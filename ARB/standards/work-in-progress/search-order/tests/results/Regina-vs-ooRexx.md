# Search Order in Regina vs. ooRexx

Tested with [Test Search Order](../programs/TestSearchOrder).

Versions compared are ooRexx 5.1.0 (Edition 2023.01.01, last revised on 20221024 with r12526) under Windows 11 Pro and Regina Rexx 3.9.5 under Ubuntu 20.04 (wsl2).

| Feature | Regina | ooRexx |
| --- | --- | --- |
| Concept of "same" (or caller) directory | No | Yes |
| Directories to search | (1) REGINA_MACROS (env. variable)<br>(2) Current directory<br> (3) PATH (env. variable) | (1) Caller directory<br> (2) Current directory<br>(3) Application-defined extra path<br> (4) REXX_PATH (env. variable)<br> (5) PATH (env. variable) |
| User-defined extra directories | REGINA_MACROS<br> Before the current directory | REXX_PATH <br> After the current directory |
| The search order is bypassed... | ... when the program name <br>"contains a file path specification" | ... when name[1] == "\" \| name[1] == "/" \|<br> name[2] == ":" \| <br> name[1,2] == "./" \| name[1,2] == ".\\" \| <br> name[1,3] == "../" \| name[1,3] == "..\\" |
| Is this bypassing documented? | Yes. 1.4.2 of the 3.9.5 version of regina.pdf | No |
| Search for same extension as caller? | No | Yes |
| Basic extension list and order | [1] "" (empty string),<br> [2] REGINA_SUFFIXES (env. variable),<br> [3] ".rexx",<br> [4] ".rex",<br> [5] ".cmd", and<br> [6] ".rx" | [1] ".cls" (for ::requires only),<br> [2] the same extension,<br> [3] the application-defined extensions, <br> [4] ".REX", (for unix-like systems), <br> [5] ".rex", and<br> [6] no extension |
| Searches for no extension | At the beginning | At the end |
| User-defined extensions | Yes (REGINA_SUFFIXES) | No (Application defined only) |
| Type of traversal | Directory-first | Extension-first |
