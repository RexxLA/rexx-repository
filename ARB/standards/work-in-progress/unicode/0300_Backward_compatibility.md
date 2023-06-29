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

## Non object-oriented versions and BIFs

Any new BIF introduced will create a compatibility problem, since BIFs are searched before external routines. There seems to be no way out of this problem.

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
  (jlf)  
  agreed. The "T" prefix is just a pretty-print to make a distinction between RexxText instance and String instance. It's a prefix because I see it immediatly, but a suffix would be also ok.  
  (/jlf)

* c2x(a) operates in such a way that the resulting string, "hhhhh", if prepended to an "X", "hhhh"X, will be identical to "a", i.e., "hhhh"X == a. And similarly for c2b and binary strings. I love the design of c2u. For simmetry reasons, the language should allow specifying strings as "U+xxxx U+xxxx"U. Since the internal U becomes redundant, I'd make it (and the plus sign) optional. Then "U+0041"U = "U41"U = "41"U. If the U is optional, then we should allow for "," as a delimiter. Blanks between hex strings have a different, defined meaning.  

  (jlf)  
  Yes, I saw your proposition elsewhere. I don't have a strong opinion about "nnnn, nnnn, nnnn, nnnn"U. If other people find it useful then why not.  
  I use the blanks inside the hex string (not between), to make clear what is the segmentation. They are just separators. It's a real added value to me and will not abandon them.  
  (/jlf)
  
  (jmb)  
  I see that my assertion was unclear. I'll try to explain better. "hhhh"x == "hh hh"x, and "hhhhhhhh"x == "hhhh hhhh"x, i.e., blanks (in certain positions) are _irrelevant_ in hex strings. That's why I oppose simple blanks as separators: it's not a good idea to have non-significant blanks in one kind of strings, and significant in another kind of strings.  
  I'd make the comma mandatory, and maybe the blanks optional. And I agree with you, blanks make the string much more readable, so probably c2u should return "41, 42" instead of "41,42".  
  (/jmb)

* My impression is that c2g should return graphemes in the "xxxx, xxxx, xx"U form. Again, blanks between hex strings have a different, defined meaning.  
  (jlf)  
  No, here too, I look at the same internal encoding, with a different perspective. Same hex digits as c2x.  
  The blank separator between the graphemes is a real added value to me.  
  Side note:  
  I understand that NetRexx can show only Unicode scalars. Any other representation would need to pass an encoding.  
  cRexx takes the same decision, because they want to hide the internal representation.  
  Giving access to the internal representation is not making the rest of the functionalities less abstract.  
  (/jlf)
    
  (jmb)  
  About the string returned by c2g, please see my reply to the preceding point.  
  As I see it, the problem with giving access to the internal representation is not the lack of abstraction, but the fact that you're entering a contract with the programmers stating that the representation exists. Then prople will start producing programs that obey this contract. If we later decided, for whatever reason, that the representation should be changed, this change would become impossible.  
  (/jmb)
  
* Discussion about performance moved to [a separate section](./Performance.md)

