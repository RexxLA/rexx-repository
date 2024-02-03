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

.local~Unicode.Normalization = .Unicode.Normalization

::Class Unicode.Normalization Public SubClass Unicode.Property

::Constant BinaryFile                           "normalization.bin"  

::Constant PrimaryComposite                     "Unicode.PrimaryComposite.rex"  

::Constant Normalization.Properties             "Canonical_Decomposition_Mapping Canonical_Combining_Class ccc"

--
-- Activate is automatically called at the end of class initialization.
--
 
::Method Activate Class
  Expose canonicalCombiningClass Canonical_Decomposition_Mapping. canonicalDouble canonicalDoubleFirsts canonicalDoubleLasts CJK_2F800_2FA1D CJK_F900_FAD9 -
         PrimaryCompositeLastSuffixes PrimaryCompositeFirstPrefixes PrimaryCompositeFirstSuffix  

  -- Inform the registry that we will be handling these properties and functions
  
  super~registerFunctions(  "toNFC toNFD", self )
  super~registerProperties( self~Normalization.Properties, self )
      
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
  
  Canonical_Decomposition_Mapping.    = "Same"
  Canonical_Decomposition_Mapping.03  = "03"
  Canonical_Decomposition_Mapping.1F  = "1F"
  Canonical_Decomposition_Mapping.20  = "20"
  Canonical_Decomposition_Mapping.21  = "21"
  Canonical_Decomposition_Mapping.23  = "23"
  Do i = X2D(AC) To X2D(D7)
    x = D2X(i)
    Canonical_Decomposition_Mapping.x = "Hangul_Syllabe"
  End
  Canonical_Decomposition_Mapping.F9  = "CJK_FXXX"
  Canonical_Decomposition_Mapping.FA  = "CJK_FXXX"
  Canonical_Decomposition_Mapping.2F8 = "CJK_2FXXX"
  Canonical_Decomposition_Mapping.2F9 = "CJK_2FXXX"
  Canonical_Decomposition_Mapping.2FA = "CJK_2FXXX"
  
  --
  -- Primary Composite, an ordered pair <first, last>
  -- last: lastPrefix*256 + lastSuffix
  --
  --
  -- PrimaryCompositeLastSuffixes
  -- ----------------------------
  --
  -- An array containing the (modulo 256) suffixes of Primary Composite last components
  --
  -- First byte: a distinguishing counter
  -- Bytes 2..length: the different suffixes
  --
  PrimaryCompositeLastSuffixes  = .Array~new

  --
  -- PrimaryCompositeFirstPrefixes
  -- -----------------------------
  --
  -- An array, indexed by the first byte of PrimaryCompositeLastSuffixes[last % 256]
  --
  -- Every element of PrimaryCompositeFirstPrefixes[last % 256] is itself an array, indexed
  -- by the position of the suffix (last // 256) in the suffix string found in PrimaryCompositeLastSuffixes
  --
  -- Every component of this array is a binary string composed of:
  --
  -- Byte 01: The ccc property of "last"
  -- Byte 02: One of:
  --         "01"X: All the "first" and "last" values share the same prefix
  --         "02"X: All the "first" values have a prefix of "0000"X (i.e., they are all of the form "0000hh"X)
  --         "00"X: There are "first" values with different prefixes
  -- When byte 02 is "01"X, then:
  --    Byte  03: Number ("N") of different "first" suffixes
  --    Bytes 04 to 04+N-1: "first" suffixes (1 byte each)
  --          04+N to 04+N + 3*N: the corresponding composites (3 bytes each)
  -- When byte 02 is "02"X, then: 
  --    Byte  03: Number ("N") of different "first" suffixes
  --    Bytes 04 to 04+N-1: "first" suffixes (1 byte each)
  --          04+N to 04+N + 3*N: the corresponding composites (3 bytes each)
  -- When byte 02 is "00"X, then:
  --    Byte  03: Number ("N") of different "first" PREfixes
  --    Bytes 04 to 04+N-1: "first" PREfixes (1 byte each; heuristics indicate that they are all of the form 00xxyy)
  --
  PrimaryCompositeFirstPrefixes = .Array~new

  --
  -- PrimaryCompositeFirstSuffix
  -- ---------------------------
  --
  -- When PrimaryCompositeFirstPrefixes[index1, index2] byte 02 is "00"X, then
  -- PrimaryCompositeFirstSuffix contains:
  --   1) a list of the "first" suffixes (1 byte each), and
  --   2) A list of the primary composites (three bytes each).
  -- The number of suffixes and composites is Length(PrimaryCompositeFirstSuffix) / 4.

  PrimaryCompositeFirstSuffix   = .Array~new

  -- Make array non-sparse, access is faster
  -- Heuristics: maximum prefix is "0119"X
  Do i = 1 To 0119~x2d
    PrimaryCompositeLastSuffixes[i] =  ""
  End
  
  Call ( super~BinFile.Qualify( self~PrimaryComposite ) ) PrimaryCompositeLastSuffixes, PrimaryCompositeFirstPrefixes, PrimaryCompositeFirstSuffix    
      
