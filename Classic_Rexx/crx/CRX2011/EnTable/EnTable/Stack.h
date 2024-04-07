/* The shift transitions between states were recorded with discriminators that were both upcoming terminals and upcoming productions.  The parser won't use the latter - we want the parser to work on the latest token.
The parser necessarily has a stack on which the components of a Rhs are kept during progress through the Rhs (and replaced by the Lhs when all there).  The method of Aoe et al uses the content of the stack, in
conjunction with the upcoming token, to decide the parser action.

At this stage we convert from states of the grammar to states of the parser.  The latter are fewer and more complex.
We must convert the state info into instructions for the parser when at a particular parser state.  The relevant instructions are covered by the explanation of the instructions when printed with the "V" (for verbose) option:
The state number will not be the same as the original state numbering - the states are fewer and renumbered.  The parser state number is followed by the grammar state number(s) in square brackets".
The letter 'F' indicates that the state number should be stacked, so that it can be tested for in later decisions. (A reference state)
The letter 'S' follows if there are shifts from the state.
The letter 'R' and a number indicates a reduction to the state with that number. 
The letter 'P' and a number says how many items are to be pruned from the stack.
The letter 'X' and a number indicates an exit to be taken. (Called an exit because control leaves the parser, although control returns).  The number is the number of the action to be taken, as provided by the symbol of
the grammar, e.g. the the 30 of do_check.30 
It is a peculiarity of Rexx that concatenation can be implied, e.g. "Alpha="Alpha, when there is no explicit operator.  '||' indicates such a state.
The letter 'E' will be followed by the major and minor parts of an error code, e.g. 35.1   This is the syntax error raised if the conditions for other action are not met.
The letter 'K' is followed by a number indicating the position in the keyword list at which to start looking for valid keywords for this state.
After this comes the list of shifts.  The discriminator (aka trigger) precedes '=>' and the state to shift to follows.
After this comes the list of reductions.  The trigger is a state number to be found on the stack and ':' is followed by the state to reduce to. 

As background, here is algorithm the parser in CRX uses. (See syntax.as of the actual code).
  Start at State 0. 
  Cycle:
  While HasShift is off 
    if HasAction call the action at address from the state.
    Prune the stack by amount from the state.
    Decide where to reduce to. (Maybe a state given in this state (absolute or relative), or maybe necessary to test the state now on top of stack (a reference state). 
  If flagged as error state raise syntax error (major&minor codes from state) Exit this code.
  Note if Abuttal is implied possibility at this state.  
  Get next token.  (If keyword possible, state provides label in table of keywords, where to search)
  If token not acceptable in this state goto reduction/error activity above. (Acceptance is determined by bit matrix, one coordinate from state, the other from the token data.)
  Determine shift target (maybe given in state, maybe involves calculation from token)
  Special case "mock shift" - see note below. 
  If new state is a reference state, note that on the stack.
  Goto Cycle

The "mock shift" is something that is encoded along with the shifts but has no target.  The code uses this for a state that has a reduce, some shifts, an error or errors in both the shift list and the reduce aheads, and the Standard 
gives preference (Standard 6.4.5) to the error message from the shift list. (There are about 30 such states, mostly arising because Msg21.1 needs to be avoided).  The reason for complicating the "if token doesn't call for shift then reduce" rule
is because reducing would go to a state with the unwanted error message.
The "mock shift" is checking that there would be an error after reduce by reducing only on tokens that would not give an error after reduction.  If the token would give an error on reduction, the prefered shift message is given instead.

This mechanism works at the expense of some parser complication.  I have not thought through whether some alteration of errors attached to states at table generation time could achieve the same effect. 

This stage is the first that produces assembler code to be part of the CRX interpreter.  Routines that output the assembler code have names that start "Write" and appear at the end of the present code. The main routines that describe
the parser table generation on file Out have names that start Show.
*/
void WriteKeywords();
void Keywords();
int Separator = -1; // special label separates keyword lists within merged.
void ShowParserStates();
void WriteGroupMembers();
unsigned GroupCount = 0, NonKeyCount;
typedef struct{ 
  unsigned short AcceptNdx;
  unsigned short ShiftNdx;
  bool UseArray;
  unsigned short Tentative; // Target state if UseArray not set;
} GroupType;
GroupType ThisGroup; 
vector<GroupType> Groups;

bool BetterMsg(unsigned short, unsigned short, unsigned int);
// These definitions for keyword analysis:
struct KeyListRecord {
 int ListLen;
 unsigned int OfState; 
};  // KeyListRecord 

vector <KeyListRecord> Lists; 
KeyListRecord ThisKLR;

bool LongFirst(KeyListRecord a, KeyListRecord b) {
   return a.ListLen>b.ListLen;
}

bool TransitSort(TransitType a, TransitType b) {
   if(a.Discrim!=b.Discrim) return(a.Discrim<b.Discrim);
   return a.Target<b.Target;
}
// These for noting parser states from grammar states.
  bool SameTargets(unsigned, unsigned);
  unsigned int StatesCount;
  vector<vector<bool>*> BitMatrix; 
  unsigned short ParseStateNum;
  vector<bitset<TermLimit>*> TermBitMatrix; // To note how terminals differ.

