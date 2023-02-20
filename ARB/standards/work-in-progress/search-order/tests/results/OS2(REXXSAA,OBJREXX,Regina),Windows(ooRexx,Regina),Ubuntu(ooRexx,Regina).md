That's a work-in-progress, still editing this file -- Josep Maria Blasco

The test program is distributed as a zip file implementing the structure shown below. The test initiator program, `sotest.rex`, calls immediately `./subdir/dotdotsame/same/same.rex`, to be able to set the "same" (or caller) directory in a convenient place. This has to be done manually, by patching the value returned from `Parse Source`, since we can not know whether a filename of the form `".\"` will work or not for a call (that's one of the things we are trying to find out in our test).

Similarly, we save and modify the current directory (by using the `Directory()` BIF) so that it is `./subdir/dotdotcurr/curr`, and we save and modify the value of the `PATH` variable so that it has a single directory, `./subdir/dotdotpath/path`.

This directory structure and this setting of the caller's, current and path directories allow us to thoroughly test many variations of the `Call`instruction.

<pre><code>   
(<b>Root</b> directory. Normally, "sotest")
   |
   +---> sotest.rex (The test initiator program. Calls ./subdir/dotdotsame/same/same.rex)
   |
   +---> <b>subdir</b> (Dummy directory, for future expansion)
           |
           +---> <b>dotdotsame</b> (The parent of the "same"or caller directorY)
           |       |
           |       +---> dotdotsame.rex (Returns "dotdotsame")
           |       |
           |       +---> <b>same</b> (The "same" or caller directory)
           |               |
           |               +---> same.rex (The program in the "same" or
           |               |               caller directory. Returns "same")
           |               +---> main.rex (The main program)
           |               |
           |               +---> <b>lib</b>
           |                       |
           |                       +---> samelib.rex (Returns "samelib")
           |
           +---> <b>dotdotcurr</b> (The parent of the current directory)
           |       |
           |       +---> dotdotcurr.rex (Returns "dotdotcurr")
           |       |
           |       +---> <b>curr</b> (The current directory)
           |               |
           |               +---> curr.rex (The program in the current
           |               |               directory. Returns "curr")
           |               +---> oorexxextensions (Extensionless. Returns
           |               |               "directory")
           |               +---> reginaextensions.rex (Returns
           |               |               "directory")
           |               +---> <b>lib</b>
           |                       |
           |                       +---> currlib.rex (Returns "currlib")
           |
           +---> <b>dotdotpath</b>
                   |
                   +---> dotdotpath.rex (Returns "dotdotpath")
                   |
                   +---> <b>path</b>
                           |
                           +---> path.rex (The program in the path
                           |               directory. Returns "path")
                           +---> oorexxextensions.rex (Returns
                           |               "extension")
                           +---> reginaextensions.rexx (Returns
                           |               "extension")
                           +---> <b>lib</b>
                                   |
                                   +---> pathlib.rex (Returns "pathlib")
</code></pre>

## Methodology

The same test program was run under several operating systems, and under several interpreters.

#### Operating systems tested

1) OS/2 (actually, Arca Noae 5.0.7). We will use the label **OS2** to refer to this operating system.
2) Windows (actually, Windows 11 Pro). We will use the label **Windows** to refer to this operating system.
3) Linux (actually, Ubuntu 22.04.01 LTS). We will use the label **Linux** to refer to this operating system.

#### Interpreters tested

1) For OS2
    * The IBM REXXSAA interpreter ("REXXSAA 4.00 3 Feb 1999"). We will use the label **REXXSAA** to refer to this interpreter.
    * The IBM Object Rexx interpreter ("OBJREXX 6.00 18 May 1999"). We will use the label **OBJREXX** to refer to this interpreter.
    * The Regina REXX interpreter ("REXX-Regina_3.9.5(MT) 5.00 25 Jun 2022"). We will use the collective label **Regina** to refer to all the Regina REXX interpreters, since the results are the same, independently of the operating system.
