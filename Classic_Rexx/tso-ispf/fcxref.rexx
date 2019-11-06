/* REXX    FCXREF     produces a side-by-side list  of member names
                      in a set of concatenated libraries.
           |**-***-***-***-***-***-***-***-***-***-***-***-***-**|
           |                                                     |
           |  WARNING: EMBEDDED COMPONENTS.                      |
           |              See text following TOOLKIT_INIT        |
           |                                                     |
           |**-***-***-***-***-***-***-***-***-***-***-***-***-**|

            Each library is LISTD'd to develop a list of members.
            This list is then annotated with an indicator of the
            source dataset, and the whole is sorted.  The resultant
            list is processed to provide one report line per member
            either with or without headers.  Three report formats
            are available:
              (a) with the member name positioned on the line
                  beneath the header for its origin dataset;
              (b) with member statistics positioned on the line
                  beneath the header for its origin dataset (STATS);
              (c) with the dataset number (only) appearing on the
                  line in a standard position (COMPACT).

            Because it makes each column so wide, STATS is practical
            only when the number of datasets being cross-referenced
            is fewer than 8.

            In rare instances, a large number of datasets allocated to
            a DDName may make the standard listing format impractical.
            Selecting COMPACT in this case provides a much narrower
            report style in which page 1 is devoted to merely listing
            the dataset names for which the list was done.  Subsequent
            pages list the member-name at the left margin, and next to
            it (a) numeric indicator(s) of the source dataset(s) in
            which it appears.  In this format, a count of how many
            datasets contain each member is also provided.

           Written by Frank Clarke

     Impact Analysis
.    SYSPROC   LA
.    SYSPROC   MEMBERS
.    SYSPROC   TRAPOUT

     Modification History
     19950504 fxc made output dataset FBA.
     19960514 fxc upgrade to REXXSKEL;
     19980302 fxc upgrade from v.960506 to v.19971030; DECOMM;
                  RXSKLY2K;
     19990908 fxc use MEMBERS to develop alias lists; drop E_ and F_;
                  enable call-from-READY;
     19991129 fxc upgrade from v.19971030 to v.19991109; new DEIMBED;
     20000208 fxc make Y2K compliant: was using ZLMDATE instead of
              ZLM4DATE;
     20010515 fxc reorganize and restructure; panel is now 30 names long
              and scrollable; to make it longer, add lines in area
              DSLIST and change "listlim" to reflect the length of the
              list;
     20010613 fxc several difficult bugs related to unloading the panel
              data, bad switch names, etc; uncovered when I tried to run
              without using a DDNAME as part of the parm data;

*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts

signal on syntax
signal on novalue

call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */

call A_INIT                            /*                           -*/
                                    if sw.0ISPF_requested then,
call B_SETUP_LIBDEFS                   /*                           -*/
call C_GET_DSNS                        /*                           -*/
                                    if sw.0ISPF_requested then,
call D_DROP_LIBDEFS                    /*                           -*/
if sw.0halt_process then exit

call E_LOAD_SORTIN                     /*                           -*/

if sw.0compact then call HC_SHORTHDR; else, /*                      -*/
if sw.0stats then call HS_STATHDR      /*                           -*/
else call HA_STANDARD_HDR              /* gen report header lines   -*/

call Q_COMPOSE                         /* finish report             -*/

exit                                   /*@ FCXREF                    */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO

   if parms="" then call HELP          /*                           -*/
   parse value ""  with,
            dsn.  ,
            ddn mlist.                 /* guarantee values           */

   call AA_KEYWDS                      /*                           -*/

   if sw.0ISPF_requested | sw.0stats then,
   if \sw.inispf then do
      "ISPSTART CMD("exec_name argline")" /* Invoke ISPF             */
      exit
      end

                     /* no line-mode output when BROWSE is available */
   if outdsn = "" & sw.inispf then,
      parse value exec_name".$TMP" with,
                  outdsn  .

   if sw.0ISPF_requested then call DEIMBED /*                       -*/

   if sw.0stats & sw.0compact then do
      helpmsg = "STATS and COMPACT are mutually exclusive"
      call HELP                        /*                           -*/
      end
   else if sw.0stats then,             /* stats-display              */
           parse value "16 11" with collen margin .
   else if sw.0compact then,           /* presence-display           */
           parse value " 2 17" with collen margin .
   else parse value "10  2" with collen margin .  /* name-display    */

   if lpp = "" then,
   if outdsn = "" then pagelim = 22    /* 22 for term, 60 for print  */
                  else,
      if \sw.0do_hdr then pagelim = 0
                     else pagelim = 60

   if Space(memmask lomem himem,0) <> "" then,
      sw.0selective = "1"              /* do member selection        */

   listlim = 30                        /* number of DSNs on panel    */

