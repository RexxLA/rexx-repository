;------------------------------------------------------------------------------
; Processing for tracing proceeds clause by clause.
;------------------------------------------------------------------------------
comment~ Rexx tracing shows the clause before executing but doesn't pause until
a clause ends.  Showing and executing are different activities - all the clause
will be shown even if the raising of a condition means that it isn't all
executed.

To do the execution aspects of tracing, extra Pcode is made transiently on a
clause-by-clause basis.  This extra Pcode has the same format and opcodes as
ordinary (fast-form, original) Pcode but with an extra opcode $pTraceEvent used.

The sequence of activity is:

a) Fast-form Pcode is made for the whole source file and execution begins.

b) After a TRACE instruction (or TRACE bif) there is a
test for whether tracing is needed.  When the need for tracing is detected a
non-producing parse is done, (Synch), to put the source position and the
execution position in step.

c) Pcode, including trace events, is generated for the clause. Any jump targets
in this transient Pcode take their values from the original Pcode. During this
generation the limit of the source relating to this clause is noted.
See ClauseSourceEnd.
Also the offset of the original Pcode following the clause is noted.

d) The source is shown if the trace setting requires that.

e) The transient Pcode is executed. The effect is the same as ordinary Pcode
plus writing to the trace file when $pTraceEvent opcodes are executed.
However, the operations are monitored for whether they produce jumps.

e) The trace event for end-of-clause will be executed.

There are some complications:

When the TRACE bif starts the trace, there will be no source shown for that
clause, so TraceSource is irrelevant.  It is marked negative to indicate this.

When the TRACE instruction starts the trace, we do not want the Action91 at
the end of that clause to compile an end-of-clause event.  The setting of
DualGen has to be delayed until after, by the DualPending flag.
~

comment~ When tracing there will be transient separate Pcode made for each
clause and it will be executed by XCycle.  It uses the same set of
Pcode operators as are available to XCycle but also has those which come here.
Code here checks after each operator
is executed to see if there have been a jump.
(NYI.The idea is that fallthru could avoid a synch but this version synchs
anyway.)
~

Monitor:; The same action as for XCycle operations. See label Operator.
 movzx bx,al
 mov Z.Stack,StackDi; Record of how much stack in use needed for Compaction.
 call cs:(PcodesBase$-1)[bx]
; The CursorSi now will tell us whether the operation resulted in a jump.
; A jump target is in the original Pcode so will be below the transient Pcode.
 cmp CursorSi,Z.DualCodeújnb XCycle
; We jumped out of that clause. That ends the clause and tells us where to
; start the next.
JumpedOut:
 mov Z.Cursor,CursorSi
; Clause can end by reason of jump or by $TraceEndClause event at end.
ClauseRunEnd:
 Off Z.Cancel,ParseTrace
 mov CursorSi,Z.Cursor; Next clause, on the original.
; If it is the $pExit synthesised on the end of the original program then there
; is no corresponding source.
 lea ax,1[CursorSi]
 cmp ax,Hg.Original
 je StartExecutionY; Run the original $pExit
DualSwitch:; CursorSi is ready for the next clause.
 mov sp,Z.XCycleResetSp
; There may be no reason to stay in (or enter) clause-by-clause mode.
 call HeritageDiúmov al,L.TraceLetterúpop StackDi
; Make sure of ShowClauseId each time tracing starts up.
 Qry Z.Gen,Dualújnz @Fúz Z.TraceLineú@@:
 cmp al,'N'úje XCycleúcmp al,'O'úje XCycle
; Do the next clause by dual method.
 mov Z.Synch,CursorSi
 mov Z.Gen,mask Dual
 mov Z.Cursor,$StrideH
 call Compiling
; Bounds of the source will have been a compiling by-product.
; Convert the current letter to a set of flags.
 call HeritageDi
 movzx bx,L.TraceLetterúmov dl,cs:$TraceLetter[bx-'A']úpop StackDi
 test dl,$TraceAújz NotTraceA
