# Unicode Identifiers

## ARB recommendations

(TBD)

## Unicode standard

### UAX #31: UNICODE IDENTIFIER AND PATTERN SYNTAX

[Link][unicode_tr31]

This annex describes specifications for recommended defaults for the use of Unicode
in the definitions of general-purpose identifiers, immutable identifiers, hashtag
identifiers, and in pattern-based syntax. It also supplies guidelines for use of
normalization with identifiers.

A common task facing an implementer of the Unicode Standard is the provision of
a parsing and/or lexing engine for identifiers, such as programming language
variables or domain names. There are also realms where identifiers need to be
defined with an extended set of characters to align better with what end users
expect, such as in hashtags.

To assist in the standard treatment of identifiers in Unicode character-based
parsers and lexical analyzers, a set of specifications is provided here as a
basis for parsing identifiers that contain Unicode characters.
These specifications include:

- Default Identifiers: a recommended default for the definition of identifiers.
- Immutable Identifiers: for environments that need a definition of identifiers
  that does not change across versions of Unicode.
- Hashtag Identifiers: for identifiers that need a broader set of characters,
  principally for hashtags.

Edge Cases for Folding:  
The upshot is that when it comes to identifiers, implementations should never use
the General_Category or Lowercase or Uppercase properties to test for casing conditions,
nor use toUppercase(), toLowercase(), or toTitlecase() to fold or test identifiers.
Instead, they should instead use Case_Folding or NFKC_CaseFold.


### UTR #36: UNICODE SECURITY CONSIDERATIONS

[Link][unicode_tr36]

Because Unicode contains such a large number of characters and incorporates the 
varied writing systems of the world, incorrect usage can expose programs or systems
to possible security attacks. This is especially important as more and more products
are internationalized. This document describes some of the security considerations
that programmers, system analysts, standards developers, and users should take into
account, and provides specific recommendations to reduce the risk of problems.

2.11.2 Recommendations for Programmers

A. When parsing numbers, detect digits of mixed scripts and unexpected scripts
   and alert the user.

B. When defining identifiers in programming languages, protocols, and other environments:
   1. Use the general security profile for identifiers from Section 3, Identifier
      Characters in UTS #39: Unicode Security Mechanisms [UTS39].  
      Note that the general security profile allows characters from Table 3,
      Candidate Characters for Inclusion in Identifiers in [UAX31], such as
      U+00B7 (·) MIDDLE DOT used in Catalan.

   2. For equivalence of identifiers, preprocess both strings by applying NFKC
      and case folding. Display all such identifiers to users in their processed
      form. (There may be two displays: one in the original and one in the processed
      form.) An example of this methodology is Nameprep [RFC3491]. Although Nameprep
      is currently limited to Unicode 3.2, the same methodology can be applied by
      implementations that need to support more up-to-date versions of Unicode.

3 Non-Visual Security Issues

There are a number of exploits based on misuse of character encodings.
Some of these are fairly well-known, such as buffer overflows in conversion,
while others are not. Many are involved in the common practice of having a
'gatekeeper' for a system. That gatekeeper checks incoming data to ensure that
it is safe, and passes only safe data through. Once in the system, the other
components assume that the data is safe. A problem arises when a component treats
two pieces of text as identical—typically by canonicalizing them to the same
form—but the gatekeeper only detected that one of them was unsafe.

For example, suppose that strings containing the letters "delete" are sensitive
internally, and that therefore a gatekeeper checks for them. If some process
casefolds "DELETE" after the gatekeeper has checked, then the sensitive string
can sneak through. While many programmers are aware of this, they may not be aware
that the same thing can happen with other transformations, such as an NFKC
transformation of "Ⓓⓔⓛⓔⓣⓔ" into "delete".


### UTS #39: UNICODE SECURITY MECHANISMS

[Link][unicode_tr39]

Because Unicode contains such a large number of characters and incorporates the
varied writing systems of the world, incorrect usage can expose programs or systems
to possible security attacks. This document specifies mechanisms that can be used
to detect possible security problems.

