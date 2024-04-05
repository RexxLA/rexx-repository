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
 call ToDsSiCxúJcxzQ UpperRet
; !! Better with test for cx < 8 ?
 call AllocateCx_EsAxújnc @Fúcall ToDsSiCxú@@:
 push cxúpush axúpush StackDiúmov di,axúmov bx,Attributes
;MASM ..........................
UpperLoop:lodsbúmov RawCharAh,alúXlatBDLSújpe @F
 test AttribAl,$Lowercaseújnz @Fúand RawCharAh,0DFhú@@:
 mov Bptr es:[di],ahúinc diúLoopQ UpperLoop
 pop StackDiúpop axúpop cx
 call AwayEsAxCx
RetEsSi:mov ProgEs,Z.ProgScope
UpperRet:RetSi

CONFIG_MSG$$:push CursorSi
; Convert top from msg number to text.
; This is the ERRORTEXT creation.  Since there is no conflict with inserts,
; the Serial space can be used.
 mov al,$SerialNoneúcall Serialize
 mov ax,Zshape.Serialúmov Z.MsgSoFar,axúmov Z.MsgBegin,ax
 mov ax,V.MantLow
; Use 1 if major overlarge so <description> texts can be hidden.
 cmp ah,$Limit_Majorújbe @Fúmov ah,1ú@@:
 On Z.Cancel,ForBIF; Stops inserts.
 mv ds,cs
 push diúcall TargetMsgúmov ax,diúpop di
 mov ProgEs,Z.ProgScope
 Off Z.Cancel,ForBIF
 mov V.Sg,ss
 mov V.Pt,Zshape.Serial
 sub ax,Zshape.Serial
 mov V.Len,ax
 mov V.Dtype,$AwayString
 RetSi

CONFIG_C2B$$:push CursorSi
 call ToDsSiCxúJcxzQ C2Bret
 cmp cx,10000h/8újnb Raise5p1d
 shl cx,3
; Source may be V so cannot use ResultSpace.
 call AllocateCx_EsAx
; The bits of Ds:Si to become 0/1 characters in the result, es:ax.
; In and out cannot be the same place
 mov bx,axúpush cx
C2Bloop:
 test cl,7újnz @Fúmov dh,Bptr[si]úinc siú@@:
 shl dh,1úmov dl,'0'úadc dx,ZeroBp
 mov Bptr es:[bx],dlúinc bx
 loop C2Bloop
 pop cx
 call AwayEsAxCx
C2Bret:
 mov ProgEs,Z.ProgScopeúMove Ve[$?OUTCOME],VúDownúRetSi

CONFIG_B2C$$:push CursorSi
 call ToDsSiCxúshr cx,3úJcxzQ C2Bret
 call ResultSpace; Ok since process left to right.
 shl cx,3úmov bx,axúz alúmov dl,128
B2Cloop:cmp Bptr[si],'0'úje @Fúadd al,dlú@@:
 shr dl,1újnz @F
 mov Bptr es:[bx],alúinc bxúz alúmov dl,128
@@:inc siúLoopQ B2Cloop
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
 cmp V.Dtype,$NullString+6úDownCareújne CSPout
; 2012 Select file cursor to match reading.
 btr F.Flags,WriteModeújnc @Fúcall SwopReadWriteú@@:
 cmp dl,'C'úje CSPinc
; LINEIN
; 2012 here we would reposition the file if respecting the third
; argument.
 jmp CSPret
CSPinc:; CHARIN
 jmp CSPret
CSPout:
; 2012 Select file cursor to match writing.
 bts F.Flags,WriteModeújc @Fúcall SwopReadWriteú@@:
cmp dl,'C'úje CSPoutc
; LINEOUT
 jmp CSPret
CSPoutc:
; CHAROUT
CSPret:Down; 2012 Loses the 3rd argument to C S P. (?)
; 2012 ES address the variable of which RESPONSE is one.
 mov Ve.String[$?RESPONSE],alúret

LookFileDsBx:
; V on entry is the string key value.
; Conversion from stream name to file handle is by lookup in the interface.
; Allow space ahead of anything this lookup adds, for file data.
; Use the lookup mechanism that stems use.
; Set FS:BX as if Z.SysFiles was the segment pointer of a $Stem variable.
; Assert - EXPOSED not relevant to SysFiles.
 mv fs,ssúmov bx,Zshape.SysFiles-Vshape.Sg-$StrideV; So now Vbxf2.
; Allow extra space ahead of item to be made.
 mov ds,Z.SysFilesúadd Hd.Avail,$StrideF
; Different trees are kept for normal data files versus source files.
 Qry Z.Cancel,SourceFilesújz @F
 push Hd.Probeúmove Hd.Probe,Hd.TreeProg