; ELSE has special treatment.
 Qry Z.Program,ShowELSEújnz MonNotThen
; We want the lines of source between Z.TraceSource and Z.TraceEnds.
; THEN is special. We had to push on over it in the source but it isn't
; supposed to show if the THEN clause isn't executed.
 mov CursorSi,Z.DualCode
 inc CursorSi; Over $pTraceEvent
 cmp Bptr gs:[CursorSi],$pThenúje @F
 cmp Bptr gs:[CursorSi],$pWhenújne MonNotThen
@@:inc CursorSi; Over $pThen
; Have to run THEN before (perhaps) showing it.
 call Then$$
 On Z.Program,ShowELSE
 cmp CursorSi,Z.DualCodeújb JumpedOut; Nothing shown
 mov Z.DualCode,CursorSi
 Off Z.Program,ShowELSE
MonNotThen:
; ELSE is special. The unconditional jump it puts at the end of a THEN leg,
; if executed, does not have any corresponding source shown.
 cmp Bptr gs:[CursorSi],$pJumpúje ExecuteDual; Showing no source.
; Our window on the source is Z.Relative onwards for $SourceBufferSize-2.
; No need to refetch if what we want is in the window.
 mov ecx,Z.TraceSource
 cmp Z.SerialNow,$SerialSourceújne @F
 mov edx,Z.Relativeúcmp ecx,edxújb @F
 add edx,$SourceBufferSize-2úcmp edx,Z.TraceEndsúja NoNeedSource
@@:mov Z.Relative,ecxúmov al,$SerialSourceúcall Serialize
NoNeedSource:mov esi,ecxúsub esi,Z.Relativeúadd si,Zshape.Serial
; Bytes to show start at SS:SI
 mov Dptr(Z.Tag+1),StringOrder('*','-','*',' '); For first ShowClauseId
; Dont show leading $Lf
 mv ds,ssúcmp Bptr[si],$Lfújne @Fúinc siúinc ecxúz Z.TraceSourceColumnú@@:
 mov dx,siúcmp ecx,Z.TraceEndsújnb NotTraceA
TSloop:lodsbúcmp al,$Lfújne TSnext
 call ShowLine; dx up to si
TSnext:inc ecxúcmp ecx,Z.TraceEndsújne TSloop
; If there is anything to show at this point it will not end with a line-feed.
; One has to be added.
 cmp si,dxúje NotTraceA
 call ShowLine
 mv ds,csúmov dx,Yshape.CrLfúmov cx,2
 mov ah,$DosWriteúint 21h
NotTraceA:
  btr Z.Program,ShowELSEújnc ExecuteDual
; Go again with same Z.Synch but flag off.
 mov CursorSi,Z.Synchújmp DualSwitch

; Code with trace events starts at Z.DualCode, ends with $TraceEndClause.
ExecuteDual:mov CursorSi,Z.DualCodeújmp StartExecutionY

; Convert letter to flags, allowing for 'C' includes 'E' etc.
$TraceO equ 0
$TraceB equ 1; TraceBack
$TraceA equ 2
$TraceC equ 4
$TraceE equ 8
$TraceF equ 16
$TraceI equ 32
$TraceL equ 64
$TraceR equ 128
if Solid
; Whatever the letter, traceback is enabled.
$TraceLetter db $TraceA+1údb ?údb $TraceC+$TraceE+1údb ?
 db $TraceE+1údb $TraceF+1údb ?údb ?údb $TraceA+$TraceI+1údb ?údb ?
 db $TraceL+1údb ?údb $TraceF+1údb $TraceO+1údb ?údb ?údb $TraceA+$TraceR+1
endif

