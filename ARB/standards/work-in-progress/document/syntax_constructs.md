# Syntax constructs

## Notation

### Backus-Naur Form (BNF)

The syntax constructs in this standard are defined in Backus-Naur Form (BNF). The syntax used in these
BNF productions has

- a left-hand side (called _identifier_);

- the characters `':="`;

- a right-hand side (called _bnf_expression_).

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

- the operator `'|'` specifies alternatives between the preceding and the following constructs.

### Grouping

Parentheses and square brackets are used to group constructs. Parentheses are used for the purpose of
grouping only. Square brackets specify that the enclosed construct is optional.

### BNF syntax definition

The BNF syntax, described in BNF, is:

```rexx <!--ebnfgrouping.ebnf-->
production  :=    identifier ':=' bnf_expression
bnf_expression    := abuttal | bnf_expression '|' abuttal
abuttal     :=    [abuttal] bnf primary
bnf_primary :=    '[' bnf expression ']' | '(' bnf expression ')' | literal |
identifier | message identifier | bnf primary '+'
```

### Syntactic errors

The syntax descriptions (see nnn and nnn) make use of _message_identifiers_ which are shown as
_Msgnn.nn_ or _Msgnn_, where _nn_ is a number. These actions produce the correspondingly numbered error
messages (see nnn and nnn).

## Lexical

The lexical level processes the source and provides tokens for further recognition by the top syntax level.

### Lexical elements

#### Events

The fully-capitalized identifiers in the BNF syntax (see nnn) represent events. An event is either supplied
by the configuration or occurs as result of a look-ahead in left-to-right parsing. The following events are
defined:

- _EOL_ occurs at the end of a line of the source. It is provided by `Config_SourceChar`, see nnn;

- _EOS_ occurs at the end of the source program. It is provided by `Config_SourceChar`;

- _RADIX_ occurs when the character about to be scanned is `'X'` or `'x'` or `'B'` or `'b'` not followed by a _general_letter_, or a _digit_, or `'.'`;

- _CONTINUE_ occurs when the character about to be scanned is `','`, and the characters after the `','` up
to _EOL_ represent a repetition of _comment_ or _blank_, and the _EOL_ is not immediately followed by an
_EOS_;

- _EXPONENT_SIGN_ occurs when the character about to be scanned is `'+'` or `'-'`, and the characters to
the left of the sign, currently parsed as part of _Const_symbol_, represent a _plain_number_ followed by `'E'`
or `'e'`, and the characters to the right of the sign represent a repetition of _digit_ not followed by a
_general_letter_ or `'.'`.

_- I would put _ASSIGN_ here for the leftmost `'='` in a clause that is not within parentheses or brackets. But Simon not
happy with message term being an assignment?_

#### Actions and tokens

Mixed case identifiers with an initial capital letter cause an action when they appear as operands ina
production. These actions perform further tests and create tokens for use by the top syntax level. The
following actions are defined:

- _Special_ supplies the source recognized as _special_ to the top syntax level;

- _Eol_ supplies a semicolon to the top syntax level;

- _Eos_ supplies an end of source indication to the top syntax level;

- _Var_symbol_ supplies the source recognized as _Var_symbol_ to the top syntax level, as keywords or
  _VAR_SYMBOL_ tokens, see nnn. The characters in a _Var_symbol_ are converted by `Config_Upper` to
  uppercase. _Msg30.1_ shall be produced if _Var_symbol_ contains more than `#Limit_Name` characters,
  see nnn;

- _Const_symbol_ supplies the source recognized as _Const_symbol_ to the top syntax level. If it is a
  number it is passed as a _NUMBER_ token, otherwise it is passed as a _CONST_SYMBOL_ token. The
  characters in a _Const_symbol_ are converted by `Config_Upper` to become the characters that comprise
  that _NUMBER_ or _CONST_SYMBOL_. _Msg30.1_ shall be produced if _Const_symbol_ contains more than
  `#Limit_Name` characters;

- _Embedded_quotation_mark_ records an occurrence of two consecutive quotation marks within a
  string delimited by quotation marks for further processing by the _String_ action;

- _Embedded_apostrophe_ records an occurrence of two consecutive apostrophes within a string
  delimited by apostrophes for further processing by the _String_ action;

