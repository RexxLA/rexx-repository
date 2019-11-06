/* REXX    RSTTBL   this is the anti-process of FLTTBL.  This
                      rebuilds an ISPF table from the data produced
                      by FLTTBL.
 
           Written by Frank Clarke, Richmond, 19990806
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20010618 fxc upgrade from v.19990709 to v.20010524; WIDEHELP;
                  ....
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010524      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
 
"NEWSTACK"                             /* isolate queue data         */
                                    if \sw.0error_found then,
call B_READ_FLATFILE                   /*                           -*/
                                    if \sw.0error_found then,
call C_POPULATE_TABLE                  /*                           -*/
"DELSTACK"                             /* expose queue data          */
 
if helpmsg <> "" then call HELP
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ RSTTBL                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   call AA_KEYWDS                      /*                           -*/
   openmode.0  = "WRITE"               /* based on NOUPDT            */
   openmode.1  = "NOWRITE"             /*                            */
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   prm_flatdsn  = KEYWD("FROM")
   prm_libdsn   = KEYWD("LIBRARY")
   parse var info  prm_tblnm  info
 
   if prm_tblnm prm_flatdsn = "" then do
      helpmsg = "Either NAME or FROM must be specified.  You may",
                "specify both."
      call HELP                        /* ...and don't come back     */
      end
   parse value prm_flatdsn   "FLATTBLS."prm_tblnm     with,
               flatdsn   .
 
return                                 /*@ AA_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
B_READ_FLATFILE:                       /*@                           */
   if branch then call BRANCH
   address TSO
 
   "ALLOC FI($IN) DA("flatdsn")  SHR REU"
   if rc > 4 then do
      say       "Dataset" flatdsn "failed to ALLOCate."
      sw.0error_found = "1" ; return
      end
   "EXECIO * DISKR $IN (FINIS"         /* load the data queue        */
   "FREE  FI($IN)"                     /* finished with file         */
 
   if queued() < 2 then do
      say       "Dataset" flatdsn "has no data."
      sw.0error_found = "1" ; return
      end
   parse pull "Contents of" dta_tblnm libdata "rows)" ,
              "KEYS(" keylst ")",
              "NAMES(" nmlist ")"
   parse var libdata    libdata   "(" rowcount .
   parse var libdata  "in" dta_libdsn  .
   if dta_libdsn <> "" then dta_libdsn = "'"dta_libdsn"'"
 
   parse value prm_tblnm   dta_tblnm    with,
               $tn$    .
   parse value prm_libdsn  dta_libdsn   with,
               libdsn  .
 
   if libdsn = "" then do              /* no specification           */
      helpmsg = "LIBRARY was not specified and no library name was",
                  "found in the header of" flatdsn".  Processing",
                  "halted.  Specify LIBRARY when reinvoking."
      sw.0error_found = "1" ; return
      end                              /* no LIBDSN                  */
 
   if Sysdsn(libdsn) <> "OK" then do   /* needs to be built          */
      "ALLOC FI($TMP) DA("libdsn") NEW CATALOG REU UNIT(SYSDA)",
            "DSNTYPE(LIBRARY)",        /* PDSE                       */
            "RECFM(F B) LRECL(80) BLKSIZE(0) SPACE(5 5) TRACKS"
      "FREE  FI($TMP)"
      end
 
return                                 /*@ B_READ_FLATFILE           */
/*
.  ----------------------------------------------------------------- */
C_POPULATE_TABLE:                      /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "CONTROL ERRORS RETURN"             /* I'll handle my own         */
   call CA_OPEN_TABLE                  /*                           -*/
                                    if \sw.0error_found then,
   call CL_LOAD_TABLE                  /*                           -*/
                                    if \sw.0error_found then,
   call CZ_WRAP_UP                     /*                           -*/
 
return                                 /*@ C_POPULATE_TABLE          */
/*
.  ----------------------------------------------------------------- */
CA_OPEN_TABLE:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "TBCREATE" $tn$ "KEYS("keylst") NAMES("nmlist") WRITE REPLACE"
 
