# The 'bin/build' subdirectory

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
``` 

This subdirectory contains a set of utility programs that generate the binary files
needed by The Unicode Tools Of Rexx. These binary files are stored in the parent
directory, 'bin'.

The special utility 'all.rex' calls all utility programs in turn, and is useful
to completely regenerate the whole set of binary files.
