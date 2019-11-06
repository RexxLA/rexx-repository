/* REXX    SETREFS    Builds backward references for datasets in a
                      catalogued procedure.
 
                      When rigged to modify the PROC JCL, this routine
                      can be run repeatedly without danger.
*/
address ISREDIT
"MACRO (opts)"
upper opts
parse var opts "TRACE" tv .
parse value tv "N" with tv .
rc = Trace(tv)
sw.0insert = Wordpos("INSERT",opts) > 0
 
"CURSOR = 1 1"
parse value "0" with  st# 1 log# 1 .
parse value "" with step.  log.  workddn  altdsn.
"RESET"
"X ALL '//*' 1 "                       /* no comments                */
do forever
   "F P'^' 1  NX"                      /* non-blank in 1             */
   if rc > 0 then leave
   "(text) = LINE .zcsr"               /* carpe textem               */
   if Wordpos("EXEC",text) > 0 then do /* acquire stepname           */
      parse var text "//" stepnm .
      st# = st# + 1
      end ; else,                      /* EXEC                       */
   if Wordpos("DD",text) > 0 then do   /* acquire dsname             */
      parse var text p1 p2 p3 .        /* //ddname dd disp=...       */
      do while Right(p3,1) = ","       /* continued line             */
         "F P'^' 1 NX"                 /* next line                  */
         if rc > 0 then do
            say "Unexpected end of source while searching for",
                "end-of-statement."
            leave
            end
         "(text) = LINE .zcsr"         /* carpe textem               */
         parse var text  .  p3a  .   ;   p3 = p3 || p3a
      end                              /* while                      */
      "(L#) = LINENUM .zcsr"
      parse var p3 "DSN=" dsn ","
      if dsn = "" then iterate
 
      parse var p1 "//" ddname .       /* What if it's concatenated? */
      parse value ddname workddn  with  ddname  .
      workddn = ddname                 /* last used ddname           */
 
      key = "*."stepnm"."ddname
                                       /* log all this information   */
      parse value log#+1 st# stepnm   ddname dsn key L#  with,
                  $log  log.$log    1 log#   .
      end                              /* DD                         */
end
                                        rc = Trace("O"); rc = Trace(tv)
do zz = 1 to log#                      /* every log entry            */
   parse var log.zz  st#  stepnm  ddname  dsn  key  L#  .
   if altdsn.dsn <> "" then,           /* last-known use of dsn      */
      if step.dsn <> stepnm then,      /* ...in a different step     */
         dataid = altdsn.dsn"("dsn")"  /* show backward ref          */
      else dataid = dsn
   else dataid = dsn
 
   log.zz = Right(st#,3) Left(stepnm,8) Left(ddname,8) dataid "("L#")"
 
   altdsn.dsn = key                    /* attach key to dsn          */
   step.dsn   = stepnm                 /* attach ddname to dsn       */
end
                                        rc = Trace("O"); rc = Trace(tv)
if sw.0insert then do                  /* insert notelines           */
   do zz = log# to 1 by -1             /* from the bottom            */
      parse var log.zz  st# stepnm ddn dataid l# .
      if Left(dataid,2) = "*." then do /* referback                  */
         parse var L#  "(" l#  ")"
         parse var dataid refbk "("
         refbk = Left("//"ddn,12)"DD DSN="refbk","
         "LINE_AFTER" L# "= NOTELINE (refbk)"
         end                           /* referback                  */
   end                                 /* zz                         */
   end                                 /* INSERT                     */
else do                                /* list                       */
   address TSO
   "ALLOC FI($TMP) UNIT(VIO) SPACE(1 1) TRACKS",
                  "NEW REU RECFM(V B) LRECL(180) BLKSIZE(0)"
   "EXECIO" log# "DISKW $TMP (STEM LOG. FINIS"
 
   address ISPEXEC
   "LMINIT DATAID($ED) DDNAME($TMP)"
   "EDIT DATAID("$ed")"
   "LMFREE DATAID("$ed")"
   end                                 /* not INSERT                 */
 
exit                                   /*@ SETREFS                   */
