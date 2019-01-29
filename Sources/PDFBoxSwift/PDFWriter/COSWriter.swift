//
//  COSWriter.swift
//  PDFBoxSwiftPDFWriter
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

/// This class acts on an in-memory representation of a PDF document.
open class COSWriter: COSVisitorProtocol {

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
  private var startxref: UInt64 = 0

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

  /// The list of x ref entries made so far
  private var xRefEntries = [COSWriterXRefEntry]()

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

  private var currentObjectKey: COSObjectKey?
  private var document: Either<PDFDocument, FDFDocument>?

  private var willEncrypt = false

  // Signing
  private var reachedSignature = false

  private var signatureOffset: UInt64 = 0
  private var signatureLength: UInt64 = 0
  private var byteRangeOffset: UInt64 = 0
  private var byteRangeLength: UInt64 = 0

  private struct Incremental {
    var input: RandomAccessRead
    var output: OutputStream
    var part: [UInt8]
  }

  private var incremental: Incremental?
  private var incrementalUpdate = false
  private var signer: Signer?
  private var incrementPart = [UInt8]()
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

  private func prepareIncrement(for document: PDFDocument) {

    let doc = document.cosDocument

    for cosObjectKey in doc.xrefTable.keys {
      if let object = doc.objectFromPool(forKey: cosObjectKey).object,
         !(object is COSNumber) {
        objectKeys[object] = cosObjectKey
        keyObject[cosObjectKey] = object
      }
    }

    let highestNumber = max(
      doc.highestXRefObjectNumber,
      doc.xrefTable.keys.max { $0.number < $1.number }?.number
        ?? doc.highestXRefObjectNumber
    )

    self.number = highestNumber
  }

  private func doWriteObject(_ object: COSBase) throws {

    writtenObjects.insert(object)

    // find the physical reference
    let key = self.key(for: object)
    currentObjectKey = key
    addXRefEntry(COSWriterXRefEntry(start: standardOutput.position,
                                    object: object,
                                    key: key))
    // write the object
    try standardOutput.write(number: key.number)
    try standardOutput.write(bytes: COSWriter.space)
    try standardOutput.write(number: key.generation)
    try standardOutput.write(bytes: COSWriter.space)
    try standardOutput.write(bytes: COSWriter.obj)
    try standardOutput.writeEOL()
    try object.accept(visitor: self)
    try standardOutput.writeEOL()
    try standardOutput.write(bytes: COSWriter.endobj)
    try standardOutput.writeEOL()
  }

  private func doWriteHeader(for document: COSDocument) throws {

    let headerString: String

    switch self.document {
    case .right?:
      headerString = "%FDF-\(document.version.rawValue)"
    default:
      headerString = "%PDF-\(document.version.rawValue)"
    }

    try standardOutput.write(utf8: headerString)
    try standardOutput.writeEOL()
    try standardOutput.write(bytes: COSWriter.comment)
    try standardOutput.write(bytes: COSWriter.garbage)
    try standardOutput.writeEOL()
  }

  private func doWriteTrailer(for document: COSDocument) throws {
    try standardOutput.write(bytes: COSWriter.trailer)
    try standardOutput.writeEOL()

    // sort xref, needed only if object keys not regenerated
    xRefEntries.sort()

    document.trailer?[native: .trailerSize] = xRefEntries.last
      .map { $0.key.number + 1 }

    // Only need to stay, if an incremental update will be performed
    if !incrementalUpdate {
      document.trailer?[native: .prev] = nil
    }
    if !document.isXRefStream {
      document.trailer?[native: .xRefStm] = nil
    }

    // Remove a checksum if present
    document.trailer?[.docChecksum] = nil

    try document.trailer?.accept(visitor: self)
  }

