-- For cp437.cls
inFile = "../UCD/CP437-2.0.0.TXT"

Do While Lines(inFile)
  line = LineIn(inFile)
  If line[1] == "#" Then Iterate
  If line[1] = ""   Then Iterate
  Parse Upper Var line "X"ascii . "0X"cp437 ."#"
  
  Say "  decode.['"ascii"'X ] = '"cp437"'; encode.['"cp437"'] = '"ascii"'X"
End