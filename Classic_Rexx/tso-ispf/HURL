/* REXX    HURL       Use NDM to ship specified datasets.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Chris Lewis 951220
 
     Impact Analysis
.    SYSPROC   TRAPOUT
.    ISPSLIB   HURLNDM      (embedded)
.    ISPSLIB   HURLNDM1     (embedded)
.    ISPSLIB   HURLNDM2     (embedded)
.    ISPLLIB   DMBATCH
 
     Modification History
     19960220 fxc Fixed problem where could not ship to TPATSTG;
     19960815 ctl Upgrade REXXSKEL from v960119 to v960725.  Fix novalue.
     19961114 ctl Say process numbers when batch
     19970313 ctl Add Site TPAM.
     19970917 ctl Upgrade REXXSKEL from ver.960725 to ver.970999.  Add
                  switch to specify disposition of NEW rather than
                  RPL (replace).
     20020213 fxc Upgrade from ver.970818 to v.20010802; RXSKLY2K;
                  DECOMM;
     20020508 fxc DEIMBED;
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.20010802      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
                                    if \sw.0error_found then,
call B_NDM                             /* Invoke NDM                -*/
call Z_ABORT                           /* Shut it down              -*/
 
if ^sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ HURL                      */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call AA_PARSE_PARMS                 /*                           -*/
   call AB_SET_VARS                    /*                           -*/
 
   "TBCREATE" ndmtbl "KEYS(SHIPDSN NODE) NAMES(TODSN HURLSKEL)",
                     "NOWRITE REPLACE"
 
   parse var info shipdsn todsn .      /* dataset to ship receive    */
 
   if left(shipdsn,1) = "'" then,
      shipdsn = Strip(shipdsn,,"'")    /* strip of quotes            */
   else,
      shipdsn = Userid()"."shipdsn     /* prefix with userid         */
 
   if todsn = "" then,
      todsn = Overlay(Userid(),shipdsn,1,7)/*Build receiving dataset */
   else,
      if left(todsn,1) = "'" then,
         todsn = Strip(todsn,,"'")     /* strip of quotes            */
      else,
         todsn = Userid()"."todsn      /* prefix with userid         */
 
   do until active_sites = ""          /* Run each site              */
      parse var active_sites site active_sites
 
      if ^ship.site then iterate       /* Site wasn't specified      */
      if  ship.site = snode then iterate/*Can't ship to site you are */
                                       /* on.                        */
      node = node.site                 /* set the node               */
     "TBADD" ndmtbl                    /* add to table               */
 
   end                                 /* ii = 1                     */
 
   "TBSTATS" ndmtbl "ROWCURR(ROWNUM)"  /* Get the # of rows in tbl   */
    if rownum = 0 then do              /* Table is empty             */
       rcx    = 12
       zerrsm = "No Datasets to SHIP"
       zerrlm = "No rows in" ndmtbl". There is nothing to ship."
       sw.error_found = 1
       return                          /*                           -*/
       end                             /* rownum = 0                 */
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_PARSE_PARMS:                        /*@                           */
   if branch then call BRANCH
   address TSO
 
   memlist  = KEYPHRS("MEMBERS")       /* member list                */
   parse value KEYWD("NOTIFY") Userid() with user .
 
   ship.     = 0
 
   if SWITCH("NEW") then               /* disposition=NEW            */
      hurlskel = "HURLNDM2"
   else
      hurlskel = "HURLNDM1"            /* disposition=RPL (replace)  */
 
return                                 /*@ AA_PARSE_PARMS            */
/*
.  ----------------------------------------------------------------- */
AB_SET_VARS:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
   node.         = "?"
   node.MOXIE    = "MOXIE"             /* Mark each site             */
   node.MVS3803  = "MOTHER"
 
   snode    = node.node                /* Sending node               */
 
   if memlist = "" then memlist = "*"  /* Default to ALL             */
   else
      memlist = translate(space(memlist),","," ")
 
   parse value "ef"X with xef messages zerrlm .
 
   active_sites = "MOTHER  MOXIE"
   ndmtbl       = "NDM"right(time("s"),5,"0") /* Unique table        */
 
return                                 /*@ AB_SET_VARS               */
/*
   Build input for NDM and invoke.  Skeleton is built from temp table
.  ----------------------------------------------------------------- */
B_NDM:                                 /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BA_PROLOG                      /* extract and LIBDEF        -*/
 
   "FTOPEN TEMP"
    if rc > 0 then do
       rcx = rc ; sw.error_found = 1 ; zerrlm = "("branch("ID")")" zerrlm
       return
       end                             /* rc > 0                     */
 
   "FTINCL HURLNDM"                    /* skeleton to build from     */
    if rc > 0 then do
       rcx = rc ; sw.error_found = 1 ; zerrlm = "("branch("ID")")" zerrlm
       return
       end                             /* rc > 0                     */
 
   "FTCLOSE"
    if rc > 0 then do
       rcx = rc ; sw.error_found = 1 ; zerrlm = "("branch("ID")")" zerrlm
       return
       end                             /* rc > 0                     */
 
   "VGET (ZTEMPF ZTEMPN)"
 
   if monitor | noupdt then do
     "LMINIT DATAID(DDNID) DDNAME("ztempn")"
     "EDIT DATAID("ddnid")"
      end                              /* monitor                    */
 
