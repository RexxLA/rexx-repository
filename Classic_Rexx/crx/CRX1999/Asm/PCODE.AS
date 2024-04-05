; Copyright Formcroft Ltd 1997-1999
 .model smallú.486ú.code
 include always.inc; Assembler shorthands like 'Bptr' for 'byte ptr'.
 include declares.inc; Symbolic constants, macros, records, structures.
; Syntax actions, made public to fulfill slots in syntax tables.
 PUBLIC Action0;   the action for an operand. (Not numbered in the BNF)
 PUBLIC Action1;   assignment at =
 PUBLIC Action2;   end of keyword instruction
 PUBLIC Action3;   end of command
 PUBLIC Action6;    PARSE VALUE
 PUBLIC Action10;   a binary op
 PUBLIC Action11;   a prefix
 PUBLIC Action12;   comparisons
 PUBLIC Action18;   a function name or after CALL
 PUBLIC Action50;   after the subject of PARSE
 PUBLIC Action51;   ARG verb
 PUBLIC Action52;   PULL verb
 PUBLIC Action53;   Trigger
 PUBLIC Action55;   +-=
 PUBLIC Action56;   UPPER
 PUBLIC Action57;   after template
 PUBLIC Action58;   comma in template
 PUBLIC Action20;   at THEN
 PUBLIC Action21;   at ELSE
 PUBLIC Action22;   end of if
 PUBLIC Action23;   end of select
 PUBLIC Action24;   end of otherwise
 PUBLIC Action25;   end of when
 PUBLIC Action26;   PROCEDURE
 PUBLIC Action28;   ITERATE/LEAVE, no VAR
 PUBLIC Action29;   ITERATE/LEAVE with VAR
 PUBLIC Action30;   do-end without var after.
 PUBLIC Action31;   var after do-end
 PUBLIC Action32;   end of do.
 PUBLIC Action33;   dorep done
 PUBLIC Action34;   While
 PUBLIC Action35;   Until
 PUBLIC Action36;   FOREVER
 PUBLIC Action37;   WHILE/UNTIL
 PUBLIC Action381;   TO
 PUBLIC Action382;   BY
 PUBLIC Action383;   FOR
 PUBLIC Action41;   missing expressions in a list
 PUBLIC Action43;   a function completes
 PUBLIC Action44;   CALL Ftn without expression list
 PUBLIC Action45;   CALL Ftn with expression list
 PUBLIC Action60;   callon spec.
 PUBLIC Action61;   after condition
 PUBLIC Action62;   OFF
 PUBLIC Action70;   ADDRESS instruction
 PUBLIC Action71;   INPUT resources
 PUBLIC Action72;   OUTPUT resources
 PUBLIC Action73;   ERROR resources
 PUBLIC Action74;   APPEND
 PUBLIC Action75;   Environment name
 PUBLIC Action80;   after numeric.
 PUBLIC Action90;   Expression ends
 PUBLIC Action91;   Clause end
 EXTERN $CondKeys:near, $WithKey:near; To alter lexical keyword lookups.
 EXTERN Bifs:near; The table of spellings.
 EXTERN PcodeBif:near
 EXTERN StrictFlags:near; Used in ConstValue

OpFactAh is <ah>   ; Byte of facts about the operator.
OpFactAl is <al>   ; Ditto
;------------------------------------------------------------------------------
; Lookups need access to the Symbols segment so the discipline is to keep
; SymbolsEs in play, as with the rest of compile activity. The segment Pcode
; is made in is addressed by GS. (As it is also in execution, except during
; Compaction). DS and FS do not have specific uses.
; BX is not needed for the attributes table during Pcode generation so can be
; used for the Pcode cursor, CursorBx. (Picked up from Z.Cursor, current
; position in generated Pcode). There are other uses.
; The principal use of DI is as StackDi, with copy to Z.Stack.
; (Other uses, particularly during Lookup.)
; On entry to Actions, SI addresses the parser stack (use S. and ParseSi) but
; it can be reused.
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Before being put in Pcode, operands are given a compact numbering by Lookup.
;------------------------------------------------------------------------------
comment~ On first sight, a symbol or string is written to where Z.Symbols points
and (Z.Clause,Tailed) notes whether it is qualified.  The question of when to do
Lookup is complicated.  Label definitions don't need to be seen by the parser so
they are looked up on first sight.  Doing a variable symbol early would be wrong
if it was actually a keyword.  Doing a variable symbol late (eg in an Action)
could be wrong when implied concatenate - both symbols would get read before any
lookup.  So best time for a variable symbol is when the parser shifts it.  But
in a case like A.B=F() it is required that the RHS be evaluated before B is
referenced so, for code making reasons, Lookup is held over until the RHS has
been done.  Holdover is on soft stack, is raw symbol when tailed, else result of
lookup.  Constants and label uses could be done at any stage - are currently
being done at RealShift in parser (simplest for line number in messages)
TokNum is $VAR_SYMBOL when a name is initially uppercased and stored.
The result, the latest thing looked up, is set in Z.Resolved.

The Lower and Higher fields are altered during lookup so it would be inefficient
to use any spare bits they have for information about the subject.  There are no
spare bits on Here since space for the names and literals may be a limiting
factor on program size.  We need to pack all the subject data into the one
remaining word.  We want to hold offsets of code for the labels, and info on
which bif.  At 0.1% loss of code size max, we can take 66 of the 2**16 values
for the bifs.  Slightly inefficient , but what else?  (Leaving bif lookup until
end-of-source would prevent making bif-dependent code on the one pass.)
(Actually now types-with-constants is implemented it could be done that way.)

~
 Assert Vshape.Pair eq 0;
 Assert Vshape.Lower eq 0;
; During the following loop, ArrayBx locates a tree that may contain the
; searched for value, eventually going to zero if the value is not found
; anywhere.
Find:; Takes ds and Z.Middles,LookLabel, LookBin.
; Z.Symbols addresses string to look up.
; Searches (and maybe adds item) according to info in DS header.
; The header of segment ds has zone offset of place that addresses the segment.
; On exit ds:bx is the matching item, es:dx::ax addresses the string, and
; Carry on if the item is new. The relevant probe will have been changed
; and Z.Middles.LookLabel will be off.
; SegOffDi will be zone offset (how much of this matters?).
 mov ArrayBx,Hd.Probe
 Qry Z.Middles,LookLabel,LookBinújz FindNewúmov ArrayBx,Hd.Labelsú@@:
 Qry Z.Middles,LookBinújz @Fúmov ArrayBx,Hd.TreeBinú@@:
FindNew:; Enter here with ArrayBx set, eg zero to ensure isolated item.
 mov ToFindDx,He.Avail
 mov si,ToFindDxúmovzx ToFindLenAx,SymbolsEs:Bptr[si]úinc ToFindLenAx
; LowSi and HighDi are the offsets of slots (with the slots themselves
; containing offsets). Those slots are filled in by the subsequent iteration.
; Use the next available element for this newly developed place so that it
; will be in the right place if the subject is previously unknown.
 mov LowSi,Hd.Availúlea HighDi,[LowSi+Vshape.Higher]
; In parallel with searching, the tree is being re-arranged to make the
; found (or new) item the root.  This has good performance characteristics
; when references to the same thing are clustered.
WhileArrayBx:TestReg ArrayBxújz LookNoFind
; Do the string (with length) compare.
LookLoop:push siúpush di
 mov si,ToFindDxúmov di,Vbx.Hereúmov cx,ToFindLenAx
 repe cmps SymbolsEs:Bptr[si],Bptr[di]úpop diúpop siújae SymbolsBelow
; We want the next probe to be at a higher place, so must set ArrayBx from
; Higher. At the same time the tree-rewriting info must be maintained.
; LowSi is set to locate a slot in an item where we followed the 'higher'
; locator.  We are stepping on even higher, so we can refill that slot
; (with an offset to where we are now probed) knowing that there is no
; risk that slot contained an offset to the thing we are looking for.
 mov [LowSi],ArrayBx; Complete prior iteration
 lea LowSi,Vbx.Higher; Note slot to pick up now
 mov ArrayBx,[LowSi]; Pick upújmp WhileArrayBx
; Found equality.
; Complete each of the two subtrees we have been making, one
; containing items lower than the probe and one containing higher values.
SymbolEq:mov ax,Vbx.Lowerúmov [LowSi],axúmov ax,Vbx.Higherúmov [HighDi],ax
; Make everything one tree rooted at ArrayBx.
 mov si,Hd.Avail
 mov esi,Vshape.Pair[si]úmov Vbx.Pair,esi
 mov SegOffDi,Hd.Link
 Qry Z.Middles,LookLabel,LookBinújnz FoundLabBin
 mov Hd.Probe,ArrayBx
@@:mov Z.Resolved,ArrayBxúclcúret; Subject found at ArrayBx.
FoundLabBin:btr Z.Middles,LookLabelújc FoundLabel
 Off Z.Middles,LookBinúmov Hd.TreeBin,ArrayBxújmp @B
FoundLabel:mov Hd.Labels,ArrayBxújmp @B

SymbolsBelow:je SymbolEq
; This section by symmetry.
 mov [HighDi],ArrayBxúlea HighDi,Vbx.Lowerúmov ArrayBx,[HighDi]
 TestReg ArrayBxújnz LookLoop
; It was not found. Complete the two isolated trees.  bx is zero.
LookNoFind:z Wptr[LowSi]úz Wptr[HighDi]
; Commit the new item we have been making.
 mov SegOffDi,Hd.Link; Address a pointer in the Zone for the current segment
; Commit the symbol just looked up. This is the first use.
 call TakeSlotDi
 mov SymbolsEs,Z.Symbolsúadd He.Avail,ToFindLenAx; For next symbol
 mov Vbx.Here,ToFindDx
 Qry Z.Middles,LookLabel,LookBinújnz NewLabBin
 mov Hd.Probe,ArrayBx
@@:mov Z.Resolved,ArrayBxústcúret; Subject new at ArrayBx. SegOffDi active.
NewLabBin:btr Z.Middles,LookLabelújc NewLabel
 Off Z.Middles,LookBinúmov Hd.TreeBin,ArrayBxújmp @B
NewLabel:mov Hd.Labels,ArrayBxújmp @B
;------------------------------------------------------------------------------
; The general Find mechanism is used to lookup variables, constants, ....
;------------------------------------------------------------------------------
Lookup:push axúpush dxúpush siúpush di
; TokNumAh is argument, to determine what sort of lookup.
; If Z.Clause,Tailed off, Lookup what is at Symbols Avail, using the relevant
; tree. OpAppendCl is set.
; If Z.Clause,Tailed on,(and not a label) Lookup parts of what is at V. (SS:DI)
; Commits space in Symbols segment and Vars/Consts segment, for new item(s).
; Z.Resolved is a place to put the result. Also in ArrayBx.

; Select the segment we are searching and the tree within it.
; There are two possibilities for the segment - one for variables and the
; other for labels and constants. The latter contains three independent trees,
; making four possibilities for what is to be searched.
 btr Z.Middles,TakenConstantújc AsConstúcmp TokNumAh,$VAR_SYMBOLújne AsConst
; Look up a variable symbol.
 btr Z.Clause,Tailedújc LookTailedúmov ds,Z.Varsúcall Findújnc LookupRet
; The new current pool variable should initially say dropped.
 mov fs,Z.VarScopeúmov Vbxf.Dtype,$Dropped
 z Z.PoolPool; Shorter pools no longer useful.
; If it is a stem variable it takes two slots in the variable array.
; The first is for the default value, the second is special data for a stem.
; The second is not in any tree, uses the same characters as its symbol.
 mov si,He.Availúcmp Bptr SymbolsEs:[si-1],'.'újne LookupRet
 push Vbx.Hereúcall TakeSlotDi
 mov Vbxf.Dtype,$Droppedúpop Vbx.Here; So that second slot can be dumped.
 sub ArrayBx,$StrideV
LookupRet:
 pop di
if Debug
 call Consist
endif
 pop siúpop dxúpop axúret

AsConst:Off Z.Clause,Tailedúmov ds,Z.ConstsúQry Z.Middles,LookLabelújnz AsLabel
; We will have to pop TokNumAh to ch because Find sets ToFindLenAx
 push axúcall Findúpop cxújnc LookupRet
