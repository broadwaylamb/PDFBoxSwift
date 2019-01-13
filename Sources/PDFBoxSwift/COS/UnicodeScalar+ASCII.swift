//
//  UnicodeScalar+ASCII.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 11/01/2019.
//

extension OutputStream {

  /// Writes the specified unicode scalar in its ASCII representation
  /// to this output stream.
  ///
  /// - Parameter ascii: The byte.
  /// - Precondition: `ascii.value` can be represented as ASCII (0..<128).
  public func write(ascii: UnicodeScalar) throws {
    try write(byte: UInt8(ascii: ascii))
  }
}

internal func == (lhs: UInt8, rhs: UnicodeScalar) -> Bool {
  return lhs == UInt8(ascii: rhs)
}

internal func == (lhs: UnicodeScalar, rhs: UInt8) -> Bool {
  return UInt8(ascii: lhs) == rhs
}

internal func != (lhs: UInt8, rhs: UnicodeScalar) -> Bool {
  return lhs != UInt8(ascii: rhs)
}

internal func != (lhs: UnicodeScalar, rhs: UInt8) -> Bool {
  return UInt8(ascii: lhs) != rhs
}

internal func < (lhs: UInt8, rhs: UnicodeScalar) -> Bool {
  return lhs < UInt8(ascii: rhs)
}

internal func < (lhs: UnicodeScalar, rhs: UInt8) -> Bool {
  return UInt8(ascii: lhs) < rhs
}

internal func <= (lhs: UInt8, rhs: UnicodeScalar) -> Bool {
  return lhs <= UInt8(ascii: rhs)
}

internal func <= (lhs: UnicodeScalar, rhs: UInt8) -> Bool {
  return UInt8(ascii: lhs) <= rhs
}

internal func > (lhs: UInt8, rhs: UnicodeScalar) -> Bool {
  return lhs > UInt8(ascii: rhs)
}

internal func > (lhs: UnicodeScalar, rhs: UInt8) -> Bool {
  return UInt8(ascii: lhs) > rhs
}

internal func >= (lhs: UInt8, rhs: UnicodeScalar) -> Bool {
  return lhs >= UInt8(ascii: rhs)
}

internal func >= (lhs: UnicodeScalar, rhs: UInt8) -> Bool {
  return UInt8(ascii: lhs) >= rhs
}

internal func ~=(pattern: UnicodeScalar, value: UInt8) -> Bool {
  return value == pattern
}

internal func + (lhs: UInt8, rhs: UnicodeScalar) -> UInt8 {
  return lhs + UInt8(ascii: rhs)
}

internal func + (lhs: UnicodeScalar, rhs: UInt8) -> UInt8 {
  return UInt8(ascii: lhs) + rhs
}

internal func - (lhs: UInt8, rhs: UnicodeScalar) -> UInt8 {
  return lhs - UInt8(ascii: rhs)
}

internal func - (lhs: UnicodeScalar, rhs: UInt8) -> UInt8 {
  return UInt8(ascii: lhs) - rhs
}
