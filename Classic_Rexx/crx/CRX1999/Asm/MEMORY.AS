; Copyright Formcroft Ltd 1997
 .model smallú.486ú.code
 include always.inc; Assembler shorthands like 'Bptr' for 'byte ptr'.
 include declares.inc; Symbolic constants, macros, records, structures.
 EXTERN Exit:near

comment~

Intel xx86 hardware has a segmented model. One can move a segment in memory and
just change the segment pointer to keep addressibility to it's content.  The
segment register used by a hardware instruction is often implied by the
instruction.

The hardware model for data is therefore:

                           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                           ³             ³
                           ³             ³
                           ³             ³
 Stack pointer lowers      ³             ³
           with a push ==> ³-------------³
                           ³             ³
                           ³             ³
                           ³             ³
                           ³             ³
                           ³             ³
                           ³             ³
 Stack Segment Register ==>ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ<== Maybe Data Segment also.

The hardware has one byte signed offsets when addressing data so (spacewise) the
low 128 bytes of a segment are the best place for data.
                           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                           ³             ³
                           ³             ³
                           ³             ³
 Stack pointer lowers      ³             ³
           with a push ==> ³-------------³
                           ³             ³
                           ³             ³
                           ³             ³
                           ³             ³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³  128 bytes  ³
 Stack Segment Register ==>ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ<== Maybe Data Segment also.

If we are willing to use 64K of data, as a minimum, we can have two of these
efficient areas.
                       64K ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                           ³  128 bytes  ³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³             ³
                           ³             ³
 Stack pointer lowers      ³             ³
           with a push ==> ³-------------³
                           ³             ³
                           ³             ³
                           ³             ³
                           ³             ³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³  128 bytes  ³
 Stack Segment Register ==>ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ<== Maybe Data Segment also.

Whether to have two is a build choice, dependent on the platform.

Another worthwhile addition is a serially reusable space. (eg for input from
different files at different times.)  This is similar to any other one-off data
that will not fit in the more efficient areas.

                        64KÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                           ³  128 bytes  ³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³             ³
                           ³             ³
 Stack pointer lowers      ³             ³
           with a push ==> ³-------------³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³ SerialSpace ³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³  More Data  ³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³  128 bytes  ³
 Stack Segment Register ==>ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ<== Maybe Data Segment also.

It would be a poor use of memory if the "gap" between the current stack pointer
and the low end data was generally unused, so there will be data in the gap.
(Or adjustment of segment size to keep the gap relatively small.)
There will need to be a mechanism to copy with the stack growing over that data
(ie to move the data in the gap.)

Once there is a mechanism to cope with the stack growing over
the gap, we might as well have two stacks.  (When using one stack in the
push-pop way the other one can be used with push only so as to accumulate a
list.)

                        64KÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                           ³  128 bytes  ³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³             ³
                           ³ Hard Stack  ³
 Stack pointer lowers      ³             ³
           with a push ==> ³-------------³
                           ³             ³
                           ³ Gap         ³
                           ³   Data      ³
 Soft pointer goes up with ³      Moves  ³
              a push   ==> ³-------------³
                           ³             ³
                           ³ Soft Stack  ³
                           ³             ³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³ SerialSpace ³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³  More Data  ³
                           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                           ³  128 bytes  ³
 Stack Segment Register ==>ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ<== Maybe Data Segment also.

(Note 1999 scheme does not have data in the gap or 64K-always size.)

The Zshape declaration maps the fixed parts of the diagram above. The gap data,
and any other sources of memory, are managed on the basis of allocating on
demand, compacting by "garbage collection" as necessary.  To allow for the
compactions, Z.Stack must be valid when allocations are done.

Using Dos for each allocation is deemed too slow although allocation
isn't needed for strings less than 8 long or numbers that fit in 8 bytes.

There has to be a compaction scheme that repositions the strings
adjacent, otherwise there won't be reasonable areas to give back to
Dos when a command is issued.

Given that there is a compaction mechanism, it seems right not to keep
lists of free areas.  In this way our allocation goes without any
search and our freeing does nothing.

The price will be at compaction time.  A scan of the variables to
find those still with allocations is not too pricey (compared
with the actual string copying to be done anyway) but just knowing
what they are is not enough to reposition them. (It isn't very
practical to avoid the scan by keeping lists of things allocated
because of the difficulty of weeding things DROPped from the list.)

By sorted them by addresses of the strings it is possible to
copy them leftwards without risk of overwrite. (It is possible to copy
the strings onto a different arrangement of themselves by copying a
piece to a free place in the target area and then solving the
resulting lesser problem.  But it is messy and involves some
marking/searching.)

An advantage of sorting is that a series of compactions will tend to
move longer lived strings to the low addresses where they may stay
without moving on the next compaction.  Sorting can also detect the
case that several variables point to pieces of the same allocation.

If we are to use this mechanism for all data, it has to cope with things
that need to start at zero offset in a segment. (eg where the evenness
of the offsets of things in that data is used as a flag, or where we
want to exploit one byte offsets.) Call this paragraph allocation as
opposed to byte allocation.

seg:disp addresses can be normalized to use only 20 bits, or 16 if they
are paragraph allocated.

When control passes to Dos (on command or external call) there has to be
compaction followed by releasing as much memory as possible back to Dos.
On return from Dos, memory is taken from Dos. In principle more could be
released during Dos activity, by writing out data, reloading code and data.

Finding the variables with lengthy-string values is OK for the user
variables but harder for temporaries not explicitly referenced by the
Pcode, like the result of a || operation. These temporaries are on a
stack.

The SS segment is used for two stacks, at opposite ends. One is the
stack managed by the hardware. The other is the "soft" stack. In
addition to the return addresses stacked by hardware operations there
are various things to be stacked - parser states, control blocks for
invocation level, control blocks for DO level, the temporary values,
and a "what-used" list to be exploited when a procedure level is
returned from.  (For performance reasons we don't want to run a stack
in a separate segment for any of these.)

There are also some names as in DO Alpha.Beta=1 ...  end Alpha.Beta
that have to be held during parsing.  These can reasonably be in a
separate segment. (Although currently, Dec 97, on soft stack.)
(General space, 1999)

The temporaries "belong" to control blocks in the sense that when a
control block becomes current the pre-existing temporaries become
inaccessible (pushed-down).  So the temporaries can be addressed off
the control block address, provided nothing else intermingles.  This
leads to a design with parser states and "what-used" on the hard
stack, blocks and temps on the soft one. There are two sorts of temps.
There are the runtime ones, which have values, and compile time ones.
The compile time ones mimic the runtime ones but only have values if they are
constants.  They also serve to reduce the number of "Actions" in the BNF - an
action can test whether there is an operand stacked or not, avoiding the need
for the BNF to distinquish the cases via different actions.

Some details of Z.Stack, the boundary that 'protects' things on the soft
stack: Z.Stack is used in testing that there is enough "slack" between
the soft stack and the hard stack to cover temporary uses. At compile time
and runtime it is maintained so that Compaction knows what is on the
soft stack.
~
comment~ For compaction one needs a list of all things refered to.  We can use
the Z.Serial space for that list.  (And implement a soft paging if it is thought
necessary) Put the Zone, Code, Symbols, names array, and constants array into
list.  Scan up levels - put temporaries and procedure variables into list, plus
tailed en passant.  Every element in the list will represent something contained
within something else in the list.

