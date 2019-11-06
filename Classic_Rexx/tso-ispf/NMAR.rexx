/* REXX    NMAR       NMR Application Repository.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
                      NMAR uses RXVSAM extensively.  Information about
                      RXVSAM can be obtained from the CBT archives at
                      http://www.cbttape.org.  While the syntax and
                      function of RXVSAM calls is typically
                      self-evident, maintainers are warned that its
                      syntax is rigid and unforgiving.
 
           Written by Frank Clarke 20050129
 
     Impact Analysis
.    ISPLLIB   RXVSAM
.    ISPLLIB   SYSPMON
.    SYSEXEC   FIREHIST
.    SYSEXEC   TRAPOUT
.    (alias)   NMART
 
     Modification History
     20050701 fxc enabled CKOUT and RLSE ;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20040227      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
supported_functions = "QUERY CKOUT RLSE ADD" /* needed for HELP      */
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
call B_MAIN_PROCESS                    /*                           -*/
call ZB_SAVELOG                        /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ NMAR                      */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   thisuser = Userid()
   parse value "" with rxvsam_errormsg ,
               appl.  currver.  obstat. ,
               pattern.   ,            /* patterns for types         */
               applist   patternlist ,
               sel    comp.  vskey
   parse value "0 0 0 0 0 0 0 0 0" with,
               seq.   sw_obs   .
 
   call AA_SETUP_LOG                   /*                           -*/
   call AK_KEYWDS                      /*                           -*/
   if exec_name = "NMART" then do      /* test                       */
      ocompds = "'DTAFXC.@#AR.D01VCMP.KSD.PROD'"
      checkds = "'DTAFXC.@#AR.D01VCHK.KSD.PROD'"
      cleards = "'DTAFXC.@#AR.D20VHIS.PA1.PROD'"
      dirds   = "'DTAFXC.@#AR.D01VDIR.KSD.PROD'"
      end                              /*                            */
   if exec_name = "NMAR"  then do      /* prod                       */
      ocompds = "'ACNV.TS.D822.D01VCMP.KSD.PROD'"
      checkds = "'ACNV.TS.D822.D01VCHK.KSD.PROD'"
      cleards = "'ACNV.TS.D822.D20VHIS.PA1.PROD'"
      dirds   = "'ACNV.TS.D822.D01VDIR.KSD.PROD'"
      end                              /*                            */
   obstext.  = ""
   obstext.1 = "(Obsolete)"
   costat.   = "??"
   costat.1C = "Ckout"
   costat.1D = "Ckout/Susp"
   costat.2C = "Xmit"
   costat.2D = "Xmit/Susp"
 
   tmtag     =      Time("S")
   $tn$      = "$AR"tmtag              /* $AR04385 maybe             */
 
   monparm = "/USER" Userid() "TOOL" exec_name
   "CALL 'NTIN.TS.D822.LIB.ISPLLIB(SYSPMON)'"  "'" monparm"'"
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_SETUP_LOG:                          /*@                           */
   if branch then call BRANCH
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
   logdsn = "@@LOG."exec_name"."subid".#CILIST"
 
   origds = Find_Origin()              /*                           -*/
   locale = BRANCH("ID")
   call ZL_LOGMSG(exec_name "started by" Userid()  yyyymmdd  hhmmss)
   call ZL_LOGMSG( exec_name locale,
                  "Running from" origds)
   call ZL_LOGMSG( exec_name locale,
                  "Arg:" argline)
 
return                                 /*@ AA_SETUP_LOG              */
/*
.  ----------------------------------------------------------------- */
AK_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   if info  = "" then call HELP        /*                           -*/
 
   appl    = KEYWD("APPL")             /* only needed for ADD       -*/
 
   parse var info    func  key
   savkey  = key                       /* retain                     */
   if WordPos(func,supported_functions) = 0 then do
      helpmsg = "Function >"func"< not recognized."
      call HELP                        /* ...and don't come back    -*/
      end
 
return                                 /*@ AK_KEYWDS                 */
/*
   Function to be provided:  Add a new component, Check-out, Query
   History, Release Check-out.  All except 'Query' require 10-char
   (non-generic) keys.  'Add' requires specification of 'APPL'.
.  ----------------------------------------------------------------- */
B_MAIN_PROCESS:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LIBDEF ISPLLIB DATASET ID('NTIN.TS.D822.LIB.ISPLLIB') STACK"
 
   select
      when func = "ADD"   then do
         call BA_ADD                   /* add a new component       -*/
         end                           /* ADD                        */
      when func = "CKOUT" then do
         call BC_CKOUT                 /* check out a component     -*/
         end                           /* CKOUT                      */
      when func = "QUERY" then do
         call BI_INFO                  /* display A/R detail        -*/
         end                           /* QUERY                      */
      when func = "RLSE"  then do
         call BR_RLSE                  /* release check out         -*/
         end                           /* RLSE                       */
      otherwise do                     /*                            */
         end                           /* otherwise                  */
   end                                 /* select                     */
 
   "LIBDEF ISPLLIB"
 
return                                 /*@ B_MAIN_PROCESS            */
/*
   Add a new component.  Each 'key' must be exactly 10 characters
   long.  The last two characters identify the type of component.
.  ----------------------------------------------------------------- */
BA_ADD:                                /*@                           */
   if branch then call BRANCH
   address TSO
   if \sw.0Force &,
      exec_name = "NMAR" then return   /* disabled                   */
 
   if appl = "" then do
      helpmsg = "APPL is required for ADD"
      call HELP                        /* ...and exit               -*/
      end
 
   if patternlist = "" then,           /* not loaded                 */
      call BAA_LOAD_PATTERNS           /* identify type of data     -*/
 
   if WordPos(appl,applist) = 0 then do
      call BAB_CHECK_APPL              /*                           -*/
      if sw.0vdir_not_found then do
         zerrsm = "Appl INCORR"
         zerrlm = exec_name "("BRANCH("ID")")",
                  "Application" appl "is unknown."
         address ISPEXEC "SETMSG MSG(ISRZ002)"
         return
         end
      end
 
   call BAC_LOAD_COMPONENTS            /*                           -*/
 
