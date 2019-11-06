/* REXX    PLILBLS    Find all labels and display all occurrences of
              those labels.
 
           Impact Analysis
.          SYSEXEC  STRSORT
.          SYSEXEC  SEGMENT  (macro)
.          (alias)  ENTRIES
.          (alias)  ENC
 
     Modification History
     20040831 fxc fixed to work for the Enterprise Compiler;
 
*/
address ISREDIT
"MACRO (opts)"
address ISPEXEC "CONTROL ERRORS RETURN"
call A_INIT                            /*                           -*/
rc = Trace("O"); rc = Trace(tv)
 
call B_POSITION                        /*                           -*/
if sw.0mon then say lastline-topline+1 "lines to be examined."
 
firstornext = "FIRST"
do forever
   "F .SB .SE ':'" firstornext lbnd rbnd
   if rc > 0 then leave                /* not found                  */
   firstornext = "NEXT"
 
   "(text) = LINE" .zcsr
   parse var text =(lbnd) text =(rbnd) /* snip ASA char              */
   parse var text front ":" rest
   if Words(front) > 1 then iterate
 
   lbl = Strip(front)
   if Pos(Left(lbl,1),alfa) = 0 then iterate
   if Pos(Left(lbl,1),badchars) > 0 then iterate
   "(lx,lc) = CURSOR" ; currln = lx
 
   do while Pos(";",rest) = 0          /* find whole statement       */
      currln = currln + 1
      "(extra) = LINE" currln
      parse var extra =(lbnd) extra =(rbnd)
      rest = Space(rest extra,1)
   end                                 /* find whole statement       */
   upper rest                          /* shift to uppercase         */
   rest = Strip(rest)
   if sw.0ent & Left(rest,4) <> "PROC" then iterate
   upper lbl                           /* shift to uppercase         */
 
   if sw.0mon then say lbl
   lbllist  =  lbllist lbl             /* add to the list            */
   lx = lx + 0                         /* strip zeroes               */
   found_on_line.lbl = found_on_line.lbl lx
end                                    /* forever                    */
 
rc = Trace("O"); rc = Trace(tv)
/* ress ISPEXEC "VPUT (lbllist) PROFILE" */
 
if sw.0mon then say Words(lbllist) "labels"
 
"X ALL"
foundlbls = lbllist                    /* save a copy                */
 
do while lbllist <> ""
   rc = Trace("O"); rc = Trace(tv)
   parse var lbllist  lbl  lbllist
   if sw.0mon then say lbl
 
   loc = "FIRST"
   do forever
      "SEEK .SB .SE" loc lbl lbnd rbnd
      if rc > 0 then leave             /* didn't find                */
      "(xstat) = XSTATUS .zcsr"        /* X or NX ?                  */
      "XSTATUS .zcsr = NX"             /* show this line             */
      loc = "NEXT"
      "(thisline,col) = CURSOR"        /* where are we ?             */
      "(text) = LINE" thisline         /* acquire source line        */
      thisline = thisline + 0          /* strip zeroes               */
 
      if Wordpos(thisline,found_on_line.lbl) > 0 then do
         "XSTATUS .zcsr = NX"          /* show this line */
         "F ';'"
         "XSTATUS .zcsr = NX"          /* show this line */
         iterate                       /* keep 'found on' line       */
         end
 
      upper text                       /* shift to uppercase         */
      parse var text  =(lbnd) front (lbl) back =(rbnd)
      if Left(back,1) = "(" then do    /* function ref               */
         used_on_line.lbl = used_on_line.lbl thisline
         if sw.0noc then "XSTATUS .zcsr = (xstat)"
         iterate                       /* keep this function call    */
         end
 
      "CURSOR = .zcsr" rbnd            /* prevent reprocessing       */
      revfront = Reverse(front)
      parse var revfront  word1 word2 .
      if word1 = "OT" then,
         if word2 = "OG" then do
            used_on_line.lbl = used_on_line.lbl thisline
            if sw.0noc then "XSTATUS .zcsr =" xstat
            iterate                    /* keep 'GO TO'               */
            end
      if Wordpos(word1,Reverse("CALL GOTO LEAVE")) > 0 then do
         used_on_line.lbl = used_on_line.lbl thisline
         if sw.0noc then "XSTATUS .zcsr =" xstat
         iterate                       /* keep CALL GOTO LEAVE       */
         end
      if Wordpos(";DNE",revfront) > 0 |,
         Wordpos("DNE",revfront) > 0 then do
         end_on_line.lbl = end_on_line.lbl thisline
         iterate
         end
 
      "XSTATUS .zcsr =" xstat          /* maybe exclude this line    */
   end                                 /* forever                    */
end                                    /* lbllist                    */
 
foundlbls = STRSORT(foundlbls)         /* sort the labels            */
 
