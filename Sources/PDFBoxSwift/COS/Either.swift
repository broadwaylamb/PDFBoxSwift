//
//  Either.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 11/01/2019.
//

public enum Either<Left, Right> {
  case left(Left)
  case right(Right)

  public init(_ value: Left) {
    self = .left(value)
  }

  public init(_ value: Right) {
    self = .right(value)
  }
}

extension Either: Equatable where Left: Equatable, Right: Equatable {}

extension Either: Hashable where Left: Hashable, Right: Hashable {}

extension Either: COSObjectable
    where Left: COSObjectable, Right: COSObjectable {

  public var cosObject: COSBase {
    switch self {
    case .left(let left):
      return left.cosObject
    case .right(let right):
      return right.cosObject
    }
  }
}

extension Either: ConvertibleToCOS
    where Left: ConvertibleToCOS, Left: COSObjectable,
          Right: ConvertibleToCOS, Right: COSObjectable {

  public typealias ToCOS = Either<Left.ToCOS, Right.ToCOS>

  public var cosRepresentation: ToCOS {
    switch self {
    case .left(let left):
      return .left(left.cosRepresentation)
    case .right(let right):
      return .right(right.cosRepresentation)
    }
  }
}

extension Either: ConvertibleFromCOS
    where Left: ConvertibleFromCOS, Right: ConvertibleFromCOS {

  public typealias FromCOS = Either<Left.FromCOS, Right.FromCOS>

  public init(cosRepresentation: FromCOS) {
    switch cosRepresentation {
    case .left(let left):
      self = .left(Left(cosRepresentation: left))
    case .right(let right):
      self = .right(Right(cosRepresentation: right))
    }
  }
}
