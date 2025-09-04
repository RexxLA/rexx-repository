The SYNTAX collection - Goals
=============================

The main goal
-------------

The main goal of the SYNTAX task force is
to prepare an up-to-date EBNF syntax definition
for ooRexx 5.1.0 (and 5.2.0 beta), including
all the latest language enhancements,
like variable references, resources,
array terms, etc.

### A note from Josep Maria Blasco

This is what interests me at the moment; please
feel free to add additional goals and objectives
to the document. I need that the nomenclature 
used in the ooRexx manuals when defining the language
is clear, understandable, unambiguous and stable,
because I will need to expose that very same
nomenclature when defining the Tree API of
the ooRexx Parser. For example, since the syntax
of the "LEAVE" instruction is `LEAVE name`,
where "name" is optional, the Tree API for the
LEAVE instruction should naturally provide
a "name" method, which would return `.Nil` when
the instruction has not specified a name.
The "natural" name for the methods defined by
the Tree API should be the names used by
ooRexx when defining the language. But the definition
of the language is partial and inconsistent.
And that's why we need to review and stabilize it
-- which is the purpose of this task force).

Fixing ambiguities
------------------

When collecting and reviewing the EBNF definitions,
we should pay special attention to concepts which are
overloaded or ambiguous; this normally has a 
correlation with certain obscurities one can
find in the reference books.

For example, the construct "variable reference"
appears in "variable reference term" (rexxref 1.11.7)
and in the VariableReference class (ib. 5.4.27):
these appearances refer to the same concept. 

Then the same construction appears in Chapter 11,
_Conditions and Condition Traps_, under the
description of the NOVALUE condition, which
is "raised if an uninitialized variable is used as
\[... a\] variable reference in an EXPOSE instruction,
a PROCEDURE instruction, or a DROP instruction".

Similarly, error 46 reads 'Invalid variable reference'
(Ib., C.1.42): there we learn that "a variable
reference" is "a variable whose value is to be used,
indicated by its name being enclosed in parentheses",
"within an ARG, DROP, EXPOSE, PARSE, PULL, or PROCEDURE
instruction". 

These concepts should be given
names which are distinct, the reference manuals should be
updated, and the EBNFs, in the case that they exist, 
should be fixed accordingly.

Define some undefined but necessary concepts
--------------------------------------------

Similarly, some concepts which appear to be necessary
are not defined. For example, a ooRexx program consists
mainly of a series of directives and code bodies.
The prolog of a program is a code body; the body of
a routine is a code body; and the body of a method is
a code body. A code body may be empty, when it consists
only of null clauses, and some directives can only
be followed by other directives, empty code bodies,
or the end of source. Non-empty code bodies are
supposed to be implicitly finished by an EXIT instruction.
Yet, ooRexx does not define the concept of code body.
It _uses_ it: for example message 99.939 is "External
routines cannot have a code body", and note 3 to
the definition of the ::ANNOTATE directive reads
"An annotation for an attribute, a method, or a routine
should be placed after any attribute/method/routine
_code body_, as ::ANNOTATE, like any other directive,
will end the _code body_", but there is Non-empty
definition of what a code body is. This is a fundamental
concept, and it should be defined.

Choose names which are nice and easy to remember
------------------------------------------------

Some concepts have denominations which are _ugly_,
and therefore impractical and difficult to remember.
One of these is what the ANSI standard calls a
`taken_constant`. A "taken constant" is either
a string, or a symbol, which is "taken as a conatant",
that is, a _name_. In several contexts, ooRexx
calls these constructs simply "names": for example,
the syntax for the LEAVE instruction is `LEAVE name`,
where "name" is optional, and similarly for ITERATE.
But these is no formal concept of name in any of the
variants of Rexx, and, besides, in some cases
strings are accepted, and in some others not,
and in a few cases we find "taken constants"
that do not refer to names, but to _values_,
like annotation values. Rexx needs a concept
with a proper denomination, and a systematic
rewrite of the references.

Avoid cryptic denominations
---------------------------

Some concepts receive cryptic denominations. For
example, the ANSI Rexx standard BNF definitions
stipulate that pattern trigger PARSE templates
may be composed of strings or "vrefp"s --
there is no explanation about what a "vrefp" is.
Some other concepts, like null clauses, receive
abbreviated names ("ncl"), which is contributes
to make the syntax definitions unreadable.

Multiple styles are not only good, but also necessary
-----------------------------------------------------

When one produces a BNF definition with the purpose
of producing an explanation about how the language
is built, or what features it has, she is naturally led
to a style which should be _pedagogical_: redundancies
are welcome, as they can make the intentions of
the language designers more explicit. In other contexts,
redundancy should be avoided, as it can introduce
bugs, errors or inconsistencies. In still other
contexts, one simply needs to assign names that
produce diagrams which fit nicely on the page.
These different needs produce definition styles
which are different. ooRexx should have a formal
BNF definition which makes the life of tool implementors
easy, and another BNF definition, which may have
an important non-empty intersection with the first
definition, suitable to produce nicely formatted
and readable manuals.
