/* REXX    ADDCMDS    Add one command table to the currently-resident
                      copy of ISPCMDS.  The user's personal command
                      table may thus be dynamically spliced to ISPCMDS.
                      Changes to the user's personal command table may
                      be implemented at any time by re-running this.
 
           Written by Frank Clarke in the Dark Ages
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     19981027 fxc REXXSKEL at last, v.19980225;
     19991117 fxc upgrade from v.19980225 to v.19991109;
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
"CONTROL ERRORS RETURN"                /* I'll handle my own errors  */
call A_INIT                            /*                           -*/
call B_TABLE_OPS                       /*                           -*/
 
exit                                   /*@ ADDCMDS                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   parse value "0 0" with,
         adds    dels    del_list
   parse value  info exec_name    with,
         tblname   .
   if tblname = "ADDCMDS" then tblname = "TMPCMDS"
   if Length(tblname) < 5 then tblname = tblname"CMDS"
   if monitor then say,
      "Using" tblname
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_TABLE_OPS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBQUERY" tblname                   /* tell me about this table   */
   if rc > 12 then do                  /* doesn't exist, maybe ?     */
      zerrsm = "TBQUERY error"
      if Symbol("zerrlm") = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"; return
      drop zerrlm                      /* make it a LIT again        */
      end
 
   if rc = 12 then "TBOPEN" tblname "NOWRITE" /* 12 = 'not open'     */
 
   "TBSORT" tblname "FIELDS(ZCTVERB,C,D)"
   do forever                          /* for every row in the table */
      "TBSKIP" tblname                 /* get next row               */
      if rc > 0 then leave
      if monitor then say,
         "   Working" zctverb
      do forever                       /* found a match on ISPCMDS   */
         "TBSCAN ISPCMDS NOREAD ARGLIST(ZCTVERB) CONDLIST(EQ)"
         if rc > 0 then leave
         if monitor then say,
            "        Delete from ISPCMDS"
         "TBDELETE ISPCMDS"            /* get rid of it              */
         del_list = del_list zctverb   /* make note of it            */
         dels = dels + 1               /* count a deleted row        */
      end                              /* forever (inner)            */
      "TBADD ISPCMDS"                  /* ... add a new line         */
      adds = adds + 1                  /* count an added row         */
      "TBTOP ISPCMDS"                  /* reposition to row 0        */
   end                                 /* forever (outer)            */
 
   "TBEND " tblname                    /* close and end              */
 
   if sw.0show then do                 /* user asked for a list      */
      "TBTOP ISPCMDS"                  /* reset to top               */
      do forever
         "TBSKIP ISPCMDS"              /* get another row            */
         if rc > 0 then leave          /* end of table               */
         say Left(zctverb,8) Right(zcttrunc,2) Left(zctact,66)
         say " " Left(zctdesc,72)
      end                              /* forever                    */
      end                              /* SHOW                       */
 
   ZERRSM = "A="adds "D="dels          /* short message              */
   ZERRLM = adds "lines were added;" dels "lines deleted."
   if dels <> 0 & ABS(adds-dels) > 1 then do
      ZERRSM = ZERRSM "(!)"
      ZERRLM = ZERRLM "Deleted verbs:" del_list
      ZERRALRM = "YES"
      end
   else ZERRALRM = "NO"
   address ISPEXEC "SETMSG  MSG(ISRZ002)"
 
return                                 /*@ B_TABLE_OPS               */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   sw.0show = SWITCH("SHOW")           /* user asked for a list ?    */
 
return                                 /*@ LOCAL_PREINIT             */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"      adds a user-command-table to the in-storage copy "
say "                of ISPCMDS.  Any existing command-table entries  "
say "                with matching names are deleted before the new   "
say "                commands are added.                              "
say "                                                                 "
say "  Syntax:   "ex_nam"  [cmd-tbl-name]                   (Defaults)"
say "                  ((  [SHOW]                                     "
say "                                                                 "
say "                                                                 "
say "            If cmd-tbl-name is not specified, the name defaults  "
say "            to 'TMPCMDS' for execname=ADDCMDS, and to the name of"
say "            the routine for any aliases.                         "
pull
"CLEAR"
say "   Debugging tools provided include:"
say "                                                                 "
say "        MONITOR:  displays key information throughout processing."
say "                  Displays most paragraph names upon entry."
say "                                                                 "
say "        NOUPDT:   by-pass all update logic."
say "                                                                 "
say "        BRANCH:   show all paragraph entries."
say "                                                                 "
say "        TRACE tv: will use value following TRACE to place"
say "                  the execution in REXX TRACE Mode."
say "                                                                 "
say "                                                                 "
say "   Debugging tools can be accessed in the following manner:"
say "                                                                 "
say "        TSO" exec_name"  parameters  ((  debug-options"
say "                                                                 "
say "   For example:"
say "                                                                 "
say "        TSO" exec_name " (( MONITOR TRACE ?R"
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/****** REXXSKEL back-end removed to save space.   *******/ 