# A toy ooRexx implementation of the General_Category Unicode property (20230711)

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023, 2024 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                     │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

I have written a toy, pure ooRexx, implementation of the General_Category Unicode property.

General_Category (abbr: gc) can be found as the third column of UnicodeData.txt 
(see https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt). 
It maps codepoints to an enumeration (see https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, section 4.5, "General Category", on p. 172 for details).

Here is the list of possible values for gc:

* Lu = Letter, uppercase
* Ll = Letter, lowercase
* Lt = Letter, titlecase
* m = Letter, modifier
* Lo = Letter, other
* Mn = Mark, nonspacing
* Mc = Mark, spacing combining
* Me = Mark, enclosing
* Nd = Number, decimal digit
* Nl = Number, letter
* No = Number, other
* Pc = Punctuation, connector
* Pd = Punctuation, dash
* Ps = Punctuation, open
* Pe = Punctuation, close
* Pi = Punctuation, initial quote (may behave like Ps or Pe depending on usage)
* Pf = Punctuation, final quote (may behave like Ps or Pe depending on usage)
* Po = Punctuation, other
* Sm = Symbol, math
* Sc = Symbol, currency
* Sk = Symbol, modifier
* So = Symbol, other
* Zs = Separator, space
* Zl = Separator, line
* Zp = Separator, paragraph
* Cc = Other, control
* Cf = Other, format
* Cs = Other, surrogate
* Co = Other, private use
* Cn = Other, not assigned (including noncharacters)

Unicode implementations make ample use of this (and of course also of many other) properties. 
For example, the Go language defines a boolean function called "isLetter" that returns true when gc is L* (that is, Lu, Ll, Lt, Lm or Lo).

The class file needs to scan the included file UnicodeData.15.0.0.txt and builds a two-stage table, which is then stored in a binary file and reused on subsequent runs.

The main public routine is called, unsurprisingly, "GC". As an added bonus, I've added an "Algorithmic_name_start" routine that returns 
the start of a codepoint name when that name is algorithmically computable (in other cases, it returns the null string). See the source comments for details.

You will also find a self-test. On my desktop machine, a quite aged i7-9700 @ 3MHz, it checks about 0.5M codepoints/second.

I call this program a toy implementation because I've not spent much time to make a very robust implementation. For example, I am not looking for I/O errors. I've preferred to focus on functionality. 

My intention is to produce, given time, a whole set of toy implementations. 
This will allow us to play with the concepts in practice, to do it in ooRexx, and to produce very quick prototypes, proof-of-concepts, et cetera.

You can download the program and the accompanying files from https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeToys.
