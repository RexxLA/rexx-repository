/* Here we are concerned with the physical layout of the parser tables.  The results take the form of declarations (in Assembler) which the CRX interpreter will incorporate.

Packing for parser tables only has limited coverage in the literature about how to deal with grammars.  So there is plenty of room for creativity here.

The unit for packing is two bytes.  The states are addressed by the parser in CRX on two byte boundaries. Each state can have one to many two byte components, which appear in succession.
If the state has both shift and reduce possibilities it will have at least two components.  It may also have a component for action to be taken and may have extra test(s) to decide what state to reduce to.
A state which is a shift without reduction possibility will have an error component to describe the error if the current token from the user program is unacceptable.
A state which has shift may have a keys component to describe the keywords acceptable in that state.
A state which has reduction may have a component for action.  (i.e. a call exit into unique CRX code)  

At parsing time the test for a shift goes (a) test acceptability (b) if not acceptable then reduce or error according to what the state allows (c) shift to new state. (New state may be specified in the token tables or
in the current state.)
At parsing time the testing for a reduction goes (a) call action if there is one (b) prune the stack as specified (c) decide new state to reduce to.

Some states are simple enough to be contained in one two-byte component.  The challenge for compactness lies in the switches.  In principle a switch need not take more space than the space for one constant, if the 
switch obeys an arithmetic rule like Target = Discrim + Constant.  Since we have freedom in allocating the number given to each token, and the number given to each state there is potential to create these
arithmetic relationships.  However it is not always possible.  For instance if all the discriminators in a switch were different and two targets were not different then adding a constant could not work.   

It is in the nature of the shift switches that the targets are all different.  In the reduce switches several of the targets tend to be the same. So a preliminary step in testing a reduction might test for a particular 
Discrim, thus effectively removing it from the switch (which might then become amenable to an arithmetic approach).

Although there is freedom to number the tokens, the same numbering will apply to all the switches.  Suppose we have two switches, with Target = Discrim + ConstantA applying to one and 
Target = Discrim + ConstantB applying to the other.  Suppose there are two elements in the first switch  DiscrimX => TargetX and DiscrimY => TargetY.  We know DiscrimX-DiscrimY = TargetX-TargetY.
Whatever this gap value is, it will be the same for the other switch if the same Discrims or Targets are involved in that one.  So the constraints implied by the gaps gather scope.

If all the constraints are met it will be possible to do the numbering so that the addition-based switches work.  It would work if the switches were laid out so that none overlapped (i.e. the targets were numbered in
different ranges) but there is potential for a much better packing because the numbering can be interleaved.

After the switches are laid out there will still be spaces in the state numbering.  The states that were not involved in the switches can be numbered to fill these spaces.  Since the final stage is allocating numbers 
to states that comprise a single two-byte field it should be possible to fill almost all the spaces. 

; Shapes for interpreting syntax tables. Ensure match with table generator.
TokVal record  GrpNdx:6,SubNum:2; Shape of $name
TokRec record X02:1, NdxbT:5, Aim:10
KeyRec record KeyFlags:3,EndList:1, KeyLen:4
ShiftRec record HasShift:1, ErrorAlone:1, CatFlag:1, HasKeys:1, Reference:1,
                Direct:1,Indexb:5, Index:5
ErrorRec record HasShiftOn:1, ErrorAloneOn:1, MajorField:8, MinorField:6
RedRec record HasShiftOff:1, HasAction:1, PruneCt:2, Rtype:2, Rstate:10
*/
bitset<TermLimit> StateAcceptsGroups;  // Tokens acceptable in particular state.
vector<bitset<TermLimit>> StateAcceptsGroupsV; // Holds uniques.
bitset<ParseLimit> GroupAcceptsStates;  // States accepting particular token
vector<bitset<ParseLimit>> GroupAcceptsStatesV;
unsigned RowsCount, ColsCount;
void WriteAccept();
unsigned IsSubset(unsigned);  // Routine to see if one reduction switch is a subset of another.
typedef vector<unsigned> DiscrimsType;  
DiscrimsType ThisDiscrims;
vector<pair<unsigned, DiscrimsType>> Targets; // Element is a target and Discrims (vector) that lead to it.
bool TargetsSort(pair<unsigned, DiscrimsType> a, pair<unsigned, DiscrimsType> b) {
   return a.second.size() > b.second.size();
}
typedef vector<pair<unsigned, unsigned>> GapsType;
GapsType TheseGaps;
vector<GapsType> Gaps; 

