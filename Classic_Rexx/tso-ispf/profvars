/* REXX    PROFVARS   Display all the Profile Variables for a
                      given application pool.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Chris Lewis 20021220
 
     Impact Analysis
.    SYSEXEC   LA
.    SYSEXEC   MEMBERS
.    SYSEXEC   TRAPOUT
 
     Modification History
     20030206 ctl Upgrade REXXSKEL from v19971030 to 20020513; Add
                  DEIMBED.  Add ability to open an alternate profile;
     20030206 fxc use LA to acquire ISPPROF dataset name;
     20030207 fxc eliminate unnecessary VGET;
     20050116 fxc major upgrade: adds display of all available profiles
                  for selection; reorganize structuring; adds detail
                  display of individual variable data; update REXXSKEL
                  to v.20040227; update Impact Analysis;
     20100318 fxc move banner to top;
     20161013 fxc add panel PROFVARH
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20040227      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
                                    if sw.error_found then nop ; else ,
call B_TABLE_OPS                       /*                           -*/
call Z_TERMINATE                       /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@                           */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
  "CONTROL ERRORS RETURN"              /* handle our own errors      */
 
   parse value ""  with ,
               profname sel
 
   parse value KEYWD("APPL")         with ,
               appl   .
   if appl <>  ""      then,           /* specified                  */
   if Length(appl) < 5 then,           /* just the prefix            */
      profname = appl"PROF"
   else,                               /* full profile name?         */
   if Right(appl,4) = "PROF" then,
      profname = appl
 
   call AI_ISPPROF                     /* get profile names         -*/
   call AS_SETUP_ISPF                  /* DEIMBED                   -*/
 
return                                 /*@ A_INIT                    */
/*
   Determine profile-dataset-name.  Find all ..PROF members in that
   dataset.
.  ----------------------------------------------------------------- */
AI_ISPPROF:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   "%LA ISPPROF (( STACK LIST"
   parse pull . ":" profdsn .
   "DELSTACK"
 
   if profname <> "" then return       /* we don't need a member list*/
 
   "NEWSTACK"
   "%MEMBERS" "'"profdsn"'" "((STACK LINE"
   parse pull mbrlist
   "DELSTACK"
   rmbr = Reverse(mbrlist)
   mbr = ""
   do Words(mbrlist)                   /* each word                  */
      parse value rmbr mbr  with  mbr rmbr
      if Left(mbr,4) <> "FORP" then,   /* PROF reversed              */
         mbr = ""                      /* don't keep it              */
   end                                 /* mbrlist                    */
   mbrlist = Reverse(rmbr mbr)         /* restore                    */
 
return                                 /*@ AI_ISPPROF                */
/*
.  ----------------------------------------------------------------- */
AS_SETUP_ISPF:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call DEIMBED                        /* extract ISPF assets       -*/
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ AS_SETUP_ISPF             */
/*
   Load the PROFILE member names onto the primary selector panel and
   present it for profile selection.  If a profile name already exists
   this section is redundant and we can branch directly to the inner
   logic.
.  ----------------------------------------------------------------- */
B_TABLE_OPS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if profname <> "" then do
      call BDA_DETAILS                 /*                           -*/
      return                           /* we're done...              */
      end
 
   call BA_PROLOG                      /*                           -*/
   call BB_LOAD_TABLE                  /*                           -*/
   call BD_DISPLAY_TABLE               /*                           -*/
   call BZ_EPILOG                      /*                           -*/
 
return                                 /*@ B_TABLE_OPS               */
/*
.  ----------------------------------------------------------------- */
BA_PROLOG:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   $tn$    = "AP"Right(time("S"),5,0)
   "TBCREATE" $tn$ "NOWRITE REPLACE NAMES(PROFNAME)"
 
return                                 /*@ BA_PROLOG                 */
/*
.  ----------------------------------------------------------------- */
BB_LOAD_TABLE:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   do Words(mbrlist)                   /* each profile name          */
      parse var mbrlist profname mbrlist /* isolate                  */
      "TBADD" $tn$
   end                                 /* mbrlist                    */
 
