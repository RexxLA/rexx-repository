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
/*  The UNICODE.CASE class                                                   */
/*  ======================                                                   */
/*                                                                           */
/*  Various case operations                                                  */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1e JMB 20230721 Initial release. Implements toLowercase(string)       */
/*                                                                           */
/*****************************************************************************/

-- Requires "../Runes.cls" won't work

separator = .File~separator
Parse source . . myself  
myDir = Left( myself, LastPos( separator, myself ) )
Call (myDir"../Runes.cls")

--
-- Running this file (or ::requiring it) will generate the binary
-- file if not present.
--

::Class Unicode.Case Public SubClass Unicode.Property

::Constant UnicodeData           "UnicodeData-15.0.0.txt"  
::Constant DerivedCoreProperties "DerivedCoreProperties-15.0.0.txt"
::Constant BinaryFile            "Case.bin"  

::Attribute myself Class Get 

::Method toLowercase Class
  Expose mask.
/*****************************************************************************/
/*  Maps a string to its corresponding Lowercase_Mapping                     */
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
/*****************************************************************************/
  Use Strict Arg string
  
  runes = .Runes~new(string)

  res     = ""
  changes = 0
  codes   = runes~allRunes
  length  = Words(codes)
  Do counter i code Over codes~makeArray(" ")
    If code == "0130" Then Do -- Not one-to-one: 0130 --> 0069 0307
      res   ||= "69CC87"X
      changes = 1
      Iterate
    End
    If code == "03A3", FinalSigma() Then Iterate -- Context dependent
    n     = X2D(code)
    index = X2D(C2X(self~TwoStageTable.getByteAtFromInt("Lowercase",n)))
    If index \== 0 Then Do
      diff  = X2D(C2X(self~getPersistent("Lowercase.Differences")[index*4-3,4]),8)
      n     = n + diff
      changes = 1
    End
    res   ||= UTF8(d2x(n))
  End
  
  If \changes Then Return string
  
  Return res
  
FinalSigma:  
  Do n = i - 1 While n >= 1, BitAnd(self~TwoStageTable.getByteAtFromCode("Cased_Case_Ignorable",Word(codes,n)),mask.Case_Ignorable) == mask.Case_Ignorable
  End
  If n >=1, BitAnd(self~TwoStageTable.getByteAtFromCode("Cased_Case_Ignorable",Word(codes,n)),mask.Cased) \== mask.Cased Then Return 0
  Do n = i + 1 While n <= length, BitAnd(self~TwoStageTable.getByteAtFromCode("Cased_Case_Ignorable",Word(codes,n)),mask.Case_Ignorable) == mask.Case_Ignorable
  End
  If n <=length, BitAnd(self~TwoStageTable.getByteAtFromCode("Cased_Case_Ignorable",Word(codes,n)),mask.Cased) == mask.Cased Then Return 0
  res ||= "CF82"X
  changes = 1
Return 1
  
UTF8: Procedure -- Internal, fast
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
  

::Method Generate Class
  Expose myDir separator mask.
  
  -- Default is 0, a character maps to itself
  --
  -- No codepoint >= U+20000 has an explicit lowercase mapping
    
  Call Time "R"
  
  self~log( "Generating binary file..." )
  
  -- Parse UnicodeData.txt first to tabulate the Lowercase_mapping property.
  -- This property returns a codepoint. To preserve space, we calculate
  -- the difference between the source codepoint and the property, store
  -- these differences in an auxiliary table of 32-bit signed integers, 
  -- and store the index into this table as the value of the property.
  
  inFile = myDir".."separator"UCD"separator || self~UnicodeData
  
  Call Stream inFile, "c", "query exists"
  
  If result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")
  
  buffer = .MutableBuffer~new( Copies( "00"x, X2D( 20000 ) ) )

  count = 0
  code. = 0
  code.0 = 0
  diffs = ""
  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code";" ";" ";" ";" ";" ";" ";" ";" ";" ";" ";" ";" ";"lower";"
    If lower == "" Then Iterate
    count += 1
    diff = X2d(lower) - X2d(code)
    If code.diff = 0 Then Do
      code.0 += 1
      code.diff = code.0
      diff.[code.0] = diff
      diffs ||= D2C(diff,4)
    End
    buffer[X2d(code)+1] = X2C(D2X(code.diff))
  End
  
  Call Stream inFile, "c", "Close"
  
  diffs = Strip(diffs)

  array = self~TwoStageTable.Compress(buffer)
  
  self~setPersistent("Lowercase.Table1",       array[1])
  self~setPersistent("Lowercase.Table2",       array[2])
  self~setPersistent("Lowercase.Differences",  diffs)
  
  -- Now we have to parse DerivedCoreProperties.txt for the Lowercase, Uppercase 
  -- Cased and Case_Ignorable properties.
  
  inFile = myDir".."separator"UCD"separator || self~DerivedCoreProperties

  Call Stream inFile, "c", "query exists"
  
  If result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")
  
  buffer = .MutableBuffer~new( Copies( "00"x, X2D( 20000 ) ) )
  
  -- mask. values created in activate method

  Do While Lines(inFile) > 0
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";" value "#"
    value = Strip(value)
    If WordPos(value, "Lowercase Uppercase Cased Case_Ignorable") == 0 Then Iterate
    value = Upper(value)
    codes = Strip(codes)
    If Pos("..",codes) > 0 Then Parse Var codes min".."max
    Else Do
      min = codes
      max = codes
    End
    Do i = X2D(min) to X2D(max)
      buffer[i+1] = BitXor(buffer[i+1], mask.value)
    End
  End
  
  Call Stream inFile, "c", "Close"

  array = self~TwoStageTable.Compress(buffer)
  
  self~setPersistent("Cased_Case_Ignorable.Table1",       array[1])
  self~setPersistent("Cased_Case_Ignorable.Table2",       array[2])
  
  self~SavePersistent( myDir".."separator"bin"separator || self~binaryFile )
  
  elapsed = Time("E")
  self~log( "Done, took" elapsed "seconds." )
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
  Expose separator myself myDir mask.
    
  self~activate:super
  
  separator = .File~separator
  
  Parse source . . myself  
  myDir = Left( myself, LastPos( separator, myself ) )

  -- For DerivedCoreProperties
  
  mask.Lowercase      = "80"X
  mask.Uppercase      = "40"X
  mask.Cased          = "20"X
  mask.Case_Ignorable = "10"X
    
  self~loadPersistent( myDir".."separator"bin"separator || self~binaryFile )

::Requires Unicode.Property.cls
