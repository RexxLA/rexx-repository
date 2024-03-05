# Rexx standard math library

## Goals

The goal is to specify a standard Rexx math library which is compatible over the variants and their implementations. The set of targets is ooRexx, NetRexx, Regina, cRexx.

- Variable precision is needed.
- Consistent and high performance is needed.

## What is there already

### Patrick McPhee Rexx Math Bumper Pack

|Function                 | Call. Seq.   | Alias(es) |       Requires    |
|=========================|==============|===========|===================|
|Absolute value           | abs(x)       |  fabs     | |
|Inverse cosine           | acos(x)      |            |   -1.0 <= x <= 1.0|
|Inverse hyperbolic cos   | acosh(x)     |             |     x >= 1.0|
|Inverse sine             | asin(x)      |             |  -1.0 <= x <= 1.0|
|Inverse hyperbolic sin   | asinh(x)     | ||
|Inverse tangent          | atan(x)      ||
|Inverse hyp. tangent     | atanh(x)     | |              -1.0 < x < 1.0|
|Inv. tangent y/x         | atan(y,x)    |  |             y != 0.0, x != 0.0|
|Lowest integer above x   | ceil(x)      |||
|Cosine                   | cos(x)       |||
|Hyperbolic cosine        | cosh(x)      |||
|Cotangent                | cot(x)       | cotan|
|ICotangent               | cotan(x)     | cot|
|Cosecans                 | csc(x)       |||
|e to the power x         | exp(x)       |||
|Absolute value           | fabs(x)      | abs||
|Factorial                | fact(x)      |      |        x >= 0, x < 171|
|Highest integer below x  | floor(x)     | int|
|Highest integer below x  | int(x)       | floor|
|Log base e               | ln(x)        | log   |       x > 0.0|
|Log base e               | log(x)       | ln     |      x > 0.0|
|Log base 10              | log10(x)     |               x > 0.0|
|Nearest integer to x     | nint(x)      ||
|x to the power y         | pow(x,y)     |  power, xtoy | x >= 0.0|
|x to the power y         | power(x,y)   |  pow, xtoy |   x >= 0.0|
|Secans                   | sec(x)       |||
|Sine                     | sin(x)       |||
|Hyperbolic sine          | sinh(x)      |||
|Square root              | sqrt(x)      |  |             x >= 0.0|
|Tangent                  | tan(x)       |||
|Hyperbolic tangent       | tanh(x)      |||
|x to the power y         | xtoy(x,y)    | pow, power |  x >= 0.0|


### The ooRexx RxMath library

This is a set of functions that fail when numeric digits is > 16.

### The Zabrodski set of math functions

In these functions the number of digits needs to be specified on a function call basis. The package is available in ooRexx distributions and as a standalone package. It contains hardcoded versions of Pi and E with specific precision.

### Calling JVM functions from NetRexx and BSF4ooRexx

### Calling numpy from Rexx

- needs to be investigated

### Rosettacode algorithms

Rosettacode contains some implementations, some good, some less so; with wildly varying performance also.

## Suggested functions


