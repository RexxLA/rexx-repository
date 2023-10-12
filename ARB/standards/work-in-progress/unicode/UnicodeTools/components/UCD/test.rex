Call Unicode.cls


Exit

fn = "UnicodeData-15.0.0.txt"

count = 0
single = 0
last. = 0
first. = 0
firsts = .MutableBuffer~new
lasts = .MutableBuffer~new

Do While Lines(fn) > 0
  Parse Value LineIn(fn) With code";" ";" ";" ";" ";"decomp";"
  If decomp = "" Then Iterate
  If Left(decomp,1) == "<" Then Iterate
  If Words(decomp) == 1 Then Do
    single += 1
    -- Say code "::" decomp
  End
  Else Do
    Parse Var decomp first last
    If first.first == 0 Then Do
      first.0    += 1
      first.[first.0] = first
      first.first += first.0
      firsts~append(Right(X2C(first),3,"00"X))
    End
    If last.last == 0 Then Do
      last.0    += 1
      last.[last.0] = last
      last.last += last.0
      lasts~append(Right(X2C(last),3,"00"X))
    End
    bin = last.0 * 512 + first.0
    lastOffset  = bin %  512
    firstOffset = bin // 512
    Say code Right(D2X(bin),4,0) lastOffset firstOffset "["first.[firstOffset]  last.[lastOffset]"]"
    Say code Right(D2X(bin),4,0) lastOffset firstOffset "["C2X(firsts[1-3+firstOffset*3,3]) C2X(lasts[1-3+lastOffset*3,3])"]"
  End
  count += 1
End

Say "Total:" count", single:" single", last:" last.0", first:" first.0
Say "Length(firsts):" Length(firsts)", "Length(firsts)/3 "* 3"
Say "Length(lasts ):" Length(lasts )", "Length(lasts )/3 "* 3"