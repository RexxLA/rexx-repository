/* REXX    CMMEMIDX   Generates an 'index-member' for a partitioned             
                      dataset.                                                  
                                                                                
           Written by Frank Clarke, Oldsmar FL                                  
                                                                                
     Impact Analysis                                                            
.    SYSPROC   MEMBERS                                                          
.    SYSPROC   STRSORT                                                          
.    SYSPROC   TRAPOUT                                                          
                                                                                
     Modification History                                                       
     20010412 fxc added sw ALIAS to enable posting of aliasnames;               
                  reference external STRSORT;                                   
     20010501 fxc add TARGET as alternate output ds; put #INDEX into            
                  memberlist if it doesn't exist;                               
                                                                                
*/ arg argline                                                                  
address TSO                            /* REXXSKEL ver.19991109      */         
arg parms "((" opts                                                             
                                                                                
signal on syntax                                                                
signal on novalue                                                               
                                                                                
call TOOLKIT_INIT                      /* conventional start-up     -*/         
rc     = trace(tv)                                                              
info   = parms                         /* to enable parsing          */         
                                                                                
call A_INIT                            /*                           -*/         
     "NEWSTACK"                        /* isolate the major queue    */         
call B_GET_INPUTS                      /*                           -*/         
call C_LOAD_QUEUE                      /*                           -*/         
     "DELSTACK"                        /* finished                   */         
                                                                                
if \sw.nested then call DUMP_QUEUE     /*                           -*/         
exit                                   /*@ CMMEMIDX                  */         
/*                                                                              
   Initialization                                                               
.  ----------------------------------------------------------------- */         
A_INIT:                                /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   call AA_KEYWDS                      /*                           -*/         
                                                                                
   parse value "0      0             "    with,                                 
                li.    liptr,                                                   
                .                                                               
   listmbr = 'ff'x                                                              
   parse value "Unknown"     with,                                              
                udata.,                                                         
                .                                                               
   udata.G052811 = "Chris Lewis        "                                        
   udata.DTCFXC1 = "Frank Clarke       "                                        
   udata.DTCFXC2 = "Frank Clarke       "                                        
   udata.DTAFXC  = "Frank Clarke       "                                        
   udata.ISCH89  = "Frank Clarke       "                                        
   udata.DFCDX01 = "Don Ohlin          "                                        
   udata.F9CLARK = "Frank Clarke       "                                        
   udata.T3CAMB0 = "Anna Bandel        "                                        
   udata.JPMACKE = "Jim MacKean        "                                        
   udata.DFCBXD3 = "Bill deBruler      "                                        
                                                                                
   parse var info   dsn  .                                                      
   if Right(dsn,1) <> "'" then,                                                 
      dsn = "'"Userid()"."dsn"'"       /* make it fully-qualified    */         
   indx_mbr = Overlay( "(#INDEX)'" , dsn , Length(dsn) )                        
   if monitor then say,                                                         
      "Using" indx_mbr                                                          
                                                                                
return                                 /*@ A_INIT                    */         
/*                                                                              
   Parse out KEYWDs, SWITCHes and KEYPHRSes.                                    
.  ----------------------------------------------------------------- */         
AA_KEYWDS:                             /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   idx_target = KEYWD("TARGET")        /* alternate output ds        */         
                                                                                
   if SWITCH("ALIAS") then alias = "ALIAS"                                      
                      else alias = ""                                           
                                                                                
