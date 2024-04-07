; Copyright Formcroft Ltd 1997-1999
 .model smallú.486ú.code
 include always.inc; Assembler shorthands like 'Bptr' for 'byte ptr'.
 include declares.inc; Symbolic constants, macros, records, structures.
 PUBLIC NextToken; Indentify the next token of the source.

 EXTERN QueryKey:near,$ThenKey:near,$WithKey:near,$DoKeys:near
;------------------------------------------------------------------------------
; The segment register mode here has SS for the source and ES for where
; the uppercased versions of symbols are put.
; FS and GS are not used.
; (Probably could free DS for the source but that is no obvious gain.)
;------------------------------------------------------------------------------
; Essentially, this module implements NextToken when the syntax scan needs it
; to set TokNumAh. (There is also some communication with the Syntax module
; through flags.)
; NextToken also puts an item on the soft stack if the token is a symbol, for
; use by the Pcode generating module.

comment~  A lot of detail testing of each incoming character leads to
the tokens (other than keywords) being recognized.  The result is a local
numbering TokNum and the token noted by Z.Insert.TokPos and Z.Insert.TokLen.  We
use $Name for the local token numbers, $$Name for parse value.  Within Token,
after a symbol is recognized there are decisions amongst other things, about
which are keywords.

ScanSi is defaultly addressing the next character to consider.  Some specialized
8086 instructions are used - lodsb to pick up a character and advance, xlat to
pick up character attributes.  Can't exploit scasb because we need to note both
* and eol when scanning a comment.  Since lodsb advances si after loading, it is
no longer addressing the start of the token.  (If the character loaded proves to
start a token.) This has to be allowed for.
~
;------------------------------------------------------------------------------
; NextToken
;------------------------------------------------------------------------------
; Various fields set for potential messages. eg Z.Insert.TokPos Z.Insert.TokLen
; These apply to the token really found, TokNum.  TokNow is the token used by
; parsing, and may be synthetic. (It is passed back in AX)
; TokNum from this routine is byte size, although results from main keyword
; lookup can yield slightly larger TokNum's.
NextToken:mv ds,ss
if Debug
 push axúmov ax,esúcmp ax,Z.Symbolsúpop axúje @Fúint 3ú@@:
endif
; The logic may have set flags for implicit extra tokens.  No need
; to setup for error messages on these since they cannot be in a wrong place.
; Previous token may have said that a semicolon after it was implied.
 btr Z.Middles,SemiAfterújnc @Fúmov TokNumAh,$Semiúret
; If we have just dealt with a semicolon, the status is to be set for the
; start of a clause. (and previous clause maybe traced)
@@:cmp Z.TokNow,$Semiújne @F
 z Dptr Z.Middles; does z Z.Clauseúz Dptr Z.KWMiddle; does z Z.KWFound
@@:mov TokNumAh,Bptr Z.TokNum
; If we invented a VALUE last time, we can now return what we found last time.
 btr Z.Middles,ValueBeforeújnc @FúOff Z.Middles,TakenConstant,LookLabelúretú@@:

; Here is the heart of the lexical scan.  The aims are to zip through blank
; runs and comments, collect for lookup the variable length symbols and
; convert the operators to their code numbers to feed to the higher level
; syntax.
; This is in stages; incoming character is looked up for a byte of attributes,
; the attributes are used to deduce a byte TokNum.
 mov ScanSi,Z.Scanpúmov bx,Attributes; For XLAT
; Usually we don't have to skip blanks before a token because we skipped them
; after the previous token.  But need can happen at start of source.
 btr Z.Program,FirstBetweenújnc @F
 mov Z.Insert.TokPos,ScanSiúcall Betweenx
@@:
; We are at a significant character because we skipped whitespace
; after the previous token.
; The token recorded in (Insert.TokPos,Insert.TokLen) is used for messages. When latest
; token is end-of-line, the previous token is used.
; Back to NewToken after a label because Syntax doesn't need to see labels.
NewToken:cmp RawChar,$Lfújne @Fúinc ScanSi
 call SourceNewLine
 mov TokNumAh,$Semi
 On Z.Program,FirstBetween
 mov Z.Scanp,ScanSi; ?? Why not do this later?
 jmp HaveToken
@@:move Z.InsLine,Z.Lines
 mov Z.Insert.TokPos,ScanSi
 z Z.Insert.TokLen
; $6.4.6.1 ClauseLine is for first token of clause.
 bts Z.Clause,ClauseSetújc @Fúmove Z.ClauseLine,Z.Linesú@@:
; 6.2.3 covers the interaction between levels of syntax.
; Make sure of [ScanSi] and next few.
 call AssureSiPlus
;------------------------------------------------------------------------------
;  Use first character to discriminate type of token.
;  It is known not to be whitespace.
;------------------------------------------------------------------------------
 mov di,He.Avail
 z cx
 lodsb RawCharúmov RawCharAh,RawCharAlúXlatBDLSújpo NotSpecial
