/*  One could debate what a "state" of a parser is.  If two states are different in terms of positions in the grammar recognised, but lead to the same action by the parser/interpreter, are they essentially different states?
Here we follow the literature and regard a state as identified by a set of positions in the grammar. (Positions that the parsing may be at when parsing is in that state).  Positions are described in terms of where the caret is.
Thus A:=^B C describes "about to scan an instance of A", while A:=B C^ describes "an instance of A recognised".

Obviously, the initial state is position Starter:=^Whatever.  From this state other states will be reachable - which other states depending on what starts Whatever. 

When we say a state is identified by a set of caret positions, that could be a "core" set or a full set (aka the "closure").  The difference arises because if A:=B^C is in the set then C:=^Whichever is also implicitly in the set because 
the state is expecting C.  When these transitives are actually in the set then that is the closure; when they are not it is the core set.

A position can be identified by the production is in together with how far through the production the caret is.  The production is identified by its index in Gram and the caret offset from there is a small number so together than can 
held as an int.  Thus identification of a state is a collection of ints, here aka Positions.  

The transitions from state to state are also recorded.   A transition records the Target state to be entered when the Discriminator is next in the program being parsed.  A check on the discriminators tells us whether
the grammar is ambiguous (aka has conflicts).   

There are three types of transition, in respect of parser actions.  If the discriminator is end-of-file or a Msg then parsing stops. If the caret is at rightmost possible the Lhs production is recognised.  This is known as reduction.
The third type of transition is a shift - progress is made across the Rhs.

If the transitions vector for some state has two reductions then that is a conflict, unless their lookaheads have no overlap. We only allow one anyway.
The shifts cannot conflict with one another because they were constructed using a map so the discriminators are unique to their set.
The shifts can conflict with the reduction (if there is one).  (At parser time, if there is no conflict then the reduction only occurs if the current token does not allow the shift)

The look-ahead associated with a Position is not used to establish the transitions, it is only used to detect conflicts.  The look-ahead has the terminals to be expected immediately after the LHS is reduced to.
The transitions indicate by the discriminators what causes shift to the next state.  Something that is in the lookahead for a reduction and also in the set of discriminators indicates a conflict.

Rexx has just one conflict, the "if A then if B then C; else D" situation.  The "else" might pair with the second if, a shift, or might pair with the first by initially reducing the "if B then C".  A non-grammar rule makes it a shift. 
*/
  typedef unsigned int Position;  // An index onto Gram which will be split to index of production + caret offset. 
  typedef unsigned int StateNdx; // Subscript on States.
  typedef unsigned int GramNdx; // Subscript on Gram.

  typedef struct{
    Position p;
    bitset<TermLimit> Ahead;
  } PositType; 
  PositType ThisPosLook;
  vector<PositType> Closure;  // The Position field will not have duplicate values but this is by reason of coded search, not using STL map.

  typedef map<Position, bitset<TermLimit>> PositsType; // It is a map because there will be no duplicates of Position.  Hence reference to components of an element as first (the Position) and second (the LookAhead).
  map<Index,PositsType> Gotos; // The record of coresets (.second) reached by move over operand (.first).

  typedef struct{ // For transition element.
    Index Discrim;
    StateNdx Target; 
  } TransitType;
  TransitType ThisTransit;

  typedef struct{ // For State element. There are some fields that are not used in establishing the states.  They are used later to find parser states.
    bool Uncertain;  // True when some Core lookahead not yet propagated.
    PositsType Core; // Positions identifying the state.

    vector<TransitType> Transits; // Transitions on Discrim to Target.
    bitset<TermLimit> ShiftKeys; // Shows which keywords are discriminators in the Transits.
    unsigned short KeysOffset; // To find keys list.
    vector<TransitType> Froms; // Transits in reverse direction.

    bool HasRed; // True if state includes a reduction.
    Index RedPos; // Position in Grammar describing reduction.
    vector<TransitType> RedSwitch; // Transitions (state-on-stack, state) when reduction.
    bitset<TermLimit> RedAhead;
    unsigned short Reference;  // 0 or 1 units pushed by entering state.
    unsigned short Prune;// Prune of stack on a reduction.

    unsigned short Action;  // Action associated with the reduction.
    unsigned short MsgMN;  // Error message associated with a shift. 
    unsigned short Physical;  // How many slots for this one in the assembled table? 

    unsigned short ParseStateNum; //  Number of Parser states is less than number of Grammar states because some of latter equivalent.  Hence the States vector is renumbered to become parser states.
    unsigned short GramStateNum; // Only set for printout purposes.
    unsigned short StateAcceptsGroups;
    unsigned short ShiftNdx;
    unsigned short RedSubsetOf;
// Reduction for Rexx grammar has at most three steps.  A bit crude but simple to use fixed record.
    unsigned short RedStep[3];
    unsigned short Arg[3];
    unsigned short Next[3];
  } StatesType;
  StatesType ThisState;
  vector<StatesType> States;

  int ConflictCount=0;
  int ReductionsFlaw = -1; // No flaw found yet.

  void CloseIt(); // Forms Closure from ThisState.
  void ShowState(int s);
  
