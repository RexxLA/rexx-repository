/* REXX    TBLMSTR    Master Table Maintenance:  This table
                      maintenance routine handles changes to the
                      AAMSTR table.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke, Richmond, 19990716
 
     Impact Analysis
.    SYSPROC   FCCMDUPD
.    SYSPROC   TRAPOUT
.    ISPPLIB   AASEL         (Imbed)
.    ISPPLIB   AADAT         (Imbed)
.    ISPTLIB   AAMSTR
 
     Modification History
     19991129 fxc upgrade from v.19980225 to v.19991109; new DEIMBED;
     20011002 fxc fixed scroll-amt field;
     20020423 fxc allow multiple selections; auto-install;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
"POST" exec_name argline
call A_INIT                            /*                           -*/
call B_TABLE_OPS                       /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ TBLMSTR                   */
/*
   Initialize all variables
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call AA_KEYWDS                      /*                           -*/
 
   parse value " "    with,
         pnl.
   pnl.select    = "AASEL"             /* Selection panel            */
   pnl.datent    = "AADAT"             /* Data Entry panel           */
   openmode.0    = "WRITE"             /* based on NOUPDT            */
   openmode.1    = "NOWRITE"
 
return                                 /*@ A_INIT                    */
/*
   Extract parameters                  /*                            */
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
 
return                                 /*@ AA_KEYWDS                 */
/*
   Acquire data via panels.
.  ----------------------------------------------------------------- */
B_TABLE_OPS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
   "CONTROL ERRORS RETURN"             /* I'll handle my own         */
 
   call BA_OPEN                        /*                           -*/
                                    if \sw.0error_found then,
   call BD_DISPLAY                     /*                           -*/
   call BZ_CLOSE                       /*                           -*/
 
return                                 /*@ B_TABLE_OPS               */
/*
   Open the table; initialize as necessary.
.  ----------------------------------------------------------------- */
BA_OPEN:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LIBDEF  ISPTLIB  DATASET  ID("isptlib") STACK"
   "TBSTATS" $tn$ "STATUS1(s1) STATUS2(s2)"
   if s1 > 1 then do                   /* table not found            */
      call BAA_INIT_MSTR               /* Build a new AAMSTR table  -*/
      end; else,
   if s2 = 1 then do
      "TBOPEN " $tn$  openmode.noupdt
      end
   else "TBTOP" $tn$
   "LIBDEF  ISPTLIB"
 
return                                 /*@ BA_OPEN                   */
/*
   TBCREATE the AAMSTR table and TBADD the first entry.
.  ----------------------------------------------------------------- */
BAA_INIT_MSTR:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBCREATE" $tn$ "KEYS(AATBLID)",
                   "NAMES(AATBLNM AAKEYS AANAMES AASORT AADESC)",
                   openmode.noupdt
   aatblid   = "AA"                    /* ID for AAMSTR              */
   aatblnm   = "AAMSTR"                /* its name                   */
   aakeys    = "AATBLID"               /* the only key field         */
   aanames   = "AATBLNM AAKEYS AANAMES AASORT AADESC" /* name fields */
   aasort    = "AATBLID,C,A"           /* how it's sorted            */
   aadesc    = "Master Table"          /* how it's described         */
   "TBADD"  $tn$                       /* load these values          */
   sw.0table_changed = "1"             /* mark it 'changed'          */
 
return                                 /*@ BAA_INIT_MSTR             */
/*
   Main table processing: display table, handle updates.
.  ----------------------------------------------------------------- */
BD_DISPLAY:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BDA_PROLOG                     /* extract/setup panels      -*/
   do forever
      "TBDISPL" $tn$ "PANEL("pnl.select")"  /* show selection panel  */
      if rc > 4 then leave             /* PF3 ?                      */
 
      do ztdsels
         "CONTROL DISPLAY SAVE"
         select
            when Wordpos(action,"B") > 0 then do
               call BDB_BROWSE         /*                           -*/
               end
            when Wordpos(action,"E U") > 0 then do
               call BDC_CHANGE         /*                           -*/
               end
            when Wordpos(action,"D") > 0 then do
               call BDD_DELETE         /*                           -*/
               end
            when Wordpos(action,"I") > 0 then do
               call BDI_INSERT         /*                           -*/
               end
            otherwise nop
         end                           /* Select                     */
         "CONTROL DISPLAY RESTORE"
         if ztdsels = 1 then,          /* never do the last one      */
            ztdsels = 0
         else "TBDISPL" $tn$           /* next row                   */
      end                              /* ztdsels                    */
      action = ''                      /* clear for re-display       */
   end                                 /* forever                    */
 
   call BDZ_EPILOG                     /* drop LIBDEFs               */
 
