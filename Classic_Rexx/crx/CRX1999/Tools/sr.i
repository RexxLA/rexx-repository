/*------------------------------------------------------------------------------
To make 'C' structures that record STATES output.
15 Feb 96. Change to 32 bit version, with lots more function.
'C' as output not maintained, except for keyword table that goes with MSGC.

The grammar has been read in.  A dictionary of symbols is addressed by Dict and
an array Text represents the productions.  Positive elements in the array are
dictionary references, negative elements are operators.

1. Initialize

2. Check that first number on the second argument is the same as the Checksum.

3. Read Aheads information.

4. Read each state.

Any conflicts of shift reduce, or what msg to produce, are resolved.

At this stage the switch lists show switches on both atoms and non-atoms.
To make them fit the Aoe method, the non-atoms in the switches go away,
and reductions dependent on the stack are introduced.

5. Note which shifted from.

6. Process reductions to switchlists.

7. Make the reduce switch for state Sj.
   By iterating back on the Froms, the top-of-stack after reduction is deduced.

8. Shorten switch-switches now that only atoms matter.

9. Look to eliminate states that are effectively the same as others.

10. Work on reduction switches.

   We record a lot of stuff that might have helped encode the reduce switch
   using shift&mask but in practice there aren't enough bits in a state
   number for that to work. (At least with originals it didn't work.)

11. Minimise the token set.

12. Write out to the next stage, via Stdout.

13. Routine PrintStates.

14. Routine ScanProduction

15. Routine Keywords.  Constructs the keyword table.

16. Routine MsgChoice

17. Routines EnList Differ AddRedSw

õ-----------------------------------------------------------------------------*/
char * Names[]={
   "","Eos",
   "%","Percent",
   "*","Mul",
   "/","Div",
   "//","Rem",
   "(","Lparen",
   ")","Rparen",
   "-","Minus",
   "+","Plus",
   "\\","Not",  /* Escaped */
   "||","Cat",
   " ","Abut",
   "$","Assign",
   "|","Or",
   "&&","Xor",
   "&","And",
   "**","Power",
   ",","Comma",
   ".","Dot",
   ";","Semi",
   "<" ,"Lt",
   "<<" ,"Slt",
   "<<=" ,"Sle",
   "<=" ,"Le",
   "==" ,"Seq",
   ">" ,"Gt",
   ">=" ,"Ge",
   ">>" ,"Sgt",
   ">>=" ,"Sge",
   "\\=" ,"Ne",   /* Escaped */
   "\\==" ,"Sne",  /* Escaped */
   "=" ,"Eq" };
struct MsgRec{
   Uchar Major;
   Uchar Minor;
   char *Guts;
};/* struct */
#define MajMin(m,n) (256*m+n)
static short *Tp, *TpZi; /* Text pointer and its fence.*/
static short *Tpx;
static Ushort StatesCount;
static Ushort AtomsCount,ACwas; /* Excludes messages. */
static Ushort TotalInSw;
static Ushort Sj,Sj2; /* Counts to StatesCount */
static Ushort Sk,Sr,Sr2; /* Counts to SwitchCount, usually. */
static Ushort SwitchCount;
static Ushort Anchor;
static Ushort Bytes, Bytes2;
static short Trigger,Goto;
/* 288 for classic */
#define TriggerZi 384
static Bool DropTrigger[TriggerZi];
static Bool Logic,First;
static Bool OuterLogic;
static Ushort LoopGuard;
static Ushort j1,j2,k1,k2;
static Ushort j,k;
static Ushort LowKey;
static char * s;
/* 480 for Classic */
#define StatesZi 800
#define SpareStates 40
/* 65 for classic */
#define Strip 100  /* cf StatesZi (TriggerZi should be less than StatesZi) */
static char Different[StatesZi] [Strip];  /* On if differ. */
static char InList[StatesZi] [Strip];  /* On if sub judice */
static char Decided[StatesZi] [Strip];  /* On when decided */
static char RedSwPair[StatesZi] [Strip];  /* On when decided */
static Ushort Renum[StatesZi];
static Ushort RenumAtom[TriggerZi];
static void Differ(Ushort j, Ushort j2);
static Ushort MaxMap;
static Ushort NumBy;
static Ushort NumFor;
static Ushort NumThen;
static Ushort NumTo;
static Ushort NumUntil;
static Ushort NumWhile;
static Ushort NumWith;
static Ushort NumInput;
static Ushort NumOutput;
static char * KeyBy = "'BY'";
static char * KeyFor = "'FOR'";
static char * KeyThen = "'THEN'";
static char * KeyWhen = "'WHEN'";
static char * KeyTo = "'TO'";
static char * KeyUntil = "'UNTIL'";
static char * KeyWhile = "'WHILE'";
static char * KeyWith = "'WITH'";
static char * KeyInput = "'INPUT'";
static char * KeyOutput = "'OUTPUT'";
static char * KeyValue = "'VALUE'";
static char * KeyVersion = "'VERSION'";
static char * KeyOtherwise = "'OTHERWISE'";
static char * KeyIterate = "'ITERATE'";
static char * KeyLeave = "'LEAVE'";
static char * KeyAddress = "'ADDRESS'";
static char * KeyForm = "'FORM'";
static char * KeyElse = "'ELSE'";
static char * KeySignal = "'SIGNAL'";
static char * KeyTrace = "'TRACE'";
static char * KeyParse = "'PARSE'";
static char * KeyName = "'NAME'";
static char * KeyCall = "'CALL'";
static char * KeyDo = "'DO'";
static char * KeyIf = "'IF'";
static char * KeyEnd = "'END'";
static char * KeyVarSymbol = "VAR_SYMBOL";
static char * Expr_Alias = "expr_alias";
#define SwitchLimit 256
#define SpareStates 40
static Ushort SparesLeft;
static Ushort StatesBound;
static jmp_buf DifferSig;
struct StStruc{
  struct{
    unsigned HasBy:1;
    unsigned HasFor:1;
    unsigned HasThen:1;
    unsigned HasTo:1;
    unsigned HasUntil:1;
    unsigned HasWhile:1;
    unsigned HasWith:1;
    unsigned HasInput:1;
    unsigned HasOutput:1;
    unsigned HasPad:7;  /* Make it 16 bits for illegal overlay. */
  } f;
  unsigned ShiftEntry:1;/* Can be entered on shift */
  unsigned Self:1;/* Can transit to self? */
  unsigned RedEnd:1;/* Has END as reduction trigger. */
  unsigned ShiftVar:1;/* Has VAR_SYMBOL as shift trigger. */
  unsigned ShiftExp:1;/* Has expression as shift trigger. */
  unsigned IsRanked:1;
  unsigned SwapDone:1;
  unsigned ReduceJoin:1;
  unsigned Careful:1;
  unsigned HasCat:1;
  unsigned Valued:1;  /* State where VALUE implied. */
  unsigned Versioned:1;  /* State where VALUE implied. */
  unsigned AboveAction:1;  /* State on stack when exit. */
  Ushort Work;    /* Temp during algorithms */
  Ushort Chain;   /* Temp during algorithms */
  Ushort Flatten; /* Bits masked when switching. */
  Ushort StackPhysical; /* Words required on stack. */
  Ushort *RedSw;  /* Switch for general reduce. */
  Ushort RedSwCt,RedSwCt2;
  Ushort Ref1;     /* Default state for reduce-to. */
  Ushort Red1,Red2; /* Alternative new states for a reduce. */
  Ushort FromsLo;  /* To section of states that shift to this. */
  Ushort FromsZi;
  Ushort Kws;  /* Place in StKey to count length of keyword list. */
  Ushort Kwr;
  Ushort Maps;  /* Offset in keyword table for shifts. */
  Ushort Mapr;  /* Offset in keyword table for reduces. */
  Ushort ReduceProd; /* Text of production. */
  Ushort Recognise;  /* LHS recognised by reduction. */
  Ushort ExitNum;  /* Exit taken when Recognise. */
  Ushort RHScount;
  Ushort Prune;
  Ushort Error;
  Ushort SwLen; /* Counting just what came as shifts. */
  Ushort SwLen2; /* Including those added to get messages before reduction. */
  Ushort SwLen3; /* After removal of switches on non-atoms. */
  Ushort ShLo;
  Ushort ShZi;
  Ushort ReLo;
  Ushort ReZi;
  struct{
    Ushort Trigger;
    Ushort Goto;
  } e[SwitchLimit*2];
};
typedef struct{
  Wallet w; /* See Wal.h */
  struct{
    Ushort Left;
    Ushort Right;
  }e[1];
} Pairs;
static Pairs * Pairsp;
 typedef struct {
   Wallet w;
   Ushort e [1];
 } Wmsgs;
