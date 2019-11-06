/* REXX    PLIPOS      Annotate a PL/I declare with the start- and
                       end-positions for each field.
*/
address ISREDIT                        /* REXXSKEL ver.20021008      */
"MACRO (opts)"
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
 
address ISPEXEC "CONTROL ERRORS RETURN"
if sw.0Rpt then call ZA_SETUP_LOG   /*                            */
call A_INIT                            /*                           -*/
call B_FIND_FIRST                      /*                           -*/
                                    if sw.0error_found then return
call C_DO_ELEMENT                      /*                           -*/
                                    if sw.0error_found then exit
call D_ROLL_UP                         /*                           -*/
if sw.0Rpt = 0 then,                   /*                            */
   call E_ANNOTATE                     /*                           -*/
else,                                  /*                            */
   call F_ANALYZE                      /*                           -*/
 
exit                                   /*@ PARSEDCL                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value "1 1 1 1 1 1 1 1 1 1 1 1 1 "  with,
                start  ,
                .
   parse value " 0 0 0 0 0 0 0 0 0"  with,
                fillseq  ,
                .
 
   parse value ""  with,
               elemdata. ,             /* declared name/type/len     */
               delim_q ,               /*                            */
               parent.  ,              /*                            */
               parent_id  ,            /*                            */
               parent_name,            /*                            */
               spec ,                  /* data for ELEMLEN           */
               text ,                  /* workarea                   */
               .
 
   parse var info source .
   group_list  = "BASE"                /* fq name list               */
   parent_q    = "1"                   /* lvl # in DCL               */
   elemdata.BASE = "BASE"
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_FIND_FIRST:                          /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   line# = 0
   slug = ''
   do forever
      line# = line# + 1                /* next line                  */
      "(text) = LINE" line#            /* acquire text               */
      if rc > 0 then leave
 
      parse var text 2 text 73
      slug = Space(slug text,1)
 
      do while Left(slug,2) = '615C'x  /* slash-asterisk             */
         ptb = Pos('5C61'x,slug)       /* asterisk-slash             */
         if ptb = 0 then leave         /* no comment-end             */
         else do
            slug = Delstr(slug,1,ptb+1)    /* snip                   */
            slug = Strip(slug)
            end
      end                              /* while comment-start        */
      if slug <> "" then,              /* non-empty                  */
      if Left(slug,2) <> '615C'x then leave    /* non-comment        */
 
   end                                 /* forever                    */
 
   if rc > 0 then do
      sw.0error_found = 1
      zerrsm = "No text"
      zerrlm = "No PL/I declare found in text."
      address ISPEXEC "SETMSG MSG(ISRZ002)"
      return
      end
 
   first_line = line#
   line# = line# - 1
   text = ""
 
return                                 /*@ B_FIND_FIRST              */
/*
   Isolate each "line" of the DCL and pass to ELEMLEN.
   A "line" may span lines or be fragmentary.
.  ----------------------------------------------------------------- */
C_DO_ELEMENT:                          /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   "RENUM"
   "UNNUM"
   do forever                          /* re-evaluate every time     */
      line# = line# + 1
      "(line) = LINE" line#
      if rc > 0 then leave
 
      parse var line 2 line 73
      text = Strip(text) Strip(line)
      if Word(text,1) = "DCL" then
         text = Delword(text,1,1)      /* snip                       */
 
      call CA_ISOLATE_STMT             /*                           -*/
      if sw.0Error_Found then leave
 
   end                                 /* forever                    */
 
