# Rexx.Tokenizer.cls, a Rexx Tokenizer

## Introduction

The ``Rexx.Tokenizer.cls`` classfile includes a set of ooRexx classes. The main class is ``Rexx.Tokenizer``. 
It implements both a _basic_ and a _full_ Rexx tokenizer (see below for definitions of _basic_ and _full_ tokenizing). 
The ``getSimpleToken`` method returns basic Rexx tokens and non-tokens character sequences, like comments and whitespace, 
while the ``getFullToken`` method returns full tokens, after discarding null clauses, ignorable blanks and comments. 
When requesting full tokens, an optional mechanism allows access to the ignored simple tokens and some other tokens that are
not ignorable but that have been included ("absorbed") for your convenience: for example, labels include their own colon,
keyword instructions include the first blank after the keyword, if any, and so on.

The tokenizer intent is to support all the syntactical constructs of Open Object Rexx (ooRexx), Regina Rexx and ANSI Rexx. 
You can select the desired syntax subset at instance creation time by selecting the appropriate class. 

```
Rexx.Tokenizer        -- The main class
ooRexx.Tokenizer      -- Tokenizes programs written in ooRexx
Regina.Tokenizer      -- Tokenizes programs written in Regina Rexx
ANSI.Rexx.Tokenizer   -- Tokenizes programs written in ANSI Rexx
```

Subclasses starting with "Regina" accept the Regina Rexx syntax; subclasses starting with "ANSI.Rexx" accept only the ANSI Rexx syntax 
(for example, comments starting with "--" are accepted by Regina but not by ANSI); subclasses starting with "ooRexx" accept ooRexx syntax; 
for example, "\[", "\]" and "~" are valid characters for ooRexx subclasses but not for Regina or ANSI subclasses.

The tokenizer supports classic comments (including nested comments), line comments and strings. ooRexx ::Resources are also handled. 

When a Unicode class is used (see below), Y-, P-, T- and U-suffixed strings are recognized, translated (in the case of U strings) and supported.

```
ooRexx.Unicode.Tokenizer      -- Tokenizes programs written in ooRexx, with experimental Unicode extensions
Regina.Unicode.Tokenizer      -- Tokenizes programs written in Regina Rexx, with experimental Unicode extensions
ANSI.Rexx.Unicode.Tokenizer   -- Tokenizes programs written in ANSI Rexx, with experimental Unicode extensions
```

The full tokenizer is not a full AST parser, but it returns a lof of useful semantical information, like the instruction type, the directive type,
the kind of variable (simple, stem or compound), etc.

## Creating a tokenizer instance

To create a tokenizer instance, you will need to construct a Rexx array containing the source file to tokenize. 

```
size   = Stream(inFile,"Command","Query Size")
array  = CharIn(inFile,,size)~makeArray
tokenizer = .ooRexx.Tokenizer~new(array)           -- Or Regina.Tokenizer, etc.
```

You will also have to decide whether you will be using the _simple tokenizer_ (i.e., you will be getting tokens using the ``getSimpleToken`` tokenizer method),
or you will prefer to use the _full tokenizer_ (i.e., you will be getting your tokens using the ``getFullToken tokenizer method).

```
tokenizer = .ooRexx.Tokenizer~new(array)

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

## An example: simple and full tokens, 

### Structure of simple tokens

Let us start with a very simple piece of code:
```
i = i + 1
```
We will create a test file, say ``test.rex``, and run it through ``inspectSimple.rex``, a sample utility program you will find in the ``parser`` directory. 
```
inspectSimple test.rex
```
Here is the output of the program, prettyprinted and commented for your convenience.
```
 1   [1 1 1 1]: ''  (; B)  -- Automatically generated BEGIN_OF_SOURCE marker.
 2   [1 1 1 2]: 'i' (V 1)  -- A simple variable
 3   [1 2 1 3]: ' ' (b b)  -- A blank run consisting of a single blank
 4   [1 3 1 4]: '=' (o o)  -- An operator. It happens to work as an assignment in this position
 5   [1 4 1 5]: ' ' (b b)  -- Another blank
 6   [1 5 1 6]: 'i' (V 1)  -- The same variable as before
 7   [1 6 1 7]: ' ' (b b)  -- One blank more
 8   [1 7 1 8]: '+' (o o)  -- A plus sign, denoting addition
 9   [1 8 1 9]: ' ' (b b)  -- Still one more blank
