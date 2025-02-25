; Copyright Formcroft Ltd 1997-1999
 .model small�.486�.code
 include always.inc; Assembler shorthands like 'Bptr' for 'byte ptr'.
 include declares.inc; Symbolic constants, macros, records, structures.
;------------------------------------------------------------------------------
; This code is in the mode ds=cs because it works with read-only tables
; that are assembled with the code. Control leaves this module to determine
; the next thing in the source (NextToken) and for Actions (such as adding
; to the pseudo-code) to be taken. On return from these, ds=cs is
; re-established.
; ES is Z.Symbols, only needed in QueryKey.
; FS and GS are not used in this mode.
; On call-out from here (Action0, Actioning, NextToken) the module saves
; what it needs and sets StackDi from Z.Stack.
;------------------------------------------------------------------------------
; Some keyword lookups are lexical, as when THEN or WITH ends an expression.
; Keyword lookups for verbs, options... are a syntax requirement.
; We keep the keyword table here to satisfy references from the syntax tables.
 PUBLIC Keys; Table of keywords.  (Used for message creation)
 PUBLIC $WithKey; Part of table needed by lexical work.
 PUBLIC $ThenKey; Part of table needed by lexical work.
 PUBLIC $CondKeys; Part of table needed by lexical work.
 PUBLIC $DoKeys; Part of table needed by lexical work.
 PUBLIC QueryKey; To look up keywords.
 EXTERN NextToken:near; To identify next token in the source.
; The decorated BNF says what actions are to be taken when certain syntax
; constructions are encountered.
 EXTERN Action0:near;   the action for an operand. (Not numbered in the BNF)
 EXTERN Action1:near;   assignment at =
 EXTERN Action2:near;   end of keyword instruction
 EXTERN Action3:near;   end of command
 EXTERN Action6:near;   PARSE VALUE
 EXTERN Action10:near;   a binary op
 EXTERN Action11:near;   a prefix
 EXTERN Action12:near;   comparisons
 EXTERN Action18:near;   a function name or after CALL
 EXTERN Action20:near;   at THEN
 EXTERN Action21:near;   at ELSE
 EXTERN Action22:near;   end of if
 EXTERN Action23:near;   end of select
 EXTERN Action24:near;   end of otherwise
 EXTERN Action25:near;   end of when
 EXTERN Action26:near;   PROCEDURE
 EXTERN Action28:near;   ITERATE/LEAVE, no VAR
 EXTERN Action29:near;   ITERATE/LEAVE with VAR
 EXTERN Action30:near;   do-end without var after.
 EXTERN Action31:near;   var after do-end
 EXTERN Action32:near;   end of do.
 EXTERN Action33:near;   dorep done
 EXTERN Action34:near;   While
 EXTERN Action35:near;   Until
 EXTERN Action36:near;   FOREVER
 EXTERN Action37:near;   WHILE/UNTIL
 EXTERN Action381:near;   TO
 EXTERN Action382:near;   BY
 EXTERN Action383:near;   FOR
 EXTERN Action41:near;   missing expressions in a list
 EXTERN Action43:near;   a function completes
 EXTERN Action44:near;   CALL Ftn without expression list
 EXTERN Action45:near;   CALL Ftn with expression list
 EXTERN Action50:near;   after the subject of PARSE
 EXTERN Action51:near;   ARG verb
 EXTERN Action52:near;   PULL verb
 EXTERN Action53:near;   Trigger
 EXTERN Action55:near;   +-=
 EXTERN Action56:near;   UPPER
 EXTERN Action57:near;   after template
 EXTERN Action58:near;   comma in template
 EXTERN Action60:near;   callon spec.
 EXTERN Action61:near;   after condition
 EXTERN Action62:near;   OFF
 EXTERN Action70:near;   ADDRESS instruction
 EXTERN Action71:near;   INPUT resources
 EXTERN Action72:near;   OUTPUT resources
 EXTERN Action73:near;   ERROR resources
 EXTERN Action74:near;   APPEND
 EXTERN Action75:near;   Environment name
 EXTERN Action80:near;   after numeric.
 EXTERN Action90:near;   Expression ends
 EXTERN Action91:near;   Clause ends
