; Copyright Formcroft Ltd 1997
 .model smallú.486ú.code
MyGroup GROUP _TEXT, BifSeg, FanSegB
; These are the routines the Bcode interpreter calls upon, other than the ones
; shared with the Pcode interpreter.
; Only used in this module so using a segment is convenience rather than
; necessity.
FanSegB SEGMENT WORD PUBLIC 'CODE'
BcodesBase$:
 dw Zero$$
 dw One$$
 dw Null$$
 dw String$$
 dw String1$$
 dw String2$$
 dw _RetBc$$
 dw _RetB$$
 dw _RetF$$
 dw _IterCV$$
 dw _Exists$$
 dw _Then$$
 dw _Jump$$
 dw _Eq$$
 dw _Ne$$
 dw _Lt$$
 dw _Le$$
 dw _Ge$$
 dw _Gt$$
 dw _Seq$$
 dw _Sne$$
 dw _Slt$$
; See CRX.RX, the code from ANSI that is processed into Bcode. These are
; the machine code routines that code uses but does not contain.
 dw CONFIG_RAISE$$
 dw CONFIG_RAISE40$$
 dw CONFIG_UPPER$$
 dw CONFIG_MSG$$
 dw CONFIG_C2B$$
 dw CONFIG_B2C$$
 dw CONFIG_STREAM_POSITION$$
 dw CONFIG_STREAM_CHARIN$$
 dw CONFIG_STREAM_QUERY$$
 dw CONFIG_STREAM_CLOSE$$
 dw CONFIG_STREAM_CHAROUT$$
 dw CONFIG_STREAM_COUNT$$
 dw CONFIG_STREAM_QUALIFIED$$
 dw CONFIG_STREAM_COMMAND$$
 dw CONFIG_STREAM_STATE$$
 dw CONFIG_TIME$$
 dw CONFIG_ARITH$$
FanSegB ENDS
; The Bcode comparisons are the same as the Pcode ones except for having
; relative jumping so they are put with Pcode implementation.
 EXTERN _Eq$$:near, _Ne$$:near, _Lt$$:near, _Le$$:near, _Ge$$:near, _Gt$$:near
 EXTERN _Seq$$:near, _Sne$$:near, _Slt$$:near
 EXTERN BifCHARIN:near, BifCHAROUT:near, BifSTREAM:near
BifSeg SEGMENT WORD PUBLIC 'CODE'
Bswitch:
; Ordering of Bifs is exploited. Early ones required NOP at end-clause.
 dw BifDATE
 dw BifTIME
 dw BifLINES
 dw BifCHARS
 dw BifCHARIN
 dw BifCHAROUT
 dw BifLINEIN
 dw BifLINEOUT
 dw BifSTREAM
 dw BifSTRIP
 dw BifVERIFY
 dw BifQUALIFY
 dw BifWORDS
 dw BifTRUNC
 dw BifERRORTEXT
 dw BifSPACE
 dw BifTRANSLATE
 dw BifFORMAT ; Have to special case 1,4
 dw BifWORDLENGTH
 dw BifWORDPOS
 dw BifABBREV
 dw BifCENTER
 dw BifCENTRE
 dw BifCOMPARE
 dw BifDELSTR
 dw BifDELWORD
 dw BifRIGHT
 dw BifLASTPOS
 dw BifINSERT
 dw BifOVERLAY
 BifSeg ENDS
 PUBLIC BifCHANGESTR; Grouped with BifQUEUED hence not in this module's BifSeg.
 PUBLIC BifCOUNTSTR
 PUBLIC BifMAX; Needs high BifNum hence not in this module's BifSeg.
 PUBLIC BifMIN
 PUBLIC BifX2B; !! could avoid this
 PUBLIC BifD2X; !! could avoid this
 PUBLIC BifC2X; !! could avoid this
 PUBLIC BifB2X; !! could avoid this
 PUBLIC BifX2C; !! could avoid this
 PUBLIC BifX2D; !! could avoid this
 PUBLIC BifC2D; !! could avoid this
 PUBLIC BifD2C; !! could avoid this
 PUBLIC BifBITAND; !! could avoid this
 PUBLIC BifBITOR; !! could avoid this
 PUBLIC BifBITXOR; !! could avoid this
 PUBLIC B4VALUE1
 PUBLIC B4VALUE2
 PUBLIC B4DROP
 PUBLIC B4EXPOSE
 PUBLIC PATHQUALIFY
 PUBLIC LINESPLIT
 PUBLIC COMMANDWRAP

 PUBLIC Bswitch; Start of list of Bifs. In module's BifSeg but not used here.
 PUBLIC ARITHOP$$; Bcode routine for arithmetic.
 PUBLIC Bassign; Call here to do assignment to Bcode variable (on the stack).
 PUBLIC One$$,String1$$; So Parse$$ can load things.
 PUBLIC CloseBx; So Exit$$ can close things.
 EXTERN TargetMsg:near
