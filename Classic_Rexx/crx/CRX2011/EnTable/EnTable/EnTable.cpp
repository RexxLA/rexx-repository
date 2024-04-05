/* EnTable.cpp 
This program has a grammar as input and produces tables for parsing that grammar.  In particular, it has been tested with the grammar from the ANSI Rexx language Standard, and the tables subsequently incorporated in a Rexx 
interpreter. 
The program should be invoked with two arguments, the file names for input and output, optionally preceeded by a third argument which is options for the invocation.  Those options must have '/' as the first character and may have:

Note that in order to use C++ bitset class the program has capacity constraints.  The following constants in stdafx are adequate for the ANSI syntax but recompilation with larger numbers might be necessary for other syntaxes.
*/

#include "stdafx.h" // Precompiled header as used by Visual Studio 2010
// Various C++ STD features:

using namespace std;
#include "Thrown.h"  // The program may finish abnormally in various ways.

// User provides arguments on the command line.
  char * InArg, * OutArg, * Switchp, * Switches;
  char * InMemory; // The input file gets copied to memory.
  ofstream Out;  

#include "ReadIn.h"
#include "Simplify.h"
#include "Counting.h"
#include "States.h"
#include "Stack.h"
#include "Pack.h"

int main(int argc, char * argv[]){ // Single byte chars in parameters.  In Visual Studio 2010 compiles, properties do not default to this, so need setting. (And entry point name)
try {
// If unexpected parameters, remind user of usage. 
  if(argc!=3 && argc!=4) throw 2;
  if(argc==4 && argv[1][0]!='/') throw 2;

// Collect the arguments:
  if(argc==3){InArg=(char *)argv[1];OutArg=(char *)argv[2];Switches=" ";}
  else {InArg=(char *)argv[2];OutArg=(char *)argv[3];
// Upper case the switches.  
    Switches=_strdup(argv[1]);
    Switchp=Switches;while(*Switchp){*Switchp=(char)toupper(*Switchp);Switchp++;}
  }
  ReadIn(); // Read the input file and convert to simplified sequential text plus a dictionary of symbols. 
  cout << "Syntax check of grammar performed." << endl; // (Original source file is not used after here.)
  Simplify();// Rewrite the grammar so that the only operation is abuttal.
  cout << "Grammar translated to basic form." << endl; // Basic form has vector Source of productions, referencing dictionary Operands.
  Counting(); // Separate terminals from non-terminals and use compact numberings.
  cout << "There are " << TermCount << " terminals and " << ProdCount << " productions." << endl;
  if(TermCount>TermLimit || ProdCount>ProdLimit) throw 7;
  // The grammar is now held in arrays ProdTerms and Gram.
  NoteStates();  // Establish the grammar states.
  cout << "There are " << States.size() << " grammar states. There are " << ConflictCount << " conflicts." << endl; 
  NoteStack();
  cout << "There are " << ParseStateNum << " parser states."  << endl;
  Pack(); 
  
  Out.close();
  return 0;
} // try
catch( int x ) {
  cout <<  Thrown[x] << endl;
  if(x==5) cout << InMemory;
  exit(x);
}
// Unreachable
}


