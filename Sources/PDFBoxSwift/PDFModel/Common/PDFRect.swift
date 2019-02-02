//
//  PDFRect.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 30/01/2019.
//

/// A rectangle in a PDF document.
public struct PDFRect: Hashable {

  /// 8.5 x 11 inches
  public static let letter = PDFRect(origin: .zero, size: .letter)

  /// 8.5 x 14 inches
  public static let legal = PDFRect(origin: .zero, size: .legal)

  /// 841 x 1189 mm
  public static let a0 = PDFRect(origin: .zero, size: .a0)

  /// 594 x 841 mm
  public static let a1 = PDFRect(origin: .zero, size: .a1)

  /// 420 x 594 mm
  public static let a2 = PDFRect(origin: .zero, size: .a2)

  /// 297 x 420 mm
  public static let a3 = PDFRect(origin: .zero, size: .a3)

  /// 210 x 297 mm
  public static let a4 = PDFRect(origin: .zero, size: .a4)

  /// 148 x 210 mm
  public static let a5 = PDFRect(origin: .zero, size: .a5)

  /// 105 x 148 mm
  public static let a6 = PDFRect(origin: .zero, size: .a6)

  /// 250 x 353 mm
  public static let b4 = PDFRect(origin: .zero, size: .b4)

  /// 176 x 250 mm
  public static let b5 = PDFRect(origin: .zero, size: .b5)

  /// 7.25 x 10.5 inches
  public static let executive = PDFRect(origin: .zero, size: .executive)

  /// 4 x 6 inches
  public static let us4x6 = PDFRect(origin: .zero, size: .us4x6)

  /// 4 x 8 inches
  public static let us4x8 = PDFRect(origin: .zero, size: .us4x8)

  /// 5 x 7 inches
  public static let us5x7 = PDFRect(origin: .zero, size: .us5x7)

  /// 4.125 x 9.5 inches
  public static let envelope10 = PDFRect(origin: .zero, size: .envelope10)

  /// The rectangle whose origin and size are both zero.
  public static let zero = PDFRect(origin: .zero, size: .zero)

  /// A point that specifies the coordinates of the rectangle’s
  /// lower left corner.
  public var lowerLeft: PDFPoint2D

  /// A point that specifies the coordinates of the rectangle’s
  /// upper right corner.
  public var upperRight: PDFPoint2D

  /// Creates a rectangle with the specified origin and size.
  ///
  /// - Parameters:
  ///   - origin: A point that specifies the coordinates of
  ///             the rectangle’s origin.
  ///   - size:   A size that specifies the height and width of the rectangle.
  @inlinable
  public init(origin: PDFPoint2D, size: PDFSize) {
    lowerLeft = origin
    upperRight = PDFPoint2D(x: origin.x + size.width, y: origin.y + size.height)
  }

  /// Creates a rectangle with coordinates and dimensions specified as
  /// floating-point values.
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the origin.
  ///   - y: The y-coordinate of the origin.
  ///   - width: The width of a rectangle.
  ///   - height: The height of a rectangle.
  @inlinable
  public init(x: Float, y: Float, width: Float, height: Float) {
    self.init(origin: PDFPoint2D(x: x, y: y),
              size: PDFSize(width: width, height: height))
  }

  /// Creates a rectangle with coordinates and dimensions specified as
  /// integer values.
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the origin.
  ///   - y: The y-coordinate of the origin.
  ///   - width: The width of a rectangle.
  ///   - height: The height of a rectangle.
  @inlinable
  public init(x: Int, y: Int, width: Int, height: Int) {
    self.init(x: Float(x),
              y: Float(y),
              width: Float(width),
              height: Float(height))
  }

  /// A size that specifies the height and width of the rectangle.
  @inlinable
  public var size: PDFSize {
    return PDFSize(width:  upperRight.x - lowerLeft.x,
                   height: upperRight.y - lowerLeft.y)
  }

  /// The width of a rectangle.
  @inlinable
  public var width: Float {
    return size.width
  }

  /// The height of a rectangle.
  @inlinable
  public var height: Float {
    return size.height
  }

  /// The center point of the rectangle.
  @inlinable
  public var center: PDFPoint2D {
    return PDFPoint2D(x: (lowerLeft.x + upperRight.x) / 2,
                      y: (lowerLeft.y + upperRight.y) / 2)
  }

  /// The x-coordinate that establishes the center of a rectangle.
  @inlinable
  public var midX: Float {
    return center.x
  }

  /// The y-coordinate that establishes the center of the rectangle.
  @inlinable
  public var midY: Float {
    return center.y
  }
}

extension PDFRect: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(lowerLeft.x)
    try container.encode(lowerLeft.y)
    try container.encode(upperRight.x)
    try container.encode(upperRight.y)
  }
}

extension PDFRect: Decodable {
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    let x1 = try container.decode(Float.self)
    let y1 = try container.decode(Float.self)
    let x2 = try container.decode(Float.self)
    let y2 = try container.decode(Float.self)

    lowerLeft  = PDFPoint2D(x: min(x1, x2), y: min(y1, y2))
    upperRight = PDFPoint2D(x: max(x1, x2), y: max(y1, y2))
  }
}

extension PDFRect: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "[\(lowerLeft.x), \(lowerLeft.y), \(upperRight.x), \(upperRight.y)]"
  }
}

extension PDFRect: CustomStringConvertible {
  public var description: String {
    return debugDescription
  }
}
