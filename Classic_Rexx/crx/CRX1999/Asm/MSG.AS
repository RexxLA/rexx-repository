; Sort $descs when Zone stabilizes
; RCK when commands work.
comment~ TraceBack starts knowing execution is in file Z.File, at the
level of Z.Level.  CursorSi will say where the execution is in the relevant
Pcode. Routine Cursor2Clause will work out what clause & line number that
corresponds to. (Since the clause is shown in the traceback it looks like
we don't need to also have the name of the routine. However, there are
messages with <name> inserts so keep the name for that purpose.)

The callers are found on the UpLevel chain through the level blocks. There
is an IsExternal flag on the top level for a file, indicating that the caller's
L.File should be copied to Z.File when the caller becomes current.

~
; Copyright Formcroft Ltd 1997-1999
 .model small�.486�.code
 include always.inc; Assembler shorthands like 'Bptr' for 'byte ptr'.
 include declares.inc; Symbolic constants, macros, records, structures.
 PUBLIC MakeMsg
 PUBLIC ShowMsg
 PUBLIC TargetMsg; Used by ERRORTEXT
 EXTERN BifNames:near; Label for lookup of bif insert.
 EXTERN Keys:near; Label to help compaction - use words from keyword table.
 EXTERN Exit:near; Label to exit.
; See the MSGC utility amongst my WARP programs for making of cmp.inc
; (That takes IS.MSG as uncompressed input. Descriptions order to be matched.)
; Avoid first offset in compressed msgs being zero. Not edited.
                                                               include cmp.inc
comment~ There is either going to be a message (and termination) or SIGNAL ON
SYNTAX.  The description inserts in some messages are not specified by the
Standard.  See our raw message text for the prose of these.  The numbers there
must match $Desc... values.

Fairly complicated, with layers of routines, because of decompression and
inserts.
~

;------------------------------------------------------------------------------
; MakeMsg - Construct the message specified by ax.
; With adjustments for special cases.
;------------------------------------------------------------------------------

MakeMsg:push bx�mv ds,cs
; There are actually two or three messages as far as the ErrorText is
; concerned. A 0.1 or 0.2 to locate the problem, then a Z.Insert.MajMin,
; then maybe an implementation provided Description.
; (A 0.3 is done by calling TargetMsg directly)
; The component messages are made in sequence so that values for inserts
; can change between components.
; Assert - nothing Insert does will need Z.Stack increase.
; We cannot use Z.Serial as workspace because Z.Insert.TokPos points into it.
 mov StackDi,Z.Stack�Up
 mov Z.MsgSoFar,StackDi�mov Z.MsgBegin,StackDi
 add Z.Stack,$MaxPreInsert+5*$Limit_Insert�call StackSafe
 mov ax,MkMajMin(0,1)�
; !! inc ax when interactive
 call TargetMsg
 move Z.InsLine,Z.ClauseLine�mov ax,Z.Insert.MajMin�call TargetMsg
; Luckily, the <description> is always last in the messages. So it just sets
; a flag, acted on here.
 btr Z.Cancel,Description�jnc @F
 mov ah,$Descriptions�mov al,Z.Insert.Desc�call TargetMsg
@@:pop bx�ret

;------------------------------------------------------------------------------
; TargetMsg - Expand the message specified by ax.
; Flag says whether inserts are to be expanded.
;------------------------------------------------------------------------------
TargetMsg:mov Z.TargetMajMin,ax
CharCx is <cx>; Testing insert letter
CharCl is <cl>; Testing insert letter
CharAl is <al>; Testing insert letter
CurrentByteAx is <ax>; AH is kept zero. (LODS used)
LowCurrentByteAl is <al>
 mv es,ss
; Now the scan. Start at -1 because there is a message 0.
; Put the msg without inserts somewhere it can be copied left while inserting.
 mov MajMinDx,MkMajMin(-1,0)�mov di,Z.MsgSoFar�add di,$MsgRoom�push di
 z CurrentByteAx�z DepthBl
 mov si,offset MsgcPacked�mov cx,MsgcUnits�call MovePart
