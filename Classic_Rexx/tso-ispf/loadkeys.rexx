/* REXX    LOADKEYS   Set my default PFKey values.  This loads values 
                      to ISRPROF.
 
           Written by Frank Clarke 20161011
 
     Modification History
     ccyymmdd xxx .....
                  ....
 
*/ arg argline                         /* pro-forma quick-start      */
address TSO
parse source  . . exec_name .          /* needed by HELP             */
parse value "0 0 0 0" with inispf branch sw. .
arg parms "((" opts
/* if WordPos("?",parms) > 0 then call HELP */
opts = Strip(opts,"T",")")
parse var opts "TRACE"  tv  .
parse value tv "N"  with  tv .         /* default to N               */
rc = Trace("O"); rc = Trace(tv)
 
address ISPEXEC
zpf01 = "Help"
zpf02 = "Split "
zpf03 = "End "
zpf04 = "Reset "
zpf05 = ":tf70 "
zpf06 = ":ts "
zpf07 = "Up "
zpf08 = "Down "
zpf09 = "Swap "
zpf10 = "Left "
zpf11 = "Right "
zpf12 = "Save "
zpf13 = "Sort Cha "
zpf14 = "Split "              /* replica */
zpf15 = "End "                /* replica */
zpf16 = "Nop "
zpf17 = "Rfind "
zpf18 = "Rchange "
zpf19 = "Up "                 /* replica */
zpf20 = "Down "               /* replica */
zpf21 = "Isolate "
zpf22 = "Makepara "
zpf23 = "TSO %addcmds "                                                
amt   = "CSR"                          /* scroll values              */
scin  = "CSR"                                                          
zamt  = "CSR"                                                          
zsced = "CSR"                                                          
zscml = "CSR"                                                          
zusc  = "CSR"                                                          
zrefamt = "CSR"                                                        
                                      rc = Trace("O"); rc = Trace(tv)  
zpf24 = "Retrieve "                                                    
"VPUT (",                                                              
       "ZPF01 ZPF02 ZPF03 ZPF04 ZPF05 ZPF06 ZPF07 ZPF08 ZPF09 ZPF10",  
       "ZPF11 ZPF12 ZPF13 ZPF14 ZPF15 ZPF16 ZPF17 ZPF18 ZPF19 ZPF20",  
       "ZPF21 ZPF22 ZPF23 ZPF24",                                      
       "AMT SCIN ZAMT ZSCED ZSCML ZUSC ZREFAMT",                       
     ")"                                                               
 
exit                                   /*@ LOADKEYS                  */