@@:z axúcall DotsFsBxDsSiXúmov fs,Z.VarScope
 Qry Z.Cancel,SourceFilesújz @F
 mov ax,Hd.Probeúpop Hd.Probeúmov Hd.TreeProg,ax
@@:mov FileBx,si; The result. Vbx for buffer, F. for file info.
; Extra space not needed if item not new.
 cmp Vbx.Dtype,$Omittedúje @Fúsub Hd.Avail,$StrideFúret
@@:z F.Flagsúret

; Dos I/O needs bx as the handle but we have it for the file data.
Int21DsBx:push FileBxúpush dsúmov ds,Z.SysFilesúmov bx,F.Handúpop ds
 int 21húpop FileBxúmov ds,Z.SysFilesúret

OpenQ:inc bp
OpenW:inc bp
OpenR:inc bpúmov cx,bpúxor bp,bp
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

 Qry F.Flags,Openújnz HaveHandle
; Open for R&W, whatever this operation is.
 push cx
; To use the key string as a DOS parameter, it has to have a zero after it.
 lea si,Jbx.Keyúmov dx,siúadd si,Jbx.KeyLenúmov cl,Bptr[si]úz Bptr[si]
; AL is the open mode.
 mov al,02húmov ah,$DosOpenúint 21h
; 2012 sysout is always there but another file may not be.
 jnc @Fúcmp al,2újne FileErrorPop
 push cxúz cx; file attributes
 mov al,02húmov ah,$DosCreateúint 21h
 pop cx
 jc FileErrorPop
@@:mov Bptr[si],clúOn F.Flags,Openúmov F.Hand,ax; The handle.
 pop cx
HaveHandle:loop NotReadúbts F.Flags,BeenReadújc HaveBuffer
; On first read, establish a buffer.
; Set up Vbx as the long string variable buffer and fill it.
FillBuffer:mov cx,$FileBufferSize
 call AllocateCx_EsAx
; 2011 Should compaction be maintaining DS here?
 mov ds,Z.SysFiles
 mov Vbx.Dtype,$AwayStringúmov Vbx.Sg,esúmov Vbx.Pt,ax
 mov Vbx.Len,cx
; Set registers for DosRead.
 mv ds,esúmov dx,axúmov ah,$DosReadúcall Int21DsBx
 mov ProgEs,Z.ProgScope
 jc FileError
 mov Vbx.Len,axújmp @F
HaveBuffer:; Take the chance to ensure empty buffer only at Eof.
 cmp Vbx.Len,ZeroBpúje FillBuffer
; If the last thing was a write, we have to swop file pointers.
@@:btr F.Flags,WriteModeújnc @Fúcall SwopReadWriteú@@:ret
;MASM...............................
NotRead:loop NotWriteúbts F.Flags,BeenWriteújc @F
; If this is the first go at writing, move the DOS pointer to end of file.
 z dxúz cxúmov ax,MkMajMin($DosSeek,2)úcall Int21DsBx; Ask to move 0 from end.
 On F.Flags,WriteMode
; If the last thing not a write, we have to swop file pointers.
@@:bts F.Flags,WriteModeújc @Fúcall SwopReadWriteú@@:ret

NotWrite:ret; Here it is a query. Assuring FileBx is enough.

SwopReadWrite:; First get the cursor from DOS.
 pusha
 z dxúz cxúmov ax,MkMajMin($DosSeek,1)úcall Int21DsBx; Ask to move 0 from current.
 mov cx,dxúmov dx,ax; Move result to same registers as input.
; Then exchange value with the one remembered.
 xchg dx,Wptr F.Other_Positionúxchg cx,Wptr F.Other_Position+2
 mov ax,MkMajMin($DosSeek,0)úcall Int21DsBx; Ask to move cx:dx from begin of file.
 popa
 ret

CONFIG_STREAM_CHARIN$$:; Like an operator, so must honour StackDi and CursorSi
 push CursorSiúmov ds,Z.SysFilesúmov FileBx,Z.Stream
 cmp V.String,'L'újne NotLinein
 call OpenR
; Scan for end-of-line.
; We will put the line into V. and the residual buffer into Vbx.
; ANSI doesn't say but it looks like Warp practice is to treat 0D, 0A, 1A as
; equals to end lines. Then 0A following 0D ignored.

FindLine:les si,Vbx.Frúmov cx,Vbx.Lenúmov dx,si
; Warp can read past Eof but that doesn't seem right.
 cmp Bptr es:[si],$Eofúje EndFile
; Assert Eof is the largest of interest as eol control.
@@:lodsb es:[si]úcmp al,$Eofújbe TestEol
NotEol:LoopQ @B
TryLonger:
; Found no eol. Read some more from the file and restart.
; Build as V then set Vbx.
 mov cx,siúsub cx,dx; Amount already scanned.
 push cxúadd cx,$FileBufferSizeúcall ResultSpace
