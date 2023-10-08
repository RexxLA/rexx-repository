# The encoding/decoding model

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
``` 

This directory contains the main encoding class, ``Encoding.cls``, and a growing set of particular encoding classes. The ['build'](.encoding/build/) subdirectory
contains a set of utility routines to generate the translate tables used by some of the encoding classes.

This file contains the documentation for the public Encoding class, contained in ``Encoding.cls``, 
and some guidelines to implement particular encodings, as subclasses of the Encoding class.

Constants, registry methods and abstract methods will be implemented by the encoding subclasses. Utility methods 
should be considered private documentation (i.e., not a public API).

## The Encoding class

The Encoding class is the base class for all encodings, and all encoding classes should subclass Encoding.

The Encoding class implements a series of services common to all encodings (like _the encoding registry_), and defines a set of common interfaces (a contract) that all encodings have to follow.

## The Encoding registry and contract

The Encoding class and its subclasses operate under the following contract. All subclasses must adhere to this contract to work properly.

* Subclasses of ``Encoding`` must reside each in a separate ``.cls`` file, and these files must be located in the "components/encodings" subdirectory.
* At initialization time, the ``Encoding`` class will register itself in the ``.local`` directory by using ``.local~encoding = .Encoding``.
  This allows encoding subclasses to subclass Encoding without having to use the ``::Requires`` directive.
* ``Encoding`` will then call all the ``.cls`` files that reside in the "encoding" subdirectory, except itself. This will give all subclasses an opportunity to register with the ``Encoding`` class.
* Each subclass ``myEncoding`` must use its prolog to register with the ``Encoding`` class, by issuing the following method call: ``.Encoding~register(.myEncoding)``.
* ``Encoding`` will then inspect the ``name`` and ``aliases`` constants of the ``myEncoding`` class, check that there are no duplicates, and, if no errors are found, it will register these names appropriately.
* From then on, the new ``myEncoding`` encoding will be accesible as the value of the ``.Encoding[name]`` method call (note the square brackets), where ``name``
  is the (case-insensitive) value of ``myEncoding``'s name, or of any of its ``aliases``.

## Constants

A number of abstract constants are specified by the Encoding class; they should be defined by each subclass. As ooRexx does not have abstract constants, those that do not have suitable defaults are defined as 
abstract class attribute getters.

### aliases

```
   ╭─────────╮             
▸▸─┤ aliases ├──▸◂
   ╰─────────╯  
```

In addition to a _name_, an encoding may also have a set of case-insensitive _aliases_. The encoding can be uniquely identified by its _name_, or by any of its _aliases_. The ``Encoding`` class keeps a registry of all the names and aliases of all encodings, takes care that there are no duplicates, and resolves names to their corresponding classes.

Aliases can specified either as a one-dimensional array of strings, or as a blank separated string of words.

### allowsurrogates

```
   ╭─────────────────╮             
▸▸─┤ allowsurrogates ├──▸◂
   ╰─────────────────╯  
```

This is a boolean constant that determines if surrogates are allowed as Unicode values when decoding a string.

The default is 0 (.false). A class may set this constant to 1 (.true) when it needs to manage ill-formed UTF-16 sequences, 
containing isolated or out-of-sequence surrogates. Such ill-formed strings are encountered in certain contexts, for example as Windows file names.

WTF-8 and WTF-16 are encodings that need to set allowSurrogates to true.

### alternateEndOfLine

```
   ╭────────────────────╮             
▸▸─┤ alternateEndOfLine ├──▸◂
   ╰────────────────────╯  
```

Some encodings and some implementations allow more than one form of end-of-line character. 
For example, ooRexx recognizes both Windows end of line (CR LF) and Linux end of line (LF) sequences. 

If _alternateEndOfLine_ is the null string, no alternate end of line sequence exists for this encoding. 
If an alternate end of line sequence is otherwise specified, it has to verify that ``alternateEndOfLine~endsWith(endOfLine) = 1``.

### bytesPerChar

```
   ╭──────────────╮             
