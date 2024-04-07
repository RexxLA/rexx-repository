/*------------------------------------------------------------------------------
States finds the states of a BNF grammar.
Note the Extern convention that allows for a header to be written once but
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
#include "bits.h"
#include "rd.h"
/* Here the header for what is being implemented. (exported) */
#undef Extern
#undef Storage
#define Extern 0
#define Storage
#include "main.h"
/* The rest is only refered to locally, hence use of 'static'. */
  char * Msg[];  /* Values given later */
  static short Rc;
  static char * InArg;
  static char * OutArg;
  static char * Switchp;
  static void States(void);
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
  States();    /* Just to put body in a separate include, st.i */
  printf(Msg[0]);
  goto Exit;
Tell:
  printf(Msg[3]);
Exit:
  exit(Rc);
}
  #include "st.i"
  char * Msg[]={
/* 0*/ "\nSTATES finished normally.\n",
/* 1*/ "\nSTATES did NOT finish normally.\n",
/* 2*/ "\nSTATES For personal use of those I give it to - BLM Oct 92",
/* 3*/ "\nSTATES finds states of a grammar. "
"Usage:  STATES [/Options] InFile OutFile\n"
"Options concatenated after slash: C for conflicts only. B for 'begins'.\n",
/* 4*/ "\nSTATES Too many terminals. Limit %d. Recompile for new limit.",
/* 5*/ "\nSTATES Too many productions. Limit %d. Recompile for new limit.",
/* 6*/ "\nSTATES Processed %d states. Known %d still to process...",
/* 7*/ "\nSTATES There are %d states...",
/* 8*/ "\nSTATES Count of conflict states was %d.",
/* 9*/ "\nSTATES Reprocess due to merge:  %d.",
/*10*/ "\nSTATES Writing to second argument.",
/*11*/ "\nSTATES Grammar is not simple - use Simplify.",
  };
