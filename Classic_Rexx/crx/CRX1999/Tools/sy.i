/*------------------------------------------------------------------------------
To simplify an extended BNF grammar

The grammar has been read in.  A dictionary of symbols is addressed by WalkBase
and an array Text represents the productions.  Positive elements in the array
are dictionary references, negative elements are operators.

1. Initialize

2. Remove the A:=B productions.

3. Copy from Array1 to Array2, looking for and making appropriate changes.
   Remove B:=B
   A:=B+ => A:= t t:= B  t:= B C

4. Rename Array2 as Array1 and vice versa.

5. Repeat from 3 while any simplification on latest pass.

6.  Steps 3 4 5 are done again for a different rewrite rule.
    Remove temps:  A:=t t:=B t:=B C => A:=B A:=B C

7. Rename Array2 as Array1 and vice versa.

8. Repeat from 6 while any simplification on latest pass.

9. Delete what follows messages.  (April 94)

10. Permutations & empties

11. Cut out duplicates (normally from messages)

12. Write grammar from Array1.

13.  Show statistics.

õ-----------------------------------------------------------------------------*/
/* Simplify shares Permute with RD */
#define Permute -99
 static Wshort* Array1, * Array2, * Swapper;
 static Ushort n1,n2; /* Counts for the arrays */
 static short Element; /* To go in Array1 or Array2 */
 static Ushort Passes;
 static Bool Logic;
