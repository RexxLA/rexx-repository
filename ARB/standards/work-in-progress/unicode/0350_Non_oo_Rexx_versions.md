# Non object-oriented Rexx versions

## ARB recommendations

(TBD)

## Draft Notes

### Introduction

In most of our discussions, we are centered on object-oriented versions of Rexx, namely, on ooRexx, or on Jean-Louis Faucher's Executor. This is fine, but we shouldn't forget about the non-oo versions, like Regina, BRexx, etc. We should produce a
set of recommendations that are implementable in a non-oo version of Rexx, _and_ also in ooRexx and Executor.

As discussed in the *[Preliminary questions](0150_Preliminary_questions.md)* section, there are two radically different approaches to the Unicode problem. One we can call the "optional" approach, and the other the "first-class Unicode" approach. 

In the "optional" approach, Unicode support would be optional. It would be activated by an OPTIONS instruction. Once activated, a new set of BIFs would be available to manage Unicode values.

In the "first-class Unicode" approach, the Rexx language would experiment a profound, radical change. Strings would be, by default, Unicode strings. This would represent a big compatibility problem; some of the issues are addressed in the *[Backward Compatibility](0300_Backward_compatibility.md)* section. Old-style, byte-oriented strings would still be usable, probably by specifying a new, incompatible, string suffix. Interpreters should implement a compatibility mode, where
strings would still be byte-oriented by default, to make it possible to run old programs.

### What the consideration of non-object oriented interpreters shows us about compatibility

