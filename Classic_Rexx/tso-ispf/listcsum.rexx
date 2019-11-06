/* REXX    LISTCSUM   Parse and isolate LISTCAT output to discrete,
                      identifiable packets.
 
           Written by Frank Clarke 20020318
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20020423 fxc enable OUTPUT; if CLUSTERASSOCIATIONS is empty,
                  get clustername from DATAASSOCIATIONS or
                  INDEXASSOCIATIONS and restart the command;
     20020507 fxc no hyphens in keys
     20020722 fxc leave queue intact if STACK
     20030331 fxc GDGBASE implies NONVSAM and SUMMARY
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010802      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
                                    if sw.0error_found then return
call B_LISTC                           /*                           -*/
call C_PARSE                           /*                           -*/
call D_REPORT                          /*                           -*/
 
if sw.0STACK then return               /* leave the queue intact     */
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ LISTCSUM                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call AA_SETUP_LOG                   /*                           -*/
   call AB_KEYWDS                      /*                           -*/
 
   major_keys = "ALIAS NONVSAM CLUSTER DATA INDEX SUMM"
   minor_keys. = ""
   minor_keys.alias   = "INCAT HISTORY ASSOCIATIONS"
   minor_keys.nonvsam = "INCAT HISTORY SMSDATA VOLUMES",
                        "ASSOCIATIONS ATTRIBUTES"
   minor_keys.gdgbase = "INCAT HISTORY ASSOCIATIONS ATTRIBUTES"
   minor_keys.cluster = "INCAT HISTORY SMSDATA RLSDATA ASSOCIATIONS"
   minor_keys.data    = "INCAT HISTORY ASSOCIATIONS ATTRIBUTES",
                        "STATISTICS ALLOCATION VOLUME"
   minor_keys.index   = "INCAT HISTORY ASSOCIATIONS ATTRIBUTES",
                        "STATISTICS ALLOCATION VOLUME"
   minor_keys.SUMM    = "ARY"
   parse value "" with ,
               valuestr.  .
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_SETUP_LOG:                          /*@                           */
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
   logdsn = "@@LOG."exec_name"."subid".#CILIST"
 
   call ZL_LOGMSG(exec_name "started by" Userid()  yyyymmdd  hhmmss)
   call ZL_LOGMSG("Arg:" argline)
 
return                                 /*@ AA_SETUP_LOG              */
/*
.  ----------------------------------------------------------------- */
AB_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.0stack = SWITCH("STACK")         /* return results to stack    */
 
   outdsn    = KEYWD("OUTPUT")         /* save output on DASD        */
   if outdsn <> "" then do
      sw.0stack = 1                    /* force stack                */
 
      alloc.0 = "NEW CATALOG UNIT(SYSDA) SPACE(5 5) TRACKS",
                  "RECFM(V B) LRECL(4096) BLKSIZE(0)"
      alloc.1 = "SHR"                  /* if it already exists...    */
      tempstat = Pos(Sysdsn(outdsn),"OK MEMBER NOT FOUND") > 0
      "ALLOC FI($TMP) DA("outdsn") REU" alloc.tempstat
      if rc > 0 then do
         sw.0error_found = 1
         return
         end
      end                              /* outdsn                     */
 
   parse var info   vsds  info
   if vsds = "" then do
      say "DSName required"
      exit
      end
 
return                                 /*@ AB_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
B_LISTC:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   "ALLOC FI(SYSPRINT) UNIT(VIO)  NEW REU SPACE(1) TRACKS",
            "RECFM(V B A) LRECL(121) BLKSIZE(0)"
   "ALLOC FI(SYSIN)    UNIT(VIO)  NEW REU SPACE(1) TRACKS",
            "RECFM(F B) LRECL(80) BLKSIZE(0)"
   "NEWSTACK"
   queue "  LISTCAT ENTRIES("vsds") +"
   queue "          ALL"
   "EXECIO" queued() "DISKW SYSIN (FINIS"
   "DELSTACK"
 
   address LINKMVS "IDCAMS"
 
return                                 /*@ B_LISTC                   */
/*
.  ----------------------------------------------------------------- */
C_PARSE:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   "EXECIO * DISKR SYSPRINT (FINIS"    /* load the queue             */
   do queued()
      parse pull 2 w1 rest
      if w1 = "" then iterate
      if WordPos(w1,"IDCAMS LISTCAT") > 0 then iterate
      if w1 = "IN-CAT" then w1 = "INCAT"
      select
         when WordPos(w1,"THE") > 0 then leave
         when WordPos(w1,"GDG") > 0 then do
            /* special case: major name is two words                 */
            parse var rest w2 rest
            if w2 = "BASE" then,
               parse value "GDGBASE NONVSAM SUMM" with ,
                            major_keys 1 w1 .
            major = w1
            rest  = Translate(rest," ","-")
            valuestr.major = Space(rest,1)        /* strip           */
            end                        /* GDG BASE                   */
         when WordPos(w1,major_keys) > 0 then do
            major = w1
            rest  = Translate(rest," ","-")
            valuestr.major = Space(rest,1)        /* strip           */
            end                        /* major                      */
         when WordPos(w1,minor_keys.major) > 0 then do
            minor = w1
            key   = Space(major minor,0)
            data  = Translate(rest," ","-")
            valuestr.key = Space(data,1)     /* strip                */
            end                        /* minor                      */
         otherwise do
            data  = Translate(w1 rest," ","-")
            valuestr.key = valuestr.key Space(data,1)     /* strip   */
            end                        /* value line                 */
      end                              /* select                     */
   end                                 /* queued                     */
 
   info = valuestr.DATAASSOCIATIONS valuestr.INDEXASSOCIATIONS
   if valuestr.CLUSTERASSOCIATIONS = "" then,
      if info <> "" then do            /* re-do the command          */
         "DELSTACK"                    /* stack before CALL          */
         clustername = KEYWD("CLUSTER")
         (exec_name) clustername argline
         exit                          /* bail out                   */
         end
 
   major = "SUMM"                      /* This is kinda hokey...     */
   key   = "SUMMARY"
   do queued()                         /* gross stats                */
      parse pull 2 w1 rest
      if w1 = "" then iterate
      select
         when WordPos(w1,"THE") > 0 then leave
         otherwise do
            data  = Translate(w1 rest," ","-")
            valuestr.key = valuestr.key Space(data,1)     /* strip   */
            end                        /* value line                 */
      end                              /* select                     */
   end                                 /* queued                     */
   "DELSTACK"
 
