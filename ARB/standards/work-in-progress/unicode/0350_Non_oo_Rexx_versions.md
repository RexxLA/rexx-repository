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

Let's see how the "library" approach could work in a non-oo interpreter, for example Regina Rexx. Unicode would be implemented as a separate library, but, as we will soon see, it would also require some
collaboration from the interpreter. 

* The library would offer a new, BIF. Let's call it UNICODE (this is not a name proposal), maybe with a shorthand of U. UNICODE(string) (and U(string)) would return a Unicode value (to be defined shortly). With a little help
from the interpreter, Static, parse-time analysis, would be able to determine if UNICODE (or U) calls were indeed to be resolved to the new BIF, so that calls with a literal argument could be treated as literal Unicode strings.

* The result from UNICODE (or U) would be the very same string received as an argument (or a copy of the string if the original had active references), but with an implementarion-defined, internal, flag that would indicate
that the string was, indeed an Unicode string.

* The encoding to use would be the same as the one used in the program file. An optional, second argument could make the encoding specific: UNICODE("string", "UTF-8").

* If any encoding errors were found, a new condition would be raised. An optional, third, boolean parameter could be specified to allow ignoring of encoding errors, e.g., UNICODE("string", "UTF-8", 0). The fact that there was or not
an encoding error would be stored as part of the string status, and would be accesible using a specialized BIF.

* The interpreter would provide a whole set of new BIFs for Unicode strings. They would work at the grapheme cluster level.

* Arithmetic operators would work as usual, with ASCII numbers. The result would always be a plain (i.e., non-unicode) string.

* Contatenation would follow a protocol similar to the one used by Executor, as indicated in *[String Contatenation](525_String_concatenation.md)*.

* Comparison is tricky. Depending on how we define it, it can incur in an implicit encoding or recoding, and probably in a (also implicit) normalization. It may well be that the best option would be to completely
disallow direct comparison of Unicode and non-Unicode strings, i.e., UNICODE("A") = "A" would produce a syntax error. Parse-time litteral strings would be normalized by default (unless the third parameter was 0).
The fact that a string was normalized would be stored as part of the string status. When two strings of different encodings had to be compared, a "neutral" encoding should be used (always the same). If a recoding
to the neutral encoding was even produced, it would be cached as part of the string status.

Examples (assuming a UTF-8 ambiance):

    a = "Síntesis"           -- A byte string. "53 C3 AD 6E 74 65 73 69 73"X
    u = U("Síntesis")        -- An Unicode String "U 53, ED, 6E, 74, 65, 73, 69, 73"X

xx

