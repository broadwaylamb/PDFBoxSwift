//
//  COSCodingKey.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 02/02/2019.
//

public protocol COSCodingKey: CodingKey {
  var nameValue: COSName { get }
  init?(nameValue: COSName)
}

extension COSCodingKey {

  public var stringValue: String {
    return nameValue.name
  }

  public init?(stringValue: String) {
    self.init(nameValue: COSName.getPDFName(stringValue))
  }

  public var intValue: Int? {
    return nil
  }

  public init?(intValue: Int) {
    return nil
  }
}