static Wmsgs *Rmsgs,*Smsgs,*Domp;
static struct StStruc State;
static struct StStruc *Statep, *Statep2, *Statep3, *Statepx, *Statepx2;
static struct StStruc * (* States) [1];
static FILE * In;
static Bool MakeAsm;
static Ushort MsgChoice(Ushort);
static Ushort GetMajMin(void);
static Ushort * Fromsp;
static Ushort MaxWork;
static Ushort Default, Pass;
static Ushort *Set1p, *Set2p, *Setxp;
static Ushort Set1Zi, Set2Zi;
static void Keywords(void);
static void FirstLess(Ushort a, Ushort b);
static void EnList(Ushort j, Ushort j2);
static void AddRedSw(Ushort j, Ushort j2);
static void PrintStates(void);
static Ushort ScanProduction(Ushort Mode);
static char * ToName(char * s, Ushort n);
#if 0
static void ShowK(void);    /* Shows Keys wallet */
#endif
static void Structs(void){
/*------------------------------------------------------------------------------
1. Initialize
õ-----------------------------------------------------------------------------*/
/* There are alternative forms of output. */
 MakeAsm=No;if(strchr(Switches,'A')) MakeAsm=Yes;
 WalletInit(Domp);
 WalletInit(Pairsp);
 WalletInit(Rmsgs);
 WalletInit(Smsgs);
 TpZi=&(Text->e[Text->w.Needs]);
  In=fopen(InArg2,"r");
  if(In==NULL) {
    printf(Msg[5],InArg2);
    longjmp(ErrSig,1);
  }
/*------------------------------------------------------------------------------
2. Check that first number on the second argument is the same as the Checksum.
õ-----------------------------------------------------------------------------*/
  {
 static long CheckNow, CheckSum;
     CheckSum=0;
     for(Tp=Text->e;Tp<TpZi;Tp++){
       CheckSum+=(long)*Tp;
     }
     fscanf(In,"%ld",&CheckNow);
     if(CheckSum!=CheckNow) {
       printf(Msg[6]);
       longjmp(ErrSig,1);
     }
/* Cannot free Text yet, we need it to work out reductions. */
  }
/* Allocate space for the States array. */
  fscanf(In,"%d",&StatesCount);
  if(StatesCount+SpareStates>StatesZi){
       printf(Msg[13]);
       longjmp(ErrSig,1);
     }
  if((States=calloc(StatesCount+SpareStates,sizeof((*States)[1])))==NULL){
       printf(Msg[7]);
       longjmp(ErrSig,1);
  }
/*------------------------------------------------------------------------------
3. Read Aheads information.
õ-----------------------------------------------------------------------------*/
/* I'm recording this stuff but it never gets used nowadays. */
/* In fact overwritten by the Differ activity. */
{ Ushort St, Keyw, t;
  for(;;){
    fscanf(In,"%d %d",&St, &Keyw);
    if(St==0 & Keyw==0) break;
    t=Pairsp->w.Needs++;WalletCheck(Pairsp);
    Pairsp->e[t].Left=St;
    Pairsp->e[t].Right=Keyw;
  }
}
/*------------------------------------------------------------------------------
4. Read each state.
õ-----------------------------------------------------------------------------*/
 SparesLeft=SpareStates;
 StatesBound=StatesCount;
  for(Sj=0;Sj<StatesCount;Sj++){
   Ushort t;Bool IsRmsg;
    Clear(State);
    Rmsgs->w.Needs=0;
    Smsgs->w.Needs=0;
/* There is a count of pairs for this State. */
    fscanf(In,"%d",&SwitchCount);
/* Then the pairs. */
    for(Sk=0;Sk<SwitchCount;Sk++){
      fscanf(In,"%d %d",&Trigger,&Goto);
/* Static limit on size of switch. */
      if(Trigger>=TriggerZi){
        printf(Msg[8],TriggerZi-1);
        longjmp(ErrSig,1);
      }
      if(Goto<0){
        Goto=-Goto;
/* All reductions are recognizing the same production, in the cases we care
about. */
        if(State.ReduceProd!=0 && State.ReduceProd!=(Ushort)Goto){
          printf(Msg[9],Sj);
          longjmp(ErrSig,1);
        }
        State.ReduceProd=Goto;
/* Realized late in the design that keyword tables needed to include the
reducing keywords like 'end'. */
/* Mar 94. In this version we keep every reducer that isn't a msg.  Then
delete the lot if it turns out there is no choice over a reduce. */
        Sym=SymLoc(*(Num2Sym+Trigger));
        if(Sym->IsMsg){
          t=Rmsgs->w.Needs++;WalletCheck(Rmsgs);
          Rmsgs->e[t]=GetMajMin();
#if 0
          printf("\n Rmsg Sj %d Tr %d Err %d",Sj,Trigger,Rmsgs->e[t]);
#endif
        }
        else{
          State.e[SwitchLimit+State.SwLen2++].Trigger=Trigger;
          if(State.SwLen2==SwitchLimit) Failure;
          if(memcmp(Sym->s,KeyEnd,strlen(KeyEnd))==0) State.RedEnd=Yes;
          if((Ushort)Trigger==CatNum) {State.HasCat=True;}
        }
        continue;
      }  /* Reducing */
/* Shifting */
/* For a Msg we ignore Goto since we will stop. (Anyway zero) */
      Sym=SymLoc(*(Num2Sym+Trigger));
      if(Sym->IsMsg){
        t=Smsgs->w.Needs++;WalletCheck(Smsgs);
        Smsgs->e[t]=GetMajMin();
        continue;
      } /* Msg */
/* Others are the normal switch elements. */
      State.e[State.SwLen].Trigger=Trigger;
      State.e[State.SwLen].Goto=Goto-1; /* We added one when making output. */
      State.SwLen++;
      if(State.SwLen==SwitchLimit) Failure;
/* A few flags characterising the switch list */
      Sym=SymLoc(*(Num2Sym+Trigger));
      if((Ushort)Trigger==CatNum) {State.HasCat=True;}
      if(memcmp(Sym->s,KeyValue,strlen(KeyValue))==0)
        State.Valued=True;
      if(memcmp(Sym->s,KeyVersion,strlen(KeyVersion))==0)
        State.Versioned=True;
      if(memcmp(Sym->s,KeyVarSymbol,strlen(KeyVarSymbol))==0)
        State.ShiftVar=True;
      if(memcmp(Sym->s,Expr_Alias,strlen(Expr_Alias))==0)
        {
        State.ShiftExp=True;
      printf("\nShift Expr %d",Sj);
        }
    } /* Sk */
/* PARSE cannot imply its VALUE. */
    if(State.Versioned) State.Valued=False;
/* MsgChoice sets State.Error */
  IsRmsg=No;
  t=(Rmsgs->w.Needs?1:0);
  if(t+Smsgs->w.Needs>1){
    for(t=0;t<Rmsgs->w.Needs;t++){
#if 0
      printf("\n s %d r %d.%d ",Sj,Rmsgs->e[t]/256, Rmsgs->e[t]%256);
#endif
      if(MsgChoice(Rmsgs->e[t])) IsRmsg=Yes /*,printf(" y")*/;
    }
  } /* Rmsg candidate selection */
  for(t=0;t<Smsgs->w.Needs;t++){
#if 0
    printf("\n s %d s %d.%d ",Sj,Smsgs->e[t]/256, Smsgs->e[t]%256);
#endif
    if(MsgChoice(Smsgs->e[t])) IsRmsg=No /*,printf(" n")*/;
  }
/* Choice of an Rmsg is the same as no message since it will be the Smsg
of some other state. */
  if(IsRmsg) State.Error=0;
/* Awkward case is where there are reductions but the shift error is
preferred. In that case we have to test the triggers that cause
reduction.  That seems to be mostly semicolon in practice. */
/* March 97.  We were doing something wrong, so review. */
/* Turns out this "Explicit Reduce" is also needed for the case when END is
a reducer and VAR_SYMBOL is a shift. The following is probably safer than
need be. */
  Logic = No;
#if 0
/* April 97 exploring explicit reduce on ||.  Assert this won't happen
if there are other reasons for the explicit reduce. */
/* It made the Boolean array too big. */
  if(State.HasCat){
    State.e[SwitchLimit].Trigger=CatNum;
    State.SwLen2=1;
    Logic=Yes;
  }
#endif
  if(State.Error && State.ReduceProd) Logic=Yes; /* Shift error preferred */
  if(State.RedEnd && State.ShiftVar) Logic=Yes; /* Avoid shift before END test.
  ( gets END in the keyword list for that state.) */
  if(!Logic) State.SwLen2=0;
  else {
    printf("\n Shift msg & reduce %d, extras %d",Sj,State.SwLen2);
    if(State.HasCat) printf(" HasCat");
    State.Careful=Yes;
  }
/* What to recognise and how much to prune is deduced from ReduceProd which
indexes to the text of the production. */
    if(State.ReduceProd){
      Tp = Text->e + State.ReduceProd;
      Sym=SymLoc(*Tp);
      State.Recognise=Sym->Num;
/* Perhaps unnecessarily early for our purposes, readin set a flag for
names with a dot in them. */
      State.ExitNum=0;
      if(Sym->IsExit){
        for(t=0;t<Sym->SymbolLength;t++){
          if(Sym->s[t]=='.') State.ExitNum=0;
          else State.ExitNum=10*State.ExitNum+(Sym->s[t]-'0');
        }
      }
      State.RHScount=0;
      for(Tp=Tp+2;*Tp>0;Tp++) State.RHScount++;
    }
/* Copy it from State for later use. */
/* For each state, from its productions, we can deduce "this state will
(after one advance of the caret) be looking (possibly) at certain keywords."
Or for some states, at what cannot be keyword.
*/
/* Join up the switch and specific-error lists. */
/* The specific error items are cases where a particular atom leads to a
specific error (as opposed to leading to a reduction and possible later
error).  At this point we invent a state for the error, so as to make it
like shifting on that particular atom. */
/* Mar 97. The paragraph above looks to be nonsense. The things in the
SwLen2 list say which tokens will give a reduce without errors, not
which will give a reduce to an error. */
/* So I'm junking what was the next bit: */
/* Current state to its own space. */
  Bytes=sizeof(State)
    -sizeof(State.e[1])*(2*SwitchLimit-State.SwLen-State.SwLen2);
  if((Statep=malloc(Bytes))==NULL){
       printf(Msg[7]);
       longjmp(ErrSig,1);
  }
  Bytes2=sizeof(State.e[1])*State.SwLen2;
  Bytes-=Bytes2;
  State.SwLen2+=State.SwLen;  /* SwLen of switch, then aheads. */
  memcpy(Statep,&State,Bytes);
  memcpy(&(Statep->e[State.SwLen]),&(State.e[SwitchLimit]),Bytes2);
  (*States)[Sj]=Statep;
  } /* States loop reading in. */
  StatesCount=StatesBound; /* Include the spares */
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    for(Sk=0;Sk<Statep->SwLen2;Sk++){
      Sr=Statep->e[Sk].Goto;
      /* Shift to zero is not really a shift */
      if(Sr){
        (*States)[Sr]->ShiftEntry=Yes;
      }
    } /* Sk */
  }
  (*States)[0]->ShiftEntry=Yes;

/*------------------------------------------------------------------------------
5. Note which shifted from.
õ-----------------------------------------------------------------------------*/
{
  Ushort FromsTotal;
  /* Note Froms for each state. Count for each state first. */
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    for(Sk=0;Sk<Statep->SwLen2;Sk++){
      Sr=Statep->e[Sk].Goto;
      /* Shift to zero is not really a shift */
      if(Sr){
        Statep2=(*States)[Sr];
        Statep2->FromsZi++; /* Slot will record Sj as From for Sr */
      }
    } /* Sk */
  }
