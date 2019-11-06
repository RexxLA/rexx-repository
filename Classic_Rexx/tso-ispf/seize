/* REXX    SEIZE      While looking at a member in Browse or Edit, pop
                      a panel to collect the targeting information,
                      then invoke PDSCOPYD to seize a copy to the
                      target.
.                     SEIZE is most easily executed via a
                      command-table entry of the form:
.                     SELECT CMD(%SEIZE {&zdsn {&zmem {&zmemb {&zparm
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke 20010411
 
     Impact Analysis
.    SYSPROC   PDSCOPYD
.    SYSPROC   TRAPOUT
 
     Modification History
     20010718 fxc block PFSHOW
     20011026 fxc require permission to overwrite existing data;
                  enable auto-install;
     20040817 fxc enable to-version
     20041004 fxc enable PS datasets
     20050114 fxc disable for temporary datasets ;
     20050518 fxc catch "argline is empty";
     20051121 fxc allow user to demand Edit (WORKIT);
 
*/ arg argline
if argline = "" then do                /* no command table?          */
   address TSO
   parse source     .    .        exec_nm   .
   "CLEAR"
   say
   say exec_nm "cannot proceed because there is no data to process."
   say
   say "You may not have a command-table entry with the proper"
   say "configuration, or you may not have loaded your command table."
   say
   say "If you have a command table and it has been loaded, you should"
   say "install" exec_nm "by issuing the following command inside ISPF:"
   say
   say "   ===> tso" exec_nm "(( install "
   say
   say "then immediately reload your command table."
   say
   say exec_nm "can only be exercised via a command-table entry.  If  "
   say "you do not have a command table, you cannot run this routine. "
   "NEWSTACK";pull;"DELSTACK"
   "CLEAR"
   exit
   end
address ISPEXEC                        /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
"CONTROL ERRORS RETURN"                /* I'll handle my own         */
if sw.0install then do                 /* set in LOCAL_PREINIT       */
   call ZZ_LOAD_CMDTBL                 /*                           -*/
   if sw.0load_err then nop
   else do
      zerrsm = "Shortcut created"
      zerrlm = "A command has been written to your personal command",
            "table as specified.     When activated, you may invoke",
            "this routine from Edit, Browse, or View."
      "SETMSG     MSG(ISRZ002)"
      end
   return                              /* no processing              */
   end                                 /* INSTALL specified          */
 
call A_INIT                            /*                           -*/
call B_SETUP_LIBDEFS                   /*                           -*/
call C_ACQUIRE_TEXT                    /*                           -*/
call D_DROP_LIBDEFS                    /*                           -*/
 
