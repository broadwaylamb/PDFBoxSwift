//
//  COSObjectConvertible.swift
//  COS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

@available(*, deprecated, renamed: "COSObjectConvertible")
public typealias COSObjectable = COSObjectConvertible

/// This is an interface used to get/create the underlying COSObject.
public protocol COSObjectConvertible {

  /// Convert this object to a COS object.
  ///
  /// - Returns: The COS object that matches this object.
  func getCOSObject() throws -> COSBase
}