void Pack(){
  if(strchr(Switches,'V')){ // V for Verbose
    // Print some statistics.  Just for an idea of the problem being solved.
    Out << "\nStates " << ParseStateNum;
    int FCount =0, ECount=0, XCount = 0, WCount = 0;
    for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
      if(States[Sj].Reference) FCount++;
      if(States[Sj].MsgMN) ECount++;
      if(States[Sj].Action) XCount++;
      WCount+=States[Sj].Transits.size();
      WCount+=States[Sj].RedSwitch.size();
    } // Sj
    Out << "\nReference " << FCount;
    Out << "\nError elements " << ECount;
    Out << "\nAction elements " << XCount;
    Out << "\nSwitch elements " << WCount;
    Out << "\nToken Groups " << GroupCount;
    Out << "\nNonKeys " << NonKeyCount;
  } // V


/* The lexical level of the parser will be aware of all the possible terminals, e.g. $else $ne $eos etc, but those numbers will be replaced by the numbers of the groups by the time shifts are tested.  (Groups aka Tokens)
Acceptability of tokens is tested in two ways, by using a list that contains only acceptable keywords for the state and by a bit matrix state-v-token.  Thus the acceptability is a boolean matrix, states times nonkeyword tokens.
 
Here we squeeze the array so that no two rows are the same and no two columns are the same. Provided one of the directions has less than 33 elements the Assembler code can use a sequence of dwords for the matrix.
*/
  for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
    StateAcceptsGroups.reset(); 
    for(unsigned t=0;t!=States[Sj].Transits.size();t++){
      // The Boolean is only about acceptance of non-key tokens.  Discrim already has those tokens as group numbers.
      if(States[Sj].Transits[t].Discrim < NonKeyCount) StateAcceptsGroups.at(States[Sj].Transits[t].Discrim)=true; // NonKeyCount divides group range.
    } // t 
    unsigned r;
    for(r=0;r<StateAcceptsGroupsV.size();r++) if(StateAcceptsGroupsV[r]==StateAcceptsGroups) break; // Look for latest in the previous.
    if(r==StateAcceptsGroupsV.size()) StateAcceptsGroupsV.push_back(StateAcceptsGroups); // Latest is new unique.
    States[Sj].StateAcceptsGroups = r;
  } // Sj
  ColsCount = StateAcceptsGroupsV.size();
  if(ColsCount>32) throw 7;   // Easy interpreter code change for more.
 
// Similarly, keep unique in the other axis. 
  if(ParseStateNum>ParseLimit) throw 7;
  for(unsigned Gj=0;Gj<NonKeyCount;Gj++){
    GroupAcceptsStates.reset(); 
    for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
      if(StateAcceptsGroupsV[States[Sj].StateAcceptsGroups].at(Gj)) GroupAcceptsStates.at(Sj)=true;
    } // Sj 
    unsigned c;
    for(c=0;c<GroupAcceptsStatesV.size();c++) if(GroupAcceptsStatesV[c]==GroupAcceptsStates) break;
    if(c==GroupAcceptsStatesV.size()) GroupAcceptsStatesV.push_back(GroupAcceptsStates);
    Groups[Gj].AcceptNdx = c;
  } // Gj
  RowsCount = GroupAcceptsStatesV.size();

  if(strchr(Switches,'V')){ // V for Verbose
    Out << "\nRowsCount " << RowsCount;
    Out << "\nColsCount " << ColsCount;
  } // V
  WriteAccept();

