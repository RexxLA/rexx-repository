BIFC2D db 4*8+2,Arg1-14,$pLength,Zero,_Eq,+3,Zero,_RetB,String2
 db "10",Frag3,Arg2-14,_Exists,_Then,+66,Arg2-14,SIZE_-Tgt,SIZE_
 db Zero,_Eq,+3,Zero,_RetB,Arg1-14,SIZE_-2,$pBifq,2*$BifXRANGE
 db One,$pBifq,2*$BifLEFT,$pBifq,2*$BifRIGHT+128,C_T-Tgt,C_T
 db CONFIG_C2B,?OUTCOME,One,$pBifq,2*$BifLEFT,C_SIGN-Tgt,?OUTCOME
 db String1,"2",$pPositive,$pBifq,2*$BifSUBSTR,?OUTCOME+Tgts
 db ?OUTCOME,String1,"2",String2,"10",RERADIX,C_T-Tgt,C_SIGN
 db _Then,+9,C_T,String1,"2",?OUTCOME,$pLength,$pPower,$pSubtract
 db C_T-Tgt,C_T,$pBifq,2*$BifABS,C_MAX-2,_Gt,+7,C_T,String2,"35"
 db $pPositive,CONFIG_RAISE40,C_T,_RetB,Arg1-14,CONFIG_C2B,?OUTCOME
 db String1,"2",String2,"10",RERADIX,C_T-Tgt,C_T,C_MAX-2,_Gt
 db +7,C_T,String2,"35",$pPositive,CONFIG_RAISE40,C_T,_RetB