::Method ccc                       Class
  Forward Message "Canonical_Combining_Class" 
::Method Canonical_Combining_Class Class
  Expose canonicalCombiningClass

  Use Strict Arg code
  
  If code~startsWith("00"X) Then code = C2X(code)
  
  code = NiceCode(Upper(code))
    
  Return X2D(C2X( canonicalCombiningClass[ X2D(code) ] ))
  
NiceCode: 
  Arg aCode
  aCode = Strip(aCode,"L",0)
  If Length(aCode) < 4 Then aCode = Right(aCode,4,0)
Return aCode  

::Method Canonical_Composition32           Class
  Expose PrimaryCompositeLastSuffixes PrimaryCompositeFirstPrefixes PrimaryCompositeFirstSuffix  
  Use Strict Arg utf32
    
  lutf32 = Length(utf32)
  
  -- Empty string, or only one char? Nothing to do.
  If lutf32 <= 4 Then Return utf32
    
  -- Hangul constants
  NCount  = 588 
  SCount  = 11172
  TCount  = 28
  SBase   = AC00~x2d
  TBase   = 11A7~x2d
  
  i = 1
  Loop Label StarterLoop i = i By 4
  
    -- p. 136 "D107 Starter: Any code point (assigned or not) with combining class of zero (ccc = 0)".
    --
    -- Have to use .Unicode instead of Unicode because the loading order of our packages doesn't make
    -- the Unicode public routine known to this package.
    Do i = i To lutf32 By 4 Until .Unicode[starter,"Property","ccc"] == 0
      starter = utf32[i,4]
    End
    
    maxCCC = 0
    
    -- Start looking at char after starter
    j = i + 4
    
    Loop Label LastLoop
      -- No starter found, or starter is last character in string
      If j > lutf32 Then Return utf32
    
      last = utf32[j,4]
  
      -- Hangul: Case LV + T
      If starter >>= "0000 AC00"X, starter <<= "0000 D7A3"X Then Do
        LV = (starter~c2x~right(4)~x2d - AC00~x2d) // 28
        If LV == 0, last >>= "0000 11A8"X, last <<= "0000 11C2"X Then Do
          TIndex = last   ~c2x~right(4)~x2d - TBase
          s      = starter~c2x~right(4)~x2d + TIndex
          utf32[i,8] = Right(s~d2x~x2c,4,"00"X)
          lutf32 = Length(utf32)
          Iterate StarterLoop
        End
      End
      
      -- Hangul starter (L)...
      If starter >>= "0000 1100"X, starter <<= "0000 1112"X Then Do
        -- Hangul L+V...
        If last >>= "0000 1161"X, last <<= "0000 1175"X Then Do
          LIndex  = starter~c2x~right(4)~x2d - 1100~x2d
          VIndex  = last   ~c2x~right(4)~x2d - 1161~x2d
          LVIndex = LIndex * NCount + VIndex * TCount
          If j + 4 <= lutf32 Then Do
            TPart = utf32[j + 4,4]
            -- Hangul: Case L + V + T
            If TPart >>= "0000 11A8"X, TPart <<= "0000 11C2"X Then Do
              TIndex = TPart~c2x~right(4)~x2d - TBase
              s      = SBase + LVIndex + TIndex
              utf32[i,12] = Right(s~d2x~x2c,4,"00"X)
              lutf32 = Length(utf32)
              Iterate StarterLoop
            End
          End
          -- Hangul: Case L + V
          s = SBase + LVIndex
          utf32[i,8] = Right(s~d2x~x2c,4,"00"X)
          lutf32 = Length(utf32)
          Iterate StarterLoop
        End
        Iterate StarterLoop
      End
  
      newCCC = .Unicode[last,"Property", "ccc"]
      If 0 < newCCC Then Do
        If newCCC < maxCCC      Then Iterate StarterLoop -- Look for next starter
        Else If newCCC = maxCCC Then Do -- This one is blocked, but maybe next one is not
          j += 4
          Iterate LastLoop
        End
      End
      -- If newCCC == 0 and maxCCC > 0, we have a new starter
      Else If maxCCC > 0 Then Do
        i = j - 4
        Iterate StarterLoop
      End      
 
      subst = PrimaryComposite(starter, last)
      If subst == "" Then Do
        If newCCC == 0 Then Do
          i = j - 4
          Iterate StarterLoop -- Look for another starter
        End
        Else Do
          maxCCC = newCCC
          j += 4
          Iterate LastLoop
        End
      End
      utf32[j,4] = ""
      utf32[i,4] = subst
      lutf32 = Length(utf32)
      starter = utf32[i,4]
      i = i - 4
      Iterate StarterLoop
    End
  End

