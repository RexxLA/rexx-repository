/*------------------------------------------------------------------------------
BF processes the Rexx code from the Standard
Nov 98 from DT of Oct 97.
õ-----------------------------------------------------------------------------*/
void main(const int argc, const char* const argv[]);
#include "always.h"
/* A compile time variable Extern allows the same cluster heading to be
used as declaration in one compiland and definition in another. */
/* Here we include the headers for clusters being used (imported). */
/* Order may be important. */
#define Extern 1
#define Storage extern
#include "show.h"
#include "wal.h"
#include "bits.h"
/* Here the header for what is being implemented. (exported) */
#undef Extern
#undef Storage
#define Extern 0
#define Storage
#include "main.h"
/* The rest is only refered to locally, hence use of 'static'. */
  char * Msg[];  /* Values given later */
  static short Rc;
  static char * Switchp;
  static char * InArg;
  static void Scopes(void);
void main(const int argc, const char* const argv[])
{
  printf(Msg[2]);
/* Allow for subroutine exits. */
  if ((Rc=setjmp(ErrSig))!=0) {
/* There was a longjmp(ErrSig,n) */
      printf(Msg[Rc]);
      Rc=Rc+100;
      if(C_Line){
        printf("\nFile is %s, Line is %d",C_File,C_Line);
      }
      goto Exit;
  }
/* Detect when user needs help on the syntax of the function. */
  if (argc!=2) goto Tell;
  InArg=(char *)argv[1];
  Scopes();    /* Just to put body in a separate include, bf.i */
  printf(Msg[0]);
  goto Exit;
Tell:
  printf(Msg[3]);
Exit:
  fflush(stdout);
  exit(Rc);
}
  #include "bf.i"
  char * Msg[]={
/* 0*/ "\nBF finished normally.\n",
/* 1*/ "\nBF did NOT finish normally.\n",
/* 2*/ "\nBF For personal use of those I give it to - BLM Oct 97",
/* 3*/ "\nBF takes one arg (CRX output) to make BF.T",
/* 4*/ "\nBF Unable to read %s.",
/* 5*/ "\nBF Input file fails checks.",
/* 6*/ "\nBF Memory exhausted.",
/* 7*/ "\nBF No labels.",
/* 8*/ "\nBF Make more variables space.",
  };