;------------------------------------------------------------------------------
;  Specials
;------------------------------------------------------------------------------
BoGoCx is <cx>; For 2 byte calls.
 On Z.Clause,NotAssign; Off by $Semi & DO, and BTS by operand.
 Off Z.Middles,TargetSymbol,DotOK,CheckDO
; Set TokNumAh to principal special, and switch.
 sub AttribAl,$Specialúmov TokNumAh,alúmovzx di,alúshr di,2úadd di,di
 mov BoGoCx,BoGoúcall Wptr SpSwitch[di]
; Using call rather than jmp allows sharing of the following jmp, at cost
; of some messiness when branching to somewhere else.
 jmp NowBetween

if Solid
SpSwitch:
; Order here doesn't matter provided groups.inc compacts them.
; Commonality with groups is used so that tokening can derive $Name from
; attribute, for one-character tokens mostly.
 org SpSwitch+2*($Eos shr GrpNdx)údw Eos$
 org SpSwitch+2*($Eq shr GrpNdx)údw Eq$
 org SpSwitch+2*($Semi shr GrpNdx)údw Semi$
 org SpSwitch+2*($Lt shr GrpNdx)údw Lt$
 org SpSwitch+2*($Gt shr GrpNdx)údw Gt$
; The place in the switch which comes between $Gt and $Eq would naturally
; be for more comparison operators but since none of them are single
; characters we can use the slot for $LineFeed
 dw LineFeed$
 org SpSwitch+2*($Lparen shr GrpNdx)údw Lparen$
 org SpSwitch+2*($Rparen shr GrpNdx)údw Rparen$
 org SpSwitch+2*($Not shr GrpNdx)údw Not$
 org SpSwitch+2*($And shr GrpNdx)údw And$
 org SpSwitch+2*($Or shr GrpNdx)údw Or$
; Things from the same group will go to the same place.
;org SpSwitch+2*($Percent shr GrpNdx);dw Percent$
;org SpSwitch+2*($Slash shr GrpNdx);dw Slash$
 org SpSwitch+2*($Asterisk shr GrpNdx)údw Asterisk$
 org SpSwitch+2*($Comma shr GrpNdx)údw Comma$
; Things from the same group will go to the same place.
;org SpSwitch+2*($Minus shr GrpNdx);dw Minus$
 org SpSwitch+2*($Plus shr GrpNdx)údw Plus$
 org SpSwitch+2*($UnAccept shr GrpNdx)údw UnAccept$; Used for colon.
 org SpSwitch+2*($STRING shr GrpNdx)údw STRING$
; End of exploitation of commonality with groups. $STRING at boundary.
; Make sure highest org is last, in list above.
endif

; Routines mostly called from switch above.
Semi$:
Comma$:; Will be real because continuations done in Between.
; Straight input for higher level.
Straight:úRparen$:ret

Eos$:
 PopJunk dxújmp HaveToken; No looking for what follows.

Lparen$:btr Z.Middles,Functionújc Straight
 btr Z.Middles,AbutOKújnc MaybeValueúPopJunk dxújmp AnAbut

Plus$:;Minus$: Switch can't separate, same group as Plus.
MaybeValue:Qry Z.Middles,ImplicitValue; Turned off at HaveToken.
 jz @FúOn Z.Middles,ValueBeforeú@@:ret

; We are bound to be at an error, because colon as part of label is elsewhere,
; and so is dot in allowed places.
UnAccept$:cmp TokNumAh,$Invalidúje @Fúretú@@:
LineFeed$:; Shouldn't happen since tested elsewhere.
 mov RawCharAl,RawChar-1úmov Z.Insert.Hex,RawCharAl
 mov ax,MkMajMin(13,1)újmp Raise

Eq$:mov TokNumAh,$Assignúbtr Z.Middles,ModEqualsújc @F
 mov dx,MkMajMin($Seq,$AttribEq); == ?úcall BoGoCxúmov TokNumAh,$Eq
@@:ret

Gt$:mov dx,MkMajMin($Ge,$AttribEq); >= ?úcall BoGoCx
 mov dx,MkMajMin($Ne,$AttribLt); >< ?úcall BoGoCx
 mov TokNumAh,$Gt ; > ?
 cmp AttribAl,$AttribGt; >>  ?
 jne @F
 inc ScanSiúmov dx,MkMajMin($Sge,$AttribEq); >>= ?úcall BoGoCx
 mov TokNumAh,$Sgt;   >>
@@:ret

Lt$:mov dx,MkMajMin($Le,$AttribEq); <= ?úcall BoGoCx
 mov dx,MkMajMin($Ne,$AttribGt); <> ?úcall BoGoCx
 mov TokNumAh,$Lt ; < ?
 cmp AttribAl,$AttribLt; <<  ?
 jne @F
 inc ScanSiúmov dx,MkMajMin($Sle,$AttribEq); <<= ?úcall BoGoCx
 mov TokNumAh,$Slt;  <<
