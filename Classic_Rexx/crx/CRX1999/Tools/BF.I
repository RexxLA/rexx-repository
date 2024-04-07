/*------------------------------------------------------------------------------

To process Rexx from the standard. The Pcode produced by CRX is compiled to
a Bcode that is smaller (and restricted in function).

There is a lot of obsolete stuff in here but it is harmless, eg calculations
of code point allocations prior to the final one.

SYSOUT gets some (occasionally very approx) figures about the Pcode subject.
BF.I gets the file in Assembler that becomes part of CRX.

In outline, the Pcode is read as made, into memory addressed by Codep, Consp,
Varsp, Symsp.  The code is turned to a less compact, more readily accessed
form Grist.

There follows a lot of scanning around over the Grist for various sorts of
labels and how they are called, which variables used in which section of
code etc.

There is a preliminary output of how the 256 available Bcode points might
be used but it is merely indicative because there is more to be calculated.
SetDelta tracks the number of temporaries that will be on the runtime soft
stack. That + args + local variables (maximums) determines how many points
are needed for addressing off top-of-stack.

Actually it is twice that many used because load & store are distinguished.

There are few left after those and ones for Opcodes and ones for System
variables etc are taken.  Automatic Subroutine Recognition is aimed at
making use of those to call fragments of shared code.

There is a degree of freedom in mapping the locals.  First call on that
is to make arguments and variables into aliases, avoiding assignment between
them.  Later calls are to improve ASR.

õ-----------------------------------------------------------------------------*/
/* Size of a run time DO block in terms of rexx variables. */
#define Dod 5
#define LookHash 6
#define MeritProposal 10
/* Changing MeritCommit from 8 to 9 cost 67 bytes on total output, saved 9
codepoints. */
/* Changing MeritCommit from 9 to 10 cost 39 bytes on total output, saved 5
codepoints. */
/* Changing MeritCommit from 10 to 11 cost 67 bytes on total output, saved
 33 down to 30 codepoints. */
#define MeritCommit 11
static FILE * In;
#include "codeshdr.i"
#define VarLo 5 /* . RESULT RC SIGL */
#define ParseDot 0
#define ConLo 22
/* Need some actual values. */
static Uchar HereThen, HereAssign, HerePattern, HereExists, HereNop, HereBifq;
static Uchar HereARG;
#define Arg1 7500
#define Arg2 7501
#define Arg3 7502
#define Arg4 7503
#define Arg5 7504
static Bool VoidJump,AssignTgt,WithinParse;
static Ushort a,b,j,k,kk,m,n,p,q,r,s,t,v,x,w;  /* Generally useful. */
static Ulong aa;
static Ushort Restarts;
static Ushort PrevLen;

/*------------------------------------------------------------------------------
 Here we get the subject Pcode into memory, in the format that CRX made it.
õ-----------------------------------------------------------------------------*/
typedef struct{
/* We won't need the lookup fields again so they can be used for info
during new processing. */
/* Looks like Borland uses 4 bytes for the bit fields although only
16 flags. So awkward Union */
 union{
   struct{
     Ushort u; /* Zeroed so as to clear the flags. */
     Ushort ScopeNum;
   } g;
   struct{
     unsigned System:1;
     unsigned Scope:1;
     unsigned External:1;
     unsigned Open:1;
     unsigned Callee:1;
     unsigned Called:1;
     unsigned Invoked:1;
     unsigned HexIt:1;
     unsigned ArgsSet:1;
     unsigned Spare:7;
   } f;
 };
 Ushort Here;
 Ushort Label;
} Vshape;
/* It was a bit messy re-using the Label field so I allocated some more
space to avoid that for routines. Also to get signed VarNum */
typedef struct{
  Ushort ArgUse;
  short VarNum;
} Rshape;
/* The ...Len things count in bytes. */
static Ushort CodeLen, SymsLen, VarsLen, ConsLen;
/* The ....Count things count in language units. */
static Ushort VarsCount, ConsCount, StemCount;
static Ushort VarsCtr, ConsCtr;
/* These for where it is read into. */
static char * Symsp;
static Uchar *Codep, *CodepZi, *CodepLo;
static Uchar * VarspRaw, * ConspRaw;
static Vshape * Varsp, * Consp;
static Rshape * Rsp;
static Ushort Av(Ushort v);/* Convert from address to 0,1,2,... of variables.*/
static Ushort Ac(Ushort v);
static Ushort NullCon;
/* These for overall statistics on the subject Pcode. */
static Bool Show;
static int Freq[Dim(Pcodes)];
static int FreqVars, FreqCons, FreqJumps, Freqs, RangeOps, Points, TotLen;
static int FreqHex,FreqFtns, FreqOps, TotBytes;
/* We look into scope of variables at a gross level - in terms of routines. */
#define VarLimit 320
#define VarLimitPacked ((VarLimit+7)/8)
typedef struct{
 Ushort Index;/* To symbol of label. */
 Ushort Lo;
 Ushort Args;
 Uchar ArgCt[7]; /* How often arg used. */
 Bool Sized;
 Ushort LocalVars;
 char Alive[VarLimitPacked];
 char Mapped[VarLimitPacked]; /* Stack slot mapped onto. */
} ScopeShape;
static ScopeShape *Scp, *ScpX;
static char Spare[VarLimitPacked];
static Ushort ScopeCount,MaxArgs,MaxLocals,MaxDelta;
static Ushort Bro[VarLimit],Sis[VarLimit];/* Used in matching. */
static Ulong Al; /* Used just to speed up matching. */
static Ushort FragNum;
static Bool Middle, BifPart; /* Used in logic of Bcode making. */
/* Here is the shape for data on a per byte of Pcode basis. */
/* Order of .Type is used. Opcode and above can start fragments. */
 enum{Number,OpVar,OpCon,Jump,PartOf,Fragment,OpCode,Var,Con,Arg};
 typedef struct{
  Ushort Type;
  Ushort Value;
  Ushort ValueWas; /* For checking */
  Ushort From; /* Earliest place that jumps to here. */
  Ushort OpLen;
  Ushort WithinP;
  Ushort FragFact; /* About fragment call. */
  Ushort Overlap; /* Avoid fragment overlap. */
  Ushort Delta;/* Intermediate stack items count. */
  Ushort ArgScp; /* Which first level scope arg is in */
  short DoDelta;/* Iterative DO temps. */
  Ushort SkipTo;/* Used just to speed up matching. */
  Ulong Ahead;/* Used just to speed up matching. */
} Pshape;
 Pshape * Grist;
