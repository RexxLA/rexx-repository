# New built-in functions

The Rexx Preprocessor for Unicode implements a series of _new_ built-in functions (BIFs). Follow [this link](built-in.md) if you want to read about modifications to _existing_ BIFs.

## BYTES

```
   ╭────────╮  ┌────────┐  ╭───╮
▸▸─┤ BYTES( ├──┤ string ├──┤ ) ├─▸◂
   ╰────────╯  └────────┘  ╰───╯
```

Returns the _string_ converted to the BYTES format.  BYTES strings are composed of 8-bit bytes, and every character in the string can be an arbitrary 8-bit value, including binary data. 
Rexx built-in-functions operate at the byte level, and no Unicode features are available (for example, LOWER operates only on the ranges ``"A".."Z"`` and ``"a".."z"``).
This is equivalent to Classic Rexx strings, but with some enhancements. See the description of the BYTES class for details.

## CODEPOINTS

```
   ╭─────────────╮  ┌────────┐  ╭───╮
▸▸─┤ CODEPOINTS( ├──┤ string ├──┤ ) ├─▸◂
   ╰─────────────╯  └────────┘  ╰───╯
```

Converts _string_ to a CODEPOINTS string and returns it. CODEPOINTS strings are composed of Unicode codepoints, and every character in the string can be an arbitrary Unicode codepoint. 
The argument _string_ has to contain well-formed UTF-8, or a Syntax error will be raised. When working with CODEPOINTS strings, Rexx built-in functions operate at the codepoint level, 
and can produce much richer results than when operating on BYTES strings.

Please note that CODEPOINTS and TEXT strings are guaranteed to contain well-formed UTF-8 sequences. To test if a string contains well-formed UTF-8, you can use the ``DECODE(string,"UTF-8")`` function call.

## C2U (Character to Unicode)

```
   ╭──────╮  ┌────────┐                      ╭───╮
▸▸─┤ C2U( ├──┤ string ├─┬──────────────────┬─┤ ) ├─▸◂
   ╰──────╯  └────────┘ │ ╭───╮ ┌────────┐ │ ╰───╯
                        └─┤ , ├─┤ format ├─┘
                          ╰───╯ └────────┘
```

Returns a string, in character format, that represents _string_ converted to Unicode codepoints.

By default, C2U returns a list of blank-separated hexadecimal representations of the codepoints. The _format_ argument allows to select different formats for the returned string:

* When _format_ is the null string or __CODES__ (the default), C2U returns a list of blank-separated hexadecimal codepoints.
  Codepoints larger than ``"FFFF"X`` will have their leading zeros removed, if any. Codepoints smaller than ``"10000"X`` will always have four digits (by adding zeros to the left if necessary).
* When _format_ is __U+__, a list of hexadecimal codepoints is returned. Each codepoint is prefixed with the characters ``"U+"``.
* When _format_ is __NAMES__, each codepoint is substituted by its corresponding name or label, between parentheses.
  For example, ``C2U("S") == "(LATIN CAPITAL LETTER S)"``, and ``C2U("0A"X) = "(<control-000A>)"``.
* When _format_ is __UTF-32__, a UTF-32 representation of _string_ is returned.

__Examples__ (assuming an ambient encoding of UTF-8):

```
 C2U("Sí")       = "0053 00ED"       -- And "0053 00ED"U == "53 C3AD"X == "Sí".
 C2U("Sí","U+")  = "U+0053 U+00ED"   -- Again, "U+0053 U+00ED"U == "53 C3AD"X == "Sí".
 C2U("Sí","Na")  = "(LATIN CAPITAL LETTER S) (LATIN SMALL LETTER I WITH ACUTE)"
                                     -- And "(LATIN CAPITAL LETTER S) (LATIN SMALL LETTER I WITH ACUTE)"U == "Sí"
 C2U("Sí","UTF-32") = "0000 0053 0000 00ED"X
```

## DECODE

