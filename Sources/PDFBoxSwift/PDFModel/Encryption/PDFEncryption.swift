//
//  PDFEncryption.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 29/01/2019.
//

/// This class is a specialized view of the encryption dictionary of
/// a PDF document. It contains a low level dictionary (`COSDictionary`) and
/// provides the methods to manage its fields. The available fields are the ones
/// who are involved by standard security handler and public key security
/// handler.
public final class PDFEncryption {

  /// A code specifying the algorithm to be used in encrypting and decrypting
  /// the document:
  ///
  /// - `undocumentedUnsupported`: An algorithm that is undocumented. This value
  ///   shall not be used.
  /// - `algorithm40Bit`: "Algorithm 1: Encryption of data using the RC4 or AES
  ///   algorithms" in 7.6.2, "General Encryption Algorithm," with an encryption
  ///   key length of 40 bits.
  /// - `algorithmVariableLength`: *(PDF 1.4)* "Algorithm 1: Encryption of data
  ///   using the RC4 or AES algorithms" in 7.6.2,
  ///   "General Encryption Algorithm," but permitting encryption key lengths
  ///   greater than 40 bits.
  /// - `unpublishedAlgorithm`: *(PDF 1.4)* An unpublished algorithm that
  ///   permits encryption key lengths ranging from 40 to 128 bits. This value
  ///   shall not appear in a conforming PDF file.
  /// - `securityHandler`: *(PDF 1.5)* The security handler defines the use of
  ///   encryption and decryption in the document, using the rules specified by
  ///   the **CF**, **StmF**, and **StrF** entries.
  public enum Version: Int, Codable, CaseIterable {

    /// An algorithm that is undocumented. This value shall not be used.
    case undocumentedUnsupported = 0

    /// Algorithm 1: Encryption of data using the RC4 or AES algorithms"
    /// in 7.6.2, "General Encryption Algorithm," with an encryption key length
    /// of 40 bits.
    case algorithm40Bit = 1

    /// *(PDF 1.4)* "Algorithm 1: Encryption of data using the RC4 or AES
    /// algorithms" in 7.6.2, "General Encryption Algorithm," but permitting
    /// encryption key lengths greater than 40 bits.
    case algorithmVariableLength = 2

    /// *(PDF 1.4)* An unpublished algorithm that permits encryption key lengths
    /// ranging from 40 to 128 bits. This value shall not appear in a conforming
    /// PDF file.
    case unpublishedAlgorithm = 3

    /// *(PDF 1.5)* The security handler defines the use of encryption and
    /// decryption in the document, using the rules specified by the **CF**,
    /// **StmF**, and **StrF** entries.
    case securityHandler = 4
  }

  public struct Filter: Codable, RawRepresentable, Hashable {
    public var rawValue: COSName
    public init(rawValue: COSName) {
      self.rawValue = rawValue
    }
  }

  public struct SubFilter: Codable, RawRepresentable, Hashable {
    public var rawValue: COSName
    public init(rawValue: COSName) {
      self.rawValue = rawValue
    }
  }

  /// A number specifying which revision of the standard security handler shall
  /// be used to interpret this dictionary
  ///
  /// - `r2`: If the document is encrypted with a **V** value less than 2
  ///   (see PDF spec Table 20) and does not have any of the access permissions
  ///   set to 0 (by means of the **P** entry) that are designated “Security
  ///   handlers of revision 3 or greater” in Table 22.
  /// - `r3`: If the document is encrypted with a **V** value of 2 or 3, or has
  ///   any “Security handlers of revision 3 or greater” access permissions set
  ///   to 0.
  /// - `r4`: If the document is encrypted with a **V** value of 4.
  public enum Revision: Int, Codable, CaseIterable {

    /// If the document is encrypted with a **V** value less than 2
    /// (see PDF spec Table 20) and does not have any of the access permissions
    /// set to 0 (by means of the **P** entry) that are designated “Security
    /// handlers of revision 3 or greater” in Table 22.
    case r2 = 2

    /// If the document is encrypted with a **V** value of 2 or 3, or has
    /// any “Security handlers of revision 3 or greater” access permissions set
    /// to 0.
    case r3 = 3

    /// If the document is encrypted with a **V** value of 4.
    case r4 = 4
  }

