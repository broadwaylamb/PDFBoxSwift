//
//  IOError.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 14/01/2019.
//

public enum IOError: Error {
  case readingError
  case writingError
  case markResetNotSupported
  case scratchFileClosed
  case bufferClosed
  case unexpectedEOF
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
    }
  }
}