Identifiers ("IDs") are strings used in application contexts to refer to specific
entities of certain significance in the given application. In a given application,
an identifier will map to at most one specific entity. Many applications have
security requirements related to identifiers. A common example is URLs referring
to pages or other resources on the Internet: when a user wishes to access a resource,
it is important that the user can be certain what resource they are interacting with.
For example, they need to know that they are interacting with a particular financial
service and not some other entity that is spoofing the intended service for malicious
purposes. This illustrates a general security concern for identifiers: potential
ambiguity of strings. While a machine has no difficulty distinguishing between any
two different character sequences, it could be very difficult for humans to recognize
and distinguish identifiers if an application did not limit which Unicode characters
could be in identifiers. The focus of this specification is mitigation of such issues
related to the security of identifiers.

Deliberately restricting the characters that can be used in identifiers is an important
security technique. The exclusion of characters from identifiers does not affect the
general use of those characters for other purposes, such as for general text in documents. 


## Examples of implementation by several languages

### cRexx

TBD: describe the rules implemented by cRexx.


### Elixir

[Link][elixir_unicode_syntax]

Strings are UTF-8 encoded.

Charlists are lists of Unicode code points. In such cases, the contents are kept
as written by developers, without any transformation.

Elixir allows Unicode characters in its variables, atoms, and calls.
From now on, we will refer to those terms as identifiers.

The characters allowed in identifiers are the ones specified by Unicode.

Elixir normalizes all characters to be the in the NFC form.

Mixed-script identifiers are not supported for security reasons.

    аdmin
     1 : ( "а"   U+0430 Ll 1 "CYRILLIC SMALL LETTER A" )
     2 : ( "d"   U+0064 Ll 1 "LATIN SMALL LETTER D" )
     3 : ( "m"   U+006D Ll 1 "LATIN SMALL LETTER M" )
     4 : ( "i"   U+0069 Ll 1 "LATIN SMALL LETTER I" )
     5 : ( "n"   U+006E Ll 1 "LATIN SMALL LETTER N" )

The character must either be all in Cyrillic or all in Latin.

The only mixed-scripts that Elixir allows, according to the Highly Restrictive
Unicode recommendations, are:
    Latin and Han with Bopomofo
    Latin and Japanese
    Latin and Korean

Elixir will also warn on confusable identifiers in the same file.

For example, Elixir will emit a warning if you use both variables а (Cyrillic)
and а (Latin) in your code.