  private func doWriteXRefInc(for document: COSDocument,
                              hybridPrev: Int64) throws {
    if document.isXRefStream || hybridPrev != -1 {

      // the file uses XrefStreams, so we need to update
      // it with an xref stream. We create a new one and fill it
      // with data available here

      // TODO
      fatalError("XRef streams are not implemented yet")
    }

    if !document.isXRefStream || hybridPrev != -1 {
      document.trailer?[native: .prev] = document.startXref
      if hybridPrev != -1 {
        document.trailer?[native: .xRefStm] = Int64(document.startXref)
      }
      try doWriteXRefTable()
      try doWriteTrailer(for: document)
    }
  }

  private func doWriteXRefTable() throws {
    addXRefEntry(.nullEntry)

    // sort xref, needed only if object keys not regenerated
    xRefEntries.sort()

    // remember the position where the xref was written
    startxref = standardOutput.position

    try standardOutput.write(bytes: COSWriter.xref)
    try standardOutput.writeEOL()

    // write start object number and object count for this x ref section
    // we assume starting from scratch
    let xRefRanges = self.xRefRanges(for: xRefEntries)

    var entryIndex = 0
    for (firstObjectNumber, numberOfEntries) in xRefRanges {
      try writeXRefRange(firstObjectNumber: firstObjectNumber,
                         numberOfEntries: numberOfEntries)

      for _ in 0..<numberOfEntries {
        try writeXrefEntry(xRefEntries[entryIndex])
        entryIndex += 1
      }
    }
  }

  /// Write an incremental update for a non signature case.
  /// This can be used for e.g. augmenting signatures.
  private func doWriteIncrement() throws {
     if let input = incremental?.input,
        let output = incremental?.output,
        let byteArray = self.output as? ByteArrayOutputStream {
      // write existing PD
      try RandomAccessInputStream(read: input).copy(to: output)
      // write the actual incremental update
      try output.write(bytes: byteArray.bytes)
    }
  }

  private func doWriteSignature() throws {

    guard let incremental = self.incremental,
          let output = self.output as? ByteArrayOutputStream else { return }

    // calculate the ByteRange values
    let inLength = try incremental.input.count()
    let beforeLength = signatureOffset
    let afterOffset = signatureOffset + signatureLength
    let afterLength = standardOutput.position - afterOffset

    let byteRange = "0 \(beforeLength) \(afterOffset) \(afterLength)]"

    // Assign the values to the actual COSArray, so that the user can access it
    // before closing
    if byteRangeArray.count >= 4 {
      byteRangeArray[0] = COSInteger.zero
      byteRangeArray[1] = COSInteger.get(beforeLength)
      byteRangeArray[2] = COSInteger.get(afterOffset)
      byteRangeArray[3] = COSInteger.get(afterLength)
    } else {
      throw IOError.cannotWriteNewByteRange(byteRange: byteRange,
                                            maxLength: byteRangeLength)
    }

    if byteRange.count > byteRangeLength {
      throw IOError.cannotWriteNewByteRange(byteRange: byteRange,
                                            maxLength: byteRangeLength)
    }

    // copy the new incremental data into a buffer
    // (e.g. signature dict, trailer)
    try output.flush()
    incrementPart = output.bytes

    // overwrite the ByteRange in the buffer
    let byteRangeBytes = Array(byteRange.utf8)
    for i in 0..<byteRangeLength {
      incrementPart[Int(byteRangeOffset + i - inLength)] =
          i >= byteRangeBytes.count ? 0x20 : byteRangeBytes[Int(i)]
    }

    if let signer = signer {
      let dataToSign = try getDataToSign()
      let signatureBytes = try signer.sign(content: dataToSign)
      try writeExternalSignature(signatureBytes)
    }

    // else signature should be created externally and set via
    // writeSignature()
  }

