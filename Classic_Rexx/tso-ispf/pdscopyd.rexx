/* REXX    PDSCOPYD   copy a member from one PO dataset to another when
                      the DCBs are incompatible for use by IEBCOPY.
                      This also serves as a replacement for IEBCOPY at
                      installations which do not allow its use in the 
                      foreground. 
   
           Written by Frank Clarke, Richmond, 19991005

     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     19991118 fxc upgrade from v.19990923 to v.19991109 
     20010320 fxc include seconds in zlmtime and use 4-digit year 
     20010509 fxc dsnames could be in quotes...

*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */         
arg parms "((" opts

signal on syntax 
signal on novalue 

call TOOLKIT_INIT                      /* conventional start-up     -*/         
rc     = trace(tv) 
info   = parms                         /* to enable parsing          */         

call A_INIT                            /*                           -*/         
"NEWSTACK"                             /* isolate all queues         */         
                                    if \sw.0error_found then, 
call B_ACQUIRE_INPUT                   /*                           -*/         
                                    if \sw.0error_found then,
call C_LOAD_OUTPUT                     /*                           -*/         
"DELSTACK"                             /* expose all queues          */         

if \sw.nested then call DUMP_QUEUE     /*                           -*/         
exit(save_rc)                          /*@ PDSCOPYD                  */         
/* 
.  ----------------------------------------------------------------- */         
A_INIT:                                /*@                           */         
   if branch then call BRANCH
   address TSO
 
   parse value "20"        with,
               save_rc  .
   call AA_KEYWDS                      /*                           -*/         
 
   dsnimbr = "'"dsni"("memi")'"
   if monitor then say, 
      "Input:" dsnimbr
 
   dsnombr = "'"dsno"("memo")'"
   if monitor then say,
      "Output:" dsnombr
 
   if Sysdsn(dsnimbr) <> "OK" then,    /* input member must exist    */         
      helpmsg = helpmsg,
               "Specified or implied source member must exist. "

   if Sysdsn("'"dsno"'") <> "OK" then, /* output dataset must exist  */         
      helpmsg = helpmsg,
               "Specified or implied target dataset must exist. " 
 
   if helpmsg <> "" then call HELP     /* ...and don't come back    -*/         

return                                 /*@ A_INIT                    */         
/* 
.  ----------------------------------------------------------------- */         
AA_KEYWDS:                             /*@                           */         
   if branch then call BRANCH 
   address TSO
 
   dsni      = KEYWD("FROMDS")
   dsno      = KEYWD("TODS")
   memi      = KEYWD("FROMMBR")
   memo      = KEYWD("TOMBR")

 
   if dsni""memi = "" then do
      parse var info source info       /* first token may be source  */         
      if Left(source,1) = "'" then do  /* source is quoted           */         
         source = Strip(source,,"'")
         sw.0quotedsrc = "1" 
         end 
 
      if Pos( "(",source ) > 0 then do /* there is a banana          */         
         parse var source front "(" memi ")" back 
         source = front""back          /* reconstruct                */         
         end 
 
      if sw.0quotedsrc then , 
         dsni = "'"source"'" 
      else , 
         dsni = source 
      end 
 
 
   if dsno""memo = "" then do
      parse var info target info       /* next token may be target  */          
      if Left(target,1) = "'" then do  /* target is quoted           */         
         target = Strip(target,,"'")
         sw.0quotedtgt = "1" 
         end 
 
      if Pos( "(",target ) > 0 then do /* there is a banana          */         
         parse var target front "(" memo ")" back
         target = front""back          /* reconstruct                */         
         end
 
      if sw.0quotedtgt then , 
         dsno = "'"target"'"
      else , 
         dsno = target
      end
 
 
   parse value memo  memi  with  memo  .  /* default output to input */         
   parse value dsno  dsni  with  dsno  .  /* default output to input */         
 
   if Words(dsni dsno memi memo) < 3 then,
      helpmsg = helpmsg,
               "Invalid parm: too few tokens. "
 
 
   if Left(dsni,1) = "'" then,
      dsni = Strip(dsni,,"'")          /* unquoted                   */         
   else, 
      dsni = Userid()"."dsni           /* fully-qualified            */         
 
   if Left(dsno,1) = "'" then, 
      dsno = Strip(dsno,,"'")          /* unquoted                   */         
   else,
      dsno = Userid()"."dsno           /* fully-qualified            */         
   
   if dsni""memi = dsno""memo then, 
      helpmsg = helpmsg, 
               "The source cannot be the same as the target. "
 
   if helpmsg <> "" then call HELP     /* ...and don't come back    -*/         
 
