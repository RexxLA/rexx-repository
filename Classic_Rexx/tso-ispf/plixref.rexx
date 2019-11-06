/* REXX    PLIXREF    adds statement number references to a PL/I
                      compiler listing.
 
           Written by Frank Clarke, Houston, 19981009
 
     Impact Analysis
.    SYSEXEC   PLIXREFO
.    SYSEXEC   PLIXREFE
 
     Modification History
     19981019 fxc retry line replacement with additional quote-marks;
     19981202 fxc eliminate duplicate refs on same statement;
     20010302 fxc bypass INSOURCE
     20010302 fxc make NOLOG and NOLINK defaults
     20020812 fxc sort list of uninitialized variables
     20020830 fxc use OVERLAY for adding text to the ends; use Doug
                  Nadel's trick to avoid DATALINE;
     20030212 fxc converted to be a driver; separate routines will
                  handle listings from the Optimizing Compiler and
                  the Enterprise Compiler.
     20030610 fxc HELP
     20040108 fxc stats reflect compile date/time
     20040427 fxc monitor with SYSUMON
     20040706 fxc SHORTPG only in PLIXREFE
 
*/
address ISREDIT
"MACRO (opts)"
parse source . . exec_name .
call A_INIT                            /*                           -*/
if Left(Strip(opts),2) = "?" then call HELP        /*               -*/
rc = Trace("O"); rc = Trace(tv)
 
address TSO "SYSUMON TOOL PLIXREF USER" Userid()
"RESET"
"(init) = LINENUM .zlast"              /* how many initial lines ?   */
"F P'^' FIRST"                         /* first non-blank            */
"(text) = LINE .zcsr"
if Left(text,9) = "15668-910" then do  /* Optimizer                  */
   newmac = "PLIXREFO"
   call O_SET_DATE                     /*                           -*/
   end                                 /* Optimizer                  */
else,
if Left(text,9) = "15655-H31" then do  /* Enterprise                 */
   newmac = "PLIXREFE"
   call E_SET_DATE                     /*                           -*/
   end                                 /* Enterprise                 */
else,
   do                                  /* Unknown                    */
   zerrhm = "ISR00001"
   zerralrm = "YES"
   zerrsm = "Unknown compiler"
   zerrlm = "The header information on this listing cannot be ",
            "mapped to a recognized compiler."
   address ISPEXEC "SETMSG MSG(ISRZ002)"
   return                              /* halt processing            */
   end                                 /* Unknown                    */
 
address TSO "ALTLIB   ACT APPLICATION(EXEC)  DA('DTAFXC.@@.EXEC') "
if rc > 4 then do
   say "ALTLIB failed, RC="rc
   exit
   end
 
(newmac) opts "TRACE" tv
if nosave = "" then "SAVE"
"(size) = LINENUM .zlast"              /* how many final lines ?     */
 
address ISPEXEC
"CONTROL ERRORS RETURN"
address ISREDIT "(dataset) = DATASET"
address ISREDIT "(memname) = MEMBER"
parse value "PLIXREF 01 00"  with ,
             id      vv mm  .
parse value init+0   size+0  with ,
            init     size   .
"LMINIT    DATAID(BASEID)   DATASET('"dataset"')"
"LMMSTATS  DATAID("baseid")" "MEMBER("memname")" "USER("id")",
          "VERSION("vv")" "MODLEVEL("mm")" "MODDATE4("changed")",
          "MODTIME("time")" "CREATED4("created")" "CURSIZE("size")",
          "INITSIZE("init")"
if rc > 0 then do
   zerrsm = "Stats Error"
   zerrlm = "Unable to modify to the ISPF Stats. RC = "rc
   "SETMSG MSG(ISRZ002)"
   end                                 /* rc > 0                     */
 
"LMFREE     DATAID("baseid")"
if sw.batch then address ISREDIT "END"
 
address TSO "ALTLIB DEACT APPLICATION(EXEC)"
 
exit                                   /*@ PLIXREF                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   address ISREDIT
 
   upper opts
   if Wordpos("TRACE",opts) > 0 then do
      parse var opts front "TRACE" tv back
      opts = front back
      end
   else tv  = "O"
 
   if Wordpos("NOSAVE",opts) > 0 then do
      parse var opts front "NOSAVE"   back
      opts = front back
      nosave = "NOSAVE"
      end
   else nosave = ""
 
   sw.batch     = sysvar("SYSENV")  = "BACK"
 
return                                 /*@ A_INIT                    */
/*
   Parse date from the top line.  Set 'changed', 'created', and 'time'.
.  ----------------------------------------------------------------- */
E_SET_DATE:                            /*@                           */
   address TSO
 
   parse var text 97 credate  time .
   changed = Translate(credate , "/" , ".")
   created = changed
 
return                                 /*@ E_SET_DATE                */
/*
   Parse date from the top line.  Set 'changed', 'created', and 'time'.
.  ----------------------------------------------------------------- */
O_SET_DATE:                            /*@                           */
   address TSO
 
   mth.     = "???"
   mth.JAN  = "Jan"
   mth.FEB  = "Feb"
   mth.MAR  = "Mar"
   mth.APR  = "Apr"
   mth.MAY  = "May"
   mth.JUN  = "Jun"
   mth.JUL  = "Jul"
   mth.AUG  = "Aug"
   mth.SEP  = "Sep"
   mth.OCT  = "Oct"
   mth.NOV  = "Nov"
   mth.DEC  = "Dec"
 
   parse var text 90 dd mmm yy   time .
   mmm = Left(mmm,3)
   cent = yy < 75 ; cc = 19 + cent
   chgdate = Date("S",dd mth.mmm cc""yy, "N")
   changed = Translate("CcYy/Mm/Dd" , chgdate , "CcYyMmDd")
   created = changed
 
return                                 /*@ O_SET_DATE                */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR" ; say ""
parse source  sys_id  how_invokt  exec_name  .
say
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      examines a PL/1 compiler listing for labels, GOTOs and    "
say "                calls.  The lines containing labels are then annotated    "
say "                with the statement numbers of their corresponding GOTOs   "
say "                and CALLs.  The GOTOs and CALLs are annotated to show the "
say "                statement number of the ENTRY label they reference.       "
say "                                                                          "
say "  Syntax:   "ex_nam"  <LOG>                                               "
say "                      <LINK>                                              "
say "                      <UNUSED>                                            "
say "                                                                          "
say "            <LOG>     requests that an external log of activity be kept   "
say "                      for this execution.  This is useful for debugging.  "
say "                                                                          "
say "            <LINK>    requests that the LinkEdit listing be kept.  The    "
say "                      default is to delete it.                            "
say "                                                                          "
say "            <UNUSED>  requests that unused variables be specially listed. "
say "                                                                          "
"NEWSTACK"; pull; "CLEAR"; "DELSTACK"
say "                                                                          "
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the execution in"
say "                  REXX TRACE Mode.                                        "
say "                                                                          "
say "                                                                          "
say "   Debugging tools can be accessed in the following manner:               "
say "                                                                          "
say "        TSO" ex_nam "    parameters    debug-options                      "
say "                                                                          "
say "   For example:                                                           "
say "                                                                          "
say "        TSO" ex_nam " (( TRACE ?R                                         "
 
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
