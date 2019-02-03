//
//  COSInteger.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// This class represents an integer number in a PDF document.
public final class COSInteger: COSNumber, Decodable {

  /// The lowest integer to be kept in the `staticInts` array.
  private static let low: Int64 = -100

  /// The highest integer to be kept in the `staticInts` array.
  private static let high: Int64 = 256

  /// Static instances of all `COSInteger`s in the range from `low` to `high`.
  private static let staticInts = (low...high).map(COSInteger.init)

  /// Returns a `COSInteger` instance with the given value.
  ///
  /// - Parameter value: Integer value.
  /// - Returns: A `COSInteger` instance.
  public static func get<T: BinaryInteger>(_ value: T) -> COSInteger {
    let value = Int64(clamping: value)
    if (low...high).contains(value) {
      return staticInts[Int(value - low)]
    } else {
      return COSInteger(value: value)
    }
  }

  /// Constant for the number zero.
  public static let zero = get(0)

  /// Constant for the number one.
  public static let one = get(1)

  /// Constant for the number two.
  public static let two = get(2)

  /// Constant for the number three.
  public static let three = get(3)

  private let value: Int64

  private init(value: Int64) {
    self.value = value
  }

  public convenience init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    try self.init(_get: container.decode(Int64.self))
  }

  public override func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }

  public override func isEqual(_ other: COSBase) -> Bool {
    guard let other = other as? COSInteger else { return false }
    return other.intValue == self.intValue
  }

  public override func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }

  public override var floatValue: Float {
    return Float(value)
  }

  public override var doubleValue: Double {
    return Double(value)
  }

  public override var intValue: Int64 {
    return value
  }

  @discardableResult
  public override func accept(visitor: COSVisitorProtocol) throws -> Any? {
    return try visitor.visit(self)
  }

  /// This will write this object out to a PDF stream.
  ///
  /// - Parameter output: The stream to write to.
  /// - Throws: Any error the stream throws during writing.
  public func writePDF(_ output: OutputStream) throws {
    try output.write(number: value)
  }

  public override var debugDescription: String {
    return "COSInteger{\(value)}"
  }
}

/// https://forums.swift.org/t/allow-self-x-in-class-convenience-initializers
private protocol COSIntegerSelfAssignInInit {
  static func get<T: BinaryInteger>(_ value: T) -> Self
}

extension COSIntegerSelfAssignInInit {
  fileprivate init<T: BinaryInteger>(_get value: T) {
    self = Self.get(value)
  }
}

extension COSInteger: COSIntegerSelfAssignInInit {}
