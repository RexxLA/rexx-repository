# Rexx.Tokenizer.cls, a Rexx Tokenizer

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

```

---

__Notice:__

Although this class is part of TUTOR, The Unicode Tools Of Rexx, it can also be used separately, 
as it has no dependencies on the rest of components of TUTOR.

---

## Introduction

The ``Rexx.Tokenizer.cls`` classfile includes a set of ooRexx classes. The main class is ``Rexx.Tokenizer``.
It implements both a [_simple_](#simple) and a [_full_](#full) Rexx tokenizer (see below for definitions of [_simple_](#simple) and [_full_](#full) tokenizing).
The [``getSimpleToken``](#getSimpleToken) method returns basic Rexx tokens and non-tokens character sequences, like comments and whitespace,
while the [``getFullToken``](#getFullToken) method returns full tokens, after discarding null clauses, ignorable blanks and comments.
When requesting full tokens, an optional mechanism allows access to the ignored simple tokens and some other tokens that are
not ignorable but that have been included ("absorbed") for your convenience: for example, labels include their own colon,
keyword instructions include the first blank after the keyword, if any, and so on.

This help file starts with a high-level description of the tokenizer functionality, and ends with an enumeration
and description of the tokenizer methods, and some implementation notes.

## Subclasses and Unicode support

The tokenizer intent is to support all the syntactical constructs of Open Object Rexx (ooRexx), Regina Rexx and ANSI Rexx.
You can select the desired syntax subset at instance creation time by selecting the appropriate class.

```rexx
Rexx.Tokenizer                -- The main class. Choose a subclass

ooRexx.Tokenizer              -- Tokenizes programs written in ooRexx
Regina.Tokenizer              -- Tokenizes programs written in Regina Rexx
ANSI.Rexx.Tokenizer           -- Tokenizes programs written in ANSI Rexx
```

Subclasses starting with "Regina" accept the Regina Rexx syntax; subclasses starting with "ANSI.Rexx" accept only the ANSI Rexx syntax
(for example, comments starting with "--" are accepted by Regina but not by ANSI); subclasses starting with "ooRexx" accept ooRexx syntax;
for example, "\[", "\]" and "~" are valid characters for ooRexx subclasses but not for Regina or ANSI subclasses.

The tokenizer supports classic comments (including nested comments), line comments and strings. The ooRexx ``::ESOURCE`` construct is also accepted.

When a Unicode class is used (see below), Y-, P-, G-, T- and U-suffixed strings are recognized, translated (in the case of U strings) and supported.

```rexx
ooRexx.Unicode.Tokenizer      -- Tokenizes programs written in ooRexx, with experimental Unicode extensions
Regina.Unicode.Tokenizer      -- Tokenizes programs written in Regina Rexx, with experimental Unicode extensions
ANSI.Rexx.Unicode.Tokenizer   -- Tokenizes programs written in ANSI Rexx, with experimental Unicode extensions
```

The full tokenizer is not a full AST parser, but it returns a lof of useful semantical information, like the instruction type, the directive type,
the kind of variable (simple, stem or compound), etc.

## Creating a tokenizer instance

To create a tokenizer instance, you will first need to construct a Rexx array containing the source to tokenize. This array will
then be passed as an argument to the ``init`` method of the corresponding tokenizer class to produce an instance of the tokenizer
for this particular source.

```rexx
source  = CharIn(inFile,,Chars(inFile))~makeArray    -- Read the whole file into an array
tokenizer = .ooRexx.Tokenizer~new(source)            -- Or Regina.Tokenizer, etc.
```

You will also have to decide whether you will be using the _simple tokenizer_ (i.e., you will be getting tokens using the [``getSimpleToken``](#getSimpleToken) tokenizer method),
or you will prefer to use the _full tokenizer_ (i.e., you will be getting your tokens using the [``getFullToken``](#getFullToken) tokenizer method).

```rexx
tokenizer = .ooRexx.Tokenizer~new(source)

Do Forever
  token. = tokenizer~getSimpleToken                                        -- Or tokenizer~getFullToken
If token.class == END_OF_SOURCE | token.class == SYNTAX_ERROR Then Leave   -- Constants are defined below
  -- Do things with the token.