```
   ╭─────────╮  ┌────────┐  ╭───╮  ┌──────────┐  ╭───╮                                             ╭───╮
▸▸─┤ DECODE( ├──┤ string ├──┤ , ├──┤ encoding ├──┤ , ├─┬────────────┬─┬──────────────────────────┬─┤ ) ├─▸◂
   ╰─────────╯  └────────┘  ╰───╯  └──────────┘  ╰───╯ │ ┌────────┐ │ │ ╭───╮ ┌────────────────┐ │ ╰───╯
                                                       └─┤ format ├─┘ └─┤ , ├─┤ error_handling ├─┘
                                                         └────────┘     ╰───╯ └────────────────┘
```

Tests whether a _string_ is encoded according to a certain _encoding_, and optionally decodes it to a certain _format_.

DECODE works as an _encoding_ validator when _format_ is omitted, and as a decoder when _format_ is specified. It is an error to omit _format_ and to specify a value for _error_handling_ at the same time (that is, if _format_ was omitted, then _error_handling_ should be omitted too).

When DECODE is used as validator, it returns a boolean value, indicating if the string is well-formed according to the specified encoding.
For example, ``DECODE(string,"UTF-8")`` returns __1__ when string contains well-formed UTF-8, and __0__ if it contains ill-formed UTF-8.

To use DECODE as a decoder, you have to specify a _format_. This argument accepts a blank-separated set of tokens.
Each token can have one of the following values: __UTF8__, __UTF-8__, __UTF32__, or __UTF-32__ (duplicates are allowed and ignored).
When __UTF8__ or __UTF-8__ have been specified, a UTF-8 representation of the decoded _string_ is returned.
When __UTF32__ or __UTF-32__ have been specified, UTF-32 representation of the decoded _string_ is returned.
When both have been specified, an two-items array is returned. The first item of the array is the UTF-8 representation of the decoded _string_,
and the second item of the array contains the UTF-32 representation of the decoded _string_.

The optional _error_handling_ argument determines the behaviour of the function when the _format_ argument has been specified.
If it has the value __""__ (the default) or __NULL__, a null string is returned when there a decoding error is encountered.
If it has the value __REPLACE__, any ill-formed character will be replaced by the Unicode Replacement Character (``U+FFFD``).
If it has the value __SYNTAX___, a Syntax condition will be raised when a decoding error is encountered.

__Examples:__

```
DECODE(string, "UTF-16")                           -- Returns 1 if string contains proper UTF-8, and 0 otherwise
var = DECODE(string, "UTF-16", "UTF-8")            -- Decodes string to the UTF-8 format. A null string is returned if string contains ill-formed UTF-16.
DECODE(string, "UTF-16",,"SYNTAX")                 -- The fourth argument is checked for validity and then ignored.
DECODE(string, "UTF-16",,"POTATO")                 -- Syntax error (Invalid option 'POTATO').
var = DECODE(string, "UTF-16", "UTF-8", "REPLACE") -- Decodes string to the UTF-8 format. Ill-formed character sequences are replaced by U+FFFD.
var = DECODE(string, "UTF-16", "UTF-8", "SYNTAX")  -- Decodes string to the UTF-8 format. Any ill-formed character sequence will raise a Syntax error.
```

## ENCODE

```
   ╭─────────╮  ┌────────┐  ╭───╮  ┌──────────┐                               ╭───╮
▸▸─┤ ENCODE( ├──┤ string ├──┤ , ├──┤ encoding ├──┬──────────────────────────┬─┤ ) ├─▸◂
   ╰─────────╯  └────────┘  ╰───╯  └──────────┘  │ ╭───╮ ┌────────────────┐ │ ╰───╯
                                                 └─┤ , ├─┤ error_handling ├─┘
                                                   ╰───╯ └────────────────┘
```

ENCODE first validates that _string_ contains well-formed UTF-8. Once the _string_ is validated, encoding is attempted using the specified _encoding_. ENCODE returns the encoded string,
  or a null string if validation or encoding failed. You can influence the behaviour of the function when an error is encountered by specifying the optional _error_handling_ argument.
* When _error_handling_ is not specified, is __""__ or is __NULL__ (the default), a null string is returned if an error is encountered.
* When _error_handling_ has the value __SYNTAX__, a Syntax error is raised if an error is encountered.