/* Froms will be in one long array.  Total how long it will be */
  FromsTotal=0;
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    Statep->FromsLo=FromsTotal;
    FromsTotal+=Statep->FromsZi;
    Statep->FromsZi=Statep->FromsLo;/* Ready for filling array. */
  }
  /* Allocate Froms array */
  if((Fromsp=(Ushort *)malloc(FromsTotal * sizeof(Ushort)))==NULL){
       printf(Msg[7]);
       longjmp(ErrSig,1);
  }
  /* And a couple of work arrays. */
  if((Set1p=(Ushort *)malloc(StatesCount * sizeof(Ushort)))==NULL){
       printf(Msg[7]);
       longjmp(ErrSig,1);
  }
  if((Set2p=(Ushort *)malloc(StatesCount * sizeof(Ushort)))==NULL){
       printf(Msg[7]);
       longjmp(ErrSig,1);
  }
/* A pass to fill Froms in. */
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    for(Sk=0;Sk<Statep->SwLen2;Sk++){
      Sr=Statep->e[Sk].Goto;
      /* Mark the 'gone to' as having Sj as 'from' */
      /* Shift to zero is not really a shift */
      if(Sr){
        Statep2=(*States)[Sr];
        *(Fromsp+Statep2->FromsZi)=Sj;
        Statep2->FromsZi++;
      }
    } /* Sk */
  } /* Sj */
/* Each state now indicates a subarray showing what it "came from". */
}
/*------------------------------------------------------------------------------
6. Process reductions to switchlists.
õ-----------------------------------------------------------------------------*/
/* We will use the same algorithm twice, once to determine which states
are "Reference" and once to add up their sizes. */
  for(Sj=1;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
/* For each reduction we want to know what could be on the top of stack
after the reduction */
    if(Statep->ReduceProd){
      Ushort k;Ushort t;
      ScanProduction(0);
/* Set1 and Set2 have been set up. */
/* When Sj reduced, Set1 element on stack means goto corresponding Set2
state. Set2 is a bag. */
/*------------------------------------------------------------------------------
7. Make the reduce switch for state Sj.
õ-----------------------------------------------------------------------------*/
/* Cannot do anything yet that depends on whether states are "equal",
which actually makes it the wrong time for StackPhysical (ie Reference state)
deduction.  However, I think it fails in a safe way. */
/* Setting StackPhysical is a by-product. */
      if((Statep->RedSw=(Ushort *)malloc(2*(Set1Zi) * sizeof(Ushort)))==NULL){
        printf(Msg[7]);
        longjmp(ErrSig,1);
      }
      Statep->RedSwCt=Set1Zi;
/* Those that are reduce-switched on will have to be put on the stack
as they are entered, so that there is something there to test when the
time comes. (unless all the targets are the same.) */
      k=0;
      for(j1=0;j1<Set1Zi;j1++){
        if(*(Set2p+j1) != *(Set2p) ) k=1;
      }
      j=0;
      for(j1=0;j1<Set1Zi;j1++){
        *(Statep->RedSw+j)=*(Set1p+j1);
        Statep2=(*States)[*(Set1p+j1)];
        if(k) Statep2->StackPhysical=1;
        t=*(Set2p+j1);
        *(Statep->RedSw+j+1)=t;
        /* Debugging - loop test. */
        if(t==Sj) Statep->Self=Yes;
        j+=2;
      }
    } /* Reduce */
  }  /* Sj */
  /* Don't merge this with previous loop ! */
  for(Sj=1;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    if(Statep->ReduceProd){
      /* Do it again now that StackPhysicals are set, to add up for pruning. */
      Statep->Prune=ScanProduction(1);
      if(Statep->Prune==0 && Statep->Self) printf("\nDodgy %d",Sj);
    } /* Reduce */
  }  /* Sj */
  /* Propagate AboveAction, just for the listing. */
  do{
    Logic=0;
    for(Sj=1;Sj<StatesCount;Sj++){
      Statep=(*States)[Sj];
      if(Statep->AboveAction){
        for(k=Statep->FromsLo;k<Statep->FromsZi;k++){
          Statepx=(*States)[*(Fromsp+k)];
          if(Statepx->StackPhysical && !Statepx->AboveAction){
            Statepx->AboveAction=Yes;Logic=Yes;
          }
        } /* k, Froms */
      } /* AboveAction */
    }  /* Sj */
  } while(Logic);
  for(Sj=1;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    if(Statep->AboveAction){
      printf("\nAboveAction %d:",Sj);
      for(k=Statep->FromsLo;k<Statep->FromsZi;k++){
        printf(" %d",*(Fromsp+k));
      } /* k, Froms */
    } /* AboveAction */
  }  /* Sj */
/*------------------------------------------------------------------------------
8. Shorten switch-switches now that only atoms matter.
õ-----------------------------------------------------------------------------*/
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    if(Statep->SwLen2){
      Sr2=0;
      for(Sk=0;Sk<Statep->SwLen2;Sk++){
        Sr=Statep->e[Sk].Trigger;
        if(Sr<TermCount){
/* We have to copy because the error case means they are no longer ordered. */
          Statep->e[Sr2].Trigger=Sr;
          Statep->e[Sr2].Goto=Statep->e[Sk].Goto;
          Sr2=Sr2+1;
        }
      } /* Sk */
      Statep->SwLen3=Sr2;
    }
  } /* Sj */
/* Now we know the shifts by the Gotos and the reduces by the RedSw etc. */
/*------------------------------------------------------------------------------
9. Look to eliminate states that are effectively the same as others.
õ-----------------------------------------------------------------------------*/
/* There are (StatesCount*(StatesCount-1)) decisions to be made about
whether a a pair of original states are effectively the same state so it
it won't be quick however it is done. */
#if 0
  PrintStates();
#endif
  /* Use Work for how many decisions made about this state sofar. */
  /* First pass for things that can be quickly decided as different. */
  /* Assert Work==0 */
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    for(Sj2=Sj+1;Sj2<StatesCount;Sj2++){
      Bool DidDiffer;
      DidDiffer=No;
      /* First pass for things that can be quickly decided as different. */
      Statep2=(*States)[Sj2];
      /* Differ on keyword set. */
      if(Statep->Maps != Statep2-> Maps) DidDiffer=Yes;
      /* Differ if these have different error messages. */
      else if(Statep->Error != Statep2->Error) DidDiffer=Yes;
      /* Differ if these have different length switches. */
      else if(Statep->SwLen3 != Statep2->SwLen3) DidDiffer=Yes;
      else if(Statep->RedSwCt!=Statep2->RedSwCt) DidDiffer=Yes;
      else if(Statep->HasCat!=Statep2->HasCat) DidDiffer=Yes;
      /* Differ if reducingness different */
      /* This still allows reducing to different things with no actions. */
      else if(Statep->Recognise && !(Statep2->Recognise)) DidDiffer=Yes;
      else if(Statep2->Recognise && !(Statep->Recognise)) DidDiffer=Yes;
      else if(Statep->Recognise){
        if(Statep->Prune!=Statep2->Prune) DidDiffer=Yes;
        if(Statep->ExitNum!=Statep2->ExitNum) DidDiffer=Yes;
#if 0
      /* Assume for now exits are never the same. */
        Sym=SymLoc(*(Num2Sym+Statep->Recognise));
        if(Sym->IsExit) DidDiffer=Yes;
        Sym=SymLoc(*(Num2Sym+Statep2->Recognise));
        if(Sym->IsExit) DidDiffer=Yes;
#endif
      }
      /* I hope the switches are sorted in a consistent order. */
      if(!DidDiffer)
      for(k=0;k<Statep->SwLen3;k++){
        if(Statep->e[k].Trigger!=Statep2->e[k].Trigger){
          DidDiffer=Yes;
          break;
        }
      }
      if(DidDiffer){
        if(QryFlag(Decided[Sj2],Sj)) Failure;
        SetFlag(Different[Sj],Sj2);SetFlag(Different[Sj2],Sj);
        SetFlag(Decided[Sj],Sj2);SetFlag(Decided[Sj2],Sj);
        Statep->Work++;Statep2->Work++;
      }
    } /* Sj2 */
  } /* Sj */
  AddRedSw(0,0);/* Setup RedSwPair. */
/* The approach here is to find a pair of states for which the decision
has not been made and check them out, calling functions to check the
states they reference, and so on.  If something is found to
distinquish the pair a longjmp is made back to tidy up the testing.
If nothing is found that means the pair are one, and any pairs
involved in the latest checking are also matched. */
/* Those pairs are collected in a wallet by the EnList function. */
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    if(Statep->Work==StatesCount-1){/* Speedup some. */
      continue;
    }
    else
    for(Sj2=Sj+1;Sj2<StatesCount;Sj2++){
      Ushort k,j,j2;
      if(Statep->Work==StatesCount-1) break;/* All decided for Sj */
      if(QryFlag(Decided[Sj],Sj2)) continue;/* Decided as by-product of previous.*/
      if (setjmp(DifferSig)!=0) goto DifferCase;/* Was a longjmp(DifferSig,n) */
      Statep2=(*States)[Sj2];
      /* Initialize the Pairs list to have this pair. */
      Pairsp->w.Needs=0;
      EnList(Sj,Sj2);
      for(k=0;k<Pairsp->w.Needs;k++){
        Ushort j,j2;
        j=Pairsp->e[k].Left;
        j2=Pairsp->e[k].Right;
        Differ(j,j2);
      }
      /* If we reach here, nothing was found to cause a DifferCase jump. */
      for(k=0;k<Pairsp->w.Needs;k++){
        j=Pairsp->e[k].Left;
        j2=Pairsp->e[k].Right;
        /* All of the set match. */
        if(QryFlag(Decided[j2],j)) Failure;
        SetFlag(Decided[j2],j);
        SetFlag(Decided[j],j2);
        (*States)[j]->Work++;
        (*States)[j2]->Work++;
      }
NextPair:;
      /* Empty the list */
      for(k=0;k<Pairsp->w.Needs;k++){
        j=Pairsp->e[k].Left;
        j2=Pairsp->e[k].Right;
        OffFlag(InList[j],j2); /* Say pair is not in list. */
        OffFlag(InList[j2],j);
      }
      Pairsp->w.Needs=0;
      continue;
DifferCase:;
      /* Something differed, making this pair differ. */
      SetFlag(Different[Sj2],Sj);
      SetFlag(Different[Sj],Sj2);
      if(QryFlag(Decided[Sj2],Sj)) Failure;
      SetFlag(Decided[Sj2],Sj);
      SetFlag(Decided[Sj],Sj2);
      Statep->Work++;Statep2->Work++;
      goto NextPair;
    } /* Sj2 */
  } /* Sj */
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    if(Statep->Work!=StatesCount-1){
      printf("\n%d %d",Sj,Statep->Work);
      Failure;
    }
    Statep->Work=0;
  }
