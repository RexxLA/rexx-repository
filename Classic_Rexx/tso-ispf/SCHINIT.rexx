/* REXX      SCHINIT      Initialization for SCHED                   */
textds   = Userid()".SCHED.TEXT"       /* source for lits & eyeballs */
printds  = Userid()".SCHED.PRTFORM"    /* output target              */
push textds printds
exit
