Here the research by Rony for Windows and Unix(-like)

## Here two resources which may help for this discussion:

  * PATH (variable): <https://en.wikipedia.org/wiki/PATH_(variable)>
  * Path (computing): <https://en.wikipedia.org/wiki/Path_(computing)>

## Ad resolving Rexx programs, here a few terms that get used further down:

 1. srcDir: the source directory of the Rexx program that currently gets run (one can get at it by
    extracting the path2pgm's location from 'parse source . . path2pgm'
 2. currDir: the current working directory in which the Rexx program executes
 3. pathDir: the directories listed on the PATH environment variable

 4. relativePath: any path that does not start with the root directory, which therefore gets
    resolved relative to currDir
 5. absolutePath: any path that starts out with the root directory, which therefore locates exactly
    the desired executable

 6. unqualifiedExecutable: the name of an executable without path information
 7. relativeExecutables: the name of an executable with relative path information, i.e. relativePath
 8. absoluteExecutables: the fully qualified name of any executable,  i.e. absolutePath

## Searching for executables via the operating system:

  * Unix-like:
    * unqualifiedExecutables: get searched along the pathDir (PATH) in the order supplied, if not
      found an error gets raised
    * relativeExecutables: the supplied information gets appended to currDir (current working
      directory) and denotes the exact location of the executable, no further searches are
      undertaken and if not found an error gets raised
    * absoluteExecutables: denotes the exact location of the executable, no further searches are
      undertaken and if not found an error gets raised

  * Windows:
      o unqualifiedExecutables:
          + first the current working directory gets searched for it and if not found
          + search along the pathDir (PATH) in the order supplied, if not found an error gets raised
      o relativeExecutables: the supplied information gets appended to currDir (current working
        directory) and denotes the exact location of the executable, no further searches are
        undertaken and if not found an error gets raised
      o absoluteExecutables: denotes the exact location of the executable, no further searches are
        undertaken and if not found an error gets raised

So the resolution of executables is the same on Unix and Windows except for Windows first searching 
currDir (the current working directory) in the case of unqualifiedExecutables.

---

 - Conclusion #1: if relativeExecutables get searched and are not found relative to the current working 
directory, then no further search takes place and an error gets raised! This is how the operating 
systems behave, no matter whether using a shell/terminal or system services.

 - Conclusion #2: if non-operating system software behaves differently then the operating system then 
this is the responsibility of that software and needs to be documented. E.g. the observation that a 
compiler like gcc will use the paths in some environment variables in a different manner (e.g. using 
the value of the INCLUDE environment variable for locating c/cpp include files), does not 
define/determine/change how PATH should get used for locating unqualifiedExecutables.

 - Conclusion #3: if a Rexx CALL, that causes an external search, or an ooRexx ::requires directive 
(the first time encountered will cause a CALL of the denoted external file) get executed then the 
following rules (should) apply:

  * Rexx programs that are unqualifiedExecutables:
      o srcDir gets searched first and if not found
      o the operating system search for unqualifiedExecutables gets carried out next and if not
        found an error gets raised
  * Rexx programs that are relativeExecutables: the supplied information gets appended to currDir
    (current working directory) and denotes the exact location of the Rexx program, no further
    searches are undertaken and if not found an error gets raised
  * Rexx programs that are absoluteExecutables: denotes the exact location of the Rexx program, no
    further searches are undertaken and if not found an error gets raised

Given these findings and conclusions it is probably a misconception of expecting Rexx/ooRexx to 
behave like gcc (when employing the INCLUDE environment variable directories), rather than like 
operating systems resolve PATH.

In the case of Rexx/ooRexx the documentation defines for unqualifiedExecutables to first search 
srcDir and then pathDir. (Probably it needs to be improved w.r.t. to the above as currently one can 
observe quite some confusion even among long-time users while discussing this issue.)
