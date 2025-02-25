# Rationale

This annex explains some of the decisions made by the committee that drafted this standard, and assists
in the understanding of this document. Some of the statements made here are opinions rather than facts.
These should be interpreted as if prefixed by "In the opinion of the X3J18 committee...”.

The language described in this standard is, almost entirely, a compatible extension of the language
described by the third reference of Annex C, which we call "Classic Rexx".

The extension allows programs to be written in a less monolithic fashion; "Directives" are introduced to
allow one file to contain several executable units and to allow a program to be written as several files.
The functional extension centers on the addition of objects. Unlike the individual strings which are the
data of Classic Rexx, an object may be composite. The use of identifiers to reference objects is an
indirect reference, that is two identifiers may refer to the same object. Classic Rexx avoided any aliasing,
even to the extent having by-reference parameters, to promote simple error free programming. In the
years since Rexx originated the problems tackled by programmers have become more complex and data
structures larger, so that the benefit of simplicity is outweighed by the power of assignment semantics
that are not simply copying all the data.

Even with the addition of references Rexx remains a typeless language, in the sense that the
programmer need not consider underlying hardware formats such as LONG or FLOAT representations.
Object Rexx does have classes, which are the hardware independent analogy to types. The class of an
object corresponds to the operations that can be performed upon it.
