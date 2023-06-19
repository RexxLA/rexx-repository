# Serialization and deserialization

## ARB recommendations

(TBD)

## Draft Notes

> (josep maria)
> Manipulating a stream that is BINARY RECLENGTH nnn is the first example that comes to my mind.
>  One knows the binary structure of the records, for example you know that the first four bytes
>  of each record represent an integer. You get the first four bytes, Left(record, 4), then C2X, then X2D

we should distinguish internal representation from serialization - this particular
example can go wrong in so many ways; network byte order versus little endian;
signed (1 complement, 2 complement) vs unsigned;

jlf question:
ISO8859-1  
All bytes compatible with Unicode? or not?  
- [ISO8859](https://www.unicode.org/Public/MAPPINGS/ISO8859/)
- [Wikipedia](https://en.wikipedia.org/wiki/ISO/IEC_8859-1#Code_page_layout)

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
