/* REXX    JSPLIT     Reorganize JCL into a neater package
 
           Written by Frank Clarke 20041101
 
     Impact Analysis
.    SYSEXEC   TRAPOUT
 
     Modification History
     20050104 fxc handle quoted strings;
     20061217 fxc finally working!;
 
*/
address ISREDIT                        /* REXXSKEL ver.20040227      */
"MACRO (opts)"
upper opts
info   =       opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
 
call A_INIT                            /*                           -*/
   address TSO "NEWSTACK"
call B_ONE_LINE                        /*                           -*/
call C_RECONSTRUCT                     /*                           -*/
   address TSO "DELSTACK"
call ZB_SAVELOG                        /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ JSPLIT                    */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   call AA_SETUP_LOG                   /*                           -*/
   parse value "" with,
         frag.   fragordr.  ,
         stash   taglist  ,
         text  slug  comm
   parse value "0 0 0 0 0 0 0 0 0 0 0 0 0 0" with,
         top  bottom  line#  .
 
   fragordr.DD   = "DUMMY SYSOUT OUTPUT DSN DISP UNIT VOL SPACE DCB",
                   "RECFM LRECL BLKSIZE"
   fragordr.EXEC = "PGM PROC PARM # COND @ REGION TIME"
   fragordr.JOB  = "0_AI 0_PN USER PASSWORD REGION TIME COND",
                   "CLASS MSGCLASS MSGLEVEL NOTIFY"
 
   "RESET"
   "RENUM"
   "UNNUM"
   "(bottom) = LINENUM .zl"            /* last line                  */
   top       = 1
   "F FIRST P'^'"
   "LABEL .zcsr = .JS 0"               /* mark JCL-start             */
   "(origcaps) = CAPS"
   "CAPS OFF"
 
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
 
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                  "started by" Userid()  yyyymmdd  hhmmss)    /*    -*/
 
return                                 /*@ AA_SETUP_LOG              */
/*
   Read the JCL bottom-up separating each statement into the three
   canonical tokens plus all the comments collected in a fourth token.
   Push each line onto the stack to maintain original order.  Queue
   each block of comment right-justified in a field of 71.
.  ----------------------------------------------------------------- */
B_ONE_LINE:                            /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   x3e = '3E'x
   x3f = '3F'x
   do line# = bottom to top by -1
      "(text) = LINE" line#
 
      ptf = Pos("'",text)
      ptl = LastPos("'",text)
      if ptf > 0 then,                 /* there is a quote           */
      if ptf < ptl then do             /* there are two quotes       */
         slab  = Translate(Substr(text,ptf,ptl-ptf+1),,
                           x3f , " " ) /* blanks to special          */
         text = Overlay(slab,text,ptf)
         sw.0_dotted = 1               /*                            */
         end
 
      if Left(text,2) <> "//" then do  /* non-JCL                    */
         push Strip(text,"T")          /* top of stack               */
         iterate
         end
      else text = Left(text,72)        /* lop numbers                */
 
      if Left(text,3) = "//*" then do  /* comment                    */
         push Strip(text,"T")          /* top of stack               */
         iterate
         end
                      /* It's REAL JCL...                            */
      parse var text . verb .          /* 2nd token                  */
      if WordPos(verb,"EXEC PROC DD") > 0 then do
         parse var text w1 w2 w3 comm  /* //ddname dd dsn=...        */
         if comm <> "" then do
            comm = Right(comm,71)
            comm = Overlay("//*",comm,1)
            push  comm
            end
         slug = w1 w2 Space(w3 slug,0)
         push slug                     /* top of stack               */
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                         slug)
         parse value "" with slug comm
         iterate                       /* next line up               */
         end                           /* a verb I know              */
      else,
      if WordPos(verb,"JOB") > 0 then do
         parse var text w1 w2 w3
         w3 = Strip(w3)
         pt = LastPos(",",w3) + 1      /* find the last comma        */
         if Substr(w3,pt,1) == ' ' then,    /* text beyond?          */
            parse var w3   w3 =(pt) comm     /* split off comment    */
         if comm <> "" then do
            comm = Right(comm,71)
            comm = Overlay("//*",comm,1)
            push  comm
            end
         w3 = Translate(w3,x3f," ")    /* spaces to special          */
         slug = w1 w2 Space(w3 slug,0)
         push slug                     /* top of stack               */
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                         slug)
         parse value "" with slug comm
         iterate                       /* next line up               */
         end                           /* a verb I know              */
      else,
      if WordPos(verb,"PRINT INCLUDE OUTPUT SET JCLLIB") > 0 then,
         do
         parse var text w1 w2 w3 comm  /* //ddname dd dsn=...        */
         if comm <> "" then do
            comm = Right(comm,71)
            comm = Overlay("//*",comm,1)
            push  comm
            end
         slug = w1 w2 Space(w3 x3e slug,0)
         push slug                     /* top of stack               */
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                         text)
         parse value "" with slug comm
         iterate
         end                           /* a verb I know              */
      else,
      if Left(verb,1) = "'" then do    /* continued PARM             */
         parse var text  .  text       /* take it all                */
         ptf = Pos("'",text) + 1       /* start of parm-text         */
         parse var text   "'"  w2  "'" /* extract text               */
         w2 = Translate(w2,x3f," ")    /* spaces to special          */
         text = Overlay(w2  ,text,ptf) /* insert between quotes      */
         parse var text   text  comm
         if comm <> "" then do
            comm = Right(comm,71)
            comm = Overlay("//*",comm,1)
            push  comm
            end
         slug = Space(text     slug,0) /* concat                     */
         sw.0_dotted = 1               /*                            */
         iterate
         end                           /* a verb I know              */
 
      /* it must be a continued line...                              */
      parse var text w1 w2    comm
      if comm <> "" then do
         comm = Right(comm,71)
         comm = Overlay("//*",comm,1)
         push  comm
         end
      slug = w2""x3e""slug             /* concat                     */
   end                                 /* bottom to top              */
 
