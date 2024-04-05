; Copyright Formcroft Ltd 1997-1999
 .model smallú.486ú.code
 include always.inc; Assembler shorthands like 'Bptr' for 'byte ptr'.
 include declares.inc; Symbolic constants, macros, records, structures.
MyGroup GROUP _TEXT, BifSeg
BifSeg SEGMENT WORD PUBLIC 'CODE'
 dw BifFORM
 dw BifDATATYPE
 dw BifADDRESS
 dw BifARG
 dw BifCONDITION
 dw BifTRACE
 dw BifFUZZ
 dw BifDIGITS
 dw BifSOURCELINE
 dw BifXRANGE
 dw BifRANDOM
 dw BifREVERSE
 dw BifABS
 dw BifSIGN
 dw BifC2X
 dw BifB2X
 dw BifX2B
 dw BifX2C
 dw BifX2D
 dw BifC2D
 dw BifD2C
 dw BifD2X
 dw BifBITAND
 dw BifBITOR
 dw BifBITXOR
 dw BifVALUE
 dw BifCOPIES
 dw BifWORD
 dw BifWORDINDEX
 dw BifSUBWORD
 dw BifPOS
 dw BifLEFT
 dw BifSUBSTR
; Things which can't fail on argument type can be given simpler treatment.
;Some of these can use same Pcode point because number of args will distinquish.
; They need a bif number only so that messages can invert it to the name.
; Need specials high values. FORMAT with 5 args is special.
; Need these higher values than others.
 dw BifQUEUED
 dw BifSYMBOL
 dw BifCOUNTSTR
 dw BifCHANGESTR
 dw BifLENGTH
 dw BifMAX
 dw BifMIN
BifSeg ENDS

 PUBLIC BifNames; Used by messages to convert from bif number.
 PUBLIC Bifs; For lookup of spellings.
 PUBLIC BifGroup$$
 PUBLIC Bif$$
 PUBLIC Max$$
 PUBLIC Min$$
 PUBLIC Length$$
 PUBLIC Bifq$$
 PUBLIC Trace$$
 PUBLIC BifCHARIN, BifCHAROUT, BifSTREAM

 PUBLIC AfterCheck
 PUBLIC PcodeBif
 EXTERN B4VALUE1:near
 EXTERN B4VALUE2:near

 EXTERN Raise40p11:near
 EXTERN Raise40p32:near
 EXTERN Raise40p33:near
 EXTERN Raise40:near

 EXTERN BifCOUNTSTR:near
 EXTERN BifCHANGESTR:near
 EXTERN BifMAX:near
 EXTERN BifMIN:near
 EXTERN BifX2B:near; !! could be avoided.
 EXTERN BifD2X:near; !! could be avoided.
 EXTERN BifC2X:near; !! could be avoided.
 EXTERN BifB2X:near; !! could be avoided.
 EXTERN BifX2C:near; !! could be avoided.
 EXTERN BifX2D:near; !! could be avoided.
 EXTERN BifC2D:near; !! could be avoided.
 EXTERN BifD2C:near; !! could be avoided.
 EXTERN BifBITAND:near; !! could be avoided.
 EXTERN BifBITOR:near; !! could be avoided.
 EXTERN BifBITXOR:near; !! could be avoided.

 EXTERN UpperFirstAh:near
 EXTERN Bswitch:near
$BifSpecial equ $BifQUEUED
;------------------------------------------------------------------------------
; Make Pcode for a Bif.
;------------------------------------------------------------------------------
PcodeBif:; Here is Bif checking/generation.
; StackDx and StackDi come as the lo:hi bounds of parameters to be consumed.
; ParmsCl, Z.StackLo, Z.Stack are also set.
 mov StackDi,StackDx; StackDi to below leftmost arg.
; bx will address the checking data. $9.2.1
 mov Z.InsBif,blúadd bx,bxúmov SpecsBx,Wptr(Bswitch)[bx]
 mov Z.BifParmsHi,ParmsCl
; The byte before the label has the data we want.
BoundsDl is <dl>;
 dec SpecsBxúmov BoundsDl,[SpecsBx]
; Isolate limits.
MinAh is <ah>;
MaxAl is <al>;
 mov MinAh,BoundsDlúshr MinAh,ParmsMin
 mov MaxAl,BoundsDlúand MaxAl,mask ParmsXtrúshr MaxAl,ParmsXtrúadd MaxAl,MinAh
; Usually the Pcode second byte will show BifNum and number of (optional) args.
; Special cases are MAX MIN & FORMAT
 cmp Z.InsBif,$BifFORMATújne @Fúmov ax,MkMajMin(1,5)ú@@:
; 255 equals infinity because of $MaxParms
 cmp BoundsDl,(3 shl ParmsMin + 3 shl ParmsXtr)újb @Fúmov ax,MkMajMin(1,255)ú@@:
 mov dh,ParmsClúsub dh,MinAhúshl dh,6úadd dh,Z.InsBifúrol dh,1úmov Z.BifByte,dh
ErrDl is <dl>;
 mov ErrDl,$n40p3; Possible error
 mov Z.Insert.ArgNum,MinAhúcmp ParmsCl,MinAhújb DelayedRaise
 mov ErrDl,$n40p4úmov Z.Insert.ArgNum,MaxAlúcmp ParmsCl,MaxAlúja DelayedRaise
; The ARG() count is good but that can include omitted arguments.
; x=arg(,'E') is not allowed.
 cmp Z.InsBif,$BifARGújne @Fúcmp ParmsCl,2újne @Fúinc MinAhú@@:
 mov ErrDl,$n40p5újmp TestOmitted
@@:inc chúmov Z.Insert.ArgNum,ch
 Upúcmp V.Dtype,$Omittedúje DelayedRaise
TestOmitted:cmp ch,MinAhújne @B
; The presence/absence of arguments is OK, but they may not be the right types.
 mov StackDi,Z.StackLoúmov StackDx,Z.Stack; Hi end
; There are some special bifs for which type testing isn't relevant.
 mov al,Z.InsBif
; FORMAT with 5 parameters is special.
 cmp ParmsCl,5újne @Fúcmp al,$BifFORMATúje BifGroupú@@:
 cmp al,$BifSpecialújb BifPlain
; LENGTH MAX MIN have their own Pcodes.
 sub al,$BifLENGTHújb BifGroupújz @F
; MAX & MIN need the (excess) parameter count.
 dec ParmsClúadd al,al
@@:add al,$pLengthújmp PcodeOp

; QUEUE etc initially use the same runtime; number of parameters distinquishes.
BifGroup:OpRet $pBifGroup

; Put $pRaise and error code. Parsing will recover what more a message needs.
DelayedRaise:mov OpAppendCl,ErrDlúOpRet $pRaise

comment~ Errors about number of arguments to a builtin have already been
tested.  BifTypes will check on the datatype of the arguments. This occurs
at both compile and run times. At compile time the intention is to put
any arguments that are constants into the best format for the job, eg the
letter "1" for a pad, the number 1 for a subscript position. If all relevant
arguments can be checked this way there is no need for a run time check.
Run time check has to be done in the order that the parameters appeared.
StackDi to StackDx are set for that order.

