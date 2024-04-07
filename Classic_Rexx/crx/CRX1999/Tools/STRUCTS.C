/*------------------------------------------------------------------------------
STRUCTS produces tables for a grammar from the output of STATES.
15 Feb 96. Change to 32 bit version, with lots more function.
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
  static char * InArg2;
  static char * OutArg;
  static char * Switchp;
  static void Structs(void);
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
    if (argc!=5) goto Tell;
/* Upper case the switches */
    Switches=strdup(argv[1]);
    Switchp=Switches;
    while(*Switchp){
      *Switchp=(char)toupper(*Switchp);
      Switchp++;
    }
    InArg=(char *)argv[2];
    InArg2=(char *)argv[3];
    OutArg=(char *)argv[4];
  }
  else{
    Switches=" ";
    if (argc!=4||argv[1][0]=='?') goto Tell;
    InArg=(char *)argv[1];
    InArg2=(char *)argv[2];
    OutArg=(char *)argv[3];
  }
/* The pointer to symbols gets set in Dict, pointer to in Text. */
  ReadIn(InArg); /* In the rd Cluster to read in the grammar. */
  SetShowFile(OutArg); /* In the Show Cluster - where to output. */
  Structs();    /* Just to put body in a separate include, sr.i */
  printf(Msg[0]);
  goto Exit;
Tell:
  printf(Msg[3]);
Exit:
  exit(Rc);
}
  #include "sr.i"
  char * Msg[]={
/* 0*/ "\nSTRUCTS finished normally.\n",
/* 1*/ "\nSTRUCTS did NOT finish normally.\n",
/* 2*/ "\nSTRUCTS For personal use of those I give it to - BLM Nov 92",
/* 3*/ "\nSTRUCTS makes table in 'C' or ASM format. "
"Usage:  STRUCTS [/Options] InFile InFromStates OutFile\n"
"Options concatenated after slash: a.\n",
/* 4*/ "\nSTRUCTS Writing to third argument.",
/* 5*/ "\nSTRUCTS Unable to read %s.",
/* 6*/ "\nSTRUCTS Second argument must be made from first by STATES.",
/* 7*/ "\nSTRUCTS Memory exhausted.",
/* 8*/ "\nSTRUCTS Recompile for > %d terminals and nonterms.",
/* 9*/ "\nSTRUCTS Reduction conflict in State %d.",
/*10*/ "\nSTRUCTS Unexpected lookahead %d %d %d.",
/*11*/ "\nSTRUCTS Major Minor ? %d %d.",
/*12*/ "\nSTRUCTS Message number %d %d %d.",
/*13*/ "\nSTRUCTS Recompile for extra states.",
  };
