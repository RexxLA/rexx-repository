/* REXX    COMPDT     Reports the compile-date for LOAD modules.
 
           Written by Frank Clarke, Houston, 19980422
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20010801 fxc upgrade from v.19980225 to v.20010730; WIDEHELP;
     20030508 fxc use PDS/ATTRIB;
     20050310 fxc adjust HELP-text;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010730      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
call C_PDS_ATTRIB                      /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ COMPDT                    */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call AA_KEYWDS                      /*                           -*/
   parse value "" with ,
         program  datetime ,
         .
   parse value "0 0 0 0 0 0 0 0 0" with ,
         list. ,
         .
 
return                                 /*@ A_INIT                    */
   /* obsoleted code follows                                         */
   parse value  '8015'x  '8011'x   with,
                taglist
 
   if info = "*" then do               /* wants all members          */
      "NEWSTACK"
      "MEMBERS" dsn "((STACK LINE"
      pull info
      "DELSTACK"
      end                              /* info=*                     */
 
   if Left(dsn,1) = "'" then,          /* quoted                     */
      dsn = Strip(dsn,,"'")            /* unquoted                   */
   else,
      dsn = Userid()"."dsn             /* fully-qualified            */
 
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value  KEYWD("SYSOUT")  "X"  with,
         syscls  .                     /* no longer used             */
   dsn        = KEYWD("IN")
   if dsn = "" then do
      helpmsg = "IN is required.  Specify the LOAD library name."
      call HELP
      end
 
return                                 /*@ AA_KEYWDS                 */
/*
.  Available data:
.  ----------------------------------------------------------------- */
C_PDS_ATTRIB:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   do words(info)
      parse var info  memid info
      rc = Outtrap("pds.")
      "PDS" dsn "ATTRIB" memid
      do cx = 1 to pds.0
         line = pds.cx
         msgid = Word(line,1)
                                       /* set PROGRAM                */
         if msgid = "PDS020I" then do
            if program <> "" then do
               parse value list.0+1 program datetime errmsg   with,
                           $z$      list.$z$   1  list.0 .
               parse value "" with program datetime errmsg
               end
            program = Left(Word(line,2),8)
            iterate
            end
         else,
         if Wordpos("Attributes",line) > 0 then do
            program = Left(Word(line,1),8)
            datetime = ""
            iterate
            end
 
         if Right(msgid,1) = "E" then do
            errmsg   = msgid
            iterate
            end
                                       /* set DATETIME               */
         if msgid = "PDS064I" then do
            parse var line " on "  datetime  " by "
            end
         else,
         if Wordpos("link-edited",line) > 0 then do
            parse var line " on "  datetime  " by "
            end
 
         if program <> "" &,
            datetime <> "" then do
            parse value list.0+1 program datetime with,
                        $z$      list.$z$   1  list.0 .
            parse value "" with program datetime
            end
      end                              /* queued                     */
      rc = Outtrap("OFF")
   end                                 /* words in info              */
   "DELSTACK"
 
   if list.0 = 0 then say "No items met the search criteria"
   else do
      do zz = 1 to list.0
         queue list.zz
      end                              /* zz                         */
      end
 
return                                 /*@ C_PDS_ATTRIB              */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   sw.nested = sw.nested & \SWITCH("NONEST")
   if SWITCH("CLEAR") then "CLEAR"
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
   '8015'x usually (PL/1); sometimes '8011'x (COBOL?)
.  ----------------------------------------------------------------- */
B_READ_LOAD:                           /*@                           */
   b_tv = trace()                      /* what setting at entry ?    */
   if branch then call BRANCH
   address TSO
 
   do Words(info)                      /* each module                */
      temptags = taglist
      parse var info  mem  info        /* isolate                    */
      say "Processing" mem
 
      $z = Outtrap("INM")
      "XMIT" node"."Userid(),
             "DA('"dsn"("mem")')",
             "SYSOUT("syscls")",
             "OUTDATASET(XMOLOD.LIST)   NOL NON NOP NOE"
      $z = Outtrap("OFF")
      if rc = 12 then do               /* not found?                 */
         queue "Unable to process.  XMIT RC was 12"
         return
         end
 
      "ALLOC FI($LD) DA(XMOLOD.LIST) SHR REU"
      if rc > 4 then iterate           /* not found ?                */
 
      "EXECIO * DISKR $LD (STEM LD. FINIS"
      if monitor then queue,
         ld.0 "lines read for" mem
 
      do while (temptags <> "")        /*                            */
         parse var temptags tag temptags /* isolate                  */
                                  rc = Trace("O")
         do bx = 1 to ld.0 while(Pos(tag,ld.bx)=0); end  /* find tag */
                                  rc = trace(b_tv)
         if bx > ld.0 then iterate
         call BB_CHECK_DATE            /*                           -*/
         if sign = "F" then leave
      end                              /* temptags                   */
 
      if bx > ld.0 then do
         queue Left(mem,8) "No date found"
         return
         end                           /* No date found              */
 
      if tag = '8011'x then
         call BA_GET_TIME              /*                           -*/
      else do
         comp_time = Left(C2X(comp_tm_pk),7)
         comp_time = Translate("Hh:Mm:Ss" , comp_time , "aHhMmSs")
         tag = comp_dt_gr              /* 4 Nov 1998                 */
         end
      queue Left(mem,8) Left(compiler_id,10) comp_dt,
                         tag,
                         comp_time
 
   end                                 /* words(info)                */
   "FREE  FI($LD)"                     /* finished                   */
 
