/* REXX    ALIASGEN   generate DELETE ALIAS and DEFINE ALIAS                    
                      statements from a pre-set list of names.                  
                                                                                
           Written by Frank Clarke 19921124                                     
                                                                                
     Impact Analysis                                                            
.    SYSPROC   TRAPOUT                                                          
                                                                                
     Modification History                                                       
     20010329 fxc conform to REXXSKEL v.19991109; DECOMM;                       
                                                                                
*/ arg argline                                                                  
address TSO                            /* REXXSKEL ver.19991109      */         
arg parms "((" opts                                                             
                                                                                
signal on syntax                                                                
signal on novalue                                                               
                                                                                
call TOOLKIT_INIT                      /* conventional start-up     -*/         
rc     = trace(tv)                                                              
info   = parms                         /* to enable parsing          */         
                                                                                
call A_INIT                            /*                           -*/         
call B_GEN_ALIASES                     /*                           -*/         
                                                                                
if \sw.nested then call DUMP_QUEUE     /*                           -*/         
exit                                   /*@ ALIASGEN                  */         
/*                                                                              
.  ----------------------------------------------------------------- */         
A_INIT:                                /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   def. = ""; del.=""                  /* prepare arrays             */         
   parse var info            dsn .                                              
   if dsn = "?" then call HELP                                                  
   if dsn = "" then dsn = defn_dsn                                              
   source = dsn"(ALIASES)"                                                      
   define = dsn"(DEFALIAS)"                                                     
   delete = dsn"(DELALIAS)"                                                     
                                                                                
return                                 /*@ A_INIT                    */         
/*                                                                              
   (1) Read the list of aliases and create (1a) new definitions and             
       (1b) DELETE statements for the aliases which are about to be             
       defined.                                                                 
   (2) If a 'delete' member currently exists, run it.                           
   (3) Create/replace the delete-member with the latest DELETE                  
       statements.                                                              
   (4) Build the new aliases.                                                   
.  ----------------------------------------------------------------- */         
B_GEN_ALIASES:                         /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                       /* Read the list              */         
   "ALLOC FI(DEFN) DA('"source"') SHR REU"                                      
                                                                                
   if rc <> 0 then do                  /* ALLOC failed               */         
      "CLEAR"                                                                   
      say "Allocation of definition file failed, RC="rc                         
      exit                                                                      
      end                                                                       
                                                                                
   /* (1) Read the list of aliases                                   */         
   "EXECIO * DISKR DEFN (FINIS STEM DEF."                                       
                                                                                
   do bx = 1 to def.0                  /* for every definition       */         
      if Left(def.bx,1) = "*" then iterate                                      
      parse var def.bx alias base .    /* get aliasname and basename */         
      del.bx = " DELETE ("alias") ALIAS"  /* Create DELETE statement */         
      queue " DEFINE ALIAS ( NAME  ("alias") +"                                 
      queue "               RELATE ("base") )"      /* Create DEFINE */         
   end                                                                          
   del.0 = bx                                                                   
                                                                                
   "ALLOC FI(DEFN) DA('"define"') SHR REU"                                      
   "EXECIO" queued() "DISKW DEFN (FINIS"  /* load new DEFINEs        */         
   "ALLOC FI(SYSPRINT) DA(*) SHR REU"                                           
   "ALLOC FI(SYSIN) DA('"delete"') SHR REU"                                     
                                                                                
   /* (2) If a 'delete' member currently exists, run it.             */         
   if Sysdsn("'"delete"'") = "OK" then,                                         
      address LINKMVS "IDCAMS"         /* delete existing ALIASes    */         
                                                                                
   /* (3) Create/replace the delete-member                           */         
   "EXECIO" del.0 "DISKW SYSIN (FINIS STEM DEL."   /* reload DELETEs */         
                                                                                
   /* (4) Build the new aliases.                                     */         
   "ALLOC FI(SYSIN) DA('"define"') SHR REU"                                     
   address LINKMVS "IDCAMS"            /* define new ALIASes         */         
   "FREE FI(SYSIN DEFN)"               /* clean up                   */         
   "ALLOC FI(SYSIN) DA(*) REU"                                                  
                                                                                
return                                 /*@ B_GEN_ALIASES             */         
/*                                                                              
.  ----------------------------------------------------------------- */         
LOCAL_PREINIT:                         /*@ customize opts            */         
   address TSO                                                                  
                                                                                
   defn_dsn = "DTAFXC.TEST.CNTL"       /* default source             */         
                                                                                
return                                 /*@ LOCAL_PREINIT             */         
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */         
/*                                                                              
.  ----------------------------------------------------------------- */         
HELP:                                  /*@                           */         
address TSO;"CLEAR"                                                             
if helpmsg <> "" then do ; say helpmsg; say ""; end                             
ex_nam = Left(exec_name,8)             /* predictable size           */         
                                                                                
say "  "ex_nam"      helps you build and maintain dataset aliases.     "        
say "                                                                  "        
say "  Syntax:   "ex_nam"  <POsrc>                                     "        
say "                                                                  "        
say "            POsrc     is a TSO-format FB80PO dataset containing   "        
say "                      several specific members, among which are:  "        
say "                                                                  "        
say "                      ALIASES -- contains the alias-base pairs to "        
say "                              be defined.                         "        
say "                                                                  "        
say "                      DELALIAS -- contains IDCAMS DELETE commands "        
say "                              written by the last execution of    "        
say "                              "exec_name".  These will be used to "        
say "                              clear away the existing aliases     "        
say "                              prior to redefining a new set.      "        
say "                                                                  "        
say "            It is not an error for DELALIAS to be missing, but the"        
say "            result of execution is undefined if there are existing"        
say "            aliases.                                              "        
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"                                         
say "   Debugging tools provided include:                              "        
say "                                                                  "        
say "        MONITOR:  displays key information throughout processing. "        
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
       "Begin Stacks" tk_init_stacks , /* Stacks present at start    */         
       "Stacks to DUMP" stk2dump                                                
                                                                                
   do dd = rc to tk_init_stacks by -1  /* empty each one.            */         
      say "Processing Stack #" dd "Total Lines:" queued()                       
      do queued();pull line;say line;end /* pump to the screen       */         
      "DELSTACK"                       /* remove stack               */         
   end                                 /* dd = 1 to rc               */         
                                                                                
return                                 /*@ DUMP_QUEUE                */         
/*                                                                              
.  ----------------------------------------------------------------- */         
KEYWD: Procedure expose info           /*@ hide all vars, except info*/         
   arg kw                                                                       
   kw_pos = wordpos(kw,info)           /* find where it is, maybe    */         
   if kw_pos = 0 then return ""        /* send back a null, not found*/         
   kw_val = word(info,kw_pos+1)        /* get the next word          */         
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
   do ssii = ssbeg to ssend ; say sourceline(ssii) ; end                        
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
   tk_globalvars = "tk_globalvars exec_name tv helpmsg sw. zerrhm",             
                   "zerralrm zerrsm zerrlm tk_init_stacks branch",              
                   "monitor noupdt"                                             
                                                                                
   call LOCAL_PREINIT                  /* for more opts             -*/         
                                                                                
return                                 /*@ TOOLKIT_INIT              */         
