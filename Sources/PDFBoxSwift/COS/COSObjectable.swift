//
//  COSObjectConvertible.swift
//  COS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// This is a protocol used to get/create the underlying COSObject.
public protocol COSObjectable {

  /// Convert this object to a COS object.
  ///
  /// - Returns: The COS object that matches this object.
  var cosObject: COSBase { get }
}