return                                 /*@ B_READ_LOAD               */
/*
.  ----------------------------------------------------------------- */
BA_GET_TIME:                           /*@                           */
   ba_tv = trace()                     /* what setting at entry ?    */
   if branch then call BRANCH
   address TSO
 
   parse var comp_dt_gr    dd  mname  yy
   yy = Right(yy,2)
   upper mname
   dd = dd + 0
   tag = dd mname yy                   /* 7 APR 99 maybe             */
 
   found = 0
   comp_time = "Unknown"
                                       rc = Trace("O")
   do bax = bx to ld.0-1
      baz = bax + 1                    /* next line                  */
      slug = ld.bax||ld.baz            /* trim                       */
      pt = Pos(tag,slug)               /* tag found ?                */
      if pt > 0 then do
         if monitor then queue,
            tag "found on line" bax
         parse var slug (tag) comp_time .
         comp_time = left(comp_time,5)
         leave
         end                           /* found the date!            */
                                       rc = Trace(ba_tv)
   end
 
return                                 /*@ BA_GET_TIME               */
/*
.  ----------------------------------------------------------------- */
BB_CHECK_DATE:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   startpt = bx
   pt = Pos(tag,ld.bx)
 
   if monitor then queue,
      "'"X2D(tag)"'x found on line" bx "at position" pt
 
   slug = Substr(ld.bx,pt)
   if length(slug) < 19 then do
      bx = bx + 1
      slug = slug || ld.bx
      end
 
   parse var slug      4 compiler_id 13 +3 comp_dt_pk +3 comp_tm_pk +4
   comp_dt = C2X(comp_dt_pk)           /* unpack                     */
   parse var comp_dt comp_dt 6 sign
   if sign <> "F" then return
   comp_dt = Left(comp_dt,5)           /* lop sign                   */
   comp_dt_gr = Date("N",comp_dt,"J")
 
return                                 /*@ BB_CHECK_DATE             */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR" ; say ""
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"      Reports the compile-date for LOAD modules.                "
say "                                                                          "
say "  Syntax:   "ex_nam"  <member-list>                     (Required)        "
say "                      <IN dsname>                       (Required)        "
say "                  ((  <NONEST>                                            "
say "                      <CLEAR>                                             "
say "                                                                          "
say "            <member-list>   names the members to be examined.  The        "
say "                            member-list may be specified as '*', that is: "
say "                            all members, or it may be specified in any    "
say "                            manner consistent with PDS/ATTRIB syntax,     "
say "                            e.g.: TA4D* or TA4DZ2:TA4DZ3.                 "
say "                                                                          "
say "            <dsname>        names the LOAD library in which the modules   "
say "                            will be found (quoted if fully-qualified).    "
say "                                                                          "
say "            <NONEST>        (switch in OPTS) specifies that the queue     "
say "                            (containing the response) is to be dumped to  "
say "                            the screen at end.  "exec_name" normally      "
say "                            returns its answer via the queue if the       "
say "                            routine is invoked 'nested'.                  "
say "                                                                          "
say "            <CLEAR>         (switch in OPTS) clears the screen.           "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place                 "
say "                  the execution in REXX TRACE Mode.                       "
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
 
   origin = sigl                       /* where was I called from ?  */
   do currln = origin to 1 by -1       /* inch backward to label     */
      if Right(Word(Sourceline(currln),1),1) = ":" then do
         parse value sourceline(currln) with pgfname ":" .  /* Label */
         leave ; end                   /*                name        */
   end                                 /* currln                     */
 
   select
      when brparm = "NAME" then return(pgfname) /* Return full name  */
      when brparm = "ID"      then do           /* wants the prefix  */
         parse var pgfname pgfpref "_" .        /* get the prefix    */
         return(pgfpref)
         end                           /* brparm = "ID"              */
      otherwise
         say left(sigl,6) left(pgfname,40) exec_name "Time:" time("L")
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
    "   Begin Stacks" tk_init_stacks , /* Stacks present at start    */
    "   Stacks to DUMP" stk2dump
 
   do dd = rc to tk_init_stacks by -1  /* empty each one.            */
      say "Processing Stack #" dd "    Total Lines:" queued()
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
   ssend = ssbeg + ssend
   do ssii = ssbeg to ssend ; say Strip(sourceline(ssii),'T') ; end
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
   Can call TRAPOUT.
.  ----------------------------------------------------------------- */
TOOLKIT_INIT:                          /*@                           */
   address TSO
   info = Strip(opts,"T",")")          /* clip trailing paren        */
 
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm,
                     as_invokt  cmd_env  addr_spc  usr_tokn
 
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
   tk_globalvars = "exec_name  tv  helpmsg  sw.  zerrhm  zerralrm ",
                   "zerrsm  zerrlm  tk_init_stacks  branch  monitor ",
                   "noupdt"
 
   call LOCAL_PREINIT                  /* for more opts             -*/
 
return                                 /*@ TOOLKIT_INIT              */
