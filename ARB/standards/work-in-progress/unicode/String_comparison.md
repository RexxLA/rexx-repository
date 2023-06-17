# Unicode Draft Notes

## String comparison

Normalization, equivalence  (proto)

String comparison (proto): strict, not strict

String matching - Lower vs Casefold  (proto)

Josep Maria : strict comparison should probably use NFC, and not strict maybe NFKC. Codepoint-based comparison (which would be stricter that strict comparison) would always be obtainable via APIs, if really needed. Comparison should never be based on internal representation. Internal representation should either be completely hidden to the user, or only obtainable via API calls. The following quote is extracted from [UAX #15 Unicode Normalization Forms](https://unicode.org/reports/tr15/#Norm_Forms), section 1.2:

>The _W3C Character Model for the World Wide Web 1.0: Normalization_ [[CharNorm]](https://unicode.org/reports/tr41/tr41-30.html#CharNorm) and other W3C Specifications (such as XML 1.0 5th Edition) recommend using Normalization Form C for all content, because this form avoids potential interoperability problems arising from the use of canonically equivalent, yet different, character sequences in document formats on the Web. See the _W3C Character Model for the Word Wide Web: String Matching and Searching_ [[CharMatch]](https://unicode.org/reports/tr41/tr41-30.html#CharMatch) for more background.

Shmuel : codepoints are important for some scenarios.

René : we can offer methods in addition to operators.
