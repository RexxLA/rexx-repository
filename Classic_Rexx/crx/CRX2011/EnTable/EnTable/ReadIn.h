/* ReadIn converts the input to an internal form.  The grammar of the input is: (See ANSI standard section 6.1.5)

The BNF syntax, described in BNF, is:
production := identifier ':=' bnf_expression
bnf_expression := abuttal | bnf_expression '|' abuttal
abuttal := [abuttal] bnf_primary
bnf_primary := '[' bnf_expression ']'
| '(' bnf_expression ')' | literal
| identifier | message_identifier
| bnf_primary '+'

The order of the productions is insignificant but here the convention is that the grammar is covered by a production for "Starter", which comes first. 

The internal form is a dictionary with symols of both productions and terminals (ie non-productions like keywords of the grammar) in it,  together with a vector containing the productions in a simple form.  Simple form has LHS of some production (as a pointer
to the dictionary item) followed by the RHS components. There is a terminator ending each production.
 
*/
/* The defines say what each character in the input is to be translated to. ASCII is assumed here. */
// Underscore names for sets of characters - just convention.
#define _ '\x00' 
#define _LETTER '\x01'
#define _SPECIAL '\x02'
#define _WHITE '\x03'
#define _QUOTE '\x04'
#define _ADIGIT '\x05'
#define Slash '\x06'
#define Colon '\x07'
#define Assignment '\x08'
#define LeftParen '\x09'
#define RightParen '\x0A'
#define LeftBracket '\x0B'
#define RightBracket '\x0C'
#define SpecialOr '\x0D'
#define Plus '\x0E'
#define Abuttal '\x0F'
// End-Of-Source may or may not be a character in the source.
#define EOS '\x10'  
// Break is an invented operator, as production terminator.
#define Break '\x10'

/* Note period treated as letter. */
/* Microsoft 'C' book says 0x09 to 0x0d as whitespace. */
/* We need period as letter for the utilities. */
char Translate[]={
 /* 000 */ _,_,_,_,_,_,_,_,_,_WHITE,
 /* 010 */ /*lf*/_WHITE,_WHITE,_WHITE,/*cr*/_WHITE,_,_,_,_,_,_,
 /* 020 */ _,_,_,_,_,_,EOS,_,_,_,
 /* 030 */ _,_,/* */_WHITE,_,/*"*/_QUOTE,_,_,_,_,/*'*/_QUOTE,
 /* 040 */ /*(*/LeftParen,/*)*/RightParen,_,/*+*/Plus,_,_,/*.*/_LETTER,/*/*/Slash,_ADIGIT,_ADIGIT,
 /* 050 */ _ADIGIT,_ADIGIT,_ADIGIT,_ADIGIT,_ADIGIT,_ADIGIT,_ADIGIT,_ADIGIT,/*:*/Colon,/*;*/_,
 /* 060 */ /*<*/_,/*=*/Assignment,/*>*/_,_,_,/*A*/_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,
 /* 070 */ _LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,
 /* 080 */ _LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,
 /* 090 */ _LETTER,/*[*/LeftBracket,_,/*]*/RightBracket,_,/*_*/_LETTER,_,/*a*/_LETTER,_LETTER,_LETTER,
 /* 100 */ _LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,
 /* 110 */ _LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,_LETTER,
 /* 120 */ _LETTER,_LETTER,_LETTER,_,/*|*/SpecialOr,_,_,_,_,_,
 /* 130 */ _,_,_,_,_,_,_,_,_,_,
 /* 140 */ _,_,_,_,_,_,_,_,_,_,
 /* 150 */ _,_,_,_,_,_,_,_,_,_,
 /* 160 */ _,_,_,_,_,_,_,_,_,_,
 /* 170 */ _,_,_,_,_,_,_,_,_,_,
 /* 180 */ _,_,_,_,_,_,_,_,_,_,
 /* 190 */ _,_,_,_,_,_,_,_,_,_,
 /* 200 */ _,_,_,_,_,_,_,_,_,_,
 /* 210 */ _,_,_,_,_,_,_,_,_,_,
 /* 220 */ _,_,_,_,_,_,_,_,_,_,
 /* 230 */ _,_,_,_,_,_,_,_,_,_,
 /* 240 */ _,_,_,_,_,_,_,_,_,_,
 /* 250 */ _,_,_,_,_,_
 };
  int Flength; /* Input file length when read as ASCII. */

/* The initial file is ASCII charactors and it is tokenised into operators and operands.  The token stream becomes a vector.  Because STL requires elements of a vector to have the same types, we need
each element to have two fields - an integer for if it is an operator and a pointer into a map for if it is an operand.
*/

