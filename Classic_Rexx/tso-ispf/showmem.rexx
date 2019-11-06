/* REXX    SHOWMEM    Display a requested member list with ISPF stats
                      in a TBDISPL format.  Allows users to browse,
                      edit, print, delete, acquire and roll members.
                      Acquire and Roll were built for the CM Tools
                      group.
 
           Written by Chris Lewis 950426
 
     Impact Analysis
.    ISPPLIB   POP50BY4
.    ISPPLIB   SHOWMEM
.    ISPPLIB   SHOWMEM#
.    ISPPLIB   SMACQUR
.    ISPPLIB   SMACQURE
.    ISPPLIB   SMCONFRM
.    ISPPLIB   SMCOPY
.    ISPPLIB   SMDELTE
.    ISPPLIB   SMNDM
.    ISPPLIB   SMPRINTN                   customized for NMR
.    ISPPLIB   SMROLL
.    ISPPLIB   SMROLLE
.    ISPPLIB   SMSIGNE
.    SYSPROC   HURL                       ship dataset via NDM
.    SYSPROC   ICEUSER      DSName hard-coded
.    SYSPROC   LA                         LISTA to stack
.    SYSPROC   LCLPRTRX                   PRINT environment
.    SYSPROC   MEMBERS                    Memberlist to stack
.    SYSPROC   PDSCOPY                    Member-copy
.    SYSPROC   PDSCOPYD                   Member-copy
.    SYSPROC   SHOWDDNM                   Valid DDNames
.    SYSPROC   SHOWPARM                   Additional datasets
.    SYSPROC   SHOWTASK                   Front end for task system
.    SYSPROC   SMARCH                     Identify archive datasets
.    SYSPROC   SMENDV                     Identify Endevor parms
.    ISPPLIB   SMHELP
.    SYSPROC   SMMAP                      Identify order of ENDV datasets
.    SYSPROC   SMNDM                      Identify NDM sites
.    SYSPROC   SMPKG                      Identify package components
.    SYSPROC   SMPREF                     Set default dataset prefix
.    SYSPROC   SMULOG
.    SYSPROC   TRAPOUT                    Trap trace output
.    SYSPROC   UPOE@#ST     DSName hard-coded
.    SYSPROC   VPSPRINT
 
     Modification History
     19950426 fxc moved LISTALL and QUIET setting above 'info=parms';
                  forces QUIET and LISTALL to be specified in OPTS;
     19950426 ctl fixed problem with missing ddname on ACQUIRE and ROLL
                  and problem with CZ_CONFIRM; Made DDNAME a key field
                  on table.
     19950502 fxc use LCLPRTRX to determine default printer-id
     19950509 ctl CM Tools converted to ENDEVOR.  ACQUIRE, DELETE and
                  ROLL options were modified to perform endevor actions.
                  New option of COPY added.
     19950525 ctl Only delete from table when delete behind specified.
     19950612 ctl Comment is set incorrectly
     19950626 ctl Add signin feature.
     19950628 ctl For everyone except DTCDPO1 the name of the save dsn
                  is EXEC for ddname SYSPROC and SYSEXEC.  For Don it is
                  still CLIST.  This change was made because Frank and
                  Chris prefer SAVE.EXEC rather than SAVE.CLIST
     19950703 ctl Reset comment to blanks after provoking endevor
     19950711 fxc upgrade REXXSKEL; enable PROCLIB, JCLLIB, SORCELIB,
                  and DOCLIB; reversed chg/0628: DTCDPO1 now uses EXEC;
     19950724 ctl Acquire must be ENDV dataset.
     19950808 ctl Add keywd of ACTION to call to SHOWTASK.  Fix problem
                  with call to SHOWTASK in C_COPY paragraph.
     19951108 ctl Upgrade REXXSKEL from 950620.  Allow deletes from
                  CNFG.  Add ability to perform global searches.  Remove
                  popup (always run quiet).  Add L option to browse
                  member list.  Add help panels.  Insert logic to
                  determine if acquire and roll should invoke endevor.
                  Modify COPY option to be a pseudo-roll.  Give option
                  of archiving on a delete to archive datasets.
     19951114 ctl Do not update table for ENDV delete
     19951127 ctl For ENDV ADDs element & member names may be different
     19951203 dpo Log ENDEVOR "roll" actions; update REXXSKEL
     19951226 ctl Upgrade REXXSKEL from 951129; Call external routine
                  SHOWDDNM to get list of valid ddnames; Improve logic
                  for wildcard searches; Remove LISTALL; Add ISPF stats
                  to the log for 'roll' actions.
     19960124 fxc enable "F" and "T" actions for repopulating one member
                  to multiple others with stats... especially for
                  REXXSKEL;
     19960131 fxc always allocate SYSIN and SYSPRINT to DA(*) when no
                  longer required;
     19960212 ctl Merge overlayed code with recent changes.  Change
                  951226 was overlayed.  Upgrade REXXSKEL from
                  ver.951211 to ver 960119.  Add option 'N' to ship
                  dataset/member to other sites using NDM.  On ADD
                  (roll) to ENDEVOR invoke NDM to ship material to TPA.
                  This provides a backup in TPA with ISPF stats.
     19960319 ctl For an ADD then always make copy to SAVE datasets and
                  send the member to T2 prod dsn.
     19960328 ctl Initalize the variables for the ISPF stats.  These
                  variables are not initialized from lmmfind on a
                  loadlib.
     19960509 ctl SETMSG if backup fails
     19960528 ctl Do not delete from table when delete not requested for
                  endevor signin
     19960619 sep Check ISPF version to determine whether to use BROWSE
                  or VIEW when 'BROWSE' is selected from panel.  If ISPF
                  version is 4.2 or greater, use VIEW.
     19960701 ctl Make sure delete completed before tbdelete
     19960729 ctl Backup on ADDs; not on MOVEs
     19970506 ctl Upgrade REXXSKEL ver.960119 to ver.970211.  Rewrite to
                  accomdate non-Endevor needs.  General Cleanup
     19970604 fxc parse at l.567 missing comma; Les Koehler sez Don't
                  waste 72 bytes for a blank line (trim unused
                  comments); changed rcx to ndvrc in cz_invoke_endevor;
     19970605 fxc novalue on todsn at l.667;
     19970618 ctl Upgrade REXXSKEL from ver.970211 to ver.970609.  Build
                  variable to contain list of variables to expose in
                  procedure paragraphs (fixes novalue)
     19970715 fxc fix <hurl_parm> at 873; s/b <hurl_parms>;
     19970818 ctl Upgrade REXXSKEL from ver.970609 to ver.970818.
                  zwinttl not set in CAC_COPY; fix problem in CB.
     19970829 ctl Call SMPREF to determine default prefix to search for
                  during an ACQUIRE.
     19970908 jpb Add "V" as an alternate action for browse/view.
     19970929 ctl Add "X" to loc if numeric in CAP_PRINT.  This is due
                  to an odd quirk in XEROXPRT where the numeric
                  locations are followed with an "X".
     19971021 fxc only do memberlist once per dsn
     19980608 fxc DIAGNOSE
     19980618 fxc add <never_search> capability
     19980707 fxc enable 'member delete' via LMMDEL
     19991006 fxc enable monitor=diagnose; enable "I" action for
                  incompatible DCBs; add ddname to TBMOD-after-update
                  (use existing DDN if any);
     19991109 fxc upgrade from v.970818 to v.19991109; RXSKLY2K;
     20010403 fxc finally added HELP-text; upgrade for NMR where
                  IEBCOPY is unavailable in foreground;
     20010424 fxc drop all Endevor-specific code; switch to PRINTDS;
                  SNIP all lines to 80 bytes or less; add support for
                  aliases in memberlists;
     20010816 fxc save from roll-target (not roll-source)           
     20011010 fxc reset <never_search>; add concat-seq to table;    
                  add <never_use_DD>
 
*/ arg argline
address ISPEXEC                        /* REXXSKEL ver.19991109      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
"CONTROL ERRORS RETURN"
 
call A_INIT                            /* call LA & build a list    -*/
call B_PROCESS_INPUTS                  /* of valid ddnames.  Load    */
 
