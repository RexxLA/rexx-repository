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


| Code | Meaning |
| ---  | ---|
| 🔴 | Regina interrupts the search algorithm when there is a path separator in the file name. Only the current directory is searched.<br>"Note that the search algorithm to this point is ignored if the program name contains a file path specification. eg. if "CALL .\MYPROG" is called, then no searching of REGINA_MACROS or PATH is done; only the concatenation of suffixes is carried out."<br>This seems not to apply when the file name starts with a drive.<br>Creates the `0 0 1 1 0 0` vertical pattern.|
| 🔵 | This language processor does not have the concept of "same directory"<br>Creates the `0 0 x x x x` vertical pattern. |
| 🟢 | REXXSAA does not have the concept of "same extension", and the default extension is `.cmd`.<br>Creates the `0 x 0 x 0 x` vertical pattern. |
| 🟣 | Divergence between the Windows and Ubuntu versions of ooRexx. Probably a bug. |

* "SAA" refers to the IBM REXXSAA interpreter for OS/2 (version Arca Noae 5.0.7), version string is "REXXSAA 4.00 3 Feb 1999".
* "OBJ" refers to the IBM Object Rexx Interpreter for OS/2 (version Arca Noae 5.0.7), version string is "OBJREXX 6.00 18 May 1999".
* "REG" refers to the Regina Rexx Interpreter, under OS/2 (version Arca Noae 5.0.7, version string "REXX-Regina_3.9.5(MT) 5.00 25 Jun 2022"), Windows (Windows 11 Pro, version string "REXX-Regina_3.9.5(MT) 5.00 25 Jun 2022") and Linux (Ubuntu 22.04.01 LTS, version string "REXX-Regina_3.9.5 5.00 25 Jun 2022").
* "OOR" refers to the Open Object Rexx Interpreter under Windows (Windows 11 Pro, version string "REXX-ooRexx\_5.0.0(MT)\_64-bit 6.05") and Linux (Ubuntu 22.04.01 LTS, version string "REXX-ooRexx\_5.0.0(MT)\_64-bit 6.05").
* "Some" means that some of the previous tests has passed for this call variation. Some = 0 when all the tests failed.

## Common tests

### Same (caller), current and path directories.

| Call   | SAA | OBJ | REG | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---  |---|
| `same` | 0 | 0 | 0 | 1 | **1** ||
| `same.rex` | 0 | 0 | 0 | 1 | **1** ||
| `curr` | 0 | 1 | 1 | 1 | **1** ||
| `curr.rex` | 1 | 1 | 1 | 1 | **1** ||
| `path` | 0 | 1 | 1 | 1 | **1** ||
| `path.rex` | 1 | 1 | 1 | 1 | **1** ||

### Downward-relative calls

| Call   | SAA | OBJ | REG | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---  |---|
| `lib\samelib` | 0 | 0 | 0 | 1 | **1** ||
| `lib\samelib.rex` | 0 | 0 | 0 | 1 | **1** ||
| `lib\currlib` | 0 | 1 | 1 | 1 | **1** ||
| `lib\currlib.rex` | 1 | 1 | 1 | 1 | **1** ||
| `lib\pathlib` | 0 | 1 | 0 | 1 | **1** ||
| `lib\pathlib.rex` | 0 | 1 | 0 | 1 | **1** ||

### Dot-relative calls

| Call   | SAA | OBJ | REG | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---  |---|
| `.\same` | 0 | 0 | 0 | 0 | **0** ||
| `.\same.rex` | 0 | 0 | 0 | 0 | **0** ||
| `.\curr` | 0 | 1 | 1 | 1 | **1** ||
| `.\curr.rex` | 1 | 1 | 1 | 1 | **1** ||
| `.\path` | 0 | 1 | 0 | 0 | **1** ||
| `.\path.rex` | 0 | 1 | 0 | 0 | **1** ||

### Upward-relative calls

| Call   | SAA | OBJ | REG | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---  |---|
| `..\dotdotsame` | 0 | 0 | 0 | 0 | **0** ||
| `..\dotdotsame.rex` | 0 | 0 | 0 | 0 | **0** ||
| `..\dotdotcurr` | 0 | 1 | 1 | 1 | **1** ||
| `..\dotdotcurr.rex` | 1 | 1 | 1 | 1 | **1** ||
| `..\dotdotpath` | 0 | 1 | 0 | 0 | **1** ||
| `..\dotdotpath.rex` | 0 | 1 | 0 | 0 | **1** ||

### Upward-relative calls with a trick

| Call   | SAA | OBJ | REG | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---  |---|
| `lib\..\..\dotdotsame` | 0 | 0 | 0 | 1 | **1** ||
| `lib\..\..\dotdotsame.rex` | 0 | 0 | 0 | 1 | **1** ||
| `lib\..\..\dotdotcurr` | 0 | 1 | 1 | 1 | **1** ||
| `lib\..\..\dotdotcurr.rex` | 1 | 1 | 1 | 1 | **1** ||
| `lib\..\..\dotdotpath` | 0 | 1 | 0 | 1 | **1** ||
| `lib\..\..\dotdotpath.rex` | 0 | 1 | 0 | 1 | **1** ||

