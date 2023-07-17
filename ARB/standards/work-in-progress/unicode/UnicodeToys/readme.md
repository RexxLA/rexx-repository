# The Unicode Toys

Take a look at [UnicodeToys.md](doc/UnicodeToys.md) for a gentle introduction.

### Basic classes and classfiles

* [Runes.cls](Runes.cls) implements strings composed of codepoints. RUNES(string) returns a Runes value. BYTES(string) transforms a Runes strings into a classic Rexx string (currently, in UTF-8 format). TEXT(string) transforms a Runes string int a Text string.
* [Text.cls](Text.cls) implements strings composed of (extended) graphems clusters. TEXT(string) returns a Text value. RUNES(string) transforms a Text string into a Runes string. BYTES(string) transforms a Text string into a classic Rexx string (currently, in UTF-8 format).
* [Unicode.Property.cls](Unicode.Property.cls) is the base Unicode property class. Concrete Unicode property classes can subclass this class to get access to a number of common services.
* [Unicode.General_Category.cls](Unicode.General_Category.cls) implements the General_Category (gc) Unicode property, which can be found in the (required and included) [UnicodeData-15.0.0.txt](UnicodeData-15.0.0.txt) file. On the first run, and if not present, the class will automatically compile UnicodeData.txt and produce a [General_Category.bin](General_Category.bin) binary file (included). The class also implements the algorithmical part of the Name (na) property and of labels like "&lt;control-0001&gt;".
* [Unicode.Name.cls](Unicode.Name.cls) implements the Name (na) Unicode property, which can be found in the (required and included) [UnicodeData-15.0.0.txt](UnicodeData-15.0.0.txt) and [NameAliases-15.0.0.txt](NameAliases-15.0.0.txt) files. This class relies on the algorithmical handling of Unicode names included in [Unicode.General_Category.cls](Unicode.General_Category.cls).
* [Unicode.Grapheme_Cluster_Break.cls](Unicode.Grapheme_Cluster_Break.cls) implements a version of the Grapheme_Cluster_Break (gcb) property, which can be found on the (required and included) [UnicodeData-15.0.0.txt](UnicodeData-15.0.0.txt), [GraphemeBreakProperty-15.0.0.txt](GraphemeBreakProperty-15.0.0.txt) and [emoji-data-15.0.0.txt](emoji-data-15.0.0.txt) files. On the first run, and if not present, the class will automatically these .txt files and produce a [Grapheme_Cluster_Break.bin](Grapheme_Cluster_Break.bin) binary file (included).
* [Unicode.cls](Unicode.cls) implements a series of common and utility routines.

### Included Unicode UCD (Unicode Database) files

A number of UCD files that are necessary for the Unicode Toys classes to run are included in this distribution. Their names have "-15.0.0" added at the end, so that one can know for sure on which Unicode version the programs are based without having to resort to manual inspection of the files. All the files are official and have been downloaded from the Unicode web page. They are located in the [UCD](UCD/) subdirectory.

* [UnicodeData-15.0.0.txt](UnicodeData-15.0.0.txt) is the main UCD file.
* [NameAliases-15.0.0.txt](NameAliases-15.0.0.txt) lists a series of name aliases for certain codepoints.
* [GraphemeBreakProperty-15.0.0.txt](GraphemeBreakProperty-15.0.0.txt) maps codepoints to their corresponding Grapheme_Cluster_Break (gcb) property.
