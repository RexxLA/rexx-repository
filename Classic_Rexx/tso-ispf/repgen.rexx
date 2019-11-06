/* REXX    REPGEN     This exec processes a mockup of a printable report
                      and produces PLI or COBOL record structures for
                      inclusion into the program source.
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
           Written by J.P.MacKean RCG Information Technology
 
     Impact Analysis
.    SYSPROC  TRAPOUT
 
     Modification History
     19980501 jpm Original conversion of earlier REXX exec;
     20010926 fxc Upgrade from v.19980225 to v.20010730; convert to
                  FB/80;
     20040824 fxc adjust width of data areas; NORECID;
     20040916 fxc enable LRECL;
     20051004 fxc enable STARS;
     20051201 fxc STARS and NORECID on the panel;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010730      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
                                       /*                            */
call A_Initialize                      /* local initialization       */
call B_User_Interface                  /* let user specify I/O dsns  */
call C_Wrap_up                         /* clean up and exit          */
 
if ^sw.nested then call DUMP_QUEUE     /*                            */
exit                                   /*@ REPGEN                    */
/*
.  ----------------------------------------------------------------- */
A_Initialize:                          /*@ Initialize local variables*/
   if branch then call BRANCH
   address ISPEXEC
 
   m = MSG('OFF')                      /* turn OFF tso messages      */
   sw.0proceed = "0"
   call AK_KEYWDS                      /*                           -*/
                                       /* get profile ariables       */
   "VGET (rgihli,rgigrp,rgityp,rgidsn) profile"
   "VGET (rgohli,rgogrp,rgotyp,rgodsn,rglang) profile"
 
return                                 /*@ A_Initialize              */
/*
.  ----------------------------------------------------------------- */
AK_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   sw.0Star_fill = SWITCH("STARS")
   sw.0_RECID    = \SWITCH("NORECID")
   parse value   KEYWD("LRECL")  "133"   with ,
                 lrecl   .
 
return                                 /*@ AK_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
B_User_Interface:                      /*@ let user specify I/O dsns */
   if branch then call BRANCH
   address ISPEXEC
 
   call BA_PROLOG                      /*                           -*/
   do forever
      rgimem = " "
      rgseq = "1"
      @star = Left("X",sw.0Star_fill)
      @rid  = Left("X",sw.0_RECID)
      "DISPLAY PANEL(REPGEN01)"        /* display data-entry panel   */
      if zcmd = "X" | rc > 0 then leave
 
      sw.0Star_fill = @star = "X"
      sw.0_RECID    = @rid  = "X"
 
      call BI_CHECK_INPUT_DATASET      /* is input dsn valid         */
                                    if sw.0proceed <> '1' then iterate
      call BO_CHECK_OUTPUT_DATASET     /* is output dsn valid        */
                                    if sw.0proceed <> '1' then iterate
      call BP_PROCESS_LAYOUT           /* process the layout dataset */
 
   end                                 /* do forever                 */
   call BZ_EPILOG                      /*                           -*/
 
