/* REXX    COMPILE    Setup and submit JCL to compile and link the
                      current member.  For optimum operation there
                      should be a command in the command table whose
                      action is
               SELECT CMD(%COMPILE {&ZDSN {&ZMEM {&ZMEMB {&ZPARM )
                      This allows you to issue the command "COMPILE"
                      while in edit causing a background job to be
                      submitted to compile/link the instant source.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke 20010621
 
     Impact Analysis
.    SYSPROC   FCCMDUPD
.    SYSPROC   POST
.    SYSPROC   TRAPOUT
.    ISPSLIB   COMPILE     (embedded)
.    ISPPLIB   FROMTO      (embedded)
.    ISPPLIB   FROMTOH     (embedded)
.    ISPPLIB   INSTALL     (embedded)
.    ISPPLIB   INSTALH     (embedded)
 
     Modification History
     20010716 fxc LINK only if loadlib specified; save listing only if
                  listing dataset specified; INSTALL option;
     20010718 fxc block PFSHOW
     20011005 fxc add switch on panel to bypass LINK
     20011127 fxc GOLINK is OFF if LODDS is blank
     20020124 fxc LE-CICS enabled
     20020129 fxc Oops....   needs to be CICS.TS.ACNN....
     20020204 fxc 4 separate blocks for LKED/SYSLIB; too confusing any
                  other way; all DLINKLIB become SLINKLIB
     20020416 fxc rig for LE-only; use FCCMDUPD for command
                  installation; drop LECOMP alias;
     20020430 fxc POST; use NTIN.TS.D822.LIB.EXEC for COMBINE
 
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
call B_TAILOR                          /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ COMPILE                   */
/*
   Initialization.  Setup JOB1L as the first job statement.
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   parse var parms "{" srcds . "{" src "{" memb "{" info
   if SWITCH("?") then call HELP       /* a lone q-mark in info      */
   parse value src memb       with src .
 
   lelink = 1     /* exec_name = "LECOMP" */
 
   parse var src 3 tag 5
   "VGET JOB1L ASIS"                   /* jobcard                    */
   if job1l = "" then do
      "VGET JOB1 ASIS"                 /* get standard jobcard       */
      if rc > 0 then do                /* not found?                 */
         address TSO "JOBCARDS"        /* setup initial set          */
         "VGET JOB1 ASIS"
         end                           /* JOB1 not found             */
      job1l = job1
      end                              /* JOB1H not found            */
   parse var job1l w1 rest             /* //jobname ...              */
   job1l = "//"Userid()tag rest        /* reconstruct                */
   "VPUT JOB1L PROFILE"                /* save it                    */
 
return                                 /*@ A_INIT                    */
/*
   Customize the JCL
.  ----------------------------------------------------------------- */
B_TAILOR:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BA_SETUP_LIBDEFS               /*                           -*/
   call BJ_BUILD_JCL                   /*                           -*/
   call BZ_DROP_LIBDEFS                /*                           -*/
 
return                                 /*@ B_TAILOR                  */
/*
   Deimbed and attach the ISPF material
.  ----------------------------------------------------------------- */
BA_SETUP_LIBDEFS:                      /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call DEIMBED                        /* extract ISPF elements     -*/
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd with dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ BA_SETUP_LIBDEFS          */
/*
   File-tailor the skeleton to compile and link the source and store
   the listings in a library.  Submit the JCL.
.  ----------------------------------------------------------------- */
BJ_BUILD_JCL:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BJA_OUTPUT_WHERE               /* what load and list locns? -*/
   if sw.error_found then return       /* Oops...                    */
   prc    = Sysdsn("'"srcds"(PROCESS)'") = "OK"
   prcc   = Sysdsn("'"srcds"(PROCICS)'") = "OK"
 
   "FTOPEN TEMP"
   "FTINCL COMPILE"                    /* customize JCL              */
   if rc > 0 then do
      "SETMSG  MSG(ISRZ002)"
      sw.error_found = "1"
      end                              /* FTINCL error               */
   "FTCLOSE"
   if rc > 0 then do
      "SETMSG  MSG(ISRZ002)"
      sw.error_found = "1"
      end                              /* FTCLOSE error              */
 
   if sw.error_found then return       /* Oops...                    */
 
   "VGET (ZTEMPF ZTEMPN)"
   if modify then do
      "LMINIT DATAID(DDNID) DDNAME("ztempn")"
      zerrsm = "Submit-it-yourself"
      zerrlm = "This JCL will -NOT- be automatically submitted when",
               "EDIT completes.  If you want the JOB to run",
               "you must issue the SUBMIT command before leaving",
               "this edit session."
      "SETMSG  MSG(ISRZ002)"
      "EDIT DATAID("ddnid")"
      end
   else,
      address TSO "SUBMIT '"ZTEMPF"'"
 
