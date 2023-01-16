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

Languages (not Rexx) that have keywords mostly avoid having these keywords in Unicode.

## Which BIFs are impacted by Unicode versus ASCII/EBCDIC

- __length()__: length('Café') should be 4, not 5. The word has 5 bytes but 4 characters.

| Statement   | Rexx version | Platform  | Output |
|-----------  |--------------|-----------|--------|
| `say length('Café)` | CMS/TSO 4.02 | z/VM, z/OS| 4  |
| `say length('Café)` | Regina       | all       | 5 |
| `say length('Café)` | Brexx 2.1    | all except| 5  |
| `say length('Café)` | NetRexx 4.05 | all | 4

- __left()__ and __right()__: these should not yield incorrect output by returning, e.g., half of a double byte character
- __substr()__: the same goes for substr()
- __translate()__: here are more repercussions that might not have been wholly solved in any implementation (needs further study)
