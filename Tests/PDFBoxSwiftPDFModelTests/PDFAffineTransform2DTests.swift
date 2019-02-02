//
//  PDFAffineTransform2DTests.swift
//  PDFBoxSwiftPDFModelTests
//
//  Created by Sergej Jaskiewicz on 02/02/2019.
//

import XCTest
import PDFBoxSwift

final class PDFAffineTransform2DTests: XCTestCase {

  static let allTests = [
    ("testAffineTransformDescription", testAffineTransformDescription),
    ("testMakeRotation", testMakeRotation),
    ("testMakeScale", testMakeScale),
    ("testMakeTranslation", testMakeTranslation),
    ("testConcatenate", testConcatenate),
    ("testInvert", testInvert),
    ("testConcatenateWithRotation", testConcatenateWithRotation),
    ("testConcatenateWithScaling", testConcatenateWithScaling),
    ("testConcatenateWithTranslation", testConcatenateWithTranslation),
    ("testApplyTransformToSize", testApplyTransformToSize),
    ("testApplyTransformToPoint", testApplyTransformToPoint)
  ]

  func testAffineTransformDescription() {

    // Given
    let transform = PDFAffineTransform2D(scaleX:     200,    shearY:     1,
                                         shearX:     12.333, scaleY:    -3,
                                         translateX: 0,      translateY: 1223)
    let expectedRepresentation = "[200.0, 1.0, 12.333, -3.0, 0.0, 1223.0]"

    // When
    let returnedRepresentation = transform.description

    // Then
    XCTAssertEqual(expectedRepresentation, returnedRepresentation)
  }

  func testMakeRotation() {

    // Given
    let expectedTransform1 = PDFAffineTransform2D(
      scaleX:    -0.903692185, shearY:    -0.428182662,
      shearX:     0.428182662, scaleY:    -0.903692185,
      translateX: 0,           translateY: 0
    )

    let expectedTransform2 = PDFAffineTransform2D.identity

    let expectedTransform3 = PDFAffineTransform2D.identity

    let expectedTransform4 = PDFAffineTransform2D(
      scaleX:     0.5,         shearY:    -0.866025388,
      shearX:     0.866025388, scaleY:     0.5,
      translateX: 0,           translateY: 0
    )

    // When
    let returnedTransform1 = PDFAffineTransform2D(rotationAngle: 35)
    let returnedTransform2 = PDFAffineTransform2D(rotationAngle: 0)
    let returnedTransform3 = PDFAffineTransform2D(rotationAngle: 2 * .pi)
    let returnedTransform4 = PDFAffineTransform2D(rotationAngle: -.pi / 3)

    // Then
    XCTAssertEqual(expectedTransform1, returnedTransform1)
    XCTAssertEqual(expectedTransform2, returnedTransform2)
    XCTAssertEqual(expectedTransform3, returnedTransform3)
    XCTAssertEqual(expectedTransform4, returnedTransform4)

    XCTAssertEqual(returnedTransform1.determinant, 1, accuracy: defaultAccuracy)
    XCTAssertEqual(returnedTransform2.determinant, 1, accuracy: defaultAccuracy)
    XCTAssertEqual(returnedTransform3.determinant, 1, accuracy: defaultAccuracy)
    XCTAssertEqual(returnedTransform4.determinant, 1, accuracy: defaultAccuracy)
  }

  func testMakeScale() {

    // Given
    let expectedTransform1 = PDFAffineTransform2D(scaleX:     2, shearY:     0,
                                                  shearX:     0, scaleY:     3,
                                                  translateX: 0, translateY: 0)

    let expectedTransform2 = PDFAffineTransform2D(scaleX:     0, shearY:     0,
                                                  shearX:     0, scaleY:     0,
                                                  translateX: 0, translateY: 0)

    let expectedTransform3 = PDFAffineTransform2D(scaleX:    -1, shearY:     0,
                                                  shearX:     0, scaleY:     1,
                                                  translateX: 0, translateY: 0)

    // When
    let returnedTransform1 = PDFAffineTransform2D(scaleX: 2, y: 3)
    let returnedTransform2 = PDFAffineTransform2D(scaleX: 0, y: 0)
    let returnedTransform3 = PDFAffineTransform2D(scaleX: -1, y: 1)
    let returnedTransform4 = PDFAffineTransform2D(scaleX: 1, y: 1)

    // Then
    XCTAssertEqual(expectedTransform1, returnedTransform1)
    XCTAssertEqual(expectedTransform2, returnedTransform2)
    XCTAssertEqual(expectedTransform3, returnedTransform3)
    XCTAssertTrue(returnedTransform4.isIdentity)

    XCTAssertEqual(returnedTransform1.determinant, 6,
                   accuracy: defaultAccuracy)
    XCTAssertEqual(returnedTransform2.determinant, 0,
                   accuracy: defaultAccuracy)
    XCTAssertEqual(returnedTransform3.determinant, -1,
                   accuracy: defaultAccuracy)
    XCTAssertEqual(returnedTransform4.determinant, 1,
                   accuracy: defaultAccuracy)
  }