; Raw message is now at [Z.MsgSoFar]+$MsgRoom..., ending before di.
 mov Z.PreZi,di�pop si; [Z.MsgSoFar]+$MsgRoom
; Uppercase the first letter.
 cmp Bptr[si+bp],'<'�je @F�and Bptr[si+bp],0DFh�@@:
 mov di,Z.MsgSoFar; Next copy is to Z.MsgSoFar
 mv ds,ss; Shuffle ds to save prefixing�jmp WhileInsert
LoopInsert:lodsb�cmp CharAl,'<'�jne NotIns
; For the builtin, inserts are left unaltered.
 Qry Z.Cancel,ForBIF�jnz NotIns
; The <> are not kept
 lodsb
; Insert does switches on what sort of insert.
 z cx�mov cl,al�sub CharCl,'a'-1;
 push si�call Insert�mv ds,ss�pop si
 ; Skip past next '>'
@@:lodsb�cmp CharAl,'>'�jne @B�jmp WhileInsert
NotIns:stosb; Plain copy when not inserting.
WhileInsert:cmp si,Z.PreZi�jb LoopInsert
 mv ds,cs�mov Z.MsgSoFar,di�ret; From TargetMsg

Insert:
; We are set up with es=ss so that movsb will be into message buffer.
; We are set up with ds=ss which can be changed.
; ax & & bx & dx free to use. cx free after finding which insert.
; si to first letter of insert type, free for reuse.
 loop Nota;<argnumber>
 movzx ax,Z.Insert.ArgNum�jmp ShowAx
Nota:loop Notb;<bif>
; Reverse lookup - Bif number to spelling.
 mv ds,cs�mov si,offset BifNames; Where spellings are laid out.
PerBif:mov cx,si
@@:lodsb�sub al,$BifTag�jb @B
 cmp al,Z.InsBif�jne PerBif
 xchg cx,si�sub cx,si�dec cx
MoveQuit:rep movsb�ret
Notb:loop Notc;<char>�mov al,Z.Insert.Char�stosb�ret
Notc:loop Notd;<description>�On Z.Cancel,Description�ret
Notd:dec CharCx�dec CharCx�dec CharCx
 loop Noth;<hex-encoding>�movzx ax,Z.Insert.Hex�mov Z.Radix,16�jmp ShowAx
; Code moved to bring loop Notk into range.
; It takes about 143 bytes of code to do this keywords insert.  Actually
; expanding in the original message might do better - there are 64 elements.
DoneArray:
 TestReg ax�jnz AnotherPass�mv es,ss�mov di,Z.Insert.KeysList�mov bx,sp
InsKey:
 mov si,ss:[bx]�mov cl,[si]�and cl,mask KeyLen�inc si�rep movsb
 inc bx�inc bx�mov cx,dx�sub cx,bx�jz InsDone
; Early separators are ", "
 mov ax," ,"�stosw�cmp cl,2�jne InsKey
; Last separator is ", or " or " or " depending if total list was two items.
 dec di�mov cx,bx�sub cx,sp�cmp cl,2�jne @F�dec di�@@:
 mov ax,"o "�stosw�mov ax," r"�stosw�jmp InsKey
InsDone:mov sp,dx; recover data space used.�ret
Noth:dec CharCx�dec CharCx
 loop Notk;<keywords>
; Everything with this insert will be a error state preceeded by keys offset.
 mv es,cs�mv ds,cs
 mov si,Z.Insert.KeysList�mov si,[si-2]; To keyword list
 mov Z.Insert.KeysList,di; Just a place to save it.
 z ax�mov dx,sp
; Run down the list in keyword table, pushing to make an array of offsets.
; First byte is data. Second byte is data including keyword length.
@@:add si,ax�inc si�push si
 lodsb�and al,mask EndList+mask KeyLen; FORM has KeyFlags
 btr ax,EndList�jnc @B
AnotherPass:; Stack from sp up thru dx has the pointers to keywords.
 z ax�mov bx,sp
AnotherPair:; Compare this one with one above.
 mov cx,dx�sub cx,bx�dec cx�dec cx�jz DoneArray; One left not enough for pair.
 mov si,ss:[bx]�inc bx�inc bx�mov di,ss:[bx]�
