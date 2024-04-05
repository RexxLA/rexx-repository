; Build characteristics:
 CD equ 0; On when dump of compaction activity needed. See CD.REXX
 Debug equ 0; On for normal checks detecting internal flaws early.
 MemCheck equ 0; On for DOS memory checks.
 ForBcode equ 0; When making code that will be turned to BCode.
 ForBig equ 0; When making code that will be turned into one big assembly.
 SortSpaceSS equ 1; Design has compaction list under SS.
 Trial equ 0; Design change experiment.
 Solid equ 1; Always 1, used to mark sensitive areas for ForBig technology.
;(Solid section with following label is assumed not to fall through.)
if ForBigú.lallúendif
if Debug
CheckType macro
 test V.Dtype,$Testújz @F
 cmp V.Dtype,$AwayStringúje @F
 cmp V.Dtype,$NullStringúje @F
 cmp V.Dtype,$NullString+1úje @F
 cmp V.Dtype,$NullString+2úje @F
 cmp V.Dtype,$NullString+3úje @F
 cmp V.Dtype,$NullString+4úje @F
 cmp V.Dtype,$NullString+5úje @F
 cmp V.Dtype,$NullString+6úje @F
 cmp V.Dtype,$NullString+7úje @F
endm
endif
 EXTERNDEF ToWholeEbx:near; Converts from Rexx variable to integer in EBX.
 EXTERNDEF Zero$$:near; Puts zero on the stack.
 EXTERNDEF Then$$:near; Execution of THEN
 EXTERNDEF DigitsChange:near; Called at places where Digits() setting may change.
 EXTERNDEF ZoneNumerics:near; Updates Zone for fast access to numeric settings.
 EXTERNDEF SetInherit:near; Inherit, for an external routine.
 EXTERNDEF Compiling:near; To start compiling something.
 EXTERNDEF Compiler:near; To start compiling something.
 EXTERNDEF StartExecution:near; To start executing made Pcode.
 EXTERNDEF StartExecutionY:near; To start executing made Pcode.
 EXTERNDEF ResumeP$:near; To start executing Pcode after Bcode.
 EXTERNDEF Command:near; To start compiling source named on a command.
 EXTERNDEF AssureSiPlus:near
 EXTERNDEF AssignExposed:near
 EXTERNDEF Name2File:near
 EXTERNDEF ZoneToLevel:near
 EXTERNDEF BifBound:near; A place separating code on basis of address
 EXTERNDEF ConstValue:near
 EXTERNDEF ConstValueX:near
 EXTERNDEF Terminate:near
 EXTERNDEF UpperFirstAh:near
 EXTERNDEF NotPresent:near
 EXTERNDEF Consist:near
 EXTERNDEF Serialize:near
 EXTERNDEF RetEsSi:near
 EXTERNDEF ExposedFs:near, DotsExposed:near
; Make the memory services available to all modules.
 EXTERNDEF InitMemory:near, AllocateCx_EsAx:near, InitSegDs:near
 EXTERNDEF MoreSpaceEs:near,GiveDosMem:near
 EXTERNDEF ParaAllocAx:near, Raise5p1:near, Raise5p1d:near
 EXTERNDEF StackSafe:near, SetStack:near, UpStack:near
; Most modules need to load values from Rexx variables to registers.
 EXTERNDEF ToDsSiCx:near, NumDxBx:near
; Many modules create pseudo-code, test operator attributes..
 EXTERNDEF Scode:near, Pcode1:near, Pcode2:near, PcodeArg:near
 EXTERNDEF PcodeGapBx:near, PcodeOp:near, OpFlags:near
; Lookup things may be needed in execution, eg for DROP (abc)
 EXTERNDEF Lookup:near,SymbolsSafe:near,SetSymLenJa:near,SymbolLook:near
 EXTERNDEF VasDsSiCx:near
; And a few more in common use.
 EXTERNDEF Ax2DsSiCx:near,HeritageDi:near, Raise:near
 EXTERNDEF Attributes:near; Table for uppercasing, etc.
 EXTERNDEF ResultSpace:near, AwayEsAxCx:near
 EXTERNDEF LinkBcode:near, LinkBcodeX:near
 EXTERNDEF CONFIG_UPPER$$:near
 EXTERNDEF CONFIG_RAISE40$$:near
 EXTERNDEF PcodesBase$:near
 EXTERNDEF DotsFsBxDsSi:near
 EXTERNDEF DotsFsBxDsSiX:near
 EXTERNDEF XCycle:near,Rejumps:near,Boolery:near,BooleryRejumps:abs
 EXTERNDEF LookFileDsBx:near
 EXTERNDEF Away:near
 EXTERNDEF ClauseSourceEnd:near
 EXTERNDEF DualSwitch:near
if Debug
 EXTERNDEF Say$$:near ; only for Consist debug
 EXTERNDEF DosMemCheck:near
 EXTERNDEF Create4Dump:near
 EXTERNDEF Dumper:near
endif

 include codes.inc; Relates to ordering within FanSeg and BifSeg.
 include synequ.inc; Values given to special characters etc.
ParseDot equ 254; A non-operator Bcode value otherwise unused.
KeysBase equ 4*10; Manual
; Here are some symbolic names of registers, used for readability of this code.
ZeroBp is <bp>
StackDi is <di>      ; The soft stack pointer.
StackSi is <si>      ; Another soft stack pointer.
StackDx is <dx>      ; Limit of range on soft stack.
ArrayBx is <bx>      ; To an element of Vshape.
StemBx is <bx>       ; When the subject is a stem.
TailSi is <si>       ; When the subject is a tailed variable.
FileBx is <bx>       ; To an element of Fshape.
ArraySi is <si>      ; To an element of Vshape.
OperandBx is <bx>    ; A pointer to an operand in one of the arrays of Vshapes.
OperandBl is <bl>    ;
ProbeBx is <bx>      ; Used when searching a binary tree for a stemmed variable.
LowSi is <si>        ; Used when searching a binary tree.
HighDi is <di>       ; Used when searching a binary tree.
ToFindLenAx is <ax>  ; Used when searching a binary tree.
ToFindDx is <dx>     ; Used when searching a binary tree.
KeyListCx is <cx>;   ; Parameter to keyword lookup.
TokNowCh is <ch>;    ; One of the places numbers for tokens are held.
StateSi is <si>      ; The state in parsing.
ParseSi is <si>      ; Parse state pushed on hard stack.
StateDi is <di>      ; Address first word of the state.
StateBx is <bx>      ; Often distance from StateOrig to some state data.
ParseDx is <dx>      ; Token data in form the parser uses.
RtypeAh is <ah>      ; Type of reduction done in Cycle.
TokNumAh is <ah>     ; Where next token is returned, becoming TokNum.
LookupSi is <si>     ; Where Lookup finds unresolved compound symbol.
LevelSi is <si>      ; To block for this invocation level.
LevelDi is <di>
CursorSi is <si>     ; Offset in Pcode.
CursorBx is <bx>     ; Offset in Pcode.
OpAppendCx is <cx>   ; Numeric argument to PcodeOp routine.
ScanSi is <si>       ; Scanning the user's source program.
OpAppendCl is <cl>
RawCharAl is <al>
RawCharAh is <ah>
AttribAl is <al>
RadixTypeDl is <dl>
ParmsCx is <cx>
ParmsCl is <cl>
LengthAtBx is <bx>
SymsZiDx is <dx>
SegOffDi is <di> ; Offset in Zone of a segment pointer.
; Special use of bp for two-byte call.
Error49Bp is <call bp>
; Shorthand for current byte of input.
RawChar is <byte ptr ss:[si+bp]>
; These for making messages.
DepthBl is <bl>; of recursion.
DepthBx is <bx>; Bug if inc/dec affects bh.
TheMsgBh is <bh>; on when scanning the target.
PartLenCx is <cx>; Amount of compressed to expand.
LowPartLenCl is <cl>
KeywordOffsetCx is <cx>
MajMinDx is <dx>
MajorDh is <dh>
MinorDl is <dl>
MinorDx is <dx>; inc/dec
ScannerSi is <si>; SI the address in table. (LODS used)
; For segment registers.
; ES has some transient uses (particularly because it cannot be overridden
; in movsb) but mainly it is set to the symbols segment during compilation
; and the program scope segment during execution.  Tailed variable references
; also use it (transiently) because each stem variable has it's own segment.
SymbolsEs is <es>
ProgEs is <es>
StemEs is <es>
comment~ The root for what CRX comprises is the CS register. A chain anchored
in what that addresses is used for the program executions.  A program
execution has an SS value, with SP and DI giving the stacks within it. Under the
SS value there is an array; array elements address segments for Symbols, Consts,
Variables, Pcode, ProgScope and VarScope.

