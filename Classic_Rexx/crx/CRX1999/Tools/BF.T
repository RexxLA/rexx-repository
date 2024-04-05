;õ bf\Frag.inc

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
;õ bf\ARITHOP.inc
ARITHOP$$ db 25*8+4,NUMBER1,DIGITS-2,PREPARE,TT-Tgt,TT,$pParse
 db 00h,022h,SIGN1-2,MANTISSA1-2,EXPONENT1-2,01ah,NUMBER2,DIGITS-2
 db PREPARE,TT-Tgt,TT,$pParse,00h,022h,SIGN2-2,MANTISSA2-2,EXPONENT2-2
 db 01ah,OPERATOR,String1,"*",_Seq,+4,_MULTIPLY,_Jump,+36,OPERATOR
 db String1,"/",_Seq,+4,_DIVTYPE,_Jump,+28,OPERATOR,String2,"**"
 db _Seq,+4,_POWER,_Jump,+19,OPERATOR,String1,"%",_Seq,+4,_DIVTYPE
 db _Jump,+11,OPERATOR,String2,"//",_Seq,+4,_DIVTYPE,_Jump,+2
 db _ADDSUBCOMP,_POSTOP,NUMBER3,_RetB

PREPARE$$ db 9*8+2,NUMBER,Zero,$pBifq,2*$BifSPACE+128,$pParse
 db 02h,0ah,String1,"E",02ah,MANTISSA-2,022h,EXPONENT-2,01ah
 db EXPONENT,Null,_Seq,+3,Zero,EXPONENT-Tgt,String1,"+",SIGN-Tgt
 db MANTISSA,One,$pBifq,2*$BifLEFT,String1,"-",_Seq,+4,String1
 db "-",SIGN-Tgt,MANTISSA,One,$pBifq,2*$BifLEFT,String2,"+-"
 db $pBifq,2*$BifVERIFY,Zero,_Eq,+8,MANTISSA,String1,"2",$pPositive
 db $pBifq,2*$BifSUBSTR,MANTISSA-Tgt,String1,".",MANTISSA-2,$pBifq
 db 2*$BifPOS,P_P-Tgt,P_P,Zero,_Gt,+9,MANTISSA,P_P-2,One,$pBifq
 db 2*$BifDELSTR+128,MANTISSA-Tgt,_Jump,+6,One,MANTISSA-2,$pLength
 db $pAdd,P_P-Tgt,One,$pNumber,MANTISSA-10,$pLength,One,$pSubtract
 db $pTo,$pControlVar,P_Q-10
 dw $+16
db MANTISSA-10,P_Q-12,One,$pBifq,2*$BifSUBSTR+128,Zero,_Sne,+2
 db $pLeave,P_P-10,One,$pSubtract,P_P-Tgt-10,_IterCV,MANTISSA
 db P_Q-2,$pBifq,2*$BifSUBSTR,MANTISSA-Tgt,EXPONENT,MANTISSA-2
 db $pLength,P_P-4,$pSubtract,One,$pAdd,$pSubtract,EXPONENT-Tgt
 db P_DIGITS,One,$pAdd,$pNumber,MANTISSA-10,$pLength,$pTo,$pControlVar
 db JJ-10
 dw $+41
db MANTISSA-10,JJ-12,One,$pBifq,2*$BifSUBSTR+128,Zero,_Sne,+31
 db EXPONENT-10,MANTISSA-12,$pLength,$pAdd,P_DIGITS-12,$pSubtract
 db EXPONENT-Tgt-10,MANTISSA-10,P_DIGITS-12,One,$pAdd,One,$pBifq
 db 2*$BifSUBSTR+128,P_T-Tgt-10,MANTISSA-10,P_DIGITS-12,$pBifq
 db 2*$BifLEFT,MANTISSA-Tgt-10,P_T-10,String1,"5",_Ge,+5,MANTISSA-10
 db One,$pAdd,MANTISSA-Tgt-10,$pLeave,_IterCV,MANTISSA,$pLength
 db P_DIGITS-2,_Gt,+13,EXPONENT,MANTISSA-2,$pLength,$pAdd,P_DIGITS-2
 db $pSubtract,EXPONENT-Tgt,MANTISSA,P_DIGITS-2,$pBifq,2*$BifLEFT
 db MANTISSA-Tgt,MANTISSA,Zero,_Seq,+3,Zero,EXPONENT-Tgt,SIGN
 db MANTISSA-2,$pCat,EXPONENT-2,$pCat,_RetB

_POSTOP$$ db 0*8+0,MANTISSA3,$pLength,DIGITS-2,$pSubtract,TT-Tgt
 db TT,Zero,_Gt,+37,MANTISSA3,DIGITS-2,One,$pAdd,One,$pBifq,2*$BifSUBSTR+128
 db String1,"4",_Gt,+17,MANTISSA3,DIGITS-2,$pBifq,2*$BifLEFT
 db One,$pAdd,MANTISSA3-Tgt,MANTISSA3,$pLength,DIGITS-2,_Gt,+5
 db EXPONENT3,One,$pAdd,EXPONENT3-Tgt,MANTISSA3,DIGITS-2,$pBifq
 db 2*$BifLEFT,MANTISSA3-Tgt,EXPONENT3,TT-2,$pAdd,EXPONENT3-Tgt
 db MANTISSA3,Zero,$pBifq,2*$BifVERIFY,Zero,_Eq,+4,Zero,NUMBER3-Tgt
 db _RetBc,OPERATOR,String1,"/",_Seq,00h,OPERATOR-2,String2,"**"
 db _Seq,00h,$pOr,_Then,+34,MANTISSA3,$pLength,$pNumber,One,$pNegate
 db $pBy,String1,"2",$pTo,$pControlVar,ZZ-10
 dw $+16
db MANTISSA3-10,ZZ-12,One,$pBifq,2*$BifSUBSTR+128,Zero,_Sne,+2
 db $pLeave,EXPONENT3-10,One,$pAdd,EXPONENT3-Tgt-10,_IterCV,MANTISSA3
 db One,ZZ-4,$pBifq,2*$BifSUBSTR+128,MANTISSA3-Tgt,_FLOATING
 db String1,"E",_Seq,+154,EXPONENT3,MANTISSA3-2,$pLength,One
 db $pSubtract,$pAdd,EXPONENT3-Tgt,One,A_X-Tgt,$pBifq,2*$BifFORM
 db String1,"E",_Seq,+39,EXPONENT3,String1,"3",String2,"//",EXPONENT3-6
 db $pLength,ARITHOP,A_X-Tgt,A_X,Zero,_Lt,+6,A_X,String1,"3"
 db $pAdd,A_X-Tgt,EXPONENT3,A_X-2,$pSubtract,EXPONENT3-Tgt,A_X
 db One,$pAdd,A_X-Tgt,MANTISSA3,$pLength,A_X-2,_Lt,+7,MANTISSA3
 db A_X-2,Zero,$pBifq,2*$BifLEFT+128,MANTISSA3-Tgt,EXPONENT3
 db String,9,"999999999",_Gt,+19,String,6,"SYNTAX",String,4,"42.1"
 db NUMBER1-4,OPERATOR-6,NUMBER2-8,CONFIG_RAISE,String,9,"999999999"
 db $pNegate,EXPONENT3-2,_Gt,+19,String,6,"SYNTAX",String,4,"42.2"
 db NUMBER1-4,OPERATOR-6,NUMBER2-8,CONFIG_RAISE,MANTISSA3,$pLength
 db A_X-2,_Ne,+8,String1,".",MANTISSA3-2,A_X-4,$pBifq,2*$BifINSERT+128
 db MANTISSA3-Tgt,EXPONENT3,Zero,_Ge,+11,MANTISSA3,String2,"E+"
 db $pAbut,EXPONENT3-2,$pAbut,NUMBER3-Tgt,_Jump,+8,MANTISSA3
 db String1,"E",$pAbut,EXPONENT3-2,$pAbut,NUMBER3-Tgt,_Jump,+54
 db MANTISSA3,$pLength,EXPONENT3-2,$pAdd,A_Y-Tgt,A_Y,One,_Lt
 db +12,Zero,One,A_Y-4,$pSubtract,$pBifq,2*$BifCOPIES,MANTISSA3-2
 db $pAbut,MANTISSA3-Tgt,One,A_Y-Tgt,A_Y,MANTISSA3-2,$pLength
 db _Gt,+11,MANTISSA3,Zero,A_Y-4,MANTISSA3-6,$pLength,$pSubtract
 db $pBifq,2*$BifCOPIES,$pAbut,MANTISSA3-Tgt,MANTISSA3,NUMBER3-Tgt
 db A_Y,NUMBER3-2,$pLength,_Lt,+10,String1,".",MANTISSA3-2,A_Y-4
 db $pBifq,2*$BifINSERT+128,NUMBER3-Tgt,_Jump,+3,MANTISSA3,NUMBER3-Tgt
 db SIGN3,String1,"-",_Seq,+6,String1,"-",NUMBER3-2,$pAbut,NUMBER3-Tgt
 db _RetBc

_FLOATING$$ db 0*8+0,Null,TT-Tgt,EXPONENT3,MANTISSA3-2,$pLength
 db $pAdd,DIGITS-2,_Gt,+4,String1,"E",TT-Tgt,MANTISSA3,$pLength
 db EXPONENT3-2,$pAdd,String1,"5",$pNegate,_Lt,+4,String1,"E"
 db TT-Tgt,TT,_RetB

_ADDSUBCOMP$$ db 0*8+0,DIGITS,NOWDIGITS-Tgt,OPERATOR,String1
 db "+",_Sne,00h,OPERATOR-2,String1,"-",_Sne,00h,$pAnd,_Then
 db +4,String1,"-",OPERATOR-Tgt,MANTISSA2,Zero,_Seq,+8,SIGN1
 db SIGN3-Tgt,MANTISSA1,MANTISSA3-Tgt,EXPONENT1,EXPONENT3-Tgt
 db _RetBc,MANTISSA1,Zero,_Seq,+14,SIGN2,SIGN3-Tgt,MANTISSA2
 db MANTISSA3-Tgt,EXPONENT2,EXPONENT3-Tgt,OPERATOR,String1,"+"
 db _Sne,+2,Frag7,_RetBc,EXPONENT1,MANTISSA1-2,$pLength,$pAdd
 db EXPONENT1-Tgt,EXPONENT2,MANTISSA2-2,$pLength,$pAdd,EXPONENT2-Tgt
 db Zero,ALIGN1-Tgt,EXPONENT1,EXPONENT2-2,$pSubtract,ALIGN2-Tgt
 db ALIGN2,Zero,_Gt,+17,ALIGN2,NOWDIGITS-2,One,$pAdd,$pMin,01h
 db ALIGN2-Tgt,Zero,ALIGN2-2,$pBifq,2*$BifCOPIES,MANTISSA2-2
 db $pAbut,MANTISSA2-Tgt,EXPONENT1,EXPONENT2-Tgt,ALIGN2,Zero
 db _Lt,+22,ALIGN2,$pNegate,ALIGN1-Tgt,ALIGN1,NOWDIGITS-2,One
 db $pAdd,$pMin,01h,ALIGN1-Tgt,Zero,ALIGN2-Tgt,Zero,ALIGN1-2
 db $pBifq,2*$BifCOPIES,MANTISSA1-2,$pAbut,MANTISSA1-Tgt,EXPONENT2
 db EXPONENT1-Tgt,MANTISSA1,$pLength,MANTISSA2-2,$pLength,$pMax
 db 01h,SIGDIGITS-Tgt,SIGDIGITS,NOWDIGITS-2,One,$pAdd,$pMin,01h
 db SIGDIGITS-Tgt,MANTISSA1,SIGDIGITS-2,Zero,$pBifq,2*$BifLEFT+128
 db MANTISSA1-Tgt,MANTISSA2,SIGDIGITS-2,Zero,$pBifq,2*$BifLEFT+128
 db MANTISSA2-Tgt,EXPONENT1,SIGDIGITS-2,$pSubtract,EXPONENT3-Tgt
 db EXPONENT3,EXPONENT1-Tgt,EXPONENT3,EXPONENT2-Tgt,String1,"+"
 db SIGN3-Tgt,SIGN1,String1,"-",_Seq,+10,SIGN2,String1,"+",Frag15
 db String1,"-",SIGN3-Tgt,_Jump,+5,SIGN2,String1,"-",Frag15,OPERATOR
 db String1,"-",_Seq,+12,MANTISSA1,MANTISSA2-2,_Slt,+8,MANTISSA1
 db AA-Tgt,MANTISSA2,MANTISSA1-Tgt,AA,MANTISSA2-Tgt,Frag7,MANTISSA1
 db MANTISSA2-2,OPERATOR-4,CONFIG_ARITH,MANTISSA3-Tgt,$pRepEver
 dw $+24