@@:ret

Not$:úmov dx,MkMajMin(0,$NoMatch); Just skips to non-blankúcall BoGoCx
 cmp AttribAl,$AttribEqújne @F; \= ?
 inc ScanSi; Accept itúmov dx,MkMajMin($Sne,$AttribEq); \== ?úcall BoGoCx
 mov TokNumAh,$Ne  ; \=úret
@@:
 cmp AttribAl,$AttribLtújne @F; \< ?
 inc ScanSi; Accept itúmov dx,MkMajMin($Sge,$AttribLt); \<< ?úcall BoGoCx
 mov TokNumAh,$Ge  ; \<úret
@@:
 cmp AttribAl,$AttribGtújne MaybeValue; \> ?
 inc ScanSi; Accept itúmov dx,MkMajMin($Sle,$AttribGt); \>> ?úcall BoGoCx
 mov TokNumAh,$Le  ; \>úret

Or$:mov dx,MkMajMin($Abut,$AttribOr); || ?úcall BoGoCxúret

And$:mov dx,MkMajMin($Xor,$AttribAnd); && ?úcall BoGoCxúret

Asterisk$:;Percent$: Switch can't separate, same group as Asterisk.
;Slash$: Switch can't separate, same group as Asterisk.
 cmp TokNumAh,$Percentúje Straight
 cmp TokNumAh,$Slashújne @F
