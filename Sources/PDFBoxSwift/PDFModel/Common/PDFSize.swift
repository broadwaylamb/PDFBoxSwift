//
//  PDFSize.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 30/01/2019.
//

/// A structure that contains width and height values.
public struct PDFSize: Hashable {

  private static let pointsPerInch: Float = 72

  private static let pointsPerMM = 1 / 25.4 * pointsPerInch

  /// 8.5 x 11 inches
  public static let letter = PDFSize(width: 8.5 * pointsPerInch,
                                     height: 11 * pointsPerInch)

  /// 8.5 x 14 inches
  public static let legal = PDFSize(width: 8.5 * pointsPerInch,
                                    height: 14 * pointsPerInch)

  /// 841 x 1189 mm
  public static let a0 = PDFSize(width:  841  * pointsPerMM,
                                 height: 1189 * pointsPerMM)

  /// 594 x 841 mm
  public static let a1 = PDFSize(width:  594 * pointsPerMM,
                                 height: 841 * pointsPerMM)

  /// 420 x 594 mm
  public static let a2 = PDFSize(width:  420 * pointsPerMM,
                                 height: 594 * pointsPerMM)

  /// 297 x 420 mm
  public static let a3 = PDFSize(width:  297 * pointsPerMM,
                                 height: 420 * pointsPerMM)

  /// 210 x 297 mm
  public static let a4 = PDFSize(width:  210 * pointsPerMM,
                                 height: 297 * pointsPerMM)

  /// 148 x 210 mm
  public static let a5 = PDFSize(width:  148 * pointsPerMM,
                                 height: 210 * pointsPerMM)

  /// 105 x 148 mm
  public static let a6 = PDFSize(width:  105 * pointsPerMM,
                                 height: 148 * pointsPerMM)

  /// 250 x 353 mm
  public static let b4 = PDFSize(width:  250 * pointsPerMM,
                                 height: 353 * pointsPerMM)

  /// 176 x 250 mm
  public static let b5 = PDFSize(width:  176 * pointsPerMM,
                                 height: 250 * pointsPerMM)

  /// 7.25 x 10.5 inches
  public static let executive = PDFSize(width:  7.25 * pointsPerInch,
                                        height: 10.5 * pointsPerInch)

  /// 4 x 6 inches
  public static let us4x6 = PDFSize(width:  4 * pointsPerInch,
                                    height: 6 * pointsPerInch)

  /// 4 x 8 inches
  public static let us4x8 = PDFSize(width:  4 * pointsPerInch,
                                    height: 8 * pointsPerInch)

  /// 5 x 7 inches
  public static let us5x7 = PDFSize(width:  5 * pointsPerInch,
                                    height: 7 * pointsPerInch)

  /// 4.125 x 9.5 inches
  public static let envelope10 = PDFSize(width:  4.125 * pointsPerInch,
                                         height: 9.5   * pointsPerInch)

  /// The size whose width and height are both zero.
  public static let zero = PDFSize(width: 0, height: 0)

  /// A width value.
  public var width: Float

  /// A height value.
  public var height: Float

  /// Creates a size with dimensions specified as floating-point values.
  ///
  /// - Parameters:
  ///   - width: A width value.
  ///   - height: A height value.
  @inlinable
  public init(width: Float, height: Float) {
    self.width = width
    self.height = height
  }

  /// Creates a size with dimensions specified as integer values.
  ///
  /// - Parameters:
  ///   - width: A width value.
  ///   - height: A height value.
  @inlinable
  public init(width: Int, height: Int) {
    self.init(width: Float(width), height: Float(height))
  }

  /// Returns the height and width resulting from a transformation of
  /// an existing height and width.
  ///
  /// - Parameter transform: The affine transform to apply.
  /// - Returns: A new size resulting from applying the specified affine
  ///            transform to the existing size.
  @inlinable
  public func applying(_ transform: PDFAffineTransform2D) -> PDFSize {
    return PDFSize(width:  transform.scaleX * width + transform.shearX * height,
                   height: transform.shearY * width + transform.scaleY * height)
  }
}

extension PDFSize: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "(\(width), \(height))"
  }
}

extension PDFSize: CustomStringConvertible {
  public var description: String {
    return debugDescription
  }
}
