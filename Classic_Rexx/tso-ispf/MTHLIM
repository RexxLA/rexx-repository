/* REXX    MTHLIM     Given a month-indicator (YYYYMM),
.                     deliver: Day-of-the-week for YYYYMM01, and
                               Number of days in Month.
                      This was written to support SCHED.
 
                Written by Frank Clarke, Oldsmar FL
 
     Modification History
     20040319 fxc use REXX date function for basedate
 
*/
nested = Sysvar("SYSNEST") = "YES"
 
arg parms "((" opts
opts  =  Strip(opts,,")")              /* clip trailing paren        */
 
parse var opts "TRACE" tv .
parse value tv "N" with tv .           /* guarantee a value          */
 
parse var parms date .
if date = "" then date = Left(Date("S"),6)  /* yyyymm                */
 
rc = trace("O"); rc = trace(tv)
 
parse var date yyyy 5 mm 7 .
if Datatype(yyyy,"W") +,
   Datatype(mm,"W") < 2 then do
   say "Incorrect date format -- non-numeric."
   if nested then push 0 0
   exit
   end
 
if mm < 1 | mm > 12 then do
   say "Incorrect date format -- Month" mm "out of range."
   if nested then push 0 0
   exit
   end
 
   push   31   28   31   30   31   30   31   31   30    31    30    31
   pull mm.1 mm.2 mm.3 mm.4 mm.5 mm.6 mm.7 mm.8 mm.9 mm.10 mm.11 mm.12
   mm.2 = mm.2 + (yyyy//4=0) - (yyyy//100=0) + (yyyy//400=0)
 
b_date = Date("B",Space(yyyy mm "01",0),"S")           /* 20010701   */
mx = mm + 0
if nested then,
   push b_date//7 mm.mx
else,
   say  b_date//7 mm.mx
 
exit                                   /*@ MTHLIM                    */
