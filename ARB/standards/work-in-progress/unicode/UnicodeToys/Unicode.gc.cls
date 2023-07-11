
--
-- Running this file (or ::requiring it) will generate the binary
-- file if not present.
--
-- .Unicode.GC~Consistency_Check will run an internal consistency check
-- that takes some few seconds.
--
/*
Say   0000 GC(0000)
Say   0010 GC(0010)
Say   001F GC(001F)
Say   0020 GC(0020)
Say   0110 GC(0110)
Say   0210 GC(0210)
Say   1210 GC(1210)
Say   200f GC(200F)
Say   8010 GC(8010)
Say  18010 GC(18010)
Say  1a010 GC(1A010)
Say  1f010 GC(1F010)
Say 10FFFD GC(10FFFD)
Say 10FFFE GC(10FFFE)
Say   8010 Algorithmic_name_start(8010)
Say   FA10 Algorithmic_name_start(FA10)
Say   FA11 Algorithmic_name_start(FA11)
*/


-- Returns the "General_Category" (GC) property

::Routine GC Public
  Use Strict Arg code
  Call CheckCode code
  Return .Unicode.GC[code]

-- Returns the start of the algorithmic name, or ""
  
::Routine Algorithmic_name_start Public  
  Use Strict Arg code
  Call CheckCode code
  Return .Unicode.GC~algorithmic_name_start(code)

-- Some private routines  
  
::Routine Error Private
  Raise Syntax 98.900 Additional(Arg(1))  

::Routine CheckCode Private
  Use Strict Arg code
  bad = Verify(code,"0123456789ABCDEFabcdef")
  If bad > 0 Then 
    Call Error "Codepoints should be composed only of hexadecimal digits, found '"code[bad]"'"
  If Length(code) < 4 | Length(code) > 6 Then
    Call Error "Codepoint length should be 4, 5 or 6 hexadecimal digits, found '"code"'"
  If Length(code) \== 4, code[1] == "0" Then
    Call Error "Codepoints longer than four characters cannot start with zero, found '"code"'"
  If X2d( code ) > X2D( 10FFFF ) Then
    Call Error "Codepoints should not be bigger than 10FFFF, found '"code"'"
Return

::Routine Log Private
  Parse Source . . myself
  Say "["myself"]" Arg(1)

--------------------------------------------------------------------------------
--                                                                            --
-- CLASS UNICODE.GC                                                           --
--                                                                            --
-- Implements the General_Category property.                                  --
--                                                                            --
-- As a bonus, it includes a method that returns the first part               --
-- of the Name property, when that property is algorithmically computable.    --
--                                                                            --
--------------------------------------------------------------------------------

::Class Unicode.GC Private
 
--
-- The purposee of the following class method is to parse UnicodeData.txt
-- (up to U+20000, since higher code points can have their properties
-- easily computed) and extract:
--
-- 1) The General_Category (gc) property value (i.e., column 3 of the database),
-- and, additionally,
--
-- 2) A set of code point ranges where the code point name can be computed
-- algorithmically.
--
-- Data is first stored in a MutableBuffer, and later broken in 256-byte chunks.
-- These chunks are deduplicated using a two-stage table, which is < 40Kb.
--  