static Ushort DeltaNow;
static Ushort Arg0;/* Maintain Arg0 so that Bcode offsets of Args come right.*/
/* Another use of the SkipTo field */
#define ByteOff SkipTo
static Ushort SepCount;
static Ushort ExternalsCount, InternalsCount, GlobalsCount, TgtRange;
static Ushort Persist;
static Bool LoopStart(Ushort Op);
static void ShowH(Ushort w);
static void ShowVarHere(Ushort w);
static void ShowConHere(Ushort w);
static void PrintConHere(Ushort w);
static void PrintVarHere(Ushort w);
static void ScanPcode(void);
static void CopyAcross(void);
static void SetDelta(void);
static void ArgsOf(Ushort j,Ushort v);
static void Separate(void);
static Ushort Bsize(Ushort From,Ushort UpTo);
static Ushort Bcode(Ushort Scop,Ushort From,Ushort UpTo,Ushort Make);
static void ScanP(Ushort From,Ushort UpTo);
static void Scopes(void){
 for(j=0;j<Dim(Pcodes);j++){
   if(strcmp(Pcodes[j].Op,"Assign")==0) HereAssign=j;
   if(strcmp(Pcodes[j].Op,"Then")==0) HereThen=j;
   if(strcmp(Pcodes[j].Op,"Bifq")==0) HereBifq=j;
   if(strcmp(Pcodes[j].Op,"Pattern")==0) HerePattern=j;
/* Here we just need a value not otherwise used. */
   if(strcmp(Pcodes[j].Op,"InterpEnd")==0) HereExists=j;
   if(strcmp(Pcodes[j].Op,"Nop")==0) HereNop=j;
 }
 for(j=0;j<Dim(Bifs);j++){
   if(strcmp(Bifs[j].f,"ARG")==0) HereARG=j;
 }
#if 0
 printf("\nAss H %d %d",HereAssign,HereThen);
#endif
/*------------------------------------------------------------------------------
1. Read in.
õ-----------------------------------------------------------------------------*/
 SetShowFile("BF.T"); /* In the Show Cluster - where to output. */
/* If dependencies get too complicated there is the "out" of committing
something and restarting the whole exercise. */
/* That didn't help. */
Restart:if(Restarts>10) Failure
 if(Restarts){
   fclose(In);
   free(Codep);
   free(Symsp);
   free(VarspRaw);
   free(ConspRaw);
   free(Rsp);
   free(Grist);
   for(k=0;k<ScopeCount;k++){
     ScpX[k].LocalVars=Scp[k].LocalVars;
   }
   free(Scp);
   ExternalsCount=InternalsCount=GlobalsCount=0;
 }
 In=fopen(InArg,"rb");
 if(In==NULL) {
   printf(Msg[4],InArg);
   longjmp(ErrSig,1);
 }
 fread(&CodeLen,2,1,In);
 fread(&SymsLen,2,1,In);
 printf("\nCodeLen %d SymsLen %d",CodeLen,SymsLen);
 if((Codep=malloc(CodeLen))==NULL) printf(Msg[6]),longjmp(ErrSig,1);
 if((Symsp=malloc(SymsLen))==NULL) printf(Msg[6]),longjmp(ErrSig,1);
 printf("\nSymp %p",Symsp);
 CodepLo=Codep;
 CodepZi=Codep+CodeLen;
 fread(Codep,CodeLen,1,In);
 fread(Symsp,SymsLen,1,In);
/* Scan through Symbols to count variables and constants. */
/* 255=char, 254=Label, 253=binary */
 k=sizeof SegHeader;
 VarsCount=0;ConsCount=0;StemCount=0;
 for(k=sizeof SegHeader;k<SymsLen;){
   j=(Uchar)Symsp[k];k=k+j+1;
   m=(Uchar)Symsp[k];
   if(k>=SymsLen || m<253){
     VarsCount++;
     if(Symsp[k-1]=='.') StemCount++;
   }
   else {
     ConsCount++;
     k++;
     if(m==254) k+=2;
     if(j==0) NullCon=ConsCount;
   }
 }
 /* $Omitted special */
 printf("\nVarsCount %d+%d  ConsCount %d+1",VarsCount,StemCount,ConsCount);
 VarsCount+=StemCount;ConsCount++;
/* We don't need header space but might as well make it like it would be if
the segments had been dumped. */
 VarsLen=VarsCount*(sizeof (Vshape))+sizeof SegHeader;
 ConsLen=ConsCount*(sizeof (Vshape))+sizeof SegHeadeC;
 if((VarspRaw=malloc(VarsLen))==NULL) printf(Msg[6]),longjmp(ErrSig,1);
 if((ConspRaw=malloc(ConsLen))==NULL) printf(Msg[6]),longjmp(ErrSig,1);
/* Discount headers on the arrays. */
 Varsp=(Vshape*)(VarspRaw+sizeof SegHeader);
 Consp=(Vshape*)(ConspRaw+sizeof SegHeadeC);
/* Scan through Symbols again to set fields in arrays. */
/* 255=char, 254=Label, 253=binary */
 k=sizeof SegHeader;
 VarsCtr=0;ConsCtr=1;
 for(k=sizeof SegHeader;k<SymsLen;){
   w=k;
   j=(Uchar)Symsp[k];k=k+j+1;
   m=(Uchar)Symsp[k];
   if(k>=SymsLen || m<253){
     Varsp[VarsCtr].Here=w;
     Varsp[VarsCtr].Label=0;
     VarsCtr++;
     if(Symsp[k-1]=='.'){
       Varsp[VarsCtr].Label=0;
       Varsp[VarsCtr].Here=w;VarsCtr++;}
   }
   else {
     Consp[ConsCtr].Here=w;
     Consp[ConsCtr].Label=0;
     k++;
#if 0
     if(m==253) Consp[ConsCtr].Binary=Yes;
#endif
     if(m==254){
       Consp[ConsCtr].Label=*(Ushort *)(Symsp+k);
       k+=2;
     }
     ConsCtr++;
   }
 }
 Consp[0].Here=Consp[NullCon].Here;
#if 0
 for(j=0;j<VarsCount;j++){
   k=Varsp[j].Here;
   n=(Uchar)Symsp[k];
   if(*(Symsp+k+1)=='#'){
     Varsp[j].f.System=Yes;
     ShowA(Symsp+k+1,n);
     NewLine();
   }
 }
#endif
#if 0
 for(j=0;j<VarsCount;j++){
   ShowD(j);
   ShowC(' ');
   ShowD(Varsp[j].Here);
   ShowC(' ');
   ShowVarHere(j);
   NewLine();
 }
#endif
#if 0
 for(j=1;j<ConsCount;j++){
   ShowD(j);
   ShowC(' ');
   ShowD(Consp[j].Here);
   ShowC(' ');
   ShowConHere(j);
   NewLine();
 }
 exit(0);
#endif
 if(VarsCount>VarLimit) printf(Msg[8]),longjmp(ErrSig,1);
 if((Rsp=calloc(Max(ConsCount,VarsCount),sizeof Rsp[0]))==NULL)
   printf(Msg[6]),longjmp(ErrSig,1);
/*------------------------------------------------------------------------------
2. Scan (and optionally dump) the Pcode for its statistics.
õ-----------------------------------------------------------------------------*/

#if 0
Probably obsolete
 ScanP(sizeof SegHeader,CodeLen);

 for(j=0;j<Dim(Freq);j++){
   if(Freq[j]){
     printf("\n%2x %13s %5d",j,Pcodes[j].Op,Freq[j]);
     Freqs+=Freq[j];
     RangeOps++;
     }
 }
 printf("\nUsed %d of %d pcodes.  Aggregate uses %d", RangeOps,Dim(Pcodes),Freqs);
 printf("\nVar  refs %5d",FreqVars);
 printf("\nCon  refs %5d",FreqCons);
 printf("\nJump refs %5d",FreqJumps);
#endif

/*------------------------------------------------------------------------------
  Copy the subject to a suitable form for Bcode processing.
õ-----------------------------------------------------------------------------*/
/* CopyAcross will decide the Ops we need so dump step above is optional. */
 for(j=0;j<Dim(Freq);j++){
   Freq[j]=0;
 }
 RangeOps=0;
/* Clear some flag spaces. */
 for(j=0;j<VarLo;j++){
   Varsp[j].g.u=0; /* In case these flags used. */
 }
/* Mark the system variables. */
 for(j=VarLo;j<VarsCount;j++){
   Rsp[j].VarNum=0;
   Varsp[j].g.u=0;k=Varsp[j].Here;
   if(*(Symsp+k+1)=='#'){
     Varsp[j].f.System=Yes;
     *(Symsp+k+1)='?';
   }
 }
/* Find all the labels. (& strange constants) */
 for(j=0;j<ConLo;j++){
   Consp[j].g.u=0; /* In case these flags used.  Assert not HexIt */
 }
 ScopeCount=0;
 for(j=ConLo;j<ConsCount;j++){
  Uchar x;Ushort y;
   Consp[j].g.u=0;k=Consp[j].Here;
   x=*(Symsp+k);
   if(*(Symsp+k+1)=='_') Consp[j].f.Open=Yes;
   m=Consp[j].Label;
   if(m<BifBase && m>1){
     printf("\nScope Number %3d ",ScopeCount);
     PrintConHere(j);
     Consp[j].f.Scope=Yes;ScopeCount++;}
   for (y=0;y<x;y++){
     if(*(Symsp+k+y+1)<' ') Consp[j].f.HexIt=Yes;
   }
 }
 if(ScopeCount==0) printf(Msg[7]),longjmp(ErrSig,1);
 aa=sizeof Scp[0];
 /* Spare to hold bound. */
 if((Scp=calloc(ScopeCount+1,aa))==NULL) printf(Msg[6]),longjmp(ErrSig,1);
 if(Restarts==0){
  if((ScpX=calloc(ScopeCount+1,aa))==NULL) printf(Msg[6]),longjmp(ErrSig,1);
 }
 else{
  for(k=0;k<ScopeCount;k++){
    Scp[k].LocalVars=ScpX[k].LocalVars;
  }
 }
 for(j=ConLo,s=0;j<ConsCount;j++)
   if(Consp[j].f.Scope){Scp[s].Index=j;Consp[j].g.ScopeNum=s;s++;}

 aa=sizeof Grist[0];
 if((Grist=calloc(CodeLen+1,aa))==NULL)
   printf(Msg[6]),longjmp(ErrSig,1);
 CopyAcross();
 printf("\nOperators in copied/modified Pcode. (InterpEnd for Exists)");
 for(j=0;j<Dim(Freq);j++){
   if(Freq[j]){
     printf("\n%3d %13s %5d",j,Pcodes[j].Op,Freq[j]);
     Freqs+=Freq[j];
     RangeOps++;
     }
 }
 for(j=ConLo;j<ConsCount;j++){
   if(Consp[j].f.Called && Consp[j].f.Invoked){
     printf("\n Inconsistent ");PrintConHere(j);
   }
 }
/* Put labels in order, so we know where each routine ends. */
Disorder:
 r=0;
 for(k=1;k<ScopeCount;k++){
   j=Scp[k].Index;m=Consp[j].Label;
   t=Scp[k-1].Index;n=Consp[t].Label;
   if(n>m){Scp[k-1].Index=j;Scp[k].Index=t;r=1;}
 }
 if(r) goto Disorder;
/* Also need to go from label to scope. */
 printf("\nScopes with Pcode offsets");
 for(k=0;k<ScopeCount;k++){
   j=Scp[k].Index;Consp[j].g.ScopeNum=k;
/* Fill in the bounds. */
   Scp[k].Lo=Consp[j].Label;
   printf("\n%2d %4x ",k,Scp[k].Lo);
   PrintConHere(j);
 }
 Scp[ScopeCount].Lo=CodeLen;
/* Note which variables used by which routines. */
 for(k=0;k<ScopeCount;k++){
   for(p=Scp[k].Lo;p<Scp[k+1].Lo;p++){
     if(Grist[p].Type==Var || Grist[p].Type==OpVar){
       j=Grist[p].Value;
       if(Varsp[j].f.System==No){
         SetFlag(Scp[k].Alive,j);
       }
     }
     /* Also which args */
     if(Grist[p].Type==Arg){
       Ushort t;t=Grist[p].Value;
       /* Compute actual arg number */
       t=t-Arg1;
       Scp[k].Args=Max(Scp[k].Args,t+1);
       if((t=++Scp[k].ArgCt[t])==3) Scp[k].ArgCt[t]=2;/* 0,1,more uses */
       Grist[p].ArgScp=k;
     }
     /* Also check calls. */
     if(Grist[p].Type==OpCode){
       v=Grist[p].Value;
       j=Scp[k].Index;
       if(strcmp(Pcodes[v].Op,"Return")==0){
         if(Consp[j].f.Invoked){
           printf("\n Invoked? ");PrintConHere(j);
         }
       }
       if(strcmp(Pcodes[v].Op,"Returns")==0){
         if(Consp[j].f.Called){
           printf("\n Called? ");PrintConHere(j);
         }
       }
     }
   }
 }
/* Look to see where "Open" routines are called from. */
/* Their caller must look after variables for them. */
Propagate:
 for(r=0,k=0;k<ScopeCount;k++){
   for(p=Scp[k].Lo;p<Scp[k+1].Lo;p++){
     a=Grist[p].Type;b=Grist[p].Value;
     if(a==OpCon && Consp[b].f.Open && !Consp[b].f.External){
       j=Consp[b].g.ScopeNum;
       if(j>=ScopeCount){
         PrintConHere(b);printf("\n%d %d",j,b);
         Failure;
       }
/* Add Alives of j to Alives of k and note if it makes a difference. */
       Assign(Spare,Scp[k].Alive);
       MemOr(Scp[k].Alive,Scp[j].Alive,sizeof Spare);
       if(Compare(Scp[k].Alive,Spare)) r=1;
     }
   }
 }
 if(r) goto Propagate;
 for(k=0;k<ScopeCount;k++){
   j=Scp[k].Index;
/* Open routines don't have variables of their own. */
   if(Consp[j].f.Open) Clear(Scp[k].Alive);
 }
/* How clean is the scope position? */
 for(j=VarLo;j<VarsCount;j++){
   r=0;
   for(k=0;k<ScopeCount;k++){
     if(QryFlag(Scp[k].Alive,j)){
       r++;if(r==2){
         printf("\nPossible global - %d - ",j);PrintVarHere(j);
         printf(" also in ");PrintConHere(Scp[k].Index);
       }
     }
   }
 }
/* Show the Alives array. */
 for(k=0;k<ScopeCount;k++){
   printf("\n");PrintConHere(Scp[k].Index);
   printf("[%d]:",Scp[k].Args);
   for(j=VarLo;j<VarsCount;j++){
     if(QryFlag(Scp[k].Alive,j)){
       printf(" ");PrintVarHere(j);
       if(Restarts==0)
         Scp[k].LocalVars++;
       Varsp[j].g.ScopeNum=k;
     }
   }
   printf(" [%d]",Scp[k].LocalVars);
 } /* Scopes */

/*------------------------------------------------------------------------------
  There is a circularity difficulty here.  To make the best use of fragments
  we want to allow variable sharing which can lead to some unused space in
  the local variables array. So in principle we don't know how many code points
  to reserve for addressing locals.  In practice it seems the gaps are not
  fatal.
õ-----------------------------------------------------------------------------*/
 for(j=ConLo;j<ConsCount;j++){
   if(Consp[j].f.External){
     printf("\n");PrintConHere(j);ExternalsCount++;
   }
   else if(Consp[j].f.Callee) InternalsCount++;
 }
 printf("\nGlobals:");
 for(j=VarLo;j<VarsCount;j++){
   if(Varsp[j].f.System){
     printf(" ");PrintVarHere(j);
     GlobalsCount++;
   }
 }
 for(k=0;k<ScopeCount;k++){
   MaxLocals=Max(MaxLocals,Scp[k].LocalVars);
   MaxArgs=Max(MaxArgs,Scp[k].Args);
 }
/* RangeOps as made not helpful because some get substituted as Bcode made. */
/* And anyway may not be contigous. */
 RangeOps=HerePattern+30;
 printf("\nOpcodes:%d",RangeOps);
 printf("\nExternal callees:%d",ExternalsCount);
 printf("\nInternal callees:%d",InternalsCount);
 Points=256-RangeOps-ExternalsCount-InternalsCount;
 printf("\n(Leaving %d)",Points);
 printf("\nGlobal variable type:%d",GlobalsCount);
 Points-=2*GlobalsCount;
 printf("\n(Leaving %d)",Points);
 printf("\nLocalVars:%d",MaxLocals);
 printf("\nArgs:%d",MaxArgs);
 MaxLocals+=MaxArgs;
 Points-=3*MaxLocals;
 printf("\nLeaving:%d", Points);
/* Setting the "Delta" which counts args & intermediates on the stack had
to wait until we had gathered arg info for each routine. */
 SetDelta();
 printf("\nMaxDelta=%d",MaxDelta);
#if 0
 for(p=sizeof SegHeader;p<CodeLen;p++){
   printf("\n%x %d",p,Grist[p].Delta);
 }
#endif
#if 0
/* Did that checkout? */
 for(k=0;k<ScopeCount;k++){
   j=Scp[k].Index;
   printf("\n");
   PrintConHere(j);
   if(Consp[j].f.ArgsSet){
     printf(" %d =? %d",Rsp[j].ArgUse,Scp[k].Args);
   }
 }
#endif
/* Look for opportunities to use arguments as variables. */
 for(k=0;k<ScopeCount;k++){
   printf("\nArg use mode this scope %d %x ",k,Scp[k].Lo);
   PrintConHere(Scp[k].Index);
   for(p=0;p<5;p++) printf(" %d",Scp[k].ArgCt[p]);
#if 0
   if(k==14){
     for(p=Scp[k].Lo;p<Scp[k].Lo+8;p++){
       printf("\n%d",Grist[p].Type);
     }
   }
#endif
/* Since the Arg started as a Bif in Pcode there are a lot of PartOfs about.*/
   for(p=Scp[k].Lo;p<Scp[k+1].Lo;p++){
     if(Grist[p].Type==PartOf) continue;
     if(Grist[p].Type!=Arg) break;
     r=Grist[p].Value-Arg1;
     if(Scp[k].ArgCt[r]!=1) break;
/* It's one use will have been to assign it to a variable. */
     if(Grist[p+1].Type!=PartOf) Failure;
     if(Grist[p+2].Type!=OpCode) break;
     if(Grist[p+2].Value!=HereAssign) break;
     if(Grist[p+3].Type!=OpVar){printf("\n %x",p);Failure;}
     j=Grist[p+3].Value;
     if(Varsp[j].f.System) break;
     /* We don't want to commit LocalVars yet so mark as aliased to an arg */
     printf("\nAliased arg %d, from scope %d ",r+1,Scp[k].LocalVars);
     PrintVarHere(j);
     Rsp[j].VarNum=-r-1;
/* Maybe safer not to save variable space? */
#if 0
     Scp[k].LocalVars--;
#endif
     Grist[p].Type=Grist[p+2].Type=Grist[p+3].Type=PartOf;
   }
 }
/*------------------------------------------------------------------------------
  Here we begin to look for "fragments" of code that can be run as subroutines.
  The algorithm is "greedy on length", that is to say the longest subroutine
  is decided for to begin with, then the resulting setup is looked on as a new
  problem.

  Two fragments can be implemented as one subroutine if:
   a. The opcodes are the same, in the same order.
   b. Constants used are the same, in the same places.
   c. Jumps (relative) are equal and have targets within the fragments.
   d. Argument references are the same.
   e. Global variable reference are the same.
   f. Numeric fields are the same.
   g. Local variable references are "mergeable".

Different variables in the same scope are not mergeable.  Variables in different
scopes are mergeable if they are allocated the same position within the
respective scopes.
õ-----------------------------------------------------------------------------*/
/* Change the jumps to be relative. */
/* These are not the final jump values to go in Bcode, they are jumps in
the Grist position. */
 for(p=Scp[0].Lo;p<Scp[ScopeCount].Lo;p++){
   if(Grist[p].Type==Jump) Grist[p].Value-=p;
 }
/* we are not going to compare very short fragments so we can build type
info look-ahead into a hash number. */
 for(k=0;k<ScopeCount;k++){
   for(p=Scp[k].Lo;p<Scp[k+1].Lo;p++){
     Ushort m;
     for(m=0,n=0,Al=1;m<LookHash;n++){
       if(p+n==Scp[k+1].Lo) break;
       if(Grist[p+n].Type==PartOf) continue;
       Al=Al*(n+Grist[p+n].Type);/* Some sort of hash. */
       m++;
     }
     Grist[p].Ahead=Al;
   }
 }
 for(p=Scp[ScopeCount].Lo-1;p>=Scp[0].Lo;p--){
   Al=Grist[p].Ahead;r=p;
   for(q=p-1;q>=Scp[0].Lo;q--){
     if(Grist[q].Ahead==Al){
       Grist[q].SkipTo=r;r=q;
     }
   }
 }
/* Hard to see that it matters which order the scopes are considered in. */
{ Ushort a,b,e,f,g,i,j,s,t,p,pp,q,qq,u,v,x,y,r,z;short c,d;
/* We depend on finding long ones (and committing them) before short ones.
 Committing the longest found doesn't quite do this, it seems.  Maybe the
 match rules are such that effects of committing a short make a longer
 possible.  Anyway, we use PrevLen to avoid trouble. */
 PrevLen=CodeLen;
Matching:
 w=0;/* Merit of best proposal so far. */
 for(k=0;k<ScopeCount;k++){
   Ushort Dbug;
   Dbug=0;
   for(p=Scp[k].Lo;p<Scp[k+1].Lo;p++){
     s=Grist[p].Type;
/* "Load Stack" can be separated from an Opcode, but Opcode with its argument
 should be atomic. */
     if(s<OpCode) continue;
/* Some operands are not good places to start looking for a fragment. */
     if(Grist[p].WithinP) continue;
#if 0
     if(k==14 && Dbug==0) Dbug=p;
#endif
/* Compare fragment at p with other fragments, at q. */
     pp=Grist[p].Overlap;
     q=p;
NewQ:
#if 0
     if(p==0xB56 && q==0xE71){
       printf("\nTried %x %x rzw %d %d %d",p,q,r,z,w);
     }
#endif
     q=Grist[q].SkipTo;if(!q) continue;
#if 0
     if(p==0xB56 && q==0xE71){
      k=14;/* For stop */
     }
         if(p==0x1bd8 && q==0x1c51){
           printf("\nBegan");
           u=0x1be6;v=0x1c5f;
           printf("\n@%x @%x %d %d %d %d",u,v,Grist[u].Type,Grist[v].Type,
             Grist[u].Value,Grist[v].Value);
         }
#endif
/* Step through fragments with u & v respectively. */
       r=0;e=0;z=0;u=p;v=q;qq=Grist[q].Overlap;
NextR:;/* r progresses while possibility fragments match further. Continue
 with next q otherwise. */
       s=Grist[u].Type;
       t=Grist[v].Type;
       if(s!=t) goto NewQ; /* Next q */
       if(Grist[u].Overlap!=pp) goto NewQ;
       if(Grist[v].Overlap!=qq) goto NewQ;
       if(s==PartOf) goto GoodR;
/* Longest first so: */
       if(s==Fragment) goto NewQ;
/* Crude on Delta */
       if(Grist[u].Delta!=Grist[v].Delta) goto NewQ;
/* Crudely giving up on certain OpCodes because I don't want the effort of
tracking what an Iterate (say) is actually branching to. */
       x=Grist[u].Value;
       if(s==OpCode){
         if(strncmp(Pcodes[x].Op,"Iter",4)==0) goto NewQ;
         if(strncmp(Pcodes[x].Op,"Leave",5)==0) goto NewQ;
         if(strncmp(Pcodes[x].Op,"While",5)==0) goto NewQ;
         if(strncmp(Pcodes[x].Op,"Until",5)==0) goto NewQ;
         if(strncmp(Pcodes[x].Op,"Return",6)==0) goto NewQ;
         z=Max(z,r+Grist[u].OpLen);/* Target for r. */
       }
       y=Grist[v].Value;
/* We can't be sure about jumps yet. */
       if(s==Jump){
         if(x!=y) goto NewQ;
         z=Max(z,r+x);/* Target for r. */
         goto GoodR;
       }
       if(s!=Var && s!=OpVar){
         if(x != y) goto NewQ;
#if 0
         if(u==0x1be6 && v==0x1c5f){
           printf("\n%x %x S%d X%d Y%d",u,v,s,x,y);
         }
#endif
         if(x != y) goto NewQ;
         if(s!=Arg) goto GoodR;
/* Args match when offset matches which needs Arg0 the same. */
         a=Grist[u].ArgScp;
         b=Grist[v].ArgScp;
         if(a==b) goto GoodR;
         i=Scp[a].LocalVars+Scp[a].Args;
         j=Scp[b].LocalVars+Scp[b].Args;
         /* Dodgy because variable pairing might upset? */
         if(i==j) goto GoodR;
         if(i>j && Scp[b].Sized) goto NewQ;
         if(j>i && Scp[a].Sized) goto NewQ;
         goto GoodR;
       }
       else{
/* If they are the same variable, good enough, even if not yet mapped. */
         if(x==y) goto GoodR;
/* Cannot merge globals. */
         if(Varsp[x].f.System) goto NewQ;
         if(Varsp[y].f.System) goto NewQ;
         if(x==ParseDot) goto NewQ;
         if(y==ParseDot) goto NewQ;
/* If in the same scope they can't be merged. */
         a=Varsp[x].g.ScopeNum;
         b=Varsp[y].g.ScopeNum;
         if(a==b) goto NewQ;
/* Different scopes, but are they already mapped? */
         c=Rsp[x].VarNum;
         d=Rsp[y].VarNum;
/* It isn't sound to assume that if both unmapped they can be mapped to
match, because may we have a set of mappings. */
/* It would be complicated to make the mappings on-the-fly here and reverse
them when the proposal proved weak. */
/* Simpler, perhaps sub-optimal, to just prevent interacting series of
pairings. */
         if(c==0 && d==0) goto Relate;
/* If they are arg-aliased, the one with less local vars better not have
its size fixed. */
         if(c<0 && d<0){
           if(c!=d) goto NewQ;
           i=Scp[a].LocalVars;
           j=Scp[b].LocalVars;
           if(i>j && Scp[b].Sized) goto NewQ;
           if(j>i && Scp[a].Sized) goto NewQ;
           goto Relate;
         }
         if(c<0 && d>0) goto NewQ;
         if(d<0 && c>0) goto NewQ;
         if(c<0 && d==0){
           Ushort k;
           k=Scp[a].LocalVars+Scp[a].Args+1+c; /* c is neg */
           if(QryFlag(Scp[b].Mapped,k)) goto NewQ;
           if(k>Scp[b].LocalVars) goto NewQ;/* Could do more. */
           goto Relate;
         }
         if(d<0 && c==0){
           Ushort k;
           k=Scp[b].LocalVars+Scp[b].Args+1+d;/* d is neg */
           if(QryFlag(Scp[a].Mapped,k)) goto NewQ;
           if(k>Scp[a].LocalVars) goto NewQ;
           goto Relate;
         }
/* If both mapped, it will have to have been to the same position. */
         if(c!=0 && d!=0){
           if(c==d) goto GoodR;
           goto NewQ;
         }
/* Whichever is mapped, the other better not be committed in the same
 position. */
         if(c!=0){
           /* If mapped as an argument we will gamble other can be mapped
           to same offset. */
           if(c<0) goto Relate;
           if(QryFlag(Scp[b].Mapped,c)) goto NewQ;
/* Restart mechanism didn't solve things so better not keep as option
extending locals. */
           if(c>Scp[b].LocalVars) goto NewQ;
           goto Relate;
         }
         else{
           if(d<0) goto Relate;
           if(QryFlag(Scp[a].Mapped,d)) goto NewQ;
           if(d>Scp[a].LocalVars) goto NewQ;
           goto Relate;
         }
         Failure;
       }
Relate:
/* Avoid complex relations, which might not subsequently map. */
/* If x involved already with y, nothing to do. */
  for(f=0;f<e;f++){
    if(Bro[f]==x){
      if(Sis[f]==y) goto GoodR;
      goto NewQ;
    }
  }
  for(f=0;f<e;f++){
    if(Sis[f]==x){
      if(Bro[f]==y) goto GoodR;
      goto NewQ;
    }
  }
/* y involved (with non-x) prevents (x,y) pair. */
  for(f=0;f<e;f++){
    if(Bro[f]==y) goto NewQ;
    if(Sis[f]==y) goto NewQ;
  }
/* Both x and y new. */
  Bro[e]=x;Sis[e]=y;e++;
/* Depending on the jump situation, this may be a solution or merely on the
way to one. */
GoodR:
/* If the place we are about to absorb in proposed fragment is a place branched
to then the start of that branch also needs to be in the fragment. */
  if(r<Grist[u].From) goto NewQ;
  if(r<Grist[v].From) goto NewQ;
  r++;u++;v++;
/* Is this solution better than those found before? */
/* Maybe r isn't the best figure of merit but it will do for proposals. */
  if(r<z || r<=w){
    if(u<Scp[k+1].Lo) goto NextR;
    goto NewQ;
  }
/* Record this best. */
 w=r;m=p;n=q;g=k;
 if(u<Scp[k+1].Lo) goto NextR;
   } /* p */
 } /* k */
/* We are going to find more potential fragments than we will actually take
because some will turn out later not to be ultimately worthwhile. Or maybe
we run out of Points. */
/* We need a rule for stopping the sequence of recognitions. */
 if(w>MeritProposal){
/* Best proposal is starts m,n for w. */
   printf("\nProposal @%x @%x %d Scp %d",m,n,w,g);
#if 0
   if(m==0x606){
     printf("\nScanP");fflush(stdout);
     ScanP(m,m+w);
     ScanP(n,n+w);
   }
#endif
  if(w>PrevLen){
     printf("\nScanP");fflush(stdout);
/* ScanP is off original, not Grist */
     ScanP(m,m+w);
     ScanP(n,n+w);
     NewLine();
     longjmp(ErrSig,1);
  }
/* Turn this proposal to fact before trying again. */
/* Step through fragments with u & v respectively. */
   u=m;v=n;
   for(r=0;r<w;r++){
CommitR:
     s=Grist[u].Type;
     if(s!=Var && s!=OpVar){
#if 0
       if(u==0x1659){
         printf("\n@%x T%d %d %x",n,Grist[n].Type,Grist[n+1].FragFact,
         Grist[n].FragFact);
       }
#endif
       if(s!=Arg) goto MatchedR;
/* Args match when offset matches which needs Arg0 the same. */
         a=Grist[u].ArgScp;
         b=Grist[v].ArgScp;
         if(a==b) goto MatchedR;
         i=Scp[a].LocalVars+Scp[a].Args;
         j=Scp[b].LocalVars+Scp[b].Args;
         /* Have to set .Sized in case something later takes advantage. */
         if(i!=j){
           if(i>j && Scp[b].Sized) Failure;
           if(j>i && Scp[a].Sized) Failure;
           if(i>j){
             Scp[b].LocalVars+=i-j;
             printf("\nSized ");
             PrintConHere(Scp[b].Index);
             printf(" now %d",Scp[b].LocalVars);
           }
           if(j>i){
             Scp[a].LocalVars+=j-i;
             printf("\nSized ");
             PrintConHere(Scp[a].Index);
             printf(" now %d",Scp[a].LocalVars);
           }
         }
         Scp[a].Sized=Yes;
         Scp[b].Sized=Yes;
         goto MatchedR;
     }
     x=Grist[u].Value;
     y=Grist[v].Value;
/* If they are the same variable, good enough, even if not yet mapped. */
     if(x==y) goto MatchedR;
/* If in the same scope they can't be merged. */
     a=Varsp[x].g.ScopeNum;
     b=Varsp[y].g.ScopeNum;
/* Different scopes, but are they already mapped? */
     c=Rsp[x].VarNum;
     d=Rsp[y].VarNum;
#if 0
     if(m==0x606){printf("\nc=%d d=%d",c,d);}
#endif
/* If they are both negative it means they were aliased on to arguments. */
     if(c<0 && d<0){
       /* Unlikely they will be different args although we might be able
        to cope. */
       if(c!=d) Failure;
       i=Scp[a].LocalVars;
       j=Scp[b].LocalVars;
       if(i==j){
         printf("\nSameSize ");
         PrintConHere(Scp[a].Index);
         printf(" ");
         PrintConHere(Scp[b].Index);
       }
       else if(i>j){
         k=i-j;
         printf("\nExtend by %d, ",k);PrintConHere(Scp[b].Index);
         if(Scp[b].Sized) Failure;
         Scp[b].LocalVars+=k;
       }
       else {
         k=j-i;
         printf("\nExtend by %d, ",k);PrintConHere(Scp[a].Index);
         if(Scp[a].Sized) Failure;
         Scp[a].LocalVars+=k;
       }
       printf(" ");PrintVarHere(x);
       printf(" ");PrintVarHere(y);
       Scp[a].Sized=Yes;
       Scp[b].Sized=Yes;
       goto MatchedR;
     }
     if(c<0 && d==0){
       k=Scp[a].LocalVars+Scp[a].Args+1+c;
       if(QryFlag(Scp[b].Mapped,k)) Failure;
       if(k>Scp[b].LocalVars) Failure;
#if 0
       if(m==0x606){printf("\nc=%d d=%d",c,d);}
#endif
       Rsp[y].VarNum=k;
       SetFlag(Scp[b].Mapped,k);
       Scp[a].Sized=Yes;
       goto MatchedR;
     }
     if(d<0 && c==0){
       k=Scp[b].LocalVars+Scp[b].Args+1+d;
       if(QryFlag(Scp[a].Mapped,k)) Failure;
       if(k>Scp[a].LocalVars) Failure;
       Rsp[x].VarNum=k;
#if 0
       if(m==0x606){printf("\nx=%d k=%d",x,k);}
#endif
       SetFlag(Scp[a].Mapped,k);
       Scp[b].Sized=Yes;
       goto MatchedR;
     }
/* It isn't sound to assume that if both unmapped they can be mapped to
match but lets's see. */
     if(c==0 && d==0){
/* Find an unused position in both scopes. */
       for(j=1;j<VarLimit;j++){
         if(!QryFlag(Scp[a].Mapped,j)
         && !QryFlag(Scp[b].Mapped,j)){
           Rsp[x].VarNum=j;
           Rsp[y].VarNum=j;
           SetFlag(Scp[a].Mapped,j);
           SetFlag(Scp[b].Mapped,j);
           printf("\nMerged ");
           PrintConHere(Scp[a].Index);
           printf(":");
           PrintVarHere(x);
           printf(" ");
           PrintConHere(Scp[b].Index);
           printf(":");
           PrintVarHere(y);
           printf(" @ %d",j);
           if(j>Scp[b].LocalVars){
             Scp[b].LocalVars=j;
             printf(" Up");
             Restarts++;
            goto Restart;
           }
           if(j>Scp[a].LocalVars){
             Scp[a].LocalVars=j;
             printf(" Up");
             Restarts++;
            goto Restart;
           }
           goto MatchedR;
         }
       }/* j */
       Failure;
     }
     if(c>0 && d>0){
       if(c==d) goto MatchedR;
           printf("\n!!!!?");
           PrintConHere(Scp[a].Index);
           printf(":");
           PrintVarHere(x);
           printf(" @ %d",c);
           printf(" ");
           PrintConHere(Scp[b].Index);
           printf(":");
           PrintVarHere(y);
           printf(" @ %d",d);
       Failure;
     }
     if(c>0){
       SetFlag(Scp[b].Mapped,c);
       Rsp[y].VarNum=c;
       printf("\nMapped ");
       PrintConHere(Scp[a].Index);
       printf(":");
       PrintVarHere(x);
       printf(" ");
       PrintConHere(Scp[b].Index);
       printf(":");
       PrintVarHere(y);
       printf(" @ %d",c);
       if(c>Scp[b].LocalVars){
         Scp[b].LocalVars=c;
         printf(" Up");
         Restarts++;
         goto Restart;
       }
       goto MatchedR;
     }
     if(d>0){
       SetFlag(Scp[a].Mapped,d);
       Rsp[x].VarNum=d;
       printf("\nMapped ");
       PrintConHere(Scp[b].Index);
       printf(":");
       PrintVarHere(y);
       printf(" ");
       PrintConHere(Scp[a].Index);
       printf(":");
       PrintVarHere(x);
       printf(" @ %d",d);
       if(d>Scp[a].LocalVars){
         Scp[a].LocalVars=d;
         printf(" Up");
         Restarts++;
         goto Restart;
       }
       goto MatchedR;
     }
     printf("\n%d %d ",c,d);
     PrintVarHere(x);
     PrintVarHere(y);
     Failure;
MatchedR:
     Grist[v].Type=PartOf; /* Keep one copy, lose one. */
#if 0
   if(v==0x1659){
     printf("\n@%x overlay by PartOf",v);
   }
#endif
     Grist[u].Overlap=m;
     u++;v++;
   } /* r */
/* Change the duplicate at n to a call. */
   Grist[n].Type=Fragment;
   Grist[n].FragFact=m; /* What it is same as. */
   Grist[n+1].FragFact=w; /* Thats length */
   Grist[n+2].FragFact=g; /* Which scope. */
   PrevLen=w;
#if 0
   if(n==0x1659){
     printf("\n@%x T%d %d %x",n,Grist[n].Type,Grist[n+1].FragFact,
        Grist[n].FragFact);
   }
#endif
   goto Matching;
 } /* A commit */
} /* Routining */
/*------------------------------------------------------------------------------
  Here is where the Bcode is made, in assembler format.
  First the fragments, because we don't know yet how many of them.
õ-----------------------------------------------------------------------------*/
 FreqVars=FreqCons=FreqJumps=FreqHex=FreqFtns=0;
/* The bcode fragments can go anywhere in code since they are labelled. */
/* We will use the ALL2INC utility to divide the output file up so each
potential INCLUDE needs to be marked. */
#if 0
  NewLine();
  ShowS(";õ bf\\configs.inc");
/* External Routines */
 for(j=ConLo;j<ConsCount;j++){
   if(Consp[j].f.Callee && Consp[j].f.External){
     NewLine();ShowS(" dw ");ShowConHere(j);ShowS("$$ú");
     ShowConHere(j);ShowS(" equ ");ShowD(Points++);
   }
 }
#endif
  ShowS(";õ bf\\Frag.inc");
/* We will go for showing shortest fragment first. (equ's OK order) */
#if 0
  p=0x1659;
  printf("\n@%x Type %d (p+1) %d (p) %x",p,Grist[p].Type,Grist[p+1].FragFact,
      Grist[p].FragFact);
#endif
NextFrag:
 w=CodeLen;
 for(p=Scp[0].Lo;p<Scp[ScopeCount].Lo;p++){
   if(Grist[p].Type==Fragment){
     if(Grist[p+1].FragFact<w){
       w=Grist[p+1].FragFact;n=Grist[p].FragFact;
       k=Grist[p+2].FragFact;/* Scope */
     }
   }
 }
 /* CodeLen marker means a fragment we have already put out. */
 if(w!=CodeLen){
 /* Does it still merit being a fragment? */
  if(Bsize(n,n+w)>MeritCommit){
   FragNum++;
   Arg0=Scp[k].LocalVars+Scp[k].Args+1;
   printf("\nFrag %d @%x Scp %d Arg0 %d",FragNum,n,k,Arg0);
   t=Bcode(USHRT_MAX,n,n+w,0);/* Map for jumps. */
   NewLine();NewLine();
   ShowS("Frag");ShowD(FragNum);ShowS("$$ ");
   Middle=No;
   Bcode(USHRT_MAX,n,n+w,1);
/* Fragments need a RETURN at the end. */
   Separate();
   ShowS("_RetF");
   printf("\nFragment %d bytes %d.",FragNum,t+1);
   TotBytes+=t+1;
/* Now that it has been translated, we can make all uses of it look the same
in the Pcode version. */
/* Clear subject that has gone to routine. */
   for(p=n;p<n+w;p++){
     Grist[p].Type=PartOf;
   }
/* And mark it as a call to already made routine. */
   Grist[n].Type=Fragment;
   Grist[n].FragFact=n;
   Grist[n+1].FragFact=w;
/* And mark it and other places that call same fragment. */
   for(p=Scp[0].Lo;p<Scp[ScopeCount].Lo;p++){
     if(Grist[p].Type==Fragment
        && Grist[p].FragFact==n && Grist[p+1].FragFact==w){
       Grist[p].Value=FragNum;Grist[p+1].FragFact=CodeLen;
       printf("\nFragment %d invoked @%x.",FragNum,p);
     }
   } /* Making same. */
  } /* Emit */
  else {
  /* Expand the fragment call away. */
   for(p=Scp[0].Lo;p<Scp[ScopeCount].Lo;p++){
     if(Grist[p].Type==Fragment
        && Grist[p].FragFact==n && Grist[p+1].FragFact==w){
       printf("\nSubject @%x expanded back @%x.",n,p);
       for(r=0;r<w;r++){
         Ushort s;
/* It should be enough to copy just the Type, so undoing any aliasing of
names. */
/* No, doesn't work because FragFacts etc needed. Hence ValueWas. */
         s=Grist[p+r].ValueWas;
         Grist[p+r]=Grist[n+r];
         if(Grist[p+r].Type==Var || Grist[p+r].Type==OpVar) Grist[p+r].Value=s;
       } /* Copy subject. */
     } /* A use */
   } /* p */
  } /* Expand */
  goto NextFrag;
 } /* End of have fragment to output or expand. */

/* That just leaves the original coding, as it is now. */
 for(k=0;k<ScopeCount;k++){
   Ushort j,x;
   Arg0=Scp[k].LocalVars+Scp[k].Args+1;
   t=Bcode(k,Scp[k].Lo,Scp[k+1].Lo,0);
   printf("\nScope ");
   PrintConHere(Scp[k].Index);
   printf(" bytes %d.",t);
   TotBytes+=t;
   NewLine();
/* For the first and the builtins we want a separate include made. */
   j=Consp[Scp[k].Index].Here;
   if(k==0 || strncmp(Symsp+j+1,"BIF",3)==0){
     ShowS(";õ bf\\");
     x=*(Symsp+j);
     if(k){x-=3;j+=3;}
     x=Min(x,8);
     ShowA(Symsp+j+1,x);
     ShowS(".inc");
   }
   NewLine();
/* Ones that are called internally need labels. (Also others for hard code) */
   ShowConHere(Scp[k].Index);
   if(Consp[Scp[k].Index].f.Callee){
     ShowS("$$ ");
   }
   else
     ShowC(' ');
   Middle=No;
   Bcode(k,Scp[k].Lo,Scp[k+1].Lo,1);
/* Assume all these routines have their own returns. */
 }
/* That has made the actual Bcode.  Still need vectors that point to those
labels. */
/* The array of Bcode addresses just has to go somewhere in the code segment.*/
 /* Now a vector of Bcode addresses. Begin with internals. */
 NewLine();ShowS("RoutineBase$ equ $");
 for(j=ConLo;j<ConsCount;j++){
   if(Consp[j].f.Callee && !Consp[j].f.External){
     NewLine();ShowS(" dw ");ShowConHere(j);ShowS("$$");
   }
 }
/* Then fragments */
 NewLine();ShowS("FragsBase$ equ $");
 for(j=0;j<FragNum;j++){
   NewLine();ShowS(" dw Frag");ShowD(j+1);ShowS("$$");
 }
/* That has made the Bcode.  Now for equates that give access to the arrays. */
/* This allocation of the code points is the one that actually matters.
/* Do MaxLocals again 'cos of aliasing. */
 MaxLocals=0;
 for(k=0;k<ScopeCount;k++){
   MaxLocals=Max(MaxLocals,Scp[k].LocalVars);
 }
/* High code points address the local variables. */
 printf("\nTgt %d + %d + %d",MaxArgs, MaxLocals, MaxDelta);
 TgtRange = MaxArgs+MaxLocals+MaxDelta;
 Points=256-2*TgtRange;
 Points=Points-FragNum;
 Points=Points-InternalsCount;
 w = Points;
 Points=Points-2*GlobalsCount;
 printf("\nFor m/c routines %d",Points);
 NewLine();
 ShowS(";õ bf\\Bcodes.inc");
 NewLine();
 ShowS("Tgt equ ");ShowD(2*TgtRange);
 ShowS("ú$Locals equ 256-Tgt");
#if 0
 ShowS("ú$FanMinB equ ");ShowD(w);
#endif
 for(j=0;j<MaxArgs;j++){
   NewLine();ShowS("Arg");ShowD(j+1);ShowS(" equ ");ShowD(2*(j+1));
 }

/*------------------------------------------------------------------------------
  Finalize the mapping of variables and produce equates.
õ-----------------------------------------------------------------------------*/
/* Just take available numbers for unmapped locals. */
 for(j=VarLo;j<VarsCount;j++){
 Ushort a,b;
   if(Varsp[j].f.System) continue;
   if(Rsp[j].VarNum==0){
     a=Varsp[j].g.ScopeNum;
     for(b=1;b<VarLimit;b++){
       if(QryFlag(Scp[a].Mapped,b)==No){
         SetFlag(Scp[a].Mapped,b);
         Rsp[j].VarNum=b;
         if(b>Scp[a].LocalVars){
           printf("\nFails %d ",b);PrintVarHere(j);
           Failure;
         }
         goto Nextj;
       }
     }
     Failure;
   }
Nextj:;
 }
/* Arbitary, put equates for locals out in scopes order. */
 for(k=0;k<ScopeCount;k++){
   short r;
   NewLine();
   ShowS("; LocalVars of ");ShowConHere(Scp[k].Index);
   for(j=VarLo;j<VarsCount;j++){
     if(Varsp[j].f.System) continue;
     if(Varsp[j].g.ScopeNum==k){
       r=Rsp[j].VarNum;
       if(r==0) Failure;
       printf("\n%d %d %d ",k,j,r);PrintVarHere(j);
       if(r<0) r=Scp[k].Args+Scp[k].LocalVars+r+1;
       if(QryColumn()>58)NewLine();else ShowC('ú');
       ShowVarHere(j);ShowS(" equ -");ShowD(2*r);
     }
   }
 }
/* Here a section of numbers for the system variables. */
 Points+=GlobalsCount; /* Target versions of system variables. */
/* Don't do equates yet because we want them in a different include. */
 Persist=Points;Points+=GlobalsCount;
#if 0
 NewLine();ShowS("Tgts equ ");ShowD(GlobalsCount);
#endif
/* Things that will index Bcode address table. First the Internals */
 for(k=0,j=ConLo;j<ConsCount;j++){
   if(Consp[j].f.Callee && !Consp[j].f.External){
     NewLine();ShowConHere(j);ShowS(" equ $RoutineBase+");ShowD(k);
     Points++;k=k+2;
   }
 }
  NewLine();
/* Then fragments */
 for(j=0;j<FragNum;j++){
   NewLine();
   ShowS("Frag");ShowD(j+1);ShowS(" equ $BPcodesCeil+");ShowD(2*j);
   Points++;
 }
#if 0
 NewLine();ShowS(";õ bf\\sysvars.inc");
 NewLine();ShowS("$Persistent equ ");ShowD(Persist);
 for(j=VarLo;j<VarsCount;j++){
   if(Varsp[j].f.System){
     NewLine();ShowVarHere(j);ShowS(" equ ");ShowD(Persist);
   }
 }
#endif
 printf("\nBytes %d",TotBytes);
 printf("\nOpBytes:%d",FreqOps);
 printf("\nVarBytes:%d",FreqVars);
 printf("\nConBytes:%d",FreqCons);
 printf("\nFtnBytes:%d",FreqFtns);
 printf("\nJumpBytes:%d",FreqJumps);
 printf("\nHexBytes:%d",FreqHex);

 NewLine();
 exit(0);
}
static Ushort Bcode(Ushort Scop,Ushort From,Ushort UpTo,Ushort Make){
/* This needs to be called with Make==0 to decide ByteOff and then with
Make==1 to make output.  (Otherwise forward branches would be a problem.) */
 Ushort dd,d,p,v,f,Op;
 f=0;
 BifPart=0;
/* If it is a scope with locals there needs to be stack reservation for them.*/
/* Changed to implying _Locals when non-fragment. */
 if(Scop!=USHRT_MAX){
   f+=1;if(Make){
#if 0
     Separate();
     ShowS("_Locals");
     FreqOps++;
#endif
     Separate();
     ShowD(Scp[Scop].LocalVars);
     ShowS("*8+");
     ShowD(Scp[Scop].Args);
     FreqHex++;
   }
 }
 dd=Grist[From].Delta;  /* Should always be zero? Maybe not in fragment. */
 if(dd!=0 && Scop!=USHRT_MAX){
   NewLine();
   Failure;
 }
 Op=0;DeltaNow=0;
 for(p=From;p<UpTo;p++){
   DeltaNow+=Grist[p].DoDelta;
#if 0
   printf("\n %x",p);
   fflush(stdout);
   {Uchar *t;t=malloc(3);free(t);}
#endif
   if(Make && f!=Grist[p].ByteOff) Failure;
   Grist[p].ByteOff=f;
   if(Grist[p].Type==PartOf) continue;
/* No separator if dw coming. */
   if(Make && !AssignTgt && !(LoopStart(Op) && Grist[p].Type==Jump))
     Separate();
   v=Grist[p].Value;
   d=Grist[p].Delta;
   if(d>100){
     printf("\n%x %d",p,d);
     Failure;
   }
/* Usually a byte value to go on the output. */
   switch(Grist[p].Type){
   case Jump:
     if(Make){
/* Long jumps only when making DO loops */
       if(!LoopStart(Op)){
         Ushort Bug;
         ShowC('+');
         Bug=Grist[p+v].ByteOff-f;
         if(Bug>255){
           printf("\nBug=%d p=%x v=%x x=%x f=%x",Bug,p,v,Grist[p+v].ByteOff,f);
           Failure;
         }
         ShowD(Grist[p+v].ByteOff-f);
       }
       else{
         NewLine();
         ShowS(" dw $+");
         ShowD(Grist[p+v].ByteOff-f);
         NewLine();
         Middle=No;
       }
       FreqJumps++;
     }
     f++;
     if(LoopStart(Op)) f++;
     break;
   case Number:
     if(Make){
       if(BifPart==0) {
         ShowC('0');ShowH(v);ShowC('h');
       }
       else{ /* Convert what follows $pBifq to symbolic. */
         Ushort BifNum, XtraArgs;
         BifNum = v & 126;
         XtraArgs = v - BifNum;
         BifNum = BifNum/2;
         ShowS("2*$Bif");
         ShowS(Bifs[BifNum].f);
         if(XtraArgs){
           ShowC('+');
           ShowD(XtraArgs);
         }
         BifPart=0;
       }
       FreqHex++;
     }
     f++;
     break;
   case Arg:
   case Var:
   case OpVar:
/* Special case the dot of Parse. */
     if(v==ParseDot){
       if(Make){ShowS("ParseDot");FreqVars++;}
       f++;
       break;
       }
     if(Make){
/* Since the top item of the soft stack has offet zero from StackDi, when we
make new space it has a range of zero to minus something offset from the new
StackDi. If we put that range in the Pcode it can't be tested with one compare
so we subtract one. Now an unsigned compare with the low bound does the test.
Hence locals are addressed -1,-2,-3,....  The price is a dynamic adjustment
in computing the address off StackDi.  When there are known to be temporaries on
the stack the testing problem doesn't arise so, in particular for assignment,
that adjustment by one can be made in the value in Pcode rather than
dynamically. The overall effect is that "gets" use the same value in Pcode as
"puts" (apart from the Tgt adjustment that denotes a "put") even though there is
one more on the stack when "puts" are done. */
       ShowVarHere(v);
       if(AssignTgt){
/* The Assign operator lowered Delta so we don't have to do it again here. */
         if(!Varsp[v].f.System)
           ShowS("-Tgt");
         else
           ShowS("+Tgts");
       }
#if 0
       if(p==2559) printf("\np2559 %d %d %d",d,Scop,Varsp[v].f.System);
#endif
       if(d){
         if(v >= Arg1 || !Varsp[v].f.System){
           ShowC('-');ShowD(2*d); /* Adjust to even at the last minute. */
#if 0
           if(Scop==10 && v>=Arg1){
           NewLine();
           printf("\np= %d",p);
           exit(0);}
#endif
         }
       }
       FreqVars++;
     }
     AssignTgt=No;
     f++;
     break;
   case Con:
   case OpCon:
     if(Consp[v].f.Scope || Consp[v].f.External){
       /* This is an invocation, whether or not target was part of the input. */
       if(Make){ShowConHere(v);FreqFtns++;}
       f++;
       break;
     }
/* Special case some numbers. */
     { Ushort k,x;
       k=Consp[v].Here;
       x=*(Symsp+k);
       if(x==0){
         if(Make){ShowS("Null");/* Null string */ FreqCons++;}
         f++;break;
       }
       if(x==1){
         if(*(Symsp+k+1)=='0'){
           if(Make){ShowS("Zero");FreqCons++;}
           f++;break;
         }
         if(*(Symsp+k+1)=='1'){
           if(Make){ShowS("One");FreqCons++;}
           f++;break;
         }
       }
     } /* Specials left with break. */
     {
     /* Output for constant.  Constant will be immediate in the Bcode. */
     /* Starts with String or String1 or String2. Iff String then length
     byte next. */
     Uchar x,*t,*w;Ushort y,k;
/* Struggle here.  If string contains CrLf-like it will have to go in hex. */
     k=Consp[v].Here;
     x=*(Symsp+k);
     if(Consp[v].f.HexIt){
       if(Make){
         ShowS("String");
         FreqCons++;
         Separate();
         ShowD(x);
         FreqCons++;
         Separate();
         for(y=0;y<x;y++){
           ShowC('0');
           ShowH(*(Symsp+k+y+1));
           ShowC('h');
           FreqCons++;
           if(y+1<x) Separate();
         }
       }
       f+=x+2;
     }
     else{
       if(Make){
/* If parts use Show separately they may wind up on different lines.*/
         t=malloc(x+3);
         w=t;*t++='"';
         for(y=0;y<x;y++){
           *t++=*(Symsp+k+y+1);
         }
         *t++='"';
         *t++=0;
         /* Save a byte if strings short, length included in code point. */
         if(x==1) ShowS("String1");
         else if(x==2) ShowS("String2");
         else {
           ShowS("String");
           Separate();
           ShowD(x);
         }
         Separate();
         ShowS(w);
         free(w);
         FreqCons+=x+1+(x>2);
       }
       f+=x+1+(x>2);
     }
   }
   break;
   case Fragment:
     if(Make){
       ShowS("Frag");
       ShowD(v);
       FreqFtns++;
     }
     f++;
     break;
   case OpCode:
     if(v>Dim(Pcodes)){
       NewLine();
       ShowH(p);
       Failure;
     }
     if(strcmp(Pcodes[v].Op,"Bifq")==0) BifPart=1; /* Qualifies next Number */
     Op=v;
/* Assign doesn't do anything except qualify how the next variable
reference is made. */
     if(strcmp(Pcodes[v].Op,"Assign")==0){AssignTgt=Yes;continue;}
/* Call is redundant since argument that follows says it is a routine. */
     if(strcmp(Pcodes[v].Op,"Call")==0) continue;
/* Return needs to manage the stack. */
/* But we changed to pushed prune amount so no argument. */
     if(strcmp(Pcodes[v].Op,"Return")==0||strcmp(Pcodes[v].Op,"Returns")==0){
       if(Scop==USHRT_MAX) Failure; /* Shouldn't happen in a fragment. */
       if(Make){
         short Prune;
         if(strcmp(Pcodes[v].Op,"Returns")==0)
           ShowS("_RetB");
         else
           ShowS("_RetBc");
         FreqOps++;
/* Prune one less for Returns to allow result thru. */
         Prune=Scp[Scop].LocalVars+Scp[Scop].Args+d;
         if(strcmp(Pcodes[v].Op,"Returns")==0 && (d-DeltaNow)!=1){
           printf("\n%d %d",d,DeltaNow);
           NewLine();
           Failure;}
         if(strcmp(Pcodes[v].Op,"Return")==0 && d!=DeltaNow){
           printf("\n%d %d",d,DeltaNow);
           NewLine();
           Failure;}
         if(strcmp(Pcodes[v].Op,"Returns")==0) Prune--;
#if 0
         Separate();
         ShowD(2*Prune);
         FreqHex++;
#endif
       }
     }
     else {
       if(Make){
         if(v>=(BPcodesCeil>>1)){
          ShowC('_');
/* See HereExists */
          if(v==HereExists)ShowS("Exists");
          else ShowS(Pcodes[v].Op);
         }
         else{ ShowS("$p"); ShowS(Pcodes[v].Op);}
         FreqOps++;
       }
     }
     f++;
     break;
   default:
     NewLine();
     printf("\n%x %x %d",n,p,Grist[p].Type);
     Failure;
   } /* Switch */
 } /* p */
/* Grist made bigger to make this safe. */
 Grist[p].ByteOff=f;/* In case branched to? */
#if 0
   {Uchar *t;t=malloc(3);free(t);}
#endif
 return f;
} /* Bcode */
static Ushort Bsize(Ushort From,Ushort UpTo){
/* Return total byte length. */
/* This version is just a merit indicator for not making a fragment. */
/* Need not be accurate. */
  Ushort b,c,d,v;
  b=0;
  for(c=From;c<UpTo;c++){
    d=Grist[c].Type;
    v=Grist[c].Value;
    if(d!=PartOf) b++;
    if(d==OpCode && v==HereAssign) b--;
    if(d==Con) b+=(Uchar)Symsp[Consp[v].Here];
  }
  return b;
}
static void Separate(void){
/* There is a limit to continuations/complexity that MASM will take. */
  if(!Middle){
    ShowS("db ");Middle=Yes;SepCount=0;return;
  }
  SepCount++;
  if(SepCount>25 && QryColumn()>1){
    NewLine();
    ShowS(" db ");
    SepCount=0;
    return;
  }
  if(QryColumn()>59){
/* List file from Assembler looks bad if continuations used. */
#if 0
    ShowC('\\');
#endif
    NewLine();
    ShowS(" db ");
    SepCount=0;
  }
  else ShowC(',');
}
/*------------------------------------------------------------------------------
  This section is dumping Pcode, if needed.
õ-----------------------------------------------------------------------------*/
static void ScanP(Ushort From,Ushort UpTo){
/* Show the Pcode. */
 NewLine();
 ShowH(From);
 ShowC(':');
 for(Codep=CodepLo+From;Codep<CodepLo+UpTo;){
   ShowC(' ');
   ScanPcode();
 }
 NewLine();
 return;
} /* ScanP */
/*------------------------------------------------------------------------------
  Converters between indices that are addresses and language units.
õ-----------------------------------------------------------------------------*/
static Ushort Av(Ushort v){
 printf("\nAv %d %d %d %d",v, sizeof SegHeader,sizeof Varsp[0],sizeof Varsp[0].f);
  return (v-sizeof SegHeader)/(sizeof Varsp[0]);
} /* Av */
static Ushort Ac(Ushort v){
 printf("\nAc %d %d %d",v, sizeof SegHeadeC,sizeof Consp[0]);
 return (v-sizeof SegHeadeC)/(sizeof Consp[0]);
} /* Ac */
/*------------------------------------------------------------------------------
  Little routines for showing.
õ-----------------------------------------------------------------------------*/
static void ShowVarHere(Ushort w){
 Ushort k,n;
 if(w>=Arg1){
   ShowS("Arg");ShowC('1'+(w-Arg1));ShowC('-');ShowD(2*Arg0);
   return;
 }
 k=Varsp[w].Here;
 if(!k) Failure;
 n=(Uchar)Symsp[k];ShowA(Symsp+k+1,n);
} /* ShowVarHere */
static void ShowConHere(Ushort w){
 Ushort k,n;
 if(w>=ConsCount) return;
 k=Consp[w].Here;
 if(!k) Failure;
 n=(Uchar)Symsp[k];ShowA(Symsp+k+1,n);
} /* ShowConHere */
static void PrintConHere(Ushort w){
 Ushort k,n;
 char s[100];
 if(w>=ConsCount) return;
 k=Consp[w].Here;
 if(!k){printf("\n%d",w);Failure;}
 n=(Uchar)Symsp[k];if(n>99) Failure;
 strncpy(s,Symsp+k+1,n);s[n]=0;printf("%s",s);
} /* PrintConHere */
static void PrintVarHere(Ushort w){
 Ushort k,n;
 char s[100];
 if(w>=Arg1){
   printf("Arg%C",'1'+(w-Arg1));
   return;
 }
 k=Varsp[w].Here;
 if(!k) Failure;
 n=(Uchar)Symsp[k];if(n>99) Failure;
 strncpy(s,Symsp+k+1,n);s[n]=0;printf("%s",s);
} /* PrintVarHere */
static void ShowH(Ushort w){
  char Buf[20];
  int j;
  j=sprintf(Buf,"%x",w);
  ShowS(Buf);
} /* ShowH */
static void ScanPcode(void){
 Uchar k;
 Ushort kk;
 if(QryColumn()>60){
   NewLine();
   ShowH((Ushort)(Codep-CodepLo));
   ShowC(':');
 }
 k=*Codep;
 kk=*(Ushort *)Codep;
 if(k%2==0){
   /* Operand */
   Codep+=2;
   if(kk%4==0){
     Ushort j;
     j=Av(kk);
     ShowVarHere(j);
     ShowC('{');
     ShowD(Rsp[j].VarNum);
     ShowC('}');
     FreqVars++;
     return;
   }
   if(kk%2==0){
     ShowC('"');
     ShowConHere(Ac(kk));
     ShowC('"');
     FreqCons++;
     return;
   }
   return;
 }
 /* Operator */
 kk=k/2;
 kk=Min(kk,Dim(Pcodes)-1);
 Freq[kk]++;
 ShowS(Pcodes[kk].Op);
 Codep++;
 if(strncmp(Pcodes[kk].Op,"Bool",4)==0)
   {VoidJump=Yes; return;}/* Bool prefix */
 if(Pcodes[kk].Has.Num){
   k=*Codep++;
   ShowC('(');ShowH(k);ShowC(')');
 }
 if(Pcodes[kk].Has.Symbol){
   ShowC(' ');
   ScanPcode();
 }
 if(Pcodes[kk].Has.Jump){
   Ushort kx;
   if(VoidJump==No){
     kx=*(Ushort *)Codep;
     Codep+=2;
     FreqJumps++;
     ShowC('[');ShowH(kx);ShowC(']');
   }
   VoidJump=No;
 }
 if(Pcodes[kk].Has.Extra==XtraNum){
   k=*Codep++;
   ShowC('(');ShowH(k);ShowC(')');
 }
 if(Pcodes[kk].Has.Extra==XtraSymbol){
   ShowC(' ');
   ScanPcode();
 }
 if(Pcodes[kk].Has.Extra==XtraJump){
   Ushort kx;
   kx=*(Ushort *)Codep;
   Codep+=2;
   FreqJumps++;
   ShowC('[');ShowH(kx);ShowC(']');
 }
 ShowC(';');
} /* ScanPcode */

