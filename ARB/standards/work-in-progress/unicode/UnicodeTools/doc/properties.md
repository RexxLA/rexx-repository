# The Unicode properties

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
``` 

The Unicode.Property class (``properties.cls``) and its subclasses are located in the ``components/properties`` subdirectory. Unicode.Property makes use of two auxiliary classes, MultiStageTable and PersistentStringTable, described below.

Classes implementing concrete Unicode properties should subclass Unicode.Property. It offers a set of common services, including the            
generation and loading of compressed two-stage tables to store property values.                                                         

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
