/* REXX    FTPERR     Analyzes FTP return codes.  These are of the              
                      form xxyyy where xx relates to the function and           
                      yyy describes the result of the function.                 
                                                                                
           Written by Frank Clarke 20010316                                     
                                                                                
     Impact Analysis                                                            
.    SYSPROC   TRAPOUT                                                          
                                                                                
     Modification History                                                       
     20031110 fxc upgrade from v.19991109 to v.20031022;                        
                                                                                
*/ arg argline                                                                  
address TSO                            /* REXXSKEL ver.20031022      */         
arg parms "((" opts                                                             
                                                                                
signal on syntax                                                                
signal on novalue                                                               
                                                                                
call TOOLKIT_INIT                      /* conventional start-up     -*/         
rc     = trace(tv)                                                              
info   = parms                         /* to enable parsing          */         
                                                                                
call A_INIT                            /*                           -*/         
                                                                                
if sw.0stack then do                                                            
   queue subcd subcmd                  /* 16 DELETE maybe            */         
   queue rsncd reason                  /* 550 DS Not Found maybe     */         
   end                                 /* load the stack             */         
if \sw.nested then call DUMP_QUEUE     /*                           -*/         
if \sw.0stack then return(reason)                                               
exit                                   /*@ FTPERR                   -*/         
/*                                                                              
.  ----------------------------------------------------------------- */         
A_INIT:                                /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   call AR_LOAD_REASONS                /*                           -*/         
   call AS_LOAD_SUBCMDS                /*                           -*/         
                                                                                
   parse var info ftprc .              /* the one and only parm      */         
   if ftprc = "" then do                                                        
      helpmsg = "FTPRC is required."                                            
      call HELP                                                                 
      end                                                                       
                                                                                
   rsncd   = ftprc//1000               /* xx yyy selects YYY         */         
   reason  = reason.rsncd                                                       
                                                                                
   subcd   = ftprc%1000                /* xx yyy selects XX          */         
   subcmd  = subcmd.subcd                                                       
                                                                                
return                                 /*@ A_INIT                    */         
/*                                                                              
.  ----------------------------------------------------------------- */         
AR_LOAD_REASONS:                       /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   reason.    = "??"                   /* default                    */         
   reason.000 = "FTP subcommand contains an incorrect parameter"                
   reason.110 = "Restart marker reply"                                          
   reason.120 = "Service ready in nnn minutes"                                  
   reason.125 = "Data connection already open; transfer starting"               
   reason.150 = "File status okay; about to open data connection"               
   reason.200 = "Command okay"                                                  
   reason.202 = "Command not implemented; not used on this host"                
   reason.208 = "Unable to delete data set because expiration date",            
                "has not passed"                                                
   reason.211 = "System status, or system help reply"                           
   reason.212 = "Directory status"                                              
   reason.213 = "File status "                                                  
   reason.214 = "Help message"                                                  
   reason.215 = "MVS is the operating system of this server"                    
   reason.220 = "Service ready for new user"                                    
   reason.221 = "QUIT command received"                                         
   reason.226 = "Closing data connection; requested file action",               
                "successful "                                                   
   reason.230 = "User logged on; proceed"                                       
   reason.250 = "Requested file action okay, completed"                         
   reason.257 = "PATH NAME created"                                             
   reason.331 = "Send password please"                                          
   reason.332 = "Supply minidisk password using account"                        
   reason.421 = "Service not available"                                         
   reason.425 = "Cannot open data connection"                                   
   reason.426 = "Connection closed; transfer ended abnormally"                  
   reason.450 = "Requested file action not taken; file busy"                    
   reason.451 = "Requested action abended; local error in processing"           
   reason.452 = "Requested action not taken; insufficient storage",             
                "space in system"                                               
   reason.500 = "Syntax error; command unrecognized"                            
   reason.501 = "Syntax error in parameters or arguments"                       
   reason.502 = "Command not implemented"                                       
   reason.503 = "Bad sequence of commands"                                      
   reason.504 = "Command not implemented for that parameter"                    
   reason.530 = "Not logged on"                                                 
   reason.532 = "Need account for storing files"                                
   reason.550 = "Requested action not taken; file not found or no",             
                "access "                                                       
   reason.551 = "Requested action abended; page type unknown"                   
   reason.552 = "Requested file action ended abnormally; exceeded",             
                "storage allocation"                                            
   reason.553 = "Requested action not taken; file name not allowed"             
   reason.554 = "Transfer aborted; unsupported SQL statement"                   
                                                                                
