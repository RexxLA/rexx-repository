/* REXX    VCX        Re-write of Jim Connelley's VC to take advantage
                      of LISTCSUM
 
           Written by Frank Clarke 20020507
 
     Impact Analysis
.    SYSPROC   LISTCSUM
.    SYSPROC   TRAPOUT
 
     Modification History
     20020722 fxc NUMBERED on CLUSTER only; ignore NOWRITECHK, NOIMBED,
                  NOREPLICAT, NOREUSE;
     20020819 fxc rearranged parameters; drop obsolete tags;
     20030331 fxc no SUMMARY for a GDGBASE; a single generation of a
                  GDG will show as NONVSAM with a 'GDG' tag in
                  NONVSAMASSOCIATIONS;
     20041028 fxc enable AIX;
     20041209 fxc enable VIEW of partitioned dataset;
     20041209 fxc not VIEW, EDIT; include DELETE and SET MAXCC;
                  discard many tokens from AIXDATAATTRIBUTES;
     20050207 fxc make sure output requires manual intervention;
     20050304 fxc correct processing of GDGs (involved LISTCSUM);
     20070814 fxc added missing '-' to two DEFINEs;
     20070820 fxc don't send DATACLASS, MANAGEMENTCLASS, STORAGECLASS,
                  or CONTROLINTERVALSIZE;
     20071009 fxc implement SKINNY to yield terse definitions;
     20080103 fxc BLDINDEX for AIXs;
     20080225 fxc VERIFY;
     20080312 fxc allow NONUNIQKEY for AIX;
     20080410 fxc LISTCAT shows 'NONUNIQKEY' for AIX, but
                  DEFINE wants  'NONUNIQUEKEY';
     20080722 fxc relabel BGG_DEFNVSAM to BGN_;
     20160930 fxc an empty GDG BASE will have no NONVSAMASSOCIATIONS;
                  parsing GDG will yield null
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20020513      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
call B_PROCESS_CAT                     /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
if \sw.nested then do
   "NEWSTACK" ; pull ; "DELSTACK"
   end
exit                                   /*@ VCX                       */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value "0 0 0 0 0 0 0 0 0 0" with ,
         ct.    .
   parse value "" with ,
         taglist   tagdata.      ,
         vwsuff  ,
         .
   call AK_KEYWDS                      /*                           -*/
   parse var info dsname info
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AK_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.0Skinny  = SWITCH("SKINNY")
   outdsn = KEYWD("OUTPUT")
   if Pos( "(" , outdsn ) > 0 then,
      sw.0outpds = 1                   /* output is partitioned      */
 
return                                 /*@ AK_KEYWDS                 */
/*
   Obtain definition data via LISTC; parse it into its components;
   recreate the DEFINE which produced this picture.
.  ----------------------------------------------------------------- */
B_PROCESS_CAT:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   "NEWSTACK"
   call BA_RUN_LISTCSUM                /*                           -*/
   call BD_PULL_DATAPOINTS             /*                           -*/
 
   "DELSTACK" ; "NEWSTACK"
                                    if \sw.0error_found then,
   call BG_WRITE_DEFINE                /*                           -*/
   "DELSTACK"
 
return                                 /*@ B_PROCESS_CAT             */
/*
.  ----------------------------------------------------------------- */
BA_RUN_LISTCSUM:                       /*@                           */
   if branch then call BRANCH
   address TSO
 
   "LISTCSUM" dsname  "STACK"          /* load keys to stack        -*/
 
