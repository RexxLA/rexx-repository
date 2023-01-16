# Unicode

After an era of 6,7 and 8 bit character sets the computing world finally put an end to problems with code pages and non-english character encoding, and adopted the Unicode standard. This means a character might not fit in 8 bits anymore. The first 128 characters in the Unicode standards are identical to the ASCII characters. EBCDIC, which is the default character representation for the mainframe implementations, is a character set with 256 values, but like the ASCII and extended ASCII sets, a number of different codepages for different national languages. 

Most modern languages have chosen an internal Unicode representation and can use exchange formats like UTF-8 and UTF-16. Some Classic Rexx implementations can use multibyte character representation, like the z/VM an z/OS implementation can use Kana and Katakana. 

NetRexx, being Java, uses Java's character encoding, which is UTF-16. Most other variants and implementations thereof tolerate some Unicode use by being codepage 

## Which elements of the language can be Unicode

The possibilities here are
- Comments
- Identifiers
- Character content (of variables and constants)
- String content (of variables and constants)

## Which BIFs are impacted by Unicode versus ASCII/EBCDIC

- __length()__: length('Café') should be 4, not 5. The word has 5 bytes but 4 characters.
- __left()__ and __right()__: these should not yield incorrect output by returning, e.g., half of a double byte character
- __substr()__: the same goes for substr()
- __translate()__: here are more repercussions that might not have been wholly solved in any implementation
