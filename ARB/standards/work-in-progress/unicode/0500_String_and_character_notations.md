# String and character notations

## ARB recommendations

(TBD)

## Draft Notes

(jmb)

If we could work modulo backward compatibility, I would suggest:

* `"nnnn"U` for Unicode codepoints. This is Rexx-like, in the sense that `"nnnn"B` is binary and `"nnnn"X` is hexadecimal.
* We should probably also allow for `"nnnn, nnnn, nnnn, nnnn"U` to indicate a sequence of codepoints, e. g. `"52, 65, 6E, E9"U == "René"`.
* `"xxxx"T` for explicit Text strings. I would say that "T" is better than "U" because "U" exposes the underlying implementation ("Unicode"), while "T", for "Text", represents an abstract idea.
* "U" + "T" would only break two suffixes, and would be enough to add Unicode functionality, while the default strings would still be byte strings, i.e., Classic Rexx strings.
* If we have to have a Rexx version where the default strings are "T" strings, we need a new suffix for "old-style", byte, or Classic Rexx strings.
* Maybe "C" for such a suffix? We could say that "C" means "Classic", or "Compatibility".
* So, this would be: `"xxxx"C` is a byte string; `"xxxx"T` is a text string (probably composed of graphemes); `"xxxx[, xxxx]*"U` is a (sequence of) codepoints.
* For "compatibility", or old-style programs, `"xxxx" == "xxxx"C`. For new programs, `"xxxx" == "xxxx"T`. Explicit use of the "C" and "T" suffixes should always be allowed.

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

(jmb -- Updated 20230702)

Assuming that c2x makes sense implies that a choice has been made, namely, to store the string in a certain (internal) representation.

If no representation can be implied, c2x makes no sense.

Therefore, it's risky to stipulate that c2x has to be offered as a BIF, since it constrains the implementors, i.e., it implicitly mandates a particular form of implementation.

The inherent property of a Unicode string is that it is composed of _codepoints_, and nothing more. Codepoints are integers (although they often expressed in hexadecimal notation).

A BIF should exist that returns the codepoint array associated with a grapheme cluster.

The C2X BIF can only be applied to _byte_ strings, e.g., to _decodings_ of a Unicode string.

A Unicode string does not have to have an encoding. It may have one, or it may not. Stipulating that it _must_ have one is, again, saying too much about the implementation. An implementor should be free to store the original encoding, or to throw it away.

(/jmb)

## How other languages are supporting escape characters for Unicode:

    \N{Unicode name}    Character name in the Unicode database (Python, Julia)
    \u{nnnn ...}        Unicode character(s), where each nnnn is 1-6 hexadecimal digits (Ruby)
    \u{X..X}            Unicode character denoted by a 1–8 hex digits (Swift)
    \u{XXXXXX}          hexadecimal Unicode code point UTF-8 encoded (1 or more digits) (zig)
    \uXXXX              Unicode character denoted by 4 hex digits (Go, Java, JSON, Julia, Netrexx, Python, Ruby)
    \UXXXXXXXX          Unicode character denoted by 8 hex digits (Go, Julia, Python)
    \xXX                1 byte denoted by 2 hex digits (Go, Netrexx, Python, Ruby)
    \XXX                Unicode character denoted by 3 octal digits (Go)
