BIFPOS db 6*8+3,Frag13,$pLength,Zero,_Eq,+3,Zero,_RetB,P_START
 db $pNumber,O_HAYSTACK-10,$pLength,One,$pAdd,P_NEEDLE-12,$pLength
 db $pSubtract,$pTo,$pControlVar,P_I-10
 dw $+14
db P_HAYSTACK-10,P_I-12,P_NEEDLE-14,$pLength,$pBifq,2*$BifSUBSTR+128
 db P_NEEDLE-12,_Seq,+3,P_I-10,_RetB,_IterCV,Zero,_RetB
