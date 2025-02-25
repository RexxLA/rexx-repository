;------------------------------------------------------------------------------
; Only kept for debugging.
;------------------------------------------------------------------------------
Consist:pusha�push ds�push fs
; Does content of Symbols make sense?
; More than that, do Z.Vars and Z.Consts agree with it?
 mov ds,Z.Symbols
; Move si thru symbols.
 z cx�z dx�mov si,$StrideH�inc cx; Allows for Omitted.
DumpL:
 movzx ax,Bptr[si]�inc si�mov bx,si
; DS:SI::AX and DS:BX::AX to the symbol content.

if 0
; To Say the symbol. We need a sensible DI.  This should be OK
 mov di,Z.Stack
 Up�mov V.Sg,ds
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
 cmp si,Hd.Avail�je ConsistRet
; This bit is about the item trailer.
; Send on DI=0 unless there was a label value.
 z di
 cmp Bptr[si],$tChar�jne @F�inc si�jmp DLcon�@@:
 cmp Bptr[si],$tBinary�jne @F�inc si�jmp DLcon�@@:
 cmp Bptr[si],$tLabel�jne @F
; The value of the label is in here.
 inc si�mov di,Wptr[si]�add si,2�jmp DLcon
@@:
; DX is the count of this variable. Check that one points the same as BX
 mov ax,dx�inc dx�shl ax,$ShiftV
 mov di,ax�mov fs,Z.Vars�mov ax,fs:V.Here[$StrideH]
 inc ax�cmp ax,bx�je @F�int 3�@@:
; Variables that end with a dot take two slots.
 cmp Bptr[si-1],'.'�jne @F�inc dx�@@:
; Ought to be a variable symbol.
 mov al,Bptr[bx]
 mov bx,Attributes
 XlatBDLS�jpo @F�int 3�@@:
 js @F�int 3�@@:
 jmp ConsistL

DLcon:; CX is the count of this const. Check any LabelValue & check v BX
 mov ax,cx�inc cx�shl ax,$ShiftV
 xchg di,ax�mov fs,Z.ProgScope�add di,$SizeConstsHeader
 TestReg ax�jz @F�cmp ax,fs:V.LabelValue�je @F
 cmp fs:V.LabelValue,1�je @F
; The Reserveds don't stay labels so cant check em.
 cmp di,$?STARTTIME�jna @F�int 3
@@:
 mov fs,Z.Consts
 mov ax,fs:V.Here
 inc ax�cmp ax,bx�je @F�int 3�@@:
; SI now on next symbol.
ConsistL:cmp si,Hd.Avail�jb DumpL
ConsistRet:pop fs�pop ds�popa�ret

; Create file to take dump.
Dump db "D.T",0

Create4Dump:pusha
comment~ Even if I successfully close the dump file after each use, that does
not stop $DosCreate consuming a new file handle each time. Hence Z.Dumper test.
That means the close has to be done at exit.
~
 mov bx,Z.Dumper�TestReg bx�jne C4Has
 mv ds,cs�mov dx,offset Dump�z cx
 mov ah,$DosCreate�int 21h�jnc @F�Error49Bp�@@:mov Z.Dumper,ax�mov bx,ax
C4Has:z cx�z dx
 mov ax,MkMajMin($DosSeek,0)�int 21h; Ask to move cx:dx from begin of file.
 popa�ret

Dumper:pusha
if 1
 call Consist
endif
; Write lengths
 mov bx,Z.Dumper�mov cx,2
 mov ds,Z.Code�mov dx,Hshape.Avail�mov ah,$DosWrite�int 21h
 mov ds,Z.Symbols�mov dx,Hshape.Avail�mov ah,$DosWrite�int 21h
; Write from segments
 z dx
 mov ds,Z.Code�mov cx,Hd.Avail�mov ah,$DosWrite�int 21h
 mov ds,Z.Symbols�mov cx,Hd.Avail�mov ah,$DosWrite�int 21h
 popa�ret

