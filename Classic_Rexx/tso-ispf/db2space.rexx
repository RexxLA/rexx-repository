/* REXX    DB2SPACE   Calculate the amount of space needed by a DB2
                      database and index.
 
           Written by Frank Clarke, Houston, 19981019
 
     Impact Analysis
.    SYSEXEC   TRAPOUT
 
     Modification History
     20021010 fxc upgrade from v.19980225 to v.20020513;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20020513      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
call B_CALC                            /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ DB2SPACE                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call AA_KEYWDS                      /*                           -*/
   parse value "0 0 0 0 0 0 0 0 0 0" with,
           entpleaf  leafpgs  indexpgs  workpgs  intpages  indexk .
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   rows        = KEYWD("ROWS")
   lrecl       = KEYWD("LRECL")
   keysize     = KEYWD("KEYSIZE")
 
   if Words(rows lrecl keysize) <> 3 then do
      helpmsg = "Missing required parameters. "
      call HELP                        /*                           -*/
      end
 
return                                 /*@ AA_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
B_CALC:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   tblsize      = rows * lrecl
   rowsppg      = 4074 % (lrecl+8)     /* rows per page              */
   if rowsppg > 127 then rowsppg = 127 /* 127 max                    */
 
   tblpages     = rows % rowsppg  + 1  /*                            */
   tablek       = (tblpages + 2) * 4   /* base table size            */
 
   if keysize > 0 then call BX_CALC_INDEX     /*                    -*/
 
   "CLEAR"
   say "Table calculation"
   say
   say "LRECL (bytes/row)        :"Right(lrecl     ,6)
   say "# of rows                :"Right(rows      ,6)
   say "Rows per 4K Page         :"Right(rowsppg   ,6)
   say "Pages                    :"Right(tblpages  ,6)
   say "Total size (Kbytes)      :"Right(tablek    ,6)
   say
   say
   say "Index calculation"
   say
   say "Key length               :"Right(keysize   ,6)
   say "Entries per 4K Leaf page :"Right(entpleaf  ,6)
   say "Leaf pages needed        :"Right(leafpgs   ,6)
   say "Intermediate pages needed:"Right(intpages  ,6)
   say "Total index pages        :"Right(indexpgs  ,6)
   say "Index size (Kbytes)      :"Right(indexk    ,6)
 
return                                 /*@ B_CALC                    */
/*
.  ----------------------------------------------------------------- */
BX_CALC_INDEX:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   entpleaf     = 4050 % (keysize + 4) /* entries per leaf           */
   leafpgs      = rows % entpleaf + 1  /* base index pages           */
 
   indexpgs     = 1 + leafpgs          /* add the top page           */
   workpgs      = leafpgs              /* preserve leafpgs           */
   do while workpgs > entpleaf         /* calc intermediate pages    */
      intpages  = workpgs % entpleaf
      if intpages < (workpgs / entpleaf) then,  /* truncation        */
         intpages = intpages + 1       /* round up                   */
      indexpgs  = indexpgs + intpages
      workpgs   = intpages
   end
   indexk       = (indexpgs + 2) * 4
 
return                                 /*@ BX_CALC_INDEX             */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "                                                                          "
say "  "ex_nam"      Calculates space requirements for DB2 tables and indexes. "
say "                                                                          "
say "  Syntax:   "ex_nam"  <LRECL   recordsize>                      (Required)"
say "                      <ROWS    tablesize>                       (Required)"
say "                      <KEYSIZE keylength>                       (Required)"
say "                                                                          "
say "            <recordsize>    the nominal length of a typical DB2 table row "
say "                      for this table.                                     "
say "                                                                          "
say "            <tablesize>     the expected number of rows to be contained in"
say "                      this table.                                         "
say "                                                                          "
say "            <keylength>     the size in bytes of the key (if any) for this"
say "                      table.  Specify '0' if the table is not keyed.      "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "                                                                          "
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
say "                                                                          "
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
    "   Excess Stacks to dump" stk2dump
 
   do dd = rc to tk_init_stacks by -1  /* empty each one.            */
      say "Processing Stack #" dd "   Total Lines:" queued()
      do queued();pull line;say line;end /* pump to the screen       */
      "DELSTACK"                       /* remove stack               */
   end                                 /* dd = 1 to rc               */
 
return                                 /*@ DUMP_QUEUE                */
/* Handle CLIST-form keywords             added 20020513
.  ----------------------------------------------------------------- */
CLKWD: Procedure expose info           /*@ hide all except info      */
   arg kw
   kw = kw"("                          /* form is 'KEY(DATA)'        */
   kw_pos = Pos(kw,info)               /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   rtpt   = Pos(") ",info" ",kw_pos)   /* locate end-paren           */
   slug   = Substr(info,kw_pos,rtpt-kw_pos+1)     /* isolate         */
   info   = Delstr(info,kw_pos,rtpt-kw_pos+1)     /* excise          */
   parse var slug (kw)     slug        /* drop kw                    */
   slug   = Reverse(Substr(Reverse(Strip(slug)),2))
return slug                            /*@CLKWD                      */
/* Handle multi-word keys 20020513
.  ----------------------------------------------------------------- */
KEYWD: Procedure expose info           /*@ hide all vars, except info*/
   arg kw
   kw_pos = wordpos(kw,info)           /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   kw_val = word(info,kw_pos+Words(kw))/* get the next word          */
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
