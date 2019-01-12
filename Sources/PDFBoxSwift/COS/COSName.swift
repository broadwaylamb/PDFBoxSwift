//
//  COSName.swift
//  PDFBoxSwiftCOS
//
//  Created by Sergej Jaskiewicz on 09/01/2019.
//

/// This class represents a PDF Name object.
public final class COSName: COSBase, ConvertibleToCOS {

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

  @discardableResult
  public override func accept(visitor: COSVisitorProtocol) throws -> Any? {
    return try visitor.visit(self)
  }

  /// This will write this object out to a PDF stream.
  ///
  /// - Parameter output: The stream to write to.
  /// - Throws: Any error the stream throws during writing.
  public func writePDF(_ output: OutputStream) throws {

    try output.write(ascii: "/")

    for byte in name.utf8 {

      // Be more restrictive than the PDF spec, "Name Objects",
      // see https://issues.apache.org/jira/browse/PDFBOX-2073
      if byte >= "A" && byte <= "Z" ||
         byte >= "a" && byte <= "z" ||
         byte >= "0" && byte <= "9" ||
         byte == "+"                ||
         byte == "-"                ||
         byte == "_"                ||
         byte == "@"                ||
         byte == "*"                ||
         byte == "$"                ||
         byte == ";"                ||
         byte == "."                 {
        try output.write(byte: byte)
      } else {
        try output.write(ascii: "#")
        try output.writeAsHex(byte)
      }
    }
  }

  public var cosRepresentation: COSName {
    return self
  }