return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO

   sw.0ISPF_requested = SWITCH("ISPF")
   sw.0dup_only       = SWITCH("CONFLICTS")
   sw.0compact        = SWITCH("COMPACT")
   sw.0stats          = SWITCH("STATS")
   sw.0do_hdr         = \SWITCH("NOHDR")     /* Headers or not ?     */

   ddn      = KEYWD("DDNAME")          /* Input via DDName ?         */
   outdsn   = KEYWD("OUTPUT")          /* Output to a dataset ?      */
   lpp      = KEYWD("LPP")             /* lines-per-page             */

   memmask  = KEYWD("MEMBERSLIKE")
   lomem    = KEYWD("MEMBERSFROM")
   himem    = KEYWD("MEMBERSTO")

return                                 /*@ AA_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
B_SETUP_LIBDEFS:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   ddn = ""
   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd with dd ddnlist
      $ddn = $ddn.dd                   /* PLIB322 <- PLIB            */
      "LIBDEF ISP"dd "LIBRARY ID("$ddn") STACK"
   end
   ddnlist = ddnlist dd

return                                 /*@ B_SETUP_LIBDEFS           */
/*
.  ----------------------------------------------------------------- */
C_GET_DSNS:                            /*@                           */
   if branch then call BRANCH
   address TSO

   do forever
      if ddn <> "" then do
         "NEWSTACK"
         "LA" ddn "((STACK"            /* call LA, return stack      */
         pull dsnstr                   /* retrieve stack             */
         "DELSTACK"
         if monitor then say,
            "LA:" dsnstr
         dsn. = ""                     /* set up array               */
         dsn.0 = words(dsnstr)         /* how many dsnames ?         */
         do ii = 1 to dsn.0
            dsn.ii = "'"Word(dsnstr,ii)"'"
         end
         ddn = ""                      /*                            */
         end

      if sw.0ISPF_requested then do
         call CA_LOAD_PNL              /* load to screen variables  -*/
         if sw.0do_hdr then hdr = "Y"
                       else hdr = "N"
         address ISPEXEC "DISPLAY PANEL(GETLIBS)"
         if rc = 8 then do
            sw.0halt_process = "1"
            leave
            end

         if ddn <> "" then iterate     /* re-do the loop             */
         sw.0do_hdr = hdr = "Y"
         call CU_UNLOAD_PNL            /*                           -*/
         end                           /* sw.0ISPF_requested         */
      call CZ_SETUP_OUTPUT             /*                           -*/
      leave                            /* don't re-do the loop       */
   end                                 /* forever                    */

return                                 /*@ C_GET_DSNS                */
/*
.  Convert variables of the form: dsn.1, dsn.2, ..., dsn.n ;
.  to variables of the form: dsn1, dsn2, ..., dsnn.
.  ----------------------------------------------------------------- */
CA_LOAD_PNL:                           /*@                           */
   if branch then call BRANCH
   address TSO

   do bx = 1 to listlim                /* each line of panel         */
      $z$ = Value("xrdsn"bx,dsn.bx)
   end                                 /* bx                         */

return                                 /*@ CA_LOAD_PNL               */
   list = dsn.1 dsn.2 dsn.3 dsn.4 dsn.5 dsn.6 dsn.7,
          dsn.8 dsn.9 dsn.10 dsn.11 dsn.12
   if list = "" then exit
   parse var list xrdsn1 xrdsn2 xrdsn3 xrdsn4 xrdsn5 xrdsn6,
                  xrdsn7 xrdsn8 xrdsn9 xrdsn10 xrdsn11 xrdsn12 .
/*
.  Convert variables of the form: xrdsn1, xrdsn2, ..., xrdsnn ;
.  to variables of the form: dsn.1, dsn.2, ..., dsn.n.
.  ----------------------------------------------------------------- */
CU_UNLOAD_PNL:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   parse value  "0"  with  dsn.0  dsnstr  thisdsn
   do cx = 1 to listlim                /* each panel line            */
      dsnstr = Space(dsnstr Value("xrdsn"cx) ,1)
   end                                 /* cx                         */

   do Words(dsnstr)                    /* whole list                 */
      parse value dsnstr thisdsn  with  thisdsn  dsnstr
      if Left(thisdsn,1)  <>  "'" then, /* quoted ?                  */
         thisdsn = "'"Userid()"."thisdsn"'"  /* no, attach userid.   */
      parse value dsn.0+1 thisdsn  with,
                  cx      dsn.cx  1   dsn.0 .
   end                                 /* dsnstr                     */
   dsnstr = dsnstr thisdsn             /* add last one               */
   dsnstr = Translate(dsnstr," ","'" ) /* translate all quotes away  */

