//
//  Either.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 11/01/2019.
//

public enum Either<Left, Right> {
  case left(Left)
  case right(Right)

  @inlinable // Inlinable as trivially forwarding and generic
  public init(_ value: Left) {
    self = .left(value)
  }

  @inlinable // Inlinable as trivially forwarding and generic
  public init(_ value: Right) {
    self = .right(value)
  }

  @inlinable // Inlinable as trivially forwarding and generic
  public func mapLeft<U>(
    _ transform: (Left
  ) throws -> U) rethrows -> Either<U, Right> {
    switch self {
    case .left(let left):
      return try .left(transform(left))
    case .right(let right):
      return .right(right)
    }
  }

  @inlinable // Inlinable as trivially forwarding and generic
  public func mapRight<U>(
    _ transform: (Right
    ) throws -> U) rethrows -> Either<Left, U> {
    switch self {
    case .left(let left):
      return .left(left)
    case .right(let right):
      return try .right(transform(right))
    }
  }

  @inlinable // Inlinable as trivially forwarding and generic
  public func transform<U>(ifLeft: (Left) throws -> U,
                           ifRight: (Right) throws -> U) rethrows -> U {
    switch self {
    case let .left(left):
      return try ifLeft(left)
    case let .right(right):
      return try ifRight(right)
    }
  }
}

extension Either: Equatable where Left: Equatable, Right: Equatable {}

extension Either: Hashable where Left: Hashable, Right: Hashable {}
