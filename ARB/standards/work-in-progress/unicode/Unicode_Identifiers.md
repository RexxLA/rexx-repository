# Unicode Identifiers

## ARB recommendations

TBD

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


### Python

[PEP-3131 Supporting Non-ASCII Identifiers][python_pep_3131]

Created: 01-May-2007

Python-Version: 3.0

#### Abstract

This PEP suggests to support non-ASCII letters (such as accented characters,
Cyrillic, Greek, Kanji, etc.) in Python identifiers.

#### Rationale

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

#### Specification of Language Changes

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

#### Implementation

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
