/* REXX    FIXSTATS   Update the ISPF statistics for a member.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
                      Proper operation of this routine is dependent on
                      the existence of the following line (or
                      equivalent) in an active command table:
           SELECT CMD(%FIXSTATS {&ZDSN {&ZMEM &ZMEMB  {&ZPARM)
 
           Written by Frank Clarke 20010803
 
     Impact Analysis
.    (alias)   SEESTATS
.    (alias)   TAGSTATS
.    SYSEXEC   FCCMDUPD
.    SYSEXEC   TRAPOUT
.    SYSEXEC   WHOIS
 
     Modification History
     20020903 fxc reorg ;
     20021210 fxc remove scroll field ;
     20031113 fxc show username ;
     20040922 fxc correct subroutine list;
     20050613 fxc enable TAGSTATS; fix INSTALL process;
     20051020 fxc comments on panel;
     20051219 fxc relocate call to WHOIS;
     20160301 fxc set display-only fields to 'output'
     20160830 fxc fix display
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.20010802      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
"CONTROL ERRORS RETURN"                /* I'll handle my own         */
 
if info = "" then call HELP            /* ...and don't come back    -*/
 
call A_INIT                            /*                           -*/
                                    if sw.0error_found then return
call L_LM_FUNCS                        /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ FIXSTATS                  */
/*
   "info" may arrive as a string of delimited tokens, the delimiter
   being the first character found in the info-string.  The tokens
   are DSNAME, MEMBER, and other parms.  The remaining parms are not
   individually delimited, and may include "?"  and "UID userid" to
   identify a userid to be 'tagged' for a "TAGSTATS" operation.  As a
   result of this calling sequence, this routine ONLY operates on the
   member currently being edited, viewed, or browsed, and is only
   callable via a command-table entry.
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value Left(info,1) '4f'x   with   dlm .
 
   parse var info (dlm) zdsn   . (dlm) zmem .  (dlm) parms
   if zdsn = "" then call HELP         /*                           -*/
 
   if Word(parms,1) = "?" then call HELP /* ...and don't come back   */
   zdsn    = "'"zdsn"'"
   parse value "" with uname .
   info    = parms
 
   parse  value  KEYWD("UID")  Userid()  with,
                 taguser  .
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
L_LM_FUNCS:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call LA_LMINIT                      /* perform the LMINIT        -*/
                                    if sw.0error_found then return
   call LD_USE_DATAID                  /*                           -*/
   call LZ_LMFREE                      /* perform the LMFREE        -*/
 
return                                 /*@ L_LM_FUNCS                */
/*
.  ----------------------------------------------------------------- */
LA_LMINIT:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LMINIT DATAID(DATAID) DATASET("zdsn") "
   if rc > 0 then do
      zerrsm = "LMINIT failed"
      zerrlm = lminit.rc
      "SETMSG MSG(ISRZ002)"
      sw.error_found = "1"
      end
 
return                                 /*@ LA_LMINIT                 */
/*
   LMOPEN - Gather stats - LMCLOSE
.  ----------------------------------------------------------------- */
LD_USE_DATAID:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call LDA_LMOPEN                     /* perform the LMOPEN        -*/
                                    if sw.0error_found then return
   call LDP_PROCESS_MBR                /*                           -*/
   call LDZ_LMCLOSE                    /* perform the LMCLOSE       -*/
 
return                                 /*@ LD_USE_DATAID             */
/*
.  ----------------------------------------------------------------- */
LDA_LMOPEN:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LMOPEN DATAID("dataid") OPTION(INPUT)"
   if rc > 0 then do
      zerrsm = "LMOPEN failed"
      zerrlm = lmopen.rc
      "SETMSG MSG(ISRZ002)"
      sw.error_found = "1"
      end
 
return                                 /*@ LDA_LMOPEN                */
/*
.  ----------------------------------------------------------------- */
LDP_PROCESS_MBR:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call LDPA_LMMFIND                   /* get original stats        -*/
                                    if sw.0error_found then return
   if sw.0TagOnly then,
      call LDPT_SETTAGS                /*                           -*/
   else,
      call LDPD_DISPLAY                /* display original stats    -*/
                                    if sw.0error_found then return
                                    if noupdt          then return
   call LDPF_LMMSTATS                  /* reload adjusted stats     -*/
 
return                                 /*@ LDP_PROCESS_MBR           */
/*
   Get original stats
.  ----------------------------------------------------------------- */
LDPA_LMMFIND:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LMMFIND DATAID("dataid") MEMBER("zmem") STATS(YES)"
   if rc > 0 then do
      zerrsm = "LMMFIND failed"
      zerrlm = lmmfind.rc
      "SETMSG MSG(ISRZ002)"
      sw.error_found = "1"
      end
   parse value zluser taguser    with  zluser  .
 