return                                 /*@ BD_DISPLAY                */
/*
.  ----------------------------------------------------------------- */
BDA_PROLOG:                            /*@                           */
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
 
return                                 /*@ BDA_PROLOG                */
/*
   Display the row data.  Do not store changes.
.  ----------------------------------------------------------------- */
BDB_BROWSE:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   io     = "OUTPUT"                   /* attribute for AATBLID      */
   do forever                          /*                            */
      zerrsm = "Changes disallowed"
      zerrlm = "You selected BROWSE.  To make changes, go back and",
               "select EDIT or UPDATE."
      "SETMSG  MSG(ISRZ002)"
      "DISPLAY PANEL("pnl.datent")"
      if rc > 0 then leave
   end                                 /* forever                    */
 
return                                 /*@ BDB_BROWSE                */
/*
   Display the data for this row; accept updates.
.  ----------------------------------------------------------------- */
BDC_CHANGE:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   io     = "OUTPUT"                   /* attribute for AATBLID      */
   do forever                          /*                            */
      "DISPLAY PANEL("pnl.datent")"
      if rc > 0 then leave
   end                                 /* forever                    */
 
   if rc = 8 then "TBMOD" $tn$         /* insert changes             */
   else do                             /* DISPLAY failed ?           */
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      "SETMSG  MSG(ISRZ002)"
      drop zerrlm                      /* make it a LIT again        */
      sw.0error_found = "1"; return
      end
 
   /* check the results of the TBMOD                                 */
   if rc > 0 then do
      zerrsm = "Update failed for AATBLID" aatblid"."
      if Symbol("zerrlm") = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      "SETMSG  MSG(ISRZ002)"
      drop zerrlm                      /* make it a LIT again        */
      sw.0error_found = "1"; return
      end
   sw.0table_changed = "1"             /* mark it 'changed'          */
 
return                                 /*@ BDC_CHANGE                */
/*
   Delete this row.
.  ----------------------------------------------------------------- */
BDD_DELETE:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBDELETE" $tn$
   if rc > 0 then do
      zerrsm = "Delete failed for AATBLID" aatblid"."
      if Symbol("zerrlm") = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      "SETMSG  MSG(ISRZ002)"
      drop zerrlm                      /* make it a LIT again        */
      sw.0error_found = "1"; return
      end
   sw.0table_changed = "1"             /* mark it 'changed'          */
 
return                                 /*@ BDD_DELETE                */
/*
   Display a blank panel for adding a new entry.
.  ----------------------------------------------------------------- */
BDI_INSERT:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   io     = "INPUT"                    /* attribute for AATBLID      */
   parse value "" with   AATBLID,
                         AATBLNM AAKEYS AANAMES AASORT AADESC
 
   do forever                          /* until PF3                  */
      "DISPLAY PANEL("pnl.datent")"
      if rc > 0 then leave
   end                                 /* forever                    */
 
   if rc = 8 then "TBADD" $tn$         /* insert changes             */
   else do                             /* DISPLAY failed ?           */
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      "SETMSG  MSG(ISRZ002)"
      drop zerrlm                      /* make it a LIT again        */
      sw.0error_found = "1"; return
      end
 
   /* check the results of the TBADD                                 */
   if rc > 0 then do
      zerrsm = "Insert failed for AATBLID" aatblid"."
      if Symbol("zerrlm") = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      "SETMSG  MSG(ISRZ002)"
      drop zerrlm                      /* make it a LIT again        */
      sw.0error_found = "1"; return
      end
   sw.0table_changed = "1"             /* mark it 'changed'          */
 
return                                 /*@ BDI_INSERT                */
/*
.  ----------------------------------------------------------------- */
BDZ_EPILOG:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      "LIBDEF  ISP"dd
   end
 
return                                 /*@ BDZ_EPILOG                */
/*
   Close table.  If the data has changed, TBCLOSE; otherwise TBEND.
   The table may have been opened NOWRITE if NOUPDT was specified.
   In that case, both TBEND and TBCLOSE purge any changes.
.  ----------------------------------------------------------------- */
BZ_CLOSE:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LIBDEF  ISPTABL  DATASET  ID("isptabl") STACK"
   if sw.0table_changed then do
      "TBSORT "  $tn$ "FIELDS(AATBLID,C,A)"
      "TBCLOSE"  $tn$                  /* write to ISPTABL           */
      end
   else,
      "TBEND  "  $tn$                  /* purge                      */
   "LIBDEF  ISPTABL"
 