  /// Returns the stream of PDF data to be signed. Clients should use this
  /// method only to create signatures externally. `write(document:)` method
  /// should have been called prior. The created signature should be set using
  /// `writeExternalSignature(_:)`.
  ///
  /// When `Signer` instance is used, `COSWriter` obtains and writes
  /// the signature itself.
  ///
  /// - Returns: Data stream to be signed.
  open func getDataToSign() throws -> InputStream {
    guard let incremental = incremental else {
      preconditionFailure("PDF not prepared for signing")
    }

    // range of incremental bytes to be signed
    // (includes /ByteRange but not /Contents)
    let incPartSigOffset = try signatureOffset - incremental.input.count()
    let afterSigOffset = incPartSigOffset + signatureLength
    let afterSigCount = UInt64(incrementPart.count) - afterSigOffset

    let ranges = [
      (offset: 0,              count: incPartSigOffset),
      (offset: afterSigOffset, count: afterSigCount)
    ]

    return SequenceInputStream(
      RandomAccessInputStream(read: incremental.input),
      COSFilterInputStream(input: incrementPart, byteRanges: ranges)
    )
  }

  /// Write externally created signature of PDF data obtained via
  /// `getDataToSign()` method.
  ///
  /// - Parameter cmsSignature: CMS signature byte array.
  open func writeExternalSignature(_ cmsSignature: [UInt8]) throws {
    guard !incrementPart.isEmpty,
          let incrementalInput = incremental?.input,
          let incrementalOutput = incremental?.output else {
      preconditionFailure("PDF not prepared for setting signature")
    }

    let signatureBytes = cmsSignature.flatMap { $0.pdfBoxASCIIHex }

    // substract 2 bytes because of the enclosing "<>"
    guard signatureBytes.count <= signatureLength - 2 else {
      throw IOError
        .cannotWriteSignature(expectedLength: Int(signatureLength - 2),
                              actualLength: signatureBytes.count)
    }

    // overwrite the signature Contents in the buffer
    let incPartSigOffset = try Int(signatureOffset - incrementalInput.count())
    incrementPart.replaceSubrange(
      incPartSigOffset + 1 ..< incPartSigOffset + 1 + signatureBytes.count,
      with: signatureBytes
    )

    // write the data to the incremental output stream
    try RandomAccessInputStream(read: incrementalInput)
      .copy(to: incrementalOutput)
    try incrementalOutput.write(bytes: incrementPart)

    // prevent furtherUse
    incrementPart = []
  }

  private func writeXRefRange(firstObjectNumber: Int,
                              numberOfEntries: Int) throws {
    try standardOutput.write(number: firstObjectNumber)
    try standardOutput.write(bytes: COSWriter.space)
    try standardOutput.write(number: numberOfEntries)
    try standardOutput.writeEOL()
  }

  private func writeXrefEntry(_ entry: COSWriterXRefEntry) throws {
    let offset = String(entry.offset, width: 10)
    let generation = String(entry.key.generation, width: 5)
    try standardOutput.write(utf8: offset)
    try standardOutput.write(bytes: COSWriter.space)
    try standardOutput.write(utf8: generation)
    try standardOutput.write(bytes: COSWriter.space)
    try standardOutput
      .write(bytes: entry.isFree ? COSWriter.xrefFree : COSWriter.xrefUsed)
    try standardOutput.writeCRLF()
  }