; Iteration in Bcode is in this module but uses parts of the Pcode
; implementation
 EXTERN AddRegs:near
 EXTERN CompareTO:near
 EXTERN Raise49:near
 include always.inc; Assembler shorthands like 'Bptr' for 'byte ptr'.
 include declares.inc; Symbolic constants, macros, records, structures.
;------------------------------------------------------------------------------
; (Bcode is in the first module so that Bcode offsets on bcode.lst have the
; same values as those occurring in registers during execution)
;------------------------------------------------------------------------------
if Solid
; Because of link order, this jump is at cs:0
R:jmp Raise49
 nop
; By putting constants in the first 128 bytes we can save a byte when
; addressing them.
 org 0
 Yshape <>
;------------------------------------------------------------------------------
; The builtins done this way just need the code from ANSI and argument specs.
;------------------------------------------------------------------------------
; Firstness of MAX/MIN is used, see BcodeEntry.
;$9.4.4úParmsRec <3,3,0111b>
BifMIN:
 include bf\min.inc

;$9.4.3ú; All $NumúParmsRec <3,3,0111b>
BifMAX:; Note MAX MIN have their own Pcodes.
 include bf\max.inc

;$9.3.1údb $WholeGEúParmsRec <2,1,1101b>
BifABBREV:
 include bf\abbrev.inc

;$9.3.2údb $Padúdb $WholeGEúParmsRec <2,1,1001b>
BifCENTER:
;$9.3.3
;ParmsRec <2,1,1001b> This one for benefit of utility seeking CENTRE info.
BifCENTRE:
 include bf\center.inc

;$9.3.4úParmsRec <3,0,1111b>
BifCHANGESTR:
 include bf\changest.inc

;$9.3.5údb $PadúParmsRec <2,1,1101b>
BifCOMPARE:
 include bf\compare.inc

;$9.3.7úParmsRec <2,0,1111b>
BifCOUNTSTR:
 include bf\countstr.inc

;$9.8.1údb "BDENOSU"údb -@SizeStr(<BDENOSU>)údb "BDEMNOSUW"
 db -@SizeStr(<BDEMNOSUW>)úParmsRec <0,3,0101b>
BifDATE:
 include bf\date.inc

;$9.3.9údb $WholeGEúdb $WholeGTúParmsRec <2,1,1001b>
BifDELSTR:
 include bf\delstr.inc

;$9.3.10údb $WholeGEúdb $WholeGTúParmsRec <2,1,1001b>
BifDELWORD:
 include bf\delword.inc

;$9.5.5údb "SN"údb -@SizeStr(<SN>)údb $Num; Partial test.úParmsRec <1,1,0011b>
BifERRORTEXT:
 include bf\errortex.inc

;$9.4.2údb $WholeGEúdb $WholeGEúdb $WholeGEúdb $WholeGEúdb $Num
; FORMAT actually 1,4 but no room in ParmsRec record for that.
 ParmsRec <1,3,0000b>
BifFORMAT:
 include bf\format.inc

;$9.3.11údb $Padúdb $WholeGEúdb $WholeGEúParmsRec <2,3,1100b>
BifINSERT:
 include bf\insert.inc

;$9.3.12údb $WholeGTúParmsRec <2,1,1101b>
BifLASTPOS:
 include bf\lastpos.inc

;$9.3.15údb $Padúdb $WholeGEúdb $WholeGTúParmsRec <2,3,1100b>
BifOVERLAY:
 include bf\overlay.inc

