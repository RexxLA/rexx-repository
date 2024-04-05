/*------------------------------------------------------------------------------
PACK is doing the physical packing of states & switches onto memory space.
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
  static char * InArg;
  static char * OutArg;
  static char * Switchp;
  static void Pack(void);
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
  SetShowFile(OutArg); /* In the Show Cluster - where to output. */
  Pack();    /* Just to put body in a separate include, pa.i */
  printf(Msg[0]);
  goto Exit;
Tell:
  printf(Msg[3]);
Exit:
  exit(Rc);
}
  #include "pa.i"
  char * Msg[]={
/* 0*/ "\nPACK finished normally.\n",
/* 1*/ "\nPACK did NOT finish normally.\n",
/* 2*/ "\nPACK For personal use of those I give it to - BLM Feb 96",
/* 3*/ "\nPACK makes table in ASM format. "
"Usage:  PACK [/Options] InFile OutFile\n"
"Options concatenated after slash: None.\n",
/* 4*/ "\nPACK Inconsistent input.",
/* 5*/ "\nPACK Unable to read %s.",
/* 6*/ "\nPACK Memory exhausted.",
/* 7*/ "\nPACK Input read.",
  };