return                                 /*@ B_User_Interface          */
/*
   Deimbed panels; attach via LIBDEF.
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
BI_CHECK_INPUT_DATASET:                /*@ verify input dataset name */
   if branch then call BRANCH
   address ISPEXEC
 
   "VGET (rgihli,rgigrp,rgityp,rgidsn) profile"
   "VGET (zprefix,zuser,rgimem) shared"
   sw.0proceed = "0"
   if rgidsn = "" then                 /* if null, go with last dsn  */
      indsn = rgihli"."rgigrp"."rgityp"("rgimem")"
   else do
      if substr(rgidsn,1,1) = "'" then /* fully qualified ?          */
         indsn = rgidsn
      else do
         if zprefix = "" then
            indsn = zuser"."rgidsn     /* not qualified, add TSO user*/
         else
            indsn = zprefix"."rgidsn   /* not qualified, add prefix  */
      end
   end
   indsn = strip(indsn,"B","'")
   if indsn = ".." then do             /* dsn no good                */
      ZERRSM = "Invalid source dataset"
      ZERRLM = "Unable to locate the source dataset or insufficient access"
      "SETMSG MSG(ISRZ002)"
   end
   else do
      parse value indsn with indsn "(" rgimem ")"
      if SYSDSN("'"indsn"'") = "OK" then do
         dsi = LISTDSI("'"indsn"'")    /* get dataset attributes     */
         indsorg = SYSDSORG
         if indsorg = 'PS' then do     /* sequential ?               */
            if rgimem = "" then
               call BIA_ALLOCATE_LAYOUT /*allocate to ddname INDD    */
            else do
               ZERRSM = "Dataset not partitioned"
               ZERRLM = "A member was specified, but the dataset",
                        "is not partitioned"
               "SETMSG MSG(ISRZ002)"
            end
         end
         else do
            if rgimem = "" then do
               call BIS_SELECT_MEMBER_LIST /* member picklist        */
               indsn = indsn"("rgimem")"
               call BIA_ALLOCATE_LAYOUT /*allocate to ddname INDD    */
            end
            else do
               pattern = index(rgimem,'*')
               if pattern > 0 then     /* specified member pattern   */
                  call BIS_SELECT_MEMBER_LIST /* member picklist     */
               indsn = indsn"("rgimem")" /* add member name          */
               call BIA_ALLOCATE_LAYOUT /*allocate to ddname INDD    */
            end
         end                           /*                            */
      end                              /*                            */
      else do
         ZERRSM = "Invalid source dataset"
         ZERRLM = "Unable to locate the source dataset or insufficient access"
         "SETMSG MSG(ISRZ002)"
      end                              /*                            */
   end                                 /*                            */
 
return                                 /*@ BI_CHECK_INPUT_DATASET    */
/*
.  ----------------------------------------------------------------- */
BIA_ALLOCATE_LAYOUT:                   /*@ allocate layout to INDD   */
   if branch then call BRANCH
   address TSO
 
   if SYSDSN("'"indsn"'") = "OK" then do
      "ALLOCATE FILE(INDD) DATASET('"indsn"') SHR REUSE"
      if rc = 0 then do
         "EXECIO * DISKR INDD (STEM inrec. FINIS"
         sw.0proceed = "1"
      end
      else do
         ZERRSM = "Allocation error input"
         ZERRLM = "An error occurred allocating the input source layout file"
         address ISPEXEC "SETMSG MSG(ISRZ002)"
      end
   end
   else do
      ZERRSM = "Invalid source dataset"
      ZERRLM = "Unable to locate the source dataset or insufficient access"
      address ISPEXEC "SETMSG MSG(ISRZ002)"
   end
 
return                                 /*@ BIA_ALLOCATE_LAYOUT       */
/*
.  ----------------------------------------------------------------- */
BIS_SELECT_MEMBER_LIST:                /*@ display member list       */
   if branch then call BRANCH
   address ISPEXEC
 
   "LMINIT DATAID(MEMLIST) DATASET('"indsn"') ENQ(SHR)"
   "LMOPEN DATAID("memlist") OPTION(INPUT)"
   "LMMDISP DATAID("memlist") MEMBER("rgimem") OPTION(DISPLAY) COMMANDS(S)"
   rgimem = strip(zlmember)            /* get user specified member  */
   "LMMDISP DATAID("memlist") OPTION(FREE)"
   "LMCLOSE DATAID("memlist")"
   "LMFREE DATAID("memlist")"
 
