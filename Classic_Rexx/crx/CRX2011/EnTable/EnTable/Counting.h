/* At this stage we give the production names a compact numbering and the terminals (non-productions) a compact numbering.  An array of type ProdTerm describes both the productions and terminals.
An array of integers gives the components of the productions.  After this, the Source and Operands data is no longer needed. 
*/

// For Rexx, we need to refer to some terminals specifically:
unsigned int TermVarSymbol; 
       
struct ProdTermType{
  unsigned short MsgMN; // For easy test of which terminals are Msgnn.nn type.
  int ProdPos; // Index into production detail, for productions.
  bitset<TermLimit> Begins;      // For productions.
  bitset<ProdLimit> BeginProds;  // For productions.
  unsigned GroupNum; // Renumbering for terminals.
  string Symbol; // For both productions and terminals.
  bool IsKey; 
  bool IsKeyS; // For curiosity - which keywords are in shift lists?
  bool IsKeyR; // For curiosity - which keywords are in Aheads?
};

  ProdTermType *ProdTerms;
  short *Gram;

  unsigned int ProdCount, TermCount, GramZi; // For array sizes.

  map<string,short>::iterator LHS;

// For Positions in the grammar, two numbers are packed into one by Num = Num1*Split+Num2
 int const Split = 256;

void Counting(){
  ProdCount=0;TermCount=0;

// Source scan one allows us to mark the productions (which appear as LHSs) amongst the Operands.
  for(GramNdx j=0;j<Source->size();j++){
// Find what may be multiple productions with the same LHS.
    LHS=Source->at(j++).Operand;
    LHS->second |= 3; // Used and a production.
    // Scan to Break, possibly repeatedly.
    for(;;){
      while(Source->at(j).Operator!=Break){
        Source->at(j++).Operand->second |= 1; // Used
      }
      if(j+1==Source->size() || Source->at(j+1).Operand!=LHS) break;
      j+=2;
    } // Group with same LHS
  } // j

// A scan of Operands now allows productions to be counted and given a compact numbering.  Similarly terminals (with negative numbering).
  for(map<string, short>::iterator i=Operands.begin();i!=Operands.end();i++)
    if(i->second) i->second = (i->second>1)? ++ProdCount : 0-(++TermCount);

// Allocate for the new format data.      
  ProdTerms = new ProdTermType[ProdCount+TermCount];
  GramZi = Source->size();
  Gram = new short[GramZi];

// A second scan of Operands copies the symbols into the arrays.  Also take the opportunity to set MsgMN. Also opportunity to flag keywords.
  for(map<string, short>::iterator i=Operands.begin();i!=Operands.end();i++){
    int t;
    if(!i->second) continue; // "Empty" operand no longer used.
    if(i->second>0){
      t = i->second-1; // Productions, which come low in the new numbering.
      ProdTerms[t].MsgMN = 0;
    }
    else{ 
      t = -(i->second)-1+ProdCount;
      ProdTerms[t].MsgMN = 0;
      if(i->first.substr(0,3)=="Msg" /* && i->first.find(".")!=string::npos Msg36 is used. */){
         // Note major and minor error codes in one number.
        unsigned short m=0,n=0; bool Logic = false; char Char;
        for(unsigned int k=3;k<i->first.size();k++){
          Char = *(i->first.substr(k,1).data());
          if(Char == '.'){
            m=n;Logic=true;
            n=0;
          }
          else n=10*n+(Char-'0');
        } // k
        if(!Logic){
          m=n;n=0;/* Was no '.' */
        }
        ProdTerms[t].MsgMN = 256*m+n;
      } // Msg
      ProdTerms[t].IsKey = (i->first.substr(0,1)=="'" && i->first.substr(1,1) >= "A" && i->first.substr(1,1) <= "Z"); 
    }
    ProdTerms[t].Symbol = i->first;
    ProdTerms[t].IsKeyS = false; // Initialise
    ProdTerms[t].IsKeyR = false;
    if(ProdTerms[t].Symbol == "VAR_SYMBOL") TermVarSymbol = t-ProdCount;
  } // i

// A final pass over Source makes a version of the grammar with indices to arrays replacing the iterators to maps.
// The ranges in the value of an array element are 0 to ProdCount-1 for productions, ProdCount to ProdCount+TermLimit-1 for terminals, -1 for Break. 

  for(GramNdx j=0;j<Source->size();j++){
    short v = Source->at(j).Operand->second; // Production name as compact number.
    Gram[j] = v-1;  // Equivalent on output.
    ProdTerms[Gram[j]].ProdPos=j; // Note start of group with same LHS.
    LHS=Source->at(j++).Operand;
    // Scan to Break, possibly repeatedly.
    for(;;){
      while(Source->at(j).Operator!=Break){
        v = Source->at(j).Operand->second;
        Gram[j++] = v>0 ? v-1 : -v-1+ProdCount;
      }
      Gram[j]=-1; // Output form of Break. 
      if(j+1==Source->size() || Source->at(j+1).Operand!=LHS) break;
      j++;
    } // Group with same LHS
  } // j

// The following are no longer needed:
  Operands.clear();Source->clear();

  if(strchr(Switches,'V')){ // V for Verbose
    Out << endl << "Terminals" << endl;
    for(Index j=ProdCount;j<TermCount+ProdCount;j++) Out << j-ProdCount << ':' << ProdTerms[j].Symbol << ' ';
    Out << endl << endl << "Productions" << endl;
    for(Index j=0;j<ProdCount;j++) Out << j << ':' << ProdTerms[j].Symbol << '(' << ProdTerms[j].ProdPos << ") ";
    Out << endl;
  } // V
} // Counting

   
