/* Here we are converting Pcode to a looser format.  Although CodesHdr and Codes have given some description of Pcode, there are still some bits here than depend on Pcode details.
*/

void PcodeToGrist(void){
bool VoidJump = false;
/* Is destructive of the incoming code. (Where?) */
/* I am going to remove any AssignConst because we are using immediate
constants in Bcode. */
/* Also remove the ARG(const) bif calls because we can access args like variables.  But compiler didn't reserve slots in the variables array for  these new variables. 
Here we use new high numbers, and detect them in PrintVarHere etc. */
 Uchar k;Ushort Op,q,kk,DoEndsAt;
 WithinParse=false;
 DoEndsAt=0;
 for(p=sizeof SegHeader,q=p,Codep=CodepLo;p<CodeLen;){
   if(p==0)
	    throw 10;
/* If we reach a place where DO ends, some accounting of temps is needed. */
 if(p==DoEndsAt){
   DoEndsAt=Grist[p].DoDelta;Grist[p].DoDelta=-Dod;
 }
Fiddled:
   k=Codep[p];
   if(k%2==0){
/* Oct 99. Now have Subcodes - they pass through as numbers. */
     if(k%8 == 2){
       Grist[p].Type=Number;
       Grist[p].Value=k;
       p++;
       if(k==mParseEnd){
         WithinParse=false;
       }
       continue;
     }
/* Simple loads/stores don't have to be with an operator */
     Grist[p].WithinP = true;
     if(!WithinParse){
       Grist[q].OpLen=p-q;q=p;
       Grist[p].WithinP = false;
     }
     kk=*(Ushort *)(Codep+p);
/* Nov 99 - invent Assign operations as needed. */
     if(k%8 == 6){
       kk-=6;
/* Leave targets in Parse looking like they used to. */
       if(!WithinParse){
       /* Outside Parse, prefix opcode. */
         Grist[p].Type=OpCode;
         Grist[p].Value=HereAssign;
         Freq[HereAssign]++;
         Grist[p+1].Type=OpVar;
         Grist[p+1].Value=Av(kk);
         p+=2;
         continue;
       }
     }
/* Normal operand here. */
     Grist[p].Type=(kk&7) ? Con : Var;
     Grist[p].Value=(kk&7)? Ac(kk) : Av(kk);
     Grist[p+1].Type=PartOf;p+=2;continue;
   }
/* Only operators get to here. */
   Op=k>>1;
   if(Op>=Dim(Pcodes))
	 throw 10;   
//   cout << endl << p << ' ' << Pcodes[Op].Op;
   if(strcmp(Pcodes[Op].Op,"Parse")==0){
     WithinParse=true;
   }
/* Special case - when we hit AssignConst, change it to Assign and retry. */
   if(strcmp(Pcodes[Op].Op,"AssignConst")==0){
     kk=*(Ushort *)(Codep+p+1);*(Ushort *)(Codep+p)=kk;
     Codep[p+2]=2*HereAssign+1;
     goto Fiddled;
   }
/* Any Exit won't be part of what we want. */
   if(strcmp(Pcodes[Op].Op,"Exit")==0){
     Grist[p].Type=PartOf;p++;continue;
   }
/* A Raise will be a missing Otherwise. We don't need it, or Jump that
preceeds it. */
/* Oct 99 change */
   if(strcmp(Pcodes[Op].Op,"Raise")==0){
     Grist[p-3].Type=PartOf;     /* Jump */
     Grist[p-2].Type=PartOf;
     Grist[p-1].Type=PartOf;
     Grist[p].Type=PartOf;p++;   /* Raise */
     Grist[p].Type=PartOf;p++;   /* Raise arg */
     continue;
   }
/* A When is the same as a Then in restricted Rexx */
   if(strcmp(Pcodes[Op].Op,"When")==0)
	   Op=HereThen;
/* Source is supposed to be error free. */
   if(strcmp(Pcodes[Op].Op,"Bif")==0) Op=HereBifq;

   Grist[p].Type=OpCode;
   Grist[p].Value=Op;
   Grist[q].OpLen=p-q;q=p;
/* Special case - when we hit Store, expand as Assign and load. */
   if(strcmp(Pcodes[Op].Op,"Store")==0){
     Grist[p].Value=HereAssign;
     p=p+1;
     Grist[p].WithinP = false;
     kk=*(Ushort *)(Codep+p);
     Grist[p].Type=OpVar;
     Grist[p].Value=(kk&7)? Ac(kk) : Av(kk);
     Grist[p+1]=Grist[p];
     Grist[p+1].Type=Var;
     p+=2;continue;
   }
         if(p==0)
	  throw 10;
/* Special case - changing Arg(n) to Argn */
   if(strcmp(Pcodes[Op].Op,"Bifq")==0){
     k=Codep[p+1];
     if(k==(2*HereARG+128) && Grist[p-2].Type==Con){
       Ushort k;char x;
       k=Consp[Grist[p-2].Value].Here;
       x=*(Symsp+k);
       if(x==1 && *(Symsp+k+1)>'0' && *(Symsp+k+1)<'6'){
         x=*(Symsp+k+1);
         if(x=='1') k=Arg1;
         if(x=='2') k=Arg2;
         if(x=='3') k=Arg3;
         if(x=='4') k=Arg4;
         if(x=='5') k=Arg5;
         Grist[p].Type=Arg;
         Grist[p].Value=k;
         Grist[p-2].Type=PartOf;
         Grist[p-1].Type=PartOf;
         Grist[p+1].Type=PartOf;
         p+=2;continue;
       }
     } /* Argn */
/* Special case - changing Arg(n,'E') to Argn _Exists */
     if(k==(2*HereARG+1) && Grist[p-4].Type==Con){
       Ushort k;char x;
       k=Consp[Grist[p-4].Value].Here;
       x=*(Symsp+k);
       if(x==1 && *(Symsp+k+1)>'0' && *(Symsp+k+1)<'6'){
         x=*(Symsp+k+1);
         if(x=='1') k=Arg1;
         if(x=='2') k=Arg2;
         if(x=='3') k=Arg3;
         if(x=='4') k=Arg4;
         if(x=='5') k=Arg5;
         Grist[p].Type=Arg;
         Grist[p].Value=k;
         Grist[p-4].Type=PartOf;
         Grist[p-3].Type=PartOf;
         Grist[p-2].Type=PartOf;
         Grist[p-1].Type=PartOf;
         Codep[p+1]=2*HereExists+1;
         p++;continue;
       }
     } /* ArgEn */
   } /* Bifq */
   if(strcmp(Pcodes[Op].Op,"Number")==0){
     Grist[p].DoDelta = Dod;
   }
   p++;/* Optor */
   if(strncmp(Pcodes[Op].Op,"Bool",4)==0) {
     Grist[p].OpLen=2;q++;
     VoidJump=true;
     Freq[Op]++;
     continue;
   }/* Bool prefix */
   if(Pcodes[Op].Has.Num){
     k=Codep[p];
     Grist[p].Type=Number;
     Grist[p].Value=k;
     p++;
   }
         if(p==0)
	  throw 10;
   if(Pcodes[Op].Has.Symbol){
     kk=*(Ushort *)(Codep+p);
     Grist[p].Type=(kk&7) ? OpCon : OpVar;
     Grist[p].Value=(kk&7)? Ac(kk) : Av(kk);
     Grist[p+1].Type=PartOf;
/* If it is a constant in this position it will be something invoked. */
/* Take the chance to note externals. */
     if(Grist[p].Type==OpCon && Pcodes[Op].Has.Extra!=XtraSymbol){
       int j=Grist[p].Value;
/* As soon as we set Callee flag we reuse the Label field. */
       if(!Consp[j].v.f.Callee)
         if(Consp[j].Label<2) Consp[j].v.f.External=true;
       Consp[j].v.f.Callee=true;
/* We don't need to keep the Call and Invoke because characteristics of the
target will imply those. */
       if(strcmp(Pcodes[Op].Op,"Call")==0){
/* It would be nice if we had Delta determined since that would tell number
of arguments but we don't */
         Consp[j].v.f.Called=true;
         Grist[p-1].Type=PartOf;
         Freq[Op]--;
       }
       else{
         /* Here the number of arguments is explicit. */
         ArgsOf(j,Grist[p-1].Value);
         Consp[j].v.f.Invoked=true;
         Grist[p-1].Type=PartOf;
         Grist[p-2].Type=PartOf;
         Freq[Op]--;
       }
     }
     p+=2;
   }
      if(p==0)
	  throw 10;
   if(Pcodes[Op].Has.Jump){
     if(VoidJump==false){
       kk=*(Ushort *)(Codep+p);
       Grist[p].Type=Jump;
       Grist[p].Value=kk;
       Grist[p+1].Type=PartOf;
/* Also must set target as a branch-in point. */
       if(kk>=CodeLen)
		       throw 10;
       Grist[kk].From=kk-p;
/* In some cases the branch is by reason of leaving an iterative loop.
  We need to track the boundaries of loops since they need temporaries. */
	      if(Op>=Dim(Pcodes))
	        throw 10;  
       if(LoopStart(Op)){
         if(strcmp(Pcodes[Op].Op,"ControlVar")){
           Grist[p].DoDelta = Dod;
         }
         Grist[kk-1].DoDelta=DoEndsAt;
         DoEndsAt=kk-1;
/* Is this a worthwhile check? */
         if(strncmp(Pcodes[Codep[kk-1]>>1].Op,"Iter",4))
		       	 throw 10;
       }
       p+=2;
     }
     else{
/* At this point we have Bool followed by comparison and have avoided putting
out a jump target.  However, the prefered representation is to avoid Bool and
represent it by a relative jump of zero. */
/* Move comparison back. */
       Grist[p-2].Type=Grist[p-1].Type;
       Grist[p-2].Value=Grist[p-1].Value;
/* Put in unchangeable zero. */
       Grist[p-1].Type=Number;
       Grist[p-1].Value=0;
     }
     VoidJump=false;
   } /* Jump */
   if(Pcodes[Op].Has.Extra==XtraNum){
     Grist[p].Type=Number;
     Grist[p].Value=k;
     p++;
   }
   if(Pcodes[Op].Has.Extra==XtraSymbol){
     kk=*(Ushort *)(Codep+p);
     Grist[p].Type=(kk&7) ? OpCon : OpVar;
     Grist[p].Value=(kk&7)? Ac(kk) : Av(kk);
     Grist[p+1].Type=PartOf;
     p+=2;
   }
   if(Pcodes[Op].Has.Extra==XtraJump){
     kk=*(Ushort *)(Codep+p);
     Grist[p].Type=Jump;
     Grist[p].Value=kk;
     Grist[p+1].Type=PartOf;
     Grist[kk].From=kk-p;
     p+=2;
   }
   Freq[Op]++;
 } /* p */
 Grist[q].OpLen=p-q;
 for(p=sizeof SegHeader;p<CodeLen;p++){
   Grist[p].ValueWas=Grist[p].Value;
 }
} /* PcodeToGrist */