/* From here on, where we have switches (Transits and RedSwitch) we are encoding on the basis that the value we are looking up in a switch is bound to be there.  That implies that a switch which is a subset of another switch need not take
extra space. Also in squeezing a matrix, a slot "not possible" matches any value.  
*/
/* There may be some groups that always have the same target, irrespective of the state.  We can encode the target with the group. 
*/
  for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
    if(!States[Sj].Transits.size()) continue;
    for(unsigned t=0;t<States[Sj].Transits.size();t++){
      unsigned d = States[Sj].Transits[t].Discrim;
      if(Groups[d].UseArray) continue;  // Already known not suitable.
      if(Groups[d].Tentative==0) Groups[d].Tentative = States[Sj].Transits[t].Target; // First time a target.
      if(Groups[d].Tentative!=States[Sj].Transits[t].Target) Groups[d].UseArray = true; // Not this Discrim always same target.
    } // t
  } // Sj
  for(unsigned g=0;g<Groups.size();g++){
    if(!Groups[g].UseArray) Out << "\n " << g << " direct to state " << Groups[g].Tentative; 
  } // g 
// Try a matrix states * groups with elements target state.
  vector<unsigned> V0(GroupCount,0);// Targets indexed by group number.
  vector<unsigned> V, Vv;
  vector<vector<unsigned>> Vs; // Unique values of V.
  for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
    if(!States[Sj].Transits.size()) continue;
    V=V0;
    for(unsigned t=0;t<States[Sj].Transits.size();t++){
      unsigned d = States[Sj].Transits[t].Discrim;
      if(Groups[d].UseArray)
        V[d] = States[Sj].Transits[t].Target;
    } // t
    // Has there been a V like this?
    unsigned v;
    for(v=0;v<Vs.size();v++){
      Vv = Vs[v];  // Modifiable copy for compatibility test.
      unsigned g; 
      for(g=0;g<GroupCount;g++){
        if(V[g]==0) continue; // Nothing to fit in.
        if(Vv[g]==0) Vv[g]=V[g]; // element previously unused.
        if(V[g]!=Vv[g]) break;
      } // g 
      if(g==GroupCount){ // Vs[v], altered to Vv, can be used as a match.
        Vs[v] = Vv; 
        break; 
      }
      // Differ, try next Vs[]
    } // v
    if(v==Vs.size()) Vs.push_back(V);
    States[Sj].ShiftNdx = v; // The index on the States axis.
//    Out << "\n[" << Sj << "] " << v;
  } // Sj
  unsigned PhysicalTotal = 0;// Will give a minimum for table space needed.
// Now the other axis, i.e. indexing by group number.
  vector<unsigned> W(Vs.size(),0), Ww; // Targets indexed by states (after squeeze). 
  vector<vector<unsigned>> Ws; // Unique values of W.
  for(unsigned g=0;g<GroupCount;g++){
    for(unsigned v=0;v<Vs.size();v++){
      W[v]=Vs[v][g];
    } // v
    // Has there been a W like this? 
    unsigned w;
    for(w=0;w<Ws.size();w++){
      Ww = Ws[w];
      unsigned v;
      for(v=0;v<Vs.size();v++){
        if(W[v]==0) continue; 
        if(Ww[v]==0) Ww[v]=W[v];
        if(W[v]!=Ww[v]) break;
      } // v
      if(v==Vs.size()){
        Ws[w] = Ww;
        break; 
      }
    } // w    
    if(w==Ws.size()){
      Ws.push_back(W);
      for(unsigned p=0;p<W.size();p++) PhysicalTotal++;
    }
    Groups[g].ShiftNdx = w;
  } // g
  Out << "\nShiftNdx dimension(states)  " << Vs.size(); 
  Out << "\nShiftNdx dimension(groups) " << Ws.size(); 

