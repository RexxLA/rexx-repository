/* REXX    TBLOOK     Display any ISPF table
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by Frank Clarke, Oldsmar FL
 
     Impact Analysis
.    SYSEXEC   LA
.    SYSEXEC   TRAPOUT
.    SYSPROC   TBLSORT
.    ISPPLIB   ARRANGE   (embedded)
.    ISPPLIB   PRTCONF   (embedded)
.    ISPPLIB   P1H       (embedded)
.    ISPPLIB   P2H       (embedded)
 
     Modification History
     19951016 fxc upgrade REXXSKEL (950824); activate 'IN datasetname';
     19980211 fxc leave table OPEN if it was found that way; enable
                  SORT;
     19980602 fxc enable Find/Locate
     19980729 fxc upgrade from v.960119 to v.19980225;
                  RXSKLY2K; DECOMM;
     19991101 fxc use VIO for the panel library similar to the method
                  used by DEIMBED.
     19991110 fxc handle 'no keys, no names' tables
     19991206 fxc upgrade from v.19980225 to v.19991109
     20020130 fxc add TPRINT capability and ability to select,
                  exclude, and arrange fields to be printed;
     20020207 fxc minor corrective adjustments
     20020829 fxc use TBLSORT to sort table
     20030304 fxc fixed call to TBLSORT
     20040129 fxc widen fields to use full screen width
     20040722 fxc widescreen version;
     20040822 fxc added STATS option for main screen;
     20051014 fxc if tblds specified, force table closed;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
"POST" exec_name argline
 
call A_INIT                            /*                           -*/
                                   if \sw.0error_found then,
call B_BUILD_PANELS                    /*                           -*/
 
exit                                   /*@ TBLOOK                    */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch  then call BRANCH
   address ISPEXEC
 
   "CONTROL ERRORS RETURN"             /* I'll handle my own.        */
   alloc.0   = "NEW CATALOG UNIT(VIO) SPACE(2 2) TRACKS DIR(5)",
               "RECFM(F B) LRECL(80) BLKSIZE(0)"
 
   parse value "0 0 0 0 0 0 0 0 0 0" with,
      lastfnd    hdr.    ll.    .
 
   parse value "" with,
      pfkey  thisds  keynames  varnames allxvars
 
   call AA_KEYWDS                      /*                           -*/
 
   parse var info  tblid .
   if tblid = "" then do               /* tablename not specified ?  */
      helpmsg = "Tablename must be specified."
      call HELP; end
 
   if tblds = "" then do
      "TBSTATS" tblid "STATUS2(s2)"
      if rc > 0 then do
         zerrlm  = exec_name "("BRANCH("ID")")",
                   zerrlm
         "SETMSG  MSG(ISRZ002)"
         sw.0error_found = "1" ; return
         end
      if s2 > 1 then do
         sw.0leave_open = "1"
         return
         end
      call AB_LISTA                    /* loads tblds from ISPTLIB  -*/
      end
   else do
      if Left(tblds,1) <> "'" then,
              tblds = Userid()"."tblds            /* fully-qualified  */
      else    tblds = Strip(tblds,,"'")           /* unquoted         */
      end
 
   do ii = 1 to Words(tblds)
      parse var tblds thisds tblds
      if Sysdsn("'"thisds"("tblid")'") = "OK" then leave
   end                                 /* ii                         */
 
   if Sysdsn("'"thisds"("tblid")'") <> "OK" then do
      say tblid "not found in ISPTLIB"
      sw.0error_found = "1" ; return
      end
 
   openmode.0  = "WRITE"               /* based on NOUPDT            */
   openmode.1  = "NOWRITE"
   noupdt      = \sw.4EDIT
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.4EDIT   = SWITCH("UPDATE")
   parse value  KEYWD("TBLIB") KEYWD("IN") with,
                tblds    .
 
return                                 /*@ AA_KEYWDS                 */
/*
   No <tblds> was specified.  Search area is ISPTLIB.
.  ----------------------------------------------------------------- */
AB_LISTA:                              /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   "LA ISPTLIB ((STACK"
   pull tblds
   "DELSTACK"
 
return                                 /*@ AB_LISTA                  */
/*
.  ----------------------------------------------------------------- */
B_BUILD_PANELS:                        /*@                           */
   if branch  then call BRANCH
   address ISPEXEC
 
   "VGET (ZSCREENW)"
   maxusable = zscreenw - 2
 
   call BA_PROLOG                      /* extract and load panels   -*/
                                   if \sw.0error_found then,
   call BB_OPEN                        /*                           -*/
                                   if \sw.0error_found then,
   call BC_LOAD_PANELS                 /*                           -*/
                                   if \sw.0error_found then,
   call BD_SHOW_TABLE                  /*                           -*/
 
   "LIBDEF ISPTABL DATASET ID('"thisds"') STACK"
   if sw.0leave_open then,
      if sw.4EDIT then "TBSAVE" tblid
                  else nop
   else,                               /* don't leave open           */
      if sw.4EDIT then "TBCLOSE" tblid
                  else "TBEND"  tblid
   "LIBDEF ISPTABL"
   call BZ_EPILOG                      /* drop LIBDEFs              -*/
 
