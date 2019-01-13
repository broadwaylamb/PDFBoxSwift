//
//  COSWriter.swift
//  PDFBoxSwiftPDFWriter
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

/// This class acts on an in-memory representation of a PDF document.
public final class COSWriter: COSVisitorProtocol {

  // MARK: - Tokens

  /// The dictionary open token.
  internal static let dictOpen: [UInt8] = Array("<<".utf8)

  /// The dictionary close token.
  internal static let dictClose: [UInt8] = Array(">>".utf8)

  /// Space character.
  internal static let space: [UInt8] = Array(" ".utf8)

  /// The start to a PDF comment.
  internal static let comment: [UInt8] = Array("%".utf8)

  /// The output version of the PDF.
  internal static let version: [UInt8] = Array("PDF-1.4".utf8)

  /// Garbage bytes used to create the PDF header.
  internal static let garbage: [UInt8] = [0xF6, 0xE4, 0xFC, 0xDF]

  /// The EOF constant.
  internal static let eof: [UInt8] = Array("%%EOF".utf8)

  /// The reference token.
  internal static let reference: [UInt8] = Array("R".utf8)

  /// The XREF token.
  internal static let xref: [UInt8] = Array("xref".utf8)

  /// The xref free token.
  internal static let xrefFree: [UInt8] = Array("f".utf8)

  /// The xref used token.
  internal static let xrefUsed: [UInt8] = Array("n".utf8)

  /// The trailer token.
  internal static let trailer: [UInt8] = Array("trailer".utf8)

  /// The start xref token.
  internal static let startXref: [UInt8] = Array("startxref".utf8)

  /// The start object token.
  internal static let obj: [UInt8] = Array("obj".utf8)

  /// The end object token.
  internal static let endobj: [UInt8] = Array("endobj".utf8)

  /// The array open token.
  internal static let arrayOpen: [UInt8] = Array("[".utf8)

  /// The array close token.
  internal static let arrayClose: [UInt8] = Array("]".utf8)

  /// The open stream token.
  internal static let stream: [UInt8] = Array("stream".utf8)

  /// The close stream token.
  internal static let endstream: [UInt8] = Array("endstream".utf8)

  // MARK: -

  /// The stream where we create the PDF output.
  private let output: OutputStream

  /// The stream used to write standard COS data.
  private let standardOutput: COSStandardOutputStream

  /// The start position of the x ref section
  private var startxref = 0

  /// The current object number.
  private var number = 0

  /// Maps the objects to the keys generated in the writer.
  ///
  /// Used for indirect references in other objects.
  private var objectKeys = [COSBase : COSObjectKey]()

  /// Maps the keys generated in the writer to the objects.
  ///
  /// Used for indirect references in other objects.
  private var keyObject = [COSObjectKey : COSBase]()

  private var objectsToWriteSet = Set<COSBase>()

  /// A list of objects to write.
  private var objectsToWrite = LinkedList<COSBase>()

  /// A set of objects already written
  private var writtenObjects = Set<COSBase>()

  /// An "actual" is any `COSBase` that is not a `COSObject`.
  ///
  /// We need to keep a list of the actuals that are added
  /// as well as the objects because there is a problem
  /// when adding a `COSObject` and then later adding
  /// the actual for that object, so we will track
  /// actuals separately.
  private var actualsAdded = Set<COSBase>()

  private var willEncrypt = false

  // Signing
  private var reachedSignature = false

  private var signatureOffset = 0
  private var signatureLength = 0
  private var byteRangeOffset = 0
  private var byteRangeLength = 0

  private struct Incremental {
    var input: RandomAccessRead
    var output: OutputStream
    var part: [UInt8]
  }

  private var incremental: Incremental?
  private var incrementalUpdate = false
  private var byteRangeArray = COSArray()

  /// `COSWriter` constructor.
  ///
  /// - Parameter outputStream: The output stream to write the PDF.
  ///                           It will be closed when this object is closed.
  ///                           or deallocated.
  public init(outputStream: OutputStream) {
    self.output = outputStream
    self.standardOutput = COSStandardOutputStream(out: outputStream)
  }

