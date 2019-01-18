//
//  COSWriterXRefEntry.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

/// This is en entry in the xref section of the physical pdf document generated
/// by `COSWriter`.
internal struct COSWriterXRefEntry {

  /// The null entry: `0000000000 65535 f`.
  public static let nullEntry =
      COSWriterXRefEntry(start: 0,
                         object: nil,
                         key: COSObjectKey(number: 0, generation: 65535),
                         isFree: true)

  /// The offset into the document,
  let offset: UInt64

  /// The COS object that this entry represents.
  let object: COSBase?

  /// The object key.
  let key: COSObjectKey

  /// The xref 'free' attribute.
  let isFree: Bool

  /// Constructor.
  ///
  /// - Parameters:
  ///   - start: The start attribute.
  ///   - object: The COS object that this entry represents.
  ///   - key: The key to the COS object.
  ///   - isFree: The xref 'free' attribute.
  init(start: UInt64,
       object: COSBase?,
       key: COSObjectKey,
       isFree: Bool = false) {
    self.offset = start
    self.object = object
    self.key = key
    self.isFree = isFree
  }
}

extension COSWriterXRefEntry: Comparable {
  static func < (lhs: COSWriterXRefEntry, rhs: COSWriterXRefEntry) -> Bool {
    return lhs.key.number < rhs.key.number
  }
}
