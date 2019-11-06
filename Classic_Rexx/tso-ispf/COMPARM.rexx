/* REXX    COMPARM    Fetch or Store compiler parameters
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke 20030729
 
     Impact Analysis
.    SYSEXEC   LA
.    SYSEXEC   TBCOPY
.    SYSEXEC   TBLGEN
.    SYSEXEC   TRAPOUT
 
     Modification History
     20040327 fxc finished enabling REVIEW/EDIT;
     20040329 fxc forgot cplib...;
     20040729 fxc swappable displays (thanks, Chris);
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20021008      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                            */
call B_TABLE_OPS                       /*                            */
 
push  cp_rc  xef  cp_sm  xef  cp_lm  xef  info
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ COMPARM                   */
/*
   The 1st token must be <action>: either REVIEW, FETCH or STORE.
   The 2nd token will be <cproot>, the key of the CP table for FETCH
       or STORE.
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value 'EF'x   0     with,
               xef     cp_rc   cp_sm   cp_lm   .
   openmode.0  = "WRITE"               /* based on NOUPDT            */
   openmode.1  = "NOWRITE"
 
   parse var info   action  cproot  info
   if action = "REVIEW" then return
 
   if WordPos(action,"FETCH STORE") = 0 then do
      helpmsg = exec_name Branch("ID")": first token must be 'FETCH' ",
                "'REVIEW', or 'STORE'."
      call HELP                        /* ...and don't come back     */
      end
 
   if cproot = "" then do
      helpmsg = exec_name Branch("ID")": second token must be ",
                "the key of the CP table."
      call HELP                        /* ...and don't come back     */
      end
   cproot = Left(cproot,5)
 
return                                 /*@ A_INIT                    */
/*
   For a FETCH, open the CP table and TBGET cproot; send CPCLASS,
      CPTYPE, CPLIB, and CPLIST back in the SHARED pool.
 
   For a STORE, get CPCLASS, CPTYPE, CPLIB, and CPLIST from the
      SHARED pool, and reload them to the CP table for cproot.
.  ----------------------------------------------------------------- */
B_TABLE_OPS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BA_PROLOG                      /* locate and open table     -*/
                                    if sw.0error_found then return
   if action = "REVIEW" then,
      call BR_REVIEW                   /*                           -*/
   else,
   if action = "FETCH" then,
      call BF_FETCH                    /*                           -*/
   else,
      call BS_STORE                    /*                           -*/
 
   call BZ_EPILOG                      /* close table               -*/
 
return                                 /*@ B_TABLE_OPS               */
/*
   Look in ISPPROF for table COMPARM.
.  ----------------------------------------------------------------- */
BA_PROLOG:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   "LA    ISPPROF ((STACK LIST"        /* ddn: dsn dsn dsn           */
   pull . dsnlist
   do Words(dsnlist)
      parse var dsnlist  profdsn dsnlist
      if Pos(Userid()".",profdsn) > 0 then leave
                                      else profdsn = ""
   end
   "DELSTACK"
 
   if profdsn = "" then do             /* no profile ?               */
      zerrsm = "No profile"
      zerrlm = exec_name "was unable to locate an ISPPROF dataset ",
               "you own.  There is no place to store parameters."
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"
      return
      end
   else isptlib = "'"profdsn"'"
 
   address ISPEXEC
   "LIBDEF  ISPTLIB  DATASET  ID("isptlib")  STACK"
   "TBSTATS" $tn$ "STATUS1(s1) STATUS2(s2)"
           /* S1 is meaningful only for PERMANENT tables
              S1 = 1 = table exists
                   2 = table not in library chain
                   3 = table library not allocated
              s2 = 1 = table not open
                   2 = table open in NOWRITE
                   3 = table open in WRITE
                   4 = table open in SHARED NOWRITE    */
   if s1 > 1 then do
      call BAG_GEN_COMPARM             /*                           -*/
      zerrsm = "Table" $tn$ "built."
      zerrlm = "Table" $tn$ "was built (new) via TBLGEN."
      "SETMSG  MSG(ISRZ002)"
      end; else,
   if s2 = 1 then do                   /* table is not open          */
      "TBOPEN "   $tn$   openmode.noupdt
      end
   else "TBTOP" $tn$
   "LIBDEF  ISPTLIB"
 
   /* Check for back-level table                                     */
   "TBQUERY" $tn$ "NAMES(NAMELIST)"
   parse var namelist "(" namelist ")"
   if WordPos("CPMLIB",namelist) = 0 then do
      /* call TBCOPY to rebuild the back-level table                 */
      address TSO "TBCOPY" $tn$ "TYPE CP REPLACE FROM" isptlib
      call BA_PROLOG                   /* reopen table              -*/
      end                              /* back_level table           */
 
