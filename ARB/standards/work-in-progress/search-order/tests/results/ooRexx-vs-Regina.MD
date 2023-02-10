# Search Order in Rexx vs. Regina

| Feature | Regina | ooRexx |
| --- | --- | --- |
| Concept of "same" (or caller) directory | Yes | no |
| Directories to search | (1) REGINA MACROS (env. variable)<br>(2) Current directory<br> (3) PATH (env. variable) | (1) Caller directory<br> (2) Current directory<br>(3) Application-defined extra path<br> (4) REXX_PATH (env. variable)<br> (5) PATH (env. variable) |
| Bypassing the search order | The program name "contains<br>a file path specification" | name[1] == "\" \| name[1] == "/" \|<br> name[2] == ":" \| <br> name[1,2] == "./" \| name[1,2] == ".\\" \| <br> name[1,3] == "../" \| name[1,3] == "..\\" |
| Is this bypassing documented? | Yes. 1.4.2 of the 3.9.5 version of regina.pdf | No |
| Search for same extension as caller? | No | Yes |
| Basic extension list and order | [1] "" (empty string),<br> [2] ".rexx",<br> [3] ".rex",<br> [4] ".cmd",<br> and [5]".rx" | [1] ".cls" (for ::requires only),<br> [2] the same extension,<br> the application-defined extensions, [3] ".REX" [3] (for unix-like systems), [4] ".rex", and<br> [5] no extension |