return                                 /*@ BB_LOAD_TABLE             */
/*
   Show the primary selection table and allow the user to select one
   or more profiles for display.  Pass each selected "profname" to
   BDA_DETAILS.
.  ----------------------------------------------------------------- */
BD_DISPLAY_TABLE:                      /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBTOP" $tn$
   do forever
      sel = ""
      "TBDISPL" $tn$ "PANEL(SELPROF)"
       if rc > 4 then leave
 
      do ztdsels
         "CONTROL DISPLAY SAVE"
         call BDA_DETAILS              /*                           -*/
         "CONTROL DISPLAY RESTORE"
         if ztdsels > 1 then "TBDISPL" $tn$
      end                              /* ztdsels                    */
 
   end                                 /* forever                    */
 
return                                 /*@ BD_DISPLAY_TABLE          */
/*
   Process the selection made from the primary selection table
   (profile name).  Show the details of this profile.  If the user
   specified a profile name as a parm, control will branch directly
   into this procedure.
.  ----------------------------------------------------------------- */
BDA_DETAILS: Procedure expose,         /*@ hide everything except... */
   (tk_globalvars) profname profdsn
   if branch then call BRANCH
   address ISPEXEC
 
   io      = 'OUTPUT'
   call BDAA_PROLOG                    /*                           -*/
   call BDAB_VAR_LOAD                  /*                           -*/
   call BDAD_DISPLAY                   /*                           -*/
   call BDAZ_EPILOG                    /*                           -*/
 
return                                 /*@ BDA_DETAILS               */
/*
.  ----------------------------------------------------------------- */
BDAA_PROLOG:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   $vars$  = "DD"Right(time("S"),5,0)
 
  "TBSTATS" profname "STATUS2(S2)"
 
   if s2 > 1 then return               /* table is already open      */
 
  "LIBDEF ISPTLIB DATASET ID('"profdsn"')"
  "TBOPEN" profname "NOWRITE"
   if rc <> 0 then do
      sw.error_found = 1
      zerrsm = "Table Error"
      zerrlm = "Unable to open" profname".  Is this a valid Profile?"
     "SETMSG MSG(ISRZ002)"
      end                              /* rc <> 0                    */
  "LIBDEF ISPTLIB"                     /* open table                 */
                                    if sw.error_found then return
  sw.0ClosePROF = 1                    /* we opened it               */
 
return                                 /*@ BDAA_PROLOG               */
/*
   Load the profile variables from the xxxxPROF table onto the temp
   table.
.  ----------------------------------------------------------------- */
BDAB_VAR_LOAD:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
  "TBTOP"  profname
  "TBSKIP" profname "NUMBER(1) SAVENAME(SAVES)" /* variable are stored*/
                                       /* in an extension variable   */
   parse var saves "(" saves ")" .     /* grab all variable names    */
 
   "TBCREATE" $vars$ "NOWRITE REPLACE KEYS(X4NAME) NAMES(LEN VARVAL)"
 
   do while saves <> ""
     parse var saves x4name saves
     varval = Value(x4name)
     len    = Length( Strip( varval ) )
    "TBADD" $vars$
   end                                 /* while                      */
 
return                                 /*@ BDAB_VAR_LOAD             */
/*
   Show the list of variables.  Allow the user to select one or more
   for display.
.  ----------------------------------------------------------------- */
BDAD_DISPLAY:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBSORT" $vars$ "FIELDS(X4NAME,C,A)" /* sort and set crp to top   */
 
   sel = ""
   do forever
      "TBDISPL" $vars$ "PANEL(PROFVARS)"
       if rc > 4 then leave
 
      do ztdsels
         "CONTROL DISPLAY SAVE"
         if sel = "D" then,            /* Delete                     */
            do
            /* TBDELETE the row.   Indicate 'changed'                */
            "TBDELETE" $vars$
            sw.0VarsChgd = 1
            end                        /* Delete                     */
         else,
         if sel = "E" then,            /*                            */
            do
            /* Save original text.   Allow EDIT of the contents
               If contents changed at end, indicate 'changed'        */
            origval = varval
            io      = 'INPUT'
            call BDADS_SHOW_DETAIL     /*                           -*/
            io      = 'OUTPUT'
            if origval <> varval then,
               do
               sw.0VarsChgd = 1
               len          = Length( Strip( varval ) )
               "TBMOD" $vars$
               end
            end                        /*                            */
         else,
            do
            call BDADS_SHOW_DETAIL     /*                           -*/
            end                        /*                            */
 
         "CONTROL DISPLAY RESTORE"
         if ztdsels > 1 then "TBDISPL" $vars$
 
      end                              /* ztdsels                    */
 
      sel = ""
   end                                 /* forever                    */
 
