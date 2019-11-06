/* REXX     STRCHART     builds an indented structure
                         chart for COBOL source
 
       Requires:  EXEC(STRUCT)
                  Requires:  EXEC(PGFS)
*/
total = 0
address ISREDIT
"macro (opts)"                         /* I'm a macro                */
if opts = ?  then call HELP
if opts = "" then call HELP
opts = " "Translate(opts)
 
parse upper var opts . " TRACE " tv .  /* trace requested ?          */
if tv <> "" then do
   rc = Trace(tv)
   where = WordPos("TRACE",opts)
   opts = DelWord(opts,where,2)
   end
parse value tv "O" with tv .
parse upper var opts . " INDENT " incr .  /* indention               */
if incr = "" then incr = 8
else do
   where = WordPos("INDENT",opts)
   opts = DelWord(opts,where,2)
   end
parse upper var opts . " TO " outdsn . /* output destination         */
   where = WordPos("TO",opts)
   opts = DelWord(opts,where,2)
 
diagnose = WordPos("DIAGNOSE",opts)>0
if diagnose then do
   where = WordPos("DIAGNOSE",opts)
   opts = DelWord(opts,where,1)
   end
if opts <> "" then,
   say "Unrecognized parameters:" opts
 
"RESET"
"F 'PROGRAM-ID.' FIRST"
"(text) = LINE .zcsr"
parse var text "PROGRAM-ID." pgmid .
parse var pgmid pgmid "."
"(n1,n2) = NUMBER"                     /* query number mode          */
if n1 = "ON" &,
   Word(n2,2) = "COBOL" then bump = 0
                        else bump = 6
one   = 1 + bump
two   = 2 + bump
 
ref. = 0                               /* clear array                */
section = 1                            /* mainline                   */
ref.section. = 0
tgt = 0
 
"STRUCT"                               /* front-end work             */
address ISPEXEC "VGET CALLLIST"
address ISPEXEC "VERASE CALLLIST BOTH"
 
if calllist  = "<EMPTY>" then,
   calllist = ""
 
"F ' ' FIRST NX"                       /* first line                 */
"(line) = LINE .zcsr"
line = Substr(line,one)
parse var line word1 word2 .
if word1 = "PERFORM" |,
   word1 = "CALL" then do
   ref.1 = "< unnamed >"               /* mainline has no pgf-name   */
   end
else do
   ref.1 = Word(line,1)                /* the mainline routine       */
   parse var ref.1 ref.1 "."
   "F ' ' NEXT NX" one
   end
if diagnose then say "1" ref.1
 
do while rc = 0
 
   "(line) = LINE .zcsr"               /* seize the text             */
   line = Substr(line,one)
   parse var line word1 word2 .        /* parse                      */
   if word1 = "PERFORM" then do
      tgt = tgt + 1                    /* next target                */
      parse var word2 word2 "."        /* clip off period            */
      ref.section.tgt = word2          /* load to array              */
      if diagnose then say section"."tgt ref.section.tgt
      end
   else                                /* it"s a label               */
   if word1 = "CALL" then do
      tgt = tgt + 1                    /* next target                */
      parse var word2 word2 "."        /* clip off period            */
      ref.section.tgt = word2          /* load to array              */
      if diagnose then say section"."tgt ref.section.tgt
      if WordPos(word2,calllist) = 0 then,
         calllist = calllist word2     /* add it to the calllist     */
      end
   else do                             /* it's a label               */
      ref.section.0 = tgt              /* how many in last section ? */
      section = section + 1            /* next section               */
      ref.section. = 0                 /* clear                      */
      parse var word1 word1 "."
      ref.section  = word1             /* section name               */
/*    say word1                                                      */
      tgt = 0
      end
   "F ' '   NEXT NX" one
end /* while */
 
/* add each call-list entry as its own section                       */
do i = 1 to Words(calllist)
   ref.section.0 = tgt                 /* how many in last section ? */
   section = section + 1               /* next section               */
   ref.section. = 0                    /* clear                      */
   ref.section  = Word(calllist,i)     /* section name               */
/* say Word(calllist,i)                                              */
   tgt = 0
end
 
ref.section.0 = tgt                    /* how many in last section ? */
ref.0         = section                /* how many pgf-names ?       */
 
