/*------------------------------------------------------------------------------
SIMPLIFY processes a grammar to a simpler format.
There is a simple messages scheme so that an internal error can (almost)
always be reported by a printf.
Note also the Extern convention that allows for a header to be written once but
used either as a declaration or a definition.
It is expected that the complete program will consist of clusters, where
a cluster has a clustername.h that defines its interface to other clusters
and a cluster.c that is its implementation.
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
#include "rd.h"
/* Here the header for what is being implemented. (exported) */
#undef Extern
#undef Storage
#define Extern 0
#define Storage
#include "main.h"
/* The rest is only refered to locally, hence use of 'static'. */
  char * Msg[5];  /* Values given later */
  static short Rc;
  static char * InArg;
  static char * OutArg;
  static char * Switchp;
  static void Simplify(void);
void main(const int argc, const char* const argv[])
{
  printf(Msg[3]);
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
  if (argc>1&&argv[1][0]=='/'){
    if (argc!=4) goto Tell;
/* Upper case the switches */
    Switches=strdup(argv[1]);
    Switchp=Switches;
    while(*Switchp){
      *Switchp=(char)toupper(*Switchp);
      Switchp++;
    }
    InArg=(char *)argv[2];
    OutArg=(char *)argv[3];
  }
  else{
    Switches=" ";
    if (argc!=3||argv[1][0]=='?') goto Tell;
    InArg=(char *)argv[1];
    OutArg=(char *)argv[2];
  }
/* The pointer to symbols gets set in Dict, pointer to in Text. */
  ReadIn(InArg); /* In the rd Cluster to read in the grammar. */
  SetShowFile(OutArg); /* In the Show Cluster - where to output. */
  Simplify();    /* Just to put body in a separate include, sy.c */
  printf(Msg[0]);
  goto Exit;
Tell:
  printf(Msg[2]);
Exit:
  exit(Rc);
}
  #include "sy.i"
  char * Msg[5]={
/* 0*/ "\nSIMPLIFY finished normally.\n",
/* 1*/ "\nSIMPLIFY did NOT finish normally.\n",
/* 2*/ "\nSIMPLIFY InputFile OutputFile simplifies a grammar.",
/* 3*/ "\nSIMPLIFY For personal use of those I give it to - BLM Oct 92",
/* 4*/ "\nSIMPLIFY Repetition of an optional is disallowed.",
  };