return                                 /*@ AA_KEYWDS                 */         
/* 
.  ----------------------------------------------------------------- */         
B_ACQUIRE_INPUT:                       /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   call BA_INPUT_STATS                 /*                           -*/         
                                    if \sw.0error_found then,                   
   call BB_INPUT_DATA                  /*                           -*/         
                                                                                
return                                 /*@ B_ACQUIRE_INPUT           */         
/*                                                                              
   Get the ISPF statistics (if any) for the input member.                       
.  ----------------------------------------------------------------- */         
BA_INPUT_STATS:                        /*@                           */         
   if branch then call BRANCH                                                   
   address ISPEXEC                                                              
                                                                                
   parse value "" with ,                                                        
               zlc4date  zlm4date  zlmtime  zlmsec  zlcnorc  zlinorc,           
               zlmnorc   zluser    zlvers   zlmod  .                            
                                                                                
  "LMINIT  DATAID(BASEID) DATASET('"dsni"')"                                    
  if rc > 0 then do                                                             
      zerrlm = exec_name "("BRANCH("ID")")",                                    
               zerrlm                                                           
      address ISPEXEC "SETMSG  MSG(ISRZ002)"                                    
      sw.0error_found = "1"; return                                             
     end                                                                        
  "LMOPEN  DATAID("baseid")"                                                    
  if rc > 0 then do                                                             
      zerrlm = exec_name "("BRANCH("ID")")",                                    
               zerrlm                                                           
      address ISPEXEC "SETMSG  MSG(ISRZ002)"                                    
      sw.0error_found = "1"                                                     
     end                                                                        
  "LMMFIND DATAID("baseid") MEMBER("memi") STATS(YES)"                          
  if rc > 0 & \sw.0error_found then do                                          
      zerrlm = exec_name "("BRANCH("ID")")",                                    
               zerrlm                                                           
      address ISPEXEC "SETMSG  MSG(ISRZ002)"                                    
      sw.0error_found = "1"                                                     
     end                                                                        
                                                                                
  if zlmsec <> "" then,                                                         
     zlmtime = zlmtime":"zlmsec        /* hh:mm:ss                   */         
  parse value zlcnorc zlinorc zlmnorc    with,                                  
              zlcnorc zlinorc zlmnorc .         /* strip             */         
                                                                                
  "LMCLOSE DATAID("baseid")"                                                    
  "LMFREE  DATAID("baseid")"                                                    
   if monitor then say,                                                         
      "Available stats:",                                                       
               zlc4date  zlm4date  zlmtime  zlcnorc  zlinorc,                   
               zlmnorc   zluser    zlvers   zlmod                               
                                                                                
return                                 /*@ BA_INPUT_STATS            */         
/*                                                                              
   Read the input member into the queue.                                        
.  ----------------------------------------------------------------- */         
BB_INPUT_DATA:                         /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   "ALLOC FI($DTA) DA("dsnimbr") SHR REU"                                       
   "EXECIO      *      DISKR $DTA (FINIS"                                       
   if monitor then say,                                                         
      queued() "lines read from" dsnimbr                                        
                                                                                
