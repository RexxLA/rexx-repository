/* REXX    DIRREAD    Read directory details directly

           Written by .....

     Impact Analysis
.    SYSPROC   TRAPOUT

     Modification History
     ccyymmdd xxx .....
                  ....

*/ arg argline                                                                  
address TSO                            /* REXXSKEL ver.19991109      */         
arg parms "((" opts                                                             
 
signal on syntax 
signal on novalue 

call TOOLKIT_INIT                      /* conventional start-up     -*/         
rc     = trace(tv)
info   = parms                         /* to enable parsing          */         
  
parse var info   dsn  .

"Alloc Fi(PDS) Da("dsn") Shr Reuse ",
              "RECFM(F) DSORG(PS) LRECL(256) BLKSIZE(256)"                      
"ExecIO * DiskR PDS (Stem dir. Finis)"      /* read PDS directory     */        
"FREE FI(PDS)" 

Do blk = 1 to dir.0
 usedbytes = C2d(Substr(dir.blk,1,2))
 index = 3                                  /* skip past used bytes   */        
 Do While index < usedbytes
  If Substr(dir.blk,index,8) = "FFFFFFFFFFFFFFFF"x Then                         
   Signal direof
  pds2name = Substr(dir.blk,index,8)        /* member name            */        
/*tt       = Substr(dir.blk,index+8,2)  */
/*r        = Substr(dir.blk,index+10,1) */
  index    = index + 11                     /* skip past name and ttr */        
  pds2indc = Substr(dir.blk,index,1) 
  len      = Bitand(pds2indc,"1F"x)         /* isolate user data leng */        
  userlen  = C2d(len) * 2                   /* halfwords to bytes     */        
  userdata = Substr(dir.blk,index,userlen)  /* get userdata           */        
  bits     = x2b(C2x(Substr(userdata,1,1)))

  If (Substr(bits,1,1) = "1") Then
     Alias = "*Alias"
  Else
     Alias = Right(" ",6)

  vr = C2d(Substr(userdata,2,1))
  if vr > 0 then do 
     mo      = C2d(Substr(userdata,3,1))
     created = C2x(Substr(userdata,6,4))
     date    = Substr(created,1,7)
     Call JULCONV 
     created = date
     changed = C2x(Substr(userdata,10,4))
     date    = Substr(changed,1,7)
     Call JULCONV
     changed = date  
     chnghrs = C2x(Substr(userdata,14,1))
     chngmin = C2x(Substr(userdata,15,1))
     chngtim = chnghrs":"chngmin   
     size    = C2d(Substr(userdata,16,2))
     init    = C2d(Substr(userdata,18,2)) 
     mod     = C2d(Substr(userdata,20,2))
     id      = Substr(userdata,22,8)
     end 
  else parse value "Stats?" with alias vr mo created changed chngtim,           
                           size init mod id

  display = Right(vr,2,"0")"."Right(mo,2,"0"),
            Left(created,8) Left(changed,8),
            chngtim Right(size,5)Right(init,5)Right(mod,5) id                   
  If (Substr(created,1,2) = "40") Then 
     Say pds2name alias 
  Else 
     Say pds2name alias display 
  index = index + userlen + 1               /* skip past user data    */        
 End 
End 
/**********************************************************************/        
DIREOF:                                                                         
Exit 0                                                                          
/**********************************************************************/        
JULCONV:                                    /* convert julian to      */        
                                            /*    gregorian           */        
parse var date 3 juldt 
date = Date("U",juldt,"J")             /* convert to U               */         
return                                 /*                            */         
/* ---------------------------------------------------------         */         
year = Substr(date,1,4)
yy   = Substr(date,3,2)
If (Substr(year,1,2) = "00") Then 
 year = "19"||Substr(year,3,2) 
else, 
 year = "20"||Substr(year,3,2)
Call LEAPTEST 
ddd  = Substr(date,5,3) 
dd = ddd 
If (dd > (59 + t)) Then 
 dd = dd+2-t
mm = (((dd+91)*100)%3055)
dd = dd+91-(mm*3055)%100 
mm = mm - 2 
yy = Right(yy,2,"0")
mm = Right(mm,2,"0") 
dd = Right(dd,2,"0") 
date = yy||"/"||mm||"/"||dd 
Return 
/**********************************************************************/        
LEAPTEST:                                   /* standard leap year test*/        
   t = (year//4 = 0) - (year//100 = 0) + (year//400 = 0) 
Return

if \sw.nested then call DUMP_QUEUE     /*                           -*/         
exit                                   /*@                           */         
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
             /* The following template may be used to                           
                customize HELP-text for this routine.                           
say "  "ex_nam"      ........                                          "        
say "                ........                                          "        
say "                                                                  "        
say "  Syntax:   "ex_nam"  ..........                                  "        
say "                      ..........                                  "        
say "                                                                  "        
say "            ....      ..........                                  "        
say "                      ..........                                  "        
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
                                                                    .*/         
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