/*
   Allocate the files needed for NDM and the invoke NDM; read the
   SYSPRINT produced by NDM to get the process numbers.
*/
   if noupdt then return
 
   address TSO
 
  "ALLOC F(DMNETMAP) DA('ACN1.PR.D292.NDM.TMVS20.NETMAP') SHR REU"
  "ALLOC F(DMMSGFIL) DA('ACN1.PR.D292.NDM.TMVS20.MSG') SHR REU"
 
  "ALLOC F(DMPUBLIB) DA('ACN1.PR.D292.NDM.TMVS20.PROCESS.LIB')",
                              " SHR REU"     /* skeltons             */
  "ALLOC F(SYSIN) DA('"ztempf"') SHR REU"
 
  "ALLOC F(NDMCMDS)  DUMMY REU"
  "ALLOC F(SYSUDUMP) DUMMY REU"
  "ALLOC F(SYSPRINT) DUMMY REU"
 
  "ALLOC F(DMPRINT) NEW DELETE UNIT(SYSDA) TRACKS SPACE(5)",
        "LRECL(255) RECFM(V B) BLKSIZE(0) REU"
 
  "CALL *(DMBATCH) 'YYSLYNN'"
   rcx = rc
 
   sw.error_found = rcx > 4            /* 1 if true, 0 if false      */
 
  "EXECIO * DISKR DMPRINT (STEM NDM. FINIS"
 
  "FREE F(DMNETMAP DMPUBLIB DMMSGFIL SYSIN DMPRINT NDMCMDS SYSPRINT SYSUDUMP)"
 
   if monitor then do iii = 1 to ndm.0 ; say ndm.iii ; end
 
   if sw.error_found then,
      call BE_NDM_ERROR                /*                           -*/
   else,
      call BS_NDM_SUBMITTED            /* display & track proc #    -*/
 
   call BZ_EPILOG                      /* drop LIBDEFs              -*/
 
return                                 /*@ B_NDM                     */
/*
   Extract ISPF elements and attach via LIBDEF
.  ----------------------------------------------------------------- */
BA_PROLOG:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call DEIMBED                        /*                           -*/
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ BA_PROLOG                 */
/*
   NDM failed.  Write output to a flat file under the users id for
   later reference.
.  ----------------------------------------------------------------- */
BE_NDM_ERROR:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   errords = "NDM.ERROR.LIST"
 
   alloc.0 = "NEW CATALOG UNIT(SYSDA) TRACKS SPACE(5)",
             "RECFM(V B) LRECL(255) BLKSIZE(0) DSORG(PS)"
   alloc.1 = "SHR"
 
   stat    = sysdsn(errords) = "OK"
 
  "ALLOC F($NDM) DA("errords") REU" alloc.stat
  "EXECIO" ndm.0 "DISKW $NDM (STEM NDM. FINIS"
  "FREE F($NDM)"
 
   address ISPEXEC "EDIT DATASET("errords")"
 
   zerrsm = "NDM Error"
   zerrlm = "NDM Failed with RC="rcx
 
return                                 /*@ BE_NDM_ERROR              */
/*
   NDM has completed sucessfully.  Now scan the output a get process
   numbers.  These numbers are loaded into a variable which will
   later be returned as a setmsg or via the stack to the caller.
.  ----------------------------------------------------------------- */
BS_NDM_SUBMITTED:                      /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   search_for = "SUBMITTED PROCESS NUMBER"
   messages   = ""
 
   do idx = 1 to ndm.0
      if wordpos(search_for,ndm.idx) > 0 then do
         parse var ndm.idx (search_for) num .
         messages = messages num
         end                           /* wordpos()                  */
   end                                 /* idx                        */
 
   zerrsm = "NDM Finished"
   zerrlm = "NDM Finished with RC="rcx
 
return                                 /*@ BS_NDM_SUBMITTED          */
/*
.  ----------------------------------------------------------------- */
BZ_EPILOG:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd
      address TSO "FREE  FI("$ddn")"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ BZ_EPILOG                 */
/*
   If not a nested routine then pull line from stack and setmsg.
   Close the temp table.
.  ----------------------------------------------------------------- */
Z_ABORT:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   select
      when sw.nested then
         push rcx xef zerrsm xef zerrlm xef messages
 
      when sw.batch   then
         say  rcx xef zerrsm xef zerrlm xef messages
 
      otherwise do
         zerrlm = zerrlm messages
        "SETMSG MSG(ISRZ002)"
         end
 
   end                                 /* select                     */
 
  "TBEND" ndmtbl                       /* close table                */
 
return                                 /*@ Z_ABORT                   */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
   Parse out the embedded components at the back of the source code.
