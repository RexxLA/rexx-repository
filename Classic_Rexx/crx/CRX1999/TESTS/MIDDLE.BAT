@echo off
 set myt=\tests\
 set mys=
rem Some rules that apply in the middle of a clause, mostly keywords.
echo This one about radix  > t.t
 call progrc 6p2p1p1 2101
echo These about VALUE etc.  >> t.t
 call progrc 6p2p3 2511
echo These about DO etc.  >> t.t
 call progrc 6p2p3a 2101
