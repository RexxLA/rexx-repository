/* REXX    MACSLIST   Display list of available MACS compiler listings
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke 20020327
 
     Impact Analysis
.    ISPLLIB   SYSUMON
.    SYSEXEC   DFLTTLIB
.    SYSEXEC   FCCMDUPD
.    SYSEXEC   MLUPDT
.    SYSEXEC   SEIZE
.    SYSEXEC   TBLGEN
.    SYSEXEC   TRAPOUT
.    SYSPROC   TBLSORT
 
     Modification History
     20020416 fxc notify maintainers when list item is missing;
     20020520 fxc make INSTALLable
     20020904 fxc dont start command name with #
     20020927 fxc use TBLSORT for sorting; enable QPRINT;
     20030303 fxc DFLTTLIB no longer used; table location is static;
     20030326 fxc enable L (locate)
     20030516 fxc View/Browse doesn't detect an empty dataset; use
                  SYSDSN;
     20030814 fxc enable call-from-READY
     20030909 fxc call MLUPDT to add new lines to the table
     20030920 fxc call MLUPDT if ordered
     20031125 fxc function U;
     20031125 fxc always call MLUPDT
     20040507 fxc enable SYSUMON
     20040818 fxc correct problem of table position when swapping
                  formats;
     20041022 fxc Enable call to CANICLR;
     20050310 fxc fix positioning problem when F10/F11;
     20051130 fxc enable STATS;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010802      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
if ^sw.inispf  then do                 /* after TOOLKIT_INIT return  */
   argline = argline "(( ISPSTART"     /* tell the next invocation   */
   "ISPSTART CMD("exec_name argline")" /* Invoke ISPF...             */
   exit                                /* ...then bail out           */
   end
 
monparm = "/USER" Userid() "TOOL" exec_name
"CALL 'NTIN.TS.D822.LIB.ISPLLIB(SYSPMON)'"  "'" monparm"'"
call A_INIT                            /*                           -*/
call B_TABLE_OPS                       /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
if sw.0exit_ISPF then do               /* just after DUMP_QUEUE      */
   rc = OutTrap('LL.')
   exit 1
   end
 
exit                                   /*@ MACSLIST                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call AK_KEYWDS                      /*                           -*/
   if sw.0update then,
      call AU_UPDT_TABLE               /*                           -*/
   parse value "0 0 0 0 0 0 0 0 0 0 0"   with ,
         ct.   csrrow  lastfnd  lastcrp   err.     .
   parse value " " with ,
         clrlist   pfkey   tbldata   ,
         idxlist    ,
         .
 
   maintainers = "DTAFXC"              /* identify all maintainers   */
 
   listpref = "ACN1.PR.D292.MACS.COMPLINK"
   sortslug = "DEFAULT"                /* displayable sort sequence  */
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AK_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address tso
 
   sw.0update   = 1  /* SWITCH("UPDATE") */
 
return                                 /*@ AK_KEYWDS                 */
/*
   Update the ML table with any new material.
.  ----------------------------------------------------------------- */
AU_UPDT_TABLE:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   "MLUPDT" argline
 
return                                 /*@ AU_UPDT_TABLE             */
/*
.  ----------------------------------------------------------------- */
B_TABLE_OPS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BA_PROLOG                      /*                           -*/
   call BD_DISPLAY                     /*                           -*/
   call BZ_EPILOG                      /*                           -*/
 
return                                 /*@ B_TABLE_OPS               */
/*
   Extract ISPF material and LIBDEF it active.
.  ----------------------------------------------------------------- */
BA_PROLOG:                             /*@                           */
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
 
   /* Set up values for the variable-format panel(s)                 */
   desc1   = "V -Member- Type  A/R Base  -Userid-  ---Date--- Time   Libtype"
   desc2   = "V -Member- Type  A/R Base  -Userid-  -Username----"
   modl1   = "_z!mlroot  +!z   !mlbase   !mluid    !mldate    !mltime!mlloc"
   modl2   = "_z!mlroot  +!z   !mlbase   !mluid    !mlsname"
   styles  = "detail uname"
   stylect = 2
   style   = 1                         /* default style              */
   "VGET (ZPF10 ZPF11) PROFILE"
   save_f10 = zpf10
   save_f11 = zpf11
 