/* Different now tells us what differed. */
  Sj2=0; /* To start renumbering. */
  for(Sj=0;Sj<StatesCount;Sj++){
    Ushort k;
    Statep=(*States)[Sj];
    if(!Statep) continue;
    /* This one will be kept. */
    Renum[Sj]=Sj2;
    /* Discard states that are the same. */
    printf("\n%d becomes %d, as do old:",Sj,Sj2);
    for(k=Sj+1;k<StatesCount;k++){
      if(!QryFlag(Different[Sj],k)){
        Renum[k]=Sj2;
        if(Statep->StackPhysical!=(*States)[k]->StackPhysical) Failure;
        printf(" %d",k);
        free((*States)[k]);
        (*States)[k]=NULL;
      }
    }
    if(Sj2<Sj){
      /* Compact range. */
      if((*States)[Sj2]) Failure;
      (*States)[Sj2]=Statep;
      (*States)[Sj]=NULL;
    }
    Sj2++;/* New number for this one. */
  } /* Sj */
  StatesCount=Sj2;
  /* The switches need updating. */
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    if(!Statep) Failure;
    for(Sk=0;Sk<Statep->SwLen3;Sk++){
      Sr=Statep->e[Sk].Goto;
      Statep->e[Sk].Goto=Renum[Sr];
    } /* Sk */
    for(Sk=0;Sk<2*Statep->RedSwCt;Sk++){
      Sr=*(Statep->RedSw+Sk);
      *(Statep->RedSw+Sk)=Renum[Sr];
    } /* Sk */
  } /* Sj */
#if 0
  printf("\nPre RedSw thin.");
  PrintStates();
#endif
/*------------------------------------------------------------------------------
10. Work on reduction switches.
õ-----------------------------------------------------------------------------*/
/* We want to know how many of each differing value in Set2. */
/* We put a chain through the full list of states. */
/* Work records how often each state is a target of this switch. */
/* Before anything else, drop duplicates in RedSw that can have arisen
because of the renumbering. */
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    if(Statep->RedSwCt){
      for(j2=0;j2<Statep->RedSwCt-1;j2++){
        Sr=*(Statep->RedSw+2*j2);
        Sr2=*(Statep->RedSw+2*j2+1);
        for(j=j2+1;j<Statep->RedSwCt;j++){
        /* If [j] same as [j2] then swop last into its place. */
          if(Sr==*(Statep->RedSw+2*j) && Sr2==*(Statep->RedSw+2*j+1)){
            *(Statep->RedSw+2*j)=*(Statep->RedSw+2*(Statep->RedSwCt-1));
            *(Statep->RedSw+2*j+1)=*(Statep->RedSw+2*(Statep->RedSwCt-1)+1);
            j--;/* To test the one moved. */
            Statep->RedSwCt--;
          }
        }
      } /* j2 */
    }
  }
#if 0
  printf("\nMid RedSw thin.");
  PrintStates();
#endif
/* Sort each switch on Set1 state within Work of Set2 state. */
  for(Sj=0;Sj<StatesCount;Sj++){
    Ushort Mask, Width, WorkOnes;
    Statep=(*States)[Sj];
    if(Statep->RedSwCt){
      Anchor=0;
      for(j2=0;j2<Statep->RedSwCt;j2++){
        Sr=*(Statep->RedSw+2*j2+1);
        Statep2=(*States)[Sr];/* Target state. */
        if(Statep2->Work) Statep2->Work++;
        else {
          /* Chaining up the targets. */
          Statep2->Chain=Anchor;
          Anchor=Sr;
          Statep2->Work=1;
        }
      }
      do{
        Logic=0;
        for(j1=1;j1<Statep->RedSwCt;j1++){
          long Ta,Tb;Ushort S1a,S1b,S2a,S2b;
          S2a=*(Statep->RedSw+1+2*j1-2);/* Gotolike of earlier. */
          S2b=*(Statep->RedSw+1+2*j1);/* Gotolike of this. */
          Ta=(*States)[S2a]->Work;
          Tb=(*States)[S2b]->Work;
          S1a=*(Statep->RedSw+2*j1-2);/* Triggerlike of earlier. */
          S1b=*(Statep->RedSw+2*j1);/* Triggerlike of this. */
          if(Ta>Tb || (Ta==Tb && S1a>S1b)){
            Logic=1;
            *(Statep->RedSw+2*j1-2)=S1b;
            *(Statep->RedSw+2*j1)=S1a;
            *(Statep->RedSw+1+2*j1-2)=S2b;
            *(Statep->RedSw+1+2*j1)=S2a;
          }
        }
      } while(Logic);
/* Sort the chain on Work */
/* The way things are done 20-02-96 this is a bit pointless. */
      do{
        Ushort Prior;
        Logic=No;
        j1=Anchor;Prior=0;
        while(j1){
          Statepx=(*States)[j1];
          j2=Statepx->Chain;
          Statep2=(*States)[j2];
          if(j2 && Statep2->Work>Statepx->Work){
            Logic=Yes; /* Something needed change. */
            Statepx->Chain=Statep2->Chain;  /* Bypass j2 */
            /* Put j2 back before j1 */
            Statep2->Chain=j1;
            if(Prior){
              Statepx=(*States)[Prior];
              Statepx->Chain=j2;
            }
            else Anchor=j2;
            Prior=j2;
          } /* Change. */
          else {
            Prior=j1;
            j1=j2;
          }
        }  /* j1 */
      } while(Logic);
/* Make a pass of chain noting a few things, and clear chain. */
/* Could simplify to do without the chain. */
      Mask=(*States)[Anchor]->Work; /* How many of most frequent. */
      j1=Anchor;Width=0;WorkOnes=0;
      while(j1){
        Width++;
        Statepx=(*States)[j1];
#if 0
  printf("\n%d switch contains %d this many times %d",Sj,j1,Statepx->Work);
#endif
        if(Statepx->Work==1) WorkOnes++;
        j1=Statepx->Chain;
        Statepx->Work=0;
        Statepx->Chain=0;
      }
      Statep->RedSwCt2=Statep->RedSwCt;/* Retain count including defaulted. */
      /* Not best to default if they are all different targets. */
      if(Mask==1 && Statep->RedSwCt>1){
        Mask=0;Anchor=0;
      }
      /* Default target of reduction is made the last target. */
      Statep->Red1=*(Statep->RedSw+2*(Statep->RedSwCt-1)+1);
      /* If they all go to the same target we can't do better than set
      ReduceJoin and Red1. */
      if(Width==1){
        Statep->ReduceJoin=Yes;
#if 0
        /* We could free if we didn't want to pass info to another stage. */
        free(Statep->RedSw);
        Statep->RedSw=NULL;
#endif
      }
      else{
        /* No need in the switch for the default, which has Mask items. */
        Statep->RedSwCt-=Mask;
      }
      Anchor=0;
    } /* Was RedSwCt */
/* For the reductions, we need to work out the prune count - how much
stack is removed as this Recognize (LHS of production ReduceProd) is
recognized. That means adding up the reference states (and any variables
we choose to put with them) that will have built up in reaching the state
where the reduction happens. */
  } /* Sj */
  printf("\nPost RedSw thin.");
  PrintStates();
/*------------------------------------------------------------------------------
11. Minimise the token set.
õ-----------------------------------------------------------------------------*/
/* Find where the messages start. */
/* Some keys have to be treated as non-key because of hybrid rules. */
  for(AtomsCount=1;AtomsCount<TermCount;AtomsCount++){
    Ushort t;
    char c;
    /* Can't recall where IsKey set (if anywhere) so do it here. */
/* Iskey here means the shift in Parser will look it up, as opposed to
 keywords detected by special rules for the middle of clauses. */
    Sym=SymLoc(*(Num2Sym+AtomsCount));
    c=Sym->s[1];
    t=Sym->SymbolLength;
    if(!Sym->IsMsg && Sym->s[0]== '\''&& c>='A' && c<='Z') Sym->IsKey=Yes;
    if(t==4 && memcmp(Sym->s,KeyBy,4)==0){
      NumBy=AtomsCount;
      Sym->IsKey=No;
    }
    if(t==5 && memcmp(Sym->s,KeyFor,5)==0){
      NumFor=AtomsCount;
      Sym->IsKey=No;
    }
    if(t==6 && memcmp(Sym->s,KeyThen,6)==0){
      NumThen=AtomsCount;
      Sym->IsKey=No;
    }
    if(t==4 && memcmp(Sym->s,KeyTo,4)==0){
      NumTo=AtomsCount;
      Sym->IsKey=No;
    }
    if(t==7 && memcmp(Sym->s,KeyUntil,7)==0){
      NumUntil=AtomsCount;
      Sym->IsKey=No;
    }
    if(t==7 && memcmp(Sym->s,KeyWhile,7)==0){
      NumWhile=AtomsCount;
      Sym->IsKey=No;
    }
    if(t==6 && memcmp(Sym->s,KeyWith,6)==0){
      NumWith=AtomsCount;
      Sym->IsKey=No;
    }
 /* Had to make END non-key because risk semicolon|END being done by Direct. */
    if(t==5 && memcmp(Sym->s,KeyEnd,5)==0){
      Sym->IsKey=No;
    }
 /* FORM VALUE ... led to this one. */
    if(t==7 && memcmp(Sym->s,KeyValue,7)==0){
      Sym->IsKey=No;
    }
    if(Sym->IsMsg) break;
  }
  printf("\n%d atoms",AtomsCount);
  /* Clear some flags for reuse. */
  for(j=0;j<AtomsCount;j++) Clear(Different[j]);
  for(Sj=0;Sj<StatesCount;Sj++){
    Ushort t;
    Statep=(*States)[Sj];
    if(Statep->SwLen3){
      /* Reuse InList[0] as 1 equals atom not in this list. */
      memset(InList,0xFF,Strip);
      for(k=0;k<Statep->SwLen3;k++){
        Trigger=Statep->e[k].Trigger;
        OffFlag(InList[0],Trigger);
      }
      /* Each atom is different from anything not in the list. */
      for(k=0;k<Statep->SwLen3;k++){
        Trigger=Statep->e[k].Trigger;
        MemOr(Different[Trigger],InList[0],Strip);
        for(j=0;j<AtomsCount;j++)
          if(QryFlag(Different[Trigger],j)) SetFlag(Different[j],Trigger);
        /* Also different from anything in the list with a different Goto. */
        Goto=Statep->e[k].Goto;
        for(k1=k+1;k1<Statep->SwLen3;k1++){
          if(Statep->e[k1].Goto!=Goto){
            t=Statep->e[k1].Trigger;
            SetFlag(Different[Trigger],t);
            SetFlag(Different[t],Trigger);
          }
        }
      }
    }
  } /* Sj */
