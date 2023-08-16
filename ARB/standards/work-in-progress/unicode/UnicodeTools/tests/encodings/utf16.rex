/*****************************************************************************/
/*                                                                           */
/*  The UNICODE Tools for ooRexx                                             */
/*  ============================                                             */
/*                                                                           */
/*  Copyright (c) 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>     */
/*                                                                           */
/*  See https://github.com/RexxLA, rexx-repository,                          */
/*      path ARB/standards/work-in-progress/unicode/UnicodeTools             */
/*                                                                           */
/*  License: Apache License 2.0 https://www.apache.org/licenses/LICENSE-2.0  */
/*                                                                           */
/*                                                                           */
/*  The UTF-16 encoder/decoder test                                          */
/*  ===============================                                          */
/*                                                                           */
/*  Can take some time to complete                                           */     
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Ver.  Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.2b JMB 20230728 Initial release                                       */
/*                                                                           */
/*****************************************************************************/


utf16 = .Encoding["utf-16"]
utf32 = .Encoding["utf-32"]

count  = 0 
failed = 0
FAIL   = 0
PASS   = 1

Call Time "R"

-- Encoding tests
Say Time("E") "UTF16 encoding tests."


Say Time("E") "UTF-16 Encoding tests. U+0000..U+D7ff should all PASS (before surrogates)."

Do i = 0 To X2D("D7FF")
  c32 = X2C(Right(D2X(i),8,0)) -- UTF-32
  c8  = utf32~decode(c32,"UTF-8")
  Call TestEncode c32, c8, Right(c32,2)
End

Say Time("E") "UTF-16 Encoding tests. U+D800..U+DFff should all FAIL (surrogates)"
Do i = X2D("D800") To X2D("DFFF")
  c32 = X2C(Right(D2X(i),8,0)) -- UTF-32
  c8  = utf32~decode(c32,"UTF-8")
  Call TestEncode c32, c8, ""
End

Say Time("E") "UTF-16 Encoding tests. U+E000..U+FFFF should all PASS (16-bit, after surrogates)"
Do i = X2D("E000") To X2D("FFFF")
  c32 = X2C(Right(D2X(i),8,0)) -- UTF-32
  c8  = utf32~decode(c32,"UTF-8")
  Call TestEncode c32, c8, Right(c32,2)
End

Say Time("E") "UTF-16 Encoding tests. U+10000..U+10FFFF should all PASS (32-bit)"

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

-- Decoding tests

Say Time("E") "UTF16 decoding tests."

-- Before surrogates
Say Time("E") "UTF16 validation. Before surrogates."
Do i = X2D("0000") To X2D("D7FF")
  c = X2C(Right(D2X(i),4,0))
  Call TestDecode c,    PASS  -- Well-formed
  Call TestDecode c"*", FAIL  -- Ill-formed, 3 bytes
End

Say Time("E") "UTF16 validation. Out-of-sequence low surrogates."
-- Low surrogate alone, or followed by something else
Do i = X2D("DC00") To X2D("DFFF")
  c = X2C(Right(D2X(i),4,0))
  Call TestDecode c,    FAIL  -- Low surrogate alone
  Call TestDecode c"*", FAIL  -- Low surrogate alone + "*"
  Call TestDecode c"**",FAIL  -- Low surrogate alone + "**"
End

Say Time("E") "UTF16 validation. Lone high surrogates, or not followed by low surrogate."
-- High surrogate alone, or followed by something else (not a low surrogate)
Do i = X2D("D800") To X2D("DBFF")
  c = X2C(Right(D2X(i),4,0))
  Call TestDecode c,    FAIL  -- High surrogate alone  
  Call TestDecode c"*", FAIL  -- High surrogate alone + "*"
  Call TestDecode c"**",FAIL  -- High surrogate alone + "**" (i.e., not a low surrogate)
End


Say Time("E") "UTF16 validation. High surrogate followed by low surrogate."
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

Say Time("E") "UTF16 validation. After surrogates."

-- After surrogates
Do i = X2D("E000") To X2D("FFFF")
  c = X2C(Right(D2X(i),4,0))
  Call TestDecode c,    PASS  -- Well-formed
  Call TestDecode c"*", FAIL  -- Ill-formed, 3 bytes
End

If failed == 0 Then Say "All" count "tests PASSED, t=" Time("E")
Else Do
  Say failed "of the" count "tests FAILED, t=" Time("E")
  Exit 1
End  

Exit 0

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