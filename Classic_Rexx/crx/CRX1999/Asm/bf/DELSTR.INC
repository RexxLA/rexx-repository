BIFDELSTR db 6*8+3,Arg3-20,_Exists,_Then,+3,Arg3-20,LEN-Tgt,NUM
 db D_STRING-2,$pLength,_Gt,+3,D_STRING,_RetB,D_STRING,One,NUM-4
 db One,$pSubtract,$pBifq,2*$BifSUBSTR+128,D_OUTPUT-Tgt,Arg3-20
 db _Exists,_Then,+17,NUM,LEN-2,$pAdd,D_STRING-2,$pLength,_Le
 db +10,D_OUTPUT,D_STRING-2,NUM-4,LEN-6,$pAdd,$pBifq,2*$BifSUBSTR
 db $pAbut,D_OUTPUT-Tgt,D_OUTPUT,_RetB