"TBSTATS" showtbl "ROWCURR(ROWNUM)"
   if rownum > 0 then                  /* If there are rows in the   */
      call C_DISPLAY                   /* table then start the MAZE -*/
   else do
      zerrsm = "None Found"
      zerrlm = "No matches found for MEMBER LIST("strip(memlist)")",
               "and for DDNAME LIST("save_ddnames")"
      "SETMSG MSG(ISRZ002)"
      end                              /* else (rownun)              */
 
"TBEND" showtbl
 
/*   ZB_SAVELOG                                                      -*/
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit
/*
   Initialize variables build qualifer arrays create the temp table
   Building the mapping rules and build array for endevor libs.
.  ----------------------------------------------------------------- */
A_INIT:                                /*@ SHOWMEM                   */
   if branch then call BRANCH
   address TSO
 
   nicknames = KEYPHRS(".PKGS")
 
   call A0_SETUP_LOG                   /*                           -*/
 
   parse var info input_list           /* preserve info for later    */
 
   parse value "0 0 0 0 0 0 0 0 0 0 0"  with ,
                seq.  ,
                .
   parse value "SHOW"Right(Time("S"),4,"#")  0      'efef'X  'ef'X  with ,
                showtbl                      endv.  xefef    xef         ,
                ddname.  ddnames  memlist  map.  mems.  dsns.  .
 
   parse value SMPREF() UserID()".ENDV" with, /*                    -*/
               pref  .
   call ZL_LOGMSG("Using SMPREF" pref)                        
 
   never_use_dd = "SYSLBC ISPLLIB EDCHKDD ISPTLIB ISPTABL"
   never_search = "ACNN.PR.D502.LIB.ISPSLIB",
                  "ACN1.PR.D292.STARTOOL.SKELS ACN1.ISRSLIB",
                  "ISP.SISPSLIB ISP.SISPSENU REXX.SFANSKL SYS1.DGTSLIB",
                  "ACNN.PR.D502.LIB.ISPPLIB ACN1.ISRPLIB ISP.SISPPENU",
                  "ISF.SISFPLIB ACNN.PR.D502.QUICKREF.PANELS",
                  "ACN1.PR.D292.STARTOOL.PANELS SYS1.DFQPLIB",
                  "SYS1.DGTPLIB ACNN.PR.D502.NDM.ISP.ISPPLIB",
                  "ACN1.PR.D502.SAR.ISPPLIB",
                  "ACN1.PR.D292.CA7.NS.CAIISPP",
                  "ACN1.PR.D502.CAI.CAIISPP EOY.SEOYPENU REXX.SFANPENU",
                  "SYS1.SBPXPENU ACNN.PR.D502.LIB.CLIST ACN1.SP.CLIST",
                  "ACNN.PR.D502.APPL.CLIST ISP.SISPCLIB ISP.SISPEXEC",
                  "ACN1.PR.D502.UCC7.REXX.EXEC",
                  "ACN1.PR.D292.CA7.NS.CAICLIB",
                  "ACN1.PR.D292.JCLCHECK.NS.CAICLIB",
                  "ACN1.PR.D292.STARTOOL.CLIST",
                  "ACN1.PR.D292.CA11.NS.CAICLIB",
                  "ACN1.PR.D502.CAI.CAICLIB EOY.SEOYCLIB SDF2.SDGICMD",
                  "REXX.SFANCMD REXX.SEAGCMD SYS1.DGTCLIB SYS1.SERBCLS",
                  "SYS1.SBPXEXEC ACNN.PR.D502.FILEAID.CLIST",
                  "ACNN.PR.D502.LIB.ISPMLIB",
                  "ACNN.PR.D502.QUICKREF.MESSAGES",
                  "ACN1.PR.D292.STARTOOL.MSGS ISP.SISPMENU",
                  "ISF.SISFMLIB ACN1.ISRMLIB SYS1.DFQMLIB SYS1.DGTMLIB",
                  "ACNN.PR.D502.NDM.ISP.ISPMLIB EOY.SEOYMENU",
                  "SYS1.SBPXMENU "
 
   expose_list = "OPTS XEF XEFEF DATASET MEMNAME NOUPDT NDMSITES"
 
   msg.0  = "Completed"
   msg.1  = "FAILED"
 
   "NEWSTACK"
   "SMMAP"                             /*                           -*/
   pull endv_list
   do queued()                         /* ddname dsntest dsnprod     */
      pull ddname  map.ddname          /* may be more than 1 token   */
      call ZL_LOGMSG("SMMAP:" Left(ddname,8) Strip(map.ddname) )
   end                                 /* queued()                   */
   "DELSTACK"
 
   do while endv_list <> ""            /* Turn on                    */
      parse var endv_list dsn endv_list
      endv.dsn = 1
   end
 
   address ISPEXEC
 
   "VGET ZENVIR SHARED"                /* ISPF Version info          */
 
   zenvir     = Substr(zenvir,6,3)     /* ISPF 4.2MVS .......        */
   viewopt.0  = "BROWSE"               /* Get version number         */
   viewopt.1  = "VIEW"
   viewopt    = zenvir >  3.5          /* Browse or View?            */
   viewopt    = viewopt.viewopt
 
   "TBCREATE" showtbl "KEYS(DATASET MEMNAME DDNAME)",
             "NAMES(VV MM CREATED CHANGED TIME SIZE",                
             "INIT MOD ID AL SEQ)",
             "NOWRITE REPLACE"
   "TBSORT"  showtbl "FIELDS(DDNAME,C,A , MEMNAME,C,A , SEQ,N,A)"
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
A0_SETUP_LOG:                          /*@                           */
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
   logdsn = "@@LOG."exec_name"."subid".LIST"
 
   call ZL_LOGMSG("Log started by" Userid()  yyyymmdd  hhmmss)
 
