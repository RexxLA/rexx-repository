/* REXX    ALIST      Display the user's current allocations

                    Written by Frank Clarke, Oldsmar, FL
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
*/
address TSO                            /* default address            */
tv = ""
signal on syntax
parse source sys_id how_invokt exec_name DD_nm DS_nm as_invokt cmd_env,
                          addr_spc usr_tokn
if ds_nm <> "?" then do                /* explicit invocation        */
   say exec_name "cannot be invoked explicitly."
   say " "
   say "   It must be part of your SYSPROC or SYSEXEC allocation,"
   say "   and invoked implicitly because it requires ISPF facilities"
   say "   and these are incompatible with a command library which is"
   say "   not part of your defined environment."
   say " "
   exit
   end
if Sysvar("sysispf") = "NOT ACTIVE" then do
   arg line
   line = line "((  RESTARTED"         /* tell the next invocation   */
   "ISPSTART CMD("exec_name line")"    /* Invoke ISPF if nec.    */
   exit                                /* ...and restart it          */
   end

arg target "((" opts
opts = Strip( opts , "T" , ")" )       /* clip trailing paren        */
if Word(target,1) = "?" then call HELP /* ...and don't come back     */

parse var opts "TRACE" tv .
parse value tv "O"  with tv .
rc = Trace(tv)
address ISPEXEC                        /* default address for ISPF   */
"CONTROL ERRORS RETURN"

call A_INIT                            /*                           -*/
call B_GET_ALLOCATIONS                 /*                           -*/
call C_LOAD_TABLE                      /*                           -*/
call D_TABLE_OPS                       /*                           -*/
call E_REDO_ALLOC                      /*                           -*/

exit                                   /*@ ALIST                     */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   address TSO

   restarted = WordPos("RESTARTED",opts)>0/* called from READY-mode ? */
   parse value "0       ISR00000    YES"   with,
               got_one   zerrhm     zerralrm     zerrsm zerrlm
   t_nam = "T"Right(Time(s),5,0)       /* T32855 maybe              #*/

   parse value "?"        with,
                ddname   dsnames.   disp.  tk_globalvars  ,
                ddlist ,
                .

return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_GET_ALLOCATIONS:                     /*@                           */
   address TSO

   tgt_list = ""

   do ii = 1 to Words(target)          /* for every target spec      */
      this_tgt = Word(target,ii)
      if this_tgt = "ISPF" then,       /* expand ISPF                */
         tgt_list = tgt_list "ISPPLIB ISPMLIB ISPSLIB ISPTLIB",
                             "ISPTABL ISPLLIB ISPPROF"
      else,
      if this_tgt = "CMDS" |,          /* expand CMDS                */
         this_tgt = "COMMANDS" then,
         call BA_Q_ALTLIB              /*                           -*/
/*       tgt_list = tgt_list "SYSPROC SYSEXEC" */
      else,                            /* just add to the list       */
         tgt_list = tgt_list this_tgt
   end                                 /* ii                         */

   ln. = ""                            /* setup array                */
   rc = Outtrap("ln.")                 /* open trap                  */
   "LISTA ST"
   rc = Outtrap("off")                 /* close trap                 */
   call BB_GET_STACKS                  /*                           -*/

   dds_to_realloc = ""
   ds_stack.      = ""
   redo_alloc     = "0"

return                                 /*@ B_GET_ALLOCATIONS         */
/*
.  ----------------------------------------------------------------- */
BA_Q_ALTLIB:                           /*@                           */
   address TSO

   $x = Outtrap("alt.")                /* set up outtrap             */
   "ALTLIB DISPLAY"                    /* get ddname-list            */
   $x = Outtrap("OFF")                 /* release trap               */

   do bax = 1 to alt.0
      parse var alt.bax "DDNAME=" baxddn .
      tgt_list = tgt_list baxddn
   end                                 /* bax                        */

