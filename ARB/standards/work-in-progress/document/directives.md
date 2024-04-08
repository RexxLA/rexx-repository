# Directives

The syntax constructs which are introduced by the optional '::' token are known as directives.

## Notation

Notation functions are functions which are not directly accessible as functions in a program but are used
in this standard as a notation for defining semantics.

Some notation functions allow reference to syntax constructs defined in nnn. Which instance of the
syntax construct in the program is being referred to is implied; it is the one for which the semantics are
being specified.

The `BNF_primary` referenced may be directly in the production or in some component referenced in the
_production_, recursively. The components are considered in left to right order.

```rexx
#Contains (Identifier, BNF primary)
```

where:

* Identifier is an _identifier_ in a _production_ (see nnn) defined in nnn.
* `BNF_primary` is a _bnf_primary_ (see nnn) in a _production_ defined in nnn.

Return `'1'` if the _production_ identitied by _Identifier_ contained a _bnf_primary_ identified by `BNF_primary`, otherwise return `'0'`.

```rexx
#Instance (Identifier, BNF primary)
```

where:

* `Identifier` is an _identifier_ in a _production_ defined in nnn.
* `BNF_primary` is a _bnf_primary_ in a _production_ defined in nnn.

Returns the content of the particular instance of the `BNF_primary`. If the `BNF_primary` is a
`VAR_SYMBOL` this is referred to as the symbol "taken as a constant."

```rexx
#Evaluate (Identifier, BNF primary)
```

where:

* `Identifier` is an _identifier_ in a _production_ defined in nnn.
* `BNF_primary` is a _bnf_primary_ in a _production_ defined in nnn.
* 
Return the value of the `BNF_primary` in the _production_ identified by `Identifier`.

```rexx
#Execute (Identifier, BNF primary)
```

where:

* `Identifier` is an _identifier_ in a _production_ defined in nnn.
* `BNF_primary` is a _bnf_primary_ in a _production_ defined in nnn.

Perform the instructions identified by the `BNF_primary` in the _production_ identified by `Identifier`.

```rexx
#Parses (Value, BNF primary)
```

where:

* `Value` is a string
* `BNF_primary` is a _bnf_primary_ in a _production_ defined in nnn.

Return `'1'` if Value matches the definition of the `BNF_primary`, by the rules of clause 6, `'0'` otherwise.

```rexx
#Clause (Label)
```

where:

* `Label` is a label in code used by this standard to describe processing.

Return an identification of that label. The value of this identification is used only by the `#Goto` notation
function.

```rexx
#Goto (Value)
```

where:

* `Value` identifies a label in code used by this standard to describe processing.

The description of processing continues at the identified label.

```rexx
#Retry ()
```

This notation is used in the description of interactive tracing to specify re-execution of the clause just
previously executed. It has the effect of transferring execution to the beginning of that clause, with state
variable `#Loop` set to the value it had when that clause was previously executed.

## Initializing

_Some of the initializing, now grouped in classic section 8.2.1 will have to come here so that 
we have picked up anything from the `START_API` that needs to be passed on to the execution
of REQUIRES subject. We will be using some operations that are forward reference to what was section nnn._

### Program initialization and message texts

Processing of a program begins when `API_Start` is executed. A pool becomes current for the reserved
variables.

```rexx
call Config ObjectNew
#ReservedPool = #Outcome
#Pool = #ReservedPool
```

_Is it correct to make the reserved variables and the builtin objects in the same pool?_

Some of the values which affect processing of the program are parameters of `API_Start`:
`#Howlnvoked` is set to `'COMMAND'`, `'FUNCTION'` or `'SUBROUTINE'` according to the first parameter of
`API_Start`.

`#Source` is set to the value of the second parameter of `API_Start`.

The third parameter of `API_Start` is used to determine the initial active environment.

