; Copyright Formcroft Ltd 1997-1999
 .model smallú.486ú.code
 include always.inc; Assembler shorthands like 'Bptr' for 'byte ptr'.
 include declares.inc; Symbolic constants, macros, records, structures.
; The GROUP mechanism is capable of spreading the table of operation addresses
; amongst different assemblies but that is not now exploited - here are all
; the Pcode addresses.
; FanSeg is canned by a utility so not commented. See "Pcode generation".
MyGroup GROUP _TEXT, FanSeg
FanSeg SEGMENT WORD PUBLIC 'CODE'
PcodesBase$:
 dw Abut$$
 dw Cat$$
 dw Nop$$
 dw AssignDotsP$$
 dw Parse$$
 dw ResumeParse$$
 dw Number$$; After J in DO J=...
 dw To$$
 dw By$$
 dw For$$
 dw While$$
 dw Until$$
 dw IterRep$$; Matches DO 999
 dw Iterate$$; Matches DO FOREVER
 dw Leave$$
 dw UnDo$$
 dw Result$$
 dw Return$$
 dw Returns$$
 dw Exit$$
 dw Say$$
 dw Bifq$$
 dw Length$$
 dw Max$$
 dw Min$$
 dw Not$$
 dw And$$
 dw Or$$
 dw Xor$$
 dw Positive$$
 dw Negate$$
 dw Add$$
 dw Subtract$$
 dw Multiply$$
 dw Divide$$
 dw IntDivide$$
 dw Remainder$$
 dw Power$$
 dw Command$$
 dw Interpret$$
 dw Numeric$$
 dw Invoke$$
 dw Call$$
PjumpBase$:
 dw Rep$$; DO 999
 dw RepEver$$; DO FOREVER
 dw ControlVar$$; DO N=A TO B
BPcodesCeil$:
 dw DotControlVar$$
 dw Then$$
 dw When$$
 dw Jump$$
 dw Eq$$
 dw Ne$$
 dw Lt$$
 dw Le$$
 dw Ge$$
 dw Gt$$
 dw Seq$$
 dw Sne$$
 dw Slt$$
 dw Sle$$
 dw Sge$$
 dw Sgt$$
 dw Ceq$$
 dw Cne$$
 dw Clt$$
 dw Cle$$
 dw Cge$$
 dw Cgt$$
PjumpCeil$:
 dw InterpEnd$$
 dw Signal$$
 dw SignalOn$$
 dw CallOn$$
 dw Dots$$
 dw Assign$$
 dw AssignStem$$
 dw AssignDots$$
 dw AssignConst$$
 dw Unstore$$
 dw Drop$$
 dw Expose$$
 dw Bool$$
 dw IterCV$$
 dw Address$$
 dw CommandEnv$$
 dw EnvName$$
 dw Bif$$
 dw BifGroup$$
 dw Raise$$
 dw SignalOff$$
 dw SignalV$$
 dw SysVar$$
 dw DropList$$
 dw ExposeList$$
 dw Push$$
 dw Queue$$
 dw Trace$$
 dw TraceEvent$$
 dw Options$$
PcodesCeil$:
FanSeg ENDS

 EXTERN Bif$$:near,Bifq$$:near,BifGroup$$:near,Trace$$:near; With the Bif.
 EXTERN Max$$:near,Min$$:near,Length$$:near
 EXTERN Address$$:near,EnvName$$:near
 EXTERN Command$$:near,TraceEvent$$:near,TraceEventX:near
 EXTERN One$$:near,String1$$:near

 PUBLIC _Eq$$, _Ne$$, _Lt$$, _Le$$, _Ge$$, _Gt$$, _Seq$$, _Sne$$, _Slt$$
 PUBLIC Abut$$; Used by Command$$
 PUBLIC Interpret1; Used during initializing.
 PUBLIC AddRegs,CompareTO; Used in Bcode implementation.
 PUBLIC Exit, ExitDOS
 PUBLIC StrictFlags; Used at compile to test constants.

 PUBLIC Raise49
 PUBLIC Raise26p5,Raise26p6
 PUBLIC Raise33p1,Raise33p2,Raise33p3
 PUBLIC Raise34p5,Raise34p6
 PUBLIC Raise40
 PUBLIC Raise40p11,Raise40p32,Raise40p33

 EXTERN Bassign:near; This code does some work on behalf of Bcode.
; Things implemented in Bcode, run from here.
 EXTERN B4DROP:near,B4EXPOSE:near,ARITHOP$$:near,PATHQUALIFY:near
 EXTERN CloseBx:near; Needed by Exit.
 EXTERN MakeMsg:near
 EXTERN ShowMsg:near

CommandEnv$$:Error49Bp

Operator:inc CursorSiúxor bh,bh
; The fan-out is made with:
; AX not in use.
; BX containing the opcode (hence bh=0) and reusable.
; CX not in use. (See Note 1)
; DX not in use. (See Note 1)
; SI such that gs:CursorSi is after opcode. Return must be made with SI
; positioned on the next opcode.
; DI at the low address end of the latest operand to be stacked.
; DS not in use.
; ES not in use.
; FS addressing the current variables. Return must be with same value.
; GS addressing the Pcode. Return must be with same value.
; Note 1: Extensions of these registers are all not in use, except that
; when the top stack item is binary, it's value will be in ecx:edx as well
; on the stack.  (?? is this worth guaranteeing?)

if Debug
  push axúmov ax,gsúcmp ax,Y.Csegújae @Fúint 3ú@@:pop ax

  push axúmov ax,esúcmp ax,Z.ProgScopeúje @Fúint 3ú@@:pop ax

  mov Z.DebugStash,bx
  Qry Z.Cancel,BcodeInterpretújz @Fúmov Z.DebugStash,$pReturnsú@@:
endif

  mov Z.Stack,StackDi; Record of how much stack in use needed for Compaction.

; Jmps are faster than Rets so potentially fast to jump out to code and jump
; back (as is done for operand-to-stack loading) but that would prevent the
; functions from being (easily) called from other places.

  call cs:(PcodesBase$-1)[bx]

if Debug
; Part of check that StackDi = Z.CurrentDO at end-of-clause, ie no
; unprocessed operands left over.
if MemCheck
    call DosMemCheck
endif
 mov bx,Z.DebugStashúcmp bl,$pReturnsúje @F
 cmp bl,$pExitúje @F
 cmp StackDi,Z.CurrentDOújz @Fúmov dx,bx;Assert DX free to use. (Visible in CV)
 shr bx,1úmov bl,Bptr OpFlags[bx]úQry bl,EndsClauseújz @F
 int 3úmov ah,$DosExitúint 21h
@@:
endif

XCycle:

if 0
 call Consist; Check overwrite of Symbols.
endif

; Here with the soft instruction pointer on the bytes to be interpreted.
if Debug
 cmp si,bpújns @Fúint 3ú@@:
endif
 mov bx,Wptr gs:[CursorSi]
; Even means it is an operand. There are usually more operands than operators.
 test OperandBl,1újnz Operatorúadd CursorSi,2
 test OperandBl,$CaseTargetújnz NotLoadVariable

; Alignment 8 means procedure scope. There are roughly as many of these
; as there are constant references (program scope).
; FS is maintained addressing the variables of the current procedure.
; The following Up (=add) puts the previous operand (if any) underneath (lower
; address than) StackDi, and the new operand is then positively addressed
; by StackDi.
; It isn't necessary to test for stack overflow here because there is a limit
; on the number of operands that can happen without a function invocation
; intervening and the function will make a check. (Limit is deduced at compile
; time- NYI but conservative view taken.)
FetchBx:Upútest Vbxf.Dtype,$Testújg NotPresent
; If control branched off, it will return to XCycle when a value to be used
; for the operand is established.
; Whatever the datatype of the value, 8 bytes contains or anchors it.
 Move V,Vbxfújmp XCycle

NotLoadVariable:jpo ProgScope
; $CaseTarget (=6) modulo 8 means a variable being assigned to.
 cmp Vbxt.Dtype,$Exposedúje @F
 Move Vbxt,VúDownújmp XCycle
@@:push XCycleújmp AssignExposed

; Excursion from XCycle for loading a constant.
ProgScope:UpúMove V,Vbxeújmp XCycle

; The Rejumps either change CursorSi, or don't, according to the hardware
; flags. They are the "conditional jumps" of Pcode.  Which one to use is
; determined by the Pcode operator, by this time converted into which of
; this array of conditional jumps is to be used.
; Once upon a time Rejumps were four bytes like je @F xax CursorSi @@:ret
; but latest should be faster.

if Solid
Rejumps:
 je @Fúmov CursorSi,axú@@:BackRet
 nopúnopúnop
 jne @Fúmov CursorSi,axú@@:BackRet
 nopúnopúnop
 jb @Fúmov CursorSi,axú@@:BackRet
 nopúnopúnop
 jbe @Fúmov CursorSi,axú@@:BackRet
 nopúnopúnop
 jae @Fúmov CursorSi,axú@@:BackRet
 nopúnopúnop
 ja @Fúmov CursorSi,axú@@:BackRet

Boolery:; Turns what is in hardware flags to a Boolean byte in al.
; sete al ret will fit in four bytes but nowadays we use eight - see Rejumps.
 sete Bptr(V.Mantissa)úBackRet
 nopúnopúnop
 setne Bptr(V.Mantissa)úBackRet
 nopúnopúnop
 setb Bptr(V.Mantissa)úBackRet
 nopúnopúnop
 setbe Bptr(V.Mantissa)úBackRet
 nopúnopúnop
 setae Bptr(V.Mantissa)úBackRet
 nopúnopúnop
 seta Bptr(V.Mantissa)úBackRet

BooleryRejumps equ Boolery-Rejumps
endif
;------------------------------------------------------------------------------
; When I changed the search from a subroutine to inline the performance
; went down (!) so presumably alignment is important.
;------------------------------------------------------------------------------
comment~ The principal runtime activity is to go from the state where the tail
parts are on the stack to the the state where they are pruned and the tailed
variable is known.   This is sufficient when the subject is being
assigned to, but fetch needs more.  Fetch is three-stage; the subject might have
a value, or the stem might supply one, or the stem might not.  In the last case,
both the stem and the tail are needed again as part of the default value.

Considerable scarcity of segment registers here. We can't save and restore
segment registers because of compaction effects. The segment registers have
to be committed or reloadable. We have committed SS and CS. There is no
choice about ES during most of this routine because of movs and cmps use.
It is just too clumsy to keep reloading DS, so we let FS be the exposed
variable pool rather than just the current one.

~
; Concatenates parameters (with '.' between them) to make a tail value.
; Looks under the stem (which comes in fs:bx) for item with that key, makes it
; if necessary.  AX says how many parameters.
; Results fs:bx for stem (upper of pair), ds:si for tailed item.
; StackDi adjusted. ax & cx & dx not preserved.

DotsFsBxDsSi:
; AX defining how many parts.
; Change fs to required pool, if necessary.
 cmp Vbxf.Dtype,$Exposedújne @Fúcall ExposedFsú@@:
; Find the segment owned by the stem.
; If stem says dropped, a segment is needed which will hold all the keys.
 cmp Vbxf2.Dtype,$Droppedújne @Fúcall StemAllocVbxDsú@@:
DotsFsBxDsSiX:; Entry from externals lookup.
 mov Z.StackHi,StackDiúmov Z.StackLo,StackDiúsub Z.StackLo,ax
if Debug
 TestReg axújns @Fúint 3ú@@:
endif
; Copy parts of tail to make complete key.
 mov StemEs,Vbxf2.Sg
 mov si,He.Avail; Points to spare space.úlea ToFindDx,J.Key
 Up
 mov ax,ToFindDx; ax as cursor across key.
TailLenLoop:Down
@@:push StackDiúcall ToDsSiCx
; Assure room in stem segment.
 mov di,axúadd di,cxúinc diúcmp di,He.Triggerújb @F
 mov Z.Stem,StemEsúmov SegOffDi,Zshape.Stem
 call MoreSpaceEsúmov Vbxf2.Sg,StemEsúpop StackDiújmp @B
; Add tail part to the key, with dot after. AX advances.
@@:mov di,ax
; Trade size for speed.
  cmp cx,8
  ja  SlowRep
  mov eax,Dptr[si]
  mov Dptr es:[di],eax
  mov eax,Dptr [si+4]
  mov Dptr es:[di+4],eax
  add di,cx
PostRep:
 mov al,'.'ústosbúmov ax,di
 pop StackDiúcmp StackDi,Z.StackLo
if Debug
 jae @Fúint 3ú@@:
endif
 jne TailLenLoop
if 0
; In this variation, a preliminary run works out key length so that test
; for space is only needed once.
; For the record, this was 3% slower for REXXCPS overall.
endif
if 0
; In this variation, a limit is set on key length.
; This didn't noticieable speed things up.
endif
; Now ready to see if stem has already used this key.; ES:ToFindDx at the key.
 sub ax,ToFindDxúdec ToFindLenAx; Lose trailing dot.

; EXPOSE at the item level can lead to repeat lookup in a different pool.
; Enter here with ES:DX::AX as the key.
ExposedLoop:mov ds,Vbxf2.Sg
;------------------------------------------------------------------------------
; This section does the search for the keyed item.
;------------------------------------------------------------------------------
; ds&es at segment.
; ToFindLenAx and ToFindDx set.
 push StemBxúmov ProbeBx,Hd.Probeúmov TailSi,ToFindDx
 sub TailSi,Jshape.Keyúmov Z.NewJshape,TailSiúlea LowSi,J.Lower
; ds now at segment for keys & Vshapes. bx the probe to start looking.
; Lookup algorithm is like that for symbols, but has keys embedded.
; So limited comments on this one.
 lea HighDi,[LowSi+Jshape.Higher-Jshape.Lower]
 jmp WhileStemBxQ

; Backwater for hungover bit.
SlowRep:rep movsb
  jmp PostRep

; Do the string (with length) compare.
StemLoopQ:cmp ToFindLenAx,Jbx.KeyLenúja ProbeBelow2Qújb ProbeAboveQ
 push siúpush diúmov di,ToFindDxúlea TailSi,Jbx.Keyúmov cx,ToFindLenAx
 repe cmpsbúpop diúpop siújae ProbeBelowQ
ProbeAboveQ:mov [LowSi],ProbeBx; Complete prior iteration
 lea LowSi,Jbx.Higherúmov ProbeBx,[LowSi]
; A little bit of duplication for speed.
 TestReg ProbeBxújnz StemLoopQújmp NewStemBx

ProbeBelowQ:je ProbeMatchQ
ProbeBelow2Q:mov [HighDi],ProbeBxúlea HighDi,Jbx.Lowerúmov ProbeBx,[HighDi]
WhileStemBxQ:TestReg ProbeBxújnz StemLoopQ; Drop through if not found.
NewStemBx:z Wptr[LowSi]úz Wptr[HighDi]
; Commit the new item we have been making.
; Key has already been copied into the relevant place.
 pop StemBxúmov TailSi,Z.NewJshape
 mov J.KeyLen,ToFindLenAx
 lea di,J.Keyúadd ToFindLenAx,diúmov Hd.Avail,ax
 mov Hd.Probe,TailSi
 stcújmp FoundKey

ProbeMatchQ:;Subject found at ProbeBx.
 mov ax,Jbx.Lowerúmov [LowSi],axúmov ax,Jbx.Higherúmov [HighDi],ax
; Address the place found with si and recover bx of the stem.
 mov TailSi,ProbeBxúpop StemBxúmov di,Z.NewJshape
 mov edi,Jdi.Pairúmov J.Pair,edi
 mov Hd.Probe,TailSi; Probe for next time look at this stemmed.
 clc
FoundKey:
;------------------------------------------------------------------------------
; DS:SI now the relevant Vshape item.
;------------------------------------------------------------------------------
; Leave StackDi ready to take a value.
 mov StackDi,Z.StackLo
 jc TailNew
; If this element is EXPOSEd, we need to lookup again, in the caller's pool.
 cmp Vsid.Dtype,$Exposedúje DotsExposed; And then ExposedLoop
 mov ProgEs,Z.ProgScope
 ret

; We need to find the A.B which isn't EXPOSEd.
DotsExposed:call ExposedFs
; Search will be with the same key.  Hard work to copy it to the new subject.
 mv es,ds; Segment currently having key.
; Stem may never have been used in the caller's pool.
 cmp Vbxf2.Dtype,$Droppedújne @Fúcall StemAllocVbxDsú@@:
 mv ds,es
 push di
 mov es,Vbxf2.Sg;
 mov di,He.Avail
 mov ax,J.KeyLenúmov es:Jdi.KeyLen,axúmov cx,ax
 lea TailSi,J.Keyúlea di,Jdi.Keyúmov dx,diúRepmovsb
 pop di
; Look again for this key on this stem in this pool.
 jmp ExposedLoop

TailNew:mov Vsid.Dtype,$Omitted; Mark as new item.
 mov ProgEs,Z.ProgScope
 ret

StemAllocVbxDs:; First time some tail of a stem is used. Second of pair gets
; to address the segment for tails and their values.
 pushaúmov bx,512-8;Triggerúlea cx,[bx+8]; SegSize bytes.
 mov SegOffDi,Zshape.Stemúcall InitSegDs
 popaúmov Vbxf2.Sg,ds
; Compaction failure when this was before the allocate!
 mov Vbxf2.Dtype,$Stem; It is not a variable, but not now $Dropped either.
 ret
;------------------------------------------------------------------------------
; The operand was not one that could be loaded directly from the ProgScope
; or VarScope arrays.  The effect of the code here is as if it was.
;------------------------------------------------------------------------------
; There are various reasons why we might not yet have the final value.
NotPresent:push XCycle
NotPresentX:; Entry point when called from eg Parse.
 mv ds,fs; Exposed only happens for variables.
;; Might be better code if we altered fs? Would have to reload after.
 cmp Vbx.Dtype,$Exposedújne NotExposed
; Assert - loop for non-exposed bound to find one.
@@:mov ds,Hd.UpPoolúcmp Vbx.Dtype,$Exposedúje @B
NotExposed:test Vbx.Dtype,$Testújg @F
 Move V,VbxúBackRet

; Here if now-non-exposed is not present. (Dropped or SIGL type)
@@:cmp Vbx.Dtype,$Droppedújne NotDropped
; Is NOVALUE enabled?
 call HeritageDiúcmp L.NoValue,0úpop StackDiújne @F
 On Z.Cancel,WasDropped; For trace >L>
 call ValueIsNameúBackRet

; NYI some lookahead here since tails of compounds don't give NOVALUE.
; Lookahead for stemmed variable cases.
; Raise NOVALUE.
@@:Error49Bp

NotDropped: Move V,Vbx

comment~ Most things under program scope, segment Z.ProgScope, are constants.
References to program scope variables, eg .MN, are followed by SysVar$$ so
that in the usual case Z.ProgScope can load constant without needing
a test.
~
SysVar$$:test V.Dtype,$Testújg @FúBackRet

@@:; Assert - cannot be exposed.
 push CursorSi
; Here for ones where conversion to number has been postponed.
 cmp V.Dtype,$MsgNumújne NotMsgNum
; This type, until needed, is stored with MajMin as binary.
 push StackDiúmv es,ssúmov dx,V.MantLow
; Major number as part of short string result, via Zone
 movzx ax,dhúcall Ax2DsSiCxúrep movsb
; Dot and minor number unless zero.
 mov al,dlúTestReg axújz @F
 mov Bptr es:[di],'.'úinc diúcall Ax2DsSiCxúrep movsb
; Set Dtype of result.
@@:mov ax,diúpop StackDiúsub ax,StackDiúadd al,$NullStringúmov V.Dtype,al
 jmp RetEsSi