return                                 /*@ A0_SETUP_LOG              */
/*
   Build list of default and active ddnames.  Separate input parms
   into ddnames and members.  Build array indexed by ddname which
   contains the datasets to search for that ddname.
.  ----------------------------------------------------------------- */
B_PROCESS_INPUTS:                      /*@                           */
   if branch then call BRANCH
   address TSO
 
   call BA_ACTIVE_DDNAMES              /* sets valid_ddnames        -*/
   call BB_SPLIT_DDNAMES_FROM_MEMBERS  /*                           -*/
 
   call ZL_LOGMSG("DDNames:" ddnames)
   do idx = 1 to Words(ddnames)        /* Append to array anything   */
      ddname = Word(ddnames,idx)       /* that is in SHOWPARM        */
      dsns.ddname = dsns.ddname SHOWPARM(ddname) /* get more DSNs   -*/
      call ZL_LOGMSG("DSNames:" dsns.ddname)
      call X_TRIM_DSNLIST              /* remove duplicates         -*/
      call BX_GET_MEMS                 /*                           -*/
   end                                 /* idx                        */
 
   if Pos("*",memlist) > 0 then        /* Wilcard present            */
      call BC_WILDCARDS                /*                           -*/
   else
      call BD_MEMBER_SEARCH            /*                           -*/
 
   if nicknames = "" then nop
   else
      call BE_NICKNAMES
 
return                                 /*@ B_PROCESS_INPUTS          */
/*
   Create <valid_ddnames> to be used to verify the parameter string.
   SHOWDDNM provides any non-standard DDNames; LA provides the allocated
   DDNames and the DSNames that go with them.
.  ----------------------------------------------------------------- */
BA_ACTIVE_DDNAMES:                     /*@                           */
   ba_tv = Trace()                     /* what setting at entry ?    */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"                          /* Call external routine to   */
   "SHOWDDNM" ; pull valid_ddnames     /* get list of valid ddnames -*/
   call ZL_LOGMSG("Valid DDNames:" valid_ddnames)
   "DELSTACK"
 
   "NEWSTACK"                          /* array indexed by ddname    */
                                       /* that contains all datasets */
   "LA (( STACK LIST  "                /* allocated to that ddname. -*/
                                                  
   do queued()
      parse pull ddname ":" dsnames
      if Left(ddname,3) = "ISP" |,                                     
         Left(ddname,4) = "SYS0" |,                                    
         WordPos(ddname,never_use_DD) > 0 then iterate    /* ignore  */
      valid_ddnames = valid_ddnames ddname
                    /* If it's in <never_search>, drop from the list */
      token = ""                       /* init                       */
      do Words(dsnames)                /* every DSName               */
         parse value dsnames token   with  token dsnames
         if WordPos(token,never_search) > 0 then token = ""
      end
                                   $z$ = Trace("O"); $z$ = Trace(ba_tv)
      dsnames = Space(dsnames token,1) /* add last one back           */
 
      dsns.ddname   = Space(dsns.ddname   dsnames,1)
   end                                 /* queued                      */
                                   rc = Trace(ba_tv)
   "DELSTACK"
 
return                                 /*@ BA_ACTIVE_DDNAMES         */
/*
   Parse the main parameter string.  Any words which are in
   <valid_ddnames> are DDNames; everything else is a member name.  This
   might be a good place to call BE_ to attach package data.
.  ----------------------------------------------------------------- */
BB_SPLIT_DDNAMES_FROM_MEMBERS:         /*@                           */
   if branch then call BRANCH
   address TSO
 
   do until input_list = ""            /* member names to search for.*/
       parse var input_list name input_list
 
       if Wordpos(name,valid_ddnames) > 0 then do
          if Wordpos(name,ddnames) = 0 then
             ddnames = ddnames name    /* Unique list of ddnames     */
          end                          /* Wordpos(name,valid_ddnames)*/
       else
          if Wordpos(name,memlist) = 0 then
             memlist = memlist name    /* Unique list of members     */
 
   end                                 /* until                      */
 
   if ddnames = "" then ddnames = "SYSEXEC SYSPROC"
 
   call ZL_LOGMSG("Using DDNames:" ddnames )
   call ZL_LOGMSG("Seeking members:" memlist )
 
   save_ddnames = ddnames              /* may need it later          */
 
return                                 /*@ BB_SPLIT_DDNAMES_FROM_MEMBERS */
/*
   There is a wildcard.  Build the mems array which is indexed by ddname
   and dsn.  This will contain a list of the members for that dsn.
.  ----------------------------------------------------------------- */
BC_WILDCARDS:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   call BCA_FIND_MATCHES
 
return                                 /*@ BC_WILDCARDS              */
/*
   Wildcard characters have been found in member string.  Process each
   ddname, dataset and member list for matches.
.  ----------------------------------------------------------------- */
BCA_FIND_MATCHES:                      /*@                           */
   if branch then call BRANCH
   address TSO
 
   call ZL_LOGMSG("Resolving wildcards" )
   do dd = 1 to Words(ddnames)         /* Process ddnames            */
      ddname = Word(ddnames,dd)
 
      do mem = 1 to Words(memlist)     /* Process member list        */
         tempname = Word(memlist,mem)  /* 1 if present, 0 if not     */
         wildcard = Pos("*",tempname) > 0
 
         if wildcard then do           /* is a wildcard              */
            lomask  = Translate(tempname,'00'X,"*")
            himask  = Translate(tempname,'ff'X,"*")
            lenmask = Length(tempname)
            end                        /* wildcard                   */
 
         do ii = 1 to Words(dsns.ddname)
            dataset  = Word(dsns.ddname,ii)
            templist = mems.dataset
            call BCAA_SEARCH           /*                           -*/
         end                           /* ii (Words(dsns.ddname)     */
 
      end                              /* mem = 1 to w(memlist)      */
   end                                 /* dd = 1 to w(ddnames)       */
 
