/* REXX    SHOWME     Show 'first found' members by DDname.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke, Richmond, 20000104
 
     Impact Analysis
.    SYSPROC   KVW
.    SYSPROC   LA
.    SYSPROC   MEMBERS
.    SYSPROC   TRAPOUT
.    ISPPLIB   SHOWMEDS  (IMBED)
.    ISPPLIB   SHOWME01  (IMBED)
.    ISPPLIB   SHOWME02  (IMBED)
.    ISPPLIB   POP45BY3  (IMBED)
 
     Modification History
     20020411 fxc upgrade from v.19991109 to v.20010802;
                  restructure; enable multiple DDnames;
     20160407 fxc enable restart; enable CMDS and ISPF DDnames
     20160426 fxc DUPS;
     20160530 fxc implem subact. = the action used to get here
     20160607 fxc discontinue use of PF05; can't imagine what I was
                  thinking, but it prevents TEXTFLOW; for members with
                  more datasets than can be displayed, place those DSNs
                  into extension variables (TNx); display the table name
                  on the screen to allow TBLOOK to find it; BEWARE:
                  sorting the table via TBLOOK leaves it sorted on
                  return;
     20160926 fxc allow "K" selection to provoke KVW
     20161018 fxc added call to FIND_ORIG
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010802      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
 
if ^sw.inispf  then do                 /* after TOOLKIT_INIT return  */
   arg line
   line = line "((  RESTARTED"         /* tell the next invocation   */
   "ISPSTART CMD("exec_name line")"    /* Invoke ISPF...             */
   exit                                /* ...then bail out           */
   end
 
info   = parms                         /* to enable parsing          */
 
call I_INIT                            /*                           -*/
                                    if sw.0Error_Found then nop ; else ,
call T_TABLE_OPS                       /*                           -*/
                                    if sw.0Error_Found | sw.0savelog then,
call ZB_SAVELOG                        /*                           -*/
 
if helpmsg <> "" then call HELP        /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
if sw.0exit_ISPF then do               /* was restarted from READY   */
   rc = OutTrap('LL.')
   exit 4
   end
 
exit                                   /*@ SHOWME                    */
/*
   Initialization
.  ----------------------------------------------------------------- */
I_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   msglim         = 124
   parse value "0 0 0 0 0 0 0 0" with,
                memct.  lastfnd  datasets  elements  .
   parse value "" with,
               mstr   xvars,
               dsname_list   allmbrs  dslist.   pfkey
 
   call IA_SETUP_LOG                   /*                           -*/
   call IK_KEYWDS                      /*                           -*/
                                    if sw.0Error_Found then return
   call IM_GET_MEMBERS                 /*                           -*/
   action.        = "VIEW"             /* default action             */
   action.E       = "EDIT"
   action.B       = "BROWSE"
 
return                                 /*@ I_INIT                    */
/*
.  ----------------------------------------------------------------- */
IA_SETUP_LOG:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value "0" with,
               log#    log.
   parse value Date("S")  Time("S")  Time("N")  with,
               yyyymmdd   sssss      hhmmss  .
   parse var yyyymmdd  4 yrdigit 5 mm 7 dd          /* 9 12 14 maybe */
   parse var hhmmss  hh ":" nn ":"                  /* 13 22   maybe */
   if Pos(yrdigit,"13579") > 0 then mm = mm + 12       /* mm=24      */
   logtag = Substr("ABCDEFGHIJKLMNOPQRSTUVWX",mm,1)    /* logtag=X   */
   subid  = logtag""dd""Right(sssss,5,0)               /* X1423722 ? */
   time4  = hh || nn
   subid  = logtag""dd""time4                          /* X141322  ? */
   vb4k.0    = "NEW CATALOG UNIT(SYSDA) SPACE(1 5) TRACKS",
               "RECFM(V B) LRECL(137) BLKSIZE(0)"
   vb4k.1    = "SHR"                   /* if it already exists...    */
   logdsn = "@@LOG."exec_name"."subid".#CILIST"
 
   call ZL_LOGMSG(exec_name "started by" Userid()  yyyymmdd  hhmmss)
   call ZL_LOGMSG("Running from" FIND_ORIGIN() )
   call ZL_LOGMSG("Arg:" argline)
 
