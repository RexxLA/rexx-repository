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