db MANTISSA3-10,One,$pBifq,2*$BifLEFT,Zero,_Seq,00h,MANTISSA3-12
 db $pLength,One,_Gt,00h,$pAnd,$pWhile,MANTISSA3-10,String1,"2"
 db $pPositive,$pBifq,2*$BifSUBSTR,MANTISSA3-Tgt-10,$pIterate
 db MANTISSA3,$pLength,SIGDIGITS-2,_Gt,+5,SIGDIGITS,One,$pAdd
 db SIGDIGITS-Tgt,SIGDIGITS,NOWDIGITS-2,$pSubtract,AA-Tgt,AA
 db Zero,_Le,+2,_RetBc,MANTISSA3,$pLength,AA-2,$pSubtract,TT-Tgt
 db TT,Zero,_Gt,+51,MANTISSA3,TT-2,One,$pAdd,One,$pBifq,2*$BifSUBSTR+128
 db String1,"4",_Gt,+32,MANTISSA3,TT-2,$pBifq,2*$BifLEFT,One
 db $pAdd,MANTISSA3-Tgt,MANTISSA3,$pLength,TT-2,_Gt,+15,TT,NOWDIGITS-2
 db _Lt,+7,TT,One,$pAdd,TT-Tgt,_Jump,+5,EXPONENT3,One,$pAdd,EXPONENT3-Tgt
 db MANTISSA3,TT-2,$pBifq,2*$BifLEFT,MANTISSA3-Tgt,EXPONENT3
 db AA-2,$pAdd,One,$pSubtract,EXPONENT3-Tgt,_Jump,+3,Zero,MANTISSA3-Tgt
 db _RetBc

_MULTIPLY$$ db 0*8+0,SIGN1,SIGN2-2,_Seq,+6,String1,"+",SIGN3-Tgt
 db _Jump,+4,String1,"-",SIGN3-Tgt,EXPONENT1,EXPONENT2-2,$pAdd
 db EXPONENT3-Tgt,MANTISSA1,Zero,_Seq,+4,Zero,MANTISSA3-Tgt,_RetBc
 db Null,MANTISSA3-Tgt,One,$pNumber,MANTISSA2-10,$pLength,$pTo
 db $pControlVar,ZZ-10
 dw $+64
db MANTISSA3-10,Zero,$pAbut,MANTISSA3-Tgt-10,MANTISSA2-10,ZZ-12
 db One,$pBifq,2*$BifSUBSTR+128,$pRep
 dw $+51
db MANTISSA1-20,$pLength,MANTISSA3-22,$pLength,$pSubtract,TT-Tgt-20
 db TT-20,Zero,_Gt,+8,MANTISSA3-20,MANTISSA1-22,$pLength,Zero
 db $pBifq,2*$BifRIGHT+128,MANTISSA3-Tgt-20,TT-20,Zero,_Lt,+8
 db MANTISSA1-20,MANTISSA3-22,$pLength,Zero,$pBifq,2*$BifRIGHT+128
 db MANTISSA1-Tgt-20,MANTISSA3-20,MANTISSA1-22,String1,"+",CONFIG_ARITH
 db MANTISSA3-Tgt-20,MANTISSA3-20,One,$pBifq,2*$BifLEFT,Zero
 db _Eq,+8,MANTISSA3-20,String1,"2",$pPositive,$pBifq,2*$BifSUBSTR
 db MANTISSA3-Tgt-20,$pIterRep,_IterCV,_RetBc

_DIVTYPE$$ db 0*8+0,MANTISSA2,Zero,_Seq,+19,String,6,"SYNTAX"
 db String,4,"42.3",Zero,Zero,Zero,CONFIG_RAISE,EXPONENT1,EXPONENT2-2
 db $pSubtract,EXPONENT3-Tgt,MANTISSA1,$pLength,MANTISSA2-2,$pLength
 db $pSubtract,EXPONENT3-2,$pAdd,INTDIGITS-Tgt,MANTISSA1,Zero
 db _Eq,00h,INTDIGITS-2,Zero,_Lt,00h,OPERATOR-4,String1,"%",_Seq
 db 00h,$pAnd,$pOr,_Then,+9,Zero,MANTISSA3-Tgt,String1,"+",SIGN3-Tgt
 db Zero,EXPONENT3-Tgt,_RetBc,INTDIGITS,Zero,_Lt,00h,OPERATOR-2
 db String2,"//",_Seq,00h,$pAnd,_Then,+8,MANTISSA1,MANTISSA3-Tgt
 db SIGN1,SIGN3-Tgt,EXPONENT1,EXPONENT3-Tgt,_RetBc,SIGN1,SIGN2-2
 db _Seq,+6,String1,"+",SIGN3-Tgt,_Jump,+4,String1,"-",SIGN3-Tgt
 db Zero,AA-Tgt,Null,MANTISSA3-Tgt,MANTISSA1,MANTISSA2-2,$pLength
 db $pBifq,2*$BifLEFT,A_X-Tgt,MANTISSA1,MANTISSA2-2,$pLength
 db One,$pAdd,$pBifq,2*$BifSUBSTR,A_Y-Tgt,$pRepEver
 dw $+97
db Zero,ZZ-Tgt-10,$pRepEver
 dw $+20
db A_X-20,MANTISSA2-22,$pSubtract,A_X-Tgt-20,A_X-20,One,$pBifq
 db 2*$BifLEFT,String1,"-",_Seq,+2,$pLeave,ZZ-20,One,$pAdd,ZZ-Tgt-20
 db $pIterate,A_X-10,MANTISSA2-12,$pAdd,A_X-Tgt-10,MANTISSA3-10
 db ZZ-12,$pAbut,MANTISSA3-Tgt-10,MANTISSA3-10,Zero,_Seq,+3,Null
 db MANTISSA3-Tgt-10,A_Y-10,Null,_Seq,+6,A_X-10,Zero,_Eq,+2,$pLeave
 db MANTISSA3-10,$pLength,DIGITS-12,_Gt,+2,$pLeave,OPERATOR-10
 db String1,"/",_Sne,+10,INTDIGITS-10,Zero,_Eq,+2,$pLeave,INTDIGITS-10
 db One,$pSubtract,INTDIGITS-Tgt-10,A_Y-10,Null,_Seq,+11,Zero
 db A_Y-Tgt-10,EXPONENT3-10,One,$pSubtract,EXPONENT3-Tgt-10,AA-10
 db One,$pAdd,AA-Tgt-10,A_X-10,A_Y-12,One,$pBifq,2*$BifLEFT,$pAbut
 db A_X-Tgt-10,A_Y-10,String1,"2",$pPositive,$pBifq,2*$BifSUBSTR
 db A_Y-Tgt-10,$pIterate,MANTISSA3,Null,_Eq,+3,Zero,MANTISSA3-Tgt
 db A_X,A_Y-2,$pAbut,ZZ-Tgt,EXPONENT3,A_Y-2,$pLength,$pAdd,EXPONENT3-Tgt
 db $pRepEver
 dw $+12
db Frag8,$pWhile,ZZ-10,String1,"2",$pPositive,$pBifq,2*$BifSUBSTR
 db ZZ-Tgt-10,$pIterate,OPERATOR,String1,"/",_Sne,+42,_FLOATING
 db String1,"E",_Seq,+37,OPERATOR,String1,"%",_Seq,+11,String
 db 5,"26.11",TT-Tgt,_Jump,+9,String,5,"26.12",TT-Tgt,String
 db 6,"SYNTAX",TT-2,NUMBER1-4,NUMBER2-6,DIGITS-8,CONFIG_RAISE
 db OPERATOR,String2,"//",_Seq,+9,SIGN1,SIGN3-Tgt,ZZ,MANTISSA3-Tgt
 db EXPONENT1,AA-2,$pSubtract,EXPONENT3-Tgt,_RetBc

_POWER$$ db 0*8+0,MANTISSA2,Zero,_Seq,+9,String1,"+",SIGN3-Tgt
 db One,MANTISSA3-Tgt,Zero,EXPONENT3-Tgt,_RetBc,MANTISSA2,MANTISSA2-2
 db $pLength,EXPONENT2-4,$pAdd,Zero,$pBifq,2*$BifLEFT+128,RHS-Tgt
 db RHS,$pLength,A_X-Tgt,RHS,$pBifq,2*$BifD2X,$pBifq,2*$BifX2B
 db A_Y-Tgt,One,$pNumber,One,$pBy,$pControlVar,ZZ-10
 dw $+12
db A_Y-10,ZZ-12,One,$pBifq,2*$BifSUBSTR+128,Zero,_Sne,+2,$pLeave
 db _IterCV,One,AA-Tgt,$pRepEver
 dw $+50
db A_Y-10,ZZ-12,One,$pBifq,2*$BifSUBSTR+128,One,_Seq,+19,AA-10
 db SIGN1-12,MANTISSA1-14,$pAbut,String1,"E",$pAbut,EXPONENT1-14
 db $pAbut,String1,"*",DIGITS-16,A_X-18,$pAdd,One,$pAdd,ARITHOP
 db AA-Tgt-10,ZZ-10,A_Y-12,$pLength,_Eq,+2,$pLeave,AA-10,AA-12
 db String1,"*",DIGITS-16,A_X-18,$pAdd,One,$pAdd,ARITHOP,AA-Tgt-10
 db ZZ-10,One,$pAdd,ZZ-Tgt-10,$pIterate,SIGN2,String1,"-",_Seq
 db +15,String1,"+",SIGN2-Tgt,One,AA-2,String1,"/",DIGITS-6,A_X-8
 db $pAdd,One,$pAdd,ARITHOP,AA-Tgt,AA,DIGITS-2,A_X-4,$pAdd,One
 db $pAdd,PREPARE,$pParse,02h,022h,SIGN3-2,MANTISSA3-2,EXPONENT3-2
 db 01ah,_RetBc

TIME2DATE$$ db 0*8+1,Arg1-4,Zero,_Lt,+6,String2,"18",$pPositive
 db CONFIG_RAISE40,Arg1-4,String,18,"315537897600000000",_Ge
 db +6,String2,"18",$pPositive,CONFIG_RAISE40,Arg1-4,TIME2DATE2
 db _RetB

TIME2DATE2$$ db 12*8+1,Y_TIME,String,7,"1000000",$pIntDivide
 db Y_SECOND-Tgt,Y_TIME,String,7,"1000000",$pRemainder,Y_MICROSECOND-Tgt
 db Y_SECOND,String2,"60",$pIntDivide,Y_MINUTE-Tgt,Y_SECOND,String2
 db "60",$pRemainder,Y_SECOND-Tgt,Y_MINUTE,String2,"60",$pIntDivide
 db Y_HOUR-Tgt,Y_MINUTE,String2,"60",$pRemainder,Y_MINUTE-Tgt
 db Y_HOUR,String2,"24",$pIntDivide,Y_DAY-Tgt,Y_HOUR,String2
 db "24",$pRemainder,Y_HOUR-Tgt,Y_DAY,Y_BASEDAYS-Tgt,Y_DAY,One
 db $pAdd,Y_DAY-Tgt,Y_DAY,String,3,"366",$pIntDivide,Y_YEAR-Tgt
 db Y_DAY,Y_YEAR-2,String,3,"365",$pMultiply,Y_YEAR-4,String1
 db "4",$pIntDivide,$pAdd,Y_YEAR-4,String,3,"100",$pIntDivide
 db $pSubtract,Y_YEAR-4,String,3,"400",$pIntDivide,$pAdd,$pSubtract
 db Y_DAY-Tgt,Y_YEAR,One,$pAdd,Y_YEAR-Tgt,$pRepEver
 dw $+30
db Y_DAY-10,String,3,"365",Y_YEAR-14,LEAP,$pAdd,_Gt,00h,$pWhile
 db Y_DAY-10,String,3,"365",Y_YEAR-14,LEAP,$pAdd,$pSubtract,Y_DAY-Tgt-10
 db Y_YEAR-10,One,$pAdd,Y_YEAR-Tgt-10,$pIterate,Y_DAY,Y_YEARDAYS-Tgt
 db String,35,"31 28 31 30 31 30 31 31 30 31 30 31",Y_DAYS-Tgt
 db One,$pNumber,Y_DAYS-10,$pBifq,2*$BifWORDS,$pTo,$pControlVar
 db Y_MONTH-10
 dw $+26
db Y_DAYS-10,Y_MONTH-12,$pBifq,2*$BifWORD,Y_MONTH-12,String1
 db "2",_Eq,00h,Y_YEAR-14,LEAP,$pMultiply,$pAdd,Y_THISMONTH-Tgt-10
 db Y_DAY-10,Y_THISMONTH-12,_Le,+2,$pLeave,Y_DAY-10,Y_THISMONTH-12
 db $pSubtract,Y_DAY-Tgt-10,_IterCV,Y_YEAR,Y_MONTH-2,$pCat,Y_DAY-2
 db $pCat,Y_HOUR-2,$pCat,Y_MINUTE-2,$pCat,Y_SECOND-2,$pCat,Y_MICROSECOND-2
 db $pCat,Y_BASEDAYS-2,$pCat,Y_YEARDAYS-2,$pCat,_RetB

LEAP$$ db 0*8+1,Arg1-4,String1,"4",$pRemainder,Zero,_Eq,00h,Arg1-4-2
 db String,3,"100",$pRemainder,Zero,_Ne,00h,Arg1-4-4,String,3
 db "400",$pRemainder,Zero,_Eq,00h,$pOr,$pAnd,_RetB

