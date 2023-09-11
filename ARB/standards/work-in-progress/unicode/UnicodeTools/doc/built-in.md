# Rexx built-in functions for Unicode: enhancements and modifications

## Introduction: What are the enhanced built-in functions and how are they implemented

### Statement of the problem

The purpose of RXU, the Rexx Preprocessor for Unicode, is to offer a Unicode-enhanced
Rexx experience that is as seamless and as simple as possible. A Unicode-enhanced Rexx program ("a RXU
program" for short) is a program written in a language based on standard (oo)Rexx
and enhanced with a set of Unicode specific additions and modifications.

As an example of _additions_, RXU programs allow for four new types of literal strings.
These are described in an accompanying document, [_New types of strings_](string-types.md).

_Modifications_ become necessary when the behaviour of already existing mechanisms of Rexx
has to be altered. In our case, for instance, we will expect that RXU programs know 
how to manage Unicode strings, and thus bring the rich set of features of Rexx to the Unicode world. 
But this will mean that _existing_ BIFs will have to operate with _new_ entities (i.e., Unicode strings) 
and, of course, they will most probably have to produce _new and different_ results when processing these new entities.

We are then confronted to the task of enhancing, and in this sense _redefining_, existing BIFs.
But this is extremely problematic.

### Ways to substitute BIFs. Necessity of a preprocessor

As is well known, built-in functions (BIFs) are _second_ in the Rexx search order

> Functions are searched in the following sequence: internal routines, built-in functions, external
functions (_rexxref_, 7.2.1, "Search Order").

As a consequence, when one wants to redefine a BIF, the only possible way is to write an _internal_
function with the same name:

> If the call or function invocation uses a literal string, then the search for internal label is bypassed. This
bypass mechanism allows you to extend the capabilities of an existing internal function, for example,
and call it as a built-in function or external routine under the same name as the existing internal
function. To call the target built-in or external routine from inside your internal routine, you must use a
literal string for the function name (_Ibid._).

If, as we stated above, we want to offer an experience that is "as seamless and as simple as possible", the
only way to achieve that is to implement a _preprocessor_. The alternative would be to define a kind of
"epilog" that would contain all the redefined functions, and ask the programmers to copy it at the
bottom of their programs: a maintenance nightmare, and nothing that can be called "seamless" or "simple".

### Ways to substitute BIFs, part II

The preprocessor could add such a prolog to RXU programs in an automated way. But, if we count on
the idea of a (sufficiently powerful) preprocessor, we can opt for a different strategy. Instead
of writing an internal routine for each BIF that we want to modify or enhance, we can _substitute_ the name of each BIF
in every BIF call, and call a different function instead. Now, that different function will have a new name,
an _external function name_. Clashes with existing BIF names will disappear, and, with them, the need
to define internal routines. That's a much neater solution. Indeed, if working with ooRexx, all the
external routines can be grouped in some few packages, and the task of the preprocessor will practically be reduced,
beyond the substitution of names and the implementation of new string types, to the trivial addition
of a ``::Requires`` directive or a function call that enables the new external functions.

The RXU preprocessor for Unicode follows this approach. It substitutes calls to a rexx BIF ``F`` with calls to ``!F``,
i.e., an exclamation mark, "!", is added to the BIF name. For example the preprocessor would translate ``Length(var)``
to ``!Length(var)``.

### Subtleties of substitution

The _basic idea_ of such a substitution is trivially easy; as it often happens, its concrete realization is nothing
but trivial. You cannot simply pick every occurence of, say, ``"LENGTH"`` and blindly substitute it with "!LENGTH":
that would unintendedly transform _method calls_, like in ``n = var~length``, for example. 

Ok, you could say: let's reduce ourselves to the case where a BIF name is followed by a left parentheses. 
But this leaves out ``CALL`` statements, and there are methods that have arguments anyway...

The RXU Rexx Preprocessor for Unicode handles all these complexities, and many more, except one: if there is an internal routine
with the same name as a BIF, it substitutes names anyway. It should not, but it's beyond its power, in the current
version. This limitation will be addressed in a future release.

---

## C2X (Character to heXadecimal)

## CHARIN 

```
   ╭─────────╮              ╭───╮                                    ╭───╮
▸▸─┤ CHARIN( ├─┬──────────┬─┤ , ├─┬───────────┬─┬──────────────────┬─┤ ) ├─▸◂
   ╰─────────╯ │ ┌──────┐ │ ╰───╯ │ ┌───────┐ │ │ ╭───╮ ┌────────┐ │ ╰───╯
               └─┤ name ├─┘       └─┤ start ├─┘ └─┤ , ├─┤ length ├─┘
                 └──────┘           └───────┘     ╰───╯ └────────┘
```

The CHARIN BIF is enhanced by supporting the _encoding_ options specified in the STREAM OPEN command.
* When an _encoding_ is not specified for a stream, the standard BIF is called.
* When an _encoding_ is specified, the action taken depends on the encoding _target_.
    * When the encoding _target_ is __TEXT__ (the default), a TEXT string, composed of grapheme clusters, is returned.
    * When the encoding _target_ is __CODEPOINTS__, the appropiate number of Unicode codepoints is read and is returned in a string.
* The handling of ill-formed Unicode sequences depends on the value of the encoding _error_handling_.
    * When _error_handling_ is set to __REPLACE__ (the default), any ill-formed character will be replaced by the Unicode Replacement Character (U+FFFD).
    * When _error_handling_ is set to __SYNTAX__, a Syntax condition will be raised.
 
Character positioning is precautionarily disabled in some circumstances:
* When the _encoding_ is a variable-length encoding.
* When the _encoding_ is a fixed-length encoding, but a _target_ of __TEXT__ has been requested.

Character positioning at the start of the stream (that is, when _start_ is specified as __1__) will work unconditionally.

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## CHAROUT

```
   ╭──────────╮              ╭───╮                                    ╭───╮
▸▸─┤ CHAROUT( ├─┬──────────┬─┤ , ├─┬────────────┬─┬─────────────────┬─┤ ) ├─▸◂
   ╰──────────╯ │ ┌──────┐ │ ╰───╯ │ ┌────────┐ │ │ ╭───╮ ┌───────┐ │ ╰───╯
                └─┤ name ├─┘       └─┤ string ├─┘ └─┤ , ├─┤ start ├─┘
                  └──────┘           └────────┘     ╰───╯ └───────┘
```

The CHAROUT BIF is enhanced by supporting the _encoding_ options specified in the STREAM OPEN command.
* When an _encoding_ has not been specified for a stream, the standard BIF is called.
* When the _string_ type is __TEXT__ or __CODEPOINTS__, the _string_ presentation is well-formed UTF-8 and will be used as-is.
* When the _string_ type is __BYTES__, it will be checked for UTF-8 well-formedness.
* In both cases, the resulting string is then encoded using the _encoding_ specified in the STREAM OPEN command.
    * When __SYNTAX__ was specified as the stream _error_handling_ option, a Syntax error is raised in case an encoding error is found, or if the argument _string_ contains ill-formed UTF-8.
    * When __REPLACE__ was specified as the stream _error_handling_ option, ill-formed characters will be replaced by the Unicode Replacement Character (``U+FFFD``).
    * 
Character positioning is precautionarily disabled in some circumstances:
* When the _encoding_ is a variable-length encoding.
* When the _encoding_ is a fixed-length encoding, but a _target_ of __TEXT__ has been requested.
* 
Character positioning at the start of the stream (that is, when _start_ is specified as __1__) will work unconditionally.

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## CHARS 

```
   ╭────────╮  ┌──────┐  ╭───╮
▸▸─┤ CHARS( ├──┤ name ├──┤ ) ├─▸◂
   ╰────────╯  └──────┘  ╰───╯
```

The CHARS BIF is modified to support the _encoding_ options specified in the STREAM OPEN command.

* When an _encoding_ has not been specified for stream _name_, the standard BIF is called.
* When an _encoding_ has been specified for stream _name_, the behaviour of CHARS depends on the stream _encoding_ options.
    * When the _encoding_ is variable-length or the _target_ type is __TEXT__, the CHARS function returns __1__ to indicate that data is present in the stream, or __0__ if no data is present.
    * When the _encoding_ is fixed length and the _target_ type is __CODEPOINTS__, the standard BIF is called to obtain the number of remaining bytes.
      If this number is an exact multiple of the _encoding_ length, the result of dividing the number of bytes left by the number of bytes per character of the _encoding_ is returned.
    * In all other cases, 1 is returned.

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## CENTER

## CENTRE

## COPIES

## DATATYPE

## LEFT

## LENGTH

## LINEIN 

```
   ╭─────────╮              ╭───╮                                  ╭───╮
▸▸─┤ LINEIN( ├─┬──────────┬─┤ , ├─┬──────────┬─┬─────────────────┬─┤ ) ├─▸◂
   ╰─────────╯ │ ┌──────┐ │ ╰───╯ │ ┌──────┐ │ │ ╭───╮ ┌───────┐ │ ╰───╯
               └─┤ name ├─┘       └─┤ line ├─┘ └─┤ , ├─┤ count ├─┘
                 └──────┘           └──────┘     ╰───╯ └───────┘
```

The LINEIN BIF is enhanced by supporting the _encoding_ options specified in the STREAM OPEN command.

* When an _encoding_ has not been specified for stream _name_, the standard BIF is called.
* When an _encoding_ has been specified, a line is read, taking into account the end-of-line conventions defined by the _encoding_. The line is then decoded to UTF8, and returned as a TEXT string (the default), or as a 
  CODEPOINTS string, if __CODEPOINTS__ has been specified as an _encoding_ option of the STREAM OPEN command.
* If an error is found in the decoding process, the behaviour of the LINEIN BIF is determined by the _error_handling_ method specified as an _encoding_ option of the STREAM OPEN command.
    * When __SYNTAX__ has been specified, a Syntax error is raised.
    * When __REPLACE_ has been specified, any character that cannot be decoded will be replaced with the Unicode Replacement character (``U+FFFD``).
 
### Line-end handling

_Preliminary note_. Rexx honors Windows line-end sequences (``"0D0A"X``) and Unix-like line-end characters (``"0A"X``), and it does so both in Windows and in Unix-like systems. 
You can try it for yourself by creating a file that contains ``"31610d0a32610d33610a34610a0d3563"X`` and reading it line-by line both on Windows and on Linux.

What happens when we are using a multi-byte encoding like UTF-16 or UTF-32? On the one hand, we will be getting false positives: ``"000A"X`` is a line end, 
but ``"0Ahh"X`` is not, irrespective of the value of ``hh``. On the other hand, we will be getting lost sequences: a ``"000D"X`` that immediately preceeds a 
``"000A"X`` should be removed by Rexx, but the current versions do not remove it.

All these details have to be taken into account by this routine.

__Implementation restriction__. Line positioning when line > 1 is not implemented when:

* The end-of-line character is not ``"0A"X``.
* The _encoding_ number of bytes per char is greater than 1.
* The _encoding_ is not fixed-length.

Some or all of these restrictions may be eliminated in a future release.

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## LINEOUT

```
   ╭─────────╮              ╭───╮                                   ╭───╮
▸▸─┤ LINEIN( ├─┬──────────┬─┤ , ├─┬────────────┬─┬────────────────┬─┤ ) ├─▸◂
   ╰─────────╯ │ ┌──────┐ │ ╰───╯ │ ┌────────┐ │ │ ╭───╮ ┌──────┐ │ ╰───╯
               └─┤ name ├─┘       └─┤ string ├─┘ └─┤ , ├─┤ line ├─┘
                 └──────┘           └────────┘     ╰───╯ └──────┘
```

The LINEOUT BIF is enhanced by supporting the _encoding_ options specified in the STREAM OPEN command.
* When an _encoding_ has not been specified for stream _name_, the standard BIF is called.
* When an _encoding_ has been specified for stream _name_, the _string_ is decoded to that _encoding_; additionally, the _encoding_ end-of-line sequence is used.
  
__Implementation restriction__. When line > 1, line positioning is not implemented in the following cases:
* When the _encoding_ is a variable-length encoding.
* When the length of the _encoding_ end-of-line character is greater than 1.
* When the end-of-line character is not ``"0A"``.

Some or all of these restrictions may be eliminated in a future release.  

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## LINES

```
   ╭────────╮                                      ╭───╮
▸▸─┤ LINES( ├─┬──────────┬──┬────────────────────┬─┤ ) ├─▸◂
   ╰────────╯ │ ┌──────┐ │  │ ╭───╮ ┌──────────┐ │ ╰───╯
              └─┤ name ├─┘  ├─┤ , ├─┤ "Normal" ├─┤ 
                └──────┘    │ ╰───╯ └──────────┘ │
                            │ ╭───╮ ┌─────────┐  │
                            └─┤ , ├─┤ "Count" ├──┘
                              ╰───╯ └─────────┘
```

The LINES BIF is modified to support the _encoding_ options specified in the STREAM OPEN command.

__Implementation restriction__. ``LINES(name,"Count")`` will fail with a Syntax error when:
* The _encoding_ is not fixed-length.
* The length of the _encoding_ is greater than 1.
* The _encoding_ end-of-line character is different from "0A"X.
  
Some or all of these restrictions may be eliminated in a future release.  

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## LOWER

## POS

## REVERSE

## RIGHT 

## STREAM

The STREAM BIF is enhanced by adding _encoding_ options to the OPEN and QUERY commands. 
In this version, ENCODING should be the last option specified, and it can not be used with BINARY streams.

### New options for the OPEN command

```
▸▸─ STREAM( name , "Command" , "Open" options "ENCODING" encoding >─┬────────────────┬──┬─────────────┬─> ) ─▸◂
                                                                    ├  "TEXT"        ┤  ├  "REPLACE"  ┤
                                                                    └─ "CODEPOINTS" ─┘  └─ "SYNTAX"  ─┘
```
The encoding options are as follows:

* __ENCODING__ _encoding_ specifies that the file is encoded (for reading) or is to be encoded (for writing) using the _encoding_ encoding.
* __ENCODING__ _encoding_ can be followed by any of __SYNTAX__, __REPLACE__, __TEXT__ or __CODEPOINTS__, in any order.
* Only one of __TEXT__ or __CODEPOINTS__ can be specified; __TEXT__ is the default. This option determines the type of the strings (STRINGTYPE) that will be returned by the CHARIN and LINEIN BIFs.
* Only one of __SYNTAX__ or __REPLACE__ can be specified; __REPLACE__ is the default. When __REPLACE__ is specified, ill-formed byte sequences
  are replaced by the Unicode Replacement Character (``U+FFFD``); when __SYNTAX__ is specified, any ill-formed byte sequence raises a Syntax condition.

### New QUERY commands

* __QUERY ENCODING__ returns a string consisting of three words, or a null string if no _encoding_ was specified.
  If the returned string is not empty, it will contain the official _encoding_ name, the _encoding_ target (that is, __TEXT__ or __CODEPOINTS__), and the encoding _error_handling_ (that is, __SYNTAX__ or __REPLACE__).
* __QUERY ENCODING NAME__ returns the stream _encoding_ official name, or a null string if no _encoding_ was specified.
* __QUERY ENCODING TARGET__ returns __TEXT__ or __CODEPOINTS__, or a null string if no _encoding_ was specified.
* __QUERY ENCODING ERROR__ returns __SYNTAX__ or __REPLACE__, or a null string if no _encoding_ was specified.
* __QUERY ENCODING LASTERROR__ returns the value of the characters that could not be encoded or decoded by the last stream operation. __QUERY ENCODING LASTERROR__ will return a null string if no encoding or decoding 
  errors have been produced in the stream _name_, or when the last operation was successful; if there was an error in the last stream operation, the offending line will be returned.

### Modifications and restrictions to the SEEK and POSITION STREAM commands

__Implementation restrictions__. SEEK and POSITION will raise a Syntax error in the following cases:

For character positioning,
* When the _encoding_ is variable-length.
* When __TEXT__ has been selected as the encoding _target_ type.

Positioning the stream at the start of the stream with an offset of "=1" will unconditionally succeed.

For line positioning, all the restrictions listed for character positioning apply, and, additionally:
* When the _encoding_ specifies a line-end different from ``"0A"X``.

Some or all of these restrictions may be eliminated in a future release.  

__Note.__ The source code for the enhanced stream operations can be found in the file Stream.cls.

Please refer to the stream.rxu program in the samples subdirectory for examples.

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## SUBSTR

## UPPER
