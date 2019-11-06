/* REXX    SORTCMDS   sorts a command table                                     
                                                                                
           Written by Frank Clarke ages ago                                     
                                                                                
     Impact Analysis                                                            
.    SYSPROC   TRAPOUT                                                          
                                                                                
     Modification History                                                       
     19980427 fxc REXXSKEL'd                                                    
     20020903 fxc upgrade from v.19980225 to v.20020513;                        
                                                                                
*/ arg argline                                                                  
address TSO                            /* REXXSKEL ver.20020513      */         
arg parms "((" opts                                                             
                                                                                
signal on syntax                                                                
signal on novalue                                                               
                                                                                
call TOOLKIT_INIT                      /* conventional start-up     -*/         
rc = Trace("O"); rc = Trace(tv)                                                 
info   = parms                         /* to enable parsing          */         
                                                                                
call A_INIT                            /*                           -*/         
                                   if \sw.0error_found then,                    
call B_SORT                            /*                           -*/         
                                                                                
exit                                   /*@ SORTCMDS                  */         
/*                                                                              
.  ----------------------------------------------------------------- */         
A_INIT:                                /*@                           */         
   if branch then call BRANCH                                                   
   address ISPEXEC                                                              
                                                                                
   "CONTROL ERRORS RETURN"             /* I'll handle my own errors  */         
                                                                                
   call AK_KEYWDS                      /*                           -*/         
   parse value  info  "TMPCMDS"  with $tn$     .                                
                                                                                
   if isptlib <> "" then,                                                       
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
      zerrsm = "Table" $tn$ "not available."                                    
      zerrlm = "Table" $tn$ "not found in the ISPTLIB library chain"            
      "SETMSG  MSG(ISRZ002)"                                                    
      sw.0error_found = "1"; return                                             
      end; else,                                                                
   if s2 = 1 then do                   /* table is not open          */         
      "TBOPEN "   $tn$   "WRITE"                                                
      end                                                                       
   else "TBTOP" $tn$                                                            
   if isptlib <> "" then,                                                       
      "LIBDEF  ISPTLIB"                                                         
                                                                                
return                                 /*@ A_INIT                    */         
/*                                                                              
.  ----------------------------------------------------------------- */         
AK_KEYWDS:                             /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   isptlib    = KEYWD("IN")                                                     
                                                                                
return                                 /*@ AK_KEYWDS                 */         
/*                                                                              
.  ----------------------------------------------------------------- */         
B_SORT:                                /*@                           */         
   if branch then call BRANCH                                                   
   address ISPEXEC                                                              
                                                                                
   "TBSORT" $tn$ "FIELDS(zctverb)"     /* sort                       */         
   if rc = 0 then do                                                            
      ZERRSM = $tn$ "sorted"           /* short message              */         
      ZERRLM = "Sort of" $tn$ "completed successfully."                         
      end                                                                       
   else do                                                                      
      ZERRSM = "SORT failed" rc        /* short message              */         
      ZERRLM = "Sort of" $tn$ "failed with RC="rc                               
      end                                                                       
   "SETMSG MSG(ISRZ002)"                                                        
                                                                                
   if isptlib <> "" then,                                                       
      "LIBDEF  ISPTABL  DATASET  ID("isptlib")  STACK"                          
                                                                                
   if s2 = 1 then,                     /* started out CLOSED         */         
      "TBCLOSE" $tn$                                                            
                                                                                
   if isptlib <> "" then,                                                       
      "LIBDEF  ISPTABL"                                                         
                                                                                
return                                 /*@ B_SORT                    */         
/*                                                                              
.  ----------------------------------------------------------------- */         
LOCAL_PREINIT:                         /*@ customize opts            */         
   address TSO                                                                  
                                                                                
                                                                                
return                                 /*@ LOCAL_PREINIT             */         
/*                                                                              
.  ----------------------------------------------------------------- */         
HELP:                                  /*@                           */         
address TSO;"CLEAR"                                                             
if helpmsg <> "" then do ; say helpmsg; say ""; end                             
ex_nam = Left(exec_name,8)             /* predictable size           */         
                                                                                
say "                                                                          "
say "  "ex_nam"      sorts an ISPF command table.                              "
say "                                                                          "
say "                                                                          "
say "  Syntax:   "ex_nam"  <tblnm>                                (Defaults)   "
say "                      <IN tblds>                                          "
say "                                                                          "
say "                                                                          "
say "            tblnm     identifies the command table to be sorted.          "
say "                                                                          "
say "            tblds     names the ISPF Table Library which contains 'tblnm'."
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"                                         
say "   Debugging tools provided include:"                                      
say "                                                                 "         
say "                                                                 "         
say "        BRANCH:   show all paragraph entries."                             
say "                                                                 "         
say "        TRACE tv: will use value following TRACE to place"                 
say "                  the execution in REXX TRACE Mode."                       
say "                                                                 "         
say "                                                                 "         
say "   Debugging tools can be accessed in the following manner:"               
say "                                                                 "         
say "        TSO" exec_name"  parameters  ((  debug-options"                    
say "                                                                 "         
say "   For example:"                                                           
say "                                                                 "         
say "        TSO" exec_name " (( MONITOR TRACE ?R"                              
                                                                                