- _String_ supplies the source recognized as _String_ to the top syntax level as a _STRING_ token. Any
  occurrence of _Embedded_quotation_mark_ or _Embedded_apostrophe_ is replaced by a single quotation
  mark or apostrophe, respectively. _Msg30.2_ shall be produced if the resulting string contains more than
  `#Limit_Literal` characters;

- _Binary_string_ supplies the converted binary string to the top syntax level as a _STRING_ token, after
  checking conformance to the _binary_string_ syntax. If the _binary_string_ does not contain any
  occurrence of a _binary_digit_, a string of length 0 is passed to the top syntax level. The occurrences of
  _binary_digit_ are concatenated to form a number in radix 2. Zero or 4 digits are added at the left if
  necessary to make the number of digits a multiple of 8. If the resulting number of digits exceeds 8
  times `#Limit_Literal` then _Msg30.2_ shall be produced. The binary digits are converted to an encoding,
  see nnn. The encoding is supplied to the top syntax level as a _STRING_ token;

- _Hex_string_ supplies the converted hexadecimal string to the top syntax level as a _STRING_ token,
  after checking conformance to the _hex_string_ syntax. If the _hex_string_ does not contain any
  occurrence of a _hex_digit_, a string of length 0 is passed to the top syntax level. The occurrences of
  _hex_digit_ are each converted to a number with four binary digits and concatenated. 0 to 7 digits are
  added at the left if necessary to make the number of digits a multiple of 8. If the resulting number of
  digits exceeds 8 times `#Limit_Literal` then _Msg30.2_ shall be produced. The binary digits are converted
  to an encoding. The encoding is supplied to the top syntax level as a _STRING_ token;

- _Operator_ supplies the source recognized as _Operator_ (excluding characters that are not
  _operator_char_ ) to the top syntax level. Any occurrence of an _other_negator_ within _Operator_ is
  supplied as `'\'`;

- _Blank_ records the presence of a blank. This may subsequently be tested (see nnn).
  
Constructions of type _Number_, _Const_symbol_, _Var_symbol_ or _String_ are called operands.

#### Source characters

The source is obtained from the configuration by the use of `Config_SourceChar` (see nnn). If no character
is available because the source is not a correct encoding of characters, message _Msg22.1_ shall be
produced.

The terms _extra_letter_, _other_blank_character_, _other_negator_, and _other_character_ used in the
productions of the lexical level refer to characters of the groups _extra_letters_ (see nnn),
_other_blank_characters_ (see nnn), _other_negators_ (see nnn) and _other_characters_ (see nnn),
respectively.

#### Rules

In scanning, recognition that causes an action (see nnn) only occurs if no other recognition is possible,
except that _Embedded_apostrophe_ and _Embedded_quotation_mark_ actions occur wherever possible.

### Lexical level

### Interaction between levels of syntax
When the lexical process recognizes tokens to be supplied to the top level, there can be changes made
or tokens added. Recognition is performed by the lexical process and the top level process in a
synchronized way. The tokens produced by the lexical level can be affected by what the top level syntax
has recognized. Those tokens will affect subsequent recognition by the top level. Both processes operate
on the characters and the tokens in the order they are produced. The term "context" refers to the
progress of the recognition at some point, without consideration of unprocessed characters and tokens.

If a token which is `'+'`, `'-'`, `'\'` or `'('` appears in a lexical level context (other than after the keyword `'PARSE'`)
where the keyword `'VALUE'` could appear in the corresponding top level context, then `'VALUE'` is passed
to the top level before the token is passed.

If an `'='` _operator_char_ appears in a lexical level context where it could be the `'='` of an _assignment_ or
_message_instruction_ in the corresponding top level context then it is recognized as the `'='` of that
instruction. (It will be outside of brackets and parentheses, and any _Var_symbol_ immediately preceding it
is passed as a _VAR_SYMBOL_). If an operand is followed by a colon token in the lexical level context then
the operand only is passed to the top level syntax as a _LABEL_, provided the context permits a _LABEL_.

Except where the rules above determine the token passed, a _Var_symbol_ is passed as a terminal (a
keyword) rather than as a _VAR_SYMBOL_ under the following circumstances:

