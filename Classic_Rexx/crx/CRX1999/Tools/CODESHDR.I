/* Facts needed to unpick the Pcode format, file In. */
/* Expanded June 99 to cover Bcodes and Bifs. */
/* A few opcodes have extra fields above the optional Number, Symbol, and
Jump.*/
/* Some Xtra's historical. */
 enum{XtraNone,XtraNum,XtraSymbol,XtraJump};
 typedef struct{
   struct{
     unsigned Extra:3;
     unsigned Num:1;
     unsigned Symbol:1;
     unsigned Jump:1;
     unsigned Down:2;
     unsigned Eoc:1;
   } Has;
   char * Op;
 } OpShape;
 typedef struct{
   Ushort MinArgs;
   char * f;
 } BifShape;
#define BifBase (65535-70)
static char SegHeader[16];
static char SegHeadeC[20];
/* This is about what fields the opcodes have, not about semantics. */

/* Sept 99.  No utilities process Bcodes yet.
 OpShape Bcodes[]={
 XtraNone  ,0,0,0,0,0,"CONFIG_RAISE",
 XtraNone  ,0,0,0,0,0,"CONFIG_RAISE40",
 XtraNone  ,0,0,0,0,0,"CONFIG_UPPER",
 XtraNone  ,0,0,0,0,0,"CONFIG_MSG",
 XtraNone  ,0,0,0,0,0,"CONFIG_C2B",
 XtraNone  ,0,0,0,0,0,"CONFIG_B2C",
 XtraNone  ,0,0,0,0,0,"CONFIG_STREAM_POSITION",
 XtraNone  ,0,0,0,0,0,"CONFIG_STREAM_CHARIN",
 XtraNone  ,0,0,0,0,0,"CONFIG_STREAM_QUERY",
 XtraNone  ,0,0,0,0,0,"CONFIG_STREAM_CLOSE",
 XtraNone  ,0,0,0,0,0,"CONFIG_STREAM_CHAROUT",
 XtraNone  ,0,0,0,0,0,"CONFIG_STREAM_COUNT",
 XtraNone  ,0,0,0,0,0,"CONFIG_STREAM_QUALIFIED",
 XtraNone  ,0,0,0,0,0,"CONFIG_STREAM_COMMAND",
 XtraNone  ,0,0,0,0,0,"CONFIG_STREAM_STATE",
 XtraNone  ,0,0,0,0,0,"CONFIG_TIME",
 XtraNone  ,0,0,0,0,0,"Zero",
 XtraNone  ,0,0,0,0,0,"One",
 XtraNone  ,0,0,0,0,0,"Null",
 XtraNone  ,0,0,0,0,0,"String",
 XtraNone  ,0,0,0,0,0,"String1",
 XtraNone  ,0,0,0,0,0,"String2",
 XtraNone  ,0,0,0,0,0,"_RetBc",
 XtraNone  ,0,0,0,0,0,"_RetB",
 XtraNone  ,0,0,0,0,0,"_RetF",
 XtraNone  ,0,0,0,0,0,"_IterCV",
 XtraNone  ,0,0,0,0,"_Exists",
 XtraNone  ,0,0,0,0,0,"_Then",
 XtraNone  ,0,0,0,0,0,"_Jump",
 XtraNone  ,0,0,0,0,0,"_Eq",
 XtraNone  ,0,0,0,0,0,"_Ne",
 XtraNone  ,0,0,0,0,0,"_Lt",
 XtraNone  ,0,0,0,0,0,"_Le",
 XtraNone  ,0,0,0,0,0,"_Ge",
 XtraNone  ,0,0,0,0,0,"_Gt",
 XtraNone  ,0,0,0,0,0,"_Seq",
 XtraNone  ,0,0,0,0,0,"_Sne",
 XtraNone  ,0,0,0,0,0,"_Slt",
 };
*/
/* BEWARE - no comments below here since it is scanned by utility program
 CODES.REX  (July 2002 - this comment obsolete?) */

#include "codes.i"
