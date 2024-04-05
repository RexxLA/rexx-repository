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
 db "ARG"údb $BifTag+$BifARG
 db "B2X"údb $BifTag+$BifB2X
 db "C2D"údb $BifTag+$BifC2D
 db "C2X"údb $BifTag+$BifC2X
 db "D2C"údb $BifTag+$BifD2C
 db "D2X"údb $BifTag+$BifD2X
 db "X2B"údb $BifTag+$BifX2B
 db "X2C"údb $BifTag+$BifX2C
 db "X2D"údb $BifTag+$BifX2D
 db "POS"údb $BifTag+$BifPOS
 db "ABS"údb $BifTag+$BifABS
 db "MAX"údb $BifTag+$BifMAX
 db "MIN"údb $BifTag+$BifMIN
Bifs4:
 db "SIGN"údb $BifTag+$BifSIGN
 db "LEFT"údb $BifTag+$BifLEFT
 db "WORD"údb $BifTag+$BifWORD
 db "FORM"údb $BifTag+$BifFORM
 db "FUZZ"údb $BifTag+$BifFUZZ
 db "DATE"údb $BifTag+$BifDATE
 db "TIME"údb $BifTag+$BifTIME
Bifs5:
 db "RIGHT"údb $BifTag+$BifRIGHT
 db "SPACE"údb $BifTag+$BifSPACE
 db "STRIP"údb $BifTag+$BifSTRIP
 db "WORDS"údb $BifTag+$BifWORDS
 db "TRUNC"údb $BifTag+$BifTRUNC
 db "TRACE"údb $BifTag+$BifTRACE
 db "BITOR"údb $BifTag+$BifBITOR
 db "CHARS"údb $BifTag+$BifCHARS
 db "LINES"údb $BifTag+$BifLINES
 db "VALUE"údb $BifTag+$BifVALUE
Bifs6:
 db "ABBREV"údb $BifTag+$BifABBREV
 db "DIGITS"údb $BifTag+$BifDIGITS
 db "CENTER"údb $BifTag+$BifCENTER
 db "CENTRE"údb $BifTag+$BifCENTRE
 db "COPIES"údb $BifTag+$BifCOPIES
 db "DELSTR"údb $BifTag+$BifDELSTR
 db "INSERT"údb $BifTag+$BifINSERT
 db "LENGTH"údb $BifTag+$BifLENGTH
 db "SUBSTR"údb $BifTag+$BifSUBSTR
 db "VERIFY"údb $BifTag+$BifVERIFY
 db "STREAM"údb $BifTag+$BifSTREAM
 db "QUEUED"údb $BifTag+$BifQUEUED
 db "RANDOM"údb $BifTag+$BifRANDOM
 db "XRANGE"údb $BifTag+$BifXRANGE
 db "FORMAT"údb $BifTag+$BifFORMAT
 db "BITAND"údb $BifTag+$BifBITAND
 db "BITXOR"údb $BifTag+$BifBITXOR
 db "CHARIN"údb $BifTag+$BifCHARIN
 db "LINEIN"údb $BifTag+$BifLINEIN
 db "SYMBOL"údb $BifTag+$BifSYMBOL
Bifs7:
 db "COMPARE"údb $BifTag+$BifCOMPARE
 db "DELWORD"údb $BifTag+$BifDELWORD
 db "LASTPOS"údb $BifTag+$BifLASTPOS
 db "OVERLAY"údb $BifTag+$BifOVERLAY
 db "REVERSE"údb $BifTag+$BifREVERSE
 db "SUBWORD"údb $BifTag+$BifSUBWORD
 db "WORDPOS"údb $BifTag+$BifWORDPOS
 db "ADDRESS"údb $BifTag+$BifADDRESS
 db "CHAROUT"údb $BifTag+$BifCHAROUT
 db "LINEOUT"údb $BifTag+$BifLINEOUT
 db "QUALIFY"údb $BifTag+$BifQUALIFY
Bifs8:
 db "COUNTSTR"údb $BifTag+$BifCOUNTSTR
 db "DATATYPE"údb $BifTag+$BifDATATYPE
Bifs9:
 db "TRANSLATE"údb $BifTag+$BifTRANSLATE
 db "WORDINDEX"údb $BifTag+$BifWORDINDEX
 db "CHANGESTR"údb $BifTag+$BifCHANGESTR
 db "CONDITION"údb $BifTag+$BifCONDITION
 db "ERRORTEXT"údb $BifTag+$BifERRORTEXT
Bifs10:
 db "WORDLENGTH"údb $BifTag+$BifWORDLENGTH
 db "SOURCELINE"údb $BifTag+$BifSOURCELINE
Bifs11:
endif
