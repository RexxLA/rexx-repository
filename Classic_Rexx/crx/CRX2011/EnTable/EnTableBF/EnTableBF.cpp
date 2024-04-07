/* This is a C++ version of the program used in conversion of the Rexx from the ANSI Standard, CRX.RX, into the Bcode equivalent (in symbolic form so that the Assembler can incorporate it into the 
CRX interpreter).  It assumes a previous stage has made D.T, a file which is CRX.RX in the form of Pcode (which is a lossless conversion apart from comments).

Here is how the original problem was viewed:

The raw figures on code from standard are daunting.  2708 non-null clauses.
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


The Pcode produced by CRX is compiled to a Bcode that is smaller (and restricted in function). Strictly speaking it is not true Pcode that is used since the build of CRX that produces it avoids some Pcode constructions,
but it is a slightly subset Pcode.

SYSOUT gets some (occasionally very approx) figures about the Pcode subject.  BF.I gets the file in Assembler that becomes part of CRX.

In outline, the Pcode is read as made, into memory addressed by Codep, Consp,Varsp, Symsp.  The code is turned to a less compact, more readily accessed form Grist.

There follows a lot of scanning around over the Grist for various sorts of labels and how they are called, which variables used in which section of code etc.

There is a preliminary output of how the 256 available Bcode points might be used but it is merely indicative because there is more to be calculated.  SetDelta tracks the number of temporaries that will be on
the runtime soft stack. That + args + local variables (maximums) determines how many points are needed for addressing off top-of-stack. (Actually it is twice that many used because load & store are distinguished.)

There are few left after those and ones for Opcodes and ones for System variables etc are taken.  Automatic Subroutine Recognition is aimed at making use of those to call fragments of shared code.

There is a degree of freedom in mapping the locals.  First call on that is to make arguments and variables into aliases, avoiding assignment between them.  Later calls are to improve ASR.

This program is working out what happens to the runtime stack when the Bcode is executing so it needs to know something of CRX internals.  It also needs to know how to interpret Pcode since it's input is
Pcode.

See also rules at top of CRX.RX, e.g.  Routines not coded to use just locals and system variables are marked with a leading underscore. 
*/

#include "stdafx.h"
using namespace std;
#define VarLimit 312
#define VarLimitPacked ((VarLimit+7)/8)
/* Size of a run time DO block in terms of rexx variables. */
#define Dod 5
/* Stretch used to hash for fragment finding: */
#define LookHash 6
/* Some variables are always present, even if not in the source code. */
#define VarLo 5 /* . RESULT RC SIGL */
#define ConLo 22 // Always present constants. (Better if this number had come with the input.)
// Marker for dot as target in parse.
#define ParseDot 0
/* This program can be tuned to optimise various ways the Bcode can be packed.  It is tuned by these defines. */
#define MeritProposal 10
/* Changing MeritCommit from 8 to 9 cost 67 bytes on total output, saved 9
codepoints. */
/* Changing MeritCommit from 9 to 10 cost 39 bytes on total output, saved 5
codepoints. */
/* Changing MeritCommit from 10 to 11 cost 67 bytes on total output, saved
 33 down to 30 codepoints. */
#define MeritCommit 11

#include "always.h"
  char * InArg; // Names input file.
  ofstream Out; // Hardwired here as "BF.T"
  char * Msg[]={
/* 0*/ "\nBF finished normally.\n",
/* 1*/ "\nBF did NOT finish normally.\n",
/* 2*/ "\nBF For personal use of those I give it to - BLM Oct 97",
/* 3*/ "\nBF takes one arg (CRX output, usually D.T) to make BF.T",
/* 4*/ "\nBF Unable to read %s.",
/* 5*/ "\nBF Input file fails checks.",
/* 6*/ "\nBF Memory exhausted.",
/* 7*/ "\nBF No labels.",
/* 8*/ "\nBF Make more variables space.",
/* 9*/ "\nBF Could not open output file.",
/*10*/ "\nBF Internal error - Sorry.",
  };
  int Acquired = 0; // bytes requested from Operating System.
  // Info about how to read Pcode:  
  #include "CodesHdr.h"  
/* These for where it is read into, in raw form. */
  Uchar *Codep, *CodepZi, *CodepLo;
/* The ...Len things count in bytes. */
  Ushort CodeLen, SymsLen, VarsLen, ConsLen;
  char * Symsp; // Where input is read to.

  int Freq[Dim(Pcodes)]; // To count frequency of occurrence of operations.
