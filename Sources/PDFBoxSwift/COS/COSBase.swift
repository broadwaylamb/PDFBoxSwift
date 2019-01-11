//
//  COSBase.swift
//  COS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// The base object that all objects in the PDF document will extend.
public class COSBase: COSObjectable, Hashable {

  /// If the state is `true`, the dictionary will be written direct
  /// into the called object.
  /// This means, no indirect object will be created.
  public var isDirect: Bool = false

  /// Constructor.
  internal init() {}

  /// /// Convert this object to a COS object.
  public var cosObject: COSBase {
    return self
  }

  /// Visitor pattern double dispatch method.
  ///
  /// - Parameter visitor: The object to notify when visiting this object.
  /// - Returns: Any object, depending on the visitor implementation, or `nil`.
  @discardableResult
  public func accept(visitor: COSVisitorProtocol) throws -> Any? {
    COSBase.requiresConcreteImplementation()
  }

  /// Returns a `Bool` value that indicates whether `self` is equal to
  /// another given object.
  ///
  /// - Parameter other: The object with which to compare `self`.
  /// - Returns: `true` if `self` is equal to `other`, otherwise `false`.
  public func isEqual(_ other: COSBase) -> Bool {
    return self === other
  }

  public static func == (lhs: COSBase, rhs: COSBase) -> Bool {
    return lhs.isEqual(rhs)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  internal static func requiresConcreteImplementation(
    _ fn: String = #function,
    file: StaticString = #file,
    line: UInt = #line
  ) -> Never {
    fatalError("\(fn) must be overriden in subclass implementations",
               file: file,
               line: line)
  }
}
