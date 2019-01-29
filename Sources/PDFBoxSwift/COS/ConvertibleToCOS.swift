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

  associatedtype ToCOS: COSBase

  /// A strategy of converting a value of the conforming type to a COS object.
  var cosRepresentation: ToCOS { get }
}

extension ConvertibleToCOS where Self: RawRepresentable,
                                 Self.RawValue: ConvertibleToCOS,
                                 Self.RawValue.ToCOS == ToCOS {

  public var cosRepresentation: ToCOS {
    return rawValue.cosRepresentation
  }
}

extension Bool: ConvertibleToCOS {
  public var cosRepresentation: COSBoolean {
    return COSBoolean.get(self)
  }
}

extension Int: ConvertibleToCOS {
  public var cosRepresentation: COSInteger {
    return COSInteger.get(Int64(self))
  }
}

extension Int32: ConvertibleToCOS {
  public var cosRepresentation: COSInteger {
    return COSInteger.get(Int64(self))
  }
}

extension Int64: ConvertibleToCOS {
  public var cosRepresentation: COSInteger {
    return COSInteger.get(self)
  }
}

extension UInt64: ConvertibleToCOS {
  public var cosRepresentation: COSInteger {
    return COSInteger.get(Int64(clamping: self))
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

extension PDFEncryption.Version: ConvertibleToCOS {
  public typealias ToCOS = COSInteger
}

extension PDFEncryption.Filter: ConvertibleToCOS {
  public typealias ToCOS = COSName
}

extension PDFEncryption.SubFilter: ConvertibleToCOS {
  public typealias ToCOS = COSName
}

extension PDFEncryption.Revision: ConvertibleToCOS {
  public var cosRepresentation: COSNumber {
    return COSInteger.get(rawValue)
  }
}

extension PDFPermissions: ConvertibleToCOS {
  public typealias ToCOS = COSInteger
}