map<string,short> Operands;

struct Token{
  int Operator;
  map<string,short>::iterator Operand; 
};
vector<Token> Tokens;

map<string,short>::iterator LookUp(char * p, int Len){
  string s(p, Len);
  return Operands.insert(pair<string,short>(s,0)).first;
} 

  Token EmptyToken;

/*------------------------------------------------------------------------------
NextToken
õ-----------------------------------------------------------------------------*/
char * Shadow; // Translated copy of the source.
int NextTokenState=0; // Retains progress across calls to NextToken.
Token TokenItem, HeldToken;
char *p, *q; // Cursors for scan. p and q are kept in synch with p addressing the source and q addressing the Shadow.

void NextToken(){ // Sets TokenItem
  TokenItem.Operator=0;TokenItem.Operand=Operands.end();
  char *r, *s; 
 switch(NextTokenState){
   case 0 :                   /* Initially */
      p=InMemory;q=Shadow;
      NextTokenState=1;
   case 1 :                   /* No Token held from last call. */
 Switch:
     switch(*q){
       case _WHITE:p++;q++;goto Switch;
       case Slash:
         if(*(p+1)!='*') *p='\0',throw 5;
         r=p+2;
     InComment:
     /* Find next '*' */
         while(*r!='*' && *r!='\0') r++;if(*r!='*') *p='\0',throw 5;
         if(*++r!='/') goto InComment;
         r++;q+=r-p;p=r;goto Switch;

       case LeftParen: case RightParen: case LeftBracket: case RightBracket: case SpecialOr: case Plus:
         TokenItem.Operator = *q; 
         p++;q++;
         return;
       case _ADIGIT:
       case _LETTER:r=q+1;while(*r==_LETTER || *r==_ADIGIT) r++;
         TokenItem.Operand = LookUp(p, r-q);
         p+=r-q;q=r; // Past the operand.
/* It is a design choice whether to introduce Break as a prefix to each production, as a separator of productions, or as terminator of each production.  The latter was chosen. 
Check ahead, since we find the Break terminator of productions by detecting the start of a production. (Or by end of source) 
*/
         r=p;s=q; // r & s for lookahead.
/* Skip blanks and comments for this check. */
         while(*r=='/' || *s==_WHITE){
          if(*r=='/'){
            if(*(r+1)!='*')  *p='\0',throw 5;
            r=r+2;
 InCommentx:
 /* Find next '*' */
            while(*r!='*' && *r!='\0') r++;if(*r!='*')  *p='\0',throw 5;
            if(*++r!='/') goto InCommentx;
          }
          r++;s=q+(r-p);
         }
// We are looking ahead from every non-literal operand but only a LHS has a colon after it.
/* If we do have ':', we must return Break before returning the Token we just went past. */
         if(*r==':' ){
           if(*++r!='=') *r='\0',throw 5; 
           p=r+1;q=s+2; // No point in ever returning ":=" as a token because Break serves its function.   
           HeldToken=TokenItem;
           NextTokenState=2;
           TokenItem.Operator=Break;
         }
         return;
       case _QUOTE:{
         char c=*p;
         r=p+1;while(*r!=c && *r!='\n' && *r!=EOS) r++;
         if(*r++!=c)  *p='\0',throw 5;
         TokenItem.Operand = LookUp(p, r-p);
         q+=r-p;p=r;
         return;
       } 
       case EOS:{
         TokenItem.Operator = Break; 
         return;
       }
       default:;
         *p='\0',throw 5; // Includes colon and assign which will be out of place.
     } /* switch *q */
   case 2:           /* Return a held token */
     TokenItem=HeldToken;
     NextTokenState=1;
     return;
  } /* Switch NextTokenState */
} /* NextToken */

