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
 cmp CursorSi,Z.DualCode�jnb XCycle
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
 call HeritageDi�mov al,L.TraceLetter�pop StackDi
; Make sure of ShowClauseId each time tracing starts up.
 Qry Z.Gen,Dual�jnz @F�z Z.TraceLine�@@:
 cmp al,'N'�je XCycle�cmp al,'O'�je XCycle
; Do the next clause by dual method.
 mov Z.Synch,CursorSi
 mov Z.Gen,mask Dual
 mov Z.Cursor,$StrideH
 call Compiling
; Bounds of the source will have been a compiling by-product.
; Convert the current letter to a set of flags.
 call HeritageDi
 movzx bx,L.TraceLetter�mov dl,cs:$TraceLetter[bx-'A']�pop StackDi
 test dl,$TraceA�jz NotTraceA
; ELSE has special treatment.
 Qry Z.Program,ShowELSE�jnz MonNotThen
; We want the lines of source between Z.TraceSource and Z.TraceEnds.
; THEN is special. We had to push on over it in the source but it isn't
; supposed to show if the THEN clause isn't executed.
 mov CursorSi,Z.DualCode
 inc CursorSi; Over $pTraceEvent
 cmp Bptr gs:[CursorSi],$pThen�je @F
 cmp Bptr gs:[CursorSi],$pWhen�jne MonNotThen
@@:inc CursorSi; Over $pThen
; Have to run THEN before (perhaps) showing it.
 call Then$$
 On Z.Program,ShowELSE
 cmp CursorSi,Z.DualCode�jb JumpedOut; Nothing shown
 mov Z.DualCode,CursorSi
 Off Z.Program,ShowELSE
MonNotThen:
; ELSE is special. The unconditional jump it puts at the end of a THEN leg,
; if executed, does not have any corresponding source shown.
 cmp Bptr gs:[CursorSi],$pJump�je ExecuteDual; Showing no source.
; Our window on the source is Z.Relative onwards for $SourceBufferSize-2.
; No need to refetch if what we want is in the window.
 mov ecx,Z.TraceSource
 cmp Z.SerialNow,$SerialSource�jne @F
 mov edx,Z.Relative�cmp ecx,edx�jb @F
 add edx,$SourceBufferSize-2�cmp edx,Z.TraceEnds�ja NoNeedSource
@@:mov Z.Relative,ecx�mov al,$SerialSource�call Serialize
NoNeedSource:mov esi,ecx�sub esi,Z.Relative�add si,Zshape.Serial
; Bytes to show start at SS:SI
 mov Dptr(Z.Tag+1),StringOrder('*','-','*',' '); For first ShowClauseId
; Dont show leading $Lf
 mv ds,ss�cmp Bptr[si],$Lf�jne @F�inc si�inc ecx�z Z.TraceSourceColumn�@@:
 mov dx,si�cmp ecx,Z.TraceEnds�jnb NotTraceA
TSloop:lodsb�cmp al,$Lf�jne TSnext
 call ShowLine; dx up to si
TSnext:inc ecx�cmp ecx,Z.TraceEnds�jne TSloop
; If there is anything to show at this point it will not end with a line-feed.
; One has to be added.
 cmp si,dx�je NotTraceA
 call ShowLine
 mv ds,cs�mov dx,Yshape.CrLf�mov cx,2
 mov ah,$DosWrite�int 21h
NotTraceA:
  btr Z.Program,ShowELSE�jnc ExecuteDual
; Go again with same Z.Synch but flag off.
 mov CursorSi,Z.Synch�jmp DualSwitch

; Code with trace events starts at Z.DualCode, ends with $TraceEndClause.
ExecuteDual:mov CursorSi,Z.DualCode�jmp StartExecutionY

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
$TraceLetter db $TraceA+1�db ?�db $TraceC+$TraceE+1�db ?
 db $TraceE+1�db $TraceF+1�db ?�db ?�db $TraceA+$TraceI+1�db ?�db ?
 db $TraceL+1�db ?�db $TraceF+1�db $TraceO+1�db ?�db ?�db $TraceA+$TraceR+1
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
 test al,1�jnz Monitor
; $TraceEndClause is special because it ends the transient code.
 cmp al,$TraceEndClause�je ClauseRunEnd
; Just set a flag when PARSE.
 cmp al,$TraceParse�jne @F�On Z.Cancel,ParseTrace�ret�@@:

; Normal entry is from XCycle but there is this one from mid-parse. (With more
; registers in use. DsSiCx )
TraceEventX:push CursorSi; (SI is not CursorSi when from mid-parse)
; Convert the current letter to a set of flags.
 call HeritageDi
 movzx bx,L.TraceLetter�mov dl,cs:$TraceLetter[bx-'A']�pop StackDi
; Note whether letter (mask) enables this event.
; Event of loading Var becomes event of loading Lit if variable is dropped.
 btr Z.Cancel,WasDropped�jnc @F�mov al,$TraceLit�@@:
 cbw�mov bx,ax�shr bx,1�add bx,ax�and dl,Bptr cs:$TrEv[bx]�jz TrEvRet
; Note the tag for the line to be shown.
 mov bx,cs:$TrEv[bx+1]�mov Wptr Z.Tag+1,bx�mov Z.Tag+3,bl
; DL now says what is to be shown.
 cmp al,$TraceAssign�jne NotAssign$
