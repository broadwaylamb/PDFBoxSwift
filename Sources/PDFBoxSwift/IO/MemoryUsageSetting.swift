//
//  MemoryUsageSetting.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 14/01/2019.
//

/// Controls how memory/temporary files are used for buffering streams etc.
public struct MemoryUsageSetting: Hashable {

  public let useMainMemory: Bool

  /// Maximum size of main-memory in bytes to be used,
  /// or `nil` if unrestricted.
  public let maxMainMemoryBytes: UInt64?

  /// Maximum size of storage bytes to be used (main-memory and
  /// temporary files all together).
  public let maxStorageBytes: UInt64?

  /// Directory to be used for temporary files.
  public let tempFileDir: String?

  private init(useMainMemory: Bool,
               tempFileDir: String?,
               maxMainMemoryBytes: UInt64?,
               maxStorageBytes: UInt64?) {

    let useTempFile = tempFileDir != nil

    // do some checks; adjust values as needed to get consistent setting
    var locUseMainMemory = useTempFile ? useMainMemory : true
    var locMaxMainMemoryBytes = useMainMemory ? maxMainMemoryBytes : nil
    var locMaxStorageBytes = maxStorageBytes
      .flatMap { $0 > 0 ? maxStorageBytes : nil } ?? nil

    if locUseMainMemory && locMaxMainMemoryBytes == 0 {
      if useTempFile {
        locUseMainMemory = false
      } else {
        locMaxMainMemoryBytes = locMaxStorageBytes
      }
    }

    if locUseMainMemory, locMaxStorageBytes != nil,
       locMaxMainMemoryBytes == nil ||
       locMaxMainMemoryBytes! > locMaxStorageBytes! {
      locMaxStorageBytes = locMaxMainMemoryBytes
    }

    self.useMainMemory = locUseMainMemory
    self.tempFileDir = tempFileDir
    self.maxMainMemoryBytes = locMaxMainMemoryBytes
    self.maxStorageBytes = locMaxStorageBytes
  }

  /// `true` if temporary file is to be used. If this returns `false` it is
  /// ensured `useMainMemory` returns true.
  public var useTempFile: Bool {
    return tempFileDir != nil
  }

  /// Returns `true` if maximum main memory is restricted to a specific number
  /// of bytes.
  public var isMainMemoryRestricted: Bool {
    return maxMainMemoryBytes != nil
  }

  /// Returns `true` if maximum amount of storage is restricted to a specific
  /// number of bytes.
  public var isStorageRestricted: Bool {
    return maxStorageBytes.map { $0 > 0 } ?? false
  }

  /// Only use main-memory with the defined maximum.
  ///
  /// - Parameter maxMainMemoryBytes: Maximum number of main-memory to be used;
  ///                                 `nil` for no restriction; 0 will also be
  ///                                 interpreted here as no restriction.
  ///                                 Default value is `nil`.
  /// - Returns: The memory usage setting.
  public static func mainMemoryOnly(
    maxMainMemoryBytes: UInt64? = nil
  ) -> MemoryUsageSetting {
    return MemoryUsageSetting(useMainMemory: true,
                              tempFileDir: nil,
                              maxMainMemoryBytes: maxMainMemoryBytes,
                              maxStorageBytes: maxMainMemoryBytes)
  }

  /// Гse temporary file(s) (no main-memory) with the specified maximum size.
  ///
  /// - Parameters:
  ///   - tempDirectory: The directory to be used for temporary files.
  ///   - maxStorageBytes: Maximum size the temporary file(s) may have all
  ///                      together; `nil` for no restriction; 0 will also be
  ///                      interpreted here as no restriction.
  ///                      Default value is `nil`.
  /// - Returns: The memory usage setting.
  public static func tempFileOnly(
    tempDirectory: String,
    maxStorageBytes: UInt64? = nil
  ) -> MemoryUsageSetting {
    return MemoryUsageSetting(useMainMemory: false,
                              tempFileDir: tempDirectory,
                              maxMainMemoryBytes: 0,
                              maxStorageBytes: maxStorageBytes)
  }

  /// Use a portion of main-memory and additionally temporary file(s) in case
  /// the specified portion is exceeded.
  ///
  /// - Parameters:
  ///   - tempDirectory: The directory to be used for temporary files.
  ///   - maxMainMemoryBytes: Maximum number of main-memory to be used; if `nil`
  ///     this is the same as `MemoryUsageSetting.mainMemoryOnly()`; if 0 this
  ///     is the same as
  ///     `MemoryUsageSetting.tempFileOnly(tempDirectory: tempDirectory)`.
  ///   - maxStorageBytes: Maximum size the main-memory and temporary file(s)
  ///     may have all together; 0 or `nil` will be ignored; if it is less than
  ///     `maxMainMemoryBytes` we use `maxMainMemoryBytes` value instead.
  /// - Returns: The memory usage setting.
  public static func mixed(
    tempDirectory: String,
    maxMainMemoryBytes: UInt64?,
    maxStorageBytes: UInt64? = nil
  ) -> MemoryUsageSetting {
    return MemoryUsageSetting(useMainMemory: true,
                              tempFileDir: tempDirectory,
                              maxMainMemoryBytes: maxMainMemoryBytes,
                              maxStorageBytes: maxStorageBytes)
  }
}

extension MemoryUsageSetting: CustomStringConvertible {
  public var description: String {
    var string = String()
    if useMainMemory {
      if useTempFile {
        string.append(
          "Mixed mode with max. of \(maxMainMemoryBytes!) main memory bytes"
        )
        if isStorageRestricted {
          string.append(" and max. of \(maxStorageBytes!) storage bytes")
        } else {
          string.append(" and unrestricted scratch file size")
        }
      } else if isMainMemoryRestricted {
        string.append(
          "Main memory only with max. of \(maxMainMemoryBytes!) bytes"
        )
      } else {
        string.append("Main memory only with no size restriction")
      }
    } else if isStorageRestricted {
      string.append("Scratch file only with max. of \(maxStorageBytes!) bytes")
    } else {
      string.append("Scratch file only with no size restriction")
    }
    return string
  }
}
