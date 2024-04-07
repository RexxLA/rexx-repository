;------------------------------------------------------------------------------
; Literal and numeric replacements
;------------------------------------------------------------------------------
is textequ <textequ>
Bptr  is <byte ptr>
Wptr  is <word ptr>
Dptr  is <dword ptr>
Hang  is <jmp $>
$Cr   is <0dh>
$Lf   is <0ah>
$Eof  is <1ah>
Overlay is <0 dup(?)>
Assert is <.erre>
;------------------------------------------------------------------------------
; Typedefs. MASMs pointers are offsets in a segment.
; Some of this is to indicate the purpose to the reader rather than MASM,
; ie CHAR v BYTE since both are unsigned 8 bits.
; However, pointerness is worth saying for words containing offsets since
; debugger will take note.
; WORD will tend not to get used since a word is either an integer (USHORT)
; or an offset.
; I haven't yet found the penalty in giving up SHORT as a keyword so as to
; use it in the 'C' sense.
;------------------------------------------------------------------------------
  option nokeyword:<short>
  option nokeyword:<C>
; One byte target:
char   typedef byte
Bool   typedef byte
bytep  typedef ptr byte
charp  typedef ptr byte
charfp  typedef far ptr byte
Boolp  typedef ptr byte
; Two byte
Ushort typedef word
Ushortp typedef ptr word
short typedef sword
shortp typedef ptr sword
Handle typedef word
Handlep typedef ptr word
Segp typedef word; Slightly different sense.
; Four byte
Ulong typedef dword
Farp struc; For les,lds
 Pt charp 0
 Sg Segp 0
Farp ends

;------------------------------------------------------------------------------
; Macros
;------------------------------------------------------------------------------

MkMajMin macro Maj:req, Min:req
 ;; Makes parts of msg number into one number.
 exitm %(256*Maj+Min)
endm

StringOrder macro a:req, b:req, c, d
 ;; Load so that a store puts them in the written order.
 ifnb <d>
  exitm %(256*256*256*(d)+256*256*(c)+256*(b)+(a))
 endif
 exitm %(256*(b)+(a))
endm

; Splat makes a visual 'noise' on the output.
Splat macro It:=<'*'>
 mov dl,It
 mov ah,02h
 int 21h
endm

LoopQ macro tgt:req
;; Faster than single loop instruction
  dec cx
  jnz tgt
endm

JcxzQ macro tgt:req
;; jcxz is written only where retaining flags matters, else JcxzQ
;; JcxzQ can be rendered in way that can do long jump. (And maybe faster)
  test cx,cx
  je tgt
endm

Pos macro Needle:req, Hay:req
 exitm % @InStr(1,Hay,Needle)
endm

; As provided in MASM readme, plus fixing:
 la macro Dest:req, Symbol:req
; This can go wrong because replacement in operand occurs later.
; Page 583 of Waite suggests we can test this but...
 if (opattr(Symbol)) and 20h
   if (opattr(Symbol)) and 08h
     mov Dest, offset Symbol
   else
     lea Dest, Symbol
   endif
 else
   ; Assume MOV if errors
   mov Dest, offset Symbol
 endif
 endm

; Having bp=0 makes a difference to zeroing.
; XOR is no better than MOV of 0, and disturbs flags so this is just shorthand.
; XOR faster than MOV of 0 on some machines?
; Actually XOR is better for accum, but macro can't distinquish accum.
; If Ax is positive CWD is better for DX, but macro doesn't do that.
 z macro Dest:req
; Drop this bit because XOR never better than register move.
     if (type Dest) eq 1
       mov Dest,0
     else
       if (type Dest) eq 2
         mov Dest,bp
       else
         if (type Dest) eq 4
           mov Dest,ebp
         else
           Whoops
         endif
       endif
     endif
 endm

; Illuminate special use of test to set flags.
TestReg macro arg:req
       test arg,arg
endm

; Illuminate pop that discards.
PopJunk  macro arg:req
  pop arg
endm

