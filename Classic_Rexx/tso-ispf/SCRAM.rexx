/* REXX   SCRAM    Produce IEBCOPY-flattened versions of PO datasets
                   suitable for downloading to the PC as binary files.
 
                   The name is derived from Nuclear Engineering: to
                   'scram' a reactor is to shut it down as quickly as
                   possible.
 
           Written by  Frank Clarke,  Oldsmar FL
 
     Modification History
     960203 fxc enable LISTIN for alternate SCRAMSET;
                add REXXSKEL;
 
*/
address TSO                            /* REXXSKEL ver.960119        */
arg parms "((" opts                    /*                            */
                                       /*                            */
signal on syntax                       /*                            */
signal on novalue                      /*                            */
                                       /*                            */
call TOOLKIT_INIT                      /* conventional start-up     -*/
if tv ^= "" then rc = trace(tv)        /*                            */
info   = parms                         /* to enable parsing          */
                                       /*                            */
call A_INIT                            /*                           -*/
if Sysdsn(scram_ds) ^= "OK" then exit  /*                            */
rc = Msg('off')                        /*                            */
call B_ALLOC_FILES                     /*                           -*/
call C_SPOOL_DATA                      /*                           -*/
 
/*
call DUMP_QUEUE                        /*                           -*/
*/
exit                                   /*                            */
 
/* ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch  then call BRANCH
   address TSO
 
   parse value  KEYWD("LISTIN") "SCRAMSET" with scram_ds .
   extra      = SWITCH("EXTRA")        /*                            */
   if extra then drive = ""            /*                            */
            else drive = "A:"          /*                            */
   node       = whereami()
   iam        = node"."userid()
 
   alloc.0   = "NEW CATALOG UNIT(SYSDA) SPACE(1) TRACKS RECFM(V B) LRECL(255) BLKSIZE(0)"
   alloc.1   = "SHR"                      /* if it already exists...    */
 
   msg. = "??"                            /*                            */
   msg.0000  = "OK"                       /*                            */
   msg.0005  = "NC"                       /*                            */
   msg.0009  = "MI"                       /*                            */
 
return                                 /*@ A_INIT                    */
 
/* ----------------------------------------------------------------- */
B_ALLOC_FILES:                         /*@                           */
   if branch then call BRANCH
/*
*/
   address TSO
 
   outdsn   = "PULL.BAT"
   ldrc   = Listdsi(outdsn"  nodirectory norecall")
   if msg.sysreason = "MI" then "HDEL" outdsn
   tempstat = Sysdsn(outdsn) = "OK"    /* 1=exists, 0=missing        */
   "ALLOC FI($DRV) DA("outdsn") REU" alloc.tempstat
 
   outdsn   = "SCRAM.BAT"
   ldrc   = Listdsi(outdsn"  nodirectory norecall")
   if msg.sysreason = "MI" then "HDEL" outdsn
   tempstat = Sysdsn(outdsn) = "OK"    /* 1=exists, 0=missing        */
   "ALLOC FI($BAT) DA("outdsn") REU" alloc.tempstat
   push " receive" Left("%1"outdsn,16) Left(drive||outdsn,16) "ascii crlf"
   "EXECIO 1 DISKW $DRV       "
 
   outdsn   = "SCZIP.BAT"
   ldrc   = Listdsi(outdsn"  nodirectory norecall")
   if msg.sysreason = "MI" then "HDEL" outdsn
   tempstat = Sysdsn(outdsn) = "OK"    /* 1=exists, 0=missing        */
   "ALLOC FI($ZIP) DA("outdsn") REU" alloc.tempstat
   push " receive" Left("%1"outdsn,16) Left(drive||outdsn,16) "ascii crlf"
   "EXECIO 1 DISKW $DRV (FINIS"
 
return                                 /*@ B_ALLOC_FILES             */
                                       /*                            */
/* ----------------------------------------------------------------- */
C_SPOOL_DATA:                          /*@                           */
   if branch then call BRANCH
