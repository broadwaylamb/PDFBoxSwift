//
//  BitSet.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 15/01/2019.
//

private typealias Word = UInt64

private let wordBitSize = MemoryLayout<Word>.size * 8
private let allOnesWord = Word.max

internal struct BitSet {

  private var storage: [Word] = [0]
  private var wordCount = 0

  init() {}

  private mutating func grow(to wordIndex: Int) {
    let newWordCount = wordIndex + 1

    guard newWordCount > wordCount else {
      return
    }

    if newWordCount > storage.count {
      let appendCount = max(2 * storage.count, newWordCount) - storage.count
      storage.append(contentsOf: repeatElement(0, count: appendCount))
    }

    wordCount = newWordCount
  }

  subscript(index: Int) -> Bool {
    get {
      precondition(index >= 0, "Index out of bounds")
      let storageIndex = index / wordBitSize
      guard storageIndex < wordCount else { return false }
      return (storage[storageIndex] & (Word(1) << (index % wordBitSize))) != 0
    }
    set {
      precondition(index >= 0, "Index out of bounds")
      let storageIndex = index / wordBitSize
      if newValue {
        grow(to: storageIndex)
        storage[storageIndex] |= Word(1) << (index % wordBitSize)
      } else {
        guard storageIndex < wordCount else { return }
        storage[storageIndex] &= ~(Word(1) << (index % wordBitSize))
        storage.lastIndex(where: { $0 != 0 }).map { wordCount = $0 + 1 }
      }
    }
  }

  mutating func clear() {
    for i in 0..<wordCount {
      storage[i] = 0
    }
    wordCount = 0
  }

  mutating func set(_ range: Range<Int>) {
    precondition(range.lowerBound >= 0, "Index out of bounds")

    guard !range.isEmpty else {
      return
    }

    let startStorageIndex = range.lowerBound / wordBitSize
    let endStorageIndex = (range.upperBound - 1) / wordBitSize
    grow(to: endStorageIndex)

    let firstWordMask = allOnesWord << (range.lowerBound % wordBitSize)
    let lastWordMask = ~(allOnesWord << (range.upperBound % wordBitSize))

    if startStorageIndex == endStorageIndex {
      storage[startStorageIndex] |= firstWordMask & lastWordMask
    } else {
      storage[startStorageIndex] |= firstWordMask
      storage[endStorageIndex] |= lastWordMask
      for i in startStorageIndex + 1 ..< endStorageIndex {
        storage[i] = allOnesWord
      }
    }
  }

  var count: Int {
    if wordCount == 0 { return 0 }
    return wordBitSize * wordCount - storage[wordCount - 1].leadingZeroBitCount
  }

  var isEmpty: Bool {
    return count == 0
  }
}
