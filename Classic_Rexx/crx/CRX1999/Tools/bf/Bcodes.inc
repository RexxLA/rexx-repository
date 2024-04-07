Tgt equ 86ú$Locals equ 256-Tgt
Arg1 equ 2
Arg2 equ 4
Arg3 equ 6
Arg4 equ 8
Arg5 equ 10
; LocalVars of ARITHOPúNUMBER1 equ -58úNUMBER2 equ -56úOPERATOR equ -54
DIGITS equ -52úTT equ -12úSIGN1 equ -14úMANTISSA1 equ -4úEXPONENT1 equ -16
SIGN2 equ -18úMANTISSA2 equ -20úEXPONENT2 equ -22úNUMBER3 equ -24
MANTISSA3 equ -26úEXPONENT3 equ -8úZZ equ -2úA_X equ -10úA_Y equ -28
SIGN3 equ -30úNOWDIGITS equ -32úALIGN1 equ -34úALIGN2 equ -36
SIGDIGITS equ -6úAA equ -38úINTDIGITS equ -40úRHS equ -42
; LocalVars of PREPAREúNUMBER equ -22úP_DIGITS equ -20úMANTISSA equ -2
EXPONENT equ -8úSIGN equ -4úP_P equ -6úP_Q equ -10úJJ equ -12
P_T equ -14
; LocalVars of _POSTOP
; LocalVars of _FLOATING
; LocalVars of _ADDSUBCOMP
; LocalVars of _MULTIPLY
; LocalVars of _DIVTYPE
; LocalVars of _POWER
; LocalVars of TIME2DATE
; LocalVars of TIME2DATE2úY_TIME equ -26úY_SECOND equ -2úY_MICROSECOND equ -4
Y_MINUTE equ -6úY_HOUR equ -8úY_DAY equ -10úY_BASEDAYS equ -12
Y_YEAR equ -14úY_YEARDAYS equ -16úY_DAYS equ -18úY_MONTH equ -20
Y_THISMONTH equ -22
; LocalVars of LEAP
; LocalVars of RERADIXúRR_SUBJECT equ -2úRR_FROMRADIX equ -8
RR_TORADIX equ -4úRR_INTEGER equ -6úRR_J equ -10úRR_R equ -12
; LocalVars of BIFABBREVúSUBJECT equ -18úSUBJ equ -16úLENGTH_ equ -2
COND1 equ -4úCOND2 equ -6úCOND3 equ -8
; LocalVars of BIFCENTERúSTRING equ -14úC_LENGTH equ -12úPAD equ -2
TRIM equ -4
; LocalVars of BIFCHANGESTRúOUTPUT equ -2úPOSITION equ -4úFOUNDPOS equ -6
; LocalVars of BIFCOMPAREúSTR1 equ -18úSTR2 equ -16úC_PAD equ -2
CO_LENGTH equ -4úC_I equ -6
; LocalVars of BIFCOUNTSTRúC_OUTPUT equ -2úC_POSITION equ -4
; LocalVars of BIFDELSTRúD_STRING equ -18úNUM equ -16úLEN equ -2
D_OUTPUT equ -4
; LocalVars of BIFDELWORDúDW_STRING equ -18úDW_NUM equ -16úDW_LEN equ -2
ENDLEFT equ -6úDW_OUTPUT equ -8úBEGINRIGHT equ -4
; LocalVars of BIFINSERTúNEW equ -20úTARGET equ -18úI_NUM equ -6
I_LENGTH equ -2úI_PAD equ -4
; LocalVars of BIFLASTPOSúNEEDLE equ -16úHAYSTACK equ -14úSTART equ -2
NEEDLELENGTH equ -4úII equ -6
; LocalVars of BIFOVERLAYúO_NEW equ -20úO_TARGET equ -18úO_NUM equ -6
O_LENGTH equ -2úO_PAD equ -4
; LocalVars of BIFPOSúP_NEEDLE equ -18úP_HAYSTACK equ -16úP_START equ -2
P_I equ -4úO_HAYSTACK equ -6
; LocalVars of BIFRIGHTúR_STRING equ -14úR_LENGTH equ -12úR_PAD equ -2
R_TRIM equ -4
; LocalVars of BIFSPACEúS_STRING equ -18úS_NUM equ -4úS_PAD equ -2
PADDING equ -6úS_OUTPUT equ -8úS_I equ -10
; LocalVars of BIFSTRIPúST_STRING equ -12úOPTION_ equ -2úUNWANTED equ -4
; LocalVars of BIFSUBWORDúSW_STRING equ -18úSW_NUM equ -16úS_LENGTH equ -2
S_START equ -6úEND_ equ -4úSW_OUTPUT equ -8
; LocalVars of BIFTRANSLATEúT_STRING equ -24úTABLEI equ -4úTABLEO equ -2
T_PAD equ -6úT_OUTPUT equ -8úT_J equ -10úT_C equ -12úKK equ -14
; LocalVars of BIFVERIFYúV_STRING equ -32úREFERENCE equ -30
V_OPTION equ -12úV_START equ -2úLAST equ -4úV_I equ -6úV_T equ -8
; LocalVars of BIFWORD
; LocalVars of BIFWORDINDEXúW_STRING equ -12úW_NUM equ -10úW_START equ -2
COUNT equ -4
; LocalVars of BIFWORDLENGTH
; LocalVars of BIFWORDPOSúPHRASE equ -18úWP_STRING equ -16úR_START equ -2
PHRASEWORDS equ -4úSTRINGWORDS equ -6úWORDNUMBER equ -8
; LocalVars of BIFWORDSúS_PART equ -6úS_COUNT equ -2
; LocalVars of BIFFORMATúBEFORE equ -12úAFTER equ -14úEXPP equ -16
EXPT equ -18úF_NUMBER equ -22úF_MANTISSA equ -2úF_EXPONENT equ -8
F_SIGN equ -24úBEFO equ -26úAFTE equ -28úPOINT equ -10úSHOWEXP equ -30
AFTERS equ -32úF_R equ -4úMANTLEN equ -34úTRIGGERED equ -6úF_Z equ -20
DIGIT equ -36úEXPART equ -38úSIGNEXP equ -40
; LocalVars of BIFMAXúNEXT equ -2úMAX equ -4úI_M equ -6
; LocalVars of BIFMINú_NEXT equ -2úMIN equ -4úI_N equ -6
; LocalVars of BIFTRUNCúT_NUMBER equ -12úT_NUM equ -2úT_INTEGER equ -4
T_T equ -6
; LocalVars of BIFERRORTEXTúMSGCODE equ -2úE_OPTION equ -12
MAJOR equ -4úMINOR equ -6
; LocalVars of BIFB2XúB_STRING equ -2
; LocalVars of BIFBITANDúSTRING1 equ -24úSTRING2 equ -2úB_T equ -4
B_R equ -6úB_J equ -8úB1 equ -10úB2 equ -12
; LocalVars of BIFC2DúC_MAX equ -2úSIZE_ equ -6úC_T equ -4úC_SIGN equ -8
; LocalVars of BIFC2X
; LocalVars of BIFD2CúD_SUBJECT equ -2úD_R equ -4úD_LENGTH equ -6
DC_OUTPUT equ -8
; LocalVars of BIFD2XúX_SUBJECT equ -2úX_R equ -4
; LocalVars of BIFX2BúXB_SUBJECT equ -8
; LocalVars of BIFX2CúXC_SUBJECT equ -8úXC_R equ -2úXC_LENGTH equ -4
; LocalVars of BIFX2DúXD_MAX equ -2úXD_SUBJECT equ -4úXD_R equ -6
SIGNBIT equ -8
; LocalVars of BIFCHARINúC_COUNT equ -2úMODE equ -4úC_R equ -6
; LocalVars of BIFCHAROUTúC_STRING equ -2úO_MODE equ -4úSTRIDE equ -6
RESIDUE equ -8úCURSOR equ -10úPIECE equ -12
; LocalVars of BIFCHARSúH_OPTION equ -2
; LocalVars of BIFLINEINúL_COUNT equ -2
; LocalVars of BIFLINEOUT
; LocalVars of BIFLINESúN_OPTION equ -2
; LocalVars of BIFQUALIFY
; LocalVars of BIFSTREAMúOPERATION equ -2
; LocalVars of BIFDATEúD_OPTION equ -2úVALUE equ -10úINOPTION equ -12
LOGIC equ -20úDAY equ -16úMONTHIS equ -22úYEAR equ -4úMONTH equ -14
YY equ -24úYEARNOW equ -26úDAYS equ -6úBASEDAYS equ -8úMICRO equ -18
; LocalVars of DATEFORMATúD_YEAR equ -6úD_MONTH equ -2úD_DAY equ -4
D_HOUR equ -8úD_MINUTE equ -10úD_SECOND equ -12úD_MICROSECOND equ -14
D_BASE equ -16úD_DAYS equ -18
; LocalVars of BIFTIMEúT_OPTION equ -2úINVALUE equ -10úT_INOPTION equ -12
HH equ -6úMM equ -16úSS_ equ -4úHOURADJUST equ -8úXX equ -14
T_MICRO equ -18
; LocalVars of TIMEFORMATúT_HOUR equ -6úT_MINUTE equ -2úT_SECOND equ -4
T_MICROSECOND equ -8úTF_OUTPUT equ -10
; LocalVars of DOS_TIMEúTV equ -18úDT_YEAR equ -4úDT_MONTH equ -14
DT_DAY equ -16úDT_DAYS equ -6úDT_BASEDAYS equ -8
; LocalVars of B4VALUE1
; LocalVars of B4VALUE2úB4V equ -2
; LocalVars of B4DROP
; LocalVars of B4EXPOSE
; LocalVars of STREAMQUALIFYúQ_T equ -2úQ_DRIVE equ -10úQ_J equ -4
Q_NAME equ -6úQ_PATH equ -8
; LocalVars of PATHQUALIFYúPQ_T equ -2úPQ_HAVEENV equ -12úPQ_DRIVE equ -10
PQ_J equ -4úPQ_NAME equ -6úPQ_PATH equ -8úPQ_EXTEN equ -14úPQ_EXISTS equ -16
PQ_LETTER equ -18úPQ_PREFIX equ -20úPQ_DIR equ -22úPQ_R equ -24
PQ_REST equ -26
; LocalVars of LINESPLITúLS_T equ -8úLS_N equ -2úLS_P equ -4
; LocalVars of COMMANDWRAPúCW_T equ -2
ARITHOP equ $RoutineBase+0
PREPARE equ $RoutineBase+2
_MULTIPLY equ $RoutineBase+4
_DIVTYPE equ $RoutineBase+6
_POWER equ $RoutineBase+8
_ADDSUBCOMP equ $RoutineBase+10
_POSTOP equ $RoutineBase+12
_FLOATING equ $RoutineBase+14
TIME2DATE equ $RoutineBase+16
TIME2DATE2 equ $RoutineBase+18
LEAP equ $RoutineBase+20
RERADIX equ $RoutineBase+22
DOS_TIME equ $RoutineBase+24
DATEFORMAT equ $RoutineBase+26
TIMEFORMAT equ $RoutineBase+28

