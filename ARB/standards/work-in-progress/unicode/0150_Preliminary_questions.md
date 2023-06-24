# Preliminary questions

## ARB recommendations

(TBD)

## Draft Notes

### Introduction

There are a number of questions which, from a logical point of view, are preliminary, but, at the same time, they are impossible to settle at the present moment:
we need more information to be able to come to an informed decision.

What comes logically first, therefore, will probably end up coming last, cronologically.

As an example, one of these questions (see below) is whether we want to implement Unicode as an optional, pluggable, set of routines (for example, in the form of an external function package), 
or if, to the contrary, we set as our target a language where strings are Unicode by default, and classical Rexx strings are relegated to a specialized package.

The answer to these questions will per force have a profound impact on the architecture we will end up recommending. To continue with our example, Unicode as an external library would 
probably be implementable with little impact on compatibility, if any, while Unicode strings by default would necessarily imply a number of disruptive changes 
that are complex to conceptualize, manage and document.

### What do we want to implement?

* One possibility is to decide that Unicode support is an optional add-on to (oo)Rexx. It would be implemented in a separate loadable library; this library would offer access
to a new set of BIFs (and one or more new classes and BIMs, in the case of oo versions) that would allow the management of Unicode values, their corresponding encoding
and decodings. etc. Literal strings woould be byte-oriented bu default, and an explicit use of the library would be necessary to transform byte string values to unicode
strings.

* Another possibility would be to implement Unicode as first class strings. It would always be loaded, as part of the interpreter.
* A literal string "abcde" would be, by default, a Unicode string, and that the classical BIFs would operate, in these cases,
on grapheme clusters (or maybe on codepoints) instead of on bytes. Classic, byte-oriented, strings would continue to be definable, but would
probably require the use of a new string suffix.

It should be obvious that the second option (that some would appreciate as much more desirable than the first one) necessarily implies a set of problems (backward
compatibility, new notation, etc.) that the first option does not have.
