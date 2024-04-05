rem @echo off
 set myt=\tests\
 set mys=
rem These are about capacity.  They are not about limits that the standard
rem allows for, since those are tested along with testing messages about
rem exceeding them.
echo Comments nested 1000 deep are OK.  > t.t
 call progrc capcomm 0
echo But at some point too deep.        >> t.t
 call progrc 501 501
echo "Unfinished comment" messages refer to the relevant /*   >> t.t
 call progrc capcommb 601
 call progrc capcommc 601