; Constants for interpreting syntax tables. Ensure match with table generator.
$ReferR   equ 0; Says reduction test is two word.
$DirectR  equ 1; Says reduction goes without further test. (One word)
$SubsetR  equ 2; Says reduction is like some other state's.(One word)
$ArithR   equ 3; In second word, says two word is to target by arithmetic.
$EqTest   equ 0; In second word, says if Reference = x then reduce to y.
$GeTest   equ 1; In second word, says if Reference >= x then reduce to y.
;------------------------------------------------------------------------------
; Here is the "compile time" loop, Cycle.
;------------------------------------------------------------------------------
comment~ This is more complex because there many flags and small numbers in the
compact tables (generated offline by utility programs) which define the syntax.
For an understanding in this context it is only necessary to note that the
cycle makes calls to NextToken (when consuming more source) and to Action1,
Action2, ....  when appropriate things are recognized. Action0 deals with
operands.  It also calls QueryKey to detect keywords and it jumps to the label
Terminate. It will jump to Raise if a SYNTAX error is detected.

The method is due to AOE.  The first check is whether the token is one due to be
considered in this state.  Zero in the acceptance field of token data says 'yes
it is', otherwise the acceptance field is used in conjunction with data from the
state for a yes/no.  If accepted, another array indicates the new state to shift
to.  If not accepted the state is changed ('reduced') or there is an error.  The
parser operates on ParseDx - this comes form a TokData table indexed by TokNum.
For that table, TokData is made by a utility program.

Cycle expects to progress StateBx in the context of what is on the hard stack.
~
; The syntax utility makes syn.inc and a groups list. The latter is put in
; prefered order by hand (see groups.inc) then processed for synequ.inc and
; TokData
if Solid
TokData word Overlay
 include tokdata.inc
 include attribs.inc; Table of attributes of all 256 characters.
; Syntax table. Not first since addressed with -4 offset. Not edited.
                                                          include syn.inc
; Avoid first offset in keyword table being zero. Not edited.
                                                          include keys.inc
endif
comment~ The parser is used in several ways through this entry point.

a) Processing the whole source file, making Pcode. This is the first use,
and the only one that processes labels. It can take two passes.

b) Generating code for an interpret. This may be an INTERPRET clause subject,
or an interpret for interactive debug or for something like the VALUE bif.
The subject comes in Z.Serial and the Pcode generated is appended to the
previously made code, transiently.

c) Synchronizing the source (line number, source file offset, etc) with the
current execution (represented by an offset in Pcode). This is done by
"compiling" as in (a) above but not storing the generated code, just checking
when the offset reaches the offset of execution.  In particular this is done
when a runtime error occurs, so as to find out what linenumber, builtin function
name, etc. is relevant.

d) Generating code for clause-by-clause execution. This variant starts with
an action like (c) and then continues compiling with generation of code switched
on.  The code generated is appended on the code segment and the invocation ends
when one clause has been compiled.

The Pcode made by (a) or (b) and matched by (c) does not have code generated to
indicate where there may be TRACE output.  The code generated by (d) does have
the $pTraceEvent codes.

~

Compiling:
 mov Z.ParseResetSp,sp; Allows tidying of the parser stack when syntax errors.
; Z.Scanp indicates the subject source.
; Z.Synch indicates the synch point. Zero if making code.
; Z.Cursor indicates offset to start on code.
 move Z.Base0,Z.Stack
 mov gs,Z.Code
; Initialize compiler flags.
 z Dptr Z.Middles; does z Z.Clause�z Dptr Z.KWMiddle; does z Z.KWFound
 z Z.LastTarget
; In the Interpret case the source is already in Z.Serial, at Z.Scanp.
 cmp Z.Scanp,ZeroBp�jne @F
; All-of-file case.
 mov Z.Lines,1�z Z.TraceEnds�z Z.TraceEndsColumn�z Z.TraceAlign�z Z.Relative
; Source will be read using the Serial buffer.
 mov ScanSi,Zshape.Serial�mov Z.Scanp,ScanSi�mov Z.Insert.TokPos,ScanSi
 mov al,$SerialSource�call Serialize
@@:
; Prepare to read tables, record symbols.
 mv ds,cs�mov SymbolsEs,Z.Symbols
 z ParseDx�push ZeroBp; Marker on parse stack
 On Z.Program,FirstBetween�Off Z.Program,EndSource�mov StateBx,State0
; After here to Compiled or Raise. (If latter, msg maybe)
; The parser method is explained elsehwere. (Aoe method)
; The group number comes from the listing output of the table generator.
Cycle:lea StateSi,StateOrig[StateBx]�mov StateDi,StateBx�mov ax,[StateSi]
; As long as no chance of a shift, keep recognising. (Reducing)
 Assert HasShift eq 15�add ax,ax; S^...�jc HasShiftL
