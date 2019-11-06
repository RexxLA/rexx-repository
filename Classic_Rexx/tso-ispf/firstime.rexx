/* REXX    FIRSTIME   Do a process if for the first time <whenever>.
 
                Written by Frank Clarke, Oldsmar, FL
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     19950221 fxc "THIS WEEK" doesn't work because 'this' was in lower
                  case and was being compared against upper case text
     19950329 fxc failed on "this wednesday" because no check was being
                  done other than 'is today the right day?'; any other
                  day produced HELP text
     19960612 fxc squeeze space out of line before rewriting; lack of
                  this caused an odd failure in which the data
                  continually got longer with each iteration until it
                  was lost off the end of the file; upgrade to REXXSKEL;
     19970212 fxc recognize NOUPD and NOUPDT as being equivalent;
                  upgrade from v.960606 to v.970113;
     19980604 fxc upgrade from v.970113 to v.19980225;
                  RXSKLY2K; DECOMM; standardize;
     19991103 fxc drop support for NOUPD
     20010601 fxc HELP was doing a RETURN instead of an EXIT
     20160714 fxc eliminate FTINIT
     20161020 fxc smooth HELP-text
 
*/
address TSO                            /* REXXSKEL ver.19980225      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /* Initialization            -*/
call B_GET_FTC                         /* Read existing data        -*/
call C_CHECK_FTC                       /* When did I last run?      -*/
call D_WRITE_FTC                       /* Write new run date info   -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ FIRSTIME                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   run = "0"                           /* off by default             */
   weekdays = "SUNDAY MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY SATURDAY"
 
   ftc = "'"Userid()".FTC'"
 
   parse upper value  Date("B") Date("S") Date("W") with,
                      daily     sdate     dayname .
   day_idx = daily//7
   weekly  = daily - day_idx           /* start of the week          */
   monthly = Left(sdate,6)             /* current month - YYYYMM     */
   annual  = Left(sdate,4)             /* current year  - YYYY       */
                                       /* parse parms                */
   parse var parms token1 rest
   if token1 = "THIS" then,            /* token-1 may be "this"      */
      parse var rest  token1 rest      /* 1st rem token is t-scale   */
 
return                                 /*@ A_INIT                    */
/*
   Read the user's personal FTC file (contains info about when this
   routine was last run).
.  ----------------------------------------------------------------- */
B_GET_FTC:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"                          /* fence off a buffer         */
   ftcalc.0  = "NEW CATALOG UNIT(SYSDA) SPACE(1) TRACKS",
               "RECFM(V B) LRECL(255) BLKSIZE(0)"
   ftcalc.1  = "SHR"                   /* if it already exists...    */
   tempstat = Sysdsn(ftc) = "OK"       /* 1=exists, 0=missing        */
   "ALLOC FI($TMP) DA("ftc") REU" ftcalc.tempstat
   "ALLOC FI(CTL) DA("ftc") SHR REU"
   "FREE  FI($TMP)"
   if tempstat = 0 then do
      call BA_GENLINE                  /* establish line            -*/
      end
   else do
      "EXECIO 1 DISKR CTL (FINIS"
      pull line
      line = Space(line,1)             /* condense                   */
      end
   "DELSTACK"                          /* purge the buffer           */
   if monitor then say "Contents of" ftc":" line
 
return                                 /*@ B_GET_FTC                 */
/*
   FTC was non-existent; build a new one.
.  ----------------------------------------------------------------- */
BA_GENLINE:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   line = "D:"0 "W:"0 "M:"0 "A:"0 "D0:"0 ,
          "D1:"0 "D2:"0 "D3:"0 "D4:"0 "D5:"0 "D6:"0
   push line
   "EXECIO 1 DISKW CTL (FINIS"
 
