comment~
Only one lot of Zone data is needed, even when "external" Rexx calls are made,
so the natural place for recording DOS info (such as file name to file handle
relationships) is in the Zone. This Interface involves lookups and it probably
saves implementation size if the mechanism is the same as for stemmed variables.

For files, it would be quick and simple if the whole file was copied to memory
when it was opened.  However, we don't have enough address space for that.
Nearest equivalent is to pick a size and read the file in chunks on demand.
Provided a new allocation is made for each chunk there will not need to be
copying of the CHARIN/LINEIN results (except as part of Compaction perhaps).

(2012 But see actual implementation.)

It seems right to do QUALIFY whenever a stream name is used. (Silly if current
drive was "C:" but "C:FILE.MY" was a different file from "FILE.MY").  However,
QUALIFY can make two Dos calls so performance a problem if done for every
LINEIN. So QUALIFY should have a lookup in the interface compound.

I took the tails off things like LINEIN_POSITION of crx.rx (the ANSI Rexx code)
because the tail was always Stream, and Stream was stable for each routine.
That means some of the SysVars are implicitly qualified so when Stream is set
they should be given the values of that Stream.

We want the QUALIFY lookup to use the stream name as given by the user as key.
If the result was the QUALIFY result there would need to be another lookup to
get from that to the file's data.  Better if the result is the file item itself
(with QUALIFY result as its key).  That is usually a double lookup the first
time the stream name is used but later will be one.

The usual register setup in the I/O routines is that DS:BX addresses a Vshape
(the result of looking up the stream name) and the file data is an Fshape
addressed (at an offset) using the same values. The Vshape addresses the data
buffer for the file and ES addresses that data.  Some segment register shuffling
is needed because one is also needed to reach the system variables.

~
; ES:AX,CX  to the answer.
 CONFIG_UPPER$$:push CursorSi
; !! Faster to check if already upper?
 call ToDsSiCx�JcxzQ UpperRet
; !! Better with test for cx < 8 ?
 call AllocateCx_EsAx�jnc @F�call ToDsSiCx�@@:
 push cx�push ax�push StackDi�mov di,ax�mov bx,Attributes
;MASM ..........................
UpperLoop:lodsb�mov RawCharAh,al�XlatBDLS�jpe @F
 test AttribAl,$Lowercase�jnz @F�and RawCharAh,0DFh�@@:
 mov Bptr es:[di],ah�inc di�LoopQ UpperLoop
 pop StackDi�pop ax�pop cx
 call AwayEsAxCx
RetEsSi:mov ProgEs,Z.ProgScope
UpperRet:RetSi

CONFIG_MSG$$:push CursorSi
; Convert top from msg number to text.
; This is the ERRORTEXT creation.  Since there is no conflict with inserts,
; the Serial space can be used.
 mov al,$SerialNone�call Serialize
 mov ax,Zshape.Serial�mov Z.MsgSoFar,ax�mov Z.MsgBegin,ax
 mov ax,V.MantLow
; Use 1 if major overlarge so <description> texts can be hidden.
 cmp ah,$Limit_Major�jbe @F�mov ah,1�@@:
 On Z.Cancel,ForBIF; Stops inserts.
 mv ds,cs
 push di�call TargetMsg�mov ax,di�pop di
 mov ProgEs,Z.ProgScope
 Off Z.Cancel,ForBIF
 mov V.Sg,ss
 mov V.Pt,Zshape.Serial
 sub ax,Zshape.Serial
 mov V.Len,ax
 mov V.Dtype,$AwayString
 RetSi

CONFIG_C2B$$:push CursorSi
 call ToDsSiCx�JcxzQ C2Bret
 cmp cx,10000h/8�jnb Raise5p1d
 shl cx,3
; Source may be V so cannot use ResultSpace.
 call AllocateCx_EsAx
; The bits of Ds:Si to become 0/1 characters in the result, es:ax.
; In and out cannot be the same place
 mov bx,ax�push cx
C2Bloop:
 test cl,7�jnz @F�mov dh,Bptr[si]�inc si�@@:
 shl dh,1�mov dl,'0'�adc dx,ZeroBp
 mov Bptr es:[bx],dl�inc bx
 loop C2Bloop
 pop cx
 call AwayEsAxCx
C2Bret:
 mov ProgEs,Z.ProgScope�Move Ve[$?OUTCOME],V�Down�RetSi

CONFIG_B2C$$:push CursorSi
 call ToDsSiCx�shr cx,3�JcxzQ C2Bret
 call ResultSpace; Ok since process left to right.
 shl cx,3�mov bx,ax�z al�mov dl,128