return                                 /*@ AA_KEYWDS                 */         
/*                                                                              
   Read #INDEX if it exists; spill headers onto the queue; get                  
   memberlist; resolve aliases if requested; setup for LM functions.            
.  ----------------------------------------------------------------- */         
B_GET_INPUTS:                          /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   "ALLOC FI($TMP) DA("indx_mbr") SHR REU"                                      
   if Sysdsn(indx_mbr) = "OK" then do                                           
      "EXECIO * DISKR $TMP (STEM LI. FINIS"                                     
      if rc > 0 then call BA_NEW_HDR                                            
      else do                                                                   
         do ii = 1 by 1 until Right(Strip(li.ii),8) = "========"                
            queue li.ii                /* copy input to output       */         
         end                                                                    
         do liptr = ii+1 by 1 while liptr \> li.0                               
            if li.liptr = "" then iterate /* blank line              */         
            parse var li.liptr 1 bl1 2 listmbr 10 bl2 12                        
            if Strip(bl1 bl2) <> "" |,                                          
               Words(listmbr) > 1 then iterate                                  
            leave                      /* listmbr is populated       */         
         end                           /* liptr                      */         
         end                                                                    
      end                                                                       
   else call BA_NEW_HDR                /* no #INDEX member...        */         
                                                                                
   "NEWSTACK"                          /* isolate                    */         
   "MEMBERS" dsn "((STACK LINE" alias                                           
   pull mbrlist                                                                 
   "DELSTACK"                          /* expose                     */         
                                                                                
   sw.0newindex = WordPos("#INDEX",mbrlist) = "0"                               
                                                                                
   call BB_ADD_ALIASES                 /*                           -*/         
   parse value mbrlist 'FF'x with  thismbr  mbrlist                             
                                                                                
   address ISPEXEC                                                              
   "LMINIT DATAID(lmdataid) DATASET("dsn")"                                     
   "LMOPEN DATAID("lmdataid") OPTION(INPUT)"                                    
                                                                                
return                                 /*@ B_GET_INPUTS              */         
/*                                                                              
   Write a new header.                                                          
.  ----------------------------------------------------------------- */         
BA_NEW_HDR:                            /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   queue  " "                                                                   
   queue  "         "dsn" - Directory"                                          
   queue  " "                                                                   
   queue  " "                                                                   
   queue  "           Usage or"                                                 
   queue  " Member    Caller      Description"                                  
   queue  " ========  ==========  "Copies("=",48)                               
                                                                                
return                                 /*@ BA_NEW_HDR                */         
/*                                                                              
   Setup aliases with a pointer to their main member.                           
.  ----------------------------------------------------------------- */         
BB_ADD_ALIASES:                        /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   mainmbr. = ""                                                                
   thismbr  = ""                                                                
   do words(mbrlist)                                                            
      parse value mbrlist thismbr with thismbr mbrlist                          
      if Right(thismbr,3) = "(*)" then do                                       
         parse var thismbr thismbr "("                                          
         mainmbr.thismbr = mainmbr                                              
         end                           /* alias                      */         
      else mainmbr = thismbr           /* not an alias               */         
   end                                 /* words in mbrlist           */         
   mbrlist = mbrlist thismbr           /* put last one back          */         
                                                                                
   if idx_target = "" then,            /* no alternate               */         
   if sw.0newindex then,               /* #INDEX doesn't exist       */         
      mbrlist = mbrlist "#INDEX"                                                
                                                                                
   mbrlist = STRSORT(mbrlist)                                                   
                                                                                