/* 
First we classify the reductions - simple/subset, arithmetic, ranked. 
*/
  vector<pair<vector<unsigned>, vector<unsigned>>> Ranking; // Each element of Ranking separates two sets of states.
/* EqTest probably not worth the parser code.  It is not smaller or faster, it is just a bit less demanding on the packing process. 
*/
  enum {Simple=1, Subset, Arith, GeTest, EqTest}; 
  for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
    if(States[Sj].RedSwitch.size()<2){
      States[Sj].RedStep[0]=Simple;
      continue;  // At most one slot needed for reduction.
    }
    if(IsSubset(Sj)) States[Sj].RedStep[0]=Subset; // May set RedSubsetOf    
  } // Sj
// Shorten subset chains.
  for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
    if(States[Sj].RedSwitch.size()<2) continue;
    if(!States[Sj].RedSubsetOf) continue;
    unsigned Sk=Sj;
    while(States[Sk].RedSubsetOf) Sk=States[Sk].RedSubsetOf;
    States[Sj].RedSubsetOf = Sk;
    Out << "\nRed[" << Sj << "] is a subset of " << Sk;
  } // Sj
// How best to trim away at complex switches is not obvious, but a reasonable way would be to separate off the target that is most frequent.  Such separations must eventually lead to a solution.
  unsigned Step=0;
  for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
    if(States[Sj].RedSwitch.size()<2) continue;
    if(States[Sj].RedSubsetOf) continue;
// Copy the RedSwitch to the targetted form. (That is unique target as first, vector of Discrims as second.)
    for(unsigned r=0;r<States[Sj].RedSwitch.size();r++){
      unsigned t;
      for(t=0;t<Targets.size();t++){
        if(Targets[t].first == States[Sj].RedSwitch[r].Target) break; 
      } // t
      if(t==Targets.size()) Targets.push_back(pair<unsigned, DiscrimsType>(States[Sj].RedSwitch[r].Target,ThisDiscrims));
      Targets[t].second.push_back(States[Sj].RedSwitch[r].Discrim);
    } // r
// Work out best way to implement this switch.  It might take steps, e.g. 
    for(Step=0;Step<3;Step++){
// Sort Targets on size of Targets.second, i.e how many Discrims go to this target. 
      sort(Targets.begin(), Targets.end(), TargetsSort);
// If the greatest frequency is one, all targets are different, Arith best.  (Base slot holds required constant)
      if(Targets[0].second.size()==1){
        // For Step>0, there might be just one target.
        if(Targets.size()==1){
          States[Sj].RedStep[Step] = Simple; 
          States[Sj].Next[Step] = Targets[0].first;
          break;
        }
        States[Sj].RedStep[Step] = Arith; 
        // .Arg is the displacement constant.  It will be set when states placed. (i.e. given addresses)
// Arith works by making gaps between Discrim and Target all the same. The Gap ID is the index on Gaps.  That selects vector showing the (equal) gaps.
        TheseGaps.clear();
        for(unsigned h=0;h<Targets.size();h++){
          TheseGaps.push_back(pair<unsigned, unsigned>(Targets[h].first, Targets[h].second[0])); 
        } // h
        Gaps.push_back(TheseGaps);
        break;  
      } 
#if 0
      if(Targets[0].second.size()==2 && Targets[1].second.size()==1){// If Discrim choice of 2 is happening just once, we can do an equals compare with the stack followed by Arith transit.
        States[Sj].RedStep[Step] = EqTest;
        States[Sj].Arg[Step] = Targets[0].second.back(); // One of the Discrim
        Targets[0].second.pop_back();
        States[Sj].Next[Step] = Targets[0].first;
        continue;
      }
// Why was that equals test needed?  A Rank would do the same job.
#endif 
      // A partition is needed.
      States[Sj].RedStep[Step] = GeTest; 
      // .Arg will be set when partitions known 
      States[Sj].Next[Step] = Targets[0].first;
// The Discrims leading to that target must rank differently from all the other Discrims.
      Ranking.push_back(pair<vector<unsigned>, vector<unsigned>>((Targets[0].second),Targets[1].second));
      vector<pair<vector<unsigned>, vector<unsigned>>>::iterator x;
      x = Ranking.end()-1;
      for(unsigned j=2;j<Targets.size();j++){
         x->second.insert(x->second.end(),Targets[j].second.begin(),Targets[j].second.end());
      } // j
// Remove first element of Targets for next step.
      Targets[0].second.clear();
      Targets.erase(Targets.begin()); // Drops the first target.  Hopefully simpler remainder takes at most two steps.
    } // Step
    if(Step==3) throw 9;
