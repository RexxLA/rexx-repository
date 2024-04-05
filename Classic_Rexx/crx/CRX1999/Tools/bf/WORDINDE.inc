BIFWORDINDEX db 4*8+2,One,W_START-Tgt,Zero,COUNT-Tgt,$pRepEver
 dw $+56
db W_STRING-10,String,6,09h,0ah,0bh,0ch,0dh,020h,String1,"N"
 db W_START-16,$pBifq,2*$BifVERIFY+1,W_START-Tgt-10,W_START-10
 db Zero,_Eq,+3,Zero,_RetB,COUNT-10,One,$pAdd,COUNT-Tgt-10,COUNT-10
 db W_NUM-12,_Eq,+2,$pLeave,W_STRING-10,String,6,09h,0ah,0bh
 db 0ch,0dh,020h,String1,"M",W_START-16,One,$pAdd,$pBifq,2*$BifVERIFY+1
 db W_START-Tgt-10,W_START-10,Zero,_Eq,+3,Zero,_RetB,$pIterate
 db W_START,_RetB
