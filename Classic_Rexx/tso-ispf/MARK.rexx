/* REXX    MARK       Attach a dash(-) to the tail end of a comment.
                      REXXSKEL convention encourages that ALL calls be
                      labeled with a dash in the comment.  If the
                      comment line is not present then it will be
                      created.
 
           Written by G052811 Chris Lewis
 
     Modification History
     19960508 ctl Prep for ICEBERG; converted from personal tool
     20040323 fxc ASIS no longer supported for edit macros
 
*/
address ISREDIT
"macro (parms) NOPROCESS"              /* Used to turning trace on   */
parse upper var parms parms "((" opts
 
parse var opts "TRACE" tv .
parse value tv "N" with  tv  .
rc = Trace("O"); rc = Trace(tv)
 
parse value parms "-" with marker .    /* allow override to default  */
 
"(capstate) = CAPS"                    /* original state             */
 
"(data) = LINE .zcsr"                  /* contents of line cursor is */
"(lp,cp) = CURSOR"                     /* on.  Position of cursor on */
                                       /* line                       */
back   = "*/"                          /* tail end of comment block  */
"CAPS = ON"
 
if wordpos(back,data) = 0 then         /* there is no comment        */
  "CHANGE '                              ' '/*                           "marker"*/' 40"
else
  "C ' "back"' '"marker||back"'"
 
"CURSOR =" lp cp                       /* return cursor to original  */
"CAPS =" capstate                      /* restore original           */
 
exit                                   /*@                           */
