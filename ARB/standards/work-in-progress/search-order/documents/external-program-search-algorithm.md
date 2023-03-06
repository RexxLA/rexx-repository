# External Program Search Algorithm - Draft 0.3

**Definitions**. An **External Program Search Algorithm (EPSA)** is a procedure with the following arguments. 

* A _filename_. This can be specified as a single file name (```filename```) or as a file name followed by a file extension (```filename.ext```), and it can also include a (possibly relative) location specification (e.g, ```some/path/name.ext```).
* A list of lists of (possibly only partially specified) _directories_. One or more of these directories can be _distinguished_, and constitute a fallback choice when a _directory exception_ is applied (see below).

  A _directory list_ is created by collating of all the lists of directories in an order-preserving way.

* Another list of lists of (possibly empty) _file extensions_. One or more of these extensions can be _distinguished_, and constitute a fallback choice when an _extension exception_ is applied (see below).

  An _extension list_ is created by all the lists of extensions in an order-preserving way.
  
The _goal_ of the procedure is to locate and return the first file that matches the _filename_, resides in one of the _directories_ and has one of the specified _extensions_. 

The search algorithm can be **extension-first** or **location-first**. _Extension-first_ algorithms 
search for a file in all locations using the first of the extensions supplied; if not found, the search is initiated again, in all locations, 
with the second of the extensions, and so on. A _directory-first_ algorithm first searches all extensions in the first supplied location; 
if not found, it searches all extensions in the second supplied location, and so on.

In pseudo-code,

    Do dir Over directories -- Directory-first search algorithm
      Do ext Over extensions     
        file = Check(dir, filename, ext)     
        If file \== "" Then Return file  
      End
    End
    
and 

    Do ext Over extensions -- Extension-first search algorithm  
      Do dir Over directories
        file = Check(dir, filename, ext)     
        If file \== "" Then Return file  
      End
    End
    
Every EPSA algorithm can specify a procedure for **directory exceptions**, and another procedure for **extension exceptions**. 
The _directory exceptions_ procedure can indicate that, instead of searching in all directory, the search will be limited to a designated subset of these same locations. 
The _extension exceptions_ procedure can limit the search to a designated subset of the extensions or filetypes, or require that the search is performed using no extension at all.

An External Program Search Algorithm is completely determined by its parameters, by the exception subalgorithms, 
if any, and by the fact that the search has to be performed extension- or location-first.

## Example 1. The External Program Search Order in ooRexx

The **list of directories** for ooRexx is (1) the "same" or caller's directory, when it exists (i.e., not for macrospace programs); (2) the current directory, which is the distinguished location; (3) the application-defined extra path, i.e., the value of the ```EXTERNAL_CALL_PATH``` parameter; (4) the contents of the ```REXX_PATH``` environment variable; (5) the contents of the ```PATH``` environment variable.

The **list of extensions** is (1) ```".cls"``` (only for ```::REQUIRES```); (2) the caller's extension, if it has one; (3) the application-defined extra extensions, i.e., the value of the ```EXTERNAL_CALL_EXTENSIONS``` parameter; (4) ```".REX"``` on Windows, or ```".rex"``` and ```".REX"``` on Unix-based systems; and (5) ```""```, i.e., no extension, the distinguished extension.

The **directory exception algorithm** returns true when ```filename[1] == "/" | filename[1] == "~" | filename[1,2] == "./" | filename[1,3] == "../"``` for Unix-like systems, and when ```filename[1] == "\" | filename[2] == ":" | filename[1,2] == ".\" | filename[1,3] == "..\" for Windows```. In these cases, only the distinguished directory (the current directory) is checked.

The **extension exception** algorithm returns true when ```filename~contains(".")```. In this case, only the filename as-is is checked, which is equivalent to checking with the distinguished extension, that is, with no extension.
