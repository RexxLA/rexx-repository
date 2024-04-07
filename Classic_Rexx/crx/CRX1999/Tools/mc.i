/* Jun 2002 going to Borland. It just gives an error, with output up to
then (essentially?) the same. */
/* Presumably this is Borland mangled heap, when other processors coped. */
/* No - looks like it was out-of-range reference that others did not catch. */
/* I have contrived to get the same output as with Warp by just not taking
Merit==2 but there are unresolved errors if ==2 allowed. */
#include <alloc.h>
int heapcheck(void);
int heapcheckfill(unsigned int);
int heapfillfree(unsigned int);
#define HeapFill 250
/*
_HEAPCORRUPT    Heap has been corrupted
_HEAPEMPTY      No heap
_HEAPOK
*/
/* Heapcheck found nothing - program still falls over. */
/* 25-11-96 going to CPP version, dropping _huge */
/* Can't get rid of warning on qsort, but seems to work. */
/* ToDo Dcls made not in setup.
Really want to work this again keeping accounts for Index & Referees, and
using two byte codes.
SortChain slows things; only zeroness currently used.
Not maintaining RefSum.
Allow for #Limit when reading source.
Looks like save code by programming the uppercasing of first char in a message,
particularly if we remove keywords first?  Approx 130 appearences of keywords.
Did keywords but still have options like ACEFIL..
*/
/* SECTION A: Msgc - Overview
   SECTION B: SetSource - Reading source
   SECTION C: Setup
   SECTION D: Select for Two->One replacement, One->Two replacement.
   SECTION E: RankMerit - Tracking the merit of the pairs.
   SECTION F: PutPacked - Producing the results.
   SECTION G: Table - lookup
   SECTION H: Only for debugging.

Each section has a main routine, with static variables and small routines
before it, major associated and subsiduary routines after it.
*/
/* Turn on CHECKS and scan for 'Check' places when detail debugging. */
#define CHECKS 1
#if CHECKS
static void MeritCheck(void);
static void Checking(void);
static void FreqCheck(void);
#endif
static Bool Trace; /* Used when debugging by altering this program. */
static Bool BorlBug; /* Used when debugging by altering this program. */

/*------------------------------------------------------------------------------
SECTION A: Overview

To make the tables for compressed messages.
Argument is filename for input.
STDOUT gets the progress output.
'Show' is set up to be the file on which compressed data is put. (Also dumps)

It is necessary for the coding scheme to be very simple, since the space
for the code that does decompression offsets the benefit of shortening the
string.

Of the 256 codes that can go in a byte, we take a compact set to cover all
the unique characters in the string. (probably 70 - 100 unique)
Another compact set covers markers, like various forms of insert, or a
change of message number. A yet further set covers keywords.

Markers and characters can then be neatly separated from the codes available
to represent compressed parts of the string.

Terminology:

A "phrase" is a section of the original source, eg "must be a".
A "fragment" is the encoded version of phrase.
Fragments are chosen so that a fragment only appears once in the compressed
data. If the corresponding phrase was used more than once then the one
appearence of the fragment will be cross-referenced.  The one appearence is
called the "referee" and the reference numbers are known as "code points".
The "code points" do not reference the referee directly, they go via an
"index" which gives the offset and length of the fragment.

õ-----------------------------------------------------------------------------*/
static char * McMsg[]={
/* 0*/ "\n Could not open the input.",
/* 1*/ "\n Unacceptable syntax. Acceptable part is:",
/* 2*/ "\n Reading input...",
/* 3*/ "\n %d after keywords. Last message has number %d.%d",
/* 4*/ "\n Two->One. Max merit %d",
/* 5*/ "\n  [%s^",
/* 6*/ "\n Now requirement is %d+%d+%d=%d using %d codes, %d pairs",
/* 7*/ "\n Need to reprogram to allow more pairs.",
/* 8*/ "\n %d Unique original characters.",
/* 9*/ "]%d ",
/*10*/ "\n Code number misorder %d ",
/*11*/ "\n Unused",
/*12*/ "\n One->Two, unit cost %d",
/*13*/ "\nCode Freq Length Offset Gain",
  };
/* This program keeps details of the code points in an array. */
#define CodesZi 700
/* There will be a limit on fragment length. */
/* Another percent to get by making this 33 and using code point order to
distinquish long/short but that is complicated. */
#define FragLimit 17
/* Details about pairs of adjacent characters are also kept. For processing
convenience the original source characters also have elements in this array,
with flag Single to distinguish them. */
/* About 32 bytes per array element, so this array is _huge. */
#define ArrayZi 10000
/* The goal is to use a byte. */
static Ushort Goal = 256;
static Ushort *Source, *Target;  /* Source as sequence of code points. */
static Ushort *pp, *qq, *rr, *ss; /* For scanning source. */
static Ushort NowLen; /* Length of Source */
/* Some variables for the logic of stopping the search for a better
solution. */
static Bool Worthy;        /* Something worth expanding. */
static Bool FirstOf;
static Bool Stopping;      /* Stop forced by loop avoidance. */
static Ushort SpareCodes;  /* Count */
/*ô  */
static Ushort Needed;      /* Number of spares needed for goal. */
static Ushort BreakValue;  /* Increased to reclaim more points. */
static Ushort StrSum;      /* Bytes in the main string. */
static Ushort RefSum;      /* Bytes in the referees */
static Ushort NdxSum;      /* Bytes in the index. */
static Ushort ElemCount;   /* Pairs count */
static Bool ProgMsg; /* Latches an option. */
static Bool MakeAsm; /* Latches output format. */
/* Forward references */
static void SetSource(const char* const fi);
static void Setup(void);
static void Summary(void);
static void SelectTwoOne(void);
static void SelectOneTwo(Ushort, Ushort);
static void Contract(void);
static void RankMerit(void);
static void ReMap(void);
static void PutPacked(void);
#include "is.kwc"
/* At the end of this program are sections for table lookup and debugging. */

/*------------------------------------------------------------------------------
Msgc
õ-----------------------------------------------------------------------------*/
static void Msgc(const char* const fi){
   heapfillfree(HeapFill);
/* There are alternative forms of output. */
   MakeAsm=No;if(strchr(Switches,'A')) MakeAsm=Yes;
/* Some progress messages are optional. */
   ProgMsg=No;if(strchr(Switches,'P')) ProgMsg=Yes;
/* The source is read in, resulting in Source and NowLen being set, and
also space allocated under Target. */
/* The unique characters in the source are recorded. */
   printf(McMsg[2]);
   SetSource(fi);
/* The tables are initialized with the frequencies of characters and pairs. */
   Setup();
   Summary();
/* Some pairs are selected to have code points of their owm. */
NextPass:
/* After a pass, there may be some items to put in ranked order.  */
   if(BorlBug) printf("\nBorlBug NextPass");fflush(stdout);
   RankMerit();
   if(BorlBug) printf("\nBorlBug Ranked");fflush(stdout);
   Worthy=No;
   SelectTwoOne();
   /* BorlBug didn't make it to here. */
#if 0
Borland specific bit unneeded
   if(BorlBug) printf("\nBorlBug TwoOned");fflush(stdout);
   if(heapcheck()==_HEAPCORRUPT) {printf("Heapfail1");exit(1);}
   if(heapfillfree(HeapFill)!=_HEAPOK) {printf("Heapfailf1");exit(1);}
   if(BorlBug) printf("\nBorlBug");fflush(stdout);
#endif
   if(Worthy) Contract(); /* Shorten Source by the substitutions. */
   else goto DoneCompress;  /* Nothing frequent enough to replace. */
   if(BorlBug) printf("\nBorlBug Contract");fflush(stdout);
   if(Stopping) goto DoneCompress; /* Previous reclaim showed no future. */
   if(SpareCodes) goto NextPass;/* Use spare codes until need to reclaim some */
   printf("\nspare codes");
   exit(0);
/* By setting CodesZi high we can avoid avoid coming here but there may be
some small computational reason for supporting a smaller array. */
/* Things may have changed so that previous choices should be backed out. */
   SelectOneTwo(0,CodesZi);
   if(!SpareCodes) goto DoneCompress; /* Exhausted all spare code points. */
#if CHECKS
   RankMerit();
   Checking();
   MeritCheck();
   FreqCheck();
#endif
   goto NextPass;
DoneCompress:;
   if(BorlBug) printf("\nBorlBug DoneComp");fflush(stdout);
#if CHECKS
   Checking();
   MeritCheck();
   FreqCheck();
#endif
/* Feb 94. I have been trying the effect of raising CodesZi until even the
things that only occur twice have acquired a code. */
/* Expand away the unworthy ones even if there are spare code points. */
   SelectOneTwo(0,CodesZi);
/* Then we expand away again until only Goal codes are in use. */
   for(BreakValue=0;SpareCodes<Needed;BreakValue++)
     SelectOneTwo(BreakValue,Needed);
/* The Goal in use are not yet mapped to 0 to Goal-1. */
   ReMap();
/* The answers are used for statistics and to make declarations for
decode-time. */
   PutPacked();
   return;
} /* Msgc */
/*------------------------------------------------------------------------------
Section B: Reading source.
õ-----------------------------------------------------------------------------*/
/* Low level I/O is used */
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <io.h>
/* Note records on first look at source, for subsequent inserts to Source. */
/* Struct to note where markers were */
 struct {
   Wallet w;
   struct{
     Ushort Pos;
     Uchar Mark;
     Uchar KeyVal; /* If Mark is Keyword */
   } e[1];
 } * Note;

