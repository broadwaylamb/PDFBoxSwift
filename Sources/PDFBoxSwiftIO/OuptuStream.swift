//
//  OuptuStream.swift
//  PDFBoxSwiftIO
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

public protocol OutputStream: AnyObject {
  func write<Bytes: Sequence>(bytes: Bytes) throws where Bytes.Element == UInt8
  func write(byte: UInt8) throws
}

extension OutputStream {
  public func writeUTF8(_ string: String) throws {
    try write(bytes: string.utf8)
  }

  public func writeAsHex(byte: UInt8) throws {
    try write(byte: 0x30 + (byte & 0xF0) >> 4)
    try write(byte: 0x30 + byte & 0x0F)
  }
}
