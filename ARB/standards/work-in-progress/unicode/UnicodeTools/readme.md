# The Unicode Tools Of Rexx (TUTOR)

Version 0.4a, 20231002.

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│                 ═══> TUTOR is a prototype, not a finished product. Use at your own risk. <═══                 │
│                                                                                                               │
│                         Interfaces and specifications are proposals to be discussed,                          │  
│                          and can be changed at any moment without previous notice.                            │  
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## \[Cumulative change log, preparing for next release, 0.4b\]

* 20231010 &mdash; Fix [tokenizer bug](https://github.com/RexxLA/rexx-repository/issues/2), update tokenizer and docs.
* 20231008 &mdash; Implement [enhancement #3](https://github.com/RexxLA/rexx-repository/issues/3): add programs in the samples directory to the automated test suite, where reasonable.
* 20231007 &mdash; Fix [the charin.rxu bug](https://github.com/RexxLA/rexx-repository/issues/1).
* 20231006 &mdash; Start using the 'Issues' feature of GitHub. Partial fix for [the charin.rxu bug](https://github.com/RexxLA/rexx-repository/issues/1).
* 20231005 &mdash; Extensive code and doc refactoring to avoid clutter in the main directory.

---

## Quick installation

Download Unicode.zip, unzip it in some directory of your choice, and run ``setenv`` to set the path (for Linux users: use ``. ./setenv.sh``, not ``./setenv.sh``, or your path will not be set).

You can then navigate to the ``samples`` directory and try the samples by using ``[rexx] rxu filename``.

## Documentation

* [For The Unicode Tools Of Rexx (TUTOR, this file)](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/readme.md).
* [For RXU, the Rexx Preprocessor for Unicode](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/rxu.md)
  * [New types of strings](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/string-types.md)
  * [Revised built-in functions](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/built-in.md)
    * [Stream functions for Unicode](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/stream.md)
    * [The encoding/decoding model](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/encodings.md)
  * [New built-in functions](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/new-functions.md)
    * [The properties model](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/properties.md)
  * [New classes](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/classes.md)
  * [New values for the OPTIONS instruction](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/options.md)
* [For the Rexx Tokenizer](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/parser/readme.md)

## Release notes for version 0.4a, 20231002

This release, apart from a large number of documentation improvements and some small bug fixes, contains two main improvements:

* A new UTF8 built-in function has been defined. It contains the main part of the UTF-8 decoder, previously found in the ``encodings/Encoding.cls`` package. The new routine has been generalized so that it can manage
  strings in UTF-8, UTF-8Z, CESU-8, MUTF-8 and WTF-8 formats. See [the code](utf8.cls) and [the UTF8 section](doc/new-functions.md#utf8) of [this helpfile](doc/new-functions.md) for documentation details.
* Documentation has been migrated to markdown format. Most classes and routines are fully documented, and some are partially documented. Documentation includes some internal details, which in most cases are labeled as "implementation notes".

## Components of TUTOR which can be used independently

There are currently two components of TUTOR which can be used independently of TUTOR, since they have no absolute dependencies on other TUTOR components.

* [The Rexx Tokenizer](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/parser/readme.md) can be used independently of TUTOR, but you will need TUTOR
  when you use one of the Unicode subclasses.
* [The UTF8](utf8.cls) routine can be used independently of TUTOR. UTF8 detects whether Unicode.cls has been loaded (by looking for the existence of a .Bytes class that subclasses .String), and returns .Bytes strings or standard ooRexx strings as appropriate.

---

## Release notes for version 0.4, 20230901.

The main changes in the 0.4 release are (a) a big upgrade to the Rexx tokenizer, and (b) a complete rewrite of ``rxu.rex``, the Rexx Preprocessor for Unicode, to take advantage of the improvements in the tokenizer.

To know more about the upgraded tokenizer, please refer [to its readme file](parser/readme.md). Changes to the Rexx Preprocessor for Unicode are internal, and should not affect its functionality. If at all, you should find that the new version is more smooth and stable.

---

## Release notes for version 0.3b, 20230817.

Highlights:

* Four new encodings, contributed by Rony G. Flatscher (thanks!): ISO-8859-1 (alias: ISO8859-1), CP-437 (alias: CP437), CP-1252 (alias: CP1252), IBM-1047 (alias: IBM1047).
* A lot of new documentation. Documentation, though, is still a work-in-progress.
* A new ENCODE BIF.
* A new OPTIONS DEFAULTSTRING NONE. Use it when other forms of OPTIONS DEFAULTSTRING causes problems (see [the documentation for the RXU preprocessor](https://htmlpreview.github.io/?https://raw.githubusercontent.com/RexxLA/rexx-repository/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/packages/rxu.rex.html) for details).
* A lot of bug fixes and small improvements.

---

## Release notes for version 0.3

This is a BIG release, with many changes and additions, and with a lot of preliminary documentation.

The most prominent feature in this release is the addition of Unicode-enabled input/output stream built-in functions (BIFs).
Here is the [documentation for the stream BIFs](https://htmlpreview.github.io/?https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/packages/Stream.cls.html).

### Unicode-enabled streams

A stream is said to be **Unicode-enabled** when an ``ENCODING`` is specified in the ``STREAM`` ``OPEN`` command:

```rexx
   Call Stream filename, "Command", "Open read ENCODING UTF-8"
```
Stream I/O BIFs recognize that the stream is Unicode-enabled, and change their behaviour accordingly:

* The contents of the line is automatically decoded and converted to Unicode (i.e., to a UTF-8 *presentation*).
* Both ``LINEIN`` and ``CHARIN`` return strings of type ``TEXT``, composed of extended grapheme clusters.
* When you call ``CHARIN`` and specify the *length* parameter, the appropriate number of characters (grapheme clusters) are read and returned.
* Each encoding can specify its own set of end-of-line characters. For example, the IBM-1047 encoding (a variant of EBCDIC)
  specifies that ``"15"X``, the NL character, is to be used as end-of-line. Both ``LINEIN`` and ``LINEOUT`` honor this requirement, i.e.,
  when reading lines, a line will be ended by ``"15"X``, and when writing lines, they will be ended by ``"15"X`` too, instead of the
  usual LF or CRLF combination
* When using Unicode semantics, some operations can become very expensive to implement. For example, a simple direct-access character
  substitution in a file is trivial to implement for ASCII streams, but it can become prohibitive when using a variable-length encoding.
  These operations have been restricted in the current release.
* Similarly, when the Unicode-enabled stream has a string target of ``TEXT`` (the default), some operations can become prohibitive too:
  a ``TEXT`` "character" is, indeed, a grapheme cluster, and a grapheme cluster can have an arbitrary length. Direct-access character
  substitutions become too expensive to implement.

**Note**: *We should start a discussion about what features we are used to, like direct-access character substitution, make sense and should be
implemented for Unicode-enabled streams*.

### Error handling

When using a Unicode-enabled stream, encoding and decoding errors can occur. By default, ill-formed characters are replaced by the Unicode
Replacement Character (``U+FFFd``). You can explicitly request this behaviour by specifying the ``REPLACE`` option in the ``ENCODING``
of your stream:

```rexx
   Call Stream filename, "Command", "Open read ENCODING UTF-8 REPLACE"
```

``REPLACE`` is the default option for error handling. You can also specify ``SYNTAX`` as an error handling option,

```rexx
   Call Stream filename, "Command", "Open read ENCODING UTF-8 SYNTAX"
```

Finding ill-formed characters will then raise a Syntax error. If the Syntax condition is trapped, you will be able to access the
undecoded or unencoded offending line or character sequence by using the ``"QUERY ENCODING LASTERROR"`` ``STREAM`` command:

```rexx
   Call Stream filename, "Command", "Open read ENCODING UTF-8 SYNTAX"
   ...
   Signal On Syntax
   ...
   var = LineIn(filename)           -- May raise a Syntax error
   -- Do something with "var"
   ...
   Syntax:
      offendingLine = Stream(filename, "Command", "Query Encoding Lasterror")
      -- Do something with "offendingLine"
   ...
```
### Specifying the target type

By default, Unicode-enabled streams return strings of type ``TEXT``, composed of grapheme clusters. In some occasions, you may prefer
to receive ``CODEPOINTS`` strings. You can specify the target type in the ``ENCODING`` section of your ``STREAM`` ``OPEN`` command:

```rexx
   Call Stream filename, "Command", "Open read ENCODING UTF-8 TEXT"
```

When you specify ``TEXT`` (the default), returned strings are of type ``TEXT``. When you specify ``CODEPOINTS``, returned strings are
of type ``CODEPOINTS``.

**Note**: *Some operations that are easy to implement for a ``CODEPOINTS`` target type can become impractical when switching to a ``TEXT`` type.
For example, UTF-32 is a fixed-length encoding, so that with a ``CODEPOINTS`` target type, direct-access character positioning and
substitution is trivial to implement. On the other hand, if the target type is ``TEXT``, these operations become very difficult to implement*.

### STREAM QUERY extensions

The ``STREAM`` BIF has been extended to support Unicode-enabled streams:

```Rexx
  Call Stream filename, "Command", "Open read ENCODING IMB1047 CODEPOINTS SYNTAX"    -- Now "filename" refers to a Unicode-enabled stream
  Say  Stream(filename, "Command", "Query Encoding Name")                            -- "IBM1047"
  Say  Stream(filename, "Command", "Query Encoding Target")                          -- "CODEPOINTS", the name of the target type
  Say  Stream(filename, "Command", "Query Encoding Error")                           -- "SYNTAX", the name of the error handling option
  Say  Stream(filename, "Command", "Query Encoding LastError")                       -- "", the offending line or character sequence
  Say  Stream(filename, "Command", "Query Encoding")                                 -- "IBM1047 CODEPOINTS SYNTAX"
```

### Manual encoding and decoding

Although the simplicity and ease of use of Unicode-enabled streams is very convenient, in some cases you may want to resort to manual
encoding and decoding operations. For maximum control, you can use the new BIFs, ``ENCODE`` and ``DECODE`` (defined in 
[Unicode.cls](https://htmlpreview.github.io/?https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/packages/Unicode.cls.html)).

``DECODE`` can be used as an *encoding validator*:

```rexx
   wellFormed = DECODE(string, encoding)
```

will return a boolean value indicating whether *string* can be decoded without errors by using the specified *encoded* (i.e., **1** when the decoding will succeed, and **0** otherwise).

You can also use ``DECODE`` to decode a string, by specifying a target format (currently, only UTF-8 and UTF-32 are supported):

```rexx
   decoded = DECODE(string, encoding, "UTF-8")
```

In this case, the function will return the null string if *string* cannot be decoded without errors with the specified *encoding*, and the decoded version of its first argument if no ill-formed character combinations are found.

Since encoding and decoding are considered to be low-level operations, the results of ``ENCODE`` and ``DECODE`` are always ``BYTES`` strings. If you need
more features for the returned strings, you can always promote the results to higher types by using the ``CODEPOINTS`` and ``TEXT`` BIFs.

#### Manual decoding and error handling

A fourth argument to the ``ENCODE`` BIF determines the way in which ill-formed character sequences are handled:

```rexx
   decoded = DECODE(string, encoding, "UTF-8", "REPLACE")
```

When the fourth argument is omitted, or is specified as ``""`` or ``"NULL"`` (the default), a null string is returned if any ill-formed sequence is found.
When the fourth argument is ``"REPLACE"``, any ill-formed character is replaced with the Unicode Replacement Character (U+FFFD). When the fourth
argument if ``"SYNTAX"``, a Syntax error is raised in the event that an ill-formed sequence is found.

## Other changes and additions

### ooRexxDoc documentation

I have started to document the programs using ooRexxDoc. This is a work-in-progress.

### To the ``rxu`` [Rexx Preprocessor for Unicode](https://htmlpreview.github.io/?https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/packages/rxu.rex.html)

* Recognize BIFs in CALL instructions.
* Remove support for OPTIONS CONVERSIONS (wanted to rethink the feature).
* Change "C" suffix for classic strings to "Y", as per Rony's suggestion.
* "U" strings are now BYTES strings.
* Implement DATATYPE(string, "C") (syntax checks uniCode strings).
* Implement LINEIN, LINEOUR, CHARIN, CHAROUT, CHARS and LINES.

### To the main Unicode class, [Unicode.cls](https://htmlpreview.github.io/?https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/packages/Unicode.cls.html)

* Rename P2U to C2U, and create a new U2C BIF. Complete symmetry with C2X, X2C and DATATYPE("X").

### Encoding support

A new ``encoding`` subdirectory has been created. The main encoding class is [``Encoding.cls``](https://htmlpreview.github.io/?https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/packages/Encoding.cls.html). Concrete encodings
are subclasses of ``Encoding.cls``, and are automatically recognized when they are added to the ``encoding`` subdirectory.

**Note**: *the encoding interface is likely to change in the following releases*.

### Samples

Numerous sample programs have been added to the ``samples`` directory. Most of these programs test the behaviour of the enhanced BIFs.