void NoteStack(){
  if(strchr(Switches,'V')){ // V for Verbose
    Out << endl << "Parser states are described as follows." << endl; 
    Out << "The letter 'S' follows the state number if there are shifts from the state." << endl; 
    Out << "The letter 'R' and a number indicates a reduction to the state with that number." << endl; 
    Out << "The letter 'P' and a number says how many items are to be pruned from the stack." << endl; 
    Out << "The letter 'X' and a number indicates an exit to be taken." << endl; 
    Out << "The letter 'F' indicates that the state number should be stacked, so that it can be tested for in later decisions. (A reference state)" << endl; 
    Out << "The letter 'E' will be followed by the major and minor parts of an error code, e.g. 35.1" << endl; 
    Out << "The letter 'K' is followed by a number indicating the position in the keyword list at which to start looking for valid keywords for this state." << endl; 
    Out << "After this comes the list of shifts, each shift with +>" << endl; 
    Out << "After this comes the list of reductions, each with ':'" << endl; 
  } // V

/* Up to this stage messages (Msgnn) have been treated as terminals.  Unlike the real terminals, they are not tokens in the subject Rexx program.  
We can shorten the switch lists so that there is at most one MsgMN, using the ANSI Standard 6.4.5 rules about prefered messages.
Then we can take that message out and put it with the state.

There are complications when a message on shift is prefered to a message from reduction because the parser needs to be told when reduction would not lead to a message. 

Note - I think the Standards Committee did a poor job with 6.4.5.   They should either have written the grammar to allow only the preferred message, or they should have provided guidance rather than imperative in choice.
*/
  for(unsigned int Statej=0;Statej<States.size();Statej++){
    unsigned short BestSmsg = 0, OtherSmsg = 0, BestSmsgI = 0, OtherSmsgI = 0;
    for(unsigned int t=0;t<States[Statej].Transits.size();t++){
      unsigned short m = ProdTerms[States[Statej].Transits[t].Discrim].MsgMN;
      if(m){// Copy value and erase from transits;
        if(BestSmsg == 0){
          BestSmsg = m;
          BestSmsgI = States[Statej].Transits[t].Discrim;
        }
        else{
          OtherSmsg = m;
          OtherSmsgI = States[Statej].Transits[t].Discrim;
        }
        States[Statej].Transits.erase(States[Statej].Transits.begin()+t);t--;// Drop msg from transits.
        // Update BestSmsg.
        if(OtherSmsg){
          if(BetterMsg(OtherSmsg, BestSmsg, Statej)){BestSmsg = OtherSmsg; BestSmsgI = OtherSmsgI;}   
        }
      } // m
    } // t 
    States[Statej].MsgMN = BestSmsg; 

// Similarly, one can look in the Aheads for alternative msgs after reduction.
// It would be a nasty complication if BestSmsg was prefered to some reduction message but not to another reduction message.  Fortunately the Standard avoided that.
    unsigned short BestRmsg = 0;
    if(States[Statej].HasRed) 
    for(unsigned int Termj=0; Termj < TermCount; Termj++){
      if(States[Statej].RedAhead[Termj] && ProdTerms[ProdCount+Termj].MsgMN){
        BestRmsg = ProdTerms[ProdCount+Termj].MsgMN;
        break;
      }
    } 
// Which message to emit?
    if(BestSmsg && BestRmsg){
// If the Rmsg is at least as good as the Smsg then we don't need the Smsg for this state; just reduce instead.
       if(!BetterMsg(BestSmsg, BestRmsg, Statej)){ 
         if(strchr(Switches,'V')) Out << "Unused Shift message, State " << Statej << endl;
	    States[Statej].MsgMN = 0;
       } 
       else{//  Smsg error even if discrims not matching current token. Add aheads to switch list as explicit reduction instruction.  (Mock shift).
         for(unsigned int Termj=0; Termj < TermCount; Termj++){
           if(States[Statej].RedAhead[Termj] && !ProdTerms[ProdCount+Termj].MsgMN){
             if(strchr(Switches,'V')){
               Out << "LookAhead " << ProdTerms[ProdCount+Termj].Symbol << " added, State " << Statej << endl;
             } 
             ThisTransit.Discrim = ProdCount+Termj;
             ThisTransit.Target = 0;
             States[Statej].Transits.push_back(ThisTransit);
           }
         } // Termj
       }    
    } 
  } // Statej 

/* We next invert the Goto Transits so as to get a list, for each state, of the states it is reached from.  This is a help with Reduce analysis later.
*/
  for(unsigned int Statej=0;Statej<States.size();Statej++){
    States[Statej].Reference = 0; // Initiialise.  Not used immediately.
    for(unsigned int t=0;t<States[Statej].Transits.size();t++){
      ThisTransit.Discrim = States[Statej].Transits[t].Discrim;
      unsigned int s = States[Statej].Transits[t].Target;
      ThisTransit.Target = Statej;  // Froms of s to get Statej-on-this-trigger.
      if(s) States[s].Froms.push_back(ThisTransit);
    } // t 
  } // Statej

/* We need to analyse, for a reduction, the collection of states that could have been in play when the production now fully recognised was embarked on.
We start with the knowledge of being in Statej which has a Reduce production.  The grammar for the Reduce production tells us, in its RHS, what was recognised in development in left to right order. 
So if we take the rightmost trigger (aka discriminator) from that grammar production, together with the Froms of Statej, we can tell what collection of states was current before that trigger brought us to Statej.
And from that set and the adjacent trigger in the grammar we can similarly deduce what collection of states was two steps back from Statej.  And so on.

In the first use of PreDiscrim and PostDiscrim we are only interested in the states (.first) but later we work with the amount to prune stack (.second).
*/
  vector<pair<unsigned int, unsigned int>> PostDiscrim, PreDiscrim; 
  for(unsigned int Statej=0;Statej<States.size();Statej++){
    if(Statej==379)
      Statej=Statej;
    if(!States[Statej].HasRed) continue;
    PostDiscrim.clear();
    PostDiscrim.push_back(pair<unsigned,unsigned>(Statej,0)); // Start with just this state.
    PreDiscrim.clear();
    GramNdx g = States[Statej].RedPos; // Position in Grammar of LHS of production corresponding to the reduction.
// Take the opportunity to note action (aka exit).
    States[Statej].Action = 0;
    string s = ProdTerms[Gram[g]].Symbol;
    unsigned int f = s.find("."); 
    if(f!=string::npos){
      for(f=f+1;f<s.length();f++) States[Statej].Action = 10*States[Statej].Action + (s[f]-'0'); 
    }
    GramNdx h = g+1; // Left of RHS
    while(Gram[h+1]>=0) h++;// Find RHS limit
    for(;;h--){ // Leftwards loop.
      unsigned int d = Gram[h];  // The discriminant from the grammar.
      // Loop through PostDiscrim.
      for(unsigned int k=0;k<PostDiscrim.size();k++){
        // Put something in PreDiscrim if d matches a discriminant of one of the states' Froms.
        for(unsigned int f = 0;f<States[PostDiscrim[k].first].Froms.size();f++){
          if(States[PostDiscrim[k].first].Froms[f].Discrim == d){
            // Check if that was a duplicate.  (Can that happen? It never seeems to.)
            int t = States[PostDiscrim[k].first].Froms[f].Target;
            for(unsigned p=0;p<PreDiscrim.size();p++) if(PreDiscrim[p].first==t) throw 9;
            PreDiscrim.push_back(pair<unsigned,unsigned>(States[PostDiscrim[k].first].Froms[f].Target,0)); 
          }
        } // f
      } // k 
      if(h-1==g) break; // No more RHS
      // Prepare for next cycle.
      PostDiscrim = PreDiscrim;
      PreDiscrim.clear();
    } // h
     // PreDiscrim now has the collection of states prior to embarking on Reduce.  Each will have a transit element for the Reduce production.
    for(unsigned int k=0;k<PreDiscrim.size();k++){
      unsigned int Statek = PreDiscrim[k].first;
      for(unsigned int t=0;t<States[Statek].Transits.size();t++){
        // RedPos is a position in Gram so what the reduction is to is the LHS there.
        if(States[Statek].Transits[t].Discrim == Gram[States[Statej].RedPos]){ // Note that for Statek on stack the reduction transits to ...
          ThisTransit.Discrim = Statek;
          ThisTransit.Target = States[Statek].Transits[t].Target;
          States[Statej].RedSwitch.push_back(ThisTransit);
          break; // Discrim unique within a Transits.
        }  
      } // t
    } // k
  } // Statej

/* At this stage we have the data for the parser - a switch for which state to transit to according to the latest token found in the subject program, and another switch for which state to transit to according
to what state is top-of-stack when something is recognised.  However, there is tidying and improvement that can be done.
The transitions on tokens have been recorded in State[].Transits along with other transitions the parser does not need. (That info was used in producing States[].RedSwitch.)  So States[].Transit can be compacted to be only
transitions on tokens (aka terminals).
*/
  for(unsigned int Statej=0;Statej<States.size();Statej++){
    Index To=0;
    for(Index From = 0;From<States[Statej].Transits.size();From++){
      if(States[Statej].Transits[From].Discrim >= ProdCount)
        States[Statej].Transits[To++] = States[Statej].Transits[From];// Copy towards low end of vector.
    } // From, transits
    States[Statej].Transits.erase(States[Statej].Transits.begin()+To, States[Statej].Transits.end()); // Erase unwanted at high end of vector.
    if(strchr(Switches,'V')) ShowState(Statej);
    if(Statej==ReductionsFlaw) throw 8;  // Delayed until state shown.
  } // States

// The allowed keywords for any state can be accessed by a single number - the offset into a list of keywords acceptable in that state. 
  Keywords();
  WriteKeywords();

/* The parser will need to record on the stack the state number of each state that is tested in some Redswitch.  There is an exception when all the targets in the RedSwitch are the same. Then that particular switch is not a 
cause for stacking states.  States that are to be stacked are called "reference" states.  Here we note the reference states.  This provides a failsafe test of whether two grammar states match (although it has
to be done again for the final parser states).
The RedSwitch can be tidied because if all the targets are the same the discrims are unneeded.  (BTW it is not the same for Transits because tokens encountered may not match any of the discrims in a Transits switch.  For RedSwitch we know all
that can be on the stack.)
*/
  for(unsigned Statej=0;Statej<States.size();Statej++){
    if(States[Statej].HasRed && States[Statej].RedSwitch.size()!=0){  // Beware Starter=X3J18^
      unsigned r, T = States[Statej].RedSwitch[0].Target;
      for(r=1;r<States[Statej].RedSwitch.size();r++){
        if(States[Statej].RedSwitch[r].Target!=T) break;
      }  // r
      if(r==States[Statej].RedSwitch.size()){ // All targets the same.
        States[Statej].RedSwitch[0].Discrim = 0;
        States[Statej].RedSwitch.erase(States[Statej].RedSwitch.begin()+1, States[Statej].RedSwitch.end());
      }
      else{// Here the targets are not all the same.  So the Discrims will be Reference.
        for(unsigned i = 0;i<States[Statej].RedSwitch.size();i++){     
          States[States[Statej].RedSwitch[i].Discrim].Reference = 1;
        } // i
      }
    } 
  } // Statej
/* Now we know which states are Reference, we can work out how many stacked states are to be removed when a reduction happens.
 The code is similar to the code that made the RedSwitch in the first place.
 Note that setting Reference and Prune at this stage is fail-safe.  If done again after matching equal states it might get a tighter result.
*/
  for(unsigned int Statej=0;Statej<States.size();Statej++){
    if(!States[Statej].HasRed) continue;
    PostDiscrim.clear();
    PostDiscrim.push_back(pair<unsigned,unsigned>(Statej,0)); // Start with just this state. It is the state at which we are reducing.
    PreDiscrim.clear();
    GramNdx g = States[Statej].RedPos; // Position in Grammar of LHS of production corresponding to the reduction.
    GramNdx h = g+1; // Left of RHS
    while(Gram[h+1]>=0) h++;// Find RHS limit
    for(;;h--){ // Leftwards loop.
      unsigned int d = Gram[h];  // The discriminant from the grammar.
      // Loop through PostDiscrim.
      for(unsigned int k=0;k<PostDiscrim.size();k++){
        // Put something in PreDiscrim if d matches a discriminant of one of the states' Froms.
        for(unsigned int f = 0;f<States[PostDiscrim[k].first].Froms.size();f++){
          if(States[PostDiscrim[k].first].Froms[f].Discrim == d){
            unsigned t = States[PostDiscrim[k].first].Froms[f].Target;
/*  In this step back we are negating the push to the stack that was made on entry to the state if the state was a reference.  t is the state we are going back to, PostDiscrim[k].first is state being negated.
*/
            unsigned p = States[PostDiscrim[k].first].Reference + PostDiscrim[k].second;
            PreDiscrim.push_back(pair<unsigned,unsigned>(t,p)); 
          }
        } // f
      } // k 
      if(h-1==g) break; // No more RHS
      // Prepare for next cycle.
      PostDiscrim = PreDiscrim;
      PreDiscrim.clear();
    } // h
    // PreDiscrim now has the collection of states prior to embarking on Reduce.  The second field is the prune to get back there.
/* The prunes better be all the same because we want to put the prune amount with the state that is doing the reducing. 
*/
    unsigned p = PreDiscrim[0].second;
    for(unsigned int k=1;k<PreDiscrim.size();k++) if(PreDiscrim[k].second != p)
      throw 9;
    States[Statej].Prune = p;
  } // Statej


/* When looked at from the parser's point of view, some grammar states may be duplicates.  After renumbering to give equivalent grammar states the same parser state number, we get a compact numbering for the parser states.
There are complex interactions in deciding which states are duplicates and it is probably too ambitious to expect a perfect job.  What has to be done is to fail-safe, i.e. genuine duplicates might get tagged as unequal, but unequals
will not get tagged as duplicates.

It is easy to tag some states as different for reasons unconnected with state numbering, ie one is shift and one not, or their Transit Discrim(s) differ.  To decide about the other pairs of states recursion is necessary because of
"These states are equal if those states are equal" situations.  The recursion is in SameTargets.

The awkward case to handle is where the two states both appear in the discrims of one RedSwitch. If the two associated targets are the same by reason of being the same grammar state then no problem - the two discrim states
could be equal.  But we cannot have the target states unequal and the discrims made the same because then there would be no way to test which target to use.  Although I cannot see it explicitly in the 1990's code, it looks like that
code handles the awkward case by never allowing two reference states to match.  (When this code uses that rule it gets 289 parser states, near enough the 295 from the old code.)  
  
To record which states differ from one another we need a matrix of grammarstates x grammarstates size.  (Actually a triangular matrix will suffice since the relation is reflexive).  We also need a bit per state pair to record whether 
the algorithm has decided whether there is a difference or not.  In 2011 these arrays would not be regarded as large even at a byte per element.  However, some sense of efficiency leads me to try using the STL bool vector class. 

Most pairs of states will not be the awkward case.  Which ones are can be recorded as Decided = false with "Equal States" = true, a combination which has no other use.
*/
  StatesCount = States.size(); 
  for(unsigned k=0;k<StatesCount;k++){
    vector<bool>* t;
    t = new vector<bool>(StatesCount, false);
    BitMatrix.push_back(t);
    BitMatrix[k]->at(k) = true; // Fill the diagonal with true, meaning state is duplicate of itself and that has been decided.
    States[k].ParseStateNum = StatesCount;  // Tags all states as not yet renumberd.
  }

// Most pairs of states will be states that differ.  A relatively simple test will decide for many pairs.
  for(unsigned Statej=0;Statej<StatesCount-1;Statej++){
    for(unsigned Statek=Statej+1;Statek<StatesCount;Statek++){
      bool Decided = false;
      // On this pass we can only decide things are unequal, cannot decide they are equal.
      if(States[Statej].Transits.size() != States[Statek].Transits.size()) Decided = true;
      else if(States[Statej].RedSwitch.size() != States[Statek].RedSwitch.size()) Decided = true;
      else if(States[Statej].HasRed ^ States[Statek].HasRed) Decided = true;
      else if(States[Statej].Reference ^ States[Statek].Reference) Decided = true;
      else if(States[Statej].Action != States[Statek].Action) Decided = true;
      else if(States[Statej].Prune != States[Statek].Prune) Decided = true;
      else if(States[Statej].MsgMN != States[Statek].MsgMN) Decided = true;
      else{// The Transits are the same size, do they have the same Discrims?  (If so same order as they came from a STL map)
        for(unsigned t=0;t<States[Statej].Transits.size();t++)
          if(States[Statej].Transits[t].Discrim!=States[Statek].Transits[t].Discrim){Decided = true; break;}
      } 
      if(Decided) BitMatrix[Statej]->at(Statek) = true; // Record decided. BitMatrix[Statek]->at(Statej) remains false - the states differ.
    } // Statek
  } // Statej

// Set the bits for easier detection of the awkward cases.
  for(unsigned Statej=0;Statej<StatesCount-1;Statej++){
    if(States[Statej].RedSwitch.size()<2) continue;
    // Look at all pairs in the discrims.
    for(unsigned r=0;r<States[Statej].RedSwitch.size()-1;r++){
      unsigned a = States[Statej].RedSwitch[r].Discrim;
      unsigned c = States[Statej].RedSwitch[r].Target;
      for(unsigned q=r+1;q<States[Statej].RedSwitch.size();q++){
        unsigned b = States[Statej].RedSwitch[q].Discrim;
        unsigned aa=a,bb=b;
        if(aa>bb) aa=b, bb=a; 
        if(BitMatrix[aa]->at(bb)) continue;  // Previously found to differ.
        unsigned d = States[Statej].RedSwitch[q].Target;
        if(c==d) continue; // No evidence they differ.
        // a can duplicate b only if c is duplicate of d.
        BitMatrix[b]->at(a) = true;  // So SameTargets knows it is an awkward case.
      } // t
    }  // r
  } // Statej

/* The still undecided pairs have many aspects the same but are not equal unless some states they reference are equal.
Targets are grammar states. Two targets can be equal even when their grammar state numbers are not. 
Hence the need for recursion in deciding.  
*/
  for(unsigned Statej=0;Statej<StatesCount-1;Statej++)
    for(unsigned Statek=Statej+1;Statek<StatesCount;Statek++){
      if(BitMatrix[Statej]->at(Statek)) continue; // Already decided for this pair.
      SameTargets(Statej, Statek);  // SameTargets will set the relevant Matrix bits.
    } // Statek, Statej

/* Now reflect a compact numbering for the unique states into all the data.  
*/
  ParseStateNum = 0;
  for(unsigned Statej=0;Statej<StatesCount;Statej++){
/*  It is convenient to have a field in the ultimately-retained parser states which gives the original state.  This is printed out so that a state encountered when running the actual parser
can be traced back to a grammar state.
*/
    States[Statej].GramStateNum = Statej;
    States[Statej].Reference = 0; // For later.
    if(States[Statej].ParseStateNum != StatesCount) continue;  // State already renumbered.
    bool Headed = false; 
    for(unsigned Statek=Statej;Statek<StatesCount;Statek++){
      if(BitMatrix[Statek]->at(Statej)) {
        States[Statek].ParseStateNum = ParseStateNum;
// No need to display here after debug because matches shown on parser state listing.
#if 0
        if(Statek!=Statej){
          if(!Headed){Out << endl << Statej << " matched "; Headed=true;}
          Out << Statek << ' ';
        }
#endif
      } // Match
    } // Statek
    if(Headed) Out << '[' << ParseStateNum << ']';
    ParseStateNum++;
  } // Statej

/*  We know now which states form each group - they have the same ParStateNum.  Those in a group were determined to match on the basis of subsequent behaviour, not on context.  (i.e Froms and RedPos not matched.)
We want to recompute the Prune numbers to take advantage of states grouping.  That recompute depends on the grammar and the Froms so it is done now using the original state numbering.  This time we are adding up the references 
of the groups encountered. 

Before the recompute we will put the ParseStateNum in some vectors because it is a byproduct of doing that which tells us which are reference states.  (And the altered vectors are not used in the recompute of Prune.)  

It turns out that this second Prune calculation is redundant - nothing improves.  However, I left it in on "If its not broke..." principles.
*/

  ParseStateNum = 0;
  for(unsigned Statej=0;Statej<StatesCount;Statej++){
    if(States[Statej].ParseStateNum != ParseStateNum) continue;
    // One which will be kept. Modify the switches to latest state numbers.
    ParseStateNum++;
    for(unsigned t=0;t<States[Statej].Transits.size();t++){
      States[Statej].Transits[t].Target = States[States[Statej].Transits[t].Target].ParseStateNum;
    } // t 
    for(unsigned t=0;t<States[Statej].RedSwitch.size();t++){
      States[Statej].RedSwitch[t].Discrim = States[States[Statej].RedSwitch[t].Discrim].ParseStateNum;
      States[Statej].RedSwitch[t].Target = States[States[Statej].RedSwitch[t].Target].ParseStateNum;
    } // t

/* The RedSwitch can be tidied because if all the targets are the same the switch is unneeded.  (BTW it is not the same for Transits because tokens encountered may not match any of the discrims in a Transits switch.  For RedSwitch we know all
that can be on the stack.)  This tidying was done for grammar states but the change to parser states could make more targets equal.
*/
    if(States[Statej].HasRed && States[Statej].RedSwitch.size()!=0){  // Beware Starter=X3J18^
      unsigned r, T = States[Statej].RedSwitch[0].Target;
      for(r=1;r<States[Statej].RedSwitch.size();r++){
        if(States[Statej].RedSwitch[r].Target!=T) break;
      }  // r
      if(r==States[Statej].RedSwitch.size()){ // Targets the same.
        States[Statej].RedSwitch.erase(States[Statej].RedSwitch.begin()+1, States[Statej].RedSwitch.end());
      } else { // Targets differ.  We still need to remove duplicates. (Which may have arisen from renumbering.)
        sort(States[Statej].RedSwitch.begin(), States[Statej].RedSwitch.end(), TransitSort);
        unsigned R = 1;
        unsigned s = States[Statej].RedSwitch[0].Discrim;
        States[s].Reference = 1; // Tells us the parser state will need to be stacked at parse time.
        for(r=1;r<States[Statej].RedSwitch.size();r++){
          s = States[Statej].RedSwitch[r].Discrim;
          States[s].Reference = 1; 
          if(s!=States[Statej].RedSwitch[r-1].Discrim || States[Statej].RedSwitch[r].Target!=States[Statej].RedSwitch[r-1].Target){
            States[Statej].RedSwitch[R++] = States[Statej].RedSwitch[r]; // Collect the uniques.
          }
        }  // r
        States[Statej].RedSwitch.erase(States[Statej].RedSwitch.begin()+R,States[Statej].RedSwitch.end());
      }  // Differ
    } // RedSwitch 
  } // Statej

/*  Intuitively, simplifying the RedSwitches may have led to less need for Reference states.  Here we do the working backwards on the grammar again, using grammar states for the computation except where the Reference is picked 
up from the parser state associated with the grammar state.  That means the sets PreDiscrim and PostDiscrim will be the same as they were when the calculation was done before.
*/
  for(unsigned int Statej=0;Statej<StatesCount;Statej++){
    if(!States[Statej].HasRed) continue;
    PostDiscrim.clear();
    PostDiscrim.push_back(pair<unsigned,unsigned>(Statej,0)); // Start with just this state. It is the grammar state at which we are reducing.
    PreDiscrim.clear();
    GramNdx g = States[Statej].RedPos; // Position in Grammar of LHS of production corresponding to the reduction.
    GramNdx h = g+1; // Left of RHS
    while(Gram[h+1]>=0) h++;// Find RHS limit
    for(;;h--){ // Leftwards loop.
      unsigned int d = Gram[h];  // The discriminant from the grammar.
      // Loop through PostDiscrim.
      for(unsigned int k=0;k<PostDiscrim.size();k++){
        // Put something in PreDiscrim if d matches a discriminant of one of the states' Froms.
        for(unsigned int f = 0;f<States[PostDiscrim[k].first].Froms.size();f++){
          if(States[PostDiscrim[k].first].Froms[f].Discrim == d){
            unsigned t = States[PostDiscrim[k].first].Froms[f].Target;
/*  In this step back we are negating the push to the stack that was made if the state was a reference.
*/
 //           unsigned p = States[States[t].ParseStateNum].Reference + PostDiscrim[k].second;
            unsigned p = States[States[PostDiscrim[k].first].ParseStateNum].Reference + PostDiscrim[k].second;
            PreDiscrim.push_back(pair<unsigned,unsigned>(t,p)); 
          }
        } // f
      } // k 
      if(h-1==g) break; // No more RHS
      // Prepare for next cycle.
      PostDiscrim = PreDiscrim;
      PreDiscrim.clear();
    } // h
    // PreDiscrim now has the collection of states prior to embarking on Reduce.  The second field is the prune to get back there.
/* The prunes better be all the same because we want to put the prune amount with the state that is doing the reducing. 
*/
    unsigned p = PreDiscrim[0].second;
    for(unsigned int k=1;k<PreDiscrim.size();k++) if(PreDiscrim[k].second != p)
       throw 9;
    if(States[Statej].Prune!=p){
      Out << endl << Statej << " prune was " << States[Statej].Prune << " is " << p;// Didn't happen with Rexx grammar.
      States[Statej].Prune = p;
    } 
/* If a Reference state is entered and reduction follows, it doesn't make much sense to push the state on the stack and immediately remove it as part of the prune.  Better not to push (and adjust prune).
*/
    States[Statej].Prune -= States[Statej].Reference;
  } // Statej
  Out << endl << "New prune ended";

  // Squeeze out obsolete states. (Retaining Reference which was already computed there.) 
  ParseStateNum = 0;
  for(unsigned Statej=0;Statej<StatesCount;Statej++){
    if(States[Statej].ParseStateNum == ParseStateNum){ // One which will be kept.
      int F = States[ParseStateNum].Reference;
      States[ParseStateNum] = States[Statej]; 
      States[ParseStateNum].Reference = F;
      ParseStateNum++;
    }
  } // Statej

  ShowParserStates();

/*  Some pairs of terminals, e.g. LEAVE ITERATE are syntactically (although not semantically) equivalent.  They are acceptable in the same states and have the same
targets when used in Transits.  Here we develop the groups of terminals; members of a group are syntactically equivalent. 
*/
  for(unsigned k=0;k<TermLimit;k++){ // Construct matrix to record atoms-differ.
    bitset<TermLimit>* t;
    t = new bitset<TermLimit>;
    t->reset();
    TermBitMatrix.push_back(t);
    ProdTerms[ProdCount+k].GroupNum = TermLimit; // Initialise for later.
  }
  for(unsigned Statej=0;Statej<ParseStateNum;Statej++){
    if(!States[Statej].Transits.size()) continue; // Transits are the only use of the terminals (aka atoms).
    // Temp strip with true for what is not amongst the triggers.
    bitset<TermLimit> Outside; Outside.set();
    for(unsigned t=0;t<States[Statej].Transits.size();t++){
      Outside[States[Statej].Transits[t].Discrim-ProdCount] = false;
    } // t 
    // Each inside is different from all the outsides. 
    for(unsigned t=0;t<States[Statej].Transits.size();t++){
      *TermBitMatrix[States[Statej].Transits[t].Discrim-ProdCount] |= Outside;
    } // t 
    // Insides differ from one another unless targets are equal.
    for(unsigned t=0;t<States[Statej].Transits.size()-1;t++){
      for(unsigned u=t+1;u<States[Statej].Transits.size();u++){
        if(States[Statej].Transits[t].Target != States[Statej].Transits[u].Target){
          (*TermBitMatrix[States[Statej].Transits[t].Discrim-ProdCount]) [States[Statej].Transits[u].Discrim-ProdCount] = true;
        }
      } // u 
    } // t 
  } // Statej
// A couple of passes will set GroupNum to reflect groups and number keywords high.  Also make a vector in GroupNum order.
  ThisGroup.AcceptNdx = 0;
  for(unsigned j=0;j<TermCount;j++){
    if(ProdTerms[ProdCount+j].IsKey || ProdTerms[ProdCount+j].MsgMN) continue; 
    if(ProdTerms[ProdCount+j].GroupNum != TermLimit) continue; // Already numbered.
    ProdTerms[ProdCount+j].GroupNum = GroupCount;
    // Look for any that don't differ and number them the same.  (Could a key and a non-key play the same grammar role?  If so number apart anyway.)
    for(unsigned k=j+1;k<TermCount;k++){
      if(ProdTerms[ProdCount+k].IsKey) continue; 
      if(TermBitMatrix[j]->at(k) || TermBitMatrix[k]->at(j)) continue;
      ProdTerms[ProdCount+k].GroupNum = GroupCount;
    } // k
    Groups.push_back(ThisGroup); // initialising.
    GroupCount++;
  } // j
  NonKeyCount = GroupCount;
  for(unsigned j=0;j<TermCount;j++){
    if(!ProdTerms[ProdCount+j].IsKey || ProdTerms[ProdCount+j].MsgMN) continue; 
    if(ProdTerms[ProdCount+j].GroupNum != TermLimit) continue; // Already numbered.
    ProdTerms[ProdCount+j].GroupNum = GroupCount;
    // Look for any that don't differ and number them the same.  (Could a key and a non-key play the same grammar role?  If so number apart anyway.)
    for(unsigned k=j+1;k<TermCount;k++){
      if(!ProdTerms[ProdCount+k].IsKey) continue; 
      if(TermBitMatrix[j]->at(k) || TermBitMatrix[k]->at(j)) continue;
      ProdTerms[ProdCount+k].GroupNum = GroupCount;
    } // k
    Groups.push_back(ThisGroup); // initialising.
    GroupCount++;
  } // j
  WriteGroupMembers();
/* The lexical level of the parser will be aware of all the possible terminals, e.g. $else $ne $eos etc, but those numbers will be replaced by the numbers of the groups by the time shifts are tested.   
*/
// Use the new numbering in shifts henceforth.  Remove any duplicate elements in the switches which that might make.
  for(unsigned Statej=0;Statej<ParseStateNum;Statej++){
    if(!States[Statej].Transits.size()) continue;
    for(unsigned t=0;t<States[Statej].Transits.size();t++){
      States[Statej].Transits[t].Discrim = ProdTerms[States[Statej].Transits[t].Discrim].GroupNum;
    } // t 
    // Discrims changed now. Elide duplicates.
    if(States[Statej].Transits.size()==1) continue;
    sort(States[Statej].Transits.begin(), States[Statej].Transits.end(), TransitSort);
    unsigned T = 1; // Place to write nonduplicate.
    for(unsigned t=1;t<States[Statej].Transits.size();t++){
      if(States[Statej].Transits[t].Discrim != States[Statej].Transits[t-1].Discrim) States[Statej].Transits[T++] = States[Statej].Transits[t];
    } // t 
    States[Statej].Transits.erase(States[Statej].Transits.begin()+T,States[Statej].Transits.end());
  } // Statej
} // NoteStack

