# The Unicode properties

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
``` 

The Unicode.Property class (``properties.cls``) and its subclasses are located in the ``components/properties`` subdirectory. 
Unicode.Property makes use of two auxiliary classes, [MultiStageTable](multi-stage-table.md), and [PersistentStringTable](persistent-string-table.md).

Classes implementing concrete Unicode properties should subclass Unicode.Property. It offers a set of common services, including the            
generation and loading of compressed two-stage tables to store property values.               

Documented subclasses are:

* [Unicode.Normalization](properties/Unicode.Normalization.md).

## The Properties class

TBD
