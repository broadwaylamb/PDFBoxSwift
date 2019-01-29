//
//  PDFPermissions.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 29/01/2019.
//

public struct PDFPermissions: OptionSet, Hashable {

  public let rawValue: Int32

  @inlinable
  public init(rawValue: Int32) {
    self.rawValue =
      Int32(bitPattern: 0b11111111111111111111000011000000) |
      Int32(bitPattern: 0b11111111111111111111111111111100) &
      rawValue
  }

  public static let all = PDFPermissions(rawValue: ~3)

  public static let none = PDFPermissions()

  /// - *(Security handlers of revision 2)* Print the document.
  /// - *(Security handlers of revision 3 or greater)* Print the document
  ///   (possibly not at the highest quality level, depending on whether bit
  ///   `highQualityPrint` is also set).
  public static let print = PDFPermissions(rawValue: 1 << 2)

  /// Modify the contents of the document by operations other than those
  /// controlled by bits `modifyAnnotations`, `fillInForm`,
  /// and `assembleDocument`.
  public static let modify = PDFPermissions(rawValue: 1 << 3)

  /// - *(Security handlers of revision 2)* Copy or otherwise extract text and
  /// graphics from the document, including extracting text and graphics
  /// (in support of accessibility to users with disabilities or for other
  /// purposes).
  /// - *(Security handlers of revision 3 or greater)* Copy or otherwise extract
  /// text and graphics from the document by operations other than that
  /// controlled by bit `extractForAccessibility`.
  public static let extract = PDFPermissions(rawValue: 1 << 4)

  /// Add or modify text annotations, fill in interactive form fields, and, if
  /// bit `modify` is also set, create or modify interactive form fields
  /// (including signature fields).
  public static let modifyAnnotations = PDFPermissions(rawValue: 1 << 5)

  /// *(Security handlers of revision 3 or greater)* Fill in existing
  /// interactive form fields (including signature fields), even if
  /// bit `modifyAnnotations` is clear.
  public static let fillInForm = PDFPermissions(rawValue: 1 << 8)

  /// *(Security handlers of revision 3 or greater)* Extract text and graphics
  /// (in support of accessibility to users with disabilities or for other
  /// purposes).
  public static let extractForAccessibility = PDFPermissions(rawValue: 1 << 9)

  /// *(Security handlers of revision 3 or greater)* Assemble the document
  /// (insert, rotate, or delete pages and create bookmarks or thumbnail
  /// images), even if bit `modify` is clear.
  public static let assembleDocument = PDFPermissions(rawValue: 1 << 10)

  /// *(Security handlers of revision 3 or greater)* Print the document to
  /// a representation from which a faithful digital copy of the PDF content
  /// could be generated. When this bit is clear (and bit `print` is set),
  /// printing is limited to a low-level representation of the appearance,
  /// possibly of degraded quality.
  public static let highQualityPrint = PDFPermissions(rawValue: 1 << 11)
}
