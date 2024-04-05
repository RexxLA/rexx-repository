echo ================================================================ >> t.t
 type %myt%%1.rx  >> t.t
echo ---------------------------------------------------------------- >> t.t
 \h\s\crxmsg %myt%%1.rx >> t.t
 if errorlevel %1 goto OK
echo !!!!!!!!!!!! mismatch return code
echo !!!!!!!!!!!! mismatch return code >> t.t
:OK