return                                 /*@ BA_RUN_LISTCSUM           */
/*
.  ----------------------------------------------------------------- */
BD_PULL_DATAPOINTS:                    /*@                           */
   if branch then call BRANCH
   address TSO
 
   do queued()                         /* each queued line           */
      parse pull keytag ":" tagdata
      taglist = taglist keytag         /* add to list                */
      tagdata.keytag = tagdata         /* load tagdata to keytag     */
   end                                 /* queued                     */
 
   info      = tagdata.SUMMARY
   parse value   KEYWD("AIX")     0 with ct.0aix   .
   parse value   KEYWD("ALIAS")   0 with ct.0alias .
   parse value   KEYWD("CLUSTER") 0 with ct.0cluster .
   parse value   KEYWD("DATA")    0 with ct.0data  .
   parse value   KEYWD("PATH")    0 with ct.0path  .
   parse value   KEYWD("GDG")     0 with ct.0gdg   .
   parse value   KEYWD("INDEX")   0 with ct.0index .
   parse value   KEYWD("NONVSAM") 0 with ct.0nonvsam .
   parse value   KEYWD("TOTAL")   0 with ct.0total .
   ct.0subtot  = ct.0alias + ct.0cluster + ct.0data + ct.0gdg + ,
                 ct.0aix + ct.0path + ,
                 ct.0index + ct.0nonvsam
   if ct.0total > ct.0subtot then do   /* stuff we can't handle      */
      say exec_name "is not yet capable of handling something in",
            "this list:"
      say info                         /* what's left over?          */
      sw.0error_found = 1
      return                           /* we're done                 */
      end
 
   if ct.0alias   > 0 then call BDA_ALIAS /*                         -*/
   if ct.0cluster > 0 then call BDC_CLU   /*                         -*/
   if ct.0gdg     > 0 then call BDG_GDG   /*                         -*/
   if ct.0nonvsam > 0 then call BDN_NV    /*                         -*/
   if ct.0aix     > 0 then call BDX_AIX   /*                         -*/
 
return                                 /*@ BD_PULL_DATAPOINTS        */
/*
   An ALIAS is also referenced in NONVSAMASSOCIATIONS
.  ----------------------------------------------------------------- */
BDA_ALIAS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   info     = tagdata.aliasassociations
   base     = KEYWD("NONVSAM")
   alias    = dsname
 
return                                 /*@ BDA_ALIAS                 */
/*
   CLUSTER.
.  ----------------------------------------------------------------- */
BDC_CLU:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   clusterdsn = dsname
 
   info     = tagdata.clusterassociations
   datadsn  = KEYWD("DATA")
   indexdsn = KEYWD("INDEX")
 
   info     = tagdata.clustersmsdata
   stgcls   = KEYWD("STORAGECLASS")
   mgmtcls  = KEYWD("MANAGEMENTCLASS")
   datacls  = KEYWD("DATACLASS")
 
   if ct.0data > 0 then,
      call BDCD_DATA                   /*                           -*/
 
   if ct.0index > 0 then,
      call BDCI_INDEX                  /*                           -*/
 
return                                 /*@ BDC_CLU                   */
/*
   CLUSTER DATA
.  ----------------------------------------------------------------- */
BDCD_DATA:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   info     = tagdata.dataattributes
   keylen   = KEYWD("KEYLEN")
   avgrecl  = KEYWD("AVGLRECL")
   bufspc   = KEYWD("BUFSPACE")
   cisize   = KEYWD("CISIZE")
   rkp      = KEYWD("RKP")
   maxrecl  = KEYWD("MAXLRECL")
   excpext  = KEYWD("EXCPEXIT")
   recsper  = KEYWD("RECORDS/CI")
   maxrecs  = KEYWD("MAXRECS")
   cicapct  = KEYWD("CI/CA")
   shropts  = CLKWD("SHROPTNS")        /* CLIST-form                 */
   dataopts = Space(info,1)            /* whatever is left           */
 
   info     = tagdata.dataallocation
   spctyp   = KEYWD("SPACE TYPE")
   spcpri   = KEYWD("SPACE PRI")
   spcsec   = KEYWD("SPACE SEC")
 
   info     = tagdata.datastatistics
   dfspcci  = KEYWD("FREESPACE %CI")
   dfspcca  = KEYWD("FREESPACE %CA")
 
   info     = tagdata.dataassociations
   clusterdsn = KEYWD("CLUSTER")
 
