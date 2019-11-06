/* REXX  SHOWFLOW    exposes only subroutine labels and references to           
                     them.  Labels which are not referenced by an               
                     invoking statement are marked to indicate this.            
                                                                                
         19990907 fxc labels are not found because of case-mismatch.            
         20000114 fxc verify label against symbolset                            
                                                                                
*/                                                                              
address ISREDIT                                                                 
'macro (opts)'                                                                  
push opts; pull opts                   /* shift to uppercase         */         
push "0"                               /* init value                 */         
pull monitor  sublist  tv                                                       
monitor = Wordpos("MONITOR",opts) > 0  /*                            */         
                                                                                
parse var opts "TRACE" tv .                                                     
parse value tv "O"  with tv .                                                   
rc = Trace("O"); rc = Trace(tv)                                                 
                                                                                
symbolset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#_$›.!?"                      
"F 'LOCAL_PREINIT:'  1 FIRST "                                                  
if rc = 0 then,                                                                 
   "(lastline) = LINENUM .zcsr "       /* at LOCAL_...               */         
else "(lastline) = LINENUM .zl"        /* bottom                     */         
if monitor then say "Last-line set at" lastline                                 
                                                                                
do ii = 1 to lastline - 1                                                       
   "(text) = LINE" ii                  /* get the text               */         
   if text = "" then iterate                                                    
   if Pos("=", Word(text,1)) > 0 then do         /* assignment       */         
      parse var text  front "=" back   /* split                      */         
      text = front "=" back            /* reconstruct                */         
      end                                                                       
   if Right(Word(text,1) ,1) = ":" then do                                      
      parse var text   label ":" .     /* must be 1st word...        */         
      upper label                                                               
      if Verify(label,symbolset) > 0 then iterate  /* not a label    */         
      if monitor then say,             /*                            */         
         "Label" label "found in >>"Strip(text)"<<"                             
      if Wordpos(label,sublist) = 0 then do                                     
         sublist = sublist Word(text,1)    /* add to list of subrtns */         
         if monitor then say Word(text,1) ii                                    
         end                           /* label not in sublist       */         
      end                              /* 1st word ends with colon   */         
end                                    /* ii                         */         
sublist = Translate( sublist , "" , ":" )                                       
/* sublist is all the labels */                                                 
if monitor then do; say "All the labels:"; say sublist; end                     
                                                                                
rc = trace('o'); if tv ^= '' then rc = trace(tv)                                
push     '61'x    '5c'x    '6b'x     '7d'x     '7f'x       '4d'x                
pull     slash    star     comma     singleq   doubleq     bananal              
                                                                                
"X ALL"                                                                         
upper sublist                          /* all uppercase              */         
do ii = 1 to Words(sublist)            /* for every subroutine       */         
   subr = Word(sublist,ii)             /* isolate                    */         
   loc = "FIRST" ; found = "0"                                                  
   do forever                                                                   
      "F" subr "WORD" loc                                                       
      loc = "NEXT"                                                              
      if rc > 0 then leave                                                      
      if found then iterate                                                     
      "(text) = LINE .zcsr"                                                     
      upper text                       /* all uppercase              */         
      do while Pos(subr,text) > 0                                               
         parse var text front (subr) back                                       
         sepr = Left(back,1)        /* char immed following subr  */            
         if sepr = bananal then found = '1'                                     
         else do                                                                
            front = Reverse(front)                                              
            found   = Wordpos("LLAC",front) = 1,                                
                    | Wordpos("NO",front) = 1 ,                                 
                    | Wordpos("LANGIS",front) = 1                               
            end                     /* sepr ^= banana             */            
         if found then text = ""       /* halt the loop              */         
                  else text = back     /* do it again                */         
      end                              /* Pos(subr                   */         
   end                                                                          
   if monitor & \found & loc="NEXT" then say "Not found in" text                
   if ^found then do                   /* no CALLs !                 */         
      "F" subr "WORD FIRST"                                                     
      "LINE_BEFORE .zcsr = NOTELINE,                                            
               'The following subroutine is not otherwise referenced:'"         
      end                                                                       
end                                    /* ii                         */         
"CURSOR =  1 1 "                       /* Top                        */         
                                                                                
exit                                                                            