return                                 /*@ C_DO_ELEMENT              */
/*
   Find a comma or semicolon at the end of the statement.  Isolate
   this fragment of text and pass it to ELEMLEN.
.  ----------------------------------------------------------------- */
CA_ISOLATE_STMT:                       /*@                           */
   ca_tv = trace()                     /* what setting at entry ?    */
   if branch then call BRANCH
   address ISREDIT
 
   pt = 0                              /* pointer                    */
                               if \sw.0Diag then rc = Trace("O")
   do forever
      if pt >= Length(text) then do    /* end of our rope            */
         line# = line# + 1
         "(line) = LINE" line#
         if rc > 0 then sw.0boom=1
         if sw.0boom then leave
 
         parse var line 2 line 73
         pt = length(text)
         text = text Strip(line)
         end                           /* end of text and no comma   */
      pt = pt + 1                      /* advance pointer            */
      char = Substr(text,pt,1)         /* isolate this character     */
 
      if Pos(char,",;()'/") = 0 then iterate
 
      if Pos(char,",;") > 0 then,
         if delim_q = "" then leave
 
      if char = "'" then ,
         if Word(delim_q,1) = "'" then,
            parse var delim_q . delim_q           /* remove match    */
            else      delim_q = char delim_q
 
      if char = "(" then delim_q = char delim_q ; else,
      if char = ")" then ,
         if Word(delim_q,1) = "(" then,
            parse var delim_q . delim_q           /* remove match    */
 
      if char = "/" then,              /* start of comment?          */
      if Substr(text,pt,2) = "615C"x then do /* slash-asterisk */
         pt2 = Pos('5C61'x,text)       /* asterisk-slash             */
         do while pt2 = 0              /* find the end               */
            line# = line# + 1
            "(line) = LINE" line#
            if rc > 0 then sw.0boom=1
            if sw.0boom then leave
 
            parse var line 2 line 73
            text = text Strip(line)
            pt2 = Pos('5C61'x,text)    /* asterisk-slash             */
         end                           /* while                      */
         if sw.0boom then leave
         text = Delstr(text,pt,pt2-pt+2)
         end                           /* it was a comment           */
 
   end                                 /* forever                    */
 
   if sw.0boom then do
      address TSO "CLEAR"
      say "Premature end-of-text"
      sw.0error_found = '1'
      return
      end
                                     rc = Trace("O")
                                     rc = trace(ca_tv)
   parse var text         spec =(pt) . +1  text
   if Word(spec,1) = "DCL" then        /* stacked DCL                */
      spec = DelWord(spec,1,1)         /* snip DCL                   */
 
   address TSO
   "NEWSTACK"
   "ELEMLEN" spec                      /* 3 zork dec fixed(5)       -*/
   pull ans                            /* response from ELEMLEN      */
   if sw.0Rpt then,
      call ZL_LOGMSG(ans)
   if WordPos("INDET",ans) > 0 then do /* Oops....                   */
      sw.0Error_Found = 1
      say ans
      say "Unable to calculate storage length"
      return
      end                              /* Indeterminate value        */
   call CAA_ANALYZE_RESPONSE ans       /*                           -*/
   "DELSTACK"
 
return                                 /*@ CA_ISOLATE_STMT           */
/*
   What did ELEMLEN say?  What level is this element at?  Group or
   data?  How long?  How deep?
   The response from ELEMLEN contains these elements:
        #  name  {varies}  Length ##  Depth ##  Total ##
                  -or-
        #  name  {varies}  Group of ##
                  -or-
        #  name  {varies}  Align on aaa
                  -or-
        #  name  {varies}  Pointer aligned
   In particular, {name} may contain parentheses if it is an array,
   or the arrayspec might be part of {varies}.  In either case, the
   "Depth" value or the "Group" value is equivalent to any arrayspec
   present.
 
   The "key" of all this data must be the fully-qualified name of any
   element or group to guard against a duplicate element-name in
   different sub-structures.
.  ----------------------------------------------------------------- */
CAA_ANALYZE_RESPONSE:                  /*@                           */
   if branch then call BRANCH
   address TSO
 
   arg info                            /* response from ELEMLEN      */
   parse var info        level name rest
   if Datatype(level,"W") = 0 then return
 
   if Pos("(",name) > 0 then do        /* separate arrayspec         */
      parse var name name "(" other
      rest = "("other rest
      end                              /* separate arrayspec         */
 
   if level = "1" then do              /* stacked DCL                */
      call D_ROLL_UP                   /*                           -*/
      call E_ANNOTATE                  /*                           -*/
      call A_INIT                      /*                           -*/
      end                              /* stacked DCL                */
 
   if name = "FILLER" then do
      fillseq = fillseq + 1
      name = name"{"Right(fillseq,3,0)
      end
 
   wdpt = 0
   do Words(parent_q)                  /* all prior parent levels    */
      wdpt = wdpt + 1                  /* index                      */
      parent_lvl = Word(parent_q,wdpt) /* isolate                    */
      if level > parent_lvl then do
         parent_name = Word(group_list,wdpt)
         leave
         end
   end                                 /* parent_q                   */
   fq_name     = Strip(parent_name":"name , "L" , ":")
   group_list  = Space(fq_name group_list,1)
   parent_q    = Space(level  parent_q,1)
 
   if SWITCH("ALIGN") then do
      baseelem = KEYWD("ON")           /* ON ZORK.FURBLE             */
      baseelem = Translate(baseelem,":",".")
      altkey   = "BASE:"baseelem
      start    = Max(start.baseelem,start.altkey)
      end                              /* ALIGN                      */
   else,
   if SWITCH("ALIGNED") then do
      $x = SWITCH("POINTER")
      start = 1
      end                              /* POINTER                    */
   else,
   if SWITCH("GROUP") then,
      depth.fq_name = KEYWD("OF")      /* GROUP OF ##                */
   else do
      depth.fq_name  = KEYWD("DEPTH")
      length.fq_name = KEYWD("LENGTH")
      totlen.fq_name = KEYWD("TOTAL")
      end
 
   elemdata.fq_name = info
   start.fq_name    = start
   start            = start + totlen.fq_name     /* may be zero      */
   end.fq_name      = start - 1
 