PrimaryComposite: Procedure Expose PrimaryCompositeLastSuffixes PrimaryCompositeFirstPrefixes PrimaryCompositeFirstSuffix
  Use Strict Arg first, last
  
  -- Calculate prefix = last % 256
  prefix      = last[1,3]
  
  -- Case prefix = 0 handled manually, to avoid syntax error
  If prefix  == "000000"X Then Return ""
  
  -- Heuristics
  If prefix  >> "000119"X Then Return ""
  
  -- Calculate prefix = last % 256, and use if as an index
  suffixes    = PrimaryCompositeLastSuffixes[ prefix~c2x~x2d ]

  -- suffixes is "" if there is no <first, last> that is a primary composite
  If suffixes  == "" Then index2 = -1
  -- otherwise, suffixes[2..*] contains possible suffixes
  Else index2     = Pos(last[4], suffixes, 2) - 1
  
  -- index2 == -1 means that this "last" forms no suitable pair
  If index2 == -1 Then Return ""
  
  -- The first byte of "suffixes" is an index we will be using
  index1       = suffixes[1]~c2x~x2d
  
  -- ccc + class + first suffixes
  suffixes     = PrimaryCompositeFirstPrefixes[index1][index2]
  class        = suffixes[2]
  
  Select
    -- There are suitable "first" values with different prefixes
    -- Heuristics: all these prefixes are in the "00"X.."FF"X range
    When class == "00"X Then Do
      index3   = Pos(first[3], suffixes,3) - 2
      If index3 == -2 Then Return ""
      If first[1,2] \== "0000"X Then Return ""
      -- Get a list of suitable suffixes
      suffixes = PrimaryCompositeFirstSuffix[index1, index2, index3]
      index4 = Pos(first[4], suffixes, 1, Length(suffixes) / 4)
      If index4 == 0 Then Return ""
      Return "00"X || SubStr(suffixes, Length(suffixes) / 4 + 1 + (index4-1)* 3, 3)
    End
    -- All the suitable "first" values have the same prefix as "last"
    When class == "01"X Then Do
      If first[1,3] \== prefix Then Return ""
      Signal 0102Common
    End
    -- All the suitable "first" values are in the "00"X.."FF"X range
    When class == "02"X Then Do
      If first[1,3] \== "000000"X Then Return ""
      Signal 0102Common
    End
  End

