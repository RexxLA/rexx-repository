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
/*  The UNICODE.NORMALIZATION class                                          */
/*  ===============================                                          */
/*                                                                           */
/* See Unicode Standard Annex #15. UNICODE NORMALIZATION FORMS               */
/* https://unicode.org/reports/tr15/                                         */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.4b JMB 20231014 Initial release. Implements toNFD                     */
/*                                                                           */
/*****************************************************************************/

::Class Unicode.Normalization Public SubClass Unicode.Property

::Constant BinaryFile                           "normalization.bin"  

::Constant Normalization.Properties             "Canonical_Decomposition Canonical_Combining_Class"
::Constant Normalization.Aliases                "=                       ccc"

--
-- Activate is automatically called at the end of class initialization.
--
 
::Method Activate Class
  Expose canonicalCombiningClass Canonical_Decomposition. canonicalDouble canonicalDoubleFirsts canonicalDoubleLasts CJK_2F800_2FA1D CJK_F900_FAD9

  -- Inform the registry that we will be handling these properties, functions and aliases
  
  super~registerFunctions(  "toNFD", self )
  super~registerProperties( self~Normalization.Properties, self~Normalization.Aliases, self )
      
  If .Unicode.Buildtime \== 1 Then Do
    super~loadPersistent( super~BinFile.Qualify( self~binaryFile ) ) 
    
    table1                  = super~getPersistent("UnicodeData.normalization.canonicalDouble.Table1")
    table2                  = super~getPersistent("UnicodeData.normalization.canonicalDouble.Table2")
    
    -- Chunk size should be coordinated with the build utility of the same name in /components/bin/build
    
    canonicalDouble         = .MultiStageTable~new(table1,table2,,128,2)

    table1                  = super~getPersistent("UnicodeData.normalization.canonicalCombiningClass.Table1")
    table2                  = super~getPersistent("UnicodeData.normalization.canonicalCombiningClass.Table2")
    
    -- Chunk size should be coordinated with the build utility of the same name in /components/bin/build
    
    canonicalCombiningClass = .MultiStageTable~new(table1,table2, ,64)
    
    canonicalDoubleFirsts   = super~getPersistent("UnicodeData.normalization.canonicalDoubleFirsts")
    canonicalDoubleLasts    = super~getPersistent("UnicodeData.normalization.canonicalDoubleLasts")
    CJK_2F800_2FA1D         = super~getPersistent("UnicodeData.normalization.CJK_2F800_2FA1D")
    CJK_F900_FAD9           = super~getPersistent("UnicodeData.normalization.CJK_F900_FAD9")

  End
  
-- Canonical decomposition, singletons
--
-- In the 15.0 version of UnicodeData.txt, most canonical decomposable
-- characters are CJK COMPATIBILITY IDEOGRAPH F900 to FAD9 (some few
-- characters in this range are not decomposable) and 2F800 to
-- 2FA1D.
--
-- The rest of the characters are:
--
-- 0340, 0341, 0343, 0374, 037E, 0387;
-- 1F71, 1F73, 1F75, 1F77, 1F79, 1F7B, 1F7D, 1FBB, 1FBE, 1FC9, 1FCB, 1FD3, 1FDB, 1FE3, 1FEB, 1FEE, 1FEF, 1FF9, 1FFB, 1FFD;
-- 2000, 2001;
-- 2126, 212A, 212B;
-- 2329, 232A.
--
--  
  
  Canonical_Decomposition.    = "Same"
  Canonical_Decomposition.03  = "03"
  Canonical_Decomposition.1F  = "1F"
  Canonical_Decomposition.20  = "20"
  Canonical_Decomposition.21  = "21"
  Canonical_Decomposition.23  = "23"
  Do i = X2D(AC) To X2D(D7)
    x = D2X(i)
    Canonical_Decomposition.x = "Hangul_Syllabe"
  End
  Canonical_Decomposition.F9  = "CJK_FXXX"
  Canonical_Decomposition.FA  = "CJK_FXXX"
  Canonical_Decomposition.2F8 = "CJK_2FXXX"
  Canonical_Decomposition.2F9 = "CJK_2FXXX"
  Canonical_Decomposition.2FA = "CJK_2FXXX"

::Method Canonical_Combining_Class Class
  Expose canonicalCombiningClass

  Use Strict Arg code
  
  If code~startsWith("00"X) Then code = C2X(code)
  code = StripZeros(Upper(code))
  If Length(code) < 4 Then code = Right(code,4,0)
  
  n   = X2D(code)
  
  Return canonicalCombiningClass[n]
  
StripZeros: 
  Arg aCode
  Do While Length(aCode) > 4, aCode~startsWith(0)
    aCode = SubStr(aCode,2)
  End
Return aCode  

::Method Canonical_Decomposition   Class
  Expose Canonical_Decomposition. canonicalDouble canonicalDoubleFirsts canonicalDoubleLasts CJK_2F800_2FA1D CJK_F900_FAD9
  
  Use Strict Arg code
  
  If code~startsWith("00"X) Then code = C2X(code)
  code = StripZeros(Upper(code))
  If Length(code) < 4 Then code = Right(code,4,0)
  
  n   = X2D(code)
  
  -- Non-singletons
  bin = canonicalDouble[n]~c2x~x2d
  If bin \== 0 Then Do
    lastOffset  = bin %  512
    firstOffset = bin // 512
    first = C2X(canonicalDoubleFirsts[1-3+firstOffset*3,3])
    last  = C2X(canonicalDoubleLasts[ 1-3+lastOffset *3,3])
    Return StripZeros(first) StripZeros(last)
  End
  
  co = code~left(Length(code)-2)
  Signal (Canonical_Decomposition.co)

