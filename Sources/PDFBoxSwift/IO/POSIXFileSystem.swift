//
//  POSIXFileSystem.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 16/01/2019.
//

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

#if canImport(Darwin) || canImport(Glibc)

public final class POSIXFileSystem: FileSystem {

  private init() {}

  public static let `default` = POSIXFileSystem()

  public func isDirectory(_ path: String) throws -> Bool {
    let stat = try getStat(path)
    return stat.st_mode & S_IFMT == S_IFDIR
  }

  public var temporaryDirectory: String {
#if canImport(Darwin)
    var buf = [CChar](repeating: 0, count: 100)
    let r = confstr(_CS_DARWIN_USER_TEMP_DIR, &buf, buf.count)
    if r != 0 && r < buf.count {
      return buf.withUnsafeBufferPointer { String(cString: $0.baseAddress!) }
    }
#endif
    if let tmpdir = getenv("TMPDIR") {
      return normalizeDirectoryPath(String(cString: tmpdir))
    }
    return "/tmp/"
  }

  public func createTemporaryFile(
    prefix: String,
    suffix: String,
    directory: String
  ) throws -> RandomAccessFile {

    let normalized = normalizeDirectoryPath(directory)
    let template = "\(normalized)\(prefix)XXXXXX\(suffix)"

    let templateSize = template.utf8.count + 1
    let templatePtr = UnsafeMutablePointer<CChar>
      .allocate(capacity: templateSize)
    defer { templatePtr.deallocate() }

    template.withCString {
      templatePtr.initialize(from: $0, count: templateSize)
    }

    let fd = mkstemps(templatePtr, CInt(suffix.utf8.count))
    let path = String(cString: templatePtr)
    
    return try BinaryFileExtendedOutputStream(path: path, descriptor: fd)
  }

  public func deleteFile(path: String) throws {
    try wrapSyscall { remove(path) }
  }
}

private func normalizeDirectoryPath<S: StringProtocol>(_ path: S) -> String {
  if !path.hasSuffix("/") {
    return path + "/"
  } else {
    return String(path)
  }
}

#endif
