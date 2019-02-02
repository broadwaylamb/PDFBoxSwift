//
//  PDFPoint2D.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 30/01/2019.
//

/// A structure that contains a point in a two-dimensional coordinate system.
public struct PDFPoint2D: Hashable {

  /// The point with location (0, 0).
  public static let zero = PDFPoint2D(x: 0, y: 0)

  /// The x-coordinate of the point.
  public var x: Float

  /// The y-coordinate of the point.
  public var y: Float

  /// Creates a point with coordinates specified as floating-point values.
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the point.
  ///   - y: The y-coordinate of the point.
  @inlinable
  public init(x: Float, y: Float) {
    self.x = x
    self.y = y
  }

  /// Creates a point with coordinates specified as integer values.
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the point.
  ///   - y: The y-coordinate of the point.
  @inlinable
  public init(x: Int, y: Int) {
    self.init(x: Float(x), y: Float(y))
  }

  /// Translates the `lhs` point by the specified `rhs` vector.
  ///
  /// - Parameters:
  ///   - lhs: The point to translate.
  ///   - rhs: The difference vector.
  /// - Returns: The point created by translation the `lhs` point by the `rhs`
  ///            vector.
  @inlinable
  public static func +(lhs: PDFPoint2D, rhs: PDFVector2D) -> PDFPoint2D {
    return PDFPoint2D(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
  }

  /// Translates the `lhs` point by negation of the specified `rhs` vector.
  ///
  /// - Parameters:
  ///   - lhs: The point to translate.
  ///   - rhs: The difference vector.
  /// - Returns: The point created by translation the `lhs` point by negation
  ///            of the `rhs` vector.
  @inlinable
  public static func -(lhs: PDFPoint2D, rhs: PDFVector2D) -> PDFPoint2D {
    return PDFPoint2D(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
  }

  /// Returns the vector that needs to be added to `rhs` to get `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The first point.
  ///   - rhs: The second point.
  /// - Returns: The vector that needs to be added to `rhs` to get `lhs`.
  @inlinable
  public static func -(lhs: PDFPoint2D, rhs: PDFPoint2D) -> PDFVector2D {
    return PDFVector2D(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
  }

  /// Returns the point resulting from an affine transformation of an existing
  /// point.
  ///
  /// - Parameter transform: The affine transform to apply.
  /// - Returns: A new point resulting from applying the specified affine
  ///            transform to the existing point.
  @inlinable
  public func applying(_ transform: PDFAffineTransform2D) -> PDFPoint2D {
    return PDFPoint2D(
      x: transform.scaleX * x + transform.shearX * y + transform.translateX,
      y: transform.shearY * x + transform.scaleY * y + transform.translateY
    )
  }
}

extension PDFPoint2D: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "(\(x), \(y))"
  }
}

extension PDFPoint2D: CustomStringConvertible {
  public var description: String {
    return debugDescription
  }
}
