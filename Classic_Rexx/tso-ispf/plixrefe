/* REXX    PLIXREFE   adds statement number references to a PL/I
                      (Enterprise) compiler listing.
 
           Written by Frank Clarke, Houston, 19981009
 
     Impact Analysis
.    SYSEXEC   SEGMENT
.    SYSEXEC   SHORTPG
.    SYSEXEC   STRSORT
.    SYSEXEC   TRAPOUT
 
     Modification History
     200302xx fxc rewrite for Enterprise PL/I compiler format
     20030630 fxc default to LINK
     20040315 fxc unused-list only if requested
     20050110 fxc Impact Analysis;
     20050131 fxc handle multiple CALLS-per-line;
 
*/ arg parms
address ISREDIT                        /* REXXSKEL ver.20040227      */
"MACRO (opts)"
"RESET"
upper opts
address ISPEXEC "CONTROL ERRORS RETURN"
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
 
call A_INIT                            /*                           -*/
 
call B_COLLECT_REFS                    /*                           -*/
 
call C_POST_LABELS                     /*                           -*/
call D_FINAL_REPORT                    /*                           -*/
if \sw.0SkipLog then,
   call ZB_SAVELOG                     /*                           -*/
 
exit                                   /*@ PLIXREFE                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   address ISREDIT
 
   "SHORTPG"                           /* clip blank lines           */
 
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm,
                     as_invokt  cmd_env  addr_spc  usr_tokn
   parse value "" with,
         line_err_list  loc.  namelist  reflist.  unreflist ,
         msgnames ,
         helpmsg   stmtlist  .
   parse value "0" with,
         sw.   .
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
 
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
            "Log started by" Userid()  yyyymmdd  hhmmss )
 
   opts = Strip(opts,"T",")")
   if opts = "?" then call HELP        /* ...and don't come back     */
   parse var opts "TRACE" tv .
   parse value tv "O" with tv .        /* guarantee a value          */
 
/* sw.0DropLink = Wordpos("LINK",opts) = 0 */
   sw.0DoUnused = Wordpos("UNUSED",opts) > 0
   sw.0SkipLOg  = Wordpos("LOG",opts)  = 0
   msgloc = 105                        /* start of sequence fld      */
 
return                                 /*@ A_INIT                    */
/*
   Find the top and bottom bounds of the attribute and cross
   reference list.  Scan the Att/Xref for all ENTRY and LABEL.
   Collect the line-number references for each.
.  ----------------------------------------------------------------- */
B_COLLECT_REFS:                        /*@                           */
   address TSO
 
   call BA_DELIMIT_SECTIONS            /*                           -*/
        "NEWSTACK"
   call BB_FIND_ENTRIES                /*                           -*/
        "DELSTACK"
 
return                                 /*@ B_COLLECT_REFS            */
/*
.  ----------------------------------------------------------------- */
BA_DELIMIT_SECTIONS:                   /*@                           */
   address ISREDIT
 
   "SEGMENT"
   address ISPEXEC "VGET LBLLIST SHARED"
   parse var lbllist . ".SRC" src_bgn     lbllist
   parse var lbllist  tag line# .
   src_end = line# - 1                 /* previous line              */
 
   parse var lbllist . ".ATTR" att_bgn     lbllist
   parse var lbllist  tag line# .
   att_end = line# - 1                 /* previous line              */
 
   "CURSOR = " att_bgn
   "F 'Identifier'"
   "(text) = LINE .zcsr"               /* seize the line             */
   id_pt   = Pos("Identifier",text)-1  /* column the name starts in  */
   namecol = Pos("Attributes",text)-1  /* attribute location         */
 
return                                 /*@ BA_DELIMIT_SECTIONS       */
/*
.  ----------------------------------------------------------------- */
BB_FIND_ENTRIES:                       /*@                           */
   address ISREDIT
                                  bbtv = Trace()
   slug = ""
                /* Put each variable's attributes on a single line   */
   do bx = att_bgn to att_end          /* scan the attrlist          */
      "(text) = LINE" bx
      parse var text 2 text            /* strip ASA                  */
      if text = "" then iterate
      if Pos(Left(Strip(text),5),"5655- State") > 0 then iterate
 
      parse var text  stmt =(id_pt) entry =(namecol) attribs
      if stmt  <> "" then do           /* new variable               */
         if slug <> "" then queue slug
         slug = Strip(text,"T"," ")    /* strip trailing             */
         end
      else do                          /* continuation               */
         slug = slug Strip(attribs)
         end
   end                                 /* bx                         */
   if slug <> "" then queue slug
                /* The queue contains one line for each item in the
                   Attribute/Xref list                               */
   do queued()                         /* reprocess the queue        */
      pull line                        /* get data                   */
      call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
               Strip(line) )
      parse var line   stmt entry attribs
 
      sw.0label = WordPos("LABEL",attribs)  > 0
      sw.0entry = WordPos("ENTRY",attribs)  > 0 | ,
                      Pos("ENTRY(",attribs) > 0
      if sw.0label + sw.0entry <> 1 then iterate
 
      stmt = Strip(stmt)               /* remove blanks    v.58      */
      entry = Strip(entry)             /*                            */
      if loc.entry = "" then,
         namelist = namelist entry     /* add to namelist            */
      loc.entry = loc.entry stmt       /* where declared             */
      if sw.0entry then,
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
              "Found ENTRY" entry stmt)
      else,
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
              "Found LABEL" entry stmt)
      parse var line "REFS:" stmtlist "SETS:"
      reflist.stmt.entry = Space(stmtlist,1)
   end                                 /* queued                     */
   /* The queue is now empty                                         */
 
