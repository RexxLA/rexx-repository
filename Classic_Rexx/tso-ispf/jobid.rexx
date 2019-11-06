/* REXX    JOBID      Get Jobname and Jobnumber from internal
                      control blocks.
*/
address TSO
 
signal on syntax
signal on novalue
 
@ascb    = Right(c2x(Storage(224,4)),7) /* ASCBaddr is at X'224'     */
@cvt     = Right(c2x(Storage(10,4)),7) /* CVTaddr is at X'10'        */
sysname  = Storage(d2x(x2d(@cvt) + x2d('154')),8)
                             /* SYSNAME is X'154' bytes into the CVT */
 
@smca    = Right(c2x(Storage(d2x(x2d(@cvt) + x2d('c4')),4)),7)
                             /* SMCAaddr is X'C4' bytes into the CVT */
cpuid    = Storage(d2x(x2d(@smca) + x2d('10')),4)
                       /* DW92, e.g.; located 16 bytes into the SMCA */
 
@tcb     = Right(c2x(Storage(21c,4)),7)  /* TCBaddr is at X'21C'     */
@tct     = Right(c2x(Storage(d2x(x2d(@tcb) + x2d('a4')),4)),7)
                              /* TCTaddr is X'A4' bytes into the TCB */
@jscb    = Right(c2x(Storage(d2x(x2d(@tcb) + x2d('b4')),4)),7)
                             /* JSCBaddr is X'B4' bytes into the TCB */
@ssib    = Right(c2x(Storage(d2x(x2d(@jscb) + x2d('13c')),4)),7)
                           /* SSIBaddr is X'13C' bytes into the JSCB */
jobnum   = Storage(d2x(x2d(@ssib) + x2d('0c')),8)
                           /* JOBnumber is X'0C' bytes into the SSIB */
 
@tiot    = Right(c2x(Storage(d2x(x2d(@tcb) + x2d('c')),4)),7)
                                /* TIOTaddr is 12 bytes into the TCB */
jobname  = Storage(@tiot,8)
                         /* JOBname is the first 8 bytes of the TIOT */
 
text = "JN="jobname " J#="jobnum "  CPU="cpuid "  Sysn="sysname
if Sysvar("sysnest") = "YES" then,
   push text
else say text
 
exit                                   /*@ JOBID                     */
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
SYNTAX:                                /*@                           */
   errormsg = "REXX error" rc "in line" sigl":" errortext(rc)
   say errormsg
   zsigl = sigl
   signal SHOW_SOURCE                  /*@ SYNTAX                    */
/*
.  ----------------------------------------------------------------- */
SHOW_SOURCE:                           /*@                           */
   if sourceline() ^= "0" then
      say sourceline(zsigl)
   rc =  trace("?R")
   nop
   exit                                /*@ SHOW_SOURCE               */