NotMsgNum:cmp V.Dtype,$Siglújne NotSigl
; Use compile phase to find line number.
 move Z.Synch,V.MantLow
 mov Z.Cursor,$StrideH
 z Z.Scanp
 push StackDiúcall Compilingúpop StackDi
 mov ProgEs,Z.ProgScope
 mov fs,Z.VarScope
 mov gs,Z.Code
; ??? NYI does Z.Stack survive? or matter?
 mov V.ExpAnd,ebp
 mov V.Mantissa,ebp
 move V.MantLow,Z.ClauseLine; Or is it meant to be Z.Lines?
 jmp RetEsSi

NotSigl:Error49Bp

; End of loading operands.

;------------------------------------------------------------------------------
; Abut and Cat have special concerns over compaction since three strings
; need pinning at the same time.
;------------------------------------------------------------------------------
TotalCx is <cx>
MovsCx is <cx>
RHSLenDx is <dx>
LHSLenBx is <bx>
Abut$$:push CursorSi
; If the left one isn't a string then better convert it now so that no
; compaction threat from ToDsSiCx of it.
 test V0.Dtype,$Testújnz @F
 Downúcall ToDsSiCxúUp
; Remember RHS
@@:call ToDsSiCxúmov RHSLenDx,cxúpush dsúpush si
; Look at LHS
 Downúcall ToDsSiCxúmov LHSLenBx,cx
; If room, just append in place.
 add TotalCx,RHSLenDxújc Raise5p1dúcmp TotalCx,7úja AbutAlloc
; Allow for possibility of a short AwayString.
 cmp V.Dtype,$AwayStringúje AbutAlloc
; Setup ES:DI for place LHS to go.
 mv es,dsúand V.Dtype,-8úadd V.Dtype,cl; Adjust length of LHS.
 xchg LHSLenBx,diúadd di,si; Position inside LHS for RHS to go.
 jmp CatAppend

AbutAlloc:mov Z.CatTotal,TotalCx
; Only Abut and Cat care about possible appended allocation so the code for
; that is put inline, both places.
; This sort of allocate may turn out to be an extend of the current $AwayString
; stack item. Maybe not faster than allocate but may save a long move.
; Test is whether the LHS operand is actually just ahead of what we are
; about to allocate.
 cmp V.Dtype,$AwayStringújne AbutOther
 AllocAppend AbutOtherPop; Jump if cannot append.
 pop si
; Stack item has been changed to make room for RHS.  Setup target of RHS copy.
 xchg LHSLenBx,StackDiúadd di,axújmp CatAppend
; New space in memory is needed.
AbutOtherPop:pop si
AbutOther:call AllocateCx_EsAx
; RHS may have moved when compaction, invalidating pushed registers.
 jnc @FúPopJunk siúPopJunk si
 Upúcall ToDsSiCxúDownúpush dsúpush siúcall ToDsSiCxú@@:
; Maybe LHS is short string - must move before altering stack item.
 mov MovsCx,LHSLenBxúmov bx,StackDiúmov di,axúRepmovsbújmp CatLong

; See also Abut$$
Cat$$:push CursorSi
; If the left one isn't a string then better convert it now so that no
; compaction threat from ToDsSiCx of it.
 test V0.Dtype,$Testújnz @F
 Downúcall ToDsSiCxúUp
@@:call ToDsSiCxúmov RHSLenDx,cxúpush dsúpush si
 Downúcall ToDsSiCxúmov LHSLenBx,cx
; Allow for separating character.
 add TotalCx,RHSLenDxújc Raise5p1d
 inc TotalCxújz Raise5p1dúcmp TotalCx,7úja CatAlloc
; Allow for possibility of a short AwayString.
 cmp V.Dtype,$AwayStringúje AbutAlloc
; If room, just append in place.
 mv es,dsúand V.Dtype,-8úadd V.Dtype,cl; Adjust length of LHS.
 xchg LHSLenBx,diúadd di,si; Position inside LHS for RHS to go.
 mov al,' 'ústosb
CatAppend:pop siúpop dsúmov MovsCx,RHSLenDxúRepmovsb; Copy the RHS
 mov StackDi,bx
 jmp RetEsSi
CatAlloc:mov Z.CatTotal,TotalCx
 cmp V.Dtype,$AwayStringújne CatOther
 AllocAppend CatOtherPopúpop si
; Stack item has been changed to make room for RHS.
 xchg LHSLenBx,StackDiúadd di,axújmp CatMid

CatOtherPop:pop si
CatOther:call AllocateCx_EsAx
; RHS may have moved when compaction, invalidating pushed registers.
 jnc @FúPopJunk siúPopJunk si
 Upúcall ToDsSiCxúDownúpush dsúpush siúcall ToDsSiCxú@@:
; Maybe LHS is short string - must move before altering stack item.
 mov MovsCx,LHSLenBxúmov bx,StackDiúmov di,axúRepmovsb
CatMid:mov cx,axúmov al,' 'ústosbúmov ax,cx
CatLong:pop siúpop dsúmov MovsCx,RHSLenDxúRepmovsb; Copy the RHS
; Fill fields of stack item to address result
 mov StackDi,bxúmov TotalCx,Z.CatTotal
 mov V.Len,TotalCxúmov V.Sg,es
 mov V.Pt,axúmov V.Dtype,$AwayString
 jmp RetEsSi

Nop$$:mov Ve.Dtype[$?CLAUSETIME],$NullString
 BackRet

;------------------------------------------------------------------------------
; PARSE stage one is to get the subject addressed by the current stack variable.
;------------------------------------------------------------------------------
comment~ There are a variety of PARSE sources, for which we use several
pcode points and a marker for uppering. The FindNextBreak, $8.3.17, is done
at parser time (to the extent of what sort of search - Pattern or +-=
forms of positional). These markers will find their parameter is on the stack.
All the relevant targets follow, so that WordParse can be done on the isolated
source. The set of targets is ended by another trigger, a marker to end the
parse, or the marker for a comma in a template.

The schema described in the paragraph above assumes that all the values and
targets in the template-list are simple two byte references.  The execution
time parse scan could not cope with more so it is paused, and the general
pcode mechanism used, for complex cases.  These cases must allow for the
possibility of a compaction occurring.

Parse is important for execution speed. The Intel architecture isn't that
good for scanning but we can work on other aspects. We should avoid going back
to the interpreter loop too often. So the assignments are done without
having a $pAssign opcode for them, and without taking the source value
up to the stack and back.

Parse terminology: "Subject" is the thing parse scans; in the case of PARSE ARG
there can be several. A "section" is a substring of that isolated by a "trigger"
which is a pattern or column. The contents of a runtime section correspond
to a set of target variables (isolated by the trigger spec) in the compile
time parse clause. A "Break" is the pattern that separates sections. It is
null for a column trigger. Parsee is a collection of info about the parsing.

~
CursorDi is <di>
SectionSi is <si>
SectionDi is <di>
SectionDx is <dx>
DataLenCx is <cx>
SectionCx is <cx>
PatternSi is <si>

Parse$$:lodsb Bptr gs:[CursorSi]úmov bl,al
 cmp Bptr gs:[CursorSi],$mUpperújne @Fúinc CursorSiúOn Z.Cancel,ParseUpperú@@:
 push CursorSiújmp SourceTable[bx]

if Solid
SourceTable:
 dw Var$
 dw With$
 dw Arg$
 dw LineIn$
 dw Pull$
 dw Source$
 dw Version$
endif

; This can be repeated at the template comma.
Arg$:z Z.ParseeNumúUp
ArgInc:inc Z.ParseeNum; All the other sources keep ParseeNum at zero.
; Set StackSi for relevant argument.
 mov ax,Z.ParseeNumúshl ax,$ShiftV
 mov LevelSi,Z.Levelúmov StackSi,Lsi.Arg0úadd StackSi,ax
; Put copy of it at current stack item.
 Move V,Vsiúcall ToDsSiCxújmp FromArg

TemplateComma$:push CursorSiúcmp Z.ParseeNum,ZeroBpújne ArgIncúpop CursorSi
; Non-ARG so parse a null string.
 move Z.Parsee.Limit,Z.Parsee.Ptújmp LoadTrigger

LineIn$:
 Error49Bp

Pull$:; Push/Pull is at the high end of Z.Serial.
; Length of aggregate is first word of Z.Serial.
; Items have their length at both ends of the item.
 mov al,$SerialQueúcall Serializeúmv ds,ss
; Another source if nothing on Rexx stack.
 mov si,Wptr Z.SerialúTestReg siújz PullSysin
; Do the "pop".
 mov cx,Wptr Z.Serial[si]úsub si,cxúmov Wptr Z.Serial,si
; Item (including lengths) goes from Z.Serial[si+2] for cx bytes.
; Have to physically copy because where it is can get reused.
Pulled:lea si,Z.Serial[si+4]
 sub cx,4úUpúcall ResultSpaceúpush StackDiúmov di,axúrep movsbúpop StackDi
 mov ProgEs,Z.ProgScopeújmp Var$

PullSysin:; Fill by read of Stdin
; Pretend there are lengths, to share code.
 z bx; Handle of Stdin
 mov dx,offset Zshape.Serial+4úmov cx,sizeof Zshape.Serial-4
 mov ah,$DosReadúint 21húadd ax,4úmov cx,axújmp Pulled

Version$:; Alias the constant from code segment to a stack variable.
 Upúmv ds,csúmov si,offset Versionúmov cx,sizeof Version
 jmp FromVersion

; This routine makes the V stack variable reflect DS:SI::CX
VasDsSiCx:mov V.Pt,siúmov V.Sg,dsúmov V.Len,cxújmp Away

Source$:Upúpush StackDi
; #Configuration #HowInvoked #Source, to be set up as string variable.
; Add up lengths in cx and allocate space.
 mov cx,sizeof Configurationúadd cx,Z.HowInvoked
 lds bx,Z.InsSourceúmov bx,Jbx.KeyLenúadd cx,bx
 push cxúmv ds,csúcall AllocateCx_EsAx
; Copy Configuration from code segment.
 mov di,axúmov cx,sizeof Configurationúmov si,offset Configurationúrep movsb
; Copy HowInvoked from code segment.
 mov cx,Z.HowInvoked
 cmp cx,sizeof FUNCTIONújne @Fúadd si,FUNCTION-COMMANDú@@:
 cmp cx,sizeof SUBROUTINEújne @Fúadd si,SUBROUTINE-COMMANDú@@:
 rep movsb
; And the bit for #Source.
 mov cx,bxúlds bx,Z.InsSourceúlea si,Jbx.Keyúrep movsb
 mv ds,esúmov si,axúpop cxúpop StackDi
 mov ProgEs,Z.ProgScope
FromVersion:; Set stack to reflect the value.
 call VasDsSiCx

Var$:úWith$:; Stack has the thing to be parsed.
 z Z.ParseeNum; And stays that for these sources.
FromArg:
; We keep a stored copy of the subject during PARSE, on stack so that
; Compaction is aware. (Compaction only during escape)
 Qry Z.Cancel,ParseUpperújz @Fúcall CONFIG_UPPER$$ú@@:úcall ToDsSiCx
; Z.Parsee.Sg we keep stored because of paucity of segment registers.
; Z.Parsee.Pt we keep stored ready to create an empty segment. (TemplateComma)
; Also keep track of the end of the sections.
 mov Z.Parsee.Sg,dsúmov Z.Parsee.Pt,siúadd cx,siúmov Z.Parsee.Limit,cx
; The position of a pattern determines the start of the following section.
 mov Z.BreakStart,siúmov Z.BreakEnd,si
 pop CursorSi
;------------------------------------------------------------------------------
; Second stage, get the trigger value, eg the pattern for a pattern search.
;------------------------------------------------------------------------------
; If the trigger is not a difficult value to load, we do not need to go
; back to the interpreter loop to load it.
LoadTrigger:mov ax,Wptr gs:[CursorSi]úinc CursorSi
NextSection:
; AX is two bytes from the Pcode, with CursorSi moved over one of them.
 cmp al,$mPosRestúje PosRest$; No value to load for PosRest$
 cmp Z.ResumeP,ZeroBpújne ParseBcode; Will return to TriggerWith.
if Debug
; Shouldn't be an opcode.útest al,1újz @FúError49Bpú@@:
endif
; It will be a marker or an operand for a trigger.
TriggerArg:test al,02hújnz PSwitch
; It is a (non-complex) operand.
; Load value of variable needed for trigger.
; Advance cursor over the operand and wind up at TriggerWith.
 inc CursorSiúmov ArrayBx,axúUpútest al,04hújnz ConTrigger
; Compile time could detect most complications, but not EXPOSED.
 test Vbxf.Dtype,$Testújg @F
 Move V,Vbxfújmp TriggerWith
@@:push TriggerWithújmp NotPresentX
; Load value of constant needed for trigger.
ConTrigger: mov ProgEs,Z.ProgScopeúMove V,Vbxe

; Switch on which trigger.  StackDi has the trigger value, if trigger uses one.
TriggerWith:lodsb gs:[CursorSi]; Known to be a marker.

PSwitch:shr al,2úmovzx bx,alújmp Triggers[bx-$mParseEscape/4]
if Solid
Triggers:
 dw ParseEscape$ ; Complex operand. Get and resume at TriggerWith.
 dw ParseEnd$
 dw PosRest$     ; Won't happen here - was tested early.
 dw Pattern$
 dw PosEq$
 dw PosPlus$
 dw PosMinus$
 dw TemplateComma$
endif

;------------------------------------------------------------------------------
; Third stage.
; Here we deal with a section of the parse. We deduce where the section runs,
; and record BreakStart and BreakEnd for use next time around in determining
; the next section.  Goes on to WordParse, via Section.
;------------------------------------------------------------------------------
Pattern$:push CursorSiúcall ToDsSiCx
 Downúpop axúpush StackDiúpush ax; CursorSi nearest as WordParse needs.
; Search for this pattern.
 JcxzQ NullPattern; Null matches the end of the subject.
; Setup where to search.
 mov Z.PattLenEtc,cxúmov es,Z.Parsee.Sgúmov SectionDi,Z.BreakEnd
 mov SectionCx,Z.Parsee.Limitúsub SectionCx,SectionDi
; PatternSi is at pattern, SectionDi at subject, SectionCx to look over.
; Stop on places that match the first character.
 mov al,[PatternSi]
SingleNext:repne scasbújne NullPattern
; One character match. Is the pattern longer?
 mov dx,Z.PattLenEtcúdec dxújz HasPattern
; Compare rest of pattern, without advancing. dx is amount left to compare.
 cmp dx,SectionCxúja NullPattern
 push SectionDiúpush SectionCxúpush PatternSi
 inc PatternSiúmov cx,dxúrepe cmpsbúpop PatternSiúpop SectionCx
 je HasPatternPopúpop SectionDiújmp SingleNext
HasPatternPop:PopJunk ax
; Match over all pattern.
HasPattern:; SectionDi is now position after the last matching character.
 mov SectionSi,Z.BreakEnd; Start of this section.
 mov Z.BreakEnd,SectionDiúsub SectionDi,Z.PattLenEtc
 mov Z.BreakStart,SectionDiújmp Section

NullPattern:mov SectionSi,Z.BreakEnd
 mov ax,Z.Parsee.Limitúmov Z.BreakEnd,axúmov Z.BreakStart,axújmp Section
; Here the column for the limit of a new section is specified.
PosEq$:call ToWholeEbxújc Raise26p4úDownúpush StackDiúpush CursorSi
 mov SectionSi,Z.BreakEnd
; Convert from column to segment offset.
comment~ If we kept bx as Z.Parsee.Pt we would avoid conversion, and escapes
would be simpler.  But then addressing would be [bx+si] and so scansb could
not be used.
~
 mov ax,Z.Parsee.Ptúadd ax,bxúdec axúmovzx edx,axújmp PosNew

; Relative means relative to start of last section delimiter.
; If we do this in 16 bits, negatives will look like large addresses.
PosMinus$:call ToWholeEbxújc Raise26p4úneg ebxújmp @F
PosPlus$:call ToWholeEbxújc Raise26p4
@@:Downúpush StackDiúpush CursorSiúmovzx edx,Z.BreakStart
 mov SectionSi,dxúadd edx,ebxúmov ax,dx
; Keep position to start next section within range.
PosNew:movzx ecx,Z.Parsee.Ptúcmp edx,ecxújge @Fúmov ax,Z.Parsee.Ptú@@:
 movzx ecx,Z.Parsee.Limitúcmp edx,ecxújl @Fúmov ax,Z.Parsee.Limitú@@:
 mov Z.BreakStart,axúmov Z.BreakEnd,ax
Section:; Section goes from current SectionSi to new Z.BreakStart or end of
; subject. Hence DataLenCx.
 mov cx,Z.BreakStartúcmp SectionSi,Z.BreakEndújb @Fúmov cx,Z.Parsee.Limitú@@:
 jmp SectionGo

PosRest$:; Section runs to end of parsee.
; No need to set things for next section, or to range check.
 push StackDiúpush CursorSiúmov SectionSi,Z.BreakEndúmov cx,Z.Parsee.Limit
SectionGo:sub DataLenCx,SectionSi

;------------------------------------------------------------------------------
; Stage 4 - Bits of the identified section are assigned to variables.
; WordParse - see the Standard.
;------------------------------------------------------------------------------
comment~ Here we are at a point in the pcode where a trigger has been processed,
setting SectionSi to a section of the subject, length DataLenCx.
Z.BreakStart and Z.BreakEnd are also set.
There follows in the pcode a set of targets to be fulfilled from the section.
StackDi and CursorSi are already pushed.  CursorDi fills usual CursorSi role in
this code, so that scansb can be used on the subject.

~
 pop CursorDiúmov ds,Z.Parsee.Sg
; This is a routine where Pcode and Bcode are distinquished during execution.
 cmp Z.ResumeP,ZeroBpújne ParseB
; Looking though ds:si:cx for words. Assigning to targets given in Pcode.
; The loop will advance si with corresponding reduction in cx, in conjunction
; with di advancing through targets.
NextTarget:mov OperandBx,gs:[CursorDi]
; It will either be a target, or a marker (for EndParse or ParseEscape),
; or an operand which is next trigger value.
 test bl,$CaseTargetújpo WpDone
; It is a target. Cursor advances over target.
 inc CursorDiúinc CursorDiúsub OperandBx,$CaseTarget
; Make fs:bx the item to be assigned to.
 cmp Vbxf.Dtype,$Exposedújne @Fúcall ExposedFsú@@:
 push fsúpush OperandBx
; Enter here from escape for tailed cases.
ParseAssign:; The next part of the subject is to be assigned to (pushed) FS:BX.
; There will be no compaction while determining what to assign.
 JcxzQ AssignNull; Assign null is same whether this is last of section or not.
 mov al,Bptr gs:[CursorDi]
 test al,$CaseTargetújz WpLastújpe WpWordúcmp al,$mParseEscapeújne WpLast
; When not last of section, target gets just one word.
WpWord:
 mov bx,Attributes; Prepare to test AllBlanks.
; Move SI on to nonblank.
@@:lodsbúXlatBDLSújnz @FúLoopQ @Bújmp AssignNull
; Came out of the above loop with si advanced but cx not fully decreased.
; SectionDx to remember start of the word.
@@:mov SectionDx,SectionSiúdec SectionDxúdec cxújz WpOne
; Move SI on to blank.
@@:lodsbúXlatBDLSújz @FúLoopQ @B
; Nothing ends the word. We want to do further work with DataLenCx=0
WpOne:inc DataLenCxúinc SectionSi
@@:dec DataLenCx; Word terminator not part of residue.
; SectionSi is beyond the blank but that is OK - don't want to scan it again.
 mov Z.PattLenEtc,DataLenCx; Save use as residue, start use as word length.
 mov cx,SectionSiúsub cx,SectionDxúdec cx; Word length.
 xchg SectionSi,SectionDx; Back to start of the word. SectionDx for next scan.
