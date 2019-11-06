/* REXX    PRINTME ...to the default printer.  Execution of PRINTME is
                   dependent upon having an appropriate verb defined
                   in the user command table.  The 'action' must be:
           SELECT CMD(%PRINTME º&ZDSN º&ZMEM º&ZMEMB º  º&ZPARM)
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke in the Dark Ages
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20010724 fxc REXXSKEL; WIDEHELP; variable dlm; improved HELP;
     20011030 fxc auto-INSTALL;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010524      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
parse value Left(info,1) '4f'x   with   dlm .
 
parse var info (dlm) zdsn   . (dlm) zmem . (dlm) zmemb . ,
               (dlm)  .       (dlm) parms
 
if Word(parms,1) = "?" then call HELP  /* ...and don't come back     */
 
if sw.0install then do
   call ZZ_LOAD_CMDTBL                 /*                           -*/
   if sw.0load_err then nop
   else do
      zerrsm = "Shortcut created"
      zerrlm = "A command has been written to your personal command",
            "table as specified.     When activated, you may invoke",
            "this routine from Edit, Browse, or View."
      "SETMSG     MSG(ISRZ002)"
      end
   call ZZ_EPILOG                      /* release LIBDEFs           -*/
   return                              /* no processing              */
   end                                 /*                            */
call A_INIT                            /*                           -*/
call B_PRINT                           /*                           -*/
exit                                   /*@ PRINTME                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   address TSO
 
   parse var  zdsn  ebdsn  .           /* strip                      */
   parse value zmem zmemb  with  ebmem  .
   if ebmem <> "" then ebdsn = ebdsn"("ebmem")"
 
   info = parms                        /* setup for parsing          */
   sw.0land = SWITCH("LAND")
   sw.0port = SWITCH("PORT")
   if sw.0land + sw.0port <>  1 then,
      parse value "0          1"      with,
                   sw.0land   sw.0port   .
 
   if sw.0land then prtdest = "DEST("prtdestl")"
               else prtdest = "DEST("prtdestp")"
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_PRINT:                               /*@                           */
   address TSO
 
   "PRINTDS  DATASET('"ebdsn"') CLASS("prtcls")" prtdest  info
 
return                                 /*@ B_PRINT                   */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address ISPEXEC
 
   sw.0install  = SWITCH("INSTALL")
   "VGET (PRTCLS PRTDESTP PRTDESTL) PROFILE"
   if Words(prtcls prtdestp prtdestl)  <> 3 |,
      SWITCH("SETUP") then do          /* get new parms              */
      call DEIMBED                     /*                           -*/
      call ZA_PROLOG                   /*                           -*/
      call ZG_GETVALS                  /*                           -*/
      if \sw.0install then,
         call ZZ_EPILOG                /*                           -*/
      "VPUT (PRTCLS PRTDESTP PRTDESTL) PROFILE"
      end                              /* get new parms              */
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
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
   Get PRTCLS and PRTDEST.  Write them to the profile.
.  ----------------------------------------------------------------- */
ZG_GETVALS:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "VGET ZPFCTL"; save_zpf = zpfctl    /* save current setting       */
   zpfctl = "OFF"; "VPUT ZPFCTL"       /* PFSHOW OFF                 */
 
   "ADDPOP ROW(8) COLUMN(5)"
   zwinttl = "Verify Printer Parameters"
   "DISPLAY PANEL(PRTVALS)"
   disp_rc = rc
   "REMPOP ALL"
 
   zpfctl = save_zpf; "VPUT ZPFCTL"    /* restore                    */
 
return                                 /*@ ZG_GETVALS                */
/*
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
   Install a shortcut command on the caller's command table.
.  ----------------------------------------------------------------- */
ZZ_LOAD_CMDTBL:                        /*@                           */
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
 
         zctverb  = "PRINTME"
         zcttrunc = 0
         zctact   = ,
               "SELECT CMD(%PRINTME {&ZDSN {&ZMEM {&ZMEMB { {&ZPARM )"
         zctdesc  = "Print the current dataset"
         "TBADD"  cmdtbl"CMDS"
 
         "LIBDEF ISPTABL DATASET ID("tlibds") STACK"
         "TBCLOSE" cmdtbl"CMDS"
         "LIBDEF ISPTABL"
         end
      end
   else sw.0load_err = "1"
 
return                                 /*@ ZZ_LOAD_CMDTBL            */
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
 
say "  "ex_nam"      prints the dataset currently being browsed or edited.  The"
say "                CLASS and DEST for the printer is stored in the profile.  "
say "                If the appropriate variables are not found in the profile "
say "                you will be prompted to supply them.                      "
say "                                                                          "
say "  Syntax:   "ex_nam"  <PORT | LAND>                                       "
say "                      <other PRINTDS parameters>                          "
say "                  ((  <SETUP>                                             "
say "                      <INSTALL>                                           "
say "                                                                          "
say "            PORT/LAND specifies the required orientation (portrait or     "
say "                      landscape).  If neither/both are specified, the     "
say "                      default is 'PORT'.                                  "
say "                                                                          "
say "            SETUP     requests the setup dialog be started in order to    "
say "                      verify/change the printer parameters.               "
say "                                                                          "
say "            INSTALL   causes a command to be inserted to the user's       "
say "                      command table to enable this routine to be called   "
say "                      from the command line.                              "
say "                                                                          "
say "                      If INSTALL is specified, no other function is done. "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK "
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                                                                          "
say "        NOUPDT:   by-pass all update logic.                               "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the execution in"
say "                  REXX TRACE Mode.                                        "
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
/*  REXXSKEL back-end removed for space   */
/*
)))PLIB PRTVALS
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON) JUST(LEFT) PAD('_')
  @ TYPE(OUTPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT)
  $ TYPE(INPUT)  INTENS(HIGH) CAPS(ON) JUST(LEFT)
)BODY WINDOW(68,5)
+
+      Print CLASS%==>$z+
+       Print DEST%==>$z       + (Portrait)
+       Print DEST%==>$z       + (Landscape)
+
)INIT
  .ZVARS   = '(PRTCLS PRTDESTP PRTDESTL)'
  .HELP    = PRTVALH
  .CURSOR  = PRTCLS
)PROC
  VER (&PRTCLS,NB)
  VER (&PRTDESTP,NB)
  VER (&PRTDESTL,NB)
)END
)))PLIB PRTVALH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(ºº)
%TUTORIAL º-º Verify Printer Parameters º-º TUTORIAL
%Next Selection ===>_ZCMD
 
+
+    Enter the one-character class value associated with your preferred
+    printer.  Usually '6'Ù
+
+    Enter the destination-strings for 'Portrait' orientation and 'Landscape'
+    orientation associated with your preferred printer.  Usually 'U##'Ù
+
)PROC
)END
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
)BODY EXPAND(ºº)
%TUTORIAL º-º COMPILE -- Install Shortcut º-º TUTORIAL %Next Selection
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