~

$DosDisk equ 19h
$DosDate equ 2Ah
$DosTime equ 2Ch
$DosCreate equ 3Ch
$DosOpen equ 3Dh
$DosClose equ 3Eh
$DosRead equ 3Fh
$DosWrite equ 40h
$DosDelete equ 41h
$DosSeek equ 42h
$DosChmod equ 43h
$DosPath equ 47h
$DosAllocate equ 48h
$DosFree equ 49h
$DosModifyAllocated equ 4Ah
$DosExecute equ 4Bh
$DosExit equ 4Ch
$DosReturnCode equ 4Dh
$DosGetError equ 59h
$DosPSP equ 62h
; As allowed by the Standard:
$Limit_EnvironmentName equ 10
$Limit_String equ 50000
$Limit_Literal equ 250
$Limit_Name equ 250
$Limit_Digits equ 9999; Note Msg33.2 must be generated to match.
$Limit_ExponentDigits equ 9
$Limit_Insert equ 50; Longest insert.
; Ours
$Limit_Major equ 54; Highest message user sees.
$Descriptions equ 55; A place in the message numbering for oddment prose.
$MsgRoom equ 4*$Limit_Insert
$MaxPreInsert equ 175; Chars in message.
$MsgChunk equ 80; Strictly, ANSI says leave chunking to system.
$MaxParms equ 100; Per invokation. (Or temporary results within an expression)
$FileBufferSize equ 1024
$Leeway equ 3
; Data types within symbols segment:
$tChar equ 0FFh
$tLabel equ 0FEh
$tBinary equ 0FDh
; Minor bits on an operand reference.
$CaseTarget equ 6
; Subcodes to Pcodes.
; These are used by the utility. Avoid putting semicolon abutting the "h".
; These markers share values with Sysvar references in Bcode but we don't
; parse into sysvars in our Bcode.
; If we want to detect presence/absence of these they need to be 2 modulo 8.
; However if they always follow something known, any value will do.
; In practice we sometimes use the modulo 8 approach (even at the expense of
; a shift when they are used) so as to make scanning of Pcode simpler.
$mRepTail equ 02h        ; Used when $pDotControlVar addresses tails.
$mUpper equ 0Ah          ; Modifier on parse source.
$mParseEscape equ 12h    ; Parse part too complex to handle as single action.
$mParseEnd equ 1Ah       ; Parse ends.
$mPosRest equ 22h        ; Parse trigger
$mPattern equ 2Ah        ; Parse trigger after operand
$mPosEq equ 32h          ; Parse trigger after operand
$mPosPlus equ 3Ah        ; Parse trigger after operand
$mPosMinus equ 42h       ; Parse trigger after operand
$mTemplateComma equ 4Ah  ; Parse trigger
; These in number field of $pParse:
$nVar equ 0              ; These
$nWith equ 2             ;       two lowest of parse sources.
$nArg equ 4
$nLineIn equ 6
$nPull equ 8
$nSource equ 10
$nVersion equ 12
; These in number field of $pCommandEnv
$nStem equ 00h
$nStream equ 20h
$nNormal equ 40h
; These in number field of $pNumeric
$nDigits equ 00h
$nFuzz equ 02h
$nForm equ 04h
; These in number field of $pRaise
$n7p3 equ 0
$n17p1 equ 2
$n40p3 equ 4
$n40p4 equ 6
$n40p5 equ 8
; Types for things in Z.Serial
; $SerialNone is also used for message building.
; $SerialSource is qualified by Z.RelativeNow - what part of source file.
; These are modals except for $SerialCompaction which saves/restores previous.
$SerialNone equ 0
$SerialQue equ 1
$SerialCompaction equ 2
$SerialInterpret equ 3
$SerialSource equ 4
; Trace events. (Order unexploited except for highest.)
$TraceAssign equ 0
$TraceBY equ 1*2
$TraceClause equ 2*2
$TraceCompound equ 3*2
$TraceDot equ 4*2
$TraceError equ 5*2
$TraceExpr equ 6*2
$TraceFailure equ 7*2
$TraceFunction equ 8*2
$TraceOperator equ 9*2
$TracePrefix equ 10*2
$TraceLit equ 11*2
$TraceVar equ 12*2
$TraceBack equ 13*2; Highest for $TrEv.
$TraceParse equ 14*2; Only sets flag.
$TraceEndClause equ 15*2; Compiled at end of a traced clause.
; Descriptions on messages.    See OverfullMem for some.
Assert Zshape.SysFiles-Zshape.SysFiles eq 2*1-2
Assert Zshape.Consts-Zshape.SysFiles eq 2*2-2
Assert Zshape.Vars-Zshape.SysFiles eq 2*3-2
Assert Zshape.ProgScope-Zshape.SysFiles eq 2*4-2 ; Used for 'memory' msg.
Assert Zshape.VarScope-Zshape.SysFiles eq 2*5-2 ; Used for 'string length'
Assert Zshape.Symbols-Zshape.SysFiles eq 2*6-2
Assert Zshape.Code-Zshape.SysFiles eq 2*7-2
Assert Zshape.Zone-Zshape.SysFiles eq 2*8-2
Assert Zshape.Stem-Zshape.SysFiles eq 2*9-2
$DescString equ 5
$DescArgs   equ 10
$Desc59H    equ 11
$DescFiles  equ 12
$DescQueue  equ 13
$BifTag equ 80h; Helps with reverse lookup
; As well as source coming from a file, there are the cases of INTERPRET,
; VALUE, and SYMBOL where some compiling is needed.  Also VarPool cases.
; Even if only Lookup is needed, it can be simplest to compile and pick
; the answer up from the generated code.
$SourceBufferSize equ 4552; Allows for long bit literal.
$InitStackSize equ 8192
 $White equ 0ú$Digit equ 64ú$Letter equ 128ú$Special equ 192
 $NonUpable equ 8ú$Bb equ 4ú$Xx equ 2ú$Ee equ 1
 $Lowercase equ $Digit+$NonUpable; Use jnz avoiding uppering.
; Constants for Bifs.
$BifBase equ 65535-70; 68 bifs at high numbers.
; The equates for pseudo code operations are with the P switch.
; (See also $Reserved)
comment~ The mechanism for variables has a symbol pool which is a segment with
the uppercased names of all the program's variables in it.  (It also has the
constants but that doesn't affect this discussion.)

A compact numbering of the variables is used to index an array.  The
array has an eight byte element.  Two bytes address the corresponding
name. Four of the bytes are used for binary lookup of names.

In addition to the array used for lookup, there are copies of this
array for the program level and each level of procedure call.  In
these arrays the eight bytes are the value of that name in that scope.
(There is a special value for "Dropped")

Design note:- A good design for EXPOSED depends on guessing the usage.
If a few variables are exposed then "copy-in copy-out" of the value to
the current procedure would be good.  If many variables are exposed
and few used then "indirect reference" is better.  Both are catered
for well by "copy-in on first reference and copy-out if assigned to"
but that involves more dynamic testing. The copy-in test would hardly
cost because it can go with the dropped test needed anyway. The
copy-out test would add to the work for every assignment.

Another option would be copy-in on first reference and use the EXPOSE
list again at RETURN from the procedure to do copy-out.  Note that we
cannot compile differently for exposed variables because in general
SIGNAL can reach same code with a variable either way. Also a problem
recompiling when "expose (abc)".

There is no way to guess what proportion of exposed will actually be
used on a typical call, so maybe best to do something simpler.

The simpler route is to retain the expose as an indirection even after
use. This no slower for non-exposed, not much slower for exposed, and
does away with a lot of mechanism.  End Design note.

There is a special value also for "Exposed".

By moving the sign of the mantissa in with the exponent we can test
zeroness rather than parity in the high bits of the mantissa.  Taking just one
value out of the four leaves three, for "is a short string", "is a long string",
and "not present".  After "not present" there will be a further test, to
distinquish "dropped" and "exposed".

The user may write constants in a way that mismatches how they look from the
type of value needed, eg LEFT(2.0,"2.0").  To avoid runtime conversions
the $Constant type is used, allowing for compile time conversion to
LEFT("2.0",2).  Another example is options - these are made to one character
uppercase when constant.

