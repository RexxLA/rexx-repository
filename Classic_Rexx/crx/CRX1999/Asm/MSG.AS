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
 .model smallú.486ú.code
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

MakeMsg:push bxúmv ds,cs
; There are actually two or three messages as far as the ErrorText is
; concerned. A 0.1 or 0.2 to locate the problem, then a Z.Insert.MajMin,
; then maybe an implementation provided Description.
; (A 0.3 is done by calling TargetMsg directly)
; The component messages are made in sequence so that values for inserts
; can change between components.
; Assert - nothing Insert does will need Z.Stack increase.
; We cannot use Z.Serial as workspace because Z.Insert.TokPos points into it.
 mov StackDi,Z.StackúUp
 mov Z.MsgSoFar,StackDiúmov Z.MsgBegin,StackDi
 add Z.Stack,$MaxPreInsert+5*$Limit_Insertúcall StackSafe
 mov ax,MkMajMin(0,1)ú
; !! inc ax when interactive
 call TargetMsg
 move Z.InsLine,Z.ClauseLineúmov ax,Z.Insert.MajMinúcall TargetMsg
; Luckily, the <description> is always last in the messages. So it just sets
; a flag, acted on here.
 btr Z.Cancel,Descriptionújnc @F
 mov ah,$Descriptionsúmov al,Z.Insert.Descúcall TargetMsg
@@:pop bxúret

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
 mov MajMinDx,MkMajMin(-1,0)úmov di,Z.MsgSoFarúadd di,$MsgRoomúpush di
 z CurrentByteAxúz DepthBl
 mov si,offset MsgcPackedúmov cx,MsgcUnitsúcall MovePart
; Raw message is now at [Z.MsgSoFar]+$MsgRoom..., ending before di.
 mov Z.PreZi,diúpop si; [Z.MsgSoFar]+$MsgRoom
; Uppercase the first letter.
 cmp Bptr[si+bp],'<'úje @Fúand Bptr[si+bp],0DFhú@@:
 mov di,Z.MsgSoFar; Next copy is to Z.MsgSoFar
 mv ds,ss; Shuffle ds to save prefixingújmp WhileInsert
LoopInsert:lodsbúcmp CharAl,'<'újne NotIns
; For the builtin, inserts are left unaltered.
 Qry Z.Cancel,ForBIFújnz NotIns
; The <> are not kept
 lodsb
; Insert does switches on what sort of insert.
 z cxúmov cl,alúsub CharCl,'a'-1;
 push siúcall Insertúmv ds,ssúpop si
 ; Skip past next '>'
@@:lodsbúcmp CharAl,'>'újne @Bújmp WhileInsert
NotIns:stosb; Plain copy when not inserting.
WhileInsert:cmp si,Z.PreZiújb LoopInsert
 mv ds,csúmov Z.MsgSoFar,diúret; From TargetMsg

Insert:
; We are set up with es=ss so that movsb will be into message buffer.
; We are set up with ds=ss which can be changed.
; ax & & bx & dx free to use. cx free after finding which insert.
; si to first letter of insert type, free for reuse.
 loop Nota;<argnumber>
 movzx ax,Z.Insert.ArgNumújmp ShowAx
Nota:loop Notb;<bif>
; Reverse lookup - Bif number to spelling.
 mv ds,csúmov si,offset BifNames; Where spellings are laid out.
PerBif:mov cx,si
@@:lodsbúsub al,$BifTagújb @B
 cmp al,Z.InsBifújne PerBif
 xchg cx,siúsub cx,siúdec cx
MoveQuit:rep movsbúret
Notb:loop Notc;<char>úmov al,Z.Insert.Charústosbúret
Notc:loop Notd;<description>úOn Z.Cancel,Descriptionúret
Notd:dec CharCxúdec CharCxúdec CharCx
 loop Noth;<hex-encoding>úmovzx ax,Z.Insert.Hexúmov Z.Radix,16újmp ShowAx
; Code moved to bring loop Notk into range.
; It takes about 143 bytes of code to do this keywords insert.  Actually
; expanding in the original message might do better - there are 64 elements.
DoneArray:
 TestReg axújnz AnotherPassúmv es,ssúmov di,Z.Insert.KeysListúmov bx,sp
InsKey:
 mov si,ss:[bx]úmov cl,[si]úand cl,mask KeyLenúinc siúrep movsb
 inc bxúinc bxúmov cx,dxúsub cx,bxújz InsDone
