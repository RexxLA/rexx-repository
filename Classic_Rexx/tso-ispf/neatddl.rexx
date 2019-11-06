/* REXX    NEATDDL   Designed to be used on the .CARDS dataset which
                     is output of a DSNTIAUL UNLOAD.
 
           Written by Frank Clarke, Houston, 19981207
 
*/
address ISREDIT
"MACRO (opts)"
upper opts; parse var opts "TRACE" tv .
parse value tv "N" with tv .; rc = Trace(tv)
mvl = 25                               /* max variable-name length   */
 
recycle: 
initmax = mvl
"C ALL '(' '( '"
"C ALL ')' ' )'"
"F  ' ' LAST"
"(lastline,x) = CURSOR"
str = "" 
 
/*  Pack the entire multi-line description into a single text line.  */
do line# = 1 to lastline
   "(text) = LINE" line#
   str = str Space(text,1)
end                                    /* line#                      */
rc = Trace("N"); rc = Trace(tv)
"X ALL"; "DEL ALL X"                   /* clear the original workspc */
 
rstr = Reverse(str)
parse var rstr ")" rstr
str  = Reverse(rstr)
 
parse var str front "(" str
push front "("
conn = " "
do while str <> ""
   parse var str slug "," str
   parse var slug  varn  .  "POSITION(" pos ")" type  "(" len ")" extra
   mvl = Max(mvl,Length(varn))         /* make larger if needed      */
   line = Left("   "conn||varn,mvl+4) "POSITION("Space(pos,0)")"
   line = Left(line,mvl+24)Strip(type)
   if len <> "" then line = line"("Right(Strip(len),3,0)")"
   if Length(line Space(extra,1)) > 72 then do
      push line
      push "           "Space(extra,1)
      end
   else, 
      push line Space(extra,1)
   conn = ","
end                                    /*  str                       */
rc = Trace("N"); rc = Trace(tv)
push "     )"
 
do queued()                            /* each line                  */
   pull line
   "LINE_AFTER 0 = DATALINE '"line"'"
end                                    /* queued()                   */
"CURSOR = 1,1"
if mvl > initmax then signal recycle
 
exit                                   /*@ NEATDDL                   */
