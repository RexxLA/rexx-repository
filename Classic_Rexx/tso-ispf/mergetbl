/* REXX    MERGETBL   Merge two ISPF tables.
 
           Written by Frank Clarke 20051006
 
     Impact Analysis
.    SYSEXEC   TRAPOUT
 
     Modification History
     ccyymmdd xxx .....
                  ....
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.20040227      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
call B_TBL_OPS                         /*                           -*/
call C_VERIFY                          /*                           -*/
call ZB_SAVELOG                        /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ MERGETBL                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value ""    with,
               state  ,
               .
   call AA_SETUP_LOG                   /*                            */
   call AK_KEYWDS                      /*                           -*/
 
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
   logdsn = "@@LOG."exec_name"."subid".LIST"
 
   call ZL_LOGMSG(exec_name "started by" Userid()  yyyymmdd  hhmmss)
   call ZL_LOGMSG("Arg:" argline)
 
return                                 /*@ AA_SETUP_LOG              */
/*
   MERGETBL intbl FROM intbllib INTO outtbl IN outtbllib
.  ----------------------------------------------------------------- */
AK_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.0Verify   = SWITCH("VERIFY")
   sw.0Keep     = SWITCH("KEEP")
   sw.0Repl     = SWITCH("REPLACE")
   if sw.0Keep + sw.0Repl <> 1 then,
      helpmsg = helpmsg "KEEP or REPLACE is required. "
   else,
      sw.0Keep  = \sw.0Repl
 
   outtbllib  = KEYWD("IN")
   if outtbllib = "" then helpmsg = helpmsg ,
          " 'IN outtbllib' is required. "
   else do
      state = Sysdsn(outtbllib)
      if state <> "OK" then,
         helpmsg = helpmsg "Status for" outtbllib "is" state". "
      end
   if Left(outtbllib,1) = "'" then,
      outtbllib = Strip(outtbllib,,"'")
   else,
      outtbllib = Userid()"."outtbllib
 
   outtbl     = KEYWD("INTO")
   if outtbl    = "" then helpmsg = helpmsg ,
          " 'INTO outtbl' is required. "
   else do
      if state = "OK" then do          /* outtbllib exists           */
         state = Sysdsn("'"outtbllib"("outtbl")'")
         if state <> "OK" then,
            helpmsg = helpmsg outtbl "was not found in" outtbllib". "
         end
      end
 
   intbllib   = KEYWD("FROM")
   if intbllib  = "" then helpmsg = helpmsg,
              " 'FROM intbllib' is required. "
   else do
      state = Sysdsn(intbllib)
      if state <> "OK" then,
         helpmsg = helpmsg "Status for" intbllib "is" state". "
      end
   if Left(intbllib,1) = "'" then,
      intbllib = Strip(intbllib,,"'")
   else,
      intbllib = Userid()"."intbllib
 
   parse var info  intbl  info
   if intbl     = "" then helpmsg = helpmsg ,
          " The source-table name is required. "
   else do
      if state = "OK" then do          /* intbllib exists            */
         state = Sysdsn("'"intbllib"("intbl")'")
         if state <> "OK" then,
            helpmsg = helpmsg intbl "was not found in" intbllib". "
         end
      end
 
   if helpmsg <> "" then,
      call HELP                        /* ...and don't come back     */
 
return                                 /*@ AK_KEYWDS                 */
/*
   Open intbl, open outtbl, verify that the KEYS and NAMES are
   equivalent.  Read intbl and write each row to outtbl.  Use TBADD
   if sw.0Keep; use TBMOD if sw.0Repl.
.  ----------------------------------------------------------------- */
B_TBL_OPS:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BA_OPEN_TABLES                 /*                           -*/
                                    if \sw.0error_found then,
   call BC_COMBINE                     /*                           -*/
   call BZ_CLOSE_TABLES                /*                           -*/
 
