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

Mojibake

Filenames

WTF8 (proto)

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

String comparison (proto)

String matching - Lower vs Casefold  (proto)


### Identifiers, Security


### Locale

CLDR Common Locale Data Repository


### BIDI


### Regular expressions


### Terminal / console / cmd