; Copy hangover to new buffer.
 pop cxúlds si,Vbx.Fr; Hangover
 push StackDiúpush siúmov di,V.Ptúrep movsbúpop si
 mov dx,di; Where data from file will go.
 pop StackDi
; Append from the file.
 mov cx,$FileBufferSizeúmv ds,esúmov ah,$DosReadúcall Int21DsBx
 sub cx,ax; Bytes not read.
 Move Vbx,V,edxúsub Vbx.Len,cx
 TestReg axújnz FindLine
; Need some fixup for a file ending in an unterminated line.
; Pretend an Eof
 les si,Vbx.Frúadd si,Vbx.Lenúmov Bptr es:[si],$Eof
 inc Vbx.Lenújmp FindLine

TestEol:je WasEol;(Eof)úcmp al,$Crúje WasCrúcmp al,$Lfújne NotEol
WasEol:; Here with some eol character.
; ax is for line, si for residue.
 mov ax,si
WasCrLf:
 dec cx
; Update buffer to residue.
 mov Vbx.Pt,si
 mov Vbx.Len,cx
; ?OUTCOME is the line.
 sub ax,dxúdec ax
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
 cmp Bptr es:[si],$Lfújne WasCrLf; No Lfúinc siúdec cx
 jmp WasCrLf

EndFile:
 mov al,'O'; ?RESPONSE is 'O'
; Null line returned.
EndNull:mov ProgEs,Z.ProgScopeúmov Ve.Dtype[$?OUTCOME],$NullString
 jmp Respond

FileErrorPop:PopJunk ax; Pushed CXúPopJunk ax; Link of OpenR
FileError:; Respond with 'E'úmov al,'E'újmp EndNull

NotLinein:
 cmp V.String,'C'újne NotCharin
NotCharin:
 Error49Bp

CONFIG_STREAM_QUERY$$:
 Error49Bp

CONFIG_STREAM_CLOSE$$:mov FileBx,Z.Stream
CloseBx:push CursorSi
 mov ds,Z.SysFilesúbtr F.Flags,Openúmov F.Flags,ZeroBpújnc @F
 mov bx,F.Handúmov ah,$DosCloseúint 21h
@@:RetSi

CONFIG_STREAM_CHAROUT$$:
; 2012 The Rexx form of close is lineout with nothing to write.
 cmp V.Dtype,$Omittedúje CONFIG_STREAM_CLOSE$$
 push CursorSi
; 2012 this was unimplemented in 1999 but the Say verb was implemented
; and the difference of that from simple LINEOUT is only in the handle.
; Hence this code, mostly copied from Say.
; Get the Handle.
 mov ds,Z.SysFilesúmov FileBx,Z.Streamúcall OpenWúmov bx,F.Hand
; Get what to write.
 call ToDsSiCxúmov dx,si
; Write with newline
 mov ah,$DosWriteúint 21h; Takes ds:dx:cx to file bx
 mv ds,csúmov dx,Yshape.CrLfúmov cx,2
 mov ah,$DosWriteúint 21h
 Downúpop CursorSiúret

CONFIG_STREAM_COUNT$$:push CursorSi
; First arg is CHARS/LINES, second is option N/C
 mov ds,Z.SysFilesúmov FileBx,Z.Stream
 cmp V0.String,'C'újne NotChars
 push Vbx.Lenúcall OpenQúmov bx,F.Hand
; Method is to seek both current and relative-to-eof positions. Difference
; is chars remaining.    !! Part buffer processed?
 z dxúz cxúmov ax,MkMajMin($DosSeek,1)úint 21h; Ask for 0 from current.
; Rexx position is not the same as DOS position because we read a buffersworth.
; Adjustment comes later.
; Save somewhere.  V2 and V3 as workspace.
 mov Wptr V3.Mantissa,axúmov Wptr V3.Mantissa+2,dx
 z dxúz cxúmov ax,MkMajMin($DosSeek,2)úint 21h; Ask for 0 from eof
 mov Wptr V2.Mantissa,axúmov Wptr V2.Mantissa+2,dx
; Have to move it back from end to current.
 mov dx,Wptr V3.Mantissaúmov cx,Wptr V3.Mantissa+2
 mov ax,MkMajMin($DosSeek,0)úint 21h; Ask for cx:dx from origin.
; Do the arithmetic
 mov edx,V2.Mantissaúsub edx,V3.Mantissa
; Add unscanned part of buffer.
 pop cxúmovzx ecx,cxúadd edx,ecx
 mov V0.Mantissa,edx
CSCret:Downúz V.ExpAndúRetSi

NotChars:; N/C matters for LINES. NYI
; Method is different for LINES.
; If the option is 'N' we only need to know if the next available char is
; $Eof.
 z V0.Mantissa
 call OpenR
 cmp V.String,'N'újne LinesExact
