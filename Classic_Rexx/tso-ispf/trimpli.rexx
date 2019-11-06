/* REXX   TRIMPLI     easily gets rid of billions and billions of               
               pages of yukky SQL stuff from your compiler listings.            
                                                                                
               Save the PL/1 SYSPRINT file to a dataset, edit it,               
               and execute TRIMPLI as a "COMMAND ===> trimpli".                 
               When you print the listing, all the SQL junk pages               
               will be missing.                                                 
*/                                                                              
address ISREDIT                        /* my default address space   */         
lvl = "1"                                                                       
"macro (opts)"                         /* I'm an ISPF EditMacro      */         
parse upper var opts opts              /* shift to uppercase         */         
parse var opts "TRACE" tv .            /* see if there's a trace val */         
parse value tv "O" with tv .           /* default to OFF             */         
rc = Trace(tv)                         /* activate TRACE             */         
                                                                                
test    = WordPos("TEST", opts)>0      /* Test-mode ?                */         
as_note = WordPos("NOSTATS",opts)>0    /* stats as data ?            */         
if test then lvl = "0"                                                          
                                                                                
linetag = "    <trimpli >"             /* to mark deletions          */         
"RESET"                                                                         
"SEEK '1' 1 ALL"                                                                
"(origpgs) = SEEK_COUNTS"              /* pages at start             */         
"SEEK P'^' LAST"                                                                
"(origlns) = CURSOR"                   /* lines at start             */         
                                                                                
"X ALL"                                /* exclude everything         */         
                                                                                
"F 'ATTRIBUTE AND CROSS-REF'"                                                   
"F 'SQLPLIST'"                                                                  
if rc > 0 then exit                                                             
                                                                                
"LABEL .zcsr = .A" lvl                 /* mark the line "A"          */         
"F 'SQLPLIST' LAST"                                                             
"F ' '  2"                                                                      
"LABEL .zcsr = .B" lvl                 /* mark the line "B"          */         
"RESET .a .b"                          /* pop all lines betw A and B */         
"DELETE ALL NX"                        /* aloha, any shown lines...  */         
                                                                                
"UP MAX"                                                                        
do forever                                                                      
   "F 'SQLPLIST' "                                                              
   if rc > 0 then leave                                                         
   "F 'DO;' 12 PREV"                                                            
   "LABEL .zcsr = .A" lvl              /* mark the line "A"          */         
   "F 'END;' 12 NEXT"                                                           
   "LABEL .zcsr = .B" lvl              /* mark the line "A"          */         
   "RESET .a .b"                       /* pop all lines betw A and B */         
   "DELETE ALL NX"                     /* aloha, any shown lines...  */         
end                                    /* forever                    */         
                                                                                
"SEEK '1' 1 ALL"                                                                
"(remnpgs) = SEEK_COUNTS"              /* pages after clean-up       */         
"SEEK P'^' LAST"                                                                
"(remnlns) = CURSOR"                   /* lines after clean-up       */         
                                                                                
diffpgs = origpgs - remnpgs            /* pages saved                */         
difflns = origlns - remnlns            /* lines saved                */         
origlns = origlns + 0                                                           
origpgs = origpgs + 0                                                           
remnlns = remnlns + 0                                                           
remnpgs = remnpgs + 0                                                           
"LABEL 000002 = .T" lvl                /* mark the line "T"          */         
if as_note then form = "NOTELINE"                                               
           else form = "DATALINE"                                               
                                                                                
                                       /* report on how well TRIMPLI */         
                                       /* did its job :-)            */         
tlmsg = "  TRIMPLI has reduced this listing from",                              
     Right(origlns,5) "lines (" Right(origpgs,4)" pages ) "                     
"LINE_BEFORE .T =" form "'" tlmsg "'"                                           
                                                                                
tlmsg = "                                     to",                              
     Right(remnlns,5) "lines (" Right(remnpgs,4)" pages ),"                     
"LINE_BEFORE .T =" form "'" tlmsg "'"                                           
                                                                                
tlmsg = "                            a saving of",                              
     Right(difflns,5) "lines (" Right(diffpgs,4)" pages )."                     
"LINE_BEFORE .T =" form "'" tlmsg "'"                                           
                                                                                
"CURSOR ="1 0                          /* put the cursor up top      */         
                                                                                
exit                                                                            
/*                                                                              
.  ----------------------------------------------------------------- */         
NOLINES:                                                                        
   "RESET"                                                                      
   "CURSOR ="1 0                                                                
   msg="  No lines deleted; probable re-run."                                   
   "LINE_BEFORE .zcsr = NOTELINE '"msg"'"                                       
   exit     /* NOLINES */              /* don't return, bail out     */         
/*                                                                              
.  ----------------------------------------------------------------- */         
NOT_DB2:                                                                        
   "RESET"                                                                      
   "CURSOR ="1 0                                                                
   msg="  DB2 tell-tales not found.  No lines deleted."                         
   "LINE_BEFORE .zcsr = NOTELINE '"msg"'"                                       
   exit     /* NOT_DB2 */              /* don't return, bail out     */         
