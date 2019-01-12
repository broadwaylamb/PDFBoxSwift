//
//  TypedCOSName.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 11/01/2019.
//

/// The helper struct to allow strongly typed `COSDictionary` subscripting.
///
/// You can extend this struct to provide common values of your names.
public struct TypedCOSName<T> {
  /// The key in a dictionary
  public let key: COSName
  public init(key: COSName) {
    self.key = key
  }
}

// MARK: - PDF spec: Table 5 – Entries common to all stream dictionaries

extension TypedCOSName where T == Int {

  /// *(Required)* The number of bytes from the beginning of the line following
  /// the keyword **stream** to the last byte just before the keyword
  /// **endstream**. (There may be an additional EOL marker, preceding
  /// **endstream**, that is not included in the count and is not logically
  /// part of the stream data.)
  /// See PDF spec 7.3.8.2, "Stream Extent", for further discussion.
  public static let length = TypedCOSName(key: .length)

  /// **(Optional; PDF 1.5)** A non-negative integer representing the number
  /// of bytes in the decoded (defiltered) stream. It can be used to determine,
  /// for example, whether enough disk space is available to write a stream to
  /// a file.
  ///
  /// This value shall be considered a hint only; for some stream filters,
  /// it may not be possible to determine this value precisely.
  public static let dl = TypedCOSName(key: .dl)
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

// MARK: - PDF spec: Table 6 – Standard filters

extension TypedCOSName where T == Void {

  /// Decodes data encoded in an ASCII hexadecimal representation,
  /// reproducing the original binary data.
  public static let asciiHexDecode = TypedCOSName(key: .asciiHexDecode)

  /// Decodes data encoded in an ASCII base-85 representation,
  /// reproducing the original binary data.
  public static let ascii85Decode = TypedCOSName(key: .ascii85Decode)

  /// Decompresses data encoded using the LZW (Lempel-Ziv-Welch)
  /// adaptive compression method, reproducing the original text or binary data.
  public static let lzwDecode = TypedCOSName(key: .lzwDecode)

  /// **(PDF 1.2)** Decompresses data encoded using the zlib/deflate
  /// compression method, reproducing the original text or binary data.
  public static let flateDecode = TypedCOSName(key: .flateDecode)

  /// Decompresses data encoded using a byte-oriented run-length
  /// encoding algorithm, reproducing the original text or binary data
  /// (typically monochrome image data, or any data that contains frequent
  /// long runs of a single byte value).
  public static let runLengthDecode = TypedCOSName(key: .runLengthDecode)

  /// Decompresses data encoded using the CCITT facsimile standard,
  /// reproducing the original data (typically monochrome image data at
  /// 1 bit per pixel).
  public static let ccittfaxDecode = TypedCOSName(key: .ccittfaxDecode)

  /// **(PDF1.4)** Decompresses data encoded using the JBIG2 standard,
  /// reproducing the original monochrome (1 bit per pixel) image data
  /// (or an approximation of that data).
  public static let jbig2Decode = TypedCOSName(key: .jbig2Decode)

  /// Decompresses data encoded using a DCT (discrete cosine transform)
  /// technique based on the JPEG standard, reproducing image sample data
  /// that approximates the original data.
  public static let dctDecode = TypedCOSName(key: .dctDecode)

  /// **(PDF 1.5)* Decompresses data encoded using the wavelet-based
  /// JPEG2000 standard, reproducing the original image data.
  public static let jpxDecode = TypedCOSName(key: .jpxDecode)

  /// **(PDF 1.5)* Decrypts data encrypted by a security handler,
  /// reproducing the data as it was before encryption.
  public static let crypt = TypedCOSName(key: .crypt)
}

// MARK: - PDF spec: Table 15 – Entries in the file trailer dictionary

extension TypedCOSName where T == Int {

  /// *(Required; shall not be an indirect reference)* The total number of
  /// entries in the file’s cross-reference table, as defined by the combination
  /// of the original section and all update sections. Equivalently, this value
  /// shall be 1 greater than the highest object number defined in the file.
  ///
  /// Any object in a cross-reference section whose number is greater than
  /// this value shall be ignored and defined to be missing by a conforming
  /// reader.
  public static let trailerSize = TypedCOSName(key: .size)

  /// *(Present only if the file has more than one cross-reference section;
  /// shall be an indirect reference)*
  /// The byte offset in the decoded stream from the beginning of the file to
  /// the beginning of the previous cross-reference section.
  public static let prev = TypedCOSName(key: .prev)
}

extension TypedCOSName where T == COSDictionary {

  /// *(Required; shall be an indirect reference)* The catalog dictionary for
  /// the PDF document contained in the file
  /// (see PDF spec 7.7.2, "Document Catalog").
  public static let root = TypedCOSName(key: .root)

  /// *(Required if document is encrypted; PDF 1.1)*
  /// The document’s encryption dictionary (see PDF spec 7.6, "Encryption").
  public static let encrypt = TypedCOSName(key: .encrypt)

  /// *(Optional; shall be an indirect reference)*
  /// The document’s information dictionary
  /// (see PDF spec 14.3.3, "Document Information Dictionary").
  public static let info = TypedCOSName(key: .info)
}

extension TypedCOSName where T == COSArray {

  /// *(Required if an Encrypt entry is present; optional otherwise;
  /// PDF 1.1)*
  /// An array of two byte-strings constituting a file identifier
  /// (see PDF spec 14.4, "File Identifiers") for the file.
  /// If there is an **Encrypt** entry this array and the two byte-strings
  /// shall be direct objects and shall be unencrypted.
  ///
  /// - Note: Because the **ID** entries are not encrypted it is possible to
  ///         check the **ID** key to assure that the correct file is being
  ///         accessed without decrypting the file. The restrictions that
  ///         the string be a direct object and not be encrypted assure that
  ///         this is possible.
  ///
  /// - Note: Although this entry is optional, its absence might prevent
  ///         the file from functioning in some workflows that depend on
  ///         files being uniquely identified.
  ///
  /// - Note: The values of the **ID** strings are used as input to
  ///         the encryption algorithm. If these strings were indirect, or if
  ///         the **ID** array were indirect, these strings would be encrypted
  ///         when written. This would result in a circular condition for
  ///         a reader: the **ID** strings must be decrypted in order to use
  ///         them to decrypt strings, including the **ID** strings themselves.
  ///         The preceding restriction prevents this circular condition.
  public static let id = TypedCOSName(key: .id)
}
