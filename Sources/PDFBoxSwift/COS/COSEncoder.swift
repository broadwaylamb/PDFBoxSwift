//
//  COSEncoder.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 02/02/2019.
//

open class COSEncoder {

  open var userInfo: [CodingUserInfoKey : Any] = [:]

  fileprivate struct _Options {
    let userInfo: [CodingUserInfoKey : Any]
  }

  fileprivate var options: _Options {
    return _Options(userInfo: userInfo)
  }

  public init() {}

  open func encode<T: Encodable>(_ value: T) throws -> COSBase {
    let encoder = _COSEncoder(options: self.options)

    guard let topLevel = try encoder.box_(value) else {
      let context = EncodingError.Context(
        codingPath: [],
        debugDescription: "Top-level \(T.self) did not encode any values."
      )
      throw EncodingError.invalidValue(value, context)
    }

    return topLevel
  }
}

// MARK: - _JSONEncoder

private class _COSEncoder : Encoder {

  /// The encoder's storage.
  var storage: _COSEncodingStorage

  /// Options set on the top-level encoder.
  let options: COSEncoder._Options

  /// The path to the current point in encoding.
  var codingPath: [CodingKey]

  /// Contextual user-provided information for use during encoding.
  var userInfo: [CodingUserInfoKey : Any] {
    return self.options.userInfo
  }

  // MARK: - Initialization

  /// Initializes `self` with the given top-level encoder options.
  init(options: COSEncoder._Options, codingPath: [CodingKey] = []) {
    self.options = options
    self.storage = _COSEncodingStorage()
    self.codingPath = codingPath
  }

  var canEncodeNewValue: Bool {
    // Every time a new value gets encoded, the key it's encoded for is pushed
    // onto the coding path (even if it's a nil key from an unkeyed container).
    // At the same time, every time a container is requested, a new value gets
    // pushed onto the storage stack.
    // If there are more values on the storage stack than on the coding path,
    // it means the value is requesting more than one container, which violates
    // the precondition.
    //
    // This means that anytime something that can request a new container goes
    // onto the stack, we MUST push a key onto the coding path.
    // Things which will not request containers do not need to have the coding
    // path extended for them (but it doesn't matter if it is, because they
    // will not reach here).
    return storage.count == codingPath.count
  }

  // MARK: - Encoder Methods
  func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
    // If an existing keyed container was already requested, return that one.
    let topContainer: COSDictionary
    if canEncodeNewValue {
      // We haven't yet pushed a container at this level; do so here.
      topContainer = storage.pushKeyedContainer()
    } else {
      guard let container = storage.containers.last as? COSDictionary else {
        preconditionFailure("""
        Attempt to push new keyed encoding container when already previously \
        encoded at this path.
        """)
      }

      topContainer = container
    }

    let container = _COSKeyedEncodingContainer<Key>(referencing: self,
                                                    codingPath: codingPath,
                                                    wrapping: topContainer)
    return KeyedEncodingContainer(container)
  }

  public func unkeyedContainer() -> UnkeyedEncodingContainer {
    // If an existing unkeyed container was already requested, return that one.
    let topContainer: COSArray
    if canEncodeNewValue {
      // We haven't yet pushed a container at this level; do so here.
      topContainer = storage.pushUnkeyedContainer()
    } else {
      guard let container = storage.containers.last as? COSArray else {
        preconditionFailure("""
        Attempt to push new keyed encoding container when already previously \
        encoded at this path.
        """)
      }

      topContainer = container
    }

    return _COSUnkeyedEncodingContainer(referencing: self,
                                        codingPath: codingPath,
                                        wrapping: topContainer)
  }

  public func singleValueContainer() -> SingleValueEncodingContainer {
    return self
  }
}

// MARK: - Encoding Storage and Containers

fileprivate struct _COSEncodingStorage {

  /// The container stack.
  /// Elements may be any one of the COS types
  /// (COSNull, COSNumber, COSString, COSArray, COSDictionary).
  private(set) var containers: [COSBase] = []

  // MARK: - Initialization

  /// Initializes `self` with no containers.
  init() {}

  // MARK: - Modifying the Stack

  var count: Int {
    return containers.count
  }

  mutating func pushKeyedContainer() -> COSDictionary {
    let dictionary = COSDictionary()
    self.containers.append(dictionary)
    return dictionary
  }

  mutating func pushUnkeyedContainer() -> COSArray {
    let array = COSArray()
    self.containers.append(array)
    return array
  }

  mutating func push(container: COSBase) {
    self.containers.append(container)
  }

  mutating func popContainer() -> COSBase {
    precondition(!self.containers.isEmpty, "Empty container stack.")
    return self.containers.popLast()!
  }
}

// MARK: - Encoding Containers