::Method Generate Class
  Use Local
  
  -- Default is "Cn" -- reserved (unassigned code point)
  --
  -- Properties for code points <= U+20000 are effectively stored in a two-stage table.
  --
  -- Properties for code points >  U+20000 are dynamically computed.
  --
    
  Call Time "R"
  
  Call Log "Generating binary file..."
  
  Call Stream UnicodeData, "c", "query exists"
  
  if result == "" Then Call Error "File '"UnicodeData"' not found. Aborting"
  
  gc = .MutableBuffer~new( Copies( Cn, X2D( 20000 ) ) )

  --
  -- Algorithmically generated names and labels
  --
  -- See "Unicode Name Property" in The Unicode® Standard, Version 15.0 – Core Specification,
  -- https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, p. 183,
  -- and "Code Point Labels", ibid., p. 186.
  --
  -- We have added "TANGUT COMPONENT" because it is also computable.
  --
  -- <control>                        <=> gc == "Cc"
  -- <private-use>                    <=> gc == "Co"
  -- <noncharacter>                   <=> gc == "Cn" & ( code in U+FDD0..U+FDEF | Right(code,4) in {FFFE, FFFF} )
  -- <reserved>                       <=> gc == "Cn" & code is not a noncharacter
  -- <surrogate>                      <=> gc == "Cs" [& code in U+D800..U+DFFF]
  -- TANGUT IDEOGRAPH-code            <=> gc == "Lo" & code in U+17000..U+187F7 UNION 18d00..18D08
  -- TANGUT COMPONENT-n               <=> gc == "Lo" & n = X2d(code) - 100343 & code in U+18800..U+18AFF
  -- KHITAN SMALL SCRIPT-code         <=> gc == "Lo" & code in U+18B00..U+18CD5
  -- CJK COMPATIBILITY IDEOGRAPH-code <=> gc == "Lo" & code in  U+F900.. U+FAD9 UNION U+2F800..U+2FA1D
  -- CJK UNIFIED IDEOGRAPH-code       <=> gc == "Lo" & code in  U+3400.. U+4DBF 
  --                                                     UNION  U+4E00.. U+9FFF 
  --                                                     UNION U+20000..U+2A6DF
  --                                                     UNION U+2A700..U+2B739
  --                                                     UNION U+2B740..U+2B81D
  --                                                     UNION U+2B820..U+2CEA1
  --                                                     UNION U+2CEB0..U+2EBE0
  --                                                     UNION U+30000..U+3134A
  --                                                     UNION U+31350..U+323AF
  -- HANGUL SYLLABE syllabe           <=> gc == "Lo" & code in  U+AC00.. U+D7A3
  --
  -- "Twelve of the CJK ideographs in the starred range in Table 4-8, in the CJK Compatibility
  -- Ideographs block, are actually CJK unified ideographs. Nonetheless, their names are constructed 
  -- with the “cjk compatibility ideograph-” prefix shared by all other code points
  -- in that block. The status of a CJK ideograph as a unified ideograph cannot be deduced
  -- from the Name property value for that ideograph; instead, the dedicated binary property
  -- Unified_Ideograph should be used to determine that status. See “CJK Compatibility Ideographs” 
  -- in Section 18.1, Han, and Section 4.4, “Listing of Characters Covered by the Unihan Database” 
  -- in Unicode Standard Annex #38, “Unihan Database,” for more details about
  -- these exceptional twelve CJK ideographs." (Ibid., p. 184).
  --
  -- Annex 38, https://unicode.org/reports/tr38/#BlockListing, section 4.4,
  -- "Listing of Characters Covered by the Unihan Database".
  --
  -- † Note: 12 code points in the CJK Compatibility Ideographs block (
  -- U+FA0E, U+FA0F, U+FA11, U+FA13, U+FA14, U+FA1F, U+FA21, U+FA23, U+FA24, U+FA27, U+FA28, and U+FA29) 
  -- lack a canonical Decomposition_Mapping value in UnicodeData.txt, and so are not actually CJK compatibility ideographs. 
  -- These twelve characters are CJK unified ideographs.
  --

  Do While Lines(UnicodeData)
    Parse Value LineIn(UnicodeData) With code";"name";"thisGC";"
    thisGC = Upper(thisGC)
    n = X2D( code )
    If n >= X2D(20000) Then Leave
    -- The "Lo" General_Category property is internally extended to store
    -- information about algorithmically computable names.
    If thisGC == "LO" Then Do
      Select
        When name~startsWith("CJK COMPATIBILITY IDEOGRAPH-")   Then
          If WordPos(code,"FA0E FA0F FA11 FA13 FA14 FA1F FA21 FA23 FA24 FA27 FA28 U+FA29") > 0 Then 
                                                                    thisGC = "LO_CJK_UNIFIED_IDEOGRAPH"
          Else                                                      thisGC = "LO_CJK_COMPATIBILITY_IDEOGRAPH"
        When name~startsWith("<CJK Ideograph")                 Then thisGC = "LO_CJK_UNIFIED_IDEOGRAPH"
        When name~startsWith("<Hangul Syllable")               Then thisGC = "LO_HANGUL_SYLLABE"
        When name~startsWith("<Tangut Ideograph")              Then thisGC = "LO_TANGUT_IDEOGRAPH"
        When name~startsWith("TANGUT COMPONENT-")              Then thisGC = "LO_TANGUT_COMPONENT"
        When name~startsWith("KHITAN SMALL SCRIPT CHARACTER-") Then thisGC = "LO_KHITAN_SMALL_SCRIPT"
        Otherwise Nop
      End
    End
    -- Handle ranges (First-Last line pairs)
    If name~endsWith("First>") Then Do
      Parse Value LineIn(UnicodeData) With code2";"
      Do i = n + 1 To X2D( code2 ) + 1 -- "+ 1" to avoid referring to gc[0]
        gc[i] = gc.thisGC
      End
    End
    Else gc[ n + 1 ] = gc.thisGC       -- "+ 1" to avoid referring to gc[0]
  End

  Call Build_and_Store_Tables
  
  elapsed = Time("E")
  Call Log "Done, took" elapsed "seconds."
  
