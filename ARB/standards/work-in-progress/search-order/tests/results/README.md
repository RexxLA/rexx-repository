# A collection of test results related to the Search Order problem

### Reports

* [Search order in Regina vs. ooRexx](Regina-vs-ooRexx.md)
* [A detailed comparison between OS/2 (REXXSAA, OBJREXX and Regina), Windows (ooRexx and Regina) and Ubuntu (ooRexx and Regina)](OS2(REXXSAA,OBJREXX,Regina),Windows(ooRexx,Regina),Ubuntu(ooRexx,Regina).md)

### Tools

* [compare.rex](compare.rex) -- Quick & dirty program to compare two result sets
* [SearchPath.exe](SearchPath.exe) -- Try the SearchPath Windows API from the command line.

### Results of running `sotest.rex`

* [OS/2 OBJREXX](os2.objrexx.results.rex)
* [OS/2 Regina](os2.regina.results.rex)
    * Results are identical to the [Windows CMD Search Order](windows.cmd.results.txt), to [Ubuntu Regina](ubuntu.regina.results.rex) and to [Windows Regina](windows.regina.results.rex)
* [OS/2 REXXSAA](os2.rexxsaa.results.rex)
* [OS/2 REXXSAA, with the SAA bug fixed (manually created)](os2.rexxsaa.fixed.results.rex)
* [Ubuntu ooRexx](ubuntu.oorexx.results.rex)
    * Results are identical to [Windows ooRexx (without the hasDirectory bug)](windows.oorexx-5.1.0-beta-r12651.results.rex)
* [Ubuntu Regina](ubuntu.regina.results.rex)
    * Results are identical to the [Windows CMD Search Order](windows.cmd.results.txt), to [OS/2 Regina](os2.regina.results.rex) and to [Windows Regina](windows.regina.results.rex)
* [Windows ooRexx 5.0.0](windows.oorexx-5.0.0.results.txt)
* [Windows ooRexx (without the hasDirectory bug)](windows.oorexx-5.1.0-beta-r12651.results.rex)
    * Results are identical to [Ubuntu ooRexx](ubuntu.oorexx.results.rex)
* [Windows Regina](windows.regina.results.rex)
    * Results are identical to the [Windows CMD Search Order](windows.cmd.results.txt), to [OS/2 Regina](os2.regina.results.rex) and to [Ubuntu Regina](ubuntu.regina.results.rex)

### Results of testing the CMD Search Order

* [Windows CMD Search Order](windows.cmd.results.rex)
    * Results are identical to [Regina](windows.regina.results.rex)

### Results of the Windows SearchPath API (1st parameter="same directory;.;path"; 2nd parameter=filename; 3rd parameter=".rex")

* [Windows SearchPath API resolution](windows.SearchPath.results.txt) 
    * Results are identical to [Windows ooRexx (without the hasDirectory bug)](windows.oorexx-5.1.0-beta-r12651.results.rex)

