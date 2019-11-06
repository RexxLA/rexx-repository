   do forever                                                                   
      "TBDISPL" $tn$ "PANEL(APFLIST)"                                           
      if rc > 4 then leave             /* PF3 ?                      */         
      do ztdsels                                                                
         select                                                                 
            when curact = "S" then do  /* Select                     */         
               end                                                              
            otherwise nop                                                       
         end                           /* Select                     */         
         if ztdsels = 1 then,          /* never do the last one      */         
            ztdsels = 0                                                         
         else "TBDISPL" $tn$           /* next row                   */         
      end                              /* ztdsels                    */         
      action = ''                      /* clear for re-display       */         
   end                                 /* forever                    */         