return                                 /*@ CA_OPEN_TABLE             */
/*
.  The first line in the stack contained the root data about the
.  table: the table name, the dataset from which it was extracted,
.  the key fields, and the name fields.  Each additional line in the
.  stack represents a single table-row.  This row-data is in KEYPHRS
.  format: a keyword (which names a table column) followed by a
.  two-character separator followed by the data for that column
.  followed by a second two-character separator.  After the
.  keyfields and namefields, KEYPHRS 'XVARS' names any extension
.  variables for that row.  Extension variable data follows in
.  KEYPHRS format.
.
.  To recap: the row is formed as:
.    <keyfld data> <namefld data>  <xvar names>  <xvar data>
.  Each block above identifies one or more KEYPHRS blocks in which
.  the data appears as:
.     <literal .. one or more words ..>
.  with the '..' being any non-blank character pair, usually 'EFEF'x.
.
.  <xvars> may, of course, be empty in which case there is no xvar
.  data to follow.
.  ----------------------------------------------------------------- */
CL_LOAD_TABLE:                         /*@                           */
   cl_tv = trace()                     /* what setting at entry ?    */
   if branch then call BRANCH
   address ISPEXEC
 
   defined = Space(keylst nmlist,1)
   do queued()                         /* every line in the stack    */
      "TBVCLEAR" $tn$                  /* zap all columns            */
      parse pull info                  /* prepare for parsing        */
      call CLP_PARSE_FIELDS            /*                           -*/
                                     rc = Trace("O"); rc = trace(cl_tv)
      "TBMOD"  $tn$ "SAVE("xvarlst")"
 
   end                                 /* queued()                   */
 
return                                 /*@ CL_LOAD_TABLE             */
/*
.  ----------------------------------------------------------------- */
CLP_PARSE_FIELDS:                      /*@                           */
   if branch then call BRANCH
   address TSO
 
   do clx = 1 to Words(defined)
      fldn    = Word(defined,clx)      /* isolate field name         */
       clp_tv = trace()
           rc = Trace("O")
      fldval  = KEYPHRS(fldn)          /* acquire text from 'info'   */
           rc = Trace(clp_tv)
      $z$     = Value(fldn,fldval)     /* load fldval to fldn        */
      $z$     = fldval
   end                                 /* defined                    */
 
   xvarlst = KEYPHRS("XVARS")          /* any extension variables ?  */
   do clx = 1 to Words(xvarlst)
      fldn    = Word(xvarlst,clx)      /* isolate field name         */
       clp_tv = trace()
           rc = Trace("O")
      fldval  = KEYPHRS(fldn)          /* acquire text from 'info'   */
           rc = Trace(clp_tv)
      $z$     = Value(fldn,fldval)     /* load fldval to fldn        */
      $z$     = fldval
   end                                 /* xvars                      */
 
return                                 /*@ CLP_PARSE_FIELDS          */
/*
.  ----------------------------------------------------------------- */
CZ_WRAP_UP:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   "LIBDEF  ISPTABL  DATASET  ID("libdsn")  STACK"
   "TBCLOSE" $tn$
   "LIBDEF  ISPTABL"
 
return                                 /*@ CZ_WRAP_UP                */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"                    /* NMR uses CLEAR             */
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      Rebuilds an ISPF table from unload data produced by       "
say "                FLTTBL or a similar process.                            "
say "                                                                          "
say "  Syntax:   "ex_nam"  <tblname>                                           "
say "                      <FROM flat-dsn>                                     "
say "                      <LIBRARY output>                                    "
say "                 At least one of <tblname> and <flat-dsn> must be         "
say "                 specified in order to determine the primary input file.  "
say "                                                                          "
say "            <tblname>     identifies the name which is to be assigned to  "
say "                      the newly re-created table.  If not specified, it   "
say "                      will be determined from the header information of   "
say "                      the primary input file.                             "
say "                                                                          "
say "            <flat-dsn>   identifies the dataset which is to be used as the"
say "                      primary input.  If not specified, the tblname       "
say "                      determines the default as FLATTBLS.tblname.         "
say "                                                                          "
say "            <output>   identifies the ISPF table library which is to      "
say "                      receive the re-created table.  If this library does "
say "                      not exist it will be built.                         "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                  Displays most paragraph names upon entry.               "
say "                                                                          "
say "        NOUPDT:   by-pass all update logic.                               "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place                 "
say "                  the execution in REXX TRACE Mode.                       "
say "                                                                          "
say "                                                                          "
say "   Debugging tools can be accessed in the following manner:               "
say "                                                                          "
say "        TSO" ex_nam   "  parameters  ((  debug-options                    "
say "                                                                          "
say "   For example:                                                           "
say "                                                                          "
say "        TSO" ex_nam " (( MONITOR TRACE ?R                                 "
 
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*   REXXSKEL back-end removed for space */