return                                 /*@ B_ONE_LINE                */
/*
   The original JCL has been one-lined and can be found on the stack.
   Split to component parts, reassemble, and reconstruct the JCL.
.  ----------------------------------------------------------------- */
C_RECONSTRUCT:                         /*@                           */
   c_tv = trace()                      /* what setting at entry ?    */
                                     rc = Trace("O"); rc = trace(c_tv)
   if branch then call BRANCH
   address ISREDIT
 
   do queued()
      pull line
      if Left(line,3) = "//*" then do  /* comment                    */
         queue line
         iterate
         end
 
      if Left(line,2) <> "//" then do  /* non-JCL                    */
         queue line
         iterate
         end
 
      frag.  = ""                      /* re-init                    */
      parse var line w1 w2 w3
      taglist  = ""
      /* JOB goes in 12;  EXEC goes in 12; DD goes in 13 followed by 2
         blanks; otherwise space1.  */
      select
         when w2="DD" then do
            if Length(w1) < 12 then,
                 slug = Left(w1,11) w2
            else slug = w1 w2
            call CD_PARSE_DD           /*                           -*/
            end                        /* DD                         */
         when w2="EXEC" then do
            if Length(w1) < 11 then,
                 slug = Left(w1,10) w2
            else slug = w1 w2
            call CE_PARSE_EXEC         /*                           -*/
            end                        /* EXEC                       */
         when w2="JOB" then do
            if Length(w1) < 11 then,
                 slug = Left(w1,10) w2
            else slug = w1 w2
            call CJ_PARSE_JOB          /*                           -*/
            end                        /* JOB                        */
         when w2="PROC" then do
            if Length(w1) < 11 then,
                 slug = Left(w1,10) w2
            else slug = w1 w2
            call CP_PARSE_PROC         /*                           -*/
            end                        /* PROC                       */
         otherwise do
            slug = Space(w1 w2 w3,1)
            call CU_PARSE_UNDEF        /*                           -*/
            end
      end                              /* select                     */
   end                                 /* queued                     */
 
   if noupdt then return
   do queued()                         /* every stacked line         */
      parse pull line
      "LINE_BEFORE .JS = (line)"
   end                                 /* queued                     */
 
   "RESET"
   "X ALL   .JS  .ZL"                  /* exclude original           */
   "DEL ALL X"                         /* ...and delete              */
   "F FIRST P'^'"                      /* position to top            */
 
