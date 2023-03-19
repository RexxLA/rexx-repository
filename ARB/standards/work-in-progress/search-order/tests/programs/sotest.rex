/*****************************************************************************
 *                                                                           *
 *  sotest.rex                                                               *
 *                                                                           *
 *  This is a stub that displays some minimal infomation and then calls      *
 *  ./subdir/dotdotsame/same/main.rex                                        *
 *                                                                           *  
 *  WARNING:                                                                 *
 *                                                                           * 
 *  This program and its companion, main.rex, are carefully designed to      *
 *  run under REXXSAA for OS/2, Object Rexx for OS/2, ooRexx for Windows     *
 *  and Unixlike, and Regina for OS/2, Windows and Linux. Please be          *
 *  careful when modifying it, to ensure that no platform/interpreter        *
 *  combination is affected.                                                 *
 *                                                                           * 
 *  Written in 2023 by Josep Maria Blasco <josep.maria.blasco@epbcn.com>     *
 *                                                                           * 
 *****************************************************************************/

Arg args

/* "FIXIT" is experimental and poorly documented atm */
fixit     = 0
verbosity = 1

Do i = 1 To Words(args)
  arg = Word(args,i)
  Select
    When arg == "FIXIT" Then fixit = 1
    When arg == "VERB" Then
      If i == Words(args) Then verbosity = 1
      Else Do
        n = Word(args,i+1)
        If DataType(n,"W") & n > 0 Then Do
          verbosity = n
          i = i + 1
          End
        Else verbosity = 1
     End
   Otherwise
     Say "Unrecognized option '"arg"'."
     Exit 1
  End
End

Parse version interpreter
ooRexx  = Pos("OOREXX", Translate(interpreter)) > 0 /* Windows, Linux        */
ObjREXX = Pos("OBJREXX",Translate(interpreter)) > 0 /* OS/2                  */
rexxSAA = Pos("REXXSAA",Translate(interpreter)) > 0 /* OS/2                  */
Regina  = Pos("REGINA", Translate(interpreter)) > 0 /* OS/2, Windows, Linux  */

Parse Source os . myself
windows = Left(Translate(os),3) == "WIN"
os2     = Left(Translate(os),4) == "OS/2"

Select
  When os2           Then env = "OS2ENVIRONMENT"
  Otherwise               env = "ENVIRONMENT"		
End

Select
  When windows Then sep = "\"
  When os2     Then sep = "\"
  Otherwise         sep = "/" /* Unix */  
End  

myDir  = SubStr(myself, 1, LastPos(sep,myself))

If Regina & fixIt Then Do
  saveRegina_Macros = Value("REGINA_MACROS",,env)
  /* Simulate "same" directory */
  Say "-- ==> Partially fixing the 'same' directory problem by using"
  Say "-- ==> the REGINA_MACROS environment variable."
  Say "--"
  Call Value "REGINA_MACROS",mydir"subdir"sep"dotdotsame"sep"same",env
End  

/* Save current directory and PATH, call main, restore things, and exit      */
saveCurrent  = Directory()
savePath     = GetPath()

Call CallMain

Call SetPath   savePath
Call Directory saveCurrent

If Regina & fixIt Then Do /* Restore REGINA_MACROS */
  Call Value "REGINA_MACROS",saveRegina_Macros,env
End

Exit 0

/*****************************************************************************/

GetPath: Return Value("PATH",,env)

SetPath:
  Call Value "PATH",Arg(1),env
Return

/*****************************************************************************/

CallMain:
  pathDir = myDir"subdir"sep"dotdotpath"sep"path"
  sameDir = myDir"subdir"sep"dotdotsame"sep"same"

  Call SetPath pathDir
  If ObjREXX & fixIt Then Do
    Say "-- ==> Partially fixing the absence of the 'same' directory notion"
    Say "-- ==>  under Object REXX by adding the 'same' directory to the PATH"
    Say "-- ==> environment variable."
    Say "--"
    Call SetPath pathDir";"sameDir
  End

  next = sameDir||sep"main.rex"
  Interpret "Call '"next"'" "'"myself"',"fixit","verbosity
Return
