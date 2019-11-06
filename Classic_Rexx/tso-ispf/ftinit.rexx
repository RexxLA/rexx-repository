/* REXX    FTINIT     User-specific initialization for FIRSTIME
                Written by Frank Clarke, Oldsmar FL
*/
ftc = "'"Userid()".FTC'"
if Sysvar("SYSNEST") = "NO"  then say  ftc
                             else push ftc
return(0)