return                                 /*@ BA_Q_ALTLIB               */
/*
   Build lists of DSNames by DDName and store in a stem array indexed
   by DDName.
.  ----------------------------------------------------------------- */
BB_GET_STACKS:                         /*@                           */
   address TSO
                                          /* Build DDName stack      */
   do bbx = 1 to ln.0,                 /* for each trapped line      */
      until Substr(ln.bbx,1,1) <> "-"  /* ...skip the header         */
   end                                 /* bbx                        */

   start = bbx
   do bbx = start to ln.0              /* for each trapped line      */
      if Left(ln.bbx,1) = ' ' then do  /* it's a DDname              */
         if Substr(ln.bbx,3,1) <> " " then do   /* new DDName        */
            parse var ln.bbx ddname  disp  .
            ddlist  = ddlist  ddname
            end                        /* DDName                     */
         dsnames.ddname = dsnames.ddname dsname
         disp.ddname = disp
         end                           /* DDname                     */
      else dsname = Word(ln.bbx,1)     /* it's a DSName              */
   end                                 /* bbx                        */

return                                 /*@ BB_GET_STACKS             */
/*
.  ----------------------------------------------------------------- */
C_LOAD_TABLE:                          /*@                           */
   address ISPEXEC

   if tgt_list = "" then tgt_list = ddlist

   "TBCREATE " t_nam " NAMES(DDNAME DSNAME DISP) NOWRITE"
   disp = "?"

   do Words(tgt_list)                  /* every DDName               */
      parse var tgt_list  ddname tgt_list
      ds_stack.ddname = dsnames.ddname
      disp            = disp.ddname
      do Words(dsnames.ddname)
         parse var dsnames.ddname  dsname  dsnames.ddname
         "TBADD" t_nam                 /* add to table              #*/
         got_one = "1"
      end                              /* dsnames                    */
   end                                 /* Words(tgt_list)            */

return                                 /*@ C_LOAD_TABLE              */
/*
.  ----------------------------------------------------------------- */
D_TABLE_OPS:                           /*@                           */
   address ISPEXEC

   if got_one then do
      call DEIMBED                     /* expose the panel          -*/
      $ddn = $ddn.PLIB
      "LIBDEF ISPPLIB LIBRARY ID("$ddn") STACK"

      "TBTOP" t_nam                    /*                            */
      "CONTROL DISPLAY SAVE"           /* In case of re-invocation   */
      do forever
         "TBDISPL" t_nam "PANEL(FCALLOC) CURSOR(ACTION) AUTOSEL(NO)"
         if rc > 4 then leave
         do ztdsels
            curact = Translate(action)
            "CONTROL DISPLAY SAVE"
            select
               when curact = "E" then do /* Edit                     */
                  "EDIT DATASET('"dsname"')"
                  save_rc = rc
                  end                  /* Edit                       */
               when curact = "V" then do /* View                     */
                  "VIEW DATASET('"dsname"') CONFIRM(NO)"
                  save_rc = rc
                  end                  /* View                       */
               when curact = "B" then do /* Browse                   */
                  "BROWSE DATASET('"dsname"')"
                  save_rc = rc
                  end                  /* Browse                     */
               when curact = "D" then do /* DUP                      */
                  address TSO "DUP   '"dsname"' ID"
                  save_rc = rc
                  if rc <> 0 then do
                     ZERRSM = "RC ="rc
                     ZERRLM = "DUP ended abnormally"
                     end
                  end                  /* CLONE                      */
               when curact = "F" then do /* Free                     */
                  redo_alloc = "1"
                  if WordPos(ddname,dds_to_realloc) = 0 then,/* new DDName */
                     dds_to_realloc = dds_to_realloc ddname
                  dsid = WordPos(dsname,ds_stack.ddname) /* in the list ? */
                  if dsid > 0 then,
                     ds_stack.ddname = DelWord(ds_stack.ddname,dsid,1)
                  end                  /* Free                       */
               when curact = "X" then do /* UnDisplay                */
                  "TBDELETE" t_nam     /* drop this row              */
                  end                  /* UnDisplay                  */
               otherwise nop
            end                        /* Select                     */
            "CONTROL DISPLAY RESTORE"
            if save_rc <> 0 then,
               "SETMSG MSG(ISRZ002)"
            save_rc = 0
            if ztdsels = 1 then,       /* never do the last one      */
               ztdsels = 0
            else "TBDISPL" t_nam       /* next row                  #*/
         end                           /* ztdsels                    */
         action = ""                   /* clear for re-display       */
      end                              /* forever                    */
      "CONTROL DISPLAY RESTORE"        /* In case of re-invocation   */

      "LIBDEF ISPPLIB"
      "TBCLOSE" t_nam
      address TSO "FREE FI("$ddn")"
      end                              /* got_one                    */
   else do
      "TBEND" t_nam                    /*                           #*/
      ZERRSM = "No datasets"           /* short message              */
      ZERRLM = "No datasets were allocated as specified/implied."
      "SETMSG MSG(ISRZ002)"
      end

