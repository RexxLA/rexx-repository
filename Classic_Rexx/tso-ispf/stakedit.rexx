/* REXX    STAKEDIT   Recursive edit.  Will also Browse or View                 
                      depending on the active alias.                            
                                                                                
        NOTE ::::    MUST    be called via the command table:                   
                             SELECT CMD(%STAKEDIT &ZPARM) NEWAPPL(ISR)          
                                                                                
                    Written by Frank Clarke                                     
*/                                                                              
tv = ""                                                                         
arg parms "((" opts                                                             
                                                                                
optl = Length(opts)                    /* how long ?                 */         
if optl > 0 then,                      /* exists ?                   */         
if Substr(opts,optl,1) = ")" then,     /* last char is close-paren ? */         
   opts = Substr(opts,1,optl-1)        /* clip trailing paren        */         
                                                                                
parse var opts "TRACE" tv .                                                     
if tv ^= "" then interpret "TRACE" tv                                           
                                                                                
if parms = "" then call HELP                                                    
parse var parms indsn .                                                         
icmd = Sysvar("SYSICMD")               /* How was I called ?         */         
action.          = "BROWSE"                                                     
action.STAKEDIT  = "EDIT"                                                       
action.STAKVIEW  = "VIEW"                                                       
                                                                                
address ISPEXEC                                                                 
"CONTROL ERRORS RETURN"                /* I'll handle my own         */         
(action.icmd) "DATASET("indsn")"                                                
                                                                                
zerrhm = "ISR00000"                                                             
ZERRALRM = "YES"                       /* beep the screen            */         
address ISPEXEC "SETMSG MSG(ISRZ002)"                                           
                                                                                
exit                                                                            
                                                                                
/* ----------------------------------------------------------------- */         
HELP:                                                                           
say "HELP for" Sysvar(Sysicmd) "not available"                                  
exit                                                                            