RERADIX$$ db 6*8+3,String,3,"999",$pNumeric,00h,Arg1-20,RR_SUBJECT-Tgt
 db Arg2-20,RR_FROMRADIX-Tgt,Arg3-20,RR_TORADIX-Tgt,Zero,RR_INTEGER-Tgt
 db One,$pNumber,RR_SUBJECT-10,$pLength,$pTo,$pControlVar,RR_J-10
 dw $+35
db RR_INTEGER-10,RR_FROMRADIX-12,$pMultiply,RR_SUBJECT-12,RR_J-14
 db One,$pBifq,2*$BifSUBSTR+128,String,16,"0123456789ABCDEF"
 db $pBifq,2*$BifPOS,$pAdd,One,$pSubtract,RR_INTEGER-Tgt-10,_IterCV
 db Null,RR_R-Tgt,RR_TORADIX,String2,"10",_Eq,+7,RR_INTEGER,Zero
 db _Eq,+3,Zero,RR_R-Tgt,$pRepEver
 dw $+41
db RR_INTEGER-10,Zero,_Gt,00h,$pWhile,String,16,"0123456789ABCDEF"
 db One,RR_INTEGER-14,RR_TORADIX-16,$pRemainder,$pAdd,One,$pBifq
 db 2*$BifSUBSTR+128,RR_R-12,$pAbut,RR_R-Tgt-10,RR_INTEGER-10
 db RR_TORADIX-12,$pIntDivide,RR_INTEGER-Tgt-10,$pIterate,RR_FROMRADIX
 db String1,"2",_Eq,00h,RR_TORADIX-2,String2,"16",_Eq,00h,$pAnd
 db _Then,+16,RR_R,RR_SUBJECT-2,$pLength,String1,"3",$pAdd,String1
 db "4",$pIntDivide,Zero,$pBifq,2*$BifRIGHT+128,RR_R-Tgt,_Jump
 db +25,RR_FROMRADIX,String2,"16",_Eq,00h,RR_TORADIX-2,String1
 db "2",_Eq,00h,$pAnd,_Then,+11,RR_R,RR_SUBJECT-2,$pLength,String1
 db "4",$pMultiply,Zero,$pBifq,2*$BifRIGHT+128,RR_R-Tgt,RR_R
 db _RetB
;õ bf\ABBREV.inc
BIFABBREV db 6*8+3,Arg3-20,_Exists,_Then,+5,Arg3-20,LENGTH_-Tgt
 db _Jump,+4,SUBJ,$pLength,LENGTH_-Tgt,SUBJECT,$pLength,SUBJ-2
 db $pLength,_Ge,00h,COND1-Tgt,SUBJ,$pLength,LENGTH_-2,_Ge,00h
 db COND2-Tgt,SUBJECT,One,SUBJ-4,$pLength,$pBifq,2*$BifSUBSTR+128
 db SUBJ-2,_Seq,00h,COND3-Tgt,COND1,COND2-2,$pAnd,COND3-2,$pAnd
 db _RetB
;õ bf\CENTER.inc
BIFCENTER db 4*8+3,Frag22,_Gt,+12,STRING,TRIM-2,String1,"2",$pIntDivide
 db One,$pAdd,C_LENGTH-4,$pBifq,2*$BifSUBSTR+128,_RetB,STRING
 db PAD-2,C_LENGTH-4,$pBifq,2*$BifCOPIES,TRIM-4,$pNegate,String1
 db "2",$pIntDivide,One,$pAdd,$pBifq,2*$BifOVERLAY+128,_RetB
;õ bf\CHANGEST.inc
BIFCHANGESTR db 3*8+3,Null,OUTPUT-Tgt,One,POSITION-Tgt,$pRepEver
 dw $+31
db Arg1-14-10,Arg2-14-12,POSITION-14,$pBifq,2*$BifPOS+128,FOUNDPOS-Tgt-10
 db FOUNDPOS-10,Zero,_Eq,+2,$pLeave,OUTPUT-10,Arg2-14-12,POSITION-14
 db FOUNDPOS-16,POSITION-18,$pSubtract,$pBifq,2*$BifSUBSTR+128
 db $pAbut,Arg3-14-12,$pAbut,OUTPUT-Tgt-10,FOUNDPOS-10,Arg1-14-12
 db $pLength,$pAdd,POSITION-Tgt-10,$pIterate,OUTPUT,Arg2-14-2
 db POSITION-4,$pBifq,2*$BifSUBSTR,$pAbut,_RetB
;õ bf\COMPARE.inc
BIFCOMPARE db 6*8+3,Arg3-20,_Exists,_Then,+5,Arg3-20,C_PAD-Tgt
 db _Jump,+4,String1," ",C_PAD-Tgt,STR1,$pLength,STR2-2,$pLength
 db _Gt,+12,STR1,$pLength,CO_LENGTH-Tgt,STR2,CO_LENGTH-2,C_PAD-4
 db $pBifq,2*$BifLEFT+128,STR2-Tgt,_Jump,+10,STR2,$pLength,CO_LENGTH-Tgt
 db STR1,CO_LENGTH-2,C_PAD-4,$pBifq,2*$BifLEFT+128,STR1-Tgt,One
 db $pNumber,CO_LENGTH-10,$pTo,$pControlVar,C_I-10
 dw $+17
db STR1-10,C_I-12,One,$pBifq,2*$BifSUBSTR+128,STR2-12,C_I-14
 db One,$pBifq,2*$BifSUBSTR+128,_Sne,+3,C_I-10,_RetB,_IterCV
 db Zero,_RetB
;õ bf\COUNTSTR.inc
BIFCOUNTSTR db 2*8+2,Zero,C_OUTPUT-Tgt,Arg1-10,Arg2-10-2,$pBifq
 db 2*$BifPOS,C_POSITION-Tgt,$pRepEver
 dw $+21
db C_POSITION-10,Zero,_Gt,00h,$pWhile,C_OUTPUT-10,One,$pAdd,C_OUTPUT-Tgt-10
 db Arg1-10-10,Arg2-10-12,C_POSITION-14,Arg1-10-16,$pLength,$pAdd
 db $pBifq,2*$BifPOS+128,C_POSITION-Tgt-10,$pIterate,C_OUTPUT
 db _RetB
;õ bf\DELSTR.inc
BIFDELSTR db 6*8+3,Arg3-20,_Exists,_Then,+3,Arg3-20,LEN-Tgt,NUM
 db D_STRING-2,$pLength,_Gt,+3,D_STRING,_RetB,D_STRING,One,NUM-4
 db One,$pSubtract,$pBifq,2*$BifSUBSTR+128,D_OUTPUT-Tgt,Arg3-20
 db _Exists,_Then,+17,NUM,LEN-2,$pAdd,D_STRING-2,$pLength,_Le
 db +10,D_OUTPUT,D_STRING-2,NUM-4,LEN-6,$pAdd,$pBifq,2*$BifSUBSTR
 db $pAbut,D_OUTPUT-Tgt,D_OUTPUT,_RetB
;õ bf\DELWORD.inc
BIFDELWORD db 6*8+3,Arg3-20,_Exists,_Then,+3,Arg3-20,DW_LEN-Tgt
 db DW_NUM,DW_STRING-2,$pBifq,2*$BifWORDS,_Gt,+3,DW_STRING,_RetB
 db DW_STRING,DW_NUM-2,$pBifq,2*$BifWORDINDEX,One,$pSubtract
 db ENDLEFT-Tgt,DW_STRING,ENDLEFT-2,$pBifq,2*$BifLEFT,DW_OUTPUT-Tgt
 db Arg3-20,_Exists,_Then,+19,DW_STRING,DW_NUM-2,DW_LEN-4,$pAdd
 db $pBifq,2*$BifWORDINDEX,BEGINRIGHT-Tgt,BEGINRIGHT,Zero,_Gt
 db +8,DW_OUTPUT,DW_STRING-2,BEGINRIGHT-4,$pBifq,2*$BifSUBSTR
 db $pAbut,DW_OUTPUT-Tgt,DW_OUTPUT,_RetB
;õ bf\INSERT.inc
BIFINSERT db 5*8+5,Arg3-22,_Exists,_Then,+5,Arg3-22,I_NUM-Tgt
 db _Jump,+3,Zero,I_NUM-Tgt,Frag27,I_PAD-4,$pBifq,2*$BifLEFT+128
 db NEW-2,I_LENGTH-4,I_PAD-6,$pBifq,2*$BifLEFT+128,$pAbut,TARGET-2
 db I_NUM-4,One,$pAdd,$pBifq,2*$BifSUBSTR,$pAbut,_RetB
;õ bf\LASTPOS.inc
BIFLASTPOS db 5*8+3,HAYSTACK,$pLength,START-Tgt,Arg3-18,_Exists
 db _Then,+6,Arg3-18,START-2,$pMin,01h,START-Tgt,NEEDLE,$pLength
 db NEEDLELENGTH-Tgt,NEEDLELENGTH,Zero,_Eq,+3,Zero,_RetB,START
 db NEEDLELENGTH-2,$pSubtract,One,$pAdd,START-Tgt,START,$pNumber
 db One,$pNegate,$pBy,$pControlVar,II-10
 dw $+18
db II-10,Zero,_Gt,00h,$pWhile,HAYSTACK-10,II-12,NEEDLELENGTH-14
 db $pBifq,2*$BifSUBSTR+128,NEEDLE-12,_Seq,+3,II-10,_RetB,_IterCV
 db Zero,_RetB
;õ bf\OVERLAY.inc
BIFOVERLAY db 5*8+5,Arg3-22,_Exists,_Then,+5,Arg3-22,O_NUM-Tgt
 db _Jump,+3,One,O_NUM-Tgt,Frag27,One,$pSubtract,O_PAD-4,$pBifq
 db 2*$BifLEFT+128,O_NEW-2,O_LENGTH-4,O_PAD-6,$pBifq,2*$BifLEFT+128
 db $pAbut,O_TARGET-2,O_NUM-4,O_LENGTH-6,$pAdd,$pBifq,2*$BifSUBSTR
 db $pAbut,_RetB
;õ bf\POS.inc
BIFPOS db 6*8+3,Frag13,$pLength,Zero,_Eq,+3,Zero,_RetB,P_START
 db $pNumber,O_HAYSTACK-10,$pLength,One,$pAdd,P_NEEDLE-12,$pLength
 db $pSubtract,$pTo,$pControlVar,P_I-10
 dw $+14
db P_HAYSTACK-10,P_I-12,P_NEEDLE-14,$pLength,$pBifq,2*$BifSUBSTR+128
 db P_NEEDLE-12,_Seq,+3,P_I-10,_RetB,_IterCV,Zero,_RetB
;õ bf\RIGHT.inc
BIFRIGHT db 4*8+3,Frag22,_Ge,+8,R_STRING,R_TRIM-2,One,$pAdd,$pBifq
 db 2*$BifSUBSTR,_RetB,R_PAD,R_TRIM-2,$pNegate,$pBifq,2*$BifCOPIES
 db R_STRING-2,$pAbut,_RetB
;õ bf\SPACE.inc
BIFSPACE db 6*8+3,Arg2-20,_Exists,_Then,+5,Arg2-20,S_NUM-Tgt
 db _Jump,+3,One,S_NUM-Tgt,Arg3-20,_Exists,_Then,+5,Arg3-20,S_PAD-Tgt
 db _Jump,+4,String1," ",S_PAD-Tgt,S_PAD,S_NUM-2,$pBifq,2*$BifCOPIES
 db PADDING-Tgt,S_STRING,One,One,$pBifq,2*$BifSUBWORD+128,S_OUTPUT-Tgt
 db String1,"2",$pNumber,S_STRING-10,$pBifq,2*$BifWORDS,$pTo
 db $pControlVar,S_I-10
 dw $+13
db S_OUTPUT-10,PADDING-12,$pAbut,S_STRING-12,S_I-14,One,$pBifq
 db 2*$BifSUBWORD+128,$pAbut,S_OUTPUT-Tgt-10,_IterCV,S_OUTPUT
 db _RetB
;õ bf\STRIP.inc
BIFSTRIP db 3*8+3,Arg2-14,_Exists,_Then,+5,Arg2-14,OPTION_-Tgt
 db _Jump,+4,String1,"B",OPTION_-Tgt,Arg3-14,_Exists,_Then,+5
 db Arg3-14,UNWANTED-Tgt,_Jump,+10,String,6,09h,0ah,0bh,0ch,0dh
 db 020h,UNWANTED-Tgt,OPTION_,String1,"L",_Seq,00h,OPTION_-2
 db String1,"B",_Seq,00h,$pOr,_Then,+28,$pRepEver
 dw $+26
db ST_STRING-10,Null,_Sne,00h,ST_STRING-12,One,$pBifq,2*$BifLEFT
 db UNWANTED-14,$pBifq,2*$BifPOS,Zero,_Gt,00h,$pAnd,$pWhile,ST_STRING-10
 db String1,"2",$pPositive,$pBifq,2*$BifSUBSTR,ST_STRING-Tgt-10
 db $pIterate,OPTION_,String1,"T",_Seq,00h,OPTION_-2,String1
 db "B",_Seq,00h,$pOr,_Then,+29,$pRepEver
 dw $+27