return                                 /*@ BA_PROLOG                 */
/*
.  ----------------------------------------------------------------- */
BD_DISPLAY:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call BDA_TBOPEN                     /*                           -*/
                                    if \sw.0error_found then,
   call BDD_TBDISPL                    /*                           -*/
   call BDZ_TBEND                      /*                           -*/
 
   if err.0 > 0 then,
      call BD0_NOTIFY                  /*                           -*/
 
return                                 /*@ BD_DISPLAY                */
/*
   Open the table.
.  ----------------------------------------------------------------- */
BDA_TBOPEN:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LIBDEF  ISPTLIB  DATASET  ID("isptlib")  STACK"
   "TBSTATS" $tn$ "STATUS1(s1) STATUS2(s2)"
   if s1 > 1 then do
      say "Table" $tn$ "not available."
      zerrsm = "Table" $tn$ "not available."
      zerrlm = "Table" $tn$ "not found in the ISPTLIB library chain"
      sw.0error_found = "1"; return
      end; else,
   if s2 = 1 then do                   /* table is not open          */
      "TBOPEN "   $tn$   "NOWRITE"
      end
   else "TBTOP" $tn$
   "LIBDEF  ISPTLIB"
 
return                                 /*@ BDA_TBOPEN                */
/*
.  ----------------------------------------------------------------- */
BDD_TBDISPL:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBTOP" $tn$
   "TBVCLEAR" $tn$                     /* zap values                 */
   mlroot = '3f3f'x                    /* set to special             */
   "TBSARG" $tn$ "NAMECOND(MLROOT,GT)" /* exclude admin row          */
   do forever
      sel = ""
      sep = ""
      modl = Value('modl'style)
      desc = Value('desc'style)
 
      if csrrow <> 0 then do           /* skip to 1st displayed line */
         "TBTOP"  $tn$
         "TBSKIP" $tn$ "NUMBER("csrrow")"
         end
 
            parse value "END   END"   with zpf10 zpf11  .
            "VPUT (ZPF10 ZPF11) PROFILE"
      "TBDISPL" $tn$ "PANEL(MLDISP)"
      disp_rc = rc
            zpf10 = save_f10
            zpf11 = save_f11
            "VPUT (ZPF10 ZPF11) PROFILE"
 
       if pfkey = "PF03" | disp_rc > 4 then leave
 
      if WordPos(pfkey,"PF10 PF11") > 0 then do
         call BDDK_CHECK_STYLE         /*                           -*/
         csrrow = ztdtop               /* set TBSKIP position        */
         iterate
         end
      else csrrow = 0
 
      if disp_rc > 8 then do
         zerrlm = exec_name "("BRANCH("ID")")",
                  zerrlm
         "SETMSG  MSG(ISRZ002)"
         sw.0error_found = "1"
         leave
         end
      if disp_rc = 8 then leave
 
      if zcmd <> "" then do
         "CONTROL DISPLAY SAVE"
         call BDDP_PROCESS_ZCMD
         "CONTROL DISPLAY RESTORE"
         end ; else,
      do ztdsels
         "CONTROL DISPLAY SAVE"
 
         select
 
            when WordPos(sel,"B S") > 0 then do
               call BDDB_BROWSE        /*                           -*/
               if sw.0missing then do
                  parse value err.0+1 mlroot mlsuff with ,
                              $z$     err.$z$       1  err.0 .
                  "TBDELETE" $tn$      /* temp for NOWRITE table     */
                  sw.0missing = 0
                  if Symbol("zerrlm") = "LIT" then zerrlm = ""
                  if zerrlm = "" then do
                     zerrlm = "Missing listings detected: "
                     zerrsm = "Missing data"
                     sw.0msg_pending = 1
                     end
                  zerrlm = Space(zerrlm sep mlroot mlsuff,1)
                  sep = ";"
                  end                  /* missing listing            */
               end
 
            when sel = "C" then do
               call BDDC_COPY          /*                           -*/
               end
 
            when sel = "I" then do
               call BDDI_INFO          /*                           -*/
               end
 
            when sel = "U" then do
               call BDDU_USER          /* identify userid           -*/
               end
 
            when sel = "?" then do
               clrlist = clrlist mlroot"P"mlsuff
               end
 
            otherwise nop
 
         end                           /* select                     */
 
         "CONTROL DISPLAY RESTORE"
 
         if ztdsels > 1 then "TBDISPL" $tn$
      end                              /* ztdsels                    */
 
      if clrlist <> "" then do         /* run CANICLR                */
         address TSO "CANICLR" clrlist
         clrlist = ""
         end
 
      if sw.0msg_pending then do
         "SETMSG  MSG(ISRZ002)"
         zerrlm = ""
         sw.0msg_pending = 0
         end
   end                                 /* forever                    */
 
