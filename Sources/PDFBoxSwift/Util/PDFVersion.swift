//
//  PDFVersion.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

public enum PDFVersion: String {
  case v1_0 = "1.0"
  case v1_1 = "1.1"
  case v1_2 = "1.2"
  case v1_3 = "1.3"
  case v1_4 = "1.4"
  case v1_5 = "1.5"
  case v1_6 = "1.6"
  case v1_7 = "1.7"
}

extension PDFVersion: CustomStringConvertible {
  public var description: String {
    return rawValue
  }
}