bool SameTargets(unsigned Sjj, unsigned Skk){// is reflexive)
  unsigned Sj = Sjj, Sk = Skk;
  if(Sjj>Skk){Sj = Skk; Sk = Sjj;} 
  if(Sj==80 && Sk==81)
    Sj=Sj;
  if(BitMatrix[Sj]->at(Sk)) return BitMatrix[Sk]->at(Sj);  // One triangle of matrix says whether "decided", other triangle says what decided.

  bool Awkward = BitMatrix[Sk]->at(Sj);
  // On the way down the recursions we (hopefully) decide targets match - if that proves wrong the matrix is corrected on the way up from the recursions. This is to deal with cycles.
  BitMatrix[Sj]->at(Sk) = true;
  BitMatrix[Sk]->at(Sj) = true;

// Check Targets of Transits match.
  for(unsigned t=0;t<States[Sj].Transits.size();t++){
    if(!SameTargets(States[Sj].Transits[t].Target, States[Sk].Transits[t].Target)){
      BitMatrix[Sk]->at(Sj) = false;
      return false;
    }
  } // t 
// Check RedSwitch contents match.
  if(States[Sj].RedSwitch.size()) for(unsigned t=0;t<States[Sj].RedSwitch.size();t++){
    if(!SameTargets(States[Sj].RedSwitch[t].Discrim, States[Sk].RedSwitch[t].Discrim)){
      BitMatrix[Sk]->at(Sj) = false;
      return false;
    }
	  if(!SameTargets(States[Sj].RedSwitch[t].Target, States[Sk].RedSwitch[t].Target)){
      BitMatrix[Sk]->at(Sj) = false;
      return false;
    }
  } // t

// If Sj and Sk are to be used as reference states in a single RedSwitch, then they have to be distinguishable.
// Only some pairs are marked as awkward.
  if(!Awkward) return true; // Previously marked non-awkward.
// Look at all the RedSwitches, in case.
  for(unsigned St=0;St<States.size();St++){
    if(States[St].RedSwitch.size()<2) continue;
    // Look at all pairs in the discrims.
    for(unsigned r=0;r<States[St].RedSwitch.size()-1;r++){
      unsigned a = States[St].RedSwitch[r].Discrim;
      if(a!=Sj && a!=Sk) continue; // Speedup. 
      unsigned c = States[St].RedSwitch[r].Target;
      for(unsigned q=r+1;q<States[St].RedSwitch.size();q++){
        unsigned b = States[St].RedSwitch[q].Discrim;
        unsigned aa=a, bb=b;
        if(aa>bb) aa=b,bb=a;
        if(aa!=Sj || bb!=Sk) continue;
        unsigned d = States[St].RedSwitch[q].Target;
        // aa can duplicate bb only if c is duplicate of d.
        if(!SameTargets(c,d)){
          BitMatrix[Sk]->at(Sj) = false;
          return false;
        }
      } // t
    }  // r
  } // St

  return true;
} // Same targets.

