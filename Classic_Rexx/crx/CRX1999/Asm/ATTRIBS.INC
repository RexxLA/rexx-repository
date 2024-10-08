;------------------------------------------------------------------------------
; Table that picks up a byte of data on the latest character.
;------------------------------------------------------------------------------
if Solid
Attributes:
  byte 256 dup($Special+$Invalid); Default
; Ignored whitespace. Linefeed is active whitespace
  org Attributes+9�byte $White; HT
  org Attributes+11�byte $White�byte $White�byte $White; VT FF CR
  org Attributes+' '�byte $White
; Letters
  org Attributes+'#'�byte $Letter+$NonUpable
  org Attributes+'$'�byte $Letter+$NonUpable
  org Attributes+'@'�byte $Letter+$NonUpable
  org Attributes+'!'�byte $Letter+$NonUpable
  org Attributes+'?'�byte $Letter+$NonUpable
  org Attributes+'_'�byte $Letter+$NonUpable
  org Attributes+'A'�byte $Letter+$NonUpable+$OKx
  org Attributes+'B'�byte $Letter+$NonUpable+$Bb+$OKx
  org Attributes+'C'�byte 2 dup($Letter+$NonUpable+$OKx)
  org Attributes+'E'�byte $Letter+$NonUpable+$Ee+$OKx
  org Attributes+'F'�byte $Letter+$NonUpable+$OKx
  org Attributes+'G'�byte 17 dup($Letter+$NonUpable)
  org Attributes+'X'�byte $Letter+$NonUpable+$Xx
  org Attributes+'Y'�byte 2 dup($Letter+$NonUpable)
  org Attributes+'a'�byte $Letter+$OKx
  org Attributes+'b'�byte $Letter+$Bb+$OKx
  org Attributes+'c'�byte 2 dup($Letter+$OKx)
  org Attributes+'e'�byte $Letter+$Ee+$OKx
  org Attributes+'f'�byte $Letter+$OKx
  org Attributes+'g'�byte 17 dup($Letter)
  org Attributes+'x'�byte $Letter+$Xx
  org Attributes+'y'�byte 2 dup($Letter)
; Constant starts.
  org Attributes+'0'�byte $Digit+$OKb+$OKx
  org Attributes+'1'�byte $Digit+$OKb+$OKx+1
  org Attributes+'2'�byte $Digit+$OKx+2
  org Attributes+'3'�byte $Digit+$OKx+3
  org Attributes+'4'�byte $Digit+$OKx+4
  org Attributes+'5'�byte $Digit+$OKx+5
  org Attributes+'6'�byte $Digit+$OKx+6
  org Attributes+'7'�byte $Digit+$OKx+7
  org Attributes+'8'�byte $Digit+$OKx+8
  org Attributes+'9'�byte $Digit+$OKx+9
; Dot is special in a template but can be part of a number, or a reserved.
; I have tried as digit, as special, as letter, and least bad is letter, maybe.
  org Attributes+"."�byte $Letter+$NonUpable
  org Attributes+':'�byte $Special+$Colon
; Specials, see also SpSwitch.
; These match initial groups.inc
  org Attributes+$Eof�byte $Special+$Eos
  org Attributes+';'�byte $Special+$Semi
  org Attributes+'('�byte $Special+$Lparen
  org Attributes+')'�byte $Special+$Rparen
  org Attributes+'%'�byte $Special+$Percent
  org Attributes+'-'�byte $Special+$Minus
  org Attributes+"="�byte $Special+$Eq
  org Attributes+"'"�byte $Special+$STRING
  org Attributes+'"'�byte $Special+$STRING
  org Attributes+"<"�byte $Special+$Lt
  org Attributes+'\'�byte $Special+$Not
  org Attributes+"|"�byte $Special+$Or
  org Attributes+"&"�byte $Special+$And
  org Attributes+">"�byte $Special+$Gt
  org Attributes+"/"�byte $Special+$Slash
  org Attributes+","�byte $Special+$Comma
  org Attributes+$Lf�byte $Special+$LineFeed
  org Attributes+"+"�byte $Special+$Plus
  org Attributes+"*"�byte $Special+$Asterisk
  org Attributes+256; Attributes end
endif