void NoteStates(){
  if(strchr(Switches,'V')){ // V for Verbose
    Out << endl << "States are shown as state number then core caret positions then switch for following states =>" << endl; 
  } // V
// Make a pass over Gram, to note what can start each production.  Then later all the terminals that start a production will be available in a bit strip.
  for(GramNdx g=0;g<GramZi;g++){
    int Lhs=Gram[g++];Index Head=Gram[g++];
/* There is clumsiness because C++ bitsets can be 'or'ed but C++ bit vectors cannot (except by looping code, I believe).  The use of bitsets with their fixed lengths is not an elegant fit with the natural compact numbering of ProdTerms.   
*/
    if(Head>=ProdCount)
      ProdTerms[Lhs].Begins.set(Head-ProdCount,true);  // First of Rhs is a lookahead for the Lhs. Here a terminal.
    else 
      ProdTerms[Lhs].BeginProds.set(Head,true);  // Here a production.
    while(Gram[g]>=0) g++; // Skip the rest of Rhs.
  } // g 

/* If B was found to start A and C to start B then C can start A. */
/* This double loop is called Warshall's algorithm. It records all these relations.*/
  for(Index q=0;q<ProdCount;q++){
    for(Index p=0;p<ProdCount;p++){
      if(ProdTerms[p].BeginProds[q]){
        ProdTerms[p].BeginProds |= ProdTerms[q].BeginProds; // Which productions start the production.
        ProdTerms[p].Begins |= ProdTerms[q].Begins; // Which terminals start the production.
      }
    } //p
  } //q

// The Starter state is the Starter production with the caret position leftmost.
  bitset<TermLimit> AheadNull;
  AheadNull.reset();
  ThisState.Core.insert(pair<Position,bitset<TermLimit>>(0,AheadNull));
  ThisState.Uncertain = true; // Mark it to be processed.
  States.push_back(ThisState); 
  int Uncertains = 1;

// Fan-out from this state until there are no more new ones.
  while(Uncertains)
  for(StateNdx InPlay=0;InPlay<States.size();InPlay++){
    if(!States[InPlay].Uncertain) continue; // In later passes, most Aheads are already established.
    States[InPlay].Uncertain = false; // In expectation.
    Uncertains--;
    ThisState = States[InPlay];
    CloseIt();
    Gotos.clear();
/* For each of the elements in Closure we look at what progressing the caret position by one would result in - what would the caret be moved over and what would the new position be?  From this data a map is developed from whatever is moved over 
to the set of positions reached.  Each set of positions becomes the coreset for a new state, unless there is already a state recorded with that coreset.
*/
    for(int c=0;c!=Closure.size();c++){ // Scan Closure
      Position t; unsigned int ProdPos, CaretPos;
      t=Closure[c].p; ProdPos=t/Split;CaretPos=t%Split;
      // Maybe the caret position is already off the rightmost end of the production.  Then there is nothing to move over. 
      GramNdx g=ProdPos+CaretPos+1; // Position in the grammar
      if(Gram[g]<0){
/* With Rexx there is at most one reduction on one of these states so postpone any thinking about a more general case.   
*/    
        if(States[InPlay].HasRed) ReductionsFlaw = InPlay;   
        States[InPlay].HasRed = true; 
        States[InPlay].RedPos = ProdPos;  
        States[InPlay].RedAhead = Closure[c].Ahead;
        continue;
      }
      Index m=Gram[g];// What is to be moved over. (The discriminator)
      t++; // The new position.
      // If m is not already in Gotos then m now maps to t.
/* The Aheads refer to what can follow the Lhs of the production involved, not what can follow the specified position in that production.   
*/
      map<Index,PositsType>::iterator i = Gotos.find(m);
      if(i==Gotos.end()){// First encounter of this discriminator.
        PositsType a; 
        a.insert(pair<Position,bitset<TermLimit>>(t,Closure[c].Ahead));
        Gotos.insert(pair<Index,PositsType>(m, a)); 
      } else i->second.insert(pair<Position,bitset<TermLimit>>(t,Closure[c].Ahead)); // Add t to set for m if m already in Gotos.
    } // c

// The Gotos have been made from the Closure. Scan the Gotos and set Transits for current state. Also add new states to the vector of States.
    for(map<Index,PositsType>::iterator i = Gotos.begin();i!=Gotos.end();i++){
      // Is this coreset already known amongst States?
/* This is set comparison but implementation is not that simple.  There does not seem to be an STL way of referring to the set of keys of a map. 
*/
      StateNdx Search;
      PositsType::iterator p,q;
      for(Search=0;Search<States.size();Search++){
        if(States[Search].Core.size()!=i->second.size()) continue; // Sets not the same since not same size.
// I think STL can be relied on to have equal sets in same order here.  Serially compare the Positions in the maps.
        for(p=i->second.begin(),q=States[Search].Core.begin();p!=i->second.end();p++,q++) if(p->first!=q->first) break; // Loop looking for unequal.
        if(p==i->second.end()){// Equal sets on the positions.  Target will thus be the existing state, [Search].
          // Run the loop again to check for Aheads enlargement.
          for(p=i->second.begin(),q=States[Search].Core.begin();p!=i->second.end();p++,q++){
            bitset<TermLimit> Ahead;
            Ahead = p->second | q->second; // Merge the Aheads.
            if(Ahead!=q->second){// Extra true.
              q->second = Ahead;
/* Not clear to me what is going on here but when a state is re-encountered, eg S[16] with transit to S[1}, the lookaheads may be larger.  That cannot change any coresets or transits but it is relevant to the conflicts test.
So the fan-out of such unstable states has to be repeated - the repetitions will always find existing targets.  The re-process may propagate enlargement of the Aheads.  
*/
              if(!States[Search].Uncertain){// Rest fields that will be recomputed.
                States[Search].Uncertain = true;
                States[Search].HasRed=false; 
                States[Search].Transits.clear();
                Uncertains++;
                // Tricky.  If it is InPlay that we have reset (to be processed later) we must iterate the InPlay loop now.
                if(Search==InPlay) goto InPlayNext;
              }  
            } // Enlarges
          } // p & q
          break;    // From Search loop.
        } // Equal sets.
      } // Search 
      ThisTransit.Discrim=i->first;
/* Error messages come through from the syntax this way but the target is not meaningful because in parsing the error will be raised.
  We put them in the shift list (with zero target) for convenience in testing core-state equality. (Also msg preference.)
*/
	 if(ProdTerms[ThisTransit.Discrim].MsgMN) Search=0;
      else 
      if(Search==States.size()){// An additional state is needed.
        ThisState.Transits.clear(); // No transits established for the added set yet.
        ThisState.Uncertain = true; Uncertains++;
        States.push_back(ThisState);
        States[Search].Core = i->second;  // Core set of added state as made in Goto.
      }
      // This is a transition from the current state.
      ThisTransit.Target=Search;
      States[InPlay].Transits.push_back(ThisTransit);
    } // i over Gotos
InPlayNext:;
  } // InPlay and Uncertains.

// Now the number of states and the lookaheads have settled, states can be checked and initialised.
  bool TestLater;
  for(StateNdx InPlay=0;InPlay<States.size();InPlay++){
//    States[InPlay].Chain = InPlay; // State is equal to itself.
    TestLater = States[InPlay].HasRed;
    if(States[InPlay].HasRed){ 
      ThisState = States[InPlay];CloseIt();
// Make a bitset of the terminals that are discriminators in the transitions.
      bitset<TermLimit> Check;
      Check.reset();
      for(int t=0;t!=States[InPlay].Transits.size();t++)
        if(States[InPlay].Transits[t].Discrim>=ProdCount) Check[States[InPlay].Transits[t].Discrim-ProdCount] = true;
// Find the reduce and note what follows it.
      for(int c=0;c!=Closure.size();c++){ // Scan Closure
        Position t; unsigned int ProdPos, CaretPos;
        t=Closure[c].p; ProdPos=t/Split;CaretPos=t%Split;
        // Maybe the caret position is already off the rightmost end of the production.  That is a reduce.
        GramNdx g=ProdPos+CaretPos+1; // Position in the grammar
        if(Gram[g]<0){
          Check &= Closure[c].Ahead;// Look for what is both a discriminator of shift and a follower if reduction.
          if(Check.any()){
// STL doesn't tell us which bit is true.
             for(unsigned int f=ProdCount;f<ProdCount+TermCount;f++){ // thru terminals
             // No conflict on messages since Rexx has special rules on message priority.
               if(Check[f-ProdCount] && !ProdTerms[f].MsgMN){
                 Out << endl << "Conflict in state " << InPlay << " resolved in favour of shift!! Terminal:" << ProdTerms[f].Symbol;
			  // (Will need to run with option "V" to see the actual state)
                 ConflictCount++;
                 States[InPlay].HasRed = false;
               }
             } // f
          } // any
        } // Reduce found
      } // c
    } // Was Reduce
// A state with no reduce ought to have an error message, so the parser will know what to do if no discriminator matches the latest token.
// Messy because we don't want this test if lack of Reduce was due to conflict. (Or Starter=...)
    if(!TestLater){
      bool HasMsg = false; 
      for(int t=0;t!=States[InPlay].Transits.size();t++)
        if(ProdTerms[States[InPlay].Transits[t].Discrim].MsgMN) HasMsg = true;
      if(!HasMsg){
        Out << endl << "What error message for state " << InPlay << "?";
      }
    } // No Reduce
  } // InPlay
} // NoteStates


