; Copyright Formcroft Ltd 1997-1999
 .model small�.486�.code
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
 push ax�mov ax,es�cmp ax,Z.Symbols�pop ax�je @F�int 3�@@:
endif
; The logic may have set flags for implicit extra tokens.  No need
; to setup for error messages on these since they cannot be in a wrong place.
; Previous token may have said that a semicolon after it was implied.
 btr Z.Middles,SemiAfter�jnc @F�mov TokNumAh,$Semi�ret
; If we have just dealt with a semicolon, the status is to be set for the
; start of a clause. (and previous clause maybe traced)
@@:cmp Z.TokNow,$Semi�jne @F
 z Dptr Z.Middles; does z Z.Clause�z Dptr Z.KWMiddle; does z Z.KWFound
@@:mov TokNumAh,Bptr Z.TokNum
; If we invented a VALUE last time, we can now return what we found last time.
 btr Z.Middles,ValueBefore�jnc @F�Off Z.Middles,TakenConstant,LookLabel�ret�@@:

; Here is the heart of the lexical scan.  The aims are to zip through blank
; runs and comments, collect for lookup the variable length symbols and
; convert the operators to their code numbers to feed to the higher level
; syntax.
; This is in stages; incoming character is looked up for a byte of attributes,
; the attributes are used to deduce a byte TokNum.
 mov ScanSi,Z.Scanp�mov bx,Attributes; For XLAT
; Usually we don't have to skip blanks before a token because we skipped them
; after the previous token.  But need can happen at start of source.
 btr Z.Program,FirstBetween�jnc @F
 mov Z.Insert.TokPos,ScanSi�call Betweenx
@@:
; We are at a significant character because we skipped whitespace
; after the previous token.
; The token recorded in (Insert.TokPos,Insert.TokLen) is used for messages. When latest
; token is end-of-line, the previous token is used.
; Back to NewToken after a label because Syntax doesn't need to see labels.
NewToken:cmp RawChar,$Lf�jne @F�inc ScanSi
 call SourceNewLine
 mov TokNumAh,$Semi
 On Z.Program,FirstBetween
 mov Z.Scanp,ScanSi; ?? Why not do this later?
 jmp HaveToken
@@:move Z.InsLine,Z.Lines
 mov Z.Insert.TokPos,ScanSi
 z Z.Insert.TokLen
; $6.4.6.1 ClauseLine is for first token of clause.
 bts Z.Clause,ClauseSet�jc @F�move Z.ClauseLine,Z.Lines�@@:
; 6.2.3 covers the interaction between levels of syntax.
; Make sure of [ScanSi] and next few.
 call AssureSiPlus
;------------------------------------------------------------------------------
;  Use first character to discriminate type of token.
;  It is known not to be whitespace.
;------------------------------------------------------------------------------
 mov di,He.Avail
 z cx
 lodsb RawChar�mov RawCharAh,RawCharAl�XlatBDLS�jpo NotSpecial
;------------------------------------------------------------------------------
;  Specials
;------------------------------------------------------------------------------
BoGoCx is <cx>; For 2 byte calls.
 On Z.Clause,NotAssign; Off by $Semi & DO, and BTS by operand.
 Off Z.Middles,TargetSymbol,DotOK,CheckDO
; Set TokNumAh to principal special, and switch.
 sub AttribAl,$Special�mov TokNumAh,al�movzx di,al�shr di,2�add di,di
 mov BoGoCx,BoGo�call Wptr SpSwitch[di]
; Using call rather than jmp allows sharing of the following jmp, at cost
; of some messiness when branching to somewhere else.
 jmp NowBetween

if Solid
SpSwitch:
; Order here doesn't matter provided groups.inc compacts them.
; Commonality with groups is used so that tokening can derive $Name from
; attribute, for one-character tokens mostly.
 org SpSwitch+2*($Eos shr GrpNdx)�dw Eos$
 org SpSwitch+2*($Eq shr GrpNdx)�dw Eq$
 org SpSwitch+2*($Semi shr GrpNdx)�dw Semi$
 org SpSwitch+2*($Lt shr GrpNdx)�dw Lt$
 org SpSwitch+2*($Gt shr GrpNdx)�dw Gt$