At run time we can raise error 40 as soon as a test fails. At compile time
it may "fail" because it is a variable and cannot be tested. In that case
we want to continue and check remaining arguments.
~

BifPlain:
; Bifs that can set the NotReady condition need a check at the end of the clause
; to see if it happened.  Set a flag now and compile a $pNop at end-of-clause.
 cmp al,$BifSTREAMúja @FúOn Z.Middles,EndClauseú@@:
; BifTypes expects StackDi,StackDx,SpecsBx. StackDi below 1st, StackDx at last.
 call BifTypes
; Here when BifTypes has been used at compile time.
; If all types were checked good, because they are consts, the faster form
; of Pcode can be used.
; Soft stack left with the parameters removed. Function action adds result.
 mov al,$pBifúmov cl,Z.BifByte
; If any check failed, use $pBif which does tests at run time.
 btr Z.Program,BifCheckújc @Fúmov al,$pBifqú@@:
if ForBcode
 mov al,$pBifq; Rely on programmer when making Pcode to be translated to Bcode.
endif
 jmp PcodeOp

comment~ Originally this was coded so that DATATYPE had the option letter
converted to a compact numbering.  At assembler time this was done with
 Pos(<B>,<ABLMNSUWX>) sort of thing. Nowadays DATATYPE tests the uppercased
 letter instead of a number.
~

if Solid
WhichCheck:
; Minor msg number. Letter for DataType
; Difference of Whole and WholeNum is only in the conversion, not the test.
; The DATATYPE bif uses 'N' and 'W', which convert at current precision.
; CheckArgs needs a similar test, but with bif precision. Detect that
; as zero datatype.
; WholeGE needs to complain about wholeness in preference to about GE.
Assert $Whole     eq $-WhichCheckúdb 12,' 'údw AnyRet
Assert $WholeGE   eq $-WhichCheckúdb 12,' 'údw WholeGE$
Assert $WholeGT   eq $-WhichCheckúdb 12,' 'údw WholeGT$
Assert $Num       eq $-WhichCheckúdb 11,'N'údw AnyRet
Assert $M090      eq $-WhichCheckúdb 17,'N'údw M090$
Assert $WholeNum  eq $-WhichCheckúdb 12,'W'údw WholeNum$
; Pad is distinctive in not needing a DataType test. Internally nop.
Assert $Pad       eq $-WhichCheckúdb 23,'$'údw Pad$
Assert $Hex       eq $-WhichCheckúdb 25,'X'údw AnyRet
; The DATATYPE bif doesn't have Stream test. Internally we add one.
Assert $Stream    eq $-WhichCheckúdb 27,'Z'údw AnyRet
Assert $Bin       eq $-WhichCheckúdb 24,'B'údw AnyRet
Assert $Symbol    eq $-WhichCheckúdb 26,'S'údw AnyRet
endif

; Pads have to be length one.
Pad$:call ToDsSiCxúcmp cx,1újne Failed
AnyRet:ret

WholeGT$:; If we got this far it was a whole number. (Else was msg 40.12)
 mov al,14úcmp V.Mantissa,ebpújne @Fújmp Failed

WholeGE$:mov al,13
@@:test V.Sign,1újnz Failedúret

M090$:mov al,17
; If we tested here we would be able to put constants right a compile time,
; eg 41.10 => 41.1
; However, it seems easier to put the algorithm in Rexx.
; Fail on negative.
; Convert to string.
; Fail if 'E'
; Split at dot.
; Fail major > 90
; Kill trailing zeroes on minor
; Fail first digit of minor 9 unless only digit.
 ret

WholeNum$:
; What is this test ?? Only runtime use of ParmsHi?
 cmp Z.BifParmsHi,2újb @F
; !! what if too many digits for binary.
 test Bptr(V.Mantissa+3),80hújz @F
 mov al,13újmp Failed
@@:ret

; Maybe better code here if list of letters had been reversed but that would
; make producing <options> in a message harder.
; al holds negative of the length of the letter sequence.
; Trace is a special case - any number of leading question marks.
LetterList:cbwúdec SpecsBx
 cmp Bptr[SpecsBx],'?'újne PostTrace

; What to do with '?' of the subject !!
 inc axúdec SpecsBx
; Make it a runtime problem.
 cmp V.Dtype,$Variableúje Failed
 cmp V.Dtype,$Constantúje Failed
; Throw them away for now.         NYI
Qdrop:call ToDsSiCxúJcxzQ PostTrace
 cmp Bptr[si],'?'újne PostTrace
; take SUBSTR(it,2)
 Upúmov V.ExpAnd,ebpúmov V.Mantissa,ebpúmov Bptr(V.Mantissa),2
 mov al,0úpush SpecsBxúpush PostSubstrúpush siújmp BifSUBSTR
PostSubstr:pop SpecsBxújmp Qdrop

PostTrace:
; About to check an options letter against the list.
; We may need the list for a syntax msg.
 mv ds,cs
 inc ax
 mov Z.Insert.OptsHi,SpecsBxúadd SpecsBx,axúmov Z.Insert.Options,SpecsBx
 mov cl,V.Dtype
; Parameter == '' is SYNTAX 40.21
 mov al,21úcmp cl,$NullStringúje Failed
 cmp cl,$Constantújne @F
 mov si,V.WhichConúmov ds,Z.ProgScopeúcmp Vsid.Dtype,$NullStringúje Failed
