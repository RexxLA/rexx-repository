Names
=====

Procedures, functions, routines, methods, classes, resources, labels, and other Rexx constructs
have one or more _names_. A name is usually either a symbol or a string (but see note 1 below). 
When a name is a symbol, that symbol is first uppercased and then it is taken _literally_, that is, 
it is not substituted by its value when the symbol has the form of a variable or of an environment symbol
(see also note 2). 
When a symbol is taken literally, we may also say that it is _taken as a constant_. 

Notes
-----

1. In some syntactical contexts, a name cannot be a string, but only a symbol (for example, in the `LABEL` clause
   in `DO`, `LOOP` and `SELECT` instructions). Likewise, names which are strings are taken as-is in some cases
   (for example when they are labels), and uppercased in some other cases (class, method or routine names).
   Please refer to the respective chapters for the specific details about a
   particular Rexx construct.

3. In some infrequent cases, an environment symbol may be associated with a _method_ instead of 
   a value (for example, by using the `setmethod` method on the local or the global environment directories).
   When a symbol is used as a name, as it is taken literally, the associated method is not called.

Examples
--------

```rexx
Label:                  -- The Label "LABEL"
"label":                -- The label "label" (different from "LABEL")
12.00E1:                -- The label "12.00E1"
Loop Label Wendy        -- "Label 'Wendy'" would produce a syntax error
  Leave WENDY           -- Value gets uppercased
End

Call .True              -- Calls ".TRUE", not "1"
.environment~setMethod("m", "Say 'Hi'")
::Routine .M            -- The name is always ".M"
```