Frag1 equ $BPcodesCeil+0
Frag2 equ $BPcodesCeil+2
Frag3 equ $BPcodesCeil+4
Frag4 equ $BPcodesCeil+6
Frag5 equ $BPcodesCeil+8
Frag6 equ $BPcodesCeil+10
Frag7 equ $BPcodesCeil+12
Frag8 equ $BPcodesCeil+14
Frag9 equ $BPcodesCeil+16
Frag10 equ $BPcodesCeil+18
Frag11 equ $BPcodesCeil+20
Frag12 equ $BPcodesCeil+22
Frag13 equ $BPcodesCeil+24
Frag14 equ $BPcodesCeil+26
Frag15 equ $BPcodesCeil+28
Frag16 equ $BPcodesCeil+30
Frag17 equ $BPcodesCeil+32
Frag18 equ $BPcodesCeil+34
Frag19 equ $BPcodesCeil+36
Frag20 equ $BPcodesCeil+38
Frag21 equ $BPcodesCeil+40
Frag22 equ $BPcodesCeil+42
Frag23 equ $BPcodesCeil+44
Frag24 equ $BPcodesCeil+46
Frag25 equ $BPcodesCeil+48
Frag26 equ $BPcodesCeil+50
Frag27 equ $BPcodesCeil+52
Frag28 equ $BPcodesCeil+54