; Early separators are ", "
 mov ax," ,"ústoswúcmp cl,2újne InsKey
; Last separator is ", or " or " or " depending if total list was two items.
 dec diúmov cx,bxúsub cx,spúcmp cl,2újne @Fúdec diú@@:
 mov ax,"o "ústoswúmov ax," r"ústoswújmp InsKey
InsDone:mov sp,dx; recover data space used.úret
Noth:dec CharCxúdec CharCx
 loop Notk;<keywords>
; Everything with this insert will be a error state preceeded by keys offset.
 mv es,csúmv ds,cs
 mov si,Z.Insert.KeysListúmov si,[si-2]; To keyword list
 mov Z.Insert.KeysList,di; Just a place to save it.
 z axúmov dx,sp
; Run down the list in keyword table, pushing to make an array of offsets.
; First byte is data. Second byte is data including keyword length.
@@:add si,axúinc siúpush si
 lodsbúand al,mask EndList+mask KeyLen; FORM has KeyFlags
 btr ax,EndListújnc @B
AnotherPass:; Stack from sp up thru dx has the pointers to keywords.
 z axúmov bx,sp
AnotherPair:; Compare this one with one above.
 mov cx,dxúsub cx,bxúdec cxúdec cxújz DoneArray; One left not enough for pair.
 mov si,ss:[bx]úinc bxúinc bxúmov di,ss:[bx]ú
; Compare at shorter length
 mov cl,[si]úand cl,mask KeyLenúcmp cl,[di]újb @Fúmov cl,[di]ú@@:
 inc siúinc diúrepe cmpsbújbe AnotherPair
; Exchange needed.
 mov di,ss:[bx]úxchg di,ss:[bx-2]úmov ss:[bx],diúinc axújmp AnotherPair
Notk:loop Notl;<linenumber>úmov ax,Z.InsLine
ShowAx:call Ax2DsSiCxújmp MoveQuit
Notl:dec CharCx
 loop Notn;<name>  NYI SIGNAL VALUE dud
 mov ds,Z.Symbolsúmov si,Z.Insert.Namedúmovzx cx,Bptr[si]úinc siújmp MoveQuit
Notn:loop Noto;<optionslist><operator>  <operation>!!
 cmp Bptr[si+bp+8],'>'úje NotnTemp
 cmp Bptr[si+bp+7],'>'újne @F
NotnTemp:
; A synchronisation has been done when messages are put out, so we can use
; Z.InsOperator.
 mov si,Zshape.InsOperatorúmovzx cx,Bptr[si+bp]úinc siújmp MoveQuit
@@:mov si,Z.Insert.Options
@@:lodsb cs:Bptr[si]ústosbúcmp si,Z.Insert.OptsHiújbe @B
SomeRet:ret
Noto:loop Notp;<position>úmov ax,Z.Insert.Positionújmp ShowAx

Notp:dec CharCxúdec CharCx
 loop Nots;<source><sourceline()>
 cmp Bptr[si+bp+5],'>'újne Notsr
 lds bx,Z.InsSourceúlea si,Jbx.Keyúmov cx,Jbx.KeyLenújmp MoveQuit

Notsr:lds bx,Z.SysFileúmov ax,Wptr F.Linesújmp ShowAx

Nots:loop Nott;<token>
 Qry Z.Cancel,TokIsValueújnz AsValue
 mov si,Z.Insert.TokPosúmov cx,Z.Insert.TokLen
LimitedInsert:
 z bx; "..." indicator. Should depend on quotes but that is pedantic.
 cmp cx,$Limit_Insertújna @Fúmov cx,$Limit_Insertúinc bxú@@:
 JcxzQ LiA; Failsafe uninitialized
NotsLoop:lodsb
 ; If keyword, uppercase. (Where does it say that?)
 cmp Z.Insert.Major,27újne @Fúand al,0DFhú@@:
 stosbúloop NotsLoop
LiA:dec bxújnz @Fúmov al,'.'ústosbústosbústosbú@@:ret
Nott:; <values> are usually Rexx variable values but not always.
 cmp Z.TargetMajor,0újnz @F
; In this case, <value> means Z.Insert.MajMin, the number of the error
; Have to make Z.Insert.MajMin in a readable form. Zero minor codes are not shown.
 movzx ax,Z.Insert.Majorúcmp Z.Insert.Minor,0újz ShowAx
 call Ax2DsSiCxúrep movsbúmov al,'.'ústosbúmovzx ax,Bptr Z.Insert.Minor
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
@@:z axúxchg ax,Z.Insert.DigitsúTestReg axújnz JmpShowAx
 push diúmov di,Z.Insert.Value
 add Z.Insert.Value,$StrideVúcall ToDsSiCxúpop diúmv es,ssújmp LimitedInsert
