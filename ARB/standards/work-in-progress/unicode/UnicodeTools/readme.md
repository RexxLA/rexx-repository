# The Unicode Tools for Rexx

Version 0.3, 20230811.

**---> This is a prototype, not a finished product. Use at your own risk. <---**

Interfaces and specifications are proposals to be discussed, and can be changed at any moment.

## Quick installation

Download Unicode.zip, unzip it in some directory of your choice, and run ``setenv`` to set the path.

You can navigate to the ``samples`` directry and try the samples by using ``[rexx] rxu filename``.

## Preliminary documentation

This release includes [some preliminary documentation](https://htmlpreview.github.io/?https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/oorexxdoc.html). 

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
* Both ``LINEIN`` and ``CHARIN`` return strings of type ``TEXT``, composed of extender grapheme clusters.
* When you call ``CHARIN`` and specify the *length* parameter, the appropriate number of characters (grapheme clusters) are read and returned.
* Each encoding can specify its own set of end-of-line characters. For example, the IBM-1047 encoding (a variant of EBCDIC)
  specifies that ``"15"X``, the NL character, is to be used as end-of-line. Both ``LINEIN`` and ``LINEOUT`` honor this requirement, i.e.,
  when reading lines, a line will be ended by ``"15"X``, and when writing lines, they will be ended by ``"15"X`` too, instead of the
  usual LF or CRLF combination
* When using Unicode semantics, some operations can become very expensive to implement. For example, a simple direct-access character
  substitution in a file is trivial to implent for ASCII streams, but it can become prohibitive when using a variable-length encoding.
  These operations have been restricted in the current release.
* Similarly, when the Unicode-enabled stream has a string target of ``TEXT`` (the default), some operations can become prohibitive too:
  a ``TEXT`` "character" is, indeed, a grapheme cluster, and a grapheme cluster can have an arbitrary length. Direct-access character
  substitutions become too expensive to implement.

**Note**: We should start a discussion about what features we are used to, like direct-access character substitution, make sense and should be
implemented for Unicode-enabled streams.

### Error handling

When using a Unicode-enabled stream, encoding and decoding errors can occur. By default, ill-formed characters are relaced by the Unicode
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

**Note**: Some operations that are easy to implement for a ``CODEPOINTS`` target type can become impractical when switching to a ``TEXT`` type.
For example, UTF-32 is a fixed-length encoding, so that with a ``CODEPOINTS`` target type, direct-access character positioning and
substitution is trivial to implement. On the other hand, if the target type is ``TEXT``, these operations become very difficult to implement.