; Do the reduction that is at StateSi, maybe partway through state data.
; Test for associated action.
Reduction:Qry Wptr[StateSi],HasAction�jz NoAction
 mov ax,sp�push ParseDx�push StateSi
 mov ParseSi,ax
Actioning:; Just a debugging label.
comment~
 The registers are available for use in these actions.  SI is initially the
 ParseSi and DS initially equal to CS but they can be changed. DI initially
 Z.Stack, can be reused. (Action0 a little different) See EXTERN list of
 actions, realised by pcode.as.

The hard part with actions is knowing where to find things on the parser stack
when the call for the action is made.  The processing of the BNF produces a
listing of the 'original' states, and by looking at the recognitions of ABC.NN
left-hand-sides we know when ActionNN is invoked.  The program which lessens the
number of states by noting which are effectively equivalent produces some output
about what states will be pruned immediately after the action.  It also
correlates the numbering of 'original' states to the fewer 'unique' states.
(see utility program \a\s\X2S.EXE to match run-time to the listings.)

Knowing the states, and the data like 'latest TokNum' which is stacked with the
states, it is usually possible to do what is needed in the action, even though
the stack was designed for parsing rather than code generation.  The non-parser
stack is used for recording the DO nesting.

SI points to the stack as it was before the call.  So the order of things
addressed positively from it is first the elements that will be pruned, then the
Reference element, then older things in the stack.
AX, BX, CX, DX, DI are free. DS is in use as CS.  SI can be altered.
ES in use for Z.Symbols.

Sadly, the gap between the interesting things on the stack is sometimes
dependent on stack contents.

~
 mov bx,Wptr(StateOrig-2)[StateDi]�mov StackDi,Z.Stack
 call bx�pop StateSi�pop ParseDx�mv ds,cs
NoAction:; Prune stack.
 mov ax,[StateSi]�shr ax,PruneCt�and al,3�mov ah,$StrideS�mul ah�add sp,ax
; Here for each test, deciding where to reduce to, with si as cursor on tests.
; Setup StateBx as the state given in this word.
CycleTest:mov StateBx,[StateSi]�mov RtypeAh,bh
 and StateBx,mask Rstate�add StateBx,StateBx
 and RtypeAh,high mask Rtype�jnz NotRefer
; Rtype $ReferR says this is not a one-word reduction. The first word has
; to be checked against the stack to see if the second word applies.
 pop ax�push ax; Reference state�inc StateSi�inc StateSi
 test Bptr[StateSi+1],high mask Rtype; Rtype in second word.�jz EqTest
; GeTest. Reduce to second word only if reference >= to criteria.
 cmp ax,StateBx�jl NextTest
ReferMatch:
 mov StateBx,[StateSi]�and StateBx,mask Rstate�add StateBx,StateBx�jmp Cycle
; EqTest. Reduce to second word only if reference == to criteria.
EqTest:cmp ax,StateBx�je ReferMatch
NextTest:inc StateSi�inc StateSi�jmp CycleTest
; The rest of the reductions are one word only types.
NotRefer:jpe Arith�cmp RtypeAh,high ($SubsetR shl Rtype)
 jnz Cycle; $DirectR just contains the new state.
; $SubsetR is a space saver. The reduction code is shared with another state.
 lea StateSi,StateOrig[StateBx]�jz CycleTest
Arith:; Add to get new state, with wrap-around.
 pop ax�push ax; Reference state�add StateBx,ax
 cmp StateBx,$Needed�jl Cycle�sub StateBx,$Needed�jmp Cycle
; Deal here with word that describes shift/error part of AOE algorithm.
HasShiftL:; Leftmost bit of ax now indicates error alone.
 Assert ErrorAlone eq 14�add ax,ax; 1E^...�jnc @F
IssueError:; Issue error message.
; Ax has been moved left 2 bits in detecting this case.  Now have 8 & 6 bits
; for the Major and Minor error numbers.
; StateSi used to pass position of keywords message insert.
 mov Z.Insert.KeysList,StateSi�shr al,2�jmp Raise
; We need to know where abuttal is an implied operator.
@@:Assert CatFlag eq 13�Off Z.Middles,AbutOK�add ax,ax; 1EC^...�jnc @F
 On Z.Middles,AbutOK
; Cannot do more until we know what the next token is.
@@:TestReg ParseDx�jnz ParseKl�push ax
; Record for stacking later.
 mov ax,Z.TokNow�mov Z.TokWas,ax
 mov bx,Z.Insert.TokPos�dec bx�js @F
 mov edx,ss:Dptr[bx]�mov dl,Bptr Z.Insert.TokLen
 mov Z.InsOperator,edx
