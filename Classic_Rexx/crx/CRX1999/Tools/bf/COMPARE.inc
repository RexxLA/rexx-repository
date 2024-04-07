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
