BIFCHARIN db 6*8+3,Frag19,Arg2-20,_Exists,_Then,+30,String,6
 db "CHARIN",Arg2-20-2,CONFIG_STREAM_POSITION,?RESPONSE,One,$pBifq
 db 2*$BifLEFT,String1,"R",_Seq,+10,String1,"2",$pPositive,Arg2-20-2
 db String2,"41",$pPositive,CONFIG_RAISE40,?RESPONSE,Frag5,Frag14
 db Zero,_Eq,+10,String,4,"NULL",CONFIG_STREAM_CHARIN,Null,_RetB
 db CONFIG_STREAM_QUERY,?OUTCOME,MODE-Tgt,Null,C_R-Tgt,$pRepEver
 dw $+37
db _Jump,+6,C_COUNT-10,Zero,_Eq,00h,$pUntil,String,6,"CHARIN"
 db CONFIG_STREAM_CHARIN,?RESPONSE,One,$pBifq,2*$BifLEFT,String1
 db "N",_Sne,+3,Frag21,$pLeave,C_R-10,?OUTCOME,$pAbut,C_R-Tgt-10
 db C_COUNT-10,One,$pSubtract,C_COUNT-Tgt-10,$pIterate,MODE,String1
 db "B",_Seq,+5,C_R,CONFIG_B2C,?OUTCOME,C_R-Tgt,C_R,_RetB
