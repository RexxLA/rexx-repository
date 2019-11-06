/* REXX    PLIXREF    adds statement number references to a PL/I
                      compiler listing.
 
           Written by Frank Clarke, Houston, 19981009
 
     Impact Analysis
.    SYSEXEC   SEGMENT
.    SYSEXEC   STRSORT
 
     Modification History
     19981019 fxc retry line replacement with additional quote-marks;
     19981202 fxc eliminate duplicate refs on same statement;
     20010302 fxc bypass INSOURCE
     20010302 fxc make NOLOG and NOLINK defaults
     20020812 fxc sort list of uninitialized variables
     20020830 fxc use OVERLAY for adding text to the ends; use Doug
                  Nadel's trick to avoid DATALINE;
     20030212 fxc refit for use as a 2nd-level macro
     20030630 fxc LINK is now the default
     20040118 fxc UNUSED set on permanently
 
*/ arg argline
address ISREDIT
"MACRO (opts)"
"RESET"
 
address ISPEXEC "CONTROL ERRORS RETURN"
address ISPEXEC "VGET DEBUG SHARED"
parse value debug "O" with tv .
call A_INIT                            /*                           -*/
$z = Trace("O"); $z = Trace(tv)        /* activate TRACE, maybe      */
 
call B_COLLECT_REFS                    /*                           -*/
 
call C_POST_LABELS                     /*                           -*/
call D_FINAL_REPORT                    /*                           -*/
if \sw.0SkipLog then,
   call ZB_SAVELOG                     /*                           -*/
 
exit                                   /*@ PLIXREF                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   address ISREDIT
 
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm,
                     as_invokt  cmd_env  addr_spc  usr_tokn
   parse value "" with,
         line_err_list  loc.  namelist  reflist.  uninitlist,
         msgnames ,
         helpmsg   stmtlist  .
   parse value "0" with,
         sw.   .
                                       /*                            */
   push opts; pull opts; opts = Strip(opts,"T",")")
   if opts = "?" then call HELP        /* ...and don't come back     */
   parse var opts "TRACE" tv .
   parse value tv "O" with tv .        /* guarantee a value          */
 
   sw.0DoUnused = 1
   sw.monitor   = Wordpos("MONITOR",opts) > 0
   sw.0SkipLOg  = Wordpos("LOG",opts)  = 0
   tk_globalvars = 'sw.'
   call AL_SETUP_LOG                   /*                           -*/
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AL_SETUP_LOG:                          /*@                           */
   address TSO
 
   parse value "0" with,
               log#    log.
   parse value Date("S")  Time("S")  Time("N")  with,
               yyyymmdd   sssss      hhmmss  .
   parse var yyyymmdd  4 yrdigit 5 mm 7                /* 9 12 maybe */
   if Pos(yrdigit,"13579") > 0 then mm = mm + 12       /* mm=24      */
   logtag = Substr("ABCDEFGHIJKLMNOPQRSTUVWX",mm,1)    /* logtag=X   */
   subid  = logtag""Right(yyyymmdd,2)Right(sssss,5,0)  /* X1423722 ? */
   vb4k.0    = "NEW CATALOG UNIT(SYSDA) SPACE(1) TRACKS",
               "RECFM(V B) LRECL(4096) BLKSIZE(0)"
   vb4k.1    = "SHR"                   /* if it already exists...    */
   logdsn = "@@LOG."exec_name"."subid".#CILIST"
 
   call ZL_LOGMSG("Log started by" Userid()  yyyymmdd  hhmmss)
 
return                                 /*@ AL_SETUP_LOG              */
/*
   Find the top and bottom bounds of the attribute and cross
   reference list.  Scan the Att/Xref for all ENTRY and all
   STATEMENT LABEL CONSTANT.  Collect the line-number references for
   each.
.  ----------------------------------------------------------------- */
B_COLLECT_REFS:                        /*@                           */
   address ISREDIT
 
   call BA_DELIMIT_SECTIONS            /*                           -*/
 
   call BB_FIND_ENTRIES                /*                           -*/
 
   call BC_FIND_LABELS                 /*                           -*/
                        if sw.0DoUnused then,
   call BD_FIND_UNUSED                 /*                           -*/
                        if sw.0DoUnused then,
   call BM_FIND_MSGS                   /*                           -*/
 
