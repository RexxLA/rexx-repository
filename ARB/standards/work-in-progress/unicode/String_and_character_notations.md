# String and character notations

## ARB recommendations

(TBD)

## Draft Notes

(jmb)
If we could work modulo backward compatibility, I would suggest:

* "nnnn"U for Unicode points. This is Rexx-like, in the sense that "nnnn"B is binary and "nnnn"X is hexadecimal.
* Maybe "nnnn, nnnn, nnnn, nnnn"U for multiple unicode points, e. g. "52, 65, 6E, E9"U.
* "xxxx"T for explicit Text strings. I would say that "T" is better than "U" because "U" exposes the underlying implementation ("Unicode"), while "T", for "Text" is an abstract idea.
* "U" + "T" would only break two suffixes, and would be enough to add Unicode functionality, while the default strings would still be byte strings, i.e., Classic Rexx strings.
* If we have to have a Rexx version where the default strings are "T" strings, we need a new suffix for "old-style", byte, or Classic Rexx strings.
* Maybe "C" for such a suffix? We could say that "C" means "Classic".
* So, this would be: "xxxx"C is a byte string; "xxxx"T is a text string (probably composed of graphemes); "xxxx[, xxxx]*"U is a (sequence of) codepoints.
(/jmb)

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

(jmb)
c2x implies that "characters" have a "hexadecimal" representation. This is maybe saying too much, i.e., exposing too much about the underlying representation. I don't think c2x and x2c should be implemented for text strings.

* If we end up working with codepoints, we could provide a c2u function. It would return the codepoint number, i.e., an integer. u2c would be reversible, i.e., we should guarantee that u2c(c2u(c)) == c.
* If we end up working with grapheme clusters, c2u should return an array of codepoints (maybe by using a stem under Classic Rexx implementations).
(/jmb)
