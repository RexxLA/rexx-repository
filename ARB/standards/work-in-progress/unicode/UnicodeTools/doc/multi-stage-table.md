## The MultiStageTable class

This class, defined in the ``/components/utilities/MultiStageTable.cls`` package, specializes in producing two-stage tables, three-stage tables, or, in general multi-stage tables.

Multi-stage tables are recommended in [_The Unicode Standard 15.0_](https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf), section 5.1, 
_Data Structures for Character Conversion_, "Multistage Tables", pp. 196–7.

This is not a general implementation of multi-stage tables, but a custom, tailored one, specific to Unicode and the BMP and SMP planes.

The indexes for these tables run from 0 to 131071 (2**17-1). Negative values will raise a syntax error, and indexes greater than 131071 will return "00"X.

### compress (Class method)

```
   ╭───────────╮  ┌────────┐  ╭───╮
▸▸─┤ compress( ├──┤ buffer ├──┤ ) ├─▸◂
   ╰───────────╯  └────────┘  ╰───╯
```

The _compress_ method compresses a _buffer_ and returns two smaller, compressed, tables.

_Buffer_ is a 128K-byte string (131072 bytes) representing an array of 1-byte elements. 
Elements 1-65536 correspond to the Unicode Basic Multilingual Plane (BMP), and elements 65537-131072 correspond to the Unicode Supplementary Multilingual Plane (SMP).

The compression technique works as follows: the source array-string is supposed to be compressible, i.e., is supposed to contain different segments which are identical. 
The array will be broken in a series of fixed-size sub-arrays, and, instead of storing the sub-array itself, we will store a reference to the sub-array. 
Thus, when two identical sub-arrays (segments) of the argument array are found, only the first copy is stored, and a repeated reference. 
But a reference is supposed to be much smaller than the subarray itself.

The current implementation uses several hardcoded constants. This can be changed in the future:

* The argument _buffer_ is supposed have a length of exactly 2**17 bytes.
* Sub-arrays will be of 256 bytes.
* To allow for maximum compression, we are supposing that the quantity of different sub-arrays does not exceed 256. This allows to store the references to the sub-arrays in a single byte.

### []

```
   ╭───╮  ┌───┐  ╭───╮
▸▸─┤ [ ├──┤ n ├──┤ ] ├─▸◂
   ╰───╯  └───┘  ╰───╯
```

Returns the _n_-th element of the multi-stage table, when 0 < _n_ <= 131071, or a string containing width copies of ``"00"X``, when _n_ > 131071. Negative or non-numeric values of _n_ will raise a Syntax error.

### new

```
   ╭──────╮  ┌────────┐  ╭───╮  ┌────────┐  ╭───╮                                        ╭───╮
▸▸─┤ new( ├──┤ offset ├──┤ , ├──┤ chunks ├──┤ , ├─┬───────────┬─┬──────────────────────┬─┤ ) ├─▸◂
   ╰──────╯  └────────┘  ╰───╯  └────────┘  ╰───╯ │ ┌───────┐ │ │ ╭───╮ ┌────────────┐ │ ╰───╯
                                                  └─┤ width ├─┘ └─┤ , ├─┤ big_values ├─┘
                                                    └───────┘     ╰───╯ └────────────┘
```

Creates a new multi-stage table. The _offset_ and _chunks_ tables should have been created by the _compress_ class method. _Width_ and _big_values_ are optional. 
When specified, _width_ should be a positive number greater than 1, and _big_values_ should be a string of _width_-byte values. 
In that case, the 1-byte value obtained from _offset_ and _chunks_ is multiplied by _width_ and used as an index into _big_values_.
