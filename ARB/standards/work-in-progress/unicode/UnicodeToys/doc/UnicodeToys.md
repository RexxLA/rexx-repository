# The Unicode Toys for Rexx

### Introduction

**The Unicode Toys for Rexx** is a set of ooRexx classes, files and programs that allow to play and experiment with Unicode concepts using
the Rexx language.

These classes and programs provide simple implementations of many Unicode properties, like General Category, Grapheme Cluster Break or Name.

The package also includes ``rxu.rex``, a Rexx Preprocessor for Unicode that implements a version of Rexx extended with several
new Unicode constructs:

* **Text** strings: they are ended by a "T" suffix, "like this"T. They are composed of extended grapheme clusters. For example, "👩‍👨‍👩‍👧🎅"T is composed of two grapheme clusters only, although it is formed of eighth codepoints.
* **Runes** strings: they are ended by a "R" suffix, "like this"R. They are composed of Unicode codepoints.
* **Bytes** strings: they are ended by a "C" suffix, "like this"C. They are composed of individual bytes, and they are equivalent to Classic Rexx strings (hence the final "C").
* **Codepoint strings**: they are ended by a "U" suffix, and can only contain:
  * Unicode codepoints, in the U+ format, like "U+0061"U or "U+20 U+61 U+20"U.
  * Unicode codepoints, without the U+ prefix, like "20 61 20"U.
  * Unicode codepoint names, according to UnicodeData.txt and NameAliases.txt, like  "(Woman) (ZERO WIDTH JOINER) (Man) (zwj) (WOMAN) (zwj) (Girl) (Father_Christmas)"U, which displays as "👩‍👨‍👩‍👧🎅".
 
Strings can be promoted/demoted by the new BYTES, RUNES and TEXT built-in functions (BIFs). For example, TEXT(string) transforms a string into a TEXT string, and so on.
 
Several BIFs have been adapted to work seamlessly with the new datatypes. LENGTH, for example, will return the number of bytes when its argument is a BYTES string, the number of codepoints when it is a RUNES string, 
and the number of grapheme clusters when it is a TEXT string. The same is true of SUBSTR, POS, LEFT, RIGHT, CENTER/CENTRE, COPIES, [] and many other BIFs. You can find an up-to-date list of these BIFs in the first lines of ``rxu.rex``.

RXU supports the following variations of the OPTIONS instruction:

* OPTIONS DEFAULTSTRING &lt;stringType&gt;. Determines the interpretation of an unsuffixed string, i.e., "string", with no B, X, C, R, T or U suffix. Possible values for <stringType>
  are BYTES, RUNES or TEXT. The preprocessor encloses unsuffixed strings with a call to the corresponding conversion BIF, e.g., if
  DEFAULTSTRING TEXT is in effect, then "string" will be equivalent to TEXT("string").
* OPTIONS CONVERSIONS NONE. Do not perform automatic conversions. Operations between differently typed strings, like concatenating a BYTES and a TEXT string, will raise a Syntax error. 
* OPTIONS CONVERSIONS PROMOTE. If one of the operands is TEXT, return a TEXT string. Else, if one of the operands is RUNES, return a RUNES string. Otherwise, return a BYTES string.
* OPTIONS CONVERSIONS DEMOTE. If one of the operands is BYTES, return a BYTES string. Else, if one of the operands is RUNES, return a RUNES string. Otherwise, return a TEXT string.
* OPTIONS CONVERSIONS LEFT. An attempt is made to convert the result to the class of the left operand.
* OPTIONS CONVERSIONS RIGHT. An attempt is made to convert the result to the class of the right operand.

OPTIONS CONVERSIONS is highly experimental. It currently works for the "||" concatenation only.