return                                 /*@ BCA_FIND_MATCHES          */
/*
   Search through templist (member list of dsn) and look for match.
   If found then load the table.
.  ----------------------------------------------------------------- */
BCAA_SEARCH:                           /*@                           */
   if branch then call BRANCH
   address TSO
 
   if wildcard then
      do until templist = ""           /* Is a wildcard, check each  */
                                       /* member                     */
         parse var templist memname templist
 
         ckmem = Left(memname,lenmask)
 
         if BitAND(himask,ckmem) = BitOR(lomask,ckmem) then
            call Z_LOAD_STATS          /*                           -*/
 
      end                              /* until                      */
   else
      if Wordpos(tempname,templist) > 0 then do /* not a wildcard    */
         memname = tempname            /* if the member is in list   */
         call Z_LOAD_STATS             /* then load to table        -*/
         end                           /* Wordpos(tempname,...)      */
 
return                                 /*@ BCAA_SEARCH               */
/*
   There are no wildcards.  Process list of ddnames and members.
   Check if member exists in each dataset allocated to the ddname.
   If found then get the stats and load table.
.  ----------------------------------------------------------------- */
BD_MEMBER_SEARCH:                      /*@                           */
   if branch then call BRANCH
   address TSO
 
   do while ddnames <> ""
      parse var ddnames ddname ddnames
 
      do ii = 1 to Words(memlist)
         memname = Word(memlist,ii)
         call BZ_LOAD_HITS             /*                           -*/
      end                              /* ii = 1                     */
 
   end                                 /* until                      */
 
return                                 /*@ BD_MEMBER_SEARCH          */
/*
   Get package data from SMPKG consisting of DDName and members related
   to that DDName.
.  ----------------------------------------------------------------- */
BE_NICKNAMES:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   "SMPKG" nicknames                   /*                            -*/
 
   call ZL_LOGMSG("SMPKG" nicknames)
 
   do queued()
      pull ddname mems
      call ZL_LOGMSG("SMPKG:" ddname mems)
      if Wordpos(ddname,ddnames) = 0 then do
         ddnames = ddnames ddname
         dsns.ddname = dsns.ddname SHOWPARM(ddname) /*              -*/
         call X_TRIM_DSNLIST           /*                           -*/
         call BX_GET_MEMS              /*                           -*/
         end
      do while mems <> ""
         parse var mems memname mems
         call BZ_LOAD_HITS             /*                           -*/
      end                              /* while mems                 */
   end                                 /* queued()                   */
   "DELSTACK"
 
return                                 /*@ BE_NICKNAMES              */
/*
   Get the memberlist(s) for this DDName and store as <mems.dsn>
.  ----------------------------------------------------------------- */
BX_GET_MEMS:                           /*@                           */
   bx_tv = Trace()                     /* what setting at entry ?    */
   if branch then call BRANCH
   address TSO
 
   wrkddn = ddname":"
   do ii = 1 to Words(dsns.ddname)
      dsn = Word(dsns.ddname,ii)
 
      if mems.dsn = "" then do
         if Sysdsn("'"dsn"'") = "OK" then do
            "NEWSTACK"
            "MEMBERS '"dsn"' ((STACK LINE ALIAS"
            pull mems.dsn
            "DELSTACK"
            end
         else iterate
 
         if mems.dsn = "<EMPTY>" then nop; else,
            do
            if sw.0diagnose then say,
            call ZL_LOGMSG(Left(wrkddn,11) dsn Words(mems.dsn) ,
                           "members" )                      
            call ZL_LOGMSG(mems.dsn)        
            wrkddn = ""
            end
         end                           /*  mems.dsn = ""             */
   end                                 /*  ii                        */
 
return                                 /*@ BX_GET_MEMS               */
/*
   Given a DDName and a membername, examine all datasets within that
   DDName for the member.  NOTE that this search is specific to a
   DDName.  For any found, load to the table.
.  ----------------------------------------------------------------- */
BZ_LOAD_HITS:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   do bz = 1 to Words(dsns.ddname)     /* Process each dataset       */
      dataset = Word(dsns.ddname,bz)
      if Wordpos(memname,mems.dataset) > 0 then
         call Z_LOAD_STATS             /* found a hit then load tbl -*/
   end                                 /* bz                         */
 
return                                 /*@ BZ_LOAD_HITS              */
/*
   Beginning of the maze.  Display the table, if any rows are
   selected then call PROCESS....
.  ----------------------------------------------------------------- */
C_DISPLAY:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBTOP" showtbl
 
   parse value "" with to_list from_list repop_member zerrlm
 
   do forever
      "TBDISPL" showtbl "PANEL("nqa_panel")"
      if rc > 4 then leave
      if zcmd <> "" then do            /*                            */
         call CZ_ZCMD                  /*                           -*/
         iterate
         end                           /* zcmd                       */
 
      if ztdsels > 0 then
         call CA_PROCESS_SELECTIONS    /*                           -*/
 
      if to_list = "" | from_list = "" then nop; else,
         call CB_REPOPULATE            /* do REPOPs last            -*/
 
      parse value "" with to_list from_list repop_member
 
   end                                 /* forever                    */
 