private struct _COSKeyedEncodingContainer<K: CodingKey>:
    KeyedEncodingContainerProtocol {
  typealias Key = K

  // MARK: Properties

  /// A reference to the encoder we're writing to.
  private let encoder: _COSEncoder

  /// A reference to the container we're writing to.
  private let container: COSDictionary

  /// The path of coding keys taken to get to this point in encoding.
  private(set) var codingPath: [CodingKey]

  // MARK: - Initialization

  /// Initializes `self` with the given references.
  init(referencing encoder: _COSEncoder,
       codingPath: [CodingKey],
       wrapping container: COSDictionary) {
    self.encoder = encoder
    self.codingPath = codingPath
    self.container = container
  }

  // MARK: - KeyedEncodingContainerProtocol Methods

  mutating func encodeNil(forKey key: Key) throws {
    container[key.cosName] = COSNull.null
  }

  mutating func encode(_ value: Bool, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: Int, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: Int8, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: Int16, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: Int32, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: Int64, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: UInt, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: UInt8, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: UInt16, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: UInt32, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: UInt64, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }

  mutating func encode(_ value: String, forKey key: Key) throws {
    container[key.cosName] = encoder.box(value)
  }


  mutating func encode(_ value: Float, forKey key: Key)  throws {
    // Since the float may be invalid and throw, the coding path needs to
    // contain this key.
    encoder.codingPath.append(key)
    defer { encoder.codingPath.removeLast() }
    container[key.cosName] = try encoder.box(value)
  }

  mutating func encode(_ value: Double, forKey key: Key) throws {
    // Since the double may be invalid and throw, the coding path needs to
    // contain this key.
    encoder.codingPath.append(key)
    defer { encoder.codingPath.removeLast() }
    container[key.cosName] = try encoder.box(value)
  }

  mutating func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
    encoder.codingPath.append(key)
    defer { encoder.codingPath.removeLast() }
    container[key.cosName] = try encoder.box(value)
  }

  mutating func nestedContainer<NestedKey>(
    keyedBy keyType: NestedKey.Type,
    forKey key: Key
  ) -> KeyedEncodingContainer<NestedKey> {
    let dictionary = COSDictionary()
    self.container[key.cosName] = dictionary

    codingPath.append(key)
    defer { codingPath.removeLast() }

    let container = _COSKeyedEncodingContainer<NestedKey>(
      referencing: encoder,
      codingPath: codingPath,
      wrapping: dictionary
    )
    return KeyedEncodingContainer(container)
  }

  mutating func nestedUnkeyedContainer(
    forKey key: Key
  ) -> UnkeyedEncodingContainer {
    let array = COSArray()
    container[key.cosName] = array

    codingPath.append(key)
    defer { codingPath.removeLast() }

    return _COSUnkeyedEncodingContainer(referencing: encoder,
                                        codingPath: codingPath,
                                        wrapping: array)
  }

  mutating func superEncoder() -> Encoder {
    return _COSReferencingEncoder(referencing: encoder,
                                   at: _COSKey.super,
                                   wrapping: container)
  }

  mutating func superEncoder(forKey key: Key) -> Encoder {
    return _COSReferencingEncoder(referencing: encoder,
                                  at: key,
                                  wrapping: container)
  }
}

private struct _COSUnkeyedEncodingContainer: UnkeyedEncodingContainer {
  // MARK: Properties

  /// A reference to the encoder we're writing to.
  private let encoder: _COSEncoder

  /// A reference to the container we're writing to.
  private let container: COSArray

  /// The path of coding keys taken to get to this point in encoding.
  private(set) var codingPath: [CodingKey]

  /// The number of elements encoded into the container.
  public var count: Int {
    return container.count
  }

  // MARK: - Initialization

  /// Initializes `self` with the given references.
  init(referencing encoder: _COSEncoder,
       codingPath: [CodingKey],
       wrapping container: COSArray) {
    self.encoder = encoder
    self.codingPath = codingPath
    self.container = container
  }

  // MARK: - UnkeyedEncodingContainer Methods

  mutating func encodeNil() throws {
    container.append(COSNull.null)
  }

  mutating func encode(_ value: Bool) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: Int) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: Int8) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: Int16) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: Int32) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: Int64) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: UInt) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: UInt8) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: UInt16) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: UInt32) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: UInt64) throws {
    container.append(encoder.box(value))
  }

  mutating func encode(_ value: String) throws {
    container.append(encoder.box(value))
  }


  mutating func encode(_ value: Float)  throws {
    // Since the float may be invalid and throw, the coding path needs
    // to contain this key.
    encoder.codingPath.append(_COSKey(index: count))
    defer { encoder.codingPath.removeLast() }
    try container.append(encoder.box(value))
  }

  mutating func encode(_ value: Double) throws {
    // Since the double may be invalid and throw, the coding path needs
    // to contain this key.
    encoder.codingPath.append(_COSKey(index: count))
    defer { encoder.codingPath.removeLast() }
    try container.append(encoder.box(value))
  }

  mutating func encode<T: Encodable>(_ value: T) throws {
    encoder.codingPath.append(_COSKey(index: count))
    defer { encoder.codingPath.removeLast() }
    try container.append(encoder.box(value))
  }

  mutating func nestedContainer<NestedKey>(
    keyedBy keyType: NestedKey.Type
  ) -> KeyedEncodingContainer<NestedKey> {
    codingPath.append(_COSKey(index: count))
    defer { codingPath.removeLast() }

    let dictionary = COSDictionary()
    self.container.append(dictionary)

    let container = _COSKeyedEncodingContainer<NestedKey>(
      referencing: encoder,
      codingPath: codingPath,
      wrapping: dictionary
    )
    return KeyedEncodingContainer(container)
  }

  mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
    codingPath.append(_COSKey(index: count))
    defer { codingPath.removeLast() }

    let array = COSArray()
    container.append(array)
    return _COSUnkeyedEncodingContainer(referencing: encoder,
                                        codingPath: codingPath,
                                        wrapping: array)
  }

  mutating func superEncoder() -> Encoder {
    return _COSReferencingEncoder(referencing: encoder,
                                  at: container.count,
                                  wrapping: container)
  }
}

