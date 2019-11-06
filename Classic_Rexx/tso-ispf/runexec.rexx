/* REXX    RUNEXEC    Run the current exec.  Execution of RUNEXEC is
                   dependent upon having an appropriate verb defined
                   in the user command table.  The 'action' must be:
           SELECT CMD(%RUNEXEC บ&ZDSN บ&ZMEM บ&ZMEMB บ&ZLINES บ&ZPARM)
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
                    Probably Written by Chris Lewis in the Dark Ages
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20010803 fxc REXXSKEL v.20010802; handles embedded quoted strings
                  and dumps the queue when a called routine returns
                  data;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010802      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
parse var argline  "บ"zdsn "บ"zmem "บ"zmemb  "บ"parms
if \sw.0diagnose then rc = Trace("O")
 
call A_INIT                            /*                           -*/
call B_EXECUTE                         /*                           -*/
call DUMP_QUEUE                        /*                           -*/
exit                                   /*@ RUNEXEC                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse var  zdsn  ebdsn  .           /* strip                      */
   parse value zmem zmemb  with  ebmem  .
   if ebmem <> "" then ebdsn = ebdsn"("ebmem")"
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_EXECUTE:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   "ALLOC FI($TMP$) DA('"ebdsn"') SHR REU"
   "EXECIO 1 DISKR $TMP$ (FINIS"
   "FREE  FI($TMP$)"
   pull firstline
   "DELSTACK"
   if Pos("REXX",firstline) > 0 then e_or_c = "EXEC"
                                else e_or_c = "CLIST"
 
   if Pos("'",parms) > 0 then,         /* contains quoted string     */
      call BA_DOUBLEUP                 /*                           -*/
 
   if parms <> "" then,
      "EX   '"ebdsn"' '"parms"'" e_or_c
   else,
      "EX   '"ebdsn"'          " e_or_c
 
return                                 /*@ B_EXECUTE                 */
/*
   Double the quotes for any quoted strings in <parms>
.  ----------------------------------------------------------------- */
BA_DOUBLEUP:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
   parms = "   "parms
   pt    = Lastpos("'",parms)
   do while pt <> 0
      parms = Insert("'",parms,pt)
      pt    = Lastpos("'",parms,pt-1)
   end                                 /* pt                         */
 
return                                 /*@ BA_DOUBLEUP               */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   sw.0diagnose  = SWITCH("DIAGRX")
   sw.0install   = SWITCH("INSTALL")
 
   if sw.0install then do
      call DEIMBED                     /*                           -*/
      call ZA_PROLOG                   /*                           -*/
      call ZL_LOAD_CMDTBL              /*                           -*/
      call ZZ_EPILOG                   /*                           -*/
      if sw.0load_err then nop
      else do
         zerrsm = "Shortcut created"
         zerrlm = "A command has been written to your personal command",
               "table as specified.  When activated, you may invoke",
               "this routine from any ISPF command line."
         "SETMSG  MSG(ISRZ002)"
         end
      exit                             /* no processing              */
      end                              /*                            */
 
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
   Setup the LIBDEFs