return                                 /*@ BA_PROLOG                 */
/*
.  ----------------------------------------------------------------- */
BAG_GEN_COMPARM:                       /*@                           */
   if branch then call BRANCH
   address TSO
 
   "TBLGEN  CP  WRITE REPLACE"
 
return                                 /*@ BAG_GEN_COMPARM           */
/*
.  ----------------------------------------------------------------- */
BF_FETCH:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   reas.   = "Other severe error"
   reas.8  = "Key not found"
   reas.12 = "Table not open"
 
   "TBGET" $tn$                        /* using cproot from arg      */
   if rc > 4 then do
      zerrsm = "TBGET failed"
      zerrlm = "TBGET for" cproot "in" $tn$ "failed rc="rc,
               "("reas.rc")"
      "SETMSG MSG(ISRZ002)"
      cp_rc = 8 ; cp_sm = zerrsm ; cp_lm = zerrlm ; info = ""
      parse value "" with cpclass cptype cplib cplist cpcics
      end
   else do                             /* rc = 0                     */
      info = ""
      cp_rc = 0
      cp_sm = "OK"
      cp_lm = "Data returned"
      if cpclass <> "" then info = info "CPCLASS" cpclass
      if cptype  <> "" then info = info "CPTYPE " cptype
      if cplib   <> "" then info = info "CPLIB  " cplib
      if cplist  <> "" then info = info "CPLIST " cplist
      if cpcics  <> "" then info = info "CPCICS " cpcics
      if cpmlib  <> "" then info = info "CPMLIB " cpmlib
      end                              /* rc = 0                     */
/* "VPUT (CPROOT CPCLASS CPTYPE CPLIB CPLIST CPCICS) SHARED"
*/
return                                 /*@ BF_FETCH                  */
/*
   Display the contents of the table for editing.
.  ----------------------------------------------------------------- */
BR_REVIEW:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BRA_PROLOG                     /*                           -*/
   call BRD_DISPLAY_LIST               /*                           -*/
   call BRZ_EPILOG                     /*                           -*/
 
return                                 /*@ BR_REVIEW                 */
/*
   Setup the environment
.  ----------------------------------------------------------------- */
BRA_PROLOG:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   disp1  =  "V MbrID  Class Type   CICS   ListDSN"
   disp2  =  "V MAPLIB                     LoadDSN"
   modl1  = "_z!z    +  !z+   !z+   !z+   !cplist"
   modl2  = "_z!cpmlib                    !cplib"
   zvar1  = "ACTSEL CPROOT CPCLASS CPTYPE CPCICS"
   zvar2  = "ACTSEL"
   styles = "list load"
   stylect = Words(styles)
   style  = 1                          /* default                    */
   stword = Word(styles,style)
 
   call DEIMBED                        /*                           -*/
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
  "VGET (ZPF10 ZPF11) PROFILE"
 
   save_f10 = zpf10
   save_f11 = zpf11
 
 
