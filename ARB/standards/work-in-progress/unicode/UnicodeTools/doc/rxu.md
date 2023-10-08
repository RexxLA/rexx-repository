# The RXU Rexx Preprocessor for Unicode

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
``` 

## Description

The __RXU Rexx Preprocessor for Unicode__ is implemented by a set of Rexx programs. The most visible one is a new command called ``rxu.rex``. 

__RXU__ reads a ``.rxu`` program and attempts to translate it to standard ``.rex`` code (RXU needs the Unicode library, ``Unicode.cls``, and will automatically use it). 
If no errors are found in the translation pass, the resulting ``.rex`` program is then executed, after which it is deleted. 
RXU programs can be written using an extended Rexx syntax that implements a set of Unicode and non-Unicode literals, several new BIFs and BIMs, 
and a system of polymorphic BIFs that allow the programmer to continue using the same concepts and BIFs that in Classic Rexx, 
and at the same time take advantage of the power and novelties of the Unicode world.

## The RXU command

``RXU filename`` converts a file named ``filename.ext`` (default extension: ``.rxu``) into a ``.rex`` file, and then interprets this ``.rex`` file. By default, the
``.rex`` file is deleted at the end of the process-

### Format:                                                                  

```                                                                           
[rexx] rxu [options] filename [arguments]                              
```

__Options:__

```
    -help, -h  : display help for the RXU command                          
    -keep, -k  : do not delete the generated .rex file                     
    -nokeep    : delete the generated .rex file (the default)              
    -warnbif   : warn when using not-yet-migrated to Unicode BIFs
    -nowarnbif : don't warn when using not-yet-migrated to Unicode BIFs (the default)
```

## What we do and what we don't do

RXU is a work-in-progress, not a finished product. Some parts of Rexx have been made to appear as "Unicode-ready", and some others have not. This can produce all kind of unexpected results. Use at your own risk!

The major focus of the translator is to implement Unicode-aware Classic Rexx: in this sense, priority is given, for example, 
to the implementation of Built-in Functions (BIFs) over Built-in Methods (BIMs). 
For instance, currently you will find a Unicode-aware implementation of several stream i/o BIFs, but no reimplementation of the Stream I/O classes.

## Here is a list of what is currently implemented

### [Four new types of string](string-types.md)

### [Revised built-in functions](built-in.md)

* [Stream functions for Unicode](stream.md)
* [The encoding/decoding model](encodings.md)

### [New built-in functions](new-functions.md)

* [The properties model](properties.md)

### [New classes](classes.md)

### [New values for the OPTIONS instruction](options.md)
