/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

-- This test will take a few seconds. Only the BMP is tested, since the encoding is confined to this plane.

myName = "CP-850"

cp850 = .Encoding[myName]
utf16 = .Encoding["utf16"]

count  = 0 
failed = 0
FAIL   = 0
PASS   = 1

Call Init

Call Time "R"

Call Tick "Encoder/decoder"
Call Tick "==============="
Call Tick ""
Call Tick "Running all tests for" myname"..."
Call Tick ""
Call Tick "Decoding tests"
Call Tick "--------------"
Call Tick ""

-- Decoding tests

Call Tick "Decoding. Validation"

Do i = 0 To X2D("FF")
  c = X2C(D2X(i))
  Call TestDecode c
End

Call Tick "Decoding. Values 00..7F"

Do i = 0 To X2D("7F")
  c = X2C(D2X(i))
  Call TestDecode c, c
End

Call Tick "Decoding. Values 80..FF"

Do i = X2D("80") To X2D("FF")
  c = X2C(D2X(i))
  Call TestDecode c, utf16~decode(X2C(Decode.c),"UTF8")
End

Call Tick ""
Call Tick "Encoding tests"
Call Tick "--------------"
Call Tick ""

-- Encoding tests

Call Tick "Encoding tests, 00..7F"

Do i = 0 To X2D("7F")
  c = X2C(D2X(i))
  Call TestEncode c, c
End

Call Tick "Encoding tests, 80..7FF"

Do i = X2D("80") To X2D("7FF")
  c = Right(D2X(i),4,0)
  b = X2B(c)
  y = SubStr(b,6,5)
  x = Right(b,6)
  utf8 = X2C(B2X("110"y"10"||x))
  Call TestEncode utf8, Encode.c
End

Call Tick "Encoding tests, 800..FFFF"

Do i = X2D("800") To X2D("FFFF")
  c = Right(D2X(i),4,0)
  b = X2B(c)
  z = Left(b,4)
  y = SubStr(b,5,6)
  x = Right(b,6)
  utf8 = X2C(B2X("1110"z"10"y"10"||x))
  Call TestEncode utf8, Encode.c
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

TestEncode:
  count += 1
  If cp850~encode(Arg(1)) == Arg(2) Then Return
  Say "'"C2X(Arg(1))"' failed."
  failed += 1
Return

TestDecode:
  count += 1
  If Arg(2,"O") Then Do
    If cp850~decode(Arg(1)) Then Return
    Say "'"C2X(Arg(1))"' failed."
    failed += 1
  End
  Else Do
    If cp850~decode(Arg(1),"UTF-8") == Arg(2) Then Return
    Say "'"C2X(Arg(1))"' failed."
    failed += 1
  End
Return  

Tick:
  Parse Value Time("E") WIth l"."r
  If r == "" Then t = "0.000"  
  Else            t = l"."Left(r,3)
  Say Right(t,10) myName Arg(1)
Return  

