/*bin/true;exec rexx -x "$0" "$@";exit # This is a REXX program */

parse upper arg a +1 .
if a=='Y' then do
   n=right(random(0,9999),4,0)
   say "Guess my 4-digit number."
   do forever
      call charout ,'? '
      parse pull guess
      if n=guess then leave
      say guess':' mark(guess,n)
   end
   say n "is correct."
   exit
end

do i=0 to 9999
   n.i=right(i,4,0)
end
d.=1000
size=10000
say "Let me guess your 4-digit number."

usedg.=0
do while size>1
   guess=''
   used.=0
   do i=1 to 4
      n=0; d=0
      do j=0 to 9
         if d.i.j>n | (d.i.j=n & used.d) then do; n=d.i.j; d=j; end
      end
      guess=guess||d
      used.d=1
   end
   do while usedg.guess | guess==''
      guess=random(0,9999)
      guess=n.guess 
   end
   usedg.guess=1
   call charout ,left('[size='size']',14) guess'? '
   do forever
      parse pull mark
      if length(mark)==2 & datatype(mark,'w') then leave
      say "Please enter a two-digit number."
   end
   do i=0 to 9999
      if n.i=='' then iterate
      if mark(guess,n.i)\==mark then do
         do j=1 to 4
            parse var n.i d +1 n.i
            d.j.d=d.j.d-1
         end
         size=size-1
      end
   end
end
if size=0 then say "Sorry, I think you have made a mistake."
else do i=0 to 9999; if n.i\='' then say "The number is" n.i"."; end
exit

mark: procedure
parse arg n1,n2
yy=0; yn=0
do i=1 to 4
   if substr(n1,i,1)==substr(n2,i,1) then do
      yy=yy+1
      n1=overlay(' ',n1,i)
      n2=overlay(' ',n2,i)
   end
end
do i=1 to 4
   c=substr(n1,i,1)
   if c\==' ' then do
      p=pos(c,n2)
      if p>0 then do
         yn=yn+1
         n2=overlay(' ',n2,p)
      end
   end
end
return yy||yn
