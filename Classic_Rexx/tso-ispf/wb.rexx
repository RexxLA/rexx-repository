/* REXX    WB         Fill in the Written By ..... in REXXSKEL with user
                      name and date.
 
           Written by Chris Lewis 19970811
 
     Modification History
     yymmdd xxx .....
                ....
 
*/
address ISREDIT
"MACRO (PARMS) NOPROCESS"
 
"FIND 'WRITTEN BY' FIRST"              /* Find 1st occurrence        */
if rc <> 0 then exit                   /* not found, adios           */
 
"(data) = LINE .zcsr"                  /* contents of line .zcsr     */
"(cnum) = LINENUM" .zcsr               /* Line number of cursor      */
 
data    = "'"data"'"                   /* save current data          */
chgval  = WBNAME() date("S")           /* new info                  -*/
newline = "'           Written by" chgval"'"
 
"LINE_AFTER" cnum" = DATALINE" newline /* insert into document       */
"LINE_AFTER" cnum + 1 " = NOTELINE" data /* display as a note        */
 
"DELETE" cnum cnum                     /* delete original data       */
 
exit
