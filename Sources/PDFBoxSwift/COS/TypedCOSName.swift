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

// MARK: - PDF spec: Table 252 – Entries in a signature dictionary
extension TypedCOSName where T == COSName {

  /// *(Required; inheritable)* The name of the preferred signature handler
  /// to use when validating this signature. If the **Prop_Build** entry is not
  /// present, it shall be also the name of the signature handler that was used
  /// to create the signature. If **Prop_Build** is present, it may be used to
  /// determine the name of the handler that created the signature (which is
  /// typically the same as **Filter** but is not needed to be). A conforming
  /// reader may substitute a different handler when verifying the signature,
  /// as long as it supports the specified **SubFilter** format. Example
  /// signature handlers are **Adobe.PPKLite**, **Entrust.PPKEF**,
  /// **CICI.SignIt**, and **VeriSign.PPKVS**. The name of the filter
  /// (i.e. signature handler) shall be identified in accordance with the rules
  /// defined in Annex E.
  public static let signatureFilter = TypedCOSName(key: .filter)

  /// *(Optional)* A name that describes the encoding of the signature value and
  /// key information in the signature dictionary. A conforming reader may use
  /// any handler that supports this format to validate the signature.
  ///
  /// *(PDF 1.6)* The following values for public-key cryptographic signatures
  /// shall be used: **adbe.x509.rsa_sha1**, **adbe.pkcs7.detached**, and
  /// **adbe.pkcs7.sha1** (see PDF spec 12.8.3, “Signature Interoperability”).
  /// Other values may be defined by developers, and when used, shall be
  /// prefixed with the registered developer identification. All prefix names
  /// shall be registered (see Annex E). The prefix “adbe” has been registered
  /// by Adobe Systems and the three subfilter names listed above and defined in
  /// 12.8.3, “Signature Interoperability“ may be used by any developer.
  public static let signatureSubFilter = TypedCOSName(key: .subFilter)
}

extension TypedCOSName where T == COSString {

  /// *(Required)* The signature value. When **ByteRange** is present, the value
  /// shall be a hexadecimal string (see PDF spec 7.3.4.3,
  /// “Hexadecimal Strings”) representing the value of the byte range digest.
  ///
  /// For public-key signatures, **Contents** should be either a DER-encoded
  /// PKCS#1 binary data object or a DER-encoded PKCS#7 binary data object.
  ///
  /// Space for the **Contents** value must be allocated before the message
  /// digest is computed. (See PDF spec 7.3.4, “String Objects“)
  public static let signatureContents = TypedCOSName(key: .contents)
}

extension TypedCOSName where T == Either<COSArray, COSString> {

  /// *(Required when SubFilter is adbe.x509.rsa_sha1)* An array of byte strings
  /// that shall represent the X.509 certificate chain used when signing and
  /// verifying signatures that use public-key cryptography, or a byte string if
  /// the chain has only one entry. The signing certificate shall appear first
  /// in the array; it shall be used to verify the signature value in
  /// **Contents**, and the other certificates shall be used to verify
  /// the authenticity of the signing certificate.
  ///
  /// If **SubFilter** is ***adbe.pkcs7.detached*** or ***adbe.pkcs7.sha1***,
  /// this entry shall not be used, and the certificate chain shall be put in
  /// the PKCS#7 envelope in **Contents**.
  public static let signatureCert = TypedCOSName(key: .cert)
}

extension TypedCOSName where T == COSArray {

  /// *(Required for all signatures that are part of a signature field and
  /// usage rights signatures referenced from the UR3 entry in
  /// the permissions dictionary)* An array of pairs of integers (starting byte
  /// offset, length in bytes) that shall describe the exact byte range for
  /// the digest calculation. Multiple discontiguous byte ranges shall be used
  /// to describe a digest that does not include the signature value
  /// (the **Contents** entry) itself.
  public static let signatureByteRange = TypedCOSName(key: .byteRange)

  /// *(Optional; PDF 1.5)* An array of signature reference dictionaries
  /// (see Table 253).
  public static let signatureReference = TypedCOSName(key: .reference)

  /// *(Optional)* An array of three integers that shall specify changes to
  /// the document that have been made between the previous signature and this
  /// signature, in this order: the number of pages altered, the number of
  /// fields altered, and the number of fields filled in.
  ///
  /// The ordering of signatures shall be determined by the value of
  /// **ByteRange**. Since each signature results in an incremental save,
  /// later signatures have a greater length value.
  public static let signatureChanges = TypedCOSName(key: .changes)
}

extension TypedCOSName where T == COSString {

  /// *(Optional)* The name of the person or authority signing the document.
  /// This value should be used only when it is not possible to extract
  /// the name from the signature.
  public static let signatureName = TypedCOSName(key: .name)
}

extension TypedCOSName where T == PDFDate {

  /// *(Optional)* The time of signing. Depending on the signature handler, this
  /// may be a normal unverified computer time or a time generated in
  /// a verifiable way from a secure time server.
  ///
  /// This value should be used only when the time of signing is not available
  /// in the signature.
  public static let signatureTime = TypedCOSName(key: .m)
}

extension TypedCOSName where T == COSString {

  /// *(Optional)* The CPU host name or physical location of the signing.
  public static let signatureLocation = TypedCOSName(key: .location)

  /// *(Optional)* The reason for the signing, such as (I agree...).
  public static let signatureReason = TypedCOSName(key: .reason)

  /// *(Optional)* Information provided by the signer to enable a recipient
  /// to contact the signer to verify the signature.
  public static let signatureContactInfo = TypedCOSName(key: .contactInfo)
}

extension TypedCOSName where T == Int {

  /// *(Optional)* The version of the signature handler that was used to create
  /// the signature. *(PDF 1.5)* This entry shall not be used, and the information
  /// shall be stored in the Prop_Build dictionary.
  public static let signatureHandlerVersion = TypedCOSName(key: .r)

  /// *(Optional; PDF 1.5)* The version of the signature dictionary format.
  /// It corresponds to the usage of the signature dictionary in the context of
  /// the value of **SubFilter**. The value is 1 if the **Reference** dictionary
  /// shall be considered critical to the validation of the signature.
  ///
  /// Default value: 0.
  public static let signatureDictionaryFormatVersion = TypedCOSName(key: .v)
}

extension TypedCOSName where T == COSDictionary {

  /// *(Optional; PDF 1.5)* A dictionary that may be used by a signature handler
  /// to record information that captures the state of the computer environment
  /// used for signing, such as the name of the handler used to create
  /// the signature, software build date, version, and operating system.
  ///
  /// The PDF Signature Build Dictionary Specification provides implementation
  /// guidelines for the use of this dictionary.
  public static let signaturePropBuild = TypedCOSName(key: .propBuild)
}

extension TypedCOSName where T == Int {

  /// *(Optional; PDF 1.5)* The number of seconds since the signer was last
  /// authenticated, used in claims of signature repudiation. It should be
  /// omitted if the value is unknown.
  public static let signaturePropAuthTime = TypedCOSName(key: .propAuthTime)
}

extension TypedCOSName where T == COSName {

  /// *(Optional; PDF 1.5)* The method that shall be used to authenticate
  /// the signer, used in claims of signature repudiation. Valid values shall
  /// be PIN, Password, and Fingerprint.
  public static let signaturePropAuthType = TypedCOSName(key: .propAuthType)
}

// MARK: - Common names
extension TypedCOSName where T == COSName {

  /// (Optional) The type of PDF object that this dictionary describes.
  public static let type = TypedCOSName(key: .type)
}