B2Cloop:cmp Bptr[si],'0'�je @F�add al,dl�@@:
 shr dl,1�jnz @F
 mov Bptr es:[bx],al�inc bx�z al�mov dl,128
@@:inc si�LoopQ B2Cloop
 jmp C2Bret

CONFIG_STREAM_POSITION$$:; CHARIN/CHAROUT/LINEIN/LINEOUT and position.
; Lots NYI - getting thru just so 40.39 can test later.
; Present code does little more than throw away it arguments.
; 2012 There was much unexplained in the original here.
; 5.8.2 of the standard does not explicitly say, but 'N' is the
; response when this function is able to do what is intended.
 mov al,'N'
; 2012 parameter checking has established what file we are talking
; about
 mov FileBx,Z.Stream
 mov dl,V.String; First char of LINEIN/LINEOUT/CHARIN/CHAROUT
; 2012 Split OUT from IN by length of the parameter.
 cmp V.Dtype,$NullString+6�DownCare�jne CSPout
; 2012 Select file cursor to match reading.
 btr F.Flags,WriteMode�jnc @F�call SwopReadWrite�@@:
 cmp dl,'C'�je CSPinc
; LINEIN
; 2012 here we would reposition the file if respecting the third
; argument.
 jmp CSPret
CSPinc:; CHARIN
 jmp CSPret
CSPout:
; 2012 Select file cursor to match writing.
 bts F.Flags,WriteMode�jc @F�call SwopReadWrite�@@:
cmp dl,'C'�je CSPoutc
; LINEOUT
 jmp CSPret
CSPoutc:
; CHAROUT
CSPret:Down; 2012 Loses the 3rd argument to C S P. (?)
; 2012 ES address the variable of which RESPONSE is one.
 mov Ve.String[$?RESPONSE],al�ret

LookFileDsBx:
; V on entry is the string key value.
; Conversion from stream name to file handle is by lookup in the interface.
; Allow space ahead of anything this lookup adds, for file data.
; Use the lookup mechanism that stems use.
; Set FS:BX as if Z.SysFiles was the segment pointer of a $Stem variable.
; Assert - EXPOSED not relevant to SysFiles.
 mv fs,ss�mov bx,Zshape.SysFiles-Vshape.Sg-$StrideV; So now Vbxf2.
; Allow extra space ahead of item to be made.
 mov ds,Z.SysFiles�add Hd.Avail,$StrideF
; Different trees are kept for normal data files versus source files.
 Qry Z.Cancel,SourceFiles�jz @F
 push Hd.Probe�move Hd.Probe,Hd.TreeProg
@@:z ax�call DotsFsBxDsSiX�mov fs,Z.VarScope
 Qry Z.Cancel,SourceFiles�jz @F
 mov ax,Hd.Probe�pop Hd.Probe�mov Hd.TreeProg,ax
@@:mov FileBx,si; The result. Vbx for buffer, F. for file info.
; Extra space not needed if item not new.
 cmp Vbx.Dtype,$Omitted�je @F�sub Hd.Avail,$StrideF�ret
@@:z F.Flags�ret

; Dos I/O needs bx as the handle but we have it for the file data.
Int21DsBx:push FileBx�push ds�mov ds,Z.SysFiles�mov bx,F.Hand�pop ds
 int 21h�pop FileBx�mov ds,Z.SysFiles�ret

OpenQ:inc bp
OpenW:inc bp
OpenR:inc bp�mov cx,bp�xor bp,bp
; Rexx can do both reads and writes to the same stream name. If network files
; are involved it might be best to have two different file handles for read
; versus write but for now I will try just always opening for read & write.
; DOS will only know of one "current position" for the file and Rexx has
; both read and write positions so one of the positions has to be kept in
; the Rexx Fshape file block.

; The default for a Rexx write is to append. This is a difference from DOS
; for a first write. (BeenWrite flag)

; The first read needs to establish a buffer. (BeenRead flag)

; Asking for the size of a file is not really read or write but it needs a
; file handle. So open for read/write/query are different  (1/2/3 here).

 Qry F.Flags,Open�jnz HaveHandle
; Open for R&W, whatever this operation is.
 push cx
; To use the key string as a DOS parameter, it has to have a zero after it.
 lea si,Jbx.Key�mov dx,si�add si,Jbx.KeyLen�mov cl,Bptr[si]�z Bptr[si]
; AL is the open mode.
 mov al,02h�mov ah,$DosOpen�int 21h