return                                 /*@ B_BUILD_PANELS            */
/*
   DEIMBED and LIBDEF
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
 
return                                 /*@ BA_PROLOG                 */
/*
.  ----------------------------------------------------------------- */
BB_OPEN:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if sw.0leave_open then return
 
   "CONTROL ERRORS RETURN"
   if thisds <> "" then,
      "LIBDEF ISPTLIB DATASET ID('"thisds"') STACK"
 
   "TBSTATS" tblid "STATUS1(s1) STATUS2(s2)"
   if rc = 20 then do
      say tblid "is not a valid ISPF table"
      sw.0error_found = "1"
      end ; else,
   if thisds <> "" & s1 > 1 then do
      say "Table" tblid "not available."
      sw.0error_found = "1"
      end ; else,
   if s2> 1 then,                      /* it's already open!!!       */
      "TBEND" tblid                    /* force it closed/nowrite    */
   "TBOPEN" tblid openmode.noupdt
 
   if thisds <> "" then,
      "LIBDEF  ISPTLIB"
 
return                                 /*@ BB_OPEN                   */
/*
   Build the panels for the table display.
.  ----------------------------------------------------------------- */
BC_LOAD_PANELS:                        /*@                           */
   if branch  then call BRANCH
   address TSO
 
   call BCA_GETNAMES                   /* table columns             -*/
   call BCH_HEADERS                    /* build panel lines         -*/
 
   "NEWSTACK"
   call BCP_LOADP1                     /* load to temp ISPPLIB      -*/
   call BCQ_LOADP2                     /* load to temp ISPPLIB      -*/
   "DELSTACK"
 
return                                 /*@ BC_LOAD_PANELS            */
/*
.  ----------------------------------------------------------------- */
BCA_GETNAMES:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBQUERY" tblid "KEYS(keynames) NAMES(varnames)"
   parse var keynames "(" keynames ")"
   parse var varnames "(" varnames ")"
   keynmes  = keynames
   varnmes  = varnames
   allnames = keynames varnames
   wordct   = Max(1,Words(allnames))
   collen   = 8
   if Words(allnames) < 9 then,
      collen = (maxusable-3) % wordct
 
return                                 /*@ BCA_GETNAMES              */
/*
.  ----------------------------------------------------------------- */
BCH_HEADERS:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   slug   = "+S"                       /* P1 column header           */
   dashes = "+-"
   zees   = "14"x"Z"
   zvarlist   = "(ZCMD $S$"
   cols   = slug                       /* P1 column header           */
   do bchx = 1 to Words(allnames)
      var = Word(allnames,bchx)
      slug  = slug Left(var,collen-1)
      if Length(slug) > maxusable then leave  /* too long            */
      cols   = slug
      dashes = dashes Copies("-",collen-1)
      zees   =   zees || Left("?Z",collen)
      zvarlist   = zvarlist var
   end                                 /* forever                    */
   zvarlist = zvarlist")"
   zees   =   zees"+"
   if Length(cols) < 4 then cols = cols,
   "#    ....No KEYS....    ....No NAMES...."
 
return                                 /*@ BCH_HEADERS               */
/*
.  ----------------------------------------------------------------- */
BCP_LOADP1:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   daid   = daid.PLIB                  /* set the proper DATAID      */
 
   queue ")ATTR                                                     "
   queue " #    TYPE(TEXT)    INTENS(HIGH)                          "
   queue " 14   TYPE(INPUT)   INTENS(LOW)   PAD('.')   CAPS(ON)     "
   queue " ?    TYPE(OUTPUT)  INTENS(HIGH)  SKIP(ON)                "
   queue ")BODY EXPAND(||)   WIDTH(&ZSCREENW)                       "
   queue "+|-|-#TABLE" tblid "("thisds")+-|-|                       "
   queue "%COMMAND ===>_Z                                           "
   queue "+       SORT <fld>,<typ>,<dir>  <fld>    L fld=value / F5=refind "
   queue cols
   queue dashes
   queue ")MODEL                                                    "
   queue zees
   queue ")INIT                                                     "
   queue "  .HELP = P1H                                             "
   queue "  .ZVARS = &ZVARLIST                                      "
   queue "  &ZSCROLLA = 'CSR'                                       "
   queue "  &$S$ = ' '                                              "
   queue ")REINIT                                                   "
   queue ")PROC                                                     "
   queue "   IF (.PFKEY = 'PF05')                                   "
   queue "       &PFKEY = 'F5'                                      "
   queue "       .RESP = END                                        "
   queue ")END                                                      "
   "LMOPEN DATAID("daid") OPTION(OUTPUT)"
   do queued()
      parse pull line
      "LMPUT DATAID("daid") MODE(INVAR) DATALOC(LINE)" ,
                        "DATALEN("zscreenw")"
   end
   "LMMADD DATAID("daid") MEMBER(P1)"
   "LMCLOSE DATAID("daid")"
 
