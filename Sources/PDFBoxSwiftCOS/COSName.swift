//
//  COSName.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

import PDFBoxSwiftIO

public final class COSName: COSBase {

  public let name: String

  public override func isEqual(_ other: COSBase) -> Bool {
    guard let other = other as? COSName else { return false }
    return self.name == other.name
  }

  public override func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

  /// Private constructor. This will limit the number of `COSName` objects
  /// that are created.
  ///
  /// - Parameters:
  ///   - name: The name of the `COSName` object.
  ///   - static: Indicates if the `COSName` object is static so that it can be
  ///             stored in the dictionary without synchronizing.
  private init(name: String, static: Bool = true) {
    self.name = name
    super.init()
    if !`static` {
      COSName.nameMap.atomically { $0[self.name] = self }
    }
  }

  /// Whether the name is the empty string.
  public var isEmpty: Bool {
    return name.isEmpty
  }

  public override func accept(visitor: COSVisitorProtocol) throws -> Any? {
    return try visitor.visit(self)
  }

  /// This will write this object out to a PDF stream.
  ///
  /// - Parameter output: The stream to write to.
  /// - Throws: Any error the stream throws during writing.
  public func writePDF(_ output: OutputStream) throws {

    try output.write(byte: 0x2F) // '/'

    for byte in name.utf8 {

      // Be more restrictive than the PDF spec, "Name Objects",
      // see https://issues.apache.org/jira/browse/PDFBOX-2073
      if byte >= 0x41 && byte <= 0x5A || // 'A'-'Z'
         byte >= 0x61 && byte <= 0x7A || // 'a'-'z'
         byte >= 0x30 && byte <= 0x39 || // '0'-'9'
         byte == 0x2B                 || // '+'
         byte == 0x2D                 || // '-'
         byte == 0x5F                 || // '_'
         byte == 0x40                 || // '@'
         byte == 0x2A                 || // '*'
         byte == 0x24                 || // '$'
         byte == 0x3B                 || // ';'
         byte == 0x2E                  {  // '.'
        try output.write(byte: byte)
      } else {
        try output.write(byte: 0x23) // '#'
        try output.writeAsHex(byte: byte)
      }
    }
  }
}

extension COSName: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "COSName{\(name)}"
  }
}

extension COSName: Comparable {
  public static func < (lhs: COSName, rhs: COSName) -> Bool {
    return lhs.name < rhs.name
  }
}

extension COSName {

  public static func getPDFName(_ nameString: String) -> COSName {

    // Is it a common COSName?
    if let cosName = commonNameMap[nameString] {
      return cosName
    }

    // It seems to be a document specific COSName
    if let cosName = nameMap.value[nameString] {
      return cosName
    }

    // name is added to the synchronized dictionary in the initializer
    return COSName(name: nameString, static: false)
  }

  /// Not usually needed except if resources need to be reclaimed in a long
  /// running process.
  public static func clearResources() {
    nameMap.atomically { $0.removeAll() }
  }

  // MARK: A
  public static let a = COSName(name: "A")
  public static let aa = COSName(name: "AA")
  public static let ac = COSName(name: "AC")
  public static let acroForm = COSName(name: "AcroForm")
  public static let actualText = COSName(name: "ActualText")
  public static let adbePKCS7Detached = COSName(name: "adbe.pkcs7.detached")
  public static let adbePKCS7SHA1 = COSName(name: "adbe.pkcs7.sha1")
  public static let adbeX509RSASHA1 = COSName(name: "adbe.x509.rsa_sha1")
  public static let adobePPKLite = COSName(name: "Adobe.PPKLite")
  public static let aesv2 = COSName(name: "AESV2")
  public static let aesv3 = COSName(name: "AESV3")
  public static let after = COSName(name: "After")
  public static let ais = COSName(name: "AIS")
  public static let alt = COSName(name: "Alt")
  public static let alpha = COSName(name: "Alpha")
  public static let alternate = COSName(name: "Alternate")
  public static let annot = COSName(name: "Annot")
  public static let annots = COSName(name: "Annots")
  public static let antiAlias = COSName(name: "AntiAlias")
  public static let ap = COSName(name: "AP")
  public static let apRef = COSName(name: "APRef")
  public static let app = COSName(name: "App")
  public static let artBox = COSName(name: "ArtBox")
  public static let artifact = COSName(name: "Artifact")
  public static let `as` = COSName(name: "AS")
  public static let ascent = COSName(name: "Ascent")
  public static let asciiHexDecode = COSName(name: "ASCIIHexDecode")
  public static let asciiHexDecodeAbbreviation = COSName(name: "AHx")
  public static let ascii85Decode = COSName(name: "ASCII85Decode")
  public static let ascii85DecodeAbbreviation = COSName(name: "A85")
  public static let attached = COSName(name: "Attached")
  public static let author = COSName(name: "Author")
  public static let avgWidth = COSName(name: "AvgWidth")

  // MARK: B
  public static let b = COSName(name: "B")
  public static let background = COSName(name: "Background")
  public static let baseEncoding = COSName(name: "BaseEncoding")
  public static let baseFont = COSName(name: "BaseFont")
  public static let baseState = COSName(name: "BaseState")
  public static let bbox = COSName(name: "BBox")
  public static let bc = COSName(name: "BC")
  public static let be = COSName(name: "BE")
  public static let before = COSName(name: "Before")
  public static let bg = COSName(name: "BG")
  public static let bitsPerComponent = COSName(name: "BitsPerComponent")
  public static let bitsPerCoordinate = COSName(name: "BitsPerCoordinate")
  public static let bitsPerFlag = COSName(name: "BitsPerFlag")
  public static let bitsPerSample = COSName(name: "BitsPerSample")
  public static let blackIs1 = COSName(name: "BlackIs1")
  public static let blackPoint = COSName(name: "BlackPoint")
  public static let bleedBox = COSName(name: "BleedBox")
  public static let bm = COSName(name: "BM")
  public static let border = COSName(name: "Border")
  public static let bounds = COSName(name: "Bounds")
  public static let bpc = COSName(name: "BPC")
  public static let bs = COSName(name: "BS")

  /// Acro form field type for button fields.
  public static let btn = COSName(name: "Btn")
  public static let byteRange = COSName(name: "ByteRange")

