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
/*  The UNICODE.GRAPHEME_CLUSTER_BREAK class                                 */
/*  ========================================                                 */
/*                                                                           */
/*  This class implements a primitive that maps a codepoint to its           */
/*  Grapheme_Cluster_Break property. The property is taken from several      */
/*  official Unicode sources, since the standard is unclear on several       */
/*  points. Building on that property, another primitive is provided that    */
/*  transforms a set of codepoints (provided either as an array or as a      */
/*  blank-delimited string) into the corresponding string composed of        */
/*  grapheme clusters.                                                       */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Ver. Aut Date     Comments                                               */
/*  ---- --- -------- ------------------------------------------------------ */
/*  00.1 JMB 20230716 Initial release                                        */
/*                                                                           */
/*****************************************************************************/

--
-- Running this file (or ::requiring it) will generate the binary
-- file if not present.
--

--
-- See https://www.unicode.org/Public/UCD/latest/ucd/auxiliary/GraphemeBreakProperty.txt
-- See https://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt
--
-- See also https://www.unicode.org/Public/UCD/latest/ucd/auxiliary/GraphemeBreakTest.txt
--      and https://www.unicode.org/Public/15.0.0/ucd/auxiliary/GraphemeBreakTest.html
--
-- See https://www.unicode.org/reports/tr29/#Regex_Definitions
--
-- The table at https://www.unicode.org/Public/15.0.0/ucd/auxiliary/GraphemeBreakTest.html#table
-- uses two values that are not defined in Grapheme_Cluster_Break: Extend_ExtCccZwj and
-- ZWJ_ExtCccZwj. These values are not defined anywhere.
--
-- Inspection of GraphemeBreakTest.txt shows that ZWJ_ExtCccZwj takes
-- the place of ZWJ, i.e., there is no single occurence of ZWJ in the test file, and
-- all the occurences of 200D are labeled ZWJ_ExtCccZwj.
--
-- Things are more involved regarding Extend_ExtCccZwj. Although there is absolutely no
-- documentation about this value, we can find a reference to ExtCccZwj, without the
-- leading "Extend_", in https://www.unicode.org/reports/tr29/tr29-42.html, a draft
-- proposal to update UAX #29.
-- 
-- There we can find the following definition:
--
--   ExtCccZwj := [[\p{gcb=Extend}-\p{ccc=0}]\p{gcb=ZWJ}]
--
-- Somehow, Extend but not ccc = 0. Let's check GraphemeBreakTest.txt:
--
-- All the examples labeled Extend_ExtCccZwj in GraphemeBreakTest.txt have
-- gcb = Extend AND ccc = 0.
--
-- Similarly, all examples labeled Extend in GraphemeBreakTest.txt have
-- gcb = Extend AND ccc > 0.
--
-- We will modify the values of gcb accordingly, i.e., add a new
-- value Extend_ExtCccZwj and attribute it to the items in Extend
-- that happen to have ccc = 0.
--
-- Our tables store only the first two planes. We have to study these two lines:
--
-- E0020..E007F  ; Extend # Cf  [96] TAG SPACE..CANCEL TAG
-- E0100..E01EF  ; Extend # Mn [240] VARIATION SELECTOR-17..VARIATION SELECTOR-256
--
-- Inspection of UnicodeData.txt shows that both sets have ccc = 0, i.e., they
-- can continue to have the Extend value.
--
-- 
--

--.Unicode.Grapheme_Cluster_Break~generate
--.Unicode.Grapheme_Cluster_Break~GraphemeBreakTest
--.Unicode.Grapheme_Cluster_Break~Consistency_Check


::Class Unicode.Grapheme_Cluster_Break Public SubClass Unicode.Property
  
::Constant Variables   "Other Control CR Extend Extend_ExtCccZwj Extended_Pictographic L LF LV LVT Prepend Regional_Indicator SpacingMark T V ZWJ"
--                      01    02      03 04     05               06                   07 08 09 0A  0B      0C                 0D         0E 10 11
::Constant GraphemeBreakPropertyFile "GraphemeBreakProperty-15.0.0.txt"  
::Constant EmojiDataFile             "emoji-data-15.0.0.txt"
::Constant UnicodeDataFile           "UnicodeData-15.0.0.txt"
::Constant GraphemeBreakTestFile     "GraphemeBreakTest-15.0.0.txt"
::Constant BinaryFile                "Grapheme_Cluster_Break.bin"  
::Attribute myself Class Get  
  