if sw.0Redirect then do                /* edit new data              */
   todsn = Strip(todsn,,"'")           /* no quotes                  */
   "EDIT DATASET('"olaydsn"')"
   end
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ SEIZE                     */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value " "               with,
          workit     .
   parse value "0 0 0 0 0 0 0 0" with,
          disp_rc    .
 
   call DEIMBED                        /*                           -*/
   parse var parms "{" dataset . "{" memname "{" memb "{" info
   parse var dataset node1 "."         /* HLQ                        */
   if Length(node1) = 8 & Left(node1,3) = "SYS" then do
      helpmsg = exec_name "doesn't work for temporary datasets. "
      call HELP                        /*                           -*/
      end
   parse value memname memb   with memname .
   if memname = "" then dsorg = "PS"   /* sequential                 */
                   else dsorg = "PO"   /* partitioned                */
   if Words(dataset memname) <> 2 then typ = "INPUT"
                                  else typ = "OUTPUT"
 
   if info = "?" then call HELP        /* and don't come back...    -*/
   if info <> "" then sw.0Redirect = 1 /* go to new data             */
   newver = KEYWD("TO")                /* TO 411, maybe              */
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_SETUP_LIBDEFS:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ B_SETUP_LIBDEFS           */
/*
.  ----------------------------------------------------------------- */
C_ACQUIRE_TEXT:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   tomem   = memname                   /* seed                       */
   if newver <> "" then do
      tomem   = Reverse(,
                  Overlay(,
                    Reverse(newver),Reverse(tomem),
                         ) ,
                       )
      end
 
   if dsorg = "PS" then fqdsn = dataset
                   else fqdsn = dataset"("memname")"
   if dataset <> "" then,
      parse value "'"dataset"'" "Copy" fqdsn             with,
                     dataset     zwinttl    1   todsn   .
   else,
      zwinttl = "Copy anything"
 
   if newver = "" then call CG_GET_TARGET      /*                    */
   if disp_rc > 0 then return
 
   if memname = "" then do
      ldrc   = Listdsi(dataset "directory norecall")
      if sysdsorg = "PS" then frommbr = ""
      else do
         zerrsm = "Input member not specified"
         zerrlm = exec_name "("BRANCH("ID")")",
                  "This process requires an input member if the input",
                  "dataset is PO."
         "SETMSG  MSG(ISRZ002)"
         sw.0error_found = "1"; return
         end                           /* PO and no member           */
      end                              /* no input member            */
   else frommbr = "FROMMBR" memname
 
   confirm = "N"                       /* init                       */
   call CK_VERIFY_TARGET               /*                           -*/
   if confirm = "N" then noupdt = "1"  /* do not overlay             */
 
   if noupdt then do
      zerrsm = "PDSCOPYD bypassed."
      zerrlm = "PDSCOPYD bypassed because NOUPDT was specified."
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      return
      end                              /* noupdt                     */
 
   call CP_PDSCOPY                     /* transfer data              */
   address ISPEXEC "SETMSG MSG(ISRZ002)"
 
return                                 /*@ C_ACQUIRE_TEXT            */
/*
   NEWVER was not specified; prompt.
.  ----------------------------------------------------------------- */
CG_GET_TARGET:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "VGET ZPFCTL"; save_zpf = zpfctl    /* save current setting       */
      zpfctl = "OFF"; "VPUT ZPFCTL"    /* PFSHOW OFF                 */
   "ADDPOP ROW(8) COLUMN(5)"
   "DISPLAY PANEL(FROMTO)"
   disp_rc = rc
   "REMPOP ALL"
      zpfctl = save_zpf; "VPUT ZPFCTL" /* restore                    */
 
   if workit = "Y" then,
      sw.0Redirect = 1
 
return                                 /*@ CG_GET_TARGET             */
/*
.  ----------------------------------------------------------------- */
CK_VERIFY_TARGET:                      /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if Left(todsn,1) = "'" then,
      olaydsn = Strip(todsn,,"'")      /* unquoted                   */
   else olaydsn = Userid()"."todsn     /* fully-qualified            */
                                       /*                            */
   if dsorg = "PS" then nop
                   else olaydsn = olaydsn"("tomem")"
   if Sysdsn("'"olaydsn"'") = "OK" then,
      do
      "VGET ZPFCTL"; save_zpf = zpfctl /* save current setting       */
         zpfctl = "OFF"; "VPUT ZPFCTL" /* PFSHOW OFF                 */
      "ADDPOP ROW(8) COLUMN(5)"
      "DISPLAY PANEL(OLCONFRM)"
      disp_rc = rc
      "REMPOP ALL"
         zpfctl = save_zpf; "VPUT ZPFCTL" /* restore                 */
      end
   else confirm = "Y"                  /* OK to copy                 */
 
return                                 /*@ CK_VERIFY_TARGET          */
/*
.  ----------------------------------------------------------------- */
CP_PDSCOPY:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   if frommbr = "" then tomen = ""
                   else tomem = "TOMBR" tomem
   "PDSCOPYD  FROMDS" dataset   frommbr,
              " TODS" todsn     tomem
   if rc > 0 then do
      zerrsm = "PDSCOPYD error"
      zerrlm = "PDSCOPYD did not copy the data"
      sw.0Redirect = 0
      end
   else do
      zerrsm = "Copied"
      zerrlm = memname "in" dataset "was copied to",
               tomem "in" "'"olaydsn"'"
      end
 
