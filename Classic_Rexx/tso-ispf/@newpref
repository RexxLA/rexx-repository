/* REXX                                                                         
    Edit macro to change a label prefix (and all of its referents) to           
    one specified by the caller.                                                
    Usage:  @NEWPREF DC  çput cursor on label-line to be chgd to DC Ÿ           
*/                                                                              
address ISREDIT                                                                 
"MACRO (NEWPREF CASE)"                                                          
                                                                                
if case = "" then do                                                            
   address ISPEXEC "VGET ($$TCASE)"                                             
   if $$TCASE = ""     then $$TCASE = "CAPS ON"                                 
   if $$TCASE = "ASIS" then $$TCASE = "CAPS OFF"                                
   if $$TCASE = "CAPS" then $$TCASE = "CAPS ON"                                 
   end                                                                          
else $$TCASE = case                                                             
address ISPEXEC "VPUT ($$TCASE)"       /* store it away              */         
                                                                                
parse upper var newpref newpref        /* shift to uppercase         */         
"(data) = LINE .zcsr"                                                           
parse var data word1 ":" .                                                      
word1 = Strip(word1)                                                            
parse var word1 oldpref "_" oldlbl                                              
tgt = newpref"_"oldlbl                                                          
($$TCASE)                                                                       
"C ALL NX " word1 tgt                                                           
"CAPS OFF"                                                                      
exit                                   /*@ NEWPREF                   */         