/*
*/
   address TSO
 
   "ALLOC FI($TMP) DA("scram_ds") SHR REU"
   "EXECIO * DISKR $TMP (FINIS"        /*                            */
   if monitor then say queued() "lines in SCRAMSET"
                                       /*                            */
   ignore_rest = '0'                   /*                            */
   do queued()                         /*                            */
      pull input output pcspec .       /*                            */
      if input = "***" then ignore_rest = '1'
      if ignore_rest then iterate      /*                            */
      rc = Outtrap("xx.")
      call SHIPIT   input   output
      rc = Outtrap("off")
      if monitor then say "Converted" input "to" output "rc="xrc
      push " receive" Left(pcspec,16) Left(drive||output,16)
      "EXECIO 1 DISKW $BAT"            /*                            */
      parse var pcspec fn "." ft       /*                            */
      push " pkzip" Left("%1"fn".ZIP",16) Left(pcspec,16)
      "EXECIO 1 DISKW $ZIP"            /*                            */
   end                                 /* queued                     */
   "EXECIO 0 DISKW $BAT (FINIS"        /*                            */
   "EXECIO 0 DISKW $ZIP (FINIS"        /*                            */
   if node ^= "TPA" then do            /*                            */
      rc = Outtrap('xmit.')            /*                            */
      "XMIT  TPA."Userid() "DSNAME(PULL.BAT)  NOL NOP NOE SEQ NON sysout(w)"
      "XMIT  TPA."Userid() "DSNAME(SCRAM.BAT) NOL NOP NOE SEQ NON sysout(w)"
      "XMIT  TPA."Userid() "DSNAME(SCZIP.BAT) NOL NOP NOE SEQ NON sysout(w)"
      "FREE  FI($DRV $BAT $ZIP $TMP)"
      rc = Outtrap('off')              /*                            */
      end                              /*                            */
 
return                                 /*@ C_SPOOL_DATA              */
                                       /*                            */
/* ----------------------------------------------------------------- */
SHIPIT:                                /*@                           */
   arg in out                          /*                            */
   "XMIT" iam "DS("in") OUTDATASET("out") nol non nop noe sysout(w)"
   xrc = rc                            /*                            */
   "XMIT  TPA."Userid() "DSN("out") NOL NOP NOE SEQ NON sysout(w)"
   xrc = Max(rc,xrc)
   "DELETE" out                        /*                            */
   xrc = Max(rc,xrc)
return                                 /*@ SHIPIT                    */
                                       /*                            */
/* ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   if branch then call BRANCH          /*                            */
   address TSO                         /*                            */
                                       /*                            */
   monitor   = ^SWITCH("QUIET")        /*                            */
                                       /*                            */
return                                 /*@ LOCAL_PREINIT             */
                                       /*                            */
/* ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"                    /*                            */
if helpmsg ^= "" then do ; say helpmsg; say ""; end
say "  SCRAM         Compress selected libraries and ship off-site for"
say "                safety.  Prepare .BAT files for use by a PC-based"
say "                process to download and ZIP the compressed files."
say "                                                                 "
say "  Syntax:   SCRAM     <LISTIN  alternate-scramset>               "
say "                                                                 "
say "            The format of a scramset-dataset is:                 "
say "                3 columns of data;                               "
say "                1st col: the MVS datasetname to be SCRAMmed      "
say "                2nd col: an intermediate MVS name for the        "
say "                      compressed version                         "
say "                3rd col: the PC filespec                         "
say "            If the first token on any line is a series of three  "
say "            asterisks, processing stops at that line.            "
pull
"CLEAR"
say "   Debugging tools provided include:"
say "                                                                 "
say "        MONITOR:  displays key information throughout processing."
say "                  Displays most paragraph names upon entry."
say "                                                                 "
say "        USEHLQ:   causes dataset prefix to be altered as "
say "                  specified."
say "                                                                 "
say "        NOUPDT:   by-pass all update logic."
say "                                                                 "
say "        BRANCH:   show all paragraph entries."
say "                                                                 "
say "        TRACE tv: will use value following TRACE to place"
say "                  the execution in REXX TRACE Mode."
say "                                                                 "
say "        QUIET:    suppresses in-progress informational messages. "
say "                                                                 "
say "                                                                 "
say "   Debugging tools can be accessed in the following manner:"
say "                                                                 "
say "        TSO" exec_name"  parameters  ((  debug-options"
say "                                                                 "
say "   For example:"
say "                                                                 "
say "        TSO" exec_name " (( MONITOR TRACE ?R"
address ISPEXEC "CONTROL DISPLAY REFRESH" /*                         */
exit                                   /*@ HELP                      */
                                       /*                            */
