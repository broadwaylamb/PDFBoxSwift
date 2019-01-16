//
//  Sequence+ContiguousStorage.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

extension Sequence {

#if !compiler(>=5)
  internal func withContiguousStorageIfAvailable<Result>(
    _ body: (UnsafeBufferPointer<Element>) throws -> Result
  ) rethrows -> Result? {
    if let array = self as? [Element] {
      return try array.withUnsafeBufferPointer(body)
    } else if let array = self as? ContiguousArray<Element> {
      return try array.withUnsafeBufferPointer(body)
    } else if let buffer = self as? UnsafeBufferPointer<Element> {
      return try body(buffer)
    } else if let buffer = self as? UnsafeMutableBufferPointer<Element> {
      return try body(UnsafeBufferPointer(buffer))
    } else {
      return nil
    }
  }
#endif
}
