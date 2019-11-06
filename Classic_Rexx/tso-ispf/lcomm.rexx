/* REXX    LCOMM          inserts a PL/I comment right-justified on the
                          selected line.
 
           Written by Frank Clarke 20051116
 
     Impact Analysis
.    ...       ...
 
     Modification History
     ccyymmdd ... ..........
                  ...
 
*/
address ISREDIT
"MACRO (opts)"
parse var opts parms "((" opts
upper opts
parse var opts "TRACE" tv .
parse value tv "N" with tv .
rc = Trace(tv)
 
comment = "/*" Strip(parms) "*/"
comml = Length(comment)
"(text) = LINE .zcsr"                  /* acquire text               */
parse var text text 73 .               /* snip                       */
if Right(text,comml) = "" then do
   text = Overlay(comment,text,73-comml)
   "LINE .zcsr = (text)"
   end
else do                                /*                            */
   parse value     "ISR00000  YES"        with,
                   zerrhm    zerralrm  .
   zerrsm = "Too long"
   zerrlm = "Text '"parms"' cannot be fitted on the line."
   address ISPEXEC "SETMSG MSG(ISRZ002)"
   end
 
exit                                   /*@ LCOMM                     */
