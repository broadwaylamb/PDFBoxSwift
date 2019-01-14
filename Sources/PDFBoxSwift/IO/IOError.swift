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
    }
  }
}