- if the symbol is spelled `'WHILE'` or `'UNTIL'` it is a keyword wherever a _VAR_SYMBOL_ would be part
  of an expression within a _do_specification_,

- if the symbol is spelled `'TO'`, `'BY'`, or `'FOR'` it is a keyword wherever a _VAR_SYMBOL_ would be part
  of an expression within a _do_rep_;

- if the symbol is spelled `'WITH'` it is a keyword wherever a _VAR_SYMBOL_ would be part of a
  _parsevalue_, or part of an _expression_ or _taken_constant_ within _address_;

- if the symbol is spelled `'THEN'` it is keyword wherever a _VAR_SYMBOL_ would be part of an
  _expression_ immediately following the keyword `'IF'` or `'WHEN'`.

Except where the rules above determine the token passed, a _Var_symbol_ is passed as a keyword if the
spelling of it matches a keyword which the top level syntax recognizes in its current context, otherwise the
_Var_symbol_ is passed as a _VAR_SYMBOL_ token.

In a context where the top level syntax could accept a `'||'` token as the next token, a `'||'` operator or a `''`
operator may be inferred and passed to the top level provided that the next token from the lexical level is
a left parenthesis or an operand that is not a keyword. If the blank action has recorded the presence of
one or more blanks to the left of the next token then the `''` operator is inferred. Otherwise, a `'||'` operator is
inferred, except if the next token is a left parenthesis following an _operand_ (see nnn); in this case no
operator is inferred.

When any of the keywords `'OTHERWISE'`, `'THEN'`, or `'ELSE'` is recognized, a semicolon token is supplied
as the following token. A semicolon token is supplied as the previous token when the `'THEN'` keyword is
recognized. A semicolon token is supplied as the token following a _LABEL_.

#### Reserved symbols

A _Const_symbol_ which starts with a period and is not a _Number_ shall be spelled `.MN`, `.RESULT`, `.RC`,
`.RS`, or `.SIGL` otherwise _Msg50.1_ is issued.

#### Function name syntax

A _symbol_ which is the leftmost component of a _function_ shall not end with a period, otherwise _Msg51.1_ is
issued.

## Syntax

### Syntax elements
The tokens generated by the actions described in nnn form the basis for recognizing larger constructs.

### Syntax level

