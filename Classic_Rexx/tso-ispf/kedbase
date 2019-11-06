/* REXX    KEDBASE    Edit/Browse by DDName
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke 19980216
 
     Impact Analysis
.    SYSPROC   TRAPOUT
.    (alias)   CNAXKED
.    (alias)   CNAXKBR
.    (alias)   CNAXKVW
 
     Modification History
     19980508 fxc delete .PLIB when done
     19991015 fxc upgrade from v.19971030 to v.19991006; new DEIMBED;
     20010718 fxc block PFSHOW
     20020314 fxc enable INSTALL
 
*/ arg argline
address TSO                            /* REXXSKEL ver.19991006      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
                                   if \sw.0error_found then,
call B_LISTA                           /*                           -*/
                                   if \sw.0error_found then,
call C_ACTION                          /*                           -*/
"FREE  FI("$ddn")"
 
exit                                   /*@ KEDBASE                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value "0 0 0 0 0 0 0 0 0 0" with,
         ct.     .
   parse value "VIEW" with,
         taction  stat.
   call AA_KEYWDS                      /*                           -*/
                                    if sw.0error_found then return
   if Sysvar("Sysicmd") = "CNAXKED" then taction = "EDIT" ; else,
   if Sysvar("Sysicmd") = "CNAXKVW" then taction = "VIEW" ; else,
   if Sysvar("Sysicmd") = "CNAXKBR" then taction = "BROWSE"
   actionlist = "SEBV"
 
   action.   = taction                 /* the default... when S      */
   action.E  = "EDIT"
   action.B  = "BROWSE"
   action.V  = "VIEW"
 
   if sw.0FIRST then nop
                else call AB_TBCREATE  /*                           -*/
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   info = Strip( info , "T" , ")" )
 
   sw.0FIRST    = SWITCH("FIRST")
   sw.0Direct   = SWITCH("FORCE") = "0" /* FORCE means 'show selection
                                           panel even if only 1 DSN' */
 
   parse var  info  ddn  . "(" mbr .
   mbr  = Strip( mbr  , "T" , ")" )
 
   if ddn = "" then do
      zerrsm = "DDName is required."
      zerrlm = exec_name "("BRANCH("ID")")",
               "I can't 'edit by DDName' if no DDName is supplied, can I?"
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"; return
      end ; else,
   if ddn = "CMDS" then do
      ddn = "SYSEXEC SYSPROC"
      end
 
   if mbr = "" then mlit = ""                /* no member            */
               else mlit = "MEMBERS" mbr     /* set up for LISTISPF  */
   sw.0NO_MEMBER = mlit = ""
   if sw.0NO_MEMBER then sw.0FIRST = "0"    /* ridiculous!           */
 
return                                 /*@ AA_KEYWDS                 */
/*
   FIRST was not specified.  A table will be needed to display the
   selectable list.
.  ----------------------------------------------------------------- */
AB_TBCREATE:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "CONTROL ERRORS RETURN"
   $tn$   = "T"Right(Time("L"),6,0)    /*                            */
   "TBCREATE" $tn$ "NAMES(TABLEDSN MDATE MTIME",
                         "DDNAME MUSER VV MM CDATE SIZE INIT MOD",
                         ") NOWRITE REPLACE"
   if rc > 4 then do
      zerrsm = "TBCREATE" $tn$ "failed."
      zerrlm = exec_name "("BRANCH("ID")")",
               "TBCREATE failed RC="rc
      "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"; return
      end
 
return                                 /*@ AB_TBCREATE               */
/*
   Get the list of datasets for this DDName.  Pass the list on to the
   appropriate subroutine.
.  ----------------------------------------------------------------- */
B_LISTA:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   "LA" ddn "(( STACK LIST"
   do queued()
      pull ddname ":" dsnlist
 
      if dsnlist = "(EMPTY)" then do
         zerrsm = ddn "is not allocated"
         zerrlm = exec_name "("BRANCH("ID")")",
                  "No datasets were found allocated to DDName" ddn
         address ISPEXEC "SETMSG MSG(ISRZ002)"
         sw.0error_found = "1"; return
         end
 
      if sw.0FIRST then call BA_LOCATE_FIRST                  /*    -*/
      else,
      if sw.0NO_MEMBER then call BB_LOAD_LIST                 /*    -*/
      else call BC_SHORT_LIST                                 /*    -*/
   end                                 /* queued                     */
   "DELSTACK"
 
