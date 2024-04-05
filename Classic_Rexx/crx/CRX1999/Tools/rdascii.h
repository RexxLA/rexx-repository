/* syascii.h  */
/* The defines say what the character is to be translated to. */
#define _LETTER '\x01'
#define _SPECIAL '\x02'
#define _WHITE '\x03'
#define _QUOTE '\x04'
#define _SLASH '\x05'
#define _ADIGIT '\x06'
#define _ '\xFF'
/* Note period treated as letter. */
/* Microsoft 'C' book says 0x09 to 0x0d as whitspace. */
/* We need period as letter for the utilities but not for "Tidy" which is
REXX rules. */
static char Translate[]={
 /* 000 */ _,_,_,_,_,_,_,_,_,_WHITE,
 /* 010 */ /*lf*/_WHITE,_WHITE,_WHITE,/*cr*/_WHITE,_,_,_,_,_,_,
 /* 020 */ _,_,_,_,_,_,_,_,_,_,
 /* 030 */ _,_,/* */_WHITE,_,/*"*/_QUOTE,_,_,_,_,/*'*/_QUOTE,
 /* 040 */ /*(*/_SPECIAL,/*)*/_SPECIAL,_,/*+*/_SPECIAL,_,_,/*.*/_LETTER,/*/*/_SLASH,_ADIGIT,_ADIGIT,
 /* 050 */ _ADIGIT,_ADIGIT,_ADIGIT,_ADIGIT,_ADIGIT,_ADIGIT,_ADIGIT,_ADIGIT,/*:*/_SPECIAL,/*;*/_SPECIAL,
 /* 060 */ /*<*/_SPECIAL,/*=*/_SPECIAL,/*>*/_SPECIAL,_,_,/*A*/_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,
 /* 070 */ _LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,
 /* 080 */ _LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,
 /* 090 */ _LETTER,/*[*/_SPECIAL,_,/*]*/_SPECIAL,_,/*_*/_LETTER,_,/*a*/_LETTER,_LETTER,_LETTER,
 /* 100 */ _LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,
 /* 110 */ _LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,
 /* 120 */ _LETTER,_LETTER,_LETTER,_,/*|*/_SPECIAL,_,_,_,_,_,
 /* 130 */ _,_,_,_,_,_,_,_,_,_,
 /* 140 */ _,_,_,_,_,_,_,_,_,_,
 /* 150 */ _,_,_,_,_,_,_,_,_,_,
 /* 160 */ _,_,_,_,_,_,_,_,_,_,
 /* 170 */ _,_,_,_,_,_,_,_,_,_,
 /* 180 */ _,_,_,_,_,_,_,_,_,_,
 /* 190 */ _,_,_,_,_,_,_,_,_,_,
 /* 200 */ _,_,_,_,_,_,_,_,_,_,
 /* 210 */ _,_,_,_,_,_,_,_,_,_,
 /* 220 */ _,_,_,_,_,_,_,_,_,_,
 /* 230 */ _,_,_,_,_,_,_,_,_,_,
 /* 240 */ _,_,_,_,_,_,_,_,_,_,
 /* 250 */ _,_,_,_,_,_
 };