return                                 /*@ IA_SETUP_LOG              */
/*
   Parse out KEYWDs and SWITCHes.
.  ----------------------------------------------------------------- */
IK_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   if WordPos("ISPF",info) > 0 then mstr = "ISPF"
   if WordPos("CMDS",info) > 0 then mstr = "CMDS"
   sw.0savelog  = SWITCH("SAVELOG")
   sw.0select   = SWITCH("SELECT")
   sw.0dups     = SWITCH("DUPS")
   if SWITCH("CMDS") then info = info "SYSEXEC SYSPROC"
   if SWITCH("ISPF") then info = info "ISPPLIB ISPSLIB ISPTLIB",
                             "ISPMLIB ISPPROF"
   parse var info   ddnames
   if ddnames = "" then do
      helpmsg = "DDNAME is required."
      sw.0Error_Found = "1"
      end
   if mstr = "" then mstr = Word(ddnames,1)
 
return                                 /*@ IK_KEYWDS                 */
/*
   A <ddname> was provided as input.  Use LA to get the DSNames by
   DDNname, then use MEMBERS to find members-by-dsname.
.  ----------------------------------------------------------------- */
IM_GET_MEMBERS:                        /*@                           */
   if branch then call BRANCH
   address TSO
 
   orig_ddns = ddnames
   do while ddnames <> ""              /* each ddname                */
      parse var ddnames  ddname ddnames   /* isolate                 */
      "NEWSTACK"
      "%LA" ddname "((STACK "          /*                          --*/
      pull list
      "DELSTACK"
      call ZL_LOGMSG(ddname":" list)
      if list = "(EMPTY)" then iterate
      dsname_list = dsname_list list   /* splice                     */
   end                                 /* ddnames                    */
 
   if dsname_list = "" then do
      helpmsg = helpmsg " Nothing allocated for" orig_ddns
      sw.0Error_Found = "1"; return
      end
   datasets = Words(dsname_list)
 
   w1 = ""                             /* survey DSNs to find giants */
   do Words(dsname_list)
      parse value dsname_list w1  with  w1 dsname_list
      zzx = LISTDSI("'"w1"'"  "directory")
      memct.w1 = sysmembers            /* how many members?          */
      if sysmembers > memlim then,     /* a giant                    */
      if sw.0Select = 0 then do
         sw.0Select = 1
         zerrsm = "Forced"
         zerrlm = "One or more datasets had more than" memlim,
                  "members.  You may wish to exclude some or all to",
                  "speed processing."
         address ISPEXEC "SETMSG  MSG(ISRZ002)"
         end                           /* broke memlim               */
   end                                 /* each dsname                */
   dsname_list = dsname_list w1
                                        rc = Trace("O"); rc = Trace(tv)
   if sw.0select then call IMT_TRIMLIST     /*                      -*/
                                    if sw.0Error_Found then return
   do Words(dsname_list)               /* every dsn                  */
      parse var dsname_list dsn dsname_list           /* isolate     */
      call IML_MEMBERS                 /*                           -*/
   end                                 /* dsname_list                */
   if elements = 0 then do
      helpmsg = helpmsg " No members."
      sw.0Error_Found = "1"; return
      end
 
return                                 /*@ IM_GET_MEMBERS            */
/*
   Get lists of members-by-dsname and generate dsname-by-member.
.  ----------------------------------------------------------------- */
IML_MEMBERS:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   "MEMBERS  '"dsn"'  ((STACK"         /*                          --*/
   pull mbrlist
   "DELSTACK"
 
   call ZL_LOGMSG(dsn":" Words(mbrlist) "members")
 
   if mbrlist = "(EMPTY)" then mbrlist = ""
   elements = elements + Words(mbrlist)     /* total inventory       */
 
   do Words(mbrlist)                   /* every member               */
      parse var mbrlist   mbr mbrlist  /* isolate                    */
      if dslist.mbr = "" then,         /* new one....                */
         allmbrs = allmbrs mbr         /* add to list                */
      dslist.mbr = dslist.mbr dsn      /* member -> dsn              */
   end                                 /* dsname_list                */
 