The fourth parameter of `API_Start` is used to determine the arguments. For each argument position
`#ArgExists.1.ArgNumber` is set `'1'` if there is an argument present, `'0'` if not. 
`ArgNumber` is the number of the argument position, counting from `1`. If `#ArgExists.1.ArgNumber` 
is `'1'` then `#Arg.1.ArgNumber` is set to the value of the corresponding argument. 
If `#ArgExists.1.ArgNumber` is `'0'` then `#Arg.1.Arg` is set to the null string. 
`#ArgExists.1.0` is set to the largest `n` for which `#ArgExists.1.n` is `'1'`, or to zero if there is no
such value of `n`.

Some of the values which affect processing of the program are provided by the configuration:

```rexx
call Config OtherBlankCharacters
#A11Blanks<Index "#Al1Blanks" # "" > = ' '#Outcome /* "Real" blank concatenated with
others */
#Bif Digits. = 9
call Config Constants
.true = '1'
.false = '0'
```
_Objects in our model are only distinquished by the values within their pool so we can construct the builtin classes incomplete and then complete them with directives._

_Can we initialize the methods of .nil by directives?_

```rexx
call Config_ObjectNew
.List = #Outcome
call var_set .List, #IsClass, '0', '1'
call var_set .List, #ID, '0', 'List'
```

Some of the state variables set by this call are limits, and appear in the text of error messages. The
relation between message numbers and message text is defined by the following list, where the message
number appears immediately before an `'='` and the message text follows in quotes.

```rexx
#ErrorText.    = ''

#ErrorText.0.1 = 'Error <value> running <source>, line <linenumber>: '
#ErrorText.0.2 = 'Error <value> in interactive trace: '
#ErrorText.0.3 = 'Interactive trace. "Trace Off" to end debug. ',
                 'ENTER to continue.'
#ErrorText.2   = 'Failure during finalization’
#ErrorText.2.1 = 'Failure during finalization: <description>'

#ErrorText.3   = 'Failure during initialization'
#ErrorText.3.1 = 'Failure during initialization: <description>'

#ErrorText.4   = 'Program interrupted'
#ErrorText.4.1 = 'Program interrupted with HALT condition: <description>'

#ErrorText.5   = 'System resources exhausted'
#ErrorText.5.1 = 'System resources exhausted: <description>'

#ErrorText.6   = 'Unmatched "/*" or quote'
#ErrorText.6.1 = 'Unmatched comment delimiter ("/*")'
#ErrorText.6.2 = "Unmatched single quote (')"
#ErrorText.6.3 = 'Unmatched double quote (")'

#ErrorText.7   = 'WHEN or OTHERWISE expected'
#ErrorText.7.1 = 'SELECT on line <linenumber> requires WHEN;',
                 'found "<token>"'
#ErrorText.7.2 = 'SELECT on line <linenumber> requires WHEN, OTHERWISE,'.
                 'or END; found "<token>"'
#ErrorText.7.3 = 'All WHEN expressions of SELECT on line <linenumber> are',
                 'false; OTHERWISE expected’

#ErrorText.8   = 'Unexpected THEN or ELSE'
#ErrorText.8.1 = 'THEN has no corresponding IF or WHEN clause'
#ErrorText.8.2 = 'ELSE has no corresponding THEN clause'

#ErrorText.9   = 'Unexpected WHEN or OTHERWISE'
#ErrorText.9.1 = 'WHEN has no corresponding SELECT'
#ErrorText.9.2 = 'OTHERWISE has no corresponding SELECT'

#ErrorText.10  = 'Unexpected or unmatched END'
#ErrorText.10.1= 'END has no corresponding DO or SELECT'
#ErrorText.10.2= 'END corresponding to DO on line <linenumber>',
                 'must have a symbol following that matches',
                 'the control variable (or no symbol);',
                 'found "<token>"'
#ErrorText.10.3= 'END corresponding to DO on line <linenumber>',
                 'must not have a symbol following it because',
                 'there is no control variable;',
                 'found "<token>"'
#ErrorText.10.4= 'END corresponding to SELECT on line <linenumber>',
                 'must not have a symbol following;',
                 'found "<token>"'
#ErrorText.10.5= 'END must not immediately follow THEN'
#ErrorText.10.6= 'END must not immediately follow ELSE'

#ErrorText.13  = 'Invalid character in program'
#ErrorText.13.1= 'Invalid character "('<hex-encoding>'X)" in program'

#ErrorText.14  = 'Incomplete DO/SELECT/IF'
#ErrorText.14.1= 'DO instruction requires a matching END'
#ErrorText.14.2= 'SELECT instruction requires a matching END'
#ErrorText.14.3= 'THEN requires a following instruction'
#ErrorText.14.4= 'ELSE requires a following instruction'

#ErrorText.15  = 'Invalid hexadecimal or binary string'
#ErrorText.15.1= 'Invalid location of blank in position',
                 '<position> in hexadecimal string'
#ErrorText.15.2= 'Invalid location of blank in position',
                 '<position> in binary string'
#ErrorText.15.3= 'Only 0-9, a-f, A-F, and blank are valid in a',
                 'hexadecimal string; found "<char>"'
#ErrorText.15.4= 'Only 0, 1, and blank are valid in a',
                 'binary string; found "<char>"'

#ErrorText.16  = 'Label not found'
#ErrorText.16.1= 'Label "<name>" not found'
#ErrorText.16.2= 'Cannot SIGNAL to label "<name>" because it is',
                 'inside an IF, SELECT or DO group'
#ErrorText.16.3= 'Cannot invoke label "<name>" because it is',
                 'inside an IF, SELECT or DO group'

#ErrorText.17  = 'Unexpected PROCEDURE'
#ErrorText.17.1= 'PROCEDURE is valid only when it is the first',
                 'instruction executed after an internal CALL',
                 'or function invocation'
#ErrorText.17.2= 'The EXPOSE instruction is valid only when it is the first',
                 'instruction executed after a method invocation’

#ErrorText.18  = 'THEN expected'
#ErrorText.18.1= 'IF keyword on line <linenumber> requires',
                 'matching THEN clause; found "<token>"'
#ErrorText.18.2= 'WHEN keyword on line <linenumber> requires',
                 'matching THEN clause; found "<token>"'

```