return                                 /*@ AR_LOAD_REASONS           */         
/*                                                                              
.  ----------------------------------------------------------------- */         
AS_LOAD_SUBCMDS:                       /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   subcmd.    = "Invalid"                                                       
   subcmd.1   = "AMBIGUOUS"                                                     
   subcmd.2   = "?"                                                             
   subcmd.3   = "ACCOUNT"                                                       
   subcmd.4   = "APPEND"                                                        
   subcmd.5   = "ASCII"                                                         
   subcmd.6   = "BINARY"                                                        
   subcmd.7   = "CD"                                                            
   subcmd.8   = "CLOSE"                                                         
   subcmd.9   = "TSO"                                                           
   subcmd.10  = "OPEN"                                                          
   subcmd.11  = "DEBUG"                                                         
   subcmd.12  = "DELIMIT"                                                       
   subcmd.13  = "DELETE"                                                        
   subcmd.14  = "DIR"                                                           
   subcmd.15  = "EBCDIC"                                                        
   subcmd.16  = "GET"                                                           
   subcmd.17  = "HELP"                                                          
   subcmd.18  = "LOCSTAT"                                                       
   subcmd.19  = "USER"                                                          
   subcmd.20  = "LS"                                                            
   subcmd.21  = "MDELETE"                                                       
   subcmd.22  = "MGET"                                                          
   subcmd.23  = "MODE"                                                          
   subcmd.24  = "MPUT"                                                          
   subcmd.25  = "NOOP"                                                          
   subcmd.26  = "PASS"                                                          
   subcmd.27  = "PUT"                                                           
   subcmd.28  = "PWD"                                                           
   subcmd.29  = "QUIT"                                                          
   subcmd.30  = "QUOTE"                                                         
   subcmd.31  = "RENAME"                                                        
   subcmd.32  = "SENDPORT"                                                      
   subcmd.33  = "SENDSITE"                                                      
   subcmd.34  = "SITE"                                                          
   subcmd.35  = "STATUS"                                                        
   subcmd.36  = "STRUCT"                                                        
   subcmd.37  = "SUNIQUE"                                                       
   subcmd.38  = "SYSTEM"                                                        
   subcmd.39  = "TRACE"                                                         
   subcmd.40  = "TYPE"                                                          
   subcmd.41  = "LCD"                                                           
   subcmd.42  = "LOCSITE"                                                       
   subcmd.43  = "LPWD"                                                          
   subcmd.44  = "MKDIR"                                                         
   subcmd.45  = "LMKDIR"                                                        
   subcmd.46  = "EUCKANJI"                                                      
   subcmd.47  = "IBMKANJI"                                                      
   subcmd.48  = "JIS78KJ"                                                       
   subcmd.49  = "JIS83KJ"                                                       
   subcmd.50  = "SJISKANJI"                                                     
   subcmd.51  = "CDUP"                                                          
   subcmd.52  = "RMDIR"                                                         
   subcmd.53  = "HANGEUL"                                                       
   subcmd.54  = "KSC5601"                                                       
   subcmd.55  = "TCHINESE"                                                      
   subcmd.56  = "RESTART"                                                       
   subcmd.99  = "UNKNOWN"                                                       
                                                                                
return                                 /*@ AS_LOAD_SUBCMDS           */         
/*                                                                              
.  ----------------------------------------------------------------- */         
LOCAL_PREINIT:                         /*@ customize opts            */         
   address TSO                                                                  
                                                                                
   sw.0stack   = SWITCH("STACK")                                                
                                                                                
return                                 /*@ LOCAL_PREINIT             */         
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */         
/*                                                                              
.  ----------------------------------------------------------------- */         
HELP:                                  /*@                           */         
address TSO;"CLEAR"                                                             
if helpmsg <> "" then do ; say helpmsg; say ""; end                             
ex_nam = Left(exec_name,8)             /* predictable size           */         
e_n = exec_name                                                                 
say "  "ex_nam"      describes in text form the meaning of the return  "        
say "                code from FTP.  FTP returns a two-part number to  "        
say "                indicate the results of execution.  The low-order "        
say "                three digits describe the execution results and   "        
say "                the high-order digits verify the operation verb.  "        
say "                                                                  "        
say "  Syntax:   "ex_nam"  ftprc                             (Required)"        
say "                  ((  STACK                                       "        
say "                                                                  "        
say "            ftprc     is the return code from FTP                 "        
say "                                                                  "        
say "            STACK     (OPTION literal) directs" e_n "to return    "        
say "                      the two-part explanation via the data       "        
say "                      stack, one part per line.                   "        
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"                                         
say "   Debugging tools provided include:                              "        
say "                                                                  "        
say "        MONITOR:  displays key information throughout processing. "        
say "                                                                  "        
say "        BRANCH:   show all paragraph entries.                     "        
say "                                                                  "        
say "        TRACE tv: will use value following TRACE to place the     "        
say "                  execution in REXX TRACE Mode.                   "        
say "                                                                  "        
say "                                                                  "        
say "   Debugging tools can be accessed in the following manner:       "        
say "                                                                  "        
say "        TSO "ex_nam"  parameters     ((  debug-options            "        
say "                                                                  "        
say "   For example:                                                   "        
say "                                                                  "        
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                         "        
address ISPEXEC "CONTROL DISPLAY REFRESH"                                       
exit                                   /*@ HELP                      */
/* -------------- REXXSkel back-end removed for space -------------- */   
