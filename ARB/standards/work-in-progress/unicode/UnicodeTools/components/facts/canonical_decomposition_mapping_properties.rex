

-- About UnicodeData.txt:

-- All --> Canonical <-- Decomposition Mappings (column 6, 1-based) obey the following rules:
--
-- 1) They are either absent, meaning the identity, i.e., code --> code, or
-- 2) singletons, i.e., code1 --> code2, or
-- 3) they are pair decompositions, i.e., code --> first last, and in this case
-- 3a) last does not have any further decomposition, i.e., last --> last.
-- 4) The sequence of characters in a full decomposition does not have adjacent pairs A, B such
--    that ccc(A) > ccc(B).
-- 5) If a singleton decomposition firther decomposes, this is always to a pair

sep = .File~separator
Parse Source . . myself 
mydir = Left(myself, Lastpos(sep, myself) )

inFile = mydir".."sep"UCD"sep"UnicodeData-15.0.0.txt"

ccc.    = 0
decomp. = ""

Call Stream inFile, "C", "Open Read"

  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code";" ";" ";"ccc";" ";"decomp";"
    If ccc \== 0 Then ccc.code = ccc
    If decomp == "" Then Iterate
    If decomp[1] == "<" Then Iterate
    decomp.code = decomp
    If Words(decomp) > 2 Then Do
      Say "Assumption invalidated:" code "decomposes to" decomp", which has more than two words."
      Exit 1
    End
  End

Call Stream inFile, "C", "Close"

Call Stream inFile, "C", "Open Read"

  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code";" ";" ";"ccc";" ";"decomp";"
    If decomp == "" Then Iterate
    If decomp[1] == "<" Then Iterate
    Say code ccc decomp
    If Words(decomp) == 1 Then Do
      If decomp.decomp == "" Then Iterate
      If Words(decomp.decomp) \== 2 Then Do
        Say "Assumption invalidated:" code "decomposes to" decomp", and" decomp", in turn, decomposes to" decomp.decomp"."
        Exit 1
      End
    End
    If Words(decomp) == 2 Then Do
      Parse Var decomp first last
      If decomp.last \== "" Then Do
        Say "Assumption invalidated:" code "decomposes to" decomp", and" last", in turn, decomposes to" decomp.last"."
        Exit 1
      End
      Do While decomp.first \== ""
        Parse Var decomp.first first middle
        last = middle last
      End
      cccs = ""
      lastccc = 0
      Do i = 1 To Words(first last)
        newccc = ccc.[Word(first last,i)]
        If newccc < lastccc Then Do
          Say "Assumption invalidated:" code "decomposes to" first last", and the ccc sequence includes" lastccc newccc"."
          Exit 1
        End
        cccs ||= " "ccc.[Word(first last,i)]
      End
--      Say code "-->" "("ccc.first")" first last "("ccc.[Word(first last,Words(first last))]")"
--      Say "          "cccs
    End
  End

Call Stream inFile, "C", "Close"