; The place in the switch which comes between $Gt and $Eq would naturally
; be for more comparison operators but since none of them are single
; characters we can use the slot for $LineFeed
 dw LineFeed$
 org SpSwitch+2*($Lparen shr GrpNdx)�dw Lparen$
 org SpSwitch+2*($Rparen shr GrpNdx)�dw Rparen$
 org SpSwitch+2*($Not shr GrpNdx)�dw Not$
 org SpSwitch+2*($And shr GrpNdx)�dw And$
 org SpSwitch+2*($Or shr GrpNdx)�dw Or$
; Things from the same group will go to the same place.
;org SpSwitch+2*($Percent shr GrpNdx);dw Percent$
;org SpSwitch+2*($Slash shr GrpNdx);dw Slash$
 org SpSwitch+2*($Asterisk shr GrpNdx)�dw Asterisk$
 org SpSwitch+2*($Comma shr GrpNdx)�dw Comma$
; Things from the same group will go to the same place.
;org SpSwitch+2*($Minus shr GrpNdx);dw Minus$
 org SpSwitch+2*($Plus shr GrpNdx)�dw Plus$
 org SpSwitch+2*($UnAccept shr GrpNdx)�dw UnAccept$; Used for colon.
 org SpSwitch+2*($STRING shr GrpNdx)�dw STRING$
; End of exploitation of commonality with groups. $STRING at boundary.
; Make sure highest org is last, in list above.
endif

; Routines mostly called from switch above.
Semi$:
Comma$:; Will be real because continuations done in Between.
; Straight input for higher level.
Straight:�Rparen$:ret

Eos$:
 PopJunk dx�jmp HaveToken; No looking for what follows.

Lparen$:btr Z.Middles,Function�jc Straight
 btr Z.Middles,AbutOK�jnc MaybeValue�PopJunk dx�jmp AnAbut

Plus$:;Minus$: Switch can't separate, same group as Plus.
MaybeValue:Qry Z.Middles,ImplicitValue; Turned off at HaveToken.
 jz @F�On Z.Middles,ValueBefore�@@:ret

; We are bound to be at an error, because colon as part of label is elsewhere,
; and so is dot in allowed places.
UnAccept$:cmp TokNumAh,$Invalid�je @F�ret�@@:
LineFeed$:; Shouldn't happen since tested elsewhere.
 mov RawCharAl,RawChar-1�mov Z.Insert.Hex,RawCharAl
 mov ax,MkMajMin(13,1)�jmp Raise

Eq$:mov TokNumAh,$Assign�btr Z.Middles,ModEquals�jc @F
 mov dx,MkMajMin($Seq,$AttribEq); == ?�call BoGoCx�mov TokNumAh,$Eq
@@:ret

Gt$:mov dx,MkMajMin($Ge,$AttribEq); >= ?�call BoGoCx
 mov dx,MkMajMin($Ne,$AttribLt); >< ?�call BoGoCx
 mov TokNumAh,$Gt ; > ?
 cmp AttribAl,$AttribGt; >>  ?
 jne @F
 inc ScanSi�mov dx,MkMajMin($Sge,$AttribEq); >>= ?�call BoGoCx
 mov TokNumAh,$Sgt;   >>
@@:ret

Lt$:mov dx,MkMajMin($Le,$AttribEq); <= ?�call BoGoCx
 mov dx,MkMajMin($Ne,$AttribGt); <> ?�call BoGoCx
 mov TokNumAh,$Lt ; < ?
 cmp AttribAl,$AttribLt; <<  ?
 jne @F
 inc ScanSi�mov dx,MkMajMin($Sle,$AttribEq); <<= ?�call BoGoCx
 mov TokNumAh,$Slt;  <<
@@:ret

Not$:�mov dx,MkMajMin(0,$NoMatch); Just skips to non-blank�call BoGoCx
 cmp AttribAl,$AttribEq�jne @F; \= ?
 inc ScanSi; Accept it�mov dx,MkMajMin($Sne,$AttribEq); \== ?�call BoGoCx
 mov TokNumAh,$Ne  ; \=�ret