; Assign that word away, to variable specified in pcode, now ArrayBx.
; ds:si::cx is the word.
WpLast:; Enter here for last target -last one gets the residue, blanks and all.
 pop OperandBxúpop fs
; I hate to have a test that costs even when trace isn't used but this place
; is so deep in parse that I see no reasonable way to use $pTraceEvent instead.
 Qry Z.Cancel,ParseTrace
 jz NotTracingúpushaúmov al,$TraceAssign
 cmp OperandBx,$?Discardújne @Fúmov al,$TraceDotú@@:
 call TraceEventXúpopa
NotTracing:
; Moot whether testing for 'no target' is worth the saving.
; It didn't help REXXCPS much. So we assign to $?Discard instead.
 cmp cx,7úja @8p3p17A
 Move Vbxf,Vsid,eaxúadd cl,$NullStringúmov Vbxf.Dtype,cl
; Rescan from where we had reached.
WpResume:mov fs,Z.VarScope
 mov SectionSi,SectionDxúmov DataLenCx,Z.PattLenEtcújmp NextTarget

@8p3p17A:; Alias setup
 mov Vbxf.Sg,dsúmov Vbxf.Pt,siúmov Vbxf.Len,cxúmov Vbxf.Dtype,$AwayString
 jmp WpResume

AssignNull:
 Qry Z.Cancel,ParseTraceújz NotTracingXúpushaúmov al,$TraceAssign
 cmp OperandBx,$?Discardújne @Fúmov al,$TraceDotú@@:
 call TraceEventXúpopa
NotTracingX:pop OperandBxúpop fsúmov Vbxf.Dtype,$NullStringújmp NextTarget

; Parsee to be taken off stack at end of PARSE clause.
ParseEnd$:DownúOff Z.Cancel,ParseUpperúmov ProgEs,Z.ProgScopeúBackRet

WpDone:mov Z.PattLenEtc,SectionSi
 mov CursorSi,CursorDiúpop StackDiúmov fs,Z.VarScope
; The sequence of targets was ended either by a marker or by the operand
; part of the next trigger. In the latter case we go to work
; on the next section of the parse. In the former case we may have an
; operandless trigger like PosRest or ParseEnd, or this may not really
; be the end of the targets, just a target that needs AssignDotsP$$.
; That target calculation will start with a $mParseEscape.
 mov ax,bxúinc CursorSiúcmp al,$mParseEscapeújne NextSection
;------------------------------------------------------------------------------
; Escapes from simple parsing.
;------------------------------------------------------------------------------
; We won't come here often but there is a lot to do.
; If Compaction happens the parse subject will move in memory. So our
; pointers into it have to be made relative to its first byte and
; reconstructed later.

ParseEscape$:
; The simple parse for a trigger will have an operand then a code for the
; type of trigger. If the operand cannot be represented as just a two-byte
; reference (eg because tailed) then escape is made to load the operand.
; The other use of $mParseEscape is similar, when a target is tailed.
; Make info relative to start of subject.
 mov ax,Z.Parsee.Pt
 sub Z.Parsee.Limit,ax
 sub Z.BreakStart,ax
 sub Z.BreakEnd,ax
 sub Z.PattLenEtc,ax
 mov ProgEs,Z.ProgScope
 BackRet; PARSE suspends for a while.
; Here from XCycle when complex trigger operand has been loaded.
ResumeParse$$:inc CursorSiúpush TriggerWith
SubjectRestore:push CursorSi
; Make info reflect (possibly) new position of parsee.
 call ToDsSiCx
 mov Z.Parsee.Sg,ds
 mov Z.Parsee.Pt,si
 add Z.Parsee.Limit,si
 add Z.BreakStart,si
 add Z.BreakEnd,si
 add Z.PattLenEtc,si
 pop CursorSiúret
; Here from XCycle when tail parts have been loaded.
AssignDotsP$$:; This is like AssignDots$$ to start with.
 lodsw gs:[CursorSi]úmov StemBx,axúpush CursorSi
 mov ax,StackDiúsub ax,Z.CurrentDOúsub ax,2*$StrideV
 call DotsFsBxDsSiúDownúmov fs,Z.VarScope
; We have worked out what to assign to, Vsid, but the value to assign
; is not what is on the stack. The parse subject is on the stack and
; only a part of that is to be assigned.
; Use the code that decides what part.
; We left the parse in the WordParse stage, which operates with StackDi pushed
; and CursorDi replacing CursorSi role.
 pop ax; Was CursorSi
 push StackDi
 push dsúpush si; Will restore to fs:bx
 call SubjectRestoreúmov CursorDi,axúmov SectionSi,Z.PattLenEtc
 mov DataLenCx,Z.Parsee.Limitúsub DataLenCx,SectionSiújmp ParseAssign

;------------------------------------------------------------------------------
; Spacewise, I don't like duplicating the WordParse code. The alternative
; of first copying the isolated word to $pDiscard and then using Bassign
; worked but makes Bcode dependent on VarScope which isn't logical.
;------------------------------------------------------------------------------
; We might needed to enhance this section to allow more complex PARSE in Bcode.
; Loading trigger argument from Bcode:
ParseBcode:cmp al,String1újne @Fúcall String1$$újmp TriggerWithú@@:
 cmp al,Oneújne @Fúcall One$$újmp TriggerWithú@@:Error49Bp

ParseB:
; Looking though ds:si:cx for words. Assigning to targets given in Bcode.
; The loop will advance si with corresponding reduction in cx, in conjunction
; with di advancing through targets.
NextTargetB:mov ax,gs:[CursorDi]
; al is ultimate target. Will be checked for ParseDot.
 test al,1újnz WpDoneB; Operator to load constant for next section, end section.
; Both subcodes and operands are even, so the test for operands is by value.
 cmp al,$mPosRestújna WpDoneB
 inc CursorDi; Over target.
 JcxzQ AssignNullB
 mov bl,alútest ah,1újnz WpLastBúcmp ah,$mPosRestújna WpLastB
WpWordB:push ax
 mov bx,Attributes; Prepare to test AllBlanks.
; Move SI on to nonblank.
@@:lodsbúXlatBDLSújnz @FúLoopQ @Búpop axújmp AssignNullB
; Came out of the above loop with si advanced but cx not fully decreased.
; SectionDx remembers start of the word.
@@:mov SectionDx,SectionSiúdec SectionDxúdec cxújz WpOneB
; Move SI on to blank.
@@:lodsbúXlatBDLSújz @FúLoopQ @B
; Nothing ends the word. We want to do further searches with DataLenCx=0
WpOneB:inc DataLenCxúinc SectionSi
@@:dec DataLenCx; Word terminator not part of residue.
; SectionSi is beyond the blank but that is OK - don't want to scan it again.
 mov Z.PattLenEtc,DataLenCx; Change use.
 mov cx,SectionSiúsub cx,SectionDxúdec cx; Word length.
 xchg SectionSi,SectionDx; Back to start of the word. SectionDx for next scan.
 pop OperandBx; Was ax.
; Assign that word away, to variable specified in Bcode, now bl.
; ds:si::cx is the string.
WpLastB:cmp bl,ParseDotúje WpResumeB
; Put it on the stack, so as to use Bassign to put it away.
 pop ax; StackDiúpush axúpush CursorDiúmov StackDi,ax
 Upúcall VasDsSiCxúmov bh,0FFhúcall Bassignúpop CursorDi
; Rescan from where we had reached in getting that word.
WpResumeB:mov SectionSi,SectionDxúmov DataLenCx,Z.PattLenEtcújmp NextTargetB

; (CX is zero but is there a risk about DsSi?)
AssignNullB:mov bl,alúmov Z.PattLenEtc,ZeroBpújmp WpLastB

WpDoneB:mov CursorSi,CursorDiúpop StackDi
; The sequence of targets was ended either by a marker or by the next constant
; trigger.
 inc CursorSiútest al,1újnz TriggerArg
 cmp al,$mPosRestújna PSwitchújmp TriggerArg
;------------------------------------------------------------------------------
; This lot are about looping.
;------------------------------------------------------------------------------
Number$$:push CursorSi; The expression of DO N=Expr...
; According to $6.3.6, check on numberness should be before check of TO/BY/FOR.
 call NumDxBxújc Raise41p6
; Build DO block over where the parameter was.
 add StackDi,$StrideD-$StrideVúcmp Z.ResumeP,ZeroBpújne @F
 mov Z.Stack,StackDiúmov Z.CurrentDO,StackDi
@@:call StackSafeúmov D.Rec,0
; Default BY
 mov D.By.ExpAnd,ebpúmov D.By.Mantissa,ebpúinc D.By.Mantissa
 RetSi

ControlVar$$:
; The thing to be assigned was noted (maybe long ago).
; First argument of this Pcode is a target, as on Assign$$.
 sub StackDi,$StrideD-$StrideV; Tos now value to be assigned.
 cmp Z.ResumeP,ZeroBpúje @F
 movsx bx,gs:Bptr[CursorSi]úinc CursorSi
; This says where the control variable is relative to stack-with-this-DO
 push bxúadd bl,(2*$StrideD/$StrideV)úcall Bassignúpop bx
 jmp Bassigned
@@:
 call Assign$$
Bassigned:; What stored now in ecx:eax
 add StackDi,$StrideD; Back to addressing the loop block.
 Move V2; Have to place the CV value again so as to share compare with TO.
 mov D.CV,bx; Set CV field in LoopBlock.
; Set Leaving field in LoopBlock from argument.
 lodsw gs:[CursorSi]úmov D.Leaving,ax
AsControlVar:
 mov D.Iteration,CursorSi; Set Iterate field in LoopBlock to here.
; The test against TO is like the one at the end of a loop except that if
; it doesn't LEAVE it needs CursorSi where it is now rather than at UNTIL
; stuff.
 push StackDiúcall CompareTOúpop dx
 cmp dx,StackDiúje @Fúret; CompareTO did LEAVE
; If here is a jump, this is Until and the Iterate avoids the jump.
@@:cmp Z.ResumeP,ZeroBpújne ACV
 cmp Bptr gs:[CursorSi],$pJumpújne @Fúadd D.Iteration,3ú@@:ret

ACV:cmp Bptr gs:[CursorSi],_Jumpújne @Fúadd D.Iteration,2ú@@:ret

DotControlVar$$:
; This is the more complicated variation, so that ControlVar$$ can be kept fast.
; The code layout is like:  (expr) $pNumber, (expr) $pTo, Tail1 Tail2,
; $pDotControlVar & args, $mRepTail & arg,body of DO, $pIterCV
; Argument one of $pDotControlVar is a target, as on Assign$$.
; Argument of $mRepTail is a label, the place to go to reload tail
; components. (At Tail1 in example)
; On iteration the loop picks up at loading the tails. Whether this is first
; time or not, we need the address of the control variable.
; The $mRepTail part is not there if CV is A. rather than A.B
 lodsw gs:[CursorSi]
 cmp Bptr gs:[CursorSi+2],$mRepTailúje @F
; Here for A.
 Error49Bp
@@:mov StemBx,axúpush CursorSi
 mov ax,StackDiúsub ax,Z.CurrentDOúsub ax,$StrideV; At least a tail
 call DotsFsBxDsSi
; DotsFsBxDsSi allowed for value pickup by Dots$$.
 btr Z.Cancel,FromIterCVújc BackToIterCV
 sub StackDi,$StrideD; Tos now value to be assigned.
 Move Vsid,VúDownúmov fs,Z.VarScope
; What stored now in ecx:eax
 add StackDi,$StrideD; Back to addressing the loop block.
 Move V2; Have to place the CV value again so as to share compare with TO.
 mov D.CV,bx; Set CV field in LoopBlock.
; Set Leaving field in LoopBlock from argument.
 lodsw gs:[CursorSi]úmov D.Leaving,ax
 mov D.CVinit.Dtype,$NullString; frees space where TailsAt overlaid.
 On D.Rec,HasDot
 pop CursorSiúinc CursorSi
 push axúlodsw gs:[CursorSi]úmov D.TailsAt,axúpop ax
 On D.Rec,HasDots; Overrides HasDot.
 jmp AsControlVar

For$$:; Set field in control block
 call ToWholeEbxújc Raise26p3
 Downúmov D.ForCount.Mantissa,ebxúOn D.Rec,HasForúBackRet

To$$:; Set field in control block
 call NumDxBxújc Raise41p4
 Downúmov D.To.ExpAnd,edxúmov D.To.Mantissa,ebxúOn D.Rec,HasToúBackRet

By$$:; Set field in control block
 call NumDxBxújc Raise41p5újnz ByChar
 Downúmov D.By.ExpAnd,edxúmov D.By.Mantissa,ebx
 test dl,1újz @F
ByRetNeg:On D.Rec,ByDown
@@:BackRet

; BY value is numeric but not held as binary.
ByChar:
 call ToDsSiCxúDownúMove D.By,Vúcmp Bptr[si],'-'úje ByRetNegúBackRet

RepEver$$:Upúmov V.Dtype,$Omittedújmp FromEver; bx non-zero

Rep$$:; Set fields in control block.
; The parameter will need to be an integer.
 call ToWholeEbxújc Raise26p2úcmp ebx,ebpújs Raise26p2
; Build DO block over where the parameter was.
FromEver:add StackDi,$StrideD-$StrideV
; Assert ToWholeEbx will have filled V.Mantissa and that overlays D.Reps.Mantissa
 cmp Z.ResumeP,ZeroBpújne @F
 mov Z.Stack,StackDiúmov Z.CurrentDO,StackDi
@@:call StackSafe
; Iterate will come back to the bytes after the $pRep instruction.
; Leave address is the argument of $pRep
 lodsw gs:[CursorSi]úmov D.Leaving,axúmov D.Iteration,CursorSi
; If here is a jump, this is Until and the Iterate avoids the jump.
 cmp Z.ResumeP,ZeroBpúje @F
 cmp Bptr gs:[CursorSi],_Jumpújne IfZero
 add D.Iteration,2újmp IfZero
@@: cmp Bptr gs:[CursorSi],$pJumpújne IfZero
 add D.Iteration,3
; Leave DO if zero repetitions.
IfZero:cmp ebx,ebpúje Leave$$úBackRet

Until$$:; If T='1' then leave.
 call ToWholeEbxújc Raise34p4
 dec ebxújz DownLeaveúinc ebxújnz Raise34p4
WhUntRet:DownúBackRet

While$$:; If T='0' then leave.
 call ToWholeEbxújc Raise34p3
 dec ebxújz WhUntRetúinc ebxújnz Raise34p3
DownLeave:Down
Leave$$:; Jump to where block says, with UnDo.
 mov CursorSi,D.Leaving
UnDo$$:sub StackDi,$StrideD
 cmp Z.ResumeP,ZeroBpújne @Fúmov Z.Stack,StackDiúmov Z.CurrentDO,StackDi
@@:BackRet

IterCV$$:;Jump to where block says. This one when there is a Control Variable
 Qry D.Rec,HasDotsújnz DotsIterCV
; Retreive CV, with test of Dropped.!!
; CV could be Exposed!!
 Up
 mov bx,D1.CV
 Move V,Vbxf
 push bx
 call NumDxBxújc Raise41p1
; It would be inefficent to use all the code of Add$$ because that checks
; LHS and then RHS. We don't need the RHS (the BY value) checked again.
; Add on BY.
 Move V2,D1.By
; AddRegs only when binary !!
 call AddRegs
 pop bx
; Store that back in CV.
 call AsgnToFsBx
CompareTO:
 Qry D.Rec,HasToújz ItNoTo
 Up; Over as assigned to CV.
; Compare with TO
; !! Not good enough to do compare with Subtract because of FUZZ<>0 case.
 Move V2,D1.To,edx
 Upúcall Subtract$$
; It is possible for the result to be out of binary range.
 test V.Dtype,$Testújz ByBin
; TO value was subtracted so LEAVE when signs of result and BY are same.
 call ToDsSiCxúDown
 cmp Bptr[si],'0'úje ItNoTo; No LEAVE when compare equal.
 mov al,0úcmp Bptr[si],'-'újne @Fúinc axú@@:
 xor al,D.Recútest al,1újz Leave$$
 jmp ItNoTo
ByBin:
 Down
; Assert Subtract$$ leaves eax as mantissa.
 cmp eax,ebpúje ItNoTo; No LEAVE when compare equal.
; TO value was subtracted so LEAVE when signs of result and BY are same.
 mov al,V2.Signúxor al,D.Recútest al,1újz Leave$$
ItNoTo:
 Qry D.Rec,HasForújz ItNoFor
; Count down FOR
 dec D.ForCount.Mantissaújs Leave$$
ItNoFor:mov CursorSi,D.IterationúBackRet

DotsIterCV:; To establish the CV, it is necessary to go to the top of the
; loop again, where the tails are specified.
 push CursorSiúmov CursorSi,D.TailsAtúOn Z.Cancel,FromIterCVúBack
BackToIterCV:; From DotControlVar$$ when CV resolved.
 PopJunk ax; SI pushed by DotsControlVar$$
 PopJunk ax; XCycle return link.
; Was left Up.
 Move V,Vsid
 call NumDxBxújc Raise41p1
; Add on BY.
 Move V2,D1.By
 call AddRegs
; Store that back in CV.
 Move Vsid,V
; Doesn't work for A.  NYI
 Down
 pop CursorSi
 jmp CompareTO

IterRep$$:; This is where DO n enters.
 dec D.Reps.Mantissaújz Leave$$
Iterate$$:; This is where FOREVER enters.
 mov CursorSi,D.IterationúBackRet

;------------------------------------------------------------------------------
; This lot are about invoke and return.
;------------------------------------------------------------------------------
comment~ If an external Rexx routine is to be kept in memory between calls
to it then it will be essential to preserve the Pcode segment, and the Symbols
segment. If it has any values it will need the pools for constants and
variables, ProgScope and VarScope(s).  If it is to do new symbol lookups
(eg for INTERPRET) or if it needs default symbol values then it will need
the Vars and Consts segments but these can be reconstructed on demand from
the Symbols segment.

So it makes sense to have the Pcode and Symbols addressed from the SysFiles
compound when dormant. For execution these are made current by copying the
segment pointers to the Zone. The Vars and Constants and scopes are then
available "on demand".
~

; Invoke is like CALL, with an extra argument to count relevant parameters.
Invoke$$:lodsb gs:[CursorSi]úmov ah,-$StrideVúimul ah
 add ax,StackDi; For where the arguments are.
 mov dx,mask IsFunction; And zeroes for other flags in callee level.
 jmp AsCall

; The CALL argument is the relevant label.  There may be parameters.
Call$$:mov ax,Z.CurrentDO; Parameters lie between last DO block and new level.
 z dx
AsCall:
;MASM..............................
; ax is where the callee will find its arguments.
; dx distinguishes call v invoke.
; Should not change to new level yet, by update of Z.Level, because any
; error in calling needs to be raised in the caller level.
 push axúpush dx
; Wont hurt to complete some fields in the caller level, even if call fails.
 mov bx,Z.Level; The level being called from.
 move Lbx.LevelDO,Z.CurrentDO; Avoidable for CALL but code sharing with Invoke.
 lodsw gs:[CursorSi]; The callee.
; Note where to resume if we return to caller, in the caller level.
; (For simple case, CursorSi not pushed. But that complicates error case.)
 mov Lbx.Resume,CursorSi
; There are both .SIGL and SIGL.
 mov Ve.Dtype[$?SIGL],$Siglúmov Ve.MantLow[$?SIGL],CursorSi
 mov Vf.Dtype[$?SIGLx],$Siglúmov Vf.MantLow[$?SIGLx],CursorSi