End
```

Both kind of tokens are described below. In case you have opted for the full tokenizer, you will also be able to select _detailed_ or
_undetailed_ tokenizing. _Detailed_ tokenizing returns all the simple tokens that constitute a full token as a property of the
full token. _Undetailed_ tokenizing returns only the full tokens, and discards the elementary, simple tokens, once the full
token has been constructed.

In any case, you will always be able to reconstitute the entirety of your source file by following the location attributes of the returned tokens.

## An example: simple and full tokens

<a id="simple"></a>

### Structure of simple tokens 

Let us start with a very simple piece of code:
```rexx
i = i + 1
```
We will create a test file, say ``test.rex``, and run it through ``InspectTokens.rex`` with the ``-simple`` option. ``InspectTokens.rex`` is a sample utility program you will find in the ``parser`` directory.
```
InspectTokens -simple test.rex
```
Here is the output of the program, prettyprinted and commented for your convenience.
```
 1   [1 1 1 1] END_OF_CLAUSE (BEGIN_OF_SOURCE): ''    -- Automatically generated BEGIN_OF_SOURCE marker
 2   [1 1 1 2] VAR_SYMBOL (SIMPLE_VAR): 'i'           -- A simple variable (i.e., not a stem nor a compound variable)
 3   [1 2 1 3] BLANK: ' '                             -- A blank run consisting of a single blank
 4   [1 3 1 4] OPERATOR: '='                          -- An operator. It happens to work as an assignment in this position
 5   [1 4 1 5] BLANK: ' '                             -- Another blank
 6   [1 5 1 6] VAR_SYMBOL (SIMPLE_VAR): 'i'           -- The same variable as before
 7   [1 6 1 7] BLANK: ' '                             -- One blank more
 8   [1 7 1 8] OPERATOR: '+'                          -- A plus sign, denoting addition
 9   [1 8 1 9] BLANK: ' '                             -- Still one more blank
10  [1 9 1 10] NUMBER (INTEGER): '1'                  -- A number (the smallest positive integer)
11 [1 10 1 10] END_OF_CLAUSE (END_OF_LINE): ''        -- An END_OF_LINE indicator (which works as an implied semicolon)
```
* The first column is a _counter_.
* The second column is an aggregate, the _location_ of the token. We have written it between \[brackets\].
  It is of the form _starting-position_ _ending-position_, where each _position_ is a _line-column_ sequence.
  The ending position if the first character _after_ the returned token. For example, the first "i" in the line
  runs from position (1,1) to position (1,2).
* The third column contains one or two values. When there are two, the second one is enclosed between parentheses. These are the _class_ and the _subclass_ of the token.
  They give a lot of information about the nature of the token (e.g., this is a NUMBER \[class\], subclass INTEGER; or
  this is a VAR_SYMBOL \[class\], subclass SIMPLE_VAR \[i.e., not a stem or a compound variable\]) and will be described below
* The fourth column, after a colon and between simple quotes, is the _value_ of the token. Generally speaking,
  this is the token itself, but in some cases (classic comments, resources) only an indicator is returned
  (you can always reconstitute the original comment or resource by referring to the _location_ attribute
  of the token). In some other cases, the _value_ contains an elaboration of the original token: for example,
  an X, B or U string will be interpreted, so that their value can be substituted in the source file ("(man)"U,
  for instance, will generate a value of "👨").

How does the ``InspectTokens.rex`` program work? Well, essentially what it does is the following: it instantiates a
tokenizer instance, and then it runs it, by calling the [``getSimpleToken``](#getSimpleToken) method, until either the end of file is reached
or a syntax error is encountered. Now, here is the trick: [``getSimpleToken``](#getSimpleToken) _returns tokens... which are Rexx stems!_
(you can already imagine the components of these stems):

```rexx
-- after
token. = tokenizerInstance~getSimpleToken
-- we have (assume that we have just scanned the second "i" of the above program)
token.class    == VAR_SYMBOL     -- The CLASS of the token
token.subClass == SIMPLE_VAR     -- The SUBCLASS of the token
token.location == "1 5 1 6"      -- The LOCATION of the token
token.value    == "1"            -- The VALUE of the token
```

Now you know practically everything there is to know about simple tokens (indeed, there are only two things more
to know, if you limit yourself to simple tokenizing: _error tokens_, and _end-of-file conditions_; we will get
to both of these shortly).

<a id="full"></a>

### Structure of full tokens (undetailed)

What happens now if we want [_full_](#full) tokens, instead of _simple_ ones? We will call ``InspectTokens.rex`` with the ``-full`` option
so that it calls [``getFullToken``](#getFullToken) instead of [``getSimpleToken``](#getSimpleToken).
We will also add the ``-nodetailed`` option for the moment:
```
InspectTokens -full -nodetailed test.rex
```
Let us have a look at its output. Some tokens are the same as before, but some others have experienced some
modifications. Let us focus on those:

```
1   [1 1 1 1] END_OF_CLAUSE (BEGIN_OF_SOURCE): ''
2   [1 1 1 2] ASSIGNMENT_INSTRUCTION (SIMPLE_VAR): 'i'
3   [1 2 1 5] OPERATOR (COMPARISON_OPERATOR): '='        -- "=" has grown to include the blanks before and after
4   [1 5 1 6] VAR_SYMBOL (SIMPLE_VAR): 'i'
5   [1 6 1 9] OPERATOR (ADDITIVE_OPERATOR): '+'          -- "+" has grown to include the blanks before and after
6  [1 9 1 10] NUMBER (INTEGER): '1'
7 [1 10 1 10] END_OF_CLAUSE (END_OF_LINE): ''
```

What has changed, exactly? Well, both the "=" operator and the "+" operator seem to have "grown".
Indeed, they have "eaten" the corresponding blanks. This strictly follows the rules of Rexx:
blanks before and after operator characters are ignored. The tokenizer ignores the blanks, but
at the same time does not want to lose information, so that it "expands" the absorbing tokens
by making them wider, so that they can (so to speak) "accomodate" the ignored blanks: the "="
on line 3 runs now from (1 2 1 3) \[where the previous blank is located\] to (1 4 1 5) \[where
the next blank is located\].

There are some other, subtle, changes in the returned results. The _class_ of "i" has changed,
it is no longer VAR_SYMBOL, but ASSIGNMENT_INSTRUCTION. The full tokenizer "knows"
that ``i = i + 1`` is an assignment instructions, and it passes this knowledge to us.
Similarly, the _subclass_ of "=" has changed. Previously, it was OPERATOR: all the
tokenizer knew was that "=" was an operator character. Now it is ASSIGNMENT_OPERATOR,
which is more informative. Similarly, "+" has now a subclass of ADDITIVE_OPERATOR.

### Structure of full tokens (detailed)

As we mentioned above, when using the full tokenizer, you have the option to request a _detailed_
tokenizing. You do so at instance creation time, by specifying the optional, boolean, _detailed_ argument:
```rexx
detailed = .true
tokenizer = .ooRexx.Tokenizer~new(array, detailed)
```
We will call our ``inspectTokens.rex`` utility program once more, but this time we will not specify the
``-nodetailed`` option, so that a detailed listing (the default when requesting full tokenizing) is produced. 
```
InspectTokens -full test.rex
```
We will get output similar to the following:
```
1   [1 1 1 1] END_OF_CLAUSE (BEGIN_OF_SOURCE): ''
2   [1 1 1 2] ASSIGNMENT_INSTRUCTION (SIMPLE_VAR): 'i'
3   [1 2 1 5] OPERATOR (COMPARISON_OPERATOR): '='          -- If this token is the stem "token." ...
      ---> Absorbed:
      1[1 2 1 3] BLANK: ' '                                -- ...then these subtokens are in token.absorbed[1], ...
      2[1 3 1 4] OPERATOR: '=' <==                         -- ...token.absorbed[2], and...
      3[1 4 1 5] BLANK: ' '                                -- ...token.absorbed[3].