; Compare at shorter length
 mov cl,[si]�and cl,mask KeyLen�cmp cl,[di]�jb @F�mov cl,[di]�@@:
 inc si�inc di�repe cmpsb�jbe AnotherPair
; Exchange needed.
 mov di,ss:[bx]�xchg di,ss:[bx-2]�mov ss:[bx],di�inc ax�jmp AnotherPair
Notk:loop Notl;<linenumber>�mov ax,Z.InsLine
ShowAx:call Ax2DsSiCx�jmp MoveQuit
Notl:dec CharCx
 loop Notn;<name>  NYI SIGNAL VALUE dud
 mov ds,Z.Symbols�mov si,Z.Insert.Named�movzx cx,Bptr[si]�inc si�jmp MoveQuit
Notn:loop Noto;<optionslist><operator>  <operation>!!
 cmp Bptr[si+bp+8],'>'�je NotnTemp
 cmp Bptr[si+bp+7],'>'�jne @F
NotnTemp:
; A synchronisation has been done when messages are put out, so we can use
; Z.InsOperator.
 mov si,Zshape.InsOperator�movzx cx,Bptr[si+bp]�inc si�jmp MoveQuit
@@:mov si,Z.Insert.Options
@@:lodsb cs:Bptr[si]�stosb�cmp si,Z.Insert.OptsHi�jbe @B
SomeRet:ret
Noto:loop Notp;<position>�mov ax,Z.Insert.Position�jmp ShowAx

Notp:dec CharCx�dec CharCx
 loop Nots;<source><sourceline()>
 cmp Bptr[si+bp+5],'>'�jne Notsr
 lds bx,Z.InsSource�lea si,Jbx.Key�mov cx,Jbx.KeyLen�jmp MoveQuit

Notsr:lds bx,Z.SysFile�mov ax,Wptr F.Lines�jmp ShowAx

Nots:loop Nott;<token>
 Qry Z.Cancel,TokIsValue�jnz AsValue
 mov si,Z.Insert.TokPos�mov cx,Z.Insert.TokLen
LimitedInsert:
 z bx; "..." indicator. Should depend on quotes but that is pedantic.
 cmp cx,$Limit_Insert�jna @F�mov cx,$Limit_Insert�inc bx�@@:
 JcxzQ LiA; Failsafe uninitialized
NotsLoop:lodsb
 ; If keyword, uppercase. (Where does it say that?)
 cmp Z.Insert.Major,27�jne @F�and al,0DFh�@@:
 stosb�loop NotsLoop
LiA:dec bx�jnz @F�mov al,'.'�stosb�stosb�stosb�@@:ret
Nott:; <values> are usually Rexx variable values but not always.
 cmp Z.TargetMajor,0�jnz @F
; In this case, <value> means Z.Insert.MajMin, the number of the error
; Have to make Z.Insert.MajMin in a readable form. Zero minor codes are not shown.
 movzx ax,Z.Insert.Major�cmp Z.Insert.Minor,0�jz ShowAx
 call Ax2DsSiCx�rep movsb�mov al,'.'�stosb�movzx ax,Bptr Z.Insert.Minor
JmpShowAx:jmp ShowAx
; In the rest of the cases a value is on the soft stack.
; There are nine cases where messages have two <value> inserts. Mostly they
; are adjacent values on the stack.
; However 26.8 and 33.1 need DIGITS() as a first <value>. It would be nice
; to trick that by making the message have, say, a <position> insert instead
; but that would upset bif ERRORTEXT.
; So "DIGITS() first" is indicated by non-zero Z.Insert.Digits.
; 26.11 & 26.12 need DIGITS as third <value>, which caller puts on the stack.
AsValue:
@@:z ax�xchg ax,Z.Insert.Digits�TestReg ax�jnz JmpShowAx
 push di�mov di,Z.Insert.Value
 add Z.Insert.Value,$StrideV�call ToDsSiCx�pop di�mv es,ss�jmp LimitedInsert
;Insert ends

