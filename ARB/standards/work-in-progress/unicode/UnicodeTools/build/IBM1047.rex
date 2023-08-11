inFile = "../IANA/iana.org_assignments_charset-reg_IBM1047.txt"

k = 0
Do While Lines(inFile) > 0
  line = LineIn(inFile)
  If k == 2 Then Leave
  If line~startsWith("*------") Then k += 1
End

str = ""
a2e. = ""
Do Until line~startsWith("*")
  Parse Var line ebcdic ucs2 .
  ucs2 = Right(ucs2,2)
  a2e.ucs2 = ebcdic
  str ||= ucs2
  line = LineIn(inFile)
End  
Say "IBM10472ASCII = '"str"'X"

str=""
Do ucs2 Over a2e.~allIndexes~sort
  str ||= a2e.ucs2
End

Say "ASCII2IBM1047 = '"str"'X"