@@:
; Special case for STREAM bif, but I'll do that in the STREAM routine.
; (If the second argument isn't 'C' then a third is wrong.)
; Parameter omitted will be defaulted.
 cmp cl,$Omittedúje NoLetter
; Uppercase the parameter, and shorten to one char.
; At compile time we may alter the constant.
 mov ah,'O'úcmp cl,$Constantújne @Fúcall ConstValueXú@@:
 mov al,28
; More by luck than good coding this doesn't change $Variable things to letters.
 call UpperFirstAh
 mv ds,cs
; See if match in string.
 dec SpecsBx
@@:inc SpecsBxúcmp SpecsBx,Z.Insert.OptsHiúja Failedúcmp ah,Bptr[SpecsBx]újne @B
NoLetter:
 mov SpecsBx,Z.Insert.Optionsújmp AfterCheck

; Here is a set of ways of raising SYNTAX, jumped to from the bif testing.
; The numeric tests can fail with "Exponent out of range."
; Change 40.11 to 40.9 if exponent too big.
;MASM........................
Failed:
 btr Z.Cancel,ExpRangeújnc @Fúmov al,9ú@@:
; Z.Insert.Value will be good for Value insert. (Raise will set it from StackDi)
; Z.Insert.Options is good if relevant.
; Z.Insert.ArgNum has been maintained.
; Z.InsBif has not been set, the rescan will do that.
; al has been set to minor code.
; CursorSi was pushed early on for line number.
; When Bif parameters are checked at compile time a failure will come here.
; Instead of following through we need to continue checking, with a flag
; to ensure we eventually make code to check again at run time.
 cmp Z.Scanp,ZeroBpújz Raise40
; Assert SpecsBx, StackDi, StackDx in play.
 mov sp,Z.StashúOn Z.Program,BifCheckújmp AfterCheck

; These bifs have a fixed number of arguments so we can economize on codes by
; distinguishing them here. Only FORMAT requires argument checking.
BifGroup$$:
 mov bl,Bptr gs:[CursorSi]
 inc CursorSiúpush CursorSi
 cmp bl,5újne @F
 mov bl,2*$BifFORMATúmov al,4úOn Z.Cancel,Format5újmp FromFORMAT5
@@:add bl,$BifQUEUEDúadd bx,bxúz al
 jmp FromBifGroup

; Bif, and Bifq both invoke a builtin function.
; Bif$$ does full checking.
Bif$$:push CursorSi
comment~ The parameters are checked before calling the Bif, against data which
is held adjacent to the machine code peculiar to that Bif.  This has to be done
in the order that they appeared.

~
 mov al,gs:[CursorSi]úmov bl,alúand bl,7Eh
; InsBif isn't needed for potential error message because parser will be
; reused to synch the message and that sets InsBif.
SpecsBx is <bx>; SpecsBx will address the checking data. $9.2.1
 ror al,7úand al,3
FromFORMAT5:
 mv ds,csúmov bx,(Bswitch)[bx]
; Combine the count of optional parameters now in al with count of mandatory.
 dec SpecsBxúmov cl,Bptr[SpecsBx]úshr cl,ParmsMinúadd al,clúmov Z.BifParmsHi,al
; Set StackDi to address any parameters from below the leftmost.
 mov StackDx,StackDiúmov ah,$StrideVúmul ahúsub StackDi,ax
BifTypes:; Note this routine is used both at compile and run times.
; Hence care with segment register non-use or reload.
; Either way label Raise handles things that don't pass the testing.
; The number of parameters has already been checked, because that is always a
; compile time job.
; At this point, it is SpecsBx, StackDi and StackDx that define to-be-done.
 mov Z.Insert.ArgNum,0úpush StackDx
; First byte says which parameters need checking.
 mov al,Bptr[SpecsBx]úshl al,8-width NonCheck
 mov Z.Stash,sp; To tidy up in Failed.
 mov Z.Flags,alújmp AfterCheck
ParmLoop:inc Z.Insert.ArgNumúshl Z.Flags,1újc AfterCheck

comment~ A parameter omitted is bound to be OK since if it was a mandatory
position some $pRaise Pcode would already have been substituted.  But we can't
just skip those yet because of need to default.  Subsequent bytes are either a
list of letters for checking an option, or some value denoting another test.
All the CheckArgs tests are here, plus some others.

~
 dec SpecsBxúmov al,Bptr[SpecsBx]úcmp al,-@SizeStr(<ACEFILNOR?>)újae LetterList
 cmp V.Dtype,$Omittedúje AfterCheck
; StackDi is for the current argument, StackDx yields how many there were.
; The table at WhichCheck gives input to a datatype test plus actual address
; of a relevant particular test.
 movzx si,alúadd si,WhichCheckúlodsw
; Make a version of a constant argument that is of suitable type, if possible.
; ah is type letter.
 cmp V.Dtype,$Constantújne @F
; Only happens at compile time.
 call ConstValueX
@@:
; The test of $Variable is only relevant at compile time and wouldn't be
; needed if I made sure conversions always failed for that type.
 cmp V.Dtype,$Variableúje Failed
; al now will be minor message number. ah will be letter option for datatype.
; Carry will be set on by DataType if the type test fails.
; Otherwise DataType will convert the argument, according to ah.
; DataType doesn't do its own saving; sometimes called with nothing to save.
 push SpecsBxúpush StackDxúpush siúpush axúmov al,ahúcall DataTypeúpop ax
 pop siúpop StackDxúpop SpecsBx
 mv ds,cs
 jc Failed
; Symbol is only checked as the first parameter of VALUE, and can't be wrong
; then if there is a third parameter.
; I have decided to test this only in the BifVALUE code.
 call Wptr[si]; For specialized tests on the argument.
 mv ds,cs
AfterCheck:Upúcmp StackDi,StackDxújna ParmLoop
; Reached here if no check failed.
 pop StackDiúz bh
; If BifTypes was used from compile time it returns from here.
 cmp Z.Scanp,ZeroBpúje @Fúretú@@:
 Qry Z.Cancel,Format5újz @F
; Typical Format awkwardness.
 mov al,4úmov bl,2*$BifFORMATújmp FromBifGroup
@@:
 pop CursorSi
; End of Bif$$ pre-checking of arguments. Now is like Bifq$$.
;------------------------------------------------------------------------------
; The XCycle fans to Add$$, Iterate$$ etc.  Bifq$$ is another fan-out.
;  (Bif$$ does parameter checking on the way to Bifq$$ when necessary.)
;------------------------------------------------------------------------------
Bifq$$:lodsb gs:[CursorSi]úpush CursorSi; Many Bifs need to use this.
comment~ Design note - the "bif byte" has the middle six bits determining the
bif and the sign+oddness bits saying how many parameters beyond the minimum
required for that bif.  Using two bytes would avoid some complexity, trade a
little Pcode size for a little speed.  Note, however, that use of sign+oddess
means the count can be put in the hardware flags with one test instruction.

~
; Pick up address of BifABBREV or whatever it is.
 mov bl,alúand bl,7Eh
FromBifGroup:
 mov si,cs:(Bswitch)[bx]
; Some are hard codes, some use Bcodes.
; BEWARE - this test depends on the order in which object modules are linked.
 cmp si,offset BifBoundújb BifBcoded
; Adjust the optional extra parameters out of the StackDi position.
 mov bl,alúand bl,81húrol bl,$ShiftV+1úsub StackDi,bx
; The bif routines are entered with:
;AH free, AL showing what optional parameters were present. (need not preserve)
;BH zero, BX free
;CH free, CL showing options letter as number, where relevant. (need not pre..)
;DX free
;SI free Must be restored on return, by pop.
;DI addressing the last mandatory argument. On return must address result.
;DS free
;ES free
;FS not free
;GS not free
;Extended parts of registers can be changed.
 jmp si; Will return to XCycle

; When we come from setting up a builtin AL describes the builtin and number
; of actual arguments. SI addresses the implementing Bcode and the byte
; before that gives the maximum possible number of optional arguments.
; (Exception - MAX and MIN)
; The stack about to be padded with $Omitted arguments so that the implementing
; code always sees the same amount of stack for arguments.
; (Z.ArgsB0 and Z.ArgsB also say where args are; this needed for MAX/MIN)
; CursorSi is now the cursor on Bcode.
; The CursorSi position has been pushed. (That is Pcode position if top level.)
; Set ah to allowed extras, al to extras on this invocation.
comment~ The test that brings us here distinguishes Bcode/machinecode. That
doesn't allow for a bit of machine code as a preamble for a particular bif,
followed by Bcode for that bif.  So if we want to do something like that, it
will havee to be tested here. (Change to a more efficient way one day)
~
BifBcoded:
 cmp bl,2*$BifBITANDújne @F
 mov Dptr(Ve.String[$?BIF]),StringOrder('B','I','T','A')
 mov Dptr(Ve.String[$?BIF+4]),StringOrder('N','D',0,($NullString+6))
 jmp BifUsual
@@:cmp bl,2*$BifBITORújne @F
 mov Dptr(Ve.String[$?BIF]),StringOrder('B','I','T','O')
 mov Dptr(Ve.String[$?BIF+4]),StringOrder('R',0,0,($NullString+5))
 jmp BifUsual
@@:cmp bl,2*$BifBITXORújne @F
 mov Dptr(Ve.String[$?BIF]),StringOrder('B','I','T','X')
 mov Dptr(Ve.String[$?BIF+4]),StringOrder('O','R',0,($NullString+6))
 jmp BifUsual
@@:cmp bl,2*$BifFORMATújne BifUsual
 mov ah,4; Max extras.úbtr Z.Cancel,Format5újc Format5nújmp Formatn
BifUsual:mov ah,cs:[CursorSi-1]úand ah,mask ParmsXtrúshr ah,ParmsXtr
Formatn:rol al,1úand al,3
Format5n:mov Z.ArgsB,al; Actual extras.újmp BifArgPad
@@:Upúmov V.Dtype,$Omittedúinc ax
BifArgPad:cmp al,ahújne @Bújmp LinkBcodeX

; Bifs implemented. Data for checking parameters ahead of the machine code.

if Solid
;$9.3.6
 db $WholeGEúParmsRec <2,0,1011b>
BifCOPIES:
endif
 mov bx,V.MantLowúDown
; Zero copies returns null string.
 TestReg bxújnz @Fúmov V.Dtype,$NullStringúRetSiú@@:
 call ToDsSiCxúJcxzQ @3p6ret
 Move V2,V,edx
; Setup for result loses first argument.
 xax cxúmul bxújc Raise5p1dúxax cxúcall ResultSpace
; In case compaction.
 Upúcall ToDsSiCxúDown
 push StackDiúmov di,ax
@@:push cxúpush siúrep movsbúpop siúpop cxúdec bxújnz @B
 pop StackDi
@3p6ret:jmp BackEsSi

if Solid
;$9.3.8
 db "ABLMNSUWX"údb -@SizeStr(<ABLMNSUWX>)úParmsRec <1,1,1011b>
BifDATATYPE:
endif
 test al,81hújnz @F
 inc bhúmov al,'N'újmp WithLetter
@@:Upúcall UpperFirstAhúmov al,ahúDown
WithLetter:call DataType
; Carry is set if *not* this type.
 mov eax,ebpújc @Fúinc axú@@:
 mov V.Mantissa,eaxúmov V.ExpAnd,ebp
 test bh,bhúje BifDret
 mov V.Dtype,$NullString+3
 mov Dptr(V.String),StringOrder('N','U','M',' ')
 dec axújz BifDret
 mov V.Dtype,$NullString+4
 mov Dptr(V.String),StringOrder('C','H','A','R')
BifDret:pop CursorSiúBackRet

DataType:
; DataType determines whether the data type of the value on the stack is
; as expected, and does some conversion.
; On entry StackDi gives the subject.
; On entry al is the option letter.
; On exit carry is Boolean for "not as expected"
; A side-effect of some types is to "normalise" the subject.

; al blank on entry means that this is one of the tests for whole numbers
; with bifs. The test for number syntax is the same as with 'N' but the
; integerness test may be different because always at precision 9.
; ToWholeEbx also used for FOR argument etc.
 cmp al,' 'úje ToWholeEbx

; Get the null string cases out of the way
 cmp V.Dtype,$NullStringújne TqNonNull
 cmp al,'B'úje @Fúcmp al,'X'úje @Fúcmp al,'Z'úje @Fústcú@@:ret

TqNonNull:pusha
; The three major representations are number, short string, and long string.
; A particular Rexx value can be held in different representations.
 mov bx,Attributes; For potential XLAT

 cmp al,'N'újne DNotN
; !! Is current digits, not 9.  Carry from NumDxBx is bad syntax.  jnz for bin.
 call NumDxBxújc TqFailújmp TqOK
DNotN:
 cmp al,'W'újne DNotW
; WholeNum. DATATYPE uses the current digits.
 call ToWholeEbxújc TqFailújmp TqOK

DNotW:
 call ToDsSiCx
 mov bx,Attributes
 cmp al,'A'újne DNotA
; Letters and digits OK. Not including '_' etc which our table has as letters.
; Not including '.' which our table has as a letter.
; Sadly. '@' is mixed in with the uppercase letters in ASCII sequence.
@@:lodsbúcmp al,'0'újb TqFailúcmp al,'@'úje TqFail
 cmp al,'.'úje TqFailúXlatBDLSújpe TqFailúloop @Bújmp TqOK
DNotA:

 cmp al,'B'újne DNotBúmov dx,MkMajMin(3,$OKb)újmp FromB
DNotB:

 cmp al,'L'újne DNotL
; Lower case OK, same as uppercaseable letter/digit
@@:lodsbúXlatBDLSújpe TqFail
 test al,$Lowercaseújnz TqFailúloop @Bújmp TqOK
DNotL:

 cmp al,'M'újne DNotM
; Mixed, same as 'A' except excludes digits.
@@:lodsbúcmp al,'A'újb TqFailúXlatBDLSújpe TqFailúloop @Bújmp TqOK
DNotM:

 cmp al,'S'újne DNotS
; Not easy to share Symbol test with compile time.
 cmp cx,$Limit_Nameúja TqFail
; Dot as letter.
; What about reserveds in SYMBOL()?
@@:lodsbúXlatBDLSújpe TqFailúloop @Bújmp TqOK
DNotS:

 cmp al,'U'újne DNotU
; Upper
@@:lodsbúcmp al,'A'újb TqFailúcmp al,'Z'úja TqFailúloop @Bújmp TqOK
DNotU:

 cmp al,'X'újne DNotX
; The same loop is used for hex and binary, with parameters.
; To test for valid chars, RadixTypeDl.
; To test for blanks badly placed dh, 1 for Hex, 3 for Bin.
 mov dx,MkMajMin(1,$OKx)
FromB:
; Check first and last of content for blanks.
 mov al,[si]úXlatBDLSújz TqFail
 add si,cxúdec siúmov al,[si]úXlatBDLSújz TqFail
; Check the string content which goes down from si for cx.
; Whitespace is allowed for formatting.
; But not at ends or in middle of nibbles.
 z Z.DigitCount
 std
RadiLoop:lodsb [si]úXlatBDLSújnz NonWhi
 test Bptr Z.DigitCount,dhújnz TqFail
 jmp @F
NonWhi:jpe TqFail; Not a letter or digit
 test AttribAl,RadixTypeDlújz TqFail; Not good for this radix
 inc Z.DigitCount
@@:LoopQ RadiLoop
 jmp TqOK
DNotX:

; Here would be test for allowable characters in a stream name.
; cmp al,'Z'    NYI
 jne DNotZ

TqFail:popaúcldústcúret

DNotZ:; Pad type always succeeding.
TqOK:popaúcldúclcúret

Max$$:inc bh
Min$$:lodsb gs:[CursorSi]úmov Z.ArgsB,alúinc ax; Actual args.
; Check Numberness in the original order.
 mov ah,-$StrideVúimul ah
 mov cx,StackDiúadd StackDi,axúmov Z.ArgsB0,StackDiúmov Z.Insert.ArgNum,0
 push bx
@@:inc Z.Insert.ArgNumúUpúcall NumDxBxújc Raise40p11úcmp StackDi,cxújne @B
 pop bx
; Actual function is Bcoded.
 mov dx,BifMAXútest bh,bhújne @Fúmov dx,BifMINú@@:jmp LinkBcode

if Solid
;$9.3.13
 db $Padúdb $WholeGEúParmsRec <2,1,1001b>
BifLEFT:
endif
 test al,81hújz @3p13Two
 add Z.Stack,$StrideV
; LEFT(a,b,c) ==> SUBSTR(a,1,b,c)
; SUBSTR with four args, two mandatory.
 add al,1
; Move pad field one further up, after ensuring it is char.
; Avoid check if Bcode didn't use Bifq$$ all the time.(Best avoided compiletime)
 Upúcall ToDsSiCxúDown
 mov cl,V2.Stringúmov V3.String,cl
 mov V3.Dtype,$NullString+1
@3p13Two:
; LEFT(a,b) ==> SUBSTR(a,1,b)
; SUBSTR with three args, two mandatory.
 add al,80h
; Move length field one further up.
 mov ecx,V.Mantissaúmov V2.Mantissa,ecx
 mov ecx,V.ExpAndúmov V2.ExpAnd,ecx
; Set what was length field to 1.
 mov V.Mantissa,ebpúmov V.ExpAnd,ebpúinc Bptr V.Mantissa
 jmp BifSUBSTR

if Solid
;$9.3.16
 db $WholeGTúParmsRec <2,1,1101b>
BifPOS:
endif
; Start above Haystack above Needle.
 call ToDsSiCxúDown
 test al,81húz axújcxz @3p16Doneújns @3p16Two
; Adjust when start position given.
 mov dx,V3.MantLow
 cmp dx,cxúja @3p16Doneúmov ax,dx
 dec axúadd si,axúsub cx,ax
; ax is contribution to result.
@3p16Two:
; NYI push ds unsound?
 push diúpush dsúpush siúpush cxúcall ToDsSiCx; For Needle
; bx = Hay length. di=Hay pos.  es=Hay seg.
 pop bxúpop diúpop esúJcxzQ @3p16Noneúsub bx,cxújb @3p16None
; ax to be result. Usual registers for repe cmpsb. bx detects end of Haystack.
@3p16loop:inc axúpush siúpush diúpush cxúrepe cmpsbúpop cxúpop diúpop si
 je @3p16xúinc diúdec bxújns @3p16loop
@3p16None:z ax
@3p16x:pop di
@3p16Done:mov V.ExpAnd,ebpúmov V.Mantissa,ebpúmov V.MantLow,ax
 jmp BackEsSi

if Solid
;$9.3.17
 ParmsRec <1,0,1111b>
BifREVERSE:
endif
; Setup for result loses first argument.
 Move V2,V,edx
 call ToDsSiCxúJcxzQ @9p3p17
 call ResultSpace
 xax bxúadd bx,cx
 Upúcall ToDsSiCxúDown;
@@:lodsbúdec bxúmov es:[bx],alúloop @B
@9p3p17:jmp BackEsSi

if Solid
;$9.3.21
 db $Padúdb $WholeGEúdb $WholeGTúParmsRec <2,2,1000b>
BifSUBSTR:
endif
; Setup to be  V2 (bx+1) is position, V3 (dx) is length, V4 is pad char, pad
; length ax.
if 1
; NYI Bcode to explicitly make number where required?
 test V.Dtype,$Testújz @Fúcall NumDxBxú@@:
endif
 mov bx,V.MantLow
 Downúcall ToDsSiCxúdec bx
; Lower position offset, bx, to within string or at end.
 cmp bx,cxújna @Fúmov bx,cxú@@:
 test al,81hújs @3p21Threeújpo @3p21Four
; Two arguments. Default length is the rest.
 mov dx,cxúsub dx,bx
; When there is no padding there will be no need for allocate and move.
@3p21NoPad:cmp dx,7újna @F
 add V.Pt,bxúmov V.Len,dxúpop CursorSiúBackRet
@@:add si,bxúmov ecx,Dptr[si]úmov ebx,Dptr[si+4]
 mov Dptr(V.String),ecxúmov Dptr(V.String+4),ebx
 add dl,$NullStringúmov V.Dtype,dl
BackEsSi:
 mov ProgEs,Z.ProgScope
 pop CursorSi
 BackRet

@3p21Alloc:;cx pad length, dx total length, ds:si source.
xchg cx,dxúcall AllocateCx_EsAxúxchg dx,cxújnc @3p21Move
; Compaction will have invalidated ds:si
 push cxúcall ToDsSiCxúpop cxújmp @3p21Move

; Default pad is ' '
@3p21Three:mov Bptr(V4.String),' '
@3p21Four:
; Arg 3 is known to be binary since if the types were checked at runtime it
; would have been converted then and if the types passed check at compile
; time the constant would be stored as binary.
; (For Bcode there is risk but hopefully they are coded to cope.)
 mov dx,V3.MantLow
; Data move is necessary only if there is padding. Change cx to amount of pad.
 mov ax,bxúadd ax,dxúsub ax,cxújna @3p21NoPadúmov cx,ax
; New space not necessary for short results.
 cmp dx,7úja @3p21Allocúmv es,dsúmov ax,si; es:ax is target.
@3p21Move:push axúsub dx,cxúxchg cx,dx; cx chars from original, dx chars of pad
; Copy it. Direction of move is OK when source is short.
 push StackDiúadd si,bxúmov bl,V4.Stringúmov di,axúRepmovsb
 mov al,blúmov cx,dxúrep stosbúpop StackDi
 mov ax,V3.MantLowúcmp ax,7úja @3p21Long
 add al,$NullStringúmov V.Dtype,alúPopJunk si
 jmp RetEsSi

@3p21Long:mov V.Len,axúmov V.Sg,esúpop V.Pt
 call Away
 jmp RetEsSi

if Solid
;$9.3.22údb $WholeGEúdb $WholeGTúParmsRec <2,1,1001b>
BifSUBWORD:
endif
 Downúmov V4.Dtype,al;Just a place to save it.
; V3 is optional, number of words.
 test al,81hújz @Fúdec V3.MantLowújs @3p22Nullú@@:
; Address string, move si to first wanted word.
 call ToDsSiCxúcall WordIndex
 JcxzQ @3p22Null
 dec siúmov dx,si
; Omitted third parameter means all residual string except trailing blanks.
 test V4.Dtype,81hújz @3p22Clip
; Move on past word that was found.
@@:lodsbúXlatBDLSújz @FúLoopQ @Bújmp @3p22Done
; Third parameter is count of words. (Already decremented)
@@:dec siúmov ax,V3.MantLowúTestReg axújz @3p22Doneúmov V2.MantLow,ax
; Move on to beginning of the last word.
 call WordIndexúJcxzQ @3p22ClipXúdec cx
; Move on past that word.
@@:lodsbúXlatBDLSújz @FúLoopQ @Búinc siú@@:dec si
; Wanted is from dx up to si.
@3p22Done:mov cx,siúmov si,dxúsub cx,si
 cmp cx,7úja @3p22Long
 mov edx,Dptr[si]úmov ebx,Dptr[si+4]
 mov Dptr(V.String),edxúmov Dptr(V.String+4),ebx
 add cl,$NullStringúmov V.Dtype,clúpop CursorSiúBackRet
; If it is long now it must have been a long source.
@3p22Long:mov V.Pt,siúmov V.Len,cxúpop CursorSiúBackRet
@3p22Null:mov V.Dtype,$NullStringúpop CursorSiúBackRet

@3p22ClipX:; Recovery end position.úcall ToDsSiCx
@3p22Clip:; Scan back from far endúadd si,cx
@@:mov al,Bptr[si-1]úXlatBDLSújnz @3p22Doneúdec siújmp @B

if Solid
;$9.3.25údb $WholeGTúParmsRec <2,0,1011b>
BifWORD:; Set what will be third arg of subword.
endif
 mov V2.Mantissa,ebpúmov Bptr V2.Mantissa,1
 mov al,80h; Tell SUBWORD of extra parameter.
 jmp BifSUBWORD

if Solid
;$9.3.26údb $WholeGTúParmsRec <2,0,1011b>
BifWORDINDEX:; Share subroutine with SUBWORD.
endif
 Downúcall ToDsSiCx; Address the string.
 mov dx,siúcall WordIndexúsub si,dxúmov V.MantLow,si
 mov V.ExpAnd,ebpúz V.MantHighúpop CursorSiúBackRet

WordIndex:; Used on Ds:Si:Cx. If not found si not changed (and cx=0), else
; si one beyond found character (and cx one more than matching si).
; Requires V2.Mantissa as first word count, which is zeroed.
; ax is altered, bx set to the table.
 push siúJcxzQ @3p26Zero
 mov bx,Attributes; Prepare to test AllBlanks.
; Move SI on to nonblank.
 inc si
@3p26LoopX:dec si
@3p26Loop:lodsbúXlatBDLSújnz @FúLoopQ @3p26Loopújmp @3p26Zero
; Is this the wanted word?
@@:dec V2.Mantissaújz @3p26
 dec si; Simplest
; Move SI on to blank and cycle.
@@:lodsbúXlatBDLSújz @3p26LoopXúLoopQ @B
@3p26Zero:pop CursorSiúBackRet
@3p26:pop axúret

if Solid
;$9.3.30
 db $Padúdb $PadúParmsRec <0,2,0011b>
BifXRANGE:; cl for 'around to', dl for 'first value'.
endif
 z dxúmov cx,0FFhútest al,81hújz @3p30úmov cl,V2.Stringújs @3p30
; Two extras present.
 mov dl,V2.String
 mov cl,V3.String
@3p30:sub cl,dlúinc cx
 Up
 call ResultSpace
 JcxzQ @3p30ret
 push StackDi
 mov di,axúmov al,dl
@@:stosbúinc alúloop @B
 pop StackDi
@3p30ret:
 jmp RetEsSi

if Solid
;$9.4.1
 db $NumúParmsRec <1,0,0111b>
BifABS:
endif
 call NumDxBx; !! not required when we change constants.
; Longs in bifs !!
 and V.Sign,0FEhúpop CursorSiúBackRet

if Solid
;$9.4.5
 db $NumúParmsRec <1,0,0111b>
BifSIGN:
endif
 call NumDxBx
 mov ecx,ebpútest V.Sign,1újz @Fúinc cxúmov V.ExpAnd,ecxújmp @4p5ú@@:
 mov V.ExpAnd,ebpúcmp V.Mantissa,ebpújz @4p5úinc cx
@4p5:mov V.Mantissa,ecx
 pop CursorSiúBackRet

if Solid
;$9.5.1
 db "EINO"údb -@SizeStr(<EINO>)úParmsRec <0,1,0111b>
BifADDRESS:; More to come
endif
 call HeritageDi
; L.Active.EnvNumber identifies the address. Jan 00 not decided on where
; actual name is.
 pop StackDi
; Return "DOS" for now.
 Up
 mov ecx,Y.DOS
 mov Dptr(V.String),ecx
 mov Bptr(V.Dtype),$NullString+3
 pop CursorSiúBackRet

if Solid
;$9.5.2
 db "ENO"údb -@SizeStr(<ENO>)údb $WholeGTúParmsRec <0,2,0011b>
BifARG:
endif
; Moot point whether we should have put both ends of arglist in the
; Level block.  (Loses when BifARG not used.)
; Si to be result, most cases.
 Upúcmp Z.ResumeP,ZeroBpúje @5p2Pcode
; Crude for BCycle bifs.  Only MAX MIN FORMAT use arg() internally.
 movzx si,Z.ArgsBúinc siútest al,81hújz @5p2None
; Numeric arg index to bx
 call NumDxBxúmov cx,Z.ArgsB0újmp @5p2One

@5p2Pcode:mov si,Z.Levelúmov cx,Lsi.Arg0úsub si,$StrideL
 sub si,cxúshr si,$ShiftV; arg()útest al,81hújz @5p2None
; Numeric arg index to bx
 call NumDxBxútest al,81hújs @5p2One
; There is an option.
 Upúcall UpperFirstAh; to ahúDown
; arg(9999) will be non-existant
 cmp bx,siúz siúja @5p2Omitted
 shl bx,$ShiftVúadd bx,cx
 cmp Vbxs.Dtype,$Omittedúje @Fúinc siú@@:
@5p2Omitted:cmp ah,'O'újne @5p2None
 xor si,1
@5p2None:; Use si as the result.
 mov V.ExpAnd,ebpúmovzx esi,siúmov V.Mantissa,esi
@5p2Ret:pop CursorSiúBackRet
@5p2One:cmp bx,siúmov V.Dtype,$NullStringúja @5p2Ret
 shl bx,$ShiftVúadd bx,cx
 Move V,Vbxs,edx
 jmp @5p2Ret

if Solid
;$9.5.3
 db "CDEIS"údb -@SizeStr(<CDEIS>)úParmsRec <0,1,0111b>
BifCONDITION:
endif
 Up; Arg, will be result.
 test al,81hújz @5p3I; Default is 'I'
 call UpperFirstAh
 cmp ah,'D'újne @F
 call HeritageDiúmov LevelSi,LevelDiúpop StackDi
 Move V,Lsi.ConditionDescription
 RetSi
@5p3I:
@@:Error49Bp

if Solid
;$9.5.4
 ParmsRec <0,0,1111b>
BifDIGITS:
endif
 mov cx,Z.Digits
@5p4Like:Upúz V.MantHighúmov V.MantLow,cxúmov V.ExpAnd,ebp
 pop CursorSiúBackRet
if Solid
;$9.5.6
 ParmsRec <0,0,1111b>
BifFORM:
endif
 call HeritageDiúmov al,L.Formúpop StackDiúUp
 mov bx,$?Súcmp al,'S'úje @Fúadd bx,$?E-$?Sú@@:
 Move V,Vbxe
 pop CursorSiúBackRet

if Solid
;$9.5.7
 ParmsRec <0,0,1111b>
BifFUZZ:
endif
 mov cx,Z.Fuzzújmp @5p4Like

if Solid
;$9.5.8
 db $WholeGTúParmsRec <0,1,0111b>
BifSOURCELINE:
endif
 lds bx,Z.SysFileúmov ecx,F.Lines
 test al,81hújnz @5p8One
; No args - return line count of file.
 call Zero$$úmov V.Mantissa,edx
 RetSi
@5p8One:; Check against current source file line count.
 Upúcall ToWholeEbxúcmp ebx,ecxúmov al,34úja Raise40
 Error49Bp; NYI

if Solid
;$9.5.9
TraceVerb$:
  db "ACEFILNOR?"údb -@SizeStr(<ACEFILNOR?>)úParmsRec <0,1,0111b>
BifTRACE:
endif
; 2011 There is no mandatory argument to TRACE. So the general bif
; mechanism will have set StackDi to reflect no argument and set
; Al to the Pcode byte value, which contains count of the optionals.
; Collect any parameter, setup LevelDi, and note previous trace setting.
 z siútest al,81hújz @FúUpúcall ToDsSiCxúDownú@@:
 call HeritageDiúmov dx,L.TraceWord
; If there was a parameter, alter trace setting to reflect it.
 TestReg siújz @5p9Showúmov al,'N'úJcxzQ @5p9Null
@@:lodsbúcmp al,'?'újne @Fúbtc L.TraceWord,InteractiveúLoopQ @Bújmp @5p9Show
@@:cmp al,'a'újb @Fúcmp al,'z'úja @Fúand al,0DFhú@@:cmp al,'O'újne @F
@5p9Null:Off L.TraceWord,Interactiveú@@:mov L.TraceLetter,al
@5p9Show:; Letter or Questionmark letter.
; 2011 Up whether optional or not, to place for result.
; pop StackDiúTestReg siújnz @FúUpú@@:
 pop StackDiúUp
 mov al,$NullString+1úQry dh,Interactiveújz @Fúinc axúmov dh,dlúmov dl,'?'ú@@:
 mov Wptr(V.String),dxúmov V.Dtype,alúRetSi

Trace$:call ToDsSiCxúcall HeritageDiúmov al,'N'úJcxzQ InterOff
@@:lodsbúcmp al,'?'újne @Fúbtc L.TraceWord,InteractiveúLoopQ @Bújmp TraceRet
@@:cmp al,'a'újb @Fúcmp al,'z'úja @Fúand al,0DFhú@@:
; Test match in string.
 mv ds,csúmov SpecsBx,TraceVerb$úmov cx,@SizeStr(<ACEFILNOR>)
@@:cmp al,Bptr[SpecsBx]úje TraceOKúinc SpecsBxúloop @B
 pop StackDiúmov V.String,alúmov ax,MkMajMin(24,1)
 mov V.Dtype,$NullString+1újmp Raise
TraceOK:cmp al,'O'újne @F
InterOff:Off L.TraceWord,Interactive
@@:mov L.TraceLetter,al
TraceRet:pop StackDiúDownúpop CursorSiújmp DualSwitch

; TRACE verb.
Trace$$:push CursorSi
; Omitted parameter was supplied at compile time.
 call NumDxBxújc Trace$
 call ToWholeEbxúmov ax,MkMajMin(26,7)újc Raise
; Z.InhibitTrace Z.InhibitPauses NYI
 pop CursorSi
 jmp DualSwitch

if Solid
;$9.7.1
 db $WholeGEúdb $WholeGTúdb $StreamúParmsRec <0,3,0001b>
BifCHARIN:
endif
 Error49Bp

if Solid
;$9.7.2
 db $WholeGTúdb $StreamúParmsRec <0,3,0101b>
BifCHAROUT:
endif
 Error49Bp

;MASM..............................
if Solid
;$9.7.8
; Further test.
 db "CDS"údb -@SizeStr(<CDS>)údb $StreamúParmsRec <1,2,0011b>
BifSTREAM:
endif
 Error49Bp

if Solid
;$9.8.2
 ParmsRec <0,0,1111b>
BifQUEUED:
endif
; We also use this one for just loading the value of a Bcode variable the
; stack.
 Qry Z.Cancel,BcodeInterpretújz @F
; See B4VALUE2
 UpúMove V,Ve[$?OUTCOME]úRetSi

; The Rexx queue is in Z.Serial when acted on.
@@:mov al,$SerialQueúcall Serialize
; Length of aggregate is first word of Z.Serial.
; Items have their length at both ends of the item.
 z cxúz si
@@:cmp si,Wptr Z.Serialújnb @Fúinc cxúadd si,Wptr ss:Z.Serial[si+2]újmp @B
@@:Upúz V.Mantissaúz V.ExpAndúmov Wptr V.Mantissa,cx
 pop CursorSiúBackRet

if Solid
;$9.8.3
 db $WholeGEúdb $WholeGEúdb $WholeGEúParmsRec <0,3,0001b>
BifRANDOM:
endif
 Up; Adjust to position of result.
; set ecx=minimum ebx=maximum
 z ecxúmov ebx,Y.N1000údec ebx
 test al,81hújz @3p8Noneújpe @3p8Threeújns @3p8Two
 mov ebx,V.Mantissaúcmp ebx,Y.N1e5újbe @3p8None
 mov al,31újmp Raise40
@3p8Three:
@3p8Two:cmp V.Dtype,$Omittedúje @Fúmov ecx,V.Mantissaú@@:
 cmp V2.Dtype,$Omittedúje @Fúmov ebx,V2.Mantissaú@@:
; Put Min and Max down for messages. (And result)
@3p8None:mov V.Mantissa,ecxúmov V.ExpAnd,ebp
 mov V2.Mantissa,ebxúmov V2.ExpAnd,ebp
; Change ebx to be the range.
 sub ebx,ecxújz @3p8Outújl Raise40p33úcmp ebx,Y.N1e5újg Raise40p32
; The rest follows IBM but I don't suppose they will mind since Rick
; told SHARE all about it and inventive part is from Knuth.
 cmp al,81h+2*$BifRANDOMújne @F
; ConfigRandomSeed
 mov ecx,V3.Mantissaúnot ecxúmov Z.Seed,ecxúOn Z.Program,RandomSeeded
 jmp Fiddling;
@@:bts Z.Program,RandomSeededújc Seeded
; Set cx and dx from timer.
 mov ah,$DosTimeúint 21húmov Wptr Z.Seed,cxúmov Wptr Z.Seed+2,dx
; Might as well include the date.
 mov ah,$DosDateúint 21húxor Wptr Z.Seed,cxúxor Wptr Z.Seed+2,dx
Fiddling:
; Try to remove some non-randomness in relations of bits.
 mov cx,13ú@@:call Randomúloop @B
Seeded:call Random
; Convert latest internal to result. First reverse the bits.
 mov cx,32ú@@:rcl eax,1úrcr edx,1úloop @Búmov eax,edx
; Divide by range+1
 inc ebxúz edxúdiv ebxúadd V.Mantissa,edx
@3p8Out:pop CursorSiúBackRet
Random:; ConfigRandomNext
 mov eax,Z.Seedúmul Y.N1664525úinc eaxúmov Z.Seed,eaxúret

if Solid
;$9.8.4
 ParmsRec <1,0,1111b>
BifSYMBOL:
endif
 call ToDsSiCx
; We are not setup to share code with compile time because "next char" at
; compile time can mean detecting end-of-buffer while execution time is
; about a string with length count.
; So we can share amongst SYMBOL & VALUE & VarPool & DROP() & EXPOSE()
; but not much more without a rewrite.
 JcxzQ IsBad
 call SymbolLookúJcxzQ @F
IsBad:mov Dptr V.String,StringOrder('B','A','D',' ')újmp RetSym
@@:test bx,bxújnz IsLit
; NYI What nonsense bx is not result of Lookup.
 cmp Vbx.Dtype,$Droppedúje IsLit
 mov Dptr V.String,StringOrder('V','A','R',' ')újmp RetSym
IsLit:mov Dptr V.String,StringOrder('L','I','T',' ')
RetSym:mov V.Dtype,$NullString+3úpop CursorSiúBackRet


; DS:SI:CX is the string to scan. Scan ends with string exhausted or end of
; part with symbol syntax. SI & CX are updated.  AX used. DX kept.
; Carry set iff not syntax of symbol.
; bx = 0 for a variable name.
SymbolLook:; si set to be past symbol.  bx used.
 push dxúJcxzQ SymBadúmov bx,Attributesúz dx
; First character a letter if this is a variable name.
 mov al,[si]úmov RawCharAh,alúXlatBDLS
 jpe SymBadújns SymLitúcmp RawCharAh,'.'úje SymLit
; Go to limit of letters and digits.
SymLoop:inc dxúlodsbúXlatBDLSújpe @FúLoopQ SymLoopú@@:
 cmp dx,$Limit_Nameúja SymBad
 z bxúclcúpop dxúret
SymBad:stcúpop dxúret

; Scan to distinguish BAD from LIT.
SymRec record SRpad:11, HadDigits:1, HadDot:1, NotNumber:1, HadSign:1, HadE:1

SymLit:lodsb; At most one dot in a number.úcmp RawCharAl,'.'
 jne @Fútest dl,mask HadSignújnz SymBadúbts dx,HadDotújc SymNotNumú@@:
; Specials not allowed except +- absorbed by exponent.
 XlatBDLSújpe SymBadújs SymLetúor dl,mask HadDigitsújmp SymLoo
SymLet:test dl,mask NotNumberújnz SymLoo
 JcxzQ SymNotNumútest al,$Eeújz SymNotNum
 test dl,mask HadDigitsújz SymNotNum
 bts dx,HadEújc SymNotNum
 cmp Bptr[si],'+'úje SymSign
 cmp Bptr[si],'-'újne SymLoo
SymSign:test dl,mask NotNumberújnz SymBadúinc siúdec cxúor dl,mask HadSign
SymLoo:LoopQ SymLit
 clcúpop dxúret

SymNotNum:test dl,mask HadSignújnz SymBadúor dl,mask NotNumberújmp SymLoo

Raise40p26:mov al,26újmp Raise40

if Solid
;$9.8.6
; Could have $Symbol here but better to do that in the routine.
 ParmsRec <1,2,1111b>
BifVALUE:
endif
 test al,81hújg @8p6Threeújnz @8p6Two
; One argument - return it's value.
; Check it is not a bad symbol before do special interpret to get value.
 call ToDsSiCxúJcxzQ Raise40p26
; We need a valid symbol and nothing left over.
 call SymbolLookújc Raise40p26úTestReg cxújnz Raise40p26
 pop CursorSiúmov dx,offset B4VALUE1úcall LinkBcodeúmov Z.Stack,StackDi
 UpúMove V,Ve[$?OUTCOME]úret
@8p6Two:; Check first is non-constant symbol.
 call ToDsSiCxúJcxzQ Raise40p26
 call SymbolLookújc Raise40p26úTestReg cxújnz Raise40p26
 TestReg bxúmov al,43újnz Raise40
 Upúpop CursorSiúmov dx,offset B4VALUE2újmp LinkBcodeúmov Z.Stack,StackDi

@8p6Three:; DOS environment pool.
; Since the code is in the DOS system for Get/Set of these variables it is
; a shame it is not made available. Still, doesn't look like it is.
; !! Check 3rd arg value. "ENVIRONMENT" used by Personal REXX.
; IBM DOS 7 ??
comment~ DOS hold the environment data in a segment, which means it's size
is available.  I have to assume it is safe to alter the content, within the
confines of the segment.
~
; NYI.  go back 13 bytes for word with para length. 'M' and our CS before.
; Check out the pool name.(NYI - use DosPool & length check)
 add StackDi,2*$StrideV
 call CONFIG_UPPER$$úcall ToDsSiCxúmov al,37úJcxzQ Raise40
 mv es,csúpush diúmov di,Yshape.DOSúrepe cmpsbúpop diújne Raise40
; Fold the value's name, even in the environment case.
 sub StackDi,2*$StrideV
 call CONFIG_UPPER$$úcall ToDsSiCx
; PSP ahead of code.
 mov ax,csúsub ax,10húmov es,axúmov es,es:[2Ch]úpush StackDiúz di
@8p6Env:cmp Bptr es:[di],0úmov al,36újz Raise40
; Compare this one with given.
; Maybe some chaos if a null in user's string? Or an '='?
 push cxúpush siúrepe cmpsbúpop siúpop cxújnz @F
 cmp Bptr es:[di],'='úje @8p6
; Advance to next in environment.
@@:cmp Bptr es:[di-1],0úje @8p6Envúinc diújmp @B

@8p6:; Value follows after '=' up to null.
 inc diúmov cx,-1úz axúrepne scasb; Find the null
 neg cxúdec cxúmov si,diúsub si,cxúdec cx; SI for CX is result.
; Copy to be result.
 mv ds,esúpop StackDiúcall ResultSpace
 push StackDiúmov di,axúRepmovsbúpop StackDi
 jmp RetEsSi

if Solid
;$9.3.14
 ParmsRec <1,0,1111b>
BifLENGTH:
 Error49Bp; Not done by bif mechanism.
endif

@@:push CursorSiúcall ToDsSiCxúpop CursorSi
Length$$:mov cl,V.Dtypeútest cl,$Testújns @B
 mov V.ExpAnd,ebpúz V.MantHigh
 jpe @Fúand cx,7úmov V.MantLow,cxú@@:BackRet

 include bifs.inc
 end