return                                 /*@ BA_ADD                    */
/*
   The supported components can be found in ACNN.PR.CTLCARD(AD02DA1P).
   Any line there whose first character is a dot contains as its first
   token the pattern for a component-type:
.  (n) dots represent the key-portion;
.  (m) asterisks represent the variable-portion;
.  the last two characters are the component-type.
.  ----------------------------------------------------------------- */
BAA_LOAD_PATTERNS:                     /*@                           */
   if branch then call BRANCH
   address TSO
 
   "ALLOC FI($TMP) DA('ACNN.PR.CTLCARD(AD02DA1P)') SHR REU"
   "NEWSTACK"
   "EXECIO * DISKR $TMP (FINIS"
   "FREE  FI($TMP)"
   do queued()                         /* every row                  */
      pull t1 .                        /* first token                */
      if Left(t1,1) = "." then do
         kl = LastPos(".",t1)          /* last dot is key-length     */
         vl = 8 - kl
         parse var t1 9 type .
         pattern.type = kl vl          /* 6 2, maybe                 */
         patternlist = patternlist type
         end
   end                                 /* queued                     */
   "DELSTACK"
 
return                                 /*@ BAA_LOAD_PATTERNS         */
/*
   Verify that the supplied application-id is valid.
.  ----------------------------------------------------------------- */
BAB_CHECK_APPL:                        /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.0vdir_not_found = 0
   "ALLOC FI($VS) DA("dirds") SHR REU"
   rxv_rc = RXVSAM("OPENINPUT","$VS","KSDS")
   rxv_rc = RXVSAM('READ','$VS',Left(appl,8),'AD0102')
   if rxv_rc > 0 then,                 /* ...oops                    */
      sw.0vdir_not_found = 1
   else do
      applist = applist appl
      call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                  "DIR:" AD0102 )
      end
   rxv_rc = RXVSAM("CLOSE","$VS")
   "FREE  FI($VS)"
 
return                                 /*@ BAB_CHECK_APPL            */
/*
   Load the new key to the Component file.
.  ----------------------------------------------------------------- */
BAC_LOAD_COMPONENTS:                   /*@                           */
   if branch then call BRANCH
   address TSO
 
   zerrlm = ""
   "ALLOC FI($VS) DA("ocompds") SHR REU"
   rxv_rc = RXVSAM("OPENOUTPUT","$VS","KSDS")
   parse value "0 0" with ok_ct ng_ct
   do Words(key)                       /* each key                   */
      parse var key  thiskey key       /* isolate 10-char key        */
      if Length(thiskey) <> 10 then do
         zerrlm = zerrlm";" thiskey "length not 10"
         iterate
         end
      if Pos("*",thiskey) > 0 then do
         zerrlm = zerrlm";" thiskey "refused - generic key"
         iterate
         end                           /* thiskey contains stars     */
 
      parse var thiskey 9 suff .
      if pattern.suff = "" then do
         zerrlm = zerrlm";" suff "not supported"
         iterate
         end
 
      parse var pattern.suff  kl vl .
      component = Left(thiskey,kl)Copies("*",vl)suff
      ad0104 = Left(appl,8) ||,
               component    ||,
               thiskey      ||,
               x2c(00)      ||,
               Copies(" ",25)
      rxv_rc = RXVSAM('WRITE','$VS',component,'AD0104')
      if rxv_rc <> 0 then do
         ng_ct = ng_ct + 1
         zerrlm = zerrlm";" component "not written, RC="rxv_rc
         end
      else do
         ok_ct = ok_ct + 1
         zerrlm = zerrlm";" component "written."
         end
   end                                 /* key                        */
   rxv_rc = RXVSAM("CLOSE","$VS")
   "FREE  FI($VS)"
 
   address ISPEXEC
   zerrsm = "OK="ok_ct " NG="ng_ct
   zerrlm = Space(Strip(zerrlm,,";"),1)
   "SETMSG  MSG(ISRZ002)"
 
return                                 /*@ BAC_LOAD_COMPONENTS       */
/*
.  Read VCMP to find the base-component.
.  Read VCHK to acquire current data (if any).  If key-not-found,
   build a new record.
.  Update VCHK to show component checked-out:
.    (a) #_OF_USERS +1 (but not >5) and convert to 2-byte binary;
.    (b) if necessary, purge oldest block
.    (c) add a new CHECKOUT block with STATUS = '1C'x
   A user may have no more than one active check-out for a component.
.  ----------------------------------------------------------------- */
BC_CKOUT:                              /*@                           */
   if branch then call BRANCH
   address TSO
/* if \sw.0Force &,
      exec_name = "NMAR" then return      disabled                   */
 
   if patternlist = "" then,           /* not loaded                 */
      call BAA_LOAD_PATTERNS           /* identify type of data     -*/
 
   do Words(key)                       /* each key                   */
      parse var key  thiskey key       /* isolate A/R component name */
      if Length(thiskey) <> 10 then do
         zerrlm = zerrlm";" thiskey "length not 10"
         iterate
         end
      if Pos("*",thiskey) > 0 then do
         zerrlm = zerrlm";" thiskey "refused - generic key"
         iterate
         end                           /* thiskey contains stars     */
 
      parse var thiskey 9 suff .
      if pattern.suff = "" then do
         zerrlm = zerrlm";" suff "not supported"
         iterate
         end
 
      parse var pattern.suff  kl vl .
      component = Left(thiskey,kl)Copies("*",vl)suff
      call BCA_READ_VCMP               /* Owned components          -*/
                                    if sw.0error_found then return
      call BCC_READ_VCHK               /* Get Checkout record       -*/
 
      call BCD_UPDATE_CKOUT            /* Load new data and write   -*/
   end                                 /* key                        */
 
