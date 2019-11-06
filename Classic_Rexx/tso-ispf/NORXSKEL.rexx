/* REXX    NORXSKEL   Edit macro to exclude REXXSKEL lines.
 
           Written by G052811 Chris Lewis 19961202
 
     Modification History
     20010125 fxc upgrade for new ISPF
 
*/
address ISREDIT                        /* REXXSKEL ver.19961014      */
"macro (parms) NOPROCESS"              /* Used to turning trace on   */
parse upper var parms parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
"(lp,cp) = CURSOR"                     /* retain cursor position     */
 
call A_PROCESS
 
"CAPS OFF"
"CURSOR =" lp cp                       /* return cursor to original  */
"RESET LABEL .RA .RF"                  /* Clear only our labels      */
 
if sw.error_found then
   address ISPEXEC "setmsg msg(ISRZ002)"
 
if ^sw.nested then call DUMP_QUEUE     /*                           -*/
 
exit
 
/* ----------------------------------------------------------------- */
A_PROCESS:                             /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
  "(start)  = LINENUM" .zfirst         /* find first &               */
  "(last)   = LINENUM" .zlast          /* last rows                  */
 
  "label" start "= .RA"
  "label" last  "= .RF"
 
   call AA_SET_POINTERS                /*                           -*/
                                    if sw.error_found then return
 
  "FIND address 1 FIRST"
 
return                                 /*@ A_PROCESS                 */
 
/* ----------------------------------------------------------------- */
AA_SET_POINTERS:                       /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
  "FIND 'info' 1 FIRST"                /* end of rexxskel in mainline*/
   if rc <> 0 then do
     "FIND 'address' 1 FIRST"
      if rc <> 0 then do
         zerrsm = "REXXSKEL Problem"
         zerrlm = "Module does not contain or has old version of REXXSKEL",
                  "'info = parms' and 'address' was not found in column 1."
         sw.error_found = 1
         return
         end                           /* rc <> 0                    */
      end                              /* rc <> 0                    */
 
  "(line) = LINENUM" .zcsr
  "label" line "= .RD"
 
  "FIND '*/' 1 FIRST"
   if rc <> 0 then do
      zerrsm = "REXXSKEL Problem"
      zerrlm = "Module does not contain or has old version of REXXSKEL",
               "Closing comment marker was not found in column 1."
      sw.error_found = 1
      return
      end
 
  "(lcm)   = LINENUM" .zcsr
   lcm1    = lcm - 1
  "(data)  = LINE" lcm1
   if data = "" then
      lcm  = lcm1
 
  "label" lcm    "= .RC"
 
  "FIND P'###### @@@' 6 20 PREV"
   if rc = 0 then do
     "(scm) = LINENUM" .zcsr
      scm = scm - 1
     "label" scm "= .RB"
     "X ALL .RA .RB"                   /* Exclude labels             */
     "X ALL .RC .RD"                   /* Exclude labels             */
      end
   else
     "X ALL .RA .RD"                   /* Exclude labels             */
 
  "FIND 'LOCAL_PREINIT:' 1 FIRST"      /* Beginning of the end       */
   if rc <> 0 then
     "FIND HELP: 1 FIRST"
 
  "(hctr)   = LINENUM" .zcsr
   hctr     = hctr - 1                 /* get line before            */
  "label" hctr "= .RE"
  "X ALL .RE .RF"
 
return                                 /*@ AA_SET_POINTERS           */
 
/* ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
 
/* ----------------------------------------------------------------- */
HELP:                                  /*@ HELP                      */
   address TSO
 
   "CLEAR"
   if helpmsg ^= "" then do ; say helpmsg; say ""; end
   "HELP" exec_name "FUNCTION SYNTAX"
 
exit                                   /*@ HELP                      */
 
