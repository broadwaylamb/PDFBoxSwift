//
//  PDFVector2D.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 30/01/2019.
//

/// A structure that contains a two-dimensional vector.
public struct PDFVector2D: Hashable {

  /// The vector whose components are both zero.
  public static let zero = PDFVector2D(dx: 0, dy: 0)

  /// The x component of the vector.
  public var dx: Float

  /// The y component of the vector.
  public var dy: Float

  /// Creates a vector with components specified as floating-point values.
  ///
  /// - Parameters:
  ///   - dx: The x component of the vector.
  ///   - dy: The y component of the vector.
  @inlinable
  public init(dx: Float, dy: Float) {
    self.dx = dx
    self.dy = dy
  }

  /// Creates a vector with components specified as integer values.
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the point.
  ///   - y: The y-coordinate of the point.
  @inlinable
  public init(dx: Int, dy: Int) {
    self.init(dx: Float(dx), dy: Float(dy))
  }

  #if !compiler(>=5.0)
  /// Returns the given vector unchanged.
  ///
  /// You can use the unary plus operator (+) to provide symmetry in your code.
  ///
  /// - Parameter x: A vector.
  /// - Returns: The given argument without any changes.
  @inlinable
  public prefix static func +(x: PDFVector2D) -> PDFVector2D {
    return x
  }
  #endif

  /// Returns the inverse of the specified vector.
  ///
  /// - Parameter x: A vector.
  /// - Returns: The inverse of this vector.
  @inlinable
  public prefix static func -(x: PDFVector2D) -> PDFVector2D {
    return PDFVector2D(dx: -x.dx, dy: -x.dy)
  }

  /// Adds two vectors and produces their sum vector.
  ///
  /// - Parameters:
  ///   - lhs: The first vector to add.
  ///   - rhs: The second vector to add.
  /// - Returns: The sum vector.
  @inlinable
  public static func +(lhs: PDFVector2D, rhs: PDFVector2D) -> PDFVector2D {
    return PDFVector2D(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
  }

  /// Subtracts one value from another and produces their difference vector.
  ///
  /// - Parameters:
  ///   - lhs: A vector.
  ///   - rhs: The vector to subtract from `lhs`.
  /// - Returns: The difference vector.
  @inlinable
  public static func -(lhs: PDFVector2D, rhs: PDFVector2D) -> PDFVector2D {
    return PDFVector2D(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
  }

  /// Adds two vectors and stores the result in the left-hand-side variable.
  ///
  /// - Parameters:
  ///   - lhs: The first vector to add.
  ///   - rhs: The second vector to add.
  @inlinable
  public static func +=(lhs: inout PDFVector2D, rhs: PDFVector2D) {
    lhs.dx += rhs.dx
    lhs.dy += rhs.dy
  }

  /// Subtracts the second vector from the first and stores the difference in the
  /// left-hand-side variable.
  ///
  /// - Parameters:
  ///   - lhs: A vector.
  ///   - rhs: The vector to subtract from `lhs`.
  @inlinable
  public static func -=(lhs: inout PDFVector2D, rhs: PDFVector2D) {
    lhs.dx -= rhs.dx
    lhs.dy -= rhs.dy
  }

  /// Multiplies a vector by a floating-point scalar value.
  ///
  /// - Parameters:
  ///   - lhs: A vector.
  ///   - rhs: A floating-point scalar value.
  /// - Returns: The scaled vector.
  @inlinable
  public static func *(lhs: PDFVector2D, rhs: Float) -> PDFVector2D {
    return PDFVector2D(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
  }

  /// Multiplies a vector by an integer scalar value.
  ///
  /// - Parameters:
  ///   - lhs: A vector.
  ///   - rhs: An integer scalar value.
  /// - Returns: The scaled vector.
  @inlinable
  public static func *(lhs: PDFVector2D, rhs: Int) -> PDFVector2D {
    return PDFVector2D(dx: lhs.dx * Float(rhs), dy: lhs.dy * Float(rhs))
  }

  /// Multiplies a vector by a floating-point scalar value.
  ///
  /// - Parameters:
  ///   - lhs: A floating-point scalar value.
  ///   - rhs: A vector.
  /// - Returns: The scaled vector.
  @inlinable
  public static func *(lhs: Float, rhs: PDFVector2D) -> PDFVector2D {
    return PDFVector2D(dx: rhs.dx * lhs, dy: rhs.dy * lhs)
  }

  /// Multiplies a vector by an integer scalar value.
  ///
  /// - Parameters:
  ///   - lhs: An integer scalar value.
  ///   - rhs: A vector.
  /// - Returns: The scaled vector.
  @inlinable
  public static func *(lhs: Int, rhs: PDFVector2D) -> PDFVector2D {
    return PDFVector2D(dx: rhs.dx * Float(lhs), dy: rhs.dy * Float(lhs))
  }
}

#if compiler(>=5)
extension PDFVector2D: AdditiveArithmetic {}
#endif

extension PDFVector2D: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "(\(dx), \(dy))"
  }
}
