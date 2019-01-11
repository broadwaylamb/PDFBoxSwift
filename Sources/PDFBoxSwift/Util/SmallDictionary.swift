//
//  SmallDictionary.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 11/01/2019.
//

/// Dictionary implementation with the smallest possible memory usage.
/// It should only be used for dictionaries with small number of items
/// (e.g. <30) since most operations have O(n) complexity. Thus it should be
/// used in cases with large number of dictionaries, each having only few items.
internal struct SmallDictionary<Key : Equatable, Value> {

  fileprivate struct KeyValuePair {
    var key: Key
    var value: Value
  }

  private var dictArr: [KeyValuePair] = []

  /// Creates an empty dictionary.
  init(minimumCapacity: Int = 0) {
    dictArr.reserveCapacity(minimumCapacity)
  }
}

extension SmallDictionary: ExpressibleByDictionaryLiteral {
  init(dictionaryLiteral elements: (Key, Value)...) {
    dictArr = elements.map(KeyValuePair.init)
  }
}

extension SmallDictionary where Key: Hashable {
  init(_ dictionary: [Key : Value]) {
    dictArr = dictionary.map(KeyValuePair.init)
  }
}

extension SmallDictionary.KeyValuePair: Equatable where Value: Equatable {}

extension SmallDictionary.KeyValuePair: Hashable
    where Key: Hashable, Value: Hashable {}

extension SmallDictionary: Equatable where Value: Equatable {}

extension SmallDictionary: Hashable where Key: Hashable, Value: Hashable {}

extension SmallDictionary: MutableCollection {

  struct Index: Equatable {
    fileprivate var arrIndex: Int
    init(_ i: Int) {
      arrIndex = i
    }
  }

  var startIndex: Index {
    return Index(dictArr.startIndex)
  }


  var endIndex: Index {
    return Index(dictArr.endIndex)
  }

  func index(after i: Index) -> Index {
    return Index(dictArr.index(after: i.arrIndex))
  }

  func formIndex(after i: inout Index) {
    dictArr.formIndex(after: &i.arrIndex)
  }

  func index(forKey key: Key) -> Index? {
    return dictArr
      .firstIndex { $0.key == key }
      .map(Index.init)
  }

  subscript(position: Index) -> Value {
    get {
      return dictArr[position.arrIndex].value
    }
    set {
      dictArr[position.arrIndex].value = newValue
    }
  }

  var count: Int {
    return dictArr.count
  }

  var isEmpty: Bool {
    return dictArr.isEmpty
  }
}

extension SmallDictionary {
  subscript(key: Key) -> Value? {
    get {
      return dictArr.first { $0.key == key }?.value
    }
    set {
      if let index = index(forKey: key) {
        if let newValue = newValue {
          self[index] = newValue
        } else {
          dictArr.remove(at: index.arrIndex)
        }
      } else if let newValue = newValue {
        dictArr.append(KeyValuePair(key: key, value: newValue))
      }
    }
  }
}

extension SmallDictionary.Index: Comparable {
  static func < (lhs: SmallDictionary.Index,
                 rhs: SmallDictionary.Index) -> Bool {
    return lhs.arrIndex < rhs.arrIndex
  }
}