;------------------------------------------------------------------------------
; Check that callee is callable.
;------------------------------------------------------------------------------
 mov OperandBx,ax; Target routine
 cmp Bptr Vbxe.LabelType,0újne Raise16p3; Trace-only
 mov CursorSi,Vbxe.LabelValue; Offset in Code of callee.
 TestReg CursorSiújnz NotExternal
; There was no label-with-colon in the source for this name. The
; name itself is the determinant of what is called.
 mov ds,Z.Constsúmove Z.Insert.Named,Vbx.Here; In case error 43.1
 Upúcall BxConstúmov Z.HowInvoked,sizeof FUNCTION
; Use a Bcode routine to search DOS path for the name.
External:On Z.Cancel,SourceFilesúcall Name2FileúOff Z.Cancel,SourceFiles
 z Z.ResumeP; Done with Bcode for now.
; We have looked up the fully qualified name of the source program file.
; Address the qualified name.
 mov ds,Z.SysFilesúlea dx,Jbx.Keyúmov si,Jbx.KeyLen
 cmp si,ZeroBpújne FullName

; PATHQUALIFY could not find the relevant file.
; In non-command case, not found is error 43.1
 PopJunk axúPopJunk axúmov ax,MkMajMin(43,1)
 cmp Bptr Z.HowInvoked,sizeof COMMANDúje @F
 mov StackDi,Z.Levelúmov CursorSi,L.Resumeújmp Raise
; "Routine not found" seems better than "Initializing error".
@@:dec ax; We don't have a constant to be <name>, so short msg.
; Need some initializing to prevent Raise falling over.
 z Z.Codeúz Z.InsLine
; We want <source> to be the unqualified file name.
 move Z.File,Z.InsUnqual,cxújmp Raise

;------------------------------------------------------------------------------
; Invoke the internal routine.
;------------------------------------------------------------------------------
NotExternal:; Make new level and fill fields.
 add StackDi,$StrideL; Is also new LevelDi
 pop L.Access; Was dx
 pop L.Arg0; Was ax
 move L.UpLevel,Z.Level; From new to old.
 mov Z.Level,LevelDi
 mov Z.CurrentDO,StackDi
; Procedures are marked at their beginning.
 cmp Bptr gs:[CursorSi],$pRaiseúje @FúBackRet

Raise16p3:PopJunk axúPopJunk axúmov ax,MkMajMin(16,3)újmp Raise16

@@:; Turn on flag for the benefit of Return$$.
 inc2 CursorSi; Length of Raise op.
 On L.Access,IsProcedure

comment~ Invocation of a PROCEDURE requires a new generation of the array that
accesses Rexx variables (aka a pool).  This cannot go on the stack because
INTERPRET can change it's size (by introducing a new variable) while the array
is active.  A possible design would put the Level block (Digits setting etc for
this call) at the header of the segment for the array but that would be
inefficient for a non-procedure.  So the actual design has a Level block in the
stack for every invocation, with that block addressing the array if the
invocation is for a procedure.

When a variable is EXPOSED there will be an item for it in the current pool,
ie current Z.VarScope array, to say 'exposed' and an item at the same position
in a caller's array saying 'not-exposed'.

Exposed lists can be dynamic so a name that has not been seen before provokes
a new item in both caller and callee pools. In this design the callee pool is
initially made without concern for that, and maybe extended later.
~

 push CursorSiúz si; Supports H mode of addressing.
; Is there a recycled pool space available?
 mov cx,fs:H.SegSize; Assembles better than Hf.SegSize since offset=si=zero.
 cmp Z.PoolPool,ZeroBpújne HavePool
; Z.Vars is the array for naming variables.
; Z.VarScope is the array for the values of variables.
; They are the same size, same header.
; Make space for a copy of the latter.
 call ParaAllocAxúmov ds,axújmp HaveSpace
HavePool:mov ds,Z.PoolPool
if Debug
 cmp H.SegSize,cxúje @FúError49Bpú@@:
endif
 move Z.PoolPool,H.UpPool
HaveSpace:; At ds for cx bytes.
 call VarPoolInitúpop CursorSiúBackRet

VarPoolInit:; Initialise with copy of header, variables all type Dropped.
; Used for a PROCEDURE call and for a reuse of an external.
 z bxúshr cx,$ShiftV
@@:mov Vbx.Dtype,$Droppedúadd bx,$StrideVúLoopQ @B
 z siúmov edx,fs:H.Hdw0úmov H.Hdw0,edx
 mov edx,Hf.Hdw0+4úmov H.Hdw0+4,edx
; I am not sure following is needed. It sets Link but that not needed?
 mov H.Link,Zshape.VarScope
; Procedure's pool remembers caller's pool for reinstatement at return.
; (In PROCEDURE case)
 mov H.UpPool,fs
; Zone to show the latest.
 mov Z.VarScope,dsúmov fs,Z.VarScopeúret

; To treat Command like an external call we have already put the callee name
; on the stack. Push where args are and not-a-function tag.
Command:push Zshape.CommandArg-$StrideVúpush ZeroBp
 mov Z.HowInvoked,sizeof COMMANDújmp External
;------------------------------------------------------------------------------
; Invoke an external routine.
;------------------------------------------------------------------------------
FullName:; FileBx leads to name of compilee.
 add StackDi,$StrideL; Is also new LevelDi
 pop L.Access; Was dx
 On L.Access,IsExternal
 pop L.Arg0; Was ax
 move L.UpLevel,Z.Level; From new to old.
; We can change to the new level because even if it fails to compile that will
; count as a failure in the callee.
 mov Z.Level,LevelDi
 mov Z.CurrentDO,StackDi
 mov Z.Stack,StackDi

comment~ This is the entry for an external call.  SS is set to the Zone, with
some fields in Zone already set.  In particular Z.Level is the latest level
block, the one for this callee.  It has Arg0 set for its parameters, and the
UpLevel link. There is nothing for it to inherit from, so the rest of it has
to be initialized.

Z.SysFiles in the Zone is set and in particular FileBx is the item in that
segment for the qualified name of the called source file.

~

comment~ Since we are operating with a single copy of Zone, there is quite a
lot of state to save when starting on a new program source file.
The resume address and the level of DO are already saved since they are
needed in non-external case. Also saved (in the level for the callee)
are the pointer to the caller level and the pointer for the args.
We don't need to save things that are valid across the whole execution, eg
SysFiles and Radix. We don't need to save things that are to do with the
compilation process because we are executing the call. We don't need to save
things
that are held in level blocks, eg the setting of conditions. We don't need to
save execution things that are inactive when invoke is possible, eg the PARSE
work values. I'm not sure whether it is necessary to save the randomizing Seed
but it is probably best to.

The segments relating to the caller need to be saved (or reconstructed on
return/demand).  The ones that represent compilation, Symbols and Pcode, are
saved in the SysFile entry for the DOS name of the caller source file. (The
latest version is stored in case this call is from an INTERPRET.) The segments
that represent values, VarScope and ProgScope, are saved in the caller level
block. The segments needed for lookup, Var and Consts, are stored in the
SysFile entry but lost on compaction and reconstructed on demand.(NYI)

~
; Exit is to scan for Level, so as to actually Return.

; Raise to know.

 mov LevelSi,L.UpLevel
; Outermost level has no segments to save.
 cmp LevelSi,ZeroBpúje @F
 call ZoneToLevelúmov Z.VarScope,csúmov Z.ProgScope,cs
@@:
 call SetInherit

; The Vshape part of the item (used for buffer when a data file) is not used
; in the case of source, except as a flag for whether this is first sighting
; of the file.
 cmp Vbx.Dtype,$Droppedújne KnownExternalúmov Vbx.Dtype,$NullString
; This is first sighting, so compile the source.
; ASCIIZfy.
 mov si,Jbx.KeyLen
 z clúxchg cl,Bptr(Jbx.Key[si])
; Attempt to open the source file.
 mov ax,MkMajMin($DosOpen,0)úint 21h
 mov Bptr(Jbx.Key[si]),cl; Un-ASCIIZfy
 mov Z.SourceHandle,ax
 jnc OpenedOK

; Get extended error. Don't care if es,ds changed.
 push dxúpush siúpush di
 z bxúmov ah,$DosGetErrorúint 21h
 pop diúpop siúpop dx
; if al==4 No handles left.
 cmp al,4újne @Fúmov dl,$DescFilesújmp Raise5p1ú@@:
; else some other initialization error.
 mov Z.Insert.Hex,alúmov ax,MkMajMin(3,1)úmov dl,$Desc59Hújmp Raise

if Solid
; 'E' and 'S' would do except for result of bif FORM()
$Reserved db ".MN .RS .RESULT .RC .SIGL;"
          db "1:2:3:4:5:6:7:8:9:A:B:;"
          db "9 0'' 'ENGINEERING' 'SCIENTIFIC';"
          db "ARG . RESULT RC SIGL ;push qualify('CRXREXX.QUE');"
$ReservedLen equ $-$Reserved
endif

ZoneToLevel:; Saves Zone contents before External call.
 push ax
 move Lsi.ProgScope,Z.ProgScope
 move Lsi.VarScope,Z.VarScope
 move Lsi.File,Z.File
 pop ax
 ret

OpenedOK:
 mov Z.File,FileBx; Not earlier or <source> in msgs would be wrong.

; Setup segments for Symbols etc.
; These sizes are not crucial, they are just granularity for segment expansion.
 mov cx,4096; Bytes.
 mov bx,4096-2; Trigger for when to extend.
 mov SegOffDi,Zshape.Symbolsúcall InitSegDs
; Setup segment for Code
 mov SegOffDi,Zshape.Codeúcall InitSegDs
; Setup segment for Vars
 mov cx,127*16úmov bx,127*16-2*$StrideV
 mov SegOffDi,Zshape.Varsúcall InitSegDs
; VarScope is a shadow of Vars.
 mov SegOffDi,Zshape.VarScopeúcall InitSegDs
; Setup segment for Consts
 mov SegOffDi,Zshape.Constsúcall InitSegDs
; Make offsets into ProgScope multiples of two but not of eight.
; And add a spare item for $Omitted.
 mov Wptr Hd.Avail,$StrideV+$SizeConstsHeader
; Set up ProgScope segment which contains space for $?OUTCOME etc.
 mov cx,127*16úmov bx,127*16-2*$StrideV
 mov SegOffDi,Zshape.ProgScopeúcall InitSegDs
; Make offsets into ProgScope two modulo eight.
; And add a spare item for $Omitted.
 mov Wptr Hd.Avail,$StrideV+$SizeConstsHeader
if MemCheck
 call DosMemCheck
endif
;------------------------------------------------------------------------------
; Initializing of names for Lookup is done by an INTERPRET of $Reserved string.
;------------------------------------------------------------------------------
 call UpStack
 mov V.Sg,cs
 mov V.Pt,offset $Reserved
 mov V.Len,$ReservedLen
 mov V.Dtype,$AwayString
 mov gs,Z.Code
 call Interpret1; Interpret with labels allowed, no execution.
; Any code made from Reserved is unwanted.
 mov Hg.Avail,$StrideH
; The labels were just to reserve some slots. Lookup should not see them.
 z siúmov ds,Z.Constsúz H.Labelsúz H.TreeBin
; Make the constant for Omitted special.
; Omitted to have value of null string and unique datatype.
 move Vsid.Here[$?Omitted],Vsid.Here[$?Null]
; Last stream encountered in $Reserved was for Rexx queue.
 move Z.Queue,Z.Stream
 call ProgScopeInit
 mov ds,Z.SysFiles
Jett:; Just a label for debugging.
if MemCheck
 call DosMemCheck
endif
 jmp Compiler

ProgScopeInit:; SI is set zero
 push StackDi
 mov ds,Z.ProgScope
 z si
 mov di,$StrideH
@@:mov Bptr[di],0úinc diúcmp di,$?Nineújb @B
 mov Vsid.Dtype[$?Omitted],$Omitted
; Set the type of some SysVars.
 mov Vsid.Dtype[$?RESPONSE],$NullString+1
 mov Vsid.Dtype[$?CLAUSETIME],$NullString
 mov Vsid.Dtype[$?STARTTIME],$NullString
 mov Vsid.Dtype[$?RESULT],$NullString
 pop StackDi
 ret

KnownExternal:; Invoke of something previously compiled.
 move Z.File,FileBx
 move Z.Symbols,F.Symbols
 move Z.Code,F.Code
 move Z.Consts,F.Consts
 move Z.ProgScope,F.ProgScope
 move Z.Vars,F.Vars
 call ProgScopeInit
; !! If only one copy of ProgScope values, need .MN etc in Level.
if 0
 We could have reconstructed ProgScope from Symbols
; Size of Z.ProgScope is the same as Z.Consts.
 mov fs,ax!!úmov cx,Hf.SegSize
 call ParaAllocAxúmov ds,axúmov Z.ProgScope,ax
; Headers are the same except for Link field.
 mov edx,fs:H.Hdw0úmov H.Hdw0,edx
 mov edx,fs:H.Hdw0+4úmov H.Hdw0+4,edx
 mov H.Link,Zshape.ProgScope
; Fill in the values of the constants.
endif
; Make Z.VarScope for the callee.
; Size of Z.VarScope is the same as Z.Vars.
 mov fs,axúmov cx,Hf.SegSize
 call ParaAllocAxúmov ds,axúmov Z.VarScope,ax
 call VarPoolInit
 mov Hf.UpPool,ZeroBp; Unlike PROCEDURE
 jmp StartExecution

Result$$:DownúBackRet; Lose unwanted result from called bif.

Returns$$:
 push V.Mantissaúpush V.ExpAnd
 mov LevelDi,Z.Level; Lose DO's at this level.
 Qry L.Access,IsFunctionújz CallResult
 call ReturnX
 Upúpop V.ExpAndúpop V.Mantissa
 BackRet

CallResult:
 call ReturnX
 Upúpop V.ExpAndúpop V.Mantissa
; Set RESULT special variable.
 Move Vf[$?RESULTx],V
; Set .RESULT reserved variable.
 Move Ve[$?RESULT],V
 Down
 BackRet

Return$$:mov LevelDi,Z.Level; Lose DO's at this level.
; Check for RETURN when called as a function.
 Qry L.Access,IsFunctionújz ReturnX
; Msg 45.1 happens in the callee. (External has 44.1 in caller)
 Qry L.Access,IsExternalújnz PlainRet
; Recover caller name.
 mov LevelDi,L.UpLevel; Invoker block. Assert cannot be zero.
 mov CursorBx,L.Resume; Invoker holds resume point.
 mov ArrayBx,gs:[CursorBx-2]
 mov ds,Z.Constsúmove Z.Insert.Named,Vbx.Here
 mov ax,MkMajMin(45,1)újmp Raise

; If this is a procedure folding, there will be a change of Z.VarScope.
ReturnX:Qry L.Access,IsProcedureújz PlainRet
; Current scope goes on freespace chain.
 mov ax,Z.PoolPool
 xchg ax,Hf.UpPool
 mov Z.PoolPool,fs
; Caller's pool becomes current.
 mov Z.VarScope,ax
 mov fs,ax
PlainRet:
; Drop RESULT special variable.
 mov Vf.Dtype[$?RESULTx],$Dropped
; Drop .RESULT reserved variable.
 mov Ve.Dtype[$?RESULT],$Dropped
 mov LevelSi,L.UpLevel; Invoker block.úTestReg LevelSiújz Exit$$
 mov Z.Level,LevelSi
; Some Zone restoration from callers stuff if an External is being left.
 Qry L.Access,IsExternalújz @F
 move Z.ProgScope,Lsi.ProgScopeúmov ProgEs,ax
 move Z.VarScope,Lsi.VarScopeúmov fs,ax
 move Z.File,Lsi.File,FileBxúmov ds,Z.SysFiles
 move Z.Symbols,F.Symbolsúmove Z.Code,F.Codeúmov gs,ax
 move Z.Consts,F.Constsúmove Z.Vars,F.Vars
@@:
; Return can have the effect of altering the current digits().
; But only if the invokee(s) altered digits().
 Qry L.Access,DigitsSetújz @F
 call DigitsChange
@@:
; Lose arguments and level block of completing routine.
 mov StackDi,L.Arg0úmove Z.CurrentDO,Lsi.LevelDO
 mov CursorSi,Lsi.Resume; Invoker holds resume point.úBackRet

Exit$$:; Exit has an optional argument.
 z cxúcmp StackDi,Z.CurrentDOúje @F
 inc cxúpushd V.ExpAndúpushd V.Mantissa
@@:push CursorSi
; Go up the Level chain to the current External
ExitUp:mov LevelSi,Z.Levelúmov StackDi,Lsi.Arg0
if Debug
 TestReg LevelSiújnz @FúError49Bpú@@:
endif
 Qry Lsi.Access,IsExternalújnz @F
 move Z.Level,Lsi.UpLevel,LevelSiújmp ExitUp
@@:move Z.CurrentDO,Lsi.LevelDO
; Is this the outermost external (that came as a command)?
 cmp Lsi.UpLevel,ZeroBpúje @F
 pop CursorSiúTestReg cxújz Return$$; EXIT with no argument becomes RETURN.
 Upúpop V.Mantissaúpop V.ExpAndújmp Returns$$; EXIT(...) becomes RETURN(...)
@@:; True exit. Can only return a byte (in AL) as result.
if 0
; Close all files.
 mov ds,Z.SysFiles
 mov dx,Hd.Avail
 mov bx,$StrideH; Steps through files.
NextFile:call CloseBx
 Wrong see Compaction
 add bx,$StrideF
 add bx,Jbx.KeyLenúadd bx,$StrideJ
 cmp bx,dxújb NextFile
endif

Exit:
 mov al,$SerialNoneúcall Serialize
 mov bx,Z.Dumper
 mov ah,$DosCloseúint 21h
ExitDOS:mov ah,$DosExitúint 21h

;------------------------------------------------------------------------------
; Here are the other operators for expressions.
;------------------------------------------------------------------------------
comment~
Aug99 plan is to have $AwayNumber as a general form for numbers and have a
binary format as an optimization, used for values that will fit in the 8 byte
binary format.  ($AwayNumber is currently being done as a char string by ARITHOP
but there is potential to go to binary.)

This Jan 2000 rewrite of the problems caused by changing of NUMERIC settings.

Problem #1:  For performance we plan to keep arithmetic results (eg J+1) in
binary when the value allows that. Problem is that eventual use may be a
string context (eg K=J+1;say K).  The conversion to string needs to know
about the NUMERIC settings as they were when the value was created. (They
may have changed since.)  There isn't room to keep this info with the value
so conversion has to assume the normal (default) settings of 9 digits and
SCIENTIFIC form.  So if the actual settings are different (strictly speaking,
would lead to a different string result) then we cannot keep an arithmetic
result as binary.  This isn't an awful problem because most arithmetic will
be at normal settings and values with lots of digits could not be held in
eight-byte binary anyway.

Problem #2:  We would like to convert constants, ie 77 in ABC+77, to binary
at compile time. But we cannot simply do that because 77 has value 8E1 at
digits one.  There is a theoretical approach of waiting until digits<9 happens
then reworking the constants but that would mean knowing which were BIF
arguments since these don't need reworking.

Problem #3:  A number held in binary will have been made at digits nine. If
used at digits less than nine it will have to be converted to string and then
back to number, the latter conversion making any LOSTDIGITS adjustment.

There are two reasonable implementations. (1) When digits changes to below nine
find all binary values and make them string.  (2) Check digits setting before
use of each binary value.

Problem #4:  Changes in digits() should be shielded from the Bifs, which have
their own precision rules.

About ArithOp.  The ArithOp routine from the standard, implemented as Bcode,
is our way of doing the general case of Rexx arithmetic.  The standard runs
ArithOp with digits setting "as necessary"; in practice the setting of the
caller seems sufficient.  Explicitly and implicitly ArithOp recurses, eg
division done by repeated subtraction.  This recursion has to end, by
ensuring that single digit plus single digit does not recurse. To avoid
complication when digits()=1, when 7+7\=14 but LOSTDIGITS, it seems best to
provide a CONFIG_ADD for the single digit case.