return                                 /*@ BC_CKOUT                  */
/*
   Pick up AD0104 (Component)
.  ----------------------------------------------------------------- */
BCA_READ_VCMP:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.0vcmp_not_found = 0
   "ALLOC FI($VS) DA("ocompds") SHR REU"
   rxv_rc = RXVSAM("OPENINPUT","$VS","KSDS")
   rxv_rc = RXVSAM('READ','$VS',component,'AD0104')
   if rxv_rc > 0 then do               /* ...oops                    */
      sw.0vcmp_not_found = 1
      sw.0error_found = 1
      end
   else do
      parse var ad0104  appl 9 component 19 currver 29 bits 30
      call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                  "CMP:" ad0104 )
      bits      = X2B(C2X(bits))
      sw_obs    = Left(bits,1)
      comp.thiskey      = component
      appl.component    = appl
      currver.component = currver
      obstat.component  = obstext.sw_obs
      end
   rxv_rc = RXVSAM("CLOSE","$VS")
   "FREE  FI($VS)"
 
   if sw.0vcmp_not_found then do
      address ISPEXEC
      zerrsm = "No Component"
      zerrlm = "Component" thiskey "not found"
      "SETMSG  MSG(ISRZ002)"
      end
 
return                                 /*@ BCA_READ_VCMP             */
/*
   Part I of two parts: read the existing check-out record (AD0106),
   if any.  Caller will set 'thiskey', length 10.
.  ----------------------------------------------------------------- */
BCC_READ_VCHK:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   "ALLOC FI($VS) DA("checkds") SHR REU"
   rxv_rc = RXVSAM("OPENIO","$VS","KSDS")
   rxv_rc = RXVSAM('READ','$VS',thiskey,'AD0106')
   if rxv_rc > 0 then,                 /* ...oops                    */
      sw.0key_not_found  = 1
   else,
      call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                  "CHK:" ad0106 )
 
return                                 /*@ BCC_READ_VCHK             */
/*
   Part II of two parts: (re-)construct the AD0106 record and
   (RE)WRITE it to the VSAM file.  This was split from the READ to
   make the process clearer.
.  ----------------------------------------------------------------- */
BCD_UPDATE_CKOUT:                      /*@                           */
   if branch then call BRANCH
   address TSO
 
   if sw.0key_not_found then do        /* build block #1             */
      ardate = Date("S")
      argrp  = component               /* component with *'s         */
      arfile = "CHK"
      currver = currver.component      /* from VCMP                  */
      artext = "U="thisuser "CO="currver "ST="costat.1C
      parse value seq.arfile+1   with ,
                   arseq . 1 seq.arfile .
      blk1   = Left(thisuser, 8)  || ,
               Left(ardate  , 8)  || ,
               Left(currver ,10)  || , /* from VCMP                  */
               Left(' '     ,10)  || , /* Transmit name              */
               x2c(1C)                 /* checked out                */
      ad0106 = Left(argrp   ,10)  || ,
               X2C(0001)          || , /* 2-byte binary              */
               blk1                    /* 37 bytes                   */
      if noupdt = 0 then,
         rxv_rc = RXVSAM("WRITE","$VS",argrp,"AD0106")
      else say,
                 'RXVSAM("WRITE","$VS",'argrp'"AD0106")'
      call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                  "WRITE CHK" ad0106 )
      end                              /* WRITE                      */
   else do                             /* key was found              */
      parse var ad0106  component 11 userct 13 blk1,
                                           +37 blk2,
                                           +37 blk3,
                                           +37 blk4,
                                           +37 blk5
      userct = c2x(userct) + 0         /* how many blocks ?          */
      call BCDA_VERIFY_USER            /*                           -*/
      if sw.0Already_checked_out = 0 then do
         if userct = 5 then do         /* aready at max              */
            call BCDB_PURGE_BLK1       /* delete table row          -*/
            blk1 = blk2                /* shift everything down      */
            blk2 = blk3
            blk3 = blk4
            blk4 = blk5
            call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                  "Block #1 purged")
            end
         else do
            userct = userct + 1
            end
         ardate = Date("S")
         argrp  = component            /* component with *'s         */
         arfile = "CHK"
         coname = currver.component    /* from VCMP                  */
         artext = "U="thisuser "CO="coname "ST="costat.1C
         parse value seq.arfile+1   with ,
                  arseq . 1 seq.arfile .
         new = Left(thisuser, 8)  || ,
               Left(ardate  , 8)  || ,
               Left(coname  ,10)  || ,
               Left(' '     ,10)  || ,
               x2c(1C)                 /* checked out                */
         $rc = Value('blk'userct,new)  /* load blk#                  */
         userct = x2c(Right(userct,4,0)) /* 2-byte binary            */
         ad0106 = thiskey   || userct || ,
                  blk1 || blk2 || blk3 || blk4 || blk5
 
         if noupdt = 0 then,
            rxv_rc = RXVSAM("REWRITE","$VS",component,"AD0106")
         else say,
                    'RXVSAM("REWRITE","$VS",'component'"AD0106") '
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                  "REWRITE CHK" ad0106 )
         end                           /* not already checked out    */
      end                              /* REWRITE                    */
   rxv_rc = RXVSAM("CLOSE","$VS")
   "FREE  FI($VS)"
 
   if func = "QUERY" then do
             /* This was called from the component line on the
                display.    */
      address ISPEXEC
      "TBADD" $tn$ "ORDER"
      zerrsm = "Checked Out"
      zerrlm = exec_name "("BRANCH("ID")")",
               "Component" component ,
               "has been checked out"
      "SETMSG MSG(ISRZ002)"
      call ZL_LOGMSG(zerrlm)
      end
 
return                                 /*@ BCD_UPDATE_CKOUT          */
/*
   Before a user can check out a component, we must verify that the
   user does not have the component checked out already!  blk1 thru
   blk5 may have been populated.  Examine each one to verify that this
   user is not represented there.
.  ----------------------------------------------------------------- */
BCDA_VERIFY_USER:                      /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.0Already_checked_out = 0
   do zx = 1 to userct                 /* each block                 */
      if Left(Value('blk'zx),8) = thisuser then,
         sw.0Already_checked_out = 1
   end                                 /* zx                         */
 
   if sw.0Already_checked_out = 1 then do
      zerrsm = ""
      zerrlm = exec_name "("BRANCH("ID")")",
               "Component" coname "already checked-out by" thisuser
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      end
 