  /// The encryption dictionary.
  public let dictionary: COSDictionary

  public var securityHandler: SecurityHandler?

  /// Creates a new empty encryption dictionary.
  public init() {
    dictionary = COSDictionary()
  }

  /// Creates a new encryption dictionary from the low level dictionary
  /// provided.
  ///
  /// - Parameter dictionary: A COS encryption dictionary.
  public init(dictionary: COSDictionary) {
    self.dictionary = dictionary

    // TODO
    fatalError("Encryption is not implemented yet")
  }

  public func getSecurityHandler() throws -> SecurityHandler {
    if let handler = securityHandler {
      return handler
    }

    throw IOError.missingSecurityHandler(filter: filter)
  }

  /// The **Filter** entry of the encryption dictionary.
  public var filter: Filter? {
    get {
      return dictionary[decode: .encryptionFilter]
    }
    set {
      dictionary[decode: .encryptionFilter] = newValue
    }
  }

  /// The **SubFilter** entry of the encryption dictionary.
  public var subFilter: SubFilter? {
    get {
      return dictionary[decode: .encryptionSubFilter]
    }
    set {
      dictionary[decode: .encryptionSubFilter] = newValue
    }
  }

  /// The **V** entry of the encryption dictionary.
  public var version: Version {
    get {
      return dictionary[native: .encryptionVersion,
                        default: .undocumentedUnsupported]
    }
    set {
      dictionary[decode: .encryptionVersion] = newValue
    }
  }

  /// The number of bits to use for the encryption algorithm.
  ///
  /// - Note: This value is used to decrypt the PDF document. If you change this
  ///   when the document is encrypted then decryption will fail!
  public var length: Int {
    get {
      return dictionary[native: .encryptionKeyLength, default: 40]
    }
    set {
      dictionary[decode: .encryptionKeyLength] = newValue
    }
  }

  /// The **R** entry of the encryption dictionary.
  ///
  /// - Note: This value is used to decrypt the PDF document. If you change this
  ///   when the document is encrypted then decryption will fail!
  public var revision: Revision {
    get {
      return dictionary[native: .securityHandlerRevision, default: .r2]
    }
    set {
      dictionary[decode: .securityHandlerRevision] = newValue
    }
  }

  /// The **O** entry in the standard encryption dictionary — a 32 byte array.
  public var ownerKey: [UInt8] {
    get {
      return dictionary[cos: .ownerKey]?.bytes ?? []
    }
    set {
      if newValue.isEmpty {
        dictionary[cos: .ownerKey] = nil
      } else {
        dictionary[cos: .ownerKey] = COSString(bytes: newValue)
      }
    }
  }

  /// The **U** entry in the standard encryption dictionary — a 32 byte array.
  public var userKey: [UInt8] {
    get {
      return dictionary[cos: .userKey]?.bytes ?? []
    }
    set {
      if newValue.isEmpty {
        dictionary[cos: .userKey] = nil
      } else {
        dictionary[cos: .userKey] = COSString(bytes: newValue)
      }
    }
  }

  /// The **OE** entry in the standard encryption dictionary — a 32 byte array.
  public var ownerEncryptionKey: [UInt8] {
    get {
      return dictionary[cos: .ownerEncryptionKey]?.bytes ?? []
    }
    set {
      if newValue.isEmpty {
        dictionary[cos: .ownerEncryptionKey] = nil
      } else {
        dictionary[cos: .ownerEncryptionKey] = COSString(bytes: newValue)
      }
    }
  }

  /// The **UE** entry in the standard encryption dictionary — a 32 byte array.
  public var userEncryptionKey: [UInt8] {
    get {
      return dictionary[cos: .userEncryptionKey]?.bytes ?? []
    }
    set {
      if newValue.isEmpty {
        dictionary[cos: .userEncryptionKey] = nil
      } else {
        dictionary[cos: .userEncryptionKey] = COSString(bytes: newValue)
      }
    }
  }

  public var permissions: PDFPermissions {
    get {
      return dictionary[native: .permissions]
    }
    set {
      dictionary[native: .permissions] = newValue
    }
  }

  /// **EncryptMetaData** dictionary info. Default is `true`.
  public var encryptMetaData: Bool {
    return dictionary[native: .encryptMetaData, default: true]
  }

  // TODO: This implementation is incomplete
}