return                                 /*@ C_RECONSTRUCT             */
/*
   Reconstruct a DD statement.
.  ----------------------------------------------------------------- */
CD_PARSE_DD:                           /*@                           */
   cd_tv = trace()                     /* what setting at entry ?    */
   if branch then call BRANCH
   address ISREDIT
 
   if Pos( "," , w3  ) = 0 then do     /* first token * or DUMMY     */
      w3    = Translate(w3  ," ",x3f)  /* special to blanks          */
      queue slug Strip(w3)             /* slug is w1+w2              */
      parse value "" with w1 w2 w3
      return
      end
 
   parse var w3 tag "="
   if Pos( "," , tag ) > 0 then do     /* first token may be DUMMY   */
      parse var w3 notag "," w3        /* identify                   */
      taglist = "DUMMY" taglist
      frag.DUMMY = notag
      end
 
   call CX_DEFRAG                      /* sets frag.tag=tagvalue    -*/
                                       /* E.g.: frag.DISP=(SHR,PASS) */
   /* Process FRAGORDER first, eliminating tags from TAGLIST         */
   wrkordr = fragordr.DD
   suffix  = ","
   do cz = 1 to Words(wrkordr)         /* each word                  */
      token   =  Word(wrkordr,cz)      /* isolate one                */
      if Words(taglist) = 0 then leave
      if Words(taglist) = 1 then suffix = ""
      if frag.token <> "" then do
                                     rc = Trace("O"); rc = trace(cd_tv)
         slug    = Left(slug,14) token"="frag.token
         /* if slug is too long, crack it in pieces.                 */
         if Length(slug) > 65 then,
            do
            call CDS_SPLIT_LONG        /*                           -*/
            end
         else,
            do
            slug = Translate(slug," ",x3e) /* special to blanks      */
            end
         queue Strip(slug)suffix
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,       /*    -*/
                         Strip(slug)suffix)
         slug  =  Left("//",14)
         end                           /* frag.token                 */
      wpt     = WordPos(token,taglist) /* locate                     */
      if wpt > 0 then,
         taglist = DelWord(taglist,wpt,1) /* snip                    */
   end                                 /* cz                         */
 
   /* Process remaining tags in TAGLIST                              */
   do cz = 1 to Words(taglist)         /* each word                  */
      token   =  Word(taglist,cz)      /* isolate one                */
      if Words(taglist) = cz then suffix = ""
      if frag.token <> "" then do
                                     rc = Trace("O"); rc = trace(cd_tv)
         slug    = slug token"="frag.token""suffix
         /* if slug is too long, crack it in pieces.                 */
         if Length(slug) > 65 then,
            do
            call CDS_SPLIT_LONG        /*                           -*/
            end
         else,
            do
            slug = Translate(slug," ",x3e) /* special to blanks      */
            end
         queue Strip(slug)suffix
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,       /*    -*/
                         Strip(slug)suffix)
         slug  =  Left("//",14)
         end                           /* frag.token                 */
   end                                 /* cz                         */
 
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                   queued() "lines queued")             /*          -*/
 
