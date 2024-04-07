BIFVERIFY db 12*8+4,Arg3-34,_Exists,_Then,+5,Arg3-34,V_OPTION-Tgt
 db _Jump,+4,String1,"N",V_OPTION-Tgt,Arg4-34,_Exists,_Then,+5
 db Arg4-34,V_START-Tgt,_Jump,+3,One,V_START-Tgt,V_STRING,$pLength
 db LAST-Tgt,V_START,LAST-2,_Gt,+3,Zero,_RetB,REFERENCE,Null
 db _Seq,+12,V_OPTION,String1,"N",_Seq,+5,V_START,_RetB,_Jump
 db +3,Zero,_RetB,V_START,$pNumber,LAST-10,$pTo,$pControlVar
 db V_I-10
 dw $+31
db V_STRING-10,V_I-12,One,$pBifq,2*$BifSUBSTR+128,REFERENCE-12
 db $pBifq,2*$BifPOS,V_T-Tgt-10,V_OPTION-10,String1,"N",_Seq
 db +9,V_T-10,Zero,_Eq,+3,V_I-10,_RetB,_Jump,+7,V_T-10,Zero,_Gt
 db +3,V_I-10,_RetB,_IterCV,Zero,_RetB
