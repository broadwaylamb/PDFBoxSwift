//
//  ConvertibleToCOS.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 11/01/2019.
//

/// This protocol is for native values that have their corresponding
/// COS value.
///
/// You can conform your types to this protocol do define a strategy of
/// converting a value of your type to a COS object.
public protocol ConvertibleToCOS {

  associatedtype ToCOS: COSObjectable

  /// A strategy of converting a value of the conforming type to a COS object.
  var cosRepresentation: ToCOS { get }
}

extension Bool: ConvertibleToCOS {
  public var cosRepresentation: COSBoolean {
    return COSBoolean.get(self)
  }
}

extension Int: ConvertibleToCOS {
  public var cosRepresentation: COSInteger {
    return COSInteger.get(self)
  }
}

extension Int32: ConvertibleToCOS {
  public var cosRepresentation: COSInteger {
    return COSInteger.get(Int(self))
  }
}

extension Float: ConvertibleToCOS {
  public var cosRepresentation: COSFloat {
    return COSFloat(value: self)
  }
}

extension String: ConvertibleToCOS {
  public var cosRepresentation: COSString {
    return COSString(text: self)
  }
}
