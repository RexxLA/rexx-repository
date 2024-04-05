/*------------------------------------------------------------------------------
ToDo - exercise spill, eg make it work for C syntax.
     - strip out the old experiments.

To find states of a grammar.

The grammar has been read in.  A dictionary of symbols is addressed by Dict and
an array Text represents the productions.  Positive elements in the array are
dictionary references, negative elements are operators.

1. Initialize

2. Check that this is a simple bnf, correct syntax with no <> etc.  ReadIn
   allowed an extended bnf.

3. Note which productions can be empty.

4. Record what terms and non-terminals start and follow others.

5. Develop indirect information from direct information.

6. Begin to develop states, assuming the grammar is LALR(1).

7. Process a state and note the states stemming from it.

8. Move the Caret forward one step, forming successor states.

9. Write out what will be input for further programs.

10. Show the states.

Model:  Statesp gets to states which has Gs and Cs components.
        Cs gives core set of 'positions in productions' for this state, closure
        of that gives full set.
        Gs say where to go from this state, in the form of Target for each
        different next token Discrim.
õ-----------------------------------------------------------------------------*/
static short *Tp, *TpZi; /* Text pointer and its fence.*/
static Symbol *LhsSym; /* Production being defined */
static Bool Stable; /* Used to iterate until things are stable. */
static Bool CanBeEmpty;
static Ushort MergeCount,PassCount;
static Ushort Num; /* From Sym->Num , compact indexing. */
static Ushort LhsNum;/* Number of production being defined */
static Offset Grammar; /* The root of the production tree. */
#define ProdLimit 208
#define ProdLimitPacked ((ProdLimit+7)/8)
#define TermLimit 256
#define TermLimitPacked ((TermLimit+7)/8)
#define BothLimitPacked (ProdLimitPacked+TermLimitPacked)
/* We need some arrays of packed bits. These are allocated dynamically. */
static char (*Starts)[1][BothLimitPacked];
#ifdef Followers
/* Followers are not much use since they or-together the followers in
different contexts.  In contrast, the Starters of a production are the
same wherever it is used. */
static char (*Follows)[1][BothLimitPacked];
static char (*LFollows)[1][ProdLimitPacked]; /* Last in RHS */
#endif
static char Ahead[TermLimitPacked];/* Not dynamic. Used to develop LookAhead */
static Ushort Aj; /* Index on Ahead type. */
static Bool Starting, Logic;
static Ushort ToDo; /* Count states yet to be processed. (Done=No)*/
static Bool Showing;
/* It is not portable to set one type in a union and read it in another
but we use that here to get comparison on a 4 byte structure by
overlaying a long. */
typedef
    union{
      long Overlay;
      struct{
        Offset Produ;
        Uchar Caret;   /* High order of long with little Endian. */
      }s;
    }Trick;
typedef struct{
  Wallet w; /* See Wal.h */
  struct{
    Trick u;
    char LookAhead[TermLimitPacked];
  }e[1];
} CoreSet;
typedef struct{
  Wallet w; /* See Wal.h */
  struct{
    Ushort Discrim; /* Num from Symbol table. */
    Ushort Target;
  }e[1];
} GotoSet;
typedef struct{
  Wallet w; /* See Wal.h */
  struct{
    unsigned Done:1;
    unsigned Conflict:1;
    unsigned MsgDoubt:1;
    unsigned MsgDead:1;
    unsigned PairKey:1;
    Ushort Gs;
    Ushort Cs;
  }e[1];
} StateSet;
static Offset Produ;
static Uchar Caret;
static Ushort Discrim;
static Ushort Target;
static StateSet * Statesp;
static CoreSet * Closure, *Coresp, *Coresp2;
static GotoSet * Gotosp;
static CoreSet * Coresp;
static Trick ThisCore; /* For copy of Overlay element */
static Ushort CsNum, CsNumX;
static Ushort GsNum; /* A GoSet number */
static Ushort Sj, Sj2; /* Cursor on Statesp */
static Ushort Sk; /* Cursor on Statesp */
static Ushort Ci; /* Cursor on CoreSet */
static Ushort Cj, Cj2; /* Cursor on CoreSet */
static Ushort Ck; /* Cursor on closure usually.*/
static Ushort Gj; /* Cursor on gotos */
static Ushort Gi; /* Cursor on gotos */
static Ushort SjGs; /* Number of GoSet for Sj state. */
static Ushort SjCs, Sj2Cs; /* Number of CoreSet for Sj state. */
/* The following defines are for various loops. */
/* Through the text. (Assumes Rhs loop inside) */
#define WhileProds Tp=Text->e+1;while(Tp<TpZi){Sym=SymNow();LhsSym=Sym;\
 LhsNum=LhsSym->Num;Tp+=2;
#define EndProds Tp++;} /* EndProds */
/* Through the Rhs of a production. */
#define WhileRhs while(*Tp>0){Sym=SymNow();
#define EndRhs Tp++;} /* EndRhs */
/* Through the states in the state set. */
#define WhileStates for(Sj=0;Sj<Statesp->w.Needs;Sj++){\
  SjGs=Statesp->e[Sj].Gs;\
  SjCs=Statesp->e[Sj].Cs;