ArithOp is not intended to be speedy.  The implementation would be faster
for digits()\=9 if the binary Add$$ routine was used for values that fitted
in 8 bytes, even when the current digits() was not nine.  For this to work
some extra tests are needed.  Binary values coming into the arithmetic have
to be checked for possible LOSTDIGITS. Binary results have to be checked
for possibility that character conversion would not give the same result
as digits nine would.  So having these checks is a trade-off of slower
execution of normal arithmetic in favour of speeded non-nine arithmetic.


The interesting coding for Add$$ etc.is when both operands come as binary.

Shifts needed to bring operands into alignment can lead to an intermediate
result which needs to be rounded to bring it into digits() range. (Although
64 add/subtract is enough for intermediate results whatever the shifts.)

There needs to be fast access to the power of ten that determines if rounding is
necessary. This costs a test on RETURNs, looking for change of digits().

~
; Aug 99 - clumsy interface to ArithOp since future undecided.
Raise41p2BLM:int 3újmp Raise41p2
ArithRight:jc Raise41p2BLM
ArithGeneral:
 mov dl,gs:Bptr[CursorSi-1]úpush CursorSi
 Downúcall ToDsSiCxújmp @F

Raise41p1BLM:int 3újmp Raise41p1
ArithLeft:jc Raise41p1BLM
 mov dl,gs:Bptr[CursorSi-1]
ArithDl:push CursorSi; Entry with lower already string and DL for the operator.
@@:Upúcall ToDsSiCx
 Upúmov V.Dtype,$NullString+1
 mov V.String,'>'; All compares
 cmp dl,$pAddújne @Fúmov V.String,'+'ú@@:
 cmp dl,$pSubtractújne @Fúmov V.String,'-'ú@@:
 cmp dl,$pNegateújne @Fúmov V.String,'-'ú@@:
 cmp dl,$pPositiveújne @Fúmov V.String,'+'ú@@:
 cmp dl,$pMultiplyújne @Fúmov V.String,'*'ú@@:
 cmp dl,$pDivideújne @Fúmov V.String,'/'ú@@:
 cmp dl,$pIntDivideújne @Fúmov V.String,'%'ú@@:
 cmp dl,$pRemainderújne @Fúmov Wptr V.String,'//'úinc V.Dtypeú@@:
 cmp dl,$pPowerújne @Fúmov Wptr V.String,'**'úinc V.Dtypeú@@:
 call HeritageDiúmovzx eax,L.Digitsúmov dx,L.Fuzzúpop StackDi
 cmp V.String,'>'újne @Fúsub ax,dxú@@:
 Upúmov V.Mantissa,eaxúmov V.ExpAnd,ebp
 pop CursorSiúpush CursorSi; Might be needed for Msg
 mov dx,offset ARITHOP$$úcall LinkBcodeúmov Z.Stack,StackDi
 pop CursorSi
if Debug
 CheckType
 int 3
@@:
endif
; We do some conversions at compile time.
 mov ProgEs,Z.ProgScope
 cmp Z.Scanp,ZeroBpúje @F
 mov SymbolsEs,Z.Symbols
@@:BackRet

; The binary operators find their LHS as the older parameter and their RHS
; as the latest parameter.
; Add, subtract, and numeric compare are similar.
; If the values are too big for the precision we must use ArithGeneral to
; raise LOSTDIGITS. This check is in NumDxBx
Add$$:; Required to check left one first.
 Downúcall NumDxBxújnz ArithLeft
 mov ecx,edxúmov eax,ebx
 Upúcall NumDxBxújnz ArithRight
 Down
; Now we know it is to be done in binary, the predominant case.
AddRegs:;LHS in ecx:eax (V originally)   RHS in edx:ebx (V2 originally)
; Easy case with both signs and exponents the same.
 cmp ecx,edxújne AddTest
; Result cannot be zero unless both operands were, in which case exponent
; already zero.
 add eax,ebxúcmp eax,Z.Ceilingújae Round32; Unusual
AddSubEax:mov V.Mantissa,eax
AddSubNull:
; If not SCIENTIFIC 9, convert to char because if char needed later the
; numeric settings may have changed.
 cmp Z.UseGeneral,ZeroBpúje AddS9b
; Don't want to do this in Bcode because (1) numeric setting won't lower and
; (2) assumptions of S9 are made.
 cmp Z.ResumeP,ZeroBpújnz AddS9b
 push CursorSi
 call ToDsSiCx
 pop CursorSi
AddS9b:BackRet; Does not guarantee registers match V.

Round32:;32 bit result to be roundedúz edxújmp Acc64

; Mantissa shifted out of significance is the same as being zero.
AlignNoOver:add edx,ecxúmov ebx,eax
RetEdxEbx:mov V.ExpAnd,edxúmov V.Mantissa,ebxúBackRet

AddTest:; Still doing AddRegs, after some cases handled.
; Test zero mantissas.
 cmp ebx,ebpúje AddSubNull; LHS+0 case.
if 0
 Problems with rounding.
cmp eax,ebpúje RetEdxEbx
endif
; If the signs differ, change sign and change to a subtract.
 push edxúxor edx,ecxútest dl,1úpop edxújz @Fúxor dl,1újmp SubRegsú@@:
; Signs are now the same but exponents will not be.
 cmp ecx,edxújge @F; First make LHS have the large exponent.
; Simplest is to change A+B to B+A.
 xchg edx,ecxúxchg ebx,eax
@@:sub ecx,edx; ecx is non-negative, twice the difference of exponents.
; If the difference is large there will be no overlap of mantissae
; and the big magnitude operand is the result.
 cmp ecx,Z.TwiceDigitsújge AlignNoOver
; Multiply by appropriate power of ten. (ecx is double shift required)
 push edxúmul Ycx2.N1; Indexing does a second doubling.
; It may be we are just adding cents to dollars and the result is going to fit
; in 32 bits but more likely we are doing a scientific calculation which has
; built up nine digits. So probably best just to do things with 64 bits(?).
 pop ecxúadd eax,ebxúadc edx,ebp
; Assert ebx+eax cannot have result zero. (So pushed edx remains the exponent)
; Does result need rounding? Note that V & V2 are intact, for a possible msg.
 cmp edx,ebpújne Acc64
AddPos32:cmp eax,Z.Ceilingújae Acc64
PostAcc64:Move VúBackRet

OneMore:z edxújmp ChangeExpon

ToArithGeneral:Upújmp ArithGeneral

Acc64:; The 64 bit accumulator edx:eax has a result that is too big for
; Z.Ceiling.
; It may need rounding, or if current digits >9 it needs rework as long.
 cmp Z.Digits,9úja ToArithGeneral
; The exponent of the result is in ecx. (Doubled form)
 push CursorSi
; Something with BSR instruction and lookup might be quicker than a loop here.
; We are going to have to reduce the Mantissa and bump the exponent at least
; once. Do initially divide with enough to zero edx of edx:eax.
ChangeExpon:z si
@@:add ecx,2úadd si,4úcmp edx,Ysi.N1újae @B
 div Ysi.N1; Division by this power of ten will give result in 32 bits.
; That took (edx*2**32+eax)*(ecx/2) to eax*10**(N+ecx/2) with edx remainder.
 cmp eax,Z.Ceilingújae OneMore
; We have enough significant decimals to the eax number. edx decides rounding.
 add edx,edxúcmp edx,Ysi.N1újb @Fúinc eax
; It is just possible accum is now exactly over limit
 cmp eax,Z.Ceilingúje OneMore
@@:pop CursorSi
; Quick test accepts most exponents.
 cmp ecx,Y.ExponHiújg TestExpon
 cmp ecx,Y.ExponLoújg PostAcc64

comment~ The exponent is held in binary, representing a decimal exponent.
Testing is not as simple as testing -999999999 to +999999999 because
(a) the mantissa is held as integer so giving the mantissa a decimal point in
the correct place increases the exponent and (b) Engineering notation can reduce
the exponent. However, these effects are limited so we can be sure most
exponents are OK by testing a smaller range, Y.ExponLo to Y.ExponHi.
When that test is inconclusive, the simplest thing is to convert to decimal and
test that. For that to work, ToDsSiCx needs to cope with exponents up to 2**32.
~
TestExpon:; The quick check on V. has already been made, so ecx is extreme.
; Need to keep original LHS for possible message.
 pushd V.ExpAndúpushd V.MantissaúMove V
 push CursorSiúpush ecxúcall ToDsSiCx
@@:dec cxúinc siúcmp Bptr[si],'E'újne @Búmov dl,Bptr[si+1]
 cmp cx,$Limit_ExponentDigits+1úpop ecxúpop CursorSi
 pop V.Mantissaúpop V.ExpAndúja PostAcc64
; 40.9 and 41.7 occur on loading operands for input to operations.
; 42.1 and 42.2 occur when testing the output of operations.
 mov ax,MkMajMin(42,1)úcmp dl,'+'úje Raiseúinc axújmp Raise

Subtract$$:; Required to check left one first.
 Downúcall NumDxBxújnz ArithLeftúmov ecx,edxúmov eax,ebx
 Upúcall NumDxBxújnz ArithRightúDown

SubRegs:; Read the code for Add first.
 cmp ecx,edxújne SubTestúsub eax,ebxújz SubZero
 jl @Fúcmp eax,Z.Ceilingújb AddSubEaxújmp Round32
@@:xor cl,1úneg eaxúcmp eax,Z.Ceilingújae Round32
SubAddEcxEax:mov V.ExpAnd,ecxújmp AddSubEax

SubTest:cmp ebx,ebpúje AddSubNull
; If the signs differ, change sign and change to an add.
 push edxúxor edx,ecxútest dl,1úpop edxújz @Fúxor dl,1újmp AddRegs
SubRegsCmp:; Here from compare, avoiding some tests.
@@:cmp ecx,edxújge @F
; Simplest is to change A-B to (-B)-(-A), so exponents ordered.
 xor cl,1úxor dl,1úxchg edx,ecxúxchg ebx,eax
@@:sub ecx,edxúcmp ecx,Z.TwiceDigitsújge AlignNoOver
 push edxúmul Ycx2.N1
 pop ecxúsub eax,ebxúsbb edx,ebpújns SubPos
; Subtract is harder than Add, since zero and negative possible.
 xor cl,1úneg eaxúpushfúneg edxúpopfújnc @Fúdec edxú@@:
SubPos:cmp edx,ebpújne Acc64úcmp eax,ebpújnz AddPos32
SubZero:mov V.ExpAnd,ebpújmp AddSubEax

;------------------------------------------------------------------------------
; Conditional Pcode jumps and Boolean results here.
;------------------------------------------------------------------------------
if 0
This proved to be a lot slower. Kept just for interest.
comment~ The way to do conditionals without writing into code is to use an
array of sequences like (jb @Fúxax CursorSiú@@:ret) and branch to one of them.
 (sete alúret) for boolean results.  However, this version writes to code.
~
Eq$$:úNe$$:úLt$$:úLe$$:úGe$$:úGt$$:
; Alter code so that eventual test, after comparison, is the intended
; conditional jump.
 mov al,cs:Conditionals[bx-$pEq]úmov Bptr cs:Conditional,al
; SetFlags is used from elsewhere as a subroutine.
SetFlags:; Set hardware flags from compare and also ax from Pcode.
FlagsSet:lodsw gs:[CursorSi]
....
; User wants fallthru on Pcode if the test succeeds, else continuation at ax.
Conditional:je @Fúmov CursorSi,axú@@:BackRet
endif

; CmpGen is the general test for whether non-strict is char or arith compare.
; Already filtered off (at compile) case where one argument is non-arith const.
; Already filtered off case of both in binary.

StringC:Up; RHS was number but LHS proved not.
 Move V; Non-binary form of RHS
 jmp StringCompare

CmpGen2:; RHS is bin (and was originally), LHS may be convertible.
 call NumDxBxújnc CmpArithúUpújmp StringCompare

; No msgs so we can look at rhs first.
; This is a touch clumsy because NumDxBx is destructive - usually conversion
; is desirable if possible - but for comparison we want conversion only
; if both will convert.
CmpGen:Move ,Vúcall NumDxBxújc StringCompare
; RHS is some sort of numberúDownúcall NumDxBxújc StringC
; Both some sort of arith.  ArithGeneral if either out of range for Binary.
; Or if FUZZ<>0
CmpArith:jnz @F
; 2011 UseGeneral does not apply if both binary.
; cmp Z.UseGeneral,ZeroBp
; jne @F
 test V2.Dtype,$Test
 jz FromCmpGen; For binary Arith compare after conversion(s).
@@:Up
 call ArithGeneral
 call NumDxBxújz MantPare
; Difference was still not binary.
 lds bx,V.Fr
 z V.ExpAndúz V.MantHigh
 cmp Bptr[bx],'-'újne MantPare
 inc V.Signújmp MantPare

Eq$$:úNe$$:úLt$$:úLe$$:úGe$$:úGt$$:
; Convert particular operator to place in Rejumps.
 shl bx,2úadd bx,Rejumps-(4*$pEq)úpush bx
SetFlags:; Set hardware flags from compare and also ax from Pcode.
; Is it worth a quick test for the number v number case? (Avoids CmpGen)
 cmp Z.UseGeneral,ZeroBpújne CmpGen
 test V.Dtype,$Testújnz CmpGenúDownútest V.Dtype,$Testújnz CmpGen2
FromCmpGen:; When conversions to binary worked.
 Move ,Vúmov edx,V2.ExpAndúmov ebx,V2.Mantissa
; RHS in edx:ebx LHS in ecx:eax
 xor ecx,edxújz EasyPare; Quick if exponents and signs are the same.
 test cl,1újnz EasySign; Quick if signs differ.
 mov ecx,V.ExpAnd
; Subtract and test result will work but may be overkill.
; Signs are the same, exponents differ.
;Exponent is irrelevant if comparison is with zero.(Nearly 1/4 of reached here)
  cmp ebx,ebpúje EasyPare
; Subtract and test result.
 call SubRegsCmp
; Compare Mantissa with zero.
MantPare:mov eax,V.Mantissaúz ebx
EasyPare:test V.Sign,1újz @Fúxchg eax,ebxú@@:
 Downúcmp eax,ebx
; Interpreted branch conditional.
; Flags reflect relation.
 lodsw gs:[CursorSi]
; User wants fallthru on Pcode if the test succeeds, else continuation at ax.
; We jump to some jump conditional.  (Or return if called.)
 ret
EasySign:; Deduce result from the (differing) signs.
 Downúmov ax,1útest dl,1újnz @Fúxchg ah,alú@@:cmp al,ah
 lodsw gs:[CursorSi]
 ret

;------------------------------------------------------------------------------
; The C series of compares are known from compile time to be string compares.
; They join the general case once the hardware flags are set.
; The S for strict series are similar.
; The _ series of Bcode operators is similar but with one byte jump addresses.
;------------------------------------------------------------------------------
@@:Downúcall ToDsSiCxúUpújmp @F

Ceq$$:úCne$$:úClt$$:úCle$$:úCge$$:úCgt$$:
 shl bx,2úadd bx,Rejumps-(4*$pCeq)úpush bx
StringCompare:; Space traded for speed.
 mov bx,Attributes; For potential XLAT
 push CursorSi
; If the left one isn't a string then better convert it now so that no
; compaction threat from ToDsSiCx of it.
 test V0.Dtype,$Testújz @B
@@:call ToDsSiCx
 JcxzQ FromStripR
; All my blanks rank no higher than plain blank so quick test is possible.
 mov dx,FromStripR
 cmp Bptr[si],' 'újbe StripB
 push siúadd si,cxúdec siúcmp Bptr[si],' 'újbe StripEúpop si
FromStripR:
 mv es,dsúpush siúpush cx
 Downúcall ToDsSiCx
 JcxzQ FromStripL
 mov dx,FromStripL
 cmp Bptr[si],' 'újbe StripB
 push siúadd si,cxúdec siúcmp Bptr[si],' 'újbe StripEúpop si
FromStripL:pop bxúpop ax
FromStrict:Down
; Now strict comparison of the lhs(ds:si:cx) with rhs(es:ax:bx)
 push StackDiúmov di,axúmov ax,cx
; Change cx to shared length.
 cmp bx,cxújg @Fúmov cx,bxú@@:
 cmp bp,bp; Zero flags in case cx=0.
 repe cmpsbújne @F
; Equal over shared length. Comparison now on lengths.
 cmp bx,ax
@@:; Flags reflect relation.
 mov ProgEs,Z.ProgScope
 pop StackDiúpop CursorSi
 lodsw gs:[CursorSi]
 ret

; Remove all types of blank from both ends of Ds:Si:Cx
StripB:lodsbúXlatBDLSújnz @FúLoopQ StripBújmp dx
@@:dec si
push siúadd si,cxúdec si
StripE:std
@@:lodsbúXlatBDLSújnz @FúLoopQ @B
@@:cldúpop siújmp dx
Seq$$:úSne$$:úSlt$$:úSle$$:úSge$$:úSgt$$:
; Convert particular operator to place in Rejumps.
 shl bx,2úadd bx,Rejumps-(4*$pSeq)úpush bx
StrictFlags:push CursorSiúcall ToDsSiCxúmv es,dsúmov ax,siúmov bx,cx
 Downúcall ToDsSiCxújmp FromStrict

; The prefix to a comparison operator means the result is to go to the
; stack rather than used for a conditional jump.
; It would have been simpler to reserve a zero value of jump to mean Boolery
; but we don't want to add a test to the more frequent case.
; There is shared code for doing the comparison, entered at different places
; for strict and non-strict.
; That code ends with a jump to something it pops.  For conditional branch
; that jump leads to a conditional jump instruction. For Bool$$ it leads
; back to BoolBack.
Bool$$:mov bl,gs:[CursorSi]
 cmp bl,$pSeqújae BoolSC
; Stride is eight in the table we will eventually use. Stride of $pXXX is two.
 shl bx,2úpush bxúcall SetFlags
BoolBack:; Hardware flags reflect the relation.
 lea CursorSi,(-1)[CursorSi]; Non-existent target word was loaded.
 pop bxúlea bx,(Boolery-4*$pEq)[bx]
SetV:UpCareúmov V.ExpAnd,ebpúmov V.Mantissa,ebpújmp bx

BoolSC:cmp bl,$pCeqújae BoolC
 add bl,($pEq-$pSeq)úshl bx,2úpush bxúpush BoolBackújmp StrictFlags

BoolC:
 add bl,($pEq-$pCeq)úshl bx,2úpush bxúpush BoolBackújmp StringCompare
_Eq$$:ú_Ne$$:ú_Lt$$:ú_Le$$:ú_Ge$$:ú_Gt$$:
; Convert particular operator to place in Rejumps.
 shl bx,2úadd bx,Rejumps-(4*_Eq)úpush bx
 call SetFlags; Hardware flags reflect the relation.
; That code assumed two-byte jump argument so step back a byte.
Relatives:pushfúdec CursorSiúz ahúdec axújs @Fúadd ax,CursorSiúpopf
 ret; To Rejumps.
@@:; We use zero relative jump to mean Boolery.
 popfúpop bxúlea bx,(BooleryRejumps)[bx]újmp SetV

_Seq$$:ú_Sne$$:ú_Slt$$:ú_Sle$$:ú_Sge$$:ú_Sgt$$:
; Convert particular operator to place in Rejumps.
 shl bx,2úadd bx,Rejumps-(4*_Seq)úpush bx
 call StrictFlagsújmp Relatives

;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
Multiply$$:Downúcall NumDxBxújnz ArithLeftúmov ecx,edxúmov eax,ebx
 Upúcall NumDxBxújnz ArithRightúDown