return                                 /*@ B_LISTA                   */
/*
   FIRST was specified.  Find the first occurrance of this member and
   start an Edit/Browse/View session immediately.  Set sw.0ERROR_FOUND
   so that no further processing takes place.
.  ----------------------------------------------------------------- */
BA_LOCATE_FIRST:                       /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.0error_found = "1"               /* cause early termination    */
 
   do dsid = 1 to words(dsnlist)
      dsn = "'"Word(dsnlist,dsid)"("mbr")'"
      if Sysdsn(dsn) = "OK" then do    /* found one                  */
         address ISPEXEC (taction) "DATASET("dsn")"
         return
         end                           /* Sysdsn(dsn)                */
   end
 
   zerrsm = mbr "not found"
   zerrlm = exec_name "("BRANCH("ID")")",
            "Searched" dsnlist "but did not find" mbr "anywhere."
   address ISPEXEC "SETMSG  MSG(ISRZ002)"
 
return                                 /*@ BA_LOCATE_FIRST           */
/*
   No MEMBER was specified.  Load all DSNames to the list.
.  ----------------------------------------------------------------- */
BB_LOAD_LIST:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   parse value "" with  mdate mtime .
   do while dsnlist <> ""              /* for each dsn               */
      parse var dsnlist tabledsn dsnlist   /* isolate                */
      "TBADD" $tn$
      if rc > 0 then do
         zerrsm = "TBADD failed."
         zerrlm = exec_name "("BRANCH("ID")")",
                  "TBADD ended RC="rc "for" tabledsn
         "SETMSG  MSG(ISRZ002)"
         sw.0error_found = "1"; return
         end
   end                                 /* dsnlist                    */
 
return                                 /*@ BB_LOAD_LIST              */
/*
   A membername was specified.  Find all the DSNames which contain
   that member and load them to the list.
.  ----------------------------------------------------------------- */
BC_SHORT_LIST:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   do dsid = 1 to words(dsnlist)
      dsn = "'"Word(dsnlist,dsid)"("mbr")'"
      if Sysdsn(dsn) = "OK" then do    /* found one                  */
         mrc = Msg("OFF")
         call BCA_GET_STATS   Word(dsnlist,dsid)   mbr   /*         -*/
/*       address TSO "PIPE  LISTISPF '"Word(dsnlist,dsid)"'" mlit "| STEM STAT."
         mrc = Msg(mrc)
         if rc > 4 then iterate
         */
         tabledsn = Strip(dsn,,"'")    /* no quotes: dsn(mbr)        */
/*       parse var stat.1  25  mdate  mtime  .  40
         if mdate <> "" then,
            mdate = Translate("Yy/Mm/Dd", mdate ,"CcYyMmDd") */
         "TBADD"  $tn$
         if rc > 0 then do
            zerrsm = "TBADD failed."
            zerrlm = exec_name "("BRANCH("ID")")",
                     "TBADD ended RC="rc "for" tabledsn mdate mtime
            "SETMSG  MSG(ISRZ002)"
            sw.0error_found = "1"; return
            end
         sw.0FOUND_MBR = "1"
         ct.found = ct.found + 1       /* how many ?                 */
         end                           /* found one                  */
   end
   if queued() > 0 then return         /* more lines to process      */
 
   if \sw.0FOUND_MBR then do
      zerrsm = mbr "not found"
      zerrlm = exec_name "("BRANCH("ID")")",
               "Searched" dsnlist "but did not find" mbr "anywhere."
      "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"; return
      end                              /* member not found           */
 
   if sw.0Direct then,                 /* OK to process single DSN   */
   if ct.found = 1 then do             /* there's only one...        */
      sw.0error_found = "1"            /* Do it and bail out         */
      (taction) "DATASET('"tabledsn"')"
      end                              /* there's only one...        */
 
return                                 /*@ BC_SHORT_LIST             */
/*
.  ----------------------------------------------------------------- */
BCA_GET_STATS: Procedure expose,       /*@                           */
   (tk_globalvars) vv mm cdate mdate mtime size init mod muser
   if branch then call BRANCH
   address ISPEXEC
   arg dsn mbr .
 
   "LMINIT  DATAID(LMID) DATASET('"dsn"')"
   "LMOPEN  DATAID("lmid")"
   "LMMFIND DATAID("lmid") MEMBER("mbr") STATS(YES)"
   parse value zlvers zlmod zlcdate zlmdate zlmtime zlcnorc zlinorc zlmnorc,
         with  vv     mm    cdate   mdate   mtime   size    init    mod     .
   muser = zluser
   "LMCLOSE DATAID("lmid")"
   "LMFREE  DATAID("lmid")"
 