return                                 /*@ BB_FIND_ENTRIES           */
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
         if stmt# = 1 then iterate     /* PROC OPTIONS(MAIN)         */
         "F FIRST '" stmt# "' 17 25 .SRC .ATTR"
         if rc > 0 then iterate
         "(line#,col#) = CURSOR"       /* where are we ?             */
         "LABEL .zcsr = .CA "
         slug = Translate(reflist.stmt#.thiswd," ",",")
         if slug = "" then do          /* unreferenced               */
            unreflist = unreflist thiswd"("stmt#")"
            iterate ix
            end                        /* unreferenced               */
         do Words(slug)                /* eliminate duplicates       */
            parse var slug   stmt slug
            if WordPos(stmt,slug) > 0 then,   /* duplicate           */
               iterate
            slug   = slug stmt         /* unique, attach at end      */
         end                           /* words(slug)                */
         $z = Trace("O"); $z = Trace(ctv)
         reflist.stmt#.thiswd = Space(slug,1)
         slug                 = "From:" Space(slug,1)
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                "Posting fromstring for" thiswd,
                "at" line#":" slug)
 
         "(text) = LINE" line#         /* acquire the text           */
         tailend  = Substr(text,msgloc)
         taillen  = Length(tailend)
 
         if Length(slug) > taillen then, /* won't fit on the line    */
            call CZ_POST_LONG_SLUG     /*                           -*/
 
         slug = Overlay(slug,text,msgloc)
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
      "F FIRST '" call# "' 17 25 .SRC .ATTR"  /* call/goto statement */
      if rc > 0 then call CL_LOCATE_MISSING_STMT  /*                -*/
      "LABEL .zcsr = .CZ "
      "(callline,callcol) = CURSOR"
 
                /* the call or goto may not be on exactly this line  */
      "(text) = LINE .zcsr"            /* acquire the text           */
      if Pos(thiswd,text) = 0 then,
         "F NEXT" thiswd               /* find where it appears      */
      if rc > 0 then "L .CZ"           /* back to the statement line */
 
      "LABEL .zcsr = .CA "
      atslug = " At:" stmt#
      call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                "Posting atstring for" thiswd,
                "at" callline":" atslug)
 
      "(text) = LINE .zcsr"            /* acquire the text           */
      tailend  = Substr(text,msgloc)
      taillen  = Length(tailend)
 
      if WordPos("At:"  ,tailend) > 0 |,
         WordPos("From:",tailend) > 0 then,
         fromslug = tailend            /* save existing reference    */
 
      text   = Overlay(atslug"    ",text,msgloc)
      "LINE .CA  = (text)"
 
      if rc > 0 then do
         if Wordpos(call#,line_err_list) = 0 then,
            line_err_list = line_err_list call#
         end
 
      if fromslug <> "" then do
         fromslug = Overlay(fromslug," ",msgloc)
         "LINE_AFTER .CA = (fromslug)"
         fromslug = ""
         end
   end                                 /* cx                         */
 
return                                 /*@ CA_MARK_REFS              */
/*
   The statement number being sought is not in the listing.  Probably
   there is more than one CALL on the line and thus more than one
   statement-number has been assigned to a single line.  Decrement
   "call#" until that line number is found.
.  ----------------------------------------------------------------- */
CL_LOCATE_MISSING_STMT:                /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   do clz = call# to 1 by -1
      "F FIRST '" clz "' 17 25 .SRC .ATTR"
      if rc = 0 then leave             /* found it                   */
   end                                 /* clz                        */
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
        "Statement" call# "repositioned to" clz)
 
return                                 /*@ CL_LOCATE_MISSING_STMT    */
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
 
   do while Length(slug) > worklen           /* 82 > 28 maybe        */
      pq = Lastpos(" " , slug , worklen)     /* 26 maybe             */
      pqtext = Substr(slug,1,pq)
      push pqtext
      slug = Substr(slug,pq+1)               /* sluglen now 55       */
      worklen = shortlen            /* every line but first is short */
   end
 
/* everything but the current slug is on the queue in reverse order  */
 
   do queued()                         /* all except the last        */
      slug = Overlay(Strip(slug)," ",msgloc+6)
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
 
   "F IEL0916I .DIAG .ZL"              /* uninitialized variables    */
   if rc = 0 then do
      call DA_REARRANGE                /*                           -*/
      end                              /* uninitialized variables    */
 
   "CURSOR = 1 1"
 
   if line_err_list <> "" then do
      msg = " Check these statements:" line_err_list
      "LINE_AFTER 1 = (msg)"
      end
 
   if sw.0DoUnused then,
   if unreflist <> "" then do
      do while Length(unreflist) > 70
         bp        = Lastpos(" ",unreflist,70)
         slug      = Left(unreflist,bp)
         unreflist = DelStr(unreflist,1,bp)
         push  "    "Space(slug,1)
      end
      push     "    "Space(unreflist,1)
      queue "  The following data elements appear to be unused:"
 
      do queued()
         parse pull msg
         "LINE_AFTER 1 = (msg)"
      end
      end                              /* unreflist                  */
 
   msg = " This PL/I compiler listing was processed by PLIXREF",
         "on" Date("N") "at" Time("C")
   "LINE_AFTER 1 = (msg)"
 
return                                 /*@ D_FINAL_REPORT            */
/*
   Make sure the text for IEL0916I is not split in the middle of a
   variable name.
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
 
   "F IEL0916I .DIAG .ZL"              /* uninitialized variables    */
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
/* ------------- REXXSKEL back-end removed for space --------------- */
