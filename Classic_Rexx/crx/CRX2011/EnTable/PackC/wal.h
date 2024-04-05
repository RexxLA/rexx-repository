/*------------------------------------------------------------------------------
 wal.h  920605
õ-----------------------------------------------------------------------------*/
/* The Wallet cluster is to support arrays of variable dimension. */
/* The Walks cluster is to build and walk binary trees. */

/* An empty wallet is by calloc.  It is allocated by the user of the WAL
cluster.  The user should then set Stride and optionally Clear.  */
/* How to declare: Put a wallet named w ahead of the array, eg
  struct{Wallet w;MyType My[1];} *MyWallet;
   To initialize,
  MyWallet=calloc(1,sizeof(Wallet));MyWallet->w.Stride=sizeof(MyType);
   To resize (initially there are no elements):
  MyWallet->w.Needs=99;MyWallet=WalletEx(MyWallet);
   To access, remember C has zero indexing.
  MyWallet->My(98)=whatever;
*/

 typedef struct{
  Ushort Has; /* Number of array slots allocated. */
  Ushort Needs; /* Number of array slots needed. */
  unsigned Clear:1; /* If new space to be zeroed. */
  unsigned Exact:1; /* If to be cut to exact size. */
  unsigned Fix:14; /* Can't get C600 to do a byte so best make explicit */
  Uchar Stride; /* Number of bytes to a unit of Needs. */
 } Wallet;

/* It is expanded by the user setting Needs > Has and calling WalletEx, which
does a realloc and returns a pointer to the expanded wallet.  The slot content
is up to the user but will be initialized zero if Clear is set.  Need will not
be changed, Has will be made at least as big.  */

/* It is not a good idea to have more than one pointer to a Wallet as there
is a risk one will get updated but not the other. */
void * WalletEx(void *);

/*------------------------------------------------------------------------------
The wallet scheme above is extended by giving the wallets a compact
numbering.  MyNum=WalletNew(Uchar StrideMyType) obtains a not-in-use number
(greater than zero)
suitable for accessing a wallet of MyTypes (declared as previous example).
MyWallet=Walletp(MyNum) obtains a pointer addressing (transiently) the
MyNum'th wallet. (Clear and Exact flags can be set this way. There is no need
to set Stride since WalletNew does.) WalletSize(MyNum) will use Needs in the
wallet and make sure of appropriate space. (WalletSize must be used instead
of WalletEx for a numbered wallet.)

The pointer obtained is good until the next use of that MyNum value, except
if there is spilling to disk. Spilling is specified by setting WalletSpill
to the maximum number of bytes of disk file available for spilling. A zero
value specifies no spilling. If spilling is specified, the pointer from
Walletp is only good until the next use of any wallet number.

For better performance with spilling, there is also Walletr which gives
a read-only pointer.

When spilling is used, all allocation should be done with WalletMalloc
or WalletCalloc which are like their system counterparts but may spill
to make room. (And give a message instead of returning NULL)
õ-----------------------------------------------------------------------------*/
  Storage long WalletSpill;
  Storage Wallet * WalletTemp;
  Storage Ushort WalletNew(Uchar);
  void WalletDel(Ushort);
  void WalletSize(Ushort);
  void WalletGet(Ushort);
  void * WalletMalloc(size_t);
  void * WalletCalloc(size_t,size_t);
/* The index to wallets is itself a wallet. */
Storage struct{
  Wallet w;
  struct{
    Wallet * p; /* Address in memory. */
    unsigned Altered;
    union{
    fpos_t f; /* Position on file. */
    Ushort Chain;
    }u;
  } e[1];
} * Wallets;
#if 0
/* This has never been tested and I'm not sure it works. Does WalletTemp
get the result of comparison? */
#define Walletp(x) ((WalletTemp=Wallets->e[x].p)?WalletTemp;\
(Wallets->e[x].Altered=1,WalletGet(x)))
#define Walletr(x) ((WalletTemp=Wallets->e[x].p)?WalletTemp;WalletGet(x))
#endif
/* Changed to this for now. Can't find any uses of WalletTemp. */
#define Walletp(x) (Wallets->e[x].p)
#define Walletr(x) (Wallets->e[x].p)

/*------------------------------------------------------------------------------
If there is plenty of address space, the code for handling trees turns out
neatly using pointers.  However, that clashes with having the tree nodes in a
wallet since the pointers from node to node would be obsoleted by moving the
whole wallet of nodes.  So in this variation we use offsets instead of pointers.
õ-----------------------------------------------------------------------------*/

/* Each node in a tree starts with two offsets. */
 typedef struct WalkNode{
  Offset Lower;  /* Offset of tree with lower valued nodes. */
  Offset Higher; /* Offset of tree with higher valued nodes. */
 } WalkNode;
