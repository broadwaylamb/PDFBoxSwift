//
//  COSUpdateInfo.swift
//  COS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

public protocol COSUpdateInfo {

  /// The update state for the `COSWriter`. This indicates whether an object
  /// is to be written when there is an incremental save.
  var needsToBeUpdated: Bool { get set }
}