return                                 /*@ BDD_TBDISPL               */
/*
.  ----------------------------------------------------------------- */
BDDB_BROWSE:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dsn = "'"listpref"."mlsuff"("mlroot")'"
 
   if Sysdsn(dsn) <> "OK" then do
      sw.0missing = 1
      return
      end
 
   "VIEW DATASET("dsn")"
 
return                                 /*@ BDDB_BROWSE               */
/*
.  ----------------------------------------------------------------- */
BDDC_COPY:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   "SEIZE {"listpref"."mlsuff ,        /* SEIZE wants it unquoted    */
         "{" mlroot "{ { "
 
return                                 /*@ BDDC_COPY                 */
/*
.  ----------------------------------------------------------------- */
BDDI_INFO:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   dsn = "'"listpref"."mlsuff"'"
   "VIEW DATASET("dsn")"
 
return                                 /*@ BDDI_INFO                 */
/*
   Cycle between styles.  If there were 5 styles:
   To go to the next style:  (style//stylect) + 1:
          1   2   3   4   5
          1   2   3   4   0    (mod stylect)
          2   3   4   5   1    (add one)
   To go to the prior style:  (style+stylect-2)//stylect + 1
          1   2   3   4   5
          6   7   8   9  10    (+stylect)
          4   5   6   7   8    ( -2 )
          4   0   1   2   3    ( //stylect)
          5   1   2   3   4    ( +1 )
   This works regardless of the number of styles; it even works when
   the number of styles is 1!
.  ----------------------------------------------------------------- */
BDDK_CHECK_STYLE:                      /*@                           */
   if branch then call BRANCH
   address TSO
 
   select
 
      when pfkey = "PF11" then,
         style = style//stylect + 1    /* next style                 */
 
      when pfkey = "PF10" then,
         style = (style+stylect-2)//stylect + 1       /* prev style  */
 
      otherwise nop
   end
 
return                                 /*@ BDDK_CHECK_STYLE          */
/*
   LOCATE is not implemented because the table is not expected to grow
   to the point that it would be necessary.  ONLY provides, as well,
   much of the benefit which LOCATE would deliver, and the table can
   also be sorted in any manner desired,
.  ----------------------------------------------------------------- */
BDDP_PROCESS_ZCMD:                     /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   parse var zcmd   verb text
   select                              /* which verb ?               */
      when verb = "L" then do
         if tbldata = "" then do
            call BDDPSD_DESCRIBE       /* sets 'origsort'           -*/
            parse var origsort  activfld ","
            end
         $z$ = Value(activfld,text"*")
         call Z_TBSCAN                 /*                           -*/
         end
 
      when verb = "ONLY" then do       /* chg TBSARG                 */
         text = Strip(text,,"*")
         "TBVCLEAR" $tn$
         mlroot = text"*"
         "TBSARG" $tn$ "NAMECOND(MLROOT,EQ)" /* only these rows      */
         end                           /* ONLY                       */
 
      when verb = "ALL"  then do       /* chg TBSARG                 */
         "TBVCLEAR" $tn$
         mlroot = '3f3f'x
         "TBSARG" $tn$ "NAMECOND(MLROOT,GT)" /* exclude admin row    */
         end                           /* ALL                        */
 
      when verb = "SORT" then do       /* Sort                       */
         call BDDPS_SORT               /*                           -*/
         end                           /* Sort                       */
 
      when verb = "STATS" then do      /* Statistics                 */
         call BDDPT_STATS              /*                           -*/
         end                           /* Statistics                 */
 
      when verb = "QPRINT" then do     /* Print                      */
         call BDDPP_PRINT              /*                           -*/
         end                           /* Print                      */
 
      otherwise nop
   end                                 /* select                     */
 