extension _COSEncoder: SingleValueEncodingContainer {

  fileprivate func assertCanEncodeNewValue() {
    precondition(canEncodeNewValue, """
                 Attempt to encode value through single value container \
                 when previously value already encoded.
                 """)
  }

  func encodeNil() throws {
    assertCanEncodeNewValue()
    storage.push(container: COSNull.null)
  }

  func encode(_ value: Bool) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: Int) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: Int8) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: Int16) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: Int32) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: Int64) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: UInt) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: UInt8) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: UInt16) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: UInt32) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: UInt64) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: String) throws {
    assertCanEncodeNewValue()
    storage.push(container: box(value))
  }

  func encode(_ value: Float) throws {
    assertCanEncodeNewValue()
    try storage.push(container: box(value))
  }

  func encode(_ value: Double) throws {
    assertCanEncodeNewValue()
    try storage.push(container: box(value))
  }

  func encode<T: Encodable>(_ value: T) throws {
    assertCanEncodeNewValue()
    try storage.push(container: box(value))
  }
}

// MARK: - Concrete Value Representations

extension _COSEncoder {

  func box(_ value: Bool) -> COSBoolean {
    return COSBoolean.get(value)
  }

  func box(_ value: Int) -> COSInteger {
    return COSInteger.get(value)
  }

  func box(_ value: Int8) -> COSInteger {
    return COSInteger.get(value)
  }

  func box(_ value: Int16) -> COSInteger {
    return COSInteger.get(value)
  }

  func box(_ value: Int32) -> COSInteger {
    return COSInteger.get(value)
  }

  func box(_ value: Int64) -> COSInteger {
    return COSInteger.get(value)
  }

  func box(_ value: UInt) -> COSInteger {
    return COSInteger.get(value)
  }

  func box(_ value: UInt8) -> COSInteger {
    return COSInteger.get(value)
  }

  func box(_ value: UInt16) -> COSInteger {
    return COSInteger.get(value)
  }

  func box(_ value: UInt32) -> COSInteger {
    return COSInteger.get(value)
  }

  func box(_ value: UInt64) -> COSInteger {
    return COSInteger.get(value)
  }

  func box(_ value: String) -> COSString  {
    return COSString(text: value)
  }

  func box(_ float: Float) throws -> COSFloat {
    guard !float.isInfinite && !float.isNaN else {
       throw EncodingError.invalidFloatingPointValue(float, at: codingPath)
    }
    return COSFloat(value: float)
  }

  func box(_ double: Double) throws -> COSFloat {
    guard !double.isInfinite && !double.isNaN else {
      throw EncodingError.invalidFloatingPointValue(double, at: codingPath)
    }
    return COSFloat(value: double)
  }

  func box<T: Encodable>(_ value: T) throws -> COSBase {
    return try box_(value) ?? COSDictionary()
  }

  // This method is called "box_" instead of "box" to disambiguate it from
  // the overloads. Because the return type here is different from all of
  // the "box" overloads (and is more general), any "box" calls in here would
  // call back into "box" recursively instead of calling the appropriate
  // overload, which is not what we want.
  fileprivate func box_<T: Encodable>(_ value: T) throws -> COSBase? {

    // These classes are immutable, we can encode them as is without copying
    switch value {
    case let value as COSName:
      return value
    case let value as COSBoolean:
      return value
    case let value as COSNumber:
      return value
    case let value as COSNull:
      return value
    default:
      break
    }

    // The value should request a container from the _COSEncoder.
    let depth = storage.count
    do {
      try value.encode(to: self)
    } catch {
      // If the value pushed a container before throwing, pop it back off
      // to restore state.
      if storage.count > depth {
        _ = storage.popContainer()
      }
      throw error
    }

    // The top container should be a new container.
    guard storage.count > depth else {
      return nil
    }

    return storage.popContainer()
  }
}

/// _COSReferencingEncoder is a special subclass of _COSEncoder which has
/// its own storage, but references the contents of a different encoder.
/// It's used in superEncoder(), which returns a new encoder for encoding
/// a superclass - the lifetime of the encoder should not escape the scope
/// it's created in, but it doesn't necessarily know when it's done being used
/// (to write to the original container).
private class _COSReferencingEncoder: _COSEncoder {

  /// The type of container we're referencing.
  private enum Reference {
    /// Referencing a specific index in an array container.
    case array(COSArray, Int)

    /// Referencing a specific key in a dictionary container.
    case dictionary(COSDictionary, COSName)
  }