10  [1 9 1 10]: '1' (N 4)  -- A number (the smallest positive integer)
11 [1 10 1 10]: ''  (; L)  -- An END_OF_LINE indicator (which works as an implied semicolon)
```
* The first column is a _counter_.
* The second column is an aggregate, the _location_ of the token. We have written if between \[brackets\].
  It is of the form _starting-position_ _ending-position_, where each _position_ is a _line-column_ sequence.
  The ending position if the first character _after_ the returned token. For example, the first "i" in the line
  runs from position (1,1) to position (1,2).
* The third column, after a colon and between simple quotes, is the _value_ of the token. Generally speaking,
  this is the token itself, but in some cases (classic comments, resources) only an indicator is returned
  (you can always reconstitute the original comment or resource by referring to the _location_ attribute
  of the token). In some other cases, the _value_ contains an elaboration of the original token: for example,
  an X, B or U string will be interpreted, so that their value can be substituted in the source file ("(man)"U,
  for instance, will generate a value of "👨").
* The fourth column contains two values, grouped by parenthesis. These are the _class_ and the _subclass_ of the token.
  They give a lot of information about the nature of the token (e.g., this is a NUMBER \[class\], subclass INTEGER; or
  this is a VAR_SYMBOL \[class\], subclass SIMPLE \[i.e., not a stem or a compound variable\]) and will be described below

How does the ``inspectSimple.rex`` program work? Well, essentially what it does is the following: it instantiates a
tokenizer instance, and then it runs it, by calling the ``getSimpleToken`` method, until either the end of file is reached
or a syntax error is encountered. Now, here is the trick: ``getSimpleToken`` _returns tokens... which are Rexx stems!_ 
(you can already imagine the components of these stems):

```
-- after
token. = tokenizerInstance~getSimpleToken
-- we have (assume that we have just scanned the second "i" of the above program)
token.class    -- The CLASS of the token, i.e., V (stands for VAR_SYMBOL)
token.subClass -- The SUBCLASS of the token, i.e., 1 (stands for SIMPLE)
token.location -- The LOCATION of the token, i.e., "1 5 1 6"
token.value    -- The VALUE of the token, i.e., "1".
```

Now you know practically everything there is to know about simple tokens (indeed, there are only two things more
to know, if you limit yourself to simple tokenizing: _error tokens_, and _end-of-file conditions_; we will get
to both of these shortly).

### Structure of full tokens (undetailed)

What happens now if we want _full_ tokens, instead of _simple_ ones? Well, we have a corresponding
``inspectFull.rex`` utility program: it calls ``getFullToken`` instead of ``getSimpleToken``. 
Let us have a look at its output. Some tokens are the same as before, but some others have experienced some
modifications. Let us focus on those:

    1   [1 1 1 1]: ''  (; B)
    2   [1 1 1 2]: 'i' (O 1)
    3   [1 2 1 5]: '=' (o c) -- "=" has grown to include the blanks before and after
    4   [1 5 1 6]: 'i' (V 1)
    5   [1 6 1 9]: '+' (o a) -- "+" has grown to include the blanks before and after
    6  [1 9 1 10]: '1' (N 4)
    7 [1 10 1 10]: ''  (; L)

What has changed, exactly? Well, both the "=" operator and the "+" operator seem to have "grown".
Indeed, they have "eaten" the corresponding blanks. This strictly follows the rules of Rexx:
blanks before and after operator characters are ignored. The tokenizer ignores the blanks, but
at the same time does not want to lose information, so that it "expands" the absorbing tokens
by making them wider, so that they can (so to speak) "accomodate" the ignored blanks: the "="
on line 3 runs now from (1 2 1 3) \[where the previous blank is located\] to (1 4 1 5) \[where
the next blank is located\].

There are some other, subtle, changes in the returned results. The _class_ of "i" has changed,
it is no longer "V" (VAR_SYMBOL), but "O" (ASSIGNMENT_INSTRUCTION). The full tokenizer "knows"
that ``i = i + 1`` is an assignment instructions, and it passes this knowledge to us.
Similarly, the _subclass_ of "=" has changed. Previously, it was "o", for OPERATOR: all the
tokenizer knew was that "=" was an operator character. Now it is "c", COMPARISON_OPERATOR,
which is more informative. Similarly, "+" has now a subclass of "a", ADDITIVE_OPERATOR.

### Structure of full tokens (detailed)

As we mentioned above, when using the full tokenizer, you have the option to request a _detailed_ 
tokenizing. You do so at instance creation time, by specifying the optional, boolean, _detailed_ argument:

```
detailed = .true
tokenizer = .ooRexx.Tokenizer~new(array, detailed)
```
There is a corresponding ``inspectFullDetailed.rex`` utility program to test this feature. Let us try it,
once more, on our test program. We will get something similar to the following (we have added comments
and some prettyprinting):

```
1   [1 1 1 1]: ''  (; B)
2   [1 1 1 2]: 'i' (O 1)
3   [1 2 1 5]: '=' (o c)              -- If this token is the stem "token." ...
       ---> Absorbed:
       1 [1 2 1 3] (b b): ' '        -- ...then these subtokens are in token.absorbed[1], ...
       2 [1 3 1 4] (o o): '=' <==    -- ...token.absorbed[2], and...
       3 [1 4 1 5] (b b): ' '        -- ...token.absorbed[3].