4   [1 5 1 6] VAR_SYMBOL (SIMPLE_VAR): 'i'
5   [1 6 1 9] OPERATOR (ADDITIVE_OPERATOR): '+'
      ---> Absorbed:
      1[1 6 1 7] BLANK: ' '
      2[1 7 1 8] OPERATOR: '+' <==                         -- The "original" main token is indexed by token.cloneIndex, so that...
      3[1 8 1 9] BLANK: ' '                                -- ...token.absorbed[token.cloneIndex] is that token.
6  [1 9 1 10] NUMBER (INTEGER): '1'
7 [1 10 1 10] END_OF_CLAUSE (END_OF_LINE): ''
```

The non-indented lines are identical to the previous listing. The indented ones show us some new components
of a full token, when a detailed tokenizing is requested:

* ``token.absorbed`` is an array of "absorbed" tokens. If there are no absorbed tokens, ``token.~hasIndex(absorbed)`` is
  false.
* ``token.cloneIndex`` is the index in ``token.absorbed`` of the "original" token. For example, when a "=" operator
  absorbs two blanks, these blanks are ignorable, but the "=" operator is the "original", main, non-ignorable token.
  In that case, ``token.cloneIndex`` will be the index of the "=" operator in the ``absorbed`` array.

<a id="tokenClasses"></a>

## Constants, classes and subclasses

A token ``t.`` has a _class_, ``t.class``, and a _subclass_, ``t.subclass``. Classes and subclasses are defined in the
[``tokenClasses``](#tokenClasses) constant of the ``Rexx.Tokenizer`` class. The [``tokenClasses``](#tokenClasses) constant itself is an array of constants,
so that you can use the following code to replicate these constants in your own program:

```rexx
Do constant over tokenizer~tokenClasses
  Call Value constant[1], constant[2]