if sw.0rpt then,
do while foundlbls <> ""
   rc = Trace("O"); rc = Trace(tv)
   parse var foundlbls  lbl foundlbls  /* isolate                    */
 
   text = Left(lbl,24) "Found on" Strip(found_on_line.lbl)
 
   if end_on_line.lbl <> "" then,
      text = text " END on" Strip(end_on_line.lbl)
 
   if Length(text) > 70 then do
      do while Length(text) > 70
         lbpos = LastPos(" ",text,70)
         savedtxt = Substr(text,lbpos+1)
         text     = Left(text,lbpos)
         "LINE_BEFORE  .SB  = NOTELINE '"text"'"
         text     = Copies(" ",33) savedtxt
      end                              /* while length > 70          */
      end
   "LINE_BEFORE  .SB  = NOTELINE '"text"'"
 
   text = Left(" ",24) " Used on" Strip(used_on_line.lbl)
   if Length(text) > 70 then do
      do while Length(text) > 70
         lbpos = LastPos(" ",text,70)
         savedtxt = Substr(text,lbpos+1)
         text     = Left(text,lbpos)
         "LINE_BEFORE  .SB  = NOTELINE '"text"'"
         text     = Copies(" ",33) savedtxt
      end                              /* while length > 70          */
      end
   "LINE_BEFORE  .SB  = NOTELINE '"text"'"
 
end                                    /* foundlbls                  */
 
"CURSOR = .SB 1 "
exit                                   /*@ PLILBLS                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   address ISPEXEC
 
   parse source srcline
   parse var srcline  .  .  ex_nam  .  /* macro name                 */
 
   parse value "" with,
               end_on_line.  found_on_line.  used_on_line.,
               tv  lbllist .
   push opts; pull opts
   opts = Strip(opts,"T",")")
   if WordPos("?",opts) > 0 then call HELP /*                       -*/
 
   sw.0mon = Wordpos("MONITOR",opts) > 0
   sw.0rpt = Wordpos("REPORT" ,opts) > 0
   sw.0noc = Wordpos("NOCALLS",opts) > 0 |,
             Wordpos("ENC"    ,opts ex_nam) > 0
   sw.0ent = Wordpos("ENTRIES",opts ex_nam) > 0 |,
             Wordpos("ENC"    ,opts ex_nam) > 0
 
   parse var opts "TRACE" tv .
   parse value tv "O"   with  tv  .
 
   alfa = "ABCDEFGHIJKLMNOPQRSTUVWXYZ@$#%abcdefghijklmnopqrstuvwxyz"
   badchars = "=("
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_POSITION:                            /*@                           */
   address ISREDIT
 
   "F FIRST P'^'"
   "(text) = LINE" .zcsr
   if Left(text,5) = "15668" then,     /* compiler listing           */
      do
      "SEGMENT LABELS"
      address ISPEXEC "VGET LBLLIST SHARED"
      parse var lbllist ".SRC" src_start . src_end .
      "LABEL" src_start "= .SB"
      "LABEL" src_end   "= .SE"
      lastline = src_end
      "(lastline,lc) = CURSOR"
      lbnd = 19                        /* left boundary              */
      rbnd = lbnd + 71
      end                              /* compiler listing           */
   else,
   if Left(text,5) = "15655" then,     /* compiler listing           */
      do
      "SEGMENT LABELS"
      address ISPEXEC "VGET LBLLIST SHARED"
      parse var lbllist ".SRC" src_start . src_end .
      "LABEL" src_start "= .SB"
      "LABEL" src_end   "= .SE"
      lastline = src_end
      lbnd = 33                        /* left boundary              */
      rbnd = lbnd + 70
      lbllist = ""
      end                              /* compiler listing           */
   else do                             /* source code                */
      "LABEL .zcsr = .SB"
      "(topline,lc) = CURSOR"
      "F p'^' LAST"                    /* locate last line           */
      "LABEL .zcsr = .SE"
      "(lastline,lc) = CURSOR"
      lbnd = 2                         /* left boundary              */
      rbnd = lbnd + 71
      end                              /* source code                */
 
return                                 /*@ B_POSITION                */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
 
ex_nam = Left("PLILBLS",8)             /* predictable size           */
 
say "  "ex_nam"      displays all the labels in a PL/I program.  Options can   "
say "                be used to restrict the display to classes of usage.      "
say "                                                                          "
say "  Syntax:   "ex_nam"  <MONITOR>                                           "
say "                      <REPORT>                                            "
say "                      <NOCALLS>                                           "
say "                      <TRACE tv>                                          "
say "                                                                          "
say "            MONITOR   displays key information throughout processing.     "
say "                                                                          "
say "            REPORT    places a summary report of where-found/where-used   "
say "                      at the top of the source.                           "
say "                                                                          "
say "            NOCALLS   excludes the invocation points and shows only the   "
say "                      target labels.                                      "
say "                                                                          "
say "            ENTRIES   excludes ordinary labels; shows only PROCEDURE      "
say "                      entry points.                                       "
say "                                                                          "
say "            TRACE tv  will use the value following TRACE to place         "
say "                      the execution in REXX TRACE Mode.                   "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
