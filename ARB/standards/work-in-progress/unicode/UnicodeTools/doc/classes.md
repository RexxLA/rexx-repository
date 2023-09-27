# New classes

## Introduction

The Rexx Preprocessor for Unicode (RXU) implements a set of Rexx extensions that allow programmers to write Unicode-enabled Rexx programs.

RXU is a work-in-progress. Its goal is to produce a proof-of-concept implementation of Unicode-enabled Rexx, limited to what has been informally called "stage 1" Unicode in some circles, namely:

* RXU is _Classic Rexx-first_. This means that its priority is to first define a procedural implementation of Unicode Rexx. This will be done by (a) extending the base string type to support a _polymorphic_ system, in which three different string types are supported, BYTES, CODEPOINTS and TEXT; the study of these three types will be the subject matter of this document. (b) _Extending the semantics_ of the existing built-in functions (BIFs) to work with Unicode string types, and: (c) _Defining new BIFs_, necessary for Unicode. A classic Rexx implementation, like Regina or BRexx, could be extended, if desided, following the RXU definitions, to produce a Unicode-enabled classic Rexx interpreter.
* RXU is procedural-first in its _definitions_, but object-oriented in its _implementation_. This means that (a) we work in ooRexx, which is object-oriented, but specially that (b) our implementation uses classes to achieve its effects. We want to stress the fact that our definitions are still procedural, i.e., that one could write a new, different, implementation, to produce a Unicode-enabled classic Rexx interpreter.

## A non-object oriented presentation of the classes

From a procedural point of view, a string can have one of three __types__: ``BYTES``, ``CODEPOINTS``, or ``TEXT``. You can retrieve the type of a string by using the ``STRINGTYPE(string)`` BIF. 

### Promotion and demotion BIFs

A BYTES _string_ can be __promoted__ to CODEPOINTS by using the ``CODEPOINTS(string)`` BIF, or to TEXT by using the ``TEXT(string)`` BIF; a CODEPOINTS _string_ can be __demoted__ to BYTES by using the ``BYTES(string)`` BIF, or __promoted__ to TEXT by using the ``TEXT(string)`` BIF; a ``TEXT`` _string_ can be __demoted__ to CODEPOINTS by using the ``CODEPOINTS(string)`` BIF, or to BYTES by using the ``BYTES(string)`` BIF.

Demotion always succeeds. Promotion from BYTES can fail: ``CODEPOINTS`` and ``TEXT`` require that their argument _string_ contains well-formed UTF-8. You can validate a _string_ for UTF-8 well-formedness by using the ``UTF8(string)`` BIF or the more general ``DECODE(string,"UTF-8")`` BIF.

### Semantics, and a rationale for the three types/classes system

A string is always _the same_, irrespective of its type. Changing the type of a string amounts to _changing our_ __view__ _of the string_.

Namely,

* We _view_ a BYTES string _as a string composed of bytes_ (octets). This is equivalent to Classic Rexx strings, and to the String type of ooRexx. "A character" means the same as "a byte" ("an octet"). BIFs operate on characters = bytes = octets.
* We _view_ a CODEPOINTS string _as a string composed of Unicode codepoints_. All the usual BIFs will continue working, but new "a character" means "a Unicode codepoint".
* We _view_ a TEXT string _as a string composed of extended grapheme clusters_. All the usual BIFs will continue working, but new "a character" means "an extended grapheme cluster".

__Examples:__

```
string = "(Man)(Zero Width Joiner)(Woman)"U
Say string                                       -- "👨‍👩"   U strings are always BYTES strings
Say C2X(string)                                  -- "F09F91A8E2808DF09F91A9"
Say Length(string)                               -- 11
Say string[1]                                    -- "�"   "F0"X, which is ill-formed UTF-8,
                                                 -- and gets substituted by the Replacement Character
string = Codepoints(string)                      -- Promote to the CODEPOINTS type
Say C2X(string)                                  -- "F09F91A8E2808DF09F91A9"   It's the same string,...
Say Length(string)                               -- 3   ...but its interpretation --its "view"-- has changed
Say string[1]                                    -- "👨"   The first codepoints, i.e., "(Man)"U
string = Text(string)                            -- Promote to the TEXT type
Say C2X(string)                                  -- "F09F91A8E2808DF09F91A9"   Still the same string,...
Say Length(string)                               -- 1   ...but its interpretation has changed once more
Say string[1]                                    -- "👨‍👩"   The first (and only) grapheme cluster
```

When a BIF has more than one string as an argument, there is always an argument which is the "main" string. For example, in POS(_needle_, _haystack_), _haystack_ is the main string. The remaining strings are  promoted or demoted, if needed, to match the type of the main string; in the case of promotions, this operation can raise a Syntax error (i.e., when the source string contains ill-formed UTF-8 sequences).

__Examples:__

```
Pos("E9"U, "José"T)                               -- 1   Same as Pos( Bytes("E9"U), "José")
Pos("80"X, "José"T)                               -- Syntax error
```

The _view_ of a string is implemented through a set of built-in functions (BIFs), namely, _Classic Rexx BIFs_, the set of functions we are used to (i.e., LENGTH, SUBSTR, POS, etc.) and _new BIFs_, necessary for Unicode.

With a few exceptions, most BIFs are at the same time _the same_ and _different_. They are _the same_ in the sense that they have the _same_ abstract definition, in terms of characters. They are _different_, because the definition of what a character is _changes_ between types, and, therefore, this _same_ definition will have a _different_ meaning. The above example illustrates very clearly these concepts: C2X is one of the few exceptional BIFs, since it always returns a BYTES string, which is _the same_, irrespective of the type of the source string. LENGTH, or the string\[n\] construction, on the other hand, operate _differently_, depending on the type of the string they operate on.

_Changing the view_ of a string is equivalent to _changing the set of BIFs_ that operate on the string.

## An object-oriented presentation of the classes

* ``BYTES``. A class similar to Classic Rexx strings. A BYTES string is composed of bytes, and all the BIFs work as in pre-Unicode Rexx. The BYTES class adds a ``C2U`` method (see the description of the ``C2U`` BIF for 
  details), and reimplements a number of ooRexx built-in methods: \[\], C2X, CENTER, CENTRE, DATATYPE (a new option, ``"C"``, is implemented: ``DATATYPE(string,"C")`` will return __1__ when and only when ``"string"U`` 
  would be a valid Unicode string), LEFT, LENGTH, LOWER, POS, REVERSE, RIGHT, SUBSTR, U2C (same as ``X2C``, but for ``U`` strings), and UPPER.
* ``CODEPOINTS``. A CODEPOINTS string is composed of Unicode codepoints. CODEPOINTS is a subclass of BYTES. The CODEPOINTS class redefines the most basic BIMs (\[\] and LENGTH), and the other BIMs, being defined on 
  those, work automatically.
* ``TEXT``. A TEXT string os composed of Unicode extended grapheme clusters. TEXT is a subclass of CODEPOINTS. The TEXT class redefines the most basic BIMs (\[\] and LENGTH), and the other BIMs, being defined on
  those, work automatically.
