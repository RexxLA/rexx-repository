# External Search Order in Regina

### External Rexx programs (regina.pdf 3.9.5, section 1.4.2)

Regina searches for *Rexx* programs, using a combination of the **REGINA_MACROS**
environment variable, the **PATH** environment variable, the **REGINA_SUFFIXES** environment
variable and the addition of filename extensions. This rule applies to both external function calls
within a Rexx program and the program specified on the *command line*.

First of all we process the environment variable **REGINA_MACROS**. If no file is found we
proceed with the current directory and then with the environment variable **PATH**. The semantics of
the use of **REGINA_MACROS** and **PATH** are the same, and the search in the current directory is
omitted for the superuser on Unix systems for security reasons. The current directory must be
specified explicitly by the superuser.

When processing an environment variable, the content is split into the different paths and each path
is processed separately. Note that the search algorithm to this point is ignored if the program name
contains a file path specification. eg. if "CALL .\MYPROG" is called, then no searching of
**REGINA_MACROS** or **PATH** is done; only the concatenation of suffixes is carried out.

For each file name and path element, a concatenated file name is created. If a known file extension
is part of the file name only this file is searched, otherwise the file name is extended by the
extensions "" (empty string), ".rexx", ".rex", ".cmd", and ".rx" in this order. The file name case is
ignored on systems that ignore the character case for normal file operations like DOS, Windows,
and OS/2.

The first matching file terminates the whole algorithm and the found file is returned.

The environment variable **REGINA_SUFFIXES** extends the list of known suffixes as specified
above, and is inserted after the empty extension in the process. **REGINA_SUFFIXES** has to
contain a space or comma separated list of extensions, a dot in front of each entry is allowed,
e.g. ".macro,.mac,.regina" or "macro mac regina"-

Note that it is planned to extend the list of known suffixes by ".rxc" in version 3.4 to allow for
seamless integration of pre-compiled macros.

#### Example: Locating an external Rexx program for execution

Assume you have a call to an external function, and it is coded as follows:

    Call myextfunc arg1, arg2

Assume also that the file **myextfunc.cmd** exists in the directory /opt/rexx/, and that
**PATH**=/usr/bin:/opt/rexx, **REGINA_MACROS** is not set, and **REGINA_SUFFIXES**=.macro.

The files that Regina will search for in order are:

    ./myextfunc
    ./myextfunc.macro
    ./myextfunc.rexx
    ./myextfunc.rex
    ./myextfunc.cmd
    ./myextfunc.rx
    
    /usr/bin/myextfunc
    /usr/bin/myextfunc.macro
    /usr/bin/myextfunc.rexx
    /usr/bin/myextfunc.rex
    /usr/bin/myextfunc.cmd
    /usr/bin/myextfunc.rx
    
    /opt/rexx/myextfunc
    /opt/rexx/myextfunc.macro
    /opt/rexx/myextfunc.rexx
    /opt/rexx/myextfunc.rex
    /opt/rexx/myextfunc.cmd /* found!! terminate search*/
