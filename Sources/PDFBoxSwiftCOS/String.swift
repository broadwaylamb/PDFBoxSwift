//
//  String.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

extension String {
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
}
