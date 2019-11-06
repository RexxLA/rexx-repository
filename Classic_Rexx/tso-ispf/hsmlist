/* REXX    HSMLIST    A dialog to ease the use of HSM's HLIST
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke 20010608
 
     Impact Analysis
.    SYSEXEC   POST
.    SYSEXEC   TRAPOUT
 
     Modification History
     20010620 fxc zap the table row on 'delete';
     20011002 fxc fix scroll-amt field;
     20020102 fxc add HELP panel; log table-load; WIDEHELP;
     20020423 fxc NOVALUE in CB_;
     20020607 fxc reorg;
     20020918 fxc progress msg during HLIST; allow KEEP of HLIST
                  output;
     20030218 fxc remove obsolete code;
     20031121 fxc text on panels;
     20040722 fxc widescreen version;
     20050218 fxc HELP for main panel;
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.20010524      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
"CONTROL ERRORS RETURN"                /* I'll handle my own         */
 
address TSO "POST" exec_name argline
call A_INIT                            /*                           -*/
 
call C_TABLE_OPS                       /*                           -*/
                                    if \sw.0halt_process then,
call D_HSM_OPS                         /*                            */
 
call ZB_SAVELOG                        /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ HSMLIST                   */
/*
   Initialization
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call AL_SETUP_LOG                   /*                           -*/
   parse value "0 0 0 0 0 0 0 0 0" with ,
         req.  ,
         .
 
   parse value "" with ,
         dslevel  odsn ,
         dsname  backdt  backtm  gen ,
         .
   call AP_KEYWDS                      /*                           -*/
   parse var info   dslevel  info
 
return                                 /*@ A_INIT                    */
/*
   Allocate the LOG dataset
.  ----------------------------------------------------------------- */
AL_SETUP_LOG:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value "0" with,
               log#    log.
   parse value Date("S")  Time("S")  Time("N")  with,
               yyyymmdd   sssss      hhmmss  .
   parse var yyyymmdd  4 yrdigit 5 mm 7 dd          /* 9 12 14 maybe */
   if Pos(yrdigit,"13579") > 0 then mm = mm + 12       /* mm=24      */
   logtag = Substr("ABCDEFGHIJKLMNOPQRSTUVWX",mm,1)    /* logtag=X   */
   subid  = logtag""dd""Right(sssss,5,0)               /* X1423722 ? */
   vb4k.0    = "NEW CATALOG UNIT(SYSDA) SPACE(1 5) TRACKS",
               "RECFM(V B) LRECL(4096) BLKSIZE(0)"
   vb4k.1    = "SHR"                   /* if it already exists...    */
   logdsn = "@@LOG."exec_name"."subid".#CILIST"
 
   call ZL_LOGMSG("Log started by" Userid()  yyyymmdd  hhmmss)
   call ZL_LOGMSG("Arg:" argline)
 
return                                 /*@ AL_SETUP_LOG              */
/*
.  ----------------------------------------------------------------- */
AP_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.0KeepList = SWITCH("SAVE")
 
return                                 /*@ AP_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
C_TABLE_OPS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call C0_PROLOG                      /*                           -*/
   call CA_HLIST                       /*                           -*/
                                    if \sw.0halt_process then,
   call CB_LOAD_TABLE                  /*                           -*/
                                    if \sw.0halt_process then,
   call CD_DISPLAY                     /*                           -*/
   call CZ_EPILOG                      /*                           -*/
 
return                                 /*@ C_TABLE_OPS               */
/*
.  ----------------------------------------------------------------- */
C0_PROLOG:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call DEIMBED                        /*                           -*/
   call C0A_SETUP_LIBDEFS              /*                           -*/
 
return                                 /*@ C0_PROLOG                 */
/*
   Attach the extracted ISPF material
.  ----------------------------------------------------------------- */
C0A_SETUP_LIBDEFS:                     /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ C0A_SETUP_LIBDEFS         */
/*
   HLIST the requested datasets
.  ----------------------------------------------------------------- */
CA_HLIST:                              /*@                           */
   if branch then call BRANCH
   address TSO
 
   if dslevel = ""  then do
      call ZL_LOGMSG("No input parm.")
      call CAG_GET_PARMS               /*                           -*/
      end
                                    if sw.0halt_process then return
   call ZL_LOGMSG("Using" dslevel)
   call CAM_PROGRESS_MSG               /*                           -*/
 
   parse value odsn "TEMP.SYSPRINT"   with   odsn  .
 
   "HLIST LEVEL("dslevel") BOTH ODS("odsn")"
 
