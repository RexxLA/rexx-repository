/* The input has two parts, concatenated, which describe the Rexx being turned to Bcode.  One is pseudo-code, the other a list of constants and variable names.
*/
  ifstream::pos_type Size;
  ifstream Tfile (InArg, ios::in|ios::binary|ios::ate); if (!Tfile.is_open()) throw 4; 
   // get length of file:
  Tfile.seekg (0, ios::end); Size = Tfile.tellg(); Tfile.seekg (0, ios::beg);
// Self defining w.r.t. length.
  Tfile.read((char *)&CodeLen,2); Tfile.read((char *)&SymsLen,2);
  if(CodeLen+SymsLen+4 != Size) throw 5;
  Codep = new Uchar [CodeLen]; Tfile.read ((char *)Codep, CodeLen);
  Acquired+=CodeLen;
  Symsp = new char [SymsLen]; Tfile.read (Symsp, SymsLen);
  Acquired+=SymsLen;
  Tfile.close();
  CodepLo=Codep; CodepZi=Codep+CodeLen;

// Might as well open the output for early message if unopenable. 
  Out.open("BF.T", ios::out|ios::trunc);
  if(!Out.is_open()) throw 9;

/* Scan through Symbols to count variables and constants. */
/* 255=char, 254=Label, 253=binary */
 VarsCount=0;ConsCount=0;StemCount=0;
 for(int k=sizeof SegHeader;k<SymsLen;){ // Ignore the segment header.
   Uchar j=(Uchar)Symsp[k];k=k+j+1; // Length of the symbol.
   Uchar m=(Uchar)Symsp[k]; // Type of symbol.
   if(k>=SymsLen || m<253){
     VarsCount++;
     if(Symsp[k-1]=='.') StemCount++;// A stem default variable.
   }
   else {
     ConsCount++;
     k++;
     if(m==254) k+=2;
     if(j==0) NullCon=ConsCount; // In practice there will be a "".
   }
 }
  // $Omitted is a special constant. Stems are double elements.
 cout << "\nOriginal Variables Count " << VarsCount << '+' << StemCount << " Original Constants Count " << ConsCount+1; 
 if(VarsCount>VarLimit) throw 8;
 VarsCount+=StemCount;ConsCount++;
/*------------------------------------------------------------------------------
  Fill the arrays in various ways.
õ-----------------------------------------------------------------------------*/
 
  Varsp = new Vshape[VarsCount]; Consp = new Vshape[ConsCount];
  VarsLen=VarsCount*(sizeof (Vshape)); ConsLen=ConsCount*(sizeof (Vshape));
  Acquired = Acquired + VarsLen + ConsLen;

// Scan through Symbols again to set fields in arrays.  255=char, 254=Label, 253=binary 
  Ushort VarsNdx=0, ConsNdx=1;
  for(int k=sizeof SegHeader;k<SymsLen;){
   int w=k;
   int j=(Uchar)Symsp[k];k=k+j+1;
   int m=(Uchar)Symsp[k];
   if(k>=SymsLen || m<253){
     Varsp[VarsNdx].Here=w;
     Varsp[VarsNdx++].Label=0;
     if(Symsp[k-1]=='.'){Varsp[VarsNdx].Label=0; Varsp[VarsNdx++].Here=w;}
   } else {
     Consp[ConsNdx].Here=w; Consp[ConsNdx].Label=0;
     k++;
// Label values are the 16-bit offsets into the raw Pcode.
     if(m==254){Consp[ConsNdx].Label=*(Ushort *)(Symsp+k); k+=2;}
     ConsNdx++;
   }
 }
 Consp[0].Here=Consp[NullCon].Here;

  for(int j=0;j<Dim(Freq);j++) Freq[j]=0;
  RangeOps=0;
/* Clear some flag spaces. */
  for(int j=0;j<VarLo;j++) Varsp[j].v.g.u=0; /* In case these flags used. */
/* Mark the system variables. */
  for(int j=VarLo;j<VarsCount;j++){
    Varsp[j].VarNum=0;
    Varsp[j].v.g.u=0;int k=Varsp[j].Here;
    if(*(Symsp+k+1)=='#'){
      Varsp[j].v.f.System=true;
      *(Symsp+k+1)='?';
    }
  }
/* Find all the labels. (& strange constants) */
// This tells us all the Scopes - each builtin separate and a few for arithmetic.
  for(int j=0;j<ConLo;j++) Consp[j].v.g.u=0; /* In case these flags used.  Assert not HexIt */
  ScopeCount=0;
  for(int j=ConLo;j<ConsCount;j++){
    Uchar x;
    Consp[j].v.g.u=0;int k=Consp[j].Here;
    x=*(Symsp+k);
// A leading underscore indicates that the routine does not have variables of its own.  (Similar to called Rexx label without PROCEDURE).
    if(*(Symsp+k+1)=='_') Consp[j].v.f.Open=true;
    int m=Consp[j].Label;
// There is a range that corresponds to the routines aka scopes we are concerned with. 
    if(m<BifBase && m>1){
      Consp[j].v.f.Scope=true;ScopeCount++;
    }
// There are some characters which should be fed to Assembler as hex, otherwise taken as tab etc.
    for (int y=0;y<x;y++) if(*(Symsp+k+y+1)<' ') Consp[j].v.f.HexIt=true;
  }

  if(ScopeCount==0) throw 7; // No labels check.

  bitset<VarLimit> Spare;
  Scp = new ScopeShape[ScopeCount+1]; /* One spare to hold bound equal to beyond-last-scope. */
  Acquired+=(ScopeCount+1)*sizeof(ScopeShape);
  int s=0;
  for(int j=ConLo;j<ConsCount;j++)
    if(Consp[j].v.f.Scope){
      Scp[s].Index=j;
      Scp[s].Lo = 0;
      Scp[s].Args = 0;
      for(int i=0;i<7;i++) Scp[s].ArgCt[i] = 0;
      Scp[s].LocalVars = 0;
#if UseRestarts
      if(Restarts) Scp[s].LocalVars=ScpX[s];
#else
      Scp[s].LocalVars=0;
#endif
      Scp[s].Sized = false;
      Scp[s].Alive.reset(); 
      Scp[s].Mapped.reset();
      Consp[j].v.g.ScopeNum=s++;
    } // new s

  Grist = new Pshape[CodeLen+1];
  Acquired += sizeof(Pshape)*(CodeLen+1); 
  for(int k=0;k<CodeLen+1;k++){
    Grist[k].Overlap = 0;
    Grist[k].SkipTo = 0;
    Grist[k].Delta = 0;
    Grist[k].DoDelta = 0;
    Grist[k].From = 0;
    Grist[k].WithinP = false; 
  }//k