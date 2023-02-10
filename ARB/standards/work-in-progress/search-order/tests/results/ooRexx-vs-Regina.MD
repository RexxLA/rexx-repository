# Search Order in Rexx vs. Regina

| Feature | ooRexx | Regina |
| --- | --- | --- |
| Concept of "same" (or caller) directory | Yes | no |
| Directories to search: | (1) REGINA MACROS (env. variable)<br>(2) Current directory<br> (3) PATH (env. variable) | (1) Caller directory<br> (2) Current directory<br>(3) Application-defined extra path<br> (4) REXX_PATH (env. variable)<br> (5) PATH (env. variable) |
