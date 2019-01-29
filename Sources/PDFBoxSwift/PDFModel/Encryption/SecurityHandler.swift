//
//  SecurityHandler.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 29/01/2019.
//

/// A security handler as described in the PDF specifications. A security
/// handler is responsible of documents protection.
public class SecurityHandler {

  internal static func requiresConcreteImplementation(
    _ fn: String = #function,
    file: StaticString = #file,
    line: UInt = #line
    ) -> Never {
    fatalError("\(fn) must be overriden in subclass implementations",
      file: file,
      line: line)
  }

  /// Prepare the document for encryption.
  ///
  /// - Parameter document: The document that will be encrypted.
  public func prepareDocumentForEncryption(_ document: PDFDocument) throws {
    SecurityHandler.requiresConcreteImplementation()
  }

  /// Whether a protection policy has been set.
  public var hasProtectionPolicy: Bool {
    SecurityHandler.requiresConcreteImplementation()
  }
}