__Examples:__

```
ENCODE(string, "IBM1047")                          -- The encoded string, or "" if string can not be encoded to IBM1047.
ENCODE(string, "IBM1047","SYNTAX")                 -- The encoded string. If the encoding fails, a Syntax error is raised.
```

## N2P (Name to codePoint)

```
   ╭──────╮  ┌──────┐  ╭───╮
▸▸─┤ N2P( ├──┤ name ├──┤ ) ├─▸◂
   ╰──────╯  └──────┘  ╰───╯
```

Returns the hexadecimal Unicode codepoint corresponding to _name_, or the null string if _name_ does not correspond to a Unicode codepoint.

``N2P`` accepts _names_, as defined in the second column of ``UnicodeData.txt`` (that is, the Unicode "Name" \["Na"\] property), like ``"LATIN CAPITAL LETTER F"`` or ``"BELL"``;
aliases, as defined in ``NameAliases.txt``, like ``"LF"`` or ``"FORM FEED"``, and labels identifying codepoints that have no names, like ``"<Control-0001>"`` or ``"<Private Use-E000>"``.

When specifying a _name_, case is ignored, as are certain characters: spaces, medial dashes (except for the ``"HANGUL JUNGSEONG O-E"`` codepoint) and underscores that replace dashes.
Hence, ``"BELL"``, ``"bell"`` and ``"Bell"`` are all equivalent, as are ``"LATIN CAPITAL LETTER F"``, ``"Latin capital letter F"`` and ``"latin_capital_letter_f"``.

Returned codepoints will be _normalized_, i.e., they will have a minimum length of four digits, and they will never start with a zero if they have more than four digits.

__Examples:__

```
N2P("LATIN CAPITAL LETTER F") =  "0046"       -- Padded to four digits
N2P("BELL")                   = "1F514"       -- Not "01F514"
N2P("Potato")                 = "1F954"       -- Unicode has "Potato" (a vegetable emoticon)..
N2P("Potatoes")               = ""            -- ..but no "Potatoes".
```

## P2N (codePoint to Name)

```
   ╭──────╮  ┌───────────┐  ╭───╮
▸▸─┤ P2N( ├──┤ codepoint ├──┤ ) ├─▸◂
   ╰──────╯  └───────────┘  ╰───╯
```

Returns the name or label corresponding to the hexadecimal Unicode _codepoint_ argument, or the null string if the codepoint has no name or label.

The argument _codepoint_ is first _verified_ for validity. If it is not a valid hexadecimal number or it is out-of-range, a null string is returned.
If the _codepoint_ is found to be valid, it is then _normalized_: if it has less than four digits, zeros are added to the left,
until the _codepoint_ has exactly four digits; and if the _codepoint_ has more than four digits, leading zeros are removed, until no more zeros are found or the _codepoint_ has exactly four characters.

Once the _codepoint_ has been validated and normalized, it is uppercased, and the Unicode Character Database is then searched for the "Name" ("Na") property.

If the _codepoint_ has a name, that name is returned.
If the _codepoint_ does not have a name but it has a label, like ``"<control-0010>"``, then that label is returned. In all other cases, the null string is returned.

__Note__. Labels are always enclosed between ``"<"`` and ``">"`` signs. This allows to quickly distinguish them from names.

__Examples:__

```
P2N("46")      =  "LATIN CAPITAL LETTER F"    -- Normalized to "0046"
P2N("0046")    =  "LATIN CAPITAL LETTER F"    -- Normalized to "0046"
P2N("0000046") =  "LATIN CAPITAL LETTER F"    -- Normalized to "0046"
P2N("1F342")   =  "FALLEN LEAF"               -- An emoji
P2N("0012")    =  "<control-0012>"            -- A label, not a name
P2N("XXX")     =  ""                          -- Invalid codepoint
P2N("110000")  =  ""                          -- Out-of-range
```

## STRINGTYPE

