/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

--------------------------------------------------------------------------------
-- This program is part of the automated test suite. See tests/test.all.rex   --
-------------------------------------------------------------------------------- 
 
Arg auto .
auto = auto == (!DS("AUTO"))

tmpfile = SysTempFileName((!DS("????.file")))

If tmpFile == (!DS("")) Then Do
  Say (!DS("Cannot create temporary file."))
  Exit (!DS(1))
End

Say (!DS("Creating a UTF-16 file..."))

crlf = (Bytes("000d 000a"x))
--                ---Man--- -ZWJ --Woman-- --a- --´- LowSurrogate
Call CreateFile ((Bytes("D83D DC68 200D D83D DC69 0061 0301 DC68"X)),(!DS(""))),crlf

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-16 CODEPOINTS REPLACE'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-16 CODEPOINTS REPLACE"))

Call Test tmpFile, , , (Bytes("F09F91A8"X)),                     (!DS(0)) 
Call Test tmpFile, ,(!DS(4)), (Bytes("E2808DF09F91A961CC81"X)),         (!DS(0))
Call Test tmpFile, , , (Bytes("efbfbd"X))                ,       (!DS(0))
If \ auto Then Parse Pull


Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-16 REPLACE TEXT'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-16 REPLACE TEXT"))

Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0)) 
Call Test tmpFile, , , (Bytes("C3A1"X))                  ,       (!DS(0))
Call Test tmpFile, , , (Bytes("efbfbd"X))                ,       (!DS(0))
If \ auto Then Parse Pull


Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-16 REPLACE GRAPHEMES'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-16 REPLACE GRAPHEMES"))

Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0)) 
Call Test tmpFile, , , (Bytes("61CC81"X))                ,       (!DS(0)) 
Call Test tmpFile, , , (Bytes("efbfbd"X))                ,       (!DS(0))
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-16 SYNTAX TEXT'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-16 SYNTAX TEXT"))

                        --Man--- -ZWJ-- --Woman- -á--
Call Test tmpFile, ,(!DS(2)), (Bytes("F09F91A8 E2808D F09F91A9 C3A1"X)), (!DS(0))
                        --Man--- -ZWJ-- --Woman-
Call Test tmpFile,(!DS(1)),(!DS(1)), (Bytes("F09F91A8 E2808D F09F91A9"X)),         (!DS(0))
                     -- -a -´--
Call Test tmpFile,(!DS(2)),(!DS(1)), (Bytes("61 CC81"X)),                          (!DS(1))
Call Test tmpFile,(!DS(1)),(!DS(0)), (!DS("")),                                  (!DS(0))
Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),           (!DS(0)) 
Call Test tmpFile, , , (Bytes("C3A1"X))                  ,           (!DS(0))
Call Test tmpFile, , , (!DS(""))                       ,           (!DS(1))
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-16 SYNTAX GRAPHEMES'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-16 SYNTAX GRAPHEMES"))

                        --Man--- -ZWJ-- --Woman- -a -´--
Call Test tmpFile, ,(!DS(2)), (Bytes("F09F91A8 E2808D F09F91A9 61 CC81"X)), (!DS(0)) 
                        --Man--- -ZWJ-- --Woman-
Call Test tmpFile,(!DS(1)),(!DS(1)), (Bytes("F09F91A8 E2808D F09F91A9"X)),         (!DS(0))
                     -- -a -´--
Call Test tmpFile,(!DS(2)),(!DS(1)), (Bytes("61 CC81"X)),                          (!DS(1))
Call Test tmpFile,(!DS(1)),(!DS(0)), (!DS("")),                                  (!DS(0))
Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),           (!DS(0)) 
Call Test tmpFile, , , (Bytes("61CC81"X))                ,           (!DS(0)) 
Call Test tmpFile, , , (!DS(""))                       ,           (!DS(1))
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-16 SYNTAX CODEPOINTS'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-16 SYNTAX CODEPOINTS"))

Call Test tmpFile, ,(!DS(2)), (Bytes("F09F91A8E2808D"X)),               (!DS(0)) 
Call Test tmpFile,(!DS(1)),(!DS(1)), (Bytes("F09F91A8"X)),                     (!DS(0))
Call Test tmpFile,(!DS(2)),(!DS(1)), (Bytes("E2808D"X)),                       (!DS(1))
Call Test tmpFile,(!DS(1)),(!DS(0)), (!DS("")),                              (!DS(0))
Call Test tmpFile, , , (Bytes("F09F91A8"X)),                     (!DS(0)) 
Call Test tmpFile, ,(!DS(4)), (Bytes("E2808DF09F91A961CC81"X)),         (!DS(0))
Call Test tmpFile, , , (!DS(""))                       ,       (!DS(1)) 
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say
Say (!DS("Creating a UTF-32 file..."))
Say 

