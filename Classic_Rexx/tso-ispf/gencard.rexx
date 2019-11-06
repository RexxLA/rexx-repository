/* REXX    GENCARD    Accept text in parms, write it onto file $OUT
                      stripped, but otherwise as-is.
 
           Written by Frank Clarke, Oldsmar FL
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     19950612 fxc KEYWD wasn't working; upgrade to latest REXXSKEL;
     19980908 fxc upgrade from v.950501 to v.19980225; RXSKLY2K;
                  DECOMM; add confirmation message via SAY to
                  SYSTSPRT;
     20010502 fxc upgrade from v.19980225 to v.19991109; update HELP
                  text;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.19980225      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
if pos    ^= "" then parms = Copies(" ",pos-1 )parms; else
if indent ^= "" then parms = Copies(" ",indent)parms
address TSO
push parms
"EXECIO" queued() "DISKW $OUT (FINIS"  /* must be pre-allocated      */
if sw.batch then do
   say
   say " ------Output of" exec_name "delivered to FILE($OUT)--------"
   say
   say "----+----1----+----2----+----3----+----4----+----5----+----6----+----7"
   say parms
   say
   end
 
if \sw.nested then call DUMP_QUEUE
exit                                   /*@ GENCARD                   */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   indent = KEYWD("INDENT")
   pos    = KEYWD("POS")
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  GENCARD       Accept text in 'parms', write it onto file $OUT   "
say "                stripped, but otherwise as-is.                    "
say "                                                                  "
say "  Syntax:   GENCARD   <text>                                      "
say "                  ((  <INDENT i>                  (KEYWD in <opts>"
say "                      <POS    p>                  (KEYWD in <opts>"
say "                                                                  "
say "            <i>       specifies the number of characters to indent"
say "                      the text.                                   "
say "                                                                  "
say "            <p>       specifies the desired position of the first "
say "                      character of <text>                         "
say "                                                                  "
say "                                                                  "
say "            INDENT and POS are logically mutually exclusive.  If  "
say "            both are specified, POS is selected.                  "
say "                                                                  "
say "                                               more......         "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "                                                                  "
say "  Examples:                                                       "
say "                                                                  "
say "  GENCARD was designed for automating JCL PROCs which might       "
say "  otherwise require manual intervention.  A good example is a     "
say "  PanValet retrieve which requires a control card of the form:    "
say "          ++WRITE,WORK,module                                     "
say "                                                                  "
say "                                                                  "
say "  Normally, one would be forced to rely on other processes to     "
say "  generate the control card, but with GENCARD, if the variable    "
say "  data appears as a parameter in the PROC, the line can be        "
say "  generated dynamically, written to temporary or permanent DASD,  "
say "  and referenced by following steps.  Sample JCL for a PanValet   "
say "  ++WRITE follows.  Other applications would be implemented in a  "
say "  similar fashion.                                                "
say "                                                                  "
say "                                               more......         "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "                                                                  "
say "  SAMPLE JCL TO GENERATE A PANVALET ++WRITE STATEMENT:            "
say "                                                                  "
say "    //REXX   EXEC PGM=IKJEFT01,                                   "
say "    //       PARM='GENCARD ++WRITE,WORK,&MODULE.'                 "
say "    //SYSPROC  DD DISP=SHR,DSN=DTCFXC1.PUBLIC.EXEC                "
say "    //SYSTSPRT DD SYSOUT=*                                        "
say "    //SYSTSIN  DD DUMMY                                           "
say "    //$OUT     DD DISP=(NEW,PASS),UNIT=VIO,                       "
say "    //            SPACE=(80,(1)),DCB=(RECFM=F,LRECL=80)           "
say "        (&MODULE to be supplied as a PROCedure parameter).        "
say "                                                                  "
say "  GENCARD will take all the remaining text in PARM and replicate  "
say "  it left-justified in an 80-byte field.  This is written to file "
say "  $OUT which must be pre-allocated.                               "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                              "
say "                                                                  "
say "        MONITOR:  displays key information throughout processing. "
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
/*   REXXSKEL back-end removed for space   */