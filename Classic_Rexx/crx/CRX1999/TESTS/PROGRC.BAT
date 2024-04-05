@ECHO OFF
rem Type the program and check the return code from running it.
echo ================================================================ >> t.t
 type %myt%%1.rx  >> t.t
echo ---------------------------------------------------------------- >> t.t
 %mys%crx %myt%%1.rx >> t.t
echo: >> t.t
echo  ++++Should be %2 >> t.t
