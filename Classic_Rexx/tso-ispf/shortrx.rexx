/* REXX       ........    ....                                                  
                          ...                                                   
                                                                                
*/ arg argline                         /* pro-forma quick-start      */         
address TSO                                                                     
arg parms "((" opts                                                             
opts = Strip(opts,"T",")")                                                      
parse var opts "TRACE"  tv  .                                                   
parse value tv "N"  with  tv .                                                  
rc = Trace(tv)                                                                  
                                                                                
                                                                                
exit                                   /*@                           */         
