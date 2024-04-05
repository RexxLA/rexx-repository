/*------------------------------------------------------------------------------
  Here is where the Bcode is made, in assembler format.
  First the fragments, because we don't know yet how many of them.
õ-----------------------------------------------------------------------------*/

/* The bcode fragments can go anywhere in code since they are labelled. */
/* We will use the ALL2INC utility to divide the output file up so each
potential INCLUDE needs to be marked. */
  Out << ";õ bf\\Frag.inc";
/* We will go for showing shortest fragment first. (equ's OK order) */
NextFrag:
 int w=CodeLen;
 int n=0;
 for(p=Scp[0].Lo;p<Scp[ScopeCount].Lo;p++){
   if(Grist[p].Type==Fragment){
     if(Grist[p+1].FragFact<w){
       w=Grist[p+1].FragFact;n=Grist[p].FragFact;
       k=Grist[p+2].FragFact;/* Scope */
     }
   }
 }
 /* CodeLen marker means a fragment we have already put out. */
 if(w!=CodeLen){
 /* Does it still merit being a fragment? */
  if(Bsize(n,n+w)>MeritCommit){
   FragNum++;
   Arg0=Scp[k].LocalVars+Scp[k].Args+1;
   cout << "\nFrag " << FragNum <<" @ " << hex << n << hex << " Scp " << k << ' ' << Arg0;
   int t=Bcode(USHRT_MAX,n,n+w,0);/* Map for jumps. */
   Out << endl << endl;
   Out << "Frag" << FragNum << "$$ ";
   Middle=false;
   Bcode(USHRT_MAX,n,n+w,1);
/* Fragments need a RETURN at the end. */
   Separate();
   Out << "_RetF";
   cout << "\nFragment " << FragNum << " bytes " << t+1 << ',';
   TotBytes+=t+1;
/* Now that it has been translated, we can make all uses of it look the same
in the Pcode version. */
/* Clear subject that has gone to routine. */
   for(p=n;p<n+w;p++){
     Grist[p].Type=PartOf;
   }
/* And mark it as a call to already made routine. */
   Grist[n].Type=Fragment;
   Grist[n].FragFact=n;
   Grist[n+1].FragFact=w;
/* And mark it and other places that call same fragment. */
   for(p=Scp[0].Lo;p<Scp[ScopeCount].Lo;p++){
     if(Grist[p].Type==Fragment
        && Grist[p].FragFact==n && Grist[p+1].FragFact==w){
       Grist[p].Value=FragNum;Grist[p+1].FragFact=CodeLen;
       cout << "\nFragment %d invoked @" << FragNum << "." <<p;
     }
   } /* Making same. */
  } /* Emit */
  else {
  /* Expand the fragment call away. */
   for(p=Scp[0].Lo;p<Scp[ScopeCount].Lo;p++){
     if(Grist[p].Type==Fragment
        && Grist[p].FragFact==n && Grist[p+1].FragFact==w){
       cout << "\nSubject @" << n << " expanded back @" << p << '.';
       for(r=0;r<w;r++){
         Ushort s;
/* It should be enough to copy just the Type, so undoing any aliasing of
names. */
/* No, doesn't work because FragFacts etc needed. Hence ValueWas. */
         s=Grist[p+r].ValueWas;
         Grist[p+r]=Grist[n+r];
         if(Grist[p+r].Type==Var || Grist[p+r].Type==OpVar) Grist[p+r].Value=s;
       } /* Copy subject. */
     } /* A use */
   } /* p */
  } /* Expand */
  goto NextFrag;
 } /* End of have fragment to output or expand. */

/* That just leaves the original coding, as it is now. */
 for(k=0;k<ScopeCount;k++){
   Ushort j,x;
   Arg0=Scp[k].LocalVars+Scp[k].Args+1;
   int t=Bcode(k,Scp[k].Lo,Scp[k+1].Lo,0);
   cout << "\nScope ";
   PrintConHere(Scp[k].Index);
   cout << " bytes " << t << '.';
   TotBytes+=t;
   cout << endl;
/* For the first and the builtins we want a separate include made. */
   j=Consp[Scp[k].Index].Here;
   if(k==0 || strncmp(Symsp+j+1,"BIF",3)==0){
     Out << ";õ bf\\";
     x=*(Symsp+j);
     if(k){x-=3;j+=3;}
     x=Min(x,8);
     Out << string((char *)Symsp+j+1,(int)x);
     Out << ".inc";
   }
   Out << endl;
/* Ones that are called internally need labels. (Also others for hard code) */
   ShowConHere(Scp[k].Index);
   if(Consp[Scp[k].Index].v.f.Callee){
     Out << "$$ ";
   }
   else
     Out << ' ';
   Middle=false;
   Bcode(k,Scp[k].Lo,Scp[k+1].Lo,1);
/* Assume all these routines have their own returns. */
 }
/* That has made the actual Bcode.  Still need vectors that point to those
labels. */
/* The array of Bcode addresses just has to go somewhere in the code segment.*/
 /* Now a vector of Bcode addresses. Begin with internals. */
 Out << endl << "RoutineBase$ equ $";
 for(int j=ConLo;j<ConsCount;j++){
   if(Consp[j].v.f.Callee && !Consp[j].v.f.External){
     Out << endl << " dw ";ShowConHere(j);Out << "$$";
   }
 }
/* Then fragments */
 Out << endl << "FragsBase$ equ $";
 for(int j=0;j<FragNum;j++){
   Out << endl << " dw Frag" << j+1 << "$$";
 }
/* That has made the Bcode.  Now for equates that give access to the arrays. */
/* This allocation of the code points is the one that actually matters.
/* Do MaxLocals again 'cos of aliasing. */
 MaxLocals=0;
 for(k=0;k<ScopeCount;k++){
   MaxLocals=Max(MaxLocals,Scp[k].LocalVars);
 }
/* High code points address the local variables. */
 cout << "\nTgt " << MaxArgs << " + " << MaxLocals << " + " << MaxDelta;
 TgtRange = MaxArgs+MaxLocals+MaxDelta;
 Points=256-2*TgtRange;
 Points=Points-FragNum;
 Points=Points-InternalsCount;
 w = Points; 
 Points=Points-2*GlobalsCount;
 cout << "\nFor m/c routines " << Points;
 Out << endl;
 Out << ";õ bf\\Bcodes.inc" << endl;
 Out <<  "Tgt equ " << 2*TgtRange;
 Out << "ú$Locals equ 256-Tgt";

 for(int j=0;j<MaxArgs;j++){
   Out << endl << "Arg" << (j+1) << " equ " << 2*(j+1);
 }
