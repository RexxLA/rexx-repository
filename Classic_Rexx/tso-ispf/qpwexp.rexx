/* REXX    QPWEXP     Calculate the expiration date of the user's
                        password.
                      If RACF doesn't run on this system, the response
                      to the "LU" command is "RACF PRODUCT DISABLED".
                      Call the ACF_SYS code to calc the date on an
                      ACF2 system.
 
           Written by Frank Clarke 20160526
 
*/ arg argline                         /* pro-forma quick-start      */
address TSO
 
   parse value "0" with ,
               sw.   usrname  pdate  pinterval  .
 
arg parms "((" opts
opts = Strip(opts,"T",")")
parse var opts "TRACE"  tv  .
parse value tv "N"  with  tv .
sw.0ListAll = WordPos("DUMP",parms) > 0
sw.0Stack   = WordPos("STACK",opts) > 0
rc = Trace("O"); rc = Trace(tv)
 
   uid   = Userid()
   rc = Outtrap("OUT.")                /* trap command output        */
   secprod = "R"                       /* RACF                       */
   "LU" uid "TSO"
   lurc = rc
   if lurc > 20 then do
      rc = Outtrap("OFF") ; rc = Outtrap("OUT.")      /* reset       */
      secprod = "A"                    /* ACF2                       */
      queue "LIST *"                   /* ACF2 command               */
      queue "END"                      /* ACF2 command               */
      "ACF"                            /* provoke ACF2               */
      end
   rc = Outtrap("OFF")
                                       /* process command output     */
   do ss = 1 to out.0
      if secprod = "R" then do
         if Pos("PASSDATE=",out.ss) > 0 then do
            parse var out.ss "PASSDATE=" pdate . /* yy.ddd */
            parse var pdate yy "." ddd
            bpdate = Date("B",yy||ddd,"J")    /* date pw last chgd   */
            end
         if Pos("PASS-INTERVAL=",out.ss) > 0 then,
            parse var out.ss "PASS-INTERVAL=" mxday .
         if Pos("NAME=",out.ss) > 0 then,
            parse var out.ss "NAME=" usrname "OWNER"
         end                           /* R                          */
      else,
      if secprod = "A" then do
         if Pos("PSWD-DAT(",out.ss) > 0 then do
            parse var out.ss "PSWD-DAT(" pdate ")" /* Date("U")      */
            bpdate = Date("B",pdate,"U")
            end
         if Pos("MAXDAYS",out.ss) > 0 then ,
            parse var out.ss "MAXDAYS(" mxday ")" .
         if Word(out.ss,1) = uid then,
            parse var out.ss 48 usrname
         end                           /* A                          */
      if usrname <> "" & pdate <> "" & mxday <> "" then leave ss
   end                                 /* ss                         */
 
   bpdate  = bpdate + mxday
   expdate = Date("S",bpdate,"B")
   if sw.0Stack then do
      queue bpdate  secprod  mxday  usrname
      end
   else,
   if sw.0ListAll then do
      msglim  = 110
      do nn = 1 to out.0
         msgtext = out.nn
         do while Length(msgtext) > msglim
            pt    = LastPos(" ",msgtext,msglim)
            slug  = Left(msgtext,pt)
            queue   slug
            msgtext = Copies(" ",21)Substr(msgtext,pt)
         end                           /* while msglim               */
         queue msgtext
      end                              /* nn                         */
                                     rc = Trace("O"); rc = Trace(tv)
      push " "
      push "Your password will expire on",
          Translate("CcYy-Mm-Dd",expdate,"CcYyMmDd")
      "ALLOC FI($RPT) UNIT(SYSDA) NEW REU SPACE(1) TRACKS",
             "RECFM(V B) LRECL(121) BLKSIZE(0)"
      "EXECIO" queued() "DISKW $RPT (FINIS"
      address ISPEXEC
      "LMINIT DATAID(RPT) DDNAME($RPT)"
      "VIEW DATAID(&RPT)"
      end                              /* ListAll                    */
   else,
      say "Your password will expire on",
          Translate("CcYy-Mm-Dd",expdate,"CcYyMmDd")
 
exit                                   /*@ QPWEXP                    */
