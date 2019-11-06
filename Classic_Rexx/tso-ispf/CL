/* REXX    CL         Insert a change log into a panel.
 
           Written by Chris Lewis 19970911
 
     Modification History
     19980831 fxc expand 'Date' and 'By' fields; RXSKLY2K; DECOMM:
     20010125 fxc adjust for new ISPF
 
*/
address ISREDIT
"MACRO (PARMS) NOPROCESS"
 
"FIND ')ATTR' 1 FIRST"
 if rc <> 0 then do
    zerrhm   = "ISR00000"
    zerralrm = "YES"
    zerrsm = "Missing Section"
    zerrlm = "Unable to find ATTR section of panel."
    address ISPEXEC "SETMSG MSG(ISRZ002)"
    exit 
    end
 
"(cnum) = LINENUM" .zcsr               /* Line number of cursor      */
 
stem.1  =,
     "/* ------ Change Log --------------------------------------------------- "
stem.2  =,
     "/* --Date-- --by------ -Description of change -------------------------- "
stem.3  =,
     "/*                                                                       "
stem.4  =,
     "/*                                                                       "
stem.5  =,
     "/* --------------------------------------------------------------------- "
stem.0  =     5
 
do aa = 1 to stem.0                    /* insert array into text     */
   data = "'"stem.aa"'"
  "LINE_AFTER" cnum " = DATALINE" data
   cnum = cnum + 1
end
 
"CAPS OFF"
 
exit                                   /*@ CL                        */
