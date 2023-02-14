That's a work-in-progress, still editing this file -- Josep Maria Blasco

The test program is distributed as a zip file implementing the structure shown below. The test initiator program, `sotest.rex`, calls immediately `./subdir/dotdotsame/same/same.rex`, to be able to set the "same" (or caller) directory. This has to be done manually, by patching the value returned from `Parse Source`, since we can not know whether a filename of the form `".\"` will work or not for a call (that's what we are trying to test).

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

Legend

| OS/2<br>*Arca Noae 5.0.7* | Windows<br>*Windows 11 Pro* | Ubuntu<br>*22.04.01 LTS* |
| --- | --- | --- |
| <ol><li>REXXSAA 4.00<br>3 Feb 1999</li><li>OBJREXX 6.00<br>18 May 1999.</li><li>REXX-Regina_3.9.5(MT) 5.00<br>25 Jun 2022</li></ol> | <ol start="4"><li>REXX-ooRexx_5.0.0(MT)_64-bit 6.05<br>23 Dec 2022<br>27 Jan 2023</li><li>REXX-Regina_3.9.5(MT) 5.00<br>25 Jun 2022</li></ol> | <ol start="6"><li>REXX-ooRexx_5.0.0(MT)\_64-bit 6.05<br>23 Dec 2022</li><li>REXX-Regina_3.9.5 5.00<br>25 Jun 2022</li></ol> |


"Some" means that some of the previous tests has passed for this call variation. Some = 0 when all the tests failed.

## Common tests

### Same (caller), current and path directories.

| Call | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | |
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* | *ooR* | *Reg* |  | |
| `same` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** | REXXSAA, OBJREXX and Regina do not have the concept of "same" (or caller) directory |
| `same.rex` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** | REXXSAA, OBJREXX and Regina do not have the concept of "same" (or caller) directory |
| `curr` | 0 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| `curr.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `path` | 0 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| `path.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |

### Downward-relative calls

| Call | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | |
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* | *ooR* | *Reg* |  | |
| `lib\samelib` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** | REXXSAA, OBJREXX and Regina do not have the concept of "same" (or caller) directory |
| `lib\samelib.rex` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** | REXXSAA, OBJREXX and Regina do not have the concept of "same" (or caller) directory |
| `lib\currlib` | 0 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| `lib\currlib.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** |   |
| `lib\pathlib` | 0 | 1 | 0 | 1 | 0 | 1 | 0 | **1** | REXXSAA seems to limit the search to the current directory because there is a "\\" character <br> Regina limits the search to the current directory because there is a "\\" character |
| `lib\pathlib.rex` | 0 | 1 | 0 | 1 | 0 | 1 | 0 | **1** | REXXSAA seems to limit the search to the current directory because there is a "\\" character <br> Regina limits the search to the current directory because there is a "\\" character |

### Dot-relative calls

| Call | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | |
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* | *ooR* | *Reg* |  | |
| `.\same` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** | REXXSAA, OBJREXX and Regina do not have the concept of "same" (or caller) directory <br> ooRexx limits the search to the current directory when the file name starts with `.\` or `./` |
| `.\same.rex` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** | REXXSAA, OBJREXX and Regina do not have the concept of "same" (or caller) directory <br> ooRexx limits the search to the current directory when the file name starts with `.\` or `./` |
| `.\curr` | 0 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| `.\curr.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `.\path` | 0 | 1 | 0 | 0 | 0 | 0 | 0 | **1** | REXXSAA, ooRexx and Regina stop the search and limit it to the current directory in the `.\` case |
| `.\path.rex` | 0 | 1 | 0 | 0 | 0 | 0 | 0 | **1** | REXXSAA, ooRexx and Regina stop the search and limit it to the current directory in the `.\` case |

**Additional comments**: It's interesting to see that OBJREXX does check `.\path.rex` against the directories of the `PATH`.

### Dotdot-relative calls

| Call | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | |
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* | *ooR* | *Reg* |  | |
| `..\dotdotsame` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** | |
| `..\dotdotsame.rex` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** | |
| `..\dotdotcurr` | 0 | 1 | 1 | 0 | 1 | 1 | 1 | **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| `..\dotdotcurr.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `..\dotdotpath` | 0 | 1 | 0 | 0 | 0 | 0 | 0 | **1** | Only OBJREXX has love for `..\` applied to the `PATH` |
| `..\dotdotpath.rex` | 0 | 1 | 0 | 0 | 0 | 0 | 0 | **1** | Only OBJREXX has love for `..\` applied to the `PATH`  |

### Dotdot-relative calls, with a trick

| Call | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | | |
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* | *ooR* | *Reg* |  | | |
| `lib\..\..\dotdotsame` | 0 | 0 | 0 | 0 | 0 | 1 | 0 | **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| `lib\..\..\dotdotsame.rex` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** | |
| `lib\..\..\dotdotcurr` | 0 | 1 | 1 | 0 | 1 | 1 | 1 | **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| `lib\..\..\dotdotcurr.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `lib\..\..\dotdotpath` | 0 | 1 | 0 | 0 | 0 | 1 | 0 | **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| `lib\..\..\dotdotpath.rex` | 0 | 1 | 0 | 1 | 0 | 1 | 0 | **1** | |

## Windows- and OS/2-only tests

### Slash-relative calls

| Call | (1) | (2) | (3) | (4) | (5) |  **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* |   | | 
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* |  | | 
| \\sotest\\subdir\\dotdotsame\\same\\same | 0 | 0 | 0 | 0 | 0  | **0** | |
| \\sotest\\subdir\\dotdotsame\\same\\same.rex | 0 | 0 | 0 | 0 | 0  | **0** | |
| \\dotdotcurr | 0 | 1 | 1 | 1 | 1  | **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| \\dotdotcurr.rex | 1 | 1 | 1 | 1 | 1  | **1** | |
| \\dotdotpath | 0 | 0 | 0 | 0 | 0 |  **0** | |
| \\dotdotpath.rex | 0 | 0 | 0 | 0 | 0  | **0** | |

### Drive-relative calls

| Call | (1) | (2) | (3) | (4) | (5) |  **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* |   | | 
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* |  | | 
| D:lib\\samelib | 0 | 0 | 0 | 0 | 0  | **0** | |
| D:lib\\samelib.rex | 0 | 0 | 0 | 0 | 0  | **0** | |
| Z:curr\\curr | 0 | 1 | 1 | 1 | 1 |  **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| Z:curr\\curr.rex | 1 | 1 | 1 | 1 | 1  | **1** | |
| Y:path\\path | 0 | 1 | 1 | 1 | 1 |  **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| Y:path\\path.rex | 1 | 1 | 1 | 1 | 1 | **1** | |

### Absolute calls

| Call | (1) | (2) | (3) | (4) | (5) |  **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* |   | | 
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* |  | | 
| D:\\sotest\\subdir\\dotdotsame\\same\\same | 0 | 1 | 1 | 1 | 1  | **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| D:\\sotest\\subdir\\dotdotsame\\same\\same.rex | 1 | 1 | 1 | 1 | 1  | **1** | |
| Z:\\curr\\curr | 0 | 1 | 1 | 1 | 1 |  **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| Z:\\curr\\curr.rex | 1 | 1 | 1 | 1 | 1 | **1** | |
| Y:\\path\\path | 0 | 1 | 1 | 1 | 1 |  **1** | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd` |
| Y:\\path\\path.rex | 1 | 1 | 1 | 1 | 1 | **1** | |