/* ----------------------------------------------------------------- */
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
         say left($l#n,45) exec_name "Time:" time("L")
   end                                 /* select                     */
 
return                                 /*@ BRANCH                    */
 
/* ----------------------------------------------------------------- */
DUMP_QUEUE:                            /*@ Take whatever is in stack */
                                       /*  and write to the screen   */
   if branch then call BRANCH
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
 
/* ----------------------------------------------------------------- */
KEYWD: Procedure expose info           /*@ hide all vars, except info*/
   arg kw
   kw_pos = wordpos(kw,info)           /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   kw_val = word(info,kw_pos+1)        /* get the next word          */
   info   = Delword(info,kw_pos,2)     /* remove both                */
return kw_val                          /*@ KEYWD                     */
 
/* ----------------------------------------------------------------- */
KEYPHRS: Procedure expose,             /*@                           */
         info helpmsg exec_name        /*  except these three        */
   arg kp
   wp    = wordpos(kp,info)            /* where is it?               */
   if wp = 0 then return ""            /* not found                  */
   front = subword(info,1,wp-1)        /* everything before kp       */
   back  = subword(info,wp+1)          /* everything after kp        */
   parse var back dlm back             /* 1st token must be 2 bytes  */
   if length(dlm) ^= 2 then            /* Must be two bytes          */
      helpmsg = helpmsg "Invalid length for delimiter("dlm") with KEYPHRS("kp")"
   if wordpos(dlm,back) = 0 then       /* search for ending delimiter*/
      helpmsg = helpmsg "No matching second delimiter("dlm") with KEYPHRS("kp")"
   if helpmsg ^= "" then call HELP     /* Something is wrong         */
   parse var back kpval (dlm) back     /* get everything b/w delim   */
   info =  front back                  /* restore remainder          */
return Strip(kpval)                    /*@ KEYPHRS                   */
 
/* ----------------------------------------------------------------- */
NOVALUE:                               /*@                           */
   say exec_name "raised NOVALUE at line" sigl
   say " "
   say "The referenced variable is" condition("D")
   say " "
   zsigl = sigl
   signal SHOW_SOURCE                  /*@ NOVALUE                   */
 
/* ----------------------------------------------------------------- */
SHOW_SOURCE:                           /*@                           */
   call DUMP_QUEUE                     /* Spill contents of stacks  -*/
   if sourceline() ^= "0" then         /* to screen                  */
      say sourceline(zsigl)
   rc =  trace("?R")
   nop
   exit                                /*@ SHOW_SOURCE               */
 
/* ----------------------------------------------------------------- */
SS: Procedure                          /*@ Show Source               */
   arg ssparms ; parse var ssparms ssbeg ssend .
   if ssend = "" then ssend = 10
   if ^datatype(ssbeg,"W") | ^datatype(ssend,"W") then return
   address TSO "CLEAR"
   ssend = ssbeg + ssend
   do ssii = ssbeg to ssend ; say sourceline(ssii) ; end
   address TSO "CLEAR"
return(0)                              /*@ SS                        */
 
/* ----------------------------------------------------------------- */
SWITCH: Procedure expose info          /*@                           */
   arg kw
   sw_val = Wordpos(kw,info) > 0       /* exists = 1; not found = 0  */
   if sw_val then                      /* exists                     */
      info = Delword(info,Wordpos(kw,info),1) /* remove it           */
return sw_val                          /*@ SWITCH                    */
 
/* ----------------------------------------------------------------- */
SYNTAX:                                /*@                           */
   errormsg = exec_name,
              "encountered REXX error" rc "in line" sigl":" errortext(rc)
   say errormsg
   zsigl = sigl
   signal SHOW_SOURCE                  /*@ SYNTAX                    */
 
/* ----------------------------------------------------------------- */
TOOLKIT_INIT:                          /*@                           */
   address TSO
   info = Strip(opts,"T",")")          /* clip trailing paren        */
 
   "QSTACK" ; tk_init_stacks = rc      /* How many stacks?           */
 
   parse value "" with tv helpmsg      /* initializing values to null*/
 
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm  as_invokt,
                    cmd_env  addr_spc  usr_tokn
   if Word(parms,1) = "?" then call HELP /* I won't be back          */
 
 
   parse value KEYWD("TRACE") "O"  with   tv  .
 
   if SWITCH("TRAPOUT") then do
      "TRAPOUT" exec_name parms "(( TRACE R" info
      exit
      end                              /* trapout                    */
 
   branch  = SWITCH("BRANCH")
   monitor = SWITCH("MONITOR")
   noupdt  = SWITCH("NOUPDT")
 
   rc = outtrap("CVTINFO","1")
       "CVTINFO"
   rc = outtrap("OFF")
 
   parse var cvtinfo1 "NJENODE=" node .
 
   hlq.    = "TTGTCBS"
   hlq.FTW = "TTGYCBS"
 
   tk_hlq  = KEYWD("USEHLQ")
   parse value tk_hlq hlq.node with hlq . /*default to prod          */
 
   sw.          = 0
   sw.nested    = sysvar("SYSNEST") = "YES"
   sw.batch     = sysvar("SYSENV")  = "BACK"
   sw.inispf    = sysvar("SYSISPF") = "ACTIVE"
 
   zerrhm   = "ISR00000"
   zerrsm   = "Error-Press PF1"
   zerralrm = "YES"
 
   call LOCAL_PREINIT                  /* for more opts             -*/
 
return                                 /*@ TOOLKIT_INIT              */
 
