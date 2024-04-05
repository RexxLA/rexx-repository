BIFSUBWORD db 6*8+3,Arg3-20,_Exists,_Then,+5,Arg3-20,S_LENGTH-Tgt
 db _Jump,+4,SW_STRING,$pLength,S_LENGTH-Tgt,S_LENGTH,Zero,_Eq
 db +3,Null,_RetB,SW_STRING,SW_NUM-2,$pBifq,2*$BifWORDINDEX,S_START-Tgt
 db S_START,Zero,_Eq,+3,Null,_RetB,SW_STRING,SW_NUM-2,S_LENGTH-4
 db $pAdd,$pBifq,2*$BifWORDINDEX,END_-Tgt,END_,Zero,_Eq,+6,SW_STRING
 db $pLength,One,$pAdd,END_-Tgt,SW_STRING,S_START-2,END_-4,S_START-6
 db $pSubtract,$pBifq,2*$BifSUBSTR+128,SW_OUTPUT-Tgt,$pRepEver
 dw $+34
db SW_OUTPUT-10,Null,_Sne,00h,$pWhile,SW_OUTPUT-10,One,$pBifq
 db 2*$BifRIGHT,String,6,09h,0ah,0bh,0ch,0dh,020h,$pBifq,2*$BifPOS
 db Zero,_Eq,+2,$pLeave,SW_OUTPUT-10,SW_OUTPUT-12,$pLength,One
 db $pSubtract,$pBifq,2*$BifLEFT,SW_OUTPUT-Tgt-10,$pIterate,SW_OUTPUT
 db _RetB
