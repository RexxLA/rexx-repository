/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

-- Tough tests. Will take a some few minutes

myName = "UTF-16"

utf16 = .Encoding[myName]
utf32 = .Encoding["utf-32"]

count  = 0 
failed = 0
FAIL   = 0
PASS   = 1

Call Time "R"

Call Tick "Encoder/decoder"
Call Tick "==============="
Call Tick ""
Call Tick "Running all tests for" myname"..."
Call Tick ""
Call Tick "Encoding tests"
Call Tick "--------------"
Call Tick ""

Call Tick "Encoding tests. U+0000..U+D7ff should all PASS (before surrogates)."

Do i = 0 To X2D("D7FF")
  c32 = X2C(Right(D2X(i),8,0)) -- UTF-32
  c8  = utf32~decode(c32,"UTF-8")
  Call TestEncode c32, c8, Right(c32,2)
End

Call Tick "Encoding tests. U+D800..U+DFff should all FAIL (surrogates)"

Do i = X2D("D800") To X2D("DFFF")
  c32 = X2C(Right(D2X(i),8,0)) -- UTF-32
  c8  = utf32~decode(c32,"UTF-8")
  Call TestEncode c32, c8, ""
End

Call Tick "Encoding tests. U+E000..U+FFFF should all PASS (16-bit, after surrogates)"

Do i = X2D("E000") To X2D("FFFF")
  c32 = X2C(Right(D2X(i),8,0)) -- UTF-32
  c8  = utf32~decode(c32,"UTF-8")
  Call TestEncode c32, c8, Right(c32,2)
End

Call Tick "Encoding tests. U+10000..U+10FFFF should all PASS (32-bit)"

Do i = X2D("10000") To X2D("10FFFF")
  code = Right(D2X(i),6,0)
  b    = X2B(code)
  u    = SubStr(b,4,5)
  x    = SubStr(b,9)
  w    = Right(X2B(D2X( X2D(B2X(u))-1 )), 4)
  c32  = X2C("00"code)
  c8   = utf32~decode(c32,"UTF-8")
  Call TestEncode c32, c8, X2C(B2X("110110"w||Left(x,6)"110111"Right(x,10)))
End

Call Tick ""
Call Tick "Decoding tests"
Call Tick "--------------"
Call Tick ""

Call Tick "Validation. Before surrogates."

Do i = X2D("0000") To X2D("D7FF")
  c = X2C(Right(D2X(i),4,0))
  Call TestDecode c,    PASS  -- Well-formed
  Call TestDecode c"*", FAIL  -- Ill-formed, 3 bytes
End

Call Tick "Validation. Out-of-sequence low surrogates."

-- Low surrogate alone, or followed by something else
Do i = X2D("DC00") To X2D("DFFF")
  c = X2C(Right(D2X(i),4,0))
  Call TestDecode c,    FAIL  -- Low surrogate alone
  Call TestDecode c"*", FAIL  -- Low surrogate alone + "*"
  Call TestDecode c"**",FAIL  -- Low surrogate alone + "**"
End

Call Tick "Validation. Lone high surrogates, or not followed by low surrogate."

-- High surrogate alone, or followed by something else (not a low surrogate)
Do i = X2D("D800") To X2D("DBFF")
  c = X2C(Right(D2X(i),4,0))
  Call TestDecode c,    FAIL  -- High surrogate alone  
  Call TestDecode c"*", FAIL  -- High surrogate alone + "*"
  Call TestDecode c"**",FAIL  -- High surrogate alone + "**" (i.e., not a low surrogate)
End

Call Tick "Validation. High surrogate followed by low surrogate."

-- High surrogate alone, followed by a low surrogate
Do i = X2D("D800") To X2D("DBFF")
  Do j = X2D("DC00") To X2D("DFFF")
    -- 110110wwwwxxxxxx 110111xxxxxxxxxx
    x = Right(X2B(D2X(i)), 6)Right(X2B(D2X(j)), 10)
    u = X2B(D2X(X2D(B2X(SubStr(X2B(D2X(i)), 7, 4))) + 1))
    c = X2C(Right(D2X(i),4,0))X2C(Right(D2X(j),4,0))
    Call TestDecode c,  PASS  -- High surrogate + low surrogate
  End
End

Call Tick "Validation. After surrogates."

-- After surrogates
Do i = X2D("E000") To X2D("FFFF")
  c = X2C(Right(D2X(i),4,0))
  Call TestDecode c,    PASS  -- Well-formed
  Call TestDecode c"*", FAIL  -- Ill-formed, 3 bytes
End

Call Tick ""

If failed == 0 Then Do
  Call Tick "All" count "tests PASSED!"
  Say ""
End  
Else Do
  Call Tick failed "of the" count "tests FAILED"
  Exit 1
End  

Exit 0

Tick:
  Parse Value Time("E") WIth l"."r
  If r == "" Then t = "0.000"  
  Else            t = l"."Left(r,3)
  Say Right(t,10) myName Arg(1)
Return  

TestEncode:
  count += 1
  If utf16~encode(Arg(2)) == Arg(3) Then Return
  Say "Encoding of '"C2X(Arg(1))"' failed."
  failed += 1
Return  

TestDecode:
  count += 1
  If utf16~decode(Arg(1)) == Arg(2) Then Return
  Say "Decoding of '"C2X(Arg(1))"' failed."
  failed += 1
Return  

::Requires "Unicode.cls"