0102Common:
  pos      = Pos(first[4], suffixes,3, (Length(suffixes)-2)/4) - 2  
  If pos   == -2 Then Return ""
  Return "00"X || SubStr(suffixes, 2 + (Length(suffixes)-2)/4 + (pos-1)* 3 + 1, 3)
  
::Method Canonical_Decomposition_Mapping   Class
  Expose Canonical_Decomposition_Mapping. canonicalDouble canonicalDoubleFirsts canonicalDoubleLasts CJK_2F800_2FA1D CJK_F900_FAD9
  
  Use Strict Arg code
  
  If code~startsWith("00"X) Then code = C2X(code)
  code = NiceCode(Upper(code))
  
  n   = X2D(code)
  
  -- Non-singletons
  bin = canonicalDouble[n]~c2x~x2d
  If bin \== 0 Then Do
    lastOffset  = bin %  512
    firstOffset = bin // 512
    first = C2X(canonicalDoubleFirsts[1-3+firstOffset*3,3])
    last  = C2X(canonicalDoubleLasts[ 1-3+lastOffset *3,3])
    Return NiceCode(first) NiceCode(last)
  End
  
  co = code~left(Length(code)-2)
  Signal (Canonical_Decomposition_Mapping.co)

NiceCode: 
  Arg aCode
  aCode = Strip(aCode,"L",0)
  If Length(aCode) < 4 Then aCode = Right(aCode,4,0)
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
  Return NiceCode(CJK_2F800_2FA1D[3*(X2D(code)-X2D(2F800))+1,3]~C2X)
  
-- There are no decompositions for codepoints FAxx higher than FAD9
-- Not all the codepoints have a decomposition
CJK_FXXX:
  If code >> FAD9 Then Return code
  decomp = CJK_F900_FAD9[3*(X2D(code)-X2D(F900))+1,3]~C2X
  If decomp == "000000" Then Return code
  Return NiceCode(CJK_F900_FAD9[3*(X2D(code)-X2D(F900))+1,3]~C2X)

--------------------------------------------------------------------------------
-- UTF-32 version of Canonical_Decomposition_Mapping
--------------------------------------------------------------------------------

::Method Canonical_Decomposition_Mapping32 Class
  Expose Canonical_Decomposition_Mapping. canonicalDouble canonicalDoubleFirsts canonicalDoubleLasts CJK_2F800_2FA1D CJK_F900_FAD9
  
  Use Strict Arg code
  
--If code == "0001 F071"X Then Trace ?a  
  
  xcode = Substr(code~c2x,3)
  If Length(xcode) > 4, xcode[1] == "0" Then xcode = Substr(xcode,2)
  If Length(xcode) > 4, xcode[1] == "0" Then xcode = Substr(xcode,2)

  -- Non-singletons
  bin = canonicalDouble[xcode~x2d]~c2x~x2d
  If bin \== 0 Then Do
    lastOffset  = bin %  512
    firstOffset = bin // 512
    first = canonicalDoubleFirsts[1-3+firstOffset*3,3]
    last  = canonicalDoubleLasts[ 1-3+lastOffset *3,3]
    Return "00"X || first || "00"X || last
  End
  
  co = xcode~left(Length(xcode)-2)
  Signal (Canonical_Decomposition_Mapping.co)

"Same": Return code

03:
  xx = code[4]
  If xx << "40"X Then Return code
  If xx >> "87"X Then Return code
  Select Case xx
    When "40"X Then Return "0000 0300"X
    When "41"X Then Return "0000 0301"X
    When "43"X Then Return "0000 0313"X
    When "74"X Then Return "0000 02B9"X
    When "7E"X Then Return "0000 003B"X
    When "87"X Then Return "0000 00B7"X
    Otherwise       Return code
  End