; 2012 sysout is always there but another file may not be.
 jnc @F�cmp al,2�jne FileErrorPop
 push cx�z cx; file attributes
 mov al,02h�mov ah,$DosCreate�int 21h
 pop cx
 jc FileErrorPop
@@:mov Bptr[si],cl�On F.Flags,Open�mov F.Hand,ax; The handle.
 pop cx
HaveHandle:loop NotRead�bts F.Flags,BeenRead�jc HaveBuffer
; On first read, establish a buffer.
; Set up Vbx as the long string variable buffer and fill it.
FillBuffer:mov cx,$FileBufferSize
 call AllocateCx_EsAx
; 2011 Should compaction be maintaining DS here?
 mov ds,Z.SysFiles
 mov Vbx.Dtype,$AwayString�mov Vbx.Sg,es�mov Vbx.Pt,ax
 mov Vbx.Len,cx
; Set registers for DosRead.
 mv ds,es�mov dx,ax�mov ah,$DosRead�call Int21DsBx
 mov ProgEs,Z.ProgScope
 jc FileError
 mov Vbx.Len,ax�jmp @F
HaveBuffer:; Take the chance to ensure empty buffer only at Eof.
 cmp Vbx.Len,ZeroBp�je FillBuffer
; If the last thing was a write, we have to swop file pointers.
@@:btr F.Flags,WriteMode�jnc @F�call SwopReadWrite�@@:ret
;MASM...............................
NotRead:loop NotWrite�bts F.Flags,BeenWrite�jc @F
; If this is the first go at writing, move the DOS pointer to end of file.
 z dx�z cx�mov ax,MkMajMin($DosSeek,2)�call Int21DsBx; Ask to move 0 from end.
 On F.Flags,WriteMode
; If the last thing not a write, we have to swop file pointers.
@@:bts F.Flags,WriteMode�jc @F�call SwopReadWrite�@@:ret

NotWrite:ret; Here it is a query. Assuring FileBx is enough.

SwopReadWrite:; First get the cursor from DOS.
 pusha
 z dx�z cx�mov ax,MkMajMin($DosSeek,1)�call Int21DsBx; Ask to move 0 from current.
 mov cx,dx�mov dx,ax; Move result to same registers as input.
; Then exchange value with the one remembered.
 xchg dx,Wptr F.Other_Position�xchg cx,Wptr F.Other_Position+2
 mov ax,MkMajMin($DosSeek,0)�call Int21DsBx; Ask to move cx:dx from begin of file.
 popa
 ret

CONFIG_STREAM_CHARIN$$:; Like an operator, so must honour StackDi and CursorSi
 push CursorSi�mov ds,Z.SysFiles�mov FileBx,Z.Stream
 cmp V.String,'L'�jne NotLinein
 call OpenR
; Scan for end-of-line.
; We will put the line into V. and the residual buffer into Vbx.
; ANSI doesn't say but it looks like Warp practice is to treat 0D, 0A, 1A as
; equals to end lines. Then 0A following 0D ignored.

FindLine:les si,Vbx.Fr�mov cx,Vbx.Len�mov dx,si
; Warp can read past Eof but that doesn't seem right.
 cmp Bptr es:[si],$Eof�je EndFile
; Assert Eof is the largest of interest as eol control.
@@:lodsb es:[si]�cmp al,$Eof�jbe TestEol
NotEol:LoopQ @B
TryLonger:
; Found no eol. Read some more from the file and restart.
; Build as V then set Vbx.
 mov cx,si�sub cx,dx; Amount already scanned.
 push cx�add cx,$FileBufferSize�call ResultSpace
; Copy hangover to new buffer.
 pop cx�lds si,Vbx.Fr; Hangover
 push StackDi�push si�mov di,V.Pt�rep movsb�pop si
 mov dx,di; Where data from file will go.
 pop StackDi
; Append from the file.
 mov cx,$FileBufferSize�mv ds,es�mov ah,$DosRead�call Int21DsBx
 sub cx,ax; Bytes not read.
 Move Vbx,V,edx�sub Vbx.Len,cx
 TestReg ax�jnz FindLine
; Need some fixup for a file ending in an unterminated line.
; Pretend an Eof
 les si,Vbx.Fr�add si,Vbx.Len�mov Bptr es:[si],$Eof
 inc Vbx.Len�jmp FindLine

TestEol:je WasEol;(Eof)�cmp al,$Cr�je WasCr�cmp al,$Lf�jne NotEol
WasEol:; Here with some eol character.
; ax is for line, si for residue.
 mov ax,si
WasCrLf:
 dec cx
; Update buffer to residue.
 mov Vbx.Pt,si
 mov Vbx.Len,cx
