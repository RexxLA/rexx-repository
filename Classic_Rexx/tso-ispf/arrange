/* REXX    ARRANGE    A routine to demonstrate the technique for
                      adding entries to a table in a random sequence
                      and maintaining that sequence throughout
                      processing.  The sequence number may be a
                      fractional decimal number and will cause the new
                      line to be inserted in the proper order as
                      specified by the sequence.  Command REORDER will
                      cause the table to be resequenced and remain in
                      the original order.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke 20010507
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     ccyymmdd xxx .....
                  ....
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
"CONTROL ERRORS RETURN"
 
call A_INIT                            /*                           -*/
call B_TABLE_OPS                       /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ ARRANGE                   */
/*
   Initialization
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call DEIMBED                        /*                           -*/
 
return                                 /*@ A_INIT                    */
/*
   Mainline for ISPEXEC table operations.
.  ----------------------------------------------------------------- */
B_TABLE_OPS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BA_OPEN                        /*                           -*/
   call BB_LIBDEF_INIT                 /*                           -*/
   call BD_DISPLAY                     /*                           -*/
   call BX_LIBDEF_DROP                 /*                           -*/
   call BZ_CLOSE                       /*                           -*/
 
return                                 /*@ B_TABLE_OPS               */
/*
   Open the table; build anew if necessary.
.  ----------------------------------------------------------------- */
BA_OPEN:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBSTATS" $tn$ "STATUS1(s1) STATUS2(s2)"
   if s1 > 1 then do
      "TBCREATE" $tn$ "KEYS(POSITION) NAMES(DSNAME) NOWRITE REPLACE"
      "TBSORT"   $tn$ "FIELDS(POSITION,N,A)"
      end; else,
   if s2 = 1 then do
      "TBOPEN "   $tn$   openmode.noupdt
      end
   else "TBTOP" $tn$
 
return                                 /*@ BA_OPEN                   */
/*
   LIBDEF the embedded components.
.  ----------------------------------------------------------------- */
BB_LIBDEF_INIT:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ BB_LIBDEF_INIT            */
/*
   Display the table.
.  ----------------------------------------------------------------- */
BD_DISPLAY:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   do forever
      "TBTOP" $tn$
      "TBDISPL" $tn$ "PANEL(ARRNG01)"
      if rc > 4 then leave             /* PF3 ?                      */
 
      call BDA_ZCMD                    /*                           -*/
      call BDB_ADDNEW                  /*                           -*/
 
      call BDC_ZTDSELS                 /*                           -*/
   end                                 /* forever                    */
 
return                                 /*@ BD_DISPLAY                */
/*
   Process tha ZCMD field.
.  ----------------------------------------------------------------- */
BDA_ZCMD:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if zcmd <> "" then do
      if zcmd = "REORDER" then do      /* resequence table           */
         "TBTOP" $tn$
 
         address TSO "NEWSTACK"        /* isolate a queue            */
 
         do forever
            "TBSKIP" $tn$              /* next row                   */
            if rc > 0 then leave       /* no more rows               */
            queue dsname               /*                            */
            "TBDELETE" $tn$            /* lose this row              */
         end                           /* forever                    */
 
         /* The table should be empty and the queue should have all
            the datasetnames from the table in the proper order      */
 
         position = 1.0
         do queued()                   /* each datasetname           */
            pull dsname
            "TBADD" $tn$
            position = position + 1.0
         end                           /* queued                     */
 
         address TSO "DELSTACK"        /* restore the queue          */
 
         end                           /* REORDER                    */
      end
 
return                                 /*@ BDA_ZCMD                  */
/*
   Add a new row.
.  ----------------------------------------------------------------- */
BDB_ADDNEW:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if newpos <> "" then,
      if newds <> "" then do
         position = newpos
         dsname      = newds
         if Sysdsn(dsname) = "OK" then do
            "TBMOD" $tn$ "ORDER"
            parse value "" with newpos newds
            end
         else do
            zerrsm = "Oops!"
            zerrlm = "DSN" dsname "is invalid.  Not added."
            "SETMSG MSG(ISRZ002)"
            iterate
            end                        /* Bad DSN                    */
         end
 
return                                 /*@ BDB_ADDNEW                */
/*
   Process individual row selections.
.  ----------------------------------------------------------------- */
BDC_ZTDSELS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   do ztdsels
      select
         when action = "D" then do     /* Delete                     */
            "TBDELETE" $tn$
            end
         otherwise "TBMOD" $tn$
      end                              /* Select                     */
      if ztdsels = 1 then,             /* never do the last one      */
         ztdsels = 0
      else "TBDISPL" $tn$              /* next row                  #*/
   end                                 /* ztdsels                    */
   action = ''                         /* clear for re-display       */
 
return                                 /*@ BDC_ZTDSELS               */
/*
   Detach the LIBDEFed material.
.  ----------------------------------------------------------------- */
BX_LIBDEF_DROP:                        /*@                           */
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
 
return                                 /*@ BX_LIBDEF_DROP            */
/*
   Close the table.  Since this table was defined NOWRITE, it is
   discarded after use.
.  ----------------------------------------------------------------- */
BZ_CLOSE:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBEND" $tn$
 
return                                 /*@ BZ_CLOSE                  */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   parse value KEYWD("USETBL")  "ARNG00"   with,
               $tn$    .
 
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
             /* The following template may be used to
                customize HELP-text for this routine.
say "  "ex_nam"      ........                                          "
say "                ........                                          "
say "                                                                  "
say "  Syntax:   "ex_nam"  ..........                                  "
say "                      ..........                                  "
say "                                                                  "
say "            ....      ..........                                  "
say "                      ..........                                  "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                              "
say "                                                                  "
say "        MONITOR:  displays key information throughout processing. "
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
                                                                    .*/
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*  REXXSKEL back-end removed for space  */
/*          Panel definitions follow
)))plib arrng01
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) caps(on)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON) just(right)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(บบ)
%บ-บ The Lone Arranger - TEST +บ-บ
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT
+  -- D=Delete  or specify new Position: ===>_newpos+ and
+ /                            DSN: ===>_newds
%V    ---Pos-  DSName
)MODEL
_Z+  !position@dsname
)INIT
  .ZVARS = '(action)'
  .HELP = arrngh1
)REINIT
)PROC
)END
)))plib arrngh1
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ)
%TUTORIAL บ-บ The Lone Arranger บ-บ TUTORIAL
%Next Selection ===>_ZCMD
 
+
    This demonstrator program shows how to build (for instance) a
    dataset list adding elements anywhere in the list as it is built.
 
    The list starts out empty and the user adds rows by specifying a
%   sequence number+and a%DSName+(which must be valid).  This DSName
    is inserted to the list in the order implied by the sequence
    number.  If seq# 1 is added followed by seq# 2, adding seq# 1.6
    next will cause that item to be inserted between the other two.
 
    Command%REORDER+causes the sequence numbers to be reset in
    increments of 1.0 but the order of the table remains unchanged.
 
    A%D+next to any row will cause that row to be deleted.
 
    You may change the DSName on any row just by overtyping it.
)PROC
)END
*/
