/*------------------------------------------------------------------------------
 Bits.c 921002 Separate compilation
õ-----------------------------------------------------------------------------*/
#include "always.h"
/* Here we include the headers for clusters being used (imported). */
/* Order may be important. */
#define Extern 1
#define Storage extern
#include "main.h"
/* Here the header for what is being implemented. (exported) */
#undef Extern
#define Extern 0
#undef Storage
#define Storage
#include "bits.h"
/*------------------------------------------------------------------------------
 The Bit cluster supports bit-strips.
õ-----------------------------------------------------------------------------*/
static char OnMasks[8]  = "\x80\x40\x20\x10\x08\x04\x02\x01";
static char OffMasks[8] = "\x7F\xBF\xDF\xEF\xF7\xFB\xFD\xFE";
/*------------------------------------------------------------------------------
Routines to set flags in packed bitstrips.
õ-----------------------------------------------------------------------------*/
void SetFlag(char *Strip,Ushort Pos){
/* Set a flag in the compact bit strip. */
  div_t r;
  r=div(Pos,8);
*(Strip+r.quot) |= OnMasks[r.rem];
} /*SetFlag*/
void OffFlag(char *Strip,Ushort Pos){
/* Set a flag in the compact bit strip. */
  div_t r;
  r=div(Pos,8);
*(Strip+r.quot) &= OffMasks[r.rem];
} /*OffFlag*/
Bool QryFlag(char *Strip,Ushort Pos){
/* Query a flag in the compact bit strip. */
  div_t r;
  r=div(Pos,8);
  return *(Strip+r.quot) & OnMasks[r.rem];
}
/*------------------------------------------------------------------------------
Routine to OR strings.
õ-----------------------------------------------------------------------------*/
void MemOr(char * p,char * q,size_t t){
  char * r;
  r=p+t;while(p<r) *p++ |= *q++;
}
/*------------------------------------------------------------------------------
Routine to AND strings.
õ-----------------------------------------------------------------------------*/
void MemAnd(char * p,char * q,size_t t){
  char * r;
  r=p+t;while(p<r) *p++ &= *q++;
}
/*------------------------------------------------------------------------------
Routine to XOR strings.
õ-----------------------------------------------------------------------------*/
void MemXor(char * p,char * q,size_t t){
  char * r;
  r=p+t;while(p<r) *p++ ^= *q++;
}
/*------------------------------------------------------------------------------
Routine to see if anything is common.
õ-----------------------------------------------------------------------------*/
Bool MemBoth(char * p,char * q,size_t t){
  char * r;
  r=p+t;while(p<r) if(*p++ & *q++) return 1;
  return 0;
}
/*------------------------------------------------------------------------------
Routine to check for empty set.
õ-----------------------------------------------------------------------------*/
Bool MemAny(char * p,size_t t){
  char * r;
  r=p+t;while(p<r) if(*p++) return 1;
  return 0;
}