  private func xRefRanges(
    for entries: [COSWriterXRefEntry]
    ) -> [(firstObjectNumber: Int, numberOfEntries: Int)] {

    var lastObjectNumber = -2
    var count = 1
    var array = [(firstObjectNumber: Int, numberOfEntries: Int)]()

    for entry in entries {
      let objectNumber = entry.key.number
      if objectNumber == lastObjectNumber + 1 {
        count += 1
      } else if lastObjectNumber != -2  {
        array.append((firstObjectNumber: lastObjectNumber - count + 1,
                      numberOfEntries: count))
        count = 1
      }
      lastObjectNumber = objectNumber
    }

    return array
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
  open func visit(_ array: COSArray) throws -> Any? {

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
        if willEncrypt ||
           incrementalUpdate ||
           subValue is COSDictionary ||
           subValue == nil {

          // https://issues.apache.org/jira/browse/PDFBOX-4308
          // added willEncrypt to prevent an object
          // that is referenced several times from being written
          // direct and indirect, thus getting encrypted
          // with wrong object number or getting encrypted twice
          addObjectToWrite(current)
          try writeReference(current)
        } else {
          try subValue!.accept(visitor: self)
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
  open func visit(_ bool: COSBoolean) throws -> Any? {
    try bool.writePDF(standardOutput)
    return nil
  }

  @discardableResult
  open func visit(_ dictionary: COSDictionary) throws -> Any? {

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
        let subValue = value.object
        if willEncrypt ||
           incrementalUpdate ||
           value.object is COSDictionary ||
           subValue == nil {

          // https://issues.apache.org/jira/browse/PDFBOX-4308
          // added willEncrypt to prevent an object
          // that is referenced several times from being written
          // direct and indirect, thus getting encrypted
          // with wrong object number or getting encrypted twice
          addObjectToWrite(value)
          try writeReference(value)
        } else {
          try subValue!.accept(visitor: self)
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
  open func visit(_ document: COSDocument) throws -> Any? {

    if !incrementalUpdate {
      try doWriteHeader(for: document)
    } else {
      // https://issues.apache.org/jira/browse/PDFBOX-1051
      // Sometimes the original file will be missing a newline at the end
      // In order to avoid having %%EOF the first object on the same line
      // as the %%EOF, we put a newline here. If there's already one at
      // the end of the file, an extra one won't hurt.
      try standardOutput.writeCRLF()
    }

    try doWriteBody(document)

    let hybridPrev = document.trailer?[native: .xRefStm] ?? -1

    if incrementalUpdate || document.isXRefStream {
      try doWriteXRefInc(for: document, hybridPrev: hybridPrev)
    } else {
      try doWriteXRefTable()
      try doWriteTrailer(for: document)
    }

    try standardOutput.write(bytes: COSWriter.startXref)
    try standardOutput.writeEOL()
    try standardOutput.write(number: startxref)
    try standardOutput.writeEOL()
    try standardOutput.write(bytes: COSWriter.eof)
    try standardOutput.writeEOL()

    if incrementalUpdate {
      if signatureOffset == 0 || byteRangeOffset == 0 {
        try doWriteIncrement()
      } else {
        try doWriteSignature()
      }
    }
    return nil
  }

  @discardableResult
  open func visit(_ float: COSFloat) throws -> Any? {
    try float.writePDF(standardOutput)
    return nil
  }

  @discardableResult
  open func visit(_ int: COSInteger) throws -> Any? {
    try int.writePDF(standardOutput)
    return nil
  }

  @discardableResult
  open func visit(_ name: COSName) throws -> Any? {
    try name.writePDF(standardOutput)
    return nil
  }

  @discardableResult
  open func visit(_ null: COSNull) throws -> Any? {
    try null.writePDF(standardOutput)
    return nil
  }

  open func writeReference(_ object: COSBase) throws {
    let key = self.key(for: object)
    try standardOutput.write(number: key.number)
    try standardOutput.write(bytes: COSWriter.space)
    try standardOutput.write(number: key.generation)
    try standardOutput.write(bytes: COSWriter.space)
    try standardOutput.write(bytes: COSWriter.reference)
  }

  @discardableResult
  open func visit(_ stream: COSStream) throws -> Any? {
    if willEncrypt {
      // TODO
      fatalError("Encryption is not implemented yet")
    }

    try visit(stream as COSDictionary)
    try standardOutput.write(bytes: COSWriter.stream)
    try standardOutput.writeCRLF()

    let input = try stream.createRawInputStream()
    try input.copy(to: standardOutput)
    try input.close()
    try standardOutput.writeCRLF()
    try standardOutput.write(bytes: COSWriter.endstream)
    try standardOutput.writeEOL()
    return nil
  }

  @discardableResult
  open func visit(_ string: COSString) throws -> Any? {
    if willEncrypt {
      // TODO
      fatalError("Encryption is not implemented yet")
    }
    try COSWriter.writeString(string, output: standardOutput)
    return nil
  }

  private func doWriteBody(_ document: COSDocument) throws {
    if let root = document.trailer?[cos: .root] {
      addObjectToWrite(root)
    }
    if let info = document.trailer?[cos: .info] {
      addObjectToWrite(info)
    }
    try doWriteObjects()
    willEncrypt = false
    if let encrypt = document.trailer?[cos: .encrypt] {
      addObjectToWrite(encrypt)
    }
    try doWriteObjects()
  }

  private func doWriteObjects() throws {
    while let nextObject = objectsToWrite.popFirst() {
      objectsToWriteSet.remove(nextObject)
      try doWriteObject(nextObject)
    }
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

  private func addXRefEntry(_ entry: COSWriterXRefEntry) {
    xRefEntries.append(entry)
  }

  /// This will close the stream.
  func close() throws {
    var ensure = Ensure()
    ensure.do { try standardOutput.close() }
    ensure.do { try incremental?.output.close() }
    try ensure.done()
  }

  /// This will write the PDF document.
  ///
  /// - Parameter document: The document to write.
  open func write<C: Clock>(document: COSDocument, clock: C) throws {
    try write(document: PDFDocument(document), clock: clock)
  }

  /// This will write the PDF document. If signature should be created
  /// externally, `writeExternalSignature(_:)` should be invoked to set
  /// signature after calling this method.
  ///
  /// - Parameters:
  ///   - document: The document to write.
  ///   - signer: `Signer` to be used for signing; `nil` if external signing
  ///             would be performed or there will be no signing at all.
  open func write<C: Clock>(document: PDFDocument,
                            signer: Signer? = nil,
                            clock: C) throws {

    let idTime = document.documentID ?? UInt64(clock.now() * 1000)

    self.document = Either(document)
    self.signer = signer

    if incrementalUpdate {
      prepareIncrement(for: document)
    }

    // if the document says we should remove encryption, then we shouldn't
    // encrypt
    if document.isAllSecurityToBeRemoved {
      willEncrypt = false
      // also need to get rid of the "Encrypt" in the trailer so readers
      // don't try to decrypt a document which is not encrypted
      document.cosDocument.trailer?[cos: .encrypt] = nil
    } else if let encryption = document.encryption {
      if !incrementalUpdate {
        let securityHandler = try encryption.getSecurityHandler()
        precondition(securityHandler.hasProtectionPolicy, """
                     PDF contains an encryption dictionary, please remove it \
                     with 'allSecurityToBeRemoved = true' or set a protection
                     policy with protect(_:)
                     """)
        try securityHandler.prepareDocumentForEncryption(document)
      }
      willEncrypt = true
    } else {
      willEncrypt = false
    }

    let cosDoc = document.cosDocument
    let trailer = cosDoc.trailer
    let idArray = trailer?[cos: .id] ?? COSArray()
    let missingID = idArray.count != 2

    if missingID || incrementalUpdate {

      let md5 = MD5()

      // algorithm says to use time/path/size/values in doc to generate the id.
      // we don't have path or size, so do the best we can
      md5.update(withBytes: ArraySlice(String(idTime).utf8))

      if let info = trailer?[cos: .info] {
        for value in info.values {
          md5.update(withBytes: ArraySlice(String(describing: value).utf8))
        }
      }

      let digest = md5.finish()

      // reuse origin documentID if available as first value
      let firstID = missingID
        ? COSString(bytes: digest)
        : idArray[0] as? COSString

      // it's ok to use the same ID for the second part if the ID is created
      // for the first time
      let secondID = missingID ? firstID : COSString(bytes: digest)
      trailer?[cos: .id] = [firstID, secondID]
    }

    try cosDoc.accept(visitor: self)
  }

  /// This will write the FDF document.
  ///
  /// - Parameter document: The document to write.
  open func write(document: FDFDocument) throws {
    self.document = .right(document)
    willEncrypt = false
    try document.cosDocument.accept(visitor: self)
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