db ST_STRING-10,Null,_Sne,00h,ST_STRING-12,One,$pBifq,2*$BifRIGHT
 db UNWANTED-14,$pBifq,2*$BifPOS,Zero,_Gt,00h,$pAnd,$pWhile,ST_STRING-10
 db ST_STRING-12,$pLength,One,$pSubtract,$pBifq,2*$BifLEFT,ST_STRING-Tgt-10
 db $pIterate,ST_STRING,_RetB
;õ bf\SUBWORD.inc
BIFSUBWORD db 6*8+3,Arg3-20,_Exists,_Then,+5,Arg3-20,S_LENGTH-Tgt
 db _Jump,+4,SW_STRING,$pLength,S_LENGTH-Tgt,S_LENGTH,Zero,_Eq
 db +3,Null,_RetB,SW_STRING,SW_NUM-2,$pBifq,2*$BifWORDINDEX,S_START-Tgt
 db S_START,Zero,_Eq,+3,Null,_RetB,SW_STRING,SW_NUM-2,S_LENGTH-4
 db $pAdd,$pBifq,2*$BifWORDINDEX,END_-Tgt,END_,Zero,_Eq,+6,SW_STRING
 db $pLength,One,$pAdd,END_-Tgt,SW_STRING,S_START-2,END_-4,S_START-6
 db $pSubtract,$pBifq,2*$BifSUBSTR+128,SW_OUTPUT-Tgt,$pRepEver
 dw $+34
db SW_OUTPUT-10,Null,_Sne,00h,$pWhile,SW_OUTPUT-10,One,$pBifq
 db 2*$BifRIGHT,String,6,09h,0ah,0bh,0ch,0dh,020h,$pBifq,2*$BifPOS
 db Zero,_Eq,+2,$pLeave,SW_OUTPUT-10,SW_OUTPUT-12,$pLength,One
 db $pSubtract,$pBifq,2*$BifLEFT,SW_OUTPUT-Tgt-10,$pIterate,SW_OUTPUT
 db _RetB
;õ bf\TRANSLAT.inc
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
;õ bf\VERIFY.inc
BIFVERIFY db 12*8+4,Arg3-34,_Exists,_Then,+5,Arg3-34,V_OPTION-Tgt
 db _Jump,+4,String1,"N",V_OPTION-Tgt,Arg4-34,_Exists,_Then,+5
 db Arg4-34,V_START-Tgt,_Jump,+3,One,V_START-Tgt,V_STRING,$pLength
 db LAST-Tgt,V_START,LAST-2,_Gt,+3,Zero,_RetB,REFERENCE,Null
 db _Seq,+12,V_OPTION,String1,"N",_Seq,+5,V_START,_RetB,_Jump
 db +3,Zero,_RetB,V_START,$pNumber,LAST-10,$pTo,$pControlVar
 db V_I-10
 dw $+31
db V_STRING-10,V_I-12,One,$pBifq,2*$BifSUBSTR+128,REFERENCE-12
 db $pBifq,2*$BifPOS,V_T-Tgt-10,V_OPTION-10,String1,"N",_Seq
 db +9,V_T-10,Zero,_Eq,+3,V_I-10,_RetB,_Jump,+7,V_T-10,Zero,_Gt
 db +3,V_I-10,_RetB,_IterCV,Zero,_RetB
;õ bf\WORD.inc
BIFWORD db 0*8+2,Arg1-6,Arg2-6-2,One,$pBifq,2*$BifSUBWORD+128
 db _RetB
;õ bf\WORDINDE.inc
BIFWORDINDEX db 4*8+2,One,W_START-Tgt,Zero,COUNT-Tgt,$pRepEver
 dw $+56
db W_STRING-10,String,6,09h,0ah,0bh,0ch,0dh,020h,String1,"N"
 db W_START-16,$pBifq,2*$BifVERIFY+1,W_START-Tgt-10,W_START-10
 db Zero,_Eq,+3,Zero,_RetB,COUNT-10,One,$pAdd,COUNT-Tgt-10,COUNT-10
 db W_NUM-12,_Eq,+2,$pLeave,W_STRING-10,String,6,09h,0ah,0bh
 db 0ch,0dh,020h,String1,"M",W_START-16,One,$pAdd,$pBifq,2*$BifVERIFY+1
 db W_START-Tgt-10,W_START-10,Zero,_Eq,+3,Zero,_RetB,$pIterate
 db W_START,_RetB
;õ bf\WORDLENG.inc
BIFWORDLENGTH db 0*8+2,Arg1-6,Arg2-6-2,One,$pBifq,2*$BifSUBWORD+128
 db $pLength,_RetB
;õ bf\WORDPOS.inc
BIFWORDPOS db 6*8+3,Frag13,$pBifq,2*$BifSPACE,PHRASE-Tgt,PHRASE
 db $pBifq,2*$BifWORDS,PHRASEWORDS-Tgt,PHRASEWORDS,Zero,_Eq,+3
 db Zero,_RetB,WP_STRING,$pBifq,2*$BifSPACE,WP_STRING-Tgt,WP_STRING
 db $pBifq,2*$BifWORDS,STRINGWORDS-Tgt,R_START,$pNumber,STRINGWORDS-10
 db PHRASEWORDS-12,$pSubtract,One,$pAdd,$pTo,$pControlVar,WORDNUMBER-10
 dw $+13
db PHRASE-10,WP_STRING-12,WORDNUMBER-14,PHRASEWORDS-16,$pBifq
 db 2*$BifSUBWORD+128,_Seq,+3,WORDNUMBER-10,_RetB,_IterCV,Zero
 db _RetB
;õ bf\WORDS.inc
BIFWORDS db 2*8+1,Zero,S_COUNT-Tgt,$pRepEver
 dw $+19
db S_PART-10,Null,_Ne,00h,$pWhile,S_COUNT-10,One,$pAdd,S_COUNT-Tgt-10
 db S_PART-10,$pParse,00h,022h,ParseDot,S_PART-12,01ah,$pIterate
 db S_COUNT,_RetB
;õ bf\FORMAT.inc
BIFFORMAT db 20*8+5,Arg2-52,_Exists,_Then,+3,Arg2-52,BEFORE-Tgt
 db Arg3-52,_Exists,_Then,+3,Arg3-52,AFTER-Tgt,Arg4-52,_Exists
 db _Then,+3,Arg4-52,EXPP-Tgt,Arg5-52,_Exists,_Then,+5,Arg5-52
 db EXPT-Tgt,_Jump,+4,$pBifq,2*$BifDIGITS,EXPT-Tgt,Arg1-52,F_NUMBER-Tgt
 db $pBifq,2*$BifARG,String1,"2",_Lt,+3,F_NUMBER,_RetB,F_NUMBER
 db $pParse,00h,String1,"E",02ah,F_MANTISSA-2,022h,F_EXPONENT-2
 db 01ah,F_EXPONENT,Null,_Seq,+3,Zero,F_EXPONENT-Tgt,Zero,F_SIGN-Tgt
 db F_MANTISSA,One,$pBifq,2*$BifLEFT,String1,"-",_Seq,+10,One
 db F_SIGN-Tgt,F_MANTISSA,String1,"2",$pPositive,$pBifq,2*$BifSUBSTR
 db F_MANTISSA-Tgt,F_MANTISSA,$pParse,00h,String1,".",02ah,BEFO-2
 db 022h,AFTE-2,01ah,BEFO,AFTE-2,$pAbut,F_MANTISSA-Tgt,F_EXPONENT
 db AFTE-2,$pLength,$pSubtract,F_EXPONENT-Tgt,$pRepEver
 dw $+12
db Frag8,$pWhile,F_MANTISSA-10,String1,"2",$pPositive,$pBifq
 db 2*$BifSUBSTR,F_MANTISSA-Tgt-10,$pIterate,F_MANTISSA,$pLength
 db POINT-Tgt,Zero,SHOWEXP-Tgt,F_MANTISSA,$pLength,F_EXPONENT-2
 db $pAdd,EXPT-2,_Gt,+3,One,SHOWEXP-Tgt,F_EXPONENT,$pNegate,F_MANTISSA-2
 db $pLength,$pSubtract,String1,"6",_Ge,+3,One,SHOWEXP-Tgt,Arg4-52
 db _Exists,_Then,+7,EXPP,Zero,_Eq,+3,Zero,SHOWEXP-Tgt,SHOWEXP
 db _Then,+53,One,POINT-Tgt,F_EXPONENT,F_MANTISSA-2,$pLength
 db $pAdd,One,$pSubtract,F_EXPONENT-Tgt,$pBifq,2*$BifFORM,String
 db 11,"ENGINEERING",_Seq,+25,$pRepEver
 dw $+23
db F_EXPONENT-10,String1,"3",$pRemainder,Zero,_Ne,00h,$pWhile
 db POINT-10,One,$pAdd,POINT-Tgt-10,F_EXPONENT-10,One,$pSubtract
 db F_EXPONENT-Tgt-10,F_MANTISSA-10,Zero,$pAbut,F_MANTISSA-Tgt-10
 db $pIterate,_Jump,+54,F_MANTISSA,$pLength,POINT-Tgt,$pRepEver
 dw $+20
db F_EXPONENT-10,Zero,_Gt,00h,$pWhile,F_MANTISSA-10,Zero,$pAbut
 db F_MANTISSA-Tgt-10,POINT-10,One,$pAdd,POINT-Tgt-10,F_EXPONENT-10
 db One,$pSubtract,F_EXPONENT-Tgt-10,$pIterate,$pRepEver
 dw $+28
db F_EXPONENT-10,Zero,_Lt,00h,$pWhile,POINT-10,One,$pSubtract
 db POINT-Tgt-10,POINT-10,One,_Lt,+9,Zero,F_MANTISSA-12,$pAbut
 db F_MANTISSA-Tgt-10,POINT-10,One,$pAdd,POINT-Tgt-10,F_EXPONENT-10
 db One,$pAdd,F_EXPONENT-Tgt-10,$pIterate,F_MANTISSA,$pLength
 db POINT-2,$pSubtract,AFTERS-Tgt,Arg3-52,_Exists,Zero,_Eq,+3
 db AFTERS,AFTER-Tgt,$pRepEver
 dw $+16
db AFTERS-10,AFTER-12,_Lt,00h,$pWhile,AFTERS-10,One,$pAdd,AFTERS-Tgt-10
 db F_MANTISSA-10,Zero,$pAbut,F_MANTISSA-Tgt-10,$pIterate,AFTERS
 db AFTER-2,_Gt,+115,F_MANTISSA,POINT-2,AFTER-4,$pAdd,One,$pAdd
 db One,$pBifq,2*$BifSUBSTR+128,F_R-Tgt,F_MANTISSA,POINT-2,AFTER-4
 db $pAdd,$pBifq,2*$BifLEFT,F_MANTISSA-Tgt,F_MANTISSA,$pLength
 db MANTLEN-Tgt,F_R,String1,"5",_Ge,+5,F_MANTISSA,One,$pAdd,F_MANTISSA-Tgt
 db F_MANTISSA,Zero,_Eq,+3,Zero,F_SIGN-Tgt,F_MANTISSA,$pLength
 db MANTLEN-2,_Lt,+11,Zero,MANTLEN-2,F_MANTISSA-4,$pLength,$pSubtract
 db $pBifq,2*$BifCOPIES,F_MANTISSA-2,$pAbut,F_MANTISSA-Tgt,F_MANTISSA
 db $pLength,MANTLEN-2,_Gt,+11,POINT,One,$pAdd,POINT-Tgt,POINT
 db EXPT-2,_Gt,+3,One,SHOWEXP-Tgt,SHOWEXP,One,_Eq,+46,F_EXPONENT
 db POINT-2,One,$pSubtract,$pAdd,F_EXPONENT-Tgt,One,POINT-Tgt
 db $pBifq,2*$BifFORM,String,11,"ENGINEERING",_Seq,+21,$pRepEver
 dw $+19
db F_EXPONENT-10,String1,"3",$pRemainder,Zero,_Ne,00h,$pWhile
 db POINT-10,One,$pAdd,POINT-Tgt-10,F_EXPONENT-10,One,$pSubtract
 db F_EXPONENT-Tgt-10,$pIterate,AFTER,Zero,_Gt,+14,String1,"."
 db F_MANTISSA-2,POINT-4,One,$pAdd,AFTER-6,$pBifq,2*$BifSUBSTR+128
 db $pAbut,AFTE-Tgt,_Jump,+3,Null,AFTE-Tgt,F_MANTISSA,POINT-2
 db $pBifq,2*$BifLEFT,F_MANTISSA-Tgt,Arg2-52,_Exists,Zero,_Eq
 db +5,POINT,F_SIGN-2,$pAdd,BEFORE-Tgt,POINT,BEFORE-2,F_SIGN-4
 db $pSubtract,_Gt,+10,String1,"2",$pPositive,Arg1-52-2,String2
 db "38",$pPositive,CONFIG_RAISE40,$pRepEver
 dw $+16
db POINT-10,BEFORE-12,_Lt,00h,$pWhile,POINT-10,One,$pAdd,POINT-Tgt-10
 db Zero,F_MANTISSA-12,$pAbut,F_MANTISSA-Tgt-10,$pIterate,Null
 db F_R-Tgt,Zero,TRIGGERED-Tgt,One,$pNumber,F_MANTISSA-10,$pLength
 db $pTo,$pControlVar,F_Z-10
 dw $+76
