/* Manual sorting of the groups.inc output from the utility syntax-table maker
determines the actual numeric values used for lexical items, eg $Asterisk or
$THEN.  The generation of "equ" statements from the groups.inc contents can
be done with a MASM 6.0 macro (see appended) but it is complicated and hard to
make use of in more than one object module.  Hence this program, which makes
the same output as the macro. */
 Out="synequ.inc"
 OutTok="tokdata.inc"
 "ERASE" Out
 "ERASE" OutTok
 Groups="groups.inc"
 Scode="scode.inc"
 Syn="syn.inc"
/* Scan syn.inc to see what it declares. */
 do while lines(Syn)>0
   Line=linein(Syn)
   parse var Line Name Equ .
   if Equ=="equ" then IfDef.Name = 'Y'
 end

 Counter = 0
 SubCount = 0
 PrevGrp = 999
 PrevName = ""
 do while lines(Groups)>0
   Line=linein(Groups)
/* Pick up to Grp the number that the utility used for the group containing
 Name. */
   parse var Line Gm Grp ',' Name
   if Gm \== "GroupMember" then iterate
/* This equate is for when the group is involved in Direct acceptance. */
   if Grp \= PrevGrp then do
     t = "$Grp"Grp"Only"
     if IfDef.t='Y' then
       call lineout Out,"$"Grp "equ" Counter
   end
   if Grp \= PrevGrp | SubCount=3 then do
/* A new number in our series of token numbers is required. */
/* Does the token always cause "aim" to a state? */
     t = "$Grp"Grp"Aim"
     if IfDef.t='Y' then
       Value = "($Grp"Grp"ndxb shl NdxbT)+$Grp"Grp"Aim"
/*
       call lineout Out,"$$"Name "equ ($Grp"Grp"ndxb shl NdxbT)+$Grp"Grp"Aim"
*/
     else
       Value = "($Grp"Grp"ndxb shl NdxbT)+$Grp"Grp"ndx+$Needed/2"
/*
call lineout Out,"$$"Name "equ ($Grp"Grp"ndxb shl NdxbT)+$Grp"Grp"ndx+$Needed/2"
*/
     call lineout OutTok," dw" Value
/* Syntactically '=' differs from the other comparisons (because usable in
     parsing template). Here is the place we force it to be numbered adjacent.
     Eq is the only thing in its group.
*/
    if Name \= "Eq" then
      call lineout Out,"$"Name "equ" Counter"*4"
    else
      call lineout Out,"$"Name "equ" Counter"*4+3"
    Counter = Counter + 1
    PrevGrp = Grp
    SubCount = 0
  end
  else do
/* If not new, just equate. */
    SubCount = SubCount + 1
    call lineout Out,"$"Name "equ 4*("Counter"-1) + "SubCount
  end
 end /* file Groups */
/* Also want to note the $sXXX codes which are the result of manually
overlaying sparse sets of the $names. */
 Counter = 0
 do while lines(Scode)>0
   Line=linein(Scode)
   if pos("Assert $s",Line) > 0 then do
     parse var Line . Name .
     call lineout Out,Name "equ" Counter
     end
   if pos('db ',Line)>0 then Counter = Counter + 1
 end
 say "Synequ finished normally, making "Out" and "OutTok"."
 exit
/*
; Syntax table. Not first in link edit since addressed with -4 offset.
; Precedes GroupMember since that uses ifdef. Not edited.
                                                          include syn.inc
; Assembly time variables for the GroupMember macro.
Counter textequ <0>
SubCount textequ <0>
PrevGrp textequ <999>
PrevName textequ <   >
GroupMember macro Grp, Name
 ;; This macro provides values for $Name and $$Name for each token.
 ;; The table builder passes equ's in syn.inc which tell us what
 ;; assembly-time values it has symbolically referenced.
 ;; We want a further array element only when the group is a new one.
 ;; But we also have to put an extra word, identical to the previous,
 ;; when the SubNum space doesn't allow enough $Name values to use the
 ;; same slot.
 ;; Counter counts real slots (words) in the TokData.
 ;; SubCount distinquishes tokens which map to that slot.
 ;; This equate is for when the group is involved in Direct acceptance.
 if Grp ne PrevGrp
%  ifdef @CatStr(<$Grp>,Grp,<Only>)
     @CatStr(<$>,Grp,< equ >, %Counter)
   endif
 endif
 if Grp ne PrevGrp or SubCount eq 3
% ifdef @CatStr(<$Grp>,Grp,<Aim>)
;; This equate is for when the token results in aiming at a state.
   @CatStr(<$$>,Name,< equ ($Grp>,Grp,<ndxb shl NdxbT)+$Grp>,Grp,<Aim>)
  else
   @CatStr(<$$>,Name,< equ ($Grp>,Grp,<ndxb shl NdxbT)+$Grp>,Grp,<ndx+$Needed/2>)
  endif
  @CatStr(< dw $$>,Name)
;; Syntactically '=' differs from the other comparisons (because usable in
;; parsing template). Here is the place we force it to be numbered adjacent.
;; Eq is the only thing in its group.
  ifdif <Name>,<Eq>
   @CatStr(<$>,Name,< equ >, %Counter,< *4>)
  else
   @CatStr(<$>,Name,< equ >, %Counter,< *4 + 3>)
  endif
  Counter textequ %Counter+1
  PrevGrp textequ %Grp
  SubCount textequ <0>
 else
;; If not new, just equate.
   SubCount textequ %SubCount+1
   @CatStr(<$>,Name,< equ 4*(>, %Counter,<-1) + >, %SubCount)
 endif
 PrevName textequ <%Name>
 exitm
endm
TokData word Overlay
 include groups.inc
*/
