/*
About options.  No options produces the tables I first tried which used
lots of arithmetic and were good, but a bit complex so that it was hard
to pack into the states info on what to do with the particular state.
Option D means use DirectAim on tokens, ie if a token (when accepted)
always leads to the same state this info is recorded with the token (only).
Option U means an array is used for shift targets irrespective of the token.
Otherwise only selected tokens index the array.

Part A is concerned with the shifts.  What it does reflects what the
parser algorithm does at parsing time.  It notes the Direct shifts
where only one token is acceptable.  For the rest a bit matrix is
used for whether the state accepts the token.  If the acceptance test
is past the target for the shift is either looked up in an array or
computed.  Part A notes the constraints (implied in using arithmetic)
on the gaps between addresses in states; these constraints to be resolved
in conjunction with those from reductions.

A1. Initialize, and read in the problem to be solved.
A2. Make the Boolean matrix for shift acceptance.
A3. Post-acceptance token equivalence.
A4. Put the switches in the form with most-used-target last.
A5. Store equations about shifts.  Deduce which can be arithmetic. (Loop to A4)
A6. Eliminate subsets in shifting.
A7. Overlay amongst the full shift array.

Part B is concerned with reductions. (For the reduction switches the
reference states, off the stack, take on the role that tokens have for
shifting, with the difference that no acceptance test is needed; the set of
possible values on the stack is known.)
At parsing time the general case is to test the reference state on
magnitude, so all high ones can go to the same target.  This is repeated
as necessary until the rest of the targets are all different. At this
point an arithmetic calculation is used.

B1. Eliminate subsets in reductions.
B2. Equations for reduction.
B3. Tidy up the record of constraints. Note how many words each individual
    state.
B4. Rank the states into different partitions of the state address space.

Part C solves the problem set up by Parts A & B. There is a record of what
gaps between state addresses have to be equal.  There is a record of the
size needed for each state.  There is a record of what partition a state
must fall in (if ranked at all).  How to position the states in accordance?
A full exhaustive search is not practical; something like factorial(200)
possibilities. Something is known of the values of gaps as well as equalities;
if a gap spans partitions it will be known positive or negative, and a
minimum absolute value. Using the minimums, the states can be laid out.
(If the constraints were contradictory it would be necessary to make Part B
take more of them out of the picture by using non-arithmetic methods).
Where the laying out results in states overlapping, extra gaps are invented
and added to the constraints in play so as to separate them.  This results
in an initial feasible layout for just those states involved in gaps
spanning partitions.

A reminder of what I want to try.  Replace 'array' method by special casing
and arithmetic. Trials with moveable partitions; required list of actions
done so can back out. Requires Setup as rules rather than initial map.
C1. Layout states with gaps that span partitions.
C2. Recursive trials for mapping the remaining constrained states.

D1. Put more assembler on the output.
*/
/* Capital T alone is for a field which is a trigger. Capital G alone is
for a goto. (If T then new state is G). */
/* Capital L and R for left and right of a gap, [L]+gap=[R]. */
/* These numbers read in: */
static Ushort AtomsCount;/* Those distinct in the syntax. (After sr.i grouping)
                         Terms token and token group also used. */
static Ushort PairsCount; /* The trigger-gotos for both shift and reduce. */
static Ushort StatesCount;
static Ushort LowKey; /* Lowest of the 'pure' keys, eg not 'THEN' etc. */
/* These deduced from readin. */
static Ushort PruneMax;
static Ushort StackMax;
/* These are options. */
static Ushort DirectAim;
static Ushort UseArray; /* On for *all* tokens to be UseArray. */
/* These numbers are the size of the Boolean acceptance matrix. */
static Ushort StateAcceptCt;/* Countup on initial bool matrix */
static Ushort TokenAcceptCt;/* Countup on initial bool matrix */
/* These numbers are the size of the non-Boolean array switch. */
static Ushort RetainedStateCt; /* Bound of array. */
static Ushort RetainedTokenCt; /* Bound of array. */
static Ushort Used,Unused; /* Parts of the shift array. */
static Ushort x[64],y[64]; /* Indices to shift array. */

static Ushort AtomBreak; /* Added to atom numbers to distinquish . */
static Ushort Needed; /* Words needed for all the states. */
static Ushort RankedTotal; /* Needed for ranked states. */
static Ushort SetupProblemCt; /* # separate problems. */
static Ushort ConstrainCt; /* States with position constrained. */
static Ushort MaxRank; /* Divisions ranked into. */
static Ushort ShiftCt; /* States with NoShift. */
static Ushort UseArrayCt; /* Tokens which don't fit Arith scheme. */
static Bool LastPass; /* Used in the logic. */
static Bool FlatOnce;
static Bool RankRanc;
static Ushort GapID;
static jmp_buf RemapEnv;/* For longjmp to Remap */
static Ushort RangeCutter;
static Ushort Difficults;

/* Here are typedefs for things to be arranged in arrays or wallets. */
typedef struct{/* For State. */
  unsigned NoShift:1; /* Originally. */
  unsigned NoRed:1; /* No reductions */
  unsigned Direct:1; /* Test acceptance by single value AcceptValue. */
  unsigned FlatSym:1; /* Varieties of symbol treated equally. */
  unsigned Subset:1; /* Subset of another for shifting. (Or equal) */
  unsigned SubsetR:1; /* Subset of another for reduces. (Or equal) */
  unsigned DirectR:1; /* (Remaining) reductions all to same place. */
  unsigned Filter:1;/* Test one of reductions early. */
  unsigned FilterHi:1; /* Test one reduction at other end of list early. */
  unsigned IsSpecial:1; /* Needs special test. */
  unsigned ArrayGone:1; /* Work for constructing merged full array. */
  unsigned Constrained:1; /* Not total freedom in mapping this one. */
  unsigned IsDecided:1; /* In latest decisions, not necessarily Decided set. */
  unsigned RankSettled:1; /* Settled only for this go at ranking. */
  unsigned MapHigh:1; /* Advice to mapper based on rank. */
  unsigned MapLow:1; /* Advice to mapper based on rank. */
  unsigned Setup:1; /* Suitable to be setup (decided) first. */
  unsigned Final:1;
  /* These are just read in: */
  Ushort KeysOffset; /* Goes in state to identify keywords accepted. */
  Ushort HasCat; /* One if || allowed next. */
  Ushort StackPhysical; /* Pushed when state entered. */
  Ushort Prune;
  Ushort HasExit;
  Ushort ExitNum;
  Ushort Error;
  /* These about acceptance: */
  Ushort AcceptValue;
  Ushort AcceptGoto;
  Bool * AcceptStrip; /* Valid shifts strip */
  Ushort StateAccept; /* What state accepts. */
  /* About ones dealt with as singles: */
  Ushort AimGoto;
  /* About ones dealt with as subsets: */
  Ushort SubsetOf;
  Ushort SubsetOfR;
  /* About the Array shift mechanism: */
  Ushort * Shift; /* Shift switch in full form as opposed to a list of pairs.*/
  Ushort ArraySame;
  Ushort Used,Unused;
  /* Finding lists: */
  Ushort ShLo; /* Reaches pairs involved in shifting. */
  Ushort ShZi;
  Ushort ReLo; /* Reaches pairs involved in reducing. */
  Ushort ReZi;
  Ushort VecReZi;/* Part of reduction list split by arithmetic. */
  /* ReLo and ReZi are altered when deciding how to make reductions but
  the original values are relevant to showing what is on the stack as
  the reduction is made. */
  Ushort ReLoOrig;
  Ushort ReZiOrig;
  /* 'Result' type info. */
  Ushort Rank,Ranc;
  Ushort Decided; /* When mapped */
  Ushort Lo,Hi; /* Limits on Decided */
  Ushort Delta; /* Contribution to the shift calculation. */
  Ushort Involved; /* With Setup */
  Ushort Section; /* To which its reductions contributed. */
  Ushort SpecialK;
  Ushort Physical; /* Address space taken. */
  Ushort PhysicalR; /* Address space taken for reduction. */
  /* Other */
  Ushort ChainL,ChainR;/* Find appearences on left & right. */
  Ushort Work;
  Ushort Difficulty;/* Raise this get state mapped earlier. */
} State;
typedef struct {
  unsigned UseArray:1;
  unsigned Alias:1;
  unsigned IsDecided:1;
  unsigned Constrained:1;
  unsigned ArrayGone:1; /* Discounted for full array. */
  unsigned DirectAim:1; /* Only one target (after acceptance tested). */
  unsigned DirectSubj:1; /* Looked for in Direct acceptance. */
  Ushort AliasTo;
  Ushort AimedAt;
  Ushort TokenAccept; /* Couple to StateAccept. */
  Ushort ArraySame;
  Ushort ChainL,ChainR;/* Find appearences on left & right. */
  Ushort Involved; /* With Setup */
  Ushort Work;
  Ushort Decided;
} Atom;
typedef struct{
  Ushort T;
  Ushort G;
} Pair;
/* There are wallets for Pairs (on T change state to G), for the
States, for the Gap values, for the sections of the gap values,
for the decisions, for the ranks, for directs, for essentials. */
/* Atoms wasn't made into a wallet, but could be if we wanted to create
new atoms. */
#define Wp Pap->e
#define Ws Stp->e
#define Wg Gpp->e
#define Wm Gmp->e
#define Wd Dep->e
#define Wr Rp->e
#define Wf Fdp->e
#define We Esp->e
/* There are variables and iterators used for the common loops. */
#define DoVars Ushort c,j,k,q
/* This is a loop thru the states looking at shifts: */
#define DoShiftj for(j=0;j<StatesCount;j++){\
  if(Ws[j].NoShift) continue;
/* An inner loop to cover pairs of states, j&q. */
#define DoAboveq for(q=j+1;q<StatesCount;q++){\
  if(Ws[q].NoShift) continue;
/* An inner loop to cover pairs of states, j&q, with q<j. */
#define DoBelowq for(q=0;q<j;q++){\
  if(Ws[q].NoShift) continue;
#define EndShifts }
#define DoRedj for(j=0;j<StatesCount;j++){\
  if(Ws[j].NoRed) continue;
#define DoRedq for(q=j+1;q<StatesCount;q++){\
  if(Ws[q].NoRed) continue;
#define EndReds }
/* Each switch is a section of the pairs wallet. */
#define DoSwitchk for(k=Ws[j].ShLo;k<Ws[j].ShZi;k++){
#define DoRedSwitk for(k=Ws[j].ReLo;k<Ws[j].ReZi;k++){
#define EndSwitch }
typedef struct{
  Wallet w;
  Pair e[1];
} Pairs;
static Pairs *Pap;
typedef struct{
  Wallet w;
  State e[1];
} States;
static States *Stp;
typedef struct{
  Wallet w;
  struct{
    /* The idea of a gap is that the value of the gap between L and R has
    identifier N.  The identifier is used on the Wm wallet to see (eg) whether
    the value of the Gap is determined yet. This route will also find other
    gaps with the same Gap ID. */
    Ushort L;
    Ushort R;
    Ushort N;
    Ushort ChainL,ChainR;/* Find appearences on left & right. */
    Ushort Sample; /* Of a state that uses this gap. */
  } e[1];
} Gaps;
static Gaps *Gpp;
/* AtomBreak added to atom numbers to distinquish them from states . */
#define AtomBreak 1000
typedef struct{/* For sections of the gaps wallet. */
  Wallet w;
  struct{
    unsigned IsDecided:1;
    unsigned Positive:1;
    unsigned Inverted:1;
    Ushort Decided;
    Ushort Lo;
    Ushort Involved; /* With Setup */
    Ushort Sample; /* of a state involved. */
    Ushort GapMax,GapMin,AbsMax,AbsMin;
  }e[1];
} GapSections;
static GapSections *Gmp;
typedef struct{
  Wallet w;
  struct{
    Ushort Type; /* Decision type */
    Ushort Index;/* Decision detail, eg Gpp index. */
    short Slant;/* How to use the equation. */
    Ushort Which; /* Which is given value by the equation. */
    Ushort Deduced; /* Value given */
  } e[1];
} Decisions;
static Decisions *Dep;
static Atom *Atoms;
typedef struct{ /* List of Gpp indices forming a loop. */
  Wallet w;
  Ushort e[1];
} LoopList;
static LoopList *Lsp;
typedef struct{ /* Table for partitioning by rank. */
  Wallet w;
  struct{
    Ushort Lo; /* Where partition goes */
    Ushort Hi; /* Where partition goes */
    Ushort Tot; /* How many words go in this rank? */
  } e[1];
} RankTab;
static RankTab *Rp;
typedef struct{
  Wallet w;
  struct{
    Ushort LL;
    Ushort RR;
  } e[1];
} Essentials;
static Essentials *Esp;
#define Available 1000
static Ushort Taken[Available];
typedef struct{
  Wallet w;
  struct{
    Bool F;
    Bool D;
    Bool R;
    Ushort A;
  }e[1];
} FlatDirect;
static FlatDirect *Fdp;
static void PrintTaken(void);
static void PrintStates(void);
static void PrintSection(Ushort f);
static void PrintPartitions(void);
static void PrintRanks(void);
static void PrintDecisions(void);
static Ushort RqdWidth(Ushort n);
static void ArrayShifts(void);
#define TuneHigh 20
static Bool Map(Ushort t,Ushort j);
static void Confirm(void);
enum AlsoTypes {PositionS,PositionT,GapSize};
static void Also(Ushort t,Ushort x,short m);
static Bool Consider(Ushort m,Ushort t,Ushort x);
static Bool RangeCut(void);
static Ulong Merit(void);
static void Undecided(Ushort d);
static void PrintDec(void);
static void Rechain(void);
static Ushort Wrap(long v);
static short FindGap(Ushort l,Ushort r);
static void MakeSections(void);
static void ShowState(Ushort j);
static void ShowRefer(Ushort j, Ushort k, Ushort t);
void Pack(){
/*------------------------------------------------------------------------------
A1. Initialize, and read in the problem to be solved.
õ-----------------------------------------------------------------------------*/
 {DoVars;
  int cc;
  FILE * In;
/* A bit of initializing. */
  DirectAim=No;if(strchr(Switches,'D')) DirectAim=Yes;/* Option as Boolean. */
  UseArray=No;if(strchr(Switches,'U')) UseArray=Yes;/* Option as Boolean. */
  WalletInit(Esp); /* Not needed until much later. */
  WalletInit(Dep);
  WalletInit(Gpp);
  Gpp->w.Clear=1;
  Gpp->w.Needs=1;WalletCheck(Gpp);/* Spare one at 0 for shuffling. */
  WalletInit(Gmp);
  /* Low end of the zero'th section is 1 on the Gpp wallet. */
  Gmp->w.Clear=Yes;
  /* There is an extra at end of Gmp-> so we can use its Lo. */
  Gmp->w.Needs=1;WalletCheck(Gmp);
  Wm[0].Lo=1;
  In=fopen(InArg,"r");
  if(In==NULL) { printf(Msg[5],InArg);longjmp(ErrSig,1);}
  while((cc=getc(In))!= EOF) if(cc=='') goto OK;
BadIn:;
  printf(Msg[4]);  longjmp(ErrSig,1);
OK:;
  fscanf(In,"%hd %hd %hd %hd",&AtomsCount,&PairsCount,&StatesCount,&LowKey);
  if(!StatesCount) goto BadIn;
  WalletInit(Pap);
  Pap->w.Needs=1+PairsCount;/* Reserve e[0] as shuttling space. */
  WalletCheck(Pap);
  for(k=1;k<=PairsCount;k++){
    fscanf(In,"%hd %hd",&Wp[k].T,&Wp[k].G);
  }
  WalletInit(Stp);
  Stp->w.Needs=StatesCount+5;/* Don't expect to use many spares. */
  if(StatesCount+10>AtomBreak) Failure;
  Stp->w.Exact=Yes;Stp->w.Clear=Yes;WalletCheck(Stp);Stp->w.Exact=No;
  DoShiftj;
    fscanf(In,"%hd %hd %hd %hd %hd %hd %hd %hd %hd %hd",&Ws[j].Error,
    &Ws[j].ExitNum,&Ws[j].Prune,&Ws[j].StackPhysical,
    &Ws[j].KeysOffset,&Ws[j].HasCat,&Ws[j].ShLo,&Ws[j].ShZi,
    &Ws[j].ReLo,&Ws[j].ReZi);
    if(Ws[j].ShLo==Ws[j].ShZi) Ws[j].NoShift=Yes;
    if(Ws[j].ReLo==Ws[j].ReZi) Ws[j].NoRed=Yes;
#if 0
/* March 97, making prune fit algorithm where things are stacked before
shift/reduce decision made. */
/* Actually already did allow? */
    Ws[j].Prune=Ws[j].Prune+Ws[j].StackPhysical;
#endif
    if(Ws[j].Prune>PruneMax) PruneMax=Ws[j].Prune;
    if(Ws[j].StackPhysical>StackMax) StackMax=Ws[j].StackPhysical;
    /* Avoiding zero suits unsigned compares. */
    /* Previous phase made them zero origin, we read them into up one. */
    Ws[j].ShLo++;Ws[j].ShZi++;Ws[j].ReLo++;Ws[j].ReZi++;
  EndShifts;
  fscanf(In,"%hd",&k);
  if(k!=PairsCount) goto BadIn;
  printf("\nPruneMax %d, StackMax %d",PruneMax,StackMax);
/* Also take space for the atoms (token groups) now. */
/* Spare for possible later invented atom. */
  if((Atoms=(Atom*)calloc(AtomsCount+1,sizeof(Atom)))==NULL){
    printf(Msg[6]);
    longjmp(ErrSig,1);
  }
/* Make the space for a full shift array. */
/* Any new states made wont be shift states. */
/* Zeros mean "can't accept this atom in this state". Non-Zero is Target. */
  DoShiftj;
    if((Ws[j].Shift=calloc(AtomsCount+1,sizeof(Ushort)))==NULL){
      printf(Msg[6]);
      longjmp(ErrSig,1);
    }
  EndShifts;
  for(j=0;j<StatesCount;j++){
    Ws[j].Difficulty=1;
    Ws[j].HasExit=(Ws[j].ExitNum>0);
    Ws[j].ReLoOrig=Ws[j].ReLo;
    Ws[j].ReZiOrig=Ws[j].ReZi;
  }
 }
  printf(Msg[7]);
/*------------------------------------------------------------------------------
A2. Make the Boolean matrix for shift acceptance.
õ-----------------------------------------------------------------------------*/
 {DoVars;
  char * AtomSetp;
  Ushort j1,j2,t,v,g;
  Ushort Atoma, Atomb;
  char Strip[32];
  AtomSetp=NULL;
/* Boolean matrix: Zeros mean "can't accept this atom in this state."
 Non-Zero is True. */
/* We want a bit matrix in the physical but use byte-per-bit now. */
  DoShiftj;
    ShiftCt++;
    /* Establish the Boolean strip as zeros. */
    if(!AtomSetp){
      if((AtomSetp=calloc(AtomsCount,1))==NULL){
        printf(Msg[6]);longjmp(ErrSig,1);
      }
    }
    /* Fill AtomSetp from shift switch. */
    t=0;v=USHRT_MAX;
    DoSwitchk;
      if(Wp[k].T<LowKey){
        t++;v=Wp[k].T;g=Wp[k].G;
        *(AtomSetp+Wp[k].T)=Yes;
      }
    EndSwitch;
    if(t<=1){
      /* It only switches on one or none non-key, so at most a test of one
      value is needed. */
#if 0
      printf("\nState %d accept by direct test of token %d.",j,v);
#endif
      Ws[j].Direct=Yes;
      /* Have to pack the atom values in 5 bits somehow. */
      if(v==USHRT_MAX) v=31;
      else if(v==31) Failure;
      if(v!=31) (Atoms+v)->DirectSubj=Yes;
      Ws[j].AcceptValue=v;
      Ws[j].AcceptGoto=g;
      /* No more tests needed in this state, for Accept or Aiming. */
      /* Sadly not true - aim of keywords hasn't been tested. */
      free(AtomSetp);AtomSetp=NULL;
      continue;
    }
    /* Have we had this strip before? */
    DoBelowq;
      if(Ws[q].Direct) continue;
      if(!AtomSetp) Failure;
      if(memcmp(AtomSetp,Ws[q].AcceptStrip,AtomsCount)==0){
        memset(AtomSetp,'\0',AtomsCount);/* Gets reused. */
        Ws[j].AcceptStrip=Ws[q].AcceptStrip;
        Ws[j].StateAccept=Ws[q].StateAccept;
        goto SameStrip;
      }
    EndShifts;
    /* None the same yet. */
    Ws[j].AcceptStrip=AtomSetp;/* Take it permanently. */
    Ws[j].StateAccept=StateAcceptCt;
    AtomSetp=NULL;
    StateAcceptCt++;
SameStrip:;
  EndShifts;
  printf("\nStateAcceptCt %d from %d shift states from %d states",
    StateAcceptCt,ShiftCt,StatesCount);
#if 0
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    if((Atoms+Atoma)->DirectSubj) printf("\nDirectSubj %d",Atoma);
  }
#endif
/* Now the same sort of thing for "columns". */
  for(Atoma=0;Atoma<LowKey;Atoma++){
    for(Atomb=0;Atomb<Atoma;Atomb++){
    /* Does Atoma behave like Atomb in all strips? */
      DoShiftj;
        if(Ws[j].Direct) continue;
        AtomSetp=Ws[j].AcceptStrip;
        if(AtomSetp[Atoma]!=AtomSetp[Atomb]) goto ColDiff;
      EndShifts;
      (Atoms+Atoma)->TokenAccept=(Atoms+Atomb)->TokenAccept;
      goto ColSam; /* To next Atoma */
ColDiff:;
    } /* Atomb */
    /* None of those were the same as this. */
    (Atoms+Atoma)->TokenAccept=TokenAcceptCt++;
ColSam:;
  } /* Atoma */
  printf("\nTokenAcceptCt %d from %d non-purekey from %d token groups.",
    TokenAcceptCt,LowKey,AtomsCount);
/* Put out the Assembler code for the switch. */
  NewLine();
  ShowS(";Generated matrix for accept-by-this-state, state*token. ");
  ShowD(StateAcceptCt);
  ShowC('*');
  ShowD(TokenAcceptCt);
  NewLine();
  if(StateAcceptCt>32) Failure;
  ShowS("AcceptBits dword 0 dup(?)");
  j2=0;
  /* Move j2 thru numbers that go with atoms. */
  /* Move j1 thru numbers that go with states. */
  for(t=0;t<32-StateAcceptCt;t++) Strip[t]='0';
  for(Atoma=0;Atoma<LowKey;Atoma++){
    if(Atoms[Atoma].TokenAccept!=j2) continue;
      j1=0;
      NewLine();
      ShowS(" dword ");
      DoShiftj;
        if(Ws[j].Direct) continue;
        if(Ws[j].StateAccept==j1){
          AtomSetp=Ws[j].AcceptStrip;
          Strip[31-j1]='0'+AtomSetp[Atoma];
          j1++;
        }
      EndShifts;
      for(t=0;t<32;t++) ShowC(Strip[t]);
      ShowS("y;  ");
      ShowD(j2);
    j2++;
  } /* Atoma */
  NewLine();
  ShowS(";Equates for which token groups use which row.");
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    NewLine();
    if(Atoma<LowKey){
      ShowS("$Grp");ShowD(Atoma);ShowS("ndxb equ ");
      /* Add one so that zero can be used to mean Bool-not-used */
      ShowD((Atoms+Atoma)->TokenAccept+1);
    }
    else{
      ShowS("$Grp");ShowD(Atoma);ShowS("ndxb equ 0");
    }
  }
  NewLine();
 } /* locals */