## Windows- and OS/2-only tests

### Slash-relative calls

| Call   | SAA | OBJ | REG | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---  |---|
| `\sotest\subdir\dotdotsame\same\same` | 0 | 0 | 0 | 0 | **0** ||
| `\sotest\subdir\dotdotsame\same\same.rex` | 0 | 0 | 0 | 0 | **0** ||
| `\dotdotcurr` | 0 | 1 | 1 | 1 | **1** ||
| `\dotdotcurr.rex` | 1 | 1 | 1 | 1 | **1** ||
| `\dotdotpath` | 0 | 0 | 0 | 0 | **0** ||
| `\dotdotpath.rex` | 0 | 0 | 0 | 0 | **0** ||

### Drive-relative calls

| Call   | SAA | OBJ | REG | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---  |---|
| `D:lib\samelib` | 0 | 0 | 0 | 0 | **0** ||
| `D:lib\samelib.rex` | 0 | 0 | 0 | 0 | **0** ||
| `Z:curr\curr` | 0 | 1 | 1 | 1 | **1** ||
| `Z:curr\curr.rex` | 1 | 1 | 1 | 1 | **1** ||
| `Y:path\path` | 0 | 1 | 1 | 1 | **1** ||
| `Y:path\path.rex` | 1 | 1 | 1 | 1 | **1** ||

### Absolute calls

| Call   | SAA | OBJ | REG | OOR | Some| Comments   |
|---     |---  |---  |---  |---  |---  |---|
| `D:\sotest\subdir\dotdotsame\same\same` | 0 | 1 | 1 | 1 | **1** ||
| `D:\sotest\subdir\dotdotsame\same\same.rex` | 1 | 1 | 1 | 1 | **1** ||
| `Z:\curr\curr` | 0 | 1 | 1 | 1 | **1** ||
| `Z:\curr\curr.rex` | 1 | 1 | 1 | 1 | **1** ||
| `Y:\path\path` | 0 | 1 | 1 | 1 | **1** ||
| `Y:\path\path.rex` | 1 | 1 | 1 | 1 | **1** ||

# OLD RESULTS

### Same (caller), current and path directories.

| Call | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | |
| | *SAA*<br>🔵🟢 | *OBJR*<br>🔵 | *Reg*<br>🔵 | *ooR* | *Reg*<br>🔵 | *ooR* | *Reg*<br>🔵 |  | |
| `same` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** |  |
| `same.rex` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** |  |
| `curr` | 0 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `curr.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `path` | 0 | 1 | 1 | 1 | 1 | 1 | 1 | **1** |  |
| `path.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |

### Downward-relative calls

