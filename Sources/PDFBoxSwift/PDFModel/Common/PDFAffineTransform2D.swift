//
//  PDFAffineTransform2D.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 30/01/2019.
//

/// An affine transformation matrix is used to rotate, scale, translate, or skew
/// the objects you draw in a graphics context. The `PDFAffineTransform2D` type
/// provides functions for creating, concatenating, and applying affine
/// transformations.
///
/// Affine transforms are represented by a 3 by 3 matrix:
///
/// ```
/// / scaleX     shearY     0 \
/// | shearX     scaleY     0 |
/// \ translateX translateY 1 /
/// ```
///
/// Because the third column is always `(0,0,1)`, the `PDFAffineTransform2D`
/// structure contains values for only the first two columns.
///
/// Conceptually, an affine transform multiplies a row vector representing each
/// point `(x,y)` in your drawing by this matrix, producing a vector that
/// represents the corresponding point `(x’,y’)`:
/// ```
///                       / a          shearY     0 \
/// (x’ y’ 1) = (x y 1) × | shearX     scaleY     0 |
///                       \ translateX translateY 1 /
/// ```
///
/// Given the 3 by 3 matrix, the following equations are used to transform
/// a point `(x, y)` in one coordinate system into a resultant point `(x’,y’)`
/// in another coordinate system.
/// ```
/// x’ = scaleX * x + shearX * y + translateX
/// y’ = shearY * x + scaleY * y + translateY
/// ```
///
/// The matrix thereby “links” two coordinate systems — it specifies how points
/// in one coordinate system map to points in another.
///
/// Note that you do not typically need to create affine transforms directly.
/// If you want only to draw an object that is scaled or rotated, for example,
/// it is not necessary to construct an affine transform to do so. The most
/// direct way to manipulate your drawing — whether by movement, scaling,
/// or rotation — is to call the functions `translateBy(x:y:)`, `scaleBy(x:y:)`,
/// or `rotate(by:)`, respectively.
public struct PDFAffineTransform2D: Hashable {

  /// The entry at position [1,1] in the matrix.
  public var scaleX: Float

  /// The entry at position [1,2] in the matrix.
  public var shearY: Float

  /// The entry at position [2,1] in the matrix.
  public var shearX: Float

  /// The entry at position [2,2] in the matrix.
  public var scaleY: Float

  /// The entry at position [3,1] in the matrix.
  public var translateX: Float

  /// The entry at position [3,2] in the matrix.
  public var translateY: Float

  /// Creates a new affine transformation using the matrix with provided values.
  ///
  /// - Parameters:
  ///   - scaleX:  The entry at position [1,1] in the matrix.
  ///   - shearY:  The entry at position [1,2] in the matrix.
  ///   - shearX:  The entry at position [2,1] in the matrix.
  ///   - scaleY:  The entry at position [2,2] in the matrix.
  ///   - translateX: The entry at position [3,1] in the matrix.
  ///   - translateY: The entry at position [3,2] in the matrix.
  @inlinable
  public init(scaleX:  Float,    shearY:  Float,
              shearX:  Float,    scaleY:  Float,
              translateX: Float, translateY: Float) {
    self.scaleX = scaleX
    self.shearY = shearY
    self.shearX = shearX
    self.scaleY = scaleY
    self.translateX = translateX
    self.translateY = translateY
  }

  /// Creates an affine transformation matrix constructed from a rotation value
  /// you provide.
  ///
  /// This function creates a `PDFAffineTransform2D` structure, which you can
  /// use (and reuse, if you want) to rotate a coordinate system. The matrix
  /// takes the following form:
  /// ```
  /// / cos(angle)  sin(angle)  0 \
  /// | -sin(angle) cos(angle)  0 |
  /// \ 0           0           1 /
  /// ```
  ///
  /// These are the resulting equations used to apply the rotation to a point
  /// `(x, y)`:
  /// ```
  /// x’ = x * cos(angle) - y * sin(angle)
  /// y’ = x * sin(angle) + y * sin(angle)
  /// ```
  /// - Parameter angle: The angle, in radians, by which this matrix rotates
  ///                    the coordinate system axes.
  @inlinable
  public init(rotationAngle angle: Float) {
    let cosine = cos(angle)
    let sine = sin(angle)
    self.init(scaleX:     cosine, shearY:     sine,
              shearX:     -sine,  scaleY:     cosine,
              translateX: 0,      translateY: 0)
  }

