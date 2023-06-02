# Unicode

After an era of 6,7 and 8 bit character sets the computing world finally put an end to problems with code pages and non-english character encoding, and adopted the Unicode standard. This means a character might not fit in 8 bits anymore. The first 128 characters in the Unicode standards are identical to the ASCII characters. EBCDIC, which is the default character representation for the mainframe implementations, is a character set with 256 values, but like the ASCII and extended ASCII sets, a number of different codepages for use with different national languages that need more than the Latin alphabet.

Most modern languages have chosen an internal Unicode representation and can use exchange formats like UTF-8 and UTF-16. Some Classic Rexx implementations can use multibyte character representation, like the z/VM an z/OS implementation wich can use Kana and Katakana in DBCS (Double Byte Character Sets). These require a number of options and caveats. 

NetRexx, being Java (or CLI), uses Java's internal character encoding, which is UTF-16. cRexx is being designed with Unicode in mind. Most other variants and implementations thereof tolerate some Unicode use by being *codepage agnostic*, which stops short of full Unicode support.

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
The I/O components should be able to recognize byte order of UTF(16 or 32) files by checking the byte order marker (BOM).

Options should guide the writing of files. We have to see what from DBCS support in Classic Rexx can be carried over.

__NetRexx__ currently uses UTF-8 for __charin()__ and __charout()__ - other encodings can be used by employing the java.util and java.nio classes.

__EXECIO__ implementations and emulations probably should not be changed.
