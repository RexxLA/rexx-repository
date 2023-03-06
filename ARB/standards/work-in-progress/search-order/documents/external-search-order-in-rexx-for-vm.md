># Search Order

[For z/VM 7.1](https://www.ibm.com/docs/en/zvm/7.1?topic=subroutines-search-order)

>
>The search order for functions is: internal routines take precedence, then built-in functions, and finally external functions.
>
>**Internal routines** are _not_ used if the function name is given as a literal string (that is, specified in quotation marks); in this case the function must be built-in or external. This lets you usurp the name of, say, a built-in function to extend its capabilities, yet still be able to call the built-in function when needed.
>
>**Example:**

    /* This internal DATE function modifies the          */
    /* default for the DATE function to standard date.   */
    date: procedure
          arg in
          if in='' then in='Standard'
          return 'DATE'(in)```
>
>**Built-in functions** have uppercase names, and so the name in the literal string must be in uppercase for the search to succeed, as in the example. The same is usually true of external functions.
>**External functions** and **subroutines** have a system-defined search order.
>
>**External functions** and **subroutines** have a specific search order.
>
>1. The name has a prefix of RX, and the language processor attempts to run the program of that name, using CMSCALL.
>2. If the function is not found, the function packages are interrogated and loaded if necessary (they return RC=0 if they contained the requested function, or RC=1 otherwise). The function packages are checked in the order RXUSERFN, RXLOCFN, and RXSYSFN. If the load is successful, step 2 is repeated and will succeed.
>3. If still not found, the name is restored to its original form, and all directories and accessed minidisks are first checked for a program with the same file type as the currently executing program (if the file type is not EXEC, as with XEDIT macros for example), and then checked for a file with the file type of EXEC. If either is found, control is passed to it. (The IMPEX setting has no control over this.)
>4. Finally the language processor attempts to run the function under its original name, using CMSCALL. (If still not found, an error results.)
>
>The name prefix mechanism, RX, allows new REXX functions to be written with little chance of name conflict with existing MODULES.
