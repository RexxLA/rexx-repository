/* There are different ways of writing a grammar that essentially describe the same grammar.  E.g. A:=B C D could be A:=B E;E:= C D
In the same sense, there are different ways of simplifying.  The essential is removing the operators ()[]|+.  
The simplifying here is not exactly that done twenty years ago but near enough.
During ReadIn we removed () by going to Polish notation in the Token sequence output. Also we replaced [Something] with (Something | #Empty).  
However, the abbutal alternation and repetition operators are still possibly mixed in any production.  The next aim is to have extra productions so that each has only one sort of opertion.

Roughly, algorithm is:
   scan a production.
   if simple copy from Source to Target
   if non-simple extract some part, copy the rest, add a production to Target for the extracted part.
   Repeat over Source.
   Make Target the Source, repeat until stable.   

After this stage, each production is either all abuttals or all alternatives (or just A:=B).  The alternatives can easily be tread as a series of A:=B with A constant and B each alternative.  So the essentials for further processing,
that there should be nothing but abuttal, have been achieved.

But future processing will be easier if #Empty components are eliminated.  Also there may be advantages from "neatening" the grammar, although that is subjective.

Eliminating a production is done by replacing all references to its LHS by the content of its RHS.  That is not possible when a reference to its LHS is contained in its RHS.  If the intention is to make tables for an interpreter,
as opposed to just a syntax checker, it is not right to eliminate productions that have an action associated with them.  An associated action is shown by the presence of a dot in the production name, e.g. realaddition.10 means
that the interpreter must do something (such as make pseudo code to perform addition) where the realaddition.10 production is recognised.    

The actions of the form Msgmm.nn give a number to a syntax error.  What can follow such a syntax error is undefined, even if the grammar appears to define it. So the grammar can be simplified by removing anything that is abutted after
a Msgmm.nn.  (See Msg21.1 in the ANSI grammar).   
*/

// The mechanics of copy-with-changes involves a vector for the Source grammar and another for the Target. (It might be done with vector::erase and vector::insert but that is not obviously better.)

  vector<Token> LikeTokens, *Source = &Tokens, *Target = &LikeTokens, *Swop;
  int NewNameCount=0;char NewNameBuffer[5];
  void Eliminate(Index n); // Eliminates a production by putting its RHS whereever its LHS was referenced.
  vector<Token> Eliminee;
  typedef unsigned int GramNdx;  // Index into the grammar, e.g. Source.

