# New types of strings

## Introduction

Classic Rexx defines three different syntactical constructions to denote string literals:

* ``"character"`` strings, enclosed between single ro double quotes.
* ``"hexadecimal"X`` strings, with a ``X`` suffix. They are composed of hexadecimal digits and optional blank characters.
* ``"binary"B`` strings, with a ``B`` suffix. They are composed of binary digits and optional blank characters.

### String equivalence

Please note that character, hexadecimal and binary strings are all forms of the same strings, and they are equivalent between them.
For example, if we assume an ASCII encoding, ``"a"``, ``"61"X`` and ``"0110 0001"B`` are _the same string_, i.e.,
they are different ways to denote the same value.

In this sense, you can have a label of ``"a"``,

```
"a": Procedure
```

and then use that label (with a function call, a ``CALL`` or ``SIGNAL`` statement, etc.) by referring to it as ``"61"X``, or
``"0110 0001"B``:

```
Call "61"X            -- Identical to 'Call "a"'
Signal "0110 0001"B   -- Identical to 'Signal "a"'
```

## New strings for Unicode: a rationale

The _first basic condition for Unicode-enabled Rexx_ is to preserve compatibility for old programs. This means that Unicode-enabled
Rexx programs will have to handle at least two different types of strings. Let's introduce some nomenclature:

* _Classic strings_, or _Classic Rexx strings_, are strings composed of bytes (octets). 
* _Unicode strings_ are the new strings implemented by Unicode-enabled Rexx.

Classic strings will be used (a) for compatibility with old programs, and (b) when one wants to manage the constituent
bytes of the string, for example, to store binary values packed with D2X and X2C.

Unicode strings will extend the built-in functions of Classic Rexx to the Unicode world. Unicode characters will no
longer be limited to one byte; indeed, the very same definition of "character" will be under discussion.

The Unicode standard defines _Unicode scalars_, integer numbers that represent _Unicode codepoints_, and _(Extended)
Grapheme Clusters_, collections of scalars that constitute a "user-perceived character". Some languages (e.g., Java)
define their characters to be Unicode scalars; some other languages (e.g., Swift) define their characters to be
Extended Grapheme Clusters.

There are good reasons to adopt both definitions: if characters are scalars (i.e., codepoints), you can have
speed-efficient representations (UTF-32), space efficient representations (UTF-8), and an in-between
that might be useful if your application is limited to the Basic Multilingual Plane (UTF-16); if characters
are Extended Grapheme Clusters, you lose efficiency, but you gain a better conformance with the standard,
and (it is hoped) a better experience for the end-users.

The RXU Rexx Preprocessor for Unicode implements both definitions, i.e., it has a data type for unicode scalars,
called CODEPOINTS, and another data type for Extended Grapheme Clusters, called TEXT. 

This may seem redundant, but it has its benefits. TEXT is supposed to be the default string type for Unicode-enabled Rexx programs, and, in this
sense, CODEPOINTS would always be a secondary, technical type. But a CODEPOINTS string offers compatibility
with Java (and with all the other languages that have opted to implement characters as scalars, instead of graphemes), and
it may be useful when you have to manage streams that are not normalized or (by using a special switch) contains ill-formed sequences,
like Windows file names. TEXT strings can be normalized at string creation time, while CODEPOINTS strings will never
be automatically normalized; and so on.

### A note about the implementation strategy 

There has been some discussion about whether it is a good idea or not to have two different Unicode string types
in Rexx. Similarly, there has been some discussion about whether special names (i.e., TEXT and CODEPOINTS) should be assigned to these different types,
or it would be more convenient to subsume all the names in a single specialized BIF, say STRING. The RXU approach is to allow all possibilities
to coexist at once, and to allow all the different names to have maximum visibility. The reasons for such an approach are mainly
_psychological_ and _sociological_. It is much easier to thing of two types of string and finally to renounce one, than to think of only one type: renouncement is then
built-in, so to speak, inside the very same language you are using, and then it is very easy to end up by introduce biases, thinking that they are unavoidable conditions 
of your choice. On a similar vein, we cannot forget that RXU (and the whole Unicode Tools Of Rexx) are a _prototype_ to foster discussion and interchange
about a future Unicode-aware implementation of Rexx, not the future implementation itself: in this sense, giving names (like BYTES, TEXT or CODEPOINTS) to the entities 
we have to handle (i.e., Classic RExx strings, codepoint-based strings, and grapheme based strings) is a way to fix ideas, to create a collective vocabulary
for the Architecture Review Board to share and use, and to disseminate a collective imaginary -- that's how collective decisions are taken.

### T- and, P- and Y- strings; default string type

Coming back to our main subject: we need a notation to specify that a literal string is a TEXT or a CODEPOINTS string: we have chosen ``"string"T`` for TEXT,
and ``"string"P`` for CODEPOINTS.

We will also need a _name_ and a _notation_ for Classic Rexx strings. Let's start with the _name_ first: we will say that these strings are BYTES strings: 
a string will now be either a BYTES string, or a CODEPOINTS string, or a TEXT string, and nothing more. We will also introduce
a new BIF, called STRINGTYPE, so that ``STRINGTYPE(string)`` will return precisely __BYTES__, __CODEPOINTS__ or __TEXT__, 
depending on the type of _string_.

We also need a _notation_. Per force, we will have programs that have to handle both Classic strings (i.e., BYTES strings) and
Unicode strings (i.e., TEXT or CODEPOINTS strings, or both) at the same time.

And so we come to the _second basic condition for Unicode-enable Rexx_: Unicode should be the default. What does this mean,
exactly? Well, for example, it means that ``"string"`` should, by default, be a Unicode string (i.e., a TEXT or a CODEPOINTS string).
But here we encounter a problem: if strings are Unicode strings by default, this breaks (potentially) all the Classic Rexx programs.

