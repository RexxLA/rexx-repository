/* REXX   ATTACH      a routine to perform LOGON-time customization of a
                      TSO user environment, especially as regards file
                      allocations.

           Written by Frank Clarke, 19970921

.    Impact Analysis
.    SYSPROC   TRAPOUT
.    SYSPROC   LA
.    SYSEXEC   NOOP

   Some files are pre-allocated; an input file will provide additional
   information in the following form:
      ATTACH  filename dsname (AHEAD, BEHIND, UNIQUE, FIRST, LAST, ONLY)
      DETACH  filename dsname
      DROP    filename
      INCLUDE dsname
      TSO     CLIST or REXX EXEC
      REXX    executable-command
   The default primary input file is member 'START' from the caller's
   ISPF.PROFILE dataset.

.  Process:
        Each command will be processed in the order encountered, except
               that all INCLUDE statements and nested INCLUDEs must
               first be expanded.
        All allocations will be collected and processed together.
.       Begin: determine all existing allocations; process each ATTACH,
               DETACH, DROP, and INCLUDE statement found in the command
               stack;
.       ATTACH: the dsname specified is first removed (if it exists in
                the allocation for the filename) and then inserted
                either at the head of the sequence or at the tail;
.       DETACH: the dsname specified is removed (if it exists in the
                allocation for the filename)
.       DROP:   the file specified is FREEd.
.       INCLUDE: the dsname specified is presumed to contain ATTACH,
                DETACH, DROP, TSO, REXX, and INCLUDE commands; it is
                read into the command stack where found.  Because of the
                possibility of nested INCLUDEs, the presence of an
                INCLUDE requires the stack to be reprocessed.
.       TSO/    indicates a command to be stored for execution after
.       REXX:   all the allocations are finalized.  The command must be
                executable as written.  TSO statements are executed
                in-line after all allocations complete; REXX statements
                are interpreted for execution as the last task of
                ATTACH.

     Modification History
     19990922 fxc added call to EXECUTIL and NOOP to force SYSEXEC
                  closed so that ATTACH may be re-run; RXSKLY2K;
     19991021 fxc added FIRST=AHEAD, ONLY=UNIQUE, LAST=BEHIND
     19991122 fxc upgrade from v.19980225 to v.19991109;
     20010327 fxc add external logging

*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts

signal on syntax
signal on novalue

call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */

call A_INIT                            /*                           -*/
call B_EXISTING_ALLOCS                 /*                           -*/
   "NEWSTACK"
call C_LOAD_CMD_STACK                  /*                           -*/
call D_BUILD_LISTS                     /*                           -*/
   "DELSTACK"
call E_REALLOC                         /*                           -*/

if sw.0DoLog then,                     /*                            */
   call ZB_SAVELOG                     /*                           -*/

return                                 /*@ ATTACH                    */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO

   call A0_SETUP_LOG                   /*                           -*/
   localvars  = "dsn."
   parse value "0 0 0 0 0 0 0 0 0 0 0" with,
         REXX_cmds.  stored_cmds.    .
   parse value "" with,
         dsn.  ddn

   sw.0DoLog    = \SWITCH("NOLOG")

return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
A0_SETUP_LOG:                          /*@                           */
   if branch then call BRANCH
   address TSO

   parse value "0" with,
               log#    log.
   tk_globalvars = tk_globalvars "log. log#"

   parse value Date("S")  Time("S")  Time("N")  with,
               yyyymmdd   sssss      hhmmss  .

   parse var yyyymmdd  4 yrdigit 5 mm 7 dd          /* 9 12 14 maybe */

   if Pos(yrdigit,"13579") > 0 then mm = mm + 12       /* mm=24      */

   logtag = Substr("ABCDEFGHIJKLMNOPQRSTUVWX",mm,1)    /* logtag=X   */

   subid  = logtag""dd""Right(sssss,5,0)               /* X1423722 ? */

   vb4k.0    = "NEW CATALOG UNIT(SYSDA) SPACE(1 5) TRACKS",
               "RECFM(V B) LRECL(4096) BLKSIZE(0)"
   vb4k.1    = "SHR"                   /* if it already exists...    */
   logdsn = "@@LOG."exec_name"."subid".LIST"

   call ZL_LOGMSG("Log started by" Userid()  yyyymmdd  hhmmss)