return                                 /*@ CD_PARSE_DD               */
/*
   SLUG is ready-to-write except that it's too long to be written on a
   single line.  Split and queue all but the last piece.  This long
   text may contain '3E'x characters indicating original line-breaks.
   If present, split there.
.  On return, 'slug' must be fully-formed and ready to be queued.
.  ----------------------------------------------------------------- */
CDS_SPLIT_LONG: Procedure expose,      /*@                           */
         (tk_globalvars)  log. log#     frag.  token  slug x3f x3e,
                          suffix
   if branch then call BRANCH
   address TSO
 
   /* First check for comma in the string                            */
   if Length(slug) < 72 then,
   if Pos(",",slug) = 0 then return    /* can't be split             */
 
   /*  Next check for '3E'x in the string                            */
   pt = Pos( x3e , slug )
   if pt > 0 then do                   /* line was originally split  */
      do while pt > 0
         parse var slug   slug (x3e) frag.token
         queue Strip(slug)             /* already has a comma!       */
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                         slug)                                /*    -*/
         slug       =  Left("//",14) frag.token
         pt = Pos( x3e , slug )
      end                              /* pt                         */
      return
      end                              /* pt                         */
 
   parse var slug slug "=" frag.token
   delim = Left(frag.token,1)
   if delim <> "(" then,
      frag.token = "("frag.token")"
   start = 2                           /* after the banana           */
 
   do while Length(frag.token) > 45
      /* Find a comma not inside unbalanced quotes/parens            */
      stack = ""
      do cz = start to Length(frag.token)
         char  = Substr(frag.token,cz,1)
         if Pos(char , "'()" ) > 0 then
            do
            if char = "'" then,
               if Left(stack,1) = "'" then,
                  stack = Substr(stack,2)   /* snip                  */
               else stack = "'"stack        /* add                   */
            else,
            if char = "(" then,
               stack = "("stack        /* add                   */
            else,
            if char = ")" then,
               if Left(stack,1) = "(" then,
                  stack = Substr(stack,2)   /* snip                  */
            end                        /* special character          */
         else,
         if char = "," then,
            if stack = "" then,        /* no unclosed subparms       */
               do
               slug = slug Substr(frag.token,1,cz)","
               slug = Translate(slug," ",x3f)
               queue slug
               call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                               slug)                          /*    -*/
               slug       =  Left("//",14)
               frag.token = Substr(frag.token,cz+1)
               start = 1
               leave                   /* (cz, I hope...)            */
               end                     /* no unclosed subparms       */
      end                              /* cz                         */
   end                                 /* while len > 50             */
 
return                                 /*@ CDS_SPLIT_LONG            */
/*
   Reconstruct an EXEC statement.
   Order of the fragments:  first glyph (PGM=, PROC=, or procname); if
   a procedure (not 'PGM='), then each phrase in alpha-order; else
   PARM COND REGION TIME.
.  ----------------------------------------------------------------- */
CE_PARSE_EXEC:                         /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   if Pos( "PGM="  , w3 ) = 0 &,
      Pos( "PROC=" , w3 ) = 0 then,
      w3       = "PROC="w3             /* identify                   */
 
   call CX_DEFRAG                      /* sets frag.tag=tagvalue    -*/
                                       /* E.g.: frag.DISP=(SHR,PASS) */
 
   wrkordr = fragordr.EXEC
   suffix  = ","
   do cz = 1 to Words(wrkordr)         /* each word                  */
      token   =  Word(wrkordr,cz)      /* isolate one                */
      if Words(taglist) = 0 then leave
      if Words(taglist) = 1 then suffix = ""
      if frag.token <> "" then do
         if Right(frag.token,1) = x3e then,
            frag.token = Delstr(frag.token,,     /* snip!            */
                         Length(frag.token),1)
         slug    = slug token"="frag.token""suffix
         queue slug
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,       /*    -*/
                               slug)
         slug  =  Left("//",14)
         end                           /* frag.token                 */
      wpt     = WordPos(token,taglist) /* locate                     */
      if wpt > 0 then,
         taglist = DelWord(taglist,wpt,1) /* snip                    */
   end                                 /* cz                         */
 
   do cz = 1 to Words(taglist)         /* each word                  */
      token   =  Word(taglist,cz)      /* isolate one                */
      if Words(taglist) = cz then suffix = ""
      if frag.token <> "" then do
         if Right(frag.token,1) = x3e then,
            frag.token = Delstr(frag.token,,     /* snip!            */
                         Length(frag.token),1)
         slug    = slug token"="frag.token""suffix
         queue slug
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,       /*    -*/
                               slug)
         slug  =  Left("//",14)
         end                           /* frag.token                 */
   end                                 /* cz                         */
 
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                   queued() "lines queued")             /*          -*/
 
