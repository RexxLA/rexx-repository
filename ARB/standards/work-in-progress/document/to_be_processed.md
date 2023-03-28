To be processed:

The following decisons are abstracted from minutes. We need to ensure they are covered in the main standard and
their rationale appropriately reworded for this annex.

Aliasing. Assignment is viewed as making the target reference the same object as the source. Hence
the object (and changes to it) may be accessed through more than one name. For 'immutable' objects a
changed version of an object can only be produced by creating a new object. For compatibility with
classic Rexx, strings are immutable objects. Non-strings may or may not be immutable. Note that there
is an alternative model in which distinction is made between assignments which copy values and
assignments which copy references. This alternative was not chosen; the committee prefered the model
in which all data names are naming references (which may be implicitly followed to values).

175
Arguments 'by-reference’. The introduction of aliasing makes this natural although the detail has
simple-versus-general contentions. (Is it necessary for simple strings to be passed by reference.
Encapsulation. An object may 'own' some variables and access to those may be limited (so that
re-implementation of the object could use different variables without upsetting the usage of the object).
Classess. There will be ‘factory’ objects capable of creating multiple new objects which have common
characteristics about how they can be used.

Inheritance and hierachy. The semantics of a clas may be specified by adding to the semantics of
another class. This relation is used to form a tree. We prefer a singly rooted tree, rooted in the class
‘Object’ which is built-in to the language. Other classes will also be built-in. Experience with OOM and
other languages is that unrestricted inheritance by one class from multiple classes does not work in the
way the coder intended (the implementations of the classes do not combine successfully). If multiple
inheritance is added to Rexx at all, it will be in the cautious 'MIXIN' flavor of OOI.

Messaging: Executing some labelled code which is associated with objects of a given class is a form of
invocation that is sufficiently different from classic Rexx to justify a new syntax construct. The new syntax
is Receiver ~ MethodName(Arguments) and implies both a different search for the method to be invoked
and a special role for the receiver as opposed to the other arguments of the invocation.

Packaging: In principle a ‘program builder’ could be used in developing Rexx programs with many classes
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

a) Stronger control, eg only one cursor within the methods of a set of objects.

b) More detailed control, eg division of a method into sections which allow/disallow other cursors into the
section.

Extended Variable Pools. The API for variable pools will need to be extended to reflect the model in
which the named content in a pool is always a reference (and the reference is followed when the value of
a string is required.) We note that OO! adopts a convention that names starting with '!' (shriek) name
objects that are not intended for access by the coder. These objects will not be standardized. Additionally
some objects without shriek names are not candidates for standardising, eg SYSTEM, .KERNEL.

176
A model is needed for whether changes made to methods are seen by objects created before the
changes. Changes that are seen are preferable where a long-lived object is being brought up-to-date.
Changes that only apply to future objects are preferable if avoiding failure of what "used to work" is the
priority. In view of OOM experience the standard should allow both, on a method by method choice. (eg
perhaps a bug fix applied retrospectively but not an enhancement.)

Multiple inheritance. Study of the 'method search’ algorithm, see later, shows that this is an "add-on" that
could readily be retained or omitted. That argues in principle for retention, since the non-user of multiple
inheritance would not suffer from it. On the other hand it adds complexity and can be misused even in
the conservative form that OOI has it.

Signature-based method search. This is not in OOI but is in languages such as Java.

Subclassing of imported classes. It is our intention to say that imported classes can be used in all the
same ways as builtin classes. Because this may be impractical to implement with some external classes,
a conforming language processor will have a list (which may be empty) of external classes it supports.
(And hence nothing of the current SOM interface will be part of the standard.)

Persistent objects. It is our belief that support for very-long-running programs is required. It is a moot
point whether the ENVIRONMENT directory is enough.

If persistent objects are to converted to a form which is platform independent, ("pickling"), there are
difficulties in deciding what pointers should be followed and further objects included, as opposed to
objects being assumed available on all platforms. This topic is defered.

Locking across a set of objects. In OOI this can only be done by locking the events serially, which has
more risk of deadlock than locking them simultaneously. The decision was made not to add
simultaneous locking.

Critical sections. The GUARD mechanism can be used in a ‘critical section’ style. Nothing will be added
to the definition.

Old objects seeing new changed methods. When bugs in long running programs are fixed, there can be
a benefit if old objects see the corrected methods. It seems practical to offer a variation of DEFINE for
this - see method lookup discussion.