crlf = (Bytes("0000000d0000000a"x))
Call CreateFile ((Bytes("0001F468 0000200D 0001F469 00000061 00000301 0000DC68"X)),(!DS(""))),crlf

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-32 SYNTAX TEXT'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-32 SYNTAX TEXT"))

Call Test tmpFile, ,(!DS(2)), (Bytes("F09F91A8E2808DF09F91A9C3A1"X)),   (!DS(0)) 
Call Test tmpFile,(!DS(1)),(!DS(1)), (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0))
Call Test tmpFile,(!DS(2)),(!DS(1)), (Bytes("61CC81"X)),                       (!DS(1))
Call Test tmpFile,(!DS(1)),(!DS(0)), (!DS("")),                              (!DS(0))
Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0)) 
Call Test tmpFile, , , (Bytes("C3A1"X))                  ,       (!DS(0))
Call Test tmpFile, , , (!DS(""))                       ,       (!DS(1))
If \ auto Then Parse Pull


Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-32 SYNTAX GRAPHEMES'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-32 SYNTAX GRAPHEMES"))

Call Test tmpFile, ,(!DS(2)), (Bytes("F09F91A8E2808DF09F91A961CC81"X)), (!DS(0)) 
Call Test tmpFile,(!DS(1)),(!DS(1)), (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0))
Call Test tmpFile,(!DS(2)),(!DS(1)), (Bytes("61CC81"X)),                       (!DS(1))
Call Test tmpFile,(!DS(1)),(!DS(0)), (!DS("")),                              (!DS(0))
Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0)) 
Call Test tmpFile, , , (Bytes("61CC81"X))                ,       (!DS(0)) 
Call Test tmpFile, , , (!DS(""))                       ,       (!DS(1))
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-32 REPLACE TEXT'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-32 REPLACE TEXT"))

Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0)) 
Call Test tmpFile, , , (Bytes("C3A1"X))                  ,       (!DS(0))
Call Test tmpFile, , , (Bytes("efbfbd"X))                ,       (!DS(0))
If \ auto Then Parse Pull


Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-32 REPLACE GRAPHEMES'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-32 REPLACE GRAPHEMES"))

Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0)) 
Call Test tmpFile, , , (Bytes("61CC81"X))                ,       (!DS(0)) 
Call Test tmpFile, , , (Bytes("efbfbd"X))                ,       (!DS(0))
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-32 SYNTAX CODEPOINTS'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-32 SYNTAX CODEPOINTS"))

Call Test tmpFile, ,(!DS(2)), (Bytes("F09F91A8E2808D"X)),               (!DS(0)) 
Call Test tmpFile,(!DS(1)),(!DS(1)), (Bytes("F09F91A8"X)),                     (!DS(0))
Call Test tmpFile,(!DS(2)),(!DS(1)), (Bytes("E2808D"X)),                       (!DS(0))
Call Test tmpFile,(!DS(1)),(!DS(0)), (!DS("")),                              (!DS(0))
Call Test tmpFile, , , (Bytes("F09F91A8"X)),                     (!DS(0)) 
Call Test tmpFile, ,(!DS(4)), (Bytes("E2808DF09F91A961CC81"X)),         (!DS(0))
Call Test tmpFile, , , (!DS(""))                       ,       (!DS(1)) 
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-32 CODEPOINTS REPLACE'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-32 CODEPOINTS REPLACE"))

Call Test tmpFile, , , (Bytes("F09F91A8"X)),                     (!DS(0)) 
Call Test tmpFile, ,(!DS(4)), (Bytes("E2808DF09F91A961CC81"X)),         (!DS(0))
Call Test tmpFile, , , (Bytes("efbfbd"X))                ,       (!DS(0))
If \ auto Then Parse Pull

Say
Say (!DS("Creating a UTF-8 file..."))
Say 

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))

crlf = (Bytes("0d0a"x))  

Call CreateFile ((Bytes("F09F91A8 E2808D F09F91A9 61 CC81 FF"X)),(!DS(""))),crlf

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-8 SYNTAX TEXT'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-8 SYNTAX TEXT"))

Call Test tmpFile, ,(!DS(2)), (Bytes("F09F91A8E2808DF09F91A9C3A1"X)),   (!DS(0))
Call Test tmpFile,(!DS(1)),(!DS(1)), (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0))
Call Test tmpFile,(!DS(2)),(!DS(1)), (Bytes("61CC81"X)),                       (!DS(1))
Call Test tmpFile,(!DS(1)),(!DS(0)), (!DS("")),                              (!DS(0))
Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0)) 
Call Test tmpFile, , , (Bytes("C3A1"X))                  ,       (!DS(0))
Call Test tmpFile, , , (!DS(""))                       ,       (!DS(1))
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-8 SYNTAX GRAPHEMES'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-8 SYNTAX GRAPHEMES"))

