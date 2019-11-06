/* REXX    NEWALIAS   Interactively provide an easy method for
                      specifying an alias for a dataset.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke 20051107
 
     Impact Analysis
.    SYSEXEC   TRAPOUT
 
     Modification History
     20051130 fxc populate ALIASDS; position cursor in ALIASDS;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20040227      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                            */
call B_REALIAS                         /*                            */
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ NEWALIAS                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse var info realdsn info
   aliasds   = realdsn                 /* populate screen variable   */
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_REALIAS:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BA_PROLOG                      /*                            */
   do forever
      call BD_DISPLAY                  /*                            */
      if rc > 0 then leave
   end                                 /* forever                    */
   call BZ_EPILOG                      /*                            */
 
return                                 /*@ B_REALIAS                 */
/*
.  ----------------------------------------------------------------- */
BA_PROLOG:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call DEIMBED                        /*                            */
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ BA_PROLOG                 */
/*
.  ----------------------------------------------------------------- */
BD_DISPLAY:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "DISPLAY PANEL(GETDSN)"
   if rc > 0 then return               /* entry refused              */
 
   if Sysdsn(realdsn) = "OK" then,
   if Sysdsn(aliasds) <> "OK" then,
      do
      address TSO "DEFINE ALIAS( NAME("aliasds")  RELATE("realdsn") )"
      zerrsm = "Alias assigned"
      zerrlm = aliasds "was assigned as an alias of",
               realdsn
      "SETMSG  MSG(ISRZ002)"
      end
   else,                               /* alias exists               */
      do
      zerrsm = "Alias exists"
      zerrlm = "This alias cannot be used because it is ",
               "already in-use."
      "SETMSG  MSG(ISRZ002)"
      end
   else,                               /* realdsn is bad             */
      do
      zerrsm = "Dataset not found"
      zerrlm = "The DSN specified does not exist."
      "SETMSG  MSG(ISRZ002)"
      end
 
return                                 /*@ BD_DISPLAY                */
/*
.  ----------------------------------------------------------------- */
BZ_EPILOG:                             /*@                           */
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
 
return                                 /*@ BZ_EPILOG                 */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
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
address TSO;"CLEAR" ; say ""
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      Interactively provide an easy method for specifying an    "
say "                alias for a dataset.                                      "
say "                                                                          "
say "  Syntax:   "ex_nam"  <dsn>                                               "
say "                                                                          "
say "            dsn       names, in TSO-format, the dataset which is to be    "
say "                      aliased.  You will be prompted in a pop-up screen to"
say "                      provide an alias for this DSN.                      "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
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
 
if sw.inispf then,
   address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/* ------------ REXXSKEL back-end removed for space ---------------- */
/*
)))PLIB GETDSN
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT)  INTENS(LOW) CAPS(ON)
  @ TYPE(TEXT)   INTENS(HIGH) COLOR(YELLOW)
  ! TYPE(INPUT)  INTENS(NON)
)BODY EXPAND(บบ)
@บ-บ% Define a new ALIAS for a dataset @บ-บ
%COMMAND ===>_ZCMD
                                                             %SCROLL ===>_ZAMT+
+
+         DSN ===>_realdsn
+
        ALIAS ===>_aliasds
+
)INIT
   .CURSOR = ALIASDS
)PROC
   VER (&REALDSN,NB,DSNAME)
   VER (&ALIASDS,NB,DSNAME)
)END
*/