/*------------------------------------------------------------------------------
There is assumed to be a type (call it Node), declared elsewhere, overlaid and
starting with a WalkNode. The content beyond the WalkNode is whatever the user of
the WAL cluster wants.  Note that it need not be fixed length.

The tree is constructed by routine LookUp.  Each call to LookUp returns a
a node offset.  The node is such that IsIt(nodeoffset) returns True. If that
is not true for any existing node then MakeIt is called and MakeIt must return
a node offset such that IsIt(nodeoffset) is true.

IsIt() should return -1 for nodes that represent lower values than the value
being looked up, +1 for nodes that represent higher values than the one being
looked up.

All this arrangement allows the tree code to be separated from knowledge
of what is in the tree, but the separate compilations must share something -
a pointer which is the base for all the offsets used.

It is the responsibility of the user of the WAL cluster to maintain this pointer
and initialize the WalkHead space.

õ-----------------------------------------------------------------------------*/
typedef struct WalkHead{
  Wallet w;  /* In case we want this to be a wallet. Not used by LookUp.*/
  Offset Root;     /* Set zero initially */
  Offset LowHeld;  /* Set zero initially */
  Offset HighHeld;  /* Set zero initially */
  Offset (* MakeIt)(void);
  short (* IsIt)(Offset);
} WalkHead;

/* WalkBase is 'char *' not 'void *' so that WalkBase+n is an address. */
Storage char * volatile WalkBase; /* WalkHead *, and base for what follows
WalkHead. */
#define WHWB  ((WalkHead*)WalkBase)
Offset LookUp(void);
/*------------------------------------------------------------------------------
Walk does a walk of the tree, calling a given function for each node in
sorted order.
õ-----------------------------------------------------------------------------*/
void Walk(void(*f)(Offset));
/*------------------------------------------------------------------------------
Some declarations handy for Wal user, although not used by Wal itself.
õ-----------------------------------------------------------------------------*/
 typedef struct {
   Wallet w;
   short e[1]; /* Pity compiler won't take zero or null here */
 } Wshort;
/* A macro for fast check on a Wallet. */
#define WalletCheck(x) if(((Wallet*)(x))->Has<((Wallet*)(x))->Needs)\
  x=WalletEx((Wallet*)(x));
/* By always calling the wallet heading w and the elements in it e we can use
the following macro */
#define WalletInit(x) \
  x=calloc(1,sizeof(Wallet));if(x) x->w.Stride=sizeof(x->e[1])
/*------------------------------------------------------------------------------
 wal.h  920605
õ-----------------------------------------------------------------------------*/
/* The Wallet cluster is to support arrays of variable dimension. */
/* The Walks cluster is to build and walk binary trees. */

/* An empty wallet is by calloc.  It is allocated by the user of the WAL
cluster.  The user should then set Stride and optionally Clear.  */
/* How to declare: Put a wallet named w ahead of the array, eg
  struct{Wallet w;MyType My[1];} *MyWallet;
   To initialize,
  MyWallet=calloc(1,sizeof(Wallet));MyWallet->w.Stride=sizeof(MyType);
   To resize (initially there are no elements):
  MyWallet->w.Needs=99;MyWallet=WalletEx(MyWallet);
   To access, remember C has zero indexing.
  MyWallet->My(98)=whatever;
*/

 typedef struct{
  Ushort Has; /* Number of array slots allocated. */
  Ushort Needs; /* Number of array slots needed. */
  unsigned Clear:1; /* If new space to be zeroed. */
  unsigned Exact:1; /* If to be cut to exact size. */
  unsigned Fix:14; /* Can't get C600 to do a byte so best make explicit */
  Uchar Stride; /* Number of bytes to a unit of Needs. */
 } Wallet;

/* It is expanded by the user setting Needs > Has and calling WalletEx, which
does a realloc and returns a pointer to the expanded wallet.  The slot content
is up to the user but will be initialized zero if Clear is set.  Need will not
be changed, Has will be made at least as big.  */

/* It is not a good idea to have more than one pointer to a Wallet as there
is a risk one will get updated but not the other. */
void * WalletEx(void *);