Ushort Av(Ushort v);/* Convert from address to 0,1,2,... of variables.*/
Ushort Ac(Ushort v);
void PrintConHere(Ushort w); // Output the literal.
void PrintVarHere(Ushort w); 
void ArgsOf(Ushort j,Ushort v);
void Separate(void);
Ushort Bsize(Ushort From,Ushort UpTo); // Count bytes in a fragment of Bcode.
Ushort Bcode(Ushort Scop,Ushort From,Ushort UpTo,Ushort Make);
 bool AssignTgt;
void ShowVarHere(Ushort w);
 int FreqHex,FreqFtns, FreqOps, TotBytes;
 int FreqVars, FreqCons, FreqJumps, Freqs, RangeOps, Points, TotLen;
 Ushort Arg0;/* Maintain Arg0 so that Bcode offsets of Args come right.*/
bool Middle, BifPart; /* Used in logic of Bcode making. */
Ushort SepCount;
/* Another use of the SkipTo field */
#define ByteOff SkipTo
Ushort FragNum;
void ShowConHere(Ushort w);
bool LoopStart(Ushort Op);
/*------------------------------------------------------------------------------
  Grist has one Pshape element per byte of the input Pcode.
õ-----------------------------------------------------------------------------*/
void PcodeToGrist(void);
// The intrface uses:
#define Arg1 7500
#define Arg2 7501
#define Arg3 7502
#define Arg4 7503
#define Arg5 7504
bool WithinParse; // Shared with SetDelta
Ushort p;
Uchar DeltaNow;
Ushort MaxDelta;
// It is programmer's choice whether to recognise an opcode by the spelling of its name or to use it in binary.  Here are a few we note in binary.
Uchar HereThen, HereAssign, HerePattern, HereExists, HereNop, HereBifq, HereARG;
/* Here is the shape for data on a per byte of Pcode basis. */
/* Order of .Type is used. Opcode and above can start fragments. */
 enum{Number,OpVar,OpCon,Jump,PartOf,Fragment,OpCode,Var,Con,Arg};
 typedef struct{
  bool WithinP;
  Uchar Type; // See enum.
  Uchar OpLen;
  Ushort Value;
  Ushort ValueWas; /* For checking */
  Ushort From; /* Earliest place that jumps to here. */
  Ushort Overlap; /* Avoid fragment overlap. */
  Ushort FragFact; /* About fragment call. */
  Uchar Delta;/* Intermediate stack items count. */
  Uchar ArgScp; /* Which first level scope arg is in */
  Ushort DoDelta;/* Iterative DO temps. */
  Ushort SkipTo;/* Used just to speed up matching. */
  Ulong Ahead;/* Used just to speed up matching. */  // Not used after SkipTo set so can alias.
} Pshape;
 Pshape * Grist;
/*------------------------------------------------------------------------------
 There is one Vshape element for each variable or constant of the input Pcode.
õ-----------------------------------------------------------------------------*/
/* The ....Count things count in language units. */
 Ushort VarsCount, ConsCount, StemCount;
typedef struct{
  union{
    struct{
      Ushort u; /* Zeroed so as to clear the flags. */
      Ushort ScopeNum;
    } g;
    struct{
      unsigned System:1; unsigned Scope:1; unsigned External:1; unsigned Open:1; unsigned Callee:1; unsigned Called:1; unsigned Invoked:1; unsigned HexIt:1;  unsigned ArgsSet:1;
    } f;
  } v;
  Ushort Here; // Offset of variable/constant name in provided Symbols.
  Ushort Label; // Offset of labelled position in provided Pcode.
  Ushort ArgUse;
  short VarNum;
} Vshape;
  Vshape * Varsp, * Consp; // To the arrays of info.
/*------------------------------------------------------------------------------
  There is one ScopeShape element for each routine in the input.
õ-----------------------------------------------------------------------------*/
  typedef struct{ // Data per scope, aka routine.
    Ushort Index;/* To symbol of label. */
    Ushort Lo;
    Ushort Args;
    Uchar ArgCt[7]; /* How often arg used. */
    bool Sized;
    Uchar LocalVars;
   	bitset<VarLimit> Alive;
   	bitset<VarLimit> Mapped; /* Stack slot mapped onto. */
  } ScopeShape;
  ScopeShape *Scp;
#if UseRestarts
  Uchar *ScpX; // To pass LocalVars to Restarts.
