# The Unicode.Normalization class

The Unicode.Normalization class, a subclass of Unicode.Property, resides in ``/components/properties/normalization.cls``. It implements the following methods.

## activate (Class method)

```
   ╭──────────╮             
▸▸─┤ activate ├──▸◂
   ╰──────────╯  
```

This class method gets automatically called at the end of the class construction process. It uses the Unicode.Property registry to register:

* The ``toNFD`` function.
* The ``Canonical_Decomposition`` and ``Canonical_Combining_Class`` (``ccc``) properties.

The associated build routine, located at ``/components/bin/build/normalization.rex``, generates the ``/components/bin/normalization.bin`` PersistentStringTable.
The table contains the following entries:

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
      <dd>An array of three-byte elements containing the singleton canonical decomposition mappings for the CJK Compatibility Ideographs between "F900"U and "FAD9"U.</dd>
  <dt>UnicodeData.normalization.CJK_2F800_2FA1D</dt>
      <dd>An array of three-byte elements containing the singleton canonical decomposition mappings for the CJK Compatibility Ideographs between "2F800"U and "2FA1D"U.</dd>
  <dt>UnicodeData.normalization.canonicalCombiningClass.Table1</dt>
      <dd>Offset table for the ``canonicalCombiningClass`` MultiStageTable.</dd>
  <dt>UnicodeData.normalization.canonicalCombiningClass.Table2</dt>
      <dd>Chunks table for the ``canonicalCombiningClass`` MultiStageTable.</dd>
</dl>  

A stem called ``Canonical_Decomposition.`` is created. It will contain targets for a calculated SIGNAL instruction. 
This will handle the cases of Hangul Syllabes and the few singleton decompositions that are not CJK Ideographs.
    