static Ushort *Num2Cnt; /* From Num to LHS count */
static Ushort *Num2Sub; /* From Num to substitute symbol */
static jmp_buf LongAwry;
static void ToArray2(void);/* Puts an element on Array2 */
static void ShowProd(Offset n);
static void ShowTerm(Offset n);
static void Simplify(void){
   Bool Done;
   Ushort i,j,k,Begins; /* Cursors */
   short ParenLevel;
   short t; /* Element */
   Ushort NewProduction, NoteEnd, NoteBegin;
   Symbol *Sym;
/*------------------------------------------------------------------------------
1. Initialize
õ-----------------------------------------------------------------------------*/
 NoteBegin=0;
 Array1=Text; /* As set by readin */
 n1=Array1->w.Needs;
 Text=NULL; /* Keep only one pointer to each wallet. */
 Array2=calloc(sizeof(Wallet),1);
 Array2->w.Stride=sizeof(Ushort);
 n2=0;
/* Need some space for noting A:=B; type substitutions.  */
   if((Num2Cnt=calloc(BothCount,sizeof(Ushort)))==NULL) Failure;
   if((Num2Sub=calloc(BothCount,sizeof(Ushort)))==NULL) Failure;
   if(setjmp(LongAwry)) goto Awry;
/*------------------------------------------------------------------------------
2. Remove the A:=B productions.
õ-----------------------------------------------------------------------------*/
/* A preamble to count how often things appear on LHS. */
   Logic=1;
   for(j=0;j<n1-1;j++){
     Element=Array1->e[j];
     if(Element==Break) {
       Element=Array1->e[j+1];
       Sym=(Symbol *)(WalkBase+Element);
       (*(Num2Cnt+Sym->Num))+=1;
       if(Logic){
         Logic=0;
         j--; /* Count first one twice - need to retain starter. */
       }
     }
   }
/* For things appearing just once, we will see if RHS is simple. */
   for(j=0;j<n1-1;j++){
     Element=Array1->e[j];
     if(Element==Break) {
       Element=Array1->e[j+1];
       Sym=(Symbol *)(WalkBase+Element);
       if(Sym->IsExit==No && *(Num2Cnt+Sym->Num)==1){
         if(j+4<n1 && Array1->e[j+4]==Break){
/* j+1 is lhs, j+2 is assign, j+3 is rhs */
         *(Num2Sub+Sym->Num)=Array1->e[j+3]; /* Showing this is substitute */
         Sym->Temp=Yes;
#if 0
         NewLine();
         ShowA(&(Sym->s[0]),Sym->SymbolLength);
         ShowS(" gone");
#endif
         }
       }
     }
   }
   for(;;){
     Done=True;/* Hopefully */
     for(j=0;j<n1;j++){
       Element=Array1->e[j];
       if(Element>0) {
       Sym=(Symbol *)(WalkBase+Element);
       if(*(Num2Sub+Sym->Num)){
           Done=False;
           Array1->e[j]=*(Num2Sub+Sym->Num);
#if 0
           NewLine();
           ShowA(&(Sym->s[0]),Sym->SymbolLength);
           ShowS(" replaced ");
           Element=Array1->e[j];
           Sym=(Symbol *)(WalkBase+Element);
           ShowA(&(Sym->s[0]),Sym->SymbolLength);
#endif
         }
       }
     } /* Text */
     if(Done) break;
   }
   /* The resulting B:=B productions will get thrown away later. */
/*------------------------------------------------------------------------------
3. Copy from Array1 to Array2, looking for and making appropriate
   simplifications.
õ-----------------------------------------------------------------------------*/
   for(;;){
     Bool Together;
     if(Passes++==20) goto Awry;/* Something amiss. */
     Done=True;/* Hopefully */
     for(j=0;j<n1;j++){
       Element=Array1->e[j];
       if(Element==Break) {
/* Test for B:=B; */
         if(Array1->e[j+1]==Array1->e[j+3] && Array1->e[j+4]==Break){
           Done=False;
           j+=3;continue;
         }
         ToArray2();
/* There may be a New Production to write, that was enclosed in parentheses
originally. */
/* But we can't slip it in here if the lhs of what is coming is the same
as the lhs we just did because we need productions which have the same
lhs to be kept together. */
         Together=Yes;if(j+1==n1) Together=No;
         if(Array1->e[Begins]!=Array1->e[j+1]) Together=No;
/* Adding commentary April 97. */
/* If we have reached a sound place to add things into the output side,
and have noted something that needs copying... */
/* NewProduction was set at same stage as NoteBegin. */
         if(NoteBegin && !Together){
           /* Output "NewP =" */
           Element=NewProduction;ToArray2();
           Element=Array1->e[Begins+1];ToArray2();
           if(Array1->e[NoteBegin]==Plus){/* See code below for this flagging */
             /* Change to recursive production */
             /* Add to "NewP =" the "Subject eol" */
             Element=Array1->e[NoteBegin-1];ToArray2();
             Element=Break;ToArray2();
             /* Now "NewP = NewP Subject eol" */
             Element=NewProduction;ToArray2();
             Element=Assignment;ToArray2();
/* Swapped these April 97 so Q67 = Q67 Q5 rather than Q5 Q67. */
             Element=NewProduction;ToArray2();
             Element=Array1->e[NoteBegin-1];ToArray2();
             Element=Break;ToArray2();
           }
           else{     /* () or [] */
             for(i=NoteBegin+1;i<NoteEnd;i++){/* The part from (....) */
               Element=Array1->e[i];ToArray2();
             }
             Element=Break;ToArray2();
/* In the case where it was [...] we also have new one optional. */
             if(Array1->e[NoteBegin]==LeftBracket){
               /* Output "NewP = eol" */
               Element=NewProduction;ToArray2();
               Element=Array1->e[Begins+1];ToArray2();
               Element=Break;ToArray2();
             }
           }
           NoteBegin=0;/* Says nothing pending. */
           Done=False; /* Need to rescan this */
         }
         Begins=j+1;
         continue;
       }
       if(NoteBegin==0 && Element==SpecialOr){
 /* Close off first alternative. */
         Element=Break;ToArray2();
 /* Repeat the Alpha: */
         for(k=Begins;k<Begins+2;k++){
           Element=Array1->e[k];ToArray2();
         }
         continue;
       }
/* One set of () or [] per production per pass. */
       if(NoteBegin==0 && Element==LeftParen){
 /* Find matching bracket. */
         ParenLevel=0;
         for(k=j+1;;k++){
           if((t=Array1->e[k])==LeftParen) ParenLevel++;
           if(t==RightParen) {
             if(ParenLevel==0) break;
             ParenLevel--;
           };
           if(t==Break) break;
         }
 /* Remember range for later definition of this new production. */
         NoteBegin=j;NoteEnd=k;
         j=k;/* To skip (...) this time */
/* Make it a separate production. */
         NewProduction=NewName();
         Element=NewProduction;ToArray2();
/* It is not to be a Temp if followed by + */
         if(Array1->e[k+1]==Plus)
           ((Symbol*)(WalkBase+NewProduction))->Temp=No;
         continue;
       } /* ( */
       if(NoteBegin==0 && Element==LeftBracket){
/* Find matching bracket. */
         ParenLevel=0;
         for(k=j+1;;k++){
           if((t=Array1->e[k])==LeftBracket) ParenLevel++;
           if(t==RightBracket) {
             if(ParenLevel==0) break;
             ParenLevel--;
           };
           if(t==Break) break;
         }
/* Remember <> so as to not copy later. */
         NoteBegin=j;NoteEnd=k;
/* Skip the whole thing now. */
         j=NoteEnd;
/* Make it a separate production. */
         NewProduction=NewName();
         Element=NewProduction;ToArray2();
/* It is an error to have repetition of an optional */
         if(Array1->e[k+1]==Plus)
             longjmp(ErrSig,4);
         continue;
       } /* [ */
       if(NoteBegin==0 && Element==Plus){
/* Skip the Plus. */
         NoteBegin=j; /* Flags doing repetition. */
/* This was an element "Subject +" */
/* Subject already copied so we will overwrite it. */
         n2--;
/* Make it a separate production. */
         NewProduction=NewName();
         Element=NewProduction;ToArray2();
         ((Symbol*)(WalkBase+NewProduction))->Temp=No;
         continue;
       } /* + */
       ToArray2();
     }
/*------------------------------------------------------------------------------
 4. Rename Array2 as Array1 and vice versa.
õ-----------------------------------------------------------------------------*/
    Swapper=Array1;Array1=Array2;Array2=Swapper;
    n1=n2;n2=0;
/*------------------------------------------------------------------------------
 5. Repeat from 3 while any simplification on latest pass.
õ-----------------------------------------------------------------------------*/
     if(Done) break;
   }
/*------------------------------------------------------------------------------
 6.  Steps 3 4 5 are done again for a different rewrite rule.
õ-----------------------------------------------------------------------------*/
/* There are no [] () | now. */
/* We next get rid of the productions we created to get rid of () []. */
   for(;;){
     if(Passes++==40) goto Awry;/* Something amiss. */
     Done=True;/* Hopefully */
     for(j=0;j<n1;j++){
       Element=Array1->e[j];
/* Look for a Lhs. */
       if(Element>0 && Array1->e[j-1]==Break) {
         Begins=j;
         (Sym=(Symbol*)(WalkBase+Element))->Prod=Yes;
       }
/* Here we are finding references to temps. */
/* References are positive, not following semicolons */
       if(Element>0 && Array1->e[j-1]!=Break){
           if((Sym=(Symbol*)(WalkBase+Element))->Temp==Yes){
/* Copy the expansion of the Temp. */
             Done=False;
             t=Element;
/* First find the expansion of it. */
             for(k=1;k<n1;k++){
               if(Array1->e[k]==t && Array1->e[k-1]==Break) break;
             }
/* Will need to cycle for its alternatives.  */
Cycle:
             k+=2; /* Skip : */
             for(;;){
               Element=Array1->e[k++];
               if(Element==Break) break;
               ToArray2();
             }
/* Copy what follows the reference to the temp. */
             i=j+1;
             for(;;){
               Element=Array1->e[i++];
               ToArray2();
               if(Element==Break) break;
             }
/* If there are more expansions of the Temp */
             if(k<n1 && Array1->e[k]==t){
/* Copy from beginning of production that was using Temp. */
               for(i=Begins;i<j;i++){
                 Element=Array1->e[i];
                 ToArray2();
               }
/* Repeat from before. */
               goto Cycle;
             }
/* Skip this production. */
           j=i-1;
           continue;
           }
       }
       ToArray2();
     }
/*------------------------------------------------------------------------------
 7. Rename Array2 as Array1 and vice versa.
õ-----------------------------------------------------------------------------*/
    Swapper=Array1;Array1=Array2;Array2=Swapper;
    n1=n2;n2=0;
/*------------------------------------------------------------------------------
 8. Repeat from 6 while any simplification on latest pass.
õ-----------------------------------------------------------------------------*/
     if(Done) break;
   }
/* We need a an extra pass to cutout the temps. */
     for(j=0;j<n1;j++){
       Element=Array1->e[j];
/* Look for a Lhs. */
       if(Element>0 && Array1->e[j-1]==Break) {
         Sym=(Symbol*)(WalkBase+Element);
         if(Sym->Temp==Yes){
           while(Array1->e[++j]!=Break);
           continue;
         }
       }
       ToArray2();
     }
    Swapper=Array1;Array1=Array2;Array2=Swapper;
    n1=n2;n2=0;
/*------------------------------------------------------------------------------
9. Delete what follows messages.  (April 94)
õ-----------------------------------------------------------------------------*/
     for(j=0;j<n1;j++){
       Element=Array1->e[j];
/* Look for a Msg. */
       if(Element>0) {
         Sym=(Symbol*)(WalkBase+Element);
         if(Sym->IsMsg==Yes){
           ToArray2();
           while(Array1->e[j+1]!=Break){
             j++;
           }
           continue;
         }
       }
       ToArray2();
     }
    Swapper=Array1;Array1=Array2;Array2=Swapper;
    n1=n2;n2=0;
/*------------------------------------------------------------------------------
10. Permutations
õ-----------------------------------------------------------------------------*/
do{           /* until */
  Done=Yes; /* Hopefully */
  for(j=0;j<n1;j++){
  Ushort k,m,Lhsj,Permj,Breakj;
    Element=Array1->e[j];
    ToArray2();
    /* Lookahead after breaks */
    if(Element==Break){
      Lhsj=j+1;Permj=0;
      /* Scan to Break looking for Perm. */
      for(k=j+2;k<n1;k++){
        if(Array1->e[k]==Break) break;
        if(Array1->e[k]==Permute) Permj=k;
      }
      if(!Permj) continue;
      Done=No;
      Breakj=k;
      /* Special case 0 or 1 on rhs */
      if(Breakj<=Lhsj+3){
        Array1->e[Permj]=Assignment;
        continue;
      }
      /* The part from Lhsj up to Permj is repeated with alternatives
      for Permj to Breakj */
      for(k=Permj+1;k<Breakj;k++){
        for(m=Lhsj;m<Permj;m++){
          Element=Array1->e[m];ToArray2();
        }
        if(Permj==Lhsj+1) Element=Assignment,ToArray2();
        /* Put down element k, a perm, then non-k elements. */
        Element=Array1->e[k];ToArray2();
        /* Omit perm before just one thing. ie special case 2 things.*/
        if(Permj+3!=Breakj) Element=Permute,ToArray2();
        for(m=Permj+1;m<Breakj;m++){
          if(m!=k) Element=Array1->e[m],ToArray2();
        }
        Element=Break;ToArray2();
      }   /* k */
      /* Pick up original scan at Breakj */
      n2--; /* Avoids duplicate break */
      j=Breakj-1;
    } /* At break */
  }
  Swapper=Array1;Array1=Array2;Array2=Swapper;
  n1=n2;n2=0;
} while(!Done);
/* Now look for productions with nothing on the rhs */
{ Ushort NullBegin,NullLhs,SubjectBegin,k,SubjectEnd,Subject,Progress;
  Ushort NextNullBegin;
ReFindEmpty:
  NullBegin=0;
  for(j=0;j<n1-1;j++){
    Element=Array1->e[j+1];
    if(Element==Assignment){
      if(Array1->e[j+2]!=Break) continue;
      NullBegin=j;NullLhs=Array1->e[j];break;
    }
  } /* j */
  if(NullBegin==0) goto NoNull;
  Progress=0;
FindSubject:
  Subject=0;
  for(j=0;j<n1;j++){
    Element=Array1->e[j];
    if(Array1->e[j+1]==Assignment) SubjectBegin=j;
    if(Element==NullLhs && Array1->e[j+1]!=Assignment &&
       j>Progress){
      Subject=j;break;
    }
  } /* j */
  /* Copying pass */
  for(j=0;j<n1;j++){
    Element=Array1->e[j];
    if(Subject==0 && j==NullBegin)
      {j+=2;continue;}  /* Drop unused B=; */
    else
    if(j && j==Subject && Array1->e[j+1]!=Assignment){
      /* Replace A=B C by A=B C; A=C; when B can be null */
      /* Move Progress mark past the output B so it doesn't get expanded
      on next look. */
      Progress=n2+1;
      for(k=j;k<n1;k++){
        Element=Array1->e[k];ToArray2();
        if(Element==Break) break;
      }
      SubjectEnd=k;
      for(k=SubjectBegin;k<SubjectEnd;k++){
        if(k==j) continue;
        Element=Array1->e[k];ToArray2();
      }
      j=k;Element=Break; /* Pickup scan */
    } /* Alter */
    if(j==NullBegin)
      NextNullBegin=n2;/* For next pass */
    ToArray2();
  }
  NullBegin=NextNullBegin;
  Swapper=Array1;Array1=Array2;Array2=Swapper;
  n1=n2;n2=0;
  if(Subject) goto FindSubject;
  goto ReFindEmpty;
NoNull:;
} /* Empties */
/*------------------------------------------------------------------------------
11. Cut out duplicates (normally from messages)
õ-----------------------------------------------------------------------------*/
     for(j=0;j<n1;j++){
       Ushort k,i;
       Element=Array1->e[j];
/* Look for a Lhs. */
       if(Element>0 && Array1->e[j-1]==Break) {
/* Look for a duplicate starting at k. */
         for(k=0;k<j;k++){
           for(i=0;;i++){
             if(Array1->e[j+i]!=Array1->e[k+i]) break;
             if(Array1->e[j+i]==Break) {
               j+=i;
               goto Continuej;
             }
           }
         } /* Try next k */
       }
       ToArray2();
Continuej:;
     }
    Swapper=Array1;Array1=Array2;Array2=Swapper;
    n1=n2;n2=0;
/*------------------------------------------------------------------------------
12. Write grammar from Array1.
õ-----------------------------------------------------------------------------*/
 Awry:
 { Ushort j; /* Cursor */
   Symbol * Sym;
   Bool Lhs;
   Lhs=Yes;
   for(j=1;j<n1;j++){
     Element=Array1->e[j];
     if(Element==Permute) Element=Plus;
     if(Element<0){
       if(Element==Break){NewLine();Lhs=Yes;}
       else ShowC(Specials[-1-Element]);
     }
     else {
       Sym=(Symbol *)(WalkBase+Element);
       if(Lhs){
         Lhs=No;
         if(Sym->Hatch){
           ShowC('#');
         }
       }
       ShowA(&(Sym->s[0]),Sym->SymbolLength);
       if(Array1->e[j+1]>0) ShowC(' ');
     }
   }
 }
   NewLine();
/*------------------------------------------------------------------------------
13.  Show statistics.
õ-----------------------------------------------------------------------------*/
/* Because we have added productions we will have to count them again. */
/* Simplest to count terms as well. */
   ProdCount=0;BothCount=0;TermCount=0;Walk(CountTerm);
   /* Just drop the old Num2Sym */
   if((Num2Sym=malloc(BothCount*sizeof(Offset)))==NULL) Failure;
   Walk(CountProd); /* Fills Num2Sym as byproduct. */
   SetShowFile(""); /* So Show works on stdout */
   printf("\nProductions:\n");
   Walk(ShowProd);
   NewLine();
   printf("\nTerminals:\n");
   Walk(ShowTerm);
   NewLine();
   printf("\nProductions count:%d",ProdCount);
   printf("\nTerminals count:%d\n",TermCount);
};/* Simplify */
/*------------------------------------------------------------------------------
Subroutine ToArray2 puts Element on Array2.
õ-----------------------------------------------------------------------------*/
static void ToArray2(void){
  if(n2>65000 ){
    Failure;
  }
  if(Element==0){
    longjmp(LongAwry,1);
  }
    Array2->w.Needs=++n2;
    WalletCheck(Array2);
    Array2->e[n2-1]=Element;
}
/*------------------------------------------------------------------------------
Routine ShowProd to show the name of a Production.
õ-----------------------------------------------------------------------------*/
static void ShowProd(Offset n){
  Symbol *Sym;
  Sym=(Symbol*)(WalkBase+n);
  if(!Sym->Prod) return;
  if(Sym->Temp) return;
  ShowD(Sym->Num);ShowC(':');
  ShowA(Sym->s,Sym->SymbolLength);ShowC(' ');
} /* ShowProd */
/*------------------------------------------------------------------------------
Routine ShowTerm to show the name of a terminal.
õ-----------------------------------------------------------------------------*/
static void ShowTerm(Offset n){
  Symbol *Sym;
  Sym=(Symbol*)(WalkBase+n);
  if(Sym->Prod) return;
  ShowD(Sym->Num);ShowC(':');
  ShowA(Sym->s,Sym->SymbolLength);ShowC(' ');
} /* ShowTerm */
