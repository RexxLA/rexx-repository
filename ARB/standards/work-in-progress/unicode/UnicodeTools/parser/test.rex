Call Time "R"

tmpFile = "temp.file"

lines = 0

Do inFile Over ("Rexx.Tokenizer.cls", "../Stream.cls", "../rxu.rex")

  Call TokenizeAndCollect inFile, tmpFile, 0
  Call TokenizeAndCollect inFile, tmpFile, 1, 0
  Call TokenizeAndCollect inFile, tmpFile, 1, 1
  
End

Say "Time=" Time("E")", total=" lines "lines."

Exit

TokenizeAndCollect: Procedure Expose lines
  Use Arg inFile, outFile, full = 1, detailed = 0

  If full Then Do
    full? = "full"
    If detailed then full? ||= " detailed"
    Else             full? ||= " undetailed"
    End
  Else         
    full? = "simple"
  
  Say
  Say "Tokenize '"inFile"' and collect into '"outFile"'. Comparing" full? "tokenization results..."
  
  eol = "0D0A"X
  
  size  = Stream(infile,"c","q size") -- This
  array = CharIn(inFile,,size)~makeArray
  
  lines += array~items

  count = 0

  t = .ooRexx.Tokenizer~new(array,detailed)

  lastLine = 1
  Do i = 1 By 1
    If full Then 
      x = t~getFullToken
    Else
      x = t~getSimpleToken
  If x[class] == "F" | x[class] == "E" Then Leave
    If x~hasIndex(absorbed) Then y = x[absorbed]
    Else                         y = .array~of(x)
    Do z over y
      count += 1
      Parse Value z[location] With line1 col1 line2 col2
      Do i = lastLine To line1-1
        Call CharOut outFile, eol -- Sources are created in Windows
      End
      If line1 == line2 Then Do
        Call CharOut outFile, array[line1][col1,col2-col1]
        lastLine = line1
      End
      Else Do line = line1 To line2
        Select Case line
          When line1 Then Call CharOut outFile, SubStr(array[line1],col1)eol
          When line2 Then Call CharOut outFile, Left(array[line2],col2-1)
          Otherwise       Call CharOut outFile, array[line]eol
        End
        lastLine = line2
      End
    End
  End
  -- Final EOL
  Call CharOut outFile, eol -- Sources are created in Windows
  
  Call Stream outFile,"c","Close"
  Call Stream inFile ,"c","Close"
  
  If x[class] == "E" Then Do
    Say
    Say "Syntax error" x[number] "on line" x[line]":" x[message]
    Say x[secondaryMessage]
    Say
    Say "Press ENTER to continue"
    Parse Pull
  End

  
  "FC" inFile outFile "> nul"
  
  xrc = rc
  
  If xrc == 0 Then Do
    Say "Files are identical," count "tokens examined."
    Call SysFileDelete outFile
  End
  
Return xrc

::Requires Rexx.Tokenizer.cls