return                                 /*@ IML_MEMBERS               */
/*
   Are there any datasets in this DDN that should be ignored?
.  ----------------------------------------------------------------- */
IMT_TRIMLIST:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   $td$ = "$TD$"
   "TBCREATE" $td$ "KEYS(DSN) NAMES(MEMS) NOWRITE REPLACE"
   dsn = ""
   do Words(dsname_list)
      parse value  dsname_list  dsn   with   dsn  dsname_list
      mems = memct.dsn
      "TBADD" $td$
   end
   parse value  dsname_list  dsn   with   dsname_list
 
   /*   DEIMBED has not yet been run, so panel SHOWMEDS doesn't exist.
        (Strangely, it DOES exist if SHOWME has been run successfully
        before, but not if this is the first time.)
        Load the panels and open the panel libraries.
                                                                     */
   call TA_LOAD_PANELS                 /* DEIMBED sets ddnlist      -*/
   "TBTOP" $td$
   do forever
      "TBDISPL"  $td$  "PANEL(SHOWMEDS)"
      if rc > 4 then leave
 
      do ztdsels
         if sel = "X" then,            /* what action this row ?     */
            "TBDELETE" $td$            /* select                     */
         if ztdsels = 1 then,          /* never do the last one      */
            ztdsels = 0
         else "TBDISPL" $td$           /* next row                  #*/
      end                              /* ztdsels                    */
      call IMTC_COUNT_DSNAMES          /*                           -*/
 
   end                                 /* forever                    */
   if zcmd = "CANCEL" then sw.0Error_Found = "1"
 
return                                 /*@ IMT_TRIMLIST              */
/*
   Maintain a running count of DSNames.
.  ----------------------------------------------------------------- */
IMTC_COUNT_DSNAMES:                    /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBTOP" $td$
   dsname_list = ""
   do forever
      "TBSKIP" $td$
      if rc > 0 then leave
      dsname_list = dsname_list dsn
   end
   datasets = Words(dsname_list)
   "TBTOP" $td$
 
return                                 /*@ IMTC_COUNT_DSNAMES        */
/*
.  ----------------------------------------------------------------- */
T_TABLE_OPS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if Symbol("ddnlist") = "LIT" then,             /* not yet set     */
      call TA_LOAD_PANELS              /* DEIMBED sets ddnlist      -*/
   call TB_OPEN                        /* MBR-DSN table             -*/
                                    if sw.0Error_Found then return
   call TD_DISPLAY                     /*                           -*/
 
   call TU_CLOSE                       /*                           -*/
   call TZ_DROP_PANELS                 /*                           -*/
 
return                                 /*@ T_TABLE_OPS               */
/*
   Extract ISPF material and activate via LIBDEF
.  ----------------------------------------------------------------- */
TA_LOAD_PANELS:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "CONTROL ERRORS RETURN"
   call DEIMBED                        /* expose the panels         -*/
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
 