return                                 /*@ BCA_GET_STATS             */
/*
   The table is loaded.  Display and process selections.
.  ----------------------------------------------------------------- */
C_ACTION:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBTOP"    $tn$
   "LIBDEF ISPPLIB  LIBRARY  ID("$ddn") STACK"
   do forever
      "TBDISPL"  $tn$  "PANEL(KED)"
      if rc > 4 then leave
 
      do ztdsels
         "CONTROL DISPLAY SAVE"
         select                        /* what action this row ?     */
            when Pos(action,actionlist) > 0 then do
               l_action = action.action
               (l_action) "DATASET('"tabledsn"')"
               if rc > 0 then "SETMSG  MSG(ISRZ002)"
               else if mbr <> "" then,
                    if l_action = "EDIT" then do  /* update STATS    */
                  parse var tabledsn  dsn "("
                  call BCA_GET_STATS  dsn  mbr     /*               -*/
                  "TBMOD" $tn$
                  end
               end                     /* SB or SE or SV             */
            when WordPos(action,"C D") > 0 then do
               parse var tabledsn  temp "(" .
               address TSO "DUP '"temp"'"
               if rc > 0 then do
                  pop1 = "DUP" temp
                  pop2 = "returned RC="rc "in"
                  pop3 = exec_name branch("ID")
                  call X_POPMSG        /*                           -*/
                  end
               end                     /* C                          */
            when action = "L" then do
               parse var tabledsn  temp "(" .
               (taction) "DATASET('"temp"')"
               if rc > 0 then do
                  pop1 = taction temp
                  pop2 = "returned RC="rc "in"
                  pop3 = exec_name branch("ID")
                  call X_POPMSG        /*                           -*/
                  end
               end                     /* L                          */
            when action = "P" then do
               parse var tabledsn  temp "(" .
               address TSO "PDS '"temp"'"
               if rc > 0 then do
                  pop1 = "PDS" temp
                  pop2 = "returned RC="rc "in"
                  pop3 = exec_name branch("ID")
                  call X_POPMSG        /*                           -*/
                  end
               end                     /* P                          */
            otherwise nop
         end                           /* select                     */
         "CONTROL DISPLAY RESTORE"
         if ztdsels = 1 then,          /* never do the last one      */
            ztdsels = 0
         else "TBDISPL" $tn$           /* next row                   */
      end                              /* ztdsels                    */
 
   end                                 /* forever                    */
   "LIBDEF ISPPLIB"
 
return                                 /*@ C_ACTION                  */
/*
   An error was detected.  Pop up a warning message.
.  ----------------------------------------------------------------- */
X_POPMSG:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "VGET ZPFCTL"; save_zpf = zpfctl    /* save current setting       */
      zpfctl = "OFF"; "VPUT ZPFCTL"    /* PFSHOW OFF                 */
   "ADDPOP ROW(+1) COLUMN(+2)"
   "DISPLAY PANEL(POP40BY3)"
   "REMPOP ALL"
      zpfctl = save_zpf; "VPUT ZPFCTL" /* restore                    */
 
return                                 /*@ X_POPMSG                  */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   if SWITCH("INSTALL") then do        /* install commands           */
      queue "KBR"
      queue "0"
      queue "SELECT CMD(%CNAXKBR &ZPARM) NEWAPPL(ISR) PASSLIB"
      queue "Browse by DDName"
      "FCCMDUPD"
      queue "KED"
      queue "0"
      queue "SELECT CMD(%CNAXKED &ZPARM) NEWAPPL(ISR) PASSLIB"
      queue "Edit by DDName"
      "FCCMDUPD"
      queue "KVW"
      queue "0"
      queue "SELECT CMD(%CNAXKVW &ZPARM) NEWAPPL(ISR) PASSLIB"
      queue "View by DDName"
      "FCCMDUPD"
      exit
      end                              /* INSTALL                    */
   zerrhm     = "KEDH"
   call DEIMBED                        /*                           -*/
   $ddn = $ddn.PLIB
 
return                                 /*@ LOCAL_PREINIT             */
/*        Subroutines below LOCAL_PREINIT are not seen by SHOWFLOW   */
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
   do while sourceline(currln) <> "/*"
      text = sourceline(currln)        /* save with a short name !   */
      if Left(text,3) = ")))" then do  /* package the queue          */
         parse var text ")))" ddn mbr .   /* PLIB PANL001  maybe     */
         if Pos(ddn,ddnlist) = 0 then do  /* doesn't exist           */
            ddnlist = ddnlist ddn      /* keep track                 */
            $ddn = ddn || Random(999)
            $ddn.ddn = $ddn
            "ALLOC FI("$ddn")" fb80po.0
            address ISPEXEC "LMINIT DATAID(DAID) DDNAME("$ddn")"
            daid.ddn = daid
            end
         daid = daid.ddn
         address ISPEXEC "LMOPEN DATAID("daid") OPTION(OUTPUT)"
         do queued()
            parse pull line
            address ISPEXEC "LMPUT DATAID("daid") MODE(INVAR)",
                            "DATALOC(LINE) DATALEN(80)"
         end
         address ISPEXEC "LMMADD DATAID("daid") MEMBER("mbr")"
         address ISPEXEC "LMCLOSE DATAID("daid")"
         end                           /* package the queue          */
      else push text                   /* onto the top of the stack  */
      currln = currln - 1              /* previous line              */
   end                                 /* while                      */
   "DELSTACK"
 
