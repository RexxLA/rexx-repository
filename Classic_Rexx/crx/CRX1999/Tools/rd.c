/*------------------------------------------------------------------------------
Sept 92 - Extend with topdown routines for syntax check.
Nov 94 - Note # for action.
Oct 96 - :+ for permutation.

1. Initialize

2. Read it all to one variable in memory.

3. Divide into tokens
    - For each symbol, add to dictionary and put offset in array Text
    - For each operator, add corresponding offset to array Text

4. Tidy up and return
õ-----------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------
ReadIn reads a grammar.
õ-----------------------------------------------------------------------------*/
static char * MsgRd[]={
/* 0*/ "\nReading in found a syntax error. Good part is:\n",
/* 1*/ "\nReadIn could not open the input.",
/* 2*/ "\nReadIn:  Grammar read in.",
  };
/* Low level I/O is used */
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <io.h>
#include "always.h"
/* A compile time variable Extern allows the same cluster heading to be
used as declaration in one compiland and definition in another. */
/* Here we include the headers for clusters being used (imported). */
/* Order may be important. */
#define Extern 1
#define Storage extern
#include "main.h"
#include "wal.h"
/* Here the header for what is being implemented. (exported) */
#undef Extern
#undef Storage
#define Extern 0
#define Storage
#include "rd.h"
/* Simplify shares Permute with RD */
#define Permute -99
static FILE * In; /* Fix Borland? */
static Ushort TextHas; /* Amount of text. */
static short Element; /* of text. */
static char * Tokenp;  /* Address of latest token. */
static Ushort TokenLength; /* Length of latest token. */
static short Token; /* Value to go in Text. */
static int Fhandle;    /* For the file to be read. */
static long Flength;
static char * Fmem;/* File in memory. */
static char * Shadow;/* Translated copy. */
static char *p, *q; /* Cursors on memory file and its shadow. */
static char *p, *q, *r; /* Cursors on memory file and its shadow. */
static unsigned Textl; /* Length when read as text. */
static short IsIt(Offset); /* Called from LookUp, see wal cluster. */
static Offset MakeIt(void); /* Called from LookUp, see wal cluster. */
static char *NameCount="Q0000"; /* For creating names of productions. */
static Uchar TrapReduce;
static void Place(short t);
static void Bnf(void); /* Scan to bnf rules. */
static void Ors(void); /* Scan to bnf rules. */
static void Cats(void); /* Scan to bnf rules. */
static void Prim(void); /* Scan to bnf rules. */
static void NextToken(void);
static jmp_buf Fail;
void ReadIn(const char * const Argv1){
/*------------------------------------------------------------------------------
1. Initialize
õ-----------------------------------------------------------------------------*/
/* WalkBase addresses the wallet containing symbols. */
   WalkBase=calloc(sizeof(Wallet),1);/* Wallet for the Symbols */
   WHWB->w.Stride=1;WHWB->w.Clear=Yes;
/* With a header for LookUp */
   TextHas=Offsetof(Symbol,Hatch);
   TextHas=sizeof(WalkHead);
   TextHas=sizeof(Wallet);
   TextHas=Offsetof(Wallet,Has);
   TextHas=Offsetof(Wallet,Needs);
   TextHas=Offsetof(Wallet,Stride);
   WHWB->w.Needs=sizeof(WalkHead)-sizeof(Wallet);
   WalkBase=WalletEx(WalkBase);
   /* Initialised for LookUp */
   WHWB->MakeIt=MakeIt;WHWB->IsIt=IsIt;
 Text=calloc(sizeof(Wallet),1);
 Text->w.Stride=sizeof(Ushort);
/* An extra semicolon at the front so that rules begin and end at semicolons. */
    Text->w.Needs=100; /* Reasonable first size */
    Text=WalletEx((Wallet*)Text);
    TextHas=1;
    Text->e[TextHas-1]=Break;
/*------------------------------------------------------------------------------
2. Read it all to one variable in memory.
õ-----------------------------------------------------------------------------*/
  Fhandle=open(Argv1,O_RDONLY|O_TEXT);
  if(Fhandle==-1){
     printf(MsgRd[1]);
     longjmp(ErrSig,1);
  }
/* Read into a sufficiently long memory segment. */
  Flength=lseek(Fhandle,0L,SEEK_END);   /* This gives length including eof */
#if 0
  printf("Len %d",Flength);    /* eg 10129 for IS.BNF once */
#endif
  Flength++;
  Fmem=malloc((size_t)Flength);
  if(lseek(Fhandle,0L,SEEK_SET)==-1){perror("");Failure;}
  close(Fhandle);    /* Borland fix */
#if 0
/* I expected the following to read all but the eof.  Actually one less? */
/* Textl=read(Fhandle,Fmem,65534U); worked for C600 and Warp C++. */
/* Borland failed with "Invalid Argument" */
/* Change last arg to 10000 yields "illegal operation" */
/* Change last arg to Flength-1 yields "illegal operation" */
/* Change last arg to Flength-2 yields "illegal operation" */
/* Change last arg to 10129 yields "illegal operation" */
/* Change last arg to UINT_MAX-1 yields "Invalid Argument" */
/* Whatsup?  Fhandle OK presumably because length retrieved OK. */
/* Borland help for 'read' does not give "Invalid Argument" as a possibility.*/
/* DOS error is 87 decimal. */
/* That is not in errno.h, but 7 is a bad memory block, which might figure. */
/* 64 + 23 and 23 is too many files open but surely that would be on open. */
/* But read into static no better. */
/* See if close then open helps */
  if(close(Fhandle)==-1){perror("");printf("Dos %d",_doserrno);Failure;}
  Fhandle=open(Argv1,O_RDONLY|O_BINARY);
  if(Fhandle==-1){
     printf(MsgRd[1]);
     longjmp(ErrSig,1);
  }
/* It doesn't. Even if opened binary. */
  Textl=read(Fhandle,Play,UINT_MAX-1);
  if(Textl==-1){perror("");printf("Dos %d",_doserrno);Failure;}
#endif
/* So for Borland read at a higher level. */
  if ((In=fopen(Argv1,"r"))==NULL){
     printf(MsgRd[1]);
     longjmp(ErrSig,1);
  }
  p=Fmem;
  Textl = 0;
  do{
   Textl++;
   *p = getc(In);Token = *p++;
  } while(Token!=EOF && Token !=0);
  Textl = Textl-1;
  Fmem[Textl]='\0'; /* So that scans always terminate if looking for zero. */
  fclose(In);
/*------------------------------------------------------------------------------
3. Divide into tokens
    - For each symbol, add to dictionary and put offset in array Text
    - For each operator, add corresponding value to array Text
õ-----------------------------------------------------------------------------*/
/* Make a shadow the source, with a byte describing each byte. */
 {
 #include "rdascii.h"
   Shadow=malloc((size_t)Flength);
   p=Fmem;
   for(q=Shadow;q<Shadow+Flength;q++){
     *q=Translate[*p++];
   }
   if(setjmp(Fail)){
      printf(MsgRd[0]);
      *p='\0'; /* End the good part */
      /* Show good part and quit. */
      printf(Fmem);longjmp(ErrSig,1);
   }
   Bnf();
 }
/* Do counting */
   TermCount=ProdCount=BothCount=0;
/* Go over the symbols with a walk rather than a scan, to get alpha order. */
   Walk(CountTerm);
/* We number the productions after the terminals so that Sym->Num can index
a bit strip applying to both productions and terminals. */
/* We will have an array so that we can go from number to symbol. */
   if((Num2Sym=malloc(BothCount*sizeof(Offset)))==NULL) Failure;
   Walk(CountProd);/* Also fills Num2Sym */
/*------------------------------------------------------------------------------
4. Tidy up and return
õ-----------------------------------------------------------------------------*/
  free(Fmem); /* Source no longer needed. */
/* Remove any spare space on the wallets. */
  Place(0); /* To be safe when lookahead */
  Text->w.Exact=Yes;Text=WalletEx((Wallet*)Text);
  Text->w.Needs--;/* Don't count the trailing zero. */
  WHWB->w.Exact=Yes;WalkBase=WalletEx(WHWB);
  SyoLo=sizeof(WalkHead);/* Where symbols start. */
  SyoZi=WHWB->w.Needs+sizeof(Wallet);/* Address beyond */
  printf(MsgRd[2]);
  return;
}
/*------------------------------------------------------------------------------
Subroutine Isit tests whether something is already in the symbol dictionary.
õ-----------------------------------------------------------------------------*/
static short IsIt(Offset Subject){
  Symbol * Sym;int m,t;
  int SubMsg, TokMsg;
/* Subject is an offset to a Symbol */
  Sym=(Symbol *)(WalkBase+Subject);
/* Simplest compare does lengths first. */
/* But we want the more normal sort order. */
/* Oct 94 - make Msg sort high. */
/* Do I need to test length>2? */
  SubMsg=memcmp(Sym->s,"Msg",3);
  TokMsg=memcmp(Tokenp,"Msg",3);
  if(SubMsg==0 && TokMsg!=0) return +1;
  if(SubMsg!=0 && TokMsg==0) return -1;
/* A quick first test. */
  if(Sym->s[0]>*Tokenp) return +1;
  if(Sym->s[0]<*Tokenp) return -1;
/* Now slower */
  m=Min(Sym->SymbolLength,TokenLength);
  if((t=memcmp(Sym->s,Tokenp,m))>0) return +1;
  if(t<0) return -1;
  if(Sym->SymbolLength>TokenLength) return +1;
  if(Sym->SymbolLength<TokenLength) return -1;
  return 0;
}
/*------------------------------------------------------------------------------
Subroutine MakeIt makes a symbol item.
õ-----------------------------------------------------------------------------*/
static Offset MakeIt(void){
 Symbol* ThisOne;Offset t;
 t=WHWB->w.Needs+sizeof(Wallet);
 WHWB->w.Needs+=Offsetof(Symbol,s)+TokenLength;
 WalletCheck(WalkBase);
 ThisOne=(Symbol*)(WalkBase+t);
 Clear(*ThisOne);
 ThisOne->SymbolLength=TokenLength;
 strncpy((char *)(&ThisOne->s[0]),Tokenp,TokenLength);
 return t;
}
/*------------------------------------------------------------------------------
Subroutine NewName - Create a new production name.
õ-----------------------------------------------------------------------------*/
Offset NewName(void){
  Ushort i;Offset r;
  i=atoi(&NameCount[1]);i++;
  sprintf(&NameCount[1], "%d", i);
  Tokenp=NameCount;
  TokenLength=strlen(NameCount);
  r=LookUp();
  ((Symbol*)(WalkBase+r))->Temp=Yes;
  return r;
}
/*------------------------------------------------------------------------------
Place token in Text
õ-----------------------------------------------------------------------------*/
static void Place(short t){
         Text->w.Needs=++TextHas;
         WalletCheck(Text);
         Text->e[TextHas-1]=t;
} /* Place */
/*------------------------------------------------------------------------------
Scan to bnf rules.  Bnf = prod_list;  prod= lhs ':' Ors
õ-----------------------------------------------------------------------------*/
static void Bnf(void){
  Symbol * Sym; Ushort AssignType;
/* Ignore break generated by look-ahead. */
 NextToken();if(Token!=Break) longjmp(Fail,1);
 NextToken();
 do{
  /* Lhs = rhs1 | <rhs2> | (rhs3) | */
  if(Token<=0) longjmp(Fail,1);
  Sym=(Symbol*)(WalkBase+Token);
  Sym->Prod=Yes;
  if(Sym->ProdPos==0) Sym->ProdPos=TextHas;
  Place(Token);
  NextToken();
/* Assignment flavours are ::= := = and => (Latter as == in Switches. */
/* Default to := */
  AssignType=Assignment;
  if(strstr(Switches,"::=")){
    if(Token!=Colon) longjmp(Fail,1);NextToken();
    if(Token!=Colon) longjmp(Fail,1);NextToken();
    if(Token!=Assignment) longjmp(Fail,1);NextToken();
  }
  else if(strstr(Switches,"==")){
    if(Token!=Assignment) longjmp(Fail,1);NextToken();
    if(Token!=RightAngle) longjmp(Fail,1);NextToken();
  }
  else if(strstr(Switches,":=")){/* :=  with :+ allowed also. */
    if(Token!=Colon) longjmp(Fail,1);NextToken();
    if(Token!=Assignment && Token != Plus) longjmp(Fail,1);
    if(Token == Plus) AssignType=Permute;
    NextToken();
  }
  else {  /* = is default because .SIM usual. */
    if(Token!=Assignment) longjmp(Fail,1);NextToken();
  }
  Place(AssignType);
  if(Token!=Break) Ors();
  if(Token!=Break) longjmp(Fail,1);Place(Token);NextToken();
 } while(Token);
} /* Bnf */
/*------------------------------------------------------------------------------
Ors in bnf            ors = cats | cats '|' ors
õ-----------------------------------------------------------------------------*/
static void Ors(void){
 for(;;){
  Cats();
  if(Token!=SpecialOr) break;
  Place(Token);NextToken();
 }
} /* Ors */
/*------------------------------------------------------------------------------
Cats in bnf            cats= prim | prim cats
õ-----------------------------------------------------------------------------*/
static void Cats(void){
 do{
  Prim();
 } while(Token>0 || Token==LeftParen || Token==LeftBracket);
} /* Cats */
/*------------------------------------------------------------------------------
Prim in bnf            prim= operand | '(' Ors ')' | '[' Ors ']'
              Optional + after
õ-----------------------------------------------------------------------------*/
static void Prim(void){
 if(Token>0){
   Place(Token);NextToken();
 }
 else if(Token==LeftBracket){
   Place(Token);NextToken();
   Ors();if(Token!=RightBracket) longjmp(Fail,1);
   Place(Token);NextToken();
 }
 else if(Token==LeftParen){
   Place(Token);NextToken();
   Ors();if(Token!=RightParen) longjmp(Fail,1);
   Place(Token);NextToken();
 }
 else longjmp(Fail,1);
/* Here after Prim */
 if(Token==Plus){Place(Token);NextToken();}
} /* Prim */
/*------------------------------------------------------------------------------
NextToken
õ-----------------------------------------------------------------------------*/
static Ushort NextTokenState;
static short HeldToken;
static void NextToken(void){
char *r, *s; /* Cursors for local scans. */
   char c;
 switch(NextTokenState){
   case 0 :                   /* Initially */
      p=Fmem;q=Shadow;
      NextTokenState=1;
   case 1 :                   /* No Token held from last call. */
 Switch:
     switch(*q){
       case _WHITE:p++;q++;goto Switch;
       case _SLASH:
         if(*(p+1)!='*') longjmp(Fail,1);
         r=p+2;
     InComment:
     /* Find next '*' */
         while(*r!='*' & *r!='\0') r++;if(*r!='*') longjmp(Fail,1);
         if(*++r!='/') goto InComment;
         r++;q+=r-p;p=r;goto Switch;
       case _SPECIAL:r=Specials;/* Recorded as negative of index into this. */
         Token=-1-(strchr(r,*p)-r);p++;q++;
         return;
       case _ADIGIT:
       case _LETTER:r=q+1;while(*r==_LETTER | *r==_ADIGIT) r++;
         Tokenp=p;TokenLength=r-q;
         p+=r-q;q=r;
         Token=LookUp();
         /* Set flag for dot */
         r=Tokenp;
         while(r<Tokenp+TokenLength){
           if(*r++=='.'){
             ((Symbol*)(WalkBase+Token))->IsExit=Yes;
             break;
           }
         }
         /* Any # value gets written into the symbol accessed. */
         if(TrapReduce){
           ((Symbol*)(WalkBase+Token))->Hatch=TrapReduce;
           TrapReduce=0;
         }
/* Check ahead, since we find the break between productions by detecting
the start of a production. p & q don't change. */
         r=p;s=q;
/* Skip blanks and comments for check. */
         while(*r=='/' || *s==_WHITE){
          if(*r=='/'){
            if(*(r+1)!='*') longjmp(Fail,1);
            r=r+2;
 InCommentx:
 /* Find next '*' */
            while(*r!='*' & *r!='\0') r++;if(*r!='*') longjmp(Fail,1);
            if(*++r!='/') goto InCommentx;
          }
          r++;s=q+(r-p);
         }
/* If we do have ':', we must return Break before returning the Token we
just went past. */

/* Also '=' now we have switches. */
         if(*r==':' || *r=='='){
           HeldToken=Token;
           NextTokenState=3;
           Token=Break;
         }
         return;
       case _QUOTE:
         c=*p;
         r=p+1;while(*r!=c & *r!='\n' & *r!='\0') r++;
         if(*r++!=c) longjmp(Fail,1);
         Tokenp=p;TokenLength=r-p;
         q+=r-p;p=r;
         Token=LookUp();
         return;
       default:;
          if(*p=='#'){
            TrapReduce = 1;
            p++;q++;
            goto Switch;
          }
/* Unless it is the nul we put at the end
 we have finished prematurely. */
          if(q!=&(Shadow[Textl])) longjmp(Fail,1);
          Token=Break;
          NextTokenState=2;
          return;
      } /* switch *p */
   case 2 :           /* End of file */
     Token=0;return;
   case 3 :           /* Return a held token */
     Token=HeldToken;
     NextTokenState=1;
     return;
 } /* Switch NextTokenState */
} /* NextToken */
/*------------------------------------------------------------------------------
Routine CountProd to number productions
õ-----------------------------------------------------------------------------*/
void CountProd(Offset n){
  Symbol *Sym;
  Sym=(Symbol*)(WalkBase+n);
  if(Sym->Prod  && !Sym->Temp ) Sym->Num=TermCount+ProdCount++;
  /* Note all symbols in index. */
  *(Num2Sym+Sym->Num)=(char *)Sym-(char *)WalkBase;
  /* Some Rexx specialized stuff. */
  /* Note if there is a '||' */
  if(memcmp("'||'",Sym->s,Sym->SymbolLength)==0)
     CatNum=Sym->Num;
  if(memcmp("VAR_SYMBOL",Sym->s,Sym->SymbolLength)==0)
     VarNum=Sym->Num;
} /* CountProd */
/*------------------------------------------------------------------------------
Routine CountTerm to number terminals
õ-----------------------------------------------------------------------------*/
void CountTerm(Offset n){
  Symbol *Sym;
  Sym=(Symbol*)(WalkBase+n);
     BothCount++;
     if(!Sym->Prod){
       Sym->Num=TermCount++;
       if(memcmp(Sym->s,"Msg",3)==0)
          {MsgFlag=Yes;Sym->IsMsg=Yes;Sym->IsExit=No;/* Even if dot */}
     }
} /* CountTerm */
