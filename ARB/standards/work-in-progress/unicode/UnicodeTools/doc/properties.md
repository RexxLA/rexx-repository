# The Unicode properties

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
``` 

This directory contains the main Unicode.Property class, located in the ``Properties.cls`` package, and the individual property files.

The Unicode.Property class makes use of two auxiliary classes, MultiStageTable and PersistentStringTable, described below.

Classes implementing concrete Unicode properties should subclass    
Unicode.Property. It offers a set of common services, including the            
generation and loading of compressed two-stage tables to store           
property values.                                                         

## The MultiStageTable class (internal documentation)

This class specializes in producing two-stage tables, three-stage tables, or, in general multi-stage tables.

Multi-stage tables are recommended in The Unicode Standard 15.0 (https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf), section 5.1, 
_Data Structures for Character Conversion_, "Multistage Tables", pp. 196–7.

This is not a general implementation of multi-stage tables, but a custom, tailored one, specific to Unicode and the BMP and SMP planes.

The indexes for these tables run from 0 to 131071 (2**17-1). Negative values will raise a syntax error, and indexes greater than 131071 will return "00"X.

### []

```
   ╭───╮  ┌───┐  ╭───╮
▸▸─┤ [ ├──┤ n ├──┤ ] ├─▸◂
   ╰───╯  └───┘  ╰───╯
```

Returns the _n_-th element of the multi-stage table, when 0 < _n_ <= 131071, or a string containing width copies of ``"00"X``, when _n_ > 131071. Negative or non-numeric values of _n_ will raise a Syntax error.

### compress

```
   ╭───────────╮  ┌────────┐  ╭───╮
▸▸─┤ compress( ├──┤ buffer ├──┤ ) ├─▸◂
   ╰───────────╯  └────────┘  ╰───╯
```

The _compress_ method compresses a _buffer_ and returns two smaller, compressed, tables.

_Buffer_ is a 128K-byte string (131072 bytes) representing an array of 1-byte elements. Elements 1-65536 correspond to the Unicode Basic Multilingual Plane (BMP), and elements 65537-131072 correspond to the Unicode Supplementary Multilingual Plane (SMP).

The compression technique works as follows: the source array-string is supposed to be compressible, i.e., is supposed to contain different segments which are identical. 
The array will be broken in a series of fixed-size sub-arrays, and, instead of storing the sub-array itself, we will store a reference to the sub-array. 
Thus, when two identical sub-arrays (segments) of the argument array are found, only the first copy is stored, and a repeated reference. 
But a reference is supposed to be much smaller than the subarray itself.

The current implementation uses several hardcoded constants. This can be changed in the future:

* The argument _buffer_ is supposed have a length of exactly 2**17 bytes.
* Sub-arrays will be of 256 bytes.
* To allow for maximum compression, we are supposing that the quantity of different sub-arrays does not exceed 256. This allows to store the references to the sub-arrays in a single byte.

### new

```
   ╭──────╮  ┌────────┐  ╭───╮  ┌────────┐  ╭───╮                                        ╭───╮
▸▸─┤ new( ├──┤ offset ├──┤ , ├──┤ chunks ├──┤ , ├─┬───────────┬─┬──────────────────────┬─┤ ) ├─▸◂
   ╰──────╯  └────────┘  ╰───╯  └────────┘  ╰───╯ │ ┌───────┐ │ │ ╭───╮ ┌────────────┐ │ ╰───╯
                                                  └─┤ width ├─┘ └─┤ , ├─┤ big_values ├─┘
                                                    └───────┘     ╰───╯ └────────────┘
```

Creates a new multi-stage table. The _offset_ and _chunks_ tables should have been created by the _compress_ class method. _Width_ and _big_values_ are optional. When specified, _width_ should be a positive number greater than 1, and _big_values_ should be a string of _width_-byte values. In that case, the 1-byte value obtained from _offset_ and _chunks_ is multiplied by _width_ and used as an index into _big_values_.

## PersistentStringTable (internal documentation)

PersistentStringTable is a subclass of StringTable that can be quickly saved and restored to a file.

The present implementation has the following limitations:

* Keys must all be < 256 characters in length.
* Values must all be strings, or have a string value and be apt to be saved as strins.
* The total size of the resulting file (that is, keys + values + overhead) must not exceed 2**32 bytes.
  
Format of the binary file:

```
              0         1         2         3         4
              ┌─────────┬─────────┬─────────┬─────────┐
   0          │       number of items (32 bits)       │   4
              ├─────────┼─────────┼─────────┼─────────┤
   4          │  len1   │  5                              len1 = Len(key1)
              ├─────────┼─────────┼         ┼─────────┤
   5          │  key1 . . . . . . . . /// . . . . . . │   5 + len1
              ├─────────┼─────────┼─────────┼─────────┤
   5 + len1   │      offset of value 1 (32 bits)      │   5 + len1 + 4  ─────────────────┐       
              ├─────────┼─────────┼─────────┼─────────┤                                  │
   9 + len1   │      length of value 1 (32 bits)      │   5 + len1 + 4 + 4               │
              ├─────────┼─────────┼─────────┼─────────┤                                  │ This points here 
  13 + len1      (structure repeats for key2..keyn)                                      │
              ├─────────┼─────────┼         ┼─────────┤                                  │
   offset1    │  value1 . . . . . . . /// . . . . . . │   offset1 + Len(val1)  <─────────┘           
              ├─────────┼─────────┼         ┼─────────┤

              (structure is repeated for value2..valuen)
```

## The Properties class (internal documentation)

TBD
