;------------------------------------------------------------------------------
; Table that picks up a byte of data on the latest character.
;------------------------------------------------------------------------------
if Solid
Attributes:
  byte 256 dup($Special+$Invalid); Default
; Ignored whitespace. Linefeed is active whitespace
  org Attributes+9úbyte $White; HT
  org Attributes+11úbyte $Whiteúbyte $Whiteúbyte $White; VT FF CR
  org Attributes+' 'úbyte $White
; Letters
  org Attributes+'#'úbyte $Letter+$NonUpable
  org Attributes+'$'úbyte $Letter+$NonUpable
  org Attributes+'@'úbyte $Letter+$NonUpable
  org Attributes+'!'úbyte $Letter+$NonUpable
  org Attributes+'?'úbyte $Letter+$NonUpable
  org Attributes+'_'úbyte $Letter+$NonUpable
  org Attributes+'A'úbyte $Letter+$NonUpable+$OKx
  org Attributes+'B'úbyte $Letter+$NonUpable+$Bb+$OKx
  org Attributes+'C'úbyte 2 dup($Letter+$NonUpable+$OKx)
  org Attributes+'E'úbyte $Letter+$NonUpable+$Ee+$OKx
  org Attributes+'F'úbyte $Letter+$NonUpable+$OKx
  org Attributes+'G'úbyte 17 dup($Letter+$NonUpable)
  org Attributes+'X'úbyte $Letter+$NonUpable+$Xx
  org Attributes+'Y'úbyte 2 dup($Letter+$NonUpable)
  org Attributes+'a'úbyte $Letter+$OKx
  org Attributes+'b'úbyte $Letter+$Bb+$OKx
  org Attributes+'c'úbyte 2 dup($Letter+$OKx)
  org Attributes+'e'úbyte $Letter+$Ee+$OKx
  org Attributes+'f'úbyte $Letter+$OKx
  org Attributes+'g'úbyte 17 dup($Letter)
  org Attributes+'x'úbyte $Letter+$Xx
  org Attributes+'y'úbyte 2 dup($Letter)
; Constant starts.
  org Attributes+'0'úbyte $Digit+$OKb+$OKx
  org Attributes+'1'úbyte $Digit+$OKb+$OKx+1
  org Attributes+'2'úbyte $Digit+$OKx+2
  org Attributes+'3'úbyte $Digit+$OKx+3
  org Attributes+'4'úbyte $Digit+$OKx+4
  org Attributes+'5'úbyte $Digit+$OKx+5
  org Attributes+'6'úbyte $Digit+$OKx+6
  org Attributes+'7'úbyte $Digit+$OKx+7
  org Attributes+'8'úbyte $Digit+$OKx+8
  org Attributes+'9'úbyte $Digit+$OKx+9
; Dot is special in a template but can be part of a number, or a reserved.
; I have tried as digit, as special, as letter, and least bad is letter, maybe.
  org Attributes+"."úbyte $Letter+$NonUpable
  org Attributes+':'úbyte $Special+$Colon
; Specials, see also SpSwitch.
; These match initial groups.inc
  org Attributes+$Eofúbyte $Special+$Eos
  org Attributes+';'úbyte $Special+$Semi
  org Attributes+'('úbyte $Special+$Lparen
  org Attributes+')'úbyte $Special+$Rparen
  org Attributes+'%'úbyte $Special+$Percent
  org Attributes+'-'úbyte $Special+$Minus
  org Attributes+"="úbyte $Special+$Eq
  org Attributes+"'"úbyte $Special+$STRING
  org Attributes+'"'úbyte $Special+$STRING
  org Attributes+"<"úbyte $Special+$Lt
  org Attributes+'\'úbyte $Special+$Not
  org Attributes+"|"úbyte $Special+$Or
  org Attributes+"&"úbyte $Special+$And
  org Attributes+">"úbyte $Special+$Gt
  org Attributes+"/"úbyte $Special+$Slash
  org Attributes+","úbyte $Special+$Comma
  org Attributes+$Lfúbyte $Special+$LineFeed
  org Attributes+"+"úbyte $Special+$Plus
  org Attributes+"*"úbyte $Special+$Asterisk
  org Attributes+256; Attributes end
endif
