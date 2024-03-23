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
 
-- lineout.rxu - Test the extended features of the LINEOUT BIF.
 
Arg auto 
auto = auto == (!DS("AUTO"))
 
tmpfile = SysTempFileName((!DS("????.file")))

If tmpFile == (!DS("")) Then Do
  Say (!DS("Cannot create temporary file."))
  Exit (!DS(1))
End

Say (!DS("Testing the LINEOUT BIF"))
Say (!DS("----------------------"))
Say
/*
Say "When the program appears to stop, please press ENTER to continue"
Say
If \auto Then Parse pull
*/
Call !Stream tmpFile,(!DS("C")), (!DS("Open Write Encoding UTF-16"))

Call !LineOut tmpFile, (Bytes("Abá")) (Bytes("👨")) (Bytes("FF"X))
Call !Stream  tmpFile, (!DS("C")), (!DS("Close"))

Call !Stream  tmpFile,(!DS("C")), (!DS("Open Read"))
line = !LineIn(tmpFile)(Bytes("0A"X))
expected = (Bytes("0041006200E10020D83DDC680020FFFD000D000A"X))
If line \== expected Then Do
  Say (!DS("FAILED!"))
  Say
  Say (!DS("Expected: '"))expected~c2x||(!DS("'."))
  Say (!DS("Found:    '"))line~c2x||(!DS("'."))
  Call Exit (!DS(1))
End
Say (!DS("...A...b...á... --(Man)-... REPL..CR..LF"))
Say line~c2x

Call Exit (!DS(0))

Exit:
  Call !Stream tmpfile,(!DS("C")),(!DS("CLOSE"))
  Call SysFileDelete tmpfile
  Exit Arg((!DS(1)))

4: Return !Right(Arg((!DS(1))),(!DS(4)),(Bytes("00"x)))

Test: Procedure Expose line. tmpfile
  Use Strict Arg read, n, label
  If read \== line.n Then Do
    Say (!DS("Test failed: line no.")) n,,
      (!DS("should be '"))line.n||(!DS("' ('"))!c2x(line.n)(!DS("'X),")),,
      (!DS("found     '"))read||(!DS("' ('"))!c2x(read)(!DS("'X)."))
    Call Exit (!DS(1))
  End
  Say label||(!DS(": PASSED."))
Return

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
