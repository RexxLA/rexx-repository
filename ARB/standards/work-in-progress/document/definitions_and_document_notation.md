# Definitions and document notation
Lots more for NetRexx

## Definitions

application programming interface
: A set of functions which allow access to some
Rexx facilities from non-Rexx programs.

arguments
: The expressions (separated by commas) between
the parentheses of a function call or following the
name on a CALL instruction. Also the
corresponding values which may be accessed by a
function or routine, however invoked.

built-in function
: A function (which may be called as a subroutine)
that is defined in section nnn of this standard and
can be used directly from a program.

character string
: A sequence of zero or more characters.

clause
: A section of the program, ended by a semicolon.
The semicolon may be implied by the end of a line
or by some other constructs.

coded
: A coded string is a string which is not necessarily
comprised of characters. Coded strings can occur
as arguments to a program, results of external
routines and commands, and the results of some
built-in functions, such as D2C.

command
: A clause consisting of just an expression is an
instruction known as a command. The expression
is evaluated and the result is passed as a
command string to some external environment.

condition
: A specific event, or state, which can be trapped by
CALL ON or SIGNAL ON.

configuration
: Any data-processing system, operating system and
software used to operate a language processor.

conforming language processor
: A language processor which obeys all the
provisions of this standard.

construct
: A named syntax grouping, for example
"expression", "do_ specification”.

default error stream
: An output stream, determined by the configuration,
on which error messages are written.

default input stream
: An input stream having a name which is the null
string. The use of this stream may be implied.

default output stream
: An output stream having a name which is the null
string. The use of this stream may be implied.

direct symbol
: A symbol which, without any modification, names a
variable in a variable pool.

directive
: Clauses which begin with two colons are
directives. Directives are not executable, they
indicate the structure of the program. Directives
may also be written with the two colons implied.

dropped
: A symbol which is in an unitialized state, as
opposed to having had a value assigned to it, is
described as dropped. The names in a variable
pool have an attribute of 'dropped' or 'not-dropped’.

encoding
: The relation between a character string anda
corresponding number. The encoding of character
strings is determined by the configuration.

end-of-line
: An event that occurs during the scanning of a
source program. Normally the end-of-lines will
relate to the lines shown if the configuration lists
the program. They may, or may not, correspond to
characters in the source program.

environment
: The context in which a command may be
executed. This is comprised of the environment
name, details of the resource that will provide input
to the command, and details of the resources that
will receive output of the command.

environment name
: The name of an external procedure or process
that can execute commands. Commands are sent
to the current named environment, initially selected
externally but then alterable by using the
ADDRESS instruction.

error number
: A number which identifies a particular situation
which has occurred during processing. The
message prose associated with such a number is
defined by this standard.

exposed
: Normally, a symbol refers to a variable in the most
recently established variable pool. When this is not
the case the variable is referred to as an exposed
variable.

expression
: The most general of the constructs which can be
evaluated to produce a single string value.

external data queue
: A queue of strings that is external to REXX
programs in that other programs may have access
to the queue whenever REXX relinquishes control
to some other program.

external routine
: A function or subroutine that is neither built-in nor
in the same program as the CALL instruction or
function call that invokes it.

external variable pool
: A named variable pool supplied by the
configuration which can be accessed by the
VALUE built-in function.

function
: Some processing which can be invoked by name
and will produce a result. This term is used for
both Rexx functions (See nnn) and functions
provided by the configuration (see n).

identifier
: The name of a construct.

implicit variable
: A tailed variable which is in a variable pool solely
as a result of an operation on its stem. The names
in a variable pool have an attribute of ‘implicit’ or
‘not-implicit’.

instruction
: One or more clauses that describe some course of
action to be taken by the language processor.

internal routine
: A function or subroutine that is in the same
program as the CALL instruction or function call
that invokes it.

keyword
: This standard specifies special meaning for some
tokens which consist of letters and have particular
spellings, when used in particular contexts. Such
tokens, in these contexts, are keywords.

label
: A clause that consists of a single symbol or a literal
followed by a colon.

language processor
: Compiler, translator or interpreter working in
combination with a configuration.

notation function
: A function with the sole purpose of providing a
notation for describing semantics, within this
standard. No Rexx program can invoke a notation
function.

null clause
: A clause which has no tokens.

null string
: A character string with no characters, that is, a
string of length zero.

production
: The definition of a construct, in Backus-Naur form.

return code
: A string that conveys some information about the
command that has been executed. Return codes
usually indicate the success or failure of the
command but can also be used to represent other
information.

routine
: Some processing which can be invoked by name.

state variable
: A component of the state of progress in processing
a program, described in this standard by a named
variable. No Rexx program can directly access a
state variable.

stem
: If a symbol naming a variable contains a period
which is not the first character, the part of the
symbol up to and including the first period is the
stem.

stream
: Named streams are used as the sources of input
and the targets of output. The total semantics of
such a stream are not defined in this standard and
will depend on the configuration. A stream may be
a permanent file in the configuration or may be
something else, for example the input from a
keyboard.

string
: For many operations the unit of data is a string. It
may, or may not, be comprised of a sequence of
characters which can be accessed individually.

subcode
: The decimal part of an error number.

subroutine
: An internal, built-in, or external routine that may or
may not return a result string and is invoked by the
CALL instruction. If it returns a result string the
subroutine can also be invoked by a function call,
in which case it is being called as a function.

symbol
: A sequence of characters used as a name, see
nnn. Symbols are used to name variables,
functions, etc.

tailed name
: The names in a variable pool have an attribute of
‘tailed’ or 'non-tailed’. Otherwise identical names
are distinct if their attributes differ. Tailed names
are normally the result of replacements in the tail of
a symbol, the part that follows a stem.

token
: The unit of low-level syntax from which high-level
constructs are built. Tokens are literal strings,
symbols, operators, or special characters.

trace
: A description of some or all of the clauses of a
program, produced as each is executed.

trap
: A function provided by the user which replaces or
augments some normal function of the language
processor.

variable pool 
: A collection of the names of variables and their
associated values.

## Document notation

### Rexx Code

Some Rexx code is used in this standard. This
code shall be assumed to have its private set of
variables. Variables used in this code are not
directly accessible by the program to be
processed. Comments in the code are not part of
the provisions of this standard.

### Italics

Throughout this standard, except in Rexx code,
references to the constructs defined in section nnn
are *italicized*.