return                                 /*@ C_DISPLAY                 */
/*
   Process each row selected.  We know that at least 1 row has been
   selected.
.  ----------------------------------------------------------------- */
CA_PROCESS_SELECTIONS:                 /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   do ztdsels
      "CONTROL DISPLAY SAVE"
 
      parse value "0               0"                          with,
                  sw.error_found  sw.STOP  zerrsm  zerrlm  .
 
      select
         when action = "A" then        /* Acquire                    */
            call CAA_ACQUIRE           /*                           -*/
 
         when action = "B" then        /* Browse/View                */
            viewopt "DATASET('"dataset"("memname")'"
 
         when action = "C" then        /* Copy                       */
            call CAC_COPY              /*                           -*/
 
         when action = "D" then        /* Delete                     */
            call CAD_DELETE            /*                           -*/
 
         when action = "E" then do     /* Edit - reload stats        */
            "EDIT  DATASET('"dataset"("memname")')"
             if rc = 0 then
                call Z_LOAD_STATS      /* if changed then reload    -*/
             end                       /* action = "E"               */
 
         when action = "F" then do     /* "FROM" dataset-name        */
            from_list = from_list dataset
            repop_member = memname
            popvv      = vv
            popmm      = mm
            popcreated = created
            popchanged = changed
            poptime    = time
            popsize    = size
            popinit    = init
            popmod     = mod
            popid      = id
            end
 
         when action = "I" then,       /* Incompatible DCB copy      */
            call CAI_COPYD             /*                           -*/
 
         when action = "L" then        /* Browse dataset             */
            viewopt "DATASET('"dataset"')"
 
         when action = "M" then        /* Edit dataset               */
            "EDIT   DATASET('"dataset"')"
 
         when action = "P" then        /* Print                      */
            call CAP_PRINT             /*                           -*/
 
         when action = "R" then        /* Roll                       */
            call CAR_ROLL              /*                           -*/
 
         when action = "T" then,       /* "TO" dataset-name          */
            if \endv.dataset then,     /*  non-ENDV DS               */
               to_list = to_list dataset
 
         when action = "U" then
            address TSO "EXEC 'DTAFXC.EXECONLY.EXEC(UPOE@#ST)' '"showtbl,
               memname dataset vv mm created changed time size,
               init mod id ddname "((TRACE" tv "'"
 
         when action = "V" then        /* View/Browse                */
            viewopt "DATASET('"dataset"("memname")'"
 
         otherwise nop
 
      end                              /* select                     */
 
      "CONTROL DISPLAY RESTORE"
 
      if ztdsels > 1 then
         "TBDISPL" showtbl
 
      if sw.error_found then
         "SETMSG MSG(ISRZ002)"
 
   end                                 /* ztdsels                    */
 
   action = ""
 
return                                 /*@ CA_PROCESS_SELECTIONS     */
/*
   Determine if dataset is an Endevor managed dataset.  If so, then
   acquire must be done via Endevor.  Determine the approriate routine
   to call.
.  ----------------------------------------------------------------- */
CAA_ACQUIRE:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   parse var dsns.ddname . (pref) qual .
 
   if qual = "" then todsn = Word(dsns.ddname,1)
   else              todsn = pref||qual
 
   tomem   = memname
   ndvactn = "ACQUIRE"
 
   call CAAB_ACQUIRE                   /*                           -*/
 
   if sw.error_found then return
   if sw.STOP then return
 
   if updttask = "Y" then              /* Update task system         */
      call SHOWTASK("FROMDSN" dataset "FROMMEM" memname,                                             
                      "TODSN" todsn     "TOMEM" tomem "ACTION" ndvactn)
 
   parse value todsn       tomem     ddname.todsn  ddname  with,
               dataset     memname   ddname      .
   "TBMOD" showtbl                     /* Add to bottom of table     */
 
return                                 /*@ CAA_ACQUIRE               */
/*
   Acquire for non-Endevor managed datasets.  This is done via
   IEBCOPY.
.  ----------------------------------------------------------------- */
CAAB_ACQUIRE:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   zwinttl = "Acquire" memname
 
   call CZ_DISPLAY_WINDOW "SMACQUR"    /*                           -*/                         
                                    if sw.STOP then return
   call CZ_CONFIRM todsn tomem         /* Confirm overlay of code   -*/                         
                                    if sw.STOP then return
   call CZ_IEBCOPY dataset memname todsn tomem   /* do copy         -*/                                
                                    if sw.error_found then return
 
return                                 /*@ CAAB_ACQUIRE              */
/*
   Copy a member to up to three different dataset-members using
   IEBCOPY.
.  ----------------------------------------------------------------- */
CAC_COPY:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
                                       /*  Can copy mutilple dsns    */
   "VGET (OUTDSN1 OUTDSN2 OUTDSN3 UPDTTASK) PROFILE"
 
   do ii = 1 to 4                      /* Set equal to memname       */
      rc = Value('newmem'||ii,memname)
   end
 
   savedsn = CZ_ARCHIVE_DSNAME(ddname) /* Build save ds name        -*/
 
   zwinttl = "COPY" memname
 
   call CZ_DISPLAY_WINDOW "SMCOPY"     /*                           -*/                         
                                    if sw.STOP then return
 
   "NEWSTACK"
 
   queue outdsn1 newmem1               /* load with datasets to      */
   queue outdsn2 newmem2               /* copy.  They may or may not */
   queue outdsn3 newmem3               /* be blank                   */
 
   if backup = "Y" then
      queue savedsn newmem4
 
   do queued()
      pull outdsn newmem .
      if newmem = "" then iterate
                                       /*  Check if overlay          */
      call CZ_CONFIRM outdsn newmem    /* Confirm overlay of code   -*/
      if sw.STOP then iterate
 
      call CZ_IEBCOPY dataset memname outdsn newmem  /*             -*/
 
      if sw.error_found then
         "SETMSG MSG(ISRZ002)"
      else do
         if updttask = "Y" then        /* Update task system         */
            call SHOWTASK("FROMDSN" dataset "FROMMEM" memname,                                            
                            "TODSN" outdsn    "TOMEM" newmem "ACTION COPY")
         parse value outdsn   newmem   ddname.outdsn  ddname  with,
                     dataset  memname  ddname  .
         "TBMOD" showtbl               /* update table               */
         end
   end                                 /* queued()                   */
 
   "DELSTACK"
 
return                                 /*@ CAC_COPY                  */
/*
   Delete a member.  Endevor must be used if dsn is a Endevor managed
   dataset.
.  ----------------------------------------------------------------- */
CAD_DELETE:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   call Z_PDS_DELETE "'"dataset"'" memname   
   if sw.error_found then nop   
   else   
      "TBDELETE" showtbl            /* delete row from tbl        */   
 