4   [1 5 1 6]: 'i' (V 1)
5   [1 6 1 9]: '+' (o a)
       ---> Absorbed:
       1 [1 6 1 7] (b b): ' '
       2 [1 7 1 8] (o o): '+' <==    -- The "original" main token is indexed by token.cloneIndex, so that...
       3 [1 8 1 9] (b b): ' '        -- ...token.absorbed[token.cloneIndex] is that token.
6  [1 9 1 10]: '1' (N 4)
7 [1 10 1 10]: ''  (; L)
```

The non-indented lines are identical to the previous listing. The indented ones show us some new components
of a full token, when a detailed tokenizing is requested:

* ``token.absorbed`` is an array of "absorbed" tokens. If there are no absorbed tokens, ``token.~hasIndex(absorbed)`` is
  false.
* ``token.cloneIndex`` is the index in ``token.absorbed`` of the "original" token. For example, when a "=" operator
  absorbs two blanks, these blanks are ignorable, but the "=" operator is the "original", main, non-ignorable token.
  In that case, ``token.cloneIndex`` will be the index of the "=" operator in the ``absorbed`` array.

## Constants, classes and subclasses

A token ``t.`` has a _class_, ``t.class``, and a _subclass_, ``t.subclass``. Classes and subclasses are defined in the
``tokenClasses`` constant of the ``Rexx.Tokenizer`` class. The ``tokenClasses`` constant itself is an array of constants,
so that you can use the following code to replicate these constants in your own program:

```
Do constant over tokenizer~tokenClasses
  Call Value constant[1], constant[2]
