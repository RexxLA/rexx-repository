# New classes

## Introduction

The Rexx Preprocessor for Unicode (RXU) implements a set of Rexx extensions that allow programmers to write Unicode-enabled Rexx programs.

RXU is a work-in-progress. Its goal is to produce a proof-of-concept implementation of Unicode-enabled Rexx, limited to what has been informally called "stage 1" Unicode in some circles, namely:

* The RXU project is _Classic Rexx-first_. This means that its priority is to first _define a procedural implementation of Unicode Rexx_. This will be achieved by (a) extending the base string type to support a _polymorphic_ system, in which three different types are supported, BYTES, CODEPOINTS and TEXT (the study of these three types will be the subject matter of this document). (b) _Extending the semantics_ of the existing built-in functions (BIFs) to work with Unicode string types, and: (c) _Defining new BIFs_, necessary for Unicode. A classic Rexx implementation, like Regina or BRexx, could be extended, if desided, following the RXU definitions, to produce a Unicode-enabled classic Rexx interpreter.
* RXU is procedural-first in its _definitions_, but object-oriented in its _implementation_. This means that (a) RXU is implemented in ooRexx, which is object-oriented, but specially that (b) our implementation uses _a set of ooRexx classes_. Regardless of the implementation details, our definitions are still procedural: one could write a new, different, implementation, to produce a Unicode-enabled classic Rexx interpreter implementing the same definitions.
* Our purpose is to be able to _manage Unicode strings_, i.e., read and write Unicode strings, compare and sort them, test them for (in)equality, break them into smaller components, etc. This is what we call "stage 1" Unicode. Other Unicode extensions, like allowing Unicode identifiers in Rexx programs, are considered "stage 2" (or of a later stage), and are not part of the present effort.
* The _classes_ used in the _implementation_ of RXU are, by themselves, an implementation of a Unicode-extended object-oriented Rexx (ooRexx), which is a strict superset of the procedurally defined extensions. 

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

## BYTES

### C2U (Character to Unicode codepoints)

```
   ╭──────╮                 ╭───╮
▸▸─┤ C2U( ├──┬────────────┬─┤ ) ├─▸◂
   ╰──────╯  │ ┌────────┐ │ ╰───╯
             └─┤ format ├─┘
               └────────┘
```

Returns a <code>BYTES</code> string such that if a <code>U</code> were appended to it
and it was inserted as a literal in a Rexx source program it would have
the same string value as the target string.

This method assumes that the target string contains well-formed UTF-8. If this is not the case, it will raise a Syntax condition. 
Please note that <code>CODEPOINTS</code> and <code>TEXT</code> strings are always well-formed.

* When _format_ is not specified, is specified as the null string, or is __"CODES"__ (the default), C2X will return a sequence of blank-separated codepoints,
  (without the ``"U+"`` prefix). Codepoints smaller than "1000"U will be padded on the left with zeros until they are four bytes long.
  Codepoints larger that "FFFF"U will have any leading zeroes removed.
* When _format_ is __"U+"__, C2X returns a list of blank-separated codepoints, with the <code>"U+"</code> prefix.
* When _format_ is __"NAMES"__, C2X returns a blank-separated list of the Unicode "Name" ("Na") property for each codepoint in the target string.
* When _format_ is __"UTF32"__, C2X returns a UTF-32 representation of the target string, 
 
__Examples:__

```
"Sí"~C2U                                -- "0053 00ED" (and "0053 00ED"U = "53 C3AD"X = "Sí")
"Sí"~C2U("U+")                          -- "U+0053 U+00ED"
"Sí"~C2U("Na")                          -- "(LATIN CAPITAL LETTER S) (LATIN SMALL LETTER I WITH ACUTE)"
"Sí"~C2U("UTF32")                       -- "00000053 000000ED"X
```

### U2C (Unicode codepoints to Character)

```
   ╭─────╮             
▸▸─┤ U2C ├──▸◂
   ╰─────╯  
```

This method inspects the target string for validity (see below). If valid,
it translates the corresponding codepoints to UTF8, and then returns the translated string.
If not valid, a Syntax condition is raised.

You can use the ``DATATYPE(string, "C")`` BIF  or the ``DATATYPE("C")`` method to verify whether a string is a proper Unicode codepoints string.

The target string is valid when it contains a blank-separated sequence of either:

* Hexadecimal Unicode codepoints, like ``41``, ``E9`` or ``1F514``.
* Hexadecimal Unicode codepoints preceded with ``U+`` or ``u+``, like ``U+41``, ``u+E9`` or ``U+1F514``.
* Unicode character names, enclosed between parentheses, like ``(Bell)``, ``(Zero Width Joiner)`` or
  ``(Latin small letter a with acute)``.
* Unicode character alias, enclosed between parentheses, like ``(End of line)`` or ``(Del)``.
* Unicode character labels, enclosed between parentheses, like ``(<Control-0010>)``. Please note that Unicode labels are enclosed themselves between "&lt;" and
  "&gt;" signs.

When searching for names, aliases and labels, spaces, medial hypens and underscores are ignored (with the exception of ``hangul jungseong o-e``), as are case
differences. Therefore, ``(Zero Width Joiner)`` is identical to ``(ZERO WIDTH JOINER)``, to ``(ZeroWidthJoiner)``, to ``(Zero_Width_Joiner)`` and
to ``(Zero-Width Joiner)``: they are all a reference to "200D"U.

A separating space is not necessary after a closing parentheses, or before an opening parentheses.

__Examples:__

```
"41"~U2C                                -- "A"
"U+41"~U2C                              -- "A"
"u+0041"~U2C                            -- "A"
"(Latin Capital Letter A)"~U2C          -- "A"
"41 42"~U2C                             -- "AB"
"1F514"~U2C                             -- "🔔" 
"(Bell)"~U2C                            -- "🔔"
"A(Bell)"~U2C                           -- "A🔔"
```

---

* ``BYTES``. A class similar to Classic Rexx strings. A BYTES string is composed of bytes, and all the BIFs work as in pre-Unicode Rexx. The BYTES class adds a ``C2U`` method (see the description of the ``C2U`` BIF for 
  details), and reimplements a number of ooRexx built-in methods: \[\], C2X, CENTER, CENTRE, DATATYPE (a new option, ``"C"``, is implemented: ``DATATYPE(string,"C")`` will return __1__ when and only when ``"string"U`` 
  would be a valid Unicode string), LEFT, LENGTH, LOWER, POS, REVERSE, RIGHT, SUBSTR, U2C (same as ``X2C``, but for ``U`` strings), and UPPER.
* ``CODEPOINTS``. A CODEPOINTS string is composed of Unicode codepoints. CODEPOINTS is a subclass of BYTES. The CODEPOINTS class redefines the most basic BIMs (\[\] and LENGTH), and the other BIMs, being defined on 
  those, work automatically.
* ``TEXT``. A TEXT string os composed of Unicode extended grapheme clusters. TEXT is a subclass of CODEPOINTS. The TEXT class redefines the most basic BIMs (\[\] and LENGTH), and the other BIMs, being defined on
  those, work automatically.
