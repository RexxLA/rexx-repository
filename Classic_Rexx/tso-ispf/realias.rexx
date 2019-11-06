/* REXX    REALIAS    Automatically reassign aliases for routines whose
                      'Impact Analysis' section indicates the need.  The IA
                      section below indicates that REALIAS should also be 
                      known as ##ALIAS.
 
           Written by Frank Clarke 20010320
 
     Impact Analysis
.    SYSPROC   TRAPOUT
.    (alias)   ##ALIAS
 
     Modification History
     ccyymmdd xxx .....
                  ....
 
*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
call E_READ_SOURCE                     /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ REALIAS                   */
/*
   Initialization
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   if info = "" then call HELP
 
   parse var info basetext info
 
   if Sysdsn(basetext) <> "OK" then do
      helpmsg = basetext "is an invalid parameter."
      call HELP                        /* ...and don't come back     */
      end                              /* basetext is not a dsn(mbr) */
 
   parse var basetext  dsn  "(" basenm ")"  back
 
   if basenm = "" then do              /* membername not present     */
      helpmsg = "No membername was specified."
      call HELP                        /* ...and don't come back     */
      end                              /* basetext is not a dsn(mbr) */
 
   dsn       = dsn""back               /* possible ending quote      */
 
   if Sysdsn(dsn) <> "OK" then do      /* dsn is not a dsn!          */
      helpmsg = dsn "is an invalid dataset name."
      call HELP                        /* ...and don't come back     */
      end                              /* basetext is not a dsn(mbr) */
 
                 /* DSN will be used in JCL -- clean it up           */
   if Left(dsn,1) = "'" then,          /* quoted                     */
      dsn = Strip(dsn ,, "'")
   else,                               /* unquoted                   */
      dsn = Userid()"."dsn             /* fully-qualified            */
 
 
   parse value "0 0 0 0 0 0 0 0" with,
         aliasrows,
         .
 
return                                 /*@ A_INIT                    */
/*
   Read the subject EXEC top to bottom to discover all ALIAS lines in
   the Impact Analysis section.  First locate "Impact Analysis", then
   any lines which contain the string "(alias)" as the 2nd word.  Stop
   when a blank line is encountered.
.  ----------------------------------------------------------------- */
E_READ_SOURCE:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   "ALLOC FI($TMP) DA("basetext") SHR REU"
   if rc > 0 then do                   /* failed to allocate         */
      helpmsg = basetext "failed to allocate."
      call HELP                        /* ...and don't come back     */
      end
 
   "NEWSTACK"
   "EXECIO * DISKR $TMP (FINIS"        /* load the queue             */
   "FREE  FI($TMP)"
 
   do queued()
      parse pull line
      if Pos("Impact Analysis",line) > 0 then leave
   end
 
   if Pos("Impact Analysis",line) = 0 then do
      say "No impact analysis section found"
      end                              /* ran off the queue          */
   else,
   do queued()
      parse pull line
 
      if line = "" then leave          /* end of IA section          */
 
      if WordPos("(alias)",line) > 0 then,
         do
         parse var line   dot  alit  aliasnm   .
         "DELETE" "'"dsn"("aliasnm")'"
         "RENAME" "'"dsn"("basenm")'" "("aliasnm")   ALIAS"
         end
   end                                 /* queued                     */
 
   "DELSTACK"
 
return                                 /*@ E_READ_SOURCE             */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   modify    = SWITCH("EDIT")
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "                                                                          "
say "  "ex_nam"      scans a REXX exec for information about required ALIASes  "
say "                and re-establishes those aliases.                         "
say "                                                                          "
say "                                                                          "
say "  Syntax:   "ex_nam"  <dsn(mbr)>                        (Required)        "
say "                                                                          "
say "                                                                          "
say "            dsn(mbr)  is a TSO-format datasetname with membername.  This  "
say "                      must be immediately allocable or "exec_name" fails. "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                                                                          "
say "        NOUPDT:   by-pass all update logic.                               "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the execution in"
say "                  REXX TRACE Mode.                                        "
say "                                                                          "
say "                                                                          "
say "   Debugging tools can be accessed in the following manner:               "
say "                                                                          "
say "        TSO "ex_nam"  parameters     ((  debug-options                    "
say "                                                                          "
say "   For example:                                                           "
say "                                                                          "
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                                 "
 
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/* REXXSKEL back-end removed for space */