@@:push si�push di�mov StackDi,Z.Stack�call NextToken�pop di�pop si�mv ds,cs
 shr ax,8�mov Z.TokNow,ax
; Use TokNow as index to TokData
 shr ax,GrpNdx�add ax,ax�xax bx�mov ParseDx,TokData[bx]
; ParseDx may change later if token is found to be an acceptable keyword.
 mov Z.TokData,ParseDx�pop ax
ParseKl:Assert HasKeys eq 12�add ax,ax; 1ECK^...�jnc @F
; State allows keywords.
 inc StateSi�inc StateSi�cmp Z.TokNow,$VAR_SYMBOL�jne @F
 Qry Z.Middles,ModEquals�jnz @F�mov KeyListCx,[StateSi]
 call QueryKey; Which will set carry (and set bx) if acceptable keyword.
 jnc @F
; Set token data to the keyword values.
 mov Z.TokNow,bx; Relevant when token is END
 shr bx,GrpNdx�add bx,bx�mov ParseDx,TokData[bx]
 mov Z.TokData,ParseDx�shl ax,2; Reference & Direct bits not tested.
 jmp Accept
; Is this token one dealt with in this State?
; Bit after Reference bit indicates 'Direct' test.
@@:shl ax,2; 10CKRD^Indexb...�jnc BitAccept
; We need to line up Indexb with main group number, without disturbing ax.
; Keywords don't come this way, except those detected by middle, so we
; can be sure TokNow is low range.
$31 equ 31; Used when no non-keyword is acceptable.
; Isolate what the acceptable token needs to be.
 mov TokNowCh,Bptr Z.TokNow�shl TokNowCh,1
; TokNow doubled means 3 bits unwanted at right.
 xor TokNowCh,ah�and ch,0F8h; Discount ID (doubled) within group value.
 jz Accept
; Must now reduce or is in error. (If both use error; reduction by mock shift)
NonAccept:inc StateSi�inc StateSi
 test Bptr[StateSi+1],high mask HasShift�jz JmpReduction
 mov ax,[StateSi]�shl ax,2�jmp IssueError
; Take relevant five bit index from state data.
; 10CKR0^Indexb...
BitAccept:mov cx,ax�shr cx,11; Indexb
; Take relevant bit index from token data.
 mov bx,ParseDx�and bh,high mask NdxbT�jz Accept
 shr bx,(width Aim)-2; AcceptBits element is 4 bytes.
; One would hope the bt would wrap the ecx value around at 32 but it doesn't.
 movzx ecx,cx�bt AcceptBits[bx-4],ecx�jnc NonAccept
; We are going to do a shift. (Or explicit reduce). Deduce which state to go to.
; Take a field from the TokData
Accept:mov bx,ParseDx�and bh,high mask Aim
; If this is a state number, it is the one to go to.
 add StateBx,bx�cmp StateBx,$Needed�jl HaveTarget
 sub StateBx,$Needed; It is an array index, now doubled.
; Take relevant bit Index from state data.
 shr ax,6; Cancels the add ax,ax shifts we made for flag testing.
 and al,mask Index�mov ah,2*TokensDim�mul ah; Multiply by suitable stride
 add bx,ax; Add in token index.
 mov StateBx,StateOrig[bx]; Pick up target.
; There is a special case where the target is 0.  This means that it is
; not really a shift, but a reduce of the sort that happens on particular
; tokens rather than by reason of non-shift.
; This mechanism is also used to ensure keyword END is looked for before
; a shift on $VAR_SYMBOL.
HaveTarget:TestReg StateBx�jnz RealShift
; If Eos has proved acceptable, maybe we are done.
 Assert $Eos eq 0
 cmp Z.TokNum,ZeroBp�jnz @F�On Z.Program,EndSource
; Advance over current word, and error number if necessary.
@@:inc StateSi�inc StateSi
 test Bptr[StateSi+1],high mask HasShift�jz JmpReduction
 inc StateSi�inc StateSi
JmpReduction:jmp Reduction
; Moving from StateDi to StateBx
; If this token still says $VAR_SYMBOL, it can be looked up. (Was
; delayed in case it was a keyword.)
; The parser doesn't care what it is shifting, but we choose to detect
; things for Lookup now.
RealShift:mov TokNumAh,Bptr Z.TokNow
; End-of-source marker is the last thing we shift.
 Qry Z.Program,EndSource�jnz Terminate