#endif
 #include "Grist.h"

int main(int argc, char * argv[]){ // Single byte chars in parameters.  In Visual Studio 2010 compiles, properties do not default to this, so need setting. (And entry point name)
  Ushort MaxLocals;
  Ushort MaxArgs;
  Ushort ScopeCount; // Scopes are the procedures the Rexx from ANSI is broken into. 
  cout << Msg[2];
  /* Detect when user needs help on the syntax of the function. */
  if (argc!=2) {cout << Msg[3];return 0;}
  InArg=(char *)argv[1];
try{
// Note some binary values.
  Ushort NullCon; // Index to null constant.
  for(int j=0;j<Dim(Pcodes);j++){
    if(strcmp(Pcodes[j].Op,"Assign")==0) HereAssign=j;
    if(strcmp(Pcodes[j].Op,"Then")==0) HereThen=j;
    if(strcmp(Pcodes[j].Op,"Bifq")==0) HereBifq=j;
    if(strcmp(Pcodes[j].Op,"Pattern")==0) HerePattern=j;
/* Here we just need a value not otherwise used. */
    if(strcmp(Pcodes[j].Op,"InterpEnd")==0) HereExists=j;
    if(strcmp(Pcodes[j].Op,"Nop")==0) HereNop=j;
  } // j
  for(int j=0;j<Dim(Bifs);j++){
    if(strcmp(Bifs[j].f,"ARG")==0) HereARG=j;
  } // j
 /*------------------------------------------------------------------------------
  Read in.
õ-----------------------------------------------------------------------------*/
/* If dependencies get too complicated there is the "out" of committing something and restarting the whole exercise. 
But there is no obvious way to gain from that mechanism.
*/
  ScopeCount = 0; // Otherwise VS compiler gets confused.
#if UseRestarts
Ushort Restarts = 0;
Restart:if(Restarts>10) throw 10; // 10 is more than enough in practice.
 if(Restarts){
   free(Codep);
   free(Symsp);
   free(Grist);
   for(Ushort k=0;k<ScopeCount;k++){
     ScpX[k]=Scp[k].LocalVars;
   }
   free(Scp);
 }
#endif
 #include "Absorb.h" 
  PcodeToGrist();

// The frequency of Pcode operators is just for interest.  It is the amount of Bcode we are minimising.
 cout << "\nOperators(hex) in copied/modified Pcode. (InterpEnd for Exists test)";
 cout << "\nThese are the operators that will be in the (space optimised) Bcode"; 
 Freqs = 0;
 for(int j=0;j<Dim(Freq);j++){
   if(Freq[j]){
	    cout << endl << setw(2) << hex << j << dec << ' ' << setw(13) << Pcodes[j].Op << ' ' << setw(4) <<Freq[j];     
     Freqs+=Freq[j];
     RangeOps++;
     }
 }
 // PcodeToGrist set the Called and Invoked flags.  Check a possible coding error of the original.
 for(int j=ConLo;j<ConsCount;j++){
   if(Consp[j].v.f.Called && Consp[j].v.f.Invoked){
     cout << "\n Inconsistent about whether function or routine.";PrintConHere(j);
   }
 }
/* Put labels in order, so we know where each routine ends. 
*/
Disorder:
 int r=0;
 for(int k=1;k<ScopeCount;k++){
   int j=Scp[k].Index;int m=Consp[j].Label;
   int t=Scp[k-1].Index;int n=Consp[t].Label;
   if(n>m){ // Since Index is the only field filled (except as initialising), the swop of Index is same as swop of all.
      Scp[k-1].Index=j;Scp[k].Index=t;r=1;}
 }
 if(r) goto Disorder;
/* Also need to go from label to scope. */
 cout << "\nScopes with their original (hex) offsets in Pcode";
 cout << "\nThese are the routines of the Rexx from the ANSI Standard, if original source was CRX.RX";
 for(int k=0;k<ScopeCount;k++){
   int j=Scp[k].Index;Consp[j].v.g.ScopeNum=k;
/* Fill in the bounds. */
   Scp[k].Lo=Consp[j].Label; // And from now on use Lo rather than Label to address the Pcode per routine.
   cout << endl << setw(3) << k << ' ' << hex << setw(4) << Scp[k].Lo << dec << ' ';
   PrintConHere(j);
 }
 Scp[ScopeCount].Lo=CodeLen;
/* Note which variables used by which routines. */
 for(int k=0;k<ScopeCount;k++){
   for(p=Scp[k].Lo;p<Scp[k+1].Lo;p++){
     if(Grist[p].Type==Var || Grist[p].Type==OpVar){
       int j=Grist[p].Value;
       if(Varsp[j].v.f.System==false){
         Scp[k].Alive[j] = true;
       }
     }
     /* Also which args */
     if(Grist[p].Type==Arg){
       Ushort t=Grist[p].Value;
       /* Compute actual arg number */
       t=t-Arg1;
       Scp[k].Args=Max(Scp[k].Args,t+1);
       if((t=++Scp[k].ArgCt[t])==3) Scp[k].ArgCt[t]=2;/* 0,1,more uses */
       Grist[p].ArgScp=k;
     }
     /* Also check calls. */
     if(Grist[p].Type==OpCode){
       int v=Grist[p].Value;
       int j=Scp[k].Index;
       if(strcmp(Pcodes[v].Op,"Return")==0){
         if(Consp[j].v.f.Invoked){
           cout << "\n Invoked as function when CALL needed? ";PrintConHere(j);
         }
       }
       if(strcmp(Pcodes[v].Op,"Returns")==0){
         if(Consp[j].v.f.Called){
           cout << "\n Called as routine when invocation as function needed? ";PrintConHere(j);
         }
       }
     }
   }
 }
 /*------------------------------------------------------------------------------
  Note which bcode routines will have which variables in their "automatic" storage.
õ-----------------------------------------------------------------------------*/
/* Look to see where "Open" routines are called from. */
/* Their caller must look after variables for them. */
Propagate:
 int k;
 for(r=0,k=0;k<ScopeCount;k++){
   for(p=Scp[k].Lo;p<Scp[k+1].Lo;p++){
     int a=Grist[p].Type;int b=Grist[p].Value;
     if(a==OpCon && Consp[b].v.f.Open && !Consp[b].v.f.External){
       int j=Consp[b].v.g.ScopeNum;
       if(j>=ScopeCount){
         PrintConHere(b);cout << endl << j << ' ' << b;
         throw 10;
       }
/* Add Alives of j to Alives of k and note if it makes a difference. */
	   Spare=Scp[k].Alive;
       Scp[k].Alive |= Scp[j].Alive;
       if(Scp[k].Alive != Spare) r=1;
     }
   }
 } // k
 if(r) goto Propagate;

 for(k=0;k<ScopeCount;k++){
   int j=Scp[k].Index;
/* Open routines don't have variables of their own. */
   if(Consp[j].v.f.Open) Clear(Scp[k].Alive);
 } // k

/* How clean is the scope position? */
 for(int j=VarLo;j<VarsCount;j++){
   r=0;
   for(k=0;k<ScopeCount;k++){
     if(Scp[k].Alive[j]){
       r++;if(r==2){
         cout << "\nPossible global - " << j << " - ";PrintVarHere(j);
         cout << " also in ";PrintConHere(Scp[k].Index);
       }
     }
   }
 }
/* Show the Alives array. */
 cout << "\n Variables are allocated  as Automatic to procedures, as follows:"; 
 for(int k=0;k<ScopeCount;k++){
   cout << endl;PrintConHere(Scp[k].Index);
   cout << "[" <<Scp[k].Args<<"]:";
   for(int j=VarLo;j<VarsCount;j++){
     if(Scp[k].Alive[j]){
       cout << " ";PrintVarHere(j);
// I don't understand this bit. 
#if UseRestarts
       if(Restarts==0)
         Scp[k].LocalVars++;
#endif
       Varsp[j].v.g.ScopeNum=k;
     }
   } // j
   cout << " [" << Scp[k].LocalVars << "]";
 } // k
 /*------------------------------------------------------------------------------
  Show some more information.  (For human consumption)
õ-----------------------------------------------------------------------------*/
 // Some counting, preparatory to deciding how the first byte of a Bcode is to be interpreted. 
 Ushort ExternalsCount, InternalsCount, GlobalsCount, TgtRange;
 ExternalsCount=InternalsCount=GlobalsCount=MaxLocals=MaxArgs=MaxDelta=0;
 cout << "\nThese are the 'External' variables:";
 for(int j=ConLo;j<ConsCount;j++){
   if(Consp[j].v.f.External){
     cout << endl;PrintConHere(j);ExternalsCount++;
   }
   else if(Consp[j].v.f.Callee) InternalsCount++;
 }
 cout << "\nThese are the 'Global' variables:";
 for(int j=VarLo;j<VarsCount;j++){
   if(Varsp[j].v.f.System){
     cout << ' ';PrintVarHere(j);
     GlobalsCount++;
   }
 }
 for(k=0;k<ScopeCount;k++){
   MaxLocals=Max(MaxLocals,Scp[k].LocalVars);
   MaxArgs=Max(MaxArgs,Scp[k].Args);
 }

 cout << "\nExternal callees: " << ExternalsCount;
 cout << "\nInternal callees: " << InternalsCount;
 cout << "\nGlobal variable type: " << GlobalsCount;
 cout << "\nLocalVars overall maximum: " << MaxLocals;
 cout << "\nArgs overall maximum: " << MaxArgs;
 MaxLocals+=MaxArgs;


/* Setting the "Delta" which counts args & intermediates on the stack had
to wait until we had gathered arg info for each routine. */
 SetDelta();
cout << "\nMaxDelta (offset into Bcode stack) " << MaxDelta;

 /*------------------------------------------------------------------------------
   Look for opportunities to use arguments as variables. 
õ-----------------------------------------------------------------------------*/

 cout << "\nHere we try to alias arguments with a variable of the procedure";
 for(k=0;k<ScopeCount;k++){
   cout << "\nArg number of uses for each arg in this scope " << k << ' ' << Scp[k].Lo << ' '; PrintConHere(Scp[k].Index);
   for(p=0;p<5;p++) if ((int)Scp[k].ArgCt[p]) cout << "  " << (int)Scp[k].ArgCt[p];

/* Since the Arg started as a Bif in Pcode there are a lot of PartOfs about. (Nop elements in Grist) */
   for(p=Scp[k].Lo;p<Scp[k+1].Lo;p++){
     if(Grist[p].Type==PartOf) continue;
     if(Grist[p].Type!=Arg) break;
     r=Grist[p].Value-Arg1;
     if(Scp[k].ArgCt[r]!=1) break;
/* It's one use will have been to assign it to a variable. */
     if(Grist[p+1].Type!=PartOf) throw 10;
     if(Grist[p+2].Type!=OpCode) break;
     if(Grist[p+2].Value!=HereAssign) break;
     if(Grist[p+3].Type!=OpVar){cout << "\n " << hex << p << dec;throw 10;}
     int j=Grist[p+3].Value;
     if(Varsp[j].v.f.System) break;
     /* We don't want to commit LocalVars yet so mark as aliased to an arg */
     cout << "\nAliased arg " << r+1 << " from scope " << k << ' ';
     PrintVarHere(j);
     Varsp[j].VarNum=-r-1;
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
   e. Global variable references are the same.
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
/* we are not going to compare very short fragments so we can build type info look-ahead into a hash number. This just to speed up comparing every position in the Pcode with every other position.
*/
 int Al;
 for(k=0;k<ScopeCount;k++){
   for(p=Scp[k].Lo;p<Scp[k+1].Lo;p++){
     Ushort m;int n;
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
   for(int q=p-1;q>=Scp[0].Lo;q--){
     if(Grist[q].Ahead==Al){
       Grist[q].SkipTo=r;r=q;
     }
   }
 }
/* Hard to see that it matters which order the scopes are considered in. */
{ Ushort a,b,e,f,g,i,j,s,t,p,pp,q,qq,u,v,x,y,r,z;short c,d,w,m,n;
 Ushort Bro[VarLimit],Sis[VarLimit];/* Used in matching. */
/* We depend on finding long ones (and committing them) before short ones.
 Committing the longest found doesn't quite do this, it seems.  Maybe the
 match rules are such that effects of committing a short make a longer
 possible.  Anyway, we use PrevLen to avoid trouble. */
 int  PrevLen=CodeLen;
Matching:
 w=0;/* Merit of best proposal so far. */
 for(k=0;k<ScopeCount;k++){
   for(p=Scp[k].Lo;p<Scp[k+1].Lo;p++){
     s=Grist[p].Type;
/* "Load Stack" can be separated from an Opcode, but Opcode with its argument
 should be atomic. */
     if(s<OpCode) continue;
/* Some operands are not good places to start looking for a fragment. */
     if(Grist[p].WithinP) continue;
/* Compare fragment at p with other fragments, at q. */
     pp=Grist[p].Overlap;
     q=p;
NewQ:
     q=Grist[q].SkipTo;if(!q) continue;
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
         if(Varsp[x].v.f.System) goto NewQ;
         if(Varsp[y].v.f.System) goto NewQ;
         if(x==ParseDot) goto NewQ;
         if(y==ParseDot) goto NewQ;
/* If in the same scope they can't be merged. (Really?)*/
         a=Varsp[x].v.g.ScopeNum;
         b=Varsp[y].v.g.ScopeNum;
         if(a==b) goto NewQ;
/* Different scopes, but are they already mapped? */
         c=Varsp[x].VarNum;
         d=Varsp[y].VarNum;
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
           Ushort kk;
           kk=Scp[a].LocalVars+Scp[a].Args+1+c; /* c is neg */
           if(Scp[b].Mapped[kk]) goto NewQ;
           if(kk>Scp[b].LocalVars) goto NewQ;/* Could do more. */
           goto Relate;
         }
         if(d<0 && c==0){
           Ushort kk;
           kk=Scp[b].LocalVars+Scp[b].Args+1+d;/* d is neg */
           if(Scp[a].Mapped[kk]) goto NewQ;
           if(kk>Scp[a].LocalVars) goto NewQ;
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
           if(Scp[b].Mapped[c]) goto NewQ;
/* Restart mechanism didn't solve things so better not keep as option
extending locals. */
           if(c>Scp[b].LocalVars) goto NewQ;
           goto Relate;
         }
         else{
           if(d<0) goto Relate;
           if(Scp[a].Mapped[d]) goto NewQ;
           if(d>Scp[a].LocalVars) goto NewQ;
           goto Relate;
         }
         throw 10;
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
   cout << "\nProposal @" << hex << m << ' ' << n << ' ' << dec << w << ' ' << g;
// Log shows that negative gain didn't happen.
#if 0 
  if(w>PrevLen){
     printf("\nScanP");fflush(stdout);
/* ScanP is off original, not Grist */
     ScanP(m,m+w);
     ScanP(n,n+w);
     NewLine();
     longjmp(ErrSig,1);
  }
#endif
/* Turn this proposal to fact before trying again. */
/* Step through fragments with u & v respectively. */
   u=m;v=n;
   for(r=0;r<w;r++){
     s=Grist[u].Type;
     if(s!=Var && s!=OpVar){
       if(s!=Arg) goto MatchedR;
/* Args match when offset matches which needs Arg0 the same. */
         a=Grist[u].ArgScp;
         b=Grist[v].ArgScp;
         if(a==b) goto MatchedR;
         i=Scp[a].LocalVars+Scp[a].Args;
         j=Scp[b].LocalVars+Scp[b].Args;
         /* Have to set .Sized in case something later takes advantage. */
         if(i!=j){
           if(i>j && Scp[b].Sized) throw 10;
           if(j>i && Scp[a].Sized) throw 10;
           if(i>j){
             Scp[b].LocalVars+=i-j;
             cout << "\nLocal variables count ";
             PrintConHere(Scp[b].Index);
             cout << " now " << Scp[b].LocalVars;
           }
           if(j>i){
             Scp[a].LocalVars+=j-i;
             cout << "\nLocal variables count ";
             PrintConHere(Scp[a].Index);
             cout << " now " << Scp[a].LocalVars;

           }
         }
         Scp[a].Sized=true;
         Scp[b].Sized=true;
         goto MatchedR;
     }
     x=Grist[u].Value;
     y=Grist[v].Value;
/* If they are the same variable, good enough, even if not yet mapped. */
     if(x==y) goto MatchedR;
/* Cannot merge globals. */
         if(Varsp[x].v.f.System) goto NewQ;
         if(Varsp[y].v.f.System) goto NewQ;
         if(x==ParseDot) goto NewQ;
         if(y==ParseDot) goto NewQ;
/* If in the same scope they can't be merged. */
         a=Varsp[x].v.g.ScopeNum;
         b=Varsp[y].v.g.ScopeNum;
         if(a==b) goto NewQ;
/* Different scopes, but are they already mapped? */
     c=Varsp[x].VarNum;
     d=Varsp[y].VarNum;
/* If they are both negative it means they were aliased on to arguments. */
     if(c<0 && d<0){
       /* Unlikely they will be different args although we might be able
        to cope. */
       if(c!=d) throw 10;
       i=Scp[a].LocalVars;
       j=Scp[b].LocalVars;
       if(i==j){
         cout << "\nSameSize ";
         PrintConHere(Scp[a].Index);
         cout << ' ';
         PrintConHere(Scp[b].Index);
       }
       else if(i>j){
         k=i-j;
         cout << "\nExtend by " << k << ", ";PrintConHere(Scp[b].Index);
         if(Scp[b].Sized) throw 10;
         Scp[b].LocalVars+=k;
       }
       else {
         k=j-i;
         cout << "\nExtend by " << k << ", ";PrintConHere(Scp[a].Index);
         if(Scp[a].Sized) throw 10;
         Scp[a].LocalVars+=k;
       }
       cout << ' ';PrintVarHere(x);
       cout << ' ';PrintVarHere(y);
       Scp[a].Sized=true;
       Scp[b].Sized=true;
       goto MatchedR;
     }
     if(c<0 && d==0){
       k=Scp[a].LocalVars+Scp[a].Args+1+c;
       if(Scp[b].Mapped[k]) throw 10;
       if(k>Scp[b].LocalVars) throw 10;
       Varsp[y].VarNum=k;
       Scp[b].Mapped[k] = true;
       Scp[a].Sized=true;
       goto MatchedR;
     }
     if(d<0 && c==0){
       k=Scp[b].LocalVars+Scp[b].Args+1+d;
       if(Scp[a].Mapped[k]) throw 10;
       if(k>Scp[a].LocalVars) throw 10;
       Varsp[x].VarNum=k;
       Scp[a].Mapped[k] = true;
       Scp[b].Sized=true;
       goto MatchedR;
     }
/* It isn't sound to assume that if both unmapped they can be mapped to
match but lets's see. */
     if(c==0 && d==0){
/* Find an unused position in both scopes. */
       for(j=1;j<VarLimit;j++){
         if(!Scp[a].Mapped[j] && !Scp[b].Mapped[j]){
           Varsp[x].VarNum=j;
           Varsp[y].VarNum=j;
           Scp[a].Mapped[j];
           Scp[b].Mapped[j];
           cout << "\nMerged variables ";
           PrintConHere(Scp[a].Index);
           cout << ':';
           PrintVarHere(x);
           cout << ' ';
           PrintConHere(Scp[b].Index);
           cout << ':';
           PrintVarHere(y);
           cout << " @ " << j;
/* I can't see what is intended here.  How can an index on all the vars be compared with a count of locals?  So I'll leave the code out! 
*/
#if 0 
           if(j>Scp[b].LocalVars){
             Scp[b].LocalVars=j;
             cout << " Retry with more local variables.";
             Restarts++;
            goto Restart;
           }
           if(j>Scp[a].LocalVars){
             Scp[a].LocalVars=j;
             cout << " Retry with more local variables.";
             Restarts++;
            goto Restart;
           }
#endif
           goto MatchedR;
         }
       }/* j */
       throw 10;
     }
     if(c>0 && d>0){
       if(c==d) goto MatchedR;
#if 0
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
#endif
       throw 10;
     }
     if(c>0){
       Scp[b].Mapped[c]=true;
       Varsp[y].VarNum=c;
       cout << "\nMapped ";
       PrintConHere(Scp[a].Index);
       cout << ' ';
       PrintVarHere(x);
       cout << ' ';
       PrintConHere(Scp[b].Index);
       cout << ':';
       PrintVarHere(y);
       cout << " @ " << c;
/* I can't see what is intended here.  How can an index on all the vars be compared with a count of locals?  So I'll leave the code out! 
*/
#if 0 
       if(c>Scp[b].LocalVars){
         Scp[b].LocalVars=c;
         cout << " Retry with more local variables.";
         Restarts++;
         goto Restart;
       }
#endif
       goto MatchedR;
     }
     if(d>0){
       Scp[a].Mapped[d];
       Varsp[x].VarNum=d;
       cout << "\nMapped ";
       PrintConHere(Scp[b].Index);
       cout << ':';
       PrintVarHere(y);
       cout << ' ';
       PrintConHere(Scp[a].Index);
       cout << ':';
       PrintVarHere(x);
      cout << " @ " << d;
#if 0
       if(d>Scp[a].LocalVars){
         Scp[a].LocalVars=d;
        cout << " Retry with more local variables.";
         Restarts++;
         goto Restart;
       }
#endif
       goto MatchedR;
     }
     cout << endl << c << ' ' << d;
     PrintVarHere(x);
     PrintVarHere(y);
     throw 10;
MatchedR:
     Grist[v].Type=PartOf; /* Keep one copy, lose one. */
     Grist[u].Overlap=m;
     u++;v++;
   } /* r */
/* Change the duplicate at n to a call. */
   Grist[n].Type=Fragment;
   Grist[n].FragFact=m; /* What it is same as. */
   Grist[n+1].FragFact=w; /* Thats length */
   Grist[n+2].FragFact=g; /* Which scope. */
   PrevLen=w;
   goto Matching;
 } /* A commit */
} /* Routining */

// Write out the Bcode in a form the Assembler will accept. 
  #include "writeasm.h" 

  cout << Msg[0];
  return 0;
} // try
catch( int x ) {
  cout <<  Msg[x];
  exit(x);
}
} // Main

/*------------------------------------------------------------------------------
  Converters between an offset taken from Pcode (where CRX.EXE made it) and index to variable/constant in an array here in this program. 
õ-----------------------------------------------------------------------------*/
Ushort Av(Ushort v){
/* We are passed an offset into a segment that CRX had internally.  Since Rexx variables are (based on) eight bytes, this will be the sum of a header and 8 times an index to the variable.  I think original code
had the 8 right by ensuring Vshape here was the same sizeof as Vshape in CRX assembler.
*/
  return (v-sizeof SegHeader)/8;
} /* Av */
Ushort Ac(Ushort v){
  return (v-sizeof SegHeadeC)/8;
} /* Ac */

void ArgsOf(Ushort j,Ushort v){
  if(Consp[j].v.f.ArgsSet){
    if(Varsp[j].ArgUse!=v)
	    	throw 10;
    return;
  }
  Consp[j].v.f.ArgsSet=true;
  Varsp[j].ArgUse=v;
} // ArgsOf

/*------------------------------------------------------------------------------
 Other little routines. 
õ-----------------------------------------------------------------------------*/

bool LoopStart(Ushort Op){
  if(Op>=Dim(Pcodes))
	 throw 10;  
  string s = Pcodes[Op].Op;
  if(strcmp(Pcodes[Op].Op,"Rep")==0
   || strcmp(Pcodes[Op].Op,"RepEver")==0
   || strcmp(Pcodes[Op].Op,"ControlVar")==0)
   return true;
  return false;
} // LoopStart

void PrintConHere(Ushort w){// A sequence of chars to print, but there is no terminator.
 Ushort k,n;
 string s;
 if(w>=ConsCount) return;
 k=Consp[w].Here;
 n=(Uchar)Symsp[k];
 s.assign((char *)&Symsp[k+1],n);
 cout << s;
} /* PrintConHere */

static void PrintVarHere(Ushort w){
 Ushort k,n;char c;
 if(w>=303)
   w=w;
 string s;
 if(w>=Arg1){
   c = '1'+(w-Arg1);
   cout << "Arg" << c;
   return;
 }
 k=Varsp[w].Here;
 if(!k) throw 10;
 n=(Uchar)Symsp[k];
 s.assign((char *)&Symsp[k+1],n);
 cout << s;
} /* PrintVarHere */



Ushort Bsize(Ushort From,Ushort UpTo){
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

void Separate(void){
/* There is a limit to continuations/complexity that MASM will take. */
  if(!Middle){
    Out << "db ";Middle=true;SepCount=0;return;
  }
  SepCount++;
/*  Problem here because the original output routines allowed qeurying of chars-since-newline but << mechanism doesn't. 
*/
#if 0  
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
#endif
}
/*------------------------------------------------------------------------------
  Little routines for showing.
õ-----------------------------------------------------------------------------*/
static void ShowVarHere(Ushort w){
 Ushort k;
 if(w>=Arg1){
   Out << "Arg" << (char)('1'+(w-Arg1)) << '-' << 2*Arg0;
   return;
 }
 k=Varsp[w].Here;
 if(!k) throw 10;
 string s = string((char *)Symsp+k+1, (Uchar)Symsp[k]);
 Out << s;
} /* ShowVarHere */

static void ShowConHere(Ushort w){
 Ushort k;
 if(w>=ConsCount) return;
 k=Consp[w].Here;
 if(!k) throw 10;
 string s = string((char *)Symsp+k+1, (Uchar)Symsp[k]);
 Out << s;
} /* ShowConHere */
 
#include "WriteBcode.h"