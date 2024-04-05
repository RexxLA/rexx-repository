comment~
This file is the starting point for understanding the code of "Compact Rexx".
It is entirely prose and describes:

 - mechanical aspects of editing and assembling the code.
 - conventions in the writing of the assembler code.
 - A suggested order of reading.

It is assumed the reader has a general knowledge of CRX from reading papers
available on the REXXLA site.

One difficulty is not specifically an Assembler problem, but a problem whenever
files are included.  Global searches and replacements need to see all the
inclusions together in one file.  See EALL.BAT for my solution of this
difficulty. The by-product of the editing, INC2ALL.T, has all relevant source so
it can be scanned as a last resort on "what does this variable do" questions.

A difficulty with assembler language is that a small amount of function takes a
lot of lines on the screen.  To ameliorate that a utility is used which
recognizes a separator between multiple assembler operations on one line.  (See
the .MK files used with NMAKE for how this is used.) The coding is done with an
editor set up to easily insert the separators. (The separator is ASCII 250,
which is a dot in the centre of the character.)

So the usual assembly process is (a) pull includes to one file, edit that file,
make into Object Modules to be linked.

I never found a limit that would prevent all of CRX to be done as a single
assembly so the splitting into separately assembled modules is more for
ease of understanding than for physical modularity. The .AS files have the
EXTERN and PUBLIC declarations.  Further clarity in module separation is
achieved in the "pull includes and generate files" stage by suppressing names
that are not used in the particular module being generated.  The construction
[ module-ID .....] is recognised.  The [ module-ID ] part is not passed through
to the output.  The rest of what is in the square brackets is passed unaltered
if module-ID matches what is being ASMed.  Otherwise names at the beginning of
lines are replaced by otherwise unused names.  (z000,z001,z002....)

Any pseudo-code interpreter needs an array of the addresses of the routines
that implement all the different operation codes.  If these routines are in
different object modules then the assembly that contains the array will need
lots of EXTERNs to reference the non-local routines, unless a separate segment
is used for the array.  Ideally this segment would be COMMON type, and each of
the object modules would contribute to it the address of the routines in that
object module.  However, this does not work because the linker does not support
initialized common.  The best that can be done is to use the PUBLIC combine
type.  This concatenates the contributions, in the order the object modules are
presented to the linker.  The segment FanSeg is an array of addresses of
interpreter routines.  The segment BifSeg is a similar array for the builtin
fuctions.

 USE OF SEGMENT REGISTERS

To make use of the 600K+ that DOS addresses, segment register contents
have to be changed dynamically.  Segment registers are scarce -
without overrides or Scaled Index Byte only the DS and SS have
addressing modes.  It would be difficult to program without some
"always-addressable" area, equivalent to extra registers; call it the
Zone.  By putting the Zone and the stack both under SS, the DS is
freed up for purposes such as addressing the syntax tables.  All the
SS addressing includes BP in the calculation, so BP will need a
constant value to address the Zone.  In practice here, BP is set to
zero.

By using a macro to expand an identifier to (Zshape ptr[bp]), we can avoid
having to write the [bp] on the references.

In general the physical order of code doesn't matter much, because code is
reached by labels that are word values.  However, some things the assembler does
are dependent on the physical order, eg macros need to be before their use.  To
a large extent this is handled by avoiding name clashes and putting the
equates and records declarations early. (Also first of link-edit is special
for alignment reasons.)

The Reference for MASM, which is reflected in what the assembler listing says,
is only a rough guide to speed.  (It says nop is a 3 cycle operation but my
computer does them several times faster than an immediate-to-memory which the
listing says is one cycle.) The listing says that a prefix segment override
costs no speed.  This is roughly borne out by measurement on my machine.

This says that in execution the choice of segment registers should be made to
avoid segment register loads; in compilation to avoid prefixes.  However there
is not a lot to gain anyway so simplicity comes into consideration.

(At 200MHz:  100 times a million iterations of empty DO, 11.15 secs; that
is 4.1 billion cycles according to the listing.  4 billion complex but nominally
1 cycle ops, 24 seconds.  4 billion nops 5.7 seconds.  )

ORDER OF READING

It is worth reading just the beginning of every *.as file.  Each becomes an
object module.  The FanSeg and BifSeg entries indicate what the module
implements in support of the interpreter loop(s).  The PUBLIC actions indicate
which syntax constructions are handled in the module, to construct Pcode for
them.  The PUBLIC routines indicate what the module implements in support of
other modules.  Hence a quick overview of what is done where.

Probably best to start detailed reading "bottom-up" with memory.as.  This covers
how the rest of the code reaches its data.

Bcode.as covers interpreting the (processed) Rexx from the ANSI standard so it
is an introduction to interpreter loops with the simplification that the subject
pseudo-code is fixed and visible, as opposed to some pseudo-code generated
from some unknown user program.

The general pattern of the Bcode/Pcode is as that source values appear before
the operator in the Pcode (and are loaded to the stack) while targets appear
after the operator.  (The details are covered in the utility that dumps Pcode to
a readable form.)

Bcode makes opcode/operator distinctions by different ranges of values in a
byte (see bcode.as). Pcode makes distinctions on the low order three bits of
values (see pcode.as).

The simplest operators are the four that operate on Boolean values, ie Not Or
And and Xor. There are two essentially character operations, abuttal and
concatenation.  We take 16 code points for the expansions of PARSE statements.

declares.inc for what sort of things are in Z.  fields, V.  fields etc.

Update - a utility is used instead of GroupMember macro these days.
There is an ordering in the definitions.  Macro GroupMember expansion depends on
what syn.inc has defined.  After GroupMember used, the $name values can be used
(eg for switches).  The table generator did a numbering and that is reflected in
the equates that are in syn.inc and keys.inc.  (GrpNNndx, GrpNNndxb, GrpNNAim)
The relation of those NN to names is in groups.inc Macro GroupMember (invoked
from groups.inc) uses the GrpNN values to construct a word of data for each
name.  It also generates equates for 8 bit $name and 16 bit $$name.  $name
reflects the order of appearance in groups.inc so that numbering can be chosen
independently from the table generator by manually re-ordering groups.inc.  The
constants that macro Groupmember uses to build the $$name values from the GrpNN
values reflect the TokVal layout.  NdxbT is five bits (plus 00), to pick up
doubleword of acceptance bits.  Aim is ten bits, the number of a state to switch
to.  Alternatively, Aim is an index to the switch table.  The data held with a
keyword contains a $name value, and another byte.
~
