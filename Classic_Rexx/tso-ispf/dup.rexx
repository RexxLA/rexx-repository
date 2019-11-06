/* REXX    DUP        Copy a PDS or a Sequential file.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
                      DUP is designed to work in ISPF 3.4 or from the
                      command-line as a tool that will copy one dataset
                      to another dataset.  DUP will present a window to
                      display and collect allocation information used to
                      create the new dataset.

           Written by Chris Lewis

     Impact Analysis
.    SYSPROC   TRAPOUT
.    ISPPLIB   DUP

     Modification History
     19950828 ctl Do not exit if an allocate
     19951204 ctl Upgrade REXXSKEL, previous version 950620.  Fixed
                  bug with RECFM
     19970217 ctl Remove obstacles to allow copy of FBA datasets.
     19970313 fxc allow allocation of PS from PO and v.v.;
     19970402 fxc fix "blank dballoc" bug
     19970605 fxc upgrade from v.951129 to v.970211; halt when todsn
                  pre-exists; reorg code; DECOMM
     19981117 fxc upgrade from v.970211 to v.19980225;
                  RXSKLY2K;
     19990811 fxc fixed BLOCK bug
     19991020 fxc new DEIMBED; upgraded HELP;
                  upgrade REXXSKEL from v.19980225 to v.19991006;
     19991206 fxc upgrade from v.19991006 to v.19991109;

*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.19991109      */
arg parms "((" opts

signal on syntax
signal on novalue

call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */

call A_INIT                            /*                           -*/
call B_LISTDSI                         /*                           -*/
call C_DISPLAY                         /*                           -*/

exit                                   /*@ DUP                       */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO

   call AA_KEYWDS                      /*                           -*/
   pname = exec_name

   parse var info fromdsn info

   if fromdsn = "" then,
      helpmsg = helpmsg "Dataset is Required."

   if Sysdsn(fromdsn) ^= "OK" then
      helpmsg = helpmsg "Dataset("fromdsn") does not exist."

   if helpmsg ^= "" then call HELP

   if sw.0ID then,
        todsn = overlay(userid(),fromdsn,2,7)
   else todsn = fromdsn

return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO

   sw.0ID = SWITCH("ID")

return                                 /*@ AA_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
B_LISTDSI:                             /*@                           */
   if branch then call BRANCH
   address TSP

   rc = listdsi(fromdsn "DIRECTORY")

   alloc    = sysalloc
   used     = sysused
   mems     = sysmembers
   unit     = sysunits
   dsorg    = sysdsorg
   recfm    = sysrecfm
   lrecl    = syslrecl
   blksize  = sysblksize
   prim     = sysprimary
   secd     = sysseconds
   extents  = sysextents
   dballoc  = sysadirblk
   dbused   = sysudirblk
   created  = syscreate

   zwinttl = exec_name "Facility"

return                                 /*@ B_LISTDSI                 */
/*
.  ----------------------------------------------------------------- */
C_DISPLAY:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   call DEIMBED                        /* deimbed panel "DUP"       -*/
   $ddn  = $ddn.PLIB                   /* get real DDName            */
   "LIBDEF  ISPPLIB  LIBRARY  ID("$ddn") STACK"
   do forever
      "ADDPOP ROW(6) COLUMN(6)"
      "DISPLAY PANEL("pname")"
      save_rc = rc
      "REMPOP ALL"

      if save_rc > 0 then leave

      rc = CA_ALLOC()                  /*                           -*/

      if rc ^= 0 | sel = "A" then iterate
      if dsorg <> alcdsorg then iterate /* can't copy...             */

      rc = CB_COPY()                   /*                           -*/

      if rc = 0 then do
         zerrsm = "Copy Completed"
         zerrlm = "Copy("rc") from DSN("fromdsn") to DSN("todsn")."
         "SETMSG MSG(ISRZ002)"
         end
      else do
         zerrsm = "Copy Error"
         zerrlm = "Copy failed with RC="rc
         "SETMSG MSG(ISRZ002)"
         end

   end                                 /* forever                    */
   "LIBDEF  ISPPLIB"