; Convert trace event number to what letter (mask) enables it.
if Solid
$TrEv equ $
 org $TrEv+3*$TraceClause/2
 db $TraceA+$TraceI+$TraceR
 db "*-" ; Source, as with All
 org $TrEv+3*$TraceExpr/2
 db $TraceR
 db ">>" ; Results
 org $TrEv+3*$TraceBY/2
 db $TraceR
 db ">+" ; BY
 org $TrEv+3*$TraceDot/2
 db $TraceR
 db ">." ; Parse .
 org $TrEv+3*$TraceAssign/2
 db $TraceR
 db ">=" ; Assign, parse assign.
 org $TrEv+3*$TraceCompound/2
 db $TraceI
 db ">C" ; Parts of a compound reference.
 org $TrEv+3*$TraceLit/2
 db $TraceI
 db ">L" ; Literal
 org $TrEv+3*$TracePrefix/2
 db $TraceI
 db ">P" ; Prefix operator
 org $TrEv+3*$TraceOperator/2
 db $TraceI
 db ">O" ; Other operator
 org $TrEv+3*$TraceFunction/2
 db $TraceI
 db ">F" ; Function reference.
 org $TrEv+3*$TraceVar/2
 db $TraceI
 db ">V" ; Variable
 org $TrEv+3*$TraceError/2
 db $TraceE
 db "++" ; Return code
 org $TrEv+3*$TraceFailure/2
 db $TraceF
 db "++" ; Return code
 org $TrEv+3*$TraceBack/2
 db $TraceB; Highest
 db "*T" ; Traceback
; Also "*-"  and "*," for source.
endif

TraceEvent$$:lodsb gs:[CursorSi]
; Odds are Pcodes, evens are particular causes of tracing.
 test al,1újnz Monitor
; $TraceEndClause is special because it ends the transient code.
 cmp al,$TraceEndClauseúje ClauseRunEnd
; Just set a flag when PARSE.
 cmp al,$TraceParseújne @FúOn Z.Cancel,ParseTraceúretú@@:

; Normal entry is from XCycle but there is this one from mid-parse. (With more
; registers in use. DsSiCx )
TraceEventX:push CursorSi; (SI is not CursorSi when from mid-parse)
; Convert the current letter to a set of flags.
 call HeritageDi
 movzx bx,L.TraceLetterúmov dl,cs:$TraceLetter[bx-'A']úpop StackDi
; Note whether letter (mask) enables this event.
; Event of loading Var becomes event of loading Lit if variable is dropped.
 btr Z.Cancel,WasDroppedújnc @Fúmov al,$TraceLitú@@:
 cbwúmov bx,axúshr bx,1úadd bx,axúand dl,Bptr cs:$TrEv[bx]újz TrEvRet
; Note the tag for the line to be shown.
 mov bx,cs:$TrEv[bx+1]úmov Wptr Z.Tag+1,bxúmov Z.Tag+3,bl
; DL now says what is to be shown.
 cmp al,$TraceAssignújne NotAssign$
; The assign in parse does not have a value of the stack. It is DS:SI:CX
 Qry Z.Cancel,ParseTraceújz ShowTop
@@:; We need some reasonable place on the stack, to make it similar to others.
 mov StackDi,Z.Stackúadd StackDi,2*$StrideVúcall VasDsSiCxújmp ShowTop
NotAssign$:cmp al,$TraceDotúje @B
 test dl,$TraceC or $TraceI or $TraceRújz NotTop
ShowTop:
; The value to be shown is on the stack.
 mov bx,Z.Stdoutúcall ShowClauseId
 mv ds,csúmov dx,Yshape.DqCrLfúmov cx,1
 mov ah,$DosWriteúint 21h; Takes ds:dx:cx to file bx
; We want to leave V. the way we found it.
; But cannot but V. back to numeric until showing done.
 test V.Dtype,$Testúpushfúcall ToDsSiCxúpush cx
 cmp cx,$Limit_Insertújna @Fúmov cx,$Limit_Insertú@@:
 mov dx,si
; Better not let things like e-o-f show.
; How to do that without altering version in memory?
; Maybe show char by char if troubled? NYI
 mov ah,$DosWriteúint 21h; Takes ds:dx:cx to file bx
 mv ds,csúmov dx,Yshape.DqCrLf
