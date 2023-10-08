/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

--------------------------------------------------------------------------------
-- This program is part of the automated test suite. See tests/test.all.rex   --
--------------------------------------------------------------------------------

-- This is the testfile for the UTF8 routine

--
-- Please refer to docs/new-functions.md for documentation and additional details.
--
-- Version 0.4b, 20230925
--
-- Notice:
--
-- Although this routine is part of TUTOR, The Unicode Tools Of Rexx,
-- it can also be used separately, as it has no dependencies on the rest
-- of components of TUTOR.
--

--
-- See https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf
-- Section. 3.9 Unicode Encoding Forms, p. 119

-- "U+FFFD Substitution of Maximal Subparts". p.127

Call Time "R"
count = 0

Say Time() "Testing the UTF-8 decoding and boundary conditions..."
Say

-- We first test the samples in p. 128 of the standard

Say Time() "Testing 'U+FFFD Substitution of Maximal Subparts'..."

-- Table 3.8, p. 128
Call Test 'UTF8("C0 AF E0 80 BF F0 81 82 41"X, utf8, utf32, REPLACE)', "0000FFFD0000FFFD0000FFFD0000FFFD0000FFFD0000FFFD0000FFFD0000FFFD00000041"X

-- Table 3.9, p. 128
Call Test 'UTF8("ED A0 80 ED BF BF ED AF 41"X, utf8, utf32, REPLACE)', "0000FFFD0000FFFD0000FFFD0000FFFD0000FFFD0000FFFD0000FFFD0000FFFD00000041"X

-- Table 3.10, p. 128
Call Test 'UTF8("F4 91 92 93 FF 41 80 BF 42"X, utf8, utf32, REPLACE)', "0000FFFD0000FFFD0000FFFD0000FFFD0000FFFD000000410000FFFD0000FFFD00000042"X

-- Table 3.11, p. 128
Call Test 'UTF8("E1 80 E2 F0 91 92 F1 BF 41"X, utf8, utf32, REPLACE)', "0000FFFD0000FFFD0000FFFD0000FFFD00000041"X


Say Time() "Testing UTF-8 boundary conditions..."

-- Cfr. Tables 3.6 & 3.7, p. 125

ReplChar = "0000 FFFD"X

Replace1 = ReplChar
Replace2 = ReplChar || ReplChar
Replace3 = ReplChar || ReplChar || ReplChar


-- 1-byte sequences

Do i = X2D("00") To X2D("7F")
  h = Right(D2X(i),2,0)
  c = X2C(h)
  Call Test 'UTF8("'h'"X,       utf8 ,utf32, REPLACE)', 4(c)                             
End
Do c Over (XRange("80"X,"FF"X))~makeArray("")
  h = C2X(c)
  Call Test 'UTF8("'h'"X,       utf8 ,utf32, REPLACE)', Replace1                          
End

-- Instead of testing all the combinations, we test only the extremes. 
-- For example, to check that "8000", "8001",...,"807F" all return
-- a replacement character + one ascii character, we test only
-- "8000" and "807F". 

-- 2-byte sequences

Do c Over (XRange("80"X,"FF"X))~makeArray("")
  h = C2X(c)
  b1 = Right(X2B(h),5)
  Do d Over "007F"X~makeArray("") 
    Call Test 'UTF8("'h C2X(d)'"X,   utf8 ,utf32, REPLACE)', Replace1 || 4(d)                 
  End
  If c <= "C1"X | c >= "F5"X Then Do
    Do d Over "80FF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace2                         
    End
    Iterate
  End
  If c <= "DF"X Then Do -- C2..DF
    Do d Over "80BF"X~makeArray("") 
      g = C2X(d)
      b2 = Right(X2B(g),6)
      Call Test 'UTF8("'h g'"X, utf8 ,utf32, REPLACE)', 4(X2C(B2X(b1||b2)))              
    End
    Do d Over "C0FF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace2                         
    End
    Iterate
  End
  If c == "E0"X  Then Do
    Do d Over "809F"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace2                         
    End
    Do d Over "A0BF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace1                         
    End
    Do d Over "C0FF"X~makeArray("")
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace2                         
    End
    Iterate
  End
  If c == "ED"X  Then Do
    Do d Over "809F"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace1                         
    End
    Do d Over "A0FF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace2                         
    End
    Iterate
  End
  If c <= "EF"X  Then Do -- E1..EC, EE..EF
    Do d Over "80BF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace1                         
    End
    Do d Over "C0FF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace2                         
    End
    Iterate
  End
  If c == "F0"X  Then Do
    Do d Over "808F"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace2                         
    End
    Do d Over "90BF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace1                         
    End
    Do d Over "C0FF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace2                         
    End
    Iterate
  End
  If c <= "F3"X  Then Do -- F1..F3
    Do d Over "80BF"X~makeArray("")
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace1                         
    End
    Do d Over "C0FF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace2                         
    End
    Iterate
  End
  If c == "F4"X  Then Do
    Do d Over "808F"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace1                         
    End
    Do d Over "90FF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d)'"X, utf8 ,utf32, REPLACE)', Replace2                         
    End
    Iterate
  End