/*------------------------------------------------------------------------------
Acceptance is tested either by state showing only acceptable (18 states,18
tokengroup values), or by bit array (state holds 0-27, tokengroup selects
from 22 words).
õ-----------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------
A3. Post-acceptance token equivalence.
After the acceptance test is done, two tokens can be effectively the
same even when one is in the trigger list and the other isn't. If they are
both in the list they differ if their Gs differ.
To merge them doesn't necessarily help - we are not trying
to cut the width of the AtomData.  It probably will help if it leads
to a shorter switch list.
Although they could turn out to be non-arith and it wouldn't help.
Anyway can't harm.
õ-----------------------------------------------------------------------------*/
 {DoVars;
  Ushort k1,t,ta,tb;Bool ShownFlag;
  Ushort Atoma, Atomb;
  if(UseArray) goto NoAliasTo;
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    for(Atomb=Atoma+1;Atomb<AtomsCount;Atomb++){
      DoShiftj;
        DoSwitchk;
          if(Wp[k].T!=Atoma && Wp[k].T!=Atomb) continue;/* Speedup?*/
          for(k1=k+1;k1<Ws[j].ShZi;k1++){
            if(Wp[k].T==Atoma && Wp[k1].T==Atomb
            || Wp[k].T==Atomb && Wp[k1].T==Atoma) {
              /* Finally found Atoma and Atomb in the same switch. */
              /* It won't happen twice in one switch. */
              if(Wp[k].G==Wp[k1].G) goto Nextj;
              else goto Nextb;
            }
          }/* k1 */
        EndSwitch;
Nextj:;
      EndShifts;
      /* In the places where both are acceptable, Atoma & Atomb do the
      same thing. */
      ShownFlag=No;
      DoShiftj;
        DoSwitchk;
          if(Wp[k].T!=Atoma) continue;
          for(k1=k+1;k1<Ws[j].ShZi;k1++){
            if(Wp[k1].T!=Atomb) continue;
            /* Yes, found Atoma and Atomb in the same switch. */
            if(Wp[k].G!=Wp[k1].G) Failure;
            if(!ShownFlag){
              printf("\nMerging tokens %d %d helps state %d", Atoma,Atomb,j);
              ShownFlag=Yes;
            }
            ta=Wp[k].T;
            if((Atoms+ta)->Alias) ta=(Atoms+ta)->AliasTo;
            tb=Wp[k1].T;
            if((Atoms+tb)->Alias) tb=(Atoms+tb)->AliasTo;
            if(ta!=tb){
              (Atoms+ta)->Alias=Yes;
              (Atoms+ta)->AliasTo=tb;
            }
            Wp[k1]=Wp[Ws[j].ShZi-1];
            Ws[j].ShZi--;
            goto Nextjx;
          }/* k1 */
        EndSwitch;
Nextjx:;
      EndShifts;
Nextb:;
    } /* Atomb */
  } /* Atoma */
  /* Remove aliases from lists. (Already done where shortening.)  */
  DoShiftj;
    DoSwitchk;
      t=Wp[k].T;
      if((Atoms+t)->Alias){
        Wp[k].T=(Atoms+t)->AliasTo;
      }
    EndSwitch;
  EndShifts;
NoAliasTo:;
 } /* locals */
/* Aliased atoms are no longer refered to by the states. */

/*------------------------------------------------------------------------------
A4. Put the switches in the form with most-used-target last. Detect UseArray.
Ideally we would use simple arithmetic on the data from state and token to
deduce target state.  It is possible to deduce some cases where this cannot
work. For those we use an array lookup of the target.
We can deal with some awkward cases either by special casing or by making
more things UseArray.  The special casing makes extra (error) states.
õ-----------------------------------------------------------------------------*/
ReArith:
 {DoVars;
  Ushort t,j1,k1,g,w,Usually,First,Last,LastG;
  Bool Flat=Yes;/* Experiment on what flattening is worth. */
  if(UseArray) Flat=No;
  Gpp->w.Needs=1;
  Usually=USHRT_MAX;
  DoShiftj;
    if(Ws[j].Subset) continue;
    for(j1=0;j1<StatesCount;j1++) Ws[j1].Work=0;
    DoSwitchk;
      Ws[Wp[k].G].Work++;
    EndSwitch;
    DoSwitchk;
      Wp[0]=Wp[k];/* Spare place */
      w=Ws[Wp[k].G].Work;
      /* Move up higher freq ones. */
      for(k1=k-1;k1>=Ws[j].ShLo;k1--){
        if(w > Ws[Wp[k1].G].Work) break;
        else if(w < Ws[Wp[k1].G].Work){
          Wp[k1+1]=Wp[k1];
        }
        else{ /* Second level sort on trigger. */
          if(Wp[0].T>=Wp[k1].T) break;
          Wp[k1+1]=Wp[k1];
        }
      }/* k1 */
      Wp[k1+1]=Wp[0];
    EndSwitch;
#if 0
/*  It shouldn't hurt much not to exploit DirectAim from states. */
    if(Ws[j].ShZi-Ws[j].ShLo<2) {
    /* There is always just one in the list so arith can cope. */
      printf("\nState %d only one target left. %d",j,Wp[Ws[j].ShLo].G);
      Ws[j].DirectAim=Yes;
      Ws[j].AimGoto=Wp[Ws[j].ShLo].G;
      continue;
    }
#endif
    /* Interesting cases are ones where the Gs are not all unique. */
    /* Does it happen that targets all the same? */
    First=Ws[j].ShLo;
    Last=Ws[j].ShZi-1;/* Last indexes last */
    if(Last!=First && Wp[Last].G==Wp[First].G){
      printf("\nMultiple to %d from %d", Wp[First].G,j);
      /* Apparently not, so note if it ever happens. */
      /* Doesn't matter in some experiments. */
      if(!UseArray) Failure;
    }
    if(Flat && Last>First && Wp[Last].G == Wp[Last-1].G){
      Ws[j].FlatSym=Yes;
      t=1;
      if(Usually==USHRT_MAX)
        Usually=Wp[Last].T;
      /* It turns out here is just one set of three things to flatten. */
      if(Usually!=Wp[Last].T) {
        /* And two sets of 2 which have error destinations. */
        LastG=Wp[Last].G;
        if(!Ws[LastG].Error||!Ws[LastG].NoShift||!Ws[LastG].NoRed){
          /* And sadly some other found late when Direct mechanism was
          sorted out. */
          /* Hence spaghetti fix. */
          t=Wp[Last].T;
          (Atoms+t)->UseArray=Yes;
          printf("\nState %d forcing %d to UseArray.",j,t);
          goto DropArith;
        }
        /* An error-only state can be duplicated. */
        Wp[Last].G=StatesCount;
        if(Stp->w.Needs<StatesCount+1){
          Stp->w.Needs=StatesCount+1;WalletCheck(Stp);
        }
        Ws[StatesCount++]=Ws[LastG];
        printf("\nDuplicated Error state %d for %d targets.",LastG,j);
      }
      else{
        /* Usual case of these three T's */
        /* Maybe only 2 present */
        if(Ws[j].ShZi-Ws[j].ShLo>2 &&
           Wp[Last-2].G == Wp[Last-1].G) t=2;
        /* While they have the same G, shorten. */
        if(!FlatOnce){
          /* Take the spare Atom once. */
          FlatOnce=Yes;
          printf("\nFlatten %d %d %d",Wp[Last-2].T, Wp[Last-1].T, Wp[Last].T);
          AtomsCount++;/* New one represents the three taken merged. */
        }
        Ws[j].ShZi-=t;
        Wp[Ws[j].ShZi-1].T=AtomsCount-1;
      }
    j=j-1; /* Gets list resorted. */
    } /* Non-unique */
  EndShifts;
 } /* locals */

/*------------------------------------------------------------------------------
A5. Store equations about shifts.  Deduce which can be arithmetic.
The aim is to do state transition by the rule that the new state address
is the sum of a constant from the current state and a constant from the
current token.  (For reductions,
the reference state plus a constant from the current state.)
This cannot always be done.  If state A has T1 leading to S1 and T2 leading
to S2 then state A's gap (difference) of T1 & T2 has to be the same as the gap
for S1 & S2. (And the same for other pairs of tokens in A's switch list.)
If the same T1,T2, and S1 appear elsewhere with an S2 not the same then
arithmetic won't hack it. (Two states can't have the same address.)

A greedy algorithm is used to make some tokens (T1 or T2 above) non-arith.
The token involved with most problems is first made non-arith, then the
process is repeated.
õ-----------------------------------------------------------------------------*/
 {DoVars;
  Ushort k1,d,f,g,n,ta,tb,ga,gb,wa,wb;
  Ushort ToksWhere,StatesWhere;
  Ushort Atoma, Atomb;
  Ushort j1,j2,n1,n2;
  GapID=1;
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    (Atoms+Atoma)->Work=0;
    (Atoms+Atoma)->ChainL=USHRT_MAX;
    (Atoms+Atoma)->ChainR=USHRT_MAX;
  }
  for(j=0;j<StatesCount;j++){
    Ws[j].ChainL=USHRT_MAX;
    Ws[j].ChainR=USHRT_MAX;
  }
  DoShiftj;
    if(Ws[j].Subset) continue;
    DoSwitchk;
      ta=Wp[k].T;ga=Wp[k].G;
      if((Atoms+ta)->UseArray) continue;
      /* Consider pairs of pairs. */
      for(k1=k+1;k1<Ws[j].ShZi;k1++){
        /* T's to be separated by same distance as the targets. */
        tb=Wp[k1].T;
        if((Atoms+tb)->UseArray) continue;
        /* Currently relying on the list sort. */
        if(LastPass && ta>tb) Failure;
        gb=Wp[k1].G;
        /* Check if either pair is already there. */
        n=0;
        ToksWhere=StatesWhere=0;
        for(c=(Atoms+ta)->ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
          if(Wg[c].L!=ta+AtomBreak) Failure;
          if(Wg[c].R==tb+AtomBreak){
            n=Wg[c].N;
            ToksWhere=c;break;
          }
        }
        for(c=Ws[ga].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
          if(Wg[c].L!=ga) Failure;
          if(Wg[c].R==gb){
            n=Wg[c].N;
            StatesWhere=c;break;
          }
        }
        /* Could there be an awkward case where the gap is known, but with
        left & right inverted? */
        if(LastPass){
          for(c=(Atoms+tb)->ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
            if(Wg[c].L!=tb+AtomBreak) Failure;
            if(Wg[c].R==ta+AtomBreak) Failure;
          }
          for(c=Ws[gb].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
            if(Wg[c].L!=gb) Failure;
            if(Wg[c].R==ga) Failure;
          }
        }
        if(ToksWhere && StatesWhere){
          /* Reconcile the GapIds if necessary. */
          n=Wg[StatesWhere].N;
          if(Wg[ToksWhere].N!=n){
            /* Replace all references to one of them. */
            for(d=1;d<Gpp->w.Needs;d++){
              if(Wg[d].N==Wg[ToksWhere].N) Wg[d].N=n;
            }
          }
          /* Both there, with same GapID. */
        }
        /* If neither, a new GapID is needed. */
        if(!n) n=++GapID;
        else{
          /* If either goto appears with a different partner and the same
          GapID then its failure, since the addresses of two states cannot
          be the same. */
          /* Count rather than restart, because we want to select which
          atoms to knock out. */
          for(c=Ws[ga].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
            if(Wg[c].L!=ga) Failure;
            if(Wg[c].N!=n) continue;
            if(Wg[c].R==gb) continue;
            (Atoms+ta)->Work++;
            (Atoms+tb)->Work++;
          }
          for(c=Ws[gb].ChainR;c!=USHRT_MAX;c=Wg[c].ChainR){
            if(Wg[c].N!=n) continue;
            if(Wg[c].L==ga) continue;
            (Atoms+ta)->Work++;
            (Atoms+tb)->Work++;
          }
        } /* Not new */
        /* Add to the gaps recorded. */
        if(!ToksWhere){
          c=Gpp->w.Needs++;WalletCheck(Gpp);
          Wg[c].L=ta+AtomBreak;
          Wg[c].R=tb+AtomBreak;
          Wg[c].N=n;
          Wg[c].ChainL=(Atoms+ta)->ChainL;(Atoms+ta)->ChainL=c;
          Wg[c].ChainR=(Atoms+tb)->ChainR;(Atoms+tb)->ChainR=c;
          Wg[c].Sample=j;
        }
        if(!StatesWhere){
          c=Gpp->w.Needs++;WalletCheck(Gpp);
          Wg[c].L=ga;
          Wg[c].R=gb;
          Wg[c].N=n;
          Wg[c].ChainL=Ws[ga].ChainL;Ws[ga].ChainL=c;
          Wg[c].ChainR=Ws[gb].ChainR;Ws[gb].ChainR=c;
          Wg[c].Sample=j;
        }
      }/* k1 */
    EndSwitch;
  EndShifts;
  /* Throw out the most troublesome atom. */
  d=0;
  if(!UseArray){
    for(Atoma=0;Atoma<AtomsCount;Atoma++){
      if((Atoms+Atoma)->Work>d){
        Atomb=Atoma;
        d=(Atoms+Atoma)->Work;
      }
    }
    if(d){
      (Atoms+Atomb)->UseArray=Yes;
      UseArrayCt++;
    }
  }
  else{ /* UseArray */
    /* I think the test stops looping here. */
    if(!Atoms->UseArray) d=1;
    /* Setup to drop all token switching from lists. */
    for(Atoma=0;Atoma<AtomsCount;Atoma++){
      (Atoms+Atoma)->UseArray=Yes;
    }
  }
  if(d){
DropArith:;
    /* Drop relevant pairs out of the list, note them for the array method. */
    DoShiftj;
      if(Ws[j].Subset) continue;
      k1=Ws[j].ShLo;
      DoSwitchk;
        if(!(Atoms+Wp[k].T)->UseArray){
          Wp[k1++]=Wp[k];
        }
        else{
          /* Add 1 to G to ensure non-zero */
          *(Ws[j].Shift+Wp[k].T)=1+Wp[k].G;
        }
      EndSwitch;
      Ws[j].ShZi=k1;
      /* Just drop the cases where the switch has become null. */
      /* It is a subset of anything. */
      if(Ws[j].ShZi-Ws[j].ShLo<1) Ws[j].Subset=Yes;
    EndShifts;
    goto ReArith;
  }
  printf("\nWg[1] %d %d %d",Wg[1].L,Wg[1].R,Wg[1].N);
  /* If we eliminate subsets before a final pass it will minimise what appears
  in the list of gaps. */
