//
//  LinkedList.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

private final class LinkedListStorage<Element> {

  final class Node {
    var value: Element
    var next: Node?
    weak var previous: Node?

    init(value: Element) {
      self.value = value
    }
  }

  var nodes: (first: Node, last: Node)?

  private(set) var count: Int

  init() {
    count = 0
  }

  func append(_ element: Element) {
    let newNode = Node(value: element)
    if let nodes = nodes {
      nodes.last.next = newNode
      newNode.previous = nodes.last
      self.nodes = (nodes.first, newNode)
    } else {
      nodes = (newNode, newNode)
    }

    count += 1
  }

  func prepend(_ element: Element) {
    let newNode = Node(value: element)
    if let nodes = nodes {
      nodes.first.previous = newNode
      newNode.next = nodes.first
      self.nodes = (newNode, nodes.last)
    } else {
      nodes = (newNode, newNode)
    }

    count += 1
  }

  func popFirst() -> Element? {

    guard let nodes = nodes else { return nil }

    let element = nodes.first.value
    
    let secondNode = nodes.first.next
    secondNode?.previous = nil

    self.nodes = secondNode.map { ($0, nodes.last) }

    count -= 1

    return element
  }

  func popLast() -> Element? {

    guard let nodes = nodes else { return nil }

    let element = nodes.last.value

    let beforeLastNode = nodes.last.previous
    beforeLastNode?.next = nil

    self.nodes = beforeLastNode.map { (nodes.first, $0) }

    count -= 1

    return element
  }
}

/// A double-ended queue.
///
/// All enqueuing and dequeuing operations are O(1).
internal struct LinkedList<Element> {

  private let isReversed: Bool
  private var storage: LinkedListStorage<Element>

  private init(isReversed: Bool, storage: LinkedListStorage<Element>) {
    self.isReversed = isReversed
    self.storage = storage
  }

  init() {
    self.init(isReversed: false, storage: .init())
  }

  mutating func append(_ element: Element) {
    copyStorageIfNeeded()

    if isReversed {
      storage.prepend(element)
    } else {
      storage.append(element)
    }
  }

  mutating func prepend(_ element: Element) {
    copyStorageIfNeeded()

    if isReversed {
      storage.append(element)
    } else {
      storage.prepend(element)
    }
  }

  @discardableResult
  mutating func popFirst() -> Element? {
    copyStorageIfNeeded()

    if isReversed {
      return storage.popLast()
    } else {
      return storage.popFirst()
    }
  }

  @discardableResult
  mutating func popLast() -> Element? {
    copyStorageIfNeeded()

    if isReversed {
      return storage.popFirst()
    } else {
      return storage.popLast()
    }
  }

  mutating func append<S: Sequence>(contentsOf sequence: S)
      where S.Element == Element{

    for element in sequence {
      append(element)
    }
  }

  var count: Int {
    return storage.count
  }

  var isEmpty: Bool {
    return count == 0
  }

  private mutating func copyStorageIfNeeded() {
    guard !isKnownUniquelyReferenced(&storage) else {
      return
    }

    let newStorage = LinkedListStorage<Element>()
    for element in LinkedList(isReversed: false, storage: storage) {
      newStorage.append(element)
    }

    storage = newStorage
  }

  func reversed() -> LinkedList<Element> {
    return LinkedList(isReversed: !isReversed, storage: storage)
  }
}

extension LinkedList: ExpressibleByArrayLiteral {

  init(arrayLiteral elements: Element...) {
    self.init()
    append(contentsOf: elements)
  }
}

extension LinkedList: Sequence {

  internal struct Iterator: IteratorProtocol {

    private var node: LinkedListStorage<Element>.Node?
    private var isReversed: Bool

    fileprivate init(_ node: LinkedListStorage<Element>.Node?,
                     isReversed: Bool) {
      self.node = node
      self.isReversed = isReversed
    }

    mutating func next() -> Element? {
      defer {
        node = isReversed ? node?.previous : node?.next
      }
      return node?.value
    }
  }

  func makeIterator() -> Iterator {
    return Iterator(isReversed ? storage.nodes?.last : storage.nodes?.first,
                    isReversed: isReversed)
  }

  var underestimatedCount: Int {
    return count
  }
}

extension LinkedList: CustomStringConvertible {
  var description: String {
    return debugDescription
  }
}

extension LinkedList: CustomDebugStringConvertible {
  var debugDescription: String {
    return "[\(lazy.map(String.init(describing:)).joined(separator: ", "))]"
  }
}

extension LinkedList: Equatable where Element: Equatable {

  static func == (lhs: LinkedList, rhs: LinkedList) -> Bool {

    if lhs.storage === rhs.storage && lhs.isReversed == rhs.isReversed {
      return true
    }

    guard lhs.count == rhs.count else {
      return false
    }

    return zip(lhs, rhs).allSatisfy(==)
  }
}

extension LinkedList: Hashable where Element: Hashable {
  func hash(into hasher: inout Hasher) {
    for element in self {
      hasher.combine(element)
    }
  }
}
