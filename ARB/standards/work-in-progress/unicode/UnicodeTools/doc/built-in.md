# Rexx built-in functions for Unicode: enhancements and modifications

## C2X (Character to heXadecimal)

## CHARIN 

```
   ╭─────────╮              ╭───╮                       
▸▸─┤ CHARIN( ├─┬──────────┬─┤ , ├─┬───────────┬─┬──────────────────┬──▸◂
   ╰─────────╯ │ ┌──────┐ │ ╰───╯ │ ┌───────┐ │ │ ╭───╮ ┌────────┐ │ 
               └─┤ name ├─┘       └─┤ start ├─┘ └─┤ , ├─┤ length ├─┘
                 └──────┘           └───────┘     ╰───╯ └────────┘
```

The CHARIN BIF is enhanced by supporting the _encoding_ options specified in the STREAM OPEN command.
* When an _encoding_ is not specified for a file, the standard BIF is called.
* When an _encoding_ is specified, the action taken depends on the encoding _target_.
    * When the encoding _target_ is __TEXT__ (the default), a TEXT string, composed of grapheme clusters, is returned.
    * When the encoding _target_ is __CODEPOINTS__, the appropiate number of Unicode codepoints is read and is returned in a string.
* The handling of ill-formed Unicode sequences depends on the value of the encoding _error_handling_.
    * When _error_handling_ is set to __REPLACE__ (the default), any ill-formed character will be replaced by the Unicode Replacement Character (U+FFFD).
    * When _error_handling_ is set to __SYNTAX__, a Syntax condition will be raised.
 
Character positioning is precautionarily disabled in some circumstances:
* When the encoding is a variable-length encoding.
* When the encoding is a fixed-length encoding, but a _target_ of __TEXT__ has been requested.

Character positioning at the start of the stream (that is, when start is specified as __1__) will work unconditionally.

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## CHAROUT

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## CHARS 

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## CENTER

## CENTRE

## COPIES

## DATATYPE

## LEFT

## LENGTH

## LINEIN 

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## LINEOUT

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## LINES

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## LOWER

## POS

## REVERSE

## RIGHT 

## STREAM

Please refer to the accompanying document [_Stream functions for Unicode_](stream.md) for a comprehensive vision of the stream functions for Unicode-enabled streams.

## SUBSTR

## UPPER


Please refer to the documentation for Unicode.cls and Stream.cls for a detailed description of these enhanced BIFs.