return                                 /*@ BCP_LOADP1                */
/*
.  ----------------------------------------------------------------- */
BCQ_LOADP2:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if sw.4EDIT then vtypvals = "INPUT"
               else vtypvals = "OUTPUT  SKIP(ON)"
   parse var vtypvals    vtyp  vtypskip  .
 
   daid   = daid.PLIB                  /* set the proper DATAID      */
 
   queue ")ATTR                                                     "
   queue "  14   TYPE(INPUT) INTENS(LOW) PAD('.') CAPS(ON)          "
   queue "  !    TYPE("vtyp") INTENS(HIGH)" vtypskip
   queue "  ?    TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)                 "
   queue "  #    TYPE(TEXT)   INTENS(HIGH)                          "
   queue ")BODY EXPAND(||)   WIDTH(&ZSCREENW)                       "
   queue "+|-|-#TABLE" tblid "("thisds")+-|-|                       "
   queue "%COMMAND ===>_Z                                           "
   queue "+                                                         "
   queue "#VARIABLE  T  VALUE+                                      "
   queue "+                                                         "
   queue ")MODEL                                                    "
   queue "?Z        ?Z !Z                                           "
   queue ")INIT                                                     "
   queue "  .HELP = P2H                                             "
   queue "  .ZVARS='( ZCMD          XVAR XTYPE XVALUE )'            "
   queue "  &ZSCROLLA = 'CSR'                                       "
   queue ")END                                                      "
   "LMOPEN DATAID("daid") OPTION(OUTPUT)"
   do queued()
      parse pull line
      "LMPUT DATAID("daid") MODE(INVAR) DATALOC(LINE)" ,
                        "DATALEN("zscreenw")"
   end
   "LMMADD DATAID("daid") MEMBER(P2)"
   "LMCLOSE DATAID("daid")"
 
return                                 /*@ BCQ_LOADP2                */
/*
.  ----------------------------------------------------------------- */
BD_SHOW_TABLE:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LIBDEF  ISPPLIB  LIBRARY  ID("$ddn.PLIB") STACK"
   "VGET (ZPF05) PROFILE"
   save_f5 = zpf05
   $S$       = ""                      /* init                       */
   do forever
                               zpf05 = "END"  ; "VPUT (ZPF05) PROFILE"
      "TBDISPL" tblid "PANEL(P1)"
      disp_rc = rc
                               zpf05 = save_f5; "VPUT (ZPF05) PROFILE"
      if disp_rc > 8 then do
         zerrlm = exec_name "("BRANCH("ID")")",
                  zerrlm ,
                  "K:"keynmes "N:"varnmes
         "SETMSG  MSG(ISRZ002)"
         sw.0error_found = "1"
         "EDIT DATAID("daid.PLIB") MEMBER(P1)"
         leave
         end
 
      if disp_rc = 8 then,
         if pfkey = "F5" then call Z_REFIND        /*               -*/
                         else leave
 
      if zcmd <> "" then do
         call BDC_ZCMD                 /*                           -*/
         end ; else,
      do ztdsels
         upper $S$                     /* action field               */
         if $S$ = "D" then "TBDELETE" tblid
         else do
            "TBGET" tblid "SAVENAME(xvars)"
            call BDA_BUILD_ROW
            call BDB_SHOW_ROW
            end
         if ztdsels = 1 then,          /* never do the last one      */
            ztdsels = 0
         else "TBDISPL" tblid          /* next row                  #*/
      end                              /* ztdsels                    */
      $S$    = ""                      /* clear for re-display       */
   end                                 /* forever                    */
   "LIBDEF  ISPPLIB"
 
return                                 /*@ BD_SHOW_TABLE             */
/*
.  ----------------------------------------------------------------- */
BDA_BUILD_ROW:                          /*@                           */
   if branch  then call BRANCH
   address ISPEXEC
 
   "TBCREATE XTABLE NOWRITE REPLACE KEYS(XVAR) NAMES(XTYPE XVALUE)"
   parse var xvars "(" xvars ")"
   xtype = "K"
   keynames = keynmes
   do while keynames <> ""
      parse var keynames xvar keynames
      xvalue = Value(xvar)
      "TBADD  XTABLE"
   end                                 /* keynames                   */
   xtype = "N"
   varnames = varnmes
   do while varnames <> ""
      parse var varnames xvar varnames
      xvalue = Value(xvar)
      "TBADD  XTABLE"
   end                                 /* varnames                   */
   xtype = "S"
   do while xvars    <> ""
      parse var xvars    xvar xvars
      xvalue = Value(xvar)
      "TBADD  XTABLE"
   end                                 /* xvars                      */
 
