10 Built-in functions

10.1 Notation

The built-in functions are defined mainly through code. The code refers to state variables. This is solely a
notation used in this standard.

The code refers to functions with names that start with 'Config_'; these are the functions described in
section nnn.

The code is specified as an external routine that produces a result from the values #Bif (which is the
name of the built-in function), #Bif_Arg.0 (the number of arguments), #Bif_Arg.i and #Bif_ArgExists.i
(which are the argument data.)

The value of #Level is the value for the clause which invoked the built-in function.

The code either returns the result of the built-in or exits with an indication of a condition that the
invocation of the built-in raises.

The code below uses built-in functions. Such a use invokes another use of this code with a new value of
#Level. On these invocations, the CheckArgs function is not relevant.

Numeric settings as follows are used in the code. When an argument is being checked as a number by
‘NUM' or 'WHOLENUM' the settings are those current in the caller. When an argument is being checked
as an integer by an item containing 'WHOLE' the settings are those for the particular built-in function.
Elsewhere the settings have sufficient numeric digits to avoid values which would require exponential
notation.

10.2 Routines used by built-in functions

The routine CheckArgs is concerned with checking the arguments to the built-in. The routines Time2Date
and Leap are for date calculations. ReRadix is used for radix conversion. The routine Raise raises a
condition and does not return.

10.2.1. Argument checking

/* Check arguments. Some further checks will be made in particular built-ins.*/
/* The argument to CheckArgs is a checklist for the allowable arguments. */

/* NUM, WHOLENUM and WHOLE have a side-effect, 'normalizing' the number. */

/* Calls to raise syntax conditions will not return. */

CheckArgs:
CheckList = arg(1) /* This refers to the argument of CheckArgs. */