```
   ╭─────────────╮  ┌────────┐                    ╭───╮
▸▸─┤ STRINGTYPE( ├──┤ string ├─┬────────────────┬─┤ ) ├─▸◂
   ╰─────────────╯  └────────┘ │ ╭───╮ ┌──────┐ │ ╰───╯
                               └─┤ , ├─┤ type ├─┘
                                 ╰───╯ └──────┘
```

If you specify only _string_, it returns __TEXT__ when _string_ is a TEXT string,
__CODEPOINTS__ when _string_ is a CODEPOINTS string, and __BYTES__ when _string_ is a BYTES string. If you specify _type_, it returns __1__ when
_string_ matches the _type_. Otherwise, it returns __0__. The following are valid types: 

* __BYTES__. Returns __1__ if the string is a BYTES string.
* __CODEPOINTS__. Returns __1__ if the string is a CODEPOINTS string.
* __TEXT__. Returns __1__ if the string is a TEXT string.

## TEXT

```
   ╭───────╮  ┌────────┐  ╭───╮
▸▸─┤ TEXT( ├──┤ string ├──┤ ) ├─▸◂
   ╰───────╯  └────────┘  ╰───╯
```

Converts _string_ to a TEXT string and returns it. TEXT strings are composed of extended grapheme clusters, and every character in a TEXT string can be an arbitrary extended grapheme cluster. 
The argument _string_ has to contain well-formed UTF-8, or a Syntax error is raised. When working with TEXT strings, Rexx built-in functions operate at the extended grapheme cluster level, and can produce much richer results than when operating with BYTES or CODEPOINTS strings.

Please note that CODEPOINTS and TEXT strings are guaranteed to contain well-formed UTF-8 sequences. To test if a string contains well-formed UTF-8, you can use the ``DECODE(string,"UTF-8")`` function call.

## UTF8

```
   ╭───────╮  ┌────────┐  ╭───╮                                             ╭───╮
▸▸─┤ UTF8( ├──┤ string ├──┤ , ├─┬────────────┬─┬──────────────────────────┬─┤ ) ├─▸◂
   ╰───────╯  └────────┘  ╰───╯ │ ┌────────┐ │ │ ╭───╮ ┌────────────────┐ │ ╰───╯
                                └─┤ format ├─┘ └─┤ , ├─┤ error_handling ├─┘
                                  └────────┘     ╰───╯ └────────────────┘
```

Tests whether a _string_ contains well-formed UTF-8, and optionally decodes it to a certain _format_.

UTF8 works as a UTF-8 validator when _format_ is omitted, and as a decoder when _format_ is specified. It is an error to omit _format_ and to specify a value for _error_handling_ at the same time (that is, if _format_ was omitted, then _error_handling_ should be omitted too).

When UTF8 is used as validator, it returns a boolean value, indicating if the string contains well-formed UTF8.
For example, ``UTF8(string)`` returns __1__ when string contains well-formed UTF-8, and __0__ if it contains ill-formed UTF-8.

To use UTF8 as a decoder, you have to specify a _format_. This argument accepts a blank-separated set of tokens.
Each token can have one of the following values: __UTF8__, __UTF-8__, __UTF32__, or __UTF-32__ (duplicates are allowed and ignored).
When __UTF8__ or __UTF-8__ have been specified, a UTF-8 representation of _string_ is returned.
When __UTF32__ or __UTF-32__ have been specified, a UTF-32 representation of _string_ is returned.
When both have been specified, an two-items array is returned. The first item of the array is the UTF-8 representation of _string_,
and the second item of the array contains the UTF-32 representation of _string_.

The optional _error_handling_ argument determines the behaviour of the function when the _format_ argument has been specified.
If it has the value __""__ (the default) or __NULL__, a null string is returned when there a decoding error is encountered.
If it has the value __REPLACE__, any ill-formed character will be replaced by the Unicode Replacement Character (``U+FFFD``).
If it has the value __SYNTAX___, a Syntax condition will be raised when a decoding error is encountered.

__Conditions:__

* Syntax 93.900. Invalid option '<em>option</em>'.
* Syntax 93.900. Invalid format '<em>format</em>'.
* Syntax 23.900. Invalid UTF-8 sequence in position <em>n</em> of string: '<em>hex-value</em>'X.