The memory scheme depends only SS and what it accesses. Compaction may
reset other segment registers but the scheme isn't dependent on what the usage
is.

Memory scheme is to take from Dos and sub-allocate.  The table with elements
showing far pointer and size is to be set up.

Allocations for string variables are on byte boundaries with no header to
what is allocated. (This sometimes allows concatenation to be done by appending
to something previously allocated.) There are also segment allocations on
paragraph boundaries. These segments may be made re-sizeable by using a
header paragraph.

General approach to segments is to have five values - the number of paragraphs
in the segment, the number to increase by if necessary, the segment address, the
offset of available byte in the segment, and a trigger offset which causes
segment size increase if the 'available' offset reaches it.  Note that the
trigger may be deliberately short of the full size of the segment so that
limited use of the segment can be made without a check.

Each Rexx compound variable uses a segment, and the number of these is
unpredictable (given recursion), so they have to hold their management values
within the segment.

Notes on using the memory scheme:

The programmer need not think about compaction issues during runs of code
that do not call on compaction. Note however that the call can be
indirect - eg loading a string may mean numeric to string conversion which
may do allocation.

Subject to the above, segment pointers must not be stored except where the
compaction algorithm will find them.  This means OK in Rexx variables but
not OK to push or generally store.

Segment registers DS ES FS GS can be loaded at will but must address
things that will be found by compaction, if those segment registers are
to be updated by the compaction.

The rules above usually nullify the threat of compaction, even when
compaction would result in updated values in segment registers and in
Rexx variables.  Just occasionally the programmer will want to obtain
segment register pointers for two variables at once (eg to do Abut$$
operation).  The compaction threat is more intrusive then - the fact
that allocation returns carry to say if compaction happens must be used
to ensure that compaction does not happen between the fetches of the
segment values for the two variables. (And further care if a result space
is allocated.)

Here is an overview of the compaction algorithm.  The tree of what needs
to be compacted is stepped over, forming a physically compact array of far
pointers to "Rexx pointers".  The latter are far pointers with a physically
adjacent length field, usually six bytes of the eight representing a long
string value. Stage 2 sorts the compact array on the basis of the addresses
of the strings, ie not the addresses of the far pointers but of what they
point at.  Stage 3 moves through the array (and hence through strings
in address order) dynamically mapping where those strings will be moved to,
and changing the Rexx pointers to reflect that new mapping.  This leaves
all the data as it will be when compacted, but not in the compacted positions.
As each element in the array is used it is replaced by the current, ie
original, address and length of the corresponding data. Stage 4 moves through
the array and uses the lengths to repeat the new mapping - the actual moves
of data are made in this pass.
~
comment~ Another mechanism relates to the "serial" chunk of memory.  In
principle the same chunk can be used for many purposes, provided the uses are
disjoint (or if not disjoint are read-only and loadable from disk).

So it can be shared for different input streams of the user program, for
the source of the program (and INTERPRET), as workspace for compaction, ...
There are some complications in using the space for a message; the inserts of
the message may use the source or cause compaction. I think it is simpler to
take stack space dynamically for the message.
~

;------------------------------------------------------------------------------
; InitMemory is called just once, at startup.
;------------------------------------------------------------------------------
InitMemory:
; Whenever we give control to Dos we give it memory.  Here we go the other way.
; Ashapes are setup from Z.Shape.MemoryTable up to MemoryTableZi, describing
; the memory chunks to be allocated from.  They are ordered on addresses.
; The stosw need to match Ashape shape.
; We have already taken one segment, for the stack.
 mov cx,$Ashapes-1úmv es,ssúmov di,Zshape.MemoryTable
; Fill the first with stack details. It shows full so will not be allocated
; from.  (Will be freed by compaction.)
 mov ax,$InitStackSizeúpush axústoswúmov ax,ssústoswúpop axústosw
DosAlloc:mov bx,4095úmov ah,$DosAllocateúint 21hújnc @F
 test bx,bxúje DosEmptyúmov ah,$DosAllocateúint 21h
@@:; I think we are going to have to waste a paragraph to avoid problems,
; as when four bytes are picked up to get three. There won't be segment
; wraparound since we only took 4095 paras but there is risk of Dos blocks
; being overwritten. Play safe for now.
 dec bxúxchg ax,bpústoswúxchg ax,bpústoswúshl bx,4úxax bxústoswúloop DosAlloc
 jmp DosOrder
DosEmpty:; Fill the rest with zero amounts.
 z axústoswústoswústoswúloop DosAlloc
; Any simple method will do to sort them on segment pointer.
; This one just finds a needed exchange and starts over.
DosOrder:mov si,Zshape.MemoryTable-$StrideA
@@:add si,$StrideAúlea bx,[si+$StrideA]úcmp bx,diúje @F
; Pick up segment and amount. Loop for next if segments ordered.
 Assert Ashape.Amount eq Ashape.Fr.Sg+2
 mov edx,Dptr(A.Fr.Sg)úcmp dx,ss:Ashape.Fr.Sg[bx]újbe @B
; Exchange necessary. First the four bytes in hand, then the .Pt
 xchg edx,Dptr(ss:Ashape.Fr.Sg[bx])úmov Dptr(A.Fr.Sg),edx
 mov dx,A.Fr.Ptúxchg dx,ss:Ashape.Fr.Pt[bx]úmov A.Fr.Pt,dxújmp DosOrder
@@:
 mov si,Zshape.MemoryTable
 mov Z.FromDos,si
if MemCheck
 call DosMemCheck
endif
 ret

GiveDosMem:call Compaction
 mov si,Zshape.MemoryTable
GiveLoop:
 cmp A.Amount,ZeroBpúje NotSuited; Slot has not had anything from DOS
 cmp A.Fr.Pt,ZeroBpújne NotSuited; Slot part-used.
; Segment with nothing yet allocated in it. Give it back.
 mov ah,$DosFree
 mov es,A.Fr.Sg
 int 21h
if MemCheck
 call DosMemCheck
endif
 mov A.Amount,ZeroBpúmov A.Fr.Pt,ZeroBp
NotSuited:add si,$StrideAúcmp si,Zshape.MemoryTableZiújb GiveLoop
 ret

; 2011 Would be neater if integrated with original code.
GetDosMem: mov si,Zshape.MemoryTable
GetLoop:
 cmp A.Amount,ZeroBpúje NotSuitedx
 cmp A.Fr.Pt,ZeroBpújne NotSuitedx
; Segment with nothing now from DOS in it. Try to fill it.
 mov bx,4095úmov ah,$DosAllocateúint 21hújnc @F
 test bx,bxúje DosEmptyxúError49Bp
@@:
 mov A.Fr.Sg,axúshl bx,4úmov A.Amount,bx
NotSuitedx:add si,$StrideAúcmp si,Zshape.MemoryTableZiújb GiveLoop
DosEmptyx:
 call DosOrder; Our slots to have ascending addresses.
 ret
;------------------------------------------------------------------------------
; Byte level allocations.
; cx bytes requested. Returns result es:ax. cx unaltered. Carry = was compaction
;------------------------------------------------------------------------------
AllocateCx_EsAx:push si
PostCompact:mov si,Z.FromDosúmov Z.FromDosWas,si
AllocRetry:les ax,A.Frúadd ax,cxújc @Fúcmp ax,A.Amountúja @F
; When we return the Compacted flag will be off, carry will show compaction.
 mov A.Fr.Pt,axúsub ax,cx