#ErrorText.19 =
#ErrorText.19.1=

#ErrorText.19.2=
#ErrorText.19.3=
#ErrorText.19.4=
#ErrorText.19.6=
#ErrorText.19.7=
#ErrorText.19.8=

#ErrorText.19.9=

#ErrorText.19.11='String or symbol

#ErrorText.19.12='String or symbol

#ErrorText.19.13=

#ErrorText.19.15='String or symbol

#ErrorText.19.16='String or symbol

#ErrorText.19.17=

Unsound now we are using '‘term'?

65

#ErrorText.20 =
#ErrorText.20.1=
#ErrorText.20.2=
#ErrorText.20.3=

#ErrorText.21
#ErrorText.21.1

#ErrorText.22 =
#ErrorText.22.1=

#ErrorText.23 =
#ErrorText.23.1=

#ErrorText.24 =
#ErrorText.24.1=
#ErrorText.25 =
#ErrorText.25.1=
#ErrorText.25.2=
#ErrorText.25.3=
#ErrorText.25.4=
#ErrorText.25.5=
#ErrorText.25.6=
#ErrorText.25.7=

#ErrorText.25.8=

'String or symbol expected'
'String or symbol expected after ADDRESS keyword;',
"found "<token>"!
'String or symbol expected after CALL keyword;',
"found "<token>"!
'String or symbol expected after NAME keyword;',
"found "<token>"!
'String or symbol expected after SIGNAL keyword;',
"found "<token>"!
'String or symbol expected after TRACE keyword;',
"found "<token>"!
'Symbol expected in parsing pattern;',
"found "<token>"!
'String or symbol expected after REQUIRES;',
"found "<token>"!
'String or symbol expected after METHOD;',
"found "<token>"!

