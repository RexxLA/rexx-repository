/* REXX    EN         Insert the exec name into the REXXSKEL header
 
           Written by Chris Lewis 19970813
 
     Modification History
     971028 ctl Add exec name into a comment on the mainline exit
                statement.
     971107 fxc account for YAT in exit-line-comment;
 
*/
address ISREDIT
"MACRO (PARMS) NOPROCESS"
parse upper var parms parms "((" opts
 
parse var opts "TRACE" tv .
parse value tv "O"  with tv .
rc = trace(tv)
 
justname = parms <> ""                 /* bypass footer if true      */
 
"(lp,cp) = CURSOR"                     /* Line and column position   */
"(mem)   = MEMBER"                     /* Member name                */
 
call A_HEADER                          /*                           -*/
 
if justname then nop
else
   call B_FOOTER                       /*                           -*/
 
"CURSOR = "lp cp                       /* return cursor to original  */
                                       /* location                   */
exit
 
/* ----------------------------------------------------------------- */
A_HEADER:                              /*@                           */
/*
   Insert the name of the member into a REXXSKEL header line.
*/
   address ISREDIT
 
   cnum = 1                            /* only concerned with topline*/
 
   "(data) = LINE" cnum                /* contents of line 1         */
 
   parse var data "REXX" oldmem text
   newline = "'/* REXX    "left(mem,8)"   "strip(text)"'"
   data = "'"data"'"
 
   "LINE_AFTER" cnum" = DATALINE" newline /* insert into document    */
   "LINE_AFTER" cnum + 1 " = NOTELINE" data /* display as a note     */
 
   "DELETE" cnum cnum                  /* delete original data       */
 
return                                 /*@ A_HEADER                  */
/*
   Insert the name of the member into a comment on the mainline
   exit statement.
.  ----------------------------------------------------------------- */
B_FOOTER:                              /*@                           */
   address ISREDIT
 
   parse value '615C7C'X  '5C61'X   with,/* hex values of opening &    */
                opcom      clcom   .     /* closing comment markers    */
 
   template = copies(" ",39)
 
   "FIND 'exit' 1 FIRST"               /* find 1st exit in column 1  */
   if rc <> 0 then return              /* none found                 */
 
   "(cnum) = LINENUM" .zcsr            /* line number of cursor      */
   "(data) = LINE" cnum                /* contents of line           */
                                       /* find existing comments     */
   parse var data front (opcom) text (clcom) back
 
   if Strip(text) =  mem then return        /* comment already there */
 
   front   = strip(front)
   back    = strip(back)
   newline = "'"overlay(front,template)||opcom left(mem,26)||clcom back"'"
   data    = "'"strip(data)"'"
 
   "LINE_AFTER" cnum" = DATALINE" newline /* insert into document    */
   "LINE_AFTER" cnum + 1 " = NOTELINE" data /* display as a note     */
 
   "DELETE" cnum cnum                  /* delete original data       */
 
return                                 /*@ B_FOOTER                  */
 
