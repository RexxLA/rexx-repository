/* REXX    FCSUPED    SuperEdit replacement
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke, Oldsmar FL
 
     Impact Analysis
.    SYSPROC  FCSUPBR
 
     Modification History
     19980309 fxc upgrade from v.950824 to v.19980225; imbed panel
                  ZSUPEDIT; RXSKLY2K; DECOMM;
     19980811 fxc change BROWSE to VIEW
     19991129 fxc upgrade from v.19980225 to v.19991109; new DEIMBED;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
if Sysvar("SYSISPF") = "NOT ACTIVE" then do
   arg argline
   "ISPSTART CMD("Sysvar("SYSICMD")  argline ")"
   exit
   end                                 /* ISPF not active            */
 
call A_EDREC                           /*                           -*/
 
push  ""                               /* initializing value         */
pull  pnl.
 
push  "0"                              /* initializing value         */
pull  sw.
pnl.BROWSE  = "ZSUPBROW"
pnl.VIEW    = "ZSUPBROW"
pnl.EDIT    = "ZSUPEDIT"
 
func      = "EDIT"
altfunc   = "VIEW"
 
address ISPEXEC
"CONTROL ERRORS RETURN"
zerrsm = ""
call DEIMBED                           /*                           -*/
dd = ""
do Words(ddnlist)                      /* each LIBDEF DD             */
   parse value ddnlist dd  with  dd ddnlist
   $ddn   = $ddn.dd                    /* PLIB322 <- PLIB            */
   "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
end
ddnlist = ddnlist dd
 
do forever
   "DISPLAY PANEL("pnl.func")"         /* edit or browse             */
   if rc > 0 then leave
 
   if ocnl = "Y" then,                 /* wants to Browse            */
      op  =  altfunc
   else op = func
 
   if svol = "" then volinfo = ""
   else volinfo = "VOLUME("svol")"
 
   if member = "" then meminfo = ""
   else meminfo = "("member")"
 
   if zopt = " " then,
   if ocnl = "Y" then do               /* swap to alternate          */
      "CONTROL DISPLAY SAVE"
      address TSO "FCSUPBR"
      "CONTROL DISPLAY RESTORE"
      iterate
      end ; else,                      /* swap                       */
      do                               /* no ZOPT, OCNL = N          */
      iterate
      end ; else,                      /* swap                       */
   if zopt < "I" then do               /* 3-level set                */
      ed_dsn = Value("PRJ"zopt)"."Value("LIB"zopt)"."Value("TYP"zopt)
      ed_dsn  = Strip(ed_dsn,,".")     /* lop trailing dots          */
      end ; else,                      /* 3-level set                */
   if zopt > "H" then do               /* n-level set                */
      ed_dsn  =  Value("DSN"zopt)
      if Left(ed_dsn,1) = "'" then,
         ed_dsn = Strip(ed_dsn,,"'")
      else ed_dsn = Userid()"."ed_dsn
      end                              /* n-level set                */
 
   (OP) "DATASET('"ed_dsn||meminfo"')" volinfo
   call M_MSG(rc)                      /*                           -*/
end                                    /* forever                    */
 
dd = ""
do Words(ddnlist)                      /* each LIBDEF DD             */
   parse value ddnlist dd  with  dd ddnlist
   "LIBDEF  ISP"dd
end
 
rc = Outtrap("ZZ.")
address TSO "DELETE" exec_name".PLIB"
rc = Outtrap("OFF")
 
exit
/*
.  ----------------------------------------------------------------- */
A_EDREC:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "EDREC QUERY"
   if rc = 0 then "EDREC INIT"; else,
   if rc = 4 then do
      "DISPLAY PANEL(ISREDM02)"
      if rc = 8 then exit
      if rc > 8 then do
         "SETMSG MSG(ISRZ002)"
         exit
         end
      if zedcmd = "" then do
         "EDREC PROCESS"
         if rc = 4 then do; zerrsm="EDREC PROCESS :: RC=4";zerrlm = zerrsm
            "SETMSG MSG(ISRZ002)"
            end
         end; else,
      if zedcmd = "C" then do          /* CANCEL                     */
         "EDREC CANCEL"
         end; else,
      if zedcmd = "D" then do          /* DEFER                      */
         "EDREC DEFER "
         end
      end                              /* QUERY = 4                  */
   else do
      "SETMSG MSG("zerrmsg")"
      exit
      end
 