#define EndStates } /* EndStates */
#define WhileClosure for(Ck=0;Ck<Closure->w.Needs;Ck++){
#define EndClosure }
#define WhileCores for(Cj=0;Cj<Coresp->w.Needs;Cj++){
#define EndCores }
#define WhileGotos for(Gj=0;Gj<Gotosp->w.Needs;Gj++){
#define EndGotos }
static Symbol * SymNow(void);
static void CloseIt(void);
static void CountProdu(Offset n); /* Readin has CountProd */
static void CountTerm(Offset n);
static Ushort EqualCs(Ushort);
static void States(void){
/*------------------------------------------------------------------------------
1. Initialize
õ-----------------------------------------------------------------------------*/
/* ReadIn counted the symbols. */
   if(TermCount>TermLimit){
     printf(Msg[4],TermLimit-1);
     longjmp(ErrSig,1);
   }
   if(ProdCount>ProdLimit){
     printf(Msg[5],ProdLimit-1);
     longjmp(ErrSig,1);
   }
 TpZi=&(Text->e[Text->w.Needs]);
/*------------------------------------------------------------------------------
2. Check that this is a simple bnf, correct syntax with no [] etc. (ReadIn
   allowed an extended bnf.) Do some counting as a by-product.
õ-----------------------------------------------------------------------------*/
/* Check the text. It should be all Lhs=Rhs...; sort. */
   Tp=Text->e;
   if(*Tp++!=Break) {
Bad:
       longjmp(ErrSig,11);
   }
ProdChk:
   if(*Tp<0) goto Bad;
   Sym=SymNow();
/* Remember first of any series with the same Lhs. */
/* Remember which was first production in order of appearence. */
   if(Grammar==0) Grammar=Sym->ProdPos;
   Tp++;
   if(*Tp++!=Assignment) goto Bad;
   while(*Tp>0) Tp++;  /* Skip identifiers and constants */
   if(*Tp++!=Break) goto Bad;
   if(Tp>TpZi)goto Bad;
   if(Tp<TpZi)goto ProdChk;
/* Do counting */
   TermCount=ProdCount=BothCount=0;
/* Go over the symbols with a walk rather than a scan, to get alpha order. */
   Walk(CountTerm);
/* We number the productions after the terminals so that Sym->Num can index
a bit strip applying to both productions and terminals. */
/* We will have an array so that we can go from number to symbol. */
   if((Num2Sym=malloc(BothCount*sizeof(Offset)))==NULL) Failure;
   Walk(CountProdu);/* Also fills Num2Sym */
   if(TermCount>TermLimit){
     printf(Msg[4],TermLimit-1);
     longjmp(ErrSig,1);
   }
   if(ProdCount>ProdLimit){
     printf(Msg[5],ProdLimit-1);
     longjmp(ErrSig,1);
   }
#if 0
/* Dump list for reference. */
   for(Num=0;Num<BothCount;Num++){
     Sym=SymLoc(*(Num2Sym+Num));
     if(Sym->Num!=Num) Failure;
     ShowD(Num);ShowC(' ');
     ShowA(Sym->s,Sym->SymbolLength);ShowC(' ');
   }
   NewLine();
#endif
/*------------------------------------------------------------------------------
3. Note which productions can be empty.
õ-----------------------------------------------------------------------------*/
/* It turns out that none are for the published 'C' grammar and no doubt we
could write Rexx grammar to have none.  But we would have to check anyway. */
  do{Stable=Yes;
  WhileProds;
/* If we find any alternative that makes it empty, we set dict flag. */
     CanBeEmpty=Yes; /* For this alternative. Until proved otherwise. */
     WhileRhs;
       if(Sym->CanBeEmpty==No) CanBeEmpty=No;
     EndRhs;
     if(CanBeEmpty){
       if(LhsSym->CanBeEmpty==No){
         Stable=No;LhsSym->CanBeEmpty=Yes;
       }
     }
  EndProds;
  } while(Stable==No);
/*------------------------------------------------------------------------------
4. Record what terms and non-terminals start and follow others.
õ-----------------------------------------------------------------------------*/
   if((Starts=calloc(ProdCount,BothLimitPacked))==NULL) Failure;
#ifdef Followers
   if((Follows=calloc(ProdCount,BothLimitPacked))==NULL) Failure;
   if((LFollows=calloc(ProdCount,ProdLimitPacked))==NULL) Failure;
#endif
 {
/* This is a text pass, to initialize the bit information. */
   WhileProds;
     Starting=Yes;
     /* Starting remains on while passing over CanBeEmptys. */
     WhileRhs;
       if(Starting){
/* This item on the Rhs is a possible start of the production on the Lhs. */
         SetFlag(Starts[LhsNum-TermCount][0],Sym->Num);
         if(!Sym->CanBeEmpty) Starting=No;
       }
     EndRhs;
/* We are looking beyond the last item on the Rhs.  */
#ifdef Followers
/* Here is the code that collects Follows info. */
/* We would need it if we wanted to see if the grammar was Simple LR since
then reduce-action only if current token is valid follower of the reduction
result. */
     Starting=Yes;
     {short *Xp;Symbol *XSym;Ushort XNum,j;
/* Scan backwards for pairings for Follows info. */
/* Starting remains on while passing over CanBeEmptys. */
       for(Xp=Tp-1;;Xp--){
         if(*Xp<0) break;
         XSym=SymLoc(*Xp);
         XNum=XSym->Num;
         if(XSym->Prod){
           if(Starting){
/* This production on the Lhs has followers that include those in the set for
the production on the Rhs. */
             SetFlag(LFollows[XNum-TermCount][0],LhsNum-TermCount);
             if(!XSym->CanBeEmpty) Starting=No;
           }
         }
         else{ /* Terminal */
           Starting=No;
         }
/* On the same pass, pick up immediate follower information */
/* Scan back over empties for this. */
         for(j=1;;j++){
           if(*(Xp-j)<0) break;
           Sym=SymLoc(*(Xp-j));
/* We don't need to know what follows terminals. */
           if(Sym->Prod)
             SetFlag(Follows[Sym->Num-TermCount][0],XNum);
           if(!Sym->CanBeEmpty) break;
         }
       } /* Xp */
     } /* The follow recording. */
#endif
   EndProds;
 }
/*------------------------------------------------------------------------------
5. Develop indirect information from direct information.
õ-----------------------------------------------------------------------------*/
{Ushort j,k;
/* If B was found to start A and C to start B then C can start A. */
/* This double loop is called Warshall's algorithm. */
  for(j=0;j<ProdCount;j++){
    for(k=0;k<ProdCount;k++){
      if(QryFlag(Starts[k][0],TermCount+j)){
        MemOr(Starts[k][0],Starts[j][0],sizeof(Starts[0]));
      }
    }
  }
#ifdef Followers
/* Similarly the followers. */
/* If production k follows production j then starters of k are followers
of j. */
  for(j=0;j<ProdCount;j++){
    for(k=0;k<ProdCount;k++){
      if(QryFlag(Follows[j][0],TermCount+k)){
        MemOr(Follows[j][0],Starts[k][0],sizeof(Follows[0]));
      }
    }
  }
/* Now transitive closure according to the LFollows. */
/* Overwrite the production part of the rectangular array with LFollows. */
  for(j=0;j<ProdCount;j++){
    for(k=0;k<ProdCount;k++){
      if(QryFlag(LFollows[j][0],k))
        SetFlag(Follows[j][0],TermCount+k);
      else
        OffFlag(Follows[j][0],TermCount+k);
    }
  }
/* And closure.*/
  for(j=0;j<ProdCount;j++){
    for(k=0;k<ProdCount;k++){
      if(QryFlag(Follows[k][0],TermCount+j)){
        MemOr(Follows[k][0],Follows[j][0],sizeof(Follows[0]));
      }
    }
  }
#endif
}
/*------------------------------------------------------------------------------
6. Begin to develop states, assuming the grammar is LALR(1).
õ-----------------------------------------------------------------------------*/
/* About practicalities.  We are unlikely to have enough memory for everything
from now on, so the extended Wallet mechanism is used to allow spill.  Most
things are wallets that have been compactly numbered.  Even those that are not
have to get their space with Wallet functions because of the competition
for space. */
/* August 92 - all spill is untested since even the C grammar didn't
blow memory. */
/* Ordinary wallets may shift about but will stay in memory.  For the
managed (numbered) wallets only one is guaranteed to be in at one time.
There are comments on the right of the code about which are relied on. */
/*                                                                     None  */
/* About parsing: */
/* When we have the cursor partway through the program during parsing we may not
know what production we are working through or how far through it we have
reached. So we have here to record all the possibilities (for all the possible
progress through the program). */
/* A CoreSet records a list (wallet) of productions and how far through
each of them. How far through is recorded as a caret-position.
Caret-position zero means about to scan the first thing on the Rhs,
caret-position one means about to scan the second thing on the Rhs and so on.
Also, for each (Prod, Caret-position) we note the LookAhead, a bitstrip
showing what terminals can come next.
*/
/* From a coreset we can work out what to do next, according to what
comes next in the program being parsed.  This is recorded in
a GotoSet. The elements in this Wallet are pairs (symbol,target) showing
where to progress to when particular things are consumed. */
/* The target is a new state, ie a new CoreSet and GotoSet. These states are
collected in the StateSet. Since CoreSets and GotoSets are Wallets, the
pointers from StateSets to them are best as wallet numbers. This allows for the
sets to have unstable addresses (and even to be spilled out of memory). */
/* The initial state set has just one state. */
   Statesp=WalletCalloc(sizeof(Wallet),1);
   Statesp->w.Needs=1;Statesp->w.Stride=sizeof(Statesp->e[1]);
   Statesp->w.Clear=Yes;
   Statesp=WalletEx((Wallet *)Statesp);
/* Its GoTo is nowhere.  Its coreset is parsing the root production. */
   Statesp->e[0].Cs=CsNum=WalletNew(sizeof(Closure->e[1]));
   (Coresp=(CoreSet *)Walletp(CsNum))->w.Clear=Yes;Coresp->w.Needs=1;
/*                                                                     CsNum */
   WalletSize(CsNum);Coresp=(CoreSet *)Walletp(CsNum);
   Coresp->e[0].u.s.Produ=Grammar;/* Caret and LookAhead zero */
/* The number of states in the set will increase as we work.  The number
of states we have processed will also increase.  The finish would be
the latter catches up with the former, except for a special case.
Occasionally we find that a state has to be reprocessed. We handle this
using a Done flag for each state, and a counter. */
   ToDo=1; /* The one we just initialized is to be processed. */
   while(ToDo>0){
     PassCount++;
     if(MergeCount) printf(Msg[9],MergeCount);
     MergeCount=0;
   WhileStates;
/*------------------------------------------------------------------------------
7. Process a state and note the states stemming from it.
õ-----------------------------------------------------------------------------*/
     if((Sj+1)%100==0) printf(Msg[6],Sj+1,ToDo);
     if(Statesp->e[Sj].Done) continue; /* Has been done on prior pass. */
     Statesp->e[Sj].Done=Yes; /* Or at least it will be. */
     ToDo--;
/* An element of a core set may have a caret ahead of a production. So that
element also represents (indirectly) an element with that production and
caret-position zero.  Taking direct and indirect together gives us the
'closure'.  For each State we make the closure but it isn't kept, only
used transiently to deduce new states. */
/* Note that Closure is an ordinary wallet, kept in memory. */
     CloseIt();
/*                                                                      None */
/* Now we divide up the full set of possibilities according to what follows
the caret. Each of the parts from that division corresponds to moving
the caret over a particular terminal or non-terminal. */
     GsNum=0;
     WhileClosure;
/* Compute where this position in this production corresponds to in the text.*/
      Produ=Closure->e[Ck].u.s.Produ;
      Caret=Closure->e[Ck].u.s.Caret;
      Tp = Text->e + (Produ + 2 + Caret);
/* If the caret position is off the end of the production then there is
no more to say - the production will have been recognised. */
      if(*Tp>0){
        Sym=SymNow();Num=Sym->Num;
/* Allocate a GotoSet if we haven't done so already. */
        if(GsNum==0) GsNum=WalletNew(sizeof(Gotosp->e[1]));
/* Look for this symbol in it. */
/* GotoSet is sorted, mostly for the benefit of the human-readable. */
        Gotosp=(GotoSet *)Walletr(GsNum);
/*                                                                     GsNum */
        WhileGotos;
          if(Gotosp->e[Gj].Discrim==Num){
            CsNum=Gotosp->e[Gj].Target;
            goto HaveDiscrim;
          }
          if(Gotosp->e[Gj].Discrim>Num) break;
        EndGotos;
/* Symbol not found, add it to the GotoSet and make a target. */
        (Gi=Gotosp->w.Needs++);WalletSize(GsNum);
        Gotosp=(GotoSet *)Walletr(GsNum);
/*                                                                     GsNum */
/* Open a space for this to be slotted in sorted. */
        if(Gi!=Gj){
   memmove(&(Gotosp->e[Gj+1]),&(Gotosp->e[Gj]),(Gi-Gj)*sizeof(Gotosp->e[1]));
        }
/* Take an object for the target set. It may prove to be equal to one
we already have, in which case it will be deleted later. */
/* April 94.  Try going 'nowhere' on messages. Would be change all around. */
     if(Sym->IsMsg) CsNum=0;
     else{
        CsNum=WalletNew(sizeof(Closure->e[1]));
        Coresp=(CoreSet *)Walletp(CsNum);
/*                                                                     CsNum */
        Coresp->w.Clear=Yes;
     }
        Gotosp=(GotoSet *)Walletp(GsNum);
/*                                                                     GsNum */
        Gotosp->e[Gj].Discrim=Num;
        Gotosp->e[Gj].Target=CsNum;
HaveDiscrim:;
/* Items in the CoreSet are sorted, for easier detection of duplicates. */
      if(CsNum==0) goto IsThere;
        ThisCore.s.Produ=Produ;
        ThisCore.s.Caret=(Uchar)(Caret+1);
        Coresp=(CoreSet *)Walletr(CsNum);
/*                                                                     CsNum */
        WhileCores;
          if(Coresp->e[Cj].u.Overlay==ThisCore.Overlay) goto IsThere;
          if(Coresp->e[Cj].u.Overlay>ThisCore.Overlay) break;
        EndCores;
        Ci=Coresp->w.Needs++;WalletSize(CsNum);
        Coresp=(CoreSet *)Walletp(CsNum);
/*                                                                     CsNum */
/* Open a space for this to be slotted in sorted. */
        if(Ci!=Cj){
    memmove(&(Coresp->e[Cj+1]),&(Coresp->e[Cj]),(Ci-Cj)*sizeof(Coresp->e[1]));
        }
        Coresp->e[Cj].u.Overlay=ThisCore.Overlay;
        Assign(Coresp->e[Cj].LookAhead,Closure->e[Ck].LookAhead);
IsThere:;
      }
     EndClosure;
/* At this point the closure has been split up to make a GotoSet and a
number of CoreSets. It is finished with. */
     free(Closure);Closure=NULL;
/*------------------------------------------------------------------------------
8. Move the Caret forward one step, forming successor states.
õ-----------------------------------------------------------------------------*/
/* Determine whether the CoreSets just created are the same as ones we had
before. */
/* Also change the GotoSet from Targetting at CoreSets to Targetting at
states with that CoreSet. */
 if(GsNum){
   Gotosp=(GotoSet *)Walletp(GsNum);
/*                                                                     GsNum */
   WhileGotos;
     CsNum=Gotosp->e[Gj].Target;
     if(CsNum==0) continue;
/* This CsNum may be a set that we have had before. */
     for(Sk=0;Sk<Statesp->w.Needs;Sk++){
      if(EqualCs((CsNumX=Statesp->e[Sk].Cs))) goto HaveCs;
/*                                                                      None */
      Gotosp=(GotoSet *)Walletr(GsNum);
/*                                                                     GsNum */
     }
/* Its new, we will have to process it later. */
   Sk=Statesp->w.Needs++;Statesp=(StateSet *)WalletEx((Wallet *)Statesp);
   ToDo++;
   if(PassCount>1){
     Failure;
   }
/*                                                                      None */
   Statesp->e[Sk].Cs=CsNum;
   goto EndG;
HaveCs:;
/* Merge the two sets of LookAheads into the one found. (CsNumX) */
   Logic=No;
   Coresp=(CoreSet *)Walletr(CsNum);
/*                                                                     CsNum */
  WhileCores;
   Assign(Ahead,Coresp->e[Cj].LookAhead);
   Coresp=(CoreSet *)Walletr(CsNumX);
/*                                                                     CsNumX*/
/* OR the LookAheads. */
   MemOr(Ahead,Coresp->e[Cj].LookAhead,sizeof(Ahead));
/* Check for enlargment of LookAhead. */
   if(memcmp(Ahead,Coresp->e[Cj].LookAhead,sizeof(Ahead))){
     Assign(Coresp->e[Cj].LookAhead,Ahead);
     Logic=Yes;
   }
   Coresp=(CoreSet *)Walletr(CsNum);
/*                                                                     CsNum */
  EndCores;
   WalletDel(CsNum);
/* If there was any enlargement of LookAheads we may need to go back and
re-process the state in case enlargement propagates. */
   if(Logic && Statesp->e[Sk].Done ){
     Statesp->e[Sk].Done=No;ToDo++;MergeCount++;
/* Easiest if Gs remade next pass. */
     if(Statesp->e[Sk].Gs){
        WalletDel(Statesp->e[Sk].Gs);
        Statesp->e[Sk].Gs=0;
     }
     if(PassCount>1){
       Logic=No;
     }
   }
EndG:Gotosp=(GotoSet *)Walletp(GsNum);
/*                                                                     GsNum */
   Gotosp->e[Gj].Target=Sk;
   EndGotos;
 } /* Was GsNum */
   Statesp->e[Sj].Gs=GsNum;
   if(ToDo==0) break;
   EndStates;
   printf(Msg[7],Statesp->w.Needs);
   } /* while ToDo */
/*------------------------------------------------------------------------------
9. Write out what will be input for further programs.
õ-----------------------------------------------------------------------------*/
/* We execute this for side effects even when numbers not requested. */
{long CheckSum;
   Ushort ConflictCount;
   Ushort Reduces,Msgs,k;
/* Act will record what actions.  Shifts will encoded as the state shifted
to plus one.  Reductions as ProdPos negatively. */
   short Act[ProdLimit+TermLimit];
   Ushort ActCount;
   ActCount=0;ConflictCount=0;
/* Used to be # but that is MAKE comment delimiter. */
   Showing=No;if(strchr(Switches,'S')) Showing=Yes;
   if(Showing){
     printf(Msg[10]);
     CheckSum=0;
     for(Tp=Text->e;Tp<TpZi;Tp++){
/* This gave different answers on C++ and C600     CheckSum+=*Tp;
Perhaps an explicit casting will help. */
/* No, that didn't help. Lets print them all. */
       CheckSum+=(long)*Tp;
/*       printf("\n%ld ",CheckSum); Turned out to be alignment in structures.*/
     }
     ShowL(CheckSum);ShowC(' ');
     ShowD(Statesp->w.Needs);ShowC(' ');
   }
/* Show the strict AHead information. */
/* Ordinarily the LookAhead means what is inherited from constructs above this
one as well as the lookahead for this construct.  But here we are not including
those, we are just recording for this actual coreset. */
   WhileStates;
     Clear(Ahead);
     Coresp=(CoreSet *)Walletp(SjCs);
     WhileCores;
       Produ=Coresp->e[Cj].u.s.Produ;
       Caret=Coresp->e[Cj].u.s.Caret;
       Tp = Text->e + (Produ + 2 + Caret);
/* Compute where this position in this production corresponds to in the text.*/
/* Do nothing if off the end of the production. */
       if(*Tp>0){
         Sym=SymNow();
         if(Sym->Prod){
           Tp++;
           WhileRhs; /* Scan remainder of the production already in Closure. */
             if(Sym->Prod){
/* Absorb all starts from a production. */
               MemOr(Ahead,Starts[Sym->Num-TermCount][0],sizeof(Ahead));
               if(!Sym->CanBeEmpty) break;
             }
             else{
               SetFlag(Ahead,Sym->Num);break;
             }
           EndRhs;
         } /* Stepover Prod */
       } /* Not off */
/* Here if all the rest of the production could be empty. */
     EndCores;
     for(k=0;k<TermCount;k++){
       if(QryFlag(Ahead,k)){
/* We only care about keywords */
         Sym=SymLoc(*(Num2Sym+k));
         if(Sym->s[0]=='\'' && Sym->s[1]>='a' && Sym->s[1]<='z'){
           ShowD(Sj);ShowC(' ');
           ShowD(k);ShowC(' ');
         }
       }
     }
   EndStates;
   ShowS("0 0 ");
/* Write the actions for each state.  */
   WhileStates;
     Reduces=0;Msgs=0;
     Clear(Act);
/* We have to make the closure to cover the remote chance that something
added in the closure is also an empty production, immediately completed. */
     CloseIt();
/* There may be more than one reduction, provided they have distinct
terminals in the LookAheads. */
     WhileClosure;
/* Compute where this position in this production corresponds to in the text.*/
      Produ=Closure->e[Ck].u.s.Produ;
      Caret=Closure->e[Ck].u.s.Caret;
      Tp = Text->e + (Produ + 2 + Caret);
/* If the caret position is off the end of the production then
the production will have been recognised. */
      if(*Tp<0){
        Tp=Text->e + Produ;Sym=SymNow();
        for(Aj=0;Aj<TermCount;Aj++){
          if(QryFlag(Closure->e[Ck].LookAhead,Aj)){
            if(Act[Aj]){
              Statesp->e[Sj].Conflict=Yes;
              ConflictCount++;
            }
            else{Act[Aj]=-Produ;ActCount++;Reduces++;}
          }
        }
      }
     EndClosure;
     free(Closure);
/* The shifts we get from GotoSet. */
 if(SjGs){
   Gotosp=(GotoSet *)Walletr(SjGs);
/*                                                                     GsNum */
   WhileGotos;
        Num=Gotosp->e[Gj].Discrim;
        Target=Gotosp->e[Gj].Target;
/* Flag the state if any shift is on a keyword. */
        Sym=SymLoc(*(Num2Sym+Num));
        if(Sym->s[0]=='\'' && Sym->s[1]>='a' && Sym->s[1]<='z')
          Statesp->e[Sj].PairKey=Yes;
        if(Act[Num]){
          Act[Num]=1+Target;/* Resolve in favour of shift. */
          if(!Sym->IsMsg){
            Statesp->e[Sj].Conflict=Yes; /* Flag as conflict */
            ConflictCount++;
          }
        }
        else{
          Act[Num]=1+Target;ActCount++;
          if(Sym->IsMsg) Msgs++;
        }
/* Assert Target not zero here. */
   EndGotos;
 }
/* If interested in error Msgs... */
/* There should be just one thing in the shifts list that produces an
error message. */
   if(MsgFlag&&Reduces==0&&Msgs!=1)
              Statesp->e[Sj].MsgDoubt=Yes;
   if(MsgFlag&&Reduces>0 && Msgs>0)
              Statesp->e[Sj].MsgDead=Yes;
/* Write the actions we recorded. */
   if(Showing){
    ShowD(ActCount);
    ShowC(' ');
    for(Num=0;Num<BothCount;Num++){
      if(Act[Num]){
        ShowD(Num);ShowC(' ');
        ShowD(Act[Num]);ShowC(' ');
        ActCount--;
      }
    }
    if(ActCount) Failure;
   }
   EndStates;
  printf(Msg[8],ConflictCount);
}
/*------------------------------------------------------------------------------
10. Show the states.
õ-----------------------------------------------------------------------------*/
/* Dictionary pass to show these emptys. */
   NewLine();ShowS("Productions that can be empty( ");
   WhileSym;
     if(Sym->CanBeEmpty){
       ShowA(Sym->s,Sym->SymbolLength);ShowC(' ');
     }
   EndSym;
   ShowC(')');NewLine();
   if(strchr(Switches,'B')){
/* Show the Starters */
      Ushort j,k;
       NewLine();
       ShowS("Can be at the start, for each nonterminal:");
       for(j=0;j<ProdCount;j++){
         Sym=SymLoc(*(Num2Sym+TermCount+j));
         SetMargin(1);
         NewLine();
         ShowA(Sym->s,Sym->SymbolLength);ShowC(':');
         SetMargin(5);
         NewLine();
         for(k=0;k<BothCount;k++){
           if(QryFlag(Starts[j][0],k)){
             Sym=SymLoc(*(Num2Sym+k));
             ShowA(Sym->s,Sym->SymbolLength);ShowC(' ');
           }
         }
       }
   }
/* And the actual States. */
  SetMargin(1);NewLine();
  WhileStates;
   Showing=Yes;if(strchr(Switches,'C')) Showing=No;
   if(Statesp->e[Sj].Conflict) Showing=Yes;
   if(Statesp->e[Sj].MsgDoubt) Showing=Yes;
   if(Statesp->e[Sj].MsgDead) Showing=Yes;
   if(Showing){ShowS("State number ");ShowD(Sj);}
   if(Statesp->e[Sj].Conflict) ShowS(" Conflict!!");
   if(Statesp->e[Sj].MsgDoubt) ShowS(" Msgs!!");
#if 0
   /* Not really helpful since choice of reduce/shift msg in tablemaker. */
   if(Statesp->e[Sj].MsgDead) ShowS(" MsgDead!!");
#endif
   SetMargin(2);
   Coresp=(CoreSet *)Walletr(SjCs);
   ToDo=Coresp->w.Needs; /* Reuse of ToDo */
/*                                                                      SjCs */
/* We have to make the closure to cover the remote chance that something
added in the closure is also an empty production, immediately completed. */
     CloseIt();
   WhileClosure;
   {  short * TpC;
      Produ=Closure->e[Ck].u.s.Produ;
      Caret=Closure->e[Ck].u.s.Caret;
      Tp = Text->e + Produ;TpC=Tp+Caret+2;
/* Show it if it is in the core or is a reduction.  */
    if(Showing)
      if(Ck<ToDo || *TpC<0){
        NewLine();
        Sym=SymNow();
        if(Sym->Hatch) ShowC('#');
        ShowA(Sym->s,Sym->SymbolLength);ShowS("=");
        Tp+=2;
        WhileRhs;
         if(Tp==TpC) ShowC('^');
         Sym=SymNow();
         ShowA(Sym->s,Sym->SymbolLength);ShowC(' ');
        EndRhs;
        Logic=No;
        if(Tp==TpC){
/* This is a completion, the LookAhead matters. */
          Logic=Yes;
          ShowC('^');
        }
/* No need to show reduction aheads if this is reduction only state. */
        if((Logic && SjGs) || Statesp->e[Sj].Conflict){
/* Show the Lookaheads. */
          NewLine();ShowC('(');
          for(Aj=0;Aj<TermCount;Aj++){
            if(QryFlag(Closure->e[Ck].LookAhead,Aj)){
              Sym=SymLoc(*(Num2Sym+Aj));
              ShowA(Sym->s,Sym->SymbolLength);ShowC(' ');
            }
          }
          ShowC(')');
        }
      } /* Showing one */
   }
   EndClosure;
   free(Closure);
   if(Showing){
     if(SjGs){
       SetMargin(10);NewLine();
       Gotosp=(GotoSet *)Walletr(SjGs);
/*                                                                      SjGs */
       WhileGotos;
          Num=Gotosp->e[Gj].Discrim;
          Target=Gotosp->e[Gj].Target;
          Sym=SymLoc(*(Num2Sym+Num));
          ShowA(Sym->s,Sym->SymbolLength);ShowS("=>");
          ShowD(Target);ShowC(' ');
       EndGotos;
     }
     SetMargin(1);NewLine();
   }
  EndStates;
};/* States */
/*------------------------------------------------------------------------------
  Routine to compare CoreSets CsNum and given argument.
õ-----------------------------------------------------------------------------*/
static Ushort EqualCs(Ushort c){
/* If we were doing the grammar as LR, rather than LALR, then we would
match LookAheads as well. */
/* If we were spilling a lot it would pay to have a hash value kept in
memory most comparisons could fail without bringing coreset back from disk. */
  Ushort n;
  long m;
  Coresp=(CoreSet *)Walletr(CsNum);n=Coresp->w.Needs;
/*                                                                     CsNum */
  Coresp=(CoreSet *)Walletr(c);
/*                                                                         c */
/* Differ if different number of elements */
  if(n!=Coresp->w.Needs) return 0;
/* Differ if an element differs. */
  WhileCores;
   m=Coresp->e[Cj].u.Overlay;
   Coresp=(CoreSet *)Walletr(CsNum);
/*                                                                     CsNum */
   if(m!=Coresp->e[Cj].u.Overlay) return 0;
   Coresp=(CoreSet *)Walletr(c);
/*                                                                         c */
  EndCores;
  return 1;
}
/*------------------------------------------------------------------------------
   Routine to develop a closure.
õ-----------------------------------------------------------------------------*/
static void CloseIt(void){
        Symbol * SubjSym;
        Offset  SubjOff;
        Bool Logic;
/* What we have is some Caret positions within productions. We can work out
all the possibilities for what comes after the caret position. */
/* We are going to develop a set in Closure, starting with a copy of
what Sj has. */
/* The closure is used and deleted outside this routine. */
  Closure=WalletCalloc(sizeof(Wallet),1);
/*                                                                      None */
  Closure->w.Needs=Walletr(SjCs)->Needs;
/*                                                                      SjCs */
  Closure->w.Stride=sizeof(Closure->e[1]);
  Closure->w.Clear=Yes;
  Closure=(CoreSet *)WalletEx((Wallet *)Closure);
/*                                                                      None */
  Coresp=(CoreSet *)Walletr(SjCs);
/*                                                                      SjCs */
  for(Cj=0;Cj<Coresp->w.Needs;Cj++){
    Closure->e[Cj]=Coresp->e[Cj];
  }
/* Add the indirects, ie where the caret is ahead of something, we add the
something (with the caret position zero, that is before the start of it). */
   WhileClosure;
Rework:;/* May need to reduce Ck and come back here. */
    Clear(Ahead);
/* Compute where this position in this production corresponds to in the text.*/
    Tp = Text->e + (Closure->e[Ck].u.s.Produ + 2 + Closure->e[Ck].u.s.Caret);
/* We could be off the end of the production. */
    if(*Tp<0) Logic=No;else {
      Logic=Yes;Sym=SymNow();
    }
/* If the thing at that position is terminal that it cannot add to closure. */
    if(Logic && Sym->Prod){
      SubjSym=Sym;SubjOff=*Tp;Tp++;
/* We are going to add productions of this symbol, and will scan to
find what can follow that non-terminal. */
      WhileRhs; /* Scan remainder of the production already in Closure. */
        if(!Sym->Prod){
/* Note that this terminal is a possible 'lookahead' of the thing that we are
going to add to the closure. */
          SetFlag(Ahead,Sym->Num);goto SkipRest;
        }
        else{
/* Absorb all starts from a production. */
          MemOr(Ahead,Starts[Sym->Num-TermCount][0],sizeof(Ahead));
          if(!Sym->CanBeEmpty) goto SkipRest;
        }
      EndRhs;
/* Here if all the rest of the production could be empty.  Inherit the
Starts. */
      MemOr(Ahead,Closure->e[Ck].LookAhead,sizeof(Ahead));
SkipRest:;
/* Each of the productions with the same relevant Lhs is to be added
to the Closure. */
      Tp=Text->e + SubjSym->ProdPos;
      while((Offset)(*Tp)==SubjOff){
        ThisCore.s.Produ=Tp-Text->e;
        ThisCore.s.Caret=0;
/* Is it already in our closure? */
/* Note WhileClosure doesn't nest. */
        for(Cj=0;Cj<Closure->w.Needs;Cj++){
         if(Closure->e[Cj].u.Overlay==ThisCore.Overlay){
/* Union the lookaheads. */
          MemOr(Ahead,Closure->e[Cj].LookAhead,sizeof(Ahead));
          if(memcmp(Ahead,Closure->e[Cj].LookAhead,sizeof(Ahead))){
            Assign(Closure->e[Cj].LookAhead,Ahead);
/* It has enlarged. Need to worry about what propagated from it. */
/* No worry if we haven't started making from it yet. */
            if(Cj<=Ck){
              Ck=Cj;goto Rework;
            }
          }
          goto NoAddp;
         }
        }
/* Not there already so add. */
        (Cj=(Closure->w.Needs++));Closure=WalletEx((Wallet *)Closure);
        Closure->e[Cj].u.Overlay=ThisCore.Overlay;
        Assign(Closure->e[Cj].LookAhead,Ahead);
NoAddp:
/* Advance to next. */
        Tp+=2; /* Past the assignment */
        while(*Tp>0) Tp++;Tp++;
/* That has got us past the semicolon. */
        if(Tp==TpZi) break;
      } /* Loop to next production with same Lhs. */
    } /* Was a production after caret. */
  EndClosure;
} /* CloseIt */
/*------------------------------------------------------------------------------
Routine CountProdu to number productions
õ-----------------------------------------------------------------------------*/
static void CountProdu(Offset n){
  Symbol *Sym;
  Sym=(Symbol*)(WalkBase+n);
  if(Sym->Prod) Sym->Num=TermCount+ProdCount++;
  /* Note all symbols in index. */
  *(Num2Sym+Sym->Num)=(char *)Sym-WalkBase;
} /* CountProdu */
/*------------------------------------------------------------------------------
Routine CountTerm to number terminals
õ-----------------------------------------------------------------------------*/
static void CountTerm(Offset n){
  Symbol *Sym;
  Sym=(Symbol*)(WalkBase+n);
     BothCount++;
     if(!Sym->Prod){
       Sym->Num=TermCount++;
       if(memcmp(Sym->s,"Msg",3)==0){MsgFlag=Yes;Sym->IsMsg=Yes;}
     }
} /* CountTerm */
/*------------------------------------------------------------------------------
Routine to gather info from text element.
õ-----------------------------------------------------------------------------*/
static Symbol * SymNow(void){
/* Get more info on text element. */
 if(*Tp<0) {
Failure;/* Check that it is Dict pointer. */
 }
 return SymLoc(*Tp);
} /* SymNow */