return                                 /*@ BB_ADD_ALIASES            */         
/*                                                                              
   Spin thru #INDEX (if any) and the memberlist; insert lines for new           
   members; drop lines for missing members; write the new #INDEX.               
.  ----------------------------------------------------------------- */         
C_LOAD_QUEUE:                          /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   do while thismbr <> 'FF'x                                                    
      if listmbr < thismbr then do     /* lose this one              */         
         if monitor then say listmbr "Drop"                                     
         sw.chgd = "1"                                                          
         call CA_GET_LISTMBR           /*                           -*/         
         end                           /*                            */         
      if listmbr = thismbr then do     /* post to output             */         
         queue " "                                                              
         if mainmbr.thismbr = "" then,                                          
            queue li.liptr                                                      
         else,                         /* always replace an alias    */         
            queue " "Left(thismbr,9) Left("(alias)",11),                        
                           "alias of" mainmbr.thismbr                           
         if monitor then say listmbr "Transfer"                                 
         call CA_GET_LISTMBR           /*                           -*/         
         call CB_GET_THISMBR           /*                           -*/         
         end                           /*                            */         
      if listmbr > thismbr then do     /* add a new line             */         
         queue " "                                                              
         if mainmbr.thismbr = "" then do                                        
            address ISPEXEC "LMMFIND DATAID("lmdataid")",                       
                            "MEMBER("thismbr") STATS(YES)"                      
            if zluser <> "" then do                                             
               parse var zluser zluser . /* strip                    */         
               userdata = udata.zluser                                          
               end                                                              
            else do                                                             
               zlmdate = "No stats"                                             
               zlmtime = ""                                                     
               userdata = ""                                                    
               end                                                              
            queue " "Left(thismbr,9) Left("(new)",11) Left("(new)",8),          
                           zluser zlmdate zlmtime Strip(userdata)               
            end                        /* not an alias               */         
         else,                         /* alias                      */         
            queue " "Left(thismbr,9) Left("(alias)",11) Left("(new)",8),        
                           "alias of" mainmbr.thismbr                           
         if monitor then say thismbr "Add"                                      
         sw.chgd = "1"                                                          
         call CB_GET_THISMBR           /*                           -*/         
         end                           /* thismbr low                */         
   end                                 /* mbrlist                    */         
   /* mbrlist is processed.  Anything left in the LI. array is junk  */         
                                                                                
   if idx_target <> "" then do         /* write elsewhere            */         
      "ALLOC FI($TMP) DA("idx_target") SHR REU"                                 
      sw.chgd = "1"                    /* force the output           */         
      end                                                                       
                                                                                
   if sw.chgd then,                    /* Don't write if no changes  */         
      "EXECIO" queued() "DISKW $TMP (FINIS"                                     
   "FREE  FI($TMP)"                                                             
                                                                                
   address ISPEXEC                                                              
   "LMCLOSE DATAID("lmdataid")"                                                 
   "LMFREE  DATAID("lmdataid")"                                                 
                                                                                
return                                 /*@ C_LOAD_QUEUE              */         
/*                                                                              
   Parse the membername out of the #INDEX text.                                 
.  ----------------------------------------------------------------- */         
CA_GET_LISTMBR:                        /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   castart = liptr + 1                 /* next logical line          */         
   do liptr = castart by 1 while liptr \> li.0                                  
      if li.liptr = "" then iterate                                             
      parse var li.liptr 1 bl1 2 listmbr 10 bl2 12                              
      if Strip(bl1 bl2) <> "" |,                                                
         Words(listmbr) > 1 then iterate                                        
      leave                            /* listmbr is populated       */         
   end                                 /* liptr                      */         
   if liptr > li.0 then listmbr = 'FF'x    /* super-high, run it out */         
                                                                                
return                                 /*@ CA_GET_LISTMBR            */         
/*                                                                              
   Get next member from memberlist.                                             
.  ----------------------------------------------------------------- */         
CB_GET_THISMBR:                        /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   parse var mbrlist  thismbr  mbrlist                                          
                                                                                
return                                 /*@ CB_GET_THISMBR            */         
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
                                                                                
say "  Help for" exec_name                                                      
say "                                                                  "        
say "  "ex_nam"      Generates an 'index-member' for a partitioned     "        
say "                dataset.  This member can be used to document the "        
say "                contents of the subject PDS.  A double-spaced list"        
say "                of all the dataset's members is produced in member"        
say "                #INDEX.                                           "        
say "                                                                  "        
say "  Syntax:   "ex_nam"  <source-dataset>                            "        
say "                      <TARGET idxtarget>                          "        
say "                      <ALIAS>                                     "        
say "                                                                  "        
say "            <source-dataset>   specifies the TSO-form dataset name"        
say "                      to be indexed.                              "        
say "                                                                  "        
say "            <idxtarget>    specifies the TSO-form dataset name    "        
say "                      which will hold the output.  This may be a  "        
say "                      sequential dataset or a member of a         "        
say "                      partitioned dataset, but must exist prior   "        
say "                      to execution.                               "        
say "                                                                  "        
say "            <ALIAS>   requests ALIASes to be identified and       "        
say "                      annotated.                                  "        
pull                                                                            
"CLEAR"                                                                         
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