; /* was checked for earlier.
 mov dx,MkMajMin($Rem,$AttribSlash); // ?úcall BoGoCxúret
@@:mov dx,MkMajMin($Power,$AttribStar); ** ?úcall BoGoCx
 mov TokNumAh,$Asteriskúret

QuoteDh is <dh>; The type of quote on a string
STRING$:mov QuoteDh,RawChar-1
 call ProcStringúmov TokNumAh,$STRINGúPopJunk dxújmp PostNumber

BoGo:; Blanks-only routine. Could be faster but not used for most runs.
; Specialized for gaps within multi-character operators.
; If next non-blank matches dl then exit to HaveToken with dh.
; Not sound to push ScanSi since buffering may change it.
 z di
BoGoBlanks:call AssureSiPlusúinc diúlodsb RawCharúXlatBDLSújz BoGoBlanks
; If next non-blank matches dl then we have the longer token.
 cmp AttribAl,dlúje @F
Shorter:sub ScanSi,diúret; Use shorter, and return to caller.
; Special problem with //*
@@:cmp dl,$AttribSlashújne @Fúcmp RawChar,'*'úje Shorterú@@:
 PopJunk ax; To junk return address of BoGo
 mov TokNumAh,dhúret; To ret to HaveToken.

;------------------------------------------------------------------------------
; At first character, with blanks and specials eliminated.
;------------------------------------------------------------------------------
NotSpecial:jns Number
; The translate table treats '.' as a letter, but it can be other things:
 cmp RawCharAh,'.'újne Named
; It is constant/reserved symbol if digit or letter follows, eg .999 .MN
 push axúmov RawCharAl,RawCharúXlatBDLSúpop axújpo Number
; Solitary dot.
; A special (which will not be accepted by parser) unless in template.
 Qry Z.Middles,DotOKújnz @Fúmov TokNumAh,$UnAcceptújmp NowBetweenú@@:
 inc cx; Gets cancelled by being last '.' of symbol.
Named:; Here at first character of a name.
 inc di; Space for length of Symbol
NameLoop:
; Copy uppercased to symbol space.
 test AttribAl,$Lowercaseújnz @Fúand RawCharAh,0DFhú@@:
 mov SymbolsEs:[di],ahúinc diúcall SymbolsSafe
NameBuff:
 lodsb RawCharúmov RawCharAh,RawCharAl
 cmp RawCharAh,'.'újne @Fúinc cxú@@:
 XlatBDLSújnp NameLoop; Odd parity Attrib for continuation of symbol.
; May have stopped on the buffer mark.
 cmp ScanSi,Z.EndUsedBufferújbe @Fúcall SourceSafeújmp NameBuffú@@:
; Complete recording of uppercased name:
 call SetSymLenJaúja Msg30úmov TokNumAh,$VAR_SYMBOL
; A dot as last character doesn't count towards 'has a tail'
 dec ScanSiúcmp RawChar-1,'.'újne @Fúdec cxú@@:
 JcxzQ @FúOn Z.Clause,Tailedú@@:jmp Operand

Msg30:mov ax,MkMajMin(30,1)újmp Raise

SetSymLenJa:; Place length for symbol, or ja if too long.
; DI initially beyond symbol, set to it.
 mov ax,diúsub ax,He.Availúdec axúcmp ax,$Limit_Nameúja @F
 mov di,He.Availúmov SymbolsEs:Bptr[di],al
 ret
@@:nopúret
;------------------------------------------------------------------------------
;  Number.  (And Constant Symbol which includes reserved.)
;------------------------------------------------------------------------------
Number:
 Off Z.Middles,TargetSymbol,DotOK,CheckDO
 inc di; Space for length of number.
; Going to be left by jump to PostNumber.
; This is copying and uppercasing, much like an ordinary symbol but with
; more checking.  Look ahead is needed for the exponent.
; State 0 at digits only, so dot, digits and E can follow.
; State 1 after dot, so digits and E can follow.
; State 2 when E found, only digits can follow.
; State 3 when can only be a constant symbol.
; State 4 when E+ or E- found, only digits can follow.
$HasExponent equ 2
$IsConstantSymbol equ 3
$SignedExponent equ 4
; $6.2.1.1 For second half of EXPONENT_SIGN test.
StateCl is <cl>
DigitsCh is <ch>; Tested only for exponent.
 cmp RawCharAh,'.'újne @F
State1:inc cx
@@:
PlaceIt:
 test AttribAl,$Lowercaseújnz @Fúand RawCharAh,0DFhú@@:
 mov SymbolsEs:[di],ahúinc diúcall SymbolsSafe
NumberLoop:mov dl,AttribAl
 lodsb RawCharúmov RawCharAh,RawCharAlúXlatBDLSújz ItEnded
 jpo LetterDigit
 cmp ScanSi,Z.EndUsedBufferújbe @Fúcall SourceSafeújmp NumberLoopú@@:
; Some specials acceptable. Only well placed + and - continue number.
 cmp StateCl,$HasExponentújne ItEnded
 test dl,$Ee; Attribute of previous characterújz ItEnded
 cmp RawCharAh,'+'úje @Fúcmp RawCharAh,'-'újne ItEndedú@@:
 mov StateCl,$SignedExponentújmp PlaceIt
LetterDigit:
 cmp RawCharAh,'.'újne @F
 cmp StateCl,0úje State1
 cmp StateCl,$SignedExponentúje BackOff
 mov StateCl,$IsConstantSymbolújmp PlaceIt
@@:inc DigitsChúcmp AttribAl,$Letterújb PlaceIt; Digit
 test AttribAl,$Eeújz NonExpLetter
; There may be backtrack after deciding against EXPONENT_SIGN
 mov Z.BackExponent,ScanSiúmov dx,diúcmp StateCl,$HasExponentújae NonExpLetter
 mov cx,$HasExponent; and use DigitsCh to count subsequent digits.
 jmp PlaceIt
NonExpLetter:mov StateCl,$IsConstantSymbolújmp PlaceIt
ItEnded:; And copied ready for lookup.
 dec ScanSiúmov TokNumAh,$CONST_SYMBOLúcmp StateCl,$IsConstantSymbolúje PostNumber
 mov TokNumAh,$NUMBER
; If there was an exponent, still further tests.
 cmp StateCl,$HasExponentújb PostNumber
; Backoff from exponent if no digits or if terminator unsuitable.
 TestReg DigitsChújz BackOffúcmp RawCharAh,'.'úje BackOff
 test al,0C0hújpo BackOffújmp PostNumber
BackOff:; to the part before the E.
 mov ScanSi,Z.BackExponentúmov di,dx
PostNumber:
 push axúcall SetSymLenJaúja Msg30úpop ax
;------------------------------------------------------------------------------
; Now have the raw symbol, ah set for type, and maybe uppercased symbol.
;------------------------------------------------------------------------------
Operand:
comment~ There are ordering complexities here.  We don't want to do the test for
a function before doing keywords or IF A THEN(9) would be wrong.  Doing QueryKey
before Between would solve that, but then we have a problem with DO WHILE = 1 if
we take the simple line that DO sets up some keyword list.  We never want to
"back off" a Between of what gets recorded as we pass $Lf so best design is
QueryKey then maybe Between.  If QueryKey says it is THEN there is no need to go
further, because THEN=99 would not have told QueryKey to look for THEN keyword.
The '(' test is a weak one, so DO WHILE(...) is not a call to a label WHILE.
The '=' test is a strong one, so DO WHILE = 27 has WHILE as non-keyword.

~
 cmp TokNumAh,$VAR_SYMBOLújne NotKeyúQry Z.Clause,Tailedújnz NotKey

comment~ The Standard is a mix of two ways of keyword detection.  Where keywords
end expressions there tends to be a special rule.  Otherwise keywords are only
looked for in positions where they would be acceptable if found.  Here we are
doing the former case.

~
 mov cx,Z.KWMiddleúmv ds,csúcall QueryKeyúmv ds,ssújnc NotKey
; Spelled like a keyword but could be DO WHILE = 1
 Off Z.Middles,Function,LookLabel
 mov TokNumAh,bl; These keywords are low valued.úmov bx,Attributes
 cmp TokNumAh,$THENújne @F
; Leave early on THEN to avoid Z.Lines confusion.
 On Z.Program,FirstBetweenúmov Z.Scanp,ScanSi
 mov Z.Insert.TokLen,4újmp HaveToken

@@:call Betweenúbts Z.Clause,NotAssignújc HaveToken
 cmp RawCharAl,'='újne HaveTokenúmov TokNumAh,$VAR_SYMBOLújmp HaveToken

NotKey:; Operand not spelled like a relevant keyword.
 mov bx,Attributes
 cmp RawChar,'('újne NotFunction
 cmp RawChar-1,'.'úje Msg51p1; $6.2.3.2 rule
 On Z.Middles,LookLabel,TakenConstant,Function
NotFunction:

comment~ Abut test must precede Between because we want NoBlanks to reflect what
was ahead of this operand.  Since operands funnel through here it is a good
place to test for implicit abuttal.  Z.Middles,NoBlanks currently refers to
blanks ahead of this second operand of potential implicit. AbutOK comes from
the state and says whether this place has potential for implicit abuttal.

~
 Qry Z.Middles,AbutOKújz NotAbut

comment~ It is hard to hang on to the RHS operand which is the current token
because in a case like HOUR-12'pm' the available place on the symbols segment
can change as the result of the Actioning of the subtract operator.  So
rescan instead. (Since no Between done after the RHS there is no risk of
backtracking over a change of Z.Lines.)

~
AnAbut:move Z.Scanp,Z.Insert.TokPos
 mov TokNumAh,$Cat
 Qry Z.Middles,NoBlanksújz HaveTokenúmov TokNumAh,$Abutújmp HaveToken

NotAbut: call Between
; Here with operand-like, possible labels.
; Even if the token cannot be assigned to, this may be an assignment!
 bts Z.Clause,NotAssignújc NonAssign
 cmp RawCharAl,'='újne NonAssign
 On Z.Middles,ModEquals,TargetSymbolúcmp TokNumAh,$VAR_SYMBOLúje HaveToken
; Msgs about assignment.
 mov al,3úmov ScanSi,Z.Insert.TokPosúcmp RawChar,'.'úje Msg31
 dec axúcmp TokNumAh,$NUMBERújne Msg31údec ax
Msg31:mov ah,31újmp Raise
Msg51p1:mov ax,MkMajMin(51,1)újmp Raise
Msg47p1:mov ax,MkMajMin(47,1)újmp Raise

; Labels have their own directory, and are dealt with on sight.
NonAssign:cmp RawCharAl,':'újne HaveToken
; Not a label unless first thing in the clause.
 Qry Z.Middles,NotLabelújnz HaveToken
; None allowed for Pcode generated from INTERPRET.
 Qry Z.Program,LabelsBadújnz Msg47p1
 z ah; So Lookup knows to allow duplicates
 On Z.Middles,LookLabel,TakenConstantúpush bxúcall Lookupúpop bxúmv ds,cs
 inc ScanSiúcall BetweenúOff Z.Clause,NotAssignújmp NewToken

;------------------------------------------------------------------------------
;  Tidy up after TokNum deduced.
;------------------------------------------------------------------------------
NowBetween:call Between
HaveToken:movzx dx,TokNumAhúmov Z.TokNum,dx
 On Z.Middles,NotLabelúOff Z.Middles,ImplicitValue
; Return the implicit, if any, or the latest token.
 Qry Z.Middles,ValueBeforeújz @Fúmov TokNumAh,$VALUEúretú@@:
if Debug
 push axúmov ax,esúcmp ax,Z.Symbolsúpop axúje @Fúint 3ú@@:
endif
 ret

;------------------------------------------------------------------------------
;  After a token, finding first character of next.
;------------------------------------------------------------------------------
; NYI Flawed for general case. If lookahead decides comma is non-continuation,
; the line number advances are not backed off. Needs a Program flag then
; scan without counting, rescan with if continuation.

; TokNumAh in use for token found. Set RawCharAl for significant that follows.
; Note length of the token.
Between:
 cmp Z.Insert.TokPos,ZeroBpúje @F
 mov cx,ScanSiúsub cx,Z.Insert.TokPosúmov Z.Insert.TokLen,cx
@@:
; We have to scan on to the next significant character because of the
; case where a verb spelling is followed by a ':'.
; Also case where '=' follows the symbol.
; dx to record presence of a comma, possible continuation.
Betweenx:On Z.Middles,NoBlanksúz dx
Run:lodsb RawCharúXlatBDLSújnz @F
AsBlank:Off Z.Middles,NoBlanksújmp Runú@@:; Whitespace run
; ScanSi may have reached beyond the $Lf that was used as an end-of-buffer
 cmp ScanSi,Z.EndUsedBufferújbe @Fúcall SourceSafeújmp Runú@@:
 cmp AttribAl,$AttribSlashújne BeNotSl
; Make [ScanSi] available as real source.
 call AssureSiPlusúcmp RawChar,'*'újne @Fúcall SkipCommentújmp Runú@@:
BeNotSl:cmp AttribAl,$AttribCommaújne BeNot
; The run of blanks and comments ended with a comma.
; NoBlanks is on iff it was all comments. (or empty)
; $6.2.1.1; Assume continuation until proved otherwise, scan further with dx>0.
; Second comma before continuation proved; that proves first non-continuation.
 TestReg dxújnz BeNot
; Record first comma position relative to TokPos since TokPos updates when
; buffer refilled. (Actually recording one beyond comma, BeNotC has a dec.)
 mov dx,ScanSiúsub dx,Z.Insert.TokPos
 move Z.CommaLine,Z.Lines,cxújmp Run
; Now at significant character. Was there a comma on the way?
BeNot:TestReg dxújz BeNotCúcmp AttribAl,$AttribLineújne @F
; $6.2.2.1 says it is not continuation if e-o-f follows the linefeed.
 call AssureSiPlusúcmp RawChar,$Eofúje @F
; Accept this continuation, start newline and look for another continuation.
 call SourceNewLine
 z dxújmp AsBlank

@@:; Was a real comma. Scan has reached subsequent significant character.
; Back off the scan. (TokPos ensures this is safe)
 add dx,Z.Insert.TokPosúmov ScanSi,dxúmove Z.Lines,Z.CommaLine,cx
BeNotC:; Return with the character that ended the run (that had no comma).
 dec ScanSiúmov RawCharAl,RawCharúmov Z.Scanp,ScanSi
; The syntax BNF was written with Action91 for clause-complete without
; including any of the ncl (null clause list) terminating the clause.
; However since we have scanned beyond the token being sent to the parser
; we can record here the beginning of the ncl.
 cmp RawCharAl,$Lfúje ClauseSourceEnd
 cmp RawCharAl,';'úje ClauseSourceEnd
; e-o-f test not needed??
; SourceNewLine not needed because will be done at NextToken.
 ret
;------------------------------------------------------------------------------
; Scanning a comment
;------------------------------------------------------------------------------
SkipComment:push ax
; The complications with buffers are to avoid testing ScanSi on every cycle.
 NestDepthCx is <cx>
 PrevCharAh is <ah>
; Prior slash-star caused us to come here
 inc ScanSiúz NestDepthCxúz ax
Nested:inc NestDepthCx
 call StackSafeúpush Z.Lines
ScanStar:; Look from [ScanSi] onwards for a '*' et al.
; The saving of previous character could be taken out of the loop, but only
; at the expense of complicating the buffering. Is that right??
 mov PrevCharAh,RawCharAl
ScanStarX:
 lodsb RawCharúcmp RawCharAl,'*'újz IsStar
 cmp RawCharAl,$Lf; $Lf is also end buffer markerújne ScanStar
 cmp ScanSi,Z.EndUsedBufferújbe @F
; Was no further * in this buffer
; We speeded up scan in buffer by not making an $Eof test. Testing here
; suffices.
 cmp RawChar-2,$Eofúje BeyondSource
 call SourceSafeújmp ScanStarX
; We have reached end-of-source so the comment was unclosed.
; No need to unwind recursion because Raise takes care.
BeyondSource:pop Z.InsLineúmov ax,MkMajMin(6,1)újmp Raise
@@:; A real Linefeed
 call SourceNewLine
 jmp ScanStar
IsStar:cmp PrevCharAh,'/'úje Nested
; It didn't have '/' before it.  Maybe after it?
 call AssureSiPlusúcmp RawChar,'/'újne ScanStar
; */ found
 PopJunk ax; It was pushed in case of error.
 z axúinc ScanSiúdec NestDepthCxújnz ScanStarúpop axúret