return                                 /*@ BRA_PROLOG                */
/*
   Display the table
.  ----------------------------------------------------------------- */
BRD_DISPLAY_LIST:                      /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBTOP" $tn$
   do forever
      actsel = ""
 
      modl = Value('modl'style)
      disp = Value('disp'style)
      zvar = Value('zvar'style)
      stword = Word(styles,style)
 
            parse value "END END" with zpf10 zpf11 .
            "VPUT (ZPF10 ZPF11) PROFILE"
      "TBDISPL" $tn$ "PANEL(COMPARM)"
      disp_rc = rc
            zpf10 = save_f10
            zpf11 = save_f11
            "VPUT (ZPF10 ZPF11) PROFILE"
       if pfkey = "PF03" | disp_rc > 4 then leave
 
      if WordPos(pfkey,"PF10 PF11") > 0 then do
         call BRDK_CHECK_STYLE         /*                           -*/
         iterate
         end
 
      do ztdsels
         "CONTROL DISPLAY SAVE"
 
         select
 
            when actsel = "D" then do
               "TBDELETE" $tn$
               end
 
            when actsel = "E" then do
               call BRDE_EDIT          /*                           -*/
               end
 
            otherwise nop
 
         end                           /* select                     */
 
         "CONTROL DISPLAY RESTORE"
 
         if ztdsels > 1 then "TBDISPL" $tn$
 
      end                              /* ztdsels                    */
 
      actsel = ""
 
   end                                 /* forever                    */
 
return                                 /*@ BRD_DISPLAY_LIST          */
/*
   Edit the selected entry
.  ----------------------------------------------------------------- */
BRDE_EDIT: Procedure expose,           /*@                           */
           (tk_globalvars),
           $tn$ cpcics cpclass cplib cplist cproot cptype
   if branch then call BRANCH
   address ISPEXEC
 
   parse value cproot cpclass cptype cplib cpcics cplist cpmlib with,
               zzroot zzclass zztype zzlib zzcics zzlist zzmlib .
   do forever
      "DISPLAY PANEL(PARMED)"
      if rc > 4 then leave
   end                                 /* forever                    */
 
   if rc > 8 then do
      "SETMSG MSG(ISRZ002)"
      return
      end                              /* serious error              */
 
   if Space(cproot cpclass cptype cplib cpcics cplist cpmlib,0) <> ,
      Space(zzroot zzclass zztype zzlib zzcics zzlist zzmlib,0) then do
      "TBMOD" $tn$
      sw.0tblchg = 1
      end
 
return                                 /*@ BRDE_EDIT                 */
/*
   Cycle between styles.  If there were 5 styles:
   To go to the next style:  (style//stylect) + 1:
          1   2   3   4   5
          1   2   3   4   0    (mod stylect)
          2   3   4   5   1    (add one)
   To go to the prior style:  (style+stylect-2)//stylect + 1
          1   2   3   4   5
          6   7   8   9  10    (+stylect)
          4   5   6   7   8    ( -2 )
          4   0   1   2   3    ( //stylect)
          5   1   2   3   4    ( +1 )
   This works regardless of the number of styles; it even works when
   the number of styles is 1!
.  ----------------------------------------------------------------- */
BRDK_CHECK_STYLE:                      /*@                           */
   if branch then call BRANCH
   address TSO
 
   select
 
      when pfkey = "PF11" then,
         style = style//stylect + 1    /* next style                 */
 
      when pfkey = "PF10" then,
         style = (style+stylect-2)//stylect + 1       /* prev style  */
 
      otherwise nop
   end
 
return                                 /*@ BRDK_CHECK_STYLE          */
/*
.  ----------------------------------------------------------------- */
BRZ_EPILOG:                            /*@                           */
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
 
return                                 /*@ BRZ_EPILOG                */
/*
   Data to be stored is found in 'info'.
.  ----------------------------------------------------------------- */
BS_STORE:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   reas.   = "Other severe error"
   cpclass = KEYWD("CPCLASS")
   cptype  = KEYWD("CPTYPE ")
   cplib   = KEYWD("CPLIB  ")
   cplist  = KEYWD("CPLIST ")
   cpcics  = KEYWD("CPCICS ")
   cpmlib  = KEYWD("CPMLIB ")