#define MajMin(m,n) (256*m+n)
bool BetterMsg(unsigned short A, unsigned short B, unsigned int S){
// This is translated from an earlier version - I hope it matches the Standard. 
 if(A==B) return false; 
 /* Msg21.1 always loses. */
 if(A==MajMin(21,1)) return false;
 if(B==MajMin(21,1)) return true;
 /* Msg35.1 loses apart from that. */
 /* Except not to 27.1 */
 if(A==MajMin(35,1) && B==MajMin(27,1)) return true;
 /* Also not to 36.0 */
 if(A==MajMin(35,1) && B==MajMin(36,0)) return true;
 if(A==MajMin(36,0) && B==MajMin(35,1)) return false;
 /* Also not to 38.3 */
 if(A==MajMin(35,1) && B==MajMin(38,3)) return true;
 if(A==MajMin(38,3) && B==MajMin(35,1)) return false;
 if(A==MajMin(35,1)) return false;
 if(B==MajMin(35,1)) return true;
 /* 25.16 preferred to 27.1 */
 if(A==MajMin(25,16) && B==MajMin(27,1)) return true;
 if(A==MajMin(27,1) && B==MajMin(25,16)) return false;
 
 Out << S << ' ' << A/256 << '.' << A%256 << ' ' << B/256 << '.' << B%256 << endl;
 throw 9;
} // BetterMsg

  vector<int> Merged; // of keywords, labels.