End
```

You should always use this construction, instead of relying on the internal values of the constants: these values
can be changed without notice.

Here is the full value of the [``tokenClasses``](#tokenClasses) constant. Please note that the second element of each array is a placeholder,
the character "*". This will be substituted by appropriate values by the tokenizer init method.

```rexx
::Constant tokenClasses (    -             
  ( SYNTAX_ERROR                   , "*" ), -  -- Special token returned when a Syntax error is found
  ( OPERATOR                       , "*" ), -
                                            -  -- +--- All subclasses of OPERATOR are full tokenizer only
    ( ADDITIVE_OPERATOR            , "*" ), -  -- | "+", "-" 
    ( COMPARISON_OPERATOR          , "*" ), -  -- | "=", "\=", ">", "<", "><", "<>", ">=", "\<", "<=", "\>" 
                                            -  -- | "==", "\==", ">>", "<<", ">>=", "\<<", "<<=", "\>>"
    ( CONCATENATION_OPERATOR       , "*" ), -  -- | "||" 
    ( LOGICAL_OPERATOR             , "*" ), -  -- | "&", "|", "&&" 
    ( MESSAGE_OPERATOR             , "*" ), -  -- | "~", "~~" 
    ( MULTIPLICATIVE_OPERATOR      , "*" ), -  -- | "*", "/", "//", "%" 
    ( POWER_OPERATOR               , "*" ), -  -- | "**" 
    ( EXTENDED_ASSIGNMENT          , "*" ), -  -- | "+=", "-=", "*=", "/=", "%=", "//=", "||=", "&=", "|=", "&&=", "**=" 
                                            -  -- +--- All subclasses of OPERATOR are full tokenizer only
  ( SPECIAL                        , "*" ), -
  ( COLON                          , "*" ), -
  ( DIRECTIVE_START                , "*" ), -  -- "::" (Full tokenizer only, absorbed by directive)
  ( LPAREN                         , "*" ), -
  ( RPAREN                         , "*" ), -
  ( LBRACKET                       , "*" ), -
  ( RBRACKET                       , "*" ), -
  ( BLANK                          , "*" ), -  -- May be ignorable, or not
  ( LINE_COMMENT                   , "*" ), -  -- Up to but not including the end of the line
  ( CLASSIC_COMMENT                , "*" ), -  -- Infinite nesting allowed
  ( RESOURCE                       , "*" ), -  -- The resource itself, i.e., the array of lines
  ( RESOURCE_DELIMITER             , "*" ), -  -- End delimiter, ends resource
  ( RESOURCE_IGNORED               , "*" ), -  -- After "::Resource name ;" or "::END delimiter"
  ( END_OF_SOURCE                  , "*" ), -
  ( END_OF_CLAUSE                  , "*" ), -
    ( BEGIN_OF_SOURCE              , "*" ), -  -- Dummy and inserted. Very convenient for simplification
    ( END_OF_LINE                  , "*" ), -  -- Implied semicolon
    ( SEMICOLON                    , "*" ), -  -- An explicit semicolon
    ( INSERTED_SEMICOLON           , "*" ), -  -- For example, after a label, THEN, ELSE, and OTHERWISE
                                            -
                                            -  -- CLAUSE SUPPORT (Full tokenizer only)
                                            -  -- ==============
  ( LABEL                          , "*" ), -  -- Includes and absorbs the COLON
                                            -  -- All DIRECTIVEs include and absorb the :: marker
  ( DIRECTIVE                      , "*" ), -  -- 
    ( ANNOTATE_DIRECTIVE           , "*" ), -  -- 
    ( ATTRIBUTE_DIRECTIVE          , "*" ), -  -- 
    ( CLASS_DIRECTIVE              , "*" ), -  -- 
    ( CONSTANT_DIRECTIVE           , "*" ), -  -- 
    ( METHOD_DIRECTIVE             , "*" ), -  -- 
    ( OPTIONS_DIRECTIVE            , "*" ), -  -- 
    ( REQUIRES_DIRECTIVE           , "*" ), -  -- 
    ( RESOURCE_DIRECTIVE           , "*" ), -  -- 
    ( ROUTINE_DIRECTIVE            , "*" ), -  -- 
                                            -  --
  ( KEYWORD_INSTRUCTION            , "*" ), -  -- All KEYWORD_INSTRUCTIONs include the first blank after the keyword, if present 
    (ADDRESS_INSTRUCTION           , "*" ), -  --     
    (ARG_INSTRUCTION               , "*" ), -  -- 
    (CALL_INSTRUCTION              , "*" ), -  -- 
    (CALL_ON_INSTRUCTION           , "*" ), -  -- Includes the ON  sub-keyword
    (CALL_OFF_INSTRUCTION          , "*" ), -  -- Includes the OFF sub-keyword
    (DO_INSTRUCTION                , "*" ), -  -- 
    (DROP_INSTRUCTION              , "*" ), -  -- 
    (ELSE_INSTRUCTION              , "*" ), -  -- Inserts a ";" after
    (END_INSTRUCTION               , "*" ), -  -- 
    (EXIT_INSTRUCTION              , "*" ), -  -- 
    (EXPOSE_INSTRUCTION            , "*" ), -  -- 
    (FORWARD_INSTRUCTION           , "*" ), -  -- 
    (GUARD_INSTRUCTION             , "*" ), -  -- 
    (IF_INSTRUCTION                , "*" ), -  -- 
    (INTERPRET_INSTRUCTION         , "*" ), -  -- 
    (ITERATE_INSTRUCTION           , "*" ), -  -- 
    (LEAVE_INSTRUCTION             , "*" ), -  -- 
    (LOOP_INSTRUCTION              , "*" ), -  -- 
    (NOP_INSTRUCTION               , "*" ), -  -- 
    (NUMERIC_INSTRUCTION           , "*" ), -  -- 
    (OPTIONS_INSTRUCTION           , "*" ), -  -- 
    (OTHERWISE_INSTRUCTION         , "*" ), -  -- Inserts a ";" after
    (PARSE_INSTRUCTION             , "*" ), -  -- Includes UPPER, LOWER and CASELESS (as attributes too)
    (PROCEDURE_INSTRUCTION         , "*" ), -  -- 
    (PUSH_INSTRUCTION              , "*" ), -  -- 
    (PULL_INSTRUCTION              , "*" ), -  -- 
    (QUEUE_INSTRUCTION             , "*" ), -  -- 
    (RAISE_INSTRUCTION             , "*" ), -  -- 
    (REPLY_INSTRUCTION             , "*" ), -  -- 
    (RETURN_INSTRUCTION            , "*" ), -  -- 
    (SAY_INSTRUCTION               , "*" ), -  -- 
    (SELECT_INSTRUCTION            , "*" ), -  -- 
    (SIGNAL_INSTRUCTION            , "*" ), -  -- 
    (SIGNAL_ON_INSTRUCTION         , "*" ), -  -- Includes SIGNAL ON
    (SIGNAL_OFF_INSTRUCTION        , "*" ), -  -- Includes SIGNAL OFF
    (THEN_INSTRUCTION              , "*" ), -  -- Inserts a ";" before and after
    (TRACE_INSTRUCTION             , "*" ), -  -- 
    (UPPER_INSTRUCTION             , "*" ), -  -- Regina only, no ANSI
    (USE_INSTRUCTION               , "*" ), -  -- 
    (WHEN_INSTRUCTION              , "*" ), -  -- 
  ( ASSIGNMENT_INSTRUCTION         , "*" ), -  -- Variable assignments, not message assignments             
  ( COMMAND_OR_MESSAGE_INSTRUCTION , "*" ), -  -- Cannot determine without arbitrarily large context        
                                            -  -- End of CLAUSE SUPPORT
                                            -  -- =====================
  ( VAR_SYMBOL                     , "*" ), -  
    ( SIMPLE_VAR                   , "*" ), -  
    ( STEM_VAR                     , "*" ), -
    ( COMPOUND_VAR                 , "*" ), -
  ( NUMBER                         , "*" ), -
    ( INTEGER                      , "*" ), -
    ( FRACTIONAL                   , "*" ), -
    ( EXPONENTIAL                  , "*" ), -
  ( CONST_SYMBOL                   , "*" ), -
    ( PERIOD_SYMBOL                , "*" ), -
    ( LITERAL_SYMBOL               , "*" ), -
    ( ENVIRONMENT_SYMBOL           , "*" ), -
  ( STRING                         , "*" ), -
    ( BINARY_STRING                , "*" ), -
    ( HEXADECIMAL_STRING           , "*" ), -
    ( CHARACTER_STRING             , "*" ), -  
    ( BYTES_STRING                 , "*" ), -  -- Unicode only. Y suffix
    ( CODEPOINTS_STRING            , "*" ), -  -- Unicode only. P suffix
    ( GRAPHEMES_STRING             , "*" ), -  -- Unicode only. G suffix
    ( TEXT_STRING                  , "*" ), -  -- Unicode only. T suffix
    ( UNOTATION_STRING             , "*" )  -  -- Unicode only. U suffix
)
```

You will notice that many classes and subclasses are marked as "full tokenizer only": they will
only be returned as values when using the full tokenizer. Some other are marked as Unicode only,
or Regina only, etc.

## Error handling

When an error is encountered, tokenizing stops, and a special token is returned. Its class
and subclass will be SYNTAX_ERROR, and a number of special attributes will be included, so that
the error information is as complete as possible:

```rexx
token.class            = SYNTAX_ERROR
token.subclass         = SYNTAX_ERROR
token.location         = location in the source file where the error was found
token.value            = main error message

