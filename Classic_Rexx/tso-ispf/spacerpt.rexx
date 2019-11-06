/* REXX    SPACERPT   produce a report showing the allocation status of
                      classes of libraries.
 
                      The caller of SPACERPT will be expected to provide
                      either a single catalog level as the first parm,
                      or a dataset which specifies the catalog level(s)
                      to be examined, or both.  SPACERPT will obtain the
                      list of dataset names and the allocation data for
                      each, formatting them as appropriate.
 
           Written by Frank Clarke, Oldsmar FL
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     ........ ... ........
                  ....
 
*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
if parms  = "" then call HELP          /* ...and don't come back     */
 
call A_INIT                            /*                           -*/
call B_RUN_LIST                        /*                           -*/
call E_WRITE                           /*                           -*/
 
call ZB_SAVELOG                        /*                           -*/
if ^sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ SPACERPT                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
                                       /*                            */
   call A0_SETUP_LOG                   /*                           -*/
 
   call AA_KEYWDS                      /*                           -*/
 
   call AB_LOAD_LEVELS                 /*                           -*/
 
   msg.      = "??"
   msg.0000  = "OK"
   msg.0005  = "NC"
   msg.0009  = "MI"
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
A0_SETUP_LOG:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value "0" with,
               log#    log.
   parse value Date("S")  Time("S")  Time("N")  with,
               yyyymmdd   sssss      hhmmss  .
   parse var yyyymmdd  4 yrdigit 5 mm 7 dd          /* 9 12 14 maybe */
   if Pos(yrdigit,"13579") > 0 then mm = mm + 12       /* mm=24      */
   logtag = Substr("ABCDEFGHIJKLMNOPQRSTUVWX",mm,1)    /* logtag=X   */
   subid  = logtag""dd""Right(sssss,5,0)               /* X1423722 ? */
   vb4k.0    = "NEW CATALOG UNIT(SYSDA) SPACE(1 5) TRACKS",
               "RECFM(V B) LRECL(4096) BLKSIZE(0)"
   vb4k.1    = "SHR"                   /* if it already exists...    */
   logdsn = "$LOG."exec_name"."subid".LIST"
 
   call ZL_LOGMSG("Log started by" Userid()  yyyymmdd  hhmmss)
   call ZL_LOGMSG("Arg:" argline)
 
return                                 /*@ A0_SETUP_LOG              */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   outdsn    = KEYWD("OUTPUT")
   dsni      = KEYWD("LEVELS")
   parse var info single_lvl           /* if LEVELS not specified    */
   if Words(dsni single_lvl) < 1 then,
      helpmsg = "Either OUTPUT or a catalog level must be specified. ",
                "Both MAY be specified. "
 
   if outdsn = "" then,
      helpmsg = helpmsg "OUTPUT is a required keyword."
 
   if helpmsg <> "" then,
      call HELP                        /* ...and don't come back    -*/
 
return                                 /*@ AA_KEYWDS                 */
/*
   Read <dsni> to populate <info>.
.  ----------------------------------------------------------------- */
AB_LOAD_LEVELS:                        /*@                           */
   if branch then call BRANCH
   address TSO
 
   info = single_lvl
 
   if dsni <> "" then do
      "ALLOC FI($LVL) DA("dsni") SHR REU"
      if rc > 4 then do
         helpmsg = dsni "could not be allocated. Make sure this dataset",
                   "exists and is correctly populated."
         call HELP                     /* ...and don't come back    -*/
         end                           /* ALLOC failure              */
      end                              /* dsni                       */
 
   "NEWSTACK"
   if dsni <> "" then do
      "EXECIO * DISKR $LVL (FINIS"     /* load the queue             */
      "FREE FI($LVL)"
      end                              /* dsni                       */
 
   do queued()                         /* every line                 */
      pull line
      if Left(line,1) = "*" then iterate    /* ignore comments       */
      info = Space(info line,1)
   end                                 /* queued()                   */
 
   "DELSTACK"
   call ZL_LOGMSG("Consolidated levels:" info)
 
return                                 /*@ AB_LOAD_LEVELS            */
/*
   <info> is populated with datasetnames.  Use LISTDSI on each
   datasetname to acquire allocation data.
.  ----------------------------------------------------------------- */
B_RUN_LIST:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   call BH_HEADER                      /* initial headers           -*/
 
   do bx = 1 to Words(info)
      thislvl = Word(info ,bx)
      rc = Outtrap("lc.")
      "LISTC LVL("thislvl")"
      rc = Outtrap("off")
 
      do bz = 1 to lc.0
         parse var lc.bz lit . dsn .
         if lit ^= "NONVSAM" then iterate
         call BA_LISTDSI
      end                              /* bz                         */
   end                                 /* bx                         */
 
return                                 /*@ B_RUN_LIST                */
/*
   Format and print allocation data for each dataset.
.  ----------------------------------------------------------------- */
BA_LISTDSI:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   ldrc   = Listdsi("'"dsn"'  directory   norecall")    /* sets:     */
   dsstat = msg.sysreason              /*   SYSREASON                */
 
   if lines//6 = 0 then do; queue " "; lines = lines + 1; end
   if dsstat  = "MI" then do
      queue " "Left(dsn,47) "Migrated"
      lines = lines + 1
      end
   if dsstat ^= "OK" then return
 
   if sysadirblk = "NO_LIM" then do
      sysdsorg   = "POE"
      sysused    = "---"
      sysadirblk = "N/L"
      sysudirblk = "---"
      end                              /* NO_LIM                     */
   queue " "Left(dsn,47) Left(sysdsorg,3),
                         Left(sysrecfm,3),
                         Right(syslrecl,5),
                         Right(sysblksize,5),
                         Right(sysalloc,5),
                         Right(sysused,5),
                         Right(sysprimary,5),
                         Right(sysseconds,5),
                         Right(sysextents,2),
                         Right(sysadirblk,4),
                         Right(sysudirblk,4),
                         Right(sysmembers,5),
                         sysunits
   lines = lines + 1
   if lines > 53 then call BH_HEADER               /*               -*/
 