return                                 /*@ BA_GENLINE                */
/*
.  ----------------------------------------------------------------- */
C_CHECK_FTC:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
   select                              /* what kind of check ?       */
      when WordPos(token1,"TODAY DAY DAILY") > 0 then do
         parse var line front "D:" last_x back
         if last_x < daily then do
            line = front "D:"daily back
            run="1"
            end
         end                           /* Daily                      */
      when WordPos(token1,"WEEK WEEKLY") > 0 then do
         parse var line front "W:" last_x back
         if last_x < weekly then do
            line = front "W:"weekly back
            run="1"
            end
         end                           /* Weekly                     */
      when WordPos(token1,"MONTH MONTHLY") > 0 then do
         parse var line front "M:" last_x back
         if last_x < monthly then do
            line = front "M:"monthly   back
            run="1"
            end
         end                           /* Monthly                    */
      when WordPos(token1,"YEAR YEARLY ANNUALLY") > 0 then do
         parse var line front "A:" last_x back
         if last_x < annual then do
            line = front "A:"annual back
            run="1"
            end
         end                           /* Annually                   */
      when Wordpos(token1,weekdays) >  0 then do
         if token1 <> dayname then,    /* restricted to specific day */
            update = "0"               /* not the right day...       */
         else do                       /* we can run today           */
            parse var line front "D0:" last.0 "D1:" last.1 "D2:" last.2,
                    "D3:" last.3 "D4:" last.4 "D5:" last.5 "D6:" last.6,
                    back               /* Monday=0, Tuesday=1, Sunday=6 */
            if last.day_idx < daily then do
               last.day_idx = daily
               line = front "D0:"last.0 "D1:"last.1 "D2:"last.2,
                            "D3:"last.3 "D4:"last.4 "D5:"last.5,
                            "D6:"last.6 back
               run="1"
               end                     /* file LT current            */
            end                        /* we can run today           */
         end                           /* Specific day               */
      otherwise do
         "CLEAR"
         helpmsg = "ERR ===> Cycle indicator '"token1"' not recognized."
         call HELP
         update = "0"                  /* don't write to CTL         */
         end
   end                                 /* select                     */
 
   if run then do                      /* to run or not to run ?     */
      if monitor then say "Running command:" rest
      address TSO rest
      end
   else,
      if monitor then say "Ignoring command:" rest
 
return                                 /*@ C_CHECK_FTC               */
/*
.  ----------------------------------------------------------------- */
D_WRITE_FTC:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
   if update then do                   /* to updt or not to updt ?   */
      if monitor then,
         say "Replace FTC with <"line">"
      line = Space(line,1)
      push line
      "EXECIO 1 DISKW CTL (FINIS"
      end
   else,
      if monitor then,
         say "FTC was not replaced"
   "FREE FI(CTL)"
 
return                                 /*@ D_WRITE_FTC               */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   if branch then call BRANCH
   address TSO
 
   update = \noupdt
 
return                                 /*@ LOCAL_PREINIT             */
/*
. ------------------------------------------------------------------ */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
 