Elixir implements the requirements outlined in the [Unicode Annex #31][unicode_tr31.]

- Elixir does not allow the use of ZWJ or ZWNJ in identifiers and therefore does
  not implement R1a.
- Bidirectional control characters are also not supported.
- R1b is guaranteed for backwards compatibility purposes.
- Elixir supports only code points \t (0009), \n (000A), \r (000D) and \s (0020)
  as whitespace and therefore does not follow requirement R3.
  R3 requires a wider variety of whitespace and syntax characters to be supported.


### Julia

#### [Variables in Julia](https://cormullion.github.io/assets/images/juliamono/juliamanual/manual/variables.html)

Variable names are case-sensitive.

Unicode names (in UTF-8 encoding) are allowed:

        julia> δ = 0.00001
        1.0e-5

        julia> 안녕하세요 = "Hello"
        "Hello"

Variable names must begin with a letter (A-Z or a-z), underscore, or a subset of
Unicode code points greater than 00A0; in particular, [Unicode character categories](https://www.fileformat.info/info/unicode/category/index.htm)
Lu/Ll/Lt/Lm/Lo/Nl (letters), Sc/So (currency and other symbols), and a few other
letter-like characters (e.g. a subset of the Sm math symbols) are allowed.
Subsequent characters may also include ! and digits (0-9 and other characters in
categories Nd/No), as well as other Unicode code points: diacritics and other
modifying marks (categories Mn/Mc/Me/Sk), some punctuation connectors (category Pc),
primes, and a few other characters.

Operators like + are also valid identifiers, but are parsed specially. In some contexts,
operators can be used just like variables; for example (+) refers to the addition
function, and (+) = f will reassign it. Most of the Unicode infix operators (in
category Sm), such as ⊕, are parsed as infix operators and are available for
user-defined methods (e.g. you can use const ⊗ = kron to define ⊗ as an infix
Kronecker product). Operators can also be suffixed with modifying marks, primes,
and sub/superscripts, e.g. +̂ₐ″ is parsed as an infix operator with the same
precedence as +.

Julia identifiers are NFC-normalized.  
jlf: really? that's in contradiction with Unicode recommendations.

#### (jlf) Are Julia identifiers canonicalized to NFC or to NFKC?

[https://github.com/JuliaLang/julia/issues/5434](https://github.com/JuliaLang/julia/issues/5434)
is a long mailing list from year 2014 about Unicode identifiers in Julia.

Some quotes:

[Jeff Bezanson](https://github.com/JuliaLang/julia/issues/5434#issuecomment-32715371)  
Many in the lisp/scheme world argue for case-insensitive identifiers because to
them letter case is just a personal style choice, with the same character underneath.
For example some people like to name functions in all-uppercase where they are
defined and otherwise use lowercase. However, those people are wrong.

[jiahao](https://github.com/JuliaLang/julia/issues/5434#issuecomment-32773731)  
The majority opinion (or maybe just mine) is that neither NFC nor NKFC is entirely
suitable. The former will not normalize Greek mu μ and micro µ, while the latter
would normalize ℍ and H, and χ² and χ2.

At this point, I would suggest NFD/NFC by default_, because I'm pretty sure we
don't want to mess with combining diacritics regardless, and print warnings if
NKFD-equivalent identifiers exist in scope. (_D may be sufficient since we don't
necessarily need to recompose the Unicode string for an identifier name, although
introspection would be less pretty)

[Stefan Karpinski](https://github.com/JuliaLang/julia/issues/5434#issuecomment-32779438)  
A good first-order approximation of my proposal is:

1. NFC/D normalize source code silently.
2. Warn if two NFKC/D-equivalent identifiers appear in the same file.

There may be additional character equivalences that should trigger warnings, but
we can add those as they come up.

[stevengj](https://github.com/JuliaLang/julia/issues/5434#issuecomment-35852577)  
It might be useful to read through the Python discussions on why they chose NFKC,
and explicitly discussed and rejected the possibility of flagging compatible
characters as an error. It seems that for users of several non-English languages,
it is actually quite difficult in practice to avoid cases of the "same" identifier
in NFC-inequivalent forms, e.g. [in Japanese](https://mail.python.org/pipermail/python-3000/2007-June/008220.html) 
or [in Korean](https://mail.python.org/pipermail/python-3000/2007-June/008227.html)
or [in Serbian and Croatian](https://mail.python.org/pipermail/python-3000/2007-June/008316.html),
and supporting users in these languages was a strong motivating factor in their
decision (see the conclusion of the linked thread). The example of the punctuation
characters from [#5903](https://github.com/JuliaLang/julia/issues/5903) is yet
another one of these unintentional inequivalencies for non-English users. (In
these cases, giving an error as @StefanKarpinski suggests, or even just a warning,
would be a huge headache: one of the linked authors wrote, "as a daily user of
several Japanese input methods, I can tell you it would be a massive pain in the
ass if Python doesn't convert those, and errors would be an on-the-minute-every-minute
annoyance.")

I really think that using NFKC has far more advantages (avoiding extreme confusion
in the many many cases where NFC-inequivalent identifiers are typically read as
equivalent by mundanes) than disadvantages (treating e.g. H and ℍ as the same identifier).

[Stefan Karpinski](https://github.com/JuliaLang/julia/issues/5434#issuecomment-36690894)  
This is why I've been arguing for an error. Our general philosophy is that if
there's no obvious one right interpretation of something, raise an error. NFC is
fine-grained enough that we can be sure that NFC-equivalent identifiers are meant
to be the same. NFKC is coarse-grained enough that we can be sure that NFKC-distinct
identifiers are clearly meant to be different. Everything between is no man's land.
So we should throw an error. Otherwise, we are implicitly guessing what the user
really meant. Not canonicalizing to NFKC is guessing that distinct identifiers are
actually meant to be different. Canonicalizing to NFKC is guessing that distinct
but NFKC-equivalent identifiers are meant to be the same. Either strategy will
inevitably be wrong some of the time.

[nalimilan](https://github.com/JuliaLang/julia/issues/5434#issuecomment-36720711)
I agree with @StefanKarpinski: there's not much to win by silently normalizing
identifiers using NFKC. If we report an error/warning, people will notice the
problem early and avoid much trouble. Julia IDEs will be made smart enough to
detect cases where two identifiers are equal after NFKC normalization, and will
suggest you to adapt automatically when typing them. OTC if the parser does the
normalization, you will never be able to trust grep to find an identifier because
of the many possible variants.

jlf: so it seems they decided to not use NFKC... They worry about mathematical
characters that become normalized. I understand they prefer to keep ALL the
possible mathematical characters, which makes sense for a scientific programming
language.

@jmb You are mathematician, do you think it would be a problem if Rexx applies
the NFKC transformation?


### Code review

[jl_is_identifier](https://github.com/JuliaLang/julia/blob/879f6d482420e181f17af60d361b601cbcc204f9/src/rtutils.c#L567C1-L582C1)

[jl_id_start_char](https://github.com/JuliaLang/julia/blob/879f6d482420e181f17af60d361b601cbcc204f9/src/flisp/julia_extensions.c#L127C1-L134C2)

[jl_id_char](https://github.com/JuliaLang/julia/blob/879f6d482420e181f17af60d361b601cbcc204f9/src/flisp/julia_extensions.c#L136C1-L153C2)

jlf: Can't find where NFC is applied for identifiers.
To continue...

(/jlf)



### NetRexx

TBD: describe the rules implemented by NetRexx.


### Python

#### [Lexical analysis](https://docs.python.org/3/reference/lexical_analysis.html#identifiers)

All identifiers are converted into the normal form NFKC while parsing;
comparison of identifiers is based on NFKC.

#### [PEP-3131 Supporting Non-ASCII Identifiers][python_pep_3131]

Created: 01-May-2007

Python-Version: 3.0

##### Abstract

This PEP suggests to support non-ASCII letters (such as accented characters,
Cyrillic, Greek, Kanji, etc.) in Python identifiers.

##### Rationale

Python code is written by many people in the world who are not familiar with the
English language, or even well-acquainted with the Latin writing system. Such 
developers often desire to define classes and functions with names in their
native languages, rather than having to come up with an (often incorrect) English
translation of the concept they want to name. By using identifiers in their native
language, code clarity and maintainability of the code among speakers of that
language improves.

For some languages, common transliteration systems exist (in particular, for the
Latin-based writing systems). For other languages, users have larger difficulties 
to use Latin to write their native words.

##### Specification of Language Changes

The syntax of identifiers in Python will be based on the Unicode standard annex 
[UAX-31][unicode_tr31], with elaboration and changes as defined below.

Within the ASCII range (U+0001..U+007F), the valid characters for identifiers are
the same as in Python 2.5. This specification only introduces additional characters
from outside the ASCII range. 

The identifier syntax is `<XID_Start> <XID_Continue>*`.

ID_Start is defined as all characters having one of the general categories 

    - uppercase letters (Lu), 
    - lowercase letters (Ll), 
    - titlecase letters (Lt), 
    - modifier letters (Lm), 
    - other letters (Lo), 
    - letter numbers (Nl), 
    - the underscore, 
    - and characters carrying the Other_ID_Start property.

XID_Start then closes this set under normalization, by removing all characters 
whose NFKC normalization is not of the form ID_Start ID_Continue* anymore.

ID_Continue is defined as all characters in 

    - ID_Start, plus
    - nonspacing marks (Mn),
    - spacing combining marks (Mc),
    - decimal number (Nd),
    - connector punctuations (Pc),
    - and characters carrying the Other_ID_Continue property.

Again, XID_Continue closes this set under NFKC-normalization; it also adds U+00B7
to support Catalan.

All identifiers are converted into the normal form NFKC while parsing; comparison
of identifiers is based on NFKC.

##### Implementation

The following changes will need to be made to the parser:

1. If a non-ASCII character is found in the UTF-8 representation of the source code,
   a forward scan is made to find the first ASCII non-identifier character (e.g.
   a space or punctuation character)
2. The entire UTF-8 string is passed to a function to normalize the string to NFKC,
   and then verify that it follows the identifier syntax. No such callout is made
   for pure-ASCII identifiers, which continue to be parsed the way they are today.
   The Unicode database must start including the Other_ID_{Start|Continue} property.
3. If this specification is implemented for 2.x, reflective libraries (such as pydoc)
   must be verified to continue to work when Unicode strings appear in __dict__ slots
   as keys.

### Rust

[RFC 2457-non_ascii_idents][rust_rfcs_2457]

Excerpts:

* To disallow any Unicode identifiers in a project (for example to ease collaboration or for security reasons) limiting the accepted identifiers to ASCII add this lint to the lib.rs or main.rs file of your project: #![forbid(non_ascii_idents)] (It would be interesting to implement a similar mechanism - jmb).
* Rust lexers normalize identifiers to NFC.

[Github pull request][rust_lang_pull_2457]

Allow non-ASCII letters (such as accented characters, Cyrillic, Greek, Kanji, etc.) in Rust identifiers.

A not so good user experience ([https://github.com/rust-lang/rfcs/pull/2457#issuecomment-394204986][rust_user_experience])

### Swift

[Swift Lexical Structure][swift_grammar_lexical_structure]  
The formal definitions of identifiers and operators are each a screen full of 
Unicode scalar references and demonstrate clear and deliberate support for 
advanced Unicode concepts like combining characters.

(Historic: Oct 19, 2016) [Refining Identifier and Operator Symbology][rust_refining_identifier]  
Probably worth to read... Still status "Awaiting review" (abandonned draft?) but a lot of pointers.

(Mar 2019) [String Comparison for Identifiers][swift_forum_string_comparison_for_identifiers]

(Mar 2019) [Pitch: Unicode Equivalence for Swift Source][swift_forum_unicode_equivalence_for_swift_source]


## Other

Maybe to study to understand the vulnerabilities in source code ([https://trojansource.codes/][trojan_source_codes])



[elixir_unicode_syntax]: https://hexdocs.pm/elixir/unicode-syntax.html
[python_pep_3131]: https://peps.python.org/pep-3131/
[rust_lang_pull_2457]: https://github.com/rust-lang/rfcs/pull/2457
[rust_refining_identifier]: https://github.com/jtbandes/swift-evolution/blob/unicode-id-op/proposals/NNNN-refining-identifier-and-operator-symbology.md
[rust_rfcs_2457]: https://rust-lang.github.io/rfcs/2457-non-ascii-idents.html
[rust_user_experience]: https://github.com/rust-lang/rfcs/pull/2457#issuecomment-394204986
[swift_forum_string_comparison_for_identifiers]: https://forums.swift.org/t/string-comparison-for-identifiers/21558
[swift_forum_unicode_equivalence_for_swift_source]: https://forums.swift.org/t/pitch-unicode-equivalence-for-swift-source/21576
[swift_grammar_lexical_structure]: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/lexicalstructure/
[trojan_source_codes]: https://trojansource.codes/
[unicode_tr31]:https://www.unicode.org/reports/tr31/
[unicode_tr36]: https://unicode.org/reports/tr36/
[unicode_tr39]: http://www.unicode.org/reports/tr39/