  // MARK: C
  public static let c = COSName(name: "C")
  public static let c0 = COSName(name: "C0")
  public static let c1 = COSName(name: "C1")
  public static let ca = COSName(name: "CA")
  public static let caNS = COSName(name: "ca")
  public static let calGray = COSName(name: "CalGray")
  public static let calRGB = COSName(name: "CalRGB")
  public static let cap = COSName(name: "Cap")
  public static let capHeight = COSName(name: "CapHeight")
  public static let catalog = COSName(name: "Catalog")
  public static let ccittfaxDecode = COSName(name: "CCITTFaxDecode")
  public static let ccittfaxDecodeAbbreviation = COSName(name: "CCF")
  public static let centerWindow = COSName(name: "CenterWindow")
  public static let cert = COSName(name: "Cert")
  public static let cf = COSName(name: "CF")
  public static let cfm = COSName(name: "CFM")

  /// Acro form field type for choice fields.
  public static let ch = COSName(name: "Ch")
  public static let charProcs = COSName(name: "CharProcs")
  public static let charSet = COSName(name: "CharSet")
  public static let ciciSignIt = COSName(name: "CICI.SignIt")
  public static let cidFontType0 = COSName(name: "CIDFontType0")
  public static let cidFontType2 = COSName(name: "CIDFontType2")
  public static let cidToGIDMap = COSName(name: "CIDToGIDMap")
  public static let cidSet = COSName(name: "CIDSet")
  public static let cidSystemInfo = COSName(name: "CIDSystemInfo")
  public static let cl = COSName(name: "CL")
  public static let clrF = COSName(name: "ClrF")
  public static let clrFf = COSName(name: "ClrFf")
  public static let cmap = COSName(name: "CMap")
  public static let cmapName = COSName(name: "CMapName")
  public static let cmyk = COSName(name: "CMYK")
  public static let co = COSName(name: "CO")
  public static let color = COSName(name: "Color")
  public static let collection = COSName(name: "Collection")
  public static let colorBurn = COSName(name: "ColorBurn")
  public static let colorDodge = COSName(name: "ColorDodge")
  public static let colorants = COSName(name: "Colorants")
  public static let colors = COSName(name: "Colors")
  public static let colorSpace = COSName(name: "ColorSpace")
  public static let columns = COSName(name: "Columns")
  public static let compatible = COSName(name: "Compatible")
  public static let components = COSName(name: "Components")
  public static let contactInfo = COSName(name: "ContactInfo")
  public static let contents = COSName(name: "Contents")
  public static let coords = COSName(name: "Coords")
  public static let count = COSName(name: "Count")
  public static let cp = COSName(name: "CP")
  public static let creationDate = COSName(name: "CreationDate")
  public static let creator = COSName(name: "Creator")
  public static let cropBox = COSName(name: "CropBox")
  public static let crypt = COSName(name: "Crypt")
  public static let cs = COSName(name: "CS")

  // MARK: D
  public static let d = COSName(name: "D")
  public static let da = COSName(name: "DA")
  public static let darken = COSName(name: "Darken")
  public static let date = COSName(name: "Date")
  public static let dctDecode = COSName(name: "DCTDecode")
  public static let dctDecodeAbbreviation = COSName(name: "DCT")
  public static let decode = COSName(name: "Decode")
  public static let decodeParms = COSName(name: "DecodeParms")
  public static let `default` = COSName(name: "default")
  public static let defaultCMYK = COSName(name: "DefaultCMYK")
  public static let defaultCryptFilter = COSName(name: "DefaultCryptFilter")
  public static let defaultGray = COSName(name: "DefaultGray")
  public static let defaultRGB = COSName(name: "DefaultRGB")
  public static let desc = COSName(name: "Desc")
  public static let descendantFonts = COSName(name: "DescendantFonts")
  public static let descent = COSName(name: "Descent")
  public static let dest = COSName(name: "Dest")
  public static let destOutputProfile = COSName(name: "DestOutputProfile")
  public static let dests = COSName(name: "Dests")
  public static let deviceCMYK = COSName(name: "DeviceCMYK")
  public static let deviceGray = COSName(name: "DeviceGray")
  public static let deviceN = COSName(name: "DeviceN")
  public static let deviceRGB = COSName(name: "DeviceRGB")
  public static let di = COSName(name: "Di")
  public static let difference = COSName(name: "Difference")
  public static let differences = COSName(name: "Differences")
  public static let digestMethod = COSName(name: "DigestMethod")
  public static let digestRIPEMD160 = COSName(name: "RIPEMD160")
  public static let digestSHA1 = COSName(name: "SHA1")
  public static let digestSHA256 = COSName(name: "SHA256")
  public static let digestSHA384 = COSName(name: "SHA384")
  public static let digestSHA512 = COSName(name: "SHA512")
  public static let direction = COSName(name: "Direction")
  public static let displayDocTitle = COSName(name: "DisplayDocTitle")
  public static let dl = COSName(name: "DL")
  public static let dm = COSName(name: "Dm")
  public static let doc = COSName(name: "Doc")
  public static let docChecksum = COSName(name: "DocChecksum")
  public static let docTimeStamp = COSName(name: "DocTimeStamp")
  public static let docMDP = COSName(name: "DocMDP")
  public static let document = COSName(name: "Document")
  public static let domain = COSName(name: "Domain")
  public static let dos = COSName(name: "DOS")
  public static let dp = COSName(name: "DP")
  public static let dr = COSName(name: "DR")
  public static let ds = COSName(name: "DS")
  public static let duplex = COSName(name: "Duplex")
  public static let dur = COSName(name: "Dur")
  public static let dv = COSName(name: "DV")
  public static let dw = COSName(name: "DW")
  public static let dw2 = COSName(name: "DW2")