| Call | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | |
| | *SAA*<br>🔵🟢 | *OBJR*<br>🔵 | *Reg*<br>🔵🔴 | *ooR* | *Reg*<br>🔵🔴 | *ooR* | *Reg*<br>🔵🔴 |  | |
| `lib\samelib` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** |  |
| `lib\samelib.rex` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** |  |
| `lib\currlib` | 0 | 1 | 1 | 1 | 1 | 1 | 1 | **1** |  |
| `lib\currlib.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** |   |
| `lib\pathlib` | 0 | 1 | 0 | 1 | 0 | 1 | 0 | **1** | REXXSAA seems to limit the search to the current directory because there is a "\\" character |
| `lib\pathlib.rex` | 0 | 1 | 0 | 1 | 0 | 1 | 0 | **1** | REXXSAA seems to limit the search to the current directory because there is a "\\" character |

### Dot-relative calls

| Call | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | |
| | *SAA*<br>🔵🟢 | *OBJR*<br>🔵 | *Reg*<br>🔵🔴 | *ooR* | *Reg*<br>🔵🔴 | *ooR* | *Reg*<br>🔵🔴 |  | |
| `.\same` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** |  |
| `.\same.rex` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** |  |
| `.\curr` | 0 | 1 | 1 | 1 | 1 | 1 | 1 | **1** |  |
| `.\curr.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `.\path` | 0 | 1 | 0 | 0 | 0 | 0 | 0 | **1** | REXXSAA and ooRexx stop the search and limit it to the current directory in the `.\` case<br>Only OBJREXX has love for `.\` applied to the `PATH`  |
| `.\path.rex` | 0 | 1 | 0 | 0 | 0 | 0 | 0 | **1** | REXXSAA and ooRexx stop the search and limit it to the current directory in the `.\` case<br>Only OBJREXX has love for `.\` applied to the `PATH`  |

**Additional comments**: It's interesting to see that OBJREXX does check `.\path.rex` against the directories of the `PATH`.

### Dotdot-relative calls

| Call | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | |
| | *SAA*<br>🔵🟢 | *OBJR*<br>🔵 | *Reg*<br>🔵🔴 | *ooR* | *Reg*<br>🔵🔴 | *ooR* | *Reg*<br>🔵🔴 |  | |
| `..\dotdotsame` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** | REXXSAA, ooRexx and Regina stop the search and limit it to the current directory in the `..\` case|
| `..\dotdotsame.rex` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** | REXXSAA, ooRexx and Regina stop the search and limit it to the current directory in the `.\` case|
| `..\dotdotcurr` | 0 | 1 | 1 | 0 | 1 | 1 | 1 | **1** | 🟣 |
| `..\dotdotcurr.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `..\dotdotpath` | 0 | 1 | 0 | 0 | 0 | 0 | 0 | **1** | REXXSAA and ooRexx stop the search and limit it to the current directory in the `.\` case<br>Only OBJREXX has love for `..\` applied to the `PATH` |
| `..\dotdotpath.rex` | 0 | 1 | 0 | 0 | 0 | 0 | 0 | **1** | REXXSAA and ooRexx stop the search and limit it to the current directory in the `.\` case<br>Only OBJREXX has love for `..\` applied to the `PATH` |

### Dotdot-relative calls, with a trick

| Call | (1) | (2) | (3) | (4) | (5) | (6) | (7) | **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* | *Ubu* | *Ubu* |  | |
| | *SAA*<br>🔵🟢 | *OBJR*<br>🔵 | *Reg*<br>🔵🔴 | *ooR* | *Reg*<br>🔵🔴 | *ooR* | *Reg*<br>🔵🔴 |  | | 
| `lib\..\..\dotdotsame` | 0 | 0 | 0 | 0 | 0 | 1 | 0 | **1** | 🟣 |
| `lib\..\..\dotdotsame.rex` | 0 | 0 | 0 | 1 | 0 | 1 | 0 | **1** | |
| `lib\..\..\dotdotcurr` | 0 | 1 | 1 | 0 | 1 | 1 | 1 | **1** | 🟣 |
| `lib\..\..\dotdotcurr.rex` | 1 | 1 | 1 | 1 | 1 | 1 | 1 | **1** | |
| `lib\..\..\dotdotpath` | 0 | 1 | 0 | 0 | 0 | 1 | 0 | **1** | 🟣 |
| `lib\..\..\dotdotpath.rex` | 0 | 1 | 0 | 1 | 0 | 1 | 0 | **1** | |

## Windows- and OS/2-only tests

### Slash-relative calls

| Call | (1) | (2) | (3) | (4) | (5) |  **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* |   | | 
| | *SAA*<br>🔵🟢 | *OBJR*<br>🔵 | *Reg*<br>🔵🔴 | *ooR* | *Reg*<br>🔵🔴 |  | | 
| `\sotest\subdir\dotdotsame\same\same` | 0 | 0 | 0 | 0 | 0  | **0** | |
| `\sotest\subdir\dotdotsame\same\same.rex` | 0 | 0 | 0 | 0 | 0  | **0** | |
| `\dotdotcurr` | 0 | 1 | 1 | 1 | 1  | **1** | |
| `\dotdotcurr.rex` | 1 | 1 | 1 | 1 | 1  | **1** | |
| `\dotdotpath` | 0 | 0 | 0 | 0 | 0 |  **0** | |
| `\dotdotpath.rex` | 0 | 0 | 0 | 0 | 0  | **0** | |

### Drive-relative calls

| Call | (1) | (2) | (3) | (4) | (5) |  **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* |   | | 
| | *SAA*<br>🔵🟢 | *OBJR*<br>🔵 | *Reg*<br>🔵 | *ooR* | *Reg*<br>🔵 |  | | 
| `D:lib\samelib` | 0 | 0 | 0 | 0 | 0  | **0** | |
| `D:lib\samelib.rex` | 0 | 0 | 0 | 0 | 0  | **0** | |
| `Z:curr\curr` | 0 | 1 | 1 | 1 | 1 |  **1** | |
| `Z:curr\curr.rex` | 1 | 1 | 1 | 1 | 1  | **1** | |
| `Y:path\path` | 0 | 1 | 1 | 1 | 1 |  **1** |  |
| `Y:path\path.rex` | 1 | 1 | 1 | 1 | 1 | **1** | |

### Absolute calls

| Call | (1) | (2) | (3) | (4) | (5) |  **Some** | Comments |
| ---    | --- | --- | --- | --- | --- | --- | --- |
| | *OS/2* | *OS/2* | *OS/2* | *Win* | *Win* |   | | 
| | *SAA*<br>🟢 | *OBJR*<br> | *Reg*<br> | *ooR* | *Reg*<br> |  | | 
| `D:\sotest\subdir\dotdotsame\same\same` | 0 | 1 | 1 | 1 | 1  | **1** |  |
| `D:\sotest\subdir\dotdotsame\same\same.rex` | 1 | 1 | 1 | 1 | 1  | **1** | |
| `Z:\curr\curr` | 0 | 1 | 1 | 1 | 1 |  **1** |  |
| `Z:\curr\curr.rex` | 1 | 1 | 1 | 1 | 1 | **1** | |
| `Y:\path\path` | 0 | 1 | 1 | 1 | 1 |  **1** |  |
| `Y:\path\path.rex` | 1 | 1 | 1 | 1 | 1 | **1** | |