  public override var debugDescription: String {
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
  internal static let a = COSName(name: "A")
  internal static let aa = COSName(name: "AA")
  internal static let ac = COSName(name: "AC")
  internal static let acroForm = COSName(name: "AcroForm")
  internal static let actualText = COSName(name: "ActualText")
  internal static let adbePKCS7Detached = COSName(name: "adbe.pkcs7.detached")
  internal static let adbePKCS7SHA1 = COSName(name: "adbe.pkcs7.sha1")
  internal static let adbeX509RSASHA1 = COSName(name: "adbe.x509.rsa_sha1")
  internal static let adobePPKLite = COSName(name: "Adobe.PPKLite")
  internal static let aesv2 = COSName(name: "AESV2")
  internal static let aesv3 = COSName(name: "AESV3")
  internal static let after = COSName(name: "After")
  internal static let ais = COSName(name: "AIS")
  internal static let alt = COSName(name: "Alt")
  internal static let alpha = COSName(name: "Alpha")
  internal static let alternate = COSName(name: "Alternate")
  internal static let annot = COSName(name: "Annot")
  internal static let annots = COSName(name: "Annots")
  internal static let antiAlias = COSName(name: "AntiAlias")
  internal static let ap = COSName(name: "AP")
  internal static let apRef = COSName(name: "APRef")
  internal static let app = COSName(name: "App")
  internal static let artBox = COSName(name: "ArtBox")
  internal static let artifact = COSName(name: "Artifact")
  internal static let `as` = COSName(name: "AS")
  internal static let ascent = COSName(name: "Ascent")
  internal static let asciiHexDecode = COSName(name: "ASCIIHexDecode")
  internal static let asciiHexDecodeAbbreviation = COSName(name: "AHx")
  internal static let ascii85Decode = COSName(name: "ASCII85Decode")
  internal static let ascii85DecodeAbbreviation = COSName(name: "A85")
  internal static let attached = COSName(name: "Attached")
  internal static let author = COSName(name: "Author")
  internal static let avgWidth = COSName(name: "AvgWidth")

  // MARK: B
  internal static let b = COSName(name: "B")
  internal static let background = COSName(name: "Background")
  internal static let baseEncoding = COSName(name: "BaseEncoding")
  internal static let baseFont = COSName(name: "BaseFont")
  internal static let baseState = COSName(name: "BaseState")
  internal static let bbox = COSName(name: "BBox")
  internal static let bc = COSName(name: "BC")
  internal static let be = COSName(name: "BE")
  internal static let before = COSName(name: "Before")
  internal static let bg = COSName(name: "BG")
  internal static let bitsPerComponent = COSName(name: "BitsPerComponent")
  internal static let bitsPerCoordinate = COSName(name: "BitsPerCoordinate")
  internal static let bitsPerFlag = COSName(name: "BitsPerFlag")
  internal static let bitsPerSample = COSName(name: "BitsPerSample")
  internal static let blackIs1 = COSName(name: "BlackIs1")
  internal static let blackPoint = COSName(name: "BlackPoint")
  internal static let bleedBox = COSName(name: "BleedBox")
  internal static let bm = COSName(name: "BM")
  internal static let border = COSName(name: "Border")
  internal static let bounds = COSName(name: "Bounds")
  internal static let bpc = COSName(name: "BPC")
  internal static let bs = COSName(name: "BS")

  /// Acro form field type for button fields.
  internal static let btn = COSName(name: "Btn")
  internal static let byteRange = COSName(name: "ByteRange")

  // MARK: C
  internal static let c = COSName(name: "C")
  internal static let c0 = COSName(name: "C0")
  internal static let c1 = COSName(name: "C1")
  internal static let ca = COSName(name: "CA")
  internal static let caNS = COSName(name: "ca")
  internal static let calGray = COSName(name: "CalGray")
  internal static let calRGB = COSName(name: "CalRGB")
  internal static let cap = COSName(name: "Cap")
  internal static let capHeight = COSName(name: "CapHeight")
  internal static let catalog = COSName(name: "Catalog")
  internal static let ccittfaxDecode = COSName(name: "CCITTFaxDecode")
  internal static let ccittfaxDecodeAbbreviation = COSName(name: "CCF")
  internal static let centerWindow = COSName(name: "CenterWindow")
  internal static let cert = COSName(name: "Cert")
  internal static let cf = COSName(name: "CF")
  internal static let cfm = COSName(name: "CFM")

  /// Acro form field type for choice fields.
  internal static let ch = COSName(name: "Ch")
  internal static let charProcs = COSName(name: "CharProcs")
  internal static let charSet = COSName(name: "CharSet")
  internal static let ciciSignIt = COSName(name: "CICI.SignIt")
  internal static let cidFontType0 = COSName(name: "CIDFontType0")
  internal static let cidFontType2 = COSName(name: "CIDFontType2")
  internal static let cidToGIDMap = COSName(name: "CIDToGIDMap")
  internal static let cidSet = COSName(name: "CIDSet")
  internal static let cidSystemInfo = COSName(name: "CIDSystemInfo")
  internal static let cl = COSName(name: "CL")
  internal static let clrF = COSName(name: "ClrF")
  internal static let clrFf = COSName(name: "ClrFf")
  internal static let cmap = COSName(name: "CMap")
  internal static let cmapName = COSName(name: "CMapName")
  internal static let cmyk = COSName(name: "CMYK")
  internal static let co = COSName(name: "CO")
  internal static let color = COSName(name: "Color")
  internal static let collection = COSName(name: "Collection")
  internal static let colorBurn = COSName(name: "ColorBurn")
  internal static let colorDodge = COSName(name: "ColorDodge")
  internal static let colorants = COSName(name: "Colorants")
  internal static let colors = COSName(name: "Colors")
  internal static let colorSpace = COSName(name: "ColorSpace")
  internal static let columns = COSName(name: "Columns")
  internal static let compatible = COSName(name: "Compatible")
  internal static let components = COSName(name: "Components")
  internal static let contactInfo = COSName(name: "ContactInfo")
  internal static let contents = COSName(name: "Contents")
  internal static let coords = COSName(name: "Coords")
  internal static let count = COSName(name: "Count")
  internal static let cp = COSName(name: "CP")
  internal static let creationDate = COSName(name: "CreationDate")
  internal static let creator = COSName(name: "Creator")
  internal static let cropBox = COSName(name: "CropBox")
  internal static let crypt = COSName(name: "Crypt")
  internal static let cs = COSName(name: "CS")

  // MARK: D
  internal static let d = COSName(name: "D")
  internal static let da = COSName(name: "DA")
  internal static let darken = COSName(name: "Darken")
  internal static let date = COSName(name: "Date")
  internal static let dctDecode = COSName(name: "DCTDecode")
  internal static let dctDecodeAbbreviation = COSName(name: "DCT")
  internal static let decode = COSName(name: "Decode")
  internal static let decodeParms = COSName(name: "DecodeParms")
  internal static let `default` = COSName(name: "default")
  internal static let defaultCMYK = COSName(name: "DefaultCMYK")
  internal static let defaultCryptFilter = COSName(name: "DefaultCryptFilter")
  internal static let defaultGray = COSName(name: "DefaultGray")
  internal static let defaultRGB = COSName(name: "DefaultRGB")
  internal static let desc = COSName(name: "Desc")
  internal static let descendantFonts = COSName(name: "DescendantFonts")
  internal static let descent = COSName(name: "Descent")
  internal static let dest = COSName(name: "Dest")
  internal static let destOutputProfile = COSName(name: "DestOutputProfile")
  internal static let dests = COSName(name: "Dests")
  internal static let deviceCMYK = COSName(name: "DeviceCMYK")
  internal static let deviceGray = COSName(name: "DeviceGray")
  internal static let deviceN = COSName(name: "DeviceN")
  internal static let deviceRGB = COSName(name: "DeviceRGB")
  internal static let di = COSName(name: "Di")
  internal static let difference = COSName(name: "Difference")
  internal static let differences = COSName(name: "Differences")
  internal static let digestMethod = COSName(name: "DigestMethod")
  internal static let digestRIPEMD160 = COSName(name: "RIPEMD160")
  internal static let digestSHA1 = COSName(name: "SHA1")
  internal static let digestSHA256 = COSName(name: "SHA256")
  internal static let digestSHA384 = COSName(name: "SHA384")
  internal static let digestSHA512 = COSName(name: "SHA512")
  internal static let direction = COSName(name: "Direction")
  internal static let displayDocTitle = COSName(name: "DisplayDocTitle")
  internal static let dl = COSName(name: "DL")
  internal static let dm = COSName(name: "Dm")
  internal static let doc = COSName(name: "Doc")
  internal static let docChecksum = COSName(name: "DocChecksum")
  internal static let docTimeStamp = COSName(name: "DocTimeStamp")
  internal static let docMDP = COSName(name: "DocMDP")
  internal static let document = COSName(name: "Document")
  internal static let domain = COSName(name: "Domain")
  internal static let dos = COSName(name: "DOS")
  internal static let dp = COSName(name: "DP")
  internal static let dr = COSName(name: "DR")
  internal static let ds = COSName(name: "DS")
  internal static let duplex = COSName(name: "Duplex")
  internal static let dur = COSName(name: "Dur")
  internal static let dv = COSName(name: "DV")
  internal static let dw = COSName(name: "DW")
  internal static let dw2 = COSName(name: "DW2")

  // MARK: E
  internal static let e = COSName(name: "E")
  internal static let earlyChange = COSName(name: "EarlyChange")
  internal static let ef = COSName(name: "EF")
  internal static let embeddedFDFs = COSName(name: "EmbeddedFDFs")
  internal static let embeddedFiles = COSName(name: "EmbeddedFiles")
  internal static let empty = COSName(name: "")
  internal static let encode = COSName(name: "Encode")
  internal static let encodedByteAlign = COSName(name: "EncodedByteAlign")
  internal static let encoding = COSName(name: "Encoding")
  internal static let encoding90msRKSJH = COSName(name: "90ms-RKSJ-H")
  internal static let encoding90msRKSJV = COSName(name: "90ms-RKSJ-V")
  internal static let encodingETenB5H = COSName(name: "ETen-B5-H")
  internal static let encodingETenB5V = COSName(name: "ETen-B5-V")
  internal static let encrypt = COSName(name: "Encrypt")
  internal static let encryptMetaData = COSName(name: "EncryptMetadata")
  internal static let endOfLine = COSName(name: "EndOfLine")
  internal static let entrustPPKEF = COSName(name: "Entrust.PPKEF")
  internal static let exclusion = COSName(name: "Exclusion")
  internal static let extGState = COSName(name: "ExtGState")
  internal static let extend = COSName(name: "Extend")
  internal static let extends = COSName(name: "Extends")

  // MARK: - F
  internal static let f = COSName(name: "F")
  internal static let fDecodeParms = COSName(name: "FDecodeParms")
  internal static let fFilter = COSName(name: "FFilter")
  internal static let fb = COSName(name: "FB")
  internal static let fdf = COSName(name: "FDF")
  internal static let ff = COSName(name: "Ff")
  internal static let fields = COSName(name: "Fields")
  internal static let filespec = COSName(name: "Filespec")
  internal static let filter = COSName(name: "Filter")
  internal static let first = COSName(name: "First")
  internal static let firstChar = COSName(name: "FirstChar")
  internal static let fitWindow = COSName(name: "FitWindow")
  internal static let fl = COSName(name: "FL")
  internal static let flags = COSName(name: "Flags")
  internal static let flateDecode = COSName(name: "FlateDecode")
  internal static let flateDecodeAbbreviation = COSName(name: "Fl")
  internal static let folders = COSName(name: "Folders")
  internal static let font = COSName(name: "Font")
  internal static let fontBbox = COSName(name: "FontBBox")
  internal static let fontDesc = COSName(name: "FontDescriptor")
  internal static let fontFamily = COSName(name: "FontFamily")
  internal static let fontFile = COSName(name: "FontFile")
  internal static let fontFile2 = COSName(name: "FontFile2")
  internal static let fontFile3 = COSName(name: "FontFile3")
  internal static let fontMatrix = COSName(name: "FontMatrix")
  internal static let fontName = COSName(name: "FontName")
  internal static let fontStretch = COSName(name: "FontStretch")
  internal static let fontWeight = COSName(name: "FontWeight")
  internal static let form = COSName(name: "Form")
  internal static let formtype = COSName(name: "FormType")
  internal static let frm = COSName(name: "FRM")
  internal static let ft = COSName(name: "FT")
  internal static let function = COSName(name: "Function")
  internal static let functionType = COSName(name: "FunctionType")
  internal static let functions = COSName(name: "Functions")

  // MARK: G
  internal static let g = COSName(name: "G")
  internal static let gamma = COSName(name: "Gamma")
  internal static let group = COSName(name: "Group")
  internal static let gtsPDFA1 = COSName(name: "GTS_PDFA1")

  // MARK: H
  internal static let h = COSName(name: "H")
  internal static let hardLight = COSName(name: "HardLight")
  internal static let height = COSName(name: "Height")
  internal static let helv = COSName(name: "Helv")
  internal static let hideMenubar = COSName(name: "HideMenubar")
  internal static let hideToolbar = COSName(name: "HideToolbar")
  internal static let hideWindowUI = COSName(name: "HideWindowUI")
  internal static let hue = COSName(name: "Hue")

  // MARK: I
  internal static let i = COSName(name: "I")
  internal static let ic = COSName(name: "IC")
  internal static let iccbased = COSName(name: "ICCBased")
  internal static let id = COSName(name: "ID")
  internal static let idTree = COSName(name: "IDTree")
  internal static let identity = COSName(name: "Identity")
  internal static let identityH = COSName(name: "Identity-H")
  internal static let identityV = COSName(name: "Identity-V")
  internal static let `if` = COSName(name: "IF")
  internal static let im = COSName(name: "IM")
  internal static let image = COSName(name: "Image")
  internal static let imageMask = COSName(name: "ImageMask")
  internal static let index = COSName(name: "Index")
  internal static let indexed = COSName(name: "Indexed")
  internal static let info = COSName(name: "Info")
  internal static let inklist = COSName(name: "InkList")
  internal static let interpolate = COSName(name: "Interpolate")
  internal static let it = COSName(name: "IT")
  internal static let italicAngle = COSName(name: "ItalicAngle")
  internal static let issuer = COSName(name: "Issuer")
  internal static let ix = COSName(name: "IX")

  // MARK: J
  internal static let javaScript = COSName(name: "JavaScript")
  internal static let jbig2Decode = COSName(name: "JBIG2Decode")
  internal static let jbig2Globals = COSName(name: "JBIG2Globals")
  internal static let jpxDecode = COSName(name: "JPXDecode")
  internal static let js = COSName(name: "JS")

  // MARK: K
  internal static let k = COSName(name: "K")
  internal static let keywords = COSName(name: "Keywords")
  internal static let keyUsage = COSName(name: "KeyUsage")
  internal static let kids = COSName(name: "Kids")

  // MARK: L
  internal static let l = COSName(name: "L")
  internal static let lab = COSName(name: "Lab")
  internal static let lang = COSName(name: "Lang")
  internal static let last = COSName(name: "Last")
  internal static let lastChar = COSName(name: "LastChar")
  internal static let lastModified = COSName(name: "LastModified")
  internal static let lc = COSName(name: "LC")
  internal static let le = COSName(name: "LE")
  internal static let leading = COSName(name: "Leading")
  internal static let legalAttestation = COSName(name: "LegalAttestation")
  internal static let length = COSName(name: "Length")
  internal static let length1 = COSName(name: "Length1")
  internal static let length2 = COSName(name: "Length2")
  internal static let lighten = COSName(name: "Lighten")
  internal static let limits = COSName(name: "Limits")
  internal static let lj = COSName(name: "LJ")
  internal static let ll = COSName(name: "LL")
  internal static let lle = COSName(name: "LLE")
  internal static let llo = COSName(name: "LLO")
  internal static let location = COSName(name: "Location")
  internal static let luminosity = COSName(name: "Luminosity")
  internal static let lw = COSName(name: "LW")
  internal static let lzwDecode = COSName(name: "LZWDecode")
  internal static let lzwDecodeAbbreviation = COSName(name: "LZW")

  // MARK: M
  internal static let m = COSName(name: "M")
  internal static let mac = COSName(name: "Mac")
  internal static let macExpertEncoding = COSName(name: "MacExpertEncoding")
  internal static let macRomanEncoding = COSName(name: "MacRomanEncoding")
  internal static let markInfo = COSName(name: "MarkInfo")
  internal static let mask = COSName(name: "Mask")
  internal static let matrix = COSName(name: "Matrix")
  internal static let matte = COSName(name: "Matte")
  internal static let maxLen = COSName(name: "MaxLen")
  internal static let maxWidth = COSName(name: "MaxWidth")
  internal static let mcid = COSName(name: "MCID")
  internal static let mdp = COSName(name: "MDP")
  internal static let mediaBox = COSName(name: "MediaBox")
  internal static let measure = COSName(name: "Measure")
  internal static let metadata = COSName(name: "Metadata")
  internal static let missingWidth = COSName(name: "MissingWidth")
  internal static let mix = COSName(name: "Mix")
  internal static let mk = COSName(name: "MK")
  internal static let ml = COSName(name: "ML")
  internal static let mmType1 = COSName(name: "MMType1")
  internal static let modDate = COSName(name: "ModDate")
  internal static let multiply = COSName(name: "Multiply")

  // MARK: N
  internal static let n = COSName(name: "N")
  internal static let name = COSName(name: "Name")
  internal static let names = COSName(name: "Names")
  internal static let navigator = COSName(name: "Navigator")
  internal static let needAppearances = COSName(name: "NeedAppearances")
  internal static let newWindow = COSName(name: "NewWindow")
  internal static let next = COSName(name: "Next")
  internal static let nm = COSName(name: "NM")
  internal static let nonEFontNoWarn = COSName(name: "NonEFontNoWarn")
  internal static let nonFullScreenPageMode =
    COSName(name: "NonFullScreenPageMode")
  internal static let none = COSName(name: "None")
  internal static let normal = COSName(name: "Normal")
  internal static let nums = COSName(name: "Nums")

  // MARK: O
  internal static let o = COSName(name: "O")
  internal static let obj = COSName(name: "Obj")
  internal static let objStm = COSName(name: "ObjStm")
  internal static let oc = COSName(name: "OC")
  internal static let ocg = COSName(name: "OCG")
  internal static let ocgs = COSName(name: "OCGs")
  internal static let ocProperties = COSName(name: "OCProperties")
  internal static let oe = COSName(name: "OE")
  internal static let oid = COSName(name: "OID")

  /// "OFF", to be used for OCGs, not for Acroform
  internal static let offOCG = COSName(name: "OFF")

  /// "Off", to be used for Acroform, not for OCGs
  internal static let offAcroform = COSName(name: "Off")

  internal static let on = COSName(name: "ON")
  internal static let op = COSName(name: "OP")
  internal static let opNS = COSName(name: "op")
  internal static let openAction = COSName(name: "OpenAction")
  internal static let openType = COSName(name: "OpenType")
  internal static let opm = COSName(name: "OPM")
  internal static let opt = COSName(name: "Opt")
  internal static let order = COSName(name: "Order")
  internal static let ordering = COSName(name: "Ordering")
  internal static let os = COSName(name: "OS")
  internal static let outlines = COSName(name: "Outlines")
  internal static let outputCondition = COSName(name: "OutputCondition")
  internal static let outputConditionIdentifier =
      COSName(name: "OutputConditionIdentifier")
  internal static let outputIntent = COSName(name: "OutputIntent")
  internal static let outputIntents = COSName(name: "OutputIntents")
  internal static let overlay = COSName(name: "Overlay")

  // MARK: P
  internal static let p = COSName(name: "P")
  internal static let page = COSName(name: "Page")
  internal static let pageLabels = COSName(name: "PageLabels")
  internal static let pageLayout = COSName(name: "PageLayout")
  internal static let pageMode = COSName(name: "PageMode")
  internal static let pages = COSName(name: "Pages")
  internal static let paintType = COSName(name: "PaintType")
  internal static let panose = COSName(name: "Panose");
  internal static let params = COSName(name: "Params")
  internal static let parent = COSName(name: "Parent")
  internal static let parentTree = COSName(name: "ParentTree")
  internal static let parentTreeNextKey = COSName(name: "ParentTreeNextKey")
  internal static let path = COSName(name: "Path")
  internal static let pattern = COSName(name: "Pattern")
  internal static let patternType = COSName(name: "PatternType")
  internal static let pdfDocEncoding = COSName(name: "PDFDocEncoding")
  internal static let perms = COSName(name: "Perms")
  internal static let pg = COSName(name: "Pg")
  internal static let preRelease = COSName(name: "PreRelease")
  internal static let predictor = COSName(name: "Predictor")
  internal static let prev = COSName(name: "Prev")
  internal static let printArea = COSName(name: "PrintArea")
  internal static let printClip = COSName(name: "PrintClip")
  internal static let printScaling = COSName(name: "PrintScaling")
  internal static let procSet = COSName(name: "ProcSet")
  internal static let process = COSName(name: "Process")
  internal static let producer = COSName(name: "Producer")
  internal static let propBuild = COSName(name: "Prop_Build")
  internal static let properties = COSName(name: "Properties")
  internal static let ps = COSName(name: "PS")
  internal static let pubSec = COSName(name: "PubSec")

  // MARK: Q
  internal static let q = COSName(name: "Q")
  internal static let quadpoints = COSName(name: "QuadPoints")

  // MARK: R
  internal static let r = COSName(name: "R")
  internal static let range = COSName(name: "Range")
  internal static let rc = COSName(name: "RC")
  internal static let rd = COSName(name: "RD")
  internal static let reason = COSName(name: "Reason")
  internal static let reasons = COSName(name: "Reasons")
  internal static let `repeat` = COSName(name: "Repeat")
  internal static let recipients = COSName(name: "Recipients")
  internal static let rect = COSName(name: "Rect")
  internal static let registry = COSName(name: "Registry")
  internal static let registryName = COSName(name: "RegistryName")
  internal static let rename = COSName(name: "Rename")
  internal static let resources = COSName(name: "Resources")
  internal static let rgb = COSName(name: "RGB")
  internal static let ri = COSName(name: "RI")
  internal static let roleMap = COSName(name: "RoleMap")
  internal static let root = COSName(name: "Root")
  internal static let rotate = COSName(name: "Rotate")
  internal static let rows = COSName(name: "Rows")
  internal static let runLengthDecode = COSName(name: "RunLengthDecode")
  internal static let runLengthDecodeAbbreviation = COSName(name: "RL")
  internal static let rv = COSName(name: "RV")

  // MARK: S
  internal static let s = COSName(name: "S")
  internal static let sa = COSName(name: "SA")
  internal static let saturation = COSName(name: "Saturation")
  internal static let schema = COSName(name: "Schema")
  internal static let screen = COSName(name: "Screen")
  internal static let se = COSName(name: "SE")
  internal static let separation = COSName(name: "Separation")
  internal static let setF = COSName(name: "SetF")
  internal static let setFf = COSName(name: "SetFf")
  internal static let shading = COSName(name: "Shading")
  internal static let shadingType = COSName(name: "ShadingType")
  internal static let sig = COSName(name: "Sig")
  internal static let sigFlags = COSName(name: "SigFlags")
  internal static let size = COSName(name: "Size")
  internal static let sm = COSName(name: "SM")
  internal static let smask = COSName(name: "SMask")
  internal static let softLight = COSName(name: "SoftLight")
  internal static let sort = COSName(name: "Sort")
  internal static let sound = COSName(name: "Sound")
  internal static let split = COSName(name: "Split")
  internal static let ss = COSName(name: "SS")
  internal static let st = COSName(name: "St")
  internal static let standardEncoding = COSName(name: "StandardEncoding")
  internal static let state = COSName(name: "State")
  internal static let stateModel = COSName(name: "StateModel")
  internal static let status = COSName(name: "Status")
  internal static let stdCF = COSName(name: "StdCF")
  internal static let stemH = COSName(name: "StemH")
  internal static let stemV = COSName(name: "StemV")
  internal static let stmF = COSName(name: "StmF")
  internal static let strF = COSName(name: "StrF")
  internal static let structElem = COSName(name: "StructElem")
  internal static let structParent = COSName(name: "StructParent")
  internal static let structParents = COSName(name: "StructParents")
  internal static let structTreeRoot = COSName(name: "StructTreeRoot")
  internal static let style = COSName(name: "Style")
  internal static let subFilter = COSName(name: "SubFilter")
  internal static let subj = COSName(name: "Subj")
  internal static let subject = COSName(name: "Subject")
  internal static let subjectDN = COSName(name: "SubjectDN")
  internal static let subtype = COSName(name: "Subtype")
  internal static let supplement = COSName(name: "Supplement")
  internal static let sv = COSName(name: "SV")
  internal static let svCert = COSName(name: "SVCert")
  internal static let sw = COSName(name: "SW")
  internal static let sy = COSName(name: "Sy")
  internal static let synchronous = COSName(name: "Synchronous")

  // MARK: T
  internal static let t = COSName(name: "T")
  internal static let target = COSName(name: "Target")
  internal static let templates = COSName(name: "Templates")
  internal static let threads = COSName(name: "Threads")
  internal static let thumb = COSName(name: "Thumb")
  internal static let ti = COSName(name: "TI")
  internal static let tilingType = COSName(name: "TilingType")
  internal static let timeStamp = COSName(name: "TimeStamp")
  internal static let title = COSName(name: "Title")
  internal static let tk = COSName(name: "TK")
  internal static let tm = COSName(name: "TM")
  internal static let toUnicode = COSName(name: "ToUnicode")
  internal static let tr = COSName(name: "TR")
  internal static let tr2 = COSName(name: "TR2")
  internal static let trapped = COSName(name: "Trapped")
  internal static let trans = COSName(name: "Trans")
  internal static let transparency = COSName(name: "Transparency")
  internal static let tRef = COSName(name: "TRef")
  internal static let trimBox = COSName(name: "TrimBox")
  internal static let trueType = COSName(name: "TrueType")
  internal static let trustedMode = COSName(name: "TrustedMode")
  internal static let tu = COSName(name: "TU")

  /// Acroform field type for text field.
  internal static let tx = COSName(name: "Tx")
  internal static let type = COSName(name: "Type")
  internal static let type0 = COSName(name: "Type0")
  internal static let type1 = COSName(name: "Type1")
  internal static let type3 = COSName(name: "Type3")

  // MARK: U
  internal static let u = COSName(name: "U")
  internal static let ue = COSName(name: "UE")
  internal static let uf = COSName(name: "UF")
  internal static let unchanged = COSName(name: "Unchanged")
  internal static let unix = COSName(name: "Unix")
  internal static let uri = COSName(name: "URI")
  internal static let url = COSName(name: "URL")
  internal static let urlType = COSName(name: "URLType")

  // MARK: V
  internal static let v = COSName(name: "V")
  internal static let verisignPPKVS = COSName(name: "VeriSign.PPKVS")
  internal static let version = COSName(name: "Version")
  internal static let vertices = COSName(name: "Vertices")
  internal static let verticesPerRow = COSName(name: "VerticesPerRow")
  internal static let view = COSName(name: "View")
  internal static let viewArea = COSName(name: "ViewArea")
  internal static let viewClip = COSName(name: "ViewClip")
  internal static let viewerPreferences = COSName(name: "ViewerPreferences")
  internal static let volume = COSName(name: "Volume")
  internal static let vp = COSName(name: "VP")

  // MARK: W
  internal static let w = COSName(name: "W")
  internal static let w2 = COSName(name: "W2")
  internal static let whitePoint = COSName(name: "WhitePoint")
  internal static let widget = COSName(name: "Widget")
  internal static let width = COSName(name: "Width")
  internal static let widths = COSName(name: "Widths")
  internal static let winANSIEncoding = COSName(name: "WinAnsiEncoding")

  // MARK: X
  internal static let xfa = COSName(name: "XFA")
  internal static let xStep = COSName(name: "XStep")
  internal static let xHeight = COSName(name: "XHeight")
  internal static let xObject = COSName(name: "XObject")
  internal static let xRef = COSName(name: "XRef")
  internal static let xRefStm = COSName(name: "XRefStm")

  // MARK: Y
  internal static let yStep = COSName(name: "YStep")
  internal static let yes = COSName(name: "Yes")

  // MARK: Z
  internal static let zaDb = COSName(name: "ZaDb")

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