~
$Test       equ 11000000b; To test the most vital bits.
$NullString equ 10000000b; 01000nnn for 0-7 length strings.
$Omitted    equ 10001000b; Value of omitted is null string.
$Variable   equ 10001001b; Only used at compile time.
$Constant   equ 10001010b; Only used at compile time. (Untyped constant.)
$Label      equ 10001011b;
$AwayString equ 11000000b;
; NYI $AwayNumber equ 11110000b;
; The 01 tags don't reach the runtime stack.
; (That avoids a test when type checking operands now and allows future use.)
$Dropped    equ 01000000b;
$Exposed    equ 01010000b;
$Stem       equ 01100000b;
$MsgNum     equ 01000100b; Msg number in Major/Minor form.
$Sigl       equ 01001000b; Jump point still as code offset.
; Not to be confused with the bits from the table of characters:
XlatBDLS macro ;; 0=Blanks 1=Digits 2=Letters 3=Special
 ;; Picks up attributes of current char and sets flags.
 xlat Bptr cs:[bx]útest al,0C0h
endm
Down macro
 sub StackDi,$StrideV
endm
Up macro
 add StackDi,$StrideV
endm
DownCare macro
 lea StackDi,(-$StrideV)[StackDi]
endm
UpCare macro
 lea StackDi,$StrideV[StackDi]
endm
; Hard & soft cursors return.
RetSi macro
 pop CursorSi
 ret
endm
; Macros for some common idioms in Pcode making.
OpAl macro $p
  mov al,$púcall PcodeOp
endm
OpRet macro $p
  mov al,$pújmp PcodeOp
endm
EvAh macro $p
  mov ah,$púcall TraceEvent
endm
EvRet macro $p
  mov ah,$pújmp TraceEvent
endm

; Macros are used to make that clear where code is run out of the interpreter
; loop, and to allow experiments in how the return is made.
; These experiments never worked out because of the difficulty in having some
; operations that needed to be routines (eg Assign as part of ControlVar) and
; some that didn't.  Changing code to achieve sometimes-routine is a speed
; killer.

Back macroújmp XCycleúendm
BackRet macroúretúendm

; When all the operations end with a jump to XCycle we can turn them into
; callable routines by sticking a ret instruction the code at XCycle.
; Performance killer so rarely used.
$ret equ 0C3h
CodeModeR macro
 push Wptr cs:XCycle
 mov Bptr cs:XCycle,$ret
endm
UnCodeMode macro
 pop Wptr cs:XCycle
endm

comment~ Generally we avoid string moves because they require five registers
set up. So short strings move a fixed 8 bytes and long string assignments are
done by pointer manipulation rather than actual move.  However, sometimes
moves are necessary.  The timing of rep movs is 12+3n where n is the
repetitions. So it doesn't take much length to make movsw and movsd better than
movsb even if some cx adjustment is needed.

Repmovsb is a faster version of rep movsb. Faster still is possible if we
know it is safe to movs extra byte(s) beyond the essential ones, that cx is
multiple of four, or something else relevant.

In practice cannot see an improvement. Maybe hardware has tricks for movsb.

What does seem to work in practice is to check for length<8 and move eight
bytes without a loop.
~
Repmovsb macroúlocal IsEven
if 1
 rep movsb
endif
if 0
; This ought to be faster but didn't seem to be. Perhaps jnc high cost.
 shr cx,1úrep movswújnc IsEvenúmovsbúIsEven:
endif
endm

; There is a "mv" macro that moves registers by push & pop.
; There is a "move" that saves typing when memory-to-memory.
; Here is "Mv" that moves a Rexx variable (8 bytes addressed by pointer
; register) memory-to-memory by push & pop.
; Here is "Move" that moves a Rexx variable (8 bytes addressed by pointer
; register) memory-to-memory by shuffling through general registers.
Mv macro To,From
; "Move" is faster than "Mv" and no bigger, if there is a spare register.
   pushd From.OverExpoúpop To.OverExpo
   pushd From.OverMantúpop To.OverMant
endm

Move macro To,From,Via
; Move of a Rexx value. Convention is to use ecx:eax
 ifb <To>
; No target means load usual registers.
   mov ecx,From.OverExpo
   mov eax,From.OverMant
 elseifb <From>
; No source means store from usual registers.
   mov To.OverExpo,ecx
   mov To.OverMant,eax
 elseifb <Via>
; Copy via usual registers.
   mov ecx,From.OverExpoúmov To.OverExpo,ecx
   mov eax,From.OverMantúmov To.OverMant,eax
 else
; Copy via specified register.
  mov Via,From.OverExpoúmov To.OverExpo,Via
  mov Via,From.OverMantúmov To.OverMant,Via
 endif
endm

comment~ Everything to do with processing a program is
anchored on the SS register.  (The stack segment contains a pointer to the code
segment.)

The stack segment has the hardware stack (addressed by offset SP) at the high
address end and a "soft stack" at the low address end.

The hardware stack is used for general things like return addresses and pushes
to save registers temporarily, and is also used to stack parser states.
(Also for lists that speed up Rexx procedure calls - see Call$$)

The software stack is the stack for Rexx values in execution. It is used in an
analogous way during parsing to stack information about operands - information
that allows improved pseudo-code generation. The shape most commonly stacked
represents a variable's value, but items that correspond to DO groups and
invocations are also stacked.

The register StackDi is maintained pointing to the soft stack (but not
necessarily the latest item on it).

Here is the content of the SS segment arranged with higher address
higher up the screen:

The Parser states.  Top end of this is the top end of the segment.  Bottom end
is SP (when there are no unmatched PUSHes or CALLs that have changed SP; that is
the case in Cycle when a parser state is added/removed at low end).

The links and pushes.  The ordinary mechanics of executing Intel code require a
stack; this is it, whatever CRX is doing. It's low end is the current value of
SP.

The gap. This managed by appropriate checks. It is prevented from getting too
small by increasing the size of the SS segment on demand (with matching increase
of SP value.)

The compile time argument checking stack.  This runs from Stack at
high address down to Base0.

The compile time stack for holding up left-hand-sides so that they can be put in
the Pcode after the expression to be assigned.

The operands and temporaries invoved in executing the current expression.

The DO and INTERPRET blocks.

The block for the level of invocation. This, with the two things listed above,
may be repeated.

The Zone, general data area.  Includes a block for the outermost level.

~
FarpX struc
 Fr dword Overlay
 Pt charp 0
 Sg Segp 0
 Limit word Overlay
 Len word 0
FarpX ends

comment~ The logic for this Vshape goes as follows.  To get 7 bytes contiguous
for a string, we need to put the Dtype at highest or lowest byte.  If at the
lowest it would correspond to the least significant end of any numbers overlaid.
But we want to detect numbers via Dtype by having two bits zero at the high end
of the mantissa.  So both Dtype and Mantissa go at the high end.

The Intel architecture uses signed offsets so it is a close call about which
byte of the structure the index register should address.  Putting it at the low
end means no offset in the instruction when addressing Sign,String and Exponent.
Putting is at the high end means no offset when addressing Dtype.

The simple solution of having the index at the first unused byte of the stack is
not efficient, because then none of the fields have zero offset.

To make things consistent, the index is set $StrideV bytes lower than the first
unused byte.  This applies even when the top thing on this soft stack is not of
size $StrideV, eg DO and Level blocks are addressed from partway down them.

~

Vshape union
 struc; When containing a short string.
  String db 7 dup(?)
  Dtype db ?                        ; Whether string or not and used length.
 ends
 struc; When binary number
  Sign byte Overlay     ; Odd means negative mantissa.
  ExpAnd dword Overlay  ; Exponent and sign of mantissa.
   ExpoUses db 3 dup(?)
   ExpoSign db ?        ; Sign of exponent.
  Mantissa dword Overlay
   MantLow word ?
   MantHigh word ?
 ends
 struc; When treated as just bytes.
  OverExpo dword ?
  OverMant dword ?
 ends
 struc; When referencing a long string.
  FarpX <>
  dw ?                              ; Covers Dtype.
 ends
 struc; When referencing label information
  LabelValue word ?                 ; Offset in Pcode.
  dword ?
  LabelType word Overlay
  byte ?                            ; 0 = normal, 1 = TraceOnly
  db ?                              ; Covers Dtype. Will be $Label.
 ends
 struc; When compile time stack item for a constant.
  WhichCon word ?                  ; Offset under ProgScope.
  PcodePos word ?                  ; Where it will be in Pcode.
  db 4 dup(?)                       ; Covers Dtype. Will be $Constant.
 ends
 struc; When compile time stack item for a resolved target.
  HeldOver word ?                   ; To go in Pcode eventually.
  db 6 dup(?)                       ; Covers Dtype. Will be $NullString
 ends
 struc ; When used to look up symbols.  Dtype not relevant then.
