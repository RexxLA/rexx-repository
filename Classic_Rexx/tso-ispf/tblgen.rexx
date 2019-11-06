/* REXX    TBLGEN     TBCREATE according to specifics stored in
                      AAMSTR, the Master Table-of-Tables.
                      The structure of AAMSTR is:
                        Variable   T  Example
                        --------   -  -------------------
                        AATBLID    K  AA (for the AAMSTR table itself)
                        AATBLNM    N  AAMSTR
                        AAKEYS     N  AATBLID
                        AANAMES    N  AATBLNM AADESC AAKEYS AANAMES AASORT
                        AASORT     N  AATBLID,C,A
                        AADESC     N  Master Table

           Written by Frank Clarke, Oldsmar FL, 19980528

     Impact Analysis
.    SYSPROC   TRAPOUT

     Modification History
     20010223 fxc finally added help-text for DESCRIBE; wrapped CLEAR
                  commands with NEWSTACK/DELSTACK;
     20010720 fxc WIDEHELP;

*/
address ISPEXEC                        /* REXXSKEL ver.19980225      */
arg parms "((" opts

signal on syntax
signal on novalue

call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */

"CONTROL ERRORS RETURN"
call A_INIT                            /*                           -*/
call B_READ_MSTR                       /*                           -*/
                                   if \sw.0error_found then,
call C_BUILD                           /*                           -*/

if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ TBLGEN                    */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   call AA_KEYWDS                      /*                           -*/
   openmode.0  = "WRITE"               /* based on NOUPDT            */
   openmode.1  = "NOWRITE"

return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   tblnm        = KEYWD("TBLNAME")
   sw.0testmode = SWITCH("TEST")
   sw.0describe = SWITCH("DESCRIBE")
   parse var info  aatblid   genparms

return                                 /*@ AA_KEYWDS                 */
/*
   Get the TBCREATE info from table AAMSTR
.  ----------------------------------------------------------------- */
B_READ_MSTR:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   "LIBDEF  ISPTLIB  DATASET  ID("isptlib")  STACK"
   "TBSTATS" $tn$ "STATUS1(s1) STATUS2(s2)"
   if s1 > 1 then do
      say "Table" $tn$ "not available."
      exit
      end; else,
   if s2 = 1 then,                     /* not open                   */
      "TBOPEN " $tn$ "NOWRITE"
   else "TBTOP" $tn$
   "LIBDEF  ISPTLIB"

   "TBGET" $tn$                        /* aatblid is already set     */
   if rc > 0 then do
      zerrsm = "TBGET failed for key="aatblid
      zerrlm = exec_name "("BRANCH("ID")")",
               "Row not found for ID" aatblid,
               "in "Strip(isptlib,,"'")"("$tn$").",
               " Are you using the correct ISPTLIB dataset?"
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"
      end
   "TBEND" $tn$

return                                 /*@ B_READ_MSTR               */
/*
.  ----------------------------------------------------------------- */
C_BUILD:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   parse value tblnm aatblnm   with  tblnm  .

   if sw.0describe then do
      queue  "KEYS("aakeys") NAMES("aanames") SORT("aasort")"
      return
      end
   else,
   if sw.0testmode then do
      address TSO "CLEAR"
      say "TBLGEN will issue the following commands:"
      say ""
      say,
      "TBCREATE" tblnm "KEYS("aakeys") NAMES("aanames")" genparms
      say ""
      end
   else,
      "TBCREATE" tblnm "KEYS("aakeys") NAMES("aanames")" genparms

   if rc > 4 then do
      zerrsm = "TBCREATE failed."
      if Symbol('zerrlm') = "LIT" then,
         zerrlm = "No additional diagnostics produced.  RC was" rc
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"; return
      end ; else,
   if rc > 0 then do
      zerrsm = "Table was replaced."
      zerrlm = exec_name "("BRANCH("ID")")",
               "TBCREATE replaced existing table" aatblnm"."
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      end

   if aasort <> "" then do
      if sw.0testmode then do
         say ""
         say,
         "TBSORT" tblnm "FIELDS("aasort")"
         say ""
         end
      else,
         "TBSORT" tblnm "FIELDS("aasort")"
      end

return                                 /*@ C_BUILD                   */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO

   parse value KEYWD("ISPTLIB") "..."   with,
               isptlib   .

   parse value KEYWD("ISPTABL")  isptlib    with,
               isptabl   .

   parse value KEYWD("USETBL")  "AAMSTR"   with,
               $tn$      .

return                                 /*@ LOCAL_PREINIT             */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end

ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"      builds a new ISPF table from parameters stored in the     "
say "                Table Master table.                                       "
say "                                                                          "
say "  Syntax:   "ex_nam"  [table-id]                       (Required)         "
say "                      [TEST]                                              "
say "                      [DESCRIBE]                                          "
say "                      [TBLNAME table-name]             (Defaults)         "
say "                      [add'l TBCREATE parameters]                         "
say "                   (( [ISPTLIB input-dsn]                                 "
say "                      [ISPTABL output-dsn]                                "
say "                      [USETBL  master-table]                              "
say "                                                                          "
say "            [table-id]  is the two-character identifier which is the key  "
say "                      of AAMSTR.                                          "
say "                                                                          "
say "            [TEST]    instructs" exec_name "to display the commands which "
say "                      would have been issued in the absence of 'TEST'.    "
say "                                                                          "
say "            [DESCRIBE]  instructs" exec_name "to return, via the data     "
say "                      stack, a description of the table.  The following   "
say "                      line is placed on the stack:                        "
say "                         KEYS(...) NAMES(...) SORT(...)                   "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "            [table-name]  is the name to be given to the newly-created    "
say "                      table.  If [table-name] is not specified, the       "
say "                      default name stored in the master table, if any, is "
say "                      used.                                               "
say "                                                                          "
say "            [input-dsn]  is the name of the table library which contains  "
say "                      the master-table.  If no value is specified, it     "
say "                      defaults to ...                                     "
say "                                                                          "
say "            [output-dsn]  is the name of the table library used for       "
say "                      storing the newly-created table.  If not specified, "
say "                      the current value of ISPTLIB is used.               "
say "                                                                          "
say "            [master-table]  is the name of the table from which to obtain "
say "                      the definition used to build the new table.  If not "
say "                      specified, 'AAMSTR' will be used.                   "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
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
say "        TSO" exec_name"  parameters  ((  debug-options                    "
say "                                                                          "
say "   For example:                                                           "
say "                                                                          "
say "        TSO" exec_name " (( MONITOR TRACE ?R                              "
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/****** REXXSKEL back-end removed to save space.   *******/