return                                 /*@ CAD_DELETE                */
/*
   Use PDSCOPYD to move text between PDSs with incompatible DCBs.
.  ----------------------------------------------------------------- */
CAI_COPYD:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
                                       /*  Can copy mutilple dsns    */
   "VGET (OUTDSN1 OUTDSN2 OUTDSN3 UPDTTASK) PROFILE"
 
   do ii = 1 to 4                      /* Set equal to memname       */
      rc = Value('newmem'||ii,memname)
   end
 
   savedsn = CZ_ARCHIVE_DSNAME(ddname) /* Build save ds name        -*/
 
   zwinttl = "PDSCOPYD" memname "(incompatible DCB)"
 
   call CZ_DISPLAY_WINDOW "SMCOPY"     /*                           -*/                         
                                    if sw.STOP then return
 
   "NEWSTACK"
 
   queue outdsn1 newmem1               /* load with datasets to      */
   queue outdsn2 newmem2               /* copy.  They may or may not */
   queue outdsn3 newmem3               /* be blank                   */
 
   if backup = "Y" then
      queue savedsn newmem4
 
   do queued()
      pull outdsn newmem .
      if newmem = "" then iterate
                                       /*  Check if overlay          */
      call CZ_CONFIRM outdsn newmem    /* Confirm overlay of code   -*/
      if sw.STOP then iterate
 
      call CZ_PDSCOPYD dataset memname outdsn newmem /*             -*/
 
      if sw.error_found then
         "SETMSG MSG(ISRZ002)"
      else do
         if updttask = "Y" then        /* Update task system         */
            call SHOWTASK("FROMDSN" dataset "FROMMEM" memname,                                            
                            "TODSN" outdsn    "TOMEM" newmem "ACTION COPY")
         parse value outdsn   newmem   ddname.outdsn  ddname  with,
                     dataset  memname  ddname  .
         "TBMOD" showtbl               /* update table               */
         end
   end                                 /* queued()                   */
 
   "DELSTACK"
 
return                                 /*@ CAI_COPYD                 */
/*
   Print member.  Display panel allowing user to specify parms, such
   as copies and printer destination.                         
.  ----------------------------------------------------------------- */
CAP_PRINT:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "VGET (DEST) SHARED"
 
   zwinttl = "Print Confirmation"
 
   call CZ_DISPLAY_WINDOW "SMPRINTN"   /*                           -*/                         
                                    if sw.STOP then return
 
   "VPUT (DEST) SHARED"
 
   if noupdt then return
 
   copy = Max("1",copy)                /* Print member               */
 
   address TSO
 
   "PRINTDS DATASET('"dataset"("memname")'",                            
               "CLASS("prcls")  DEST("dest")",
               "COPIES("copy")" prtopts                                 
 
return                                 /*@ CAP_PRINT                 */
/*
   Roll member to next stage.  If dataset is Endevor-managed then
   must perform an ADD or a MOVE.  If not then use IEBCOPY.  Roll
   is a two step process (only perform one step at a time).
 
   Step 1:  user lib to TEST lib
   Step 2:  TEST lib to PROD lib
.  ----------------------------------------------------------------- */
CAR_ROLL:                              /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "VGET (UPDTTASK) PROFILE"
 
   parse value updttask "N" with,
               updttask  .
 
   savedsn = CZ_ARCHIVE_DSNAME(ddname) /*                           -*/
 
   parse var map.ddname testdsn cnfgdsn .
 
   if dataset = cnfgdsn then do
      zerrsm = "Already in Production" /*  active                    */
      zerrlm = dataset "and" cnfgdsn "match.  Can't roll PROD to PROD."
      sw.error_found = 1
      return
      end                              /* dataset = cnfgdsn          */
 
   if dataset = testdsn then           /* Roll from T to P           */
      push cnfgdsn  "MOVE    N       2"
   else                                /* Roll to Prod               */
      push testdsn  "ADD     N       1"
 
    pull   todsn    ndvactn  backup  stage  .
 
   tomem   = memname
 
   call CARB_ROLL                      /*                           -*/
 
   if sw.STOP        then return
   if sw.error_found then return
 
   call CARC_LOG_ROLL_ACTION           /*                           -*/
 
   if sw.0DBEHIND then                 /* Delete behind requested    */
      "TBDELETE" showtbl               /* delete from table          */
 
   if updttask = "Y" then              /* Update task system         */
      call SHOWTASK("FROMDSN" dataset "FROMMEM" memname,                                             
                      "TODSN" todsn     "TOMEM" tomem "ACTION" ndvactn)
 
   parse value todsn    tomem    ddname.todsn  ddname  with,
               dataset  memname  ddname  .
 
   "TBMOD" showtbl
 
return                                 /*@ CAR_ROLL                  */
/*
   Display window that shows copy stats
.  ----------------------------------------------------------------- */
CARAA_IEBCOPY_WINDOW:                  /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   var = sw.error_found
 
   zwinttl = "IEBCOPY" msg.var "RC("rcx")"
 
   popmsg1 = "From:" indsn
   popmsg2 = "Mem :" inmem
   popmsg3 = "TO  :" copy2dsn
   popmsg4 = "Mem :" copy2mem
 
   if sw.error_found then nop
   else
      "CONTROL DISPLAY LOCK"
 
   call CZ_DISPLAY_WINDOW "POP50BY4"   /*                           -*/
 
return                                 /*@ CARAA_IEBCOPY_WINDOW      */
/*
   Perform the non-Endevor roll using IEBCOPY.
.  ----------------------------------------------------------------- */
CARB_ROLL:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   type    = ddname                    /* Needed for call to SMULOG  */
   zwinttl = "Roll -" memname
 
   call CZ_DISPLAY_WINDOW "SMROLL"     /*                           -*/                         
                                    if sw.STOP then return
 
   sw.0SAVE    = backup = "Y" /* | ndvactn = "ADD" */
   sw.0DBEHIND = behind = "Y"
 
   call CZ_CONFIRM todsn tomem         /* Confirm overlay of code   -*/                         
                                    if sw.STOP then return
 
   if sw.0SAVE then do
      call CZ_IEBCOPY todsn   tomem   savedsn tomem /*              -*/
      call CARAA_IEBCOPY_WINDOW        /*                           -*/
      end                              /* sw.0SAVE                   */
 
   if sw.error_found then return
 
   call CZ_IEBCOPY dataset memname todsn tomem
 
   if sw.error_found then return
 
   if sw.0DBEHIND then
      call Z_PDS_DELETE "'"dataset"'" memname
      /* should probably also TBDELETE ? */
 
return                                 /*@ CARB_ROLL                 */
/*
   Track date and time of ROLL
.  ----------------------------------------------------------------- */
CARC_LOG_ROLL_ACTION:                  /*@                           */
   if branch then call BRANCH
   address TSO
 
   parmlist = "ACTION" Left(ndvactn,4) "ELEMENT" memname,
              "TYPE" type "VERSION" vv "LEVEL" mm "CREATE" created,
              "CHANGE" changed "SIZE" size "INIT" init "MOD" mod,
              "ID" id
 
    "NEWSTACK"
    "SMULOG" parmlist                  /*                            -*/
    "DELSTACK"
 
