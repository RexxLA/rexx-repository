# Stream functions for Unicode

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
``` 

Several of the stream built-in functions have been rewritten to implement a basic level of Unicode support.

Unicode support for the built-in functions is implemented by the [``stream.cls``](../components/stream.cls) package. It contains a set of
helper routines implementing Unicode-enabled streams.

### Backwards compatibility

By default, stream operations continue to be byte-oriented, unless you specifically request otherwise. 
This allows existing programs to continue to run unchanged.

### Unicode-enabled streams

A stream is said to be **Unicode-enabled** when an ``ENCODING`` is specified in the ``STREAM`` ``OPEN`` command:

```rexx
   Call Stream filename, "Command", "Open read ENCODING UTF-8"
```

When an encoding is specified, STREAM first checks that an encoding with that name is available in the system. 
The name is looked for both as an official name, and as an alias. 
If no encoding of that name can be found in the system, a syntax error is raised. 
If the encoding can be found, the stream is open, in the mode specified by the options in the OPEN command, 
and the encoding information gets associated with the stream until the stream is closed. 
The official name of the encoding can be retrieved by using the ``QUERY ENCODING NAME`` command:

```
Call Stream filename, "Command", "Open Read ENCODING IBM-1047"     -- IBM-1047 is an alias for the encoding
Say  Stream filename, "Command", "QUERY ENCODING NAME"             -- IBM1047 (maybe): the official name of the encoding is returned
```

Once a stream is opened with the ENCODING option, stream I/O BIFs recognize that the stream is Unicode-enabled, and change their behaviour accordingly:

* For input BIFs, the contents of the stream is automatically decoded and converted to Unicode (i.e., to a UTF-8 *presentation*).
* Both ``LINEIN`` and ``CHARIN`` return strings of type ``TEXT``, composed of extended grapheme clusters. Lines and character strings are automatically normalized to the NFC Unicode normalization form.
* When you call ``CHARIN`` and specify the *length* parameter, the appropriate number of codepoints (or grapheme clusters) are read and returned.
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

### Error handling

When using a Unicode-enabled stream, encoding and decoding errors can occur. By default, ill-formed characters are replaced by the Unicode
Replacement Character (``U+FFFd``). You can explicitly request this behaviour by specifying the __REPLACE__ option in the ``ENCODING``
of your stream:

```rexx
   Call Stream filename, "Command", "Open read ENCODING UTF-8 REPLACE"
```

__REPLACE__ is the default option for error handling. You can also specify __SYNTAX__ as an error handling option,

```rexx
   Call Stream filename, "Command", "Open read ENCODING UTF-8 SYNTAX"
```

finding ill-formed character sequences will then raise a syntax error. If the syntax condition is trapped, you will be able to access the
undecoded or unencoded offending line or character sequence by using the __QUERY ENCODING LASTERROR__ ``STREAM`` command:

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

If the function causing the error was ``LINEIN`` or ``CHARIN``, the result of the __QUERY ENCODING LASTERROR__ command
will be the original, undecoded, line or character sequence, as it appears in the file. If the function causing the error was ``LINEOUT`` or
``CHAROUT``, the result of the __QUERY ENCODING LASTERROR__ is the string provided as an argument.

### Specifying the target type

By default, Unicode-enabled streams return strings of type TEXT, composed of grapheme clusters automatically normalized to the NFC Unicode normalization form. 
You may prefer to manage Unicode string that are not automatically normalized; in that case, you should use GRAPHEMES as the target type.
In some other occasions, you may prefer to manage CODEPOINTS strings. 
You can specify the target type in the ``ENCODING`` section of your ``STREAM`` ``OPEN`` command:

```rexx
   Call Stream filename, "Command", "Open read ENCODING UTF-8 TEXT"
```

When you specify __TEXT__ (the default), ``LINEIN`` and ``CHARIN`` will return strings are of type TEXT, automatically normalized to NFC.
When you specify __GRAPHEMES__, ``LINEIN`` and ``CHARIN`` will return strings are of type GRAPHEMES, without any automatical normalization.
When you specify __CODEPOINTS__, returned strings will be of type CODEPOINTS.

**Note**: *Some operations that are easy to implement for a CODEPOINTS target type can become impractical when switching to a GRAPHEMES or a TEXT type.
For example, UTF-32 is a fixed-length encoding, so that with a CODEPOINTS target type, direct-access character positioning and
substitution is trivial to implement. On the other hand, if the target type is TEXT, these operations become very difficult to implement*.

### Options order

You can specify any of __TEXT__, __GRAPHEMES__, __CODEPOINTS__, __REPLACE__ and __SYNTAX__ in any order, but you can not specify
contradictory options. For example, __TEXT SYNTAX__ is the same as __SYNTAX TEXT:: (and as __Syntax text__, since case is ignored), 
but __REPLACE SYNTAX__ will produce a syntax error.

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
more features for the returned strings, you can always promote the results to higher types by using the ``CODEPOINTS``. ``GRAPHEMES`` and ``TEXT`` BIFs.

#### Manual decoding and error handling

A fourth argument to the ``ENCODE`` BIF determines the way in which ill-formed character sequences are handled:

```rexx
   decoded = DECODE(string, encoding, "UTF-8", "REPLACE")
```

When the fourth argument is omitted, or is specified as ``""`` or ``"NULL"`` (the default), a null string is returned if any ill-formed sequence is found.
When the fourth argument is ``"REPLACE"``, any ill-formed character is replaced with the Unicode Replacement Character (U+FFFD). When the fourth
argument if ``"SYNTAX"``, a Syntax error is raised in the event that an ill-formed sequence is found.

###  Implementation limits, and some reflections

The usual semantics of the stream BIFs can not be directly translated to the Unicode world without a lot of precautions and limitations.
Some of these limitations are due to the fact that the present implementation is a prototype, a proof-of-concept. Some other limitations
are of a more serious nature.
* _Variable-length encodings_. Managing character read/write positions for variable-length encodings, like UTF-8 and UTF-16, can
  be prohibitive to the point of becoming impractical. The same can be said when the target type is TEXT (a "character", in this case, is 
  an [extended] grapheme cluster, and, in the limit case, an arbitrarily large cluster could substitute a one-byte, one-letter, ASCII grapheme.
  Operating systems don't have primitives to insert/delete bytes in the middle of a file, and, although this behaviour can certainly be simulated, it can be
  so, but at a extremely expensive price. It is highly dubious that such a functionality should be defined in the language, or implemented.
* _In an encoding where the LF (``"0A"X``) character can be embedded in a normal character, like UTF-16 or UTF-32, ooRexx 
  line count and line positioning can not be relied upon. This implementation does not go to the lengths of actively simulating line count
  and positioning, and therefore, it preventively disables such operations.