; Moot whether this is really a Vshape but pretending it is allows use of Vbx.
  Pair dd 0 dup(?)                  ; Next two together.
   Lower Ushortp ?                  ; a subtree.
   Higher Ushortp ?                 ; a subtree
  Here charp ?                      ; to the symbol.
 ends
Vshape ends
; V. is for Vshape objects addressed by [di+bp]; eg variables on the stack.
V is <(Vshape ptr[bp+di])>
; 1-origin numbers for the parameters of bif, but V is used for V1 (and result).
; So lhs and rhs of binary operation are V and V2, result overlays V.
; Of course, changing di by $StrideV is an alternative to using different Vn.
$StrideV equ size Vshapeú$ShiftV equ 3
V0 is <(Vshape ptr[bp+di-$StrideV])>
V00 is <(Vshape ptr[bp+di-2*$StrideV])>
V2 is <(Vshape ptr[bp+di+$StrideV])>
V3 is <(Vshape ptr[bp+di+2*$StrideV])>
V4 is <(Vshape ptr[bp+di+3*$StrideV])>
; Vsi. is for Vshape objects addressed by [si+bp]; variables on the stack.
Vsi is <(Vshape ptr[bp+si])>
;Vsif. is for Vshape objects addressed by fs:[si]; Variables of procedure.
Vsif is <fs:(Vshape ptr[si])>
; Vdid. is for Vshape objects addressed by ds:[di]
Vdid is <ds:(Vshape ptr[di])>
; Vsid. is for Vshape objects addressed by ds:[si]
Vsid is <ds:(Vshape ptr[si])>
;Vbx. is for Vshape objects addressed by ds:[bx]
Vbx is <ds:(Vshape ptr[bx])>
;Vbxf. is for Vshape objects addressed by fs:[bx]; Variables of procedure.
Vbxf is <fs:(Vshape ptr[bx])>
Vbxt is <fs:(Vshape ptr[bx-$CaseTarget])>
Vbxf2 is <fs:(Vshape ptr[bx+$StrideV])>
;Vbxs. is for Vshape objects addressed by ss:[bx]; Variables on the stack.
Vbxs is <ss:(Vshape ptr[bx])>
;Ve. is for Vshape objects addressed by es:[bp]; (Saves a byte sometimes)
Ve is <es:(Vshape ptr[bp])>
Vf is <fs:(Vshape ptr[bp])>
;Vbxe. is for Vshape objects addressed by es:[bx]
Vbxe is <es:(Vshape ptr[bx])>
if 0
Worked, but so does trailing []
Vat macro Delta:req
  exitm @CatStr(<(Vshape ptr es:[bp+>,Delta,<])>)
 endm
endif
Dshape struc; The elements of soft stack for DO loops.    (And INTERPRET)
; Here the n of "DO n;" will wind up.
; Also x of DO j=x...  We don't need to retain that through the DO-END, but
; harmless to do so. (Overlaid when DO A.K=....)
 TailsAt word Overlay; Where the pcode to reload tails is.
 Subject Vshape 0 dup(<>); When block is for an INTERPRET.
 CVinit Vshape 0 dup(<>)úReps Vshape <>
 To Vshape <>
 By Vshape <>
 ForCount Vshape <>
; The rest is made similar to a Vshape so that Bcode can overlay Dshape as
; variables.
 PcodePos charp Overlay; When block used for an INTERPRET.
 Iteration charp ?; Where to branch on ITERATE
 Leaving charp ?  ; Where to branch on LEAVE
 UpDO charp Overlay; When block used for an INTERPRET.
 CV charp ?; Offset of the control variable.
 byte ?
 Rec byte ?;  MASM confused when LoopsRec<> used.
Dshape ends
$StrideD equ size Dshape
; D. is for Dshape objects addressed by [di+bp]; the DO nesting.
; These objects are addressed from partway through them.  This is because the
; XCycle loop benefits from moving StackDi over the "previous operand" when
; loading the latest operand. But the "previous operand" may actually have
; been one of these DO control blocks.
; Use D1 to address the DO block when StackDi has been upped to indicate
; there is a value stacked later than the DO block.
D is <(Dshape ptr[bp+di-$StrideD+$StrideV])>
D1 is <(Dshape ptr[bp+di-$StrideD])>

comment~  When looking up external names we could separate looking up data
files from looking up programs by using using different segments or different
trees in the one segment. The latter is used (see SourceFiles flag).
~
 FRec record Qual:1,Read:1,Open:1,BeenRead:1,BeenWrite:1,
             WriteMode:1,IsSource:1,BeenCompiled:1,FFpad:8
Fshape struct ; Data for a file, the key is the file name.
  Flags FRec <>
  ToQual word ? ; To item for fully qualified name.
  Lines Ulong ?
  Hand Handle ?
  Other_Position Ulong ? ; A position on the file, provided by DOS.
  Exten byte ?; 1=REX/CMD 2=COM 3=EXE 4=BAT
  TraceWidth byte ?; How many chars in a clause identifier.
  Symbols Segp ? ; Saved from Zone when file inactive.
  Code Segp ?
  Vars Segp ?
  Consts Segp ?
  ProgScope Segp ?
Fshape ends
$StrideF equ size Fshape
; F. is for Fshape objects addressed by [bx]; a file.
; An Fshape is put ahead of a Jshape.
F is <(Fshape ptr[bx-$StrideF])>

EnvBlock struc 2
 EnvNumber    word ?
 EnvResourceI word ?
 EnvResourceO word ?
 EnvResourceE word ?
EnvBlock ends
if 1; Private to memory object
Ashape struc; Describe pieces of memory got from Dos, and part of them used.
 Fr Farp <>
 Amount Ushort 0
Ashape ends
; A. is for Ashape objects addressed by [si+bp]; For memory allocation.
A is <(Ashape ptr[bp+si])>
$StrideA equ size Ashape
endif
InsBlock struc;  Used by issuing of messages, to deduce inserts.
 MajMin word Overlay    ; This is an error detected.
  Minor byte ?
  Major byte ?
 Value word ?           ; Soft stack offset of value.
 Named Ushort Overlay
 Position Ushort ?
 KeysList charp ?       ; Yields keyword list
 ArgNum byte ?
 Desc byte ?            ; To find text of <Description>
 Hex byte Overlay
 Char byte ?
 Options charp ?        ; Msg 40.28
 OptsHi charp ?         ; Msg 40.28
 Digits word ?          ; Msgs 26.1 and 33.1  Don't overlay, zero meaningful.
 TokPos charp ?         ; Position of token within segment holding source.
 TokLen Ushort ?        ; Ushort although inserts have low limit length.
InsBlock ends

; "Interacting" is a bug for "Interactive" ?. Pad 8 makes byte offset zero.
LevelRec record Lpad:8,InheritDone:1,DigitsSet:1,IsProcedure:1,IsExternal:1,
    IsFunction:1,Lpad2:3

LevelRecI record LIPad:14,Interactive:1,ConditionInstruction:1
; Instruction.Condition and ConditionInstruction are the same value.

ConditionRec record Enabling:1,Delayed:1,PendingNow:1,Instruction:1,CRspare:4

Lshape struc; The elements of soft stack for invocations.
; The part inherited from the level above. (When there is one.)
 align 4; We move the inherited bit using doublewords.
  DigitsFuzz dword Overlay
  Digits Ushort ?
  Fuzz Ushort ?
  Form char ?
  StartTime qword ?
  TraceLetter char Overlay
  TraceWord word ?; LevelRecI <>.
  Active EnvBlock <>
  Alternate EnvBlock <>
  Syntax ConditionRec <>
  LostDigits ConditionRec <>
  NoValue ConditionRec <>
  NotReady ConditionRec <>
  Error ConditionRec <>
  Failure ConditionRec <>
  Halt ConditionRec <>
  TrapName word 7 dup(?)
  EventLevel word ?   ; Only used for Halt.
  Condition word ?    ; As CONDITION bif result(C)
  ConditionDescription Vshape <>; As CONDITION bif result(D)
  ConditionExtra Vshape <>; As CONDITION bif result(E)
 align 4; We move the inherited bit using doublewords.
  Inherit char Overlay; End of inherited.
 ClauseTime qword ?
 ClauseLocal qword ?
 PendingDescription qword ?
 PendingExtra qword ?
 LevelDO charp ?;  Level's CurrentDO held over call.
 StackSave Farp <>; To make save over DosExecute recursive.
 File charp ?     ; Save which external file is source when external call made.
 ProgScope Segp ? ; Saved values of constants, when external call.
 VarScope Segp ?  ; Saved values of variables, when external call.
 align 4
