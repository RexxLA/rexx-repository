BIFOVERLAY db 5*8+5,Arg3-22,_Exists,_Then,+5,Arg3-22,O_NUM-Tgt
 db _Jump,+3,One,O_NUM-Tgt,Frag27,One,$pSubtract,O_PAD-4,$pBifq
 db 2*$BifLEFT+128,O_NEW-2,O_LENGTH-4,O_PAD-6,$pBifq,2*$BifLEFT+128
 db $pAbut,O_TARGET-2,O_NUM-4,O_LENGTH-6,$pAdd,$pBifq,2*$BifSUBSTR
 db $pAbut,_RetB