void CloseIt(){// Makes Closure from ThisState.
/*  I tried to write this with Closure as a map, so that the STL library did the avoidance of duplicate positions.  But I could not fit that to the action required when lookaheads got denser.  So this version has Closure as an unordered
vector of pairs, position and lookahead.

The picture is that a position has a component to identify a production and a component to identify an offset into the Rhs of that production.  
If the offset puts the caret to the left of a production, all the possible beginings of that production are added to the closure. 
*/

// Initialise the vector with coreset of parameter ThisState..
  Closure.clear();
  for(PositsType::iterator j=ThisState.Core.begin();j!=ThisState.Core.end();j++){
    ThisPosLook.p = j->first; ThisPosLook.Ahead = j->second;
    Closure.push_back(ThisPosLook);
  } // j

// Take from the vector a single position.  Ensure it is in Closure and put its derivatives on the list.
  for(unsigned int k=0;k!=Closure.size();k++){
Rework: // May need to reduce k and come here.
    PositType t; unsigned int ProdPos, CaretPos;
    t=Closure[k];
    bitset<TermLimit> Ahead;
    Ahead.reset();
/* If the position is off the end of the production, or is at a terminal, then there is nothing to add to the closure.
Otherwise the position in Gram gets us to the name of a group.  The starts of each member of the group are to be added to the closure.
If the group name is followed by something, in the grammar, then we know the starts of that something are Ahead for the new positions we are adding to the closure.
*/
    ProdPos=t.p/Split;CaretPos=t.p%Split;
    Index Lhs = Gram[ProdPos];
    GramNdx g=ProdPos+CaretPos+1; // Selects what the caret preceeds. 
    // Maybe the caret position is off the rightmost end of the production.  
    if(Gram[g]<0) continue; // Gram is signed, Group is not.
    Index Group=Gram[g]; // Item that caret preceeds.
    if(Group>=ProdCount) continue; // A terminal
    // We are going to put all the variants of this Group in the closure and we know something of their lookaheads if the grammar at this point shows something ahead.
    int Follower = Gram[g+1];
    if(Follower>=0){
      if((unsigned int) Follower>=ProdCount) Ahead[Follower-ProdCount]=true;
      else Ahead=ProdTerms[Follower].Begins;
    } 
    else Ahead=t.Ahead; // Inherit in case like A=B.
    // Now loop through the variants of Group.
    g = ProdTerms[Group].ProdPos;
    while(g<GramZi && Gram[g]==Group){
      // Is this position already in the Closure?
      Position f = g*Split; // With caret 0
      Index s;
      for(s=0;s<Closure.size();s++){
        if(Closure[s].p == f){  // Already there. Union the lookaheads.
          Ahead |= Closure[s].Ahead;
          bool Enlarged = (Ahead != Closure[s].Ahead);
          Closure[s].Ahead = Ahead;
          // It is a concern if the lookahead has enlarged, in the case where the unenlarged might have been propagated. 
          if(Enlarged && s<k){
            k=s;
            goto Rework;
          }
          break; // Leave s loop.
        } // Found
      } // s
      if(s==Closure.size()){// Not already there.
        ThisPosLook.p = f;ThisPosLook.Ahead = Ahead;
        Closure.push_back(ThisPosLook);
      }
      while(Gram[g++]>=0);      // Skip to Break
    } // Variants of Group.
  } // k
} // CloseIt

