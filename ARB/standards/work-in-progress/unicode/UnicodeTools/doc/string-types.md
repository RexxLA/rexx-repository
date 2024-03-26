# New types of strings

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023, 2024 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                     │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
``` 

## Introduction

Classic Rexx defines three different syntactical constructions to denote string literals:

* ``"Character"`` strings, enclosed between single or double quotes.
* ``"Hexadecimal"X`` strings, with a ``X`` suffix. They are composed of hexadecimal digits and optional blank characters.
* ``"Binary"B`` strings, with a ``B`` suffix. They are composed of binary digits and optional blank characters.

In this document, we will explore the use of new constructions to denote Unicode strings.

### A note about string equivalence

Please note that character, hexadecimal and binary strings are all _different notations for the same class of strings_, namely, they are all equivalent and interchangeable between them.
For example, if we assume an ASCII encoding, then ``"a"``, ``"61"X`` and ``"0110 0001"B`` are _the same string_: they are different ways to denote a single value.

Assume that you have a label ``"a"``:

```rexx
"a": /* do something */
```

You can then use that label (with a function call, a ``CALL`` or ``SIGNAL`` statement, etc.) by referring to it as ``"61"X``, or
as ``"0110 0001"B``:

```rexx
Call ("61"X)          -- Identical to 'Call ("a")' -- Parentheses are needed for internal function calls
Signal "0110 0001"B   -- Identical to 'Signal "a"'
```

Similarly, ``"a" == "61"X`` will always be true, as will ``"61"X == "0110 0001"B``. Let's keep this aspect of Rexx in mind later, when we address the new kinds of Unicode literals.

### Purpose of this document

In this document, we will explore the impact that an Unicode-aware implementation of Rexx will have on the universe of Rexx strings, 
as exemplified by the prototype implementation of RXU, the Rexx Preprocessor for Unicode.

New nomenclature will have to be introduced, and a small set of new built-in functions will be defined. The main purpose of the document
will be to provide a _rationale_ for the proposed extensions, as a basis for further discussion and comment.

## What is a Rexx Unicode string?

One would expect that a Rexx Unicode string should implement all the (implementable) built-in functions of Classic Rexx, 
only that applied to the Unicode universe. For example, the Classic Rexx UPPER built-in function uppercases only characters that are in the ``A-Z`` and ``a-z`` ranges, 
but one would expect that an Unicode UPPER BIF would uppercase the full range of cased Unicode codepoints 
(or even the full range of cased Unicode grapheme clusters, depending on the meaning of "character" that is chosen by the implementation).

Similarly, the POS BIF operates on characters when its argument is a classic Rexx string, but it should operate on Unicode scalars
when its argument was a Unicode string (or even against grapheme clusters, depending on the meaning of "character" that is
chosen by the implementation).

## Necessity of at least two string types

We need to keep classic rexx strings ("classic strings" for short) into the language, for compatibility reasons; at the same time, we want to be
able to fully manage Unicode strings. As we have seen, the behaviour of the built-in functions has to be _different_ when operating with
classic strings and when operating with Unicode strings. Under ooRexx, this difference can be implemented using ooRexx classes;
but it would be very convenient if we could define Rexx extensions that could be implemented by Classic Rexx interpreters, i.e, by
interpreters that do not include object-oriented features: this would define a possible way for implementing Unicode in these Classic Rexx
interpreters. 

We should, then, be able to differentiate both types of string, both at parse time (differently typed string literals) and
at run time (the value of a parameter, for example, may be a classic Rexx string, or a Unicode string).

Please note that this type difference is _not_ assimilable to the "types" returned by the DATATYPE built-in function. 
DATATYPE should have been (more aptly) named DATACONTENT: it allows one to check whether _the contents_ of a string is suitable, for
example, to form an hexadecimal number, but the _nature_ of the underlying string never changes: it is always the same,
a classic Rexx string.

What Unicode-enabled Rexx needs is a new string system, in which there are strings of different types. 
Of types that are real types, as the types in Pascal: of types that alter the nature and influence the semantics of the typed
variable. The fact that a string is of a type or of another type will modify the results of the various built-in
functions: each string will have its own type and, if these types are different, they will behave in ways that are also
different.

As an example, the character ``"á"``, "Latin small letter a with acute", has a UTF-8 representation of ``"C3A1"X``; 
assuming a UTF-8 encoding, ``LEFT("á",1)`` will be ``"C3"X`` when operating on classic strings, and ``"C3A1"X`` when operating on Unicode characters.

This need for several string types will lead us to a number of quandaries, questions and problems, which we shall be addressing below.

## The first quandary: how to introduce types in an untyped language?

If we restrict ourselves to Classic Rexx, we are supposed to be working with a _typeless_, or _untyped_, language, since "everything
is a string". Then speaking of different types of string would, at first glance, look like a contradiction: we would have not one,
but several types (of strings). 

On further reflection, though, we can see that this quandary is imaginary; that "everything is a string", indeed, does _not_ strictly mean 
that there are no types. What is meant when one says that in (classic) Rexx "there are no types" is that "there are no declarations", i.e., both (a) that "you don't have to specify 
beforehand the type of a variable" and (b) that "a variable can change types dynamically at run-time". But Rexx variables _do have_ types. 
For example, arithmetic types: you can multiply two variables if and only if they are both numbers (i.e., if they are both of the same, _arithmetic_, type);
otherwise, you get a Syntax error, i.e., the _type system_ complains (at run-time).

In this sense, adapting the nomenclature to include two or more types of strings should not be too difficult. It will reduce to
a _documentation problem_.

## The second quandary: Unicode-first vs. compatibility

Let's introduce some nomenclature. An implementation of Unicode-aware Rexx will be _Unicode-first_ if unsuffixed strings are, by default, Unicode strings; 
otherwise, we will say that the implementation is _Classic-strings first_. 

Similarly, we will say that an implementation of Unicode-aware Rexx is _compatible_ if existing, non-Unicode, programs can be run unchanged in this
implementation; otherwise, we will say that the implementation is _incompatible_, or _non-compatible_.

Ideally, we would like an implementation of Unicode-aware Rexx to be both _Unicode-first_ and _compatible_ at the same time. 
But this is clearly impossible: if the implementation is Unicode-first, unsuffixed strings will have Unicode semantics, 
and then some of the existing programs will break. And, conversely, if an implementation is compatible,
unsuffixed strings have to behave as classic strings, not as Unicode strings, and then the implementation cannot be Unicode-first.

One way out of this dilemma is to allow the existence of two dialects of Rexx: a _compatibility dialect_, in which unsuffixed strings would be classic strings, 
and a _Unicode dialect_, in which unsuffixed strings would be Unicode strings. The compatibility dialect would not be Unicode-first, but it would
be perfectly compatible; the Unicode dialect would be Unicode-first, but it would not be compatible.

Some mechanism should be introduced to specify which dialect is in use. This could be an ``OPTIONS`` instruction, an ``::OPTIONS`` directive
(for ooRexx), or some other mechanism, like a language processor switch. 

## Interaction between different types of strings. Typed string literals and the STRINGTYPE BIF

In any case, and regardless of the dialect, it is perfectly conceivable that the programmer needs to use strings
of the "other" dialect in her program. For example, if she was using the compatibility dialect, where strings are classic by default,
she could well want to manage some strings, in some part of her program, that were Unicode strings; and, conversely, if she was using the Unicode dialect,
she could want to manage some strings that were classic strings.

This introduces the need for (1) a way to specify (1a) classic string literals in a Unicode-first program, (1b) and Unicode string
literals in a compatibility program; and (2) a way to distinguish, at run-time, whether a string is a classic string, or a Unicode string.

To satisfy (1), we will be introducing new suffixes, to specify the _type_ of a string. They will allow us to specify that
a string is classic in a Unicode-first program, and that a string is Unicode in a compatibility program. The exact form
of these suffixes will be discussed below, when some further questions about Unicode will have been addressed.

To satisfy (2), we will be introducing a new BIF called STRINGTYPE. 

![Diagram for the STRINGTYPE BIF](img/BIF_STRINGTYPE.svg)

``STRINGTYPE(string)`` will return different values depending
on the type of the string; these values will be specified later.

## Scalars and grapheme clusters: CODEPOINTS, GRAPHEMES and TEXT

Unicode strings will extend the built-in functions of Classic Rexx to take advantage of the Unicode world. Unicode characters will no
longer be limited to one byte; indeed, the very same definition of "character" will be under discussion.

The Unicode standard defines _Unicode scalars_, integer numbers that represent _Unicode codepoints_, and _(Extended)
Grapheme Clusters_, collections of scalars that constitute "user-perceived characters". Some languages (e.g., Java)
define their characters to be Unicode scalars, while some other languages (e.g., Swift) define their characters to be
Extended Grapheme Clusters.

What definition should Rexx adopt? There are good reasons to adopt either of the two: if characters are scalars (i.e., codepoints), 
you can have speed-efficient representations (UTF-32), space efficient representations (UTF-8), and an in-between
that might be useful if your application is generally limited to the Basic Multilingual Plane (UTF-16); if characters
are Extended Grapheme Clusters, you may lose some efficiency, but you will gain a better conformance with the standard,
more expressive power, and (it is hoped) a better experience, both for the programmers and for the end-users.

TUTOR implements both definitions, i.e., it has a data type for unicode scalars,
called CODEPOINTS, and two data types for Extended Grapheme Clusters, called GRAPHEMES and TEXT. TEXT automatically normalizes
strings to the NFC Unicode normalization form, while GRAPHEMES leaves strings as they are.

This may seem somewhat redundant, but it has its benefits. TEXT is supposed to be the default string type for Unicode-enabled Rexx programs, 
and, in this sense, CODEPOINTS and GRAPHEMES would always be a secondary, technically-oriented, type. But CODEPOINTS strings offers compatibility
with Java (and with all the other languages that have opted to implement characters as scalars, instead of graphemes, which at the moment
of this writing is the absolute majority of languages), and they may be useful when you have to manage streams that are not normalized, 
or (by using an additional, special, switch) contains ill-formed sequences, like Windows file names, that may contain UTF-16 sequences with ill-formed surrogates (WTF-16). 
GRAPHEMES strings, on the other hand, are useful when, while wanting to manage Unicode as grapheme clusters, you want to have
complete control over the real data you are getting; this control is somehow lost when you accept automatic normalization, which
is the default with TEXT strings.

## _Excursus:_ A note about the implementation strategy 

There has been some discussion about whether it is a good idea or not to have two different Unicode string types in Rexx. 
Similarly, there has been some discussion about whether special names (i.e., TEXT and CODEPOINTS) should be assigned to these different types,
or it would be more convenient to subsume all the names in a single specialized BIF, say STRING. The RXU approach is to allow all possibilities
to coexist at once, and to allow all the different names to be first-class citizens, to have maximum visibility. 

The reasons for such an approach are mainly _psychological_ and _sociological_. It is much easier to thing of two types of string and finally to renounce one, 
than to think of only one type: renouncement is then built-in, so to speak, inside the very same linguistic repertoire you have decided to use, 
and then it is very easy to end up by introducing biases, while thinking that they are unavoidable conditions of your previous choices. 

On a similar vein, we cannot forget that RXU, and the whole Unicode Tools Of Rexx, are _prototypes_ to foster discussion and interchange
about a future Unicode-aware implementation of Rexx, and not that future implementation itself: in this sense, giving names 
(like BYTES, CODEPOINTS, GRAPHEMES or TEXT) to the entities we have to manage (i.e., Classic Rexx strings, codepoint-based strings, and grapheme based strings) 
is a way to fix ideas, to create a collective vocabulary for the Architecture Review Board to share and use, and to disseminate a collective imaginary, that
is, to create the conditions for the collective decisions that have to be taken.

Does this mean that the real, final, implementations of Unicode-enabled Rexx will have to support both CODEPOINTS, GRAPHEMES and TEXT, or that these names, CODEPOINTS,
GRAPHEMES and TEXT, will be mandatory? Not at all. BYTES, CODEPOINTS, GRAPHEMES and TEXT are _temporary names_, or, if you prefer, _temporary concepts_ for a collective research. 
Once we decide that this research is finished, we will be able to decide whether we prefer to keep both concepts or we chose to keep only one. 
And, regarding the names, they can be changed on-the-fly, if needs arise: we have already changed from RUNES to CODEPOINTS, for example.

## T, G, P and Y strings

Coming back to our main subject: we need a notation to specify that a literal string is a TEXT, GRAPHEMES or a CODEPOINTS string: we have chosen ``"string"T`` for TEXT,
``"string"G`` for GRAPHEMES, and ``"string"P`` for CODEPOINTS.

We will also need a _name_ and a _notation_ for to denote Classic Rexx strings, when we are programming in the Unicode dialect. 
Let's start with the _name_ first: we will say that these strings are BYTES strings: a string will now be either a BYTES string, 
or a CODEPOINTS string, or a GRAPHEMES string, or a TEXT string, and there are no more possibilities. As we mentioned before, We will also introduce a new BIF, 
called STRINGTYPE. ``STRINGTYPE(string)`` will return precisely __BYTES__, __CODEPOINTS__, __GRAPHEMES__ or __TEXT__, 
depending on the type of _string_ (please refer to [_New built-in functions_](new-functions.md) for more details about the STRINGTYPE BIF).

We also need a _notation_ for BYTES strings. We will use the "Y" suffix for that. "Y" comes from "bYtes": it would be nice to be able
to use "B", but it was already taken (for "Binary" strings). 

## BYTES, CODEPOINTS, GRAPHEMES and TEXT as BIFs

The names BYTES, CODEPOINTS, GRAPHEMES and TEXT are also names of built-in functions. These built-in functions promote or demote strings in
the type hierarchy. A BYTES string can be _promoted_ to CODEPOINTS, GRAPHEMES or to TEXT, if it contains well-formed UTF-8; a CODEPOINTS
string can be _demoted_ to BYTES, or _promoted_ to GRAPHEMES or to TEXT; a GRAPHEMES string can be _demoted_ to BYTES or to CODEPOINTS, or _promoted_
to TEXT; a TEXT string can be _demoted_ to BYTES, to CODEPOINTS, or to GRAPHEMES (please
refer to [_New built-in functions_](new-functions.md) for more details abouy these functions).

Suffix notation, like ``"string"T`` or ``"string"Y``, is appropiate when you are specifying string literals; BIF notation, like
``BYTES(var)`` or ``TEXT(expression)``, should be used when you want to promote or demote the value of a variable or the
result of an expression. In general terms, ``TEXT("string")`` is the same as ``"string"T``, ``GRAPHEMES("string")`` is the same
as ``"string"G``, ``CODEPOINTS("string")`` is the
same as ``"string"P``, and ``BYTES("string")`` is the same as ``"string"Y``.

## Default string type

What should an unsuffixed string literal, ``"string"``, refer to? In the Unicode-first dialect, it should refer to an
Unicode string, but we now have _three_ types of Unicode strings, namely CODEPOINTS, GRAPHEMES and TEXT; in the compatibility dialect, it should refer to
a classic rexx string, i.e., to a BYTES string.

TUTOR does not force you to choose. It implements an experimental OPTIONS instruction,

```
OPTIONS DEFAULTSTRING default
```

where _default_ can be ``BYTES``, ``CODEPOINTS``, ``GRAPHEMES`` or ``TEXT``. The semantics for this instructions should be obvious: ``OPTIONS
DEFAULTSTRING TEXT``, for example, guarantees that all occurences of unsuffixed strings will be interpreted as TEXT strings.

__Implementation restriction__. Please note that the current implementation of the ``OPTIONS DEFAULTSTRING`` instruction
has the following limitation: the value for the default string type _is stored globally_. This means that you
can change its value in an internal routine, in an external routine, or in a method. We don't recommend doing that,
of course, unless you know exactly what you are doing.

## U strings

There has been some discussion about whether Rexx should implement escape sequences in strings, that is, special
combinations of characters that are translated to other characters, like ``"\r"`` for the carriage return character, ``"0D"X``,
or ``"\n"`` for the line feed character, ``"0A"X``. Many languages implement these escape sequences, including NetRexx, and it
would probably be a good idea if Rexx implemented them too. The problem is, again, compatibility with existing
programs: classic Rexx, as it is well known, does not implement escape sequences; if you want
special characters, you have to resort to hexadecimal (or binary) strings.

If we were to implement escape sequences in Rexx strings, we would need either (a) two set of suffixes, as
Python does, for escaped and unescaped strings, or (b) to introduce an asymmetry between unsuffixed strings
in Classic Rexx and the rest of strings. I.e., to preserve compatibility with old programs, unsuffixed
strings could not contain escape sequences in the compatibility dialect, but these same escape sequences
would be allowed in other types of string.

Since all this is quite controversial and there is no clear consensus about this problem,
TUTOR has opted for a conservative approach. It does not allow the use of escape sequences, 
but it defines a new type of low-level string, the _Unicode string_, similar to hexadecimal and
binary strings. Unicode strings are terminated by a "U" character. They can contain blank-separated Unicode codepoints (with or without
the "U+" prefix that many languages use), and Unicode codepoint names, alias or labels, written between parentheses, 
as defined by the Unicode standard.

__Examples:__

```rexx
"(LATIN CAPITAL LETTER A)"U == "A"  -- "LATIN CAPITAL LETTER A" is the value of the "Name" property for "A"
"41"U == "41"X == "A"               -- ASCII "A" is "41"X
"0041"U == "A"                      -- Leading zeros are optional
"U+0041"U == "A"                    -- The "U+" prefix is also optional
"(Latin capital letter A)"U == "A"  -- Casing is irrelevant
"(LatincapitalletterA)"U == "A"     -- Spacing is also irrelevant
"(End of line)"U == "0A"X           -- "END OF LINE" is an abbreviation, defined in the UCD, file NameAliases.txt
"(<control-000A>)" == "0A"X         -- This is a label, not a name
"(man)"U = "👨"                     -- A emoticon
"(Man)(Bell)"U  -- "👨🔔"          -- Two emoticons
"1F514"U == "🔔"                    -- A emoticon
"0001F514"U == "🔔"                 -- Leading zeros are irrelevant
"U+1F514"U == "🔔"                  -- The "U+" prefix is not mandatory
```

U strings are low-level constructions, equivalent to X and B strings, and therefore they are BYTES strings. 
You can always promote them, if you so please, using the CODEPOINTS, GRAPHEMES or TEXT built-in functions.

Please note that U strings are first-class strings: ``"(Bell)"U`` and ``"0001F514"U`` are equivalent to ``"🔔"``, and ``"🔔"``, in turn,
is equivalent to ``"F0 9F 94 94"X``, its UTF-8 representation. All of them can be used, interchangeably, as labels and as targets
of the CALL and SIGNAL instructions. The following code, for example, is perfectly legitimate:

```rexx
Call ("F0 9F 94 94"X)                -- Parentheses are required since this is an internal call
...
"🔔": /* Do something */
...
If condition Then Signal "(Bell)"U  