return                                 /*@ BDCD_DATA                 */
/*
   CLUSTER INDEX
.  ----------------------------------------------------------------- */
BDCI_INDEX:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   info     = tagdata.indexattributes
   idxklen  = KEYWD("KEYLEN")
   idxavgl  = KEYWD("AVGLRECL")
   idxbuf   = KEYWD("BUFSPACE")
   idxci    = KEYWD("CISIZE")
   idxrkp   = KEYWD("RKP")
   idxmaxl  = KEYWD("MAXLRECL")
   idxecpx  = KEYWD("EXCPEXIT")
   idxcica  = KEYWD("CI/CA")
   idxshro  = CLKWD("SHROPTNS")        /* CLIST-form                 */
   idxopts  = Space(info,1)            /* whatever is left           */
 
   info     = tagdata.indexallocation
   idxspc   = KEYWD("SPACE TYPE")
   idxpri   = KEYWD("SPACE PRI")
   idxsec   = KEYWD("SPACE SEC")
 
   info     = tagdata.indexstatistics
   xfspcci  = KEYWD("FREESPACE %CI")
   xfspcca  = KEYWD("FREESPACE %CA")
 
   info     = tagdata.indexassociations
   clusterdsn = KEYWD("CLUSTER")
 
return                                 /*@ BDCI_INDEX                */
/*
.  Missing: OWNER, TO, FROM
   If the GDG BASE is empty, there will be no NONVSAMASSOCIATIONS
   from which to acquire the Base name.
.  ----------------------------------------------------------------- */
BDG_GDG:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   info     = tagdata.gdgbaseattributes
   gdglim   = KEYWD("LIMIT")
   info     = tagdata.nonvsamassociations
   parse value KEYWD("GDG") dsname with dsname .
   gdgopts  = Space(info,1)            /* whatever is left           */
   ct.0nonvsam = 0                     /* don't process NONVSAM      */
 
return                                 /*@ BDG_GDG                   */
/*
   NON-VSAM
   still undo: if a non-vsam file has an alias, DEFINE ALIAS
.  ----------------------------------------------------------------- */
BDN_NV:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   info     = tagdata.nonvsamsmsdata
   stgcls   = KEYWD("STORAGECLASS")
   mgmtcls  = KEYWD("MANAGEMENTCLASS")
   datacls  = KEYWD("DATACLASS")
 
   info     = tagdata.nonvsamassociations
   nvalias  = KEYWD("ALIAS")
   nvgdg    = KEYWD("GDG")
 
return                                 /*@ BDN_NV                    */
/*
   AIX (alternate index)
.  ----------------------------------------------------------------- */
BDX_AIX:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   info        = tagdata.aixassociations
   baseclname  = KEYWD("CLUSTER")      /* base clustername           */
   datadsn     = KEYWD("DATA")         /* data name                  */
   indexdsn    = KEYWD("INDEX")        /* index name                 */
   pathdsn     = KEYWD("PATH")         /* path name                  */
 
   aixattrib   = Space(tagdata.aixattributes,1)
 
   info        = tagdata.dataassociations
   aixname     = KEYWD("AIX")          /* base AIX name              */
 
   info        = tagdata.dataattributes
   keylen      = KEYWD("KEYLEN")
   avgrecl     = KEYWD("AVGLRECL")
   bufspc      = KEYWD("BUFSPACE")
   cisize      = KEYWD("CISIZE")
   rkp         = KEYWD("RKP")
   maxrecl     = KEYWD("MAXLRECL")
   $z          = KEYWD("EXCPEXIT")
   $z          = KEYWD("CI/CA")
   axrkp       = KEYWD("AXRKP")
   shropts     = CLKWD("SHROPTNS")
   nunqkey     = SWITCH("NONUNIQKEY")
   unqkey      = SWITCH("UNIQKEY") + SWITCH("UNIQUEKEY")
   $z          = SWITCH("INDEXED")
   $z          = SWITCH("NOWRITECHK")
   $z          = SWITCH("WRITECHK")
   $z          = SWITCH("NOIMBED")
   $z          = SWITCH("IMBED")
   $z          = SWITCH("REPLICAT")
   $z          = SWITCH("NOREPLICAT")
   $z          = SWITCH("ORDERED")
   $z          = SWITCH("UNORDERED")
   $z          = SWITCH("NOREUSE")
   $z          = SWITCH("REUSE")
   $z          = SWITCH("SPANNED")
   dataopts    = Space(info,1)         /* all remaining              */
 
   info        = tagdata.datastatistics
   cipct       = KEYWD("FREESPACE %CI")
   capct       = KEYWD("FREESPACE %CA")
 
   info        = tagdata.dataallocation
   spctyp      = KEYWD("SPACE TYPE")
   spcpri      = KEYWD("SPACE PRI")
   spcsec      = KEYWD("SPACE SEC")
 
   info        = tagdata.indexallocation
   idxspc      = KEYWD("SPACE TYPE")
   idxpri      = KEYWD("SPACE PRI")
   idxsec      = KEYWD("SPACE SEC")
 
   info        = tagdata.indexattributes
   idxklen     = KEYWD("KEYLEN")
   idxavgl     = KEYWD("AVGLRECL")
   idxbuf      = KEYWD("BUFSPACE")
   idxci       = KEYWD("CISIZE")
   idxrkp      = KEYWD("RKP")
   idxmaxl     = KEYWD("MAXLRECL")
 
   pathopts    = tagdata.pathattributes
 