db F_MANTISSA-10,F_Z-12,One,$pBifq,2*$BifSUBSTR+128,DIGIT-Tgt-10
 db TRIGGERED-10,One,_Eq,+6,F_R-10,DIGIT-12,$pAbut,F_R-Tgt-10
 db _IterCV,DIGIT-10,Zero,_Eq,+27,F_MANTISSA-10,F_Z-12,One,$pAdd
 db One,$pBifq,2*$BifSUBSTR+128,Zero,_Eq,00h,F_Z-12,One,$pAdd
 db F_MANTISSA-14,$pLength,_Lt,00h,$pAnd,_Then,+7,F_R-10,String1
 db " ",$pAbut,F_R-Tgt-10,_IterCV,DIGIT-10,Zero,_Eq,00h,F_Z-12
 db F_MANTISSA-14,$pLength,_Ne,00h,$pAnd,_Then,+4,String1," "
 db DIGIT-Tgt-10,F_SIGN-10,One,_Eq,+4,String1,"-",DIGIT-Tgt-10
 db F_R-10,DIGIT-12,$pAbut,F_R-Tgt-10,One,TRIGGERED-Tgt-10,_IterCV
 db F_R,AFTE-2,$pAbut,F_NUMBER-Tgt,SHOWEXP,One,_Eq,+83,Null,EXPART-Tgt
 db Zero,SIGNEXP-Tgt,F_EXPONENT,Zero,_Lt,+6,One,SIGNEXP-Tgt,F_EXPONENT
 db $pNegate,F_EXPONENT-Tgt,Arg4-52,_Exists,Zero,_Eq,+4,F_EXPONENT
 db $pLength,EXPP-Tgt,F_EXPONENT,$pLength,EXPP-2,_Gt,+10,String1
 db "4",$pPositive,Arg1-52-2,String2,"38",$pPositive,CONFIG_RAISE40
 db F_EXPONENT,EXPP-2,Zero,$pBifq,2*$BifRIGHT+128,F_EXPONENT-Tgt
 db F_EXPONENT,Zero,_Eq,+16,Arg4-52,_Exists,_Then,+10,String1
 db " ",EXPP-2,String1,"2",$pAdd,$pBifq,2*$BifCOPIES,EXPART-Tgt
 db _Jump,+19,SIGNEXP,Zero,_Eq,+9,String2,"E+",F_EXPONENT-2,$pAbut
 db EXPART-Tgt,_Jump,+7,String2,"E-",F_EXPONENT-2,$pAbut,EXPART-Tgt
 db F_NUMBER,EXPART-2,$pAbut,F_NUMBER-Tgt,F_NUMBER,_RetB
;õ bf\MAX.inc
BIFMAX db 3*8+0,Frag11,$pControlVar,I_M-10
 dw $+13
db I_M-10,$pBifq,2*$BifARG+128,NEXT-Tgt-10,MAX-10,NEXT-12,_Lt
 db +3,NEXT-10,MAX-Tgt-10,_IterCV,MAX,_RetB
;õ bf\MIN.inc
BIFMIN db 3*8+0,Frag11,$pControlVar,I_N-10
 dw $+13
db I_N-10,$pBifq,2*$BifARG+128,_NEXT-Tgt-10,MIN-10,_NEXT-12,_Gt
 db +3,_NEXT-10,MIN-Tgt-10,_IterCV,MIN,_RetB
;õ bf\TRUNC.inc
BIFTRUNC db 4*8+2,Arg2-14,_Exists,_Then,+5,Arg2-14,T_NUM-Tgt
 db _Jump,+3,Zero,T_NUM-Tgt,String2,"10",T_NUM-2,$pPower,T_NUMBER-2
 db $pMultiply,One,$pIntDivide,T_INTEGER-Tgt,T_NUM,Zero,_Eq,+3
 db T_INTEGER,_RetB,T_INTEGER,$pLength,T_NUM-2,$pSubtract,T_T-Tgt
 db T_T,Zero,_Le,+13,String2,"0.",T_INTEGER-2,T_NUM-4,Zero,$pBifq
 db 2*$BifRIGHT+128,$pAbut,_RetB,_Jump,+8,String1,".",T_INTEGER-2
 db T_T-4,$pBifq,2*$BifINSERT+128,_RetB
;õ bf\ERRORTEX.inc
BIFERRORTEXT db 23*8+2,Arg1-52,MSGCODE-Tgt,String1,"N",E_OPTION-Tgt
 db Arg2-52,_Exists,_Then,+3,Arg2-52,E_OPTION-Tgt,MSGCODE,One
 db $pIntDivide,MAJOR-Tgt,MSGCODE,MAJOR-2,$pSubtract,MINOR-Tgt
 db MAJOR,Zero,_Lt,00h,MAJOR-2,String2,"90",_Gt,00h,$pOr,MINOR-2
 db String2,".9",_Gt,00h,$pOr,String1,"E",MSGCODE-4,$pBifq,2*$BifPOS
 db Zero,_Gt,00h,$pOr,_Then,+7,Arg1-52,String2,"17",$pPositive
 db CONFIG_RAISE40,MINOR,Zero,_Gt,+8,MINOR,String1,"3",$pPositive
 db $pBifq,2*$BifSUBSTR,MINOR-Tgt,String,3,"256",MAJOR-2,$pMultiply
 db MINOR-2,$pAdd,CONFIG_MSG,_RetB
;õ bf\B2X.inc
BIFB2X db 1*8+1,Arg1-6,Zero,$pBifq,2*$BifSPACE+128,B_STRING-Tgt
 db B_STRING,String1,"2",String2,"16",RERADIX,_RetB
;õ bf\BITAND.inc
BIFBITAND db 9*8+3,Arg2-26,_Exists,_Then,+5,Arg2-26,STRING2-Tgt
 db _Jump,+3,Null,STRING2-Tgt,Arg3-26,_Exists,_Then,+23,STRING1
 db $pLength,STRING2-2,$pLength,_Gt,+10,STRING2,STRING1-2,$pLength
 db Arg3-26-4,$pBifq,2*$BifLEFT+128,STRING2-Tgt,_Jump,+8,STRING1
 db STRING2-2,$pLength,Arg3-26-4,$pBifq,2*$BifLEFT+128,STRING1-Tgt
 db STRING1,CONFIG_C2B,?OUTCOME,STRING1-Tgt,STRING2,CONFIG_C2B
 db ?OUTCOME,STRING2-Tgt,STRING1,$pLength,STRING2-2,$pLength
 db _Lt,+7,STRING1,B_T-Tgt,STRING2,STRING1-Tgt,B_T,STRING2-Tgt
 db Null,B_R-Tgt,One,$pNumber,STRING2-10,$pLength,$pTo,$pControlVar
 db B_J-10
 dw $+67
db STRING1-10,B_J-12,One,$pBifq,2*$BifSUBSTR+128,B1-Tgt-10,STRING2-10
 db B_J-12,One,$pBifq,2*$BifSUBSTR+128,B2-Tgt-10,?BIF,String
 db 6,"BITAND",_Seq,+7,B1-10,B2-12,$pAnd,B1-Tgt-10,_Jump,+32
 db ?BIF,String,5,"BITOR",_Seq,+7,B1-10,B2-12,$pOr,B1-Tgt-10
 db _Jump,+16,?BIF,String,6,"BITXOR",_Seq,+5,B1-10,B2-12,$pXor
 db B1-Tgt-10,B_R-10,B1-12,$pAbut,B_R-Tgt-10,_IterCV,B_R,STRING1-2
 db STRING1-4,$pLength,STRING2-6,$pLength,$pSubtract,$pBifq,2*$BifRIGHT
 db $pAbut,B_R-Tgt,B_R,CONFIG_B2C,?OUTCOME,_RetB
;õ bf\C2D.inc
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
;õ bf\C2X.inc
BIFC2X db 0*8+1,Arg1-4,$pLength,Zero,_Eq,+3,Null,_RetB,Arg1-4
 db CONFIG_C2B,?OUTCOME,String1,"2",String2,"16",RERADIX,_RetB
;õ bf\D2C.inc
BIFD2C db 4*8+2,String,3,"999",$pNumeric,00h,Arg1-14,$pBifq,2*$BifABS
 db Frag12,$pRepEver
 dw $+15
db D_LENGTH-10,String1,"8",$pRemainder,Zero,_Ne,00h,$pWhile,D_LENGTH-10
 db One,$pAdd,D_LENGTH-Tgt-10,$pIterate,Arg1-14,Zero,_Lt,+24
 db String1,"2",D_LENGTH-2,$pPower,D_SUBJECT-2,$pSubtract,Frag12
 db $pRepEver
 dw $+15
db D_LENGTH-10,String1,"8",$pRemainder,Zero,_Ne,00h,$pWhile,D_LENGTH-10
 db One,$pAdd,D_LENGTH-Tgt-10,$pIterate,D_R,D_LENGTH-2,Zero,$pBifq
 db 2*$BifRIGHT+128,D_R-Tgt,D_R,CONFIG_B2C,?OUTCOME,DC_OUTPUT-Tgt
 db Arg2-14,_Exists,$pNot,_Then,+3,DC_OUTPUT,_RetB,Arg1-14,Zero
 db _Ge,+13,DC_OUTPUT,Arg2-14-2,$pBifq,2*$BifXRANGE,One,$pBifq
 db 2*$BifLEFT,$pBifq,2*$BifRIGHT+128,_RetB,_Jump,+11,DC_OUTPUT
 db Arg2-14-2,$pBifq,2*$BifXRANGE,One,$pBifq,2*$BifRIGHT,$pBifq
 db 2*$BifRIGHT+128,_RetB
;õ bf\D2X.inc
BIFD2X db 2*8+2,String,3,"999",$pNumeric,00h,Arg1-10,$pBifq,2*$BifABS
 db X_SUBJECT-Tgt,X_SUBJECT,String2,"10",String2,"16",RERADIX
 db X_R-Tgt,Arg1-10,Zero,_Lt,+19,String2,"16",X_R-2,$pLength
 db $pPower,X_SUBJECT-2,$pSubtract,X_SUBJECT-Tgt,X_SUBJECT,String2
 db "10",String2,"16",RERADIX,X_R-Tgt,Arg2-10,_Exists,$pNot,_Then
 db +3,X_R,_RetB,Arg1-10,Zero,_Ge,+9,X_R,Arg2-10-2,Zero,$pBifq
 db 2*$BifRIGHT+128,_RetB,_Jump,+8,X_R,Arg2-10-2,String1,"F"
 db $pBifq,2*$BifRIGHT+128,_RetB
;õ bf\X2B.inc
BIFX2B db 3*8+1,XB_SUBJECT,Null,_Seq,+3,Null,_RetB,XB_SUBJECT
 db Frag9,_RetB
;õ bf\X2C.inc
BIFX2C db 3*8+1,XC_SUBJECT,Null,_Seq,+3,Null,_RetB,XC_SUBJECT
 db Frag9,XC_R-Tgt,String1,"8",XC_SUBJECT-2,$pLength,One,$pAdd
 db String1,"2",$pIntDivide,$pMultiply,XC_LENGTH-Tgt,XC_R,XC_LENGTH-2
 db Zero,$pBifq,2*$BifRIGHT+128,CONFIG_B2C,?OUTCOME,_RetB
;õ bf\X2D.inc
BIFX2D db 4*8+2,String2,"10",Frag3,Arg1-14,XD_SUBJECT-Tgt,XD_SUBJECT
 db Null,_Seq,+3,Zero,_RetB,XD_SUBJECT,Zero,$pBifq,2*$BifSPACE+128
 db $pBifq,2*$BifTRANSLATE,XD_SUBJECT-Tgt,Arg2-14,_Exists,_Then
 db +15,Arg2-14,XD_SUBJECT-2,$pLength,One,$pAdd,$pMin,01h,XD_R-Tgt
 db XD_SUBJECT,XD_R-2,Zero,$pBifq,2*$BifRIGHT+128,XD_SUBJECT-Tgt
 db XD_SUBJECT,Null,_Seq,+3,Zero,_RetB,Arg2-14,_Exists,_Then
 db +10,XD_SUBJECT,$pBifq,2*$BifX2B,One,$pBifq,2*$BifLEFT,SIGNBIT-Tgt
 db _Jump,+3,Zero,SIGNBIT-Tgt,XD_SUBJECT,String2,"16",String2
 db "10",RERADIX,XD_R-Tgt,SIGNBIT,_Then,+11,XD_R,String1,"2"
 db String1,"4",Arg2-14-6,$pMultiply,$pPower,$pSubtract,XD_R-Tgt
 db XD_R,$pBifq,2*$BifABS,XD_MAX-2,_Gt,+7,XD_SUBJECT,String2
 db "35",$pPositive,CONFIG_RAISE40,XD_R,_RetB