End

-- 3-Byte sequences

c = "E0"X
h = C2X(c)
b1 = Right(X2B(h),5)
Do d Over XRange("A0"X,"BF"X)~makeArray("")
  g = C2X(d)
  b2 = Right(X2B(g),6)
  Do e Over "007F"X~makeArray("") 
    Call Test 'UTF8("'h C2X(d) C2X(e)'"X, utf8 ,utf32, REPLACE)', replace1 || 4(e)
  End
  Do e Over "80BF"X~makeArray("") 
    f = C2X(e)
    b3 = Right(X2B(f),6)
    Call Test 'UTF8("'h C2X(d) C2X(e)'"X, utf8 ,utf32, REPLACE)', 4(X2C(B2X(b1||b2||b3)))              
  End
  Do e Over "C0FF"X~makeArray("") 
    Call Test 'UTF8("'h C2X(d) C2X(e)'"X, utf8 ,utf32, REPLACE)', replace2
  End
End

Do c Over (XRange("E1"X,"EC"X)XRange("EE"X,"EF"X))~makeArray("")
  h = C2X(c)
  b1 = Right(X2B(h),5)
  Do d Over XRange("80"X,"BF"X)~makeArray("")
    g = C2X(d)
    b2 = Right(X2B(g),6)
    Do e Over "007F"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d) C2X(e)'"X, utf8 ,utf32, REPLACE)', replace1 || 4(e)
    End
    Do e Over "80BF"X~makeArray("") 
      f = C2X(e)
      b3 = Right(X2B(f),6)
      Call Test 'UTF8("'h C2X(d) C2X(e)'"X, utf8 ,utf32, REPLACE)', 4(X2C(B2X(b1||b2||b3)))              
    End
    Do e Over "C0FF"X~makeArray("") 
      Call Test 'UTF8("'h C2X(d) C2X(e)'"X, utf8 ,utf32, REPLACE)', replace2
    End
  End
End

c = "ED"X
h = C2X(c)
b1 = Right(X2B(h),5)
Do d Over XRange("80"X,"9F"X)~makeArray("")
  g = C2X(d)
  b2 = Right(X2B(g),6)
  Do e Over "007F"X~makeArray("") 
    Call Test 'UTF8("'h C2X(d) C2X(e)'"X, utf8 ,utf32, REPLACE)', replace1 || 4(e)
  End  
  Do e Over "80BF"X~makeArray("") 
    f = C2X(e)
    b3 = Right(X2B(f),6)
    Call Test 'UTF8("'h C2X(d) C2X(e)'"X, utf8 ,utf32, REPLACE)', 4(X2C(B2X(b1||b2||b3)))              
  End
  Do e Over "C0FF"X~makeArray("") 
    Call Test 'UTF8("'h C2X(d) C2X(e)'"X, utf8 ,utf32, REPLACE)', replace2
  End
End

-- Four byte sequences

c = "F0"X
cx = C2X(c)
b1 = Right(X2B(cx),4)
Do d Over XRange("90"X,"BF"X)~makeArray("")
  dx = C2X(d)
  b2 = Right(X2B(dx),6)
  Do e Over XRange("80"X,"BF"X)~makeArray("")
    ex = C2X(e)
    b3 = Right(X2B(ex),6)
    Do f Over "007F"X~makeArray("") 
      fx = C2X(f)
      Call Test 'UTF8("'cx dx ex fx'"X, utf8 ,utf32, REPLACE)', replace1 || 4(f)
    End
    Do f Over "80BF"X~makeArray("") 
      fx = C2X(f)
      b4 = Right(X2B(fx),6)
      Call Test 'UTF8("'cx dx ex fx'"X, utf8 ,utf32, REPLACE)', 4(X2C(B2X(b1||b2||b3||b4)))              
    End
    Do f Over "C0FF"X~makeArray("") 
      fx = C2X(f)
      Call Test 'UTF8("'cx dx ex fx'"X, utf8 ,utf32, REPLACE)', replace2
    End
  End
