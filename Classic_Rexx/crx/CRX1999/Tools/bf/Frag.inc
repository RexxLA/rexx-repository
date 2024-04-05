
Frag1$$ db String,3,"12:",T_MINUTE-2,String1,"2",$pPositive,Zero
 db $pBifq,2*$BifRIGHT+128,$pAbut,_RetF

Frag2$$ db String1,":",$pAbut,T_MINUTE-2,String1,"2",$pPositive
 db Zero,$pBifq,2*$BifRIGHT+128,$pAbut,_RetF

Frag3$$ db $pBifq,2*$BifDIGITS,$pPower,One,$pSubtract,C_MAX-Tgt
 db String,3,"999",$pNumeric,00h,_RetF

Frag4$$ db String1,"W",$pBifq,2*$BifDATATYPE+128,$pNot,DAY-2
 db String1,"W",$pBifq,2*$BifDATATYPE+128,$pNot,$pOr,YEAR-2,_RetF

Frag5$$ db One,$pBifq,2*$BifLEFT,String1,"T",_Seq,+7,?STREAM
 db String2,"42",$pPositive,CONFIG_RAISE40,_RetF

Frag6$$ db $pBifq,2*$BifDATATYPE+128,$pNot,$pOr,_Then,+8,VALUE
 db INOPTION-2,String2,"19",$pPositive,CONFIG_RAISE40,_RetF

Frag7$$ db SIGN3,String1,"+",_Seq,+6,String1,"-",SIGN3-Tgt,_Jump
 db +4,String1,"+",SIGN3-Tgt,_RetF

Frag8$$ db ZZ-10,$pLength,One,_Gt,00h,ZZ-12,One,$pBifq,2*$BifLEFT
 db Zero,_Seq,00h,$pAnd,_RetF

Frag9$$ db Zero,$pBifq,2*$BifSPACE+128,XB_SUBJECT-Tgt,XB_SUBJECT
 db $pBifq,2*$BifTRANSLATE,String2,"16",String1,"2",RERADIX,_RetF

Frag10$$ db String1,"W",$pBifq,2*$BifDATATYPE+128,$pNot,_Then
 db +8,VALUE,INOPTION-2,String2,"19",$pPositive,CONFIG_RAISE40
 db _RetF

Frag11$$ db One,NEXT-Tgt,NEXT,$pBifq,2*$BifARG+128,MAX-Tgt,String1
 db "2",$pNumber,$pBifq,2*$BifARG,$pTo,One,$pBy,_RetF

Frag12$$ db D_SUBJECT-Tgt,D_SUBJECT,String2,"10",String1,"2"
 db RERADIX,D_R-Tgt,D_R,$pLength,D_LENGTH-Tgt,_RetF

Frag13$$ db Arg3-20,_Exists,_Then,+5,Arg3-20,P_START-Tgt,_Jump
 db +3,One,P_START-Tgt,P_NEEDLE,_RetF

Frag14$$ db Arg3-20,_Exists,_Then,+5,Arg3-20,C_COUNT-Tgt,_Jump
 db +3,One,C_COUNT-Tgt,C_COUNT,_RetF

Frag15$$ db _Seq,+14,OPERATOR,String1,"+",_Seq,+6,String1,"-"
 db OPERATOR-Tgt,_Jump,+4,String1,"+",OPERATOR-Tgt,_RetF

Frag16$$ db VALUE-2,_Sne,+8,VALUE,INOPTION-2,String2,"19",$pPositive
 db CONFIG_RAISE40,MICRO,D_OPTION-2,_RetF

Frag17$$ db MONTH-2,String1,"2",_Gt,00h,YEAR-4,LEAP,$pMultiply
 db $pAdd,DAY-2,$pAdd,One,$pSubtract,DAYS-Tgt,_RetF

Frag18$$ db String1,"2",$pPositive,Zero,$pBifq,2*$BifRIGHT+128
 db String1,"/",$pAbut,D_MONTH-2,String1,"2",$pPositive,Zero
 db $pBifq,2*$BifRIGHT+128,$pAbut,String1,"/",$pAbut,_RetF