/* Different tells us what differed. */
  ACwas=AtomsCount;AtomsCount=0; /* To start renumbering. */
#if 0
  printf("\n Dump of Different");
  if(QryFlag(Different[1],101)) printf("\n[]1");else printf("\n[]0");
  for(j=0;j<ACwas;j++){
    Ushort t;
    printf("\n %d ",j);
    for(t=j+1;t<ACwas;t++){
      if(QryFlag(Different[j],t)) printf("1");
      else printf("0");
    }  /* t */
  } /* j */
#endif
  Clear(DropTrigger);
  for(k=0;k<2;k++){ /* Two-pass to do keywords second. */
    for(j=0;j<ACwas;j++){
      Ushort t;
      if(!DropTrigger[j]){
        Sym=SymLoc(*(Num2Sym+j));
        if(k==0 && Sym->IsKey) continue;
        if(k==1 && !Sym->IsKey) continue;  /* THEN etc were made non-key. */
        for(t=j+1;t<ACwas;t++){
          if(!QryFlag(Different[j],t)){
            RenumAtom[t]=AtomsCount;DropTrigger[t]=Yes;
          }
        }
        RenumAtom[j]=AtomsCount++;
      }
    } /* j */
    if(k==0) LowKey=AtomsCount;
  } /* Passes */
/* Put this out in a form suitable to man-handle into the assembler code. */
  for(k=0;k<AtomsCount;k++){
    for(j=0;j<ACwas;j++){
      char * s;
    /* Looking for things with RenumAtom[j] the same. */
      if(RenumAtom[j]==k){
/* If the original is a word we can use the word as a name. */
        Sym=SymLoc(*(Num2Sym+j));
        if(Sym->s[0]!='\''){
          printf("\n GroupMember %d,",k);
          for(Sj=0;Sj<Sym->SymbolLength;Sj++)
            printf("%c",Sym->s[Sj]);
        }
        else{
          if(Sym->s[1]>='A' && Sym->s[1]<='Z'){
            printf("\n GroupMember %d,",k);
            for(Sj=1;Sj<Sym->SymbolLength-1;Sj++)
              printf("%c",Sym->s[Sj]);
          }
          else{
            s=ToName(&Sym->s[1],Sym->SymbolLength-2);
            /* If it is not found it should be the same as some other in
            both syntax & semantics, so no name needed. */
            if(s!=NULL){
              printf("\n GroupMember %d,",k);
              printf("%s",s);
            }
          }
        }
      }
    }
  }
/* Keywords at this particular point, where RenumAtom has been set but the
switch triggers still show original token numbers. */
#if 0
  if(!MakeAsm){
    ShowS("#define Extern 0");
    NewLine();
    ShowS("#include \"tables.h\"");
  }
#endif
/* The list of keywords allowed, if any. */
  Keywords();
  NewLine();
  /* The switches are then updated: */
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    for(Sk=0;Sk<Statep->SwLen3;Sk++){
      Sr=Statep->e[Sk].Trigger;
      Statep->e[Sk].Trigger=RenumAtom[Sr];
    } /* Sk */
  } /* Sj */
/* Drop duplicates in switch that can have arisen
because of the renumbering. */
  for(Sj=0;Sj<StatesCount;Sj++){
    Ushort t;
    Statep=(*States)[Sj];
    if(Statep->SwLen3){
      for(Sk=0;Sk<Statep->SwLen3-1;Sk++){
        Sr=Statep->e[Sk].Trigger;
        Goto=Statep->e[Sk].Goto;
        for(t=Sk+1;t<Statep->SwLen3;t++){
        /* If [t] same as [Sk] then swop last into its place. */
          if(Sr==Statep->e[t].Trigger && Goto==Statep->e[t].Goto){
            Statep->e[t].Trigger=Statep->e[Statep->SwLen3-1].Trigger;
            Statep->e[t].Goto=Statep->e[Statep->SwLen3-1].Goto;
            t--;/* To test the one moved. */
            Statep->SwLen3--;
          }
        }
      }
    }
  }
  /* If this PrintStates is deleted, TotalInSw will have to be set some
  other way. */
  PrintStates();
/*------------------------------------------------------------------------------
12. Write out to the next stage, via Stdout.
õ-----------------------------------------------------------------------------*/
 {
  Ushort Total=0;
  printf("\n\n");/* Mark transition on Stdout. */
  printf("%d %d %d %d",AtomsCount,TotalInSw,StatesCount,LowKey);
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    if(Statep->SwLen3 || Statep->RedSwCt2) printf("\n");
    if(Statep->SwLen3){
      Statep->ShLo=Total;
      for(Sk=0;Sk<Statep->SwLen3;Sk++){
        printf("%d %d ",Statep->e[Sk].Trigger,Statep->e[Sk].Goto);
        Total++;
      } /* Sk */
      Statep->ShZi=Total;
    }
    if(Statep->RedSwCt2){
      Statep->ReLo=Total;
      for(j1=0;j1<Statep->RedSwCt2;j1++){
        printf("%d %d ",*(Statep->RedSw+j1+j1),*(Statep->RedSw+j1+j1+1));
        Total++;
      }
      Statep->ReZi=Total;
    }
  }
  if(Total!=TotalInSw){
    printf("\n%d %d",Total,TotalInSw);
    Failure;
    }
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    printf("\n%d %d %d %d %d %d %d %d %d %d",
      Statep->Error,Statep->ExitNum,Statep->Prune,
      Statep->StackPhysical,Statep->Maps,
/* May 97, latest on implied || is to send the HasCat flag through. */
      Statep->HasCat,
      Statep->ShLo,
      Statep->ShZi,
      Statep->ReLo,
      Statep->ReZi);
  }
  printf("\n%d",TotalInSw);/* As a check. */
  return;
 }
} /* Structs */
/*------------------------------------------------------------------------------
13. Routine PrintStates.
õ-----------------------------------------------------------------------------*/
static void PrintStates(void){
  TotalInSw=0;/* By-product */
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    if(!Statep) Failure;
    printf("\n%d is ",Sj);
    if(Statep->SwLen3) printf("S");
    if(Statep->Prune) printf("P%d",Statep->Prune);
    if(Statep->ReduceProd) printf("R%d",Statep->Red1);
    if(Statep->ExitNum) printf("X%d",Statep->ExitNum);
    if(Statep->HasCat) printf("||",Statep->Red1);
    for(Sk=0;Sk<Statep->StackPhysical;Sk++) printf("F");
    if(Statep->Error)printf("E%d.%d",Statep->Error/256,Statep->Error%256);
    if(Statep->Maps){
      printf("K%d",Statep->Maps);
      if(!Statep->ShiftEntry) Failure; /* Doesn't happen. Maybe can't? */
    }
    printf(" ");
    if(Statep->SwLen3){
      TotalInSw+=Statep->SwLen3;
      for(Sk=0;Sk<Statep->SwLen3;Sk++){
        Sr=Statep->e[Sk].Trigger;
        Sr2=Statep->e[Sk].Goto;
        if((1+Sk)%6==0) printf("\n");
        printf("[");
        if(ACwas){/* Groups now */
          printf("%d",Sr);
        }
        else{
          Sym=SymLoc(*(Num2Sym+Sr));
          for(Sr=0;Sr<Sym->SymbolLength;Sr++)
            printf("%c",Sym->s[Sr]);
        }
        printf(":%d]",Sr2);
      } /* Sk */
      printf("\n");
    }
    TotalInSw+=Statep->RedSwCt2;
    if(Statep->ReduceProd && !Statep->ReduceJoin){
      if(Statep->RedSw){
        for(j1=0;j1<Statep->RedSwCt;j1++){
          if((1+j1)%8==0)printf("\n");
          printf("{%d:%d}",*(Statep->RedSw+j1+j1),*(Statep->RedSw+j1+j1+1));
        }
      }
    }
  }
} /* PrintStates */

