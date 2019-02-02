//
//  PDFPage.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 02/02/2019.
//

/// A page in a PDF document.
public final class PDFPage: COSObjectable {

  private let page: COSDictionary

  /// Creates a new instance of `PDFPage` for embedding.
  ///
  /// - Parameter mediaBox: The **MediaBox** of the page. The default value is
  ///   the size of U.S. Letter (8.5 x 11 inches).
  public init(mediaBox: PDFRect = .letter) {
    page = COSDictionary()
  }

  public var cosObject: COSBase {
    return page
  }
}

extension PDFPage: Equatable {
  public static func == (lhs: PDFPage, rhs: PDFPage) -> Bool {
    return lhs.page == rhs.page
  }
}

extension PDFPage: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(page)
  }
}