  /// Creates an affine transformation matrix constructed from scaling values
  /// you provide.
  ///
  /// This function creates a `PDFAffineTransform2D` structure, which you can
  /// use (and reuse, if you want) to scale a coordinate system. The matrix
  /// takes the following form:
  /// ```
  /// / sx 0  0 \
  /// | 0  sy 0 |
  /// \ 0  0  1 /
  /// ```
  ///
  /// These are the resulting equations used to scale the coordinates of
  /// a point `(x,y)`:
  /// ```
  /// x’ = x * sx
  /// y’ = y * sy
  /// ```
  ///
  /// - Parameters:
  ///   - sx: The factor by which to scale the x-axis of the coordinate system.
  ///   - sy: The factor by which to scale the y-axis of the coordinate system.
  @inlinable
  public init(scaleX sx: Float, y sy: Float) {
    self.init(scaleX:     sx, shearY:     0,
              shearX:     0,  scaleY:     sy,
              translateX: 0,  translateY: 0)
  }

  /// Returns an affine transformation matrix constructed from translation
  /// values you provide.
  ///
  /// This function creates a `PDFAffineTransform2D` structure, which you can
  /// use (and reuse, if you want) to move a coordinate system. The matrix
  /// takes the following form:
  /// ```
  /// / 1  0  0 \
  /// | 0  1  0 |
  /// \ translateX translateY 1 /
  /// ```
  ///
  /// These are the resulting equations used to apply the translation to
  /// a point `(x,y)`:
  /// ```
  /// x’ = x + translateX
  /// y’ = y + translateY
  /// ```
  ///
  /// - Parameters:
  ///   - translateX: The value by which to move the x-axis of the coordinate
  ///                 system.
  ///   - translateY: The value by which to move the y-axis of the coordinate
  ///                 system.
  @inlinable
  public init(translationX tx: Float, y ty: Float) {
    self.init(scaleX:     1,  shearY:     0,
              shearX:     0,  scaleY:     1,
              translateX: tx, translateY: ty)
  }

  /// Checks whether an affine transform is the identity transform.
  @inlinable
  public var isIdentity: Bool {
    return self == .identity
  }

  /// The identity transform:
  ///
  /// ```
  /// / 1 0 0 \
  /// | 0 1 0 |
  /// \ 0 0 1 /
  /// ```
  public static let identity =
    PDFAffineTransform2D(scaleX:     1, shearY:     0,
                         shearX:     0, scaleY:     1,
                         translateX: 0, translateY: 0)

  /// The x-scaling factor of this matrix. This is calculated from the scale
  /// and shear.
  public var scalingFactorX: Float {
    if shearX != 0 || shearY != 0 {
      return (scaleX * scaleX + shearY * shearY).squareRoot()
    } else {
      return scaleX
    }
  }

  /// The y-scaling factor of this matrix. This is calculated from the scale
  /// and shear.
  public var scalingFactorY: Float {
    if shearX != 0 || shearY != 0 {
      return (scaleY * scaleY + shearX * shearX).squareRoot()
    } else {
      return scaleY
    }
  }

  /// Returns an affine transformation matrix constructed by combining two
  /// existing affine transforms.
  ///
  /// Concatenation combines two affine transformation matrices by multiplying
  /// them together.
  /// You might perform several concatenations in order to create a single
  /// affine transform that contains the cumulative effects of several
  /// transformations.
  ///
  /// Note that matrix operations are not commutative—the order in which you
  /// concatenate matrices is important.
  /// That is, the result of multiplying matrix `t1` by matrix `t2` does not
  /// necessarily equal the result of multiplying matrix `t2` by matrix `t1`.
  ///
  /// - Parameter other: The affine transform to concatenate to this affine
  ///                    transform.
  /// - Returns: A new affine transformation matrix. That is,
  ///            `t’ = self * other`.
  @inlinable
  public func concatenating(
    _ other: PDFAffineTransform2D
  ) -> PDFAffineTransform2D {
    return PDFAffineTransform2D(
      scaleX:  scaleX * other.scaleX + shearY * other.shearX,
      shearY:  scaleX * other.shearY + shearY * other.scaleY,
      shearX:  shearX * other.scaleX + scaleY * other.shearX,
      scaleY:  shearX * other.shearY + scaleY * other.scaleY,
      translateX: translateX * other.scaleX + translateY * other.shearX +
        other.translateX,
      translateY: translateX * other.shearY + translateY * other.scaleY +
        other.translateY
    )
  }

