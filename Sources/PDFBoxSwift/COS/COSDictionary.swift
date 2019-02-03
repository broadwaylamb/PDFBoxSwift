//
//  COSDictionary.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 11/01/2019.
//

/// This class represents a dictionary where name/value pairs reside.
public class COSDictionary: COSBase, COSUpdateInfo {

  private static let pathSeparator = "/"

  public var needsToBeUpdated: Bool = false

  internal var items = SmallDictionary<COSName, COSBase>()

  public override init() {
    super.init()
  }

  /// Copy Constructor. This will make a shallow copy of this dictionary.
  ///
  /// - Parameter dict: The dictionary to copy.
  public init(_ dict: COSDictionary) {
    items = dict.items
  }

  private struct CodingKeys: COSCodingKey {
    let nameValue: COSName
    init(nameValue: COSName) {
      self.nameValue = nameValue
    }
  }

  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    for (key, value) in self {
      try container.encode(value, forKey: CodingKeys(nameValue: key))
    }
  }

  /// Returns a Boolean value indicating whether the dictionary contains
  /// the given value. This will dereference a `COSObject`.
  ///
  /// - Parameter value: The value to find in the dictionary.
  /// - Returns: `true` if the value was found in the dictionary;
  ///             otherwise, `false`.
  public func contains(_ value: COSBase) -> Bool {
    let contains = items.contains { $0.value == value }
    if !contains, let value = value as? COSObject {
      return items.contains { $0.value == value.object }
    } else {
      return contains
    }
  }

  /// Search in the dictionary for the value that matches the argument
  /// and return the first key that maps to that value.
  ///
  /// - Parameter value: The value to search for in the dictionary.
  /// - Returns: The key for the value in the dictionary, or `nil`
  ///            if it does not exist.
  public func key(forValue value: COSBase) -> COSName? {
    return items.first { keyValuePair in
      if keyValuePair.value == value {
        return true
      }
      if let candidate = keyValuePair.value as? COSObject,
         candidate.object == value {
        return true
      }
      return false
    }?.key
  }

  /// The collection of keys of the dictionary,
  public typealias Keys = AnyBidirectionalCollection<COSName>

  /// The names of the entries in this dictionary. The returned collection is in
  /// the order the entries were added to the dictionary.
  public var keys: Keys {
    return Keys(items.keys)
  }

  /// The collection of values of the dictionary,
  public typealias Values = AnyBidirectionalCollection<COSBase>

  /// The values of the dictionary.
  public var values: Values {
    return Values(items.values)
  }

  @discardableResult
  public override func accept(visitor: COSVisitorProtocol) throws -> Any? {
    return try visitor.visit(self)
  }

  public override var debugDescription: String {
    var string = "COSDictionary{"
    for (key, value) in self {
      string.append(key.description)
      string.append(":")
      string.append(value.description)
      string.append(";")
    }
    string.append("}")
    return string
  }
}

extension COSDictionary: MutableCollection {

  public typealias Element = (key: COSName, value: COSBase)

  public struct Index: Equatable {
    fileprivate var wrapped: SmallDictionary<COSName, COSBase>.Index
    fileprivate init(_ wrapped: SmallDictionary<COSName, COSBase>.Index) {
      self.wrapped = wrapped
    }
  }

  public var startIndex: Index {
    return Index(items.startIndex)
  }

  public var endIndex: Index {
    return Index(items.endIndex)
  }

  public func index(after i: Index) -> Index {
    return Index(items.index(after: i.wrapped))
  }

  public func formIndex(after i: inout Index) {
    items.formIndex(after: &i.wrapped)
  }

  public subscript(position: Index) -> Element {
    get {
      let pair = items[position.wrapped]
      return (pair.key, pair.value)
    }
    set {
      items[position.wrapped] =
        SmallDictionary.KeyValuePair(key: newValue.key, value: newValue.value)
    }
  }

  public var count: Int {
    return items.count
  }

  public var isEmpty: Bool {
    return items.isEmpty
  }
}

extension COSDictionary: BidirectionalCollection {

  public func index(before i: Index) -> Index {
    return Index(items.index(before: i.wrapped))
  }

  public func formIndex(before i: inout Index) {
    items.formIndex(before: &i.wrapped)
  }

  public func distance(from start: Index, to end: Index) -> Int {
    return items.distance(from: start.wrapped, to: end.wrapped)
  }

  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    return Index(items.index(i.wrapped, offsetBy: distance))
  }

  public func index(_ i: Index,
                    offsetBy distance: Int,
                    limitedBy limit: Index) -> Index? {
    return items
      .index(i.wrapped, offsetBy: distance, limitedBy: limit.wrapped)
      .map(Index.init)
  }
}

extension COSDictionary {

  /// This will get an object from this dictionary. If the object is
  /// a reference then it will dereference it and get it from the document.
  /// If the object is `COSNull` then `nil` will be returned.
  ///
  /// - Parameter key: The key to the object that we are getting.
  /// - Returns: The object that matches the key.
  public subscript(key: COSName) -> COSBase? {
    get {
      let object = items[key]
      switch object {
      case let ref as COSObject:
        return ref.object
      case is COSNull:
        return nil
      default:
        return object
      }
    }
    set {
      items[key] = newValue
    }
  }

