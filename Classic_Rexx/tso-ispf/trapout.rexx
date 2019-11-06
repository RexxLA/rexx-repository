/* Rexx */ /* This is REXX EXEC "TRAPOUT" to trap line output */
address TSO
rc=trace("O")
"EXECUTIL TE"
Parse arg TSOCMD     /* A TSO Command will be the input parm */
rc = Outtrap("OUT.")  /* Turn on outtrap, to rexx stem OUT. */
(TSOCMD) "((TRACE R"    /* Do the command */
rc = Outtrap("OFF")

If OUT.0 > 0 Then Do             /* If any output, write to the file */
   dsdate = Right(date("S"),6)           /* 950118 maybe               */
   dstime = time()
   parse var dstime th ":" tm ":" ts .
   dstime = Right(th,2,0)Right(tm,2,0)Right(ts,2,0)
   dsn = "TRAPOUT.D"dsdate".T"dstime".TRCLIST"
   X = Msg("OFF");"DEL" dsn ;X= Msg("ON")
   "ALLOC FI(TRAPOUT) DA("dsn") NEW CATALOG REU SP(5,5) CYL ",
            "RECFM(V B) LRECL(255) BLKSIZE(0)"
   "EXECIO" out.0 "DISKW TRAPOUT (STEM OUT. FINIS"
   "FREE  FI(TRAPOUT)"
   end