return                                 /*@ CA_HLIST                  */
/*
   Caller didn't pass a parm.  Get the catalog level to be HLISTed
.  ----------------------------------------------------------------- */
CAG_GET_PARMS:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "DISPLAY PANEL(HLPARM)"
   sw.0halt_process = rc > 0
 
return                                 /*@ CAG_GET_PARMS             */
/*
.  ----------------------------------------------------------------- */
CAM_PROGRESS_MSG:                      /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "CONTROL DISPLAY LOCK"
   parse value "" with pop1 pop2 pop3 pop4
   pop2 = "    Obtaining HSM data."
   "ADDPOP ROW(12) COLUMN(3)"
   "DISPLAY PANEL(POP40BY4)"
   "REMPOP ALL"
 
return                                 /*@ CAM_PROGRESS_MSG          */
/*
   Create the table and load the HLIST data to it.
.  ----------------------------------------------------------------- */
CB_LOAD_TABLE:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBCREATE  HSML  KEYS(DSNAME GEN) NAMES(TYPEMORB BACKDT BACKTM VER)",
            "NOWRITE REPLACE"
 
   address TSO "NEWSTACK"
   call CBQ_LOAD_QUEUE                 /* HLIST output to queue     -*/
 
   "CONTROL DISPLAY LOCK"
   pop3 = "    Loading temporary table"
   "ADDPOP ROW(12) COLUMN(3)"
   "DISPLAY PANEL(POP40BY4)"
   "REMPOP ALL"
 
   typemorb = "M"                      /* migrated                   */
   do queued()
      pull 2 line
      if Pos("BACKUP DATASET-",line) > 0 then leave
      if Pos("LAST REF MIGRAT",line) > 0 then sw.0ready = "1"
      if Pos("MIGRATED"       ,line) > 0 then iterate
      if Pos("CONTROL DATASET",line) > 0 then iterate
      if \sw.0ready then iterate
      if Left(line,12) = "" then iterate
 
      /* process this line ------------------------                  */
      parse var line dsname vol refdt backdt .
      "TBADD  HSML"
      call ZL_LOGMSG("M" Left(dsname,44) vol refdt backdt)
   end                                 /* queued                     */
 
   typemorb = "B"                      /* backed-up                  */
   dsname = ""
   do queued()
      pull 2 line
      if Word(line,1) = "DSNAME" then do
         parse var line . . dsname .
         iterate ;   end
      if dsname = "" then iterate
      if Pos("BACKUP VERSION ",line) > 0 then iterate
      if Pos("VOLUME  VOLUME ",line) > 0 then iterate
      if line = "" then,               /* empty line                 */
         if gen = "" then iterate      /* skip                       */
      else do
         parse value "" with gen dsname
         iterate ; end
      /* process this line ------------------------                  */
      parse var line 67 backdt . 77 backtm . 92 gen . 98 ver .
      "TBADD  HSML"
      call ZL_LOGMSG("B" Left(dsname,44) gen ver backdt backtm)
   end                                 /* queued                     */
   "TBSORT  HSML  FIELDS(DSNAME,C,A,GEN,N,D)"
 
   address TSO "DELSTACK"
 
return                                 /*@ CB_LOAD_TABLE             */
/*
.  ----------------------------------------------------------------- */
CBQ_LOAD_QUEUE:                        /*@                           */
   if branch then call BRANCH
   address TSO
 
   "ALLOC FI($TMP) DA("odsn") SHR REU"
   "EXECIO * DISKR $TMP (FINIS"
   "FREE  FI($TMP)"
 
   call ZL_LOGMSG(queued() "lines on SYSPRINT")
   if sw.0KeepList then return         /* don't delete the data      */
 
   $z = Msg("OFF")
   "DELETE TEMP.SYSPRINT"
   $z = Msg($z)
 
