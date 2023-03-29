# Syntax constructs
## Notation
### Backus-Naur Form (BNF)
The syntax constructs in this standard are defined in Backus-Naur Form (BNF). The syntax used in these
BNF productions has

- a left-hand side (called identifier);

- the characters ':=";

- a right-hand side (called bnf_expression).
The left-hand side identifies syntactic constructs. The right-hand side describes valid ways of writing a
specific syntactic construct.
The right-hand side consists of operands and operators, and may be grouped.
### Operands
Operands may be terminals or non-terminals. If an operand appears as identifier in some other
production it is called a non-terminal, otherwise it is called a terminal. Terminals are either literal or
symbolic.
Literal terminals are enclosed in quotes and represent literally (apart from case) what must be present in
the source being described.
Symbolic terminals formed with lower case characters represent something which the configuration may,
or may not, allow in the source program, see nnn, nnn, nnn, nnn.
Symbolic terminals formed with uppercase characters represent events and tokens, see nnn and nnn.
### Operators
The following lists the valid operators, their meaning, and their precedence; the operator listed first has
the highest precedence; apart from precedence recognition is from left to right:

- the postfix plus operator specifies one or more repetitions of the preceding construct;

- abuttal specifies that the preceding and the following construct must appear in the given order;

- the operator '|' specifies alternatives between the preceding and the following constructs.
### Grouping
Parentheses and square brackets are used to group constructs. Parentheses are used for the purpose of
grouping only. Square brackets specify that the enclosed construct is optional.
### BNF syntax definition
The BNF syntax, described in BNF, is:

production := identifier ':=' bnf expression

bnf expression t= abuttal | bnf expression '|' abuttal

abuttal t= [abuttal] bnf primary

bnf primary := '[T' bnf expression ']' | '(' bnf expression ')' | literal |

identifier | message identifier | bnf primary '+'
### Syntactic errors
The syntax descriptions (see nnn and nnn) make use of message_identifiers which are shown as
Msgnn.nn or Msgnn, where nn is a number. These actions produce the correspondingly numbered error
messages (see nnn and nnn).
## Lexical
The lexical level processes the source and provides tokens for further recognition by the top syntax level.
### Lexical elements
#### Events
The fully-capitalized identifiers in the BNF syntax (see nnn) represent events. An event is either supplied
by the configuration or occurs as result of a look-ahead in left-to-right parsing. The following events are
defined:
- EOL occurs at the end of a line of the source. It is provided by Config_SourceChar, see nnn;
- EOS occurs at the end of the source program. It is provided by Config_SourceChar;
- RADIX occurs when the character about to be scanned is 'X' or 'x' or 'B' or ‘b' not followed by a
general_letter, or a digit, or'.';
- CONTINUE occurs when the character about to be scanned is ',', and the characters after the ',’ up
to EOL represent a repetition of comment or blank, and the EOL is not immediately followed by an
EOS;