▸▸─┤ bytesPerChar ├──▸◂
   ╰──────────────╯  
```

For fixed-length encodings, this is the length in bytes of one character. For variable-length encodings, this is the minimum length in bytes of a character.

### endOfLine

```
   ╭───────────╮             
▸▸─┤ endOfLine ├──▸◂
   ╰───────────╯  
```

Each encoding can define its own end-of-line sequence.

### endOfLineAlignment

```
   ╭────────────────────╮             
▸▸─┤ endOfLineAlignment ├──▸◂
   ╰────────────────────╯  
```

If endOfLineAlignment is > 1, ``endOfLine`` and ``alternateEndOfLine`` sequences will only be recognized when they are aligned to ``endOfLineAlignment`` bytes.

### isFixedLength

```
   ╭───────────────╮             
▸▸─┤ isFixedLength ├──▸◂
   ╰───────────────╯  
```

An encoding can be __fixed-__ or __variable length__. For example, IBM850 is (1-byte) fixed length, as is UTF-32 (4-byte), but UTF-8 is variable-length (1 to 4 bytes).

The fact that an encoding is variable-length can have notable influence on the behaviour and performance of certain stream BIFs. In particular, some of these behaviours can become extremely expensive, and others may be entirely disallowed by the implementation.

### maxBytesPerChar

```
   ╭─────────────────╮             
▸▸─┤ maxBytesPerChar ├──▸◂
   ╰─────────────────╯  
```

For fixed-length encodings, this is the length in bytes of one character. For variable-length encodings, this is the maximum length in bytes of a character.

### name

```
   ╭──────╮             
▸▸─┤ name ├──▸◂
   ╰──────╯  
```

An encoding has an official _name_, a case-insensitive label by which it may be uniquely identified.

### useAlternateEndOfLine

```
   ╭───────────────────────╮             
▸▸─┤ useAlternateEndOfLine ├──▸◂
   ╰───────────────────────╯  
```

For encodings where ``alternateEndOfLine \== ""``, determines whether ``endOfLine`` or ``alternateEndOfLine`` is used when writing a line to a stream.

## Registry methods

### [] (class method)

```
   ╭───╮  ┌──────┐                       ╭───╮
▸▸─┤ [ ├──┤ name ├─┬───────────────────┬─┤ ] ├─▸◂
   ╰───╯  └──────┘ │ ╭───╮  ┌────────┐ │ ╰───╯
                   └─┤ , ├──┤ option ├─┘
                     ╰───╯  └────────┘
```

Returns the encoding class object uniquely identified by _name_, the encoding name or alias to resolve, according to the ``Encoding`` refistry. The behaviour of the method
when _name_ is not found depends on the value of the optional argument _option_. When _option_ is __SYNTAX__ (the default) and _name_ is not
found, a syntax error is raised. When _option_ is __NULL__ or the null string (__""__), a null string is returned.

### register (class method)

```
   ╭───────────╮  ┌─────────┐  ╭───╮
▸▸─┤ register( ├──┤ handler ├──┤ ) ├─▸◂
   ╰───────────╯  └─────────┘  ╰───╯
```

Register is one of the two methods that define the interface to the encoding registry. Its only argument is
_handler_, the encoding class to register.

The register itself is implemented and stored in a stem called ``Names.``, which is ``exposed`` in the register and "[]" methods.

## Abstract methods

### bytesNeededForChar (abstract class method)

```
   ╭─────────────────────╮  ┌────────┐  ╭───╮
▸▸─┤ bytesNeededForChar( ├──┤ string ├──┤ ) ├─▸◂
   ╰─────────────────────╯  └────────┘  ╰───╯
```

Returns 0 if _string_ is a complete character, or the number of bytes remaining to get a complete character. For example, if the encoding is UTF-16 and the argument _string_ is a lone high surrogate, 
the _bytesNeededForChar_ method will return __2__.

Please note that the fact that a character is complete does not imply that it is well-formed or valid.

### decode (abstract class method)

```
   ╭─────────╮  ┌────────┐  ╭───╮                                               ╭───╮
