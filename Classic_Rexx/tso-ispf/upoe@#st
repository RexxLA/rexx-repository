/* REXX    UPOE@#ST   Will update the stats and TBMOD the table                 
                                                                                
           Written by Chris Lewis 950308                                        
                                                                                
     Modification History                                                       
     950426 ctl Added DDNAME to pull in parms b/c of rewrite to                 
                SHOW@MEM                                                        
                                                                                
rc = trace("OFF")                      /* Ssshhh, lets be quiet      */         
address TSO "EXECUTIL TE"              /* Just to be safe            */         
*/                                                                              
                                                                                
zerrhm   = "ISR00000"                                                           
zerralrm = "YES"                                                                
                                                                                
address ISPEXEC                                                                 
"CONTROL ERRORS RETURN"                                                         
                                                                                
parse arg  tbl_name  memname  dataset  vv  mm  created  changed  time,          
           size  init  mod  id  ddname  .                                       
                                                                                
parse var created  crtyr "/"                                                    
if crtyr < 100 then,                                                            
if crtyr < 79 then created = "20"created                                        
              else created = "19"created                                        
parse var changed  chgyr "/"                                                    
if chgyr < 100 then,                                                            
if chgyr < 79 then changed = "20"changed                                        
              else changed = "19"changed                                        
"LMINIT    DATAID(BASEID)   DATASET('"dataset"')"                               
"LMMSTATS  DATAID("baseid")" "MEMBER("memname")" "USER("id")",                  
          "VERSION("vv")" "MODLEVEL("mm")" "MODDATE4("changed")",               
          "MODTIME("time")" "CREATED4("created")" "CURSIZE("size")",            
          "INITSIZE("init")" "MODRECS("mod")"                                   
if rc > 0 then do                                                               
   zerrsm = "Stats Error"                                                       
   zerrlm = "Unable to modify to the ISPF Stats. RC = "rc                       
   "SETMSG MSG(ISRZ002)"                                                        
   end                                 /* rc > 0                     */         
                                                                                
"LMFREE     DATAID("baseid")"                                                   
                                                                                
"TBMOD" tbl_name                                                                
if rc > 0 then do                                                               
   zerrsm = "Table Error"                                                       
   zerrlm = "Unable to modify to" tbl_name".     RC = "rc                       
   "SETMSG MSG(ISRZ002)"                                                        
   end                                 /* rc > 0                     */         
                                                                                
return                                 /*@                           */         