Return  

Build_and_Store_Tables:

  k      = -1       -- Offset of a chunk
  seen.  = 0        -- Marks a chunk as seen
  step   = 256      -- Size of the chunks
  offset = ""       -- Will store the (512) 1-byte offsets
  chunks = ""       -- Will store the deduplicated chunks

  Do i = 1 To 1FFFF~x2d + 1 By step
    chunk = gc[i,step]
    If seen.chunk > 0 Then Do
      offset ||= Right( d2x(seen.chunk), 2, 0 )~x2c
      Iterate
    End
    k += 1
    seen.chunk = k
    offset ||= Right( d2x(k) , 2, 0)~x2c
    chunks ||= chunk
  End

  outFile = myDir"gc.bin"

  -- No I/O error handling
  
  Call Stream  outFile, "C", "Open Write Replace"
  Call CharOut outFile, offset || chunks, 1
  Call Stream  outFile, "C", "Close"

Return 
 
--
-- Activate is automatically called at the end of class initialization.
--
-- First, we generate a set of global variables (shared using an
-- empty "Use Local" instruction). 
--
-- We next check whether the binary file exists; 
-- if it does not exist, we call the "Generate" method
-- to build it. 
--
-- Finally, we load the two-stage table in memory (the "bin" string).
-- 
 
::Method Activate Class
  Use Local

  -- We will need these variables and stems everywhere
  
  gcs= "Lu Ll Lt Lm Lo Lo_CJK_Compatibility_Ideograph Lo_CJK_Unified_Ideograph Lo_Hangul_Syllabe Lo_Khitan_Small_Script Lo_Tangut_Component Lo_Tangut_Ideograph Mn Mc Me Nd Nl No Pc Pd Ps Pe Pi Pf Po Sm Sc Sk So Zs Zl Zp Cc Cf Cs Co Cn"
  general_category. = "Cn"
  Do counter c gc over gcs~makeArray( " " )
    ugc           = Upper( gc )
    x             = x2c( d2x( c ) )
    gc.[ ugc ]    = x
    gc.x          = ugc
    Call Value ugc, x
    Call Value "general_category."gc, Left( gc, 2 )
  End
  
  Parse source . . myself  
  myDir = Left( myself, LastPos( .File~separator,myself ) )
  UnicodeData = myDir"UnicodeData.15.0.0.txt"
  
  inFile = myDir"gc.bin"
  
  -- No I/O error handling
  
  Call   Stream  inFile, "C", "Query Exists"
  If result == "" Then self~generate
  
  Call   Stream  inFile, "C", "Open Read"
  size = Stream( inFile, "C", "Query Size" )
  bin  = CharIn( inFile,1,size )
  Call   Stream  inFile, "C", "Close"
    
::Method algorithmic_name_start Class
  Use Local
  Use Strict Arg code
  code = Upper(code)
  xgc = self~xgc(code)
  Select Case xgc
    When Lo_CJK_Compatibility_Ideograph Then Return "CJK COMPATIBILITY IDEOGRAPH-"
    When Lo_CJK_Unified_Ideograph       Then Return "CJK UNIFIED IDEOGRAPH-"
    When Lo_Hangul_Syllabe              Then Return "HANGUL SYLLABE"
    When Lo_Khitan_Small_Script         Then Return "KHITAN SMALL SCRIPT CHARACTER-"
    When Lo_Tangut_Component            Then Return "TANGUT COMPONENT-"
    When Lo_Tangut_Ideograph            Then Return "TANGUT IDEOGRAPH-"
    When Cc                             Then Return "<control-"
    When Co                             Then Return "<private-use-"
    When Cn                             Then Do
      If WordPos( Right(code,4), "FFFE", "FFFF") > 0 Then
                                             Return "<noncharacter-"
      n = X2D( code )
      If n >= 64976, n <= 65007         Then -- code in U+FDD0..U+FDEF 
                                             Return "<noncharacter-"
                                             Return "<reserved-"
    End
    When Gs                             Then Return "<surrogate-"
    Otherwise                                Return ""
  End