return                                 /*@ CARC_LOG_ROLL_ACTION      */
/*
   The user has entered one (and ONLY ONE) "F" action and one or more
   "T" actions on the panel.  The DSNs have been collected into
   <from_list> and <to_list>.  IEBCOPY <repop_member> from the
   one-and-only "FROM" DSN to each of the "TO" DSNs.
.  ----------------------------------------------------------------- */
CB_REPOPULATE:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if Words(from_list) <> 1 then,
      zerrlm = zerrlm "One and only one 'From' token may be specified. "
   if Words(to_list)  = 0 then,
      zerrlm = zerrlm "At least one 'To' token must be specified. "
   if zerrlm <> "" then do
      sw.error_found = 1
      return
      end
 
   parse value from_list with from_list .
 
   do while to_list <> ""
      parse var to_list  outdsn to_list
      call CZ_IEBCOPY from_list repop_member outdsn repop_member /* -*/
      if sw.error_found then           /* Copy failed                */
         "SETMSG MSG(ISRZ002)"
      else do
         call SHOWTASK("FROMDSN" from_list "FROMMEM" repop_member,                                                   
                         "TODSN" outdsn      "TOMEM" repop_member,
                         "ACTION REPOP")
         parse value outdsn   repop_member  ddname.outdsn  ddname  with,
                     dataset  memname       ddname   .
         vv           = popvv
         mm           = popmm
         created      = popcreated
         changed      = popchanged
         time         = poptime
         size         = popsize
         init         = popinit
         mod          = popmod
         id           = popid
         "TBMOD" SHOWTBL               /* Add to bottom of table     */
         end                           /* else (\sw.error_found)     */
 
    end                                /* while                      */
 
return                                 /*@ CB_REPOPULATE             */
/*
   Build the archive dataset name.  SMARCH will return by ddname the
   dataset to be used as the archive dataset.
.  ----------------------------------------------------------------- */
CZ_ARCHIVE_DSNAME:                     /*@                           */
   if branch then call BRANCH
   address TSO
   arg ddname .
 
   savedsn = SMARCH(ddname)            /*                           -*/
 
return(savedsn)                        /*@ CZ_ARCHIVE_DSNAME         */
/*
   If a member will be overlaid then display a window requesting
   confirmation of the overlay.  Turn switch on overlay was not
   verified.
.  ----------------------------------------------------------------- */
CZ_CONFIRM:                            /*@                           */
   if branch then call BRANCH
   address TSO
   arg olaydsn olaymem .
 
   if Sysdsn("'"olaydsn"("olaymem")'") <> "OK" then return
 
   zwinttl = "Overlay Confirmation"
   call CZ_DISPLAY_WINDOW "SMCONFRM"   /*                           -*/
   sw.STOP = confirm = "N"
 
return                                 /*@ CZ_CONFIRM                */
/*
.  ----------------------------------------------------------------- */
CZ_DISPLAY_WINDOW:                     /*@                           */
   if branch then call BRANCH
   address ISPEXEC
   arg pnl row column .
 
   parse value row 10 'ef'X column 10 with ,
               row .  'ef'X column .
 
   "ADDPOP ROW("row") COLUMN("column")"
   "DISPLAY PANEL("pnl")"
   rcx = rc
   "REMPOP ALL"
 
   sw.STOP = rcx > 4
 
return                                 /*@ CZ_DISPLAY_WINDOW         */
/*
   Copy a member using IEBCOPY.  At NMR IEBCOPY is not usable in the
   TSO foreground; use PDSCOPYD.
.  ----------------------------------------------------------------- */
CZ_IEBCOPY:                            /*@                           */
   if branch then call BRANCH
   address TSO
   arg indsn inmem copy2dsn copy2mem .
 
   call CZ_PDSCOPYD indsn inmem copy2dsn copy2mem .          /*      -*/
 
return                                 /*@ CZ_IEBCOPY                */
   parmlist = "FROM" indsn "TO" copy2dsn "MEMBER" inmem "AS" copy2mem
 
   rcx      = PDSCOPY(parmlist)        /*                           -*/
 
   sw.error_found =  rcx < 0 | rcx > 4
 
   if sw.error_found then do
      zerrsm = "Copy Failed"
      zerrlm = "IEBCOPY failed with RC="rcx,
               "Unable to copy" indsn"("inmem") to" copy2dsn"("copy2mem")."
      end
/*
   Use PDSCOPYD to copy to an incompatible DCB.
.  ----------------------------------------------------------------- */
CZ_PDSCOPYD:                           /*@                           */
   if branch then call BRANCH
   address TSO
   arg indsn inmem copy2dsn copy2mem .
 
   parmlist = "FROMDS '"indsn"' TODS '"copy2dsn"'",
              "FROMMBR" inmem "TOMBR" copy2mem
 
   rcx      = PDSCOPYD(parmlist)       /*                           -*/
 
   sw.error_found =  rcx < 0 | rcx > 4
 
   if sw.error_found then do
      zerrsm = "Copy Failed"
      zerrlm = "PDSCOPYD failed with RC="rcx,
               "Unable to copy" indsn"("inmem") to" copy2dsn"("copy2mem")."
      call ZL_LOGMSG(zerrlm)
      end
 
return                                 /*@ CZ_PDSCOPYD               */
/*
   ZCMD was populated.  Process the command text.
.  ----------------------------------------------------------------- */
CZ_ZCMD:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   parse var zcmd verb text .
   select
      when verb = "SORT" then do
         sortspec    = ""
         varn.       = "?"
         varn.MEMBER = "MEMNAME"
         varn.DDNAME = "DDNAME"
         varn.DSN    = "DATASET"
         do while text <> ""
            parse var text fldspec text
            parse var fldspec  fldn "," fldt "," fldd .
            parse value fldt "C"  with fldt .
            parse value fldd "A"  with fldd .
            sortspec = sortspec varn.fldn fldt fldd
         end
         sortspec = Space(sortspec,1)
         sortspec = Translate(sortspec,","," ")
         "TBSORT" showtbl "FIELDS("sortspec")"
         end                           /* SORT                       */
      otherwise nop
   end                                 /* select                     */
 
