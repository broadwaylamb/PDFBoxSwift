//
//  PDFDocument.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

/// This is the in-memory representation of the PDF document.
public final class PDFDocument: Closeable {

  public let cosDocument: COSDocument

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

  public func close() throws {
    // TODO
  }
}