return                                 /*@ BJ_BUILD_JCL              */
/*
   Where to put the load module?  Where to put the listings?
.  ----------------------------------------------------------------- */
BJA_OUTPUT_WHERE:                      /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "VGET (LODDS,LISTDS) PROFILE"
   "VGET ZPFCTL"; save_zpf = zpfctl    /* save current setting       */
   do forever
      if listds <> "" then list = src                       /* seed */
                      else list = ""
      if lodds  <> "" then lmod = src                       /* seed */
                      else lmod = ""
      zpfctl = "OFF"; "VPUT ZPFCTL"    /* PFSHOW OFF                 */
      "ADDPOP ROW(8) COLUMN(5)"
      zwinttl = "Compile" srcds"("src")"
      "DISPLAY PANEL(FROMTO)"
      disp_rc = rc
      "REMPOP ALL"
      zpfctl = save_zpf; "VPUT ZPFCTL" /* restore                    */
 
      if disp_rc > 0 then do
         sw.error_found = "1"          /* Halt                       */
         leave
         end
 
      golink = ok2link = "Y"
      if golink then,
      if lodds <> "" then do
         if Sysdsn("'"lodds"'") <> "OK" then do
            zerrsm = "LOADLIB?"
            zerrlm = "Named library not available"
            "SETMSG  MSG(ISRZ002)"
            iterate
            end
         if lmod = "" then golink = "0"
         end                           /* lodds                      */
      else golink = "0"                /* LODDS is blank             */
 
      saveprt = "0"
      if listds <> "" then do
         if Sysdsn("'"listds"'") <> "OK" then do
            zerrsm = "LISTING?"
            zerrlm = "Named library not available"
            "SETMSG  MSG(ISRZ002)"
            iterate
            end
         $RC = Listdsi("'"listds"' DIRECTORY")
         if sysdsorg = "PO" then,
            if list = "" then do
               zerrsm = "What List mbr?"
               zerrlm = "Specify a member name for the listing."
               "SETMSG MSG(ISRZ002)"
               iterate
               end ; else nop
         else list = ""                /* not PO, zap membername     */
         saveprt = "1"
         end                           /* listds                     */
 
      leave
   end                                 /* forever                    */
 
return                                 /*@ BJA_OUTPUT_WHERE          */
/*
.  ----------------------------------------------------------------- */
BZ_DROP_LIBDEFS:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd with dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd
      address TSO "FREE  FI("$ddn")"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ BZ_DROP_LIBDEFS           */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   if SWITCH("INSTALL") then do
      queue "COMPILE"
      queue  0
      queue "SELECT CMD(%COMPILE {&ZDSN {&ZMEM {&ZMEMB {&ZPARM )"
      queue "Compile a PLI source module"
      "FCCMDUPD"
      exit
      end                              /* INSTALL                    */
   modify       = SWITCH("EDIT")
 
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
 