@@:
 cmp AttribAl,$AttribLt�jne @F; \< ?
 inc ScanSi; Accept it�mov dx,MkMajMin($Sge,$AttribLt); \<< ?�call BoGoCx
 mov TokNumAh,$Ge  ; \<�ret
@@:
 cmp AttribAl,$AttribGt�jne MaybeValue; \> ?
 inc ScanSi; Accept it�mov dx,MkMajMin($Sle,$AttribGt); \>> ?�call BoGoCx
 mov TokNumAh,$Le  ; \>�ret

Or$:mov dx,MkMajMin($Abut,$AttribOr); || ?�call BoGoCx�ret

And$:mov dx,MkMajMin($Xor,$AttribAnd); && ?�call BoGoCx�ret

Asterisk$:;Percent$: Switch can't separate, same group as Asterisk.
;Slash$: Switch can't separate, same group as Asterisk.
 cmp TokNumAh,$Percent�je Straight
 cmp TokNumAh,$Slash�jne @F
; /* was checked for earlier.
 mov dx,MkMajMin($Rem,$AttribSlash); // ?�call BoGoCx�ret
@@:mov dx,MkMajMin($Power,$AttribStar); ** ?�call BoGoCx
 mov TokNumAh,$Asterisk�ret

QuoteDh is <dh>; The type of quote on a string
STRING$:mov QuoteDh,RawChar-1
 call ProcString�mov TokNumAh,$STRING�PopJunk dx�jmp PostNumber

BoGo:; Blanks-only routine. Could be faster but not used for most runs.
; Specialized for gaps within multi-character operators.
; If next non-blank matches dl then exit to HaveToken with dh.
; Not sound to push ScanSi since buffering may change it.
 z di
BoGoBlanks:call AssureSiPlus�inc di�lodsb RawChar�XlatBDLS�jz BoGoBlanks
; If next non-blank matches dl then we have the longer token.
 cmp AttribAl,dl�je @F
Shorter:sub ScanSi,di�ret; Use shorter, and return to caller.
; Special problem with //*
@@:cmp dl,$AttribSlash�jne @F�cmp RawChar,'*'�je Shorter�@@:
 PopJunk ax; To junk return address of BoGo
 mov TokNumAh,dh�ret; To ret to HaveToken.

;------------------------------------------------------------------------------
; At first character, with blanks and specials eliminated.
;------------------------------------------------------------------------------
NotSpecial:jns Number
; The translate table treats '.' as a letter, but it can be other things:
 cmp RawCharAh,'.'�jne Named
; It is constant/reserved symbol if digit or letter follows, eg .999 .MN
 push ax�mov RawCharAl,RawChar�XlatBDLS�pop ax�jpo Number
; Solitary dot.
; A special (which will not be accepted by parser) unless in template.
 Qry Z.Middles,DotOK�jnz @F�mov TokNumAh,$UnAccept�jmp NowBetween�@@:
 inc cx; Gets cancelled by being last '.' of symbol.
Named:; Here at first character of a name.
 inc di; Space for length of Symbol
NameLoop:
; Copy uppercased to symbol space.
 test AttribAl,$Lowercase�jnz @F�and RawCharAh,0DFh�@@:
 mov SymbolsEs:[di],ah�inc di�call SymbolsSafe
NameBuff:
 lodsb RawChar�mov RawCharAh,RawCharAl
 cmp RawCharAh,'.'�jne @F�inc cx�@@:
 XlatBDLS�jnp NameLoop; Odd parity Attrib for continuation of symbol.
; May have stopped on the buffer mark.
 cmp ScanSi,Z.EndUsedBuffer�jbe @F�call SourceSafe�jmp NameBuff�@@:
; Complete recording of uppercased name:
 call SetSymLenJa�ja Msg30�mov TokNumAh,$VAR_SYMBOL
; A dot as last character doesn't count towards 'has a tail'
 dec ScanSi�cmp RawChar-1,'.'�jne @F�dec cx�@@:
 JcxzQ @F�On Z.Clause,Tailed�@@:jmp Operand

Msg30:mov ax,MkMajMin(30,1)�jmp Raise

SetSymLenJa:; Place length for symbol, or ja if too long.
; DI initially beyond symbol, set to it.
 mov ax,di�sub ax,He.Avail�dec ax�cmp ax,$Limit_Name�ja @F
 mov di,He.Avail�mov SymbolsEs:Bptr[di],al
 ret
@@:nop�ret
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
 cmp RawCharAh,'.'�jne @F
State1:inc cx
@@:
PlaceIt:
 test AttribAl,$Lowercase�jnz @F�and RawCharAh,0DFh�@@:
 mov SymbolsEs:[di],ah�inc di�call SymbolsSafe
NumberLoop:mov dl,AttribAl
 lodsb RawChar�mov RawCharAh,RawCharAl�XlatBDLS�jz ItEnded
 jpo LetterDigit
 cmp ScanSi,Z.EndUsedBuffer�jbe @F�call SourceSafe�jmp NumberLoop�@@:
; Some specials acceptable. Only well placed + and - continue number.
 cmp StateCl,$HasExponent�jne ItEnded
 test dl,$Ee; Attribute of previous character�jz ItEnded
 cmp RawCharAh,'+'�je @F�cmp RawCharAh,'-'�jne ItEnded�@@:
 mov StateCl,$SignedExponent�jmp PlaceIt
LetterDigit:
 cmp RawCharAh,'.'�jne @F
 cmp StateCl,0�je State1
 cmp StateCl,$SignedExponent�je BackOff
 mov StateCl,$IsConstantSymbol�jmp PlaceIt
@@:inc DigitsCh�cmp AttribAl,$Letter�jb PlaceIt; Digit
 test AttribAl,$Ee�jz NonExpLetter
; There may be backtrack after deciding against EXPONENT_SIGN
 mov Z.BackExponent,ScanSi�mov dx,di�cmp StateCl,$HasExponent�jae NonExpLetter
 mov cx,$HasExponent; and use DigitsCh to count subsequent digits.
 jmp PlaceIt
NonExpLetter:mov StateCl,$IsConstantSymbol�jmp PlaceIt
ItEnded:; And copied ready for lookup.
 dec ScanSi�mov TokNumAh,$CONST_SYMBOL�cmp StateCl,$IsConstantSymbol�je PostNumber
 mov TokNumAh,$NUMBER
; If there was an exponent, still further tests.
 cmp StateCl,$HasExponent�jb PostNumber
; Backoff from exponent if no digits or if terminator unsuitable.
 TestReg DigitsCh�jz BackOff�cmp RawCharAh,'.'�je BackOff
 test al,0C0h�jpo BackOff�jmp PostNumber
BackOff:; to the part before the E.
 mov ScanSi,Z.BackExponent�mov di,dx
PostNumber:
 push ax�call SetSymLenJa�ja Msg30�pop ax
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
 cmp TokNumAh,$VAR_SYMBOL�jne NotKey�Qry Z.Clause,Tailed�jnz NotKey

comment~ The Standard is a mix of two ways of keyword detection.  Where keywords
end expressions there tends to be a special rule.  Otherwise keywords are only
looked for in positions where they would be acceptable if found.  Here we are
doing the former case.

~
 mov cx,Z.KWMiddle�mv ds,cs�call QueryKey�mv ds,ss�jnc NotKey
; Spelled like a keyword but could be DO WHILE = 1
 Off Z.Middles,Function,LookLabel
 mov TokNumAh,bl; These keywords are low valued.�mov bx,Attributes
 cmp TokNumAh,$THEN�jne @F
; Leave early on THEN to avoid Z.Lines confusion.
 On Z.Program,FirstBetween�mov Z.Scanp,ScanSi
 mov Z.Insert.TokLen,4�jmp HaveToken

@@:call Between�bts Z.Clause,NotAssign�jc HaveToken
 cmp RawCharAl,'='�jne HaveToken�mov TokNumAh,$VAR_SYMBOL�jmp HaveToken

NotKey:; Operand not spelled like a relevant keyword.
 mov bx,Attributes
 cmp RawChar,'('�jne NotFunction
 cmp RawChar-1,'.'�je Msg51p1; $6.2.3.2 rule
 On Z.Middles,LookLabel,TakenConstant,Function
NotFunction:

comment~ Abut test must precede Between because we want NoBlanks to reflect what
was ahead of this operand.  Since operands funnel through here it is a good
place to test for implicit abuttal.  Z.Middles,NoBlanks currently refers to
blanks ahead of this second operand of potential implicit. AbutOK comes from
the state and says whether this place has potential for implicit abuttal.

~
 Qry Z.Middles,AbutOK�jz NotAbut

comment~ It is hard to hang on to the RHS operand which is the current token
because in a case like HOUR-12'pm' the available place on the symbols segment
can change as the result of the Actioning of the subtract operator.  So
rescan instead. (Since no Between done after the RHS there is no risk of
backtracking over a change of Z.Lines.)

~
AnAbut:move Z.Scanp,Z.Insert.TokPos
 mov TokNumAh,$Cat
 Qry Z.Middles,NoBlanks�jz HaveToken�mov TokNumAh,$Abut�jmp HaveToken

NotAbut: call Between
; Here with operand-like, possible labels.
; Even if the token cannot be assigned to, this may be an assignment!
 bts Z.Clause,NotAssign�jc NonAssign
 cmp RawCharAl,'='�jne NonAssign
 On Z.Middles,ModEquals,TargetSymbol�cmp TokNumAh,$VAR_SYMBOL�je HaveToken
; Msgs about assignment.
 mov al,3�mov ScanSi,Z.Insert.TokPos�cmp RawChar,'.'�je Msg31
 dec ax�cmp TokNumAh,$NUMBER�jne Msg31�dec ax
Msg31:mov ah,31�jmp Raise
Msg51p1:mov ax,MkMajMin(51,1)�jmp Raise
Msg47p1:mov ax,MkMajMin(47,1)�jmp Raise

; Labels have their own directory, and are dealt with on sight.
NonAssign:cmp RawCharAl,':'�jne HaveToken
; Not a label unless first thing in the clause.
 Qry Z.Middles,NotLabel�jnz HaveToken
; None allowed for Pcode generated from INTERPRET.
 Qry Z.Program,LabelsBad�jnz Msg47p1
 z ah; So Lookup knows to allow duplicates
 On Z.Middles,LookLabel,TakenConstant�push bx�call Lookup�pop bx�mv ds,cs
 inc ScanSi�call Between�Off Z.Clause,NotAssign�jmp NewToken

;------------------------------------------------------------------------------
;  Tidy up after TokNum deduced.
;------------------------------------------------------------------------------
NowBetween:call Between
HaveToken:movzx dx,TokNumAh�mov Z.TokNum,dx
 On Z.Middles,NotLabel�Off Z.Middles,ImplicitValue
; Return the implicit, if any, or the latest token.
 Qry Z.Middles,ValueBefore�jz @F�mov TokNumAh,$VALUE�ret�@@:
if Debug
 push ax�mov ax,es�cmp ax,Z.Symbols�pop ax�je @F�int 3�@@:
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
 cmp Z.Insert.TokPos,ZeroBp�je @F
 mov cx,ScanSi�sub cx,Z.Insert.TokPos�mov Z.Insert.TokLen,cx
@@:
; We have to scan on to the next significant character because of the
; case where a verb spelling is followed by a ':'.
; Also case where '=' follows the symbol.
; dx to record presence of a comma, possible continuation.
Betweenx:On Z.Middles,NoBlanks�z dx
Run:lodsb RawChar�XlatBDLS�jnz @F
AsBlank:Off Z.Middles,NoBlanks�jmp Run�@@:; Whitespace run
; ScanSi may have reached beyond the $Lf that was used as an end-of-buffer
 cmp ScanSi,Z.EndUsedBuffer�jbe @F�call SourceSafe�jmp Run�@@:
 cmp AttribAl,$AttribSlash�jne BeNotSl
; Make [ScanSi] available as real source.
 call AssureSiPlus�cmp RawChar,'*'�jne @F�call SkipComment�jmp Run�@@:
BeNotSl:cmp AttribAl,$AttribComma�jne BeNot
; The run of blanks and comments ended with a comma.
; NoBlanks is on iff it was all comments. (or empty)
; $6.2.1.1; Assume continuation until proved otherwise, scan further with dx>0.
; Second comma before continuation proved; that proves first non-continuation.
 TestReg dx�jnz BeNot
; Record first comma position relative to TokPos since TokPos updates when
; buffer refilled. (Actually recording one beyond comma, BeNotC has a dec.)
 mov dx,ScanSi�sub dx,Z.Insert.TokPos
 move Z.CommaLine,Z.Lines,cx�jmp Run
; Now at significant character. Was there a comma on the way?
BeNot:TestReg dx�jz BeNotC�cmp AttribAl,$AttribLine�jne @F
; $6.2.2.1 says it is not continuation if e-o-f follows the linefeed.
 call AssureSiPlus�cmp RawChar,$Eof�je @F
; Accept this continuation, start newline and look for another continuation.
 call SourceNewLine
 z dx�jmp AsBlank

@@:; Was a real comma. Scan has reached subsequent significant character.
; Back off the scan. (TokPos ensures this is safe)
 add dx,Z.Insert.TokPos�mov ScanSi,dx�move Z.Lines,Z.CommaLine,cx
BeNotC:; Return with the character that ended the run (that had no comma).
 dec ScanSi�mov RawCharAl,RawChar�mov Z.Scanp,ScanSi
; The syntax BNF was written with Action91 for clause-complete without
; including any of the ncl (null clause list) terminating the clause.
; However since we have scanned beyond the token being sent to the parser
; we can record here the beginning of the ncl.
 cmp RawCharAl,$Lf�je ClauseSourceEnd
 cmp RawCharAl,';'�je ClauseSourceEnd
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
 inc ScanSi�z NestDepthCx�z ax
Nested:inc NestDepthCx
 call StackSafe�push Z.Lines
ScanStar:; Look from [ScanSi] onwards for a '*' et al.
; The saving of previous character could be taken out of the loop, but only
; at the expense of complicating the buffering. Is that right??
 mov PrevCharAh,RawCharAl
ScanStarX:
 lodsb RawChar�cmp RawCharAl,'*'�jz IsStar
 cmp RawCharAl,$Lf; $Lf is also end buffer marker�jne ScanStar
 cmp ScanSi,Z.EndUsedBuffer�jbe @F
; Was no further * in this buffer
; We speeded up scan in buffer by not making an $Eof test. Testing here
; suffices.
 cmp RawChar-2,$Eof�je BeyondSource
 call SourceSafe�jmp ScanStarX
; We have reached end-of-source so the comment was unclosed.
; No need to unwind recursion because Raise takes care.
BeyondSource:pop Z.InsLine�mov ax,MkMajMin(6,1)�jmp Raise
@@:; A real Linefeed
 call SourceNewLine
 jmp ScanStar
IsStar:cmp PrevCharAh,'/'�je Nested
; It didn't have '/' before it.  Maybe after it?
 call AssureSiPlus�cmp RawChar,'/'�jne ScanStar
; */ found
 PopJunk ax; It was pushed in case of error.
 z ax�inc ScanSi�dec NestDepthCx�jnz ScanStar�pop ax�ret
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
 z DigitsCx�z DoublesDl
