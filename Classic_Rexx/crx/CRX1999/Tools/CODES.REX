/* This program works out how the list of addresses of routines to implement
 code points of the interpreter(s) is built up by the Assembler/Linker.

 These values can then be used in other utilities that need to know (like the
 pseudo-code dumper) and are included in the assemblies. We have to this
 two-stage route because the Assembler doesn't know what the linker will do.

 Sept 99 re-arrangement of codes.
  The shared Pcodes $pAbut etc go 1 to 73h, odds.   57 of em
  bcodes.inc shows 32 fragments.
  Config_ 16 slots.                    Jan 00 - need more.
  42*2 slots for reference to local variables.
  22 like _Exists
  SysVars 2*11
  16 like ArithOp

  Split
    Odd
      small opcode - $pCode   58
      Fragments               32     128
      (Gap here?  Fragnn to BcodesBase)
      larger Opcode - _OpCode 22
      largest Opcode - Config 16


    Even
      SysVars                              22   122
      ArithOp type                         16
      42 more neg with wrap - Local put    42
      Negatives - Local get                42

  Oct 99.
   Pick up some more stuff from ASM, operator facts.
*/

 Mk="..\asm\CRX.MK"; OutAsm="codes.inc"; OutC="codes.i"
 InPc="..\asm\pcode.as"
 InBc="..\asm\bcode.as"
 InBi="..\asm\bifs.as"
 InDe="..\asm\declares.inc"
 Routines=''; Counter=1; CounterB=0
 "ERASE" OutAsm; "ERASE" OutC

/* Look thru Makefile to note link-edit order. */
 do while lines(Mk)>0
   Line=linein(Mk)
   do while right(Line,1)='\'
     Line=left(Line,length(Line)-1)||linein(Mk)
   end
/* Find the line that shows link order */
   if pos("crx.exe:",Line)>0 then signal Found
 end
 say "Didn't find the relevant line"
 exit

Found: Routines=''; Bifs=''; Bops='';
/* Run a loop over the object module names in relevant order. */
/* Actually more mechanism than we actually need but harmless. */
 Objs = substr(Line,pos("crx.exe:",Line)+length("crx.exe:"))
 do while Objs<>""
   parse var Objs Obj Objs  /* Next Obj */
/* XXX.obj is made from XXX.AS */
   parse var Obj Name '.' .
   if Name = "crx" then Name = "Memory"; /* From crx.lib */
/* Within each component, look for the FanSeg segment. */
   Subject = "..\asm\"Name".AS"
   say "Subject" Subject
   do while lines(Subject)>0
     Line = linein(Subject);if left(strip(Line,'L'),1)==';' then iterate
     if pos("FanSeg SEGMENT",Line)>0 then do
       say Name "has FanSeg"
       Line = linein(Subject)
       do while pos("FanSeg ",Line)=0
         /* Lines will be labels or 'dw' for routine implementing operation. */
         if pos(" dw ",Line)>0 then do
           parse var Line . Routine ';' .
           dd=right(Routine,2)
           /* Convention to end names of them with $$ */
           if dd<>"$$" then do;Say "$$a??" Line;exit;end
           Routine=left(Routine,length(Routine)-2)
           Routines = Routines' 'Routine
           Counter = Counter+2
         end
         else do
           p=pos(":",Line)
           if p=0 then do;say "b??" Line;exit;end
           Label=left(Line,p-1)
           say ":::" Label Counter
/* Count. is set to associate opcode number with name. */
           Count.Label = Counter
         end
         do until left(strip(Line,'L'),1)<>';'
           Line = linein(Subject)
         end
       end /* of one FanSeg segment contribution. */
     end /* FanSeg found */

