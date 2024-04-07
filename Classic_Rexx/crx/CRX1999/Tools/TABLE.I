/*------------------------------------------------------------------------------
 Macro-style for Table.
 Copy Table.d which 'include's this.
õ-----------------------------------------------------------------------------*/
/* The array must have Lower and Higher fields of type pointer to element. */
/* Array[0] is reserved, Array[0].Lower roots the tree. */
/* IsIt returns int result of comparison result. (Ptr arguments) */
/* MakeIt returns address of added element.
/*------------------------------------------------------------------------------
Table does tree lookup on an array. The transient use of the Lower/Higher
fields in an array element requires that they be pointers (as opposed to
indices).  That means the array must be updated if relocated.
õ-----------------------------------------------------------------------------*/
static Tablep Table(void)
{
  Tablep Look; /* Flits over tree. */
 /* Pointers of subtrees temporarily  disjoint. */
  Tablep *LowHeld;
  Tablep *HighHeld;
   int t;

/* During the following loop, Look locates a tree that may contain the
searched for value, eventually going to zero if the value is not found
anywhere. */
  Look=Array[0].Lower; /* Root */

/* LowHeld and HighHeld are the addresses of slots (with the slots themselves
containing ptrs) which are currently trash. Those slots are filled in by
the subsequent iteration. */
  LowHeld=&(Array[0].Lower);
  HighHeld=&(Array[0].Higher);

/* In parallel with searching, the tree is being re-arranged to make the
found (or new) item the root.  This has good performance chacteristics
when references to the same thing are clustered. */
  while (Look) {
    if ((t=IsIt(Look))<0){
/* We want the next probe to be at a higher place, so must set Look from Higher.
At the same time the tree-rewriting info must be maintained.  */

/* LowHeld is set to locate a slot in an item where we followed the 'higher'
locator.  We are stepping on even higher, so we can refill that slot
(with an index to where we are now probed) knowing that there is no
risk that slot contained an index to the thing we are looking for. */
      *LowHeld=Look;   /* Complete prior iteration */
      LowHeld=&(Look->Higher);/* Note slot to pick up now & fill later. */
      Look=*LowHeld;   /* Pick up */
    }
    else
      if (t>0) {
/* This section by symmetry. */
        *HighHeld=Look;   /* Complete prior iteration */
        HighHeld=&(Look->Lower);/* Note slot to pick up now */
        Look=*HighHeld;   /* Pick up */
      }
      else {
/* Firstly complete each of the two subtrees we have been making, one
containing items lower than the probe and one containing higher values. */
        *LowHeld=Look->Lower;
        *HighHeld=Look->Higher;

/* Join those subtrees, making everything one tree rooted at Look. */
        goto LookJoin;
      }
  }                                    /* while */

/* Complete the two isolated trees. */
  *LowHeld=NULL;
  *HighHeld=NULL;

/* Make a new item. */
  Look=MakeIt();

/* Join the subtrees, making everything one tree rooted at Look. */
LookJoin:
  Look->Lower=Array[0].Lower;
  Look->Higher=Array[0].Higher;
  Array[0].Lower=Look; /* Root */
  return Look;
}                                      /* LookUp */
