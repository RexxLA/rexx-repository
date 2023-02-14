# External Search Order in ooRexx

### Locating External Rexx Files (rexxref.pdf 5.0.0, section 7.2.1.1)

Rexx uses an extensive search procedure for locating program files. The first element of the search
procedure is the locations that will be checked for files. The locations, in order of checking, are:

1.  The same directory the program invoking the external routine is located. If this is an initial program execution or the calling program was loaded from the macrospace, this location is skipped. Checking in this directory allows related program files to be called without requiring the directory be added to the search path.
2.  The current filesystem directory.
4.  Some applications using Rexx as a scripting language may define an extension path used to locate called programs. If the Rexx program was invoked directly from the system command line, then no extension path is defined.
4. Any directories specified via the REXX_PATH environment variable.
5. Any directories specified via the PATH environment variable.

The second element of the search process is the file extension. If the routine name contains at least
one period, then this routine is extension qualified. The search locations above will be checked for
the target file unchanged, and no additional steps will be taken. If the routine name is not extension
qualified, then additional searches will be performed by adding file extensions to the name. All
directory locations will be checked for a given extension before moving to the next potential extension.
The following extensions may be used:

1. If the searched file is requested by a **::REQUIRES** directive without a **LIBRARY** option, or the **Package** methods **new** and **loadPackage** when only the name argument is specified, an attempt to locate a file using the extension **.cls** is made. 
2. If the calling program has a file extension, then the interpreter will attempt to locate a file using the same extension as the caller.
3. Some applications using Rexx as a scripting language may define additional extension types. For example, an editor might define a preferred extension that should be used for editor macros. This extension would be searched next.
4. The default system extension, which is **.REX** on Windows, and both **.rex** and **.REX** on Unix-based systems.
5. If the target file has not been located using any of the above extensions, the file name is tried without an added extension.

There are some file system considerations involved when searching for files. Windows file systems
typically are case insensitive, so files can be located regardless of how the call is specified. Unixbased
systems typically have a case sensitive file system, so files must be exact case matches in
order to be located. For these systems, each time a file name probe is attempted, the name will be
tried in the case specified and also as a lower case name. The check is not performed on the very last
step that uses the file name without an extension to avoid unintentional conflicts with other executable
files.

Note that for function or subroutine calls using an unquoted name, the target name is the string
value of the name symbol, which will be an uppercase value. Thus calls to myfunc(), MyFunc(), and
myFUNC() all trigger a search for a function named "MYFUNC". Calls specified as a quoted string will
maintain the original string case. Thus 'myfunc'() and 'MyFunc'() would search for different names.