return                                 /*@ TA_LOAD_PANELS            */
/*
   Build and populate the primary table.
.  ----------------------------------------------------------------- */
TB_OPEN:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   $tn$ = "TMP"Random(99999)
   $td$ = Overlay("TMD",$tn$,1,3)
   "TBCREATE" $tn$ "KEYS(MBR) NAMES(DSLIST) NOWRITE REPLACE"
   if rc > 0 then do
      zerrsm = "TBCREATE failed"
      if Symbol("zerrlm") = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.0Error_Found = "1"; return
      end
 
   "VGET ZSCREENW"
   dslim = 3 + (zscreenw = 132)
   do Words(allmbrs)                   /* every known member         */
      parse var allmbrs  mbr allmbrs   /* isolate                    */
      dslist = Words(dslist.mbr)
      if sw.0dups & dslist = 1 then iterate    /* ignore it          */
      if dslist < dslim then,
         parse value Space(dslist.mbr,2)  with  dslist
                        else,
            do
            $tmp = dslist.mbr
            idx = 0
            do while $tmp <> ""
               parse value idx+1 $tmp   with  idx  w1  $tmp
               rc = Value("TN"idx,w1)
               xvars = xvars "TN"idx
            end                        /* while                      */
            end                        /* else                       */
      "TBADD" $tn$ "SAVE("xvars")"
      if rc > 0 then do
         zerrsm = "TBADD failed"
         if Symbol("zerrlm") = "LIT" then,
            zerrlm = "MBR="mbr "DSLIST="dslist
         zerrlm = exec_name "("BRANCH("ID")")",
                  zerrlm
         address ISPEXEC "SETMSG MSG(ISRZ002)"
         sw.0Error_Found = "1"; return
         end                           /* TBADD failed               */
      xvars = ""
   end                                 /* allmbrs                    */
 
   "TBSORT" $tn$ "FIELDS(MBR,C,A)"
 
return                                 /*@ TB_OPEN                   */
/*
   Show the primary table (key=member).  If a selected member exists
   in several datasets, expand the list to allow selection of the
   dataset.
.  ----------------------------------------------------------------- */
TD_DISPLAY:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   do forever
      "TBDISPL"  $tn$  "PANEL(SHOWME01)"
      disp_rc = rc
      if disp_rc > 8 then do
         zerrlm = exec_name "("BRANCH("ID")")",
                  zerrlm
         "SETMSG  MSG(ISRZ002)"
         sw.0Error_Found = "1"
         leave
         end
      if disp_rc = 8 then,
         do                            /* make sure the PF3 was valid*/
         zwinttl = "SHOWME Termination"
         popmsg1 = "END command detected"
         popmsg2 = ""
         popmsg3 = "   PF3 to confirm.   ENTER to cancel."
         "ADDPOP ROW(+3) COLUMN(+2)"
         "DISPLAY PANEL(POP45BY3)"
         pop_rc = rc
         "REMPOP ALL"
         if pop_rc = 8 then leave ; else iterate
         end                           /* make sure the PF3 was valid*/
 
      if zcmd <> "" then do
         call TDC_ZCMD                 /* F or L                    -*/
         end                           /* zcmd was populated         */
      else,
      do ztdsels
         "CONTROL DISPLAY SAVE"
         if sel = "K" then do          /* use KVW                    */
            address TSO "KVW"  mstr"("mbr")"
            end                        /* K                          */
         else,
         if Words(dslist.mbr) = 1 then do
            (action.sel) "DATASET('"dslist"("mbr")')"
            end
         else,
            call TDA_EXPAND            /*                           -*/
         "CONTROL DISPLAY RESTORE"
         if ztdsels = 1 then,          /* never do the last one      */
            ztdsels = 0
         else "TBDISPL" $tn$           /* next row                   */
      end                              /* ztdsels                    */
      sel = ""                         /* clear for reuse            */
 
   end                                 /* forever                    */
 
return                                 /*@ TD_DISPLAY                */
/*
   The selected member exists in more than one dataset.  Build a
   secondary table by dsname and allow selection.
.  ----------------------------------------------------------------- */
TDA_EXPAND: Procedure expose,          /*@                           */
   (tk_globalvars)  sel  mbr  $td$  action.  dslist.
   if branch then call BRANCH
   address ISPEXEC
 
   subact.  = action.sel
   subact.B = "BROWSE"
   subact.E = "EDIT"
   subact.V = "VIEW"
   "TBCREATE" $td$ "KEYS(TARGET) NOWRITE REPLACE"
   dslist = dslist.mbr
   do Words(dslist)
      parse var dslist  dsn dslist
      target = "'"dsn"("mbr")'"
      "TBADD" $td$
   end
 
   do forever
      "TBTOP" $td$
      "TBDISPL"  $td$  "PANEL(SHOWME02)"
      if rc > 4 then leave
 
      do ztdsels
         "CONTROL DISPLAY SAVE"
         (subact.sel) "DATASET("target")"
         "CONTROL DISPLAY RESTORE"
 
         if ztdsels = 1 then,          /* never do the last one      */
            ztdsels = 0
         else "TBDISPL" $td$           /* next row                  #*/
      end                              /* ztdsels                    */
 
   end                                 /* forever                    */
   "TBEND" $td$                        /* finished with table        */
 
