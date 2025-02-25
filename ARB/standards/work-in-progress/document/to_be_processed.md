# To be processed:

_The following decisons are abstracted from minutes. We need to ensure they are covered in the main standard and
their rationale appropriately reworded for this annex._

Aliasing. Assignment is viewed as making the target reference the same object as the source. Hence
the object (and changes to it) may be accessed through more than one name. For 'immutable' objects a
changed version of an object can only be produced by creating a new object. For compatibility with
classic Rexx, strings are immutable objects. Non-strings may or may not be immutable. Note that there
is an alternative model in which distinction is made between assignments which copy values and
assignments which copy references. This alternative was not chosen; the committee prefered the model
in which all data names are naming references (which may be implicitly followed to values).

Arguments 'by-reference'. The introduction of aliasing makes this natural although the detail has
simple-versus-general contentions. (Is it necessary for simple strings to be passed by reference.
Encapsulation. An object may 'own' some variables and access to those may be limited (so that
re-implementation of the object could use different variables without upsetting the usage of the object).
Classess. There will be factory' objects capable of creating multiple new objects which have common
characteristics about how they can be used.

Inheritance and hierachy. The semantics of a clas may be specified by adding to the semantics of
another class. This relation is used to form a tree. We prefer a singly rooted tree, rooted in the class
Object' which is built-in to the language. Other classes will also be built-in. Experience with OOM and
other languages is that unrestricted inheritance by one class from multiple classes does not work in the
way the coder intended (the implementations of the classes do not combine successfully). If multiple
inheritance is added to Rexx at all, it will be in the cautious 'MIXIN' flavor of OOI.

Messaging: Executing some labelled code which is associated with objects of a given class is a form of
invocation that is sufficiently different from classic Rexx to justify a new syntax construct. The new syntax
is `Receiver~MethodName(Arguments)` and implies both a different search for the method to be invoked
and a special role for the receiver as opposed to the other arguments of the invocation.

Packaging: In principle a program builder' could be used in developing Rexx programs with many classes
and methods, and that builder could hide from the coder the details of how the configuration held the
methods. However, rather than define a program builder we are choosing to define a simple method of
holding multiple classes & mthods (with specification of their hierarchy) within a single text file. The
non-executable dividers in such a file are known as directives. The files are known as packages and a
package may specify (by directive) that it requires another package in order to function correctly. There
are questions about when initialization of required packages occurs; we intend to find a solution that does
not require the complete graph of requirements to be initialized before other code is executed.

A note on the syntax of directives. When no special token (eg ::) is used to introduce directives the
directives are be recognizable by the spelling of the keyword. (CLASS REQUIRES etc.) The purpose of
the special token is emphasis of directives rather than implementation ease in "pre-processing" the
directives.

Packages in non-Rexx. It is necessary to exploit packages that are not written in Rexx. To invoke their
methods it is necessary that the package makes known to the Rexx method search the names of the
classes and their methods. To do more than invoke the methods (eg to subclass the the external
classes) requires complicated mechanisms and may not be a requirement.

External procedures. To allow Classic internal procedures to be separated into different files with undue
change of semantics, the PROCEDURE statement will be permiteed as the first statement of a routine
which is in a separate file.

Concurrency will be added, that is multiple execution cursors progressing through one program. The
mechanism for creating multiple cursors will be the “early reply" where one cursor becomes two; one of
two progresses by "falling through" the early reply and the other starts its progress after the site of the
current invocation. Multiple cursors carry the risk of execution interleaving in a way which negates the
coder's intentions in writing so that clauses would execute sequentially. The language definition will be
tightened to ensure atomicity of string assignment etc. Additionally, a set of rules about allowing two
cursors on the same method at the same time will provide a reduction of the risk. Since in many cases
the data which have to be maintained consistent will reside in a single object the rules are object-based.
In general a cursor on a method executing against a particular object will delay any other cursor from
executing methods against that object.

This rule provides sensible synchronization without much effort from the programmer but other controls
may be provided:

1.  Stronger control, eg only one cursor within the methods of a set of objects.
2.  More detailed control, eg division of a method into sections which allow/disallow other cursors into the
section.

Extended Variable Pools. The API for variable pools will need to be extended to reflect the model in
which the named content in a pool is always a reference (and the reference is followed when the value of
a string is required.) We note that OOI adopts a convention that names starting with '!' (shriek) name
objects that are not intended for access by the coder. These objects will not be standardized. Additionally
some objects without shriek names are not candidates for standardising, eg `.SYSTEM`, `.KERNEL`.

A model is needed for whether changes made to methods are seen by objects created before the
changes. Changes that are seen are preferable where a long-lived object is being brought up-to-date.
Changes that only apply to future objects are preferable if avoiding failure of what "used to work" is the
priority. In view of OOM experience the standard should allow both, on a method by method choice. (eg
perhaps a bug fix applied retrospectively but not an enhancement.)

Multiple inheritance. Study of the 'method search' algorithm, see later, shows that this is an "add-on" that
could readily be retained or omitted. That argues in principle for retention, since the non-user of multiple
inheritance would not suffer from it. On the other hand it adds complexity and can be misused even in
the conservative form that OOI has it.

Signature-based method search. This is not in OOI but is in languages such as Java.

Subclassing of imported classes. It is our intention to say that imported classes can be used in all the
same ways as builtin classes. Because this may be impractical to implement with some external classes,
a conforming language processor will have a list (which may be empty) of external classes it supports.
(And hence nothing of the current SOM interface will be part of the standard.)

Persistent objects. It is our belief that support for very-long-running programs is required. It is a moot
point whether the `.ENVIRONMENT` directory is enough.

If persistent objects are to converted to a form which is platform independent, ("pickling"), there are
difficulties in deciding what pointers should be followed and further objects included, as opposed to
objects being assumed available on all platforms. This topic is defered.

Locking across a set of objects. In OOI this can only be done by locking the events serially, which has
more risk of deadlock than locking them simultaneously. The decision was made not to add
simultaneous locking.

Critical sections. The `GUARD` mechanism can be used in a critical section' style. Nothing will be added
to the definition.

Old objects seeing new changed methods. When bugs in long running programs are fixed, there can be
a benefit if old objects see the corrected methods. It seems practical to offer a variation of DEFINE for
this - see method lookup discussion.

The committee does not find the current OOI approach to merging 'classic' stems with OO stems
satisfactory. It invalidates some existing programs. (A warning about this was put in A8.3.3 of X3.274.) It
produces surprises for OO programmers, eg `a==b` after `a=.stem~new; b=.stem~new`. The proposed
alternative is to make the presence/absence of a dot at the end of the name determine whether coercion
to string is done. The 'classic' meaning of `A.=B.` would be restored but `AA=BB`, `AA==BB` etc. would have
their OO meanings. The meaning of `USE ARG` with a dotted name would be defined to allow by
reference' passing of a stem. Square brackets could be used with both dotted and undotted names. A
further proposal is to note that this leaves few differences between the DIRECTORY class and the
non-dotted STEM class so that it might be a further improvement if the DIRECTORY class was extended
to the extent that the STEM class was unnecessary.

There is a potential problem which the committee has not fully analysed in the OO! treatment of SAY and
streams. OOI has made features (of the STREAM bif) that were configuration determined in X3-274 into
OO language methods, and has made SAY a method (undocumented?). Full analysis may show that
more of I/O could (& should?) be made standard or may show that some OOI I/O language should not be
standardized.

The committee discussed what parts of the OOI implementation were suitable to be defined in a
standard. Potentially, all the builtin classes and objects (which are reachable from `.ENVIRONMENT`)
might be standardized. However, names which start with an exclamation mark denote unsuitable things.
The committee also thought the following unsuitable:

- Anything specific to SOM.
- `RX_QUEUE`
- Stream_Supplier
- Parts of `.LOCAL` other than direct reference to the default streams. There is a naming problem with this. The names in OOI are `STDIN`,
`STDOUT` and `STDERR`. We would prefer `INPUT`, `OUTPUT`, and `ERROR` to be consistent with the
keywords. OOI has used those names for something else. We will work on the proposal that we use
the prefered names and the `MONITOR` class is dropped. (Users who want the monitor function can
get it with a few lines of directive.)

The committee feels that OOI over-specifies the index of an item in a `LIST`. In OOI it is a count giving the
sequence over time of the insertions in the list. The risk in using numbers is that they may be (wrongly)
used as positions, and arithmetic done on them. It is proposed that the index of a list item be of class
`OBJECT` rather than of class `STRING`.

In OOI, the `.ENVIRONMENT` is global, not read-only, and contains builtin objects such as `.TRUE` and
`.FALSE`. The committee regards this as too risky - suppose that `.TRUE` was accidentally or maliciously
revalued as 0!

It seems sufficient to add read-only as a characteristic of directories. (This characteristic at the element
level might be expensive to implement.)

Reserved symbols (X8-274 clause 6.2.3.1) also provide a mechanism for preventing the override of
builtin names.

It won't be possible for a standard to exactly define in a system-independent way the scopes/lifetimes of
`.ENVIRONMENT` and `.LOCAL` but (as with OOI) the `.LOCAL` will relate to "One `API_START`" and
`.ENVIRONMENT` will have a wider scope. (Power on to power off of some system?).

The proposed "search order" is:

1. Things provided by the system which no user is expected to want to override. Perhaps `.TRUE` `.FALSE`
`NIL.`

2. The `.LOCAL` read/write directory, initialized with the default streams, changable by the user for
individual program executions. Perhaps `METHODS` here.

3. The read-only part of the environment, that is the builtin classes and objects. Also `.SYSTEM` perhaps.

4. The read/write `.ENVIRONMENT` directory. Changable by programmers co-operating at the system
level.

Final placement of all builtins needs discussion, but the read-only true&false requirement will be met.
Note that the algorithm of method lookup does not change if "old objects see newest methods" is desired.
What changes is whether the method tables are updated in place or copied-and-updated when they are
changed.

1. There have been sugestions to allow the `REQUIRES` directive appear in more places. The committee
agrees with this and proposes:

    A) All `REQUIRES` directives must appear together in the file. 
  
    B) These directives may appear anywhere the OOI implementation currently allows them to appear.

