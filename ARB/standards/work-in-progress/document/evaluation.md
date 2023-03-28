7 Evaluation

The syntax section describes how expressions and the components of expressions are written in a
program. It also describes how operators can be associated with the strings, symbols and function results
which are their operands.

This evaluation section describes what values these components have in execution, or how they have no
value because a condition is raised.

This section refers to the DATATYPE built-in function when checking operands, see nnn. Except for
considerations of limits on the values of exponents, the test:

datatype (Subject) == 'NUM'
is equivalent to testing whether the subject matches the syntax:
num := [blank+] ['+' | '-'] [blank+] number  [blank+]

For the syntax of number see nnn.

When the matching subject does not include a '-' the value is the value of the number in the match,
otherwise the value is the value of the expression (0 - number).

The test:

datatype (Subject , 'W')

is a test that the Subject matches that syntax and also has a value that is "whole", that is has no non-zero
fractional part.

When these two tests are made and the Subject matches the constraints but has an exponent that is not

in the correct range of values then a condition is raised:
call #Raise 'SYNTAX', 41.7, Subject

This possibility is implied by the uses of DATATYPE and not shown explicitly in the rest of this section
nnn.

7.1. Variables

The values of variables are held in variable pools. The capabilities of variable pools are listed here,
together with the way each function will be referenced in this definition.

The notation used here is the same as that defined in sections nnn and nnn, including the fact that the
Var_ routines may return an indicator of 'N', 'S' or 'X'.

Each possible name in a variable pool is qualified as tailed or non-tailed name; names with different
qualification and the same spelling are different items in the pool. For those Var_ functions with a third
argument this argument indicates the qualification; it is '1' when addressing tailed names or '0' when
addressing non-tailed names.

Each item in a variable pool is associated with three attributes and a value. The attributes are ‘dropped’ or
‘not-dropped', 'exposed' or 'not-exposed' and ‘implicit’ or 'not-implicit’.

A variable pool is associated with a reference denoted by the first argument, with name Pool. The value
of Pool may alter during execution. The same name, in conjunction with different values of Pool, can
correspond to different values.

7.1.1. Var_Empty

Var_Empty (Pool)

The function sets the variable pool associated with the specified reference to the state where every name
is associated with attributes ‘dropped’, ‘implicit’ and 'not-exposed'.

7.1.2 Var Set
Var _Set(Pool, Name, '0', Value)

The function operates on the variable pool with the specified reference. The name is a non-tailed name. If
the specified name has the ‘exposed’ attribute then Var_Set operates on the variable pool referenced by
#Upper in this pool and this rule is applied to that pool. When the pool with attribute 'not-exposed' for this
name is determined the specified value is associated with the specified name. It also associates the
attributes 'not-dropped' and ‘not-implicit’. If that attribute was previously 'not-dropped' then the indicator
returned is 'R'. The name is a stem if it contains just one period, as its rightmost character. When the
name is a stem Var_Set(Pool, TailedName, '1',Value) is executed for all possible valid tailed names which

have Name as their stem, and then those tailed-names are given the attribute ‘implicit’.
Var _Set(Pool, Name, '1', Value)

The function operates on the variable pool with the specified reference. The name is a tailed name. The
left part of the name, up to and including the first period, is the stem. The stem is a non-tailed name. If the
specified stem has the 'exposed' attribute then Var_Set operates on the variable pool referenced by
#Upper in this pool and this rule is applied to that pool. When the pool with attribute 'not-exposed' for the
stem is determined the name is considered in that pool. If the name has the 'exposed' attribute then the

46
variable pool referenced by #Upper in the pool is considered and this rule applied to that pool. When the
pool with attribute 'not-exposed' is determined the specified value is associated with the specified name.
It also associates the attributes 'not-dropped' and 'not-implicit’ . If that attribute was previously
‘not-dropped' then the indicator returned is 'R’.

7.1.3 Var_Value

Var _Value(Pool, Name, '0')

The function operates on the variable pool with the specified reference. The name is a non-tailed name. If
the specified name has the 'exposed' attribute then Var_Value operates on the variable pool referenced
by #Upper in this pool and this rule is applied to that pool. When the pool with attribute 'not-exposed' for
this name is determined the indicator returned is 'D' if the name has ‘dropped’ associated, 'N' otherwise.
In the former case #Outcome is set equal to Name, in the latter case #Outcome is set to the value most

recently associated with the name by Var_Set.
Var _Value(Pool, Name, '1')

The function operates on the variable pool with the specified reference. The name is a tailed name. The
left part of the name, up to and including the first period, is the stem. The stem is a non-tailed name. If the
specified stem has the 'exposed' attribute then Var_Value operates on the variable pool referenced by
#Upper in this pool and this rule is applied to that pool. When the pool with attribute 'not-exposed' for the
stem is determined the name is considered in that pool. If the name has the 'exposed' attribute then the
variable pool referenced by #Upper in the pool is considered and this rule applied to that pool. When the
pool with attribute 'not-exposed' is determined the indicator returned is 'D' if the name has 'dropped'
associated, 'N' otherwise. In the former case #Outcome is set equal to Name, in the latter case #Outcome
is set to the value most recently associated with the name by Var_Set.

7.1.4 Var_Drop

Var _Drop(Pool, Name, '0')

The function operates on the variable pool with the specified reference. The name is a non-tailed name. If
the specified name has the ‘exposed’ attribute then Var_Drop operates on the variable pool referenced by
#Upper in this pool and this rule is applied to that pool. When the pool with attribute 'not-exposed' for this
name is determined the attribute 'dropped' is associated with the specified name. Also, when the name is
a stem, Var_Drop(Pool,TailedName,'1') is executed for all possible valid tailed names which have Name
as astem.

