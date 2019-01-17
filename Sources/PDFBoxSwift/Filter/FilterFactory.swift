//
//  FilterFactory.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 17/01/2019.
//

private let filters: [COSName : Filter] = [:]

public enum FilterFactory {

  public static func filter(forName name: COSName) throws -> Filter {
    guard let filter = filters[name] else {
      throw IOError.unknownFilter(name)
    }

    return filter
  }

  internal static func filter<T: Filter>(forName name: TypedCOSName<T>) -> T {
    return filters[name.key] as! T
  }

  public static let allSupportedFilters = Array(filters.values)
}