return                                 /*@ TDA_EXPAND                */
/*
   The user entered text on the command line.  F (find) and L (locate)
   are supported commands.
.  ----------------------------------------------------------------- */
TDC_ZCMD:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   parse var zcmd  verb  text
   if Wordpos(Left(verb,1),"F L") > 0 then do
      "TBVCLEAR" $tn$
      mbr = Strip(text)"*"
      "TBSARG" $tn$ "NAMECOND(MBR,GE)"
      "TBTOP" $tn$
      call Z_TBSCAN                    /*                           -*/
      end                              /* L LOCATE F FIND            */
 
return                                 /*@ TDC_ZCMD                  */
/*
   Finished with the primary table.
.  ----------------------------------------------------------------- */
TU_CLOSE:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBEND" $tn$                        /* finished with table        */
 
return                                 /*@ TU_CLOSE                  */
/*
   Deactivate LIBDEFs
.  ----------------------------------------------------------------- */
TZ_DROP_PANELS:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF ISP"dd
      "FREE FI("$ddn")"
   end
 
return                                 /*@ TZ_DROP_PANELS            */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   sw.0exit_ISPF = SWITCH("RESTARTED") /* were we?                   */
   parse value  KEYWD("MEMLIM") 450   with,
                memlim   .             /* 450 unless specified       */
   if SWITCH("INSTALL") then do        /* set tmpcmds                */
      queue "SHOWME"                   /* zctverb                    */
      queue "0"                        /* zcttrunc                   */
      queue "SELECT CMD(%SHOWME &ZPARM)"   /* zctact                 */
      queue "Members across DD"        /* zctdesc                    */
      "FCCMDUPD"                       /* load the table             */
      exit
      end                              /* INSTALL                    */
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
ZB_SAVELOG:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   if Symbol("LOG#") = "LIT" then return          /* not yet set     */
   if sw.0Error_Found then,
      call ZL_LOGMSG("Error forced logging.")
 
   "ALLOC FI($LOG) DA("logdsn") REU" vb4k.0
   "EXECIO" log# "DISKW $LOG (STEM LOG. FINIS"
   "FREE  FI($LOG)"
 
return                                 /*@ ZB_SAVELOG                */
/*
.  ----------------------------------------------------------------- */
ZL_LOGMSG: Procedure expose,           /*@                           */
   (tk_globalvars)  log. log#  msglim
   address TSO
 
   parse arg msgtext
   do while Length(msgtext) > msglim
      pt  = LastPos(" ",msgtext,msglim)
      slug  = Left(msgtext,pt)
      parse value  log#+1  slug        with,
                   zz      log.zz    1  log#   .
      msgtext = "       "Substr(msgtext,pt)
   end                                 /* while msglim               */
   parse value  log#+1  msgtext     with,
                zz      log.zz    1  log#   .
 
   if monitor then say,
      msgtext
 
return                                 /*@ ZL_LOGMSG                 */
/*
     Find where code was run from.  It assumes cataloged data sets.
 
     Original by Doug Nadel
     With SWA code lifted from Gilbert Saint-flour's SWAREQ exec
.  ----------------------------------------------------------------- */
FIND_ORIGIN: Procedure                 /*@                           */
answer="* UNKNOWN *"                   /* assume disaster            */
Parse Source . . name dd ds .          /* get known info             */
Call listdsi(dd "FILE")                /* get 1st ddname from file   */
Numeric digits 10                      /* allow up to 7FFFFFFF       */
If name = "?" Then                     /* if sequential exec         */
  answer="'"ds"'"                      /* use info from parse source */
