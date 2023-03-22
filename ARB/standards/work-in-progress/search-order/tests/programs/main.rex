/*****************************************************************************
 *                                                                           *
 *  main.rex - Main routine for sotest.tex                                   *
 *                                                                           * 
 *  Version 1.0, 20230319                                                    *
 *                                                                           *
 *  Called from ../../../sotest.rex                                          * 
 *                                                                           * 
 *  WARNING:                                                                 *
 *                                                                           * 
 *  This program and its companion, sotest.rex, are carefully designed to    *
 *  run under REXXSAA for OS/2, Object Rexx for OS/2, ooRexx for Windows     *
 *  and Unixlike, and Regina for OS/2, Windows and Linux. Please be          *
 *  careful when modifying it, to ensure that no platform/interpreter        *
 *  combination is affected.                                                 *
 *                                                                           *   
 *  Written in 2023 by Josep Maria Blasco <josep.maria.blasco@epbcn.com>     *
 *                                                                           * 
 *****************************************************************************/

/*****************************************************************************
 *  This is for Regina: otherwise, when an external function is not found,   *
 *  the routine name is tried as a command.                                  *
 *****************************************************************************/
Options NOEXT_COMMANDS_AS_FUNCS  

/*  Determine our own OS                                                     */
Parse source os . myself
windows = Left(Translate(os),3) == "WIN"
os2     = Left(Translate(os),4) == "OS/2"
linux   = \windows & \os2

/*  Determine the path separator                                             */
If linux Then sep = "/"
         Else sep = "\"
		 
/*  OS2 can be picky about the VALUE pool selector                           */		 
If os2   Then environmentSelector = "OS2ENVIRONMENT"
         Else environmentSelector = "ENVIRONMENT"			 

/*  Determine the interpreter                                                */
Parse version interpreter
ooRexx  = Pos("OOREXX", Translate(interpreter)) > 0 /* Windows, Linux        */
ObjREXX = Pos("OBJREXX",Translate(interpreter)) > 0 /* OS/2                  */
rexxSAA = Pos("REXXSAA",Translate(interpreter)) > 0 /* OS/2                  */
Regina  = Pos("REGINA", Translate(interpreter)) > 0 /* OS/2, Windows, Linux  */

/*****************************************************************************
 *  Verbosity = 0: print only the cases that fail,  no details               *
 *  Verbosity = 1: print all cases, no details                               *
 *  Verbosity = 2: print only the cases that fail, with details              *
 *  Verbosity = 3: print all cases, with details                             *
 *****************************************************************************/
Verbosity = 1

Parse arg callerName, specialTest, fixit, verbosity
callerDir = SubStr(callerName, 1, LastPos(sep,callerName))
Say "/"Copies("*",78)
Say "  "SubStr(callerName, LastPos(sep,callerName) +1 ) "-- A Search Order test suite"
Say ""
Say "  Interpreter:     " interpreter
Say "  Operating system:" os
Say "  Full name:       " callerName
Say "  Main routine:    " myself
If specialTest == "CMD" Then Do
  If \Windows Then Do
    Say "*** CMD.EXE can only be checked under Windows"
	Exit 1
  End
Say ""  
Say "  Special test: CMD.EXE"
End
Say ""
Say "  Test suite starting on" Date() "at" Time()
Say ""

lastSlash  = LastPos(sep,myself)
sameDir    = SubStr(myself, 1, lastSlash - 1)
Parse Value Reverse(sameDir) With (sep) (sep)rest
currDir    = Reverse(rest)sep"dotdotcurr"sep"curr"
pathDir    = Value("PATH",,environmentSelector)
path       = pathDir

/*****************************************************************************
 *  If we are trying to "fix" things, the PATH environment variable          *
 *  under OS/2 and under Object Rexx will contain the "same" directory.      *
 *****************************************************************************/ 
If fixIt & ObjRexx Then Parse Var pathDir pathDir";"

Call Directory currDir
If result \== currDir Then Do
  Say "*** Could not set current directory to '"currDir"'."
  Say "*** Exiting..."
  Exit 1
End

Say "  The following values have been set:"
Say ""
Say "    Same directory:    '"sameDir"'"
Say "    Current directory: '"currDir"'"
Say "    Path:              '"path"'"
If Regina & fixIt Then
Say "    Regina_Macros:     '"Value("REGINA_MACROS",,environmentSelector)"'"
Say ""

/*  This will simplify things from now on                                    */
sameDir = sameDir || sep
currDir = currDir || sep
pathDir = pathDir || sep

/*  The following checks that all required files are there                   */
/*  and that, when called, their return values are correct.                  */

Call TestFiles

/*  Extension- or directory- first? (Only for certain combos atm)            */