return                                 /*@ CU_UNLOAD_PNL             */
   dsn.0 = Words(dsnstr)
   do cx = 1 to dsn.0                  /* for each list item         */
      dsn.cx = Word(dsnstr,cx)         /* isolate                    */
      if Left(dsn.i,1)  <>  "'" then,  /* quoted ?                   */
         dsn.i = "'"Userid()"."dsn.i"'" /* no, attach userid.        */
   end

   dsnstr = ""                         /* clear work area            */
   do i = 1 to dsn.0
      dsnstr = dsnstr dsn.i            /* splice dsn to dsnstr       */
   end
/*
   As soon as we know how many datasets we're dealing with, set up the
   output dataset.
.  ----------------------------------------------------------------- */
CZ_SETUP_OUTPUT:                       /*@                           */
   if branch then call BRANCH
   address TSO

   /* COMPACT display puts the membername and count on each line and
      adds markers by dataset; STATS/normal show either member-stats
      or the member-name in each column. */
   if outdsn <> "" then do
      outlen = (dsn.0 * (collen+1)) + margin

      outlen = Max(outlen,60)          /* never shorter than 60      */
      orig_msg = Msg("off")
      "DELETE" outdsn "SCR PURGE"
      "ALLOC FI(OUT) DA("outdsn") NEW CATALOG UNIT(SYSDA) SPACE(20 20)",
          " TRACKS RECFM(F B A) LRECL("outlen") BLKSIZE(0) REU"
      msg_stat = Msg(orig_msg)
      outop = "QUEUE"
      end
   else outop = "SAY"

return                                 /*@ CZ_SETUP_OUTPUT           */
/*
.  ----------------------------------------------------------------- */
D_DROP_LIBDEFS:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   dd = ""
   do Words(ddnlist)                   /* each LIBDEF DD             */
      parse value ddnlist dd with dd ddnlist
      $ddn = $ddn.dd                   /* PLIB322 <- PLIB            */
      "LIBDEF ISP"dd "LIBRARY ID("$ddn") STACK"
   end

return                                 /*@ D_DROP_LIBDEFS            */
/*
   Requires array DSN. to be populated with the dsnames to be
   processed.
.  ----------------------------------------------------------------- */
E_LOAD_SORTIN:                         /*@                           */
   if branch then call BRANCH
   address TSO

   parse value "0" with midx  lvls.           /* set up array        */

   "NEWSTACK"                          /* isolate prior queues       */
   do dsix = 1 to dsn.0                /* for all dsnames            */
      if Sysdsn(dsn.dsix) <> "OK" then,
         iterate                       /* skip it, get next dsn      */
      "NEWSTACK"
      "MEMBERS" dsn.dsix "((STACK LINE ALIAS"
      pull mbrlist
      "DELSTACK"
      if sw.0selective then call EA_TRIM_MBRLIST     /*             -*/
      if monitor then say dsn.dsix
      if monitor then say mbrlist

      lvls.dsix = Translate(Word(dsnstr,dsix)," ",".")   /* zap dots */

      do Words(mbrlist)                /* each member/alias          */
         parse var mbrlist   mbr  mbrlist      /* isolate mbrname    */
         if Right(mbr,3) = "(*)" then do   /* it's an ALIAS          */
            parse var mbr  mbr "("
            queue  mbr  dsix  "*"
            end                        /* ALIAS                      */
         else queue mbr dsix           /* not an ALIAS               */
      end
   end                                 /* dsix                       */

   midx  = queued()                    /* how many lines ?           */
   "ALLOC FI(SORTIN) DA(TEMPSRT) RECFM(F B) SPACE(5 2) TRACK NEW REU",
      " LRECL(16) BLKSIZE(0)"
   if rc > 4 then do
      "ALLOC FI(SORTIN) DA(TEMPSRT) SHR REU"
      end
   "EXECIO" midx "DISKW SORTIN (FINIS"
   "DELSTACK"                          /* restore prior queues       */

   say "Starting sort," midx "items."

   rc = Outtrap("sort.")
   "ALLOC FI(SORTOUT) DA(TEMPSRT) SHR REU"
   "ALLOC FI(SYSOUT) DUMMY REU "

   "ALLOC FI(SYSIN) NEW TRACKS SPACE(1) UNIT(SYSDA)",
          " LRECL(80) BLKSIZE(800) RECFM(F B) REU"
   queue " SORT FIELDS=(1,12,CH,A)"
   "EXECIO" queued() "DISKW SYSIN (FINIS"

   sortprm = "MSG=CC"                  /* suppress messages          */
   address LINKMVS "SORT sortprm"
   "EXECIO *      DISKR SORTOUT (STEM MLIST. FINIS"

   "FREE FI(SORTIN SORTOUT SYSOUT)"
   "ALLOC FI(SYSIN) DA(*) SHR REU"
   "DELETE TEMPSRT SCR PURGE"
   rc = Outtrap("off")

   say "Finished sort," mlist.0 "items."

