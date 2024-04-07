BIFLINEIN db 6*8+3,Frag19,Arg2-20,_Exists,_Then,+30,String,6
 db "LINEIN",Arg2-20-2,CONFIG_STREAM_POSITION,?RESPONSE,Frag5
 db ?RESPONSE,One,$pBifq,2*$BifLEFT,String1,"R",_Seq,+10,String1
 db "2",$pPositive,Arg2-20-2,String2,"41",$pPositive,CONFIG_RAISE40
 db Frag14,One,_Gt,+7,L_COUNT,String2,"39",$pPositive,CONFIG_RAISE40
 db L_COUNT,Zero,_Eq,+10,String,4,"NULL",CONFIG_STREAM_CHARIN
 db Null,_RetB,String,6,"LINEIN",CONFIG_STREAM_CHARIN,?RESPONSE
 db One,$pBifq,2*$BifLEFT,String1,"N",_Sne,+35,?RESPONSE,One
 db $pBifq,2*$BifLEFT,String1,"E",_Seq,+9,String,5,"ERROR",?STREAMSTATE+Tgts
 db String,8,"NOTREADY",?STREAM,?RESPONSE,String1,"2",$pPositive
 db $pBifq,2*$BifSUBSTR,CONFIG_RAISE,?OUTCOME,_RetB
