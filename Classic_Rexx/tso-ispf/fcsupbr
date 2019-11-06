/* REXX    FCSUPBR    SuperBrowse replacement
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke, Oldsmar FL
 
     Impact Analysis
.    SYSPROC  FCSUPED
 
     Modification History
     19971126 fxc upgrade from undated REXXSKEL to v.19971030;
     19980309 fxc imbed panel ZSUPBROW
     19980811 fxc change BROWSE to VIEW
     19991129 fxc upgrade v.19971030 to v.19991109; new DEIMBED;
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
if Sysvar("SYSISPF") = "NOT ACTIVE" then do
   address TSO
   arg argline
   "ISPSTART CMD("Sysvar("SYSICMD")  argline ")"
   exit
   end                                 /* ISPF not active            */
 
call A_INIT                            /*                           -*/
call B_ISPF_OPS                        /*                           -*/
 
exit                                   /*@ FCSUPBR                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value "" with,                /* initializing value         */
               pnl.  .
   pnl.BROWSE = "ZSUPBROW"
   pnl.VIEW   = "ZSUPBROW"
   pnl.EDIT   = "ZSUPEDIT"
 
   func    = "VIEW"
   altfunc = "EDIT"
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_ISPF_OPS:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
   call DEIMBED                        /* extract panel              */
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
   "CONTROL ERRORS RETURN"
   do forever
      "DISPLAY PANEL("pnl.func")"      /* edit or browse             */
      if rc > 0 then leave
 
      if bocnl = "Y" then,             /* wants to Edit              */
         op = altfunc
      else op = func
 
      if bsvol = "" then volinfo = ""
      else volinfo = "VOLUME("bsvol")"
 
      if bmember = "" then meminfo = ""
      else meminfo = "("bmember")"
 
      if zopt = " " then,
      if bocnl = "Y" then do           /* swap to alternate          */
         "CONTROL DISPLAY SAVE"
         address TSO "FCSUPED"
         "CONTROL DISPLAY RESTORE"
         iterate
         end ; else,                   /* swap                       */
         do                            /* no ZOPT, BOCNL = N         */
         iterate
         end ; else,                   /* swap                       */
      if zopt < "I" then do            /* 3-level set                */
         ed_dsn = Value("BPRJ"zopt)"."Value("BLIB"zopt)"."Value("BTYP"zopt)
         ed_dsn = Strip(ed_dsn,,".")   /* lop trailing dots          */
         end ; else,                   /* 3-level set                */
      if zopt > "H" then do            /* n-level set                */
         ed_dsn = Value("BDSN"zopt)
         if Left(ed_dsn,1) = "'" then,
            ed_dsn = Strip(ed_dsn,,"'")
         else ed_dsn = Userid()"."ed_dsn
         end                           /* n-level set                */
 
      (OP) "DATASET('"ed_dsn||meminfo"')" volinfo
      call M_MSG(rc)
   end                                 /* forever                    */
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      "LIBDEF  ISP"dd
   end
   rc = Outtrap("ZZ.")
   address TSO "DELETE" exec_name".PLIB"
   rc = Outtrap("OFF")
 
return                                 /*@ B_ISPF_OPS                */
/*
.  ----------------------------------------------------------------- */
M_MSG:                                 /*@                           */
   if branch then call BRANCH
   address ISPEXEC
   arg retcode .
 
   if op = "EDIT" then do              /* Edit                       */
      if bmember = "" then do          /* No member                  */
         if rc = 0 then do; zerrsm="Dataset saved"
                            zerrlm="Dataset saved as" ed_dsn; end
         else,
         if rc = 4 then do; zerrsm="Dataset not changed";
             zerrlm="Dataset was not changed or Edit was cancelled"; end
         end                           /* No member                  */
      else do                          /* Member                     */
         if rc = 0 then do; zerrsm="Member saved";
                          zerrlm=bmember "has been saved in" ed_dsn; end
         else,
         if rc = 4 then do; zerrsm="Member not changed";
             zerrlm=bmember "was not changed or Edit was cancelled"; end
         end                           /* Member                     */
      end                              /* Edit                       */
   else do                             /* View                       */
      if bmember = "" then do          /* No member                  */
         if rc = 0 then do; zerrsm="View completed";
                            zerrlm=ed_dsn "was viewed"; end
         end                           /* No member                  */
      else do                          /* Member                     */
         if rc = 0 then do; zerrsm="Member viewed"
                          zerrlm=bmember "viewed in dataset" ed_dsn; end
         else,
         if rc = 4 then do
            zerrsm="Member not found or in use"
            zerrlm=bmember "was not found in" ed_dsn,
                           "or was in use by another process"; end
         end                           /* Member                     */
      end                              /* View                       */
   if zerrsm <> "" then,
      "SETMSG MSG(ISRZ002)"
 
