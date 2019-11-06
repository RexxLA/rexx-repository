/* REXX    PLIMSGS    adds error messages in-line with the compiler
                      listing.
 
           Written by Frank Clarke 20010307
 
     Modification History
     20010717 fxc don't sort if only 1 token;
 
*/
address ISREDIT
"MACRO (opts)"
"RESET"
 
address ISPEXEC "CONTROL ERRORS RETURN"
call A_INIT                            /*                           -*/
$z = Trace(tv)                         /* activate TRACE, maybe      */
 
call B_COLLECT_REFS                    /*                           -*/
if sw.0BuildLog then,
   call ZB_SAVELOG                     /*                           -*/
 
exit                                   /*@ PLIMSGS                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   address ISREDIT
 
   monitor = "0"
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm,
                     as_invokt  cmd_env  addr_spc  usr_tokn
 
   tk_globalvars = "exec_name   sw.  monitor "
   call AS_SETUP_LOG                   /*                           -*/
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm,
                     as_invokt  cmd_env  addr_spc  usr_tokn
 
   parse value "" with,
         msgid.  msgid   sev  stmt#  msgtxt  stmts.  msg. ,
         .
 
   parse value "0 0 0 0 0 0 0 0 0 0 0 0 0 0" with,
         sw. ,
         .
 
   push opts; pull opts; opts = Strip(opts,"T",")")
   parse var opts "TRACE" tv .
   parse value tv "O" with tv .        /* guarantee a value          */
 
   sw.0DropLink = Wordpos("NOLINK",opts) > 0
   sw.0BuildLog = Wordpos("LOG",opts) > 0
   monitor      = Wordpos("MONITOR",opts) > 0
   IgnoreList   = " IEL0239I IEL0533I IEL0541I IEL0916I ",
                  " IEL0671I IEL0885I IEL0892I IEL0919I"
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AS_SETUP_LOG:                          /*@                           */
   address TSO
 
   parse value "0" with,
               log#    log.
   parse value Date("S")  Time("S")  Time("N")  with,
               yyyymmdd   sssss      hhmmss  .
   parse var yyyymmdd  4 yrdigit 5 mm 7 dd          /* 9 12 14 maybe */
   if Pos(yrdigit,"13579") > 0 then mm = mm + 12       /* mm=24      */
   logtag = Substr("ABCDEFGHIJKLMNOPQRSTUVWX",mm,1)    /* logtag=X   */
   subid  = logtag""dd""Right(sssss,5,0)               /* X1423722 ? */
   vb4k.0    = "NEW CATALOG UNIT(SYSDA) SPACE(1 5) TRACKS",
               "RECFM(V B) LRECL(4096) BLKSIZE(0)"
   vb4k.1    = "SHR"                   /* if it already exists...    */
   logdsn = "@@LOG."exec_name"."subid".LIST"
 
   call ZL_LOGMSG("Log started by" Userid()  yyyymmdd  hhmmss)
   call ZL_LOGMSG("Arg:" argline)
 
return                                 /*@ AS_SETUP_LOG              */
/*
.  ----------------------------------------------------------------- */
B_COLLECT_REFS:                        /*@                           */
   address ISREDIT
 
   call BA_DELIMIT_SECTIONS            /*                           -*/
 
   call BB_FIND_MESSAGES               /*                           -*/
 
   call BP_POST_MESSAGES               /*                           -*/
 
