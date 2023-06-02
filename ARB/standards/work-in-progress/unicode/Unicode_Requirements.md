# Unicode

After an era of 6,7 and 8 bit character sets the computing world finally put an end to problems with code pages and non-english character encoding, and adopted the Unicode standard. This means a character might not fit in 8 bits anymore. The first 256 code points in the Unicode standard are identical to the ISO8859-1 (Latin-1 ASCII) character set. EBCDIC, which is the default character representation for the mainframe implementations, is a character set with 256 values, but like the ASCII and extended ASCII sets, a number of different codepages for use with different national languages that need more than the Latin alphabet.

Most modern languages have chosen an internal Unicode representation and can use exchange formats like UTF-8 and UTF-16. Some Classic Rexx implementations can use multibyte character representation, like the z/VM an z/OS implementation wich can use Kana and Katakana in DBCS (Double Byte Character Sets). These require a number of options and caveats. 

NetRexx, being Java (or CLI), uses Java's internal character encoding, which is UTF-16. cRexx is being designed with Unicode in mind. Most other variants and implementations thereof tolerate some Unicode use by being *codepage agnostic*, which stops short of full Unicode support.

## Definitions
Unicode (https://www.unicode.org/) is a specification that aims to list every character used by human languages and give each character its own unique code. The Unicode specifications are continually revised and updated to add new languages and symbols.

A character is the smallest possible component of a text. ‘A’, ‘B’, ‘C’, etc., are all different characters. So are ‘È’ and ‘Í’. Characters vary depending on the language or context you’re talking about. For example, there’s a character for “Roman Numeral One”, ‘Ⅰ’, that’s separate from the uppercase letter ‘I’. They’ll usually look the same, but these are two different characters that have different meanings.

The Unicode standard describes how characters are represented by code points. A code point value is an integer in the range 0 to 0x10FFFF (about 1.1 million values, the actual number assigned is less than that). In the standard and in this document, a code point is written using the notation U+265E to mean the character with value 0x265e (9,822 in decimal).

### Encodings
a Unicode string is a sequence of code points, which are numbers from 0 through 0x10FFFF (1,114,111 decimal). This sequence of code points needs to be represented in memory as a set of code units, and code units are then mapped to 8-bit bytes. The rules for translating a Unicode string into a sequence of bytes are called a character encoding. UTF-8 is the encoding most computer languages and applications are converging upon.

### UTF-8
UTF-8 has several useful properties:

- It can handle any Unicode code point.
- A Unicode string is turned into a sequence of bytes that contains embedded zero bytes only where they represent the null character (U+0000). This means that UTF-8 strings can be processed by C functions such as strcpy() and sent through protocols that can’t handle zero bytes for anything other than end-of-string markers.
- A string of ASCII text is also valid UTF-8 text.
- UTF-8 is compact; the majority of commonly used characters can be represented with one or two bytes.
- If bytes are corrupted or lost, it’s possible to determine the start of the next UTF-8-encoded code point and resynchronize. It’s also unlikely that random 8-bit data will look like valid UTF-8.
- UTF-8 is a byte oriented encoding. The encoding specifies that each character is represented by a specific sequence of one or more bytes. This avoids the byte-ordering issues that can occur with integer and word oriented encodings, like UTF-16 and UTF-32, where the sequence of bytes varies depending on the hardware on which the string was encoded.

## Which elements of the language can be Unicode

The possibilities here are
- Comments
- Identifiers
- Character content (of variables and constants)
- String content (of variables and constants)

Languages (not Rexx) that have keywords mostly avoid having these keywords in Unicode. There should be an
explicit decision whether emoticons are supported or not for language symbols.

## What should be supported

## Which Unicode subsets are supported
In business applications Unicode support can be limited to subsets; European commercial banking seems to converge on MES-2. We should decide how Rexx supports subsets and subset testing.

### The default type
It should be decided what should be the default type: 8bit characters or Unicode code points. A bridging strategy is a possibility - seen the fact there is a .text type available for ooRexx. It seems there is a consensus for Unicode strings being the default string type towards the future.

### Combining characters
In Unicode it is possible to have characters that include accents, or to have a combination of a character and an accent to form an accented character. There should be a decision whether that combination forms a single character or it counts as two characters.

### Grapheme clusters
With a __grapheme_cluster__ two or more characters can be combined into one __grapheme__ (character with a length of 1). Rexx should support this mechanism, but its priority is lower than the other forms of Unicode support. In this we can probably follow the level of support in other languages.

### Surrogate pairs
Surrogates are code points from two special ranges of Unicode values, reserved for use as the leading, and trailing values of paired code units in UTF-16. Leading surrogates, also called high surrogates, are encoded from D80016 to DBFF16, and trailing surrogates, or low surrogates, from DC0016 to DFFF16. They are called surrogates, since they do not represent characters directly, but only as a pair.

## Non-printing characters
There should be a decision whether to count non-printing characters or not, and in which bifs. For example for __centre()__ it seems counterproductive to count the number of invisible characters.

## Validation of UTF-8 input
Implementations should be validated against malevolently constructed ‘UTF-8’ input. They can offer validation methods to the language user but should not assume responsibility for everything in user code. It might be an idea to standardize the names of the validation methods/functions.

## Which BIFs are impacted by Unicode versus ASCII/EBCDIC

- __length()__: length('Café') should be 4, not 5. The word has 5 bytes but 4 characters.

| Statement   | Rexx version | Platform  | Output |
|-----------  |--------------|-----------|--------|
| `say length('Café')` | CMS/TSO 4.02 | z/VM, z/OS| 4  |
| `say length('Café')` | USS | z/OS|  |
| `say length('Café')` | Regina       | all       | 5 |
| `say length('Café')` | Brexx 2.1    | all except| 5  |
| `say length('Café')` | NetRexx 4.05 | all | 4

- __center()__ (and __centre()__ of course): multibyte chars cannot be centered correctly if the number of character positions is unknown
- __left()__ and __right()__: these should not yield incorrect output by returning, e.g., half of a double byte character
- __substr()__: the same goes for substr()
- __translate()__: here are more repercussions that might not have been wholly solved in any implementation (needs further study)
- __lower()__ and __upper()__: how, for example, to change the case on Greek or Cyrillic

- __c2x__: we need to decide how to handle compatibility, perhaps adding length and encoding parameters

## I/O functions and methods

### Internal representation versus marshalling
A Rexx implementation should be free to choose how characters and strings are represented internally. A compressed approach or structures specific to the implementation should be possible; when data needs to be marshalled for I/O and transmission purposes, conversions to standard encoded representations should be available. These standards should be at least contain support for UTF-8 and historic codepages used by the implementations. These might be handled by external libaries but should be available from built-in functions.
The I/O components should be able to recognize byte order of UTF(16 or 32) files by checking the byte order marker (BOM).

Options can guide the writing of files. We have to see what from DBCS support in Classic Rexx can be carried over.

__NetRexx__ currently uses UTF-8 for the __charin()__ and __charout()__ stream functions - other encodings can be used by employing the java.util and java.nio classes.

__EXECIO__ implementations and emulations probably should not be changed.

