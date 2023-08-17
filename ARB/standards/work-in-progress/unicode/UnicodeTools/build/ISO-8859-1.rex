-- For iso88591.cls
inFile = "../UCD/ISO-8859-1-3.0.0.TXT"

Do While Lines(inFile)
  line = LineIn(inFile)
  If line[1] == "#" Then Iterate
  If line[1] = ""   Then Iterate
  Parse Upper Var line "X"ascii . "0X"iso88591 ."#"
  --If "00"ascii == iso88591 Then Iterate
  
  If iso88591 == "" Then iso88591 = "00"ascii
  
  Say "  decode.['"ascii"'X ] = '"iso88591"'; encode.['"iso88591"'] = '"ascii"'X"
End