return                                 /*@ BDX_AIX                   */
/*
.  ----------------------------------------------------------------- */
BG_WRITE_DEFINE:                       /*@                           */
   if branch then call BRANCH
   address TSO
 
   if ct.0alias  > 0 then,
      call BGA_DEFALIAS                /*                           -*/
   if ct.0cluster > 0 then,
      call BGC_DEFCL                   /*                           -*/
   if ct.0gdg    > 0 then,
      call BGG_DEFGDG                  /*                           -*/
   if ct.0nonvsam > 0 then,
      call BGN_DEFNVSAM                /*                           -*/
   if ct.0aix     > 0 then,
      call BGX_DEFAIX                  /*                           -*/
 
   call BGY_OUTPUT_DEFINE              /*                            */
 
   if sw.0BrowseTMP then do            /* display text               */
      call BGZ_BROWSE_TMP              /*                           -*/
      "FREE  FI($TMP)"
      end                              /* BrowseTMP                  */
 
return                                 /*@ BG_WRITE_DEFINE           */
/*
.  ----------------------------------------------------------------- */
BGA_DEFALIAS:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   queue "   DEFINE  ALIAS -"
   queue "       (   NAME( -"alias" ) -"
   queue "         RELATE( -"base" ) )"
 
return                                 /*@ BGA_DEFALIAS              */
/*
.  ----------------------------------------------------------------- */
BGC_DEFCL:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   info = dataopts                     /* ready for parsing          */
   sw.numbered = SWITCH("NUMBERED")    /* RRDS ?                     */
   sw.indexed  = SWITCH("INDEXED")     /* KSDS ?                     */
   sw.nonindx  = SWITCH("NONINDEXED")  /* ESDS ?                     */
   sw.linear   = SWITCH("LINEAR")      /* Linear DS ?                */
 
   sw.reuse    = SWITCH("REUSE")
   sw.noreuse  = SWITCH("NOREUSE")
   if sw.reuse = sw.noreuse then,
      parse value "0 1"  with  sw.reuse  sw.noreuse .
 
   sw.unique   = SWITCH("UNIQUE")
   if sw.reuse then sw.unique = 0
 
   $z   = SWITCH("NOWRITECHK")         /* unused                     */
   $z   = SWITCH("NOIMBED")            /* unused                     */
   $z   = SWITCH("NOREPLICAT")         /* unused                     */
   dataopts = Space(info,1)            /* restore corrected          */
 
   queue "   DELETE" "-"clusterdsn "CLUSTER"
   queue " "
   queue "   SET MAXCC = 0"
   queue " "
   queue "   DEFINE  CLUSTER -"
   queue "       (   NAME( -"clusterdsn" ) -"
