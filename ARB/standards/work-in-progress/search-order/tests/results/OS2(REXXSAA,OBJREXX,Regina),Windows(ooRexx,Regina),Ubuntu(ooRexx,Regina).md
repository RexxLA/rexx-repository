That's a work-in-progress, still editing this file -- Josep Maria Blasco

<pre><code>
The test program is distributed as a zip file. It implements the following structure.
    
(<b>Root</b> directory. Normally, "sotest")
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
                                   +---> pathlib.rex (Returns "pathlib"
</code></pre>

Legend

1. OS/2 (Arca Noae 5.0.7), REXXSAA 4.00 3 Feb 1999.
2. OS/2 (Arca Noae 5.0.7), OBJREXX 6.00 18 May 1999.
3. OS/2 (Arca Noae 5.0.7), REXX-Regina_3.9.5(MT) 5.00 25 Jun 2022
4. Windows (Win 11 Pro), REXX-ooRexx_5.1.0(MT)\_64-bit 6.05 27 Jan 2023
5. Windows (Win 11 Pro), REXX-Regina_3.9.5(MT) 5.00 25 Jun 2022
6. Ubuntu (22.04 LTS), REXX-ooRexx_5.0.0(MT)\_64-bit 6.05 23 Dec 2022
7. Ubuntu (22.04 LTS), REXX-Regina_3.9.5 5.00 25 Jun 2022

"Some" means that some of the previous tests has passed for this call variation. Some = 0 when all the tests failed.

## Common tests

### Same (caller), current and path directories.

| Called | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
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

| Called | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
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

| Called | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
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

| Called | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | |
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* | *ooR* | *Reg* |  | |
| `..\dotdotsame` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** | |
| `..\dotdotsame.rex` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** | |
| `..\dotdotcurr` | 0 | 1 | 1 | 0 | 1 | 1 | 1 | **1** | |
| `..\dotdotcurr.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `..\dotdotpath` | 0 | 1 | 0 | 0 | 0 | 0 | 0 | **1** | |
| `..\dotdotpath.rex` | 0 | 1 | 0 | 0 | 0 | 0 | 0 | **1** | |

### Dotdot-relative calls, with a trick

| Called | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | | |
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* | *ooR* | *Reg* |  | | |
| `lib\..\..\dotdotsame` | 0 | 0 | 0 | 0 | 0 | 1 | 0 | **1** | |
| `lib\..\..\dotdotsame.rex` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** | |
| `lib\..\..\dotdotcurr` | 0 | 1 | 1 | 0 | 1 | 1 | 1 | **1** | |
| `lib\..\..\dotdotcurr.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `lib\..\..\dotdotpath` | 0 | 1 | 0 | 0 | 0 | 1 | 0 | **1** | |
| `lib\..\..\dotdotpath.rex` | 0 | 1 | 0 | 1 | 0 | 1 | 0 | **1** | |

## Windows- and OS/2-only tests

### Slash-relative calls

| Called | (1) | (2) | (3) | (4) | (5) |  **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* |   | | 
| | *SAA* | *OBJR* | *Reg* | *ooR* | *Reg* |  | | 
| \\sotest\\subdir\\dotdotsame\\same\\same | 0 | 0 | 0 | 0 | 0  | **0** | |
| \\sotest\\subdir\\dotdotsame\\same\\same.rex | 0 | 0 | 0 | 0 | 0  | **0** | |
| \\dotdotcurr | 0 | 1 | 1 | 1 | 1  | **1** | |
| \\dotdotcurr.rex | 1 | 1 | 1 | 1 | 1  | **1** | |
| \\dotdotpath | 0 | 0 | 0 | 0 | 0 |  **0** | |
| \\dotdotpath.rex | 0 | 0 | 0 | 0 | 0  | **0** | |

### Drive-relative calls

| Called | (1) | (2) | (3) | (4) | (5) |  **Some** |
| ---    | --- | --- | --- | --- | --- | --- |
| D:lib\\samelib | 0 | 0 | 0 | 0 | 0  | **0** |
| D:lib\\samelib.rex | 0 | 0 | 0 | 0 | 0  | **0** |
| Z:curr\\curr | 0 | 1 | 1 | 1 | 1 |  **1** |
| Z:curr\\curr.rex | 1 | 1 | 1 | 1 | 1  | **1** |
| Y:path\\path | 0 | 1 | 1 | 1 | 1 |  **1** |
| Y:path\\path.rex | 1 | 1 | 1 | 1 | 1 | **1** |

### Absolute calls

| Called | (1) | (2) | (3) | (4) | (5) |  **Some** |
| ---    | --- | --- | --- | --- | --- | --- |
| D:\\sotest\\subdir\\dotdotsame\\same\\same | 0 | 1 | 1 | 1 | 1  | **1** |
| D:\\sotest\\subdir\\dotdotsame\\same\\same.rex | 1 | 1 | 1 | 1 | 1  | **1** |
| Z:\\curr\\curr | 0 | 1 | 1 | 1 | 1 |  **1** |
| Z:\\curr\\curr.rex | 1 | 1 | 1 | 1 | 1 | **1** |
| Y:\\path\\path | 0 | 1 | 1 | 1 | 1 |  **1** |
| Y:\\path\\path.rex | 1 | 1 | 1 | 1 | 1 | **1** |
