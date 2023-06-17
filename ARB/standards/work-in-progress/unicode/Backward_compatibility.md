# Unicode Draft Notes

## Backwards compatibility

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

1. For classic Rexx, an almost zero-cost way to implement Unicode would be to (1) introduce new Unicode strings, ended with "u" or "U", i.e., "xxx"X would be an hexadecimal string, "xxxx"b would be a binary string (no departure so far), and "xxxx"U would be a Unicode string (new stuff). This would break programs where a literal string ("xxxx") was collated to a variable called "U", but no more (and maybe we should have an Option to disable such "U" strings and then ensure perfect backwards compatibility). (2) Codepoint literals could be written as a variation of the hexadecimal string format, for example "U+E9"X, or "Ue9"x, or somesuch. This would be syntactically different enough from "normal" hexadecimal strings, and would indicate it was a Unicode codepoint reference. (3) In the same way that 2+ "a" produces a syntax error, "hello" + "mom"U should produce a syntax error ("Can not collate Unicode and byte strings", for example). BIFs could be dual-pathed for Unicode strings and for classic strings without problems, and without interference between "classic" strings and Unicode Strings. (4) Of course there should exist a set of encode/decode BIFs to transform Unicode strings to "classic" strings and vice versa.

2. Object oriented versions of Rexx could well follow the Classic Rexx paradigm and extend over it (i.e., duplicating classic rexx BIFs as the corresponding class BIMs, etc).

(/Josep Maria)

<examples & study to start>