address ISPEXEC "CONTROL DISPLAY REFRESH"                                       
exit                                   /*@ HELP                      */         
/*                                                                              
.  ----------------------------------------------------------------- */         
BRANCH: Procedure expose,              /*@                           */         
        sigl exec_name                                                          
   rc = trace("O")                     /* we do not want to see this */         
   arg brparm .                                                                 
                                                                                
   origin = sigl                       /* where was I called from ?  */         
   do currln = origin to 1 by -1       /* inch backward to label     */         
      if Right(Word(Sourceline(currln),1),1) = ":" then do                      
         parse value sourceline(currln) with pgfname ":" .  /* Label */         
         leave ; end                   /*                name        */         
   end                                 /* currln                     */         
                                                                                
   select                                                                       
      when brparm = "NAME" then return(pgfname) /* Return full name  */         
      when brparm = "ID"      then do           /* wants the prefix  */         
         parse var pgfname pgfpref "_" .        /* get the prefix    */         
         return(pgfpref)                                                        
         end                           /* brparm = "ID"              */         
      otherwise                                                                 
         say left(sigl,6) left(pgfname,40) exec_name "Time:" time("L")          
   end                                 /* select                     */         
                                                                                
return                                 /*@ BRANCH                    */         
/*                                                                              
.  ----------------------------------------------------------------- */         
DUMP_QUEUE:                            /*@ Take whatever is in stack */         
   rc = trace("O")                     /*  and write to the screen   */         
   address TSO                                                                  
                                                                                
   "QSTACK"                            /* how many stacks?           */         
   stk2dump    = rc - tk_init_stacks   /* remaining stacks           */         
   if stk2dump = 0 & queued() = 0 then return                                   
   say "Total Stacks" rc ,             /* rc = #of stacks            */         
    "   Begin Stacks" tk_init_stacks , /* Stacks present at start    */         
    "   Excess Stacks to dump" stk2dump                                         
                                                                                
   do dd = rc to tk_init_stacks by -1  /* empty each one.            */         
      say "Processing Stack #" dd "   Total Lines:" queued()                    
      do queued();pull line;say line;end /* pump to the screen       */         
      "DELSTACK"                       /* remove stack               */         
   end                                 /* dd = 1 to rc               */         
                                                                                
return                                 /*@ DUMP_QUEUE                */         
/* Handle CLIST-form keywords             added 20020513                        
.  ----------------------------------------------------------------- */         
CLKWD: Procedure expose info           /*@ hide all except info      */         
   arg kw                                                                       
   kw = kw"("                          /* form is 'KEY(DATA)'        */         
   kw_pos = Pos(kw,info)               /* find where it is, maybe    */         
   if kw_pos = 0 then return ""        /* send back a null, not found*/         
   rtpt   = Pos(") ",info" ",kw_pos)   /* locate end-paren           */         
   slug   = Substr(info,kw_pos,rtpt-kw_pos+1)     /* isolate         */         
   info   = Delstr(info,kw_pos,rtpt-kw_pos+1)     /* excise          */         
   parse var slug (kw)     slug        /* drop kw                    */         
   slug   = Reverse(Substr(Reverse(Strip(slug)),2))                             
return slug                            /*@CLKWD                      */         
/* Handle multi-word keys 20020513                                              
.  ----------------------------------------------------------------- */         
KEYWD: Procedure expose info           /*@ hide all vars, except info*/         
   arg kw                                                                       
   kw_pos = wordpos(kw,info)           /* find where it is, maybe    */         
   if kw_pos = 0 then return ""        /* send back a null, not found*/         
   kw_val = word(info,kw_pos+Words(kw))/* get the next word          */         
   info   = Delword(info,kw_pos,2)     /* remove both                */         
