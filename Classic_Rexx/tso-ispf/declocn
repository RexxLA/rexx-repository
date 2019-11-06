/* REXX    DECLOCN      Replace the line numbers in an assembler listing
                        with the decimal conversion of D-Loc.
*/
address ISREDIT
"MACRO"
"X ALL"
 
do forever
   "F P'#' 2"
   if rc > 0 then leave                /* didn't find any ?          */
   "(text) = LINE .zcsr"               /* carpe textem               */
   parse var text 2 hv 8 idler 9       /* get possible hexvalue      */
   if idler = ""       then,
   if Datatype(hv,"X") then,
   if Length(hv) = 6 then do
      junk = Strip(Substr(text,114,8))
      "X ALL"
      "F ALL '"junk"'"
      "C ALL NX P'=' ' '  114 130 "    /* get rid of all the junk    */
      leave
      end
end
 
"X ALL"
do forever
   "F P'#' 2"
   if rc > 0 then leave                                                
   "(text) = LINE .zcsr"               /* carpe textem               */
   parse var text 2 hv 8 idler 9       /* get possible hexvalue      */
   if idler = ""       then,
   if Datatype(hv,"X") then,
   if Length(hv) = 6 then do
      dv = Right(X2D(hv)+1,8,0)
      text = Overlay(dv,text,114,14)
      "LINE .zcsr = (text)"
      end
end                                    /* forever                    */
"X ALL"; "RESET"
 
exit                                   /*@ DECLOCN                   */