say "  "ex_nam"      submits a background job to compile and link the current  "
say "                source program.  You should be in Edit, Browse, or View on"
say "                the source to be compiled.                                "
say "                                                                          "
say "  Syntax:   "ex_nam"  <no parms>                                          "
say "                 ((   <EDIT>                                              "
say "                      <INSTALL>                                           "
say "                                                                          "
say "            EDIT      causes the composed JCL to be presented in EDIT for "
say "                      last-minute changes.                                "
say "                                                                          "
say "            INSTALL   writes a shortcut command for this routine onto the "
say "                      user's command table.                               "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK "
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
/*      REXXSKEL back-end removed for space                          */
/*
)))SLIB COMPILE
&JOB1L
&JOB2
&JOB3
&JOB4
//* ------------------------------------------------------------     */
//ORIGIN   EXEC PGM=IEFBR14
//SOURCE    DD DISP=SHR,DSN=&SRCDS(&SRC)
)SET LSTEP = ORIGIN
)SET LDDN  = SOURCE
)SEL    &SWCICS = Y
//* ------------------------------------------------------------     */
//CICSPRE  EXEC PGM=DFHEPP1$,REGION=4096K
//STEPLIB   DD DISP=SHR,DSN=CICS.TS.SDFHLOAD
//SYSIN     DD DISP=SHR,
)SEL    &PRCC = 1
//             DSN=&SRCDS(PROCICS)
//          DD DISP=SHR,
)ENDSEL &PRCC = 1
//             DSN=*.&LSTEP..&LDDN
//SYSPRINT  DD SYSOUT=*
//SYSPUNCH  DD UNIT=VIO,SPACE=(CYL,(5,1)),DISP=(,PASS),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=0)
)SET LSTEP = CICSPRE
)SET LDDN  = SYSPUNCH
)ENDSEL &SWCICS = Y
//* ------------------------------------------------------------     */
//PLI      EXEC PGM=IEL0AA,
//             PARM='NSEQ,OBJECT,NODECK',REGION=4096K
//SYSIN     DD DISP=SHR,
)SEL    &PRC = 1
//             DSN=&SRCDS(PROCESS)
//          DD DISP=SHR,
)ENDSEL &PRC = 1
//             DSN=*.&LSTEP..&LDDN
//SYSLIB    DD DISP=SHR,DSN=&SRCDS
)SEL    &SWCICS = Y
//          DD DISP=SHR,DSN=CICS.TS.SDFHPL1
//          DD DISP=SHR,DSN=CICS.TS.SDFHMAC
//          DD DISP=SHR,DSN=CICS.TS.SDFHSAMP
)ENDSEL &SWCICS = Y
//          DD DISP=SHR,DSN=NTIN.TS.PLILIB
//          DD DISP=SHR,DSN=NTIN.AT.PLILIB
)SEL    &SWCICS = Y
//          DD DISP=SHR,DSN=NTIN.TS.MAPLIB
)ENDSEL &SWCICS = Y
//          DD DISP=SHR,DSN=ACNN.PR.PLILIB
//SYSLIN    DD DISP=(MOD,PASS),UNIT=VIO,
//             SPACE=(TRK,(200,50))
//SYSPRINT  DD UNIT=VIO,DISP=(NEW,PASS),SPACE=(CYL,(1,5))
//SYSUT1    DD UNIT=VIO,
//             SPACE=(1024,(200,50),,CONTIG,ROUND),DCB=BLKSIZE=1024
)SEL    &GOLINK = 1
//*                                                                  */
//            IF (PLI.RC << 8) THEN
//* LELINK = &LELINK    SWCICS = &SWCICS                             */
//* ------------------------------------------------------------     */
//LKED     EXEC PGM=IEWL,REGION=4096K,
//             PARM='XREF,LIST,COMPAT=LKED,STORENX'
)SEL    &LELINK = 1
//STEPLIB   DD DISP=SHR,DSN=CEE.SCEELPA
)ENDSEL &LELINK = 1
//*                                                                  */
)SEL    &SWCICS = Y
)SEL    &LELINK = 1
//SYSLIB    DD DISP=SHR,DSN=CEE.SCEELKED
//          DD DISP=SHR,DSN=CICS.TS.SDFHLOAD
//          DD DISP=SHR,DSN=CICS.TS.ACNN.PR.SLINKLIB.LE
//          DD DISP=SHR,DSN=NTIN.TS.CLINKLIB
//          DD DISP=SHR,DSN=SYS1.PLI.ABEND
)ENDSEL &LELINK = 1
)SEL    &LELINK = 0
//SYSLIB    DD DISP=SHR,DSN=CICS41.SDFHLOAD
//          DD DISP=SHR,DSN=NTIN.TS.SLINKLIB
//          DD DISP=SHR,DSN=ACNN.PR.SLINKLIB
)ENDSEL &LELINK = 0
)ENDSEL &SWCICS = Y
)SEL    &SWCICS = N
)SEL    &LELINK = 1
//SYSLIB    DD DISP=SHR,DSN=CEE.SCEELKED
//          DD DISP=SHR,DSN=CICS.TS.ACNN.PR.SLINKLIB.LE
//          DD DISP=SHR,DSN=SYS1.PLI.ABEND
//          DD DISP=SHR,DSN=NTIN.TS.SLINKLIB
//          DD DISP=SHR,DSN=NTIN.AT.SLINKLIB
//          DD DISP=SHR,DSN=ACNN.PR.SLINKLIB
)ENDSEL &LELINK = 1
)SEL    &LELINK = 0
//SYSLIB    DD DISP=SHR,
//             DSN=NTIN.TS.SLINKLIB
//          DD DISP=SHR,DSN=NTIN.AT.SLINKLIB
//          DD DISP=SHR,DSN=ACNN.PR.SLINKLIB
)ENDSEL &LELINK = 0
)ENDSEL &SWCICS = N
//*                                                                  */
//SYSLIN    DD DISP=SHR,
)SEL    &SWCICS = Y
)SEL    &LELINK = 1
//             DSN=CEE.SCEESAMP(IBMWRLKC)
)ENDSEL &LELINK = 1
)SEL    &LELINK = 0
//             DSN=CICS41.SDFHPL1(DFHEILIP)
)ENDSEL &LELINK = 0
//          DD DISP=SHR,
)ENDSEL &SWCICS = Y
//             DSN=*.PLI.SYSLIN
//          DD DDNAME=SYSIN
//SYSLMOD   DD DISP=SHR,DSN=&LODDS(&LMOD)
//SYSPRINT  DD UNIT=VIO,DISP=(NEW,PASS),SPACE=(CYL,(1,5))
//SYSUT1    DD DISP=(NEW,PASS),UNIT=VIO,
//             SPACE=(1024,(200,50),,CONTIG,ROUND),DCB=BLKSIZE=1024
)SEL    &ALIAS EQ &Z
//SYSIN     DD DUMMY
)ENDSEL &ALIAS EQ &Z
)SEL    &ALIAS NE &Z
//SYSIN     DD *
    ALIAS  &ALIAS
    NAME   &LMOD(R)
)ENDSEL &ALIAS NE &Z
//*                                                                  */
//            ENDIF
//*                                                                  */
)ENDSEL &GOLINK = 1
//* ------------------------------------------------------------     */
//PRINT1   EXEC PGM=IEBGENER
//SYSUT1    DD DISP=SHR,DSN=*.PLI.SYSPRINT
//SYSUT2    DD SYSOUT=*
//SYSIN     DD DUMMY
//SYSPRINT  DD DUMMY
//*                                                                  */
//* ----------                                                       */
//            IF (PLI.RC << 8) THEN
//*                                                                  */
)SEL    &GOLINK = 1
//PRINT2   EXEC PGM=IEBGENER
//SYSUT1    DD DISP=SHR,DSN=*.LKED.SYSPRINT
//SYSUT2    DD SYSOUT=*
//SYSIN     DD DUMMY
//SYSPRINT  DD DUMMY
//*                                                                  */
)ENDSEL &GOLINK = 1
)SEL    &SAVEPRT = 1
//* ----------                                                       */
//*                                                                  */
//COMBINE  EXEC PGM=IKJEFT01,DYNAMNBR=300,PARM='COMBINE (( RACE R'
//SYSTSIN   DD DUMMY
//SYSTSPRT  DD SYSOUT=*
//SYSPROC   DD DISP=SHR,DSN=NTIN.TS.D822.LIB.EXEC
//$COMP     DD DISP=SHR,DSN=*.PLI.SYSPRINT
)SEL    &GOLINK = 0
//$LINK     DD DUMMY
)ENDSEL &GOLINK = 0
)SEL    &GOLINK = 1
//$LINK     DD DISP=SHR,DSN=*.LKED.SYSPRINT
)ENDSEL &GOLINK = 1
//$PRINT    DD DISP=SHR,DSN=&LISTDS(&LIST)
//*                                                                  */
)ENDSEL &SAVEPRT = 1
//* ----------                                                       */
//            ELSE
)SEL    &SAVEPRT = 1
//*                                                                  */
//PLIFAIL  EXEC PGM=IKJEFT01,
//         DYNAMNBR=300,PARM='COMBINE (( RACE R'
//SYSTSIN   DD DUMMY
//SYSTSPRT  DD SYSOUT=*
//SYSPROC   DD DISP=SHR,DSN=*.COMBINE.SYSPROC
//$COMP     DD DISP=SHR,DSN=*.PLI.SYSPRINT
//$LINK     DD DUMMY
//$PRINT    DD DISP=SHR,DSN=*.COMBINE.$PRINT
//*                                                                  */
)ENDSEL &SAVEPRT = 1
//            ENDIF
//* ----------                                                       */
)))PLIB FROMTO
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)  JUST(LEFT) PAD('_')
  @ TYPE(OUTPUT) INTENS(HIGH) CAPS(OFF) JUST(LEFT)
  $ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)  JUST(LEFT)
)BODY WINDOW(68,10)
+ Source DSN%==>@srcds                                         +
+        Mem%==>@src     +    CICS? ==>$Z+ (Y or N)
                @namemsg
