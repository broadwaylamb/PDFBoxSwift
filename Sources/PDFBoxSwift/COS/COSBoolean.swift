//
//  COSBoolean.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// This class represents a boolean value in the PDF document.
public final class COSBoolean: COSBase, Decodable {

  /// The "true" boolean token.
  private static let trueBytes: [UInt8] = Array("true".utf8)

  /// The "false" boolean token.
  private static let falseBytes: [UInt8] = Array("false".utf8)

  /// The PDF "true" value.
  public static let `true` = COSBoolean(value: true)

  /// The PDF "false" value.
  public static let `false` = COSBoolean(value: false)

  /// The value that this object wraps.
  public let value: Bool

  private init(value: Bool) {
    self.value = value
    super.init()
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    try self.init(_get: container.decode(Bool.self))
  }

  public override func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }

  /// This will get the boolean value.
  ///
  /// - Parameter value: Which boolean value to get.
  /// - Returns: The single boolean instance that matches the parameter.
  public static func get(_ value: Bool) -> COSBoolean {
    return value ? .true : .false
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
    if value {
      try output.write(bytes: COSBoolean.trueBytes)
    } else {
      try output.write(bytes: COSBoolean.falseBytes )
    }
  }

  public override var debugDescription: String {
    return value.description
  }
}

/// https://forums.swift.org/t/allow-self-x-in-class-convenience-initializers
private protocol COSBooleanSelfAssignInInit {
  static func get(_ value: Bool) -> Self
}

extension COSBooleanSelfAssignInInit {
  fileprivate init(_get value: Bool) {
    self = Self.get(value)
  }
}

extension COSBoolean: COSBooleanSelfAssignInInit {}