static int In; /* File Handle */
static FILE * Inf; /* File Handle */
static short Token;
static Ushort Flength;
static unsigned Textl; /* Length as read. */
static char * Fmem;/* File in memory. */

/* Number and meaning of markers is built into this program. */
#define BumpMajor 0
#define BumpMinor 1
#define Keyword 2
#define MarksUsed 3
/* We note breaks in the range of codes, separating different purposes. */
static Ushort MarksLo, FragsLo, FragsHi;
static void PretendPair(Ushort k, Uchar c, Uchar y);
static Ushort Left, Right; /* See Table lookup. */

static Uchar *p, *q;
#define CrChar 0x0D
#define LfChar 0x0A
#define EosChar 0x1A
static void Skip(void){
/* Skip hurdles whitespace when scanning input. */
  while(*p==' ' || *p==CrChar || *p==LfChar) p++;
}
static void Summary(void){
  Ushort s,t,r;
#if 0
Borland bit not needed
   if(heapcheck()==_HEAPCORRUPT) {printf("Heapfail2");exit(2);}
   if(heapfillfree(HeapFill)!=_HEAPOK) {printf("Heapfailf2");exit(2);}
#endif
  t=CodesZi-SpareCodes-1; /* Codes in use. */
  r=t-(MarksLo-1); /* Excluding singles. */
  r=r-(CodesZi-FragsHi-1); /* Keywords */
  NdxSum=2*r;
  s=StrSum+RefSum+NdxSum;
  printf(McMsg[6],StrSum,RefSum,NdxSum,s,t,ElemCount);
}
/*------------------------------------------------------------------------------
SetSource
õ-----------------------------------------------------------------------------*/
char * Limits[]={"#Limit_EnvironmentName",
              "#Limit_String",
              "#Limit_Literal",
              "#Limit_Name",
              "#Limit_Digits",
              "#Limit_ExponentDigits"};
/* Crude - replacements have to be same length */
char * Limitr[]={"'10',                 ",
              "'50000'     ,",
              "'250'        ,",
              "'250'     ,",
              "'999'       ,",
              "'9'                 ,"};
#if 0
void Tables(void); /* Simplest to take the big tables although only Keys
needed.*/
   extern char Keys[1];
