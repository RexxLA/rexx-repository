comment~ The bifs are recognized on first sight by their names.  (And a restart
made if name subsequently attached to user routine.) This allows the "number of
parameters" check to be moved away from execution time, although raising of
SYNTAX has to be compiled since message cannot be emitted until execution.

It also allows the Pcode to be more compact than for an ordinary
invocation. $pBif can have a byte of argument that covers both the
number of the bif and the number of parameters (usually).

~
if Solid
; Firstly the names, grouped by length for efficient lookup.
Bifs:
 dw Bifs3
 dw Bifs4
 dw Bifs5
 dw Bifs6
 dw Bifs7
 dw Bifs8
 dw Bifs9
 dw Bifs10
 dw Bifs11
BifNames:
Bifs3:
 db "ARG"�db $BifTag+$BifARG
 db "B2X"�db $BifTag+$BifB2X
 db "C2D"�db $BifTag+$BifC2D
 db "C2X"�db $BifTag+$BifC2X
 db "D2C"�db $BifTag+$BifD2C
 db "D2X"�db $BifTag+$BifD2X
 db "X2B"�db $BifTag+$BifX2B
 db "X2C"�db $BifTag+$BifX2C
 db "X2D"�db $BifTag+$BifX2D
 db "POS"�db $BifTag+$BifPOS
 db "ABS"�db $BifTag+$BifABS
 db "MAX"�db $BifTag+$BifMAX
 db "MIN"�db $BifTag+$BifMIN
Bifs4:
 db "SIGN"�db $BifTag+$BifSIGN
 db "LEFT"�db $BifTag+$BifLEFT
 db "WORD"�db $BifTag+$BifWORD
 db "FORM"�db $BifTag+$BifFORM
 db "FUZZ"�db $BifTag+$BifFUZZ
 db "DATE"�db $BifTag+$BifDATE
 db "TIME"�db $BifTag+$BifTIME
Bifs5:
 db "RIGHT"�db $BifTag+$BifRIGHT
 db "SPACE"�db $BifTag+$BifSPACE
 db "STRIP"�db $BifTag+$BifSTRIP
 db "WORDS"�db $BifTag+$BifWORDS
 db "TRUNC"�db $BifTag+$BifTRUNC
 db "TRACE"�db $BifTag+$BifTRACE
 db "BITOR"�db $BifTag+$BifBITOR
 db "CHARS"�db $BifTag+$BifCHARS
 db "LINES"�db $BifTag+$BifLINES
 db "VALUE"�db $BifTag+$BifVALUE
Bifs6:
 db "ABBREV"�db $BifTag+$BifABBREV
 db "DIGITS"�db $BifTag+$BifDIGITS
 db "CENTER"�db $BifTag+$BifCENTER
 db "CENTRE"�db $BifTag+$BifCENTRE
 db "COPIES"�db $BifTag+$BifCOPIES
 db "DELSTR"�db $BifTag+$BifDELSTR
 db "INSERT"�db $BifTag+$BifINSERT
 db "LENGTH"�db $BifTag+$BifLENGTH
 db "SUBSTR"�db $BifTag+$BifSUBSTR
 db "VERIFY"�db $BifTag+$BifVERIFY
 db "STREAM"�db $BifTag+$BifSTREAM
 db "QUEUED"�db $BifTag+$BifQUEUED
 db "RANDOM"�db $BifTag+$BifRANDOM
 db "XRANGE"�db $BifTag+$BifXRANGE
 db "FORMAT"�db $BifTag+$BifFORMAT
 db "BITAND"�db $BifTag+$BifBITAND
 db "BITXOR"�db $BifTag+$BifBITXOR
 db "CHARIN"�db $BifTag+$BifCHARIN
 db "LINEIN"�db $BifTag+$BifLINEIN
 db "SYMBOL"�db $BifTag+$BifSYMBOL
Bifs7:
 db "COMPARE"�db $BifTag+$BifCOMPARE
 db "DELWORD"�db $BifTag+$BifDELWORD
 db "LASTPOS"�db $BifTag+$BifLASTPOS
 db "OVERLAY"�db $BifTag+$BifOVERLAY
 db "REVERSE"�db $BifTag+$BifREVERSE
 db "SUBWORD"�db $BifTag+$BifSUBWORD
 db "WORDPOS"�db $BifTag+$BifWORDPOS
 db "ADDRESS"�db $BifTag+$BifADDRESS
 db "CHAROUT"�db $BifTag+$BifCHAROUT
 db "LINEOUT"�db $BifTag+$BifLINEOUT
 db "QUALIFY"�db $BifTag+$BifQUALIFY
Bifs8:
 db "COUNTSTR"�db $BifTag+$BifCOUNTSTR
 db "DATATYPE"�db $BifTag+$BifDATATYPE
Bifs9:
 db "TRANSLATE"�db $BifTag+$BifTRANSLATE
 db "WORDINDEX"�db $BifTag+$BifWORDINDEX
 db "CHANGESTR"�db $BifTag+$BifCHANGESTR
 db "CONDITION"�db $BifTag+$BifCONDITION
 db "ERRORTEXT"�db $BifTag+$BifERRORTEXT
Bifs10:
 db "WORDLENGTH"�db $BifTag+$BifWORDLENGTH
 db "SOURCELINE"�db $BifTag+$BifSOURCELINE
Bifs11:
endif