return                                 /*@ BIS_SELECT_MEMBER_LIST    */
/*
.  ----------------------------------------------------------------- */
BO_CHECK_OUTPUT_DATASET:               /*@ verify output dataset name*/
   if branch then call BRANCH
   address TSO
 
   address ISPEXEC "VGET (rgohli,rgogrp,rgotyp,rgodsn,rglang) profile"
   address ISPEXEC "VGET (zprefix,zuser) shared"
   sw.0proceed = "0"
   if rgodsn = "" then                 /* if null, go with last dsn  */
      outdsn = rgohli"."rgogrp"."rgotyp
   else do
      if substr(rgodsn,1,1) = "'" then /* fully qualified ?          */
         outdsn = rgodsn
      else do
         if zprefix = "" then
            outdsn = zuser"."rgodsn    /* not qualified, add TSO user*/
         else
            outdsn = zprefix"."rgodsn  /* not qualified, add prefix  */
      end
   end
   outdsn = strip(outdsn,"B","'")
   if outdsn = ".." then do            /* dsn no good                */
      ZERRSM = "Invalid output dataset"
      ZERRLM = "Unable to locate the output dataset or insufficient access"
      address ISPEXEC "SETMSG MSG(ISRZ002)"
   end
   else do
      parse value outdsn with outdsn "(" rgomem ")"
      if SYSDSN("'"outdsn"'") = 'OK' then do /* output dsn exists ?  */
         dsi = LISTDSI("'"outdsn"'")   /* get dataset attributes     */
         outdsorg = SYSDSORG
         if outdsorg = "PS" then do    /* sequential ?               */
            rgomem = ""
            call BOA_ALLOCATE_OUTFILE  /* allocate to ddname OUTDD   */
         end
         else do                       /* set default member name    */
            if rgimem = "" | indsorg = "ps" then
               rgomem = "rg" || substr(date('s'),3,6)
            else
               rgomem = rgimem
            call BOA_ALLOCATE_OUTFILE  /* allocate to ddname OUTDD   */
         end
      end
      else do                          /* not found, allocate new one*/
         "ALLOCATE DATASET('"outdsn"') NEW SPACE(2,5) TRACKS ",
                   "RECFM(F B) LRECL(80) DIR(5) CATALOG"
         if rc = 0 then do             /* set default member name    */
            if rgimem = "" | indsorg = "PS" then
               rgomem = "rg" || substr(date('s'),3,6)
            else
               rgomem = rgimem
            call BOA_ALLOCATE_OUTFILE  /* allocate to ddname OUTDD   */
         end
         else do
            ZERRSM = "Invalid output dataset"
            ZERRLM = "Unable to locate the output dataset or",
                     "insufficient access"
            address ISPEXEC "SETMSG MSG(ISRZ002)"
         end
      end
   end
 
return                                 /*@ BO_CHECK_OUTPUT_DATASET   */
/*
.  ----------------------------------------------------------------- */
BOA_ALLOCATE_OUTFILE:                  /*@ allocate output to OUTDD  */
   if branch then call BRANCH
   address TSO
 
   if SYSDSN("'"outdsn"'") = "OK" then do
      if rgomem = "" then
         nop
      else
         outdsn = outdsn"("rgomem")"
      "ALLOCATE FILE(OUTDD) DATASET('"outdsn"') SHR REUSE"
      if rc = 0 then
         sw.0proceed = "1"
      else do
         ZERRSM = "Allocation error output"
         ZERRLM = "An error occurred allocating the output source layout file"
         address ISPEXEC "SETMSG MSG(ISRZ002)"
      end
   end
   else do
      ZERRSM = "Invalid output dataset"
      ZERRLM = "Unable to locate the output dataset or insufficient access"
      address ISPEXEC "SETMSG MSG(ISRZ002)"
   end
 
return                                 /*@ BOA_ALLOCATE_OUTFILE      */
/*
.  ----------------------------------------------------------------- */
BP_PROCESS_LAYOUT:                     /*@ process the report layout */
   if branch then call BRANCH
   address ISPEXEC
 
   call BPA_GET_VARNAMES               /* var names to substitute    */
   parse value "0 0 0" with rec# ix v# /* initialize counters        */
   if verify(rgseq,"123456789") = 0 then do
      ix = ix + rgseq
      seq = substr("ABCDEFGHI",ix,1)   /* A=first, B=sceond, etc.    */
   end
   else
      seq = "A"
 
   do l = 1 to limit
      inrec.l  = Left(inrec.l,lrecl," ")
      parse var inrec.l carriage 2 remainder /* carriage control char*/
      count = 0
      charpos. = ''
      do while (length(remainder) >= 2) /* assign to stem variable   */
         count = count + 1
         parse var remainder charpos.count 2 remainder
      end
      count = count + 1
      charpos.count = remainder
      call BPB_ANALYSE_STRING          /* text, char or numeric ?    */
      call BPC_GET_LINE_SEGMENTS       /* get substrings of like type*/
      select
         when rglang = 'PLI' then
            call BPD_GENERATE_PLI      /* build PLI declare stmts    */
         when rglang = 'COBOL' then
            call BPE_GENERATE_COBOL    /* build COBOL data stmts     */
         otherwise do
            ZERRSM = "Language not supported"
            ZERRLM = "The language chosen is currently not supported"
            "SETMSG MSG(ISRZ002)"
            sw.0proceed = '0'
            return
         end
      end
   end
 
   ZERRSM = "Copy member generated"
   ZERRLM = "A copy member containing the report structures has been generated"
   ZERRALRM = "NO"
   "SETMSG MSG(ISRZ002)"
   ZERRALRM = "YES"
   sw.0proceed = "1"
   rgidsn  = ""
   rgodsn  = ""
 
