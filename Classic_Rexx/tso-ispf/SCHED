/* REXX    SCHED      Produce a pro-forma calendar page for a specific
                      month.  Input is a date value of the form:
                      "YYYYMM" (year + month) indicating the period for
                      which the schedule is to be generated.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke, Oldsmar, FL
 
     Impact Analysis
.    ISPSLIB   SCHED        (imbedded)
.    SYSPROC   SCHINIT
.    SYSPROC   BLOX
.    SYSPROC   MTHLIM
.    SYSPROC   TRAPOUT
 
     Modification History
     19950928 fxc upgrade to REXXSKEL; uses 'push/pull' for
                  initialization; uses 'Value' for iterative
                  assignments;
     19971017 fxc upgrade REXXSKEL from v.950824 to v.970818;
     19980428 fxc reorg; restructure; comments;
     19981221 fxc upgrade from v.970818 to v.19980225
     19991129 fxc upgrade from v.19980225 to v.19991109; new DEIMBED;
                  RXSKLY2K;
     20010501 fxc better comments
     20010723 fxc FREE embedded files rather than DELETE; WIDEHELP;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
                                   if \sw.0error_found then,
call B_SETUP_CAL                       /* arrange day-names         -*/
                                   if \sw.0error_found then,
call C_BUILD_CAL                       /* load dialog variables     -*/
                                   if \sw.0error_found then,
call D_WRITE_CAL                       /* generate via FT services  -*/
 
exit                                   /*@ SCHED                     */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call AA_KEYWDS                      /* parse parms               -*/
   call AB_SUBROUTS                    /* initialization            -*/
 
   push "sunday monday tuesday wednesday thursday friday saturday"
   pull  sun    mon    tue     wed       thu      fri    sat .
   parse var yyyymm 1 cc 3 yy 5 mm,    /* 2-digit year and month     */
                         3 yymm 7
   mth_nm = Word("JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC",mm)
   parse value  "0     .    ."   with,
                 dtx   dt.  jd.   .
 
   mbr_pref.    = "Z"
   mbr_pref.19  = "A"
   mbr_pref.20  = "B"
   mpref        = mbr_pref.cc
   outmem       = mpref||yymm          /* B0102 = Feb 2001           */
                                       /*       = 20(B) || 0102      */
   call AC_ALLOC_DS                    /*                           -*/
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.0replace   = SWITCH("REPLACE")
 
return                                 /*@ AA_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
AB_SUBROUTS:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"                          /* isolate SCHINIT output     */
   "SCHINIT"                           /* invoke SCHINIT            -*/
   pull textds printds .
   "DELSTACK"                          /* purge queue                */
 
   parse var info  yyyymm  .
   if yyyymm = "" then call HELP       /*                           -*/
   if yyyymm = "?" then call HELP      /*                           -*/
 
   "NEWSTACK"                          /* isolate MTHLIM output      */
   call MTHLIM yyyymm                  /* develop BOM and EOM       -*/
   pull dayindex monthend  .           /* '3 31' perhaps             */
   "DELSTACK"                          /* purge queue                */
   if dayindex = 0 &,
      monthend = 0 then exit           /* MTHLIM failed              */
 
return                                 /*@ AB_SUBROUTS               */
/*
.  ----------------------------------------------------------------- */
AC_ALLOC_DS:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
   outdsn = "'"printds"'"
   stat = Sysdsn(outdsn)
   if stat <> "OK" then do
      "ALLOC DA("outdsn") NEW CATALOG RECFM(F B) LRECL(133) BLKSIZE(0)",
             "UNIT(SYSDA) SPACE(1 1) TRACKS DIR(43)"
      "FREE  DA("outdsn")"
      end
 
   outdsn = "'"printds"("outmem")'"
   stat = Sysdsn(outdsn)
   if stat = "OK" then do
      if sw.0replace then return       /* overwrite it               */
      else do
         sw.0error_found = "1"
         zerrsm = "Output dataset exists."
         zerrlm = "The output dataset,",
                outdsn", already exists but REPLACE was not specified."
         address ISPEXEC "SETMSG MSG(ISRZ002)"
         end
      end                              /* output already exists      */
 