return                                 /*@ CE_PARSE_EXEC             */
/*
   Reconstruct a JOB statement.
   Order of the fragments:  Acctg info and programmer name on first
   line; then USER PASSWORD REGION TIME COND CLASS MSGCLASS MSGLEVEL
   NOTIFY
.  ----------------------------------------------------------------- */
CJ_PARSE_JOB:                          /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   /* parse accounting info                                          */
   stash = ""
   taglist = ""
   do cx = 1 to Length(w3)             /* each character             */
      this1 = Substr(w3,cx,1)
      if this1 = "(" then stash = Space(this1 stash,0)
      else,
      if this1 = ")" then,
         if Left(stash,1) = "(" then stash = Substr(stash,2)
                                else nop
      else,
      if this1 = "'" then,
         if Left(stash,1) = "'" then stash = Substr(stash,2)
                                else stash = Space(this1 stash,0)
      else,
      if this1 = "," then,
         if stash = "" then do
            tagvalue = Substr(w3,1,cx-1)
            call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                            "(Acctg info)="tagvalue)          /*    -*/
            frag.0_AI   = tagvalue
            taglist     = taglist 0_AI
            w3          = Delstr(w3,1,cx)
            leave
            end
   end                                 /* cx                         */
   /* parse programmer name                                          */
   do cx = 1 to Length(w3)             /* each character             */
      this1 = Substr(w3,cx,1)
      if this1 = "(" then stash = Space(this1 stash,0)
      else,
      if this1 = ")" then,
         if Left(stash,1) = "(" then stash = Substr(stash,2)
                                else nop
      else,
      if this1 = "'" then,
         if Left(stash,1) = "'" then stash = Substr(stash,2)
                                else stash = Space(this1 stash,0)
      else,
      if this1 = "," then,
         if stash = "" then do
            tagvalue = Substr(w3,1,cx-1)
            call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                            "(PgmrName)="tagvalue)            /*    -*/
            frag.0_PN   = tagvalue
            taglist     = taglist 0_PN
            w3          = Delstr(w3,1,cx)
            leave
            end
   end                                 /* cx                         */
   call CX_DEFRAG                      /* sets frag.tag=tagvalue    -*/
                                       /* E.g.: frag.DISP=(SHR,PASS) */
 
   wrkordr = fragordr.JOB
   suffix  = ","
   do cz = 1 to Words(wrkordr)         /* each word                  */
      token   =  Word(wrkordr,cz)      /* isolate one                */
      if Words(taglist) = 0 then leave
      if Words(taglist) = 1 then suffix = ""
      if frag.token <> "" then do
         if Right(frag.token,1) = x3e then,
            frag.token = Delstr(frag.token,,     /* snip!            */
                         Length(frag.token),1)
         if Left(token,1) = 0 then,    /* special tag                */
            slug    = slug frag.token""suffix
         else,                         /* regular tag                */
            slug    = slug token"="frag.token""suffix
         queue slug
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,       /*    -*/
                               slug)
         slug  =  Left("//",14)
         end                           /* frag.token                 */
      wpt     = WordPos(token,taglist) /* locate                     */
      if wpt > 0 then,
         taglist = DelWord(taglist,wpt,1) /* snip                    */
   end                                 /* cz                         */
 
   do cz = 1 to Words(taglist)         /* each word                  */
      token   =  Word(taglist,cz)      /* isolate one                */
      if Words(taglist) = cz then suffix = ""
      if frag.token <> "" then do
         if Right(frag.token,1) = x3e then,
            frag.token = Delstr(frag.token,,     /* snip!            */
                         Length(frag.token),1)
         slug    = slug token"="frag.token""suffix
         queue slug
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,       /*    -*/
                               slug)
         slug  =  Left("//",14)
         end                           /* frag.token                 */
   end                                 /* cz                         */
 
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                   queued() "lines queued")             /*          -*/
 