return                                 /*@ BDA_BUILD_ROW             */
/*
.  ----------------------------------------------------------------- */
BDB_SHOW_ROW: Procedure expose,        /*@                           */
   (tk_globalvars) tblid keynames varnames xvars
   if branch  then call BRANCH
   address ISPEXEC
 
   "CONTROL DISPLAY SAVE"
   "TBTOP   XTABLE"
   call BDBA_PROCESS_ROW               /*                           -*/
   "TBEND   XTABLE"
   "CONTROL DISPLAY RESTORE"
 
return                                 /*@ BDB_SHOW_ROW              */
/*
.  ----------------------------------------------------------------- */
BDBA_PROCESS_ROW:                      /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   sw.0KeyChange = "0"
   do forever
      "TBDISPL XTABLE PANEL(P2)"
      if zcmd <> "" then do
         upper zcmd
         if zcmd = "UPDATE" then do
            call BDBAL_LOAD_MAIN       /*                           -*/
            leave
            end                        /* UPDATE                     */
         end                           /* zcmd                       */
      if rc > 4 then leave             /* PF3 ?                      */
      do ztdsels
         if xtype = "K" then sw.0KeyChange = "1" /* Use TBADD */
         "TBMOD  XTABLE"
         $a$ = xvar                    /* for TRAPOUT purposes       */
         $b$ = xtype
         $c$ = xvalue
         if ztdsels = 1 then,          /* never do the last one      */
            ztdsels = 0
         else "TBDISPL XTABLE"         /* next row                  #*/
      end                              /* ztdsels                    */
      "TBTOP  XTABLE"
 
   end                                 /* forever                    */
 
return                                 /*@ BDBA_PROCESS_ROW          */
/*
.  ----------------------------------------------------------------- */
BDBAL_LOAD_MAIN:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBTOP XTABLE"
   do forever
      "TBSKIP XTABLE"
      if rc > 0 then leave
      if xtype = "S" then xvars = Space(xvars xvar,1)
      $z$ = Value(xvar,xvalue)         /* load xvalue into xvar      */
      $a$ = xvalue
   end
   "TBMOD" tblid "SAVE("xvars")"       /* update the main table      */
 
return                                 /*@ BDBAL_LOAD_MAIN           */
/*
.  ----------------------------------------------------------------- */
BDC_ZCMD:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   parse var zcmd  verb  text
   if verb = "TPRINT" then do
      hdr. = 0                         /* force re-do headers        */
      call BDCP_PRINT                  /*                           -*/
      end                              /* PRINT                      */
             else,
   if verb = "STATS" then do
      call BDCQ_STATS                  /*                           -*/
      end                              /* STATS                      */
             else,
   if verb = "SORT" then do
      call BDCS_SORT                   /*                           -*/
      end                              /* SORT                       */
             else,
   if Wordpos(Left(verb,1),"F L") > 0 then do
      parse var text  fld . "=" val .
      if Symbol(fld) = "BAD" then do
         zerrsm = "Typo!"
         zerrlm = "Field-name" fld "is invalid."
         "SETMSG  MSG(ISRZ002)"
         return
         end                           /* typo                       */
      "TBVCLEAR" tblid
      $z$ = Value(fld,val"*")          /* load value                 */
      "TBSARG" tblid "NAMECOND("fld",EQ)"
      "TBTOP" tblid
      call Z_TBSCAN                    /*                           -*/
      end                              /* L LOCATE F FIND            */
 
return                                 /*@ BDC_ZCMD                  */
/*
   Print the table
.  ----------------------------------------------------------------- */
BDCP_PRINT:                            /*@                           */
   pp_tv = trace()                     /* what setting at entry ?    */
   if branch then call BRANCH
   address ISPEXEC
 
   address TSO "NEWSTACK"
   if \sw.0scanned then,               /* table has not been scanned */
      call BDCPA_SCAN                  /*                           -*/
 
   call BDCPH_HEADERS                  /*                           -*/
 
   "TBTOP" tblid
   parse value "0" with  linect asa
   do forever
      "TBSKIP" tblid "SAVENAME(XVARS)" /* next row                   */
      if rc > 0 then leave
 
      call BDCPF_FORMAT_LINE           /*                           -*/
      linect = linect + 1
      asa = ""
 
      if linect > 55 then do           /* end-of-page                */
         parse value "0 1" with  linect asa .
         call BDCPH_HEADERS            /*                           -*/
         end
   end                                 /* forever                    */
                                     rc = Trace("O"); rc = trace(pp_tv)
   qcount = queued()                   /* how many lines ?           */
   call BDCPP_WHAT_PRINTER             /*                           -*/
 
   call BDCPW_WRITEQ                   /* put queue to printer      -*/
   address TSO "DELSTACK"
 
