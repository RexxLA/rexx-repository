/* REXX    CMDUPD     will insert a command to a specific command table.
 
           Written by Frank Clarke, Richmond, 19991112
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     ccyymmdd xxx .....
                  ....
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
call ispvcall                          /*                            */
 
call A_INIT                            /*                           -*/
                                    if \sw.0error_found then,
call B_CHECK_TABLE                     /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ CMDUPD                    */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call AA_KEYWDS                      /*                           -*/
   "NEWSTACK"
   "LA  ISPTABL  ((STACK"              /* allocation for ISPTABL     */
   pull  allocds
   "DELSTACK"
   tblstat = Sysdsn("'"Strip(allocds)"("$tn$")'")
   if tblstat <> "OK" then do
      say       $tn$ "is not in your table-output library. ",
                "ISPTABL must contain a copy of the table to be",
                "modified."
      sw.0error_found = "1"
      end
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   $tn$         = KEYWD("TABLE")
   key          = KEYWD("COMMAND")
   parse value    KEYWD("TRUNC") "0"   with   trunc  .
   action       = KEYPHRS("ACTION")
   desc         = KEYPHRS("DESC")
 
   if $tn$ = "" then helpmsg = helpmsg,
      "TABLE is required. "
   if key  = "" then helpmsg = helpmsg,
      "COMMAND is required. "
   if action  = "" then helpmsg = helpmsg,
      "ACTION is required. "
   if desc = "" then helpmsg = helpmsg,
      "DESC is required. "
 
   if helpmsg <> "" then call HELP     /* ...and don't come back     */
 
return                                 /*@ AA_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
B_CHECK_TABLE:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "CONTROL ERRORS RETURN"             /* I'll handle my own         */
   parse value "? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?" with,
                $cdate $ctime $udate $utime $user,
                $svc $stat1 $stat2 $stat3 .
   parse value "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" with,
                $rcrt $rcurr $rupd $tblupd $retcode .
 
   "TBSTATS" $tn$ "CDATE($cdate) CTIME($ctime)",
                  "UDATE($udate) UTIME($utime) USER($user)",
                  "ROWCREAT($rcrt) ROWCURR($rcurr) ROWUPD($rupd)",
                  "TABLEUPD($tblupd) SERVICE($svc) RETCODE($retcode)",
                  "STATUS1($stat1) STATUS2($stat2) STATUS3($stat3)"
 
   if $stat1 = 1 then do               /* table on disk              */
      call B1_ONDISK                   /*                           -*/
      end ; else,
   if $stat1 = 2 then do               /* table not on disk          */
      call B2_NOTONDISK                /*                           -*/
      end ; else,
   if $stat1 = 3 then do               /* no ISPTLIB                 */
      zerrsm = "No ISPTLIB."
      zerrlm = exec_name "("BRANCH("ID")")",
               "You appear to have no table library.  You should",
               "probably correct that. "exec_name", in any case,",
               "cannot update what doesn't exist."
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"
      end
 
return                                 /*@ B_CHECK_TABLE             */
/*
   The table is on disk.  Is it OPEN ?  If it's OPEN, it may also be
   unavailable.  TBCLOSE and reopen WRITE, if necessary.  TBPUT the
   required row.  Restore the table to its original condition and bail.
 
   1   - not open.           open write/put/close
   2,4 - open/nowrite.  end, open write/put/close.  open nowrite.
   3,5 - open/write.                    put/save
.  ----------------------------------------------------------------- */
B1_ONDISK:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if Wordpos($stat2,"  2   4  ") > 0 then do      /* TBEND          */
      call B1A_TBEND                   /*                           -*/
      end
                                    if sw.0error_found then return
   if Wordpos($stat2,"1 2   4  ") > 0 then do      /* TBOPEN WRITE   */
      call B1B_OPENWRITE               /*                           -*/
      end
                                    if sw.0openfail  = 0 then,
   if Wordpos($stat2,"1 2 3 4 5") > 0 then do      /* TBPUT          */
      call B1C_TBPUT                   /*                           -*/
      end
                      if sw.0putfail + sw.0openfail  = 0 then,
   if Wordpos($stat2,"    3   5") > 0 then do      /* TBSAVE         */
      call B1D_TBSAVE                  /*                           -*/
      end
                      if sw.0putfail + sw.0openfail  = 0 then,
   if Wordpos($stat2,"1 2   4  ") > 0 then do      /* TBCLOSE        */
      call B1E_TBCLOSE                 /*                           -*/
      end
 
   if Wordpos($stat2,"  2   4  ") > 0 then do      /* TBOPEN NOWRITE */
      "TBOPEN" $tn$ "NOWRITE"
      end
 