+       Link%==>$z+
+   Load DSN%==>$lodds                                         +
+        Mem%==>$lmod    +     Set ALIAS to%==>$alias   +
+
+Listing DSN%==>$listds                                        +
+        Mem%==>$list    +
)INIT
  .HELP    = FROMTOH
  .CURSOR  = LODDS
  .ZVARS = '(SWCICS OK2LINK)'
  VGET (LODDS,LISTDS,SWCICS) PROFILE
  &OK2LINK = 'Y'                       /*                            */
)PROC
  VER (&LODDS,DSNAME)
  VER (&LMOD,NAME)
  VER (&LISTDS,DSNAME)
  VER (&LIST,NAME)
  &OK2LINK = TRANS(&OK2LINK
               N,N
               *,Y )
  &SWCICS = TRANS(&SWCICS
               Y,Y
               *,N )
  VPUT (LODDS,LISTDS,SWCICS) PROFILE
)END
)))PLIB FROMTOH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ)
%TUTORIAL บ-บ COMPILE -- Specify Target บ-บ TUTORIAL %Next Selection
===>_ZCMD
 
+
     The FROMDSN and FROMMBR have been determined by your current location.
 
     Please specify a datasetname and member for the load module.  If you
     do not want to Linkedit, set "Link" to N.
 
     Please specify a datasetname and member for the output listing dataset.
     If left blank, the listing will not be saved.
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