return                                 /*@ E_LOAD_SORTIN             */
/*
   Some combination of MEMBERSLIKE, MEMBERSFROM, and MEMBERSTO was
   specified.  Remove any unneeded names from <mbrlist>.
.  ----------------------------------------------------------------- */
EA_TRIM_MBRLIST:                       /*@                           */
   if branch then call BRANCH
   address TSO

   if lomem <> "" then do
      do Words(mbrlist)                /* each membername            */
         parse var mbrlist mbr mbrlist
         if mbr < lomem then iterate   /* discard                    */
         mbrlist = mbr mbrlist         /* restore                    */
         leave                         /* all done                   */
      end                              /* words                      */
      end

   if himem <> "" then do
      temp = ""
      do Words(mbrlist)                /* each membername            */
         parse var mbrlist mbr mbrlist
         if mbr < himem then temp = temp mbr      /* save            */
                        else leave
      end                              /* words                      */
      mbrlist = temp
      end

   if memmask <> "" then do
      memmask = Strip(memmask,"T","*")"*"
      maskl   = Length(memmask)
      lomask  = Translate(memmask, '00'x , "*")
      himask  = Translate(memmask, 'FF'x , "*")
      do Words(mbrlist)                /* each membername            */
         parse var mbrlist mbr mbrlist
         if BitAnd(himask,Left(mbr,maskl)) = ,
             BitOr(lomask,Left(mbr,maskl)) then,
            mbrlist = mbrlist mbr
      end                              /* words                      */
      end

return                                 /*@ EA_TRIM_MBRLIST           */
/*
.  Build standard (not STATS, not COMPACT) header records:
.  " | ........ | ........ | ........ | ..etc"
.  that is: starts with " | " plus qualifier padded to l=10, repeat
.  for all datasets.
.  ----------------------------------------------------------------- */
HA_STANDARD_HDR:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   slug       = Right("",collen)"|"
   sluglen    = Length(slug)

   base_line = " |"Copies(slug,dsn.0)  /* leader = 2 bytes           */

   do ii = 1 to dsn.0
      rdsn.ii  = Reverse(lvls.ii)      /* CEXE TSET 54321TD, maybe ? */
   end

   more = "1"
   do while more

      more = "0"
      hdrline = base_line              /* start of line              */

      do ii = 1 to dsn.0
         parse var rdsn.ii tlvl rdsn.ii /* TSET maybe                */
         tlvl  = Reverse(tlvl)         /* TEST maybe                 */
         pos = ((ii-1) * sluglen) + 4  /* 4, 15, 26, 37, maybe       */
         hdrline = Overlay( Left(tlvl,8) , hdrline , pos , 8 )
         if rdsn.ii <> "" then more = "1" /* do another cycle        */
      end

      push hdrline                     /* place on top of the stack  */

   end                                 /* while more                 */

   hdrline = base_line                 /* start separator line       */
   hdrline = Translate(hdrline,"-"," ")
   hdrline = Translate(hdrline,"+","|")
   hdrline = Overlay(" ",hdrline,1,1)
   queue hdrline

   hidx = 0; hdr.=""                   /* set up array               */
   do queued()                         /* hdrlines in stack          */
      pull hdrline                     /* pull topmost               */
      hidx = hidx + 1                  /* increment index            */
      hdr.hidx = hdrline               /* load to array              */
   end
   hdr.1 = Overlay("1",hdr.1)          /* page eject                 */
   hdr.0 = hidx                        /* how many header lines ?    */

return                                 /*@ HA_STANDARD_HDR           */
/*
.  build header records:
.  This routine builds header records for the "COMPACT" display:
.  starts with "          |    |" plus room for dataset identifier,
.  padded to l=3, repeat for all datasets.  Total length = 17 + 3
.  per dataset.
.  ----------------------------------------------------------------- */
HC_SHORTHDR:                           /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   base_line = "          |    |"      /* leader = 16 bytes          */
   hdrline = base_line                 /* start of line              */
   sluglen = 3

   queue hdrline                       /* place on bottom of stack   */

   hidx = 0; hdr.=""                   /* set up array               */
   do queued()                         /* hdrlines in stack          */
      pull hdrline                     /* pull topmost               */
      hidx = hidx + 1                  /* increment index            */
      hdr.hidx = hdrline               /* load to array              */
   end
   hdr.1 = Overlay("1",hdr.1)          /* page eject                 */

   hdrline = Copies("-",outlen)        /* all dashes                 */
   hdrline = Overlay(base_line,hdrline) /* overlay bars              */
   hdrline = Overlay("|",hdrline,outlen) /* last char = bar          */
   hdrline = Translate(hdrline,"-"," ")
   hdrline = Translate(hdrline,"+","|") /* bars become pluses        */
   hdrline = Overlay(" ",hdrline,1,1)

   hidx = hidx + 1                     /* increment index            */
   hdr.hidx = hdrline                  /* add to array               */
   hdr.0 = hidx                        /* how many header lines ?    */
   call HCA_TITLE_PG                   /* put up dsn list           -*/