  func testMakeTranslation() {

    // Given
    let expectedTransform1 = PDFAffineTransform2D(
      scaleX:     1,  shearY:     0,
      shearX:     0,  scaleY:     1,
      translateX: 12, translateY: 43
    )

    let expectedTransform2 = PDFAffineTransform2D.identity

    let expectedTransform3 = PDFAffineTransform2D(
      scaleX:      1, shearY:     0,
      shearX:      0, scaleY:     1,
      translateX: -4, translateY: 15
    )

    // When
    let returnedTransform1 = PDFAffineTransform2D(translationX:  12, y: 43)
    let returnedTransform2 = PDFAffineTransform2D(translationX:  0,  y: 0)
    let returnedTransform3 = PDFAffineTransform2D(translationX: -4,  y: 15)

    // Then
    XCTAssertEqual(expectedTransform1, returnedTransform1)
    XCTAssertEqual(expectedTransform2, returnedTransform2)
    XCTAssertEqual(expectedTransform3, returnedTransform3)
  }

  func testConcatenate() {

    // Given
    let transform11 = PDFAffineTransform2D(scaleX:     1,  shearY:     5,
                                           shearX:     4,  scaleY:     6,
                                           translateX: 12, translateY: 43)

    let transform12 = PDFAffineTransform2D(scaleX:     76, shearY:     4,
                                           shearX:     8,  scaleY:     51,
                                           translateX: 0,  translateY: 2)

    let expectedTransform1 = PDFAffineTransform2D(
      scaleX:     116,  shearY:     259,
      shearX:     352,  scaleY:     322,
      translateX: 1256, translateY: 2243
    )

    let expectedTransform2 = PDFAffineTransform2D(
      scaleX:     4,  shearY:     5,
      shearX:     9,  scaleY:     11,
      translateX: 44, translateY: 2
    )

    // When
    let returnedTransform1 = transform11 * transform12
    let returnedTransform2 = expectedTransform2 * .identity

    // Then
    XCTAssertEqual(expectedTransform1, returnedTransform1)
    XCTAssertEqual(expectedTransform2, returnedTransform2)
  }

  func testInvert() {

    // Given
    let transform1 = PDFAffineTransform2D(scaleX:     1,  shearY:     5,
                                          shearX:     4,  scaleY:     6,
                                          translateX: 12, translateY: 43)


    let expectedTransform1 = PDFAffineTransform2D(
      scaleX:     -0.428571428571429, shearY:      0.357142857142857,
      shearX:      0.285714285714286, scaleY:     -0.0714285714285714,
      translateX: -7.14285714285714,  translateY: -1.21428571428571
    )

    let expectedTransform2 = PDFAffineTransform2D(
      scaleX:     3,  shearY:     0,
      shearX:     5,  scaleY:     2,
      translateX: 10, translateY: 1
    )

    let expectedInvertedDegenerateTransform = PDFAffineTransform2D(
      scaleX:     1,  shearY:     5,
      shearX:     1,  scaleY:     5,
      translateX: 12, translateY: 43
    )

    // When
    let returnedTransform1 = transform1.inverted()
    let returnedTransform2 = expectedTransform2.inverted()?.inverted()
    let returnedInvertedDegenerateTransform =
      expectedInvertedDegenerateTransform.inverted()

    // Then
    XCTAssertEqual(expectedTransform1, returnedTransform1)
    XCTAssertEqual(expectedTransform2, returnedTransform2)
    XCTAssertNil(returnedInvertedDegenerateTransform)
  }

  func testConcatenateWithRotation() {

    // Given
    let transform1 = PDFAffineTransform2D(scaleX:     1,  shearY:     5,
                                          shearX:     4,  scaleY:     6,
                                          translateX: 12, translateY: 43)

    let expectedTransform1 = PDFAffineTransform2D(
      scaleX:    -2.61642289, shearY:    -7.08755684,
      shearX:    -3.18658614, scaleY:    -3.28123975,
      translateX: 12,         translateY: 43
    )

    let transform2 = PDFAffineTransform2D(scaleX:     1,  shearY:     0,
                                          shearX:     3,  scaleY:     2,
                                          translateX: 12, translateY: 43)

    let expectedTransform2 = PDFAffineTransform2D(
      scaleX:    -1,  shearY:     0,
      shearX:    -3,  scaleY:    -2,
      translateX: 12, translateY: 43
    )

    // When
    let returnedTransform1 = transform1.rotated(byAngle: 35)
    let returnedTransform2 = transform2.rotated(byAngle: .pi)

    // Then
    XCTAssertEqual(expectedTransform1, returnedTransform1)
    XCTAssertEqual(expectedTransform2, returnedTransform2)
  }

