# Backwards compatibility

## ARB recommendations

(TBD)

## Draft Notes

(at least) three groups of users:

1) The programmer types that know about bytes, hex. They would need a byte type.
2) People using Rexx for all types of processing using natural language - most of it in their own codepage
3) People who have never been able to use their writing systems in combination with Rexx.

> (rick)
> A few other issues that will need to be addressed in trying to put this together. 
> 1) If there are two types that behave like strings, then the interactions between these two types (I'll use the names `.Text` and `.Byte` so it's clear which I'm talking about) need to be addressed. For example, concatenation. What happens if you concatenate a `.Text` to a `.Byte`? What type is the operation result? Note that any operation involving disparate types carries with it the risk of creating an invalid .Text encoding. This applies to all of the comparison operators, but also things like `insert()`, `overlay()`, `pos()`, etc. where more than one "string" is involved. 
> 2) Streams are inherently byte oriented in the way they have been used. There's probably going to need to be different modes for using the streams. 
> 3) APIs are definitely a problem area, the `.Byte` nature of the arguments and return values show up everywhere.
> 4) Even the `XRANGE()` and + `TRANSLATE()` bifs can be a bit of a problem.

(jmb)

1. For classic Rexx, an almost zero-cost way (regarding compatibility) to implement Unicode would be to (1) introduce new Unicode strings, ended for example with "T" (meaning "Text"). Then `"xxxx"X` would be an hexadecimal string, `"xxxx"b` would be a binary string (no departure so far), and `"xxxx"T` would be a Unicode string (new stuff). This would break programs where a literal string ("xxxx") was abutted to a variable called "T", but no more (and maybe we should have an Option to disable such "T" strings and then ensure perfect backwards compatibility). (2) Codepoint literals could either be written as a variation of the hexadecimal string format, for example `"U+E9"X`, or we could use an "U" suffix, i.e., `"E9"U` (this would break old programs that abut a literal string to a variable called U). (3) In the same way that `2+ "a"` produces a syntax error, `"hello" || "Mom"T` should produce a syntax error ("Can not collate text and byte strings", for example). BIFs could be dual-pathed for Unicode strings and for classic strings without problems, and without interference between "classic" strings and Unicode Strings. (4) Of course there should exist a set of encode/decode BIFs to transform Unicode strings to "classic" strings and vice versa.

2. Object oriented versions of Rexx could well follow the Classic Rexx paradigm and extend over it (i.e., duplicating classic rexx BIFs as the corresponding class BIMs, etc).

(/jmb)

## Rationale for Executor