return                                 /*@ B_COLLECT_REFS            */
/*
   Set local label for .AZ (end  of Attr/Xref)
   Purge LinkEdit listing if necessary
   Set search columns in the Attr/Xref
.  ----------------------------------------------------------------- */
BA_DELIMIT_SECTIONS:                   /*@                           */
   address ISREDIT
 
   "SEGMENT"
   address ISPEXEC "VGET LBLLIST"      /* known labels               */
 
   pt = WordPos(".ATTR",lbllist)
   if pt = 0 then do
      zerrsm = "No cross-reference"
      zerrlm = "Could not find the .ATTR tag in LBLLIST."
      zerrhm = "ISR00001"
      address ISPEXEC "SETMSG MSG(ISRZ001)"
      exit
      end
 
   l#  = Word(lbllist,pt+3)            /* line# for next tag         */
   if l# = "" then do
      exit
      end                              /* nothing after attr/xref ?  */
   lastline   =  l#
   l# = l# - 1
   "LABEL" l# "= .AZ 0"
 
   if sw.0DropLink then do             /* lose the LKED listings     */
      "RESET"
      "X ALL .LINK .ZL"
      if rc = 0 then,
         "DELETE ALL X"
      end
 
   "F FIRST 'ATTRIBUTES AND REFERENCES'" /* start of xref section    */
   "(text) = LINE .zcsr"               /* save the line              */
   namecol = Pos("ATTRIBU",text)
   id_pt   = Pos("IDENTIF",text)
 
return                                 /*@ BA_DELIMIT_SECTIONS       */
/*
   Look for ENTRY items in the Attribute-and-Cross-Reference section.
.  ----------------------------------------------------------------- */
BB_FIND_ENTRIES:                       /*@                           */
   address ISREDIT
                                  bbtv = Trace()
   seq = "FIRST"
   do forever                          /* process all ENTRY          */
      "F WORD 'ENTRY' .ATTR .AZ" seq namecol
      if rc > 0 then leave             /* no more left               */
      seq = "NEXT"
      "(text) = LINE .zcsr"
      $z = Trace("O"); $z = Trace(bbtv)
      parse var text 2 stmt  entry .
      if loc.entry = "" then,          /* new name                   */
         namelist = namelist entry     /* add to list                */
      loc.entry = loc.entry stmt       /* The locn(s) of the label   */
      call ZL_LOGMSG("Found ENTRY" entry stmt)
      "(origl#) = LINENUM .zcsr" ; l# = origl#
 
      do forever                       /* find 'where-used'          */
         l# = l# + 1                   /* next line                  */
         "(text) = LINE" L#
 
         if Left(text,1) = "1" then iterate       /* page eject      */
         if Left(text,4) = "-DCL" then iterate    /* header          */
 
         if BDS_ITSA_STMTLINE() then nop; else leave
         stmtlist = Strip(Substr(text,namecol))
         reflist.stmt.entry = Space(reflist.stmt.entry stmtlist,1)
         call ZL_LOGMSG("    Used on" stmtlist)
      end                              /*  forever                   */
   end                                 /* forever                    */
 
return                                 /*@ BB_FIND_ENTRIES           */
/*
.  ----------------------------------------------------------------- */
BC_FIND_LABELS:                        /*@                           */
   address ISREDIT
                                  bctv = Trace()
   "L .ATTR"
   seq = "FIRST"
 
   do forever                          /* process all LABEL          */
      "F WORD 'STATEMENT LABEL CONSTANT' .ATTR .AZ" seq namecol+3
      if rc > 0 then leave             /* no more left               */
      seq = "NEXT"
      "(text) = LINE .zcsr"
      $z = Trace("O"); $z = Trace(bctv)
      parse var text 2 stmt  entry .
      if loc.entry = "" then,          /* new name                   */
         namelist = namelist entry     /* add to list                */
      loc.entry = loc.entry stmt       /* The locn(s) of the label   */
      call ZL_LOGMSG("Found LABEL" entry stmt)
      "(origl#) = LINENUM .zcsr" ; l# = origl#
 
      do forever                       /* find 'where-used'          */
         l# = l# + 1                   /* next line                  */
         "(text) = LINE" L#
 
         if Left(text,1) = "1" then iterate       /* page eject      */
         if Left(text,4) = "-DCL" then iterate    /* header          */
 
         if BDS_ITSA_STMTLINE() then nop; else leave
         stmtlist = Strip(Substr(text,namecol))
         reflist.stmt.entry = Space(reflist.stmt.entry stmtlist,1)
         call ZL_LOGMSG("    Used on" stmtlist)
      end                              /*  forever                   */
   end                                 /* forever                    */
 