/*------------------------------------------------------------------------------
14. Routine ScanProduction
õ-----------------------------------------------------------------------------*/
static Ushort ScanProduction(Ushort Mode){
      Ushort S1,S2,f,y,Totaly,Cycles;
      Totaly=0;Cycles=0;
      /* We don't want to count the first state when doing physicals. */
      /* First list is the state that is reducing, others by working
      back on Froms. */
      *(Set1p)=Sj;Set1Zi=1;Set2Zi=0;
      Tpx = Text->e + Statep->ReduceProd;
      /* Scan this production from the right */
      for(Tp=Tpx+1+Statep->RHScount;Tp>Tpx+1;Tp--){
        Cycles++;
        Sym=SymLoc(*Tp);
        Trigger=Sym->Num;
        y=(*States)[*(Set1p)]->StackPhysical;/* Initialize. */
/* We want Set2 to be things that shift to Set1 on Trigger. */
        for(j1=0;j1<Set1Zi;j1++){
          S1=*(Set1p+j1);
          Statep2=(*States)[S1];
          if(Statep2->StackPhysical != y){
            printf("%d %d",*(Set1p),S1);
            Failure;
#if 0
            /* Doesn't look as if this happens.  Need to arrange
            iteration if it did. */
            printf("\nUpping StackPhysical, Sj=%d",Sj);
            y=Statep2->StackPhysical;
#endif
          }
          /* Now the Froms that goto that state on a matching trigger. */
          for(f=Statep2->FromsLo;f<Statep2->FromsZi;f++){
            Statepx=(*States)[*(Fromsp+f)];
            for(Sk=0;Sk<Statepx->SwLen2;Sk++){
              if(S1==Statepx->e[Sk].Goto &&
                (Ushort)Trigger==Statepx->e[Sk].Trigger){
                  /* Add it to Set2. */
                  *(Set2p+Set2Zi)=*(Fromsp+f);
                  /* Uniqueness? */
                  for(S2=0;S2<Set2Zi;S2++){
                    if(*(Set2p+S2)==*(Set2p+Set2Zi)) Failure;
                  }
                  Set2Zi++;
                  break;
                }
            } /* Sk, triggers in Froms. */
          } /* f, Froms */
        } /* j1 thru set 1 */
        /* Set all states moved over to the same stack width. */
        /* Probably irrelevant, as already equal. */
        for(j1=0;j1<Set1Zi;j1++){
          S1=*(Set1p+j1);
          Statep2=(*States)[S1];
          Statep2->StackPhysical=y;
        } /* j1 thru set 1 */
/* Aug 97 display of what exits prune. */
        if(Mode && y && Statep->ExitNum){
          printf("\nxxx%d %d{",Statep->ExitNum,Sj);
          for(j1=0;j1<Set1Zi;j1++){
            S1=*(Set1p+j1);
            printf("%d ",S1);
          } /* j1 thru set 1 */
          printf("}");
        }
/* StackPhysical will give us amount to prune when going back to reference set.*/
        Totaly+=y;
        /* For the next iteration, Set2 is the Set1 */
        Setxp=Set1p;Set1p=Set2p;Set2p=Setxp;
        Set1Zi=Set2Zi;Set2Zi=0;
      } /* Tp */
      /* Now S1 is the top-of-stack set. */
      if(Mode && Statep->ExitNum){
        printf("\nxxx%d %d[",Statep->ExitNum,Sj);
        for(j1=0;j1<Set1Zi;j1++){
          S1=*(Set1p+j1);
          printf("%d ",S1);
          Statep3=(*States)[S1];
          Statep3->AboveAction=Yes;
        } /* j1 thru set 1 */
        printf("]");
      }
      /* We will put in Set2 where they shift to on Trigger. */
      Sym=SymLoc(*Tpx);
      Trigger=Sym->Num;
      for(j1=0;j1<Set1Zi;j1++){
        S1=*(Set1p+j1);
        Statep3=(*States)[S1];
        for(Sk=0;Sk<Statep3->SwLen2;Sk++){
          if(Statep3->e[Sk].Trigger==(Ushort)Trigger){
            *(Set2p+Set2Zi)=Statep3->e[Sk].Goto;
            Set2Zi++;
            break;
          }
        } /* Sk */
        if(Set2Zi!=j1+1) Failure;
      } /* j1 */
  /* May 97, try model where test of reference is not done when reducing. */
        Totaly -= (*States)[Sj]->StackPhysical;
  return Totaly;
} /* ScanProduction */
/*------------------------------------------------------------------------------
15. Routine Keywords.  Construct the keyword table.
õ-----------------------------------------------------------------------------*/
static char * MsgWords =
 "HALT WHEN OTHERWISE SELECT END THEN ELSE IF DO SIGNAL PROCEDURE "
 "ADDRESS NAME TRACE ON CALL OFF WITH INPUT OUTPUT APPEND REPLACE "
 "FORM PARSE UPPER ERROR FOREVER EXPOSE FOR FUZZ TRACE ITERATE LEAVE "
 "DIGITS NUMERIC WHILE UNTIL VALUE TO BY RETURN INTERPRET STREAM STEM "
 "                     ";
static char * MsgWordsX;
static struct {
   Wallet w;
   struct{
     Ushort n; /* First, for sort purposes. (Count for longest list first.) */
     Ushort s; /* State */
     Ushort f; /* Flag for reduce-list */
   } e[1];
 } * StKey;
static Ushort Jsk;
Wshort * Keys, *KeysX;
static Ushort Jk, Jkx, Jky ;
static short Kv, Kvy;
#define Marker 32000
char Set[TriggerZi/8];
char SetRqd[TriggerZi/8];
char SetWork[TriggerZi/8];
static Ushort Map;
/*------------------------------------------------------------------------------
    Little routine used in sorting.
õ-----------------------------------------------------------------------------*/
static int ComparePairs(const void * x, const void * y){
 /* Nov 97 version. Sort states also for consistency. */
   typedef struct{
     Ushort n; /* First, for sort purposes. (Count for longest list first.) */
     Ushort s; /* State */
     Ushort f; /* Flag for reduce-list */
   } element;
  element *xx,*yy;
  xx=(element *)x;yy=(element *)y;
  if( xx->n  < yy->n ) return(1);
  if( xx->n  > yy->n ) return(-1);
  if( xx->s  > yy->s ) return(1);
  if( xx->s  < yy->s ) return(-1);
  return(0);
} /* ComparePairs */
#if 0
static int ComparePairs(const void * x, const void * y){
  if( *(Ushort *)x  < *(Ushort *)y ) return(1);
  if( *(Ushort *)x  > *(Ushort *)y ) return(-1);
  return(0);
} /* ComparePairs */
#endif
#if 0
static void ShowK(void){    /* Shows Keys wallet */
  NewLine();ShowS("==ShowK==");
  for(Jk=0;Jk<Keys->w.Needs;Jk++){
    NewLine();
    ShowD(Jk);ShowC(':');
    Kv=Keys->e[Jk];
    if(Kv<0) {
      Sym=SymLoc(*(Num2Sym-Kv));
      ShowA(Sym->s,Sym->SymbolLength);ShowC(' ');
    }
    else ShowD(Kv);
  }
}
#endif
static void Keywords(void){
/* Find out which states need a keyword list and length of it. */
  Ushort Sl;
  Bool First,Middle;
  Ushort Jkx,JkxLo,JkxHi,j,k,g;
  Ushort Statetbf;
  Bool ListMsg,DoCopy;
  WalletInit(StKey);StKey->w.Clear=Yes;
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    for(Sk=0;Sk<Statep->SwLen2;Sk++){
      Trigger=Statep->e[Sk].Trigger;
      Sym=SymLoc(*(Num2Sym+Trigger));
      if(Sym->s[0]=='\'' && Sym->s[1]>='A' && Sym->s[1]<='Z'){
        Sym->IsKey=Yes;
/* April 94. Treat them all as shifts.  (Reduces will have zero target.) */
/* A keyword shift. */
        if(Statep->Kws==0){
          Jsk=StKey->w.Needs++;WalletCheck(StKey);
          StKey->e[Jsk].s=Sj;
          Statep->Kws=Jsk+1;
        }
        StKey->e[Statep->Kws-1].n++;
/* For later: */
        if(memcmp(Sym->s,KeyBy,strlen(KeyBy))==0){
          Statep->f.HasBy=Yes;NumBy=Trigger;
        }
        else if(memcmp(Sym->s,KeyFor,strlen(KeyFor))==0){
          Statep->f.HasFor=Yes;NumFor=Trigger;
        }
        else if(memcmp(Sym->s,KeyTo,strlen(KeyTo))==0){
          Statep->f.HasTo=Yes;NumTo=Trigger;
        }
      } /* Keyword */
    } /* Sk */
  } /* States */
  qsort(StKey->e,StKey->w.Needs,sizeof(StKey->e[1]),ComparePairs);
/* Dec 97. Curious bug. There is pseudo randomness in how qsort orders
pairs that ComparePairs says are equal. Somehow that affects the length
overall of what is made, and even causes failure. */
/* Now have states with longest keyword list first. */
/* Make a list to cover all the keywords.  Negative values are keywords,
non-negative are the 'entry points' for corresponding state.  Large positive
to mark discontinuities. */
  WalletInit(Keys);
  for(Jsk=0;Jsk<StKey->w.Needs;Jsk++){
    Sj=StKey->e[Jsk].s;
#if 1
    printf("\nSj %d %d",StKey->e[Jsk].s,StKey->e[Jsk].n);
#endif
    if(Sj<StatesCount)
      Statep=(*States)[Sj];
    else
      Statep=(*States)[Sj-StatesCount];
    Clear(SetRqd);
/* Take part of list depending on whether Switches or Aheads. */
    for(Sk=0;Sk<Statep->SwLen2;Sk++){
      Logic=Yes;
      if(Sj<StatesCount && Sk>=Statep->SwLen) Logic=No;
      if(Sj>=StatesCount && Sk<Statep->SwLen) Logic=No;
      if(Logic){
        Trigger=Statep->e[Sk].Trigger;
        Sym=SymLoc(*(Num2Sym+Trigger));
        if(Sym->s[0]=='\'' && Sym->s[1]>='A' && Sym->s[1]<='Z'){
          SetFlag(SetRqd,Sym->Num);
#if 1
          {      char * q, *v;
            q=&(Sym->s[0]);v=q+Sym->SymbolLength;
            while(q<v){
              printf("%c",*q++);
            }
          }
#endif
        }
      }
    } /* Sk */
/* SetRqd is now a bitstrip for the keywords of this state. */
/* Go down the runs of keywords in the Keys wallet, and see if there is a run
which completely contains the desired run. */
    Clear(Set);
    Jkx=0;/* Indexes where a label might be needed. */
    for(Jk=0;Jk<Keys->w.Needs;Jk++){
      Kv=Keys->e[Jk];
      if(Kv<0) SetFlag(Set,-Kv);
      if(Kv==Marker){
/* Set is the bitstrip for what was found in this run. */
/* Check for exactly the same. */
        if(memcmp(SetRqd,Set,sizeof(Set))==0){
          goto Embedded;
        }
/* Check for subset. */
        Assign(SetWork,Set);
        MemOr(SetWork,SetRqd,sizeof(SetRqd));
        if(memcmp(SetWork,Set,sizeof(Set))==0){
/* SetRqd is a subset. Can it be organised as the tail of the run? */
          Assign(SetWork,SetRqd);
          Jkx=Jk-1; /* Jkx moves towards head of list. */
CheckOff:;
          Kv=Keys->e[Jkx];
          if(Kv==Marker){
            goto AddAtEnd;
          }
          if(Kv<0){
            Kv=-Kv;
            if(QryFlag(SetWork,Kv)){
/* Note a keyword in the tail that is a flag of SetRqd. */
              OffFlag(SetWork,Kv);
/* Maybe they have all been found. */
              if(!MemAny(SetWork,sizeof(SetRqd))) goto Embedded;
              Jkx--;
              goto CheckOff;
            }
/* We have to move this one (at Jkx, value Kv) because we don't want it in the
tail. */
/* That means we have to find a place for it, where it can be exchanged with a
slot that we do want in the tail. */
            for(Jky=Jkx-1;;Jky--){
              Kvy=Keys->e[Jky];
              if(Kvy<0 && QryFlag(SetWork,-Kvy)){
/* Found one to swop. */
                Keys->e[Jky]=-Kv;Keys->e[Jkx]=Kvy;
                goto CheckOff;
              }
              if(Kvy>=0) goto NoJoy; /* Can't swap over a label. */
/* It was a keyword, but not one to exchange with. */
            }
          } /* Was a keyword */
        } /* Was subset */
NoJoy:;
        Jkx=Jk+1;/* Indexes where a label might be needed. */
        Clear(Set);
      } /* Was Marker */
    } /* Jk */
/* Add SetRqd to the list. */
AddAtEnd:;
    Jkx=Keys->w.Needs; /* Where label will go. */
    for(Kv=0;Kv<TriggerZi;Kv++){
      if(QryFlag(SetRqd,Kv)){
        Jk=Keys->w.Needs++;WalletCheck(Keys);
        Keys->e[Jk]=-Kv; /* Zero won't be a keyword. */
      }
    }
    Jk=Keys->w.Needs++;WalletCheck(Keys);
    Keys->e[Jk]=Marker;
Embedded:;
/* Add an entry point for Sj at position Jkx. */
    Jk=Keys->w.Needs++;WalletCheck(Keys);
    memmove(Keys->e+Jkx+1,Keys->e+Jkx,(Jk-Jkx)*sizeof(Keys->e[1]));
    Keys->e[Jkx]=Sj;
  } /* Jsk */