Select
  When Regina Then Do
    Call "reginaextensions" /* ReginaExtensions */
    Say "  This is Regina. Search order is" result"-first"
	Say ""
    End
  When ooRexx Then Do
    Call ooRexxExtensions
    Say "  This is ooRexx. Search order is" result"-first"
	Say ""
    End
  Otherwise /* No test prepared */
End  

/*  Emit closing comment delimiter                                           */
Say " "Copies("*",78)"/"

testNo = 0

/*  Group 1: Pathless tests                                                  */

Call TryCall "'same'",                                 "same"
Call TryCall "'same.rex'",                             "same"

Call TryCall "'curr'",                                 "curr"
Call TryCall "'curr.rex'",                             "curr"

Call TryCall "'path'",                                 "path"
Call TryCall "'path.rex'",                             "path"

/*  Group 2: Downward-relative tests                                         */

Call TryCall "'lib"sep"samelib'",                      "samelib"
Call TryCall "'lib"sep"samelib.rex'",                  "samelib"

Call TryCall "'lib"sep"currlib'",                      "currlib"
Call TryCall "'lib"sep"currlib.rex'",                  "currlib"

Call TryCall "'lib"sep"pathlib'",                      "pathlib"
Call TryCall "'lib"sep"pathlib.rex'",                  "pathlib"

/*  Group 3: Dot (this directory) tests                                      */

Call TryCall "'."sep"same'",                           "same"
Call TryCall "'."sep"same.rex'",                       "same"

Call TryCall "'."sep"curr'",                           "curr"
Call TryCall "'."sep"curr.rex'",                       "curr"

Call TryCall "'."sep"path'",                           "path"
Call TryCall "'."sep"path.rex'",                       "path"

/*  Group 4: Upward-relative tests                                           */

Call TryCall "'.."sep"dotdotsame'",                    "dotdotsame"
Call TryCall "'.."sep"dotdotsame.rex'",                "dotdotsame"

Call TryCall "'.."sep"dotdotcurr'",                    "dotdotcurr"
Call TryCall "'.."sep"dotdotcurr.rex'",                "dotdotcurr"

Call TryCall "'.."sep"dotdotpath'",                    "dotdotpath"
Call TryCall "'.."sep"dotdotpath.rex'",                "dotdotpath"

/*  Group 5: Upward-relative tests with a trick                              */

Call TryCall "'lib"sep".."sep".."sep"dotdotsame'",     "dotdotsame"
Call TryCall "'lib"sep".."sep".."sep"dotdotsame.rex'", "dotdotsame"

Call TryCall "'lib"sep".."sep".."sep"dotdotcurr'",     "dotdotcurr"
Call TryCall "'lib"sep".."sep".."sep"dotdotcurr.rex'", "dotdotcurr"

Call TryCall "'lib"sep".."sep".."sep"dotdotpath'",     "dotdotpath"
Call TryCall "'lib"sep".."sep".."sep"dotdotpath.rex'", "dotdotpath"

/*  Under OS/2 and Windows, we can try some tests more.                      */
If OS2           Then Call Prepare4OS2
If Windows       Then Call Prepare4Windows
If OS2 | Windows Then Call DriveLetterTests

Say "Pass.0 =" testNo
Say "Return Pass."

Exit

/*****************************************************************************/
Prepare4Windows:
/*****************************************************************************
 *                                                                           *
 *  To be able to test for backslash-relative paths, we need to use the      *
 *  SUBST command to set the current directory and the path to drives        *
 *  different from  the current drive. We need to find some free drives      *
 *  first. We will do that by calling Directory("X:\"), where "X" is         *
 *  the drive; if the drive does not exist, this call will return "".        *
 *                                                                           * 
 *****************************************************************************/

  drives = Reverse( XRange("C","Z") )  /* Skip diskettes A and B             */

  freeDrives = ""
  currentDirectory = Directory()       /* Save current directory             */

    Do i = 1 To Length(Drives)
      drive = SubStr(Drives,i,1)
      Call Directory drive":\"         
      If result = "" Then freeDrives = freeDrives || drive
      If Length(freeDrives) == 2 Then Leave
    End

  Call Directory currentDirectory      /* Restore current directory          */

  If Length(freeDrives) \== 2 Then Do
    Say "Could not find enough free drives for the Windows-only tests."
    Say "Exiting..."
    Exit 1
  End

  d1 = Left( FreeDrives,1)
  d2 = Right(FreeDrives,1)

  If Verbosity >= 2 Then Do
    Say "/"Copies("*",78)
    Say Left(" *  Start of Windows-only tests",78)"*"
    Say " "Copies("*",78)"/"
    Say ""
  End

  command = "SUBST" d1":" Qualify(sameDir"..\..\dotdotcurr")
  Say "/* Executing '"Left(command"'",Max(63,Length(command"'")))" */"
  Address COMMAND command
  command = "SUBST" d2":" Qualify(sameDir"..\..\dotdotpath")
  Say "/* Executing '"Left(command"'",Max(63,Length(command"'")))" */"
  Address COMMAND command
