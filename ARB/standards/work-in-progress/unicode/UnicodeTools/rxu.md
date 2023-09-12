# The RXU Rexx Preprocessor for Unicode

## Description

The __RXU Rexx Preprocessor for Unicode__ is implemented by a set of Rexx programs. The most visible one is a new command called ``rxu.rex``. 

__RXU__ reads a ``.rxu`` program and attempts to translate it to standard ``.rex`` code (RXU needs the Unicode library, ``Unicode.cls``, and will automatically use it). 
If no errors are found in the translation pass, the resulting ``.rex`` program is then executed, after which it is deleted. 
RXU programs can be written using an extended Rexx syntax that implements a set of Unicode and non-Unicode literals, several new BIFs and BIMs, 
and a system of polymorphic BIFs that allow the programmer to continue using the same concepts and BIFs that in Classic Rexx, 
and at the same time take advantage of the power and novelties of the Unicode world.

## What we do and what we don't do

RXU is a work-in-progress, not a finished product. Some parts of Rexx have been made to appear as "Unicode-ready", and some others have not. This can produce all kind of unexpected results. Use at your own risk!

The major focus of the translator is to implement Unicode-aware Classic Rexx: in this sense, priority is given, for example, 
to the implementation of Built-in Functions (BIFs) over Built-in Methods (BIMs). 
For instance, currently you will find a Unicode-aware implementation of several stream i/o BIFs, but no reimplementation of the Stream I/O classes.

## Here is a list of what is currently implemented

### [Four new types of string](doc/string-types.md)

### [Revised built-in functions](doc/built-in.md)

### [New built-in functions](doc/new-functions.md)

### New classes

* ``BYTES``. A class similar to Classic Rexx strings. A BYTES string is composed of bytes, and all the BIFs work as in pre-Unicode Rexx. The BYTES class adds a ``C2U`` method (see the description of the ``C2U`` BIF for 
  details), and reimplements a number of ooRexx built-in methods: \[\], C2X, CENTER, CENTRE, DATATYPE (a new option, ``"C"``, is implemented: ``DATATYPE(string,"C")`` will return __1__ when and only when ``"string"U`` 
  would be a valid Unicode string), LEFT, LENGTH, LOWER, POS, REVERSE, RIGHT, SUBSTR, U2C (same as ``X2C``, but for ``U`` strings), and UPPER.
* ``CODEPOINTS``. A CODEPOINTS string is composed of Unicode codepoints. CODEPOINTS is a subclass of BYTES. The CODEPOINTS class redefines the most basic BIMs (\[\] and LENGTH), and the other BIMs, being defined on 
  those, work automatically.
* ``TEXT``. A TEXT string os composed of Unicode extended grapheme clusters. TEXT is a subclass of CODEPOINTS. The TEXT class redefines the most basic BIMs (\[\] and LENGTH), and the other BIMs, being defined on
  those, work automatically.

### New OPTIONS

#### OPTIONS DEFAULTSTRING

``OPTIONS DEFAULTSTRING`` _default_, where _default_ can be one of __BYTES__ (the default), __CODEPOINTS__, __TEXT__ or __NONE__. 
This affects the semantics of numbers and unsuffixed strings, i.e., ``"string"``, without an explicit B, X, Y, P, T or U suffix. 
If _default_ is NONE, numbers and strings are not converted (i.e., they are handled as default Rexx numbers and strings). 
In the other cases, numbers and strings are transformed to the corresponding type. For example, if OPTIONS DEFAULTSTRING TEXT is in effect, ``"string"``, will automatically be a TEXT string,
as if ``"string"T`` had been specified, i.e., ``"string"`` will be composed of extended grapheme clusters, and if OPTIONS DEFAULTSTRING CODEPOINTS is in effect, ``12.3`` will automatically
be a CODEPOINTS string, as if ``CODEPOINTS(12.3)`` had been specified.