return                                 /*@ LDPA_LMMFIND              */
/*
.  ----------------------------------------------------------------- */
LDPD_DISPLAY:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call LDPDA_PROLOG                   /* set up LIBDEF             -*/
   call LDPDB_GET_USERNAME             /* convert UID to name       -*/
   if noupdt then utype = "OUTPUT"
             else utype = "INPUT"
 
   "VGET ZPFCTL"; save_zpf = zpfctl       /* save current setting    */
   zpfctl = "OFF"; "VPUT ZPFCTL"          /* PFSHOW OFF              */
 
   "ADDPOP ROW(-1) COLUMN(-2)"
   "DISPLAY PANEL(STATS)"              /* stats may be changed here  */
   if rc > 8 then say zerrsm zerrlm
   "REMPOP ALL"
 
   zpfctl = save_zpf; "VPUT ZPFCTL"       /* restore                 */
 
   call LDPDZ_EPILOG                   /* take down LIBDEF          -*/
 
return                                 /*@ LDPD_DISPLAY              */
/*
.  ----------------------------------------------------------------- */
LDPDA_PROLOG:                          /*@                           */
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
 
return                                 /*@ LDPDA_PROLOG              */
/*
   Find the name of the last-updated-user for the display
.  ----------------------------------------------------------------- */
LDPDB_GET_USERNAME:                    /*@                           */
   if branch then call BRANCH
   address TSO
 
   if zluser <> "" then do             /* get user name              */
      "NEWSTACK"
      "%WHOIS"     zluser
      do queued()                      /* spill the queue            */
         parse pull id uname
         uname = Space(uname,1)
      end                              /* queued                     */
      "DELSTACK"
      end                              /* zluser                     */
 
return                                 /*@ LDPDB_GET_USERNAME        */
/*
.  ----------------------------------------------------------------- */
LDPDZ_EPILOG:                          /*@                           */
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
 
return                                 /*@ LDPDZ_EPILOG              */
/*
   Load adjusted stats to the member.
.  ----------------------------------------------------------------- */
LDPF_LMMSTATS:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LMMSTATS DATAID("dataid")   MEMBER("zmem") VERSION("zlvers")",
            "MODLEVEL("zlmod")  CREATED("zlcdate") MODDATE("zlmdate")",
            "MODTIME("zlmtime")  CURSIZE("zlcnorc") INITSIZE("zlinorc")",
            "MODRECS("zlmnorc")   USER("zluser") CREATED4("zlc4date")",
            "MODDATE4("zlm4date") "
 
return                                 /*@ LDPF_LMMSTATS             */
/*
   Set version 99, mod 99, current time and date.
.  ----------------------------------------------------------------- */
LDPT_SETTAGS:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value,
         Date("S") Time()   99      99 ,
         with,
         dates     zlmtime  zlvers  zlmod
   zlc4date  = Translate("CcYy/Mm/Dd" , dates , "CcYyMmDd")
   zlm4date  = zlc4date
 
return                                 /*@ LDPT_SETTAGS              */
/*
.  ----------------------------------------------------------------- */
LDZ_LMCLOSE:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   'LMCLOSE  DATAID('dataid')'
   if rc > 0 then do
      zerrsm = "LMCLOSE failed"
      zerrlm = lmclose.rc
      "SETMSG MSG(ISRZ002)"
      sw.error_found = "1"
      end
 
return                                 /*@ LDZ_LMCLOSE               */
/*
.  ----------------------------------------------------------------- */
LZ_LMFREE:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LMFREE  DATAID("dataid")"
   if rc > 0 then do
      zerrsm = "LMFREE failed"
      zerrlm = lmfree.rc
      "SETMSG MSG(ISRZ002)"
      sw.error_found = "1"
      end
 