/* ----------------------------------------------------------------- */
BRANCH: Procedure expose,              /*@                           */
        sigl exec_name                 /*                            */
   arg brparm .                        /*                            */
                                       /*                            */
   $a#y = sigl                         /* where was I called from ?  */
   do $b#x = $a#y to 1 by -1           /* inch backward to label     */
      if Right(Word(Sourceline($b#x),1),1) = ":" then do
         parse value sourceline($b#x) with $l#n ":" . /* Paragraph   */
         leave ; end                   /*                name        */
   end                                 /* $b#x                       */
                                       /*                            */
   select                              /*                            */
      when brparm = "NAME" then return($l#n) /* Return full name     */
      when brparm = "ID"      then do  /*        Return prefix       */
         parse var $l#n $l#n "_" .     /* get the prefix             */
         return($l#n)                  /*                            */
         end                           /* brparm = "ID"              */
      otherwise                        /*                            */
         say left($l#n,45) exec_name "Time:" time("L")
   end                                 /* select                     */
                                       /*                            */
return                                 /*@ BRANCH                    */
                                       /*                            */
/* ----------------------------------------------------------------- */
DUMP_QUEUE:                            /*@ Take whatever is in stack */
                                       /*  and write to the screen   */
   if branch then call BRANCH          /*                            */
                                       /*                            */
   do queued();pull line;say line;end  /*                            */
                                       /*                            */
return                                 /*@ DUMP_QUEUE                */
                                       /*                            */
/* ----------------------------------------------------------------- */
KEYWD: Procedure expose info           /*@ hide all vars, except info*/
   arg kw                              /*                            */
   kw_pos = wordpos(kw,info)           /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   kw_val = word(info,kw_pos+1)        /* get the next word          */
   info   = Delword(info,kw_pos,2)     /* remove both                */
return kw_val                          /*@ KEYWD                     */
                                       /*                            */
/* ----------------------------------------------------------------- */
KEYPHRS: Procedure expose,             /*@                           */
         info helpmsg exec_name        /*  except these three        */
   arg kp                              /*                            */
   parse var info front (kp) del_val rest
   if del_val = "" then return ""      /* find where it starts, maybe*/
   if LENGTH(del_val) ^= 2 then do     /* ck delimiter length = 2    */
      helpmsg = helpmsg "INVALID LENGTH FOR DELIMITER("del_val") WITH KEYPHRS("kp")"
      call HELP
      end
   del_pos2 = wordpos(del_val,rest)    /* find second delimiter      */
   if del_pos2 = 0 then do             /* ck second delimiter exists */
      helpmsg = helpmsg "NO MATCHING SECOND DELIMITER("del_val") WITH KEYPHRS("kp")"
      call HELP
      end
   parse var rest kp_val (del_val) back
   info = front back                   /*                            */
return kp_val                          /*@ KEYPHRS                   */
                                       /*                            */
/* ----------------------------------------------------------------- */
NOVALUE:                               /*@                           */
   say exec_name "raised NOVALUE at line" sigl
   say " "                             /*                            */
   say "The referenced variable is" condition("D")
   say " "                             /*                            */
   zsigl = sigl                        /*                            */
   signal SHOW_SOURCE                  /*@ NOVALUE                   */
                                       /*                            */
/* ----------------------------------------------------------------- */
SHOW_SOURCE:                           /*@                           */
   if sourceline() ^= "0" then         /*                            */
      say sourceline(zsigl)            /*                            */
   rc =  trace("?R")                   /*                            */
   nop                                 /*                            */
   exit                                /*@ SHOW_SOURCE               */
                                       /*                            */
/* ----------------------------------------------------------------- */
SS: Procedure                          /*@ Show Source               */
   arg ssparms ; parse var ssparms ssbeg ssend .
   if ssend = "" then ssend = 10       /*                            */
   if ^datatype(ssbeg,"W") | ^datatype(ssend,"W") then return
   address tso "CLEAR"                 /*                            */
   ssend = ssbeg + ssend               /*                            */
   do ssii = ssbeg to ssend ; say sourceline(ssii) ; end
   address ISPEXEC "CONTROL DISPLAY REFRESH"
return(0)                              /*@ SS                        */
                                       /*                            */
/* ----------------------------------------------------------------- */
SWITCH: Procedure expose info          /*@                           */
   arg kw                              /*                            */
   sw_val = Wordpos(kw,info) > 0       /* exists = 1; not found = 0  */
   if sw_val then                      /* exists                     */
      info = Delword(info,Wordpos(kw,info),1) /* remove it           */
return sw_val                          /*@ SWITCH                    */
                                       /*                            */
/* ----------------------------------------------------------------- */
SYNTAX:                                /*@                           */
   errormsg = "REXX error" rc "in line" sigl":" errortext(rc)
   say errormsg                        /*                            */
   zsigl = sigl                        /*                            */
   signal SHOW_SOURCE                  /*@ SYNTAX                    */
                                       /*                            */
/* ----------------------------------------------------------------- */
TOOLKIT_INIT:                          /*@                           */
   address TSO                         /*                            */
   info = Strip(opts,"T",")")          /* clip trailing paren        */
                                       /*                            */
   push  ""                            /* initializing value         */
   pull  tv  helpmsg                   /* set empty                  */
                                       /*                            */
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm  as_invokt  cmd_env  addr_spc  usr_tokn
   if Word(parms,1) = "?" then call HELP /* I won't be back          */
                                       /*                            */
   tv      = KEYWD("TRACE")            /*                            */
   trapout = SWITCH("TRAPOUT")         /*                            */
                                       /*                            */
   if trapout then do                  /*                            */
      "TRAPOUT" exec_name parms "(( TRACE R" info
      exit                             /*                            */
      end                              /* trapout                    */
                                       /*                            */
   branch  = SWITCH("BRANCH") ; if branch then call BRANCH /*        */
   monitor = SWITCH("MONITOR")         /*                            */
   noupdt  = SWITCH("NOUPDT")          /*                            */
                                       /*                            */
   rc = outtrap("CVTINFO","1")         /*                            */
       "CVTINFO"                       /*                            */
   rc = outtrap("OFF")                 /*                            */
                                       /*                            */
   parse var cvtinfo1 "NJENODE=" node ./*                            */
                                       /*                            */
   hlq     = KEYWD("USEHLQ")           /*                            */
   hlq.    = "TTGTCBS"                 /*                            */
   hlq.FTW = "TTGYCBS"                 /*                            */
   hlq     = word(hlq hlq.node ,1)     /* default to "production"    */
                                       /*                            */
   sw.          = 0                    /*                            */
   sw.nested    = sysvar("SYSNEST") = "YES"
   sw.batch     = sysvar("SYSENV")  = "BACK"
   sw.inispf    = sysvar("SYSISPF") = "ACTIVE"
                                       /*                            */
   zerrhm   = "ISR00000"               /*                            */
   zerrsm   = "Error-Press PF1"        /*                            */
   zerralrm = "YES"                    /*                            */
                                       /*                            */
   call LOCAL_PREINIT                  /* for more opts             -*/
                                       /*                            */
return                                 /*@ TOOLKIT_INIT              */
                                       /*                            */