if Solid
;$9.6.1
 db $BinúParmsRec <1,0,0111b>
BifB2X:
 include bf\b2x.inc
endif

if Solid
;$9.6.2
;$9.6.3
;$9.6.4
 db $PadúParmsRec <1,2,1101b>
BifBITOR: ; Same Bcode as BITAND
BifBITAND:
BifBITXOR:
 include bf\bitand.inc
endif

if Solid
;$9.6.5
 db $WholeGEúParmsRec <1,1,1011b>
BifC2D:
 include bf\c2d.inc
endif

if Solid
;$9.6.7
 db $Wholeúdb $WholeNumúParmsRec <1,1,0011b>
BifD2C:
 include bf\d2c.inc
endif

;$9.6.6
if Solid
 ParmsRec <1,0,1111b>
BifC2X:
 include bf\c2x.inc
endif

;$9.6.8
; Extra test also. NYI
if Solid
 db $Wholeúdb $WholeNumúParmsRec <1,1,0011b>
BifD2X:
 include bf\d2x.inc
endif

;$9.6.9
 db $HexúParmsRec <1,0,0111b>
BifX2B:
 include bf\x2b.inc

if Solid
;$9.6.10
 db $HexúParmsRec <1,0,0111b>
BifX2C:
 include bf\x2c.inc
endif

if Solid
;$9.6.11
 db $WholeGEúdb $HexúParmsRec <1,1,0011b>
BifX2D:
 include bf\x2d.inc
endif

;$9.7.4
 db $WholeGEúdb $WholeGTúdb $StreamúParmsRec <0,3,0001b>
BifLINEIN:
 include bf\linein.inc

if Solid
;$9.7.5
 db $WholeGTúdb $StreamúParmsRec <0,3,0101b>
BifLINEOUT:
 include bf\lineout.inc
endif

;$9.7.3
 db "CN"údb -@SizeStr(<CN>)údb $StreamúParmsRec <0,2,0011b>
BifCHARS:
 include bf\chars.inc

;$9.7.6
 db "CN"údb -@SizeStr(<CN>)údb $StreamúParmsRec <0,2,0011b>
BifLINES:
 include bf\lines.inc
;$9.7.7údb $StreamúParmsRec <0,1,0111b>
BifQUALIFY:
 include bf\qualify.inc

;$9.3.18údb $Padúdb $WholeGEúParmsRec <2,1,1001b>
BifRIGHT:
 include bf\right.inc

;$9.3.19údb $Padúdb $WholeGEúParmsRec <1,2,1001b>
BifSPACE:
 include bf\space.inc

;$9.3.20údb $Padúdb "LTB"údb -@SizeStr(<LTB>)úParmsRec <1,2,1001b>
BifSTRIP:
 include bf\strip.inc
;$9.8.5
 db "CHLMNS"údb -@SizeStr(<CHLMNS>)údb "CEHLMNORS"údb -@SizeStr(<CEHLMNORS>)
 ParmsRec <0,3,0101b>
BifTIME:
 include bf\time.inc

;$9.3.23údb $PadúParmsRec <1,3,1110b>
BifTRANSLATE:
 include bf\translat.inc
;$9.4.6údb $WholeGEúdb $NumúParmsRec <1,1,0011b>
BifTRUNC:
 include bf\trunc.inc
;$9.3.24údb $WholeGTúdb "MN"údb -@SizeStr(<MN>)úParmsRec <2,2,1100b>
BifVERIFY:
 include bf\verify.inc

;$9.3.27údb $WholeGTúParmsRec <2,0,1011b>
BifWORDLENGTH:
 include bf\wordleng.inc

;$9.3.28údb $WholeGTúParmsRec <2,1,1101b>
BifWORDPOS:
 include bf\wordpos.inc

;$9.3.29úParmsRec <1,0,1111b>
BifWORDS:
 include bf\words.inc

BifBound:; A place separating code on basis of address

endif

 include config.inc; Implementation of CONFIG_ routines.
 include bf\bcodes.inc; Equates made by the utility program.
 include bf\frag.inc; Bcode fragments made by the utility program.
 include bf\arithop.inc; More routines in Bcode.