Var _Drop(Pool, Name, '1')

The function operates on the variable pool with the specified reference. The name is a tailed name. The
left part of the name, up to and including the first period, is the stem. The stem is a non-tailed name. If the
specified stem has the 'exposed' attribute then Var_Drop operates on the variable pool referenced by
#Upper in this pool and this rule is applied to that pool. When the pool with attribute 'not-exposed' for the
stem is determined the name is considered in that pool. If the name has the 'exposed' attribute then the
variable pool referenced by #Upper in the pool is considered and this rule applied to that pool. When the
pool with attribute 'not-exposed' is determined the attribute ‘dropped’ is associated with the specified
name.

7.1.5 Var_Expose

Var_Expose (Pool, Name, '0')

The function operates on the variable pool with the specified reference. The name is a non-tailed name.
The attribute 'exposed' is associated with the specified name. Also, when the name is a stem,
Var_Expose(Pool, TailedName,'1') is executed for all possible valid tailed names which have Name as a
stem.

Var_Expose (Pool, Name, '1')

The function operates on the variable pool with the specified reference. The name is a tailed name. The
attribute 'exposed' is associated with the specified name.

7.1.6 Var_Reset
Var_ Reset (Pool)

The function operates on the variable pool with the specified reference. It establishes the effect of
subsequent API_Next and API_NextVariable functions (see sections nnn and nnn). A Var_Reset is
implied by any API_ operation other than API_Next and API_NextVariable.

7.2 Symbols

For the syntax of a symbol see nnn.

The value of a symbol which is a NUMBER or a CONST_SYMBOL which is not a reserved symbol is the
content of the appropriate token.

47
The value of a VAR_SYMBOL which is "taken as a constant" is the VAR_SYMBOL itself, otherwise the
VAR_SYMBOL identifies a variable and its value may vary during execution.

Accessing the value of a symbol which is not "taken as a constant" shall result in trace output, see nnn:
if #Tracing.#Level == 'I' then call #Trace Tag

where Tag is '>L>' unless the symbol is a VAR_SYMBOL which, when used as an argument to
Var_Value, does not yield an indicator 'D'. In that case, the Tag is '>V>".

7.3. Value of a variable

If VAR_SYMBOL does not contain a period, or contains only one period as its last character, the value of

the variable is the value associated with VAR_SYMBOL in the variable pool, that is #Outcome after
Var_ Value (Pool, VAR SYMBOL, '0')