```rexx <!--syntaxlevel.ebnf-->
starter:=x3j18
x3j18:=program Eos | Msg35.1
program   := [label_list] [ncl] [requires+] [prolog_instruction+]
                 (class_definition [requires+])+
  requires          :=  'REQUIRES' ( taken_constant  |  Msg19.8 ) ';'+
  prolog_instruction:= (package | import | options) ncl
    package         := 'PACKAGE'( NAME | Msgnn )
    import          := 'IMPORT' ( NAME | Msgnn ) ['.']
    options         := 'OPTIONS' ( symbol+ | Msgnn )
    ncl   := null_clause+ | Msg21.1
      null_clause   := ';' [label_list]
        label_list  := (LABEL ';')+
class_definition    := class [property_info] [method_definition+]
  class             := 'CLASS' ( taken_constant | Msg19.12 ) [class_option+]
                       ['INHERIT' ( taken_constant | Msg19.13 )+] ncl
  class_option      := visibility | modifier | 'BINARY' | 'DEPRECATED'
                    | 'EXTENDS' ( NAME | Msgnn )
                    | 'USES' ( NAMElist | Msgnn )
                    | 'IMPLEMENTS' ( NAMElist | Msgnn )
                    | external | metaclass | submix /* | 'PUBLIC' */
    external        := 'EXTERNAL' (STRING | Msg19.14)
    metaclass       := 'METACLASS' ( taken_constant | Msg19.15 )
    submix          := 'MIXINCLASS' ( taken_constant | Msg19.16 )
                       | 'SUBCLASS' ( taken_constant | Msg19.17 )
    visibility      := 'PUBLIC' | 'PRIVATE'
    modifier        :=  'ABSTRACT' | 'FINAL' | 'INTERFACE' | 'ADAPTER'!
    NAMElist        := NAME [(',' ( NAME | Msgnn ) )+]
  property_info     := numeric | property_assignment | properties | trace
    numeric         := 'NUMERIC' (numeric_digits | numeric_form | Msg25.15)
      numeric_digits:= 'DIGITS' [expression]
      numeric_form  := 'FORM' ['ENGINEERING' | 'SCIENTIFIC']
  property_assignment := NAME | assignment
  properties        := 'PROPERTIES' ( properties_option+ | Msgnn)
    properties_option := properties_visibility | properties_modifier
      properties_visibility := 'INHERITABLE' | 'PRIVATE' | 'PUBLIC' |
'INDIRECT'
      properties_modifier := 'CONSTANT' | 'STATIC' | 'VOLATILE' | 'TRANSIENT'
  trace             := 'TRACE' ['ALL' | 'METHODS' | 'OFF' | 'RESULTS']
method_definition   := (method [expose ncl]| routine)
                        balanced
  expose            := 'EXPOSE' variable_list
  method            := 'METHOD' (taken_constant | Msg19.9)
                      [ '(' assigncommalist | Msgnn ( ')' | Msgnn )]
                      [method_option+] ncl
    assigncommalist := assignment [(',' ( assignment | Msgnn ) )+]
    method_option   := method_visibility | method_modifier | 'PROTECT'
                    | 'RETURNS' ( term | Msgnn )
                    | 'SIGNAL' ( termcommalist | Msgnn )
                    | 'DEPRECATED'
                    | 'CLASS' | 'ATTRIBUTE' | /*'PRIVATE' | */ guarded
        guarded     := 'GUARDED' | 'UNGUARDED!
      method_visibility := 'INHERITABLE' | 'PRIVATE' | 'PUBLIC' | 'SHARED'
      method_modifier := 'ABSTRACT' | 'CONSTANT' | 'FINAL' | 'NATIVE' |
'STATIC'
      termcommalist := term [(',' ( term | Msgnn ) )+]
  routine           := 'ROUTINE' ( taken constant | Msg19.11 ) ['PUBLIC'] ncl
  balanced:= instruction_list ['END' Msgl0.1]
    instruction_list:= instruction+

/* The second part is about groups */

instruction       := group | single_instruction ncl
group             := do ncl | if | loop ncl | select ncl
  do              := do_specification ncl [instruction+] [group_handler]
                    ('END' [NAME] | Eos Msg14.1 | Msg35.1)
    group_option  := 'LABEL' ( NAME | Msgnn ) | 'PROTECT' ( term | Msgnn )
    group_handler := catch | finally | catch finally
      catch       := 'CATCH' [ NAME '=' ] ( NAME | Msgnn) ncl [instruction+]
/* FINALLY implies a semicolon. */
      finally     := 'FINALLY' ncl ( instruction+ | Msgnn )
  if              := 'IF' expression [ncl] (then | Msg18.1)
                  [else]
    then          := 'THEN' ncl
                  (instruction | EOS Msg14.3 | 'END' Msg10.5)
    else          := 'ELSE' nel
                  (instruction | EOS Msg14.4 | 'END' Msg10.6)
  loop            := 'LOOP' [group_option+] [repetitor] [conditional] ncl
                     instruction+ [group_handler]
                     loop_ending
    loop_ending   := 'END' [VAR SYMBOL] | EOS Msg14.n | Msg35.1
  conditional     := 'WHILE' whileexpr | 'UNTIL' untilexpr
    untilexpr     := expression
    whileexpr     := expression
  repetitor       := assignment [count_option+] | expression | over |
'FOREVER'
    count_option  := loopt | loopb | loopf
      loopt       := 'TO' expression
      loopb       := 'BY' expression
      loopf       := 'FOR' expression
    over          := VAR_SYMBOL 'OVER' expression
                  | NUMBER 'OVER' Msg31.1
                  | CONST_SYMBOL 'OVER' (Msg31.2 | Msg31.3)
select            := 'SELECT' [group_option+] ncl select_body [group_handler]
                  ('END' [NAME Msg10.4] | EOS Msgl14.2 | Msg7.2)
    select_body   := (when | Msg7.1) [when+] [otherwise]
      when        := 'WHEN' expression [ncl] (then | Msg18.2)
      otherwise   := 'OTHERWISE' ncl [instruction+]

/* Third part is for single instructions. */
single_instruction:= assignment | message_instruction | keyword_instruction
                  |command
  assignment      := VAR SYMBOL '#' expression
                  | NUMBER '#' Msg31.1
                  | CONST_SYMBOL '#' (Msg31.2 | Mgg31.3)
  message_instruction := message_term | message_term '#' expression
  keyword_instruction:= address | arg | call | drop | exit
                  | interpret | iterate | leave
                  | nop | numeric | options
                  | parse | procedure | pull | push | queue
                  | raise | reply | return | say | signal | trace | use
                  | 'THEN' Msg8.1 | 'ELSE' Msg8.2
                  | 'WHEN' Msg9.1 | 'OTHERWISE' Msg9.2
  command         := expression
address           := 'ADDRESS' [(taken_constant [expression]
                  | Msg19.1 | valueexp)  [ 'WITH' connection] ]
  taken_constant  := symbol | STRING
  valueexp        := 'VALUE' expression
  connection      := ad_option+
    ad_option     := error | input | output | Msg25.5
      error       := 'ERROR' (resourceo | Msg25.14)
      input       := 'INPUT' (resourcei | Msg25.6)
        resourcei := resources | 'NORMAL'
      output      := 'OUTPUT' (resourceo | Mgg25.7)
        resourceo := 'APPEND' (resources | Msg25.8)
                  | 'REPLACE' (resources | Msg25.9)
                  | resources | 'NORMAL'
resources         := 'STREAM' (VAR_SYMBOL | Msg53.1)
                  | 'STEM' (VAR_SYMBOL | Msg53.2)
  vref            := '(' var_symbol (')' | Msg46.1)
    var_symbol    := VAR_SYMBOL | Msg20.1
arg               := 'ARG' [template_list]
call              := 'CALL' (callon_spec |
                  (taken_constant | vref | Msg19.2) [expression_list] )
  callon_spec     := 'ON' (callable_condition | Msg25.1)
                  ['NAME' (symbol_constant_term | Msg19.3)]
                  | 'OFF' (callable_condition | Msg25.2)
    symbol_constant_term := term
    callable_condition:= 'ANY' | 'ERROR' | 'FAILURE' | 'HALT' | 'NOTREADY'
                  | 'USER' ( symbol_constant_term | Msg19.18 )
    condition     := callable_condition | 'LOSTDIGITS'
                  | 'NOMETHOD' | 'NOSTRING' | 'NOVALUE' | 'SYNTAX'
  expression_list := expr | [expr] ',' [expression_list]
do_specification  := do_simple | do_repetitive
  do_simple       := 'DO' [group_option+]
  do_repetitive   := do_simple (dorep | conditional | dorep conditional)
    dorep         := 'FOREVER' | repetitor
drop              := 'DROP' variable_list
  variable_list   := (vref | var_symbol)+
exit              := 'EXIT' [expression]
forward           := 'FORWARD' [forward_option+ | Msg25.18]
  forward_option  := 'CONTINUE' | ArrayArgOption |
                    MessageOption | ClassOption | ToOption
    ArrayArgOption:='ARRAY' arguments | 'ARGUMENTS' term
    MessageOption :='MESSAGE' term
    ClassOption   :='CLASS' term
    ToOption      :='TO' term
guard             := 'GUARD' ('ON' | Msg25.22) [('WHEN' | Msg25.21)
expression]
                         | ( 'OFF' | Msg25.19) [('WHEN' | Msg25.21)
expression]
interpret         := 'INTERPRET' expression
iterate           := 'ITERATE' [VAR SYMBOL | Msg20.2]
leave             := 'LEAVE' [VAR SYMBOL | Msg20.2]
nop               := 'NOP'
numeric           := 'NUMERIC' (numeric_digits | numeric_form
                  | numeric_fuzz | Msg25.15)
  numeric_digits  := 'DIGITS' [expression]
  numeric_form    := 'FORM' [numeric_form_suffix]
    numeric_form_suffix:=('ENGINEERING' |'SCIENTIFIC'|valueexp | Msg25.11)
  numeric_fuzz    := 'FUZZ' [expression]
options           := 'OPTIONS' expression
parse             := 'PARSE' [translations] (parse_type
|Msg25.12) [template_list]
  translations    := 'CASELESS' ['UPPER' | 'LOWER']
                  | ('UPPER' | 'LOWER') ['CASELESS']
  parse_type      := parse_key | parse_value | parse_var | term
    parse_key     := 'ARG' | 'PULL' | 'SOURCE' | 'LINEIN'
                  | 'VERSION'
    parse_value   := 'VALUE' [expression] ('WITH' | Msg38.3)
    parse_var     := 'VAR' var_symbol
  template := NAME [( [pattern] NAME) +]
    pattern:= STRING | [indicator] NUMBER | [indicator] '(' symbol ')'
      indicator := '+' | '-' | '='
procedure         := 'PROCEDURE' [expose | Msg25.17]
pull              := 'PULL' [template_list]
push              := 'PUSH' [expression]
queue             := 'QUEUE' [expression]
raise             := 'RAISE' conditions (raise_option | Msg25.24)
  conditions      := 'ANY' | 'ERROR' term | 'FAILURE' term
                  | 'HALT'| 'LOSTDIGITS' | 'NOMETHOD' | 'NOSTRING' |
"NOTREADY'
                  | 'NOVALUE' | 'PROPAGATE' | 'SYNTAX' term
                  | 'USER' ( symbol_constant_term | Msg19.18) | Msg25.23
  raise_option    := ExitRetOption | Description | ArrayOption
    ExitRetOption := 'EXIT' [term] | 'RETURN' [term]
    Description   :='DESCRIPTION' term
    ArrayOption   := 'ADDITIONAL' term | 'ARRAY' arguments
reply             := 'REPLY' [ expression]
return            := 'RETURN' [expression]
say               := 'SAY' [expression]
signal            := 'SIGNAL' (signal_spec | valueexp
                  | symbol_constant_term | Msg19.4)
  signal_spec     := 'ON' (condition | Msg25.3)
                  ['NAME' (symbol_constant_term | Msg19.3)]
                  | 'OFF' (condition | Msg25.4)
trace             := 'TRACE' [(taken_constant | Msg19.6) | valueexp]
use               := 'USE' ('ARG' | Msg25.26) [use_list]
  use_list        := VAR_SYMBOL | [VAR_SYMBOL] ',' [use_list]

/* Note:  The next part describes templates. */
template_list     := template | [template] ',' [template_list]
  template        := (trigger | target | Msg38.1)+
   target         := VAR_SYMBOL | '.'
   trigger        := pattern | positional
     pattern      := STRING | vrefp
       vrefp      := '(' (VAR_SYMBOL | Msg19.7) (')' | Msg46.1)
     positional   := absolute_positional | relative_positional
       absolute_positional:= NUMBER | '=' position
         position := NUMBER | vrefp | Msg38.2
     relative_positional:= ('+' | '-') position

/* Note: The final part specifies the various forms of symbol, and
expression. */
symbol            := VAR_SYMBOL | CONST_SYMBOL | NUMBER
expression        := expr [(',' Msg37.1) | (')' Msg37.2 )]
  expr            := expr_alias
    expr_alias    := and_expression
                  | expr_alias or_operator and_expression
      or_operator := '|' | '&&'
      and_expression := comparison | and_expression '&' comparison
comparison        := concatenation
                  | comparison comparison_operator concatenation
  comparison_operator:= normal_compare | strict_compare
    normal_compare:= '=' | '\=' | '<>' | '><' | '>' | '<' | '>='
                  | '<=' | '\>' | '\<'
    strict_compare:= '==' | '\==' | '>>' | '<<' | '>>=' | '<<='
                  | '\>>' | '\<<'
concatenation     := addition
                  | concatenation (' ' | '||') addition
addition          := multiplication
                  | addition additive_operator multiplication
  additive operator:= '+' | '-'
multiplication    := power_expression
                  | multiplication multiplicative_operator
                  power_expression
  multiplicative_operator:= '*' | '/' | '//' | '%'
power_expression  := prefix_expression
                  | power_expression '**' prefix_expression
  prefix_expression := ('+' | '-' | '\') prefix_expression
                  | term | Msg35.1
/* "Stub" has to be identified semantically? */
    term          := simple_term [ '.' ( term | Msgnn )]
      simple_term := symbol | STRING | invoke | indexed
                  | '(' expression ( ')' | Msg36 )
                  | initializer
                  | message_term '##'
      message_term:= term ('~' | '~~') method_name [arguments]
                  | term '['[ expression_list ] (']' | Msg36.2)

        method_name:=(taken_constant | Msg19.19)
                         [':' ( VAR_SYMBOL | Msg19.21 )]
/* Method-call without arguments is syntactically like symbol. */
/* Editor - not sure of my notes about here. */
invoke       := (symbol | STRING) arguments
  arguments       := '#(' [expression_list] (')' | Msg36)
    expression_list := expression | [expression] ',' [expression_list]
indexed           := (symbol | STRING) indices
  indices         := '#[' [expression_list] (']' | Msg36.n)
initializer       := '['expression_list (']' | Msg36.n)
```