return                                 /*@ CZ_ZCMD                   */
/*
   Retrieve the ISPF stats and add to table.
.  ----------------------------------------------------------------- */
Z_LOAD_STATS:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if Right(memname,3) = "(*)" then do /* it's an alias              */
      parse var memname   memname "("
      al   = "(alias)"
      seq  = seq.dataset               /* concatenation sequence     */
      "TBMOD" showtbl "ORDER"
      al   = ""
      return                           /* there are no stats         */
      end                              /* alias                      */
 
   parse value "" with ,
               zlcdate  zlmdate  zlmtime  zlcnorc  zlinorc,
               zlc4date zlm4date zlmnorc  zluser  zlvers  zlmod  .
 
   "LMINIT  DATAID(BASEID) DATASET('"dataset"')"
   if rc > 0 then do
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"; return
      end
   "LMOPEN  DATAID("baseid")"
   if rc > 0 then do
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"
      end
   "LMMFIND DATAID("baseid") MEMBER("memname") STATS(YES)"
   if rc > 0 & \sw.0error_found then do
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.0error_found = "1"
      end
   "LMCLOSE DATAID("baseid")"
   "LMFREE  DATAID("baseid")"
   if sw.0error_found then return
 
   parse value zlc4date zlm4date zlmtime  zlcnorc  zlinorc  zlmnorc,                             
                 zluser  zlvers  zlmod  with,
               created  changed  time     size     init     mod ,                         
                 id      vv      mm  .
 
   seq     = seq.dataset               /* concatenation sequence     */
   "TBMOD" showtbl "ORDER"
                                       /*  Clear out for next time   */
   parse value "" with,
               created  changed  time  size  init  mod  id  vv  mm  .
 
return                                 /*@ Z_LOAD_STATS              */
/*
   At Exxon, PDS has been disabled and cannot be used to delete
   members as SHOWMEM wants.  Since SHOWMEM must run as an ISPF
   dialog, the LM functions can handle the task almost as well.
.  ----------------------------------------------------------------- */
Z_PDS_DELETE:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   arg dsn mem .
 
   "LMINIT  DATAID(delid) DATASET("dsn")  ENQ(EXCLU)"
   if rc > 0 then do
      zerrsm = "LMINIT failed"
      if Symbol(zerrlm) = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.error_found = "1"; return
      end
   "LMOPEN  DATAID("delid")   OPTION(OUTPUT)"
   if rc > 0 then do
      zerrsm = "LMOPEN failed"
      if Symbol(zerrlm) = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.error_found = "1"
      end
   else, 
   "LMMDEL  DATAID("delid")   MEMBER("mem")"
   if rc > 0 then do
      zerrsm = "LMMDEL failed"
      if Symbol(zerrlm) = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.error_found = "1"
      end
   "LMCLOSE DATAID("delid")"
   if rc > 0 then do
      zerrsm = "LMCLOSE failed"
      if Symbol(zerrlm) = "LIT" then,
         zerrlm = "No additional diagnostics produced."
      zerrlm = exec_name "("BRANCH("ID")")",
               zerrlm
      address ISPEXEC "SETMSG  MSG(ISRZ002)"
      sw.error_found = "1"
      end
   "LMFREE  DATAID("delid")"
 
return                                 /*@ Z_PDS_DELETE              */
/*     This old code may work at NMR                                  */
   address TSO
   arg dsn mem .
 
   xx = Outtrap("PDS.")
       "PDS" dsn "DELETE" mem
   xx = Outtrap("OFF")
 
   sw.error_found = rc > 4
 
   if sw.error_found then do
      zerrsm = "Delete Failed"
      zerrsm = "PDS Delete of" dsn"("mem") failed with RC="rc
      end                              /* sw.error_found             */
/*
   Called after the dsns.ddname is modified by a call to SHOWPARM.
   SHOWPARM may add redundant dataset names to the list; remove
   them.  This is done by clipping a dsn off the front of the list
   and searching the remainder for a match.
.  ----------------------------------------------------------------- */
X_TRIM_DSNLIST: Procedure expose,      /*@                           */
   (tk_globalvars) (expose_list) dsns. ddname
   if branch then call BRANCH
   address TSO
 
   parse value "0"     with xpt  temp  .
   do while dsns.ddname <> ""
      parse var dsns.ddname  dsn  dsns.ddname
      temp  = temp dsn
      ddname.dsn = ddname              /* which DD owns this DS ?    */
      xpt = xpt + 1                    /* bump                       */
      seq.dsn   = xpt                  /* concatenation sequence     */
      do until dwp = 0
         dwp = Wordpos(dsn,dsns.ddname)
         if dwp > 0 then dsns.ddname = Delword(dsns.ddname,dwp,1)
      end
   end
   dsns.ddname = Space(temp,3)
 
return                                 /*@ X_TRIM_DSNLIST            */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   parse value "SMHELP" with zerrhm .
 
   ndmsites = SMNDM()                  /*                            -*/
   ndmsites = Delword(ndmsites,Wordpos(node,ndmsites),1)
 
   panel.0   = "SHOWMEM"
   panel.1   = "SHOWMEM#"
 
   "NEWSTACK"
   "EXEC 'DTAFXC.EXECONLY.EXEC(ICEUSER)'" ; pull power_usr     /*    -*/
   "DELSTACK"
 
   is_ok = Wordpos(UserID(),power_usr) > 0
   nqa_panel = panel.is_ok
 
   sw.0Diagnose  = SWITCH("DIAGNOSE") | monitor
   monitor       = sw.0Diagnose       | monitor
 
return                                 /*@ LOCAL_PREINIT             */
/* Subroutines below LOCAL_PREINIT are not seen by SHOWFLOW           */
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
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg;
   say "HELP not available for SHOWMEM"; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      provides a selectable list of the components      "
say "                specified or implied.                             "
say "                                                                  "
say "  Syntax:   "ex_nam"  <cmp-list>                                  "
say "                      <.PKGS .. pkg-list ..>                      "
say "                 ((   <DIAGNOSE>                                  "
say "                                                                  "
say "            <cmp-list>    is a blank delimited list of the        "
say "                      components to be shown.  The list may       "
say "                      include both membernames and filenames in   "
say "                      any order.  Filenames will be isolated and  "
say "                      all specified members will be located in    "
say "                      every dataset of each identified file.      "
say "                                                                  "
say "            <pkg-list>   is a blank-delimited list of packages (as"
say "                      found in SMPKG.                             "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
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
/* REXXSKEL back-end removed for space */