End

Do c Over XRange("F1"X,"F3"X)~makeArray("")
  cx = C2X(c)
  b1 = Right(X2B(cx),4)
  Do d Over XRange("80"X,"BF"X)~makeArray("")
    dx = C2X(d)
    b2 = Right(X2B(dx),6)
    Do e Over XRange("80"X,"BF"X)~makeArray("")
      ex = C2X(e)
      b3 = Right(X2B(ex),6)
      Do f Over "007F"X~makeArray("") 
        fx = C2X(f)
        Call Test 'UTF8("'cx dx ex fx'"X, utf8 ,utf32, REPLACE)', replace1 || 4(f)
      End
      Do f Over "80BF"X~makeArray("") 
        fx = C2X(f)
        b4 = Right(X2B(fx),6)
        Call Test 'UTF8("'cx dx ex fx'"X, utf8 ,utf32, REPLACE)', 4(X2C(B2X(b1||b2||b3||b4)))              
      End
      Do f Over "C0FF"X~makeArray("") 
        fx = C2X(f)
        Call Test 'UTF8("'cx dx ex fx'"X, utf8 ,utf32, REPLACE)', replace2
      End
    End
  End
End


c = "F4"X
cx = C2X(c)
b1 = Right(X2B(cx),4)
Do d Over XRange("80"X,"8F"X)~makeArray("")
  dx = C2X(d)
  b2 = Right(X2B(dx),6)
  Do e Over XRange("80"X,"BF"X)~makeArray("")
    ex = C2X(e)
    b3 = Right(X2B(ex),6)
    Do f Over "007F"X~makeArray("") 
      fx = C2X(f)
      Call Test 'UTF8("'cx dx ex fx'"X, utf8 ,utf32, REPLACE)', replace1 || 4(f)
    End
    Do f Over "80BF"X~makeArray("") 
      fx = C2X(f)
      b4 = Right(X2B(fx),6)
      Call Test 'UTF8("'cx dx ex fx'"X, utf8 ,utf32, REPLACE)', 4(X2C(B2X(b1||b2||b3||b4)))              
    End
    Do f Over "C0FF"X~makeArray("") 
      fx = C2X(f)
      Call Test 'UTF8("'cx dx ex fx'"X, utf8 ,utf32, REPLACE)', replace2
    End    
  End
End

Say 
Say Time() "All UTF-8 tests PASSED!"

--------------------------------------------------------------------------------

-- UTF-8Z is identical to UTF-8, save for the encoding of "00"U, which is
-- "C080"X instead of "00"X. 

Say 
Say Time() "Testing the UTF-8Z decoding"

Call Test 'UTF8("00"X, utf8z ,utf32, REPLACE)', replace1
Call Test 'UTF8("C001"X, utf8z ,utf32, REPLACE)', replace1 || 4("01"X)
Call Test 'UTF8("C080"X, utf8z ,utf32, REPLACE)', 4()
Call Test 'UTF8("C081"X, utf8z ,utf32, REPLACE)', replace2

Say 
Say Time() "All UTF-8Z tests PASSED!"

--------------------------------------------------------------------------------

Say 
Say Time() "Testing the WTF-8 decoding"

c = "ED"X
cx = C2X(c)
b1 = Right(X2B(cx),4)
Do d Over XRange("00"X,"7F"X)~makeArray("")
  dx = C2X(d)
  Call Test 'UTF8("'cx dx'"X, wtf8 ,wtf32, REPLACE)', replace1 || 4(d)
End
Do d Over XRange("80"X,"9F"X)~makeArray("")
  dx = C2X(d)
  b2 = Right(X2B(dx),6)
  Do e Over "80BF"X~makeArray("") 
    ex = C2X(e)
    b3 = Right(X2B(ex),6)
    Call Test 'UTF8("'cx dx ex'"X, wtf8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3)))              
  End