return                                 /*@ BA_LISTDSI                */
/*
   Write a header-line for each page.
.  ----------------------------------------------------------------- */
BH_HEADER: Procedure expose,           /*@                           */
   (tk_globalvars) lines
   if branch then call BRANCH
   address TSO
 
   lines = 0
 
   dsn         = "Dataset Name"
   sysdsorg    = "Org"
   sysrecfm    = "Len"
   syslrecl    = "Lrecl"
   sysblksize  = "Blksz"
   sysalloc    = "Alloc"
   sysused     = "Used "
   sysprimary  = "Prim"
   sysseconds  = "2ry"
   sysextents  = "X"
   sysadirblk  = "D/A"
   sysudirblk  = "D/U"
   sysmembers  = "Mbrs "
   sysunits    = "Units"
 
   queue "1"Left(dsn,47) Left(sysdsorg,3),
                         Left(sysrecfm,3),
                         Right(syslrecl,5),
                         Right(sysblksize,5),
                         Right(sysalloc,5),
                         Right(sysused,5),
                         Right(sysprimary,5),
                         Right(sysseconds,5),
                         Right(sysextents,2),
                         Right(sysadirblk,4),
                         Right(sysudirblk,4),
                         Right(sysmembers,5),
                         sysunits Date("S") Time()
 
return                                 /*@ BH_HEADER                 */
/*
   Dump the queue.
.  ----------------------------------------------------------------- */
E_WRITE:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   call ZL_LOGMSG(queued() "lines written to" outdsn)
 
   if outdsn = "VIO" then,
      "ALLOC FI($TMP) NEW UNIT(VIO) SPACE(5 15) TRACKS",
               "RECFM(V B A) LRECL(255) BLKSIZE(0)"
   else do
      alloc.0 = "NEW CATALOG UNIT(SYSDA) SPACE(5 15) TRACKS",
                  "RECFM(V B A) LRECL(255) BLKSIZE(0)"
      alloc.1 = "SHR"                  /* if it already exists...    */
      tempstat = Sysdsn(outdsn) = "OK" /* 1=exists, 0=missing        */
      "ALLOC FI($TMP) DA("outdsn") REU" alloc.tempstat
      end
   "EXECIO" queued() "DISKW $TMP (FINIS"
   call EB_BROWSE_OUTPUT               /*                           -*/
   "FREE  FI($TMP)"
 
return                                 /*@ E_WRITE                   */
/*
.  ----------------------------------------------------------------- */
EB_BROWSE_OUTPUT:                      /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if sw.batch then return
   if \sw.inispf then return
 
   "CONTROL ERRORS RETURN"             /* I'll handle my own         */
   "LMINIT  DATAID(DAID) DDNAME($TMP)"
   "BROWSE  DATAID("daid")"
   "LMFREE  DATAID("daid")"
 
return                                 /*@ EB_BROWSE_OUTPUT          */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
ZB_SAVELOG:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   if Symbol("LOG#") = "LIT" then return          /* not yet set     */
 
   "ALLOC FI($LOG) DA("logdsn") REU" vb4k.0
   "EXECIO" log# "DISKW $LOG (STEM LOG. FINIS"
   "FREE  FI($LOG)"
 
return                                 /*@ ZB_SAVELOG                */
/*
.  ----------------------------------------------------------------- */
ZL_LOGMSG: Procedure expose,           /*@                           */
   (tk_globalvars)  log. log#
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
 
say " "ex_nam"        produces a printable report showing the allocation       "
say "                status for specified datasets.                            "
say "                                                                          "
say "  Syntax:  "ex_nam"   <single-lvl>                                        "
say "                      <LEVELS dsni>                                       "
say "                      <OUTPUT dsno>       (Required)                      "
say "                                                                          "
say "            <single-lvl>  names a catalog level (or levels) to be         "
say "                          examined.  In operation, any tokens left after  "
say "                          parsing of LEVELS and OUTPUT are treated as     "
say "                          catalog levels to be examined.                  "
say "                                                                          "
say "            <dsni>        names a dataset containing LEVEL data suitable  "
say "                          for use by LISTC.  Each line of this dataset    "
say "                          may contain (0->n) specifications appropriate   "
say "                          for LISTC, but any line which begins with an    "
say "                          asterisk (*) will be ignored.  The contents of  "
say "                          this dataset, if used, will be in addition to   "
say "                          the <single-lvl> specified as a parm, if any.   "
say "                                                                          "
say "      At least one of <single-lvl> and <dsni> must be specified.          "
say "                                                                          "
say "                                                     more.....            "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "                                                                          "
say "            <dsno>        names a dataset to receive the output, a report "
say "                          showing datasetname and space usage statistics. "
say "                          <dsno> is a required specification, but the name"
say "                          specified does not need to pre-exist.  If <dsno>"
say "                          does not exist, it will be created as PS/VB/255."
say "                                                                          "
say "                          If <dsno> is specified as 'VIO' it will be      "
say "                          created as a VIO dataset and purged at CLOSE.   "
say "                          The VIO dataset used may be printed via any     "
say "                          appropriate facility during the final BROWSE    "
say "                          session.                                        "
say "                                                                          "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                  Displays most paragraph names upon entry.               "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the execution   "
say "                  in REXX TRACE Mode.                                     "
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
/*  REXXSKEL back-end removed for space    */
