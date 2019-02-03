//
//  CollectionOfErrors.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 03/02/2019.
//

public struct CollectionOfErrors: Error, RandomAccessCollection {

  private let errors: [Error]

  public init<S: Sequence>(_ errors: S) where S.Element == Error {
    self.errors = Array(errors)
  }

  public var startIndex: Int {
    return errors.startIndex
  }

  public var endIndex: Int {
    return errors.endIndex
  }

  public func index(after i: Int) -> Int {
    return errors.index(after: i)
  }

  public func formIndex(after i: inout Int) {
    errors.formIndex(after: &i)
  }

  public func index(before i: Int) -> Int {
    return errors.index(before: i)
  }

  public func formIndex(before i: inout Int) {
    errors.formIndex(before: &i)
  }

  public func index(_ i: Int, offsetBy distance: Int) -> Int {
    return errors.index(i, offsetBy: distance)
  }

  public func index(_ i: Int,
                    offsetBy distance: Int,
                    limitedBy limit: Int) -> Int? {
    return errors.index(i, offsetBy: distance, limitedBy: limit)
  }

  public func distance(from start: Int, to end: Int) -> Int {
    return errors.distance(from: start, to: end)
  }

  public subscript(position: Int) -> Error {
    return errors[position]
  }

  public var count: Int { return errors.count }
}

extension CollectionOfErrors: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Error...) {
    self.init(elements)
  }
}