;The Lshape is normally addressed a few bytes ($StrideV) down from its high end.
 Access word Overlay; MASM gets confused if this is attached to the LevelRec.
 Flags LevelRec <>
 UpLevel charp ?; Invoker's block.
 Resume charp ? ; On return from invoke from here.
 Arg0 charp ?   ; Parameters to this invoke.
Lshape ends
 $StrideL equ size Lshape
; L. is for Lshape objects addressed by ss:[di+bp]; the level of the execution.
L is <(Lshape ptr[bp+di-$StrideL+$StrideV])>
; Lsi. is for Lshape objects addressed by ss:[si+bp]
Lsi is <(Lshape ptr[bp+si-$StrideL+$StrideV])>
; Lbx. is for Lshape objects addressed by ss:[bx]; the level of the execution.
Lbx is <ss:(Lshape ptr[bx-$StrideL+$StrideV])>

comment~ In a case like A.B.C=Ftn(D), evaluation of the tail B.C has to occur
after Ftn(D) because Ftn(D) might alter B or Vbxf. For the parser to generate
pseudo code that is in the right order, the whole symbol A.B.C is stacked from
the time when generation of the code for Ftn(D) is started until after.
Sometimes there are a multiplicity of targets to be held over (eg control
variables of nested DOs), but there won't be very many.

Combining the fields needed for the parsing check with the fields needed for
DO execution into one block, the stack movement at parsing mimics the
stack movement at run time. (At clause boundaries).
~
; LoopsRec is used only in Dshape.
;HasDot:1,      ; When DO X.=
;HasDots:1,     ; When DO X.Y =
;HasTo:1,
;HasFor:1,
;ByDown:1,      ; When control variable values are going down.
;IsInterp:1     ; When block is for INTERPRET, not DO.
LoopsRec record LoopsPad:2,HasDot:1,HasDots:1,HasTo:1,HasFor:1,IsInterp:1,
                ByDown:1; ByDown last - see use in CompareTo

comment~ about flags in the Zone.
The flags in ClauseRec & MiddleRec are for syntax and are reset at the start of
each clause.  So no problems at SIGNAL and external call times since those don't
happen in compiling and Raise yields termination at compile time.

Compile time flags that last for more than a clause are in ProgramRec and
GenRec.

The flags in CancelRec are the sort where a flag is set ON to condition some
later activity which uses Bit-Test-Reset. They turn out to be mostly
conditioning error activity and can be kept tidy by zeroing before SIGNAL or
external call.

That leaves one or two flags that apply to the execution of the current
file and so (along with other fields) need care at external calls.
~
; API_Enabled:1,   Controls "Variable Pool" interface.
; NoSource:1,      $5.10.11, but no need to implement.
; RandomSeeded:1,  Has the seed been initialized?
; NotS9:1,         Off if numerics are 9 digit SCIENTIFIC.
; The following are to do with compiling - they are off in execution.
; LabelsBad:1,     On when the compile is of text from INTERPRET.
; Repass:1,        When user overides Bif name.
; FirstBetween:1,  On when parsing should start with a Between call.
; EndSource:1,     Helps parser detect end-of-source.
; BifCheck:1,      Tells whether Bif check failed, for compile time .
; TraceIF:1,       Controls trace output.
; ShowELSE:1,      Controls trace output.
ProgramRec record API_Enabled:1,
   Repass:1,
   LabelsBad:1,
   FirstBetween:1,
   EndSource:1,
   BifCheck:1,RandomSeeded:1,NotS9:1,TraceIF:1,ShowELSE:1,PRSpare:6

; InTypes:2     What are the types of the input operand(s)?
; ResultType:2  Mark result on stack with its type.
; AppendNum:1   When opcode is followed by a number.
; AppendRef:1   When opcode (plus maybe number) is followed by a reference.
; DownOne:1     On if operator leaves stack down one on when it started.
; EndsClause:1  On if operator ends a clause. (Only for internal checks)
OperatorRec record InTypes:2,ResultType:2,AppendNum:1,AppendRef:1,DownOne:1,
                   EndsClause:1

; The Dtype byte is too complex to describe as individual flags. See equates.

comment~ The critical factor on data format is floating point.  If we want
default precision float to go in 8 bytes then there is essentially no option but
to have a doubleword integer mantissa and a doubleword integer exponent.  This
commits the meaning of all the bits except those next to the signs; parity of
left two bits will be zero for such numbers.  So data types other than
arithmetic at precision up to 9 will have odd parity at the left.  Rexx integer
is Rexx float with a zero exponent.

