Tgt equ 86�$Locals equ 256-Tgt
Arg1 equ 2
Arg2 equ 4
Arg3 equ 6
Arg4 equ 8
Arg5 equ 10
; LocalVars of ARITHOP�NUMBER1 equ -58�NUMBER2 equ -56�OPERATOR equ -54
DIGITS equ -52�TT equ -12�SIGN1 equ -14�MANTISSA1 equ -4�EXPONENT1 equ -16
SIGN2 equ -18�MANTISSA2 equ -20�EXPONENT2 equ -22�NUMBER3 equ -24
MANTISSA3 equ -26�EXPONENT3 equ -8�ZZ equ -2�A_X equ -10�A_Y equ -28
SIGN3 equ -30�NOWDIGITS equ -32�ALIGN1 equ -34�ALIGN2 equ -36
SIGDIGITS equ -6�AA equ -38�INTDIGITS equ -40�RHS equ -42
; LocalVars of PREPARE�NUMBER equ -22�P_DIGITS equ -20�MANTISSA equ -2
EXPONENT equ -8�SIGN equ -4�P_P equ -6�P_Q equ -10�JJ equ -12
P_T equ -14
; LocalVars of _POSTOP
; LocalVars of _FLOATING
; LocalVars of _ADDSUBCOMP
; LocalVars of _MULTIPLY
; LocalVars of _DIVTYPE
; LocalVars of _POWER
; LocalVars of TIME2DATE
; LocalVars of TIME2DATE2�Y_TIME equ -26�Y_SECOND equ -2�Y_MICROSECOND equ -4
Y_MINUTE equ -6�Y_HOUR equ -8�Y_DAY equ -10�Y_BASEDAYS equ -12
Y_YEAR equ -14�Y_YEARDAYS equ -16�Y_DAYS equ -18�Y_MONTH equ -20
Y_THISMONTH equ -22
; LocalVars of LEAP
; LocalVars of RERADIX�RR_SUBJECT equ -2�RR_FROMRADIX equ -8
RR_TORADIX equ -4�RR_INTEGER equ -6�RR_J equ -10�RR_R equ -12
; LocalVars of BIFABBREV�SUBJECT equ -18�SUBJ equ -16�LENGTH_ equ -2
COND1 equ -4�COND2 equ -6�COND3 equ -8
; LocalVars of BIFCENTER�STRING equ -14�C_LENGTH equ -12�PAD equ -2
TRIM equ -4
; LocalVars of BIFCHANGESTR�OUTPUT equ -2�POSITION equ -4�FOUNDPOS equ -6
; LocalVars of BIFCOMPARE�STR1 equ -18�STR2 equ -16�C_PAD equ -2
CO_LENGTH equ -4�C_I equ -6
; LocalVars of BIFCOUNTSTR�C_OUTPUT equ -2�C_POSITION equ -4
; LocalVars of BIFDELSTR�D_STRING equ -18�NUM equ -16�LEN equ -2
D_OUTPUT equ -4
; LocalVars of BIFDELWORD�DW_STRING equ -18�DW_NUM equ -16�DW_LEN equ -2
ENDLEFT equ -6�DW_OUTPUT equ -8�BEGINRIGHT equ -4
; LocalVars of BIFINSERT�NEW equ -20�TARGET equ -18�I_NUM equ -6
I_LENGTH equ -2�I_PAD equ -4
; LocalVars of BIFLASTPOS�NEEDLE equ -16�HAYSTACK equ -14�START equ -2
NEEDLELENGTH equ -4�II equ -6
; LocalVars of BIFOVERLAY�O_NEW equ -20�O_TARGET equ -18�O_NUM equ -6
O_LENGTH equ -2�O_PAD equ -4
; LocalVars of BIFPOS�P_NEEDLE equ -18�P_HAYSTACK equ -16�P_START equ -2
P_I equ -4�O_HAYSTACK equ -6
; LocalVars of BIFRIGHT�R_STRING equ -14�R_LENGTH equ -12�R_PAD equ -2
R_TRIM equ -4
; LocalVars of BIFSPACE�S_STRING equ -18�S_NUM equ -4�S_PAD equ -2
PADDING equ -6�S_OUTPUT equ -8�S_I equ -10
; LocalVars of BIFSTRIP�ST_STRING equ -12�OPTION_ equ -2�UNWANTED equ -4
; LocalVars of BIFSUBWORD�SW_STRING equ -18�SW_NUM equ -16�S_LENGTH equ -2
S_START equ -6�END_ equ -4�SW_OUTPUT equ -8
; LocalVars of BIFTRANSLATE�T_STRING equ -24�TABLEI equ -4�TABLEO equ -2
T_PAD equ -6�T_OUTPUT equ -8�T_J equ -10�T_C equ -12�KK equ -14
; LocalVars of BIFVERIFY�V_STRING equ -32�REFERENCE equ -30
V_OPTION equ -12�V_START equ -2�LAST equ -4�V_I equ -6�V_T equ -8
; LocalVars of BIFWORD
; LocalVars of BIFWORDINDEX�W_STRING equ -12�W_NUM equ -10�W_START equ -2
COUNT equ -4
; LocalVars of BIFWORDLENGTH
; LocalVars of BIFWORDPOS�PHRASE equ -18�WP_STRING equ -16�R_START equ -2
PHRASEWORDS equ -4�STRINGWORDS equ -6�WORDNUMBER equ -8
; LocalVars of BIFWORDS�S_PART equ -6�S_COUNT equ -2
; LocalVars of BIFFORMAT�BEFORE equ -12�AFTER equ -14�EXPP equ -16
EXPT equ -18�F_NUMBER equ -22�F_MANTISSA equ -2�F_EXPONENT equ -8
F_SIGN equ -24�BEFO equ -26�AFTE equ -28�POINT equ -10�SHOWEXP equ -30
AFTERS equ -32�F_R equ -4�MANTLEN equ -34�TRIGGERED equ -6�F_Z equ -20
DIGIT equ -36�EXPART equ -38�SIGNEXP equ -40
; LocalVars of BIFMAX�NEXT equ -2�MAX equ -4�I_M equ -6
; LocalVars of BIFMIN�_NEXT equ -2�MIN equ -4�I_N equ -6
; LocalVars of BIFTRUNC�T_NUMBER equ -12�T_NUM equ -2�T_INTEGER equ -4
T_T equ -6
; LocalVars of BIFERRORTEXT�MSGCODE equ -2�E_OPTION equ -12
MAJOR equ -4�MINOR equ -6
; LocalVars of BIFB2X�B_STRING equ -2
; LocalVars of BIFBITAND�STRING1 equ -24�STRING2 equ -2�B_T equ -4
B_R equ -6�B_J equ -8�B1 equ -10�B2 equ -12
; LocalVars of BIFC2D�C_MAX equ -2�SIZE_ equ -6�C_T equ -4�C_SIGN equ -8
; LocalVars of BIFC2X
; LocalVars of BIFD2C�D_SUBJECT equ -2�D_R equ -4�D_LENGTH equ -6
DC_OUTPUT equ -8
; LocalVars of BIFD2X�X_SUBJECT equ -2�X_R equ -4
; LocalVars of BIFX2B�XB_SUBJECT equ -8
; LocalVars of BIFX2C�XC_SUBJECT equ -8�XC_R equ -2�XC_LENGTH equ -4
; LocalVars of BIFX2D�XD_MAX equ -2�XD_SUBJECT equ -4�XD_R equ -6
SIGNBIT equ -8
; LocalVars of BIFCHARIN�C_COUNT equ -2�MODE equ -4�C_R equ -6
; LocalVars of BIFCHAROUT�C_STRING equ -2�O_MODE equ -4�STRIDE equ -6
RESIDUE equ -8�CURSOR equ -10�PIECE equ -12
; LocalVars of BIFCHARS�H_OPTION equ -2
; LocalVars of BIFLINEIN�L_COUNT equ -2
; LocalVars of BIFLINEOUT
; LocalVars of BIFLINES�N_OPTION equ -2
; LocalVars of BIFQUALIFY
; LocalVars of BIFSTREAM�OPERATION equ -2
; LocalVars of BIFDATE�D_OPTION equ -2�VALUE equ -10�INOPTION equ -12
LOGIC equ -20�DAY equ -16�MONTHIS equ -22�YEAR equ -4�MONTH equ -14
YY equ -24�YEARNOW equ -26�DAYS equ -6�BASEDAYS equ -8�MICRO equ -18
; LocalVars of DATEFORMAT�D_YEAR equ -6�D_MONTH equ -2�D_DAY equ -4
D_HOUR equ -8�D_MINUTE equ -10�D_SECOND equ -12�D_MICROSECOND equ -14
D_BASE equ -16�D_DAYS equ -18
; LocalVars of BIFTIME�T_OPTION equ -2�INVALUE equ -10�T_INOPTION equ -12
HH equ -6�MM equ -16�SS_ equ -4�HOURADJUST equ -8�XX equ -14
T_MICRO equ -18
; LocalVars of TIMEFORMAT�T_HOUR equ -6�T_MINUTE equ -2�T_SECOND equ -4
T_MICROSECOND equ -8�TF_OUTPUT equ -10
; LocalVars of DOS_TIME�TV equ -18�DT_YEAR equ -4�DT_MONTH equ -14
DT_DAY equ -16�DT_DAYS equ -6�DT_BASEDAYS equ -8
; LocalVars of B4VALUE1
; LocalVars of B4VALUE2�B4V equ -2
; LocalVars of B4DROP
; LocalVars of B4EXPOSE
; LocalVars of STREAMQUALIFY�Q_T equ -2�Q_DRIVE equ -10�Q_J equ -4
Q_NAME equ -6�Q_PATH equ -8
; LocalVars of PATHQUALIFY�PQ_T equ -2�PQ_HAVEENV equ -12�PQ_DRIVE equ -10
PQ_J equ -4�PQ_NAME equ -6�PQ_PATH equ -8�PQ_EXTEN equ -14�PQ_EXISTS equ -16
PQ_LETTER equ -18�PQ_PREFIX equ -20�PQ_DIR equ -22�PQ_R equ -24
PQ_REST equ -26
; LocalVars of LINESPLIT�LS_T equ -8�LS_N equ -2�LS_P equ -4
; LocalVars of COMMANDWRAP�CW_T equ -2
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