/*------------------------------------------------------------------------------
Construct the declaration for the table and reflect in states.
õ-----------------------------------------------------------------------------*/
  First=Yes;Middle=No;
  MsgWordsX=strdup(MsgWords);/* Make mutable copy. */
  /* Re-ordering of the sublists to put together those which messaging
  references.  This allows more compact reference. */
  WalletInit(KeysX);
  KeysX->w.Needs=Keys->w.Needs;WalletCheck(KeysX);
  Jkx=0;JkxLo=0;JkxHi=KeysX->w.Needs-1;ListMsg=No;
  /* Another quirk.  Because of messy keyword rules we want TO BY FOR list
  first so that we can manually add UNTIL WHILE. */
  /* One pass just to copy that one to KeysX */
  DoCopy=No;
  for(Jk=0;Jk<Keys->w.Needs;Jk++){
    Kv=Keys->e[Jk];
    if(DoCopy) KeysX->e[Jkx++]=Kv;
    if(Kv==Marker){ /* End of list. */
      if(DoCopy) break;
    }
    else if(Kv>0){
      Statep=(*States)[Kv];
      if(Statep->f.HasBy && Statep->f.HasTo && Statep->f.HasFor){
        Statetbf=Kv;
        KeysX->e[Jkx++]=Kv;
        DoCopy=Yes;
      }
    }
  } /* Jk */
#if 0
  ShowK();
#endif
  /* JkxLo is start of current section, on KeysX */
  JkxLo=Jkx;
  /* On this pass, the special list should not be copied. */
  DoCopy=Yes;
  for(Jk=0;Jk<Keys->w.Needs;Jk++){
    Kv=Keys->e[Jk];
    if(Kv==Marker){ /* End of list. Decide whether to retain copy at low
      end or move to high end. */
      /* It has already been copied low at JkxLo. */
      if(DoCopy){
        KeysX->e[Jkx++]=Kv;
        if(ListMsg){
          JkxLo=Jkx;
        }
        else{
/* Bug when this loop run in wrong direction! */
          for(j=Jkx-1,k=JkxHi;j>=JkxLo;j--,k--){
            KeysX->e[k]=KeysX->e[j];
          }
          JkxHi-=Jkx-JkxLo;/* Place to put next at top end. */
          Jkx=JkxLo;
        }
      }
      DoCopy=Yes;
      ListMsg=No;
    }
    else if(Kv<0){/* Is this word one used by messages? */
      char * p;
      if(DoCopy) KeysX->e[Jkx++]=Kv;
      Sym=SymLoc(*(Num2Sym-Kv));
      Sl=Sym->SymbolLength-2;
      for(p=MsgWordsX;p<=MsgWordsX+strlen(MsgWordsX)-20;p++){
        if(strncmp(p,Sym->s+1,Sl)==0
          && *(p+Sl)==' '){
            ListMsg=Yes;
            *p='='; /* Only want to find its first use. */
          }
      }
    }
    else{
      if(Kv==Statetbf) DoCopy=No;
      if(DoCopy) KeysX->e[Jkx++]=Kv;
    }
  } /* Jk */
  Keys=KeysX;
#if 0
  ShowK();
#endif
  NewLine();
  Map=1;
  for(Jk=0;Jk<Keys->w.Needs;Jk++){
    Kv=Keys->e[Jk];
    if(Kv>=0 && Kv!=Marker) {
/* This is where the particular state starts its scan. */
      if((Ushort)Kv<StatesCount){
        if(!MakeAsm){
          ShowS("/*S");ShowD(Kv);ShowC('@');ShowD(Map);ShowS("*/");
        }
        else{
          NewLine();
          ShowS("Keys");
          ShowD(Kv);
          ShowS(":;");
          ShowD(Map);
          Middle=Yes;
        }
        Statep=(*States)[Kv];
        Statep->Maps=Map;
        MaxMap=Max(MaxMap,Map);
      }
      else{
        Kv=Kv-StatesCount;
        if(!MakeAsm){
          ShowS("/*S");ShowD(Kv);ShowC('%');ShowD(Map);ShowS("*/");
        }
        Statep=(*States)[Kv];
        Statep->Mapr=Map;
      }
    }
    else {
      if(Kv==Marker){
#if 0
/* Nowadays do marking by flagging last element. Flag is with length. */
        if(MakeAsm){
          NewLine();
          ShowS(" db 0");
        }
        else ShowS(",0");
#endif
      }
      else{
/* An element in Keys has value of keyword, length, spelling of keyword.*/
/* The quotes that are in the dictionary don't go in the table.  */
        Sym=SymLoc(*(Num2Sym-Kv));
        Sl=Sym->SymbolLength-2;
/*  6-05-96 inelegant fixes to asm version. */
        if(!MakeAsm){
          if(First){
            ShowS("char Keys[]={");
            First=No;
          }
          else ShowC(',');
          ShowD(Sym->Num);  /* Obsolete but value unimportant. */
          Map++;
          ShowC(',');
          if(Keys->e[Jk+1]==Marker)
            ShowD(Sl+16);
          else
            ShowD(Sl);
          Map++;
          for(s=Sym->s+1;s<=Sym->s+Sl;s++){
            if(QryColumn()>70){
              NewLine();
              ShowC(',');
            }
            else ShowC(',');
            ShowC('\'');ShowC((char)toupper(*s));ShowC('\'');Map++;
          } /* s */
        }
        else{   /* Assembler version. */
          if(First){
            NewLine();
            ShowS("Keys char ");
            First=No;
          }
          else{
            /* Assembler gets confused by lots of commas. */
            if(QryColumn()>40) Middle=Yes;
            if(Middle){
              NewLine();ShowS(" db ");Middle=No;
            }
            else ShowC(',');
          }
          if(QryColumn()>70){NewLine();ShowC(' ');}
          ShowC('$');ShowA(Sym->s+1,Sl);ShowS("-KeysBase");
          /* There are flags for groups of keywords. */
          k=0;
          if(memcmp(Sym->s,KeyIf,strlen(KeyIf))==0
          || memcmp(Sym->s,KeyWhen,strlen(KeyWhen))==0){
            k=32;
          }
          if(memcmp(Sym->s,KeyDo,strlen(KeyDo))==0){
            k=64;
          }
          if(memcmp(Sym->s,KeyWith,strlen(KeyWith))==0
          || memcmp(Sym->s,KeyEnd,strlen(KeyEnd))==0
          || memcmp(Sym->s,KeyIterate,strlen(KeyIterate))==0
          || memcmp(Sym->s,KeyLeave,strlen(KeyLeave))==0){
            k=96;
          }
          if(memcmp(Sym->s,KeyOtherwise,strlen(KeyOtherwise))==0
          || memcmp(Sym->s,KeyThen,strlen(KeyThen))==0
          || memcmp(Sym->s,KeyElse,strlen(KeyElse))==0){
            k=128;
          }
          if(memcmp(Sym->s,KeyAddress,strlen(KeyAddress))==0){
            k=160;
          }
          if(memcmp(Sym->s,KeyForm,strlen(KeyForm))==0
          || memcmp(Sym->s,KeyTrace,strlen(KeyTrace))==0
          || memcmp(Sym->s,KeySignal,strlen(KeySignal))==0){
            k=192;
          }
          if(memcmp(Sym->s,KeyCall,strlen(KeyCall))==0
          || memcmp(Sym->s,KeyName,strlen(KeyName))==0){
            k=224;
          }
          Map++;
          ShowC(',');
          if(QryColumn()>70){NewLine();ShowC(' ');}
          if(Keys->e[Jk+1]==Marker)
            ShowD(k+Sl+16),Middle=Yes;
          else
            ShowD(k+Sl);
          Map++;
          ShowC(',');
          if(QryColumn()>70){NewLine();ShowC(' ');}
          ShowC('"');
          ShowA(Sym->s+1,Sl);
          ShowC('"');
          Map+=Sl;
        }
      } /* Is word */
    }
  }  /* Jk */
  printf("\nMaxMap %d",MaxMap);
  ShowS(",0,16");
  if(!MakeAsm)
    ShowS("};");
} /* Keywords */
/*------------------------------------------------------------------------------
16. Routine MsgChoice
õ-----------------------------------------------------------------------------*/
static Ushort MsgChoice2(Ushort mn);
/* Added 38.2 to avoid failure,  but in practice 36 v 36.2 is just choosing
reduction message to compete with 35.1, and either would beat 35.1 */
static Ushort Mns[8] = { 0, MajMin(21,1),
                            MajMin(27,1),
                            MajMin(25,16),
                            MajMin(36,2),
                            MajMin(36,0),
                            MajMin(38,3),
                            MajMin(35,1)};
