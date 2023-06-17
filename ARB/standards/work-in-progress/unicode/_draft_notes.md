# Draft notes, to use as support during calls

## Identification of subcommittees

### Backward compatibility

(at least) three groups of users:

1) The programmer types that know about bytes, hex. They would need a byte type.
2) People using Rexx for all types of processing using natural language - most of it in their own codepage
3) People who have never been able to use their writing systems in combination with Rexx.

> (rick)
> A few other issues that will need to be addressed in trying to put this together. 
> 1) If there are two types that behave like strings, then the interactions between these two types (I'll use the names .Text and .Byte so it's clear which I'm talking about) need to be addressed. For example, concatenation. What happens if you concatenate a .Text to a .Byte? What type is the operation result? Note that any operation involving disparate types carries with it the risk of creating an invalid .Text encoding. This applies to all of the comparison operators, but also things like insert(), overlay(), pos(), etc. where more than one "string" is involved. 
> 2) Streams are inherently byte oriented in the way they have been used. There's probably going to need to be different modes for using the streams. 
> 3) APIs are definitely a problem area, the .Byte nature of the arguments and return values show up everywhere.
> 4) Even the XRANGE() and TRANSLATE() bifs can be a bit of a problem.

(Josep Maria)

A. For classic Rexx, an almost zero-cost way to implement Unicode would be to (1) introduce new Unicode strings, ended with "u" or "U", i.e., "xxx"X would be an hexadecimal string, "xxxx"b would be a binary string (no departure so far), and "xxxx"U would be a Unicode string (new stuff). This would break programs where a literal string ("xxxx") was collated to a variable called "U", but no more (and maybe we should have an Option to disable such "U" strings and then ensure perfect backwards compatibility). (2) Codepoint literals could be written as a variation of the hexadecimal string format, for example "U+E9"X, or "Ue9"x, or somesuch. This would be syntactically different enough from "normal" hexadecimal strings, and would indicate it was a Unicode codepoint reference. (3) In the same way that 2+ "a" produces a syntax error, "hello" + "mom"U should produce a syntax error ("Can not collate Unicode and byte strings", for example). BIFs could be dual-pathed for Unicode strings and for classic strings without problems, and without interference between "classic" strings and Unicode Strings. (4) Of course there should exist a set of encode/decode BIFs to transform Unicode strings to "classic" strings and vice versa.

B. Object oriented versions of Rexx could well follow the Classic Rexx paradigm and extend over it (i.e., duplicating classic rexx BIFs as the corresponding class BIMs, etc).

(/Josep Maria)

<examples & study to start>


### Define what is a character

See requirement document.

Probably grapheme, but good to investigate if an other approach could be valuable for some sceanrios.


### Internal representation

Two families of Rexx regarding the interpretation of strings:

- those working with raw bytes like Regina and ooRexx. c2x returns these raw bytes.
- those working with Unicode strings (netrexx and crexx)

> (adrian)
> - For ooRexx we could just have a new class(s) (as discussed) and the bif members would follow the expected analog
> - NetRexx - presumably is done(?)
> - cRexx level b/g - done as it is not backward compatible anyway. Moreover the compiler will know if it is bytes or text and behave as expected
> - For Classic REXX the essential problem comes down to knowing if a variable contains UTF-8 / Unicode - or if it contains binary. If it (and the BIFs) can do this then they can fall back to binary 8-bit behaviour.
> So for the classic REXX standard - I guess all we have to say is that the language processor needs to track this (text/binary contents). Literals would clearly be text, and file opens could be text or binary mode etc. BIFs would have to read the status, behave and set status as appropriate. Plenty of rules to work through ...

> (rené)
> I think it would be wrong to assume a character encoding.


### Validation

Invalid format (proto)

[Mojibake](https://en.wikipedia.org/wiki/Mojibake)

Filenames

[WTF8](http://simonsapin.github.io/wtf-8/) (proto)

Optimization, SIMD


### Serialization and deserialisation

> (josep maria)
> Manipulating a stream that is BINARY RECLENGTH nnn is the first example that comes to my mind.
>  One knows the binary structure of the records, for example you know that the first four bytes
>  of each record represent an integer. You get the first four bytes, Left(record, 4), then C2X, then X2D

we should distinguish internal representation from serialization - this particular
example can go wrong in so many ways; network byte order versus little endian;
signed (1 complement, 2 complement) vs unsigned;

Question:
ISO8859-1  
All bytes compatible with Unicode? or not?  
- [ISO8859](https://www.unicode.org/Public/MAPPINGS/ISO8859/)
- [Wikipedia](https://en.wikipedia.org/wiki/ISO/IEC_8859-1#Code_page_layout)

### String & characters notations


c2x, x2c

U+ notation (proto), 

Unicode escape sequence (proto), 

Literals

> (adrian) we should give the Unicode codepoint and not the UTF-8 coding when dealing with .text.

(jlf)  
c2x must return what x2c is needing to create a string from hex values.  
For NetRexx, it's a UCS-2 codepoint, limited to 16 bits.  
For cRexx, it's 32 bits because you choose to return Unicode scalar values (32 bit codepoints) and hide the internal encoding.  
For Regina and ooRexx, it's the internal encoding, whatever it is.

For all the interpreters, the 32 bit codepoints can be requested with a dedicated function, and returned as integers.  
Such integer acts as a key to query the properties of the Unicode character.  
(/jlf)


### String concatenation


[Rules in Executor](https://github.com/jlfaucher/executor/blob/72e68d17ec5b6797ccd9e0ba847f330ab34846be/sandbox/jlf/packages/encoding/encoding.cls#LL319C1-L346C1)

Rope


### Segmentation

Josep Maria : a priority should be given. For example, sgmentation by words and sentences is less prioritary than codepoints & graphemes.

Code point, Grapheme  (proto)

Codepoint/grapheme indexation  (proto)

Whitespaces, separators

Hyphenation

Words, Sentences


### Upper, lower, caseless

Case mappings (proto)

Collation, sorting


### String comparison

Normalization, equivalence  (proto)

String comparison (proto): strict, not strict

String matching - Lower vs Casefold  (proto)

Josep Maria : strict comparison should probably use NFC, and not strict maybe NFKC. Codepoint-based comparison (which would be stricter that strict comparison) would always be obtainable via APIs, if really needed. Comparison should never be based on internal representation. Internal representation should either be completely hidden to the user, or only obtainable via API calls. The following quote is extracted from [UAX #15 Unicode Normalization Forms](https://unicode.org/reports/tr15/#Norm_Forms), section 1.2:

>The _W3C Character Model for the World Wide Web 1.0: Normalization_ [[CharNorm]](https://unicode.org/reports/tr41/tr41-30.html#CharNorm) and other W3C Specifications (such as XML 1.0 5th Edition) recommend using Normalization Form C for all content, because this form avoids potential interoperability problems arising from the use of canonically equivalent, yet different, character sequences in document formats on the Web. See the _W3C Character Model for the Word Wide Web: String Matching and Searching_ [[CharMatch]](https://unicode.org/reports/tr41/tr41-30.html#CharMatch) for more background.

Shmuel : codepoints are important for some scenarios.

René : we can offer methods in addition to operators.



### Identifiers, Security


### Locale

CLDR Common Locale Data Repository


### BIDI


### Regular expressions


### Terminal / console / cmd

Describing the right environnment for the tests.