return                                 /*@ CJ_PARSE_JOB              */
/*
.  ----------------------------------------------------------------- */
CP_PARSE_PROC:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   call CX_DEFRAG                      /* sets frag.tag=tagvalue    -*/
                                       /* E.g.: frag.DISP=(SHR,PASS) */
 
   suffix  = ","
   do cz = 1 to Words(taglist)         /* each word                  */
      token   =  Word(taglist,cz)      /* isolate one                */
      if Words(taglist) = cz then suffix = ""
      if frag.token <> "" then do
         if Right(frag.token,1) = x3e then,
            frag.token = Delstr(frag.token,,     /* snip!            */
                         Length(frag.token),1)
         slug    = slug token"="frag.token""suffix
         slug  = Translate(slug," ",x3f)  /* special to blanks       */
         queue slug
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,       /*    -*/
                               slug)
         slug  =  Left("//",14)
         end                           /* frag.token                 */
   end                                 /* cz                         */
 
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                   queued() "lines queued")             /*          -*/
 
return                                 /*@ CP_PARSE_PROC             */
/*
   The verb is unrecognized.  Report it and do a generalized
   parse-and-queue.  If the line contains X3E characters, split at
   those points.
.  ----------------------------------------------------------------- */
CU_PARSE_UNDEF:                        /*@                           */
   if branch then call BRANCH
   address TSO
 
   slug  = Translate(slug," ",x3f)     /* special to blanks          */
 
   if Right(slug,1) = x3e then,
      slug = Delstr(slug,,                       /* snip!            */
                   Length(slug),1)
   pt = Pos( x3e , slug )
   if pt > 0 then do                   /* line was originally split  */
      do while pt > 0
         parse var slug   slug (x3e) frag.token
         queue Strip(slug)             /* already has a comma!       */
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                         slug)                                /*    -*/
         slug       =  Left("//",14) frag.token
         pt = Pos( x3e , slug )
      end                              /* pt                         */
      end                              /* pt                         */
   queue slug
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,             /*    -*/
                         slug)
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,       /*          -*/
                   queued() "lines queued")
 
return                                 /*@ CU_PARSE_UNDEF            */
/*
   <SLUG> contains the first 2 tokens of the text.  <W3> contains all
   the remainder of the text.  Defragment W3.
.  How to DEFRAG:
       get the first token (TKN=......)
       walk the rest of the string stacking and destacking parens
          and quotes.
       when the current character is a comma (or end-of-string) and
          there are no unmatched parens or quotes, store as the
          tagvalue.
.  ----------------------------------------------------------------- */
CX_DEFRAG:                             /*@                           */
   cx_tv = trace()                     /* what setting at entry ?    */
                                     rc = Trace("O"); rc = trace(cx_tv)
   if branch then call BRANCH
   address ISREDIT
 
   do while w3 <> ''                   /* until completely parsed    */
      parse var w3 tag "=" w3
      stash = ""                       /* reinit                     */
                                                        rc = Trace("O")
      do cx = 1 to Length(w3)          /* each character             */
         this1 = Substr(w3,cx,1)       /* isolate the character      */
         if this1 = "(" then stash = Space(this1 stash,0)
         else,
         if this1 = ")" then,
            if Left(stash,1) = "(" then stash = Substr(stash,2)
                                   else nop
         else,
         if this1 = "'" then,
            if Left(stash,1) = "'" then stash = Substr(stash,2)
                                   else stash = Space(this1 stash,0)
         else,
         if this1 = "," then,
            if stash = "" then do      /* balanced                   */
                                     rc = Trace("O"); rc = trace(cx_tv)
               tagvalue = Substr(w3,1,cx-1)
               call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                               tag"="tagvalue)                /*    -*/
               frag.tag = tagvalue
               taglist  = taglist tag
               w3       = Delstr(w3,1,cx)   /* snip tagvalue from w3 */
               if Left(w3,1) = x3e then,
                  w3    = Substr(w3,2)      /* snip the x3e          */
               leave
               end
            else,                      /* stash not empty            */
               do
                                     rc = Trace("O"); rc = trace(cx_tv)
               if tag = "PARM" then,
               if Pos("'",stash) = 0 then do
                  call CXP_PARSE_PARM  /*                           -*/
                  end                  /* no quote in stash          */
               end
 
                                    rc = Trace("O") ; rc = trace(cx_tv)
         if cx = Length(w3) then do
            frag.tag = w3
            tagvalue = w3
            taglist  = Space(taglist tag,1)
            call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                            tag"="tagvalue)                   /*    -*/
            w3       = ""
            end
      end                              /* cx                         */
   end                                 /* w3                         */
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                   "Taglist for" w2":" taglist)               /*    -*/
 
