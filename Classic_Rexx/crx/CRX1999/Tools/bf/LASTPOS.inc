BIFLASTPOS db 5*8+3,HAYSTACK,$pLength,START-Tgt,Arg3-18,_Exists
 db _Then,+6,Arg3-18,START-2,$pMin,01h,START-Tgt,NEEDLE,$pLength
 db NEEDLELENGTH-Tgt,NEEDLELENGTH,Zero,_Eq,+3,Zero,_RetB,START
 db NEEDLELENGTH-2,$pSubtract,One,$pAdd,START-Tgt,START,$pNumber
 db One,$pNegate,$pBy,$pControlVar,II-10
 dw $+18
db II-10,Zero,_Gt,00h,$pWhile,HAYSTACK-10,II-12,NEEDLELENGTH-14
 db $pBifq,2*$BifSUBSTR+128,NEEDLE-12,_Seq,+3,II-10,_RetB,_IterCV
 db Zero,_RetB