; StackDi is at the LHS & Result. LHS in eax:ecx RHS in ebx:edx
; Signs & Exponents by add of (Exponent*2 + Sign) unless both negative.
; Both negative made into both positive.
 test cl,1újz @Fútest dl,1újz @Fúdec cxúdec dxú@@:add ecx,edx; Exponent result.
 mul ebxújc Acc64
MagTest:
 cmp eax,Z.Ceilingújae Acc64
 cmp ecx,Y.ExponHiújg TestExpon
 cmp ecx,Y.ExponLoújl TestExpon
 Move V
 BackRet

Check34:; Leaves V. with rhs, bx as rhs.
 Downúcall ToWholeEbxújc Raise34p5
 dec ebxújz @Fúinc ebxújnz Raise34p5
@@:Up
Check34A:
 call ToWholeEbxújc Raise34p6úmov ax,bx
 dec ebxújz @Fúinc ebxújnz Raise34p6
@@:Downúmov bx,axúret

Xor$$:call Check34
Xorx:xor Bptr(V.MantLow),blúBackRet

Or$$:call Check34úor Bptr(V.MantLow),blúBackRet

And$$:call Check34úand Bptr(V.MantLow),blúBackRet

Not$$:call Check34AúUpúmov bl,1újmp Xorx

; NUMERIC settings. When the settings change, all the constants have to be
; scanned to be sure that only those convertable both ways are held as binary.
; Also if Digits<>9 or Fuzz<>0 we need to use different operators.

Form$:push CursorSi; Parameter is the VALUE.
; Test first character of the parameter.
 call UpperFirstAh
 cmp ah,'E'úje NewForm
 cmp ah,'S'újne Raise33p3
NewForm:call HeritageDiúmov L.Form,ah
FormRet:call ZoneNumerics
FormRetx:pop StackDiúDownúpop CursorSiúBackRet

; Routine sets carry if value not whole >= zero.
ToWholeEbxGE:call ToWholeEbxújc @Fútest V.Sign,1újz @Fústcú@@:ret

; Set up for <value> inserts that is actually value of Digits().
DigInsertz:xchg ax,bx
; AX for second <value> of msg.
DigInsertx:mov V.MantLow,axúmov Z.Insert.Digits,bxújmp Raise33p1

Numeric$$:mov bl,Bptr gs:[CursorSi]úinc CursorSiújmp Numeric$[bx]

if Solid
Numeric$:
 dw Digits$
 dw Fuzz$
 dw Form$
endif

Digits$:push CursorSi;Defaulted parameter was added in making Pcode.
 call ToWholeEbxGEújc Raise26p5
; New Digits, test range.
 cmp ebx,$Limit_Digitsúja Raise33p2úmov ax,Z.Fuzzúcmp bx,axújbe DigInsertx
 call HeritageDiúmov L.Digits,bx
; If Digits() changed we need to keep the Zone up-to-date, etc.
 call DigitsChangeújmp FormRetx

DigitsChange:;Also used at Return$$úpush di
; Z.Digits is what we have been running at.
; The Level has been set to desired Digits.
 mov LevelDi,Z.Levelúmov bx,L.Digitsúmov dx,Z.Digits
 cmp bx,dxúje DigitsSame
 On L.Access,DigitsSet
 call ZoneNumerics
DigitsSame:pop diúret

; Values in a level block which are normally inherited are not inherited when
; this is an external call.
SetInherit:mov LevelDi,Z.Level
 Assert (Lshape.Inherit-Lshape.Digits) mod 4 eq 0
 mov cx,(Lshape.Inherit-Lshape.Digits)/4
 mv es,ssúpush LevelDiúlea di,L.Digitsúz eaxúrep stosdúpop LevelDi
 mov L.TraceLetter,'N'úmov L.Digits,9úmov L.Form,'S'úOn L.Access,InheritDone

ZoneNumerics:; The Zone is kept showing current settings.(Speeds up arithmetic.)
; Source of settings is the current Level.
 push ecxúpush eaxúmov ecx,L.DigitsFuzzúmov Z.DigitsFuzz,ecx
 movzx ecx,cxúadd ecx,ecxúmov Z.TwiceDigits,ecx
 z Z.UseGeneral
 Off Z.Program,NotS9
 cmp cx,18újna @Fúmov cx,18ú@@:
 je @FúOn Z.Program,NotS9úinc Z.UseGeneralú@@:
; FUZZ<>0 is rarely used. It won't hurt to generalize all operations then,
; even though only compares are affected.
 cmp Z.Fuzz,ZeroBpújne Fuzzy
 cmp L.Form,'S'úje @F
Fuzzy:On Z.Program,NotS9úinc Z.UseGeneralú@@:
 movzx ecx,cxúmov eax,Ycx2.N1úmov Z.Ceiling,eax
 mov eax,Ycx2.N1-4úmov Z.DivBreak,eax
 pop eaxúpop ecxúret

Fuzz$:push CursorSi;Defaulted parameter was added in making Pcode.
 call ToWholeEbxGEújc Raise26p6
; New Fuzz, test bound.
 movzx eax,Z.Digitsúcmp ebx,eaxújae DigInsertz
; Keep the Zone up-to-date
 call HeritageDiúmov L.Fuzz,bxújmp FormRet

comment~ We want to put the dividend to the significant end of edx:eax so as to
get most digits in the result.  But if too far that way, the result may not fit
in 32 bits when divisor is small.  Could work out how far ebx needs change to
make it bigger than eax.  However, an algorithm that tries to develop all the
digits in one shot only works well for something like 1/3 as opposed to 6/3.
For 6/3 it will lead to a number ending with lots of zeros that have to be
pruned off (a division each).  Seems better to try for a few digits at a time.

So increase dividend until bigger than divisor.  Do a divide.  Done if remainder
zero.  Done if enough digits.  Multiply result-so-far and remainder until
remainder bigger than divisor (exit if enough digits). Iterate with remainder as
dividend.

That works but some heuristic might be faster, perhaps assuming the division
won't have short result if eax starts less than ebx.

~
IntDivide$$:
Remainder$$:
Divide$$:mov Z.OpIs,bl
 Downúcall NumDxBxújnz ArithLeftúmov ecx,edxúmov eax,ebx
 Upúcall NumDxBxújnz ArithRightúDown
 push CursorSi
; About to divide ecx:eax by edx:ebx, result to V.
 cmp eax,ebpúje DivideNull
 cmp ebx,ebpúje ZeroDivide
; Sign of answer to Z.SignM
 mov Z.SignM,clúcmp Z.OpIs,$pRemainderúje @Fúxor Z.SignM,dlú@@:
 sar ecx,1úsar edx,1
 sub ecx,edx; ecx now result exponent undoubled. edx freed.
 mov esi,ebpúmov edx,ebp
; esi**ecx now with partial result (0 to begin). eax:edx now 64 bit dividend.
 cmp Z.OpIs,$pDivideújne RemIntDiv
@@:cmp eax,ebxújae @F
; Multiply achieves shift of one decimal place, 64 bit answer in edx:eax.
; Shift will be compensated by exponent adjustment.
 dec ecxúmul Y.N10újnc @B
@@:; Now Dividend at least size of divisor.
; That was just a speedup to avoid producing initial zeros from the loop.
DivLoop:div ebx; Divide into edx:eax with result to eax and remainder in edx.
; ((esi+eax)*ebx+edx)*10**ecx is result of original divide
 add eax,esi; From an earlier cycle.
 cmp edx,ebpúje DivExact; Done if remainder zero.
 cmp eax,Z.DivBreakújae @F; Done if enough digits known.
; Treat as (10*(latest eax)*ebx+10*edx)*10**(ecx-1) to get more digits.
; The 2-operand imul alters just its first operand (and flags).
 dec ecxúimul eax,10úmov esi,eaxúmov eax,edxúmul Y.N10újmp DivLoop
@@:; When needed number of digits, round based on remainder.
 add edx,edxúcmp edx,ebxújb @Fúinc eaxú@@:
DivExact:
; An insignificant trailing zero is one that would come after the decimal point.
@@:mov esi,eaxúTestReg ecxújns @F
 mov edx,ebpúdiv Y.N10útest dx,dxújnz @Fúinc ecxújmp @B
; Put sign of result in.
@@:shr Z.SignM,1úadc ecx,ecx
 mov eax,esiúpop CursorSiújmp MagTest

ZeroDivide:mov ax,MkMajMin(42,3)újmp Raise

RemIntDiv:
; For % and // it is the integer part of the dividend that gets divided into.
; We have already set up so that divisor is integer.
; % and // must not make negative exponent.
; This case not speeded up for leading zeros.

if 0
 cmp ecx,ebpújge @F
endif
; We could divide by power of ten so that ecx became zero. Then put the residue
; aside to go with the final remainder. Do the divide into integer part.
; Or just bail out to ArithOp.   NYI
MayFloat:; For now
 pop CursorSi
 Up
 jmp ArithGeneral
if 0
@@:  ; NYI 26p11 test
endif

; Here with non-$pDivide, non-neg exponent of dividend (ecx), integer divisor.
IntDivLoop:div ebx
 add eax,esi; From an earlier cycle.
 jc MayFloatúcmp eax,Z.Ceilingújae MayFloat
 cmp ecx,ebpúje IntDiv; Done if last divide was of integer.
 dec ecxúimul eax,10úmov esi,eaxúmov eax,edxúmul Y.N10újmp IntDivLoop
; eax is the // result. edx is remainder.
IntDiv:cmp Z.OpIs,$pRemainderúje IntRem
; Put sign of result in.
@@:shr Z.SignM,1úadc ecx,ecx
 Move Vúpop CursorSiúBackRet

IntRem:mov eax,edxújmp @B

ZeroInt:cmp Z.OpIs,$pRemainderúje DivideNull
ArithZero:mov V.Mantissa,ebpúmov V.ExpAnd,ebp
DivideNull:pop CursorSiúBackRet

Power$$:call ToWholeEbxújnc ArithGeneral
 jmp Raise26p8

; Unary operators.
Negate$$:;  "-0" is not allowed to occur.
 call NumDxBxújc Raise41p3újnz NegGenúcmp ebx,ebpúje @Fúxor V.Sign,1ú@@:BackRet
; Use ArithGeneral of 0 - Subject
NegGen:UpúMove V,V0úmov V0.Mantissa,ebpúmov V0.ExpAnd,ebpújmp ArithGeneral

Positive$$:
 call NumDxBxújc Raise41p3újnz @FúBackRet
; Use ArithGeneral of Subject + 0
@@:Upúmov V.Mantissa,ebpúmov V.ExpAnd,ebpújmp ArithGeneral

Raise26p12:inc bp
Raise26p11:inc bpúinc bpúinc bp
Raise26p8:inc bp
Raise26p7:inc bp
Raise26p6:inc bp
Raise26p5:inc bp
Raise26p4:inc bp
Raise26p3:inc bp
Raise26p2:inc bp
Raise26p1:inc bp
 mov dl,26újmp Raise

Raise41p7:inc bp
Raise41p6:inc bp
Raise41p5:inc bp
Raise41p4:inc bp
Raise41p3:inc bp
Raise41p2:inc bp
Raise41p1:inc bp
 mov dl,41újmp Raise

Raise33p3:inc bp
Raise33p2:inc bp
Raise33p1:inc bp
 mov dl,33újmp Raise

Raise34p6:inc bp
Raise34p5:inc bp
; The two above were checked in a subroutine before saving CursorSi.
 PopJunk cx; Makes Raise push CursorSi in required place.
Raise34p4:inc bp
Raise34p3:inc bp
Raise34p2:inc bp
Raise34p1:inc bp
  mov dl,34újmp Raise

Raise40p11:mov al,11újmp Raise40
Raise40p32:mov al,32újmp Raise40
Raise40p33:mov al,33újmp Raise40
;------------------------------------------------------------------------------
; This the significant recovery point.
;------------------------------------------------------------------------------
comment~ Raising SYNTAX occurs all over the code, so it makes sense to transfer
as much of the work as possible to here, rather than the invoking site.

The caller need not unwind calls and pushes since stack is reset here.
Insert.Value is always stored, even though the message may not need it.
Insert.Desc is always stored, even though the message may not need it.

Error detection in the parser does not take much code - the syntax tables hold
the message numbers in 14 bits and one place in Cycle deals with them, see
IssueError.  Error detection for the parameters to a builtin is also handled at
one place, see BifTypes.  The remaining errors can be individually handled by
loading AX with the message number and branching to Raise.  The code is labelled
RaiseMMpNN usually, with MM.NN the message number.

However, some groups of messages (Majors 29 33 34 41 42 particularly) use a
"trick" with BP to shorten the code.

Inserts are established in various ways.  The non-line-number <value>s, the
<description>, and the error number (which may get further adjustment) arrive
at Raise in registers.
<argnumber> is run time.
<optionslist> is run time.
<sourceline()> is run time.

The <token> is set by compiling and only happens in compile messages.
<char> is compile only, given ASCII char set.
<position> is compile only.
<keywords> is compile only.
<hex-encoding> is usually compile time but we also use it for I/O error so
the value at Raise should be preserved over any Synch necessary.
<name> is both compile and run. Preserve it over Synch.
<bif> is done by compile, so needs a Synch if in runtime message.
<operator> is done by compile, so needs a Synch if in runtime message.

~
;------------------------------------------------------------------------------
; Raise stage 1, collect the message number and some insert info.
; It is assumed that we cannot be in the middle of synchronizing because if
; the source parsed OK originally it will do for Synch.
; Similarly we are not in a clause-by-clause compilation.
; We can be in the original compilation, INTERPRET compilation, or the
; execution of original, INTERPRET, clause-by-clause Pcode.
;------------------------------------------------------------------------------
Raise49:
if Debug
 int 3úpop ax; Caller.
endif
 mov ax,MkMajMin(49,0)újmp Raise

comment~ The syntax conditions raised from the Builtins that were Bcoded have
a variety of arguments.

40.4  ArgNum
40.17 Value
40.18
40.19 Value Value
40.29 Value
40.35 Value
40.38 ArgNum Value
40.39 Value
40.41 ArgNum Value
40.42 Value

~

CONFIG_RAISE40$$:
 mov si,Z.XCycleResetSpúmove Wptr[si+bp-4],Z.ResumeP
 call ResumeP$
 mov al,Bptr V.Mantissa; The minor code.
 Downúcmp al,4úje @Fúcmp al,38úje @Fúcmp al,41újne NoArgNum
@@:mov dl,Bptr V.Mantissaúmov Z.Insert.ArgNum,dlúDown
NoArgNum:cmp al,19újne @FúDownú@@:
; 40.18 won't care about inserts.

Raise40:mov ah,40
Raise:
; Non-zero bp is just a space-saving trick for passing value for al.
; (Requires dl for ah also.)
 TestReg bpújz @Fúxax bpúxor bp,bpúmov ah,dlú@@:
; Some registers will be relevant only for certain messages. Store anyway.
 mov Z.Insert.Desc,dlúmov Z.Insert.Value,StackDi
 push CursorSi; Only relevant to retrieve it if operator did not push it before.
 push CursorSi
if 0
 int 3
endif
; All the 41.xx have to become 41.7 if exponent range is the reason.
 cmp ah,41újne Not41
 Qry Z.Cancel,ExpRangeújz @Fúmov al,7ú@@:
; The message number is now in AX
Not41:z Z.Cancel; Cancel any flags that might be pending.

; The <linenumber> insert takes its value from Z.InsLine.
; A parser state has a field, ClauseWas, to hold relevant previous line
; numbers. Because we came here on a jump, sp will address the current state.
; The case of major code 14, (incomplete DO...) the number in the pre-message
; has to change. Set si for source of number, di where to put it.
 mov ParseSi,spúmov di,Zshape.ClauseLine
 cmp ah,14újne @Fúmov di,Zshape.InsLineújmp Is14ú@@:
; The case of major code 7, the relevant SELECT has to be found on the stack.
 cmp ah,7újne Not7úcmp al,1úje @F
Is14:add ParseSi,$StrideS
@@:move Wptr[di+bp],S.ClauseWas,dx
Not7:mov Z.Insert.MajMin,ax

;------------------------------------------------------------------------------
; Raise stage 2, note where the SYNTAX error occurred, and position the source
; to match if necessary.
;------------------------------------------------------------------------------
; There can be message before we really get started. eg couldn't find source
; of the very first file.
 cmp Z.Code,ZeroBpúje InSynch
; If we have never started executing this source file, the line number etc will
; be current.  SYNTAX trapping cannot have been turned on in this file.
 cmp Hg.Original,ZeroBpúje InSynch
; There has been some execution of this file, so can find the execution point
; relevant to the Raise.  Also there is a place for .MN
; Could not store .MN if Z.ProgScope not yet made.
; Put ax into .MN, still in Major+Minor format. (May not get used.)
 mov ProgEs,Z.ProgScopeúmov Ve.Dtype[$?MN],$MsgNumúmov Ve.MantLow[$?MN],ax
; At this point we are in execution, although could be parsing part of
; INTERPRET. So we will have called Operator and the Raise is from some
; operation.
; Mar 2000 method of recover CursorSi is to ensure it was first thing saved
; by execution of the operation.
; Link to the operator follows reset place, want below that.
 mov si,Z.XCycleResetSpúmov CursorSi,Wptr[si+bp-4]
; At this point CursorSi is correct, either for a message or as SIGL.
 mov Z.Synch,CursorSi;
; NYI - loop protection for msg 5 or 49.
; It may be that SYNTAX is being trapped and the message will never be shown
; but we make it anyway for CONDITION('D')
; If error was detected while compiling, the info for inserts will be available.
; So in the compile-of-INTERPRET-subject case we could record that before
; doing the synch required to get the line number of the INTERPRET clause.
; However, in the not-compiling case we have to synch on both the source file
; and the subject so might as well always do that.
;
; This re-compilation up to the Z.Synch point is very similar to the
; original compilation.
; The Synch won't necessarily happen with all the Zone fields the same as now.
; We copy some that might get harmed, don't copy ones Synch is to set.
; ?? InsBlock mechanism over-engineered?
; Execution messages don't use <token> so TokPos is in the copied block to
; retain it for the INTERPRET case.
 mov si,Zshape.Insertúmov di,Zshape.Insertsúcall CopyInsert
 add Z.Stack,2*$StrideV; Protect what may be needed for Z.Insert.Value.
 mov Z.Cursor,$StrideHúz Z.Scanp
; LabelsBad tells us whether it was INTERPRET that failed, although this
; Synch is against the original, not the INTERPRET subject.
 btr Z.Program,LabelsBadújnc NotINT
if Debug
 mov ds,Z.Consts
 mov ax,Hd.Avail
endif
 call Compiling
if Debug
 push ds
 mov ds,Z.Consts
 mov ax,Hd.Avail
 pop ds
endif
; We also have to restore the buffer, in the case where a message from
; INTERPRET uses Insert.TokPos.
 mov al,$SerialInterpretúcall Serialize
 jmp @F
NotINT:
if Debug
 mov ds,Z.Consts
 mov ax,Hd.Avail
endif
 call Compiling
if Debug
 push ds
 mov ds,Z.Consts
 mov ax,Hd.Avail
 pop ds
endif
@@:mov si,Zshape.Insertsúmov di,Zshape.Insertúcall CopyInsert
InSynch:
 z Z.Scanp
 Off Z.Program,LabelsBad
;------------------------------------------------------------------------------
; Raise stage 3, convert all the info to a text message.
; Save the message if not now finishing.
;------------------------------------------------------------------------------
; If the condition is handled, we go back to execution as if there had
; been SIGNAL rather than SYNTAX.
;
; Too risky to allow handling in some cases.
 mov ax,Z.Insert.MajMin
 cmp ah,5úje GetOutúcmp ah,49úje GetOut