; Dot as first of symbol makes it reserved, potential message.
; Unless it came as number or quoted.
 cmp ch,$CONST_SYMBOLújne @F
 mov si,ToFindDxúcmp Bptr SymbolsEs:[si+1],'.'újne @F
 cmp ArrayBx,$?SIGLúja Raise50p1
@@:
; We are here when the constant is looked up for the first time.  We have the
; symbol in literal form (Consts segment) but we also want it in ProgScope
; at run time. (With any needed conversion)
; Add a type byte after the new symbol.
 mov si,He.Availúinc He.Availúmov Bptr SymbolsEs:[si],$tChar
 mov ds,Z.ProgScope
;MASM .................................
; ToFindDx:ToFindLenAx includes a length byte.
 mov si,ToFindDxúinc siúdec ToFindLenAxúcmp ToFindLenAx,7úja @F
; Simplest to always move 8 chars.
 Move Vbx,SymbolsEs:Vsid,edx
; Code for short string is $NullString plus length.
 mov Vbx.Dtype,$NullStringúadd Vbx.Dtype,alújmp AsString
; Setup lengthy string.
@@:mov Vbx.Dtype,$AwayString
 mov Vbx.Len,axúmov Vbx.Sg,SymbolsEsúmov Vbx.Pt,si
AsString:jmp LookupRet

; Lookup of a label is in a tree devoted to labels.
AsLabel:push axúcall Findúpop axújnc LabelKnown
; Mark it amongst symbols as a label.
 mov si,He.Availúmov Bptr SymbolsEs:[si],$tLabel
 mov Wptr SymbolsEs:[si+1],ZeroBpúadd He.Avail,3
 push ds
 mov ds,Z.ProgScopeúmov Vbx.LabelValue,ZeroBp
 mov Vbx.LabelType,StringOrder(0,$Label)
 pop ds; (Z.Consts)
 TestReg TokNumAhújz WithColon
; First use of name, not with colon. See whether it is a Bif.
 mov di,ToFindDx
; Bifs have length between 3 and 10
 movzx ax,SymbolsEs:Bptr[di]
 cmp al,10úja NotBifúcmp al,3újb NotBifúinc di
; Bif tables with the code.
; Setup to search ones of relevant length.
 mov si,axúmov cx,axúadd si,siúmov dx,cs:(Bifs-4)[si]úmov si,cs:(Bifs-6)[si]
BifLoop:push siúpush diúpush cxúrepe cmpsb cs:[si],[di]
 pop cxúpop diúje BifFound
 pop siúadd si,cxúinc siúcmp si,dxújne BifLoop
NotBif:jmp LookupRet

BifFound:movzx ax,Bptr cs:[si]; Bif compact number.
 pop siúadd ax,$BifBase-$BifTagújmp SetLabel

LabelKnown:TestReg TokNumAhújnz LookupRet; Had it before, no colon here.
; Here for label that has colon.
 push dsúmov ds,Z.ProgScopeúmov cx,Vbx.LabelValueúpop ds
 JcxzQ WithColon; No colon or bif spelling before.
; Here are the awkward cases - there is a colon but we think we already
; know about the label.
 cmp cx,$BifBaseújae DupBif
; To avoid the appearence of duplication as each label is scanned
; for a second time during Repass, the non-bif labels are given value
; one before that repass. (Can't be a genuine value because of
; the code segment header).
 dec cxújz WithColon
; Not a dup when rescan for Synch.
 cmp Z.Synch,ZeroBpújne LookupRet
; Here with something like ABC:NOP;ABC:
; This is allowed, the second one being for trace purposes.
; We leave the first one as it is, and make another that is not in any tree.
 z ArrayBxúmov ds,Z.Consts
 push Hd.Probeúcall FindNewúpop Hd.Probe
 mov si,He.Availúmov Bptr SymbolsEs:[si],$tLabel
 add He.Avail,3újmp WithColon

DupBif:; Like CALL SUBSTR;...;SUBSTR:
 On Z.Program,Repass; Will need to start over knowing it is not a bif.
WithColon:; If it comes with a colon it isn't a bif.
 mov ax,Z.Cursor
SetLabel:; Put address in the Symbols, after the byte that tags a label.
 mov si,Vbx.Hereúmovzx cx,Bptr SymbolsEs:[si]
 add si,cxúmov Wptr SymbolsEs:[si+2],ax
; Also set it under Z.ProgScope.  The copy under Z.Symbols is only used to
; reconstruct Z.ProgScope segment after program made dormant. NYI
 mov ds,Z.ProgScopeúmov Vbx.LabelValue,ax
; This already done??
 mov Vbx.LabelType,StringOrder(0,$Label)
; Maybe trace-only by reason of DO or SELECT
 cmp Hg.Original,ZeroBpújne LookupRet
 cmp Z.TraceOnly,ZeroBpúje LookupRet
 mov Bptr Vbx.LabelType,1
 jmp LookupRet

; We have not done Between yet, so set Insert.TokLen.
Raise50p1:mov al,SymbolsEs:[si]úmov Bptr Z.Insert.TokLen,al
 mov ax,MkMajMin(50,1)újmp Raise

TakeSlotDi:; SegOffDi identifies segment (in Zone).
; Take slot in segment, set bx to it.
; ds will match SegOffDi. May lead to ds update.
 mov ArrayBx,$StrideVúxadd Hd.Avail,ArrayBx
; It will actually be .Vars or .Consts that is gaining a slot.
; .VarScope or .ProgScope to be matching size.
 mov es,Z.VarScopeúcmp SegOffDi,Zshape.Varsúje @Fúmov es,Z.ProgScopeú@@:
 add He.Avail,$StrideVúmov Vbxe.Dtype,$Dropped
 cmp ArrayBx,Hd.Triggerújb @Fúcall MoreSpaceEs
; The "shadows" are not tested for size; they expand when what they shadow does.
 push diúadd SegOffDi,Zshape.VarScope-Zshape.Varsúcall MoreSpaceEsúpop di
 mov ds,Z.w[SegOffDi]; DS from Zone is new.
@@:mov SymbolsEs,Z.Symbolsúret

comment~ The code for Tailed is 'on' calls Lookup recursively and eventually
exits via label LookupRet.  Here we pick symbol into parts and look them up
individually.  The Pcode made has the tail pieces followed by $pDots and a
counter of tail pieces.

~
; es is at Symbols but to cope with compaction must be picked up often.
; DS:SI has to be picked up again after each possible compaction.
; StackDi is not necessarily Z.Stack because of PARSE targets.
;; There must be an easier way!
LookTailed:On Z.Clause,WasTailed
  mov Z.Tail,StackDi
  call ToDsSiCx
; We don't want SymbolsSafe (& possible compaction) within the loop.
 push StackDiúmov di,He.Availúadd di,cxúcall SymbolsSafeúpop StackDi
 z OpAppendCxúmovzx SymsZiDx,Bptr[LookupSi]
 inc LookupSiúadd SymsZiDx,LookupSi; Runs from DS:SI up to DS:DX
 mov Z.SoFar,1
; Copy each component in turn to where it can be looked up, ie at Z.Symbols.
NextSym:mov StackDi,Z.Tail
 push OpAppendCxúcall ToDsSiCxúadd LookupSi,Z.SoFarúpop OpAppendCx
 mov LengthAtBx,He.Availúmov di,LengthAtBxúz axústosb
@@:lodsbúinc Z.SoFarústosbúinc Bptr SymbolsEs:[LengthAtBx]
 cmp al,'.'úje @Fúcmp LookupSi,SymsZiDxújbe @B; Pretend dot at limit.
@@:; One name copied, including tailing dot.
 mov TokNumAh,$VAR_SYMBOL
 JcxzQ SymFirst; For first only, '.' is part of the name.
; After first, can be constant or null.  Lookup needs to be told Const/Var.
 dec Bptr SymbolsEs:[LengthAtBx]újz Absent
 mov al,Bptr SymbolsEs:[LengthAtBx]+1úcmp al,'9'úja NotNumbúcmp al,'0'újb NotNumb
Absent:mov TokNumAh,$CONST_SYMBOL; No matter if actually NUMBER
NotNumb:push cxúcall Lookupúpop cxúmov ax,ArrayBx
 call Pcode2; Reference to part put on Pcode.
; Count of parts is in units of $StrideV.  BumpSym loops through the parts.
BumpSym:add OpAppendCl,$StrideVúcmp si,SymsZiDxújb NextSym
; We are through the parts. Put (potential) opcode (and count) onto Pcode
; (We chose not to stack the tail components during compile.)
 sub OpAppendCx,2*$StrideV; Discount the stem itself. Less one for $pDots arg.
; Set up what caller of Lookup will see as the operand.
; Pcode addresses first of pair of elements.
 mov ArrayBx,Z.StemSymúmov Z.Resolved,ArrayBxújmp LookupRet

SymFirst:push cxúcall Lookupúpop cxúmov ax,ArrayBxúmov Z.StemSym,axújmp BumpSym

;------------------------------------------------------------------------------
; Converting constants to desired value representation at compile time.
;------------------------------------------------------------------------------

comment~ Since the Dtype field says how a constant is represented we can always
hold a constant longterm as a string, and rely on there being a check (and
conversion) at places in the implementation where the argument has to be a
number. We can do better than that if the constant is written so that binary
and string versions convert to one another. (eg "99" not "099") Then we can
predict the likely use of the constant, store it in that form, and hence reduce
the converting at run time.

Best of all, though, is to allow for holding the number twice, once as string
and once as binary. Then we can select at compile time to reduce conversions.
That leads to notions of constants having an "attached" datatype and a different
lookup scope for different types. (A notion Rexx already has with labels being
in a different scope from variables.)

The simplest implementation would be to add the datatype byte to what Find looks
for, but that would preclude putting anything in the byte not related to lookup.
(Such as what radix a constant was originally in.) It also makes the end-to-end
scan of the symbols segment, where variables and constants are interleaved, more
problematic.

It is sounder to put the datatype byte after what is looked up, because there
are a few values available that cannot be confused with the length byte of
the next item. Also the lookups will be a touch faster when the trees are
separate.

There is a complication because constants are converted and looked up at
first sight since that gives the desired line number in any "its over-sized"
message.  At that time we don't know (or at least don't have a design that
knows) what datatype we want. So we always make a char version, and add a
binary later if needed.

Note that when the constant is used there will still need to be a test on
the argument (since it is just a value that might have come from a variable)
but the test will quickly find that no conversion is needed.  Even the test
is avoided for implementations of builtins since Bif$$ or Bifq$$ will have
ensured the arguments are put in appropriate format. (The bifs working always
at digits()=9 helps).

~
NotNumS:pop bxúDownúmov Z.Stack,StackDiújmp NotNewConst

ConstValue:; Replace constant reference on stack by its value.
; ah says if we want the type enforced. (See DataType letters)
 cmp V.Dtype,$Constantújne ConstRet
ConstValueX:; This entry when that test inline.
 push siúpush axúpush bxúpush cxúpush edx
; Remember where Pcode will have to be patched if this operand changes.
 mov bx,V.PcodePosúmov Z.PcodePos,bx
; Consider the constant's value.
 mov bx,V.WhichConúmov fs,Z.ProgScopeúMove V,Vbxf,edx
; It is bound to be string type at this stage.
 cmp ah,0újne NotGuess
; ah = 0 means numeric only if reversible (and written w/o quotes. NYI)
 call UpStack
 Move V,V0,edx
 push bx
 call NumDxBx; If it a number, V will be converted.
 jnz NotNumS
 call StrictFlags; Are the numeric and char exactly the same? (Drops stack two)
 pop bx
 mov SymbolsEs,Z.Symbols
 UpCareúmov Z.Stack,StackDi
 jne NotNewConst
 mov ah,'N'
NotGuess:cmp ah,'N'újne NotNum
AsVar:; Will this string convert to number? Get flag to say.
 push bxúcall NumDxBxúpop bx
; Note that Carry will be on if reason for non-binary is non-number syntax, and
; this will feed back to caller.
 jnz AsVarX