return                                 /*@ CBQ_LOAD_QUEUE            */
/*
   Show the list of datasets and let the caller select datasets for
   HRECALL, HRECOVER, HDELETE, or HBDELETE.
.  ----------------------------------------------------------------- */
CD_DISPLAY:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   $tn$  = "HSML"
   do forever
      "TBDISPL" $tn$ "PANEL(HLDETL)"
      if rc > 4 then leave             /* PF3 ?                      */
 
      if zcmd ^= "" then do
         "CONTROL DISPLAY SAVE"
         call CDP_PROCESS_CMD
         "CONTROL DISPLAY RESTORE"
         iterate
         end
 
      do ztdsels
         select
            when action = "D" then do  /* Delete                     */
               call CDD_HDELETE        /*                           -*/
               end
            when action = "R" then do  /* Recall/Recover             */
               call CDR_RECALL         /*                           -*/
               end
            otherwise nop
         end                           /* Select                     */
 
         if verb = "" then iterate     /* no action requested        */
 
         Parse value req.0+1 verb           with,
                     $z$     req.$z$     1  req.0  .
         call ZL_LOGMSG(verb)          /* Log the action             */
 
         if ztdsels = 1 then,          /* never do the last one      */
            ztdsels = 0
         else "TBDISPL" $tn$           /* next row                   */
      end                              /* ztdsels                    */
      action = ''                      /* clear for re-display       */
   end                                 /* forever                    */
 
return                                 /*@ CD_DISPLAY                */
/*
   Format the command which will be issued to HSM.
.  ----------------------------------------------------------------- */
CDD_HDELETE:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if typemorb = "B" then verb = "HBDELETE '"dsname"' VERSIONS("ver")"
                     else verb = "HDELETE  '"dsname"'"
   "TBDELETE" $tn$                     /* zap the row                */
 
return                                 /*@ CDD_HDELETE               */
/*
.  ----------------------------------------------------------------- */
CDP_PROCESS_CMD:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   parse var zcmd  cmdverb cmdtext     /*                            */
   select
      when cmdverb = "RECAP" then do   /*                            */
         call CDPR_RECAP               /*                           -*/
         end                           /* RECAP                      */
      otherwise nop
   end                                 /* select                     */
 
return                                 /*@ CDP_PROCESS_CMD           */
/*
.  ----------------------------------------------------------------- */
CDPR_RECAP:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBCREATE  HSCMDS  NAMES(HSCMD) NOWRITE REPLACE"
   do cz = 1 to req.0
      hscmd = req.cz
      "TBADD  HSCMDS"
   end                                 /* cz                         */
 
   "TBTOP  HSCMDS"
   do forever
      "TBDISPL  HSCMDS  PANEL(HLRECAP)"
       if rc > 4 then leave
 
      do ztdsels
         "CONTROL DISPLAY SAVE"
 
         select
 
            when sel = "D" then "TBDELETE HSCMDS"
 
            otherwise nop
 
         end                           /* select                     */
 
         "CONTROL DISPLAY RESTORE"
 
         if ztdsels > 1 then "TBDISPL  HSCMDS"
 
      end                              /* ztdsels                    */
 
      sel = ""
 
   end                                 /* forever                    */
 
   "TBTOP  HSCMDS"
   req.0 = 0
   do forever
      "TBSKIP  HSCMDS"
      if rc > 0 then leave
      parse value req.0+1 hscmd  with ,
                  $z$     req.$z$    1   req.0   .
   end                                 /* forever                    */
 
   "TBEND    HSCMDS"
 
return                                 /*@ CDPR_RECAP                */
/*
   HRecover or HRecall the dataset.  If it is in "backed-up" status,
   HRECOVER; if migrated, HRECALL.
.  ----------------------------------------------------------------- */
CDR_RECALL:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   if typemorb = "B" then verb = CDRA_NEW_OR_REP()
                     else verb = "HRECALL  '"dsname"'"
 