return                                 /*@ CX_DEFRAG                 */
/*
   This is a PARM and can be quite long.  PARMs can look like this:
       parm=('aaaaaa','bbbbbb','ccccccc'),nexttag=...
   CX already points to the first comma.
   Store <<('aaaaaa'>>, then store <<'bbbbbb'>>, then store <<'ccccccc')>>.
   Excise the string from W3 before returning.
.  ----------------------------------------------------------------- */
CXP_PARSE_PARM:                        /*@                           */
   if branch then call BRANCH
   address TSO
 
   tagvalue = Substr(w3,1,cx-1)
   call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                   tag"="tagvalue)                            /*    -*/
   frag.tag = tagvalue
   taglist  = taglist tag
   newpt = cx+1                        /* after the comma            */
 
   do cx = newpt to Length(w3)         /* each character             */
      this1 = Substr(w3,cx,1)
      if this1 = "(" then stash = Space(this1 stash,0)
      else,
      if this1 = ")" then,
         if Left(stash,1) = "(" then stash = Substr(stash,2)
                                else nop
      else,
      if this1 = "'" then,
         if Left(stash,1) = "'" then stash = Substr(stash,2)
                                else stash = Space(this1 stash,0)
      else,
      if this1 = "," then,
         if Pos("'",stash) = 0 then do
            tagvalue = Substr(w3,newpt,cx-1)
            tag = tag"#"
            call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                            tag"="tagvalue)                   /*    -*/
            frag.tag = tagvalue
            taglist = taglist tag
            pt = LastPos("#",fragordr.EXEC) +1
            parse var fragordr.EXEC front =(pt) back
            fragordr.EXEC = front tag back
            newpt = cx+1               /* after the comma            */
            leave
            end                        /* no quote in stash          */
 
      if cx = Length(w3) then do
         frag.tag = tag"#"
         tagvalue = Substr(w3,newpt)
         taglist     = Space(taglist tag,1)
         call ZL_LOGMSG( exec_name "("BRANCH("ID")")" ,
                         tag"="tagvalue)                      /*    -*/
         pt = LastPos("#",fragordr.EXEC) +1
         parse var fragordr.EXEC front =(pt) back
         fragordr.EXEC = front""tag "#" back
         w3          = ""
         end
   end                                 /* cx                         */
 
return                                 /*@ CXP_PARSE_PARM            */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
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
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address ISPEXEC "CONTROL DISPLAY SAVE"
address TSO;"CLEAR" ; say ""
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      reorganizes JCL to place one-phrase-per-line (where       "
say "                possible).  Phrases are reordered as follows:             "
say "                                                                          "
say "                  JOB  :  (AI PN) USER PASSWORD REGION TIME COND ...      "
say "                                                                          "
say "                  EXEC :  PGM PROC PARM COND REGION TIME ...              "
say "                                                                          "
say "                  DD   :  DUMMY SYSOUT OUTPUT DSN DISP UNIT VOL           "
say "                             SPACE DCB ...                                "
say "                                                                          "
say "  Syntax:   "ex_nam"  (no parms)                                          "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
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
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/* ----------- REXXSKEL back-end removed for space ----------------- */