return                                 /*@ LZ_LMFREE                 */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   if SWITCH("INSTALL") then do        /* set tmpcmds                */
      queue "FIXSTATS"                 /* zctverb                    */
      queue "5"                        /* zcttrunc                   */
      queue "SELECT CMD(%FIXSTATS {&ZDSN {&ZMEM &ZMEMB  {&ZPARM) "
      queue "Adjust member statistics" /* zctdesc                    */
      "FCCMDUPD"                       /* load the table             */
      queue "SEESTATS"                 /* zctverb                    */
      queue "5"                        /* zcttrunc                   */
      queue "SELECT CMD(%SEESTATS {&ZDSN {&ZMEM &ZMEMB  {&ZPARM) "
      queue "Display member statistics" /* zctdesc                   */
      "FCCMDUPD"                       /* load the table             */
      queue "TAGSTATS"                 /* zctverb                    */
      queue "5"                        /* zcttrunc                   */
      queue "SELECT CMD(%TAGSTATS {&ZDSN {&ZMEM &ZMEMB  {&ZPARM) "
      queue "Init member statistics"   /* zctdesc                    */
      "FCCMDUPD"                       /* load the table             */
      exit
      end                              /* INSTALL                    */
 
   lminit.   = "Unknown return code"
   lminit.8 =  "Data set or file not allocated because DDname not",
               "found or Data set or file organization not supported."
   lminit.12 = "Invalid parameter value "
   lminit.16 = "Truncation or translation error in accessing dialog",
               "variables."
   lminit.20 = "Severe error "
 
   lmopen.   = "Unknown return code"
   lmopen.8  = "Open failed because Data set record format not",
               "supported by ISPF "
   lmopen.10 = "No data set associated with the dataid "
   lmopen.12 = "Invalid parameter value:  Data set is already open",
               "or Cannot open data set allocated 'SHR' for output"
   lmopen.16 = "Truncation or translation error in storing defined",
               "variables "
   lmopen.20 = "Severe error"
 
   lmmfind.   = "Unknown return code"
   lmmfind.4  = "Member not available"
   lmmfind.8  = "Member not found "
   lmmfind.10 = "No data set or file associated with the given dataid"
   lmmfind.12 = "Data set or file not open or not open for input",
                "because Data set is not an ISPF library or MVS",
                "partitioned data set or Invalid parameter value"
   lmmfind.16 = "Truncation or translation error in accessing dialog",
                "variables "
   lmmfind.20 = "Severe error "
 
   lmmstats.   = "Unknown return code"
   lmmstats.4  = "No members match pattern or No member in data set"
   lmmstats.8  = "Member not found "
   lmmstats.10 = "No data set associated with the given dataid "
   lmmstats.12 = "Invalid parameter value:  Data set is not open or is",
                 "not partitioned "
   lmmstats.20 = "Severe error "
 
   lmclose.    = "Unknown return code"
   lmclose.8   = "Data set is not open "
   lmclose.10  = "No data set associated with the given data id "
   lmclose.20  = "Severe error "
 
   lmfree.   = "Unknown return code"
   lmfree.8  = "Free data set or file failed "
   lmfree.10 = "No data set or file associated with dataid "
   lmfree.20 = "Severe error "
 
   sw.0install  = SWITCH("INSTALL")
   noupdt       = noupdt | (exec_name = "SEESTATS")
   sw.0TagOnly  = exec_name = "TAGSTATS"
 
   if exec_name = "FIXSTATS" then,
      do
        chgmsg   = "  <-- change here   (yy/mm/dd)"
        timemsg  = "                    (hh:mm:ss  seconds optional)"
      end
   else parse value "" with  chgmsg  timemsg
   chgmsg2 = chgmsg
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
   Parse out the embedded components at the back of the source code.
.  ----------------------------------------------------------------- */
DEIMBED: Procedure expose,             /*@                           */
   (tk_globalvars)  ddnlist  $ddn.  daid.
 
   address TSO
   zz = Msg('OFF')
   "ALLOC FI($TMP) NEW REU UNIT(VIO) SPACE(1) TRACKS RECFM(V B)",
     "LRECL(255) BLKSIZE(0)"
   if rc = 12 then alcunit = "SYSDA"
              else alcunit = "VIO"
   "FREE  FI($TMP)"
   zz = Msg(zz)
 
   fb80po.0  = "NEW UNIT("alcunit") SPACE(5 5) TRACKS DIR(40)",
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
 
say "  FIXSTATS      allows the caller to adjust the ISPF member statistics "
say "                for any writeable dataset.  The process is designed to "
say "                be called via the command table (only).                "
say "                                                                       "
say "                FIXSTATS has two aliases: SEESTATS and TAGSTATS.       "
say "                SEESTATS allows the statistics to be VIEWed only.      "
say "                TAGSTATS forces the statistics to ver 99, mod 99,      "
say "                with today's date and a specific userid.               "
say "                                                                       "
say "  Syntax:   "ex_nam"  <UID userid>                        TAGSTATS only"
say "                  ((  <INSTALL>                                        "
say "                                                                       "
say "            <INSTALL> requests that the commands necessary to use this "
say "                      be loaded to the user's command table.  This     "
say "                      should be the first request a user makes via     "
say "                      FIXSTATS.  When INSTALL is requested, it is the  "
say "                      only function performed.                         "
say "                                                                       "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK                                      "
say "   Debugging tools provided include:                                   "
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
say "        TSO "ex_nam"  (( INSTALL TRACE ?R                              "
 
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
 
   parse value "" with  tv  helpmsg  zerrlm  .
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
)))PLIB STATS
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW) SKIP(ON)
  } TYPE(INPUT)  INTENS(LOW) CAPS(ON)
  _ TYPE(&UTYPE) INTENS(LOW) CAPS(ON)
  @ TYPE(TEXT)   INTENS(HIGH) COLOR(YELLOW)
  { TYPE(OUTPUT) CAPS(OFF)
  º TYPE(OUTPUT) caps(off) INTENS(LOW)
)BODY EXPAND(||)
@|-|% Member Statistics @|-|
%COMMAND ===>}ZCMD
 
+
+
+ Dataset ===>_zdsn
+  Member ===>_zmem    +
+ Version ===>_z + (##)
+     Mod ===>_z + (##)
+ Created ===>_zlcdate +ºchgmsg
+ Moddate ===>_zlmdate +ºchgmsg2
+ Modtime ===>_zlmtime +                  ºtimemsg
+ Cursize ===>_zlcnorc +
+Initsize ===>_zlinorc +
+ Modrecs ===>_zlmnorc +
+    User ===>_zluser  + {uname                                      +
+Created4 ===>{zlc4date   + <-- display only
+Moddate4 ===>{zlm4date   + <-- display only
)INIT
   .zvars = '(zlvers zlmod )'
)PROC
)END
*/