return                                 /*@ BCDA_VERIFY_USER          */
/*
   BLK1 is being overwritten.  Parse BLK1 to obtain the key, READ the
   record, and DELETE the matching row on $tn$.
.  ----------------------------------------------------------------- */
BCDB_PURGE_BLK1:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if func <> "QUERY" then return      /* there is no table          */
   parse var blk1 9 ardate 17
   arfile = "CHK"
   arseq  = 1                          /* base seq for CHK           */
   "TBGET" $tn$ "NOREAD"               /* position the cursor        */
   "TBDELETE" $tn$                     /* poof!                      */
 
return                                 /*@ BCDB_PURGE_BLK1           */
/*
   Display all known info for a specified key: read VCMP to find the
   APPL; read VCHK to acquire checkout records; read VHIS to locate
   clearance records; store by date and activity.
   The key supplied may be generic.
.  ----------------------------------------------------------------- */
BI_INFO:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBCREATE" $tn$ "KEYS(ARDATE ARFILE ARSEQ)",
                "NAMES(ARTEXT ARGRP)",
                "NOWRITE REPLACE"
 
   call BIA_PROLOG                     /* extract ISPF assets       -*/
   call BIB_CMP                        /* Owned components          -*/
   call BID_CHK                        /* Checkout data             -*/
   if sw.0NoHist = 0 then,
      call BIE_HIS                     /* Clearance history         -*/
 
   call BIF_SHOW_TABLE                 /* Display collected info    -*/
 
   "TBEND" $tn$
   call BIZ_EPILOG                     /* drop LIBDEFs              -*/
 
return                                 /*@ BI_INFO                   */
/*
   Extract ISPF assets and LIBDEF
.  ----------------------------------------------------------------- */
BIA_PROLOG:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call DEIMBED                        /*                           -*/
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd  with  dd ddnlist
      $ddn   = $ddn.dd                 /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"dd "LIBRARY  ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd
 
return                                 /*@ BIA_PROLOG                */
/*
   Owned components: D01VCMP.KSD key is COMPONENT(10)
.  ----------------------------------------------------------------- */
BIB_CMP:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value            "CMP"         with,
                          arfile       ardate
   "ALLOC FI($VS) DA("ocompds") SHR REU"
 
   do Words(key)                       /*                            */
      rxv_rc = RXVSAM("OPENINPUT","$VS","KSDS")
      parse var key   thiskey key      /* isolate                    */
      lkey = Length(thiskey)
      rxv_rc = RXVSAM('READGENERIC','$VS',thiskey,'AD0104')
 
      do while rxv_rc = 0              /*                            */
         parse var ad0104       9 slug      19 .
         if Left(slug,lkey) <> thiskey then leave
 
         parse var ad0104  appl 9 component 19 currver 29 bits 30
         currver.component = currver   /* needed for CHKOUT          */
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                     "CMP:" ad0104 )
         bits    = X2B(C2X(bits))
         sw_obs  = Left(bits,1)
         artext = "APPL="appl "VER="currver obstext.sw_obs
         artext = Space(artext,1)
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" artext )
         argrp  = component
         parse value seq.arfile+1   with ,
                  arseq . 1 seq.arfile .
         address ISPEXEC "TBADD" $tn$
         rxv_rc = RXVSAM('READNEXT','$VS',,'AD0104')
      end                              /* rxv_rc                     */
      rxv_rc = RXVSAM("CLOSE","$VS")
   end                                 /* key                        */
   "FREE  FI($VS)"
 
return                                 /*@ BIB_CMP                   */
/*
   Checkout data: D01VCHK.KSD key is COMPONENT(10)
.  ----------------------------------------------------------------- */
BID_CHK:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   key = savkey                        /* reload key from saved copy */
   parse value "00000000  CHK        "    with,
                ardate    arfile  .
   "ALLOC FI($VS) DA("checkds") SHR REU"
   rxv_rc = RXVSAM("OPENINPUT","$VS","KSDS")
 
   do Words(key)                       /*                            */
      parse var key   thiskey key      /* isolate                    */
      lkey = Length(thiskey)
      rxv_rc = RXVSAM('READGENERIC','$VS',thiskey,'AD0106')
 
      do while rxv_rc = 0              /*                            */
         parse var ad0106  slug      11 .
         if Left(slug,lkey) <> thiskey then leave
 
         parse var ad0106  component 11 userct 13 co_data
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                     "CHK:" ad0106 )
         argrp  = component
         userct = C2D(userct)
         do cx = 1 to userct           /* each block is 37 bytes     */
            parse var co_data  couser 9 ardate 17 coname,
                                     27 trname 37 decstat 38 co_data
            stat =  C2X(decstat)       /* 1C, 2C, 1D, or 2D          */
            state = costat.stat        /* Ckout or Xmit              */
            artext = "U="couser "CO="coname
            if trname <> "" then artext = artext "TR="trname
            artext = artext "ST="state
            artext = Space(artext,1)
            call ZL_LOGMSG( exec_name "("BRANCH("ID")")" artext )
            parse value seq.arfile+1   with ,
                         arseq . 1 seq.arfile .
            address ISPEXEC "TBADD" $tn$
         end                           /* cx                         */
         rxv_rc = RXVSAM('READNEXT','$VS',,'AD0106')
      end                              /* rxv_rc                     */
   end                                 /* key                        */
   rxv_rc = RXVSAM("CLOSE","$VS")
   "FREE  FI($VS)"
 