  /// The encoder we're referencing.
  let encoder: _COSEncoder

  /// The container reference itself.
  private let reference: Reference

  /// Initializes `self` by referencing the given array container in
  /// the given encoder.
  init(referencing encoder: _COSEncoder,
       at index: Int,
       wrapping array: COSArray) {
    self.encoder = encoder
    self.reference = .array(array, index)
    super.init(options: encoder.options, codingPath: encoder.codingPath)
    self.codingPath.append(_COSKey(index: index))
  }

  /// Initializes `self` by referencing the given dictionary container in
  /// the given encoder.
  init(referencing encoder: _COSEncoder,
       at key: CodingKey,
       wrapping dictionary: COSDictionary) {
    self.encoder = encoder
    self.reference = .dictionary(dictionary, key.cosName)
    super.init(options: encoder.options, codingPath: encoder.codingPath)
    self.codingPath.append(key)
  }

  // MARK: - Coding Path Operations

  override var canEncodeNewValue: Bool {
    // With a regular encoder, the storage and coding path grow together.
    // A referencing encoder, however, inherits its parents coding path,
    // as well as the key it was created for.
    // We have to take this into account.
    return storage.count == codingPath.count - encoder.codingPath.count - 1
  }

  // MARK: - Deinitialization

  // Finalizes `self` by writing the contents of our storage to the referenced
  // encoder's storage.
  deinit {
    let value: COSBase
    switch self.storage.count {
    case 0:
      value = COSDictionary()
    case 1:
      value = storage.popContainer()
    default:
      fatalError("""
      Referencing encoder deallocated with multiple containers on stack.
      """)
    }

    switch self.reference {
    case .array(let array, let index):
      array.insert(value, at: index)
    case .dictionary(let dictionary, let key):
      dictionary[key] = value
    }
  }
}

open class COSDecoder {

  open var userInfo: [CodingUserInfoKey : Any] = [:]

  struct _Options {
    let userInfo: [CodingUserInfoKey : Any]
  }

  fileprivate var options: _Options {
    return _Options(userInfo: userInfo)
  }

  public init() {}

  open func decode<T: Decodable>(_ type: T.Type,
                                 from cos: COSBase) throws -> T {
    let decoder = _COSDecoder(referencing: cos, options: options)
    return try decoder.unbox(cos, as: type)
  }
}

// MARK: - _COSDecoder

private class _COSDecoder: Decoder {
  // MARK: Properties

  /// The decoder's storage.
  var storage: _COSDecodingStorage

  /// Options set on the top-level decoder.
  let options: COSDecoder._Options

  /// The path to the current point in encoding.
  var codingPath: [CodingKey]

  /// Contextual user-provided information for use during encoding.
  var userInfo: [CodingUserInfoKey : Any] {
    return self.options.userInfo
  }

  // MARK: - Initialization

  /// Initializes `self` with the given top-level container and options.
  init(referencing container: COSBase,
       at codingPath: [CodingKey] = [],
       options: COSDecoder._Options) {
    self.storage = _COSDecodingStorage()
    self.storage.push(container: container)
    self.codingPath = codingPath
    self.options = options
  }

  // MARK: - Decoder Methods

  func container<Key>(
    keyedBy type: Key.Type
  ) throws -> KeyedDecodingContainer<Key> {

    guard !(storage.topContainer is COSNull) else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: """
        Cannot get keyed decoding container — \
        found null value instead.
        """
      )
      throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
                                        context)
    }

    guard let topContainer = storage.topContainer as? COSDictionary else {
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: COSDictionary.self,
                                       reality: storage.topContainer)
    }

    let container = _COSKeyedDecodingContainer<Key>(referencing: self,
                                                    wrapping: topContainer)
    return KeyedDecodingContainer(container)
  }

  func unkeyedContainer() throws -> UnkeyedDecodingContainer {

    guard !(storage.topContainer is COSNull) else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: """
        Cannot get unkeyed decoding container — \
        found null value instead.
        """
      )
      throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
    }

    guard let topContainer = storage.topContainer as? COSArray else {
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: COSArray.self,
                                       reality: storage.topContainer)
    }

    return _COSUnkeyedDecodingContainer(referencing: self,
                                        wrapping: topContainer)
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    return self
  }
}

// MARK: - Decoding Storage

private struct _COSDecodingStorage {
  // MARK: Properties

  /// The container stack.
  /// Elements may be any one of the COS types (COSNull, COSNumber, COSString,
  /// COSArray, COSDictionary, COSName, COSStream).
  private(set) var containers: [COSBase] = []

  // MARK: - Initialization

  /// Initializes `self` with no containers.
  init() {}

  // MARK: - Modifying the Stack

  var count: Int {
    return containers.count
  }

  var topContainer: COSBase {
    precondition(!containers.isEmpty, "Empty container stack.")
    return containers.last!
  }

  mutating func push(container: COSBase) {
    self.containers.append(container)
  }

  mutating func popContainer() {
    precondition(!self.containers.isEmpty, "Empty container stack.")
    self.containers.removeLast()
  }
}

// MARK: Decoding Containers