comment~ The Bcode interpreter works almost entirely on a byte basis, so there
are 256 values to be given meanings.  Certain things need a contiguous range:

- The values that index an array of addresses of machine-code routines that
implement various functions, like add and subtract.

- A similar array for operations that do not share opcode values with Pcode.

- The values that index an array of the persistent variables (the usual 8 byte
contents) that are accessible to all the Bcode. Actually two contiguous
sections, one for fetching, one for putting to the persistent variables.

- The values that index an array of addresses for routines that are in Bode as
opposed to machine code. (Not including Bifs since these have addresses in
BifSeg.)

- The values that index an array of addresses for routines that are in Bode as
opposed to machine code and were automatically generated. (Fragments)

- The values that index local variables and temporaries within Bcode routines.
Has fetching and putting sections.

The sequence that arrives at the ranges is:

1. Coding in assembler.

The contents of FanSeg sections provide an order for the opcodes that are
in Pcode. These are the lowest odd numbers used. Label PBcodesCeil$ marks
the limit of those that are also Bcodes.

The order of Bcodes not also Pcodes, and the codes for CONFIG_ routines, is
coded in bcode.as, the only place that needs to know them. These are the
high valued odd numbers.

2. Coding in C.

The codes.i file has details of the Pcodes, manually put in the same order.

3. Run some Rexx.

A Rexx utility checks that the assembler and the 'C' are in the same order,
and generates a file codes.inc giving equates for the actual $pXxxx values.

4. Run some C.

The Bcode compiler (which incorporates codes.i) is run on crx.rx to produce
assembler.  That assembler is input to CRX.EXE when that is next built.
The assembler code is symbolic when referencing values established above.
It is also symbolic in referencing the variables of the routines of crx.rx,
although since it generates equates for those that is readability rather than
logic reasons. There is one number that feeds back to the assembler that
implements Bcode, the number of code points devoted to addressing those
values.

5. Rebuild from all the files produced.

~
Tgts equ 2*$SysCount
$RoutineBase equ 4*$SysCount
$FragsBase equ $BPcodesCeil
comment~ The BCycle loop is used to run Bcode, which is the most compact form
of Rexx, but can only handle the restricted form of Rexx that we make
from the Rexx that is in the ANSI standard.  The Bcode appears in the
CRX implementation as a sequence of DB assembler statements produced
by a utility program and incorporated as various .inc files.

When the more usual execution of Pcode reaches a point (typically a
builtin) which requires execution of Bcode there will be hardware
instructions (implementing that Pcode) which start the BCycle.

There can be recursive since Bcode support INTERPRET which makes Pcode.

It is arranged that the Bcode will immediately follow the hardware
instructions that start it, for Bifs.

The Bcode may call further levels of Bcode but eventually will return
from the top level. The work required for the original Pcode operation
will have been done (eg result of builtin will be on the soft stack)
and Pcode execution resumes at the next Pcode.

About Linkage:  The user's code will make Rexx invocations which become Pcode
to Pcode calls with a Level block on the stack.  There is no other way for
Pcode to call Pcode. The interpreter loops make hardware calls to the routines
implementing opcodes. (In the case of BCycle this is push of return address
and jump but that is the same linkage.)

If the implementing routines use SI then they push and pop CursorSi so that
interpreting resumes at the intended place in Pcode/Bcode.

Some bifs and some arithmetic is done by implementing support for the Pcode
operation as a Bcoded routine. The link from Pcode to Bcode then has to
maintain GS as well as CursorSi.

On the way into the Bcode this is done by LinkBcode, which changes GS
and stacks a return address which will do the reverse. This linkage code
must detect when the caller (eg Bifq$$) is already running as Bcode.

When Bcoded procedures are run the StackDi is pushed on entry and popped on
exit.

So the hard stack will normally show:

A. Hardware addresses stacked for the latest level of m/c code calls and pushes.
B. Bcode addresses with the address of BCycle immediately earlier; these are
   Bcode-to-Bcode calls.
C. StackDi values pushed, just later than a type B (above) entry.
D. Items like type B with a different h/w address. These are calls to Bcode
   that need to do something special on return.

~

