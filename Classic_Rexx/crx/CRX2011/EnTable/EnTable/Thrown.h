// Ways the program can fail.
  char * Thrown[]={
/* 0*/ "\nEnTable finished normally.\n",
/* 1*/ "\nEnTable did NOT finish normally.\n",
/* 2*/ "\nEnTable InputFile OutputFile, or EnTAble Options InputFile OutputFile, makes tables from a grammar.",
/* 3*/ "\nEnTable Unable to open input file.",
/* 4*/ "\nEnTable Repetition of an optional in the grammar is disallowed.",
/* 5*/ "\nEnTable Syntax error in source. Good part is:",
/* 6*/ "\nEnTable Could not open the specified output file.",
/* 7*/ "\nEnTable You will have to recompile EnTable with larger capacity.",
/* 8*/ "\nEnTable Complexity not yet implemented. (Multiple reductions from one state)",
/* 9*/ "\nEnTable Internal error - sorry",
/* 10*/ "\nEnTable A state with no reduction and no error message - what is parser to do if latest token does not match any discriminator?",
  };