## Syntactic information

### VAR_SYMBOL matching

Any `VAR_SYMBOL` in a _do_ending_ must be matched by the same _VAR_SYMBOL_ occurring at the start
of an _assignment_ contained in the _do_specification_ of the _do_ that contains 
both the _do_specification_ and the _do_ending_, as described in nnn.

If there is a _VAR_SYMBOL_ in a _do_ending_ for which there is no _assignment_ in the corresponding
_do_specification_ then message _Msg10.3_ is produced and no further activity is defined.

If there is a _VAR_SYMBOL_ in a _do_ending_ which does not match the one occurring in the _assignment_
then message _Msg10.2_ is produced and no further activity is defined.

An _iterate_ or _leave_ must be contained in the _instruction_list_ of some _do_ 
with a _do_specification_ which is _do_repetitive_, otherwise a message (_Msg28.2_ or _Msg28.1_ respectively)
is produced and no further activity is defined.

If an _iterate_ or _leave_ contains a _VAR_SYMBOL_ there must be a matching _VAR_SYMBOL_ in a
_do_specification_, otherwise a message (_Msg28.1_, _Msg28.2_, _Msg28.3_ or _Msg28.4_ appropriately) is
produced and no further activity is defined. The matching _VAR_SYMBOL_ will occur at the start of an
_assignment_ in the _do_specification_. Tne _do_specification_ will be associated with a _do_ by nnn. 
The _iterate_ or _leave_ will be a single _instruction_ in an _instruction_list_ associated 
with a _do_ by nnn. These two dos shall be the same, or the latter nested one or more levels
within the former. The number of levels is called the _nesting_correction_ and 
influences the semantics of the _iterate_ or _leave_. It is zero if the two dos are the
same. The _nesting_correction_ for _iterates_ or _leaves_ that do not contain _VAR_SYMBOL_ is zero.

