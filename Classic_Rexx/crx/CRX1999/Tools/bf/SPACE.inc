BIFSPACE db 6*8+3,Arg2-20,_Exists,_Then,+5,Arg2-20,S_NUM-Tgt
 db _Jump,+3,One,S_NUM-Tgt,Arg3-20,_Exists,_Then,+5,Arg3-20,S_PAD-Tgt
 db _Jump,+4,String1," ",S_PAD-Tgt,S_PAD,S_NUM-2,$pBifq,2*$BifCOPIES
 db PADDING-Tgt,S_STRING,One,One,$pBifq,2*$BifSUBWORD+128,S_OUTPUT-Tgt
 db String1,"2",$pNumber,S_STRING-10,$pBifq,2*$BifWORDS,$pTo
 db $pControlVar,S_I-10
 dw $+13
db S_OUTPUT-10,PADDING-12,$pAbut,S_STRING-12,S_I-14,One,$pBifq
 db 2*$BifSUBWORD+128,$pAbut,S_OUTPUT-Tgt-10,_IterCV,S_OUTPUT
 db _RetB