return                                 /*@ B1_ONDISK                 */
/*
.  ----------------------------------------------------------------- */
B1A_TBEND:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBEND" $tn$
   if rc > 0 then do
      zerrsm = "TBEND failed"
      if Symbol("zerrlm") = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      drop zerrlm                      /* make it a LIT again        */
      sw.0error_found = "1"; return
      end
 
return                                 /*@ B1A_TBEND                 */
/*
.  ----------------------------------------------------------------- */
B1B_OPENWRITE:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBOPEN" $tn$ "WRITE"
   if rc > 0 then do
      zerrsm = "TBOPEN/WRITE failed"
      if Symbol("zerrlm") = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      drop zerrlm                      /* make it a LIT again        */
      sw.0error_found = "1"
      sw.0openfail    = "1"
      end
 
return                                 /*@ B1B_OPENWRITE             */
/*
.  ----------------------------------------------------------------- */
B1C_TBPUT:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBTOP" $tn$
 
   do forever
      "TBSKIP" $tn$                    /* next row                   */
      if rc > 0 then leave             /* no more rows               */
      if zctverb = key then leave      /* this is the row            */
   end                                 /* forever                    */
 
   zctverb     = key
   zcttrunc = trunc
   zctact      = action
   zctdesc     = desc
   "TBPUT" $tn$
   if rc > 0 then do
      zerrsm = "TBPUT failed"
      if Symbol("zerrlm") = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      drop zerrlm                      /* make it a LIT again        */
      sw.0error_found = "1"
      sw.0putfail     = "1"
      end
 
return                                 /*@ B1C_TBPUT                 */
/*
.  ----------------------------------------------------------------- */
B1D_TBSAVE:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBSAVE" $tn$
   if rc > 0 then do
      zerrsm = "TBSAVE failed"
      if Symbol("zerrlm") = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      drop zerrlm                      /* make it a LIT again        */
      sw.0error_found = "1"
      sw.0savefail    = "1"
      end
 
return                                 /*@ B1D_TBSAVE                */
/*
.  ----------------------------------------------------------------- */
B1E_TBCLOSE:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBCLOSE" $tn$
   if rc > 0 then do
      zerrsm = "TBPUT failed"
      if Symbol("zerrlm") = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      drop zerrlm                      /* make it a LIT again        */
      sw.0error_found = "1"
      sw.0putfail     = "1"
      end
 
return                                 /*@ B1E_TBCLOSE               */
/*
   There is an ISPTLIB, but it doesn't contain this table.  Ask the
   user to choose which library is the proper one to use for output.
   Build a new table, populate it, and write to ISPTABL.
.  ----------------------------------------------------------------- */
B2_NOTONDISK:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
 
return                                 /*@ B2_NOTONDISK              */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"      will insert a command to a specific command table."
say "                                                                  "
say "  Syntax:   "ex_nam"  <TABLE    tblname>                (Required)"
say "                      <COMMAND  cmdword>                (Required)"
say "                      <TRUNC    len>                    (Defaults)"
say "                      <ACTION  .. cmdstr  ..>           (Required)"
say "                      <DESC    .. descstr ..>           (Required)"
say "                                                                  "
say "            <tblname> is the name of the command table to be      "
say "                      updated.                                    "
say "                                                                  "
say "            <cmdword> is the command which keys the action.       "
say "                                                                  "
say "            <len>     specifies the minimum abbreviation length   "
say "                      for the command-word.   Default=0.          "
say "                                                                  "
say "            <cmdstr>  is the KEYPHRS-format string which is to be "
say "                      executed for the <cmdword>.                 "
say "                                                                  "
say "            <descstr> is a KEYPHRS-format action-description.     "
pull
"CLEAR"
say "   Debugging tools provided include:                              "
say "                                                                  "
say "        MONITOR:  displays key information throughout processing. "
say "                  Displays most paragraph names upon entry.       "
say "                                                                  "
say "        NOUPDT:   by-pass all update logic.                       "
say "                                                                  "
say "        BRANCH:   show all paragraph entries.                     "
say "                                                                  "
say "        TRACE tv: will use value following TRACE to place the     "
say "                  execution in REXX TRACE Mode.                   "
say "                                                                  "
say "                                                                  "
say "   Debugging tools can be accessed in the following manner:       "
say "                                                                  "
say "        TSO "ex_nam"  parameters     ((  debug-options            "
say "                                                                  "
say "   For example:                                                   "
say "                                                                  "
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                         "
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*             REXXSKEL back-end removed for space                   */