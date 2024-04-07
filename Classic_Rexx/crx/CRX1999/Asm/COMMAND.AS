; Copyright Formcroft Ltd 1997-1999
 .model smallú.486ú.code
 include always.inc; Assembler shorthands like 'Bptr' for 'byte ptr'.
 include declares.inc;

 PUBLIC Command$$; For bcode section of FanSeg

 PUBLIC Address$$
 PUBLIC EnvName$$
;EXTERN Abut$$:near
 EXTERN COMMANDWRAP:near ; 2011

; ADDRESS is executed by first noting things, then acting at Address$$.
; The opcode that follows STEM, and STREAM codes will tell about
; INPUT/OUTPUT/ERROR/APPEND
EnvName$$:
; Upper to do!!
; Only command we have is "DOS"
; Easier if put in reserved?
 cmp Bptr(V.Dtype),$NullString+3újne @F
 mov Bptr(V.String+3),' '
 mov ecx,Dptr(V.String)
 cmp ecx,Y.DOS
 jne @Fúinc bhú@@:
 mov Bptr Z.EnvNow.EnvNumber,bh
; Keep something on stack so Address$$ knows.
 BackRet

Normal$:inc bh
 Up; Mock parameter.
Stem$:inc bh
Stream$:push StackDi
 lodsb gs:[CursorSi]
 or bh,al; For flags about resources.
 and al,-4; Leaving offset part.
; Note offset of field of Z.EnvNow
 movzx di,al
 test bh,2újnz Normal
; Pick up Stem/Stream constant offset.
 mov ax,gs:[CursorSi-3]
 and bh,3
 or al,bh
; Fill field of Z.EnvNow
@@:mov Zshape.EnvNow[bp+si],ax
 pop StackDi
; Don't need value loaded, only the constant it was.
 Down
 ret

Normal:z axújmp @B

Command$$:
; We also use this one for just loading the value of a symbol to the stack.
 Qry Z.Cancel,BcodeInterpretújz @F
; See B4VALUE1
; We can't just leave it there on stack because return from routine will
; lose it, so make a copy.
 Move Ve[$?OUTCOME],VúDownúBackRet

@@:cmp Z.ResumeP,ZeroBpúje @F
; The other use in Bcode is from LINESPLIT.
 Move Z.CommandArg,VúDownúBackRet
ComSpec db "COMSPEC=",0
@@:; Here with the user's commands.
; 2011 The above would be done better with extra opcodes.
; Not much to do with ANSI but child-process should work.
; External routine name gets passed as  ASCIIZ in ds:dx
; "Command Tail" by far pointer in the block.
; So find COMSPEC= in current environment and invoke another instance
; of the shell, passing what user wants done as the command tail.
 push CursorSi
; 2011 DOS can tell us the active environment.
AddressB:
; Use the current = parent segment.
 mov ah,$DosPSPúint 21h; bx segment for current Program Segment Prefix
 mov Z.Fcb1.Sg,bxúmov Z.Fcb2.Sg,bx; See need later.
 mv ds,bxúmov ax,ds:02Chúmv es,ax; es:0 now the environment string.
; Caseless compare with COMSPEC=
 z si
ComStart:lea bx,ComSpec
; Always there somewhere.
ComProgress:
 mov ax,Wptr es:[si]úcmp ax,ZeroBpújne @fúError49Bpú@@:
 inc siúcmp al,'='úje @f
 and al,0DFhúcmp al,Bptr cs:[bx]újne ComStartúinc bxújmp ComProgress
@@:cmp al,Bptr cs:[bx]újne ComStart
; si now at comspec value.
 push es; Over Abut and GiveDosMem. ES in area never seen by us.
 push si

; Build block that says Command.exe to be run.
; The arguments block for the execute interrupt has a segment value
; and three far pointers. See EnvSeg in Zone.
 z Z.EnvSeg ; Says that child inherits.
; FCBs are not used but better have some tolerable addresses.
 mov Z.Fcb1.Pt,005Chúmov Z.Fcb2.Pt,006Ch

; One of the far pointers is to the "Command Tail"
; Use Bcode to wrap the user's string as [count] /c ... newline.
 mov dx,offset COMMANDWRAPúcall LinkBcodeúmov Z.Stack,StackDi
 call GiveDosMem; No need for us to get more before the interrupt.
 call ToDsSiCxúmov Z.ForPSP.Sg,dsúmov Z.ForPSP.Pt,si

; es:bx points to the block. ds:dx to the loadee. (command.exe here)
 pop dx; Was pushed as si
 pop ds; Was pushed as es.
 mv es,ssúlea bx,Z.EnvSeg
 mov ax,MkMajMin($DosExecute,0)úint 21h
 jnc @f; 2011
 int 3
@@:; Recover our context.
 xor ebp,ebp
 sub Z.Stack,$StrideV
 mov StackDi,Z.Stack     ; NYI need to reword 'cos EnvName on stack sometimes.
 mov ProgEs,Z.ProgScope
 mov fs,Z.VarScope
if MemCheck
 call DosMemCheck
endif
 mov ah,$DosReturnCodeúint 21h
 pop CursorSiúBackRet

TrivCom db "TRIV.COM"
TrivCom0 db 0

Address$$:
; No arguments case means swap the contexts in this level.
 cmp StackDi,Z.CurrentDOújne AddressA
 call HeritageDi
 Assert size EnvBlock eq 8
 mov cx,4
@@:mov ax,Wptr L.Active
 xchg ax,Wptr L.Alternate
 mov Wptr L.Active,ax
 inc diúinc diúloop @B
 pop StackDi
 BackRet

AddressA:push CursorSi
; If there were any arguments, Z.EnvNow will have garnered the context.
 Down
; If there is no command with ADDRESS, it is done in the given context.
 cmp StackDi,Z.CurrentDOújne AddressB
; If there is no command with ADDRESS, the active env is being set.
 call HeritageDi
 mov eax,Dptr(Z.EnvNow)
 mov Dptr L.Active,eax
 mov eax,Dptr(Z.EnvNow+4)
 mov Dptr(L.Active+4),eax
 pop StackDi
 RetSi

 end