expected after ROUTINE;',
"found "<token>"!

expected after CLASS;',
"found "<token>"!
'String or symbol expected after INHERIT;',
"found "<token>"!

expected after METACLASS;',
"found "<token>"!

expected after MIXINCLASS;',
"found "<token>"!
'String or symbol expected after SUBCLASS;',
"found "<token>"!
'Name expected'
'Name required; found "<token>"'

'Found "<token>" where only a name is valid'

'Found "<token>" where only a name or

'Invalid data on end of clause'
'The clause ended at an unexpected token;',

'found "<token>"'

'Invalid
"Invalid

'Invalid
"Invalid

'Invalid

character string'
character string

data string'
data string

TRACE request’

is valid'

'<hex-encoding>'xX"

'<hex-encoding>'! xX"

'TRACE request letter must be one of',

' "ACEFILNOR";

found

"evalue>"'

‘Invalid sub-keyword found'
'CALL ON must be followed by one of the',

‘keywords <keywords>;

found

"etoken>"!

'CALL OFF must be followed by one of the',

‘keywords <keywords>;

found

"etoken>"!

"SIGNAL ON must be followed by one of the',

‘keywords <keywords>;

found

"etoken>"!

'SIGNAL OFF must be followed by one of the',

‘keywords <keywords>;

found

"etoken>"!

"ADDRESS WITH must be followed by one of the',

‘keywords <keywords>;

found

"etoken>"!

"INPUT must be followed by one of the',

‘keywords <keywords>;
‘OUTPUT must be followed by
‘keywords <keywords>;
"APPEND must be followed by
‘keywords <keywords>;

found

found

found

"etoken>"!
one of the',
"etoken>"!
one of the',
"etoken>"!


#ErrorText.25.9=

#ErrorText.25.11=
#ErrorText.25.12=
#ErrorText.25.13=
#ErrorText.25.14=
#ErrorText.25.15=
#ErrorText.25.16=
#ErrorText.25.17=

#ErrorText.25.18=

#ErrorText.26
#ErrorText.26.1=

#ErrorText.26.2=

#ErrorText.26.3=

#ErrorText.26.4=
#ErrorText.26.5=

#ErrorText.26.6=

#ErrorText.26.7=
#ErrorText.26.8=

#ErrorText.26.11

#ErrorText.26.12

#ErrorText.27
#ErrorText.27.1=

#ErrorText.28
#ErrorText.28.1=
#ErrorText.28.2=
#ErrorText.28.3=

#ErrorText.28.4=

#ErrorText.29
#ErrorText.29.1=

#ErrorText.30
#ErrorText.30.1=
#ErrorText.30.2=

#ErrorText.31
#ErrorText.31.1=

#ErrorText.31.2=

#ErrorText.31.3=

"REPLACE must be followed by one of the',
‘keywords <keywords>; found "<token>"'
"NUMERIC FORM must be followed by one of the',
‘keywords <keywords>; found "<token>"'

"PARSE must be followed by one of the',
‘keywords <keywords>; found "<token>"'

"UPPER must be followed by one of the',
‘keywords <keywords>; found "<token>"'

"ERROR must be followed by one of the',
‘keywords <keywords>; found "<token>"'
"NUMERIC must be followed by one of the',
‘keywords <keywords>; found "<token>"'
'FOREVER must be followed by one of the',
"keywords <keywords> or nothing; found "<token>"'
"PROCEDURE must be followed by the keyword',
"EXPOSE or nothing; found "<token>"'

"FORWARD must be followed by one of the the keywords',

'<keywords>; found "<token>"'

'Invalid whole number'

'Whole numbers must fit within current DIGITS',
'setting(<value>); found "<value>"'

'Value of repetition count expression in DO instruction',

'must be zero or a positive whole number;',
'found "<value>"'

