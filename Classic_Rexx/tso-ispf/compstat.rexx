/* REXX    COMPSTAT   sets ISPF member stats to the date of the
                      compiler listing.
 
           Cloned from PLIXREF
 
     Impact Analysis
.    SYSEXEC   SHORTPG
 
     Modification History
     20040108 fxc cloned from PLIXREF
     20040315 fxc id=CSTATS
     20040727 fxc don't SHORTPG if ASIS; don't RESET; don't END unless
                  batch;
 
*/
address ISREDIT
"MACRO (opts)"
if Left(Strip(opts),1) = "?" then call HELP        /*               -*/
call A_INIT                            /*                           -*/
upper opts
parse var opts "TRACE" tv .
parse value tv "N" with tv .
rc=Trace("O"); rc = Trace(tv)
 
"(init) = LINENUM .zlast"              /* how many initial lines ?   */
"F P'^' FIRST"                         /* first non-blank            */
"(text) = LINE .zcsr"
if Left(text,9) = "15668-910" then do  /* Optimizer                  */
   call O_SET_DATE                     /*                           -*/
   end                                 /* Optimizer                  */
else,
if Left(text,9) = "15655-H31" then do  /* Enterprise                 */
   if sw.0_Asis = 0 then do            /* OK to change               */
      "SHORTPG"
      "SAVE"
      end                              /* not ASIS                   */
   call E_SET_DATE                     /*                           -*/
   end                                 /* Enterprise                 */
else,
   do                                  /* Unknown                    */
   zerrhm = "ISR00001"
   zerralrm = "YES"
   zerrsm = "Unknown compiler"
   zerrlm = "The header information on this listing cannot be ",
            "mapped to a recognized compiler."
   if sw.0_Batch = 0 then,
      address ISPEXEC "SETMSG MSG(ISRZ002)"
   return                              /* halt processing            */
   end                                 /* Unknown                    */
 
"(size) = LINENUM .zlast"              /* how many final lines ?     */
 
address ISPEXEC
"CONTROL ERRORS RETURN"
address ISREDIT "(dataset) = DATASET"
address ISREDIT "(memname) = MEMBER"
parse value "CSTATS  01 00"  with ,
             id      vv mm  .
parse value init+0   size+0  with ,
            init     size   .
"LMINIT    DATAID(BASEID)   DATASET('"dataset"')"
"LMMSTATS  DATAID("baseid")" "MEMBER("memname")" "USER("id")",
          "VERSION("vv")" "MODLEVEL("mm")" "MODDATE4("changed")",
          "MODTIME("time")" "CREATED4("created")" /*"CURSIZE("size")",
          "INITSIZE("init")" */
if rc > 0 then do
   zerrsm = "Stats Error"
   zerrlm = "Unable to modify to the ISPF Stats. RC = "rc
   if sw.0_Batch = 0 then,
      "SETMSG MSG(ISRZ002)"
   end                                 /* rc > 0                     */
 
"LMFREE     DATAID("baseid")"
if sw.0_Batch then,
   address ISREDIT "END"
exit                                   /*@ COMPSTAT                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   address ISREDIT
 
   sw. = 0
   sw.0_Batch   = sysvar("SYSENV")  = "BACK"
   sw.0_Asis    = WordPos("ASIS",opts) > 0
 
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
 
say "  "ex_nam"      resets the ISPF member statistics to the date shown on    "
say "                the first line of a compiler listing.  This routine is    "
say "                not designed to work onanything other than a compiler     "
say "                listing.                                                  "
say "                                                                          "
say "  Syntax:   "ex_nam"  <no parms>                                          "
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
