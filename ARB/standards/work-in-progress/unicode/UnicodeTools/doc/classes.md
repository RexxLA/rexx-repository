# New classes

## A non-object oriented presentation of the classes

From a procedural point of view, a string can have one of three _types_: ``BYTES``, ``CODEPOINTS``, or ``TEXT``. You get retrieve the type of a string by using the ``STRINGTYPE(string)`` BIF. 

### Promotion and demotion BIFs

A BYTES string _string_ can be __promoted__ to CODEPOINTS by using the ``CODEPOINTS(string)`` BIF, or to TEXT by using the ``TEXT(string)`` BIF; a CODEPOINTS string _string_ can be __demoted__ to BYTES by using the ``BYTES(string)`` BIF, or __promoted__ to TEXT by using the ``TEXT(string)`` BIF; a ``TEXT`` string _string_ can be __demoted__ to CODEPOINTS by using the ``CODEPOINTS(string)`` BIF, or to BYTES by using the ``BYTES(string)`` BIF.

Demotion always succeeds. Promotion from BYTES can fail: ``CODEPOINTS`` and ``TEXT`` require that their argument _string_ contains well-formed UTF-8. You can validate a string _string_ for UTF-8 well-formedness by using the ``UTF8(string)`` BIF.

### Semantics, and a rationale for the three types/classes system

A string is always _the same_, irrespective of its type. Changing the type of a string amounts to _changing our view of the string_.

Namely,

* We view a BYTES string as _a string composed of bytes_ (octets). This is equivalent to Classic Rexx strings, and to the String type of ooRexx. "A character" means the same as "a byte" ("an octet"). BIFs operate on characters = bytes = octets.
* We view a CODEPOINTS string as _a string composed of Unicode codepoints_. All the usual BIFs will continue working, but new "a character" means "a Unicode codepoint".
* We view a TEXT string as _a string composed of extended grapheme clusters_. All the usual BIFs will continue working, but new "a character" means "an extended grapheme cluster".

__Examples:__

```
string = "(Man)(Zero Width Joiner)(Woman)"U
Say string                                       -- "👨‍👩" (U strings are always BYTES strings)
Say C2X(string)                                  -- "F09F91A8E2808DF09F91A9"
Say Length(string)                               -- 11
string = Codepoints(string)
Say C2X(String)                                  -- "F09F91A8E2808DF09F91A9". It's the same string,...
Say Length(String)                               -- 3 ...but its interpretation (it's "view") has changed.
```

## An object-oriented presentation of the classes

* ``BYTES``. A class similar to Classic Rexx strings. A BYTES string is composed of bytes, and all the BIFs work as in pre-Unicode Rexx. The BYTES class adds a ``C2U`` method (see the description of the ``C2U`` BIF for 
  details), and reimplements a number of ooRexx built-in methods: \[\], C2X, CENTER, CENTRE, DATATYPE (a new option, ``"C"``, is implemented: ``DATATYPE(string,"C")`` will return __1__ when and only when ``"string"U`` 
  would be a valid Unicode string), LEFT, LENGTH, LOWER, POS, REVERSE, RIGHT, SUBSTR, U2C (same as ``X2C``, but for ``U`` strings), and UPPER.
* ``CODEPOINTS``. A CODEPOINTS string is composed of Unicode codepoints. CODEPOINTS is a subclass of BYTES. The CODEPOINTS class redefines the most basic BIMs (\[\] and LENGTH), and the other BIMs, being defined on 
  those, work automatically.
* ``TEXT``. A TEXT string os composed of Unicode extended grapheme clusters. TEXT is a subclass of CODEPOINTS. The TEXT class redefines the most basic BIMs (\[\] and LENGTH), and the other BIMs, being defined on
  those, work automatically.