▸▸─┤ decode( ├──┤ string ├──┤ , ├─┬────────────┬──┬───────────────────────────┬─┤ ) ├─▸◂
   ╰─────────╯  └────────┘  ╰───╯ │ ┌────────┐ │  │ ╭───╮  ┌────────────────┐ │ ╰───╯
                                  └─┤ format ├─┘  └─┤ , ├──┤ error_handling ├─┘
                                    └────────┘      ╰───╯  └────────────────┘
```

This is an abstract method. All subclasses of ``.Encoding`` have to implement this method.

This method takes a _string_ as an argument. The string is assumed to be encoded using the encoding implemented by the current class. A decoding operation is attempted. 
If the decoding operation is successful, a choice of Unicode versions of the string is returned, as determined by the optional second argument, _format_. By default, a UTF-8 version of the argument _string_ is returned.

When _format_ is the null string (__""__), __UTF-8__, __UTF8__ or is not specified, a UTF-8 version of the argument _string_ is returned.

When _format_ is __UTF-32__ or __UTF32__, a UTF-32 version of the argument __string__ is returned.

The format can also contain a blank-separated set of encodings. When both UTF-8 and UTF-32 are requested, they are returned in a stem ``S.``. ``S.UTF8`` will contain the UTF-8 version of the string, and ``S.UTF32`` will contain the UTF-32 version of the string.

For some encodings, the decoding operation may be unsuccessful; for example, an decoding operation can be attempted against an ill-formed UTF-8 sequence. The behaviour of the method is determined by the value of the third, optional, _error_handling_ argument.

When _error_handling_ is __""__ or is not specified (the default), a null string is returned whenever a decoding error is encountered. Please note that this specification does not introduce any ambiguity, since the fact that the decoding of a null string is always a null string is known in advance and may be checked separately.

When _error_handling_ has the (case-insensitive) value of __SYNTAX__, a syntax error is raised.

### encode (abstract class method)

```
   ╭─────────╮  ┌────────┐  ╭───╮                        ╭───╮
▸▸─┤ encode( ├──┤ string ├──┤ , ├─┬────────────────────┬─┤ ) ├─▸◂
   ╰─────────╯  └────────┘  ╰───╯ │ ┌────────────────┐ │ ╰───╯
                                  └─┤ error_handling ├─┘
                                    └────────────────┘
```

This is an abstract method. All subclasses of ``.Encoding`` have to implement this method.

This method takes a _string_ as an argument. The _string_ can be an Unicode string, in which case an encoding operation is immediately attempted, 
or it can be a non-unicode string (e.g., a BYTES string), in which case a normalization pass is attempted first. 
Normalizing consists of transforming the non-Unicode string into a Unicode string by promoting it to the CODEPOINTS class.

Both operations may fail. The promotion, because _string_ contains ill-formed UTF-8, and the encoding, because the Unicode string cannot be encoded to this particular encoding.

The behaviour of the encode method depends on the value of _error_handling_, a second, optional, argument.

When _error_handling_ is the null string (the default), encode returns the null string when it encounters an error (note that there is no ambiguity in this specification because the case where the string argument is itself the null string can be handled separately).

When _error_handling_ has a (case-insensitive) value of __SYNTAX__, a syntax error is raised. No other value for option is currently defined.

## Utility methods

### checkCode (class method)

```
   ╭────────────╮  ┌──────┐  ╭───╮
▸▸─┤ checkCode( ├──┤ code ├──┤ ) ├─▸◂
   ╰────────────╯  └──────┘  ╰───╯
```

This utility method checks to see if its its argument, _code_, is a valid hexadecimal Unicode codepoint, and raises a syntax condition if it is not. Surrogate codepoints are only accepted when the _allowSurrogates_ constant is set to ``.true`` for this particular class.

### checkDecodeOptions (private class method)

```
   ╭─────────────────────╮  ┌────────┐                               ╭───╮