static void CopyAcross(void){
/* Is destructive of the code. */
/* I am going to remove any AssignConst because we are using immediate
constants in Bcode. */
/* Also remove the ARG(const) bif calls because we can access args like
 variables.  But compiler didn't reserve slots in the variables array for
 these new variables.  Here we use new high numbers, and detect them in
 PrintVarHere etc. */
 Uchar k;Ushort Op,p,q,kk,DoEndsAt;
 DoEndsAt=0;
 for(p=sizeof SegHeader,q=p,Codep=CodepLo;p<CodeLen;){
/* If we reach a place where DO ends, some accounting of temps is needed. */
 if(p==DoEndsAt){
   DoEndsAt=Grist[p].DoDelta;Grist[p].DoDelta=-Dod;
 }
Fiddled:
   k=Codep[p];
   if(k%2==0){
/* Oct 99. Now have Subcodes - they pass through as numbers. */
     if(k%8 == 2){
       Grist[p].Type=Number;
       Grist[p].Value=k;
#if 0
       printf("\nMarker %x",p);
#endif
       p++;
       if(k==mParseEnd){
         WithinParse=No;
       }
       continue;
     }
/* Simple loads/stores don't have to be with an operator */
     Grist[p].WithinP = Yes;
     if(!WithinParse){
       Grist[q].OpLen=p-q;q=p;
       Grist[p].WithinP = No;
     }
     kk=*(Ushort *)(Codep+p);
/* Nov 99 - invent Assign operations as needed. */
     if(k%8 == 6){
       kk-=6;
/* Leave targets in Parse looking like they used to. */
       if(!WithinParse){
       /* Outside Parse, prefix opcode. */
         Grist[p].Type=OpCode;
         Grist[p].Value=HereAssign;
         Freq[HereAssign]++;
         Grist[p+1].Type=OpVar;
         Grist[p+1].Value=Av(kk);
         p+=2;
         continue;
       }
     }
/* Normal operand here. */
     Grist[p].Type=(kk&7) ? Con : Var;
     Grist[p].Value=(kk&7)? Ac(kk) : Av(kk);
#if 0
     if(p==17)  printf("\nG17bt %d %d %d",Grist[17].Type, Con, Var);
     if(p==17)  printf("\nG17bv %d %d %d",kk, Ac(kk), Av(kk));
     if(p==17)  printf("\nG17b %d",Grist[17].Value);
     if(p==17)  exit(0);
#endif
     Grist[p+1].Type=PartOf;p+=2;continue;
   }
/* Only operators get to here. */
   Op=k>>1;
   if(strcmp(Pcodes[Op].Op,"Parse")==0){
     WithinParse=Yes;
   }
/* Special case - when we hit AssignConst, change it to Assign and retry. */
   if(strcmp(Pcodes[Op].Op,"AssignConst")==0){
     kk=*(Ushort *)(Codep+p+1);*(Ushort *)(Codep+p)=kk;
     Codep[p+2]=2*HereAssign+1;
     goto Fiddled;
   }
/* Any Exit won't be part of what we want. */
   if(strcmp(Pcodes[Op].Op,"Exit")==0){
     Grist[p].Type=PartOf;p++;continue;
   }
/* A Raise will be a missing Otherwise. We don't need it, or Jump that
preceeds it. */
/* Oct 99 change */
   if(strcmp(Pcodes[Op].Op,"Raise")==0){
     Grist[p-3].Type=PartOf;     /* Jump */
     Grist[p-2].Type=PartOf;
     Grist[p-1].Type=PartOf;
     Grist[p].Type=PartOf;p++;   /* Raise */
     Grist[p].Type=PartOf;p++;   /* Raise arg */
     continue;
   }
/* A When is the same as a Then in restricted Rexx */
   if(strcmp(Pcodes[Op].Op,"When")==0) Op=HereThen;
/* Source is supposed to be error free. */
   if(strcmp(Pcodes[Op].Op,"Bif")==0) Op=HereBifq;

   Grist[p].Type=OpCode;
   Grist[p].Value=Op;
   Grist[q].OpLen=p-q;q=p;
/* Special case - when we hit Store, expand as Assign and load. */
   if(strcmp(Pcodes[Op].Op,"Store")==0){
     Grist[p].Value=HereAssign;
     p=p+1;
     Grist[p].WithinP = No;
     kk=*(Ushort *)(Codep+p);
     Grist[p].Type=OpVar;
     Grist[p].Value=(kk&7)? Ac(kk) : Av(kk);
     Grist[p+1]=Grist[p];
     Grist[p+1].Type=Var;
     p+=2;continue;
   }
/* Special case - changing Arg(n) to Argn */
   if(strcmp(Pcodes[Op].Op,"Bifq")==0){
     k=Codep[p+1];
     if(k==(2*HereARG+128) && Grist[p-2].Type==Con){
       Ushort k;char x;
 /*      printf("\nG17 %d",Grist[17].Value);     */
       k=Consp[Grist[p-2].Value].Here;
       x=*(Symsp+k);
#if 0
 printf("\nArg@ %d %d %d %p %d %c",p,Grist[p-2].Value,k,Symsp,x,*(Symsp+k+1));
#endif
       if(x==1 && *(Symsp+k+1)>'0' && *(Symsp+k+1)<'6'){
/*         printf("\nInA@ %d",p);  */
         x=*(Symsp+k+1);
         if(x=='1') k=Arg1;
         if(x=='2') k=Arg2;
         if(x=='3') k=Arg3;
         if(x=='4') k=Arg4;
         if(x=='5') k=Arg5;
         Grist[p].Type=Arg;
         Grist[p].Value=k;
         Grist[p-2].Type=PartOf;
         Grist[p-1].Type=PartOf;
         Grist[p+1].Type=PartOf;
         p+=2;continue;
       }
     } /* Argn */
/* Special case - changing Arg(n,'E') to Argn _Exists */
     if(k==(2*HereARG+1) && Grist[p-4].Type==Con){
       Ushort k;char x;
       k=Consp[Grist[p-4].Value].Here;
       x=*(Symsp+k);
       if(x==1 && *(Symsp+k+1)>'0' && *(Symsp+k+1)<'6'){
         x=*(Symsp+k+1);
         if(x=='1') k=Arg1;
         if(x=='2') k=Arg2;
         if(x=='3') k=Arg3;
         if(x=='4') k=Arg4;
         if(x=='5') k=Arg5;
         Grist[p].Type=Arg;
         Grist[p].Value=k;
         Grist[p-4].Type=PartOf;
         Grist[p-3].Type=PartOf;
         Grist[p-2].Type=PartOf;
         Grist[p-1].Type=PartOf;
         Codep[p+1]=2*HereExists+1;
         p++;continue;
       }
     } /* ArgEn */
   } /* Bifq */
   if(strcmp(Pcodes[Op].Op,"Number")==0){
     Grist[p].DoDelta = Dod;
#if 0
     printf("\nUp5 %x",p);
#endif
   }
   p++;/* Optor */
   if(strncmp(Pcodes[Op].Op,"Bool",4)==0) {
     Grist[p].OpLen=2;q++;
     VoidJump=Yes;
     Freq[Op]++;
     continue;
   }/* Bool prefix */
   if(Pcodes[Op].Has.Num){
     k=Codep[p];
     Grist[p].Type=Number;
     Grist[p].Value=k;
     p++;
   }
   if(Pcodes[Op].Has.Symbol){
     kk=*(Ushort *)(Codep+p);
     Grist[p].Type=(kk&7) ? OpCon : OpVar;
     Grist[p].Value=(kk&7)? Ac(kk) : Av(kk);
     Grist[p+1].Type=PartOf;
/* If it is a constant in this position it will be something invoked. */
/* Take the chance to note externals. */
     if(Grist[p].Type==OpCon && Pcodes[Op].Has.Extra!=XtraSymbol){
       j=Grist[p].Value;
/* As soon as we set Callee flag we reuse the Label field. */
       if(!Consp[j].f.Callee)
         if(Consp[j].Label<2) Consp[j].f.External=True;
       Consp[j].f.Callee=True;
#if 0
       printf("\nCallee %x ",p);
       PrintConHere(j);
#endif
/* We don't need to keep the Call and Invoke because characteristics of the
target will imply those. */
       if(strcmp(Pcodes[Op].Op,"Call")==0){
/* It would be nice if we had Delta determined since that would tell number
of arguments but we don't */
         Consp[j].f.Called=True;
         Grist[p-1].Type=PartOf;
         Freq[Op]--;
       }
       else{
         /* Here the number of arguments is explicit. */
         ArgsOf(j,Grist[p-1].Value);
         Consp[j].f.Invoked=True;
         Grist[p-1].Type=PartOf;
         Grist[p-2].Type=PartOf;
         Freq[Op]--;
       }
     }
     p+=2;
   }
   if(Pcodes[Op].Has.Jump){
     if(VoidJump==No){
       kk=*(Ushort *)(Codep+p);
       Grist[p].Type=Jump;
       Grist[p].Value=kk;
       Grist[p+1].Type=PartOf;
/* Also must set target as a branch-in point. */
       if(kk>=CodeLen){
         printf("\n%x %x %s",p,kk,Pcodes[Op].Op);
         Failure;
         }
       Grist[kk].From=kk-p;
/* In some cases the branch is by reason of leaving an iterative loop.
  We need to track the boundaries of loops since they need temporaries. */
       if(LoopStart(Op)){
         if(strcmp(Pcodes[Op].Op,"ControlVar")){
           Grist[p].DoDelta = Dod;
#if 0
           printf("\nUp5 %x",p);
#endif
         }
         Grist[kk-1].DoDelta=DoEndsAt;
         DoEndsAt=kk-1;
/* Is this a worthwhile check? */
         if(strncmp(Pcodes[Codep[kk-1]>>1].Op,"Iter",4)){
           printf("\n%x %x",p,kk-1);
           Failure;
         }
       }
       p+=2;
     }
     else{
/* At this point we have Bool followed by comparison and have avoided putting
out a jump target.  However, the prefered representation is to avoid Bool and
represent it by a relative jump of zero. */
/* Move comparison back. */
       Grist[p-2].Type=Grist[p-1].Type;
       Grist[p-2].Value=Grist[p-1].Value;
/* Put in unchangeable zero. */
       Grist[p-1].Type=Number;
       Grist[p-1].Value=0;
     }
     VoidJump=No;
   } /* Jump */
   if(Pcodes[Op].Has.Extra==XtraNum){
     Grist[p].Type=Number;
     Grist[p].Value=k;
     p++;
   }
   if(Pcodes[Op].Has.Extra==XtraSymbol){
     kk=*(Ushort *)(Codep+p);
     Grist[p].Type=(kk&7) ? OpCon : OpVar;
     Grist[p].Value=(kk&7)? Ac(kk) : Av(kk);
     Grist[p+1].Type=PartOf;
     p+=2;
   }
   if(Pcodes[Op].Has.Extra==XtraJump){
     kk=*(Ushort *)(Codep+p);
     Grist[p].Type=Jump;
     Grist[p].Value=kk;
     Grist[p+1].Type=PartOf;
     Grist[kk].From=kk-p;
     p+=2;
   }
   Freq[Op]++;
   if(Op==21) printf("\nBfrq %d %d",Freq[Op],p);
 } /* p */
 Grist[q].OpLen=p-q;
 for(p=sizeof SegHeader;p<CodeLen;p++){
   Grist[p].ValueWas=Grist[p].Value;
#if 0
   if(Grist[p].Type==OpCode){
     printf("\nOpLen %x %d",p,Grist[p].OpLen);
   }
#endif
 }
} /* CopyAcross */

