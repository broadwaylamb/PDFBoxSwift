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
  associatedtype FromCOS: COSBase

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
    self.init(clamping: cosRepresentation.intValue)
  }
}

extension Int32: ConvertibleFromCOS {
  public init(cosRepresentation: COSInteger) {
    self.init(clamping: cosRepresentation.intValue)
  }
}

extension Int64: ConvertibleFromCOS {
  public init(cosRepresentation: COSInteger) {
    self.init(cosRepresentation.intValue)
  }
}

extension UInt64: ConvertibleFromCOS {
  public init(cosRepresentation: COSInteger) {
    self.init(clamping: cosRepresentation.intValue)
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

extension PDFEncryption.Version: ConvertibleFromCOS {
  public init(cosRepresentation: COSInteger) {
    self = PDFEncryption.Version(
      rawValue: Int(clamping: cosRepresentation.intValue)
    ) ?? .undocumentedUnsupported
  }
}

extension PDFEncryption.Filter: ConvertibleFromCOS {
  public init(cosRepresentation: COSName) {
    self.init(rawValue: cosRepresentation)
  }
}

extension PDFEncryption.SubFilter: ConvertibleFromCOS {
  public init(cosRepresentation: COSName) {
    self.init(rawValue: cosRepresentation)
  }
}

extension PDFEncryption.Revision: ConvertibleFromCOS {
  public init(cosRepresentation: COSNumber) {
    self = PDFEncryption.Revision(
      rawValue: Int(clamping: cosRepresentation.intValue)
    ) ?? .r2
  }
}

extension PDFPermissions: ConvertibleFromCOS {
  public init(cosRepresentation: COSInteger) {
    self.init(rawValue: Int32(truncatingIfNeeded: cosRepresentation.intValue))
  }
}