;õ bf\CHARIN.inc
BIFCHARIN db 6*8+3,Frag19,Arg2-20,_Exists,_Then,+30,String,6
 db "CHARIN",Arg2-20-2,CONFIG_STREAM_POSITION,?RESPONSE,One,$pBifq
 db 2*$BifLEFT,String1,"R",_Seq,+10,String1,"2",$pPositive,Arg2-20-2
 db String2,"41",$pPositive,CONFIG_RAISE40,?RESPONSE,Frag5,Frag14
 db Zero,_Eq,+10,String,4,"NULL",CONFIG_STREAM_CHARIN,Null,_RetB
 db CONFIG_STREAM_QUERY,?OUTCOME,MODE-Tgt,Null,C_R-Tgt,$pRepEver
 dw $+37
db _Jump,+6,C_COUNT-10,Zero,_Eq,00h,$pUntil,String,6,"CHARIN"
 db CONFIG_STREAM_CHARIN,?RESPONSE,One,$pBifq,2*$BifLEFT,String1
 db "N",_Sne,+3,Frag21,$pLeave,C_R-10,?OUTCOME,$pAbut,C_R-Tgt-10
 db C_COUNT-10,One,$pSubtract,C_COUNT-Tgt-10,$pIterate,MODE,String1
 db "B",_Seq,+5,C_R,CONFIG_B2C,?OUTCOME,C_R-Tgt,C_R,_RetB
;õ bf\CHAROUT.inc
BIFCHAROUT db 6*8+3,Frag19,Arg2-20,_Exists,$pNot,Arg3-20-2,_Exists
 db $pNot,$pAnd,_Then,+6,CONFIG_STREAM_CLOSE,?RESPONSE,Frag5
 db Zero,_RetB,Arg3-20,_Exists,_Then,+31,String,7,"CHAROUT",Arg3-20-2
 db CONFIG_STREAM_POSITION,?RESPONSE,Frag5,?RESPONSE,One,$pBifq
 db 2*$BifLEFT,String1,"R",_Seq,+10,String1,"3",$pPositive,Arg3-20-2
 db String2,"41",$pPositive,CONFIG_RAISE40,Arg2-20,_Exists,$pNot
 db Arg2-20-2,Null,_Seq,00h,$pOr,_Then,+10,String,4,"NULL",
CONFIG_STREAM_CHAROUT,Zero,_RetB,Arg2-20,C_STRING-Tgt,CONFIG_STREAM_QUERY
 db ?OUTCOME,O_MODE-Tgt,O_MODE,String1,"B",_Seq,+16,C_STRING
 db CONFIG_C2B,?OUTCOME,C_STRING-Tgt,String1,"8",STRIDE-Tgt,C_STRING
 db $pLength,String1,"8",$pDivide,RESIDUE-Tgt,_Jump,+6,One,STRIDE-Tgt
 db C_STRING,$pLength,RESIDUE-Tgt,One,CURSOR-Tgt,$pRepEver
 dw $+35
db RESIDUE-10,Zero,_Gt,00h,$pWhile,C_STRING-10,CURSOR-12,STRIDE-14
 db $pBifq,2*$BifSUBSTR+128,PIECE-Tgt-10,CURSOR-10,STRIDE-12
 db $pAdd,CURSOR-Tgt-10,PIECE-10,CONFIG_STREAM_CHAROUT,?RESPONSE
 db One,$pBifq,2*$BifLEFT,String1,"N",_Sne,+4,Frag21,RESIDUE-10
 db _RetB,RESIDUE-10,One,$pSubtract,RESIDUE-Tgt-10,$pIterate
 db Zero,_RetB
;õ bf\CHARS.inc
BIFCHARS db 1*8+2,Frag24,String,5,"CHARS",H_OPTION-2,CONFIG_STREAM_COUNT
 db _RetB
;õ bf\LINEIN.inc
BIFLINEIN db 6*8+3,Frag19,Arg2-20,_Exists,_Then,+30,String,6
 db "LINEIN",Arg2-20-2,CONFIG_STREAM_POSITION,?RESPONSE,Frag5
 db ?RESPONSE,One,$pBifq,2*$BifLEFT,String1,"R",_Seq,+10,String1
 db "2",$pPositive,Arg2-20-2,String2,"41",$pPositive,CONFIG_RAISE40
 db Frag14,One,_Gt,+7,L_COUNT,String2,"39",$pPositive,CONFIG_RAISE40
 db L_COUNT,Zero,_Eq,+10,String,4,"NULL",CONFIG_STREAM_CHARIN
 db Null,_RetB,String,6,"LINEIN",CONFIG_STREAM_CHARIN,?RESPONSE
 db One,$pBifq,2*$BifLEFT,String1,"N",_Sne,+35,?RESPONSE,One
 db $pBifq,2*$BifLEFT,String1,"E",_Seq,+9,String,5,"ERROR",?STREAMSTATE+Tgts
 db String,8,"NOTREADY",?STREAM,?RESPONSE,String1,"2",$pPositive
 db $pBifq,2*$BifSUBSTR,CONFIG_RAISE,?OUTCOME,_RetB
;õ bf\LINEOUT.inc
BIFLINEOUT db 6*8+3,Frag19,Arg2-20,CONFIG_STREAM_CHAROUT,Zero
 db _RetB,Arg3-20,_RetB
;õ bf\LINES.inc
BIFLINES db 1*8+2,Frag24,String,5,"LINES",N_OPTION-2,CONFIG_STREAM_COUNT
 db _RetB
;õ bf\QUALIFY.inc
BIFQUALIFY db 8*8+1,Arg1-20,_Exists,_Then,+5,Arg1-20,?STREAM+Tgts
 db _Jump,+3,Null,?STREAM+Tgts,Null,Zero,CONFIG_STREAM_QUALIFIED
 db _RetB
;õ bf\STREAM.inc
BIFSTREAM db 1*8+3,Arg1-10,?STREAM+Tgts,Arg2-10,_Exists,_Then
 db +5,Arg2-10,OPERATION-Tgt,_Jump,+4,String1,"S",OPERATION-Tgt
 db Arg3-10,_Exists,OPERATION-2,String1,"C",_Sne,00h,$pAnd,_Then
 db +8,String1,"2",$pPositive,String1,"4",$pPositive,CONFIG_RAISE40
 db OPERATION,String1,"C",_Seq,+7,Arg3-10,CONFIG_STREAM_COMMAND
 db ?OUTCOME,_RetB,_Jump,+85,OPERATION,String1,"D",_Seq,+11,CONFIG_STREAM_STATE
 db ?RESPONSE,String1,"2",$pPositive,$pBifq,2*$BifSUBSTR,_RetB
 db _Jump,+70,OPERATION,String1,"S",_Seq,+65,?STREAMSTATE,String
 db 5,"ERROR",_Seq,+9,String,5,"ERROR",_RetB,CONFIG_STREAM_STATE
 db ?RESPONSE,One,$pBifq,2*$BifLEFT,String1,"N",_Seq,+9,String
 db 5,"READY",_RetB,?RESPONSE,One,$pBifq,2*$BifLEFT,String1,"U"
 db _Seq,+11,String,7,"UNKNOWN",_RetB,String,8,"NOTREADY",_RetB
;õ bf\DATE.inc
BIFDATE db 13*8+3,String2,"18",Frag28,String,42,
"January February March April May June July",String,42,
"August September October November December",$pCat,?MONTHS+Tgts
 db String,56,"Monday Tuesday Wednesday Thursday Friday Saturday Sunday"
 db ?WEEKDAYS+Tgts,Arg2-34,_Exists,$pNot,_Then,+5,?CLAUSELOCAL
 db D_OPTION-2,DATEFORMAT,_RetB,Frag20,String2,"NS",LOGIC-Tgt
 db INOPTION,String1,"N",_Seq,+35,VALUE,$pParse,00h,022h,DAY-2
 db MONTHIS-2,YEAR-2,01ah,One,$pNumber,String2,"12",$pTo,$pControlVar
 db MONTH-10
 dw $+16
db ?MONTHS,MONTH-12,$pBifq,2*$BifWORD,String1,"3",$pPositive
 db $pBifq,2*$BifLEFT,MONTHIS-12,_Seq,+2,$pLeave,_IterCV,_Jump
 db +28,INOPTION,String1,"S",_Seq,+17,VALUE,$pParse,00h,String1
 db "4",03ah,YEAR-2,String1,"2",03ah,MONTH-2,022h,DAY-2,01ah
 db _Jump,+7,String,3,"EOU",LOGIC-Tgt,LOGIC,String,3,"EOU",_Seq
 db +68,INOPTION,String1,"E",_Seq,+17,VALUE,$pParse,00h,String1
 db "/",02ah,DAY-2,String1,"/",02ah,MONTH-2,022h,YY-2,01ah,_Jump
 db +47,INOPTION,String1,"O",_Seq,+17,VALUE,$pParse,00h,String1
 db "/",02ah,YY-2,String1,"/",02ah,MONTH-2,022h,DAY-2,01ah,_Jump
 db +26,INOPTION,String1,"U",_Seq,+17,VALUE,$pParse,00h,String1
 db "/",02ah,MONTH-2,String1,"/",02ah,DAY-2,022h,YY-2,01ah,_Jump
 db +5,String2,"BD",LOGIC-Tgt,LOGIC,String,3,"EOU",_Seq,+34,YY
 db Frag10,?CLAUSELOCAL,TIME2DATE,$pParse,02h,022h,YEARNOW-2
 db ParseDot,01ah,YY,YEAR-Tgt,$pRepEver
 dw $+20
db YEAR-10,YEARNOW-12,String2,"50",$pSubtract,_Lt,00h,$pWhile
 db YEAR-10,String,3,"100",$pAdd,YEAR-Tgt-10,$pIterate,LOGIC
 db String2,"BD",_Sne,+60,MONTH,Frag4,String1,"W",Frag6,String
 db 44,"0 31 59 90 120 151 181 212 243 273 304 334 0",MONTH-2
 db $pBifq,2*$BifWORD,DAYS-Tgt,DAYS,Frag17,_Jump,+3,VALUE,Frag10
 db INOPTION,String1,"D",_Seq,+13,?CLAUSELOCAL,TIME2DATE,$pParse
 db 02h,022h,YEAR-2,ParseDot,01ah,VALUE,One,$pSubtract,DAYS-Tgt
 db INOPTION,String1,"B",_Sne,+4,Frag25,_Jump,+3,VALUE,BASEDAYS-Tgt
 db BASEDAYS,String,5,"864E8",$pMultiply,MICRO-Tgt,MICRO,INOPTION-2
 db DATEFORMAT,Frag16,DATEFORMAT,_RetB

DATEFORMAT$$ db 9*8+2,Arg1-24,TIME2DATE,$pParse,02h,022h,D_YEAR-2
 db D_MONTH-2,D_DAY-2,D_HOUR-2,D_MINUTE-2,D_SECOND-2,D_MICROSECOND-2
 db D_BASE-2,D_DAYS-2,01ah,Arg2-24,String1,"B",_Seq,+5,D_BASE
 db _RetB,_Jump,+165,Arg2-24,String1,"D",_Seq,+5,D_DAYS,_RetB
 db _Jump,+156,Arg2-24,String1,"E",_Seq,+14,D_DAY,Frag18,D_YEAR-2
 db String1,"2",$pPositive,Zero,$pBifq,2*$BifRIGHT+128,$pAbut
 db _RetB,_Jump,+138,Arg2-24,String1,"M",_Seq,+9,?MONTHS,D_MONTH-2
 db $pPositive,$pBifq,2*$BifWORD,_RetB,_Jump,+125,Arg2-24,String1
 db "N",_Seq,+24,D_DAY,?MONTHS,D_MONTH-4,$pPositive,$pBifq,2*$BifWORD
 db String1,"3",$pPositive,$pBifq,2*$BifLEFT,$pCat,D_YEAR-2,String1
 db "4",$pPositive,Zero,$pBifq,2*$BifRIGHT+128,$pCat,_RetB,_Jump
 db +97,Arg2-24,String1,"O",_Seq,+14,D_YEAR,Frag18,D_DAY-2,String1
 db "2",$pPositive,Zero,$pBifq,2*$BifRIGHT+128,$pAbut,_RetB,_Jump
 db +79,Arg2-24,String1,"S",_Seq,+27,D_YEAR,String1,"4",$pPositive
 db Zero,$pBifq,2*$BifRIGHT+128,D_MONTH-2,String1,"2",$pPositive
 db Zero,$pBifq,2*$BifRIGHT+128,$pAbut,D_DAY-2,String1,"2",$pPositive
 db Zero,$pBifq,2*$BifRIGHT+128,$pAbut,_RetB,_Jump,+48,Arg2-24
 db String1,"U",_Seq,+33,D_MONTH,String1,"2",$pPositive,Zero
 db $pBifq,2*$BifRIGHT+128,String1,"/",$pAbut,D_DAY-2,String1
 db "2",$pPositive,Zero,$pBifq,2*$BifRIGHT+128,$pAbut,String1
 db "/",$pAbut,D_YEAR-2,String1,"2",$pPositive,Zero,$pBifq,2*$BifRIGHT+128
 db $pAbut,_RetB,_Jump,+11,?WEEKDAYS,One,D_BASE-4,String1,"7"
 db $pRemainder,$pAdd,$pBifq,2*$BifWORD,_RetB