#endif
 static char * QueryKey(void){
/* Compare the upcoming chars with all keywords. */
/* Each item is a length, a result, and the keyword chars. */
/* Each item is data, a length, and the keyword chars. */
   char * u, * v, * w, * bsf ;Ushort n, m, bsfn,i;
   u=Keys+1;
   bsfn=0;
   do{
     n=(Uchar)*u;
    /* printf("\n n=%d",n); */
     if(!n) Failure;
     w=p;
     v=u+1;
     m=n;if(m>16) m-=16;/* Large length is a flag. */
     for(i=m;i>0;i--){
       if(*v++!=*w++) goto NotThis;
       if(w>=Fmem+Flength) goto NotThis;
     }
/* Keyword matches. */
     if(m>bsfn){bsf=u;bsfn=m;}/* Best so far is the longest match. */
NotThis:;
     u=u+m+2;
   } while(*u!=16);
   if(!bsfn) return NULL;
   printf("\n%d for ",bsf-Keys);
   i=*bsf;if(i>16)i-=16;
   for(u=bsf+1;i>0;i--) printf("%c",*u++);
   return bsf;
#if 0
   Tables(); /* Just to reference it. */
#endif
} /* QueryKey */
static Ushort KeyUsed[256];
static Ushort Encode[256]; /* From original character to encoded. */
static void SetSource(const char* const fi){
 Uchar *Sour, *r;

  WalletInit(Note);
/* Read all source to one variable in memory. */
  In=open(fi,O_RDONLY|O_BINARY);
  if(In==-1){
    printf(McMsg[0]);
    longjmp(ErrSig,1);
  }
/* Read into a sufficiently long memory segment. */
  Flength=(Ushort)lseek(In,0L,SEEK_END);   /* This gives length including eof */
  Flength++;
  Fmem=malloc((size_t)Flength);
  lseek(In,0L,SEEK_SET);
#if 0
 As with RD.C, Borland fails on this.
  Textl=read(In,Fmem,65534U);
  if(Textl==-1){perror("");Failure;}
#endif
  close(In);
/* So for Borland read at a higher level. */
  if ((Inf=fopen(fi,"rb"))==NULL){
     printf(McMsg[0]);
     longjmp(ErrSig,1);
  }
   p=Fmem;q=Fmem+Flength;
   while(p<q){
    *p++ = getc(Inf);
   }
  fclose(Inf);
/*------------------------------------------------------------------------------
   Make a copy which is in internal form. (original in Rexx language)
We can't put the markers in at this point but we can note where they go.
õ-----------------------------------------------------------------------------*/
{
short PrevMajor, PrevMinor;
short Major, Minor;
Ushort j;
Uchar Quote;
Ushort t,i;
char * v;
Bool BeginMsg;
   PrevMajor=-1;/* Msgi=0;*/
   PrevMinor=0;
/* Before we make a copy we will make #Limit replacements in place. */
   p=Fmem;q=Fmem+Flength;
   printf("Tail %d %d %d",*(q-2),*(q-1),Flength);
   *(q-1)=170;
   while(p<q){
     for(i=0;i<Dim(Limits);i++){
       t=strlen(Limits[i]);
       if (p+t<q && memcmp(p,Limits[i],t)==0){
/* Our scan doesn't do blank concat, only commas. */
/* So put ',' after anything to left on this line. */
          if (*(p-1)==' '){
            v=p-1;while(*v==' ') v--;
            if(*v!=LfChar) *(p-1)=',';
          }
          memcpy(p,Limitr[i],t);
/* And it can be the last thing. */
/* We "comma'd" after replace to make concat - remove comma if nothing
right of replace on line. */
          if(*(p+t)==CrChar){ *(p+t-1)=' ';}
/* Remove the extra quotes if abuttal */
          if(*(p-1)=='\''){
            v=p+1;
            while(v<p+t){
              *(v-2)=*v++;
            }
          }
       } /* Replace */
     } /* i */
     p++;
   }
   Sour=(Uchar *)malloc((size_t)Flength);
   p=Fmem;q=Sour;
NextAsgn:;
   if(*p==EosChar) goto Done;
   BeginMsg=Yes;
   Skip();if(*p++!='#') goto Error;
  /* Msgi++; */
   while(*p++!='.');
   Major=0;Minor=0;
   while(*p>='0' && *p<='9') Major=10*Major+(Ushort)(*p++ - '0');
   if(*p++!='.') Minor=0;
   else
     while(*p>='0' && *p<='9') Minor=10*Minor+(Ushort)(*p++ - '0');
/* Either Major or Minor should have increased. */
   if(Major<PrevMajor)
       printf(McMsg[10],Major);
   if(Major==PrevMajor)
     if(Minor<=PrevMinor){
       printf(McMsg[10],Major);
     }
   while(PrevMajor<Major){
     j=Note->w.Needs++;WalletCheck(Note);
     Note->e[j].Pos=q-Sour;
     Note->e[j].Mark=BumpMajor;
     PrevMajor++;
     PrevMinor=0;
   }
   while(PrevMinor<Minor){
     j=Note->w.Needs++;WalletCheck(Note);
     Note->e[j].Pos=q-Sour;
     Note->e[j].Mark=BumpMinor;
     PrevMinor++;
   }
   PrevMajor=Major;
   PrevMinor=Minor;
   Skip();if(*p++!='=') goto Error;
MoreString:;
   Skip();
   if(*p!='"' && *p!='\'' ) goto Error;
   Quote=*p;
   p++;
   while(*p && *p!=Quote && *p!=EosChar){
     if((v=QueryKey())==NULL){
       if(BeginMsg){ /* Lower case first char. */
         BeginMsg=No;
         if(*p!='<'){
           if(*p>'_' || *p<'@') Failure; /* Must survive uppercasing */
           *p=(char)(*p+('a'-'A'));
         }
       }
       *q++=*p++;
     }
     else{
       Ushort Kval;
       if(*v==0) Failure;
/* Take note of the keywords */
       BeginMsg=No;
       j=Note->w.Needs++;WalletCheck(Note);
       Note->e[j].Pos=q-Sour;
       Note->e[j].Mark=Keyword;
/* 30-08-96 Key value is now half the offset in table. */
       Kval=(v-Keys)/2;
       if(Kval>255) Failure;
/* The values used are noted, because each has to be made into a 'pair' */
       Note->e[j].KeyVal=(Uchar)Kval;
       KeyUsed[Kval]=Yes;
       t=(Uchar)*v;if(t>16) t-=16;
       p+=t;
     }
   }
   if(*p++!=Quote) goto Error;
/* Comma between strings is blank concat */
   Skip();
   if(*p==','){*q++=' ';p++;Skip();goto MoreString;}
   goto NextAsgn;
Error:;
/* Show source up to error. */
    printf(McMsg[1]);
    printf("m %d %c",*p,*p);
    *(p+1)=0;
    printf("\n'%s'",Fmem);
    longjmp(ErrSig,1);
Done:;
    NowLen=q-Sour;
    printf(McMsg[3],NowLen,Major,Minor);
    free(Fmem);
/*------------------------------------------------------------------------------
  Show how bumping corresponds to MajMin.
õ-----------------------------------------------------------------------------*/
  Major=-1;Minor=0;t=0;
  for(j=0;j<Note->w.Needs;j++){
    i=0;
    if(Note->e[j].Mark==BumpMinor){
      Minor++;t++;i++;
    }
    if(Note->e[j].Mark==BumpMajor){
      Major++;t++;i++;Minor=0;
    }
    if(i){
      printf("\nMsg%d equ %d",100*Major+Minor,t);
    }
  }
}
/*------------------------------------------------------------------------------
   Establish to compact numbering.  Make the declaration for this.
õ-----------------------------------------------------------------------------*/
{
  Ushort j,k;
/* Note which chars used. */
  Clear(Encode);
  r=Sour;q=r+NowLen;
  while(r<q){
    Encode[*r++]=1;
  }
/* Give used characters a compact numbering. */
/* For the first things in the table, the index of the array element is one
more than the encode value. */
  k=1; /* Reserving code point zero. */
  for(j=0;j<256;j++){
    if(Encode[j]){
       Encode[j]=k;
       PretendPair(k,(Uchar)j,0);/* Will be item k in both Point and Tab. */
       k++;
    }
  }
/* Hence the origins of the section for markers and the section to be
given use by this program. */
  MarksLo=k;
  printf(McMsg[8],k-1);
  for(j=0;j<MarksUsed;j++){
    PretendPair(k,'!',0);
    k++;
  }
  FragsLo=k;
  k=CodesZi-1;
/* The keywords are a sort of 'single'. */
/* Put them at the high end so they can get values > 255 */
  for(j=0;j<Dim(KeyUsed);j++){
    if(KeyUsed[j]){
      PretendPair(k,'!',(Uchar)j);
      Goal=Goal+1;  /* Since these will wind up two byte codes. */
      KeyUsed[j]=k;  /* See putting markers in text. */
      k--;
    }
  }
  FragsHi=k;
  printf("\nGoal %d",Goal);
}
/*------------------------------------------------------------------------------
   Replace values by their compact-numbered versions.
õ-----------------------------------------------------------------------------*/
{
  Ushort j;
/* Also go to Ushort for each original character. */
  Source=(Ushort *)malloc(Flength*sizeof(Ushort));
  r=Sour;q=r+NowLen;Target=Source;
  j=0;
  while(r<q){
    while((Ushort)(r-Sour)==Note->e[j].Pos){
/* Can now put the markers in without clash of encodings. */
      if(Note->e[j].Mark!=Keyword)
        *Target=MarksLo+Note->e[j].Mark;
      else{
        *Target=KeyUsed[Note->e[j].KeyVal];
      }
      j++;
      Target++;
    }
    *Target=Encode[*r++];
    Target++;
  }
  free(Sour);
  NowLen=Target-Source;
/* New space for subsequent copying to. */
  Target=(Ushort *)malloc(Flength*sizeof(Ushort));
}
    StrSum=NowLen;
    NdxSum=MarksLo-1;
} /* SetSource */
/*------------------------------------------------------------------------------
   SECTION C: Setup
õ-----------------------------------------------------------------------------*/
/*  The main data arrays.  */
typedef struct Elem {
    struct Elem * Lower;  /* For Table lookup. */
    struct Elem * Higher;
    Ushort Left; /* Of this pair. */
    Ushort Right; /* Of this this pair. */
    struct Elem * MeritUp;
    struct Elem * MeritDown;
    Ushort Merit;  /* Count of pairs to judge "replaceability" */
    Ushort Code;  /* Code point used in the emerging string. */
    unsigned Single:1; /* Not really a pair but an original character item. */
    unsigned OnMerit:1; /* On Merit chains */
    unsigned OnUnranked:1; /* On collection for this pass chain */
    unsigned Coded:1; /* Is one of Point collection */
    char PadTo32[6];
   } Element;
typedef Element * Tablep;
Element Tab[ArrayZi];
static Tablep Table(void);
static Tablep Pair(Ushort l, Ushort r);/* Does look-up of Tab element. */
/* We usually address a Tab element through it's address, rather than
indexing. */
static Tablep Elemp;
/* Element 0 is reserved so ElemCount is also the index of the latest. */
static Ushort ElemCount;
static Ushort ElemCountWas;
/* Point is indexed by developed code points. */
/* Point is connected to the pairs array by Point[].i which gives the index
into Tab for the pair of fragments that are represented by the code. */
/* The Code field in the Tab element is the corresponding index to Point. */
static struct{
  Ushort i; /* Corresponding index in the array. */
  Ushort Freq; /* in the current string, not counting index. */
  Ushort Ascend; /* To chain in ascending frequency. */
  Tablep e; /* In the array. */
  Tablep Above; /* One this the Left of. */
  Ushort With; /* Paired with. (Right of Above). Also Spares chain.  */
  Ushort ShownPos;
  Ushort Length; /* Not reliable until code set stable. */
  Uchar c;  /* Original character */
  Uchar k;  /* Value of keyword. */
  unsigned UsedAsLeft:1; /* This point is a left char of its Above. */
  unsigned UsedAsRight:1;
  unsigned Awkward:1; /* If 'With' speedup can't be used. */
  unsigned Shown:1;
  unsigned OnSpares:1; /* Not in use. */
  unsigned Undecided:1; /* A work bit. */
} Point[CodesZi];
#if CHECKS
static Ushort Freqq[CodesZi];
static Ushort Meritq[ArrayZi];  /* Questionable merit for checking. */
static void CheckRing(Tablep s, char * w);
#endif
/*------------------------------------------------------------------------------
PretendPair - Entering a unique character.
õ-----------------------------------------------------------------------------*/
static void PretendPair(Ushort k, Uchar c,Uchar y){
    Tablep Ep;
/* A single character is made to look like a pair, for uniformity in the
treatment of fragments. */
    Ep=Pair(k,0);
    Ep->Single=Yes;
    Ep->Coded=Yes;
    Ep->Code=k;
    Point[k].Shown=Yes;
    Point[k].e=Ep;
    Point[k].i=Ep-Tab;
    Point[k].c=c; /* Translation to original.*/
    Point[k].Length=1;
    Point[k].k=y; /* Only relevant for keywords */
/* Put it on frequency chain, although it might not be in the right order. */
    Point[k].Ascend=Point[0].Ascend;
    Point[0].Ascend=k;
}
/*------------------------------------------------------------------------------
Phrase - Layout the full plain text corresponding to a code.
It looks like Fragment is used when deciding compaction, Phrase only
used to produce human readable.  Hence can make Phrase have keywords expanded.
See code - could make this work
õ-----------------------------------------------------------------------------*/
/* A linear form of the string is made up by walking the tree of Left
and Right indices. */
static char * Phrase(Tablep);
 typedef struct {
   Wallet w;
   char e[1];
 } Phrasew;