'Value of FOR expression in DO instruction',
'must be zero or a positive whole number;',
'found "<value>"'

"Positional pattern of parsing template’,
'must be a whole number; found "<value>"'
"NUMERIC DIGITS value',

'must be a positive whole number;
"NUMERIC FUZZ value',

'must be zero or a positive whole number;',

'found "<value>"'

'Number used in TRACE setting',

'must be a whole number; found "<value>"'

'Operand to right of the power operator ("**")',
'must be a whole number; found "<value>"'

"Result of <value> % <value> operation would need',

found "<value>"'

‘exponential notation at current NUMERIC DIGITS <value>'

"Result of % operation used for <value> // <value>',
‘operation would need',

‘exponential notation at current NUMERIC DIGITS <value>'

‘Invalid DO syntax'
‘Invalid use of keyword "<token>" in DO clause'

‘Invalid LEAVE or ITERATE'

'LEAVE is valid only within a repetitive DO loop'
'ITERATE is valid only within a repetitive DO loop'
'Symbol following LEAVE ("<token>") must',

‘either match control variable of a current',

'DO loop or be omitted'

'Symbol following ITERATE ("<token>") must',
‘either match control variable of a current',

'DO loop or be omitted'

‘Environment name too long'
‘Environment name exceeds',

#Limit EnvironmentName 'characters; found "<name>"'
'Name or string too long'

'Name exceeds' #Limit Name 'characters'
"Literal string exceeds' #Limit Literal 'characters'
'Name starts with number or "."'!

'A value cannot be assigned to a number;',

'found "<token>"'

'Variable symbol must not start with a number;',
'found "<token>"'

'Variable symbol must not start with a ".";',

'found "<token>"'
#ErrorText.33 =
#ErrorText.33.1=

#ErrorText.33.2=

#ErrorText.33.3=

#ErrorText.34 =
#ErrorText.34.1=

‘Invalid expression result'
'Value of NUMERIC DIGITS ("<value>")',

'must exceed value of NUMERIC FUZZ

"(<¢value>)"'!

'Value of NUMERIC DIGITS ("<value>")',

'must not exceed’

#Limit Digits

"Result of expression following NUMERIC FORM',

'must start with "E"

or "S"; found "<value>"'

"Logical value not "0" or "1"!

'Value of expression

following IF keyword',

'must be exactly "0" or "1"; found "<value>"'
#ErrorText.34.2= 'Value of expression following WHEN keyword',

'must be exactly "0" or "1"; found "<value>"'
#ErrorText.34.3= 'Value of expression following WHILE keyword',

'must be exactly "0" or "1"; found "<value>"'
#ErrorText.34.4= 'Value of expression following UNTIL keyword',

'must be exactly "0" or "1"; found "<value>"'
#ErrorText.34.5= 'Value of expression to left',

‘of logical operator "<operator>"',

'must be exactly "0" or "1"; found "<value>"'
#ErrorText.34.6= 'Value of expression to right',

‘of logical operator "<operator>"',

'must be exactly "0" or "1"; found "<value>"'
#ErrorText.35 = 'Invalid expression'
#ErrorText.35.1= 'Invalid expression detected at "<token>"'

#ErrorText.36

‘Unmatched "(" in expression’

#ErrorText.37 =
#ErrorText.37.1=
#ErrorText.37.2=

'Unexpected n a n ny nt

'Unexpected ","!
‘Unmatched ")" in expression’

or

#ErrorText.38 =
#ErrorText.38.1=
#ErrorText.38.2=
#ErrorText.38.3=

‘Invalid template or pattern'

‘Invalid parsing template detected at "<token>"'
‘Invalid parsing position detected at "<token>"'
"PARSE VALUE instruction requires WITH keyword'

"Incorrect call to routine’

'External routine "<name>" failed'

'Not enough arguments in invocation of <bif>;',
'minimum expected is <argnumber>'

'Too many arguments in invocation of <bif>;',
'maximum expected is <argnumber>'

