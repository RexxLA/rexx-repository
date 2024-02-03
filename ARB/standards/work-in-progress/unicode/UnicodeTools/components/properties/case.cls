/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/


/*****************************************************************************/
/*                                                                           */
/*  The UNICODE.CASE class                                                   */
/*  ======================                                                   */
/*                                                                           */
/*  See section 5.6, "Case and Case Mapping", in the                         */
/*  Unicode Standard Annex #44, Unicode Character Database,                  */
/*  https://unicode.org/reports/tr44/#Casemapping.                           */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1e JMB 20230721 Initial release. Implements toLowercase(string)       */
/*  00.2  JMB 20230725 Implement toUppercase(string)                         */
/*                     Rename classfile to case.cls                          */
/*                                                                           */
/*****************************************************************************/

.local~Unicode.Case = .Unicode.Case

::Class Unicode.Case Public SubClass Unicode.Property

::Constant BinaryFile                           "case.bin"  

::Constant UnicodeData.Properties               "Simple_Lowercase_Mapping slc Simple_Uppercase_Mapping suc"

::Constant DerivedCoreProperties.Properties     "Math Alphabetic Alpha Lowercase Lower Uppercase Upper Cased Case_Ignorable CI Changes_When_Lowercased CWL Changes_When_Uppercased CWU Changes_When_Titlecased CWT Changes_When_Casefolded CWCF Changes_When_Casemapped CWCM"

::Constant DerivedNormalizationProps.Properties "Full_Composition_Exclusion NFD_QC_N NFC_QC_N NFC_QC_M NFKD_QC_N NFKC_QC_N NFKC_QC_M Changes_When_NFKC_Casefolded"
-- .Export different from .Properties because we internally implement the QC properties as if they were binary
::Constant DerivedNormalizationProps.Export     "Full_Composition_Exclusion Comp_Ex NFD_Quick_Check NFD_QC NFC_Quick_Check NFC_QC NFKD_Quick_Check NFKD_QC NFKC_Quick_Check NFKC_QC Changes_When_NFKC_Casefolded CWKCF"

::Constant PropList.Properties                  "Other_Alphabetic OAlpha Other_Lowercase OLower Other_Uppercase OUpper Soft_Dotted SD"

::Constant Masks (                                   -
   /*                                           */   -
   /* From DerivedCoreProperties.txt            */   -
   /*                                           */   -
  (mask.Math                         , "80000000"X), -
  (mask.Alphabetic                   , "40000000"X), -
  (mask.Lowercase                    , "20000000"X), -
  (mask.Uppercase                    , "10000000"X), -
  (mask.Cased                        , "08000000"X), -
  (mask.Case_Ignorable               , "04000000"X), -
  (mask.Changes_When_Lowercased      , "02000000"X), -
  (mask.Changes_When_Uppercased      , "01000000"X), -
  (mask.Changes_When_Titlecased      , "00800000"X), -
  (mask.Changes_When_Casefolded      , "00400000"X), -
  (mask.Changes_When_Casemapped      , "00200000"X), -
   /*                                           */   -
   /* From DerivedNormalizationProps.txt        */   -
   /*                                           */   -
  (mask.Full_Composition_Exclusion   , "00100000"X), -
  (mask.NFD_QC_N                     , "00080000"X), -
  (mask.NFC_QC_N                     , "00040000"X), -
  (mask.NFC_QC_M                     , "00020000"X), -
  (mask.NFKD_QC_N                    , "00010000"X), -
  (mask.NFKC_QC_N                    , "00008000"X), -
  (mask.NFKC_QC_M                    , "00004000"X), -
  (mask.Changes_When_NFKC_Casefolded , "00002000"X), -
   /*                                           */   -
   /* From PropList.txt                         */   -
   /*                                           */   -
  (mask.Other_Alphabetic             , "00001000"X), -
  (mask.Other_Lowercase              , "00000800"X), -
  (mask.Other_Uppercase              , "00000400"X), -
  (mask.Soft_Dotted                  , "00000200"X)  -
)

--
-- Activate is automatically called at the end of class initialization.
--
 
