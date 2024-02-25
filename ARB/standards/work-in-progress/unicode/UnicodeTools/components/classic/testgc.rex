/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

/* 
  Classic Rexx general_category (extended) test program. 
  
  Tested with Regina.
  
  This is a proof-of-concept program, with no error checking.
*/

token = gc(init)

count = 0

categories = "Lu Ll Lt Lm Lo Lo_CJK_Compatibility_Ideograph Lo_CJK_Unified_Ideograph Lo_Hangul_Syllabe Lo_Khitan_Small_Script Lo_Nushu_Character Lo_Tangut_Component Lo_Tangut_Ideograph Mn Mc Me Nd Nl No Pc Pd Ps Pe Pi Pf Po Sm Sc Sk So Zs Zl Zp Cc Cf Cs Co Cn"

Do Forever
  Call CharOut ,"Type a character and press the ENTER key, or just ENTER to leave: "
  c  = LineIn()
If c == "" Then Leave
  c32 = UTF8to32(c)
  cx = c2x(c32)
  gc = gc("Query",cx,token)
  Say "The 'general_category' property for '"c"' ('"C2X(c32)"'X, utf8: '"C2X(c)"'X) is" Word(categories,X2D(C2X(gc)))"."
End
Say "Bye!"
Exit

/* Quick and dirty, no error checking */
UTF8to32:
  Select
    When Length(Arg(1)) == 1 Then Return Arg(1)
    When Length(Arg(1)) == 2 Then Return X2C(B2X(Right(X2B(C2X(SubStr(Arg(1),1,1))),5)Right(X2B(C2X(SubStr(Arg(1),2,1))),6)))
    When Length(Arg(1)) == 3 Then Return X2C(B2X(Right(X2B(C2X(SubStr(Arg(1),1,1))),4)Right(X2B(C2X(SubStr(Arg(1),2,1))),6)Right(X2B(C2X(SubStr(Arg(1),3,1))),6)))
    When Length(Arg(1)) == 4 Then Return X2C(B2X(Right(X2B(C2X(SubStr(Arg(1),1,1))),3)Right(X2B(C2X(SubStr(Arg(1),2,1))),6)Right(X2B(C2X(SubStr(Arg(1),3,1))),6)Right(X2B(C2X(SubStr(Arg(1),4,1))),6)))
  End
  