'Missing argument in invocation of <bif>;',
‘argument <argnumber> is required'
'ebif> argument <argnumber>',

‘exponent exceeds' #Limit ExponentDigits
"found "<value>"'

'<bif> argument <argnumber>',

'must be a number; found "<value>"'!
'<bif> argument <argnumber>',

#ErrorText.40 =
#ErrorText.40.1=
#ErrorText.40.3=
#ErrorText.40.4=
#ErrorText.40.5=

#ErrorText.40.9=
'digits;',

#ErrorText.40.11=

#ErrorText.40.12=

'must be a whole number; found "<value>"'
#ErrorText.40.13='<bif> argument <argnumber>',

'must be zero or positive; found "<value>"'
#ErrorText.40.14='<bif> argument <argnumber>',

'must be positive; found "<value>"'

#ErrorText.40.17='<bif> argument 1',
'must have an integer part in the range 0:90 and a',
'decimal part no larger than .9; found "<value>"'
#ErrorText.40.18='<bif> conversion must',

"have a year in the range 0001 to 9999!
#ErrorText.40.19='<bif> argument 2, "<value>", is not in the format’,

‘described by argument 3, "<value>"'

#ErrorText.40.21='<bif> argument <argnumber> must not be null'
#ErrorText.40.23='<bif> argument <argnumber>',

'must be a single character; found "<value>"'
#ErrorText.40.24='<bif> argument 1',

'must be a binary string; found "<value>"'
#ErrorText.40.25='<bif> argument 1',

'must be a hexadecimal string; found "<value>"'
#ErrorText.40.26='<bif> argument 1',

'must be a valid symbol; found "<value>"'
#ErrorText.40.27='<bif> argument 1',

'must be a valid stream name; found "<value>"'
#ErrorText.40.28='<bif> argument <argnumber>,',

‘option must start with one of "<optionslist>";',

'found "<value>"'

#ErrorText.40.29='<bif> conversion to format "<value>" is not allowed'
#ErrorText.40.31='<bif> argument 1 ("<value>") must not exceed 100000'
#ErrorText.40.32='<bif> the difference between argument 1 ("<value>") and',

‘argument 2 ("<value>") must not exceed 100000'
#ErrorText.40.33='<bif> argument 1 ("<value>") must be less than',

‘or equal to argument 2 ("<value>")'
#ErrorText.40.34='<bif> argument 1 ("<value>") must be less than',

‘or equal to the number of lines',

‘in the program (<sourceline()>)'
#ErrorText.40.35='<bif> argument 1 cannot be expressed as a whole number;',

'found "<value>"'

#ErrorText.40.36='<bif> argument 1',
'must be the name of a variable in the pool;',
'found "<value>"'

#ErrorText.40.37='<bif> argument 3',

'must be the name of a pool; found "<value>"'
#ErrorText.40.38='<bif> argument <argnumber>',

‘is not large enough to format "<value>"'
#ErrorText.40.39='<bif> argument 3 is not zero or one; found "<value>"'
#ErrorText.40.41='<bif> argument <argnumber>',

'must be within the bounds of the stream;',

'found "<value>"'

#ErrorText.40.42='<bif> argument 1; cannot position on this stream;',
'found "<value>"'
#ErrorText.40.45='<bif> argument <argnumber> must be a single',

'non-alphanumeric character or the null string; ',

' "found <value>"'

#ErrorText.40.46='<bif> argument 3, "<value>", is a format incompatible',

'with separator specified in argument <argnumber>'

#ErrorText.41 = 'Bad arithmetic conversion'
#ErrorText.41.1= 'Non-numeric value ("<value>")',
'to left of arithmetic operation "<operator>"'

#ErrorText.41.2= 'Non-numeric value ("<value>")',
'to right of arithmetic operation "<operator>"'
#ErrorText.41.3= 'Non-numeric value ("<value>")',

‘used with prefix operator "<operator>"'

