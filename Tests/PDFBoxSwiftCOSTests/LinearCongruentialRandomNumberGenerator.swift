//
//  LinearCongruentialRandomNumberGenerator.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 10/01/2019.
//

struct LinearCongruentialRandomNumberGenerator: RandomNumberGenerator {

  private var seed: UInt64

  init(seed: UInt64) {
    self.seed = seed
  }

  mutating func next() -> UInt64 {
    seed = (1103515245 * seed + 12345) % (1 << 31)
    return seed
  }
}
