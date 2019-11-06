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
