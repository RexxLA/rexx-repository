                                       /* REXX external subroutine   */
/* ----------------------------------------------------------------- */
SQRT:                                  /*@                           */
arg nbr .
parse var nbr whole "." frac
if \Datatype(whole,"W") then whole = 0
if \Datatype(frac ,"W") then frac  = 0; else frac = "."frac
if Length(whole)//2 = 0 then parse var whole base 3 tail
                        else parse var whole base 2 tail
root = (base/2) * (10**(Length(tail)%2)) + frac
numeric digits 12
lastdiff = 0
do forever
   diff = nbr - root**2
   if diff = 0 then leave
   if diff = lastdiff then leave
   lastdiff = diff
   root  =  root + ((diff/2) /root)
end
numeric digits 11
root = root + 0
if Sysvar("Sysnest") = "NO" then say root; else,
return root                            /*@ SQRT                      */