if Debug
; 'h' through space. (Not in Compaction - overlapped moves etc.)
 pusha
 Qry Z.Cancel,MapOnlyújnz ACd
 mov di,axúmov al,'h'úrep stosb
ACd:popa
endif
 pop siúbtr Z.Cancel,Compactedúret
; Try the next slot.
@@:call NextDosúcmp si,Z.FromDosWasújne AllocRetry
 Qry Z.Cancel,Compactedújnz OverfullMem
 call CompactionúOn Z.Cancel,Compactedújmp PostCompact

OverfullMem:mov di,Zshape.ProgScope; Just to get a message <description>.
Overfull:; di tells us which segment has overfilled. Use that for good message.
 lea dx,[di]-(Zshape.SysFiles)úshr dx,1
;------------------------------------------------------------------------------
; Some limit exhausted.
;------------------------------------------------------------------------------
; NYI dl for QUEUE overflow.
;2011 There are various dl values to go with exhaustion because all of
;2011 memory may be used up even after compaction, or various segments
;2011 may have hit 64K, or limits on number of files or arguments
;2011 reached. The dl have to be matched to prose in message 55.n and
;2011 that is NYI 11/2011
Raise5p1:; Enter here with dl set for descriptionúmov ax,MkMajMin(5,1)
; If is the stack we had better make room for the message development.
 cmp dl,(Zshape.Zone-Zshape.SysFiles)/2újne @Fúsub Z.Stack,4096ú@@:
if Debug
 int 3
endif
jmp Raise
Raise5p1d:mov dl,$DescStringújmp Raise5p1
;------------------------------------------------------------------------------
; Make a new segment, that can change size later.
; SegOffDi is which segment (Zone offset). cx is initial size. bx triggers
; resize.
;------------------------------------------------------------------------------
InitSegDs:
 call ParaAllocAx
; Setup the Segp in the zone.
 mov Wptr[bp][SegOffDi],ax; Sets Z.Consts etc.
 mov ds,ax; A Hshape header is used for our memory management.
 z siúmov H.Link,SegOffDiúmov H.SegSize,cxúmov H.Bump,cx
 mov H.Trigger,bxúmov H.Avail,$StrideHúz H.Probeúz H.Labelsúz H.TreeBin
 ret

;------------------------------------------------------------------------------
; StackDi to new top-of-stack.
;------------------------------------------------------------------------------
UpStack:mov StackDi,Z.StackúUp; Note fall through.
;------------------------------------------------------------------------------
; Stack space to match StackDi
;------------------------------------------------------------------------------
SetStack:mov Z.Stack,StackDi
;------------------------------------------------------------------------------
; Stack ReSizing
;------------------------------------------------------------------------------
StackSafe:
; The stack segment is used for the Zone, the soft stack, some slack, the
; hardware stack, and the parser stack. (In that order of address value)
; Zone at [bp] and bp=0.
; Here we check that the slack is big enough.
; SS may be reset. DS is set to CS
; SP may alter.
$Slack equ 2048; Space DOS might need from our stack for interrupts, and
; other transient us by us.
 Assert $Slack mod 256 eq 0
RSSretry:push axúmov ax,Z.Stackúadd ah,$Slack/256
 cmp sp,axúpop axújb @Fúret; Normal case, there is spare room.
@@:; We will need more. (Better be a few spare for these pushes)úpusha
 mov cx,Z.SegSize;Old bytesúpush cxúadd cx,2048;Required bytes
 jnc @Fúmov cx,0FFFFh; will failú@@:
 mov SegOffDi,Zshape.Zone; For overfull msg.
 call ParaAllocAxúmov Z.SegSize,cxúpop cxúmov Z.Zone,ax
; ss to new spaceúmv ds,ssúmov ss,ax
; Copy the old area across a word at a time, leaving a gap in the middle.
 z siúshr cx,1údec siúdec si
OverOld:inc siúinc siúmov ax,Wptr[si]úcmp si,spújnb @F
 mov Wptr[si+bp],axúloop OverOld; Assert always branches.
@@:mov Wptr[si+bp+2048],axúloop OverOld
 add Z.ParseResetSp,2048
 add Z.XCycleResetSp,2048úadd sp,2048úmv ds,cs
; Return resultsúmov PushShape.sp_[esp],spúpopaújmp RSSretry
;------------------------------------------------------------------------------
; Extending a segment.
; ss:SegOffDi addresses the subject segment slot, in the Zone. That value of
; di is also in the segment itself. (Robustness check)
; ES set to the output segment, as is the segment slot.
;------------------------------------------------------------------------------
;Masm ......................
MoreSpaceEs:
 pushaúmov es,Z.w[SegOffDi]; From the Zone.
 cmp SegOffDi,He.Linkúje @Fúint 3úpopaúretú@@:
; Increase size of segment.
 mov dx,He.SegSize; Old bytesúmov cx,dxúadd cx,He.Bump; New bytes
 jnc @Fúmov cx,0FFFFh; will failú@@:
 call ParaAllocAx
; es will still be addressing the segment, even if moved.
; No more compaction threat now, so we can push-pop ds.
 push dsúmv ds,es; Same as mov ds,Z.w[SegOffDi]
; Update old with values that will be copied to new.
 mov Hd.SegSize,cxúmov cx,Hd.Bumpúadd Hd.Trigger,cx
 mov Z.w[SegOffDi],ax; Set pointer in Zone to new segment.
; Copy across old part. Assert SegSize a multiple of four.
if Debug
 test dx,3újz @Fúint 3ú@@:
 test Hd.SegSize,3újz @Fúint 3ú@@:
endif
 mov es,axúmov cx,dxúshr cx,2úz siúz diúrep movsdúpop dsúpopaúret

NextDos:; Move Z.FromDos (the segment allocations are from) onward, with wrap.
 mov si,Z.FromDosúadd si,$StrideA
 cmp si,Zshape.MemoryTableZiújne @Fúmov si,Zshape.MemoryTableú@@:
 mov Z.FromDos,si
 ret

AllocReset:; Reset the allocation tables to say "nothing allocated".
 mov si,Zshape.MemoryTableúmov Z.FromDos,si
@@:z A.Fr.Ptúadd si,$StrideAúcmp si,Zshape.MemoryTableZiújb @B
 ret

ParaAllocAx:; cx bytes requested. Returns in ax the segment value.
 push siúpush bxúpush dx
; We never give more than a segment's worth.
; In fact, we will keep the last paragraph free.  That means that if we
; choose to move three bytes by picking up four (say) then there is no
; risk of wrapping around the segment. (Which hardware objects to.)
 cmp cx,4095*16újae Overfull
ParaCompact:
; Does the one we used last time have room for cx bytes, aligned?
 mov si,Z.FromDosúmov dx,si
@@:mov bx,cx
 mov ax,A.Fr.Ptúadd ax,15úand al,-16; Round available offset upward.
 add bx,axújc ParaNextúcmp bx,A.Amountújna @F
; Try the next slot.
ParaNext:call NextDosúcmp si,dxújne @B
 Qry Z.Cancel,Compactedújnz OverfullMem
 call CompactionúOn Z.Cancel,Compactedújmp ParaCompact
