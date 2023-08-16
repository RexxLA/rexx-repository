
utf8 = .Encoding[utf8]

Call Time "R"

count  = 0
failed = 0
PASS   = 1
FAIL   = 0

Say "Testing the encoding functionality of the UTF-8 encoder/decoder..."

Do i = 0 To 127
  c = X2C(D2X(i))
  If c \== utf8~encode(c) Then Call Failed
  count += 1
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("C2") To X2D("DF")
  Do j = X2D("80") To X2D("BF")
    ix = D2X(i)
    jx = D2X(j)
    c = X2C(ix)X2C(jx)
    If c \== utf8~encode(c) Then Call Failed
    count += 1
  End
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("E0") To X2D("E0")
  Do j = X2D("A0") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If c \== utf8~encode(c) Then Call Failed
      count += 1
    End  
  End
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("E1") To X2D("EC")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If c \== utf8~encode(c) Then Call Failed
      count += 1
    End  
  End
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("ED") To X2D("ED")
  Do j = X2D("80") To X2D("9F")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If c \ == utf8~encode(c) Then Call Failed
      count += 1
    End  
  End
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("EE") To X2D("EF")
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If c \== utf8~encode(c) Then Call Failed
      count += 1
    End  
  End
End

Say count "tests in" Time("E") "seconds."

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

Say count "tests in" Time("E") "seconds."

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

Say count "tests in" Time("E") "seconds."

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

Say count "tests in" Time("E") "seconds."

Say "Testing the decoding functionality of the UTF-8 encoder/decoder..."

Do i = 0 To 127
  c = X2C(D2X(i))
  If FAIL == utf8~decode(c) Then Call Failed
  count += 1
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("80") To X2D("FF")
  c = X2C(D2X(i))
  If PASS == utf8~decode(c) Then Call Failed
  count += 1
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("C2") To X2D("DF")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("80") To X2D("BF")
    c = X2C(D2X(i))X2C(D2X(j))
    If FAIL == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("80") To X2D("BF")
    c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("E0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("E0") To X2D("E0")
  Do j = X2D("00") To X2D("9F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("A0") To X2D("BF")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("A0") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If FAIL == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("A0") To X2D("BF")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("E1") To X2D("EC")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If FAIL == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("ED") To X2D("ED")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("80") To X2D("9F")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("80") To X2D("9F")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If FAIL == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("80") To X2D("9F")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("A0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("EE") To X2D("EF")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("80") To X2D("BF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If FAIL == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
  End
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
End

Say count "tests in" Time("E") "seconds."

Do i = X2D("F0") To X2D("F0")
  Do j = X2D("00") To X2D("8F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("90") To X2D("BF")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("00") To X2D("7F")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
      Do l = X2D("C0") To X2D("FF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
      Do l = X2D("80") To X2D("BF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If FAIL == utf8~decode(c) Then Call Failed
        count += 1
      End
    End  
  End
End  

Say count "tests in" Time("E") "seconds."

Do i = X2D("F1") To X2D("F3")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("C0") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("80") To X2D("BF")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("00") To X2D("7F")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
      Do l = X2D("C0") To X2D("FF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
      Do l = X2D("80") To X2D("BF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If FAIL == utf8~decode(c) Then Call Failed
        count += 1
      End
    End  
  End
End 

Say count "tests in" Time("E") "seconds."

Do i = X2D("F4") To X2D("F4")
  Do j = X2D("00") To X2D("7F")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("90") To X2D("FF")
    c = X2C(D2X(i))X2C(D2X(j))
    If PASS == utf8~decode(c) Then Call Failed
    count += 1
  End
  Do j = X2D("80") To X2D("8F")
    Do k = X2D("00") To X2D("7F")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
    Do k = X2D("C0") To X2D("FF")
      c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))
      If PASS == utf8~decode(c) Then Call Failed
      count += 1
    End  
    Do k = X2D("80") To X2D("BF")
      Do l = X2D("00") To X2D("7F")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
      Do l = X2D("C0") To X2D("FF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If PASS == utf8~decode(c) Then Call Failed
        count += 1
      End
      Do l = X2D("80") To X2D("BF")
        c = X2C(D2X(i))X2C(D2X(j))X2C(D2X(k))X2C(D2X(l))
        If FAIL == utf8~decode(c) Then Call Failed
        count += 1
      End
    End  
  End
End  

Select case failed
  When 0 Then testsFailed = "no tests failed"
  When 1 Then testsFailed = "1 test failed"
  Otherwise   testsFailed = failed "tests failed"
End

Say count "Tests completed ("testsFailed") in" Time("E") "seconds. That's" (count/Time("E")) "tests/sec."

Exit failed \== 0

Failed:
  failed += 1 
  Say "Failed:" C2X(c) c
Return

::Requires Unicode.cls