/*----------------------- the list is ready ------------------*/
if diagnose then,
do i = 1 to ref.0
/* say ref.i                                                         */
   do j = 1 to ref.i.0
/*    say "****" ref.i.j                                             */
   end /* j */
end /* i */
 
rc = Trace("O"); rc = Trace(tv)
address TSO
"ALLOC FI(LIST) DA("outdsn") SHR REU"
if rc ^= 0 then do
   "ALLOC FI(LIST) DA("outdsn") NEW REU CATALOG UNIT(SYSDA) ",
       "SPACE(1 1) TRACKS RECFM(V B) LRECL(255) BLKSIZE(0)"
   if rc ^= 0 then do
      "CLEAR"
      say "File LIST would not allocate"
      exit
      end
   end
 
queue "       "
queue "Structure Chart for" pgmid
queue "       "
slug = Copies(".",incr)                /* standard leader            */
queue ref.1                            /* mainline pgf-name          */
do j = 1 to ref.0                      /* each section               */
do i = 1 to ref.j.0                    /* for each ref in mainline   */
   leader = slug                       /* set leader                 */
   tgt = ref.j.i
   queue leader tgt                    /* output                     */
   call NEXT                           /* get sub-refs               */
end
end
 
rc = Trace("O"); rc = Trace(tv)
 
"EXECIO" queued() "DISKW LIST (FINIS"  /* write the queue            */
"DROPBUF"
address ISREDIT
"L 000000"
exit
/*------------------- Subroutines ------------------------*/
HELP:
address TSO "CLEAR"
say "                                                                  "
say "STRCHART         Builds a structure chart for a COBOL program.    "
say "                                                                  "
say "Syntax:          STRCHART   <options>                             "
say "                                                                  "
say "                 <options> may be any combination of:             "
say "                    TO <output-specification>                     "
say "                        (no default -- required)                  "
say "                    INDENT <indentation-amount>                   "
say "                        (default is 8)                            "
say "                                                                  "
pull                                   /* get a response before exit */
exit                                   /* HELP                       */
 
NEXT: Procedure expose ref. tgt slug leader total
   sav_ldr = leader                    /* so we can restore it later */
   leader  = leader||slug              /* make longer                */
 
   do j = 1 to ref.0   while tgt <> ref.j
   end                                 /* find a match               */
   if j > ref.0 then do
      say tgt "not found"
      ref.0 = j
      ref.j = tgt
      ref.j. = 0
      say tgt "Added as entry" j
      end
                /* j points to the current label */
                /* <leader> indicates how deep is the nest */
   old_tgt = ""
   do k = 1 to ref.j.0                 /* for each sub-ref           */
      tgt = ref.j.k                    /* data for next NEXT         */
      if old_tgt ^= tgt then do
         queue leader tgt              /* output                     */
         call NEXT                     /* go deeper                  */
         old_tgt = tgt
         end
   end
   if queued() > 499 then do
      currstk = queued()
      "EXECIO" queued() "DISKW LIST"   /* write the queue            */
      total = total + currstk
      say "Total lines written =" total
      end
 
   leader  = sav_ldr                   /* restore Leader             */
return                                 /* NEXT                       */
/* END of STRCHART ---------------- */

/* BEGINNING of STRUCT ------------ */
/* REXX    STRUCT       show the innate structure of a COBOL program
 
           Requires:  EXEC(PGFS)
*/
address ISREDIT
"macro (opts)"                         /* I"m a macro                */
"(nested) = MACRO_LEVEL"
nested = nested > 1
"RESET"                                /* show all lines             */
"PGFS  NOSLASH"                        /* perf PGFS macro            */
address ISPEXEC "VGET   PGFSLIST"
address ISPEXEC "VERASE PGFSLIST"
"F all ' perform '  .b .zl "
"F all ' call '     .b .zl "
"x all '*' 1 "
lastpgf = "" ; current_pgf = ""
calllist = ""
 
tv=""
parse upper var opts "TRACE" tv .
if tv<>"" then interpret "TRACE" tv
 
