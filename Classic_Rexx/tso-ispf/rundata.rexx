/* REXX    RUNDATA    Keeps otherwise-undefined data about executions of        
                      REXX routines in an ISPF table.  The table, also          
                      called RUNDATA, has a key of RTNNAME; all other           
                      fields are extension variables; that is: they are         
                      potentially unique for each row.                          
                                                                                
                      RUNDATA is meant to be used by other REXX code            
                      exclusively.  CLIST calls are not supported due to        
                      the fact that data transfer is via the stack.             
                                                                                
           WARNING !  Maintainers beware: if you are unfamiliar with the        
                      handling characteristics of extension variables in        
                      ISPF tables, do NOT attempt to maintain this code.        
                      Above all, do not TBOPEN table RUNDATA in                 
                      WRITE-mode with any other program.                        
                                                                                
           Written by Frank Clarke, 19991217                          
                                                                                
     Impact Analysis                                                            
.    SYSPROC   TRAPOUT                                                          
                                                                                
     Modification History                                                       
     ccyymmdd xxx .....                                                         
                  ....                                                          
                                                                                
*/ arg argline                                                                  
address ISPEXEC                        /* REXXSKEL ver.19991109      */         
arg parms "((" opts                                                             
                                                                                
signal on syntax                                                                
signal on novalue                                                               
                                                                                
call TOOLKIT_INIT                      /* conventional start-up     -*/         
rc     = trace(tv)                                                              
info   = parms                         /* to enable parsing          */         
                                                                                
"CONTROL ERRORS RETURN"                /* I'll handle my own         */         
call A_INIT                            /* set up environment        -*/         
                                    if sw.0error_found then nop ; else,         
call B_TABLE_OPS                       /* read and write table rows -*/         
call ZB_SAVELOG                        /*                           -*/         
                                                                                
if \sw.nested then call DUMP_QUEUE     /*                           -*/         
exit                                   /*@ RUNDATA                   */         
/*                                                                              
.  ----------------------------------------------------------------- */         
A_INIT:                                /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   call A0_SETUP_LOG                   /*                           -*/         
   call AA_KEYWDS                      /*                           -*/         
                                    if sw.0error_found then return              
   parse value "" with taglist tag tagval                                       
   do queued()                         /* every stack item remaining */         
      pull tag tagval                  /* TAGVAL may be multiple     */         
      call ZL_LOGMSG(tag tagval)                                                
      $z$ = Value(tag,tagval)          /* load tagval                */         
      taglist = taglist tag            /* add to xvar list           */         
   end                                 /* queued                     */         
                                                                                
   openmode.0  = "WRITE"               /* based on NOUPDT            */         
   openmode.1  = "NOWRITE"             /*                            */         
   parse value  "EF"X   "EFEF"X   "3F"X   "3F3F"X   with,                       
                xef     xefef     x3f     x3f3f   .                             
                                                                                
return                                 /*@ A_INIT                    */         
/*                                                                              
.  ----------------------------------------------------------------- */         
A0_SETUP_LOG:                          /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
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
   logdsn = "LOG."exec_name"."subid".LIST"                                      
                                                                                
   call ZL_LOGMSG("Log started by" Userid()  yyyymmdd  hhmmss)                  
                                                                                
return                                 /*@ A0_SETUP_LOG              */         
/*                                                                              
.  ----------------------------------------------------------------- */         
AA_KEYWDS:                             /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   sw.0READ     = SWITCH("READ")                                                
   sw.0WRITE    = SWITCH("WRITE")                                               
   if sw.0READ + sw.0WRITE <> 1 then do        /* one and only one   */         
      sw.0error_found = "1"                                                     
      push "<ERROR>" "READ/WRITE specified incorrectly"                         
      return                                                                    
      end                                                                       
                                                                                
   rtnname      = KEYWD("PROGRAM")                                              
   if rtnname = "" then,               /* not specified...           */         
      if queued() = 0 then do          /* ...and no place to get it  */         
         sw.0error_found = "1"                                                  
         push "<ERROR>" "No table key"                                          
         return                                                                 
         end                                                                    
      else do                          /* queue has lines            */         
         pull tag tagval rest          /* must be TBLKEY xxxxx       */         
         if tag <> "TBLKEY" |,                                                  
            tagval = ""  then do                                                
            sw.0error_found = "1"                                               
            push tag tagval rest                                                
            push "<ERROR>" "No table key on stack"                              
            return                                                              
            end                                                                 
         rtnname = tagval                                                       
         call ZL_LOGMSG("RTNNAME was on the stack")                             
         end                                                                    
                                                                                