▸▸─┤ checkDecodeOptions( ├──┤ format ├─┬───────────────────────────┬─┤ ) ├─▸◂
   ╰─────────────────────╯  └────────┘ │ ╭───╮  ┌────────────────┐ │ ╰───╯
                                       └─┤ , ├──┤ error_handling ├─┘
                                         ╰───╯  └────────────────┘
```

This is a small utility method to sanitize the values supplied as arguments for the _error_handling_ and _format_ arguments to the _decode_ method. If the supplied values are invalid, it raises a syntax error.

When the values are valid, the method returns a string composed of three blank-separated values.

The first value indicates the form of desired error handling. It will be one of __"NULL"__, to indicate that a null string should be returned when a decoding error is encountered, __"SYNTAX"__, when a Syntax condition should be raised, or __"REPLACE"__, when ill-formed character sequences should be replaced by the Unicode Replacement Character (``"FFFD"U``).

The second value is a boolean indicating whether a UTF-8 version of the supplied string value is being requested or not.

The third value is a boolean indicating whether a UTF-32 version of the supplied string value is being requested or not.

### isCodeOK (private class method)

```
   ╭───────────╮  ┌──────┐  ╭───╮
▸▸─┤ isCodeOK( ├──┤ code ├──┤ ) ├─▸◂
   ╰───────────╯  └──────┘  ╰───╯
```

The isCodeOk private utility method checks that its hex argument, _code_, is in the Unicode scalar space. Surrogates are allowed only if allowSurrogates is 1 for the current (sub-)class.

### prepareEncode (private class method)

```
   ╭────────────────╮  ┌────────┐  ╭───╮                        ╭───╮
▸▸─┤ prepareEncode( ├──┤ string ├──┤ , ├─┬────────────────────┬─┤ ) ├─▸◂
   ╰────────────────╯  └────────┘  ╰───╯ │ ┌────────────────┐ │ ╰───╯
                                         └─┤ error_handling ├─┘
                                           └────────────────┘
```

This is a small private utility method that checks the arguments passed to the encode method; _error_handling_ is checked for validity, and _string_ is transformed into a UTF-32 byte sequence. If _string_ is a CODEPOINTS or a TEXT string, then the C2U("UTF32") method of _string_ is used; in other cases, the decode method of the UTF8 encoding is used, with the UTF32 format option.

The case of the null string is not handled here, since it is conceivable that an encoding could encode the null string to a non-null string (for example, by prepending a BOM or somesuch).

### transcode (class method)

```
   ╭────────────╮  ┌────────┐  ╭───╮  ┌────────┐  ╭───╮  ┌────────┐  ╭───╮                        ╭───╮
▸▸─┤ transcode( ├──┤ string ├──┤ , ├──┤ source ├──┤ , ├──┤ target ├──┤ , ├─┬────────────────────┬─┤ ) ├─▸◂
   ╰────────────╯  └────────┘  ╰───╯  └────────┘  ╰───╯  └────────┘  ╰───╯ │ ┌────────────────┐ │ ╰───╯
                                                                           └─┤ error_handling ├─┘
                                                                             └────────────────┘
```

__Note:__ This method should be considered final, in the Java sense. It is not intended to be overriden by subclasses.

This method transcodes its first argument, _string_, from the encoding idenfitied by the second argument, _source_, to the encoding identified by the third argument, _target_.

The _string_ argument is supposed to be encoded using the _source_ encoding. It will be decoded first, and then re-encoded with the _target_ encoding.

Both operations may fail. The behaviour of the method when an error is encountered is determined by the value of the fourth, optional, argument, _error_handling_.

When an error is encountered and _error_handling_ is not specified or is the null string (the default), a null string is returned.

When an error is encountered and _error_handling_ has the (case insensitive) value __SYNTAX__, a syntax error is raised.

When no error is encountered, a new string is returned. It is guaranteed to be encoded using the _target_ encoding.
