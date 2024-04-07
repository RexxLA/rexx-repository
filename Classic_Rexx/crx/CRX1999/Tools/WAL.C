/*------------------------------------------------------------------------------
 Wallet.c 920606 Separate compilation
õ-----------------------------------------------------------------------------*/
#include "always.h"
/* Here we include the headers for clusters being used (imported). */
/* Order may be important. */
/* A compile time variable Extern allows the same cluster heading to be
used as declaration in one compiland and definition in another. */
/* Here we include the headers for clusters being used (imported). */
/* Order may be important. */
#define Extern 1
#define Storage extern
#include "main.h"
/* Here the header for what is being implemented. (exported) */
#undef Extern
#define Extern 0
#undef Storage
#define Storage
#include "wal.h"
/*------------------------------------------------------------------------------
 The Wallet cluster supports variable dimension arrays.
õ-----------------------------------------------------------------------------*/

static char * MsgWal[6]={
/* 0*/ "\nWallets: Unable to open the spill file ",
/* 1*/ "\nWallets: Error when writing to the spill file ",
/* 2*/ "\nWallets: WalletSpill not large enough. ",
/* 3*/ "\nWallets: Insufficient memory. ",
/* 4*/ "\nWallets: Out of range Wallet number. ",
/* 5*/ "\nWallets: Wallet exceeds segment size. ",
  };
static void WalletPurge(Wallet * w);/* No need for user to call this directly.*/

void * WalletEx(void * ww){
 Ushort u;size_t t;Wallet * v,* w;
 long uu;
 w=(Wallet *)ww;
/* Cannot check excessive w->Needs since it will have overflowed. */
/* We could do shortening here, but we don't since user may be calling
WalletEx all the time, trading speed for neater code. */
 if(w->Needs <= (u=w->Has)){
   if(w->Exact) {
     w->Has=w->Needs;
/* Assume it can't fail when shortening. */
     w=realloc((void *)w,sizeof(Wallet)+w->Has*w->Stride);
   }
   return w;
 }
 if(w->Exact) w->Has=w->Needs;
 else{
/* There is no perfect algorithm to compromise between wasted space and
frequent extending. */
   uu=(long)w->Needs;
   uu=(uu>>2)+uu+1;
   w->Has=(Ushort)uu;
   /* At least for 32 bit, we can do big allocations. */
   /* Presumably the realloc will fail in 16 bit. */
#if 0
   uu=sizeof(Wallet)+uu*w->Stride;
   if(uu>USHRT_MAX) {
     uu=(USHRT_MAX-sizeof(Wallet)-16)/w->Stride;
     if(uu<(long)(w->Needs))
       {printf(MsgWal[5]);longjmp(ErrSig,1);}
     w->Has=(Ushort)uu; /* Maximum possible. */
   }
#endif
 }
 v=realloc((void *)w,(t=sizeof(Wallet)+w->Has*w->Stride));
 if(v==NULL){
#if 0
   WalletPurge(w);/* Spill all but this one. */
   v=realloc((void *)w,t);
#endif
   if(v==NULL){printf(MsgWal[3]);longjmp(ErrSig,1);}
 }
 w=v;
 if(w->Clear){
   memset((char*)(w)+sizeof(Wallet)+u*w->Stride,'\0',(w->Has-u)*w->Stride);
 }
 return w;
} /* WalletEx */
/* Only the routine above is needed if we are not using compact numbering
and spilling. */
long WalletSpill;
static long WalletAccum;
static Ushort WalletAnchor;
static char * WalletFile = "WALLETœœ.TMP";
static FILE * WalletStream;
static fpos_t FPos;
void * WalletMalloc(size_t s){
  char * p;
  p=malloc(s);
  if(p==NULL){
    WalletPurge(NULL);p=malloc(s);
    if(p==NULL){printf(MsgWal[3]);longjmp(ErrSig,1);}
  }
  return p;
}
void * WalletCalloc(size_t n,size_t s){
  char * p;
  p=calloc(n,s);
  if(p==NULL){
    WalletPurge(NULL);p=calloc(n,s);
    if(p==NULL){printf(MsgWal[3]);longjmp(ErrSig,1);}
  }
  return p;
}
Ushort WalletNew(Uchar s){
   Ushort n;Wallet *p;
/* This may be the first use of any numbered wallet. */
   if(Wallets==NULL){
   if((Wallets=calloc(1,sizeof(Wallet)))==NULL)
              {printf(MsgWal[3]);longjmp(ErrSig,1);}
     Wallets->w.Stride=sizeof(Wallets->e[1]);
     Wallets->w.Clear=1;
     Wallets->w.Needs=1;/* Zero'th element is not used. */
   }
   p=WalletCalloc(1,sizeof(Wallet));
   p->Stride=s;
   if(WalletAnchor){/* Use previously deleted. */
     n=WalletAnchor;WalletAnchor=Wallets->e[n].u.Chain;
   }
   else{
     n=(Wallets->w.Needs)++;
     WalletCheck(Wallets);
   }
   Wallets->e[n].p=p;
   Wallets->e[n].Altered=Yes;
   return n;
  } /* WalletNew */