Frag19$$ db Arg1-20,_Exists,_Then,+5,Arg1-20,?STREAM+Tgts,_Jump
 db +3,Null,?STREAM+Tgts,Null,?STREAMSTATE+Tgts,_RetF

Frag20$$ db Arg2-34,VALUE-Tgt,Arg3-34,_Exists,_Then,+5,Arg3-34
 db INOPTION-Tgt,_Jump,+4,String1,"N",INOPTION-Tgt,_RetF

Frag21$$ db ?RESPONSE,One,$pBifq,2*$BifLEFT,String1,"E",_Seq
 db +9,String,5,"ERROR",?STREAMSTATE+Tgts,String,8,"NOTREADY"
 db ?STREAM,?RESPONSE,String1,"2",$pPositive,$pBifq,2*$BifSUBSTR
 db CONFIG_RAISE,_RetF

Frag22$$ db Arg3-16,_Exists,_Then,+5,Arg3-16,PAD-Tgt,_Jump,+4
 db String1," ",PAD-Tgt,STRING,$pLength,C_LENGTH-2,$pSubtract
 db TRIM-Tgt,TRIM,Zero,_RetF

Frag23$$ db T_HOUR,String1,"2",$pPositive,Zero,$pBifq,2*$BifRIGHT+128
 db Frag2,String1,":",$pAbut,T_SECOND-2,String1,"2",$pPositive
 db Zero,$pBifq,2*$BifRIGHT+128,$pAbut,_RetF

Frag24$$ db Arg1-8,_Exists,_Then,+5,Arg1-8,?STREAM+Tgts,_Jump
 db +3,Null,?STREAM+Tgts,Arg2-8,_Exists,_Then,+5,Arg2-8,H_OPTION-Tgt
 db _Jump,+4,String1,"N",H_OPTION-Tgt,_RetF

Frag25$$ db YEAR,One,$pSubtract,String,3,"365",$pMultiply,YEAR-2
 db One,$pSubtract,String1,"4",$pIntDivide,$pAdd,YEAR-2,One,$pSubtract
 db String,3,"100",$pIntDivide,$pSubtract,YEAR-2,One,$pSubtract
 db String,3,"400",$pIntDivide,$pAdd,DAYS-2,$pAdd,BASEDAYS-Tgt
 db _RetF

Frag26$$ db Q_T-2,$pBifq,2*$BifLASTPOS,Q_J-Tgt,Q_J,Zero,_Eq,+7
 db Q_T,Q_NAME-Tgt,Null,Q_PATH-Tgt,_Jump,+13,Q_T,Q_J-2,One,$pAdd
 db $pBifq,2*$BifSUBSTR,Q_NAME-Tgt,Q_T,Q_J-2,$pBifq,2*$BifLEFT
 db Q_PATH-Tgt,_RetF

Frag27$$ db Arg4-22,_Exists,_Then,+5,Arg4-22,I_LENGTH-Tgt,_Jump
 db +4,NEW,$pLength,I_LENGTH-Tgt,Arg5-22,_Exists,_Then,+5,Arg5-22
 db I_PAD-Tgt,_Jump,+4,String1," ",I_PAD-Tgt,TARGET,I_NUM-2,_RetF

Frag28$$ db $pNumeric,00h,Arg3-34,_Exists,Arg2-34-2,_Exists,$pNot
 db $pAnd,_Then,+8,Null,Arg3-34-2,String2,"19",$pPositive,CONFIG_RAISE40
 db Arg1-34,_Exists,_Then,+5,Arg1-34,D_OPTION-Tgt,_Jump,+4,String1
 db "N",D_OPTION-Tgt,?CLAUSETIME,Null,_Seq,+6,CONFIG_TIME,DOS_TIME
 db ?CLAUSETIME+Tgts,?CLAUSETIME,?CLAUSELOCAL+Tgts,_RetF