;As well as the opcodes common with Pcode, there are Bcode opcodes
;for loading constants, accessing Config_ routines etc. The common
;factor is a list of addresses that are called as a hardware call.
;(call = pushreturn+jump)

BcodeRoutine:; This range is for Bcoded routines with variables.
 push CursorSiúmov CursorSi,(RoutineBase$-$RoutineBase)[bx]
;------------------------------------------------------------------------------
; Enter here to start a Bcode routine.
; Already pushed hard return addresse and a soft CursorSi.
; Enter with zero pushed when entering without Bcode continuation.
;------------------------------------------------------------------------------
BcodeEntry:lodsb cs:[CursorSi]; 5 bits locals count, 3 bits args.
; Compute in cx where Return has to reset stack in order to drop arguments.
; Special when MAX,MIN
; Will push a StackDi type value for use at return.
 cmp CursorSi,BifMAX+1úja @Fúmov cx,Z.ArgsB0újmp Routxú@@:
 movzx bx,alúand al,7úshl al,$ShiftVúcbw
 mov cx,StackDiúsub cx,ax
Routx:push cx; For use at return.
; Put local variables on stack, marked as uninitialized.
 and bl,-$StrideVúadd ArrayBx,StackDi
@@:cmp StackDi,ArrayBxúje @F
 Upúmov V.Dtype,$Omittedújmp @B
@@:mov Z.Stack,StackDiúcall StackSafe

BCycle:mov Z.Stack,StackDi
if Debug
  push axúmov ax,gsúcmp ax,Y.Csegújae @Fúint 3ú@@:pop ax
  cmp CursorSi,Z.AtPauseújne @F
;2011 To have breakpoints on Bcode, set Z.AtPause (using CodeView)
;2011 to the offset in Bcode (shown in Bcode.lst) and break here,
; Bbp.
Bbp:nopú@@:
endif
if MemCheck
 call DosMemCheck
endif
 push BCycleúlodsb cs:[CursorSi]úmovzx bx,alútest al,1újz IsEven
 cmp al,$BcodesBaseújb NotBcode
; This range means "execute operation al".  An opcode appearing in Bcode only.
; CursorSi and StackDi are to be honoured but other registers will be free.
 jmp cs:(BcodesBase$-$BcodesBase)[bx]

NotBcode:cmp al,$FragsBaseújae NotPcode
; This is an opcode appearing in Bcode and Pcode. (In Bcode here)
 jmp cs:(PcodesBase$-1)[bx]

; This is a routine implemented in Bcode, with no variables. (A fragment)
NotPcode:push CursorSiúmov CursorSi,cs:(FragsBase$-$FragsBase)[bx]újmp BCycle

IsEven:cmp al,$Localsújb NotLocalFetch
; A majority of operands will be local variables, using room reserved
; on the stack. A copy of the variable is put at the top of
; the stack when one of these is referenced.
; These are negative because we want to add StackDi to them to address a local.
comment~
Since the top item of the soft stack has offset zero from StackDi, when we
make new space it has a range of zero to minus something offset from the new
StackDi. If we put that range in the Pcode it can't be tested with one compare
so we subtract one. Now an unsigned compare with the low bound does the test.
Hence locals are addressed -2,-4,-6,....  The price is a dynamic adjustment
in computing the address off StackDi.  When there are known to be temporaries on
the stack the testing problem doesn't arise so, in particular for assignment,
that adjustment by one can be made in the value in Pcode rather than
dynamically. The overall effect is that "gets" use the same value in Pcode as
"puts" (apart from the Tgt adjustment that denotes a "put") even though there is
one more item on the stack when "puts" are done.
~

 mov bh,0FFh
; This range means "fetch from stack to top of stack"
Bfetch:; Can be called from elsewhere with bx set.  (DO iteration)
 shl ArrayBx,$ShiftV-1úlea ArrayBx,$StrideV[ArrayBx+StackDi]úUp
 Move V,Vbxs
if Debug
 CheckType
; OK to fetch Omitted if next thing is Exists test.
 cmp V.Dtype,$Omittedúje Omúint 3úOm:
 cmp Bptr gs:[CursorSi],_Existsúje @F
 int 3