return                                 /*@ BDAD_DISPLAY              */
/*
   A "varval" may have been truncated because of the screen width.
   Show it here full-size.
.  ----------------------------------------------------------------- */
BDADS_SHOW_DETAIL: Procedure expose,   /*@                           */
   (tk_globalvars) varval x4name io
   if branch then call BRANCH
   address ISPEXEC
 
   "DISPLAY PANEL(PROFDETL)"
 
return                                 /*@ BDADS_SHOW_DETAIL         */
/*
.  ----------------------------------------------------------------- */
BDAZ_EPILOG:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if sw.0VarsChgd then,
      do                               /*                            */
      saves = ""                       /* re-init                    */
      "TBTOP" $vars$
      do forever
         "TBSKIP" $vars$
         if rc > 0 then leave
         saves = saves x4name
         $rc = Value( x4name,varval )  /* load varval to x4name      */
      end                              /* forever                    */
      end                              /*                            */
   "TBEND"  $vars$
 
   if sw.0ClosePROF then,              /* we need to close it        */
      "TBEND" profname
  sw.0ClosePROF = 0                    /* reset                      */
 
return                                 /*@ BDAZ_EPILOG               */
/*
.  ----------------------------------------------------------------- */
BZ_EPILOG:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBEND" $tn$
 
return                                 /*@ BZ_EPILOG                 */
/*
   Tear down the LIBDEFs done for DEIMBEDded material.
.  ----------------------------------------------------------------- */
Z_TERMINATE:                           /*@                           */
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
 
return                                 /*@ Z_TERMINATE               */
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
   currln   = lastln
   if Left(sourceline(currln),2) <> "*/" then return
 
   currln = currln - 1                 /* previous line              */
   "NEWSTACK"
   address ISPEXEC
   do while sourceline(currln) <> "/*"
      text = sourceline(currln)        /* save with a short name     */
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
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
say ""
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      Display all the Profile Variables for a given application "
say "                pool.                                                     "
say "                                                                          "
say "  Syntax:   "ex_nam"  APPL <applid>                                       "
say "                                                                          "
say "            applid    specifies a particular application prefix to be     "
say "                      displayed.  It may be fully-specified (ex:  ZIPPROF)"
say "                      or as a prefix-only (ZIP).  If not specified a list "
say "                      of all relevant profiles will be presented for      "
say "                      selection.                                          "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "                                                                          "
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
   arg mode .
 
   "QSTACK"                            /* how many stacks?           */
   stk2dump    = rc - tk_init_stacks   /* remaining stacks           */
   if stk2dump = 0 & queued() = 0 then return
   if mode <> "QUIET" then,
   say "Total Stacks" rc ,             /* rc = #of stacks            */
    "   Begin Stacks" tk_init_stacks , /* Stacks present at start    */
    "   Excess Stacks to dump" stk2dump
 
   do dd = rc to tk_init_stacks by -1  /* empty each one.            */
      if mode <> "QUIET" then,
      say "Processing Stack #" dd "   Total Lines:" queued()
      do queued();parse pull line;say line;end /* pump to the screen */
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
   arg kw                              /* form is 'KEY DATA'         */
   kw_pos = wordpos(kw,info)           /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   kw_val = word(info,kw_pos+Words(kw))/* get the next word          */
   info   = Delword(info,kw_pos,2)     /* remove both                */
return kw_val                          /*@ KEYWD                     */
/*
.  ----------------------------------------------------------------- */
KEYPHRS: Procedure expose,             /*@                           */
         info helpmsg exec_name        /*  except these three        */
   arg kp                              /* form is 'KEY ;: DATA ;:'   */
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
   arg  ssbeg  ssct   .                /* 'call ss 122 6' maybe      */
   if ssct  = "" then ssct  = 10
   if \datatype(ssbeg,"W") | \datatype(ssct,"W") then return
   ssend = ssbeg + ssct
   do ssii = ssbeg to ssend ; say Strip(sourceline(ssii),'T') ; end