__Examples:__

```
UTF8("ascii")                                     -- 1
UTF8("José")                                      -- 1
UTF8("FF"X)                                       -- 0
UTF8("José",UTF32)                                -- "0000004A 0000006F 00000073 0000E9"X ("é" is "E9"U)
UTF8("FF"X,UTF32)                                 -- ""
UTF8("FF"X,UTF32,REPLACE)                         -- "�" ("FFFD"X, the replacement character)
UTF8("FF"X,UTF32,SYNTAX)                          -- Raises a Syntax error
```

### Implementation notes

See [The Unicode® Standard. Version 15.0 – Core Specification](https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf), p. 125:

>#### Table 3-7. Well-Formed UTF-8 Byte Sequences
>
>| Code Points        | First Byte | Second Byte  | Third Byte | Fourth Byte |
>| ------------------ | -----------| ------------ | ---------- | ----------- |
>| U+0000..U+007F     | 00..7F     |              |            |             | 
>| U+0080..U+07FF     | C2..DF     | 80..BF       |            |             | 
>| U+0800..U+0FFF     | E0         | ***A0***..BF | 80..BF     |             | 
>| U+1000..U+CFFF     | E1..EC     | 80..BF       | 80..BF     |             | 
>| U+D000..U+D7FF     | ED         | 80..***9F*** | 80..BF     |             | 
>| U+E000..U+FFFF     | EE..EF     | 80..BF       | 80..BF     |             | 
>| U+10000..U+3FFFF   | F0         | ***90***..BF | 80..BF     | 80..BF      |
>| U+40000..U+FFFFF   | F1..F3     | 80..BF       | 80..BF     | 80..BF      |
>| U+100000..U+10FFFF | F4         | 80..***8F*** | 80..BF     | 80..BF      |
>
>_In Table 3-7, cases where a trailing byte range is not 80..BF are shown in bold italic to draw
>attention to them. These exceptions to the general pattern occur only in the second byte of a sequence_.

Based on this table, on the first run, UTF8 will build a Finite State Machine. States will be coded into two
TRANSLATE tables, stored in the .local directory.

* The range 00..7F is mapped to "A" (for "A"SCII).
* The range 80..BF is mapped to "C" (for "C"ontinuation characters). Some few bytes will require manual checking.
* The values CO, C1 and F5..FF are always illegal in a UTF-8 string. We add rows for these ranges, and we map the corresponding codes to "I" (for "I"llegal).
* The range C2..DF is mapped to "20"X (the "2" in "20" reminds us that we will find a 2-byte group, if the string is well-formed).
* The range E0..EF is mapped to the "3x"X values, "3a", "3b" and "3c". The "3" reminds us that we will find a 3-bytes groups, if the string is well-formed;
  the final "a", "b" and "c" allow us to differentiate the cases, and perform the corresponding tests.
* Similarly, the F0..F4 range is mapped to "4a"X, "4b"X and "4c"X, as described below.

#### Table 3-7 (modified)

| Bytes        | Mapping | Description |
|------------- | --------| ----------- |
| 00..7F       | "A"     | ASCII byte
| 80..BF       | "C"     | Continuation byte
| C0..C1       | "I"     | Illegal byte
| C2..DF       | "20"X   | Two-bytes sequence
| E0           | "3a"X   | Three bytes, case (a)
| E1..EC       | "3b"X   | Three bytes, case (b)
| ED           | "3c"X   | Three bytes, case (c)
| EE..EF       | "3b"X   | Three bytes, case (b)
| F0           | "4a"X   | Four bytes, case (a)
| F1..F3       | "4b"X   | Four bytes, case (b)
| F4           | "4c"X   | Four bytes, case (c)
| F5..FF       | "I"     | Illegal byte
 
## UTF8Z

