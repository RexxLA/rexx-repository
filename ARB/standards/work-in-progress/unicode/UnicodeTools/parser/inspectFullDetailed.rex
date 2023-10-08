/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

-- inspectFullDetailed.rex</code> is a sample program for the Rexx Tokenizer. It tokenizes a file, and prints the full detailed tokenization. 
 
Parse Arg infile
quote = infile[1]
If Pos(quote,"""'") > 0 Then Parse Arg (quote)inFile(quote)

If Stream(inFile,"C","Query exists") == "" Then Do
  Say "File '"inFile"' not found."
  Exit 1
End

size = Stream(infile,"c","q size") -- This
array = CharIn(inFile,,size)~makeArray

t = .ooRexx.Unicode.Tokenizer~new(array,1)

Call Time "R"

Do i = 1 By 1
  x = t~getFullToken
If x[class] == "F" | x[class] == "E" Then Leave; Else

  Say i"["||X[location]"]: '"||X["VALUE"]"' ("||X[class] X[subclass]")"
  If x~hasIndex(absorbed) Then Do
    cloning = x[cloneIndex]
    Say "    ---> Absorbed:"
    Do j = 1 To x[absorbed]~items
      Say "    "j"["||x[absorbed][j][location]"] ("||X[absorbed][j][class] X[absorbed][j][subClass]"): '"||x[absorbed][j][value]"'" Copies("<==",j = cloning)
      If x[absorbed][j]~hasIndex(absorbed) Then Say "::::::::::" j
    End
  End

End

If x[class] == "E" Then Do
  Say
  Say "Syntax error" x[number] "on line" x[line]":" x[message]
  Say x[secondaryMessage]
End

Say Time("E")

::Requires Rexx.Tokenizer.cls
