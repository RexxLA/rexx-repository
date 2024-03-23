/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023, 2024 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                     │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

/*****************************************************************************/
/*                                                                           */
/*  The gc.rex build program                                                 */
/*  ========================                                                 */
/*                                                                           */
/*  This program generates the binary data needed by properties/gc.cls.      */
/*                                                                           */
/*  See also tests/gc.rex.                                                   */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.2  JMB 20230725 Moved from properties/gc.cls                          */
/*                                                                           */
/*****************************************************************************/

--
-- The purpose of the following program is to parse UnicodeData.txt
-- (up to U+20000, since higher code points can have their properties
-- easily computed by an algorithm) and extract:
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

  -- Inform our classes that we are building the .bin files, so that they don't
  -- complain that they are not there.
  
  .local~Unicode.Buildtime = 1

  -- Call instead of ::Requires allows us to set the above variable first.
  
  Call "Unicode.cls"
  
  self = .Unicode.General_Category
  
  super = self~superClass
  
  variables = self~variables
   
  nameOf. = "Cn"
  Do counter c variable over variables~makeArray( " " )
    char                           = x2c( d2x( c ) )
    Var2Char.[ Upper( variable ) ] = char
    nameOf.char                    = Left( variable, 2 )
    Call Value variable, char
  End

  Say "Generating binary values for the Unicode.General_Category class..."

  Call Time "R"
  
  inFile = super~UCDFile.Qualify( self~UnicodeData )
  
  Call Stream inFile, "c", "query exists"
  
  If result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")
  
  -- Default is "Cn" -- reserved (unassigned code point)
  --
  -- Properties for code points <= U+20000 are effectively stored in a two-stage table.
  --
  -- Properties for code points >  U+20000 are dynamically computed.
  --
   
  buffer = .MutableBuffer~new( Copies( Cn, X2D( 20000 ) ) )

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
  -- HANGUL SYLLABE syllabe           <=> gc == "Lo" & code in  U+AC00.. U+D7A3
  -- TANGUT IDEOGRAPH-code            <=> gc == "Lo" & code in U+17000..U+187F7 UNION 18D00..18D08
  -- TANGUT COMPONENT-n               <=> gc == "Lo" & n = X2d(code) - 100343 & code in U+18800..U+18AFF
  -- KHITAN SMALL SCRIPT-code         <=> gc == "Lo" & code in U+18B00..U+18CD5
  -- NUSHU CHARACTER-code             <=> gc == "Lo" & code in U+1B170..U+1B2FB
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

  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code";"name";"thisGC";"
    thisGC = Upper(thisGC)
    n = X2D( code )
    If n >= X2D(20000) Then Leave
    -- The "Lo" General_Category property is internally extended to store
    -- information about algorithmically computable names.
    If thisGC == "LO" Then Do
      Select
        When name~startsWith("CJK COMPATIBILITY IDEOGRAPH-")   Then
        /* Nobody seems to really implement that
          If WordPos(code,"FA0E FA0F FA11 FA13 FA14 FA1F FA21 FA23 FA24 FA27 FA28 U+FA29") > 0 Then 
                                                                    thisGC = "LO_CJK_UNIFIED_IDEOGRAPH"
          Else */                                                     thisGC = "LO_CJK_COMPATIBILITY_IDEOGRAPH"
        When name~startsWith("<CJK Ideograph")                 Then thisGC = "LO_CJK_UNIFIED_IDEOGRAPH"
        When name~startsWith("<Hangul Syllable")               Then thisGC = "LO_HANGUL_SYLLABE"
        When name~startsWith("<Tangut Ideograph")              Then thisGC = "LO_TANGUT_IDEOGRAPH"
        When name~startsWith("TANGUT COMPONENT-")              Then thisGC = "LO_TANGUT_COMPONENT"
        When name~startsWith("NUSHU CHARACTER-")               Then thisGC = "LO_NUSHU_CHARACTER"
        When name~startsWith("KHITAN SMALL SCRIPT CHARACTER-") Then thisGC = "LO_KHITAN_SMALL_SCRIPT"
        Otherwise Nop
      End
    End
    -- Handle ranges (First-Last line pairs)
    If name~endsWith("First>") Then Do
      Parse Value LineIn(inFile) With code2";"
      Do i = n + 1 To X2D( code2 ) + 1        -- "+ 1" to avoid referring to gc[0]
        buffer[i] = Var2Char.thisGC
      End
    End
    Else buffer[ n + 1 ] = Var2Char.thisGC    -- "+ 1" to avoid referring to gc[0]
  End

  array = .MultiStageTable~Compress(buffer)
  
  super~setPersistent("UnicodeData.gc.Table1", array[1])
  super~setPersistent("UnicodeData.gc.Table2", array[2])

  super~SavePersistent( super~BinFile.Qualify( self~binaryFile ) )
  
  elapsed = Time("E")
  Say "Done, took" elapsed "seconds."