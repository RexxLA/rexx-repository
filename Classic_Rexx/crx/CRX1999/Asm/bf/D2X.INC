BIFD2X db 2*8+2,String,3,"999",$pNumeric,00h,Arg1-10,$pBifq,2*$BifABS
 db X_SUBJECT-Tgt,X_SUBJECT,String2,"10",String2,"16",RERADIX
 db X_R-Tgt,Arg1-10,Zero,_Lt,+19,String2,"16",X_R-2,$pLength
 db $pPower,X_SUBJECT-2,$pSubtract,X_SUBJECT-Tgt,X_SUBJECT,String2
 db "10",String2,"16",RERADIX,X_R-Tgt,Arg2-10,_Exists,$pNot,_Then
 db +3,X_R,_RetB,Arg1-10,Zero,_Ge,+9,X_R,Arg2-10-2,Zero,$pBifq
 db 2*$BifRIGHT+128,_RetB,_Jump,+8,X_R,Arg2-10-2,String1,"F"
 db $pBifq,2*$BifRIGHT+128,_RetB
