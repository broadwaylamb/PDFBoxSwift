//
//  COSArray.swift
//  COS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// An array of `COSBase` objects as part of the PDF document.
public final class COSArray: COSBase, COSUpdateInfo {

  private private(set) var objects: [COSBase] = []

  /// The update state for the `COSWriter`. This indicates whether an object
  /// is to be written when there is an incremental save.
  public var needsToBeUpdated: Bool = false

  /// Constructor.
  public override init() {
    super.init()
  }

  public override func accept(visitor: COSVisitorProtocol) throws -> Any? {
    return try visitor.visit(self)
  }
}

extension COSArray: RandomAccessCollection, MutableCollection {

  public typealias Index = Int

  public typealias Indices = Range<Int>

  public typealias Iterator = IndexingIterator<COSArray>

  public var startIndex: Int { return objects.startIndex }

  public var endIndex: Int { return objects.endIndex }

  public func index(after i: Int) -> Int {
    return objects.index(after: i)
  }

  public func formIndex(after i: inout Int) {
    objects.formIndex(after: &i)
  }

  public func index(before i: Int) -> Int {
    return objects.index(before: i)
  }

  public func formIndex(before i: inout Int) {
    objects.formIndex(before: &i)
  }

  public func index(_ i: Int, offsetBy distance: Int) -> Int {
    return objects.index(i, offsetBy: distance)
  }

  public func index(_ i: Int,
                    offsetBy distance: Int,
                    limitedBy limit: Int) -> Int? {
    return objects.index(i, offsetBy: distance, limitedBy: limit)
  }

  public func distance(from start: Int, to end: Int) -> Int {
    return objects.distance(from: start, to: end)
  }

  /// Get an object from the array. This will dereference a `COSObject`.
  /// If the object is `COSNull`, then `nil` will be returned.
  ///
  /// - Parameter position: The index in the array.
  public subscript(position: Int) -> COSBase? {
    get {
      let object = objects[position]
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
      objects[position] = newValue ?? COSNull.null
    }
  }

  public var count: Int { return objects.count }
}

extension COSArray: ExpressibleByArrayLiteral {
  public convenience init(arrayLiteral elements: COSBase?...) {
    self.init()
    objects = elements.map { $0 ?? COSNull.null }
  }
}

extension COSArray: RangeReplaceableCollection {

  public  func replaceSubrange<C: Collection>(_ subrange: Range<Int>,
                                              with newElements: C)
      where C.Element == COSBase? {
    objects.replaceSubrange(subrange,
                            with: newElements.lazy.map { $0 ?? COSNull.null })
  }

  public convenience init<S: Sequence>(_ elements: S)
      where S.Element == COSBase {
    self.init()
    objects = Array(elements)
  }

  public convenience init(repeating repeatedValue: COSBase?, count: Int) {
    self.init()
    objects = Array(repeating: repeatedValue ?? COSNull.null, count: count)
  }

  public func append(_ newElement: COSBase?) {
    objects.append(newElement ?? COSNull.null)
  }

  public func append(_ newElement: COSObjectConvertible) throws {
    try objects.append(newElement.getCOSObject())
  }

  public func append<S: Sequence>(contentsOf newElements: S)
      where S.Element == COSBase? {
    objects.append(contentsOf: newElements.lazy.map { $0 ?? COSNull.null })
  }

  public func remove(at position: Int) -> COSBase? {
    return objects.remove(at: position)
  }

  public func insert(_ newElement: COSBase?, at i: Int) {
    objects.insert(newElement ?? COSNull.null, at: i)
  }

  public func removeAll(keepingCapacity keepCapacity: Bool = false) {
    objects.removeAll(keepingCapacity: keepCapacity)
  }
}

extension COSArray {

  /// Set an object at a specific index.
  ///
  /// - Parameters:
  ///   - object: The object to set.
  ///   - index: The index of the array.
  public func set(_ object: COSBase?, at index: Int) {
    self[index] = object
  }

  /// Set an integer at a specific index.
  ///
  /// - Parameters:
  ///   - number: The index of the array.
  ///   - index: The integer to set.
  public func set(_ number: Int, at index: Int) {
    set(COSInteger.get(number), at: index)
  }

  /// Set an object at a specific index.
  ///
  /// - Parameters:
  ///   - object: The object to set.
  ///   - index: The index of the array.
  /// - Throws: Any error thrown by the `try object?.getCOSObject()` call.
  public func set(_ object: COSObjectConvertible?, at index: Index) throws {
    self[index] = try object?.getCOSObject()
  }

