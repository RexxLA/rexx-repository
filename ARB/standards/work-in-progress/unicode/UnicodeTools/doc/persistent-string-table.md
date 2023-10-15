# The PersistentStringTable class

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