void Keywords(){
/* 2011 Can't claim to understand what 1990's code does about keywords that cause reduction but will do something and see if it works.  (Keywords reserved in subclauses are a bit complicated.  Thus IF (A THEN) THEN ... is ok syntax but
IF A THEN THEN ... is not.)

For normal shifts and the lists of keywords that go in messages,  it is good to make a list of keywords for each state.  The tokeniser looking up a symbol in the users program serves both to convert to a keyword number and check 
that the keyword is acceptable in that state. 

Where the list of keywords is a subset of some other list, it is not necessary to have space for both lists in the parser tables.  (See historical Keys.inc)

*/
// To merge lists, first sort them longest first.
  for(unsigned int Statej=0;Statej<States.size();Statej++){
    States[Statej].ShiftKeys.reset();
    ThisKLR.OfState = Statej;
    ThisKLR.ListLen = 0;
    for(unsigned int t=0;t<States[Statej].Transits.size();t++){
      if(ProdTerms[States[Statej].Transits[t].Discrim].IsKey){
        ThisKLR.ListLen++;
        States[Statej].ShiftKeys[States[Statej].Transits[t].Discrim-ProdCount] = true; // Note keywords as bitset.      
      } 
    } // t
    if(ThisKLR.ListLen) Lists.push_back(ThisKLR);
  } // States
  sort(Lists.begin(), Lists.end(), LongFirst);
/* Now consider lists in longest first order and see if latest list is contained in one made earlier.  Needed lists are concatenated in vector KeyLists.  The vector includes labelling of the lists.
For each list (kk) in Lists we progress over all of Merged noting the keywords referenced in ThisList.  ThisList is reset at the beginning of each list in Merged so that at the end of each list (marked by Separator) ThisList
represents the potential to use that list for the kk list.  The potential is only realised if ThisList contains the wanted keys and those keys can be re-ordered to be consecutive. 
*/
  bitset<TermLimit> ThisList; // Collected between the markers that separate lists on Merge.
  for(unsigned int kk=0;kk<Lists.size();kk++){
    ThisList.reset();
    int LabelAt = 0; // Where in Merged a label (aka entry point) might be needed.
    for(unsigned int m=0;m<Merged.size();m++){ 
      int k = Merged[m]; 
      if(k>=0) ThisList[k] = true;
      if(Merged[m]==Separator){// End of list within Merged
        // ThisList could be exactly the list the state specified by kk needs.
        bitset<TermLimit> WorkList = States[Lists[kk].OfState].ShiftKeys;
        if(ThisList == WorkList)  goto PlaceLabel; // No need to add to lists in merge, but existing list needs an extra label to show entry point for this state.
         // Match as a subset will suffice, if the subset can be isolated as the tail of a run.
        if((ThisList | WorkList) == ThisList){
          // Scan back to see if tail matches.
          int mm;
          for(mm=m-1;;mm--){
            if(Merged[mm]<0) break; // Cannot swop positions over label or separator.
            if(WorkList[Merged[mm]]==false) break; // Not one we want in the tail.
AfterSwop:
            WorkList[Merged[mm]]=false; // No longer concerned for this keyword - just seen it in tail.
            if(!WorkList.any()){ // Tail is good for all the keywords needed at this state.  Label it for this state.
              LabelAt = mm;
              goto PlaceLabel;
            }      
          } // mm
          // No fallthru.
          // If the mm loop broke on a label give up - we cannot reorder past a label.
          if(Merged[mm]>=0){// If the mm loop broke by encountering a keyword unwanted in tail, try to exchange it with something we want.
            int mmm = mm-1;
            while(Merged[mmm]>=0 && !WorkList[Merged[mmm]]) mmm--;
            if(Merged[mmm]>=0){ // Exchange will provide one more for the tail.
              int Swop=Merged[mmm];Merged[mmm]=Merged[mm];Merged[mm]=Swop;
              goto AfterSwop;
            } 
          } 
        } // Subset
        // ThisList unsuitable. Fallthru to try next list of Merged.
        ThisList.reset();
        LabelAt = m+1; // Potential for next list in Merged.
      } // Separator reached.
    } // m
    // None of lists previously Merged can be used.  So just add this one at the end.
    LabelAt = Merged.size();
    for(unsigned int t=0;t<TermCount;t++)
      if(States[Lists[kk].OfState].ShiftKeys[t]) Merged.push_back(t);
    Merged.push_back(Separator);
PlaceLabel:
    Merged.insert(Merged.begin()+LabelAt, Separator-Lists[kk].OfState-1); // Extra -1 to ensure distinction.
  } // kk, lists record. Loop to solve for next state.

// The Merged keyword list is optimised to put sublists used by messages close together and to put a particular sublist first.
// Looking for equal states will not alter the keywords lists so assembler code for the keyword lists might as well be made here.
} // Keywords

