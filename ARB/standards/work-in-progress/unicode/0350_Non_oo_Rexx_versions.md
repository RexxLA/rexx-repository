# Non object-oriented Rexx versions

## ARB recommendations

(TBD)

## Draft Notes

### Introduction

In most of our discussions, we are centered on object-oriented versions of Rexx, namely, on ooRexx, or on Jean-Louis Faucher's Executor. This is fine, but we shouldn't forget about the non-oo versions, like Regina, BRexx, etc. We should produce a
set of recommendations that are implementable in a non-oo version of Rexx, _and_ also in ooRexx and Executor.

As discussed in the *[Preliminary questions](0150_Preliminary_questions.md)* section, there are two radically different approaches to the Unicode problem. One we can call the "library" approach, and the other the "first-class Unicode" approach. 

In the "library" approach, a new, loadable, optional library would be written. This library would supply the user with a set of new functions (and, in the oo cases, of classes and methods) to manage Unicode values.

In the "first-class Unicode" approach, the Rexx language would experiment a profound, radical change. Strings would be, by default, Unicode strings. This would represent a big compatibility problem; some of the issuse are
addressed in the *[Backward Compatibility](0300_Backward_compatibility.md)* section. Old-style, byte-oriented strings would still be usable, probably by specifying a new, incompatible, string suffix. Interpreters should implement a compatibility mode, where
strings would still be byte-oriented by default, to make it possible to run old programs.

### The "library" approach (a brainstorm proposal) (jmb)

Let's see how the "library" approach could work in a non-oo interpreter, for example Regina Rexx. Unicode could be implemented as a separate library, but, as we will soon see, it would also require some
collaboration from the interpreter. 

* The library would offer a new, BIF. Let's call it UNICODE (this is not a name proposal). We will be using U for brevity (this might be an alias). U(string) would return a Unicode value (to be defined shortly). With a little help
from the interpreter, Static, parse-time analysis, would be able to determine if calls to UNICODE calls were indeed to be resolved to the new BIF, so that calls with a literal argument could be treated as literal Unicode strings.
To avoid trivial errors, U applied to a Unicode string would be the same string.

* The result from UNICODE would be the very same string received as an argument (or a copy of the string if the original had active references), but with an implementarion-defined, internal, flag that would indicate
that the string was, indeed, an Unicode string.

* The encoding to use would be the same as the one used in the program file. An optional, second argument could make the encoding explicit: UNICODE("string", "UTF-8").

* If any encoding errors were found, a new condition would be raised. An optional, third, boolean parameter could be specified to allow ignoring of encoding errors, e.g., UNICODE("string", "UTF-8", 0). The fact that there was or not
an encoding error would be stored as part of the string status, and would be accesible using a specialized BIF.

* The interpreter would provide a whole set of new BIFs for Unicode strings. They would work at the grapheme cluster level.

* Arithmetic operators would work as usual, with ASCII numbers, and the "e", "E", ".", "+" and "-" characters, regardless of whether they are part of an Unicode or a byte string. The result of an arithmetic operation would always be a plain (i.e., non-unicode) ASCII string.

* Concatenation would follow a protocol similar to the one used by Executor, as indicated in *[String Contatenation](525_String_concatenation.md)*.

* Comparison is tricky. Depending on how we define it, it can incur in an implicit encoding or recoding, and probably in a (also implicit) normalization. It may well be that the best option would be to completely
disallow direct comparison of Unicode and non-Unicode strings, i.e., UNICODE("A") = "A" would produce a syntax error. Parse-time literal strings would be normalized by default (unless the third parameter was 0).
The fact that a string was normalized would be stored as part of the string status. When two strings of different encodings had to be compared, a "neutral" encoding should be used (always the same). If a recoding
to the neutral encoding was even produced, it would be cached as part of the string status.

Examples (assuming a UTF-8 ambiance; BIF names are samples, not proposals):

    a = "Síntesis"                     -- A byte string. "53 C3 AD 6E 74 65 73 69 73"X
    u = U("Síntesis")                  -- An Unicode literal String "U 53, ED, 6E, 74, 65, 73, 69, 73"X
    U(a) == u                 
    U(a) == U(u)                       -- Since U is unicode
    IsUnicode(a)                       -- 0
    IsUnicode(u)                       -- 1
    SubStr(a,2,1)                      -- "C3"X, a 1-byte string.
    SubStr(u,2,1)                      -- "í" == "U ED"X, a one grapheme (and one codepoint) Unicode string.
    Encoding(u)                        -- "UTF-8", a byte string, the (implicit) encoding used.
    Encoding(a)                        -- ??? Probably a syntax error, or maybe "NONE", or even "UTF-8".
    12 + U("13")                       -- 25, a byte string.
    12 = U("12")                       -- Syntax error, force the user to specify what she's trying to do.
    rnon = U2C("U 52, 65, 6E, E9"X)    -- "René", NFC form
    rcomb = U2C("U 52, 65, 65, 301"X)  -- "René", NFD form
    IsNormalized(rnon)                 -- 1
    IsNormalized(rcomb)                -- 0: default would be NFC
    IsNormalized(rcomb, "NFD")         -- 1
    "Una" a                            -- "Una Síntesis", a byte string.
    "Una" u                            -- U("Una Síntesis"), an Unicode string. Implicit promotion of "Una" to Unicode
    rnon == rcomb                      -- 1 (internal normalization of rcomb, caching of this normalized value)
    rnon == rcomb                      -- 1 (using the cached normalization)
    Length(rnon)                       -- 4
    Length(rcomb)                      -- 4 (internal normalization to NFC, and caching of this normalized value).
    Decode(rnon)                       -- "Renè", a byte string
    Decode(rnon, "UTF-16")             -- "0052 0065 006E 00E9"X
    Length(Decode(rnon))               -- 4
    Length(Decode(rcomb))              -- 5
    
