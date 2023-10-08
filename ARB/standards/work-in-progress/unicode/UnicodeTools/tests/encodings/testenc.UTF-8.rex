/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

-- Tough tests. Will take some few minutes

myName = "UTF-8"

utf8 = .Encoding[myName]

Call Time "R"

count  = 0
PASS   = 1
FAIL   = 0

Call Tick "Encoder/decoder"
Call Tick "==============="
Call Tick ""
Call Tick "Running all tests for" myname"..."
Call Tick ""
Call Tick "Encoding tests"
Call Tick "--------------"
Call Tick ""

Call Tick "Encoding tests, 00..FF"

Do i = 0 To 127
  c = X2C(D2X(i))
  If c \== utf8~encode(c) Then Call Failed
  count += 1
End

Call Tick "Encoding tests, C2..DF, 80..BF"

Do i = X2D("C2") To X2D("DF")
  Do j = X2D("80") To X2D("BF")
    ix = D2X(i)
    jx = D2X(j)
    c = X2C(ix)X2C(jx)
    If c \== utf8~encode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Encoding tests, E0..E0, A0..BF, 80..BF"

Do i = X2D("E0") To X2D("E0")
  Do j = X2D("A0") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If c \== utf8~encode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Encoding tests, E1..EC, 80..BF, 80..BF"

Do i = X2D("E1") To X2D("EC")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If c \== utf8~encode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Encoding tests, ED..ED, 80..9F, 80..BF"

Do i = X2D("ED") To X2D("ED")
  Do j = X2D("80") To X2D("9F")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If c \ == utf8~encode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Encoding tests, EE..EF, 80..BF, 80..BF"

Do i = X2D("EE") To X2D("EF")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If c \== utf8~encode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Encoding tests, F0..F0, 90..BF, 80..BF, 80..BF"

