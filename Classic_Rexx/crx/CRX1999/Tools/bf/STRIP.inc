BIFSTRIP db 3*8+3,Arg2-14,_Exists,_Then,+5,Arg2-14,OPTION_-Tgt
 db _Jump,+4,String1,"B",OPTION_-Tgt,Arg3-14,_Exists,_Then,+5
 db Arg3-14,UNWANTED-Tgt,_Jump,+10,String,6,09h,0ah,0bh,0ch,0dh
 db 020h,UNWANTED-Tgt,OPTION_,String1,"L",_Seq,00h,OPTION_-2
 db String1,"B",_Seq,00h,$pOr,_Then,+28,$pRepEver
 dw $+26
db ST_STRING-10,Null,_Sne,00h,ST_STRING-12,One,$pBifq,2*$BifLEFT
 db UNWANTED-14,$pBifq,2*$BifPOS,Zero,_Gt,00h,$pAnd,$pWhile,ST_STRING-10
 db String1,"2",$pPositive,$pBifq,2*$BifSUBSTR,ST_STRING-Tgt-10
 db $pIterate,OPTION_,String1,"T",_Seq,00h,OPTION_-2,String1
 db "B",_Seq,00h,$pOr,_Then,+29,$pRepEver
 dw $+27
db ST_STRING-10,Null,_Sne,00h,ST_STRING-12,One,$pBifq,2*$BifRIGHT
 db UNWANTED-14,$pBifq,2*$BifPOS,Zero,_Gt,00h,$pAnd,$pWhile,ST_STRING-10
 db ST_STRING-12,$pLength,One,$pSubtract,$pBifq,2*$BifLEFT,ST_STRING-Tgt-10
 db $pIterate,ST_STRING,_RetB