- EXPONENT_SIGN occurs when the character about to be scanned is '+' or '-', and the characters to
the left of the sign, currently parsed as part of Const_symbol, represent a plain_number followed by 'E'
or 'e’, and the characters to the right of the sign represent a repetition of digit not followed by a
general_letter or'.’.
- | would put ASSIGN here for the leftmost '=' in a clause that is not within parentheses or brackets. But Simon not
happy with message term being an assignment?
#### Actions and tokens
Mixed case identifiers with an initial capital letter cause an action when they appear as operands ina
production. These actions perform further tests and create tokens for use by the top syntax level. The
following actions are defined:
- Special supplies the source recognized as special to the top syntax level;
- Eol supplies a semicolon to the top syntax level;
- Eos supplies an end of source indication to the top syntax level;
- Var_symbol supplies the source recognized as Var_symbol to the top syntax level, as keywords or
VAR_SYMBOL tokens, see nnn. The characters in a Var_symbol are converted by Config_Upper to
uppercase. Msg30.1 shall be produced if Var_symbo/ contains more than #Limit_Name characters,
see nnn;
- Const_symbol supplies the source recognized as Const_symbo! to the top syntax level. If itis a
number it is passed as a NUMBER token, otherwise it is passed as a CONST_SYMBOL token. The
characters in a Const_symbol are converted by Config_Upper to become the characters that comprise
that NUMBER or CONST_SYMBOL. Msg30.1 shall be produced if Const_symbo! contains more than
#Limit_Name characters;
- Embedded_quotation_mark records an occurrence of two consecutive quotation marks within a
string delimited by quotation marks for further processing by the String action;
- Embedded_apostrophe records an occurrence of two consecutive apostrophes within a string
delimited by apostrophes for further processing by the String action;
- String supplies the source recognized as String to the top syntax level as a STRING token. Any
occurrence of Embedded_quotation_mark or Embedded_apostrophe is replaced by a single quotation
mark or apostrophe, respectively. Msg30.2 shall be produced if the resulting string contains more than
#Limit_Literal characters;
- Binary_string supplies the converted binary string to the top syntax level as a STRING token, after
checking conformance to the binary_string syntax. If the binary_string does not contain any
occurrence of a binary_digit, a string of length 0 is passed to the top syntax level. The occurrences of
binary_digit are concatenated to form a number in radix 2. Zero or 4 digits are added at the left if
necessary to make the number of digits a multiple of 8. If the resulting number of digits exceeds 8
times #Limit_Literal then Msg30.2 shall be produced. The binary digits are converted to an encoding,
see nnn. The encoding is supplied to the top syntax level as a STRING token;
- Hex_string supplies the converted hexadecimal string to the top syntax level as a STRING token,
after checking conformance to the hex_string syntax. If the hex_string does not contain any
occurrence of a hex_digit, a string of length 0 is passed to the top syntax level. The occurrences of
hex_digit are each converted to a number with four binary digits and concatenated. 0 to 7 digits are
added at the left if necessary to make the number of digits a multiple of 8. If the resulting number of
digits exceeds 8 times #Limit_Literal then Msg30.2 shall be produced. The binary digits are converted
to an encoding. The encoding is supplied to the top syntax level as a STRING token;
- Operator supplies the source recognized as Operator (excluding characters that are not
operator_char ) to the top syntax level. Any occurrence of an ofher_negator within Operator is
supplied as ‘\';
- Blank records the presence of a blank. This may subsequently be tested (see nnn).
Constructions of type Number, Const_symbol, Var_symbol or String are called operands.
6.2.1.3 Source characters
The source is obtained from the configuration by the use of Config_SourceChar (see nnn). If no character
is available because the source is not a correct encoding of characters, message Msg22.1 shall be
produced.
The terms extra_letter, other_blank_character, other_negator, and other_character used in the
productions of the lexical level refer to characters of the groups extra_letters (see nnn),

