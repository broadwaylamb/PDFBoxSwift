//
//  PDFSize.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 30/01/2019.
//

/// A structure that contains width and height values.
public struct PDFSize: Hashable {

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