-- Additional attributes, specific to SYNTAX_ERROR

token.number           = the error number, in the format major.minor
token.message          = the main error message (same as token.value)
token.secondaryMessage = the secondary error message, with all substitutions applied
token.line             = line number where the error occurred (first word of .location)
```

If you want to print error messages that are identical to the ones printed by ooRexx, you can use
the following code snippet:

```rexx
If token.class == SYNTAX_ERROR Then Do
  line = token.line
  Parse Value token.number With major"."minor

  Say
  Say Right(line,6) "*-*" array[line]                              -- "array" contains the source code
  Say "Error" major "running" inFile "line" line":" token.message  -- "inFile" is the input filename
  Say "Error" major"."minor": " token.secondaryMessage

  Return -major                                                    -- Should be returned when Syntax error
End
```

## Public methods

### new (class method)

```
   ╭──────╮  ┌────────┐                          ╭───╮
▸▸─┤ new( ├──┤ source ├──┬─────────────────────┬─┤ ) ├─▸◂
   ╰──────╯  └────────┘  │ ╭───╮  ┌──────────┐ │ ╰───╯
                         └─┤ , ├──┤ detailed ├─┘
                           ╰───╯  └──────────┘
```

Returns a new tokenizer specialized to the _source_ program. _Source_ must be a (non-sparse) array of strings. The optional argument, _detailed_, has no effect when
the tokenizer is used in "basic" mode. When used in "full" mode, _detailed_ must be a boolean, which determines whether ignored (or "absorbed") tokens will be
kept as an optional attribute of the returned full tokens. When _detailed_ is __1__ (the default), ignored tokens are kept as an array, which can be accessed
using "absorbed" as a tail for the returned stem. When _detailed_ is __0__, ignored tokens are discarded.

### getFullToken

```
   ╭──────────────╮