::Method Activate Class
  Expose mask. SpecialUpper. upperCase lowercase caseproperties
      
  -- Build the MASK. stem
  
  Do pair Over self~masks
    Call Value pair[1], pair[2]
  End
      
  -- Inform the registry that we will be handling these properties, functions and aliases
  
  super~registerFunctions(  "toLowercase", self )
  super~registerFunctions(  "toUppercase", self )
  super~registerProperties( self~UnicodeData.Properties,           self )
  super~registerProperties( self~DerivedCoreProperties.Properties, self )
  super~registerProperties( self~DerivedNormalizationProps.Export, self )
  super~registerProperties( self~PropList.Properties,              self )
      
  If .Unicode.Buildtime \== 1 Then Do
    super~loadPersistent( super~BinFile.Qualify( self~binaryFile ) ) 
    
    offset         = super~getPersistent("Uppercase.Table1")
    chunks         = super~getPersistent("Uppercase.Table2")
    uppercase      = .MultiStageTable~new(offset, chunks)

    offset         = super~getPersistent("Lowercase.Table1")
    chunks         = super~getPersistent("Lowercase.Table2")
    lowercase      = .MultiStageTable~new(offset, chunks)

    offset         = super~getPersistent("CaseAndCaseMappingBitProperties.Table1")
    chunks         = super~getPersistent("CaseAndCaseMappingBitProperties.Table2")
    bigvalues      = super~getPersistent("CaseAndCaseMappingBitProperties.Table3")
    caseproperties = .MultiStageTable~new(offset, chunks, , , 4, bigvalues)
  
    string         = super~getPersistent("SpecialUpper")
    
    SpecialUpper. = ""
    Do special Over string~makeArray(";")
      Parse var special code":"codes
      SpecialUpper.code = codes
    End
  End

::Method Math Class
  Expose mask. caseproperties
  Use Strict Arg code  
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Math) == mask.Math

::Method Alpha     Class
  Forward Message "Alphabetic"
::Method Alphabetic Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  If X2D(code) <= 131071 Then
    Return BITAND(caseproperties[X2D(code)], mask.Alphabetic) == mask.Alphabetic
  value    =  .Unicode.General_Category~hexValueOfPropertyAt(code)
  If value == .Unicode.General_Category~Lo_CJK_Compatibility_Ideograph Then Return 1
  If value == .Unicode.General_Category~Lo_CJK_Unified_Ideograph       Then Return 1
  Return 0

::Method Lower     Class
  Forward Message "Lowercase"
::Method Lowercase Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Lowercase) == mask.Lowercase
  
::Method Upper     Class
  Forward Message "Uppercase"  
::Method Uppercase Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Uppercase) == mask.Uppercase
  
::Method Cased Class  
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Cased) == mask.Cased
  
::Method CI             Class    
  Forward Message "Case_Ignorable"
::Method Case_Ignorable Class  
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  If X2D(code) <= 131071 Then
    Return BITAND(caseproperties[X2D(code)], mask.Case_Ignorable) == mask.Case_Ignorable
  n = X2D(code)
  If n <  X2D(E0001) Then Return 0
  If n == X2D(E0001) Then Return 1
  If n >= X2D(E0020), n <= X2D(E007F) Then Return 1
  If n >= X2D(E0100), n <= X2D(E01EF) Then Return 1
  Return 0
  
::Method CWL                     Class  
  Forward Message "Changes_When_Lowercased"
::Method Changes_When_Lowercased Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Changes_When_Lowercased) == mask.Changes_When_Lowercased

::Method CWU                     Class  
  Forward Message "Changes_When_Uppercased"
::Method Changes_When_Uppercased Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Changes_When_Uppercased) == mask.Changes_When_Uppercased

::Method CWT                     Class  
  Forward Message "Changes_When_Titlecased"
::Method Changes_When_Titlecased Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Changes_When_Titlecased) == mask.Changes_When_Titlecased

::Method CWCF                    Class
  Forward Message "Changes_When_Casefolded"
::Method Changes_When_Casefolded Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Changes_When_Casefolded) == mask.Changes_When_Casefolded

::Method CWCM                    Class
  Forward Message "Changes_When_Casemapped"
::Method Changes_When_Casemapped Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Changes_When_Casemapped) == mask.Changes_When_Casemapped

::Method Comp_Ex                    Class
  Forward Message "Full_Composition_Exclusion"
::Method Full_Composition_Exclusion Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  n = X2D(code)
  If n <  X2d("20000") Then
    Return BITAND(caseproperties[X2D(code)], mask.Full_Composition_Exclusion) == mask.Full_Composition_Exclusion
  If n <  X2D("2F800") Then Return 0
  If n <= X2D("2FA1D") Then Return 1
  Return 0

::Method NFD_QC          Class
  Forward Message "NFD_Quick_Check"
::Method NFD_Quick_Check Class
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  If self~NFD_QC_N(code) Then Return "N"
  Return "Y"

::Method NFD_QC_N Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  n = X2D(code)
  If n <  X2d("20000") Then
    Return BITAND(caseproperties[X2D(code)], mask.NFD_QC_N) == mask.NFD_QC_N
  If n <  X2D("2F800") Then Return 0
  If n <= X2D("2FA1D") Then Return 1
  Return 0

::Method NFC_QC          Class
  Forward Message "NFC_Quick_Check"
::Method NFC_Quick_Check Class
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  If self~NFC_QC_N(code) Then Return "N"
  If self~NFC_QC_M(code) Then Return "M"
  Return "Y"