static Phrasew * Phrasep;
static Ushort Recurses;
static void Phrase2(Tablep Ep); /* Recursive from Phrase */
static char * Phrase(Tablep Ep){
  Ushort j;
  Phrasep->w.Needs=0;
  if(Ep->Single)
    Phrase2(Ep);
  else{
    Phrase2(&Tab[Ep->Left]);
    Phrase2(&Tab[Ep->Right]);
  }
/* Make it ASCIIZ */
  j=Phrasep->w.Needs;
  Phrasep->w.Needs++;Phrasep=WalletEx(Phrasep);
  Phrasep->e[j] = '\0';
  return Phrasep->e;
}
static void Phrase2(Tablep Ep){
  Ushort j;
  if(Ep==NULL) Failure;
  if(Ep->Single){
    Ushort t;
    /* Single character/code */
    t = Tab[Ep->Left].Code; /* May have been remapped */
    j=Phrasep->w.Needs;
    Phrasep->w.Needs++;Phrasep=WalletEx(Phrasep);
    if( Point[t].k /* || t>255 */){
      Phrasep->e[j] = '$';
    } else
    {
      Phrasep->e[j] = Point[t].c;
    }
    return;
  }
  /* Pairing */
  if(Recurses++==20) {
    printf("\n %d %d %d  %l", Ep->Left, Ep->Right, Ep-Tab, Ep-Tab);
    j=Phrasep->w.Needs;
    Phrasep->w.Needs++;Phrasep=WalletEx(Phrasep);
    Phrasep->e[j] = '\0';
    printf("\n%s",Phrasep->e);
    Failure;
  }
  Phrase2(&Tab[Ep->Left]);
  Phrase2(&Tab[Ep->Right]);
  Recurses--;
} /* Phrase2 */
/*------------------------------------------------------------------------------
Fragment - Layout a fragment of encoded.
õ-----------------------------------------------------------------------------*/
/* A linear form of the encoding is made up by walking the tree of Left
and Right indices. */
 typedef struct {
   Wallet w;
   Ushort e[1];
 } Frag;
static Frag * Fragp;
static Ushort Recurses;
static void Fragment2(Tablep Ep); /* Recursive from Fragment */
static Ushort * Fragment(Tablep Ep){
  Fragp->w.Needs=0;
  if(Ep->Single)
    Fragment2(Ep);
  else{
    /* Don't stop on first encoded. */
    Fragment2(&Tab[Ep->Left]);
    Fragment2(&Tab[Ep->Right]);
  }
  return Fragp->e;
}
static void Fragment2(Tablep Ep){
  Ushort j;
  if(Ep==NULL) Failure;
  if(Ep->Coded){
    /* Single point encoded */
    j=Fragp->w.Needs;
    Fragp->w.Needs++;Fragp=WalletEx(Fragp);
    Fragp->e[j] = Ep->Code;
    return;
  }
  /* Pairing */
  if(Recurses++==20) {
    printf("\n %d %d %d  %l", Ep->Left, Ep->Right, Ep-Tab, Ep-Tab);
    Failure;
  }
  Fragment2(&Tab[Ep->Left]);
  Fragment2(&Tab[Ep->Right]);
  Recurses--;
} /* Fragment2 */
/*------------------------------------------------------------------------------
FreqCount sets up Freq field.
õ-----------------------------------------------------------------------------*/
static void FreqCount(void){
/* Counters will be zero on entry. */
  qq=Source+NowLen;
  for(rr=Source;rr<qq;rr++){
    Point[*rr].Freq++;
  }
}
/*------------------------------------------------------------------------------
MeritCount estimates potential for pair replacement.
õ-----------------------------------------------------------------------------*/
static void MeritCount(void){
/* Counters will be zero on entry. */
  Tablep Ep;
  qq=Source+NowLen-1;
  for(rr=Source;rr<qq;rr++){
    Ep=Pair(Point[*rr].i,Point[*(rr+1)].i);
/* Must worry about *** being counted as ** twice even though only one ** could
be replaced. */
/* We can compute a correction but there are complications elsewhere in the
algorithm.  Since MeritCount is only a heuristic, we can live with error. */
    Ep->Merit++;
  }
}
/*------------------------------------------------------------------------------
Compare Items. Used by qsort.
õ-----------------------------------------------------------------------------*/
#if 0
Looks like Borland won't take this.
static int CompareItems(Tablep* x,Tablep* y){
  if((*x)->Merit > (*y)->Merit) return -1;
  if((*x)->Merit < (*y)->Merit) return +1;
  return 0;
} /* CompareItems */
#endif
static int CompareItems(const void* x,const void* y){
  if(((*(Tablep*)(x)))->Merit > ((*(Tablep*)y))->Merit) return -1;
  if(((*(Tablep*)(x)))->Merit < ((*(Tablep*)y))->Merit) return +1;
/* Jun 2002. Moving to Borland and having difficulty.  Non-reproducible
qsort may be a problem. So add: */
  if(((*(Tablep*)(x)))->Left > ((*(Tablep*)y))->Left) return -1;
  if(((*(Tablep*)(x)))->Left < ((*(Tablep*)y))->Left) return +1;
  if(((*(Tablep*)(x)))->Right > ((*(Tablep*)y))->Right) return -1;
  if(((*(Tablep*)(x)))->Right < ((*(Tablep*)y))->Right) return +1;
  printf("\nCompare equal!!");
  return 0;
} /* CompareItems */