return                                 /*@ CAA_ANALYZE_RESPONSE      */
/*
   All rows have been analyzed.  Begin at the bottom and work up,
   accumulating lengths and annotating non-data group items.
.  ----------------------------------------------------------------- */
D_ROLL_UP:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   if Subword(Reverse(parent_q), 1, 2) = "1 1" then do
      revtext    = Reverse(parent_q)
      revtext    = Delword(revtext,1,1)  /* snip one word            */
      parent_q   = Reverse(revtext)      /* restore                  */
      revtext    = Reverse(group_list)
      revtext    = Delword(revtext,1,1)  /* snip one word            */
      group_list = Reverse(revtext)      /* restore                  */
      if sw.0Rpt then,
         call ZL_LOGMSG("Snipped BASE")
      end
 
   do dx = 1 to Words(group_list)
      fq_name = Word(group_list,dx)    /* isolate                    */
      eff_lvl = Words(Translate(fq_name,' ',':'))
      efflvl.fq_name = eff_lvl
      if length.fq_name = 0 then do    /* group                      */
         low_lvl = eff_lvl + 1         /* next deeper                */
         length.fq_name = length.low_lvl        /* roll up           */
         totlen.fq_name = length.fq_name * depth.fq_name
         end.fq_name    = start.fq_name + totlen.fq_name - 1
         length.low_lvl = 0            /* reset                      */
         end
      length.eff_lvl = length.eff_lvl + totlen.fq_name
      if sw.0Rpt then,
         call ZL_LOGMSG("Strt="start.fq_name,
                        "Len="length.fq_name,
                        "Dpt="depth.fq_name,
                        "End="end.fq_name,
                        fq_name)
   end                                 /* dx                         */
 
   /* Last adjustment: we forced level-1 to be 'BASE'.  We may have
      removed that as the first action of this block... or we may
      not have removed it.  If it's still here, shave it off.        */
   if Word(group_list,Words(group_list)) = "BASE" then do
      ct = Words(group_list)
      group_list = Delword(group_list,ct,1)
      parent_q   = Delword(parent_q  ,ct,1)
      end                              /* BASE                       */
 
return                                 /*@ D_ROLL_UP                 */
/*
   From the top down, starting at presumed position 1, calculate
   end position as {start + length - 1}.  The start position is the
   most recent start position of the next superior level.
.  ----------------------------------------------------------------- */
E_ANNOTATE:                            /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   dcl_len = length.1                  /* overall length             */
   spotlen = Length(dcl_len)           /* number of digits           */
   if spotlen < 3 then sluglen = 9     /*st-en*/
   if spotlen = 3 then sluglen = 11    /*str-end*/
   if spotlen > 3 then sluglen = spotlen + 6 /* start */
   buflen = sluglen + 1
   buffer = Copies(" ",buflen)
 
   next_ln = first_line
 
   do ex = Words(group_list) to 1 by -1
      fq_name = Word(group_list,ex)    /* isolate                    */
      fq_brk  = Translate(fq_name,' ',':')
      elemnm  = Word(fq_brk,efflvl.fq_name)
      parse var elemnm elemnm "{"      /* snip off seq from FILLER   */
      call EA_LOCATE_LINE              /*                           -*/
      if sw.0endfile then leave
 
      if Pos(elemnm,text) > 0 then do
 
         call ES_SLUG                  /* Build the slug            -*/
         if Right(text,buflen) = "" then do
            pt = 73 - buflen
            text = Overlay(slug,text,pt)
            end
         else,
         if Substr(text,2,buflen) = "" then do
            text = Overlay(slug,text,2,buflen)
            end
 
         "LINE" next_ln "= (text)"
         next_ln = next_ln + 1
         end
   end                                 /* ex                         */
 