; Assert Syntax is zero position amongst the conditions. Enabling < 8
 call HeritageDiúbtr L.Condition,Enablingújc OnSyntax
 pop di
; Exit with message and traceback.
GetOut:
 call MakeMsg; Result Z.MsgBegin to Z.MsgSoFar(and di).
 call ShowMsg
; TraceBack.        NYI
; Return code is error number. Only room for Major code.
 mov al,Z.Insert.Majorújmp Exit

CopyInsert:mov cx,sizeof InsBlock
 push esúmv ds,ssúmv es,ssúrep movsbúpop esúret

OnSyntax:
;$8.4.1
 PopJunk ax
; BX tells where to resume interpretation.
 mov L.ConditionExtra.Dtype,$NullString
 mov bx,L.TrapName
comment~ We will have to allocate space to make the message an ordinary value
now, because we don't want to leave it in a special place while doing a
compaction.  We could build the message in that space but that is not clearly
best - it would prevent DS being kept addressing the compressed text.
~
 mov cx,$MaxPreInsert+5*$Limit_Insertúcall AllocateCx_EsAx
 mov L.ConditionDescription.Dtype,$AwayStringúmov L.ConditionDescription.Sg,es
 mov L.ConditionDescription.Pt,axúmov L.ConditionDescription.Len,cx
 push LevelDi
 call MakeMsg; Result Z.MsgBegin to Z.MsgSoFar(and di).
 pop LevelDi
; Move the message to variable allocated earlier.
 mov cx,Z.MsgSoFarúmov si,Z.MsgBeginúsub cx,si
 mov L.ConditionDescription.Len,cx
 les di,L.ConditionDescription.Fr
 rep movsb [di],ss:[si]
 mov CursorSi,Z.Synch
 jmp OnSyntaxX
SignalV$$:
 Error49Bp

Signal$$:mov bx,gs:[CursorSi]
OnSyntaxX:
 Off Z.Cancel,TokIsValue
 mov sp,Z.XCycleResetSp
; bx is the label sought.
; CursorSi is where the jump was from.
comment~ In the case of SIGNAL we might reasonably finalize .SIGL at once
but CALL would be too slow if we did that. It seems we need lazy evaluation
in converting Pcode offset to line number for .SIGL
It is a bit pesky because if we do the conversion as the number is loaded to
the stack we either need an extra test in loading from ProgScope or we need
an extra operator just for the job. If conversion is left to operand check
time it is an extra test everytime there. Current plan is to test on load of
variables and with $pSysVar for loads from "constants".
Variables case , eg SIGL, can test on load.
~
 mov ProgEs,Z.ProgScope
 mov Ve.Dtype[$?SIGL],$Siglúmov Ve.MantLow[$?SIGL],CursorSi
; There are both .SIGL and SIGL.
 mov Vf.Dtype[$?SIGLx],$Siglúmov Vf.MantLow[$?SIGLx],CursorSi
; Lose DOs, INTERPRETs and temps.
 mov LevelDi,Z.Level
 mov Z.Stack,StackDi
 mov Z.CurrentDO,StackDi
; Test for trace-only or absent label.
 mov ax,MkMajMin(16,2)úcmp Bptr Vbxe.LabelType,0újne Raise16
 mov cx,Vbxe.LabelValue
 JcxzQ @Fúmov CursorSi,cxújmp StartExecutionYú@@:
; Label never appeared with colon.
 dec ax
Raise16: mov ds,Z.Consts
 mov bx,Vbx.Hereúmov Z.Insert.Named,bx
 jmp Raise

CallOn$$:mov dl,mask Instruction + mask Enablingújmp @F
SignalOn$$:mov dl,mask Enabling
@@:call HeritageDi
; The condition is in the next byte.
; Syntax,LostDigits,NoValue,NotReady,Error,Failure,Halt
 mov bl,Bptr gs:[CursorSi]úinc CursorSi
; Target label follows.
 lodsw gs:[CursorSi]úadd LevelDi,bx
 and Bptr(L.Condition),not(mask Enabling+mask Instruction)
 or Bptr(L.Condition),dlúadd LevelDi,bxúmov L.TrapName,axúpop StackDiúBackRet

SignalOff$$:
; MASM error ...............................
 movzx bx,Bptr gs:[CursorSi]úinc CursorSi
 push StackDiúmov LevelDi,Z.Levelúadd LevelDi,bx
 and Bptr L.Condition,not(mask Enabling)
 pop StackDiúBackRet

Raise$$:
; The errors from number of args (statically detected) on a bif will be 40.n
; Other under this code is SELECT out of choices. 7.3
; ?? What about line number on that?
; Also PROCEDURE misplaced. 17.1
 mov bl,Bptr gs:[CursorSi]úinc CursorSiúmov ax,Raise$[bx]újmp Raise
if Solid
Raise$:
 dw MkMajMin(7,3)
 dw MkMajMin(17,1)
 dw MkMajMin(40,3)
 dw MkMajMin(40,4)
 dw MkMajMin(40,5)
endif

comment~ There could have been a Pcode to say "Make control block for iterative
DO" but it is more efficient to let the first expression of the DO get loaded
before making the block.  It follows that the DO control block will overlay the
result of that expression.

~
Jump$$:mov CursorSi,Wptr gs:[CursorSi]úBackRet

Raise34:cmp Bptr(gs:[CursorSi-3]),$pThenújne Raise34p2újmp Raise34p1

When$$:úThen$$:call ToWholeEbxújc Raise34úlodsw gs:[CursorSi]
 dec ebxújz @Fúinc ebxújnz Raise34úmov CursorSi,axú@@:DownúBackRet

comment~ In execution the stem will begin like an ordinary variable and contain
the default value. This means taking
two slots in the names array for each stem.  In the second slot we keep
lookaside (probe) and a pointer to the compound variable set.

~
AssignConst$$:; This is assign without going via stack.
; Only 15% faster than Assign$$.  I wonder if the order affects pipelines.
; Might have been alignment affected.
 mov bx,gs:[CursorSi]úMove ,Vbxe
; Swop to Assign$$ when target exposed.
 mov bx,gs:[CursorSi+2]úadd CursorSi,4úcmp Vbxf.Dtype,$Exposedúje @F
 Move VbxfúBackRet

@@:UpúMove Vújmp AssignExposed

; Unstore follows Assign if the assigned value is to be reloaded.
Unstore$$:UpúBackRet

Assign$$:; The target will be the only argument.
; ControlVar$$ relies on BX, EAX, ECX at return.
; If the target is changing from uninitialized in this procedure to initialized,
; that has to be recorded so that it can be backed out when the procedure
; returns, making the array of variable names fit for reuse. NYI
 mov bx,gs:[CursorSi]úadd CursorSi,2; Add2 is slower.
AsgnToFsBx:cmp Vbxf.Dtype,$Exposedúje AssignExposed
 Move Vbxf,VúDownúret

AssignExposed:; A bit slower because of FS temporary shift.
 call ExposedFs
AssignRet:Move Vbxf,Vúmov fs,Z.VarScopeúDownúret

ExposedFs:; Sets FS to the non-exposed level for variable BX.
; Assert - Dtype is $Exposed in current FS:BX
; When setting something to $Exposed we should not follow the expose chain.
 Qry Z.Cancel,ForExposeújz @Fúret
; Scan for containing procedure.
@@:mov fs,Hf.UpPoolúcmp Vbxf.Dtype,$Exposedúje @Búret

comment~  There is a choice about implementing execution of DROP and EXPOSE;
whether to handle the dynamic cases like DROP (abc) as INTERPRET "DROP" abc.
The alternative is scan the abc and invoke some pieces of the compiler at a
primitive level. There has to be some prescan of abc even if INTERPRET is used,
eg to prevent comments being accepted.

There is a slight complication that INTERPRET "PROCEDURE EXPOSE" abc would fail
from not-following-label but that is fixable.

The decision extends to VALUE(abc,99) as INTERPRET abc'='99 and to the variable
pool interface.

Aug 99 plan is to avoid the INTERPRET route because of TRACE concerns.

At first glance it seems that for exposed compounds,
eg PROCEDURE EXPOSE ABC.1DEF it would be most efficient to restrict the
necessary lookups to just the time of the EXPOSE, subsequently retaining
in the local pool the results.  Then at reference time there would be a
direct link to the exposed item.  The trouble with this approach is that
the stem may also be exposed and assigned to, eg ABC.=99.  Such an
assignment would usually be done efficiently by throwing away the tree
of elements ABC. has and relying on the default value for a stem mechanism
to provide values on subsequent references.  But that throwing away is
flawed if what is thrown includes targets of expose references. While this
might be solved by using different mechansims for ABC.=99 according to
whether or not ABC. was in the local pool, it may be more reasonable to
do multiple lookups at reference.

~
DropList$$:push CursorSi
; We want to parse the value into symbols but using compiler would
; allow comments etc.
 call ToDsSiCxúmov bx,Attributes
 Upúcall VasDsSiCx; A copy to alter.
; Skip blanks
DropLoopX:JcxzQ DropListRet
DropLoop:lodsbúXlatBDLSújnz @FúLoopQ DropLoop
DropListRet:sub StackDi,2*$StrideVúpop CursorSiúBackRet

; Begin of potential symbol found. Check it is a name.
@@:dec siúmov dx,siúcall SymbolLookúTestReg bxújnz Raise20p1
 push cxúpush si
; Set up V to be just the symbol found.
 mov V.Pt,dxúsub si,dxúmov V.Len,si
; Drop by interpret.
 mov dx,offset B4DROPúcall LinkBcodeúmov Z.Stack,StackDi
 pop siúpop cxújmp DropLoopX
Raise20p1:; This msg can happen as runtime or compile time. The insert is
; <token>, which is fine for compile time. For runtime we need a flag to
; treat the insert differently.
  mov fs,Z.VarScope
  mov Z.Stack,StackDi
  pop CursorSiúOn Z.Cancel,TokIsValueúmov ax,MkMajMin(20,1)újmp Raise
Expose$$:lodsw gs:[CursorSi]úxax bx
; Tail parts on the stack if compound name.
 mov ax,StackDiúsub ax,Z.CurrentDOújnz @F
 mov Vbxf.Dtype,$ExposedúBackRet
@@:push CursorSiúOn Z.Cancel,ForExpose
 sub ax,$StrideVúcall DotsFsBxDsSiúDown
 Off Z.Cancel,ForExpose
 mov Vsid.Dtype,$Exposedúmov fs,Z.VarScopeúz bxúpop CursorSiúBackRet

ExposeList$$:; EXPOSE (A) first does EXPOSE A.
 call Expose$$
 push CursorSi
 TestReg bxújnz @FúError49Bpú@@:
 CodeModeR
 call FetchBx
 UnCodeMode
 call ToDsSiCxúmov bx,Attributes
 Upúcall VasDsSiCx; A copy to alter.
; Skip blanks
ExposeLoopX:JcxzQ ExposeListRet
ExposeLoop:lodsbúXlatBDLSújnz @FúLoopQ ExposeLoop
ExposeListRet:sub StackDi,2*$StrideVúpop CursorSiúBackRet
; Begin of potential symbol found.
@@:dec siúmov dx,siúcall SymbolLookúTestReg bxújnz Raise20p1
 push cxúpush si
; Set up V to be just the symbol found.
 mov V.Pt,dxúsub si,dxúmov V.Len,si
 mov dx,offset B4EXPOSEúcall LinkBcodeúmov Z.Stack,StackDi
 pop siúpop cxújmp ExposeLoopX
Dots$$:; Fetch from a compound. The compound is the only argument.
; The values for the tail parts are parameters.
 movzx ax,Bptr gs:[CursorSi]úinc CursorSi
; AX now 0 = One part tail, $StrideV = two part tail,...
 mov StemBx,gs:[CursorSi]úadd CursorSi,2úpush CursorSi
 call DotsFsBxDsSi; Sets FS:BX the lower of pair, DS:SI the item.
 cmp Vsid.Dtype,$Omittedúje DotsNew
PostDotsNew:test Vsid.Dtype,$Testújg TailedDropped
 Move V,Vsid
DotsReturn:mov fs,Z.VarScopeúpop CursorSiúBackRet

DotsNew:; New item gets it's value from the stem default.
; Assert - default known not to be exposed.
  Move Vsid,Vbxfújmp PostDotsNew

TailedDropped:
if Debug
 cmp Vsid.Dtype,$Droppedúje @FúError49Bpú@@:
endif
; Have to construct STEM.tail as value.
 call ValueIsName
; Recover the tail - it is the key of the compound.
 Up
 mov V.Sg,dsúmov ax,J.KeyLenúmov V.Len,ax
 lea ax,J.Keyúmov V.Pt,ax
 call Away
 call Abut$$
 jmp DotsReturn

Away:; Mark stack as an away string if not optimizable.
 push cxúmov cx,V.Lenúcmp cx,7újna @Fúmov V.Dtype,$AwayStringúpop cxúret
@@:push dsúpush siúlds si,V.FrúMv V,Vsid
 add cl,$NullStringúmov V.Dtype,cl
 pop siúpop dsúpop cxúret

AssignStem$$:; eg ABC.=99
; If the whole stem is exposed we must change pool until it isn't.
 mov bx,gs:[CursorSi]úadd CursorSi,2
 cmp Vbxf.Dtype,$Exposedújne @Fúcall ExposedFsú@@:
; Look at the stem to see if anything (ABC.XXX as opposed to ABC.) is exposed.
; The stem may never have been used.
 cmp Vbxf2.Dtype,$Droppedúje AssignRet; to just set default value.
 push CursorSi
 mov ds,Vbxf2.Sgúmov TailSi,$StrideH
 cmp Vsid.Dtype,$Exposed
 je SomeExposed
; Empty the stem segment.
 mov Hd.Avail,$StrideHúz Hd.Probe
 pop CursorSi
 jmp AssignRet; To set ABC.

comment~ Bit of design choice here. We have to assign the stack value to
each of the exposed compounds. For the non-exposed compounds already in
the stem's segment the efficient thing is to discard them.  The easier
thing is to assign the stack value to them also. (Avoids need to rebuild
lookup tree of the retained items.)
~
SomeExposed:; DS:SI item to be given Stack value.
AssignLoop:; Simple when it is not exposed.
 cmp Vsid.Dtype,$Exposedúje AssignUp
AssignUpRet:Move Vsid,V
 add TailSi,J.KeyLenúadd TailSi,$StrideJ
 cmp TailSi,Hd.Availújb AssignLoop
 pop CursorSiújmp AssignRet
AssignUp:mov Z.StackLo,StackDi; So that DotsRet can be used.
 push AssignUpRetújmp DotsExposed
Drop$$:; Done as assignment of the value $Dropped
 cmp StackDi,Z.CurrentDO
 UpCareúmov V.Dtype,$Droppedújz Assign$$
; Compound assignment.
; Components of the tail are on the stack.
AssignDots$$:lodsw gs:[CursorSi]úmov StemBx,axúpush CursorSi
; Improve performance - set StackLo NYI
 mov ax,StackDiúsub ax,Z.CurrentDOúsub ax,2*$StrideV; At least value & a tail
 call DotsFsBxDsSi
 Down; DotsFsBxDsSi allowed for value pickup by Dots$$.
 Move Vsid,VúDownúmov fs,Z.VarScopeúpop CursorSiúBackRet

comment~ INTERPRET works by compiling Pcode on to the end of the Pcode segment,
running it with XCycle, then moving the pointer back to discard it.
Three uses are distinct:
- Initially compiling the $Reserved string to set up system variables and
  constants.
- An INTERPRET in the programmer's program. (Which can be recursive)
- An INTERPRET in Bcode, eg implementing VALUE('ABC',99).

In the case of the programmer's INTERPRET, we need a flags to disable labels.

There are three steps to an interpret: A compile step that makes new Pcode, an
execution step that runs that Pcode, and recovery step that throws away the
temporary Pcode. The compile step can transfer to Raise when there is a
SYNTAX error and the other steps are not needed. A successful compile step
makes a $pInterpEnd at the end of the Pcode and execution of that causes the
recovery step. A SIGNAL during INTERPRET will have recovery as a by-product.
Looks like RETURN is a special problem - we need recovery when interpret is
finished that way. NYI

Everything pending about an INTERPRET in the execution step is held in a block
on the stack like a DO block.  That ensures recursion, external call, etc are
OK.

Execution resumes by the ret here, at D.PcodePos the newly
compiled Pcode. When execution reaches the InterpEnd the temporary Pcode is
discarded and execution resumes after the INTERPRET (CursorSi = D.Leaving)

~

Interpret$$:
 On Z.Program,LabelsBad; Tell Parser whats up.
Interpret1:
 push CursorSi
 cmp Z.ResumeP,ZeroBpúje @F
 On Z.Cancel,BcodeInterpret; Off at InterpEnd
 mov gs,Z.Code
@@:
; INTERPRET can nest so we need a block on the stack to hold each generation.
; It is very like a DO block, in that it goes away when there is a SIGNAL.
; And provides base for counting tails on assign.
; Build DO-like block over where the parameter was.
; Normally DO blocks are adjacent because DO inside DO occurs with nothing
; on the stack. BcodeInterpret is different - new Bcoded routine without
; new Z.Level - so complicates Z.CurrentDO maintenance.
 add StackDi,$StrideD-$StrideVúmov ax,Z.CurrentDO
 mov Z.Stack,StackDiúcall StackSafeúmov D.UpDO,ax
 mov Z.CurrentDO,StackDi
 On D.Rec,IsInterp
 pop CursorSiúpush CursorSiúmov D.Leaving,CursorSi
; CursorSi not needed but left stacked for error messages.
 move D.PcodePos,Hg.Avail; Where code will start.
 mov Z.Cursor,ax
 mov al,$SerialInterpretúcall Serialize
 z Z.Synch
 call Compiling
 pop si
 mov al,$SerialNoneúcall Serialize
 cmp Hg.Original,ZeroBpújnz @F
; No execution when $Reserved.
 sub StackDi,$StrideD-$StrideVúmov Z.CurrentDO,StackDiúmov Z.Stack,StackDi
 ret
; If it failed to parse, that is handled at label Raise.
@@:mov CursorSi,D.PcodePos; Resume by executing the new code.
 jmp StartExecutionY
;MASM..............................
InterpEnd$$:; Code made from an INTERPRET statement has completed.
 move Hg.Avail,D.PcodePos; Reclaim code space.
 btr Z.Cancel,BcodeInterpretújnc Leave$$
; Like Leave$$ but the INTERPRET was in Bcode.
 mov CursorSi,D.Leaving
 move Z.CurrentDO,D.UpDO
 sub StackDi,$StrideD
 mov Z.Stack,StackDi
 mv gs,csúPopJunk axúret


;------------------------------------------------------------------------------
; The remaining verbs.
;------------------------------------------------------------------------------
Options$$:
; None yet.
 DownúBackRet

Push$$:
Queue$$:push CursorSi
; Length of aggregate is first word of Z.Serial.
; Items have their length at both ends of the item.
 mov al,$SerialQueúcall Serialize
; Establish value to be pushed.
 call ToDsSiCxúpush StackDi
; Check room.
 mov ax,Wptr Z.Serial; Previous aggregate length.
 mov dl,$DescQueue
 add ax,cxúcmp ax,sizeof Zshape.Serial-6úja Raise5p1
 mv es,ss
 mov ax,cxúadd ax,4; For two lengths
; If Queue, existing aggregate will have to move right.
 cmp bl,$pQueueújne @F
 push siúpush cx
 mov si,Wptr Z.Serialúmov cx,siúlea si,Zshape.Serial[si+1]; Rightmost byte
 mov di,siúadd di,axústdúrep movsb [di],ss:[si]úcldúpop cxúpop si
@@:mov dx,Wptr Z.Serial; Previous aggregate length.
 add Wptr Z.Serial,ax; New aggregate length.
