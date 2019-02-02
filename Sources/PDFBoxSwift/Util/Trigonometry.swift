//
//  Trigonometry.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 30/01/2019.
//

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// Swift doesn't have trigonometric functions in stdlib.
/// If we know that the C stdlib has these functions, we call them, otherwise
/// we compute the values of these functions ourselves using polynomial
/// approximation.
@inlinable
internal func sin(_ v: Float) -> Float {
  // Call the standard function only in non-debug mode
  // so that we're able to test out own implementation.
#if canImport(Darwin) && !DEBUG
  return Darwin.sin(v)
#elseif canImport(Glibc) && !DEBUG
  return Glibc.sin(v)
#else
  var v = v
  let doublePI: Float     = 2 * .pi
  let halfPI: Float       = .pi / 2
  let oneAndHalfPI: Float = 3 * .pi / 2

  // normalize the number using periodicity of sin
  v.formTruncatingRemainder(dividingBy: doublePI)
  v += doublePI
  v.formTruncatingRemainder(dividingBy: doublePI)

  // Get the value in quadrant 1 using symmetry of sin
  let negate = v > .pi
  if v > oneAndHalfPI {
    v = doublePI - v
  } else if v > .pi {
    v -= .pi
  } else if v > halfPI {
    v = .pi - v
  }

  var result = v
  if v >= .pi / 4 {
    result = cos(halfPI - v)
  } else {
    // Taylor series — first 4 terms
    let square = v * v
    v *= square
    result -= v / 6
    v *= square
    result += v / 120
    v *= square
    result -= v / 5040
  }

  if negate {
    result.negate()
  }

  return result
#endif
}

/// Swift doesn't have trigonometric functions in stdlib.
/// If we know that the C stdlib has these functions, we call them, otherwise
/// we compute the values of these functions ourselves using polynomial
/// approximation.
@inlinable
internal func cos(_ v: Float) -> Float {
  // Call the standard function only in non-debug mode
  // so that we're able to test out own implementation.
#if canImport(Darwin) && !DEBUG
  return Darwin.cos(v)
#elseif canImport(Glibc) && !DEBUG
  return Glibc.cos(v)
#else
  var v = v
  let doublePI: Float     = 2 * .pi
  let halfPI: Float       = .pi / 2
  let oneAndHalfPI: Float = 3 * .pi / 2

  // normalize the number using periodicity of cos
  v.formTruncatingRemainder(dividingBy: doublePI)
  v += doublePI
  v.formTruncatingRemainder(dividingBy: doublePI)

  // Get the value in quadrant 1 using symmetry of cos
  let negate = v > halfPI && v < oneAndHalfPI
  if v > oneAndHalfPI {
    v = 2 * .pi - v
  } else if v > .pi {
    v -= .pi
  } else if v > halfPI {
    v = .pi - v
  }

  var result: Float = 1
  if v >= .pi / 4 {
    result = sin(halfPI - v)
  } else {
    // Taylor series — first 4 terms
    let square = v * v
    v = square
    result -= v / 2
    v *= square
    result += v / 24
    v *= square
    result -= v / 720
  }

  if negate {
    result.negate()
  }

  return result
#endif
}
