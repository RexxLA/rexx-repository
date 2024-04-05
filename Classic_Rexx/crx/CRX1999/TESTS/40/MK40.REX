/* A little rexx program to ease testcase making. */
Restart:
 p1='3';p2='1';p3='A'
 fn='9P'p1'P'p2||p3'.RX'
Cycle:
 prevfn=fn
 fn='9P'p1'P'p2||p3'.RX'
 if stream(fn,'C',"QUERY EXISTS")='' then "copy" prevfn fn
 "mye" fn
What:
 say "A bumps letter,B bumps right number,C bumps groupno, R restart, X exit"
 pull User
 if User='A' then do
   p3=d2c(c2d(p3)+1)
   signal Cycle
   end
 if User='B' then do
   p2=p2+1; p3='A'
   signal Cycle
   end
 if User='C' then do
   p1=p1+1; p2=1; p3='A'
   signal Cycle
   end
 if User='R' then signal Restart
 if User='X' then exit
 signal What