.  ----------------------------------------------------------------- */
ZA_PROLOG:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ ZA_PROLOG                 */
/*
   Install a shortcut command on the caller's command table.
.  ----------------------------------------------------------------- */
ZL_LOAD_CMDTBL:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "ADDPOP ROW(8) COLUMN(5)"
   zwinttl = "Create Shortcut"
   "DISPLAY PANEL(INSTALL)"
   disp_rc = rc
   "REMPOP ALL"
 
   if tlibds <> "" then do
      if Sysdsn(tlibds) <> "OK" then do
         zerrsm = "Library?"
         zerrlm = "The datasetname specified is not available"
         "SETMSG MSG(ISRZ002)"
         sw.0load_err = "1"
         return
         end
      if cmdtbl <> "" then do
         "LIBDEF ISPTLIB DATASET ID("tlibds") STACK"
         "TBOPEN" cmdtbl"CMDS WRITE"
         if rc = 8 then do             /* new table                  */
            "TBCREATE" cmdtbl"CMDS WRITE",
                     "NAMES(ZCTVERB ZCTTRUNC ZCTACT ZCTDESC)"
            end
         if rc > 4 then do
            zerrsm = "Oops"
            zerrlm = "TBOPEN/TBCREATE failed for "cmdtbl"CMDS"
            "SETMSG MSG(ISRZ002)"
            sw.0load_err = "1"
            return
            end
         "LIBDEF ISPTLIB"
 
         zctverb  = "RUNEXEC"
         zcttrunc = 3
         zctact   = ,
         "SELECT CMD(%RUNEXEC {&ZDSN {&ZMEM {&ZMEMB {&ZLINES {&ZPARM )"
         zctdesc  = "Run the current REXX or CLIST"
         "TBADD"  cmdtbl"CMDS"
 
         "LIBDEF ISPTABL DATASET ID("tlibds") STACK"
         "TBCLOSE" cmdtbl"CMDS"
         "LIBDEF ISPTABL"
         end
      end
   else sw.0load_err = "1"
 
return                                 /*@ ZL_LOAD_CMDTBL            */
/*
   Drop the LIBDEFs
.  ----------------------------------------------------------------- */
ZZ_EPILOG:                             /*@                           */
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
 
return                                 /*@ ZZ_EPILOG                 */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
execnm = exec_name
say "  "ex_nam"      Run the current exec.  Execution of "execnm" is dependent "
say "                upon having an appropriate verb defined in the user       "
say "                command table.  The 'action' must be:                     "
say "      SELECT CMD(%"execnm" บ&ZDSN บ&ZMEM บ&ZMEMB บ&ZLINES บ&ZPARM)        "
say "                                                                          "
say "  Syntax:   "ex_nam"  <cmd-string>                                        "
say "                   (( <DIAGRX>                                            "
say "                      <INSTALL>                                           "
say "                                                                          "
say "            <cmd-string>  is the nomal parameter string passed to the     "
say "                      routine to be proxied.                              "
say "                                                                          "
say "            <DIAGRX>      allows the diagnosis of "execnm".               "
say "                                                                          "
say "            <INSTALL>     causes an appropriate command to be inserted    "
say "                      to the user's ISPTLIB where it can be activated     "
say "                      as by ADDCMDS.                                      "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK                                      "
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the             "
say "                  execution in REXX TRACE Mode.                           "
say "                                                                          "
say "                                                                          "
say "   Debugging tools can be accessed in the following manner:               "
say "                                                                          "
say "        TSO "ex_nam"  parameters     ((  debug-options                    "
say "                                                                          "
say "   For example:                                                           "
say "                                                                          "
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                                 "
 
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
)))PLIB INSTALL
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON) JUST(LEFT) PAD('_')
  @ TYPE(OUTPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT)
  $ TYPE(INPUT)  INTENS(HIGH) CAPS(ON) JUST(LEFT)
)BODY WINDOW(68,5)
+
+ ISPTLIB DSN%==>$tlibds                                        +
+     ...CMDS%==>$z   +
+
)INIT
  .ZVARS   = '(CMDTBL)'
  .HELP    = INSTALH
  .CURSOR  = TLIBDS
)PROC
  VER (&TLIBDS,DSNAME)
  VER (&CMDTBL,NAME)
  VPUT (CMDTBL,TLIBDS) PROFILE
)END
)))PLIB INSTALH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ)
%TUTORIAL บ-บ COMPILE -- Install Shortcut บ-บ TUTORIAL %Next Selection
===>_ZCMD
 
+
     Enter a Library datasetname and membername to identify your personal
     command table.  A shortcut will be generated at that location.
 
     If you do not have a personal command table, leave this information blank
     and the installation step will be skipped.
 
     It is%HIGHLY RECOMMENDED+that you have a personal command table which can
     be activated as by (e.g.) ADDCMDS.
)PROC
)END
*/
