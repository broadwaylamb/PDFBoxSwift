//
//  AtomicReference.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

import Dispatch

internal final class AtomicReference<T> {

  private lazy var _syncQueue = DispatchQueue(
    label: "com.PDFBoxSwift.AtomicReference.\(ObjectIdentifier(self))",
    attributes: .concurrent
  )

  private var _value: T

  init(_ value: T) {
    _value = value
  }

  var value: T {
    return _syncQueue.sync { return _value }
  }

  func atomically(execute: (inout T) -> Void) {
    _syncQueue.sync(flags: .barrier) {
      execute(&_value)
    }
  }
}
