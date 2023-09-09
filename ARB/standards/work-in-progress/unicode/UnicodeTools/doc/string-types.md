# New types of strings

## Introduction

Classic Rexx defines three different syntactical constructions to denote string literals:

* ``"Character"`` strings, enclosed between single ro double quotes.
* ``"Hexadecimal"X`` strings, with a ``X`` suffix. They are composed of hexadecimal digits and optional blank characters.
* ``"Binary"B`` strings, with a ``B`` suffix. They are composed of binary digits and optional blank characters.

### String equivalence

Please note that character, hexadecimal and binary strings are all _different notations for the same class of strings_, namely, they are all equivalent and interchangeable between them.
For example, if we assume an ASCII encoding, ``"a"``, ``"61"X`` and ``"0110 0001"B`` are _the same string_: they are different ways to denote a single value.

Assume that you have a label ``"a"``:

```rexx
"a": /* do something */
```

You can then use that label (with a function call, a ``CALL`` or ``SIGNAL`` statement, etc.) by referring to it as ``"61"X``, or
``"0110 0001"B``:

```rexx
Call "61"X            -- Identical to 'Call "a"'
Signal "0110 0001"B   -- Identical to 'Signal "a"'
```

Similarly, ``"a" = "61"X`` will be true, and so on. Let's keep this aspect of Rexx in mind later, when we address the new kinds of Unicode literals.

### Purpose of this document

In this document, we will explore the impact that an Unicode-aware implementation of Rexx will have on the universe of Rexx strings.
New nomenclature will be introduced, and a small set of new built-in functions will be defined. The main purpose of the document
will be to provide a _rationale_ for the proposed extensions, as a basis for further discussion and comment.

## What is a Rexx Unicode string?

A Rexx Unicode string should implement all the (implementable) built-in functions of Rexx, but applied to the Unicode universe.
For example, Classic Rexx UPPER modifies only the ``A-Z`` and ``a-z`` ranges, but one would expect Unicode UPPER to uppercase
the full range of cased Unicode codepoints, (or even the full range of cased Unicode grapheme clusters, depending on the
meaning of "character" that is finally chosen).

Similarly, POS operates on characters when used against a classic Rexx string, but it should operate on Unicode scalars
when used against a Unicode string (or even against grapheme clusters, depending on the meaning of "character" that is
finally chosen).

## Necessity of at least two string types

One needs to keep classic rexx strings ("classic strings" for short) into the language, for compatibility reasons; at the same time, one wants to be
able to fully manage Unicode strings. As we have seen, the behaviour of built-in functions has to be _different_ when operating with
classic strings and when operating with Unicode strings. Under ooRexx, this difference can be implemented using ooRexx classes;
but it would be very nice if we could define Rexx extensions that could be implemented by Classic Rexx interpreters, i.e, by
interpreters that do not include object-oriented features. We should, then, be able to differentiate both types of
string _at run time_, e.g., the value of a parameter may a classic rexx string, or a Unicode string.

Please note that this is _not_ the same as the "types" returned by the DATATYPE built-in function. DATATYPE should have
been (more aptly) named DATACONTENT: it allows one to check whether _the contents_ of a string is suitable, for
example, to form an hexadecimal number, but the nature of the underlying string never changes: it is always
a classic Rexx string.

When we are proposing --and what is indeed needed-- is a new string system, in which there are strings
of different types. Of real types, as the types in Pascal, of types that influence the semantics of the typed
variable. The fact that a string is of a type or of another type will influence the results of the various built-in
functions: each string has its own type and, if these types are different, they will behave in different ways.

As an example, the character ``"á"``, "Latin small letter a with acute", has a UTF-8 representation of ``"C3A1"X``; 
assuming a UTF-8 encoding, ``LEFT("á",1)`` will be ``"C3"X`` when operating on classic strings, and ``"C3A1"X`` when operating on Unicode characters.

This need for several string types will lead us to a number of quandaries, questions and problems, which we will be addressing below.

## The first quandary: how to introduce types in an untyped language?

If we restrict ourselves to Classic Rexx, we are supposed to be working with a _typeless_, or _untyped_, language: everything
is a string. Then speaking of different types of string would, at first glance, look like a contradiction. But "everything
is a string", indeed, does _not_ strictly mean that there are no types. What "there are no types" means is "there are no declarations",
that is, both (a) that "you don't have to specify beforehand the type of a variable" and (b) that "a variable can change types dynamically
at run-time". But Rexx variables _do have_ types. For example, arithmetic types: you can multiply two variables if and only if they
are both numbers (i.e., if they are both of the arithmetic type).

In this sense, adapting the nomenclature to include two or more types of strings should not be too difficult.

## The second quandary: Unicode-first vs. compatibility

Let's introduce some nomenclature. An implementation of Unicode-aware Rexx will be _Unicode-first_, 
if unsuffixed strings are, by default, Unicode strings; otherwise, we will say that the implementation is _Classic-strings first_. 

Similarly, we will say that an implementation of Unicode-aware Rexx is _compatible_ if existing, non-Unicode, programs can be run unchanged in this
implementation; otherwise, we will say that the implementation is _incompatible_, or _non-compatible_.

Ideally, we would like an implementation of Unicode-aware Rexx to be both _Unicode-first_ and _compatible_ at the same time. 
But this is clearly impossible: if the implementation is Unicode-first, unsuffixed strings will have Unicode semantics, 
and then some of the existing programs will break. And, conversely, if an implementation is compatible,
unsuffixed strings have to behave as classic strings, not as Unicode strings, and then the implementation cannot be Unicode-first.

One way out of this dilemma is to allow two dialects of Rexx: a _compatibility dialect_, in which unsuffixed strings would be classic strings, and
a _Unicode dialect_, in which unsuffixed strings would be Unicode strings. The compatibility dialect would not be Unicode-first, but it would
be perfectly compatible; the Unicode dialect would be Unicode-first, but it would not be compatible.

Some mechanism should be introduced to specify which dialect is in use. This could be an ``OPTIONS`` instruction, an ``::OPTIONS`` directive
(for ooRexx), or some other mechanism, like a language processor switch. A question remains: how should programs written in different dialects
interoperate?

## New strings for Unicode: a rationale

In any case, and regardless of the dialect, it is perfectly conceivable that the programmer needs to use strings
of the "other" dialect in her program. For example, if she was using the compatibility dialect, where strings are classic by default,
she could want to manage some strings that were Unicode strings; and, conversely, if she was using the Unicode dialect,
she could want to manage some strings that were classic strings.

This introduces the need for (1) a way to specify (1a) classic string literals in a Unicode-first program, (1b) and Unicode string
literals in a compatibility program; and (2) a way to distinguish, at run-time, whether a string is a classic string, or a Unicode string.

--- TBC ---

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

