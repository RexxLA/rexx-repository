/* REXX    COMMANDS   Show the contents of xxxCMDS and allow
                      selection and parameter entry.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
*/
address TSO
arg line 
exec_name = Sysvar(Sysicmd)
if Sysvar(sysispf) = "NOT ACTIVE" then do
   line = line "((  RESTARTED"         /* tell the next invocation   */
   "ISPSTART CMD("exec_name line")"    /* Invoke ISPF if nec.    */
   exit                                /* ...and restart it          */
   end
restarted = WordPos("RESTARTED",opts)>0/* called from READY-mode ?   */
tv = ""
arg parms "((" opts
opts = Strip(opts,"T",")")             /* lop trailing banana        */
 
parse var opts "TRACE" tv .
parse value tv "O"  with tv .          /* guarantee a value          */
rc = Trace(tv)
 
if parms = "?" then call HELP
parse value parms "ISP"   with  cmdtblID .
$tn$ = cmdtblID"CMDS"                  /* ISPCMDS by default         */
 
address ISPEXEC
"CONTROL ERRORS RETURN"
call DEIMBED                           /* extract panel FCCMDSP     -*/
$ddn = $ddn.PLIB
"LIBDEF  ISPPLIB  LIBRARY  ID("$ddn") STACK"
"TBTOP" $tn$
do forever
   "TBDISPL" $tn$ "PANEL(FCCMDSP) CURSOR(ACTION) AUTOSEL(NO)"
   if rc > 4 then leave
   do ztdsels
      select
         when action = "S" then do     /* Select                     */
            "CONTROL DISPLAY SAVE"     /* in case we display s'thing */
            (zctact)
            "CONTROL DISPLAY RESTORE"  /* return from display        */
            end
         when WordPos(action,"D") > 0 then,
            "TBDELETE" $tn$
         when WordPos(action,"E B") > 0 then do
            call F_FIXTBL              /*                           -*/
            end
         otherwise nop
      end                              /* Select                     */
      if ztdsels = 1 then,             /* never do the last one      */
         ztdsels = 0
      else "TBDISPL" $tn$              /* next row                   */
   end                                 /* ztdsels                    */
   action = ""                         /* clear for re-display       */
end                                    /* forever                    */
"LIBDEF  ISPPLIB"
 
if restarted then do
   @@ = OutTrap("ll.")
   exit 4
   end
exit                                   /*@ COMMANDS                  */
/*
.  ----------------------------------------------------------------- */
F_FIXTBL:                              /*@                           */
   address ISPEXEC
 
   save. = ""
   parse value zctverb zcttrunc zctact   with ,
               save.vb save.tr  save.act
   save.desc = zctdesc
   do forever
      "DISPLAY  PANEL(FCCMDFIX)"
      if rc > 0 then leave
   end
   if save.vb    = zctverb   then,
   if save.tr    = zcttrunc  then,
   if save.act   = zctact    then,
   if save.desc  = zctdesc   then return
   "TBMOD" $tn$
 
return                                 /*@ F_FIXTBL                  */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
say "HELP for" Sysvar(Sysicmd) "not available"
exit                                   /*@ HELP                      */
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
   ddnlist  $ddn.  daid.
 
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
)))PLIB FCCMDSP
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
)BODY EXPAND(��)
%�-� Current Command Table Contents �-�
%COMMAND ===>_ZCMD                                            %SCROLL ===>_AMT +
+
+    CmdName    CmdDescription
)MODEL
_Z+ !ZCTVERB + !ZCTDESC
)INIT
  .ZVARS = '(ACTION)'
)REINIT
  IF (&MSG = ' ')
     &ACTION = ' '
     REFRESH (&ACTION)
)END
)))PLIB FCCMDFIX
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  } TYPE(INPUT)  INTENS(HIGH) CAPS(OFF)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
)BODY EXPAND(��)
%�-� Current Command Table Line Contents �-�
%COMMAND ===>_ZCMD
                                                              %SCROLL ===>_AMT +
+
+        Verb ===>_zctverb +
 
+  Truncation ===>_z+
 
+      Action ===>_zctact
 
+ Description ===>}zctdesc
 
)INIT
  .ZVARS = '(ZCTTRUNC)'
)PROC
)END
*/
