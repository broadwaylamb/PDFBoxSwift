//
//  Endianness.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

internal enum Endianness {
  case big
  case little

  static let host: Endianness = 1.bigEndian == 1 ? .big : .little
}

extension FixedWidthInteger {

  internal func toHostEndiannes(from endianness: Endianness) -> Self {
    return endianness == .host ? self : byteSwapped
  }

  internal func endian(_ endianness: Endianness) -> Self {
    switch endianness {
    case .big:
      return bigEndian
    case .little:
      return littleEndian
    }
  }
}
