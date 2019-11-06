   "LIBDEF  ISPTLIB  DATASET  ID("isptlib")  STACK"                             
   "TBSTATS" $tn$ "STATUS1(s1) STATUS2(s2)"                                     
           /* S1 is meaningful only for PERMANENT tables                        
              S1 = 1 = table exists                                             
                   2 = table not in library chain                               
                   3 = table library not allocated                              
              s2 = 1 = table not open                                           
                   2 = table open in NOWRITE                                    
                   3 = table open in WRITE                                      
                   4 = table open in SHARED NOWRITE    */                       
   if s1 > 1 then do                                                            
      say "Table" $tn$ "not available."                                         
      zerrsm = "Table" $tn$ "not available."                                    
      zerrlm = "Table" $tn$ "not found in the ISPTLIB library chain"            
      sw.0error_found = "1"; return                                             
      end; else,                                                                
   if s2 = 1 then do                                                            
      "TBOPEN "   $tn$   openmode.noupdt                                        
      end                                                                       
   else "TBTOP" $tn$                                                            
   "LIBDEF  ISPTLIB"                                                            