/* if stgcls   <> "(NULL)" then,
      queue "         STORAGECLASS(" stgcls ") -"
   if mgmtcls  <> "(NULL)" then,
      queue "         MANAGEMENTCLASS(" mgmtcls ") -"
   if datacls  <> "(NULL)" then,
      queue "         DATACLASS(" datacls ") -"     20070820 */
 
   attribs = ""
   if sw.numbered  then,
      attribs = attribs "NUMBERED"
   if sw.indexed   then,
      attribs = attribs "INDEXED"
   if sw.nonindx   then,
      attribs = attribs "NONINDEXED"
   if sw.linear    then,
      attribs = attribs "LINEAR"
   if attribs <> "" then ,
      queue "         "Space(attribs,1)" -"
 
   if ct.0data > 0 then do
   if sw.0Skinny = 0 then do
   queue "       ) -"
   queue "           DATA    -"
   queue "       (   NAME( -"datadsn ") -"
      end                              /* skinny - drop this         */
   queue "         "spctyp"(" spcpri "," spcsec ") -"
   queue "         RECORDSIZE(" avgrecl "," maxrecl ") -"
   queue "         FREESPACE(" dfspcci "," dfspcca ") -"
 
   if sw.reuse then dataopts = dataopts "REUSE"
               else dataopts = dataopts "NOREUSE"
   dataopts = Space(dataopts,1)
   do while dataopts <> ""
      pt = LastPos(" ",dataopts" ",40)
      slug      = Substr(dataopts,1,pt)
      dataopts  = Delstr(dataopts,1,pt)
      queue "         "slug" -"
   end                                 /* dataopts                   */
 
   queue "         BUFFERSPACE(" bufspc ") -"
/* queue "         CONTROLINTERVALSIZE(" cisize ") -" 20080820 */
   queue "         SHAREOPTIONS(" shropts ") -"
   if keylen > 0 then,
   queue "         KEYS(" keylen "," rkp ") -"
      end                              /* DATA                       */
 
   if ct.0index > 0 then do
   if sw.0Skinny = 0 then do
   queue "       ) -"
   queue "           INDEX   -"
   queue "       (   NAME( -"indexdsn ") -"
   queue "         "idxspc"(" idxpri "," idxsec ") -"
 
   info    = idxopts                   /* ready for parsing          */
   $z      = SWITCH("SPEED")           /* purge from string          */
   $z      = SWITCH("RECOVERY")
   $z      = SWITCH("ERASE")
   $z      = SWITCH("NOERASE")
   $z      = SWITCH("UNIQUE")
   $z      = SWITCH("WRITECHK")
   $z      = SWITCH("NOWRITECHK")
   $z      = SWITCH("NOREPLICAT")
   $z      = SWITCH("REPLICAT")
   $z      = SWITCH("REPLICATE")
   idxopts = Space(info,1)             /* ready to load              */
 
   idxopts = Space(idxopts,1)
   do while idxopts <> ""
      pt = LastPos(" ",idxopts" ",40)
      slug      = Substr(idxopts,1,pt)
      idxopts   = Delstr(idxopts,1,pt)
      queue "         "slug" -"
   end                                 /* idxopts                    */
 
/* queue "         CONTROLINTERVALSIZE(" idxci ") -" 20070820 */
   queue "         SHAREOPTIONS(" idxshro ") -"
      end                              /* skinny - drop this         */
      end                              /* INDEX                      */
 
   queue "       )"
   queue " "
   queue "   VERIFY DATASET( -"clusterdsn ")"
 
return                                 /*@ BGC_DEFCL                 */
/*
.  ----------------------------------------------------------------- */
BGG_DEFGDG:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   queue "   DEFINE  GENERATIONDATAGROUP   -"
   queue "       (   NAME( -"dsname ") -"
   queue "          LIMIT(" gdglim ") -"
   queue "          " gdgopts ")"
 
return                                 /*@ BGG_DEFGDG                */
/*
.  ----------------------------------------------------------------- */
BGN_DEFNVSAM:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   queue "   DEFINE  NONVSAM   -"
   queue "       (   NAME( -"dsname ") )"
 
