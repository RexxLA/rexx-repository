/* REXX
*/
address ISREDIT
'macro (opts)'
push opts; pull opts                   /* shift to uppercase         */
push "0"                               /* init value                 */
pull monitor  sublist  tv
 
tp = Wordpos("TRACE",opts)
if tp > 0 then do; tv = Word(opts,tp+1); opts = Delword(opts,tp,2); end
if tv ^= '' then rc = trace(tv)
leave = Wordpos("LEAVE",opts)>0
 
"X ALL"
"(lastline) = LINENUM .zlast"          /*                            */
 
do ii = 1 to lastline                  /*                            */
   "(text) = LINE" ii                  /* get the text               */
   if text = "" then iterate
   if Right(Word(text,1) ,1) = ":" then do
      parse var text label ":" .       /* must be 1st word...        */
      if label = "HELP" |,             /*                            */
         label = "LOCAL_PREINIT" then leave ii
      if Wordpos(label,sublist) = 0 then do
         sublist = sublist label       /* put in list of subroutines */
         if monitor then say Word(text,1) ii
         end                           /* label not in sublist       */
      end                              /* 1st word ends with colon   */
end                                    /* ii                         */
/* sublist is all the labels */
 
rc = trace('o'); if tv ^= '' then rc = trace(tv)
push     '61'x    '5c'x    '6b'x     '7d'x     '7f'x       '4d'x
pull     slash    star     comma     singleq   doubleq     bananal
 
"X ALL"                                /*                            */
do ii = 1 to Words(sublist)            /* for every subroutine       */
   subr = Word(sublist,ii)             /*                            */
   call_found = '0'                    /*                            */
   "F" subr "WORD FIRST"               /*                            */
   do while rc=0 & ^call_found         /*                            */
      "(text) = LINE .zcsr"            /*                            */
      push text; pull text             /* shift to uppercase         */
      do while Pos(subr,text) > 0  & ^call_found
         parse upper var text front (subr) back
         sepr = Left(back,1)           /* char immed following subr  */
         if sepr = bananal then call_found = '1'
         else do                       /*                            */
            front = Reverse(front)     /*                            */
            call_found = Wordpos("LLAC",front) = 1,
                       | Wordpos("LANGIS",front) = 1,
                       | Wordpos("NO LANGIS",front) = 1
            end                        /* sepr ^= banana             */
         text = back                   /*                            */
      end                              /* Wordpos(subr               */
 
      if ^call_found then,             /*                            */
         "F" subr "WORD"               /*                            */
   end                                 /* while                      */
 
   if rc=4 then do                     /*                            */
      "X ALL WORD" subr                /*                            */
      "F" subr "FIRST WORD"            /*                            */
      "LINE_BEFORE .zcsr = NOTELINE 'The following subroutine",
                          "is not otherwise referenced:'"
      end                              /* rc=4                       */
   else,
   if call_found & ^leave then "X ALL" subr "WORD"
 
end                                    /* ii                         */
 
exit
