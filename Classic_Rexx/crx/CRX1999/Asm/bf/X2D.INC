BIFX2D db 4*8+2,String2,"10",Frag3,Arg1-14,XD_SUBJECT-Tgt,XD_SUBJECT
 db Null,_Seq,+3,Zero,_RetB,XD_SUBJECT,Zero,$pBifq,2*$BifSPACE+128
 db $pBifq,2*$BifTRANSLATE,XD_SUBJECT-Tgt,Arg2-14,_Exists,_Then
 db +15,Arg2-14,XD_SUBJECT-2,$pLength,One,$pAdd,$pMin,01h,XD_R-Tgt
 db XD_SUBJECT,XD_R-2,Zero,$pBifq,2*$BifRIGHT+128,XD_SUBJECT-Tgt
 db XD_SUBJECT,Null,_Seq,+3,Zero,_RetB,Arg2-14,_Exists,_Then
 db +10,XD_SUBJECT,$pBifq,2*$BifX2B,One,$pBifq,2*$BifLEFT,SIGNBIT-Tgt
 db _Jump,+3,Zero,SIGNBIT-Tgt,XD_SUBJECT,String2,"16",String2
 db "10",RERADIX,XD_R-Tgt,SIGNBIT,_Then,+11,XD_R,String1,"2"
 db String1,"4",Arg2-14-6,$pMultiply,$pPower,$pSubtract,XD_R-Tgt
 db XD_R,$pBifq,2*$BifABS,XD_MAX-2,_Gt,+7,XD_SUBJECT,String2
 db "35",$pPositive,CONFIG_RAISE40,XD_R,_RetB
