/* REXX    POST       ...a notation on the ISPF LOG
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
                Written by Frank Clarke, Oldsmar FL
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20010612 fxc REXXSKEL v.20010524; enable full-screen entry of text
                  if not specified as a parm.
     20011002 fxc fixed scroll-amt field;
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.20010524      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
"CONTROL ERRORS RETURN"                /* I'll handle my own         */
 
parse arg parms "(("                   /* preserve case              */
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
call B_POST                            /*                           -*/
 
/* \sw.nested then call DUMP_QUEUE                                  -*/
exit                                   /*@ POST                      */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
         /* = '------------------------'  template for max length    */
   zerrsm   = 'LOG message via POST:   '
   zerralrm = "NO"
   zerrhm   = "ISR00000"
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_POST:                                /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   rc = 0                              /* init                       */
   if parms = "" then do               /* text not specified         */
      call DEIMBED                     /* extract panel             -*/
      call BA_SETUP_LIBDEF             /* enable panel              -*/
      call BG_GET_TEXT                 /*                           -*/
      end
 
   if rc = 0 then do                   /* text available             */
      zerrlm = info
      "LOG MSG(ISRZ002)"               /* This line posts to the log */
      end
   else do
      zerrsm = "Entry declined"
      zerrlm = "Non-zero RC from NOTETXT intercepted.  No note was",
               "posted to the LOG."
      zerralrm = "YES"
      "SETMSG  MSG(ISRZ001)"
      end
 
   if parms = "" then,                 /* text not specified         */
      call BZ_DROP_LIBDEF              /*                           -*/
 
return                                 /*@ B_POST                    */
/*
.  ----------------------------------------------------------------- */
BA_SETUP_LIBDEF:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ BA_SETUP_LIBDEF           */
/*
.  ----------------------------------------------------------------- */
BG_GET_TEXT:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "DISPLAY PANEL(NOTETXT)"
 
return                                 /*@ BG_GET_TEXT               */
/*
.  ----------------------------------------------------------------- */
BZ_DROP_LIBDEF:                        /*@                           */
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
 
return                                 /*@ BZ_DROP_LIBDEF            */
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
 
say "                                                                          "
say "  "ex_nam"      will insert a message of your choice to the ISPF Log      "
say "                dataset.  This may be useful for tracking your time when  "
say "                involved in multiple projects.                            "
say "                                                                          "
say "  Syntax:   "ex_nam"  <text>                                              "
say "                                                                          "
say "            <text>    is any message you wish inserted onto the log.  If  "
say "                      <text> is not specified as a parm, you will be      "
say "                      prompted to enter it.                               "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK                                      "
say "   Debugging tools provided include:                                      "
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
/* -------------- REXXSKEL back-end removed for space -------------- */
/*
)))PLIB NOTETXT
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT)  INTENS(LOW) CAPS(ON)
  { TYPE(INPUT)  INTENS(LOW) CAPS(OFF)
  @ TYPE(TEXT)   INTENS(HIGH) COLOR(YELLOW)
  ! TYPE(INPUT)  INTENS(NON)
)BODY EXPAND(บบ)
@บ-บ% Specify Logging Text @บ-บ
%COMMAND ===>_ZCMD
                                                             %SCROLL ===>_ZAMT+
+
+
+
         Please enter the text to be posted to the LOG file:
+
         Text ===>{info
+
)INIT
)PROC
)END
*/
