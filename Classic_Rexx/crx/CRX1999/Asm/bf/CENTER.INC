BIFCENTER db 4*8+3,Frag22,_Gt,+12,STRING,TRIM-2,String1,"2",$pIntDivide
 db One,$pAdd,C_LENGTH-4,$pBifq,2*$BifSUBSTR+128,_RetB,STRING
 db PAD-2,C_LENGTH-4,$pBifq,2*$BifCOPIES,TRIM-4,$pNegate,String1
 db "2",$pIntDivide,One,$pAdd,$pBifq,2*$BifOVERLAY+128,_RetB
