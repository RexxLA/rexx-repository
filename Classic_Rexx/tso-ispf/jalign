/* REXX    JALIGN      Align JCL statements for ease of reading.                
*/                                                                              
address ISREDIT                                                                 
"MACRO"                                                                         
                                                                                
do 12 until rc > 0                                                              
   "C ALL ' DD  '   ' DD ' "           /* condense trailing blanks   */         
end                                                                             
do 12 until rc > 0                                                              
   "C ALL '  DD '   ' DD ' "           /* condense leading blanks   */          
end                                                                             
                                                                                
do 12 until rc > 0                                                              
   "C ALL ' DD '   '  DD '   1 14 "    /* shift out to 13            */         
end                                                                             
                                                                                
do 12 until rc > 0                                                              
   "C ALL '  DD '   ' DD '  12 55 "    /* shift in to 13             */         
end                                                                             
                                                                                
"X ALL"                                /*                            */         
"F ALL '// ' "                         /* only continued lines       */         
"X ALL 'PARM=' "                       /* except parms               */         
"X ALL DD WORD "                       /* and dd statements          */         
"X ALL ' PEND '"                                                                
"X ALL ' INCLUDE '"                                                             
                                                                                
"F FIRST NX ' JCLLIB '"                                                         
if rc = 0 then do                                                               
   "LABEL .zcsr = .JB 1"                                                        
   "(text) = LINE .zcsr"                                                        
   parse var text " JCLLIB " jcllib1 .                                          
   do forever                                                                   
      if Right(jcllib1,1) = "," then do /* continued                 */         
         "F NEXT NX 3 ' '"                                                      
         "(text) = LINE .zcsr"                                                  
         parse var text . jcllib1 .                                             
         end                                                                    
      else do                                                                   
         "LABEL .zcsr = .JE 0"                                                  
         leave                                                                  
         end                                                                    
   end                                 /* forever                    */         
   "X ALL .JB .JE"                                                              
   end                                                                          
                                                                                
"F FIRST NX ' SET '"                                                            
if rc = 0 then do                                                               
   "LABEL .zcsr = .SB 1"                                                        
   "(text) = LINE .zcsr"                                                        
   parse var text " SET " setparm .                                             
   do forever                                                                   
      if Right(setparm,1) = "," then do /* continued                 */         
         "F NEXT NX 3 ' '"                                                      
         "(text) = LINE .zcsr"                                                  
         parse var text . setparm .                                             
         end                                                                    
      else do                                                                   
         "LABEL .zcsr = .SE 0"                                                  
         leave                                                                  
         end                                                                    
   end                                 /* forever                    */         
   "X ALL .SB .SE"                                                              
   end                                                                          
                                                                                
"C ALL NX '// ' '//            ' "     /* shift out to 16            */         
                                                                                
do until rc > 0                                                                 
   "C ALL ' EXEC ' '  EXEC ' 1 15 "    /* shift out to 12            */         
end                                                                             
                                                                                
do until rc > 0                                                                 
   "C ALL ' EXEC ' 'EXEC ' 14 22"      /* shift in to 12             */         
end                                                                             
                                                                                
"RESET"                                                                         
"RESET LABEL"                                                                   
                                                                                
exit                                   /*@ JALIGN                    */         
