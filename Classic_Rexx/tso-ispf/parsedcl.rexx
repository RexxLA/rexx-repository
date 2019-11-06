/* REXX    PARSEDCL   Annotates a PL/1 DCL with information about
                      column-locations for each field.
           The process is:
               -- acquire the text of the DCL
               -- isolate each element/groupspec
               -- pass to ELEMLEN for the length calculation
             -- when finished:
               -- roll lengths up to parent-levels
               -- annotate each line with location information
 
           Written by Frank Clarke 20010914
 
     Impact Analysis
.    SYSPROC   ELEMLEN
.    SYSPROC   TRAPOUT
 
     Modification History
     ccyymmdd xxx .....
                  ....
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010802      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
call B_GET_TEXT                        /*                           -*/
call C_DO_ELEMENT                      /*                           -*/
                                    if sw.0error_found then return
call D_ROLL_UP                         /*                           -*/
call E_ANNOTATE                        /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ PARSEDCL                  */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value "1      1   0 0 0 0 0 0 0 0 0 0"  with,
                start  array_depth.   length.  ,
                efflvl.   start.   end.   depth.     totlen.   ,
                fillseq  ,
                .
 
   parse value ""  with,
               group_list ,            /* fq name list               */
               parent_q ,              /* lvl # in DCL               */
               elemdata  ,             /* declared name/type/len     */
               delim_q ,               /*                            */
               parent.  ,              /*                            */
               parent_id  ,            /*                            */
               parent_name,            /*                            */
               spec ,                  /* data for ELEMLEN           */
               text ,                  /* workarea                   */
               .
 
   parse var info source .
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_GET_TEXT:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   "ALLOC FI($DCL) DA("source") SHR REU"
   "EXECIO * DISKR $DCL (FINIS"        /* load the queue             */
   "FREE  FI($DCL)"
 
return                                 /*@ B_GET_TEXT                */
/*
   Isolate each "line" of the DCL and pass to ELEMLEN.
   A "line" may span lines or be fragmentary.
.  ----------------------------------------------------------------- */
C_DO_ELEMENT:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   do while queued() > 0               /* re-evaluate every time     */
      pull   line 73                   /* shift to uppercase         */
      text = text Strip(Substr(line,2))
      if Word(text,1) = "DCL" then
         text = Delword(text,1,1)      /* snip                       */
 
      call CA_ISOLATE_STMT             /*                           -*/
 
   end                                 /* queued                     */
 
return                                 /*@ C_DO_ELEMENT              */
/*
   Find a comma or semicolon at the end of the statement.  Isolate
   this fragment of text and pass it to ELEMLEN.
.  ----------------------------------------------------------------- */
CA_ISOLATE_STMT:                       /*@                           */
   if branch then call BRANCH
   address TSO
 
   pt = 0                              /* pointer                    */
   do forever
      if pt >= Length(text) then do    /* end of our rope            */
         if queued() > 0 then,
            pull line 73               /* shift to uppercase         */
         else do;sw.0boom=1;leave;end
         pt = length(text)
         text = text Strip(Substr(line,2))
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
      if Substr(text,pt,2) = "615c"x then do /* slash-asterisk */
         pt2 = Pos('5c61'x,text)       /* asterisk-slash             */
         do while pt2 = 0              /* find the end               */
            if queued() > 0 then,      /* get some more text         */
               pull line 73            /* shift to uppercase         */
            else do;sw.0boom=1;leave;end
            text = text Strip(Substr(line,2))
            pt2 = Pos('5c61'x,text)    /* asterisk-slash             */
         end                           /* while                      */
         if sw.0boom then leave
         text = Delstr(text,pt,pt2-pt+2)
         end                           /* it was a comment           */
 
   end                                 /* forever                    */
 
   if sw.0boom then do
      "CLEAR" ; say "Premature end-of-text"
      sw.0error_found = '1'
      return
      end
 
   parse var text         spec =(pt) . +1  text
   "NEWSTACK"
   "ELEMLEN" spec                      /*                           -*/
   pull ans
   call CAA_ANALYZE_RESPONSE ans       /*                           -*/
   "DELSTACK"
 
return                                 /*@ CA_ISOLATE_STMT           */
/*
   What did ELEMLEN say?  What level is this element at?  Group or
   data?  How long?  How deep?
   The response from ELEMLEN contains these elements:
        #  name  çvariesŸ  Length ##  Depth ##  Total ##
                  -or-
        #  name  çvariesŸ  Group of ##
   In particular, çnameŸ may contain parentheses if it is an array,
   or the arrayspec might be part of çvariesŸ.  In either case, the
   "Depth" value or the "Group" value is equivalent to any arrayspec
   present.
 
   The "key" of all this data must be the fully-qualified name of any
   element or group to guard against a duplicate element-name in
   different sub-structures.
.  ----------------------------------------------------------------- */
CAA_ANALYZE_RESPONSE:                  /*@                           */
   if branch then call BRANCH
   address TSO
 
   arg elemresp                        /* response from ELEMLEN      */
   parse var elemresp    level name rest
 
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
 
   if Pos("GROUP OF",rest) then do     /* non-data group             */
      parse var rest   rest  "GROUP OF" depth .
      depth.fq_name = depth
      end
 
   if Pos("LENGTH"  ,rest) > 0 then do /* data item                  */
      parse var rest  rest  "LENGTH" datalen . "DEPTH" depth . ,
                            "TOTAL" totlen  .
      depth.fq_name  = depth
      length.fq_name = datalen
      totlen.fq_name = totlen
      end
 
   elemdata.fq_name = name rest
   start.fq_name    = start
   start            = start + length.fq_name     /* may be zero      */
   end.fq_name      = start - 1
 
return                                 /*@ CAA_ANALYZE_RESPONSE      */
/*
   All rows have been analyzed.  Begin at the bottom and work up,
   accumulating lengths and annotating non-data group items.
.  ----------------------------------------------------------------- */
D_ROLL_UP:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
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
   end                                 /* dx                         */
 
return                                 /*@ D_ROLL_UP                 */
/*
   From the top down, starting at presumed position 1, calculate
   end position as çstart + length - 1Ÿ.  The start position is the
   most recent start position of the next superior level.
.  ----------------------------------------------------------------- */
E_ANNOTATE:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   do ex = Words(group_list) to 1 by -1
      fq_name = Word(group_list,ex)    /* isolate                    */
      dcl_lvl = Word(parent_q  ,ex)    /* isolate                    */
      eff_lvl = Words(Translate(fq_name,' ','.'))
      say Copies(' ',eff_lvl)""dcl_lvl elemdata.fq_name ,
          "L="totlen.fq_name ,
          "St="start.eff_lvl ,
          "End="start.eff_lvl + tot_len.fq_name - 1
   end                                 /* ex                         */
 
return                                 /*@ E_ANNOTATE                */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
             /* The following template may be used to
                customize HELP-text for this routine.
say "  "ex_nam"      ........                                               "
say "                ........                                               "
say "                                                                       "
say "  Syntax:   "ex_nam"  ..........                                       "
say "                      ..........                                       "
say "                                                                       "
say "            ....      ..........                                       "
say "                      ..........                                       "
say "                                                                       "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK                                      "
say "   Debugging tools provided include:                                   "
say "                                                                       "
say "        MONITOR:  displays key information throughout processing.      "
say "                                                                       "
say "        NOUPDT:   by-pass all update logic.                            "
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
                                                                    .*/
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/* ----------------- REXXSKEL back-end removed --------------------- */
