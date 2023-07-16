# The Unicode Toys

### Basic classes

* [Runes.cls](Runes.cls) implements strings composed of codepoints. RUNES(string) returns a Runes value. BYTES(string) transforms a Runes strings into a classic Rexx string (currently, in UTF-8 format). TEXT(string) transforms a Runes string int a Text string.
* [Text.cls](Text.cls) implements strings composed of (extended) graphems clusters. TEXT(string) returns a Text value. RUNES(string) transforms a Text string into a Runes string. BYTES(string) transforms a Text string into a classic Rexx string (currently, in UTF-8 format).
* [Unicode.Property.cls](Unicode.Property.cls) is the base Unicode property class. Concrete Unicode property classes can subclass this class to get access to a number of common services.
* [Unicode.General_Category.cls](Unicode.General_Category.cls) implements the General_Category (gc) Unicode property, which can be found in the (required and included) [UnicodeData-15.0.0.txt](UnicodeData-15.0.0.txt) file.
