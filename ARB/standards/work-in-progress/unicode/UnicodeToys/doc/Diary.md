# Unicode Toys: Diary

20230726: 0.2  - Numerous changes, too many to report in complete detail here:

* Extensive refactoring.
* I'm beginning to work on abstracting the persistence level (persistent limited StringTable).
* Allow for three-stage tables in addition to two-stage tables.
* Implement LOWER and UPPER, using full case mappings (i.e., use SpecialCasing.txt in addition to UnicodeData.txt).
* Relocate binary file building routines to the ``build`` subdirectory, and self-tests to the ``tests`` subdirectory.
* Delete the ``demo`` directory and create instead a new ``samples`` directory.
* Add OPTIONS CONVERSIONS and OPTIONS DEFAULTSTRING handling to the ``rxu`` command.
* Store numerous binary properties (see ``case.cls`` in the ``properties`` subdirectory). These will come handy to implement normalization, full case folding, etc.
* Check that everything works under Linux (checked under Ubuntu 22.04 LTS) (thanks Marc!).

20230721: 0.1e - New property classfile: Unicode.case. First version: implement toLowercase(). Implement LOWER BIF and !LOWER aux function. Create a persistence system for properties.  
20230720: 0.1e - Fix some bugs. Add support for U+hhhh in U strings.  
20230719: 0.1d - Add the Rexx tokenizer, rxu.rex, and support for LEFT, RIGHT and REVERSE.  
20230718: 0.1c - Move property classes to the "properties" subdir. Move binary files to the "bin" subdir. Fix some bugs, and add a consistency check for the Name (na) property.  
20230717: 0.1a and 0.1b - Fix a bug, move UCD files to the "UCD" directory, move demos to the "demo" directory, create "doc" directory, move one file there.  
20230716: 0.1 - Initial release.
