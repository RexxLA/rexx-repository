/* REXX           Place all necessary commands on the queue before
                  calling this routine.
*/
address TSO
"ALLOC DDNAME(SYSUDUMP) DSNAME(*)"
"ALLOC DDNAME(SYSPRINT) DSNAME(*)"
 
"ALLOC DDNAME(SYSIN) NEW TRACKS SPACE(1,1) RECFM(F,B) LRECL(80)"
 
"EXECIO" queued() "DISKW SYSIN (FINIS"
 
queue "RUN PROGRAM(DSNTIAD) PLAN(NSSTIAD) LIB('DB2TSG.RUNLIB.LOAD')"
queue "END"
"CLEAR"
"DSN SYSTEM(DB2)"
 
"FREE DDNAME(SYSUDUMP)"
"FREE DDNAME(SYSPRINT)"
"FREE DDNAME(SYSIN)"