; Adjust to make ax:0 returned.
@@:mov A.Fr.Pt,bxúshr ax,4úadd ax,A.Fr.Sgúbtr Z.Cancel,Compacted
if Debug
; 'g' through space. (Not in Compaction - overlapped moves etc.)
 push esúpusha
 Qry Z.Cancel,MapOnlyújnz @F
 mov es,axúz diúmov al,'g'úrep stosb
@@:popaúpop es
endif
 pop dxúpop bxúRetSi
;------------------------------------------------------------------------------
; Reuse of Z.Serial
; AL giving new role.
;------------------------------------------------------------------------------
comment~ The Rexx queue can be done as a file.  If this is a RAM disk file the
performance should be OK. There are cacheing possibilities within CRX if
performance proves to be a problem.  Using a fixed name for the queue is
simplest but means it has to be in current directory.  Using a name from
the environment (or OPTIONS) would be more flexible.
~
Serialize:cmp al,Z.SerialNowújne @F
; Seems best to always reload for an INTERPRET compile, otherwise lengthy
; check about whether the subject is unchanged.
 cmp al,$SerialInterpretúje @F
; Uses for source are different if not windowed onto the same place in source.
 cmp al,$SerialSourceújne SerialNop
 push axúmov eax,Z.Relativeúcmp eax,Z.RelativeNowúpop axúje SerialNop
@@:pusha; There may be things to do to preserve the previous content.
 xchg al,Z.SerialNowúcmp al,$SerialNoneúje SerialSaved
 cmp al,$SerialQueújne NotQueSave
; Dec 1999 model is to close the file after every use.
 mv ds,csúmov dx,offset Que
; It would not hurt to have zero length files but better to delete then.
; File needed unless length is zero. That is the first word in Z.Serial.
 cmp Wptr Z.Serial,ZeroBpújnz QueCreate
 mov ah,$DosDeleteúint 21hújmp SerialSaved
QueCreate:mov ah,$DosCreateúz cxúint 21hújc QueFailúmov bx,ax; File handle
; Write to it, and close.
 mv ds,ssúmov cx,Wptr Z.Serialúmov dx,offset Zshape.Serial+2
 mov ah,$DosWriteúint 21hújc QueFail
 mov ah,$DosCloseúint 21hújmp SerialSaved

NotQueSave:
; If it is $SerialInterpret then no need to save; can reload from other memory.
; If it is $SerialSource then no need to save; can reload from file.

SerialSaved:; Fetch the new contents, if there are to be any.
 cmp Z.SerialNow,$SerialNoneúje SerialFetched
 cmp Z.SerialNow,$SerialQueújne NotQueFetch
; Attempt to open the file holding the queue.
 mov ax,MkMajMin($DosOpen,2); Read&Write
 mv ds,csúmov dx,offset Queúint 21hújnc QueOpen
 cmp ax,2újne QueFail; Detect 'not found' case.
 z axújmp QueFetched
QueOpen:mov bx,ax; File handle
; Fill by read of a file.
 mv ds,ssúmov dx,offset Zshape.Serial+2úmov cx,sizeof Zshape.Serial-2
; (Should check oversize file?)
 mov ah,$DosReadúint 21hújc QueFailúpush axúmov ah,$DosCloseúint 21húpop ax
QueFetched:mov Wptr Z.Serial,axújmp SerialFetched

NotQueFetch:
 cmp Z.SerialNow,$SerialSourceújne NotSourceFetch

; Position source according to Z.Relative
 mov bx,Z.SourceHandle
 mov dx,Wptr Z.Relativeúmov cx,Wptr Z.Relative+2
 mov Wptr Z.RelativeNow,dxúmov Wptr Z.RelativeNow+2,cx
 mov ax,MkMajMin($DosSeek,0)úint 21h; Ask to move cx:dx from begin of file.
; Read from that position.
 mov dx,Zshape.Serialúmov cx,$SourceBufferSize-2úmv ds,ss
 mov ah,$DosReadúint 21h
 mov di,Zshape.Serial
 jnc @Fúz ax; Is it worth other than e-o-f for errors?ú@@:
; Compute the end position and put a marker there.
 add di,ax
; When we read a short amount it will be end-of-file. Add an $Eof in case there
; wasn't one.
 cmp cx,axúje @Fúmov Bptr[bp+di],$Eofúinc diú@@:
 mov Bptr [bp+di],$EndBuffer
 mov Z.EndUsedBuffer,diúsub di,$Leewayúmov Z.NearEnd,di
 jmp SerialFetched

NotSourceFetch:
 cmp Z.SerialNow,$SerialInterpretújne SerialFetched
; INTERPRET block is like a DO block.
 mov StackDi,Z.CurrentDO
 Qry D.Rec,IsInterpújnz @Fúint 3úError49Bpú@@:
 lea StackDi,D.Subjectúcall ToDsSiCx
; Copy the subject, a recent ToDsSiCx, to Parser's buffer.
 push es
; If we want to have very long interpret strings we will have to take care over
; compactions occurring when just part of the string has been fed through the
; source buffer. We would window, as we window on to the source file.
 cmp cx,$SourceBufferSize-3újna @FúError49Bpú@@:
 mv es,ssúmov di,Zshape.Serialúmov Z.Scanp,diúrep movsb
; Add something that compiling will see as end-of-file
 mov ax,StringOrder($Lf,$Eof)ústoswúmov Z.EndUsedBuffer,diúmov Bptr es:[di],$Lf
; Scanning will be stopped by end-of-source marker so Z.NearEnd need not be
; accurate.
 mov Z.NearEnd,diúpop es
SerialFetched:popa
SerialNop:ret

QueFail:mov ax,MkMajMin(48,0)úcall Raise

Que db "CRXREXX.QUE",0
;------------------------------------------------------------------------------
; Compacting the in-use allocations so as to free space for new allocations.
;------------------------------------------------------------------------------

comment~ There are choices about what is retained by compaction when there are
multiple external procedures in play.  The externals that are not active will
(on NORELOAD option) have their Pcode retained and addressed via SysFiles. That
doesn't affect Compaction except for having to note that these sections are
in play. The externals that are active will be found on the Level chain of the
stack. These will have VarScope and ProgScope (+ pools chained off) which
contain Rexx values.  They may also have Vars and Consts segments for rapid
Lookup of symbols but since Vars and Consts can be reconstructed from the
Symbols segment it makes sense to lose these at compaction and reconstruct on
demand. (Demand is for INTERPRET or unitialized.)
~

Gshape union; Used by compaction.
 struct
; In this form, the Farp addresses a FarpX which is for a segment or a Rexx
; long variable according to the Tag. (Incomplete in segment case)
  Mem Farp <>
  Tag byte ? ; 1 for paragraph allocation.
 ends
 struct; Shows shape but these names are not used.
  MoveLeng word ?
  MoveAddr byte 3 dup(?)
 ends
Gshape ends
;G. is for Gshape objects used by compaction.
; The code is simpler if we know the space for sorting is SS-addressable.
if SortSpaceSS
G is <(Gshape ptr[di+bp])>
Gsi is <(Gshape ptr[si+bp])>
else
G is <gs:(Gshape ptr[di])>
Gsi is <gs:(Gshape ptr[si])>
endif
$StrideG equ size Gshape