  /// Returns an affine transformation matrix constructed by inverting an
  /// existing affine transform.
  ///
  /// Inversion is generally used to provide reverse transformation of points
  /// within transformed objects.
  /// Given the coordinates `(x,y)`, which have been transformed by a given
  /// matrix to new coordinates `(x’,y’)`, transforming the coordinates
  /// `(x’,y’)` by the inverse matrix produces the original coordinates `(x,y)`.
  ///
  /// - Returns: A new affine transformation matrix.
  ///            If the affine transform cannot be inverted, returns `nil`.
  @inlinable
  public func inverted() -> PDFAffineTransform2D? {
    let det = determinant
    guard det != 0 else { return nil }
    return PDFAffineTransform2D(
      scaleX:  scaleY / det,
      shearY:  -shearY / det,
      shearX:  -shearX / det,
      scaleY:  scaleX / det,
      translateX: (-scaleY * translateX + shearX * translateY) / det,
      translateY: (shearY * translateX - scaleX * translateY) / det
    )
  }

  /// Returns an affine transformation matrix constructed by rotating `self`.
  ///
  /// You use this function to create a new affine transformation matrix by
  /// adding a rotation value to an existing affine transform. The resulting
  /// structure represents a new affine transform, which you can use (and reuse,
  /// if you want) to rotate a coordinate system.
  ///
  /// - Parameter angle: The angle, in radians, by which to rotate the affine
  ///                    transform.
  /// - Returns: A new affine transformation matrix.
  @inlinable
  public func rotated(byAngle angle: Float) -> PDFAffineTransform2D {
    return PDFAffineTransform2D(rotationAngle: angle).concatenating(self)
  }

  /// Returns an affine transformation matrix constructed by scaling `self`.
  ///
  /// You use this function to create a new affine transformation matrix by
  /// adding scaling values to an existing affine transform. The resulting
  /// structure represents a new affine transform, which you can use (and reuse,
  /// if you want) to scale a coordinate system.
  ///
  /// - Parameters:
  ///   - x: The value by which to scale x values of the affine transform.
  ///   - y: The value by which to scale y values of the affine transform.
  /// - Returns: A new affine transformation matrix.
  @inlinable
  public func scaled(byX x: Float, y: Float) -> PDFAffineTransform2D {
    return PDFAffineTransform2D(scaleX: x, y: y).concatenating(self)
  }

  /// Returns an affine transformation matrix constructed by translating
  /// an existing affine transform.
  ///
  /// You use this function to create a new affine transform by adding
  /// translation values to an existing affine transform. The resulting
  /// structure represents a new affine transform, which you can use (and reuse,
  /// if you want) to move a coordinate system.
  ///
  /// - Parameters:
  ///   - translateX: The value by which to move x values with the affine
  ///                 transform.
  ///   - ty: The value by which to move y values with the affine transform.
  /// - Returns: A new affine transformation matrix.
  @inlinable
  public func translated(byX tx: Float, y ty: Float) -> PDFAffineTransform2D {
    return PDFAffineTransform2D(translationX: tx, y: ty).concatenating(self)
  }

  /// Multiplies two matrices.
  ///
  /// This is analogous to calling `lhs.concatenating(rhs)`.
  ///
  /// Note that matrix operations are not commutative—the order in which you
  /// concatenate matrices is important.
  /// That is, the result of multiplying matrix `lhs` by matrix `rhs` does not
  /// necessarily equal the result of multiplying matrix `rhs` by matrix `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The left operand.
  ///   - rhs: The right operand.
  /// - Returns: A new affine transformation matrix.
  @inlinable
  public static func * (lhs: PDFAffineTransform2D,
                        rhs: PDFAffineTransform2D) -> PDFAffineTransform2D {
    return lhs.concatenating(rhs)
  }

  /// The determinant of this matrix, computed as `a * d - c * b`.
  @inlinable
  public var determinant: Float {
    return scaleX * scaleY - shearX * shearY
  }

  /// Whether `determinant` is zero.
  @inlinable
  public var isDegenerate: Bool {
    return determinant.isZero
  }
}

extension PDFAffineTransform2D: Decodable {
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    scaleX     = try container.decode(Float.self)
    shearY     = try container.decode(Float.self)
    shearX     = try container.decode(Float.self)
    scaleY     = try container.decode(Float.self)
    translateX = try container.decode(Float.self)
    translateY = try container.decode(Float.self)
  }
}

extension PDFAffineTransform2D: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(scaleX)
    try container.encode(shearY)
    try container.encode(shearX)
    try container.encode(scaleY)
    try container.encode(translateX)
    try container.encode(translateY)
  }
}

extension PDFAffineTransform2D: CustomDebugStringConvertible {

  public var debugDescription: String {
    return """
    [\(scaleX), \(shearY), \(shearX), \(scaleY), \(translateX), \(translateY)]
    """
  }
}

extension PDFAffineTransform2D: CustomStringConvertible {
  public var description: String {
    return debugDescription
  }
}