return                                 /*@ BZ_CLOSE                  */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   if SWITCH("INSTALL") then do
      queue "AA"                       /* zctverb                    */
      queue "0"                        /* zcttrunc                   */
      queue "SELECT CMD(%TBLMSTR &ZPARM)"    /* zctact               */
      queue "AA table Update"          /* zctdesc                    */
      "FCCMDUPD"                       /* load the table             */
      exit
      end                              /* INSTALL                    */
 
   parse value KEYWD("ISPTLIB") "'NTIN.TS.D822.LIB.ISPTLIB'"   with,
               isptlib   .
 
   parse value KEYWD("ISPTABL")  isptlib    with,
               isptabl   .
 
   parse value KEYWD("USETBL")  "AAMSTR"     with ,
               $tn$     .
 
 
return                                 /*@ LOCAL_PREINIT             */
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
 
say "  "ex_nam"      displays/updates AAMSTR, the Master Table Control table   "
say "                used primarily by TBLGEN.                                 "
say "                                                                          "
say "  Syntax:   "ex_nam"  <no parms>                                          "
say "                  ((  ISPTLIB <input-dsn>                (Defaults)       "
say "                      ISPTABL <output-dsn>               (Defaults)       "
say "                      USETBL  <table-name>               (Defaults)       "
say "                      INSTALL                                             "
say "                                                                          "
say "            <input-dsn>    a TSO-format dataset name to be used as        "
say "                      ISPTLIB.   If not specified, this will default to   "
say "                      'NTIN.TS.D822.LIB.ISPTLIB'.                         "
say "                                                                          "
say "            <output-dsn>    a TSO-format dataset name to be used as       "
say "                      ISPTABL.  If not specified, the current value of    "
say "                      ISPTLIB is used.                                    "
say "                                                                          "
say "            <table-name>    the table name to be used for all table       "
say "                      operations.  If not specified, it defaults to       "
say "                      'AAMSTR'.                                           "
say "                                                                          "
say "            <INSTALL> adds a shortcut (AA) for this routine to the user's "
say "                      command table.  If INSTALL is specified, no other   "
say "                      processing takes place.                             "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:"
say "                                                                 "
say "        NOUPDT:   by-pass all update logic."
say "                                                                 "
say "        BRANCH:   show all paragraph entries."
say "                                                                 "
say "        TRACE tv: will use value following TRACE to place"
say "                  the execution in REXX TRACE Mode."
say "                                                                 "
say "                                                                 "
say "   Debugging tools can be accessed in the following manner:"
say "                                                                 "
say "        TSO" exec_name"  parameters  ((  debug-options"
say "                                                                 "
say "   For example:"
say "                                                                 "
say "        TSO" exec_name " (( MONITOR TRACE ?R"
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*      REXXSKEL back-end removed for space                          */
/*  Embedded components follow
)))PLIB AASEL
)ATTR
/* ------ Change Log ----------------------------------------------- */
/* --Date-- --by------ -Description of change ---------------------- */
/* 19990719 F.Clarke   New                                           */
/* ----------------------------------------------------------------- */
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(บบ)
%บ-บ AAMSTR Table Selection +บ-บ
%COMMAND ===>_ZCMD
                                                                     ===>_ZAMT
%  /-   B = Browse, E,U = Change, I = Insert (new)
% /
%V +ID  +Tbl Name+    Description
)MODEL
_Z+!Z   !AATBLNM   !AADESC
)INIT
  .ZVARS = '(ACTION AATBLID) '
  .HELP  = NOHELP
)REINIT
)PROC
)END
)))PLIB AADAT
)ATTR
/* ------ Change Log ----------------------------------------------- */
/* --Date-- --by------ -Description of change ---------------------- */
/* 19990719 F.Clarke   New                                           */
/* ----------------------------------------------------------------- */
  % TYPE(TEXT)   INTENS(HIGH)                SKIP(ON)
  @ TYPE(TEXT)   INTENS(HIGH) COLOR(YELLOW)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)       SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(INPUT)  INTENS(HIGH) CAPS(OFF)
  $ TYPE(&IO)    INTENS(HIGH) CAPS(ON)
)BODY EXPAND(บบ)
@บ-บ% AAMSTR Table Update @บ-บ
%COMMAND ===>_ZCMD
                                                             %SCROLL ===>_ZAMT+
+
+     Table ID ===>$Z @         (xx)
+   Table Name ===>_AATBLNM @   (xxxxxxxx)
+  Description ===>!AADESC
+
+   Key Fields ===>_AAKEYS
 
+
+  Name Fields ===>_AANAMES
 
 
 
 
+
+Sort Sequence ===>_AASORT
 
)INIT
  .ZVARS = '(AATBLID)'
)PROC
)END
*/