; "..." preceeds CrLf, if truncation.
 pop cxúcmp cx,$Limit_Insertúmov cx,2újna @Fúsub dx,3úmov cx,5ú@@:
 mov ah,$DosWriteúint 21h
 popfújnz @Fúcall NumDxBxú@@:
 RetSi

NotTop:

 test dl,$TraceE or $TraceFújz NotRC
; Show RC=
 mv ds,csúmov dx,offset RCisúmov cx,3úmov ah,$DosWriteúint 21h
; Move to stack
 UpúMove V,Vf[$?RCx]újmp ShowTop

NotRC:Error49Bp; L & T

TrEvRet:RetSi

RCis db "RC="

ShowClauseId:; BX is target file.
 push siúpush dxúpush cx
; TraceWidth to dl - how many columns for the number.
 push bxúlds bx,Z.SysFileúmov dl,F.TraceWidthúpop bx
 mov ax,Z.ClauseLine; Current - previously shown is in Z.TraceLine
; Produce nothing for equal line number by using zero with full blank suppress.
 mov cx,axúxchg cx,Z.TraceLineúcmp ax,cxújne @Fúz axú@@:call Ax2DsSiCx
 TestReg axújnz @Fúmov Z.AxAsNum+(sizeof Zshape.AxAsNum)-1,' 'ú@@:
; Bring small numbers up to length dl by adding leading blanks.
@@:cmp cl,dlújae @Fúinc cxúdec siúmov Bptr[si],' 'újmp @Bú@@:
; Write from SI onward.
 mov dx,siúadd cx,5; Blank-tag-blank.
 mov ah,$DosWriteúint 21h; Takes ds:dx:cx to file bx
 mov Z.Tag+2,','; For case of Tag was *-*
 pop cxúpop dxúpop si
 ret

ShowLine:; Show SS:DX to SS:SI. Advances DX
 mov bx,Z.Stdoutúcall ShowClauseId
 pusha
; Alignment may be needed.
 movzx cx,Bptr Z.TraceSourceColumn; Bug havoc potential reduction.
@@:jcxz @Fúdec cxúcall ShowBlankújmp @B
@@:mov cx,siúsub cx,dx
 mov ah,$DosWriteúint 21h
 mov dx,si; Ready for next.
 popa
 ret

ShowBlank:pusha
 mov dx,Zshape.Tag; Which is a blank
 mov cx,1
 mov ah,$DosWriteúint 21h
 popaúret

ClauseSourceEnd:; Records end of a clause in source.
; This is the end of the clause from a source view point - the semicolon,
; linefeed, THEN, ELSE.
 push ScanSiúpush ax
 sub ScanSi,Zshape.Serialúmovzx esi,siúadd esi,Z.Relative
 mov eax,esi
; End of previous was beginning of this.
 xchg Z.TraceEnds,esiúmov Z.TraceSource,esi
; Also need the column.
 sub eax,Z.TraceAlignúxchg ax,Z.TraceEndsColumnúmov Z.TraceSourceColumn,ax
 pop axúpop ScanSiúret

;------------------------------------------------------------------------------
; Ax as a number in AxAsNum
; ds and si and cx set up for movsb
;------------------------------------------------------------------------------
Ax2DsSiCx:push axúpush bxúpush dxúmv ds,ss
; Radix always reverts to 10
 mov bx,10úxchg bl,Z.Radixúz cx
; Convert and store backwards
 mov si,Zshape.AxAsNum + (sizeof Zshape.AxAsNum)
Ax2:z dx; Clear top
 div bx; Divide to get last digit as remainder
 add dl,'0'; Convert to ASCII
; ABCDEF are not immediately after 0123456789
 cmp dl,'9'újbe @Fúadd dl,7ú@@:
 dec siúmov [si+bp],dlúinc cx
 TestReg axújnz Ax2
; Make it even unless going to decimal.
 test cl,1újz @Fúcmp bl,10úje @Fúdec siúmov Bptr [si+bp],'0'úinc cxú@@:
 pop dxúpop bxúpop ax
 ret