  /// This is a special case of subscript that takes two keys,
  /// it will handle the situation where multiple keys could get the same value,
  /// ie if either "CS" or "ColorSpace" is used to get the colorspace.
  /// This will get an object from this dictionary. If the object is
  /// a reference then it will dereference it and get it from the document.
  /// If the object is `COSNull` then `nil` will be returned.
  ///
  /// - Parameters:
  ///   - firstKey: The first key to try.
  ///   - secondKey: The second key to try.
  /// - Returns: The object that matches the key.
  public subscript(firstKey: COSName, secondKey: COSName) -> COSBase? {
    return self[firstKey] ?? self[secondKey]
  }

  /// This will get an object from this dictionary. If the object is
  /// a reference then it will dereference it and get it from the document.
  /// If the object is `COSNull` then `nil` will be returned.
  ///
  /// - Parameter key: The key to the object that we are getting.
  /// - Returns: The object that matches the key.
  public subscript(key: String) -> COSBase? {
    return self[COSName.getPDFName(key)]
  }

  /// Removes and returns the element at the specified position.
  ///
  /// - Parameter index: The position of the element to remove.
  /// - Returns: The element at the specified index.
  ///
  /// - Complexity: O(*n*), where *n* is the number of key-value pairs in the
  ///   dictionary.
  @discardableResult
  public func remove(at index: Index) -> Element {
    let removed = items.remove(at: index.wrapped)
    return (removed.key, removed.value)
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
  public func removeValue(forKey key: COSName) -> COSBase? {
    return items.removeValue(forKey: key)
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
  public func removeAll(keepingCapacity keepCapacity: Bool = false) {
    items.removeAll(keepingCapacity: keepCapacity)
  }

  /// This will add all of the dictionaries keys/values to this dictionary.
  /// Only called when adding keys to a trailer that already exists.
  ///
  /// - Parameter other: other descriptionThe dictionary to get the keys from.
  public func merge(_ other: COSDictionary) {

    let selfContainsSize = items.contains(where: { $0.key == .size })

    // TODO: This has complexity O(n*m) since the subscript is O(n).
    // This can work in O(n+m).

    for (key, value) in other where key != .size || !selfContainsSize {
      // If we're at a second trailer, we have a linearized pdf file,
      // meaning that the first Size entry represents all of the objects
      // so we don't need to grab the second.

      self[key] = value
    }
  }
}

// MARK: - Typed subscripts
extension COSDictionary {

  /// This will get an object from this dictionary as a COS object.
  /// If the object is a reference then it will dereference it and get it
  /// from the document. If the object is `COSNull` or is not in
  /// the dictionary, then `nil` will be returned.
  ///
  /// - Parameter key: The key to the object that we are getting.
  /// - Returns: The object that matches the key.
  @inlinable // Inlinable as trivially forwarding and generic
  public subscript<T: COSBase>(cos key: TypedCOSName<T>) -> T? {
    get {
      return self[key.key] as? T
    }
    set {
      self[key.key] = newValue
    }
  }

  /// This will get an object from this dictionary as a COS object.
  /// If the object is a reference then it will dereference it and get it
  /// from the document. If the object is `COSNull` or is not in
  /// the dictionary, then `nil` will be returned.
  ///
  /// - Parameter key: The key to the object that we are getting.
  /// - Returns: The object that matches the key.
  @inlinable // Inlinable as trivially forwarding and generic
  public subscript<T: COSBase, S: COSBase>(
    cos key: TypedCOSName<Either<T, S>>
  ) -> Either<T, S>? {
    get {
      switch self[key.key] {
      case let r as T:
        return .left(r)
      case let r as S:
        return .right(r)
      default:
        return nil
      }
    }
    set {
      self[key.key] = newValue?.transform(ifLeft: { $0 }, ifRight: { $0 })
    }
  }

  /// This will get an object from this dictionary as a native Swift value.
  /// If the object is a reference then it will dereference it and get it
  /// from the document.
  /// If the object is `COSNull` or is not in the dictionary,
  /// then `nil` will be returned.
  ///
  /// - Parameter key: The key to the object that we are getting.
  /// - Returns: The native value of the object that matches the key.
  @inlinable // Inlinable as trivially forwarding and generic
  public subscript<T: Codable>(decode key: TypedCOSName<T>) -> T? {
    get {
      do {
        return try self[key.key].map {
          try COSDecoder().decode(T.self, from: $0)
        }
      } catch {
        return nil
      }
    }
    set {
      do {
        self[key.key] = try newValue.map(COSEncoder().encode)
      } catch {
        self[key.key] = nil
      }
    }
  }

  /// This will get an object from this dictionary as a native Swift value.
  /// If the object is a reference then it will dereference it and get it
  /// from the document.
  /// If the object is `COSNull` or is not in the dictionary,
  /// then `defaultValue` will be returned.
  ///
  /// - Parameters:
  ///   - key: The key to the item in the dictionary.
  ///   - defaultValue: The value returned if the entry is `nil`.
  /// - Returns: The object that matches the key.
  @inlinable // Inlinable as trivially forwarding and generic
  public subscript<T: Codable>(
    native key: TypedCOSName<T>,
    default defaultValue: @autoclosure () ->  T
  ) -> T {
    get {
      return self[decode: key] ?? defaultValue()
    }
    set {
      self[decode: key] = newValue
    }
  }

  /// This is a special case of subscript that takes two keys,
  /// it will handle the situation where multiple keys could get the same value,
  /// ie if either "CS" or "ColorSpace" is used to get the colorspace.
  ///
  /// This will get an object from this dictionary as a native Swift value.
  /// If the object is a reference then it will dereference it and get it
  /// from the document.
  /// If the object is `COSNull` or is not in the dictionary,
  /// then `defaultValue` will be returned.
  ///
  /// - Parameters:
  ///   - firstKey: The first key to the item in the dictionary.
  ///   - secondKey: The second key to the item in the dictionary.
  ///   - defaultValue: The value returned if the entry is `nil`.
  /// - Returns: The object that matches the key.
  @inlinable // Inlinable as trivially forwarding and generic
  public subscript<T: Codable>(
    native firstKey: TypedCOSName<T>,
    secondKey: TypedCOSName<T>,
    default defaultValue: @autoclosure () ->  T
  ) -> T {
    return self[decode: firstKey] ?? self[decode: secondKey] ?? defaultValue()
  }

  /// This is a special case of subscript that takes two keys,
  /// it will handle the situation where multiple keys could get the same value,
  /// ie if either "CS" or "ColorSpace" is used to get the colorspace.
  ///
  /// This will get an object from this dictionary as a COS object.
  /// If the object is a reference then it will dereference it and get it
  /// from the document.
  /// If the object is `COSNull` or is not in the dictionary,
  /// then `nil` will be returned.
  ///
  /// - Parameters:
  ///   - firstKey: The first key to the item in the dictionary.
  ///   - secondKey: The second key to the item in the dictionary.
  /// - Returns: The object that matches the key.
  @inlinable // Inlinable as trivially forwarding and generic
  public subscript<T: COSBase>(
    cos firstKey: TypedCOSName<T>,
    secondKey: TypedCOSName<T>
  ) -> T? {
    return self[cos: firstKey] ?? self[cos: secondKey]
  }

  /// This is a special case of subscript that takes two keys,
  /// it will handle the situation where multiple keys could get the same value,
  /// ie if either "CS" or "ColorSpace" is used to get the colorspace.
  ///
  /// This will get an object from this dictionary as a COS object.
  /// If the object is a reference then it will dereference it and get it
  /// from the document.
  /// If the object is `COSNull` or is not in the dictionary,
  /// then `nil` will be returned.
  ///
  /// - Parameters:
  ///   - firstKey: The first key to the item in the dictionary.
  ///   - secondKey: The second key to the item in the dictionary.
  /// - Returns: The object that matches the key.
  @inlinable // Inlinable as trivially forwarding and generic
  public subscript<T: COSBase, S: COSBase>(
    cos firstKey: TypedCOSName<Either<T, S>>,
    secondKey: TypedCOSName<Either<T, S>>
  ) -> Either<T, S>? {
      return self[cos: firstKey] ?? self[cos: secondKey]
  }

  /// This will get an object from this dictionary as an option set.
  /// If the object is a reference then it will dereference it and get it
  /// from the document.
  /// If the object is `COSNull` or is not in the dictionary,
  /// then empty option set will be returned.
  ///
  /// - Parameter key: The key to the object that we are getting.
  /// - Returns: The option set that matches the key.
  @inlinable // Inlinable as trivially forwarding and generic
  public subscript<T: OptionSet>(
    native key: TypedCOSName<T>
  ) -> T where T.RawValue: Codable {
    get {
      return self[decode: TypedCOSName<T.RawValue>(key: key.key)]
        .map(T.init) ?? T()
    }
    set {
      self[decode: TypedCOSName<T.RawValue>(key: key.key)] = newValue.rawValue
    }
  }

  /// This will get an object from this dictionary as an option set and tell
  /// if it contains the given flag.
  /// If the object is a reference then it will dereference it and get it
  /// from the document.
  /// If the object is `COSNull` or is not in the dictionary,
  /// then `false` will be returned.
  ///
  /// - Parameters:
  ///   - key: The key to the object that we are getting.
  ///   - flag: The flag to check or set.
  /// - Returns: The value of the flag.
  @inlinable // Inlinable as trivially forwarding and generic
  public subscript<T: OptionSet>(
    native key: TypedCOSName<T>,
    flag flag: T.Element
  ) -> Bool where T.RawValue: Codable, T.Element == T {
    get {
      return self[native: key].contains(flag)
    }
    set {
      if newValue {
        self[native: key].formUnion(flag)
      } else {
        self[native: key].subtract(flag)
      }
    }
  }
}

// MARK: -
extension COSDictionary.Index: Comparable {

  public static func < (lhs: COSDictionary.Index,
                        rhs: COSDictionary.Index) -> Bool {
    return lhs.wrapped < rhs.wrapped
  }
}