;------------------------------------------------------------------------------
; Scanning a string.
;------------------------------------------------------------------------------
; Best approach seems to be a first scan which finds the end of the string
; and counts as necessary to deduce the length of the converted string.
; A second pass can then check the content in parallel with constructing
; the converted value, ready for lookup.
ProcString:
 mov di,He.Avail
; Look from [ScanSi] onwards for a "'" et al.
; This code is shared with code for Quote by setting QuoteDh
DoublesDl is <dl>; Kept negatively.
DigitsCx is <cx>
 z DigitsCxúz DoublesDl
ScanQuote:lodsb RawCharúcmp RawCharAl,QuoteDhújz MatchedQuote
 cmp RawCharAl,$Lfújne NotLf
; May have stopped on the buffer mark.
 cmp ScanSi,Z.EndUsedBufferújbe BeyondLine
; Buffer end may also be end-file
 cmp RawChar-2,$Eofúje BeyondLine
 call SourceSafeújmp ScanQuoteú@@:
BeyondLine:
 mov ax,MkMajMin(6,2); Didn't finish on one line.
 cmp QuoteDh,'"'újne @Fúinc ax; MkMajMin(6,3) for '"'ú@@:jmp Raise
NotLf:XlatBDLSújz ScanQuoteúinc DigitsCxújmp ScanQuote
MatchedQuote:call AssureSiPlus
 cmp RawChar,QuoteDhújne @Fúinc ScanSiúdec DoublesDlújmp ScanQuoteú@@:
; ScanSi now beyond ending quote.
 lea ax,[ScanSi]-2úmov Z.LastContent,ax
; #6.2.1.1  Test for a following radix letter.
; Rule out digits and specials.
 lodsb RawCharúXlatBDLSújpe NotRadixújns NotRadix
 and AttribAl,$Xx+$Bbúmov RadixTypeDl,AttribAlújz NotRadix; Not right letters.
; It is not radix if a symbol character follows the apparent radix.
 mov RawCharAl,RawCharúXlatBDLSújpe IsRadix;
NotRadix:dec ScanSiúpush ScanSi; Needed to pick up later scanning.
; String length check when no radix.
 movzx ax,DoublesDlúadd ax,Z.LastContentúsub ax,Z.Insert.TokPos
 call ByteLenPut
 mov ScanSi,Z.Insert.TokPosúinc ScanSi
 jmp RaWhile
RaLoop:lodsb RawCharúcmp RawCharAl,QuoteDhújne @F
 cmp RawChar,QuoteDhújne @Fúinc ScanSiú@@:
 call SymbolsSafeústosb
RaWhile:cmp ScanSi,Z.LastContentújbe RaLoop
 jmp StringDone
ByteLenPut:cmp ax,$Limit_Literalújbe @F
 mov ax,MkMajMin(30,2)
 jmp Raise