; Is a fit to binary number. We need it added (if not there) to the
; symbols segment (with following $tBinary type byte) . A design choice whether
; to have it there as 8 bytes binary, as that converted to char, or as the
; original string.
 push StackDiúmov ds,Z.Constsúmov si,Vbx.Here; Original symbol as string.
 movzx cx,Bptr SymbolsEs:[si]; Its length.
; Assure space with symbols for another copy.
 mov di,He.Availúadd di,cxúcall SymbolsSafeúsub di,cx
; Copy (with length) to tentative position of use.
 inc cxúrep movsb [di],es:[si]
; Look in relevant tree for it.
 push bxúmov ds,Z.ConstsúOn Z.Middles,LookBinúcall Findúpop siúpop StackDi
 mov fs,Z.ProgScope
 jnc PcodeUsesúxchg si,bx
; Now bx is the char-style constant, si is the new constant.
; Set value for the new item in ProgScope.
 Move V,Vbxfúcall NumDxBx
 mov fs:Vsid.OverMant,ebxúmov fs:Vsid.OverExpo,edx
; Add a type byte after the new symbol.
 mov si,He.Availúinc He.Availúmov Bptr SymbolsEs:[si],$tBinary
 jmp PcodeUses

AsVarX:mov V.Dtype,$Variableújmp NotNewConst

NotNum:cmp ah,' 'úje AsVarúcmp ah,'W'úje AsVar; Variations of number.
 cmp ah,'O'újne NotNewConst
; Is it already single uppercase letter?
 cmp V.Dtype,$NullString+1újne @F
 mov cl,V.Stringúcmp cl,'A'újb @Fúcmp cl,'Z'újna NotNewConst
; Lookup desired constant.
@@:call UpperFirstAhúmov ch,V.Stringúmov cl,1
 mov si,He.Availúmov Wptr SymbolsEs:[si],cx
 On Z.Middles,TakenConstantúcall Lookup
; Reference to the old constant, in the Pcode already made, has to change.
PcodeUses:mov ax,Z.Resolvedúmov si,Z.PcodePos
 cmp Z.Synch,ZeroBpújne @Fúmov gs:[si],axú@@:
NotNewConst:mv ds,csúpop edxúpop cxúpop bxúpop axúpop si
ConstRet:ret

UpperFirstAh:;Uppercase first char of the parameter, and retain only that.
; Also left in ah.
 push cxúpush siúcall ToDsSiCx
 mov ah,Bptr[si]úcmp ah,'a'újb @Fúcmp ah,'z'úja @Fúand ah,0DFhú@@:
 mov V.String,ahúmov V.Dtype,$NullString+1
 pop siúpop cxúret

;------------------------------------------------------------------------------
; Pcode generation.
;------------------------------------------------------------------------------

comment~ On the representation of Pcode:

Here are the general routines for creating Pcode - they are called from the
places where particular language features are implemented.  Because the Intel
architecture is "Little-Endian", we can mix up one-byte and two-byte fields yet
distinquish them by their low bits.  So taking the value modulo 8:  Odd values
(1,3,5,7) mean this is an operator (and in one byte).  Zero means this is an
operand in the current variable pool.  Four means it is an operand from the pool
of constants (and system variables). Two is used for "subcodes" - things looked
at only in context and must be different from operators and operands. Six is
used to mark operands as targets.

If we ever go to a second pass of compilation that will, like a dumper, benefit
from an easy scan of Pcode. The modulo 8 mechanism distinguishes Pcodes,
subcodes, and operands. There is still a need to know what follows a Pcode.
Conceivably the actual values of the Pcodes might be put in ranges that
allow this to be deduced but since there will be at least a byte per opcode of
facts about the opcode available, it is flexible to use a couple of bits.
One bit will say if a number (in a byte) follows the opcode, for example a
bif number following a $pBif. The other bit will say whether there is a
reference following, for example the target of an assignment. (If both, the
number comes first.)

This leaves some special ones to be recognised individually:

$pAssignConst has two references. (So that the constant doesn't go via the
stack).

$pBool affects the meaning of the next operator.

Some operators have a jump address attached after them.  This seems a good
use for the actual value of opcodes because if we had long/short branches
we would want to test them in execution without going to fetch any facts
associated with the opcode.  $PjumpBase $PjumpCeil

(In theory we could use order to avoid the "has reference append" flag but that
conflicts with separating opcodes on whether they are shared with Bcode.)
~

PcodeOp:push si; Put operator in Pcode and make use of its attributes.
; Pick up flags about this Pcode, which comes in al.
; AX used. CX is input when OpAppendCx, not preserved. DX preserved.
; BX used and set to position of last thing placed.
; SI preserved.
; Make the Pcode, then look at effects on the operands.
 mov ah,alúshr al,1úmov bx,OpFlagsúxlat cs:Bptr[bx]úxchg ah,al
; Test for special case of implied operand.
 test OpFactAh,mask DownOneújz NotImplied
; This flag means "pop compile time stack".
; When PcodeOp called twice, once to advance original, once for trace, the
; compile time stack adjustment should happen once.
 Qry Z.Gen,DualOnlyújnz NotImplied
 mov StackDi,Z.Stackúcmp StackDi,Z.Base0újne NotImplied
; If nothing to pop, an operand is implied, eg SAY;
 push axúmov ax,$?Omittedúcall Pcode2úpop ax
 call UpStackújmp NotAssig

NotImplied:; Exit can come with and without operand. If any, it is used up.
 cmp al,$pExitújne @Fúpush Z.Base0úpop Z.Stackú@@:
; Nov 99. Avoid assignment operator by flagging target.
 cmp al,$pAssignújne NotAssig
; Have to make the assign if it is for DO.
 Qry Z.Cancel,AssignDOújnz NotAssig
 add Z.Resolved,$CaseTargetújmp Targeted
NotAssig:; Dual mode code has a prefix to each operator.
 Qry Z.Gen,DualGenújz NoPfx
 btr Z.Cancel,BoolBeforeújc @F
 push axúmov al,$pTraceEventúcall Pcode1Dúpop ax
@@:cmp al,$pBoolújne NoPfxúOn Z.Cancel,BoolBefore
NoPfx:call Pcode1; Place the operator.
Targeted:test OpFactAh,mask AppendNumújz @F
; This an operator which needs a count after it, like Dots$$.
 xchg ax,OpAppendCxúcall Pcode1úxchg OpAppendCx,ax
@@:test OpFactAh,mask AppendRefújz NoRef
; This will be a variable reference, like the target of an Assign.
 push axúmov ax,Z.Resolvedúcall Pcode2úpop ax
NoRef:
 cmp al,$PjumpBase; The actual value of the operator.újb NoSpace
 cmp al,$PjumpCeilújae NoSpace
; Two bytes of space to be later filled by FillJump, on original pass.
; When just synchronizing, content is not needed.
; When DualGen, the dual code will want the same values as the original, put
; in different places.  So copy out for that potential purpose.
 Qry Z.Gen,DualOnlyújnz @F
; Two different calls to PCodeOp can be involved.
 mov CursorBx,Z.Cursorúmove Z.Target,Wptr gs:[CursorBx],cx
@@:call Pcode2
 Qry Z.Gen,DualGenújz NoSpace
 move Wptr gs:[CursorBx],Z.Target,cx
NoSpace:
if Debug
 push ax
endif
 mov al,ah
; Now consider the involved operands.
 mov StackDi,Z.Stack
 Qry Z.Gen,DualOnlyújnz PcodeOpDone
 test OpFactAl,mask DownOneújz NotDow
; Maybe the top stack item is just being lost, eg $pBy, or maybe there were
; two items reduced to one by a binary operator. In the latter case we
; want to look twice for constants and to mark result as $Variable.
; In the former case there will be no type given for the result.
 Assert mask InTypes eq 0C0h
 test OpFactAl,mask InTypesújns NotArithBool
 mov ah,'N'úcall ConstValue
NotArithBool:
 Downúmov Z.Stack,StackDi
 test OpFactAl,mask ResultTypeújz NoChange
; Note that the tables cannot take care of everything, eg multiple downs and
; unknown result type when $pDots.
NotDow:
; There can be nothing on the stack, eg Exit$$.
 mov StackDi,Z.Stackúcmp StackDi,Z.Base0úje PcodeOpRet
 test OpFactAl,mask InTypesújns CharBest
 mov ah,'N'úcall ConstValue
CharBest:
 test al,mask ResultTypeújz NoChange
 mov V.Dtype,$Variable
NoChange:

comment~ There is a lot more info available in static type analysis than
we can usefully use.  For example in ((A>B) & (C<D)) the $pAnd operation need
not check that its operands are 0 or 1, which it would have to do for (E & D).
But the check is cheap, so is it worth having opcodes for variations of And,
Or, Xor that don't do the check?  Similarly (A+2) > (B*3) is known to be
an arithmetic compare but the general compare will come to the same
conclusion with a few tests.  Is it worth six comparison operators to avoid
the tests on occasion?

(Of course, even more could be done if we kept track of variable contents
as well as sub-expressions.)

The actually useful things seem to be:

a) Detecting when a comparison is non-arithmetic. This avoids converting the
LHS to a number and then finding the RHS won't convert. We can detect this
for some values of constants as the operands.

b) Detecting when the arguments to a bif do not need checking. Processing
a bif instance is always two-stage; check the arguments then the rest. The
checking stage may be at compile time (Bifq$$) or run time (Bif$$). We can
detect opportunities only when the checking is on constants. (Exceptionally
something like FORMAT(A*B) doesn't need the Arith check but is that worth
bothering?)

When these constants are found to be suitable they are converted in type if
it helps, eg SUBSTR(Alpha,"7") will have the 7 held in binary.  See ConstValue.

c) Similarly for arithmetic operations, input constants are held in binary.
(The default ensures Abut$$ and Cat$$ get input constants as char strings)

d) For assignments of constants it is a matter of guesswork which
 representation is best for the constant. We guess based on the original
 source:  J=99 gets binary, J="99" gets char.
~
PcodeOpRet:
if Debug
 pop ax; Recover operator.
 mov StackDi,Z.Stackúcmp StackDi,Z.Base0úje Not1p
; We can do some debugging of this compile time stack accounting.
; But only on first pass.
 cmp Hg.Original,ZeroBpújne Not1púpush bxúpush diúz bxúmov bl,al
 shr bx,1úmov bl,Bptr OpFlags[bx]úQry bl,EndsClauseújz @F
; Not an eoc if $pBool preceeds comparison. This test OK for debug.
 mov di,Z.Cursorúcmp gs:Bptr[di-2],$pBoolúje @F
 mov cx,Z.Stackúmov bx,Z.Base0úmov si,Z.ClauseLine
 int 3úmov ax,MkMajMin(48,0)
 call Create4Dumpúcall Dumperújmp Raise
@@:pop diúpop bx
Not1p:;
endif
PcodeOpDone:
 pop si
 ret

if Solid
; This is information for each opcode. Order here doesn't matter, cos org'ed.
; InTypes 00b general, 01b char, 10b arith, 11b Boole.
; ResultType 00b unaltered, 01b char, 10b arith, 11b Boole
; There may also be an appended jump address.  This is determined by a range
; amongst the opcodes.
; Utility CODES.REX scans the OpFlags from here.
OpFlags:
; Flags for InTypes, ResultType, AppendNum, AppendRef, DownOne, EndsClause.
; Unary Boole:
 org OpFlags+$pNot/2úOperatorRec             <3,3,0,0,0,0>
; Diadic Boole
 org OpFlags+$pXor/2úOperatorRec             <3,3,0,0,1,0>
 org OpFlags+$pOr/2úOperatorRec              <3,3,0,0,1,0>
 org OpFlags+$pAnd/2úOperatorRec             <3,3,0,0,1,0>
; Unary arith:
 org OpFlags+$pNegate/2úOperatorRec          <2,2,0,0,0,0>
 org OpFlags+$pPositive/2úOperatorRec        <2,2,0,0,0,0>