Return

/*****************************************************************************/
Prepare4OS2:
/*****************************************************************************
 *                                                                           *
 *  Under OS/2, we can't use the SUBST command, as in Windows. We assume     *
 *  that by some external means (for example, VirtualBox VBoxControl,        *
 *  duplicating the files in different drives, etc) we can use two           *
 *  additional drive letters, different from sameDir[1]":". The first one    *
 *  points to currdir"\.." (or a copy of this directory), and, similarly,    *
 *  the second one points to pathDir"\.." (or a copy of this directory).     *
 *                                                                           *
 *  Before starting the tests, an environment variable called SOTEST_DRIVES  *
 *  has to be created. It should contain two different uppercase letters     *
 *  separated by a space, representing the drives (without the colon).       *
 *                                                                           *
 *****************************************************************************/  

  extraDrives = Value("SOTEST_DRIVES",,environmentSelector)
  If Words(extraDrives) == 2 Then Do
    Parse Var extraDrives d1 d2 .
	/* 
	   See that the pertinent files are there, 
	   and that they return correct values 
	*/
    Call TestExtraFiles
    If Verbosity >= 2 Then Do	
      Say "/"Copies("*",78)
      Say "   Start of OS/2-only tests"
      Say " "Copies("*",78)"/"
	End
	Say "/*"
    Say "    Drives" d1": and" d2": have been specified in the SOTEST_DRIVES"
	Say "    environment variable. All required files are in place."
	Say "*/"
  End
  
Return

/*****************************************************************************/
DriveLetterTests: 
/*****************************************************************************
 *                                                                           *
 *  Windows and OS/2 common path                                             *
 *                                                                           * 
 *****************************************************************************/

currentPath = Value("PATH",,environmentSelector)
currentDirectory = Directory()

