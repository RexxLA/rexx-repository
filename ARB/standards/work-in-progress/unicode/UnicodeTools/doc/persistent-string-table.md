# The PersistentStringTable class

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
``` 

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

## load

![Diagram for the PersistentStringTable load method](img/PersistentStringTable_load.svg)

Loads the PersistentStringTable contents from the _source_ file.

## save

![Diagram for the PersistentStringTable save method](img/PersistentStringTable_save.svg)

Saves the PersistentStringTable contents to the _target_ file. Checks are made to ensure that

* All items in the PersistentStringTable are Rexx Strings.
* All indexes have a length of 255 characters or less.
* The total size of the saved PersistentStringTable is less than 2<sup>32</sup>-1.
