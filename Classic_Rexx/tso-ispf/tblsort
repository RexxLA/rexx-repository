PROC   0
/* --------------------------------------------------------------------
/*
/* Sort an ISPF table.      This task is done in a CLIST because REXX
/* incurs substantial overhead for ISPF table sorting due to it trying
/* to store each row-variable for each row it must handle.  This is
/* architecturally a part of REXX's method and cannot be overcome,
/* therefore, table sorts should be handled by CLISTs.
/*
/* The table should be open before calling this routine.
/*
/* --------------------------------------------------------------------
 
ERROR DO
   SET   &LASTCC = &RC
   RETURN
   END
 
ISPEXEC VGET ($TN$ SORTSEQ DEBUG) SHARED
 
IF &DEBUG = DEBUG THEN CONTROL   MSG   SYMLIST   CONLIST   LIST
                  ELSE CONTROL NOMSG NOSYMLIST NOCONLIST NOLIST
 
ISPEXEC TBSORT &$TN$ FIELDS(&SORTSEQ)
 
IF &LASTCC NE 0 THEN DO
   &ZERRSM   = &STR(TBSORT ERROR)
   &ZERRLM   = &STR(TBSORT DELIVERED RC=&LASTCC FOR SORTSPEC +
                    &SORTSEQ)
   &ZERRALRM = YES
   &ZERRHM   = ISR00000
   ISPEXEC SETMSG MSG(ISRZ002)
   END
