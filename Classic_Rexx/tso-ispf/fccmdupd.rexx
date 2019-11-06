/* REXX    FCCMDUPD   Install a command onto the user's personal command
                      table.  Such a command table is designed to be
                      activated by (e.g.) ADDCMDS.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke 20010827
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20011022 fxc error checking
     20020315 fxc delete existing before insert of new
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.20010802      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
"CONTROL ERRORS RETURN"                /* I'll handle my own         */
if rc <> 0 then return                 /* no ISPF environment?       */
 
call A_INIT                            /*                           -*/
                                    if \sw.0error_found then,
call B_DRAIN_QUEUE                     /*                           -*/
                                    if \sw.0error_found then,
call C_TABLE_OPS                       /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ FCCMDUPD                  */
/*
   Initialization
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if queued() <> 4 then do            /* wrong number of lines      */
      zerrsm = "Invalid input data"
      zerrlm = "The queue must have four (4) properly formatted",
               "lines in order for this process to work correctly."
      "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"
      end                              /* queued <> 4                */
 
return                                 /*@ A_INIT                    */
/*
   Obtain ZCTVERB, ZCTTRUNC, ZCTACT, and ZCTDESC from the queue.
   There must be exactly four lines.
.  ----------------------------------------------------------------- */
B_DRAIN_QUEUE:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse pull zctverb
   parse pull zcttrunc
   parse pull zctact
   parse pull zctdesc
 
return                                 /*@ B_DRAIN_QUEUE             */
/*
   DEIMBED and LIBDEF local material.  Obtain ISPTLIB name and
   command-table name.  OPEN, LOAD, and CLOSE the command table.
   Scrubdown environment.
.  ----------------------------------------------------------------- */
C_TABLE_OPS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call CA_PROLOG                      /* DEIMBED and setup         -*/
 
   "ADDPOP ROW(8) COLUMN(5)"
   zwinttl = "Create Shortcut"
   "DISPLAY PANEL(INSTALL)"
   disp_rc = rc
   "REMPOP ALL"
 
   call CL_LOAD_CMD                    /*                           -*/
   call CZ_EPILOG                      /*                           -*/
 
   if sw.0load_err then sw.0error_found = "1"
   else do
      zerrsm = "Shortcut created"
      zerrlm = "A command has been written to your personal command",
            "table as specified.  When activated, you may invoke",
            "this routine from Edit, Browse, or View."
      "SETMSG  MSG(ISRZ002)"
      end
 
return                                 /*@ C_TABLE_OPS               */
/*
   DEIMBED and LIBDEF local material.
.  ----------------------------------------------------------------- */
CA_PROLOG:                             /*@                           */
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
 
return                                 /*@ CA_PROLOG                 */
/*
   All command-table operations.
.  ----------------------------------------------------------------- */
CL_LOAD_CMD:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call CLA_OPEN                       /*                           -*/
                                    if sw.0load_err then return
   call CLI_INSERT_CMD                 /*                           -*/
   call CLZ_CLOSE                      /*                           -*/
 
return                                 /*@ CL_LOAD_CMD               */
/*
   LIBDEF to the command-table and OPEN.  CREATE a new command table
   if necessary.
.  ----------------------------------------------------------------- */
CLA_OPEN:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
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
            if rc > 4 then do
               zerrsm = "Oops"
               zerrlm = "TBCREATE failed for "cmdtbl"CMDS"
               "SETMSG MSG(ISRZ002)"
               sw.0load_err = "1"
               end
            end
         else,
         if rc > 4 then do
            zerrsm = "Oops"
            zerrlm = "TBOPEN failed for "cmdtbl"CMDS"
            "SETMSG MSG(ISRZ002)"
            sw.0load_err = "1"
            end
         "LIBDEF ISPTLIB"
         end
      end
   else sw.0load_err = "1"
 
return                                 /*@ CLA_OPEN                  */
/*
   Purge any existing copies of this command, then insert the queued
   command-table data to the command table.
.  ----------------------------------------------------------------- */
CLI_INSERT_CMD:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   do forever                          /* drop duplicates            */
      "TBTOP"    cmdtbl"CMDS"
      "TBSCAN"   cmdtbl"CMDS  ARGLIST(ZCTVERB) NOREAD"
      if rc > 0 then leave
      "TBDELETE" cmdtbl"CMDS"
   end
   "TBADD"  cmdtbl"CMDS"
 
return                                 /*@ CLI_INSERT_CMD            */
/*
   Write the table to DASD.
.  ----------------------------------------------------------------- */
CLZ_CLOSE:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LIBDEF ISPTABL DATASET ID("tlibds") STACK"
   "TBCLOSE" cmdtbl"CMDS"
   "LIBDEF ISPTABL"
 
return                                 /*@ CLZ_CLOSE                 */
/*
   Scrubdown the environment by removing the LIBDEFs for local ISPF
   material.
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
 
say "  "ex_nam"      Installs a command onto the user's personal command    "
say "                table where it can be activated by (e.g.) ADDCMDS.     "
say "                                                                       "
say "  Syntax:   "ex_nam"  <no parms>                                       "
say "                                                                       "
say "            There must be exactly four (4) lines in the current stack  "
say "            representing ZCTVERB, ZCTTRUNC, ZCTACT, and ZCTDESC.  These"
say "            will be used to populate the inserted row.                 "
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
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                              "
 
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*      REXXSKEL back-end removed for space                          */
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