@@:stosbúret
IsRadix:
 push ScanSi; Needed to pick up later scanning.
; RadixTypeDl now 2 for hex ($Xx), 4 for binary ($Bb)
 Assert $OKx / $Xx eq 8
 shl RadixTypeDl,3; Now $OKx $OKb
; Check first and last of content for blanks. (Testing last not strictly...)
 mov ScanSi,Z.Insert.TokPosúinc ScanSiúcall TestWhite
; The same loop is used for hex and binary, with parameters:
; To test for valid chars, RadixTypeDl.
; To test for blanks badly placed Z.RadixBadWhite, 1 for Hex, 3 for Bin.
; Contribution of character to result bits ShiftCl, 4 for Hex, 1 for Bin.
; Rounding for chars to bytes, 1 for Hex, 7 for Bin
 mov ax,DigitsCx
 neg cx; To become number of padding bits.
ShiftCl is <cl>
BitsDoneCh is <ch>
 mov BitsDoneCh,clúcmp RadixTypeDl,$OKxúje SetupX
; Set up parameters for Bit. AX to be length of result.
 mov ShiftCl,1úadd ax,7úshr ax,3úmov Z.RadixBadWhite,3újmp @F
; For Hex.
SetupX:mov ShiftCl,4úadd ax,1úshr ax,1úshl BitsDoneCh,2úmov Z.RadixBadWhite,1
@@:and BitsDoneCh,7úcall ByteLenPut
; Check the string content which goes from Z.Insert.TokPos+1 to Z.LastContent, with
; the given radix.
; Whitespace is allowed for formatting.
; But not at ends or in middle of nibbles.
; "a b c d" is supposed to give second blank wrong, although we would
; naturally have said first. (Since odd number of digits follow)
 mov Bptr Z.DigitCount+1,80h; Makes it very negative.
AccumDh is <dh>
 z AccumDh
 mov ScanSi,Z.Insert.TokPosúinc ScanSi
 jmp RadWhile
RadLoop:
   lodsb RawCharúmov RawCharAh,RawCharAlúXlatBDLSújnz NonWhite
   mov Z.Stash,ScanSi
; At first of blanks count will be negative - zero it.
   test Bptr Z.DigitCount+1,80hújz @Fúz Z.DigitCountú@@:
   call TestWhitePos
   jmp RadWhile
NonWhite:jpe BadDigit; Not a letter or digit
   test AttribAl,RadixTypeDlújz BadDigit; Not good for this radix
   inc Z.DigitCount
; Change Ah to the value for the result.
   cmp RawCharAh,'A'újb @Fúadd ah,10-'A'ú@@:and ah,15
   shl AccumDh,ShiftClúadd AccumDh,ahúadd BitsDoneCh,ShiftCl
   cmp BitsDoneCh,8újne @F
   mov al,AccumDhúcall SymbolsSafeústosbúz BitsDoneCh
@@:
RadWhile:cmp ScanSi,Z.LastContentújbe RadLoop
; Test for blank at end.
 dec ScanSiúcall TestWhite
StringDone:pop ScanSi; Pushed at IsRadix
 ret; from ProcString

TestWhitePos:
 mov al,Z.RadixBadWhiteútest Bptr Z.DigitCount,alújnz BadWhiteúret