; Copy argument to Serial.
 mov di,offset Zshape.Serial+2
 cmp bl,$pQueueúje @Fúadd di,dxú@@:
 stosw; Place first copy of length.
 rep movsbústosw; data then second.
 pop CursorDiúDown
 mov ProgEs,Z.ProgScope
 pop CursorSiúBackRet

; Some simple verbs.
Say$$:
 push CursorSiúcall ToDsSiCxúmov dx,siúmov bx,Z.Stdout
 mov ah,$DosWriteúint 21h; Takes ds:dx:cx to file bx
 mv ds,csúmov dx,Yshape.CrLfúmov cx,2
 mov ah,$DosWriteúint 21h
; Say in Bcode just for debug.
 cmp Z.ResumeP,ZeroBpújne @F
 Down
@@:pop CursorSiúBackRet

comment~ The most liberal character form for numbers is given in section $7 of
the standard.  The normalized character form, as produced for arithmetic
outputs, removes leading zeros etc.  and is dependent on the NUMERIC settings.

For DIGITS less than 10, and particularly the default of 9, a binary 8 bytes is
sufficient to encode all the possible values. Even when DIGITS is more than 9,
some possible values will fit in the binary range.

Conversion is required between the liberal format and the binary format or
(if the binary won't hold it) the normalized character form.  Conversion in
the other direction produces the normalized character form or it's
generalization by the FORMAT bif.

Even in binary form, numbers are not uniquely represented, for example an
exponent of 0h and mantissa of 0Ah is the same value as exponent of 1h and
mantissa of 1h.  The binary form always has zero as all binary zeros, and
sometimes it is forced to exponent=0 for the "whole number" format.  (Note that
0Ah with exponent -1 is not the same as 1h with zero exponent since one converts
to "1.0" and the other to "1".)

~
;------------------------------------------------------------------------------
; Conversion to Number.
;------------------------------------------------------------------------------
; NumDxBx makes the stack variable a number, setting carry iff it
; cannot do that at 9 digits. ebx:edx left as copy of number stacked.
; si and di are preserved.  ax and cx are not.
; Entered at label NumDxBx.

; Mantissa ended on non-blank. Check it is dot or E or e.
; For this pass, dot is like a digit.
FnMantx:jpe FnCharútest al,$Eeújnz FnMantz
; Pity attributes of Dot not different from some other letters.
 inc diúcmp Bptr[si-1],'.'úje FnPostDot
; FnChar is place where syntax has proved to be non-number.
FnChar:pop ecxúpop eaxúpop StackDiútest V.Dtype,$TestústcúRetSi

; Blank or 'E' ends mantissa. Set to rescan it.
FnMantz:dec siújmp FnMant

FnPostSign:cmp ah,'.'úje FnNoSign
FnChSt:jmp FnChar

FnExpd:dec siúmov Z.ExpPosZi,siújmp FnB

; Build up the exponent.
FnExp:inc siúdec cxújz FnChStúlodsbúxlat cs:Bptr[bx]
 mov Z.SignE,alúand al,$Groupúcmp al,$PlusMinusújne @F
 dec cx
 JcxzQ FnChSt
 inc si
@@:dec siúmov Z.ExpPos,si
; Scan exponent digits.
@@:lodsbúXlatBDLSújz FnExpdújs FnChStúLoopQ @B
 mov Z.ExpPosZi,siújmp FnDone

Qret:mov ebx,V.Mantissa
Qretx:mov edx,V.ExpAndúret; Test has cleared flags.

; In this version (Aug 99) we are not using the $AwayNum type, using char
; types instead.
; On return the flags register reflects the Dtype of the result, with also
; Carry set if not number syntax. (ie Carry implies compare non-numeric.)

NumDxBx:
 test V.Dtype,$Testújz Qret
; May 2000 Still not done AwayNum so will have to check numberness each use.
WasChar:Off Z.Cancel,ExpRange
 push CursorSiúpush StackDiúpush eaxúpush ecx
 call ToDsSiCx
 JcxzQ FnChSt; Empty string is not a number.
 mov bx,Attributes; For XLAT
; There just are not enough registers to make it sensible to do everything in
; one pass.  Better to have a first pass that finds the digits.
; si is for lods, cx counts unconsumed characters.
; When jumping out of loops si/cx are out of step. dec si rescans, dec cx keeps.
; First pass details are recorded in Z. fields, and in di for decimal point.
 z Z.ExpPosZi
; Skip leading blanks. String all blanks is not a number.
@@:lodsbúXlatBDLSújnz @FúLoopQ @Bújmp FnChStú@@:
; Note sign. Future test will be against $AttribMinus
 mov Z.SignM,alúand al,$Groupúcmp al,$PlusMinusújne FnNoSignúdec cx
 JcxzQ FnChSt
; Skip blanks after sign.
@@:lodsbúmov ah,alúXlatBDLSújnz @FúLoopQ @B
FnChSt2:jmp FnChStú@@:js FnPostSign
FnNoSign:dec si; Here with a digit upcoming, usually.
 mov Z.MantPos,siúz di; To count decimal points.
@@:lodsbúXlatBDLSújz FnMantzújs FnMantx
FnPostDot:LoopQ @B
; Fall thru when digits go to the end.
FnMant:; Back to here from FnMantx when 'E' upcoming, or blank.
; At most one decimal point.
 cmp di,1úja FnChSt2úmov Z.MantPosZi,si
; Mantissa better have some digits in it.  .E+99 is wrong.
 sub si,diúcmp si,Z.MantPosúje FnChSt2úmov si,Z.MantPosZi
; Similarly for exponent.
 JcxzQ FnDoneútest al,$Eeújnz FnExp
; Trailing blanks OK
FnB:lodsbúXlatBDLSújnz FnChSt2úLoopQ FnB
FnDone:
; Here are two checks whether the number will go in our binary format.
; Mantissa to ebx, exponent to edx.
 mov edx,ebpúmov cx,Z.ExpPosZiúJcxzQ FnNoExpúmov si,Z.ExpPosúsub cx,si
 mov eax,ebp
@@:lodsbúsub al,'0'
 imul edx,10újs FnBigExpúadd edx,eax
 cmp edx,Y.N1e9újae FnBigExpúLoopQ @B
 cmp Z.SignE,$AttribMinusújne @Fúneg edxú@@:
FnNoExp:
; That has got the exponent, as written, into edx, and validated.
; We shall return saying this has number syntax.
; If the syntax was non-number we would have returned (with Carry) and
; not reached here. So anything awkward from here on we can say "long number",
; (even if it doesn't need a lot of digits) and it will be dealt with by
; ArithGeneral rather than the code for binary values.
; Now for mantissa to ebx.
 z ediúmov si,Z.MantPosúmov cx,Z.MantPosZiúsub cx,si
 mov ebx,ebpúmov eax,ebp
FnMloop:lodsbúcmp al,'.'újne @Fúinc ediújmp FnSkipú@@:
; Large mantissa best done by ArithGeneral.
 sub al,'0'úimul ebx,10újc FnLongúadd ebx,eaxújc FnLongúsub edx,edi
 cmp ebx,Z.Ceilingújnb FnLong
if 0
; If this is compile time we can pass the problem to run time by leaving
; the string in chars.
 cmp Z.Scanp,ZeroBpújnz FnLong
; There is unresolved language here.  For now:
 cmp cx,1úje FnSkip
 call HeritageDiúcmp L.Digits,9úpop StackDiúja FnLong
 cmp Bptr[si],'.'újne @Fúinc ediúinc siúdec cxú@@:JcxzQ FnSkip
; Rounding
 cmp Bptr[si],'4'újbe PostRoundúinc ebx
 cmp ebx,Y.N1e9újne PostRoundúinc edxúmov ebx,Y.N1e8
PostRound:
; We don't have the value yet since maybe more digits before dot.
FnLost:lodsbúcmp al,'.'újne @Fúinc ediúinc siú@@:inc edxúcmp al,'0'úje @F
; Raise LostDigits?
 call HeritageDiúcmp L.LostDigits,0úpop StackDiújz @F
 Error49Bp
@@:sub edx,ediúLoopQ FnLost
 inc cx
endif
FnSkip:LoopQ FnMloop
 cmp ebx,ebpújne @Fúmov edx,ebpú@@:
; !! check edx
; Exponent is held doubled, with sign of Mantissa added.
 add edx,edxúcmp Z.SignM,$AttribMinusújne @Fúinc edxú@@:
 cmp ebx,ebpújne @Fúmov edx,ebpú@@:
; The variable on the stack is altered when binary can fit.
 pop ecxúpop eaxúpop StackDi
 mov V.Mantissa,ebxúmov V.ExpAnd,edx
 test V.Dtype,$TestúRetSi
FnLong:
 pop ecxúpop eaxúpop StackDi
; Got to add zero anyway.
 mov StackSi,StackDiúpush StackDiúpush Z.Stackúmov StackDi,Z.Stack
 UpúMove V,Vsi,ebxúcall Zero$$úDown
 mov dl,$pAddúcall ArithDl
 mov StackSi,StackDiúpop Z.Stackúpop StackDi
 Move V,Vsi,ebx
 mov ebx,V.Mantissaúmov edx,V.ExpAnd
 test V.Dtype,$TestúRetSi

; If it looks like a number, has exponent in range, but mantissa won't fit
; nine digits, then it is a long number.
; But long binary numbers not implemented yet.
if 0
FnLong:pop ecxúpop eaxúpop StackDiúmov V.Dtype,$AwayNumberúRetSi
endif

FnBigExp:On Z.Cancel,ExpRangeújmp FnChSt

ToWholeEbx:; Result to ebx and V.Mantissa. eax ecx edx used.
; Used from arithmetic and DataType to convert to number. (Or set Carry)
 call NumDxBxújc TwFail
 jz TwBinary
; Number in char form. Try to bring it to binary.
; Got to add zero anyway.   cf FnLong
 push si
 mov StackSi,StackDiúpush StackDiúmov StackDi,Z.Stack
 UpúMove V,Vsi,ebxúcall NumDxBx
 mov StackSi,StackDiúpop StackDi
 Move V,Vsi
 pop si
 Test V.Dtype,$Testújnz TwFailx; Unsound for 'W' test. NYI
TwBinary: mov ecx,V.ExpAndúsar ecx,1újz TwOKúmov eax,V.Mantissaújs TwNegExp
if Debug
 cmp eax,ebpújne @Fúint 3újmp TwOKú@@:
endif
; Make the positive exponent zero by multiplying.
@@:mul Y.N10újc TwFailúcmp eax,Z.Ceilingújae TwFailxúdec ecxújnz @B
TwOKzero:and V.ExpAnd,1úmov V.Mantissa,eax
TwOK:mov ebx,V.Mantissaúclcúret
; We might be able to avoid a negative exponent by dividing Mantissa by 10.
TwNegExp:mov edx,ebpúdiv Y.N10úcmp dl,0újnz TwFailx
 inc ecxújnz TwNegExpújmp TwOKzero
TwFailx:stc
TwFail:ret
;------------------------------------------------------------------------------
; ToDsSiCx sets registers to reflect the top stack item.
;------------------------------------------------------------------------------
; ToDsSiCx makes the stack variable a string and sets ds:si:cx to reflect it.
; eax,ebx,edx,edi preserved.
; high of ecx not preserved.  es not preserved.
ToDsSiCx:mov cl,V.Dtypeútest cl,$Testújz ToStringújpe @F
; Here when it already is short string.
; mov ds,Z.Zone is faster than mv ds,ss
 and cx,7úAssert Vshape.String eq 0úmov ds,Z.Zoneúmov si,StackDiúret
@@:

if Debug
cmp cl,$AwayStringújne @F
endif

; Here for already a long string.
 lds si,V.Frúmov cx,V.Lenúret

if Debug
@@:Error49Bp
endif

ToString:; Converting to character string.
; We don't know what the numerics settings were when the arith value was made
; so we have to have arranged that it is OK to assume SCIENTIFIC 9 digits.
 push eaxúpush ebxúpush edxúmov ecx,ebp
; Special case single digits. That will include Booleans.
; This case requires exponent zero. The "sar" removes mantissa sign.
AfterRound:
 mov eax,V.Mantissaúmov ebx,V.ExpAndúsar ebx,1újnz TsMore
 cmp eax,Y.N10újae TsMore
; Here with integer less than ten.
; Positives are one character answers. Result length to be in cx.
 mov V.Dtype,$NullStringúinc cx
 test V.Sign,1újnz @F
 add al,'0'úmov V.String,al
TsFrom:add V.Dtype,cl
 pop edxúpop ebxúpop eax
 mov ds,Z.Zoneúmov si,StackDiúret
; Negative one digit is two character answer.
@@:inc cxúmov bx,StringOrder('-','0')úadd bh,al
 mov Wptr(V.String),bxújmp TsFrom

; Here if non-integer or more than one digit.
; ebx is exponent value. eax is mantissa.
TsMore:; ecx to count how many decimal digits it takes to hold the mantissa.
 mov si,Yshape.N10-4; ecx already zero
@@:add si,4úinc cxúcmp eax,Dptr cs:[si]újae @B
; Will floating point representation be needed?
; It will if digits for the mantissa plus right zeros implied by exponent
; makes too many digits.  Alternatively, it will if value less than a millionth.
; For this decision we assume the number was made when digits=9.
; (Although maybe get away with other cases?)
 mov edx,ebxúadd edx,ecxúcmp edx,Y.N10újge TsFloat
 cmp edx,-5újl TsFloat
; dx between -5 and 9. Position of point relative to left of mantissa.
; cx digits from mantissa.
; if bx>=0 there will not be a decimal point. Length will be dx (+1 if "-")
; if bx<0 length will be one for point plus max(cx,-bx+1)
 test bx,bxújge TsNoP
; Now set dx to string length.
 mov dx,bxúneg dxúinc dxúcmp dx,cxújge @Fúmov dx,cxú@@:mov cx,dxúinc dx
TsNoP:test V.Sign,1újz @Fúinc dxú@@:
; Now cx digits, dx total. (Maybe bx right '0' pad)
 xchg cx,dxúpush eaxúcall ResultSpaceDsúxchg cx,dx
 mov si,axúpop eax
; Here with V. set up and ds:si addressing target space.
 mov Bptr[si],'-'; May get overlaid.
 push siúpush dxúadd si,dx
; Fill from the right, first with bx zeros
@@:test bx,bxújle @Fúdec siúmov Bptr[si],'0'údec bxújmp @Bú@@:
FromFloat:
; Here bx is either 0 to mean no point or negative of position from right.
; There are cx digits to go, point along the way, maybe.
; si right of place for right digit.
 cmp cx,ZeroBpújg @FúError49Bpú@@:
TsLoop:dec siúmov edx,ebpúdiv Y.N10úadd dl,'0'úmov [si],dl
 inc bxújnz @Fúdec siúmov Bptr[si],'.'ú@@:LoopQ TsLoop
; These are results for caller.
 pop cxúpop si
; These were caller's values.
 pop edxúpop ebxúpop eax
; Note ES was preserved.
 ret

TsFloat:
; ecx is digits of mantissa.
; ebx is signed exponent alone.
 mov Z.MantSize,cx
; Adjust exponent to desired point position.
 add ebx,ecxúdec ebx
 push eax
; Separate sign of exponent. (It cannot have become zero.) ax=0 positive.
 z axúcmp ebx,ebpújns @Fúneg ebxúinc axú@@:úmov Z.ExpSign,ax
; Deduce digit places for exponent, into dx.
 mov si,Yshape.N10-4úz dx
@@:add si,4úinc dxúcmp ebx,Dptr cs:[si]újb @F
 cmp si,Yshape.N1e9újne @B
@@:
; Setup result place.
; cx mantissa digits, dx exponent digits, three for punctuation, maybe
; another sign.
; Except that decimal point won't happen if it would be just before 'E'.
 LoopQ @Fúdec cxú@@:úinc cx; 1=>0  rest unaltered.
 add cx,dxúadd cx,3útest V.Sign,1újz @Fúinc cxú@@:
 call ResultSpaceDsúmov si,axúpop eax
 mov Bptr[si],'-'; May get overlaid.
 push siúpush cx; For result to caller.
; Fill in exponent.
 add si,cxúmov cx,dxúxchg eax,ebx
FpLoop:dec siúmov edx,ebpúdiv Y.N10úadd dl,'0'úmov [si],dl
 LoopQ FpLoop
 mov dh,'+'úcmp Z.ExpSign,ZeroBpúje @Fúmov dh,'-'ú@@:
 mov dl,'E'údec siúdec siúmov [si],dx
; Back to fill in mantissa.
 mov cx,Z.MantSize
 xax ebxúmov bx,cxúneg bxúinc bx
 jmp FromFloat
; Check exponent range !!

;------------------------------------------------------------------------------
; Some little routines.
;------------------------------------------------------------------------------
; The value is the name of item bx. Load it.
ValueIsName:push siúpush dsúpush ax; cx set to length.
 mov ds,Z.Varsúmov si,Vbx.Hereúmov ds,Z.Symbols
; ds:si now addresses "counted string" form of name.
 movzx cx,Bptr[si]úinc siúcmp cl,7úja VINlong
 add cl,$NullStringúMove V,Vsid,eaxúmov V.Dtype,clújmp @F
VINlong:call VasDsSiCx
@@:pop axúpop dsúRetSi

BxConst:
; We can deduce the value from bx but it would have been better to do this
; at an earlier stage.
 mov ds,Z.Constsúmov si,Vbx.Hereúmov ds,Z.Symbols
; ds:si now addresses "counted string" form of name.
 movzx cx,Bptr[si]úinc siúcmp cl,7úja Extlong
 add cl,$NullStringúMove V,Vsid,eaxúmov V.Dtype,clújmp @F
Extlong:call VasDsSiCx
@@:ret

ResultSpace:; Sets V up as result to address CX bytes. Return also es:ax
 cmp cx,7úja @F
; Setup for short string.
 mov V.Dtype,$NullStringúadd V.Dtype,clúmv es,ssúlea ax,V.Stringúret
@@:call AllocateCx_EsAx
AwayEsAxCx:; This entry point also used just to set up V.
 mov V.Dtype,$AwayStringúmov V.Sg,esúmov V.Pt,ax
 mov V.Len,cx
 ret

HeritageDi:; Copies as necessary to inherit from caller.
; Worth the fiddle to avoid caller push.
 pop bpúpush StackDiúpush bpúxor bp,bp
 mov LevelDi,Z.Level
; MASM error ..............................
HeritRecurse:bts L.Access,InheritDoneújc HeritageRet
 push LevelDiúmov LevelDi,L.UpLevelúcall HeritRecurseúpop LevelDi
; Copy from higher level, known to be already filled.
 push LevelDiúpush siúmov LevelSi,L.UpLevelúlea si,Lsi.Digits
 Assert (Lshape.Inherit-Lshape.Digits) mod 4 eq 0
 push cxúmov cx,(Lshape.Inherit-Lshape.Digits)/4úlea di,L.Digits
 push esúmov es,Z.Zoneúrep movsd [di],es:[si]úpop esúpop cxúpop siúpop LevelDi
HeritageRet:ret

comment~ ToDsSiCx is used all over the place so it is worth an effort to
avoid it altering Es.  We need to do the AllocateEsAx in ResultSpace
though, when a numeric input converts to a long string.
~
ResultSpaceDs:mov Z.EsNew,esúcall ResultSpaceúmv ds,esúmov es,Z.EsNew
; Most times this is simple save/restore of ES but it will also work if
; ES is addressing a segment that compaction moved.
 ret

Version db "REXX 5.00 22 April 99"
Configuration db "DosCrx1.0 "
COMMAND db "COMMAND "; HowInvoked
FUNCTION db "FUNCTION "; HowInvoked
SUBROUTINE db "SUBROUTINE "; HowInvoked
 end