return                                 /*@ A0_SETUP_LOG              */
/*
   Determine all the existing allocations.
.  ----------------------------------------------------------------- */
B_EXISTING_ALLOCS:                     /*@                           */
   if branch then call BRANCH
   address TSO

   "NEWSTACK"
   "LA ((STACK LIST"
   do queued()
      pull line
      parse var line ddn ":" dsn.ddn
   end          /* queued */
   "DELSTACK"

return                                 /*@ B_EXISTING_ALLOCS         */
/*
.  Read the base command file and examine for the presence of INCLUDE
   commands.  For any INCLUDE, read the file specified and insert the
   contents directly to the bottom of the queue.
.  ATTACH, DETACH, and DROP commands can be re-written at the bottom of
   the original queue.
.  REXX and TSO commands are to be stored for later use.

   Notes on the use of the QUEUE:
   - a 'do queued()' is evaluated once at the start of the loop and is
     not re-evaluated if lines are later added to the queue.
   - sw.0continue is set ON by a call to CA_; this causes a later
     re-evaluation of the 'do queued()' if lines are added.
   - result: if an INCLUDE is found, the text of the referenced dataset
     replaces the INCLUDE and the stack is flagged for reprocessing;
     thus, if an INCLUDE points to a nested INCLUDE, the nested include
     is loaded and processed as if its text were coded as part of the
     base command file.
.  ----------------------------------------------------------------- */
C_LOAD_CMD_STACK:                      /*@                           */
   if branch then call BRANCH
   address TSO

   call CA_EAT_CMDFILE basefile        /* sets continue             -*/
   do while sw.0continue
      sw.0continue = "0"               /* automatic shut-off         */
      do queued()
         parse pull verb linedata
         if Wordpos(verb,"DROP REXX TSO ATTACH DETACH") > 0 then,
            queue verb linedata; else,
         if verb = "INCLUDE" then,
            call CA_EAT_CMDFILE linedata           /* sets continue -*/
      end          /* queued */
   end          /* while */
   "FREE  FI(CMD)"
   /* the queue contains only REXX, TSO, ATTACH, and DETACH commands */

return                                 /*@ C_LOAD_CMD_STACK          */
/*
   BASEFILE is always presented fully-qualified and unquoted.
.  ----------------------------------------------------------------- */
CA_EAT_CMDFILE: Procedure expose,      /*@                           */
   (tk_globalvars)
   if branch then call BRANCH
   address TSO

   arg basefile .

   if Sysdsn("'"basefile"'") <> "OK" then return

   parse value "1 " with    sw.0continue .
   "ALLOC FI(CMD) DA('"basefile"') SHR REU"
   "EXECIO * DISKR CMD (FINIS"
   call ZL_LOGMSG("Added '"basefile"' to the queue.")

return                                 /*@ CA_EAT_CMDFILE            */
/*
.  Input: array DSN.ddname (all the DSNames by DDName)
          the queue containing all the TSO, ATTACH, and DETACH commands

   Any named DSN is first excised from the current allocation if it
   exists (this is ALL of the processing for DETACH), after which it may
   be ATTACHed either AHEAD of the first dataset or BEHIND the last.
.  ----------------------------------------------------------------- */
D_BUILD_LISTS:                         /*@                           */
   if branch then call BRANCH
   address TSO

   parse value "" with,
         ddnlist   .

   do queued()
      pull verb linedata
      call ZL_LOGMSG(verb linedata)
      select
         when verb = "TSO" then do
            parse value stored_cmds.0+1 linedata with,
                        $z$   stored_cmds.$z$   1  stored_cmds.0 .
            iterate
            end                        /* TSO                        */
         when verb = "REXX" then do
            parse value REXX_cmds.0+1 linedata with,
                        $z$   REXX_cmds.$z$   1  REXX_cmds.0 .
            iterate
            end                        /* REXX                       */
         when verb = "DROP" then do
            parse var linedata ddn .
            if ddn = "" then iterate   /* too few tokens             */
            if dsn.ddn = "" then iterate       /* nothing to drop    */
            dsn.ddn = ""               /* just in case               */
            call DA_MARK ddn           /*                           -*/
            end                        /* DROP                       */
         when verb = "DETACH" then do
            parse var linedata   ddn  dsn  .
            if dsn = "" then iterate   /* too few tokens             */
            wrdpos = Wordpos(dsn,dsn.ddn)
            if wrdpos > 0 then do
               dsn.ddn = Delword(dsn.ddn,wrdpos,1)
               call DA_MARK ddn        /*                           -*/
               end
            end                        /* DETACH                     */
         when verb = "ATTACH" then do
            parse var linedata   ddn  dsn  option  .
            if dsn = "" then iterate   /* too few tokens             */
            wrdpos = Wordpos(dsn,dsn.ddn)
            if wrdpos > 0 then,
               dsn.ddn = Delword(dsn.ddn,wrdpos,1)
            if WordPos(option,"AHEAD FIRST") > 0 then,
                                       dsn.ddn = dsn dsn.ddn ; else,
            if WordPos(option,"UNIQUE ONLY") > 0 then,
                                       dsn.ddn = dsn         ; else,
                                       dsn.ddn = dsn.ddn dsn
            call DA_MARK ddn           /*                           -*/
            end                        /* ATTACH                     */
         otherwise nop
      end                              /* select                     */
   end                                 /* queued                     */