  /// Set the value in the array as a name.
  ///
  /// - Parameters:
  ///   - name: The name to set in the array.
  ///   - index: The index of the array.
  public func setName(_ name: String, at index: Int) {
    set(COSName.getPDFName(name), at: index)
  }

  /// Set the value in the array as a string.
  ///
  /// - Parameters:
  ///   - string: The string to set in the array.
  ///   - index: The index of the array.
  func setString(_ string: String, at index: Int) {
    set(COSString(text: string), at: index)
  }

  /// Get an object from the array. This will NOT dereference
  /// a `COSObject`.
  ///
  /// - Parameter index: The index of the array.
  /// - Returns: The object at the requested index.
  public func get(at index: Int) -> COSBase {
    return objects[index]
  }

  /// Get the value of the array as an integer.
  ///
  /// - Parameter index: The index of the array.
  /// - Returns: The integer value at that index or `nil` if does not exist.
  public func getInt(at index: Int) -> Int? {
    guard objects.indices.contains(index) else {
      return nil
    }
    return (objects[index] as? COSNumber)?.intValue
  }

  /// Get an entry in the array that is expected to be a `COSName`.
  ///
  /// - Parameter index: The index of the array.
  /// - Returns: The name converted to a string or `nil` if it does not exist.
  public func getName(at index: Int) -> String? {
    guard objects.indices.contains(index) else {
      return nil
    }
    return (objects[index] as? COSName)?.name
  }

  /// Get the value of the array as a string.
  ///
  /// - Parameter index: The index of the array.
  /// - Returns: The string or `nil` if it does not exist.
  public func getString(at index: Int) -> String? {
    guard objects.indices.contains(index) else {
      return nil
    }
    return (objects[index] as? COSString)?.string()
  }

  /// Remove an element from the array (based on identity).
  ///
  /// - Parameter object: he object to remove.
  /// - Returns: `true` if the object was removed, `false` otherwise.
  @discardableResult
  public func remove(_ object: COSBase) -> Bool {
    if let index = objects.firstIndex(of: object) {
      _ = remove(at: index)
      return true
    } else {
      return false
    }
  }

  /// Remove an element from the array (based on identity).
  /// This method will also remove a reference to the object.
  ///
  /// - Parameter object: The object to remove.
  /// - Returns: `true` if the object was removed, `false` otherwise.
  @discardableResult
  public func removeObject(_ object: COSBase) -> Bool {
    guard !remove(object) else { return true }
    for case let entry as COSObject in objects where entry.object == object {
      return remove(entry)
    }
    return false
  }

  /// Returns the first index where the specified object appears in the array.
  ///
  /// - Parameter object: The object to search for.
  /// - Returns: The first index where `object` is found. If element is not
  ///            found in the collection, returns `nil`.
  public func firstIndex(of object: COSBase) -> Int? {
    return objects.firstIndex(of: object)
  }

  /// Returns the first index where the specified object appears in the array.
  /// This method will also finds references to indirect objects.
  ///
  /// - Parameter object: The object to search for.
  /// - Returns: The first index where `object` is found. If element is not
  ///            found in the collection, returns `nil`.
  public func firstIndexIncludingReferences(of object: COSBase) -> Int? {
    return objects.firstIndex {
      if $0 == object {
        return true
      }
      if let entry = $0 as? COSObject, entry.object == object {
        return true
      }
      return false
    }
  }

  /// This will add the object until the size of the array is at least as large
  /// as `size`. If the array is already larger than the parameter then nothing
  /// is done.
  ///
  /// - Parameters:
  ///   - size: The desired size of the array.
  ///   - object: The object to fill the array with. Default value is `nil`.
  public func grow(toSize size: Int, inserting object: COSBase? = nil) {
    objects.reserveCapacity(size)
    while count < size {
      append(object)
    }
  }

  /// This will take an `COSArray` of numbers and convert it to a `[Float]`.
  ///
  /// - Returns: This `COSArray` as an array of float numbers.
  public func toFloatArray() -> [Float] {
    return map { ($0 as? COSNumber)?.floatValue ?? 0 }
  }

  public func setFloatArray<S: Sequence>(_ array: S) where S.Element == Float {
    removeAll()
    objects.reserveCapacity(array.underestimatedCount)
    append(contentsOf: array.lazy.map(COSFloat.init))
  }
}

extension COSArray: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "COSArray{\(objects)}"
  }
}