void Ors();
/*------------------------------------------------------------------------------
Scan Primary in bnf            primary= operand | '(' Ors ')' | '[' Ors ']'
              Optional + after
õ-----------------------------------------------------------------------------*/
void Prim(){
 if(!TokenItem.Operator){// Operand
   Tokens.push_back(TokenItem);NextToken();
 }
 else if(TokenItem.Operator==LeftParen){
   NextToken(); // Bracketing not retained in Polish notation.
   Ors();if(TokenItem.Operator!=RightParen) *p='\0',throw 5;
   NextToken();
 }
 else if(TokenItem.Operator==LeftBracket){
   NextToken(); // Bracketing not retained in Polish notation.
   Ors();if(TokenItem.Operator!=RightBracket) *p='\0',throw 5;
   TokenItem=EmptyToken;Tokens.push_back(TokenItem); // Add Empty as an extra Or alternative.
   TokenItem.Operator=SpecialOr;Tokens.push_back(TokenItem);
   NextToken();
 }
 else *p='\0',throw 5;
/* Here after Prim */
 if(TokenItem.Operator==Plus){Tokens.push_back(TokenItem);NextToken();} // BNF repetition syntax.
} /* Prim */
/*------------------------------------------------------------------------------
Cats in bnf            cats= prim | prim cats
õ-----------------------------------------------------------------------------*/
void Cats(){
 int CatCount=0;
 Token t;
 t.Operator=Abuttal;
 for(;;){
   Prim();
   if(TokenItem.Operator && TokenItem.Operator!=LeftParen && TokenItem.Operator!=LeftBracket) break;
   CatCount++;
 } 
 for(int j=0;j<CatCount;j++) Tokens.push_back(t); // Postfix the operations. 
} /* Cats */
/*------------------------------------------------------------------------------
Ors in bnf            ors = cats | cats '|' ors
õ-----------------------------------------------------------------------------*/
void Ors(){
 int OrCount=0;
 Token t;
 t.Operator=SpecialOr;
 for(;;){
  Cats();
  if(TokenItem.Operator!=SpecialOr) break;
  OrCount++;
  NextToken();
 }
 for(int j=0;j<OrCount;j++) Tokens.push_back(t); // Postfix the operations. 
} /* Ors */

/*------------------------------------------------------------------------------
Scan to bnf rules.  Bnf = prod_list;  prod= lhs ':=' Ors
õ-----------------------------------------------------------------------------*/
void Bnf(){
/* The Breaks between productions are detected by the colon of ":=" and inserted in the token stream prior to the LHS of the production.  There is no need to retain the assignment in the vector that 
holds the production descriptions because the layout of the description is always a LHS followed by the RHS. 
*/
 NextToken(); // Ignore initial break generated by look-ahead.
 if(TokenItem.Operator!=Break) *p='\0',throw 5;

 do{
  NextToken();// LHS
  if(TokenItem.Operator) *p='\0',throw 5;
  Tokens.push_back(TokenItem);

  // The Break substituted for ":=" so RHS here.
  NextToken();
  Ors();
  // End of production.
  if(TokenItem.Operator!=Break) *p='\0',throw 5;
  Tokens.push_back(TokenItem);
 } while(*q!=EOS);
} /* Bnf */

void ShowGrammar(vector<Token> g){
  string Optors="()[]|+&";
  for(GramNdx j=0;j<g.size();j++){
    if(g[j].Operator==Break) Out << endl;
    else{
      if(g[j].Operator) Out << Optors[g[j].Operator-LeftParen];
      else Out << g[j].Operand->first;
      Out << ' ';
    }
  } // j
} //ShowGrammar


void ReadIn(){
/*------------------------------------------------------------------------------
  Read all input file to one variable in memory, InMemory.
õ-----------------------------------------------------------------------------*/
  ifstream::pos_type size;
  ifstream Tfile (InArg, ios::in|ios::binary|ios::ate);
  if (Tfile.is_open()){
    size = Tfile.tellg();Flength = (int) size; InMemory = new char [Flength+1];
    Tfile.seekg (0, ios::beg); Tfile.read (InMemory, size); Tfile.close();
    InMemory[Flength] = '\0'; // Make sure scans have a stop. 
  }
  else throw 3;
/* Might as well open the output for early message if unopenable. 
*/
  Out.open(OutArg, ios::out|ios::trunc);
  if(!Out.is_open()) throw 6;

/*------------------------------------------------------------------------------
   Divide source into tokens and check some syntax. 
õ-----------------------------------------------------------------------------*/
/* Make a shadow the source, with a byte describing each byte of source. */
/* Depending on the editor that made it, the input may or may not have an end0of-file '1a'x at the end.  Try to cope with both possibilities. */
  Shadow = new char[Flength+1];
  char * p=InMemory;
  for(char * q=Shadow;q<Shadow+Flength;q++){
    *q=Translate[*p++];
  }
  Shadow[Flength] = EOS;
/* Our grammar input does not allow "empty" productions - those with no RHS. (i.e. A:=;)
But it might as well have since A:=[B] is not syntactically prevented, i.e empty productions are possible.
*/
  // Create an operand for "empty".
  map<string,short>::iterator Empty = Operands.insert(pair<string,short>("#Empty",0)).first;
  EmptyToken.Operator=0;EmptyToken.Operand=Empty;

  Bnf(); // Scan the source and put tokens in Reverse Polish order.

} // Readin