#ErrorText.41.4= 'Value of TO expression in DO instruction',
'must be numeric; found "<value>"'!

#ErrorText.41.5= 'Value of BY expression in DO instruction',
'must be numeric; found "<value>"'!

#ErrorText.41.6= 'Value of control variable expression of DO instruction’,
'must be numeric; found "<value>"'!

#ErrorText.41.7= 'Exponent exceeds' #Limit ExponentDigits 'digits;',
'found "<value>"'

#ErrorText.42 = 'Arithmetic overflow/underflow'
#ErrorText.42.1l= 'Arithmetic overflow detected at',
'Nevalue> <operation> <value>";',
‘exponent of result requires more than',
#Limit ExponentDigits 'digits'
#ErrorText.42.2= 'Arithmetic underflow detected at',
'Nevalue> <operation> <value>";',
‘exponent of result requires more than',
#Limit ExponentDigits 'digits'
"Arithmetic overflow; divisor must not be zero’

#ErrorText.42.3

"Routine not found’
‘Could not find routine "<name>"'

#ErrorText.43 =
#ErrorText.43.1=
#ErrorText.44 = 'Function did not return data’

#ErrorText.44.1= 'No data returned from function "<name>"'

#ErrorText.45 = 'No data specified on function RETURN'
#ErrorText.45.1= 'Data expected on RETURN instruction because’,
‘routine "<name>" was called as a function’

#ErrorText.46 = 'Invalid variable reference’
#ErrorText.46.1= 'Extra token ("<token>") found in variable',
‘reference; ")" expected’

#ErrorText.47 = 'Unexpected label'
#ErrorText.47.1l= 'INTERPRET data must not contain labels;',
'found "<name>"!

#ErrorText.48 = 'Failure in system service'
#ErrorText.48.1= 'Failure in system service: <description>'

#ErrorText.49 = 'Interpretation Error'
#ErrorText.49.1= 'Interpretation Error: <description>'
#ErrorText.50 = 'Unrecognized reserved symbol'

#ErrorText.50.1= 'Unrecognized reserved symbol "<token>"'

#ErrorText.51 = 'Invalid function name'

#ErrorText.51.1= 'Unquoted function names must not end with a period;',
'found "<token>"'

#ErrorText.52

"Result returned by "<name>" is longer than',
#Limit String 'characters'

#ErrorText.53 = 'Invalid option’
#ErrorText.53.1l= 'Variable reference expected',
‘after STREAM keyword; found "<token>"'
#ErrorText.53.2= 'Variable reference expected',
‘after STEM keyword; found "<token>"'
#ErrorText.53.3= 'Argument to STEM must have one period,',
‘as its last character; found "<name>"'
#ErrorText.54 = 'Invalid STEM value'
#ErrorText.54.1= 'For this use of STEM, the value of "<name>" must be a',
‘count of lines; found: "<value>"'

If the activity defined by clause 6 does not produce any error message, execution of the program
continues.

call Config NoSource

If Config_NoSource has set #NoSource to '0' the lines of source processed by clause 6 are copied to
#SourceLine. , with #SourceLine.O being a count of the lines and #SourceLine.n for n=1 to #SourceLine.0
being the source lines in order.

If Config_NoSource has set #NoSource to '1' then #SourceLine.0 is set to 0.
The following state variables affect tracing:

#InhibitPauses = 0

#InhibitTrace = 0

#AtPause = 0 /* Off until interactive input being received. */

#Trace QueryPrior = 'No'
An initial variable pool is established:

call Config ObjectNew

#Pool = #Outcome

#P0011 = #Pool

call Var_Empty #Pool

call Var_Reset #Pool

#Level = 1 /* Level of invocation */
#NewLevel = 2
#IsFunction.#Level = (#HowInvoked == 'FUNCTION')

For this first level, there is no previous level from which values are inherited. The relevant fields are
initialized.

