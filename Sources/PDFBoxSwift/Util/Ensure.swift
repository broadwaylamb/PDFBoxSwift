//
//  Ensure.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 30/01/2019.
//

internal struct Ensure {

  internal private(set) var error: Error?

  internal init() {}

  internal mutating func `do`<R>(_ body: () throws -> R) -> R? {
    do {
      return try body()
    } catch {
      if self.error == nil {
        self.error = error
      }
    }
    return nil
  }

  func done() throws {
    if let error = error {
      throw error
    }
  }
}
