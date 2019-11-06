/* REXX    COMBINE    ...SYSPRINTs from PLI and LKED into a single
                      dataset and store.  All inputs and outputs
                      must be preallocated as by JCL.
 
           Written by Frank Clarke 20010129
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20050321 JAD added loop to accept input parms for infinite number
                  of datasets to be combined into $PRINT;
     20060120 fxc clarified HELP text;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
"NEWSTACK"
do words(info)
  parse var info ddn info
  "EXECIO * DISKR" ddn "(FINIS"
end
"EXECIO" queued() "DISKW $PRINT (FINIS"/* write combined             */
"DELSTACK"
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ COMBINE                   */
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
say "  "ex_nam"      combines files with incompatible DCBs into a single       "
say "                sequential dataset.  All DDs passed in the parm statement "
say "                must be pre-allocated.                                    "
say "                                                                          "
say "                (Originally built to merge a PL/I compiler listing and its"
say "                 Linkage Editor listing, "ex_nam" has been upgraded to    "
say "                 handle any number of files.                              "
say "                                                                          "
say "  Syntax:   "ex_nam"    ddn1 ddn2 ddn3 ... ddnx                           "
say "                      where ddn1 to ddnx are the DDNames to be combined   "
say "                      with their order.  The output dataset name is $PRINT"
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the             "
say "                  execution in REXX TRACE Mode.                           "
say "                                                                          "
say "                                                                          "
say "   Debugging tools can be accessed in the following manner:               "
say "        TSO "ex_nam"  parameters     ((  debug-options                    "
say "                                                                          "
say "   For example:                                                           "
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                                 "
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/* -------------- REXXSKEL back-end removed ------------------------ */
