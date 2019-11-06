/* REXX    SYSVARS                                                              
*/                                                                              
sysvars = "SYSPREF SYSPROC SYSUID SYSLTERM SYSWTERM SYSENV SYSICMD",            
          "SYSISPF SYSNEST SYSPCMD SYSSCMD SYSCPU SYSHSM SYSJES",               
          "SYSLRACF SYSNODE SYSRACF SYSSRV SYSTERMID SYSTSOE"                   
/*svars = "SYSAPPCLU SYSDFP SYSMVS SYSNAME SYSSMFID SYSSMS",                    
          "SYSCLONE SYSPLEX" */                                                 
mvsvars = "SYSDFP SYSMVS SYSNAME SYSSMFID SYSSMS",                              
          "SYSCLONE"                                                            
                                                                                
say "SYSVARS:"                                                                  
do zz = 1 to words(sysvars) by 2                                                
   var = Word(sysvars,zz)                                                       
   nxt = Word(sysvars,zz+1)                                                     
   say Left(Right(var":",15) SYSVAR(var) ,38) ,                                 
       Right(nxt":",15) SYSVAR(nxt)                                             
end                                                                             
                                                                                
say "MVSVARS:"                                                                  
do zz = 1 to words(mvsvars) by 2                                                
   var = Word(mvsvars,zz)                                                       
   nxt = Word(mvsvars,zz+1)                                                     
   say Left(Right(var":",15) MVSVAR(var) ,38) ,                                 
       Right(nxt":",15) MVSVAR(nxt)                                             
end                                                                             
                                                                                
exit                                   /*@ SYSVARS                   */         