return                                 /*@ SS                        */
/*
.  ----------------------------------------------------------------- */
SWITCH: Procedure expose info          /*@                           */
   arg kw                              /* form is 'KEY'              */
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
 
   sw.nested    = sysvar("SYSNEST") = "YES"
   sw.batch     = sysvar("SYSENV")  = "BACK"
   sw.inispf    = sysvar("SYSISPF") = "ACTIVE"
 
   if Word(parms,1) = "?" then call HELP /* I won't be back          */
 
   "QSTACK" ; tk_init_stacks = rc      /* How many stacks?           */
 
   parse value SWITCH("BRANCH") SWITCH("MONITOR") SWITCH("NOUPDT") with,
               branch           monitor           noupdt    .
 
   parse value mvsvar("SYSNAME") sysvar("SYSNODE") with,
               #tk_cpu           node          .
 
   parse value KEYWD("TRACE")  "O"    with   tv  .
   tk_globalvars = "exec_name  tv  helpmsg  sw.  zerrhm  zerralrm ",
                   "zerrsm  zerrlm  tk_init_stacks  branch  monitor ",
                   "noupdt"
 
   call LOCAL_PREINIT                  /* for more opts             -*/
 
return                                 /*@ TOOLKIT_INIT              */
/*
)))PLIB SELPROF lists profiles, allows selection
)ATTR DEFAULT(%+_)
  % TYPE(TEXT) INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT) INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON) JUST(LEFT)
  @ TYPE(OUTPUT) INTENS(LOW)  CAPS(ON) JUST(LEFT)
)BODY EXPAND(||) WIDTH(&ZSCREENW)
+|-|% Select a Profile to display +|-|
%COMMAND ===>_ZCMD
 
%V  Profile
+=  ========
)MODEL ROWS(ALL)
_Z+@PROFNAME
)INIT
    .ZVARS = '(SEL)'
)PROC
)END
)))PLIB PROFVARS lists vars in profile, allows selection
)ATTR DEFAULT(%+_)
  % TYPE(TEXT) INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT) INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON) JUST(LEFT)
  @ TYPE(OUTPUT) INTENS(LOW)  CAPS(ON) JUST(LEFT)
  ! TYPE(OUTPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT)
  } TYPE(OUTPUT) INTENS(LOW)  CAPS(ON) JUST(RIGHT)
)BODY EXPAND(||) WIDTH(&ZSCREENW)
+|-|% Variable List of!profname +|-|
%COMMAND ===>_ZCMD
                                                             %SCROLL ===>_ZAMT+
%V  Name     Length Value
++  ======== ====== ===========================================================
)MODEL ROWS(ALL)
_Z+@X4NAME  }LEN  +@VARVAL
)INIT
    .ZVARS = '(SEL)'
   .HELP = PROFVARH
)PROC
)END
))) PLIB   PROFVARH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(||) WIDTH(&ZSCREENW)
%TUTORIAL |-| %Variable List of!profname + |-| TUTORIAL
%Next Selection ===>_ZCMD
 
+
     Use any character except%D+or%E+to select a row for display.
+
     Enter%D+to delete this row and this variable.
+
     Enter%E+to display this row in editable form.
)PROC
)END
)))PLIB PROFDETL shows var detail
)ATTR DEFAULT(%+_)
  % TYPE(TEXT) INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT) INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON) JUST(LEFT)
  @ TYPE(OUTPUT) INTENS(LOW)  CAPS(ON) JUST(LEFT)
  } TYPE(&IO)    INTENS(LOW)  CAPS(ON) JUST(LEFT)
)BODY EXPAND(||) WIDTH(&ZSCREENW)
+|-|% Profile Variable Detail +|-|
%COMMAND ===>_ZCMD
 
+
%  Variable Name ===>@x4name
+
% Variable Value ===>}varval
 
 
 
 
 
 
 
 
 
 
 
 
 
 
)INIT
)PROC
)END
*/
