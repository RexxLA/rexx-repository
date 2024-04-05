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