return                                 /*@ D_BUILD_LISTS             */
/*
   Add this DDN to DDNLIST if it doesn't already exist there.  This is
   the list of DDNames which need to be re-allocated.
.  ----------------------------------------------------------------- */
DA_MARK: Procedure expose,             /*@                           */
   (tk_globalvars),
       ddnlist
   if branch then call BRANCH
   arg ddn   .

   if Wordpos(ddn,ddnlist) = 0 then,
      ddnlist = ddnlist ddn

return                                 /*@ DA_MARK                   */
/*
   Reallocate any DDName which has been changed.
.  ----------------------------------------------------------------- */
E_REALLOC:                             /*@                           */
   e_tv = trace()                      /* what setting at entry ?    */
   if branch then call BRANCH
   address TSO

   if WordPos("SYSEXEC",ddnlist) > 0 then do
      "EXECUTIL EXECDD(CLOSE)"
      "NOOP"                           /* this MUST be in SYSEXEC    */
                                       /* This must NOT BE in any    */
                                       /* ALTLIBed dataset ahead     */
                                       /* of SYSEXEC                 */
      sw.0turn_on_SYSEXEC = "1"
      call ZL_LOGMSG("EXECUTIL issued to close SYSEXEC")
      end

   do while ddnlist <> ""
      parse var ddnlist  ddn  ddnlist
      call EA_ADD_QUOTES               /*                           -*/
      call EB_ALLOC                    /*                           -*/
   end

   if sw.0turn_on_SYSEXEC then do
      "EXECUTIL EXECDD(NOCLOSE) SEARCHDD(YES)"
      call ZL_LOGMSG("EXECUTIL issued to set SYSEXEC NOCLOSE")
      end
                                     rc = Trace("O"); rc = trace(e_tv)
   signal off novalue                  /*                            */
   do ex = 1 to stored_cmds.0
      call ZL_LOGMSG(stored_cmds.ex)
      if \noupdt then,
         (stored_cmds.ex)
   end          /* ex */
                                     rc = Trace("O"); rc = trace(e_tv)
   do ex = 1 to REXX_cmds.0
      call ZL_LOGMSG(REXX_cmds.ex)
      if \noupdt then,
         interpret REXX_cmds.ex
   end          /* ex */

return                                 /*@ E_REALLOC                 */
/*
   DSN.DDN has all DSNames fully-qualified and unquoted.  Make it
   suitable for use in an ALLOC command.
.  ----------------------------------------------------------------- */
EA_ADD_QUOTES:                         /*@                           */
   if branch then call BRANCH
   address TSO

   do Words(dsn.ddn)
      parse var dsn.ddn  dsn  dsn.ddn
      dsn.ddn = dsn.ddn "'"dsn"'"
   end          /* each word of dsn.ddn */

return                                 /*@ EA_ADD_QUOTES             */
/*
.  ----------------------------------------------------------------- */
EB_ALLOC:                              /*@                           */
   if branch then call BRANCH
   address TSO

   if dsn.ddn = "" then,               /* empty dataset list         */
      alloccmd = "FREE  FI("ddn")"
   else,                               /* reallocate                 */
      alloccmd = "ALLOC FI("ddn") DA("dsn.ddn") SHR REU"

   call ZL_LOGMSG(alloccmd)

   if \noupdt then do
      (alloccmd)
      call ZL_LOGMSG("ALLOC rc="rc)
      end

