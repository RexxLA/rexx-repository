# The Unicode Tools Of Rexx (TUTOR)

Version 0.4b, 20231014.

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
│ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
│ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
│ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
│                 ═══> TUTOR is a prototype, not a finished product. Use at your own risk. <═══                 │
│                                                                                                               │
│                         Interfaces and specifications are proposals to be discussed,                          │  
│                          and can be changed at any moment without previous notice.                            │  
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## \[Cumulative change log since release 0.4b\]

* 20231020 &mdash; Implement loose matching for property names. Move release notes for old releases to separate files in the ``doc`` directory.
* 20231017-18 &mdash; Document many properties for the UNICODE BIF, prepare for the introduction of the GRAPHEMES STRINGTYPE and class, add new tests, prepare for NFC.
* 20231015 &mdash; Fix [bug #6](https://github.com/RexxLA/rexx-repository/issues/6), implement all tests in NormalizationTest.txt, consistency check on ccc and canonical decomposition. Document
  [the Unicode.Normalization class](doc/properties/Unicode.Normalization.md). Improve the docs for the PersistentStringTable class, and move them to [a separate helpfile](doc/persistent-string-table.md).

---

## Quick installation

Download Unicode.zip, unzip it in some directory of your choice, and run ``setenv`` to set the path (for Linux users: use ``. ./setenv.sh``, not ``./setenv.sh``, or your path will not be set).

You can then navigate to the ``samples`` directory and try the samples by using ``[rexx] rxu filename``.

## Documentation

* [For The Unicode Tools Of Rexx (TUTOR, this file)](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/readme.md).
* [For RXU, the Rexx Preprocessor for Unicode](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/rxu.md)
  * [New types of strings](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/string-types.md)
  * [Revised built-in functions](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/built-in.md)
    * [Stream functions for Unicode](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/stream.md)
    * [The encoding/decoding model](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/encodings.md)
  * [New built-in functions](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/new-functions.md)
    * [The properties model](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/properties.md)
      * [The Unicode.Normalization class](doc/properties/Unicode.Normalization.md).
  * [New classes](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/classes.md)
  * [New values for the OPTIONS instruction](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/options.md)
  * Utility packages
    * [The MultiStageTable class](doc/multi-stage-table.md)
    * [The PersistentStringTable class](doc/persistent-string-table.md)
* [For the Rexx Tokenizer](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/parser/readme.md)

## Release notes for version 0.4b, 20231014

This release contains a plethora of small improvements and bug fixes; please take a look at the change log for details.

We have added support for the NFD normalization form. NFD recursively decomposes each canonically decomposable character until no more characters
can be canonically decomposed, and then reorders all non-spacing marks according to the Canonical_Combining_Class (ccc) Unicode property.

The main package is ``/components/properties/normalization.cls``, which implements a new property class, ``Unicode.normalization``,
supporting the Canonical_Decomposition property (including support for Hangul Syllabes) and the Canonical_Combining_Class property. Used in combination with the
NFD_Quick_Check property, supported by ``/components/properties/case.cls`` package, this allows to implement a nice set of new features.

* A new ``UNICODE()`` BIF. This will be the swiss knife of all Unicode BIFs, and will grow considerably in the future.
* For the moment, it supports the following calls:
  * ``Unicode(string,"isNFD")`` returns __1__ when _string_ is NFD-normalized, and __0__ otherwise.
  * ``Unicode(string,"toNFD")`` returns the _string_ argument nornalized to the NFD form.
* We are using a single ``UNICODE()`` function to avoid polluting the BIF namespace.
* ``UNICODE()`` is documented in the [_New BIFs_](doc/new-functions.md) helpfile.
* A new ``isNFD`` method, available in the CODEPOINTS and TEXT classes. It implements a very quick check for NFD, using the NFD_Quick_Check Unicode property.
* Non-strict equality for CODEPOINT and TEXT strings is now defined modulo NFD (we will be using NFC in the future; it will be more efficient, but the results
  are the same.
* Support for multi-stage tables has been improved, and [the documentation](doc/multi-stage-table) has been moved to a separate document.  

The internal tables for NFD are located in the ``/components/bin/normalization.bin`` file, which is only 26.596 bytes. It is generated by the
``/components/bin/build/normalization.rex`` utility. 

You can find a test file in ``/samples/nfd.rxu``.

An extensive test for the newly improved properties will be added soon to the distribution.

__Examples__:

```rexx
Options DefaultString Codepoints

Unicode("José",isNFD)         = 0                 -- "é" is "E9"U, a decomposable character.
Unicode("José",toNFD)         = "Jose´"           -- "é" decomposes as "e" ("65"U) || "◌́ " ("301"U)
Unicode("Jose"||"301"U,isNFD) = 1                 -- "é" is "E9"U, a decomposable character.

"José" == "Jose"||"301"U                          -- 0, since the strings are not binary equivalent
"José"  = "Jose"||"301"U                          -- 1, since the strings are canonically equivalent,
                                                  --    i.e., NFD(string1) = NFD(string2)
"José " = "Jose"||"301"U||"  "                    -- 1, blanks aren't taken into account for " ".

"José "~isNFD                                     -- 0
("Jose"||"301"U)~isNFD                            -- 1
```

## Components of TUTOR which can be used independently

There are currently two components of TUTOR which can be used independently of TUTOR, since they have no absolute dependencies on other TUTOR components.

* [The Rexx Tokenizer](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/parser/readme.md) can be used independently of TUTOR, but you will need TUTOR
  when you use one of the Unicode subclasses.
* [The UTF8](utf8.cls) routine can be used independently of TUTOR. UTF8 detects whether Unicode.cls has been loaded (by looking for the existence of a .Bytes class that subclasses .String), and returns .Bytes strings or standard ooRexx strings as appropriate.

---

## \[Cumulative change log since release 0.4a\]

* 20231014 &mdash; Implement Unicode(string,"isNFD"), Unicode(string,"toNFD") and NFD-based equivalence non-strict equality for CODEPOINT and TEXT strings.
* 20231013 &mdash; Move MultiStageTable.cls to /components/utilities, and create a separate helpfile in /doc.
* 20231012 &mdash; Improve properties registration system, preparing to implement normalizations
* 20231011 &mdash; Document AssignCharacterCategory; Add examples for InitializeCharacterCategories; add an ASSIGNMENT_OPERATOR subclass of OPERATOR, as per Rony's suggestion
* 20231010 &mdash; Fix [tokenizer bug](https://github.com/RexxLA/rexx-repository/issues/2), update tokenizer and docs.
* 20231008 &mdash; Implement [enhancement #3](https://github.com/RexxLA/rexx-repository/issues/3): add programs in the samples directory to the automated test suite, where reasonable.
* 20231007 &mdash; Fix [the charin.rxu bug](https://github.com/RexxLA/rexx-repository/issues/1).
* 20231006 &mdash; Start using the 'Issues' feature of GitHub. Partial fix for [the charin.rxu bug](https://github.com/RexxLA/rexx-repository/issues/1).
* 20231005 &mdash; Extensive code and doc refactoring to avoid clutter in the main directory.

---

## [Release notes for version 0.4a, 20231002](doc/0.4a-release-notes.md)
## [Release notes for version 0.4, 20230901](doc/0.4-release-notes.md)
## [Release notes for version 0.3b, 20230817](doc/0.3b-release-notes.md)
## [Release notes for version 0.3, 20230811](doc/0.3-release-notes.md)
## [Release notes for version 0.1d, 20230719](doc/0.1d-release-notes.md)
## [Release notes for version 0.1, 20230716](doc/0.1-release-notes.md)
## [A toy ooRexx implementation of the General_Category Unicode property (20230711)](doc/pre-0.1-release-notes.md)
