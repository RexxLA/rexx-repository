/* REXX    PLIFLOW       Show the operational structure of a PL/I
                         program.
*/
address ISREDIT
"MACRO (opts)"
upper opts
parse var opts "TRACE" tv .
parse value tv "N" with tv .
rc = Trace("O"); rc = Trace(tv)
monitor = Wordpos("MONITOR",opts) > 0  /*                            */
 
call A_INIT                            /*                           -*/
"F P'^' 73 80"                         /* in the sequence field      */
if rc = 0 then do
   "RENUM"
   "UNNUM"
   end                                 /* clear the sequence area    */
"(dtachg) = DATA_CHANGED"
if dtachg = "YES" then do
   "AUTOSAVE PROMPT"
   zerrsm = "Data changed"
   zerrlm = "A RENUM+UNNUM command altered the data.  If saved,",
            "stats will be refreshed."
   zerrhm = "ISR00000"
   zerralrm = "YES"
   address ISPEXEC "SETMSG MSG(ISRZ002)"
   end
"RESET"
 
do ii = 1 to lastline                  /* find all the PROCs         */
   "(text) = LINE" ii                  /* get the text               */
   if text = "" then iterate
   if Pos(":",text) > 0 then do
      parse var text front ":" back
      If Pos("PROC",back) = 0 then iterate     /* not a PROC stmt    */
      if Right(Word(text,1) ,1) <> ":" then,   /* separated colon    */
      if Words(front) = 1 then do              /* presumed LABEL     */
         text = Strip(front,"T")":" back
/*       "LINE" ii "= (text)" */
         end
      end
   if Right(Word(text,1) ,1) = ":" then do
      parse var text   label ":" .     /* must be 1st word...        */
      push  label; pull label .
      if Verify(label,symbolset) > 0 then iterate  /* not a label    */
      if monitor then say,             /*                            */
         "Label" label "found in >>"Strip(text)"<<"
      if Wordpos(label,sublist) = 0 then do
         sublist = sublist Word(text,1)    /* add to list of subrtns */
         if monitor then say Word(text,1) ii
         end                           /* label not in sublist       */
      end                              /* 1st word ends with colon   */
end                                    /* ii                         */
sublist = Translate( sublist , "" , ":" )
/* sublist is all the labels */
if monitor then do; say "All the labels:"; say sublist; end
 
rc = trace('o'); if tv ^= '' then rc = trace(tv)
 
"X ALL"
sublist = STRSORT(sublist)             /* sort labels                */
upper sublist                          /* all uppercase              */
do ii = 1 to Words(sublist)            /* for every subroutine       */
   subr = Word(sublist,ii)             /* isolate                    */
   loc = "FIRST"
   do forever
      "F" subr "WORD" loc
      loc = "NEXT"
      if rc > 0 then leave
      found = 0
      "(text) = LINE .zcsr"
      upper text                       /* all uppercase              */
      do while Pos(subr,text) > 0
         parse var text front (subr) back
         sepr = Left(Space(back,0),1)  /* first non-blank following  */
         if Pos(sepr,"(*:;") > 0 then found = '1'
         else do
            front   = Reverse(front)
            found   = Wordpos("LLAC",front) = 1
            end                     /* sepr ^= banana             */
         if found then text = ""       /* halt the loop              */
                  else text = back     /* do it again                */
      end                              /* Pos(subr                   */
      if \found then "XSTATUS .zcsr = X"
   end
end                                    /* ii                         */
 
"CURSOR =  1 1 "                       /* Top                        */
 
exit                                   /*@ PLIFLOW                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
 
   parse value "" with ,
         sublist ,
         .
   symbolset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#_$›.!?"
   "(lastline) = LINENUM .zl"          /* bottom                     */
   push     '61'x    '5c'x    '6b'x     '7d'x     '7f'x       '4d'x
   pull     slash    star     comma     singleq   doubleq     bananal
 
return                                 /*@ A_INIT                    */