ScanQuote:lodsb RawChar�cmp RawCharAl,QuoteDh�jz MatchedQuote
 cmp RawCharAl,$Lf�jne NotLf
; May have stopped on the buffer mark.
 cmp ScanSi,Z.EndUsedBuffer�jbe BeyondLine
; Buffer end may also be end-file
 cmp RawChar-2,$Eof�je BeyondLine
 call SourceSafe�jmp ScanQuote�@@:
BeyondLine:
 mov ax,MkMajMin(6,2); Didn't finish on one line.
 cmp QuoteDh,'"'�jne @F�inc ax; MkMajMin(6,3) for '"'�@@:jmp Raise
NotLf:XlatBDLS�jz ScanQuote�inc DigitsCx�jmp ScanQuote
MatchedQuote:call AssureSiPlus
 cmp RawChar,QuoteDh�jne @F�inc ScanSi�dec DoublesDl�jmp ScanQuote�@@:
; ScanSi now beyond ending quote.
 lea ax,[ScanSi]-2�mov Z.LastContent,ax
; #6.2.1.1  Test for a following radix letter.
; Rule out digits and specials.
 lodsb RawChar�XlatBDLS�jpe NotRadix�jns NotRadix
 and AttribAl,$Xx+$Bb�mov RadixTypeDl,AttribAl�jz NotRadix; Not right letters.