__Note.__ Currently, OPTIONS DEFAULTSTRING does not apply to variable and constant symbols. This will be fixed in a future release.

__Implementation restriction:__ This is currently a global option. You can change it inside a procedure, and it will apply globally, not only to the procedure scope.

__Examples.__

```
Say Stringtype("string")                          -- BYTES (the default)
Options Defaultstring CODEPOINTS
Say Stringtype("string")                          -- CODEPOINTS
Say Stringtype(1024)                              -- CODEPOINTS too
Say Stringtype("12"X)                             -- BYTES: X, B and U strings are always BYTES strings
Say Stringtype("string"T)                         -- TEXT (Explicit suffix)
```

#### OPTIONS COERCIONS

``OPTIONS COERCIONS`` _behaviour_, where _behaviour_ can be one of __PROMOTE__, __DEMOTE__, __LEFT__, __RIGHT__ or __NONE__. This instruction determines
the behaviour of the language processor when a binary operation is attempted in which the operators are of different string types, for example,
when a BYTES string is contatenated to a TEXT string, or when a CODEPOINTS number is added to a BYTES number.

* When _behaviour_ is __NONE__ a Syntax error will be raised.
* When _behaviour_ is __PROMOTE__ (the default), the result of the operation will have the type of the highest operand (i.e., TEXT when at least one of the operands is TEXT, or else CODEPOINTS
  when at least one of the operands is CODEPOINTS, or BYTES in all other cases).
* When _behaviour_ is __DEMOTE__, the result of the operation will have the type of the lowest operand (i.e., BYTES when at least one of the operands is BYTES, or else CODEPOINTS
  when at least one of the operands is CODEPOINTS, or TEXT in all other cases).
* When _behaviour_ is __LEFT__, the result of the operation will have the type of the left operand.
* When _behaviour_ is __RIGHT__, the result of the operation will have the type of the right operand.

Currently, OPTIONS COERCIONS is implemented for concatenation, arithmentic and logical operators only. 

__Note.__ This variant of the OPTIONS instruction is _highly experimental_. Its only purpose is to allow experimentation with implicit coercions. Once a decision is taken about
the preferred coercion mechanism, it will be removed.

__Implementation restriction:__ This is a global option. You can change it inside a procedure, and it will apply globally, not only to the procedure scope.

__Examples.__

```
Options Coercions Promote
Say Stringtype( "Left"B || "Right"P )             -- CODEPOINTS
Say Stringtype( "Left"B || "Right"T )             -- TEXT
Say Stringtype( "Left"P || "Right"T )             -- TEXT
Options Coercions Demote
Say Stringtype( "Left"B || "Right"P )             -- BYTES
Say Stringtype( "Left"B || "Right"T )             -- BYTES
Say Stringtype( "Left"P || "Right"T )             -- CODEPOINTS
Options Coercions Right
Say Stringtype( "Left"B || "Right"P )             -- CODEPOINTS
Say Stringtype( "Left"B || "Right"T )             -- TEXT
Say Stringtype( "Left"P || "Right"T )             -- TEXT
Options Coercions None
Say Stringtype( "Left"B || "Right"B )             -- BYTES
Say Stringtype( "Left"B || "Right"P )             -- Syntax error
```

## The RXU command

``RXU filename`` converts a file named ``filename`` (default extension: ``.rxu``) into a ``.rex`` file, and then interprets this ``.rex`` file. Ny default, the
``.rex`` file is deleted at the end of the process-

### Format:                                                                  

```                                                                           
[rexx] rxu [options] filename [arguments]                              
```

__Options:__

```
    -help, -h  : display help for the RXU command                          
    -keep, -k  : do not delete the generated .rex file                     
    -nokeep    : delete the generated .rex file (the default)              
    -warnbif   : warn when using not-yet-migrated to Unicode BIFs
    -nowarnbif : don't warn when using not-yet-migrated to Unicode BIFs (the default)
```
