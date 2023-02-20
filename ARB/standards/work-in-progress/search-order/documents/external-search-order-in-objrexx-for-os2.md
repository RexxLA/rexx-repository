# External search order for the OBJREXX interpreter under OS/2

\[Copied from REXX.INF, BOJREXX interpreter, Arca Noae 5.0.7\]

**External functions** and **subroutines** have a system-defined search order. 

The search order for external functions follows: 

1. Functions defined on ::ROUTINE directives within the program 
2. Public functions defined on ::ROUTINE directives of programs referenced with ::REQUIRES 
3. Functions that have been loaded into the macrospace for pre-order execution. (See the _Object REXX Programming Guide_ for information about the macrospace.) 
4. Functions that are part of a function package. (See the _Object REXX Programming Guide_ for details about function packages.) 
5. REXX functions in the current directory, with the current extension. 
6. REXX functions along environment PATH, with the current extension. 
7. REXX functions in the current directory, with the default extension. 
8. REXX functions along environment PATH, with the default extension. 
9. Functions that have been loaded into the macrospace for post-order execution. 
10. The full search pattern for functions and routines is shown in the following figure \[...\]. 