/*------------------------------------------------------------------------------
A6. Eliminate subsets in shifting.
 That doesn't alter the hard part but gives us less to handle.
 It will be enough to be a subset on the arith tokens.
 Subsetting on the non-arith will be covered in compacting the array.
õ-----------------------------------------------------------------------------*/
  DoShiftj;
    if(Ws[j].Subset) continue;
    n1=Ws[j].ShZi-Ws[j].ShLo;
    DoAboveq;
      if(Ws[q].Subset) continue;
      n2=Ws[q].ShZi-Ws[q].ShLo;
      /* Is one a subset of the other? */
      if(n1>=n2){
        j1=j;j2=q;
      }
      else{
        j1=q;j2=j;
      }
      /* Is 2 a subset of 1? */
      n1=Ws[j1].ShLo-1;
      for(n2=Ws[j2].ShLo;n2<Ws[j2].ShZi;n2++){
Maybe:; n1++;if(n1==Ws[j1].ShZi) goto NoJoy;
        if(Wp[n1].T!=Wp[n2].T
        || Wp[n1].G!=Wp[n2].G)
          goto Maybe;
      }
      Ws[j2].Subset=Yes;Ws[j2].SubsetOf=j1;
NoJoy:;
    EndShifts;
  EndShifts;
  if(!LastPass){
    LastPass=Yes;
    goto ReArith;
  }
  printf("\n%d UseArrays",UseArrayCt);
 }
/*------------------------------------------------------------------------------
A7. Overlay amongst the full shift array.
We know now what to ignore because tested other ways.
In theory there could be some interaction of arithmetic between shift and
reduction problems which lead to wanting to move more into the Array shift
mechanism.  However, for tidyness in this programming, assume not and get
the non-arithmetic work complete by deducing the compact array of shift
gotos.
õ-----------------------------------------------------------------------------*/
 {DoVars;
  Ushort w0,wk,k1;
  Ushort Atoma,Atomb;
  ArrayShifts();
  /* Produce the equates for which atomset uses which column. */
  printf("\n%d %d",LowKey,AtomsCount);
  ShowS(";Equates for which token groups use which column of sparse.");
  NewLine();
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    ShowS("$Grp");ShowD(Atoma);ShowS("ndx equ ");
    Atomb=Atoma;
    while((Atoms+Atomb)->ArrayGone) Atomb=(Atoms+Atomb)->ArraySame;
    ShowD((Atoms+Atomb)->ArraySame); /* Is Array index */
    NewLine();
  }
  /* How correlated are the direct and flatten cases? */
  /* Interest is in FlatSym, Direct, AcceptValue and StateAccept. */
  /* Also took a look at Reference. */
  WalletInit(Fdp);
  Fdp->w.Needs=1;WalletCheck(Fdp);
  DoShiftj;
    Wf[0].F=Ws[j].FlatSym;
    Wf[0].D=Ws[j].Direct;
    Wf[0].A=(Ws[j].Direct ? Ws[j].AcceptValue : Ws[j].StateAccept);
#if 0
    Wf[0].R=Ws[j].StackPhysical > 0;
#endif
    Wf[0].R=0;/* Decided this separate. */
    for(k=1;k<Fdp->w.Needs;k++){
      if(Wf[k].F==Wf[0].F
      && Wf[k].D==Wf[0].D
      && Wf[k].R==Wf[0].R
      && Wf[k].A==Wf[0].A) goto KnownFdp;
    }
    k=Fdp->w.Needs++;WalletCheck(Fdp);
    Wf[k]=Wf[0];
KnownFdp:;
  EndShifts;
  for(k=1;k<Fdp->w.Needs;k++){
    Wf[0]=Wf[k];/* Spare place */
    /* Compute something to sort on. */
    w0=4000*Wf[0].R+2000*Wf[0].D+1000*Wf[0].F+Wf[0].A;
    /* Move up higher rated ones. */
    for(k1=k-1;k1>=1;k1--){
      wk=4000*Wf[k1].R+2000*Wf[k1].D+1000*Wf[k1].F+Wf[k1].A;
      if(wk < w0) break;
      Wf[k1+1]=Wf[k1];
    }/* k1 */
    Wf[k1+1]=Wf[0];
  }
  for(k=1;k<Fdp->w.Needs;k++){
    printf("\n%d ",k);
    if(Wf[k].D) printf("Direct ");
    else        printf("Array  ");
    printf("%d ",Wf[k].A);
    if(Wf[k].F) printf("FlatSym ");
    if(Wf[k].R) printf("Reference ");
  }
 } /* locals */
 printf("\n***** Part A completed.");
/*------------------------------------------------------------------------------
B1. Eliminate subsets in reductions.  Also partition the switch.
The partitioning is because we want to use arithmetic.  Only states are
involved and they can't have equal addresses so something has to be done
about a switch with equal targets, unless the whole switch has equal targets.
õ-----------------------------------------------------------------------------*/
 {DoVars;
  Ushort j1,j2,n1,n2,r;
  Ushort Common,d;
  DoRedj;
    if(Ws[j].DirectR) continue;
    n1=Ws[j].ReZi-Ws[j].ReLo;
    if(n1==1){
      Ws[j].DirectR=Yes;
      continue;
    }
    DoRedq;
      if(Ws[q].DirectR) continue;
      if((n2=Ws[q].ReZi-Ws[q].ReLo)==1) continue;
      /* Is one a subset of the other? */
      if(n1>=n2){
        j1=j;j2=q;
      }
      else{
        j1=q;j2=j;
      }
      /* Is 2 a subset of 1? */
      n1=Ws[j1].ReLo-1;
      for(n2=Ws[j2].ReLo;n2<Ws[j2].ReZi;n2++){
MaybeR:; n1++;if(n1==Ws[j1].ReZi) goto NoJoyR;
        if(Wp[n1].T!=Wp[n2].T
        || Pap->e[n1].G!=Wp[n2].G)
          goto MaybeR;
      }
      Ws[j2].SubsetR=Yes;Ws[j2].DirectR=Yes;Ws[j2].SubsetOfR=j1;
#if 0
      /* Do subsets always have the same prune count? */
      if(Ws[j2].Prune!=Ws[j1].Prune)
        printf("\n%d %d Subset Prune differs",j2,j1);
#endif
      if(j2==j) goto Nextjy;
NoJoyR:;
    EndReds;
Nextjy:;
  EndReds;
/* But without info on whether targets all the same. */
  DoRedj;
    if(Ws[j].DirectR) continue;
    Ws[j].VecReZi=Ws[j].ReLo;/* Below here ranked together. */
PostSlice:
    d=0;/* Count number of different targets. */
    Common=USHRT_MAX;
    DoRedSwitk;
      if(Wp[k].G!=Common){
        d++;Common=Wp[k].G;
      }
    EndSwitch;
    if(d==1){
      Ws[j].DirectR=Yes;
      continue;
    }
    if(d==Ws[j].ReZi-Ws[j].ReLo){ /* All different */
      Ws[j].VecReZi=Ws[j].ReZi;
      continue;
    }
    if(d==2 && !Ws[j].Filter){
      /* Worth splitting off one if its a singlet. */
      /* Won't have to worry about its rank, so ReLo can forget it. */
      if(Wp[Ws[j].ReLo].G!=Wp[Ws[j].ReLo+1].G){
        Ws[j].ReLo++;
        Ws[j].Filter=Yes;
        goto PostSlice;
      }
    }
    if(d==Ws[j].ReZi-Ws[j].ReLo-1 && !Ws[j].FilterHi){
      Ushort my;
      /* Worth splitting off one if it would make the rest unique. */
#if 0
      if(j==128){
        printf("\nS128 FHi %d %d %d",Ws[j].ReLo,Ws[j].ReZi,d);
        for(my=Ws[j].ReLo;my<Ws[j].ReZi;my++){
          printf("\n   %d %d", Wp[my].G, Wp[my].T);
        }
      }
#endif
      Ws[j].ReZi--;
      Ws[j].FilterHi=Yes;
      goto PostSlice;
    }
    /* Continue noting things off the bottom while singlets. */
    /* All this set can be ranked the same and split by arithmetic. */
    /* One of the equals could be vectored but that is not a benefit. */
    r=Ws[j].ReLo;
    while(Wp[r].G!=Wp[r+1].G){
      r++;
      Ws[j].VecReZi=r;
    }
  EndReds;
 }
/*------------------------------------------------------------------------------
B2. Equations for reduction.
The Gpp wallet just lists all the relations implied by reduction lists,
adding to the relations already there from the shifts.
õ-----------------------------------------------------------------------------*/
 {DoVars;
  Ushort k1,a,e,x,y,d,f,g,t,ta,tb,ga,gb,n,h,wa,wb,l,r,Atoma,AsWas;
  Ushort ld,rd;
  Ushort OmitL,OmitR;
  short sl,sr;
  AsWas=Gpp->w.Needs;
  OmitL=OmitR=0;
RedStart:;
  DoRedj;
    if(Ws[j].DirectR) continue;
    ++GapID; /* A number in the State determines this gap. */
    DoRedSwitk;
      /* Only the vectoring part is relevant for deductions. */
      if(k==Ws[j].VecReZi) break;
      /* It is fortunate that the only case where T and G are the same
      comes under ranking and not under vectoring. */
      ga=Wp[k].T;gb=Wp[k].G;
      if(ga==gb) Failure;
      /* Consider T G pairs (for rule Sg=Sj+St+const). */
      for(c=Ws[ga].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
        if(Wg[c].L!=ga) Failure;
        if(Wg[c].R==gb){
          printf("\nRefound %d:%d.%d",j,ga,gb);
          /* Doesn't seem to happen. */
          /* Did April 97 */
          /* Doesn't seem unreasonable. If reducing after 'VALUE exp' and
          stack has 'SIGNAL...' then reduce to end of signal statement.
          Similarly if reducing after taken_constant.  Problem is it joins
          together the two list (hence same delta) and the full list may
          have conflicts, eg {a,b} and also {a,c} */
          /* That happens here because when null_clause is stacked the
          reduction may be to ADDRESS VALUE exp or to ADDRESS taken_const
          which are not equivalent states. */
          /* The process with Special may sort.*/
          /* If we are losing something previously in Omit it will
          probably come again on a later cycle. */
          OmitL=ga;OmitR=gb;
        }
      }
      /* Is there an awkward case where the gap is known, but with
      left & right inverted? */
      for(c=Ws[gb].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
        if(Wg[c].L!=gb) Failure;
        if(Wg[c].R==ga){
          printf("\n%d %d %d",j,ga,gb);
          PrintStates();
          Failure;
        }
      }
      /* If we are recycling after a failure, this may be one we want
      to handle as non-arithmetic. */
      if(ga==OmitL && gb==OmitR){
        /* It doesn't happen twice to the same State. */
        if(Ws[j].IsSpecial) Failure;
        Ws[j].IsSpecial=Yes;
        /* Take it out of the switch list by swop with ReLo. */
        k1=Ws[j].ReLo;
        Wp[0]=Wp[k];
        Wp[k]=Wp[k1];
        Wp[k1]=Wp[0];
        Ws[j].SpecialK=k1;
        /* Lose old first. */
        Ws[j].ReLo++;
        /* Assert - change of order doesn't matter. */
        printf("\n%d now special {%d:%d}",j,ga,gb);
        continue;
      }
      c=Gpp->w.Needs++;WalletCheck(Gpp);
      Wg[c].L=ga;
      Wg[c].R=gb;
      Wg[c].N=GapID;
      Wg[c].ChainL=Ws[ga].ChainL;Ws[ga].ChainL=c;
      Wg[c].ChainR=Ws[gb].ChainR;Ws[gb].ChainR=c;
    EndSwitch;
  EndReds;
  /* Go through again with the pairs in the list.  (Since ta-ga = ta2-ga2,
  ta-ta2 = ga-ga2, another constant. */
  DoRedj;
    if(Ws[j].DirectR) continue;
    DoRedSwitk;
      /* Only the vectoring part is relevant for deductions. */
      if(k==Ws[j].VecReZi) break;
      ta=Wp[k].T;ga=Wp[k].G;
      /* Consider pairs of pairs. */
      for(k1=k+1;k1<Ws[j].VecReZi;k1++){
        /* T's to be separated by same distance as the targets. */
        tb=Wp[k1].T;
        gb=Wp[k1].G;
        /* Check if either pair is already there. */
        /* Look up in 2nd-bigger mode. */
        if(ta>tb){
          g=ta;ta=tb;tb=g;g=ga;ga=gb;gb=g;
        }
        n=0;
        wa=0;
        for(c=Ws[ta].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
          if(Wg[c].L!=ta) Failure;
          if(Wg[c].R==tb){
            n=Wg[c].N;wa=c;break;
          }
        }
        wb=0;
        for(c=Ws[ga].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
          if(Wg[c].L!=ga) Failure;
          if(Wg[c].R==gb){
            n=Wg[c].N;wb=c;break;
          }
        }
        if(wa && wb){
          /* Reconcile the GapIDs if necessary. */
          n=Wg[wa].N;
          if(!n) Failure;
          if(Wg[wb].N!=n){
            /* Replace all references to one of them. */
            for(d=1;d<Gpp->w.Needs;d++){
              if(Wg[d].N==Wg[wb].N) Wg[d].N=n;
            }
          }
          /* Both there, with same GapID. */
        }
        /* If neither, a new GapID is needed. */
        if(!n) n=++GapID;
        else{
          /* If any goto appears with a different partner and the same
          GapID then its failure, since the addresses of two states cannot
          be the same. */
          /* But I can't check this until the OmitL OmitR are done so I'll
          leave it to fall out of mapping effort. */
        } /* Not new */
        /* Add to the gaps recorded. */
        if(!wa){
          c=Gpp->w.Needs++;WalletCheck(Gpp);
          Wg[c].L=ta;
          Wg[c].R=tb;
          Wg[c].N=n;
          Wg[c].Sample=j;
          Wg[c].ChainL=Ws[ta].ChainL;Ws[ta].ChainL=c;
          Wg[c].ChainR=Ws[tb].ChainR;Ws[tb].ChainR=c;
        }
        if(!wb){
          c=Gpp->w.Needs++;WalletCheck(Gpp);
          Wg[c].L=ga;
          Wg[c].R=gb;
          Wg[c].N=n;
          Wg[c].Sample=j;
          Wg[c].ChainL=Ws[ga].ChainL;Ws[ga].ChainL=c;
          Wg[c].ChainR=Ws[gb].ChainR;Ws[gb].ChainR=c;
        }
      } /* k1 */
    EndSwitch;
  EndReds;
/* There is a problem if one list says {l,r}{a,x} and another {l,a}{r,y}
because that makes x&y equal. */
  for(c=0;c<Gpp->w.Needs;c++){
    l=Wg[c].L;
    if(l>=AtomBreak) continue;
    /* We need to look at all pairs of partners to l. */
    /* Crude to do same l more than once but simplest. */
    for(d=Ws[l].ChainL;d!=USHRT_MAX;d=Wg[d].ChainL){
      for(e=Ws[l].ChainL;e!=USHRT_MAX;e=Wg[e].ChainL){
        if(e>=d) continue;/* Don't need them all twice. */
        r=Wg[d].R;
        a=Wg[e].R;
        /* is there an x? */
        x=y=0;
        for(f=Ws[a].ChainL;f!=USHRT_MAX;f=Wg[f].ChainL){
          if(Wg[d].N==Wg[f].N) x=f; /* Right of */
        }
        if(!x) continue;
        for(f=Ws[r].ChainL;f!=USHRT_MAX;f=Wg[f].ChainL){
          if(Wg[e].N==Wg[f].N) y=f; /* Right of */
        }
        if(!y) continue;
        if(Wg[x].R!=Wg[y].R){
          /* Assert - not worth complex choice of how to break situation. */
          OmitL=l;OmitR=r;
          Gpp->w.Needs=AsWas;
          Rechain();
          goto RedStart;
        }
      } /* e */
    } /* d */
  } /* c */

/*------------------------------------------------------------------------------
B3. Tidy up the record of constraints. Note how many words each individual
    state.
õ-----------------------------------------------------------------------------*/
PostDifficult:
  MakeSections();
/* When we have {a b}{c d}{e f} we have a^b=c^d=e^f and a^c=b^d and a^e=b^f
and c^e=d^f.  This was done above when the {}{}{} were related in a
single switch but they may be related indirectly. */
  for(f=0;f<Gmp->w.Needs-1;f++){
    short tsl,tsr;
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      for(d=c+1;d<Wm[f+1].Lo;d++){
        if(Wg[d].L>=AtomBreak) continue;
        /* l to Wg[d].L should equal r to Wg[d].R */
        ld=Wg[d].L;rd=Wg[d].R;
        sl=FindGap(l,ld);
        sr=FindGap(r,rd);
        if(sl!=SHRT_MAX && sr!=SHRT_MAX){
          if(sl==sr) continue; /* There and equal. */
          printf("\n%d %d %d",l,Wg[d].L,sl /* ,Wm[sl].Sample */);
          printf("\n%d %d %d",r,Wg[d].R,sr/* ,Wm[sr].Sample */);
          /* Could happen but doesn't */
          /* It did. */
          tsl=sl;tsr=sr;
          if(tsl<0) tsl=-tsl-1;
          if(tsr<0) tsr=-tsr-1;
          { Ushort h;
            for(h=0;h<Gpp->w.Needs;h++){
              if(Wg[h].N==tsl || Wg[h].N==tsr)
                printf("\n%d %d %d %d",Wg[h].N,Wg[h].R,Wg[h].L,Wg[h].Sample);
            }
          }
/* The case that happened was one pair, there in both orders.  So we have
to reverse one of them, then give both the same GapId. */
/* Keep the sl one. */
          { Ushort h;
            for(h=0;h<Gpp->w.Needs;h++){
              if(Wg[h].N==tsr){
                t=Wg[h].R;Wg[h].R=Wg[h].L;Wg[h].L=t;
                Wg[h].N=tsl;
              }
            }
          }
          if(Difficults++>50) Failure;
          goto PostDifficult;
        }
        if(sl<0 || sr<0){ /* One pair was there, in the reverse order. */
          if(sl<0) sl=-sl-1;
          else sr=-sr-1;
          t=l;l=ld;ld=t;t=r;r=rd;rd=t;
        }
        n=SHRT_MAX;
        if(sl!=SHRT_MAX) n=sl;
        if(sr!=SHRT_MAX) n=sr;
        if(n==SHRT_MAX) n=++GapID;
        /* Add to the gaps recorded. */
        if(sr!=SHRT_MAX){
          e=Gpp->w.Needs++;WalletCheck(Gpp);
          Wg[e].L=l;
          t=ld;
          Wg[e].R=t;
          Wg[e].N=n;
          Wg[e].ChainL=Ws[l].ChainL;Ws[l].ChainL=e;
          Wg[e].ChainR=Ws[t].ChainR;Ws[t].ChainR=e;
          Wg[e].Sample=Wm[f].Sample;
#if 0
          printf("\nAddedl %d^%d as %d with id %d",l,t,e,n);
#endif
        }
        if(sl!=SHRT_MAX){
          e=Gpp->w.Needs++;WalletCheck(Gpp);
          Wg[e].L=r;
          t=rd;
          Wg[e].R=t;
          Wg[e].N=n;
          Wg[e].ChainL=Ws[r].ChainL;Ws[r].ChainL=e;
          Wg[e].ChainR=Ws[t].ChainR;Ws[t].ChainR=e;
          Wg[e].Sample=Wm[f].Sample;
#if 0
          printf("\nAddedl %d^%d as %d with id %d",r,t,e,n);
#endif
        }
      }
    }
  } /* f */