return                                 /*@ HC_SHORTHDR               */
/*
.    Since the headers do not indicate the dataset name, we need a
.    title page which cross-references the indicators "(12)" to the
.    dataset name, e.g.:
.        (12) =   "TTGTCBS.DOCLIB.BLG.LETTERS"
.    These lines have to be PUSHed onto the top of the stack so that
.    they are written first.
.  ----------------------------------------------------------------- */
HCA_TITLE_PG:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   asa = " "
   do i = dsn.0 to 1 by -1             /* for each dataset           */
      line = asa"      ("Right(i,2)")  = "Word(dsnstr,i)
      push line                        /* WRITE                      */
   end

   asa = "1"
   line = asa"    Compact member cross reference "
   push line                           /* WRITE                      */

return                                 /*@ HCA_TITLE_PG              */
/*
.  build header records (STATS="1") :
.  This routine builds header records for the "STATS" display:
.  starts with "          |" plus room for member statistics,
.  padded to l=16, repeat for all datasets.  Total length = 13 + 16
.  per dataset.
.  ----------------------------------------------------------------- */
HS_STATHDR:                            /*@                           */
   if branch then call BRANCH
   address TSO

   slug       = Right("",collen)"|"
   sluglen    = Length(slug)
   base_line = "          |"Copies(slug,dsn.0) /* leader = 11 bytes  */

   do ii = 1 to dsn.0
      rdsn.ii  = Reverse(lvls.ii)      /* CEXE TSET 54321TD, maybe ? */
   end

   more = "1"
   do while more

      more = "0"
      hdrline = base_line              /* start of line              */

      do ii = 1 to dsn.0
         parse var rdsn.ii tlvl rdsn.ii /* TSET maybe                */
         tlvl  = Reverse(tlvl)         /* TEST maybe                 */
         pos = ((ii-1) * sluglen) + 13 /* 13, 30, 47     maybe       */
         hdrline = Overlay( Left(tlvl,8) , hdrline , pos , 8 )
         if rdsn.ii <> "" then more = "1" /* do another cycle        */
      end

      push hdrline                     /* place on top of the stack  */

   end                                 /* while more                 */

   hdrline = base_line                 /* start separator line       */
   hdrline = Translate(hdrline,"-"," ")
   hdrline = Translate(hdrline,"+","|")
   hdrline = Overlay(" ",hdrline,1,1)
   queue hdrline                       /* after headers              */

   hidx = 0; hdr.=""                   /* set up array               */
   do queued()                         /* hdrlines in stack          */
      pull hdrline                     /* pull topmost               */
      hidx = hidx + 1                  /* increment index            */
      hdr.hidx = hdrline               /* load to array              */
   end
   hdr.1 = Overlay("1",hdr.1)          /* page eject                 */
   hdr.0 = hidx                        /* how many header lines ?    */

return                                 /*@ HS_STATHDR                */
/*
.   input is a stack, MLIST., with entries of the form:
.                 NAME # {*}
.   sorted by name and #
.
.   Output (for STATS='0') is a line of 'n' 10-char compartments
.   separated by vertical bars.  'n' is not larger than the largest
.   '#'.  The 'name' is placed in a compartment as indicated by '#'.
.
.   Output (for STATS='1') is a line of 'n' 16-char compartments
.   separated by vertical bars.  'n' is not larger than the largest
.   '#'.  The member statistics are placed in a compartment as
.   indicated by '#'.  The membername is placed at the far left of
.   the line.
.
.   Output (for COMPACT='1') is a line of 'n' 2-char compartments
.   separated by blanks.  The dataset number is placed in a
.   compartment as indicated by '#'.  The membername and the number
.   of occurences is placed at the far left of the line.
.  ----------------------------------------------------------------- */
Q_COMPOSE:                             /*@                           */
   q_tv = trace()                      /* what setting at entry ?    */
   if branch then call BRANCH
   address TSO

   if sw.0stats then call QA_LMOPEN    /*                           -*/
   wait_for_enter="0"                  /* prompting switch           */
   line = base_line                    /* init                       */
   call QP_NEWPAGE                     /* first set of headers      -*/

   save_mbr = word(mlist.1,1)          /* avoid initial break        */
   if sw.0compact | sw.0stats then,    /* ... load 1st membername    */
      line = Overlay(save_mbr,line,2,8)

   ind = ""                            /* "*" if ALIAS               */
   occurs = 0                          /* members per line           */
   do mx = 1 to mlist.0                /* for each list item         */

      parse var mlist.mx mbr pos ind . /* get name and position      */
      if save_mbr <> mbr then do       /* if name break              */
         if sw.0compact then,
            line = Overlay(Right(occurs,2),line,13,2)
         if sw.0dup_only & occurs=1 then nop /* skip                 */
         else call QQ_PUMPLINE         /* write the line at break   -*/
         latest_date = ""
         line = base_line
         occurs = 0
         save_mbr = mbr                /* store new name             */
         if sw.0compact | sw.0stats then,
            line = Overlay(mbr,line,2,8)
         end                           /* if name break              */

      spot = ((pos-1) * sluglen) +  margin + 2

      if sw.0compact then,
         line = Overlay(Right(pos,2,0)||ind,line,spot-1,collen+1)
      else,
      if sw.0stats then do
         call QS_GET_STATS             /*                           -*/
         parse var mstat 3 mstat8      /* clip off century           */
         line = Overlay(Left(mstat8,collen),line,spot,collen-2)
         end
      else,
         line = Overlay(Left(mbr,collen)||ind,line,spot,collen-2)
      occurs = occurs + 1              /* count it                   */

   end                                 /* mx                         */

   if sw.0compact then,
      line = Overlay(Right(occurs,2),line,13,2)

   if sw.0dup_only & occurs=1 then nop /* skip                       */
   else call QQ_PUMPLINE               /* write the line at break   -*/

   if sw.0stats then call QZ_LMCLOSE   /*                           -*/

                                     rc = Trace("O"); rc = trace(q_tv)
   if outdsn <> "" then do             /* output to dataset          */
      "EXECIO" queued() "DISKW OUT (FINIS"/* pump entire queue       */
      end
   "FREE FI(OUT)"

   if sw.batch then return             /* don't BROWSE               */
   if sw.inispf & outdsn <> "" then,
      address ISPEXEC "BROWSE DATASET("outdsn")"

