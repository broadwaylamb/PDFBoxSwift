//
//  COSDictionary.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 11/01/2019.
//

/// This class represents a dictionary where name/value pairs reside.
public class COSDictionary: COSBase, COSUpdateInfo, ConvertibleToCOS {

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

  public var cosRepresentation: COSDictionary {
    return self
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

extension COSDictionary: RandomAccessCollection {

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
  public subscript<T>(cos key: TypedCOSName<T>) -> T.ToCOS? {
    get {
      return self[key.key] as? T.ToCOS
    }
    set {
      self[key.key] = newValue?.cosObject
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
  public subscript<T: ConvertibleFromCOS & ConvertibleToCOS>(
    native key: TypedCOSName<T>
  ) -> T? where T.ToCOS == T.FromCOS {
    get {
      return self[cos: key].map(T.init)
    }
    set {
      self[cos: key] = newValue?.cosRepresentation
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
  public subscript<T: ConvertibleFromCOS & ConvertibleToCOS>(
    native key: TypedCOSName<T>,
    default defaultValue: @autoclosure () ->  T
  ) -> T where T.ToCOS == T.FromCOS {
    get {
      return self[native: key] ?? defaultValue()
    }
    set {
      self[native: key] = newValue
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
  public subscript<T: ConvertibleFromCOS & ConvertibleToCOS>(
    native firstKey: TypedCOSName<T>,
    secondKey: TypedCOSName<T>,
    default defaultValue: @autoclosure () ->  T
  ) -> T where T.ToCOS == T.FromCOS {

    return self[native: firstKey] ?? self[native: secondKey] ?? defaultValue()
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
  public subscript<T>(
    cos firstKey: TypedCOSName<T>,
    secondKey: TypedCOSName<T>
  ) -> T.ToCOS? {
    return self[cos: firstKey] ?? self[cos: secondKey]
  }
}

// MARK: -
extension COSDictionary.Index: Comparable {

  public static func < (lhs: COSDictionary.Index,
                        rhs: COSDictionary.Index) -> Bool {
    return lhs.wrapped < rhs.wrapped
  }
}