### Trace-only labels

Instances of _LABEL_ which occur within a _grouping_instruction_ and are not in a _ncl_ at the end of that
_grouping_instruction_ are instances of trace-only labels.

### Clauses and line numbers

The activity of tracing execution is defined in terms of clauses. A program consists of clauses, each
clause ended by a semicolon special token. The semicolon may be explicit in the program or inferred.
The line number of a clause is one more than the number of _EOL_ events recognized before the first token
of the clause was recognized.

### Nested IF instructions

The syntax specification nnn allows `'IF'` instructions to be nested and does not fully specify the
association of an `'ELSE'` keyword with an `'IF'` keyword. An `'ELSE'` associates with the closest prior `'IF'` that
it can associate with in conformance with the syntax.

### Choice of messages

The specifications nnn and nnn permit two alternative messages in some circumstances. The following
rules apply:

- _Msg15.1_ shall be preferred to _Msg15.3_ if the choice of _Msg15.3_ would result in the replacement for
the insertion being a blank character;

- _Msg15.2_ shall be preferred to _Msg15.4_ if the choice of _Msg15.4_ would result in the replacement for
the insertion being a blank character;

- _Msg31.3_ shall be preferred to _Msg31.2_ if the replacement for the insertion in the message starts with
a period;

- Preference is given to the message that appears later in the list: _Msg21.1_, _Msg27.1_, _Msg25.16_,
_Msg36_, _Msg38.3_, _Msg35.1_, other messages.

