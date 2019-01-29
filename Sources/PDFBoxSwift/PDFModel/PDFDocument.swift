//
//  PDFDocument.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

/// This is the in-memory representation of the PDF document.
public final class PDFDocument: Closeable {

  public let cosDocument: COSDocument

  /// The document ID.
  public var documentID: UInt64?

  /// Indicates if all security is removed or not when writing the PDF.
  public var isAllSecurityToBeRemoved = false

  private var _encryption: PDFEncryption?

  public convenience init() {
    self.init(memoryUsage: .mainMemoryOnly())
  }

  public init(memoryUsage: MemoryUsageSetting) {
    // TODO
    fatalError()
  }

  public init(_ cosDocument: COSDocument, source: RandomAccessRead? = nil) {
    self.cosDocument = cosDocument
  }

  deinit {
    try? close()
  }

  /// This will tell if this document is encrypted or not.
  public var isEncrypted: Bool {
    return cosDocument.isEncrypted
  }

  /// The encryption dictionary for this document.
  public var encryption: PDFEncryption? {
    get {
      if let encryption = _encryption {
        return encryption
      }

      if let dict = self.cosDocument.encryptionDictionary {
        let encryption = PDFEncryption(dictionary: dict)
        _encryption = encryption
        return encryption
      }

      return nil
    }
    set {
      _encryption = newValue
    }
  }

  public func close() throws {
    // TODO
  }
}