; Dyadic arith:
 org OpFlags+$pIntDivide/2úOperatorRec       <2,2,0,0,1,0>
 org OpFlags+$pMultiply/2úOperatorRec        <2,2,0,0,1,0>
 org OpFlags+$pDivide/2úOperatorRec          <2,2,0,0,1,0>
 org OpFlags+$pRemainder/2úOperatorRec       <2,2,0,0,1,0>
 org OpFlags+$pSubtract/2úOperatorRec        <2,2,0,0,1,0>
 org OpFlags+$pAdd/2úOperatorRec             <2,2,0,0,1,0>
 org OpFlags+$pPower/2úOperatorRec           <2,2,0,0,1,0>
; Dyadic char:
 org OpFlags+$pAbut/2úOperatorRec            <1,1,0,0,1,0>
 org OpFlags+$pCat/2úOperatorRec             <1,1,0,0,1,0>
; Bif related;
 org OpFlags+$pLength/2úOperatorRec          <1,2,0,0,0,0>; Bif route.
 org OpFlags+$pMax/2úOperatorRec             <2,2,1,0,0,0>; Bif route.
 org OpFlags+$pMin/2úOperatorRec             <2,2,1,0,0,0>; Bif route.
 org OpFlags+$pBifq/2úOperatorRec            <0,0,1,0,0,0>
 org OpFlags+$pBif/2úOperatorRec             <0,0,1,0,0,0>
 org OpFlags+$pBifGroup/2úOperatorRec        <0,0,1,0,0,0>
; DO parts:
; Rep$$ and Number$$ build a DO block that incorporates their argument,
; RepEver$$ incorporates a spare.  So it makes more sense to say that
; $pNumber lowers the stack and the $pControlVar does not. (It matters to the
; Bcode making utility.)
; $pNumber does have number output but shouldn't look like a binary operator.
 org OpFlags+$pNumber/2úOperatorRec          <2,0,0,0,1,0>
 org OpFlags+$pTo/2úOperatorRec              <2,0,0,0,1,0>
 org OpFlags+$pBy/2úOperatorRec              <2,0,0,0,1,0>
 org OpFlags+$pWhile/2úOperatorRec           <3,0,0,0,1,0>
 org OpFlags+$pUntil/2úOperatorRec           <3,0,0,0,1,0>
 org OpFlags+$pLeave/2úOperatorRec           <0,0,0,0,0,1>
 org OpFlags+$pIterate/2úOperatorRec         <0,0,0,0,0,1>
 org OpFlags+$pIterRep/2úOperatorRec         <0,0,0,0,0,1>
 org OpFlags+$pRep/2úOperatorRec             <2,0,0,0,1,1>
 org OpFlags+$pRepEver/2úOperatorRec         <0,0,0,0,0,1>
 org OpFlags+$pUnDo/2úOperatorRec            <0,0,0,0,0,0>
 org OpFlags+$pFor/2úOperatorRec             <2,0,0,0,1,0>
 org OpFlags+$pIterCV/2úOperatorRec          <0,0,0,0,0,1>
 org OpFlags+$pControlVar/2úOperatorRec      <2,0,0,1,0,1>
 org OpFlags+$pDotControlVar/2úOperatorRec   <2,0,0,1,0,1>
; Jumps:
 org OpFlags+$pThen/2úOperatorRec            <3,0,0,0,1,1>
 org OpFlags+$pWhen/2úOperatorRec            <3,0,0,0,1,1>
 org OpFlags+$pJump/2úOperatorRec            <0,0,0,0,0,0>
 org OpFlags+$pEq/2úOperatorRec              <0,3,0,0,1,0>
 org OpFlags+$pNe/2úOperatorRec              <0,3,0,0,1,0>
 org OpFlags+$pLt/2úOperatorRec              <0,3,0,0,1,0>
 org OpFlags+$pLe/2úOperatorRec              <0,3,0,0,1,0>
 org OpFlags+$pGe/2úOperatorRec              <0,3,0,0,1,0>
 org OpFlags+$pGt/2úOperatorRec              <0,3,0,0,1,0>
 org OpFlags+$pSeq/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pSne/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pSlt/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pSle/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pSge/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pSgt/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pCeq/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pCne/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pClt/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pCle/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pCge/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pCgt/2úOperatorRec             <1,3,0,0,1,0>
 org OpFlags+$pReturn/2úOperatorRec          <0,0,0,0,0,1>
 org OpFlags+$pCallOn/2úOperatorRec          <0,0,1,1,0,1>
 org OpFlags+$pSignalOn/2úOperatorRec        <0,0,1,1,0,1>
 org OpFlags+$pSignal/2úOperatorRec          <0,0,0,1,0,1>
 org OpFlags+$pCall/2úOperatorRec            <0,0,0,1,0,1>
 org OpFlags+$pInvoke/2úOperatorRec          <0,0,1,1,0,0>
 org OpFlags+$pRaise/2úOperatorRec           <0,0,1,0,0,0>
; Assignments:
 org OpFlags+$pAssignConst/2úOperatorRec     <0,0,0,1,1,1>
 org OpFlags+$pAssign/2úOperatorRec          <0,0,0,1,1,1>
 org OpFlags+$pUnstore/2úOperatorRec         <0,0,0,0,0,0>
 org OpFlags+$pAssignStem/2úOperatorRec      <0,0,0,1,1,1>
 org OpFlags+$pAssignDots/2úOperatorRec      <0,0,0,1,1,1>
 org OpFlags+$pAssignDotsP/2úOperatorRec     <0,0,0,1,0,0>
; Others. Nop sometimes with THEN so cannot use for EndsClause test.
 org OpFlags+$pNop/2úOperatorRec             <0,0,0,0,0,0>
 org OpFlags+$pParse/2úOperatorRec           <0,0,1,0,0,0>
 org OpFlags+$pDots/2úOperatorRec            <0,0,1,1,1,0>
 org OpFlags+$pBool/2úOperatorRec            <0,0,0,0,0,0>; Too soon for result.
 org OpFlags+$pNumeric/2úOperatorRec         <0,0,1,0,1,1>
 org OpFlags+$pExit/2úOperatorRec            <0,0,0,0,0,1>
 org OpFlags+$pReturns/2úOperatorRec         <0,0,0,0,1,1>
 org OpFlags+$pDrop/2úOperatorRec            <0,0,0,1,0,0>
 org OpFlags+$pExpose/2úOperatorRec          <0,0,0,1,0,0>
 org OpFlags+$pDropList/2úOperatorRec        <0,0,0,0,1,0>
 org OpFlags+$pExposeList/2úOperatorRec      <0,0,0,1,0,0>
 org OpFlags+$pAddress/2úOperatorRec         <0,0,0,0,0,1>
 org OpFlags+$pEnvName/2úOperatorRec         <1,0,0,0,1,0>
 org OpFlags+$pCommand/2úOperatorRec         <1,0,0,0,1,1>
 org OpFlags+$pCommandEnv/2úOperatorRec      <1,0,1,0,0,0>
 org OpFlags+$pResumeParse/2úOperatorRec     <0,0,0,0,0,0>
 org OpFlags+$pResult/2úOperatorRec          <0,0,0,0,1,1>
 org OpFlags+$pInterpret/2úOperatorRec       <1,0,0,0,1,1>
 org OpFlags+$pOptions/2úOperatorRec         <1,0,0,0,1,1>
 org OpFlags+$pPush/2úOperatorRec            <1,0,0,0,1,1>
 org OpFlags+$pQueue/2úOperatorRec           <1,0,0,0,1,1>
 org OpFlags+$pTrace/2úOperatorRec           <1,0,0,0,1,1>
 org OpFlags+$pSignalOff/2úOperatorRec       <0,0,1,0,0,1>
 org OpFlags+$pSignalV/2úOperatorRec         <0,0,0,0,1,1>
 org OpFlags+$pInterpEnd/2úOperatorRec       <0,0,0,0,0,1>
 org OpFlags+$pSay/2úOperatorRec             <1,0,0,0,1,1>
 org OpFlags+$pSysVar/2úOperatorRec          <0,0,0,0,0,0>
 org OpFlags+$pTraceEvent/2úOperatorRec      <0,0,1,0,0,0>
 org OpFlags+$PcodesCeil

;------------------------------------------------------------------------------
; This is the tie-in between lexical values and Pcode operators.
;------------------------------------------------------------------------------
; To get freedom over the numbers corresponding to Pcodes, there is a
; translation table from syntax code ($s) to the opcode in the Pcode.
; AL contains the operator. SI is in use for the parser frame.
; DI can be used.

; After the freedoms in group order have been used, there are numeric
; relations between the codes for the syntax elements. These are made
; use of in actions when materializing the $s codes.  The $s codes are
; nearly compact but not in the best order for execution so there is
; later a $s to $p conversion.
; The relations that have to be fitted around are:
;BBBBBB  B           BB     BBBBBBBBBBBB                     BB  B
;                                          V   VV  VVVVV   V   VV
;                                            U   UU
;          P   PPP P   P   P
;         S   S   S
;                                       NN  N
;                                                       III
;      DD   DD
;                       LMM
; Also see intervals for DROP & EXPOSE type.(Got this wrong & had to fixup.)
; Also see needs of PosPlus PosMinus PosEq. (Would like to fit here but
; actually used flags.)
; Also need Length-Max-Min sequential.
S2P:
 Assert $sPercent eq $-S2P
BaseB equ $-$Percent
 Assert $ eq BaseB+$Percentúdb $pIntDivide
 Assert $ eq BaseB+$Asteriskúdb $pMultiply
 Assert $ eq BaseB+$Slashúdb $pDivide
 Assert $ eq BaseB+$Remúdb $pRemainder
 Assert $ eq BaseB+$Xorúdb $pXor
 Assert $ eq BaseB+$Orúdb $pOr
; DROP and EXPOSE are treated together. Also DropList and ExposeList
 BaseD equ $-$DROP
 Assert $sDrop eq $-S2P
 Assert $ eq BaseD+$DROPúdb $pDrop
 db $pExpose
 Assert $ eq BaseB+$Andúdb $pAnd
; STEM/STREAM/NORMAL are treated together
BaseS equ $-$STEM
 Assert $sStem eq $-S2P
 Assert $ eq BaseS+$STEMúdb $nStem
; PARSE sources are done together.
BaseP equ $-$WITH
 Assert $sWith eq $-S2P
 Assert $ eq BaseP+$WITHúdb $nWith
 Assert $sDropList eq $-S2P
 db $pDropList
 db $pExposeList
 Assert $ eq BaseS+$STREAMúdb $nStream
; Historically there were opcodes like $pLineIn but latest is to use markers.
 Assert $ eq BaseP+$LINEINúdb $nLineIn
 Assert $ eq BaseP+$SOURCEúdb $nSource
 Assert $ eq BaseP+$VERSIONúdb $nVersion
 Assert $ eq BaseS+$NORMALúdb $nNormal
 Assert $ eq BaseP+$PULLúdb $nPull
 db 0 ; Spare
 Assert $sMinus eq $-S2P
 Assert $ eq BaseB+$Minusúdb $pSubtract
 Assert $ eq BaseB+$Plusúdb $pAdd
 Assert $ eq BaseP+$VARúdb $nVar
 Assert $sLength eq $-S2P
 db $pLength
 db $pMax
 db $pMin
 Assert $ eq BaseP+$ARGúdb $nArg
; Eq was forced to top of its group, in order to make comparisons compact.
 Assert $sEq eq $-S2P
 Assert $ eq BaseB+$Eqúdb $pEq
 Assert $ eq BaseB+$Neúdb $pNe
 Assert $ eq BaseB+$Ltúdb $pLt
 Assert $ eq BaseB+$Leúdb $pLe
 Assert $ eq BaseB+$Geúdb $pGe
 Assert $ eq BaseB+$Gtúdb $pGt
 Assert $sSeq eq $-S2P
 Assert $ eq BaseB+$Seqúdb $pSeq
 Assert $ eq BaseB+$Sneúdb $pSne
 Assert $ eq BaseB+$Sltúdb $pSlt
 Assert $ eq BaseB+$Sleúdb $pSle
 Assert $ eq BaseB+$Sgeúdb $pSge
 Assert $ eq BaseB+$Sgtúdb $pSgt