// Clear out Targets for re-use with next switch design.
    for(unsigned h=0;h<Targets.size();h++){
      Targets[h].second.clear();
    } // h
    Targets.clear();

// Show solution for this state.
    Out << '\n' << Sj ;
    for(Step=0;Step<3;Step++){
      if(States[Sj].RedStep[Step]==Arith) {Out << 'a';break;}
      if(States[Sj].RedStep[Step]==Simple) {Out << 's';break;}
      if(States[Sj].RedStep[Step]==Subset) {Out << 'u';break;}
      if(States[Sj].RedStep[Step]==GeTest) Out << 'k' << States[Sj].Next[Step];
    } // Step
  } // Sj
// Physical size is now computable.
  for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
    States[Sj].Physical = 0;
    if(States[Sj].Transits.size()) {
// One slot suffices to index the arrays for acceptability and targets.
      States[Sj].Physical++;
// Unacceptable may be message or reduce.
      if(States[Sj].MsgMN) States[Sj].Physical++;
    } // Shift part
    if(States[Sj].HasRed){
      States[Sj].Physical++;
      if(States[Sj].Action) States[Sj].Physical++;
      if(!States[Sj].RedSubsetOf && States[Sj].RedSwitch.size()>1){// Will need extra test(s).
        if(States[Sj].RedStep[0]==GeTest) States[Sj].Physical+=2;
        if(States[Sj].RedStep[1]==GeTest) States[Sj].Physical+=2;
      }
    } // Reduction part.
    PhysicalTotal += States[Sj].Physical; 
  } // Sj
  Out << "Physical Total " << PhysicalTotal;

// Show the Gaps as first found.
  unsigned GapID;
  for(GapID=0;GapID<Gaps.size();GapID++){
    Out << endl;
    for(unsigned h=0;h<Gaps[GapID].size();h++){
      Out << "Gap " << GapID << ' ' << Gaps[GapID][h].first << ':' << Gaps[GapID][h].second << ' ';
    } // h 
  } // GapID 
/* When there are two lists of gaps with a common element then the lists have to be joined.  Every gap in the joined list is equal.  If a list has both A:B and B:A then something
is wrong - cannot have a gap equal to its negative.  
Looks like this doesn't happen in practice?  
*/
   map<pair<unsigned,unsigned>, unsigned> ToGapID;

  for(GapID=0;GapID<Gaps.size();GapID++){
    for(unsigned h=0;h<Gaps[GapID].size();h++){
      map<pair<unsigned,unsigned>, unsigned>::iterator i = ToGapID.find(pair<unsigned,unsigned>(Gaps[GapID][h].first, Gaps[GapID][h].second));
      if(i!=ToGapID.end()){
        Out << "\nJoinee" << i->second << ' ' << GapID; 
      }
    } // h 
  } // GapID 
  Out << "\nJoined";
  Out << "\n Rankings";
  for(unsigned r=0;r<Ranking.size();r++){
    Out << "\n< ";
    for(unsigned k=0;k<(Ranking[r].first).size();k++){
      Out << Ranking[r].first[k] << ' ';
    } // k
    Out << "\n> ";
    for(unsigned k=0;k<(Ranking[r].second).size();k++){
      Out << Ranking[r].second[k] << ' ';
    } // k
  } // r 

   
