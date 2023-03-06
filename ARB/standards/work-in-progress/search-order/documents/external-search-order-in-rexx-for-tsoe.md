># Search order [for TSO/E REXX, z/OS 2.4](https://www-40.ibm.com/servers/resourcelink/svc00100.nsf/pages/zOSV2R4sa320972?OpenDocument)
>
>The search order for functions is: internal routines take precedence, then built-in functions, and finally external functions.
>
>**Internal routines** are _not_ used if the function name is given as a literal string (that is, specified in
>quotation marks); in this case the function must be built-in or external. This lets you usurp the name of,
>say, a built-in function to extend its capabilities, yet still be able to call the built-in function when needed.
>
>Example:

    /* This internal DATE function modifies the */
    /* default for the DATE function to standard date. */
    date: procedure
      arg in
      if in='' then in='Standard'
      return 'DATE'(in)
      
>**Built-in functions** have uppercase names, and so the name in the literal string must be in uppercase for
>the search to succeed, as in the example. The same is usually true of external functions. The search order
>for **external functions** and **subroutines** follows.
>
>1. Check the following function packages defined for the language processor environment:
>    * User function packages
>    * Local function packages
>    * System function packages
>2. If a match to the function name is not found, the function search order flag (FUNCSOFL) is checked.
>The FUNCSOFL flag (see “Flags and corresponding masks” on page 322) indicates whether load libraries are searched before the search for a REXX exec.  
>If the flag is off, check the load libraries. If a match to the function name is not found, search for a REXX program.  
>If the flag is on, search for a REXX program. If a match to the function name is not found, check the load libraries.  
>By default, the FUNCSOFL flag is off, which means that load libraries are searched before the search for a REXX exec.  
>You can use TSO/E EXECUTIL RENAME to change functions in a function package directory. For more information, see EXECUTIL RENAME.
>3. TSO/E uses the following order to search the load libraries:
>    * Job pack area
>    * ISPLLIB. If the user entered LIBDEF ISPLLIB ..., the system searches the new alternate library defined by LIBDEF followed by the ISPLLIB library.
>    * Task library and all preceding task libraries
>    * Step library. If there is no step library, the job library is searched, if one exists.
>    * Link pack area (LPA)
>    * Link library
>4. The following list describes the steps used to search for a REXX exec for a function or subroutine call:  
>**Restriction**: VLF is not searched for REXX execs called as functions or subroutines.  
>    a. Search the ddname from which the exec that is calling the function or subroutine was loaded. For
>example, if the calling exec was loaded from the DD MYAPPL, the system searches MYAPPL for the
>function or subroutine.  
>**Note** : If the calling exec is running in a non-TSO/E address space and the exec (function or
>subroutine) being searched for was not found, the search for an exec ends. Note that depending on
>the setting of the FUNCSOFL flag, the load libraries may or may not have already been searched at
>this point.  
>b. Search any exec libraries as defined by the TSO/E ALTLIB command  
>c. Check the setting of the NOLOADDD flag (see “Flags and corresponding masks” on page 322).
>    * If the NOLOADDD flag is off, search any data sets that are allocated to SYSEXEC. (SYSEXEC is the
>default system file in which you can store REXX execs; it is the default ddname specified in the
>LOADDD field in the module name table. See “Module name table” on page 326).  
>If the function or subroutine is not found, search the data sets allocated to SYSPROC. If the
>function or subroutine is not found, the search for an exec ends. Note that depending on the
>setting of the FUNCSOFL flag, the load libraries may or may not have already been searched at
>this point.
>    * If the NOLOADDD flag is on, search any data sets that are allocated to SYSPROC. If the function or
>subroutine is not found, the search for an exec ends. Note that depending on the setting of the
>FUNCSOFL flag, the load libraries may or may not have already been searched at this point.
>
>**Note**: With the defaults that TSO/E provides, the NOLOADDD flag is off. This means that SYSEXEC
>is searched before SYSPROC.  
>You can control the NOLOADDD flag using the TSO/E REXX EXECUTIL command. For more
>information, see “EXECUTIL” on page 216.

## The USS environment
USS (Unix Systems Services) provides a POSIX environment for z/OS (it qualifies as a Unix version). It can be accessed using a shell like zh or bash, and Rexx execs can be started from these shells. The shell accesses a Unix-type singly-rooted filesystem and scripts are started like in Unix. Rexx execs can be in various character sets and when started with the 'rexx' program, do not need a shebang.

## The /* Rexx */ comment requirement
When a Rexx exec is located in the SYSEXEC concatenation, TSO automatically recognizes it as a Rexx exec and passes it to the Rexx interpreter for execution, without the need for a /* REXX */ comment.

However, when a Rexx exec is located in the SYSPROC concatenation, you do need to include the /* REXX */ comment at the beginning of the program to ensure that TSO recognizes it as a Rexx exec and passes it to the Rexx interpreter for execution, this is because clists are also loaded from the SYSPROC concatenation.

## The JES2 batch environment
Rexx execs can be run in batch, either by TSO in a batch job using the IKJEFT01 program (here the DDnames SYSPROC and SYSEXEC play the same role as in online TSO, or by the IRXJCL program, which takes the SYSEXEC DDname). 