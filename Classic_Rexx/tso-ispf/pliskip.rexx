/* REXX    PLISKIP       Replaces carriage control characters in PLI            
           source with preprocessor commands.                                   
*/                                                                              
address ISREDIT                                                                 
"MACRO (opts)"                                                                  
upper opts                                                                      
parse var opts "TRACE" tv .                                                     
parse value tv "N" with tv .                                                    
rc = Trace(tv)                                                                  
                                                                                
hyp = "-"                                                                       
cmd.     = " "                                                                  
cmd.1    = Copies(" ",59)"%page ;"     /* page eject                 */         
cmd.0    = Copies(" ",59)" "           /* double space               */         
cmd.hyp  = Copies(" ",59)"%skip(2) ;"  /* triple space               */         
                                                                                
"F P'^' 1  FIRST"                      /* first control character    */         
do while rc = 0                        /* as long as the FIND works  */         
   "(text) = LINE .zcsr"               /* acquire the text           */         
   sub = Left(text,1)                  /* 1 or 0 or -                */         
   "C P'=' ' '  1"                     /* wipe it out                */         
   cmd = cmd.sub                                                                
   if sub = "0" then,                                                           
      "LINE_BEFORE  .zcsr = DATALINE (cmd) "                                    
   else do ;                                                                    
      "F ';' PREV"                                                              
      "LINE_AFTER  .zcsr = DATALINE (cmd) "                                     
      end                                                                       
   "F P'^' 1 NEXT "                    /* next control character     */         
end                                    /* while rc = 0               */         
                                                                                
exit                                   /*@ PLISKIP                   */         