```

## In summary...

TUTOR implements, in addition to the classical Rexx strings,  the following additional types of strings:

* ``"string"Y`` strings, composed of bytes (octets). A character is one byte. They are suitable to store binary data.
* ``"string"P`` strings, composed of Unicode codepoints. A character is a single Unicode codepoint. The ``"string"`` should
  contain well-formed UTF-8 data.
* ``"string"G`` strings, composed of Unicode Extended Grapheme clusters. A character is a single Extended Grapheme Cluster. The ``"string"`` should
  contain well-formed UTF-8 data.
* ``"string"T`` strings, composed of Unicode Extended Grapheme clusters, automatically normalized to NFC at creation time. A character is a single Extended Grapheme Cluster. The ``"string"`` should
  contain well-formed UTF-8 data, and will be NFC-normalized if needed.
* ``"string"U`` strings, composed of Unicode codepoints, specified using their hexadecimal representation, preceded or not by "U+", or as names,
  alias or labels between parentheses, as defined in the Unicode Character Database. U strings are BYTES strings.

Additionally, TUTOR also implements four new built-in functions: STRINGTYPE (returns __BYTES__, __CODEPOINTS__, __GRAPHEMES__ or __TEXT__, depending on the string type),
BYTES (transforms to the BYTES type), CODEPOINTS (transforms to the CODEPOINTS type), GRAPHEMES (transforms to the GRAPHEMES type) and TEXT (transforms to the TEXT type).

For more details about these built-in functions, please refer to the accompanying document, [_New built-in functions_](new-functions.md).