2) For Windows
    * The Regina REXX interpreter ("REXX-Regina_3.9.5(MT) 5.00 25 Jun 2022"). We will use the collective label **Regina** to refer to all the Regina REXX interpreters, since the results are the same, independently of the operating system.
    * The ooRexx interpreter ("REXX-ooRexx\_5.0.0(MT)\_64-bit 6.05"). We will use the collective label **ooRexx** to refer to all the ooRexx interpreters, since the results, modulo [the hasDirectory bug](#the-hasdirectory-bug), are the same, independently of the operating system.
3) For Linux
    * The Regina REXX interpreter ("REXX-Regina_3.9.5 5.00 25 Jun 2022"). We will use the collective label **Regina** to refer to all the Regina REXX interpreters, since the results are the same, independently of the operating system.
    * The ooRexx interpreter ("REXX-ooRexx\_5.0.0(MT)\_64-bit 6.05"). We will use the collective label **ooRexx** to refer to all the ooRexx interpreters, since the results, modulo [the hasDirectory bug](#the-hasdirectory-bug), are the same, independently of the operating system.

#### The SAA bug

The REXXSAA interpreter for OS/2 does not work [as described](../../documents/external-search-order-in-rexxsaa-for-os2.md). It should search first for "REXX functions in the current directory, with the current extension", and then for "REXX functions along environment PATH, with the current extension"; it does not, but searches for "the default extension" instead (`.CMD`). We will use the expression "**the SAA bug**" to refer to this behaviour.

#### The hasDirectory bug

OORexx for Windows has a bug in the Windows version of the SysFileSystem::hasExtension routine (a routine that determines whether a filename has or not an extension, and then takes decisions regarding the search order): it searches for the Unix separator, "/", instead of the Windows separator ("\\"). The bug (reported [here](https://sourceforge.net/p/oorexx/bugs/1870/)) has passed largely unnoticed because it is difficult to trigger: one needs a filename of the form `my.path\filename`, where the path has a dot in it and the filename does not (this includes, but is not limited to, the `..\filename` and `.\file` cases). We have produced a (trivial) patch for this bug, and we are presenting the results as if the patch were already applied. Otherwise, we would find a discrepancy between the results of the test under Windows and under Ubuntu.

#### The notion of "same" directory

Between all the interpreters tested, OORexx is the only one to suport the notion of the "same" (or caller) directory.

#### REXXSAA and Regina

Modulo [the SAA bug](#the-saa-bug), the results for REXXSAA and Regina (see below) are identical. They have been grouped under a single category, labeled "NOB" (No OBject-oriented versions of the interpreters)

#### Abbreviations

In the following tables,

* "NOB" refers to both the REXXSAA and the Regina interpreters, since (modulo [the SAA bug](#the-saa-bug)) they produce exactly the same results under our tests.
* "OBJ" refers to the OBJREXX interpreter.
* "OOR" refers to the ooRexx interpreter.
* "Some" means that some of the previous tests has passed for this call variation. Some = 0 when all the tests failed, for all the interpreters tested.

## Common tests

### Same (caller), current and path directories.

| Call   | NOB | OBJ | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---         |
| `same` | 0 | 0 | 1 | **1** |
| `same.rex` | 0 | 0 | 1 | **1** |
| `curr` | 1 | 1 | 1 | **1** |
| `curr.rex` | 1 | 1 | 1 | **1** |
| `path` | 1 | 1 | 1 | **1** |
| `path.rex` | 1 | 1 | 1 | **1** |

OORexx is the only interpreter that searches in the "same", or caller, directory.

### Downward-relative calls

| Call   | NOB | OBJ | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---         |
| `lib\samelib` | 0 | 0 | 1 | **1** |
| `lib\samelib.rex` | 0 | 0 | 1 | **1** |
| `lib\currlib` | 1 | 1 | 1 | **1** |
| `lib\currlib.rex` | 1 | 1 | 1 | **1** |
| `lib\pathlib` | 0 | 1 | 1 | **1** |
| `lib\pathlib.rex` | 0 | 1 | 1 | **1** |

Modulo [the SAA bug](#the-saa-bug), we can classify the interpreters in three categories: those that search only in the current directory (REXXSAA and Regina, i.e., those grouped under the "NOB" label), those that search in the current directory and in the `PATH` (OBJREXX), and those that, additionally, search first of all in the "same" or caller directory (ooRexx).

### Dot-relative calls

| Call   | NOB | OBJ | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---         |
| `.\same` | 0 | 0 | 0 | **0** |
| `.\same.rex` | 0 | 0 | 0 | **0** |
| `.\curr` | 1 | 1 | 1 | **1** |
| `.\curr.rex` | 1 | 1 | 1 | **1** |
| `.\path` | 0 | 1 | 0 | **1** |
| `.\path.rex` | 0 | 1 | 0 | **1** |

Dot-relative call tests produce a matrix which is almost identical to the downward-relative calls; modulo [the SAA bug](#the-saa-bug), the "NOB" group (i.e., REXXSAA and Regina) exhibit the same behaviour (they only search in the current directory). The only test result matrix difference appears when the ooRexx interpreter is being tested: the ooRexx directory exception algorithm skips ".\file", and does not search the same directory or the `PATH`. It's interesting to note that OBJREXX _does_ search in the `PATH` in this case.

### Upward-relative calls

| Call   | NOB | OBJ | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---         |
| `..\dotdotsame` | 0 | 0 | 0 | **0** |
| `..\dotdotsame.rex` | 0 | 0 | 0 | **0** |
| `..\dotdotcurr` | 1 | 1 | 1 | **1** |
| `..\dotdotcurr.rex` | 1 | 1 | 1 | **1** |
| `..\dotdotpath` | 0 | 1 | 0 | **1** |
| `..\dotdotpath.rex` | 0 | 1 | 0 | **1** |

Dot-relative call tests produce a matrix which is almost identical to the downward-relative calls, and completely identical to the dot-relative calls; modulo [the SAA bug](#the-saa-bug), the "NOB" group (i.e.,  REXXSAA and Regina) exhibit the same behaviour (they only search in the current directory). The only test result matrix difference appears when the ooRexx interpreter is being tested: the ooRexx directory exception algorithm skips "..\file", and does not search the same directory or the `PATH`. It's interesting to note that OBJREXX _does_ search in the `PATH` in this case.


### Upward-relative calls with a trick

| Call   | NOB | OBJ | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---         |
| `lib\..\..\dotdotsame` | 0 | 0 | 1 | **1** |
| `lib\..\..\dotdotsame.rex` | 0 | 0 | 1 | **1** |
| `lib\..\..\dotdotcurr` | 1 | 1 | 1 | **1** |
| `lib\..\..\dotdotcurr.rex` | 1 | 1 | 1 | **1** |
| `lib\..\..\dotdotpath` | 0 | 1 | 1 | **1** |
| `lib\..\..\dotdotpath.rex` | 0 | 1 | 1 | **1** |

The trick (go downwards first and then upwards twice) helps ooRexx to pass the tests, because ooRexx triggers the directory exception algorithm by inspecting _the first characters_ of the filename only, but does not help with the "NOB" group (i.e., REXXSAA and Regina), because they search for a path separator _in the whole filename_ (confirmed for Regina and true for REXXSAA according to reverse engineering).

## Windows- and OS/2-only tests

### Slash-relative calls

| Call   | NOB | OBJ | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---         |
| `\sotest\subdir\dotdotsame\same\same` | 0 | 0 | 0 | **0** |
| `\sotest\subdir\dotdotsame\same\same.rex` | 0 | 0 | 0 | **0** |
| `\dotdotcurr` | 1 | 1 | 1 | **1** |
| `\dotdotcurr.rex` | 1 | 1 | 1 | **1** |
| `\dotdotpath` | 0 | 0 | 0 | **0** |
| `\dotdotpath.rex` | 0 | 0 | 0 | **0** |

Although "\" is relative (to the current drive), no interpreter attempts to further relativize it.

### Drive-relative calls

| Call   | NOB | OBJ | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---         |
| `D:lib\samelib` | 0 | 0 | 0 | **0** |
| `D:lib\samelib.rex` | 0 | 0 | 0 | **0** |
| `Z:curr\curr` | 1 | 1 | 1 | **1** |
| `Z:curr\curr.rex` | 1 | 1 | 1 | **1** |
| `Y:path\path` | 1 | 1 | 1 | **1** |
| `Y:path\path.rex` | 1 | 1 | 1 | **1** |

The "same" tests do not pass for ooRexx, because the presence of the ":" character triggers the directory exception algorithm. The other tests all pass, even when the directory exception is triggered (by the presence of "\\" in the filename), because the search is redirected to the operating system, and the operating system knows how to handle such cases.

### Absolute calls

| Call   | NOB | OBJ | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---         |
| `D:\sotest\subdir\dotdotsame\same\same` | 1 | 1 | 1 | **1** |
| `D:\sotest\subdir\dotdotsame\same\same.rex` | 1 | 1 | 1 | **1** |
| `Z:\curr\curr` | 1 | 1 | 1 | **1** |
| `Z:\curr\curr.rex` | 1 | 1 | 1 | **1** |
| `Y:\path\path` | 1 | 1 | 1 | **1** |
| `Y:\path\path.rex` | 1 | 1 | 1 | **1** |

These tests always succeed and, in this sense, are somewhat redundant.