; NUMERIC components are done together.
BaseN equ $-$DIGITS
 Assert $sDigits eq $-S2P
 Assert $ eq BaseN+$DIGITSúdb $nDigits
 Assert $ eq BaseN+$FUZZúdb $nFuzz
 db 0; $sTailed was here, now unneeded
; Several verbs are done together.
BaseV equ $-$NOP
 Assert $sNop eq $-S2P
 Assert $ eq BaseV+$NOPúdb $pNop
 Assert $sForm eq $-S2P
 Assert $ eq BaseN+$FORMúdb $nForm
BaseU equ $-$Not
 Assert $ eq BaseU+$Notúdb $pNot
 Assert $sAddress eq $-S2Púdb $pAddress
 Assert $ eq BaseV+$INTERPRETúdb $pInterpret
 Assert $ eq BaseV+$OPTIONSúdb $pOptions
 Assert $sNegate eq $-S2P
 Assert $ eq BaseU+$Minusúdb $pNegate
 Assert $sPositive eq $-S2P
 Assert $ eq BaseU+$Plusúdb $pPositive
 Assert $sExit eq $-S2P
 Assert $ eq BaseV+$EXITúdb $pExit
 Assert $ eq BaseV+$PUSHúdb $pPush
 Assert $ eq BaseV+$QUEUEúdb $pQueue
 Assert $sReturns eq $-S2P
 Assert $ eq BaseV+$RETURNúdb $pReturns
 Assert $ eq BaseV+$SAYúdb $pSay
 Assert $sNumber eq $-S2Púdb $pNumber
 db 0;
 Assert $sRaise eq $-S2Púdb $pRaise
 Assert $ eq BaseV+$TRACEúdb $pTrace
 db 0; was $sCatDot now unneeded.
 Assert $ eq BaseB+$Abutúdb $pAbut
 Assert $ eq BaseB+$Catúdb $pCat
 Assert $sLeave eq $-S2P
 Assert $ eq BaseV+$LEAVEúdb $pLeave
 Assert $sIterate eq $-S2P
 Assert $ eq BaseV+$ITERATEúdb $pIterate
 Assert $ eq BaseB+$Powerúdb $pPower
endif

Scode:push bxúmov bx,S2P; For XLATúxlat cs:Bptr[bx]; Pick up Pcode.
 pop bxújmp PcodeOp

;------------------------------------------------------------------------------
; Here is where values are directly put into the code segment.
; Pcode2 with Z.Synch=0 puts two bytes of original code in.
; Pcode2 with Z.Synch\=0 adjusts Z.Cursor by 2 to reflect bytes made earlier
; and also makes two bytes dual code at Hg.Avail if DualGen is on.
; So Pcode2 is used when making original, when synching, and when original
; and dual code are to be the same.
; When original and dual are not to be the same:
; Pcode2S is Pcode2 without possibility of making dual code.
; Pcode2D makes the dual code without adjusting Z.Cursor.
; Assert DualGen on implies Z.Synch\=0
;------------------------------------------------------------------------------
Pcode2:Qry Z.Gen,DualGenújnz Pcode2DSame
Pcode2S:mov CursorBx,Z.Cursorúcmp ZeroBp,Z.Synchújne NotOrig
; Original make.
if Debug
 cmp CursorBx,Hg.Availúje @Fúint 3ú@@:
endif
 call PcodeSafeGsBxúmov gs:Wptr[CursorBx],axúadd Hg.Avail,2
NotOrig:add Z.Cursor,2úpush CursorBxúinc2 CursorBx
PcodeRet:cmp Z.Synch,ZeroBpúje @F
 cmp CursorBx,Z.Synchúje SynchMatch
@@:pop CursorBxúret

Pcode2DSame:Qry Z.Gen,DualOnlyújnz Pcode2Dúadd Z.Cursor,2
Pcode2D:mov CursorBx,Hg.Availúcall PcodeSafeGsBxúmov gs:Wptr[CursorBx],ax
 add Hg.Avail,2úret

Pcode1:Qry Z.Gen,DualGenújnz Pcode1DSame
Pcode1S:mov CursorBx,Z.Cursorúcmp ZeroBp,Z.Synchújne @F
 call PcodeSafeGsBxúmov gs:Bptr[CursorBx],alúinc Hg.Avail
@@:inc Z.Cursorúpush CursorBxúinc CursorBxújmp PcodeRet

Pcode1DSame:Qry Z.Gen,DualOnlyújnz Pcode1Dúinc Z.Cursor
Pcode1D:mov CursorBx,Hg.Availúcall PcodeSafeGsBxúmov gs:Bptr[CursorBx],al
 inc Hg.Availúret

PcodeSafeGsBx:; Called when extending Pcode - may need to enlarge the segment.
@@:cmp CursorBx,Hg.Triggerújb @F
 push diúmov di,Zshape.Codeúcall MoreSpaceEsúpop diúmv gs,es
 mov SymbolsEs,Z.Symbolsújmp @B
@@:ret

BackOff2:sub Z.Cursor,2úcmp Z.Synch,ZeroBpújne @Fúsub Hg.Avail,2ú@@:ret

; Sometimes synchronizing is just to get .MN or msg setup.
SynchMatch:Qry Z.Gen,Dualújz Terminate
; In this case we have synched in order to setup making dual pcode as we
; continue to the next clause.
 move Z.DualCode,Hg.Avail,bx; Where code for clause will be made.
 On Z.Gen,DualPending
 pop CursorBxúret

;------------------------------------------------------------------------------
; Generation for Operands.
;------------------------------------------------------------------------------
comment~ Targets, ie LHS of assign or in parse, must be delayed if tailed,
because code made now would be in the wrong place.  If not tailed it can be
looked up, but the result has to be held over for the right place in code.
There can be more than one held up (when parse template) so this is producing a
list.

Symbols that look like names have to be uppercased early so that they can be
checked against keyword lists. So it makes sense to look them up early.

Constants gain from delayed resolution - by the time they are looked up we can
have more information on the operations they are involved in. (An advantage,
at least in principle.)

Labels come in both forms but anyway are suitable for lookup without delay.
~
Action0:; The uppercased symbol will be sitting in the Symbols segment.
; Except in the case of a target with dots, it will get looked up.
; Dots are not significant if symbol is taken as a constant.
 Qry Z.Middles,LookLabelújnz Lookup; And from there ret to Action0 caller.
 Qry Z.Clause,Tailedújnz Action0Dots
; Undotted, can be resolved now.
 call Lookup; Result to Z.Resolved
; A target will be held over on the stack, a CheckDO symbol will be held in
; Resolved until the check is made.
 Qry Z.Middles,TargetSymbol,CheckDOújz QueryLoad; Result into Pcode.
; A case like LEAVE ABC does not need resolved ABC kept on the stack.
 Qry Z.Middles,TargetSymbolújz Action0ret
; But ABC= does.
 call UpStackúmove V.HeldOver,Z.Resolvedúmov V.Dtype,$NullString
Action0ret:ret

comment~
There are complexities about the performance of compound variables.  Timing
isn't easy because of the coarse granularity of the DOS timer tick and because
any change of implementation can have its effect masked by speed changes due
solely to code being aligned differently, but I have done experiments.

The simplest way to implement a dotted reference is to have a $pCatDot operation
that concatenates two parts of a tail, putting a dot between them. The stemmed
lookup then always has one argument. (There has to be lookahead to prevent
NOVALUE arising from fetch of the tail values but that is not too bothersome.)
Sadly, this is not efficient; there has to be a memory allocation for the
$pCatDot result and often that result has to be copied into the stem's set of
keys.

The more efficient way is to just stack the tail parts and put a count of them
on the subsequent operation.  The tail parts can then be copied directly into
the stem's space (with dots between). This seems to make a difference of 60K in
the 1000K clauses per second target.

For an assignment, A.B.C=99, the tail count is deduced from the current
number of items on the stack but that doesn't work for sources, eg f(X,A.B.C).
So the counter is on $pDots only.

An implied count for the simplest cases would be an space improvement and maybe
a speed improvement since lookup can be done with the tail in its uncopied
position. This is not yet implemented.

Fetch from a stem (eg SAY A.) is no different from fetching from an ordinary
variable.  However assignment (A.=99) has extra work to do beyond setting
the default value; some elements may be exposed and these must also be
assigned to.
~

ChkDO:On Z.Middles,TakenConstantúcall Lookup
; eg LEAVE A.B - just need Z.Resolved for comparison.
 sub Z.Stack,$StrideVúret

Action0Dots:call UpStack
; CheckDO is for symbol with END/ITERATE/LEAVE.
; Dotted CheckDO subject - resolved as "A.B".
 Qry Z.Middles,CheckDOújnz ChkDO
; Usual dotted - On soft stack as a string.
 mv ds,esúmov si,Hd.Availúmovzx cx,Bptr[si]úinc cx
 push axúcall ResultSpaceúpush diúmov di,axúrep movsbúpop diúpop ax
 mov SymbolsEs,Z.Symbols
; Unless a target, the Pcode for the dotted reference will be made now.
 Qry Z.Middles,TargetSymbolújz @FúOff Z.Clause,Tailedúret
; In execution tail components stack but during compile they don't.
@@:; This type awkward in PARSE.
 btr Z.Clause,InParseújnc @Fúmov al,$mParseEscapeúcall Pcode1ú@@:
 call Lookup
; Delay the $pDots because it may be $Drop instead.
 sub Z.Stack,$StrideV

; At this time Z.Resolved is set but before we put the reference in the Pcode
; there are some cases to test where this isn't just a load.
QueryLoad:
; DROP abc and EXPOSE abc are not NOVALUE positions so best if opcode
; precedes operand. On the other hand DROP (abc) is a NOVALUE position.
; EXPOSE (abc) is a NOVALUE position where EXPOSE happens before getting
; the value.
; So maybe best is DROP A => $pDrop A, EXPOSE A => $pExpose A,
; DROP A. => $pDrop A., EXPOSE A. => $pExpose A.,
; DROP A.B => B $pDrop A., EXPOSE A.B => B $pExpose A.
; DROP (A) => A $pDropList, EXPOSE (A) => $pExposeList A
; DROP (A.B) => A.B $pDropList, EXPOSE (A.B) => B $pExposeList A.
; For a.b or (a.b) the tails are already in the Pcode and Z.Resolved is a.
 mov ax,Z.KWFoundúcmp ax,$DROPúje IsDropúcmp ax,$EXPOSEújne PcodeLoadX
 sub al,3; Fix 'cos I got EXPOSE value wrong.
; Here with DROP and EXPOSE
IsDrop:add al,$sDrop-$DROP
; Opcode to absorb whether argument is a list.
 cmp Z.TokWas,$Lparenújne @Fúadd al,$sDropList-$sDropú@@:
; DropList has no post argument.
 cmp al,$sDropListúje DropList
 Off Z.Clause,WasTailed
 jmp Scode; And the $pDrop/$pExposed will add Z.Resolved (without load).

; WasTailed must be cleared for next lookup.
DropList:btr Z.Clause,WasTailedúpush ax
 jc @Fúcall PcodeLoadúpop axújmp Scode

@@:OpAl $pDots; Flags on $pDots will add Z.Resolved.
 pop axújmp Scode

PcodeLoadX:btr Z.Clause,WasTailedújnc PcodeLoad
 call UpStack
 call UpStack
 OpAl $pDots
 mov V.Dtype,$Variable
 jmp PcodeLoadRet

PcodeLoad:; Puts the latest operand into Pcode with value to stack.
; Often it will be a variable and "value" will be synthetic.
 mov ArrayBx,Z.Resolvedúcall UpStack
; If is a constant, it's value is around. Else synthesize a general value.
 mov V.Dtype,$Variableútest bl,7újz IsVar
; That test isn't quite good enough because some persistent variables, eg .MN,
; are in segment for "constants". Nine is always first constant, cf Reserved.
 cmp bx,$?Nineújae UsualCon
 mov V.Dtype,$Sigl
; This type awkward in PARSE.
 btr Z.Clause,InParseújnc IsVar
 mov al,$mParseEscapeúpush bxúcall Pcode1úpop bxújmp IsVar
UsualCon:
; Well, we do have the value in Vbx. but now is a bit early to load it because
; we don't know what type it will be used as. Better just record the instance.
; We may be able to pick up what the constant became after conversion, so
; later passes have it right without conversion.
 cmp Z.Synch,ZeroBpúje UCorig
 mov CursorBx,Z.Cursor
