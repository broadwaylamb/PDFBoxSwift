// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "PDFBoxSwift",
  products: [
    .library(name: "PDFBoxSwift", targets: ["PDFBoxSwiftCOS"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "PDFBoxSwiftIO"),
    .target(name: "PDFBoxSwiftCOS",
            dependencies: ["PDFBoxSwiftIO"]),
    .target(name: "PDFBoxSwiftPDFWriter",
            dependencies: ["PDFBoxSwiftCOS, PDFBoxSwiftIO"]),
    .testTarget(name: "PDFBoxSwiftCOSTests",
                dependencies: ["PDFBoxSwiftCOS"]),
    ]
)