#if 0
  printf("\nc L R N ");
  for(c=1;c<Gpp->w.Needs;c++){
    printf("\n%d %d %d %d",c,Wg[c].L,Wg[c].R,Wg[c].N);
  }
#endif
  MakeSections();
/* Point from states to sections. */
/* Also set Physical. All the decisions on how particular states are
treated have been made. (Assuming mapping possible. */
/* July 97. Physical does not include the exits, so HasExit should be
added for actual occupancy. */
  for(j=0;j<StatesCount;j++){
    Ushort m;
    n=0;
    if(!Ws[j].NoShift) n++;
    if(Ws[j].Error) n++;
    if(Ws[j].KeysOffset) n++;
    m=n;
    if(Ws[j].FilterHi) n+=2;
    if(Ws[j].IsSpecial) n+=2;
    if(Ws[j].Filter) n+=2;
    if(Ws[j].SubsetR || Ws[j].DirectR) n++;
    else if(!Ws[j].NoRed){
      /* Downwards to bottom limit of non-vectored. */
      for(k=Ws[j].ReZi-2;k>=Ws[j].VecReZi;k--){
        if(Wp[k].G!=Wp[k+1].G) n+=2; /* Will need a > test. */
      }
      /* Test some vectoring but not all vectoring. */
      if(Ws[j].VecReZi!=Ws[j].ReLo && Ws[j].VecReZi!=Ws[j].ReZi)
        n+=2;/* For boundary from vectoring. */
      n++;/* For the ultimate action, vectoring or default. */
    }
    Ws[j].Physical=n;
    Ws[j].PhysicalR=n-m;
  } /* j */
  PrintStates();
  DoRedj;
    if(Ws[j].DirectR) continue;
    if(Ws[j].SubsetR) continue;
    DoRedSwitk;
      if(k>=Ws[j].VecReZi) continue;
      ga=Wp[k].T;
      if(ga>=AtomBreak) continue;
      gb=Wp[k].G;
      /* Find this pair in order to find a gap number. */
      for(c=Ws[ga].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
        for(d=Ws[gb].ChainR;d!=USHRT_MAX;d=Wg[d].ChainR){
          if(c==d){
            Ws[j].Section=Wg[c].N;
            Wm[Wg[c].N].Sample=j;
#if 0
            printf("\n%d state section %d sample.",j,Wg[c].N);
#endif
            goto Nextjz;
          }
        }
      }
      Failure;
    EndSwitch;
Nextjz:;
  EndReds;
 } /* locals */
/*------------------------------------------------------------------------------
B4. Rank the states into different partitions of the state address space.
õ-----------------------------------------------------------------------------*/
  /* Here the switches are looked at to see how the comparison tests on the
  reference states imply the rankings. */
 /* Everything involved in ranking is ranked at least one. */
 /* The Rank fields give the minimum rank; the Ranc say if Rank could be
 increased. Any increase in Rank never gets reversed. */
 /* The Ranc fields work in the opposite direction. */
 {DoVars;
  Ushort k1,*krp,t,t1,g;
  Ushort f,l,r,ll,rr,tt,e;
  Bool Logic,m;
  float u;
  WalletInit(Rp);
  Rp->w.Clear=Yes;
 Remap:
  setjmp(RemapEnv);
 /* It is difficult to run the mapping process backwards, although maybe
 I'll have to do that eventually.  For the moment, we introduce a cycle
 which starts everything again with a different Merit algorithm for
 deciding what to map first. */
 /* The values of Difficulty have changed when we come here again. */
  RankRanc=No;MaxRank=0;
  for(j=0;j<StatesCount;j++){
    Ws[j].RankSettled=No;
    Ws[j].IsDecided=No;
    Ws[j].MapHigh=No;
    Ws[j].MapLow=No;
    Ws[j].Setup=No;
    Ws[j].Final=No;
    Ws[j].Rank=0;
    Ws[j].Work=0;
    Ws[j].Involved=0;
  }
  for(f=0;f<Gmp->w.Needs-1;f++){
    Wm[f].IsDecided=No;
    Wm[f].Positive=No;
    if(Wm[f].Inverted){
      for(e=Wm[f].Lo;e<Wm[f+1].Lo;e++){
        t=Wg[e].L;Wg[e].L=Wg[e].R;Wg[e].R=t;
      }
      Wm[f].Inverted=No;
    }
  }
  for(t=0;t<=Available;t++){
    Taken[t]=0;
  }
  /* Reserve Rank 0 to mean not involved. */
  DoRedj;
    if(Ws[j].DirectR) continue;
    if(Ws[j].ReLo>=Ws[j].ReZi){
      printf("\n%d",j);
      Failure;
    }
    if(Ws[j].VecReZi==Ws[j].ReZi) continue; /* All different. */
    DoRedSwitk;
      Ws[Wp[k].T].Rank=1;
    EndSwitch;
  EndReds;
 ReRank:
  DoRedj;
    if(Ws[j].DirectR) continue;
    if(Ws[j].VecReZi==Ws[j].ReZi) continue; /* All different. */
    DoRedSwitk;
      krp=&Ws[Wp[k].T].Rank;
      g=Wp[k].G;
      for(k1=k-1;k1>=Ws[j].ReLo;k1--){
        /* Should be lower ranked, unless same target. */
        /* All vector part has same rank relative to nonvector. */
        Logic=Yes; /* Need to bump. */
        /* Always OK if later one in list is higher ranked. */
        if(Ws[Wp[k1].T].Rank<*krp) Logic=No;
        /* OK if pair are same targetted. */
        if(Wp[k1].G == g) Logic=No;
        /* OK if both are in the vectoring zone. */
        if(k<Ws[j].VecReZi && k1<Ws[j].VecReZi) Logic=No;
        if(Logic){
          if(++(*krp) > MaxRank) MaxRank=*krp;
          if(*krp < StatesCount) goto ReRank;
            printf("\nCannot Rank. %d %d %d",j,Wp[k].T,Wp[k1].T);
          Failure;
        }
      } /* k1 */
    EndSwitch;
  EndReds;
  /* Here we rank in the other direction, to see what freedom there is
  the ranking. */
  for(j=0;j<StatesCount;j++){
    Ws[j].Ranc=MaxRank;
  }
ReRanc:
  DoRedj;
    if(Ws[j].DirectR) continue;
    if(Ws[j].VecReZi==Ws[j].ReZi) continue; /* All different. */
    DoRedSwitk;
      krp=&Ws[Wp[k].T].Ranc;
      g=Wp[k].G;
      for(k1=k-1;k1>=Ws[j].ReLo;k1--){
        /* Should be lower ranked, unless same target. */
        /* All vector part has same rank relative to nonvector. */
        Logic=Yes; /* Need to relate. */
        /* Always OK if later one in list is higher ranked. */
        if(Ws[Wp[k1].T].Ranc<*krp) Logic=No;
        /* OK if pair are same targetted. */
        if(Wp[k1].G == g) Logic=No;
        /* OK if both are in the vectoring zone. */
        if(k<Ws[j].VecReZi && k1<Ws[j].VecReZi) Logic=No;
        if(Logic){
          /* Lower the earlier one. */
          t=Wp[k1].T;
          if(Ws[t].Ranc==0) Failure;
          Ws[t].Ranc--;
          goto ReRanc;
        }
      } /* k1 */
    EndSwitch;
  EndReds;
  /* Here we look at the info from the sections of gaps. */
  /* May be able to tell which are positive (or negative). If one of the
  gaps in a section is then they all are because the section is. */
  /* Flag names are a touch confusing. "Positive" means the direction is
  known, although it is left<right perhaps only because of "Inverted". */
#if 0
  PrintRanks();
#endif
  for(f=0;f<Gmp->w.Needs-1;f++){
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      ll=Ws[l].Rank;rr=Ws[r].Rank;
      if(ll==0 || rr==0) continue;/* No knowledge if one can go anywhere. */
      /* To be certain about 'Positive' we should be comparing Rank with Ranc.
      However, comparing Rank with Rank will give us more direction without
      really constraining mapping choices much.  Not obvious what is right
      but I'll do the first outline-ing with Ranc and then use Rank. */
      tt=(RankRanc ? Ws[l].Rank : Ws[l].Ranc);
      if(tt<rr){
        if(!Wm[f].Positive){
#if 0
          printf("\n%d to %d made positive, %d",l,r,f);
#endif
          Wm[f].Positive=Yes;
        }
      }
      tt=(RankRanc ? Ws[r].Rank : Ws[r].Ranc);
      if(tt<ll && Wm[f].Positive) {
        /* Can't swap left and right so right must increase rank. */
        if(Ws[r].Ranc<ll){
          printf("\n!!Reinvert %d %d %d(%d) %d(%d) %d",
            f,Wm[f].Sample,l,ll,r,rr,Wg[c].Sample);
          PrintSection(f);
          Failure;
        }
        printf("\nRerank %d to %d, cause %d",r,ll,l);
        Ws[r].Rank=ll;goto ReRank;
      }
      if(tt<ll) {
        /* Swop lhs and rhs throughout the switch. */
        for(e=Wm[f].Lo;e<Wm[f+1].Lo;e++){
          t=Wg[e].L;Wg[e].L=Wg[e].R;Wg[e].R=t;
        }
        Wm[f].Positive=Yes;
        if(!Wm[f].Inverted){
#if 0
          printf("\n%d to %d made inverted, %d",l,r,f);
#endif
          Wm[f].Inverted=Yes;
        }
      }
    } /* c */
  } /* f */
  /* Inverted flag not much used again.  Positive means involved-in-setup.
  Gap values involved in setup will be +ve. */
  /* Setting the Positive flags will have dragged some more states into
  the ranking: */
  m=No;
  for(f=0;f<Gmp->w.Needs-1;f++){
    if(!Wm[f].Positive) continue;
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      ll=Ws[l].Rank;rr=Ws[r].Rank;
      /* If they are not suitably ranked, they will need to be. */
      /* If ll==0 all we know is that it needs to be smaller, which could
      be any rank up through rr.  We may need more complex choice here. */
#if 0
      /* I'll try not giving the rank, and hope one is picked up later
      via Essentials. */
      if(ll==0 && rr!=0){
        Ws[l].Rank=1;
        printf("\nDerived ranking %d, %d < %d",l,l,r);
        m=Yes;
      }
#endif
      if(rr==0 && ll!=0){
        /* If rr==0 it is going to need to be at least ll. */
        rr=Ws[r].Rank=ll;
        printf("\nDerived ranking %d(%d), %d < %d",r,ll,l,r);
        m=Yes;
      }
      if(ll>rr){
        printf("\nDerived ranking %d < %d",l,r);
        Ws[r].Rank=ll;
        m=Yes;
      }
    } /* c */
  } /* f */
  if(m) goto ReRank;
  /* We are not stable yet, because we haven't looked at what the sections
  say about Ranc. */
  for(f=0;f<Gmp->w.Needs-1;f++){
    if(!Wm[f].Positive) continue;
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      ll=Ws[l].Rank;rr=Ws[r].Rank;
      if(ll==0 || rr==0) continue;
      if(Ws[l].Ranc > Ws[r].Ranc){
        Ws[l].Ranc=Ws[r].Ranc;
        goto ReRanc;
      }
    } /* c */
  } /* f */
  Rechain();
 } /* locals */
 /* Maybe improve the switches by exploiting freedom Ranc shows? */
 /* The more we can sensibly settle, the less has to be done later by
 searching for solutions. */
 { Ushort d,e,f,c,j,l,r,lp,rp,ll,rr,tt;
  Bool m,mm;
  Bool EqualRank;
  for(j=0;j<StatesCount;j++){
    Ws[j].RankSettled=No;
    if(!Ws[j].Rank) continue;
    if(Ws[j].Rank==Ws[j].Ranc) Ws[j].RankSettled=Yes;
  }
  mm=No;
ReSettle:
  m=No;
  for(f=0;f<Gmp->w.Needs-1;f++){
    if(!Wm[f].Positive) continue;
    /* Note the pairs that implied this was a Positive. */
    Esp->w.Needs=0;EqualRank=No;
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      ll=Ws[l].Rank;rr=Ws[r].Rank;
      if(ll==0 || rr==0) continue;
      tt=(RankRanc ? Ws[l].Rank : Ws[l].Ranc);
      if(tt<rr){
        lp=ll;rp=rr;/* Some pair of ranks that gave Positive. */
      }
      /* Note the "essential" ranks, where both ranks are settled. */
      if(Ws[l].RankSettled && Ws[r].RankSettled){
        e=Esp->w.Needs++;WalletCheck(Esp);
        We[e].LL=ll;We[e].RR=rr;
        if(ll==rr) EqualRank=Yes;
        /* It might have been already there. */
        for(d=0;d<e;d++){
          if(We[e].LL==We[d].LL && We[e].RR==We[d].RR){
            Esp->w.Needs--;break;
          }
        }
      }
    } /* Section */
    /* If we didn't get any essentials, the weaker reason will have to do. */
    if(Esp->w.Needs==0){
        e=Esp->w.Needs++;WalletCheck(Esp);
        We[e].LL=lp;We[e].RR=rp;
        if(lp==rp) EqualRank=Yes;
    }
    /* Through the section again, to see what guidance from Essentials. */
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      if(Ws[l].RankSettled && Ws[r].RankSettled) continue;
      if(Ws[l].RankSettled){
        ll=Ws[l].Rank;
        /* See if ll is an essential. */
        for(d=0;d<Esp->w.Needs;d++){
          if(We[d].LL==ll){
            /* It must be reasonable to make (l,r) match an essential
            if we can. */
            tt=We[d].RR;
            if(Ws[r].Rank<=tt && Ws[r].Ranc>=tt){
              if(Ws[r].Rank!=tt) mm=Yes;
              Ws[r].Rank=tt;Ws[r].RankSettled=Yes,m=Yes;
            }
          }
        }
        /* If that didn't settle rr, it will be reasonable to make it
        equal to ll if we know there are equals in essential. */
        if(!Ws[r].RankSettled && EqualRank && ll<=Ws[r].Ranc){
          if(Ws[r].Rank!=ll) mm=Yes;
          Ws[r].Rank=ll;Ws[r].RankSettled=Yes,m=Yes;
        }
      }
      if(Ws[r].RankSettled){
        rr=Ws[r].Rank;
        /* See if rr is an essential. */
        for(d=0;d<Esp->w.Needs;d++){
          if(We[d].RR==rr){
            /* It must be reasonable to make (l,r) match an essential
            if we can. */
            tt=We[d].LL;
            if(Ws[l].Rank<=tt && Ws[l].Ranc>=tt){
              if(Ws[l].Rank!=tt) mm=Yes;
              Ws[l].Rank=tt;Ws[l].RankSettled=Yes,m=Yes;
            }
          }
        }
        if(!Ws[l].RankSettled && EqualRank && rr<=Ws[l].Ranc){
          if(Ws[l].Rank!=rr) mm=Yes;
          Ws[l].Rank=rr;Ws[l].RankSettled=Yes,m=Yes;
        }
      }
    } /* Section */
