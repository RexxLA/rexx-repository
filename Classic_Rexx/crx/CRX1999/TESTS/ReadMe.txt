If you run CRX with no argument, ie just type CRX alone at the Command Prompt, you should get Error 43.  (That will show that you have a copy of CRX.EXE on the path).

If you then run CRX HELLO.RX and get the expected reponse it will show that the top level of these tests is your current directory.  Note that many of these tests use
 extension "RX".  Some use "CMD".  Any extension will work e.g. crx hello.any.  A path will work e.g. crx p\hello.rx.

The tests at this root level can be run by BAT files. (Those BAT files that start "set mys xxx" and "set myt yyy" might need editing to make xxx where CRX.exe is and
yyy where the tests are.)  It appears from the history there was an intention to check that the return code passed on exit from CRX to DOS would match the error number.
That could never have worked - DOS errorlevel is only one byte. (Anyway nothing to do with ANSI).  So any checking has to be by eyeballing the output file T.T.  (Looks
like at least one message wrong/unexpected but I have not explored.) (Also I have had hangs when a bat is run other than as first time since boot.  Have not explored the reason.)

Middle.bat capacity.bat msgs.bat msgsmore.bat  

(The capacity test is narrow but anyway capacity will not be a CRX problem - it will be a problem with user variables consuming too much memory.)

Folder 40 for some runtime messages. (rx.bat results go to t.log)
Folder AR for some tests of arithmetic.
Folder C for the builtins. 