/* REXX    PULLSAR    Get SAR reports into a TSO dataset
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke 20011114
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20020402 fxc allow GEN or SEQ to be blank
     20020417 fxc fix panel error
     20020423 fxc add check for blank gen/seq; change panel ver
     20020524 fxc force higher blocksize for output
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010802      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
address ISPEXEC "CONTROL ERRORS RETURN" /* I'll handle my own        */
call A_INIT                            /*                           -*/
call B_READ_SAR                        /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ PULLSAR                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call A0_SETUP_LOG                   /*                           -*/
   parse value "" with  ,
               progress  ,
               .
   sardsn = "ACN1.PR.D502.S01"
 
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
   logdsn = "@@LOG."exec_name"."subid".LIST"
 
   call ZL_LOGMSG("Log started by" Userid()  yyyymmdd  hhmmss)
   call ZL_LOGMSG("Arg:" argline)
 
return                                 /*@ A0_SETUP_LOG              */
/*
.  ----------------------------------------------------------------- */
B_READ_SAR:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   call BA_PROLOG                      /*                           -*/
   call BR_RETRIEVE                    /*                           -*/
   call BZ_EPILOG                      /*                           -*/
 
return                                 /*@ B_READ_SAR                */
/*
   DEIMBED, set up LIBDEFs
.  ----------------------------------------------------------------- */
BA_PROLOG:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call DEIMBED                        /*                           -*/
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ BA_PROLOG                 */
/*
   Invoke SARBCH to produce the SAR.SAPRINT dataset.  This is done via
   a background job because SARBCH is authorized and cannot be run in
   the foreground.
.  ----------------------------------------------------------------- */
BR_RETRIEVE:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "FTOPEN TEMP"
   "FTINCL JOBCARDS"
   do forever
      "DISPLAY PANEL(SARPARM)"         /* get report genin seqin     */
      if rc > 4 then leave             /* user hit PF3 ?             */
 
      if WordPos("?",report genin seqin) > 0 then do
         "SELECT PGM(SARSPF) PARM("sardsn") NEWAPPL(SAR)"
         iterate                       /* redisplay panel            */
         end
 
      if report = "" then leave        /* no more reports            */
      call ZL_LOGMSG("("BRANCH("ID")")",
               "Report="report "   Genin="genin "   Seqin="seqin)
 
      if Pos( "(", writedsn) > 0 then do
         zerrsm = "Must be sequential"
         zerrlm = "Output dataset must be sequential.  DSORG=PO",
                  "is not yet supported."
         "SETMSG  MSG(ISRZ002)"
         iterate
         end
 
      if Left(writedsn,1) = "'" then,  /* originally quoted          */
         jcldsn = Strip(writedsn,,"'") /* unquoted                   */
      else,                            /* originally unquoted        */
         jcldsn = Userid()"."writedsn  /* fully qualified            */
      "FTINCL SARBCH"                  /* JCL for SARBCH             */
 
      queue "/DBASE NAME="sardsn
      queue "/LOAD ID="Strip(report)
      if genin <> "-0" &,
         genin <> "" then,
         queue "GEN="Strip(genin)
      if seqin <> "+0" &,
         seqin <> "" then,
         queue "SEQ="Strip(seqin)
      queue "DDNAME=WRITE"
      call BRC_INSERT_CMD              /*                           -*/
      if progress = "" then,
         progress = "Prepared:" report
      else,
         progress = progress report
   end                                 /* forever                    */
 
   if progress = "" then do            /* nothing queued             */
      "FTCLOSE"                        /* nothing usable             */
      zerrsm = "Entry refused"
      zerrlm = "Panel SARPARM requires you to enter a report name",
               "and press ENTER. ",
               "You may have pressed PF3 in error."
      "SETMSG MSG(ISRZ002)"
      call ZL_LOGMSG("("BRANCH("ID")")",
            zerrlm)
      end                              /* no report selected         */
   else call BRR_RUN_SAR               /* acquire report from SAR   -*/
 