return                                 /*@ BID_CHK                   */
/*
   History data: D20VHIS.PA1 key is COMPONENT(10)
.  ----------------------------------------------------------------- */
BIE_HIS:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   key = savkey                        /* reload key from saved copy */
   parse value " 00000000  HIS         "    with,
                ardate    arfile   .
   "ALLOC FI($VS) DA("cleards") SHR REU"
   rxv_rc = RXVSAM("OPENINPUT","$VS","KSDS")
 
   do Words(key)                       /*                            */
      parse var key   thiskey key      /* isolate                    */
      lkey = Length(thiskey)
      rxv_rc = RXVSAM('READGENERIC','$VS',thiskey,'AD2002')
 
      do while rxv_rc = 0              /*                            */
         parse var ad2002  slug  11
         if Left(slug,lkey) <> thiskey then leave
 
         parse var ad2002  component 11 ,
                         hcodate 19 hcouser 27 hconame 37 htrname 47 ,
                         clrdate 55 clruser 63 clrname 73 obsname
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                     "HIS:" ad2002 )
         argrp  = component
         ardate = hcodate
         artext = "C/O" Strip(hconame) "by" Strip(hcouser) ,
                  "Xmit as" htrname
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" artext )
         parse value seq.arfile+1   with ,
                      arseq . 1 seq.arfile .
         address ISPEXEC "TBADD" $tn$
 
         ardate = clrdate
         artext ="CLR" Strip(clrname) "by" Strip(clruser)
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" artext )
         parse value seq.arfile+1   with ,
                      arseq   1 seq.arfile
         address ISPEXEC "TBADD" $tn$
 
         rxv_rc = RXVSAM('READNEXT','$VS',,'AD2002')
      end                              /* rxv_rc                     */
   end                                 /* key                        */
   rxv_rc = RXVSAM("CLOSE","$VS")
   "FREE  FI($VS)"
 
return                                 /*@ BIE_HIS                   */
/*
   Display the table.  CKOUT is only valid for CMP table rows (ARDATE
   is empty).  RLSE is only valid on CHK rows where the user (U=) is
   the active caller.
.  ----------------------------------------------------------------- */
BIF_SHOW_TABLE:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "VGET ZSCREEND"                     /* screen rows                */
   "TBSORT" $tn$ "FIELDS(ARGRP,C,A ARDATE,C,A ARSEQ,C,A)"
   do forever
      zerrsm = "" ; zerrlm = ""
      "TBQUERY" $tn$ "ROWNUM(ROWCT)"   /* table rows                 */
      if rowct < zscreend then,        /* leave big tables as-is     */
         "TBTOP" $tn$
      "TBDISPL" $tn$ "PANEL(ARDISP)"
       if rc > 4 then leave
 
      do ztdsels
         "CONTROL DISPLAY SAVE"
         select
 
            when sel = "F" then do     /* Fetch from FireProtect     */
               fpcomp = Word( Translate(argrp , "" , "*") ,1)
               address TSO "FIREHIST" fpcomp
               end                     /* Fetch from FireProtect     */
 
            when sel = "R" then do     /* Release checkout           */
               if WordPos(arfile,"CHK") = 0 then do
                  zerrsm = ""
                  zerrlm = zerrlm";" argrp":",
                           "R valid only for CHK rows"
                  end
               else,
               if Pos("U="thisuser,artext) = 0 then do
                  zerrsm = "Denied"
                  zerrlm = "You may only RLSE your own checkout."
                  address ISPEXEC "SETMSG MSG(ISRZ002)"
                  call ZL_LOGMSG( exec_name "("BRANCH("ID")")" zerrlm)
                  end
               else do
                  key     = argrp      /* TA4DZ***PR maybe           */
/*                if \sw.0Force &,
                     exec_name = "NMAR" then do
                     zerrsm = "Disabled"
                     zerrlm = exec_name "("BRANCH("ID")")",
                              "The function is not ready for prime time."
                     "SETMSG MSG(ISRZ002)"
                     call ZL_LOGMSG(zerrlm)
                     end
                  else do
  */                 zerrsm = ""
                     zerrlm = exec_name "("BRANCH("ID")")",
                              "Release key" argrp
                     call ZL_LOGMSG(zerrlm)
                     component = key
                     call BR_RLSE      /*                           -*/
/*                   end
  */              end
               end                     /* Release checkout           */
 
            when sel = "U" then do     /* Check-out                  */
               if WordPos(arfile,"CMP") = 0 then do
                  zerrsm = ""
                  zerrlm = zerrlm";" argrp":",
                           "U valid only for CMP rows"
                  call ZL_LOGMSG( exec_name "("BRANCH("ID")")" zerrlm)
                  end                  /*                            */
               else do
                  thiskey = argrp      /* TA4DZ***PR maybe           */
/*                if \sw.0Force &,
                     exec_name = "NMAR" then do
                     zerrsm = "Disabled"
                     zerrlm = exec_name "("BRANCH("ID")")",
                              "The function is not ready for prime time."
                     "SETMSG MSG(ISRZ002)"
                     call ZL_LOGMSG(zerrlm)
                     end
                  else do
*/                   zerrlm = exec_name "("BRANCH("ID")")",
                              "Checkout key" argrp
                     call ZL_LOGMSG(zerrlm)
                     component = thiskey
                     call BCC_READ_VCHK /* Get Checkout record      -*/
                     call BCD_UPDATE_CKOUT /* Load new data and write -*/
/*                   end
  */              end
               end                     /* Check-out                  */
 
            otherwise nop
         end                           /* select                     */
         "CONTROL DISPLAY RESTORE"
         if ztdsels > 1 then "TBDISPL" $tn$
      end                              /* ztdsels                    */
      sel = ""
      if zerrlm <> "" then do
         zerrlm = Space(Strip(zerrlm,,";"),1)
         "SETMSG MSG(ISRZ002)"
         end
   end                                 /* forever                    */
 
return                                 /*@ BIF_SHOW_TABLE            */
/*
   Dismantle all LIBDEFs
.  ----------------------------------------------------------------- */
BIZ_EPILOG:                            /*@                           */
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
 
return                                 /*@ BIZ_EPILOG                */
/*
   Update VCHK to show component no longer checked-out.  If called
   from BI_, func=QUERY.   In that case, ARDATE, ARSEQ and ARFILE (the
   key of the table) will also be set.
   TBGET the row and TBDELETE it.
.  ----------------------------------------------------------------- */
BR_RLSE:                               /*@                           */
   if branch then call BRANCH
   address TSO