; It is not radix if a symbol character follows the apparent radix.
 mov RawCharAl,RawChar�XlatBDLS�jpe IsRadix;
NotRadix:dec ScanSi�push ScanSi; Needed to pick up later scanning.
; String length check when no radix.
 movzx ax,DoublesDl�add ax,Z.LastContent�sub ax,Z.Insert.TokPos
 call ByteLenPut
 mov ScanSi,Z.Insert.TokPos�inc ScanSi
 jmp RaWhile
RaLoop:lodsb RawChar�cmp RawCharAl,QuoteDh�jne @F
 cmp RawChar,QuoteDh�jne @F�inc ScanSi�@@:
 call SymbolsSafe�stosb
RaWhile:cmp ScanSi,Z.LastContent�jbe RaLoop
 jmp StringDone
ByteLenPut:cmp ax,$Limit_Literal�jbe @F
 mov ax,MkMajMin(30,2)
 jmp Raise
@@:stosb�ret
IsRadix:
 push ScanSi; Needed to pick up later scanning.
; RadixTypeDl now 2 for hex ($Xx), 4 for binary ($Bb)
 Assert $OKx / $Xx eq 8
 shl RadixTypeDl,3; Now $OKx $OKb
; Check first and last of content for blanks. (Testing last not strictly...)
 mov ScanSi,Z.Insert.TokPos�inc ScanSi�call TestWhite
