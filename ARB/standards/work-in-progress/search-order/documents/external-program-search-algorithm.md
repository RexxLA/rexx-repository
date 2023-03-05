# External Program Search Algorithm

**Definitions**. An **External Program Search Algorithm (EPSA)** is a procedure with the following arguments. 

* A _filename_. This can be specified as a single file name (```filename```) or as a file name followed by a file extension (```filename.ext```) or a filetype (```filename filetype```), and it can also include a (possibly relative) location specification (e.g, ```some/path/name.ext``` or filename ```filetype filemode```).
* A list of lists of (possibly only partially specified) _locations_ (i.e., directories, minidisks, etc.). One or more of these locations can be _distinguished_, and constitute a fallback choice when a _location exception_ is applied (see below).

  A _location list_ is created by collating of all the lists of locations in an order-preserving way.

* Another list of lists of (possibly empty) _file extensions/filetypes_. One or more of these extensions or filetypes can be _distinguished_, and constitute a fallback choice when an _extension/filetype exception_ is applied (see below).

  An _extension/filetype list_ is created by all the lists of extensions/types in an order-preserving way.
  
The _goal_ of the procedure is to locate and return the first file that matches the _filename_, resides in one of the _locations_ and has one of the specified _extensions/types_. 

The search algorithm can be **extension-first**, **filetype-first** or **location-first**. _Extension-first_ and _filetype-first_ algorithms 
search for a file in all locations using the first of the extensions or filetypes supplied; if not found, the search is initiated again, in all locations, 
with the second of the extensions or filetypes, and so on. A _ocation-first_ algorithm first searches all extensions or filetypes in the first supplied location; 
if not found, it searches all extensions or filetypes in the second supplied location, and so on.

In pseudo-code,

    Do loc Over locations -- Location-first search algorithm
      Do ext Over extensions     
        file = Check(loc, filename, ext)     
        If file \== "" Then Return file  
      End
    End
    
and 

    Do ext Over extensions -- Extension-first search algorithm  
      Do loc Over locations     
        file = Check(loc, filename, ext)     
        If file \== "" Then Return file  
      End
    End
    
Every EPSA algorithm can specify a procedure for **location exceptions**, and another procedure for **extension exceptions** or **filetype exceptions**. 
The _location exceptions_ procedure can indicate that, instead of searching in all locations, the search will be limited to a designated subset of these same locations. 
The _extension/filetype exceptions_ procedure can limit the search to a designated subset of the extensions or filetypes, 
or require that the search is performed using no extension at all.

An External Program Search Algorithm is completely determined by its parameters, by the exception subalgorithms, 
if any, and by the fact that the search has to be performed extension-, filetype- or location-first.