return                                 /*@ BDCP_PRINT                */
/*
   Scan the table to determine the maximum length of each variable.
   A short variable may have a longer name, and we want to
   accomodate that.  Ignore extension variables.
.  ----------------------------------------------------------------- */
BDCPA_SCAN:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   do pt = 1 to Words(allnames)
      name = Word(allnames,pt)         /* the variable name          */
      if ll.name < Length(name) then,
         ll.name = Length(name)
   end
 
   "TBTOP" tblid
   do forever
      "TBSKIP" tblid
      if rc > 0 then leave             /* end of table               */
      do pt = 1 to Words(allnames)
         name = Word(allnames,pt)
         ll = Length(Value(name))      /* length of data             */
         if ll.name < ll then,         /*                            */
            ll.name = ll               /* save bigger value          */
      end                              /* pt                         */
   end                                 /* forever                    */
 
   sw.0scanned = '1'
 
   if monitor then do
      do pt = 1 to Words(allnames)
         name = Word(allnames,pt)
         say Right(name,9) ll.name
      end                              /* pt                         */
      end
 
return                                 /*@ BDCPA_SCAN                */
/*
   This is very dependent upon the shape of the table as determined
   in BCA_GETNAMES.  Also, each line may have extension variables.
.  ----------------------------------------------------------------- */
BDCPF_FORMAT_LINE:                     /*@                           */
   if branch then call BRANCH
   address TSO
 
   line = ""
   do bhx = 1 to Words(localnames)
      token = Word(localnames,bhx)
      line  = line Left(Value(token),ll.token)
   end                                 /* bhx                        */
   queue line
 
return                                 /*@ BDCPF_FORMAT_LINE         */
/*
   Queue header-records
.  ----------------------------------------------------------------- */
BDCPH_HEADERS:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   if hdr.0 = 0 then,                  /* TRUE only if never called  */
      call BDCPH0_SETUP                /* build column headers      -*/
 
   do hx = 1 to hdr.0                  /* each header                */
      queue hdr.hx
   end                                 /* hx                         */
 
return                                 /*@ BDCPH_HEADERS             */
/*
   Build column-headers
.  ----------------------------------------------------------------- */
BDCPH0_SETUP:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   call BDCPH0S_LOCALNAMES             /* sets localnames           -*/
   parse value "2" with hdr.0 hdr.1 hdr.2
 
   do bhx = 1 to Words(localnames)     /* for each localname         */
      token = Word(localnames,bhx)     /* isolate one                */
      hdr.1 = hdr.1 Center(token,ll.token) /* center in its slot     */
      hdr.2 = hdr.2 Copies("-",ll.token)   /* dashes for underscores */
   end                                 /* bhx                        */
 
   maxlen = Length(hdr.2)              /* dashes                     */
   hdr.1 = Overlay("1",hdr.1,1,1)      /* insert paqe-eject          */
 
return                                 /*@ BDCPH0_SETUP              */
/*
   Allow the caller to exclude fields from the print-spec and to
   arrange the others in proper order.
.  ----------------------------------------------------------------- */
BDCPH0S_LOCALNAMES:                    /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBCREATE $ARR KEYS(FLDNAME) NAMES(PRI ARMSG) NOWRITE REPLACE"
   pri = 0
   do bhx = 1 to Words(allnames allxvars)
      fldname = Word(allnames allxvars,bhx)
      armsg = ""
      pri = pri + 5
      "TBADD $ARR"                     /* load name to $ARR table    */
   end                                 /* bhx                        */
 
   sel    = ""                         /* init                       */
   do forever
      call BDCSC_CLIST("$ARR PRI,N,A  OFF")    /* Sort              -*/
      "TBTOP    $ARR"
      "TBDISPL  $ARR  PANEL(ARRANGE)"
      if rc > 4 then leave             /* PF3 ?                      */
 
      do ztdsels
 
         select
 
            when sel = "X" then do
               if armsg = "" then do
                  armsg = "Excluded"   /* mark EXCLUDED              */
                  pri   = 999          /* push to bottom             */
                  end
               else parse value 998 with pri armsg
               end
 
            otherwise nop
 
         end                           /* select                     */
 
         "TBMOD $ARR"                  /* reload changed line        */
 
         if ztdsels > 1 then "TBDISPL  $ARR"
 
      end                              /* ztdsels                    */
 
      sel = ""
 
   end                                 /* forever                    */
 
   localnames = ""
   do forever
      "TBSKIP $ARR"                    /* next row                   */
      if rc > 4 then leave             /* end of table?              */
      if armsg <> "" then leave        /* no EXCLUDED lines          */
      localnames = localnames fldname  /* add name to list           */
   end                                 /* forever                    */
   "TBEND $ARR"                        /* finished with table        */
 