; The same loop is used for hex and binary, with parameters:
; To test for valid chars, RadixTypeDl.
; To test for blanks badly placed Z.RadixBadWhite, 1 for Hex, 3 for Bin.
; Contribution of character to result bits ShiftCl, 4 for Hex, 1 for Bin.
; Rounding for chars to bytes, 1 for Hex, 7 for Bin
 mov ax,DigitsCx
 neg cx; To become number of padding bits.
ShiftCl is <cl>
BitsDoneCh is <ch>
 mov BitsDoneCh,cl�cmp RadixTypeDl,$OKx�je SetupX
; Set up parameters for Bit. AX to be length of result.
 mov ShiftCl,1�add ax,7�shr ax,3�mov Z.RadixBadWhite,3�jmp @F
; For Hex.
SetupX:mov ShiftCl,4�add ax,1�shr ax,1�shl BitsDoneCh,2�mov Z.RadixBadWhite,1
@@:and BitsDoneCh,7�call ByteLenPut
; Check the string content which goes from Z.Insert.TokPos+1 to Z.LastContent, with
; the given radix.
; Whitespace is allowed for formatting.
; But not at ends or in middle of nibbles.
; "a b c d" is supposed to give second blank wrong, although we would
; naturally have said first. (Since odd number of digits follow)
 mov Bptr Z.DigitCount+1,80h; Makes it very negative.