::Method NFC_QC_N Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  n = X2D(code)
  If n <  X2D("20000") Then
    Return BITAND(caseproperties[X2D(code)], mask.NFC_QC_N) == mask.NFC_QC_N
  If n <  X2D("2F800") Then Return 0
  If n <= X2D("2FA1D") Then Return 1
  Return 0

::Method NFC_QC_M Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.NFC_QC_M) == mask.NFC_QC_M

::Method NFKD_QC          Class
  Forward Message "NFKD_Quick_Check"
::Method NFKD_Quick_Check Class
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  If self~NFKD_QC_N(code) Then Return "N"
  Return "Y"

::Method NFKD_QC_N Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  n = X2D(code)
  If n <  X2d("20000") Then
    Return BITAND(caseproperties[X2D(code)], mask.NFKD_QC_N) == mask.NFKD_QC_N
  If n <  X2D("2F800") Then Return 0
  If n <= X2D("2FA1D") Then Return 1
  Return 0

::Method NFKC_QC          Class
  Forward Message "NFKC_Quick_Check"
::Method NFKC_Quick_Check Class
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  If self~NFKC_QC_N(code) Then Return "N"
  If self~NFKC_QC_M(code) Then Return "M"
  Return "Y"

::Method NFKC_QC_N Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  n = X2D(code)
  If n <  X2d("20000") Then
    Return BITAND(caseproperties[X2D(code)], mask.NFKC_QC_N) == mask.NFKC_QC_N
  If n <  X2D("2F800") Then Return 0
  If n <= X2D("2FA1D") Then Return 1
  Return 0
  
::Method NFKC_QC_M Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.NFKC_QC_M) == mask.NFKC_QC_M

::Method Changes_When_NFKC_Casefolded Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  n = X2D(code)
  If n <  X2d("20000") Then
    Return BITAND(caseproperties[X2D(code)], mask.Changes_When_NFKC_Casefolded) == mask.Changes_When_NFKC_Casefolded
  If n <  X2D("2F800") Then Return 0
  If n <= X2D("2FA1D") Then Return 1
  If n <  X2D("E0000") Then Return 0
  If n <= X2D("E0FFF") Then Return 1
  Return 0

::Method OAlpha           Class
  Forward Message "Other_Alphabetic"
::Method Other_Alphabetic Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Other_Alphabetic) == mask.Other_Alphabetic

::Method OLower           Class
  Forward Message "Other_Lowercase"
::Method Other_Lowercase Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Other_Lowercase) == mask.Other_Lowercase

::Method OUpper           Class
  Forward Message "Other_Uppercase"
::Method Other_Uppercase Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Other_Uppercase) == mask.Other_Uppercase

::Method SD           Class
  Forward Message "Soft_Dotted"
::Method Soft_Dotted Class
  Expose mask. caseproperties
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  Return BITAND(caseproperties[X2D(code)], mask.Soft_Dotted) == mask.Soft_Dotted

::Method suc                      Class
  Forward Message "Simple_Uppercase_Mapping"
::Method Simple_Uppercase_Mapping Class
  Expose uppercase
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  
  n        = X2D(code)
  index    = X2D(C2X(uppercase[n]))
  If index == 0 Then Return code
  upper    = D2X( n + X2D(C2X(super~getPersistent("Uppercase.Differences")[index*4-3,4]),8) )
  If Length(upper) < 4 Then Return Right(upper, 4, 0)
  Return upper

::Method slc                      Class
  Forward Message "Simple_Lowercase_Mapping"
::Method Simple_Lowercase_Mapping Class
  Expose lowercase
  Use Strict Arg code
  If code[1] == "00"X, code~length == 4 Then code = C2X(code[2,3])
  n        = X2D(code)
  index    = X2D(C2X(lowercase[n]))
  If index == 0 Then Return code
  lower    = D2X( n + X2D(C2X(super~getPersistent("Lowercase.Differences")[index*4-3,4]),8) )
  If Length(lower) < 4 Then Return Right(lower, 4, 0)
  Return lower
  
-------------------------------------------------------------------------------
-- End of property methods                                                   --
-------------------------------------------------------------------------------

/*****************************************************************************/
/*  Maps a string to its corresponding Simple_Uppercase_Mapping              */
/*  as defined in UnicodeData.txt, with a number of exceptions, taken from   */
/*  SpecialCasing.txt. These exceptions are scanned at build time and        */
/*  stored in the 'SpecialUpper' persistent variable; then the 'activate'    */
/*  class method distributes them into the SpecialUpper. stem.               */
/*                                                                           */
/*  We also handle the special case of the Iota-subscript, as defined in     */
/*  SpecialCasing.txt.                                                       */
/*                                                                           */
/*  The name "toUppercase" is defined in "Default Case Conversion", rule R1, */
/*  same source, p. 154.                                                     */
/*                                                                           */
/*****************************************************************************/

