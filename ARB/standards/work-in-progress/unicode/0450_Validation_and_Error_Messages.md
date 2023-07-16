## Validation and Error Messages

## ARB recommendations

(TBD)

## Draft Notes

Invalid format (proto)

[Mojibake](https://en.wikipedia.org/wiki/Mojibake)

[Web Encoding Spec](https://encoding.spec.whatwg.org)

Filenames

[WTF8](http://simonsapin.github.io/wtf-8/) (proto)

Optimization, SIMD

[Unicode at Gigabytes per second](https://www.youtube.com/watch?v=wBBbAKGaId4)

### Error messages

Rexx Errors 22 and 23 of ooRexx can be used for encoding/decoding errors. (Rick:) These are remnants of the times where ooRexx had DBCS support. 

Currently, error 22, "Invalid character string", reads:

    A literal string contains character codes that are not valid. This might be because some characters
    are not possible, or because the character set is extended and certain character combinations are not
    allowed.

    The associated subcodes are:

    001 Incorrect character string "character_string" ('hex_string'X).

    900 message.

    901 Incorrect double-byte character
    
while 23, "Invalid data string", reads:

    A data string (that is, the result of an expression) contains character codes that are not valid. This
    might be because some characters are not possible, or because the character set is extended and
    certain character combinations are not allowed.

    The associated subcodes are:

    001 Incorrect data string "string" ('hex_string'X).

    900 message.