return                                 /*@ Q_COMPOSE                 */
/*
.  ----------------------------------------------------------------- */
QA_LMOPEN:                             /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   do lmx = 1 to dsn.0
      "LMINIT DATAID(LMID"lmx") DATASET("dsn.lmx")"
      "LMOPEN DATAID("Value("LMID"lmx)")"
   end

   latest_date = ""

return                                 /*@ QA_LMOPEN                 */
/*
.  ----------------------------------------------------------------- */
QP_NEWPAGE:                            /*@                           */
   if branch then call BRANCH
   address TSO

   if wait_for_enter then pull         /* wait for KB enter          */
   if outdsn="" then do
      wait_for_enter="1"               /* was initially off          */
      "CLEAR"                          /* clear the screen           */
      end

   do hidx = 1 to hdr.0                /* for each header line       */
      if outop = "QUEUE" then,
         queue hdr.hidx ; else,
         say   hdr.hidx
   end
   linect = hdr.0                      /* indicate lines used        */

return                                 /*@ QP_NEWPAGE                */
/*
.  ----------------------------------------------------------------- */
QQ_PUMPLINE:                           /*@                           */
   if branch then call BRANCH
   address TSO

   if sw.0stats then call QQA_AGE      /* who's newest              -*/
   if linect = pagelim then call QP_NEWPAGE /* page break           -*/

   if outop = "QUEUE" then,
      queue line    ; else,
      say   line

   linect = linect + 1                 /* indicate line used         */

return                                 /*@ QQ_PUMPLINE               */
/*
.  Input is <latest_date>; find any stats slug which matches and tag
.  it with an > to indicate "most recent copy".
.  ----------------------------------------------------------------- */
QQA_AGE:                               /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   if occurs = 1 then return           /* nothing to compare         */
   if \Datatype(Left(latest_date,1),"W") then return  /* no stats    */
   /*
   rc = Trace("O"); rc = Trace(tv)
   */
   parse var latest_date 3 latest_date /* clip off century           */
   complen = Length(latest_date)
   do ibx = 1 to dsn.0
      start = ((ibx-1) * sluglen) + 13
      mslug = Substr(line,start,complen)  /* acquire statistics      */
      if latest_date = mslug then,
         line = Overlay(">",line,start-1,1)  /* mark it              */
   end                                 /* ibx                        */

return                                 /*@ QQA_AGE                   */
/*
.  Input is <mbr> and <pos>; get ISPF statistics for <mbr> in dataset
.  dsn.<pos>; load to variable <mstat> and return.
.  ----------------------------------------------------------------- */
QS_GET_STATS:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   "LMMFIND DATAID("Value("LMID"pos)") MEMBER("mbr")  STATS(YES)"
   mstat = zlm4date zlmtime            /* 1998/02/27 15:22  l=14+2   */
   if mstat = "" then,
      if ind = "*" then mstat = "    (alias)"
                   else mstat = "   (no stats)"
                 else,
   if latest_date < mstat then,
      latest_date = mstat

