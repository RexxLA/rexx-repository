BIFSTREAM db 1*8+3,Arg1-10,?STREAM+Tgts,Arg2-10,_Exists,_Then
 db +5,Arg2-10,OPERATION-Tgt,_Jump,+4,String1,"S",OPERATION-Tgt
 db Arg3-10,_Exists,OPERATION-2,String1,"C",_Sne,00h,$pAnd,_Then
 db +8,String1,"2",$pPositive,String1,"4",$pPositive,CONFIG_RAISE40
 db OPERATION,String1,"C",_Seq,+7,Arg3-10,CONFIG_STREAM_COMMAND
 db ?OUTCOME,_RetB,_Jump,+85,OPERATION,String1,"D",_Seq,+11,CONFIG_STREAM_STATE
 db ?RESPONSE,String1,"2",$pPositive,$pBifq,2*$BifSUBSTR,_RetB
 db _Jump,+70,OPERATION,String1,"S",_Seq,+65,?STREAMSTATE,String
 db 5,"ERROR",_Seq,+9,String,5,"ERROR",_RetB,CONFIG_STREAM_STATE
 db ?RESPONSE,One,$pBifq,2*$BifLEFT,String1,"N",_Seq,+9,String
 db 5,"READY",_RetB,?RESPONSE,One,$pBifq,2*$BifLEFT,String1,"U"
 db _Seq,+11,String,7,"UNKNOWN",_RetB,String,8,"NOTREADY",_RetB
