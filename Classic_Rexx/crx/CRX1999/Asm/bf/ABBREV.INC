BIFABBREV db 6*8+3,Arg3-20,_Exists,_Then,+5,Arg3-20,LENGTH_-Tgt
 db _Jump,+4,SUBJ,$pLength,LENGTH_-Tgt,SUBJECT,$pLength,SUBJ-2
 db $pLength,_Ge,00h,COND1-Tgt,SUBJ,$pLength,LENGTH_-2,_Ge,00h
 db COND2-Tgt,SUBJECT,One,SUBJ-4,$pLength,$pBifq,2*$BifSUBSTR+128
 db SUBJ-2,_Seq,00h,COND3-Tgt,COND1,COND2-2,$pAnd,COND3-2,$pAnd
 db _RetB