If the indicator is 'D', indicating the variable has the ‘dropped’ attribute, the NOVALUE condition is raised;
see nnn and nnn for exceptions to this.
#Response = Var Value(Pool, VAR SYMBOL, '0')
if left(#Response,1) == 'D' then
call #Raise 'NOVALUE', VAR_SYMBOL, ''
If VAR_SYMBOL contains a period which is not its last character, the value of the variable is the value
associated with the derived name.
7.3.1 Derived names
A derived name is derived from a VAR_SYMBOL as follows:

VAR SYMBOL := Stem Tail

Stem := PlainSymbol '.'!

Tail i= (PlainSymbol | '.' [PlainSymbol]) ['.' [PlainSymbol1]]+
PlainSymbol := (general letter | digit)+

The derived name is the concatenation of:
- the Stem, without further evaluation;
- the Tail, with the PlainSymbols replaced by the values of the symbols. The value of a PlainSymbol
which does not start with a digit is #Outcome after
Var_ Value (Pool, PlainSymbol,'0')
These values are obtained without raising the NOVALUE condition.

If the indicator from the Var_Value was not 'D' then:
if #Tracing.#Level == 'I' then call #Trace '>C>'

The value associated with a derived name is obtained from the variable pool, that is #Outcome after:
Var_Value(Pool,Derived Name,'1')

If the indicator is 'D', indicating the variable has the ‘dropped’ attribute, the NOVALUE condition is raised;
see nnn for an exception.

7.3.2 Value of a reserved symbol

The value of a reserved symbol is the value of a variable with the corresponding name in the reserved
pool, see nnn.

7.4 Expressions and operators

Add a load of string coercions. Equality can operate on non-strings. What if one operand non-string?

7.4.1. The value of a term

See nnn for the syntax of a ferm.

The value of a STRING is the content of the token; see nnn.

The value of a function is the value it returns, see nnn.

If a termis a symbol or STRING then the value of the term is the value of that symbol or STRING.

If a term contains an expr_alias the value of the term is the value of the expr_alias, see nnn.

7.4.2. The value of a prefix_expression

If the prefix_expression is a term then the value of the prefix_expression is the value of the ferm,
otherwise let rhs be the value of the prefix_expression within it__ see nnn

If the prefix_expression has the form '+' prefix_expression then a check is made:
if datatype(rhs)\=='NUM' then
call #Raise 'SYNTAX',41.3, rhs, '+'

and the value is the value of (0 + rhs).

If the prefix_expression has the form '-' prefix_expression then a check is made:
if datatype(rhs)\=='NUM' then
call #Raise 'SYNTAX',41.3,rhs, '-'

and the value is the value of (0 - rhs).

If a prefix_expression has the form not prefix_expression then
if rhs \== '0' then if rhs \=='1' then call #Raise 'SYNTAX', 34.6, not, rhs

48
See nnn for the value of the third argument to that #Raise.
If the value of rhs is '0' then the value of the prefix_expression value is '1', otherwise it is ‘0’.

If the prefix_expression is not a term then:
if #Tracing.#Level == 'I' then call #Trace '>P>'

7.4.3. The value of a power_expression

See nnn for the syntax of a power_expression.

If the power_expression is a prefix_expression then the value of the power_expression is the value of
the prefix_expression.

Otherwise, let Ihs be the value of power_expression within it, and rhs be the value of prefix_expression
within it.

if datatype(lhs)\=='NUM' then call #Raise 'SYNTAX',41.1,lhs,'**'

if \datatype(rhs,'W') then call #Raise 'SYNTAX',26.1,rhs,'**'

The value of the power_expression is

ArithOp(lhs,'**',rhs)

If the power_expression is not a prefix_expression then:
if #Tracing.#Level == 'I' then call #Trace '>0O>'
7.4.4 The value of a multiplication
See nnn for the syntax of a multiplication.
If the multiplication is a power_expression then the value of the multiplication is the value of the
power_expression.
Otherwise, let Ihs be the value of multiplication within it, and rns be the value of power_expression within
it.
if datatype(lhs)\=='NUM' then
call #Raise 'SYNTAX',41.1,lhs,multiplicative operation
if datatype(rhs)\=='NUM' then
call #Raise 'SYNTAX',41.2,rhs,multiplicative operation

The value of the multiplication is
ArithOp(lhs,multiplicative operation, rhs)

If the multiplication is not a power_expression then:

if #Tracing.#Level == 'I' then call #Trace '>0O>'

7.4.5 The value of an addition

See nnn for the syntax of addition.

If the addition is a multiplication then the value of the addition is the value of the multiplication.
Otherwise, let Ihs be the value of ad¢difion within it, and rhs be the value of the multiplication within it. Let

operation be the adaltive_operator.
if datatype(lhs)\=='NUM' then

call #Raise 'SYNTAX', 41.1, lhs, operation
if datatype(rhs)\=='NUM' then

call #Raise 'SYNTAX', 41.2, rhs, operation

If either of rhs or Ihs is not an integer then the value of the addition is
ArithOp(lhs, operation, rhs)
Otherwise if the operation is '+' and the length of the integer Ihs+rhs is not greater than #Digits.#Level

then the value of addition is
lhs+rhs

Otherwise if the operation is '-' and the length of the integer Ihs-rhs is not greater than #Digits.#Level then

the value of addition is
lhs-rhs

Otherwise the value of the addition is
ArithOp(lhs, operation, rhs)

If the addition is not a multiplication then:
if #Tracing.#Level == 'I' then call #Trace '>0O>'

7.4.6 The value of a concatenation
See nnn for the syntax of a concatenation.
If the concatenation is an addition then the value of the concatenation is the value of the addition.
Otherwise, let Ihs be the value of concatenation within it, and rhs be the value of the additive_expression
within it.
If the concatenation contains '||' then the value of the concatenation will have the following characteristics:
- Config_Length(Value) will be equal to Config_Length(Ihs)+Config_Length(rhs).
- #Outcome will be 'equal' after each of:

49
- Config_Compare(Config_Subsir(Ihs,n)},Config_Subsitr(Value,n)) for values of n not less than 1
and not more than Config_Length(Ihs);
- Config_Compare(Config_Subsir(rhs,n),Config_Substr(Value,Config_Length(Ihs)+n)) for values of
n not less than 1 and not more than Config_Length(rhs).
Otherwise the value of the concatenation will have the following characteristics:

- Config_Length(Value) will be equal to Config_Length(Ihs)+1+Config_Length(rhs).

- #Outcome will be 'equal' after each of:
- Config_Compare(Config_Subsir(Ihs,n)},Config_Subsitr(Value,n)) for values of n not less than 1
and not more than Config_Length(Ihs);
- Config_Compare(' ',Config_Substr(Value,Config_Length(Ihs)}+1));
- Config_Compare(Config_Subsitr(rhs,n),Config_Substr(Value,Config_Length(Ins)+1+n)) for values
of n not less than 1 and not more than Config_Length(rhs).

If the concatenation is not an addition then:
if #Tracing.#Level == 'I' then call #Trace '>0O>'

7.4.7 The value of a comparison

See nnn for the syntax of a comparison.

If the comparison is a concatenation then the value of the comparison is the value of the concatenation.
Otherwise, let Ihs be the value of the comparison within it, and rns be the value of the concatenation
within it.

If the comparison has a comparison_operator that is a strict_compare then the variable #Test is set as
follows:

#Test is set to 'E'. Let Length be the smaller of Config_Length(Ihs) and Config_Length(rhs). For values of
n greater than O and not greater than Length, if any, in ascending order, #Test is set to the uppercased
first character of #Outcome after:

Config_Compare(Config_Subsir(Ihs),Contfig_Subsir(rhs)).

If at any stage this sets #Test to a value other than 'E' then the setting of #Test is complete. Otherwise, if
Config_Length(Ihs) is greater than Config_Length(rhs) then #Test is set to 'G' or if Config_Length(Ihs) is
less than Config_Length(rhs) then #Test is set to 'L’.

If the comparison has a comparison_operator that is a normal_compare then the variable #Test is set as
follows:

if datatype(lhs)\== 'NUM' | datatype(rhs)\== 'NUM' then do
/* Non-numeric non-strict comparison */
lhs=strip(lhs, 'B', ' ') /* ExtraBlanks not stripped */
rhs=strip(rhs, 'B', ' ')

if length(lhs)>length(rhs) then rhs=left (rhs, length (lhs) )
else lhs=left (lhs, length (rhs) )
if lhs>>rhs then #Test='G'
else if lhs<<rhs then #Test='L'
else #Test='E'