return                                 /*@ EB_ALLOC                  */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   if branch then call BRANCH
   address TSO

   "CLEAR"
   say exec_name "started" Time()

   parse value KEYWD("BASEFILE") "ISPF.PROFILE(START)" with,
               basefile    .
   if Sysdsn(basefile) <> "OK" then do
      say basefile Sysdsn(basefile)
      exit
      end                              /* basefile not found ?       */
   if Left(basefile,1) = "'" then,     /* quoted                     */
      basefile = Strip(basefile,,"'")  /* unquoted                   */
   else,                               /* originally unquoted        */
      basefile = Userid()"."basefile   /* fully-qualified            */

return                                 /*@ LOCAL_PREINIT             */
/* ---- subroutines below LOCAL_PREINIT are not selected by SHOWFLOW */
/*
.  ----------------------------------------------------------------- */
ZB_SAVELOG:                            /*@                           */
   if branch then call BRANCH
   address TSO

   if Symbol("LOG#") = "LIT" then return          /* not yet set     */

   vb4k.0    = "NEW CATALOG UNIT(SYSDA) SPACE(1 5) TRACKS",
               "RECFM(V B) LRECL(4096) BLKSIZE(0)"
   "ALLOC FI($LOG) DA("logdsn") REU" vb4k.0
   "EXECIO" log# "DISKW $LOG (STEM LOG. FINIS"
   "FREE  FI($LOG)"

return                                 /*@ ZB_SAVELOG                */
/*
.  ----------------------------------------------------------------- */
ZL_LOGMSG: Procedure expose,           /*@                           */
   (tk_globalvars)
   rc = Trace("O")
   address TSO

   parse arg msgtext
   parse value  log#+1  msgtext     with,
                zz      log.zz    1  log#   .

   if monitor then say,
      msgtext

return                                 /*@ ZL_LOGMSG                 */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"      Environment customizer                                    "
say "                                                                          "
say "  Syntax:   "ex_nam"  [NOLOG]                                             "
say "                  ((  [BASEFILE dsn]                                      "
say "                                                                          "
say "            NOLOG  if specified suppresses production of the logfile, a   "
say "                   diagnostic tool.                                       "
say "                                                                          "
say "            dsn    is a file of input statements to be processed.  Six    "
say "                   verbs are currently supported:  ATTACH, DETACH, DROP,  "
say "                   INCLUDE, TSO, and REXX.                                "
say "                                                                          "
say "            ATTACH ddname dsname      [AHEAD or BEHIND or UNIQUE]         "
say "                                   [or FIRST or LAST   or ONLY]           "
say "                   the specified [dsname] will be added to the allocation "
say "                   list for the [ddname] either at the head [AHEAD or     "
say "                   FIRST], at the tail [BEHIND or LAST], or as the ONLY   "
say "                   dataset for this file [UNIQUE or ONLY].  If the dsname "
say "                   already appears in the list, it will first be          "
say "                   expunged.                                              "
say "                                                                          "
say "            DETACH ddname dsname                                          "
say "                   the specified [dsname] will be removed from the        "
say "                   allocation list for the [ddname].                      "
say "                                                                          "
say "                                                              more.....   "
pull
"CLEAR"
say "            DROP  DDname                                                  "
say "                   the named FILE will be FREEd.                          "
say "                                                                          "
say "            INCLUDE dsn                                                   "
say "                   the text of the dataset will be inserted at the point  "
say "                   the INCLUDE is discovered and will be reprocessed as   "
say "                   command-data.                                          "
say "                                                                          "
say "            TSO executable-command                                        "
say "                   names a CLIST or REXX EXEC to be executed as part of   "
say "                   the customization process.                             "
say "                                                                          "
say "            REXX executable-command                                       "
say "                   the command must be executable as written.  REXX       "
say "                   commands will be interpreted after all TSO commands    "
say "                   have been executed.  This is a good place to 'queue    "
say "                   ispf', for example, in order to cause ISPF to start    "
say "                   automatically.                                         "
pull
"CLEAR"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                  Displays most paragraph names upon entry.               "
say "                                                                          "
say "        NOUPDT:   by-pass all update logic.                               "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the execution   "
say "                  in REXX TRACE Mode.                                     "
say "                                                                          "
say "                                                                          "
say "   Debugging tools can be accessed in the following manner:               "
say "                                                                          "
say "        TSO "ex_nam"  parameters  ((  debug-options                       "
say "                                                                          "
say "   For example:                                                           "
say "                                                                          "
say "        TSO "ex_nam"  ((MONITOR TRACE ?R                                  "
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/****** REXXSKEL back-end removed to save space.   *******/ 