return                                 /*@ E_ANNOTATE                */
/*
.  Given: NEXT_LN, a pointer to a text line which may contain the
   element name.  If not, inch down until found.
.  ----------------------------------------------------------------- */
EA_LOCATE_LINE:                        /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   do forever
      "(text) = LINE" next_ln
      if rc > 0 then do
         sw.0endfile = 1
         return
         end
      parse var text text 73
      if Pos(elemnm,text) > 1 then,    /* found!                     */
         return
      else next_ln = next_ln + 1       /* next line                  */
   end                                 /* forever                    */
 
return                                 /*@ EA_LOCATE_LINE            */
/*
.  Given: SPOTLEN (2, 3, or more).  Build the slug.
.  ----------------------------------------------------------------- */
ES_SLUG:                               /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   select
      when spotlen < 3 then do
         slug = Right(start.fq_name,2,0)"-"Right(end.fq_name,2,0)
         slug = '615C'x""slug""'5C61'x
         end
      when spotlen = 3 then do
         slug = Right(start.fq_name,3,0)"-"Right(end.fq_name,3,0)
         slug = '615C'x""slug""'5C61'x
         end
      otherwise do
         slug = Right(start.fq_name,spotlen,0)
         slug = '615C'x slug '5C61'x
         end
   end                                 /* select                     */
 
return                                 /*@ ES_SLUG                   */
/*
.  ----------------------------------------------------------------- */
F_ANALYZE:                             /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   do ex = Words(group_list) to 1 by -1
      fq_name = Word(group_list,ex)    /* isolate                    */
      fq_brk  = Translate(fq_name,' ',':')
      elemnm  = Word(fq_brk,efflvl.fq_name)
 
      msg=Left( ,
          Copies(' ',2*eff_lvl)""elemdata.fq_name , 45),
          Left("L="totlen.fq_name,7) ,
          Left("St="start.fq_name,8) ,
          Left("End="start.fq_name + totlen.fq_name - 1,8)
      call ZL_LOGMSG(msg)              /*                           -*/
   end                                 /* ex                         */
   call ZB_SAVELOG                     /*                           -*/
   address ISPEXEC
   "VIEW DATASET("logdsn")"
 
return                                 /*@ F_ANALYZE                 */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   sw.0Diag    = SWITCH("DIAGNOSE")
   sw.0Rpt     = SWITCH("REPORT")
   /* These variables may be used for several ganged declares.
      Therefore, initialization must occur only once.                */
   parse value "1  1  1  1  1 "  with,
                start.   depth.  ,
                efflvl.  ,
                .
   parse value "0 0 0 0 0 0 0 0 "  with,
                end.  ,
                length.         totlen.   ,
                .
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
ZA_SETUP_LOG:                          /*@                           */
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
 
   call ZL_LOGMSG(exec_name "started by" Userid()  yyyymmdd  hhmmss)
   call ZL_LOGMSG("Arg:" opts   )
 
return                                 /*@ ZA_SETUP_LOG              */
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
if helpmsg <> "" then do ; say ""; say helpmsg; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "" ; say ""
say "  "ex_nam"      inserts start- and end-position information comments   "
say "                into a PL/I declare.                                   "
say "                                                                       "
say "                                                                       "
say "  Syntax:   "ex_nam"  <no parms>                                       "
say "                                                                       "
say "                                                                       "
say "***                                                                    "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                   "
say "                                                                       "
say "        REPORT:   maintains a log of activity as the DCL is parsed.    "
say "                                                                       "
say "        MONITOR:  shows the report as it is being produced.  Only      "
say "                    valid if REPORT was requested.                     "
say "                                                                       "
say "        BRANCH:   show all paragraph entries.                          "
say "                                                                       "
say "        TRACE tv: will use value following TRACE to place the          "
say "                  execution in REXX TRACE Mode.                        "
say "                                                                       "
say "                                                                       "
say "   Debugging tools can be accessed in the following manner:            "
say "                                                                       "
say "        "ex_nam"   debug-options                                       "
say "                                                                       "
say "   For example:                                                        "
say "                                                                       "
say "        "ex_nam"  REPORT  TRACE ?R                                     "
 
if sw.inispf then,
   address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*            REXXSKEL back-end removed for space                    */
