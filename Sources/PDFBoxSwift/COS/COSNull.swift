//
//  COSNull.swift
//  COS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// This class represents a null PDF object.
public final class COSNull: COSBase, Decodable {

  private static let nullBytes: [UInt8] = Array("null".utf8)

  /// The one null object in the system.
  public static let null = COSNull()

  /// Constructor.
  private override init() {
    super.init()
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      self.init(_get: ())
    } else {
      let context = DecodingError.Context(
        codingPath: container.codingPath,
        debugDescription: "Could not decode \(type(of: self))"
      )
      throw DecodingError.typeMismatch(COSNull.self, context)
    }
  }

  public override func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encodeNil()
  }

  @discardableResult
  public override func accept(visitor: COSVisitorProtocol) throws -> Any?  {
    return try visitor.visit(self)
  }

  /// This will output "null" as a PDF object.
  ///
  /// - Parameter output: The stream to write to.
  /// - Throws: Any error the stream throws during writing.
  public func writePDF(_ output: OutputStream) throws {
    try output.write(bytes: COSNull.nullBytes)
  }

  public override var debugDescription: String {
    return "COSNull{}"
  }
}

/// https://forums.swift.org/t/allow-self-x-in-class-convenience-initializers
private protocol COSNullSelfAssignInInit {
  static var null: Self { get }
}

extension COSNullSelfAssignInInit {
  fileprivate init(_get: ()) {
    self = .null
  }
}

extension COSNull: COSNullSelfAssignInInit {}
