//
//  BinaryInteger.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

extension BinaryInteger {

#if !compiler(>=5)
  /// Returns true if this value is a multiple of `other`, and false otherwise.
  ///
  /// For two integers a and b, a is a multiple of b if there exists a third
  /// integer q such that a = q*b. For example, 6 is a multiple of 3, because
  /// 6 = 2*3, and zero is a multiple of everything, because 0 = 0*x, for any
  /// integer x.
  ///
  /// Two edge cases are worth particular attention:
  /// - `x.isMultiple(of: 0)` is `true` if `x` is zero and `false` otherwise.
  /// - `T.min.isMultiple(of: -1)` is `true` for signed integer `T`, even
  ///   though the quotient `T.min / -1` is not representable in type `T`.
  ///
  /// - Parameter other: the value to test.
  func isMultiple(of other: Self) -> Bool {
    // Nothing but zero is a multiple of zero.
    if other == 0 { return self == 0 }
    // Special case to avoid overflow on .min / -1 for signed types.
    if Self.isSigned && other == -1 { return true }
    // Having handled those special cases, this is safe.
    return self % other == 0
  }
#endif

  func numberOfDigits(radix: Int = 10) -> Int {
    guard self != 0 else {
      return 1
    }
    var n = magnitude
    var count = 0
    while n > 0 {
      count += 1
      n /= numericCast(radix)
    }
    return count
  }
}