return                                 /*@ CDR_RECALL                */
/*
   HRECOVER this dataset, but first... does it already exist?  If so,
   ask the caller whether to replace the existing copy or give it a
   new name.
.  ----------------------------------------------------------------- */
CDRA_NEW_OR_REP:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   badcodes = "0001 0005 0008 0017 0019 0020 0021 0023 0027 0028",
              "0029 0030 0031 0032 0033 0034 0035 0036"
   verb = ""
   ldrc = LISTDSI("'"dsname"' NORECALL")
   if Wordpos(sysreason,badcodes) > 0 then do
      verb = "HRECOVER '"dsname"' VERSION("ver") REPLACE"
      return(verb)
      end
 
   "DISPLAY PANEL(HLVERF)"             /* sets REPLACE or NEWDSN     */
   if rc > 0 then return(verb)         /* PF 3 ?                     */
 
   if newdsn <> "" then,
      verb = "HRECOVER '"dsname"' VERSION("ver") NEWNAME('"newdsn"')"
                   else,
   if repl   <> "" then,
      verb = "HRECOVER '"dsname"' VERSION("ver") REPLACE"
 
return(verb)                           /*@ CDRA_NEW_OR_REP           */
/*
   Disconnect the ISPF material and FREE the files.
.  ----------------------------------------------------------------- */
CZ_EPILOG:                             /*@                           */
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
 
return                                 /*@ CZ_EPILOG                 */
/*
   Issue all the commands collected for the actions requested.
.  ----------------------------------------------------------------- */
D_HSM_OPS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   do dx = 1 to req.0                  /* every request              */
      parse var req.dx verb
      (verb)                           /* execute the command        */
   end                                 /* dx                         */
 
return                                 /*@ D_HSM_OPS                 */
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
 
   address ISPEXEC "VGET ZSCREENW"
   fb80po.0  = "NEW UNIT(VIO) SPACE(5 5) TRACKS DIR(40)",
                   "RECFM(F B) LRECL("zscreenw") BLKSIZE(0)"
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
.  ----------------------------------------------------------------- */
ZB_SAVELOG:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   if Symbol("LOG#") = "LIT" then return          /* not yet set     */
 
   "ALLOC FI($LOG) DA("logdsn") REU" vb4k.0
   "EXECIO" log# "DISKW $LOG (STEM LOG. FINIS"
   "FREE  FI($LOG)"
 
return                                 /*@ ZB_SAVELOG                */
/*
.  ----------------------------------------------------------------- */
ZL_LOGMSG: Procedure expose,           /*@                           */
   (tk_globalvars)  log. log#
   rc = Trace("O")
   address TSO
 
   parse arg msgtext
   parse value  log#+1  msgtext     with,
                zz      log.zz    1  log#   .
 
   if monitor then say,
      msgtext
 