▸▸─┤ getFullToken ├─▸◂
   ╰──────────────╯
```

The _getFullToken_ method selects the next "full" token in the source file and returns a stem containing the details that describe this token.

"Full" tokens build over "simple" tokens, by applying Rexx rules and ignoring certain elements:

* Classic comments and line comments are ignored.
* Blanks adjacent to special characters are ignored, except when they can be interpreted as a concatenation operator.
* Two consecutive end of clause markers (i.e., an explicit semicolon, or an end of line) are reduced to a single end of clause marker (the second one would constitute an ignorable null clause).
* Blanks at the beginning of a clause are ignored.
  
The ignoring process is not a simple discarding. On the one hand, the location of each full token is adjusted, so that the original source can always be reconstructed by examining the locations of the returned tokens. On the other hand, if the _detailed_ parameter is specified as __1__ when creating the tokenizer instance, all the ignored tokens, including the original non-ignored token, can be accessed as an array which is the value of ``token[absorbed]``.

Sequences of special characters are collected to see if they form a multi-character operator, line "\==", an extended assignment token, like "+=", or a directive-start marker, like "::".

#### Error handling

When the tokenizer encounters a syntax error, it returns a special token describing the error. Please note that the full tokenizer detects a series of errors that are not detected by the simple tokenizer. For example, when a directive start sequence, "::", is followed by a symbol that is not the name of a directive, the full tokenizer emits an error and stops, but the simple tokenizer does not detect any error. A higher-level parser making use of the tokenizer may detect errors that are still earlier than the one returned. See the documentation for the _syntax_error_ method for details.

#### Important note

Using [``getSimpleToken``](#getSimpleToken) and [``getFullToken``](#getFullToken) with the same tokenizer instance can lead to impredictable results.

### getSimpleToken

```
   ╭────────────────╮
▸▸─┤ getSimpleToken ├─▸◂
   ╰────────────────╯