; Some things will not be operands.
 cmp TokNumAh,$STRING�jb NotOperand�cmp TokNumAh,$VAR_SYMBOL�ja NotOperand
 push StateDi�push StateBx�mov StackDi,Z.Stack
 call Action0�pop StateBx�pop StateDi�mv ds,cs
NotOperand:z ParseDx; Indicates ready for another token.
; Reference state goes on AOE stack which is the normal stack.
 Qry Wptr StateOrig[StateDi],Reference�jz Cycle
 call StackSafe
; The parser just needs StateDi pushed; other things useful at actions.
; See Sshape. These pushes are not popped - sp is altered at prune.
; It is annoying, but some messages have the <operator> as insert and since
; the distinction between (say) "<>" and "><" and "\=" is otherwise lost,
; we must stack it away now.
 Assert $StrideS eq 4+4+2+2+2+2�pushd ebp�pushd Z.InsOperator
 push Z.TokWas�push Z.ClauseLine�push bp�push StateDi�jmp Cycle
;------------------------------------------------------------------------------
; QueryKey:
;------------------------------------------------------------------------------
; cx has been set to address of linear list of keywords, see keys.inc, KeyRec
; May change cx. Will change bx
; Returns carry flag. When carry set, TokNum in bx.
; ES will be Z.Symbols.
QueryRet:clc�ret
QueryKey:JcxzQ QueryRet; Saying not keyword.
 push di�push ax�push dx�push si�mv ds,cs
; ds:si over the table, SymbolsEs:di on the symbol.
; Scan for word of given length.
 mov bx,cx�z cx�mov ax,He.Avail�mov di,ax�mov dl,Bptr SymbolsEs:[di]
 inc ax�dec bx
; First byte is data. Second byte is data including keyword length.
CycleKey:inc bx�add bx,cx�inc bx
 mov cl,[bx]�and cl,mask KeyLen�cmp cl,dl�je Match
Mismatch:test Bptr [bx],mask EndList�jz CycleKey�clc
QKexit:pop si�pop dx�pop ax�pop di�ret
Match:; Length matches, setup and compare letters.
 mov si,bx�inc si�mov di,ax�repe cmpsb�mov cl,dl�jnz Mismatch
 mov bx,[bx-1]; Low bx now has $name value for this keyword,
; relocated by KeysBase so as to fit 0-63 range.
 mov cx,bx�z bh�add bx,KeysBase
; Clumsy treatment of TRACE VALUE....
 cmp bx,$VALUE�je @F�mov Z.KWFound,bx�@@:
; QueryKey side-affects
; Here is better than in Actions - Actions happen after next token seen.
 On Z.Clause,NotAssign�Off Z.Middles,TakenConstant,LookLabel
 shr cx,13; Isolate KeyFlags�jz DoneSide
 loop @F
;(1) IF WHEN setup for THEN
 mov Z.KWMiddle,$ThenKey�jmp DoneSide
@@:loop @F
;(2) DO sets up for WHILE and UNTIL etc.
 inc Z.TraceOnly
 Off Z.Clause,NotAssign�mov Z.KWMiddle,$DoKeys�jmp DoneSide
@@:loop @F
;(3) WITH turns middle keyword detection off.
;(3) END ITERATE LEAVE are different set really but codes are limited.
 z Z.KWMiddle�cmp dl,4�je DoneSide
 jnb NotEND�dec Z.TraceOnly�NotEND:
 On Z.Middles,CheckDO�jmp DoneSide
@@:loop @F
;(4) OTHERWISE ELSE imply a semicolon.
 On Z.Middles,SemiAfter
;(4) THEN implies semicolons before and after, but
; before is only for purposes of "end-clause" action, which THEN can do.
; We want to call ClauseSourceEnd with SI before the THEN.
 mov si,Z.Insert.TokPos
 call ClauseSourceEnd
 jmp DoneSide
@@:loop @F
;(5) ADDRESS setup for WITH, also VALUE
 mov Z.KWMiddle,$WithKey�inc cx; for fallthru
@@:loop @F
;(6) FORM SIGNAL TRACE prepare for VALUE
 On Z.Middles,ImplicitValue
; SIGNAL also needs to set LookLabel
 cmp dl,6�jne TakenC
 On Z.Clause,Signal
@@:; Last case, no need for test.
;(7) CALL NAME preceed TakenConstant
;(7) So do STEM and STREAM but they are not labels.
 cmp bx,$STEM�je TakenC
 cmp bx,$STREAM�je TakenC
 On Z.Middles,LookLabel
TakenC:On Z.Middles,TakenConstant
DoneSide:stc�jmp QKexit
 end