; MovePart - Expanding a piece of the compressed messages.
; All the text for all messages is scanned but it is not expanded until the
; relevant message is reached.
MovePart:; Recursive; Assert PartLenCx not zero.
 cmp bl,50�jna MPloop�Error49Bp;Unexpected recursion in message production.
MPloop:lodsb
; Lowest values are three special cases.
 cmp LowCurrentByteAl,0�jne NotKeyword
; convert from keyword specified in next byte to keyword itself.
; MASM bug pad ......................................................
 lodsb�dec PartLenCx�push PartLenCx�push ScannerSi�cmp TheMsgBh,0�jz UnitDone
 mov ScannerSi,offset Keys�mov KeywordOffsetCx,CurrentByteAx�add cx,cx�add cx,si
; Loop until ScannerSi is at the one we want.
 dec ScannerSi
@@:inc ScannerSi�inc ScannerSi�mov al,Bptr[ScannerSi]�and al,15; length
 cmp ScannerSi,KeywordOffsetCx�jae @F�add ScannerSi,CurrentByteAx�jmp @B
; Literal of keyword follows.
@@:z PartLenCx�mov LowPartLenCl,al�inc ScannerSi�rep movsb�jmp UnitDone
NotKeyword:push PartLenCx�push ScannerSi
 dec LowCurrentByteAl�jz BumpMinorDl�dec LowCurrentByteAl�jz BumpMajorDh
 cmp LowCurrentByteAl,MsgcFragsLo-2�jb Unique
; A fragment to be expanded, details in an array.
 mov si,CurrentByteAx; Index to Ushort
 add si,si�mov PartLenCx,[si]+(offset MsgcIndex)-(MsgcFragsLo-2)*2
; This UShort has position and length packed in it 12:4.
 mov ScannerSi,PartLenCx�shr ScannerSi,4�add ScannerSi,offset MsgcPacked
 and PartLenCx,0Fh�inc2 PartLenCx
 inc DepthBx�call MovePart�dec DepthBx; Recursion
UnitDone:pop ScannerSi�pop PartLenCx�LoopQ MPloop�ret

Unique:; Reached the depths - a character from amongst the uniques in original.
 cmp TheMsgBh,0�jz UnitDone
 mov si,CurrentByteAx�add si,offset MsgcUniques-1�movsb�jmp UnitDone

BumpMajorDh:inc MajorDh�z MinorDl�jmp @F
BumpMinorDl:inc MinorDx
@@:; TheMsgBh reflects whether we are in the message we want.
 z TheMsgBh�cmp MajMinDx,Z.TargetMajMin�jne @F�inc TheMsgBh�jmp UnitDone
@@:jb UnitDone
; Can't take advantage of passing over the target until recursion unwound.
 TestReg DepthBl�jne UnitDone
 pop ScannerSi�pop PartLenCx; Alternate pop to that at UnitDone
 ret

ShowMsg:; Show it, in chunks up to $MsgChunk
; A touch of over-engineering because ANSI says don't worry about whether
; message will get words split across lines.
ResidueAx is <ax>
ChunkCx is <cx>
SoFarDx is <dx>
 mv ds,ss�mov bx,Z.Stderr; On this file
 mov SoFarDx,Z.MsgBegin; From here to di
ShowMsgLoop:mov ax,di�sub ResidueAx,SoFarDx; Length remaining
 mov ChunkCx,$MsgChunk�cmp ResidueAx,ChunkCx�jna ShowMsgL
; Overlong. Break at rightmost blank in chunk.
 mov ax,ChunkCx�mov si,SoFarDx�add si,ChunkCx
@@:cmp Bptr[si],' '�je ShowMsgLine�dec si�loop @B
ShowMsgL:mov ChunkCx,ax
ShowMsgLine:mov ah,$DosWrite�int 21h; Takes DS:DX & CX
 add SoFarDx,ChunkCx�cmp SoFarDx,di�jne @F�ret�@@:
; Prefix the rest with newline.
 dec SoFarDx�dec SoFarDx�mov si,SoFarDx�mov Wptr[si],0A0Dh
 jmp ShowMsgLoop
 end
