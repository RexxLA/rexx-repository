Parse Version v
NUmeric Digits 4
--meric Form ENGINEERING
Say v
Say 'digits()='digits() 'form='form()
Say '>x<                        ANSI                 test'
Do xx=-12 To 6
  x='12345.678E'xx
  ansi=fansi(x,9,5,2,2)
  rexx=format(x,9,5,2,2)
  If rexx==ansi Then tag=''
  Else tag='error'
  Say left('>'||x'<',18) left(ansi,20) left(rexx,20) tag
  End
Exit
say fansi(12345.678e2,9,5,2,2)   format(12345.678e2,9,5,2,2)
Say fansi(12345.678e-2,9,5,2,2)  format(12345.678e-2,9,5,2,2)
exit
Do i=0 To 4
  x='0.'copies('0',i)'123456789'
  Call test x
  End
x=' -     1   '
Call test x
Call test 1.2345e2
Do i=1 To 10
  x=left('123456789',i)
  Call test x
  End
Exit
test:
  Parse Arg a,b,c,d,e
  ansi=fansi(a,b,c,d,e)
  test=format(a,b,c,d,e)
  tag=''
  If test\==ansi Then tag='error'
  Say left('>'||x||'<',23) right(ansi,20) right(test,20) tag
  Return

fansi:
/*
9.4.2 FORMAT
FORMAT formats its first argument. The second argument specifies the number of characters to
be used for the integer part and the third specifies the number of characters for the decimal part.
The fourth argument specifies the number of characters for the exponent and the fifth determines
when exponential notation is used.
call CheckArgs,
'rNUM oWHOLE>=0 oWHOLE>=0 oWHOLE>=0 oWHOLE>=0'
*/
Parse Arg pnumber,pbefore,pafter,pexpp,pexpt
If pbefore<>'' Then Before = pbefore
If pafter <>'' Then After =  pafter
If pexpp  <>'' Then Expp =   pexpp
If pexpt  <>'' Then Expt =   pexpt
/* In the simplest case the first is the only argument. */
number=pnumber+0
if arg() < 2 then return Number
/* Dissect the Number. It is in the normal Rexx format. */
parse var Number Mantissa 'E' Exponent
if Exponent == '' then Exponent = 0
Sign = 0
if left(Mantissa,1) == '-' then do
Sign = 1
Mantissa = substr(Mantissa,2)
end
parse var Mantissa Befo '.' Afte
/* Count from the left for the decimal point. */
Point = length(Befo)
/* Sign Mantissa and Exponent now reflect the Number. Befo Afte and
Point reflect Mantissa. */
/* The fourth and fifth arguments allow for exponential notation. */
/* Decide whether exponential form to be used, setting ShowExp. */
ShowExp = 0
if pexpp pexpt<>'' then do
if pexpt='' then Expt = digits()
/* Decide whether exponential form to be used. */
if (Point + Exponent) > Expt then ShowExp = 1 /* Digits before rule. */
LeftOfPoint = 0
if length(Befo) > 0 then LeftOfPoint = Befo /* Value left of
the point */
/* Digits after point rule for exponentiation: */
/* Count zeros to right of point. */
z = 0
do while substr(Afte,z+1,1) == '0'
z = z + 1
end
if LeftOfPoint = 0 & (z - Exponent) > 5 then ShowExp = 1
/* An extra rule for exponential form: */
if If pexpp<>'' then if Expp = 0 then ShowExp = 0
/* Construct the exponential part of the result. */
if ShowExp then do
Exponent = Exponent + ( Point - 1 )
Point = 1 /* As required for 'SCIENTIFIC' */
if form() == 'ENGINEERING' then
do while Exponent//3 \= 0
Point = Point+1
Exponent = Exponent-1
end
end
if \ShowExp then Point = Point + Exponent
end /* Expp or Expt given */
else do
/* Even if Expp and Expt are not given, exponential notation will
be used if the original Number+0 done by CheckArgs led to it. */
if Exponent \= 0 then do
ShowExp = 1
end
end
/* ShowExp now indicates whether to show an exponent,
Exponent is its value. */
/* Make this a Number without a point. */
Integer = Befo||Afte
/* Make sure Point position isn't disjoint from Integer. */
if Point<1 then do /* Extra zeros on the left. */
Integer = copies('0',1 - Point) || Integer
Point = 1
end
if Point > length(Integer) then
Integer = left(Integer,Point,'0') /* And maybe on the right. */
/* Deal with right of decimal point first since that can affect the
left. Ensure the requested number of digits there. */
Afters = length(Integer)-Point
if pafter='' then After = Afters /* Note default. ???? */
/* Make Afters match the requested After */
do while Afters < After
Afters = Afters+1
Integer = Integer'0'
end
if Afters > After then do
/* Round by adding 5 at the right place. */
r=substr(Integer, Point + After + 1, 1)
Integer = left(Integer, Point + After)
if r >= '5' then Integer = Integer + 1
/* This can leave the result zero. */
If Integer = 0 then Sign = 0
/* The case when rounding makes the integer longer is an awkward
one. The exponent will have to be adjusted. */
if length(Integer) > Point + After then do
Point = Point+1
end
if ShowExp = 1 then do
Exponent=Exponent + (Point - 1)
Point = 1 /* As required for 'SCIENTIFIC' */
if form() = 'ENGINEERING' then
do while Exponent//3 \= 0
Point = Point+1
Exponent = Exponent-1
end
end
t = Point-length(Integer)
if t > 0 then Integer = Integer||copies('0',t)
end /* Rounded */
/* Right part is final now. */
if After > 0 then Afte = '.'||substr(Integer,Point+1,After)
else Afte = ''
/* Now deal with the integer part of the result. */
Integer = left(Integer,Point)
if pbefore='' then Before = Point + Sign /* Note default. */
/* Make Point match Before */
if Point > Before - Sign then call Raise 40.38, 2, pnumber
do while Point<Before
Point = Point+1
Integer = '0'Integer
end
/* Find the Sign position and blank leading zeroes. */
r = ''
Triggered = 0
do j = 1 to length(Integer)
Digit = substr(Integer,j,1)
/* Triggered is set when sign inserted or blanking finished. */
if Triggered = 1 then do
r = r||Digit
iterate
end
/* If before sign insertion point then blank out zero. */
if Digit = '0' then
if substr(Integer,j+1,1) = '0' & j+1<length(Integer) then do
r = r||' '
iterate
end
/* j is the sign insertion point. */
if Digit = '0' & j \= length(Integer) then Digit = ' '
if Sign = 1 then Digit = '-'
r = r||Digit
Triggered = 1
end j
Number = r||Afte
if ShowExp = 1 then do
/* Format the exponent. */
Expart = ''
SignExp = 0
if Exponent<0 then do
SignExp = 1
Exponent = -Exponent
end
/* Make the exponent to the requested width. */
if pexpp='' then Expp = length(Exponent)
if length(Exponent) > Expp then
call Raise 40.38, 4, pnumber
Exponent=right(Exponent,Expp,'0')
if Exponent = 0 then do
if pexpp<>'' then Expart = copies(' ',expp+2)
end
else if SignExp = 0 then Expart = 'E+'Exponent
else Expart = 'E-'Exponent
Number = Number||Expart
end
return Number
raise:
s=''
Do i=1 To arg()
  s=s arg(I)
  End
Say 'raise' s
Exit