return                                 /*@ BDDP_PROCESS_ZCMD         */
/*
   Sort the <tbltype> table. <text> contains the sortspec in the format:
       <fldname>  {,<dir>  { <sortspec> }   }
   If <dir> is specified, it must be A or D.  Additional sortspecs
   may be appended.
.  ----------------------------------------------------------------- */
BDDPS_SORT:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if tbldata = "" then,
      call BDDPSD_DESCRIBE             /* sets 'origsort'           -*/
   sortspec = ""                       /* init empty                 */
   origtext = text                     /* save                       */
   if origtext = "" |,                 /* restore canonical order    */
      origtext = "DEFAULT" then,       /* restore canonical order    */
      sortspec = origsort              /* sort to default sequence   */
   else,
   do while text <> ""
      parse var text   spec  text      /* isolate next spec          */
      parse var spec  fld "," dir
      if fld = "" then do
         zerrsm = "Error in SORT specification"
         zerrlm = exec_name "("BRANCH("ID")")",
                  "You specified:",
                   "<"Strip(origtext)">. ",
                   " SORT specifications must contain table",
                   "field names with optional directional indicators,",
                   "(e.g.) 'ZORT,A   BLAT   GORF,D'. " exec_name,
                   "detected a missing field-name."
         "SETMSG MSG(ISRZ002)"
         return
         end                           /* no fld !                   */
      if Wordpos(fld,keys names) = 0 then do
         zerrsm = "Error in SORT specification"
         zerrlm = exec_name "("BRANCH("ID")")",
                  "You specified:",
                   "<"Strip(origtext)">. ",
                   " SORT specifications must contain table",
                   "field names with optional directional indicators,",
                   "(e.g.) 'ZORT,A   BLAT   GORF,D'. " exec_name,
                   "detected an incorrect field-name. ",
                   "The valid field-names are:" ,
                   "<"Strip(keys names)">."
         "SETMSG MSG(ISRZ002)"
         return
         end                           /* unknown field name         */
      parse value dir "A"  with dir .  /* default to A               */
      if Wordpos(dir,"A D") = 0 then do
         zerrsm = "Error in SORT specification"
         zerrlm = exec_name "("BRANCH("ID")")",
                  "You specified:",
                   "<"Strip(origtext)">. ",
                   " SORT specifications must contain table",
                   "field names with optional directional indicators,",
                   "(e.g.) 'ZORT,A   BLAT   GORF,D'. " ,
                   " Directional indicators may be either A or D. ",
                   exec_name "detected an incorrect directional",
                   "indicator."
         "SETMSG MSG(ISRZ002)"
         return
         end                           /* bad dir !                  */
      sortspec = sortspec fld",C,"dir
   end                                 /* text                       */
   sortspec = Space(sortspec,1)
   sortspec = Translate(sortspec , "," , " ")
   sortseq  = sortspec
   debug    = "OFF"
 
   "VPUT ($TN$ SORTSEQ DEBUG) SHARED"
   address TSO
   "ALTLIB ACT   QUIET APPLICATION(CLIST) DSNAME('DTAFXC.@@.CLIST')"
   "%TBLSORT"
   "ALTLIB DEACT QUIET APPLICATION(CLIST)"
 
   sortslug = sortspec                 /* show the sequence          */
   parse var sortspec activfld ","     /* locateable field           */
 
return                                 /*@ BDDPS_SORT                */
/*
   Ask TBLGEN to describe the <tbltype> table.
.  ----------------------------------------------------------------- */
BDDPSD_DESCRIBE:                       /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   "TBLGEN ML DESCRIBE"
   pull tbldata
   "DELSTACK"
 
   parse var tbldata "KEYS("  keys     ")" ,
                     "NAMES(" names    ")" ,
                     "SORT("  origsort ")"
 
