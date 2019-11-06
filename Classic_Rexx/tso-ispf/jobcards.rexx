/* REXX    JOBCARDS   Create/Maintain application-specific and
                      user-specific jobcard-sets.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke, Houston, 19980504
 
     Impact Analysis
.    ISPPLIB  JOBC          (embedded)
.    SYSPROC  TRAPOUT
 
     Modification History
     19990712 fxc adapted for PMU
     20010216 fxc adapted for NMR
 
*/
address ISPEXEC                        /* REXXSKEL ver.19980225      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
"CONTROL ERRORS RETURN"                /*                            */
call A_INIT                            /*                           -*/
call B_PANEL                           /*                           -*/
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd
      address TSO "FREE  FI("$ddn")"
   end
   ddnlist = ddnlist dd
 
exit                                   /*@ JOBCARDS                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   parse value "" with,
         pfkey
   "VGET (JOB1)     PROFILE"
   "VGET (ZACCTNUM) SHARED"
   if job1 = "" then do                /* build a new set            */
      call Z_RESET                     /*                           -*/
      "VPUT (JOB1 JOB2 JOB3 JOB4) PROFILE"
      end                              /* JOB1 missing               */
   call DEIMBED                        /* unload panels             -*/
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_PANEL:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "VGET (ZPF03 ZPF05) PROFILE"
   zpf03_save = zpf03                  /* preserve original values   */
   zpf05_save = zpf05                  /*                            */
   parse value "END   END" with zpf03 zpf05 .
   "VPUT (ZPF03 ZPF05) PROFILE"
   do forever
      "DISPLAY PANEL(JOBC)"
      if rc > 0 then do
         if pfkey = "F5" then nop    /* Cancel                     */
                         else "VPUT (JOB1 JOB2 JOB3 JOB4) PROFILE"
         leave
         end                           /*                            */
      if zcmd = "RESET" then call Z_RESET          /*               -*/
   end                                 /* forever                    */
   zpf03  = zpf03_save                 /* restore                    */
   zpf05  = zpf05_save                 /*                            */
   "VPUT (ZPF03 ZPF05) PROFILE"
 
return                                 /*@ B_PANEL                   */
/*
.  ----------------------------------------------------------------- */
Z_RESET:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   job1 = "//"Userid()"A JOB ("zacctnum"),'DEFAULT JOBCARDS',"
   job2 = "//            NOTIFY="Userid()",CLASS=X,MSGCLASS=W"
   job3 = "//*"
   job4 = "//*"
 
return                                 /*@ Z_RESET                   */
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
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say " HELP for" exec_name
say "                                                                 "
say "  "ex_nam"      helps you build a set of default jobcards for use"
say "                by routines which submit background jobs.        "
say "                                                                 "
say "  Syntax:   "ex_nam"  <no parms>                                 "
say "                                                                 "
say "                You will be presented with a panel on which you  "
say "                can make any necessary changes to your personal  "
say "                default jobcards.                                "
say "                                                                 "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:"
say "                                                                 "
say "        MONITOR:  displays key information throughout processing."
say "                  Displays most paragraph names upon entry."
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
/*
)))PLIB JOBC
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ)
%บ-บ Local JOBCARD Specification บ-บ
%COMMAND ===>_ZCMD
 
+
+    Enter%RESET+on the command line to reset your jobcards to the
+    default settings.
+
+    Use%PF 5+to%CANCEL+changes made here.
+
+
+(1)_JOB1
+(2)_JOB2
+(3)_JOB3
+(4)_JOB4
+
)INIT
  &ZCMD = ''
)REINIT
  &ZCMD = ''
)PROC
  IF (.PFKEY = 'PF03')
     &PFKEY = 'F3'
     .RESP  = END
  IF (.PFKEY = 'PF05')
     &PFKEY = 'F5'
     .RESP  = END
  VER (&JOB1,NB)
  VER (&JOB2,NB)
  VER (&JOB3,NB)
  VER (&JOB4,NB)
  REFRESH(*)
)END
*/
