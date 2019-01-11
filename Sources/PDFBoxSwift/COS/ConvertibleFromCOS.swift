//
//  ConvertibleFromCOS.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 11/01/2019.
//

/// This protocol is for native values that have their corresponding
/// COS value.
///
/// You can conform your types to this protocol do define a strategy of
/// converting a COS object to your types.
public protocol ConvertibleFromCOS {
  associatedtype FromCOS: COSObjectable

  /// A strategy of converting a COS object to the conforming type.
  init(cosRepresentation: FromCOS)
}

extension Bool: ConvertibleFromCOS {
  public init(cosRepresentation: COSBoolean) {
    self = cosRepresentation.value
  }
}

extension Int: ConvertibleFromCOS {
  public init(cosRepresentation: COSInteger) {
    self = cosRepresentation.intValue
  }
}

extension Float: ConvertibleFromCOS {
  public init(cosRepresentation: COSFloat) {
    self = cosRepresentation.floatValue
  }
}

extension String: ConvertibleFromCOS {
  public init(cosRepresentation: COSString) {
    self = cosRepresentation.string()
  }
}