return kw_val                          /*@ KEYWD                     */         
/*                                                                              
.  ----------------------------------------------------------------- */         
KEYPHRS: Procedure expose,             /*@                           */         
         info helpmsg exec_name        /*  except these three        */         
   arg kp                                                                       
   wp    = wordpos(kp,info)            /* where is it?               */         
   if wp = 0 then return ""            /* not found                  */         
   front = subword(info,1,wp-1)        /* everything before kp       */         
   back  = subword(info,wp+1)          /* everything after kp        */         
   parse var back dlm back             /* 1st token must be 2 bytes  */         
   if length(dlm) <> 2 then            /* Must be two bytes          */         
      helpmsg = helpmsg "Invalid length for delimiter("dlm") with KEYPHRS("kp")"
   if wordpos(dlm,back) = 0 then       /* search for ending delimiter*/         
      helpmsg = helpmsg "No matching second delimiter("dlm") with KEYPHRS("kp")"
   if helpmsg <> "" then call HELP     /* Something is wrong         */         
   parse var back kpval (dlm) back     /* get everything b/w delim   */         
   info =  front back                  /* restore remainder          */         
return Strip(kpval)                    /*@ KEYPHRS                   */         
/*                                                                              
.  ----------------------------------------------------------------- */         
NOVALUE:                               /*@                           */         
   say exec_name "raised NOVALUE at line" sigl                                  
   say " "                                                                      
   say "The referenced variable is" condition("D")                              
   say " "                                                                      
   zsigl = sigl                                                                 
   signal SHOW_SOURCE                  /*@ NOVALUE                   */         
/*                                                                              
.  ----------------------------------------------------------------- */         
SHOW_SOURCE:                           /*@                           */         
   call DUMP_QUEUE                     /* Spill contents of stacks  -*/         
   if sourceline() <> "0" then         /* to screen                  */         
      say sourceline(zsigl)                                                     
   rc =  trace("?R")                                                            
   nop                                                                          
   exit                                /*@ SHOW_SOURCE               */         
/*                                                                              
.  ----------------------------------------------------------------- */         
SS: Procedure                          /*@ Show Source               */         
   arg  ssbeg  ssend  .                                                         
   if ssend = "" then ssend = 10                                                
   if \datatype(ssbeg,"W") | \datatype(ssend,"W") then return                   
   ssend = ssbeg + ssend                                                        
   do ssii = ssbeg to ssend ; say Strip(sourceline(ssii),'T') ; end             
return                                 /*@ SS                        */         
/*                                                                              
.  ----------------------------------------------------------------- */         
SWITCH: Procedure expose info          /*@                           */         
   arg kw                                                                       
   sw_val = Wordpos(kw,info) > 0       /* exists = 1; not found = 0  */         
   if sw_val then                      /* exists                     */         
      info = Delword(info,Wordpos(kw,info),1) /* remove it           */         
return sw_val                          /*@ SWITCH                    */         
/*                                                                              
.  ----------------------------------------------------------------- */         
SYNTAX:                                /*@                           */         
   errormsg = exec_name "encountered REXX error" rc "in line" sigl":",          
                        errortext(rc)                                           
   say errormsg                                                                 
   zsigl = sigl                                                                 
   signal SHOW_SOURCE                  /*@ SYNTAX                    */         
/*                                                                              
   Can call TRAPOUT.                                                            
.  ----------------------------------------------------------------- */         
TOOLKIT_INIT:                          /*@                           */         
   address TSO                                                                  
   info = Strip(opts,"T",")")          /* clip trailing paren        */         
                                                                                
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm,                   
                     as_invokt  cmd_env  addr_spc  usr_tokn                     
                                                                                
   parse value "" with  tv  helpmsg  .                                          
   parse value 0   "ISR00000  YES"     "Error-Press PF1"    with,               
               sw.  zerrhm    zerralrm  zerrsm                                  
                                                                                
   if SWITCH("TRAPOUT") then do                                                 
      "TRAPOUT" exec_name parms "(( TRACE R" info                               
      exit                                                                      
      end                              /* trapout                    */         
                                                                                
   if Word(parms,1) = "?" then call HELP /* I won't be back          */         
                                                                                
   "QSTACK" ; tk_init_stacks = rc      /* How many stacks?           */         
                                                                                
   parse value SWITCH("BRANCH") SWITCH("MONITOR") SWITCH("NOUPDT") with,        
               branch           monitor           noupdt    .                   
                                                                                
   parse value mvsvar("SYSNAME") sysvar("SYSNODE") with,                        
               #tk_cpu           node          .                                
                                                                                
   sw.nested    = sysvar("SYSNEST") = "YES"                                     
   sw.batch     = sysvar("SYSENV")  = "BACK"                                    
   sw.inispf    = sysvar("SYSISPF") = "ACTIVE"                                  
                                                                                
   parse value KEYWD("TRACE")  "O"    with   tv  .                              
   tk_globalvars = "exec_name  tv  helpmsg  sw.  zerrhm  zerralrm ",            
                   "zerrsm  zerrlm  tk_init_stacks  branch  monitor ",          
                   "noupdt"                                                     
                                                                                
   call LOCAL_PREINIT                  /* for more opts             -*/         
                                                                                
return                                 /*@ TOOLKIT_INIT              */         