#if 0
    if(!m && !mm){
      printf("\nEssentials for %d:",f);
      for(d=0;d<Esp->w.Needs;d++){
        printf("\nLL=%d RR=%d",We[d].LL,We[d].RR);
      }
    }
#endif
  } /* f */
  if(m) goto ReSettle;
  if(mm) goto ReRank;
  /* More go-around using Rank instead of Ranc. */
  if(!RankRanc){
    RankRanc=Yes;
    goto ReRank;
  }
  /* We will not use Ranc again but following tidys printout. */
  for(j=0;j<StatesCount;j++){
    if(Ws[j].RankSettled) Ws[j].Ranc=Ws[j].Rank;
  }
  for(f=0;f<Gmp->w.Needs-1;f++){
    if(!Wm[f].Positive) continue;
    PrintSection(f);
  }
 } /* locals */
 { Ushort j,k,t,g;
/* Setup wallet describing the ranks. */
  Rp->w.Needs=MaxRank;WalletCheck(Rp);
  Needed=0;
  for(k=0;k<=MaxRank;k++){
    Wr[k].Tot=0;
    for(j=0;j<StatesCount;j++){
      if(Ws[j].Rank==k){
        Wr[k].Tot+=Ws[j].Physical+Ws[j].HasExit;
      }
    }
    Needed+=Wr[k].Tot;
  }
  PrintRanks();
  /* Set the bounds assuming completely compact. */
  /* Without the zero ones. */
  Wr[0].Tot=0;
  for(t=0,k=0;k<=MaxRank;k++){
    Wr[k].Lo=t;
    g=Wr[k].Tot;
    t+=g;
    Wr[k].Hi=t-1;
  }
  printf("\n\nStates physical total %d",Needed);
  printf("\nRanked total %d\n",RankedTotal);
  PrintPartitions();
  printf("\n***** Part B completed.");
 } /* locals */
/*------------------------------------------------------------------------------
C1. Layout states with gaps that span partitions.
õ-----------------------------------------------------------------------------*/
/* Firstly hints on where to map states. */
 {Ushort j,q,c,e,f,l,r,ll,rr,Range,k,t,g;
  Ushort Pct,Nct;
  Ushort MinL,MinR,MaxL,MaxR,RankDelta;
  char LStrip[6], RStrip[6];/* Which ranks appear on left/right of gap? */
  /* Strips not used now. */
  if(MaxRank>45) Failure;
  for(f=0;f<Gmp->w.Needs-1;f++){
    if(!Wm[f].Positive) continue;
    MinL=MinR=USHRT_MAX;MaxL=MaxR=0;RankDelta=0;
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      ll=Ws[l].Rank;rr=Ws[r].Rank;
      if(ll){
        if(ll<MinL) MinL=ll;
        if(ll>MaxL) MaxL=ll;
      }
      if(rr){
        if(rr<MinR) MinR=rr;
        if(rr>MaxR) MaxR=rr;
      }
      if(ll && rr){
        if(rr-ll > RankDelta) RankDelta=rr-ll;
      }
    } /* Section */
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      ll=Ws[l].Rank;rr=Ws[r].Rank;
      if(ll==0 || rr==0) continue;/* No hint if one can go anywhere. */
      /* Where the rank gap is most it will be useful if those on the
      right are mapped low. */
      if(ll && rr && (rr-ll)==RankDelta){
        if(!Ws[r].MapLow){
          Ws[r].MapLow=Yes;
          printf("\n%d to map low +cause %d&%d",r,f,Wm[f].Sample);
        }
        if(!Ws[l].MapHigh){
          Ws[l].MapHigh=Yes;
          printf("\n%d to map high +cause %d&%d",l,f,Wm[f].Sample);
        }
      }
    } /* Section */
    /* Both sides have to have a non-zero before anything deducible. */
    /* Happens anyway for Positives, I think. */
    if(MaxL==0 || MaxR==0) continue;
    if(MaxL!=MinL && MaxR!=MinR){
      /* I'm hoping this is solely cases like 6(1)^4(1) 72(5)^57(6) */
      printf("\nHoping this is OK:");
      PrintSection(f);
      continue;
    }
    if(MaxL>MinL+1){
      /* Right partition will have to cope with gaps implied by left. */
      Range=TuneHigh+2;/* Not sure if spares are necessary. */
      for(k=MinL+1;k<MaxL;k++){
        Range+=Wr[k].Tot;
      }
      if(Wr[MinR].Tot<Range){
        printf("\nPartition %d plumped to %d",MinR,Range);
        Wr[MinR].Tot=Range;
      }
    }
    if(MaxR>MinR+1){
      Range=TuneHigh+2;/* Not sure if spares are necessary. */
      for(k=MinR+1;k<MaxR;k++){
        Range+=Wr[k].Tot;
      }
      if(Wr[MinL].Tot<Range){
        printf("\nPartition %d plumped to %d",MinL,Range);
        Wr[MinL].Tot=Range;
      }
    }
  } /* f */
  /* The hints can conflict. */
  for(j=0;j<StatesCount;j++){
    if(Ws[j].MapHigh && Ws[j].MapLow){
      printf("\nHighLow %d",j);
      Ws[j].MapHigh=No;
      Ws[j].MapLow=No;
    }
  }
  Pct=Nct=0;
  /* Only a fraction of the gaps get involved with the initial setup
  in this way. */
  for(f=0;f<Gmp->w.Needs-1;f++){
    if(Wm[f].Inverted) Nct++;
    else if(Wm[f].Positive) Pct++;
    else continue;
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      Ws[l].Setup=Yes;Ws[r].Setup=Yes;
      Wm[f].Involved=1;
      if(Wm[f].Positive)
        printf("\n%d:%d(%d)^%d(%d)",f,l,Ws[l].Rank,r,Ws[r].Rank);
    }
  } /* f */
  printf("\n%d positive, %d negative, of %d",Pct,Nct,Gmp->w.Needs-1);
  /* Are all the Setup states and Positive gaps one problem? */
  /* They can be divided into disjoint sets but no clear advantage. */
  /* See old code. */
/* All in one group until proved need otherwise. */
  for(j=0;j<StatesCount;j++){
    if(Ws[j].Setup){
      Ws[j].Involved=1;
      t=Ws[j].Rank;
      if(t){
        Ws[j].Work=Wr[t].Lo;
#if 0
        if(Ws[j].MapHigh)
          Ws[j].Work=Wr[t].Hi;
#endif
      }
      else Ws[j].Work=0;
    }
  }
 } /* locals */
 {Ushort t,j,k,l,g,r,f,c,e,n,xx,yy;
  Ushort * Rowj;
  float u;
  /* Set the bounds after plumping, and take what the shift array needs. */
  /* Spread any extra space around the ranks. */
  u=Needed; /* 0 thru u slots makes just one spare. */
  u=u/Wr[MaxRank].Hi;
  for(k=1;k<=MaxRank;k++){
    g=Wr[k].Lo*u;
    Wr[k].Lo=g;
    Wr[k-1].Hi=g-1;
    Wr[k-1].Tot=g-Wr[k-1].Lo;
  }
  Wr[MaxRank].Hi=Needed;Wr[MaxRank].Tot=Needed+1-Wr[MaxRank].Lo;
  Needed+=Used; /* Include array shift needs. */
  k=1;g=Wr[k].Tot;Wr[k].Lo=0;
  for(n=0;n<Needed;n++){
    /* Is this slot needed for the shift array? */
    xx=n/RetainedTokenCt;
    if(xx>=RetainedStateCt) goto NotArray;
    yy=n%RetainedTokenCt;
    j=x[xx];Rowj=Ws[j].Shift;
    c=y[yy];
    t=*(Rowj+c);
    if(t){
      Taken[n]=t;
    }
    else {
NotArray:
      while(!g && k<=MaxRank){ /* Partition k satisfied. */
        Wr[k++].Hi=n-1;Wr[k].Lo=n;g=Wr[k].Tot;
      }
      g--;
    }
  }
  Wr[MaxRank].Hi=Needed-1;
  Wr[0].Lo=0;Wr[0].Hi=Needed-1;
  PrintPartitions();
  PrintTaken();
 } /* locals */
/* See what gap values are consistent with the partition layout. */
 {Ushort f,c,l,ll,r,rr,t;
  Ushort GapMin,GapMax;
  for(f=0;f<Gmp->w.Needs-1;f++){
    if(!Wm[f].Positive) continue;
    GapMax=USHRT_MAX;GapMin=0;
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      ll=Ws[l].Rank;rr=Ws[r].Rank;
      t=Wr[rr].Hi-Wr[ll].Lo; /* Max gap we can get from this one. */
      if(t<GapMax) GapMax=t;
      t=0;
      if(rr>ll){
        t=Wr[rr].Lo-Wr[ll].Hi; /* Min gap we can get from this one. */
        if(t>GapMin) GapMin=t;
      }
    }
    /* These "Positive" cases are spanning partitions. */
    /* In the case where the gap is spanning between partitions, if the
    gap is minimal it will only work for one pair of states - the second
    pair cannot have the same gap. */
    /* Crude allowance for this. */
    /* Crude and unreliable since there could be another section
    spanning the same partitions, but what else to do...? */
    t=Wm[f+1].Lo-Wm[f].Lo;/* How many in the section. */
    GapMin+=t;
    printf("\n%d$%d section range %d:%d",f,Wm[f].Sample,GapMin,GapMax);
    if(GapMax<GapMin){
      printf("\n%d %d %d",t,l,r);
      PrintSection(f);
      Failure;
    }
    Wm[f].GapMax=GapMax;
    Wm[f].GapMin=GapMin;
  } /* f */
  for(f=0;f<Gmp->w.Needs-1;f++){
    if(Wm[f].Positive) continue;
    /* For the non-setup, we don't know so much. */
    Wm[f].AbsMax=USHRT_MAX;
    Wm[f].AbsMin=0;
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      ll=Ws[l].Rank;rr=Ws[r].Rank;
      /* Either same rank or at least one not ranked. */
      if(ll && ll==rr){
        t=Wr[ll].Hi-Wr[ll].Lo; /* Max gap we can get within this rank. */
        if(t<Wm[f].AbsMax) Wm[f].AbsMax=t;
      }
    }
  } /* f */
/* See what gap values are consistent with the physical sizes. */
  for(f=0;f<Gmp->w.Needs-1;f++){
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      l=Wg[c].L;r=Wg[c].R;
      if(l>=AtomBreak) continue;
      if(Wm[f].Positive){
        if(Ws[l].Physical>Wm[f].GapMin){
          Wm[f].GapMin=Ws[l].Physical;
          if(Wm[f].GapMin>Wm[f].GapMax) Failure;
        }
      }
      else{
        /* We don't know if lefts or rights are determining the gap so
        worst-case. */
        if(Ws[l].Physical>Wm[f].AbsMin){
          Wm[f].AbsMin=Ws[l].Physical;
          if(Wm[f].AbsMin>Wm[f].AbsMax) Failure;
        }
        if(Ws[r].Physical>Wm[f].AbsMin){
          Wm[f].AbsMin=Ws[r].Physical;
          if(Wm[f].AbsMin>Wm[f].AbsMax) Failure;
        }
      }
    }
    if(Wm[f].Positive)
      printf("\n%d$%d section range %d:%d",
        f,Wm[f].Sample,Wm[f].GapMin,Wm[f].GapMax);
    else if(Wm[f].AbsMax!=USHRT_MAX)
      printf("\n%d$%d section range %d,%d",
        f,Wm[f].Sample,Wm[f].AbsMin,Wm[f].AbsMax);
  } /* f */
 } /* locals */
/*------------------------------------------------------------------------------
C2. Recursive trials for mapping the remaining constrained states.
At this stage, each element in Gmp-> is a decision to be made on the value
of a gap constant.  The pairs having that gap are contiguous in Gpp->.
No decisions have been made, but there are constraints on gap sizes.
õ-----------------------------------------------------------------------------*/
 {DoVars;
  Ushort d,f,g,t,Bsfj,Bsff,Maxt,Mint,Maxj,Minj,Maxd,Mind;
  Ushort Atoma;
  Ulong v,Bsfg,Bsfv;
  /* Mark the states involved. */
  for(c=0;c<Gpp->w.Needs;c++){
    Ws[Wg[c].L].Constrained=Yes;
    Ws[Wg[c].R].Constrained=Yes;
  }
  ConstrainCt=0;
  for(j=0;j<StatesCount;j++){
    if(Ws[j].Constrained) ConstrainCt++;
    t=Ws[j].Rank;
    Ws[j].Lo=Wr[t].Lo;
    Ws[j].Hi=Wr[t].Hi;
  }
  /* Mix all the constraints together. */
  RangeCut();
  printf("\nAll %d,Constrained %d", StatesCount, ConstrainCt);
  /* Select a decision not yet made. */
#if 0
  /* Setup considered first. */
  for(;;){
    /* See what a gap selection would bring in. */
    Dep->w.Needs=0;
    Bsfg=0;
    for(f=0;f<Gmp->w.Needs-1;f++){
      if(!Wm[f].Involved) continue;
      if(Wm[f].IsDecided) continue;
      Also(GapSize,f,0);
      v=Merit();
      Undecided(0);
      if(v>Bsfg){Bsff=f;Bsfg=v;}
    }
    /* See what a state selection would bring in. */
    Dep->w.Needs=0;
    Bsfv=0;
    for(j=0;j<StatesCount;j++){
      if(Ws[j].IsDecided) continue;
      if(!Ws[j].Setup) continue;
      Also(PositionS,j,0);
      v=Merit();
      Undecided(0);
      if(v>Bsfv){Bsfj=j;Bsfv=v;}
    }
    if(Bsfg>Bsfv){
      /* Commit the decision */
      if(!Map(GapSize,Bsff)) Failure;
      continue;
    }
    if(Bsfv){
      /* Commit the decision */
      if(!Map(PositionS,Bsfj)) Failure;
      continue;
    }
    break;
  }
  Confirm();
  printf("\nThrough Setup.");
#endif
  /* Whatever is left, using Merit figure. */
  printf("\nRemap");
/* This looks like a loop committing the states to positions serially, in
merit order.  It is not that simple because a failure to map during one of
the calls from this loop can cause the whole process to restart from the
Remap label (with global 'difficulty' settings changed to make the merit
order differ).
  Also the routine Map is not a simple choice of a slot for the state
because it uses Consider which can recursively lookahead to make sure
sure choices are good. */
  for(;;){
    Dep->w.Needs=0;
    Bsfv=0;
    printf("\nSofar");
    printf(" 70 Decid %d %d",Ws[70].IsDecided,Ws[70].Decided);
    for(j=0;j<StatesCount;j++){
      if(Ws[j].IsDecided) {
#if 0
        printf(" %d",j);
#endif
        continue;
      }
      Also(PositionS,j,0);
      v=Merit();
      Undecided(0);
      if(v>Bsfv){Bsfj=j;Bsfv=v;}
    }
    if(Bsfv){
      printf("\nNow %d",Bsfj);
      /* Commit the decision */
      if(!Map(PositionS,Bsfj)) Failure;
      continue;
    }
    break;
  }
  Confirm();
  printf("\nThrough all");
  PrintTaken();
 }
