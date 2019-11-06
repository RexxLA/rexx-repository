   parse value "0" with,                                                        
               log#    log.                                                     
   parse value Date("S")  Time("S")  Time("N")  with,                           
               yyyymmdd   sssss      hhmmss  .                                  
   parse var yyyymmdd  4 yrdigit 5 mm 7 dd          /* 9 12 14 maybe */         
   if Pos(yrdigit,"13579") > 0 then mm = mm + 12       /* mm=24      */         
   logtag = Substr("ABCDEFGHIJKLMNOPQRSTUVWX",mm,1)    /* logtag=X   */         
   subid  = logtag""dd""Right(sssss,5,0)               /* X1423722 ? */         
   vb4k.0    = "NEW CATALOG UNIT(SYSDA) SPACE(1 5) TRACKS",                     
               "RECFM(V B) LRECL(4096) BLKSIZE(0)"                              
   vb4k.1    = "SHR"                   /* if it already exists...    */         
   logdsn = "@@LOG."exec_name"."subid".LIST"                                    
                                                                                
   call ZL_LOGMSG("Log started by" Userid()  yyyymmdd  hhmmss)                  
/*                                                                              
.  ----------------------------------------------------------------- */         
ZB_SAVELOG:                            /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   if Symbol("LOG#") = "LIT" then return          /* not yet set     */         
                                                                                
   "ALLOC FI($LOG) DA("logdsn") REU" vb4k.0                                     
   "EXECIO" log# "DISKW $LOG (STEM LOG. FINIS"                                  
   "FREE  FI($LOG)"                                                             
                                                                                
return                                 /*@ ZB_SAVELOG                */         
/*                                                                              
.  ----------------------------------------------------------------- */         
ZL_LOGMSG: Procedure expose,           /*@                           */         
   (tk_globalvars)  log. log#                                                   
   rc = Trace("O")                                                              
   address TSO                                                                  
                                                                                
   parse arg msgtext                                                            
   parse value  log#+1  msgtext     with,                                       
                zz      log.zz    1  log#   .                                   
                                                                                
   if monitor then say,                                                         
      msgtext                                                                   
                                                                                
return                                 /*@ ZL_LOGMSG                 */         