::Method toUppercase Class
  Expose mask. SpecialUpper.
  
  Use Strict Arg string
  
  codepoints = .Codepoints~new(string)

  res     = ""
  changes = 0
  codes   = codepoints~C2U
  length  = Words(codes)
  Do i = 1 To length
    code = Word(codes,i)
  
    If code == "0345" Then Call Iota_subscript
    If SpecialUpper() Then Iterate
    
    upper = self~Simple_Uppercase_Mapping(code)
    If upper \== code Then changes = 1
    Else upper = code
    res     ||= UTF8(upper)
  End
  
  If \changes Then Return string
  
  Return res

Iota_subscript:
-- SpecialCasing.txt:
--
--   IMPORTANT-when iota-subscript (0345) is uppercased or titlecased,
--   the result will be incorrect unless the iota-subscript is moved to the end
--   of any sequence of combining marks. Otherwise, the accents will go on the capital iota.
--   This process can be achieved by first transforming the text to NFC before casing.
--   E.g. <alpha><iota_subscript><acute> is uppercased to <ALPHA><acute><IOTA>
  If i == length Then Return
  code2 = Word(codes,i+1)
  If .Unicode.General_Category[ code2 ][1] == "M" Then Do -- Combining Mark
    codes = SubWord(codes,1,i-1) code2 code SubWord(codes,i+2)
    code = code2
  End
  Return
 
SpecialUpper:
  UCodes = SpecialUpper.code
  If UCodes == "" Then Return 0
  Do k = 1 To Words(UCodes)
    res ||= UTF8(Word(UCodes,k))
  End
  changes = 1
  Return 1
 
::Method toLowercase Class
  Expose mask.
/*****************************************************************************/
/*  Maps a string to its corresponding Simple_Lowercase_Mapping              */
/*  as defined un UnicodeData.txt, with two exceptions, taken from           */
/*  SpecialCasing.txt:                                                       */
/*                                                                           */
/*     0130 --> 0069 0307  LATIN CAPITAL LETTER I WITH DOT ABOVE             */
/*     03A3 --> 03C2       Final greek sigma                                 */
/*                                                                           */
/*  The first case is not one-to one, and the second one is                  */
/*  context sensitive, as defined in The Unicode Standard. Version 15.0      */
/*  https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf  */
/*  table 3-17, p. 153.                                                      */
/*                                                                           */
/*  The name "toLowercase" is defined in "Default Case Conversion", rule R1, */
/*  same source, p. 154.                                                     */
/*                                                                           */
/*****************************************************************************/
  Use Strict Arg string
  
  codepoints = .Codepoints~new(string)

  res     = ""
  changes = 0
  codes   = codepoints~C2U
  length  = Words(codes)
  Do counter i code Over codes~makeArray(" ")
  
    -- Two non language-sensitive special cases 
    If code == "0130", CapitalIWithDotAbove() Then Iterate -- Not one-to-one: 0130 --> 0069 0307
    If code == "03A3", FinalSigma()           Then Iterate -- Context dependent
    
    lower = self~Simple_Lowercase_Mapping(code)
    If lower \== code Then changes = 1
    Else lower = code
    res     ||= UTF8(lower)
    
  End
  
  If \changes Then Return string
  
  Return string~class~new(res)
 
CapitalIWithDotAbove: -- 0130 --> 0069 0307
  res   ||= "69CC87"X
  changes = 1
Return 1
 
FinalSigma:
  Do n = i - 1 While n >= 1, self~Case_Ignorable(Word(codes,n)); End
  If n >= 1, \ self~Cased(Word(codes,n)) Then Return 0
  Do n = i + 1 While n <= length, self~Case_Ignorable(Word(codes,n))
  End
  If n <= length, self~Cased(Word(codes,n)) Then Return 0
  res ||= "CF82"X
  changes = 1
Return 1
  
::Routine UTF8
  Use Arg code
  If code~length < 4 Then code = Right(code,4,0)
  Do While code~length > 4, code[1] == 0
    code = Substr(code,2)
  End
  n = X2D(code)
  b = X2B(code)
  If b~length == 20 Then b = "0000"||b
  If b~length == 8, n >= 128 Then b = "0000"||b
  Select
    When n <= 127   Then Return X2C(code[3,2])
    When n <= 2047  Then Return X2C(B2X("110"SubStr(b,6,5)"10"Right(b,6)))
    When n <= 65535 Then Return X2C(B2X("1110"Left(b,4)"10"SubStr(b,5,6)"10"Right(b,6)))
    Otherwise            Return X2C(B2X("11110"SubStr(b,4,3) "10"SubStr(b,7,6) "10"SubStr(b,13,6) "10"Right(b,6)))
  End