return                                 /*@ A_EDREC                   */
/*
.  ----------------------------------------------------------------- */
M_MSG:                                 /*@                           */
   if branch then call BRANCH
   address ISPEXEC
   arg retcode .
 
   if op = "EDIT" then do              /* Edit                       */
      if member = "" then do           /* No memberber               */
         if rc = 0 then do; zerrsm="Dataset saved"
            zerrlm="Dataset saved as" ed_dsn; end
         else,
         if rc = 4 then do; zerrsm="Dataset not changed"
            zerrlm="Dataset was not changed or Edit was cancelled"; end
         end                           /* No member                  */
      else do                          /* Member                     */
         if rc = 0 then do; zerrsm="Member saved"
            zerrlm=member "has been saved in" ed_dsn; end
         else,
         if rc = 4 then do; zerrsm="Member not changed"; zerrlm=member,
            "was not changed or Edit was cancelled"; end
         end                           /* Member                     */
      end                              /* Edit                       */
   else do                             /* View                       */
      if member = "" then do           /* No memberber               */
         if rc = 0 then do; zerrsm="View completed"; zerrlm=ed_dsn "was viewed"
         end
         end                           /* No member                  */
      else do                          /* Member                     */
         if rc = 0 then do; zerrsm="Member viewed"
            zerrlm=member "viewed in dataset" ed_dsn; end
         else,
         if rc = 4 then do; zerrsm="Member not found or in use"; zerrlm=member,
         "was not found in" ed_dsn "or was in use by another process"; end
         end                           /* Member                     */
      end                              /* View                       */
   if zerrsm \= "" then,
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
say "  "ex_nam"      provides an easy interface for editing your       "
say "                favorite datasets.                                "
say "                                                                  "
say "  Syntax:   "ex_nam"  <no parms>                                  "
say "                                                                  "
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
/*      REXXSKEL back-end removed for space                          */
/*
)))PLIB  ZSUPEDIT
)ATTR
 % TYPE(TEXT) INTENS(HIGH) SKIP(ON)
 + TYPE(TEXT) INTENS(LOW) SKIP(ON)
 @ TYPE(TEXT) INTENS(HIGH) COLOR(YELLOW)
)BODY
@Unsupported ----------------% Super Editor @-----------------------------------
%SELECT LIBRARY%===>_ZOPT                            %BROWSE DATA?%==>_Z+ (N/Y)
+
%SELECT MEMBER %===>_MEMBER  +  (Blank for member list)  %VOLUME %==>_SVOL  +
+
+ISPF LIBRARIES:
%A+ PROJECT%===>_PRJA    +%B+%===>_PRJB    +%C+%===>_PRJC    +%D+%===>_PRJD    +
+   LIBRARY%===>_LIBA    +   %===>_LIBB    +   %===>_LIBC    +   %===>_LIBD    +
+   TYPE   %===>_TYPA    +   %===>_TYPB    +   %===>_TYPC    +   %===>_TYPD    +
%
%E+ PROJECT%===>_PRJE    +%F+%===>_PRJF    +%G+%===>_PRJG    +%H+%===>_PRJH    +
+   LIBRARY%===>_LIBE    +   %===>_LIBF    +   %===>_LIBG    +   %===>_LIBH    +
+   TYPE   %===>_TYPE    +   %===>_TYPF    +   %===>_TYPG    +   %===>_TYPH    +
+
+OTHER PARTITIONED OR SEQUENTIAL DATASETS:
%I+ DATASET NAME %===>_DSNI                                                    +
%J+ DATASET NAME %===>_DSNJ                                                    +
%K+ DATASET NAME %===>_DSNK                                                    +
%L+ DATASET NAME %===>_DSNL                                                    +
%M+ DATASET NAME %===>_DSNM                                                    +
%N+ DATASET NAME %===>_DSNN                                                    +
%O+ DATASET NAME %===>_DSNO                                                    +
%P+ DATASET NAME %===>_DSNP                                                    +
%Q+ DATASET NAME %===>_DSNQ                                                    +
)INIT
   IF (&MSG  = ' ')
       .MSG  = &MSG
   .ZVARS  = '(OCNL)'
   .HELP   = YSUPED00
   .CURSOR = ZOPT
   &CCMD   = ' '
   &OCNL   = 'N'
   &SVOL   = ' '
)REINIT
   .CURSOR = ZOPT
)PROC
   &MSG  = ' '
   VER(&OCNL,LIST,Y,N)
   VER(&ZOPT,LIST,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q)
   IF (&ZOPT=A)
      VER(&PRJA,NB,NAME)
      VER(&LIBA,NB,NAME)
   IF (&ZOPT=B)
      VER(&PRJB,NB,NAME)
      VER(&LIBB,NB,NAME)
   IF (&ZOPT=C)
      VER(&PRJC,NB,NAME)
      VER(&LIBC,NB,NAME)
   IF (&ZOPT=D)
      VER(&PRJD,NB,NAME)
      VER(&LIBD,NB,NAME)
   IF (&ZOPT=E)
      VER(&PRJE,NB,NAME)
      VER(&LIBE,NB,NAME)
   IF (&ZOPT=F)
      VER(&PRJF,NB,NAME)
      VER(&LIBF,NB,NAME)
   IF (&ZOPT=G)
      VER(&PRJG,NB,NAME)
      VER(&LIBG,NB,NAME)
   IF (&ZOPT=H)
      VER(&PRJH,NB,NAME)
      VER(&LIBH,NB,NAME)
   IF (&ZOPT=I)
      VER(&DSNI,NB,DSNAME)
   IF (&ZOPT=J)
      VER(&DSNJ,NB,DSNAME)
   IF (&ZOPT=K)
      VER(&DSNK,NB,DSNAME)
   IF (&ZOPT=L)
      VER(&DSNL,NB,DSNAME)
   IF (&ZOPT=M)
      VER(&DSNM,NB,DSNAME)
   IF (&ZOPT=N)
      VER(&DSNN,NB,DSNAME)
   IF (&ZOPT=O)
      VER(&DSNO,NB,DSNAME)
   IF (&ZOPT=P)
      VER(&DSNP,NB,DSNAME)
   IF (&ZOPT=Q)
      VER(&DSNQ,NB,DSNAME)
   VPUT (
          PRJA LIBA TYPA PRJB LIBB TYPB PRJC LIBC TYPC
          PRJD LIBD TYPD PRJE LIBE TYPE PRJF LIBF TYPF
          PRJG LIBG TYPG PRJH LIBH TYPH DSNI DSNJ DSNK
          DSNL DSNM DSNN DSNO DSNP DSNQ MEMBER
        ) PROFILE
)END
   &MEMBER = ' '
     VPUT (NAME-LIST) ASIS
*/