return                                 /*@ BDDPSD_DESCRIBE           */
/*
   Build the STATS table as {mlstag,mlstype,mlsct}, spin the main table
   and collect counts by tag+type, then populate STATS and display.
.  ----------------------------------------------------------------- */
BDDPT_STATS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   typ.R = "Root"
   typ.U = "User"
   if idxlist = "" then do
      "TBTOP" $tn$
      do forever
         "TBSKIP" $tn$
         if rc > 0 then leave          /* end of table               */
         if mlroot < ' ' then iterate  /* control record             */
         idx = "R"mlbase
         if WordPos(idx,idxlist) = 0 then idxlist = idxlist idx
         ct.idx = ct.idx + 1
         idx = "U"mluid
         if WordPos(idx,idxlist) = 0 then idxlist = idxlist idx
         ct.idx = ct.idx + 1
      end                              /* forever                    */
 
      "TBCREATE  STATS  KEYS(MLSTAG MLSTYPE) NAMES(MLSCT)",
                      "NOWRITE REPLACE"
 
      tmplist = idxlist
      do Words(tmplist)
         parse var tmplist  idx tmplist    /* isolate                */
         mlsct     = ct.idx
         parse var idx  mlstype 2 mlstag .
         mlstype   = typ.mlstype
         "TBADD  STATS"
      end                              /* tmplist words              */
   end                                 /* idxlist                    */
 
   "TBSORT  STATS  FIELDS( MLSTYPE,C,A , MLSCT,N,D  )"
/* "TBSORT  STATS  FIELDS( MLSTYPE,C,A , MLSTAG,C,A )" */
   "TBDISPL STATS  PANEL(MLSTATS)"
 
return                                 /*@ BDDPT_STATS               */
/*
   Produce a formatted report.
.  ----------------------------------------------------------------- */
BDDPP_PRINT:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
   if text = "SORTED" then do          /* sort the table first       */
      debug = "OFF"
      sortseq = "MLNAME,C,A"
      address ISPEXEC "VPUT ($TN$ SORTSEQ DEBUG) SHARED"
      "ALTLIB ACT   QUIET APPLICATION(CLIST) DSNAME('DTAFXC.@@.CLIST')"
      "%TBLSORT"
      "ALTLIB DEACT QUIET APPLICATION(CLIST)"
      end                              /* Sorted                     */
 
   "NEWSTACK"
   call BDDPPS_SPIN_TABLE              /*                           -*/
 
   outdsn = $tn$"."verb                /* macslist.qprint            */
   alloc.0   = "NEW CATALOG UNIT(SYSDA) SPACE(5 5) TRACKS",
               "RECFM(V B) LRECL(255) BLKSIZE(0)"
   alloc.1   = "SHR"                   /* if it already exists...    */
   tempstat = Sysdsn(outdsn) = "OK" |, /* 1=exists, 0=missing        */
              Sysdsn(outdsn) = "MEMBER NOT FOUND"
   "ALLOC FI($TMP) DA("outdsn") REU" alloc.tempstat
 
   zerrsm = queued() "lines"
   zerrlm = queued() "lines" "written to" outdsn
   "EXECIO" queued() "DISKW $TMP (FINIS"
 
   "DELSTACK"
 
   address ISPEXEC "SETMSG MSG(ISRZ002)"
 
return                                 /*@ BDDPP_PRINT               */
/*
.  ----------------------------------------------------------------- */
BDDPPS_SPIN_TABLE:                     /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   do forever
      "TBSKIP" $tn$                    /* next row                   */
      if rc > 0 then leave             /*                            */
      if mlseq  <> "" then,
         queue Left(mlroot,9) Left(mlname,10) mlseq mluid
   end                                 /* forever                    */
 
return                                 /*@ BDDPPS_SPIN_TABLE         */
/*
.  ----------------------------------------------------------------- */
BDDU_USER:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   "ALTLIB ACT APPLICATION(EXEC) DA('DTAFXC.@@.EXEC') "
   if rc > 4 then do
      zerrsm = "ALTLIB failed, RC="rc
      zerrlm = "ALTLIB failed for 'DTAFXC.@@.EXEC'"
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      return
      end
 
   "WHOIS"     mluid
 
   "ALTLIB DEACT APPLICATION(EXEC)"
   uidline = ""
   do queued()                         /* spill the queue            */
      parse pull uidline
      uidline = Space(uidline,1)
   end                                 /* queued                     */
   "DELSTACK"
 
   address ISPEXEC
   pop1 = uidline
   "VGET ZPFCTL"; save_zpf = zpfctl       /* save current setting    */
   zpfctl = "OFF"; "VPUT ZPFCTL"          /* PFSHOW OFF              */
 
   "ADDPOP POPLOC(SEL) ROW(+2) COLUMN(+2)"
   "DISPLAY PANEL(POP40BY1)"
   zpfctl = save_zpf; "VPUT ZPFCTL"       /* restore                 */
   "REMPOP ALL"
 
