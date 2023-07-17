# The Unicode Toys

### Introduction

Unicode Toys is a set of ooRexx classes, files and programs that allow to play ("toys") with Unicode concepts. 
They provide very simple implementations of several Unicode properties, like General Category, Grapheme Cluster Break or Name, 
three different types of string (BYTES, implemented by ooRexx Strings; RUNES, consisting of Unicode codepoints; and TEXT, consisting of extended grapheme clusters),
and a set of functions to convert between the three types.

Like a meccano, these components ("toys") can be modified to quickly create prototypes, proof-of-concept implementations of new functions, etc.

The included classes contain a simple implementation of a portion of Unicode functionality. I hope they can be of user to other implementors.

### Functionality of the Unicode Toys: a simple tour

To start playing with the Toys, download all the files in the [UnicodeToys](.) directory and its subdirectories, create a new Rexx program, and add a ``::Requires Unicode.cls`` directive. You can then write your programs as you were programming in classic Rexx, and of course you can also use the new object-oriented features.

Since other implementations (like Jean Louis Faucher's Executor) are centered in the OO aspects of implementing Unicode, I will choose the contrary approach and present things as if we were using an enhanced version of, say Regina Rexx.

We have a big problem with BIFs: since BIFs are searched first in the search order, there is no simple way to override them. But we _need_ to override them: LENGTH, for example, has to return (very) different results depending on whether a string is a BYTES, a RUNES or a TEXT.

There is no simple way out of this problem. One approach involves adding internal routines that catch the calls to the various BIFs and then route these calls to the appropriate routine of method. This is cumbersome.

A future release will include a preprocessor that changes these calls to new functions.

```rexx
-- The Unicode Toys: A simple tour
-- -------------------------------
-- 
-- We will be playing with three string types, instead of only one.
--
-- Old-style strings will now be called BYTES strings. Given any kind of string,
-- a new BIF called BYTES will always return a BYTES string.

var = BYTES(string)                    -- A classic Rexx string (encoded using UTF-8 if neccesary)

-- RUNES strings are composed of runes (codepoints). Given any kind of string,
-- a new BIF called RUNES will always return a RUNES string.

var = RUNES(string)                    -- A Runes string (decoded from UTF-8 if necessary).

-- RUNES strings can be manipulated using the usual BIFs (currently, LENGTH, [], POS, COPIES
-- and CENTER/CENTRE are implemented). These BIFs now operate at the rune (codepoint) level.

-- New BIFs are also included. R2N, "Runes to Name", transforms a codepoint (in standard
-- Unicode hexadecial format, but without the U+ prefix) into its Name property; N2R performs
-- the inverse conversion. ALLRUNES(string) returns a blank-separated collection of hexadecimal 
-- codepoints, without the U+ prefixes.

runes = Runes("noël👩‍👨‍👩‍👧🎅")            -- Creates a RUNES string
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

-- TEXT strings can be manipulated using the usual BIFs (currently, LENGTH, [], POS, COPIES
-- and CENTER/CENTRE are implemented). These BIFs now operate at the (extended) grapheme
-- cluster level.

text = Text("noël👩‍👨‍👩‍👧🎅")              -- Creates a TEXT string
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
     

     
     