/*------------------------------------------------------------------------------
D1. Put more assembler on the output.
õ-----------------------------------------------------------------------------*/
 {Ushort t,j,k,l,g,r,f,c,e,n,xx,yy;
  Ushort * Rowj;
  Ushort Atoma,AimedAt;
/* Put out the Assembler code for the rest. */
/* There is some tidying to be done because a SubsetR link that links to
something short is no benefit. */
  for(j=0;j<StatesCount;j++){
    if(Ws[j].SubsetR){
      g=Ws[j].SubsetOfR;
Follow:
      if(Ws[g].SubsetR){
        g=Ws[g].SubsetOfR;goto Follow;
      }
      if(Ws[g].PhysicalR==1){
        /* Must be Direct or Arith alone now. */
        Ws[j].SubsetR=No;Ws[j].DirectR=Ws[g].DirectR;
        Ws[j].Section=Ws[g].Section;
      }
    }
  }
  if(ConstrainCt>10000) Failure;ConstrainCt+=10000;
  NewLine();
  ShowS(";States merged with sparse shift array.");
  NewLine();
  ShowS("StatesDim equ ");
  ShowD(RetainedStateCt);
  NewLine();
  ShowS("TokensDim equ ");
  ShowD(RetainedTokenCt);
  NewLine();
  ShowS("$Needed equ 2*");
  ShowD(Needed);
  NewLine();
  /* This had to be left until Decided was known. */
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    AimedAt=(Atoms+Atoma)->AimedAt;
    if((Atoms+Atoma)->DirectAim){
      AimedAt=(Atoms+Atoma)->AimedAt;
      ShowS("$Grp");ShowD(Atoma);ShowS("Aim equ ");
      ShowD(Ws[AimedAt].Decided);
      ShowS(";S");
      ShowD(AimedAt);
      NewLine();
    }
    if((Atoms+Atoma)->DirectSubj){
      ShowS("$Grp");ShowD(Atoma);ShowS("Only equ 1");
      NewLine();
    }
  }
  ShowS("StateOrig word Overlay");
  NewLine();
  for(n=0;n<Needed;n++){
    /* Is this slot taken for the shift array? */
    xx=n/RetainedTokenCt;
    if(xx>=RetainedStateCt) goto NotArray2;
    yy=n%RetainedTokenCt;
    j=x[xx];Rowj=Ws[j].Shift;
    c=y[yy];
    t=*(Rowj+c);
    if(t){
      Ushort tt;
      j=t-1;
      ShowS(" word ");
      tt=Ws[j].Decided;
/* Targetting on State 0 was used to flag a special case. Now flag is to
be offset of 0. */
      if(j==0) tt=0;
      ShowD(tt);
      ShowS("*2;");
      SetColumn(14);
      ShowS("At ");
      ShowD(n);
      ShowS(",element ");
      ShowD(xx);
      ShowS(",");
      ShowD(yy);
      NewLine();
    }
    else {
NotArray2:
      if(Taken[n]==0){
        n++; /* Can there be unused gaps? */
        NewLine();
        ShowS(" dw 0; Wasted");
        }
      else{
        j=Taken[n]-1;
        if(j>StatesCount){
          printf("\n%d %d",n,Taken[n]);
          Failure;
        }
        ShowState(j);
        n+=Ws[j].HasExit;
        n+=Ws[j].Physical-1;
      }
    }
  }
  NewLine();
/* What can an exit expect to see on the stack? */
/* Too much stuff to go on SYN.INC */
#if 0
/* What can an exit expect to see on the stack? */
  for(j=0;j<StatesCount;j++){
    if(Ws[j].HasExit){
      ShowS(";S");
      ShowD(j);
      ShowS(" Action");
      ShowD(Ws[j].ExitNum);
      ShowS(" sees");
      for(k=Ws[j].ReLoOrig;k<Ws[j].ReZiOrig;k++){
        g=Wp[k].T;
        if(QryColumn()>60){
          NewLine();ShowC(';');
        }
        ShowS(" S");
        ShowD(g);
        ShowC('@');
        ShowD(Ws[g].Decided);
      }
      NewLine();
    }
  }
/* This doesn't work either since a state doesn't necessarily reduce on
what is above it on the stack. */
/* What can an exit expect to see on the stack? */
  for(j=0;j<StatesCount;j++){
    Ushort kk;
    if(Ws[j].HasExit){
      printf("\n%d action %d sees:",j,Ws[j].ExitNum);
      for(k=Ws[j].ReLoOrig;k<Ws[j].ReZiOrig;k++){
        g=Wp[k].T;
        printf("\nS%d",g);
        for(kk=Ws[g].ReLoOrig;kk<Ws[g].ReZiOrig;kk++){
          printf("\n  S%d",Wp[kk].T);
        }
      }
    }
  }
  printf("\n");
#endif
 return;
 }
#if 0
  /* Not doing tokens with option u. */
  /* Arbitary, token values next. */
  for(;;){
    Dep->w.Needs=0;
    Bsfv=0;
    for(Atoma=0;Atoma<AtomsCount;Atoma++){
      if(!(Atoms+Atoma)->Constrained || (Atoms+Atoma)->IsDecided) continue;
      Also(PositionT,Atoma,0);
      d=Dep->w.Needs;/* Decision plus what it implied. */
      Undecided(0);
      if(d>Bsfv){Bsfj=Atoma;Bsfv=d;}
    }
    if(Bsfv==0){
      printf("\nOut of constrained tokens");break;
    }
    Also(PositionT,Bsfj,0);
    PrintDec();
    /* Commit the decision */
  }
#endif
}
static char Conflict[508][63];
static void ArrayShifts(void){
  DoVars;
  Ushort Atoma, Atomb;
  char (* Cf)[63];
/* Conflict test is just a speedup */
/* And it didn't do much - still approaching a minute for this routine. */
/* Ws[j].Shift has been set up. We now tighten the array, exploiting knowledge
of what (State,Token) pairs are never looked up. */
Ushort Bsf,Merit,n;
Ushort Bsfa,Bsfb,Bsfj,Bsfq;
Ushort * Rowj, * Rowq;
Ushort t,AimedAt;
Ushort Rja,Rqa,Rjb;
  if(StatesCount>508 || AtomsCount>508) Failure;
  /* What does it look like from atoms point of view?*/
  /* If we are using a big array, it is worth the 'aimed at' mechanism. */
  if(UseArray)
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    if(!(Atoms+Atoma)->UseArray) continue;
    AimedAt=USHRT_MAX;
    DoShiftj;
#if 0
      if(Ws[j].Direct) continue;
#endif
      Rowj=Ws[j].Shift;
      t=*(Rowj+Atoma);
      if(t){/* t was target in j list. */
        if(AimedAt==USHRT_MAX) AimedAt=t;
        else if(AimedAt!=t) goto NextAtom;
      }
    EndShifts;
    /* All targets for this atom were the same. */
    AimedAt--; /* Was upped to ensure nonzero */
    (Atoms+Atoma)->DirectAim=Yes;
    (Atoms+Atoma)->AimedAt=AimedAt;
    /* No longer needed in the array. */
    DoShiftj;
#if 0
      if(Ws[j].Direct) continue;
#endif
      Rowj=Ws[j].Shift;
      *(Rowj+Atoma)=0;
    EndShifts;
NextAtom:;
  }
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    AimedAt=(Atoms+Atoma)->AimedAt;
    if((Atoms+Atoma)->DirectAim){
      printf("\nAtom %d aimed at %d",Atoma,AimedAt);
    }
  }
/* States by States to find best pair to overlay. */
  Clear(Conflict);
/* It is merit if goto overlays same goto, or if goto overlays empty. */
NextBest:
  Bsf = 0;
  DoShiftj;
    if(Ws[j].ArrayGone) continue;
    Rowj=Ws[j].Shift;
    Cf=&(Conflict[j]);
    DoAboveq;
      if(Ws[q].ArrayGone) continue;
      if(QryFlag(Cf[0],q)) continue;
      Rowq=Ws[q].Shift;
      Merit=0;
      for(Atoma=0;Atoma<AtomsCount;Atoma++){
        if(!(Atoms+Atoma)->UseArray) continue;
        Rja=*(Rowj+Atoma);Rqa=*(Rowq+Atoma);
        if(Rja){/* Was goto in j list. */
          if(!Rqa) Merit++; /* Empty in q list */
          else
            if(Rja == Rqa)
              Merit+=AtomsCount; /* Much more merits */
            else{
              Merit=0;SetFlag(Cf[0],q);break;
            }
        }
        /* Overlay regarded as q on j as well as j on q. */
        if(Rqa){
          if(!Rja) Merit++;
          else
            if(Rja == Rqa)
              Merit+=AtomsCount; /* Much more merits */
            else{
              Merit=0;SetFlag(Cf[0],q);break;
            }
         }
      } /* Atoma */
      if(Merit>Bsf){
        Bsf=Merit;Bsfj=j;Bsfq=q;
      }
    EndShifts;
  EndShifts;
#if 0
  printf("\nBsf %d %d %d", Bsf, Bsfj, Bsfq);
#endif
  if(Bsf){
    /* Overlay Bsfq on Bsfj */
    Rowj=Ws[Bsfj].Shift;
    Rowq=Ws[Bsfq].Shift;
    for(Atoma=0;Atoma<AtomsCount;Atoma++){
      if(!(Atoms+Atoma)->UseArray) continue;
      if(!*(Rowj+Atoma)) *(Rowj+Atoma) = *(Rowq+Atoma);
    }
    free(Rowq);
    Ws[Bsfq].Shift=NULL;
    Ws[Bsfq].ArrayGone=Yes;
    Ws[Bsfq].ArraySame=Bsfj;
#if 0
    printf("\nArraySame %d %d",Bsfq,Bsfj);
#endif
    goto NextBest;
  }
/* What states left involved? */
  DoShiftj;
    if(Ws[j].ArrayGone) continue;
#if 0
    printf("\nRetained State %d", j);
#endif
    RetainedStateCt++;
  EndShifts;
/* Overlaying the columns. */
  printf("\nArraySh 3\n");
  Clear(Conflict);
NextBestCols:
  Bsf = 0;
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    if((Atoms+Atoma)->ArrayGone) continue;
    if(!(Atoms+Atoma)->UseArray) continue;
    Cf=&(Conflict[Atoma]);
    for(Atomb=Atoma+1;Atomb<AtomsCount;Atomb++){
      if((Atoms+Atomb)->ArrayGone) continue;
      if(!(Atoms+Atomb)->UseArray) continue;
      if(QryFlag(Cf[0],Atomb)) continue;
      Merit=0;
      DoShiftj;
        if(Ws[j].ArrayGone) continue;
        Rowj=Ws[j].Shift;Rja=*(Rowj+Atoma);Rjb=*(Rowj+Atomb);
        if(Rja){
          if(!Rjb) Merit++;
          else
            if(Rja == Rjb)
              Merit+=AtomsCount; /* Much more merits */
            else{
              Merit=0;SetFlag(Cf[0],Atomb);break;
            }
        }
        if(Rjb){
          if(!Rja) Merit++;
          else
            if(Rja == Rjb)
              Merit+=AtomsCount; /* Much more merits */
            else{
              Merit=0;SetFlag(Cf[0],Atomb);break;
            }
         }
      EndShifts;
      if(Merit>Bsf){
        Bsf=Merit;Bsfa=Atoma;Bsfb=Atomb;
      }
    } /* Atomb */
  } /* Atoma */
#if 0
  printf("\nBsfToks %d %d %d", Bsf, Bsfa, Bsfb);
#endif
  if(Bsf){
    /* Overlay Bsfb on Bsfa */
    DoShiftj;
      if(Ws[j].ArrayGone) continue;
      Rowj=Ws[j].Shift;
      if(!*(Rowj+Bsfa))
        *(Rowj+Bsfa) = *(Rowj+Bsfb);
    EndShifts;
    (Atoms+Bsfb)->ArrayGone=Yes;
    (Atoms+Bsfb)->ArraySame=Bsfa;
    goto NextBestCols;
  }
/* What cols left? */
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    if(!(Atoms+Atoma)->UseArray) continue;
    if(!(Atoms+Atoma)->ArrayGone){
#if 0
      printf("\nRetained Token %d", Atoma);
#endif
      RetainedTokenCt++;
    }
  }
  printf("\nArraySh 4\n");
  /* Make it densest in the (0,0) corner. */
  if(RetainedStateCt>Dim(x)) Failure;
  n=0;
  DoShiftj;
    if(Ws[j].ArrayGone) continue;
    x[n++]=j;
    Ws[j].Work=0;
    Rowj=Ws[j].Shift;
    for(Atoma=0;Atoma<AtomsCount;Atoma++){
      if((Atoms+Atoma)->ArrayGone) continue;
      if(*(Rowj+Atoma)) Ws[j].Work++;
    }
  EndShifts;
/* It is so small we can sort crudely. */
SortSt:;
  for(n=0;n<RetainedStateCt-1;n++){
    if(Ws[x[n]].Work<Ws[x[n+1]].Work){
      t=x[n];x[n]=x[n+1];x[n+1]=t;
      goto SortSt;
    }
  }
  for(n=0;n<RetainedStateCt;n++){
    Ws[x[n]].ArraySame=n; /* These will be the !ArrayGone ones */
  }
  if(RetainedTokenCt>Dim(y)){
    printf("\n%d",RetainedTokenCt);
    Failure;
  }
  n=0;
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    if((Atoms+Atoma)->ArrayGone) continue;
    y[n++]=Atoma;
    (Atoms+Atoma)->Work=0;
    DoShiftj;
      if(Ws[j].ArrayGone) continue;
      Rowj=Ws[j].Shift;
      if(*(Rowj+Atoma)) (Atoms+Atoma)->Work++;
    EndShifts;
  }
/* It is so small we can sort crudely. */
SortAt:;
  for(n=0;n<RetainedTokenCt-1;n++){
    if((Atoms+y[n])->Work<(Atoms+y[n+1])->Work){
      t=y[n];y[n]=y[n+1];y[n+1]=t;
      goto SortAt;
    }
  }
  for(n=0;n<RetainedTokenCt;n++){
    (Atoms+y[n])->ArraySame=n; /* These will be the !ArrayGone ones */
  }
