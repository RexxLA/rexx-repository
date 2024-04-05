BIFCHAROUT db 6*8+3,Frag19,Arg2-20,_Exists,$pNot,Arg3-20-2,_Exists
 db $pNot,$pAnd,_Then,+6,CONFIG_STREAM_CLOSE,?RESPONSE,Frag5
 db Zero,_RetB,Arg3-20,_Exists,_Then,+31,String,7,"CHAROUT",Arg3-20-2
 db CONFIG_STREAM_POSITION,?RESPONSE,Frag5,?RESPONSE,One,$pBifq
 db 2*$BifLEFT,String1,"R",_Seq,+10,String1,"3",$pPositive,Arg3-20-2
 db String2,"41",$pPositive,CONFIG_RAISE40,Arg2-20,_Exists,$pNot
 db Arg2-20-2,Null,_Seq,00h,$pOr,_Then,+10,String,4,"NULL",
CONFIG_STREAM_CHAROUT,Zero,_RetB,Arg2-20,C_STRING-Tgt,CONFIG_STREAM_QUERY
 db ?OUTCOME,O_MODE-Tgt,O_MODE,String1,"B",_Seq,+16,C_STRING
 db CONFIG_C2B,?OUTCOME,C_STRING-Tgt,String1,"8",STRIDE-Tgt,C_STRING
 db $pLength,String1,"8",$pDivide,RESIDUE-Tgt,_Jump,+6,One,STRIDE-Tgt
 db C_STRING,$pLength,RESIDUE-Tgt,One,CURSOR-Tgt,$pRepEver
 dw $+35
db RESIDUE-10,Zero,_Gt,00h,$pWhile,C_STRING-10,CURSOR-12,STRIDE-14
 db $pBifq,2*$BifSUBSTR+128,PIECE-Tgt-10,CURSOR-10,STRIDE-12
 db $pAdd,CURSOR-Tgt-10,PIECE-10,CONFIG_STREAM_CHAROUT,?RESPONSE
 db One,$pBifq,2*$BifLEFT,String1,"N",_Sne,+4,Frag21,RESIDUE-10
 db _RetB,RESIDUE-10,One,$pSubtract,RESIDUE-Tgt-10,$pIterate
 db Zero,_RetB