private struct _COSKeyedDecodingContainer<K: CodingKey> :
    KeyedDecodingContainerProtocol {

  typealias Key = K

  // MARK: Properties

  /// A reference to the decoder we're reading from.
  private let decoder: _COSDecoder

  /// A reference to the container we're reading from.
  private let container: COSDictionary

  /// The path of coding keys taken to get to this point in decoding.
  private(set) var codingPath: [CodingKey]

  // MARK: - Initialization

  /// Initializes `self` by referencing the given decoder and container.
  init(referencing decoder: _COSDecoder, wrapping container: COSDictionary) {
    self.decoder = decoder
    self.container = container
    self.codingPath = decoder.codingPath
  }

  // MARK: - KeyedDecodingContainerProtocol Methods

  var allKeys: [Key] {
    if let cosCodingKeyType = K.self as? COSCodingKey.Type {
      return container.keys
        .compactMap { cosCodingKeyType.init(nameValue: $0) } as! [Key]
    } else {
      return container.keys.compactMap { Key(stringValue: $0.name) }
    }
  }

  func contains(_ key: Key) -> Bool {
    return container[key.cosName] != nil
  }

  private func errorDescription(of key: CodingKey) -> String {
    return "\(key) (\"\(key.stringValue)\")"
  }

  func decodeNil(forKey key: Key) throws -> Bool {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    return entry is COSNull
  }

  func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: Bool.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: Int.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: Int8.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: Int16.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: Int32.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: Int64.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: UInt.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: UInt8.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: UInt16.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: UInt32.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: UInt64.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: Float.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: Double.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode(_ type: String.Type, forKey key: Key) throws -> String {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = try decoder.unbox(entry, as: String.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected \(type) value but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    return value
  }

  func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
    guard let entry = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: """
        No value associated with key \(errorDescription(of: key)).
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    return try decoder.unbox(entry, as: type)
  }

  func nestedContainer<NestedKey>(
    keyedBy type: NestedKey.Type,
    forKey key: Key
  ) throws -> KeyedDecodingContainer<NestedKey> {

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = self.container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: """
        Cannot get \(KeyedDecodingContainer<NestedKey>.self) — no value found \
        for key \(errorDescription(of: key))
        """
      )
      throw DecodingError.keyNotFound(key, context)
    }

    guard let dictionary = value as? COSDictionary else {
      throw DecodingError.typeMismatch(at: self.codingPath,
                                       expectation: COSDictionary.self,
                                       reality: value)
    }

    let container = _COSKeyedDecodingContainer<NestedKey>(referencing: decoder,
                                                          wrapping: dictionary)
    return KeyedDecodingContainer(container)
  }

  func nestedUnkeyedContainer(
    forKey key: Key
  ) throws -> UnkeyedDecodingContainer {

    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    guard let value = container[key.cosName] else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: """
        Cannot get UnkeyedDecodingContainer — no value found \
        for key \(errorDescription(of: key))
        """
      )
      throw DecodingError.keyNotFound(key,
                                      context)
    }

    guard let array = value as? COSArray else {
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: COSArray.self,
                                       reality: value)
    }

    return _COSUnkeyedDecodingContainer(referencing: decoder, wrapping: array)
  }

  private func _superDecoder(forKey key: CodingKey) -> Decoder {
    decoder.codingPath.append(key)
    defer { decoder.codingPath.removeLast() }

    let value = container[key.cosName] ?? COSNull.null
    return _COSDecoder(referencing: value,
                       at: decoder.codingPath,
                       options: decoder.options)
  }

  func superDecoder() -> Decoder {
    return _superDecoder(forKey: _COSKey.super)
  }

  func superDecoder(forKey key: Key) -> Decoder {
    return _superDecoder(forKey: key)
  }
}

fileprivate struct _COSUnkeyedDecodingContainer: UnkeyedDecodingContainer {

  /// A reference to the decoder we're reading from.
  private let decoder: _COSDecoder

  /// A reference to the container we're reading from.
  private let container: COSArray

  /// The path of coding keys taken to get to this point in decoding.
  private(set) var codingPath: [CodingKey]

  /// The index of the element we're about to decode.
  private(set) var currentIndex: Int

  // MARK: - Initialization

  /// Initializes `self` by referencing the given decoder and container.
  init(referencing decoder: _COSDecoder, wrapping container: COSArray) {
    self.decoder = decoder
    self.container = container
    self.codingPath = decoder.codingPath
    self.currentIndex = 0
  }

  // MARK: - UnkeyedDecodingContainer Methods

  var count: Int? {
    return self.container.count
  }

  var isAtEnd: Bool {
    return currentIndex >= count!
  }

  mutating func decodeNil() throws -> Bool {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(COSNull.self, context)
    }

    if container[currentIndex] is COSNull {
      currentIndex += 1
      return true
    } else {
      return false
    }
  }

  mutating func decode(_ type: Bool.Type) throws -> Bool {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: Bool.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: Int.Type) throws -> Int {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: Int.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: Int8.Type) throws -> Int8 {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: Int8.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: Int16.Type) throws -> Int16 {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: Int16.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: Int32.Type) throws -> Int32 {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: Int32.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: Int64.Type) throws -> Int64 {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: Int64.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: UInt.Type) throws -> UInt {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: UInt.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: UInt8.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: UInt16.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: UInt32.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: UInt64.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: Float.Type) throws -> Float {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: Float.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: Double.Type) throws -> Double {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: Double.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode(_ type: String.Type) throws -> String {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard let decoded = try decoder.unbox(container[currentIndex],
                                          as: String.self) else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Expected \(type) but found null instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    currentIndex += 1
    return decoded
  }

  mutating func decode<T : Decodable>(_ type: T.Type) throws -> T {
    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: decoder.codingPath + [_COSKey(index: currentIndex)],
        debugDescription: "Unkeyed container is at end."
      )
      throw DecodingError.valueNotFound(type, context)
    }

    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }
    let decoded = try decoder.unbox(container[currentIndex], as: type)
    currentIndex += 1
    return decoded
  }

  mutating func nestedContainer<NestedKey>(
    keyedBy type: NestedKey.Type
  ) throws -> KeyedDecodingContainer<NestedKey> {
    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: """
        Cannot get nested keyed container — unkeyed container is at end.
        """
      )
      throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                        context)
    }

    let value = self.container[currentIndex]
    guard !(value is COSNull) else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: """
        Cannot get keyed decoding container — found null value instead.
        """
      )
      throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                        context)
    }

    guard let dictionary = value as? COSDictionary else {
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: COSDictionary.self,
                                       reality: value)
    }

    currentIndex += 1
    let container = _COSKeyedDecodingContainer<NestedKey>(referencing: decoder,
                                                          wrapping: dictionary)
    return KeyedDecodingContainer(container)
  }

  mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: """
        Cannot get nested keyed container — unkeyed container is at end.
        """
      )
      throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
    }

    let value = container[currentIndex]
    guard !(value is COSNull) else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: """
        Cannot get keyed decoding container — found null value instead.
        """
      )
      throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
    }

    guard let array = value as? COSArray else {
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: COSArray.self,
                                       reality: value)
    }

    currentIndex += 1
    return _COSUnkeyedDecodingContainer(referencing: decoder, wrapping: array)
  }

  mutating func superDecoder() throws -> Decoder {
    decoder.codingPath.append(_COSKey(index: currentIndex))
    defer { decoder.codingPath.removeLast() }

    guard !isAtEnd else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: """
        Cannot get superDecoder() — unkeyed container is at end.
        """
      )
      throw DecodingError.valueNotFound(Decoder.self, context)
    }

    let value = container[currentIndex] ?? COSNull.null
    currentIndex += 1
    return _COSDecoder(referencing: value,
                       at: decoder.codingPath,
                       options: decoder.options)
  }
}

extension _COSDecoder: SingleValueDecodingContainer {

  private func expectNonNull<T>(_ type: T.Type) throws {
    guard !decodeNil() else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "Expected \(type) but found null value instead."
      )
      throw DecodingError.valueNotFound(type, context)
    }
  }

  func decodeNil() -> Bool {
    return self.storage.topContainer is COSNull
  }

  func decode(_ type: Bool.Type) throws -> Bool {
    try expectNonNull(Bool.self)
    return try unbox(storage.topContainer, as: Bool.self)!
  }

  func decode(_ type: Int.Type) throws -> Int {
    try expectNonNull(Int.self)
    return try unbox(storage.topContainer, as: Int.self)!
  }

  func decode(_ type: Int8.Type) throws -> Int8 {
    try expectNonNull(Int8.self)
    return try unbox(storage.topContainer, as: Int8.self)!
  }

  func decode(_ type: Int16.Type) throws -> Int16 {
    try expectNonNull(Int16.self)
    return try unbox(storage.topContainer, as: Int16.self)!
  }

  func decode(_ type: Int32.Type) throws -> Int32 {
    try expectNonNull(Int32.self)
    return try unbox(storage.topContainer, as: Int32.self)!
  }

  func decode(_ type: Int64.Type) throws -> Int64 {
    try expectNonNull(Int64.self)
    return try unbox(storage.topContainer, as: Int64.self)!
  }

  func decode(_ type: UInt.Type) throws -> UInt {
    try expectNonNull(UInt.self)
    return try unbox(storage.topContainer, as: UInt.self)!
  }

  func decode(_ type: UInt8.Type) throws -> UInt8 {
    try expectNonNull(UInt8.self)
    return try unbox(self.storage.topContainer, as: UInt8.self)!
  }

  func decode(_ type: UInt16.Type) throws -> UInt16 {
    try expectNonNull(UInt16.self)
    return try unbox(storage.topContainer, as: UInt16.self)!
  }

  func decode(_ type: UInt32.Type) throws -> UInt32 {
    try expectNonNull(UInt32.self)
    return try unbox(storage.topContainer, as: UInt32.self)!
  }

  func decode(_ type: UInt64.Type) throws -> UInt64 {
    try expectNonNull(UInt64.self)
    return try unbox(storage.topContainer, as: UInt64.self)!
  }

  func decode(_ type: Float.Type) throws -> Float {
    try expectNonNull(Float.self)
    return try unbox(storage.topContainer, as: Float.self)!
  }

  func decode(_ type: Double.Type) throws -> Double {
    try expectNonNull(Double.self)
    return try unbox(storage.topContainer, as: Double.self)!
  }

  func decode(_ type: String.Type) throws -> String {
    try expectNonNull(String.self)
    return try unbox(storage.topContainer, as: String.self)!
  }

  func decode<T: Decodable>(_ type: T.Type) throws -> T {
    try expectNonNull(type)
    return try unbox(storage.topContainer, as: type)
  }
}

// MARK: - Concrete Value Representations

extension _COSDecoder {
  /// Returns the given value unboxed from a container.
  func unbox(_ value: COSBase?, as type: Bool.Type) throws -> Bool? {
    guard let value = value, !(value is COSNull) else { return nil }

    if let bool = value as? COSBoolean {
      return bool.value
    }

    throw DecodingError.typeMismatch(at: codingPath,
                                     expectation: type,
                                     reality: value)
  }

  func unbox(_ value: COSBase?, as type: Int.Type) throws -> Int? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: Int?
    switch value {
    case let number as COSInteger:
      result = type.init(exactly: number.intValue)
    case let number as COSFloat:
      let double = number.doubleValue
      result = double <= Double(type.max) && double >= Double(type.min)
        ? type.init(double)
        : nil
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }

    if let result = result {
      return result
    } else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "The number \(value) does not fit in \(type)."
      )
      throw DecodingError.dataCorrupted(context)
    }
  }

  func unbox(_ value: COSBase?, as type: Int8.Type) throws -> Int8? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: Int8?
    switch value {
    case let number as COSInteger:
      result = type.init(exactly: number.intValue)
    case let number as COSFloat:
      let double = number.doubleValue
      result = double <= Double(type.max) && double >= Double(type.min)
        ? type.init(double)
        : nil
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }

    if let result = result {
      return result
    } else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "The number \(value) does not fit in \(type)."
      )
      throw DecodingError.dataCorrupted(context)
    }
  }

  func unbox(_ value: COSBase?, as type: Int16.Type) throws -> Int16? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: Int16?
    switch value {
    case let number as COSInteger:
      result = type.init(exactly: number.intValue)
    case let number as COSFloat:
      let double = number.doubleValue
      result = double <= Double(type.max) && double >= Double(type.min)
        ? type.init(double)
        : nil
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }

    if let result = result {
      return result
    } else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "The number \(value) does not fit in \(type)."
      )
      throw DecodingError.dataCorrupted(context)
    }
  }

  func unbox(_ value: COSBase?, as type: Int32.Type) throws -> Int32? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: Int32?
    switch value {
    case let number as COSInteger:
      result = type.init(exactly: number.intValue)
    case let number as COSFloat:
      let double = number.doubleValue
      result = double <= Double(type.max) && double >= Double(type.min)
        ? type.init(double)
        : nil
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }

    if let result = result {
      return result
    } else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "The number \(value) does not fit in \(type)."
      )
      throw DecodingError.dataCorrupted(context)
    }
  }

  func unbox(_ value: COSBase?, as type: Int64.Type) throws -> Int64? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: Int64?
    switch value {
    case let number as COSInteger:
      result = number.intValue
    case let number as COSFloat:
      let double = number.doubleValue
      result = double <= Double(type.max) && double >= Double(type.min)
        ? type.init(double)
        : nil
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }

    if let result = result {
      return result
    } else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "The number \(value) does not fit in \(type)."
      )
      throw DecodingError.dataCorrupted(context)
    }
  }

  func unbox(_ value: COSBase?, as type: UInt.Type) throws -> UInt? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: UInt?
    switch value {
    case let number as COSInteger:
      result = type.init(exactly: number.intValue)
    case let number as COSFloat:
      let double = number.doubleValue
      result = double <= Double(type.max) && double >= Double(type.min)
        ? type.init(double)
        : nil
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }

    if let result = result {
      return result
    } else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "The number \(value) does not fit in \(type)."
      )
      throw DecodingError.dataCorrupted(context)
    }
  }

  func unbox(_ value: COSBase?, as type: UInt8.Type) throws -> UInt8? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: UInt8?
    switch value {
    case let number as COSInteger:
      result = type.init(exactly: number.intValue)
    case let number as COSFloat:
      let double = number.doubleValue
      result = double <= Double(type.max) && double >= Double(type.min)
        ? type.init(double)
        : nil
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }

    if let result = result {
      return result
    } else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "The number \(value) does not fit in \(type)."
      )
      throw DecodingError.dataCorrupted(context)
    }
  }

  func unbox(_ value: COSBase?, as type: UInt16.Type) throws -> UInt16? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: UInt16?
    switch value {
    case let number as COSInteger:
      result = type.init(exactly: number.intValue)
    case let number as COSFloat:
      let double = number.doubleValue
      result = double <= Double(type.max) && double >= Double(type.min)
        ? type.init(double)
        : nil
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }

    if let result = result {
      return result
    } else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "The number \(value) does not fit in \(type)."
      )
      throw DecodingError.dataCorrupted(context)
    }
  }

  func unbox(_ value: COSBase?, as type: UInt32.Type) throws -> UInt32? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: UInt32?
    switch value {
    case let number as COSInteger:
      result = type.init(exactly: number.intValue)
    case let number as COSFloat:
      let double = number.doubleValue
      result = double <= Double(type.max) && double >= Double(type.min)
        ? type.init(double)
        : nil
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }

    if let result = result {
      return result
    } else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "The number \(value) does not fit in \(type)."
      )
      throw DecodingError.dataCorrupted(context)
    }
  }

  func unbox(_ value: COSBase?, as type: UInt64.Type) throws -> UInt64? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: UInt64?
    switch value {
    case let number as COSInteger:
      result = type.init(exactly: number.intValue)
    case let number as COSFloat:
      let double = number.doubleValue
      result = double <= Double(type.max) && double >= Double(type.min)
        ? type.init(double)
        : nil
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }

    if let result = result {
      return result
    } else {
      let context = DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "The number \(value) does not fit in \(type)."
      )
      throw DecodingError.dataCorrupted(context)
    }
  }

  func unbox(_ value: COSBase?, as type: Float.Type) throws -> Float? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: Float
    switch value {
    case let number as COSNumber:
      result = number.floatValue
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }
    return result
  }

  func unbox(_ value: COSBase?, as type: Double.Type) throws -> Double? {
    guard let value = value, !(value is COSNull) else { return nil }

    let result: Double
    switch value {
    case let number as COSNumber:
      result = number.doubleValue
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }
    return result
  }

  func unbox(_ value: COSBase?, as type: String.Type) throws -> String? {
    guard let value = value, !(value is COSNull) else { return nil }

    switch value {
    case let string as COSString:
      return string.string()
    case let name as COSName:
      return name.name
    default:
      throw DecodingError.typeMismatch(at: codingPath,
                                       expectation: type,
                                       reality: value)
    }
  }

  func unbox<T: Decodable>(_ value: COSBase?, as type: T.Type) throws -> T {
    storage.push(container: value ?? COSNull.null)
    defer { storage.popContainer() }
    return try type.init(from: self)
  }
}

extension CodingKey {
  fileprivate var cosName: COSName {
    return (self as? COSCodingKey)?.nameValue ?? COSName.getPDFName(stringValue)
  }
}

private struct _COSKey: COSCodingKey {

  var nameValue: COSName
  var intValue: Int?

  init(nameValue: COSName) {
    self.init(nameValue: nameValue, intValue: nil)
  }

  init(intValue: Int) {
    self.init(stringValue: "\(intValue)", intValue: intValue)
  }

  init(index: Int) {
    self.init(stringValue: "Index\(index)", intValue: index)
  }

  init(stringValue: String, intValue: Int?) {
    self.init(nameValue: COSName.getPDFName(stringValue), intValue: intValue)
  }

  init(nameValue: COSName, intValue: Int?) {
    self.nameValue = nameValue
    self.intValue = intValue
  }

  static let `super` = _COSKey(nameValue: .super)
}


extension EncodingError {
  /// Returns a `.invalidValue` error describing the given invalid
  /// floating-point value.
  ///
  ///
  /// - parameter value: The value that was invalid to encode.
  /// - parameter path: The path of `CodingKey`s taken to encode this value.
  /// - returns: An `EncodingError` with the appropriate path and debug
  ///            description.
  fileprivate static func invalidFloatingPointValue<T: FloatingPoint>(
    _ value: T,
    at codingPath: [CodingKey]
  ) -> EncodingError {
    let valueDescription: String
    if value == T.infinity {
      valueDescription = "\(T.self).infinity"
    } else if value == -T.infinity {
      valueDescription = "-\(T.self).infinity"
    } else {
      valueDescription = "\(T.self).nan"
    }

    let debugDescription = """
    Unable to encode \(valueDescription) directly in COS.
    """

    let context = EncodingError.Context(codingPath: codingPath,
                                        debugDescription: debugDescription)

    return .invalidValue(value, context)
  }
}

extension DecodingError {
  fileprivate static func typeMismatch(at path: [CodingKey],
                                       expectation: Any.Type,
                                       reality: COSBase?) -> DecodingError {
    let description = """
    Expected to decode \(expectation) but found \
    \(_typeDescription(of: reality ?? COSNull.null)) instead.
    """
    let context = Context(codingPath: path, debugDescription: description)
    return .typeMismatch(expectation, context)
  }

  /// Returns a description of the type of `value` appropriate for an error
  /// message.
  ///
  /// - parameter value: The value whose type to describe.
  /// - returns: A string describing `value`.
  /// - precondition: `value` is one of the types below.
  fileprivate static func _typeDescription(of value: COSBase) -> String {
    switch value {
    case is COSNull:
      return "a null value"
    case is COSNumber:
      return "a number"
    case is COSString:
      return "a string/data"
    case is COSName:
      return "a name"
    case is COSArray:
      return "an array"
    case is COSDictionary:
      return "a dictionary"
    default:
      return String(describing: type(of: value))
    }
  }
}