end
else do /* Numeric comparison */
if left(-lhs,1) == '-' & left(+rhs,1) \== '-' then #Test='G!
else if left(-rhs,1) == '-' & left(+lhs,1) \== '-' then #Test='L'
else do
Difference=lhs - rhs /* Will never raise an arithmetic condition. */
if Difference > 0 then #Test='G'
else if Difference < 0 then #Test='L'
else #Test='E'
end
end
The value of #Test, in conjunction with the operator in the comparison, determines the value of the
comparison.
The value of the comparison is '1' if
- #Test is 'E' and the operator is one of '="", '=="", '>=', <=", ‘\>', '\<', 'p>=', '<<=', \>>', or <<)

- #Test is 'G' and the operator is one of '>', '>=", ‘\<', ‘\=', '<>', '><', Nes", ‘>>! ‘p>’, or <<")
- #Test is 'L' and the operator is one of '<', <=", \>', \=', '<>', '><', \==', '<<', *<<=', or \>>'.
In all other cases the value of the comparison is '0'.

If the comparison is not a concatenation then:
if #Tracing.#Level == 'I' then call #Trace '>0O>'

7.4.8 The value of an and_expression
See nnn for the syntax of an and_expression.

50
If the and_expression is a comparison then the value of the and_expression is the value of the

comparison.

Otherwise, let Ihs be the value of the and_expression within it, and rhs be the value of the comparison
within it.

if lhs \== '0' then if lhs \== '1' then call #Raise 'SYNTAX',34.5,lhs,'&'

if rhs \== '0' then if rhs \== '1' then call #Raise 'SYNTAX',34.6,rhs,'&'

Value='0'

if lhs == '1' then if rhs == '1' then Value='1'

If the and_expression is not a comparison then:

if #Tracing.#Level == 'I' then call #Trace '>0O>'

7.4.9 The value of an expression

See nnn for the syntax of an expression.

The value of an expression, or an expr, is the value of the expr_alias within it.

If the expr_alias is an and_expression then the value of the expr_alias is the value of the and_expression.
Otherwise, let Ihs be the value of the expr_alias within it, and rhs be the value of the and_expression

within it.
if lhs \== '0' then if lhs \== '1' then

call #Raise 'SYNTAX',34.5,lhs,or operator
if rhs \== '0' then if rhs \== '1' then

call #Raise 'SYNTAX',34.6,rhs,or operator
Value='1'
if lhs == '0' then if rhs == '0' then Value='0'
If the or_operator is '&&' then
if lhs == '1' then if rhs == '1' then Value='0'
If the expr_alias is not an and_expression then:
if #Tracing.#Level == 'I' then call #Trace '>0O>'

The value of an expression or expr shall be traced when #Tracing.#Level is 'R'. The tag is '>=>' when

the value is used by an assignment and '>>>' when it is not.
if #Tracing.#Level == 'R' then call #Trace Tag

7.4.10 Arithmetic operations

The user of this standard is assumed to know the results of the binary operators '+' and '-' applied to
signed or unsigned integers.

The code of ArithOp itself is assumed to operate under a sufficiently high setting of numeric digits to
avoid exponential notation.

ArithoOp:

arg Numberl, Operator, Number2
/* The Operator will be applied to Numberl and Number2 under the numeric
settings #Digits.#Level, #Form.#Level, #Fuzz.#Level */

/* The result is the result of the operation, or the raising of a 'SYNTAX' or
'LOSTDIGITS' condition. */

/* Variables with digit 1 in their names refer to the first argument of the
operation. Variables with digit 2 refer to the second argument. Variables
with digit 3 refer to the result. */

/* The quotations and page numbers are from the first reference in
Annex C of this standard. */

/* The operands are prepared first. (Page 130) Function Prepare does this,
separating sign, mantissa and exponent. */

