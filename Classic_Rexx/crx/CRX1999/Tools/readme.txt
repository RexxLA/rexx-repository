To recreate CRX from scratch in the original manner there are three stages.

Stage 1 takes message text, grammar and Rexx code from the standard.  This step will not be needed unless there had been a change to the Standard or a definition
 of a different language is to be dealt with.   Some manual tidying of the text is required (mostly described at the top of CRX.RX).  For details of all the
tidying one could compare the truly-raw text from the Standard with the almost raw (CRX.RX IS_BNF.TXT IS_MSG.TXT), using a comparison utility like WinMerge.

Stage 2 would produce Assembler source using the home-made tools for that job. (Here). This has four activities:
A) Taking IS_BNF to tables for a parser.
B) Creating Assembler to declare numbers associated with the symbols that both machine generated and hand generated Assembler would reference.
c) Taking IS_MSG to a compressed form to be used to issue error messages.
D) Taking CRX.RX to a simplified (and compact) form that becomes part of CRX.EXE

There is a reason that for this order. Both messages and syntax checking can take advantage of a list of keywords.  (A) produces code in "C" that gives the structure of 
that keyword list.  The "C" gets built into the tool that performs (C).  Similarly the output of (B) forms parts of the source for the tool that does (D).

Of course, if nothing has changed in Stage 1 or the tools, there is no need for Stage 2.

Stage 3 takes all the pieces through an Assembler and Linker (MASM 6.11), producing CRX.EXE.  This is the normal stage for changes in the hand coded source. See \asm\.

The original source for the tools is in this folder but it was written in 'C' that would be rejected/deprecated by a modern C++ compiler.
Don't expect to understand much of what this folder can do.  For that you need to look at the C++ versions of these tools in folder CRX2011. (Although just looking
at the inputs and outputs of the tools helps.)

The build process has a complication that one of the tools will only run 16-bit while others need 32-bit because they use too much memory for DOS.  (A look at the 
messages in Wal.C shows that running the tools in DOS, with software spilling to disk, was contemplated.  Fortunately 32 bit hardware came in time to avoid that need.)  
So one step involves making a file in a 16 bit environment which is input to a program in a 32 bit environment.

This folder has most of the tools in a form for 32 bit execution. (They are suitable to be compiled by Borland 5.2 which was a compiler of that time. They can be
expected to compile under Borland's current free compiler.  Alternatively the free Visual Studio Express 2010 comes with wizards which know C++ rather than C but correct results can be expected if one starts an empty project and renames CPP files to be C files.)     

PROCESSING THE REXX FROM THE ANSI DOCUMENT

The builtin functions of Rexx are implemented in CRX by taking from the ANSI document the rexx code that defines them, and converting that to data (in symbolic 
Assembler) which gets incorporated in the CRX interpreter. The mechanism is that the Rexx code (crx.rx) is converted to a file D.T by utility program CRXB, 
then that file is converted to BF.T by utility BF, and finally BF.T is converted to a folder of Assembler snippets by utility All2INC.  Since CRXB is a variant of the 
CRX interpreter, that step can only be done in a 16 bit environment. CRXB is a version of CRX.EXE that is tailored for the purpose (by assemblng it with "ForBcode equ 1").

Building the other tools that CRX build uses as 16 bit real programs cannot actually be done successfully because the tools grew to have memory requirements 
beyond 16 bit, and most actually need 32 bit address space.  The following procedure will attempt producing 16 bit tools, but only serves to show that the tools would 
have needed division into smaller pieces (or software paging), if 32bit hardware had not come anong.

1. Obtain a copy of Turbo C 2.01 from the web - it is free download. Install it.  There is also a manual which is free (or just a few Euros) to download.

2. Merge the \1999\bit16 files into C:\TC.  (Yes, this was recommended practice in those days - mix your files up with the compiler's files). Notice that \1999\bit16 
   includes some *.PRJ files which Turbo C will understand.
   Merge the \1999\bit16\include files into C:\TC\include.

3. Use the Turbo C Integrated Development Environment to create *.EXEs for the tools. Some will fail at this stage - too large for the C compiler. Some will fail in 
execution - "memory exhausted".  Simplify.exe is probably the only one that will succeed.   

PROCESSING AT 32 BIT

Although the start of the original tooling was done at 16 bit, this developed into 32 bit later. Any refreshment will be more conveniently done in 32 or 64 bit mode. 
(The same bits of machine-generated Assembler will be made either way).  The generating below is assumed to be done at 32-bit. Some filenames are a matter of choice 
but here we use extension OUT for what the program writes directly, extension LOG for redirected sysout.

STAGE 2 PART A - DETAIL

(In the old times programs had to be smaller so they passed files between them. The earliest compilers of PL/I had approaching 100 passes.)

simplify /:= is_bnf.txt simplify.out         ; That makes vanilla version of the bnf from the ANSI document.
states /s simplify.out states.out            ; That identifies the grammar states.
structs simplify.out states.out is.kwc       ; That provides the base for keyword recognition, in C.
structs /a simplify.out states.out is.kwa > structs.log     ;That provides the base for keyword recognition and other stuff in the log.
pack /u structs.log syn.inc                  ; That provides syn.inc, the Assembler for the parsing table.

There is a section of structs.log where the lines start "GroupMember".  These show the 69 groupings of tokens that need to be recognised for Rexx. There is handcoded
ordering of these lines in Group.inc.  Having checked that the Group members have not changed, a previous version of Groups.inc can be used. (Groups.inc does not 
make it to the CRX linkedit - it is just input to synequ.rex later.)  The reasons for the choice are described elsewhere.

STAGE 2 PART B - DETAIL

Some of the symbolic machine-generated code has been made and the symbols tie it to the hand-generated.  The actual values associated with the symbols, and some
other stuff about how to scan Pcode is now abstracted from the source.

The linker is capable of mapping contributions from different assemblies on to one segment.  What addresses that results in depends on the order the linker sees
the object modules.  The interpreter would like to exploit the address detail.  So next we scan various files to deduce what the linker will do. Note that the makefile 
for CRX is needed for scanning but is not activated.  Note that hand-written code in the containing folder is also scanned.

Rexx CODES.REX    ; Assumes to-be-scanned are in containing folder.  Currently set to make Codes.inc and Codes.i
Rexx SynEqu.rex   ; Currently set to make SynEqu.inc and TokData.inc

A small change in is.kwa makes keys.inc. There is a little Rexx program to do the task.  (A bit pointless since doing it with an editor would be trivial).

rexx keys.rex is.kwa keys.inc         (Ignore any complaint that there was no keys.inc to erase.)

STAGE 2 PART C - DETAIL

MSGC should now be recompiled.  (Thus integrating the is.kwc from PART A )

msgc /a is_msg.txt cmp.inc                    ;That provides the compressed messages in Assembler as cmp.inc.


STAGE 2 PART D - DETAIL

This part needs a file D.T which is a processed version of the Rexx from the Standard, made by CRXB crx.rx, where CRXB is a version of CRX assembled for the purpose.
(Yes, there was a bootstrapping consideration in using CRX to build CRX but that stage is past.)

BF should be compiled using the codes.i that CRXB used.  (It also uses codeshdr.i which has other handcoded info about D.T)

BF D.T produces BF.T
All2Inc produces a separate include for each builtin function, in folder \BF.  

FINALLY FOR THIS FOLDER

At the end of this we should have made cmp.inc codes.inc keys.inc syn.inc synequ.inc tokdata.inc and the contents of folder bf.  A consistent set of this 
machine-made assembler code is required for the CRX build.  
