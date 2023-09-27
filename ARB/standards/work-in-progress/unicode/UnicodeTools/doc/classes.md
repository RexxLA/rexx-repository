# New classes

## A non-object oriented presentation of the classes

From a procedural point of view, a string can have one of three _types_: ``BYTES``, ``CODEPOINTS``, or ``TEXT``. You get retrieve the type of a string by using the ``STRINGTYPE(string)`` BIF. 

### Promotion and demotion BIFs

A BYTES string _string_ can be __promoted__ to CODEPOINTS by using the ``CODEPOINTS(string)`` BIF, or to TEXT by using the ``TEXT(string)`` BIF; a CODEPOINTS string _string_ can be __demoted__ to BYTES by using the ``BYTES(string)`` BIF, or __promoted__ to TEXT by using the ``TEXT(string)`` BIF; a ``TEXT`` string _string_ can be __demoted__ to CODEPOINTS by using the ``CODEPOINTS(string)`` BIF, or to BYTES by using the ``BYTES(string)`` BIF.

Demotion always succeeds. Promotion from BYTES can fail: ``CODEPOINTS`` and ``TEXT`` require that their argument _string_ contains well-formed UTF-8. You can validate a string _string_ for UTF-8 well-formedness by using the ``UTF8(string)`` BIF.

### Semantics, and a rationale for the three types/classes system

A string is always _the same_, irrespective of its type. Changing the type of a string amounts to _changing our view of the string_.

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

This _view_ of a string is implemented by a series of built-in functions (BIFs). As we have seen in our examples, the _same_ BIFs (like LENGTH(string), or string[n], for instance) operate polymorphically on strings of types BYTES, CODEPOINTS or TEXT, and, in every case, they return the values that correspond to their respective types.

When a BIF has more than one string as an argument, there is always an argument which is the "main" string. For example, in POS(_needle_, _haystack_), _haystack_ is the main string. The remaining strings are  promoted or demoted, if needed, to match the type of the main string; in the case of promotions, this operation can raise a Syntax error (i.e., when the source string contains ill-formed UTF-8 sequences).

__Examples:__

```
Pos("E9"U, "José"T)                               -- 1   Same as Pos( Bytes("E9"U), "José")
Pos("80"X, "José"T)                               -- Syntax error
```

## An object-oriented presentation of the classes

* ``BYTES``. A class similar to Classic Rexx strings. A BYTES string is composed of bytes, and all the BIFs work as in pre-Unicode Rexx. The BYTES class adds a ``C2U`` method (see the description of the ``C2U`` BIF for 
  details), and reimplements a number of ooRexx built-in methods: \[\], C2X, CENTER, CENTRE, DATATYPE (a new option, ``"C"``, is implemented: ``DATATYPE(string,"C")`` will return __1__ when and only when ``"string"U`` 
  would be a valid Unicode string), LEFT, LENGTH, LOWER, POS, REVERSE, RIGHT, SUBSTR, U2C (same as ``X2C``, but for ``U`` strings), and UPPER.
* ``CODEPOINTS``. A CODEPOINTS string is composed of Unicode codepoints. CODEPOINTS is a subclass of BYTES. The CODEPOINTS class redefines the most basic BIMs (\[\] and LENGTH), and the other BIMs, being defined on 
  those, work automatically.
* ``TEXT``. A TEXT string os composed of Unicode extended grapheme clusters. TEXT is a subclass of CODEPOINTS. The TEXT class redefines the most basic BIMs (\[\] and LENGTH), and the other BIMs, being defined on
  those, work automatically.
