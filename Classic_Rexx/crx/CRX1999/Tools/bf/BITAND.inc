BIFBITAND db 9*8+3,Arg2-26,_Exists,_Then,+5,Arg2-26,STRING2-Tgt
 db _Jump,+3,Null,STRING2-Tgt,Arg3-26,_Exists,_Then,+23,STRING1
 db $pLength,STRING2-2,$pLength,_Gt,+10,STRING2,STRING1-2,$pLength
 db Arg3-26-4,$pBifq,2*$BifLEFT+128,STRING2-Tgt,_Jump,+8,STRING1
 db STRING2-2,$pLength,Arg3-26-4,$pBifq,2*$BifLEFT+128,STRING1-Tgt
 db STRING1,CONFIG_C2B,?OUTCOME,STRING1-Tgt,STRING2,CONFIG_C2B
 db ?OUTCOME,STRING2-Tgt,STRING1,$pLength,STRING2-2,$pLength
 db _Lt,+7,STRING1,B_T-Tgt,STRING2,STRING1-Tgt,B_T,STRING2-Tgt
 db Null,B_R-Tgt,One,$pNumber,STRING2-10,$pLength,$pTo,$pControlVar
 db B_J-10
 dw $+67
db STRING1-10,B_J-12,One,$pBifq,2*$BifSUBSTR+128,B1-Tgt-10,STRING2-10
 db B_J-12,One,$pBifq,2*$BifSUBSTR+128,B2-Tgt-10,?BIF,String
 db 6,"BITAND",_Seq,+7,B1-10,B2-12,$pAnd,B1-Tgt-10,_Jump,+32
 db ?BIF,String,5,"BITOR",_Seq,+7,B1-10,B2-12,$pOr,B1-Tgt-10
 db _Jump,+16,?BIF,String,6,"BITXOR",_Seq,+5,B1-10,B2-12,$pXor
 db B1-Tgt-10,B_R-10,B1-12,$pAbut,B_R-Tgt-10,_IterCV,B_R,STRING1-2
 db STRING1-4,$pLength,STRING2-6,$pLength,$pSubtract,$pBifq,2*$BifRIGHT
 db $pAbut,B_R-Tgt,B_R,CONFIG_B2C,?OUTCOME,_RetB
