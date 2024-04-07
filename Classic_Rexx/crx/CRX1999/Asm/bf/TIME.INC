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
