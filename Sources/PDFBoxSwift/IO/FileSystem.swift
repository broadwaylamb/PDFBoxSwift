//
//  FileSystem.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 15/01/2019.
//

/// A protocol for abstracting away file system representations.
///
/// On POSIX systems this protocol is implemented by the `POSIXFileSystem`
/// class. You can conform your custom class to this protocol if you want
/// to customize the behaviour or if you want to support file system operations
/// on a non-POSIX system.
public protocol FileSystem: AnyObject {

  /// Tells whether the given `path` represents a directory.
  ///
  /// - Parameter path: The path to test.
  /// - Returns: `true` if the given `path` represents a directory,
  ///             otherwise `false`.
  func isDirectory(_ path: String) throws -> Bool

  /// The platform-specific location of the temporary directory.
  var temporaryDirectory: String { get }

  /// Creates a temporary file in `directory` with the specified `prefix`
  /// and `suffix`.
  ///
  /// A new file must be created if and only if the method doesn't throw.
  ///
  /// - Parameters:
  ///   - prefix: The prefix of the new temporary file.
  ///   - suffix: The suffix of the new temporary file.
  ///   - directory: The directory where a new file will be created.
  /// - Returns: A stream object associated with the created temporary file.
  func createTemporaryFile(prefix: String,
                           suffix: String,
                           directory: String) throws -> RandomAccessFile

  /// Deletes a file or a directory at the given `path`.
  ///
  /// - Parameter path: The path of the file to delete.
  func deleteFile(path: String) throws
}

extension FileSystem {

  /// Creates a temporary file in `directory` with the specified `prefix`
  /// and `suffix`.
  ///
  /// A new file must be created if and only if the method doesn't throw.
  ///
  /// - Parameters:
  ///   - prefix: The prefix of the new temporary file.
  ///   - directory: The directory where a new file will be created.
  /// - Returns: A stream associated with the created temporary file.
  func createTemporaryFile(prefix: String,
                           directory: String) throws -> RandomAccessFile {
    return try createTemporaryFile(prefix: prefix,
                                   suffix: ".tmp",
                                   directory: directory)
  }
}
