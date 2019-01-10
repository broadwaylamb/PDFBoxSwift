//
//  Hex.swift
//  PDFBoxSwiftIO
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

extension FixedWidthInteger where Self: UnsignedInteger {
  public var pdfBoxASCIIHex: [UInt8] {
    let quadruples = stride(from: Self.bitWidth - 4, through: 0, by: -4)
      .lazy
      .map { (self & (0b1111 << $0)) >> $0 }
      .map(UInt8.init)
    return quadruples.map { $0 < 10 ? 0x30 + $0 : 0x37 + $0 }
  }
}
