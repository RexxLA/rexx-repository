# crx.mk  This version not using CodeView
# Jun 99. Hit limits on how many .obj in the $** for link. So some have to
# come via crx.lib
# Oct 99. Back below limit but I kept the mechanism.
# See also SYNEQU and CODES utilities.

goal: crx.exe

# On the limit for number of things in explicit list.
# Order matters.
crx.exe: bcode.obj crx.lib execute.obj \
   bifs.obj command.obj main.obj
   link /MAP:F /CP:1 $**,crx.exe,crx.map;

# /Sn turns off symbols
# /Sg gets the code
# /Sc gets the code timings

crx.lib:\
 memory.obj msg.obj tokens.obj syntax.obj pcode.obj

declares.inc:\
 codes.inc synequ.inc

# Things in directory bf are replaced en-masse.
main.obj: main.as always.inc\
 declares.inc\
 trace.inc\
 debug.inc
 as2asm /a main.as main.asm
 ml /c /WX /Fl /Sc /Sg     /Cp main.asm

memory.obj: memory.as always.inc declares.inc
 as2asm /a memory.as memory.asm
 ml /c /WX /Fl /Sc /Sg     /Cp memory.asm
 lib crx -+memory.obj;

msg.obj: msg.as always.inc declares.inc cmp.inc
 as2asm /a msg.as msg.asm
 ml /c /WX /Fl /Sc /Sg     /Cp msg.asm
 lib crx -+msg.obj;

bcode.obj: bcode.as always.inc declares.inc codes.inc\
 config.inc
 as2asm /a bcode.as bcode.asm
 ml /c /WX /Fl /Sc /Sg     /Cp bcode.asm

syntax.obj: syntax.as always.inc declares.inc\
 syn.inc keys.inc tokdata.inc
 as2asm /a syntax.as syntax.asm
 ml /c /WX /Fl /Sc /Sg     /Cp syntax.asm
 lib crx -+syntax.obj;

tokens.obj: tokens.as always.inc declares.inc attribs.inc
 as2asm /a tokens.as tokens.asm
 ml /c /WX /Fl /Sc /Sg     /Cp tokens.asm
 lib crx -+tokens.obj;

pcode.obj: pcode.as always.inc declares.inc \
  bifs.inc
  as2asm /a pcode.as pcode.asm
 ml /c /WX /Fl /Sc /Sg     /Cp pcode.asm
 lib crx -+pcode.obj;

bifs.obj: bifs.as always.inc\
 declares.inc
 as2asm /a bifs.as bifs.asm
 ml /c /WX /Fl /Sc /Sg     /Cp bifs.asm

execute.obj: execute.as always.inc declares.inc
 as2asm /a execute.as execute.asm
 ml /c /WX /Fl /Sc /Sg     /Cp execute.asm

command.obj: command.as always.inc declares.inc
 as2asm /a command.as command.asm
 ml /c /WX /Fl /Sc /Sg     /Cp command.asm
