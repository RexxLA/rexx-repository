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
