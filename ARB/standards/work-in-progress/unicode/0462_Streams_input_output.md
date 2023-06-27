# Streams (input/output)

## ARB recommendations

(TBD)

## Draft Notes

### ISO-8859-1 jlf question
ISO-8859-1  
All bytes compatible with Unicode? or not?  
- [ISO8859](https://www.unicode.org/Public/MAPPINGS/ISO8859/)
  Each character has a Unicode mapping.
- [Wikipedia](https://en.wikipedia.org/wiki/ISO/IEC_8859-1#Code_page_layout)
  The characters 00x to 1Fx and 7Fx to 9Fx are UNDEFINED. Why?

I follow the Wikipedia mapping, and because of that, I have this error:

        xrange()~text("iso-8859-1")~utf8=
        ISO-8859-1 encoding: cannot convert ISO-8859-1 not-ASCII character 0 (0) at byte-position 1 to UTF-8.

For Windows-1252, [Wikipedia](https://en.wikipedia.org/wiki/Windows-1252) defines
a mapping for each character, with this comment:  
According to the information on Microsoft's and the Unicode Consortium's websites,
positions 81, 8D, 8F, 90, and 9D are unused; however, the Windows API
`MultiByteToWideChar` maps these to the corresponding C1 control codes.

[Note Microsoft](https://learn.microsoft.com/en-us/windows/win32/intl/code-pages):
Originally, Windows code page 1252, the code page commonly used for English and 
other Western European languages, was based on an American National Standards 
Institute (ANSI) draft. That draft eventually became ISO 8859-1, but Windows 
code page 1252 was implemented before the standard became final, and is not 
exactly the same as ISO 8859-1.

By following theses rules, all the byte characters can be converted to Unicode:

        xrange()~text("windows-1252")~utf8=
        T'[000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F] !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ'

## End of lines with stream in text mode

Illustration with Executor, same with ooRexx.  
Not tested with cRexx, NetRexx, Regina.

.stream~linein is not working correctly with UTF-16, UTF-32.  
The detection of EOL is not good, should test the bytes listed below, in function of the encoding.

    1 : ['utf8:0A','utf16be:000A','utf16le:0A00','utf32be:0000000A','utf32le:0A000000']
    2 : ['utf8:0D','utf16be:000D','utf16le:0D00','utf32be:0000000D','utf32le:0D000000']

Dump files generated in the folder [unicode/bbedit-save_as](https://github.com/jlfaucher/executor/tree/master/sandbox/jlf/unicode/bbedit-save_as)
for the following cases supported by the editor BBEdit under MacOs:

    UTF-8
    UTF-8 with BOM
    UTF-16          (UTF-16BE)
    UTF-16 no BOM   (UTF-16BE)
    UTF-16LE
    UTF-16LE no BOM

Files showing the problem with .stream~linein:

[utf16_crlf-dump.txt](https://github.com/jlfaucher/executor/blob/21d0ad5979c361ca52c4080a504e43501a8b81a8/sandbox/jlf/unicode/bbedit-save_as/utf16_crlf-dump.txt#LL4C113-L4C120):
end of string is 000D 00 (remaining of 000D 000A where only 0A was recognized)

[utf16_lf-dump.txt](https://github.com/jlfaucher/executor/blob/21d0ad5979c361ca52c4080a504e43501a8b81a8/sandbox/jlf/unicode/bbedit-save_as/utf16_lf-dump.txt#LL4C113-L4C115):
end of string is 00 (remaining of 000A where only 0A was recognized)

[utf16_nobom_crlf-dump.txt](https://github.com/jlfaucher/executor/blob/21d0ad5979c361ca52c4080a504e43501a8b81a8/sandbox/jlf/unicode/bbedit-save_as/utf16_nobom_crlf-dump.txt#LL4C108-L4C115):
same as utf16_crlf-dump.txt

[utf16_nobom_lf-dump.txt](https://github.com/jlfaucher/executor/blob/21d0ad5979c361ca52c4080a504e43501a8b81a8/sandbox/jlf/unicode/bbedit-save_as/utf16_nobom_lf-dump.txt#LL4C108-L4C110):
same as utf16_lf-dump.txt

[utf16le_crlf-dump.txt](https://github.com/jlfaucher/executor/blob/21d0ad5979c361ca52c4080a504e43501a8b81a8/sandbox/jlf/unicode/bbedit-save_as/utf16le_crlf-dump.txt#LL4C113-L4C117):
end of first string is 0D00. Then all the following strings are wrongly extracted (not aligned on 16-bit boundary)

[utf16le_lf-dump.txt](https://github.com/jlfaucher/executor/blob/21d0ad5979c361ca52c4080a504e43501a8b81a8/sandbox/jlf/unicode/bbedit-save_as/utf16le_lf-dump.txt#LL29C10-L29C15):
end of first string is correct. But then all the following strings are wrongly extracted (not aligned on 16-bit boundary)

[utf16le_nobom_crlf-dump.txt](https://github.com/jlfaucher/executor/blob/21d0ad5979c361ca52c4080a504e43501a8b81a8/sandbox/jlf/unicode/bbedit-save_as/utf16le_nobom_crlf-dump.txt#LL4C108-L4C112):
same as utf16le_crlf-dump.txt

[utf16le_nobom_lf-dump.txt](https://github.com/jlfaucher/executor/blob/21d0ad5979c361ca52c4080a504e43501a8b81a8/sandbox/jlf/unicode/bbedit-save_as/utf16le_nobom_lf-dump.txt#LL28C10-L28C15):
same as utf16le_lf-dump.txt


## Raw bytes versus Unicode

See also [0400_Internal_representation.md](0400_Internal_representation.md).

### [PEP 383 – Non-decodable Bytes in System Character Interfaces](https://peps.python.org/pep-0383/)

(jlf) referencing this PEP because of its Rationale.
For Rexx, we are thinking to separate bytes and text by using 2 different types.
But according this PEP, it's maybe not enough. (/jlf)

#### Rationale (exerpts)
The C char type is a data type that is commonly used to represent both character
data and bytes. Certain POSIX interfaces are specified and widely understood as
operating on character data, however, the system call interfaces make no assumption
on the encoding of these data, and pass them on as-is. With Python 3, character
strings use a Unicode-based internal representation, making it difficult to ignore
the encoding of byte strings in the same way that the C interfaces can ignore the
encoding.

On the other hand, Microsoft Windows NT has corrected the original design limitation
of Unix, and made it explicit in its system interfaces that these data (file names,
environment variables, command line arguments) are indeed character data, by providing
a Unicode-based API (keeping a C-char-based one for backwards compatibility).

For Python 3, one proposed solution is to provide two sets of APIs:
a byte-oriented one, and a character-oriented one, where the character-oriented
one would be limited to not being able to represent all data accurately.
Unfortunately, for Windows, the situation would be exactly the opposite:
the byte-oriented interface cannot represent all data; only the character-oriented
API can. As a consequence, libraries and applications that want to support all
user data in a cross-platform manner have to accept mish-mash of bytes and
characters exactly in the way that caused endless troubles for Python 2.x.

### Java "file.encoding" property, "codepage-aware" Rexx stream-BIF/stream class (Rony 20230627)

One area that needs to be addressed is processing text from streams (files) which may be encoded according to different codepages.
In Java there is a system property named "file.encoding" that determines the default encoding. On Java 17 on European Windows this encoding may be set to "Cp1252". Starting with Java 18 the default "file.encoding" gets set to "UTF-8" on all systems.
The Java classes java.io.Reader [1] and java.io.Writer [2] get used for reading or writing characters and strings.
(The encoding of the standard files stdout and stderr may deviate from the "file.encoding" system property, e.g. on a Western Windows Java may explicitly define system properties like "sun.stdout.encoding" and "sun.stderr.encoding".)
If files are to be read or written in "byte mode" one would use java.io.InputStream [3] and java.io.OutputStream [4] respectively in Java.
(Beware of mixing these classes up with "java.util.stream.Stream" [5], [6] introduced with Java 8.)

---
Ad current Rexx stream BIFs/classes: linein/lineout BIFs/methods would be about byte-streams where CR and/or LF characters get removed/appended, whereas charin/charout would not change the byte-data at all.

---

The idea:

* Start out first by adding bytein/byteout BIFs/methods which always operate on bytes (like InputStream and OutputStream in the Java case). In classic Rexx and ooRexx bytein/byteout would by default be synonyms with charin/charout unless
* the stream-BIF "OPEN" command includes explicitly a codepage name which would make linein/lineout and charin/charout "codepage-aware" and apply the appropriate codepage processing.

So, if a future "codepage-aware" version of Rexx/ooRexx would allow indicating a specific codepage in its open command/method, e.g. "UTF-8", "Cp1252", "Cp850", then linein/lineout and charin/charout should operate with (potentially mulit-byte) characters. If a binary interaction was desired in such a scenario then bytein/byteout should be employed instead.

If no codepage is supplied in the "OPEN" command the original "character is a single byte" semantics (with no automatic codepage translatation taking place by Rexx) apply for backward compatibility.

Probably a "query codepage" command should be devised that returns the empty string (if no codepage was defined for the stream) or the codepage supplied in the "OPEN" command causing linein/lineout/charin/charout to apply the appropriate codepage processing.

E.g. some hypothetical code:

<pre>
      myFile="someEncodedTextFile.txt"
      call stream myFile, "c", "open both utf-8" -- "utf-8" will trigger codepage-aware processing 

      say stream(myFile,"c","query codepage")    -- says: "utf-8"

      say linein()        -- read a line and read position gets increased accordingly
      say charin(,,15)    -- read 15 (potentially multibyte) characters, read position gets increased accordingly

      say <i>bytein(,,15)</i>    -- read 15 <i>bytes</i>, read position gets increased accordingly

      call lineout myFile -- close file or "call myFile,'c','close' "
</pre>

The encoding option could be something like "utf8", "utf-8",  "utf-16", "utf-32", "cp437", "cp-437", "cp850" according to [7] ...

[1] [Javadoc 8 for java.io.Reader](https://docs.oracle.com/javase/8/docs/api/java/io/Reader.html)  
[2] [Javadoc 8 for java.io.Writer](https://docs.oracle.com/javase/8/docs/api/java/io/Writer.html)  
[3] [Javadoc 8 for java.io.InputStream](https://docs.oracle.com/javase/8/docs/api/java/io/InputStream.html)  
[4] [Javadoc 8 for java.io.OutputStream](https://docs.oracle.com/javase/8/docs/api/java/io/OutputStream.html)  
[5] [Javadoc 8 for java.util.stream.Stream](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html)  
[6] [Tutorial on java.util.stream.Stream](https://www.baeldung.com/java-8-streams)  
[7] [Oracle technotes on Java 8 supported encodings](https://docs.oracle.com/javase/8/docs/technotes/guides/intl/encoding.doc.html)  
