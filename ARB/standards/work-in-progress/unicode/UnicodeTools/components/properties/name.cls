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
/*  00.1  JMB 20230716 Initial release                                       */
/*  00.1a JMB 20230717 Move UCD files to the UCD subdirectory                */
/*  00.1c JMB 20230718 Move property classes to the "property" subdir        */
/*                     Fix control character labels for name property        */
/*                     Fix some bugs, add consistency check                  */
/*  00.2  JMB 20230725 Rename classfile to 'name.cls'                        */
/*        JMB          Add NUSHU CHARACTER-                                  */
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

.local~Unicode.Name = .Unicode.Name

::Class Unicode.Name SubClass Unicode.Property Public

::Method na   Class
  Forward Message "name"
::Method name Class
  Expose c2n. activated
  
  If \activated Then self~Delayed_activation
  
  Use Strict Arg code
  
  If \DataType(code,"X") Then Return ""
    
  -- Normalize "code" first
  If Length(code) < 4 Then code = Right(code,4,0)
  Do While code[1] == "0", Length(code) > 4
    code = SubStr(code,2)
  End
  
  code = Upper(code)
  
  -- Try code-to-name stem first
  name = c2n.code
  If name \== "" Then Return name
  
  -- Not found? See if it's algorithmic
  name = .Unicode.General_Category~Algorithmic_Name(code)
  Return name

::Method n2p Class
  Expose n2p. activated
  
  If \activated Then self~Delayed_activation
  
  Use Strict Arg name
  label = 0
  If name[1] == "<" Then Do
    If name[Length(name)] \== ">" Then Return ""
    label = 1
    Parse Var name "<"name">"
  End
  name = ChangeStr("- ",name,">")
  name = ChangeStr(" -",name,"<")
  name = Upper(ChangeStr("_",Space(name,0),""))
  If name \== "HANGULJUNGSEONGO-E" Then name = ChangeStr("-", name,"")
  name = ChangeStr(">",name,"- ")
  name = ChangeStr("<",name," -")
  If label Then name = "<"name">"
  code = n2p.name
  If code \== "" Then Return code
  Return .Unicode.General_Category~Algorithmic_Code(name)

-- Delay activation until it is really needed, because this implementation
-- is quite slow

::Method Activate Class
  Expose activated
  super~registerProperties( "Name Na", self )
  activated = 0
  
::Method Delayed_activation Class
  Expose n2p. c2n. activated
  activated = 1
  
  inFile = super~UCDFile.Qualify( self~UnicodeData )
  
  Call Stream inFile, "c", "query exists"
  
  If result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")
  
  Call Stream inFile,"C","Close"

  Call Time "R"

  c2n. = ""
  n2p. = ""
  Do While Lines(InFile) > 0
    Parse Value LineIn(Infile) With code";"name ";" ";"ccc";"
    If name[1] == "<" Then Iterate
    If name~endsWith("First>") Then Do
      Parse Value LineIn(Infile) With code2";"
      Iterate
    End
    If name~startsWith("NUSHU CHARACTER-")               Then Iterate
    If name~startsWith("TANGUT IDEOGRAPH-")              Then Iterate
    If name~startsWith("KHITAN SMALL SCRIPT CHARACTER-") Then Iterate
    If name~startsWith("CJK COMPATIBILITY IDEOGRAPH-")   Then Iterate
    If name~startsWith("CJK UNIFIED IDEOGRAPH-")         Then Iterate
    If name = "HANGUL JUNGSEONG O-E" Then key = "HANGULJUNGSEONGO-E"
    Else key = Compress(name)
    n2p.key = code
    c2n.code = name
  End

  Call Stream inFile,"C","Close"

  -- Now parse NameAliases.txt

  inFile = super~UCDFile.Qualify( self~NameAliases )
  
  Call Stream inFile, "c", "query exists"
  
  if result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")

  Call Time "R"

  Do While Lines(InFile) > 0
    line = LineIn(InFile)
    If line[1] == "#" Then Iterate
    If line     = ""  Then Iterate
    Parse Var line code";"name";"
    key = Compress(name)
    n2p.key = code
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
