/* REXX                                                                         
*/                                                                              
arg tv .                                                                        
parse value tv "N" with tv .                                                    
rc = Trace(tv)                                                                  
ASCBASXB = d2x(c2d(Storage(224,4))+108)                                         
ASXBSENV = d2x(c2d(Storage(ASCBASXB,4))+200)                                    
ACEEUNAM = d2x(c2d(Storage(ASXBSENV,4))+100)                                    
Adr = c2x(Storage(ACEEUNAM,4))                                                  
Name = Storage(d2x(c2d(Storage(ACEEUNAM,4))+1),c2d(Storage(Adr,1))-1)           
Name = Strip(Name,"B"," ")                                                      
if Sysvar("SYSNEST") = "YES",                                                   
   then return(Name)                                                            
   else say Name                                                                