::Method xgc Class
  Use Local
  Use Strict Arg code

  n = code~x2d -- + 1
  If n <= 131071 Then Do -- Planes 0 & 1
    high = n % 256
    off = bin[ high+1 ]~c2x~x2d
    xgc = bin[ 513 + off*256 + n // 256 ]
    Return xgc
  End
  Select Case Length(code)
    When 5 Then Do
      Select Case code[1]
        When "2" Then Do
          If              n <= 173791 Then Return Lo_CJK_Unified_Ideograph -- 20000 2A6DF
          If n >= 173824, n <= 177977 Then Return Lo_CJK_Unified_Ideograph -- 2A700 2B739
          If n >= 177984, n <= 178205 Then Return Lo_CJK_Unified_Ideograph -- 2B740 2B81D
          If n >= 178208, n <= 183969 Then Return Lo_CJK_Unified_Ideograph -- 2B820 2CEA1
          If n >= 183984, n <= 191456 Then Return Lo_CJK_Unified_Ideograph -- 2CEB0 2EBE0
          If n >= 194560, n <= 195101 Then Return Lo_CJK_Unified_Ideograph -- 2F800 2FA1D
        End
        When "3" Then Do
          If              n <= 201546 Then Return Lo_CJK_Unified_Ideograph -- 30000..3134A
          If n >= 201552, n <= 205743 Then Return Lo_CJK_Unified_Ideograph -- 31350..323AF
        End
        When "E" Then Do
          If n == 917505              Then Return Cf -- E0001
          If n >= 917536, n <= 917631 Then Return Cf -- E0020..E007F
          If n >= 917760, n <= 917999 Then Return Mn -- E0100..E01EF
        End
        When "F" Then
          If n <= 1048573             Then Return Co -- FFFFD
        Otherwise Return Cn
      End
    End
    When 6 Then
          If n <= 1114109             Then Return Co -- 10FFFD
    Otherwise Return Cn
  End
  Return Cn
  
::Method "[]" Class
  Use Local
  Use Strict Arg code
  Return general_category.[self~xgc(code)]

::Method Consistency_Check Class
  Use Local
  
  Call Time "R"
  
  Call Log "Running consistency checks..."
  Call Log
  Call Log "Checking the 'General_Category' (gc) property for 1114112 codepoints..."
  
  Call Stream UnicodeData,"C","Close"      -- Recovers if previous run crashed
  
  Call Stream UnicodeData,"C","Open Read"
  
  last = -1
  count = 0
  Do While Lines(UnicodeData)
    Parse Value LineIn(UnicodeData) With code1";"name";"gc";"
    If X2D(code1) \== last + 1 Then Do
      Do i = last + 1 To X2D(code1) - 1
        iCode = D2X(i)
        count += 1
        If self[iCode] \== "Cn" Then
          Say "Consistency check failed at codepoint 'U+"iCode"', got '"self[iCode]"', expected 'Cn'."
      End
    End
    If name~endsWith("First>") Then Do
      Parse Value LineIn(UnicodeData) With code2";"
      Do i = X2D(code1) To X2D(code2)
        iCode = D2X(i)
        count += 1
        If self[iCode] \== gc Then
          Say "Consistency check failed at codepoint 'U+"iCode"', got '"self[iCode]"', expected '"gc"'."
      End
      last = i - 1
    End
    Else Do
      count += 1
      If self[code1] \== gc Then
        Say "Consistency check failed at codepoint 'U+"code1"', got '"self[code1]"', expected '"gc"'."
      last = X2D(code)
    End
  End
  If last < 1114111 Then Do
    Do i = last + 1 To 1114111
      iCode = D2X(i)
      count += 1
      If self[iCode] \== "Cn" Then
        Say "Consistency check failed at codepoint 'U+"iCode"', got '"self[iCode]"', expected 'Cn'."
    End
  End
  
  Call Stream UnicodeData,"C","Close"
  
  elapsed = Time("E")
  If elapsed = 0 Then elapsed = "0.001"
  
  Call Log count "codepoints checked in" elapsed "seconds." 
  Call Log "This is" (count/elapsed) "codepoints/second."
