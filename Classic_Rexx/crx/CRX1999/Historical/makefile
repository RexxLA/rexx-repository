
# Rebuild of CRX.  This will be run out of \H\I\

# The C language programs, originally implemented with C600 compiler and then
# migrated to Warp C++, are migrated here to use Borland.
# Borland is meant to be used as a builder and the documentation for using
# the tools separately is poor. I had trouble using the linker separately.
# When used successfully as part of bcc55 compile the library is CW32.LIB and
# the 'startup' object is c0x32.obj (which we know from the map).
# Can work integrated by adding my stuff to CW32.LIB but looking for better
# way. Better way was to add IMPORT32.LIB to the linking.

.autodepend
#########################################################################
# SECTION 1  Routines that several utilities use.
a=\a\s^\    # Where my often-used files are.
# Expandable arrays:
wal.obj: $(a)wal.c $(a)wal.h
    bcc32 -c $(a)wal.c

# Building output lines.
show.obj: $(a)show.c $(a)show.h
    bcc32 -c $(a)show.c

# Bit handling in 'C'
bits.obj: $(a)bits.c $(a)bits.h
    bcc32 -c $(a)bits.c

# INC2ALL and ALL2INC allow for a set of INCs to be made one file for
# editing. (A gather/scatter mechanism)

all2inc.exe: all2inc.obj
  ilink32 /Gn /x c0x32.obj all2inc.obj wal.obj,\
    all2inc,,cw32.lib import32.lib
  copy all2inc.exe \too\*.*

all2inc.obj: $(a)all2inc.c $(a)always.h $(a)main.h $(a)wal.h
    bcc32 -c $(a)all2inc.c

inc2all.exe: inc2all.obj
  ilink32 /Gn /x c0x32.obj inc2all.obj wal.obj,\
    inc2all,,cw32.lib import32.lib
  copy inc2all.exe \too\*.*

inc2all.obj: $(a)inc2all.c $(a)always.h $(a)main.h $(a)wal.h
    bcc32 -c $(a)inc2all.c

#########################################################################
# SECTION 2  Processing parts of the ANSI Standard into ASM source code.
# Readin and tokenize a BNF grammar.
rd.obj: rd.c rd.h rdascii.h $(a)always.h $(a)main.h $(a)wal.h
  bcc32 -c rd.c

#See bnf\hbnf.doc for the grammar productions for ANSI Rexx.
# Simplify them for computer processing.
# Check sim.out for unexpected terminals, which will come from mispellings.
is.sim: \h\bnf\is.bnf simplify.exe
  simplify /:= \h\bnf\is.bnf is.sim > sim.out

simplify.exe: simplify.obj wal.obj bits.obj show.obj rd.obj
  ilink32 /Gn /x c0x32.obj simplify.obj wal.obj bits.obj show.obj rd.obj,\
    simplify,,cw32.lib import32.lib

simplify.obj: simplify.c rd.h $(a)always.h $(a)main.h $(a)wal.h $(a)show.h sy.i
  bcc32 -c simplify.c

# Compute all the states in that grammar.
is.sta: is.sim states.exe
  states /\# is.sim is.sta > states.out

states.exe: states.obj wal.obj bits.obj show.obj rd.obj
  ilink32 /Gn /x c0x32.obj states.obj wal.obj bits.obj show.obj rd.obj,\
     states,,cw32.lib import32.lib

states.obj: states.c rd.h $(a)always.h $(a)main.h $(a)wal.h $(a)show.h st.i
  bcc32 -c states.c

# Construct info for keywords and for grammar tables (structs.out).
# Structs run once with /a, once without, to make is.kwa
# and is.kwc which are keyword tables in assembler and 'C'.
# structs.out has input to packing at its end.
is.kwc: is.sim is.sta structs.exe
  structs is.sim is.sta is.kwc > structs.out
  structs /a is.sim is.sta is.kwa > structs.out

# We want is.kwa with a few extra labels in it, as keys.inc

keys.inc: is.kwa
  rexx keys

structs.exe: structs.obj wal.obj bits.obj show.obj rd.obj
  ilink32 /Gn /x c0x32.obj structs.obj wal.obj bits.obj show.obj rd.obj,\
     structs,,cw32.lib import32.lib

structs.obj: structs.c $(a)always.h $(a)main.h $(a)wal.h $(a)show.h sr.i
  bcc32 -c structs.c

# A utility produces compact message data from the raw messages of the Standard.
# Borland compiler is a pain - says "too many initializers" without saying what
# the limit is. (Anyway it is too low.) Can't see how to avoid reprogramming
# sr.i

cmp.inc: msgc.exe is.msg
  msgc /a is.msg cmp.inc > msgc.out

msgc.exe: msgc.obj wal.obj bits.obj show.obj
  ilink32 /Gn /x c0x32.obj msgc.obj wal.obj bits.obj show.obj,\
     msgc,,cw32.lib import32.lib

msgc.obj: msgc.c $(a)always.h $(a)main.h $(a)wal.h $(a)show.h mc.i is.kwc
  bcc32 -c msgc.c