return                                 /*@ AA_KEYWDS                 */         
/*                                                                              
.  ----------------------------------------------------------------- */         
B_TABLE_OPS:                           /*@                           */         
   if branch then call BRANCH                                                   
   address ISPEXEC                                                              
                                                                                
   call BA_OPEN                        /*                           -*/         
                                    if sw.0error_found then nop ; else ,        
   call BD_GET                         /*                           -*/         
   call BZ_CLOSE                       /*                           -*/         
                                                                                
return                                 /*@ B_TABLE_OPS               */         
/*                                                                              
.  ----------------------------------------------------------------- */         
BA_OPEN:                               /*@                           */         
   if branch then call BRANCH                                                   
   address ISPEXEC                                                              
                                                                                
   "LIBDEF  ISPTLIB  DATASET  ID("isptlib")  STACK"                             
   "TBSTATS" $tn$ "STATUS1(s1) STATUS2(s2)"                                     
   if s1 > 1 then do                                                            
      "TBCREATE"   $tn$  "KEYS(RTNNAME)" openmode.noupdt                        
      end; else,                                                                
   if s2 = 1 then do                                                            
      "TBOPEN "   $tn$   openmode.noupdt                                        
      end                                                                       
   else "TBTOP" $tn$                                                            
   "LIBDEF  ISPTLIB"                                                            
                                                                                
return                                 /*@ BA_OPEN                   */         
/*                                                                              
.  ----------------------------------------------------------------- */         
BD_GET:                                /*@                           */         
   if branch then call BRANCH                                                   
   address ISPEXEC                                                              
                                                                                
   if sw.0READ then,                   /* READ                       */         
      call BDR_READ                    /*                           -*/         
   else,                               /* WRITE                      */         
      call BDW_WRITE                   /*                           -*/         
                                                                                
return                                 /*@ BD_GET                    */         
/*                                                                              
   RTNNAME is set.  Get the row and populate the queue from the row's           
   extension variables by 'queue tag tagval'.                                   
.  ----------------------------------------------------------------- */         
BDR_READ:                              /*@                           */         
   if branch then call BRANCH                                                   
   address ISPEXEC                                                              
                                                                                
   call ZL_LOGMSG( "READ was set" )                                             
   "TBGET"  $tn$  "SAVENAME(TAGLIST)"                                           
   if rc > 0 then do                                                            
      push "<ERROR>" "TBGET RC="rc ";"zerrsm";"zerrlm                           
      return                                                                    
      end                              /*                            */         
                                                                                
   parse var taglist "(" taglist ")"   /* yes, we want no bananas    */         
   call ZL_LOGMSG( "TAGLIST:" taglist)                                          
                                                                                
   do Words(taglist)                   /* every xvar                 */         
      parse var taglist  tag taglist   /* isolate                    */         
      queue tag Value(tag)                                                      
      call ZL_LOGMSG( "queue" tag Value(tag))                                   
   end                                 /* taglist                    */         
                                                                                
return                                 /*@ BDR_READ                  */         
/*                                                                              
   TAGLIST was developed and populated in A_INIT from data found on the         
   queue.  Position to the proper row and reload with new data.                 
.  ----------------------------------------------------------------- */         
BDW_WRITE:                             /*@                           */         
   if branch then call BRANCH                                                   
   address ISPEXEC                                                              
                                                                                
   call ZL_LOGMSG( "WRITE was set" )                                            
   call ZL_LOGMSG( "TAGLIST:" taglist )                                         
   "TBMOD"  $tn$  "SAVE("taglist")"    /* load xvars to table        */         
                                                                                