void ShowParserStates(){
// Print the Parser states.
  if(strchr(Switches,'V'))
  for(unsigned Statej=0;Statej<ParseStateNum;Statej++){
    ThisState = States[Statej];
/* We want to show all the grammar states that equated to this parser state.  We can do this by keeping the smallest of them and using the BitMatrix to find the others.
*/

    Out << endl << Statej << '[';
    unsigned Stateg = ThisState.GramStateNum;
    for(unsigned Statek=Stateg;Statek<StatesCount;Statek++){
      if(BitMatrix[Statek]->at(Stateg)) {
        Out << Statek << ' ';
      }
    } // Statek
    Out << "] ";
    if(ThisState.Reference)  Out << 'F';
    if(ThisState.Transits.size())  Out << 'S';
    if(ThisState.MsgMN)  Out << 'E' << ThisState.MsgMN/256 << '.' << ThisState.MsgMN%256;
    if(ThisState.KeysOffset)  Out << 'K' << ThisState.KeysOffset;
    if(ThisState.RedSwitch.size())  Out << 'R';
    if(ThisState.RedSwitch.size()==1)  Out << ThisState.RedSwitch[0].Target;
    if(ThisState.Prune)  Out << 'P' << ThisState.Prune;
    if(ThisState.Action)  Out << 'X' << ThisState.Action;

    if(ThisState.RedSwitch.size()>1){
      for(unsigned int t=0;t<ThisState.RedSwitch.size();t++){
        Out << ' ' << ThisState.RedSwitch[t].Discrim << ':' << ThisState.RedSwitch[t].Target; 
      } //t
    }
    for(unsigned int t=0;t<ThisState.Transits.size();t++){
      Out << ' ' << ProdTerms[ThisState.Transits[t].Discrim].Symbol << "=>" << ThisState.Transits[t].Target; 
    } // t
  } // Statej
} // ShowParserStates

