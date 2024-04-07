/* Supports a simple 'messages' system. */
/* Use in conjunction with MAIN.C */
/* This header goes in MAIN.C and those clusters linked with MAIN.C
which make use of Failure. */
#define Failure {C_Line=__LINE__;C_File=__FILE__;longjmp(ErrSig,1);}
  Storage jmp_buf ErrSig;
  Storage short C_Line;
  Storage char * C_File;
/* Can use this as shared way to access switches. */
  Storage char * Switches;
