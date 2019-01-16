// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "PDFBoxSwift",
  products: [
    .library(name: "PDFBoxSwift", targets: ["PDFBoxSwift"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "PDFBoxSwift"),
    .testTarget(name: "PDFBoxSwiftCOSTests", dependencies: ["PDFBoxSwift"]),
    .testTarget(name: "PDFBoxSwiftIOTests", dependencies: ["PDFBoxSwift"]),
    .testTarget(name: "PDFBoxSwiftUtilTests", dependencies: ["PDFBoxSwift"]),
  ]
)