/* if \sw.0Force &,
      exec_name = "NMAR" then return      disabled                   */
 
   if patternlist = "" then,           /* not loaded                 */
      call BAA_LOAD_PATTERNS           /* identify type of data     -*/
 
   do Words(key)                       /*                            */
      parse var key   thiskey key      /* isolate                    */
      if Length(thiskey) <> 10 then do
         zerrlm = zerrlm";" thiskey "length not 10"
         iterate
         end
 
      parse var thiskey 9 suff .
      if pattern.suff = "" then do
         zerrlm = zerrlm";" suff "not supported"
         iterate
         end
 
      parse var pattern.suff  kl vl .
      component = Left(thiskey,kl)Copies("*",vl)suff
      /* Open VCHK/Update                                            */
      "ALLOC FI($VS) DA("checkds") SHR REU"
      rxv_rc = RXVSAM("OPENIO","$VS","KSDS")
      /* Read component                                              */
      rxv_rc = RXVSAM('READ','$VS',component,'AD0106')
      if rxv_rc = 0 then do            /* READ was OK                */
         call BRD_DROP_CKOUT           /*                            */
         end                           /* READ was OK                */
      else do
         zerrsm = "READ error"
         zerrlm = exec_name "("BRANCH("ID")")",
                  "RXVSAM ended RC="rxv_rc "for key" thiskey
         address ISPEXEC "SETMSG MSG(ISRZ002)"
         end
      /* Close VCHK                                                  */
      rxv_rc = RXVSAM("CLOSE","$VS")
      "FREE FI($VS)"
   end                                 /* key                        */
 
return                                 /*@ BR_RLSE                   */
/*
.  ----------------------------------------------------------------- */
BRD_DROP_CKOUT:                        /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse var ad0106 component 11 userct  13 blk1,
                                        +37 blk2,
                                        +37 blk3,
                                        +37 blk4,
                                        +37 blk5
   userct = c2x(userct) + 0
   /* Find this user's checkout slot and compress to remove */
   sw.0block_drop = 0
   do zz = 1 to userct                 /* each checkout block        */
      if Left( Value('blk'zz) , 8) = thisuser then do
         $rc = Value('blk'zz,"")       /* zap this block             */
         sw.0block_drop = 1
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
               "Dropped" $rc)
         end
   end                                 /* zz                         */
   zerrlm = ""
   /* Adjust # of users                                              */
   if sw.0block_drop then do
      userct = userct - 1
      if func = "QUERY" then do
                /* This was called from a particular line on the
                   display.  The current position of the table is
                   such that the TBDELETE can be done directly.      */
         address ISPEXEC "TBDELETE" $tn$
         zerrsm = "Released"
         zerrlm = exec_name "("BRANCH("ID")")",
                  "Checkout for" component "obtained" ardate,
                  "has been released"
         address ISPEXEC "SETMSG MSG(ISRZ002)"
         call ZL_LOGMSG(zerrlm)
         end
      end
   else do                             /* block not dropped          */
      zerrsm = ""
      zerrlm = exec_name "("BRANCH("ID")")",
               "Release denied:" component ,
               "not checked-out by" thisuser
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      call ZL_LOGMSG(zerrlm)
      end
   /* If # of users = 0 DELETE                                       */
   if userct = 0 then do
      if zerrlm = "" then
         zerrsm = "Record purged"
      zerrlm = Strip(zerrlm " Userct was zero; the record was purged.")
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      call ZL_LOGMSG( exec_name "("BRANCH("ID")")" zerrlm)
 
      if noupdt = 0 then,
         rxv_rc = RXVSAM("DELETE","$VS",component)
      else say,
                 'RXVSAM("DELETE","$VS",'component') '
      call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
               "RXVSAM DELETE" component)
      end                              /* userct = 0                 */
   /* If # of users > 0 REWRITE                                      */
   else do                             /* reconstruct                */
      userct = x2c(Right(userct,4,0)) /* 2-byte binary               */
      ad0106 = component || userct || ,
               blk1 || blk2 || blk3 || blk4 || blk5
 
      if noupdt = 0 then,
         rxv_rc = RXVSAM("REWRITE","$VS",component,"AD0106")
      else say,
                 'RXVSAM("REWRITE","$VS",'component'"AD0106") '
      call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
               "RXVSAM REWRITE" ad0106)
      end
 
return                                 /*@ BRD_DROP_CKOUT            */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   sw.0NoHist  = SWITCH("NOHIST")      /* no HIStory                 */
   sw.0Force   = SWITCH("FORCE")       /* update live                */
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
ZB_SAVELOG:                            /*@                           */
   if branch then call BRANCH
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
/*
   Parse out the embedded components at the back of the source code.
.  ----------------------------------------------------------------- */
DEIMBED: Procedure expose,             /*@                           */
   (tk_globalvars)  ddnlist  $ddn.  daid.
 
   address TSO
 
   address ISPEXEC "VGET ZSCREENW"
   fb80po.0  = "NEW UNIT(VIO) SPACE(5 5) TRACKS DIR(40)",
                   "RECFM(F B) LRECL("zscreenw") BLKSIZE(0)"
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
            "LMPUT DATAID("daid") MODE(INVAR) DATALOC(LINE)" ,
                      "DATALEN("zscreenw")"
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
     Find where code was run from.  It assumes cataloged data sets.
 
     Original by Doug Nadel
     With SWA code lifted from Gilbert Saint-flour's SWAREQ exec
.  ----------------------------------------------------------------- */
FIND_ORIGIN: Procedure                 /*@                           */
answer="* UNKNOWN *"                   /* assume disaster            */
Parse Source . . name dd ds .          /* get known info             */
Call listdsi(dd "FILE")                /* get 1st ddname from file   */
Numeric digits 10                      /* allow up to 7FFFFFFF       */
If name = "?" Then                     /* if sequential exec         */
  answer="'"ds"'"                      /* use info from parse source */