/* How dense is the full array? */
  Used=Unused=0;
  printf("\nArray is %d by %d",RetainedTokenCt,RetainedStateCt);
  printf("\neg    ");
  for(n=0;n<RetainedStateCt;n++){
    printf("%3d|",x[n]);
  }
  for(t=0;t<RetainedTokenCt;t++){
    Atoma=y[t];
    printf("\n(%3d) ",Atoma);
    for(n=0;n<RetainedStateCt;n++){
      Rowj=Ws[x[n]].Shift;
      if(*(Rowj+Atoma)) printf("%3d ",*(Rowj+Atoma)-1),Used++;
      else              printf("    "),Unused++;
    }
    printf(" ");
  }
  printf("\nUsed %d, Spare %d", Used, Unused);
} /* ArrayShifts */
static void Undecided(Ushort d){
  DoVars;Ushort w,t;short s;
  for(c=d;c<Dep->w.Needs;c++){
    t=Wd[c].Type;
    w=Wd[c].Which;
    switch(t){
    case GapSize:
      Wm[w].IsDecided=No;
      break;
    case PositionS:
      Ws[w].IsDecided=No;
      if(Ws[w].Final){
        printf("\n%d Final",w);
        PrintDec();
        Failure;
      }
      break;
    case PositionT:
      (Atoms+w)->IsDecided=No;
      break;
    }
  }
  Dep->w.Needs=d;
  return;
} /* Undecided */
Bool PrintDecFlag;
static void PrintDec(void){
  DoVars;Ushort t,w,n;short d;
  if(!PrintDecFlag)
    return;
  for(c=0;c<Dep->w.Needs;c++){
    t=Wd[c].Type;
    w=Wd[c].Which;
    printf("\nDec %d %d ",t,w);
    if(t==GapSize){
      printf("Deduced %d ",Wd[c].Deduced);
      if(Wm[w].Positive) printf("<%d:%d> ",Wm[w].GapMin,Wm[w].GapMax);
      else               printf("<%d,%d> ",Wm[w].AbsMin,Wm[w].AbsMax);
      for(d=Wm[w].Lo;d<Wm[w+1].Lo;d++){
        if(d==Wd[c].Index)printf("*");
        printf("%d:%d^%d ",d,Wg[d].L,Wg[d].R);
      }
    }
    if(t==PositionS){
      printf("(%d:%d) Rank %d Deduced %d",
        Ws[w].Lo,Ws[w].Hi,Ws[w].Rank,Wd[c].Deduced);
    }
  }
  printf("\n...");
  return;
} /* PrintDec */
static Ushort RqdWidth(Ushort n){
  /* Width of field to distinguish n values. */
  Ushort t;
  Ulong r;
  t=1;r=2;
  for(;;r=2*r,t++){
    if(r>=n) return t;
  }
} /* RqdWidth */
static void Confirm(void){
  DoVars;
  Ushort d,t,f,ta,ga,gb,jv,gv,jf;
  Ushort js,s;
  for(j=0;j<StatesCount;j++){
    if(!Ws[j].IsDecided) continue;
    jv=Ws[j].Decided;
    for(t=jv-Ws[j].HasExit;t<jv+Ws[j].Physical;t++)
      if(Taken[t]!=j+1){
        printf("\nj=%d",j);
        PrintTaken();
        Failure;
      }
    if(jv<Wr[Ws[j].Rank].Lo) Failure;
    if(jv>Wr[Ws[j].Rank].Hi) Failure;
#if 0
    if(Ws[j].Direct)  continue;
#endif
    if(Ws[j].Subset)  continue;
    DoSwitchk;
      ta=Wp[k].T;ga=Wp[k].G;
      if((Atoms+ta)->UseArray) continue;
      if((Atoms+ta)->IsDecided && Ws[ga].IsDecided){
        gv=Ws[ga].Decided;
        if(gv!=jv+(Atoms+ta)->Decided) Failure;
      }
    EndSwitch;
  } /* j */
  DoRedj;
    if(Ws[j].DirectR) continue;
    if(Ws[j].SubsetR) continue;
    jf=Ws[j].Section;
    if(!Wm[jf].IsDecided) continue;
    js=Wm[jf].Decided;
    DoRedSwitk;
      if(k<Ws[j].VecReZi){
        ga=Wp[k].T;
        gb=Wp[k].G;
        if(Ws[ga].IsDecided && Ws[gb].IsDecided){
          if(Wm[jf].Inverted)
            s=Wrap(Ws[ga].Decided-Ws[gb].Decided);
          else
            s=Wrap(Ws[gb].Decided-Ws[ga].Decided);
          if(s != js){
            printf("\ngb %d(%d) ga %d(%d) s %d js %d jf %d",
              gb,Ws[gb].Decided,ga,Ws[ga].Decided,s,js,jf);
            printf("\nTesting state %d ",j);
            for(d=Wm[jf].Lo;d<Wm[jf+1].Lo;d++){
              printf("%d:%d^%d ",d,Wg[d].L,Wg[d].R);
            }
            Failure;
          }
        }
      }
      /* Else rank suffices */
    EndSwitch;
  EndReds;
  printf("\nConfirmed so far.");
}
static void PrintDecisions(void){
  Ushort d,w;
  return;
  for(d=0;d<Dep->w.Needs;d++){
    if(Wd[d].Type==GapSize){
      printf("\nGapSize %d set to %d",Wd[d].Which,Wd[d].Deduced);
    }
    if(Wd[d].Type==PositionS){
      w=Wd[d].Which;
      printf("\nDecision on %d set to %d",w,Wd[d].Deduced);
      if(Wd[d].Deduced != Ws[w].Decided){
        printf("\nVersus Decided %d",Ws[w].Decided);
        PrintTaken();
        Failure;
      }
    }
  } /* d */
  printf("\n+++");
} /* PrintDecisions */
static void PrintTaken(void){
  Ushort t,w;
  for(t=0;t<Needed;t++){
    if(t%15==0)printf("\n%4d| ",t);
    w=Taken[t];
    if(!w) printf("    ");else printf("%4d",w-1);
  }
} /* PrintTaken */
static void PrintSection(Ushort f){
  Ushort c,l,r;
  for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
    l=Wg[c].L;r=Wg[c].R;
    printf("\nSection %d has %d(%d",
      f,l,Ws[l].Rank);
    if(Ws[l].Ranc==Ws[l].Rank) printf(")");
    else printf(":%d)",Ws[l].Ranc);
    printf("^%d(%d",r,Ws[r].Rank);
    if(Ws[r].Ranc==Ws[r].Rank) printf(")");
    else printf(":%d)",Ws[r].Ranc);
  }
}
static void PrintStates(void){
  DoVars;Ushort n;
  for(j=0;j<StatesCount;j++){
    if(Ws[j].HasExit)
      printf("\n%d(1+%d)",j,Ws[j].Physical);
    else
      printf("\n%d(%d)",j,Ws[j].Physical);
    if(Ws[j].StackPhysical) printf("R");
    if(Ws[j].Error) printf("E");
    if(Ws[j].FlatSym) printf("F");
    if(Ws[j].KeysOffset) printf("K%d",Ws[j].KeysOffset);
    if(Ws[j].Direct) printf("D");
    if(Ws[j].Subset){
      printf("S");
      if(Ws[j].SubsetOf) printf("%d",Ws[j].SubsetOf);
    }
    if(Ws[j].DirectR) printf("d");
    if(Ws[j].SubsetR) printf("s%d",Ws[j].SubsetOfR);
    if(Ws[j].Filter) printf("f");
    if(Ws[j].IsSpecial) printf("i");
    if(Ws[j].FilterHi) printf("h");
    n=1;
    if(!Ws[j].NoShift){
      DoSwitchk;
        if((n++)%10==0) printf("\n");
        if((Atoms+Wp[k].T)->UseArray) continue;
        printf("[%d:%d]",Wp[k].T,Wp[k].G);
      EndSwitch;
    }
    if(!Ws[j].NoRed){
      DoRedSwitk;
        if((n++)%10==0) printf("\n");
        if(k<Ws[j].VecReZi)
          printf("{%d:%d}",Wp[k].T,Wp[k].G);
        else
          printf("<%d:%d>",Wp[k].T,Wp[k].G);
      EndSwitch;
    }
  }
} /* PrintStates */
static void PrintPartitions(void){
  Ushort k;
  for(k=0;k<=MaxRank;k++){
    printf("\nPartition %2d has %3d at %4d:%4d.", k,
       Wr[k].Tot, Wr[k].Lo, Wr[k].Hi);
  }
} /* PrintPartitions */
static void PrintRanks(void){
  Ushort k,j;
  RankedTotal=0;
  for(k=1;k<=MaxRank;k++){
    printf("\nRank %d\n",k);
    for(j=0;j<StatesCount;j++){
      if(Ws[j].Rank==k){
        printf("%d ",j);
      }
    }
    RankedTotal+=Wr[k].Tot;
  }
} /* PrintRanks */
static void Also(Ushort t,Ushort x,short m){
 /* The decision being made might be the address of a state, a token value,
 the gap for a set of reductions, or the gap for a set of tokens/states. */
 /* The m parameter is zero on non-recursive call, otherwise says how
 to derive deduction from equation x. */
  DoVars;
  Ushort n,a,l,r,w;
  Ushort d,h;
  /* Setup n to GapID, j to state, a to atom, and return if in play. */
  /* Otherwise deduce the new value. */
  if(m){
    l=Wg[x].L;r=Wg[x].R;n=Wg[x].N;
  }
  switch(t){
    case GapSize:/* x was index to Wg. */
      if(!m) n=x;
      if(Wm[n].IsDecided) return;
      Wm[n].IsDecided=Yes; /* Just to say its pending. */
      if(m) Wm[n].Decided=Wrap(Ws[r].Decided-Ws[l].Decided);
      d=Wm[n].Decided;
      w=n;
      break;
    case PositionS:/* x is state if m==0. */
      switch(m){
      case 1:
        j=r;
        if(Ws[j].IsDecided) return;
        Ws[j].IsDecided=Yes; /* Just to say its pending. */
        d=Wrap(Ws[l].Decided+Wm[n].Decided);
        Ws[j].Decided=d;
        w=j;
        break;
      case -1:
        j=l;
        if(Ws[j].IsDecided) return;
        Ws[j].IsDecided=Yes; /* Just to say its pending. */
        d=Wrap(Ws[r].Decided-Wm[n].Decided);
        Ws[j].Decided=d;
        w=j;
        break;
      default: j=x;/* Only at startup. */
        if(Ws[j].IsDecided) return;
        Ws[j].IsDecided=Yes; /* Just to say its pending. */
        d=Ws[j].Decided; /* Preset */
        w=j;
      }
      break;
    case PositionT:/* x is atom. */
      switch(m){
      case 1:
        a=r-AtomBreak;
        if((Atoms+a)->IsDecided) return;
        (Atoms+a)->IsDecided=Yes;
        d=(Atoms+a)->Decided=Wrap((Atoms+l-AtomBreak)->Decided+Wm[n].Decided);
        w=a;
        break;
      case -1:
        a=l-AtomBreak;
        if((Atoms+a)->IsDecided) return;
        (Atoms+a)->IsDecided=Yes;
        d=(Atoms+a)->Decided=Wrap((Atoms+r-AtomBreak)->Decided-Wm[n].Decided);
        w=a;
        break;
      default: a=x;/* Only at startup. */
        if((Atoms+a)->IsDecided) return;
        (Atoms+a)->IsDecided=Yes;
        d=0;
        w=a;
      }
      break;
  }
/* Add type t decision to decisions wallet, then ramifications. */
  h=Dep->w.Needs++;WalletCheck(Dep);
  Wd[h].Type=t;
  Wd[h].Index=x;
  Wd[h].Which=w;
  Wd[h].Slant=m;
  Wd[h].Deduced=d;
  switch(t){
    case GapSize:
      /* If we select this gap, we will be deciding positions where
       they are half decided. */
      /* +1 means right to be deduced from left. */
      for(c=Wm[n].Lo;c<Wm[n+1].Lo;c++){
        if(Ws[Wg[c].L].IsDecided) Also(PositionS,c,+1);
        if(Ws[Wg[c].R].IsDecided) Also(PositionS,c,-1);
      }
      break;
    case PositionS:
      /* It may be paired with something known; that sets the gap. */
      for(c=Ws[j].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
        if(Wg[c].L!=j) Failure;
        h=Wg[c].R;
        if(Ws[Wg[c].R].IsDecided){
          Also(GapSize,c,1);
        }
        /* Maybe the gap is known and one of pair is the new state. */
        if(Wm[Wg[c].N].IsDecided) Also(PositionS,c,+1);
      }
      for(c=Ws[j].ChainR;c!=USHRT_MAX;c=Wg[c].ChainR){
        if(Wg[c].R!=j) Failure;
        h=Wg[c].L;
        if(Ws[Wg[c].L].IsDecided){
          Also(GapSize,c,1);
        }
        /* Maybe the gap is known and one of pair is the new state. */
        if(Wm[Wg[c].N].IsDecided) Also(PositionS,c,-1);
      }
      break;
    case PositionT:
      (Atoms+a)->IsDecided=Yes;
      /* It may be paired with something known; that sets the gap. */
      for(c=(Atoms+a)->ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
        if(Ws[Wg[c].R].IsDecided) Also(GapSize,c,1);
        /* Maybe the gap is known. */
        if(Wm[Wg[c].N].IsDecided) Also(PositionT,c,+1);
      }
      for(c=(Atoms+a)->ChainR;c!=USHRT_MAX;c=Wg[c].ChainR){
        if(Ws[Wg[c].L].IsDecided) Also(GapSize,c,1);
        /* Maybe the gap is known. */
        if(Wm[Wg[c].N].IsDecided) Also(PositionT,c,-1);
      }
      break;
  }
  return;
} /* Also */
static Bool Map(Ushort Type,Ushort j){
/* Dec addresses a wallet of decisions that are linked, and have to be made
together.  They are linked by arithmetic, where a value is the sum/difference
of others, and more fuzzily by being ranked (some values must be bigger
than others).

The Dec wallet elements have Type (is the decision about a state address or...),
Index (the number of the state or ...),  Base (the equation
involved), and Slant (how to use the equation) .

The mapping process needs to know what values have already been allocated
and which not.  The data structure for that is Ushort Taken[Available], with
zero element where not yet used.

For ranking, the space is partitioned, with a set of boundaries
in wallet Rp.

The mapping choice is for the first thing; the rest will ensue.
*/
  Ushort t,tt,c,d,g,w,l,r,e,f,Span,From;
  Ushort BoundLo,BoundHi;
  if(Type==PositionS){
    /* Try possibilities. */
    BoundLo=Ws[j].Lo;
    BoundHi=Ws[j].Hi;
    Span=BoundHi-BoundLo+1;
    From=BoundLo;
    /* Mapping by search in both directions didn't give good results. */
    /* So map high by forward search in second half. */
    if(Ws[j].MapHigh){
      /* Was    From=BoundZi-1;Direction=-1; */
      Span=Min((Span+1)/2,TuneHigh);
      From=BoundHi+1-Span;
    }
    for(t=From;Span;Span--,t++){
      if(Ws[j].HasExit>t) goto Nextt; /* Danger when t=0 */
      for(tt=t-Ws[j].HasExit;tt<t+Ws[j].Physical;tt++)
        if(Taken[tt]) goto Nextt;
      for(tt=t-Ws[j].HasExit;tt<t+Ws[j].Physical;tt++)
        Taken[tt]=1+j;
      Ws[j].Decided=t;  /* Routine Also sets IsDecided */
      if(j==70){
 printf("\n 70 map Wase Phys %d %d %d",t,Ws[70].HasExit,Ws[70].Physical);
 printf("Taken %d %d %d",Taken[0],Taken[1],Taken[2]);
      }
      if(Consider(0,PositionS,j)){
        goto MapOK;
      }
Nextt:;
    } /* Within bounds */
    /* If it was MapHigh and didn't map we could try again with low mapping
    but probably this is a blind alley. */
    if(Ws[j].MapHigh){
      BoundLo=Ws[j].Lo;
      BoundHi=Ws[j].Hi;
      Span=BoundHi-BoundLo+1;
      From=BoundLo;
      for(t=From;Span;Span--,t++){
        if(Ws[j].HasExit>t) goto Nexttx; /* Danger when t=0 */
        for(tt=t-Ws[j].HasExit;tt<t+Ws[j].Physical;tt++)
          if(Taken[tt]) goto Nexttx;
        for(tt=t-Ws[j].HasExit;tt<t+Ws[j].Physical;tt++)
          Taken[tt]=1+j;
        Ws[j].Decided=t;  /* Routine Also sets IsDecided */
        if(Consider(0,PositionS,j)){
          printf("\nNonMapHigh");
          goto MapOK;
        }
Nexttx:;
      } /* Within bounds */
    }
#if 0
    if(MapMark) return No; /* From recursive call. */
#endif
    printf("\nScan for %d_%d(%d) space from %d to %d failed.",
        j,Ws[j].Rank,Ws[j].Physical,From,BoundHi);
    Also(PositionS,j,0);
    goto Dump;
  }
  else if(Type==GapSize){
    f=j;
    /* Use smallest gap that works. */
    for(t=Wm[f].GapMin;t<=Wm[f].GapMax;t++){
      Wm[f].Decided=t;
      if(Consider(0,GapSize,f)){
        printf("\nFinal for gap %d$%d is %d",f,Wm[f].Sample,Wm[f].Decided);
        if(Wm[f].Inverted) printf(" was invert");
        goto MapOK;
      }
    }
    return No;
  }
  Failure;
Dump:;
/* Something about what went wrong is dumped before trying again, with
the states that failed being given priority next time. */
    PrintDec();
    PrintTaken();
    tt=0;
    for(c=0;c<Dep->w.Needs;c++){
      t=Wd[c].Type;
      w=Wd[c].Which;
      if(t==PositionS){
        tt=1;Ws[w].Difficulty*=4;
        printf("\n%d difficulty to %d",w,Ws[w].Difficulty);
        if(Ws[w].Difficulty==256) Failure;
        if(Ws[w].Difficulty==64) PrintDecFlag=Yes;
      }
    }
    if(tt) longjmp(RemapEnv,1);
    return No;
MapOK:
  for(d=0;d<Dep->w.Needs;d++){
    w=Wd[d].Which;
    g=Wd[d].Deduced;
    if(Wd[d].Type==PositionS){
      Ws[w].Final=Yes;
      Ws[w].Lo=Ws[w].Hi=g;
    }
    if(Wd[d].Type==GapSize){
      Wm[w].GapMax=Wm[w].GapMin=g;
    }
  }
  /* If RangeCut does not succeed the constraints have become conflicting. */
  if(!RangeCut()){
    w=RangeCutter;
    Ws[w].Difficulty*=4;
    printf("\n%d difficulty (range) to %d",w,Ws[w].Difficulty);
    if(Ws[w].Difficulty==256) Failure;
    if(Ws[w].Difficulty==64) PrintDecFlag=Yes;
    goto Dump;
  }
  PrintDec();
  return Yes;
} /* Map */
static void Rechain(void){
  /* Rechain what is on Gpp-> up to index n. */
  Ushort Atoma,j,c,l,r;
  for(Atoma=0;Atoma<AtomsCount;Atoma++){
    (Atoms+Atoma)->ChainL=USHRT_MAX;
    (Atoms+Atoma)->ChainR=USHRT_MAX;
  }
  for(j=0;j<StatesCount;j++){
    Ws[j].ChainL=USHRT_MAX;
    Ws[j].ChainR=USHRT_MAX;
  }
  for(c=0;c<Gpp->w.Needs;c++){
    l=Wg[c].L;
    r=Wg[c].R;
    if(l>=AtomBreak){
      Wg[c].ChainL=(Atoms+l)->ChainL;(Atoms+l)->ChainL=c;
      Wg[c].ChainR=(Atoms+r)->ChainR;(Atoms+r)->ChainR=c;
    }
    else{
      Wg[c].ChainL=Ws[l].ChainL;Ws[l].ChainL=c;
      Wg[c].ChainR=Ws[r].ChainR;Ws[r].ChainR=c;
    }
  }
} /* Rechain */
static Ushort Wrap(long v){
  while(v>=Needed) v-=Needed;
  while(v<0) v+=Needed;
  return (Ushort)v;
}
static Bool Consider(Ushort m,Ushort t,Ushort x){
  /* Returns Yes if the Deduced values are consistent with the previously
  set Takens. Returns No otherwise unless m!=0 when it dumps the failure. */
  Ushort j,d,e,f,w,g,tt,l,r,v,ww,vv;
  Ushort MapMark;
  Bool Problem;
  Problem=No;
  MapMark=Dep->w.Needs;/* "Stack" marking Dep-> allows recursion. */
  if(t==PositionS){
    j=x;
    Also(PositionS,j,0);
  }
  else if(t==GapSize){
    f=x;
    Also(GapSize,f,0);
  }
  else {Failure;}
  /* See if the implied positions were OK. */
  for(d=MapMark+1;d<Dep->w.Needs;d++){
    w=Wd[d].Which;
    g=Wd[d].Deduced;
    if(Wd[d].Type==PositionS){
      /* We fill Taken as we go along, so as to detect clashes within
      the set.  That has to be backed out on misfit. */
      if(Problem) printf("\nOkRa %d",d);
      if(g<Ws[w].Lo) goto Misfit;
      if(Problem) printf("\nOkRb %d",d);
      if(g>Ws[w].Hi) goto Misfit;
      if(Problem) printf("\nOkRc %d",d);
      /* This could be giving up but... */
      if(Ws[w].MapHigh)
        if(2*g<Ws[w].Lo+Ws[w].Hi) goto Misfit;
      if(Problem) printf("\nOkRd %d",d);
      for(tt=g-Ws[w].HasExit;tt<g+Ws[w].Physical;tt++){
        if(tt>=Needed) goto Misfit;
        if(Taken[tt]) goto Misfit;
      }
      if(Problem) printf("\nOkT %d",d);
      for(tt=g-Ws[w].HasExit;tt<g+Ws[w].Physical;tt++) Taken[tt]=1+w;
    }
    if(Wd[d].Type==GapSize){
      if(Wm[w].Positive){
        if(Problem) printf("\nOkPa %d",d);
        if(g>Wm[w].GapMax || g<Wm[w].GapMin) goto Misfit;
        if(Problem) printf("\nOkPb %d",d);
      }
      else{
        /* We don't know the sign, but can do a test on the absolute. */
        /* If sign one way would work, assume its OK */
        /* However, still a problem if it needed to be one way for
        something in the section and the other way for something else. */
        if(Problem){ printf("\nOkAa %d",d);
          printf("\n%d %d %d %d %d %d",
            g,Wm[w].AbsMax,Wm[w].AbsMin,Wrap(-g),Wrap(-Wm[w].AbsMax),
            Wrap(-Wm[w].AbsMin));
        }
        if( (g>Wm[w].AbsMax || g<Wm[w].AbsMin)
          && (g<Wrap(-Wm[w].AbsMax) || g>Wrap(-Wm[w].AbsMin)) )
          goto Misfit;
        if(Problem) printf("\nOkAb %d",d);
      }
    }
  } /* d */
  /* Will taking this set lead to any 'additive' states? */
  for(d=MapMark;d<Dep->w.Needs;d++){
    if(Wd[d].Type==PositionS){
      w=Wd[d].Which;
      for(v=0;v<StatesCount;v++){
        if(v==w) continue;
        if(Ws[v].IsDecided){
          /* Anything this pair fixed was added to the list by Also.
           However, they can constrain without actually fixing. */
          /* Find where they are in the same section. */
          for(l=Ws[w].ChainL;l!=USHRT_MAX;l=Wg[l].ChainL){
            for(r=Ws[v].ChainR;r!=USHRT_MAX;r=Wg[r].ChainR){
            /* w on some left and v on some right. */
              if(Wg[l].N!=Wg[r].N) continue;
              f=Wg[l].N;/* The section they are in. */
              if(Wm[f].IsDecided) continue;/* Effect already propagated */
              ww=Wg[l].R;vv=Wg[r].L; /* Both {w^ww} & {vv^v} in section f. */
              printf("\n%d & %d mean (%d)+(%d) fixed.",
                w,v,ww,vv);
              if(!Map(PositionS,ww)) goto Misfit;
/* Nov 97. Making VALUE an atom led to state 70 just not being mapped.
Not sure what is happening but maybe following will do it. */
              if(!Map(PositionS,vv)) goto Misfit;
            }
          } /* l */
          for(l=Ws[v].ChainL;l!=USHRT_MAX;l=Wg[l].ChainL){
            for(r=Ws[w].ChainR;r!=USHRT_MAX;r=Wg[r].ChainR){
            /* v on some left and w on some right. */
              if(Wg[l].N!=Wg[r].N) continue;
              f=Wg[l].N;/* The section they are in. */
              if(Wm[f].IsDecided) continue;/* Effect already propagated */
              ww=Wg[r].L;vv=Wg[l].R; /* Both {ww^w} & {v^vv} in section f. */
              printf("\n%d & %d mean (%d)+(%d) fixed.",
                w,v,ww,vv);
              if(!Map(PositionS,ww)) goto Misfit;
              if(!Map(PositionS,vv)) goto Misfit;
            }
          } /* l */
        }
      } /* c */
    }
  } /* d */
  return Yes;
Misfit:;
  if(m){
    /* Printout cause of failure. */
    Failure; /* for now */
  }
  /* Back out of Taken. */
  for(e=MapMark;e<d;e++){
    if(Wd[e].Type==PositionS){
      w=Wd[e].Which;
      g=Wd[e].Deduced;
      for(tt=g-Ws[w].HasExit;tt<g+Ws[w].Physical;tt++) Taken[tt]=0;
    }
  }
  Undecided(MapMark); /* Turns off IsDecided. */
  return No;
} /* Consider */
static Bool RangeCut(void){
 /* Look at the constraints. We can only narrow them by raising Lo or
 lowering Hi. */
  Ushort f,c,l,r,ll,rr;
  Ushort GapMin,GapMax;
  short s;
  Bool m;
  for(;;){
    m=No;
    for(f=0;f<Gmp->w.Needs-1;f++){
      if(!Wm[f].Positive) continue;
      GapMin=Wm[f].GapMin;GapMax=Wm[f].GapMax;
      for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
        l=Wg[c].L;r=Wg[c].R;
        if(l>=AtomBreak) continue;
        if(Ws[l].IsDecided) continue; /* Assert r will be also */
        /* Can Hi of r be achieved? */
        s=Ws[l].Hi+GapMax-Ws[r].Hi;
        if(s<0){
          Ws[r].Hi+=s, m=Yes;/* Lower it. */
          printf("\nHi of %d to %d. %d^%d=%d max %d",r,Ws[r].Hi,l,r,GapMax,f);
          if(Ws[r].Hi<Ws[r].Lo) {
            RangeCutter=r;
            goto Fatal;
          }
        }
        /* Can Lo of r be achieved? */
        s=Ws[l].Lo+GapMin-Ws[r].Lo;
        if(s>0){
          Ws[r].Lo+=s, m=Yes;/* Raise it */
          printf("\nLo of %d to %d. %d^%d=%d min %d",r,Ws[r].Lo,l,r,GapMin,f);
          if(Ws[r].Hi<Ws[r].Lo) {
            RangeCutter=r;
            goto Fatal;
          }
        }
        /* Can Hi of l be achieved? */
        s=Ws[r].Hi-GapMin-Ws[l].Hi;
        if(s<0){
          Ws[l].Hi+=s, m=Yes;/* Lower it. */
          printf("\nHi of %d to %d. %d^%d=%d min %d",l,Ws[l].Hi,l,r,GapMin,f);
          if(Ws[l].Hi<Ws[l].Lo){
            RangeCutter=l;
            goto Fatal;
          }
        }
        /* Can Lo of l be achieved? */
        s=Ws[r].Lo-GapMax-Ws[l].Lo;
        if(s>0){
          Ws[l].Lo+=s, m=Yes;/* Raise it */
          printf("\nLo of %d to %d. %d^%d=%d max %d",l,Ws[l].Lo,l,r,GapMax,f);
          if(Ws[l].Hi<Ws[l].Lo) {
            RangeCutter=l;
            goto Fatal;
          }
        }
      }
    } /* f */
    if(!m) break;
  }
  return Yes;

