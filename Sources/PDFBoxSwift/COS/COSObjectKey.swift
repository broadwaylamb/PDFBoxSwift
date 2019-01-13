//
//  COSObjectKey.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

/// Object representing the physical reference to an indirect PDF object.
public struct COSObjectKey: Hashable {

  /// The object's ID
  public let number: Int

  /// The generation number.
  public var generation: Int

  /// Constructor.
  ///
  /// - Parameters:
  ///   - number: The object number.
  ///   - generation: The object generation number.
  public init(number: Int, generation: Int) {
    self.number = number
    self.generation = generation
  }

  /// Constructor.
  ///
  /// - Parameter object: The object that this key will represent.
  public init(object: COSObject) {
    self.init(number: object.objectNumber, generation: object.generationNumber)
  }
}

extension COSObjectKey: CustomStringConvertible {
  public var description: String {
    return debugDescription
  }
}

extension COSObjectKey: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "\(number) \(generation) R"
  }
}

extension COSObjectKey: Comparable {
  public static func < (lhs: COSObjectKey, rhs: COSObjectKey) -> Bool {
    // lexicographical comparison
    return (lhs.number, lhs.generation) < (rhs.number, rhs.generation)
  }
}