return                                 /*@ DEIMBED                   */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say " HELP for" exec_name "                                            "
say "                                                                  "
say "  "ex_nam"      finds members by DDname.  All occurrences of the  "
say "                specified member will be shown on a selection     "
say "                panel with its datasetname and you may select it  "
say "                for Browse, Edit, or View.  If there is only one  "
say "                candidate member, it is selected automatically    "
say "                (unless FORCE).                                   "
say "                                                                  "
say "                "exec_name" is invoked via an alias (CNAXKBR,     "
say "                CNAXKED, or CNAXKVW) and the alias used implies   "
say "                the default action: Browse, Edit, or View.        "
say "                                                                  "
say "                The panel allows for several actions other than   "
say "                Browse, Edit, or View, including DUP, PDS, and a  "
say "                display of the enclosing dataset's member list.   "
say "                                                                  "
say "                                              more....            "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "  Syntax:   "ex_nam"  <mbrspec>                                   "
say "                      <FIRST>                                     "
say "                      <FORCE>                                     "
say "                  ((  <INSTALL>                                   "
say "                                                                  "
say "            mbrspec   is of the form 'DDName(Mbrname)'; DDName    "
say "                      'CMDS' equates to 'SYSEXEC and SYSPROC'     "
say "                                                                  "
say "            FIRST     causes the member in the most preferential  "
say "                      position to be selected unconditionally for "
say "                      the action implied by the invoking alias.   "
say "                                                                  "
say "            FORCE     results in the selection list being         "
say "                      displayed even if there is only a single    "
say "                      candidate member.                           "
say "                                                                  "
say "            FIRST and FORCE are logically mutually exclusive.     "
say "                                                                  "
say "            INSTALL   loads your command table with commands KBR, "
say "                      KED, and KVW.                               "
say "                                                                  "
say "                                              more....            "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                              "
say "                                                                  "
say "        MONITOR:  displays key information throughout processing. "
say "                  Displays most paragraph names upon entry.       "
say "                                                                  "
say "        USEHLQ:   causes dataset prefix to be altered as          "
say "                  specified.                                      "
say "                                                                  "
say "        NOUPDT:   by-pass all update logic.                       "
say "                                                                  "
say "        BRANCH:   show all paragraph entries.                     "
say "                                                                  "
say "        TRACE tv: will use value following TRACE to place         "
say "                  the execution in REXX TRACE Mode.               "
say "                                                                  "
say "                                                                  "
say "   Debugging tools can be accessed in the following manner:       "
say "                                                                  "
say "        TSO" ex_nam "    parameters  ((  debug-options            "
say "                                                                  "
say "   For example:                                                   "
say "                                                                  "
say "        TSO" ex_nam " (( MONITOR TRACE ?R                         "
 
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*      REXXSKEL back-end removed for space                          */
/*
)))PLIB KEDH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ)
+TUTORIAL บ-บ% Browse/Edit/View by DDName +บ-บ+TUTORIAL
%Next Selection ===>_ZCMD
 
+
   Select any line or lines.
 
   See the panel for functions which may be selected.
)PROC
)END
)))PLIB KED
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(บบ)
%บ-บ Browse/Edit/View by DDName +บ-บ
%COMMAND ===>_ZCMD
 
+
%B,E,V+- Select Dataset/Member  %L+-Edit entire PDS (Member List)  %D+- DUP
%|
%V+Datasets allocated to%&DDN
+- ----------------------------------------------------- -------- ----- --------
)MODEL
_Z!TABLEDSN                                             !DDNAME
                    @VV@MM+@CDATE   +@MDATE   +@MTIME+@SIZE+@INIT+@MOD+@MUSER  +
)INIT
  .ZVARS = '(ACTION)'
  &ACTION = ''
  .CURSOR = ACTION
  .HELP = KEDH
  &ZTDMARK = '********************** END OF DSNAME LIST FOR &DDNAME +
              ***************************'
  &ZTDMARK = TRUNC (&ZTDMARK,79)
)REINIT
  IF (&MSG = ' ')
     &ACTION = ' '
     REFRESH (&ACTION)
)PROC
)END
*/
