/*****************************************************************************/
/*                                                                           */
/*  The UNICODE Toys for ooRexx                                              */
/*  ===========================                                              */
/*                                                                           */
/*  Copyright (c) 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>     */
/*                                                                           */
/*  See https://github.com/RexxLA, rexx-repository,                          */
/*      path ARB/standards/work-in-progress/unicode/UnicodeToys              */
/*                                                                           */
/*  License: Apache License 2.0 https://www.apache.org/licenses/LICENSE-2.0  */
/*                                                                           */
/*                                                                           */
/*  The UNICODE.NAME class                                                   */
/*  ======================                                                   */
/*                                                                           */
/*  This class implements the Name (na) Unicode property. Both code-to-name  */
/*  and name-to-code conversions are implemented. Names are algorithmically  */
/*  generated when possible; class Unicode.General_Category contains helper  */
/*  functions for that purpose. The name-to-code conversion follows the      */
/*  Unicode suggestions and allow the search equivalence of                  */
/*  "Latin Small Letter A", "LATIN SMALL LETTER A", "Latin_Small_Letter_A",  */
/*  "Latin-Small-Letter-A" and "LatinSmallLetterA".                          */
/*                                                                           */
/*  Both UnicodeData.txt and NameAliases.txt are used, so that name aliases  */
/*  can be used on name-to-code conversions.                                 */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Ver. Aut Date     Comments                                               */
/*  ---- --- -------- ------------------------------------------------------ */
/*  00.1 JMB 20230716 Initial release                                        */
/*                                                                           */
/*****************************************************************************/

-------------------------------------------------------------------------------
--
-- See The Unicode® Standard. Version 15.0 – Core Specification, p. 181
-- https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf
--
-- "Character Name Matching. When matching identifiers transposed from 
-- character names, it is possible to ignore case, whitespace, and all 
-- medial hyphen-minus characters (or any “_” replacing a hyphen-minus), 
-- except for the hyphen-minus in U+1180 HANGUL JUNGSEONG O-E, and still 
-- result in a unique match. For example, “ZERO WIDTH SPACE” is equivalent
-- to “zero-width-space” or “ZERO_WIDTH_SPACE” or “ZeroWidthSpace”. However,
-- “TIBETAN LETTER A” should not match “TIBETAN LETTER -A”, because in that
-- instance the hyphen-minus is not medial between two letters, but is 
-- instead preceded by a space. For more information on character name 
-- matching, see Section 5.9, “Matching Rules” in Unicode Standard Annex #44, 
-- “Unicode Character Database.”
-------------------------------------------------------------------------------

::Class Unicode.Name SubClass Unicode.Property Public

::Constant UnicodeDataFile "UnicodeData-15.0.0.txt"  
::Constant NameAliasesFile "NameAliases-15.0.0.txt"  

::Method "[]" Class
  Expose c2n.
  Use Strict Arg code
  name = c2n.code
  If name \== "" Then Return name
  name = .Unicode.General_Category~Algorithmic_Name(code)
  Return name

::Method r2n Class
  Forward Message ("[]")

::Method n2r Class
  Expose n2r.
  Use Strict Arg name
  name = Upper(ChangeStr("_",Space(name,0),""))
  If name \== "HANGULJUNGSEONGO-E" Then Do
    name = ChangeStr("- ",name,">")
    name = ChangeStr(" -",name,"<")
    name = ChangeStr("-", name,"")
    name = ChangeStr(">",name,"- ")
    name = ChangeStr("<",name," -")
  End
  code = n2r.name
  If code \== "" Then Return code
  Return .Unicode.General_Category~Algorithmic_Code(name)

::Method Activate Class
  Expose n2r. c2n.
  
  self~activate:super
  
  Parse source . . myself  
  myDir = Left( myself, LastPos( .File~separator,myself ) )  
  
  inFile = myDir || self~UnicodeDataFile
  
  Call Stream inFile, "c", "query exists"
  
  if result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")

  Call Time "R"

  c2n. = ""
  n2r. = ""
  Do While Lines(InFile) > 0
    Parse Value LineIn(Infile) With code";"name ";" ";"ccc";"
    If name~endsWith("First>") Then Do
      Parse Value LineIn(Infile) With code2";"
      Iterate
    End
    If name~startsWith("CJK COMPATIBILITY IDEOGRAPH-") Then Iterate
    If name = "HANGUL JUNGSEONG O-E" Then key = "HANGULJUNGSEONGO-E"
    Else key = Compress(name)
    n2r.key = code
    c2n.code = name
  End

  Call Stream inFile,"C","Close"

  -- Now parse NameAliases.txt

  inFile = myDir || self~NameAliasesFile
  
  Call Stream inFile, "c", "query exists"
  
  if result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")

  Call Time "R"

  Do While Lines(InFile) > 0
    line = LineIn(InFile)
    If line[1] == "#" Then Iterate
    If line     = ""  Then Iterate
    Parse Var line code";"name";"
    key = Compress(name)
    n2r.key = code
  End

  Call Stream inFile,"C","Close"
Return

Compress:
  key = ChangeStr("- ",Arg(1),">") -- Preserve non-medial dash-blank sequences
  key = ChangeStr(" -",key, "<")   -- Preserve non-medial blank-dash sequences
  key = ChangeStr("-" ,key, "")    -- Delete all dashed (will all be medial)
  key = Space(key,0)               -- Delete all blanks too
  key = ChangeStr(">",key,"- ")    -- Now restore non-medial dash-blank sequences..
  key = ChangeStr("<",key," -")    -- ..and non-medial blank-slash sequences too.
Return key  
  
::Requires Unicode.Property.cls  
::Requires Unicode.General_Category.cls