  // MARK: E
  public static let e = COSName(name: "E")
  public static let earlyChange = COSName(name: "EarlyChange")
  public static let ef = COSName(name: "EF")
  public static let embeddedFDFs = COSName(name: "EmbeddedFDFs")
  public static let embeddedFiles = COSName(name: "EmbeddedFiles")
  public static let empty = COSName(name: "")
  public static let encode = COSName(name: "Encode")
  public static let encodedByteAlign = COSName(name: "EncodedByteAlign")
  public static let encoding = COSName(name: "Encoding")
  public static let encoding90msRKSJH = COSName(name: "90ms-RKSJ-H")
  public static let encoding90msRKSJV = COSName(name: "90ms-RKSJ-V")
  public static let encodingETenB5H = COSName(name: "ETen-B5-H")
  public static let encodingETenB5V = COSName(name: "ETen-B5-V")
  public static let encrypt = COSName(name: "Encrypt")
  public static let encryptMetaData = COSName(name: "EncryptMetadata")
  public static let endOfLine = COSName(name: "EndOfLine")
  public static let entrustPPKEF = COSName(name: "Entrust.PPKEF")
  public static let exclusion = COSName(name: "Exclusion")
  public static let extGState = COSName(name: "ExtGState")
  public static let extend = COSName(name: "Extend")
  public static let extends = COSName(name: "Extends")

  // MARK: - F
  public static let f = COSName(name: "F")
  public static let fDecodeParms = COSName(name: "FDecodeParms")
  public static let fFilter = COSName(name: "FFilter")
  public static let fb = COSName(name: "FB")
  public static let fdf = COSName(name: "FDF")
  public static let ff = COSName(name: "Ff")
  public static let fields = COSName(name: "Fields")
  public static let filespec = COSName(name: "Filespec")
  public static let filter = COSName(name: "Filter")
  public static let first = COSName(name: "First")
  public static let firstChar = COSName(name: "FirstChar")
  public static let fitWindow = COSName(name: "FitWindow")
  public static let fl = COSName(name: "FL")
  public static let flags = COSName(name: "Flags")
  public static let flateDecode = COSName(name: "FlateDecode")
  public static let flateDecodeAbbreviation = COSName(name: "Fl")
  public static let folders = COSName(name: "Folders")
  public static let font = COSName(name: "Font")
  public static let fontBbox = COSName(name: "FontBBox")
  public static let fontDesc = COSName(name: "FontDescriptor")
  public static let fontFamily = COSName(name: "FontFamily")
  public static let fontFile = COSName(name: "FontFile")
  public static let fontFile2 = COSName(name: "FontFile2")
  public static let fontFile3 = COSName(name: "FontFile3")
  public static let fontMatrix = COSName(name: "FontMatrix")
  public static let fontName = COSName(name: "FontName")
  public static let fontStretch = COSName(name: "FontStretch")
  public static let fontWeight = COSName(name: "FontWeight")
  public static let form = COSName(name: "Form")
  public static let formtype = COSName(name: "FormType")
  public static let frm = COSName(name: "FRM")
  public static let ft = COSName(name: "FT")
  public static let function = COSName(name: "Function")
  public static let functionType = COSName(name: "FunctionType")
  public static let functions = COSName(name: "Functions")

  // MARK: G
  public static let g = COSName(name: "G")
  public static let gamma = COSName(name: "Gamma")
  public static let group = COSName(name: "Group")
  public static let gtsPDFA1 = COSName(name: "GTS_PDFA1")

  // MARK: H
  public static let h = COSName(name: "H")
  public static let hardLight = COSName(name: "HardLight")
  public static let height = COSName(name: "Height")
  public static let helv = COSName(name: "Helv")
  public static let hideMenubar = COSName(name: "HideMenubar")
  public static let hideToolbar = COSName(name: "HideToolbar")
  public static let hideWindowUI = COSName(name: "HideWindowUI")
  public static let hue = COSName(name: "Hue")

  // MARK: I
  public static let i = COSName(name: "I")
  public static let ic = COSName(name: "IC")
  public static let iccbased = COSName(name: "ICCBased")
  public static let id = COSName(name: "ID")
  public static let idTree = COSName(name: "IDTree")
  public static let identity = COSName(name: "Identity")
  public static let identityH = COSName(name: "Identity-H")
  public static let identityV = COSName(name: "Identity-V")
  public static let `if` = COSName(name: "IF")
  public static let im = COSName(name: "IM")
  public static let image = COSName(name: "Image")
  public static let imageMask = COSName(name: "ImageMask")
  public static let index = COSName(name: "Index")
  public static let indexed = COSName(name: "Indexed")
  public static let info = COSName(name: "Info")
  public static let inklist = COSName(name: "InkList")
  public static let interpolate = COSName(name: "Interpolate")
  public static let it = COSName(name: "IT")
  public static let italicAngle = COSName(name: "ItalicAngle")
  public static let issuer = COSName(name: "Issuer")
  public static let ix = COSName(name: "IX")

  // MARK: J
  public static let javaScript = COSName(name: "JavaScript")
  public static let jbig2Decode = COSName(name: "JBIG2Decode")
  public static let jbig2Globals = COSName(name: "JBIG2Globals")
  public static let jpxDecode = COSName(name: "JPXDecode")
  public static let js = COSName(name: "JS")

  // MARK: K
  public static let k = COSName(name: "K")
  public static let keywords = COSName(name: "Keywords")
  public static let keyUsage = COSName(name: "KeyUsage")
  public static let kids = COSName(name: "Kids")

  // MARK: L
  public static let l = COSName(name: "L")
  public static let lab = COSName(name: "Lab")
  public static let lang = COSName(name: "Lang")
  public static let last = COSName(name: "Last")
  public static let lastChar = COSName(name: "LastChar")
  public static let lastModified = COSName(name: "LastModified")
  public static let lc = COSName(name: "LC")
  public static let le = COSName(name: "LE")
  public static let leading = COSName(name: "Leading")
  public static let legalAttestation = COSName(name: "LegalAttestation")
  public static let length = COSName(name: "Length")
  public static let length1 = COSName(name: "Length1")
  public static let length2 = COSName(name: "Length2")
  public static let lighten = COSName(name: "Lighten")
  public static let limits = COSName(name: "Limits")
  public static let lj = COSName(name: "LJ")
  public static let ll = COSName(name: "LL")
  public static let lle = COSName(name: "LLE")
  public static let llo = COSName(name: "LLO")
  public static let location = COSName(name: "Location")
  public static let luminosity = COSName(name: "Luminosity")
  public static let lw = COSName(name: "LW")
  public static let lzwDecode = COSName(name: "LZWDecode")
  public static let lzwDecodeAbbreviation = COSName(name: "LZW")

