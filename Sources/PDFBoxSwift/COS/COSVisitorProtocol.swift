//
//  COSVisitorProtocol.swift
//  COS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

@available(*, deprecated, renamed: "COSVisitorProtocol")
public typealias ICOSVisitor = COSVisitorProtocol

/// An interface for visiting a PDF document at the type (COS) level.
public protocol COSVisitorProtocol {

  /// Notification of visit to array object.
  ///
  /// - Parameter array: The array that is being visited.
  /// - Returns: Any value depending on the visitor implementation, or `nil`
  func visit(_ array: COSArray) throws -> Any?

  /// Notification of visit to boolean object.
  ///
  /// - Parameter bool: The boolean object that is being visited.
  /// - Returns: Any value depending on the visitor implementation, or `nil`
  func visit(_ bool: COSBoolean) throws -> Any?

  /// Notification of visit to dictionary object.
  ///
  /// - Parameter dictionary: The dictionary object that is being visited.
  /// - Returns: Any value depending on the visitor implementation, or `nil`
  func visit(_ dictionary: COSDictionary) throws -> Any?

  /// Notification of visit to float object.
  ///
  /// - Parameter float: The float object that is being visited.
  /// - Returns: Any value depending on the visitor implementation, or `nil`
  func visit(_ float: COSFloat) throws -> Any?

  /// Notification of visit to integer object.
  ///
  /// - Parameter int: The integer object that is being visited.
  /// - Returns: Any value depending on the visitor implementation, or `nil`
  func visit(_ int: COSInteger) throws -> Any?

  /// Notification of visit to name object.
  ///
  /// - Parameter name: The name object that is being visited.
  /// - Returns: Any value depending on the visitor implementation, or `nil`
  func visit(_ name: COSName) throws -> Any?

  /// Notification of visit to null object.
  ///
  /// - Parameter null: The object that is being visited.
  /// - Returns: Any value depending on the visitor implementation, or `nil`
  func visit(_ null: COSNull) throws -> Any?

  /// Notification of visit to string object.
  ///
  /// - Parameter string: The object that is being visited.
  /// - Returns: Any value depending on the visitor implementation, or `nil`
  func visit(_ string: COSString) throws -> Any?
}