StripZeros: 
  Arg aCode
  Do While Length(aCode) > 4, aCode~startsWith(0)
    aCode = SubStr(aCode,2)
  End
Return aCode

"Same": Return code

03:
  xx = code[3,2]
  If xx << "40" Then Return code
  If xx >> "87" Then Return code
  Select Case code
    When 0340 Then Return 0300
    When 0341 Then Return 0301
    When 0343 Then Return 0313
    When 0374 Then Return 02B9
    When 037E Then Return 003B
    When 0387 Then Return 00B7
    Otherwise      Return code
  End

1F:
  If code[3,2] << "71" Then 
                   Return code
  Select Case code
    When 1F71 Then Return 03AC
    When 1F73 Then Return 03AD
    When 1F75 Then Return 03AE
    When 1F77 Then Return 03AF
    When 1F79 Then Return 03CC
    When 1F7B Then Return 03CD
    When 1F7D Then Return 03CE
    When 1FBB Then Return 0386
    When 1FBE Then Return 03B9
    When 1FC9 Then Return 0388
    When 1FCB Then Return 0389
    When 1FD3 Then Return 0390
    When 1FDB Then Return 038A
    When 1FE3 Then Return 03B0
    When 1FEB Then Return 038E
    When 1FEE Then Return 0385
    When 1FEF Then Return 0060
    When 1FF9 Then Return 038C
    When 1FFB Then Return 038F
    When 1FFD Then Return 00B4  
    Otherwise      Return code
  End  

20:
  Select Case code
    When 2000 Then Return 2002
    When 2001 Then Return 2003
    Otherwise      Return code
  End

21:
  Select Case code
    When 2126 Then Return 03A9
    When 212A Then Return 004B
    When 212B Then Return 00C5
    Otherwise      Return code
  End

23:
  Select Case code
    When 2329 Then Return 3008
    When 232A Then Return 3009
    Otherwise      Return code
  End
    
-- There are no decompositions for codepoints D7xx higher than D7A3
"Hangul_Syllabe":
  If code >> D7A3 Then Return code
  -- See https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, pp. 144ss
  SBase     = AC00~x2d
  LBase     = 1100~x2d
  VBase     = 1161~x2d
  TBase     = 11A7~x2d
  LCount    = 19
  VCount    = 21
  TCount    = 28
  NCount    = 588   -- (VCount * TCount)
  SCount    = 11172 -- (LCount * NCount)  
  SIndex    = code~x2d - SBase
  LIndex    = (SIndex %  NCount)
  VIndex    = (SIndex // NCount) % TCount
  TIndex    = (SIndex // TCount)
  If TIndex > 0 Then Do
    LVIndex = (SIndex % TCount) * TCount
    Return  D2X(SBase + LVIndex) D2X(TBase + TIndex)
  End
  Return    D2X(LBase + LIndex) D2X(VBase + VIndex)
    
-- There are no decompositions for codepoints 2FAxx higher than 2FA1D
-- All the codepoints have a decomposition
CJK_2FXXX:
  If code >> 2FA1D Then Return code
  Return StripZeros(CJK_2F800_2FA1D[3*(X2D(code)-X2D(2F800))+1,3]~C2X)
  
-- There are no decompositions for codepoints FAxx higher than FAD9
-- Not all the codepoints have a decomposition
CJK_FXXX:
  If code >> FAD9 Then Return code
  decomp = CJK_F900_FAD9[3*(X2D(code)-X2D(F900))+1,3]~C2X
  If decomp == "000000" Then Return code
  Return StripZeros(CJK_F900_FAD9[3*(X2D(code)-X2D(F900))+1,3]~C2X)
    
--------------------------------------------------------------------------------    
-- Method toNFD                                                               --
--------------------------------------------------------------------------------    
    
::Method toNFD Class
  Use Strict arg string, failingPos = 1
  
  utf32 = string~c2u("UTF32")
  
  buffer = .Array~new
  
  Do i = 1 To Length(utf32) By 4
    code = StripZeros(C2X(utf32[i,4]))
    codes = self~Canonical_Decomposition(code)
    If code == codes Then Do
      buffer~append(code)
      Iterate
    End
    Parse Value codes With first rest
    Do While Length(first) > 0
      codes = self~Canonical_Decomposition(first)
      If codes == first Then Do
        buffer~append(first)
        Parse Value rest With first rest
        Iterate
      End
      Parse Value codes rest With first rest
    End
  End
  
  -- Cfr. https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, p. 137
  --
  -- D108 Reorderable pair: Two adjacent characters A and B in a coded character sequence
  -- <A, B> are a Reorderable Pair if and only if ccc(A) > ccc(B) > 0. 
  --
  -- D109 Canonical Ordering Algorithm: In a decomposed character sequence D, exchange
  -- the positions of the characters in each Reorderable Pair until the sequence contains
  -- no more Reorderable Pairs. 
  
  Do i = 2 To buffer~items
    A = buffer[i-1]
    B = buffer[i]
    cccB = self~Canonical_Combining_Class(B) 
    If cccB \== "00"X Then Do
      cccA = self~Canonical_Combining_Class(A) 
      If cccA >> cccB Then Do
        temp = buffer[i-1]
        buffer[i-1] = buffer[i]
        buffer[i] = temp
        i = i - 1
        Iterate
      End
    End
  End
  
  utf8 = .MutableBuffer~new -- Will hold the result
  
  Do i = 1 To buffer~items
    utf8~append(UTF8(buffer[i]))
  End
    
Return utf8~string  
 
StripZeros: 
  Arg aCode
  Do While Length(aCode) > 4, aCode~startsWith(0)
    aCode = SubStr(aCode,2)
  End
Return aCode
  
UTF8: Procedure
  Use Arg code
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
  
::Requires "properties.cls"  