The committee does not find the current OOI approach to merging ‘classic’ stems with OO stems
satisfactory. It invalidates some existing programs. (A warning about this was put in A8.3.3 of X3.274.) It
produces surprises for OO programmers, eg a==b after a=.stem~new; b=.stem~new. The proposed
alternative is to make the presence/absence of a dot at the end of the name determine whether coercion
to string is done. The 'classic' meaning of A.=B. would be restored but AA=BB, AA==BB etc. would have
their OO meanings. The meaning of USE ARG with a dotted name would be defined to allow ‘by
reference’ passing of a stem. Square brackets could be used with both dotted and undotted names. A
further proposal is to note that this leaves few differences between the DIRECTORY class and the
non-dotted STEM class so that it might be a further improvement if the DIRECTORY class was extended
to the extent that the STEM class was unnecessary.

There is a potential problem which the committee has not fully analysed in the OO! treatment of SAY and
streams. OOI has made features (of the STREAM bif) that were configuration determined in X3-274 into
OO language methods, and has made SAY a method (undocumented?). Full analysis may show that
more of I/O could (& should?) be made standard or may show that some OO! I/O language should not be
standardized.

The committee discussed what parts of the OOI implementation were suitable to be defined in a
standard. Potentially, all the builtin classes and objects (which are reachable from .ENVIRONMENT)
might be standardized. However, names which start with an exclamation mark denote unsuitable things.
The committee also thought the following unsuitable:

- Anything specific to SOM. - RX_QUEUE - Stream_Supplier - Parts of LOCAL other than direct
reference to the default streams. There is a naming problem with this. The names in OOI are STDIN,
STDOUT and STDERR. We would prefer INPUT, OUTPUT, and ERROR to be_ consistent with the
keywords. OOI has used those names for something else. We will work on the proposal that we use
the prefered names and the MONITOR class is dropped. (Users who want the monitor function can
get it with a few lines of directive.)

The committee feels that OOI over-specifies the index of an item in a LIST. In OO it is a count giving the
sequence over time of the insertions in the list. The risk in using numbers is that they may be (wrongly)
used as positions, and arithmetic done on them. It is proposed that the index of a list item be of class
OBJECT rather than of class STRING.

177
In OOI, the .ENVIRONMENT is global, not read-only, and contains builtin objects such as .TRUE and
.FALSE. The committee regards this as too risky - suppose that .TRUE was accidentally or maliciously
revalued as 0!
It seems sufficient to add read-only as a characteristic of directories. (This characteristic at the element
level might be expensive to implement.)
Reserved symbols (X8-274 clause 6.2.3.1) also provide a mechanism for preventing the override of
builtin names.
It won't be possible for a standard to exactly define in a system-independent way the scopes/lifetimes of
-ENVIRONMENT and .LOCAL but (as with OOl) the .LOCAL will relate to "One API_START" and
-ENVIRONMENT will have a wider scope. (Power on to power off of some system’).
The proposed "search order" is:
1. Things provided by the system which no user is expected to want to override. Perhaps .TRUE .FALSE
NIL.
2. The .LOCAL read/write directory, initialized with the default streams, changable by the user for
individual program executions. Perhaps METHODS here.
3. The read-only part of the environment, that is the builtin classes and objects. Also .SYSTEM perhaps.
4. The read/write ENVIRONMENT directory. Changable by programmers co-operating at the system
level.
Final placement of all builtins needs discussion, but the read-only true&false requirement will be met.
Note that the algorithm of method lookup does not change if "old objects see newest methods" is desired.
What changes is whether the method tables are updated in place or copied-and-updated when they are
changed.
1. There have been sugestions to allow the REQUIRES directive appear in more places. The committee
agrees with this and proposes:
A) All REQUIRES directives must appear together in the file. B) These directives may appear anywhere
the OOI implementation currently allows them to appear.
2. Message numbers and prose are now allocated to messages detected by the syntax, additional to the
messages known to the first standard. Most messages simply involve new minor codes sequential
beyond those defined in the first standard.
3. Proposed language, eg FORWARD, METHOD, and CLASS clauses, allow for many options which can
appear in any order. These can be written in the BNF (in the manner that TO BY FOR were handled in
the first standard) but it is neater to extend the BNF metalanguage.
4. The OOI syntax used in the FORWARD instruction has examples of the 'argument' construct, which is
either a symbol-or-string taken as a constant or is an expression in parentheses. The committee will
define 'term' to be allowed in such places. This is a change to the OOI for valid programs only in the case
where a MESSAGE option used a symbol intending it to be 'taken as a constant’. (As opposed to taken
as a variable with the value defaulting to its name when uninitialized.)
5. In a similar vein to 4 above, some other positions where the "variable reference” notation is used (or
proposed) will be changed. It would be nice to allow "term" in all these places but ambiguity consideration
means some will be "sub-expression", ie parenthesed expression, notation.
6. The colon used for superclass specification will allow symbol-or-string to follow.
DATA:
7. The model of data used in defining the first standard needs changing for OO, to:

- Variable pools are objects, objects are variable pools.

- Variable pool contents are references to objects, not values of strings.

- Pools are not numbered, they are referenced.

- The state variables (those with names beginning '#' used to define processing in the standard) are
present in all pools, as opposed to being in a separate pool.
This data model gives a natural interpretation to the variable pool API applied to local pools. (Local pools
may access non-local pool items by reason of EXPOSE.)
In principle this leads to different threads of execution (resulting from REPLY) being able to execute the
API. (In practice OOI has a restriction to executing the API only on the 'main' thread and the committee
needs to know if this is due to a generally applicable difficulty.)
The committee considered the relevance of IBM's "Object Rexx Programming Guide" G25H-7597-1 to the
Configuration section of the standard. The material there in Appendix A under headings External

178
Function Interface, System Exit Interface, and Variable Pool Interface was deemed material for inclusion,
and the rest not. This is similar to the first standard, although there will be an extra trap, for method calls.
The committee considered the relevance of the STREAM section of IBM's "Object Rexx Reference”,
G25H-7598-0. That stream class brings into the language more I/O than the original Rexx, eg an explicit
CLOSE. The new standard will partially follow this trend also.

PEEK on queue unnecessary - same as AT[1]?

Also need to resolve the issues on Monitor class and on run time inspection.

179
Annex B

(informative)

Method of definition

This annex describes the methods chosen to describe Rexx for this standard.

Definitions

Definitions are given for some terms which are both used in this standard and also may be used
elsewhere. This does not include names of syntax constructions; for example, group, which are
distinguished in this standard by the use of italic font.

Conformance

Note that irrespective of how this standard is written, the obligation on a conforming processor is only to
achieve the defined results, not to follow the algorithms in this standard.

Notation

The notation used to describe functions provided by the configuration is like a Rexx function call but it is
not defined as a Rexx function call since a Rexx function call is described in terms of one of these
configuration functions.

Note that the mechanism of a returned string with a distinguishing first character is part of the notation
used in this standard to explain the functions; implementations may use a different mechanism.
Notation for completion response and conditions

The testing of 'X' and 'S' indicators is made implicit, for brevity. Even when written as a subroutine call,
each use of a configuration routine implies the testing. Thus:

call Config Time

implies

#Response = Config Time()