  /// `COSWriter` constructor for incremental updates.
  ///
  /// - Parameters:
  ///   - outputStream: output stream where the new PDF data will be written.
  ///                   It will be closed when this object is closed
  ///                   or deallocated.
  ///   - inputData: Random access read containing source PDF data.
  public init(outputStream: OutputStream, inputData: RandomAccessRead) throws {

    // write to buffer instead of output
    output = ByteArrayOutputStream()
    standardOutput = try COSStandardOutputStream(out: output,
                                                position: inputData.count())

    incrementalUpdate = true
    incremental = Incremental(input: inputData,
                              output: outputStream,
                              part: [])
  }

  deinit {
    try? close()
  }

  /// This will get the object key for the object.
  ///
  /// - Parameter object: The object to get the key for.
  /// - Returns: The object key for the object.
  private func key(for object: COSBase) -> COSObjectKey {

    let actual = (object as? COSObject)?.object ?? object

    let key = objectKeys[actual] ?? objectKeys[object]

    if let key = key {
      return key
    } else {
      number += 1
      let key = COSObjectKey(number: number, generation: 0)
      objectKeys[object] = key
      return key
    }
  }

  @discardableResult
  public func visit(_ array: COSArray) throws -> Any? {

    try standardOutput.write(bytes: COSWriter.arrayOpen)
    for (i, current) in array.enumerated() {
      switch current {
      case let current as COSDictionary:
        if current.isDirect {
          try visit(current)
        } else {
          addObjectToWrite(current)
          try writeReference(current)
        }
      case let current as COSObject:
        let subValue = current.object
        if willEncrypt || incrementalUpdate || subValue is COSDictionary {

          // https://issues.apache.org/jira/browse/PDFBOX-4308
          // added willEncrypt to prevent an object
          // that is referenced several times from being written
          // direct and indirect, thus getting encrypted
          // with wrong object number or getting encrypted twice
          addObjectToWrite(current)
          try writeReference(current)
        } else {
          try subValue.accept(visitor: self)
        }
      case nil, is COSNull:
        try COSNull.null.accept(visitor: self)
      case let current?:
        try current.accept(visitor: self)
      }

      if i < array.endIndex - 1 {
        if i.isMultiple(of: 10) {
          try standardOutput.writeEOL()
        } else {
          try standardOutput.write(bytes: COSWriter.space)
        }
      }
    }

    try standardOutput.write(bytes: COSWriter.arrayClose)
    try standardOutput.writeEOL()

    return nil
  }

  @discardableResult
  public func visit(_ bool: COSBoolean) throws -> Any? {
    try bool.writePDF(standardOutput)
    return nil
  }

  @discardableResult
  public func visit(_ dictionary: COSDictionary) throws -> Any? {

    if !reachedSignature {
      let itemType = dictionary[cos: .type]
      if itemType == .sig || itemType == .docTimeStamp {
        reachedSignature = true
      }
    }

    try standardOutput.write(bytes: COSWriter.dictOpen)
    try standardOutput.writeEOL()

    for (key, value) in dictionary {

      try key.accept(visitor: self)

      try standardOutput.write(bytes: COSWriter.space)

      switch value {
      case let value as COSDictionary:
        if !incrementalUpdate {

          // write all XObjects as direct objects, this will save some size
          // https://issues.apache.org/jira/browse/PDFBOX-3684
          // but avoid dictionary that references itself
          if let item = value[.xObject], key != .xObject {
            item.isDirect = true
          }

          if let item = value[.resources], key != .resources {
            item.isDirect = true
          }
        }

        if value.isDirect {
          // If the object should be written direct, we need
          // to pass the dictionary to the visitor again.
          try visit(value)
        } else {
          addObjectToWrite(value)
          try writeReference(value)
        }
      case let value as COSObject:
        if willEncrypt || incrementalUpdate || value.object is COSDictionary {

          // https://issues.apache.org/jira/browse/PDFBOX-4308
          // added willEncrypt to prevent an object
          // that is referenced several times from being written
          // direct and indirect, thus getting encrypted
          // with wrong object number or getting encrypted twice
          addObjectToWrite(value)
          try writeReference(value)
        } else {
          try value.object.accept(visitor: self)
        }
      default:
        // If we reach the PDF signature, we need to determinate the position
        // of the content and byte range
        if reachedSignature && key == .contents {
          signatureOffset = standardOutput.position
          try value.accept(visitor: self)
          signatureLength = standardOutput.position - signatureOffset
        } else if reachedSignature && key == .byteRange {
          byteRangeArray = value as? COSArray ?? []
          byteRangeOffset = standardOutput.position + 1
          try value.accept(visitor: self)
          byteRangeLength = standardOutput.position - 1 - byteRangeOffset
          reachedSignature = false
        } else {
          try value.accept(visitor: self)
        }
      }

      try standardOutput.writeEOL()
    }

    try standardOutput.write(bytes: COSWriter.dictClose)
    try standardOutput.writeEOL()
    
    return nil
  }