return                                 /*@ BGN_DEFNVSAM              */
/*
.  ----------------------------------------------------------------- */
BGX_DEFAIX:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   queue "   DELETE" "-"aixname "  AIX"
   queue " "
   queue "   SET MAXCC = 0"
   queue " "
   queue "   DEFINE  AIX     -"
   queue "       (   NAME( -"aixname ") -"
   queue "         RELATE( -"baseclname ") -"
   queue "       "aixattrib " -"
   if sw.0Skinny = 0 then do
      queue "       ) -"
      queue "           DATA    -"
      queue "       (   NAME( -"datadsn ") -"
      end                              /* skinny not                 */
   queue "         "spctyp"(" spcpri     spcsec ") -"
   queue "         RECORDSIZE(" avgrecl     maxrecl ") -"
   if sw.0Skinny = 0 then do
      queue "         FREESPACE(" cipct  capct ") -"
      queue "         BUFFERSPACE(" bufspc ") -"
      queue "         SHAREOPTIONS(" shropts ") -"
      end                              /* skinny not                 */
   queue "         KEYS(" keylen "," rkp ") -"
   if sw.0Skinny = 0 then do
   if nunqkey then ,
      queue "         NONUNIQUEKEY -"
   else,
      queue "         UNIQUEKEY -"
   /* Add dataattributes.   This could be quite long                 */
   do while dataopts <> ""
      pt        = LastPos(" ",dataopts" ",40)   /* ID 40 bytes       */
      slug      = Substr(dataopts,1,pt)  /* load to slug             */
      dataopts  = Delstr(dataopts,1,pt)  /* excise from dataopts     */
      queue "         "slug" -"
   end                                 /* dataopts                   */
   queue "       ) -"
   queue "           INDEX   -"
   queue "       (   NAME( -"indexdsn ") -"
   queue "         "idxspc"(" idxpri "," idxsec ") -"
      end                              /* skinny not                 */
   queue "       )"
   queue "  "
   queue "   DEFINE  PATH    -"
   queue "       (   NAME( -"pathdsn ") -"
   queue "           PATHENTRY( -"aixname ") -"
   queue "       "pathopts " -"
   queue "       )"
   queue "  "
   queue "   BLDINDEX  -"
   queue "       INDATASET( -"baseclname ") -"
   queue "      OUTDATASET( -"aixname ")"
   queue " "
   queue "   VERIFY DATASET( -"aixname ")"
 
return                                 /*@ BGX_DEFAIX                */
/*
   Pump the queue to a dataset or the terminal
.  ----------------------------------------------------------------- */
BGY_OUTPUT_DEFINE:                     /*@                           */
   if branch then call BRANCH
   address TSO
 
   zz = Msg('OFF')
   "ALLOC FI($TMP) NEW REU UNIT(VIO) SPACE(1) TRACKS RECFM(V B)",
     "LRECL(255) BLKSIZE(0)"
   if rc = 12 then alcunit = "SYSDA"
              else alcunit = "VIO"
   "FREE  FI($TMP)"
   zz = Msg(zz)
 
 
   alloc.0   = "NEW CATALOG UNIT(SYSDA) SPACE(1) TRACKS",
               "RECFM(V B) LRECL( 255 ) BLKSIZE(0)"
   vio.0     = "NEW CATALOG UNIT("alcunit") SPACE(1) TRACKS",
               "RECFM(V B) LRECL( 255 ) BLKSIZE(0)"
   alloc.1   = "SHR"                /* if it already exists...    */
 
   if outdsn <> "" then do             /* write to DASD              */
      tempstat = Sysdsn(outdsn) = "OK",/* 1=exists, 0=missing        */
               | Sysdsn(outdsn) = "MEMBER NOT FOUND"
      "ALLOC FI($TMP) DA("outdsn") REU" alloc.tempstat
      "EXECIO" queued() "DISKW $TMP (FINIS"
      sw.0BrowseTMP = 1                /*                            */
      end                              /* outdsn                     */
   else ,                              /* no OUTDSN                  */
   if sw.inispf then do                /* ISPF available             */
      "ALLOC FI($TMP)  REU" vio.0
      "EXECIO" queued() "DISKW $TMP (FINIS"
      sw.0BrowseTMP = 1                /*                            */
      end                              /* inispf                     */
   else do                             /* write to terminal          */
      "CLEAR"                          /*                            */
      do queued()
         pull line; say line           /*                            */
      end                              /* queued                     */
      end                              /* terminal                   */
 
