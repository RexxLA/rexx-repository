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

### Four new types of string

* ``"string"Y``, a Classic Rexx string, composed of BYTES.
* ``"string"P``, a CODEPOINTS string (checked for UTF8 correctness at parse time)
* ``"string"T``, a TEXT string (checked for UTF8 correctness at parse time)
* ``"string"U``, a Unicode codepoint string. Codepoints can be specified using
    * Hexadecimal notation (like 61, 0061, or 0000),
    * Unicode standard U+ notation (like U+0061 or U+0000),
    * or as a name, alias or label enclosed in parenthesis (like "(cr)", "(CR) (LF)", "(Woman) (zwj) (Man)").
  A "U" string is always a BYTES string.

### Revised built-in functions

C2X, CHARIN, CHAROUT, CHARS, CENTER, CENTRE, COPIES, DATATYPE, LEFT, LENGTH, LINEIN, LINEOUT, LINES, LOWER, POS, REVERSE, RIGHT, STREAM, SUBSTR, UPPER. 
Please refer to the documentation for Unicode.cls and Stream.cls for a detailed description of these enhanced BIFs.

See [a presentation of the Unicode-enabled stream functions](doc/stream.md).

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

``OPTIONS DEFAULTSTRING`` _default_, where _default_ can be one of BYTES, CODEPOINTS, TEXT or NONE. 
This affects the semantics of unsuffixed strings, i.e., ``"string"``, without an explicit B, X, Y, P; T or U suffix. 
If _default_ is NONE, strings are not converted (i.e., they are handled as default Rexx strings). 
In the other cases, strings are transformed to the corresponding type. For example, if OPTIONS DEFAULTSTRING TEXT is in effect, ``"string"``, will automatically be a TEXT string,
as if ``"string"T`` had been specified, i.e., ``"string"`` will be composed of extended grapheme clusters. 

__Implementation restriction:__ This is currently a global option. You can change it inside a procedure, and it will apply globally, not only to the procedure scope.

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