/* Move the checklist information from a string to individual variables */
ArgType. = '''
ArgPos = 0 /* To count arguments */
MinArgs = 0
do j = 1 to length (CheckList)
ArgPos = ArgPos+1
/* Count the required arguments. */
if substr(CheckList,j,1) == 'r' then MinArgs = MinArgs + 1
/* Collect type information. */
do while j < length(CheckList)
j=eajae1
t = substr(CheckList,j,1)
if t==' ' then leave
ArgType.ArgPos = ArgType.ArgPos || t
end
/* A single space delimits parts. */
end j
MaxArgs = ArgPos

/* Check the number of arguments to the built-in, in this instance. */
NumArgs = #Bif Arg.0

if NumArgs < MinArgs then call Raise 40.3, MinArgs

if NumArgs > MaxArgs then call Raise 40.4, MaxArgs

/* Check the type(s) of the arguments to the built-in. */
do ArgPos = 1 to NumArgs
if #Bif ArgExists.ArgPos then
call CheckType
else
if ArgPos <= MinArgs then call Raise 40.5, ArgPos
end ArgPos

93
/* No errors found by CheckArgs. */

return
CheckType:
Value = #Bif Arg.ArgPos
Type = ArgType.ArgPos
select
when Type == 'ANY' then nop /* Any string */
when Type == 'NUM' then do /* Any number */

/* This check is made with the caller's digits setting. */
if \Cdatatype(Value, 'N') then
if #DatatypeResult=='E' then call Raise 40.9, ArgPos, Value
else call Raise 40.11, ArgPos, Value
#Bif Arg.ArgPos=#DatatypeResult /* Update argument copy. */
end

when Type == 'WHOLE' then do /* Whole number */
/* This check is made with digits setting for the built-in. */
if \Edatatype(Value,'W') then
call Raise 40.12, ArgPos, Value
#Bif_ Arg.ArgPos=#DatatypeResult
end

when Type == 'WHOLE>=0' then do /* Non-negative whole number */
if \Edatatype(Value,'W') then
call Raise 40.12, ArgPos, Value
if #DatatypeResult < 0 then
call Raise 40.13, ArgPos, Value
#Bif_ Arg.ArgPos=#DatatypeResult
end

when Type == 'WHOLE>0O' then do /* Positive whole number */
if \Edatatype(Value,'W') then
call Raise 40.12, ArgPos, Value
if #DatatypeResult <= 0 then
call Raise 40.14, ArgPos, Value
#Bif_ Arg.ArgPos=#DatatypeResult
end

when Type == 'WHOLENUM' then do /* D2X type whole number */
/* This check is made with digits setting of the caller. */
if \Cdatatype(Value,'W') then
call Raise 40.12, ArgPos, Value
#Bif_ Arg.ArgPos=#DatatypeResult
end

when Type == 'WHOLENUM>=0' then do /* D2X Non-negative whole number */
if \Cdatatype(Value,'W') then
call Raise 40.12, ArgPos, Value
if #DatatypeResult < 0 then
call Raise 40.13, ArgPos, Value
#Bif_ Arg.ArgPos=#DatatypeResult
end

when Type == '0 90' then do /* Errortext */

if \Edatatype(Value,'N') then
call Raise 40.11, ArgPos, Value

Value=#DatatypeResult

#Bif_ Arg.ArgPos=Value

Major=Value % 1

Minor=Value - Major

if Major < 0 | Major > 90 | Minor > .9 | pos('E',Value)>0 then
call Raise 40.17, Value /* ArgPos will be 1 */

end

when Type == 'PAD' then do /* Single character, usually a pad. */

if length(Value) \= 1 then
call Raise 40.23, ArgPos, Value

94
end

when Type == 'HEX' then /* Hexadecimal string */
if \datatype (Value, 'X') then
call Raise 40.25, Value /* ArgPos will be 1 */
when Type == 'BIN' then /* Binary string */
if \datatype(Value,'B') then
call Raise 40.24, Value /* ArgPos will be 1 */
when Type == 'SYM' then /* Symbol */

if \datatype (Value, 'S') then
call Raise 40.26, Value /* ArgPos will be 1 */

when Type == 'STREAM' then do
call Config Stream Qualify Value
if left (#Response, 1) == 'B' then
call Raise 40.27, Value /* ArgPos will be 1 */
end

when Type = 'ACEFILNOR' then do /* Trace */
Val = Value
/* Allow '?' alone */

if val \== '?' then do
/* Allow leading '?' */
if left(Val,1) == '?' then Val = substr(Val,2)

if pos(translate(left(Val, 1)), 'ACEFILNOR') = 0 then
call Raise 40.28, ArgPos, Type, Val

end
end
otherwise do /* Options */
/* The checklist item is a list of allowed characters */
if Value == '' then

call Raise 40.21, ArgPos
#Bif Arg.ArgPos = translate(left(Value, 1))
if pos(#Bif Arg.ArgPos, Type) = 0 then
call Raise 40.28, ArgPos, Type, Value
end

end /* Select */
return

Cdatatype:
/* This check is made with the digits setting of the caller. */
/* #DatatypeResult will be set by use of datatype() */

numeric digits #Digits.#Level

numeric form value #Form.#Level

return datatype(arg(1), arg(2))

Edatatype:
/* This check is made with digits setting for the particular built-in. */
/* #DatatypeResult will be set by use of datatype() */

numeric digits #Bif Digits.#Bif

numeric form scientific

return datatype(arg(1),arg(2))

10.2.2 Date calculations
Time2Date:
if arg(1) < 0 then
call Raise 40.18
if arg(1) >= 315537897600000000 then
call Raise 40.18
return Time2Date2 (arg(1))

Time: procedure
/* This routine is essentially the code from the standard, put in

95
stand-alone form. The only ‘tricky bit’ is that there is no Rexx way
for it to fail with the same error codes as a "real" implementation
would. It can however give a SYNTAX error, albeit not the desirable
one. This causing of an error is done by returning with no value.
Since the routine will have been called as a function, this produces

an error. */

/* Backslash is avoided as some systems don't handle that negation sign. */
if argQ)>3 then
returm
numeric digits 18
if arg(1,'E’) then
if pos(translate(left(arg(1),1)),"CEHLMNRS")=0 then
return
/* (The standard would also allow 'O' but what this code is running
on would not.) */
if arg(3,'E’) then
if pos(translate(left(arg(3),1)),"CHLMNS")=0 then
return
/* Tf the third argument is given then the second is mandatory. */
if arg(3,'E’) & arg(2,'E')=0 then
returm
/* Default the first argument. */
if arg(1,'E’) then
Option = translate(left(arg(1),1))
else
Option = 'N'’
/* Tf there is no second argument, the current time is returned. */
if arg(2,'E’) = 0 then
if arg(1,'E’) then
return "TIME'(arg(1))
else
return 'TIME'()
/* One cannot convert to elapsed times. */
if pos(Option, 'ERO') > 0 then
returm
InValue = arg(2)
if arg(3,'E’) then
InOption = arg(3)
else
InOption = 'N'
HH =0
MM = 0
SS =0
HourAdjust = 0
select

96
when InOption == 'C' then do
parse var InValue HH ':'. +1 MM +2 XX
if HH = 12 then
HH =0
if XX == 'pm' then
HourAdjust = 12

end
when InOption == 'H’ then
HH = InValue

when InOption == 'L’' | InOption == 'N' then
parse var InValue HH ':’ MM ':' SS
when InOption == 'M' then
MM = InValue
otherwise
SS = InValue
end
if datatype(HH,'W')=0 | datatype(MM,'W')=0 | datatype(SS,'N')=0 then
returm
HH = HH + HourAdjust
/* Convert to microseconds */
Micro = trunc((((HH * 60) + MM) * 60 + SS) * 1000000)
/* There is no special message for time-out-of-range; the bad-format
message is used. */
if Micro<0O | Micro > 24*3600* 1000000 then
returm
/* Reconvert to further check the original. */
if TimeFormat(Micro,InOption) == InValue then
return TimeFormat(Micro, Option)
return

TimeFormat: procedure
/* Convert from microseconds to given format. */
/* The day will be irrelevant; actually it will be the first day possible. */
x = Time2Date2(arg(1))
parse value x with Year Month Day Hour Minute Second Microsecond Base Days
select
when arg(2) == 'C’ then
select
when Hour>12 then
return Hour-12':'right(Minute,2,'0")'pm'
when Hour=12 then
return '12:'right(Minute,2,'0')'pm’
when Hour>0 then
return Hour':'right(Minute,2,'0')'am’
when Hour=0 then
return '12:'right(Minute,2,'0')'am’

97
when arg(2) == 'H' then return Hour
when arg(2) == 'L’ then
return right(Hour,?2,'0')':'right(Minute,2,'0')':'right(Second,2,'0'),
|| '.'right(Microsecond,6,'0')
when arg(2) == 'M' then
return 60*Hour+Minute
when arg(2) == 'N' then
return right(Hour,?2,'0')':'right(Minute,2,'0')':'right(Second,2,'0')
otherwise /* arg(2) =='S' */
return 3600*Hour+60* Minute+Second
end

Time2Date2: Procedure
/* Convert a timestamp to a date.
Argument is a timestamp (the number of microseconds relative to
0001 01 01 00:00:00.000000)
Returns a date in the form:
year month day hour minute second microsecond base days */

/* Argument is relative to the virtual date 0001 01 01 00:00:00.000000 */
Time = arg(1)

Second = Time % 1000000 } Microsecond = Time // 1000000
Minute = Second % 60 ; Second = Second // 60
Hour = Minute % 60 ; Minute = Minute // 60
Day = Hour % 24 ;} Hour = Hour // 24

/* At this point, the days are the days since the 0001 base date. */
BaseDays = Day
Day = Day + 1

/* Compute either the fitting year, or some year not too far earlier.
Compute the number of days left on the first of January of this year. */

Year = Day % 366
Day = Day - (Year*365 + Year%4 - Year%100 + Year%400)
Year = Year +1

/* Now if the number of days left is larger than the number of days
in the year we computed, increment the year, and decrement the
number of days accordingly. */
do while Day > (365 + Leap (Year) )

Day = Day - (365 + Leap(Year) )

Year = Year + 1
end

/* At this point, the days left pertain to this year. */
YearDays = Day

/* Now step through the months, increment the number of the month,
and decrement the number of days accordingly (taking into
consideration that in a leap year February has 29 days), until
further reducing the number of days and incrementing the month
would lead to a negative number of days */
Days = '31 28 31 30 31 30 31 31 30 31 30 31'
do Month = 1 to words (Days)

ThisMonth = Word(Days, Month) + (Month = 2) * Leap (Year)

if Day <= ThisMonth then leave

Day = Day - ThisMonth
end

return Year Month Day Hour Minute Second Microsecond BaseDays YearDays

98
Leap: procedure
/* Return 1 if the year given as argument is a leap year, or 0
otherwise. */
return (arg(1)//4 = 0) & ((arg(1)//100 <> 0) | (arg(1)//400 = 0))

10.2.1. Radix conversion

ReRadix: /* Converts Arg(1) from radix Arg(2) to radix Arg(3) */

procedure

Subj ect=arg(1)

FromRadix=arg (2)

ToRadix=arg (3)

/* Radix range is 2-16. Conversion is via decimal */

Integer=0

do j=1 to length (Subject)
/* Individual digits have already been checked for range. */
Integer=Integer*FromRadix+pos (substr (Subject,j,1),'0123456789ABCDEF')-1
end

rete

do while Integer>0

r= substr('0123456789ABCDEF',1 + Integer // ToRadix, 1) || r
Integer = Integer % ToRadix
end

/* When between 2 and 16, there is no zero suppression. */
if FromRadix = 2 & ToRadix = 16 then
r=eright(r, (length(Subject)+3) % 4, '0')
else if FromRadix = 16 & ToRadix = 2 then
reright(r, length(Subject) * 4, '0')
return r

10.2.2 Raising the SYNTAX condition

Raise:

/* These 40.nn messages always include the built-in name as an insert.*/
call #Raise 'SYNTAX', arg(1), #Bif, arg(2), arg(3), arg(4)
/* #Raise does not return. */

10.1. Character built-in functions

These functions process characters or words in strings. Character positions are numbered from one at
the left. Words are delimited by blanks and their equivalents, word positions are counted from one at the
left.

10.1.1 ABBREV

ABBREV returns '1' if the second argument is equal to the leading characters of the first and the length of
the second argument is not less than the third argument.

call CheckArgs 'rANY rANY oWHOLE>=0'

Subject #Bif Arg.1

Subj #Bif Arg.2

if #Bif_ArgExists.3 then Length = #Bif Arg.3
else Length = length (Subj)

Condl = length(Subject) >= length(Subj)
Cond2 = length(Subj) >= Length
Cond3 = substr(Subject, 1, length(Subj)) == Subj

return Condl & Cond2 & Cond3

10.1.2 CENTER
CENTER returns a string with the first argument centered in it. The length of the result is the second
argument and the third argument specifies the character to be used for padding.

call CheckArgs 'rANY rWHOLE>=0 oPAD'

String = #Bif Arg.1

Length = #Bif Arg.2

if #Bif_ArgExists.3 then Pad = #Bif Arg.3
else Pad = ' '!

99
Trim = length(String) - Length

if Trim > 0 then
return substr(String, Trim % 2 + 1, Length)

return overlay(String, copies(Pad, Length), -Trim % 2 + 1)

10.1.3 CENTRE

This is an alternative spelling for the CENTER built-in function.

10.1.4 CHANGESTR

CHANGESTR replaces all occurrences of the first argument within the second argument, replacing them
with the third argument.

call CheckArgs '"rANY rANY rANY'

Output = ''
Position = 1
do forever
FoundPos = pos(#Bif Arg.1, #Bif Arg.2, Position)
if FoundPos = 0 then leave
Output = Output || substr(#Bif_ Arg.2, Position, FoundPos - Position),
|| #Bif Arg.3
Position = FoundPos + length(#Bif Arg.1)
end
return Output || substr(#Bif Arg.2, Position)

10.1.5 COMPARE
COMPARE returns '0' if the first and second arguments have the same value. Otherwise, the result is the
position of the first character that is not the same in both strings.

call CheckArgs 'rANY rANY oPAD'

Strl = #Bif_Arg.1

Str2 = #Bif_Arg.2

if #Bif_ArgExists.3 then Pad
else Pad

#Bif Arg.3

/* Compare the strings from left to right one character at a time */
if length(Str1) > length(Str2) then do

Length = length(Str1)

Str2=left (Str2, Length, Pad)

end
else do

Length = length(Str2)

Strl=left (Str1, Length, Pad)

end

do i= 1 to Length
if substr(Stri, i, 1) \== substr(Str2, i, 1) then return i
end

return 0

10.1.6 COPIES

COPIES returns concatenated copies of the first argument. The second argument is the number of
copies.

call CheckArgs '"rANY rWHOLE>=0'
Output = ''
do #Bif Arg.2
Output = Output || #Bif_Arg.1
end

return Output

10.1.7 COUNTSTR
COUNTSTR counts the appearances of the first argument in the second argument.

100
call CheckArgs '"rANY rANY'

Output = 0

Position = pos (#Bif Arg.1,#Bif Arg.2)

do while Position > 0
Output = Output + 1
Position = pos(#Bif Arg.1, #Bif Arg.2, Position + length(#Bif Arg.1))
end

return Output

10.1.8 DATATYPE
DATATYPE tests for characteristics of the first argument. The second argument specifies the particular
test.

call CheckArgs 'rANY oABLMNSUWX'

/* As well as returning the type, the value for a 'NUM' is set in
#DatatypeResult. This is a convenience when DATATYPE is used

by CHECKARGS. */

String = #Bif Arg.1

/* If no second argument, DATATYPE checks whether the first is a number. */
if \#Bif_ArgExists.2 then return DtypeOne()

Type = #Bif_ Arg.2
/* Null strings are a special case. */

if String == '' then do
if Type == "X" then return 1
if Type == "B" then return 1
return 0
end

/* Several of the options are shorthands for VERIFY */
azl="abcdefghijklmnopqrstuvwxyz"
AZU= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
DO09="0123456789"
if Type == "A" then return verify(String,az1||AzU||D09)=0
if Type == "B" then do
/* Check blanks in allowed places. */
if pos (left (String,1),#Al1Blanks)>0 then return 0
if pos (right (String,1),#Al1Blanks)>0 then return 0
BinaryDigits=0
do j = length(String) by -1 tol
ce = substr(String,j,1)
if pos(c,#Al11Blanks)>0 then do
/* Blanks need four BinaryDigits to the right of them. */
if BinaryDigits//4 \= 0 then return 0
end
else do
if verify(c,"01") \= 0 then return 0
BinaryDigits = BinaryDigits + 1

end
end j

return 1

end /* B */
if Type == "L" then return (verify (String,azl1)=0)
if Type == "M" then return (verify (String, azl1||AZU)=0)
if Type == "N" then return (datatype (String) =="NUM")
if Type == "S" then return(symbol (String) \=='BAD')
if Type == "U" then return (verify (String, AZU)=0)
if Type == "W" then do

/* It may not be a number. */
if DtypeOne(String) == 'CHAR' then return '0'
/* It can be "Whole" even if originally in exponential notation,
provided it can be written as non-exponential. */
if pos('E',#DatatypeResult)>0 then return '0'
/* It won't be "Whole" if there is a non-zero after the decimal point. */
InFraction='0'

101
do j = 1 to length (String)
ce = substr(String,j,1)
if pos(c,'Ee')>0 then leave j
if InFraction & pos(c,'+-')>0 then leave j
if c == '.' then InFraction='1'
else if InFraction & a\=='0' then return 0
end j
/* All tests for Whole passed. */
#DatatypeResult = #DatatypeResult % 1
return 1
end /* W */
/* Type will be "x" */
if pos (left (String,1),#Al1Blanks)>0 then return 0
if pos (right (String,1),#Al1Blanks)>0 then return 0
HexDigits=0
do j=length(String) by -1 to 1
c=substr (String,j,1)
if pos(c,#Al11Blanks)>0 then do
/* Blanks need a pair of HexDigits to the right of them. */
if HexDigits//2 \= 0 then return 0
end
else do
if verify(c,"abcdefABCDEF"D09) \= 0 then return 0
HexDigits=HexDigits+1
end
end
return 1
/* end X */

DtypeOne:
/* See section nnn for the syntax of a number. */
#DatatypeResult = 'S' /* If not syntactically a number */
Residue = strip(String) /* Blanks are allowed at both ends. */
if Residue == '' then return "CHAR"
Sign = ''
if left(Residue,1) == '+' | left(Residue,1) == '-' then do

Sign = left(Residue, 1)
Residue = strip(substr(Residue,2),'L') /* Blanks after sign */

end
if Residue == '' then return "CHAR"
/* Now testing Number, section nnn */
if left(Residue,1) == '.' then do
Residue = substr (Residue, 2)
Before = ''
After = DigitRun()
if After == '' then return "CHAR"
end
else do
Before = DigitRun()
if Before == '' then return "CHAR"
if left(Residue,1) == '.' then do
Residue = substr (Residue, 2)
After = DigitRun()
end
end
Exponent = 0
if Residue \== '' then do
if left(Residue, 1) \== 'e' & left(Residue, 1) \== 'E' then

return "CHAR"
Residue = substr (Residue, 2)

if Residue == '' then return "CHAR"

Esign = ''

if left(Residue, 1) == '+' | left(Residue, 1) == '-' then do
Esign = left(Residue, 1)
Residue = substr (Residue, 2)
if Residue == '' then return "CHAR"
end

Exponent = DigitRun()

if Exponent == '' then return "CHAR"

Exponent = Esign || Exponent

end

if Residue \== '' then return "CHAR"

102
/*DATATYPE tests for exponent out of range. */

#DatatypeResult = 'E' /* If exponent out of range */
Before = strip(Before,'L','0')
if Before == '' then Before = '0'

Exponent = Exponent + length(Before) -1 /* For SCIENTIFIC */

/* "Engineering notation causes powers of ten to expressed as a
multiple of 3 - the integer part may therefore range from 1 through 9910." */
g=1
if #Form.#Level == 'E' then do
/* Adjustment to make exponent a multiple of 3 */
g = Exponent//3
if g < 0 then g = g +
Exponent = Exponent -
end

3
g

/* Check on the exponent. */
if Exponent > #Limit ExponentDigits then return "CHAR"
if -#Limit ExponentDigits > Exponent then return "CHAR"

/* Format to the numeric setting of the caller of DATATYPE */
numeric digits #Digits.#Level

numeric form value #Form.#Level

#DatatypeResult = 0 + #Bif_Arg.1

return "NUM"

DigitRun:
Outcome = ''
do while Residue \== ''
if pos(left (Residue, 1), '0123456789') = 0 then leave

Outcome = Outcome || left(Residue, 1)
Residue = substr(Residue, 2)
end

return Outcome

10.1.9 DELSTR
DELSTR deletes the sub-siring of the first argument which begins at the position given by the second
argument. The third argument is the length of the deletion.

call CheckArgs 'rANY rWHOLE>0 oWHOLE>=0'
String #Bif Arg.1

Num #Bif Arg.2
if #Bif_ArgExists.3 then Len = #Bif_Arg.3

if Num > length(String) then return String

Output = substr(String, 1, Num - 1)
if #Bif_ArgExists.3 then
if Num + Len <= length(String) then
Output = Output || substr(String, Num + Len)
return Output

10.1.10 DELWORD
DELWORD deletes words from the first argument. The second argument specifies position of the first
word to be deleted and the third argument specifies the number of words.

call CheckArgs 'rANY rWHOLE>0 oWHOLE>=0'
String #Bif Arg.1

Num #Bif Arg.2
if #Bif_ArgExists.3 then Len = #Bif_Arg.3

if Num > words(String) then return String

EndLeft = wordindex(String, Num) - 1
Output = left(String, EndLeft)
if #Bif_ArgExists.3 then do
BeginRight = wordindex(String, Num + Len)

103
if BeginRight>0 then
Output =

end
return Output

10.1.11. INSERT

Output || substr(String, BeginRight)

INSERT insets the first argument into the second. The third argument gives the position of the character
before the insert and the fourth gives the length of the insert. The fifth is the padding character.

call CheckArgs

New #Bif_ Arg.1
Target #Bif Arg.2
if #Bif_ArgExists.3

then
else
then
else
then
else

Num
Num
Length = #Bif Arg.4
Length = length (New)
Pad #Bif Arg.5
Pad ro

#Bif Arg.3
0

if #Bif_ArgExists.4

if #Bif_ArgExists.5

return left(Target, Num, Pad)
left (New, Length, Pad),
substr(Target, Num + 1)

“

10.1.12 LASTPOS

/* To left of insert
/* New string inserted */
/* To right of insert

'rANY rANY oWHOLE>=0 oWHOLE>=0 oPAD'

*/
*/

LASTPOS returns the position of the last occurrence of the first argument within the second. The third

argument is a starting position for the search.

call CheckArgs 'rANY rANY oWHOLE>0'

Needle = #Bif_Arg.1
Haystack = #Bif Arg.2
if #Bif_ArgExists.3 then Start = #Bif_Arg.3
else Start = length(Haystack)

NeedleLength = length (Needle)
if NeedleLength = 0 then return 0
Start = Start - NeedleLength + 1
do i= Start by -1 while i > 0
if substr(Haystack, i, NeedleLength)
end i
return 0

10.1.13 LEFT

LEFT returns characters that are on the left of the first argument.

length of the result and the third is the padding character.
call CheckArgs 'rANY rWHOLE>=0 oPAD'

if #Bif_ArgExists.3 then Pad
else Pad

#Bif Arg.3

return substr(#Bif Arg.1, 1, #Bif_ Arg.2, Pad)

10.1.14 LENGTH

Needle then return i

The second argument specifies the

Length returns a count of the number of characters in the argument.

call CheckArgs 'rANY'

String = #Bif Arg.1

#Response = Config Length(String)

Length = #Outcome

call Config Substr #Response, 1

if #Outcome \== 'E' then return Length

/* Here if argument was not a character string.
call Config C2B String
call #Raise 'SYNTAX',

23.1, b2x(#Outcome)

104

*/
/* No return to here */

10.1.15 OVERLAY

OVERLAY overlays the first argument onto the second. The third argument is the starting position of the

overlay. The fourth argument is the length of the overlay and the fifth is the padding character.

call CheckArgs 'rANY rANY oWHOLE>0 oOWHOLE>=0 oPAD'

New = #Bif_Arg.1

Target = #Bif Arg.2

if #Bif_ArgExists.3 then Num = #Bif_Arg.3
else Num = 1

if #Bif_ArgExists.4 then Length = #Bif_ Arg.4
else Length = length (New)

if #Bif_ArgExists.5 then Pad = #Bif_ Arg.5
else Pad = ' '
return left(Target, Num - 1, Pad), /* To left of overlay */
|| left (New, Length, Pad), /* New string overlaid */
|| substr (Target, Num + Length) /* To right of overlay */

10.1.16 POS
POS returns the position of the first argument within the second.

call CheckArgs 'rANY rANY oWHOLE>0'

Needle #Bif Arg.1

Haystack = #Bif Arg.2

if #Bif_ ArgExists.3 then Start
else Start

#Bif Arg.3
1

if length(Needle) = 0 then return 0

do i = Start to length (Haystack) +1-length (Needle)
if substr(Haystack, i, length(Needle)) == Needle then return i
end i

return 0

10.1.17 REVERSE
REVERSE returns its argument, swapped end for end.

call CheckArgs 'rANY'

String

#Bif Arg.1
Output = ''
do i= 1 to length (String)
Output = substr(String,i,1) || Output
end
return Output

10.1.18 RIGHT

RIGHT returns characters that are on the right of the first argument. The second argument specifies the

length of the result and the third is the padding character.
call CheckArgs 'rANY rWHOLE>=0 oPAD'

String = #Bif Arg.1
Length = #Bif Arg.2
if #Bif_ArgExists.3 then Pad

#Bif Arg.3
else Pad '

Trim = length(String) - Length
if Trim >= 0 then return substr(String,Trim + 1)
return copies(Pad, -Trim) || String /* Pad string on the left */

10.1.19 SPACE

105
SPACE formats the blank-delimited words in the first argument with pad characters between each word.
The second argument is the number of pad characters between each word and the third is the pad
character.

call CheckArgs 'rANY oOWHOLE>=0 oPAD'

String = #Bif Arg.1

if #Bif_ArgExists.2 then Num = #Bif_ Arg.2
else Num = 1
if #Bif ArgExists.3 then Pad = #Bif Arg.3
else Pad = ' '!
Padding = copies(Pad, Num)
Output = subword(String, 1, 1)
do i = 2 to words (String)
Output = Output || Padding || subword(String, i, 1)

end
return Output

10.1.20 STRIP

STRIP removes characters from its first argument. The second argument specifies whether the deletions
are leading characters, trailing characters or both. Each character deleted is equal to the third argument,
or equivalent to a blank if the third argument is omitted.

call CheckArgs 'rANY oLTB oPAD'

String = #Bif Arg.1
if #Bif_ArgExists.2 then Option = #Bif Arg.2
else Option = 'B'
if #Bif_ ArgExists.3 then Unwanted = #Bif_ Arg.3
else Unwanted = #A11Blanks<Index "#Al11Blanks" # "" >

if Option == 'L' | Option == 'B' then do
/* Strip leading characters */
do while String \== '' & pos(left(String, 1), Unwanted) > 0
String = substr(String, 2)
end
end

if Option == 'T' | Option == 'B' then do
/* Strip trailing characters */
do while String \== '' & pos(right(String, 1), Unwanted) > 0
String = left(String, length(String) -1)
end /* of while */
end
return String

10.1.21  SUBSTR
SUBSTR returns a sub-string of the first argument. The second argument specifies the position of the
first character and the third specifies the length of the sub-string. The fourth argument is the padding

character.

call CheckArgs 'rANY rWHOLE>0 oOWHOLE>=0 oPAD'

String = #Bif Arg.1
Num = #Bif_ Arg.2
if #Bif_ArgExists.3 then Length = #Bif Arg.3
else Length = max(length (String) +1-Num, 0)
if #Bif_ArgExists.4 then Pad = #Bif_ Arg.4
else Pad = ' '!
Output = ''
do Length
#Response Config Substr(String,Num) /* Attempt to fetch character.*/
Character #Outcome

Num = Num + 1
call Config Substr #Response,1 /* Was there such a character? */
if #Outcome == 'E' then do

106
/* Here if argument was not a character string. */

call Config C2B String
call #Raise 'SYNTAX', 23.1, b2x(#Outcome)
/* No return to here */

end
if #Outcome == 'M' then Character = Pad
Output=Output | | Character
end

return Output

10.1.22 SUBWORD

SUBWORD returns a sub-string of the first argument, comprised of words. The second argument is the
position in the first argument of the first word of the sub-string. The third argument is the number of
words in the sub-string.

call CheckArgs 'rANY rWHOLE>0 oWHOLE>=0'

String #Bif Arg.1

Num #Bif Arg.2

if #Bif_ ArgExists.3 then Length
else Length

#Bif_Arg.3
length(String) /* Avoids call */
/* to WORDS() */

if Length = 0 then return ''

/* Find position of first included word */

Start = wordindex (String, Num)

if Start = 0 then return '' /* Start is beyond end */

/* Find position of first excluded word */
End = wordindex (String, Num+Length)
if End = 0 then End = length(String)+1

Output=substr (String, Start, End-Start)

/* Drop trailing blanks */

do while Output \== ''
if pos (right (Output,1),#A11Blanks) = 0 then leave
Output = left (Output, length (Output) -1)
end

return Output

10.1.23 TRANSLATE
TRANSLATE returns the characters of its first argument with each character either unchanged or
translated to another character.

call CheckArgs 'rANY oANY oANY oPAD'
String = #Bif Arg.1
/* If neither input nor output tables, uppercase. */
if \#Bif ArgExists.2 & \#Bif_ArgExists.3 then do
Output = ''
do j=1 to length (String)
#Response = Config Upper (substr (String,j,1))

Output = Output || #Outcome
end j

return Output

end

/* The input table defaults to all characters. */
if \#Bif ArgExists.3 then do
#Response = Config Xrange()
Tablei = #Outcome
end
else Tablei = #Bif_Arg.3
/* The output table defaults to null */
if #Bif_ArgExists.2 then Tableo = #Bif Arg.2
else Tableo = ''
/* The tables are made the same length */
if #Bif_ArgExists.4 then Pad = #Bif_ Arg.4
else Pad = ' '
Tableo=left (Tableo, length (Tablei) , Pad)

107
Output=''
do j=1 to length (String)
c=substr (String,j,1)
k=pos(c,Tablei)
if k=0 then Output=Output ||c
else Output=Output | | substr (Tableo,k,1)
end j
return Output

10.1.24 VERIFY

VERIFY checks that its first argument contains only characters that are in the second argument, or that it
contains no characters from the second argument; the third argument specifies which check is made.
The result is '0', or the position of the character that failed verification. The fourth argument is a starting
position for the check.

call CheckArgs 'rANY rANY oMN oWHOLE>0'

String = #Bif Arg.1

Reference = #Bif_Arg.2

if #Bif_ ArgExists.3 then Option #Bif Arg.3
else Option 'N!

if #Bif_ ArgExists.4 then Start = #Bif_Arg.4
else Start = 1

Last = length(String)
if Start > Last then return 0
if Reference == '' then
if Option == 'N' then return Start
else return 0

do i = Start to Last
t = pos(substr(String, i, 1), Reference)
if Option == 'N' then do
if t = 0 then return i /* Return position of NoMatch character. */
end
else
if t > 0 then return i /* Return position of Matched character. */
end i
return 0

10.1.25 WORD
WORD returns the word from the first argument at the position given by the second argument.

call CheckArgs 'rANY rwWHOLE>0'

return subword(#Bif Arg.1, #Bif_Arg.2, 1)

10.1.26 WORDINDEX
WORDINDEX returns the character position in the first argument of a word in the first argument. The
second argument is the word position of that word.

call CheckArgs 'rANY rwWHOLE>0'

String
Num

#Bif Arg.1
#Bif Arg.2

/* Find starting position */

Start = 1
Count = 0
do forever
Start = verify(String, #Al1Blanks<Index "#A11Blanks" # "" >, 'N', Start) /*
Find non-blank */
if Start = 0 then return 0 /* Start is beyond end */
Count = Count + 1 /* Words found */
if Count = Num then leave
Start = verify(String, #Al1Blanks<Index "#Al11Blanks" # "" >, 'M', Start + 1) /*

Find blank */

108
if Start = 0 then return 0 /* Start is beyond end */
end
return Start

10.1.27  WORDLENGTH
WORDLENGTH returns the number of characters in a word from the first argument. The second
argument is the word position of that word.

call CheckArgs 'rANY rwWHOLE>0'

return length(subword(#Bif Arg.1, #Bif_Arg.2, 1))

10.1.28 WORDPOS

WORDPOS finds the leftmost occurrence in the second argument of the sequence of words in the first
argument. The result is '0' or the word position in the second argument of the first word of the matched
sequence. Third argument is a word position for the start of the search.

call CheckArgs 'rANY rANY oWHOLE>0'

Phrase = #Bif_Arg.1

String = #Bif Arg.2

if #Bif_ArgExists.3 then Start = #Bif_Arg.3
else Start = 1

Phrase = space (Phrase)
PhraseWords = words (Phrase)
if PhraseWords = 0 then return 0
String = space (String)
StringWords = words (String)
do WordNumber = Start to StringWords - PhraseWords + 1
if Phrase == subword(String, WordNumber, PhraseWords) then
return WordNumber
end WordNumber
return 0

10.1.29 WORDS
WORDS counts the number of words in its argument.

call CheckArgs 'rANY'

do Count = 0 by 1
if subword(#Bif Arg.1, Count + 1) == '' then return Count
end Count

10.1.30 XRANGE
XRANGE returns an ordered string of all valid character encodings in the specified range.

call CheckArgs 'oPAD oPAD'

if \#Bif_ArgExists.1 then #Bif_Arg.1 mr
if \#Bif_ArgExists.2 then #Bif Arg.2
#Response = Config Xrange(#Bif Arg.1, #Bif Arg.2)
return #Outcome

10.2 Arithmetic built-in functions

These functions perform arithmetic at the numeric settings current at the invocation of the built-in
function. Note that CheckArgs formats any 'NUM' (numeric) argument.

10.2.1 ABS

ABS returns the absolute value of its argument.

call CheckArgs 'rNUM'
Number=#Bif Arg.1

if left (Number,1) = '-' then Number = substr (Number, 2)
return Number

10.2.2 FORMAT

109
FORMAT formats its first argument. The second argument specifies the number of characters to be
used for the integer part and the third specifies the number of characters for the decimal part. The fourth
argument specifies the number of characters for the exponent and the fifth determines when exponeniial
notation is used.

call CheckArgs,
'rNUM OWHOLE>=0 OWHOLE>=0 OWHOLE>=0 OWHOLE>=0'

if #Bif_ArgExists.2 then Before #Bif Arg.2
if #Bif_ArgExists.3 then After #Bif Arg.3
if #Bif_ArgExists.4 then Expp #Bif Arg.4

if #Bif_ArgExists.5 then Expt = #Bif Arg.5

/* In the simplest case the first is the only argument. */
Number=#Bif Arg.1

if #Bif_Arg.0 < 2 then return Number

/* Dissect the Number. It is in the normal Rexx format. */
parse var Number Mantissa 'E' Exponent

if Exponent == '' then Exponent = 0
Sign = 0
if left (Mantissa,1) == '-' then do
Sign = 1
Mantissa = substr(Mantissa, 2)
end
parse var Mantissa Befo '.' Afte

/* Count from the left for the decimal point. */

Point = length (Befo)

/* Sign Mantissa and Exponent now reflect the Number. Befo Afte and
Point reflect Mantissa. */

/* The fourth and fifth arguments allow for exponential notation. */
/* Decide whether exponential form to be used, setting ShowExp. */
ShowExp = 0
if #Bif_ArgExists.4 #Bif ArgExists.5 then do
if \#Bif_ArgExists.5 then Expt = #Digits.#Level
/* Decide whether exponential form to be used. */
if (Point + Exponent) > Expt then ShowExp = 1 /* Digits before rule. */
LeftOfPoint = 0
if length(Befo) > 0 then LeftOfPoint = Befo /* Value left of
the point */

/* Digits after point rule for exponentiation: */

/* Count zeros to right of point. */

ze=O0

do while substr(Afte,z+1,1) == '0'
Zeze+41tl
end

if LeftOfPoint = 0 & (z - Exponent) > 5 then ShowExp = 1

/* An extra rule for exponential form: */
if #Bif_ArgExists.4 then if Expp = 0 then ShowExp = 0

/* Construct the exponential part of the result. */
if ShowExp then do

Exponent = Exponent + ( Point - 1 )
Point = 1 /* As required for 'SCIENTIFIC! */
if #Form.#Level == 'ENGINEERING' then
do while Exponent//3 \= 0

Point = Point+1l

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

110
111

end
end

/* ShowExp now indicates whether to show an exponent,
Exponent is its value. */
/* Make this a Number without a point.

Integer = Befo||Afte

*/

/* Make sure Point position isn't disjoint from Integer. */
if Point<1 then do /* Extra zeros on the left. */

Integer =
Point = 1
end

copies('0',1 - Point)

if Point > length(Integer) then
Integer = left(Integer,Point,'0') /* And maybe on the right.

/* Deal with right of decimal point first since that can affect the

|| Integer

left. Ensure the requested number of digits there.
Afters = length(Integer) -Point

if #Bif_ArgExists.3 = 0 then After =
/* Make Afters match the requested After */

do while Afters < After
Afters = Afters+1
Integer = Integer'0'
end

if Afters > After then do

/* Round by adding 5 at the right place.

Afters

r=substr (Integer, Point + After + 1,

Integer = left (Integer,

1)

Point + After)

if r >= '5' then Integer = Integer + 1
/* This can leave the result zero.
If Integer = 0 then Sign = 0

/* The case when rounding makes the integer longer is an awkward

*/

*/

one. The exponent will have to be adjusted. */
if length(Integer) > Point + After then do

Point = Point+l
end

if ShowExp = 1 then do

Exponent=Exponent + (Point - 1)

Point = 1 /* As required for 'SCIENTIFIC! */

if form() = 'ENGINEERING' then
do while Exponent//3 \= 0

Point = Point+

1

Exponent = Exponent-1

end
end

t = Point-length (Integer)
if t > 0 then Integer = Integer||copies('0',t)

end /* Rounded */

/* Right part is final
if After > 0 then Afte
else Afte

now. */
'.'| |substr (Integer, Point+1,After)

/* Now deal with the integer part of the result.
Integer = left (Integer, Point)

if #Bif ArgExists.2 =

0 then Before

/* Make Point match Before */
if Point > Before - Sign then call Raise

do while Point<Before
Point = Point+1l
Integer = '0'Integer
end

40.38,

*/

Point + Sign /* Note default.

2,

/* Find the Sign position and blank leading zeroes.

re ter
Triggered = 0

do j = 1 to length (Integer)
Digit = substr(Integer,j,1)
/* Triggered is set when sign inserted or blanking finished.
if Triggered = 1 then do

r= r||Daigit
iterate
end

*/

/* Note default.

#Bif Arg.1

*/

*/

*/

*/

*/
/* If before sign insertion point then blank out zero. */

if Digit = '0' then
if ats cael = '0' & j+l<length(Integer) then do
re r ' '
iterate
end
/* j is the sign insertion point. */
if Digit = '0' & j \= length(Integer) then Digit = ' '

if Sign = 1 then Digit = '-'
r= xr||Digit
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
if #Bif_ ArgExists.4 = 0 then Expp = length (Exponent)
if length(Exponent) > Expp then
call Raise 40.38, 4, #Bif_ Arg.1
Exponent=right (Exponent,Expp,'0')
if Exponent = 0 then do
if #Bif_ ArgExists.4 then Expart = copies(' ',expp+2)
end
else if SignExp = 0 then Expart
else Expart
Number = Number | |Expart
end
return Number

'E+' Exponent
'E- ' Exponent

10.2.3 MAX
MAX returns the largest of its arguments.

if #Bif_Arg.0 <1 then
call Raise 40.3, 1
call CheckArgs 'rNUM'||copies(' rNUM', #Bif Arg.0 - 1)

Max = #Bif Arg.1

do i = 2 to #Bif Arg.0 by 1
Next = #Bif Arg.i
if Max < Next then Max = Next
end i

return Max

10.2.4 MIN
MIN returns the smallest of its arguments.

if #Bif_Arg.0 <1 then
call Raise 40.3, 1
call CheckArgs 'rNUM'||copies(' rNUM', #Bif Arg.0 - 1)

Min = #Bif Arg.1

do i = 2 to #Bif Arg.0 by 1
Next = #Bif Arg.i
if Min > Next then Min = Next
end i

return Min

10.2.5 SIGN
SIGN returns '1', '0' or '-1' according to whether its argument is greater than, equal to, or less than zero.

call CheckArgs 'rNUM'

Number = #Bif Arg.1

112
select

when Number < 0 then Output = -1
when Number = 0 then Output = 0
when Number > 0 then Output = 1

end
return Output

10.2.6 TRUNC
TRUNC returns the integer part of its argument, or the integer part plus a number of digits after the
decimal point, specified by the second argument.

call CheckArgs 'rNUM oWHOLE>=0'

Number = #Bif Arg.1
if #Bif_ArgExists.2 then Num

#Bif Arg.2
else Num 0

Integer =(10**Num * Number) %1
if Num=0 then return Integer

t=length (Integer) -Num
if t<=0 then return '0.'right(Integer,Num,'0')
else return insert('.',Integer,t)

10.3 State built-in functions

These functions return values from the state of the execution.

10.3.1 ADDRESS

ADDRESS returns the name of the environment to which commands are currently being submitted.
Optionally, under control by the argument, it also returns information on the targets of command output
and the source of command input.

call CheckArgs 'oEINO'

if #Bif_ArgExists.1 then Optionl = #Bif_Arg.1
else Optionl='N'

if Optionl == 'N' then return #Env_Name.ACTIVE. #Level

Tail = Optionl' .ACTIVE. '#Level
return #Env_Position.Tail #Env_Type.Tail #Env_Resource.Tail

10.3.2 ARG

ARG returns information about the argument strings to a program or routine, or the value of one of those
strings.

ArgData = 'OWHOLE>0 oENO'
if #Bif_ ArgExists.2 then ArgData = 'rWHOLE>0 rENO'
call CheckArgs ArgData

if \#Bif_ArgExists.1 then return #Arg.#Level.0

ArgNum=#Bif Arg.1

if \#Bif_ArgExists.2 then return #Arg.#Level.ArgNum

if #Bif_Arg.2 =='0O' then return \#ArgExists.#Level.ArgNum
else return #ArgExists.#Level .ArgNum

10.3.3 CONDITION
CONDITION returns information associated with the current condition.

call CheckArgs 'oCDEIS'

/* Values are null if this is not following a condition. */
if #Condition.#Level == '' then do
#ConditionDescription.#Level = ''
#ConditionExtra.#Level = ''
#ConditionInstruction.#Level

113
end

Option=#Bif Arg.1

if Option=='C' then return #Condition.#Level

if Option=='D' then return #ConditionDescription. #Level
if Option=='E' then return #ConditionExtra.#Level

if Option=='I' then return #ConditionInstruction. #Level
/* State is the current state. */

if #Condition.#Level = '' then return ""
return #Enabling.#Condition.#Level
10.3.4 DIGITS

DIGITS returns the current setting of NUMERIC DIGITS.
call CheckArgs ''

return #Digits.#Level

10.3.5 ERRORTEXT

ERRORTEXT returns the unexpanded text of the message which is identified by the first argument. A
second argument of 'S' selects the standard English text, otherwise the text may be translated to another
national language. This translation is not shown in the code below.

call CheckArgs 'r0_90 oSN'

msgcode = #Bif Arg.1

if #Bif_ ArgExists.2 then Option
else Option

return #ErrorText .msgcode

10.3.6 FORM
FORM returns the current setting of NUMERIC FORM.

#Bif_Arg.2
tint

call CheckArgs ''

return #Form.#Level

10.3.7 FUZZ
FUZZ returns the current setting of NUMERIC FUZZ.

call CheckArgs ''

return #Fuzz.#Level

10.3.8 SOURCELINE

If there is no argument, SOURCELINE returns the number of lines in the program, or '0' if the source
program is not being shown on this execution. If there is an argument it specifies the number of the line
of the source program to be returned.

call CheckArgs 'oWHOLE>0'

if \#Bif_ArgExists.1 then return #SourceLine.0
Num = #Bif_Arg.1
if Num > #SourceLine.0O then
call Raise 40.34, Num, #SourceLine.0
return #SourceLine.Num

10.3.9 TRACE
TRACE returns the trace setting currently in effect, and optionally alters the setting.

call CheckArgs 'oACEFILNOR' /* Also checks for '?!' */
/* With no argument, this a simple query. */
Output=#Tracing.#Level

if #Interactive.#Level then Output = '?'||Output
if \#Bif_ArgExists.1 then return Output

114
Value=#Bif Arg.1

#Interactive.#Level=0

/* A question mark sets the interactive flag. */
if left(Value,1)=='?' then do

#Interactive.#Level = 1

Value=substr (Value, 2)

end
/* Absence of a letter leaves the setting unchanged. */
if Value\=='' then do

Value=translate (left (Value,1))
if Value=='0O' then #Interactive.#Level='0'
#Tracing.#Level = Value
end
return Output

10.4 Conversion built-in functions

Conversions between Binary form, Decimal form, and heXadecimal form do not depend on the encoding
(see nnn) of the character data.

Conversion to Coded form gives a result which depends on the encoding. Depending on the encoding,
the result may be a string that does not represent any sequence of characters.

10.4.1 B2xX

B2X performs binary to hexadecimal conversion.

call CheckArgs 'rBIN'

String = space (#Bif Arg.1,0)
return ReRadix(String,2,16)

10.4.2 BITAND

The functions BITAND, BITOR and BITXOR operate on encoded character data. Each binary digit from
the encoding of the first argument is processed in conjunction with the corresponding bit from the second
argument.

call CheckArgs 'rANY oANY oPAD'

Stringl = #Bif_ Arg.1
if #Bif ArgExists.2 then String2

#Bif Arg.2
else String2 rr

/* Presence of a pad implies character strings. */
if #Bif_ArgExists.3 then
if length(Stringl) > length(String2) then
String2=left (String2,length(String1l),#Bif_Arg.3)
else
Stringl=left(Stringl,length(String2),#Bif_Arg.3)

/* Change to manifest bit representation. */
#Response=Config C2B(String1)
String1l=#Outcome
#Response=Config C2B(String2)
String2=#0utcome
/* Exchange if necessary to make shorter second. */
if length(Stringl)<length(String2) then do

t=Stringl

Stringl=String2

String2=t

end

/* Operate on common length of those bit strings. */
r=''
do j=1 to length (String2)

bl=substr (Stringl,j,1)

b2=substr (String2,j,1)

select
when #Bif='BITAND' then
b1=b1&b2
when #Bif='BITOR' then
bl=b1|b2

115
when #Bif='BITXOR' then
b1=b1&&b2
end
r=r||bl
end j
rer || right (Stringl, length (String1) -length(String2) )

/* Convert back to encoded characters. */
return x2c (b2x(r))

10.4.3 BITOR

See nnn

10.4.4 BITXOR

See nnn

10.4.5 C2D

C2D performs coded to decimal conversion.

call CheckArgs 'rANY oWHOLE>=0'
if length(#Bif Arg.1)=0 then return 0

if #Bif_ArgExists.2 then do
/* Size specified */
Size = #Bif_Arg.2
if Size = 0 then return 0
/* Pad will normally be zeros */
t=right (#Bif Arg.1,Size,left (xrange(),1))
/* Convert to manifest bit */
call Config C2B t
/* And then to signed decimal. */
Sign = Left (#Outcome,1)
#Outcome = substr(#Outcome, 2)
t=ReRadix (#Outcome, 2,10)
/* Sign indicates 2s-complement. */
if Sign then t=t-2**length(#Outcome)
if abs(t) > 10 ** #Digits.#Level - 1 then call Raise 40.35, t
return t
end
/* Size not specified. */
call Config C2B #Bif_Arg.1
t = ReRadix(#Outcome, 2,10)
if t > 10 ** #Digits.#Level - 1 then call Raise 40.35, t
return t

10.4.6 C2Xx
C2X performs coded to hexadecimal conversion.

call CheckArgs 'rANY'
if length(#Bif Arg.1) = 0 then return ''

call Config C2B #Bif_Arg.1
return ReRadix (#Outcome,2,16)

10.4.7 D2C
D2C performs decimal to coded conversion.

'rWHOLENUM>=0'!
'rWHOLENUM rWHOLE>=0'

if \#Bif_ArgExists.2 then ArgData
else ArgData
call CheckArgs ArgData

/* Convert to manifest binary */
Subject = abs(#Bif Arg.1)
r = ReRadix(Subject,10,2)
/* Make length a multiple of 8, as required for Config B2C */
Length = length(r)
do while Length//8 \= 0
Length = Length+1
end
r= right(r,Length,'0')

116
/* 2s-complement for negatives. */
if #Bif_Arg.1<0 then do
Subject = 2**length(r)-Subject
r = ReRadix(Subject,10,2)
end
/* Convert to characters */
#Response = Config B2C(r)
Output = #Outcome
if \#Bif_ArgExists.2 then return Output

/* Adjust the length with appropriate characters. */
if #Bif_Arg.1>=0 then return right (Output, #Bif_Arg.2,left(xrange(),1))
else return right (Output, #Bif Arg.2,right (xrange(),1))

10.4.8 D2X
D2X performs decimal to hexadecimal conversion.
if \#Bif_ArgExists.2 then ArgData = 'rWHOLENUM>=0'
else ArgData = 'rWHOLENUM rWHOLE>=0'

call CheckArgs ArgData

/* Convert to manifest hexadecimal */
Subject = abs(#Bif Arg.1 )
r = ReRadix(Subject,10,16)
/* Twos-complement for negatives */
if #Bif_Arg.1<0 then do
Subject = 16**length(r) -Subject
r = ReRadix(Subject,10,16)
end
if \#Bif_ArgExists.2 then return r
/* Adjust the length with appropriate characters. */
if #Bif_ Arg.1>=0 then return right(r,#Bif Arg.2,'0')
else return right(r,#Bif Arg.2,'F')

10.4.9 X2B
X2B performs hexadecimal to binary conversion.

call CheckArgs 'rHEX'

Subject = #Bif Arg.1

if Subject == '' then return ''

/* Blanks were checked by CheckArgs, here they are ignored. */
Subject = space (Subject, 0)

return ReRadix(translate (Subject) ,16,2)

10.4.10 X2C
X2C performs hexadecimal to coded character conversion.

call CheckArgs 'rHEX'

Subject = #Bif Arg.1

if Subject == '' then return ''

Subject = space (Subject, 0)

/* Convert to manifest binary */

r = ReRadix(translate (Subject) ,16,2)

/* Convert to character */

Length = 8*( (length (Subject) +1) %2)
#Response = Config B2C(right(r,Length,'0'))
return #Outcome

10.4.11 X2D
X2D performs hexadecimal to decimal conversion.

call CheckArgs 'rHEX OWHOLE>=0'

Subject = #Bif Arg.1
if Subject == '' then return '0'

Subject = translate (space (Subject,0))

117
if #Bif ArgExists.2 then

Subject = right (Subject, #Bif Arg.2,'0')
if Subject =='' then return '0'
/* Note the sign */
if #Bif ArgExists.2 then SignBit

else SignBit

/* Convert to decimal */
r = ReRadix(Subject,16,10)
/* Twos-complement */
if SignBit then r = 2**(4*#Bif Arg.2) - r
if abs(r)>10 ** #Digits.#Level - 1 then call Raise 40.35, t
return r

left (x2b (Subject) ,1)
ror

10.5 Input/Output built-in functions
The configuration shall provide the ability to access streams. Streams are identified by character string
identifiers and provide for the reading and writing of data. They shall support the concepts of characters,
lines, and positioning. The input/output built-in functions interact with one another, and they make use of
Config_ functions, see nnn. When the operations are successful the following characteristics shall be
exhibited:
- The CHARIN/CHAROUT functions are insensitive to the lengths of the arguments. The data written
to a stream by CHAROUT can be read by a different number of CHARINs.
- The CHARIN/CHAROUT functions are reflective, that is, the concatenation of the data read from a
persistent stream by CHARIN (after positioning to 1, while CHARS(Stream)>0), will be the same as
the concatenation of the data put by CHAROUT.
- All characters can be used as CHARIN/CHAROUT data.
- The CHARS(Stream, 'N') function will return zero only when a subsequent read (without positioning)
is guaranteed to raise the NOTREADY condition.
- The LINEIN/LINEOUT functions are sensitive to the length of the arguments, that is, the length of a
line written by LINEOUT is the same as the length of the string returned by successful LINEIN of the
line.
- Some characters, call them line-banned characters, cannot reliably be used as data for
LINEIN/LINEOUT. If these are not used, LINEIN/LINEOUT is reflective. If they are used, the result is
not defined. The set of characters which are line-barred is a property of the configuration.
- The LINES(Stream, 'N’) function will return zero only when a subsequent LINEIN (without
positioning) is guaranteed to raise the NOTREADY condition.
- When a persistent stream is repositioned and written to with CHAROUT, the previously written data
is not lost, except for the data overwritten by this latest CHAROUT.
- When a persistent stream is repositioned and written to with LINEOUT, the previously written data is
not lost, except for the data overwritten by this latest LINEOUT, which may leave lines partially
overwritten.
10.5.1. CHARIN
CHARIN returns a string read from the stream named by the first argument.

call CheckArgs 'oSTREAM oOWHOLE>0 oOWHOLE>=0'

if #Bif_ArgExists.1 then Stream
else Stream
#StreamState.Stream = ''
/* Argument 2 is positioning. */
if #Bif_ArgExists.2 then do
#Response = Config Stream Position(Stream, 'CHARIN', #Bif Arg.2)

#Bif Arg.1

if left(#Response, 1) == 'R' then call Raise 40.41, 2, #Bif_ Arg.2
if left(#Response, 1) == 'T' then call Raise 40.42,Stream
end

/* Argument 3 is how many. */
if #Bif_ArgExists.3 then Count
else Count
if Count = 0 then do
call Config Stream Charin Stream, 'NULL' /* "Touch" the stream */
return '!
end
/* The unit may be eight bits (as characters) or one character. */
call Config Stream Query Stream

#Bif Arg.3
1

118
Mode = #Outcome

do until Count = 0

#Response = Config Stream Charin(Stream, 'CHARIN')

if left(#Response, 1) \== 'N' then do
if left (#Response, 1) == 'E' then #StreamState.Stream = 'ERROR'
/* This call will return. */
call #Raise 'NOTREADY', Stream, substr(#Response, 2)
leave
end

r = r| |#Outcome

Count = Count-1

end
if Mode == 'B' then do
call Config B2C r
r = #Outcome
end
return r

10.5.2 CHAROUT
CHAROUT returns the count of characters remaining after attempting to write the second argument to the
stream named by the first argument.

call CheckArgs 'oSTREAM oANY oWHOLE>0'

if #Bif_ArgExists.1 then Stream
else Stream

#Bif Arg.1

#StreamState.Stream = ''
if \#Bif ArgExists.2 & \#Bif_ArgExists.3 then do
/* Position to end of stream. */
#Response = Config Stream Close (Stream)
if left (#Response,1) == 'T' then call Raise 40.42,Stream
return 0
end

if #Bif_ArgExists.3 then do
/* Explicit positioning. */
#Response = Config Stream Position(Stream, 'CHAROUT', #Bif Arg.3)

if left (#Response,1) == 'T' then call Raise 40.42,Stream
if left(#Response, 1) == 'R' then call Raise 40.41, 3, #Bif_ Arg.3
end

if \#Bif_ArgExists.2 | #Bif_Arg.2 == '' then do
call Config Stream _Charout Stream, 'NULL' /* "Touch" the stream */
return 0
end

String = #Bif Arg.2
call Config Stream Query Stream
Mode = #Outcome
if Mode == 'B' then do
call Config C2B String
String = #Outcome
Stride = 8
Residue = length(String)/8
end
else do
Stride = 1
Residue = length (String)
end

Cursor = 1
do while Residue>0
Piece = substr (String, Cursor, Stride)
Cursor = Cursor+Stride
call Config Stream Charout Stream, Piece
if left (#Response, 1) \== 'N' then do
if left (#Response, 1) == 'E' then #StreamState.Stream = 'ERROR'
call #Raise 'NOTREADY', Stream, substr(#Response, 2)

119
return Residue
end
Residue = Residue - 1
end
return 0

10.5.3 CHARS

CHARS indicates whether there are characters remaining in the named stream. Optionally, it returns a

count of the characters remaining and immediately available.

call CheckArgs 'oSTREAM oCN'

if #Bif_ArgExists.1 then Stream = #Bif_Arg.1
else Stream = ''

if #Bif_ArgExists.2 then Option = #Bif Arg.2
else Option = 'N'

call Config Stream Count Stream, 'CHARS', Option
return #Outcome

10.5.4 LINEIN
LINEIN reads a line from the stream named by the first argument, unless the third argument is Zero.

call CheckArgs 'oSTREAM oOWHOLE>0 oOWHOLE>=0'

if #Bif_ArgExists.1 then Stream
else Stream
#StreamState.Stream = ''
if #Bif_ArgExists.2 then do
#Response = Config Stream Position(Stream, 'LINEIN', #Bif Arg2)
if left (#Response, 1) 'T' then call Raise 40.42,Stream
if left (#Response, 1) 'R' then call Raise 40.41, 2, #Bif_ Arg.2
end
if #Bif_ArgExists.3 then Count #Bif Arg.3
else Count 1
if Count>1 then call Raise 40.39, Count
if Count = 0 then do
call Config Stream Charin Stream, 'NULL' /* "Touch" the stream */
return '!
end
/* A configuration may recognise lines even in 'binary' mode. */
call Config Stream Query Stream
Mode = #Outcome
re ter
t = #Linein Position.Stream
/* Config Stream Charin will alter #Linein Position. */
do until t \= #Linein Position.Stream
#Response = Config Stream Charin(Stream, 'LINEIN')
if left(#Response, 1) \== 'N' then do
if left (#Response, 1) == 'E' then #StreamState.Stream = 'ERROR'
call #Raise 'NOTREADY', Stream, substr(#Response, 2)
leave
end
r = r||#Outcome
end
if Mode == 'B' then do
call Config B2C r
r= #Outcome
end
return r

#Bif Arg.1

10.5.5 LINEOUT

LINEOUT returns '1' or '0', indicating whether the second argument has been successfully written to the

stream named by the first argument. A result of '1' means an unsuccessful write.
call CheckArgs 'oSTREAM oANY oWHOLE>0'

if #Bif_ArgExists.1 then Stream
else Stream

#Bif Arg.1

120
#StreamState.Stream = ''

if \#Bif ArgExists.2 & \#Bif_ArgExists.3 then do

/* Position to end of stream.

*/

#Response = Config Stream Close (Stream)
if left (#Response,1) == 'T' then call Raise 40.42,Stream

return 0
end

if #Bif_ArgExists.3 then do

#Response = Config Stream Position(Stream, 'LINEOUT', #Bif Arg.3)

if left(#Response, 1) == 'T' then call Raise 40.42,Stream
if left (#Response, 1) == 'R' then call Raise 40.41, 3, #Bif_Arg.3
end

if \#Bif ArgExists.2 then do

call Config Stream _Charout Stream, '' /* "Touch" the stream */

return 0
end

String #Bif Arg.2
Stride 1
call Config Stream Query Stream
Mode = #Outcome
if Mode == 'B' then do
call Config C2B String
String = #Outcome
Stride = 8
Residue = length(String)/8
end
else do
Stride = 1
Residue = length(String)
end
Cursor = 1
do while Residue > 0

Piece = substr (String, Cursor, Stride)

Cursor = Cursor+Stride

call Config Stream Charout Stream, Piece
then do

then #StreamState.Stream = 'ERROR'

call #Raise 'NOTREADY', Stream, substr(#Response, 2)

if left(#Response, 1) \== 'N'
if left (#Response, 1) == 'E'
return 1
end
Residue = Residue-1
end
call Config Stream Charout Stream,
return 0
10.5.6 LINES

'EOL'

LINES returns the number of lines remaining in the named stream.

call CheckArgs 'oSTREAM oCN'

if #Bif_ArgExists.1 then Stream
else Stream
if #Bif_ ArgExists.2 then Option
else Option

Call Config Stream Count Stream,
return #Outcome

10.5.7 QUALIFY

#Bif Arg.1
ter
#Bif_Arg.2
tint

LINES', Option

QUALIFY returns a name for the stream named by the argument. The two names are currently
associated with the same resource and the result of QUALIFY may be more persistently associated with

that resource.
call CheckArgs 'oSTREAM'

if #Bif_ArgExists.1 then Stream
else Stream

121

#Bif Arg.1
#Response = Config Stream Qualified (Stream)
return #Outcome

10.5.8 STREAM
STREAM returns a description of the state of, or the result of an operation upon, the stream named by
the first argument.

/* Third argument is only correct with 'C' */

if #Bif ArgExists.2 & translate(left(#Bif Arg.2, 1)) == 'C' then
ArgData = 'rSTREAM rCDS rANY'

else
ArgData = 'rSTREAM oCDS'

call CheckArgs ArgData

Stream = #Bif_Arg.1

if #Bif_ ArgExists.2 then Operation = #Bif_Arg.2
else Operation = 'S'
Select
when Operation == 'C' then do

call Config Stream Command Stream, #Bif Arg.3
return #Outcome

end
when Operation == 'D' then do
#Response = Config Stream State (Stream)
return substr(#Response, 2)
end
when Operation == 'S' then do
if StreamState.Stream == 'ERROR' then return 'ERROR'
#Response = Config Stream State (Stream)

'N' then return 'READY'
'U' then return 'UNKNOWN'

if left (#Response,
if left (#Response,
return 'NOTREADY'
end

end

1) ==
1) ==

10.6 Other built-in functions

10.6.1 DATE

DATE with fewer than two arguments returns the local date. Otherwise it converts the second argument
(which has a format given by the third argument) to the format specified by the first argument. If there are
fourth or fifth arguments, they describe the treatment of separators between fields of the date.

call CheckArgs 'oBDEMNOSUW oANY oOBDENOSU oSEP oSEP'
/* If the third argument is given then the second is mandatory. */
if #Bif_ArgExists.3 & \#Bif_ArgExists.2 then

call Raise 40.19, '', #Bif Arg.3

if #Bif_ ArgExists.1 then Option
else Option

#Bif Arg.1
tint

/* The date/time is ‘frozen’ throughout a clause. */
if #ClauseTime.#Level == '' then do
#Response = Config Time ()
#ClauseTime.#Level = #Time
#ClauseLocal.#Level = #Time + #Adjust<Index "#Adjust" # "" >
end
/* English spellings are used, even if messages not in English are used. */
Months = 'January February March April May June July',
‘August September October November December'
WeekDays = 'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'

/* If there is no second argument, the current date is returned. */
if \#Bif ArgExists.2 then
return DateFormat (#ClauseLocal.#Level, Option)

/* If there is a second argument it provides the date to be
converted. */

122
Value = #Bif_Arg.2
if #Bif_ ArgExists.3 then InOption
else InOption
if Option == 'S' then OutSeparator
else OutSeparator
if #Bif_ArgExists.4 then do

if OutSeparator == 'x' then call
OutSeparator = #Bif.Arg.4
end

if InOption == 'S' then InSeparator

else InSeparator
if #Bif_ArgExists.5 then do

#Bif_Arg.3
'nt

translate (Option, "xx/x //x","BDEMNOUW")

Raise 40.46, Option, 4

translate(InOption,"xx/ //","BDENOU")

if InSeparator == 'x' then call Raise 40.46, InOption, 5

InSeparator = #Bif.Arg.5
end
/* First try for Year Month Day */
Logic = 'NS'
select
when InOption == 'N' then do
if InSeparator == '' then do

if length(Value)<9 then return
Year = right (Value, 4)

MonthIs = substr (right (Value,7),1,3)
Day = left (Value, length (Value) -7)

end
else

parse var Value Day (InSeparator) MonthIs (InSeparator) Year

do Month = 1 to 12
if left(word(Months, Month), 3)

== MonthIs then leave

parse var Value Year (InSeparator) Month (InSeparator) Day

end Month

end

when InOption == 'S' then
if InSeparator == '' then

parse var Value Year +4 Month +2 Day

else

otherwise
Logic = 'EOU' /* or BD */

end

/* Next try for year without century */

parse var Value Day (InSeparator) Month (InSeparator) YY

parse var Value YY (InSeparator) Month (InSeparator) Day

parse var Value Month (InSeparator) Day (InSeparator) YY

if logic = 'EOU' then
Select
when InOption == 'E' then
if InSeparator == '' then
parse var Value Day +2 Month +2 YY
else
when InOption == 'O' then
if InSeparator == '' then
parse var Value YY +2 Month +2 Day
else
when InOption == 'U' then
if InSeparator == '' then
parse var Value Month +2 Day +2 YY
else
otherwise
Logic = 'BD'
end
if Logic = 'EOU' then do

/* The century is assumed, on the basis of the current year. */

if datatype(YY,'W')=0 then
return

YearNow = left('DATE'('S'),4)

Year = YY

do while Year < YearNow-50
Year = Year + 100

end

end /* Century assumption */

123
if Logic <> 'BD' then do
/* Convert Month & Day to Days of year. */
if datatype(Month,'W')=0 | datatype(Day,'W')=0 | datatype(Year,'W')=0 then
return
Days = word('0 31 59 90 120 151 181 212 243 273 304 334',Month),
+ (Month>2)*Leap(Year) + Day-1

end
else

if datatype(Value,'W')=0 then

return

if InOption == 'D' then do

Year = left('DATE' ('S'),4)

Days = Value - 1 /* 'D' includes current day */
end

/* Convert to BaseDays */
if InOption <> 'B' then

BaseDays = (Year-1)*365 + (Year-1)%4 - (Year-1)%100 + (Year-1)%400 + Days
else

Basedays = Value

/* Convert to microseconds from 0001 */
Micro = BaseDays * 86400 * 1000000

/* Reconvert to check the original. (eg for Month = 99) */

if DateFormat (Micro,InOption,InSeparator) \== Value then
call Raise 40.19, Value, InOption

return DateFormat (Micro, Option, OutSeparator)

DateFormat:
/* Convert from microseconds to given format. */
parse value Time2Date(arg(1)) with,
Year Month Day Hour Minute Second Microsecond Base Days

select

when arg(2) == 'B' then

return Base
when arg(2) == 'D' then

return Days
when arg(2) == 'E' then

return right (Day,2,'0') (arg(3)) right (Month,2,'0') (arg(3)) right (Year,2,'0')
when arg(2) == 'M' then

return word (Months ,Month)
when arg(2) == 'N' then

return (Day) (arg(3)) left (word(Months,Month),3) (arg(3))right (Year,4,'0')
when arg(2) == 'O' then

return right (Year,2,'0') (arg(3))right (Month,2,'0') (arg(3))right (Day,2,'0')
when arg(2) == 'S' then

return right (Year,4,'0') (arg(3))right (Month,2,'0') (arg(3))right (Day,2,'0')
when arg(2) == 'U' then

return right (Month,2,'0') (arg(3)) right (Day,2,'0') (arg(3)) right (Year,2,'0')
otherwise /* arg(2) == 'W' */

return word (Weekdays, 1+Base//7)

end

10.6.1 QUEUED
QUEUED returns the number of lines remaining in the external data queue.

call CheckArgs ''

#Response = Config Queued()
return #Outcome

10.6.2 RANDOM
RANDOM returns a quasi-random number.

call CheckArgs 'oWHOLE>=0 oWHOLE>=0 oWHOLE>=0'

if #Bif_Arg.0 = 1 then do
Minimum = 0

124
Maximum = #Bif Arg.1
if Maximum>100000 then
call Raise 40.31, Maximum

end
else do
if #Bif_ArgExists.1 then Minimum = #Bif Arg.1
else Minimum = 0
if #Bif_ArgExists.2 then Maximum = #Bif_Arg.2
else Maximum = 999

end

if Maximum-Minimum>100000 then
call Raise 40.32, Minimum, Maximum

if Maximum-Minimum<0 then
call Raise 40.33, Minimum, Maximum

if #Bif_ArgExists.3 then call Config Random Seed #Bif_Arg.3
call Config Random Next Minimum, Maximum
return #Outcome

10.6.3 SYMBOL

The function SYMBOL takes one argument, which is evaluated. Let String be the value of that argument.
If Config_Length(String) returns an indicator 'E' then the SYNTAX condition 23.1 shall be raised.
Otherwise, if the syntactic recognition described in section nnn would not recognize String as a symbol
then the result of the function SYMBOL is 'BAD".

If String would be recognized as a symbol the result of the function SYMBOL depends on the outcome of
accessing the value of that symbol, see nnn. If the final use of Var_Value leaves the indicator with value
‘D' then the result of the function SYMBOL is 'LIT', otherwise 'VAR'.

10.6.4 TIME

TIME with less than two arguments returns the local time within the day, or an elapsed time. Otherwise it
converts the second argument (which has a format given by the third argument) to the format specified by
the first argument.

call CheckArgs 'oCEHLMNORS oANY oCHLMNS'
/* If the third argument is given then the second is mandatory. */
if #Bif_ArgExists.3 & \#Bif_ArgExists.2 then

call Raise 40.19, '', #Bif Arg.3

if #Bif_ ArgExists.1 then Option
else Option

#Bif Arg.1
tint

/* The date/time is 'frozen' throughout a clause. */

if #ClauseTime.#Level == '' then do
#Response = Config Time ()
#ClauseTime.#Level = #Time
#ClauseLocal.#Level = #Time + #Adjust<Index "#Adjust" # "" >
end

/* If there is no second argument, the current time is returned. */
if \#Bif ArgExists.2 then
return TimeFormat (#ClauseLocal.#Level, Option)

/* If there is a second argument it provides the time to be
converted. */
if pos(Option, 'ERO') > 0 then
call Raise 40.29, Option
InValue = #Bif Arg.2

if #Bif_ArgExists.3 then InOption = #Bif_Arg.3
else InOption =

HH = 0

MM = 0

ss = 0

HourAdjust = 0

select

when InOption == 'C' then do
parse var InValue HH ':' . +1 MM +2 XX

if HH = 12 then

125
HH = 0

if XX == 'pm' then
HourAdjust = 12
end
when InOption == 'H' then
HH = InValue
when InOption == 'L' | InOption == 'N' then
parse var InValue HH ':' MM ':' SS
when InOption == 'M' then
MM = InValue
otherwise
SS = InValue

end

if datatype(HH,'W')=0 | datatype(MM,'W')=0 | datatype(SS,'N')=0 then
call Raise 40.19, InValue, InOption

HH = HH + HourAdjust

/* Convert to microseconds */

Micro = trunc((((HH * 60) + MM) * 60 + SS) * 1000000)

/* There is no special message for time-out-of-range; the bad-format

message is used. */

if Micro<0 | Micro > 24*3600*1000000 then call Raise 40.19, InValue, InOption

/* Reconvert to check the original. (eg for hour = 99) */

if TimeFormat (Micro,InOption) \== InValue then
call Raise 40.19, InValue, InOption

return TimeFormat (Micro, Option)

end /* Conversion */

TimeFormat: procedure
/* Convert from microseconds to given format. */
/* The day will be irrelevant; actually it will be the first day possible. */
x = Time2Date2(arg(1))
parse value x with Year Month Day Hour Minute Second Microsecond Base Days
select
when arg(2) == 'C' then
select
when Hour>12 then
return Hour-12':'right (Minute,2,'0')'pm'
when Hour=12 then
return '12:'right(Minute,2,'0')'pm'
when Hour>0 then
return Hour':'right (Minute,2,'0')'am'
when Hour=0 then
return '12:'right(Minute,2,'0')'am'
end
when arg(2) == 'H' then return Hour
when arg(2) == 'L' then
return right (Hour,2,'0')':'right (Minute,2,'0')':'right(Second,2,'0'),
|| '.'right (Microsecond,6,'0')
when arg(2) == 'M' then
return 60*Hour+Minute
when arg(2) == 'N' then
return right (Hour,2,'0')':'right (Minute,2,'0')':'right(Second,2,'0')
otherwise /* arg(2) == 'S' */
return 3600*Hour+60*Minute+Second
end

Time2Date:
/* These are checks on the range of the date. */
if arg(1) < 0 then
call Raise 40.19, InValue, InOption
if arg(1) >= 315537897600000000 then
call Raise 40.19, InValue, InOption
return Time2Date2 (arg(1))

10.6.1 VALUE
VALUE returns the value of the symbol named by the first argument, and optionally assigns it a new

value.

'rANY oOANY oANY'

if #Bif ArgExists.3 then ArgData
'rSYM oANY oOANY'

else ArgData
call CheckArgs ArgData

126
Subject = #Bif Arg.1

if #Bif_ArgExists.3 then do /* An external pool, or the reserved pool. */
/* The reserved pool uses a null string as its pool identifier. */
Pool = #Bif_Arg.3

if Pool == '' then do
Subject = '.' || translate (Subject) /* The dot on the name is implied. */
Value = .environment [Subject] /* Was the translate redundant? */

if #Bif ArgExists.2 then .environment [Subject] = #Bif_ Arg.2
return Value
end

/* Fetch the original value */

#Response = Config Get (Pool, Subject)

#Indicator = left (#Response,1)

if #Indicator == 'F' then
call Raise 40.36, Subject
if #Indicator == 'P' then

call Raise 40.37, Pool
Value = #Outcome
if #Bif_ArgExists.2 then do
/* Set the new value. */
#Response = Config Set(Pool,Subject,#Bif Arg.2)
if #Indicator == 'P' then
call Raise 40.37, Pool
if #Indicator == 'F' then
call Raise 40.36, Subject
end
/* Return the original value. */
return Value
end
/* Not external */
Subject = translate(Subject)
/* See nnn */
Pp = pos(Subject, '.')
if p = 0 | p = length(Subject) then do
/* Not compound */
#Response = Var Value(#Pool, Subject, '0')
/* The caller, in the code of the standard, may need
to test whether the Subject was dropped. */
#Indicator = left(#Response, 1)
Value = #Outcome
if #Bif_ ArgExists.2 then
#Response = Var Set(#Pool, Subject, '0', #Bif_ Arg.2)
return Value
end
/* Compound */
Expanded = left(Subject,p-1) /* The stem */
do forever
Start = p+l1
Pp = pos(Subject,'.',Start)
if p = 0 then p = length(Subject)
Item = substr(Subject,Start,p-Start) /* Tail component symbol */
if Item\=='' then if pos(left(Item,1),'0123456789') = 0 then do
#Response = Var Value(#Pool, Item, '0')
Item = #Outcome
end
/* Add tail component. */
Expanded = Expanded'.'Item
end
#Response = Var Value(#Pool, Expanded, '1')
#Indicator = left(#Response, 1)
Value = #Outcome
if #Bif_ ArgExists.2 then
#Response = Var Set(#Pool, Expanded, '1', #Bif_ Arg.2)

return Value

10.6.1 QUEUED
QUEUED returns the number of lines remaining in the external data queue.

127
call CheckArgs ''
#Response = Config Queued()
return #Outcome

10.6.2 RANDOM
RANDOM returns a quasi-random number.

call CheckArgs 'oWHOLE>=0 oWHOLE>=0 oWHOLE>=0'

if #Bif_Arg.0 = 1 then do
Minimum = 0
Maximum = #Bif_Arg.1
if Maximum>100000 then
call Raise 40.31, Maximum

end
else do
if #Bif_ArgExists.1 then Minimum = #Bif Arg.1
else Minimum = 0
if #Bif_ArgExists.2 then Maximum = #Bif_Arg.2
else Maximum = 999

end

if Maximum-Minimum>100000 then
call Raise 40.32, Minimum, Maximum

if Maximum-Minimum<0 then
call Raise 40.33, Minimum, Maximum

if #Bif_ArgExists.3 then call Config Random Seed #Bif_Arg.3
call Config Random Next Minimum, Maximum
return #Outcome

10.6.3 SYMBOL

The function SYMBOL takes one argument, which is evaluated. Let String be the value of that argument.
If Config_Length(String) returns an indicator 'E' then the SYNTAX condition 23.1 shall be raised.
Otherwise, if the syntactic recognition described in section nnn would not recognize String as a symbol
then the result of the function SYMBOL is 'BAD".

If String would be recognized as a symbol the result of the function SYMBOL depends on the outcome of
accessing the value of that symbol, see nnn. If the final use of Var_Value leaves the indicator with value
‘D' then the result of the function SYMBOL is 'LIT', otherwise 'VAR'.

10.6.4 TIME

TIME with less than two arguments returns the local time within the day, or an elapsed time. Otherwise it
converts the second argument (which has a format given by the third argument) to the format specified by
the first argument.

call CheckArgs 'oCEHLMNORS oANY oCHLMNS'
/* If the third argument is given then the second is mandatory. */
if #Bif_ArgExists.3 & \#Bif_ArgExists.2 then

call Raise 40.19, '', #Bif Arg.3

if #Bif_ ArgExists.1 then Option
else Option

#Bif Arg.1
tint

/* The date/time is 'frozen' throughout a clause. */

if #ClauseTime.#Level == '' then do
#Response = Config Time ()
#ClauseTime.#Level = #Time
#ClauseLocal.#Level = #Time + #Adjust<Index "#Adjust" # "" >
end

/* If there is no second argument, the current time is returned. */
if \#Bif ArgExists.2 then
return TimeFormat (#ClauseLocal.#Level, Option)

/* If there is a second argument it provides the time to be

converted. */
if pos(Option, 'ERO') > 0 then

128
call Raise 40.29, Option
InValue = #Bif Arg.2

if #Bif_ArgExists.3 then InOption = #Bif_Arg.3
else InOption = 'N'
HH = 0
MM = 0
ss = 0
HourAdjust = 0
select
when InOption == 'C' then do
parse var InValue HH ':' . +1 MM +2 XX
if XX == 'pm' then HourAdjust = 12
end
when InOption == 'H' then HH = InValue
when InOption == 'L' | InOption == 'N' then
parse var InValue HH ':' MM ':' SS
when InOption == 'M' then MM = InValue
otherwise SS = InValue
end

if \datatype(HH,'W') | \datatype(MM,'W') | \datatype(SS,'N') then
call Raise 40.19, InValue, InOption

HH = HH + HourAdjust

/* Convert to microseconds */

Micro = trunc((((HH * 60) + MM) * 60 + SS) * 1000000)

/* Reconvert to check the original. (eg for hour = 99) */

if TimeFormat (Micro,InOption) \== InValue then
call Raise 40.19, InValue, InOption

return TimeFormat (Micro, Option)

end /* Conversion */

TimeFormat:
/* Convert from microseconds to given format. */
parse value Time2Date(arg(1)) with,
Year Month Day Hour Minute Second Microsecond Base Days
select
when arg(2) == 'C' then
if Hour>12 then
return Hour-12':'right (Minute,2,'0')'pm'

else
return Hour':'right (Minute,2,'0')'am'
when arg(2) == 'E' | arg(2) == 'R' then do

/* Special case first time */

if #StartTime.#Level == '' then do
#StartTime.#Level #ClauseTime.#Level
return '0O'

end
Output = #ClauseTime.#Level-#StartTime. #Level
if arg(2) == 'R' then

#StartTime.#Level = #ClauseTime.#Level
return Output * 1E-6
end /* E or R */
when arg(2) == 'H' then return Hour
when arg(2) == 'L' then
return right (Hour,2,'0')':'right (Minute,2,'0')':'right(Second,2,'0'),
|| '.'right (Microsecond,6,'0')

when arg(2) == 'M' then return 60*Hour+Minute
when arg(2) == 'N' then
return right (Hour,2,'0')':'right (Minute,2,'0')':'right(Second,2,'0')
when arg(2) == 'O' then
return trunc(#ClauseLocal.#Level - #ClauseTime.#Level)
otherwise /* arg(2) == 'S' */
return 3600*Hour+60*Minute+Second
end
10.6.5 VALUE

VALUE returns the value of the symbol named by the first argument, and optionally assigns it a new
value.

'rANY oOANY oANY'
'rSYM OANY oANY'

if #Bif ArgExists.3 then ArgData
else ArgData
call CheckArgs ArgData

129
130

Subject = #Bif Arg.1

if #Bif_ArgExists.3 then do /* An external pool, or the reserved pool. */
/* The reserved pool uses a null string as its pool identifier. */
Pool = #Bif_Arg.3

if Pool == '' then do
Subject = '.' || translate (Subject) /* The dot on the name is implied. */
Value = .environment [Subject] /* Was the translate redundant? */

if #Bif ArgExists.2 then .environment [Subject] = #Bif_ Arg.2
return Value
end

/* Fetch the original value */

#Response = Config Get (Pool, Subject)

#Indicator = left (#Response,1)

if #Indicator == 'F' then
call Raise 40.36, Subject
if #Indicator == 'P' then

call Raise 40.37, Pool
Value = #Outcome
if #Bif_ArgExists.2 then do
/* Set the new value. */
#Response = Config Set(Pool,Subject,#Bif Arg.2)
if #Indicator == 'P' then
call Raise 40.37, Pool
if #Indicator == 'F' then
call Raise 40.36, Subject
end
/* Return the original value. */
return Value
end
/* Not external */
Subject = translate(Subject)
/* See nnn */
Pp = pos(Subject, '.')
if p = 0 | p = length(Subject) then do
/* Not compound */
#Response = Var Value(#Pool, Subject, '0')
/* The caller, in the code of the standard, may need
to test whether the Subject was dropped. */
#Indicator = left(#Response, 1)
Value = #Outcome
if #Bif_ ArgExists.2 then
#Response = Var Set(#Pool, Subject, '0', #Bif_ Arg.2)
return Value
end
/* Compound */
Expanded = left(Subject,p-1) /* The stem */
do forever
Start = p+l1
Pp = pos(Subject,'.',Start)
if p = 0 then p = length(Subject)
Item = substr(Subject,Start,p-Start) /* Tail component symbol */
if Item\=='' then if pos(left(Item,1),'0123456789') = 0 then do
#Response = Var Value(#Pool, Item, '0')
Item = #Outcome
end
/* Add tail component. */
Expanded = Expanded'.'Item
end
#Response = Var Value(#Pool, Expanded, '1')
#Indicator = left(#Response, 1)
Value = #Outcome
if #Bif_ ArgExists.2 then
#Response = Var Set(#Pool, Expanded, '1', #Bif_ Arg.2)

return Value