return                                 /*@ BDW_WRITE                 */         
/*                                                                              
.  ----------------------------------------------------------------- */         
BZ_CLOSE:                              /*@                           */         
   if branch then call BRANCH                                                   
   address ISPEXEC                                                              
                                                                                
   if sw.0READ then do                                                          
      "TBEND  "  $tn$                                                           
      return                                                                    
      end                                                                       
                                                                                
   "LIBDEF  ISPTABL  DATASET  ID("isptabl") STACK"                              
                                                                                
   "TBCLOSE"  $tn$                     /* write to ISPTABL           */         
   if rc > 0 then do                                                            
      zerrsm = "TBCLOSE failed"                                                 
      if Symbol("zerrlm") = "LIT" then,                                         
         zerrlm = "No additional diagnostics produced."                         
      zerrlm = exec_name "("BRANCH("ID")")",                                    
               zerrlm                                                           
      call ZL_LOGMSG(zerrlm)                                                    
      push "<ERROR>" zerrlm                                                     
      address ISPEXEC "SETMSG  MSG(ISRZ002)"                                    
      sw.0error_found = "1"                                                     
      end                                                                       
                                                                                
   "LIBDEF  ISPTABL"                                                            
                                                                                
return                                 /*@ BZ_CLOSE                  */         
/*                                                                              
.  ----------------------------------------------------------------- */         
LOCAL_PREINIT:                         /*@ customize opts            */         
   address TSO                                                                  
                                                                                
   parse value KEYWD("ISPTLIB")  "'ENDVR.DCLOG.ISPTLIB'"   with,                
               isptlib   .                                                      
                                                                                
   parse value KEYWD("ISPTABL")  isptlib   with,                                
               isptabl   .                                                      
                                                                                
   parse value KEYWD("USETBL")  "RUNDATA"   with,                               
               $tn$      .                                                      
                                                                                
return                                 /*@ LOCAL_PREINIT             */         
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
/*                                                                              
.  ----------------------------------------------------------------- */         
HELP:                                  /*@                           */         
address TSO;"CLEAR"                                                             
if helpmsg <> "" then do ; say helpmsg; say ""; end                             
ex_nam = Left(exec_name,8)             /* predictable size           */         
                                                                                
say "  "ex_nam"      Maintain execution-time data for REXX routines.   "        
say "                                                                  "        
say "  Syntax:   "ex_nam"  <PROGRAM pgm>                               "        
say "                      <READ | WRITE>                (One Required)"        
say "                                                                  "        
say "            <pgm>     identifies the key for table RUNDATA.  This "        
say "                      will normally be the name of the calling    "        
say "                      program.   If <pgm> is not specified as a   "        
say "                      parameter, the first line of the input stack"        
say "                      must be 'TBLKEY <pgm>'.                     "        
say "                                                                  "        
say "            READ      commands that the output stack is to be     "        
say "                      populated for the caller's use.             "        
say "                                                                  "        
say "            WRITE     commands that table RUNDATA is to be loaded "        
say "                      with data from the input stack.             "        
say "                                                                  "        
say "                      READ and WRITE are mutually exclusive.  One "        
say "                      and only one must be specified.             "        
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"                                         
say "                                                                  "        
say "                                                                  "        
say "   If an error is detected for any reason, "exec_name" pushes     "        
say "      a line onto the queue.  The first token will be '<ERROR>'   "        
say "      and it will be followed by any available diagnostic         "        
say "      information.  The calling program is responsible for        "        
say "      handling such messages.  The table will not have been       "        
say "      updated.                                                    "        
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"                                         
say "   Debugging tools provided include:                              "        
say "                                                                  "        
say "        MONITOR:  displays key information throughout processing. "        
say "                  Displays most paragraph names upon entry.       "        
say "                                                                  "        
say "        NOUPDT:   by-pass all update logic.                       "        
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
/*                 REXXSKEL back-end removed for space               */         