* New BIFs will always be disruptive. They are searched after internal routines, and before external routines: when a new BIF is introduced, some programs will inevitably break. (That's most probably the reason why the new .String BIMs of ooRexx do not have counterparts as new BIFs, even if Mike had stated that it would be nice if both sets were as similar as feasible). If we had to add Unicode only to object-oriented versions of ooRexx, we could avoid the problem, because only new BIMs would be needed (especially, for the new classes).

* If one wants new literals (for example, "string"T for Unicode strings, or "string"C for compatibility/classic strings), we also encounter a compatibility problem: "string"T would be interpreted as "string"||T in old programs, and as a Unicode literal in new programs. This problem also applies to object oriented versions of Rexx.

* Another possibility would be to use a different and unused delimiter, for example, a backtick ("`"). Then `string` would be Unicode, and "string" or 'string" would be byte-strings.

### A possible way to minimize name pollution when using new BIFs

Define some few heavily overloaded BIFs (for example, "CODEPOINT", or "UNICODE"), _a la_ STREAM, or ARG. For example, instead of defining ``ISLOWER(codepoint)``, use ``CODEPOINT(codepoint,"Query","Letter")``, and so on: instead of 12 or so IsXXX functions, like in Go, we will have only an overloading of CODEPOINT, a function that we need to have anyway, for other purposes.

Please note that many of these calls can be detected and optimized at parse time, if so desired.

### The "optional" approach (a brainstorm proposal) (jmb)

Let's see how the "optional" approach could work in a non-oo interpreter as, for example, Regina Rexx. Unicode would be loaded by an OPTIONS instruction. 

    OPTIONS UNICODE -- Or OPTIONS TEXT, etc. This is not a name proposal
    
This loading would be undoable (i.e., you wouldn't be able to unload Unicode once loaded). Implementations may choose to implement Unicode as a separate library.

* Unicode support would offer several new BIFs. Let's call the main one **TEXT** (again, this is not a name proposal). TEXT(string) would return _a Unicode string_ (to be defined shortly). With a little help from the interpreter, static, parse-time analysis, would be able to determine if calls to TEXT were indeed to be resolved to the new BIF, and then calls with a literal argument could be treated as **literal Unicode strings** and optimized as such.

* Of course new string literals could also be introduced, for example in the form **"string"T**. This is more Rexx-like and has a lower astonishment factor, but it creates a new incompatibility (although the new BIFs create a still bigger incompatibility).

* A third possibility would be to innovate syntactivally, and create constructs like .TEXT["string"] and so on. In ooRexx this would be a class method, in non-oo rexxes, a syntactical novelty. It has the advantage of not introducing any incompatibility, but it's not very pleasant, aesthetically.

* The **result** from a call to TEXT would be the very same string received as an argument (or a copy of the string if the original had active references to it), but with an implementarion-defined, internal, flag that would indicate that the string was, indeed, an **Unicode string**.

* Please note that this is the description given to the user, not necessarily what would be used as the **internal representation**. An implementation should be free to keep the original string, recode it into UTF-16, -32 or -8, or use some other means of storage.

* The **encoding** to use would be the same as the one used in the program file. An explicit encoding could also be specified using an OPTIONS instruction.
  ```
  OPTIONS UNICODE ENCODING(ISO-8859-1) -- Applies to the whole file
  ```
* **Explicit encodings**. An optional, second argument to TEXT could make the encoding explicit:
  ```
  TEXT("string", "UTF-8") -- Applies only to this bytes to text conversion
  ```
* If any encoding errors were found, a **new condition** would be raised. An optional third parameter could be specified to allow special handling of encoding errors, e.g.,
  ```
  TEXT("string", "UTF-8", "handling")
  ```
  Question: what do we do with the "bad" codes? Substitute them, keep them as-is? This needs more work (see what other languages do).

* Another possibility is to return the null string when an encoding error occurs. Then the user could be able to ask for the details using a BIF. The fact that there was or not an encoding error would be stored as part of the string status, and would be accesible using a specialized BIF.

* The interpreter would provide an adapted set of **BIFs** for Unicode strings. They would work similarly to the standard BIFs, but at the _grapheme cluster_ level.
  ```
  Options Unicode Encoding(UTF-8)
  string = "René"
  text = Text(string)
  Say Length(string)   -- 5
  Say Length(text)     -- 4
  ```
* **Arithmetic** operators would work as usual, with ASCII numbers, and the "e", "E", ".", "+" and "-" characters, regardless of whether they are part of an Unicode or a byte string.

* **Concatenation** would follow a protocol similar to the one used by Executor, as indicated in *[String Concatenation](0525_String_concatenation.md)*.

* **Comparison** is tricky. Depending on how we define it, it can incur in an implicit encoding or recoding, and probably in a (also implicit) normalization.
  
* **Comparing Unicode and non-Unicode strings**. It may well be that the best option would be to completely disallow direct comparison of Unicode and non-Unicode strings.
  ```
  TEXT("A") = "A"     -- Syntax error.
  ```
* Another possibility would be to first encode the non-Unicode string using the default, Rexx-chosen, encoding.
    
* **Comparison and normalization**. Parse-time literal strings would be normalized by default (unless the third parameter to TEXT was specified). The fact that a string was normalized would be stored as part of the internal string status.
  
* **Comparing differently encoded strings**. When two strings of different encodings had to be compared, a "neutral" encoding should be used (always the same). An implementation may chose to define and fix this neutral encoding, or to allow the user to specify an "default neutral" encoding on an application level.

* **Performance of comparisons**. If a transcoding to the neutral encoding was even computed, it should be cached as part of the string status and used on subsequent calculations.

* **Compatibility**: If the Unicode option was not activated, everything should work as before, and we would have complete compatibility. When the Unicode option was activated, a new set of BIFs would be introduced, and maybe the new "string"T literals. Implementations should offer a program that would check for possible conflicts. These conflicts would only arise when an external function were called that had the same name as one of the new BIFs.

**BIFs**. Since new BIFs will always incur in the risk of creating incompatibilities, many built-in operations have been grouped under a single UNICODE BIF.

Examples (new BIF names are examples, not proposals):

    Options Unicode Encoding(UTF-8)
    a = "Síntesis"                     -- A byte string. "53 C3 AD 6E 74 65 73 69 73"X
    u = Text("Síntesis")               -- An Unicode literal String "U 53, ED, 6E, 74, 65, 73, 69, 73"X
    Text(a) == u                       -- 1        
    Unicode(a)                         -- 0
    Unicode(u)                         -- 1
    SubStr(a,2,1)                      -- "C3"X, a 1-byte string.
    SubStr(u,2,1)                      -- "í" == "U ED"X, a one grapheme (and one codepoint) Unicode string.
    Unicode(u,"Encoding")              -- "UTF-8", a byte string, the (implicit) encoding used.
    Unicode(a,"Encoding")              -- ??? Probably a syntax error, or maybe "NONE", or even "UTF-8".
    12 + Text("13")                    -- 25, a byte string.
    12 = Text("12")                    -- Syntax error, force the user to specify what she's trying to do.
    rnon  = U2T("U 52, 65, 6E, E9"X)   -- "René", NFC form
    rcomb = U2T("U 52, 65, 65, 301"X)  -- "René", NFD form
    Unicode(rnon,"Normalized")         -- 1
    Unicode(rcomb,"Normalized")        -- 0: default would be NFC
    Unicode(rcomb, "Normalized", "NFD") -- 1
    "Una" a                            -- "Una Síntesis", a byte string.
    "Una" u                            -- Text("Una Síntesis"), an Unicode string. Implicit promotion of "Una" to Unicode
    rnon == rcomb                      -- 1 (internal normalization of rcomb, caching of this normalized value)
    rnon == rcomb                      -- 1 (using the cached normalization)
    Length(rnon)                       -- 4
    Length(rcomb)                      -- 4 (internal normalization to NFC, and caching of this normalized value).
    Bytes(rnon)                        -- "Renè", a byte string
    Bytes(rnon, "UTF-16")              -- "0052 0065 006E 00E9"X
    Length(Bytes(rnon))                -- 5 
    Length(Bytes(rcomb))               -- 6 ("52 65 6E 65 CC 81"X, since U+301 is UTF8 CC81)

### New and necessary built-in functions (names and function are of course debatable)

Alphabetical list (working draft, incomplete): BYTES, CHAR (optional), CODEPOINT (or CODE?), CODEPOINTS, TEXT, UNICODE

In all the BIFs, if the string is malformed, a syntax error or similar condition should be raised.

    BYTES(string[, encoding])
    
BYTES(string, encoding) decodes _string_ using _encoding_ (default = "UTF-8"). String has to be an Unicode string, otherwise an exception is raised. 

    CHAR(string,i) 
        
Returns the _i_-th character (grapheme cluster) in _string_, or the null string if _string_ has less than _i_ characters. Similar to SUBSTR(string,i,1). Maybe adopt ooRexx notation, string[i]?

The number of characters is returned by the LENGTH BIF:

    Do i = 1 To Length(string)
      c = Char(string,i)  -- Or c = Substr(string, i, 1), or even c = string[i].
      -- Do something with i and c
    End

(Rust adds a second, boolean argument, _is_extended_: "if _is_extended_ is true, the iterator is over the _extended grapheme clusters_; otherwise, the iterator is over the _legacy grapheme clusters_. UAX#29 recommends extended grapheme cluster boundaries for general processing." -- See if this affects us or not).

    CODEPOINT(string,i)
    
Returns the _i_-th codepoint in _string_, or the null string if _string_ has less than _i_ codepoints.

    CODEPOINT(codepoint, property)

For example, ``CODEPOINT(code, "Name")``, ``CODEPOINT(code,"GC")``, ``CODEPOINT(code,"NV")``, etc.

CODEPOINT and CODEPOINTS work like WORD and WORDS. (Rust uses CHARS, but (1) CHARS is already the name of a BIF in Rexx, and (2) since codepoints are _not_ characters, it's best if the BIF name reflects it.)

    CODEPOINTS(string)
    
Number of codepoints in _string_.

    TEXT(string)

Converts (encodes) a byte _string_ using the default encoding.

    TEXT(string, encoding)

Encodes a byte _string_ using _encoding_.

    TEXT(string, encoding, handler)

Encodes _string_ using _encoding_. If errors occur during the encoding process, they are handled according to the _handler_.

(Another possibility would be to return the null string when there is an error, and then leave to another BIF --for example, UNICODE-- the task of finding the error details).

    UNICODE(string)

Returns 1 if _string_ is an unicode string, and 0 otherwise.

    UNICODE(string,"Encoding")

Returns the encoding used to produce the string. It's databable whether this value should be retained or not.

    UNICODE(string, "Normalized"[, normalizaton])

Returns 1 when the _string_ is normalized using the _normalization_ form. Default is "NFC".
