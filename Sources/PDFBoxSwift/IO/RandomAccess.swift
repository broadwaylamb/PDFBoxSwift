//
//  RandomAccess.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 13/01/2019.
//

/// A protocol to allow data to be stored completely in memory or to use
/// a scratch file on the disk.
public typealias RandomAccess = RandomAccessRead & RandomAccessWrite