::Method hexValueOfPropertyAt Class
  Expose binaryString Control Extend Other
  
  Use Strict Arg code

  n = X2D( code )
  
  If n <= 131071 Then Do -- Planes 0 & 1
    highIndex  = n % 256
    highOffset = BinaryString[ highIndex + 1 ]~c2x~x2d
    lowOffset  = n // 256
    Return       BinaryString[ 512 + 1 + highOffset*256 + lowOffset ]
  End
  
  Select Case Length(code)
    When 5 Then Do
      If code[1] == "E" Then Do
        If n <= 917535 Then Return Control -- E0000..E001F
        If n <= 917631 Then Return Extend  -- E0020..E007F
        If n <= 917759 Then Return Control -- E0080..E00FF
        If n <= 917999 Then Return Extend  -- E0100..E01EF
        If n <= 921599 Then Return Control -- E01F0..E0FFF
      End
    End
    When 6 Then Return Other
  End
 
  Return Other

::Method Activate Class
  Use Local char variable nameOf. myself myDir
  
  self~activate:super
  
  Parse Source . . myself
  myDir = Left( myself,LastPos(.File~separator,myself) )

  variables = self~variables
  Do counter c variable over variables~makeArray( " " )
    char = X2C( D2X( c ) )
    nameOf.char = variable
    Call Value variable, char -- Creates a new instance variable (because of use local)
  End
    
  self~NameOf = nameOf.

  binaryString = self~BinaryFileContents
  
  -- A modified version of
  -- https://www.unicode.org/Public/15.0.0/ucd/auxiliary/GraphemeBreakTest.html#table
  
  break. = 1
  Call NoBreak CR,  LF -- GB3
  Call NoBreak L,   L -- GB6
  Call NoBreak L,   V -- GB6
  Call NoBreak L,   LV -- GB6
  Call NoBreak L,   LVT -- GB6
  Call NoBreak LV,  V -- GB7
  Call NoBreak LV,  T -- GB7
  Call NoBreak V,   V -- GB7
  Call NoBreak V,   T -- GB7
  Call NoBreak LVT, T -- GB8
  Call NoBreak T,   T -- GB8
  Do i = 1 To Words(variables)
    gcb = x2c(d2x(i))
    If gcb == Control | gcb == CR | gcb == LF Then Iterate
    Call NoBreak Prepend, gcb
    Call NoBreak gcb, Extend
    Call NoBreak gcb, SpacingMark
    Call NoBreak gcb, ZWJ
    Call NoBreak gcb, Extend_ExtCccZwj
  End
  Call NoBreak Regional_Indicator, Regional_Indicator -- GB12, GB13  
  Call ManualCheck Extended_Pictographic, ZWJ              -- GB11
  Call ManualCheck Extended_Pictographic, Extend           -- GB11
  Call ManualCheck Extended_Pictographic, Extend_ExtCccZwj -- GB11
Return   

Break:       break.[ Arg(1) || Arg(2) ] =  1; Return  
NoBreak:     break.[ Arg(1) || Arg(2) ] =  0; Return  
ManualCheck: break.[ Arg(1) || Arg(2) ] = -1; Return

  
::Method Generate Class
  Expose myDir (variables) Extend2ExtCccZwj.  
  
  Call Time "R"
  
  self~log( "Generating binary file..." )

  buffer = .MutableBuffer~new( Copies( Other, X2D( 20000 ) ) )

  inFile = myDir || self~GraphemeBreakPropertyFile

  Call Stream inFile, "c", "Query exist"

  If result == "" Then self~SyntaxError("File '"inFile"' does not exist")
  
  Call Stream inFile, "C", "Open Read"

  Do While Lines(infile)
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";"value "#"
    value = Strip(value)
    codes = Strip(codes)
    If Pos("..", codes) > 0 Then Do
      Parse Var codes min".."max
      -- We handle Ehhhh programmatically
      If Length(min) == 5, min[1] == "E" Then Iterate
    End
    Else Do
      If Length(codes) == 5, codes[1] == "E" Then Iterate
      min = codes
      max = codes
    End
    value = Value(value)
    Do i = X2D(min) To X2D(max)
      buffer[i+1] = value
    End
  End
  
  Call Stream inFile, "C", "Close"
  
  -- The "Extended_Pictographic" property is on another file
  
  inFile = myDir || self~EmojiDataFile

  Call Stream inFile, "c", "Query exist"

  If result == "" Then self~SyntaxError("File '"inFile"' does not exist")
  
  Call Stream inFile, "C", "Open Read"

  Do While Lines(infile)
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";"value "#"
    value = Strip(value)
    If value \== "Extended_Pictographic" Then Iterate
    codes = Strip(codes)
    If Pos("..", codes) > 0 Then
      Parse Var codes min".."max
    Else Do
      min = codes
      max = codes
    End
    value = Value(value)
    Do i = X2D(min) To X2D(max)
      If Buffer[i+1] \== Other Then self~syntaxError( "Error! Codepoint" d2x(i) "is not 'Other'. Cannot assign 'Extended_Pictographic'" )
      buffer[i+1] = Extended_Pictographic
    End
  End
  
  Call Stream inFile, "C", "Close"

  -- And, still, the ccc property is on another file

  inFile = myDir || self~UnicodeDataFile
  
  Call Stream inFile, "c", "Query exist"

  If result == "" Then self~SyntaxError("File '"inFile"' does not exist")
  
  Call Stream inFile, "C", "Open Read"

  Do While Lines(infile)
    Parse Value LineIn(infile) With code";"name";" ";"ccc";"
    If ccc == 0 Then Iterate
    If name~endsWith("First>") Then Do
      Parse Value LineIn(infile) With code2";"
      Do i = X2D(code) To X2D(code2)
        If buffer[i+1] == Extend Then Do
          Extend2ExtCccZwj.[i] = 1
          buffer[i+1] = Extend_ExtCccZwj
        End
      End
    End
    Else If buffer[X2D(code)+1] == Extend Then Do
      Extend2ExtCccZwj.[X2D(code)] = 1
      buffer[X2D(code)+1] = Extend_ExtCccZwj 
    End
  End
  
  Call Stream inFile, "C", "Close"
  
  self~StoreBinaryFile(buffer)
  
  elapsed = Time("E")
  self~log( "Done, took" elapsed "seconds." )  