return                                 /*@ BDCPH0S_LOCALNAMES        */
/*
   Ask the user where they want it printed.
.  ----------------------------------------------------------------- */
BDCPP_WHAT_PRINTER:                    /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   zwinttl = "Target Printer"
   "VGET ZPFCTL"; save_zpf = zpfctl    /* save current setting       */
      zpfctl = "OFF"; "VPUT ZPFCTL"    /* PFSHOW OFF                 */
   "ADDPOP ROW(8) COLUMN(10)"
   "DISPLAY PANEL(PRTCONF)"
   disp_rc = rc
   "REMPOP ALL"
      zpfctl = save_zpf; "VPUT ZPFCTL" /* restore                    */
 
return                                 /*@ BDCPP_WHAT_PRINTER        */
/*
   Flush the queue to the printer
.  ----------------------------------------------------------------- */
BDCPW_WRITEQ:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   maxrecl = maxlen + 4
 
   if prtcls <> "0" then do
      "ALLOC FI($PRT) NEW REU DELETE UNIT(VIO) SPACE(1 5) TRACKS",
               "RECFM(V B A) LRECL("maxrecl") BLKSIZE(0)"
      "EXECIO" queued() "DISKW $PRT (FINIS"
      "PRINTDS FILE($PRT) CCHAR CLASS("prtcls") DEST("prtdest") "
      zerrsm = "Printed"
      zerrlm = "Printed" qcount "records via PRINTDS to",
               "Class" prtcls", Dest" prtdest
      end                              /* Printed                    */
   else do                             /* prtcls was zero            */
      outdsn = "@@."tblid".LIST"
      if Sysdsn(outdsn) = "OK" then do
         $oldstat = Msg("OFF")
         "DELETE" outdsn
         $z$      = Msg($oldstat)
         end
      "ALLOC FI($PRT) NEW REU CATALOG UNIT(SYSDA) SPACE(1 5) TRACKS",
            "DA("outdsn")",
            "RECFM(V B A) LRECL("maxrecl") BLKSIZE(0)"
      "EXECIO" queued() "DISKW $PRT (FINIS"
      zerrsm = "Not printed"
      zerrlm = qcount "print records were spooled to",
               "dataset" tblid".LIST",
               "because",
               "Class" prtcls "was specified."
      end                              /* Not Printed                */
   "FREE  FI($PRT)"
   address ISPEXEC "SETMSG  MSG(ISRZ002)"
 
return                                 /*@ BDCPW_WRITEQ              */
/*
   Retrieve stats for the table and present them in a pop-up.
  'TBSTATS' tablenam 'CDATE('cdatname') CTIME('ctimname'),
            UDATE('udatname') UTIME('utimname') USER('username'),
            ROWCREAT('rcrtname') ROWCURR('rcurname'),
            ROWUPD('rupdname') TABLEUPD('tupdname'),
            SERVICE('servname') RETCODE('retcname'),
            STATUS1('sta1name') STATUS2('sta2name'),
            STATUS3('sta3name') LIBRARY('libname'),
            CDATE4D('cdat4dnm') UDATE4D('udat4dnm')'
       'LMMSTATS DATAID('dataid')   MEMBER('mbrname') VERSION('ver1'),
                 MODLEVEL('mod1')  CREATED('cdate') MODDATE('mdate'),
                 MODTIME('mtime')  CURSIZE('csize') INITSIZE('isize'),
                 MODRECS('mrecs')   USER('userid') CREATED4('cdate4'),
                 MODDATE4('mdate4') DELETE'
.  ----------------------------------------------------------------- */
BDCQ_STATS:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBSTATS" tblid,
           "CDATE(cdatname)       CTIME(ctimname)",
           "UDATE(udatname)       UTIME(utimname)         USER(username)",
           "ROWCREAT(rcrtname)    ROWCURR(rcurname)",
           "STATUS1(sta1    )     STATUS2(sta2    )",
           "STATUS3(sta3    )",
           "CDATE4D(cdat4dnm)     UDATE4D(udat4dnm)"
 
   sta1.1 = "Exists in library chain"
   sta1.2 = "Does not exist in library chain"
   sta1.3 = "ISPTLIB not allocated"
   sta2.1 = "Table not open"
   sta2.2 = "NOWRITE"
   sta2.3 = "WRITE"
   sta2.4 = "SHARED NOWRITE"
   sta2.5 = "SHARED WRITE"
   sta3.1 = "Available for WRITE"
   sta3.2 = "Not available for WRITE"
   sta1rsn = sta1.sta1
   sta2rsn = sta2.sta2
   sta3rsn = sta3.sta3
   "CONTROL DISPLAY SAVE"
   "VGET ZPFCTL"; save_zpf = zpfctl       /* save current setting    */
   zpfctl = "OFF"; "VPUT ZPFCTL"          /* PFSHOW OFF              */
   "ADDPOP ROW(2) COLUMN(3)"
   "DISPLAY PANEL(TBSTATS)"
   "REMPOP ALL"
   zpfctl = save_zpf; "VPUT ZPFCTL"       /* restore                 */
   "CONTROL DISPLAY RESTORE"
 