  func testConcatenateWithScaling() {

    // Given
    let transform1 = PDFAffineTransform2D(scaleX:     1,  shearY:     5,
                                          shearX:     4,  scaleY:     6,
                                          translateX: 12, translateY: 43)

    let expectedTransform1 = PDFAffineTransform2D(
      scaleX:     2.6, shearY:     13.0,
      shearX:     1.6, scaleY:     2.4,
      translateX: 12,  translateY: 43
    )

    let transform2 = PDFAffineTransform2D(scaleX:     1,  shearY:     0,
                                          shearX:     3,  scaleY:     2,
                                          translateX: 12, translateY: 43)

    let expectedTransform2 = PDFAffineTransform2D(
      scaleX:    -1,  shearY:     0,
      shearX:     3,  scaleY:     2,
      translateX: 12, translateY: 43
    )

    // When
    let returnedTransform1 = transform1.scaled(byX: 2.6, y: 0.4)
    let returnedTransform2 = transform2.scaled(byX: -1,  y: 1)

    // Then
    XCTAssertEqual(expectedTransform1, returnedTransform1)
    XCTAssertEqual(expectedTransform2, returnedTransform2)
  }

  func testConcatenateWithTranslation() {

    // Given
    let transform1 = PDFAffineTransform2D(scaleX:     1,  shearY:     5,
                                          shearX:     4,  scaleY:     6,
                                          translateX: 12, translateY: 43)

    let expectedTransform1 = PDFAffineTransform2D(
      scaleX:     1,  shearY:     5,
      shearX:     4,  scaleY:     6,
      translateX: 6,  translateY: 69
    )

    let transform2 = PDFAffineTransform2D(scaleX:     1,  shearY:     0,
                                          shearX:     3,  scaleY:     2,
                                          translateX: 12, translateY: 43)

    let expectedTransform2 = PDFAffineTransform2D(
      scaleX:     1,   shearY:     0,
      shearX:     3,   scaleY:     2,
      translateX: 114, translateY: 111
    )

    // When
    let returnedTransform1 = transform1.translated(byX: 10, y: -4)
    let returnedTransform2 = transform2.translated(byX: 0,  y: 34)

    // Then
    XCTAssertEqual(expectedTransform1, returnedTransform1)
    XCTAssertEqual(expectedTransform2, returnedTransform2)
  }

  func testApplyTransformToSize() {

    // Given
    let size = PDFSize(width: 44, height: 12)
    let transform = PDFAffineTransform2D(scaleX:     1,  shearY:     5,
                                         shearX:     4,  scaleY:     6,
                                         translateX: 12, translateY: 43)

    let expectedSize = PDFSize(width: 92, height: 292)

    // When
    let returnedSize = size.applying(transform)

    // Then
    XCTAssertEqual(expectedSize, returnedSize)
  }

  func testApplyTransformToPoint() {

    // Given
    let point = PDFPoint2D(x: 44, y: 12)
    let transform = PDFAffineTransform2D(scaleX:     1,  shearY:     5,
                                         shearX:     4,  scaleY:     6,
                                         translateX: 12, translateY: 43)

    let expectedPoint = PDFPoint2D(x: 104, y: 335)

    // When
    let returnedPoint = point.applying(transform)

    // Then
    XCTAssertEqual(expectedPoint, returnedPoint)
  }
}

private let defaultAccuracy: Float = 0.00002

private func XCTAssertEqual(
  _ expr1: PDFAffineTransform2D?,
  _ expr2: PDFAffineTransform2D?,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #file,
  line: UInt = #line
) {

  guard let expression1 = expr1, let expression2 = expr2 else {
    XCTAssert(expr1 == nil && expr2 == nil, message(), file: file, line: line)
    return
  }

  XCTAssertEqual(expression1, expression2, message(), file: file, line: line)
}

private func XCTAssertEqual(
  _ expression1: PDFAffineTransform2D,
  _ expression2: PDFAffineTransform2D,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #file,
  line: UInt = #line
) {

  XCTAssertEqual(expression1.scaleX,
                 expression2.scaleX,
                 accuracy: defaultAccuracy,
                 message(),
                 file: file,
                 line: line)
  XCTAssertEqual(expression1.scaleY,
                 expression2.scaleY,
                 accuracy: defaultAccuracy,
                 message(),
                 file: file,
                 line: line)
  XCTAssertEqual(expression1.shearX,
                 expression2.shearX,
                 accuracy: defaultAccuracy,
                 message(),
                 file: file,
                 line: line)
  XCTAssertEqual(expression1.shearY,
                 expression2.shearY,
                 accuracy: defaultAccuracy,
                 message(),
                 file: file,
                 line: line)
  XCTAssertEqual(expression1.translateX,
                 expression2.translateX,
                 accuracy: defaultAccuracy,
                 message(),
                 file: file,
                 line: line)
  XCTAssertEqual(expression1.translateY,
                 expression2.translateY,
                 accuracy: defaultAccuracy,
                 message(),
                 file: file,
                 line: line)
}