/* The names of the operators are accumulating left-to-right in Routines.*/
/* Same exercise for builtins */
     if pos("BifSeg SEGMENT",Line)>0 then do
       say Name "has BifSeg"
       Line = linein(Subject)
       do while pos("BifSeg ",Line)=0
         /* There can be labels. */
         if pos(" dw ",Line)>0 then do
           parse var Line . Bif ';' .
           Bif = substr(Bif,4)
           Bifs = Bifs' 'Bif
           CounterB = CounterB+1
         end
         else do
           p=pos(":",Line)
           if p=0 then do;say "c??" Line;exit;end
           Label=left(Line,p-1)
           say ":::" Label CounterB
           Count.Label = CounterB
         end
         do until left(strip(Line,'L'),1)<>';'
           Line = linein(Subject)
         end
       end /* of one BifSeg segment contribution. */
     end /* BifSeg found */

/* The names of the bifs are accumulating left-to-right in Bifs.*/

/* Same exercise for bcode-only operations */
     if pos("FanSegB SEGMENT",Line)>0 then do
       say Name "has FanSegB"
       Line = linein(Subject)
       do while pos("FanSegB ",Line)=0
         /* There can be labels. */
         if pos(" dw ",Line)>0 then do
           parse var Line . Bop ';' .
           dd=right(Bop,2)
           /* Convention to end names of them with $$ */
           if dd<>"$$" then do;Say "$$x??" Line;exit;end
           Bop=left(Bop,length(Bop)-2)
           Bops = Bops Bop
         end
         else do
           p=pos(":",Line)
           if p=0 then do;say "cb??" Line;exit;end
           Label=left(Line,p-1)
           say ":::" Label
         end
         do until left(strip(Line,'L'),1)<>';'
           Line = linein(Subject)
         end
       end /* of one FanSegB segment contribution. */

/* The names of the b-operators are accumulating left-to-right in Bofs.*/

     end /* FanSegB found */
   end /* Lines of .AS */
 end /* Object modules */
 /* Generate equates. */

/*------------------------------------------------------------------------------
 We now have Routines, Bifs, and Bofs.
 Write equ's for the Assembler
õ-----------------------------------------------------------------------------*/
 RoutinesCopy = Routines;
 x = "PcodesBase$"
 PcodesBase = Count.x
 call lineout OutAsm,"$PcodesBase equ 0"d2x(PcodesBase)"h"
 call lineout OutC,"#define PcodesBase 0x"d2x(PcodesBase)
 p = "BPcodesCeil$"
 BPcodesCeil = Count.p
 call lineout OutAsm,"$BPcodesCeil equ 0"d2x(BPcodesCeil)"h"
 call lineout OutC,"#define BPcodesCeil 0x"d2x(BPcodesCeil)
 p = "PcodesCeil$"
 PcodesCeil = Count.p
 call lineout OutAsm,"$PcodesCeil equ 0"d2x(PcodesCeil)"h"
 call lineout OutC,"#define PcodesCeil 0x"d2x(PcodesCeil)
 p = "PjumpBase$"
 PjumpBase = Count.p
 call lineout OutAsm,"$PjumpBase equ 0"d2x(PjumpBase)"h"
 call lineout OutC,"#define PjumpBase 0x"d2x(PjumpBase)
 p = "PjumpCeil$"
 PjumpCeil = Count.p
 call lineout OutAsm,"$PjumpCeil equ 0"d2x(PjumpCeil)"h"
 call lineout OutC,"#define PjumpCeil 0x"d2x(PjumpCeil)
 Counter = 1
 do while Routines <> ''
   parse var Routines Routine Routines
    if Counter >= PcodesBase then
     do
       /* Opcodes have odd values, in Pcode. */
       t = Counter
       call lineout OutAsm,"$p"Routine "equ 0"d2x(t)"h"
       Pcodes.Routine = t
     end
   Counter = Counter + 2
 end
/* Bifs count from zero. */
 Counter=0
 BifName.=''
 do while Bifs <> ''
   parse var Bifs Bif Bifs
   call lineout OutAsm,'$Bif'Bif "equ" Counter
   Bifs.Bif = Counter
   BifName.Counter = Bif
   Counter = Counter + 1
 end
/* Bops count up to 255. */
 BopCt = words(Bops)
 BopNo = 257-2*BopCt
 call lineout OutAsm,"$BcodesBase equ 0"d2x(BopNo)"h"
 do while Bops <> ''
   parse var Bops Bop Bops
   call lineout OutAsm,Bop "equ 0"d2x(BopNo)"h"
   BopNo = BopNo + 2
 end
 call lineout OutAsm; /* Completes work on the file for Assembly. */