Else                                   /* now test for members       */
  If sysdsn("'"sysdsname"("name")'")="OK" Then /* if in 1st ds       */
     answer="'"sysdsname"("name")'"    /* go no further              */
  Else                                 /* hooboy! Lets have some fun!*/
    Do                                 /* scan tiot for the ddname   */
      tiotptr=24+ptr(12+ptr(ptr(ptr(16)))) /* get ddname array       */
      tioelngh=c2d(stg(tiotptr,1))     /* nength of 1st entry        */
      Do Until tioelngh=0 | tioeddnm = dd /* scan until dd found     */
        tioeddnm=strip(stg(tiotptr+4,8)) /* get ddname from tiot     */
        If tioeddnm <> dd Then         /* if not a match             */
          tiotptr=tiotptr+tioelngh     /* advance to next entry      */
        tioelngh=c2d(stg(tiotptr,1))   /* length of next entry       */
      End
      If dd=tioeddnm Then,             /* if we found it, loop through
                                          the data sets doing an swareq
                                          for each one to get the
                                          dsname                     */
        Do Until tioelngh=0 | stg(4+tiotptr,1)<> " "
          tioejfcb=stg(tiotptr+12,3)
          jfcb=swareq(tioejfcb)        /* convert SVA to 31-bit addr */
          dsn=strip(stg(jfcb,44))      /* dsname JFCBDSNM            */
          vol=storage(d2x(jfcb+118),6) /* volser JFCBVOLS (not used) */
          If sysdsn("'"dsn"("name")'")='OK' Then,  /* found it?      */
            Leave                      /* we is some happy campers!  */
          tiotptr=tiotptr+tioelngh     /* get next entry             */
          tioelngh=c2d(stg(tiotptr,1)) /* get entry length           */
        End
      answer="'"dsn"("name")'"         /* assume we found it         */
    End
Return answer                          /*@ FIND_ORIGIN               */
/*
.  ----------------------------------------------------------------- */
ptr:  Return c2d(storage(d2x(Arg(1)),4))          /*@                */
/*
.  ----------------------------------------------------------------- */
stg:  Return storage(d2x(Arg(1)),Arg(2))          /*@                */
/*
.  ----------------------------------------------------------------- */
SWAREQ:  Procedure                     /*@                           */
If right(c2x(Arg(1)),1) \= 'F' Then    /* SWA=BELOW ?                */
  Return c2d(Arg(1))+16                /* yes, return sva+16         */
sva = c2d(Arg(1))                      /* convert to decimal         */
tcb = c2d(storage(21c,4))              /* TCB PSATOLD                */
tcb = ptr(540)                         /* TCB PSATOLD                */
jscb = ptr(tcb+180)                    /* JSCB TCBJSCB               */
qmpl = ptr(jscb+244)                   /* QMPL JSCBQMPI              */
qmat = ptr(qmpl+24)                    /* QMAT QMADD                 */
Do While sva>65536
  qmat = ptr(qmat+12)                  /* next QMAT QMAT+12          */
  sva=sva-65536                        /* 010006F -> 000006F         */
End
return ptr(qmat+sva+1)+16              /*@ SWAREQ                    */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR" ; say ""
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      Direct access to the Application Repository               "
say "                                                                          "
say "  Syntax:   "ex_nam"  <function>                                (Required)"
say "                      <keylist>                                 (Required)"
say "                      <APPL appl-id>                    (Required for ADD)"
say "                ((    NOHIST                                              "
say "                                                                          "
say "            function  specifies the task to be done.  Functions supported:"
say "                      "supported_functions
say "                                                                          "
say "            keylist   identifies the keys for which (function) is to be   "
say "                      performed.                                          "
say "                                                                          "
say "            NOHIST    suppresses the display of history records.          "
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
/*
.  ----------------------------------------------------------------- */
BRANCH: Procedure expose,              /*@                           */
        sigl exec_name
   rc = trace("O")                     /* we do not want to see this */
   arg brparm .
 
   origin = sigl                       /* where was I called from ?  */
   do currln = origin to 1 by -1       /* inch backward to label     */
      if Right(Word(Sourceline(currln),1),1) = ":" then do
         parse value sourceline(currln) with pgfname ":" .  /* Label */
         leave ; end                   /*                name        */
   end                                 /* currln                     */
 
   select
      when brparm = "NAME" then return(pgfname) /* Return full name  */
      when brparm = "ID"      then do           /* wants the prefix  */
         parse var pgfname pgfpref "_" .        /* get the prefix    */
         return(pgfpref)
         end                           /* brparm = "ID"              */
      otherwise
         say left(sigl,6) left(pgfname,40) exec_name "Time:" time("L")
   end                                 /* select                     */
 
return                                 /*@ BRANCH                    */
/*
.  ----------------------------------------------------------------- */
DUMP_QUEUE:                            /*@ Take whatever is in stack */
   rc = trace("O")                     /*  and write to the screen   */
   address TSO
   arg mode .
 
   "QSTACK"                            /* how many stacks?           */
   stk2dump    = rc - tk_init_stacks   /* remaining stacks           */
   if stk2dump = 0 & queued() = 0 then return
   if mode <> "QUIET" then,
   say "Total Stacks" rc ,             /* rc = #of stacks            */
    "   Begin Stacks" tk_init_stacks , /* Stacks present at start    */
    "   Excess Stacks to dump" stk2dump
 
   do dd = rc to tk_init_stacks by -1  /* empty each one.            */
      if mode <> "QUIET" then,
      say "Processing Stack #" dd "   Total Lines:" queued()
      do queued();parse pull line;say line;end /* pump to the screen */
      "DELSTACK"                       /* remove stack               */
   end                                 /* dd = 1 to rc               */
 
return                                 /*@ DUMP_QUEUE                */
/* Handle CLIST-form keywords             added 20020513
.  ----------------------------------------------------------------- */
CLKWD: Procedure expose info           /*@ hide all except info      */
   arg kw
   kw = kw"("                          /* form is 'KEY(DATA)'        */
   kw_pos = Pos(kw,info)               /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   rtpt   = Pos(") ",info" ",kw_pos)   /* locate end-paren           */
   slug   = Substr(info,kw_pos,rtpt-kw_pos+1)     /* isolate         */
   info   = Delstr(info,kw_pos,rtpt-kw_pos+1)     /* excise          */
   parse var slug (kw)     slug        /* drop kw                    */
   slug   = Reverse(Substr(Reverse(Strip(slug)),2))
return slug                            /*@CLKWD                      */
/* Handle multi-word keys 20020513
.  ----------------------------------------------------------------- */
KEYWD: Procedure expose info           /*@ hide all vars, except info*/
   arg kw                              /* form is 'KEY DATA'         */
   kw_pos = wordpos(kw,info)           /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   kw_val = word(info,kw_pos+Words(kw))/* get the next word          */
   info   = Delword(info,kw_pos,2)     /* remove both                */