return                                 /*@ B_COLLECT_REFS            */
/*
   Find the Start-of-Source and label it (.SS), End-of-Source (.ES),
   Start-of-Messages (.SM) and End-of-Messages (.EM)
.  ----------------------------------------------------------------- */
BA_DELIMIT_SECTIONS:                   /*@                           */
   address ISREDIT
 
   "CAPS OFF"
   "F 2 'COMPILER DIAGNOSTIC' FIRST "  /* end of xref section        */
   if rc > 0 then do
      "F 2 'NO MESSAGES PRODUCED' FIRST " /* end of xref section     */
      if rc > 0 then do
         helpmsg = "Couldn't find the Diagnostic Messages",
                   "section. Is this a PL/I compiler listing?"
         call HELP
         end
      else do; zerrsm = "No messages"
         zerrlm = "No messages to insert -- clean compile."
         address ISPEXEC "SETMSG MSG(ISRZ001)"
         exit
         end
      end
   "LABEL .zcsr = .SM "                /* start of messages          */
   "(sm#) = LINENUM .zcsr"             /* save the line #            */
   call ZL_LOGMSG("Messages start at" sm#)
 
   "F 'END OF COMPILER ' 2"
   if rc = 0 then do
      "LABEL .zcsr = .EM "             /*   end of messages          */
      "(em#) = LINENUM .zcsr"          /* save the line #            */
      "F '1'     1"
      if rc = 0 & sw.0DropLink then do
         "X ALL .zcsr .zl"
         "DELETE ALL X       .zcsr .zl"
         end
      end
   call ZL_LOGMSG("Messages end at" em#)
 
   "F FIRST 'ATTRIBUTES AND REFERENCES'" /* start of xref section    */
   if rc > 0 then do
      helpmsg = "Couldn't find the Attribute and Cross-reference",
                "section. Is this a PL/I compiler listing?"
      call HELP
      end
   "LABEL .zcsr = .ES "                /* end of source statements   */
   "(es#) = LINENUM .zcsr"             /* save the line #            */
   call ZL_LOGMSG("Source ends at" es#)
 
   "F FIRST 'SOURCE LISTING'"          /* after preprocessor source  */
   if rc > 0 then do
      helpmsg = "Couldn't find the actual source listing. ",
                "Is this a PL/I compiler listing?"
      call HELP
      end
   "LABEL .zcsr = .SS "                /* start of source statements */
   "(ss#) = LINENUM .zcsr"             /* save the line #            */
   call ZL_LOGMSG("Source starts at" ss#)
 
return                                 /*@ BA_DELIMIT_SECTIONS       */
/*
   Locate the messages between .SM and .EM
   The position of "L" in "ERROR ID L" is the location of the severity
       indicator which must be S, E, W, or I
   The position of "MESS" in "MESSAGE DESCR" is the location of the
       message text which may continue onto following lines
   Parse out <msgid>, <severity>, <affected statements>, and <message
       text> (possibly continued)
   Ignore any <msgid>s in <ignorelist>
   Ignore any <msgid>s affecting only stmt# 1
   Save unique MSGIDs in <MSGID.0>
   Save unique affected statements in <STMTS.msgid>
   Save msgid, severity, and text as <MSG.msgid.stmt#>.
.  ----------------------------------------------------------------- */
BB_FIND_MESSAGES:                      /*@                           */
   address ISREDIT
 
   "LOCATE .sm"
   "F 'ERROR ID L '"
   "(text) = LINE .zcsr"
   sev_pos = Pos("L",text)       - 1
   txt_pos = Pos("MESSAG",text)  - 1
   stm_pos = Pos("STMT",text)    - 1
 
   msg = ""                            /* init                       */
   do bbx = em# to sm# by -1           /* diagnostic messages        */
      "(text) = LINE" bbx
      parse var text cc 2 text         /* snip off cc                */
      if text = ""  then iterate
      if cc   = "1" then iterate
      if Left(text,11) = "ERROR ID L " then iterate
      if Left(text,21) = "" then do    /* continued line             */
         text  = Strip(text)
         msg   = text || " " || msg    /* prepend                    */
         iterate
         end                           /* continued line             */
 
      if Datatype(Substr(text,stm_pos,1),"N") then do    /* new stmt */
         parse var  text    msgid  sev  text
         if Wordpos(msgid,IgnoreList) > 0 then do
            msg = ""                   /* collected text             */
            iterate
            end
 
         if Wordpos(msgid,msgid.0) = 0 then,
            msgid.0 = msgid.0 msgid
 
         text = Strip(text)
         text  = text msg              /* splice ahead               */
 
         templist = ""                 /* init                       */
         do while text <> ""
            parse var text stmt# text
            if Right(stmt#,1) = "," then do
               stmt#    = Strip(stmt#,"T",",")
               if Wordpos(stmt#,templist) = 0 then,
                  templist    = templist    stmt#   /* attach        */
               end
            else do                    /* no trailing comma          */
               if Wordpos(stmt#,templist) = 0 then,
                  templist    = templist    stmt#   /* attach        */
               msgtext  = text; text = ""   /* shut down loop        */
               end                     /* no trailing comma          */
         end                           /* while text not empty       */
 
         /* <msgtext> now contains the actual message                */
         if "1" = Strip(STMTS.msgid) then do
            parse value "" with STMTS.msgid msg text msgtext
            delpos = Wordpos(msgid,MSGID.0)
            if delpos <> 0 then,
               MSGID.0 = Delword(MSGID.0,delpos,1)
            else say "DELPOS was zero for" msgid
            iterate
            end
 
         call BBZ_STORE_MSGTEXT        /*                           -*/
 
         end                           /* new stmt                   */
   end                                 /* bbx bottom up              */
 
return                                 /*@ BB_FIND_MESSAGES          */
/*
.  ----------------------------------------------------------------- */
BBZ_STORE_MSGTEXT:                     /*@                           */
   address TSO
 
   do bbz    = 1 to Words(templist)
      stmt#   =      Word(templist,bbz)
      key     = Space(msgid"."stmt#,0)
      MSG.key = Strip(msgid) Strip(sev) Strip(msgtext)
      MSG.key = Left(MSG.key,69)"..."
      call ZL_LOGMSG("MSG."key "=" msg.key)
   end                                 /* bbz                        */
   STMTS.msgid = STMTS.msgid templist  /* save statement numbers     */
 
return                                 /*@ BBZ_STORE_MSGTEXT         */
/*
   For each msgid in MSGID.0, acquire STMTS.msgid
   For each stmt# in STMTS.msgid,
       - find the statement between .SS and .ES
       - load MSG.msgid.stmt# as LINE_BEFORE
.  ----------------------------------------------------------------- */
BP_POST_MESSAGES:                      /*@                           */
   address ISREDIT
 
   do bpa = 1 to Words(MSGID.0)        /* each MSGID                 */
      msgid = Word(MSGID.0,bpa)        /* isolate msgid              */
 
      if Words(STMTS.msgid) > 1 then,
         STMTS.msgid = STRSORT(STMTS.msgid)   /* sort the stmt#'s    */
      seq = "FIRST"
      do bpb = 1 to Words(STMTS.msgid) /* each affected statement    */
         stmt# = Word(STMTS.msgid,bpb) /* isolate statement number   */
 
         "F WORD '"stmt#"' .SS .ES 1 20" seq /* locate the statement */
         key      = Space(msgid"."stmt#,0)
         msgtext  = " "MSG.key
         "LINE_BEFORE .zcsr = NOTELINE (msgtext)"
         seq = "NEXT"
      end                              /* bpb                        */
 
   end                                 /* bpa                        */
 
   "L FIRST SPECIAL"
   zcmd = "&L NEXT SPECIAL"
 
return                                 /*@ BP_POST_MESSAGES          */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
   address TSO
 
   say helpmsg
 
exit                                   /*@ HELP                      */
/*
.  ----------------------------------------------------------------- */
ZB_SAVELOG:                            /*@                           */
   address TSO
 
   if Symbol("LOG#") = "LIT" then return          /* not yet set     */
 
   "ALLOC FI($LOG) DA("logdsn") REU" vb4k.0
   "EXECIO" log# "DISKW $LOG (STEM LOG. FINIS"
   "FREE  FI($LOG)"
 
return                                 /*@ ZB_SAVELOG                */
/*
.  ----------------------------------------------------------------- */
ZL_LOGMSG: Procedure expose,           /*@                           */
   (tk_globalvars)  log. log#
   rc = Trace("O")
   address TSO
 
   parse arg msgtext
   parse value  log#+1  msgtext     with,
                zz      log.zz    1  log#   .
 
   if monitor then say,
      msgtext
 
return                                 /*@ ZL_LOGMSG                 */
