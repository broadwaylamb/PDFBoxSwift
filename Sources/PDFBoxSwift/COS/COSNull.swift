//
//  COSNull.swift
//  COS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// This class represents a null PDF object.
public final class COSNull: COSBase {

  private static let nullBytes: [UInt8] = Array("null".utf8)

  /// The one null object in the system.
  public static let null = COSNull()

  /// Constructor.
  private override init() {
    super.init()
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