say "  FIRSTIME    controls execution of once-per-period events.               "
say "                                                                          "
say "  Syntax:  FIRSTIME <cycle-indicator>                                     "
say "                    <command-to-execute>                                  "
say "                                                                          "
say "    <cycle indicator> may be any ONE of the following:                    "
say "          <DAY|WEEK|MONTH|YEAR>, <TODAY>,                                 "
say "            <DAILY>, <WEEKLY>, <MONTHLY>, <YEARLY>, <ANNUALLY>,           "
say "          <MONDAY>, <TUESDAY>, <WEDNESDAY>, <THURSDAY>, <FRIDAY>,         "
say "               <SATURDAY>, <SUNDAY>.                                      "
say "                                                                          "
say "    <command-to-execute> may be any TSO command which the user is         "
say "          authorized to issue.                                            "
say "                                                                          "
say "    When a day-of-the-week is specified as the cycle-indicator, execution "
say "      will occur ONLY on that day.                                        "
say "                                                                          "
say "    When 'this' is the first word of the cycle-indicator it is ignored.   "
say "                                                                          "
say "                                                 more....                 "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "                                                                          "
say "    NOTE ::::                                                             "
say "           Occasionally it is necessary to run more than one task per     "
say "           time period, for example: several tasks needing to be done     "
say "           each week.  The normal mode of operation is to run once per    "
say "           period, so the second call to "exec_name" fails (because it    "
say "           just ran).  To run multiple tasks, specify NOUPDT for all but  "
say "           the last:                                                      "
say "                                                                          "
say "             TSO FIRSTIME THIS WEEK PROCA ((NOUPDT                        "
say "             TSO FIRSTIME THIS WEEK PROCB ((NOUPDT                        "
say "             TSO FIRSTIME THIS WEEK PROCC                                 "
say "                                                                          "
say "           -- PROCA runs but doesn't update the control file.             "
say "           -- To PROCB, it appears that it is OK to run; it runs but also "
say "              doesn't update the control file.                            "
say "           -- PROCC finds the control file not yet updated, runs, and     "
say "              updates the control file.                                   "
say "           -- If this series is rerun, the control file will have been    "
say "              updated and it will not run again.                          "
say "                                                                          "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                  Displays most paragraph names upon entry.               "
say "                                                                          "
say "        NOUPDT:   by-pass all update logic.                               "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the execution   "
say "                  in REXX TRACE Mode.                                     "
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
/*
.  ----------------------------------------------------------------- */
BRANCH: Procedure expose,              /*@                           */
        sigl exec_name
   rc = trace("O")                     /* we do not want to see this */
   arg brparm .
 
   $a#y = sigl                         /* where was I called from ?  */
   do $b#x = $a#y to 1 by -1           /* inch backward to label     */
      if Right(Word(Sourceline($b#x),1),1) = ":" then do
         parse value sourceline($b#x) with $l#n ":" . /* Paragraph   */
         leave ; end                   /*                name        */
   end                                 /* $b#x                       */
 
   select
      when brparm = "NAME" then return($l#n) /* Return full name     */
      when brparm = "ID"      then do  /*        Return prefix       */
         parse var $l#n $l#n "_" .     /* get the prefix             */
         return($l#n)
         end                           /* brparm = "ID"              */
      otherwise
         say left(sigl,6) left($l#n,40) exec_name "Time:" time("L")
   end                                 /* select                     */
 
return                                 /*@ BRANCH                    */
/*
.  ----------------------------------------------------------------- */
DUMP_QUEUE:                            /*@ Take whatever is in stack */
   rc = trace("O")                     /*  and write to the screen   */
   address TSO
 
   "QSTACK"                            /* how many stacks?           */
   stk2dump    = rc - tk_init_stacks   /* remaining stacks           */
   if stk2dump = 0 & queued() = 0 then return
   say "Total Stacks" rc ,             /* rc = #of stacks            */
       "Begin Stacks" tk_init_stacks , /* Stacks present at start    */
       "Stacks to DUMP" stk2dump
 
   do dd = rc to tk_init_stacks by -1  /* empty each one.            */
      say "Processing Stack #" dd "Total Lines:" queued()
      do queued();pull line;say line;end /* pump to the screen       */
      "DELSTACK"                       /* remove stack               */
   end                                 /* dd = 1 to rc               */
 
return                                 /*@ DUMP_QUEUE                */
/*
.  ----------------------------------------------------------------- */
KEYWD: Procedure expose info           /*@ hide all vars, except info*/
   arg kw
   kw_pos = wordpos(kw,info)           /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   kw_val = word(info,kw_pos+1)        /* get the next word          */
   info   = Delword(info,kw_pos,2)     /* remove both                */
return kw_val                          /*@ KEYWD                     */
/*
.  ----------------------------------------------------------------- */
KEYPHRS: Procedure expose,             /*@                           */
         info helpmsg exec_name        /*  except these three        */
   arg kp
   wp    = wordpos(kp,info)            /* where is it?               */
   if wp = 0 then return ""            /* not found                  */
   front = subword(info,1,wp-1)        /* everything before kp       */
   back  = subword(info,wp+1)          /* everything after kp        */
   parse var back dlm back             /* 1st token must be 2 bytes  */
   if length(dlm) <> 2 then            /* Must be two bytes          */
      helpmsg = helpmsg "Invalid length for delimiter("dlm") with KEYPHRS("kp")"
   if wordpos(dlm,back) = 0 then       /* search for ending delimiter*/
      helpmsg = helpmsg "No matching second delimiter("dlm") with KEYPHRS("kp")"
   if helpmsg <> "" then call HELP     /* Something is wrong         */
   parse var back kpval (dlm) back     /* get everything b/w delim   */
   info =  front back                  /* restore remainder          */
return Strip(kpval)                    /*@ KEYPHRS                   */
/*
.  ----------------------------------------------------------------- */
NOVALUE:                               /*@                           */
   say exec_name "raised NOVALUE at line" sigl
   say " "
   say "The referenced variable is" condition("D")
   say " "
   zsigl = sigl
   signal SHOW_SOURCE                  /*@ NOVALUE                   */
/*
.  ----------------------------------------------------------------- */
SHOW_SOURCE:                           /*@                           */
   call DUMP_QUEUE                     /* Spill contents of stacks  -*/
   if sourceline() <> "0" then         /* to screen                  */
      say sourceline(zsigl)
   rc =  trace("?R")
   nop
   exit                                /*@ SHOW_SOURCE               */
/*
.  ----------------------------------------------------------------- */
SS: Procedure                          /*@ Show Source               */
   arg  ssbeg  ssend  .
   if ssend = "" then ssend = 10
   if \datatype(ssbeg,"W") | \datatype(ssend,"W") then return
   address TSO "CLEAR"
   ssend = ssbeg + ssend
   do ssii = ssbeg to ssend ; say sourceline(ssii) ; end
   address TSO "CLEAR"
return                                 /*@ SS                        */
/*
.  ----------------------------------------------------------------- */
SWITCH: Procedure expose info          /*@                           */
   arg kw
   sw_val = Wordpos(kw,info) > 0       /* exists = 1; not found = 0  */
   if sw_val then                      /* exists                     */
      info = Delword(info,Wordpos(kw,info),1) /* remove it           */
return sw_val                          /*@ SWITCH                    */
/*
.  ----------------------------------------------------------------- */
SYNTAX:                                /*@                           */
   errormsg = exec_name "encountered REXX error" rc "in line" sigl":",
                        errortext(rc)
   say errormsg
   zsigl = sigl
   signal SHOW_SOURCE                  /*@ SYNTAX                    */
/*
.  ----------------------------------------------------------------- */
TOOLKIT_INIT:                          /*@                           */
   address TSO
   info = Strip(opts,"T",")")          /* clip trailing paren        */
 
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm  as_invokt,
                  cmd_env  addr_spc  usr_tokn
   parse value "" with  tv  helpmsg  .
   parse value 0   "ISR00000  YES"     "Error-Press PF1"    with,
               sw.  zerrhm    zerralrm  zerrsm
 
   if SWITCH("TRAPOUT") then do
      "TRAPOUT" exec_name parms "(( TRACE R" info
      exit
      end                              /* trapout                    */
 
   if Word(parms,1) = "?" then call HELP /* I won't be back          */
 
   "QSTACK" ; tk_init_stacks = rc      /* How many stacks?           */
 
   parse value SWITCH("BRANCH") SWITCH("MONITOR") SWITCH("NOUPDT") with,
               branch           monitor           noupdt    .
 
   parse value mvsvar("SYSNAME") sysvar("SYSNODE") with,
               #tk_cpu           node          .
 
   sw.nested    = sysvar("SYSNEST") = "YES"
   sw.batch     = sysvar("SYSENV")  = "BACK"
   sw.inispf    = sysvar("SYSISPF") = "ACTIVE"
 
   parse value KEYWD("TRACE")  "O"    with   tv  .
   tk_globalvars = "exec_name  tv  helpmsg  sw.  zerrhm ",
                   "zerralrm  zerrsm  zerrlm  tk_init_stacks  branch ",
                   "monitor  noupdt"
 
   call LOCAL_PREINIT                  /* for more opts             -*/
 
return                                 /*@ TOOLKIT_INIT              */