return                                 /*@ AC_ALLOC_DS               */
/*
.  ----------------------------------------------------------------- */
B_SETUP_CAL:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
/*
      The following code deserves extra explanation because it is so
      unusual.     MTHLIM returns a pair of numbers which are the
      day-number of the starting day of the month, and the number of
      days in the month (e.g.: 3 31).  The day-number is in the range
      0 to 6, where 0 is Monday and 6 is Sunday.  Unfortunately, our
      calendars are usually set up to start on Sunday, so we have the
      following situation:
           Su  M   T   W   Th  F   Sa
           6   0   1   2   3   4   5     and what we really want is:
           1   2   3   4   5   6   7
      We seem to be off by 2 almost everywhere except Sunday; if
      Sunday were only 8...    Well, it is, in a modulo7 system;
      it's (7+1).   So, if we take the MTHLIM return value, add 2,
      modulo7, that's it... almost.  Then we get:
           1   2   3   4   5   6   0
      Fine tuning, if we add 1, modulo7, then add another, we get:
           6   0   1   2   3   4   5     starting position
           7   1   2   3   4   5   6     add 1
           0   1   2   3   4   5   6     modulo 7
           1   2   3   4   5   6   7     add another 1
      That's what the following line does.
*/
   idx = ((dayindex+1) //7) +1
 
/* Now, IDX points at the 'proper' day-of-the-week                   */
 
   /* If MTHLIM returned "3 29", this loop will spin from 3 to 31.
      If MTHLIM returned "6 31" (starts on Friday for 31 days), the
         loop will spin from 6 to 36, spilling into week-6.          */
   dtx = idx                           /* array index                */
   dn = 0                              /* zero day-number            */
   jd = Date("D",yyyymm||"01","S")
   do i = idx until(dn = monthend)     /* once for each day          */
      dn = dn + 1                      /* bump daynumber             */
      daynum = Right(dn,2,0)           /* leading zero, maybe        */
      dt.dtx = Left(mth_nm daynum,15)  /* plus month-name            */
      jd.dtx = jd
      dtx = dtx + 1                    /* ready for tomorrow         */
      jd  = jd  + 1
   end
 
return                                 /*@ B_SETUP_CAL               */
/*
   A normal calendar shows 5 weeks per month.  Any month with more
   than 28 days will need that fifth line.  There is occasionally a
   need for a sixth week when a long month starts late in the week
   (Friday or Saturday) and the fifth week gets full to overflowing
   with day31 (and sometimes day30).  Most calendar makers avoid
   putting in a sixth week-line by doubling up on the last
   Sunday-Monday.  My solution is a little different: I'm going to put
   the (at most) two extra days into the empty spots in week-1.
.  ----------------------------------------------------------------- */
C_BUILD_CAL:                           /*@                           */
   if branch then call BRANCH
   address TSO
   call CD_DT                          /*                           -*/
   call CJ_JD                          /*                           -*/
 
return                                 /*@ C_BUILD_CAL               */
/*
.  ----------------------------------------------------------------- */
CD_DT:                                 /*@                           */
   if branch then call BRANCH
   address TSO
 
                                       /* five weeks of seven days   */
   targetvars = "dt1a dt1b dt1c dt1d dt1e dt1f dt1g",
                "dt2a dt2b dt2c dt2d dt2e dt2f dt2g",
                "dt3a dt3b dt3c dt3d dt3e dt3f dt3g",
                "dt4a dt4b dt4c dt4d dt4e dt4f dt4g",
                "dt5a dt5b dt5c dt5d dt5e dt5f dt5g"
 
   do ii = 1 to Words(targetvars)      /* for each var               */
      if dt.ii = "." then dt.ii = ""
      $fv$ = Value( Word(targetvars,ii) , dt.ii )
   end                                 /* ii                         */
 
   if dt.36 <> '.' then,               /* 6th-week overflow          */
      dt1a = dt.36                     /* load into 1st week         */
   if dt.37 <> '.' then,               /* 6th-week overflow          */
      dt1b = dt.37                     /* load into 1st week         */
 
return                                 /*@ CD_DT                     */
/*
.  ----------------------------------------------------------------- */
CJ_JD:                                 /*@                           */
   if branch then call BRANCH
   address TSO
 
                                       /* five weeks of seven days   */
   targetvars = "jd1a jd1b jd1c jd1d jd1e jd1f jd1g",
                "jd2a jd2b jd2c jd2d jd2e jd2f jd2g",
                "jd3a jd3b jd3c jd3d jd3e jd3f jd3g",
                "jd4a jd4b jd4c jd4d jd4e jd4f jd4g",
                "jd5a jd5b jd5c jd5d jd5e jd5f jd5g"
 
   do ii = 1 to Words(targetvars)      /* for each var               */
      if jd.ii = "." then jd.ii = ""
                     else jd.ii = " ("Right(jd.ii,3,0)")"
      $fv$ = Value( Word(targetvars,ii) , jd.ii )
   end                                 /* ii                         */
 
   if jd.36 <> '.' then,               /* 6th-week overflow          */
      jd1a = jd.36                     /* load into 1st week         */
   if jd.37 <> '.' then,               /* 6th-week overflow          */
      jd1b = jd.37                     /* load into 1st week         */
 
return                                 /*@ CJ_JD                     */
/*
.  ----------------------------------------------------------------- */
D_WRITE_CAL:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
   call DA_BLR_PLATE                   /* set up default boilerplate-*/
 
   call DB_EYEBALL                     /* build month-year eyeballs -*/
 
   /* ISPFILE must be F (not V) LRECL=133 and Partitioned  */
   "ALLOC FI(ISPFILE) DA('"printds"') SHR REU"
 
   call DC_FILETAILOR                  /*                           -*/
 
   "FREE FI(ISPFILE)"
 
return                                 /*@ D_WRITE_CAL               */
/*
   <textds> contains 2 members, BPLATE (9 lines) and BPLATE2
   (3 lines), which contain the text which is to be placed in
   the calendar headline.
.  ----------------------------------------------------------------- */
DA_BLR_PLATE:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   eql = copies('=',120)               /* line of equal-signs        */
   dsh = copies('-',120)               /* line of dashes             */
 
   revdt = "REVISED" Date("U")         /* revision date              */
 
   "ALLOC FI(TMP) DA('"textds"(BPLATE)') SHR REU"
   "EXECIO 9 DISKR TMP (STEM BP FINIS" /* get left-side boiler plate */
   bp1  = Overlay("("yyyymm")",bp1,40,8)
 
   "ALLOC FI(TMP) DA('"textds"(BPLATE2)') SHR REU"
   "EXECIO 3 DISKR TMP (STEM BPA FINIS" /* get right-side boilerplate */
   "FREE FI(TMP)"                      /* finished with text         */
 
return                                 /*@ DA_BLR_PLATE              */
/*
   <textds> contains 12 members named for the months, each of which
   contains an 8-line eyeball representation of the month-name.  It
   also has members containing the eyeball-representation of the
   year for those years which have been requested.  When a year is
   needed and doesn't exist, BLOX is called to build the new member.
.  ----------------------------------------------------------------- */
DB_EYEBALL:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   "ALLOC FI(TMP) DA('"textds"("mth_nm")') SHR REU"
   "EXECIO 8 DISKR TMP (STEM MM FINIS" /* get eyeball month-name     */
 
   target = "'"textds"(Y"yy")'"        /* compose name for Sysdsn    */
   if Sysdsn(target) <> "OK" then do   /* member not found ?         */
      "BLOX" yy "((NOPROMPT OUTPUT" target/* build eyeball for year  */
      end
   "ALLOC FI(TMP) DA("target") SHR REU"
   "EXECIO 8 DISKR TMP (STEM YY FINIS" /* get eyeball year-number    */
 
   mm1 = Overlay(yy1,mm1,28,18)        /* overlay year-number onto   */
   mm2 = Overlay(yy2,mm2,28,18)        /*   month-name, line-by-line */
   mm3 = Overlay(yy3,mm3,28,18)
   mm4 = Overlay(yy4,mm4,28,18)
   mm5 = Overlay(yy5,mm5,28,18)
   mm6 = Overlay(yy6,mm6,28,18)
   mm7 = Overlay(yy7,mm7,28,18)
   mm8 = Overlay(yy8,mm8,28,18)
 
return                                 /*@ DB_EYEBALL                */
/*
   Put all the pieces together.
.  ----------------------------------------------------------------- */
DC_FILETAILOR:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
   "CONTROL ERRORS RETURN"
 
   call DEIMBED                        /*                           -*/
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
   "FTOPEN"
   "FTINCL SCHED"                      /* do file tailoring          */
   "FTCLOSE NAME("outmem")"            /* save to member=MMMYY       */
   if rc > 0 then do
      say zerrsm ; say zerrlm
      end
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd
      address TSO "FREE  FI("$ddn")"
   end
 
   "BROWSE DATASET("outdsn")"          /* printds+member             */
 
return                                 /*@ DC_FILETAILOR             */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*    Routines below LOCAL_PREINIT are invisible to SHOWFLOW         */
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
address TSO;"CLEAR" ; say
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"      Produce a calendar page for one month.                    "
say "                                                                          "
say "  Syntax:   "ex_nam"  <date>                                              "
say "                      <REPLACE>                                           "
say "                                                                          "
say "            <date>    is in the form 'YYYYMM', for instance:  199312      "
say "                      (December, 1993)                                    "
say "                                                                          "
say "            <REPLACE> allows an existing calendar to be over-written.     "
say "                                                                          "
say "                                                                          "
say "            Note: EXEC 'SCHINIT' provides the names of the datasets from  "
say "                  which SCHED will a) obtain the pre-built text and       "
say "                  eyeball characters, and b) write the resultant calendar."
say "                                                                          "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "                                                                          "
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the execution in"
say "                  REXX TRACE Mode.                                        "
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
   ssend = ssbeg + ssend
   do ssii = ssbeg to ssend ; say sourceline(ssii) ; end
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
   tk_globalvars = "tk_globalvars exec_name tv helpmsg sw. zerrhm",
                   "zerralrm zerrsm zerrlm tk_init_stacks branch",
                   "monitor noupdt"
 
   call LOCAL_PREINIT                  /* for more opts             -*/
 
return                                 /*@ TOOLKIT_INIT              */
/*
)))SLIB SCHED
)TB 12 65 115
1!&EQL
!&DSH
!&BP1!    !&REVDT
!&BP2!&MM1!&BPA1
!&BP3!&MM2!&BPA2
!&BP4!&MM3!&BPA3
!&BP5!&MM4
!&BP6!&MM5
!&BP7!&MM6
!&BP8!&MM7
!&BP9!&MM8
)TB 12 29 46 63 80 97 114
!&EQL
!&EQL
!&SUN&JD1A!&MON&JD1B!&TUE&JD1C!&WED&JD1D!&THU&JD1E!&FRI&JD1F!&SAT&JD1G
!&DT1A!&DT1B!&DT1C!&DT1D!&DT1E!&DT1F!&DT1G
!&DSH
!.!.!.!.!.!.!.
!.!.!.!.!.!.!.
!.!.!.!.!.!.!.
!&EQL
!&EQL
!&SUN&JD2A!&MON&JD2B!&TUE&JD2C!&WED&JD2D!&THU&JD2E!&FRI&JD2F!&SAT&JD2G
!&DT2A!&DT2B!&DT2C!&DT2D!&DT2E!&DT2F!&DT2G
!&DSH
!.!.!.!.!.!.!.
!.!.!.!.!.!.!.
!.!.!.!.!.!.!.
!&EQL
!&EQL
!&SUN&JD3A!&MON&JD3B!&TUE&JD3C!&WED&JD3D!&THU&JD3E!&FRI&JD3F!&SAT&JD3G
!&DT3A!&DT3B!&DT3C!&DT3D!&DT3E!&DT3F!&DT3G
!&DSH
!.!.!.!.!.!.!.
!.!.!.!.!.!.!.
!.!.!.!.!.!.!.
!&EQL
!&EQL
!&SUN&JD4A!&MON&JD4B!&TUE&JD4C!&WED&JD4D!&THU&JD4E!&FRI&JD4F!&SAT&JD4G
!&DT4A!&DT4B!&DT4C!&DT4D!&DT4E!&DT4F!&DT4G
!&DSH
!.!.!.!.!.!.!.
!.!.!.!.!.!.!.
!.!.!.!.!.!.!.
!&EQL
!&EQL
!&SUN&JD5A!&MON&JD5B!&TUE&JD5C!&WED&JD5D!&THU&JD5E!&FRI&JD5F!&SAT&JD5G
!&DT5A!&DT5B!&DT5C!&DT5D!&DT5E!&DT5F!&DT5G
!&DSH
!.!.!.!.!.!.!.
!.!.!.!.!.!.!.
!.!.!.!.!.!.!.
!&EQL
!&EQL
*/
