

Firsts. = 0
Lasts.  = 0

inFile = "UnicodeData-15.0.0.txt"

count = 0

-- https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, p. 139.
--
-- "D114 Primary composite: A Canonical Decomposable Character (D69) which is not a Full
-- Composition Exclusion."
--
-- "D115 Blocked: Let A and C be two characters in a coded character sequence <A, ... C>. C is
--  blocked from A if and only if ccc(A) = 0 and there exists some character B between A
--  and C in the coded character sequence, i.e., <A, ... B, ... C>, and either ccc(B) = 0 or
--  ccc(B) >= ccc(C)."
-- "• Because the Canonical Composition Algorithm operates on a string which is
--  already in canonical order, testing whether a character is blocked requires
--  looking only at the immediately preceding character in the string."
--
-- Assume that ccc(C) == 0. The only possibility to combine is that L is the previous
-- character and there exists a Primary Composite P which is canonically equivalent to <L,C>.
--

PrimaryComposite. = ""
Diffs. = 0
minDiff = 0
maxDiff = 0
Do While Lines(inFile) > 0
  Parse Value LineIn(inFile) With code";" ";" ";" ccc";" ";"decomp";"
  If code[1] == "<", ccc > 0 Then Pull
  If decomp     = "" Then Iterate
  If decomp[1] == "<" Then Iterate
  If Unicode(code,"Property","Full_Composition_Exclusion") Then Iterate
  Parse Var decomp first last .
  diff = X2D(first)-X2D(last)
  minDiff = Min(diff,minDiff)
  maxDiff = Max(diff,maxDiff)
  Say code "::" first last diff

    If Firsts.first == 0 Then Do
      Firsts.first  += 1
      Firsts.0      += 1
    End
    If Lasts.last   == 0 Then Do
      Lasts.last    += 1
      Lasts.0       += 1
    End
    If PrimaryComposite.last = "" Then Do
      PrimaryComposite.last = .StringTable~new
      PrimaryComposite.last[first] = code
    End
    Else PrimaryComposite.last[first] = code
    If Diffs.diff   == 0 Then Diffs.0       += 1
    Diffs.diff    += 1
    count += 1
End

Say "Total:" count", firsts:" firsts.0", lasts=" lasts.0", diffs="diffs.0


Trace ?a

Nop

/*
offset = 4096
Say "MinDiff -" offset":" (minDiff-offset) D2X(minDiff-offset,4)
Say "MaxDiff -" offset":" (maxDiff-offset) D2X(maxDiff-offset,4)
*/

::Requires Unicode.cls