.  ----------------------------------------------------------------- */
DEIMBED: Procedure expose,             /*@                           */
   (tk_globalvars)  ddnlist  $ddn.  daid.
 
   address TSO
 
   fb80po.0  = "NEW UNIT(VIO) SPACE(5 5) TRACKS DIR(40)",
                   "RECFM(F B) LRECL(80) BLKSIZE(0)"
   parse value ""   with  ddnlist $ddn.  daid.
 
   lastln   = sourceline()
   currln   = lastln                   /*                            */
   if Left(sourceline(currln),2) <> "*/" then return
 
   currln = currln - 1                 /* previous line              */
   "NEWSTACK"
   address ISPEXEC
   do while sourceline(currln) <> "/*"
      text = sourceline(currln)        /* save with a short name !   */
      if Left(text,3) = ")))" then do  /* package the queue          */
         parse var text ")))" ddn mbr .   /* PLIB PANL001  maybe     */
         if Pos(ddn,ddnlist) = 0 then do  /* doesn't exist           */
            ddnlist = ddnlist ddn      /* keep track                 */
            $ddn = ddn || Random(999)
            $ddn.ddn = $ddn
            address TSO "ALLOC FI("$ddn")" fb80po.0
            "LMINIT DATAID(DAID) DDNAME("$ddn")"
            daid.ddn = daid
            end
         daid = daid.ddn
         "LMOPEN DATAID("daid") OPTION(OUTPUT)"
         do queued()
            parse pull line
            "LMPUT DATAID("daid") MODE(INVAR) DATALOC(LINE) DATALEN(80)"
         end
         "LMMADD DATAID("daid") MEMBER("mbr")"
         "LMCLOSE DATAID("daid")"
         end                           /* package the queue          */
      else push text                   /* onto the top of the stack  */
      currln = currln - 1              /* previous line              */
   end                                 /* while                      */
   address TSO "DELSTACK"
 
return                                 /*@ DEIMBED                   */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
             /* The following template may be used to
                customize HELP-text for this routine.
say "  "ex_nam"      ........                                               "
say "                ........                                               "
say "                                                                       "
say "  Syntax:   "ex_nam"  ..........                                       "
say "                      ..........                                       "
say "                                                                       "
say "            ....      ..........                                       "
say "                      ..........                                       "
say "                                                                       "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                   "
say "                                                                       "
say "        MONITOR:  displays key information throughout processing.      "
say "                                                                       "
say "        NOUPDT:   by-pass all update logic.                            "
say "                                                                       "
say "        BRANCH:   show all paragraph entries.                          "
say "                                                                       "
say "        TRACE tv: will use value following TRACE to place the          "
say "                  execution in REXX TRACE Mode.                        "
say "                                                                       "
say "                                                                       "
say "   Debugging tools can be accessed in the following manner:            "
say "                                                                       "
say "        TSO "ex_nam"  parameters     ((  debug-options                 "
say "                                                                       "
say "   For example:                                                        "
say "                                                                       "
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                              "
                                                                    .*/
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
/*
)))SLIB HURLNDM
   SIGNON USERID=(&USER.) -
          NODE=GTEDSINT.&SNODE  -
          ESF=YES
)DOT &NDMTBL
     SUBMIT PROC=&HURLSKEL -
            &&NODE=&NODE -
            &&SHIPDSN=&SHIPDSN -
            &&TODSN=&TODSN -
&&MEMLIST=&MEMLIST -
            &&USER=&USER -
            PRTY=15
)ENDDOT
   SIGNOFF
)))SLIB HURLNDM1
HURL         PROCESS SNODE=GTEDSINT.&NODE -
                     PNODE=GTEDSINT.TTG
SHIPIT        COPY   FROM(DSN=&SHIPDSN -
              DISP=SHR PNODE -
SELECT=(&MEMLIST)) -
              COMPRESS EXT -
              TO  (DSN=&TODSN -
              DISP=(RPL,CATLG) -
              UNIT=SYSDA SNODE)
RUNOK         IF (SHIPIT=0) THEN
NOTIFY1       RUN TASK -
(PGM=DMNOTFY2,PARM=(CL4'GOOD',&SHIPDSN,&USER)) PNODE
              ELSE
NOTIFY2       RUN TASK -
(PGM=DMNOTFY2,PARM=(CL4'FAIL',&SHIPDSN,&USER)) PNODE
              EIF
)))SLIB HURLNDM2
HURL         PROCESS SNODE=GTEDSINT.&NODE -
                     PNODE=GTEDSINT.TTG
SHIPIT        COPY   FROM(DSN=&SHIPDSN -
              DISP=SHR PNODE -
SELECT=(&MEMLIST)) -
              COMPRESS EXT -
              TO  (DSN=&TODSN -
              DISP=(NEW,CATLG) -
              UNIT=SYSDA SNODE)
RUNOK         IF (SHIPIT=0) THEN
NOTIFY1       RUN TASK -
(PGM=DMNOTFY2,PARM=(CL4'GOOD',&SHIPDSN,&USER)) PNODE
              ELSE
NOTIFY2       RUN TASK -
(PGM=DMNOTFY2,PARM=(CL4'FAIL',&SHIPDSN,&USER)) PNODE
              EIF
*/
