# A list of tests, their results, and a partial interpretation of these results

(This is an updated version of [a post by Josep Maria Blasco in the rexxla-arb@groups.io list](https://groups.io/g/rexxla-arb/message/51).)

I've been testing the behaviour of several interpreters under several operating systems, 
the behaviour of the Windows ```CMD.EXE``` command line interpreter and the Windows ```SearchPath``` API. 
All the results are collected [here](../tests/results). 
A preliminary report with a first interpretation of the results 
can be found [here](../tests/results/OS2(REXXSAA%2COBJREXX%2CRegina)%2CWindows(ooRexx%2CRegina)%2CUbuntu(ooRexx%2CRegina).md). 

In this post, I will try a higher level attempt at an interpretation, 
and I will end by advocating the removal of the current limitations of the ooRexx interpreter.

## Bugs

In the process of testing, I've uncovered two bugs.

1. A bug in the REXXSAA (i.e., Classic Rexx) interpreter for OS/2, 
   where the extension of the caller is not searched, contrary to [the documentation](../external-search-order-in-rexxsaa-for-os2.md). We will refer to this bug as "the SAA bug".
2. A bug in the ooRexx interpreter for Windows, due to a typo in the ```SysFileSystem::hasExtension``` function. 
  This bug (which I have reported and for which I've provided a trivial patch) is difficult to trigger 
  (one needs an extensionless filename and a path which contains a dot, like ```"my.dir/file"```, 
  which will be taken to have an extension when it doesn't have one). We will refer to it as "the hasDirectory bug".  
  (**Update 20230310**) [5.1.0-beta-12651](https://sourceforge.net/p/oorexx/code-0/12651/) fixes that problem.
  
## Classification of results

I've executed nine tests: (1) for [Regina under OS/2](../tests/results/os2.regina.results.txt); (2) for [Regina under Windows](../tests/results/windows.regina.results.txt); (3) for [Regina under Ubuntu](../tests/results/ubuntu.regina.results.txt); (4) for [REXXSAA under OS/2](../tests/results/os2.rexxsaa.results.txt); (5) for [Object Rexx under OS/2](../tests/results/os2.objrexx.results.txt); (6) for ooRexx under Windows ([5.0.0](../tests/results/windows.oorexx-5.0.0.results.txt) and [5.1.0-12651](../tests/results/windows.oorexx-5.1.0-beta-r12651.results.txt)); (7) for [ooRexx under Ubuntu](../tests/results/ubuntu.oorexx.results.txt); (8); [Windows CMD](../tests/results/windows.cmd.results.txt); (9) [Windows SearchPath](../tests/results/windows.SearchPath.results.txt).

Here's an attempt to classify the results of these tests. Fortunately, several of these results are identical, or would be identical if the bugs mentioned earlier were first patched. This will allow us to group our nine results in only three groups.

## Group 1: The Classic Rexx Interpreters and Windows CMD

* The results for Regina are all identical (modulo the special tests that only make sense under Windows and OS/2, because they use drive letters).
* These results are also identical to the ones obtained when using the REXXSAA interpreter, 
  if we ignore the SAA bug, i.e., if we take the results that would have been obtained if the REXXSAA interpreter worked as documented.
* These four results are in turn identical to the behaviour of the CMD command line interpreter.

REXXSAA and Regina are older than OBJREXX and ooRexx. At the beginning, Rexx was being promoted as an alternative to other batch programming languages (EXEC and EXEC2 in VM, OS/2 CMD, a successor to BAT files, etc). It should not be surprising, then, that older versions of Rexx attempted to work in the very exact same way as the command line interpreters.

## Group 2: IBM Object Rexx for OS/2

Object Rexx for OS/2 constitutes a radical departure from the Classic Rexx interpreters and from the command line paradigm. The language is much more mature, and it includes methods (the ::REQUIRES directive)  to reference external program files (a "non-executable" directive, in the wording of [the Dallas version](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/historic/Extended_Rexx_Standard_Dallas_Version-1998.pdf)). Although Object Rexx for OS/2 lacks the concept of the "same" directory that we will later find in ooRexx, its support for an extended search order puts it more in the line of compiled languages like C or C++, where constructs like ```"#include ../dir/my.h"``` are usual, and they are checked against all the specified directories: under Object Rexx for OS/2, when you ```call``` (or ```::require```) ```"..\dir\my.rexx"```, Rexx will happily check each of the directories in the ```PATH``` environment variable, apart from the current one.

## Group 3: ooRexx and the SearchPath Windows API

ooRexx adds a new concept, the "same" directory, but in another aspect it incorporates a regression, compared to Object Rexx. Modulo the hasDirectory bug (now fixed in [5.1.0-12651](https://sourceforge.net/p/oorexx/code-0/12651/)), the behaviour of ooRexx is exactly the same as the behaviour of the Windows ```SearchPath``` API. There are several places in the code (for Windows) that reference this API: it should not be called when a filename starts with ```".\"``` or ```"..\"```, says the code, because it does not give the expected results (indeed, what it does is to completely fail and return zero). Correspondingly, the Windows ooRexx interpreter includes code so that, in the case where the filename starts with ```".\"``` or ```"..\"```, ```SearchPath``` is completely bypassed, and the filename is checked only against the current directory.

The Unix version of the interpreter has similar code. I can't see why, since (1) such precautions are not needed under Unix, where the filename resolution is made manually, by appending the filename supplied by the user to each of the directories in the extended path formed by the same directory, the current directory, the application-specific path, and the contents of the ```REXX_PATH``` and ```PATH``` environment variable; (2) if one removes this code, the interpreter works perfectly, and all the tests in the test suite pass (I've submitted a trivial patch to prove this as a proof-of-concept), and, most importantly, (3) the behaviour of the interpreter would then be similar to the behaviour of Object Rexx for OS/2, but with the added notion of the "same" directory: progress without regressions.

The only reason I can see why such a limitation has been added to the Linux version of the interpreter is to ensure that ooRexx works exactly in the same way under Windows and under Unix.

But this is, I think, not a very good decision. Meaning not that the two versions should diverge, but that the Windows version should not rely on this API. The way that things work under Windows is _horrible_. The ```SearchPath``` API (1) gives results that are different from the CLI, which is extremely unfortunate, and, specially (2) the ```SearchPath``` API is inconsistent, i.e., it refuses to search for ```"..\my.file"```, but it proceeds happily with ```"x\..\..\my.file"```, which, in addition, it considers to be identical to ```"..\my.file"``` _by a mere syntactical examination of the filename_, i.e., it doesn't even check whether the ```"x"``` directory exists.

This Is Not Good. We shouldn't want, I believe, to have to explain to our users that "filenames of this and that form are checked against all directories in the ```PATH```, but, look, filenames of that other form are only checked against the current directory".

Why not? Because of several reasons:

1. It looks like something arbitrary: some relative filenames work (for example, downward relative filenames, like ```"dir\my.file"````¡) and some don't (for example, upward-relative filenames, like ```"..\my.file"```). Why?
2. It imposes a limitation. Although it's unclear whether there is "a Rexx way" of doing things in this respect or not, I am not convinced that making some task impossible is a really good idea. Rexx should allow a maximum of possibilities, and let the user decide which ones to use.
3. It's not fixable, unless one renounces completely to use the ```::REQUIRES``` directive and uses instead dynamic APIs. If one wants to ```call```, say, a file in the parent directory of the "same" directory (i.e., any directory different from the current directory), one can always temporarily change the current directory to be the "same" directory, then ```call``` the file, and then reset the current directory to its original value; this is an ugly kludge, but it works, if you really need it. But you can't do a similar thing with ```::REQUIRES```, because of a very simple reason: ```::REQUIRES```  is evaluated before any code in your program is run, and this means that you will not have time to change the current directory to anything.
4. ```::Requiring``` a file indicates a logical relationship between pieces of a program. The concept of "same" directory (or even of the directories in a certain ```PATH``` or another environment variable) are more "natural" for such logical relationships than the concept of the current directory, which is a contingency, something which can be changed dynamically and which is effectively changed, and something normally completely unrelated to the relationship between pieces of code.
