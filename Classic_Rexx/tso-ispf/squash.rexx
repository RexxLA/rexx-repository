/* REXX    SQUASH     Submit a job to compress a dataset.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Chris Lewis 19960708
 
     Impact Analysis
.    SYSPROC   TRAPOUT
.    ISPSLIB   SQUASH
 
     Modification History
     19980505 fxc RXSKLY2K; upgrade from v.960702 to v.19980225;
                  DECOMM;
     19990712 fxc adapted for PMU
     19991129 fxc upgrade from v.19980225 to v.19991109; new BEIMBED;
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
parse value reverse(info) with dsn .   /* take parm over ZDSN        */
dsn = reverse(dsn)
 
if dsn = "" | dsn = "''" then do
   helpmsg = "Dataset Name Required"
   call HELP
   end
 
if left(dsn,1) = "'" then              /* dataset should be in TSO   */
   dsn = strip(dsn,,"'")               /* format; must be fully      */
else                                   /* qualified and unquoted for */
   dsn = userid()"."dsn                /* the JCL.                   */
 
call DEIMBED                           /* extract SLIB(SQUASH)      -*/
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
"FTOPEN TEMP"
"FTINCL SQUASH"
"FTCLOSE"
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      "LIBDEF  ISP"dd
   end
mstat = Msg("OFF"); address TSO "DELETE" exec_name".SLIB"; mstat = Msg(mstat)
 
"VGET (ZTEMPN ZTEMPF)"
 
if monitor then do
   "LMINIT DATAID(DDNID) DDNAME("ztempn")"
   "EDIT DATAID("DDNID")"
   end
 
if noupdt then nop
else
   address TSO "submit '"ztempf"'"
 
exit                                   /*@ SQUASH                    */
/*
   Parse out the embedded components at the back of the source code.
 
   The components are enclosed in a comment whose start and end are on
   individual lines for easier recognition.
 
   Each component is identified by a triple-close-paren ")))" in
   column 1 followed by a DDName and a membername.  The text of the
   component begins on the next line.
 
   There are no restrictions on the DDName, but the DSName which will
   be generated for each component type is <exec_name.DDName>.  It is
   up to the programmer to add the code to properly LIBDEF each
   component type.
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
   if branch then call BRANCH
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
 
say "  SQUASH        Submit a job to compress a dataset.              "
say "                                                                 "
say "  Syntax:   SQUASH    <dsn>              -  TSO Format           "
say "                                                                 "
say "            To squeeze the dataset you are currently in, add     "
say "            the following to your command table:                 "
say "                                                                 "
say "            VERB     T  ACTION                                   "
say "                           DESCRIPTION                           "
say "            -------- -  ---------------------------------------- "
say "            SQUASH   2  SELECT CMD(%SQUASH '&ZDSN' &ZPARM)       "
say "                           SUBMIT A JOB TO COMPRESS A DATASET    "
say "                                                                 "
say "            NOTE:  Any parm is taken in preference to ZDSN.  The "
say "                   program will take the last parm as the dsn to "
say "                   compress.                                     "
say "            NOTE:  Option MONITOR will display the JCL prior to  "
say "                   submission.                                   "
say "                   Option NOUPDT will stop automatic submission  "
say "                   of the JCL.                                   "
say "                                                                 "
pull
"CLEAR"
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
/*   REXXSKEL back-end removed for space      */
/*
)))SLIB SQUASH
&JOB1
&JOB2
&JOB3
&JOB4
//* -------------------------------------- ISPSLIB(SQUASH) */
//SQUASH   EXEC PGM=IEBCOPY
//SYSPRINT  DD SYSOUT=*
//SYSUT3    DD UNIT=SYSDA,SPACE=(80,(60,45))
//SYSUT4    DD UNIT=SYSDA,SPACE=(256,(15,1)),DCB=KEYLEN=8
//SYSIN     DD *
     COPY  OUTDD=INOUT,INDD=INOUT
//INOUT     DD DISP=SHR,DSN=&DSN
*/
