/* REXX    SELMATCH    Set any )ENDSEL statements with the shown
                       condition from the matching )SEL.
*/
address ISREDIT
"MACRO (opts)"
upper opts
parse var opts "TRACE" tv .
parse value tv "N" with tv .
rc = Trace(tv)
 
"X ALL"
"F ALL ')SEL' 1"
"F ALL ')ENDSEL' 1"
next1st = "FIRST"                      /* First or Next              */
 
do forever
   "F NX ')ENDSEL'" next1st            /* next shown )endsel         */
   if rc > 0 then leave
   next1st = "NEXT"                    /* First or Next              */
   "(el ec) = CURSOR"                  /* what line?                 */
   "F NX ')SEL' 1 PREV"                /* prev )sel                  */
   "(seltext) = LINE .zcsr"            /* carpe textem               */
   parse var seltext ")SEL" cond 73
   cond = Strip(cond)
   seltext = ")SEL   " cond
   endtext = ")ENDSEL" cond
   "LINE .zcsr = (seltext)"            /* replace                    */
   "XSTATUS .zcsr =  X "               /* hide it                    */
   "LINE" el  "= (endtext)"            /* replace endsel line        */
   "XSTATUS" el  "=   X "              /* hide it                    */
end                                    /* forever                    */
 
"F ALL ')SEL' 1"
"F ALL ')ENDSEL' 1"
"F ')SEL' 1 FIRST"                     /* position to top            */
 
exit                                   /*@ SELMATCH                  */
