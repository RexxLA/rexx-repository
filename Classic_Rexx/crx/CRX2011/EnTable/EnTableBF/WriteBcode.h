
Ushort Bcode(Ushort Scop,Ushort From,Ushort UpTo,Ushort Make){
/* This needs to be called with Make==0 to decide ByteOff and then with
Make==1 to make output.  (Otherwise forward branches would be a problem.) */
 Ushort dd,d,p,v,f,Op;
 f=0;
 BifPart=0;
/* If it is a scope with locals there needs to be stack reservation for them.*/
/* Changed to implying _Locals when non-fragment. */
 if(Scop!=USHRT_MAX){
   f+=1;if(Make){
     Separate();
     Out << Scp[Scop].LocalVars;
     Out << "*8+";
     Out << Scp[Scop].Args;
     FreqHex++;
   }
 }
 dd=Grist[From].Delta;  /* Should always be zero? Maybe not in fragment. */
 if(dd!=0 && Scop!=USHRT_MAX){
   throw 10;
 }
 Op=0;DeltaNow=0;
 for(p=From;p<UpTo;p++){
   DeltaNow+=Grist[p].DoDelta;
   if(Make && f!=Grist[p].ByteOff) throw 10;
   Grist[p].ByteOff=f;
   if(Grist[p].Type==PartOf) continue;
/* No separator if dw coming. */
   if(Make && !AssignTgt && !(LoopStart(Op) && Grist[p].Type==Jump))
     Separate();
   v=Grist[p].Value;
   d=Grist[p].Delta;
   if(d>100){
     throw 10;
   }
/* Usually a byte value to go on the output. */
   switch(Grist[p].Type){
   case Jump:
     if(Make){
/* Long jumps only when making DO loops */
       if(!LoopStart(Op)){
         Ushort Bug;
         Out << '+';
         Bug=Grist[p+v].ByteOff-f;
         if(Bug>255){
           throw 10;
         }
         Out << Grist[p+v].ByteOff-f;
       }
       else{
         Out << endl << " dw $+" << Grist[p+v].ByteOff-f << endl;
         Middle=false;
       }
       FreqJumps++;
     }
     f++;
     if(LoopStart(Op)) f++;
     break;
   case Number:
     if(Make){
       if(BifPart==0) {
         Out << '0' << hex << v << dec << 'h';
       }
       else{ /* Convert what follows $pBifq to symbolic. */
         Ushort BifNum, XtraArgs;
         BifNum = v & 126;
         XtraArgs = v - BifNum;
         BifNum = BifNum/2;
         Out << "2*$Bif" << Bifs[BifNum].f;
         if(XtraArgs){
           Out << '+'<< XtraArgs;
         }
         BifPart=0;
       }
       FreqHex++;
     }
     f++;
     break;
   case Arg:
   case Var:
   case OpVar:
/* Special case the dot of Parse. */
     if(v==ParseDot){
       if(Make){Out << "ParseDot";FreqVars++;}
       f++;
       break;
       }
     if(Make){
/* Since the top item of the soft stack has offet zero from StackDi, when we
make new space it has a range of zero to minus something offset from the new
StackDi. If we put that range in the Pcode it can't be tested with one compare
so we subtract one. Now an unsigned compare with the low bound does the test.
Hence locals are addressed -1,-2,-3,....  The price is a dynamic adjustment
in computing the address off StackDi.  When there are known to be temporaries on
the stack the testing problem doesn't arise so, in particular for assignment,
that adjustment by one can be made in the value in Pcode rather than
dynamically. The overall effect is that "gets" use the same value in Pcode as
"puts" (apart from the Tgt adjustment that denotes a "put") even though there is
one more on the stack when "puts" are done. */
       ShowVarHere(v);
       if(AssignTgt){
/* The Assign operator lowered Delta so we don't have to do it again here. */
         if(!Varsp[v].v.f.System)
           Out << "-Tgt";
         else
           Out << "+Tgts";
       }
       if(d){
         if(v >= Arg1 || !Varsp[v].v.f.System){
           Out << '-' << 2*d; /* Adjust to even at the last minute. */
         }
       }
       FreqVars++;
     }
     AssignTgt=false;
     f++;
     break;
   case Con:
   case OpCon:
     if(Consp[v].v.f.Scope || Consp[v].v.f.External){
       /* This is an invocation, whether or not target was part of the input. */
       if(Make){ShowConHere(v);FreqFtns++;}
       f++;
       break;
     }
/* Special case some numbers. */
     { Ushort k,x;
       k=Consp[v].Here;
       x=*(Symsp+k);
       if(x==0){
         if(Make){Out << "Null";/* Null string */ FreqCons++;}
         f++;break;
       }
       if(x==1){
         if(*(Symsp+k+1)=='0'){
           if(Make){Out << "Zero";FreqCons++;}
           f++;break;
         }
         if(*(Symsp+k+1)=='1'){
           if(Make){Out << "One";FreqCons++;}
           f++;break;
         }
       }
     } /* Specials left with break. */
     {
     /* Output for constant.  Constant will be immediate in the Bcode. */
     /* Starts with String or String1 or String2. Iff String then length
     byte next. */
     Uchar x;Ushort y,k;
/* Struggle here.  If string contains CrLf-like it will have to go in hex. */
     k=Consp[v].Here;
     x=*(Symsp+k);
     if(Consp[v].v.f.HexIt){
       if(Make){
         Out << "String";
         FreqCons++;
         Separate();
         Out << x;
         FreqCons++;
         Separate();
         for(y=0;y<x;y++){
           Out << '0' << hex << *(Symsp+k+y+1) << 'h';
           FreqCons++;
           if(y+1<x) Separate();
         }
       }
       f+=x+2;
     }
     else{
       if(Make){
/* If parts use Show separately they may wind up on different lines.*/
         string t = string(Symsp+k+1,x);
         t = '"' + t + '"';
#if 0
         t=malloc(x+3);
         w=t;*t++='"';
         for(y=0;y<x;y++){
           *t++=*(Symsp+k+y+1);
         }
         *t++='"';
         *t++=0;
#endif
         /* Save a byte if strings short, length included in code point. */
         if(x==1) Out << "String1";
         else if(x==2) Out << "String2";
         else {
           Out << "String";
           Separate();
           Out << x;
         }
         Separate();
         Out << t;
#if 0
         Out << w;
         free(w);
#endif
         FreqCons+=x+1+(x>2);
       }
       f+=x+1+(x>2);
     }
   }
   break;
   case Fragment:
     if(Make){
       Out << "Frag" << v;
       FreqFtns++;
     }
     f++;
     break;
   case OpCode:
     if(v>Dim(Pcodes)){
      throw 10;
     }
     if(strcmp(Pcodes[v].Op,"Bifq")==0) BifPart=1; /* Qualifies next Number */
     Op=v;
/* Assign doesn't do anything except qualify how the next variable
reference is made. */
     if(strcmp(Pcodes[v].Op,"Assign")==0){AssignTgt=true;continue;}
/* Call is redundant since argument that follows says it is a routine. */
     if(strcmp(Pcodes[v].Op,"Call")==0) continue;
/* Return needs to manage the stack. */
/* But we changed to pushed prune amount so no argument. */
     if(strcmp(Pcodes[v].Op,"Return")==0||strcmp(Pcodes[v].Op,"Returns")==0){
       if(Scop==USHRT_MAX) throw 10; /* Shouldn't happen in a fragment. */
       if(Make){
         short Prune;
         if(strcmp(Pcodes[v].Op,"Returns")==0)
           Out << "_RetB";
         else
           Out << "_RetBc";
         FreqOps++;
/* Prune one less for Returns to allow result thru. */
         Prune=Scp[Scop].LocalVars+Scp[Scop].Args+d;
         if(strcmp(Pcodes[v].Op,"Returns")==0 && (d-DeltaNow)!=1){
           cout << endl << d << ' ' << DeltaNow << endl;
           throw 10;
         }
         if(strcmp(Pcodes[v].Op,"Return")==0 && d!=DeltaNow) throw 10;
         if(strcmp(Pcodes[v].Op,"Returns")==0) Prune--;
       }
     }
     else {
       if(Make){
         if(v>=(BPcodesCeil>>1)){
          Out << '_';
/* See HereExists */
          if(v==HereExists) Out << "Exists";
          else Out << Pcodes[v].Op;
         }
         else{ Out << "$p" << Pcodes[v].Op;}
         FreqOps++;
       }
     }
     f++;
     break;
   default:
     Out << endl;
//     printf("\n%x %x %d",n,p,Grist[p].Type);
     throw 10;
   } /* Switch */
 } /* p */
/* Grist made bigger to make this safe. */
 Grist[p].ByteOff=f;/* In case branched to? */
 return f;
} /* Bcode */