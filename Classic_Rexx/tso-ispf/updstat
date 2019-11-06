/* REXX    UPDSTAT    Update the stats                                          
                                                                                
           Written by G052811 Chris Lewis 950802                                
                                                                                
     Modification History                                                       
                ....                                                            
                                                                                
*/                                                                              
address ispexec                        /*                            */         
arg memname dataset vv mm created changed time size init mod id .               
                                       /*                            */         
"control errors return"                /*                            */         
                                       /*                            */         
 "lminit    dataid(baseid)   dataset('"dataset"')"                              
 if rc > 0 then return(rc)             /*                            */         
                                       /*                            */         
 "LMMSTATS DATAID("baseid") MEMBER("memname") USER("id") VERSION("vv")",        
                          "MODLEVEL("mm") MODDATE("changed") MODTIME("time")",  
                          "CREATED("created") CURSIZE("size") INITSIZE("init")",
                          "MODRECS("mod")"                                      
 stat_rc = rc                          /*                            */         
                                       /*                            */         
 "lmfree     dataid("baseid")"         /*                            */         
                                                                                
                                       /*                            */         
RETURN(stat_rc)                        /*@                           */         
