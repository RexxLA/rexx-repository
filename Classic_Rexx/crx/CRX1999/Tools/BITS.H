/*------------------------------------------------------------------------------
 bits.h  921002
õ-----------------------------------------------------------------------------*/
/* The Bits cluster works on bit-strips. */
/* First arg address strip, second zero-origin bit position. */
void SetFlag(char *,Ushort);
void OffFlag(char *,Ushort);
Bool QryFlag(char *,Ushort);
/* Result of MemOr goes in first argument. */
void MemOr(char * p,char * q,size_t t);
/* Result of MemAnd goes in first argument. */
void MemAnd(char * p,char * q,size_t t);
/* Result of MemXor goes in first argument. */
void MemXor(char * p,char * q,size_t t);
/* MemAny is 1 if any bits are on, else 0. */
Bool MemAny(char * p,size_t t);
/* MemAll is not so useful since not initialized with 1's for the spares. */
/* MemBoth to see if anything is common. */
Bool MemBoth(char * p,char * q,size_t t);