return                                 /*@ BB_INPUT_DATA             */         
/*                                                                              
.  ----------------------------------------------------------------- */         
C_LOAD_OUTPUT:                         /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   call CA_OUTPUT_DATA                 /*                           -*/         
                                    if \sw.0error_found then,                   
   call CB_OUTPUT_STATS                /*                           -*/         
   "FREE  FI($DTA)"                                                             
                                                                                
return                                 /*@ C_LOAD_OUTPUT             */         
/*                                                                              
   Write the queued text to the output member.                                  
.  ----------------------------------------------------------------- */         
CA_OUTPUT_DATA:                        /*@                           */         
   if branch then call BRANCH                                                   
   address TSO                                                                  
                                                                                
   if noupdt then do                                                            
      say "Write to" dsnombr "suppressed because of NOUPDT."                    
      return                                                                    
      end                                                                       
                                                                                
   "ALLOC FI($DTA) DA("dsnombr") SHR REU"                                       
   "EXECIO" queued() "DISKW $DTA (FINIS"                                        
   if monitor then say,                                                         
      "Stack written to" dsnombr                                                
                                                                                
return                                 /*@ CA_OUTPUT_DATA            */         
/*                                                                              
   Load the ISPF statistics of the input member to the output member.           
.  ----------------------------------------------------------------- */         
CB_OUTPUT_STATS:                       /*@                           */         
   if branch then call BRANCH                                                   
   address ISPEXEC                                                              
                                                                                
   "LMINIT    DATAID(BASEID)   DATASET('"dsno"')"                               
   if monitor then say,                                                         
   "LMMSTATS  DATAID("baseid")" "MEMBER("memo")" "USER("zluser")" ,             
             "VERSION("zlvers")" "MODLEVEL("zlmod")" ,                          
             "MODDATE4("zlm4date")" "MODTIME("zlmtime")" ,                      
             "CREATED4("zlc4date")" "CURSIZE("zlcnorc")" ,                      
             "INITSIZE("zlinorc")" "MODRECS("zlmnorc")"                         
   if noupdt then do                                                            
      say "Stats update of" dsnombr "suppressed because of NOUPDT."             
      end                                                                       
   else,                                                                        
   "LMMSTATS  DATAID("baseid")" "MEMBER("memo")" "USER("zluser")" ,             
             "VERSION("zlvers")" "MODLEVEL("zlmod")" ,                          
             "MODDATE4("zlm4date")" "MODTIME("zlmtime")" ,                      
             "CREATED4("zlc4date")" "CURSIZE("zlcnorc")" ,                      
             "INITSIZE("zlinorc")" "MODRECS("zlmnorc")"                         
   if rc > 0 then do                                                            
      zerrsm = "Stats Error"                                                    
      zerrlm = "Unable to modify to the ISPF Stats. RC = "rc                    
      "SETMSG MSG(ISRZ002)"                                                     
      end                              /* rc > 0                     */         
   else save_rc = 0                                                             
                                                                                
   "LMFREE     DATAID("baseid")"                                                
                                                                                
return                                 /*@ CB_OUTPUT_STATS           */         
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
say "  "ex_nam"      copy a member from one PO dataset to another when "        
say "                the DCBs are incompatible for use by IEBCOPY.     "        
say "                                                                  "        
say "  Syntax:   "ex_nam"  <FROMDS  dsni>                    (Required)"        
say "                      <FROMMBR mbri>                    (Required)"        
say "                      <TODS    dsno>                              "        
say "                      <TOMBR   mbro>                              "        
say "                                                                  "        
say "            A minimum of three of these parameters is required,   "        
say "            enough to specify or imply both a source and a target."        
say "            Missing output parameters will default to the input   "        
say "            value.  The source and target may not be identical.   "        
say "                                                                  "        
say "            <dsni>    identifies the source dataset (TSO format)  "        
say "                                                                  "        
say "            <mbri>    identifies the source membername            "        
say "                                                                  "        
say "            <dsno>    identifies the target dataset (TSO format)  "        
say "                                                                  "        
say "            <mbro>    identifies the target membername            "        
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
/*     REXXSKEL  back-end removed for space */