AccumDh is <dh>
 z AccumDh
 mov ScanSi,Z.Insert.TokPos�inc ScanSi
 jmp RadWhile
RadLoop:
   lodsb RawChar�mov RawCharAh,RawCharAl�XlatBDLS�jnz NonWhite
   mov Z.Stash,ScanSi
; At first of blanks count will be negative - zero it.
   test Bptr Z.DigitCount+1,80h�jz @F�z Z.DigitCount�@@:
   call TestWhitePos
   jmp RadWhile
NonWhite:jpe BadDigit; Not a letter or digit
   test AttribAl,RadixTypeDl�jz BadDigit; Not good for this radix
   inc Z.DigitCount
; Change Ah to the value for the result.
   cmp RawCharAh,'A'�jb @F�add ah,10-'A'�@@:and ah,15
   shl AccumDh,ShiftCl�add AccumDh,ah�add BitsDoneCh,ShiftCl
   cmp BitsDoneCh,8�jne @F
   mov al,AccumDh�call SymbolsSafe�stosb�z BitsDoneCh
@@:
RadWhile:cmp ScanSi,Z.LastContent�jbe RadLoop
; Test for blank at end.
 dec ScanSi�call TestWhite
StringDone:pop ScanSi; Pushed at IsRadix
 ret; from ProcString