/*------------------------------------------------------------------------------
 Make the file which feeds the same info to "C" programs.
õ-----------------------------------------------------------------------------*/
 Line = " OpShape Pcodes[]={"
 call lineout OutC,Line
 Routines = RoutinesCopy
 Optor. = ''
 Marker. = ''
/* Find the ASM lines that specify facts on operators. */
 do while lines(InPc)>0
   Line=linein(InPc);
   parse var Line "org OpFlags+$p" Optor '/' . '<' Facts '>'
   if Optor<>'' then Optor.Optor = Facts
 end
 do while lines(InDe)>0
   Line=linein(InDe);
/* Note the values of markers (subcodes) */
   if left(word(Line,1),2)=="$m" & word(Line,2)=="equ" then do
      Marker=substr(word(Line,1),3)
      MarkerNum = word(Line,3)
      MarkerNum = substr(MarkerNum,1,length(MarkerNum)-1) /* It is like 1Ah */
      MarkerNum.Marker = MarkerNum
      MarkerNum = X2D(MarkerNum)%8
      Marker.MarkerNum = Marker
     end
 end
/* Put out Facts in "C" */
 do while Routines <> ''
   parse var Routines Routine Routines
   parse var Optor.Routine I ',' O ',' N ',' R ',' D ',' E
/* The op record has R==1 whether the 2 byte append is a label or a variable
 reference.  We can distinguish by the value of the op. */

   J = Pcodes.Routine >= PjumpBase & Pcodes.Routine < PjumpCeil
/* Before optimising, D is 1 for $pEq etc because they are binary ops.
 After optimising the $pThen is (usually) omitted so the D for that has
 to go somewhere. It is added in on the comparisons. */
   if J then do
     t="Eq"
     if Pcodes.Routine >= Pcodes.t then D=D+1
   end
   Line = " XtraNone,"
   if Routine == "AssignConst" then Line = " XtraSymbol,"
   Line = Line N',' R',' J',' D',' E','
   Line = Line '"'Routine'",'
   call lineout Outc,Line
 end
 call lineout OutC," };"
/* Put out markers in "C" */
 Line = " OpShape Mcodes[]={"
 call lineout OutC,Line
 do j=0 by 1 while Marker.j<>""
   Line = " XtraNone,0,0,0,0,0,"
   Line = Line '"'Marker.j'",'
   call lineout OutC,Line
 end
 call lineout OutC," };"
 do j=0 by 1 while Marker.j<>""
   Marker=Marker.j;MarkerNum=MarkerNum.Marker
   Line = "#define m"Marker "0x"MarkerNum
   call lineout OutC,Line
 end
/* Scan for info on required arguments, per Bif. */
 Subject = InBc; call BifInfo
 Subject = InBi; call BifInfo
/* Write results. */
 Line = " BifShape Bifs[]={"
 call lineout OutC,Line
 do Counter=0 by 1 while BifName.Counter<>''
   Bif = BifName.Counter
   Line = "  "BifMin.Bif', "'Bif'",'
   call lineout OutC,Line
 end
 call lineout OutC," };"
 call lineout OutC
 say "Codes.rex has finished normally, making "OutAsm" and "OutC"." /* 2011 */
 exit
BifInfo:
 PrevLine='';

 call lineout Subject /* Close */

 say "BifInfo" Subject
 do while lines(Subject)>0
   Line = linein(Subject)
   if left(Line,3)=='Bif' then do
      j = pos(':',Line)
      if j>0 then do
        Bif = substr(Line,4,j-4)
        parse var PrevLine "ParmsRec <" N ',' .
        BifMin.Bif = N
      end
     end
   PrevLine = Line
 end
/* 2011 BITAND, BITOR, and BITXOR are all done by one routine.
*/
 Captured = "BITOR";
 Bif="BITAND";
 BifMin.Bif = BifMin.Captured;
 Bif="BITXOR";
 BifMin.Bif = BifMin.Captured;

 return