### Creation of messages

The _message_identifiers_ in clause 6 correlate with the tails of stem `#ErrorText.`, which is initialized in nnn
to identify particular messages. The action of producing an error message will replace any insertions in
the message text and present the resulting text, together with information on the origin of the error, to the
configuration by writing on the default error stream.

Further activity by the language processor is permitted, but not defined by this standard.

The effect of an error during the writing of an error message is not defined.

#### Error message prefix

The error message selected by the message number is preceded by a prefix. The text of the prefix is
_#ErrorText.0.1_ except when the error is in source that execution of an interactive trace _interpret_
instruction (see nnn) is processing, in which case the text is _#ErrorText.0.2_. The insert called `<value>` in
these texts is the message number. The insert called `<linenumber>` is the line number of the error.
The line number of the error is one more than the number of _EOL_ events encountered before the error
was detectable, except for messages _Msg6.1_, _Msg14_, _Msg14.1_, _Msg14.2_, _Msg14.3_, and _Msg14.4_. For
_Msg6.1_ it is one more than the number of _EOL_ events encountered before the line containing the
unmatched `'/*'`. For the others, it is the line number of the clause containing the keyword referenced in
the message text.

The insert called `<source>` is the value provided on the `API_Start` function which started processing of the
program, see nnn.

## Replacement of insertions