return                                 /*@ BDDU_USER                 */
/*
.  ----------------------------------------------------------------- */
BDZ_TBEND:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBEND" $tn$
 
return                                 /*@ BDZ_TBEND                 */
/*
   Some user requested a listing which no longer exists and has
   queued (an) error message(s) with the key(s).  Collect these
   error messages and notify the maintainer.
.  ----------------------------------------------------------------- */
BD0_NOTIFY:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   name = getname()
   "NEWSTACK"
   queue "*--------<MACSLIST>----------------------------------------*"
   queue " "
   queue "     USER" Userid() "("name")"
   queue "     found errors in the ML table."
   queue " "
   do bzz =1 to err.0                  /* every error                */
      queue "    "err.bzz
   end                                 /* bzz                        */
   queue " "
   queue "*----------------------------------------------------------*"
 
   "ALLOC FI($MSG) UNIT(VIO) SPACE(1) TRACKS RECFM(F B) LRECL(80)",
                 "BLKSIZE(0) NEW REU"
   "EXECIO" queued() "DISKW  $MSG (FINIS"
 
   dcidlist = maintainers
   do words(dcidlist)
      parse var dcidlist   ID  dcidlist
      rc = Outtrap("xmit.")
      "TRANSMIT"   node"."ID   "MSGFILE($MSG)    NOL NOP NOE NON"
      rc = Outtrap("OFF")
   end                                 /* dcidlist                   */
   "FREE  FI($MSG)"
   "DELSTACK"
 
return                                 /*@ BD0_NOTIFY                */
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
 
   sw.0exit_ISPF = SWITCH("ISPSTART")  /* goes in LOCAL_PREINIT      */
 
   if SWITCH("INSTALL") then do
      queue "ML"
      queue 0
      queue "SELECT CMD(%MACSLIST  &ZPARM)"
      queue "Show available compile listings from MACS"
      "FCCMDUPD"
      exit
      end                              /* INSTALL                    */
 
   parse value KEYWD("ISPTLIB")  "'NTIN.TS.D822.LIB.ISPTLIB'"  with,
               isptlib   .
 
   parse value KEYWD("ISPTABL")  isptlib   with,
               isptabl   .
 
   parse value KEYWD("USETBL")  "MACSLIST"   with,
               $tn$      .
 
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
GETNAME:                               /*@                           */
   address TSO
 
   ASCBASXB = d2x(c2d(Storage(224,4))+108)
   ASXBSENV = d2x(c2d(Storage(ASCBASXB,4))+200)
   ACEEUNAM = d2x(c2d(Storage(ASXBSENV,4))+100)
   Adr = c2x(Storage(ACEEUNAM,4))
   Name = Storage(d2x(c2d(Storage(ACEEUNAM,4))+1),c2d(Storage(Adr,1))-1)
   Name = Strip(Name,"B"," ")
 
return(name)                           /*@ GETNAME                   */
/*
   The table is positioned to find a row and the argument is set.
.  ----------------------------------------------------------------- */
Z_TBSCAN:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBSCAN" $tn$ "ROWID(LASTFND) POSITION(LASTCRP)",
                 "ARGLIST("activfld") CONDLIST(EQ)"
                      /* set LASTFND and LASTCRP if successful       */
   if rc = 8 then do                   /* not found                  */
      zerrsm = "Not found"
      if pfkey = "F5" then,
         zerrlm = "End of table encountered."
      else,
         zerrlm = "No rows found to match" activfld"="text
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      end                              /* not found                  */
   "TBSKIP" $tn$ "ROW("lastfnd") NOREAD"    /* position to LASTFND   */
 
