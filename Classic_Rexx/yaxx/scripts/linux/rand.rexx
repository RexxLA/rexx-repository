/* Random */
NUMERIC DIGITS 20
/* TRACE R */
TRACE O
call sslrand
call sslrand
call sslrand
call sslrand
call sslrand
exit

sslrand: procedure expose val
   "openssl rand 8 -hex >LIFO"
   parse pull val
   SAY val "=>" X2D(val)
   return
