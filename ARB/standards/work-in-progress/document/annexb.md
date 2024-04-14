# Annex B

(informative)

## Method of definition

This annex describes the methods chosen to describe Rexx for this standard.

##  Definitions

Definitions are given for some terms which are both used in this standard and also may be used
elsewhere. This does not include names of syntax constructions; for example, group, which are
distinguished in this standard by the use of italic font.

## Conformance

Note that irrespective of how this standard is written, the obligation on a conforming processor is only to
achieve the defined results, not to follow the algorithms in this standard.

## Notation

The notation used to describe functions provided by the configuration is like a Rexx function call but it is
not defined as a Rexx function call since a Rexx function call is described in terms of one of these
configuration functions.

Note that the mechanism of a returned string with a distinguishing first character is part of the notation
used in this standard to explain the functions; implementations may use a different mechanism.

## Notation for completion response and conditions

The testing of 'X' and 'S' indicators is made implicit, for brevity. Even when written as a subroutine call,
each use of a configuration routine implies the testing. Thus:

call Config Time

implies

#Response = Config Time()

if left (#Response,1) == 'X' then call #Raise 'SYNTAX', 5.1, substr (#Response, 2)
if left (#Response,1) == 'S' then call #Raise 'SYNTAX', 48.1, substr(#Response, 2)

## Source programs and character sets

The characters required by Rexx are identified by name, with a glyph associated so that they can be
printed in this standard. Alternative names are shown as a convenience for the reader.

## Notation

Note that nnn is not specifying the syntax of a program; it is specifying the notation used in this standard
for describing syntax.

## Lexical level

Productions nnn and nnn contain a recursion of comment. Apart from this recursion, the lexical level is a
finite state automaton.

## Syntax level

This syntax shows a null_clause list, which is minimally a semicolon, being required in places where
programmers do not normally write semicolons, for example after ‘THEN’. This is because the 'THEN'
implies a semicolon. This approach to the syntax was taken to allow the rule ‘semicolons separate
clauses’ to define ‘clauses’.

The precedence rules for the operators are built into this grammar

## Data Model

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

## Evaluation (Definitions written as code)

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

