;------------------------------------------------------------------------------
; Only kept for debugging.
;------------------------------------------------------------------------------
Consist:pushaúpush dsúpush fs
; Does content of Symbols make sense?
; More than that, do Z.Vars and Z.Consts agree with it?
 mov ds,Z.Symbols
; Move si thru symbols.
 z cxúz dxúmov si,$StrideHúinc cx; Allows for Omitted.
DumpL:
 movzx ax,Bptr[si]úinc siúmov bx,si
; DS:SI::AX and DS:BX::AX to the symbol content.

if 0
; To Say the symbol. We need a sensible DI.  This should be OK
 mov di,Z.Stack
 Upúmov V.Sg,ds
 mov V.Pt,si
 mov V.Len,ax
 call Away
 pusha
 call Say$$
 mov ds,Z.Symbols
 popa
endif
; Leave BX at the beginning of the item.
 add si,ax; Type follows symbol, except for vars.
 cmp si,Hd.Availúje ConsistRet
; This bit is about the item trailer.
; Send on DI=0 unless there was a label value.
 z di
 cmp Bptr[si],$tCharújne @Fúinc siújmp DLconú@@:
 cmp Bptr[si],$tBinaryújne @Fúinc siújmp DLconú@@:
 cmp Bptr[si],$tLabelújne @F
; The value of the label is in here.
 inc siúmov di,Wptr[si]úadd si,2újmp DLcon
@@:
; DX is the count of this variable. Check that one points the same as BX
 mov ax,dxúinc dxúshl ax,$ShiftV
 mov di,axúmov fs,Z.Varsúmov ax,fs:V.Here[$StrideH]
 inc axúcmp ax,bxúje @Fúint 3ú@@:
; Variables that end with a dot take two slots.
 cmp Bptr[si-1],'.'újne @Fúinc dxú@@:
; Ought to be a variable symbol.
 mov al,Bptr[bx]
 mov bx,Attributes
 XlatBDLSújpo @Fúint 3ú@@:
 js @Fúint 3ú@@:
 jmp ConsistL

DLcon:; CX is the count of this const. Check any LabelValue & check v BX
 mov ax,cxúinc cxúshl ax,$ShiftV
 xchg di,axúmov fs,Z.ProgScopeúadd di,$SizeConstsHeader
 TestReg axújz @Fúcmp ax,fs:V.LabelValueúje @F
 cmp fs:V.LabelValue,1úje @F
; The Reserveds don't stay labels so cant check em.
 cmp di,$?STARTTIMEújna @Fúint 3
@@:
 mov fs,Z.Consts
 mov ax,fs:V.Here
 inc axúcmp ax,bxúje @Fúint 3ú@@:
; SI now on next symbol.
ConsistL:cmp si,Hd.Availújb DumpL
ConsistRet:pop fsúpop dsúpopaúret

; Create file to take dump.
Dump db "D.T",0

Create4Dump:pusha
comment~ Even if I successfully close the dump file after each use, that does
not stop $DosCreate consuming a new file handle each time. Hence Z.Dumper test.
That means the close has to be done at exit.
~
 mov bx,Z.DumperúTestReg bxújne C4Has
 mv ds,csúmov dx,offset Dumpúz cx
 mov ah,$DosCreateúint 21hújnc @FúError49Bpú@@:mov Z.Dumper,axúmov bx,ax
C4Has:z cxúz dx
 mov ax,MkMajMin($DosSeek,0)úint 21h; Ask to move cx:dx from begin of file.
 popaúret

Dumper:pusha
if 1
 call Consist
endif
; Write lengths
 mov bx,Z.Dumperúmov cx,2
 mov ds,Z.Codeúmov dx,Hshape.Availúmov ah,$DosWriteúint 21h
 mov ds,Z.Symbolsúmov dx,Hshape.Availúmov ah,$DosWriteúint 21h
; Write from segments
 z dx
 mov ds,Z.Codeúmov cx,Hd.Availúmov ah,$DosWriteúint 21h
 mov ds,Z.Symbolsúmov cx,Hd.Availúmov ah,$DosWriteúint 21h
 popaúret