2. Message numbers and prose are now allocated to messages detected by the syntax, additional to the
messages known to the first standard. Most messages simply involve new minor codes sequential
beyond those defined in the first standard.

3. Proposed language, eg `FORWARD`, `METHOD`, and `CLASS` clauses, allow for many options which can
appear in any order. These can be written in the BNF (in the manner that `TO` `BY` `FOR` were handled in
the first standard) but it is neater to extend the BNF metalanguage.

4. The OOI syntax used in the `FORWARD` instruction has examples of the 'argument' construct, which is
either a symbol-or-string taken as a constant or is an expression in parentheses. The committee will
define 'term' to be allowed in such places. This is a change to the OOI for valid programs only in the case
where a `MESSAGE` option used a symbol intending it to be 'taken as a constant'. (As opposed to taken
as a variable with the value defaulting to its name when uninitialized.)

5. In a similar vein to 4 above, some other positions where the "variable reference" notation is used (or
proposed) will be changed. It would be nice to allow "term" in all these places but ambiguity consideration
means some will be "sub-expression", ie parenthesed expression, notation.

6. The colon used for superclass specification will allow symbol-or-string to follow.
DATA:

7. The model of data used in defining the first standard needs changing for OO, to:

    - Variable pools are objects, objects are variable pools.

    - Variable pool contents are references to objects, not values of strings.

    - Pools are not numbered, they are referenced.

    - The state variables (those with names beginning '#' used to define processing in the standard) are present in all pools, as opposed to being in a separate pool.

This data model gives a natural interpretation to the variable pool API applied to local pools. (Local pools
may access non-local pool items by reason of `EXPOSE`.)

In principle this leads to different threads of execution (resulting from `REPLY`) being able to execute the
API. (In practice OOI has a restriction to executing the API only on the 'main' thread and the committee
needs to know if this is due to a generally applicable difficulty.)

The committee considered the relevance of IBM's "Object Rexx Programming Guide" G25H-7597-1 to the
Configuration section of the standard. The material there in _Appendix A_ under headings _External
Function Interface_, _System Exit Interface_, and _Variable Pool Interface_ was deemed material for inclusion,
and the rest not. This is similar to the first standard, although there will be an extra trap, for method calls.
The committee considered the relevance of the `STREAM` section of IBM's "Object Rexx Reference",
G25H-7598-0. That stream class brings into the language more I/O than the original Rexx, eg an explicit
`CLOSE`. The new standard will partially follow this trend also.

`PEEK` on queue unnecessary - same as `AT[1]`?

_Also need to resolve the issues on `Monitor` class and on run time inspection._
