BIFCOUNTSTR db 2*8+2,Zero,C_OUTPUT-Tgt,Arg1-10,Arg2-10-2,$pBifq
 db 2*$BifPOS,C_POSITION-Tgt,$pRepEver
 dw $+21
db C_POSITION-10,Zero,_Gt,00h,$pWhile,C_OUTPUT-10,One,$pAdd,C_OUTPUT-Tgt-10
 db Arg1-10-10,Arg2-10-12,C_POSITION-14,Arg1-10-16,$pLength,$pAdd
 db $pBifq,2*$BifPOS+128,C_POSITION-Tgt-10,$pIterate,C_OUTPUT
 db _RetB
