/*------------------------------------------------------------------------------
 show.c  920605 Separate compilation
õ-----------------------------------------------------------------------------*/
#include "always.h"
/* Here we include the headers for clusters being used (imported). */
/* Order may be important. */
/* A compile time variable Extern allows the same cluster heading to be
used as declaration in one compiland and definition in another. */
/* Here we include the headers for clusters being used (imported). */
/* Order may be important. */
#define Extern 1
#define Storage extern
#include "main.h"
/* Here the header for what is being implemented. (exported) */
#undef Extern
#define Extern 0
#undef Storage
#define Storage
#include "show.h"
/*------------------------------------------------------------------------------
 The Show cluster puts output on file named FileName.
õ-----------------------------------------------------------------------------*/
 static char * Msg[]={
/* 0*/ "\nSHOW Unable to open listing file.\n",
/* 1*/ "\nSHOW Unable to write on listing file.\n",
  };
static FILE *ListFile;
static Ushort Linej=0;
static Ushort Margin=0;
static Ushort Right=LINE_SZ;
static Ushort Room=LINE_SZ;
static char FileName[100]; /* Allows for some qualifiers. */
/* End of Heading. */

void SetShowFile(char * s){
/* If FileName is null or stdout, there is no previous file to close. */
  if(FileName[0]!='\0' && strcmp(FileName,"stdout")){
    fclose(ListFile);
  }
  strncpy(FileName,s,sizeof(FileName)-1);
/* Check we can write on proposed output file. */
  if (FileName[0]=='\0' || strcmp(FileName,"stdout")==0) ListFile=stdout;
  else
    if ((ListFile=fopen(FileName, "w"))==NULL) {
      printf(Msg[0]);
      longjmp(ErrSig,1);
    }
}
void NewLine()
{
/* Default to sysout. */
  if(FileName[0]=='\0') SetShowFile("stdout");
  Line[Linej]='\0';
  if(fprintf(ListFile, "%s\n", Line)<0){
      printf(Msg[1]);
      longjmp(ErrSig,1);
  }
  Linej=0;
  while (Linej<Margin)
    Line[Linej++]=' ';
  Room=Right-Margin;
}
void ShowS(char * s)
{
  Ushort t;
/* Copies string to line. */
  t=strlen(s);
  ShowA(s,t);
}
void ShowA(char * s,Ushort n)
{/* An ASCII string with a length instead of terminator */
/* Copies string to line. */
  if (n>Room) {
    NewLine();
  }
/* Chop an overlength one */
  while(n>Room){
    strncpy(&Line[Linej],s,Room);NewLine();
    s+=Room;n-=Room;
  }
  strncpy(&Line[Linej],s,n);
  Linej+=n;
  Room-=n;
}
void ShowD(short t)
{
  char s[20];
      sprintf(s, "%d", t);
      ShowS(s);
}
void ShowL(long t)
{
  char s[20];
      sprintf(s, "%ld", t);
      ShowS(s);
}
void ShowC(char t)
{                                      /* Copies character to line. */
  if (Room==0) {
    NewLine();
  }
  Line[Linej++]=t;
  Room--;
}
void SetMargin(Ushort t)
{                                      /* Applies to subsequent Newlines. */
  Margin=t;
}
Ushort QryColumn()    /* Where will next Show go? */
{
  return(Linej);
}
void SetColumn(Ushort t)
{
  if(t>Right) return;
  if(t<Linej) NewLine();
  while (Linej<t)
    Line[Linej++]=' ';
  Room=Right-t;
}