```

The [``getSimpleToken``](#getSimpleToken) method selects the next token in the input file and returns a stem containing the details that describe this token.

The components of a returned stem ``t.`` are the following:

* ``t.class``, selected between the non-indented elements of the [``tokenClasses``](#tokenClasses) constant, excluding those marked as "Level 2".
* ``t.subclass``, selected between the indented elements of the tokenClasses constant above (when there is no indented element, ``t.class == t.subclass``). Subclasses identified as "Level 2" are not considered in a 
  simple tokenizing.
* ``t.value``. In general, this is the character representation of the token itself, but in some cases it can differ. For example, in the case of strings, this is the string value,
  independent of whether its specification has used or not internal double quotes, or it is any of the X-, B- or U- suffixed strings.
  That is, in the ASCII encoding, ``t.value`` is identical when the token was ``"a"``, ``"61"X``, ``"0110 0001"B`` or ``"0061"U``.
* ``t.location``. This component has the form ``line1 start line2 pos`` and identifies the start position of the token, and the end position, plus one character. ``Line1`` and ``line2`` will always be identical, except 
  in the case of multi-line comments.
  
__Important note__

Using [``getSimpleToken``](#getSimpleToken) and [``getFullToken``](#getFullToken) with the same tokenizer instance can lead to impredictable results.

### syntax_error

```
                                                                            ╭───╮
                                                                        ┌───┤ , ├───┐
                                                                        │   ╰───╯   │
   ╭───────────────╮  ┌──────┐  ╭───╮  ┌───────┐  ╭───╮  ┌─────┐  ╭───╮ │ ┌───────┐ │ ╭───╮
▸▸─┤ syntax_error( ├──┤ code ├──┤ , ├──┤ start ├──┤ , ├──┤ end ├──┤ , ├─┴─┤ value ├─┴─┤ ) ├─▸◂
   ╰───────────────╯  └──────┘  ╰───╯  └───────┘  ╰───╯  └─────┘  ╰───╯   └───────┘   ╰───╯
```

Returns a special type of token, ``SYNTAX_ERROR``, that includes extra information to identify a syntax error. The arguments to _syntax_error_ are:

* The error _code_, in the format ``major.minor``.
* The _start_ location and the _end_ location. Their format is ``startLine startCol endLine endCol``. The location of the error token will be the start position of the _start_ location followed by the end position of the _end_ location.
* The following arguments are the substitution instances for the secondary error message.

The tokenizer uses the _syntax_error_ method to return special tokens when a syntax error is encountered. Both the class and the subclass components of the returned stem are ``SYNTAX_ERROR``. Other components of the returned stem ``token.`` are:

* ``value`` is the main error message. Same as ``message``.
* ``message`` is the main error message. Same as ``value``.
* ``number`` is the error number, in the ``major.minor`` format, as specified in the first argument to _syntax_error_.
* ``secondaryMessage`` is the secondary error message, with all substitutions applied.
* ``line`` is the line number where the error occurred.

## Implementation notes

### Private routines

### ErrorMessage

```
     ╭───────────────╮  ┌────────┐  ╭───╮  ┌─────────────┐  ╭───╮
▸▸───┤ ErrorMessage( ├──┤ number ├──┤ , ├──┤ subst_array ├──┤ ) ├─▸◂
     ╰───────────────╯  └────────┘  ╰───╯  └─────────────┘  ╰───╯
```

Returns an array containing the major and minor error messages (in this order) associated to the specified _code_, which has to take the form _major.minor_ (where _major_
is the major error code, and _minor_ is the minor error code), with all placeholder instances substituted by the values of the array _subst_array_.

This routine returns different error messages, depending on the tokenizer subclass. For example, error 6.1 is ``'Unmatched comment delimiter ("/*") on line &1'``, with one
substitucion instance, for ooRexx, but ``'Unmatched comment delimiter (""/*")'`` for Regina Rexx, with no substitution instances.

### Private methods

### InitializeActionPairs 

```
   ╭───────────────────────╮
▸▸─┤ InitializeActionPairs ├─▸◂
   ╰───────────────────────╯
```

``InitializeActionPairs`` implements the ``Action.`` stem, which is the core of the finite state automaton implementing the full tokenizing phase. Simple tokens are examined in a window of two consecutive tokens, and a series of actions is activated by examining the classes of these tokens. For example, a ``BLANK`` adjacent to a ``COLON`` can always be ignored ("absorbed"), and so on.

### InitializeCharacterCategories  

```
   ╭───────────────────────────────╮
▸▸─┤ InitializeCharacterCategories ├─▸◂
   ╰───────────────────────────────╯