  // MARK: M
  public static let m = COSName(name: "M")
  public static let mac = COSName(name: "Mac")
  public static let macExpertEncoding = COSName(name: "MacExpertEncoding")
  public static let macRomanEncoding = COSName(name: "MacRomanEncoding")
  public static let markInfo = COSName(name: "MarkInfo")
  public static let mask = COSName(name: "Mask")
  public static let matrix = COSName(name: "Matrix")
  public static let matte = COSName(name: "Matte")
  public static let maxLen = COSName(name: "MaxLen")
  public static let maxWidth = COSName(name: "MaxWidth")
  public static let mcid = COSName(name: "MCID")
  public static let mdp = COSName(name: "MDP")
  public static let mediaBox = COSName(name: "MediaBox")
  public static let measure = COSName(name: "Measure")
  public static let metadata = COSName(name: "Metadata")
  public static let missingWidth = COSName(name: "MissingWidth")
  public static let mix = COSName(name: "Mix")
  public static let mk = COSName(name: "MK")
  public static let ml = COSName(name: "ML")
  public static let mmType1 = COSName(name: "MMType1")
  public static let modDate = COSName(name: "ModDate")
  public static let multiply = COSName(name: "Multiply")

  // MARK: N
  public static let n = COSName(name: "N")
  public static let name = COSName(name: "Name")
  public static let names = COSName(name: "Names")
  public static let navigator = COSName(name: "Navigator")
  public static let needAppearances = COSName(name: "NeedAppearances")
  public static let newWindow = COSName(name: "NewWindow")
  public static let next = COSName(name: "Next")
  public static let nm = COSName(name: "NM")
  public static let nonEFontNoWarn = COSName(name: "NonEFontNoWarn")
  public static let nonFullScreenPageMode =
    COSName(name: "NonFullScreenPageMode")
  public static let none = COSName(name: "None")
  public static let normal = COSName(name: "Normal")
  public static let nums = COSName(name: "Nums")

  // MARK: O
  public static let o = COSName(name: "O")
  public static let obj = COSName(name: "Obj")
  public static let objStm = COSName(name: "ObjStm")
  public static let oc = COSName(name: "OC")
  public static let ocg = COSName(name: "OCG")
  public static let ocgs = COSName(name: "OCGs")
  public static let ocProperties = COSName(name: "OCProperties")
  public static let oe = COSName(name: "OE")
  public static let oid = COSName(name: "OID")

  /// "OFF", to be used for OCGs, not for Acroform
  public static let offOCG = COSName(name: "OFF")

  /// "Off", to be used for Acroform, not for OCGs
  public static let offAcroform = COSName(name: "Off")

  public static let on = COSName(name: "ON")
  public static let op = COSName(name: "OP")
  public static let opNS = COSName(name: "op")
  public static let openAction = COSName(name: "OpenAction")
  public static let openType = COSName(name: "OpenType")
  public static let opm = COSName(name: "OPM")
  public static let opt = COSName(name: "Opt")
  public static let order = COSName(name: "Order")
  public static let ordering = COSName(name: "Ordering")
  public static let os = COSName(name: "OS")
  public static let outlines = COSName(name: "Outlines")
  public static let outputCondition = COSName(name: "OutputCondition")
  public static let outputConditionIdentifier = COSName(name: "OutputConditionIdentifier")
  public static let outputIntent = COSName(name: "OutputIntent")
  public static let outputIntents = COSName(name: "OutputIntents")
  public static let overlay = COSName(name: "Overlay")

  // MARK: P
  public static let p = COSName(name: "P")
  public static let page = COSName(name: "Page")
  public static let pageLabels = COSName(name: "PageLabels")
  public static let pageLayout = COSName(name: "PageLayout")
  public static let pageMode = COSName(name: "PageMode")
  public static let pages = COSName(name: "Pages")
  public static let paintType = COSName(name: "PaintType")
  public static let panose = COSName(name: "Panose");
  public static let params = COSName(name: "Params")
  public static let parent = COSName(name: "Parent")
  public static let parentTree = COSName(name: "ParentTree")
  public static let parentTreeNextKey = COSName(name: "ParentTreeNextKey")
  public static let path = COSName(name: "Path")
  public static let pattern = COSName(name: "Pattern")
  public static let patternType = COSName(name: "PatternType")
  public static let pdfDocEncoding = COSName(name: "PDFDocEncoding")
  public static let perms = COSName(name: "Perms")
  public static let pg = COSName(name: "Pg")
  public static let preRelease = COSName(name: "PreRelease")
  public static let predictor = COSName(name: "Predictor")
  public static let prev = COSName(name: "Prev")
  public static let printArea = COSName(name: "PrintArea")
  public static let printClip = COSName(name: "PrintClip")
  public static let printScaling = COSName(name: "PrintScaling")
  public static let procSet = COSName(name: "ProcSet")
  public static let process = COSName(name: "Process")
  public static let producer = COSName(name: "Producer")
  public static let propBuild = COSName(name: "Prop_Build")
  public static let properties = COSName(name: "Properties")
  public static let ps = COSName(name: "PS")
  public static let pubSec = COSName(name: "PubSec")

  // MARK: Q
  public static let q = COSName(name: "Q")
  public static let quadpoints = COSName(name: "QuadPoints")

  // MARK: R
  public static let r = COSName(name: "R")
  public static let range = COSName(name: "Range")
  public static let rc = COSName(name: "RC")
  public static let rd = COSName(name: "RD")
  public static let reason = COSName(name: "Reason")
  public static let reasons = COSName(name: "Reasons")
  public static let `repeat` = COSName(name: "Repeat")
  public static let recipients = COSName(name: "Recipients")
  public static let rect = COSName(name: "Rect")
  public static let registry = COSName(name: "Registry")
  public static let registryName = COSName(name: "RegistryName")
  public static let rename = COSName(name: "Rename")
  public static let resources = COSName(name: "Resources")
  public static let rgb = COSName(name: "RGB")
  public static let ri = COSName(name: "RI")
  public static let roleMap = COSName(name: "RoleMap")
  public static let root = COSName(name: "Root")
  public static let rotate = COSName(name: "Rotate")
  public static let rows = COSName(name: "Rows")
  public static let runLengthDecode = COSName(name: "RunLengthDecode")
  public static let runLengthDecodeAbbreviation = COSName(name: "RL")
  public static let rv = COSName(name: "RV")