return                                 /*@ B_TBL_OPS                 */
/*
.  ----------------------------------------------------------------- */
BA_OPEN_TABLES:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LIBDEF ISPTLIB DATASET ID('"intbllib"') STACK"
   "TBOPEN"  intbl "WRITE"
   "TBQUERY" intbl "KEYS(inkeys) NAMES(innames)"
   "TBSAVE"  intbl "NAME($MRG$)"
   "TBEND"   intbl
   "LIBDEF ISPTLIB"
   parse var inkeys "(" inkeys ")"
   parse var innames "(" innames ")"
   call ZL_LOGMSG("INKEYS:"inkeys " INNAMES:"innames)
 
   "LIBDEF ISPTLIB DATASET ID('"outtbllib"') STACK"
   "TBOPEN"  outtbl "WRITE"
   "TBQUERY" outtbl "KEYS(outkeys) NAMES(outnames)"
   "LIBDEF ISPTLIB"
   parse var outkeys "(" outkeys ")"
   parse var outnames "(" outnames ")"
   call ZL_LOGMSG("OUTKEYS:"outkeys " OUTNAMES:"outnames)
 
   if inkeys  = outkeys  &,
      innames = outnames then nop
   else do
      zerrsm = "Table mismatch"
      zerrlm = "The KEYS and NAMES fields in the two tables ",
               "are inconsistent.  It is not possible to merge ",
               "incompatible tables."
      "SETMSG  MSG(ISRZ002)"
      call ZL_LOGMSG(zerrlm)
      sw.0error_found = 1
      return
      end
   /* outtbl is still open, but intbl has been closed.  Open the     */
   /* copy of intbl called $MRG$ for processing.                     */
   incopy = "$MRG$"
   "LIBDEF ISPTLIB DATASET ID('"intbllib"') STACK"
   "TBOPEN"  incopy   "WRITE"
   "LIBDEF ISPTLIB"
 
return                                 /*@ BA_OPEN_TABLES            */
/*
   Spin incopy and write (TBADD or TBMOD) each line into outtbl.
.  ----------------------------------------------------------------- */
BC_COMBINE:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if sw.0Keep then insert = "TBADD"
               else insert = "TBMOD"
   do forever                          /*                            */
      "TBSKIP"  incopy "SAVENAME(xvars)"   /* next row               */
      if rc > 0 then leave
 
      parse var xvars "("xvars ")"     /* no bananas                 */
      (insert) outtbl "SAVE("xvars")"
   end                                 /* forever                    */
   "TBQUERY" outtbl "ROWNUM(ROWCT)"
   call ZL_LOGMSG(outtbl "update complete, rows="rowct+0)
 
return                                 /*@ BC_COMBINE                */
/*
.  ----------------------------------------------------------------- */
BZ_CLOSE_TABLES:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LIBDEF ISPTABL DATASET ID('"outtbllib"') STACK"
   "TBCLOSE" outtbl "NEWCOPY"
   "LIBDEF ISPTABL"
 
   "TBEND   $MRG$"                     /* discard                    */
 
return                                 /*@ BZ_CLOSE_TABLES           */
/*
.  ----------------------------------------------------------------- */
C_VERIFY:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if sw.0Verify then monitor = 1
 
   "LIBDEF ISPTLIB DATASET ID('"outtbllib"') STACK"
   "TBOPEN " outtbl  "NOWRITE"
   "LIBDEF ISPTLIB"
 
   do forever
      "TBSKIP" outtbl  "SAVENAME(xvars)"
      if rc > 0 then leave
 
      parse var xvars "(" xvars ")"
      text = ""
      namelist = outkeys outnames xvars
      do Words(namelist)
         parse var namelist  name namelist
         text = text "  "name"="Value(name)
      end                              /* words                      */
      call ZL_LOGMSG(Strip(text))
   end                                 /* forever                    */
   "TBEND"   outtbl
 
return                                 /*@ C_VERIFY                  */
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
address TSO;"CLEAR" ; say ""
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      merges two ISPF tables.                                   "
say "                                                                          "
say "  Syntax:   "ex_nam"  <intbl>                                   (Required)"
say "                      <FROM intbllib>                           (Required)"
say "                      <INTO outtbl>                             (Required)"
say "                      <IN   outtbllib>                          (Required)"
say "                      <KEEP | REPLACE>                          (Required)"
say "                      <VERIFY>                                            "
say "                                                                          "
say "            intbl     names the table whose contents will be added to     "
say "                      <outtbl>.                                           "
say "                                                                          "
say "            intbllib  names the ISPF table library which contains <intbl> "
say "                                                                          "
say "            outtbl    names the resultant table, the joining of <intbl>   "
say "                      and <outtbl>                                        "
say "                                                                          "
say "            outtbllib names the ISPF table library which contains <outtbl>"
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "                                                                          "
say "            KEEP      orders that keys in <outtbl> will be kept in        "
say "                      preference to keys from <intbl>.                    "
say "                                                                          "
say "            REPLACE   orders that keys from <intbl> may replace keys in   "
say "                      <outtbl>.                                           "
say "                                                                          "
say "            VERIFY    orders that the combined table be listed after the  "
say "                      process is complete.                                "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                                                                          "
say "        NOUPDT:   by-pass all update logic.                               "
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
 
if sw.inispf then,
   address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/* --------------- REXXSKEL back-end removed ----------------------- */
