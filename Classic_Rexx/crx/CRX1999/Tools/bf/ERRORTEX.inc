BIFERRORTEXT db 23*8+2,Arg1-52,MSGCODE-Tgt,String1,"N",E_OPTION-Tgt
 db Arg2-52,_Exists,_Then,+3,Arg2-52,E_OPTION-Tgt,MSGCODE,One
 db $pIntDivide,MAJOR-Tgt,MSGCODE,MAJOR-2,$pSubtract,MINOR-Tgt
 db MAJOR,Zero,_Lt,00h,MAJOR-2,String2,"90",_Gt,00h,$pOr,MINOR-2
 db String2,".9",_Gt,00h,$pOr,String1,"E",MSGCODE-4,$pBifq,2*$BifPOS
 db Zero,_Gt,00h,$pOr,_Then,+7,Arg1-52,String2,"17",$pPositive
 db CONFIG_RAISE40,MINOR,Zero,_Gt,+8,MINOR,String1,"3",$pPositive
 db $pBifq,2*$BifSUBSTR,MINOR-Tgt,String,3,"256",MAJOR-2,$pMultiply
 db MINOR-2,$pAdd,CONFIG_MSG,_RetB