; Can't be AssignConst case here, but original could be.
 cmp Bptr gs:[CursorBx],$pAssignConstújne @Fúinc CursorBxú@@:
 mov ArrayBx,gs:[CursorBx]
UCorig:mov V.Dtype,$Constantúmov V.WhichCon,ArrayBx
 move V.PcodePos,Hg.Avail
IsVar:
 mov ax,ArrayBxúcmp V.Dtype,$Siglújne @F
 push axúcall Pcode2úOpAl $pSysVarúpop axúmov V.Dtype,$Variableújmp PcodeLoadRet

; Is the Pcode position where this operand is to go two bytes on from the
; last assignment target?
@@:
if ForBcode
 jmp Pcode2
endif
 mov CursorBx,Z.Cursorúdec2 CursorBxúcmp CursorBx,Z.LastTargetújne Pcode2Via
; If so, is what was stored then the same as the load now?
 mov dx,axúadd dx,$CaseTarget
 cmp dx,gs:[CursorBx]újne Pcode2Via
 push ax
 OpAl $pUnstore
 pop ax
; That won't be right for the tracing version.
 Qry Z.Gen,DualGenújz @F
 dec Hg.Avail
 call Pcode2D; replace with ordinary load.
@@:
PcodeLoadRet:test al,7úmov ah,$TraceVarújz @Fúmov ah,$TraceLitú@@:
 jmp TraceEvent

Pcode2Via:call Pcode2újmp PcodeLoadRet
;------------------------------------------------------------------------------
; Generation of specific sequences.
;------------------------------------------------------------------------------
Action1:; Assignment
; There are various opcodes associated with assignment.
; $pAssign covers the majority of cases.
; $pAssignDots handles the A.B.C=99 sort.
; $pAssignStem handles the A.=99 sort.
; $pStore is an optimization for where the value is needed again. A=exp;if A...
; $pAssignConst is an optimization for RHS constant. A=99
; $pControlVar when the assignment is part of DO header activity. DO J=....
; $pDotControlVar when the assignment is part of DO header activity with a
; compound.  Both DO A.B=... and DO A.=....
; Assignments also happen within $pParse complex.
 cmp S1.State,$DoFrameúje ControlVar
MakeAssign:EvAh $TraceAssign
; Top stack item corresponds to is RHS, one below the LHS.
; We will set cx up to indicate constant.
; return dx=0 except when tails.
 z cxúcmp V.Dtype,$Constantújne @Fúinc cx
; We don't know how the LHS is going to be used, so deciding a representation
; for the value is guesswork.
 z ahúcall ConstValueX
@@:Down; Removing the RHS
 mov Z.Stack,StackDi
; LHS on the stack says what sort of target it is.
 cmp V.Dtype,$NullStringújne DotsLHS
; The LHS was not tailed and was resolved earlier.
 move Z.Resolved,V.HeldOver
; Bit of an afterthought here - we can't use the simple constant assignment
; code when the target is a stem.
 mov ds,Z.Varsúmov bx,axúmov bx,Vbx.Here
; SymbolsEs:bx now addresses "counted string" form of name.
; Does it end with dot?
 movzx dx,Bptr SymbolsEs:[bx]úadd bx,dxúcmp Bptr SymbolsEs:[bx],'.'
 z dxúje StemTgt
; If the RHS was a constant we can use a Pcode that doesn't check so much.
; This was only 15% faster in execution, despite avoiding stack.
; (Usual doubts about accuracy of measurement)
; DI has the stack item for the target.
; CX nonzero indicates constant being assigned.
if ForBcode eq 0
 test cx,cxújz NotAssignConst
 z Z.LastTarget; Can't use $pUnstore after this.
; The dual code will not be the same, so flag fiddling.
; We need to save/restore a single flag - not simple.
 btr Z.Gen,DualGenúpushf
; The RHS is already on the Pcode, at a different place than wanted, original.
; The RHS is already on the Pcode, in midst of AssignConstant, subsequently.
 call BackOff2úmov CursorBx,Z.Cursor
; If Synch, the $pAssignConst is already made. Pick up RHS and traverse.
 cmp Z.Synch,ZeroBpújz @Fúinc CursorBxú@@:
; AX is the LHS. Place $pAssignConst RHS LHS
 mov cx,Wptr gs:[CursorBx]
 mov Z.Resolved,cxúpush axúOpAl $pAssignConstúpop axúcall Pcode2
 popfújnc @FúOn Z.Gen,DualGenú@@:
 Qry Z.Gen,DualGenújz @F
 call UpStack
 On Z.Gen,DualOnly
 mov Z.Resolved,ax
 OpAl $pAssign
 Off Z.Gen,DualOnly
@@:ret

endif

; Z.LastTarget is used when a subsequent operand is fetched, to possibly
; change $pAssign to $pStore.
; OpAl has special tests for $pAssign, so it may get omitted.
NotAssignConst:OpAl $pAssignúmov Z.LastTarget,CursorBxúret

StemTgt:mov Z.LastTarget,ZeroBpúOpRet $pAssignStem

; Compound name hasn't been looked up yet.
DotsLHS:mov dx,Hg.Availúmov TokNumAh,$VAR_SYMBOLúOn Z.Clause,Tailed
 mov StackDi,Z.Stack
 call Lookup
; Now have tails put in Pcode set, PartCountCl set, and Z.Resolved target.
 OpRet $pAssignDots

Action2:; Keyword instructions
; Pick out some simple verbs.
 mov ax,Z.KWFoundúcmp ax,$NOPújb OtherVerbúcmp ax,$TRACEúja OtherVerb
 add al,$sNop-$NOP
; Faster to have a distinct Pcode for RETURN without argument.
 cmp al,$sReturnsújne Scode
 cmp StackDi,Z.Base0újne Scode
 OpRet $pReturn

OtherVerb:Qry Z.Clause,Signal; Copes with SIGNAL and NAMEújnz SignalVerb
 Qry Z.Clause,WasParseújz ActionRet
; Cannot be in InParse??
@@:Qry Z.Clause,InParseújnz @FúOpAl $pResumeParse
@@:sub Z.Stack,$StrideVúmov al,$mParseEndújmp Pcode1

Action3:; end of commandúOpRet $pCommand

Action6:; PARSE VALUE
 mov Z.KWMiddle,$WithKey
ActionRet:
 ret

Action11:; Unary operator
; Need to alter + and -. Alters Not also.
 add S.Token,$sNegate-$sMinus
 mov ah,$TracePrefixújmp @F

Action10:; Binary operator
 mov ah,$TraceOperator
@@:push axúcall ActionBinúcall Scodeúpop ax

TraceEvent:; Compile time note of tracing potential.
 Qry Z.Gen,DualGenújnz @Fúretú@@:
 mov al,$pTraceEventújmp Pcode2D

Action12:; Comparisons.
comment~ There are alternative designs possible. Ideally, we would have opcodes
for the six comparison results, times three for strict, non-strict, known
non-arithmetic. (Known arithmetic not much of an optimization because the
check is quick.) Also times another three for result-to-stack, result is
absolute jump, result is (one byte) relative jump.

To avoid getting too expensive on opcodes, I have postponed using relative jumps
(which needs an extra pass) and made the result-to-stack mechanism a prefix
to the opcode.
~
; Change from $s codes to $p ones. Simple to do that without the XLAT table.
 call ActionBinúadd al,alúadd al,$pEq-2*$sEq
; Specialize further, maybe.
 cmp al,$pSeqújae Action12Asis
; If either known to be non-arith then make it a char one.
; ie constants that don't have number syntax.
; Even if we don't know it is arith, it probably helps to use arith const
; where possible.
 mov ah,'N'
 cmp V.Dtype,$Constantújne @F
 call ConstValueX
; The flags from NumDxBx in ConstValueX are available here.
 jc Action12Char; Non number syntax so must be char compare.
 jmp Action12Asis

@@:cmp V0.Dtype,$Constantújne Action12Asis
 Downúcall ConstValueXúUpCareújnc Action12Asis
Action12Char:; A non-strict compare without arithmetic checks.
if ForBcode eq 0
 add al,$pCeq-$pEq
endif
Action12Asis:; Make the long form initially. It may get optimized.
 push axúOpAl $pBoolúpop axúinc CursorBx
 mov Z.CompareAt,CursorBxúcall PcodeOp
; Comparison operators have space for a jump value, except when $pBool precedes.
; The tables say 'make space' but we don't want it here.
 call BackOff2
 Qry Z.Gen,DualGenújz @Fúsub Hg.Avail,2ú@@:
 EvRet $TraceOperator

; S.Token was set by the parser on encountering the operator.  Now is the
; time to take it from the parser state and put it in the Pcode.
; ActionBin puts it in al.
ActionBin:move Z.InsOperator,S.Operation
 mov al,Bptr S.Tokenúadd al,$sPercent-$Percentúret

Action18:; Save function name over the arglist.
 mov ax,Z.Resolvedúmov S.Caller,axúmov S.Parms,StackDi
Action18Ret:ret

; It would be nice to have had a utility to sort out different actions
; and how they share variables but that is not yet mechanised.

$SelectFrame equ 2*363 ; S112 W177   SELECT ncl^....
$IfFrame equ 2*345 ; S48 W63         ifexpr.91 ^ ncl
$DoFrame equ 2*435 ; S8 W9           DO ^ ....

Action20:; THEN
; The THEN of IF and the THEN of WHEN differ only in the message number when the
; subject is non-Boolean. We could save a code point by using a rescan to
; determine that but I have chosen the simpler approach of a different Pcode.
; ?? Rescan for line number anyway.

; Here we find a place of the parser stack where we can store info (FillJump)
; and recover it at the end of the THEN part. (Action 21, Action 22)
; Similarly for SELECT.

 mov al,$pWhen
 cmp S.State,$IfFrameúje UseS1
; Looks like can be different for THEN when THEN starts new line.
 cmp S1.State,$IfFrameújne @Fúadd ParseSi,$StrideSújmp UseS1ú@@:
 cmp S1.State,$SelectFrame
 jne @Fúz S1.SelectSiteúinc Z.TraceOnlyújmp UseS1wú@@:
 add ParseSi,$StrideS
; Test S1 (was S2 on entry)
 cmp S1.State,$SelectFrameúje UseS1w
 add ParseSi,$StrideS
 cmp S1.State,$SelectFrameúje UseS1w
 Error49Bp
; A compare made a $pBool followed by a $pEq or similar. This leaves the
; comparison result on the stack. A $pThen now with target would do the
; conditional jump. We optimize by accepting that sequence with $pBool and
; $pThen bytes left out. However, trace and optimizing don't combine.
UseS1:mov al,$pThen
; Cannot use Hd.Avail as test value because label can get to array before it
; appears with a label.
 move S1.SoFar,Hg.Avail,dx; See traceonly test.
UseS1w:mov dx,Z.CompareAtúz Z.CompareAtúadd dx,1úcmp dx,Z.Cursorújne @F
 call Shortenújmp EndThen
@@:call PcodeOp; $pThen/$pWhen retained.
 mov S1.JumpSite,CursorBx
; The 'then' is a separate clause.
; QueryKey did a ClauseSourceEnd when THEN keyword, for what was ahead of THEN.
; Here is one for the THEN itself.
EndThen:mov CursorSi,Z.Scanpúcall ClauseSourceEnd
 jmp Action91

Shorten:; We have made Bool-Compare when just Compare wanted on short form.
; That's true of first time but later we will have just just stepped over
; so compare-op has to be found somewhere different.
 mov CursorBx,Z.Cursorúcmp Z.Synch,ZeroBpúje @Fúdec CursorBxú@@:
 mov dl,Bptr gs:[CursorBx-1];The $pEq like.
 mov dh,al
; Generate twice, with differing flags for original and trace code.
; Saving of individual flag is clumsy.
 btr Z.Gen,DualGenúpushf
 call BackOff2úmov al,dlúcall PcodeOpúmov S1.JumpSite,CursorBx
 popfújnc @FúOn Z.Gen,DualGenú@@:
 Qry Z.Gen,DualGenújz @F
