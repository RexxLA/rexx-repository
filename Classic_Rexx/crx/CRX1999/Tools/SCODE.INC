; After the freedoms in group order have been used, there are numeric
; relations between the codes for the syntax elements. These are made
; use of in actions when materializing the $s codes.  The $s codes are
; nearly compact but not in the best order for execution so there is
; later a $s to $p conversion.
; The relations that have to be fitted around are:
;BBBBBB  B           BB     BBBBBBBBBBBB                     BB  B
;                                          V   VV  VVVVV   V   VV
;                                            U   UU
;          P   PPP P   P   P
;         S   S   S
;                                       NN  N
;                                                       III
;      DD   DD
;                       LMM
; Also see intervals for DROP & EXPOSE type.(Got this wrong & had to fixup.)
; Also see needs of PosPlus PosMinus PosEq. (Would like to fit here but
; actually used flags.)
; Also need Length-Max-Min sequential.
S2P:
 Assert $sPercent eq $-S2P
BaseB equ $-$Percent
 Assert $ eq BaseB+$Percentúdb $pIntDivide
 Assert $ eq BaseB+$Asteriskúdb $pMultiply
 Assert $ eq BaseB+$Slashúdb $pDivide
 Assert $ eq BaseB+$Remúdb $pRemainder
 Assert $ eq BaseB+$Xorúdb $pXor
 Assert $ eq BaseB+$Orúdb $pOr
; DROP and EXPOSE are treated together. Also DropList and ExposeList
 BaseD equ $-$DROP
 Assert $sDrop eq $-S2P
 Assert $ eq BaseD+$DROPúdb $pDrop
 db $pExpose
 Assert $ eq BaseB+$Andúdb $pAnd
; STEM/STREAM/NORMAL are treated together
BaseS equ $-$STEM
 Assert $sStem eq $-S2P
 Assert $ eq BaseS+$STEMúdb $pStem
; PARSE sources are done together.
BaseP equ $-$WITH
 Assert $sWith eq $-S2P
 Assert $ eq BaseP+$WITHúdb $pWith
 Assert $sDropList eq $-S2P
 db $pDropList
 db $pExposeList
 Assert $ eq BaseS+$STREAMúdb $pStream
 Assert $ eq BaseP+$LINEINúdb $pLineIn
 Assert $ eq BaseP+$SOURCEúdb $pSource
 Assert $ eq BaseP+$VERSIONúdb $pVersion
 Assert $ eq BaseS+$NORMALúdb $pNormal
 Assert $ eq BaseP+$PULLúdb $pPull
 db 0 ; Spare
 Assert $sMinus eq $-S2P
 Assert $ eq BaseB+$Minusúdb $pSubtract
 Assert $ eq BaseB+$Plusúdb $pAdd
 Assert $ eq BaseP+$VARúdb $pWith; n.b.
 Assert $sLength eq $-S2P
 db $pLength
 db $pMax
 db $pMin
 Assert $ eq BaseP+$ARGúdb $pArg
; Eq was forced to top of its group, in order to make comparisons compact.
 Assert $sEq eq $-S2P
 Assert $ eq BaseB+$Eqúdb $pEq
 Assert $ eq BaseB+$Neúdb $pNe
 Assert $ eq BaseB+$Ltúdb $pLt
 Assert $ eq BaseB+$Leúdb $pLe
 Assert $ eq BaseB+$Geúdb $pGe
 Assert $ eq BaseB+$Gtúdb $pGt
 Assert $sSeq eq $-S2P
 Assert $ eq BaseB+$Seqúdb $pSeq
 Assert $ eq BaseB+$Sneúdb $pSne
 Assert $ eq BaseB+$Sltúdb $pSlt
 Assert $ eq BaseB+$Sleúdb $pSle
 Assert $ eq BaseB+$Sgeúdb $pSge
 Assert $ eq BaseB+$Sgtúdb $pSgt
; NUMERIC components are done together.
BaseN equ $-$DIGITS
 Assert $sDigits eq $-S2P
 Assert $ eq BaseN+$DIGITSúdb $pDigits
 Assert $ eq BaseN+$FUZZúdb $pFuzz
 db 0; $sTailed was here, now unneeded
; Several verbs are done together.
BaseV equ $-$NOP
 Assert $sNop eq $-S2P
 Assert $ eq BaseV+$NOPúdb $pNop
 Assert $sForm eq $-S2P
 Assert $ eq BaseN+$FORMúdb $pForm
BaseU equ $-$Not
 Assert $ eq BaseU+$Notúdb $pNot
 Assert $sAddress eq $-S2Púdb $pAddress
 Assert $ eq BaseV+$INTERPRETúdb $pInterpret
 Assert $ eq BaseV+$OPTIONSúdb $pOptions
 Assert $sNegate eq $-S2P
 Assert $ eq BaseU+$Minusúdb $pNegate
 Assert $sPositive eq $-S2P
 Assert $ eq BaseU+$Plusúdb $pPositive
 Assert $sExit eq $-S2P
 Assert $ eq BaseV+$EXITúdb $pExit
 Assert $ eq BaseV+$PUSHúdb $pPush
 Assert $ eq BaseV+$QUEUEúdb $pQueue
 Assert $sReturns eq $-S2P
 Assert $ eq BaseV+$RETURNúdb $pReturns
 Assert $ eq BaseV+$SAYúdb $pSay
 Assert $sNumber eq $-S2Púdb $pNumber
 db 0;
 Assert $sRaise eq $-S2Púdb $pRaise
 Assert $ eq BaseV+$TRACEúdb $pTrace
 db 0; was $sCatDot now unneeded.
 Assert $ eq BaseB+$Abutúdb $pAbut
 Assert $ eq BaseB+$Catúdb $pCat
 Assert $sLeave eq $-S2P
 Assert $ eq BaseV+$LEAVEúdb $pLeave
 Assert $sIterate eq $-S2P
 Assert $ eq BaseV+$ITERATEúdb $pIterate
 Assert $ eq BaseB+$Powerúdb $pPower