;Insert ends

; MovePart - Expanding a piece of the compressed messages.
; All the text for all messages is scanned but it is not expanded until the
; relevant message is reached.
MovePart:; Recursive; Assert PartLenCx not zero.
 cmp bl,50újna MPloopúError49Bp;Unexpected recursion in message production.
MPloop:lodsb
; Lowest values are three special cases.
 cmp LowCurrentByteAl,0újne NotKeyword
; convert from keyword specified in next byte to keyword itself.
; MASM bug pad ......................................................
 lodsbúdec PartLenCxúpush PartLenCxúpush ScannerSiúcmp TheMsgBh,0újz UnitDone
 mov ScannerSi,offset Keysúmov KeywordOffsetCx,CurrentByteAxúadd cx,cxúadd cx,si
; Loop until ScannerSi is at the one we want.
 dec ScannerSi
@@:inc ScannerSiúinc ScannerSiúmov al,Bptr[ScannerSi]úand al,15; length
 cmp ScannerSi,KeywordOffsetCxújae @Fúadd ScannerSi,CurrentByteAxújmp @B
; Literal of keyword follows.
@@:z PartLenCxúmov LowPartLenCl,alúinc ScannerSiúrep movsbújmp UnitDone
NotKeyword:push PartLenCxúpush ScannerSi
 dec LowCurrentByteAlújz BumpMinorDlúdec LowCurrentByteAlújz BumpMajorDh
 cmp LowCurrentByteAl,MsgcFragsLo-2újb Unique
; A fragment to be expanded, details in an array.
 mov si,CurrentByteAx; Index to Ushort
 add si,siúmov PartLenCx,[si]+(offset MsgcIndex)-(MsgcFragsLo-2)*2
; This UShort has position and length packed in it 12:4.
 mov ScannerSi,PartLenCxúshr ScannerSi,4úadd ScannerSi,offset MsgcPacked
 and PartLenCx,0Fhúinc2 PartLenCx
 inc DepthBxúcall MovePartúdec DepthBx; Recursion
UnitDone:pop ScannerSiúpop PartLenCxúLoopQ MPloopúret

Unique:; Reached the depths - a character from amongst the uniques in original.
 cmp TheMsgBh,0újz UnitDone
 mov si,CurrentByteAxúadd si,offset MsgcUniques-1úmovsbújmp UnitDone

BumpMajorDh:inc MajorDhúz MinorDlújmp @F
BumpMinorDl:inc MinorDx
@@:; TheMsgBh reflects whether we are in the message we want.
 z TheMsgBhúcmp MajMinDx,Z.TargetMajMinújne @Fúinc TheMsgBhújmp UnitDone
@@:jb UnitDone
; Can't take advantage of passing over the target until recursion unwound.
 TestReg DepthBlújne UnitDone
 pop ScannerSiúpop PartLenCx; Alternate pop to that at UnitDone
 ret

ShowMsg:; Show it, in chunks up to $MsgChunk
; A touch of over-engineering because ANSI says don't worry about whether
; message will get words split across lines.
ResidueAx is <ax>
ChunkCx is <cx>
SoFarDx is <dx>
 mv ds,ssúmov bx,Z.Stderr; On this file
 mov SoFarDx,Z.MsgBegin; From here to di
ShowMsgLoop:mov ax,diúsub ResidueAx,SoFarDx; Length remaining
 mov ChunkCx,$MsgChunkúcmp ResidueAx,ChunkCxújna ShowMsgL
; Overlong. Break at rightmost blank in chunk.
 mov ax,ChunkCxúmov si,SoFarDxúadd si,ChunkCx
@@:cmp Bptr[si],' 'úje ShowMsgLineúdec siúloop @B
ShowMsgL:mov ChunkCx,ax
ShowMsgLine:mov ah,$DosWriteúint 21h; Takes DS:DX & CX
 add SoFarDx,ChunkCxúcmp SoFarDx,diújne @Fúretú@@:
; Prefix the rest with newline.
 dec SoFarDxúdec SoFarDxúmov si,SoFarDxúmov Wptr[si],0A0Dh
 jmp ShowMsgLoop
 end