; Nothing read means no lines.
 cmp Vbx.Len,ZeroBpúje CSCret
 lds si,Vbx.Frúcmp Bptr[si],$Eofúsetne Bptr V0.Mantissaújmp CSCret

LinesExact:
; If the option is 'C', we checkpoint where we are on the file, then
; actually read lines, restore from checkpoint.
 mov ProgEs,Z.ProgScopeúMove Ve[$?Discard],Vbx
 z dxúz cxúmov ax,MkMajMin($DosSeek,1)úcall Int21DsBx; Ask for 0 from current.
; etc NYI
 mov V.String,'L'; Arg to say LINEIN
; How do we stop it going to NOTREADY?
 Error49Bp
 call CONFIG_STREAM_CHARIN$$

CSQ0:; Z.STREAM will have been set by the assignment to ?STREAM.
; Return tail of the fully qualified item.
 mov FileBx,Z.Stream
 move V.Sg,Z.SysFilesúlea ax,Jbx.Keyúmov V.Pt,ax
 move V.Len,Jbx.KeyLenúcall AwayúRetSi

CONFIG_STREAM_QUALIFIED$$:push CursorSi
; Second argument is numeric and describes function requested.
; When arg2 is 0 return QUALIFY() string.
; When arg2 is 1 get the current drive letter.
; When arg2 is 2 get the path associated with a drive letter.
; When arg2 is 3 record qualified file.
; When arg2 is 4 query file existence.

 mov cx,Wptr V.MantissaúDownúJcxzQ CSQ0úloop NotCSQ1
; When arg2 is 1 get the current drive letter.
 mov ah,$DosDiskúint 21h
 add al,'A'úmov V.String,alúmov V.Dtype,$NullString+1úRetSi

NotCSQ1:loop NotCSQ2
; When arg2 is 2 get the path associated with a drive letter.
; Arg1 is the drive letter.
; 2011 should test fully but uppercase for now.
; 2011 DOS buffer is 64.  Where is check? Giveback?
 mov dl,V.Stringúand dl,0DFhúsub dl,'A'-1úmov cx,100úcall ResultSpace
 mv ds,esúmov si,axúmov ah,$DosPathúint 21h
; Convert from ASCIIZ form.
 z V.Len
@@:cmp Bptr[si],0úje @Fúinc siúinc V.Lenújmp @Bú@@:
 push RetEsSi
 jmp Away

NotCSQ2:loop NotCSQ3
; When arg2 is 3 record qualified file.
 push Z.Stream; From the unqualified lookup.
; Arg1 is the qualified; look it up in SysFiles.
 call LookFileDsBx
; Is it the same as the one we got for unqualified lookup?
; (Unqualified could have, in fact, had all the qualifiers)
 pop dxúcmp FileBx,dxúje @F
; No, point the unqualified item to it.
 xax FileBxúmov bx,dxúmov F.ToQual,axúxax FileBx
@@:; Has it been initialized?
 bts F.Flags,Qualújc @F
; Start the new item with no buffer.
 On F.Flags,Qualúmov Vbx.Dtype,$Dropped
@@:mov Z.Stream,FileBxúRetSi

NotCSQ3:
; When arg2 is 4 query file existence.
; Do this without SysFiles lookup because don't want to clutter that.
; There may be a better way but CHMOD seems to work.
  call ToDsSiCx
  mov ax,MkMajMin($DosChmod,0)
; Make it ASCIIZ for CHMOD request
  mov dx,siúadd si,cxúmov bl,Bptr[si]úmov Bptr[si],al
  int 21húmov Bptr[si],bl; Un-ASCIIZ-fy
  z V.Mantissaúz V.ExpAnd
  jc @Fúinc V.MantLowú@@:
  RetSi

CONFIG_STREAM_COMMAND$$:
 Error49Bp
CONFIG_STREAM_STATE$$:
 Error49Bp

CONFIG_TIME$$:Upúmov V.Dtype,$NullString+7
if 0
 mov ecx,1436244chúmov Dptr V.String,ecx
 mov ecx,87130a02húmov Dptr V.String+4,ecx
 ret
; That was bug stabilize
endif
; Construct a stack value with all that DOS tells us.
MidNight:mov ah,$DosDateúint 21h;cx=year(1980+) dh=month dl=day
 sub cx,1980úmov V.String+6,clúmov Wptr V.String+4,dx
 mov ah,$DosTimeúint 21h;ch=hour cl=minute dh=second dl=hundredth
 mov Wptr V.String+2,cxúmov Wptr V.String,dx
 mov ah,$DosDateúint 21húcmp dl,V.String+4újne MidNight
; DOS doesn't tell local time adjustment for daylight.
 ret