TestWhitePos:
 mov al,Z.RadixBadWhite�test Bptr Z.DigitCount,al�jnz BadWhite�ret
TestWhite:lodsb RawChar�XlatBDLS�jz BadWhite�ret
BadWhite:
 mov ax,MkMajMin(15,1)�sub ScanSi,Z.Insert.TokPos
 dec ScanSi�mov Z.Insert.Position,ScanSi�jmp @F
BadDigit:mov Z.Insert.Char,RawCharAh�mov ax,MkMajMin(15,3)
; Add to error subcode for Binary.
@@:cmp RadixTypeDl,$OKx�je @F�inc ax�@@:jmp Raise

;------------------------------------------------------------------------------
; Note a new line encountered in the source.
; Called with ScanSi positioned after the $Lf
;------------------------------------------------------------------------------
SourceNewLine:
 inc Z.Lines
if 0
; Use this if trouble with line numbers out of step with trace source.
 cmp Z.SerialNow,$SerialSource�jne PreJett
; This variant to dump Lines-v-Cursor
 pusha�push ds�mv ds,ss�mov bx,Z.Stdout�push si�mov ax,Z.Lines�call Ax2DsSiCx
 mov dx,si�mov ah,$DosWrite�int 21h�mov ax,Z.Cursor�mov Z.Radix,16
 call Ax2DsSiCx�mov dx,si�mov ah,$DosWrite�int 21h� pop dx�mov cx,30
 mov ah,$DosWrite�int 21h�mv ds,cs�mov dx,Yshape.CrLf�mov cx,2
 mov ah,$DosWrite�int 21h�pop ds�popa
PreJett:
endif
; Record the file position for deducing columns of other file positions.
  push ScanSi
  sub ScanSi,Zshape.Serial�movzx esi,si; Now offset in buffer.
  add esi,Z.Relative; Add position of buffer as window on the source.
  mov Z.TraceAlign,esi
  pop ScanSi�ret

;------------------------------------------------------------------------------
; Ensure SymbolsEs segment contains di and a few spare.
;------------------------------------------------------------------------------
SymbolsSafe: ; In this case it is ES that addresses the segment.
if Debug
 push ax�mov ax,es�cmp ax,Z.Symbols�pop ax�je @F�int 3�ret�@@:
endif
; Ensures one char beyond di is available.
 cmp di,He.Trigger�jae @F�ret�@@:
 push di�mov SegOffDi,Zshape.Symbols�call MoreSpaceEs�pop di
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
 cmp ScanSi,Z.EndUsedBuffer�jbe @F�dec ScanSi�@@:
; If we already have a $Eof there is no point in reading more. Caller must
; avoid indefinite loop in this case.
 cmp RawChar-1,$Eof�je @F
 cmp ScanSi,Z.NearEnd�jb @F�call SourceSafeX�@@:
 ret

SourceSafe:
  dec ScanSi
SourceSafeX:
  push ax�push dx
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
 mov dx,Z.NearEnd�jmp @B
@@:
; Z.Relative is the offset of the buffer with respect to the source file.
; Update it to the section we want now.
 movzx edx,dx�add Z.Relative,edx�mov al,$SerialSource�call Serialize
; Serialize read to Z.Serial but did not alter ScanSi
 sub ScanSi,dx; Leaving it pointing to the same character as before.
 sub Z.Insert.TokPos,dx
 pop dx�pop ax�ret

 end