To start playing with the Toys, follow [the installation instructions](../../UnicodeToys#installation-instructions) to install the package. You can 
then create a file with a ``.rxu`` extension, for example ```test.rxu``, and use the ``rxu`` preprocessor to translate and run it:

```
    rxu test                    -- (Or "rexx rxu test" if under Linux)
```

Like a meccano, the components offered by the Unicode Toys can be modified to quickly create new prototypes, proof-of-concept implementations of new functions, etc. I hope they can be of use to other users and language implementors.

### Functionality of the Unicode Toys: a simple tour

Since other implementations (like Jean Louis Faucher's Executor) are centered in the OO aspects of implementing Unicode, I will choose the contrary approach and present things as if we were using an enhanced version of, say Regina Rexx.

```rexx
-- The Unicode Toys: A simple tour
-- -------------------------------
-- 
-- We will be playing with three string types, instead of only one.
--
-- Old-style strings will now be called BYTES strings. Given any kind of string,
-- a new BIF called BYTES will always return a BYTES string.

  var = BYTES(string)                    -- A classic Rexx string (encoded using UTF-8 if neccesary)

-- You can also indicate that a string is a BYTES string by using the "C" suffix:

  "string"C == BYTES("string")

-- RUNES strings are composed of runes (codepoints). Given any kind of string,
-- a new BIF called RUNES will always return a RUNES string.

  var = RUNES(string)                    -- A Runes string (decoded from UTF-8 if necessary).

-- Use the "R" suffix to indicate that a string is a RUNES string:

  "string"R = RUNES("string")

-- RUNES strings can be manipulated using the usual BIFs (currently, LENGTH, [], POS, LEFT, RIGHT,
-- COPIES, CENTER/CENTRE, LOWER and UPPER are implemented). These BIFs now operate at the rune (codepoint) level.

-- New BIFs are also included. R2N, "Rune to Name", transforms a codepoint (in standard
-- Unicode hexadecial format, but without the U+ prefix) into its Name property; N2R performs
-- the inverse conversion. ALLRUNES(string) returns a blank-separated collection of hexadecimal 
-- codepoints, without the U+ prefixes.

  runes = "noël👩‍👨‍👩‍👧🎅"R                  -- Creates a RUNES string
  Say 
  Say "runes ='"runes"', length="Length(runes)
  Say 
  Do i = 1 To Length(runes)
    rune = SubStr(runes, i, 1)           -- Get a single rune (codepoint)
    code = AllRunes(rune)                -- A single rune -> a single codepoint
    Say Right(i,2)":" Right("U+"code,7) "("Right("'"C2X(rune),9)"'X) '"rune"' ("R2N(code)")"
  End

-- Output:
--
-- runes ='noël👩‍👨‍👩‍👧🎅', length=12
--
--  1:  U+006E (      '6E'X) 'n' (LATIN SMALL LETTER N)
--  2:  U+006F (      '6F'X) 'o' (LATIN SMALL LETTER O)
--  3:  U+00EB (    'C3AB'X) 'ë' (LATIN SMALL LETTER E WITH DIAERESIS)
--  4:  U+006C (      '6C'X) 'l' (LATIN SMALL LETTER L)
--  5: U+1F469 ('F09F91A9'X) '👩' (WOMAN)
--  6:  U+200D (  'E2808D'X) '‍' (ZERO WIDTH JOINER)
--  7: U+1F468 ('F09F91A8'X) '👨' (MAN)
--  8:  U+200D (  'E2808D'X) '‍' (ZERO WIDTH JOINER)
--  9: U+1F469 ('F09F91A9'X) '👩' (WOMAN)
-- 10:  U+200D (  'E2808D'X) '‍' (ZERO WIDTH JOINER)
-- 11: U+1F467 ('F09F91A7'X) '👧' (GIRL)
-- 12: U+1F385 ('F09F8E85'X) '🎅' (FATHER CHRISTMAS)

-- TEXT strings are composed of (extended) grapheme clusters. Given any kind of string,
-- a new BIF called TEXT will always return a TEXT string.

  var = TEXT(string)                     -- A Runes string (decoded from UTF-8 if necessary).

-- You can also use the "T" suffix to indicate that a string is a TEXT string:

  "string"T == TEXT("string")

-- TEXT strings can be manipulated using the usual BIFs. These BIFs now operate
-- at the (extended) grapheme cluster level.

  text = "noël👩‍👨‍👩‍👧🎅"T                   -- Creates a TEXT string
  Say 
  Say "text ='"text"', length="Length(text)
  Say 
  Do i = 1 To Length(text)
    grapheme = SubStr(text, i, 1)        -- Get a single grapheme
    codes = AllRunes(grapheme)           -- Get all the codepoints for that grapheme
    Say Right(i,2)": '"grapheme"' ('"C2X(grapheme)"'X) '"codes"'U"
  End

-- Output:
-- 
-- text ='noël👩‍👨‍👩‍👧🎅', length=6
--
--  1: 'n' ('6E'X) '006E'U
--  2: 'o' ('6F'X) '006F'U
--  3: 'ë' ('C3AB'X) '00EB'U
--  4: 'l' ('6C'X) '006C'U
--  5: '👩‍👨‍👩‍👧' ('F09F91A9E2808DF09F91A8E2808DF09F91A9E2808DF09F91A7'X) '1F469 200D 1F468 200D 1F469 200D 1F467'U
--  6: '🎅' ('F09F8E85'X) '1F385'U
```