Within the text of error messages, an insertion consists of the characters `'<'`, `'>'`, and what is between
those characters. There will be a word in the insertion that specifies the replacement text, with the
following meaning:

- if the word is `'hex-encoding'` and the message is not _Msg23.1_ then the replacement text is the value
of the leftmost character which caused the source to be syntactically incorrect. The value is in
hexadecimal notation;

- if the word is `'token'` then the replacement text is the part of the source program which was
recognized as the detection token, or in the case of _Msg31.1_ and _Msg31.2_, the token before the
detection token.

The detection token is the leftmost token for which the program up to and including the token could
not be parsed as the left part of a program without causing a message. If the detection token is a
semicolon that was not present in the source but was supplied during recognition then the
replacement is the previous token;

- if the word is `'position'` then the replacement text is a number identifying the detection character. The
detection character is the leftmost character in the _hex_string_ or _binary_string_ which did not match the
required syntax. The number is a count of the characters in the string which preceded the detection
character, including the initial quote or apostrophe. In deciding the leftmost blank in a quoted string of
radix `'X'` or `'B'` that is erroneous note that:

    * A blank as the first character of the quoted string is an error.     
    * The leftmost embedded sequence of blanks can validly follow any number of non-blank characters.
    * Otherwise a blank run that follows an odd numbered sequence of non-blanks (or a number not a
      multiple of four in the case of radix `'B'`) is not valid.
    * If the string is invalid for a reason not described above, the leftmost blank of the rightmost sequence of
      blanks is the invalid blank to be referenced in the message;

- if the word is `'char'` then the replacement text is the detection character;

- if the word is `'linenumber'` then the replacement text is the line number of a clause associated with
  the error. The wording of the message text specifies which clause that is;

- if the word is `'keywords'` then the replacement text is a list of the keywords that the syntax would
  allow at the context where the error occurred. If there are two keywords they shall be separated by the
  four characters `' or '`. If more, the last shall be preceded by the three characters `'or'` and the others
  shall be followed by the two characters `','`. The keywords will be uppercased and in alphabetical
  order.

Replacement text is truncated to `#Limit_Messagelnsert` characters if it would otherwise be longer than
that, except for a keywords replacement. When an insert is both truncated and appears within quotes in
the message, the three characters `'...'` are inserted in the message after the trailing quote.

## Syntactic equivalence

If a _message_term_ contains a `'['` it is regarded as an equivalent _message_term_ without a `'['`, for execution.
The equivalent is `term~'[]'(expression_list)`. See nnn. If a _message_instruction_ has the construction
`message_term '=' expression` it is regarded as equivalent to a _message_term_ with the same components
as the _message_term_ left of the `'='`, except that the _taken_constant_ has an `'='` character appended and
_arguments_ has the expression from the right of the `'='` as an extra first argument. See nnn.
