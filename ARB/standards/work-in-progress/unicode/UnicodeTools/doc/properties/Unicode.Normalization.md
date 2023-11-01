# The Unicode.Normalization class

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
``` 

The Unicode.Normalization class, a subclass of Unicode.Property, resides in [``/components/properties/normalization.cls``](../../components/properties/normalization.cls). 

The associated build routine is located at [``/components/bin/build/normalization.rex``](../../components/bin/build/normalization.rex); it generates the ``/components/bin/normalization.bin`` PersistentStringTable.

The PersistentStringTable can be checked for internal consistency by the [``/tests/normalization.rex``](../../tests/normalization.rex) utility. It also runs all the tests in NormalizationTest-15.0.0.txt.

The Unicode.Normalization class implements the following methods.

## activate (Class method)

```
   ╭──────────╮             
▸▸─┤ activate ├──▸◂
   ╰──────────╯  
```

This class method gets automatically called at the end of the class construction process. It uses the Unicode.Property registry to register:

* The ``toNFD`` function.
* The ``Canonical_Decomposition_Mapping`` and ``Canonical_Combining_Class`` (``ccc``) properties.

The ``/components/bin/normalization.bin`` PersistentStringTable contains the following entries:

<dl>
  <dt>UnicodeData.normalization.canonicalDouble.Table1</dt>
      <dd>Offset table for the ``canonicalDouble`` MultiStageTable.</dd>
  <dt>UnicodeData.normalization.canonicalDouble.Table2</dt>
      <dd>Chunks table for the ``canonicalDouble`` MultiStageTable. The table contains two-byte values. Each 16-bit value is composed of a 7-bit "last" index, and a 9-bit "first" index (see below).</dd>
  <dt>UnicodeData.normalization.canonicalDoubleFirsts</dt>
      <dd>An array of three-byte elements indexed by "first". Each element is the first component of a non-singleton, non Hangul, canonical decomposition.</dd>
  <dt>UnicodeData.normalization.canonicalDoubleLasts</dt>
      <dd>An array of three-byte elements indexed by "last". Each element is the second component of a non-singleton, non Hangul, canonical decomposition.<</dd>
  <dt>UnicodeData.normalization.CJK_F900_FAD9</dt>
      <dd>An array of three-byte elements containing the singleton canonical decomposition mappings for the CJK Compatibility Ideographs between "F900"U and "FAD9"U.
         There are no decompositions for codepoints "FAxx"U higher than "FAD9"U, and not all the codepoints have a decomposition.
      </dd>
  <dt>UnicodeData.normalization.CJK_2F800_2FA1D</dt>
      <dd>An array of three-byte elements containing the singleton canonical decomposition mappings for the CJK Compatibility Ideographs between "2F800"U and "2FA1D"U.
          There are no decompositions for codepoints "2FAxx"U higher than "2FA1D"U, and all the codepoints in the range have a decomposition.
      </dd>
  <dt>UnicodeData.normalization.canonicalCombiningClass.Table1</dt>
      <dd>Offset table for the ``canonicalCombiningClass`` MultiStageTable.</dd>
  <dt>UnicodeData.normalization.canonicalCombiningClass.Table2</dt>
      <dd>Chunks table for the ``canonicalCombiningClass`` MultiStageTable.</dd>
</dl>  

A stem called ``Canonical_Decomposition_Mapping.`` is created. It will contain targets for a calculated SIGNAL instruction. 
This will handle the cases of Hangul Syllabes ("AC00"U to "D7A3"U), and the few singleton decompositions that are not CJK Ideographs.

In the 15.0 version of ``UnicodeData.txt``, most singleton canonical decomposable characters are CJK COMPATIBILITY IDEOGRAPH F900 to FAD9 (some few
characters in this range are not decomposable) and 2F800 to 2FA1D. The rest of the characters are the following: 0340, 0341, 0343, 0374, 037E, 0387;
1F71, 1F73, 1F75, 1F77, 1F79, 1F7B, 1F7D, 1FBB, 1FBE, 1FC9, 1FCB, 1FD3, 1FDB, 1FE3, 1FEB, 1FEE, 1FEF, 1FF9, 1FFB, 1FFD; 2000, 2001; 2126, 212A, 212B;
2329, 232A.

The algorithm for Hangul Syllabes can be found in https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, pp. 144ss.

The `activate` class method initializes three arrays, `PrimaryCompositeLastSuffixes`, `PrimaryCompositeFirstPrefixes` and `PrimaryCompositeFirstSuffix`. It does so
by calling `Unicode.PrimaryComposite.rex`, located in the `components/bin` directory. This file is created at build time by `components/bin/build/normalization.rex`.
    
## Canonical_Combining_Class (Class method)

```
     ╭────────────────────────────╮  ┌──────┐  ╭───╮