v = Prepare (Numberl, #Digits.#Level)
parse var v Signl Mantissal Exponentl

v = Prepare (Number2, #Digits.#Level)
parse var v Sign2 Mantissa2 Exponent2

/* The calculation depends on the operator. The routines set Sign3
Mantissa3 and Exponent3. */

Comparator = ''

select
when Operator == '*' then call Multiply

51
when Operator
when Operator

' then call DivType
*' then call Power
when Operator %' then call DivType
when Operator '//" then call DivType
otherwise call AddSubComp

end

call PostOp /* Assembles Number3 */

if Comparator \== '' then do
/* Comparison requires the result of subtraction made into a logical */
/* value. */
t = '0'
select
when left (Number3,1) == '-' then
if wordpos(Comparator,'< <= <> >< \= \>') > 0 then t = '1'
when Number3 \== '0' then
if wordpos(Comparator,'> >= <> >< \= \<') > 0 then t = '1'
otherwise
if wordpos(Comparator,'>= = =< \< \>') > 0 then t = '1!
end
Number3 = t
end
return Number3 /* From ArithOp */
/* Activity before every operation: */
Prepare: /* Returns Sign Mantissa and Exponent */
/* Preparation of operands, Page 130 */
/* ",...terms being operated upon have leading zeros removed (noting the

position of any decimal point, and leaving just one zero if all the digits in

the number are zeros) and are then truncated to DIGITS+1 significant digits
(if necessary)..." */

arg Number, Digits

/* Blanks are not significant. */

/* The exponent is separated */

parse upper value space(Number,0) with Mantissa 'E' Exponent
if Exponent == '' then Exponent = '0'

/* The sign is separated and made explicit. */

Sign = '+' /* By default */
if left(Mantissa,1) == '-' then Sign = '-'
if verify (left (Mantissa,1),'+-') = 0 then Mantissa = substr(Mantissa,2)

/* Make the decimal point implicit; remove any actual Point from the
Mantissa. */
Pp = pos('.',Mantissa)
if p > 0 then Mantissa = delstr(Mantissa,p,1)
else p = 1+length (Mantissa)

/* Drop the leading zeros */
do q = 1 to length(Mantissa) - 1

if substr(Mantissa,g,1) \== '0' then leave
p=p-l
end q

Mantissa = substr(Mantissa,q)

/* Detect if Mantissa suggests more significant digits than DIGITS
caters for. */
do j = Digits+1 to length (Mantissa)
if substr(Mantissa,j,1) \== '0' then call #Raise 'LOSTDIGITS', Number
end j

/* Combine exponent with decimal point position, Page 127 */
/* "Exponential notation means that the number includes a power of ten

following an 'E' that indicates how the decimal point will be shifted. Thus

4E9 is just a shorthand way of writing 4000000000 " */

52
/* Adjust the exponent so that decimal point would be at right of
the Mantissa. */
Exponent = Exponent - (length(Mantissa) - p + 1)

/* Truncate if necessary */

t = length(Mantissa) - (Digits+1)

if t > 0 then do
Exponent = Exponent + t
Mantissa = left (Mantissa,Digits+1)
end

if Mantissa == '0' then Exponent = 0

return Sign Mantissa Exponent

/* Activity after every operation. */
/* The parts of the value are composed into a single string, Number3. */
PostOp:

/* Page 130 */
/* 'traditional' rounding */
t = length(Mantissa3) - #Digits.#Level
if t > 0 then do
/* 'traditional' rounding */
Mantissa3 = left (Mantissa3,#Digits.#Level+1) + 5
if length(Mantissa3) > #Digits.#Level+1 then
/* There was 'carry' */

Exponent3 = Exponent3 + 1

Mantissa3 = left (Mantissa3,#Digits.#Level)

Exponent3 = Exponent3 + t

end
/* "A result of zero is always expressed as a single character '0' "*/
if verify (Mantissa3,'0') = 0 then Number3 = '0'
else do

if Operator == '/' | Operator == '**' then do

/* Page 130 "For division, insignificant trailing zeros are removed
after rounding." */

/* Page 133 "... insignificant trailing zeros are removed." */
do q = length(Mantissa3) by -1 to 2
if substr(Mantissa3,q,1) \== '0' then leave
Exponent3 = Exponent3 + 1
end q
Mantissa3 = substr(Mantissa3,1,q)
end
if Floating() == 'E' then do /* Exponential format */

Exponent3 = Exponent3 + (length(Mantissa3)-1)

/* Page 136 "Engineering notation causes powers of ten to be expressed as a

multiple of 3 - the integer part may therefore range from 1 through
999." */

g=l

if #Form.#Level == 'E' then do

/* Adjustment to make exponent a multiple of 3 */
g = Exponent3//3 /* Recursively using ArithOp as
an external routine. */
if g < 0 then g =g+ 3
Exponent3 = Exponent3 - g
geaqgitl
if length(Mantissa3) < g then
Mantissa3 = left (Mantissa3,g,'0')
end /* Engineering */

/* Exact check on the exponent. */
if Exponent3 > #Limit ExponentDigits then

call #Raise 'SYNTAX', 42.1, Numberl, Operator, Number2
if -#Limit ExponentDigits > Exponent3 then

call #Raise 'SYNTAX', 42.2, Numberl, Operator, Number2

/* Insert any decimal [point. */

53
if length(Mantissa3) \= g then Mantissa3 = insert('.',Mantissa3,g)
/* Insert the E */
if Exponent3 >= 0 then Number3
else Number3
end /* Exponent format */
else do /* 'pure number' notation */
p = length(Mantissa3) + Exponent3 /* Position of the point within
Mantissa */
/* Add extra zeros needed on the left of the point. */
if p < 1 then do
Mantissa3 = copies('0',1 - p)| |Mantissa3
p=il
end
/* Add needed zeros on the right. */
if p > length(Mantissa3) then
Mantissa3 = Mantissa3||copies('0',p-length (Mantissa3) )
/* Format with decimal point. */
Number3 = Mantissa3

Mantissa3'E+'Exponent3
Mantissa3'E'Exponent3

if p < length(Number3) then Number3 = insert('.',Mantissa3,p)
else Number3 = Mantissa3
end /* pure */
if Sign3 == '-' then Number3 = '-'Number3
end /* Non-Zero */
return
/* This tests whether exponential notation is needed. */
Floating:
/* The rule in the reference has been improved upon. */
Ct = ter
if Exponent3+length(Mantissa3) > #Digits.#Level then t = 'E'
if length(Mantissa3) + Exponent3 < -5 then t = 'E'
return t
/* Add, Subtract and Compare. */

AddSubComp: /* Page 130 */
/* This routine is used for comparisons since comparison is
defined in terms of subtraction. Page 134 */
/* "Numeric comparison is affected by subtracting the two numbers (calculating

the difference) and then comparing the result with '0'." */
NowDigits = #Digits.#Level
if Operator \=='+' & Operator \== '-' then do

Comparator = Operator

/* Page 135 "The effect of NUMERIC FUZZ is to temporarily reduce the value
of NUMERIC DIGITS by the NUMERIC FUZZ value for each numeric comparison" */
NowDigits = NowDigits - #Fuzz.#Level

end
/* Page 130 "If either number is zero then the other number ... is used as
the result (with sign adjustment as appropriate). */
if Mantissa2 == '0' then do /* Result is the lst operand */
Sign3=Signl; Mantissa3 = Mantissal; Exponent3 = Exponentl
return ''
end

if Mantissal
Sign3 = Sign

== '0' then do /* Result is the 2nd operand */
2
if Operator \

; Mantissa3 = Mantissa2; Exponent3 = Exponent2
== '+' then if Sign3 = '+' then Sign3 rat
else Sign3

bat
return ''
end

/* The numbers may need to be shifted into alignment. */

/* Change to make the exponent to reflect a decimal point on the left,

so that right truncation/extension of mantissa doesn't alter exponent. */
Exponentl = Exponentl + length (Mantissal1)
Exponent2 = Exponent2 + length (Mantissa2)

/* Deduce the implied zeros on the left to provide alignment. */

54
Aligni = 0

Align2 = Exponentl - Exponent2

if Align2 > 0 then do /* Arg 1 provides a more significant digit */
Align2 = min(Align2,NowDigits+1) /* No point in shifting further. */
/* Shift to give Arg2 the same exponent as Argl */

Mantissa2 = copies('0',Align2) || Mantissa2
Exponent2 = Exponentl
end

if Align2 < 0 then do /* Arg 2 provides a more significant digit */
/* Shift to give Argl the same exponent as Arg2 */

Aligni = -Align2

Alignl = min(Align1l,NowDigits+1) /* No point in shifting further. */
Align2 = 0

Mantissal = copies('0',Alignl) || Mantissal

Exponentl = Exponent2

end

/* Maximum working digits is NowDigits+1. Footnote 41. */

SigDigits
SigDigits

max (length (Mantissal) , length (Mantissaz2) )
min (SigDigits,NowDigits+1)

/* Extend a mantissa with right zeros, if necessary. */
Mantissal = left (Mantissal,SigDigits,'0')

Mantissa2 = left (Mantissa2,SigDigits,'0')

/* The exponents are adjusted so that

the working numbers are integers, ie decimal point on the right. */

Exponent3 = Exponentl-SigDigits
Exponentl = Exponent3
Exponent2 = Exponent3
if Operator = '+' then
Mantissa3 = (Signl || Mantissal) + (Sign2 || Mantissa2)

else Mantissa3 (Signl || Mantigsal) - (Sign2 || Mantissa2)

/* Separate the sign */
if Mantissa3 < 0 then do

Sign3 = '-'
Mantissa3 = substr (Mantissa3,2)
end

else Sign3 = '+'

/* "The result is then rounded to NUMERIC DIGITS digits if necessary,
taking into account any extra (carry) digit on the left after addition,
but otherwise counting from the position corresponding to the most
significant digit of the terms being added or subtracted." */

if length(Mantissa3) > SigDigits then SigDigits = SigDigits+l
d = SigDigits - NowDigits /* Digits to drop. */
if d <= 0 then return
t = length(Mantissa3) - d /* Digits to keep. */
/* Page 130. "values of 5 through 9 are rounded up, values of 0 through 4 are
rounded down." */
if t > 0 then do
/* 'traditional' rounding */
Mantissa3 = left(Mantissa3, t +1) +5
if length(Mantissa3) > t+1 then
/* There was 'carry' */
/* Keep the extra digit unless it takes us over the limit. */
if t < NowDigits then t = t+l
else Exponent3 = Exponent3+1
Mantissa3 = left (Mantissa3,t)
Exponent3 = Exponent3 + d
end /* Rounding */
else Mantissa3 = '0'
return /* From AddSubComp */

/* Multiply operation: */

Multiply: /* p 131 */

55
/* Note the sign of the result */

if Signl == Sign2 then Sign3 = '+'
else Sign3 = '-'
/* Note the exponent */
Exponent3 = Exponentl + Exponent2
if Mantissal == '0' then do
Mantissa3 = '0'
return
end
/* Multiply the Mantissas */
Mantissa3 = ''

do q=1 to length (Mantissa2)
Mantissa3 = Mantissa3'0'
do substr(Mantissa2,q,1)
Mantissa3 = Mantissa3 + Mantissal
end
end q
return /* From Multiply */

/* Types of Division: */

DivType: /* p 131 */
/* Check for divide-by-zero */

if Mantissa2 == '0' then call #Raise 'SYNTAX',

/* Note the exponent of the result */
Exponent3 = Exponentl - Exponent2

/* Compute (one less than) how many digits will be in the integer

part of the result. */

IntDigits = length(Mantissal) - Length(Mantissa2) + Exponent3
/* In some cases, the result is known to be zero.
if Mantigsal = 0 | (IntDigits < 0 & Operator

Mantissa3 = 0
Sign3 = '+'
Exponent3 = 0
return
end
/* In some cases, the result is known to be to be the first argument.
if IntDigits < 0 & Operator == '//' then do
Mantissa3 = Mantissal
Sign3 = Signl
Exponent3 = Exponentl
return
end
/* Note the sign of the result. */
if Signl == Sign2 then Sign3 = '+'
else Sign3 = '-'

/* Make Mantissal at least as large as Mantissa2 so Mantissa2 can be
subtracted without causing leading zero to result. Page 131 */

az 0
do while Mantissa2 > Mantissal

Mantissal = Mantissal'0'
Exponent3 = Exponent3 - 1
aztadtl
end
/* Traditional divide */
Mantissa3 = ''

/* Subtract from part of Mantissal that has length of Mantissa2 */

left (Mantissal,length(Mantissa2) )
substr (Mantissal, length (Mantissa2)+1)
o forever

x
Y
d

/* Develop a single digit in z by repeated subtraction.

ze=O0
do forever
xX = kK - Mantissa2
if left(x,1) == '-' then leave
Zeze¢t+tl
end

x = x + Mantissa2 /* Recover from over-subtraction */
/* The digit becomes part of the result */

Mantissa3 = Mantissa3 || z

if Mantissa3 == '0' then Mantissa3 = '' /* A single leading

56

42.3

*f
'%') then do

*/
zero can happen. */
/* x||y is the current residue */
if y == '' then if x = 0 then leave /* Remainder is zero */

if length(Mantissa3) > #Digits.#Level then leave /* Enough digits
in the result */

/* Check type of division */
if Operator \== '/' then do
if IntDigits = 0 then leave
IntDigits = IntDigits - 1
end
/* Prepare for next digit */
/* Digits come from y, until that is exhausted. */
/* When y is exhausted an extra zero is added to Mantissal */
if y == '' then do
y = ror
Exponent3 = Exponent3 - 1
aztadtl
end
xX = xX | | left (y,1)
y = substr(y,2)
end /* Iterate for next digit. */

Remainder = x || y
Exponent3 = Exponent3 + length(y) /* The loop may have been left early.
/* Leading zeros are taken off the Remainder. */
do while length(Remainder) > 1 & Left (Remainder,1) == '0'
Remainder = substr (Remainder, 2)
end
if Operator \== '/' then do
/* Check whether % would fail, even if operation is // */

if Floating() 'E' then do
if Operator '%' then MsgNum
else MsgNum

/* Page 133. % could fail by needing exponential notation */

26.11
26.12

call #Raise 'SYNTAX', MsgNum, Numberl , Number2, #Digits.#Level

end
end
if Operator == '//' then do
/* We need the remainder */
Sign3 = Signl

Mantissa3 = Remainder
Exponent3 = Exponentl - a
end

return /* From DivType */

/* The Power operation: */

Power: /* page 132 */
/* The second argument should be an integer */
if \WholeNumber2() then call #Raise 'SYNTAX', 26.8, Number2
/* Lhs to power zero is always 1 */
if Mantissa2 == '0' then do
Sign3 = '+'
Mantissa3
Exponent3
return
end

i
ror

/* Pages 132-133 The Power algorithm */
Rhs = left (Mantissa2,length(Mantissa2)+Exponent2,'0')/* Explicit
integer form */
L length (Rhs)
b X2B(D2X(Rhs)) /* Makes Rhs in binary notation */
/* Ignore initial zeros */
do q=l1byl
if substr(b,q,1) \== '0' then leave
end q
ael
do forever
/* Page 133 "Using a precision of DIGITS+L+1" */
if substr(b,q,1) == '1' then do
a = Recursion('*',Signl || Mantissal'E'Exponent1)

57

*/
if left(a,2) == 'MN' then signal PowerFailed
end

/* Check for finished */

if q = length(b) then leave

/* Square a */

a = Recursion('*',a)
if left(a,2) == 'MN' then signal PowerFailed
q=qrtil
end
/* Divide into one for negative power */
if Sign2 == '-' then do
Sign2 = '+'
a = Recursion('/')
if left(a,2) == 'MN' then signal PowerFailed
end

/* Split the value up so that PostOp can put it together with rounding */
Parse value Prepare(a,#Digits.#Level+L+1) with Sign3 Mantissa3 Exponent3
return

PowerFailed:
/* Distinquish overflow and underflow */
ReWas = substr(a,4)
if Sign2 = '-' then if ReWas == '42.1' then RcWas
else RcWas
call #Raise 'SYNTAX', RcWas, Numberl, '**', Number2
/* No return */

"42.2!
"42.1!

WholeNumber2:
numeric digits Digits
if #Form.#Level == 'S' then numeric form scientific

else numeric form engineering
return datatype (Number2, 'W')

Recursion: /* Called only from '**! */
numeric digits #Digits.#Level + L + 1
signal on syntax name Overflowed
/* Uses ArithOp again under new numeric settings. */
if arg(1) == '/' then return 1l/a
else return a * arg(2)
Over flowed:
return 'MN '.MN

7.5 Functions

7.5.1 Invocation

Invocation occurs when a function or a message_term or a callis evaluated. Invocation of a function
may result in a value, in which case:

if #Tracing.#Level == 'I' then call #Trace '>F>'
Invocation of a message_term may result in a value, in which case:
if #Tracing.#Level == 'I' then call #Trace '>M>'

7.5.2 Evaluation of arguments

The argument positions are the positions in the exoression_list where syntactically an expression occurs
or could have occurred. Let ArgNumber be the number of an argument position, counting from 1 at the
left; the range of ArgNumber is all whole numbers greater than zero.

For each value of ArgNumber, #ArgExists.#NewLevel.ArgNumber is set '1' if there is an expression
present, 'O' if not.

From the left, if #ArgExists.#NewLevel.ArgNumber is '1' then #Arg.#NewLevel.ArgNumber is set to the
value of the corresponding expression. If #ArgExists.#NewLevel.ArgNumber is '0' then
#Arg.#NewLevel.ArgNumber is set to the null string.

#ArgExists.#NewLevel.0 is set to the largest ArgNumber for which #ArgExists.#NewLevel.ArgNumber is
'1', or to zero if there is no such value of ArgNumber.

7.5.3. The value of a label

The value of a LABEL, or of the taken_constant in the function or call_instruction, is taken as a constant,
see nnn. If the taken_constant is not a string_literal it is a reference to the first LABEL in the program
which has the same value. The comparison is made with the '==' operator.

If there is such a matching label and the label is trace-only (see nnn) then a condition is raised:
call #Raise 'SYNTAX', 16.3, taken constant

58
If there is such a matching label, and the label is not trace-only, execution continues at the label with
routine initialization (see nnn). This is execution of an internal routine.

If there is no such matching label, or if the taken_constant is a string_literal, further comparisons are
made.

If the value of the taken_constant matches the name of some built-in function then that built-in function is
invoked. The names of the built-in functions are defined in section nnn and are in uppercase.

If the value does not match any built-in function name, Config_ExternalRoutine is used to invoke an
external routine.

Whenever a matching label is found, the variables SIGL and .SIGL are assigned the value of the line
number of the clause which caused the search for the label. In the case of an invocation resulting from a

condition occurring that shall be the clause in which the condition occurred.
Var _ Set(#Pool, 'SIGL', '0', #LineNumber)
var Set(0 , '.SIGL', '0', #LineNumber)

The name used in the invocation is held in #Name.#Level for possible use in an error message from the
RETURN clause, see nnn

7.5.4 The value of a function

A built-in function completes when it returns from the activity defined in section nnn. The value of a
built-in function is defined in section nnn.

An internal routine completes when #Level returns to the value it had when the routine was invoked. The
value of the internal function is the value of the expression on the return which completed the routine.
The value of an external function is determined by Config_ExternalRoutine.

7.5.5 The value of a method

A built-in method completes when it returns from the activity defined in section n. The value of a built-in
method is defined in section n.

An internal method completes when #Level returns to the value it had when the routine was invoked. The
value of the internal method is the value of the expression on the return which completed the method.
The value of an external method is determined by Config_ExternalMethod.

7.5.6 The value of a message term

See nnn for the syntax of a message_term. The value of the ferm within a message_term is called the
receiver.

The receiver and any arguments of the term are evaluated, in left to right order.
r= #evaluate(message term, term)
If the message term contains '~~' the value of the message term is the receiver.
Any effect on .Result?
Otherwise the value of a message_term is the value of the method it invokes. The method invoked is
determined by the receiver and the taken_constant and symbol.
t = #Instance(message term, taken constant)
If there is a symbol, it is subject to a constraints.
if #contains (message term, symbol) then do
if r <> #Self then

call #Raise 'SYNTAX', nn.n

/* OOI: "Message search overrides can only be used from methods of the target
object." */

The search will progress from the object to its class and superclasses.
/* This is going to be circular because it describes the message lookup
algorithm and also uses messages. However for the messages in this code
the message names are chosen to be unique to a method so there is no need
to use this algorithm in deciding which method is intended. */

/* message term ::= receiver '~' taken constant ':' VAR_SYMBOL arguments */

/* This code reflects OOI - the arguments on the message don't affect
the method choice. */

/* This code selects a method based on its arguments, receiver,
taken_constant, and symbol. */

/* This code is used in a context where #Self is the receiver of the
method invocation which the subject message term is running under. */

59
SelectMethod:

/* If symbol given, receiver must be self. */
if arg(3,'E') then if arg(1)\==#Self then signal error /* syntax number? */

t arg(2) /* Will have been uppercased, unless a literal. */

x arg(1) /* Cursor through places to look for the method. */

Mixing 1 /* Off for potential mixins ignored because symbol given. */
Mixins -array~new /* to note any Mixins involved. */

/* Look in the method table of the object, if no 'symbol' given. */
if arg(3,'E') then do
Mixing = 0

end
else do
m = x~#MethodTable[t]
if m \== .nil then return m
end

do until x==.object
/* Follow the class hierarchy. */
x = x-class
/* Note any mixins for later reference. */
Mix = x~Inherited /* An array, ordered as the directive left-to-right. */

if Mix \== .nil then /* Append to the record. */
do j=1 to Mix~dimension (1)
Mixins [Mixins~dimension(1)+1] = Mix[j]
end

if Mixing do
/* Consider mixins only for superclasses of 'symbol'. */
do j=1 to Mixins~dimension (1)
/* Look at the baseclass of each. */
/* That is closest superclass not a mixin. */
s = Mixins[j]~class
do while s~Mixin /* Assert stop at .object if not before. */
s=s~class
end
if s==x then do
m=Mixins [j]~#MethodTable[t]
if m \== .nil then return m
end
end j
end /* Mixing */
if arg(3,'E') then if arg(3)==x then do
Mixing=1
end
if Mixing do
/* Consider non-Mixins */
m= x-#InstanceMethodTable[t]

if m \== .nil then return m
end

x=x~superclass

end

/* Try for UNKNOWN instead */
if t == 'UNKNOWN' then return .nil
if \arg(3,'E') then return SelectMethod arg(1),'UNKNOWN'
else return SelectMethod arg(1),'UNKNOWN',arg(3)

7.1.1 Use of Config_ExternalRoutine

The values of the arguments to the use of Config_ExternalRoutine, in order, are:

The argument How is 'SUBROUTINE' if the invocation is from a call, '"FUNCTION' if the invocation is from
a function.

The argument NameType is '1' if the taken_constant is a string_literal, '0' otherwise.

The argument Name is the value of the faken_constant.

The argument Environment is the value of this argument on the API_ Start which started this execution.
The argument Arguments is the #Arg. and #ArgExists. data.

60
The argument Streams is the value of this argument on the API_Start which started this execution.

The argument Traps is the value of this argument on the API_Start which started this execution.
Var_Reset is invoked and #API_Enabled set to '1' before use of Config_ExternalRoutine. #API_Enabled
is set to 'O' after.

The response from Config_ExternalRoutine is processed. If no conditions are (implicitly) raised,
#Outcome is the value of the function.

61