[Executor](https://github.com/jlfaucher/executor) is an extension of ooRexx 4.2.

### Goals

#### Functional

- RexxText supports the same methods as String, with grapheme indexes and canonical equivalence.
- The BIFs delegate to RexxText when a String instance is not compatible with a byte string.
- The parse instruction supports RexxText.

#### Architecture

- The existing String class is kept unchanged, its methods are byte-oriented.
- The prototype adds a layer of services working at grapheme level, provided by the RexxText class.
- The RexxText class works on the bytes managed by the String class.
- String instances are immutable, the same for RexxText instances.
- No automatic conversion to Unicode by the interpreter.
- The strings crossing the I/O barriers are kept unchanged.
- Supported encodings : byte, UTF-8, UTF-16, UTF-32.


### Bytes versus graphemes

A String instance is linked to a RexxText instance, which itself is linked to this String instance:

        a String
         ▲  text --------> a RexxText
         │                     indexer (anEncoding)
         │                          codepoints (sequential access)
         │                          graphemes  (direct access)
         +-<---------------------<- string

The ooRexx programmer has the choice :
- working with String at byte level
- working with RexxText at grapheme level.
- the same instance of String is used in both cases.

Working at byte level:

        myString=                       -- 'où as tu été ?'
        myString~length=                -- 18

                                        -- 1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18
        myString                        -- 6F C3 B9 20 61 73 20 74 75 20 65 CC 81 74 C3 A9 20 3F
                                        -- o. ù....  . a. s.  . t. u.  . e. acute t. é....  . ?.

Working at grapheme level:

        myText  =                       -- T'où as tu été ?'
        myText~length=                  -- 14

                                        -- 1  2     3  4  5  6  7  8  9  10       11 12    13 14
        myText                          -- 6F C3B9  20 61 73 20 74 75 20 65 CC81  74 C3A9  20 3F
                                        -- o. ù...   . a. s.  . t. u.  . e. acut  t. é...   . ?.

The Unicode scalars (codepoints) are available with
- aText~c2u which returns a String instance "U+xxxx U+xxxx ..." (4 to 6 hex digits per codepoint)
- aText~codepoints which returns a codepoint supplier. A codepoint is an integer.

The Unicode graphemes are available with
- aText~c2g which returns a String instance with the same hex digits as c2x, but with a space between graphemes.
- aText~graphemes returns a grapheme supplier. A grapheme is a RexxText instance.

### Compatibility

There is no reason to break the compatibility with the String instances:
- c2x is available, the hex digits show the bytes of the string encoding (yes, not hidden),
  spaces are used to separate the codepoints (easy to read and analyze, in particular when encoding errors).
- x2c, d2c are available on a RexxText instance. Forwards to the String instance,
  the result is a RexxText instance with default encoding.
- c2d is available. Forwards to the String class, the result is a String instance.
- The bit methods are available. Forwards to the String instance, the result is a String instance.

The `xrange` BIF is available for Unicode. If the default encoding is a Unicode encoding
then it supports the whole Unicode characters. Otherwise forwards to the legacy
implementation (byte 00..FF).

### Escape characters

If a string must be built using Unicode scalars then use the notation already
adopted by other languages:

        \u{Unicode name}    Character name in the Unicode database
        \U{Unicode name}    same as \u
        \u{X..X}            Unicode character denoted by 1-8 hex digits. The first character must be a digit 0..9 ('u' lowercase)
        \U{X..X}            same as \u
        \uXXXX              Unicode character denoted by 4 hex digits ('u' lowercase)
        \UXXXXXXXX          Unicode character denoted by 8 hex digits ('U' uppercase)
        \xXX                1 byte denoted by 2 hex digits ('x' lowercase)
        \XXXXX              2 bytes denoted by 4 hex digits ('X' uppercase)

These escape characters must be explictely unescaped by calling ~unescape
(so it's done at run-time, not at parse-time).  
Other languages support escape characters at parse-time.  
Cannot be applied to legacy strings because that will break compatibility. To study...

### BIFs

The BIFs are routed either towards String or towards RexxText,
in function of the compatibility of the arguments with String:

        BIF(str1, str2, ..., strN)

if at least one str argument is not compatible with String then the BIF is
routed towards the RexxText class.

Illustration of the impact of the string's encoding on the BIFs:

        -- The default encoding is UTF-8
        -- (i.e a string without explicit encoding is seen as an UTF-8 string)
    
    
        -- UTF-8 encoding

        "Noel"~isCompatibleWithByteString=              -- 1
        length("Noel")=                                 -- 4 because "Noel"~length = 4
        "Noël"~isCompatibleWithByteString=              -- 0
        length("Noël")=                                 -- 4 because "Noël"~text~length = 4
        "Noël"~length=                                  -- 5 because String remains byte-oriented, not impacted by the default encoding

        -- UTF-16BE encoding
        s = "0041004200430044"x
        s=                                              -- '[00]A[00]B[00]C[00]D'
        s~isCompatibleWithByteString=                   -- 1
        s~description=                                  -- 'UTF-8 ASCII (8 bytes)'
        length(s)=                                      -- 8 because encoding UTF-8 ASCII is compatible with String
        s~encoding = "UTF16"
        s~isCompatibleWithByteString=                   -- 0
        s~description=                                  -- 'UTF-16BE (8 bytes)'
        s~length=                                       -- 8 because String is always byte-oriented (ignores the encoding)
        length(s)=                                      -- 4 because forwards to Text (encoding UTF-16BE is not compatible with String)
        s~text~utf8=                                    -- T'ABCD'

        -- UTF-32 encoding
        s = "0000004100000042"x
        s=                                              -- '[000000]A[000000]B'
        s~isCompatibleWithByteString=                   -- 1
        s~description=                                  -- 'UTF-8 ASCII (8 bytes)'
        length(s)=                                      -- 8 because encoding UTF-8 ASCII is compatible with String
        s~encoding = "UTF32"
        s~isCompatibleWithByteString=                   -- 0
        s~description=                                  -- 'UTF-32BE (8 bytes)'
        s~length=                                       -- 8 because String is always byte-oriented (ignores the encoding)
        length(s)=                                      -- 2 because forwards to Text (encoding UTF-32 is not compatible with String)
        s~text~utf8=                                    -- T'AB'

## Some quick comments about Executor (jmb)

What you have done is really impressive, many thanks for sharing it here. Some quick comments

* For simplicity, I'd prefer to use "xxxx"T instead of T"xxxx". We already have "xxxx"X and "xxxx"B. It's difficult to understand (and to explain to students) why some strings use a prefix and some use a postfix.
* c2x(a) operates in such a way that the resulting string, "hhhhh", if prepended to an "X", "hhhh"X, will be identical to "a", i.e., "hhhh"X == a. And similarly for c2b and binary strings. I love the design of c2u. For simmetry reasons, the language should allow specifying strings as "U+xxxx U+xxxx"U. Since the internal U becomes redundant, I'd make it (and the plus sign) optional. Then "U+0041"U = "U41"U = "41"U. If the U is optional, then we should allow for "," as a delimiter. Blanks between hex strings have a different, defined meaning.
* My impression is that c2g should return graphemes in the "xxxx, xxxx, xx"U form. Again, blanks between hex strings have a different, defined meaning.
* Having a RexxText class that is tied to the String class is a neat solution, but, in my opinion, it has a major drawback. It keeps String as the basic, universal class, and if one wants RexxText, one has to do additional work. For me, this is a perfectly workable solution. But what I've understood, from our conversations in the ARB list, is that many people consider it to be unacceptable. I.e., we would want that a "normal" programmer can use Unicode strings by default.
* "If a string must be built using Unicode scalars then use the notation already adopted by other languages" -- I wouldn't agree on that. Backslash-escaped strings are not present in ooRexx, not in classic Rexx. If we open the door to \UXXXX, then we should accept \n, \t and all that. Also, it's difficult to explain why some strings are parse-time and some others are run-time.
* I understand the logic behind length("Noël")= 4, "Noël"~length= 5, but I'm not sure this can be reasonably explained to new users.
* To make c2x and similar BIFs work, you have to tie a RexxText to a String, i.e., somehow you are telling the user that there is an "underlying" or "ultimate" representation for the RexxText instance. Do we really want that? I don't think so. One think is to have all kind of encode/decode BIFs, BIMs, and so on; and the other is tying the RexxText instance to its encoding. You could well end up by having two strings that are identical (regarding, for example, NFC normalization) but return different c2x results. We definitely don't want that.
* Also, x2c et al are used to store certain values in a byte. But we won't know, in general terms, how a codepoint is stored. Or a grapheme cluster.
* Ontologically, I'm not convinced that a .String has to have a .RexxText, i.e., that a~text is a good idea. This assumes that a .String has an ~encoding. I'm not convinced about that, either. It can have one, it can have several, it can have none. A .String is a byte-indexable array of characters. .RexxText (or whatever name we agree upon) should be a _primary_ type, not a property of a .String instance.

Again, many thanks for sharing your design and your ideas.