void WalletDel(Ushort n){
/* Range check, curb runaway bugs */
    if(n==0 || Wallets->w.Needs<n){
       printf(MsgWal[4]);longjmp(ErrSig,1);
    }
    free(Wallets->e[n].p);
    Wallets->e[n].p=NULL;
    /* Reusing the number. */
    Wallets->e[n].u.Chain=WalletAnchor;
    WalletAnchor=n;
  }
static void WalletPurge(Wallet * w){
/* There are no half measures - almost everything is written away and deleted
 from main memory.  This avoids fragmentation. */
 Ushort j;Wallet * p;Ushort s;
 for(j=0;j<Wallets->w.Needs;j++){
   p=Wallets->e[j].p;
/* If p is NULL this is something currently paged out. */
/* If p=w this is the one we want kept in. */
   if(p==NULL || p==w) continue;
   if(Wallets->e[j].Altered){
/* This one to be written out. Check spilling, open file if necessary. */
     s=sizeof(Wallet) + p->Needs * p->Stride;
     if(WalletAccum+s>WalletSpill){printf(MsgWal[2]);longjmp(ErrSig,1);}
/* Nothing coded yet about squeezing space from disk file.  */
     WalletAccum+=s;
     if(WalletStream==NULL)
       if((WalletStream=fopen(WalletFile,"w+b"))==NULL){
         printf(MsgWal[0]);longjmp(ErrSig,1);
       }
/* Write to file the used part. */
     fgetpos(WalletStream,&FPos);/* This where it will be. */
     Wallets->e[j].u.f=FPos;
     if(s!=fwrite(p,1,s,WalletStream)){
       printf(MsgWal[1]);longjmp(ErrSig,1);
     }
   }
/* Delete the copy from memory. */
   Wallets->e[j].p=NULL;free(p);
 }
}
void WalletGet(Ushort n){
 Wallet t;size_t s;
    Wallet * p;
/* Range check, curb runaway bugs */
    if(n==0 || Wallets->w.Needs<n){
       printf(MsgWal[4]);longjmp(ErrSig,1);
    }
/* It may be already in memory. */
    if((p=Wallets->e[n].p)!=NULL) return;
/* Read just the wallet. */
    FPos=Wallets->e[n].u.f;
    fsetpos(WalletStream,&FPos);
    fread(&t,sizeof(Wallet),1,WalletStream);
/* Now we can access the size. */
    s=sizeof(Wallet)+t.Needs*t.Stride;
    p=WalletMalloc(s);
/* Now can read the whole thing. */
    fsetpos(WalletStream,&FPos);
    fread(p,1,s,WalletStream);
    Wallets->e[n].Altered=Yes;
  Wallets->e[n].p=p;
  WalletTemp=p;
} /* WalletGet */
  void WalletSize(Ushort n){
    Wallet * p;
    if(Wallets->w.Needs<n){printf(MsgWal[4]);longjmp(ErrSig,1);}
    p=Wallets->e[n].p;
    WalletCheck(p);
    Wallets->e[n].p=p;
  } /* WalletSize */