Else                                   /* now test for members       */
  If sysdsn("'"sysdsname"("name")'")="OK" Then /* if in 1st ds       */
     answer="'"sysdsname"("name")'"    /* go no further              */
  Else                                 /* hooboy! Lets have some fun!*/
    Do                                 /* scan tiot for the ddname   */
      tiotptr=24+ptr(12+ptr(ptr(ptr(16)))) /* get ddname array       */
      tioelngh=c2d(stg(tiotptr,1))     /* nength of 1st entry        */
      Do Until tioelngh=0 | tioeddnm = dd /* scan until dd found     */
        tioeddnm=strip(stg(tiotptr+4,8)) /* get ddname from tiot     */
        If tioeddnm <> dd Then         /* if not a match             */
          tiotptr=tiotptr+tioelngh     /* advance to next entry      */
        tioelngh=c2d(stg(tiotptr,1))   /* length of next entry       */
      End
      If dd=tioeddnm Then,             /* if we found it, loop through
                                          the data sets doing an swareq
                                          for each one to get the
                                          dsname                     */
        Do Until tioelngh=0 | stg(4+tiotptr,1)<> " "
          tioejfcb=stg(tiotptr+12,3)
          jfcb=swareq(tioejfcb)        /* convert SVA to 31-bit addr */
          dsn=strip(stg(jfcb,44))      /* dsname JFCBDSNM            */
          vol=storage(d2x(jfcb+118),6) /* volser JFCBVOLS (not used) */
          If sysdsn("'"dsn"("name")'")='OK' Then,  /* found it?      */
            Leave                      /* we is some happy campers!  */
          tiotptr=tiotptr+tioelngh     /* get next entry             */
          tioelngh=c2d(stg(tiotptr,1)) /* get entry length           */
        End
      answer="'"dsn"("name")'"         /* assume we found it         */
    End
Return answer                          /*@ FIND_ORIGIN               */
/*
.  ----------------------------------------------------------------- */
ptr:  Return c2d(storage(d2x(Arg(1)),4))          /*@                */
/*
.  ----------------------------------------------------------------- */
stg:  Return storage(d2x(Arg(1)),Arg(2))          /*@                */
/*
.  ----------------------------------------------------------------- */
SWAREQ:  Procedure                     /*@                           */
If right(c2x(Arg(1)),1) \= 'F' Then    /* SWA=BELOW ?                */
  Return c2d(Arg(1))+16                /* yes, return sva+16         */
sva = c2d(Arg(1))                      /* convert to decimal         */
tcb = c2d(storage(21c,4))              /* TCB PSATOLD                */
tcb = ptr(540)                         /* TCB PSATOLD                */
jscb = ptr(tcb+180)                    /* JSCB TCBJSCB               */
qmpl = ptr(jscb+244)                   /* QMPL JSCBQMPI              */
qmat = ptr(qmpl+24)                    /* QMAT QMADD                 */
Do While sva>65536
  qmat = ptr(qmat+12)                  /* next QMAT QMAT+12          */
  sva=sva-65536                        /* 010006F -> 000006F         */
End
return ptr(qmat+sva+1)+16              /*@ SWAREQ                    */
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
 
   address ISPEXEC "VGET ZSCREENW"
   fb80po.0  = "NEW UNIT("alcunit") SPACE(5 5) TRACKS DIR(40)",
                   "RECFM(F B) LRECL("zscreenw") BLKSIZE(0)"
   parse value ""   with  ddnlist $ddn.  daid.
 
   lastln   = sourceline()
   currln   = lastln
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
            "LMPUT DATAID("daid") MODE(INVAR) DATALOC(LINE)" ,
                      "DATALEN("zscreenw")"
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
   The table is positioned to find a row and the argument is set.