#Digits.#Level = 9 /* Numeric Digits */
#Form.#Level = 'SCIENTIFIC' /* Numeric Form */
#Fuzz.#Level = 0 /* Numeric Fuzz */
#StartTime.#Level = '' /* Elapsed time boundary */
#LineNumber = ''

#Tracing.#Level = 'N'

#Interactive.#Level = '0'

69
An environment is provided by the API_ Start to become the initial active environment to which commands
will be addressed. The alternate environment is made the same:

/* Call the environments ACTIVE, ALTERNATE, TRANSIENT where these are
never-initialized state variables.

Similarly call the redirections I O and E */

call EnvAssign ALTERNATE, #Level, ACTIVE, #Level

Conditions are initially disabled:

#Enabling.SYNTAX.#Level = 'OFF'
#Enabling.HALT.#Level = 'OFF'
#Enabling.ERROR.#Level = 'OFF'
#Enabling.FAILURE.#Level = 'OFF'
#Enabling.NOTREADY.#Level = 'OFF'
#Enabling.NOVALUE.#Level = 'OFF'
#Enabling.LOSTDIGITS.#Level = 'OFF'

#PendingNow.HALT.#Level = 0
#PendingNow.ERROR.#Level = 0
#PendingNow.FAILURE.#Level = 0
#PendingNow.NOTREADY.#Level = 0
/* The following field corresponds to the results from the CONDITION built-in
function. */
#Condition.#Level = ''
The opportunity is provided for a trap to initialize the pool.
#API Enabled = '1'
call Var_Reset #Pool
call Config Initialization
#API Enabled = '0'
## REQUIRES
For each requires in order of appearence:
A use of Start_API with #instance(requires, taken_constant). Msg40.1 or a new if completion 'E’. Add Provides to an
ordered collection. Not cyclic because .LIST can be defined without defining REQUIRES but a fairly profound forward
reference.
## CLASS
For each class in order of appearence:
#ClassName = #Instance(class, taken constant)
call var_value #ReservedPool, '#CLASSES.'ClassName, '1'
if #Indicator == 'D' then do
call Config ObjectNew
#Class = #Outcome
call var_set #ReservedPool, '#CLASSES.'ClassName, '1', #Class
end
else call #Raise 'SYNTAX', nn.nn, #ClassName

New instance of CLASS class added to list. Msg "Duplicate ::CLASS directive instruction"(?)
## METHOD

For each method in order of appearence:
call Config ObjectNew
#Po00ol = #Outcome
call Config ObjectSource (#Pool)
#MethodName = #Instance(method, taken constant)
call var_value #Class, '#METHODS.'#MethodName, '1'
if #Indicator == 'D' then
call var set #Class, '#METHODS.'#MethodName, '1', #Pool
else call #Raise 'SYNTAX', nn.nn, #MethodName, #ClassName

GUARDED & public is default. if #contains(method, 'PRIVATE') then m~setprivate; if #contains(method,
'UNGUARDED)) then m~setunguarded

Why is there a keyword for GUARDED but not for PUBLIC here?

Does CLASS option mean ENHANCE with Class class methods?

#CurrentClass ~class(#instance(method, taken_constant), m)

For ATTRIBUTE, should we actually construct source for two methods? ATTRIBUTE case needs test of null body.
OO! doesn't have source (because it actually traps UNKNOWN?).

For EXTERNAL test for null body. Simon Nash doc says "Accessibility to external methods ... is
implementation-defined". Left like that it doesn't even tell us about search order. We will need a
Config_ExternalClass to import the public names of the class.

## ROUTINE

For each routine in order of appearence:

Add name (with duplicate check) to list for this file.

Extra step needed in the invocation search order. Although this is nominally EXTERNAL we presumably wont use
the external call mechanism. (Except perhaps when the routine was made available by a REQUIRES; in that case
the PARSE SOURCE answer has to change.)

| have the builtins-defined-by-directives elsewhere; it would make sense if they wound up about here.