return                                 /*@ BC_FIND_LABELS            */
/*
   Locate any unused variables in the Attribute List
.  A variable may be identified this way:  col.2-6 is the statement
   number of the declaration; col.7-12 is blank; the variable name
   starts in col.13; the attribute list starts in col.45.
.  If the attribute list contains 'AUTOMATIC' or 'STATIC', the item
   is a variable.
.  If the attribute list contains '615C40C9D5'X, the variable is
   declared in a structure.  Ignore these.
.  If the attribute list contains 'INITIAL', the first statement
   number in the list is the source of initialization.
.  ----------------------------------------------------------------- */
BD_FIND_UNUSED:                        /*@                           */
   address ISREDIT
                                  bdtv = Trace()
   "L .ATTR"
   seq = "FIRST"
 
   do forever                          /* process all LABEL          */
      "F  2  6  P'#' .ATTR .AZ" seq
      if rc > 0 then leave             /* no more left               */
      seq = "NEXT"
      "(line#,col#) = CURSOR"
      "CURSOR =" line# 11
      "(text) = LINE .zcsr"
      $z = Trace("O"); $z = Trace(bdtv)
      text = text                      /* show it for trace          */
      if BDV_ITSA_VARNLINE() then stmtlist = ""
                             else iterate
      if stmt = 1   then iterate       /* primary entry point        */
      if sw.0ignore then iterate       /* junk line                  */
      sw.0init = Wordpos("INITIAL",text) > 0
      sw.0stat = Wordpos("STATIC",text) > 0
      if sw.0stat then sw.0init = 0
      uninittext = Space(varn"("stmt")",0)
 
      loc.varn  = loc.varn  stmt       /* The statement DCL          */
      do forever                       /* find 'where-used'          */
         line# = line# + 1
         "CURSOR =" line# 1
         if line# > lastline then leave
         "(text) = LINE .zcsr"
         if BDV_ITSA_VARNLINE() then leave
         if BDS_ITSA_STMTLINE() then nop; else iterate
         stmtlist = Strip(data)
         stmtlist = Translate(stmtlist," ",",")
         leave                         /* not continued              */
      end                              /*  forever                   */
      if Words(stmtlist) > sw.0init then iterate     /* referenced   */
      if uninittext <> "" then,
         call ZL_LOGMSG(uninittext)
      uninitlist = uninitlist uninittext
   end                                 /* forever                    */
   call ZL_LOGMSG("Unused variables:" uninitlist)
 
return                                 /*@ BD_FIND_UNUSED            */
/*
.  ----------------------------------------------------------------- */
BDV_ITSA_VARNLINE:                     /*@                           */
   address TSO
 
   sw.0ignore = "0"
   parse var text 2 stmt  7 mustbeblank  13 varn  45 attlist
   if mustbeblank <> "" then return(0)
   if Words(stmt) <>  1 then return(0)
   if Words(varn) <>  1 then return(0)
                                    /* find slash-asterisk-blank-I-N */
   if Pos('615C40C9D5'X,attlist) > 0 then do /* element of structure */
      sw.0ignore = "1"                 /* ignore this variable       */
      return(1)                        /* it is a variable           */
      end
 
   if WordPos("STRUCTURE",attlist) > 0 then do
      sw.0ignore = "1"                 /* ignore this variable       */
      return(1)                        /* it is a variable           */
      end
 
   if WordPos("AUTOMATIC" ,attlist) +,
      WordPos("PARAMETER" ,attlist) +,
      WordPos("DEFINED"   ,attlist) +,
      WordPos("STATIC"    ,attlist) +,
      WordPos("BASED"     ,attlist) +,
      WordPos("ENTRY"     ,attlist) +,
      WordPos("CONTROLLED",attlist) = 0 then return(0)
 
   parse value varn stmt with  varn stmt .    /* Strip */
 
return(1)                              /*@ BDV_ITSA_VARNLINE         */
/*
.  ----------------------------------------------------------------- */
BDS_ITSA_STMTLINE:                     /*@                           */
   address TSO
 
   parse var text 2 mustbeblank =(namecol) data
   if mustbeblank <> '' then return(0)   /* continued line           */
   if Verify(data,"012345, 6789") > 0 then  /* not all numbers?      */
      return(0)
 
