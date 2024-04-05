BIFTRANSLATE db 8*8+4,Arg2-26,_Exists,$pNot,Arg3-26-2,_Exists
 db $pNot,$pAnd,_Then,+4,T_STRING,CONFIG_UPPER,_RetB,Arg3-26
 db _Exists,$pNot,_Then,+6,$pBifq,2*$BifXRANGE,TABLEI-Tgt,_Jump
 db +3,Arg3-26,TABLEI-Tgt,Arg2-26,_Exists,_Then,+5,Arg2-26,TABLEO-Tgt
 db _Jump,+3,Null,TABLEO-Tgt,Arg4-26,_Exists,_Then,+5,Arg4-26
 db T_PAD-Tgt,_Jump,+4,String1," ",T_PAD-Tgt,TABLEO,TABLEI-2
 db $pLength,T_PAD-4,$pBifq,2*$BifLEFT+128,TABLEO-Tgt,Null,T_OUTPUT-Tgt
 db One,$pNumber,T_STRING-10,$pLength,$pTo,$pControlVar,T_J-10
 dw $+32
db T_STRING-10,T_J-12,One,$pBifq,2*$BifSUBSTR+128,T_C-Tgt-10
 db T_C-10,TABLEI-12,$pBifq,2*$BifPOS,KK-Tgt-10,KK-10,Zero,_Eq
 db +7,T_OUTPUT-10,T_C-12,$pAbut,T_OUTPUT-Tgt-10,_Jump,+9,T_OUTPUT-10
 db TABLEO-12,KK-14,One,$pBifq,2*$BifSUBSTR+128,$pAbut,T_OUTPUT-Tgt-10
 db _IterCV,T_OUTPUT,_RetB
