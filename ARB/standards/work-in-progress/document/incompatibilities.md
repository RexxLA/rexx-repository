# Incompatibilities

# The incompatibilities from Classic Rexx are:

Assignment of compound variables, as in ABC. = PQR., is an assignment of references so that ABC.
subsequently refers to the same object as PQR., as opposed to making the default value of ABC. that of
PQR.. This change was necessary to fit compound variables into the object framework, in particular
allowing USE ARG to handle compound variables as by-reference parameters. The first reference of
Annex B discouraged use of this construct in Classic Rexx programs. "Breakage" of programs due to this
incompatibility is rare.

Also something in condition handling that I don't know the reason for.

## Call
The call instruction has been extended to allow for a computed name of the callee. Syntax
considerations prevent a similar thing being done for functions.

## Concurrency
Meet 17 minutes

## Guard
Meet 17 minutes
