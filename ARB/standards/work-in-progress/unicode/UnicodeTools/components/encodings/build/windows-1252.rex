/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

-- For cp1252.cls
inFile = "../../UCD/CP1252-2.0.0.TXT"

Do While Lines(inFile)
  line = LineIn(inFile)
  If line[1] == "#" Then Iterate
  If line[1] = ""   Then Iterate
  Parse Upper Var line "X"ascii . "0X"cp1252 ."#"
  --If "00"ascii == cp1252 Then Iterate
  
  -- Wikipedia: "According to the information on Microsoft's and the Unicode Consortium's websites, 
  -- positions 81, 8D, 8F, 90, and 9D are unused; however, the Windows API MultiByteToWideChar maps 
  -- these to the corresponding C1 control codes. The "best fit" mapping documents this behavior, too."
  
  If cp1252 == "" Then cp1252 = "00"ascii
  
  Say "  decode.['"ascii"'X ] = '"cp1252"'; encode.['"cp1252"'] = '"ascii"'X"
End