static void SetDelta(void){
 Ushort v, DoTotal;
 DoTotal=0;
 for(p=sizeof SegHeader;p<CodeLen;p++){
   Grist[p].Delta=DeltaNow;
#if 0
   if(p<=0xFB0) printf("\nDeltaNow = [%x] %d ",p,DeltaNow);
#endif
   DoTotal+=Grist[p].DoDelta;
   DeltaNow+=Grist[p].DoDelta;
   MaxDelta=Max(MaxDelta,DeltaNow);
   v=Grist[p].Value;
#if 0
   if(p>0x19C0 && p<=0x19CA) printf("\n%x %d %d %d",p,DeltaNow,Grist[p].Type,v);
#endif
   switch(Grist[p].Type){
   case PartOf:
   case Jump:
     break;
   case Number:
     if(WithinParse){
       if(Grist[p].Value==mParseEnd){
         DeltaNow--;
         WithinParse=No;
       }
#if 0
 Better to kill the loading of constants WithinParse.
       if(Grist[p].Value==mPosEq){
         DeltaNow--;
       }
       if(Grist[p].Value==mPosMinus){
         DeltaNow--;
       }
       if(Grist[p].Value==mPosPlus){
         DeltaNow--;
       }
       if(Grist[p].Value==mPattern){
         DeltaNow--;
       }
#endif
     }
     break;
   case Con:
   case Arg:
     if(!WithinParse) DeltaNow++;
     break;
   case Var:
     if(!WithinParse) DeltaNow++;
     break;
   case OpVar:
     break;
   case OpCon:
     /* Must be a CALL if args unknown. */
     if(!Consp[v].f.ArgsSet) ArgsOf(v,DeltaNow);
/* On external calls the number of arguments can be inconsistent if the
 callee knows what to expect. */
     if(Consp[v].f.Invoked)
       DeltaNow-=Rsp[v].ArgUse-1;
     else DeltaNow=DoTotal;
     break;
   case OpCode:
     DeltaNow-=Pcodes[v].Has.Down;
/* If the Op is one with a jump, and the jump amount is special, this is
Boolean compare and keeps a stack item. */
/* Oct 99 added zero check. How did this used to work? */
     if(Pcodes[v].Has.Jump && Grist[p+1].Type==Number
        && Grist[p+1].Value==0) DeltaNow++;
     if(strcmp(Pcodes[v].Op,"Bifq")==0){
     /* We are not changing the bif value but we need to know how
     many arguments the bif will prune from the stack. */
     /* MIN and MAX bifs are done individually. */
     /* Group ones not used by Bcode, hopefully. */
     /* Separate */
       Ushort BifNum, XtraArgs, Args;
       BifNum = Grist[p+1].Value & 126;
       XtraArgs = Grist[p+1].Value - BifNum;
       BifNum = BifNum/2;
       if(XtraArgs==1) XtraArgs=2;
       else if(XtraArgs==128) XtraArgs=1;
       else if(XtraArgs==129) XtraArgs=3;
       Args = Bifs[BifNum].MinArgs + XtraArgs;
       DeltaNow -= (Args-1);
     }
     /* Special cases because parsee is on stack throughout PARSE */
     if(strcmp(Pcodes[v].Op,"Parse")==0){
       WithinParse=Yes;
     }
#if 0
  Nowadays marked by EndParse.
     if(strcmp(Pcodes[v].Op,"Nop")==0){
       if(WithinParse){
         DeltaNow--;
         WithinParse=No;
       }
     }
#endif
     if(strcmp(Pcodes[v].Op,"Min")==0){
       DeltaNow-=Grist[p+1].Value;
     }
     if(strcmp(Pcodes[v].Op,"Max")==0){
       DeltaNow-=Grist[p+1].Value;
     }
     break;
   default:
     NewLine();
     printf("\n%x %x %d",n,p,Grist[p].Type);
     Failure;
   } /* Switch */
 } /* p */
 return;
}
static void ArgsOf(Ushort j,Ushort v){
  if(Consp[j].f.ArgsSet){
    if(Rsp[j].ArgUse!=v){
      PrintConHere(j);printf("\n args? %d",j);Failure;
    }
    return;
  }
  Consp[j].f.ArgsSet=Yes;
  Rsp[j].ArgUse=v;
#if 0
  printf("\n");
  PrintConHere(j);
  printf(" set %x %d %d",p,v,DeltaNow);
#endif
}
static Bool LoopStart(Ushort Op){
  if(strcmp(Pcodes[Op].Op,"Rep")==0
   || strcmp(Pcodes[Op].Op,"RepEver")==0
   || strcmp(Pcodes[Op].Op,"ControlVar")==0) return Yes;
  return No;
}
#if 0
/* The raw figures on code from standard are daunting.  2708 non-null clauses.
1.6 var refs, 1.25 con refs, .36jmp refs, per clause. 2.1 opcodes per clause.
Another 3 bytes in symbols per clause.  Some 32K of pcode with symbols.
Symbols will go away in compiled version.
We can remove .#Level .#NewLevel .#Bif .#Condition .#Loop from J18all.rx
because there won't be explicit stemming for the system variables.
Similarly "#Enabling." => "#Enabling" and for #PendingNow #Env_Name
#Env_Type #Env_Position #Env_Resource.
Reduces to 22872 of Pcode (sans symbols).
To make something fit for incorporation in the product, we would have to
do something like isolating the different sections of code, noting where
scopes join up.  A search for "longest equal section under rules for
making variables the same" would give a heuristic for how to map those
scopes onto variables.  Then subroutine detection would compact.
But is it worth all the coding or would doing it by hand be just as good?
*/
#endif