SortLoad macro tgt:req, arg:reqúlocal IsSegment
; Sets up the 32 bit target register to sort value of indexed subject.
; es:bx is first set to address pointer which is subject of comparison.
; That pointer may address a string (in which case the offset part is
; operative) or it may address a segment (in which case the data starts
; at zero offset). Collect data address as 20 bit value.
; Preserves ebx and allows bx as argument (but not tgt).
 push ebx
 cmp Gshape.Tag[arg],0úpushf; in case arg=bx
 les bx,Gshape.Mem[arg]úmovzx tgt,es:FarpX.Sg[bx]úshl tgt,4
 popfújne IsSegment
 movzx ebx,es:FarpX.Pt[bx]úadd tgt,ebx
IsSegment:
 pop ebx
 endm

if Debug
Dlook:pushad; di up should be sorted.
@@:SortLoad eax,di
 add di,$StrideGúcmp di,Z.Rightújna @B
 popadúret
endif

SortXchgEdx macro lhs:req,rhs:req
; Exchange elements of the array. Does not preserve edx.
 mov edx,Gshape.Mem[lhs]úxchg edx,Gshape.Mem[rhs]úmov Gshape.Mem[lhs],edx
 mov dl,Gshape.Tag[lhs]úxchg dl,Gshape.Tag[rhs]úmov Gshape.Tag[lhs],dl
 endm

SortCmpEadx macro rhs:reqúlocal IsSegment
; Compare element of the array. (What it points at, rebased, compared with eax)
; Preserves ebx and allows bx as argument.
 push ebx
 cmp Gshape.Tag[rhs],0úpushf
 les bx,Gshape.Mem[rhs]úmovzx edx,es:FarpX.Sg[bx]úshl edx,4
 popfújne IsSegment
 movzx ebx,es:FarpX.Pt[bx]úadd edx,ebx
IsSegment:
 cmp eax,edx
 pop ebx
 endm

OrderDleS:; Arrange order to be left less than or equal to right.
 SortLoad eax,LeftDi; Value based on LeftDi to eax.
 SortLoad edx,RightSi; Value based on RightSi to edx.
; Order left smaller than right
 cmp eax,edxújbe @FúSortXchgEdx LeftDi,RightSiú@@:ret

NoteSortee:; ds:bx to be recorded. That addresses Sg:Pt which describes data.
; al=1 iff paragraph allocation, when ds:bx addresses just the Segp.
; Record ds,bx,al under gs:di or under ss:di
; depending where the sort space is.
 push LevelDi
 mov di,Z.Right
; There is no need to record something that is pointing to something
; in the code segment - its target cannot move.
; This also allows us to use CS to mark null pointers.
 push axúmov ax,Vbx.Sgúcmp ax,Y.Csegúpop ax
 je NSret
if Debug
 cmp Vbx.Sg,ZeroBpújne @Fúint 3ú@@:
endif
 mov G.Mem.Sg,ds
 mov G.Mem.Pt,bx
 mov G.Tag,al
 cmp Vbx.Sg,100húja @Fúint 3ú@@:
if 0
; Just to view things.
    push eax ; Debug
    push ds
if SortSpaceSS
    mv ds,ss
else
    mv ds,gs
endif
    SortLoad eax,di
    pop ds
    cmp G.Tag,0újne @Fúmov ax,Vbx.Lenúcmp ax,2000újb @Fúint 3ú@@:
    pop eax
endif
if CD
Adump macro arg
 push axúmov ax,argúcall Adumperúpop ax
endm

Adump1 macro arg
 push axúmovzx ax,argúcall Adumperúpop ax
endm

; Show all the originals.
 pushaúpush es
 Adump 10
 movzx ax,G.Tag
 Adump ax
 Adump G.Mem.Sg
 Adump G.Mem.Pt
 mov es,G.Mem.Sg
 mov si,G.Mem.Pt
 mov cx,Wptr es:[si+2]úAdump cx
 TestReg axújnz @F
 mov cx,Wptr es:[si]úAdump cx
 mov cx,Wptr es:[si+4]úAdump cx
@@:
 pop esúpopa
endif
 add di,$StrideG
 cmp di,offset Zshape.Serial+sizeof Zshape.Serial
 jb NSret
if CD
 jmp Exit
endif
 Error49Bp; 501? !!
NSret:
 mov Z.Right,di
 pop LevelDi
 ret

; Take note of variables between bx and cx on the stack.
SorteesPlus:add bx,$StrideVúadd cx,$StrideV
; Note relevant variables in ds from bx up to (excluding) cx.
Sortees:
; !! this can't happen??
 push axúmov ax,dsúcmp ax,Y.Csegúpop axúje SorteeNull
 cmp bx,cxújne @F
SorteeNull:retú@@:
if Debug
 jb @Fúint 3ú@@:
endif
 cmp Vbx.Dtype,$AwayStringújne @Fúmov al,0úcall NoteSorteeú@@:
 cmp Vbx.Dtype,$Stemújne NextOfVars
; This is a stem.úmov al,1úcall NoteSortee
; The variables of the stem can be long strings.
 push bxúpush ds
 mov al,0úmov ds,Vbx.Sg; ds addresses the Jshapes that are
; variable+tree+key.
 mov TailSi,$StrideH; Steps through Vshapes, items in the stem.
NextOfStem:
 cmp Vsid.Dtype,$AwayStringújne @Fúmov bx,siúcall NoteSorteeú@@:
 add TailSi,J.KeyLenúadd TailSi,$StrideJ
 cmp TailSi,Hd.Availújb NextOfStemúpop dsúpop bx
NextOfVars:add bx,$StrideVújmp Sortees

Compaction:pusha
if CD
; Mark start on the dump.  See CD.REX program that shows results.

 Adump 5
 mov Z.DebugD,ebp
endif
; The allocate may overwrite ES later but
; SS, DS, ES, FS and GS are to be reloaded to appropriate values at the end of
; compaction. When they came in pointing to things allocated as segments
; they are returned pointing to those (maybe moved) segments.
; SS is a bit different - change it as soon as Zone moves.
 mov Z.DsWas,ds
 mov Z.EsWas,es
 mov Z.FsWas,fs
 mov Z.GsWas,gs
; If we don't find relevant segments, we will leave set them to CS because
; that is something they could correctly be addressing.
 mov Z.DsNew,cs
 mov Z.EsNew,cs
 mov Z.FsNew,cs
 mov Z.GsNew,cs
 z Z.PoolPool
comment~ Although the value in SS can vary during processing we can rely on it
addressing the expected fields (see Vshape).  From there there will be pointers
to any other segments to be retained.  In the segments we will be able to find
the variables because the rules for each segment are known.  In particular, the
SS segment has variables from Z.CurrentDO to Z.Stack.  These variables can point
to further segments but the upshot is that we can find what needs to be
compacted.

The algorithm is also commented on elsewhere but essentially:

There is one Zone and it has pointers to various segments (allocated on
paragraph boundaries).  The segment for user files is scanned to record the need
to retain user file buffers.  The (same) segment for source files is scanned to
retain the segments that have been compiled from the source.  SS points to the
soft stack as well as the Zone.  Z.Stack is the latest soft stack item.  Z.Level
is the latest level of invoke.  A level consists of the values (typically
arguments to the next level)(at high-address, top) then DO blocks then a Level
block.  The level block says where the DO blocks reach.  If the level is for an
external it also says where the compiled segments for that source are.  So
Z.Stack delimits the latest level, other levels delimited by their deeper level.