/*------------------------------------------------------------------------------
The Walks cluster supports build and walk of binary trees.
õ-----------------------------------------------------------------------------*/
Offset LookUp(void)
{
  Offset Look; /* Flits over tree. */
  Offset LowHeld, HighHeld; /* Offsets of subtrees temporarily disjoint. */
  int t;
/* During the following loop, Look locates a tree that may contain the
searched for value, eventually going to zero if the value is not found
anywhere. */
  Look=WHWB->Root;

/* LowHeld and HighHeld are the offsets of slots (with the slots themselves
containing offsets) which are currently trash. Those slots are filled in by the
subsequent iteration. */
  LowHeld=Offsetof(WalkHead,LowHeld);
  HighHeld=Offsetof(WalkHead,HighHeld);

/* In parallel with searching, the tree is being re-arranged to make the
found (or new) item the root.  This has good performance chacteristics
when references to the same thing are clustered. */
  while (Look) {
    if ((t=(WHWB->IsIt)(Look))<0){
/* We want the next probe to be at a higher place, so must set Look from Higher.
At the same time the tree-rewriting info must be maintained.  */

/* LowHeld is set to locate a slot in an item where we followed the 'higher'
locator.  We are stepping on even higher, so we can refill that slot
(with an offset to where we are now probed) knowing that there is no
risk that slot contained an offset to the thing we are looking for. */
      *(Offset*)(WalkBase + LowHeld)=Look;   /* Complete prior iteration */
      LowHeld=Look+Offsetof(WalkNode,Higher);/* Note slot to pick up now */
      Look=*(Offset*)(WalkBase + LowHeld);   /* Pick up */
    }
    else
      if (t>0) {
/* This section by symmetry. */
        *(Offset*)(WalkBase + HighHeld)=Look;
        HighHeld=Look+Offsetof(WalkNode,Lower);
        Look=*(Offset*)(WalkBase + HighHeld);
      }
      else {
/* Firstly complete each of the two subtrees we have been making, one
containing items lower than the probe and one containing higher values. */

        *(Offset*)(WalkBase+LowHeld)=
             *(Offset*)(WalkBase+Look+Offsetof(WalkNode,Lower));
        *(Offset*)(WalkBase+HighHeld)=
             *(Offset*)(WalkBase+Look+Offsetof(WalkNode,Higher));
/* Join those subtrees, making everything one tree rooted at Look. */
        *(Offset*)(WalkBase+Look+Offsetof(WalkNode,Lower))=
                 WHWB->LowHeld;
        *(Offset*)(WalkBase+Look+Offsetof(WalkNode,Higher))=
                 WHWB->HighHeld;
        WHWB->Root=Look;
        return Look;
      }
  }                                    /* while */

/* Complete the two isolated trees. */
  *(Offset*)(WalkBase+LowHeld)=0;
  *(Offset*)(WalkBase+HighHeld)=0;

/* Make a new item. */
  Look=(WHWB->MakeIt)();

/* Join the subtrees, making everything one tree rooted at Lookp. */

  *(Offset*)(WalkBase+Look+Offsetof(WalkNode,Lower))=
        WHWB->LowHeld;
  *(Offset*)(WalkBase+Look+Offsetof(WalkNode,Higher))=
        WHWB->HighHeld;
  WHWB->Root=Look;
  return Look;
}                                      /* LookUp */
/*------------------------------------------------------------------------------
Walk the tree.
õ-----------------------------------------------------------------------------*/
static void Walk2(Offset n,void(*f)(Offset)){
  if(n==0) return; /* Nothing down this limb. */
/* Do smaller values first. */
  Walk2(*(Offset*)(WalkBase+n+Offsetof(WalkNode,Lower)),f);
/* Call f from this one. */
  (*f)(n);
/* Do larger values last. */
  Walk2(*(Offset*)(WalkBase+n+Offsetof(WalkNode,Higher)),f);
} /* Walk2 */

void Walk(void(*f)(Offset)){
/* Pick up the root and pass on to Walk2 */
  Walk2(WHWB->Root,f);
} /* Walk */
