/* Add a few lines to the table of keywords. */
  In = "is.kwa"
  Out = "keys.inc"
  "ERASE" Out
  call lineout Out,"$DoKeys:"
  call lineout Out,' db $UNTIL-KeysBase,5,"UNTIL"'
  call lineout Out,' db $WHILE-KeysBase,5,"WHILE"'
  do while lines(In)>0
    Line = linein(In)
    if left(Line,10)=" db $UNTIL" then
      call lineout Out,"$CondKeys:"
    if left(Line,9)=" db $WITH" then
      call lineout Out,"$WithKey:"
    if left(Line,9)=" db $THEN" then
      call lineout Out,"$ThenKey:"
    if Line<>'' then call lineout Out,Line
  end