1F:
  xx = code[4]
  If xx << "71"X Then Return code
  Select Case xx
    When "71"X   Then Return "0000 03AC"X
    When "73"X   Then Return "0000 03AD"X
    When "75"X   Then Return "0000 03AE"X
    When "77"X   Then Return "0000 03AF"X
    When "79"X   Then Return "0000 03CC"X
    When "7B"X   Then Return "0000 03CD"X
    When "7D"X   Then Return "0000 03CE"X
    When "BB"X   Then Return "0000 0386"X
    When "BE"X   Then Return "0000 03B9"X
    When "C9"X   Then Return "0000 0388"X
    When "CB"X   Then Return "0000 0389"X
    When "D3"X   Then Return "0000 0390"X
    When "DB"X   Then Return "0000 038A"X
    When "E3"X   Then Return "0000 03B0"X
    When "EB"X   Then Return "0000 038E"X
    When "EE"X   Then Return "0000 0385"X
    When "EF"X   Then Return "0000 0060"X
    When "F9"X   Then Return "0000 038C"X
    When "FB"X   Then Return "0000 038F"X
    When "FD"X   Then Return "0000 00B4"X  
    Otherwise         Return code
  End  

20:
  Select Case code[4]
    When "00"X   Then Return "0000 2002"X
    When "01"X   Then Return "0000 2003"X
    Otherwise         Return code
  End

21:
  Select Case code[4]
    When "26"X   Then Return "0000 03A9"X
    When "2A"X   Then Return "0000 004B"X
    When "2B"X   Then Return "0000 00C5"X
    Otherwise         Return code
  End

23:
  Select Case code[4]
    When "29"X   Then Return "0000 3008"X
    When "2A"X   Then Return "0000 3009"X
    Otherwise         Return code
  End
    