if left (#Response,1) == 'X' then call #Raise 'SYNTAX', 5.1, substr (#Response, 2)
if left (#Response,1) == 'S' then call #Raise 'SYNTAX', 48.1, substr(#Response, 2)

Source programs and character sets

The characters required by Rexx are identified by name, with a glyph associated so that they can be
printed in this standard. Alternative names are shown as a convenience for the reader.

Notation

Note that nnn is not specifying the syntax of a program; it is specifying the notation used in this standard
for describing syntax.

Lexical level

Productions nnn and nnn contain a recursion of comment. Apart from this recursion, the lexical level is a
finite state automaton.

Syntax level

This syntax shows a null_clause list, which is minimally a semicolon, being required in places where
programmers do not normally write semicolons, for example after ‘THEN’. This is because the 'THEN'
implies a semicolon. This approach to the syntax was taken to allow the rule ‘semicolons separate
clauses’ to define ‘clauses’.

The precedence rules for the operators are built into this grammar

Data Model

The following explanation of data in terms of Classic Rexx may be helpful. References to clauses of the
existing standard have 274 as a prefix.

We start with the data model from the first Standard - a number of variable pools. Two mechanisms, the
external access of section 274.5.13 (API_Drop etc) and the internal of 274.7.1 (Var_Drop etc). Pools are
numbered, with pool 0 reserved for reserved names (.MN etc) and pool N-1 being related to pool N as the
caller's pool. The symbols which index the pools are distinquished as tailed or non-tailed. The items in the
pool have attributes 'exposed'’, 'dropped', and ‘implicit’. The values in the pools are string values.

An extra scope is used for 'state variables’ used in the definition of the standard. These follow the same
lookup rules in a conceptual and separate pool.

The first change necessary is to define the values in the pools as references. For string values this is just
a change in definition style, since a reference always followed to a string value is semantically identical
with the notion of having the value in the pool. However, references open the possibility of referencing

180
non-strings, which can behave in a changed way while still being refered to by the same reference.
(Mutable objects)

It is reasonable that the definition should have the pools reference one another rather than use numbered
pools. It is difficult to have a notion of numbering the pools when any object can have a set of variables
associated with it.

Assignment is defined as assignment of references. The language could have been designed differently,
for example to make assignment behave like the COPY method, but assignment of references is the
natural, powerful, choice.

If pools are not numbered, the notation of the first standard, where some state variables use the #Level
number as part of their names, will not suffice. An appropriate solution is to say that each variable pool
can have state variables and user program variables in it. Placing the state variables that are
per-procedure-level in the variable pool for their level avoids the need to specify #Level in their tails.
There are pre-existing objects such as all possible values that can be written as literals and the objects
accessed by .SYSTEM etc. Further objects are created by the NEW method.

Editorial note: It looks nice to unify: an object *is* a variable pool and a variable pool *is* an object. There is some
awkwardness describing the classic API_ function as applying to an object. There don't seem to be difficulties in
defining any object behaviour we want in terms of state variables that refer from one object to another.

Evaluation (Definitions written as code)
There is no single definitional mechanism for describing semantics that is predominantly used in
standards describing programming languages, except for the use of prose. The committee has chosen to
define some parts of this standard using algorithms written in Rexx. This has the advantages of being
rigorous and familiar to many of the intended readers of this standard. It has the potential disadvantage of
circularity - a definition based on an assumption that the reader already understands what is being
defined.
Circularity has been avoided by:
- specifying the language incrementally, so that the algorithms for more complex details are specified
in code that uses only more simple Rexx. For example, the notion that an expression evaluates to a
result can be understood by the reader even without a complete specification of all operators and
built-in functions that might be used in the expression;
- specifying the valid syntax of Rexx programs without using Rexx coding. The method used, Backus
Normal Form, can adequately be introduced by prose.
Ultimately, some understanding of programming languages is assumed in the reader (just as the ability to
read prose is assumed) but any remaining circularity in this standard is harmless.
The comparison of two single characters is an example of such a circularity; Config_Compare can
compare two characters but the outcome can only be tested by comparing characters. It has to be
assumed that the reader understands such a comparison.
Some of the definition using code is repeating earlier definition in prose. This duplication is to make the
document easier to understand when read from front to back.
Note that the layout of the code, in the choices of instructions-per-line, indentations etc., is not significant.
(The layout style used follows the examples in the base reference and it is deliberate that the DO and
END of a group are not at the same alignment.)
The code is not intended as an example of good programming practice or style.
The variables in this code cannot be directly referenced by any program, even if the spelling of some
VAR_SYMBOL coincides. These variables, referred to as state variables, are referenced throughout
this document; they are not affected by any execution activity involving scopes. Some of more significant
variables and routines are written with # as their first character. The following list of them is intended as
an aid to understanding the code. The index of this standard shows the main usage, but not all usage, of
these names.
The following are constants set by the configuration, by Config_Constants:
#Configuration is used for PARSE SOURCE.
#Version is used for PARSE VERSION.
#Bif_Digits. represents numeric digits settings, tails are built-in function names.
#Limit_Digits is the maximum significant digits.
#Limit_EnvironmentName is a maximum length.

181
#Limit_ExponentDigits is the maximum digits in an exponent.
#Limit_Literal is a maximum length.

#Limit_Messagelnsert is a maximum length.

#Limit_Name is a maximum length.

#Limit_String is a maximum length.

#Limit_TraceData is a maximum length.

These are named outputs of configuration routines:

#Response is used to hold the result from a configuration routine.
#Indicator is used to hold the leftmost character of Response.
#Outcome is the main outcome of a configuration routine.

#RC is set by Contig_Command.

#NoSource is set by Config_NoSource.

#Time is set by Config_Time

#Adjust<Index "#Adjust" #"" > is set by Config_Time

These variables are set up with output from configuration routines:

#Howlnvoked records from API_Start, for use by PARSE SOURCE.

#Source records from API_ Start for use by PARSE SOURCE.

#AIIBlanks<Index "#AllBlanks" # "" > is a string including Blank and equivalents.
#ErrorText.MsgNumber is the text as altered by limits.

#SourceLine. is a record of the source, retained unless NoSource is set. #SourceLine.0 is a count of
lines.

#Pool is a reference to the current variable pool.

These are variables not initialized from the configuration:

#Level is a count of invocation depth, starting at one.

#NewLevel equals #Level plus one.

#Pool1 is a reference to the variable pool current when the first instruction was executed.

#Upper is a reference to the variable pool which will be current when the current PROCEDURE ends.
#Loop is a count of loop nesting.

#LineNumber is the line number of the current clause.

#Symbol is a symbol after tails replacement.

#API_Enabled determines when the application programming interface for variable pools is available.
#Test is the Greater/Lesser/Equal result.

#InhibitPauses is a numeric trace control.

#InhibitTrace is a numeric trace control.

#AtPause is on when executing interactive input.

#AllowProcedure provides a check for the label needed before a procedure.

#DatatypeResult is a by-product of DATATYPE().

#Condition is a condition, eg ‘SYNTAX’.

#Trace_QueryPrior detects an external request for tracing.

#Tracelnstruction detects TRACE as interactive input.

These are variables that are per-Level, that is, have #Level as a tail component:

#lsFunction. indicates a function call.

#lsProcedure. indicates indicates the routine is a procedure.

#Condition. indicates whether the routine is handling a condition.

#ArgExists.#Level.ArgNumber indicates whether an argument exists. (Initialized from API_Start for
Level=1)

#Arg.#Level.ArgNumber provides the value of an argument. (Initialized from API_Start for Level=1)
When ArgNumber=0 this gives a count of the arguments.

182
#Tracing. is the trace setting letter.

#Interactive. indicates when tracing is interactive. ('?' trace setting)
#ClauseLocal. ensures that DATE/TIME are consistent across a clause.
#ClauseTime. is the TIME/DATE frozen for the clause.

#StartTime. is for 'Elapsed' time calculations.

#Digits. is the current numeric digits.

#Form. is the current numeric form.

#Fuzz. is the current numeric fuzz.

These are qualified by #Condition as well as #Level:

#Enabling. is 'ON', 'OFF' or 'DELAYED".

#Instruction. is ‘CALL’ or 'SIGNAL'

#TrapName. is the label.

#ConditionDescription. is for CONDITION('D')

#ConditionExtra. is for CONDITION('E’)

#ConditionInstruction. is for CONDITION('T')

#PendingNow. indicates a DELAYED condition.
#PendingDescription. is the description of a DELAYED condition.
#PendingExtra. is the extra description fora DELAYED condition.
#EventLevel. is the #Level at which an event was DELAYED.

These are qualified by ACTIVE, ALTERNATE, or TRANSIENT as well as #Level:

#Env_Name. is the environment name.

#Env_Type. is the type of a resource, and is additionally qualified by input/output/error distinction.
#Env_Resource. is the name of a resource, and is additionally qualified by input/output/error distinction.
#Env_Position. is INPUT or APPEND or REPLACE, and is additionally qualified by input/output/error
distinction.

These are variables that are per-loop:

#ldentity. is the control variable.

#Repeat. is the repetition count.

#By. is the increment.

#To. is the limit.

#For. is that count.

#lterate. holds a position in code describing DO instruction semantics.
#Once. holds a position in code describing DO instruction semantics.

#Leave. holds a position in code describing DO instruction semantics.

These are variables that are per-stream:

#Charin_Position.

#Charout_Position.

#Linein_Position.

#Lineout_Position.

#StreamState. records ERROR state for return by STREAM built-in function.

These are commonly used prefixes:
Config_ is used for a function provided by the configuration.
API_is used for an application programming interface.

Trap_ is used for a routine called from the processor, not provided by it.
Var_ is used for the routines operating on the variable pools.

183
These are notation routines, only available to code in this standard:

#Contains checks whether some construct is in the source.
#Instance returns the content of some construct in the source.
#Evaluate returns the value of some construct in the source.
#Execute causes execution of some construct in the source.
#Parses checks whether a string matches some construct.
#Clause notes some position in the code.

#Goto continues execution at some noted position.

#Retry causes execution to continue at a previous clause.

These are frequently used routines:
#Raise is a routine for condition raising.
#Trace is a routine for trace output.

#TraceSource is a routine to trace the source program.
#CheckArgs processes the arguments to a built-in function.