return                                 /*@ BP_PROCESS_LAYOUT         */
/*
.  ----------------------------------------------------------------- */
BPA_GET_VARNAMES:                      /*@ substitution var. names   */
   if branch then call BRANCH
   address TSO
 
   parse value "" with wordlist text   /* initialize variable list   */
                                       /* start from bottom of layout*/
                                       /* looking for an open bracket*/
   do ii = inrec.0 to 1 by -1 while(POS("(",text) = 0)
      text = strip(inrec.ii) text      /* build list of variables    */
   end
   if ii = 0 then                      /* no ?VARS statement found   */
      limit = inrec.0                  /* process while layout       */
   else
      limit = ii                       /* save last line of layout   */
   text = TRANSLATE(text,' ','+')      /* translate pluses to blanks */
   parse  var text "(" wordlist ")"    /* strip off all but var names*/
 
   varname. = "?"                      /* initialize varname stem    */
   do ii = 1 to words(wordlist)        /* how many variable names ?  */
      zvar = word(wordlist,ii)         /* variable name              */
      varname.ii = zvar                /* assign name to varname stem*/
   end
 
return                                 /*@ BPA_GET_VARNAMES          */
/*
.  ----------------------------------------------------------------- */
BPB_ANALYSE_STRING:                    /*@ text, char or numeric     */
   if branch then call BRANCH
   address TSO
 
   j        = 0                        /* variable counter           */
   save_len = 1                        /* length of current segment  */
   vtype.   = ''                       /* array of variable types    */
   vlen.    = 0                        /* array of variable lengths  */
   select
      when charpos.1 = '?' then        /* ? indicates character      */
         save_type = 'c'
      when charpos.1 = '#' then        /* # indicates numeric PIC    */
         save_type = 'p'
      when charpos.1 = ' ' then        /* blank indicates blank      */
         save_type = 'b'
      otherwise                        /* otherwise, literal text    */
         save_type = 't'
   end
   do i = 2 to count                   /* scan each character of line*/
      select
         when charpos.i = '?' then     /* ? indicates character      */
            this_type = 'c'
         when charpos.i = '#' then     /* # indicates numeric PICTURE*/
            this_type = 'p'
         when WORDPOS(charpos.i, ', . 9 - $') > 0 then
            if save_type = 'p' then    /* other PICTURE characters   */
               this_type = 'p'
            else
               this_type = 't'         /* literal text               */
         when charpos.i = ' ' then     /* blank indicates blank      */
            this_type = 'b'
         otherwise                     /* otherwise, literal text    */
            this_type = 't'
      end
      if this_type = save_type then    /* same segment type ?        */
         save_len = save_len + 1       /* increment segment length   */
      else do                          /* end of this segment        */
         j = j + 1                     /* increment segment count    */
         vtype.j = save_type           /* assign segment type        */
         vlen.j  = save_len            /* assign segment length      */
         save_type = this_type         /* next segment type          */
         save_len  = 1                 /* next segment length        */
      end
   end                                 /* scan each character        */
   j = j + 1
   vtype.j = save_type                 /* last segment type          */
   vlen.j  = save_len                  /* last segment length        */
   k = j - 1
   do x = 1 to k                       /* adjust literal lengths     */
      z = x + 1                        /* to fit declare formats     */
      select
         when (vtype.x = 't' & vtype.z = 'b' & vlen.z < 4) then do
            vtype.z = 't'              /* append blanks into text    */
            vlen.z = vlen.z + vlen.x
            vlen.x = 0
         end
         when (vtype.x = 'b' & vlen.x < 4 & vtype.z = 't') then do
            vlen.z = vlen.z + vlen.x   /* append text to blanks      */
            vlen.x = 0
         end
         when (vtype.x = 't' & vtype.z = 't') then do
            vlen.z = vlen.z + vlen.x   /* merge text strings         */
            vlen.x = 0
         end
         otherwise
            nop
      end
   end
 