return                                 /*@ BGY_OUTPUT_DEFINE         */
/*
.  ----------------------------------------------------------------- */
BGZ_BROWSE_TMP:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if sw.0outpds then do
      if Left(outdsn,1) = "'" then,    /* quoted                     */
         outdsn = Strip(outdsn,,"'")   /* unquoted                   */
      else outdsn = Userid()"."outdsn  /* fully qualified            */
      parse var outdsn dsname "(" dsmbr ")"
      "LMINIT DATAID(DDNID) DATASET('"dsname"')"
      vwsuff = "MEMBER("dsmbr")"
      end                              /* sw.0outpds                 */
   else,
      "LMINIT DATAID(DDNID) DDNAME($TMP)"
 
   "EDIT DATAID("ddnid")" vwsuff
 
return                                 /*@ BGZ_BROWSE_TMP            */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   if SWITCH("NONEST") then sw.nested = 0
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      generates pro-forma IDCAMS DEFINE statements for the   "
say "                specified entity such as would have been used to       "
say "                create it originally.                                  "
say "                                                                       "
say "  Syntax:   "ex_nam"  <dsname>                                         "
say "                      <OUTPUT outdsn>                                  "
say "                      <SKINNY>                                         "
say "                                                                       "
say "            dsname    identifies the entity to be analyzed so that (a) "
say "                      DEFINE statement(s) can be constructed.          "
say "                                                                       "
say "            outdsn    names the target to receive the generated IDCAMS "
say "                      DEFINE statements.                               "
say "                                                                       "
say "            SKINNY    produces a shortened DEFINE which names only the "
say "                      CLUSTER.                                         "
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
 
   "QSTACK"                            /* how many stacks?           */
   stk2dump    = rc - tk_init_stacks   /* remaining stacks           */
   if stk2dump = 0 & queued() = 0 then return
   say "Total Stacks" rc ,             /* rc = #of stacks            */
    "   Begin Stacks" tk_init_stacks , /* Stacks present at start    */
    "   Excess Stacks to dump" stk2dump
 
   do dd = rc to tk_init_stacks by -1  /* empty each one.            */
      say "Processing Stack #" dd "   Total Lines:" queued()
      do queued();pull line;say line;end /* pump to the screen       */
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
   arg kw
   kw_pos = wordpos(kw,info)           /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   kw_val = word(info,kw_pos+Words(kw))/* get the next word          */
   info   = Delword(info,kw_pos,2)     /* remove both                */
return kw_val                          /*@ KEYWD                     */
/*
.  ----------------------------------------------------------------- */
KEYPHRS: Procedure expose,             /*@                           */
         info helpmsg exec_name        /*  except these three        */
   arg kp
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
   arg  ssbeg  ssend  .
   if ssend = "" then ssend = 10
   if \datatype(ssbeg,"W") | \datatype(ssend,"W") then return
   ssend = ssbeg + ssend
   do ssii = ssbeg to ssend ; say Strip(sourceline(ssii),'T') ; end
return                                 /*@ SS                        */
/*
.  ----------------------------------------------------------------- */
SWITCH: Procedure expose info          /*@                           */
   arg kw
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
 
   if Word(parms,1) = "?" then call HELP /* I won't be back          */
 
   "QSTACK" ; tk_init_stacks = rc      /* How many stacks?           */
 
   parse value SWITCH("BRANCH") SWITCH("MONITOR") SWITCH("NOUPDT") with,
               branch           monitor           noupdt    .
 
   parse value mvsvar("SYSNAME") sysvar("SYSNODE") with,
               #tk_cpu           node          .
 
   sw.nested    = sysvar("SYSNEST") = "YES"
   sw.batch     = sysvar("SYSENV")  = "BACK"
   sw.inispf    = sysvar("SYSISPF") = "ACTIVE"
 
   parse value KEYWD("TRACE")  "O"    with   tv  .
   tk_globalvars = "exec_name  tv  helpmsg  sw.  zerrhm  zerralrm ",
                   "zerrsm  zerrlm  tk_init_stacks  branch  monitor ",
                   "noupdt"
 
   call LOCAL_PREINIT                  /* for more opts             -*/
 
return                                 /*@ TOOLKIT_INIT              */