@@:
endif
 ret; To BCycle usually.

NotLocalFetch:cmp al,$Locals-Tgtújb NotLocalPut
; This range means "put from top of stack to [bx] down stack"
 mov bh,0FFhúadd bx,Tgt
Bassign:; Can be called from elsewhere with bx set.
 shl ArrayBx,$ShiftV-1úadd ArrayBx,StackDi
;When return from non-local call, having "Move" use the default ecx:eax matters.
if Debug
 CheckType
 int 3
@@:
endif
 Move Vbxs,VúDownúret; To BCycle usually. (But eax:ecx used when to ControlVar)

; The system variables have been put in with the ProgScope constants.
NotLocalPut:cmp al,$RoutineBaseújae BcodeRoutine
 shl ArrayBx,$ShiftV-1
 add ArrayBx,$?SysVars
 cmp al,2*$SysCountújae SysTgt
; Lower half of range is get.
 UpúMove V,Vbxe
if Debug
 CheckType
 int 3
@@:
endif
 ret

SysTgt:sub ArrayBx,$SysCount*$StrideVúMove Vbxe,V
if Debug
 CheckType
 int 3
@@:
endif
; Detect assignment to ?STREAM because of its side effects via QUALIFY
; 2011 Name2File will do the Down
 cmp ArrayBx,$?STREAMúje Name2FileúDownúret

; Name2File is also used to look up the names of external source files.
Name2File:; Stream name has been set and we want Z.Stream (a FileBx value) to
; associate with it.
 push CursorSiúcall LookFileDsBxúpop CursorSiúmov Z.Stream,FileBx
 mov Z.InsUnqual,FileBx; Possible need for a msg.
; If this is first sighting, we need to get the qualified name.
 cmp Vbx.Dtype,$Omittedújne Name2Oldúmov Vbx.Dtype,$Dropped
; STREAMQUALIFY will look up the fully qualified stream and change to that.
; It will do that by invoking Bcode which eventually does
; CONFIG_STREAM_QUALIFIED$$ type 3.
; Run STREAMQUALIFY to set Z.Stream.
; The qualification algorithm is different for source files.
 Qry Z.Cancel,SourceFilesújz @F
 On F.Flags,IsSource
 mov dx,offset PATHQUALIFY
 call LinkBcodeúmov Z.Stack,StackDiúmov FileBx,Z.Stream
 On F.Flags,IsSourceúret
@@:mov dx,offset STREAMQUALIFY
; 2011 Extra Down
 call LinkBcodeúDownúmov Z.Stack,StackDiúmov FileBx,Z.Streamúret

; Lookup may have found the unqualified version.
Name2Old:Qry F.Flags,Qualújnz @Fúmov FileBx,F.ToQualú@@:
 mov Z.Stream,FileBx
if 0
; Slight unnecessary complexity here because STREAMQUALIFY was written to
; take no argument and PATHQUALIFY to take one. Hence need to know which
; would have been used even when neither is.
 Qry Z.Cancel,SourceFilesújz @F
 Down; PATHQUALIFY side effect.
endif
 Down   ;2011
@@: ret