Call Test tmpFile, ,(!DS(2)), (Bytes("F09F91A8E2808DF09F91A961CC81"X)), (!DS(0)) 
Call Test tmpFile,(!DS(1)),(!DS(1)), (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0))
Call Test tmpFile,(!DS(2)),(!DS(1)), (Bytes("61CC81"X)),                       (!DS(1))
Call Test tmpFile,(!DS(1)),(!DS(0)), (!DS("")),                              (!DS(0))
Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0)) 
Call Test tmpFile, , , (Bytes("61CC81"X))                ,       (!DS(0)) 
Call Test tmpFile, , , (!DS(""))                       ,       (!DS(1))
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-8 REPLACE TEXT'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-8 REPLACE TEXT"))

Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0)) 
Call Test tmpFile, , , (Bytes("C3A1"X))                  ,       (!DS(0))
Call Test tmpFile, , , (Bytes("efbfbd"X))                ,       (!DS(0))
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-8 REPLACE GRAPHEMES'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-8 REPLACE GRAPHEMES"))

Call Test tmpFile, , , (Bytes("F09F91A8E2808DF09F91A9"X)),       (!DS(0)) 
Call Test tmpFile, , , (Bytes("61CC81"X))                ,       (!DS(0)) 
Call Test tmpFile, , , (Bytes("efbfbd"X))                ,       (!DS(0))
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-8 SYNTAX CODEPOINTS'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-8 SYNTAX CODEPOINTS"))

Call Test tmpFile, ,(!DS(2)), (Bytes("F09F91A8E2808D"X)),               (!DS(0)) 
Call Test tmpFile,(!DS(1)),(!DS(1)), (Bytes("F09F91A8"X)),                     (!DS(0))
Call Test tmpFile,(!DS(2)),(!DS(1)), (Bytes("E2808D"X)),                       (!DS(1))
Call Test tmpFile,(!DS(1)),(!DS(0)), (!DS("")),                              (!DS(0))
Call Test tmpFile, , , (Bytes("F09F91A8"X)),                     (!DS(0)) 
Call Test tmpFile, ,(!DS(4)), (Bytes("E2808DF09F91A961CC81"X)),         (!DS(0))
Call Test tmpFile, , , (!DS(""))                       ,       (!DS(1)) 
If \ auto Then Parse Pull

Call !Stream tmpFile, (!DS("C")), (!DS("Close"))
Say (!DS("After 'Open Read Encoding UTF-8 CODEPOINTS REPLACE'"))
Call !Stream tmpFile, (!DS("C")), (!DS("Open Read Encoding UTF-8 CODEPOINTS REPLACE"))

Call Test tmpFile, , , (Bytes("F09F91A8"X)),                     (!DS(0)) 
Call Test tmpFile, ,(!DS(4)), (Bytes("E2808DF09F91A961CC81"X)),         (!DS(0))
Call Test tmpFile, , , (Bytes("efbfbd"X))                ,       (!DS(0))
If \ auto Then Parse Pull

Say (!DS("All tests PASSED!"))

Call Exit (!DS(0))

Test: Procedure Expose tmpfile
  Parse Arg fn, start, length, expected, syntax
  
  Call !CharOut , (!DS("Testing 'Call CharIn """))fn||(!DS(""",")) start||(!DS(",")) length||(!DS("'... "))
  
  Signal On Syntax 
  If length == (!DS("")) Then Length = (!DS(1))
  If Arg((!DS(2)),(!DS("o"))) Then Call !CharIn fn,      , length
  Else               Call !CharIn fn, start, length
  If syntax Then Do
    Say (!DS("FAILED!"))
    Say (!DS("Expected Syntax error."))
    Call Exit (!DS(1))
  End
  If result == expected Then Do
    Say (!DS("PASSED!"))
    Return
  End
  Say (!DS("FAILED!"))
  Call Exit (!DS(1))
  
Syntax:
  If \syntax Then Do
    Say (!DS("FAILED!"))
    Say (!DS("Traceback follows:"))
    Say
    Say Condition((!DS("O")))~TraceBack~makeArray
    Say
    Say (!DS("Unexpected Syntax error:")) rc||(!DS("."))Condition((!DS("E"))) (!DS("on")) Condition((!DS("O")))~program||(!DS(":")) Condition((!DS("O")))~ErrorText
    Say Condition((!DS("O")))~Message
    Call Exit (!DS(1))
  End
  Say (!DS("PASSED!"))
  Return
 
Exit:
  Call !Stream tmpfile,(!DS("C")),(!DS("CLOSE"))
  Call SysFileDelete tmpfile
  Exit Arg((!DS(1)))

CreateFile: Procedure Expose tmpFile
  Call !Stream tmpFile,(!DS("C")),(!DS("Open Write Replace"))
  Use Strict Arg lines, eol
  Do counter c line Over lines
    Call !CharOut tmpFile, line
    -- No line-end after last line    
    If c < lines~items Then Call !CharOut tmpFile, eol
  End
  Call !Stream tmpFile,(!DS("C")),(!DS("CLOSE"))
Return  

::Requires 'Unicode.cls'
