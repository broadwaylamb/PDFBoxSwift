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

  struct KeyValuePair {
    var key: Key
    var value: Value
  }

  private var dictArr: ContiguousArray<KeyValuePair> = []

  /// Creates an empty dictionary.
  init(minimumCapacity: Int = 0) {
    dictArr.reserveCapacity(minimumCapacity)
  }
}

extension SmallDictionary: ExpressibleByDictionaryLiteral {
  init(dictionaryLiteral elements: (Key, Value)...) {
    dictArr.reserveCapacity(elements.count)
    for (key, value) in elements {
      dictArr.append(KeyValuePair(key: key, value: value))
    }
  }
}

extension SmallDictionary where Key: Hashable {
  init(_ dictionary: [Key : Value]) {
    dictArr.reserveCapacity(dictionary.count)
    for (key, value) in dictionary {
      dictArr.append(KeyValuePair(key: key, value: value))
    }
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
    fileprivate init(_ i: Int) {
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

  subscript(position: Index) -> KeyValuePair {
    get {
      return dictArr[position.arrIndex]
    }
    set {
      dictArr[position.arrIndex] = newValue
    }
  }

  var count: Int {
    return dictArr.count
  }

  var isEmpty: Bool {
    return dictArr.isEmpty
  }
}

extension SmallDictionary: BidirectionalCollection {

  func index(before i: Index) -> Index {
    return Index(dictArr.index(before: i.arrIndex))
  }

  func formIndex(before i: inout Index) {
    dictArr.formIndex(before: &i.arrIndex)
  }

  func distance(from start: Index, to end: Index) -> Int {
    return dictArr.distance(from: start.arrIndex, to: end.arrIndex)
  }

  func index(_ i: Index, offsetBy distance: Int) -> Index {
    return Index(dictArr.index(i.arrIndex, offsetBy: distance))
  }

  func index(_ i: Index,
             offsetBy distance: Int,
             limitedBy limit: Index) -> Index? {
    return dictArr
      .index(i.arrIndex, offsetBy: distance, limitedBy: limit.arrIndex)
      .map(Index.init)
  }
}

extension SmallDictionary {

  /// Accesses the value associated with the given key for reading and writing.
  ///
  /// This *key-based* subscript returns the value for the given key if the key
  /// is found in the dictionary, or `nil` if the key is not found.
  ///
  /// When you assign a value for a key and that key already exists, the
  /// dictionary overwrites the existing value. If the dictionary doesn't
  /// contain the key, the key and value are added as a new key-value pair.
  ///
  /// If you assign `nil` as the value for the given key, the dictionary
  /// removes that key and its associated value.
  ///
  /// - Parameter key: The key to find in the dictionary.
  /// - Returns: The value associated with `key` if `key` is in the dictionary;
  ///   otherwise, `nil`.
  subscript(key: Key) -> Value? {
    get {
      return dictArr.first { $0.key == key }?.value
    }
    set {
      if let index = index(forKey: key) {
        if let newValue = newValue {
          self[index].value = newValue
        } else {
          dictArr.remove(at: index.arrIndex)
        }
      } else if let newValue = newValue {
        dictArr.append(KeyValuePair(key: key, value: newValue))
      }
    }
  }

  /// Removes and returns the element at the specified position.
  ///
  /// - Parameter index: The position of the element to remove.
  /// - Returns: The element at the specified index.
  ///
  /// - Complexity: O(*n*), where *n* is the number of key-value pairs in the
  ///   dictionary.
  @discardableResult
  mutating func remove(at index: Index) -> KeyValuePair {
    return dictArr.remove(at: index.arrIndex)
  }

  /// Removes the given key and its associated value from the dictionary.
  ///
  /// If the key is found in the dictionary, this method returns the key's
  /// associated value. If the key isn't found in the dictionary,
  /// `removeValue(forKey:)` returns `nil`.
  ///
  /// - Parameter key: The key to remove along with its associated value.
  /// - Returns: The value that was removed, or `nil` if the key was not
  ///   present in the dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the number of key-value pairs in the
  ///   dictionary.
  mutating func removeValue(forKey key: Key) -> Value? {
    let value = self[key]
    self[key] = nil
    return value
  }

  /// Removes all key-value pairs from the dictionary.
  ///
  /// - Parameter keepCapacity: Whether the dictionary should keep its
  ///   underlying buffer. If you pass `true`, the operation preserves the
  ///   buffer capacity that the collection has, otherwise the underlying
  ///   buffer is released.  The default is `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the number of key-value pairs in the
  ///   dictionary.
  mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    dictArr.removeAll(keepingCapacity: keepCapacity)
  }

  typealias Keys = AnyBidirectionalCollection<Key>

  var keys: Keys {
    return Keys(dictArr.lazy.map { $0.key })
  }

  typealias Values = AnyBidirectionalCollection<Value>

  var values: Values {
    return Values(dictArr.lazy.map { $0.value })
  }
}

extension SmallDictionary.Index: Comparable {
  static func < (lhs: SmallDictionary.Index,
                 rhs: SmallDictionary.Index) -> Bool {
    return lhs.arrIndex < rhs.arrIndex
  }
}