/* "VGET (CPROOT CPCLASS CPTYPE CPLIB CPLIST CPCICS) ASIS" */
   "TBSORT" $tn$ "FIELDS(CPROOT,C,A)"
   "TBMOD" $tn$ "ORDER"
   if rc > 8 then do
      zerrsm = "TBMOD failed"
      zerrlm = "TBMOD for" cproot "in" $tn$ "failed rc="rc,
               "("reas.rc")"
      "SETMSG MSG(ISRZ002)"
      cp_rc = 8 ; cp_sm = zerrsm ; cp_lm = zerrlm ; info = ""
      end
   else do
      cp_rc = 0
      cp_sm = "OK"
      cp_lm = "Data stored"
      info  = ""
      end
 
return                                 /*@ BS_STORE                  */
/*
.  ----------------------------------------------------------------- */
BZ_EPILOG:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LIBDEF  ISPTABL  DATASET  ID("isptlib")  STACK"
   "TBCLOSE" $tn$
   "LIBDEF  ISPTABL"
 
return                                 /*@ BZ_EPILOG                 */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   parse value KEYWD("USETBL")  "COMPARM"   with ,
               $tn$     .
 
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
address TSO;"CLEAR" ; say ""
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      Fetch or Store compiler parameters                        "
say "                                                                          "
say "  Syntax:   "ex_nam"  <FETCH | STORE | REVIEW>                  (Required)"
say "                      <member>                                            "
say "                                                                          "
say "            <member>  is the name of the source to be compiled.  Only the "
say "                      first 5 characters are significant.  This item is   "
say "                      ignored for 'REVIEW'.                               "
say "                                                                          "
say "            <FETCH>   causes the compiler values from the table to be     "
say "                      written to the SHARED pool.                         "
say "                                                                          "
say "            <STORE>   causes the compiler values in the SHARED pool to be "
say "                      written onto the table.                             "
say "                                                                          "
say "            <REVIEW>  causes the table to be displayed.                   "
say "                                                                          "
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
 
if sw.inispf then,
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
)))PLIB COMPARM
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) caps(on)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(บบ)
%บ-บ Compile Parameters +บ-บ
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
  /--%D+(delete) or%E+(edit)               %PF1+for%HELP+
 /
@disp
)MODEL
&modl
)INIT
  .ZVARS = '(&zvar)'
  .HELP = COMPARMH
)REINIT
)PROC
  IF (.PFKEY = 'PF05')
      &PFKEY = 'F5'
      .RESP = END
 
  IF (.PFKEY = 'PF10')
      .RESP  = 'ENTER'
 
  IF (.PFKEY = 'PF11')
      .RESP  = 'ENTER'
 
  &PFKEY = .PFKEY
 
)END
)))PLIB COMPARMH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ)
%TUTORIAL บ-บ Compile Parameters บ-บ TUTORIAL
%Next Selection ===>_ZCMD
 
+
    You may select%D+to%Delete+a profile, or%E+to%Edit+a profile.
 
    There are two different displays which you may toggle via%PF10+and%PF11.
+   The default display shows the%LIST+dataset; the alternate display shows
    the%LOAD+dataset.
)PROC
)END
)))PLIB PARMED
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT)  INTENS(LOW) CAPS(ON)
  @ TYPE(TEXT)   INTENS(HIGH) COLOR(YELLOW)
  ! TYPE(INPUT)  INTENS(NON)
  { TYPE(OUTPUT)
)BODY EXPAND(บบ)
@บ-บ% Edit &cproot @บ-บ
%COMMAND ===>_ZCMD
 
+
+         ROOT ===>{z    +                Modulename root
+        CLASS ===>_z+                    JOBCLASS
+         TYPE ===>_z+                    E or O
+         CICS ===>_z+                    Y or N
+     LINK dsn ===>_cplib
+     LIST dsn ===>_cplist
+       MAPLIB ===>_cpmlib
+
)INIT
  .ZVARS = '(CPROOT CPCLASS CPTYPE CPCICS)'
)PROC
)END
*/