▸▸───┤ Canonical_Combining_Class( ├──┤ code ├──┤ ) ├─▸◂
     ╰────────────────────────────╯  └──────┘  ╰───╯
```

Returns the Canonical Combining Class (ccc) property associated to the Unicode codepoint identified by _code_. _Code_ can be a UTF-32 codepoint (that is, a 4-byte binary integer representing a Unicode scalar), or
a hexadecimal codepoint.

The returned value is encoded as an unsigned 8-bit integer. You should use C2X and then X2D to obtain its decimal value.

## Canonical_Composition32 (class method)

```
     ╭──────────────────────────────────╮  ┌────────┐  ╭───╮
▸▸───┤ Canonical_Decomposition_Mapping( ├──┤ buffer ├──┤ ) ├─▸◂
     ╰──────────────────────────────────╯  └────────┘  ╰───╯
```

Takes a MutableBuffer argument containing the UTF-32 representation of a string, applies the Canonical Composition Algorithm (see https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, p. 138) to the buffer, and returns the modified buffer.

## Canonical_Decomposition_Mapping (Class method)

```
     ╭──────────────────────────────────╮  ┌──────┐  ╭───╮
▸▸───┤ Canonical_Decomposition_Mapping( ├──┤ code ├──┤ ) ├─▸◂
     ╰──────────────────────────────────╯  └──────┘  ╰───╯
```

Returns the Canonical Decomposition property associated to the Unicode codepoint identified by _code_ (this will be the supplied _code_ itself when there is no explicit decomposition in ``UnicodeData.txt``). _Code_ can be a UTF-32 codepoint (that is, a 4-byte binary integer representing a Unicode scalar), or a hexadecimal codepoint.

The returned value consists of a blank-separated list of Unicode codepoints. Individual codepoints have a minimum of four hexadecimal digits, and no leading zero if their length exceeds four bytes.

## ccc (Class method)

```
     ╭──────╮  ┌──────┐  ╭───╮
▸▸───┤ ccc( ├──┤ code ├──┤ ) ├─▸◂
     ╰──────╯  └──────┘  ╰───╯
```

Returns the same value as the _Canonical_Combining_Class_ method.

## toNFC

```
     ╭────────╮  ┌────────┐  ╭───╮
▸▸───┤ toNFC( ├──┤ string ├──┤ ) ├─▸◂
     ╰────────╯  └────────┘  ╰───╯
```

Returns a new NFC-normalized string equivalent to _string_.

## toNFD

```
     ╭────────╮  ┌────────┐  ╭───╮
▸▸───┤ toNFD( ├──┤ string ├──┤ ) ├─▸◂
     ╰────────╯  └────────┘  ╰───╯
```

Returns a new NFD-normalized string equivalent to _string_. Each codepoint in the supplied _string_ is substituted by its _Canonical_Decomposition_Mapping_, and then the substituted codepoints are themselves substituted by their respective decompositions, until no more decompositions are possible. Then the characters that have a _Canonical_Combining_Class_ greater than 0 are reordered according to the following algorithm:

>_D108_ Reorderable pair: Two adjacent characters `A` and `B` in a coded character sequence
>`<A, B>` are a Reorderable Pair if and only if `ccc(A) > ccc(B) > 0`. 
>
>_D109_ Canonical Ordering Algorithm: In a decomposed character sequence `D`, exchange
>the positions of the characters in each Reorderable Pair until the sequence contains
>no more Reorderable Pairs.
>
>(_Cfr._ https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, p.137)