void WriteKeywords(){
/* Here the assembler code to be included in the CRX interpreter is generated.  Each element of Merged is represented by three fields - the symbolic form of the keyword as known to the parser, the length of the symbol, and the symbol.
The length is in 4 bits and other bits of the byte may be a tag.  The end of the full list is marked by zero in the first field.
*/   
  Out << endl << "; Tag 16 for eol, 32 IF type, 64 DO type, 96 odd type, 128 THEN type, 160 ADDRESS, 192 TRACE type, 224 CALL type";
  Out << endl << "Keys: ;"; 
  int KeysOffset = 1;
  for(unsigned int m=0;m<Merged.size()-1;m++){ 
    int k = Merged[m];
    if(k!=Separator){
      if(k<0) { // Labels put out are commentary - the value of the label  is in another part of the parser tables, along with the state info.
        int Statej = -k+Separator-1;
        Out << endl << "; Keys for state " << Statej << " at offset " << KeysOffset;
        States[Statej].KeysOffset = KeysOffset; 
      } // Label
      else { // Keyword
        int Tag = 0;
        if(Merged[m+1]==Separator) Tag = 16;
        string s = ProdTerms[ProdCount+k].Symbol;
        s = s.substr(1,s.length()-2); // Drop quotes. 
        if(s=="IF" || s=="WHEN") Tag+=32;
        else if(s=="DO") Tag+=64;
        else if(s=="WITH" || s=="END" || s=="ITERATE" || s== "LEAVE") Tag+=96;
        else if(s=="OTHERWISE" || s=="THEN" || s=="ELSE") Tag+=128;  
        else if(s=="ADDRESS") Tag+=160;
        else if(s=="FORM" || s=="TRACE" || s=="SIGNAL") Tag += 192;
        else if(s=="CALL" || s=="NAME") Tag+=224;
        Out << endl << " db $" << s << "-KeysBase," << s.length() + Tag << ",\"" << s << "\"";
        if(Tag&16) Out << endl;
        KeysOffset += 2+s.length();
      } // keyword
    } // Not separator
  } // m 
  Out << endl << "; Keys offset " << KeysOffset;
  Out << endl << " db 0; Indicates end of keywords. Why would that be needed?";
} // WriteKeywords