  @discardableResult
  public func visit(_ float: COSFloat) throws -> Any? {
    try float.writePDF(standardOutput)
    return nil
  }

  @discardableResult
  public func visit(_ int: COSInteger) throws -> Any? {
    try int.writePDF(standardOutput)
    return nil
  }

  @discardableResult
  public func visit(_ name: COSName) throws -> Any? {
    try name.writePDF(standardOutput)
    return nil
  }

  @discardableResult
  public func visit(_ null: COSNull) throws -> Any? {
    try null.writePDF(standardOutput)
    return nil
  }

  public func writeReference(_ object: COSBase) throws {
    let key = self.key(for: object)
    try standardOutput.write(number: key.number)
    try standardOutput.write(bytes: COSWriter.space)
    try standardOutput.write(number: key.generation)
    try standardOutput.write(bytes: COSWriter.space)
    try standardOutput.write(bytes: COSWriter.reference)
  }

  @discardableResult
  public func visit(_ string: COSString) throws -> Any? {
    // TODO
    return nil
  }

  private func addObjectToWrite(_ object: COSBase) {

    let actual = (object as? COSObject)?.object ?? object

    guard !writtenObjects.contains(object),
          !objectsToWriteSet.contains(object),
          !actualsAdded.contains(actual) else {
      return
    }

    let cosObjectKey = objectKeys[actual]
    let cosBase = cosObjectKey.flatMap { keyObject[$0] }

    if objectKeys[actual] != nil,
       let object = object as? COSUpdateInfo,
       let cosBase = cosBase as? COSUpdateInfo,
       !object.needsToBeUpdated,
       !cosBase.needsToBeUpdated {
      return
    }

    objectsToWrite.append(object)
    objectsToWriteSet.insert(object)
    actualsAdded.insert(actual)
  }

  /// This will close the stream.
  func close() throws {
    try standardOutput.close()
    try incremental?.output.close()
  }

  /// This will output the given string as a PDF object.
  ///
  /// - Parameters:
  ///   - string: `COSString` to be written
  ///   - output: The stream to write to.
  public static func writeString(_ string: COSString,
                                 output: OutputStream) throws {
    try writeString(bytes: string.bytes,
                    forceHex: string.forceHexForm,
                    output: output)
  }

  /// This will output the given text/byte string as a PDF object.
  ///
  /// - Parameters:
  ///   - bytes: The byte representation of a string to be written
  ///   - output: The stream to write to.
  public static func writeString<Bytes: Collection>(
    bytes: Bytes,
    output: OutputStream
  ) throws where Bytes.Element == UInt8 {
    try writeString(bytes: bytes, forceHex: false, output: output)
  }

  private static func writeString<Bytes: Collection>(
    bytes: Bytes,
    forceHex: Bool,
    output: OutputStream
  ) throws where Bytes.Element == UInt8 {

    // check for non-ASCII characters
    // https://issues.apache.org/jira/browse/PDFBOX-3107
    // EOL markers within a string are troublesome
    let isAscii = forceHex
      ? true
      : bytes.allSatisfy { $0 <= 127 && $0 != "\r" && $0 != "\n" }

    if isAscii && !forceHex {
      try output.write(ascii: "(")
      for byte in bytes {
        switch byte {
        case "(", ")", "\\":
          try output.write(ascii: "\\")
          try output.write(byte: byte)
        default:
          try output.write(byte: byte)
        }
      }
      try output.write(ascii: ")")
    } else {
      // write hex string
      try output.write(ascii: "<")
      try output.writeAsHex(numbers: bytes)
      try output.write(ascii: ">")
    }
  }
}
