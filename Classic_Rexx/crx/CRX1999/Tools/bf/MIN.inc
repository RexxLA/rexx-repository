BIFMIN db 3*8+0,Frag11,$pControlVar,I_N-10
 dw $+13
db I_N-10,$pBifq,2*$BifARG+128,_NEXT-Tgt-10,MIN-10,_NEXT-12,_Gt
 db +3,_NEXT-10,MIN-Tgt-10,_IterCV,MIN,_RetB
