;;Copyright Formcroft Ltd 1997
; The .model directives didn't seem to have a way to get PARA alignment,
; so SEGMENT directives are better but CodeView confused by those.
 .model small�.486�.code
 option nokeyword:<C>
;------------------------------------------------------------------------------
; Module main has the entry point and initializing for the processing.
;------------------------------------------------------------------------------
 PUBLIC TraceEvent$$
 PUBLIC TraceEventX

 EXTERN ExitDOS:near
 EXTERN Raise34p5:near
 EXTERN Raise34p6:near
 EXTERN Raise33p1:near
 EXTERN Raise33p2:near
 EXTERN Raise33p3:near
 EXTERN Raise26p5:near
 EXTERN Raise26p6:near
 EXTERN AfterCheck:near
 EXTERN PcodeBif:near
 EXTERN Bswitch:near
 EXTERN ARITHOP$$:near
 EXTERN LINESPLIT:near
 EXTERN Bassign:near
 EXTERN TargetMsg:near
 EXTERN Interpret1:near
 include always.inc; Assembler shorthands like 'Bptr' for 'byte ptr'.
 include declares.inc; Symbolic constants, macros, records, structures.
 Assert 1 shl $ShiftV eq $StrideV
 Assert $StrideL eq Lshape.Access+$StrideV
comment~
The interpreter loop fans-out by using the opcode taken from the pseudo code as
an index to a set of labels.  (The labels are Say$$, Exit$$, etc; around 100 of
them.) One or two of the spokes of this fan-out reach builtin function
processing where they fan-out further.  (The labels are BifABBREV, BifSUBSTR
etc.) The parser fans out from one point in its cycle according to the state.
(The labels are Action1, Action2, ...  and correspond to recognition like
"beginning of argument list", "end of DO group" and so on.) The actions produce
all the pseudo code.

The recovery point is label Raise.  Rexx SYNTAX errors, compile time and
execution time, may be detected by this code when the code has done 'push' and
'call' hardware instructions.  Rather than unwind the hardware stack to report
the Rexx error, a jump is made to Raise.  Raise will reset stacks and decide
how processing is to continue.
~
if Debug
DosMemCheck:
 push ds�pusha
; PSP ahead of code. A DOS header on that to start links.
 mov ax,cs�sub ax,10h�mov bx,ax�dec ax
DMC:mov ds,ax
 cmp Bptr ds:[0],'M'�jne DMCz
 cmp Wptr ds:[1],bx�je @F
; We also use this after giving some back to DOS.
 cmp Wptr ds:[1],bp�je @F
 int 3
 Error49Bp
@@:add ax,Wptr ds:[3]�inc ax�jmp DMC
DMCz:cmp Bptr ds:[0],'Z'�je @F�int 3�@@:
 popa�pop ds�ret
endif

;------------------------------------------------------------------------------
; This is the entry from a command line invocation. Only the code is available.
;------------------------------------------------------------------------------
Startup:; ebp zero for si+bp di+bp addressing modes, and general source of zero.
 cld�xor ebp,ebp�mov Y.Cseg,cs; For easy comparison.
; Give up if there isn't enough space to control giving a message.
 mov bx,$InitStackSize/16�mov ah,$DosAllocate�int 21h
; AL only becomes return code of the command, so only major part of msg number.
 jnc @F�mov al,5�jmp ExitDOS�@@:
; Change stack to use allocated space.
 mov ss,ax; Hardware prevents interrupt here.�mov sp,$InitStackSize
if 0
; Return to DOS the stack space of Startup, and space above it.
 mv es,cs�mov bx,(StartupStack+256+15)/16
 mov ah,$DosModifyAllocated�int 21h
endif
 push ds; Now ss:bp addressing the Zone. ds is Dos Program Segment Prefix
;------------------------------------------------------------------------------
; Here is the once-only Zone initialization.
;------------------------------------------------------------------------------
if 1
 mov al,0�mov cx,(sizeof Zshape)�z di�mv es,ss�rep stosb
endif
; !! Stderr really 2 but we want redirection.
 mov Z.Stdout,1�mov Z.Stderr,1�mov Z.Radix,10
 mov Z.Tag,' '�mov Z.Tag+4,' '�z Z.SerialNow�z Z.Scanp
 z Z.Insert.Digits
 z Z.LastTarget
 z Z.Level
 mov Z.Stack,Zshape.CommandArg
; Size of stack can be changed later, so keep track within it.
 mov Z.SegSize,$InitStackSize�mov Z.Zone,ss
 z Z.ProgramCancel�z Z.Gen
 call InitMemory; Acquire from DOS for our allocations.