# Clever packing is what makes the actual assembler syntax tables good.
syn.inc: structs.out pack.exe
  pack /u structs.out syn.inc > pack.out

pack.exe: pack.obj wal.obj bits.obj show.obj
  ilink32 /Gn /x c0x32.obj pack.obj wal.obj bits.obj show.obj,\
     pack,,cw32.lib import32.lib

pack.obj: pack.c $(a)always.h $(a)main.h $(a)wal.h $(a)show.h pa.i
  bcc32 -c pack.c
#########################################################################
# SECTION 3  Scan the assembler source to make codes.inc and codes.i.
# These files are the numeric values of the opcodes in pseudo-code and
# suchlike.  Lots of files are scanned by codes.rex to do this but we do
# not show them as dependencies - the code values rarely change.
# synequ.rex is similar, making synequ.inc and tokdata.inc
# The values also allow compilation of a program, DT.EXE, to produce
# readable from dumped p-code.

dt.exe: dt.obj bits.obj show.obj
  ilink32 /Gn /x c0x32.obj dt.obj bits.obj show.obj,\
     dt,,cw32.lib import32.lib

dt.obj: dt.c dt.i codes.i codeshdr.i $(a)always.h $(a)main.h $(a)show.h\
 $(a)bits.h
   bcc32 -c dt.c

codes.inc: codes.rex
  rexx codes

tokdata.inc: groups.inc scode.inc syn.inc
  rexx synequ

#########################################################################
# SECTION 4  Build syn.inc and cmp.inc (from section 2) into assembled prog.
# Also keys.inc
# Assembler source is kept in AS format - multiple ASM lines per AS line.
# For some unknown reason ml will not run out of a makefile (or a command from
# rexx) but will run out of a BAT file.  Hence need for lots of little BAT
# files.
# Jun 99. Hit limits on how many .obj in the $** for link. So some have to
# come via crx.lib
# Oct 99. Back below limit but I kept the mechanism.
# /Sn turns off symbols
# /Sg gets the code
# /Sc gets the code timings

declares.inc:\
 codes.inc synequ.inc

crx.lib:\
 memory.obj msg.obj tokens.obj syntax.obj pcode.obj

msg.obj: msg.as \a\s\always.inc declares.inc cmp.inc
 as2asm /a msg.as msg.asm
 mkmsg
 lib crx -+msg.obj;

memory.obj: memory.as \a\s\always.inc declares.inc
 as2asm /a memory.as memory.asm
 mkmemory
 lib crx -+memory.obj;

syntax.obj: syntax.as \a\s\always.inc declares.inc attribs.inc\
 syn.inc keys.inc tokdata.inc
 as2asm /a syntax.as syntax.asm
 mksyntax
 lib crx -+syntax.obj;

tokens.obj: tokens.as \a\s\always.inc declares.inc
 as2asm /a tokens.as tokens.asm
 mktokens
 lib crx -+tokens.obj;

pcode.obj: pcode.as \a\s\always.inc declares.inc bifs.inc
 as2asm /a pcode.as pcode.asm
 mkpcode
 lib crx -+pcode.obj;

execute.obj: execute.as \a\s\always.inc declares.inc
 as2asm /a execute.as execute.asm
 mkexecut

command.obj: command.as \a\s\always.inc declares.inc
 as2asm /a command.as command.asm
 mkcomman

bifs.obj: bifs.as \a\s\always.inc declares.inc
 as2asm /a bifs.as bifs.asm
 mkbifs

# Things in directory bf are replaced en-masse, by an ALL2INC of bf.t
bcode.obj: bcode.as \a\s\always.inc declares.inc codes.inc bf.t\
 config.inc
 as2asm /a bcode.as bcode.asm
 mkbcode

main.obj: main.as \a\s\always.inc\
 declares.inc\
 trace.inc\
 debug.inc
 as2asm /a main.as main.asm
 mkmain

# Order matters.
crx.exe: bcode.obj crx.lib execute.obj \
   bifs.obj command.obj main.obj
   link /MAP:F /CP:1 /CO $**,crx.exe,crx.map;

# Variations of CRX.EXE are sometimes required. These are made using
# \TOO\EALL.BAT to alter the source and remaking CRX.EXE.  One particular
# version is copied to CRXB.EXE - it is the version needed when converting
# REXX code from the standard into an implementation of the builtin functions.
# Making CRXB.EXE is not automated.
#########################################################################
# SECTION 5  Build part of the implementation (mainly builtins) directly
# from the Rexx in the standard.
bf.exe: bf.obj wal.obj bits.obj show.obj
  ilink32 /Gn /x c0x32.obj bf.obj wal.obj bits.obj show.obj,\
     bf,,cw32.lib import32.lib

bf.obj: bf.c $(a)always.h $(a)main.h $(a)wal.h $(a)show.h $(a)bits.h bf.i \
  codeshdr.i
  bcc32 -c bf.c

# Running CRXB makes a D.T byproduct.  Running BF makes the bf.t
bf.t: crx.rx bf.exe
  crxb crx.rx
  bf D.T > bf.log