End
-- Lead surrogates are ok in wtf-32
Do d Over XRange("A0"X,"AF"X)~makeArray("")
  dx = C2X(d)
  b2 = Right(X2B(dx),6)
  Do e Over "80BF"X~makeArray("") 
    ex = C2X(e)
    b3 = Right(X2B(ex),6)
    Call Test 'UTF8("'cx dx ex'"X, wtf8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3)))              
  End
End
-- Trail surrogates are ok in wtf-32
Do d Over XRange("B0"X,"BF"X)~makeArray("")
  dx = C2X(d)
  b2 = Right(X2B(dx),6)
  Do e Over "80BF"X~makeArray("") 
    ex = C2X(e)
    b3 = Right(X2B(ex),6)
    Call Test 'UTF8("'cx dx ex'"X, wtf8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3)))              
  End
End
-- Surrogate pairs are always ill-formed
f = "ED"x
fx = C2X(f)
Do d Over XRange("A0"X,"AF"X)~makeArray("")
  dx = C2X(d)
  Do e Over "80BF"X~makeArray("") 
    ex = C2X(e)
    Do g Over XRange("B0"X,"BF"X)~makeArray("")
      gh = C2X(g)
      Do h Over "80BF"X~makeArray("") 
        hx = C2X(h)
        Call Test 'UTF8("'cx dx ex fx gh hx'"X, wtf8 ,wtf32, REPLACE)', replace2
      End
    End
  End
End

Do d Over XRange("C0"X,"FF"X)~makeArray("")
  dx = C2X(d)
  Call Test 'UTF8("'cx dx'"X, wtf8 ,wtf32, REPLACE)', replace2
End

Say 
Say Time() "All WTF-8 tests PASSED!"

--------------------------------------------------------------------------------

Say 
Say Time() "Testing the CESU-8 decoding"

c = "ED"X
cx = C2X(c)
f = "ED"X
fx = C2X(f)
b1 = Right(X2B(cx),4)
b4 = b1
Do d Over XRange("80"X,"9F"X)~makeArray("")
  dx = C2X(d)
  b2 = Right(X2B(dx),6)
  Do e Over XRange("80"X,"BF"X)~makeArray("")
    ex = C2X(e)
    b3 = Right(X2B(ex),6)
    Call Test 'UTF8("'cx dx ex'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3)))              
  End
End
Do d Over "A0AF"X~makeArray("") 
  dx = C2X(d)
  b2 = Right(X2B(dx),6)
  Call Test 'UTF8("'cx dx'"X, cesu8 ,wtf32, REPLACE)', replace1
  Do e Over "80BF"X~makeArray("") 
    ex = C2X(e)
    b3 = Right(X2B(ex),6)
    Call Test 'UTF8("'cx dx ex'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3)))              
    Call Test 'UTF8("'cx dx ex fx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace1
    Do g Over "007F"X~makeArray("") 
      gx = C2X(g)
      Call Test 'UTF8("'cx dx ex fx gx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace1 || 4(g)
    End
    Do g Over "809F"X~makeArray("") 
      gx = C2X(g)
      b5 = Right(X2B(gx),6)
      Call Test 'UTF8("'cx dx ex fx gx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace1
      Do h Over "007F"X~makeArray("") 
        hx = C2X(h)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace1 || 4(h)
      End
      Do h Over "80BF"X~makeArray("") 
        hx = C2X(h)
        b6 = Right(X2B(hx),6)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || 4(X2C(B2X(b4||b5||b6)))
      End
      Do h Over "C0FF"X~makeArray("") 
        hx = C2X(h)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace2
      End
    End
    Do g Over "A0AF"X~makeArray("") 
      gx = C2X(g)
      b5 = Right(X2B(gx),6)
      Call Test 'UTF8("'cx dx ex fx gx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace1
      Do h Over "007F"X~makeArray("") 
        hx = C2X(h)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace1 || 4(h)
      End
      Do h Over "80BF"X~makeArray("") 
        hx = C2X(h)
        b6 = Right(X2B(hx),6)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || 4(X2C(B2X(b4||b5||b6)))
      End
      Do h Over "C0FF"X~makeArray("") 
        hx = C2X(h)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace2
      End
    End
    Do g Over "B0BF"X~makeArray("") 
      gx = C2X(g)
      Call Test 'UTF8("'cx dx ex fx gx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace1
      Do h Over "007F"X~makeArray("") 
        hx = C2X(h)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace1 || 4(h)
      End
      Do h Over "80BF"X~makeArray("") 
        hx = C2X(h)
        a = Right(X2B(dx), 4)
        b = Right(X2B(ex), 6)
        c = Right(X2B(gx), 4)
        d = Right(X2B(hx), 6)
        a = X2B(D2X( X2D(B2X(a)) + 1 ))
        scalar = Right(X2C(B2X(a || b || c || d)),4,"00"X)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', scalar
      End
      Do h Over "C0FF"X~makeArray("") 
        hx = C2X(h)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace2
      End
    End
    Do g Over "C0FF"X~makeArray("") 
      gx = C2X(g)
      Call Test 'UTF8("'cx dx ex fx gx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace2
      Do h Over "007F"X~makeArray("") 
        hx = C2X(h)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace2 || 4(h)
      End
      Do h Over "80BF"X~makeArray("") 
        hx = C2X(h)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace3
      End
      Do h Over "C0FF"X~makeArray("") 
        hx = C2X(h)
        Call Test 'UTF8("'cx dx ex fx gx hx'"X, cesu8 ,wtf32, REPLACE)', 4(X2C(B2X(b1||b2||b3))) || replace3
      End
    End
  End