return                                 /*@ CP_PDSCOPY                */
/*
.  ----------------------------------------------------------------- */
D_DROP_LIBDEFS:                        /*@                           */
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
 
return                                 /*@ D_DROP_LIBDEFS            */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   sw.0Install  = SWITCH("INSTALL")
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
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
 
         zctverb  = "SEIZE"
         zcttrunc = 0
         zctact   = ,
               "SELECT CMD(%SEIZE {&ZDSN {&ZMEM {&ZMEMB {&ZPARM )"
         zctdesc  = "Copy data"
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
say "                                                                          "
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      simplifies the copying of the existing dataset.  It is    "
say "                designed to be invoked from a command-table entry of the  "
say "                form:                                                     "
say "                   SELECT CMD(%SEIZE {&zdsn {&zmem {&zmemb {&zparm        "
say "                                                                          "
say "  Syntax:   "ex_nam"  <tag>                                               "
say "                      <TO mbrsuff>                                        "
say "                  ((  <INSTALL>                                           "
say "                                                                          "
say "            tag       is any non-blank string.  If any parameter is passed"
say "                      to "exec_name" you will be placed into EDIT on the  "
say "                      resultant data.  Specifying 'TO' qualifies as a tag."
say "                                                                          "
say "            mbrsuff   specifies a 'tail' for the current member.  If      "
say "                      mbrsuff is specified, it will be overlayed on the   "
say "                      rightmost positions of the current membername and   "
say "                      you will be placed into EDIT on that new member     "
say "                      after it has been created.                          "
say "                                                                          "
say "                      If mbrsuff is not specified, you will be prompted   "
say "                      with a pop-up panel to specify a new membername.    "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "                                                                          "
say "            INSTALL   causes a command of the appropriate form to be      "
say "                      inserted to the user's personal command table.      "
say "                                                                          "
say "                      When INSTALL has been requested no other processing "
say "                      takes place regardless of any parameters passed.    "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
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
/* ------------- REXXSKEL back-end removed for space --------------- */
/*
)))PLIB FROMTO
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON) JUST(LEFT) PAD('_')
  @ TYPE(&TYP)   INTENS(HIGH) CAPS(ON) JUST(LEFT)
  $ TYPE(INPUT)  INTENS(HIGH) CAPS(ON) JUST(LEFT)
)BODY WINDOW(62,7)
+From DSN%==>@DATASET                                       +
+     Mem%==>@MEMNAME +
+
+To   DSN%==>$TODSN                                         +
+     Mem%==>$TOMEM   +
+
+  Edit ?%==>$z+     (Y or N)
)INIT
  .HELP    = FROMTOH
  .ZVARS = '(WORKIT)'
  .CURSOR  = TODSN
)PROC
 VER (&TODSN,NB,DSNAME)
 IF  (&DSORG = 'PS')
     VER (&TOMEM,NAME)
 ELSE
     VER (&TOMEM,NB,NAME)
)END
)))PLIB FROMTOH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ)
%TUTORIAL บ-บ SEIZE - Specify Target บ-บ TUTORIAL %Next Selection
===>_ZCMD
 
+
     The FROMDSN and FROMMBR have been determined by your current
     location.  Please specify the target dataset and member.
 
     If you want to be placed into EDIT on the new text, indicate
     "Y" for "Edit ?".
)PROC
)END
)))PLIB OLCONFRM
)ATTR
  % TYPE(TEXT) INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT) INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT) PAD('_') SKIP(OFF)
  @ TYPE(OUTPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT)
  $ TYPE(INPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT)
)BODY WINDOW(45,10)
+
+
+Mem ==>@TOMEM   +
+Dsn ==>@OLAYDSN                            +
+
+Member already exists in Dataset
+
+Overlay? ==> _Z+ (Yes/No)
+
+
)INIT
  .ZVARS = '(CONFIRM)'
  .CURSOR = CONFIRM
  &CONFIRM = 'N'
)PROC
 VER (&CONFIRM,NB,LIST,Y,N)
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