return                                 /*@ Z_TBSCAN                  */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      displays the list of available compile listings from   "
say "                the MACS system                                        "
say "                                                                       "
say "  Syntax:   "ex_nam"  <no parms>                                       "
say "                      <UPDATE>                                         "
say "                  ((  <ISPTLIB idsn>                         (Defaults)"
say "                      <ISPTABL odsn>                         (Defaults)"
say "                      <USETBL  tbln>                         (Defaults)"
say "                      <INSTALL>                                        "
say "                                                                       "
say "            UPDATE    causes command 'MLUPDT' to be run to add any new "
say "                      information to the table before displaying it.   "
say "                                                                       "
say "            idsn      names the input Table Library.  If not specified,"
say "                      NTIN.TS.D822.LIB.ISPTLIB will be used.           "
say "                                                                       "
say "            odsn      names the output Table Library.  If not specified,"
say "                      the current value of <idsn> is used.             "
say "                                                                       "
say "            tbln      names the table to be displayed.  Default value  "
say "                      is 'MACSLIST'.                                   "
say "                                                                       "
say "            INSTALL   causes command 'ML' to be added to the user's    "
say "                      command table as a shortcut.  If specified, no   "
say "                      other processing is allowed.                     "
say "                                                                       "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                   "
say "                                                                       "
say "        BRANCH:   show all paragraph entries.                          "
say "                                                                       "
say "        TRACE tv: will use value following TRACE to place the          "
say "                  execution in REXX TRACE Mode.                        "
say "                                                                       "
say "                                                                       "
say "   Debugging tools can be accessed in the following manner:            "
say "                                                                       "
say "        TSO "ex_nam"  parameters     ((  debug-options                 "
say "                                                                       "
say "   For example:                                                        "
say "                                                                       "
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                              "
 
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/* ---------- REXXSKEL back-end removed for space ------------------ */
/*
)))PLIB MLDISP
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON) COLOR(YELLOW)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON) caps(off)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%บ-บ Available MACS Compile Listings +บ-บ
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
+  /- B=Browse   C=Copy  I=DirInfo   Primary Cmds: SORT, ONLY, ALL      See HELP
+ /              ?=CANICLR   Sort Seq:@sortslug
@desc
)MODEL ROWS(SCAN)
&modl
)INIT
  .ZVARS = '(SEL MLSUFF)'
  .HELP = MLDISPH
)REINIT
)PROC
 
  IF (.PFKEY = 'PF10')
      .RESP  = 'ENTER'
 
  IF (.PFKEY = 'PF11')
      .RESP  = 'ENTER'
 
  &PFKEY = .PFKEY
 
)END
)))PLIB MLDISPH
)PANEL KEYLIST(ISRHELP)
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
  } AREA(SCRL)   EXTEND(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW) ASIS
%TUTORIAL บ-บ Available MACS Compile Listings บ-บ TUTORIAL
%Next Selection ===>_ZCMD
 
}mainhelp                                                                      }
}                                                                              }
}                                                                              }
}                                                                              }
}                                                                              }
}                                                                              }
}                                                                              }
)AREA MAINHELP DEPTH(7)
+    Select any row or rows for processing:
%       B+- to%Browse+the actual compiler listing
%       C+- to%Copy+the listing dataset to a destination of your choice.
%       I+- to%View the entire collection of like programs.
%       U+- to%identify the user.+ You may also toggle the display with F10/F11
                   to show Username.
%       ?+- to%execute CANICLR+for this module.  All selections with "?" are
                   processed last after all other selections.
 
+    To restrict the display to certain named modules, specify
%       ONLY ....+and give the high-order characters of the names to be
                  displayed.
%       ALL      +causes the display to revert to "all modules"
%       L        +locates the first matching row.  The Locate is done only for
                  the most significant sort-field.
 
+    To see counts for all users and base-names...%STATS
+
+    Sort the display to any order by specifying
%       SORT <sortspec>  +  where sortspec is 1-n blank-delimited blocks
+            of%<fldname<,dir>>.    <dir>+may be A or D (defaults to A);
%            <fldname>+may be any of MLNAME MLDATE MLTIME MLSEQ MLUID MLBASE
                                     MLSUFF MLLOC
%       SORT DEFAULT     +  returns the table to its original sequence,
+                           i.e.: SORT MLSEQ,D
)PROC
)END
)))PLIB POP40BY1
)ATTR
    %  TYPE(TEXT)   INTENS(HIGH)   SKIP(ON)
)BODY WINDOW(40,1)
%&pop1
)INIT
)PROC
 &POPKEY = .PFKEY
)END
)))PLIB MLSTATS
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  } TYPE(OUTPUT) INTENS(HIGH) SKIP(ON) JUST(RIGHT)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(บบ)
%บ-บ Statistics +บ-บ
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
+  Tag          Tagtype       Count
)MODEL
  !mlstag      !mlstype     }mlsct +
)INIT
  .HELP = ISR00001
)REINIT
)PROC
  IF (.PFKEY = 'PF05')
      &PFKEY = 'F5'
      .RESP = END
)END
*/