  // MARK: S
  public static let s = COSName(name: "S")
  public static let sa = COSName(name: "SA")
  public static let saturation = COSName(name: "Saturation")
  public static let schema = COSName(name: "Schema")
  public static let screen = COSName(name: "Screen")
  public static let se = COSName(name: "SE")
  public static let separation = COSName(name: "Separation")
  public static let setF = COSName(name: "SetF")
  public static let setFf = COSName(name: "SetFf")
  public static let shading = COSName(name: "Shading")
  public static let shadingType = COSName(name: "ShadingType")
  public static let sig = COSName(name: "Sig")
  public static let sigFlags = COSName(name: "SigFlags")
  public static let size = COSName(name: "Size")
  public static let sm = COSName(name: "SM")
  public static let smask = COSName(name: "SMask")
  public static let softLight = COSName(name: "SoftLight")
  public static let sort = COSName(name: "Sort")
  public static let sound = COSName(name: "Sound")
  public static let split = COSName(name: "Split")
  public static let ss = COSName(name: "SS")
  public static let st = COSName(name: "St")
  public static let standardEncoding = COSName(name: "StandardEncoding")
  public static let state = COSName(name: "State")
  public static let stateModel = COSName(name: "StateModel")
  public static let status = COSName(name: "Status")
  public static let stdCF = COSName(name: "StdCF")
  public static let stemH = COSName(name: "StemH")
  public static let stemV = COSName(name: "StemV")
  public static let stmF = COSName(name: "StmF")
  public static let strF = COSName(name: "StrF")
  public static let structElem = COSName(name: "StructElem")
  public static let structParent = COSName(name: "StructParent")
  public static let structParents = COSName(name: "StructParents")
  public static let structTreeRoot = COSName(name: "StructTreeRoot")
  public static let style = COSName(name: "Style")
  public static let subFilter = COSName(name: "SubFilter")
  public static let subj = COSName(name: "Subj")
  public static let subject = COSName(name: "Subject")
  public static let subjectDN = COSName(name: "SubjectDN")
  public static let subtype = COSName(name: "Subtype")
  public static let supplement = COSName(name: "Supplement")
  public static let sv = COSName(name: "SV")
  public static let svCert = COSName(name: "SVCert")
  public static let sw = COSName(name: "SW")
  public static let sy = COSName(name: "Sy")
  public static let synchronous = COSName(name: "Synchronous")

  // MARK: T
  public static let t = COSName(name: "T")
  public static let target = COSName(name: "Target")
  public static let templates = COSName(name: "Templates")
  public static let threads = COSName(name: "Threads")
  public static let thumb = COSName(name: "Thumb")
  public static let ti = COSName(name: "TI")
  public static let tilingType = COSName(name: "TilingType")
  public static let timeStamp = COSName(name: "TimeStamp")
  public static let title = COSName(name: "Title")
  public static let tk = COSName(name: "TK")
  public static let tm = COSName(name: "TM")
  public static let toUnicode = COSName(name: "ToUnicode")
  public static let tr = COSName(name: "TR")
  public static let tr2 = COSName(name: "TR2")
  public static let trapped = COSName(name: "Trapped")
  public static let trans = COSName(name: "Trans")
  public static let transparency = COSName(name: "Transparency")
  public static let tRef = COSName(name: "TRef")
  public static let trimBox = COSName(name: "TrimBox")
  public static let trueType = COSName(name: "TrueType")
  public static let trustedMode = COSName(name: "TrustedMode")
  public static let tu = COSName(name: "TU")

  /// Acroform field type for text field.
  public static let tx = COSName(name: "Tx")
  public static let type = COSName(name: "Type")
  public static let type0 = COSName(name: "Type0")
  public static let type1 = COSName(name: "Type1")
  public static let type3 = COSName(name: "Type3")

  // MARK: U
  public static let u = COSName(name: "U")
  public static let ue = COSName(name: "UE")
  public static let uf = COSName(name: "UF")
  public static let unchanged = COSName(name: "Unchanged")
  public static let unix = COSName(name: "Unix")
  public static let uri = COSName(name: "URI")
  public static let url = COSName(name: "URL")
  public static let urlType = COSName(name: "URLType")

  // MARK: V
  public static let v = COSName(name: "V")
  public static let verisignPPKVS = COSName(name: "VeriSign.PPKVS")
  public static let version = COSName(name: "Version")
  public static let vertices = COSName(name: "Vertices")
  public static let verticesPerRow = COSName(name: "VerticesPerRow")
  public static let view = COSName(name: "View")
  public static let viewArea = COSName(name: "ViewArea")
  public static let viewClip = COSName(name: "ViewClip")
  public static let viewerPreferences = COSName(name: "ViewerPreferences")
  public static let volume = COSName(name: "Volume")
  public static let vp = COSName(name: "VP")

  // MARK: W
  public static let w = COSName(name: "W")
  public static let w2 = COSName(name: "W2")
  public static let whitePoint = COSName(name: "WhitePoint")
  public static let widget = COSName(name: "Widget")
  public static let width = COSName(name: "Width")
  public static let widths = COSName(name: "Widths")
  public static let winANSIEncoding = COSName(name: "WinAnsiEncoding")

  // MARK: X
  public static let xfa = COSName(name: "XFA")
  public static let xStep = COSName(name: "XStep")
  public static let xHeight = COSName(name: "XHeight")
  public static let xObject = COSName(name: "XObject")
  public static let xRef = COSName(name: "XRef")
  public static let xRefStm = COSName(name: "XRefStm")

  // MARK: Y
  public static let yStep = COSName(name: "YStep")
  public static let yes = COSName(name: "Yes")

  // MARK: Z
  public static let zaDb = COSName(name: "ZaDb")

  // Using AtomicReference because this can be accessed by multiple threads.
  // The Java version uses ConcurrentHashMap, which is not available in Swift.
  private static let nameMap =
    AtomicReference([String : COSName](minimumCapacity: 8192))

