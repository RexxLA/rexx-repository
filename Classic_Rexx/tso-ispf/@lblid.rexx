/* REXX                                                                         
    Edit macro to prefix a label (and all of its referents) with an             
    identifier specified by the caller.  The specified prefix will be           
    prepended with an underscore character thus:                                
         @LBLID AA                                                              
    results in                                                                  
         AA_Initialize:                                                         
*/                                                                              
address ISREDIT                                                                 
"macro (PFX case trash)"                                                        
                                                                                
address ISPEXEC "VGET ($$TCASE)"                                                
$$TCASE = Word(case $$TCASE "CAPS",1)  /* Case specification is (in             
                                          order of preference:)                 
                                           1. specified at invocation           
                                           2. used for last run                 
                                           3. CAPS                   */         
address ISPEXEC "VPUT ($$TCASE)"       /* store it away              */         
                                                                                
parse upper var pfx pfx                /* shift to uppercase         */         
"(data) = LINE .zcsr"                                                           
parse var data word1 ":" .                                                      
word1 = Strip(word1)                                                            
tgt = pfx"_"word1                                                               
($$TCASE)                                                                       
"C ALL NX " word1 tgt                                                           
"CAPS OFF"                                                                      
exit                                                                            
