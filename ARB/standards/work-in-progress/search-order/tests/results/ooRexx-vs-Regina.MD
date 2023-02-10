# Search Order in Rexx vs. Regina

| Feature | ooRexx | Regina |
| --- | --- | --- |
| Concept of "same" (or caller) directory | Yes | no |
| Directories to search | (1) REGINA MACROS (env. variable)<br>(2) Current directory<br> (3) PATH (env. variable) | (1) Caller directory<br> (2) Current directory<br>(3) Application-defined extra path<br> (4) REXX_PATH (env. variable)<br> (5) PATH (env. variable) |
| Bypassing the search order | The program name "contains<br>a file path specification" | name[1] == "\" \| name[1] == "/" \|<br> name[2] == ":" \| <br> name[1,2] == "./" \| name[1,2] == ".\\" \| <br> name[1,3] == "../" \| name[1,3] == "..\\" |
