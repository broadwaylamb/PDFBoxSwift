//
//  TypedCOSName.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 11/01/2019.
//

/// The helper struct to allow strongly typed `COSDictionary` subscripting.
///
/// You can extend this struct to provide common values of your names.
public struct TypedCOSName<T: ConvertibleToCOS> {
  /// The key in a dictionary
  public let key: COSName
  public init(key: COSName) {
    self.key = key
  }
}

extension TypedCOSName where T == Int {

  /// *(Required)* The number of bytes from the beginning of the line following
  /// the keyword **stream** to the last byte just before the keyword
  /// **endstream**. (There may be an additional EOL marker, preceding
  /// **endstream**, that is not included in the count and is not logically
  /// part of the stream data.)
  /// See PDF spec 7.3.8.2, "Stream Extent", for further discussion.
  public static let length = TypedCOSName(key: .length)
}

extension TypedCOSName where T == Either<COSName, COSArray> {

  /// *(Optional)* The name of a filter that shall be applied in processing
  /// the stream data found between the keywords **stream** and **endstream**,
  /// or an array of zero, one or several names. Multiple filters shall be
  /// specified in the order in which they are to be applied.
  public static let filter = TypedCOSName(key: .filter)

  /// **(Optional; PDF 1.2)** The name of a filter to be applied in processing
  /// the data found in the stream’s external file, or an array of zero, one or
  /// several such names. The same rules apply as for **Filter**.
  public static let fFilter = TypedCOSName(key: .fFilter)
}

extension TypedCOSName where T == Either<COSDictionary, COSArray> {

  /// *(Optional)* A parameter dictionary or an array of such dictionaries,
  /// used by the filters specified by **Filter**. If there is only one
  /// filter and that filter has parameters, **DecodeParms** shall be set to
  /// the filter’s parameter dictionary unless all the filter’s parameters
  /// have their default values, in which case the **DecodeParms** entry may be
  /// omitted. If there are multiple filters and any of the filters has
  /// parameters set to nondefault values, **DecodeParms** shall be an array
  /// with one entry for each filter: either the parameter dictionary for that
  /// filter, or the null object if that filter has no parameters (or if all
  /// of its parameters have their default values). If none of the filters have
  /// parameters, or if all their parameters have default values,
  /// the **DecodeParms** entry may be omitted.
  public static let decodeParms = TypedCOSName(key: .decodeParms)

  /// **(Optional; PDF 1.2)** A parameter dictionary, or an array of such
  /// dictionaries, used by the filters specified by **FFilter**.
  /// The same rules apply as for **DecodeParms**.
  public static let fDecodeParms = TypedCOSName(key: .fDecodeParms)
}