End
```

You should always use this construction, instead of relying in the internal values of the constants: these values
can be changed without notice.

Here is the full value of the ``tokenClasses`` constant:

```
::Constant tokenClasses (    -            --
  ( SYNTAX_ERROR                   , "E" ), -  -- Special token returned when a Syntax error is found
  ( OPERATOR                       , "o" ), -
                                            -  -- +--- All subclasses of OPERATOR are full tokenizer only
    ( ADDITIVE_OPERATOR            , "a" ), -  -- | "+", "-" 
    ( COMPARISON_OPERATOR          , "c" ), -  -- | "=", "\=", ">", "<", "><", "<>", ">=", "\<", "<=", "\>" 
                                            -  -- | "==", "\==", ">>", "<<", ">>=", "\<<", "<<=", "\>>"
    ( CONCATENATION_OPERATOR       , "k" ), -  -- | "||" 
    ( LOGICAL_OPERATOR             , "l" ), -  -- | "&", "|", "&&" 
    ( MESSAGE_OPERATOR             , "s" ), -  -- | "~", "~~" 
    ( MULTIPLICATIVE_OPERATOR      , "m" ), -  -- | "*", "/", "//", "%" 
    ( POWER_OPERATOR               , "p" ), -  -- | "**" 
    ( EXTENDED_ASSIGNMENT          , "x" ), -  -- | "+=", "-=", "*=", "/=", "%=", "//=", "||=", "&=", "|=", "&&=", "**=" 
                                            -  -- +--- All subclasses of OPERATOR are full tokenizer only
  ( SPECIAL                        , "s" ), -
  ( COLON                          , ":" ), -
  ( DIRECTIVE_START                , "*" ), -  -- "::" (Full tokenizer only, absorbed by directive)
  ( LPAREN                         , "(" ), -
  ( RPAREN                         , ")" ), -
  ( LBRACKET                       , "[" ), -
  ( RBRACKET                       , "]" ), -
  ( BLANK                          , "b" ), -  -- May be ignorable, or not
  ( LINE_COMMENT                   , "l" ), -  -- Up to but not including the end of the line
  ( CLASSIC_COMMENT                , "c" ), -  -- Infinite nesting allowed
  ( RESOURCE                       , "R" ), -  -- The resource itself, i.e., the array of lines
  ( RESOURCE_DELIMITER             , "T" ), -  -- End delimiter, ends resource
  ( RESOURCE_IGNORED               , "G" ), -  -- After "::Resource name ;" or "::END delimiter"
  ( END_OF_SOURCE                  , "F" ), -
  ( END_OF_CLAUSE                  , ";" ), -
    ( BEGIN_OF_SOURCE              , "B" ), -  -- Dummy and inserted. Very convenient for simplification
    ( END_OF_LINE                  , "L" ), -  -- Implied semicolon
    ( SEMICOLON                    , ";" ), -  -- An explicit semicolon
    ( INSERTED_SEMICOLON           , "I" ), -  -- For example, after a label, THEN, ELSE, and OTHERWISE
                                            -
                                            -  -- CLAUSE SUPPORT (Full tokenizer only)
                                            -  -- ==============
  ( LABEL                          , "W" ), -  -- Includes and absorbs the COLON
                                            -  -- All DIRECTIVEs include and absorb the :: marker
  ( DIRECTIVE                      , "w" ), -  -- 
    ( ANNOTATE_DIRECTIVE           , "1" ), -  -- 
    ( ATTRIBUTE_DIRECTIVE          , "2" ), -  -- 
    ( CLASS_DIRECTIVE              , "3" ), -  -- 
    ( CONSTANT_DIRECTIVE           , "4" ), -  -- 
    ( METHOD_DIRECTIVE             , "5" ), -  -- 
    ( OPTIONS_DIRECTIVE            , "6" ), -  -- 
    ( REQUIRES_DIRECTIVE           , "7" ), -  -- 
    ( RESOURCE_DIRECTIVE           , "8" ), -  -- 
    ( ROUTINE_DIRECTIVE            , "9" ), -  -- 
                                            -  --
  ( KEYWORD_INSTRUCTION            , "K" ), -  -- All KEYWORD_INSTRUCTIONs include the first blank after the keyword, if present 
    (ADDRESS_INSTRUCTION           , "a" ), -  --     
    (ARG_INSTRUCTION               , "b" ), -  -- 
    (CALL_INSTRUCTION              , "c" ), -  -- 
    (CALL_ON_INSTRUCTION           , "K" ), -  -- Includes CALL ON
    (CALL_OFF_INSTRUCTION          , "L" ), -  -- Includes CALL OFF
    (DO_INSTRUCTION                , "d" ), -  -- 
    (DROP_INSTRUCTION              , "e" ), -  -- 
    (ELSE_INSTRUCTION              , "f" ), -  -- Inserts a ";" after
    (END_INSTRUCTION               , "g" ), -  -- 
    (EXIT_INSTRUCTION              , "h" ), -  -- 
    (EXPOSE_INSTRUCTION            , "i" ), -  -- 
    (FORWARD_INSTRUCTION           , "j" ), -  -- 
    (GUARD_INSTRUCTION             , "k" ), -  -- 
    (IF_INSTRUCTION                , "l" ), -  -- 
    (INTERPRET_INSTRUCTION         , "m" ), -  -- 
    (ITERATE_INSTRUCTION           , "n" ), -  -- 
    (LEAVE_INSTRUCTION             , "o" ), -  -- 
    (LOOP_INSTRUCTION              , "p" ), -  -- 
    (NOP_INSTRUCTION               , "q" ), -  -- 
    (NUMERIC_INSTRUCTION           , "r" ), -  -- 
    (OPTIONS_INSTRUCTION           , "s" ), -  -- 
    (OTHERWISE_INSTRUCTION         , "t" ), -  -- Inserts a ";" after
    (PARSE_INSTRUCTION             , "u" ), -  -- Includes UPPER, LOWER and CASELESS (as attributes too)
    (PROCEDURE_INSTRUCTION         , "v" ), -  -- 
    (PUSH_INSTRUCTION              , "w" ), -  -- 
    (PULL_INSTRUCTION              , "x" ), -  -- 
    (QUEUE_INSTRUCTION             , "y" ), -  -- 
    (RAISE_INSTRUCTION             , "z" ), -  -- 
    (REPLY_INSTRUCTION             , "A" ), -  -- 
    (RETURN_INSTRUCTION            , "B" ), -  -- 
    (SAY_INSTRUCTION               , "C" ), -  -- 
    (SELECT_INSTRUCTION            , "D" ), -  -- 
    (SIGNAL_INSTRUCTION            , "E" ), -  -- 
    (SIGNAL_ON_INSTRUCTION         , "M" ), -  -- Includes SIGNAL ON
    (SIGNAL_OFF_INSTRUCTION        , "N" ), -  -- Includes SIGNAL OFF
    (THEN_INSTRUCTION              , "F" ), -  -- Inserts a ";" before and after
    (TRACE_INSTRUCTION             , "G" ), -  -- 
    (UPPER_INSTRUCTION             , "H" ), -  -- Regina only, no ANSI
    (USE_INSTRUCTION               , "I" ), -  -- 
    (WHEN_INSTRUCTION              , "J" ), -  -- 
  ( ASSIGNMENT_INSTRUCTION         , "O" ), -  -- Variable assignments, not message assignments        
  ( COMMAND_OR_MESSAGE_INSTRUCTION , "P" ), -  -- Cannot determine without arbitrarily large context    
                                            -  -- End of CLAUSE SUPPORT
                                            -  -- =====================
  ( VAR_SYMBOL                     , "V" ), -  
    ( SIMPLE                       , "1" ), -  
    ( STEM                         , "2" ), -
    ( COMPOUND                     , "3" ), -
  ( NUMBER                         , "N" ), -
    ( INTEGER                      , "4" ), -
    ( FRACTIONAL                   , "5" ), -
    ( EXPONENTIAL                  , "6" ), -
  ( CONST_SYMBOL                   , "C" ), -
    ( PERIOD                       , "7" ), -
    ( LITERAL                      , "8" ), -
    ( ENVIRONMENT                  , "9" ), -
  ( STRING                         , "S" ), -
    ( BINARY                       , "B" ), -
    ( HEXADECIMAL                  , "X" ), -
    ( CHARACTER                    , "C" ), -  
    ( BYTES                        , "Y" ), -  -- Unicode only. Y suffix
    ( CODEPOINTS                   , "P" ), -  -- Unicode only. P suffix
    ( TEXT                         , "T" ), -  -- Unicode only. T suffix
    ( UNOTATION                    , "U" )  -  -- Unicode only. U suffix
)
```

