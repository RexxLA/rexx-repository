BIFTRUNC db 4*8+2,Arg2-14,_Exists,_Then,+5,Arg2-14,T_NUM-Tgt
 db _Jump,+3,Zero,T_NUM-Tgt,String2,"10",T_NUM-2,$pPower,T_NUMBER-2
 db $pMultiply,One,$pIntDivide,T_INTEGER-Tgt,T_NUM,Zero,_Eq,+3
 db T_INTEGER,_RetB,T_INTEGER,$pLength,T_NUM-2,$pSubtract,T_T-Tgt
 db T_T,Zero,_Le,+13,String2,"0.",T_INTEGER-2,T_NUM-4,Zero,$pBifq
 db 2*$BifRIGHT+128,$pAbut,_RetB,_Jump,+8,String1,".",T_INTEGER-2
 db T_T-4,$pBifq,2*$BifINSERT+128,_RetB