// Operator as used by ANSI grammar is followed by name as used in Assembler. 
string Names[]={"","Eos","%","Percent","*","Mul","/","Div","//","Rem","(","Lparen",")","Rparen","-","Minus","+","Plus","\\","Not" /* Escaped */,"||","Cat"," ","Abut","$","Assign","|","Or","&&","Xor","&","And",
   "**","Power",",","Comma",".","Dot",";","Semi","<" ,"Lt","<<" ,"Slt","<<=" ,"Sle","<=" ,"Le","==" ,"Seq",">" ,"Gt",">=" ,"Ge",">>" ,"Sgt",">>=" ,"Sge","\\=" ,"Ne" /* Escaped */,"\\==" ,"Sne" /* Escaped */,"=" ,"Eq" };

void WriteGroupMembers(){
/*  This is not writing Assembler for incorporation directly in the CRX interpreter.  It is writing a record of numbers against names which is subsequently used by a tool (synequ.rex) to create the Assembler equs. 
*/
  Out << endl;
  for(unsigned k=0;k<GroupCount;k++){ // New numbering.
    for(unsigned j=0;j<TermCount;j++){ // Old numbering.
      if(ProdTerms[ProdCount+j].GroupNum == k){
        // We need a name for the terminal which Assembler will accept.  (Actually with '$' prefix when CRX uses it.)
        string s;
        s = ProdTerms[ProdCount+j].Symbol;
        // It might have been named in the grammar.
        if(s[0]!='\'') Out << endl << "GroupMember " << k << ',' << s;  
        else if(s[1]>='A' && s[1]<='Z')  // If a keyword use that as name.
          Out << endl << "GroupMember " << k << ' ' << s.substr(1,s.length()-2); 
          else{ // Pick up name from array Names.
            unsigned n;
            for(n=0;n<sizeof(Names)/sizeof(Names[0]);n+=2){
              if(s.substr(1,s.length()-2) == Names[n]) break;
            } // n
            if(n<sizeof(Names)/sizeof(Names[0]))  Out << endl << "GroupMember " << k << ' ' << Names[n+1];   
            //  There are also <> >< /<< />> which must be converted somewhere.        
          }
      }
    } // j  
  } // k 
} // WriteGroupMembers