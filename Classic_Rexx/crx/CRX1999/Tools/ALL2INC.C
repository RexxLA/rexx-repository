/* Reverse ALL2INC. */
void main(const int argc, const char* const argv[]);
#include "always.h"
#undef Extern
#undef Storage
#define Extern 0
#define Storage
#include "main.h"
#include "wal.h"
#include <io.h>
  char * Msg[];  /* Values given later */
  static short Rc;
static FILE * In;
static FILE * Part;
static FILE * Out;
static char LineBuffer[200], LineBufferP[200], *Progress, *ProgressP;
static char *p, *PartName;
static long SeekPos;
void main(const int argc, const char* const argv[])
{
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
  if (argc!=2||argv[1][0]=='?') goto Tell;
  if ((In=fopen(argv[1],"r"))==NULL) longjmp(ErrSig,2);
  Progress = fgets(LineBuffer,Dim(LineBuffer),In);
  if(strncmp(LineBuffer,";õ ",3)!=0) longjmp(ErrSig,5);
NextOut:
  p=strpbrk(LineBuffer+3," ;\n");
  if(p) *p='\0';
  PartName = strdup(LineBuffer+3);
/* Check whether the file PartName is being altered and only write it if it
is.*/
  if ((Part=fopen(PartName,"r"))==NULL) goto NewPart;
/* Note position on In. */
  SeekPos = ftell(In);
  while(!feof(In)){
    Progress = fgets(LineBuffer,Dim(LineBuffer),In);
    if(!Progress) break;
    if(strncmp(LineBuffer,";õ ",3)==0) break;
    ProgressP = fgets(LineBufferP,Dim(LineBufferP),Part);
    if(feof(Part)) goto Changed;
    if(strcmp(Progress,ProgressP)!=0) goto Changed;
  }
/* Compared through. */
  if(fgets(LineBufferP,Dim(LineBufferP),Part)!=NULL) goto Changed;
  fclose(Part);
  if(strncmp(LineBuffer,";õ ",3)!=0) goto Exiting;
  goto NextOut;
Changed:;
  fclose(Part);
  fseek(In,SeekPos,SEEK_SET);
NewPart:;
  if ((Out=fopen(PartName,"w"))==NULL) longjmp(ErrSig,3);
  while(!feof(In)){
    Progress = fgets(LineBuffer,Dim(LineBuffer),In);
    if(!Progress) break;
    if(strncmp(LineBuffer,";õ ",3)==0){
      fclose(Out);
      goto NextOut;
    }
    if(fputs(LineBuffer,Out)==EOF) longjmp(ErrSig,4);
  }
  fclose(Out);
Exiting:
  fclose(In);
  printf(Msg[0]);
  goto Exit;
Tell:
  printf(Msg[1]);
Exit:
  exit(0);
}
  char * Msg[]={
/* 0 */ "\nALL2INC finished normally.\n",
/* 1 */ "\nALL2INC One arg. Arg divided at include markers.",
/* 2 */ "\nALL2INC Arg unopenable.",
/* 3 */ "\nALL2INC Output unopenable.",
/* 4 */ "\nALL2INC Output arg bad for write.",
/* 5 */ "\nALL2INC Arg should be made by INC2ALL.",
   };