void ShowState(int s){
/* ShowState won't make its full display if called before States content is finalised. 
*/
  Out << endl << "G[" << s << "] ";
  unsigned short m = States[s].MsgMN;
  if(m) Out << "E" << m/256 << '.' << m%256 << ' ';
  for(PositsType::iterator c = States[s].Core.begin();c != States[s].Core.end();c++){
    GramNdx g = c->first/Split; int f = c->first%Split;
    Out << ProdTerms[Gram[g]].Symbol << "=" ;
    for(int j=0;;j++){// Across Rhs.
      if(j==f) Out << "^";else Out << ' ';
      int i=Gram[++g];
      if(i<0) break;
      Out << ProdTerms[i].Symbol; 
    } // j 
    Out << ";";
  } // c
  if(States[s].Transits.size()){
    Out << endl;
    for(unsigned int t=0;t<States[s].Transits.size();t++){  
      Out << ' ' << ProdTerms[States[s].Transits[t].Discrim].Symbol << "=>" << States[s].Transits[t].Target;
    } // t
  } 
  Out << endl;
  if(States[s].RedSwitch.size()){
    for(unsigned int t=0;t<States[s].RedSwitch.size();t++){  
      Out << ' ' << States[s].RedSwitch[t].Discrim << ':' << States[s].RedSwitch[t].Target;
    }  // t 
  } 
} // ShowState