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

The answer to these questions will per force have a profound impact on the architecture we will end up recommending. To continue with our example, Unicode as an external library would be implementable
without making compatibility suffer, while Unicode strings by default imply a number of disruptive changes that are complex to conceptualize, manage and explain.

### What do we want to implement?

(TBD later)