return                                 /*@ BDCQ_STATS                */
/*
   Sort the table
.  ----------------------------------------------------------------- */
BDCS_SORT:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   zerrlm       = ""
   sortspec     = ""
   do while text <> ""
      parse var text     spec text
      parse var spec     fldnm "," fldtyp "," sortdir
      parse value     fldtyp "C"  with  fldtyp  .
      parse value sortdir "A"     with sortdir  .
 
      if WordPos(fldnm,allnames) = 0 then do     /* wrong name       */
         zerrsm = "Sortspec error"
         zerrlm = zerrlm " Incorrect name: you specified >"fldnm"<. ",
                  "The valid field names for this table are >",
                  Space(allnames,1)"<. "
         end                           /* bad fldnm                  */
      if Pos(fldtyp,"CN") = 0 then do            /* wrong type       */
         zerrsm = "Sortspec error"
         zerrlm = zerrlm " Incorrect type: you specified >"fldtyp"<. ",
                  "The valid field types are >C N<."
         end
      if Pos(sortdir,"AD") = 0 then do           /* wrong dir        */
         zerrsm = "Sortspec error"
         zerrlm = zerrlm " Incorrect DIR: you specified >"sortdir"<. ",
                  "The valid sort directtions are >A D<."
         end
      if zerrlm <> "" then do          /* error                      */
         zerrlm = Strip(zerrlm " Sort was not done.")
         "SETMSG  MSG(ISRZ002)"
         return
         end
 
      sortspec = sortspec fldnm","fldtyp","sortdir
   end                                 /* text                       */
 
   sortspec = Space(sortspec,1)        /* squeeze out extra blanks   */
   sortspec = Translate(sortspec,","," ")       /* blanks to commas  */
 
   call BDCSC_CLIST(tblid sortspec "OFF")      /*                   -*/
 
   if rc > 0 then do
      zerrsm     = "TBSORT failed."
      zerrlm     = exec_name "("BRANCH("ID")")",
                zerrlm
      "SETMSG     MSG(ISRZ002)"
      end
 
return                                 /*@ BDCS_SORT                 */
/*
.  ----------------------------------------------------------------- */
BDCSC_CLIST: Procedure expose,         /*@                           */
      (tk_globalvars)
   if branch then call BRANCH
   address TSO
   arg $tn$ sortseq debug
 
   address ISPEXEC "VPUT ($TN$ SORTSEQ DEBUG) SHARED"
 
   "ALTLIB ACT   QUIET APPLICATION(CLIST) DSNAME('DTAFXC.@@.CLIST')"
   "%TBLSORT"
   "ALTLIB DEACT QUIET APPLICATION(CLIST)"
 
return                                 /*@ BDCSC_CLIST               */
/*
   Drop LIBDEFs
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
   Position the cursor, then TBSCAN
.  ----------------------------------------------------------------- */
Z_REFIND:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBSKIP" tblid "ROW("lastfnd") NOREAD"
   call Z_TBSCAN                       /*                           -*/
   pfkey = ""                          /* prevent re-use             */
 
return                                 /*@ Z_REFIND                  */
/*
   The table is positioned to find a row and the argument is set.
.  ----------------------------------------------------------------- */
Z_TBSCAN:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBSCAN" tblid "ROWID(LASTFND) POSITION(LASTCRP)"
   if rc = 8 then do                   /* not found                  */
      zerrsm = "Not found"
      if pfkey = "F5" then,
         zerrlm = "End of table encountered."
      else,
         zerrlm = "No rows found to match" fld"="val
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      end                              /* not found                  */
   "TBSKIP" tblid "ROW("lastfnd") NOREAD"
 
return                                 /*@ Z_TBSCAN                  */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   if branch then call BRANCH
   address TSO
 