return                                 /*@ BR_RETRIEVE               */
/*
   Write the isolated queue to ISPSLIB and run SAR to acquire the
   report.
.  ----------------------------------------------------------------- */
BRC_INSERT_CMD:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   daid = daid.SLIB                    /* provided by DEIMBED        */
   mbr  = "SARCMDS"
   "LMOPEN DATAID("daid") OPTION(OUTPUT)"
 
   do queued()
      parse pull line
      "LMPUT DATAID("daid") MODE(INVAR) DATALOC(LINE) DATALEN(80)"
   end
 
   "LMMREP DATAID("daid") MEMBER("mbr")"
   "LMCLOSE DATAID("daid")"
   "FTINCL SARCMDS"                    /* control info for SARBCH    */
 
return                                 /*@ BRC_INSERT_CMD            */
/*
   The JCL jobstream is complete.  Submit to the background reader.
.  ----------------------------------------------------------------- */
BRR_RUN_SAR:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "FTCLOSE"
   "VGET (ZTEMPF ZTEMPN)"
   if sw.0modify then do
      "LMINIT DATAID(DDNID) DDNAME("ztempn")"
      zerrsm = "CAUTION!!!!!"
      zerrlm = "This JCL -WILL- be automatically submitted when",
               "EDIT completes.  If you DO NOT want the JOB to run",
               "you must erase this JCL, saving an empty",
               "dataset."
      "SETMSG  MSG(ISRZ002)"
      "EDIT DATAID("ddnid")"
      end
                                    if noupdt then return
   rc = Outtrap("JS.")                 /* catch SUBMITTED message    */
   address TSO "SUBMIT '"ZTEMPF"'"
   rc = Outtrap("OFF")
 
   do ccx = 1 to js.0                  /* each line                  */
      if WordPos("SUBMITTED",js.ccx) > 0 then leave
   end                                 /* ccx                        */
 
   if ccx > js.0 then,
      do ccx = 1 to js.0; say js.ccx
      call ZL_LOGMSG("("BRANCH("ID")")",
               js.ccx)
      end
   else do                             /* SUBMITTED                  */
      zerrsm = js.ccx ; zerrlm = zerrsm
      parse var js.ccx "(JOB" jn ")"   /* job number                 */
      jn = jn + 0                      /* strip zeroes               */
      "SETMSG  MSG(ISRZ002)"
      end
 
return                                 /*@ BRR_RUN_SAR               */
/*
   Remove LIBDEFs
.  ----------------------------------------------------------------- */
BZ_EPILOG:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd
      address TSO "FREE  FI("$ddn")"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ BZ_EPILOG                 */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   sw.0modify    = SWITCH("EDIT")
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
   Parse out the embedded components at the back of the source code.
.  ----------------------------------------------------------------- */
DEIMBED: Procedure expose,             /*@                           */
   (tk_globalvars)  ddnlist  $ddn.  daid.
 
   address TSO
 
   fb80po.0  = "NEW UNIT(VIO) SPACE(5 5) TRACKS DIR(40)",
                   "RECFM(F B) LRECL(80) BLKSIZE(0)"
   parse value ""   with  ddnlist $ddn.  daid.
 
   lastln   = sourceline()
   currln   = lastln                   /*                            */
   if Left(sourceline(currln),2) <> "*/" then return
 
   currln = currln - 1                 /* previous line              */
   "NEWSTACK"
   address ISPEXEC
   do while sourceline(currln) <> "/*"
      text = sourceline(currln)        /* save with a short name !   */
      if Left(text,3) = ")))" then do  /* package the queue          */
         parse var text ")))" ddn mbr .   /* PLIB PANL001  maybe     */
         if Pos(ddn,ddnlist) = 0 then do  /* doesn't exist           */
            ddnlist = ddnlist ddn      /* keep track                 */
            $ddn = ddn || Random(999)
            $ddn.ddn = $ddn
            address TSO "ALLOC FI("$ddn")" fb80po.0
            "LMINIT DATAID(DAID) DDNAME("$ddn")"
            daid.ddn = daid
            end
         daid = daid.ddn
         "LMOPEN DATAID("daid") OPTION(OUTPUT)"
         do queued()
            parse pull line
            "LMPUT DATAID("daid") MODE(INVAR) DATALOC(LINE) DATALEN(80)"
         end
         "LMMADD DATAID("daid") MEMBER("mbr")"
         "LMCLOSE DATAID("daid")"
         end                           /* package the queue          */
      else push text                   /* onto the top of the stack  */
      currln = currln - 1              /* previous line              */
   end                                 /* while                      */
   address TSO "DELSTACK"
 