/* We now have the specification for the final numbering (which implies packing) of the states.   There are some 300 states, of varying sizes, which will
 occupy some 900 slots if well packed.  Their addresses are constrained.  The Gaps array shows vectors of pairs where the pairs in vector all have the same difference in their addresses.
 The Ranking is a vector where each element is a pair of vectors and the first vector must have lower addresses than the members of the second vector.

 So at this point the parser is irrelevant - we just have a packing problem.  We know the problem can be solved because the CRX 1999 implementation.  But it doesn't 
make a lot of sense to recode it here in March 2012 because our actual interest has to be in a different problem - what happens with a larger syntax, i.e. OORexx?

 It looks difficult to get a larger syntax into a space using 10-bit addresses to 16-bit slots.  But it might be possible with more trickery.  (e.g. if the elements of the 
switch array were not state addresses but the states themselves.) If 11-bit addresses are needed it still might be possible to control the parsing will the remaining 5 bits instead of 6.
  
 So it looks like time to take a break from coding and construct an ANSI-style BNF of OORexx syntax, and see what packing problem that leads to.
*/


} // Pack 

unsigned IsSubset(unsigned s){ // Is the reduction switch of s a subset of some other?
  for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
    if(Sj==s) continue;  // Is subset of itself but no point in saying so. 
    if(States[Sj].RedSubsetOf) continue;  
    if(States[Sj].RedSwitch.size() < States[s].RedSwitch.size()) continue;
    // Is everything from s also in Sj??
    unsigned r;
    for(r=0;r<States[s].RedSwitch.size();r++){
      unsigned t;
      for(t=0;t<States[Sj].RedSwitch.size();t++){
        if(States[s].RedSwitch[r].Discrim==States[Sj].RedSwitch[t].Discrim && States[s].RedSwitch[r].Target==States[Sj].RedSwitch[t].Target) break; // One from s in Sj
      } // t
      if(t==States[Sj].RedSwitch.size()) break; // One from s not in Sj.  Break towards next Sj
    } // r 
    if(r==States[s].RedSwitch.size()){
      States[s].RedSubsetOf = Sj;
      return Sj;
    }
  } // Sj
  return 0;
} // IsSubset

void WriteAccept(){
/* Put out the Assembler code for the test which tokens acceptable in which states. (See old syn.inc) */
  Out << "\n;Generated matrix for accept-by-this-state, state*token. " << RowsCount << '*' << ColsCount;
  Out << "\nAcceptBits dword 0 dup(?)";
  unsigned AcceptNdx = 0;
  for(unsigned g=0;g<NonKeyCount;g++){
    if(Groups[g].AcceptNdx != AcceptNdx) continue;
    string s = "00000000000000000000000000000000";
    for(unsigned Sj=0;Sj<ParseStateNum;Sj++){
      unsigned StateNdx = States[Sj].StateAcceptsGroups;
      if(StateAcceptsGroupsV[StateNdx].at(g)) s[StateNdx]='1';
    } //Sj
    Out << "\n dword " << s.substr(0,ColsCount) << "y;  " << AcceptNdx;
    AcceptNdx++;
  } // g
// ?? not like syn.inc but plough on for now.
  Out << "\n;Equates for which token groups use which row.";

  for(unsigned g=0;g<GroupCount;g++){
    Out << "\n$Grp" << g << "ndxb equ ";
    if(g<NonKeyCount)
      Out << Groups[g].AcceptNdx+1; // Add one so that zero can be used to mean Bool-not-used.  (Keywords are checked for acceptance by using lists of acceptable keywords)
    else Out << '0';
  } // g
  Out << endl;

 } // WriteAccept