```

Each character in the ``"00"X.."FF"X`` range is assigned a character category, simbolized by a single character: digits (``"0".."9"``) are assigned the category "digit" (``"d"``), letters (``"a".."z"`` and ``"A".."Z"``, plus ``"_"``, ``"?"``, ``"!"`` and some other implementation-dependent characters) are assigned the "general_letter" (``"l"``) category, and so on.

```rexx
digit              = "d"
general_letter     = "l"
...
simple_symbol      = general_letter || digit
var_symbol_char    = simple_symbol  || "."
...
Call AssignCharacterCategory digit,              "0123456789"
Call AssignCharacterCategory general_letter,     "_!?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
...
```

When we are about to tokenize a line ``L``, we will use the ``TRANSLATE`` BIF to obtain a new string containing the character categories of each individual character in ``L``. 

```rexx
input_line           = 'id123.xyz = id123.xyz + 1'
character_categories = 'llddd.lll o llddd.lll o d'
```

This allows a very efficient determination of the token boundaries. For example, a run of ``"d"`` will identify a simple number, a run of ``"d"`` or ``"l"`` will identify a simple symbol, and so on.
The fragment of code below shows how the tokenizer handles tokens that start with a letter; they can be either a simple variable, a stem variable, or a compound variable.

```rexx
Call skipCharsUntilNot simple_symbol -- Skip all letters and digits

-- Neither a letter, a digit or a period? This is a simple symbol
If thisCharIsNotA( "." )             Then Return Token( VAR_SYMBOL, SIMPLE_VAR )
     
-- That was a period. Skip it
Call nextChar
     
-- End of symbol? This is a stem
If thisCharIsNotA( var_symbol_char ) Then Return Token( VAR_SYMBOL, STEM_VAR )
     
-- If there is any stuff after the period, that's a compound symbol
Call skipCharsUntilNot var_symbol_char
     
Return Token( VAR_SYMBOL, COMPOUND_VAR )
```

### InitializeClasses 

```
   ╭───────────────────╮
▸▸─┤ InitializeClasses ├─▸◂
   ╰───────────────────╯
```

This method scans the [``tokenClasses``](#tokenClasses) vector and assigns the values of the corresponding constants. It also creates some useful compound values, like ``STRING_OR_SYMBOL``, or ``CLAUSE``.

### InitializeDirectives 

```
   ╭──────────────────────╮
▸▸─┤ InitializeDirectives ├─▸◂
   ╰──────────────────────╯
```

This method creates a stem that will be used to discriminate if a symbol is a valid directive name or not.

### InitializeKeywordInstructions 

```
   ╭───────────────────────────────╮
▸▸─┤ InitializeKeywordInstructions ├─▸◂
   ╰───────────────────────────────╯
```

The ``InitializeKeywordInstructions`` method creates the ``keywordInstruction.`` stem, which allows us to determine whether a certain 
``SIMPLE_VAR VAR_SYMBOL`` is a candidate to start a ``KEYWORD_INSTRUCTION`` or not. The stem is customized for the ooRexx, Regina and ANSI cases.

### InitializeOperatorTable

```
   ╭─────────────────────────╮
▸▸─┤ InitializeOperatorTable ├─▸◂
   ╰─────────────────────────╯
```

The ``InitializeOperatorTable`` method creates the ``operator_subclass.`` stem. This stem allows us to discriminate which operator character combinations constitute valid Rexx operators, and which is its corresponding syntactic category (``ADDITIVE_OPERATOR``, ``LOGICAL_OPERATOR``, etc.) that should be assigned to those operators.

### InitializeSimpleTokenizer 

```
   ╭───────────────────────────╮
▸▸─┤ InitializeSimpleTokenizer ├─▸◂
   ╰───────────────────────────╯
```

The ``InitializeSimpleTokenizer`` method initializes a series of variables that will hold the context when tokenizing a ``::RESOURCE`` directive.

### InitializeStringSuffixes

```
   ╭──────────────────────────╮
▸▸─┤ InitializeStringSuffixes ├─▸◂
   ╰──────────────────────────╯
```

The ``InitializeStringSuffixes`` method builds a stem that maps string suffixes (i.e., "X", "B", "Y", "P", "T" and "U") to their corresponding [``tokenClasses``](#tokenClasses).


### InitializeTokenizer 

```
   ╭──────────────────────╮
▸▸─┤ InitializeTokenizer  ├─▸◂
   ╰──────────────────────╯
```

The ``InitializeTokenizer`` method sets a number of variables to track the special context for ``THEN`` clauses, the special token supplied at begin-of-source, and the extra buffer used when we are forced, in the full tokenizer, to insert certain symbols, for example, a semicolon after a label, or a ``THEN``, ``ELSE`` or ``OTHERWISE`` clauses.