; ?OUTCOME is the line.
 sub ax,dx�dec ax
 mov ds,Z.ProgScope
 mov ArraySi,$?OUTCOME
 mov Vsid.Pt,dx
 mov Vsid.Sg,es
 mov Vsid.Len,ax
 mov Vsid.Dtype,$AwayString
; ?LINEIN_POSITION indicates change of line.
 inc ds:Vshape.Mantissa[$?LINEIN_POSITION]
 mov al,'N'; ?RESPONSE is 'N'
 mov ProgEs,Z.ProgScope
Respond:mov Ve.String[$?RESPONSE],al
 Down
 RetSi

WasCr:cmp cx,1
 je TryLonger; Retry if it is a $Cr so as to be able to find $Lf that follows.
 mov ax,si
; Maybe $Lf to lose after $Cr.
 cmp Bptr es:[si],$Lf�jne WasCrLf; No Lf�inc si�dec cx
 jmp WasCrLf

EndFile:
 mov al,'O'; ?RESPONSE is 'O'
; Null line returned.
EndNull:mov ProgEs,Z.ProgScope�mov Ve.Dtype[$?OUTCOME],$NullString
 jmp Respond

FileErrorPop:PopJunk ax; Pushed CX�PopJunk ax; Link of OpenR
FileError:; Respond with 'E'�mov al,'E'�jmp EndNull

NotLinein:
 cmp V.String,'C'�jne NotCharin
NotCharin:
 Error49Bp

CONFIG_STREAM_QUERY$$:
 Error49Bp

CONFIG_STREAM_CLOSE$$:mov FileBx,Z.Stream
CloseBx:push CursorSi
 mov ds,Z.SysFiles�btr F.Flags,Open�mov F.Flags,ZeroBp�jnc @F
 mov bx,F.Hand�mov ah,$DosClose�int 21h
@@:RetSi

CONFIG_STREAM_CHAROUT$$:
; 2012 The Rexx form of close is lineout with nothing to write.
 cmp V.Dtype,$Omitted�je CONFIG_STREAM_CLOSE$$
 push CursorSi
; 2012 this was unimplemented in 1999 but the Say verb was implemented
; and the difference of that from simple LINEOUT is only in the handle.
; Hence this code, mostly copied from Say.
; Get the Handle.
 mov ds,Z.SysFiles�mov FileBx,Z.Stream�call OpenW�mov bx,F.Hand
; Get what to write.
 call ToDsSiCx�mov dx,si
; Write with newline
 mov ah,$DosWrite�int 21h; Takes ds:dx:cx to file bx
 mv ds,cs�mov dx,Yshape.CrLf�mov cx,2
 mov ah,$DosWrite�int 21h
 Down�pop CursorSi�ret

CONFIG_STREAM_COUNT$$:push CursorSi
; First arg is CHARS/LINES, second is option N/C
 mov ds,Z.SysFiles�mov FileBx,Z.Stream
 cmp V0.String,'C'�jne NotChars
 push Vbx.Len�call OpenQ�mov bx,F.Hand
; Method is to seek both current and relative-to-eof positions. Difference
; is chars remaining.    !! Part buffer processed?
 z dx�z cx�mov ax,MkMajMin($DosSeek,1)�int 21h; Ask for 0 from current.
; Rexx position is not the same as DOS position because we read a buffersworth.
; Adjustment comes later.
; Save somewhere.  V2 and V3 as workspace.
 mov Wptr V3.Mantissa,ax�mov Wptr V3.Mantissa+2,dx
 z dx�z cx�mov ax,MkMajMin($DosSeek,2)�int 21h; Ask for 0 from eof
 mov Wptr V2.Mantissa,ax�mov Wptr V2.Mantissa+2,dx
; Have to move it back from end to current.
 mov dx,Wptr V3.Mantissa�mov cx,Wptr V3.Mantissa+2
 mov ax,MkMajMin($DosSeek,0)�int 21h; Ask for cx:dx from origin.
; Do the arithmetic
 mov edx,V2.Mantissa�sub edx,V3.Mantissa
; Add unscanned part of buffer.
 pop cx�movzx ecx,cx�add edx,ecx
 mov V0.Mantissa,edx
CSCret:Down�z V.ExpAnd�RetSi

NotChars:; N/C matters for LINES. NYI
; Method is different for LINES.
; If the option is 'N' we only need to know if the next available char is
; $Eof.
 z V0.Mantissa
 call OpenR
 cmp V.String,'N'�jne LinesExact