; Already made Bool-Comp-TraceEvent[Expr]
 On Z.Gen,DualOnlyúmov al,dhúcall PcodeOpúOff Z.Gen,DualOnly
@@:ret

Action21:; ELSE
 OpAl $pJumpúmov dx,CursorBxúxchg S.JumpSite,CursorBx
 call FillJump
 mov CursorSi,Z.Scanpúcall ClauseSourceEnd
; If we are doing synch for a trace of an ELSE leg we actually want two
; lines, one for the ELSE and one for the first clause of the leg.
; Normally the Z.Synch would take us to the latter because the branch from
; THEN goes there, not to any Pcode from ELSE.
; The Pcode from ELSE will be the jump 3 bytes before that.
; If we detect this case, we can get the ELSE, then repeat the synch for
; the clause.
; That works when the ELSE leg is to be executed.
; In the alternate case, when the THEN leg is executed. We want to take the
; jump that is at the end of the THEN leg but not show the ELSE keyword that
; corresponds to the jump. See the place that outputs source during tracing.
 Qry Z.Program,ShowELSEújz Action91
 Qry Z.Gen,Dualújz Action91
 add dx,2úcmp dx,Z.Synchújne Action91
; End the compile with the flag still on.  Higher level will test
 jmp Terminate

; FillJump is always filling a forward reference with a branch to the current
; end of generated code.
; Only fill in the branch targets once. (Not on scans for line numbers.)
FillJump:mov ax,Z.Cursorúcmp Z.Synch,ZeroBpújne SynchTarget
 mov gs:[CursorBx],ax
; Can't optimize over branch-in points.
@@:z Z.LastTargetúret

SynchTarget:cmp ax,gs:[CursorBx]úje @Búint 3úError49Bp

Action22:; if completion.
; May need to mark labels trace-only, first pass.
 cmp Hg.Original,ZeroBpújne @F
; Looks at labels.
; Clumsy to scan through constants after every IF. Should chain off IF. NYI
 mov ProgEs,Z.ProgScope
 mov ds,Z.Constsúmov ArrayBx,Hd.Avail
Action22L:sub ArrayBx,$StrideV
 cmp ArrayBx,$SizeConstsHeaderújb @F
; Here for each constant since start of IF.
 cmp Vbxe.Dtype,$Labelújne Action22L
; Here if a label.
 mov ax,Vbxe.LabelValueúTestReg axújz Action22L
; Here if it has appeared with a colon.
 cmp ax,S.SoFarújb Action22L
; Here if not pointing to before the IF.
 cmp ax,Hg.Availúje Action22L
; Here if not at the end of this if clause.
 mov Bptr Vbxe.LabelType,1; Marks trace-only
 jmp Action22L

@@:mov SymbolsEs,Z.Symbols
 mov CursorBx,S.JumpSiteújmp FillJump

Action23:; select; JumpSite zeroed by otherwise.
 cmp S.JumpSite,ZeroBpúje @F
; Substitute otherwise is message 7.3
 mov OpAppendCl,$n7p3úOpAl $pRaise
; NYI also the S.ClauseWas field of the SELECT frame.
@@:mov di,S.SelectSiteúz Z.LastTarget
; There is a chain of forward branch sites.
 cmp Z.Synch,ZeroBpújne Action22Ret
; Fill them all.
 mov cx,Z.Cursor
@@:mov si,gs:[di]úmov gs:[di],cxúmov di,siúTestReg diújnz @B
Action22Ret:ret

Action24:; otherwise; Mark JumpSite with zero.
; 2011 added variety??
; +2 then +1 then +1 instead  of +3 then +1
 add ParseSi,2*$StrideSúcmp S.State,$SelectFrameúje @F
 add ParseSi,$StrideSúcmp S.State,$SelectFrameúje @F
 add ParseSi,$StrideSúcmp S.State,$SelectFrameúje @F
 Error49Bp
@@:z S.JumpSiteúret

comment~ We made no special actions in the BNF for detecting 'trace-only' labels
so that is done with ad-hoc rules.  We detect 'END' in QueryKey to count down
Z.TraceOnly.  We count it up on 'DO'.  The keyword SELECT is not specially
detected so to count up for that we actually count in the action for the first
WHEN of the select.  This count allows us to detect trace-onlys within DO-END
and SELECT-END by Z.TraceOnly > 0.

For IF things are harder because IF A THEN NOP;ABC:  is traceonly when an ELSE
follows.  It seems that IF should record the Pcode position when it starts.
When it ends, the labels for places at least as high as that recorded are
traceonly, unless they are equal to the current position.  (This assumes that an
ELSE, even ELSE NOP, makes some code.)

~
Action25:; when completion.
 cmp S1.State,$SelectFrameúje @F
 add ParseSi,$StrideS
 cmp S1.State,$SelectFrameúje @F
 add ParseSi,$StrideS
 cmp S1.State,$SelectFrameúje @F
 Error49Bp
@@:OpAl $pJump; WHEN end requires a branch to end of SELECT.
 cmp Z.Synch,ZeroBpújne @F
 mov ax,S1.SelectSiteúmov Wptr gs:[CursorBx],axúmov S1.SelectSite,CursorBx
; THEN at start of this WHEN is a jump to here.
@@:mov CursorBx,S1.JumpSiteújmp FillJump

Action26:; PROCEDURE.  Make protection against fall-thru.
 mov OpAppendCl,$n17p1úOpRet $pRaise

Raise28:mov ah,28úcmp Bptr Z.KWFound,low $LEAVEúje @Fúinc axú@@:jmp Raise

Action28:; ITERATE/LEAVE without VAR_SYMBOLúmov al,1
; Scan the stack, looking for DO repetitive.
@@:add ParseSi,$StrideSúcmp S.State,ZeroBpúje Raise28
 Qry S.Parser,DoRep,DoCVújz @B
 jmp A29Pcode
Action29:; VAR_SYMBOL after LEAVE or ITERATEúmov al,1
; Scan the stack, looking for DO info.
@@:add ParseSi,$StrideSúcmp S.State,ZeroBpúje Raise28
 Qry S.Parser,DoCV,DoRepújz @BúQry S.Parser,DoRepújnz A29UnDo
 call CompNamesúje A29Pcode
A29UnDo:OpAl $pUnDoúmov al,3újmp @B

; Different types of DO use a different iterate Pcode, for speed.
A29Pcode:cmp Bptr Z.KWFound,low $LEAVEújne @FúOpRet $pLeaveú@@:
FromDoEnd:mov al,$pIterateúQry S.Parser,Foreverújnz @F
 mov al,$pIterCVúQry S.Parser,DoCVújnz @Fúmov al,$pIterRep
@@:jmp PcodeOp

ControlVar:; Here for DO j=1 TO 99 type of assign.
; We need something in the Pcode because numberness has to be checked
; before TO BY FOR are done and actual assignment done after.
 OpAl $pNumber
; The generation for the assignment is held over the BY etc.
; Carry some info over for the END (and LEAVE/ITERATE)
; Note that the S2.State won't be a DO one, it is just a carrier.
 On S2.Parser,DoCV,DoDataHostúOn Z.Clause,CVar
; The LHS has been soft stacked for hold over the RHS expression.
; We need to remember it for the whole DO group for test of match at END.
; So for DO J=1 we remember the resolved J in the hard stack.
; For DO A.K=1 we look up A.K as the constant "A.K".  Could be a bit
; wasteful since execution may never need that constant, but convenient.
 cmp V.Dtype,$NullStringújne @Fúmov ax,V.HeldOver
CVret:mov S2.WhatCV,axúret; Leave assignment to Action33.

@@:; We will be able to detect later that WhatCV is dotted by its constantness.
; Here we look it up as a constant. Action33 will do it as tailed.
; Copy symbol saved on stack back to Z.Symbols where Lookup expects it.
 push ParseSiúpush StackDiúcall ToDsSiCx
; Check space early because compaction in loop intolerable.
 mov di,He.Availúadd di,cxúcall SymbolsSafe
 pop StackDiúcall ToDsSiCxúpush StackDi
 mov di,He.Availúrep movsbúpop StackDiúpop ParseSi
 On Z.Middles,TakenConstantúcall Lookupúmov ax,ArrayBxújmp CVret

Action30:; After do-end, without name.úret

Action31:; After do-end, with name.
; Since this name is the latest token there is more than one way to reach it.
 move Z.ClauseLine,S.ClauseWas
 mov ax,MkMajMin(10,2); Msg for mismatch.
 Qry S.Parser,DoCVújnz HasDoCVúinc ax
@@:jmp Raise
HasDoCV:call CompNamesújne @Búret

; Set zero flag iff CV name matches latest token.
CompNames:mov ArrayBx,Z.Resolvedúcmp ArrayBx,S.WhatCVúret

Action32:; Complete the do group with a loop address if repetitive.
 Qry S2.Parser,DoDataHostújnz @FúAdd ParseSi,$StrideSú@@:
 Qry S2.Parser,DoCV,DoRepújz @F
; Adjustment of Parser stack so we can share code.
 add ParseSi,$StrideS*2úcall FromDoEnd
 mov CursorBx,S.JumpSiteúcall FillJump
@@:ret

; FOREVER is like $pRep with no argument. (So why $pRepEver?)
Action36:
Action33:; dorep done. Change middle keyword list.
; Make S1 the one filled before.
 cmp S.State,$DoFrameúje @Fúadd ParseSi,$StrideSúcmp S.State,$DoFrameúje @F
 add ParseSi,$StrideSúcmp S.State,$DoFrameúje @FúError49Bpú@@:
@@:mov Z.KWMiddle,$CondKeysúOn Z.Clause,Repit
; Parser stack is not consistent so not easy to test for DoCV. Hence flag.
 Qry Z.Clause,CVarújz NoCV
; The code generation is not entirely like assignment. The control variable
; needs to be recorded at run time. A different opcode reflects this.
; Also, if there is WHILE or UNTIL, the opcode will not be one that marks
; end-of-clause.
; We also put an argument on this operation to set up the LEAVE target.
; There are two opcodes, the usual $pControlVar and the $pDotControlVar
; which is for either the CV is a stem or is tailed.
; Share code with ordinary assign by making an assignment, then changing the
; opcode.
 call UpStack; mock RHS
 On Z.Cancel,AssignDO
 call MakeAssign
 Off Z.Cancel,AssignDO
; A further complication occurs when the control variable is tailed,
; 'thunking' is needed.
; I've done that by having MakeAssign set dx to the value needed.
 test cx,cxújnz Action33Tailed
 mov al,$pControlVar
 xchg al,Bptr gs:[CursorBx-1]
 cmp al,$pAssignúje @F
; Add the space for jump address after the reference to the control variable.
Action33j:mov Bptr gs:[CursorBx-1],$pDotControlVar
@@:call Pcode2; To make space.
Action33c:mov S1.JumpSite,CursorBxúret

Action33Tailed:call Action33j
; Use a subcode to show where loop should branch back to reload tail(s).
 mov al,$mRepTailúcall Pcode1úxax dxújmp Pcode2

NoCV:cmp StackDi,Z.Base0újne @FúOn S1.Parser,Forever,DoDataHost
@@:On S1.Parser,DoRep,DoDataHostúmov al,$pRepEver
 Qry S1.Parser,Foreverújnz @Fúmov al,$pRepú@@:call PcodeOpújmp Action33c

Action34:; WHILE expúOpRet $pWhile

Action35:; UNTIL expú OpAl $pUntil
; Target jump around UNTIL to here.
 mov CursorBx,Z.UntilPlaceújmp FillJump

Action37:; Keywords WHILE/UNTIL
; If there has been no repetition we need to invent one.
 Qry Z.Clause,Repitújnz @Fúcall Action33ú@@:
 cmp Z.KWFound,$UNTILújne @F; Make jump around the until code.
 OpAl $pJumpúmov Z.UntilPlace,CursorBx
@@:ret

; Z.KWFound doesn't work out for Middle keywords.
Action381:OpRet $pTo
Action382:OpRet $pBy
Action383:OpRet $pFor

Action41:; Invent for missing parameter.
 call UpStack
 mov V.Dtype,$Omittedúmov ax,$?Omittedújmp Pcode2