return                                 /*@ D_TABLE_OPS               */
/*
.  ----------------------------------------------------------------- */
E_REDO_ALLOC:                          /*@                           */
   address TSO                         /* ready for some TSO work    */

   if redo_alloc then do
      do fidx = 1 to Words(dds_to_realloc)/* for each DDName         */
         ddname = Word(dds_to_realloc,fidx) /* grab it */
         alloc_list = ""               /* initialize                 */

         if Words(ds_stack.ddname) > 0 then,
         do didx = 1 to Words(ds_stack.ddname) /* for each DSName    */
            alloc_list = alloc_list "'"Word(ds_stack.ddname,didx)"'"
         end

         if alloc_list <> "" then,     /*  re-ALLOC                  */
            "ALLOC FI("ddname") DA("alloc_list") SHR REU"
         else "FREE FI("ddname")"
      end                              /* fidx                       */
   end                                 /* redo_alloc                 */

return                                 /*@ E_REDO_ALLOC              */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO "CLEAR"
say "                                                                 "
say "  ALIST         displays a scrollable list of allocated datasets."
say "                The list may be limited to specific DDNames or   "
say "                specific sets of DDNames.                        "
say "                                                                 "
say "  Syntax:   ALIST     [ddname-list] [CMDS] [ISPF]                "
say "                      [ ? ]                                      "
say "                                                                 "
say "            [ddname-list] is a blank-delimited list of filenames "
say "                      to be displayed.                           "
say "            [CMDS] is equivalent to 'SYSPROC SYSEXEC'            "
say "            [ISPF] is equivalent to 'ISPPLIB ISPMLIB ISPSLIB     "
say "                      ISPTLIB ISPLLIB ISPPROF ISPTABL'           "
say "                                                                 "
say "   ALIST may be invoked from READY-mode.                         "
say "                                                                 "
exit                                   /*@ HELP                      */

/* ----------------------------------------------------------------- */
SYNTAX:                                /*@                           */
   errormsg = "REXX error" rc "in line" sigl":" errortext(rc)
   say errormsg
   say sourceline(sigl)
   trace "?r"
   nop
exit                                   /*@ SYNTAX                    */
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
)))PLIB  FCALLOC
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
)BODY EXPAND(||)
%|-| Current Allocations |-|
%COMMAND ===>_ZCMD
                                                              %SCROLL ===>_AMT +
+
+    DDName     DSName                                             Disp
)MODEL
_Z+ !DDNAME  + !DSNAME                                          + !DISP        +
)INIT
  .ZVARS = '(ACTION)'
  .HELP  = FCALLOCH
)REINIT
  IF (&MSG = ' ')
     &ACTION = ' '
     REFRESH (&ACTION)
)END
)))PLIB  FCALLOCH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(��)
%TUTORIAL �-� Current Allocations �-� TUTORIAL
%Next Selection ===>_ZCMD

+
    Panel FCALLOC shows the current allocations for the DDNames you specified
    (or ALL DDNames).

    For each shown dataset you may select among several actions:

        %B+-%BROWSE  +Browse the selected dataset.

        %E+-%EDIT    +Edit the selected dataset.

        %V+-%VIEW    +View the selected dataset.

        %D+-%DUP     +You may make a copy (either filled or empty) of the
                      selected dataset.  Subroutine DUP will be called to
                      perform this function.

        %F+-%FREE    +This is effective only for DDNames which are not under
                      the control of ISPF since those files are necessarily
                      OPEN while ISPF is active.

)PROC
)END
*/