; Nothing read means no lines.
 cmp Vbx.Len,ZeroBp�je CSCret
 lds si,Vbx.Fr�cmp Bptr[si],$Eof�setne Bptr V0.Mantissa�jmp CSCret

LinesExact:
; If the option is 'C', we checkpoint where we are on the file, then
; actually read lines, restore from checkpoint.
 mov ProgEs,Z.ProgScope�Move Ve[$?Discard],Vbx
 z dx�z cx�mov ax,MkMajMin($DosSeek,1)�call Int21DsBx; Ask for 0 from current.
; etc NYI
 mov V.String,'L'; Arg to say LINEIN
; How do we stop it going to NOTREADY?
 Error49Bp
 call CONFIG_STREAM_CHARIN$$

CSQ0:; Z.STREAM will have been set by the assignment to ?STREAM.
; Return tail of the fully qualified item.
 mov FileBx,Z.Stream
 move V.Sg,Z.SysFiles�lea ax,Jbx.Key�mov V.Pt,ax
 move V.Len,Jbx.KeyLen�call Away�RetSi

CONFIG_STREAM_QUALIFIED$$:push CursorSi
; Second argument is numeric and describes function requested.
; When arg2 is 0 return QUALIFY() string.
; When arg2 is 1 get the current drive letter.
; When arg2 is 2 get the path associated with a drive letter.
; When arg2 is 3 record qualified file.
; When arg2 is 4 query file existence.

 mov cx,Wptr V.Mantissa�Down�JcxzQ CSQ0�loop NotCSQ1
; When arg2 is 1 get the current drive letter.
 mov ah,$DosDisk�int 21h
 add al,'A'�mov V.String,al�mov V.Dtype,$NullString+1�RetSi

NotCSQ1:loop NotCSQ2
; When arg2 is 2 get the path associated with a drive letter.
; Arg1 is the drive letter.
; 2011 should test fully but uppercase for now.
; 2011 DOS buffer is 64.  Where is check? Giveback?
 mov dl,V.String�and dl,0DFh�sub dl,'A'-1�mov cx,100�call ResultSpace
 mv ds,es�mov si,ax�mov ah,$DosPath�int 21h
; Convert from ASCIIZ form.
 z V.Len
@@:cmp Bptr[si],0�je @F�inc si�inc V.Len�jmp @B�@@:
 push RetEsSi
 jmp Away

NotCSQ2:loop NotCSQ3
; When arg2 is 3 record qualified file.
 push Z.Stream; From the unqualified lookup.
; Arg1 is the qualified; look it up in SysFiles.
 call LookFileDsBx
; Is it the same as the one we got for unqualified lookup?
; (Unqualified could have, in fact, had all the qualifiers)
 pop dx�cmp FileBx,dx�je @F
; No, point the unqualified item to it.
 xax FileBx�mov bx,dx�mov F.ToQual,ax�xax FileBx
@@:; Has it been initialized?
 bts F.Flags,Qual�jc @F
; Start the new item with no buffer.
 On F.Flags,Qual�mov Vbx.Dtype,$Dropped
@@:mov Z.Stream,FileBx�RetSi

NotCSQ3:
; When arg2 is 4 query file existence.
; Do this without SysFiles lookup because don't want to clutter that.
; There may be a better way but CHMOD seems to work.
  call ToDsSiCx
  mov ax,MkMajMin($DosChmod,0)
; Make it ASCIIZ for CHMOD request
  mov dx,si�add si,cx�mov bl,Bptr[si]�mov Bptr[si],al
  int 21h�mov Bptr[si],bl; Un-ASCIIZ-fy
  z V.Mantissa�z V.ExpAnd
  jc @F�inc V.MantLow�@@:
  RetSi

CONFIG_STREAM_COMMAND$$:
 Error49Bp
CONFIG_STREAM_STATE$$:
 Error49Bp

CONFIG_TIME$$:Up�mov V.Dtype,$NullString+7
if 0
 mov ecx,1436244ch�mov Dptr V.String,ecx
 mov ecx,87130a02h�mov Dptr V.String+4,ecx
 ret
; That was bug stabilize
endif
; Construct a stack value with all that DOS tells us.
MidNight:mov ah,$DosDate�int 21h;cx=year(1980+) dh=month dl=day
 sub cx,1980�mov V.String+6,cl�mov Wptr V.String+4,dx
 mov ah,$DosTime�int 21h;ch=hour cl=minute dh=second dl=hundredth
 mov Wptr V.String+2,cx�mov Wptr V.String,dx
 mov ah,$DosDate�int 21h�cmp dl,V.String+4�jne MidNight
; DOS doesn't tell local time adjustment for daylight.
 ret