```
   ╭────────╮  ┌────────┐  ╭───╮                                             ╭───╮
▸▸─┤ UTF8Z( ├──┤ string ├──┤ , ├─┬────────────┬─┬──────────────────────────┬─┤ ) ├─▸◂
   ╰────────╯  └────────┘  ╰───╯ │ ┌────────┐ │ │ ╭───╮ ┌────────────────┐ │ ╰───╯
                                 └─┤ format ├─┘ └─┤ , ├─┤ error_handling ├─┘
                                   └────────┘     ╰───╯ └────────────────┘
```

UTF8Z is a format identical to UTF-8, except that the ``"0000"U`` character is represented by the overlong encoding ``"C080"X`` instead of ``"00"X``. This guarantees that a well-formed UTF8Z string will never contain any null character (``"00"X``), and therefore UTF8Z-formatted strings can be processed using traditional null-terminated string functions. Please refer to the [modified UTF-8](https://en.wikipedia.org/wiki/UTF-8#Modified_UTF-8) section in the [Wikipedia page about UTF-8](https://en.wikipedia.org/wiki/UTF-8).

The UTF8Z BIF works in the same way that UTF8. Please refer to the documentation for UTF8 for additional details.

__Implementation notes:__

Table 3.7 will have to be adapted for UTF8Z in the following way:

#### Table 3-7 (modified for UTF8Z)

| Bytes        | Mapping | Description |
|------------- | --------| ----------- |
| 00           | "I"     | Illegal byte
| 00..7F       | "A"     | ASCII byte
| 80..BF       | "C"     | Continuation byte
| C0           | "0"     | "C080"X -> "0000"U, error otherwise
| C1           | "I"     | Illegal byte
| C2..DF       | "20"X   | Two-bytes sequence
| E0           | "3a"X   | Three bytes, case (a)
| E1..EC       | "3b"X   | Three bytes, case (b)
| ED           | "3c"X   | Three bytes, case (c)
| EE..EF       | "3b"X   | Three bytes, case (b)
| F0           | "4a"X   | Four bytes, case (a)
| F1..F3       | "4b"X   | Four bytes, case (b)
| F4           | "4c"X   | Four bytes, case (c)
| F5..FF       | "I"     | Illegal byte

## WTF8

```
   ╭───────╮  ┌────────┐  ╭───╮                                             ╭───╮
▸▸─┤ WTF8( ├──┤ string ├──┤ , ├─┬────────────┬─┬──────────────────────────┬─┤ ) ├─▸◂
   ╰───────╯  └────────┘  ╰───╯ │ ┌────────┐ │ │ ╭───╮ ┌────────────────┐ │ ╰───╯
                                └─┤ format ├─┘ └─┤ , ├─┤ error_handling ├─┘
                                  └────────┘     ╰───╯ └────────────────┘
```

WTF-8 is a format identical to UTF-8, except that it encodes surrogates that are not in a pair. Please refer to the [The WTF-8 encoding](https://simonsapin.github.io/wtf-8/#concatenating)) for details.

The WTF8 BIF works in the same way that UTF8. Please refer to the documentation for UTF8 for additional details.

__Implementation notes:__

Table 3.7 will have to be adapted for WTF-8 in the following way:

#### Table 3-7 (modified for WTF-8)

| Bytes        | Mapping | Description |
|------------- | --------| ----------- |
| 00           | "I"     | Illegal byte
| 00..7F       | "A"     | ASCII byte
| 80..BF       | "C"     | Continuation byte
| C0           | "0"     | "C080"X -> "0000"U, error otherwise
| C1           | "I"     | Illegal byte
| C2..DF       | "20"X   | Two-bytes sequence
| E0           | "3a"X   | Three bytes, case (a)
| E1..EC       | "3b"X   | Three bytes, case (b)
| ED           | "3d"X   | Three bytes, case (d): 2nd byte in 80..9F, normal char; in A0..AF, lead surrogate; in B0..BF, trail surrogate; surrogate pair: error
| EE..EF       | "3b"X   | Three bytes, case (b)
| F0           | "4a"X   | Four bytes, case (a)
| F1..F3       | "4b"X   | Four bytes, case (b)
| F4           | "4c"X   | Four bytes, case (c)
| F5..FF       | "I"     | Illegal byte