Say Left("/* Changing current directory to" d1":\",78)"*/"
Call Directory d1":\"
Say Left("/* Changing PATH to" d2":\",78)"*/"
Call Value "PATH",d2":\",environmentSelector

If Verbosity >=2 Then Do
  Say ""
  Say "Modifying current directorty and path"
  Say ""
  Say "Same directory:    '"sameDir"'"
  Say "Current directory: '"Directory()"'"
  Say "Path:              '"Value("PATH",,environmentSelector)"'"
  Say ""
End

/* New existence tests (already done under OS/2)                             */
If Windows Then Call TestExtraFiles

/*  Group 6: Backslash-relative tests                                        */
 
dir = SubStr(samedir,3)                 /* -- Skip drive and colon           */
Call TryCall "'"dir"same'",                   "same" 
Call TryCall "'"dir"same.rex'",               "same" 
Call TryCall "'\dotdotcurr'",                 "dotdotcurr" 
Call TryCall "'\dotdotcurr.rex'",             "dotdotcurr" 
Call TryCall "'\dotdotpath'",                 "dotdotpath" 
Call TryCall "'\dotdotpath.rex'",             "dotdotpath" 
  
/*  Group 7: Drive-relative tests                                            */

sameDrive = Left(samedir,1) 
  
Call TryCall "'"sameDrive":lib\samelib'",     "samelib" 
Call TryCall "'"sameDrive":lib\samelib.rex'", "samelib" 
Call TryCall "'"d1":curr\curr'",              "curr" 
Call TryCall "'"d1":curr\curr.rex'",          "curr" 
Call TryCall "'"d2":path\path'",              "path" 
Call TryCall "'"d2":path\path.rex'",          "path" 

/*  Group 8: Drive-absolute tests                                            */
  
Call TryCall "'"sameDir"same'",               "same" 
Call TryCall "'"sameDir"same.rex'",           "same" 
Call TryCall "'"d1":\curr\curr'",             "curr" 
Call TryCall "'"d1":\curr\curr.rex'",         "curr" 
Call TryCall "'"d2":\path\path'",             "path" 
Call TryCall "'"d2":\path\path.rex'",         "path" 

Call Value "PATH", currentPath, environmentSelector
Call Directory currentDirectory

If Windows Then Do                      /* Undo SUBST, but only for Windows  */
  Address COMMAND "SUBST" d1": /D"
  Address COMMAND "SUBST" d2": /D"
End

/* End of Windows- and OS/2-only tests                                       */
Return

/*****************************************************************************/

TryCall: Procedure Expose sigl ooRexx ObjREXX rexxSAA Verbosity testNo specialTest
  Parse arg target, expectedResult
  If specialTest == "CMD" Then Do
    Parse arg "'"target"'"              /* Remove outer quotes               */
	If target == "path" Then Do         /* PATH is a Windows command         */
	  target = "pth"
	  expectedResult = "pth"
	End
    Address COMMAND target With Error Stem st.
    testNo = testNo + 1
    If rc \== 0 Then Say "Pass."Left(testNo,2)" = .false; Pass."testNo".test "Copies(" ",testNo<10)"=" "'"target"'"
    Else Say "Pass."Left(testNo,2)" = .true;  Pass."testNo".test "Copies(" ",testNo<10)"=" "'"target"'"
    Return
  End
  CallLine = sigl
  Signal On Syntax Name CallSyntax
  Interpret Call target                /* Attempt the call                   */
  If result \== expectedResult Then Do
    Say "Calling" target"... Failed!"  
    Say ""
    Say "*** At line" sigl":" SourceLine(sigl)
    Say "*** Expected '"expectedResult"', found '"result"'."
    Say ""
    End
  Else If Verbosity == 1 | Verbosity == 3 Then Do
    testNo = testNo + 1
	extra = Copies(" ",testNo<10)
	Say "Pass."Left(testNo,2)" = .true;  Pass."testNo".test "extra"=" target
  End
  Return
  
CallSyntax:
  Select
    When ooRexx Then                    /* ooRexx                            */
      desc = 'Error 43.1: Could not find routine "'Condition("A")'".'
    When ObjREXX Then Do                /* For OBJREXX-OS/2 -- Interpreted   */
      stmt = "name = '""Condition(""A"")[1]""'" /* because Regina complains  */
	  Interpret stmt                    /* at "["                            */
      desc = 'Error 43: Could not find routine ""'name'"".'
	  End
    When rexxSAA Then                   /* For OS/2                          */	
      desc = 'Error 43: Routine not found.'
    Otherwise                           /* Regina                            */
      desc = Condition("D")             /* Get the description, normally 43.1*/
  End
  Signal Off Syntax                     /* Reset the condition               */
  testNo = testNo + 1
  extra = Copies(" ",testNo<10)
  Say "Pass."Left(testNo,2)" = .false; Pass."testNo".test "extra"=" target
  If Verbosity >= 2 Then Do 
    Say ""
    Say "*** Call failed at line" CallLine":" Space(SourceLine(CallLine))"." 
    Say "***" desc
    Say ""
  End
  Return                              

/*****************************************************************************/
  
TestExists: 
  Parse arg target, expectedResult
  Signal On Syntax Name CallSyntax2
  Interpret Call target                 /* Attempt the call                  */
  If result \== expectedResult Then Do
    Say "File '"target"' exists, but it does not return '"expectedResult"'.",
	  "Aborting."
    Exit 1
  End
  Return
  
CallSyntax2:
  Signal Off Syntax                     /* Reset the condition               */
  Say "Could not find file '"target"'. Aborting"
  Exit 1

/*****************************************************************************/

TestFiles:
  s = sep
  Call TestExists "'"samedir"same.rex'",                       "same"
  Call TestExists "'"currdir"curr.rex'",                       "curr"
  Call TestExists "'"pathDir"path.rex'",                       "path"
  Call TestExists "'"samedir"lib"s"samelib.rex'",              "samelib"
  Call TestExists "'"currdir"lib"s"currlib.rex'",              "currlib"
  Call TestExists "'"pathdir"lib"s"pathlib.rex'",              "pathlib"
  Call TestExists "'"samedir"."s"same.rex'",                   "same"
  Call TestExists "'"currdir"."s"curr.rex'",                   "curr"
  Call TestExists "'"pathdir"."s"path.rex'",                   "path"
  Call TestExists "'"samedir".."s"dotdotsame.rex'",            "dotdotsame"
  Call TestExists "'"currdir".."s"dotdotcurr.rex'",            "dotdotcurr"
  Call TestExists "'"pathdir".."s"dotdotpath.rex'",            "dotdotpath"
  Call TestExists "'"samedir"lib"s".."s".."s"dotdotsame.rex'", "dotdotsame"
  Call TestExists "'"currdir"lib"s".."s".."s"dotdotcurr.rex'", "dotdotcurr"
  Call TestExists "'"pathdir"lib"s".."s".."s"dotdotpath.rex'", "dotdotpath"
  /* Is the search order is directory-first or extension-first? Experimental */
  Call TestExists "'"pathDir"oorexxextensions.rex'",           "extension"
  Call TestExists "'"pathDir"reginaextensions.rexx'",          "extension"
  Call TestExists "'"currdir"oorexxextensions'",               "directory"
  Call TestExists "'"currdir"reginaextensions.rex'",           "directory"
Return

/*****************************************************************************/

TestExtraFiles:
  Call TestExists "'"d1":\dotdotcurr.rex'",                    "dotdotcurr"
  Call TestExists "'"d2":\dotdotpath.rex'",                    "dotdotpath"
  Call TestExists "'"d1":\curr\curr.rex'",                     "curr"
  Call TestExists "'"d2":\path\path.rex'",                     "path"
Return