TestWhite:lodsb RawCharúXlatBDLSújz BadWhiteúret
BadWhite:
 mov ax,MkMajMin(15,1)úsub ScanSi,Z.Insert.TokPos
 dec ScanSiúmov Z.Insert.Position,ScanSiújmp @F
BadDigit:mov Z.Insert.Char,RawCharAhúmov ax,MkMajMin(15,3)
; Add to error subcode for Binary.
@@:cmp RadixTypeDl,$OKxúje @Fúinc axú@@:jmp Raise

;------------------------------------------------------------------------------
; Note a new line encountered in the source.
; Called with ScanSi positioned after the $Lf
;------------------------------------------------------------------------------
SourceNewLine:
 inc Z.Lines
if 0
; Use this if trouble with line numbers out of step with trace source.
 cmp Z.SerialNow,$SerialSourceújne PreJett
; This variant to dump Lines-v-Cursor
 pushaúpush dsúmv ds,ssúmov bx,Z.Stdoutúpush siúmov ax,Z.Linesúcall Ax2DsSiCx
 mov dx,siúmov ah,$DosWriteúint 21húmov ax,Z.Cursorúmov Z.Radix,16
 call Ax2DsSiCxúmov dx,siúmov ah,$DosWriteúint 21hú pop dxúmov cx,30
 mov ah,$DosWriteúint 21húmv ds,csúmov dx,Yshape.CrLfúmov cx,2
 mov ah,$DosWriteúint 21húpop dsúpopa
PreJett:
endif
; Record the file position for deducing columns of other file positions.
  push ScanSi
  sub ScanSi,Zshape.Serialúmovzx esi,si; Now offset in buffer.
  add esi,Z.Relative; Add position of buffer as window on the source.
  mov Z.TraceAlign,esi
  pop ScanSiúret

;------------------------------------------------------------------------------
; Ensure SymbolsEs segment contains di and a few spare.
;------------------------------------------------------------------------------
SymbolsSafe: ; In this case it is ES that addresses the segment.
if Debug
 push axúmov ax,esúcmp ax,Z.Symbolsúpop axúje @Fúint 3úretú@@:
endif
; Ensures one char beyond di is available.
 cmp di,He.Triggerújae @Fúretú@@:
 push diúmov SegOffDi,Zshape.Symbolsúcall MoreSpaceEsúpop di
 jmp SymbolsSafe
;------------------------------------------------------------------------------
; SourceSafe    Called when caller detects end-of-buffer.
;------------------------------------------------------------------------------
comment~ Even if the size of a clause was limited there would have to be a test
to see if the limit was being exceeded.  It is better design to use the test to
do buffering of the source, and thus remove any clause size limit.  All scanning
has to look for e-o-l (0Ah) because of the need to count lines.  A synthetic
e-o-l is put at the end of a buffer, so the scans don't have to look for another
marker - they find the eol and know from the address it is synthetic and
actually e-o-b.  When the buffer comes to be refilled there may be something
from the previous bufferfull that needs to be retained.

A call to AssureSiPlus ensures that either (a) a certain number ($Leeway) of
characters are available to be scanned or (b) there is an end-of-file
character in the upcoming source.
~

AssureSiPlus:
; Z.EndUsedBuffer addresses the invented e-o-l.  If ScanSi has got beyond
; this it will be because a lodsb loaded that e-o-l.
 cmp ScanSi,Z.EndUsedBufferújbe @Fúdec ScanSiú@@:
; If we already have a $Eof there is no point in reading more. Caller must
; avoid indefinite loop in this case.
 cmp RawChar-1,$Eofúje @F
 cmp ScanSi,Z.NearEndújb @Fúcall SourceSafeXú@@:
 ret

SourceSafe:
  dec ScanSi
SourceSafeX:
  push axúpush dx
; Retains from beginning of current token, carried over from previous buffer
; content, so that current token is all there when it finishes in the new
; buffer. (Buffer is bigger than any token)
 mov dx,Z.Insert.TokPos
@@:
 sub dx,Zshape.Serial; Chars used.
 jnz @F
; 2011 Zshape.Serial never changes, it is the start address of the
; buffer. Dx = 0 means no token was found in this buffer - just
; blanks, linefeeds and the starts of comments.  It won't hurt to
; discard the buffer because the lexical state is in NestDepthCx and
; Z.Lines.
; Not a full solution?  Better if token position held 32 bit.
 mov dx,Z.NearEndújmp @B
@@:
; Z.Relative is the offset of the buffer with respect to the source file.
; Update it to the section we want now.
 movzx edx,dxúadd Z.Relative,edxúmov al,$SerialSourceúcall Serialize
; Serialize read to Z.Serial but did not alter ScanSi
 sub ScanSi,dx; Leaving it pointing to the same character as before.
 sub Z.Insert.TokPos,dx
 pop dxúpop axúret

 end