void SetDelta(void){ // Tracking the Bcode stack.
 Ushort v; Uchar DoTotal;
 DoTotal=0;
 for(int p=sizeof SegHeader;p<CodeLen;p++){
   Grist[p].Delta=DeltaNow;
   DoTotal+=Grist[p].DoDelta;
   DeltaNow+=Grist[p].DoDelta;
   MaxDelta=Max(MaxDelta,DeltaNow);
   v=Grist[p].Value;
   switch(Grist[p].Type){
   case PartOf:
   case Jump:
     break;
   case Number:
     if(WithinParse){
       if(Grist[p].Value==mParseEnd){
         DeltaNow--;
         WithinParse=false;
       }
     }
     break;
   case Con:
   case Arg:
     if(!WithinParse) DeltaNow++;
     break;
   case Var:
     if(!WithinParse) DeltaNow++;
     break;
   case OpVar:
     break;
   case OpCon:
     /* Must be a CALL if args unknown. */
     if(!Consp[v].v.f.ArgsSet) ArgsOf(v,DeltaNow);
/* On external calls the number of arguments can be inconsistent if the
 callee knows what to expect. */
     if(Consp[v].v.f.Invoked)
       DeltaNow-=Varsp[v].ArgUse-1;
     else DeltaNow=DoTotal;
     break;
   case OpCode:
     DeltaNow-=Pcodes[v].Has.Down;
/* If the Op is one with a jump, and the jump amount is special, this is
Boolean compare and keeps a stack item. */
/* Oct 99 added zero check. How did this used to work? */
     if(Pcodes[v].Has.Jump && Grist[p+1].Type==Number
        && Grist[p+1].Value==0) DeltaNow++;
     if(strcmp(Pcodes[v].Op,"Bifq")==0){
     /* We are not changing the bif value but we need to know how
     many arguments the bif will prune from the stack. */
     /* MIN and MAX bifs are done individually. */
     /* Group ones not used by Bcode, hopefully. */
     /* Separate */
       Ushort BifNum, XtraArgs, Args;
       BifNum = Grist[p+1].Value & 126;
       XtraArgs = Grist[p+1].Value - BifNum;
       BifNum = BifNum/2;
       if(XtraArgs==1) XtraArgs=2;
       else if(XtraArgs==128) XtraArgs=1;
       else if(XtraArgs==129) XtraArgs=3;
       Args = Bifs[BifNum].MinArgs + XtraArgs;
       DeltaNow -= (Args-1);
     }
     /* Special cases because parsee is on stack throughout PARSE */
     if(strcmp(Pcodes[v].Op,"Parse")==0){
       WithinParse=true;
     }
     if(strcmp(Pcodes[v].Op,"Min")==0){
       DeltaNow-=Grist[p+1].Value;
     }
     if(strcmp(Pcodes[v].Op,"Max")==0){
       DeltaNow-=Grist[p+1].Value;
     }
     break;
   default:throw 9;
   } /* Switch */
 } /* p */
 return;
} // SetDelta