Init:
  decode. = ""
  encode. = ""
  decode.['80'X ] = '00C7'; encode.['00C7'] = '80'X
  decode.['81'X ] = '00FC'; encode.['00FC'] = '81'X
  decode.['82'X ] = '00E9'; encode.['00E9'] = '82'X
  decode.['83'X ] = '00E2'; encode.['00E2'] = '83'X
  decode.['84'X ] = '00E4'; encode.['00E4'] = '84'X
  decode.['85'X ] = '00E0'; encode.['00E0'] = '85'X
  decode.['86'X ] = '00E5'; encode.['00E5'] = '86'X
  decode.['87'X ] = '00E7'; encode.['00E7'] = '87'X
  decode.['88'X ] = '00EA'; encode.['00EA'] = '88'X
  decode.['89'X ] = '00EB'; encode.['00EB'] = '89'X
  decode.['8A'X ] = '00E8'; encode.['00E8'] = '8A'X
  decode.['8B'X ] = '00EF'; encode.['00EF'] = '8B'X
  decode.['8C'X ] = '00EE'; encode.['00EE'] = '8C'X
  decode.['8D'X ] = '00EC'; encode.['00EC'] = '8D'X
  decode.['8E'X ] = '00C4'; encode.['00C4'] = '8E'X
  decode.['8F'X ] = '00C5'; encode.['00C5'] = '8F'X
  decode.['90'X ] = '00C9'; encode.['00C9'] = '90'X
  decode.['91'X ] = '00E6'; encode.['00E6'] = '91'X
  decode.['92'X ] = '00C6'; encode.['00C6'] = '92'X
  decode.['93'X ] = '00F4'; encode.['00F4'] = '93'X
  decode.['94'X ] = '00F6'; encode.['00F6'] = '94'X
  decode.['95'X ] = '00F2'; encode.['00F2'] = '95'X
  decode.['96'X ] = '00FB'; encode.['00FB'] = '96'X
  decode.['97'X ] = '00F9'; encode.['00F9'] = '97'X
  decode.['98'X ] = '00FF'; encode.['00FF'] = '98'X
  decode.['99'X ] = '00D6'; encode.['00D6'] = '99'X
  decode.['9A'X ] = '00DC'; encode.['00DC'] = '9A'X
  decode.['9B'X ] = '00F8'; encode.['00F8'] = '9B'X
  decode.['9C'X ] = '00A3'; encode.['00A3'] = '9C'X
  decode.['9D'X ] = '00D8'; encode.['00D8'] = '9D'X
  decode.['9E'X ] = '00D7'; encode.['00D7'] = '9E'X
  decode.['9F'X ] = '0192'; encode.['0192'] = '9F'X
  decode.['A0'X ] = '00E1'; encode.['00E1'] = 'A0'X
  decode.['A1'X ] = '00ED'; encode.['00ED'] = 'A1'X
  decode.['A2'X ] = '00F3'; encode.['00F3'] = 'A2'X
  decode.['A3'X ] = '00FA'; encode.['00FA'] = 'A3'X
  decode.['A4'X ] = '00F1'; encode.['00F1'] = 'A4'X
  decode.['A5'X ] = '00D1'; encode.['00D1'] = 'A5'X
  decode.['A6'X ] = '00AA'; encode.['00AA'] = 'A6'X
  decode.['A7'X ] = '00BA'; encode.['00BA'] = 'A7'X
  decode.['A8'X ] = '00BF'; encode.['00BF'] = 'A8'X
  decode.['A9'X ] = '00AE'; encode.['00AE'] = 'A9'X
  decode.['AA'X ] = '00AC'; encode.['00AC'] = 'AA'X
  decode.['AB'X ] = '00BD'; encode.['00BD'] = 'AB'X
  decode.['AC'X ] = '00BC'; encode.['00BC'] = 'AC'X
  decode.['AD'X ] = '00A1'; encode.['00A1'] = 'AD'X
  decode.['AE'X ] = '00AB'; encode.['00AB'] = 'AE'X
  decode.['AF'X ] = '00BB'; encode.['00BB'] = 'AF'X
  decode.['B0'X ] = '2591'; encode.['2591'] = 'B0'X
  decode.['B1'X ] = '2592'; encode.['2592'] = 'B1'X
  decode.['B2'X ] = '2593'; encode.['2593'] = 'B2'X
  decode.['B3'X ] = '2502'; encode.['2502'] = 'B3'X
  decode.['B4'X ] = '2524'; encode.['2524'] = 'B4'X
  decode.['B5'X ] = '00C1'; encode.['00C1'] = 'B5'X
  decode.['B6'X ] = '00C2'; encode.['00C2'] = 'B6'X
  decode.['B7'X ] = '00C0'; encode.['00C0'] = 'B7'X
  decode.['B8'X ] = '00A9'; encode.['00A9'] = 'B8'X
  decode.['B9'X ] = '2563'; encode.['2563'] = 'B9'X
  decode.['BA'X ] = '2551'; encode.['2551'] = 'BA'X
  decode.['BB'X ] = '2557'; encode.['2557'] = 'BB'X
  decode.['BC'X ] = '255D'; encode.['255D'] = 'BC'X
  decode.['BD'X ] = '00A2'; encode.['00A2'] = 'BD'X
  decode.['BE'X ] = '00A5'; encode.['00A5'] = 'BE'X
  decode.['BF'X ] = '2510'; encode.['2510'] = 'BF'X
  decode.['C0'X ] = '2514'; encode.['2514'] = 'C0'X
  decode.['C1'X ] = '2534'; encode.['2534'] = 'C1'X
  decode.['C2'X ] = '252C'; encode.['252C'] = 'C2'X
  decode.['C3'X ] = '251C'; encode.['251C'] = 'C3'X
  decode.['C4'X ] = '2500'; encode.['2500'] = 'C4'X
  decode.['C5'X ] = '253C'; encode.['253C'] = 'C5'X
  decode.['C6'X ] = '00E3'; encode.['00E3'] = 'C6'X
  decode.['C7'X ] = '00C3'; encode.['00C3'] = 'C7'X
  decode.['C8'X ] = '255A'; encode.['255A'] = 'C8'X
  decode.['C9'X ] = '2554'; encode.['2554'] = 'C9'X
  decode.['CA'X ] = '2569'; encode.['2569'] = 'CA'X
  decode.['CB'X ] = '2566'; encode.['2566'] = 'CB'X
  decode.['CC'X ] = '2560'; encode.['2560'] = 'CC'X
  decode.['CD'X ] = '2550'; encode.['2550'] = 'CD'X
  decode.['CE'X ] = '256C'; encode.['256C'] = 'CE'X
  decode.['CF'X ] = '00A4'; encode.['00A4'] = 'CF'X
  decode.['D0'X ] = '00F0'; encode.['00F0'] = 'D0'X
  decode.['D1'X ] = '00D0'; encode.['00D0'] = 'D1'X
  decode.['D2'X ] = '00CA'; encode.['00CA'] = 'D2'X
  decode.['D3'X ] = '00CB'; encode.['00CB'] = 'D3'X
  decode.['D4'X ] = '00C8'; encode.['00C8'] = 'D4'X
  decode.['D5'X ] = '0131'; encode.['0131'] = 'D5'X
  decode.['D6'X ] = '00CD'; encode.['00CD'] = 'D6'X
  decode.['D7'X ] = '00CE'; encode.['00CE'] = 'D7'X
  decode.['D8'X ] = '00CF'; encode.['00CF'] = 'D8'X
  decode.['D9'X ] = '2518'; encode.['2518'] = 'D9'X
  decode.['DA'X ] = '250C'; encode.['250C'] = 'DA'X
  decode.['DB'X ] = '2588'; encode.['2588'] = 'DB'X
  decode.['DC'X ] = '2584'; encode.['2584'] = 'DC'X
  decode.['DD'X ] = '00A6'; encode.['00A6'] = 'DD'X
  decode.['DE'X ] = '00CC'; encode.['00CC'] = 'DE'X
  decode.['DF'X ] = '2580'; encode.['2580'] = 'DF'X
  decode.['E0'X ] = '00D3'; encode.['00D3'] = 'E0'X
  decode.['E1'X ] = '00DF'; encode.['00DF'] = 'E1'X
  decode.['E2'X ] = '00D4'; encode.['00D4'] = 'E2'X
  decode.['E3'X ] = '00D2'; encode.['00D2'] = 'E3'X
  decode.['E4'X ] = '00F5'; encode.['00F5'] = 'E4'X
  decode.['E5'X ] = '00D5'; encode.['00D5'] = 'E5'X
  decode.['E6'X ] = '00B5'; encode.['00B5'] = 'E6'X
  decode.['E7'X ] = '00FE'; encode.['00FE'] = 'E7'X
  decode.['E8'X ] = '00DE'; encode.['00DE'] = 'E8'X
  decode.['E9'X ] = '00DA'; encode.['00DA'] = 'E9'X
  decode.['EA'X ] = '00DB'; encode.['00DB'] = 'EA'X
  decode.['EB'X ] = '00D9'; encode.['00D9'] = 'EB'X
  decode.['EC'X ] = '00FD'; encode.['00FD'] = 'EC'X
  decode.['ED'X ] = '00DD'; encode.['00DD'] = 'ED'X
  decode.['EE'X ] = '00AF'; encode.['00AF'] = 'EE'X
  decode.['EF'X ] = '00B4'; encode.['00B4'] = 'EF'X
  decode.['F0'X ] = '00AD'; encode.['00AD'] = 'F0'X
  decode.['F1'X ] = '00B1'; encode.['00B1'] = 'F1'X
  decode.['F2'X ] = '2017'; encode.['2017'] = 'F2'X
  decode.['F3'X ] = '00BE'; encode.['00BE'] = 'F3'X
  decode.['F4'X ] = '00B6'; encode.['00B6'] = 'F4'X
  decode.['F5'X ] = '00A7'; encode.['00A7'] = 'F5'X
  decode.['F6'X ] = '00F7'; encode.['00F7'] = 'F6'X
  decode.['F7'X ] = '00B8'; encode.['00B8'] = 'F7'X
  decode.['F8'X ] = '00B0'; encode.['00B0'] = 'F8'X
  decode.['F9'X ] = '00A8'; encode.['00A8'] = 'F9'X
  decode.['FA'X ] = '00B7'; encode.['00B7'] = 'FA'X
  decode.['FB'X ] = '00B9'; encode.['00B9'] = 'FB'X
  decode.['FC'X ] = '00B3'; encode.['00B3'] = 'FC'X
  decode.['FD'X ] = '00B2'; encode.['00B2'] = 'FD'X
  decode.['FE'X ] = '25A0'; encode.['25A0'] = 'FE'X
  decode.['FF'X ] = '00A0'; encode.['00A0'] = 'FF'X
Return  

::Requires "Unicode.cls"