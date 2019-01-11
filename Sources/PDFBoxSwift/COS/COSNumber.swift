//
//  COSNumber.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// This class represents an abstract number in a PDF document.
public class COSNumber: COSBase {

  public struct ParseError: Error, CustomStringConvertible {
    public let description: String
    internal init(_ description: String) {
      self.description = description
    }
  }

  /// This will get the float value of this number.
  public var floatValue: Float {
    COSNumber.requiresConcreteImplementation()
  }

  /// This will get the double value of this number.
  public var doubleValue: Double {
    COSNumber.requiresConcreteImplementation()
  }

  /// This will get the integer value of this number.
  public var intValue: Int {
    COSNumber.requiresConcreteImplementation()
  }

  /// This factory method will get the appropriate number object.
  ///
  /// - Parameter string: The string representation of the number.
  /// - Returns: A number object, either `COSFloat` or `COSInteger`.
  /// - Throws: `COSNumber.ParseError` if `string` is not a number.
  public static func parse(_ string: String) throws -> COSNumber {

    if string.utf8.count == 1 {

      let digit = string.utf8.first!

      if "0" <= digit && digit <= "9" {
        return COSInteger.get(Int(digit - "0"))
      } else if digit == "-" || digit == "." {
        // See https://issues.apache.org/jira/browse/PDFBOX-592
        return COSInteger.zero
      } else {
        throw ParseError("Not a number: \(string)")
      }
    } else if !string.contains(".") && !string.lowercased().contains("e") {

      if string.first == "+" {
        guard let int = Int(string.dropFirst()) else {
          return try COSFloat(string: string)
        }
        return COSInteger.get(int)
      }

      guard let int = Int(string) else {
        return try COSFloat(string: string)
      }

      return COSInteger.get(int)
    } else {
      return try COSFloat(string: string)
    }
  }
}