return                                 /*@ C_PARSE                   */
/*
.  ----------------------------------------------------------------- */
D_REPORT:                              /*@                           */
   if branch then call BRANCH
   address TSO
 
   "CLEAR"
   if outdsn <> "" then "NEWSTACK"     /* isolate the queue          */
   do Words(major_keys)                /* each major key             */
      parse var major_keys major major_keys
      do Words(minor_keys.major)       /* each minor key             */
         parse var minor_keys.major minor minor_keys.major
         key = Space(major minor,0)
         if valuestr.key = "" then iterate
         if sw.0stack then,
            queue key":" valuestr.key
         else do
            say key
            say "     "valuestr.key
            end
      end                              /* minor                      */
   end                                 /* major                      */
 
   if outdsn <> "" then do
      "EXECIO" queued() "DISKW $TMP (FINIS"
      "FREE  FI($TMP)"
      "DELSTACK"
      end
 
return                                 /*@ D_REPORT                  */
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
 
say "  "ex_nam"      parses and summarizes the output of an IDCAMS LISTCAT  "
say "                operation.                                             "
say "                                                                       "
say "  Syntax:   "ex_nam"  <dsname>                                         "
say "                      <OUTPUT odsn>                                    "
say "                      <STACK>                                          "
say "                                                                       "
say "            dsname    identifies the component for which a LISTCAT is  "
say "                      to be done.                                      "
say "                                                                       "
say "            odsn      identifies the output dataset where the stack is "
say "                      to be written.                                   "
say "                                                                       "
say "            STACK     places the parsed, summarized output on the queue"
say "                      for use by a caller-routine.                     "
say "                                                                       "
say "                                                      more....         "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "  Material placed on the stack is prefixed by its key and a colon (:)     "
say "  followed by the value string.  The following keys are delivered to the  "
say "  stack if populated:                                                     "
say "                                                                          "
say "  NONVSAMINCAT            ALIASINCAT            GDGBASEINCAT              "
say "  NONVSAMHISTORY          ALIASHISTORY          GDGBASEHISTORY            "
say "  NONVSAMASSOCIATIONS     ALIASASSOCIATIONS     GDGBASEASSOCIATIONS       "
say "  NONVSAMATTRIBUTES                             GDGBASEATTRIBUTES         "
say "  NONVSAMSMSDATA                                                          "
say "  NONVSAMVOLUMES                                                          "
say "                                                                          "
say "  CLUSTERINCAT            DATAINCAT             INDEXINCAT                "
say "  CLUSTERHISTORY          DATAHISTORY           INDEXHISTORY              "
say "  CLUSTERASSOCIATIONS     DATAASSOCIATIONS      INDEXASSOCIATIONS         "
say "  CLUSTERSMSDATA                                                          "
say "  CLUSTERRLSDATA                                                          "
say "                          DATAATTRIBUTES        INDEXATTRIBUTES           "
say "                          DATASTATISTICS        INDEXSTATISTICS           "
say "                          DATAALLOCATION        INDEXALLOCATION           "
say "                          DATAVOLUME            INDEXVOLUME               "
say "  SUMMARY                                                                 "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                   "
say "                                                                       "
say "        MONITOR:  displays key information throughout processing.      "
say "                                                                       "
say "        BRANCH:   show all paragraph entries.                          "
say "                                                                       "
say "        TRACE tv: will use value following TRACE to place the          "
say "                  execution in REXX TRACE Mode.                        "
say "                                                                       "
say "                                                                       "
say "   Debugging tools can be accessed in the following manner:            "
say "                                                                       "
say "        TSO "ex_nam"  parameters     ((  debug-options                 "
say "                                                                       "
say "   For example:                                                        "
say "                                                                       "
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                              "
 
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*		REXXSKEL back-end removed for space                  */