The per-level algorithm is:

The temporary values are scanned for which have references to things to be
retained.  The constants and variables are similarly scanned.  (If there are
procedures then the variables for a procedure are not addressed from that level,
instead the level for the external file has a chain of segments, each segment
with the variables of one level of procedure call.) The scan that records user
variables may find that the variable is a stem; in this case the stem has to be
scanned for the individual values within it.

~


 push Wptr Z.SerialNowúpushd Z.RelativeNow
 mov al,$SerialCompactionúcall Serialize
 Assert SortSpaceSS eq 1; Else need to load GS

; Stage 1, Step 1. Note FarpX things of the zone.
; Noting something serves two purposes - it ensured the data pointed to is
; retained and it ensures the pointer to the data is changed to reflect the
; new location of the data.  So we may record the same data twice becuase it
; is pointed to from two places.
 mov di,Zshape.Serialúmov Z.Left,diúmov Z.Right,di
 mv ds,ss
; There are segment pointers held as an array in the zone.
; Assert - no need to pick up the one used by Stems when expanding.
 mov cx,((Zshape.Zone-Zshape.SysFiles)/(size Z.SysFiles))+1
; The paragraph allocations are recorded by the seg&offset that addresses
; two bytes below the
; two bytes containing their segment address. (Subject segment has a header)
; (The adjustment by two makes para & non-para cases more similar.)
 mov al,1úmov bx,Zshape.SysFiles-offset FarpX.Sg
@@:call NoteSorteeúadd bx,size Z.SysFilesúloop @B

; Retain file buffers - similarly once only, not per Level
; Retain relevant segments of compiled programs, even if inactive.
 mov ds,Z.SysFiles
 mov dx,Hd.Avail
 mov bx,$StrideH+$StrideF; Steps through files.
ComNextFile:Qry F.Flags,IsSourceújnz Source@
 Qry F.Flags,Openújz @F
 Qry F.Flags,BeenReadújz @F
 z ax; These are not paragraph allocated.
; The non-paragraph allocations are recorded by the seg&offset that addresses
; six bytes containing FarpX info on the subject.
 call NoteSortee
@@:jmp @F

Source@:Qry F.Flags,BeenCompiledújz @F
 mov al,1úpush bxúlea bx,F.Symbols-offset FarpX.Sgúcall NoteSortee
 add bx,Fshape.Code-Fshape.Symbolsúcall NoteSortee
 add bx,Fshape.Consts-Fshape.Codeúcall NoteSortee
 add bx,Fshape.Vars-Fshape.Constsúcall NoteSortee
 add bx,Fshape.ProgScope-Fshape.Varsúcall NoteSortee
; We don't know if this one has a mention in the levels (ie is active) so we
; can't rely on that to retain the long string values of these constants.
; The design is suspect here (NYI) because ProgScope has reserved vars in it.
; We can record here but that is not sound.
if 1
 mov ds,Vbx.Sgúmov bx,$SizeConstsHeaderúmov cx,Hd.Availúcall Sortees
 mov ds,Z.SysFiles
endif
 pop bx
@@:add bx,Jbx.KeyLenúadd bx,$StrideJ+$StrideF
 cmp bx,dxújb ComNextFile

; Stage 1, Step 2. Note relevant things of stack, VarScope, ProgScope.
; Need to keep the values that are stacked. There is an array of these
; (intermediate results and invocation arguments), as a section of the stack,
; for each Level. So we need a loop up through the levels.
; Use DX as a non-zero when the level contains saved info about a program.
; That will be when deeper level IsExternal.
; Also this current one as a convenient way of recording var values.
 mov LevelSi,Z.Levelúcall ZoneToLevelúmov LevelDi,LevelSiúmov dx,1
 move L.LevelDO,Z.CurrentDOúmov cx,Z.Stack
; A level consists of the values (at high-address, top) then DO blocks then
; a Level block. The level block says where the DO blocks reach.
LevelLoop:
if CD
 Adump 7
; How many elements so far recorded?
 Adump 6úpush axúmov ax,Z.Rightúsub ax,Z.LeftúAdump axúpop ax
endif
 mov bx,L.LevelDO
 mv ds,ss
 call SorteesPlus
; Now to note where the Rexx variables and constants are. (The "constants"
; include program-scope variables like .MN so they need to be retained.)
 TestReg dxújz NoLevelInfoúdec dx
; Retain segment and the values in it.
 mov al,1úmv ds,ssúlea bx,L.ProgScope-offset FarpX.Sgúcall NoteSortee
if 0
 Assume this was done on file scan.
 mov ds,L.ProgScopeúmov bx,$SizeConstsHeaderúmov cx,Hd.Availúcall Sortees
endif
 mov al,1úmv ds,ssúlea bx,L.VarScope-offset FarpX.Sgúcall NoteSortee
 mov ds,L.VarScope
ProcsLoop:
if CD
 Adump 8
; How many elements so far recorded?
 Adump 6úpush axúmov ax,Z.Rightúsub ax,Z.LeftúAdump axúpop ax
endif
 mov bx,$StrideHúmov cx,Hd.Availúcall Sortees
; If there are procedures, a VarScope may be screening other scopes.
 cmp Hd.UpPool,ZeroBpúje @F
 mov al,1úmov bx,Hshape.UpPool-offset FarpX.Sgúcall NoteSortee
 mov ds,Hd.UpPoolújmp ProcsLoop
@@:
NoLevelInfo:Qry L.Access,IsExternalújz @Fúinc dxú@@:
; If there are temps for the level above they will end where this level starts.
 lea cx,[LevelDi-$StrideL]
 mov LevelDi,L.UpLevelúTestReg LevelDiújnz LevelLoop
if CD
 Adump 9
; How many elements so far recorded?
 Adump 6úpush axúmov ax,Z.Rightúsub ax,Z.LeftúAdump axúpop ax
endif

 sub Z.Right,$StrideG; Range of sortees is Z.Left:Z.Right inclusive.

; Can now use DS to address the sort space.The macros are written on that basis.
 if SortSpaceSS
    mv ds,ss
else
    mv ds,gs
endif