Action43:; Function completes. Place invoker name in pcode.
 call ActInvokeCl
; Whether Bif or not, there will be function result on this route.
 pushfúcall UpStack
; Unknown compile time values are set to be something that will fail bif tests.
 mov V.Dtype,$Variable
 popfújc @F; Carry means it is bif, Pcode was made.
; Pcode for non-bif made here.
; Parameter count before the target makes it easier to share with CALL.
 move Z.Resolved,S1.Callerúmov al,$pInvokeúcall PcodeOp
@@:EvRet $TraceFunction

Action44:sub si,$StrideS; After call without parameters.
Action45:call ActInvokeClújc BifCall
 move Z.Resolved,S1.CallerúOpRet $pCall

; Call, if Bif, needs to put result in special variable .RESULT
; We could have flagged $pResult as not DownOne since this is only usage.
BifCall:call UpStackúOpRet $pResult

ActInvokeCl:; Set Z.Stack back to pre-invoke
; Set carry iff this is a bif.
; If not bif, return parameter count in cl.
; If bif syntax error presence/number of parameters wrong, make syntax Pcode.
; If bif non-error put the Pcode to call it as a function.

; Setup StackDx to StackDi as lo:hi retained range. Equal means none.
 mov StackDx,S1.Parmsúmov Z.StackLo,StackDxúpush StackDx
; Pop of StackDx value to Z.Stack will effect removal of the args.
; Trailing commas don't count.
@@:cmp StackDi,StackDxúje @Fúcmp V.Dtype,$Omittedújne @F
 Downúcall BackOff2újmp @B
@@:call SetStack; Reflect retained args.
; Set cx to number of parms.
 mov ParmsCx,StackDiúsub ParmsCx,StackDxúshr ParmsCx,$ShiftV
 cmp ParmsCx,$MaxParmsúja ArgsLim
; Test apparent location to determine bifness.
 mov ArrayBx,S1.Callerúmov fs,Z.ProgScopeúmov bx,fs:Vbx.LabelValue
 sub bx,$BifBaseújnb @Fúpop Z.Stackúclcúretú@@:
 call PcodeBifúpop Z.Stackústcúret

ArgsLim:mov dl,$DescArgsújmp Raise5p1

Action51:;ARG verb is same as PARSE UPPER ARG
Action52:;PULL verb is same as PARSE UPPER PULL
 On Z.Clause,WasUpper
Action50:;After the subject of PARSE
 On Z.Middles,TargetSymbol,DotOK; For target names
 On Z.Clause,InParse,WasParse
 mov ax,Z.KWFoundúadd al,$sWith-$WITH
 mov bx,S2Púxlat cs:Bptr[bx]; Pick up marker.
 cmp al,$nWithújbe @Fúcall UpStack
 mov V.Dtype,$Variable
@@:
 mov OpAppendCl,al
 EvAh $TraceParse
 OpAl $pParse
 mov ax,Z.Stackúmov Z.OnSoft,ax
 Qry Z.Clause,WasUpperújnz @Fúret
@@:mov al,$mUpperújmp Pcode1

comment~ The aim is to construct a complete PARSE instruction out of markers
and operand references, without Pcodes after $pParse. Where that would result
in something too complex for Parse$$ to interpret (eg a compound reference)
then some Pcode is introduced, bracketed by $mParseEscape and $pResumeParse.
(or ended with $pAssignDotsP)
To generate the bracketing, flag InParse is set here when the parse is normal.
The hard cases elsewhere see the flag, make $mParseEscape ahead of their stuff,
and turn off the flag. Here we see the flag off and generate $pResumeParse.
~

Action53:;Trigger.
 bts Z.Clause,InParseújc @F
; It was turned off if $mParseEscape was made.
 OpAl $pResumeParse
@@:mov al,$mPosPlusúbtr Z.Clause,PosPlusújc TriggerValue
 mov al,$mPosMinusúbtr Z.Clause,PosMinus
; Stop on neg positional as debug trick.
 jnc @Fúint 3újmp TriggerValueú@@:
 mov al,$mPatternúbtr Z.Clause,PosEqújc Positional
 cmp Z.TokNow,$NUMBERújne TriggerValue
Positional:mov al,$mPosEq
TriggerValue:; Unless it is pattern we would prefer argument as a number.
 cmp al,$mPatternúje @F
 mov ah,'N'úcall ConstValue
@@:sub Z.Stack,$StrideV
PostTrigger:call Pcode1
; Any targets that were before this trigger can now be dealt with.
; they range from above Z.OnSoft to Z.Stack.
 mov StackDi,Z.OnSoftúpush StackDiújmp TestTarsUp

TarsLoop:; If it was resolved, it is sufficient just to put it as a target.
; NYI StemTarget?
 push StackDiúcmp V.Dtype,$NullStringújne TgtTailed
 mov ax,V.HeldOverúadd ax,$CaseTarget
 push StackDiúcall Pcode2úpop StackDiújmp @F
; Tail calculation is introduced by $mParseEscape.
TgtTailed:mov al,$mParseEscapeúcall Pcode1úpop StackDiúpush StackDi
; Compound name hasn't been looked up yet.
 mov dx,Z.Cursorúmov TokNumAh,$VAR_SYMBOLúOn Z.Clause,Tailed
 call Lookup
; Now have tails put in Pcode set, PartCountCl set, and Z.Resolved target.
; Doesn't look like we can use $pAssignDots because extra on stack.
 OpAl $pAssignDotsP
@@:pop StackDi
TestTarsUp:Upúcmp StackDi,Z.Stackújbe TarsLoop
; Stack resets to Z.OnSoft
 pop Z.StackúOn Z.Middles,TargetSymbol,DotOKúret

Action55:; +-= ; Sets PosPlus, PosMinus or PosEq flag.
mov ax,Z.TokNowúsub ax,$Minusúbts Z.Clause,axúret

Action56:; UPPERú On Z.Clause,WasUpperúret

Action57:; Trigger for last set in the template.
 mov al,$mPosRestújmp PostTrigger

Action58:; Comma in template
 On Z.Middles,TargetSymbol,DotOK; For target names
 mov al,$mTemplateCommaújmp Pcode1

ConditionNum:mov cx,Z.Condition
; Set OpAppendCl for subsequent PcodeOp.
; Fiddle to correct order for testing.
 cmp cl,$NOTREADYújne @Fúdec cxú@@:cmp cl,$ERRORújne @Fúsub cl,4ú@@:
 add cl,1-$LOSTDIGITS
; Now Syntax,LostDigits,NoValue,NotReady,Error,Failure,Halt
 ret

Action60:; callon specúmov al,$pCallOn
Action60x:Qry Z.Clause,OffFlagújz CallOn
 call ConditionNumúOpRet $pSignalOff

CallOn:cmp Z.KWFound,$NAMEúje @F
; The condition looked up as a keyword is still around raw to be a constant.
 On Z.Middles,LookLabel,TakenConstantúmov TokNumAh,$VAR_SYMBOLúcall Lookup
@@:call ConditionNumújmp PcodeOp

Action61:mov ax,Z.KWFoundúmov Z.Condition,axúOn Z.Clause,Conditionúret

Action62:On Z.Clause,OffFlagúret

SignalVerb:
 mov al,$pSignalOnúQry Z.Clause,Conditionújnz Action60x; Join CALL ON
; Lookup has distinquished SIGNAL ABC and SIGNAL VALUE ABC.(Labels not stacked)
 cmp StackDi,Z.Base0úje @F
 OpRet $pSignalV

; SIGNAL ABC, argument not on stack.
; We could save code by converting this to be like VALUE "ConstSymbol" but
; using another opcode makes execution much faster.
@@:OpRet $pSignal

; This is setup to use just one opcode $pCommandEnv with value following for
; STEM/STREAM/NORMAL + in/out/err + append.
Action70:; ADDRESS instruction completes.
 move Z.Stack,Z.Base0
 OpRet $pAddress

Action71:; INPUT resourcesúmov OpAppendCl,offset EnvBlock.EnvResourceI
A7n:
; Add flags to those in OpAppendCl.
 mov ax,Z.KWFoundúadd al,low($sStem-$STEM)
 mov bx,S2Púxlat cs:Bptr[bx]úor OpAppendCl,al
 OpRet $pCommandEnv

Action72:; OUTPUT resourcesúmov OpAppendCl,offset EnvBlock.EnvResourceO
@@:btr Z.Clause,Appendújnc A7núor OpAppendCl,080hújmp A7n

Action73:; ERROR resourcesúmov OpAppendCl,offset EnvBlock.EnvResourceEújmp @B

Action74:; APPENDúOn Z.Clause,Appendúret

Action75:; Environment name. Can be VALUEd so needs runtime lookup.
 OpRet $pEnvName

Action80:; numerics
; We could have set up the BNF so as to have separate actions but that
; would have meant duplicated code here.
; We could do the defaults dynamically without noticeable loss of speed
; but we choose compile time.
; First construct subcode and done if there is an operand.
 mov ax,Z.KWFoundúadd al,$sDigits-$DIGITS
; Simplest to work out default even when it might not be needed.
; Provide default operand. Tied in with order of groups and $Reserved.
; $?Nine: (9 0 '' 'E' 'S') on Reserved
; DIGITS,FUZZ, ,NOP,FORM on Scodes.
; Adjust to stride for constants (the defaults).
 push axúmov ah,$StrideVúmul ah
; If bigger than $sForm it will be Engineering/Scientific.
; Else DIGITS...FORM range fits 9...'S' range.
 cmp ax,$StrideV*$sFormújna @F
; Subcode becomes FORM for ENGINEERING/SCIENTIFIC keywords.
 pop bxúmov bl,$sFormúpush bx
; Adjust for values 'E' and 'S'.
; Cancel the $DIGITS factor and substitute $ENGINEERING.
; Cancel the $?Nine factor (coming later) and substitute $?E.
; The brackets below help the assembler!
 add ax,($?E)-($?Nine)-($ENGINEERING-$DIGITS)*$StrideV
@@:cmp StackDi,Z.Base0újne HaveValue
 add ax,$?Nine-$StrideV*$sDigitsúcall Pcode2úadd Z.Stack,$StrideV
HaveValue:pop ax
 mov bx,S2Púxlat cs:Bptr[bx]úmov OpAppendCl,al
 OpRet $pNumeric

Action90:; Trace event for end-of-expression.
 EvRet $TraceExpr

Action91:; Can use NOP as an end-of-clause marker, if one is needed.
 Qry Z.Middles,EndClauseújz @F
 OpRet $pNop
; Trace event for end-of-clause
@@:Qry Z.Gen,DualGenújz NotDualGen
; Compiling for dual mode.
 EvAh $TraceEndClause
if Debug
; Make dump show newest code.
 call Create4Dump
 call Dumper
endif
; One clause at a time is compiled in dual mode.
 Qry Z.Gen,Dualújnz Terminate
 ret

; If the Z.Synch was for tracing, the following clause needs
; dual code generated.
NotDualGen:btr Z.Gen,DualPendingújnc @FúOn Z.Gen,DualGenú@@:ret

;------------------------------------------------------------------------------
; Terminate the code made when Cycle reaches end of source.
; Used from Syntax.
;------------------------------------------------------------------------------
Terminate:z Z.Scanp
 move Z.Stack,Z.Base0,StackDi
 cmp Z.Synch,ZeroBpújne NoTrailer
; ?? Probably need a flag for TraceBack anyway so Exit & InterpEnd could share?
 mov al,$pExitúbtr Z.Program,LabelsBadújnc NotInterpúmov al,$pInterpEnd
NotInterp:call PcodeOp
NoTrailer:
; Does this every time because code segment could have extended.
; Note results of compilation.
; Is there a problem that we should update F.Code as soon as Z.Code changes,
; avoiding situation when compaction in between would save both versions??
 lds bx,Z.SysFile
 On F.Flags,BeenCompiled
 move F.Symbols,Z.Symbols
 move F.Code,Z.Code
 move F.Consts,Z.Consts
 move F.Vars,Z.Vars
 move F.ProgScope,Z.ProgScope
 mov sp,Z.ParseResetSp
 ret

 end