;õ bf\TIME.inc
BIFTIME db 13*8+3,String2,"18",Frag28,Arg2-34,_Exists,$pNot,_Then
 db +5,?CLAUSELOCAL,T_OPTION-2,TIMEFORMAT,_RetB,T_OPTION,String
 db 3,"ERO",$pBifq,2*$BifPOS,Zero,_Gt,+7,T_OPTION,String2,"29"
 db $pPositive,CONFIG_RAISE40,Frag20,Zero,HH-Tgt,Zero,MM-Tgt
 db Zero,SS_-Tgt,Zero,HOURADJUST-Tgt,T_INOPTION,String1,"C",_Seq
 db +37,INVALUE,$pParse,00h,String1,":",02ah,HH-2,One,03ah,String1
 db "2",03ah,MM-2,022h,XX-2,01ah,HH,String2,"12",_Eq,+3,Zero
 db HH-Tgt,XX,String2,"pm",_Seq,+5,String2,"12",HOURADJUST-Tgt
 db _Jump,+50,T_INOPTION,String1,"H",_Seq,+5,INVALUE,HH-Tgt,_Jump
 db +41,T_INOPTION,String1,"L",_Seq,00h,T_INOPTION-2,String1
 db "N",_Seq,00h,$pOr,_Then,+17,INVALUE,$pParse,00h,String1,":"
 db 02ah,HH-2,String1,":",02ah,MM-2,022h,SS_-2,01ah,_Jump,+12
 db T_INOPTION,String1,"M",_Seq,+5,INVALUE,MM-Tgt,_Jump,+3,INVALUE
 db SS_-Tgt,HH,Frag4,String1,"N",Frag6,HH,HOURADJUST-2,$pAdd
 db HH-Tgt,HH,String2,"60",$pMultiply,MM-2,$pAdd,String2,"60"
 db $pMultiply,SS_-2,$pAdd,String,7,"1000000",$pMultiply,$pBifq
 db 2*$BifTRUNC,T_MICRO-Tgt,T_MICRO,Zero,_Lt,00h,T_MICRO-2,String2
 db "24",String,4,"3600",$pMultiply,String,7,"1000000",$pMultiply
 db _Gt,00h,$pOr,_Then,+8,INVALUE,T_INOPTION-2,String2,"19",$pPositive
 db CONFIG_RAISE40,T_MICRO,T_INOPTION-2,TIMEFORMAT,Frag16,TIMEFORMAT
 db _RetB

TIMEFORMAT$$ db 5*8+2,Arg1-16,TIME2DATE,$pParse,02h,022h,ParseDot
 db ParseDot,ParseDot,T_HOUR-2,T_MINUTE-2,T_SECOND-2,T_MICROSECOND-2
 db ParseDot,01ah,Arg2-16,String1,"C",_Seq,+59,T_HOUR,String2
 db "12",_Gt,+14,T_HOUR,String2,"12",$pSubtract,Frag2,String2
 db "pm",$pAbut,_RetB,_Jump,+38,T_HOUR,String2,"12",_Eq,+9,Frag1
 db String2,"pm",$pAbut,_RetB,_Jump,+24,T_HOUR,Zero,_Gt,+10,T_HOUR
 db Frag2,String2,"am",$pAbut,_RetB,_Jump,+11,T_HOUR,Zero,_Eq
 db +7,Frag1,String2,"am",$pAbut,_RetB,_Jump,+134,Arg2-16,String1
 db "E",_Seq,00h,Arg2-16-2,String1,"R",_Seq,00h,$pOr,_Then,+31
 db ?STARTTIME,Null,_Seq,+5,?CLAUSETIME,?STARTTIME+Tgts,Zero
 db _RetB,?CLAUSETIME,?STARTTIME,$pSubtract,TF_OUTPUT-Tgt,Arg2-16
 db String1,"R",_Seq,+3,?CLAUSETIME,?STARTTIME+Tgts,TF_OUTPUT
 db String,4,"1E-6",$pMultiply,_RetB,_Jump,+91,Arg2-16,String1
 db "H",_Seq,+5,T_HOUR,_RetB,_Jump,+82,Arg2-16,String1,"L",_Seq
 db +16,Frag23,String1,".",$pAbut,T_MICROSECOND-2,String1,"6"
 db $pPositive,Zero,$pBifq,2*$BifRIGHT+128,$pAbut,_RetB,_Jump
 db +62,Arg2-16,String1,"M",_Seq,+11,String2,"60",T_HOUR-2,$pMultiply
 db T_MINUTE-2,$pAdd,_RetB,_Jump,+47,Arg2-16,String1,"N",_Seq
 db +5,Frag23,_RetB,_Jump,+38,Arg2-16,String1,"O",_Seq,+16,?CLAUSELOCAL
 db ?CLAUSETIME,$pSubtract,String,4,"1E+6",$pDivide,$pBifq,2*$BifTRUNC
 db _RetB,_Jump,+18,String,4,"3600",T_HOUR-2,$pMultiply,String2
 db "60",T_MINUTE-4,$pMultiply,$pAdd,T_SECOND-2,$pAdd,_RetB

DOS_TIME$$ db 8*8+1,String,4,"1980",TV-2,String1,"7",$pPositive
 db One,$pBifq,2*$BifSUBSTR+128,$pBifq,2*$BifC2D,$pAdd,DT_YEAR-Tgt
 db TV,String1,"6",$pPositive,One,$pBifq,2*$BifSUBSTR+128,$pBifq
 db 2*$BifC2D,DT_MONTH-Tgt,TV,String1,"5",$pPositive,One,$pBifq
 db 2*$BifSUBSTR+128,$pBifq,2*$BifC2D,DT_DAY-Tgt,String,42,
"0 31 59 90 120 151 181 212 243 273 304 334",DT_MONTH-2,$pPositive
 db $pBifq,2*$BifWORD,Frag17,Frag25,DT_BASEDAYS,String,5,"864E8"
 db $pMultiply,String,4,"36E8",TV-4,String1,"4",$pPositive,One
 db $pBifq,2*$BifSUBSTR+128,$pBifq,2*$BifC2D,$pMultiply,$pAdd
 db String,3,"6E7",TV-4,String1,"3",$pPositive,One,$pBifq,2*$BifSUBSTR+128
 db $pBifq,2*$BifC2D,$pMultiply,$pAdd,String,3,"1E6",TV-4,String1
 db "2",$pPositive,One,$pBifq,2*$BifSUBSTR+128,$pBifq,2*$BifC2D
 db $pMultiply,$pAdd,String,3,"1E4",TV-4,One,$pBifq,2*$BifLEFT
 db $pBifq,2*$BifC2D,$pMultiply,$pAdd,_RetB

B4VALUE1 db 0*8+1,Arg1-4,$pInterpret,_RetBc

B4VALUE2 db 1*8+2,Arg1-8,$pBifq,2*$BifVALUE,B4V-Tgt,Arg2-8,?OUTCOME+Tgts
 db Arg1-8,String,12,"= 'QUEUED'()",$pAbut,$pInterpret,B4V,_RetB

B4DROP db 0*8+1,String,4,"DROP",Arg1-4-2,$pCat,$pInterpret,_RetBc

B4EXPOSE db 0*8+1,String,16,"PROCEDURE EXPOSE",Arg1-4-2,$pCat
 db $pInterpret,_RetBc

STREAMQUALIFY db 5*8+0,?STREAM,Q_T-Tgt,Q_T,String1,"2",$pPositive
 db One,$pBifq,2*$BifSUBSTR+128,String1,":",_Seq,+13,Q_T,$pParse
 db 00h,String1,":",02ah,Q_DRIVE-2,022h,Q_T-2,01ah,_Jump,+5,Null
 db One,CONFIG_STREAM_QUALIFIED,Q_DRIVE-Tgt,String1,"\",Frag26
 db Q_PATH,One,$pBifq,2*$BifLEFT,String1,"\",_Sne,+15,String1
 db "\",Q_DRIVE-2,String1,"2",$pPositive,CONFIG_STREAM_QUALIFIED
 db $pAbut,String1,"\",$pAbut,Q_PATH-2,$pAbut,Q_PATH-Tgt,Q_DRIVE
 db String1,":",$pAbut,Q_PATH-2,$pAbut,Q_NAME-2,$pAbut,CONFIG_UPPER
 db Q_T-Tgt,Q_T,String1,"3",$pPositive,CONFIG_STREAM_QUALIFIED
 db Q_T-Tgt,_RetBc

PATHQUALIFY db 13*8+1,Arg1-30,CONFIG_UPPER,PQ_T-Tgt,Zero,PQ_HAVEENV-Tgt
 db Null,PQ_DRIVE-Tgt,PQ_T,String1,"2",$pPositive,One,$pBifq
 db 2*$BifSUBSTR+128,String1,":",_Seq,+11,PQ_T,$pParse,00h,String1
 db ":",02ah,PQ_DRIVE-2,022h,PQ_T-2,01ah,String1,"\",Frag26,PQ_NAME
 db $pParse,00h,String1,".",02ah,PQ_NAME-2,022h,PQ_EXTEN-2,01ah
 db Zero,PQ_EXISTS-Tgt,Null,One,CONFIG_STREAM_QUALIFIED,PQ_LETTER-Tgt
 db String1,"\",PQ_LETTER-2,String1,"2",$pPositive,CONFIG_STREAM_QUALIFIED
 db $pAbut,PQ_PREFIX-Tgt,PQ_PATH,PQ_DIR-Tgt,$pRepEver
 dw $+189
db PQ_DRIVE-10,Null,_Seq,00h,PQ_DRIVE-12,PQ_LETTER-14,_Seq,00h
 db $pOr,_Then,+105,PQ_DIR-10,PQ_T-Tgt-10,PQ_DIR-10,One,$pBifq
 db 2*$BifLEFT,String1,"\",_Sne,+8,PQ_PREFIX-10,String1,"\",$pAbut
 db PQ_DIR-12,$pAbut,PQ_T-Tgt-10,PQ_T-10,PQ_PATH-12,$pLength
 db $pBifq,2*$BifRIGHT,PQ_PATH-12,_Seq,+80,PQ_LETTER-10,String1
 db ":",$pAbut,PQ_T-12,$pAbut,PQ_NAME-12,$pAbut,String1,".",$pAbut
 db PQ_T-Tgt-10,PQ_EXTEN-10,Null,_Sne,+13,PQ_T-10,PQ_EXTEN-12
 db $pAbut,PQ_R-Tgt-10,PQ_R-10,String1,"4",$pPositive,CONFIG_STREAM_QUALIFIED
 db PQ_EXISTS-Tgt-10,_Jump,+48,One,$pNumber,String1,"5",$pTo
 db $pControlVar,PQ_J-20
 dw $+40
db PQ_T-20,String,19,"COM EXE REX CMD BAT",PQ_J-24,$pBifq,2*$BifWORD
 db $pAbut,PQ_R-Tgt-20,PQ_R-20,String1,"4",$pPositive,CONFIG_STREAM_QUALIFIED
 db PQ_EXISTS-Tgt-20,PQ_EXISTS-20,_Then,+2,$pLeave,_IterCV,PQ_EXISTS-10
 db _Then,+2,$pLeave,PQ_HAVEENV-10,Zero,_Eq,+18,One,PQ_HAVEENV-Tgt-10
 db String,4,"PATH",Null,String,3,"DOS",$pBifq,2*$BifVALUE+1
 db PQ_REST-Tgt-10,PQ_REST-10,$pParse,00h,String1,";",02ah,PQ_DIR-12
 db 022h,PQ_REST-12,01ah,PQ_DIR-10,Null,_Seq,+2,$pLeave,PQ_DIR-10
 db String1,"\",$pAbut,PQ_DIR-Tgt-10,PQ_DIR-10,String1,"2",$pPositive
 db One,$pBifq,2*$BifSUBSTR+128,String1,":",_Seq,+20,PQ_DIR-10
 db $pParse,00h,String1,":",02ah,PQ_LETTER-12,022h,PQ_DIR-12
 db 01ah,String1,"\",PQ_LETTER-12,String1,"2",$pPositive,
CONFIG_STREAM_QUALIFIED,$pAbut,PQ_PREFIX-Tgt-10,$pIterate,PQ_EXISTS
 db Zero,_Eq,+3,Null,PQ_R-Tgt,PQ_R,String1,"3",$pPositive,
CONFIG_STREAM_QUALIFIED,PQ_R-Tgt,_RetBc

LINESPLIT db 3*8+1,LS_T,$pParse,00h,022h,LS_N-2,LS_P-2,01ah,LS_P
 db $pBifq,2*$BifSTRIP,$pCommand,LS_N,_RetB

COMMANDWRAP db 1*8+1,Arg1-6,CW_T-Tgt,CW_T,$pLength,String1,"4"
 db $pAdd,$pBifq,2*$BifD2C,String,3,"/C ",$pAbut,Arg1-6-2,$pAbut
 db String,1,0dh,$pAbut,_RetB
RoutineBase$ equ $
 dw ARITHOP$$
 dw PREPARE$$
 dw _MULTIPLY$$
 dw _DIVTYPE$$
 dw _POWER$$
 dw _ADDSUBCOMP$$
 dw _POSTOP$$
 dw _FLOATING$$
 dw TIME2DATE$$
 dw TIME2DATE2$$
 dw LEAP$$
 dw RERADIX$$
 dw DOS_TIME$$
 dw DATEFORMAT$$
 dw TIMEFORMAT$$