return                                 /*@ QS_GET_STATS              */
/*
.  ----------------------------------------------------------------- */
QZ_LMCLOSE:                            /*@                           */
   if branch then call BRANCH
   address ISPEXEC

   do lmx = 1 to dsn.0
      "LMCLOSE DATAID("Value("LMID"lmx)")"
      "LMFREE  DATAID(LMID"lmx")"
   end

return                                 /*@ QZ_LMCLOSE                */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   if branch then call BRANCH
   address TSO


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

say "                                                                          "
say "  Help for "exec_name"                                                    "
say "                                                                          "
say "  "ex_nam"  produces a side-by-side match of member names in a set of     "
say "            concatenated libraries.                                       "
say "                                                                          "
say "  Syntax :  "ex_nam" <DDNAME filename>                                    "
say "                     <OUTPUT outdsn>                                      "
say "                     <NOHDR>                                              "
say "                     <LPP pagelen>                                        "
say "                     <ISPF>                                               "
say "                     <CONFLICTS>                                          "
say "                     <COMPACT | STATS>                                    "
say "                     <MEMBERSLIKE pattern>                                "
say "                     <MEMBERSFROM mbr>                                    "
say "                     <MEMBERSTO   mbr>                                    "
say "                                                                          "
say "  Parameters which may be specified:                                      "
say "                                                                          "
say "          <filename> :  the datasets associated with the specified ddname "
say "            are examined to produce a cross-reference list of the member  "
say "            names.                                                        "
say "                                                                          "
say "          <outdsn> :  the resultant report is written to DSN=outdsn.  This"
say "            dataset will be deleted if it exists and recreated with an    "
say "            appropriate LRECL.  By default, output is to the monitor.  The"
say "            minimum LRECL for OUTDSN is 60.                               "
say "                                                                          "
say "                                           more.....                      "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "  Parameters (continued)                                                  "
say "                                                                          "
say "          <NOHDR> :  no header lines (except the initial set) are written."
say "                                                                          "
say "          <pagelen> specifies the page length.                            "
say "                                                                          "
say "          <ISPF> :  causes "exec_name" to run as an ISPF dialog.          "
say "                                                                          "
say "          <pattern> is a wild-carded member name using '*' to specify the "
say "                    positions which may be any character.                 "
say "                                                                          "
say "          <mbr>     specifies either the earliest named member to be      "
say "                    selected (MEMBERFROM) or the earliest named member    "
say "                    which will cause selection to halt (MEMBERTO).  Absent"
say "                    MEMBERFROM, selection begins with the earliest member;"
say "                    absent MEMBERTO, selection continues to the latest    "
say "                    member.  Both may be specified.                       "
say "                                                                          "
say "                                           more.....                      "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "  Parameters (continued)                                                  "
say "                                                                          "
say "          <CONFLICTS> : instructs "exec_name" to show only lines where a  "
say "            membername exists in more than one dataset.                   "
say "                                                                          "
say "          <STATS>  :  the date and time of last modification is shown for "
say "            each member.                                                  "
say "                                                                          "
say "          <COMPACT>:  for cases in which many datasets are to be matched, "
say "            listing the membernames side-by-side may produce a listing too"
say "            wide to be printed.  COMPACT formats the listing as follows:  "
say "                                                                          "
say "              -- a header page is printed, listing all the datasets and   "
say "                 assigning an index number to each.                       "
say "                                                                          "
say "              -- membernames are listed once down the left margin with a  "
say "                 count of occurrences.  The balance of the line consists  "
say "                 of numeric references to the datasets listed on the first"
say "                 page.                                                    "
say "                                                                          "
say "                                           more.....                      "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "                                                                          "
say "            In COMPACT-mode, the LRECL of the output dataset is           "
say "               LR = 3x + 16, where x = number of datasets.                "
say "                                                                          "
say "            In normal-mode, the LRECL of the output dataset is            "
say "               LR = 11x + 2, where x = number of datasets.                "
say "                                                                          "
say "            In STATS-mode, the LRECL of the output dataset is             "
say "               LR = 17x + 2, where x = number of datasets.                "
say "                                                                          "
say "            Therefore, if the number of datasets exceeds 7, STATS will    "
say "            produce a dataset too wide to be printed:                     "
say "                        ((8x17) + 2 = 138);                               "
say "                                                                          "
say "            If the number of datasets exceeds 11, only a COMPACT list will"
say "            be printable:                                                 "
say "                        ((12x11) + 2 = 134);                              "
say "                                                                          "
say "            If the number exceeds 39, a printable list cannot be produced:"
say "                        ((40x3) + 16 = 136).                              "
say "                                                                          "
say "            In any case, if the number of partitioned datasets within a   "
say "            single DDName gets near 39, you have other more urgent        "
say "            problems.                                                     "
"NEWSTACK" ; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                             "
say "                                                                 "
say "        MONITOR:  displays key information throughout processing."
say "                  Displays most paragraph names upon entry.      "
say "                                                                 "
say "        NOUPDT:   by-pass all update logic.  (Not used by        "
say "                  "exec_name".)                                  "
say "                                                                 "
say "        BRANCH:   show all paragraph entries.                    "
say "                                                                 "
say "        TRACE tv: will use value following TRACE to place        "
say "                  the execution in REXX TRACE Mode.              "
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
/****** REXXSKEL back-end removed to save space.   *******/   
/*
)))PLIB GETLIBS
)ATTR
  % TYPE(TEXT)  INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)  INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT) INTENS(HIGH)
  " TYPE(TEXT)  COLOR(YELLOW) SKIP(ON)
  @ TYPE(TEXT)  INTENS(LOW)  COLOR(YELLOW) SKIP(ON)
  ! TYPE(INPUT) INTENS(HIGH) COLOR(PINK) CAPS(OFF) JUST(ASIS)
  $ TYPE(INPUT) INTENS(HIGH) CAPS(ON)  JUST(ASIS)
  # TYPE(TEXT)  INTENS(HIGH) SKIP(ON)
  � AREA(SCRL)  EXTEND(ON)
)BODY EXPAND(��)
@Unsupported �-� %Member Cross-Reference@ �-�
%COMMAND ===>_ZCMD

+   Output DSN ===>$OUTDSN
+  Page Length ===>$LPP+ (lines)
+    Headers ? ===>$Z+   (Y or N)
+
+      Specify input#DDNAME+===>$DDN     +
+  #or+enter/verify dataset names below:
�dslist                                                                        �
+
)AREA DSLIST
%===>$XRDSN1
%===>$XRDSN2
%===>$XRDSN3
%===>$XRDSN4
%===>$XRDSN5
%===>$XRDSN6
%===>$XRDSN7
%===>$XRDSN8
%===>$XRDSN9
%===>$XRDSN10
%===>$XRDSN11
%===>$XRDSN12
%===>$XRDSN13
%===>$XRDSN14
%===>$XRDSN15
%===>$XRDSN16
%===>$XRDSN17
%===>$XRDSN18
%===>$XRDSN19
%===>$XRDSN20
%===>$XRDSN21
%===>$XRDSN22
%===>$XRDSN23
%===>$XRDSN24
%===>$XRDSN25
%===>$XRDSN26
%===>$XRDSN27
%===>$XRDSN28
%===>$XRDSN29
%===>$XRDSN30
)INIT
 .ZVARS = '(HDR)'
 &ZCMD = &Z
 .HELP = XREFH
)PROC
 VER(&XRDSN1,DSNAME)
 VER(&XRDSN2,DSNAME)
 VER(&XRDSN3,DSNAME)
 VER(&XRDSN4,DSNAME)
 VER(&XRDSN5,DSNAME)
 VER(&XRDSN6,DSNAME)
 VER(&XRDSN7,DSNAME)
 VER(&XRDSN8,DSNAME)
 VER(&XRDSN9,DSNAME)
 VER(&XRDSN10,DSNAME)
 VER(&XRDSN11,DSNAME)
 VER(&XRDSN12,DSNAME)
 VER(&XRDSN13,DSNAME)
 VER(&XRDSN14,DSNAME)
 VER(&XRDSN15,DSNAME)
 VER(&XRDSN16,DSNAME)
 VER(&XRDSN17,DSNAME)
 VER(&XRDSN18,DSNAME)
 VER(&XRDSN19,DSNAME)
 VER(&XRDSN20,DSNAME)
 VER(&XRDSN21,DSNAME)
 VER(&XRDSN22,DSNAME)
 VER(&XRDSN23,DSNAME)
 VER(&XRDSN24,DSNAME)
 VER(&XRDSN25,DSNAME)
 VER(&XRDSN26,DSNAME)
 VER(&XRDSN27,DSNAME)
 VER(&XRDSN28,DSNAME)
 VER(&XRDSN29,DSNAME)
 VER(&XRDSN30,DSNAME)
 VER(&DDN,NAME)
 VER(&LPP,NUM)
 VER(&OUTDSN,DSNAME)
 &HDRA = TRUNC(&HDR,1)
 VER(&HDRA,LIST,Y,N)
    &NOHDR = TRANS(&HDR N,NOHDR Y,HDR)
)END
)))PLIB XREFH
)ATTR
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
)BODY EXPAND(��)
%TUTORIAL �-� Member Cross-Reference �-� TUTORIAL
%Next Selection ===>_ZCMD

+
+    This panel allows easy entry and verification of most parameters such as
+    OUTDSN, Page Length, and whether or not header lines are to be produced.
+
+    If%ENTER+is pressed while DDNAME is blank, any DSNames shown will be used
+    as input to the process.  If DDNAME is changed, the DSNames matching that
+    DDName will be loaded to the panel before it is redisplayed.
+
+    Leave DDNAME blank and press ENTER when ready.
)PROC
)END
*/