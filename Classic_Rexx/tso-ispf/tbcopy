/* REXX    .......    Make a copy of an ISPF table with modifications.
                      This routine is intended to be copied and
                      customized apllication-by-application.
                      Paragraph MA_CUSTOMIZE is the only place
                      application-specific code should be needed.
                      MA_CUSTOMIZE is called for each row retrieved
                      from the input table.  A TBADD to the output
                      table is done immediately on return from
                      MA_CUSTOMIZE.

                Written by Frank Clarke, Oldsmar, FL

     Impact Analysis
.    SYSPROC   TRAPOUT

     Modification History
     19980601 fxc upgrade from v.960506 to v.19980225; DECOMM;
     20000204 fxc upgrade from v.19980225 to v.19991109;

*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.19991109      */
arg parms "((" opts

signal on syntax
signal on novalue

call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */

call A_INIT                            /*                           -*/
call B_OPEN_TBL                        /*                           -*/
                                   if \sw.0error_found then,
call M_MAIN_PROCESS                    /*                           -*/

call Z_CLOSE_TBL                       /*                           -*/

exit
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO

   call AA_KEYWDS                      /*                           -*/

   parse var info  intbl outtbl .      /* from- and to-table         */
   parse value outtbl  "$TMP"   with,
               outtbl   .

   parse value "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" with,
         ct   .

   openmode.0  = "WRITE"               /* based on NOUPDT            */
   openmode.1  = "NOWRITE"

return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO

   replace   = SWITCH("REPLACE")
   tbltype   = KEYWD("TYPE")           /* AA, maybe                  */
   if tbltype = "" then do
      helpmsg = "TYPE is required."
      call HELP
      end
   inlib     = KEYWD("FROM")           /* source ISPTLIB             */
   outlib    = KEYWD("TO")             /* target ISPTABL             */
   parse value outlib inlib   with,
               outlib   .

return                                 /*@ AA_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
B_OPEN_TBL:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   "CONTROL ERRORS RETURN"
   if inlib <> "" then,
      "LIBDEF  ISPTLIB  DATASET  ID("inlib") STACK"

   "TBSTATS" intbl "STATUS1(s1) STATUS2(s2)"
   if s1 > 1 then do
      say "Table" intbl "not available."
      sw.0error_found = "1"
      end
   if s2 = 1 then,                     /* not open                   */
      "TBOPEN " intbl "NOWRITE"
   else "TBTOP" intbl

   if inlib <> "" then,
      "LIBDEF  ISPTLIB"

return                                 /*@ B_OPEN_TBL                */
/*
.  ----------------------------------------------------------------- */
M_MAIN_PROCESS:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   address TSO "TBLGEN" tbltype "TBLNAME" outtbl "REPLACE" openmode.noupdt

   do forever
      "TBSKIP" intbl "SAVENAME(xvars)"    /* next row                */
      if rc <> 0 then leave
      parse var xvars    "(" xvars ")"
        /* ------------ customized code goes here ------------------ */
      call MA_CUSTOMIZE                /*                           -*/
        /* ------------ customized code ends here ------------------ */
      "TBADD " outtbl "SAVE("xvars")"/* add to output table          */
      ct = ct + 1
   end                                 /* forever                    */
   say "Forever loop ended: "ct "rows transferred."

return                                 /*@ M_MAIN_PROCESS            */
/*
.  ----------------------------------------------------------------- */
MA_CUSTOMIZE:                          /*@                           */
   if branch then call BRANCH
   address TSO


return                                 /*@ MA_CUSTOMIZE              */
/*
.  ----------------------------------------------------------------- */
Z_CLOSE_TBL:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   if outlib <> "" then,
      "LIBDEF  ISPTABL  DATASET  ID("outlib") STACK"

   "TBEND  " intbl                     /* finished with table        */
   if replace then slug = "NAME("intbl")" /* ready to replace        */
              else slug = ""
   if noupdt then,
      "TBEND"   outtbl                 /* purge                      */
   else,
      "TBCLOSE" outtbl slug            /* save                       */

   if outlib <> "" then,
      "LIBDEF  ISPTABL"

return                                 /*@ Z_CLOSE_TBL               */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   if branch then call BRANCH
   address TSO


return                                 /*@ LOCAL_PREINIT             */
/*
. -------------------------------------------------------------------*/
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)
say "  "ex_nam"      copies one ISPF table to another, potentially     "
say "                replacing the original.  This EXEC needs to be    "
say "                customized for each re-use.                       "
say "                                                                  "
say "  Syntax:   "ex_nam"  [input-tbl-name]                  (Required)"
say "                      [output-tbl-name]                 (Required)"
say "                      [TYPE   tblgen-id]                (Required)"
say "                      [FROM   input-tbl-lib]                      "
say "                      [TO     output-tbl-lib]           (Defaults)"
say "                      [REPLACE]                                   "
say "                                                                  "
say "            If REPLACE is specified, the original table will be   "
say "            overwritten (if it is in a target position) by the    "
say "            regenerated table.                                    "
say "                                                                  "
say "                                                 .....more        "
pull
"CLEAR"
say "            [input-tbl-name]    identifies the table to be        "
say "                        modified.                                 "
say "                                                                  "
say "            [output-tbl-name]    is required and must not be the  "
say "                        same as the input name.  This name is     "
say "                        required even if REPLACE is specified.    "
say "                                                                  "
say "            [tblgen-id]   identifies the 2-character identifier   "
say "                        from the AAMSTR table which defines the   "
say "                        TBCREATE parameters.  TBLGEN will be      "
say "                        called to TBCREATE a new table for        "
say "                        output.                                   "
say "                                                                  "
say "                                                 .....more        "
pull
"CLEAR"
say "            [input-tbl-lib]   identifies the library which        "
say "                        contains the [input-tbl-name].  ISPTLIB   "
say "                        will be searched if this is not           "
say "                        specified.                                "
say "                                                                  "
say "            [output-tbl-lib]   identifies the library which will  "
say "                        receive [output-tbl-name].  ISPTABL will  "
say "                        be used if neither this nor FROM is       "
say "                        specified.                                "
say "                                                                  "
say "                                                 .....more        "
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
say "        TSO "exec_name" parameters   ((  debug-options            "
say "                                                                  "
say "   For example:                                                   "
say "                                                                  "
say "        TSO "exec_name" (( MONITOR TRACE ?R                       "
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/****** REXXSKEL back-end removed to save space.   *******/ 