/*------------------------------------------------------------------------------
The wallet scheme above is extended by giving the wallets a compact
numbering.  MyNum=WalletNew(Uchar StrideMyType) obtains a not-in-use number
(greater than zero)
suitable for accessing a wallet of MyTypes (declared as previous example).
MyWallet=Walletp(MyNum) obtains a pointer addressing (transiently) the
MyNum'th wallet. (Clear and Exact flags can be set this way. There is no need
to set Stride since WalletNew does.) WalletSize(MyNum) will use Needs in the
wallet and make sure of appropriate space. (WalletSize must be used instead
of WalletEx for a numbered wallet.)

The pointer obtained is good until the next use of that MyNum value, except
if there is spilling to disk. Spilling is specified by setting WalletSpill
to the maximum number of bytes of disk file available for spilling. A zero
value specifies no spilling. If spilling is specified, the pointer from
Walletp is only good until the next use of any wallet number.

For better performance with spilling, there is also Walletr which gives
a read-only pointer.

When spilling is used, all allocation should be done with WalletMalloc
or WalletCalloc which are like their system counterparts but may spill
to make room. (And give a message instead of returning NULL)
õ-----------------------------------------------------------------------------*/
  Storage long WalletSpill;
  Storage Wallet * WalletTemp;
  Storage Ushort WalletNew(Uchar);
  void WalletDel(Ushort);
  void WalletSize(Ushort);
  void WalletGet(Ushort);
  void * WalletMalloc(size_t);
  void * WalletCalloc(size_t,size_t);
/* The index to wallets is itself a wallet. */
Storage struct{
  Wallet w;
  struct{
    Wallet * p; /* Address in memory. */
    unsigned Altered;
    union{
    fpos_t f; /* Position on file. */
    Ushort Chain;
    }u;
  } e[1];
} * Wallets;
#if 0
/* This has never been tested and I'm not sure it works. Does WalletTemp
get the result of comparison? */
#define Walletp(x) ((WalletTemp=Wallets->e[x].p)?WalletTemp;\
(Wallets->e[x].Altered=1,WalletGet(x)))
#define Walletr(x) ((WalletTemp=Wallets->e[x].p)?WalletTemp;WalletGet(x))
#endif
/* Changed to this for now. Can't find any uses of WalletTemp. */
#define Walletp(x) (Wallets->e[x].p)
#define Walletr(x) (Wallets->e[x].p)

/*------------------------------------------------------------------------------
If there is plenty of address space, the code for handling trees turns out
neatly using pointers.  However, that clashes with having the tree nodes in a
wallet since the pointers from node to node would be obsoleted by moving the
whole wallet of nodes.  So in this variation we use offsets instead of pointers.
õ-----------------------------------------------------------------------------*/

/* Each node in a tree starts with two offsets. */
 typedef struct WalkNode{
  Offset Lower;  /* Offset of tree with lower valued nodes. */
  Offset Higher; /* Offset of tree with higher valued nodes. */
 } WalkNode;
/*------------------------------------------------------------------------------
There is assumed to be a type (call it Node), declared elsewhere, overlaid and
starting with a WalkNode. The content beyond the WalkNode is whatever the user of
the WAL cluster wants.  Note that it need not be fixed length.

The tree is constructed by routine LookUp.  Each call to LookUp returns a
a node offset.  The node is such that IsIt(nodeoffset) returns True. If that
is not true for any existing node then MakeIt is called and MakeIt must return
a node offset such that IsIt(nodeoffset) is true.

IsIt() should return -1 for nodes that represent lower values than the value
being looked up, +1 for nodes that represent higher values than the one being
looked up.

All this arrangement allows the tree code to be separated from knowledge
of what is in the tree, but the separate compilations must share something -
a pointer which is the base for all the offsets used.

It is the responsibility of the user of the WAL cluster to maintain this pointer
and initialize the WalkHead space.

õ-----------------------------------------------------------------------------*/
typedef struct WalkHead{
  Wallet w;  /* In case we want this to be a wallet. Not used by LookUp.*/
  Offset Root;     /* Set zero initially */
  Offset LowHeld;  /* Set zero initially */
  Offset HighHeld;  /* Set zero initially */
  Offset (* MakeIt)(void);
  short (* IsIt)(Offset);
} WalkHead;

/* WalkBase is 'char *' not 'void *' so that WalkBase+n is an address. */
Storage char * volatile WalkBase; /* WalkHead *, and base for what follows
WalkHead. */
#define WHWB  ((WalkHead*)WalkBase)
Offset LookUp(void);
/*------------------------------------------------------------------------------
Walk does a walk of the tree, calling a given function for each node in
sorted order.
õ-----------------------------------------------------------------------------*/
void Walk(void(*f)(Offset));
/*------------------------------------------------------------------------------
Some declarations handy for Wal user, although not used by Wal itself.
õ-----------------------------------------------------------------------------*/
 typedef struct {
   Wallet w;
   short e[1]; /* Pity compiler won't take zero or null here */
 } Wshort;
/* A macro for fast check on a Wallet. */
#define WalletCheck(x) if(((Wallet*)(x))->Has<((Wallet*)(x))->Needs)\
  x=WalletEx((Wallet*)(x));
/* By always calling the wallet heading w and the elements in it e we can use
the following macro */
#define WalletInit(x) \
  x=calloc(1,sizeof(Wallet));if(x) x->w.Stride=sizeof(x->e[1])