return kw_val                          /*@ KEYWD                     */
/*
.  ----------------------------------------------------------------- */
KEYPHRS: Procedure expose,             /*@                           */
         info helpmsg exec_name        /*  except these three        */
   arg kp                              /* form is 'KEY ;: DATA ;:'   */
   wp    = wordpos(kp,info)            /* where is it?               */
   if wp = 0 then return ""            /* not found                  */
   front = subword(info,1,wp-1)        /* everything before kp       */
   back  = subword(info,wp+1)          /* everything after kp        */
   parse var back dlm back             /* 1st token must be 2 bytes  */
   if length(dlm) <> 2 then            /* Must be two bytes          */
      helpmsg = helpmsg "Invalid length for delimiter("dlm") with KEYPHRS("kp")"
   if wordpos(dlm,back) = 0 then       /* search for ending delimiter*/
      helpmsg = helpmsg "No matching second delimiter("dlm") with KEYPHRS("kp")"
   if helpmsg <> "" then call HELP     /* Something is wrong         */
   parse var back kpval (dlm) back     /* get everything b/w delim   */
   info =  front back                  /* restore remainder          */
return Strip(kpval)                    /*@ KEYPHRS                   */
/*
.  ----------------------------------------------------------------- */
NOVALUE:                               /*@                           */
   say exec_name "raised NOVALUE at line" sigl
   say " "
   say "The referenced variable is" condition("D")
   say " "
   zsigl = sigl
   signal SHOW_SOURCE                  /*@ NOVALUE                   */
/*
.  ----------------------------------------------------------------- */
SHOW_SOURCE:                           /*@                           */
   call DUMP_QUEUE                     /* Spill contents of stacks  -*/
   if sourceline() <> "0" then         /* to screen                  */
      say sourceline(zsigl)
   rc =  trace("?R")
   nop
   exit                                /*@ SHOW_SOURCE               */
/*
.  ----------------------------------------------------------------- */
SS: Procedure                          /*@ Show Source               */
   arg  ssbeg  ssct   .                /* 'call ss 122 6' maybe      */
   if ssct  = "" then ssct  = 10
   if \datatype(ssbeg,"W") | \datatype(ssct,"W") then return
   ssend = ssbeg + ssct
   do ssii = ssbeg to ssend ; say Strip(sourceline(ssii),'T') ; end
return                                 /*@ SS                        */
/*
.  ----------------------------------------------------------------- */
SWITCH: Procedure expose info          /*@                           */
   arg kw                              /* form is 'KEY'              */
   sw_val = Wordpos(kw,info) > 0       /* exists = 1; not found = 0  */
   if sw_val then                      /* exists                     */
      info = Delword(info,Wordpos(kw,info),1) /* remove it           */
return sw_val                          /*@ SWITCH                    */
/*
.  ----------------------------------------------------------------- */
SYNTAX:                                /*@                           */
   errormsg = exec_name "encountered REXX error" rc "in line" sigl":",
                        errortext(rc)
   say errormsg
   zsigl = sigl
   signal SHOW_SOURCE                  /*@ SYNTAX                    */
/*
   Can call TRAPOUT.
.  ----------------------------------------------------------------- */
TOOLKIT_INIT:                          /*@                           */
   address TSO
   info = Strip(opts,"T",")")          /* clip trailing paren        */
 
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm,
                     as_invokt  cmd_env  addr_spc  usr_tokn
 
   parse value "" with  tv  helpmsg  .
   parse value 0   "ISR00000  YES"     "Error-Press PF1"    with,
               sw.  zerrhm    zerralrm  zerrsm
 
   if SWITCH("TRAPOUT") then do
      "TRAPOUT" exec_name parms "(( TRACE R" info
      exit
      end                              /* trapout                    */
 
   sw.nested    = sysvar("SYSNEST") = "YES"
   sw.batch     = sysvar("SYSENV")  = "BACK"
   sw.inispf    = sysvar("SYSISPF") = "ACTIVE"
 
   if Word(parms,1) = "?" then call HELP /* I won't be back          */
 
   "QSTACK" ; tk_init_stacks = rc      /* How many stacks?           */
 
   parse value SWITCH("BRANCH") SWITCH("MONITOR") SWITCH("NOUPDT") with,
               branch           monitor           noupdt    .
 
   parse value mvsvar("SYSNAME") sysvar("SYSNODE") with,
               #tk_cpu           node          .
 
   parse value KEYWD("TRACE")  "O"    with   tv  .
   tk_globalvars = "exec_name  tv  helpmsg  sw.  zerrhm  zerralrm ",
                   "zerrsm  zerrlm  tk_init_stacks  branch  monitor ",
                   "noupdt"
 
   call LOCAL_PREINIT                  /* for more opts             -*/
 
return                                 /*@ TOOLKIT_INIT              */
/*
)))PLIB ARDISP
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%บ-บ Application Repository Component Detail +บ-บ
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
   /-- U=Checkout   R=Release  F=Fetch/FireProt
  /
+V  Date     Component  Type  Description
)MODEL
_z!ardate  +@argrp     +@z  +@artext
)INIT
  .ZVARS = '(SEL ARFILE)'
  .HELP = ARDISPH
)REINIT
)PROC
  IF (.PFKEY = 'PF05')
      &PFKEY = 'F5'
      .RESP = END
)END
)))PLIB ARDISPH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%TUTORIAL บ-บ Application Repository Component Detail บ-บ TUTORIAL
%Next Selection ===>_ZCMD
 
+      Panel%ARDISP+displays all known detail for the requested keys
       as found in the Application Repository.
 
      %DATE        +is the activity date for Checkout records and
                    History records.
 
      %COMPONENT   +is the A/R generic component name.
 
      %TYPE        +is CMP (Owned Components)
                       HIS (Clearance History)
                       CHK (Current Checkouts)
 
      %DESCRIPTION +displays the available detail for the entry.  This
                    detail varies by TYPE.
 
+(@tmtag+)
)PROC
)END
*/