End
Do d Over XRange("B0"X,"BF"X)~makeArray("")  -- Lone trail surrogate
  dx = C2X(d)
  Call Test 'UTF8("'cx dx'"X, cesu8 ,wtf32, REPLACE)', replace1
End
Do d Over XRange("C0"X,"CF"X)~makeArray("")
  dx = C2X(d)
  Call Test 'UTF8("'cx dx'"X, cesu8 ,wtf32, REPLACE)', replace2
End

Say 
Say Time() "All CESU-8 tests PASSED!"

--------------------------------------------------------------------------------

-- MUTF-8 is identical to CESU-8, save for the encoding of "00"U, which is
-- "C080"X instead of "00"X.

Say 
Say Time() "Testing the MUTF-8 decoding"

Call Test 'UTF8("00"X,   mutf8, wtf32, REPLACE)', replace1
Call Test 'UTF8("C001"X, mutf8, wtf32, REPLACE)', replace1 || 4("01"X)
Call Test 'UTF8("C080"X, mutf8, wtf32, REPLACE)', 4()
Call Test 'UTF8("C081"X, mutf8, wtf32, REPLACE)', replace2

-- "10000"U -> "D800"X + "DC00"X --> "ED A0 80"X + "ED B0 80"X
Call Test 'UTF8("ED A0 80 ED B0 80"X, mutf8, wtf32, REPLACE)', 4("10000"X)
Call Test 'UTF8("ED A0 80 ED B0 80"X, mutf8, wtf8,  REPLACE)', "F0 90 80 80"X

-- "(Bell)"U = "1F514"U --> "D83D"X + "DD14"X --> "ED A0 BD"X + "ED B4 94"X
Call Test 'UTF8("ED A0 BD ED B4 94"X, mutf8, wtf32, REPLACE)', 4("1F514"X)
Call Test 'UTF8("ED A0 BD ED B4 94"X, mutf8, wtf8,  REPLACE)', "F0 9F 94 94"X

Say 
Say Time() "All MUTF-8 tests PASSED!"

--------------------------------------------------------------------------------

Say 
Say Time() "Testing parameter combinations"

-- It is an error to specify errorHandling when target has not been specified

Call Test 'UTF8("00"X, ,,  REPLACE)', SYNTAX
Call Test 'UTF8("00"X, ,,  NULL)',    SYNTAX
Call Test 'UTF8("00"X, ,,  SYNTAX)',  SYNTAX
Call Test 'UTF8("00"X, ,,  "")',      1       -- Except when it is the null string


-- Check the "format" ad "target" parameters parameter

Call Test 'UTF8("00"X,    utf8,     utf8)',   "00"X
Call Test 'UTF8("00"X,   "utf-8",   utf8)',   "00"X
Call Test 'UTF8("C080"X,  utf8z,    utf8)',   "00"X
Call Test 'UTF8("C080"X, "utf-8z",  utf8)',   "00"X
Call Test 'UTF8("00"X,    Potato,   utf8)',   SYNTAX

