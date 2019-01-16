//
//  AtomicReference.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

#if !PDFBOX_NO_LIBDISPATCH
import Dispatch
#endif

internal final class AtomicReference<T> {

  private var synchronized: Synchronized<T>?

  init(_ value: T) {
    synchronized = Synchronized(value, lock: self)
  }

  var value: T {
    return synchronized!.value
  }

  func atomically(execute: (inout T) -> Void) {
    synchronized!.atomically(execute: execute)
  }
}

internal struct Synchronized<T> {

#if !PDFBOX_NO_LIBDISPATCH
  private let _syncQueue: DispatchQueue
#endif

  private var _value: T

  init(_ value: T, lock: AnyObject) {
    _value = value
#if !PDFBOX_NO_LIBDISPATCH
    _syncQueue = DispatchQueue(
      label: "com.PDFBoxSwift.Synchronized.\(ObjectIdentifier(lock))",
      attributes: .concurrent
    )
#endif
  }

  var value: T {
#if !PDFBOX_NO_LIBDISPATCH
    return _syncQueue.sync { return _value }
#else
    return _value
#endif
  }

  mutating func atomically<Result>(
    execute: (inout T) throws -> Result
  ) rethrows -> Result {
#if !PDFBOX_NO_LIBDISPATCH
    return try _syncQueue.sync(flags: .barrier) {
      try execute(&_value)
    }
#else
    return try execute(&_value)
#endif
  }

  mutating func nonatomically<Result>(
    execute: (inout T) throws -> Result
  ) rethrows -> Result {
    return try execute(&_value)
  }
}