Do i = X2D("F0") To X2D("F0")
  Do j = X2D("90") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("80") To X2D("BF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If c \== utf8~encode(c) Then Call Failed
        count += 1
      End
    End  
  End
End  

Call Tick "Encoding tests, F1..F3, 80..BF, 80..BF, 80..BF"

Do i = X2D("F1") To X2D("F3")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("80") To X2D("BF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If c \== utf8~encode(c) Then Call Failed
        count += 1
      End
    End  
  End
End 

Call Tick "Encoding tests, F0..F0, 90..8F, 80..BF, 80..BF"

Do i = X2D("F4") To X2D("F4")
  Do j = X2D("80") To X2D("8F")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("80") To X2D("BF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If c \== utf8~encode(c) Then Call Failed
        count += 1
      End
    End  
  End
End  

Call Tick "Encoding tests finished"
Call Tick ""
Call Tick "Decoding tests"
Call Tick "--------------"
Call Tick ""


Call Tick "Decoding tests, 00..7F (assert: PASS)"

Do i = 0 To 127
  c = X2C(D2X(i))
  If FAIL == utf8~decode(c) Then Call Failed
  count += 1
End

Call Tick "Decoding tests, 80..FF (assert: FAIL)"

Do i = X2D("80") To X2D("FF")
  c = X2C(D2X(i))
  If PASS == utf8~decode(c) Then Call Failed
  count += 1
End

Call Tick "Decoding tests, C2..DF, 00..7F (assert: FAIL)"

Do i = X2D("C2") To X2D("DF")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, C2..DF, 80..BF (assert: PASS)"

Do i = X2D("C2") To X2D("DF")
  Do j = X2D("80") To X2D("BF")
    c = X2C(D2X(i))X2C(D2X(j))
    If FAIL == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, C2..DF, 80..BF + extra continuation (assert: FAIL)"

Do i = X2D("C2") To X2D("DF")
  Do j = X2D("80") To X2D("BF")
    c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, C2..DF, C0..FF (assert: FAIL)"

Do i = X2D("C2") To X2D("DF")
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, E0..E0, 00..9F (assert: FAIL)"

Do i = X2D("E0") To X2D("E0")
  Do j = X2D("00") To X2D("9F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, E0..E0, A0..BF, 00..7F (assert: FAIL)"

Do i = X2D("E0") To X2D("E0")
  Do j = X2D("A0") To X2D("BF")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, E0..E0, A0..BF, 80..BF (assert: PASS)"

Do i = X2D("E0") To X2D("E0")
  Do j = X2D("A0") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If FAIL == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, E0..E0, A0..BF, C0..FF (assert: FAIL)"

Do i = X2D("E0") To X2D("E0")
  Do j = X2D("A0") To X2D("BF")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Do i = X2D("E0") To X2D("E0")
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, E1..EC, 00..7F (assert: FAIL)"

Do i = X2D("E1") To X2D("EC")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, E1..EC, 80..BF, 00..7F (assert: FAIL)"

Do i = X2D("E1") To X2D("EC")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, E1..EC, 80..BF, 80..BF (assert: PASS)"

Do i = X2D("E1") To X2D("EC")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If FAIL == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, E1..EC, 80..BF, C0..FF (assert: FAIL)"

Do i = X2D("E1") To X2D("EC")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, E1..EC, C0..FF (assert: FAIL)"

Do i = X2D("E1") To X2D("EC")
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, ED..ED, 00..7F (assert: FAIL)"

Do i = X2D("ED") To X2D("ED")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, ED..ED, 80..9F, 00..7F (assert: FAIL)"

Do i = X2D("ED") To X2D("ED")
  Do j = X2D("80") To X2D("9F")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, ED..ED, 80..9F, 80..BF (assert: PASS)"

Do i = X2D("ED") To X2D("ED")
  Do j = X2D("80") To X2D("9F")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If FAIL == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, ED..ED, 80..9F, C0..FF (assert: FAIL)"

Do i = X2D("ED") To X2D("ED")
  Do j = X2D("80") To X2D("9F")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, ED..ED, A0..FF (assert: FAIL)"

Do i = X2D("ED") To X2D("ED")
  Do j = X2D("A0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, EE..EE, 00..7F (assert: FAIL)"

Do i = X2D("EE") To X2D("EF")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, EE..EE, 80..BF, 00..7F (assert: FAIL)"

Do i = X2D("EE") To X2D("EF")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, EE..EE, 80..BF, 80..BF (assert: PASS)"

Do i = X2D("EE") To X2D("EF")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If FAIL == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, EE..EE, 80..BF, C0..FF (assert: FAIL)"

Do i = X2D("EE") To X2D("EF")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, EE..EE, C0..FF (assert: FAIL)"

Do i = X2D("EE") To X2D("EF")
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, F0..F0, 00..8F (assert: FAIL)"

Do i = X2D("F0") To X2D("F0")
  Do j = X2D("00") To X2D("8F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, F0..F0, 90..BF, 00..7F (assert: FAIL)"

Do i = X2D("F0") To X2D("F0")
  Do j = X2D("90") To X2D("BF")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, F0..F0, 90..BF, 80..BF, 00..7F (assert: FAIL)"

Do i = X2D("F0") To X2D("F0")
  Do j = X2D("90") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("00") To X2D("7F")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End    
    End
  End
End

Call Tick "Decoding tests, F0..F0, 90..BF, 80..BF, 80..BF (assert: PASS)"

Do i = X2D("F0") To X2D("F0")
  Do j = X2D("90") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("80") To X2D("BF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If FAIL == utf8~decode(c) Then Call Failed
        count += 1
      End    
    End
  End
End

Call Tick "Decoding tests, F0..F0, 90..BF, 80..BF, C0..FF (assert: FAIL)"

Do i = X2D("F0") To X2D("F0")
  Do j = X2D("90") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("C0") To X2D("FF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
    End  
  End
End  

Call Tick "Decoding tests, F0..F0, 90..BF, C0..FF (assert: FAIL)"

Do i = X2D("F0") To X2D("F0")
  Do j = X2D("90") To X2D("BF")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, F0..F0, C0..FF (assert: FAIL)"

Do i = X2D("F0") To X2D("F0")
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, F1..F3, 00..7F (assert: FAIL)"

Do i = X2D("F1") To X2D("F3")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, F1..F3, 80..BF, 00..7F (assert: FAIL)"

Do i = X2D("F1") To X2D("F3")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End  

Call Tick "Decoding tests, F1..F3, 80..BF, 80..BF, 00..7F (assert: FAIL)"

Do i = X2D("F1") To X2D("F3")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("00") To X2D("7F")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
    End
  End
End

Call Tick "Decoding tests, F1..F3, 80..BF, 80..BF, 80..BF (assert: PASS)"

Do i = X2D("F1") To X2D("F3")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("80") To X2D("BF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If FAIL == utf8~decode(c) Then Call Failed
        count += 1
      End
    End  
  End
End 

Call Tick "Decoding tests, F1..F3, 80..BF, 80..BF, C0..FF (assert: FAIL)"

Do i = X2D("F1") To X2D("F3")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("C0") To X2D("FF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
    End
  End
End

Call Tick "Decoding tests, F1..F3, 80..BF, C0..FF (assert: FAIL)"

Do i = X2D("F1") To X2D("F3")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End  

Call Tick "Decoding tests, F1..F3, C0..FF (assert: FAIL)"

Do i = X2D("F1") To X2D("F3")
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, F4..F4, 00..7F (assert: FAIL)"

Do i = X2D("F4") To X2D("F4")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "Decoding tests, F4..F4, 80..8F, 00..7F (assert: FAIL)"

Do i = X2D("F4") To X2D("F4")
  Do j = X2D("80") To X2D("8F")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, F4..F4, 80..8F, 80..BF, 00..7F (assert: FAIL)"

Do i = X2D("F4") To X2D("F4")
  Do j = X2D("80") To X2D("8F")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("00") To X2D("7F")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
    End
  End
End

Call Tick "Decoding tests, F4..F4, 80..8F, 80..BF, 80..BF (assert: PASS)"

Do i = X2D("F4") To X2D("F4")
  Do j = X2D("80") To X2D("8F")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("80") To X2D("BF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If FAIL == utf8~decode(c) Then Call Failed
        count += 1
      End
    End  
  End
End  

Call Tick "Decoding tests, F4..F4, 80..8F, 80..BF, C0..FF (assert: FAIL)"

Do i = X2D("F4") To X2D("F4")
  Do j = X2D("80") To X2D("8F")
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("C0") To X2D("FF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
    End
  End
End

Call Tick "Decoding tests, F4..F4, 80..8F, C0..FF (assert: FAIL)"

Do i = X2D("F4") To X2D("F4")
  Do j = X2D("80") To X2D("8F")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
End

Call Tick "Decoding tests, F4..F4, 90..FF (assert: FAIL)"

Do i = X2D("F4") To X2D("F4")
  Do j = X2D("90") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Call Tick "All" count "tests PASSED!"
Say ""

Exit 0

Tick:
  Parse Value Time("E") WIth l"."r
  If r == "" Then t = "0.000"  
  Else            t = l"."Left(r,3)
  Say Right(t,10) myName Arg(1)
Return  

Failed:
  Say "Failed:" C2X(c) c
  Exit 1
Return

::Requires "utf8.cls"
::Requires "Unicode.cls"