return                                 /*@ C_DISPLAY                 */
/*
.  ----------------------------------------------------------------- */
CA_ALLOC:                              /*@                           */
   if branch then call BRANCH
   address TSO

   parse var recfm rec 2 fm 3 bk .
   trec  = space(rec fm bk,1)
   parse value dballoc "0" with dballoc .  /* ensure a value         */

   dsorg.   = ""
   dsorg.PO = "DIR("dballoc")"
   if dballoc = 0 then alcdsorg = "PS"
                  else alcdsorg = "PO"

   if unit = "BLOCK" then alcunit = "BLOCK("blksize")"
                     else alcunit = unit
   alloc.0 = "NEW CATALOG UNIT(SYSDA)" alcunit "SPACE("prim","secd")",
             "RECFM("trec") LRECL("lrecl") BLKSIZE("blksize")",
             "DSORG("alcdsorg")" dsorg.alcdsorg
   alloc.1 = "SHR"

   stat = Sysdsn(todsn)  = "OK"
   if stat then do
      if todsn = fromdsn then slug = "is the same as the FROM-dataset."
                         else slug = "already exists."
      zerrsm = "TO dataset ?"
      zerrlm = "The TO-dataset specified" slug
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      return(8)
      end

   msgstat = Msg("OFF")
   "ALLOC FI(SYSUT2) DA("todsn") REUSE" alloc.stat
   save_rc = rc
   if rc > 0 then do
      zerrsm = "ALLOC Error"
      zerrlm = "Alloc Failed RC("rc")  DSN("todsn")"
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      end
   else
   if sel = "A" then do
      zerrsm = "Alloc Completed"
      zerrlm = "Alloc finished RC("rc").     DSN("todsn")"
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      end

   if sel = "A" then "FREE FI(SYSUT2)"

   rc = Msg(msgstat)

return(save_rc)                        /*@    CA_ALLOC               */
/*
.  ----------------------------------------------------------------- */
CB_COPY:                               /*@                           */
   if branch then call BRANCH
   address TSO

   "ALLOC F(SYSUT1) DA("fromdsn") SHR REUSE"

   "ALLOC F(SYSPRINT) DUMMY REU"

   if dsorg = "PO" then copy_rc = PDS_IEBCOPY()            /*       -*/
   else                 copy_rc = SEQ_IEBGENER()           /*       -*/

   "FREE F(SYSIN SYSPRINT SYSUT1 SYSUT2)"

return(copy_rc)                        /*@    CB_COPY                */
/*
.  ----------------------------------------------------------------- */
PDS_IEBCOPY:                           /*@                           */
   if branch then call BRANCH
   address tso

   "ALLOC F(SYSIN) NEW TRACKS SPACE(1) UNIT(SYSDA) LRECL(80)",
                  "BLKSIZE(800) RECFM(F B) REU"

   "NEWSTACK"

   queue "CTLCOPY1   COPY INDD=SYSUT1,OUTDD=SYSUT2"
   "EXECIO" queued() "DISKW SYSIN (FINIS"

   "DELSTACK"

   "TSOEXEC IEBCOPY"
   copy_rc = rc

return(copy_rc)                        /*@    PDS_IEBCOPY            */
/*
.  ----------------------------------------------------------------- */
SEQ_IEBGENER:                          /*@                           */
   if branch then call BRANCH
   address tso

   "ALLOC FI(SYSIN) DUMMY REU"

   address LINKMVS "IEBGENER"
   copy_rc = rc