; Setting bits in records.
; I'm having trouble with MASM. If arg is complicated, it uses two byte
; offsets where one would do. (Cured by overlay of word on record)
; I cannot get MASM to put what I want on the listing. I would like the
; values computed to show in the listed expansion but MASM will only show
; the macro variable names there.  A % at the beginning of the line returned
; by the macro does nothing. A % before the macro variable name in it is seen
; as a syntax error. Short of conditional generation returning lines with
; only the macro arguments in (these do get replaced on the listing), I don't
; see a solution.

On      macro arg:req, flg:req, flg2, flg3, flg4
  local masksum
  ifnb <flg4>
    Need to elaborate
  endif
  masksum = mask flg
  ifnb <flg2>
    masksum=masksum + mask flg2
  endif
  ifnb <flg3>
    masksum=masksum + mask flg3
  endif
  if ((type arg) ne 2) or (low masksum ne 0 and high masksum ne 0)
        or  arg,masksum
  else
    if masksum gt 255
        or  Bptr(arg+1), high masksum
    else
        or  Bptr(arg), low masksum
    endif
  endif
endm
Off     macro arg:req, flg:req, flg2, flg3, flg4
  local masksum
  ifnb <flg4>
    Need to elaborate
  endif
  masksum = mask flg
  ifnb <flg2>
    masksum=masksum + mask flg2
  endif
  ifnb <flg3>
    masksum=masksum + mask flg3
  endif
  if ((type arg) ne 2) or (low masksum ne 0 and high masksum ne 0)
        and arg, not masksum
  else
    if masksum gt 255
        and Bptr(arg+1), high not masksum
    else
        and Bptr(arg), low not masksum
    endif
  endif
endm
Qry     macro arg:req, flg:req, flg2, flg3, flg4
  local masksum
  ifnb <flg4>
    Need to elaborate
  endif
  masksum = mask flg
  ifnb <flg2>
    masksum=masksum + mask flg2
  endif
  ifnb <flg3>
    masksum=masksum + mask flg3
  endif
  if ((type arg) ne 2) or (low masksum ne 0 and high masksum ne 0)
        test arg, masksum
  else
    if masksum gt 255
      if @SizeStr("&arg") gt 4
        test Bptr(arg+1), high masksum
      else
        if "cx" ne "&arg"
          test Bptr(arg+1), high masksum
        else
          test ch, high masksum
        endif
      endif
    else
        test Bptr(arg), low masksum
    endif
  endif
endm

mv   macro To:req,From:req
; Used for segment moves
 push From
 pop To
endm

xax macro To:req
; Used for ax moves when xchg saves a byte. (At expense of cycles)
; Don't use xax form if exchange is "real" exchange.
 if (type To) eq 2
   xchg ax,To
 else
   xchg eax,To
 endif
endm

inc2 macro Subj:req
; Shorter than add Subj,2 when non-acc 16 bit reg.
 inc Subj
 inc Subj
endm

dec2 macro Subj:req
; Shorter than dec Subj,2 when non-acc 16 bit reg.
 dec Subj
 dec Subj
endm

top macro To:req
; Top element of hardware stack without disturbing it.
 pop To
 push To
endm

move macro To:req,From:req,Via
; Memory to memory with arguments in same order as a mov.
 ifb <Via>
  if (type To) eq 2
    mov ax,From
    mov To,ax
  elseif (type To) eq 1
    mov al,From
    mov To,al
  else
    mov eax,From
    mov To,eax
  endif
 else
  mov Via,From
  mov To,Via
 endif
endm

;------------------------------------------------------------------------------
; Shapes of structures for based addressing.
;------------------------------------------------------------------------------
; If we PUSHA and then copy SP to BP the caller's
; registers have become locals accessible on [BP].
; Structure PushShape holds the shape for this.
PushShape struct
 di_ word ?
 si_ word ?
 bp_ word ?
 sp_ word ?
 bx_ word Overlay
 bl_ byte ?
 bh_ byte ?
 dx_ word Overlay
 dl_ byte ?
 dh_ byte ?
 cx_ word Overlay
 cl_ byte ?
 ch_ byte ?
 ax_ word Overlay
 al_ byte ?
 ah_ byte ?
PushShape ends