void Simplify(){
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
First the grammar is divided into smaller productions by inventing names for some bits and making them separate productions.
õ-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
  bool Stable;
  Token BreakToken;
  BreakToken.Operator=Break;
  Token AbutToken;
  AbutToken.Operator=Abuttal;
  Target->clear();
  do{ // while
    GramNdx k, ProdBegin, ProdEnd;
    unsigned int OperandCount, OrCount, RepCount;
    Stable=true;
    for(GramNdx j=0;j<Source->size();j++){// Over all Source productions
// Scan one Source production RHS:
      ProdBegin=j; // LHS here.
      OperandCount=0;OrCount=0;RepCount=0;
      for(k=ProdBegin+1;Source->at(k).Operator!=Break;k++){
        if(!Source->at(k).Operator) OperandCount++;
        else if(Source->at(k).Operator==SpecialOr) OrCount++;
        else if(Source->at(k).Operator==Plus) RepCount++;
      } // k  
      ProdEnd=k;
// Pick out the simple cases.
      if(RepCount==0 && (OrCount==0 || OrCount==OperandCount-1)){
// Because OR is commutative, and so is abuttal, the place of the operator amongst the operands makes no difference.  i.e (A|B)|C is the same as A|(B|C)
        if(OrCount){
          for(k=ProdBegin+1;k<ProdEnd;k++){
            // For each part of RHS make LHS:=part. 
            if(Source->at(k).Operator!=SpecialOr){
              Target->push_back(Source->at(ProdBegin)); 
              Target->push_back(Source->at(k));
              Target->push_back(BreakToken);
            }
          } // k
//         HeldToken.Operator=SpecialOr;for(unsigned int n=0;n<OrCount;n++) Target->push_back(HeldToken);  
        } else{
          for(k=ProdBegin;k<ProdEnd;k++){
            if(Source->at(k).Operator!=Abuttal) Target->push_back(Source->at(k));
          } // k
/* It is not worth outputting the Abuttal operators because in further operations they will be implicit (from lack of other operators)
*/
          Target->push_back(BreakToken);  
        }
        j=ProdEnd;continue;// Continue at next production.
      }  // Simple

      Stable=false;
// Remove first operation from a complex LHS:
      map<string,short>::iterator NewProduction;
      GramNdx PartBegin, PartEnd;
      for(k=ProdBegin+1;;k++){
        if(Source->at(k).Operator) break;// leftmost operation.
      }
      // Invent a new name. #n
      unsigned int m = sprintf_s(NewNameBuffer,sizeof(NewNameBuffer),"%d\n",NewNameCount++);
      string s(NewNameBuffer, m-1);
      NewProduction = Operands.insert(pair<string,short>("#" + s,0)).first;
      HeldToken.Operator = 0; HeldToken.Operand = NewProduction;

      if(Source->at(k).Operator==Plus){
// Because it is the first operation, its operand will immediately preceed it.
        PartEnd=k;PartBegin=k-1; 
// A=B+ is replaced by A=B; A=A B;
        Target->push_back(HeldToken);// NewProduction.
        Target->push_back(Source->at(PartBegin));
        Target->push_back(BreakToken);
        Target->push_back(HeldToken);// NewProduction.
        Target->push_back(HeldToken);// NewProduction.
        Target->push_back(Source->at(PartBegin));
        Target->push_back(AbutToken);
        Target->push_back(BreakToken);
      } else if(Source->at(k).Operator==Abuttal){
        PartEnd=k;PartBegin=k-2; 
        Target->push_back(HeldToken);// NewProduction.
        Target->push_back(Source->at(PartBegin));
        Target->push_back(Source->at(PartBegin+1));
        Target->push_back(AbutToken);
        Target->push_back(BreakToken);
      } else{ // A:=B|C is replaced by A:=B;A:=C;   Operands will immediately preceed operation.
        PartEnd=k;PartBegin=k-2; 
        Target->push_back(HeldToken);// NewProduction.
        Target->push_back(Source->at(PartBegin));
        Target->push_back(BreakToken);
        Target->push_back(HeldToken);// NewProduction.
        Target->push_back(Source->at(PartBegin+1));
        Target->push_back(BreakToken);
      } // Operation is now on Target.
      // Copy altered production. 
      for(k=ProdBegin;k<PartBegin;k++) Target->push_back(Source->at(k));
      Target->push_back(HeldToken);// NewProduction.
      for(k=PartEnd+1;k<=ProdEnd;k++) Target->push_back(Source->at(k));
      j=ProdEnd;
    } // j
    Swop=Source;Source=Target;Target=Swop;Target->clear();// Setup for further passes. 
  } while(!Stable);
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
Eliminate some, in practice most, of the invented names by replicating productions that use them.
õ-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
 
/* Choose something to eliminate.  Here we are (mostly) restricting to our invented productions.
*/
  GramNdx ProdsBegin, ProdsEnd;
  unsigned int ProdsCount;
  map<string,short>::iterator LHS;
  bool Circular; 

  for(;;){
    for(GramNdx j=0;j<Source->size();j++){
// Find what may be multiple productions with the same LHS.
      ProdsBegin=j;LHS=Source->at(j++).Operand;Circular=false;
      // Scan to Break, possibly repeatedly.
      for(ProdsCount=1;;ProdsCount++){
        while(Source->at(j).Operator!=Break){
          if(Source->at(j).Operand==LHS) Circular = true;
          j++;
        }
        if(j+1==Source->size() || Source->at(j+1).Operand!=LHS) break;
        j+=2;
      } 
      ProdsEnd=j; 
      // From ProdsBegin to ProdsEnd there are ProdsCount productions with the same LHS.  LHS is referenced in some RHS iff Circular.
      if(!Circular && (LHS->first)[0]=='#') break;  // Eliminee found.
/* Might as well eliminate the very simple cases -  A:=B where there is only one alternative for A, and B is just one element, and A is not associated with an action.  (e.g. nop:='NOP')
If A had an action and B did not one could treat the A:=B as B:=A and eliminate B.   But I don't think that case happens for Rexx.
In any case the simplifications here are not exactly the same as those in the original program - those left instruction_list and variable_list and a couple of temps uneliminated so had four more productions in the simple form.
*/
      if(ProdsEnd == ProdsBegin+2){
        if(LHS->first.find(".")==string::npos && LHS->first!="starter") break;
      }
      ProdsCount=0;// Distinquish fallthru
    } // j
    if(!ProdsCount) break;// Nothing more to eliminate.
// Move out what is to be eliminated.
    Eliminee.clear();
    for(GramNdx j=0;j<Source->size();j++){
      if(j>=ProdsBegin && j<=ProdsEnd) Eliminee.push_back(Source->at(j));
      else Target->push_back(Source->at(j)); 
    } // j
    Swop=Source;Source=Target;Target=Swop;Target->clear();// Source now without Eliminee. 
    Eliminate(ProdsCount);
    // Source will have changed for the next pass.
  } // for

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
Elide the #Empty operands, noting whether that leaves anything with no RHS.  (As is case with Program in the ANSI Rexx grammar).
õ-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  bool Problem; 
  for(GramNdx j=0;j<Source->size();j++){
    if(Source->at(j).Operator==Break || Source->at(j).Operand!=EmptyToken.Operand) Target->push_back(Source->at(j));
  } // j
  Swop=Source;Source=Target;Target=Swop;Target->clear();

  do{// Look for a production with no RHS  
    Problem=false;
    GramNdx j,PriorBreak=0;
    for(j=0;j<Source->size();j++){
      if(Source->at(j).Operator==Break){
        if(PriorBreak && PriorBreak==j-2) break; // Production w/o RHS
        PriorBreak=j;
      } 
    } // j
    if(j!=Source->size()){
      Problem=true;
/* The production at j-1 is all empty.  We could eliminate the production name by eliminating all the productions with the same LHS.  What was done originally was remove just the one alternative. That is what is done here.
(If the name associates an action, we are making the assumption that is what the grammar writer intended.)  
*/
      GramNdx Probj = j-1;
      map<string,short>::iterator Prob=Source->at(Probj).Operand;
// Scan all source, production by production.
      for(GramNdx j=0;j<Source->size();j++){
        GramNdx pp,qq,rr,jj;
        pp=j;// Begin of this production. 
        // Does it have a reference to the Eliminee?
        rr=0;
        for(jj=pp+1;Source->at(jj).Operator!=Break;jj++){
          if(Source->at(jj).Operand==Prob) rr=jj; 
        } 
        qq=jj; 
        // Is it the one we are dropping?
        if(pp!=Probj){
          if(rr){// The production from pp to qq requires the reference at rr to left out of one copy of it.
            // Copy pp thru qq, n times.
            for(unsigned int nn=0;nn<2;nn++){
              for(jj=pp;jj<=qq;jj++){
                // Copy parts not rr
                if(jj!=rr) Target->push_back(Source->at(jj));
                else{ // Copy only in one copy.
                  if(nn) Target->push_back(Source->at(jj));
                } // Replacing @rr.
             } // jj 
            } // nn
          } // rr
          else{// Plain copy of production that does not reference eliminee.
            for(jj=pp;jj<=qq;jj++) Target->push_back(Source->at(jj));
          }
        }
        j=qq;
      } // j
      Swop=Source;Source=Target;Target=Swop;Target->clear();
    } // Problem solved but there may be more.
  } while(Problem); 

  if(strchr(Switches,'V')) ShowGrammar(*Source); // V for Verbose
  
} // Simplify

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
Routine Eliminate does the replacements to eliminate Eliminee.
õ-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
bool AfterMsg; // Extra tests in these passes prevent anything being abutted after a Msgmm.nn action.
void ToTarget(Token t){// Managed append to Target.
  if(t.Operator==Break){AfterMsg=false;Target->push_back(t);return;}
  if(AfterMsg) return;
  Target->push_back(t);
  string s=t.Operand->first;
  if(s.substr(0,3)=="Msg" && s.find(".")!=string::npos) AfterMsg=true;
} //ToTarget

