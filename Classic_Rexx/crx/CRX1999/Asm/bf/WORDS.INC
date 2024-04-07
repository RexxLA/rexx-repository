BIFWORDS db 2*8+1,Zero,S_COUNT-Tgt,$pRepEver
 dw $+19
db S_PART-10,Null,_Ne,00h,$pWhile,S_COUNT-10,One,$pAdd,S_COUNT-Tgt-10
 db S_PART-10,$pParse,00h,022h,ParseDot,S_PART-12,01ah,$pIterate
 db S_COUNT,_RetB