The 8 bytes are the "value" of the item; for extreme types the 8 bytes will
point to a string elsewhere.  The address of the 8 bytes is the address of the
item.  Arrays with these 8 byte elements are used for (1) the program scope
symbols, ie constants, labels and reserved symbols, and (2) the other symbols.
The index to these arrays is the symbol number.  Note that this number is
derived from the spelling of the symbol; the effect of PROCEDURE in introducing
scopes is achieved by having a different array for each level of procedure
invocation.
~
comment~ Jshape is for lookups where the keys are with the tree info. This is
the case for compound variables, as opposed to ordinary compile time lookups
where the key is in Symbols.  This Jshape is also used for SysFiles, (with
a preceeding Fshape.
~
Jshape struc
 Valued Vshape <>                  ; Will be addressable Vsid. and J.
 Pair dd 0 dup(?)                  ; Next two together.
 Lower Ushortp ?                   ; a subtree.
 Higher Ushortp ?                  ; a subtree
 KeyLen word ?                     ; Always a word of length. Chars may follow.
 Key char 0 dup(?)
Jshape ends
$StrideJ equ size Jshape
; J. is for Jshape objects addressed by [si]; To look up tails.
J is <(Jshape ptr[si])>
; Jbx. is for Jshape objects addressed by [bx]; To look up tails.
Jbx is <(Jshape ptr[bx])>
; Jdi. is for Jshape objects addressed by [di]; To look up tails.
Jdi is <(Jshape ptr[di])>

TokVal record  GrpNdx:6,SubNum:2; Shape of $name
TokRec record X02:1, NdxbT:5, Aim:10
KeyRec record KeyFlags:3,EndList:1, KeyLen:4
; Shapes for interpreting syntax tables. Ensure match with table generator.
ShiftRec record HasShift:1, ErrorAlone:1, CatFlag:1, HasKeys:1, Reference:1,
                Direct:1,Indexb:5, Index:5
ErrorRec record HasShiftOn:1, ErrorAloneOn:1, MajorField:8, MinorField:6
RedRec record HasShiftOff:1, HasAction:1, PruneCt:2, Rtype:2, Rstate:10
; Every element on the parser stack will have the same size but the contents
; are not always the same, except for State which is the reference state
; needed by the parser mechanism.  The other fields are used for error
; message data, and code generation.
; Field order of Sshape is sensitive, matched to pushes that create an item.
ParserRec record ParserPad:12,DoRep:1,DoCV:1,Forever:1,DoDataHost:1
Sshape struc
 State word ?
 Parser word Overlay
 ParserRec <>
; Some of these fields could logically be overlaid but they are not, so that
; logic is avoided in deciding what to push. (They are all pushed)
; Actually that applies to just ClauseWas.
 ClauseWas  word ?; Line number for message 10.n and 7.n
 union
  struct; This one for an operation. Element is made on basis that it is this.
   Token Ushort ?; Numeric coding of the operation.
   Operation dword ?; ASCII coding with length ahead, eg 3,">>=".
   Caller word ?; Resolved reference to what is to be invoked.
   Parms Ushort ?; To compute how many arguments there are.
  ends
  struct; This overlay for info on a SELECT structure. (Also IF & DO)
   JumpSite word ?; Records how Pcode jumps from WHEN test to WHEN test.
                  ; (Also used by IF-ELSE)
   SoFar charp Overlay; For TraceOnly
   WhatCV charp Overlay; Control variable identification.
   SelectSite word ?; Records how Pcode jumps from end of WHENs to end SELECT.
  ends
 ends
Sshape ends
; S. is for Sshape objects addressed by [si+bp]; the parser stack.
S is <(Sshape ptr[bp+si])>
$StrideS equ size Sshape
S1 is <(Sshape ptr[bp+si+$StrideS])>
S2 is <(Sshape ptr[bp+si+2*$StrideS])>
ParmsRec record ParmsMin:2,ParmsXtr:2,NonCheck:4
comment~  Flags for middle level tests.
  NotLabel:1,      On when labels not allowed.
  SemiAfter:1,     Invent token
  ValueBefore:1,   Invent VALUE
  AbutOK:1,        When state says it could be next.
  NoBlanks:1,      Relevant to implicit concat.
  ModEquals:1,     When = that is coming next is an assign.
  EndClause:1,     On when clause needs end-of-clause marked in Pcode.
  ImplicitValue:1, Possible implied VALUE
  CheckDO:1,       eg symbol with END.
  TargetSymbol:1,  On when symbol is a target of assignment.
  Function:1,      On when next '(' is part of function call.
  TakenConstant:1, On when next lookup is taken as constant.
  LookLabel:1,     On when next lookup will be label, eg CALL "abc".
  LookBin:1,       On when next lookup will be in tree for binaries.
  DotOK:1          On when '.' allowed (in template).
~
MiddleRec record NotLabel:1,SemiAfter:1,ValueBefore:1,
  AbutOK:1,NoBlanks:1,ModEquals:1,EndClause:1,ImplicitValue:1,
  CheckDO:1,TargetSymbol:1,Function:1,TakenConstant:1,LookLabel:1,
  LookBin:1,DotOK:1,MRspare:1

; More flags for clause level.
; NotAssign:1,     Off includes DO j=
; ClauseSet:1,     On when ClauseLine set.
; Tailed:1,        Tells Lookup that compound name is on stack.
; WasTailed:1,     Last Lookup was of tailed.
; WasUpper:1,      Remembers UPPER option on PARSE.
; OffFlag:1,       Remembers OFF of CALL OFF.
; Condition:1,     Remembers there was a condition on CALL ON or SIGNAL ON.
; Append:1,        Remembers there is APPEND during ADDRESS.
; Signal:1,        Remembers when the verb was SIGNAL
; CVar:1,          Remembers when there is a control variable on DO.
; Repit:1,         Remembers when there is repetition part in DO.
; PosEq:1,         Grouped with PosPlus & PosMinus - triggers in PARSE.
; InParse:1,       On during Parse instruction. (Off when escape)
; WasParse:1,      On during Parse instruction.
  ClauseRec record WasUpper:1,OffFlag:1,Condition:1,Append:1,Signal:1,
  ClauseSet:1,CVar:1,Repit:1,PosEq:1,NotAssign:1,
  WasParse:1,InParse:1,Tailed:1,WasTailed:1,
  PosPlus:1,PosMinus:1; Using 5-gap of PosEq and PosPlus.

; Format5:1,       On for FORMAT bif with five args.
; AssignDO:1,      On when assignment is for DO.
; ForExpose:1,     On while executing EXPOSE.
; FromIterCV:1,    Used when DO loop execution has dotted control variable.
; ForBIF:1,        TargetMsg without expanding inserts. Needed for ERRORTEXT.
; TokIsValue:1     Conditions error message insert.
; ExpRange:1,      Number failure due to exponent oversize.
; Description:1,   Used in msg production.
; Compacted:1,     Used to detect a loop within Compaction.
; BcodeInterpret:1, On when INTERPRET executing on behalf of Bcode.
; MapOnly:1,       Used by Debug for when to fill allocations.
; ParseUpper:1,    On when PARSE has UPPER, in execution.
; ParseTrace:1,    On when PARSE tracing, in execution.
; SourceFiles:1, On when source files rather than ordinary data files relevant.
; BoolBefore:1,    On to prevent code generated for trace making undue prefix.
; WasDropped:1     On to tell us that last load of variable found it dropped.
CancelRec record Format5:1,AssignDO:1,ForExpose:1,FromIterCV:1,
 ForBIF:1,TokIsValue:1, ExpRange:1, Description:1, Compacted:1,
 BcodeInterpret:1, MapOnly:1, ParseUpper:1, ParseTrace:1, SourceFiles:1,
 BoolBefore:1, WasDropped:1

; Dual:1,          On when the purpose of compiling is clause by clause run.
; DualPending:1,   On when DualGen is to be set later.
; DualGen:1,       On when Pcode for trace events is being made.
; DualOnly:1,      On when Pcode for Dual differs from original.
GenRec record Dual:1,DualPending:1,DualGen:1,DualOnly:1,
 GenSpare:12

; Experience may show how many allocations the Dos space will be in.
$Ashapes equ 10
comment~ Segments for differing purposes will need different fields but some
things can be done to unify.  Each segment has a Segp field in the zone and
these form an array so that compaction can find them easily.  Each segment
itself has an Hshape header field which has a link back to the Segp field.

~
; Shortest code for addressing Header fields is varied. If mov with ax, then
; 2-byte offset is reasonable because there are dedicated opcodes. Else it
; will usually pay to specify indexing with a zero-value index because that
; uses a one byte offset. The index can be bp when there is segment override.
; Otherwise it may pay to zero si especially for the purpose.
Hshape struct
 Hdw0 dword Overlay; This and next dword used when making a copy of a segment.
 SegSize Ushort ?  ; Bytes including our header.
; The segments for different purposes need different subsets of these fields.
; They all need SegSize because Compaction uses it.
; The stack segment needs only SegSize because it has its own routine for
; expansion on demand.
; The pool-type segments only need SegSize&Bump; their size changes only when
; the relevant Vars or Consts segment changes size.
 Bump Ushort ?   ; Number of new bytes added each expansion
; Things that grow independently (Symbols, Vars, Consts, SysFiles, and each
; compound variable) need Avail and Trigger.
 Avail Ushort ?  ; Place, below Trigger, for new-stuff-at-end.
 Trigger Ushort ?; Limit before extension.
; Link identifies the type of segment and allows Zone updates.
 Link Ushort ?   ; To find slot in Zone that addresses this segment.
 TreeBin Ushort Overlay ; Field reused in the constants lookup segment.
 Original Ushort Overlay ; Field reused in the Pcode segment.
                         ; (End of original Pcode.)
 UpPool Segp ?   ; When segment is a pool. (Also used as chain of free ones)
 Probe Ushort ?  ; Place to start search if this is a lookup type segment.
 TreeProg Ushort Overlay ; Field reused as root for source file names lookup.
 Labels Ushort ? ; Alternative needed since label and constant trees same seg.
Hshape ends
$StrideH equ size Hshape
; H. is for Hshape objects addressed by [si]; Headers on segments (si=0).
H is <(Hshape ptr[si])>
; Hd. is for Hshape objects addressed by ds:; Headers on segments.
Hd is <(Hshape ptr ds:[0])>
; He. is for Hshape objects addressed by es:[bp]; Headers on segments.
He is <(Hshape ptr es:[bp])>
; Hf. is for Hshape objects addressed by fs:[bp]; Headers on segments.
Hf is <(Hshape ptr fs:[bp])>
; Hg. is for Hshape objects addressed by gs:[bp]; Headers on segments.
Hg is <(Hshape ptr gs:[bp])>

; Zshape is resized by StackSafe, not by MoreSpaceEs, so doesn't need all
; the Hshape header. It does need SegSize in correct location though because
; Compaction treats it like a headed segment.
Zshape struc
 w word Overlay       ; Not used in this position - always used like Z.w[index]
 SegSize word ?       ; Bytes.
 ProgramCancel dword Overlay; Used for zeroing.
 Program ProgramRec <>; Program flags
 Cancel CancelRec <>  ; Flags for transient logic.
 Stack word ? ; Current variable for Compaction. (Top of soft stack-$StrideV)
 ClauseLine Ushort ?  ; Line this clause starts on. (First token)
 Middles MiddleRec <> ; Extension of Clause. Keep with Clause for zeroing.
 Clause ClauseRec <>  ; Compile time clause flags
 Gen GenRec <>        ; Flags for control of what gets compiled.
 KWMiddle charp ?     ; List of search keywords.
 KWFound Ushort ?     ; Latest keyword found.
 Stdout Handle ?      ; A constant but potential redirection.
 Stderr Handle ?      ; A constant but potential redirection.
 SourceHandle Handle ?
 HowInvoked Ushort ?  ; Length of COMMAND/FUNCTION/SUBROUTINE.
 Radix byte ?         ; Normally has value 10.
 AxAsNum char 6 dup(?); For result of Ax2DsSiCx
 Tag char 5 dup(?)    ; For trace. Joined to AxAsNum
 Seed dword ?         ; For Random bif.
 ParseResetSp charp ? ; Where the parser started work on the hard stack.
 XCycleResetSp charp ?; Where the execution started work on the hard stack.
 Dumper word ?        ; Handle when we are writing Pcode to disk.
 Stash word ?         ; Various
 Resolved charp ?     ; Result of Lookup.
 Cursor charp ?       ; Offset into code. (Compile time)
 Stream charp ?       ; The current stream.  In SysFiles segment.
 Queue  charp ?       ; The FileBx for CRXREXX.QUE in SysFiles segment.
; Compaction exploits these Segp things being adjacent.
 InsSource dword Overlay
 SysFile dword Overlay
 File charp ?         ; Current external file of source.
 SysFiles Segp ?      ; DOS interface
 Consts Segp ?        ; To an array, fixed size per constant.
 Vars Segp ?          ; To an array, fixed size per variable.
 ProgScope Segp ?     ; Shadow of Consts. Order is exploited, see MoreSpaceEs.
 VarScope Segp ?      ; Shadow of Vars.
 Symbols Segp ?       ; To a write-once for names and constants.
 Code Segp ?          ; To the internal code.
 Zone Segp ?          ; Convenient place for Compaction to find address.
; End of section organised for Compaction.
 Stem Segp ?          ; Used when a stem wants MoreSpaceEs.
 PoolPool Segp ?      ; Spare VarScope copies.
 Level charp ?        ; Latest level of invocation.
 Base0 charp ?        ; Parser time, for checking how many operands pushed.
 CurrentDO charp ?    ; Junction of DO blocks and stacked values.
 ResumeP word ?       ; Save Pcode address while Bcode execution.
 ResumeDF dword Overlay
 ResumeD word ?       ; Digits() preserved over Bcode execution.
 ResumeF word ?       ; Fuzz() preserved over Bcode execution.
 ResumeS char ?       ; S/E mode preserved over Bcode execution.
; Section set by ZoneNumerics.  (cf NotS9)
 DigitsFuzz dword Overlay
 Digits Ushort ?      ; Current digits().
 Fuzz Ushort ?        ; Current fuzz().
 Ceiling dword ?      ; 1eN where N is current digits().
 DivBreak dword ?     ; To test for enough digits made in division.
 TwiceDigits dword ?  ; 2*N where N is current digits().
 UseGeneral Ushort ?  ; On for mandatory use of ArithGeneral
; end section set by ZoneNumerics.
; Inserts for messages are divided into (a) those that stay constant or which
; we always want to set when compiling, and (b) those that might be undesirably
; changed when we rescan during execution to find the line number for a message.
; The latter are in a block for save/restore.
; "Ins..." is used as help to identify.
 InsLine Ushort ?     ; Value for insert
 InsBif byte ?        ; Bif offset.
 InsOperator dword ?  ; Actual chars.
 InsUnqual charp ?    ; Offset in SysFiles. For <source> insert, msg 43.1
 Insert InsBlock <>   ; For message. The saved copy is Inserts.
 Inserts InsBlock <>
[ Execute
 SignM byte ?         ; Of mantissa
 SignE byte ?         ; Of exponent
 MantPos charp ?      ; Where mantissa starts.
 MantPosZi charp ?    ; Beyond end
 ExpPos charp ?       ; Where exponent starts.
 ExpPosZi charp ?     ; Beyond end
 ExpSign word ?
 MantSize word ?
 OpIs byte ?          ; Remembers operator in execution of it.
]
[ Bifs
 Flags byte ?         ; In BifTypes
 BifParmsHi byte ?    ; For Bifs to test how many parameters on instance.
 BifByte byte ?       ; Combines bif number and a parms count.
]
; Trace section
 TraceAlign dword ?; Beginning of line of source as offset on source file.
 TraceSource dword ?; Beginning of section of source to be shown.
 TraceEnds dword ?; End of section of source to be shown.
 TraceSourceColumn word ?
 TraceEndsColumn word ?
 DualCode charp ?; Beginning of Pcode for one clause.
 TraceOp byte ?   ; Trace info for current Pcode operation.
 Relative dword ?; Adjustment between position on file and position in buffer.
 RelativeNow dword ?; Used when Serial contains section of source.
 Continue word ?; Pcode offset of next clause.
 StackX word ?; Hold StackDi over parsing.
 TraceLine word ?; Last shown ClauseLine.
 InhibitTrace dword ?
 InhibitPauses dword ?
 Target word ?; Used to carry branch value from original pcode to dual.
; Trace section end
; Main also [ Tokens
   Scanp charp ?        ; Where the scan has reached. Zero when executing.
   EndUsedBuffer charp ?; Where marker to interrupt scan is placed.
   NearEnd charp ?      ; Towards end of buffer.
;]
[ Tokens
   CatOp byte ?         ; $pCat or $pAbut
   RadixBadWhite byte ?
   BackExponent charp ?
   LastContent charp ?
   CommaLine word ?; NonZero if previous line ended with non-continuation comma.
]
[ Pcode
   Condition Ushort ?   ; Latest condition keyword.
   UntilPlace Ushort ?  ; Place in Pcode. Held just over UNTIL expression.
   StemSym charp ?      ; Temp for A.B.C type Lookup
   SoFar word ?         ; Temp for A.B.C type Lookup
   PcodePos word ?      ; Used by ConstValue
   TraceOnly word ?     ; Used to detect 'trace only' labels.
]
 CompareAt word ?       ; For detecting compare Pcode optimizing.
 StackHi charp ?        ; Used for compound lookup.
 StackLo charp ?        ; Also for function arguments.
 OnSoft charp ?         ; Where stacked target symbols start. PARSE compiletime.
                        ; Tokens tells Pcode.
 Tail charp ?           ; Work when Pcode made for tailed.
 TokNum word ?          ; As tokenizer makes, parser sees.
 TokNow word ?
 TokWas word ?
[ Syntax
   TokData word ?       ; Data for parser derived from TokNum
]
   Synch charp ?        ; Instruction pointer, into Pcode, for synching.
   Lines Ushort ?       ; Count of lines
[ Msg
   MsgBegin charp ?     ; Where sub-messages concatenated.
   MsgSoFar charp ?     ; As sub-messages concatenated.
   PreZi charp ?        ; End of message before expanding insertions.
   TargetMajMin word Overlay; This is message being output.
    TargetMinor byte ?
    TargetMajor byte ?
]
   struc                ; See DOS command 4Bh
    EnvSeg Segp ?
    ForPSP Farp <>
    Fcb1 Farp <>
    Fcb2 Farp <>
   ends
   AtPause charp ?       ; NYI
   ArgsB byte ?; For Arg() of BCycle bif.
   ArgsB0 charp ?; For Arg(exp) of BCycle bif.
; Workspace for the verbs can be shared.
   struct; For Parse
    Parsee FarpX <>
    ParseeNum Ushort ?; Counts arguments for commas in parsing template.
    PattLenEtc Ushort ?  ; Length of pattern. Temp for cursor.
    BreakStart charp ?; Beginning of previous section delimiter.
    BreakEnd charp ?  ; End of previous section delimiter.
   ends
   EnvNow EnvBlock <> ; Used to execute ADDRESS
 CatTotal word ?      ; Used by Abut$$ & Cat$$
 LastTarget word ?    ; For detecting when to make $pUnstore.
 NewJshape charp ?    ; Used by FindKey.
 FromDos charp ?; A slot addressing a segment DOS gave us. (Cat optim. uses)
[ Memory
 FromDosWas word ?; To test for cycled through them.
 FromDosZi charp ?; Bound for FromDos
 MemoryTable Ashape $Ashapes dup(<>)
 MemoryTableZi byte Overlay; Just used as an offset.
 Left charp ?     ; For compaction.
 Right charp ?    ; For compaction.
 AllocBase dword ?; For compaction.
; Grouping matters here.
 DsWas Segp ?
 DsNew Segp ?
 EsWas Segp ?
]
 EsNew Segp ?     ; Sometimes reloaded from.
[ Memory
 FsWas Segp ?
 FsNew Segp ?
 GsWas Segp ?
 GsNew Segp ?
]
if Debug
 DebugStash word ?
 DebugD dword ?
endif
 DigitCount Ushort ?  ; Checking radix string, Compile and execute.
; Byte before Serial better not accidentally look like $Eof.
 SerialNow byte ? ; Indicates what is in Serial.
 Serial char $SourceBufferSize dup(?)
 align 4
 CommandArg Vshape <>; Parameters from Command line.
Zshape ends
; Z. is for Zshape objects addressed by [bp]; the Zone
Z is <(Zshape ptr[bp])>

Yshape struc
 dword ?; Overlays jmp.
 N1 dword 1
 N10 dword 10
 N100 dword 100
 N1000 dword 1000
 N1e4 dword 10000
 N1e5 dword 100000
 N1e6  dword 1000000
 N1e7 dword 10000000
 N1e8 dword 100000000
 N1e9 dword 1000000000
 N1664525 dword 1664525; For Random
 Assert $Limit_ExponentDigits eq 9
 ExponHi dword 1000000000-$Limit_Digits
 ExponLo dword -1000000000+2
 Cseg Segp ?          ; To be where the machine code is.
 DOS dword Overlay; Default ADDRESS
  db "DOS "
 DosPool db "ENVIRONMENT"; Pool name
  db "..."; Joined to following CrLf
 DqCrLf db '"'
 CrLf db 13,10
 StackSave Farp <>    ; To recover when only CS:IP survives.
Yshape ends
; Y. is for Yshape objects addressed by [bp]; the constants.
Y is <(Yshape ptr cs:[bp])>
Ycx2 is <(Yshape ptr cs:[2*ecx+ebp])>
Ysi is <(Yshape ptr cs:[si])>

; These equs should follow the declares of shapes they depend on.
$SizeConstsHeader equ $StrideH+4
; Configuration variables (used by the implementation but not seen by the user's
; program) are in the order the utility that makes Bcode has numbered them. The
; $Reserved string matches.
; Also constants & reserved variables that are always in ProgScope area.
$?Omitted equ $SizeConstsHeader
$?MN equ $?Omitted+$StrideV
$?RS equ $?MN+$StrideV
$?RESULT equ $?RS+$StrideV
$?RC equ $?RESULT+$StrideV
$?SIGL equ $?RC+$StrideV
$?SysVars equ $?SIGL+$StrideV
; See $Reserved for number of vars here.
$SysCount equ 11
?OUTCOME equ 0; These are the numbers used in Bcode references.
$?OUTCOME equ $?SysVars; These are the offsets used in machine code references.
; ie where the system variables are in the ProgScope segment.
?BIF equ 2ú$?BIF equ $?SysVars+$StrideV
?STREAM equ 4ú$?STREAM equ $?SysVars+2*$StrideV
?STREAMSTATE equ 6ú$?STREAMSTATE equ $?SysVars+3*$StrideV
?RESPONSE equ 8ú$?RESPONSE equ $?SysVars+4*$StrideV
?LINEIN_POSITION equ 10ú$?LINEIN_POSITION equ $?SysVars+5*$StrideV
?CLAUSETIME equ 12ú$?CLAUSETIME equ $?SysVars+6*$StrideV
?CLAUSELOCAL equ 14ú$?CLAUSELOCAL equ $?SysVars+7*$StrideV
?MONTHS equ 16ú$?MONTHS equ $?SysVars+8*$StrideV
?WEEKDAYS equ 18ú$?WEEKDAYS equ $?SysVars+9*$StrideV
?STARTTIME equ 20ú$?STARTTIME equ $?SysVars+10*$StrideV
$?Nine equ $?SysVars+11*$StrideV
$?Zero equ $?Nine+$StrideV
$?Null equ $?Zero+$StrideV
$?E equ $?Null+$StrideV
$?S equ $?E+$StrideV
; These are variables that are always in current VarScope area.
$?Discard equ $StrideH; Takes two because ends in dot.
$?RESULTx equ $?Discard+2*$StrideV
$?RCx equ $?RESULTx+$StrideV
$?SIGLx equ $?RCx+$StrideV
; Not in the table, but we need to use some character as an end-used-buffer
; mark. (Saves checking address repeatedly) Using Linefeed helps comment scan.
$EndBuffer equ $Lf
$Whole     equ 0
$WholeGE   equ 4
$WholeGT   equ 8
$Num       equ 12
$M090      equ 16
$WholeNum  equ 20
$Pad       equ 24
$Hex       equ 28
$Stream    equ 32
$Bin       equ 36
$Symbol    equ 40
comment~  Some fields not necessary:
 By XLAT test #ALLBLANKS
 #BIF
  Only used in SourceLine #SOURCELINE.
  Coming from startup.
  Need to do Stream record including #LINEIN_POSITION.  #STREAMSTATE.
 #LINENUMBER was just for SELECT and SIGL
 #TIME
 #ADJUST
 #OUTCOME
 #RESPONSE
 #TEST
 #INDICATOR
 #RC
 #VALUE
  A constant #CONFIGURATION
  A constant #VERSION
 #SOURCE by InsSource
~

AllocAppend macro Goes:req
 push si
 mov si,Z.FromDos; The current allocation source.
 mov ax,A.Fr.Ptúsub ax,V.Lenúcmp ax,V.Ptújne Goes
; Here if offset fits. Also need to check same segment.
 mov ax,V.Sgúcmp ax,A.Fr.Sgújne Goes
 mov es,ax
; The segment could be full, but if possible take the extra.
 mov ax,V.Ptúadd ax,cxújc Goes
 cmp ax,A.Amountúja Goesúmov A.Fr.Pt,ax
 sub ax,cx
 mov V.Len,cx
 endm
; Here are the numbers which go in the Attributes table.
; Most of this is just for compiling but some equates are relevant to
; execution so those have been put in declares.inc
; First two bits for quick test of Whitespace, Letter, Digit, Special
; $White equ 0 $Digit equ 64 $Letter equ 128 $Special equ 192
; When it is not Special, the remaining bits can be flags.
; When it is Special, there is a switch indexed by the rest of the byte.
; This corresponds to the right six bits of TokVal so we can test in groups.
; In practice it is "+ or -" that gets tested this way.
 $Group equ 0FChú$PlusMinus equ $AttribPlus and $Group
; The bits to the right of $White are free, and we could distinquish the
; reak blank from blank equivalents but there seems no reason to do so.
; We are short of a bit for letters. It would be nice to have flags for
; conveniently testing "Ee", "Xx", "Bb", "01", ok as hex digit, having upper
; case, and real-letter, as well as $Letter for the purposes of a symbol.
; Something has to be left out, and real-letter would only be used in
; DATATYPE().
; We are short of a bit for digits. It is highly desirable to be able to scan
; a number using lods and not have to refer to the value before xlat (since
; xlat overwrites al). So we would like to have the value of the digit in the
; low order of the attribute, as opposed to subtracting character '0' from the
; raw character. That leaves two, which gives us difficulty if we want
; OK-for-radix-B, OK-for-radix-X, and a Lower-case-letter. (Since we would
; like to test the latter in the symbol recognition loop without distinquishing
; letter/digit first.)
; The solution seems to be to invert the lowercase flag. Then with blanks and
; specials out of the way (jpe), the upperableness can be tested as zeroness
; of Digit flag and NonUpable flag, together.
; So the scheme for Letter-or-Digit is to make the right nibble dependent on
; whether letter or digit, leaving two bits for OK-for-radix.
 $OKb equ 32ú$OKx equ 16
; For letters:
; $NonUpable equ 8 $Bb equ 4 $Xx equ 2 $Ee equ 1
; $Lowercase equ $Digit+$NonUpable; Use jnz avoiding uppering.
; These values above $STRING go through switching like specials but are not
; seen by the parser.
$LineFeed equ $Eq-4
$Invalid equ $UnAccept+1
$Colon equ $UnAccept+2
$AttribAnd equ $Special+$And
$AttribOr equ $Special+$Or
$AttribEq equ $Special+$Eq
$AttribMinus equ $Special+$Minus
$AttribLt equ $Special+$Lt
$AttribGt equ $Special+$Gt
$AttribSlash equ $Special+$Slash
$AttribComma equ $Special+$Comma
$AttribLine equ $Special+$LineFeed
$AttribPlus equ $Special+$Plus
$AttribStar equ $Special+$Asterisk
$NoMatch equ $Special+63; No character has these attributes.

