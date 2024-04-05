BIFINSERT db 5*8+5,Arg3-22,_Exists,_Then,+5,Arg3-22,I_NUM-Tgt
 db _Jump,+3,Zero,I_NUM-Tgt,Frag27,I_PAD-4,$pBifq,2*$BifLEFT+128
 db NEW-2,I_LENGTH-4,I_PAD-6,$pBifq,2*$BifLEFT+128,$pAbut,TARGET-2
 db I_NUM-4,One,$pAdd,$pBifq,2*$BifSUBSTR,$pAbut,_RetB