; Assisted linkage from m/c code to Bcode and back.
comment~ Feb 2000. The numeric settings for the Rexx in Bcode are a
complication.  The bifs like MAX need to use the caller's settings. DATE and
TIME need digits 18. The rest run at SCIENTIFIC 9, including ArithOp (where
the caller's precision is an argument).

(Technically there is problem with MAX and NUMERIC DIGITS 1 because that
would not be able to count through the arguments - not a real problem.)

The choice is between push/pull of current values (and acting as if NUMERIC
statements occurred in the present level), or starting a new Level.

The code for Call$$ and Return$$ is not exactly what we need for this context
so starting a new level would duplicate a lot of that code.  Also traceback
would need to be aware of linkage blocks. Most of what is in a Level block,
about Events and Addresses, is not relevant to Bcode.

Modally changing the numerics back and forth has the disadvantage of running
HeritageDi more.

On balance, is seems best not to introduce an extra level.

Dec 2000.  Arithmetic is conditioned by keeping the ZoneNumerics panel
up-to-date.  Simplest is to use ArithGeneral whenever the numerics are not
Scientific 9 digits no-fuzz, otherwise specialized code for each operation.
At the Pcode-Bcode boundary we flip so that the Bcode starts in S9.
Hence ArithGeneral itself normally runs at this S9 mode there is no risk of it
recursing indefinitely.  However there is some Bcode, like DATE conversion,
which has parts that must run with higher digits. If that code has operations
that use ArithGeneral then ArithGeneral will get started in NotS9 mode and
recurse indefinitely.

Dec 2011 WIsh I had noticed the comment from 2000 before I spent two
days exploring a "memory exhausted" message from CRX.  ArithGeneral
calls Prepare which needs to do arithmetic (a simple zero versus
one). UseGeneral flag is on so Prepare calls ArithGeneral...

The mistake is probably in having a flag stemming from the numeric
settings.  What should determine whether arithmetic is done general
case or "quick" should be the actual values in the operation.  If all
the mantissas and exponents fit 32 bit then the arithmetic can be done
in binary.  ArithGeneral implements big number arithmetic, but does
not use big number arithmetic because the big numbers are in character
string form.
~

LinkBcode:push CursorSiúmov CursorSi,dx
LinkBcodeX:; Jump (only) here when hard link & soft cursor already pushed.
; (That will be the case from Bifq$$)
; Note whether this is Pcode/Bcode boundary.
 cmp Z.ResumeP,ZeroBpújne BcodeEntry; Nothing-or-Bcode to Bcode.

; It is the boundary, Pcode calls Bcode.
 mv gs,csúpop Z.ResumeP; The Pcode CursorSi.
; Sadly, that copy of CursorSi is the one that Raise expects to pick up so
; something will have to be done to replace it if CONFIG_RAISE happens.
; Usually we will already be at default numerics so won't need to change.
; Could simplify here since every case not S9 is UseGeneral
 z Z.ResumeD; Marks as default.
 cmp Z.UseGeneral,ZeroBpúje @F
; 2011 This fiddling of Digits() should have been done differently
; since although bifs generally operate at digits 9 there are some
; that record (and subsequently use) the user's current digits before
; using whatever they use.  Here a fix for one-such.
 cmp bl,2*$BifX2Dúje @F
 call HeritageDiúmove Z.ResumeDF,L.DigitsFuzzúmove Z.ResumeS,L.Form
 pop StackDiúcall SetS9
@@:
; Extra level of invoke, to come back here.
 push ResumeP$úcall BcodeEntry; Link of this call is not used. See _RetB
; (It takes the place of unneeded CursorSi - see other path.)
; Resume Pcode execution.  (This can be used after error raised in Bcode)
ResumeP$:; If Z.ResumeD there is need to reset numerics.
 cmp Z.ResumeD,ZeroBpúje @F
 call HeritageDiúmove L.DigitsFuzz,Z.ResumeDFúmove L.Form,Z.ResumeS
 call ZoneNumericsúpop StackDiújmp ResumePret

@@:; Assert SetS9 not needed.
ResumePret:mov CursorSi,Z.ResumePúz Z.ResumePúmov Z.Stack,StackDi
 mov gs,Z.CodeúBackRet;

SetS9:call HeritageDiúmov L.Form,'S'úz L.Fuzzúmov L.Digits,9úcall ZoneNumerics
 pop StackDiúret

;------------------------------------------------------------------------------
; Here are administration routines supporting Bcode.
;------------------------------------------------------------------------------
; Loading top-of-stack with constants.
Zero$$:Up
ZeroIt:mov V.ExpAnd,ebpúmov V.Mantissa,ebpúret

One$$:call Zero$$
IncrIt:inc Bptr V.Mantissaúret

Null$$:Upúmov V.Dtype,$NullStringúret
; One byte constant operand follows String1.
String1$$:lodsb cs:[CursorSi]úUpúmov V.Dtype,$NullString+1úmov V.String,alúret
String2$$:lodsw cs:[CursorSi]úUp
 mov V.Dtype,$NullString+2úmov Wptr(V.String),axúret
String$$:z axúlodsb cs:[CursorSi]úUpúcmp ax,7úja @F
 Move V,cs:Vsid,edxúadd CursorSi,axúadd al,$NullStringúmov V.Dtype,alúret
@@:mov V.Sg,csúmov V.Pt,CursorSi
 mov V.Len,axúcall Awayúadd CursorSi,axúret
;MASM.......................
_RetBc$$:; Prune the stack on a return with no result.
; The link to BCycle on stack is not needed.
; The link on the original call is used.
; That will usually be to continue BCycle but could be return to LinkBcode.
 PopJunk diúpop StackDiúRetSi

; Return a level within Bcode.  Case when there is a result.
; Restore StackDi to delete the local variables.
;MASM ...........................
_RetB$$:mov StackSi,StackDiúPopJunk diúpop StackDi
; Move the result on to where the first argument was.
 UpúMove V,VsiúRetSi

; Return from fragment.
_RetF$$:PopJunk siúRetSi

; Check if an argument was explicit.
_Exists$$:mov al,V.Dtypeúcall ZeroItúcmp al,$Omittedújne IncrItúret

_IterCV$$:; This version used by Bcode because assignment to control
; variable has to be different from Pcode version.
 mov bx,D.CVúpush bxúcall Bfetch
 call NumDxBx; Already checked.
; Add on BY.
 mov ecx,D1.By.ExpAndúmov V2.ExpAnd,ecx
 mov eax,D1.By.Mantissaúmov V2.Mantissa,eax
 call AddRegs
; Store that back in CV.
 pop bxúcall Bassign
 jmp CompareTO

; NYI avoid test.
_Then$$:test V.Dtype,$Testújz @Fúcall NumDxBxú@@:
 cmp V.MantLow,ZeroBpúDownCareúje _Jump$$úinc CursorSiúret

_Jump$$:movzx ax,Bptr cs:[CursorSi]úadd CursorSi,axúret

CONFIG_ARITH$$:push CursorSi; Add/Sub in decimal.
; The arguments will be string because they were made by PARSEing.
; The arguments have been made the same length.
; The result might be one longer for add.
; Leading zeros will be removed later.
; Not OK to destruct arguments.
 mov dh,V.String; The operator
; Make copy of LHS with extra position.
 Downúcall ToDsSiCxúinc cxúUpúcall ResultSpace
 sub StackDi,2*$StrideV
 call ToDsSiCx
 push StackDiúmov di,axúmov es:Bptr[di],'0'úinc diúrep movsbúpop StackDi
 Move V,V3
 call ToDsSiCxúmv es,dsúmov bx,siúinc bx
 Upúcall ToDsSiCxúDown
; Add/Sub DS:SI::CX to ES:BX which is addressed by V.
 add bx,cxúadd si,cxúz dl
 cmp dh,'+'újne CAsubloop
;MASM............................
CAaddloop:dec bxúdec siúmov al,es:[bx]úsub al,'0'úadd al,[si]úadd al,dlúz dl
 cmp al,'9'újna @Fúsub al,10úinc dxú@@:mov es:[bx],al
 LoopQ CAaddloop
 cmp dl,0úje @Fúmov Bptr es:[bx-1],'1'ú@@:
 pop CursorSiúret

CAsubloop:dec bxúdec siúmov al,es:[bx]úsub al,[si]úsub al,dlúmov dl,0
 jns @Fúadd al,10úinc dxú@@:add al,'0'úmov es:[bx],al
 LoopQ CAsubloop
; Assert DL=0 was pre-arranged.
 pop CursorSiúret

; Raise from Bcode.
CONFIG_RAISE$$:; eg 'SYNTAX',26.11,<value>,<value>,<value>
 mov si,Z.XCycleResetSpúmove Wptr[si+bp-4],Z.ResumeP
 call ResumeP$
 sub StackDi,2*$StrideV
 cmp V00.Dtype,$NullString+6újne NotSyntax
; Make it look like jmp Raise from hard code.
 mov ax,MkMajMin(26,11)
 cmp V0.String,'2'; Only 26.xx and 42.xx come this way.
 jne CR42úcmp V0.String+4,'2'újne @Fúinc axú@@:jmp Raise
CR42:mov al,V0.String+2úsub al,'0'újmp Raise

NotSyntax:Error49Bp

 end
