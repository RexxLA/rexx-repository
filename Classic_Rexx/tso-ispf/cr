/* REXX    CR         Copy REXXSKEL into a member
 
           Written by Chris Lewis 19970813
 
     Modification History
     yymmdd xxx .....
                ....
 
*/
address ISREDIT                        /* REXXSKEL ver.970609        */
"MACRO (PARMS) NOPROCESS"              /*                            */
parse upper var parms parms "((" opts  /*                            */
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
address ISPEXEC "CONTROL ERRORS RETURN"/* Handle my own errors.      */
                                       /*                            */
call A_INIT                            /*                           -*/
                                    if sw.error_found then nop ; else ,
call B_CHECK                           /*                           -*/
                                    if sw.error_found then nop ; else ,
call C_PROCESS                         /*                           -*/
                                       /*                            */
if sw.error_found then                 /*                            */
   address ISPEXEC "SETMSG MSG(ISRZ002)"
                                       /*                            */
if ^sw.nested then call DUMP_QUEUE     /*                           -*/
exit
 
/* ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH          /*                            */
/*
*/                                     /*                            */
   address ISREDIT                     /*                            */
                                       /*                            */
  "(dsn)  = DATASET"                   /* dataset name               */
                                       /*                            */
   up_case = "CAPS ON"                 /* caps                       */
                                       /*                            */
   basedsn = "TTGTCBS.EXEC.ICEBERG.EXEC"
   basemem = "REXXSKEL"
                                       /*                            */
return                                 /*@ A_INIT                    */
                                       /*                            */
/* ----------------------------------------------------------------- */
B_CHECK:                               /*@                           */
   if branch then call BRANCH          /*                            */
/*
   If REXXSKEL already exist in current dataset then use it, otherwise
   copy it from the base library (ICEBERG).  If it was copied from
   ICEBERG then perform a move rather than a copy (delete behind).
*/                                     /*                            */
   address ISPEXEC                     /*                            */
                                       /*                            */
   stat = sysdsn("'"dsn"(REXXSKEL)'") = "OK"
                                       /*                            */
   if stat then return                 /* already there              */
                                       /*                            */
  "LMINIT  DATAID(BASEID) DATASET('"basedsn"')"
  "LMINIT  DATAID(TESTID) DATASET('"dsn"')"
  "LMCOPY FROMID("baseid") FROMMEM("basemem")",
         "TODATAID("testid") TOMEM("basemem")"
   sw.error_found = rc >  0            /*      from default          */
                                       /*                            */
   if sw.error_found then do           /*                            */
      zerrsm = "Copy Failed" rc
      zerrlm = "From" basedsn"("basemem") TO" dsn"("basemem")"
      return                           /*                            */
      end                              /* sw.error_found             */
                                       /*                            */
return                                 /*@ B_CHECK                   */
                                       /*                            */
/* ----------------------------------------------------------------- */
C_PROCESS:                             /*@                           */
   if branch then call BRANCH          /*                            */
/*
*/                                     /*                            */
   address ISREDIT                     /*                            */
                                       /*                            */
   if stat then                        /*                            */
     "COPY AFTER  0" basemem           /* copy member here           */
   else                                /*                            */
     "MOVE AFTER  0" basemem           /* move member here           */
                                       /*                            */
   sw.error_found = rc <> 0            /*                            */
                                       /*                            */
  "CAPS OFF"                           /*                            */
                                       /*                            */
return                                 /*@ C_PROCESS                 */
 
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
   if branch then call BRANCH          /*  and write to the screen   */
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
   arg  ssbeg  ssend  .
   if ssend = "" then ssend = 10
   if ^datatype(ssbeg,"W") | ^datatype(ssend,"W") then return
   address TSO "CLEAR"
   ssend = ssbeg + ssend
   do ssii = ssbeg to ssend ; say sourceline(ssii) ; end
   address TSO "CLEAR"
return                                 /*@ SS                        */
 
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
 
   sw.          = 0
   sw.nested    = sysvar("SYSNEST") = "YES"
   sw.batch     = sysvar("SYSENV")  = "BACK"
   sw.inispf    = sysvar("SYSISPF") = "ACTIVE"
 
   parse value KEYWD("TRACE")  "O"    with   tv  .
 
   zerrhm   = "ISR00000"
   zerrsm   = "Error-Press PF1"
   zerralrm = "YES"
 
   call LOCAL_PREINIT                  /* for more opts             -*/
 
return                                 /*@ TOOLKIT_INIT              */
 