return                                 /*@ M_MSG                     */
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
say "  "ex_nam"      provides an easy interface for browsing your      "
say "                favorite datasets.                                "
say "                                                                  "
say "  Syntax:   "ex_nam"  <no parms>                                  "
pull
"CLEAR"
say "   Debugging tools provided include:                              "
say "                                                                  "
say "        MONITOR:  displays key information throughout processing. "
say "                  Displays most paragraph names upon entry.       "
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
/*      REXXSKEL back-end removed for space                          */
/*
)))PLIB ZSUPBROW
)ATTR
 % TYPE(TEXT) INTENS(HIGH) SKIP(ON)
 + TYPE(TEXT) INTENS(LOW) SKIP(ON)
 @ TYPE(TEXT) INTENS(LOW) COLOR(YELLOW)
)BODY
@Unsupported ------------------% Super Browse @---------------------------------
%SELECT LIBRARY%===>_ZOPT                                   +%EDIT DATA ?==>_Z+
+
%SELECT MEMBER %===>_BMEMBER +  (Blank for member list)   %VOLUME %==>_BSVOL +
+
+ISPF LIBRARIES:
%A+ PROJECT%===>_BPRJA   +%B+%===>_BPRJB   +%C+%===>_BPRJC   +%D+%===>_BPRJD   +
+   LIBRARY%===>_BLIBA   +   %===>_BLIBB   +   %===>_BLIBC   +   %===>_BLIBD   +
+   TYPE   %===>_BTYPA   +   %===>_BTYPB   +   %===>_BTYPC   +   %===>_BTYPD   +
%
%E+ PROJECT%===>_BPRJE   +%F+%===>_BPRJF   +%G+%===>_BPRJG   +%H+%===>_BPRJH   +
+   LIBRARY%===>_BLIBE   +   %===>_BLIBF   +   %===>_BLIBG   +   %===>_BLIBH   +
+   TYPE   %===>_BTYPE   +   %===>_BTYPF   +   %===>_BTYPG   +   %===>_BTYPH   +
+
+OTHER PARTITIONED OR SEQUENTIAL DATASETS:
%I+ DATASET NAME %===>_BDSNI                                                   +
%J+ DATASET NAME %===>_BDSNJ                                                   +
%K+ DATASET NAME %===>_BDSNK                                                   +
%L+ DATASET NAME %===>_BDSNL                                                   +
%M+ DATASET NAME %===>_BDSNM                                                   +
%N+ DATASET NAME %===>_BDSNN                                                   +
%O+ DATASET NAME %===>_BDSNO                                                   +
%P+ DATASET NAME %===>_BDSNP                                                   +
%Q+ DATASET NAME %===>_BDSNQ                                                   +
)INIT
   IF (&MSG = ' ')
      .MSG = &MSG
   .ZVARS  = '(BOCNL)'
   .CURSOR = ZOPT
   .HELP   = YSUPBR00
   &BOCNL  = N
   &BSVOL  = ' '
   &BSMEMBER  = ' '
   &ZSEL   = ' '
)REINIT
   .CURSOR = ZOPT
)PROC
   &MSG = ' '
   VER(&BOCNL,LIST,Y,N)
   VER(&ZOPT,LIST,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q)
   IF (&ZOPT=A)
      VER(&BPRJA,NONBLANK)
      VER(&BLIBA,NONBLANK)
   IF (&ZOPT=B)
      VER(&BPRJB,NONBLANK)
      VER(&BLIBB,NONBLANK)
   IF (&ZOPT=C)
      VER(&BPRJC,NONBLANK)
      VER(&BLIBC,NONBLANK)
   IF (&ZOPT=D)
      VER(&BPRJD,NONBLANK)
      VER(&BLIBD,NONBLANK)
   IF (&ZOPT=E)
      VER(&BPRJE,NONBLANK)
      VER(&BLIBE,NONBLANK)
   IF (&ZOPT=F)
      VER(&BPRJF,NONBLANK)
      VER(&BLIBF,NONBLANK)
   IF (&ZOPT=G)
      VER(&BPRJG,NONBLANK)
      VER(&BLIBG,NONBLANK)
   IF (&ZOPT=H)
      VER(&BPRJH,NONBLANK)
      VER(&BLIBH,NONBLANK)
   IF (&ZOPT=I)
      VER(&BDSNI,NONBLANK)
   IF (&ZOPT=J)
      VER(&BDSNJ,NONBLANK)
   IF (&ZOPT=K)
      VER(&BDSNK,NONBLANK)
   IF (&ZOPT=L)
      VER(&BDSNL,NONBLANK)
   IF (&ZOPT=M)
      VER(&BDSNM,NONBLANK)
   IF (&ZOPT=N)
      VER(&BDSNN,NONBLANK)
   IF (&ZOPT=O)
      VER(&BDSNO,NONBLANK)
   IF (&ZOPT=P)
      VER(&BDSNP,NONBLANK)
   IF (&ZOPT=Q)
      VER(&BDSNQ,NONBLANK)
   VPUT (
          BPRJA BLIBA BTYPA BPRJB BLIBB BTYPB BPRJC BLIBC BTYPC
          BPRJD BLIBD BTYPD BPRJE BLIBE BTYPE BPRJF BLIBF BTYPF
          BPRJG BLIBG BTYPG BPRJH BLIBH BTYPH BDSNI BDSNJ BDSNK
          BDSNL BDSNM BDSNN BDSNO BDSNP BDSNQ
        ) PROFILE
)END
*/
