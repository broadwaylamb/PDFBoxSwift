//
//  COSObject.swift
//  PDFBoxSwiftIO
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// This class represents a PDF object.
public final class COSObject: COSBase, COSUpdateInfo {

  public var needsToBeUpdated: Bool = false

  /// The object that this object refers to.
  public var object: COSBase

  /// The object number. Must be positive.
  public var objectNumber: Int {
    didSet {
      precondition(objectNumber > 0,
                   "An object number must be positive")
    }
  }

  /// The generation number. Must be nonnegative.
  public var generationNumber: Int {
    didSet {
      precondition(generationNumber >= 0,
                   "A generation number must be nonnegative")
    }
  }

  /// Constructor.
  ///
  /// - Parameters:
  ///   - object: The object that this object refers to.
  ///   - objectNumber: The object number. Must be positive.
  ///   - generationNumber: The generation number. Must be nonnegative.
  public init(object: COSBase,
              objectNumber: Int = 0,
              generationNumber: Int = 0) {
    self.object = object

    precondition(objectNumber > 0,
                 "An object number must be positive")
    precondition(generationNumber >= 0,
                 "A generation number must be nonnegative")

    self.objectNumber = objectNumber
    self.generationNumber = generationNumber
  }

  @discardableResult
  public override func accept(visitor: COSVisitorProtocol) throws -> Any? {
    return try object.accept(visitor: visitor)
  }
}

extension COSObject: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "COSObject{\(objectNumber), \(generationNumber)}"
  }
}
