//
//  String.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

extension String {

  internal init<Bytes: Sequence>(hexRepresentationOf: Bytes)
      where Bytes.Element == UInt8 {
    self.init(hexRepresentationOf.flatMap { String(decoding: $0.pdfBoxASCIIHex,
                                                   as: UTF8.self) })
  }

  internal func trimmingWhitespaces() -> Substring {

    func notWhitespace(_ character: Character) -> Bool {
      return unicodeScalars.first!.value > 0x20
    }

    guard let firstNonWSIndex = firstIndex(where: notWhitespace),
          let lastNonWSIndex = lastIndex(where: notWhitespace) else {
      return Substring()
    }

    return self[firstNonWSIndex...lastNonWSIndex]
  }

  internal init<Encoding: Unicode.Encoding>(hex: String,
                                            encodedAs encoding: Encoding.Type,
                                            endianness: Endianness = .host) {
    var buffer = [Encoding.CodeUnit]()
    let repaired = transcode(hex.utf16.makeIterator(),
                             from: UTF16.self,
                             to: encoding,
                             stoppingOnError: false,
                             into: { buffer.append($0.endian(endianness)) })
    assert(!repaired)
    self = buffer.withUnsafeBytes(String.init(hexRepresentationOf:))
  }

  internal init?(utf16ParsingBOM bytes: [UInt8]) {

    guard bytes.count >= 2 else {
      return nil
    }

    if bytes[0] == 0xFE && bytes[1] == 0xFF {
      // UTF-16BE
      self = bytes.dropFirst(2).withUnsafeBytes { raw in
        String(
          decoding: raw.bindMemory(to: UInt16.self)
            .lazy
            .map { $0.toHostEndiannes(from: .big) },
          as: UTF16.self
        )
      }
    } else if bytes[0] == 0xFF && bytes[1] == 0xFE {
      // UTF-16LE
      self = bytes.dropFirst(2).withUnsafeBytes { raw in
        String(
          decoding: raw.bindMemory(to: UInt16.self)
            .lazy
            .map { $0.toHostEndiannes(from: .little) },
          as: UTF16.self
        )
      }
    } else {
      return nil
    }
  }

  var utf16BigEndian: LazyMapCollection<String.UTF16View, UInt16> {
    return utf16.lazy.map { $0.bigEndian }
  }

  var utf16LittleEndian: LazyMapCollection<String.UTF16View, UInt16> {
    return utf16.lazy.map { $0.littleEndian }
  }
}