return(1)                              /*@ BDS_ITSA_STMTLINE         */
/*
   Locate all variables named MESS0... and post their usage to the
   declares.
.  ----------------------------------------------------------------- */
BM_FIND_MSGS:                          /*@                           */
   address ISREDIT
                                  bmtv = Trace()
   seq = "FIRST"                       /*                            */
   do forever                          /* process all ENTRY          */
      "F PREFIX 'MESS0' .ATTR .AZ" seq id_pt
      if rc > 0 then leave             /* no more left               */
      seq = "NEXT"
      "(text) = LINE .zcsr"
      $z = Trace("O"); $z = Trace(bmtv)
      parse var text 2 stmt  entry  attribs
      If Pos(entry"(",uninitlist) > 0 then iterate  /* unused        */
 
      msgnames = msgnames entry        /* add to list                */
      call ZL_LOGMSG("Found MSG" entry stmt)
      "(origl#) = LINENUM .zcsr" ; l# = origl#
 
      do forever                       /* find 'where-used'          */
         l# = l# + 1                   /* next line                  */
         "(text) = LINE" L#
 
         if Left(text,1) = "1" then iterate       /* page eject      */
         if Left(text,4) = "-DCL" then iterate    /* header          */
 
         if BDS_ITSA_STMTLINE() then nop; else leave
         stmtlist = Strip(Substr(text,namecol))
         reflist.stmt.entry = Space(reflist.stmt.entry stmtlist,1)
         call ZL_LOGMSG("    Used on" stmtlist)
      end                              /*  forever                   */
 
      reflist.stmt.entry = Translate(reflist.stmt.entry," ",",")
      if Pos("INITIAL",attribs) > 0 then,
         reflist.stmt.entry = Subword(reflist.stmt.entry,2)
 
   end                                 /* forever                    */
 
   /* All MESS0xxx variables have been located and mapped.           */
 
   do bmx = 1 to Words(msgnames)       /* every name                 */
      $z = Trace("O"); $z = Trace(bmtv)
      thiswd = Word(msgnames,bmx)      /* isolate                    */
      do iz = 1 to Words(loc.thiswd)   /* each DCL location          */
         stmt# = Word(loc.thiswd,iz)   /* isolate                    */
         "F FIRST '" stmt# "' 2 10 .SRC .ATTR" /* go to that DCL     */
         if rc > 0 then iterate
         "(line#,col#) = CURSOR"       /* where are we ?             */
         "LABEL .zcsr = .CA "
         slug = Translate(reflist.stmt#.thiswd," ",",")
         if slug = "" then leave
         do Words(slug)                /* eliminate duplicates       */
            parse var slug   stmt slug
            if WordPos(stmt,slug) > 0 then,   /* duplicate           */
               iterate
            slug   = slug stmt         /* unique, attach at end      */
         end                           /* words(slug)                */
         $z = Trace("O"); $z = Trace(bmtv)
         reflist.stmt#.thiswd = slug
         slug                 = "Used:" slug
         call ZL_LOGMSG("Posting usedstring for" thiswd,
                "at" line#":" slug)
 
         "(text) = LINE" line#         /* acquire the text           */
         tailend  = Substr(text,90)
         taillen  = Length(tailend)
 
         if Length(slug) > taillen then, /* won't fit on the line    */
            call CZ_POST_LONG_SLUG     /*                           -*/
 
         slug = Overlay(slug," ",90)
         "LINE_AFTER" line# "= (slug)"
      end                              /* iz                         */
   end                                 /* bmx                        */
 
return                                 /*@ BM_FIND_MSGS              */
/*
   For each ENTRY or LABEL found in the XREF, find the line where it
   appears and post there the list of line numbers where it is
   referenced (either by CALL or by GOTO).
.  ----------------------------------------------------------------- */
C_POST_LABELS:                         /*@                           */
   address ISREDIT
                                   ctv = Trace()
 
   do ix = 1 to Words(namelist)        /* every label or entry       */
      $z = Trace("O"); $z = Trace(ctv)
      thiswd = Word(namelist,ix)       /* isolate                    */
      do iz = 1 to Words(loc.thiswd)   /* each DCL location          */
         stmt# = Word(loc.thiswd,iz)   /* isolate                    */
         "F FIRST '" stmt# "' 2 10 .SRC .ATTR" /* go to that statement */
         if rc > 0 then iterate
         "(line#,col#) = CURSOR"       /* where are we ?             */
         "LABEL .zcsr = .CA "
         slug = Translate(reflist.stmt#.thiswd," ",",")
         if slug = "" then leave
         do Words(slug)                /* eliminate duplicates       */
            parse var slug   stmt slug
            if WordPos(stmt,slug) > 0 then,   /* duplicate           */
               iterate
            slug   = slug stmt         /* unique, attach at end      */
         end                           /* words(slug)                */
         $z = Trace("O"); $z = Trace(ctv)
         reflist.stmt#.thiswd = Space(slug,1)
         slug                 = "From:" Space(slug,1)
         call ZL_LOGMSG("Posting fromstring for" thiswd,
                "at" line#":" slug)
 
         "(text) = LINE" line#         /* acquire the text           */
         tailend  = Substr(text,90)
         taillen  = Length(tailend)
 
         if Length(slug) > taillen then, /* won't fit on the line    */
            call CZ_POST_LONG_SLUG     /*                           -*/
 
         slug = Overlay(slug,text,90)
         "LINE .CA = (slug)"
 
         call CA_MARK_REFS             /* annotate the 'from' lines -*/
      end                              /* iz                         */
   end                                 /* ix                         */
 
return                                 /*@ C_POST_LABELS             */
/*
   The label-line has been marked to indicate all the places it is
   called from.  Find each of those lines and indicate on each the
   line number of the ENTRY or LABEL it CALLs or GOes TO.
.  ----------------------------------------------------------------- */
CA_MARK_REFS:                          /*@                           */
   address ISREDIT
 
   fromslug = ""
   do cx = 1 to Words(reflist.stmt#.thiswd)    /* each call/goto     */
      call# = Word(reflist.stmt#.thiswd,cx)    /* isolate            */
      "F FIRST '" call# "' 2 10 .SRC .ATTR" /* a call/goto statement */
      if rc > 0 then iterate
      "LABEL .zcsr = .CZ "
      "(callline,callcol) = CURSOR"
 
                /* the call or goto may not be on exactly this line  */
      "(text) = LINE .zcsr"            /* acquire the text           */
      if Pos(thiswd,text) = 0 then,
         "F NEXT" thiswd               /* find where it appears      */
      if rc > 0 then "L .CZ"           /* back to the statement line */
 
      "LABEL .zcsr = .CA "
      atslug = " At:" stmt#
      call ZL_LOGMSG("Posting atstring for" thiswd,
                "at" callline":" atslug)
 
      "(text) = LINE .zcsr"            /* acquire the text           */
      tailend  = Substr(text,90)
      taillen  = Length(tailend)
 
      if WordPos("From:",tailend) > 0 then,
         fromslug = tailend            /* save existing reference    */
 
      text   = Overlay(atslug"    ",text,90)
      "LINE .CA  = (text)"
 
      if rc > 0 then do
         if Wordpos(call#,line_err_list) = 0 then,
            line_err_list = line_err_list call#
         end
 
      if fromslug <> "" then do
         fromslug = Overlay(fromslug," ",90)
         "LINE_AFTER .CA = (fromslug)"
         fromslug = ""
         end
   end                                 /* cx                         */
 
return                                 /*@ CA_MARK_REFS              */
/*
   The list of line number references is too long to fit on the
   line.  Break it up into several smaller pieces and insert each on
   its own line.
.  ----------------------------------------------------------------- */
CZ_POST_LONG_SLUG:                     /*@                           */
   address ISREDIT
 
   address TSO "NEWSTACK"
 
   worklen  = taillen
   shortlen = taillen - 6              /* count missing 'From: '     */
 
   do while Length(slug) > worklen
      pq = Lastpos(" " , slug , worklen)
      pqtext = Substr(slug,1,pq)
      push pqtext
      slug = Substr(slug,pq+1)
      worklen = shortlen            /* every line but first is short */
   end
 
/* everything but the current slug is on the queue in reverse order  */
 
   do queued()                         /* all except the last        */
      slug = Overlay(Strip(slug)," ",96)
      "LINE_AFTER" line# "= (slug)"
      parse pull slug
   end                                 /* queued                     */
 
   address TSO "DELSTACK"
   /* the remaining line containing the 'From:' is stored in <slug>
      and will be handled normally on return */
 
return                                 /*@ CZ_POST_LONG_SLUG         */
/*
.  ----------------------------------------------------------------- */
D_FINAL_REPORT:                        /*@                           */
   address ISREDIT
 
   "F IEL0916I .AZ   .ZL"              /* uninitialized variables    */
   if rc = 0 then do
      call DA_REARRANGE                /*                           -*/
      end                              /* uninitialized variables    */
 
   "CURSOR = 1 1"
   if uninitlist <> "" then do
      do while Length(uninitlist) > 70
         bp = Lastpos(" ",uninitlist,70)
         slug = Left(uninitlist,bp)
         uninitlist = DelStr(uninitlist,1,bp)
         push  "    "Space(slug,1)
      end
      push     "    "Space(uninitlist,1)
      queue "  The following data elements appear to be unused:"
 
      do queued()
         parse pull msg
         "LINE_AFTER 1 = (msg)"
      end
      end                              /* uninitlist                 */
 
   if line_err_list <> "" then do
      msg = " Check these statements:" line_err_list
      "LINE_AFTER 1 = (msg)"
      end
 
   msg = " This PL/I compiler listing was processed by PLIXREF",
         "on" Date("N") "at" Time("C")
   "LINE_AFTER 1 = (msg)"
 
return                                 /*@ D_FINAL_REPORT            */
/*
.  ----------------------------------------------------------------- */
DA_REARRANGE:                          /*@                           */
   address ISREDIT
 
   "(text) = LINE .zcsr"
   "LABEL .zcsr = .UVB"
   "(l916#) = LINENUM .zcsr"
   parse var text 2 . . . slug
   varstr = Strip(slug)                /* first line                 */
   do forever
      l916# = l916# + 1                /* next line                  */
      "(text) = LINE" l916#
      if Left(text,1) = "1" then iterate
      if Left(text,4) = "-COM" then iterate
      parse var text 2 slug
      varstr = varstr""Strip(slug)
      if Right(varstr,1) = "." then leave
   end                                 /* forever                    */
   "LABEL" l916# "= .UVE"
   pt = Lastpos("MAY",varstr)
   parse var varstr "ITEM(S)" items =(pt)
   items = Translate(items , "  " , "'," )
   items = STRSORT(items)
 
   "F IEL0916I .AZ   .ZL"              /* uninitialized variables    */
   "(text) = LINE .zcsr"
   parse var text front "'"            /* clip at first quote        */
   pt = Pos("ITEM",front)              /* alignment point            */
   text = front
   do while items <> ""
      parse var items  item items      /* isolate one                */
      if Length(text item",") > 121 then do
         "LINE_BEFORE .UVB = (text)"
         text = ""
         text = Overlay(item",",text,pt)
         end                           /* end of line                */
      else,
         text = text item","
   end                                 /* items                      */
 
   back = "MAY BE UNINITIALIZED WHEN USED IN THIS BLOCK."
   if Length(text back) > 121 then do
      "LINE_BEFORE .UVB = (text)"
      text = ""
      text = Overlay(back,text,pt)
      end
   else,
      text = text back
   "LINE_BEFORE .UVB = (text)"
   "DEL ALL .UVB .UVE"
 
return                                 /*@ DA_REARRANGE              */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
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
   $z = Trace("O")
   address TSO
 
   parse arg msgtext
   parse value  log#+1  msgtext     with,
                zz      log.zz    1  log#   .
   if sw.monitor then say msgtext
 
return                                 /*@ ZL_LOGMSG                 */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
parse source  sys_id  how_invokt  exec_name  .
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      examines a PL/1 compiler listing for labels, GOTOs and    "
say "                calls.  The lines containing labels are then annotated    "
say "                with the statement numbers of their corresponding GOTOs   "
say "                and CALLs.  The GOTOs and CALLs are annotated to show the "
say "                statement number of the ENTRY label they reference.       "
say "                                                                          "
say "  Syntax:   "ex_nam"  <LOG>                                               "
say "                      <LINK>                                              "
say "                      <UNUSED>                                            "
say "                                                                          "
say "            <LOG>     requests that an external log of activity be kept   "
say "                      for this execution.  This is useful for debugging.  "
say "                                                                          "
say "            <LINK>    requests that the LinkEdit listing be kept.  The    "
say "                      default is to delete it.                            "
say "                                                                          "
say "            <UNUSED>  requests that unused variables be specially listed. "
say "                                                                          "
"NEWSTACK"; pull; "CLEAR"; "DELSTACK"
say "                                                                          "
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the execution in"
say "                  REXX TRACE Mode.                                        "
say "                                                                          "
say "                                                                          "
say "   Debugging tools can be accessed in the following manner:               "
say "                                                                          "
say "        TSO" ex_nam "    parameters  ((  debug-options                    "
say "                                                                          "
say "   For example:                                                           "
say "                                                                          "
say "        TSO" ex_nam " (( TRACE ?R                                         "
 
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