Fatal:
  printf("\nFatal on range. %d",RangeCutter);
  return No;
} /* RangeCut */
static Ulong Merit(void){
  Ushort d,p,w;
  Ulong t;
  /* For judging what to guess at next. */
  /* The setup ones pose most logical problems, so they are early candidates.*/
  /* Ranked ones pose some logical problems, so they are early candidates.*/
  /* A choice which sets lots of positions is a good one. */
  /* But all this eventually over-ridden by doing most troublesome earlier. */
  t=0;
  for(d=0;d<Dep->w.Needs;d++){
    w=Wd[d].Which;
    if(Wd[d].Type==PositionS){
      p=(Ws[w].Physical + Ws[w].HasExit) * Ws[w].Difficulty;
      if(Ws[w].Setup) p=p*16;
      else if(Ws[w].Rank) p=p*4;
      t+=100*p;
    }
    if(Wd[d].Type==GapSize) t++;
  }
  return t;
}
static short FindGap(Ushort l,Ushort r){
  /* Is l^r already there? */
  Ushort c,d;
  for(c=Ws[l].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
    for(d=Ws[r].ChainR;d!=USHRT_MAX;d=Wg[d].ChainR){
      if(c==d){
        return Wg[c].N;
      }
    }
  }
  for(c=Ws[r].ChainL;c!=USHRT_MAX;c=Wg[c].ChainL){
    for(d=Ws[l].ChainR;d!=USHRT_MAX;d=Wg[d].ChainR){
      if(c==d){
        return -Wg[c].N-1; /* Avoid Zero problem */
      }
    }
  }
  return SHRT_MAX;
}
static void MakeSections(void){
  Ushort h,f,c,d,n;
/* Reorder the gap record so that equal gaps are adjacent.  Use another
wallet to record those sections. */
  printf("\n%d Unsorted Gaps",Gpp->w.Needs);
  /* Assert Wm[0].Lo==1 */
  Gmp->w.Needs=1;
  h=2;
  for(f=0;;f++){
    c=Wm[f].Lo;
    for(d=h;d<Gpp->w.Needs;d++){
      /* Look ahead for members of the same section (equal gap). */
      if(Wg[c].N==Wg[d].N){
        Wg[0]=Wg[h];/* Pick up unsorted. */
        Wg[h]=Wg[d];/* Move wanted to its place. */
        Wg[d]=Wg[0];/* Put unsorted back somewhere. */
        h++;
      }
    }
    /* This will have collected a whole section, and h indicates beginning
     of the next one. */
    n=Gmp->w.Needs++;WalletCheck(Gmp);
    Wm[n].Lo=h;
    if(h==Gpp->w.Needs) break;
  }
  printf("\n%d Sections of Gaps",Gmp->w.Needs-1);
  for(f=0;f<Gmp->w.Needs-1;f++){
    Wm[f].Sample=Wg[Wm[f].Lo].Sample;
    for(c=Wm[f].Lo;c<Wm[f+1].Lo;c++){
      Wg[c].N=f;/* Useful if eyeballing on Gpp */
    }
  } /* f */
/* Moving elements means the chains are no longer good. */
  Rechain();
}
static Ushort Remains; /* Share with ShowRefer */
static Bool StateShown; /* Share with ShowRefer */
static Bool WordStarted; /* Share with ShowRefer */
static void ShowState(Ushort j){
  Ushort k,g,t,q;
/*
This has to match assembler in order.  (But widths incidental)
 "Will it fit in field?" tests done by assembler.
ShiftRec record HasShift:1, ErrorAlone:1, CatFlag:1, HasKeys:1, Reference:1,
                Direct:1,Indexb:5, Index:5
ErrorRec record HasShiftOn:1, ErrorAloneOn:1, MajorField:8, MinorField:6
RedRec record HasShiftOff:1, HasAction:1, PruneCt:2, Rtype:2, Rstate:10
*/
  if(j==0) {
    ShowS("State0 equ 2*");
    ShowD(Ws[0].Decided);
    NewLine();
  }
  if(Ws[j].HasExit){
    ShowS(" word Action");
    ShowD(Ws[j].ExitNum);
#if 0
    ShowS("-R");
#endif
    NewLine();
  }
  StateShown=No;
  Remains=Ws[j].Physical;
  if(Ws[j].Error && Remains==1){
  /* Special case, whole state is an error. */
    Remains--;
    ShowS(" ErrorRec{1,1,");
    g=Ws[j].Error;
    ShowD(g/256);
    ShowS(",");
    ShowD(g%256);
    ShowS("};");
    SetColumn(40);ShowS("S");ShowD(j);ShowS("@");ShowD(Ws[j].Decided);
    StateShown=Yes;
    NewLine();
  }
  else if(!Ws[j].NoShift){
    Remains--;
    ShowS(" ShiftRec{1,0,");
    if(Ws[j].HasCat)
      ShowS("1,");   /* CatFlag */
    else
      ShowS("0,");
    ShowD(Ws[j].KeysOffset>0);
    ShowC(',0,');
    ShowD(Ws[j].StackPhysical);
    ShowC(',');
    if(Ws[j].Direct){
      ShowS("1,$");
      ShowD(Ws[j].AcceptValue);
    }
    else{
      ShowS("0,");
      ShowD(Ws[j].StateAccept);/* Bit will be moved to carry flag */
    }
    q=j;
    while(Ws[q].ArrayGone) q=Ws[q].ArraySame;
    ShowC(',');
    ShowD(Ws[q].ArraySame);/* ArraySame on !ArrayGone is array index. */
    ShowS("};");
    SetColumn(40);ShowS("S");ShowD(j);ShowS("@");ShowD(Ws[j].Decided);
    StateShown=Yes;
    NewLine();
    if(Ws[j].KeysOffset){
      Remains--;
      ShowS(" word Keys");
      ShowD(j);
      ShowS(";");  /* -R removed */
#if 0
      ShowS(" word Keys-1+");
#endif
      ShowD(Ws[j].KeysOffset);
      NewLine();
    }
    if(Ws[j].Error && Remains>0){
      Remains--;
      ShowS(" ErrorRec{1,1,");
      g=Ws[j].Error;
      ShowD(g/256);
      ShowS(",");
      ShowD(g%256);
      ShowC('}');
      NewLine();
    }
  } /* ShiftRec
  /* Now the reductions. */
  if(!Ws[j].NoRed){
    Ushort Sofar, Rtype, Rvalue;
    ShowS(" RedRec{0,");
    WordStarted=Yes;
    ShowD(Ws[j].ExitNum>0);
    ShowC(',');
    ShowD(Ws[j].Prune);
    ShowC(',');
    /* There may be equals tests. */
    if(Ws[j].IsSpecial){
      ShowRefer(j,Ws[j].SpecialK,0);
    }
    if(Ws[j].FilterHi){
      ShowRefer(j,Ws[j].ReZi,0);
    }
    if(Ws[j].Filter){
      ShowRefer(j,Ws[j].ReLo-1,0);
    }
    /* Now the ranking comparisons. */
    /* These will be greater-or-equal tests.  Different sections are known
    to be in the appropriate relation because of ranking.  I am setting up
    the tests on where states were actually mapped, rather than on rank limits.
    */
    Sofar=Ws[j].ReZi-1;
    /* Downwards to bottom limit of non-vectored. */
    for(k=Ws[j].ReZi-2;k>=Ws[j].VecReZi;k--){
      Ushort gg;
      if(Remains<2) break;
#if 0
        if(j==290){NewLine(); ShowS("Rem ");ShowD(Remains);}
#endif
      gg=Wp[Sofar].T;
      if(Wp[k].G!=Wp[k+1].G){
#if 0
        if(j==290){NewLine(); ShowS("bbb ");ShowD(j);ShowC(' ');
                   ShowD(Sofar);}
#endif
        ShowRefer(j,Sofar,1);
      }
      g=Wp[k].T;
      if(Ws[g].Decided<Ws[gg].Decided) Sofar=k;
    }
    /* An extra test if Arith after that. */
    /* July 2002.  Where does t for this come from? */
    if(Remains>1){
      ShowRefer(j,Sofar,1);
    }
    /* Now one word tests. */
    if(!Ws[j].DirectR) t=0;
    else{/* DirectR can mean direct target or subsetr. */
      if(Ws[j].SubsetR) t=1;
      else t=2;
    }
/* Nov 97.  Seem to have been getting away with making the last action
Arith rather than Direct because if only one (T,G) pair left either will
work. */
    if(Ws[j].VecReZi==Ws[j].ReLo) t=3;
    if(!WordStarted){
      ShowS(" RedRec{0,0,0,");
      WordStarted=Yes;
    }
    switch(t){
      case 0:ShowS("$ArithR,"); break;
      case 1:ShowS("$SubsetR,"); break;
      case 2:ShowS("$DirectR,"); break;
      case 3:ShowS("$DirectR,"); break;
    }
    if(t==0){
      k=Ws[j].Section;
      g=Wm[k].Decided;
      if(Wm[k].Inverted)
        ShowD(Wrap(Needed-g));
      else
        ShowD(g);
      ShowS("};");
    }
    else{
      if(t==1){
        g=Ws[j].SubsetOfR;
      }
      else{
        if(t==2) k=Ws[j].ReZi-1;
/* Part of same fix Nov 97 */
        else k=Ws[j].VecReZi;
        t=2;
        g=Wp[k].G;
      }
      k=Ws[g].Decided;
/* Complication for t=1, Subset, because target is not the state but the
reduction part of the state. */
      if(t==1) k=k+Ws[g].Physical-Ws[g].PhysicalR;
      ShowD(k);ShowS("}; S");ShowD(g);
    }
    if(!StateShown){
      SetColumn(40);ShowS("S");ShowD(j);ShowS("@");ShowD(Ws[j].Decided);
      StateShown=Yes;
    }
    NewLine();
    Remains--;
    if(Remains){
      printf("\n%d %d %d",j,Ws[j].Physical,Remains);Failure;
    }
  } /* Red testing. */
} /* ShowState */
static void ShowRefer(Ushort j, Ushort k, Ushort t){
  Ushort g;
#if 0
  if(j==128) printf("\nS128K %d",k);
#endif
  /* Complete two word test */
  if(!WordStarted)
    ShowS(" RedRec{0,0,0,");
  WordStarted=Yes;
  ShowS("$ReferR,");
  /* Thing to compare with Reference state */
  g=Wp[k].T;
  ShowD(Ws[g].Decided);
  ShowS("}; S");
  ShowD(g);
  if(!StateShown){
    SetColumn(40);ShowS("S");ShowD(j);ShowS("@");ShowD(Ws[j].Decided);
    StateShown=Yes;
  }
  NewLine();
  Remains--;
  g=Wp[k].G;
  ShowS(" RedRec{0,0,0,");
  /* Opcode: */
  if(t==0) ShowS("$EqTest");
  else     ShowS("$GeTest");
  ShowC(',');
  ShowD(Ws[g].Decided);  /* Place to go. */
  ShowS("}; S");
  ShowD(g);
  NewLine();
  Remains--;
  WordStarted=No;
}