return                                 /*@ DEIMBED                   */
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
 
say "  "ex_nam"      retrieves reports or sysout from SAR to a TSO dataset.    "
say "                                                                          "
say "  Syntax:   "ex_nam"  <no parms>                                          "
say "                                                                          "
say "            "ex_nam"  runs as an ISPF dialog and obtains all its run-time "
say "                      information via a panel.  The panel requires you to "
say "                      specify the report/sysout name, the GEN, and the    "
say "                      SEQuence number, all of which should be specified in"
say "                      order to avoid unpredictable results.               "
say "                                                                          "
say "                      In addition, you must also specify a dataset to hold"
say "                      the delivered output.  The dataset will be built, if"
say "                      it does not exist, as PS/VBA/137.                   "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the             "
say "                  execution in REXX TRACE Mode.                           "
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
/*      REXXSKEL back-end removed for space                          */
/*
)))PLIB SARPARM
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  @ TYPE(TEXT)   INTENS(HIGH) COLOR(YELLOW)
  _ TYPE(INPUT)  INTENS(LOW)  CAPS(ON)
  $ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(LOW)  CAPS(OFF) COLOR(PINK)
)BODY EXPAND(บบ)
@บ-บ% SAR Report Selection Panel @บ-บ
%COMMAND ===>_ZCMD
 
+
@        Verify or Respecify:
+
+         Report     ===>$report  +
+
+            GEN     ===>$genin+
+
+            SEQ     ===>$seqin+
+
       OUTPUT To     ===>$writedsn
+
+          Enter a report name, GEN, and/or SEQ to@acquire a report.
                                GEN and SEQ are optional.
+
+          Enter a "?" in any field to@go to SAR.
+
           Leave "Report" blank and press ENTER when finished.
 !PROGRESS
 
)INIT
   &REPORT = &Z
   &GENIN = '-0'
   &SEQIN = '+0'
   .HELP  = SARPARMH
)REINIT
   REFRESH(*)
)PROC
   VER (&REPORT,NB)
   VER (&WRITEDSN,NB)
)END
   VER (&GENIN,ENUM)
   VER (&SEQIN,ENUM)
)))PLIB SARPARMH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ)
%TUTORIAL บ-บ SAR Report Selection Panel บ-บ TUTORIAL
%Next Selection ===>_ZCMD
 
+
    Enter the report name as known by SAR.  If GEN and SEQ are left as-is, the
    most recent version of the SYSOUT will be retrieved; otherwise enter the
    appropriate generation and sequence for the desired SYSOUT.
 
    When finished selecting reports/SYSOUTs, leave "Report" blank and press
    ENTER.  If you specified "EDIT", the JCL for acquiring the SYSOUTs will be
    presented to you for last-minute changes.  The JCL is automatically
    submitted for you.
)PROC
)END
)))SLIB JOBCARDS
&JOB1
&JOB2
&JOB3
&JOB4
)))SLIB SARBCH
//* -------------------------------------------------------  */
//GET01    EXEC PGM=SARBCH                RETRIEVE FROM SAR
//SYSUDUMP  DD SYSOUT=*
//SYSPRINT  DD SYSOUT=W
//WRITE     DD DSN=&JCLDSN,
//             DISP=(MOD,CATLG),UNIT=SYSDA,
//             SPACE=(TRK,(10,20)),
//             DCB=(RECFM=VBA,LRECL=137,BLKSIZE=27998)
//SYSIN     DD * (member SARCMDS is inserted here)
*/