void Eliminate(Index n){
/* If there was A:= E E where E was the Eliminee and n==5 then we would need 25 versions of A.  To cope with such possible situations, multiple passes are used.
*/
  map<string,short>::iterator Lhs;
  Lhs=Eliminee[0].Operand;
  unsigned int ee;
  bool Found;
  do{
    Found=false;
// Scan all source, production by production.
    for(GramNdx j=0;j<Source->size();j++){
      GramNdx pp,qq,rr,jj;
      pp=j;// Begin of this production. 
      AfterMsg=false;
      // Does it have a reference to the Eliminee?
      rr=0;
      for(jj=pp+1;Source->at(jj).Operator!=Break;jj++){
        if(Source->at(jj).Operand==Lhs) rr=jj; 
      } 
      qq=jj; 
      if(rr){// The production from pp to qq requires the reference at rr to be expanded away.
        Found=true;
        // Copy pp thru qq, n times.
        ee=1; // Beginning of first of rhs in Eliminee.
        for(unsigned int nn=0;nn<n;nn++){
          for(jj=pp;jj<=qq;jj++){
            // Copy parts not rr
            if(jj!=rr) ToTarget(Source->at(jj));
            else{ // Copy from Eliminee.
              for(;Eliminee.at(ee).Operator!=Break;ee++) ToTarget(Eliminee.at(ee));
              ee+=2; // Next to copy from Eliminee.
            } // Replacing @rr.
          } // jj 
        } // nn
      } // rr
      else{// Plain copy of production that does not reference eliminee.
        for(jj=pp;jj<=qq;jj++) ToTarget(Source->at(jj));
      }
      j=qq;
    } // j
    Swop=Source;Source=Target;Target=Swop;Target->clear();
  } while(Found);
} // Eliminate