return                                 /*@ BPB_ANALYSE_STRING        */
/*
.  ----------------------------------------------------------------- */
BPC_GET_LINE_SEGMENTS:                 /*@ retrieve line segments    */
   if branch then call BRANCH
   address TSO
 
   k = 0                               /* segment counter this line  */
   text. = ''                          /* array of line segments     */
   field_start = 2
   do x = 1 to j
      if vlen.x > 0 then do
         k = k + 1
         text.k = substr(inrec.l,field_start,vlen.x)
         field_start = field_start + vlen.x
         if length(text.k) > 50 then do
            char1 = substr(text.k,1,1)
            if verify(text.k,char1) = 0 then
               nop
            else do                    /* breakup literals > 50 bytes*/
               longvar = text.k
               do while (length(longvar) > 50)
                  parse var longvar text.k 51 longvar
                  k = k + 1
               end
               text.k = longvar
            end
         end
      end
   end
   number_of_segments = k              /* segments in this line      */
 
return                                 /*@ BPC_GET_LINE_SEGMENTS     */
/*
.  ----------------------------------------------------------------- */
BPD_GENERATE_PLI:                      /*@ build PLI declare stmts   */
   if branch then call BRANCH
   address TSO
 
   j    = 0                            /* segment counter            */
   f#   = 0                            /* filler counter             */
   rec# = rec# + 1                     /* output record counter      */
   level =     "2"                     /* initialize record level    */
   nextrec = "bypass"
   recid = "R" || seq || right(rec#,2,'0')
   outrec = "0DCL 1 "recid","
   queue outrec                        /* output DCL statement       */
 
   vname = recid"_CC"
   vtype = "CHAR(01)"
   vinit = "INIT('"carriage"'),"
   outrec = left(" " ,  6    ) ||,              /* build output rec  */
            left(level, 2,' ') ||,
            left(vname,22,' ') ||,
            left(vtype,18,' ') ||,
            left(vinit,22,' ')
   queue outrec                        /* output carriage control    */
 
   do j = 1 to number_of_segments      /* for each segment of line   */
      if j = number_of_segments then
         terminate = ";"               /* end of Declare             */
      else
         terminate = ","               /* continuation               */
 
      select
         when substr(text.j,1,1) = '?' then do  /* character type    */
            v# = v# + 1                         /* increment vcount  */
 
            if length(text.j) < 100 then        /* how many bytes ?  */
               vlen = right(length(text.j),2,'0') /* two digits      */
            else
               vlen = right(length(text.j),3)   /* three digits      */
 
            if @rid = "X" then,
               vname = recid"_"varname.v#       /* substitue var name*/
            else,                      /* no RECID prefix            */
               vname = varname.v#               /* substitue var name*/
 
            vtype = "CHAR("vlen")"              /* character type    */
            vinit = "INIT('')"terminate         /* initialize blanks */
            outrec = left(" "  , 6    ) ||,     /* build output rec  */
                     left(level, 2,' ') ||,     /* build output rec  */
                     left(vname,22,' ') ||,
                     left(vtype,18,' ') ||,
                     left(vinit,22,' ')
            queue outrec                        /* output statement  */
         end                                    /* end character type*/
 
         when substr(text.j,1,1) = '#' then do  /* numeric variable  */
            v# = v# + 1                         /* increment vcount  */
 
            if length(text.j) > 1 then          /* single digit ?    */
               text.j = translate(text.j,'Z','#') /* # -> Z          */
            else
               text.j = '9'                     /* single digit      */
 
            p# = pos('.',text.j)
            if p# > 0 then                      /* decimal point ?   */
               text.j = substr(text.j,1,p# - 1) ||,
                         "V." ||,               /* put decimal in PIC*/
                        substr(text.j,p# + 1)
 
            if length(text.j) > 1 then          /* more than single  */
               do
                  chr2 = substr(text.j,2,1)     /* any commas ?      */
                  if chr2 = ',' & length(text.j) > 2 then
                     chr2 = substr(text.j,3,1)
                  if chr2 = '9' | chr2 = '$' then /* 9's or $'s      */
                     text.j = overlay(chr2,text.j,1,1)
               end
 
            if @rid = "X" then,
               vname = recid"_"varname.v#       /* substitue var name*/
            else,                      /* no RECID prefix            */
               vname = varname.v#               /* substitue var name*/
 
            vtype = "PIC'"text.j"'"             /* numeric picture   */
            vinit = "INIT('')"terminate         /* initialize zero   */
            outrec = left(" "  , 6    ) ||,     /* build output rec  */
                     left(level, 2,' ') ||,     /* build output rec  */
                     left(vname,22,' ') ||,
                     left(vtype,18,' ') ||,
                     left(vinit,22,' ')
            queue outrec                        /* output statement  */
         end                                    /* end numeric type  */
 
         otherwise do                           /* literal text      */
            f# = f# + 1                         /* increment fcount  */
 
            if length(text.j) < 100 then        /* how many bytes ?  */
               flen = right(length(text.j),2,'0') /* two digits      */
            else
               flen = right(length(text.j),3)   /* three digits      */
 
            if @star = "X" then,
               fname = "*"
            else,
            if @rid = "X" then,
               fname = recid"_FIL"right(f#,2,'0') /* filler name     */
            else,                      /* no RECID prefix            */
               fname = "FIL"right(f#,2,'0')     /* filler name       */
 
            ftype = "CHAR("flen")"              /* filler length     */
            if verify(text.j,' ') = 0 then
               finit = "INIT('')"terminate      /* initialize blanks */
            else do
               if length(text.j) > 13 then do
                  char1 = substr(text.j,1,1)    /* init short literal*/
                  if verify(text.j,char1) = 0 then
                     finit = "INIT(("flen")'"char1"')"terminate
                  else do
                     finit = "INIT"             /* init long literal */
                     nextrec = "           ('"text.j"')"terminate
                  end
               end
               else                             /* init short literal*/
                  finit = "INIT('"text.j"')"terminate
            end
 
            outrec = left(" "  , 6    ) ||,     /* build output rec  */
                     left(level, 2,' ') ||,     /* build output rec  */
                     left(fname,22,' ') ||,
                     left(ftype,18,' ') ||,
                     left(finit,22,' ')
            queue outrec                        /* output statement  */
            if nextrec = "bypass" then
               nop
            else do
               outrec = nextrec        /* continued statement        */
               nextrec = "bypass"
               queue outrec            /* output continuation        */
            end
         end                           /* end literal type           */
      end                              /* end select                 */
   end                                 /* end do segments            */
 
return                                 /*@ BPD_GENERATE_PLI          */
/*
.  ----------------------------------------------------------------- */
BPE_GENERATE_COBOL:                    /*@ build COBOL data stmts    */
   if branch then call BRANCH
   address TSO
 
   j    = 0                            /* segment counter            */
   rec# = rec# + 1                     /* output record counter      */
   level = '           05'             /* initialize record level    */
   nextrec = "bypass"
   recid = "R" || seq || right(rec#,2,'0')
   outrec = "       01  "recid"."
   queue outrec                        /* output 01 level statement  */
   if carriage = " " then
      carriage = "SPACE"
   else
      carriage = "'"carriage"'"
   outrec = "           05 ",
            recid"-CC       PIC X(01)            VALUE "carriage"."
   queue outrec                        /* output carriage control    */
   do j = 1 to number_of_segments      /* for each segment of line   */
      select
         when substr(text.j,1,1) = '?' then do  /* character type    */
            v# = v# + 1                         /* increment vcount  */
            if length(text.j) < 100 then        /* how many bytes    */
               vlen = right(length(text.j),2,'0') /* two digits      */
            else
               vlen = right(length(text.j),3)   /* three digits      */
            vname = recid"-"varname.v#          /* substitute varname*/
            vtype = "PIC X("vlen")"             /* alpha picture     */
            vinit = "VALUE SPACES."             /* initialize spaces */
            outrec = left(level,15,' ') ||,     /* build output rec  */
                     left(vname,14,' ') ||,
                     left(vtype,21,' ') ||,
                     left(vinit,21,' ')
            queue outrec                        /* output statement  */
         end                                    /* end character type*/
                                                /*                   */
         when substr(text.j,1,1) = '#' then do  /* numeric type      */
            v# = v# + 1                         /* increment vcount  */
            if length(text.j) > 1 then          /* single digit ?    */
               text.j = translate(text.j,'Z','#') /* # -> Z          */
            else
               text.j = '9'                     /* single digit      */
            p# = pos('.',text.j)
            if p# > 0 then                      /* decimal point ?   */
               text.j = substr(text.j,1,p# - 1) ||,
                         "." ||,                /* put decimal in PIC*/
                        substr(text.j,p# + 1)
            if length(text.j) > 1 then          /* single digit ?    */
               do
                  chr2 = substr(text.j,2,1)     /* any commas ?      */
                  if chr2 = ',' & length(text.j) > 2 then
                     chr2 = substr(text.j,3,1)
                  if chr2 = '9' | chr2 = '$' then /* 9's or $'s      */
                     text.j = overlay(chr2,text.j,1,1)
               end
            vname = recid"-"varname.v#          /* substitute varname*/
            vtype = "PIC "text.j                /* numeric picture   */
            vinit = "VALUE ZEROES."             /* initialize zeroes */
            outrec = left(level,15,' ') ||,     /* builf output rec  */
                     left(vname,14,' ') ||,
                     left(vtype,21,' ') ||,
                     left(vinit,21,' ')
            queue outrec                        /* output statement  */
         end                                    /* end numeric type  */
         otherwise do                           /* literal text      */
            if length(text.j) < 100 then        /* how many bytes ?  */
               flen = right(length(text.j),2,'0') /* two digits      */
            else
               flen = right(length(text.j),3)   /* three digits      */
            fname = "FILLER"                    /* filler name       */
            ftype = "PIC X("flen")"             /* filler length     */
            if verify(text.j,' ') = 0 then
               finit = "VALUE SPACES."          /* initialize blanks */
            else do
               if length(text.j) > 12 then do
                  char1 = substr(text.j,1,1)    /* init short literal*/
                  if verify(text.j,char1) = 0 then
                     finit = "VALUE ALL '"char1"'." /* init ALL      */
                  else do
                     finit = "VALUE"            /* init long literal */
                     nextrec = "               '"text.j"'."
                  end
               end
               else
                  finit = "VALUE '"text.j"'."   /* init short literal*/
            end
            outrec = left(level,15,' ') ||,     /* builf output rec  */
                     left(fname,14,' ') ||,
                     left(ftype,21,' ') ||,
                     left(finit,21,' ')
            queue outrec                        /* output statement  */
            if nextrec = "bypass" then
               nop
            else do
               outrec = nextrec        /* continued statement        */
               nextrec = "bypass"
               queue outrec            /* output continuation        */
            end
         end                           /* end literal type           */
      end                              /* end select                 */
   end                                 /* end do segments            */
 
return                                 /*@ BPE_GENERATE_COBOL        */
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
C_Wrap_up:                             /*@ clean up and exit         */
   if branch then call BRANCH
   address TSO
 
   if sw.0proceed = "0" then return
 
   n = queued()                        /* number of records queued   */
   "EXECIO "n" DISKW OUTDD (FINIS"     /* write records to output    */
   "FREE FILE(OUTDD)"                  /* free output file           */
 
   address ISPEXEC
   ZERRSM = "Edit or exit"
   ZERRLM = "Edit the structures as required or PF3 to exit"
   ZERRALRM = "NO"
   "SETMSG MSG(ISRZ002)"
   "EDIT DATASET('"outdsn"')"           /* edit generated structures  */
 
return                                 /*@ C_Wrap_Up                 */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
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
say ""
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      processes a mock-up of a printable report and produces PLI"
say "                or COBOL record structures for inclusion in the program   "
say "                source.                                                   "
say "                                                                          "
say "                Fields specified as strings of '#' will be declared PIC.  "
say "                Fields specified as strings of '?' will be declared CHAR. "
say "                Literals will be declared CHAR and initialized            "
say "                appropriately.                                            "
say "                                                                          "
say "                At the bottom of the mock-up, provide the names of the    "
say "                data fields as:                                           "
say "                   ?VARS = ( list-of-names +                              "
say "                            continued-list )                              "
say "                                                                          "
say "                                                        more ....         "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK "
say "  Syntax:   "ex_nam"  <NORECID>                                           "
say "                      <LRECL nn>                                          "
say "                      <STARS>                                             "
say "                                                                          "
say "            NORECID   "exec_name" typically prefixes each data item to    "
say "                      indicate on which line it resides:  ex: 'RA01_DATE'."
say "                      To suppress this prefix, specify NORECID.  This may "
say "                      also be specified on the panel itself.              "
say "                                                                          "
say "            nn        specifies a record length for the report.  If not   "
say "                      specified, it defaults to 133.                      "
say "                                                                          "
say "            STARS     (PL/1 only) uses an asterisk (*) for all 'filler'   "
say "                      fields This may also be specified on the panel      "
say "                      itself.                                             "
say "                                                                          "
say "                                                        more ....         "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK "
say "   Debugging tools provided include:                                      "
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
/*
)))PLIB REPGEN01
)ATTR
 % TYPE(TEXT)     INTENS(HIGH) SKIP(ON)
 + TYPE(TEXT)     INTENS(LOW)  SKIP(ON)
 _ TYPE(INPUT)    INTENS(HIGH) CAPS(ON)
 # TYPE(OUTPUT)   INTENS(HIGH) SKIP(ON) CAPS(OFF)
)BODY SMSG(MESSAGE) LMSG(MESSAGE)
#MESSAGE
%REPGEN01                                                           %&ZDATESTD %
                         %Report Structure Generation               %&ZTIME  %
+Command  ===>_ZCMD                                                   +
 
+Report layout source:
+ISPF Library:
   +Project%===>_RGIHLI  +
   +Group  %===>_RGIGRP  +
   +Type   %===>_RGITYP  +
   +Member %===>_RGIMEM  +       +(Blank or pattern for member selection list)
 
+Other Partitioned or Sequential Dataset:
   +Data Set Name %===>_RGIDSN                                      +
+Generated Code Output:
+ISPF Library:             _Z+ Star fill
   +Project%===>_RGOHLI  + _Z+ RECID
   +Group  %===>_RGOGRP  +
   +Type   %===>_RGOTYP  +       +(Member will be same as source member)
+Other Partitioned or Sequential Dataset:
   +Data Set Name %===>_RGODSN                                      +
       +Language  %===>_Z    +    (PLI or COBOL)
       +Sequence  %===>_Z+        (Multiple reports within program)
)INIT
 .HELP = REPGENH1
 .ZVARS = '(@STAR @RID RGLANG RGSEQ)'
 &ZCMD = ' '
)PROC
 VER (&RGLANG, LIST,'PLI','COBOL')
 VER (&RGSEQ,NUM,MSG=RSGM001I)
 VPUT (RGIHLI RGIGRP RGITYP RGIDSN) PROFILE
 VPUT (RGOHLI RGOGRP RGOTYP RGODSN RGLANG) PROFILE
 VPUT (ZCMD RGIMEM RGSEQ) SHARED
)END
)))PLIB REPGENH1
%TUTORIAL --------------- REPORT STRUCTURE GENERATION ----------------- TUTORIAL
%OPTION  ===>_ZCMD                                                             +
+                        %---------------------------
                          :   GENERAL INFORMATION   :
                          ---------------------------
+
      Column 1 should contain the standard carriage control characters
                  '1' = new page
                  ' ' = skip 1 line
                  '0' = skip 2 lines
                  '-' = skip 3 lines
                 plus = skip 0 lines (for underscore etc)
 
      Any alphanumeric characters are assigned to headings, titles, general text
 
      ?????????? indicates a string variable, length equal to number of ?'s
 
      ###,##9.99- indicates a numeric variable with the appropriate picture
 
      ?VARS=(VAR1 VAR2 VAR3 VAR4) will substitute the variable names in sequence
      into the output record structures.
 
)PROC
)END
*/