.  ----------------------------------------------------------------- */
Z_TBSCAN:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBSCAN" $tn$ "ROWID(LASTFND) POSITION(LASTCRP)"
                      /* set LASTFND and LASTCRP if successful       */
   if rc = 8 then do                   /* not found                  */
      zerrsm = "Not found"
      if pfkey = "F5" then,
         zerrlm = "End of table encountered."
      else,
         zerrlm = "No rows found to match" mbr
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      "TBSKIP" $tn$ "ROWID("lastfnd") NOREAD"
      end                              /* not found                  */
   else,
      "TBSKIP" $tn$ "NUMBER(-1) NOREAD"
 
return                                 /*@ Z_TBSCAN                  */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say Strip(helpmsg); say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"      Show members by DDname.                                   "
say "                                                                          "
say "  Syntax:   "ex_nam"  <ddnames>                                 (Required)"
say "                      <SELECT>                                            "
say "                      <DUPS>                                              "
say "                ((    <INSTALL>                                           "
say "                      <MEMLIM  count>                                     "
say "                                                                          "
say "            <ddnames> identifies the filenames to be examined.  The files "
say "                      must be allocated.                                  "
say "                                                                          "
say "            <SELECT>  causes the datasets allocated to <ddnames> to be    "
say "                      presented for de-selection.  This is especially     "
say "                      useful for DDNames which have many datasets         "
say "                      allocated when certain datasets are known to be of  "
say "                      marginal interest.  These datasets may be removed   "
say "                      from consideration before substantial work is done  "
say "                      to examine them.                                    "
say "                                                                          "
say "            <DUPS>    ignores members that exist in only one dataset.     "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "                                                                          "
say "            <INSTALL> loads a shortcut to your command table.  If INSTALL "
say "                      is specified no other functions are done.           "
say "                                                                          "
say "            <count>   Any dataset with more than MEMLIM members will cause"
say "                      the entire list to be presented as if SELECT had    "
say "                      been specified.  MEMLIM is set in LOCAL_PREINIT.    "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                  Displays most paragraph names upon entry.               "
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
say "        TSO "ex_nam" SYSEXEC SELECT  ((MONITOR TRACE ?R                   "
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
)))PLIB SHOWMEDS
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
  } TYPE(OUTPUT) INTENS(LOW)  SKIP(ON) JUST(RIGHT)
)BODY EXPAND(||) WIDTH(&ZSCREENW)
%|-| De-select Datasets +|-|
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
+
    Enter an%X+next to any dataset name to permanently remove it from
   /   the list.  PF3 to finish.  All remaining datasets will be scanned.
+ /         Datasets:!datasets+
+V     Mbrs   Dataset
)MODEL
_Z+  }mems  +!DSN
)INIT
  .ZVARS = '(SEL)'
  .CURSOR = SEL
  &SEL  = &Z
)REINIT
  .CURSOR = SEL
)PROC
)END
)))PLIB SHOWME01
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(||) WIDTH(&ZSCREENW)
%|-| Select Member +|-|
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
+
+  Enter any character to see all datasets for the specific member.
+ /         Datasets:!datasets+    Elements:!elements+
+V    Member     Dataset list....                             +Table@$tn$
)MODEL
_Z+  !MBR       @DSLIST
)INIT
  .ZVARS = '(SEL)'
  .CURSOR = SEL
  &SEL  = &Z
)REINIT
  .CURSOR = SEL
)PROC
)END
)))PLIB SHOWME02
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(||) WIDTH(&ZSCREENW)
%|-| Select Target Dataset +|-|
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
+
+   Enter%E,    B,     +or%V    +to
+  /     %Edit, Browse,+or%View
+ /
+V    Target Dataset
)MODEL
_Z+  !TARGET
)INIT
  .ZVARS = '(SEL)'
  .CURSOR = SEL
  &SEL  = &Z
)REINIT
  .CURSOR = SEL
)PROC
)END
)))PLIB POP45BY3
)ATTR
    %  TYPE(TEXT)   INTENS(HIGH)   SKIP(ON)
)BODY WINDOW(45,3)
+&popmsg1
+&popmsg2
+&popmsg3
)INIT
)PROC
)END
*/
