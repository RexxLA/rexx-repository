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

### New built-in functions

* ``BYTES(string)`` converts a string to the BYTES format, i.e., to a format where the basic components of a string are bytes. This is equivalent to Classic Rexx strings, but with some enhancements desceibed below.
* ``CODEPOINTS(string)`` converts a string to the CODEPOINTS format, i.e., to a format where the basic component of a string is the Unicode codepoint.
  The _string_ is expected to contain valid UTF-8; a Syntax error will be raised if _string_ contains ill-formed characters.
* ``C2U(string[, format])`` (Character to Unicode): Returns a string, in character format, that represents string converted to Unicode codepoints.
  By default, C2U returns a list of blank-separated hexadecimal representations of the codepoints. The format argument allows to select different formats for the returned string:
    * When _format_ is the null string or ``"CODES"`` (the default), C2U returns a list of blank-separated hexadecimal codepoints.
      Codepoints larger than ``"FFFF"X`` will have their leading zeros removed, if any. Codepoints smaller than ``"10000"X`` will always have four digits (by adding zeros to the left if necessary).
    * When _format_ is ``"U+"``, a list of hexadecimal codepoints is returned. Each codepoint is prefixed with the characters ``"U+"``.
    * When _format_ is ``"NAMES"``, each codepoint is substituted by its corresponding name or label, between parenthesis.
      For example, ``C2U("S") == "(LATIN CAPITAL LETTER S)"``, and ``C2U("0A"X) = "(<control-000A>)"``.
    * When _format_ is ``"UTF-32"``, a UTF-32 representation of the string is returned.
* ``DECODE(string, encoding, [format], [errorHandling])``. ``DECODE`` tests whether a _string_ is encoded according to a certain _encoding_, and optionally decodes it to a certain _format_.
    * ``DECODE`` works as an _encoding_ validator when _format_ is omitted, and as a decoder when _format_ is specified. It is an error to omit _format_ and to specify a value for _errorHandling_ at the same time (that is, if _format_ was omitted, then _errorHandling_ should be omitted too).
    * When ``DECODE`` is used as validator, it returns a boolean value, indicating if the string is well-formed according to the specified encoding.
      For example, ``DECODE(string,"UTF-8")`` returns __1__ when string contains well-formed UTF-8, and __0__ if it contains ill-formed UTF-8.
    * To use DECODE as a decoder, you have to specify a _format_. This argument accepts a blank-separated set of tokens.
      Each token can have one of the following values: "UTF8", "UTF-8", "UTF32", or "UTF-32" (duplicates are allowed and ignored).
      When "UTF8" or "UTF-8" have been specified, a UTF-8 representation of the decoded string is returned.
      When "UTF32" or "UTF-32" have been specified, UTF-32 representation of the decoded string is returned.
      When both have been specified, an two-items array is returned. The first item of the array is the UTF-8 representation of the decoded string,
      and the second item of the array contains the UTF-32 representation of the decoded string.
    * The optional _errorHandling_ argument determines the behaviour of the function when the format argument has been specified.
      If if has the value ``""`` (the default) or ``"NULL"``, a null string is returned when there a decoding error is encountered.
      If it has the value ``"REPLACE"``, any ill-formed character will be replaced by the Unicode Replacement Character (``U+FFFD``).
      If it has the value ``"SYNTAX"``, a Syntax condition will be raised when a decoding error is encountered.
* ``ENCODE(string, encoding [, errorHandling])``.  ``ENCODE`` first attempts to normalize the _string_, if necessary.
  Once the _string_ is normalized, encoding is attempted using the specified _encoding_. _ENCODE_ returns the encoded string,
  or a null string if any of normalization or encoding failed. You can influence the behaviour of the function when an error is encountered by specifying the optional _errorHandling_ argument.
  When _errorHandling_ is not specified, is ``""`` or is ``"NULL"`` (the default), a null string is returned if an error is encountered.
  When _errorHandling_ has the value ``"SYNTAX"``, a Syntax error is raised if an error is encountered.
* ``N2P( name )`` (Name to codePoint). Returns the hexadecimal Unicode codepoint corresponding to _name_, or the null string if _name_ does not correspond to a Unicode codepoint.
  ``N2P`` accepts _names_, as defined in the second column of ``UnicodeData.txt`` (that is, the Unicode "Name" \["Na"\] property), like ``"LATIN CAPITAL LETTER F"`` or ``"BELL"``;
  aliases, as defined in ``NameAliases.txt``, like ``"LF"`` or ``"FORM FEED"``, and labels identifying codepoints that have no names, like ``"<Control-0001>"`` or ``"<Private Use-E000>"``.
  When specifying a _name_, case is ignored, as are certain characters: spaces, medial dashes (except for the ``"HANGUL JUNGSEONG O-E"`` codepoint) and underscores that replace dashes.
  Hence, ``"BELL"``, ``"bell"`` and ``"Bell"`` are all equivalent, as are ``"LATIN CAPITAL LETTER F"``, ``"Latin capital letter F"`` and ``"latin_capital_letter_f"``.
  Returned codepoints will have a minimum length of four digits, and will never start with a zero if they have more than four digits.
* ``P2N( codepoint )`` (codePoint to Name). Returns the name or label corresponding to the hexadecimal Unicode _codepoint_ argument, or the null string if the codepoint has no name or label.
  The argument _codepoint_ is first verified for validity. If it is not a valid hexadecimal number or it is out-of-range, a null string is returned.
  If the _codepoint_ is found to be valid, it is then normalized: if it has less than four digits, zeros are added to the left,
  until the _codepoint_ has exactly four digits; and if the _codepoint_ has more than four digits, leading zeros are removed, until no more zeros are found or the _codepoint_ has exactly four characters.
  Once the _codepoint_ has been validated and normalized, it is uppercased, and the Unicode Character Database is then searched for the "Name" ("Na") property.
  If the _codepoint_ has a name, that name is returned.
  If the codepoint does not have a name but it has a label, like ``"<control-0010>"``, that label is returned. In all other cases, the null string is returned.
  __Note__. Labels are always enclosed between ``"<"`` and ``">"`` signs. This allows to quickly distinguish them from names.
* ``STRINGTYPE( string [, type] )``.  If you specify only _string_, it returns ``TEXT`` when _string_ is a TEXT string,
  ``CODEPOINTS`` when _string_ is a CODEPOINTS string, and ``BYTES`` when _string_ is a BYTES string. If you specify _type_, it returns __1__ when
  _string_ matches the _type_. Otherwise, it returns __0__. The following are valid types: 
    * ``BYTES``. Returns __1__ if the string is a BYTES string.
    * ``CODEPOINTS``. Returns __1__ if the string is a CODEPOINTS string.
    * ``TEXT``. Returns __1__ if the string is a TEXT string.
* ``TEXT(string)`` converts a string to the TEXT format, i.e., to a format where the basic components of a string are extended grapheme clusters.
  The _string_ is expected to contain valid UTF-8; a Syntax error will be raised if _string_ contains ill-formed characters.

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
