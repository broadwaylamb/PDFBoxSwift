//
//  COSBoolean.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

import PDFBoxSwiftIO

/// This class represents a boolean value in the PDF document.
public final class COSBoolean: COSBase {

  /// The PDF "true" value.
  public static let `true` = COSBoolean(value: true)

  /// The PDF "false" value.
  public static let `false` = COSBoolean(value: false)

  /// The value that this object wraps.
  public let value: Bool

  private init(value: Bool) {
    self.value = value
  }

  /// This will get the boolean value.
  ///
  /// - Parameter value: Which boolean value to get.
  /// - Returns: The single boolean instance that matches the parameter.
  public static func get(_ value: Bool) -> COSBoolean {
    return value ? .true : .false
  }

  public override func accept(visitor: COSVisitorProtocol) throws -> Any? {
    return try visitor.visit(self)
  }

  /// This will write this object out to a PDF stream.
  ///
  /// - Parameter output: The stream to write to.
  /// - Throws: Any error the stream throws during writing.
  public func writePDF(_ output: OutputStream) throws {
    if value {
      try output.writeUTF8("true")
    } else {
      try output.writeUTF8("false")
    }
  }
}

extension COSBoolean: CustomDebugStringConvertible {
  public var debugDescription: String {
    return value.description
  }
}