* "If a string must be built using Unicode scalars then use the notation already adopted by other languages" -- I wouldn't agree on that. Backslash-escaped strings are not present in ooRexx, not in classic Rexx. If we open the door to \UXXXX, then we should accept \n, \t and all that. Also, it's difficult to explain why some strings are parse-time and some others are run-time.  
  (jlf)  
  Very useful when you copy-paste examples from blogs.  
  Rony had the same need for [JSON](https://sourceforge.net/p/oorexx/code-0/HEAD/tree/main/trunk/extensions/json/json.cls).  
  It's impossible to support the escape characters at parse-time without breaking all the scripts, unless a solution exists that I don't see.  
  The unescape at run-time can be seen as a facility provided by a library, not a core functionality.  
  (/jlf)
  (rvj) NetRexx has these already and let go of the 'string'X notation(/rvj)
  (jmb)  
  I'd vote for the run-time library, or a BIF, or BIM, or somesuch.  
  The only way I see to support escape characters at parse-time without breaking everything is to introduce still another form of string, i.e., choose a new suffix, say "P" (this is not a proposal) and then stipulate that P-strings, in the form "xxxx"P, can have escaped sequences.  
  But if we are already considering X for hex, B for binary, T for Unicode, and maybe C for compatibility, maybe adding still a new type of string would be too much, and go against the spirit of simplicity of Rexx ("Keep the language small")  
  (/jmb)  

* I understand the logic behind length("Noël")= 4, "Noël"~length= 5, but I'm not sure this can be reasonably explained to new users.  
  (jlf)  
  Yes, but that's the reality.  
  And that's a fundamental rule of the prototype: "The ooRexx programmer has the choice".  
  Would be more easy for new users after the switch String <--> RexxText, maybe.  
  I struggle to find how Regina (and any Rexx without class) could support both lengths with only the `length` BIF.  
  I asked to cRexx team how they get the length in bytes. Apparently, there is no BIF, but it's possible to [use
  some microcode to implement a `length` procedure](https://groups.io/g/rexxla-arb/message/186).  
  I guess I will be told that nobody needs the length of a string in bytes.  
  (/jlf)

  (jmb)  
  Rexxes without classes will have to deal with two types anyway. When a string is Unicode, LENGTH should return the number of grapheme clusters. If you want the length in bytes, you will have to decode first the Unicode string into a byte buffer, and, voilà!, you have your length in bytes.  
  I understand the experiment you are making with your prototype, and I have the highest respect for your work. But the general idea (i.e., not limited to Executor) that a Unicode string has to have a length in bytes seems completely wrong to me. It will have a length in bytes _as soon as you decode it_.  
  (/jmb)  

* To make c2x and similar BIFs work, you have to tie a RexxText to a String, i.e., somehow you are telling the user that there is an "underlying" or "ultimate" representation for the RexxText instance. Do we really want that? I don't think so. One think is to have all kind of encode/decode BIFs, BIMs, and so on; and the other is tying the RexxText instance to its encoding. You could well end up by having two strings that are identical (regarding, for example, NFC normalization) but return different c2x results. We definitely don't want that.  
  (jlf)  
  Yes, the couple (String, RexxText) is the driving principle of the architecture.  
  The prototype is an experimentation of a smooth transition from bytes to graphemes.  
  Regarding the different values for c2X, this is exactly what I want.  
  The abstraction is elsewhere.  
  (/jlf)  
    
  (jmb)  
  As a prototype for experimentation this is, undoubtedly, invaluable. I'm not criticizing Executor. I'n trying to think about a new Rexx standard that includes Unicode. I don't think it's a good idea to tell people that string A and B are strictly equal, A == B, but that there are some internal details, that, well... This would go against the most basic nature of equality, i.e., the law of [indiscernibility of identicals](https://en.wikipedia.org/wiki/Identity_of_indiscernibles#Indiscernibility_of_identicals).  
  (/jmb)  

  (jlf)
  Interesting link, thanks. Will need to read it several times, but could not resist to try to apply the reasoning:   
  ClarkKent = "René"  
  Superman = "René"  
  Lois Lane knows that ClarkKent has 4 codepoints: U+0052 U+0065 U+006E U+00E9  
  Lois Lane knows that Superman has 5 codepoints: U+0052 U+0065 U+006E U+0065 U+0301  
  Therefore Superman is not identical to ClarkKent.  
  But Unicode says that they are equal when comparing their grapheme clusters.  
  Do we go against the most basic nature of equality?  
  
      say ClarkKent == Superman             -- 0
      say ClarkKent~text == Superman~text   -- 1
      
  (/jlf)

  (jmb)  
  :-)  
  It's one of the basic rules of equality, as studied by logic. These laws are so ingrained in our way of thinking that normally they are thought of as evident and therefore never explicited. From equality, one should expect (a) reflexivity, i.e, $\forall x (x = x)$; (b) symmetry, i.e., $\forall x \forall y (x = y \rightarrow y = x)$; (c) transitivity, i.e., $\forall x \forall y \forall z ( (x = y \land y = z) \rightarrow x = z)$, (d) the law of indiscernibility of identicals, which can be very clearly stated in plain language: if two things A and B are identical, then there should not be any property P such that P(A) \\= P(B).  
  Of course in computer science you will only have perfect indiscernibility in the reflexive case (i.e., when you are comparing one variable to itself), because otherwise address(x) \\= address(y).  
  I'll state again my point in a different way. We can (and should) offer a decode BIM. Then the _decoded_ byte string may well be different, depending on the way we store Unicode strings. This would allow for ``"René"~decode("UTF-8")~length = 5. But first-order BIMs should always return the same, except perhaps for the ones that manage internal representations, like encode and decode.  
  "René" only _has_ a c2x if we assume that an Unicode string _has_ an encoding. I strongly oppose this idea, as I've explained in detail in the next point.
  On the other hand, "René"~decode("UTF-8") is a byte string, and then of course it has c2x.
    
  [later -- for entertainment only]
    
  The superman example contained in the Wikipedia article is, of course, ludicrous. The same happens with many classical discussions in logic. For example: assume there is an universe that contains two perfectly identical spheres, orbiting each other, and no more objects. If we don't introduce a viewer, who can point her finger and say "_this_ sphere", or "_that_ sphere", then both spheres are indeed indistinguishable (=indiscernible), but nonetheless not identical (=not the same). And this would seem to contradict the law of identify of indiscernibles. Then a lot of subtle discussions ensue, where the concept of "thisness" is considered and discussed, and so on. A can of worms, of course. A little humour is the only antidote :)  
  (/jmb)  
  
* Also, x2c et al are used to store certain values in a byte. But we won't know, in general terms, how a codepoint is stored. Or a grapheme cluster.  
  (jlf)  
  Your assertion is true for NetRexx and cRexx.  
  It's false for Executor because by design, the internal representation is not hidden. I'm so glad to have access to it when analyzing encoding errors.  
  Both approaches allow the same abstractions.  
  (/jlf)

* Ontologically, I'm not convinced that a .String has to have a .RexxText, i.e., that a~text is a good idea. This assumes that a .String has an ~encoding. I'm not convinced about that, either. It can have one, it can have several, it can have none. A .String is a byte-indexable array of characters. .RexxText (or whatever name we agree upon) should be a _primary_ type, not a property of a .String instance.  
  (jlf)  
  The couple (String, RexxText) is the driving principle of the architecture.  
  Both classes are a primary type.  
  A String instance can exist without a linked RexxText instance.  
  A RexxText instance cannot exist without a String instance.  
  The circularity makes trivial the change of default class. Today, the default class is String because RexxText is incomplete.  
  Yes, a string has an encoding. Always. You can't interpret the bytes without this information.  
  Even Java needs an encoding. 
  The difference is when the encoding information is lost.  
  For Java, it's lost at the moment when a String instance is created from a ByteBuffer.  
  That's why the ARB mailing list is talking about passing a size parameter or an encoding to c2x.  
  For Executor (like Ruby), the encoding is never lost.  
  That's why Executor can always provide a c2x string that is aligned with the string's encoding.  
  (/jlf)
  
  (jmb)  
  I will defend now the following position: strings do not always have encoding, but, yes, you can't interpret the bytes _as a Unicode string_ without that information.  
  Examples.  
  (1) You are asked to read a Stream which is BINARY RECLENGTH 80 and to set the "80"X bit of the fifth byte in each of the logical lines. You can do that without knowing anything about the encoding. Indeed, given the nature of your job, it might well be that the file is purely binary, i.e., that it doesn't store text at all, but only binary data (i.e., bit masks, integers, and so on).  
  (2) Many strings, like "4131"X, can be understood in several different ways, for example as "A1" (utf-8), or as 䄱, "4131"U, which is a CJK Unified Ideograph ("a kind of grain").  
  One can conclude, then, that your statement, "A string (always) has an encoding" is not universally true. Some strings have no encoding because they are not intended to represent characters, but only binary data.  
  Some other strings can be interpreted in radically different ways depending on the encoding, and also have valid interpretations which imply no encoding at all (for example, "4131"~x2d = 16689, an space-efficient way to store a number when you are space-constrained).  
  Therefore, a string doesn't _"have"_ an encoding, neither does it _have to have_ one. One _uses_ an encoding to interpret a string.  
  (/jmb)  

  (jmb 20230626)  
  Coming back to this thread and pondering the question again, I see that what bothers me is the notation ``s~encoding``. My impression is that the encoding is an _immutable_ attribute _of the result of the encoding operation_, instead of a _mutable_ attribute of the source string, as expressions like ``S~encoding = 'UTF-8'`` seem to suggest. ``Text = s~encode("UTF-8")`` and ``encoding = text~encoding`` look right to me, but neither ``s~encoding`` nor ``text~encoding = ...`` look right.  
  (/jmb)  

Again, many thanks for sharing your design and your ideas.
