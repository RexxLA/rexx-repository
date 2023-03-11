# External Search Order for REXX under VM/SP

References:

* SC24-5239-0, First Edition, September 1983.
* SC24-5239-0, Third Edition, December 1986.

The only difference between SC24-5239-0 and SC24-5239-2 is indicated below {in curly braces}. 
{x} means that "x" only appears in the VM/SP release 3 version of the manual.

## Search Order
>The search order for functions the same as in the list above. That is, internal labels
>take precedence, then built-in functions, and finally external functions.
>
>**Internal labels** are _not_ used if the function name is given as a string (that is, is specified
>in quotes) - in this case the function must be built-in or external. This lets
>you usurp the name of, say, a built-in function to extend its capabilities, yet still be
>able to invoke the built-in function when needed.
>
>**Example**:

    /* Modified DATE to return sorted date by default */
    date: procedure
          arg in
          if in=" then in='Sorted'
          return 'DATE' (in)

>{Note that the} **built-in functions** have uppercase names, and so the name in the
>literal string must be in uppercase for the search to succeed, as in the example. The
>same is usually true of external functions.
>
>**External functions and subroutines** have a special search order:
>
>1. The name is prefixed with RX, and the interpreter attempts to execute the program of that name, using SVC 202.
>2. If the function is not found, the function packages will be interrogated and loaded if necessary (they return RC=O if they contained the requested function,  or RC= 1 otherwise). The function packages are checked in the order RXUSERFN, RXLOCFN, and RXSYSFN. If the load is successful, step (1) is repeated and will succeed.
>3. If still not found, the name is restored to its original form, and all disks are first checked for a program with the same filetype as the currently executing program (if the filetype is not EXEC, as with XEDIT macros for example), and then checked for a file with the filetype of EXEC. If either is found; control is passed to it. (The IMPEX setting has no control over this.)
>4. Finally the interpreter attempts to execute the function under its original name, using SVC 202. (If still not found, an error results.)
>
>The name prefix mechanism allows new REXX functions to be written with little chance of name conflict with existing MODULES.

## Rexx programs have to start with a /* comment */

¿When, exactly? ¿Always? ¿When invoked from the command line? ¿Does a called routine need this beggining comment?

## Beware of access 235 c/a

¿Does it affect the search order?