; Initialize the compound variable used for interfacing with Dos.
 mov cx,256�mov bx,cx�mov SegOffDi,Zshape.SysFiles�call InitSegDs
; It will be extended like an ordinary compound.
 mov Hd.Link,Zshape.Stem
if CD
 call Create4Dump
endif
; Scan the command line parameters.
; Put line as a Rexx variable on the stack. (Above item for the command args)
; Length of parameters is at 128 in PSP.
 pop ds�call UpStack�mov si,128�lodsb�movzx cx,al�call VasDsSiCx
; Use a routine (compiled from Rexx at build time) to divide that into
; the filename to be invoked and the parameter for that invokation.
; The latter returned to Z.CommandArg and the former on the stack.
 mov Z.ResumeP,si; Any non-zero to tell LinkBcode "not a call from Pcode".
; We have no level block yet, but the Bcode will do arithmetic and access
; the Zone fields normally set by taking Digits() etc from the level block - see
; ZoneNumerics.
 move Z.Ceiling,Y.N1e9; Will be enough for now.
 mv gs,cs�mov dx,offset LINESPLIT�call LinkBcode�mov Z.Stack,StackDi
if MemCheck
 call DosMemCheck
endif
 jmp Command

comment~ The parser is used to make Pcode for the original source and for
INTERPRET both as clause and interactive input.  The parser is also used in
non-producing mode to position on the source so that line number for SIGL, and
source for TRACE are deduced from Pcode offset Z.Synch. This is called a Synch.
The compiler is also used clause-by-clause to make another version of Pcode when
tracing.

There is similar processing for variable lists in DROP and EXPOSE, but these are
done using NextToken and Action0, without the parser.

~
;------------------------------------------------------------------------------
; Once (fast-form) Pcode has been satisfactorily made from the source file, it
; is retained.
;------------------------------------------------------------------------------
Compiler:; Parsing/Generating is done by using Cycle as a subroutine.  The
; linkage mechanism is a jmp, after recording SP and normal-return.  This allows
; easy transfer to Raise if parsing finds an error.
 z Z.Synch; Non zero when not making Pcode.
 z Z.TraceOnly
 mov Z.Cursor,$StrideH; Where to start putting new Pcode.
 call Compiling

; When a Bif name is used as a label, it can be necessary to start all over
; again on the source. The array for constants is not reset (that is where
; the fact of labelness was recorded) and there is no reason to reset the
; segments for variables and symbols. The Pcode is reset because it is that
; new code the repass is for.

 btr Z.Program,Repass�jnc OnePass
; For a repass we need to leave all the labels that turned out
; to be non-bif (even if spelled as a bif) marked as non-bif.
; (But not in a usual way or the second pass will see them as
; duplicated labels.)
 mov ds,Z.Consts�mov ArrayBx,$SizeConstsHeader
 mov ProgEs,Z.ProgScope
RepassB:
 cmp Vbxe.Dtype,$Label�jne @F
 mov ax,Vbxe.LabelValue�TestReg ax�jz @F
 cmp ax,$BifBase�jae @F�mov Vbxe.LabelValue,1�@@:
 add ArrayBx,$StrideV�cmp ArrayBx,Hd.Avail�jb RepassB
; Pcode will be remade.
 mov Hg.Avail,$StrideH
 jmp Compiler

OnePass:move Hg.Original,Hg.Avail; Limit of Pcode from original file.
; Maximum line number determines the width of the number on trace.
 lds bx,Z.SysFile�movzx eax,Z.Lines�dec eax�mov F.Lines,eax
 z cx�mov si,Yshape.N10-4
@@:add si,4�inc cx�cmp ax,Wptr cs:[si]�jae @B
 mov F.TraceWidth,cl
; Best to close source since number of externals may exceed supply of handles.
if 0
 mov bx,Z.SourceHandle
 mov ah,$DosClose�int 21h
endif
;2011 New build flag
if ForBcode eq 1
if CD eq 0
 call Create4Dump
 call Dumper
endif
endif

StartExecution:
 mov CursorSi,$StrideH; Pcode position to start execution.
 mov Z.XCycleResetSp,sp
StartExecutionY:
 mov ProgEs,Z.ProgScope
 mov fs,Z.VarScope
 mov gs,Z.Code
 jmp XCycle

 include trace.inc
 include debug.inc; Code that will be omitted after debugging.


StartupStack:
.stack
 end Startup