return                                 /*@ ZL_LOGMSG                 */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      eases the burden of manipulating backed-up and migrated   "
say "                versions of datasets.  It produces a scrollable list of   "
say "                the datasets for the specified <dslevel> and allows the   "
say "                caller to delete, recall, and recover datasets.  For any  "
say "                shown dataset, entering a 'D' next to the dataset name    "
say "                causes that backed-up or migrated dataset to be deleted.  "
say "                Any other character will cause the dataset to be recovered"
say "                or recalled as appropriate.                               "
say "                                                                          "
say "  Syntax:   "ex_nam"  <dslevel>                                           "
say "                ((    <SAVE>                                              "
say "                                                                          "
say "            <dslevel> identifies the catalog level for which an HLIST is  "
say "                      to be done.  The datasets referenced will be used to"
say "                      populate the display.                               "
say "                                                                          "
say "            <SAVE>    orders that the output from HLIST is to be kept     "
say "                      rather than deleted.                                "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                                                                          "
say "        NOUPDT:   by-pass all update logic.                               "
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
/* 			REXXSKEL back-end removed for space 					*/
/*
)))PLIB HLPARM
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT)  INTENS(LOW)
  @ TYPE(TEXT)   INTENS(HIGH) COLOR(YELLOW)
  ! TYPE(INPUT)  INTENS(NON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
@บ-บ% Verify Parameters for HLIST @บ-บ
%COMMAND ===>_ZCMD
                                                             %SCROLL ===>_ZAMT+
+
         Catalog Level ===>_dslevel
+
)INIT
  .HELP = HLPARMH
)PROC
   VER (&DSLEVEL,NB,DSNAME)
)END
)))PLIB HLPARMH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%TUTORIAL บ-บ Verify Parameters for HLIST บ-บ TUTORIAL
%Next Selection ===>_ZCMD
 
+
    Specify the high-level qualifiers you wish to have displayed.  The
    specification should be unquoted.
 
    The more precise this specification, the shorter will be the list,
    and the quicker the display will be ready.  Example:
 
         Catalog Level ===> ntin.ts.d822.lib
 
)PROC
)END
)))PLIB HLDETL
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%บ-บ Available Migrated/Backed-up Datasets +บ-บ
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
+              (See HELP-text for more information)          Back-Up
+V Gen M/B Dataset Name (Base)                             Date     Time
)MODEL
_z!gen+!z+!dsname                                        !backdt  !backtm
)INIT
  .ZVARS = '(ACTION TYPEMORB)'
  .HELP = HLDETLH
)REINIT
)PROC
)END
)))PLIB HLDETLH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%TUTORIAL บ-บ Available Migrated/Backed-up Datasets ....  บ-บ TUTORIAL
%Next Selection ===>_ZCMD
 
+
    The datasets available for HRECALL, HRECOVER, HDELETE, and HBDELETE are
    shown in a scrollable list.
 
    You may enter%D+next to any line to cause the shown dataset to be%HDELETEd+
    or%HBDELETEd+as appropriate.
 
    You may enter%R+next to any line to cause the shown dataset to be%HRECALLed+
    or%HRECOVERed+as appropriate.
 
    At any time you may get a list of the commands queued for execution by
    typing%RECAP+on the command line.
 
)PROC
)END
)))PLIB HLVERF
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT)  INTENS(LOW) CAPS(ON)
  @ TYPE(TEXT)   INTENS(HIGH) COLOR(YELLOW)
  { TYPE(OUTPUT) INTENS(HIGH) COLOR(YELLOW)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
@บ-บ% HRECOVER Options @บ-บ
%COMMAND ===>_ZCMD
                                                             %SCROLL ===>_ZAMT+
+
+  Dataset{dsname
+  exists.  Specify a new dataset name for the HRECOVER operation,
+  or indicate REPLACE below.
+
+  New DSN ===>_newdsn
+              (Fully-qualified unquoted)
+
+
+  REPLACE ===>_Z+
+
)INIT
   .ZVARS = '(REPL)'
   &NEWDSN = &Z
   &REPL = &Z
)PROC
   IF (VER(&NEWDSN,DSNAME))
   ELSE
      &ZERRHM = 'ISR00000'
      &ZERRSM = 'NEWDSN invalid'
      &ZERRLM = 'NEWDSN must be a valid DSNAME.'
      &ZERRALRM = 'YES'
      .MSG = ISRZ002
      EXIT
 
   IF (&REPL EQ &Z)
      IF (&NEWDSN EQ &Z)
         &ZERRHM = 'ISR00000'
         &ZERRSM = 'Nothing selected'
         &ZERRLM = 'One and only one field may be filled.  When REPLACE +
                    is empty, NEW DSN may not be blank.'
         &ZERRALRM = 'YES'
         .MSG = ISRZ002
   ELSE
      IF (&NEWDSN NE &Z)
         &ZERRHM = 'ISR00000'
         &ZERRSM = 'Too much data'
         &ZERRLM = 'One and only one field may be filled.  When REPLACE +
                    is used, NEW DSN must be blank.'
         &ZERRALRM = 'YES'
         .MSG = ISRZ002
)END
)))PLIB HLRECAP
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%บ-บ HSMLIST Commands in storage +บ-บ
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
+  /------- %D+to drop this HSM command
+ /
+V Command
)MODEL
_z!hscmd
)INIT
  .ZVARS = '(SEL)'
  .HELP = HLDETLH
)REINIT
)PROC
)END
)))PLIB POP40BY4
)ATTR
    %  TYPE(TEXT)   INTENS(HIGH)   SKIP(ON)
)BODY WINDOW(40,4)
+&pop1
+&pop2
+&pop3
+&pop4
)INIT
)PROC
)END
*/