; Stage 2, Step1, partition sorting.
; The array to be sorted is to be ds:Z.Left thru ds:Z.Right.
; The method, Oct 78 CACM QuickSort, is to create partitions (everything
; above some point bigger than everything below) recursively until there
; are no big partitions and then use a simple sort on the concatenated
; small partitions. (Guaranteed of no long distance moves in that reordering).
; (I don't have a copy of the original paper, so my commenting may be dubious.)
; To make this code a bit general, macros are used for:
; SortLoad picks up the value on which to sort. (20 bit address)
; SortXchgEdx exchanges argument elements.
; SortPush pushes argument to stack.
; SortPop pops element from stack.
LeftDi is <di>; When at (or next to) left of subarray
RightSi is <si>; When at right of subarray
PartDi is <di>; When moved up for partitioning.
PartSi is <si>; When moved down for partitioning.
PartBx is <bx>; Where RightSi finished in partitioning
PartDx is <dx>; Where LeftDi finished in partitioning
LeftBx is <bx>; Where value used in partioning is developed.
LsizeAx is <ax>; Size of left part.
RsizeCx is <cx>; Size of right part.
StrideCx is <cx>; Bytes step from element to element+1
; $SortBk decides whether partition small enough for simple treatment.
$SortBk equ 10*$StrideG

; Whole array may be small enough for SortSimple.
 mov LeftDi,Z.Leftúmov RightSi,Z.Right
 mov LsizeAx,RightSiúsub LsizeAx,LeftDiúcmp LsizeAx,$SortBkújna SortSimple
 push ebp; Mark the stack.
;MASM....................................
NextSubarray:mov StrideCx,$StrideG
; Look at top, bottom and middle to get a reasonable value to partition on.
; Any setup with [Left+1]<=[Left]<=[Right] would allow [Left] to partition
; the range Left+1:Right. The following makes arrangements for evenness
; of performance in the face of particular orders in original data.
; Get address of middle (into bx).
 mov ax,RightSiúsub ax,LeftDi
 z dxúdiv cxúshr ax,1úmul cxúadd ax,LeftDiúmov bx,ax
; Swap left+1 with middle.
 push LeftDiúadd LeftDi,StrideCxúSortXchgEdx LeftDi,bxúpop LeftBx
; LeftBx now original left position, LeftDi now addresses left+1 which has
; value from middle. RightSi still there at rightmost.
 call OrderDleS; If left+1 valued more than rightmost swap their values.
; If left valued more than right swap them.
 xchg LeftBx,LeftDiúcall OrderDleSúxchg LeftBx,LeftDi
; If left+1 valued more than left swap them.
 xchg LeftBx,RightSiúcall OrderDleSúxchg LeftBx,RightSi
; LeftBx still original left position, LeftDi still addresses left+1.
; RightSi still rightmost. Values they address may have swapped.
; LeftBx now addresses a value good for partitioning this array.
; Reuse si/di to move up/down looking where exchanges needed to make partition.
 push RightSi
 SortLoad eax,LeftBx; Hold comparing value in eax
 push LeftBx
; Move right PartDi while it addresses something ranking lower than that value.
; Move left PartSi while it addresses something ranking higher.
Partioning:add PartDi,StrideCxúSortCmpEadx PartDiúja Partioning
@@:sub PartSi,StrideCxúSortCmpEadx PartSiújb @B
; Exchange the values and continue.
 cmp PartSi,PartDiújb @FúSortXchgEdx PartDi,PartSiújmp Partioning
; Finalise partition by putting the "splitter" value in rightful place.
@@:pop LeftBxúSortXchgEdx LeftBx,PartSi
; Recover original LeftDi and RightSi of this partition, noting results of
; partition in PartDx and PartBx.
 mov PartDx,PartDiúmov LeftDi,LeftBxúmov PartBx,PartSiúpop RightSi
; The element at PartBx will not have to change value again since if we sort
; what is above and what is below that will do the job.
; What are lengths of each side of this partition?
; One is LeftDi upto PartBx. Other is PartDx thru RightSi
 mov LsizeAx,PartBxúsub LsizeAx,LeftDi

if Debug
    jns @Fúint 3újmp Exitú@@:
endif
 sub PartBx,StrideCx
; The right side:
 add StrideCx,RightSiúsub RsizeCx,PartDx
if Debug
    jns @Fúint 3újmp Exitú@@:
endif
; If both are short, get any large one stacked to work on.
 cmp LsizeAx,$SortBkúja @F
 cmp RsizeCx,$SortBkúja @F
 pop LeftDiúpop RightSiúTestReg RightSiújnz NextSubarrayújmp SortSimple
@@:; Working on the larger now ensures stacking requirement no worse than
; logarithm of array size.
 cmp LsizeAx,RsizeCxújb @F
; Shorter (right) may be short enough to be done with; then just split the left.
 cmp RsizeCx,$SortBkújna SplitLeft
; Both long, stack the longer (left); continue with right.
 push PartBxúpush LeftDi
SplitRight:mov LeftDi,PartDxújmp NextSubarray
; By symmetry
@@:cmp LsizeAx,$SortBkújna SplitRight
 push RightSiúpush PartDx
SplitLeft:mov RightSi,PartBxújmp NextSubarray

; Stage 2, Step 2, final sorting.
SortPush macro arg:req
; Looks like MASM needs to be told 'pushd' even though Mem if Fptr.
 push Dptr(Gshape.Mem[arg])úpush Wptr(Gshape.Tag[arg])
 endm
SortPop macro arg:req
 pop axúpop Dptr(Gshape.Mem[arg])úmov Gshape.Tag[arg],al
 endm
; LeftDi and RightSi now used for pair of adjacent elements.
SortSimple:
 mov LeftDi,Z.Rightújmp NextPair
Loop22:
; A rewrite could make one of these SortLoads a move.
 SortLoad eax,LeftDi
 SortLoad edx,RightSi
 cmp eax,edxújna NextPair
; Started at right, found an adjacent pair out of order.
; Left of pair is relatively too big. (Value in eax)
; If we move it sufficiently right then the part right from where it was
; will be sorted.
 mov bx,RightSi
@@:add bx,$StrideGúcmp bx,Z.Rightúja @FúSortCmpEadx bxúja @B
@@:; The new place for value now at LeftDi is just below bx.
; So bytes from RightSi upto bx need shifting to start at LeftDi.
 mov cx,bxúsub cx,RightSi
; The SortPop and SortPush achieve a move of one element.
 push LeftDiúSortPush LeftDiúmv es,dsúRepmovsbúSortPop diúpop LeftDi
if Debug
 call Dlook
endif
; jae alone can't be right for this loop since always branch if Z.Left is zero.
; But a signed test would limit the range between LeftDi and Z.Left.
; Hence extra test for LeftDi wrap.
NextPair:mov RightSi,LeftDiúsub LeftDi,$StrideG
 jc @Fúcmp LeftDi,Z.Leftújae Loop22ú@@:

if Debug
 mov LeftDi,Z.Left
Debugso:SortLoad eax,LeftDi
 add LeftDi,$StrideG
 SortCmpEadx LeftDi
 jbe @Fúint 3újmp Exitú@@:
; Check more on equals - we shouldn't be recording twice that we want a
; specific place (containing ptr) updated.
 jne @F
 mov dx,G.Mem.Ptúcmp dx,G.Mem.Pt+$StrideGújne @F
 mov dx,G.Mem.Sgúcmp dx,G.Mem.Sg+$StrideGújne @F
 mov dl,G.Tagúcmp dl,G.Tag+$StrideGújne @F
 int 3újmp Exit
@@:cmp LeftDi,Z.Rightújne Debugso
endif

; Stage 3, update pointers.
; Assert the allocates in here cannot fail.
; We want DS for other things so the sorted list reverts to access by GS.
; (Unless SortSpaceSS)
 On Z.Cancel,MapOnly
 call AllocResetúmov di,Z.Left
Next3:lds bx,G.Mem
if CD
; Dump info on the first of the set.
  Adump 0úAdump diúAdump1 G.TagúAdump dsúAdump bx
; Sorting still good?
  pushadúpush dsúmv ds,ss
; SortLoad hits ES but probably OK.
  SortLoad ecx,diúcmp ecx,Z.DebugDújnb @Fúint 3újmp Exitú@@:
  mov Z.DebugD,ecx
  pop dsúpopad
endif
; Replace addresses with ones saying where the data will be.
; Replace the G. fields with ones saying where the data is.
; Setup ds:bx addressing ptr, cx byte length, di as data segment, dx as
; data offset original.
 z dxúcmp G.Tag,0úje NonParaType
 mov es,Vbx.Sgúmov cx,He.SegSizeújmp @F
NonParaType:mov cx,Vbx.Lenúxchg dx,Vbx.Pt
@@:
; We need to look ahead to see how many of the subjects are "tied together"
; because they overlap.
; This is the bit that won't work if we have G. elements that are duplicates,
; since the lookahead would see an already-altered item.
; Things allocated as segments never partially overlap, but there may be
; multiple ptrs to some segment.
if CD
 Adump Vbx.SgúAdump dxúAdump cx
endif
 mov si,diúpush diúmov di,Vbx.Sg
 cmp di,100húja @Fúint 3ú@@:
; si moves to find variables covered by the one allocation.
JoinSi:add si,$StrideGúcmp si,Z.Rightúja NotSi
; The addresses were never "normalized" by shifting part of the offset to
; the segment value; they retain the segment value they had when allocated.
; So different segment value implies different data.
 lds bx,Gsi.Mem
; Vbx. is now the one that may join in.
 cmp di,Vbx.Sgújne NotSi
 cmp Gsi.Tag,0újne SameSeg
; Does lower one's offset plus length reach the higher one?
 mov ax,Vbx.Pt
if CD
 mov Wptr Z.AxAsNum+2,ax; For subsequent dump.
endif
 sub ax,dxúcmp ax,cxúja NotSi
 mov Vbx.Pt,ax
; What length covers them both?
 add ax,Vbx.Lenúcmp ax,cx
if CD eq 0
 jb JoinSi
else
 jb @F
endif
 mov cx,ax
SameSeg:
if CD
@@:Adump 1úAdump1 Gsi.TagúAdump siúAdump Gsi.Mem.SgúAdump Gsi.Mem.Pt
 Adump Vbx.SgúAdump (Wptr Z.AxAsNum+2)úAdump Vbx.LenúAdump cxúAdump Vbx.Pt
endif
 jmp JoinSi

NotSi:pop di; di up to si covered by length cx
; The Vbx.Pt of all the set have been adjusted so that zero in the first.
 lds bx,G.Mem
; DX is the data offset of that covered, so old address for data is Vbx.Sg:dx
; Put old address of data in 3 bytes.
; Segment G.Mem.Sg, offset dl (Will go to .Tag). Length in G.Mem.Pt
 mov G.Mem.Pt,cxúmov ax,Vbx.Sg
 push dxúshr dx,4úadd dx,axúmov G.Mem.Sg,dxúpop dxúand dl,15
if CD
; Planned move.
 Adump 2úAdump G.Mem.SgúAdump1 dlúAdump cx
endif
; Find what data's new address will be.
 cmp G.Tag,0újne Palloc
 call AllocateCx_EsAxújmp @F
; 0FFh means a new piece to move is a segment.
Palloc:call ParaAllocAxúmov es,axúz axúmov dl,0FFh
if CD
@@:Adump esúAdump ax
endif
; Pointer to show new address of data, for all in this joining.
@@:mov Vbx.Sg,esúadd Vbx.Pt,ax
if CD
 Adump 4úAdump esúAdump Vbx.Pt
endif
 mov G.Tag,dlúadd di,$StrideG
; 0FEh marks things which are part of what was allocated before.
 lds bx,G.Memúmov dl,0FEh
 cmp di,siújb @B
 cmp di,Z.Rightújna Next3

; Stage 4, move data.
; We do allocates again, same order & same lengths, so will get the same
; allocations.  Thus we find where the data will move to, and move it.
 call AllocReset
; The list tells us where it is.
 mov di,Z.Left
MovesLoop:lds cx,G.Memúmov al,G.Tag
; This gives length and segment. The segment has been normalized.
; Tags which are addition to make a string address will be 0-15 range.
 cmp al,0FEhújae AllocSeg
 movsx dx,al
 call AllocateCx_EsAx
MovePact:
; cx is length. dx and ax are the offsets. ds and es the segments.
; di in use, bx and si not.
; To do a correct job of seeing if a move is necessary we should compare
; 20-bit addresses, although move of something to itself is harmless.
 mv bx,dsúmovzx ebx,bxúshl ebx,4úmovzx edx,dxúadd ebx,edx
 mv si,esúmovzx esi,siúshl esi,4úmovzx eax,axúadd esi,eax
if CD
 pushad
 Adump 3úAdump dsúAdump dxúAdump cxúAdump esúAdump ax
 cmp esi,ebxúje @FúAdump 0ú@@:
 cmp esi,ebxújne @FúAdump 1ú@@:
 popad
endif
 cmp esi,ebxúje Non4
if Debug
    pushad
    mv bx,dsúmv si,es
   ; If it overlaps, better be downwards move.
   ; We are going to put the first byte down at 16*es+ax
   ; Range of source is 16*ds+dx to that plus cx-1
   ; si=es bx=ds currently
    movzx esi,siúshl esi,4úmovzx eax,axúadd esi,eax
    movzx ebx,bxúshl ebx,4úmovzx edx,dxúadd ebx,edx
    cmp esi,ebxújb @F
    movzx ecx,cxúadd ebx,ecx
    cmp esi,ebxújae @F
    int 3újmp Exit
   @@:popad
endif
; The segment pointers have their new values before the move is made.
if Debug
 mov bx,dsúcmp bx,Y.Csegúje Exit
endif
 mov bx,Z.Zone
; push & pop not safe here, use ax as temp.
 mov si,dxúxchg di,axúRepmovsbúmov di,ax
 mov ax,esúcmp ax,bxújne Non4
; Zone just moved.
 mov ss,ax
Non4:
 add di,$StrideGúcmp di,Z.Rightújbe MovesLoop
 mov ds,Z.DsNew
 mov es,Z.EsNew
 mov fs,Z.FsNew
 mov gs,Z.GsNew
 Off Z.Cancel,MapOnly
 pop Z.RelativeNowúpop axúcall Serialize; Restore, eg, Rexx queue.
 popaúret

AllocSeg:je Non4; No allocation since substring of another variable.
; Here to allocate the new position segment.
 call ParaAllocAx
 mov bx,ds; Where segment was.
; Recognise if it is one associated with a segment register.
 mov si,Zshape.DsWas
ASloop:cmp bx,Z.w[si]újne @Fúmov Z.w[si+2],ax; Z.DsNewú@@:add si,4
 cmp si,Zshape.GsWasújna ASloop
; All the Z. fields will be vulnerable when we are moving the zone.
; If we update SS now then any Pushes will be against memory before the copy
; of Zone is done. Better to detect later.
 Assert SortSpaceSS eq 1; Else do something when GS segment moves.
 mov es,axúz axúz dxújmp MovePact

if CD
Adumper:pushaúpush ds
; Write AX as two bytes binary through DOS.
 mov Wptr Z.AxAsNum,axúmov dx,Zshape.AxAsNumúmov cx,2úmv ds,ss
 mov bx,Z.Dumperúmov ah,$DosWriteúint 21húpop dsúpopaúret
endif

 end