static Ushort MsgChoice(Ushort mn){
 /* Return >0 if this is preferred to previous. */
 Ushort Now, Maybe, j, xxx;
 for(j=0;j<8;j++){
   if(mn==Mns[j]) break;
 }
 Maybe=j;
 for(j=0;j<8;j++){
   if(State.Error==Mns[j]) break;
 }
 Now=j;
 xxx=State.Error;
 if((Now < Maybe) != MsgChoice2(mn)) {
   printf("\n%d %d %d %d %d", Sj, xxx, Maybe, mn, Now);
   Failure;
 }
 if(Now < Maybe){
   State.Error=mn;
   return 1;
 }
 return 0;
}
static Ushort MsgChoice2(Ushort mn){
 /* Return >0 if this is preferred to previous. */
 Ushort Major, Minor;
 if(State.Error==0){
   State.Error=mn;
   return 1;
 }
 /* Msg21.1 always loses. */
 if(mn==MajMin(21,1)) return 0;
 if(State.Error==MajMin(21,1)) {State.Error=mn;return 1;}
 /* Msg35.1 loses apart from that. */
 /* Except not to 27.1 */
 if(mn==MajMin(35,1) && State.Error==MajMin(27,1)){State.Error=mn;return 1;}
 /* Also not to 36.0 */
 if(mn==MajMin(35,1) && State.Error==MajMin(36,0)){State.Error=mn;return 1;}
 if(mn==MajMin(36,0) && State.Error==MajMin(35,1)) return 0;
 /* Also not to 38.3 */
 if(mn==MajMin(35,1) && State.Error==MajMin(38,3)){State.Error=mn;return 1;}
 if(mn==MajMin(38,3) && State.Error==MajMin(35,1)) return 0;
 if(mn==MajMin(35,1)) return 0;
 if(State.Error==MajMin(35,1)) {State.Error=mn;return 1;}
 /* 25.16 preferred to 27.1 */
 if(mn==MajMin(25,16) && State.Error==MajMin(27,1)){State.Error=mn;return 1;}
 if(mn==MajMin(27,1) && State.Error==MajMin(25,16)) return 0;
 Major=State.Error/256;Minor=State.Error%256;
 printf("\n ?S %d Msg%d.%d",Sj,Major,Minor);
 Major=mn/256;Minor=mn%256;
 printf(" Msg%d.%d",Major,Minor);
 return 0;
}
static Ushort GetMajMin(void){
  char * s;Ushort m,n;
  m=0;n=0;Logic=No;
  for(s=Sym->s+3;s<Sym->s+Sym->SymbolLength;s++){
    if(*s=='.'){
      m=n;Logic=Yes;
      s++;n=0;
    }
    n=10*n+(*s-'0');
  }
  if(!Logic){
    m=n;n=0;/* Was no '.' */
  }
  return MajMin(m,n);
}
/*------------------------------------------------------------------------------
17. Routines EnList Differ AddRedSw
õ-----------------------------------------------------------------------------*/
static void EnList(Ushort j, Ushort j2){
  Ushort t;
  if(j==j2) return;
  if(QryFlag(InList[j],j2)) return; /* Already in list */
  if(QryFlag(Decided[j],j2)) Failure;
  t=Pairsp->w.Needs++;WalletCheck(Pairsp);
  Pairsp->e[t].Left=j;
  Pairsp->e[t].Right=j2;
  SetFlag(InList[j],j2); /* Say pair is in list. */
  SetFlag(InList[j2],j);
  if(QryFlag(RedSwPair[j],j2)){
    AddRedSw(j,j2);
  }
  return;
}
static void Differ(Ushort j, Ushort j2){
  struct StStruc *Sjp, *Sjp2;
  Ushort k,k1,t,t2;
  if(j==j2) return;
  if(QryFlag(Decided[j],j2)){ /* Worked out before. */
    if(QryFlag(Different[j],j2)) longjmp(DifferSig,1);
    return;
  }
  Sjp=(*States)[j];
  Sjp2=(*States)[j2];
  /* If they differ in simple things it will already have been decided. */
  for(k=0;k<Sjp->SwLen2;k++){
    t=Sjp->e[k].Goto;
    t2=Sjp2->e[k].Goto;
    if(QryFlag(Decided[t],t2)){ /* Worked out before. */
      if(QryFlag(Different[t],t2)) longjmp(DifferSig,1);
      continue;
    }
    else EnList(t,t2);
  }
  for(k=0;k<2*Sjp->RedSwCt;k++){
    t=*(Sjp->RedSw+k);
    t2=*(Sjp2->RedSw+k);
    if(QryFlag(Decided[t],t2)){ /* Worked out before. */
      if(QryFlag(Different[t],t2)) longjmp(DifferSig,1);
      continue;
    }
    else EnList(t,t2);
  }
  return; /* Nothing to show different. */
} /* Differ */

static void AddRedSw(Ushort j, Ushort j2){
/* Go through the reduction switches to see what needs EnListing.  If
A & B triggers are in the list then AA and BB, the corresponding targets
must also be. */
/* On the first call we just set up a look-aside to speed up later calls. */
/* Both args 0 on first call. */
  Ushort Sj,k,k1,Sr,t,Sr2,t2;
  struct StStruc * Statep;
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
    if(Statep->RedSw){
      for(k=0;k<Statep->RedSwCt-1;k++){
        Sr=*(Statep->RedSw+2*k);
        t=*(Statep->RedSw+2*k+1);
        for(k1=k+1;k1<Statep->RedSwCt;k1++){/* All pairs k, k1 */
          Sr2=*(Statep->RedSw+2*k1);
          if(j+j2==0){
            SetFlag(RedSwPair[Sr],Sr2);
            SetFlag(RedSwPair[Sr2],Sr);
          }
          else{
            if((j==Sr && j2==Sr2) || (j==Sr2 && j2==Sr)){
              t2=*(Statep->RedSw+2*k1+1);
              if(QryFlag(Decided[t],t2)){ /* Worked out before. */
                if(QryFlag(Different[t],t2)) longjmp(DifferSig,1);
                continue;
              }
              else EnList(t,t2);
            }
          }
        }
      }
    }
  }
  return; /* No evidence of difference. */
}
static char * ToName(char * s, Ushort n){
  Ushort j;
  for(j=0;j<Dim(Names);j+=2){
    if(strlen(Names[j])==n && memcmp(s,Names[j],n)==0){
      return Names[j+1];
    }
  }
  return NULL;
}
#if 0
/*------------------------------------------------------------------------------
   Construct structure per State.
õ-----------------------------------------------------------------------------*/
  for(Sj=0;Sj<StatesCount;Sj++){
    Statep=(*States)[Sj];
/* And now the structure that controls the switching. */
/* We declare a different structure for each state but the structures are
similar. */
/* First fields are 2 indices into the keyword table and a reduction target
and a prune count. (j & k & r & p) */ /* April 94 - j not used. */
/* Flag c */
/* The error number and count for the switch. (e & z) */
/* Elements within the switch are Trigger/Goto pairs. (t & g) */
/* Add exits Dec 95. */
    if(Statep->Recognise){
      Sym=SymLoc(*(Num2Sym+Statep->Recognise));
      if(Sym->IsExit){
        char *p;
        NewLine();
        ShowS("void ");
        for(p=Sym->s;p<Sym->s+Sym->SymbolLength;p++){
          if(*p=='.') break;
          ShowC(*p);
        }
        ShowS("(void);");
      }
    }
    NewLine();
    ShowS("struct{Ushort k;Ushort r;void (*ex)(void);Uchar p;Uchar c;");
    ShowS("Ushort e;Uchar z;");
    if(Statep->SwLen3){
      ShowS("struct{Ushort t;Ushort g;}x[");
      ShowD(Statep->SwLen3);ShowS("];");
    }
/* With initializing. */
    NewLine();
    ShowS("} S");ShowD(Sj);ShowS("={");
/*
    ShowD(Sk);ShowC(',');
    ShowD(Statep->Mapr);ShowC(',');
*/
#if 0
/* Tricky fix for Msg 10.1 */
    if(Statep->Maps && Statep->Maps<=7) Statep->Maps=1; /* Adds END
to instructionlist */
#endif
    ShowD(Statep->Maps);ShowC(',');
    ShowD(Statep->Recognise);ShowC(',');
    Logic=No;
    if(Statep->Recognise){
      Sym=SymLoc(*(Num2Sym+Statep->Recognise));
      if(Sym->IsExit){
        char *p;
        Logic=Yes;
        for(p=Sym->s;p<Sym->s+Sym->SymbolLength;p++){
          if(*p=='.') break;
          ShowC(*p);
        }
      }
    }
    if(!Logic) ShowS("NULL");
    ShowC(',');
    ShowD(Statep->RHScount);ShowC(',');
    ShowD(Statep->Careful+2*Statep->HasCat+4*Statep->Valued);ShowC(',');
    ShowD(Statep->Error);ShowC(',');
    ShowD(Statep->SwLen3);ShowC(',');
    for(Sk=0;Sk<Statep->SwLen3;Sk++){
/* Didn't work with curlies around structures. */
      ShowD(Statep->e[Sk].Trigger);
      ShowC(',');ShowD(Statep->e[Sk].Goto);ShowC(',');
    }
    ShowS("};");
  } /* Sj */
  NewLine();
/* And an array to convert from state number to state structure. */
  ShowS("void * States[]={");
  for(Sj=0;Sj<StatesCount;Sj++){
    if(QryColumn()>75) NewLine();
    ShowS("&S");ShowD(Sj);ShowC(',');
  } /* Sj */
  ShowS("};");
  NewLine();
#endif