return(copy_rc)                        /*@    SEQ_IEBGENER           */
/*
   Parse out the embedded components at the back of the source code.

   The components are enclosed in a comment whose start and end are on
   individual lines for easier recognition.

   Each component is identified by a triple-close-paren ")))" in
   column 1 followed by a DDName and a membername.  The text of the
   component begins on the next line.

   There are no restrictions on the DDName, but it is probably a good
   idea to pick a name which relates to its use so that mainline
   processing can, for example, determine what sort of LIBDEF to do.
   Note also that a 3-digit random number will be generated for each
   DDName to guard against the possibility that processing may be
   interleaved or recursive.  It is up to the programmer to add the
   code to properly LIBDEF each component type.
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
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO


return                                 /*@ LOCAL_PREINIT             */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"      DUP is designed to work in ISPF 3.4 or from the   "
say "                command-line as a tool that will copy one dataset "
say "                to another dataset.  DUP will present a window to "
say "                display and collect allocation information used to"
say "                create the new dataset.                           "
say "                                                                  "
say "  Syntax:   "ex_nam"  <from-dsn>                        (Required)"
say "                      <ID>                              (Optional)"
say "                                                                  "
say "            <from-dsn>   identifies the base dataset which is to  "
say "                      serve as a model for the DUP operation.     "
say "                      The datasetname specified must exist.       "
say "                                                                  "
say "            <ID>      if specified indicates that the caller's    "
say "                      TSO UserID is to replace the high-level     "
say "                      qualifier on the output dataset.            "
pull
"CLEAR"
say "   Debugging tools provided include:                              "
say "                                                                  "
say "        MONITOR:  displays key information throughout processing. "
say "                  Displays most paragraph names upon entry.       "
say "                                                                  "
say "        NOUPDT:   by-pass all update logic.                       "
say "                                                                  "
say "        BRANCH:   show all paragraph entries.                     "
say "                                                                  "
say "        TRACE tv: will use value following TRACE to place the     "
say "                  execution in REXX TRACE Mode.                   "
say "                                                                  "
say "                                                                  "
say "   Debugging tools can be accessed in the following manner:       "
say "                                                                  "
say "        TSO "ex_nam"  parameters     ((  debug-options            "
say "                                                                  "
say "   For example:                                                   "
say "                                                                  "
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                         "
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
)))PLIB DUP
)ATTR DEFAULT(%+_)
% TYPE(TEXT) INTENS(HIGH) SKIP(ON)
+ TYPE(TEXT) INTENS(LOW) SKIP(ON)
$ TYPE(INPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT)
# TYPE(OUTPUT) INTENS(LOW) CAPS(ON) JUST(LEFT)
@ TYPE(OUTPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT)
_ TYPE(INPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT) PAD('_')
)BODY WINDOW(62,17) EXPAND(||)
%COMMAND ===> $ZCMD                                         +
+
+From DSN%===>@FROMDSN                                       +
+To DSN  %===>$TODSN                                         +
+
+Action  %===>$Z+   (Copy or Allocate)
+
+Space:               DCB:                  PDS Only (DB) :
+
+Alloc    %==>#ALLOC+ DSORG   %==>#Z +      Alloc %==>$Z    +
+Used     %==>#USED + RECFM   %==>$Z  +     Used  %==>#Z    +
+Primary  %==>$PRIM + LRECL   %==>$LRECL+   Mem   %==>#MEMS +
+Secondary%==>$SECD + Blk Size%==>$Z    +
+Extents  %==>#Z +
+Unit     %==>$UNIT    +
+Created  %==>#CREATED +
+
)INIT
   .ZVARS  = '(SEL DSORG DBALLOC RECFM DBUSED BLKSIZE EXTENTS)'
   .CURSOR =  TODSN
   &SEL    = 'C'
)REINIT
)PROC
   VER (&SEL,NB,LIST,C,A)
   VER (&FROMDSN,NB,DSNAME)
   VER (&TODSN,NB,DSNAME)
   VER (&DSORG,NB,LIST,PO,PS)
   VER (&PRIM,NB,NUM)
   VER (&SECD,NB,NUM)
   VER (&LRECL,NB,NUM)
   VER (&UNIT,NB,LIST,TRACK,TRACKS,CYLINDER,BLOCK,BLOCKS)
   VER (&BLKSIZE,NB,NUM)
   VER (&RECFM,NB)
   IF (&DBALLOC = &Z)
       &DSORG = 'PS'
   IF (&DSORG = 'PO')
      VER (&DBALLOC,NB,NUM)
)END
*/