Call Test 'UTF8("00"X,    utf8,    "utf-8")', "00"X
Call Test 'UTF8("00"X,   "utf-8",  "utf-8")', "00"X
Call Test 'UTF8("C080"X,  utf8z,   "utf-8")', "00"X
Call Test 'UTF8("C080"X, "utf-8z", "utf-8")', "00"X
Call Test 'UTF8("00"X,    Potato,  "utf-8")', SYNTAX

Call Test 'UTF8("00"X,    utf8,     wtf8)',   "00"X
Call Test 'UTF8("00"X,   "utf-8",   wtf8)',   "00"X
Call Test 'UTF8("00"X,    wtf8,     wtf8)',   "00"X
Call Test 'UTF8("00"X,   "wtf-8",   wtf8)',   "00"X
Call Test 'UTF8("C080"X,  utf8z,    wtf8)',   "00"X
Call Test 'UTF8("C080"X, "utf-8z",  wtf8)',   "00"X
Call Test 'UTF8("C080"X,  mutf8,    wtf8)',   "00"X
Call Test 'UTF8("C080"X, "mutf-8",  wtf8)',   "00"X
Call Test 'UTF8("00"X,    cesu8,    wtf8)',   "00"X
Call Test 'UTF8("00"X,   "cesu-8",  wtf8)',   "00"X
Call Test 'UTF8("00"X,    Potato,   wtf8)',   SYNTAX

Call Test 'UTF8("00"X,    utf8,    "wtf-8")', "00"X
Call Test 'UTF8("00"X,   "utf-8",  "wtf-8")', "00"X
Call Test 'UTF8("00"X,    wtf8,    "wtf-8")', "00"X
Call Test 'UTF8("00"X,   "wtf-8",  "wtf-8")', "00"X
Call Test 'UTF8("C080"X,  utf8z,   "wtf-8")', "00"X
Call Test 'UTF8("C080"X, "utf-8z", "wtf-8")', "00"X
Call Test 'UTF8("C080"X,  mutf8,   "wtf-8")', "00"X
Call Test 'UTF8("C080"X, "mutf-8", "wtf-8")', "00"X
Call Test 'UTF8("00"X,    cesu8,   "wtf-8")', "00"X
Call Test 'UTF8("00"X,   "cesu-8", "wtf-8")', "00"X
Call Test 'UTF8("00"X,    Potato,  "wtf-8")', SYNTAX

Call Test 'UTF8("00"X,    utf8,     utf32)',   "0000 0000"X
Call Test 'UTF8("00"X,   "utf-8",   utf32)',   "0000 0000"X
Call Test 'UTF8("C080"X,  utf8z,    utf32)',   "0000 0000"X
Call Test 'UTF8("C080"X, "utf-8z",  utf32)',   "0000 0000"X
Call Test 'UTF8("00"X,    Potato,   utf32)',   SYNTAX

Call Test 'UTF8("00"X,    utf8,    "utf-32")', "0000 0000"X
Call Test 'UTF8("00"X,   "utf-8",  "utf-32")', "0000 0000"X
Call Test 'UTF8("C080"X,  utf8z,   "utf-32")', "0000 0000"X
Call Test 'UTF8("C080"X, "utf-8z", "utf-32")', "0000 0000"X
Call Test 'UTF8("00"X,    Potato,  "utf-32")', SYNTAX

Call Test 'UTF8("00"X,    utf8,     wtf32)',   "0000 0000"X
Call Test 'UTF8("00"X,   "utf-8",   wtf32)',   "0000 0000"X
Call Test 'UTF8("00"X,    wtf8,     wtf32)',   "0000 0000"X
Call Test 'UTF8("00"X,   "wtf-8",   wtf32)',   "0000 0000"X
Call Test 'UTF8("C080"X,  utf8z,    wtf32)',   "0000 0000"X
Call Test 'UTF8("C080"X, "utf-8z",  wtf32)',   "0000 0000"X
Call Test 'UTF8("C080"X,  mutf8,    wtf32)',   "0000 0000"X
Call Test 'UTF8("C080"X, "mutf-8",  wtf32)',   "0000 0000"X
Call Test 'UTF8("00"X,    cesu8,    wtf32)',   "0000 0000"X
Call Test 'UTF8("00"X,   "cesu-8",  wtf32)',   "0000 0000"X
Call Test 'UTF8("00"X,    Potato,   wtf32)',   SYNTAX

