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

### The "optional" approach (a brainstorm proposal) (jmb)

Let's see how the "optional" approach could work in a non-oo interpreter as, for example, Regina Rexx. Unicode would be loaded by an OPTIONS instruction. 

    OPTIONS UNICODE -- Or OPTIONS Text, etc. This is not a name proposal
This loading would be undoable (i.e., you wouldn't be able to unload Unicode once loaded). Implementations may choose to implement Unicode as a separate library.

* Unicode support would offer several new BIFs. Let's call the main one **TEXT** (again, this is not a name proposal). TEXT(string) would return _a Unicode string_ (to be defined shortly). With a little help from the interpreter, static, parse-time analysis, would be able to determine if calls to TEXT were indeed to be resolved to the new BIF, and then calls with a literal argument could be treated as **literal Unicode strings** and optimized as such.

* The **result** from a call to TEXT would be the very same string received as an argument (or a copy of the string if the original had active references to it), but with an implementarion-defined, internal, flag that would indicate that the string was, indeed, an **Unicode string**.

* The **encoding** to use would be the same as the one used in the program file, if supported by Rexx. An explicit encoding could be specified using an OPTIONS instruction.
  ```
  OPTIONS UNICODE ENCODING(ISO-8859-1)
  ```
* **Explicit encodings**. An optional, second argument to TEXT could make the encoding explicit:
  ```
  TEXT("string", "UTF-8").
  ```
* If any encoding errors were found, a **new condition** would be raised. An optional third parameter could be specified to allow ignoring of encoding errors, e.g.,
  ```
  TEXT("string", "UTF-8", "Ignore")
  ```
* The fact that there was or not an encoding error would be stored as part of the string status, and would be accesible using a specialized BIF.

* The interpreter would provide an adapted set of **BIFs** for Unicode strings. They would work similarly to the standard BIFs, but at the _grapheme cluster_ level.
  ```
  Options Unicode Encoding(UTF-8)
  string = "René"
  text = Text(string)
  Say Length(string)   -- 5
  Say Length(text)     -- 4
  ```
* **Arithmetic** operators would work as usual, with ASCII numbers, and the "e", "E", ".", "+" and "-" characters, regardless of whether they are part of an Unicode or a byte string. The result of an arithmetic operation would always be a plain (i.e., non-unicode) ASCII string.

* **Concatenation** would follow a protocol similar to the one used by Executor, as indicated in *[String Concatenation](0525_String_concatenation.md)*.

* **Comparison** is tricky. Depending on how we define it, it can incur in an implicit encoding or recoding, and probably in a (also implicit) normalization.
  
* **Comparing Unicode and non-Unicode strings**. It may well be that the best option would be to completely disallow direct comparison of Unicode and non-Unicode strings.
  ```
  TEXT("A") = "A"     -- Syntax error.
  ```
* Another possibility would be to first encode the non-Unicode string using the default encoding.
    
* **Comparison and normalization**. Parse-time literal strings would be normalized by default (unless the third parameter was "Ignore"). The fact that a string was normalized would be stored as part of the internal string status.
  
* **Comparing differently encoded strings**. When two strings of different encodings had to be compared, a "neutral" encoding should be used (always the same). An implementation may chose to define and fix this neutral encoding, or to allow the user to specify an "default neutral" encoding on an application level.

* **Performance of comparisons**. If a transcoding to the neutral encoding was even computed, it would be cached as part of the string status and used on subsequent calculations.

* **Compatibility**: If the Unicode option was not activated, everything should work as before, and we would have complete compatibility. When the Unicode option was activated, a new set of BIFs would be introduced. Implementations should offer a program that would check for possible conflicts. These conflicts would only arise when an external function were called that had the same name as one of the new BIFs.

Examples (new BIF names are examples, not proposals):

    Options Unicode Encoding(UTF-8)
    a = "Síntesis"                     -- A byte string. "53 C3 AD 6E 74 65 73 69 73"X
    u = Text("Síntesis")               -- An Unicode literal String "U 53, ED, 6E, 74, 65, 73, 69, 73"X
    Text(a) == u                       -- 1        
    IsUnicode(a)                       -- 0
    IsUnicode(u)                       -- 1
    SubStr(a,2,1)                      -- "C3"X, a 1-byte string.
    SubStr(u,2,1)                      -- "í" == "U ED"X, a one grapheme (and one codepoint) Unicode string.
    Encoding(u)                        -- "UTF-8", a byte string, the (implicit) encoding used.
    Encoding(a)                        -- ??? Probably a syntax error, or maybe "NONE", or even "UTF-8".
    12 + Text("13")                    -- 25, a byte string.
    12 = Text("12")                    -- Syntax error, force the user to specify what she's trying to do.
    rnon  = U2T("U 52, 65, 6E, E9"X)   -- "René", NFC form
    rcomb = U2T("U 52, 65, 65, 301"X)  -- "René", NFD form
    IsNormalized(rnon)                 -- 1
    IsNormalized(rcomb)                -- 0: default would be NFC
    IsNormalized(rcomb, "NFD")         -- 1
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

    BYTES(string[, encoding])
    
BYTES(string, encoding) decodes string using encoding (default = "UTF-8"). String has to be an Unicode string, else syntax error. 

    CHAR(string,i) -- Returns the i-th character (grapheme cluster) in string, or the null string if string has less than i characters. Similar to SUBSTR(string,i,1). Maybe adopt ooRexx notation, string[i]?

The number of characters is returned by the LENGTH BIF:

    Do i = 1 To Length(string)
      c = Char(string,i)
      -- Do something with i and c
    End

(Rust adds a second, boolean argument, is_extended: "if is_extended is true, the iterator is over the _extended grapheme clusters_; otherwise, the iterator is over the _legacy grapheme clusters_. UAX#29 recommends extended grapheme cluster boundaries for general processing." -- See if this affects us or not).

    CODEPOINT(string,i) -- Returns the i-th codepoint in string, or the null string if string has less than i codepoints.

CODEPOINT and CODEPOINTS work like WORD and WORDS. [Rust uses CHARS, but (1) CHARS is already the name of a BIF in Rexx, and (2) since codepoints are _not_ characters, it's best if the BIF name reflects it.]

    CODEPOINTS(string) -- Number of codepoints in a string  

In all the BIFs, if the string is malformed, a syntax error or similar condition should be raised.
