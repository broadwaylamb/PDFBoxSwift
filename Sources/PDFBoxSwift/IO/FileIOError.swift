//
//  FileIOError.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 14/01/2019.
//

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

#if canImport(Darwin) || canImport(Glibc)

/// An `Error` for a file IO operation.
///
/// (The implementation is taken from the SwiftNIO open source project.)
public struct FileIOError: Error {

  public enum FailureDescription {
    case function(StaticString)
    case reason(String)
  }
  /// The `errno` that was set for the operation.
  public let errnoCode: CInt

  /// The actual reason (in a human-readable form) for this `FileIOError`.
  public let reason: FailureDescription

  /// Creates a new `FileIOError`
  ///
  /// - Note: At the moment, this constructor is more expensive than
  ///         `FileIOError(errnoCode:function:)` as the `String` will incur
  ///         reference counting
  ///
  /// - Parameters:
  ///   - errorCode: The `errno` that was set for the operation.
  ///   - reason: The actual reason (in a human-readable form).
  public init(errnoCode: CInt, reason: String) {
    self.errnoCode = errnoCode
    self.reason = .reason(reason)
  }

  /// Creates a new `IOError``
  ///
  /// - Note: This constructor is the cheapest way to create a `FileIOError`.
  ///
  /// - Parameters:
  ///   - errorCode: The `errno` that was set for the operation.
  ///   - function: The function the error happened in, the human readable
  ///               description will be generated automatically when needed.
  public init(errnoCode: CInt, function: StaticString) {
    self.errnoCode = errnoCode
    self.reason = .function(function)
  }
}

/// Returns a reason to use when constructing a `FileIOError`.
///
/// - Parameters:
///   - errorCode: The `errno` that was set for the operation.
///   - reason: What failed.
/// - Returns: The constructed reason.
private func reasonForError(errnoCode: CInt, reason: String) -> String {
  if let errorDescC = strerror(errnoCode) {
    return "\(reason): \(String(cString: errorDescC)) (errno: \(errnoCode))"
  } else {
    return "\(reason): Broken strerror, unknown error: \(errnoCode)"
  }
}

extension FileIOError: CustomStringConvertible {
  public var description: String {
    switch reason {
    case .reason(let reason):
      return reasonForError(errnoCode: self.errnoCode,
                            reason: reason)
    case .function(let function):
      return reasonForError(errnoCode: self.errnoCode,
                            reason: "\(function) failed")
    }
  }
}

#endif