-- There are no decompositions for codepoints D7xx higher than D7A3
"Hangul_Syllabe":
  If code >> "0000 D7A3"X Then Return code
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
  SIndex    = xcode~x2d - SBase
  LIndex    = (SIndex %  NCount)
  VIndex    = (SIndex // NCount) % TCount
  TIndex    = (SIndex // TCount)
  If TIndex > 0 Then Do
    LVIndex = (SIndex % TCount) * TCount
    Return  X2C(D2X(SBase + LVIndex,8))X2C(D2X(TBase + TIndex,8))
  End
  Return    X2C(D2X(LBase + LIndex,8))X2C(D2X(VBase + VIndex,8))
    
-- There are no decompositions for codepoints 2FAxx higher than 2FA1D
-- All the codepoints have a decomposition
CJK_2FXXX:
  If code >> "0002 FA1D"X Then Return code
  Return "00"X||CJK_2F800_2FA1D[3*(X2D(C2X(code))-X2D(2F800))+1,3]
  
-- There are no decompositions for codepoints FAxx higher than FAD9
-- Not all the codepoints have a decomposition
CJK_FXXX:
  If code >> "0000 FAD9"X Then Return code
  decomp = CJK_F900_FAD9[3*(X2D(C2X(code))-X2D(F900))+1,3]
  If decomp == "000000"X Then Return code
  Return "00"X||decomp


--------------------------------------------------------------------------------    
-- Method toNFC                                                               --
--------------------------------------------------------------------------------    
    
::Method toNFC Class
  Use Strict arg string, failingPos = 1
  If \string~isA(.Codepoints) Then string = .Codepoints~new( string )
  
  -- TODO Optimize that, but beware of loops:
  -- If string~isNFC Then Return string
    
  nfd32 = .Codepoints~new( self~toNFD(string) )~c2u("UTF32")
  
  nfc32 = self~Canonical_Composition32( .MutableBuffer~new(nfd32) )
  
  utf8 = .MutableBuffer~new -- Will hold the result
  
  Do i = 1 To nfc32~length By 4
    code = nfc32[i+1,3]~c2x
    If code << "010000" Then code = Substr(code,3)
    Else If code << "100000" Then code = Substr(code,2)
    utf8~append(UTF8( code ))
  End
    
  Return string~class~new(utf8~string)

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
 
--------------------------------------------------------------------------------    
-- Method toNFD                                                               --
--------------------------------------------------------------------------------    
    
::Method toNFD Class
  Use Strict arg string, failingPos = 1
  
  -- TODO: Take a look at that:
  --
  -- "14.1.3 Optimizing Tables for NFD Quick Check
  -- "The values of the Canonical_Combining_Class property are constrained by the character encoding stability guarantees to the range 0..254; 
  --  the value 255 will never be assigned for a Canonical_Combining_Class value. Because of this constraint, implementations can make use of 255 
  --  as an implementation-specific value for optimizing data tables. For example, one can do a fast and compact table for implementing isNFD(x) 
  --  by using the value 255 to represent NFKC_QC=No."
  --  (https://www.unicode.org/reports/tr15/tr15-53.html)
    
  If \string~isA(.Codepoints) Then string = CODEPOINTS(string)
  
  If string~isNFD Then Return string
  
  utf32 = string~c2u("UTF32")
  
  buffer = .Array~new
  
  Do i = 1 To Length(utf32) By 4
    code = NiceCode(C2X(utf32[i,4]))
    codes = self~Canonical_Decomposition_Mapping(code)
    If code == codes Then Do
      buffer~append(code)
      Iterate
    End
    Parse Value codes With first rest
    Do While Length(first) > 0
      codes = self~Canonical_Decomposition_Mapping(first)
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
    A = buffer[i - 1]
    B = buffer[i    ]
    cccB = self~Canonical_Combining_Class(B) 
    If cccB \== 0 Then Do
      cccA = self~Canonical_Combining_Class(A) 
      If cccA > cccB Then Do
        temp = buffer[i-1]
        buffer[i-1] = buffer[i]
        buffer[i] = temp
        i = Max(i-2,1)
        Iterate
      End
    End
  End
  
  utf8 = .MutableBuffer~new -- Will hold the result
  
  Do i = 1 To buffer~items
    utf8~append(UTF8(buffer[i]))
  End
      
Return string~class~new( utf8~string )
 
NiceCode: 
  Arg aCode
  aCode = Strip(aCode,"L",0)
  If Length(aCode) < 4 Then aCode = Right(aCode,4,0)
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


--------------------------------------------------------------------------------    
-- Method toNFD32                                                             --
--------------------------------------------------------------------------------    
    
::Method toNFD32 Class
  Use Strict arg utf32
    
  buffer = .MutableBuffer~new
  
  Do i = 1 To Length(utf32) By 4
    code = NiceCode(C2X(utf32[i,4]))
    codes = self~Canonical_Decomposition_Mapping(code)
    If code == codes Then Do
      buffer~append(code)
      Iterate
    End
    Parse Value codes With first rest
    Do While Length(first) > 0
      codes = self~Canonical_Decomposition_Mapping(first)
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
    A = buffer[i - 1]
    B = buffer[i    ]
    cccB = self~Canonical_Combining_Class(B) 
    If cccB \== 0 Then Do
      cccA = self~Canonical_Combining_Class(A) 
      If cccA > cccB Then Do
        temp = buffer[i-1]
        buffer[i-1] = buffer[i]
        buffer[i] = temp
        i = Max(i-2,1)
        Iterate
      End
    End
  End
  
  utf8 = .MutableBuffer~new -- Will hold the result
  
  Do i = 1 To buffer~items
    utf8~append(UTF8(buffer[i]))
  End
      
Return string~class~new( utf8~string )
 
NiceCode: 
  Arg aCode
  aCode = Strip(aCode,"L",0)
  If Length(aCode) < 4 Then aCode = Right(aCode,4,0)
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