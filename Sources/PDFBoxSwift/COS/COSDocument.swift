//
//  COSDocument.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

public final class COSDocument: COSBase, Closeable {

  public var version: PDFVersion = .v1_4

  /// Maps object keys to a `COSObject`s. Note that references to these objects
  /// are also stored in `COSDictionary` objects that map a name to a specific
  /// object.
  private var objectPool: [COSObjectKey : COSObject] = [:]

  /// Maps object and generation IDs to object byte offsets.
  internal private(set) var xrefTable: [COSObjectKey : UInt64] = [:]

  /// List containing all streams which are created when creating a new PDF.
  private var streams: [COSStream] = []

  /// Document trailer dictionary.
  public internal(set) var trailer: COSDictionary?

  /// Signal that document is already decrypted.
  internal var isDecrypted = false

  /// The startXref position of the parsed document. This will only be needed
  /// for incremental updates.
  internal var startXref: UInt64 = 0

  public private(set) var isClosed = false

  /// Determines if the trailer is an XRef stream or not.
  internal var isXRefStream = false

  private let scratchFile: ScratchFile

  /// Used for incremental saving, to avoid XRef object numbers from being
  /// reused.
  internal var highestXRefObjectNumber: Int = 0

  /// Initializer that will use the provide memory handler for storage of
  /// the PDF streams.
  ///
  /// - Parameter scratchFile: Memory handler for buffering of PDF streams.
  public init(scratchFile: ScratchFile) {
    self.scratchFile = scratchFile
    super.init()
  }

  /// Constructor. Uses main memory to buffer PDF streams.
  public override convenience init() {
    self.init(scratchFile: .createMainMemoryOnly())
  }

  deinit {
    try? close()
  }

  /// Creates a new `COSStream` using the current configuration for scratch
  /// files.
  ///
  /// - Returns: The new `COSStream`.
  public func createCOSStream() -> COSStream {
    let stream = COSStream(scratchFile: scratchFile)
    // Collect all COSStreams so that they can be closed when closing
    // the COSDocument.
    // This is limited to newly created PDFs as all COSStreams of an existing
    // pdf are collected within the map objectPool
    streams.append(stream)
    return stream
  }

  /// Creates a new `COSStream` using the current configuration for
  /// scratch files.
  ///
  /// - Parameter dictionary: The corresponding dictionary.
  /// - Returns: The new `COSStream`.
  internal func createCOSStream(
    withDictionary dictionary: COSDictionary
  ) -> COSStream {
    let stream = COSStream(scratchFile: scratchFile)

    // TODO: This has complexity O(n*m) since the subscript is O(n).
    // This can work in O(n+m).
    for (key, value) in dictionary {
      stream[key] = value
    }
    return stream
  }

  /// This will get the first dictionary object by `type`.
  ///
  /// - Parameter type: The type of the object.
  /// - Returns: An object with the specified type.
  public func firstObject(ofType type: COSName) -> COSObject? {
    return objectPool.values.first {
      ($0.object as? COSDictionary)?[cos: .type] == type
    }
  }

  /// This will get all the dictionary objects of the specified `type`.
  ///
  /// - Parameter type: The type of the object.
  /// - Returns: This will return an object with the specified `type`.
  public func objects(
    ofType type: COSName
  ) -> [COSObject] {
    return objectPool.values.filter {
      ($0.object as? COSDictionary)?[cos: .type] == type
    }
  }

  /// Returns the `COSObjectKey` for a given COS object, or `nil` if there is
  /// none. This lookup iterates over all objects in a PDF, which may be slow
  /// for large files.
  ///
  /// - Parameter object: COS object.
  /// - Returns: The key of `object`.
  public func key(of object: COSBase) -> COSObjectKey? {
    return objectPool.first(where: { $0.value.object == object })?.key
  }

  /// This will print contents to stdout.
  public func print() {
    for object in objectPool.values {
      Swift.print(object)
    }
  }

  /// This will tell if this is an encrypted document.
  public var isEncrypted: Bool {
    return encryptionDictionary != nil
  }

  /// The encryption dictionary of the document.
  ///
  /// It is `nil` if the document is not encrypted.
  ///
  /// Should only be set when encrypting the document.
  internal var encryptionDictionary: COSDictionary? {
    get {
      return trailer?[cos: .encrypt]
    }
    set {
      trailer?[cos: .encrypt] = newValue
    }
  }

  /// The document ID
  internal var documentID: COSArray? {
    get {
      return trailer?[cos: .id]
    }
    set {
      trailer?[cos: .id] = newValue
    }
  }

  /// This will get the document catalog.
  ///
  /// - Returns: The catalog that is the root of the document.
  /// - Throws: `IOError` if no catalog can be found.
  public func catalog() throws -> COSObject {
    if let catalog = firstObject(ofType: .catalog) {
      return catalog
    } else {
      throw IOError.missingCatalog
    }
  }

  /// The list of all available objects.
  public var objects: [COSObject] {
    return Array(objectPool.values)
  }

  public override func accept(visitor: COSVisitorProtocol) throws -> Any? {
    return try visitor.visit(self)
  }

  /// This will close all storage and delete the temporary files.
  public func close() throws {
    guard !isClosed else {
      return
    }

    // Make sure that:
    // - first error is kept
    // - all COSStreams are closed
    // - ScratchFile is closed

    var firstError: Error?

    for object in objects {
      let cosObject = object.object
      if let stream = cosObject as? COSStream {
        do {
          try stream.close()
        } catch {
          if firstError == nil {
            firstError = error
          }
        }
      }
    }

    for stream in streams {
      do {
        try stream.close()
      } catch {
        if firstError == nil {
          firstError = error
        }
      }
    }

    do {
      try scratchFile.close()
    } catch {
      if firstError == nil {
        firstError = error
      }
    }

    isClosed = true

    // rethrow the first error to keep method contract
    if let error = firstError {
      throw error
    }
  }

  /// This will get an object from the pool.
  ///
  /// - Parameter key: The object key.
  /// - Returns: The object in the pool or a new one if it has not been parsed
  ///            yet.
  public func objectFromPool(forKey key: COSObjectKey?) -> COSObject? {
    if let object = key.flatMap({ objectPool[$0] }) {
      return object
    }
    // this was a forward reference, make "proxy" object
    return COSObject(object: nil,
                     objectNumber: key?.number ?? 0,
                     generationNumber: key?.generation ?? 0)
  }

  /// Removes an object from the object pool.
  ///
  /// - Parameter key: The object key.
  /// - Returns: The object that was removed or `nil` if the object was
  ///            not found
  @discardableResult
  internal func removeObject(forKey key: COSObjectKey) -> COSObject? {
    return objectPool.removeValue(forKey: key)
  }

  /// Populate XRef dictionary with given values. Each entry maps
  /// a `COSObjectKey` to a byte offset in the file.
  ///
  /// - Parameter values: XRef table entries to be added.
  internal func addXReftTable(_ values: [COSObjectKey : UInt64]) {
    xrefTable.merge(values, uniquingKeysWith: { $1 })
  }
}
