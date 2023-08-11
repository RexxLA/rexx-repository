cr   = "0d"x
lf   = "0a"x
file = "a.file"

Call Stream  file,"c", "open write replace"
Call CharOut file,"one"cr"two"lf"three"cr""lf"four"lf""cr"five"
Call Stream  file,"c","close"

Do i = 1 By 1 While Lines(file) > 0
  line = LineIn(file)
  -- Beware of CR: it "eats" all previous chars and returns to col 1
  Say i":" ChangeStr(cr,line,"_") "('"C2X(line)"'X)"
End