; The assign in parse does not have a value of the stack. It is DS:SI:CX
 Qry Z.Cancel,ParseTrace�jz ShowTop
@@:; We need some reasonable place on the stack, to make it similar to others.
 mov StackDi,Z.Stack�add StackDi,2*$StrideV�call VasDsSiCx�jmp ShowTop
NotAssign$:cmp al,$TraceDot�je @B
 test dl,$TraceC or $TraceI or $TraceR�jz NotTop
ShowTop:
; The value to be shown is on the stack.
 mov bx,Z.Stdout�call ShowClauseId
 mv ds,cs�mov dx,Yshape.DqCrLf�mov cx,1
 mov ah,$DosWrite�int 21h; Takes ds:dx:cx to file bx
; We want to leave V. the way we found it.
; But cannot but V. back to numeric until showing done.
 test V.Dtype,$Test�pushf�call ToDsSiCx�push cx
 cmp cx,$Limit_Insert�jna @F�mov cx,$Limit_Insert�@@:
 mov dx,si
; Better not let things like e-o-f show.
; How to do that without altering version in memory?
; Maybe show char by char if troubled? NYI
 mov ah,$DosWrite�int 21h; Takes ds:dx:cx to file bx
 mv ds,cs�mov dx,Yshape.DqCrLf
; "..." preceeds CrLf, if truncation.
 pop cx�cmp cx,$Limit_Insert�mov cx,2�jna @F�sub dx,3�mov cx,5�@@:
 mov ah,$DosWrite�int 21h
 popf�jnz @F�call NumDxBx�@@:
 RetSi

NotTop:

 test dl,$TraceE or $TraceF�jz NotRC
; Show RC=
 mv ds,cs�mov dx,offset RCis�mov cx,3�mov ah,$DosWrite�int 21h
; Move to stack
 Up�Move V,Vf[$?RCx]�jmp ShowTop

NotRC:Error49Bp; L & T

TrEvRet:RetSi

RCis db "RC="

ShowClauseId:; BX is target file.
 push si�push dx�push cx
; TraceWidth to dl - how many columns for the number.
 push bx�lds bx,Z.SysFile�mov dl,F.TraceWidth�pop bx
 mov ax,Z.ClauseLine; Current - previously shown is in Z.TraceLine
; Produce nothing for equal line number by using zero with full blank suppress.
 mov cx,ax�xchg cx,Z.TraceLine�cmp ax,cx�jne @F�z ax�@@:call Ax2DsSiCx
 TestReg ax�jnz @F�mov Z.AxAsNum+(sizeof Zshape.AxAsNum)-1,' '�@@:
; Bring small numbers up to length dl by adding leading blanks.
@@:cmp cl,dl�jae @F�inc cx�dec si�mov Bptr[si],' '�jmp @B�@@:
; Write from SI onward.
 mov dx,si�add cx,5; Blank-tag-blank.
 mov ah,$DosWrite�int 21h; Takes ds:dx:cx to file bx
 mov Z.Tag+2,','; For case of Tag was *-*
 pop cx�pop dx�pop si
 ret

ShowLine:; Show SS:DX to SS:SI. Advances DX
 mov bx,Z.Stdout�call ShowClauseId
 pusha
; Alignment may be needed.
 movzx cx,Bptr Z.TraceSourceColumn; Bug havoc potential reduction.
@@:jcxz @F�dec cx�call ShowBlank�jmp @B
@@:mov cx,si�sub cx,dx
 mov ah,$DosWrite�int 21h
 mov dx,si; Ready for next.
 popa
 ret

ShowBlank:pusha
 mov dx,Zshape.Tag; Which is a blank
 mov cx,1
 mov ah,$DosWrite�int 21h
 popa�ret

ClauseSourceEnd:; Records end of a clause in source.
; This is the end of the clause from a source view point - the semicolon,
; linefeed, THEN, ELSE.
 push ScanSi�push ax
 sub ScanSi,Zshape.Serial�movzx esi,si�add esi,Z.Relative
 mov eax,esi
; End of previous was beginning of this.
 xchg Z.TraceEnds,esi�mov Z.TraceSource,esi
; Also need the column.
 sub eax,Z.TraceAlign�xchg ax,Z.TraceEndsColumn�mov Z.TraceSourceColumn,ax
 pop ax�pop ScanSi�ret

;------------------------------------------------------------------------------
; Ax as a number in AxAsNum
; ds and si and cx set up for movsb
;------------------------------------------------------------------------------
Ax2DsSiCx:push ax�push bx�push dx�mv ds,ss
; Radix always reverts to 10
 mov bx,10�xchg bl,Z.Radix�z cx
; Convert and store backwards
 mov si,Zshape.AxAsNum + (sizeof Zshape.AxAsNum)
Ax2:z dx; Clear top
 div bx; Divide to get last digit as remainder
 add dl,'0'; Convert to ASCII
; ABCDEF are not immediately after 0123456789
 cmp dl,'9'�jbe @F�add dl,7�@@:
 dec si�mov [si+bp],dl�inc cx
 TestReg ax�jnz Ax2
; Make it even unless going to decimal.
 test cl,1�jz @F�cmp bl,10�je @F�dec si�mov Bptr [si+bp],'0'�inc cx�@@:
 pop dx�pop bx�pop ax
 ret

