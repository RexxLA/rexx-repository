# Choices

## Draft Notes

## Purpose of this document

The purpose of this document is to list a number of choices that have to be made regarding Unicode implementations.

This is the place to describe the choices, not to advocate for one of the options.

## Choices

### Opaque/transparent implementation

An Unicode string has per force to have been ultimately constructed using an encoding.

_Opaque_ implementations destroy, or at least don't provide access to, the details of such encoding.

_Transparent_ implementations keep the details of these encoding and provide APIs to access them.

### Object-oriented/classic implementations

An Unicode implementation will per force be realized in a certain interpreter.

Regardless of whether this interpreter is object-oriented or not, an implementation is _classic_ if it relies on a set of BIFs. 
Of course, if the interpreter is object-oriented, it will also offer a corresponding set of BIMs, perhaps new classes, etc.

An implementation is _object-oriented_ if its abstractions are mainly provided by classes, class methods. etc.

### Two classes/polimorphism

An Unicode implementarion has to present abstractions to manage Unicode strings and byte strings.

The _two classes_ approach provides two different classes (i.e., roughly, "Unicode string" and "byte string", regardless of their concretion) 
and a set of mechanisms to transform values of each of the classes in values of the other class.

A _polimorphic_ approach mimics the Classic Rexx paradigm of "no types" and doesn't define two classes, but two possible _states_ of 
a unique type.

Please note that classic Rexx implementations would probably be forced to implement polimorphism, since they don't have classes.