Call Test 'UTF8("00"X,    utf8,    "wtf-32")', "0000 0000"X
Call Test 'UTF8("00"X,   "utf-8",  "wtf-32")', "0000 0000"X
Call Test 'UTF8("00"X,    wtf8,    "wtf-32")', "0000 0000"X
Call Test 'UTF8("00"X,   "wtf-8",  "wtf-32")', "0000 0000"X
Call Test 'UTF8("C080"X,  utf8z,   "wtf-32")', "0000 0000"X
Call Test 'UTF8("C080"X, "utf-8z", "wtf-32")', "0000 0000"X
Call Test 'UTF8("C080"X,  mutf8,   "wtf-32")', "0000 0000"X
Call Test 'UTF8("C080"X, "mutf-8", "wtf-32")', "0000 0000"X
Call Test 'UTF8("00"X,    cesu8,   "wtf-32")', "0000 0000"X
Call Test 'UTF8("00"X,   "cesu-8", "wtf-32")', "0000 0000"X
Call Test 'UTF8("00"X,    Potato,  "wtf-32")', SYNTAX

Call TestStem 'UTF8("00"X,    utf8,    "utf8 utf32")', ( ("UTF8", "00"X), ("UTF32", "0000 0000"X) )
Call TestStem 'UTF8("00"X,    utf8,    "wtf8 wtf32")', ( ("WTF8", "00"X), ("WTF32", "0000 0000"X) )
Call TestStem 'UTF8("00"X,    utf8,    "utf8 wtf32")', SYNTAX
Call TestStem 'UTF8("00"X,    utf8,    "wtf8 utf32")', SYNTAX

-- Check validation mode

Call Test 'UTF8("00"X)',           1
Call Test 'UTF8("C27F"X)',         0
Call Test 'UTF8("C280"X)',         1
Call Test 'UTF8("FF"X)',           0
Call Test 'UTF8("00"X,UTF8Z)',     0
Call Test 'UTF8("C080"X,UTF8Z)',   1

-- Check "errorHandling"

Call Test 'UTF8("00"X,,utf8,"")',     "00"X
Call Test 'UTF8("C0"X,,utf8,"")',     ""
Call Test 'UTF8("00"X,,utf8,"NULL")', "00"X
Call Test 'UTF8("C0"X,,utf8,"NULL")', ""
Call Test 'UTF8("00"X,,utf8,"REPLACE")', "00"X
Call Test 'UTF8("C0"X,,utf8,"REPLACE")', "efbfbd"X

Call Test 'UTF8("00"X,,utf8,"SYNTAX")', "00"X
Call Test 'UTF8("C0"X,,utf8,"SYNTAX")', SYNTAX

Say 
Say Time() "All tests PASSED!"

--------------------------------------------------------------------------------

Say 
Say Time() "Testing helpfile examples"

