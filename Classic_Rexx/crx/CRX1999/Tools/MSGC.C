/*------------------------------------------------------------------------------
Msgc is to prepare compressed messages.
õ-----------------------------------------------------------------------------*/
/*#pragma comment( exestr,"Copyright Brian Marks 1993")*/
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
static void Msgc(const char* const f);
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
    if (argc!=4||argv[1][0]=='?') goto Tell;
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
  Msgc(InArg);    /* Just to put body in a separate include, mc.i */
  NewLine();
  printf(Msg[0]);
  goto Exit;
Tell:
  printf(Msg[2]);
Exit:
  exit(Rc);
}
#include "mc.i"
  char * Msg[]={
/* 0*/ "\nMSGC finished normally.\n",
/* 1*/ "\nMSGC did NOT finish normally.\n",
/* 2*/ "\nMSGC InputFile OutputFile compresses prose.",
/* 3*/ "\nMSGC For personal use of those I give it to - BLM Aug 93",
  };