/*------------------------------------------------------------------------------
Setup
õ-----------------------------------------------------------------------------*/
static Ushort SpareCodesAnchor;
static void SparesInc(Ushort j){
/* Note a spare code point. */
/* Cannot Clear(Point[j]) because not really 'Spare' until Expand has
finished. */
    Point[j].With=SpareCodesAnchor;
    SpareCodesAnchor=j;
    Point[j].OnSpares=Yes;
    SpareCodes++;
}
Ushort SparesDec(void){
   Ushort j;
/* Make use of previously spare code point. */
    j=SpareCodesAnchor;
    SpareCodesAnchor=Point[j].With;
    Point[j].OnSpares=No;
    Point[j].Ascend=Point[0].Ascend;
    Point[0].Ascend=j; /* May not be sorted yet. */
    SpareCodes--;
    return j;
}
static void SortChain(void){
/* To keep the Ascend chain in order. */
/* There are quicker ways but normally it will be partially ordered. */
  Ushort Cursor, DiscLo, DiscHi;
  Bool Done;
/* Reverse in the small, and try again. */
  for(;;){
    Done=Yes;/* Maybe */
    Cursor=0;
    for(;;){
      DiscLo=Point[Cursor].Ascend;
      if(!DiscLo) break;
      DiscHi=Point[DiscLo].Ascend;
      if(!DiscHi) break;
      if(Point[DiscLo].Freq>Point[DiscHi].Freq){
        Point[DiscLo].Ascend=Point[DiscHi].Ascend;
        Point[DiscHi].Ascend=DiscLo;
        Point[Cursor].Ascend=DiscHi;
   /*     DiscHi=DiscLo;  Not used. */
        DiscLo=Point[Cursor].Ascend;
        Done=No;
      }
      Cursor=DiscLo;
    }
    if(Done) break;
  }
}
static Ushort Break256;
static void Setup(void){
  Ushort j;
/*ô  */
  WalletInit(Fragp); /* Holds latest Fragment result. */
  WalletInit(Phrasep); /* Holds latest plain text result. */
  Needed=CodesZi-1-Goal;/* Number of spares when Goal code points */
  Break256=CodesZi-256;/* Number of spares when 256 code points */
  ElemCountWas=ElemCount;
  for(j=FragsLo;j<=FragsHi;j++){
    SparesInc(j);
  }
  Tab[0].Single=Yes; /* For tracing */
/*------------------------------------------------------------------------------
 Note the frequencies of the code points.
õ-----------------------------------------------------------------------------*/
  FreqCount();
  SortChain();
#if 0
  for(j=Point[0].Ascend;j;j=Point[j].Ascend){
    printf("\nj %d %d %s",j,Point[j].Freq,Phrase(Point[j].e));
  }
#endif
/*------------------------------------------------------------------------------
    Note items corresponding to each consecutive pair in the source.
This method counts '***' as two of '**' although only one could be
replaced.  However, the count is only used as a heuristic.
õ-----------------------------------------------------------------------------*/
  MeritCount();
/*------------------------------------------------------------------------------
   Index sort on Merit.
õ-----------------------------------------------------------------------------*/
{ /* Make a list of the Merit item indices. */
  Tablep* Isort;Ushort j;
  Ushort PairCount;
  PairCount=ElemCount-ElemCountWas;
#if 0
  Isort=(Tablep*)malloc(PairCount*sizeof(Tablep*));
#endif
  Isort=(Tablep*)malloc(PairCount*sizeof(Tablep));
  for(j=0;j<PairCount;j++){
    Isort[j]=&Tab[ElemCountWas+j]; /* Address of pair in lookup tree.*/
  }
  /* Sort the list */
  qsort(Isort,PairCount,sizeof(Tablep),CompareItems);
/* Chain in merit order. */
  Tab[0].MeritUp=&Tab[0]; /* Empty chain */
  for(j=0;j<PairCount;j++){
    Isort[j]->MeritUp=Tab[0].MeritUp;
    Tab[0].MeritUp=Isort[j];
  }
/* Chain both ways. */
  Elemp=Tab;
  do{
    Elemp->OnMerit=Yes;
    (Elemp->MeritUp)->MeritDown=Elemp;
    Elemp=Elemp->MeritUp;
  } while(Elemp!=Tab);
  Elemp=Tab;
}
} /* Setup */
/*------------------------------------------------------------------------------
   SECTION D: Select for Two->One replacement, One->Two replacement.
õ-----------------------------------------------------------------------------*/
static Ushort BreakNow;  /* Increased to prevent interference. */
static void NotNow(void){
/* To note one we could not use on this pass. */
   if(BorlBug) printf("\nBorlBug NotNow");fflush(stdout);
  BreakNow=Elemp->Merit; /* Don't take things of less merit before this */
  /* Huge %s only works on own? */
  if(ProgMsg){
    printf("\n  %d",Elemp->Merit);
    printf("'%s' ",Phrase(Elemp));
  }
   if(BorlBug) printf("\nBorlBug NotNowExit");fflush(stdout);
}
/*------------------------------------------------------------------------------
SelectTwoOne - Replace a pair by a code throughout the source.
õ-----------------------------------------------------------------------------*/
static Bool EndGame, EndGameLatch;
static void SelectTwoOne(void){
/* We will take pairs of highest merit (frequency) in preference.  */
   Tablep Leftp, Rightp;
   Ushort LeftCode, RightCode; /* Leftp->Code... */
   Ushort Fragl;
   printf(McMsg[4],Tab[0].MeritDown->Merit); /* "Taking" */
   if(BorlBug) printf("\nBorlBug 21in");fflush(stdout);
/* Select points in order of merit. */
   BreakNow=2;
   EndGame=Yes; /* Maybe */
/* We try to find several replacements for one pass on string. */
  for(Elemp=Tab[0].MeritDown;Elemp;Elemp=Elemp->MeritDown){
   if(BorlBug) printf("\nBorlBug looptop");fflush(stdout);
/* It may not be right to look at low merit items. */
   if(Elemp->Merit<BreakNow) goto EndFindPairs;
/* We may have just used last available code point. */
   if(SpareCodes==0) goto EndFindPairs;
   Left=Elemp->Left;Leftp=&Tab[Left];
   Right=Elemp->Right;Rightp=&Tab[Right];
#if 0
   if(BorlBug) printf("\nBorlBug LR");fflush(stdout);
/* It won't be worth taking something where the pair only appears twice
unless the use of the pair will move into just the use in the referee. */
   if(BorlBug) printf("\nBorlBug M %d",Elemp->Merit);fflush(stdout);
   if(BorlBug) printf("\nBorlBug L %d",Left);fflush(stdout);
/* That came as 4853 */
   if(Left>CodesZi) {printf("Range");exit(33);}
   if(BorlBug) printf("\nBorlBug Lf %d",Point[Left].Freq);fflush(stdout);
   if(BorlBug) printf("\nBorlBug Rf %d",Point[Right].Freq);fflush(stdout);
   if(Elemp->Merit==2)
     if(Point[Left].Freq!=2 || Point[Right].Freq!=2) continue;
   if(BorlBug) printf("\nBorlBug LRx");fflush(stdout);
#endif
   if(Elemp->Merit==2) continue;
/* We can't take a pair unless both currently given values in Point. */
   if(Leftp->Coded==No || Rightp->Coded==No){
      NotNow();
      continue;
   }
   if(BorlBug) printf("\nBorlBug LRy");fflush(stdout);
/* If it is involved in some pairing that is "in play' for this pass we
can't use it because the replacement implied by the first pairing will
affect the frequency of the second. */
/* If we applied this rule sternly we would never table a 'doublet' like **
since its left interferes with its right.  In practice we take it and
special case the problems resulting. */
/* If replacement has it on the left, other pairs can't use it on the right.*/
   LeftCode=Leftp->Code;RightCode=Rightp->Code;
   if(Point[LeftCode].UsedAsRight || Point[RightCode].UsedAsLeft){
      NotNow();
      continue;
   }
/* We won't take if total fragment length would exceed the limit. */
   if(BorlBug) printf("\nBorlBug PreFrag");fflush(stdout);
   Fragment(Leftp);
   Fragl=Fragp->w.Needs;
   Fragment(Rightp);
   Fragl+=Fragp->w.Needs;
   if(Fragl>FragLimit) continue;
/* Beware loops from putting 'doublers' in and then out. */
   if(LeftCode==RightCode){
     if(EndGameLatch && Elemp->Merit<=(Ushort)(2*BreakNow)) continue;
   }
   else EndGame=No;
   Worthy=Yes;
   Elemp->Coded=Yes;
   Elemp->Code=SparesDec();
   Point[Elemp->Code].e=Elemp;
   if(BorlBug) printf("\nBorlBug Midset");fflush(stdout);
   Point[Elemp->Code].i=Elemp-Tab;
   Point[Elemp->Code].c='$'; /* Shouldn't be used. */
   Point[LeftCode].UsedAsLeft=Yes;
   Point[RightCode].UsedAsRight=Yes;
/* With & Above are a speedup for simple cases. */
/* With records the other half of the pair being replaced, in the left half. */
   if(BorlBug) printf("\nBorlBug Mostset");fflush(stdout);
   if(Point[LeftCode].With) Point[LeftCode].Awkward=Yes; /* With already in use. */
   else{
     if(BorlBug) printf("\nBorlBug Condset");fflush(stdout);
     Point[LeftCode].With=Right; /* Records the pair. */
     Point[LeftCode].Above=Elemp; /* Records point for pair */
   }
   if(BorlBug) printf("\nBorlBug Allset");fflush(stdout);
   if(ProgMsg){
   if(BorlBug) printf("\nBorlBug ProgMsg");fflush(stdout);
/* Show a message. */
/* Two %s didn't seem to work.  A _huge problem? */
     printf(McMsg[5],Phrase(&Tab[Left]));
     printf("%s",Phrase(&Tab[Right]));
     printf(McMsg[9],Elemp->Merit);
     printf("(%d)%d",Elemp->Code,Point[Elemp->Code].i);
#if 0
     if(Point[Elemp->Code].i==5029){BorlBug = Yes;printf("BB");fflush(stdout);}
#endif
   }
   if(BorlBug) printf("\nBorlBug PostProgMsg");fflush(stdout);
 } /* Merit loop */
   if(EndGame) EndGameLatch=Yes;/* Everything selected was a doublet. */
EndFindPairs:;
   if(BorlBug) printf("\nBorlBug loopexit");fflush(stdout);
}
/*------------------------------------------------------------------------------
Substitute for these pairs, in the string.
õ-----------------------------------------------------------------------------*/
/* During this process, the merit counts are updated en passant. */
static void MeritDec(Ushort l, Ushort r);
static void MeritInc(Ushort l, Ushort r);
static void UnMerit(Tablep e);
static void Contract(void){
{
       Ushort LeftCode, RightCode; /* Leftp->Code... */
       Ushort j;
 Ushort En;Ushort Eni;Ushort R2;
  rr=Source;qq=rr+NowLen;ss=Target;
   if(BorlBug) printf("\nBorlBug precycle");fflush(stdout);
Cycle:;
  while(rr<qq){
    LeftCode=*rr;
    Left=Point[LeftCode].i; /* From encoded to index */
#if 0
    if(Left==1734) printf("\npre1734 %d %d %s",
        *ss,LeftCode,Phrase(Point[*ss].e));
#endif
    En=0;
    if(Point[LeftCode].UsedAsLeft && rr+1!=qq){
/* *rr and *(rr+1) are an possible instance of pair to be replaced. */
      RightCode=*(rr+1);
      if(Point[RightCode].UsedAsRight){
/* Still not necessarily a replacing pair. */
        Right=Point[RightCode].i;
        if(Point[LeftCode].Awkward){
          Elemp=Table();
          En=Elemp->Code;/* No pair can have En nonzero unless to-be-changed */
        }
        else{
          if(Point[LeftCode].With==Right){
            Elemp=Point[LeftCode].Above;
            En=Elemp->Code;
          }
        }
      } /*Both flagged */
    } /* Left flagged */
    if(En){
/* Yes, a pair being replaced this pass, by Elemp pair. */
      StrSum--;
      Point[En].Freq++;
      Point[RightCode].Freq--;
      Point[LeftCode].Freq--;
/* Make the Merit reflect output string. */
      if(Elemp->OnMerit) UnMerit(Elemp);
      Elemp->Merit--;
      Eni=Point[En].i;
      R2=Right; /* The Merit... routines hit Left & Right. */
      if(rr!=Source){
        MeritDec(Point[*(ss-1)].i,Left);
        MeritInc(Point[*(ss-1)].i,Eni);
      }
      pp=rr+2;
      if(pp<qq){
        MeritDec(R2,Point[*pp].i);
        MeritInc(Eni,Point[*pp].i);
      }
      *ss++=En;rr=pp;
      goto Cycle;
    }
    *ss++=*rr++; /* Unaltered copy. */
  }
  NowLen=ss-Target;ss=Source;Source=Target;Target=ss;
  Summary();
#if 0
  FreqCheck();
#endif
/* Clear the flags from this pass. */
  for(j=1;j<Dim(Point);j++){
    Point[j].UsedAsLeft=No;
    Point[j].UsedAsRight=No;
    Point[j].Awkward=No;
  }
/* A pair gone to zero freq can have its code point reclaimed. */
  SortChain();
  j=0;
  for(;;){
    Ushort k;
    k=Point[j].Ascend;
    if(k==0) break;
    if(Point[k].Freq!=0) break;
    if(Point[k].OnSpares) Failure;
    if(Point[k].e->Single==No){
      Point[j].Ascend=Point[k].Ascend;
      SparesInc(k);
      Elemp=Point[k].e;
      Elemp->Coded=No;
      Elemp->Code=0;
    }
    else j=k;
  }
} /* Replacing */
}
/*------------------------------------------------------------------------------
SelectOneTwo - Replace a code by its constituents, throughout the source.
õ-----------------------------------------------------------------------------*/
static void Expand(void);
static Bool Decided; /* An output of Cost2. */
static Ushort Reclaimed;
static Ushort Cost2(Ushort i){
/* Binary walk for determining length of a replacement. */
/* Same as fragment length except for 'decided' tests. */
  Tablep e;Ushort t;
  e=&Tab[i];
  if(e->Single) return 1;
  if(e->Coded && Point[e->Code].Undecided) Decided=No;
  if(e->Coded){
    if(Point[e->Code].Undecided) Decided=No;
    return 1;
  }
  t=Cost2(e->Left)+Cost2(e->Right);
  return t;
}
static Ushort Cost(Ushort i){
  Tablep e;Ushort t;
  e=&Tab[i];
  if(e->Single) Failure;
/* Cost when expanded. */
  t=Cost2(e->Left)+Cost2(e->Right);
#if 0
/* Cost of expanding is not so much if the short form would have been
two bytes. */
  if(SpareCodes<Break256) t--;
#endif
  return t;
}
static void SelectOneTwo(Ushort Break, Ushort g){
/* Free up everything at cost Break or less, until there are g spares. */
  Ushort j,m,k;
  printf(McMsg[12],Break);
/* A code point may have been used once, but no longer in the string.
because only used as part of a fragment. */
/* Or it may be suitable to be expanded away. */
/* There has to be an iteration because the cost of expanding can (often)
only be made when the decision has been made about its components. */
  for(j=FragsLo;j<=FragsHi;j++){
    Point[j].Undecided=Yes;
  }
NextTry:
  Reclaimed=0;
  for(j=FragsLo;j<=FragsHi;j++){
    if(SpareCodes>=g) goto Done;
    if(Point[j].OnSpares) continue;
    m=Point[j].Freq;
    if(m==0) Failure;
/* Expanding might cost more than just 1 becoming 2 if the target two
didn't already have codes.  Hence the more complicated cost calculation. */
    Decided=Yes;/* We hope */
    k=Cost(Point[j].i)-1; /* Extra length per instance. */
    if(Decided==No) continue;
    Point[j].Undecided=No;
    /* Index cannot cope with referees longer than FragLimit. */
    if(k>FragLimit || k*m<=Break){
      Elemp=Point[j].e;
      if(ProgMsg){
        Left=Elemp->Left;
        Right=Elemp->Right;
        printf(McMsg[5],Phrase(&Tab[Left]));
        printf("%s",Phrase(&Tab[Right]));
        printf(McMsg[9],m);
        Fragment(Elemp);
        printf("%d %d",k,Fragp->w.Needs);
        printf(" (%d)%d",Elemp->Code,Point[Elemp->Code].i);
      }
      SparesInc(j);
      Reclaimed++;
      StrSum-=Point[j].Freq;
      Point[j].Freq=0; /* They will be all expanded away. */
      Elemp->Coded=No;
      Elemp->Code=0;
    } /* Flagged to expand. */
  } /* Codes, j */
Done:
  if(Reclaimed){
    Expand(); /* Lengthen source, freeing code points. */
    goto NextTry; /* Since less undecided. */
  }
  Summary();
} /* SelectOneTwo */
/*------------------------------------------------------------------------------
  Expand away any rejected codes.
õ-----------------------------------------------------------------------------*/
/* Fshow used non-debug when errors detected. */
static void Fshow(Tablep x){
  Tablep l,r;
  if(x->Single){
    printf("'%c'",Point[x->Code].c);
    return;
  }
  l=&Tab[x->Left];
  r=&Tab[x->Right];
  printf("[%d",(Ushort)(x-Tab));
  printf("^");
  printf("%s",Phrase(l));
  printf("^");
  printf("%s",Phrase(r));
  printf("^");
  printf("%d",x->Left);
  if(l->Coded)printf("(%d)",l->Code);
  printf("^");
  printf("%d",x->Right);
  if(r->Coded)printf("(%d)",r->Code);
  printf("]");
}
static void PlaceOut(Ushort Pre, Ushort Plus, Ushort Post);
static Tablep Unranked; /* Pending insertion. */
static Ushort LastClaim;
/*------------------------------------------------------------------------------
Expand
õ-----------------------------------------------------------------------------*/
static void Expand(void){
  Ushort m,n;
/* Merit will change so collect for remerge. */
  Unranked=NULL;
  rr=Source;qq=rr+NowLen;ss=Target;
  while(rr<qq){
/* Cannot expand away a letter. */
    if(*rr>=FragsLo && *rr<=FragsHi && Point[*rr].Freq==0){
      m=0;if(ss!=Target) m=Point[*(ss-1)].i;
      n=0;if(rr+1<qq) n=Point[*(rr+1)].i;
#if 0
      if(ElemCount>=5289){
        printf("\n");
        if(m) Fshow(&Tab[m]);
        Fshow(Point[*rr].e);
        if(n) Fshow(&Tab[n]);
        printf(" at %d %d %d",(Ushort)(rr-Source),*(ss-1),*rr);
      }
#endif
      PlaceOut(m,Point[*rr].i,n);
      rr++;
    } /* Expand */
    else *ss++=*rr++;
  }
   NowLen=ss-Target;ss=Source;Source=Target;Target=ss;
   if(NowLen==LastClaim) Stopping=Yes;
   LastClaim=NowLen;
}
static void PlaceCode(Tablep t){
     *ss++=t->Code;Point[t->Code].Freq++;StrSum++;
}
static void PlaceInc(Ushort Pre, Ushort x, Ushort Post){
/* x being added, in this context. */
#if 0
      Tablep t;
      printf("\n PMI %d %d %d",Pre, x, Post);
      t=&Tab[x];
#endif
      if(Pre){
        MeritInc(Pre,x);
      }
      if(Post){
        MeritInc(x,Post);
      }
}
static void PlaceDec(Ushort Pre, Ushort x, Ushort Post){
/* x going away, in this context. */
#if 0
      Tablep t;
      printf("\n PMD %d %d %d",Pre, x, Post);
      t=&Tab[x];
#endif
      if(Pre){
        MeritDec(Pre,x);
      }
      if(Post){
        MeritDec(x,Post);
      }
}
static void PlaceOut(Ushort Pre, Ushort Plus, Ushort Post){
/* The bytes *ss are to have the expansion of the
fragment represented by Plus. Following byte is Post,
Post=0 if none. Previous byte is Pre, or zero if none. */

/* Redeclare the variables because we will need to recurse. */
  Tablep Plusp,Xp;
  Ushort Xi,Xpre;

      if(Recurses++==20) Failure;
#if 0
      printf("\n PO %d %d %d",Pre,Plus, Post);
#endif
      if(Plus==0) Failure;
      Plusp=&Tab[Plus];
#if 0
      printf("\n@");
      Fshow(Plusp);
#endif
/* Update for Plus going away. */
      PlaceDec(Pre,Plus,Post);
/* Expansion of Plus to be inserted. */
      if(Plusp->Single){
        Failure;
      }
/* We update Merit to reflect the LeftCode & RightCode of Plus. */
      Xi=Plusp->Left;
      Xp=&Tab[Xi];
/* First put Xi merit-wise in. */
/* We have given merit for Left before Right, mustn't double account
by having Right after Left. */
/* This time we say 'before nothing' and when we insert Right we say
'after something'. */
      PlaceInc(Pre,Xi,0);
      if(Xp->Coded){
         PlaceCode(Xp); /* Really add it. */
      }
      else{
        PlaceOut(Pre,Xi,0); /* Post-char isn't there yet.*/
      }
/* Now Pre will have changed. */
      Xpre=Point[*(ss-1)].i;
      Xi=Plusp->Right;
      Xp=&Tab[Xi];
      PlaceInc(Xpre,Xi,Post);
      if(Xp->Coded){
         PlaceCode(Xp);
      }
      else{
        PlaceOut(Xpre,Xi,Post);
      }
#if 0
      printf("$\n");
#endif
      Recurses--;
} /* Place Out */
/*------------------------------------------------------------------------------
   SECTION E: Tracking the merit of the pairs.
RankMerit.  The routines that alter and sort on the merit counts.
õ-----------------------------------------------------------------------------*/
static void UnMerit(Tablep e){
/* To take an item out of the ordered merit chain onto the Unranked chain
and set OnUnranked flag. */
    if(e->OnMerit==No) Failure;
    e->OnMerit=No;
    (e->MeritUp)->MeritDown=e->MeritDown;
    (e->MeritDown)->MeritUp=e->MeritUp;
/* Temp used of MeritUp. */
    e->MeritUp=Unranked;Unranked=e;e->OnUnranked=Yes;
}
static void MeritDec(Ushort l, Ushort r){
  Tablep e;
  Left=l;Right=r;e=Table();
  e->Merit--;
  if((short)e->Merit<0){
    printf("\n");Fshow(e);Failure;
  }
  if(e->OnMerit){
    UnMerit(e);
  }
}
static void MeritInc(Ushort l, Ushort r){
  Tablep e;
  if(r==0) Failure;
  Left=l;Right=r;e=Table();
  if(e->OnUnranked==No && e->OnMerit==No){
/* Must have just been made. */
    e->MeritUp=Unranked;Unranked=e;e->OnUnranked=Yes;
  }
  if((short)e->Merit<0){
    printf("\n");Fshow(e);Failure;
  }
  e->Merit++;
  if(e->OnMerit){
    UnMerit(e);
  }
}
/*------------------------------------------------------------------------------
RankMerit
õ-----------------------------------------------------------------------------*/
#define AsideZi 21
static Tablep Aside[AsideZi]; /* To speed up Insert. */
static void Insert(Tablep e);
static void RankMerit(void){
  Ushort j;
/* A lookaside table of fairly arbitary size. */
/* The elements altered in this pass have to be inserted into the merit
chain. */
  for(j=0;j<AsideZi;j++) Aside[j]=NULL;
  while(Unranked){
    Elemp=Unranked;
    Unranked=Elemp->MeritUp; /* They were on temp chain. */
    Elemp->OnUnranked=No;
    Insert(Elemp);
#if 0
 printf("\nInsert %d %d %s",(Ushort)(Elemp-Tab), Elemp->Merit, Phrase(Elemp));
#endif
  }
}
static void Insert(Tablep e){
  Tablep t; /* Trial point. */
  Ushort j;
  j=e->Merit;
  j=Min(j,20);
  if(Aside[j]){
    t=Aside[j];if(t->OnMerit==No){
      printf("\n%d %d",j, (Ushort)(t-Tab));
      Failure;
    }
  }
  else{
    if(e->MeritDown && (e->MeritDown)->OnMerit) t=e->MeritDown;/* Near where
before */
     else t=&Tab[0];
  }
  if(t->OnMerit==No) Failure;
/* Spin up or down from trial point. */
  if(e->Merit>t->Merit){ /* Equals MeritDown because t may be zero. */
    do{
      if(e->Merit<=t->Merit) break;
      t=t->MeritUp;
    } while(t!=&Tab[0]);
    e->MeritUp=t;e->MeritDown=t->MeritDown;
    t->MeritDown=e;(e->MeritDown)->MeritUp=e;
  }
  else{
    while(t!=&Tab[0]){
      if(e->Merit>=t->Merit) break;
      t=t->MeritDown;
    }
    e->MeritDown=t;e->MeritUp=t->MeritUp;
    t->MeritUp=e;(e->MeritUp)->MeritDown=e;
  }
  e->OnMerit=Yes;
  Aside[j]=e;
}
/*------------------------------------------------------------------------------
   SECTION F: PutPacked - Producing the results.
õ-----------------------------------------------------------------------------*/
Ushort MappedZi;
static void ReMap(void){
  Ushort j;Ushort Map[CodesZi];
  MappedZi=0;
  for(j=1;j<CodesZi;j++){
    if(Point[j].OnSpares==No){
      Point[MappedZi]=Point[j];    /* Copy lower on Point. */
      Tab[Point[j].i].Code=MappedZi;  /* Direct Tab to new position. */
      Map[j]=MappedZi++;  /* Prior point j now will map to point MappedZi. */
    }
  }
  FragsLo--;/* Since 0 now in play. */
  MarksLo--;
  qq=Source+NowLen;
  for(rr=Source;rr<qq;rr++){
    *rr=Map[*rr]; /* Source now reflects remap. */
  }
}
/*------------------------------------------------------------------------------
ShowCode puts one unit (byte unless experimenting) into the declaration of
output.  May 94 - two bytes for keywords.
õ-----------------------------------------------------------------------------*/
static Ushort CodedCount, CodedCountWas;
static Ushort Code;
/* Don't know what Units was meant to be but not # of bytes. So reset. */
static Ushort Units;
static void ShowCode(Ushort c){
/* For assembler I want the order changed, so that special cases are
the numbers 0,1, and 2. */
    if(MakeAsm){
      if(c==MarksLo+Keyword) c=0;
      else if(c==MarksLo+BumpMinor) c=1;
      else if(c==MarksLo+BumpMajor) c=2;
      else if(c<FragsLo) c=c+3;
    }
    if(c>255){
      ShowCode(MarksLo+Keyword); /* Keyword prefix */
      c=Point[c].k; /* Keyword value */
    }
    else Units++;
    CodedCount++;
    if(!FirstOf)
      ShowC(',');
    FirstOf=No;
    ShowD(c);
    if(QryColumn()>70){
/* Assembler wont take lots of continuations. */
      if(MakeAsm){
        NewLine();
        ShowS(" db ");
        FirstOf=Yes;
      }
      else NewLine();
    }
    return;
#if 0
/* I wanted to do this with a long literal but MS 6.0 has 2K limit. */
    if(c<32){
      ShowS("\\0x");
      if(c<16) ShowC('0');else{ShowC('1');c-=16;}
      ShowC(HexDigits[c]);
    }
    else {if(c=='\\' || c=='\"') ShowC('\\');ShowC(c);}
#endif
}
/*------------------------------------------------------------------------------
PutPacked - Show declarations for the text.
õ-----------------------------------------------------------------------------*/
static void PutPacked(void){
  Tablep e;Uchar * s;Ushort i,j,k;Ulong Total;Ushort Referees;
/* Show declaration of the uniques */
  NewLine();
  if(MakeAsm)
    ShowS("MsgcUniques db ");
  else
    ShowS(" unsigned char MsgcUniques[]={");
  FirstOf=Yes;
  /* Set k to last */
  for(j=0;j<256;j++){
    if(Encode[j]) k=j;
  }
  for(j=0;j<256;j++){
    if(Encode[j]){
       if(!FirstOf) ShowC(',');
       FirstOf=No;
       ShowD(j);
/* Bit of a mess because not easy to test for last. */
       if(QryColumn()>70 && MakeAsm && j!=k){
         NewLine();
         ShowS(" db ");
         FirstOf=Yes;
       }
    }
  }
  if(MakeAsm){
    NewLine();
    ShowS("MsgcFragsLo equ ");ShowD(FragsLo);
    NewLine();
/* The packed text: */
    ShowS("MsgcPacked db ");
  }
  else{
    ShowS("};");
    NewLine();
    ShowS("#define MsgcMarksLo ");ShowD(MarksLo);
    NewLine();
    ShowS("#define MsgcFragsLo ");ShowD(FragsLo);
    NewLine();
/* The packed text: */
    ShowS("unsigned char MsgcPacked[]={");
  }
  qq=Source+NowLen;CodedCount=0;
  FirstOf=Yes;
  for(rr=Source;rr<qq;rr++){
    Code=*rr;
    if(Point[Code].Shown){
      ShowCode(Code);
      continue;
    }
    Point[Code].ShownPos=CodedCount;
    Point[Code].Shown=Yes;
    e=Point[Code].e;
    ss=Fragment(e);
#if 0
    keywords!
    Point[Code].Length=Fragp->w.Needs;
#endif
    CodedCountWas=CodedCount;
    for(j=0;j<Fragp->w.Needs;j++){
      ShowCode(*ss++);
    }
    Point[Code].Length=CodedCount-CodedCountWas;
  }
  if(MakeAsm){
    /* Previous could have ended with just DB */
    if(FirstOf) ShowS(" 0 dup(?)");
    NewLine();
    ShowS("MsgcUnits equ ");ShowD(CodedCount /* Not Units */);
    NewLine();
/* The index */
    ShowS("MsgcIndex dw ");
  }
  else{
    ShowS("};");
    NewLine();
    ShowS("#define MsgcUnits ");ShowD(CodedCount /* Not Units*/);
    NewLine();
/* The index */
    ShowS("unsigned short MsgcIndex[]={");
  }
  FirstOf=Yes;
  for(j=FragsLo;j<256;j++){
    if(!FirstOf)
      ShowC(',');
    FirstOf=No;
    ShowD(16*Point[j].ShownPos+Point[j].Length-2);
    if(QryColumn()>70 && j!=255)
      if(MakeAsm){
        NewLine();
        ShowS(" dw ");FirstOf=Yes;
      }
      else NewLine();
  }
  if(!MakeAsm)
    ShowS("};");
  NewLine();
/* Display characteristics of the codes. */
/* Code Freq Length Offset Gain */
  printf(McMsg[13]);
  Total=0;Referees=0;
  for(j=0;j<MappedZi;j++){
    Ushort f;
    if(j==111) printf("111a");
    if(j==112) printf("112a");
    fflush(stdout);
    if(Point[j].OnSpares) Failure;
    f=Point[j].Freq;
    k=Point[j].Length;
    s=Phrase(Point[j].e);
    printf("\n%3d %4d %2d %5d %4d",j,f,k,Point[j].ShownPos,k*f-(k+f-1));
    printf(" [%s]",s);
    if(Point[j].k) printf(" %d",Point[j].k);
    if(j==111) printf("111b");
    if(j==112) printf("112b");
    fflush(stdout);
    Total+=Point[j].Freq;
    Referees+=k-1;
    if(ProgMsg){
      printf("\n");
      ss=Fragment(Point[j].e);
      for(i=0;i<k;i++){
         if(j==111){ printf("\n111%d %dx",i,k);fflush(stdout);}
         if(j==111 && i==24){ printf("\n24 %d",*(ss+i));fflush(stdout);}
         printf("[%s]",Phrase(Point[*(ss+i)].e));
         fflush(stdout);
      }
#if 0
/* Can't do this surely - its part of a wallet. */
      free(s);
#endif
    }
    if(j==111) printf("111c");
    fflush(stdout);
  }
  printf("\n Total %ld+%d=%ld",Total,Referees,Total+(Ulong)Referees);
    fflush(stdout);
 return;
} /* PutPacked */
/*------------------------------------------------------------------------------
   SECTION G: Table - lookup
õ-----------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------
Pair is a wrapper to Table.
õ-----------------------------------------------------------------------------*/
static Tablep Pair(Ushort LeftArg, Ushort RightArg){
   Left=LeftArg;Right=RightArg;
   return Table();
}
/*------------------------------------------------------------------------------
Subroutine Isit tests whether something is already in the symbol dictionary.
õ-----------------------------------------------------------------------------*/
static int IsIt(Tablep Subject){
  if(Subject->Left > Left) return +1;
  if(Subject->Left < Left) return -1;
  if(Subject->Right> Right) return +1;
  if(Subject->Right< Right) return -1;
  return 0;
}
/*------------------------------------------------------------------------------
Subroutine MakeIt makes a symbol item.
õ-----------------------------------------------------------------------------*/
static Tablep MakeIt(void){
 Tablep Subject;
 ElemCount++;          /* Zeroth reserved. */
 /* Dim nogood for huge? */
 if(ElemCount==ArrayZi){
   printf("\n %d",ElemCount);
    printf(McMsg[7]);
    longjmp(ErrSig,1);
 }
 Subject=&Tab[ElemCount];
 Subject->Left=Left;
 Subject->Right=Right;
 return Subject;
}
#define Array Tab
/* IsIt returns int result of comparison result. (Ptr arguments) */
/* MakeIt returns address of added element.
/* Table sets Array[0].Lower and returns it. */
#include "table.i"
/*------------------------------------------------------------------------------
   SECTION H: Only for debugging.
õ-----------------------------------------------------------------------------*/
#if CHECKS
static void Checking(void){
  Tablep Ep;Ushort g;
/* Checking */
#if 0
Borland specific
  if(_heapchk()!=_HEAPOK){
    Failure;
  }
#endif
  Ep=Tab[0].MeritUp;
  while(Ep!=&Tab[0]){
    g=1;
    if((Ushort)(Ep-Tab)>ElemCount) goto Fail;
    g=2;
    if((short)Ep->Merit<0) goto Fail;
    g=3;
    if((Ushort)Ep->Merit>NowLen) goto Fail;
    g=4;
    if((Ep->MeritDown)->MeritUp!=Ep) goto Fail;
    g=5;
    if((Ep->MeritUp)->MeritDown!=Ep) goto Fail;
    g=6;
    if((Ep->MeritDown)->Merit>Ep->Merit) goto Fail;
    g=7;
    if((Ep->MeritUp)!=&Tab[0])
      if((Ep->MeritUp)->Merit<Ep->Merit) goto Fail;
    Ep=Ep->MeritUp;
  }
  printf("\n Checking");
  return;
Fail:;
  printf("\n Fails %d %d",g,(Ushort)(Ep-Tab));
  Ep=Tab;
  do{
    printf("\n %d Merit %d",(Ushort)(Ep-Tab),Ep->Merit);
    Fshow(Ep);
    Ep=Ep->MeritUp;
  } while(Ep!=Tab);
  Failure;
}
static void CheckRing(Tablep s, char * w){
  Tablep t;Bool b;
  t=Unranked;
  while(t){
    if(t==s) Failure;
    if(t->OnMerit) Failure;
    t=t->MeritUp;
  }
  b=No;
  t=Tab;
  do{
    if(t==s)b=Yes;
    if((t->MeritUp)->MeritDown!=t){
      printf("\n%d", t-Tab);
      Failure;
    }
    if(t->OnMerit==No) Failure;
    t=t->MeritUp;
  } while(t!=Tab);
  if(!b){
    printf("\n%s %d",w, s-Tab);
    Failure;
  }
}
static void FreqCheck(void){
  Ushort j;
  printf("\n FreqCheck");
  for(j=1;j<Dim(Point);j++){
    Freqq[j]=Point[j].Freq;
    Point[j].Freq=0;
  }
  FreqCount();
  for(j=1;j<Dim(Point);j++){
    if(Freqq[j]!=Point[j].Freq){
      printf(" %d %d ",Freqq[j],Point[j].Freq);
      Fshow(Point[j].e);
      Failure;
    }
  }
}
static void MeritCheck(void){
  Ushort j;
  printf("\n MeritCheck");
  for(j=0;j<=ElemCount;j++){
    Meritq[j]=Tab[j].Merit;
    Tab[j].Merit=0;
  }
  MeritCount();
  for(j=0;j<=ElemCount;j++){
    if(Meritq[j]!=Tab[j].Merit){
      printf(" %d %d ",Meritq[j],Tab[j].Merit);
      Fshow(&Tab[j]);
      Failure;
    }
  }
}
#endif