Call Test 'UTF8("")'                                          , 1 --  (The null string always validates)
Call Test 'UTF8("ascii")'                                     , 1 --  (Equivalent to UTF8("ascii", "UTF-8") )
Call Test 'UTF8("José")'                                      , 1 --  ()
Call Test 'UTF8("FF"X)'                                       , 0 --  ("FF"X is ill-formed)
Call Test 'UTF8("00"X)'                                       , 1 --  (ASCII)
Call Test 'UTF8("00"X, "UTF-8Z")'                             , 0 --  (UTF-8Z encodes "00"U differently)
Call Test 'UTF8("C080"X,)'                                    , 0 --  ("C0"X is ill-formed in UTF-8)
Call Test 'UTF8("C080"X, "UTF-8Z")'                           , 1 --  (Ill-formed in UTF-8)
Call Test 'UTF8("C081"X, "UTF-8Z")'                           , 0 --  (Only "C080" is well-formed)
Call Test 'UTF8("ED A0 80"X)'                                 , 0 --  (High surrogate)
Call Test 'UTF8("ED A0 80"X,"WTF-8")'                         , 1 --  (UTF-8 allows surrogates)
Call Test 'UTF8("ED A0 80"X,"WTF-8")'                         , 1 --  (UTF-8 allows surrogates)
Call Test 'UTF8("F0 9F 94 94"X)'                              , 1 --  ( "(Bell)"U )
Call Test 'UTF8("F0 9F 94 94"X,"CESU-8")'                     , 0 --  ( CESU-8 doesn't allow four-byte sequences... )
Call Test 'UTF8("ED A0 BD ED B4 94"X,"CESU-8")'               , 1 --  ( ...it expects two three-byte surrogates instead)

Call Test 'UTF8("00"X, utf8,  utf8)', "00"X                       -- Validate and return UTF-8
Call Test 'UTF8("00"X, utf8,  wtf8)', "00"X                       -- Validate and return WTF-8
Call Test 'UTF8("00"X, mutf8, utf8)', SYNTAX                      -- MUTF-8 allows lone surrogates, but UTF-8 does not
Call Test 'UTF8("00"X, mutf8, wtf8)', ""                          -- "00"X is ill-formed MUTF-8
Call TestStem 'UTF8("00"X, utf8,  utf8 utf32)', ( ("UTF8","00"X), ("UTF32","0000 0000"X) ) -- A stem s.: s.utf8 == "00"X, and s.utf32 == "0000 0000"X
Call TestStem 'UTF8("00"X, utf8,  wtf8 wtf32)', ( ("WTF8","00"X), ("WTF32","0000 0000"X) ) -- A stem s.: s.wtf8 == "00"X, and s.wtf32 == "0000 0000"X
Call TestStem 'UTF8("00"X, utf8,  utf8 wtf32)', SYNTAX            -- Cannot specify UTF-8 and WTF-32 at the same time

Call Test 'UTF8("C080"X,,utf8)', ""                               -- (By default, UTF8 returns the null string when an error is found)
Call Test 'UTF8("C080"X,,utf8, replace)', "EFBFBD EFBFBD"X        -- ("EFBFBD" is the Unicode Replacement character)
Call Test 'UTF8("C080"X,,utf8, syntax)', SYNTAX                   -- Syntax error


Say 
Say Time() "All tests PASSED!"

--------------------------------------------------------------------------------

Say 
Say Time() "Testing empty strings"

Call Test 'UTF8("",utf8,utf8)', ""
Call Test 'UTF8("",utf8,wtf8)', ""
Call Test 'UTF8("",utf8,utf32)', ""
Call Test 'UTF8("",utf8,wtf32)', ""
Call TestStem 'UTF8("",utf8,utf8 utf32)', ( ("UTF8",""), ("UTF32",""))
Call TestStem 'UTF8("",utf8,wtf8 wtf32)', ( ("WTF8",""), ("WTF32",""))
Say 
Say Time() "All tests PASSED!"

--------------------------------------------------------------------------------



secs = time("E")
Say 
Say Time() "Total:" count" tests," secs "seconds," count/secs "tests/sec."

Exit 0


--------------------------------------------------------------------------------

TestStem:
  saveSigl = sigl
  count += 1
  Signal On Syntax
  Interpret "s.=" Arg(1)
  If Arg(2) == "SYNTAX" Then Do
    Say 
    Say "Expected SYNTAX condition not raised"
    Say "when evaluating" Arg(1)"."
    Say 
    Say "Test FAILED!"
    Exit 1
  End
  Do res Over Arg(2)
    If s.[res[1]] \== res[2] Then Do
      Say "When evaluating '"Arg(1)"' at index '"res[1]"',"
      Say "  got      '"s.[res[1]]"',"
      Say "  expected '"res[2]"'."
      Say "Test FAILED!"
      Exit 1
    End
  End
Return

Test:
  saveSigl = sigl
  count += 1
  Signal On Syntax
  Interpret "temp=" Arg(1)
  If Arg(2) == "SYNTAX" Then Do
    Say 
    Say "Expected SYNTAX condition not raised"
    Say "when evaluating" Arg(1)"."
    Say 
    Say "Test FAILED!"
    Exit 1
  End
  If temp \== Arg(2) Then Do
    Say 
    Say "  "saveSigl":" Arg(1)" = '"C2X(temp)"'X,"
    Say "  expected: '"C2X(Arg(2))"'X."
    Say "FAILED!"
    Exit 1
  End
Return  

Syntax:
  If Arg(2) == "SYNTAX" Then Return 1
  Say 
  Say "Unexpected SYNTAX condition" rc"."Condition("E") "at line" saveSigl": '"Condition("O")[Message]"'"
  Say "when evaluating" Arg(1)"."
  Say 
  Say "Test FAILED!"
Exit 1

--------------------------------------------------------------------------------

4: Return Right(Arg(1),4,"00"X)

--------------------------------------------------------------------------------

::Requires "utf8.cls"