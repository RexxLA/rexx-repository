3 Definitions and document notation
Lots more for NetRexx

3.1 Definitions

3.1.1 application programming interface:

A set of functions which allow access to some
Rexx facilities from non-Rexx programs.

3.1.2 arguments:

The expressions (separated by commas) between
the parentheses of a function call or following the
name on a CALL instruction. Also the
corresponding values which may be accessed by a
function or routine, however invoked.

3.1.3 built-in function:

A function (which may be called as a subroutine)
that is defined in section nnn of this standard and
can be used directly from a program.

3.1.4 character string:

A sequence of zero or more characters.

3.1.5 clause:

A section of the program, ended by a semicolon.
The semicolon may be implied by the end of a line
or by some other constructs.

3.1.6 coded:

A coded string is a string which is not necessarily
comprised of characters. Coded strings can occur
as arguments to a program, results of external
routines and commands, and the results of some
built-in functions, such as D2C.

3.1.7 command:

A clause consisting of just an expression is an
instruction known as a command. The expression
is evaluated and the result is passed as a
command string to some external environment.
3.1.8 condition:

A specific event, or state, which can be trapped by
CALL ON or SIGNAL ON.

3.1.9 configuration:

Any data-processing system, operating system and
software used to operate a language processor.
3.1.10 conforming language processor:

A language processor which obeys all the
provisions of this standard.

3.1.11 construct:

A named syntax grouping, for example
"expression", "do_ specification”.

3.1.12 default error stream:

An output stream, determined by the configuration,
on which error messages are written.

3.1.13 default input stream:

An input stream having a name which is the null
string. The use of this stream may be implied.
3.1.14 default output stream:

An output stream having a name which is the null
string. The use of this stream may be implied.
3.1.15 direct symbol:

A symbol which, without any modification, names a
variable in a variable pool.

3.1.16 directive:

Clauses which begin with two colons are
directives. Directives are not executable, they
indicate the structure of the program. Directives
may also be written with the two colons implied.
3.1.17 dropped:

A symbol which is in an unitialized state, as
opposed to having had a value assigned to it, is
described as dropped. The names in a variable
pool have an attribute of 'dropped' or 'not-dropped’.

3.1.18 encoding:

The relation between a character string anda
corresponding number. The encoding of character
strings is determined by the configuration.

3.1.19 end-of-line:

An event that occurs during the scanning of a
source program. Normally the end-of-lines will
relate to the lines shown if the configuration lists
the program. They may, or may not, correspond to
characters in the source program.

3.1.20 environment:

The context in which a command may be
executed. This is comprised of the environment
name, details of the resource that will provide input
to the command, and details of the resources that
will receive output of the command.

3.1.21 environment name:

The name of an external procedure or process
that can execute commands. Commands are sent
to the current named environment, initially selected
externally but then alterable by using the
ADDRESS instruction.

3.1.22 error number:

A number which identifies a particular situation
which has occurred during processing. The
message prose associated with such a number is
defined by this standard.

3.1.23 exposed:

Normally, a symbol refers to a variable in the most
recently established variable pool. When this is not
the case the variable is referred to as an exposed
variable.

3.1.24 expression:

The most general of the constructs which can be
evaluated to produce a single string value.

3.1.25 external data queue:

A queue of strings that is external to REXX
programs in that other programs may have access

15

to the queue whenever REXX relinquishes control
to some other program.

3.1.26 external routine:

A function or subroutine that is neither built-in nor
in the same program as the CALL instruction or
function call that invokes it.

3.1.27 external variable pool:

A named variable pool supplied by the
configuration which can be accessed by the
VALUE built-in function.

3.1.28 function:

Some processing which can be invoked by name
and will produce a result. This term is used for
both Rexx functions (See nnn) and functions
provided by the configuration (see n).

3.1.29 identifier:

The name of a construct.

3.1.30 implicit variable:

A tailed variable which is in a variable pool solely
as a result of an operation on its stem. The names
in a variable pool have an attribute of ‘implicit’ or
‘not-implicit’.

3.1.31 instruction:

One or more clauses that describe some course of
action to be taken by the language processor.
3.1.32 internal routine:

A function or subroutine that is in the same
program as the CALL instruction or function call
that invokes it.

3.1.33 keyword:

This standard specifies special meaning for some
tokens which consist of letters and have particular
spellings, when used in particular contexts. Such
tokens, in these contexts, are keywords.

3.1.34 label:

A clause that consists of a single symbol or a literal
followed by a colon.

3.1.35 language processor:

Compiler, translator or interpreter working in
combination with a configuration.

3.1.36 notation function:

A function with the sole purpose of providing a
notation for describing semantics, within this
standard. No Rexx program can invoke a notation
function.

3.1.37 null clause:

A clause which has no tokens.

3.1.38 null string:

A character string with no characters, that is, a
string of length zero.

3.1.39 production:

The definition of a construct, in Backus-Naur form.
3.1.40 return code:

A string that conveys some information about the
command that has been executed. Return codes
usually indicate the success or failure of the
command but can also be used to represent other
information.

3.1.41 routine:

Some processing which can be invoked by name.
3.1.42 state variable:

A component of the state of progress in processing
a program, described in this standard by a named
variable. No Rexx program can directly access a
state variable.

3.1.43 stem:

If a symbol naming a variable contains a period
which is not the first character, the part of the
symbol up to and including the first period is the
stem.

3.1.44 stream:

Named streams are used as the sources of input
and the targets of output. The total semantics of
such a stream are not defined in this standard and
will depend on the configuration. A stream may be
a permanent file in the configuration or may be
something else, for example the input from a
keyboard.

3.1.45 string:

For many operations the unit of data is a string. It
may, or may not, be comprised of a sequence of
characters which can be accessed individually.
3.1.46 subcode:

The decimal part of an error number.

3.1.47 subroutine:

An internal, built-in, or external routine that may or
may not return a result string and is invoked by the
CALL instruction. If it returns a result string the
subroutine can also be invoked by a function call,
in which case it is being called as a function.
3.1.48 symbol:

A sequence of characters used as a name, see
nnn. Symbols are used to name variables,
functions, etc.

3.1.49 tailed name:

The names in a variable pool have an attribute of
‘tailed’ or 'non-tailed’. Otherwise identical names
are distinct if their attributes differ. Tailed names
are normally the result of replacements in the tail of
a symbol, the part that follows a stem.

3.1.50 token:

The unit of low-level syntax from which high-level
constructs are built. Tokens are literal strings,
symbols, operators, or special characters.

3.1.51 trace:

A description of some or all of the clauses of a
program, produced as each is executed.

3.1.52 trap:

A function provided by the user which replaces or
augments some normal function of the language
processor.

3.1.53 variable pool:

16

A collection of the names of variables and their
associated values.

3.2 Document notation
3.2.1 Rexx Code
Some Rexx code is used in this standard. This
code shall be assumed to have its private set of
variables. Variables used in this code are not
directly accessible by the program to be
processed. Comments in the code are not part of
the provisions of this standard.
3.2.2 Italics
Throughout this standard, except in Rexx code,
references to the constructs defined in section nnn
are italicized.
