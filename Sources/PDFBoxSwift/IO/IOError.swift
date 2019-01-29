//
//  IOError.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 14/01/2019.
//

public enum IOError: Error, Hashable {
  case readingError
  case writingError
  case markResetNotSupported
  case scratchFileClosed
  case bufferClosed
  case unexpectedEOF
  case scratchFileDirectoryNotFound(path: String)
  case missingFileSystem
  case scratchFileMemoryExceeded
  case streamClosed
  case unknownFilter(COSName)
  case missingCatalog
  case cannotWriteNewByteRange(byteRange: String, maxLength: UInt64)
  case cannotWriteSignature(expectedLength: Int, actualLength: Int)
  case missingSecurityHandler(filter: PDFEncryption.Filter?)
  case documentClosed
}

extension IOError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .readingError:
      return "Reading failed"
    case .writingError:
      return "Writing failed"
    case .markResetNotSupported:
      return "InputStream: mark/reset not supported"
    case .scratchFileClosed:
      return "Scratch file already closed"
    case .bufferClosed:
      return "Buffer already closed"
    case .unexpectedEOF:
      return "Unexpectedly reached end of file"
    case .scratchFileDirectoryNotFound(let path):
      return "Scratch file directory does not exist: \(path)"
    case .missingFileSystem:
      return "A FileSystem object must be provided"
    case .scratchFileMemoryExceeded:
      return "Maximum allowed scratch file memory exceeded."
    case .streamClosed:
      return """
      COSStream has been closed and cannot be read. \
      Perhaps its enclosing PDFDocument has been closed?
      """
    case .unknownFilter(let name):
      return "Invalid filter: \(name)"
    case .missingCatalog:
      return "Catalog cannot be found"
    case .cannotWriteNewByteRange(let byteRange,  let maxLength):
      return """
      Can't write new byte range '\(byteRange)', not enough space to fit in \
      length \(maxLength)"
      """
    case .cannotWriteSignature:
      return "Can't write signature, not enough space"
    case .missingSecurityHandler(let filter):
      let filterDesc = filter.map { $0.rawValue.name } ?? "<nil>"
      return "No security handler for filter \(filterDesc)"
    case .documentClosed:
      return "Cannot save a document which has been closed"
    }
  }
}