"F ' ' nx first"                       /* first shown line           */
do while rc = 0
   "(TEXT) = LINE  .zcsr"              /* seize the line             */
   if Word(text,1) = "PERFORM" then do
      label = Word(text,2)             /* PERFORM what ?             */
      parse var label label "."
      if label ^= "" then,
      if WordPos(label,pgfslist) > 0 then do
         parse var label target "-" .  /* get sequence #             */
         if target < current_pgf then
            "LINE_BEFORE .zcsr = NOTELINE 'Sequence Error'"
         end
      else "EXCLUDE ' ' .zcsr .zcsr"   /* not interested...          */
      end
   else, 
   if Word(text,1) = "CALL"    then do
      label = Word(text,2)             /*    CALL what ?             */
      parse var label label "."
      if label ^= "" then,
      if WordPos(label,calllist) = 0 then,
         calllist = calllist label     /* add it to the calllist     */
      else "EXCLUDE ' ' .zcsr .zcsr"   /* not interested...          */
      end
   else, 
      if Substr(text,2,1) = " " then,
           "EXCLUDE ' ' .zcsr .zcsr"   /* not interested...          */
   else do                             /* it's a label               */
      label = Word(text,1)             /* the label is first         */
      parse var label current_pgf "-" ./* label sequence #           */
      if lastpgf > current_pgf then
         "LINE_BEFORE .zcsr = NOTELINE 'Sequence Error'"
      lastpgf = current_pgf
      end
   "FIND ' ' 1 nx next"                /* next shown line            */
end /* while rc = 0 */
 
"L 000000"                             /* TOP                        */
"L special"                            /* first 'special' line       */
 
trace o
if tv<>"" then interpret "TRACE" tv
if calllist = "" then,
   calllist = "<empty>"
 
if nested then,
   address ISPEXEC "VPUT CALLLIST"
exit
/* END of STRUCT   ---------------- */

/* BEGINNING of PGFS  ------------- */
/* REXX  PGFS      show all COBOL paragraph names
 
         Syntax: PGFS <noexit> <noslash>
                      <noexit> "exclude any paragraph exits"
                      <noslash> "don't show associated page-ejects"
 
*/
address ISREDIT
"macro (opts)"                         /* I'm a macro                */
"(nested) = MACRO_LEVEL"
nested = nested > 1
parse upper var opts opts              /* translate to upper case    */
tv=""
parse var opts . "TRACE" tv .
if tv<>"" then interpret "TRACE" tv
noexit=0; slash=1                      /* ensure values              */
do i = 1 to Words(opts)                /* check for options          */
   if Abbrev("NOEXIT" ,Word(opts,i),3) then noexit = 1
   if Abbrev("NOSLASH",Word(opts,i),3) then slash  = 0
end
"(dw) = DATA_WIDTH"                    /* numbered ?                 */
if dw = 74 then bump = 0               /*  --yes                     */
           else bump = 6               /*  --no                      */
one = 1 + bump
two = 2 + bump
four = 4 + bump
 
"RESET"
"LABEL 1  = .A 0"                      /* top line                   */
"F 'PROCEDURE DIVISION'"
"F '.'"                                /* end of statement           */
"LABEL .ZCSR = .B 0"
"X ALL .A .B"                          /* exclude the top section    */
"X ALL '     '" one
"X ALL '*'" one                        /* comments                   */
"X ALL '++' PREFIX"                    /* PanValet statements        */
 
if noexit then do
   "X ALL '-end.'"                     /* drop "end"s                */
   "X ALL '-exit.'"                    /* drop "exit"s               */
   end
 
if ^slash then,
   "X all '/'" one                     /* drop any slashes           */
 
if nested then do                      /* called by another routine  */
   pgfslist = ""                       /* init                       */
   "F ' ' FIRST NX" one                /* first non-slash            */
   do while rc = 0
      "(text) = LINE .zcsr"            /* seize the tex              */
      parse var text  pgfnm"."         /* all before the period      */
      parse var pgfnm pgfnm .          /* first word only            */
      pgfslist = pgfslist pgfnm        /* add to list                */
      "F ' ' NEXT  NX" one             /* get next                   */
   end                                 /* rc = 0                     */
   if pgfslist = "" then,              /* no paragraph names ?       */
      pgfslist = "<empty>"             /* force a value              */
   address ISPEXEC "VPUT PGFSLIST"     /* put in the variable pool   */
   end
else "CURSOR = "1 0                    /* cursor to the top          */
exit
/* END of PGFS     ---------------- */