  private static let commonNameMap: [String : COSName] = [
    // A
    a.name                           : a,
    aa.name                          : aa,
    ac.name                          : ac,
    acroForm.name                    : acroForm,
    actualText.name                  : actualText,
    adbePKCS7Detached.name           : adbePKCS7Detached,
    adbePKCS7SHA1.name               : adbePKCS7SHA1,
    adbeX509RSASHA1.name             : adbeX509RSASHA1,
    adobePPKLite.name                : adobePPKLite,
    aesv2.name                       : aesv2,
    aesv3.name                       : aesv3,
    after.name                       : after,
    ais.name                         : ais,
    alt.name                         : alt,
    alpha.name                       : alpha,
    alternate.name                   : alternate,
    annot.name                       : annot,
    annots.name                      : annots,
    antiAlias.name                   : antiAlias,
    ap.name                          : ap,
    apRef.name                       : apRef,
    app.name                         : app,
    artBox.name                      : artBox,
    artifact.name                    : artifact,
    `as`.name                        : `as`,
    ascent.name                      : ascent,
    asciiHexDecode.name              : asciiHexDecode,
    asciiHexDecodeAbbreviation.name  : asciiHexDecodeAbbreviation,
    ascii85Decode.name               : ascii85Decode,
    ascii85DecodeAbbreviation.name   : ascii85DecodeAbbreviation,
    attached.name                    : attached,
    author.name                      : author,
    avgWidth.name                    : avgWidth,
    // B
    b.name                           : b,
    background.name                  : background,
    baseEncoding.name                : baseEncoding,
    baseFont.name                    : baseFont,
    baseState.name                   : baseState,
    bbox.name                        : bbox,
    bc.name                          : bc,
    be.name                          : be,
    before.name                      : before,
    bg.name                          : bg,
    bitsPerComponent.name            : bitsPerComponent,
    bitsPerCoordinate.name           : bitsPerCoordinate,
    bitsPerFlag.name                 : bitsPerFlag,
    bitsPerSample.name               : bitsPerSample,
    blackIs1.name                    : blackIs1,
    blackPoint.name                  : blackPoint,
    bleedBox.name                    : bleedBox,
    bm.name                          : bm,
    border.name                      : border,
    bounds.name                      : bounds,
    bpc.name                         : bpc,
    bs.name                          : bs,
    btn.name                         : btn,
    byteRange.name                   : byteRange,
    // C
    c.name                           : c,
    c0.name                          : c0,
    c1.name                          : c1,
    ca.name                          : ca,
    caNS.name                        : caNS,
    calGray.name                     : calGray,
    calRGB.name                      : calRGB,
    cap.name                         : cap,
    capHeight.name                   : capHeight,
    catalog.name                     : catalog,
    ccittfaxDecode.name              : ccittfaxDecode,
    ccittfaxDecodeAbbreviation.name  : ccittfaxDecodeAbbreviation,
    centerWindow.name                : centerWindow,
    cert.name                        : cert,
    cf.name                          : cf,
    cfm.name                         : cfm,
    ch.name                          : ch,
    charProcs.name                   : charProcs,
    charSet.name                     : charSet,
    ciciSignIt.name                  : ciciSignIt,
    cidFontType0.name                : cidFontType0,
    cidFontType2.name                : cidFontType2,
    cidToGIDMap.name                 : cidToGIDMap,
    cidSet.name                      : cidSet,
    cidSystemInfo.name               : cidSystemInfo,
    cl.name                          : cl,
    clrF.name                        : clrF,
    clrFf.name                       : clrFf,
    cmap.name                        : cmap,
    cmapName.name                    : cmapName,
    cmyk.name                        : cmyk,
    co.name                          : co,
    color.name                       : color,
    collection.name                  : collection,
    colorBurn.name                   : colorBurn,
    colorDodge.name                  : colorDodge,
    colorants.name                   : colorants,
    colors.name                      : colors,
    colorSpace.name                  : colorSpace,
    columns.name                     : columns,
    compatible.name                  : compatible,
    components.name                  : components,
    contactInfo.name                 : contactInfo,
    contents.name                    : contents,
    coords.name                      : coords,
    count.name                       : count,
    cp.name                          : cp,
    creationDate.name                : creationDate,
    creator.name                     : creator,
    cropBox.name                     : cropBox,
    crypt.name                       : crypt,
    cs.name                          : cs,
    // D
    d.name                           : d,
    da.name                          : da,
    darken.name                      : darken,
    date.name                        : date,
    dctDecode.name                   : dctDecode,
    dctDecodeAbbreviation.name       : dctDecodeAbbreviation,
    decode.name                      : decode,
    decodeParms.name                 : decodeParms,
    `default`.name                   : `default`,
    defaultCMYK.name                 : defaultCMYK,
    defaultCryptFilter.name          : defaultCryptFilter,
    defaultGray.name                 : defaultGray,
    defaultRGB.name                  : defaultRGB,
    desc.name                        : desc,
    descendantFonts.name             : descendantFonts,
    descent.name                     : descent,
    dest.name                        : dest,
    destOutputProfile.name           : destOutputProfile,
    dests.name                       : dests,
    deviceCMYK.name                  : deviceCMYK,
    deviceGray.name                  : deviceGray,
    deviceN.name                     : deviceN,
    deviceRGB.name                   : deviceRGB,
    di.name                          : di,
    difference.name                  : difference,
    differences.name                 : differences,
    digestMethod.name                : digestMethod,
    digestRIPEMD160.name             : digestRIPEMD160,
    digestSHA1.name                  : digestSHA1,
    digestSHA256.name                : digestSHA256,
    digestSHA384.name                : digestSHA384,
    digestSHA512.name                : digestSHA512,
    direction.name                   : direction,
    displayDocTitle.name             : displayDocTitle,
    dl.name                          : dl,
    dm.name                          : dm,
    doc.name                         : doc,
    docChecksum.name                 : docChecksum,
    docTimeStamp.name                : docTimeStamp,
    docMDP.name                      : docMDP,
    document.name                    : document,
    domain.name                      : domain,
    dos.name                         : dos,
    dp.name                          : dp,
    dr.name                          : dr,
    ds.name                          : ds,
    duplex.name                      : duplex,
    dur.name                         : dur,
    dv.name                          : dv,
    dw.name                          : dw,
    dw2.name                         : dw2,
    // E
    e.name                           : e,
    earlyChange.name                 : earlyChange,
    ef.name                          : ef,
    embeddedFDFs.name                : embeddedFDFs,
    embeddedFiles.name               : embeddedFiles,
    empty.name                       : empty,
    encode.name                      : encode,
    encodedByteAlign.name            : encodedByteAlign,
    encoding.name                    : encoding,
    encoding90msRKSJH.name           : encoding90msRKSJH,
    encoding90msRKSJV.name           : encoding90msRKSJV,
    encodingETenB5H.name             : encodingETenB5H,
    encodingETenB5V.name             : encodingETenB5V,
    encrypt.name                     : encrypt,
    encryptMetaData.name             : encryptMetaData,
    endOfLine.name                   : endOfLine,
    entrustPPKEF.name                : entrustPPKEF,
    exclusion.name                   : exclusion,
    extGState.name                   : extGState,
    extend.name                      : extend,
    extends.name                     : extends,
    // F
    f.name                           : f,
    fDecodeParms.name                : fDecodeParms,
    fFilter.name                     : fFilter,
    fb.name                          : fb,
    fdf.name                         : fdf,
    ff.name                          : ff,
    fields.name                      : fields,
    filespec.name                    : filespec,
    filter.name                      : filter,
    first.name                       : first,
    firstChar.name                   : firstChar,
    fitWindow.name                   : fitWindow,
    fl.name                          : fl,
    flags.name                       : flags,
    flateDecode.name                 : flateDecode,
    flateDecodeAbbreviation.name     : flateDecodeAbbreviation,
    folders.name                     : folders,
    font.name                        : font,
    fontBbox.name                    : fontBbox,
    fontDesc.name                    : fontDesc,
    fontFamily.name                  : fontFamily,
    fontFile.name                    : fontFile,
    fontFile2.name                   : fontFile2,
    fontFile3.name                   : fontFile3,
    fontMatrix.name                  : fontMatrix,
    fontName.name                    : fontName,
    fontStretch.name                 : fontStretch,
    fontWeight.name                  : fontWeight,
    form.name                        : form,
    formtype.name                    : formtype,
    frm.name                         : frm,
    ft.name                          : ft,
    function.name                    : function,
    functionType.name                : functionType,
    functions.name                   : functions,
    // G
    g.name                           : g,
    gamma.name                       : gamma,
    group.name                       : group,
    gtsPDFA1.name                    : gtsPDFA1,
    // H
    h.name                           : h,
    hardLight.name                   : hardLight,
    height.name                      : height,
    helv.name                        : helv,
    hideMenubar.name                 : hideMenubar,
    hideToolbar.name                 : hideToolbar,
    hideWindowUI.name                : hideWindowUI,
    hue.name                         : hue,
    // I
    i.name                           : i,
    ic.name                          : ic,
    iccbased.name                    : iccbased,
    id.name                          : id,
    idTree.name                      : idTree,
    identity.name                    : identity,
    identityH.name                   : identityH,
    identityV.name                   : identityV,
    `if`.name                        : `if`,
    im.name                          : im,
    image.name                       : image,
    imageMask.name                   : imageMask,
    index.name                       : index,
    indexed.name                     : indexed,
    info.name                        : info,
    inklist.name                     : inklist,
    interpolate.name                 : interpolate,
    it.name                          : it,
    italicAngle.name                 : italicAngle,
    issuer.name                      : issuer,
    ix.name                          : ix,
    // J
    javaScript.name                  : javaScript,
    jbig2Decode.name                 : jbig2Decode,
    jbig2Globals.name                : jbig2Globals,
    jpxDecode.name                   : jpxDecode,
    js.name                          : js,
    // K
    k.name                           : k,
    keywords.name                    : keywords,
    keyUsage.name                    : keyUsage,
    kids.name                        : kids,
    // L
    l.name                           : l,
    lab.name                         : lab,
    lang.name                        : lang,
    last.name                        : last,
    lastChar.name                    : lastChar,
    lastModified.name                : lastModified,
    lc.name                          : lc,
    le.name                          : le,
    leading.name                     : leading,
    legalAttestation.name            : legalAttestation,
    length.name                      : length,
    length1.name                     : length1,
    length2.name                     : length2,
    lighten.name                     : lighten,
    limits.name                      : limits,
    lj.name                          : lj,
    ll.name                          : ll,
    lle.name                         : lle,
    llo.name                         : llo,
    location.name                    : location,
    luminosity.name                  : luminosity,
    lw.name                          : lw,
    lzwDecode.name                   : lzwDecode,
    lzwDecodeAbbreviation.name       : lzwDecodeAbbreviation,
    // M
    m.name                           : m,
    mac.name                         : mac,
    macExpertEncoding.name           : macExpertEncoding,
    macRomanEncoding.name            : macRomanEncoding,
    markInfo.name                    : markInfo,
    mask.name                        : mask,
    matrix.name                      : matrix,
    matte.name                       : matte,
    maxLen.name                      : maxLen,
    maxWidth.name                    : maxWidth,
    mcid.name                        : mcid,
    mdp.name                         : mdp,
    mediaBox.name                    : mediaBox,
    measure.name                     : measure,
    metadata.name                    : metadata,
    missingWidth.name                : missingWidth,
    mix.name                         : mix,
    mk.name                          : mk,
    ml.name                          : ml,
    mmType1.name                     : mmType1,
    modDate.name                     : modDate,
    multiply.name                    : multiply,
    // N
    n.name                           : n,
    name.name                        : name,
    names.name                       : names,
    navigator.name                   : navigator,
    needAppearances.name             : needAppearances,
    newWindow.name                   : newWindow,
    next.name                        : next,
    nm.name                          : nm,
    nonEFontNoWarn.name              : nonEFontNoWarn,
    nonFullScreenPageMode.name       : nonFullScreenPageMode,
    none.name                        : none,
    normal.name                      : normal,
    nums.name                        : nums,
    // O
    o.name                           : o,
    obj.name                         : obj,
    objStm.name                      : objStm,
    oc.name                          : oc,
    ocg.name                         : ocg,
    ocgs.name                        : ocgs,
    ocProperties.name                : ocProperties,
    oe.name                          : oe,
    oid.name                         : oid,
    offOCG.name                      : offOCG,
    offAcroform.name                 : offAcroform,
    on.name                          : on,
    op.name                          : op,
    opNS.name                        : opNS,
    openAction.name                  : openAction,
    openType.name                    : openType,
    opm.name                         : opm,
    opt.name                         : opt,
    order.name                       : order,
    ordering.name                    : ordering,
    os.name                          : os,
    outlines.name                    : outlines,
    outputCondition.name             : outputCondition,
    outputConditionIdentifier.name   : outputConditionIdentifier,
    outputIntent.name                : outputIntent,
    outputIntents.name               : outputIntents,
    overlay.name                     : overlay,
    // P
    p.name                           : p,
    page.name                        : page,
    pageLabels.name                  : pageLabels,
    pageLayout.name                  : pageLayout,
    pageMode.name                    : pageMode,
    pages.name                       : pages,
    paintType.name                   : paintType,
    panose.name                      : panose,
    params.name                      : params,
    parent.name                      : parent,
    parentTree.name                  : parentTree,
    parentTreeNextKey.name           : parentTreeNextKey,
    path.name                        : path,
    pattern.name                     : pattern,
    patternType.name                 : patternType,
    pdfDocEncoding.name              : pdfDocEncoding,
    perms.name                       : perms,
    pg.name                          : pg,
    preRelease.name                  : preRelease,
    predictor.name                   : predictor,
    prev.name                        : prev,
    printArea.name                   : printArea,
    printClip.name                   : printClip,
    printScaling.name                : printScaling,
    procSet.name                     : procSet,
    process.name                     : process,
    producer.name                    : producer,
    propBuild.name                   : propBuild,
    properties.name                  : properties,
    ps.name                          : ps,
    pubSec.name                      : pubSec,
    // Q
    q.name                           : q,
    quadpoints.name                  : quadpoints,
    // R
    r.name                           : r,
    range.name                       : range,
    rc.name                          : rc,
    rd.name                          : rd,
    reason.name                      : reason,
    reasons.name                     : reasons,
    `repeat`.name                    : `repeat`,
    recipients.name                  : recipients,
    rect.name                        : rect,
    registry.name                    : registry,
    registryName.name                : registryName,
    rename.name                      : rename,
    resources.name                   : resources,
    rgb.name                         : rgb,
    ri.name                          : ri,
    roleMap.name                     : roleMap,
    root.name                        : root,
    rotate.name                      : rotate,
    rows.name                        : rows,
    runLengthDecode.name             : runLengthDecode,
    runLengthDecodeAbbreviation.name : runLengthDecodeAbbreviation,
    rv.name                          : rv,
    // S
    s.name                           : s,
    sa.name                          : sa,
    saturation.name                  : saturation,
    schema.name                      : schema,
    screen.name                      : screen,
    se.name                          : se,
    separation.name                  : separation,
    setF.name                        : setF,
    setFf.name                       : setFf,
    shading.name                     : shading,
    shadingType.name                 : shadingType,
    sig.name                         : sig,
    sigFlags.name                    : sigFlags,
    size.name                        : size,
    sm.name                          : sm,
    smask.name                       : smask,
    softLight.name                   : softLight,
    sort.name                        : sort,
    sound.name                       : sound,
    split.name                       : split,
    ss.name                          : ss,
    st.name                          : st,
    standardEncoding.name            : standardEncoding,
    state.name                       : state,
    stateModel.name                  : stateModel,
    status.name                      : status,
    stdCF.name                       : stdCF,
    stemH.name                       : stemH,
    stemV.name                       : stemV,
    stmF.name                        : stmF,
    strF.name                        : strF,
    structElem.name                  : structElem,
    structParent.name                : structParent,
    structParents.name               : structParents,
    structTreeRoot.name              : structTreeRoot,
    style.name                       : style,
    subFilter.name                   : subFilter,
    subj.name                        : subj,
    subject.name                     : subject,
    subjectDN.name                   : subjectDN,
    subtype.name                     : subtype,
    supplement.name                  : supplement,
    sv.name                          : sv,
    svCert.name                      : svCert,
    sw.name                          : sw,
    sy.name                          : sy,
    synchronous.name                 : synchronous,
    // T
    t.name                           : t,
    target.name                      : target,
    templates.name                   : templates,
    threads.name                     : threads,
    thumb.name                       : thumb,
    ti.name                          : ti,
    tilingType.name                  : tilingType,
    timeStamp.name                   : timeStamp,
    title.name                       : title,
    tk.name                          : tk,
    tm.name                          : tm,
    toUnicode.name                   : toUnicode,
    tr.name                          : tr,
    tr2.name                         : tr2,
    trapped.name                     : trapped,
    trans.name                       : trans,
    transparency.name                : transparency,
    tRef.name                        : tRef,
    trimBox.name                     : trimBox,
    trueType.name                    : trueType,
    trustedMode.name                 : trustedMode,
    tu.name                          : tu,
    tx.name                          : tx,
    type.name                        : type,
    type0.name                       : type0,
    type1.name                       : type1,
    type3.name                       : type3,
    // U
    u.name                           : u,
    ue.name                          : ue,
    uf.name                          : uf,
    unchanged.name                   : unchanged,
    unix.name                        : unix,
    uri.name                         : uri,
    url.name                         : url,
    urlType.name                     : urlType,
    // V
    v.name                           : v,
    verisignPPKVS.name               : verisignPPKVS,
    version.name                     : version,
    vertices.name                    : vertices,
    verticesPerRow.name              : verticesPerRow,
    view.name                        : view,
    viewArea.name                    : viewArea,
    viewClip.name                    : viewClip,
    viewerPreferences.name           : viewerPreferences,
    volume.name                      : volume,
    vp.name                          : vp,
    // W
    w.name                           : w,
    w2.name                          : w2,
    whitePoint.name                  : whitePoint,
    widget.name                      : widget,
    width.name                       : width,
    widths.name                      : widths,
    winANSIEncoding.name             : winANSIEncoding,
    // X
    xfa.name                         : xfa,
    xStep.name                       : xStep,
    xHeight.name                     : xHeight,
    xObject.name                     : xObject,
    xRef.name                        : xRef,
    xRefStm.name                     : xRefStm,
    // Y
    yStep.name                       : yStep,
    yes.name                         : yes,
    // Z
    zaDb.name                        : zaDb,
  ]
}