FragsBase$ equ $
 dw Frag1$$
 dw Frag2$$
 dw Frag3$$
 dw Frag4$$
 dw Frag5$$
 dw Frag6$$
 dw Frag7$$
 dw Frag8$$
 dw Frag9$$
 dw Frag10$$
 dw Frag11$$
 dw Frag12$$
 dw Frag13$$
 dw Frag14$$
 dw Frag15$$
 dw Frag16$$
 dw Frag17$$
 dw Frag18$$
 dw Frag19$$
 dw Frag20$$
 dw Frag21$$
 dw Frag22$$
 dw Frag23$$
 dw Frag24$$
 dw Frag25$$
 dw Frag26$$
 dw Frag27$$
 dw Frag28$$
;õ bf\Bcodes.inc
Tgt equ 86ú$Locals equ 256-Tgt
Arg1 equ 2
Arg2 equ 4
Arg3 equ 6
Arg4 equ 8
Arg5 equ 10
; LocalVars of ARITHOPúNUMBER1 equ -58úNUMBER2 equ -56úOPERATOR equ -54
DIGITS equ -52úTT equ -12úSIGN1 equ -14úMANTISSA1 equ -4úEXPONENT1 equ -16
SIGN2 equ -18úMANTISSA2 equ -20úEXPONENT2 equ -22úNUMBER3 equ -24
MANTISSA3 equ -26úEXPONENT3 equ -8úZZ equ -2úA_X equ -10úA_Y equ -28
SIGN3 equ -30úNOWDIGITS equ -32úALIGN1 equ -34úALIGN2 equ -36
SIGDIGITS equ -6úAA equ -38úINTDIGITS equ -40úRHS equ -42
; LocalVars of PREPAREúNUMBER equ -22úP_DIGITS equ -20úMANTISSA equ -2
EXPONENT equ -8úSIGN equ -4úP_P equ -6úP_Q equ -10úJJ equ -12
P_T equ -14
; LocalVars of _POSTOP
; LocalVars of _FLOATING
; LocalVars of _ADDSUBCOMP
; LocalVars of _MULTIPLY
; LocalVars of _DIVTYPE
; LocalVars of _POWER
; LocalVars of TIME2DATE
; LocalVars of TIME2DATE2úY_TIME equ -26úY_SECOND equ -2úY_MICROSECOND equ -4
Y_MINUTE equ -6úY_HOUR equ -8úY_DAY equ -10úY_BASEDAYS equ -12
Y_YEAR equ -14úY_YEARDAYS equ -16úY_DAYS equ -18úY_MONTH equ -20
Y_THISMONTH equ -22
; LocalVars of LEAP
; LocalVars of RERADIXúRR_SUBJECT equ -2úRR_FROMRADIX equ -8
RR_TORADIX equ -4úRR_INTEGER equ -6úRR_J equ -10úRR_R equ -12
; LocalVars of BIFABBREVúSUBJECT equ -18úSUBJ equ -16úLENGTH_ equ -2
COND1 equ -4úCOND2 equ -6úCOND3 equ -8
; LocalVars of BIFCENTERúSTRING equ -14úC_LENGTH equ -12úPAD equ -2
TRIM equ -4
; LocalVars of BIFCHANGESTRúOUTPUT equ -2úPOSITION equ -4úFOUNDPOS equ -6
; LocalVars of BIFCOMPAREúSTR1 equ -18úSTR2 equ -16úC_PAD equ -2
CO_LENGTH equ -4úC_I equ -6
; LocalVars of BIFCOUNTSTRúC_OUTPUT equ -2úC_POSITION equ -4
; LocalVars of BIFDELSTRúD_STRING equ -18úNUM equ -16úLEN equ -2
D_OUTPUT equ -4
; LocalVars of BIFDELWORDúDW_STRING equ -18úDW_NUM equ -16úDW_LEN equ -2
ENDLEFT equ -6úDW_OUTPUT equ -8úBEGINRIGHT equ -4
; LocalVars of BIFINSERTúNEW equ -20úTARGET equ -18úI_NUM equ -6
I_LENGTH equ -2úI_PAD equ -4
; LocalVars of BIFLASTPOSúNEEDLE equ -16úHAYSTACK equ -14úSTART equ -2
NEEDLELENGTH equ -4úII equ -6
; LocalVars of BIFOVERLAYúO_NEW equ -20úO_TARGET equ -18úO_NUM equ -6
O_LENGTH equ -2úO_PAD equ -4
; LocalVars of BIFPOSúP_NEEDLE equ -18úP_HAYSTACK equ -16úP_START equ -2
P_I equ -4úO_HAYSTACK equ -6
; LocalVars of BIFRIGHTúR_STRING equ -14úR_LENGTH equ -12úR_PAD equ -2
R_TRIM equ -4
; LocalVars of BIFSPACEúS_STRING equ -18úS_NUM equ -4úS_PAD equ -2
PADDING equ -6úS_OUTPUT equ -8úS_I equ -10
; LocalVars of BIFSTRIPúST_STRING equ -12úOPTION_ equ -2úUNWANTED equ -4
; LocalVars of BIFSUBWORDúSW_STRING equ -18úSW_NUM equ -16úS_LENGTH equ -2
S_START equ -6úEND_ equ -4úSW_OUTPUT equ -8
; LocalVars of BIFTRANSLATEúT_STRING equ -24úTABLEI equ -4úTABLEO equ -2
T_PAD equ -6úT_OUTPUT equ -8úT_J equ -10úT_C equ -12úKK equ -14
; LocalVars of BIFVERIFYúV_STRING equ -32úREFERENCE equ -30
V_OPTION equ -12úV_START equ -2úLAST equ -4úV_I equ -6úV_T equ -8
; LocalVars of BIFWORD
; LocalVars of BIFWORDINDEXúW_STRING equ -12úW_NUM equ -10úW_START equ -2
COUNT equ -4
; LocalVars of BIFWORDLENGTH
; LocalVars of BIFWORDPOSúPHRASE equ -18úWP_STRING equ -16úR_START equ -2
PHRASEWORDS equ -4úSTRINGWORDS equ -6úWORDNUMBER equ -8
; LocalVars of BIFWORDSúS_PART equ -6úS_COUNT equ -2
; LocalVars of BIFFORMATúBEFORE equ -12úAFTER equ -14úEXPP equ -16
EXPT equ -18úF_NUMBER equ -22úF_MANTISSA equ -2úF_EXPONENT equ -8
F_SIGN equ -24úBEFO equ -26úAFTE equ -28úPOINT equ -10úSHOWEXP equ -30
AFTERS equ -32úF_R equ -4úMANTLEN equ -34úTRIGGERED equ -6úF_Z equ -20
DIGIT equ -36úEXPART equ -38úSIGNEXP equ -40
; LocalVars of BIFMAXúNEXT equ -2úMAX equ -4úI_M equ -6
; LocalVars of BIFMINú_NEXT equ -2úMIN equ -4úI_N equ -6
; LocalVars of BIFTRUNCúT_NUMBER equ -12úT_NUM equ -2úT_INTEGER equ -4
T_T equ -6
; LocalVars of BIFERRORTEXTúMSGCODE equ -2úE_OPTION equ -12
MAJOR equ -4úMINOR equ -6
; LocalVars of BIFB2XúB_STRING equ -2
; LocalVars of BIFBITANDúSTRING1 equ -24úSTRING2 equ -2úB_T equ -4
B_R equ -6úB_J equ -8úB1 equ -10úB2 equ -12
; LocalVars of BIFC2DúC_MAX equ -2úSIZE_ equ -6úC_T equ -4úC_SIGN equ -8
; LocalVars of BIFC2X
; LocalVars of BIFD2CúD_SUBJECT equ -2úD_R equ -4úD_LENGTH equ -6
DC_OUTPUT equ -8
; LocalVars of BIFD2XúX_SUBJECT equ -2úX_R equ -4
; LocalVars of BIFX2BúXB_SUBJECT equ -8
; LocalVars of BIFX2CúXC_SUBJECT equ -8úXC_R equ -2úXC_LENGTH equ -4
; LocalVars of BIFX2DúXD_MAX equ -2úXD_SUBJECT equ -4úXD_R equ -6
SIGNBIT equ -8
; LocalVars of BIFCHARINúC_COUNT equ -2úMODE equ -4úC_R equ -6
; LocalVars of BIFCHAROUTúC_STRING equ -2úO_MODE equ -4úSTRIDE equ -6
RESIDUE equ -8úCURSOR equ -10úPIECE equ -12
; LocalVars of BIFCHARSúH_OPTION equ -2
; LocalVars of BIFLINEINúL_COUNT equ -2
; LocalVars of BIFLINEOUT
; LocalVars of BIFLINESúN_OPTION equ -2
; LocalVars of BIFQUALIFY
; LocalVars of BIFSTREAMúOPERATION equ -2
; LocalVars of BIFDATEúD_OPTION equ -2úVALUE equ -10úINOPTION equ -12
LOGIC equ -20úDAY equ -16úMONTHIS equ -22úYEAR equ -4úMONTH equ -14
YY equ -24úYEARNOW equ -26úDAYS equ -6úBASEDAYS equ -8úMICRO equ -18
; LocalVars of DATEFORMATúD_YEAR equ -6úD_MONTH equ -2úD_DAY equ -4
D_HOUR equ -8úD_MINUTE equ -10úD_SECOND equ -12úD_MICROSECOND equ -14
D_BASE equ -16úD_DAYS equ -18
; LocalVars of BIFTIMEúT_OPTION equ -2úINVALUE equ -10úT_INOPTION equ -12
HH equ -6úMM equ -16úSS_ equ -4úHOURADJUST equ -8úXX equ -14
T_MICRO equ -18
; LocalVars of TIMEFORMATúT_HOUR equ -6úT_MINUTE equ -2úT_SECOND equ -4
T_MICROSECOND equ -8úTF_OUTPUT equ -10
; LocalVars of DOS_TIMEúTV equ -18úDT_YEAR equ -4úDT_MONTH equ -14
DT_DAY equ -16úDT_DAYS equ -6úDT_BASEDAYS equ -8
; LocalVars of B4VALUE1
; LocalVars of B4VALUE2úB4V equ -2
; LocalVars of B4DROP
; LocalVars of B4EXPOSE
; LocalVars of STREAMQUALIFYúQ_T equ -2úQ_DRIVE equ -10úQ_J equ -4
Q_NAME equ -6úQ_PATH equ -8
; LocalVars of PATHQUALIFYúPQ_T equ -2úPQ_HAVEENV equ -12úPQ_DRIVE equ -10
PQ_J equ -4úPQ_NAME equ -6úPQ_PATH equ -8úPQ_EXTEN equ -14úPQ_EXISTS equ -16
PQ_LETTER equ -18úPQ_PREFIX equ -20úPQ_DIR equ -22úPQ_R equ -24
PQ_REST equ -26
; LocalVars of LINESPLITúLS_T equ -8úLS_N equ -2úLS_P equ -4
; LocalVars of COMMANDWRAPúCW_T equ -2
ARITHOP equ $RoutineBase+0
PREPARE equ $RoutineBase+2
_MULTIPLY equ $RoutineBase+4
_DIVTYPE equ $RoutineBase+6
_POWER equ $RoutineBase+8
_ADDSUBCOMP equ $RoutineBase+10
_POSTOP equ $RoutineBase+12
_FLOATING equ $RoutineBase+14
TIME2DATE equ $RoutineBase+16
TIME2DATE2 equ $RoutineBase+18
LEAP equ $RoutineBase+20
RERADIX equ $RoutineBase+22
DOS_TIME equ $RoutineBase+24
DATEFORMAT equ $RoutineBase+26
TIMEFORMAT equ $RoutineBase+28

Frag1 equ $BPcodesCeil+0
Frag2 equ $BPcodesCeil+2
Frag3 equ $BPcodesCeil+4
Frag4 equ $BPcodesCeil+6
Frag5 equ $BPcodesCeil+8
Frag6 equ $BPcodesCeil+10
Frag7 equ $BPcodesCeil+12
Frag8 equ $BPcodesCeil+14
Frag9 equ $BPcodesCeil+16
Frag10 equ $BPcodesCeil+18
Frag11 equ $BPcodesCeil+20
Frag12 equ $BPcodesCeil+22
Frag13 equ $BPcodesCeil+24
Frag14 equ $BPcodesCeil+26
Frag15 equ $BPcodesCeil+28
Frag16 equ $BPcodesCeil+30
Frag17 equ $BPcodesCeil+32
Frag18 equ $BPcodesCeil+34
Frag19 equ $BPcodesCeil+36
Frag20 equ $BPcodesCeil+38
Frag21 equ $BPcodesCeil+40
Frag22 equ $BPcodesCeil+42
Frag23 equ $BPcodesCeil+44
Frag24 equ $BPcodesCeil+46
Frag25 equ $BPcodesCeil+48
Frag26 equ $BPcodesCeil+50
Frag27 equ $BPcodesCeil+52
Frag28 equ $BPcodesCeil+54