::Method Consistency_Check Class
  Expose myDir Extend2ExtCccZwj.
  
  Call Time "R"
  
  self~log( "Running consistency checks..." )
  self~log( "" )
  If Extend2ExtCccZwj.~items == 0 Then Do
    self~log( "We will need to regenerate the binary file first." )
    self~generate -- Ensures that Extend2ExtCccZwj. is filled
  End
  self~log( "" )
  self~log( "Checking the 'Grapheme_Cluster_Break' property for 1114112 codepoints..." )
  
  inFile = myDir || self~GraphemeBreakPropertyFile
  
  Call Stream inFile,"C","Close"      -- Recovers if previous run crashed
  
  Call Stream inFile,"C","Open Read"
  
  checked. = 0 -- Will allow us to check non-listed code points
  count = 0
  Do While Lines(inFile)
    line = LineIn(infile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";"value"#"
    codes = Strip(codes)
    value = Strip(value)
    If Pos("..",codes) > 0 Then Parse Var codes min".."max
    Else Do; min = codes; max = codes; End
    Do i = X2D(min) To X2D(max)
      checked.i = 1
      xCode = D2X(i)
      If Length(xCode) < 4 Then xCode = Right(xCode, 4, 0)
      count += 1
      If Extend2ExtCccZwj.i == 1, value == "Extend", self[xCode] == "Extend_ExtCccZwj" Then Nop
      Else If self[xCode] \== Value Then 
        Say "Consistency check failed at codepoint 'U+"xCode"', got '"self[xCode]"', expected '"value"'."
    End
  End
  
  ExtPic. = 0
  ExtPics = 0
  Do i = 0 To 1114111
    If checked.i Then Iterate
    xCode = D2X(i)
    count += 1
    If Length(xCode) < 4 Then xCode = Right(xCode, 4, 0)
    If self[xCode] == "Extended_Pictographic" Then Do
      ExtPic.i = 1
      ExtPics += 1
    End
    Else If self[xCode] \== "Other" Then 
      Say "Consistency check failed at codepoint 'U+"xCode"', got '"self[xCode]"', expected 'Other'."
  End

  Call Stream inFile,"C","Close"

  inFile = myDir || self~EmojiDataFile
  
  Call Stream inFile,"C","Close"      -- Recovers if previous run crashed
  
  Call Stream inFile,"C","Open Read"
  
  extpic = 0
  Do While Lines(inFile)
    line = LineIn(infile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";"value"#"
    codes = Strip(codes)
    value = Strip(value)
    If value \== "Extended_Pictographic" Then Iterate
    If Pos("..",codes) > 0 Then Parse Var codes min".."max
    Else Do; min = codes; max = codes; End
    Do i = X2D(min) To X2D(max)
      count += 1
      extpic += 1
      If ExtPic.i Then ExtPics -= 1
      Else Do
        xCode = D2X(i)
        If Length(xCode) < 4 Then xCode = Right(xCode, 4, 0)
        Say "Consistency check failed at codepoint 'U+"xCode"', marked as 'Extended_Pictographic' in '"inFile"' but not on binary file"
      End
    End
  End
  If ExtPics \== 0 Then Say "Consistency check failed:" ExtPics "'Extended_Pictographic' items remaining"  

  Call Stream inFile,"C","Close"

  
  elapsed = Time("E")
  If elapsed = 0 Then elapsed = "0.001"
  
  self~log( count "codepoints checked in" elapsed "seconds." ) 
  self~log( "This is" (count/elapsed) "codepoints/second." )
  self~log( extpic "'Extended_Pictographic' values were checked twice." )
  self~log( Extend2ExtCccZwj.~items "values changed from 'Extend' to 'Extend_ExtCccZwj'." )

::Method codepointsToGraphemes Class
  Expose (Variables) break.

  Use Arg codes, format -- "codes" is a one-dimensional non-sparse array of Unicode code points (in hex)
  
  -- We also accept a blank-separated string of codepoints
  If codes~isA(.String) Then
    If Pos(" ",codes) > 0 Then codes = codes~makeArray(" ")
    Else codes = .Array~of(codes)
  
  items = codes~items
  
  If items == 0 Then Return .Array~of()
  
  gcbs = "" -- We will accumulate the GCB properties here
  
  Do i = 1 To items
    gcbs ||= self~hexValueOfPropertyAt( codes[i] )    
  End
  
  grapheme  = ""         -- Construct each individual grapheme here
  graphemes = .Array~new -- We will return an array of UTF-8 graphemes
  
  i = 1
  
Loop:  
  Call AddToGrapheme
  index = gcbs[i,2]
  If Length(index) < 2 Then Do -- GB2
    If grapheme \== "" Then graphemes~append( grapheme )
    Return graphemes    
  End
  Select Case break.index
    When -1 Then Signal ManualHandling
    When  1 Then Do
      graphemes~append( grapheme )
      grapheme = ""
      i += 1
      Signal Loop
    End
    When  0 Then Do
      If index = Regional_Indicator || Regional_Indicator, gcbs[i+2] \== ZWJ Then Do
        i += 1
        Call AddToGrapheme
        graphemes~append( grapheme )
        If i == items Then Return graphemes
        grapheme = ""
      End
      i += 1
      Signal Loop
    End
  End  
  
ManualHandling:
  -- xpicto-sequence := \p{Extended_Pictographic} (Extend* ZWJ \p{Extended_Pictographic})*
  If index = Extended_Pictographic || Extend_ExtCccZwj Then Signal xpicto_sequence
  If index = Extended_Pictographic || Extend           Then Signal xpicto_sequence
  If index = Extended_Pictographic || ZWJ              Then Do
    j = i + 1
    Signal xpicto_sequence_ZWJ
  End
  
xpicto_sequence:  
  j = i + 1
xpicto_sequence_Extend:
  Do While gcbs[j] == Extend | gcbs[j] == Extend_ExtCccZwj
    j += 1
  End
  If gcbs[j] \ == ZWJ, gcbs[j] \ == SpacingMark Then Signal collect_xpicto_sequence
xpicto_sequence_ZWJ:  
  j = j + 1 -- ZWJ
  If gcbs[j] == SpacingMark Then Do -- postcore := [Extend ZWJ SpacingMark]
    j = j + 1
    Signal collect_xpicto_sequence 
  End
  If gcbs[j] == Extended_Pictographic Then j = j + 1
  If gcbs[j] == Extend | gcbs[j] == ZWJ Then Signal xpicto_sequence_Extend
collect_xpicto_sequence:
  Do i = i + 1 To Min(j-1, items)
    Call AddToGrapheme
  End  
  graphemes~append( grapheme )
  If i > items Then Return graphemes
  grapheme = ""
  Signal Loop
  
AddToGrapheme:
  Select Case format
    When "", "UTF8", "UTF-8" Then grapheme ||= UTF8( Codes[i] )
    Otherwise                     grapheme ||= " "Codes[i]
  End
Return
  
UTF8: Procedure -- Internal, fast
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


::Method GraphemeBreakTest Class
  Expose myDir
  
  inFile = myDir || self~GraphemeBreakTestFile

  self~log("Running all the tests in GraphemeBreakTest.txt...")

  bad = 0
  Do lineno = 1 By 1 While Lines(inFile) > 0
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes"#"
    check = codes~MakeArray("÷")
    check~delete(check~items)
    check~delete(1)
    Do i = 1 To Check~items
      check[i] = Space(ChangeStr("×",check[i]," "))
    End
    save = codes
    codes = ChangeStr("÷",codes," ")
    codes = ChangeStr("×",codes," ")
    codes = Space(codes)
    codearray = codes~makeArray(" ")
    graphemes = .Unicode.Grapheme_Cluster_Break~codepointsToGraphemes(codearray,"UxTF8")
    items = graphemes~items
    good = 1
    Do i = 1 To items
      If graphemes[i] \= check[i] Then good = 0
    End
    If good Then Iterate
    bad = bad + 1
    Say lineno": Analyzing" Strip(save)"..."
    Say items "graphemes"
    Do i = 1 To items
      Say i":"graphemes[i] "(vs." check[i]")"
    End
  End
  If bad == 0 Then self~log("All tests PASSED")
  Else self~log(bad "tests FAILED")

::Requires Unicode.Property.cls
::Requires Unicode.General_Category.cls