return                                 /*@ LOCAL_PREINIT             */
/*
   Parse out the embedded components at the back of the source code.
.  ----------------------------------------------------------------- */
DEIMBED: Procedure expose,             /*@                           */
   (tk_globalvars)  ddnlist  $ddn.  daid.
 
   address TSO
 
   address ISPEXEC "VGET (ZSCREENW)"
   fb80po.0  = "NEW UNIT(VIO) SPACE(5 5) TRACKS DIR(40)",
                   "RECFM(F B) LRECL("zscreenw") BLKSIZE(0)"
   parse value ""   with  ddnlist $ddn.  daid.
 
   lastln   = sourceline()
   currln   = lastln
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
. -------------------------------------------------------------------*/
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"      Displays any specified table.                             "
say "                                                                          "
say "  Syntax:   "ex_nam"  <tblname>                                           "
say "                      <TBLIB tbllib>  (or)                                "
say "                      <IN    tbllib>                                      "
say "                      <UPDATE>                                            "
say "                                                                          "
say "            <tblname> identifies the member in an ISPTLIB library to be   "
say "                      viewed/updated.                                     "
say "                                                                          "
say "            <tbllib>  identifies the ISPF Table Library from which to     "
say "                      retrieve the table.                                 "
say "                                                                          "
say "            <UPDATE>  (a switch in PARMS) requests that <tblname> be made "
say "                      available for changes.                              "
say "                                                                          "
"NEWSTACK"; pull; "CLEAR"; "DELSTACK"
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
/* --------------- REXXSKEL back-end removed for space ------------- */
/*
)))PLIB PRTCONF
)ATTR
    %  TYPE(TEXT)   INTENS(HIGH)   SKIP(ON)
    +  TYPE(TEXT)   INTENS(LOW) SKIP(ON)
    _  TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
    {  TYPE(OUTPUT) INTENS(HIGH) JUST(RIGHT)
)BODY WINDOW(60,7)
+
+
%    {qcount+lines to print
%    {maxlen+(longest line)
+
+    Class ===>_z+        Use Class%0+to suppress print.
+     Dest ===>_prtdest+
)INIT
   .ZVARS = '(PRTCLS)'
)PROC
)END
)))PLIB TBSTATS
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT)  INTENS(LOW) CAPS(ON)
  @ TYPE(TEXT)   INTENS(HIGH) COLOR(YELLOW)
  ! TYPE(INPUT)  INTENS(NON)
  { TYPE(OUTPUT) INTENS(HIGH) SKIP(ON) CAPS(OFF)
)BODY WINDOW(68,12)
@   % Statistics for{tblid   +
+
+  Created     :{cdatname{ctimname+     Rows then:{rcrtname+
+               {cdat4dnm
+
+  Last Updated:{udatname{utimname+     Rows now :{rcurname+
+               {udat4dnm             + By ::>{username
+
+  S1:{sta1   {sta1rsn
+  S2:{sta2   {sta2rsn
+  S3:{sta3   {sta3rsn
)INIT
)PROC
)END
)))PLIB P1H
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%TUTORIAL บ-บ Table Overview บ-บ TUTORIAL
%Next Selection ===>_ZCMD
 
+
    This panel (P1) shows all rows from the named table.  The panel's
    header also shows the name of the dataset in which it was found.
 
    You may select any row(s) for a display of the individual fields
    which may be larger than the canonical 8-characters shown on this
    display.  Further, any extension variables which are specific to
    a row will be shown on the Row Detail display.
 
    Primary commands recognized:  L, SORT, TPRINT
%      L    + <fldnm=value>
%      SORT+  <sortspec>
              "sortspec" is one or more of <fldnm,type,dir>
                  with "dir" defaulting to "A" (ascending)
                  and "type" defaulting to "C" (character).
%      TPRINT +
)PROC
)END
)))PLIB P2H
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%TUTORIAL บ-บ Row Detail บ-บ TUTORIAL
%Next Selection ===>_ZCMD
 
+
    This panel (P2) displays the contents of a single table row.  Fields are
    designated as%"K"+(key),%"N"+(name), or%"S"+(extension).
 
    If the data on the panel is changed%and+you are authorized to write on the
    ISPTABL dataset, the changes may be set with the primary command%UPDATE.+
)PROC
)END
)))PLIB ARRANGE
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH) CAPS(ON)
  # TYPE(INPUT)  INTENS(HIGH) JUST(RIGHT)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%บ-บ Field Arrangement +บ-บ
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
 + "X" to mark "non-print"
/
V  Field    Position
)MODEL
_z!fldname + #pri+   @armsg
)INIT
  .ZVARS = '(SEL)'
  .HELP = ARRH
)REINIT
)PROC
  IF (.PFKEY = 'PF05')
      &PFKEY = 'F5'
      .RESP = END
)END
)))PLIB ARRH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(บบ) WIDTH(&ZSCREENW)
%TUTORIAL บ-บ Row Detail บ-บ TUTORIAL
%Next Selection ===>_ZCMD
 
+
    Panel%ARRANGE+allows you to specify which columns to print and in what
    order.  The%Position+value shown is relative; it is used only to determine
    which field is leftmost and which rightmost.  To place a column between two
    others, change its position number appropriately.
 
    You may%X+any column to exclude it from the output.
)PROC
)END
*/
