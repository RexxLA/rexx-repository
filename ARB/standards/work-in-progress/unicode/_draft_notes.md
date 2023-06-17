# Draft notes, to use as support during calls

## Identification of subcommittees

### [Backward compatibility](./Backward_compatibility.md)

### Define what is a character

See requirement document.

Probably grapheme, but good to investigate if an other approach could be valuable for some sceanrios.


### [Internal representation](Internal_representation.md)

### [Validation](./Validation.md)

### [Serialization and deserialisation](./Serialization_and_deserialization.md)

### String & characters notations


c2x, x2c

U+ notation (proto), 

Unicode escape sequence (proto), 

Literals

> (adrian) we should give the Unicode codepoint and not the UTF-8 coding when dealing with .text.

(jlf)  
c2x must return what x2c is needing to create a string from hex values.  
For NetRexx, it's a UCS-2 codepoint, limited to 16 bits.  
For cRexx, it's 32 bits because you choose to return Unicode scalar values (32 bit codepoints) and hide the internal encoding.  
For Regina and ooRexx, it's the internal encoding, whatever it is.

For all the interpreters, the 32 bit codepoints can be requested with a dedicated function, and returned as integers.  
Such integer acts as a key to query the properties of the Unicode character.  
(/jlf)


### String concatenation


[Rules in Executor](https://github.com/jlfaucher/executor/blob/72e68d17ec5b6797ccd9e0ba847f330ab34846be/sandbox/jlf/packages/encoding/encoding.cls#LL319C1-L346C1)

Rope


### Segmentation

Josep Maria : a priority should be given. For example, sgmentation by words and sentences is less prioritary than codepoints & graphemes.

Code point, Grapheme  (proto)

Codepoint/grapheme indexation  (proto)

Whitespaces, separators

Hyphenation

Words, Sentences


### Upper, lower, caseless

Case mappings (proto)

Collation, sorting


### [String comparison](./String_comparison.md)

### Identifiers, Security


### Locale

CLDR Common Locale Data Repository


### BIDI


### Regular expressions


### Terminal / console / cmd

Describing the right environnment for the tests.