other_blank_characters (see nnn), other_negators (see nnn) and other_characters (see nnn),
respectively.
#### Rules
In scanning, recognition that causes an action (see nnn) only occurs if no other recognition is possible,
except that Embedded_apostrophe and Embedded_quotation_mark actions occur wherever possible.
###Lexical level
### Interaction between levels of syntax
When the lexical process recognizes tokens to be supplied to the top level, there can be changes made
or tokens added. Recognition is performed by the lexical process and the top level process ina
synchronized way. The tokens produced by the lexical level can be affected by what the top level syntax
has recognized. Those tokens will affect subsequent recognition by the top level. Both processes operate
on the characters and the tokens in the order they are produced. The term "context" refers to the
progress of the recognition at some point, without consideration of unprocessed characters and tokens.
If a token which is '+', '-', \' or '(' appears in a lexical level context (other than after the keyword 'PARSE')
where the keyword 'VALUE' could appear in the corresponding top level context, then 'VALUE' is passed
to the top level before the token is passed.
If an '=' operator_char appears in a lexical level context where it could be the '=' of an assignment or
message_instruction in the corresponding top level context then it is recognized as the '="' of that
instruction. (It will be outside of brackets and parentheses, and any Var_symbo/ immediately preceding it
is passed as a VAR_SYMBOL). If an operand is followed by a colon token in the lexical level context then
the operand only is passed to the top level syntax as a LABEL, provided the context permits a LABEL.
Except where the rules above determine the token passed, a Var_symbol is passed as a terminal (a
keyword) rather than as a VAR_SYMBOL under the following circumstances:
- if the symbol is spelled 'WHILE' or 'UNTIL' it is a keyword wherever a VAR_SYMBOL would be part
of an expression within a do_specification,
- if the symbol is spelled 'TO' , ‘BY’, or 'FOR' it is a keyword wherever a VAR_SYMBOL would be part
of an expression within a do_rep;
- if the symbol is spelled 'WITH' it is a keyword wherever a VAR_SYMBOL would be part of a
parsevalue, or part of an expression or taken_constant within address;
- if the symbol is spelled 'THEN' it is keyword wherever a VAR_SYMBOL would be part of an
expression immediately following the keyword 'IF' or 'WHEN'.
Except where the rules above determine the token passed, a Var_symbol is passed as a keyword if the
spelling of it matches a keyword which the top level syntax recognizes in its current context, otherwise the
Var_symbol is passed as a VAR_SYMBOL token.
In a context where the top level syntax could accept a '||' token as the next token, a'||' operator ora''
operator may be inferred and passed to the top level provided that the next token from the lexical level is
a left parenthesis or an operand that is not a keyword. If the blank action has recorded the presence of
one or more blanks to the left of the next token then the '' operator is inferred. Otherwise, a'||' operator is
inferred, except if the next token is a left parenthesis following an operand (see nnn); in this case no
operator is inferred.
When any of the keywords ‘OTHERWISE’, 'THEN', or ‘ELSE’ is recognized, a semicolon token is supplied
as the following token. A semicolon token is supplied as the previous token when the 'THEN' keyword is
recognized. A semicolon token is supplied as the token following a LABEL.
#### Reserved symbols
A Const_symbol which starts with a period and is not a Number shall be spelled .MN, .RESULT, .RC,
.RS, or .SIGL otherwise Msg50.1 is issued.
#### Function name syntax
A symbol which is the leftmost component of a function shall not end with a period, otherwise Msg51.1 is
issued.
## Syntax
### Syntax elements
The tokens generated by the actions described in nnn form the basis for recognizing larger constructs.
### Syntax level

starter:=x3j18

x3j18:=program Eos | Msg35.1

program := [label list] [ncl] [requires+] [prolog_instruction+]
(class definition [requires+])+
requires :=  'REQUIRES' ( taken constant | Mgg19.8 ) '";'+
prolog instruction:= (package | import | options) nel
package = 'PACKAGE'( NAME | Msgnn )
import = 'IMPORT' ( NAME | Msgnn ) ['.']
options := 'OPTIONS' ( symbol+ | Msgnn )
nel := null _clause+ | Msg21.1
null clause = ';' [label list]
label list = (LABEL ';')+
class definition = class [property info] [method definition+]
class = 'CLASS' ( taken constant | Msg19.12 ) [class_option+]

['INHERIT' ( taken constant | Msg19.13 )+] nel
visibility | modifier | 'BINARY' | 'DEPRECATED'
'EXTENDS' ( NAME | Msgnn )
'USES' ( NAMElist | Msgnn )
| 'IMPLEMENTS' ( NAMElist | Msgnn )

class option

numeric digits:= 'DIGITS' [expression]

| external | metaclass | submix /* | 'PUBLIC! */
external = 'EXTERNAL' (STRING | Msg19.14)
metaclass = 'METACLASS' ( taken constant | Msg19.15 )
submix = 'MIXINCLASS' ( taken constant | Msg19.16 )
| 'SUBCLASS' ( taken constant | Msg19.17 )
visibility = 'PUBLIC' | 'PRIVATE'
modifier = 'ABSTRACT' | 'FINAL' | 'INTERFACE' | 'ADAPTER'!
NAMElist = NAME [(',' ( NAME | Msgnn ) )+]
property _info = numeric | property assignment | properties | trace
numeric = 'NUMERIC' (numeric digits | numeric form | Msg25.15)
numeric form = 'FORM' ['ENGINEERING' | 'SCIENTIFIC']
property agsignment := NAME | assignment
properties := 'PROPERTIES' ( properties option+ | Msgnn)
properties option := properties vigibility | properties modifier
properties visibility := 'INHERITABLE' | 'PRIVATE' | 'PUBLIC' |
'INDIRECT'
properties modifier := 'CONSTANT' | 'STATIC' | 'VOLATILE' | 'TRANSIENT'
trace := 'TRACE' ['ALL' | 'METHODS' | 'OFF' | 'RESULTS']
method definition = (method [expose ncl]| routine)
balanced
expose = 'EXPOSE' variable list
method = 'METHOD' (taken constant | Msg19.9)
[ '(' assigncommalist | Msgnn ( ')' | Msgnn )]
[method option+] nel
assigncommalist assignment [(',' ( assignment | Msgnn ) )+]

method visibility | method modifier | 'PROTECT'
| 'RETURNS' ( term | Msgnn )
| 'SIGNAL' ( termcommalist | Msgnn )

method option

‘DEPRECATED '!
'CLASS' | 'ATTRIBUTE' | /*'PRIVATE' | */ guarded
guarded := 'GUARDED' | 'UNGUARDED!
method visibility := 'INHERITABLE' | 'PRIVATE' | 'PUBLIC' | 'SHARED!'
method modifier := 'ABSTRACT' | 'CONSTANT' | 'FINAL' | 'NATIVE' |
'STATIC'
termcommalist := term [(',' ( term | Msgnn ) )+]
routine := 'ROUTINE' ( taken constant | Msg19.11 ) ['PUBLIC'] nel
balanced:= instruction list ['END' Msgl0.1]
instruction list:= instruction+

/* The second part ig about groups */

instruction = group | gingle instruction nel
group = do ncl | if | loop nel | select nel
do = do specification nel [instruction+] [group_handler]
('END' [NAME] | Eos Msg14.1 | Msg35.1)
group option := 'LABEL' ( NAME | Msgnn ) | 'PROTECT' ( term | Msgnn )

group handler catch | finally catch finally

|
'CATCH' [ NAME '=' ] ( NAME | Msgnn) nel [instruction+]

catch =
/* FINALLY implies a semicolon. */
finally = 'FINALLY' nel ( instruction+ | Msgnn )
if := 'IF' expression [ncl] (then | Msg18.1)
[else]
then := 'THEN' nel
(instruction | EOS Msg14.3 | 'END' Msg10.5)
else := 'ELSE' nel
(instruction | EOS Msg14.4 | 'END' Msg10.6)
loop := 'LOOP' [group_option+] [repetitor] [conditional] nel

instruction+ [group_handler]
loop ending

loop ending 'END' [VAR SYMBOL] | EOS Msg14.n | Msg35.1

conditional = 'WHILE' whileexpr | 'UNTIL' untilexpr
untilexpr = expression
whileexpr = expression
repetitor = assignment [count option+] | expression | over
'FOREVER'
count option = loopt | loopb | loopf
loopt = 'TO' expression
loopb = 'BY' expression
loopf = 'FOR' expression
over = VAR SYMBOL 'OVER' expression

| NUMBER 'OVER' Msg31.1
| CONST SYMBOL 'OVER' (Msg31.2 | Msg31.3)

select := 'SELECT' [group option+] ncl select _ body [group_handler]
('END' [NAME Msg10.4] | EOS Msgl14.2 | Msg7.2)

(when | Msg7.1) [when+] [otherwise]

'WHEN' expresgion [ncl] (then | Msg18.2)

'OTHERWISE' ncl [instruction+]

select body
when
otherwise

/* Third part is for single instructions. */
single instruction:= assignment | message instruction | keyword instruction
| command
assignment := VAR SYMBOL '#' expression
NUMBER '#' Msg31.1
CONST SYMBOL '#!' (Msg31.2 | Mgg31.3)

message instruction := message term | message term '#' expression
keyword instruction:= address | arg | call | drop | exit
interpret | iterate | leave

nop | numeric | options
parse | procedure | pull | push | queue

raise | reply | return | say | signal | trace | use
'THEN' Msg8.1 'ELSE' Msg8.2
'WHEN' Msg9.1 | 'OTHERWISE' Msg9.2
command = expression
address = 'ADDRESS' [(taken constant [expression]

| Msg19.1 | valueexp) [ 'WITH' connection] ]

taken constant symbol | STRING

valueexp = 'VALUE' expression
connection = ad option+
ad option = error | input | output | Msg25.5
error = 'ERROR!' (resourceo | Msg25.14)
input = 'INPUT' (resourcei | Msg25.6)
resourcei := resources | 'NORMAL'
output = 'OUTPUT' (resourceo | Mgg25.7)
resourceo := 'APPEND' (resources | Msg25.8)
| 'REPLACE' (resources | Msg25.9)
| resources | 'NORMAL'
resources := 'STREAM' (VAR_SYMBOL | Msg53.1)
| 'STEM' (VAR_SYMBOL | Msg53.2)
vref := '(' var symbol (')' | Msg46.1)
var symbol = VAR_SYMBOL | Msg20.1

arg := 'ARG' [template list]

eall := 'CALL' (callon_spec |
(taken constant | vref | Msg19.2) [expression list] )
callon spec := 'ON' (callable condition | Msg25.1)

['NAME' (symbol constant term | Msg19.3)]
| 'OFF' (callable condition | Msg25.2)

symbol constant term := term

callable condition:= 'ANY' | 'ERROR' | 'FAILURE' | 'HALT' | 'NOTREADY'
| 'USER' ( symbol constant term | Msg19.18 )

condition := callable condition | 'LOSTDIGITS'
| 'NOMETHOD' | 'NOSTRING' | 'NOVALUE' | 'SYNTAX!

expression list
do specification
do simple

expr | [expr] ',' [expression list]
do simple | do repetitive
'DO' [group_option+]

do repetitive = do simple (dorep | conditional | dorep conditional)
dorep = 'FOREVER' | repetitor
drop = 'DROP' variable list
variable list = (vref | var_symbol)+
exit = 'EXIT' [expression]
forward = 'FORWARD' [forward _option+ | Msg25.18]
forward option = 'CONTINUE' | ArrayArgOption |
MessageOption | ClassOption | ToOption
ArrayArgOption:='ARRAY' arguments | ‘ARGUMENTS' term
MessageOption :='MESSAGE' term
ClassOption ='CLASS' term
ToOption ='TO' term
guard = 'GUARD' ('ON' | Msg25.22) [('WHEN' | Msg25.21)
expression]
| ( 'OFF' | Msg25.19) [('WHEN' | Msg25.21)
expression]
interpret = 'INTERPRET' expression
iterate = 'ITERATE' [VAR SYMBOL | Msg20.2]
leave = 'LEAVE' [VAR SYMBOL | Msg20.2]
nop = 'NOP!'
numeric = 'NUMERIC' (numeric digits | numeric form

| numeric fuzz | Msg25.15)
numeric digits 'DIGITS' [expression]
numeric form 'FORM' [numeric form suffix]
numeric form suffix:=('ENGINEERING' |'SCIENTIFIC'|valueexp | Msg25.11)
numeric fuzz 'FUZZ' [expression]

options = 'OPTIONS' expression
parse = 'PARSE' [translations] (parse type
|Msg25.12) [template list]
translations := 'CASELESS' ['UPPER' | 'LOWER']
| ('UPPER' | 'LOWER') ['CASELESS']
parse type = parse key | parse value | parse var | term
parse key = 'ARG' | 'PULL' | 'SOURCE' | 'LINEIN'
| 'VERSION!
parse value = 'VALUE' [expression] ('WITH' | Mgg38.3)
parse var = 'VAR' var symbol
template := NAME [( [pattern] NAME) +]
pattern:= STRING | [indicator] NUMBER | [indicator] '(' symbol ')'
indicator := '+' | '-' | 's!
procedure = 'PROCEDURE' [expose | Msg25.17]
pull = 'PULL' [template list]
push = 'PUSH' [expression]
queue = 'QUEUE' [expression]
raise = 'RAISE' conditions (raise option | Msg25.24)
conditions = 'ANY' | 'ERROR' term | 'FAILURE' term
| 'HALT'| 'LOSTDIGITS' | 'NOMETHOD' | 'NOSTRING' |
"NOTREADY'
| 'NOVALUE' | 'PROPAGATE' | 'SYNTAX' term
| 'USER' ( symbol constant term | Msg19.18) | Msg25.23
raise option := ExitRetOption | Description | ArrayOption

ExitRetOption := 'EXIT! [term] | 'RETURN' [term]
Description ='DESCRIPTION' term
ArrayOption = 'ADDITIONAL' term | "'ARRAY' arguments
reply = 'REPLY' [ expression]
return = 'RETURN' [expression]
say = 'SAY' [expression]
signal = 'SIGNAL' (signal spec | valueexp

| symbol constant term | Msg19.4)

signal spec := 'ON' (condition | Msg25.3)
['NAME' (symbol constant term | Msg19.3)]
| 'OFF' (condition | Msg25.4)

trace = 'TRACE' [(taken_constant | Msgl19.6) | valueexp]
use = 'USE' ('ARG' | Msg25.26) [use list]
use list = VAR_SYMBOL | [VAR SYMBOL] ',' [use list]

/* Note: The next part describes templates. */
template list template | [template] ',' [template list]

template = (trigger | target | Msg38.1)+
target = VAR_SYMBOL | '.!'
trigger = pattern | positional
pattern = STRING | vrefp
vrefp = '(' (VAR_SYMBOL | Msgl19.7) (')' | Msg46.1)
positional = absolute positional | relative positional
absolute positional:= NUMBER '=' position
pogition := NUMBER | vrefp | Msg38.2
relative posgitional:= ('+' | '-"') position

/* Note: The final part specifies the various forms of symbol, and
expression. */

symbol = VAR_SYMBOL | CONST SYMBOL | NUMBER
expression = expr [(',' Msg37.1) | (')' Msg37.2 )]
expr = expr alias

expr alias and expression

| expr alias or operator and expression

or operator := '|' | '&&!
and expression := comparison | and expression '&' comparison
comparison := concatenation
| comparison comparison operator concatenation
comparison _operator:= normal compare | strict compare
normal compare:= '=! | "\s! | hep! | tact | tot | tet | toet
len! W\>! \<!
strict_compare:= '==' | '\s=' | '>>!' | '<<!' | '>>e! | '<<s!
| '"\e>t | '\<c!
concatenation := addition
| concatenation (' ' | '||') addition
addition := multiplication
| addition additive operator multiplication
additive operator:= '+' | '-!
multiplication t= power expression

| multiplication multiplicative operator
power expression
multiplicative operator:= '*' | '/' | '//' | '%!
power expression := prefix expression
| power expression '**' prefix expression
prefix expression := ('+' | '-' | '\') prefix expression
term | Msg35.1
/* "Stub" has to be identified semantically? */

term = simple term [ '.' ( term | Msgnn )]
simple term := symbol | STRING | invoke | indexed
'(' expression ( ')' | Msg36 )
initializer
| message term '##!
message term:= term ('~' | '~~') method name [arguments]
term '['[ expression list ] (']' | Msg36.2)

42
method name:=(taken constant | Msg19.19)
[':' ( VAR_SYMBOL | Msg19.21 )]
/* Method-call without arguments ig syntactically like symbol. */
/* Editor - not sure of my notes about here. */

invoke := (symbol | STRING) arguments
arguments := '#(' [expression list] (')' | Meg36)
expression list := expregsion | [expression] ',' [expression list]
indexed = (symbol | STRING) indices
indices = '#[' [expression list] (']' | Msg36.n)
initializer = '['expression list (']' | Msg36.n)

## Syntactic information
### VAR_SYMBOL matching
Any VAR_SYMBOL in a do_ending must be matched by the same VAR_SYMBOL occurring at the start
of an assignment contained in the do_specification of the do that contains both the do_specification and
the do_ending, as described in nnn.
If there is a VAR_SYMBOL in a do_ending for which there is no assignment in the corresponding
do_specification then message Msg10.3 is produced and no further activity is defined.
If there is a VAR_SYMBOL in a do_ending which does not match the one occurring in the assignment
then message Msg10.2 is produced and no further activity is defined.
An iterate or leave must be contained in the instruction_list of some do with a do_specification which is
do_repetitive, otherwise a message (Msg28.2 or Msg28.1 respectively) is produced and no further activity
is defined.
If an iterate or leave contains a VAR_SYMBOL there must be a matching VAR_SYMBOL ina
do_specification, otherwise a message (Msg28.1, Msg28.2, Msg28.3 or Msg28.4 appropriately) is
produced and no further activity is defined. The matching VAR_SYMBOL will occur at the start of an
assignment in the do_specification. Tne do_specification will be associated with a do by nnn. The /ferafe
or leave will be a single instruction in an instruction_list associated with a do by nnn. These two dos shall
be the same, or the latter nested one or more levels within the former. The number of levels is called the
nesting_correction and influences the semantics of the iterafe or leave. It is zero if the two dos are the
same. The nesting_correction for /ferates or leaves that do not contain VAR_SYMBOL is zero.
### Trace-only labels
Instances of LABEL which occur within a grouping_instruction and are not in a nc/ at the end of that
grouping_instruction are instances of trace-only labels.
### Clauses and line numbers
The activity of tracing execution is defined in terms of clauses. A program consists of clauses, each
clause ended by a semicolon special token. The semicolon may be explicit in the program or inferred.
The line number of a clause is one more than the number of EOL events recognized before the first token
of the clause was recognized.
### Nested IF instructions
The syntax specification nnn allows 'IF' instructions to be nested and does not fully specify the
association of an 'ELSE' keyword with an 'IF' keyword. An 'ELSE' associates with the closest prior 'IF' that
it can associate with in conformance with the syntax.
### Choice of messages
The specifications nnn and nnn permit two alternative messages in some circumstances. The following
rules apply:
- Msg15.1 shall be preferred to Msg15.3 if the choice of Msg15.3 would result in the replacement for
the insertion being a blank character;
- Msg15.2 shall be preferred to Msg15.4 if the choice of Msg15.4 would result in the replacement for
the insertion being a blank character;
- Msg31.3 shall be preferred to Msg31.2 if the replacement for the insertion in the message starts with
a period;
- Preference is given to the message that appears later in the list: Msg21.1, Msg27.1, Msg25.16,
Msg36, Msg38.3, Msg35.1, other messages.
### Creation of messages
The message_identifiers in clause 6 correlate with the tails of stem #ErrorText., which is initialized in nnn
to identify particular messages. The action of producing an error message will replace any insertions in
the message text and present the resulting text, together with information on the origin of the error, to the
configuration by writing on the default error stream.
Further activity by the language processor is permitted, but not defined by this standard.
The effect of an error during the writing of an error message is not defined.
#### Error message prefix
The error message selected by the message number is preceded by a prefix. The text of the prefix is
#ErrorText.0.1 except when the error is in source that execution of an interactive trace interpret
instruction (see nnn) is processing, in which case the text is #ErrorText.0.2. The insert called <value> in
these texts is the message number. The insert called <linenumber> is the line number of the error.
The line number of the error is one more than the number of EOL events encountered before the error
was detectable, except for messages Msg6.1, Msg14, Msg14.1, Msg14.2, Msg14.3, and Msg14.4. For
Msg6.1 it is one more than the number of EOL events encountered before the line containing the
unmatched '/*'. For the others, it is the line number of the clause containing the keyword referenced in
the message text.
The insert called <source> is the value provided on the API_ Start function which started processing of the
program, see nnn.
## Replacement of insertions
Within the text of error messages, an insertion consists of the characters '<', '>', and what is between
those characters. There will be a word in the insertion that specifies the replacement text, with the
following meaning:
- if the word is 'hex-encoding' and the message is not Msg23.1 then the replacement text is the value
of the leftmost character which caused the source to be syntactically incorrect. The value is in
hexadecimal notation;
- if the word is 'token' then the replacement text is the part of the source program which was
recognized as the detection token, or in the case of Msg31.1 and Msg31.2, the token before the
detection token.
The detection token is the leftmost token for which the program up to and including the token could
not be parsed as the left part of a program without causing a message. If the detection token is a
semicolon that was not present in the source but was supplied during recognition then the
replacement is the previous token;
- if the word is ‘position’ then the replacement text is a number identifying the detection character. The
detection character is the leftmost character in the hex_string or binary_string which did not match the
required syntax. The number is a count of the characters in the string which preceded the detection
character, including the initial quote or apostrophe. In deciding the leftmost blank in a quoted string of
radix 'X' or 'B' that is erroneous not that:
A blank as the first character of the quoted string is an error.
The leftmost embedded sequence of blanks can validly follow any number of non-blank characters.
Otherwise a blank run that follows an odd numbered sequence of non-blanks (or a number not a
multiple of four in the case of radix 'B’) is not valid.
If the string is invalid for a reason not described above, the leftmost blank of the rightmost sequence of
blanks is the invalid blank to be referenced in the message;
- if the word is 'char' then the replacement text is the detection character;
- if the word is ‘linenumber' then the replacement text is the line number of a clause associated with
the error. The wording of the message text specifies which clause that is;
- if the word is 'keywords' then the replacement text is a list of the keywords that the syntax would
allow at the context where the error occurred. If there are two keywords they shall be separated by the
four characters ' or '. If more, the last shall be preceded by the three characters 'or' and the others
shall be followed by the two characters ','. The keywords will be uppercased and in alphabetical
order.

Replacement text is truncated to #Limit_Messagelnsert characters if it would otherwise be longer than
that, except for a keywords replacement. When an insert is both truncated and appears within quotes in
the message, the three characters '...' are inserted in the message after the trailing quote.

## Syntactic equivalence

If a message_term contains a '[' it is regarded as an equivalent message_term without a '[', for execution.
The equivalent is term~'[]'(expression_list). See nnn. If a message_instruction has the construction
message_term '=' expression it is regarded as equivalent to a message_term with the same components
as the message_term left of the '=', except that the taken_constant has an '=' character appended and
arguments has the expression from the right of the '=' as an extra first argument. See nnn.
