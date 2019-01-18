//
//  FDFDocument.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

/// This is the in-memory representation of the FDF document.
public final class FDFDocument: Closeable {

  public let cosDocument: COSDocument

  public init() {
    cosDocument = COSDocument()
    cosDocument.version = .v1_2

    // First we need a trailer
    cosDocument.trailer = COSDictionary()

    // TODO
    fatalError()
  }

  deinit {
    try? close()
  }

  public func close() throws {
    // TODO
  }
}

