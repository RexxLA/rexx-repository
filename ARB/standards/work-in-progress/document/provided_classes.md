# Provided classes

(Informative)

## Notation

The provided classes are defined mainly through code.
## The Collection Classes

### Collection Class Routines

These routines are used in the definition of the collection classes

```rexx
::routine CommonxXor
/* Returns a new collection that contains all items from self and
the argument except that all indexes that appear in both collections
are removed. */
/* When the target is a bag, there may be an index in the bag that is
duplicated and the same value as an index in the argument. Should one
copy of the index survive in the bag? */
 v=1
 if (arg(1)~class==.Set & arg(2)~class==.Bag) then v=2
 if (arg(1)~class==.Table & arg(2)~class==.Bag) then v=2
 if (arg(1)~class==.Table & arg(2)~class==.Relation) then v=2
 if (arg(1)~class==.Directory & arg(2)~class==.Bag) then v=2
 if (arg(1)~class==.Directory & arg(2)~class==.Relation) then v=2
/* This version it does: */
 if v=1 then do
  This = arg(1) /* self of caller */
  r=This~class~new
  ab=MayEnBag (arg (2) )
  ss=This~supplier
  do while ss~available
    r[ss~index] =ss~item
    ss~next
    end
  cs=ab~supplier
  do while cs~available
    if r~hasindex(cs~index) then r~remove (cs~index)
                            else r[cs~index] =cs~item
    cs~next
    end
  return r
  end

/* But following matches practice on Set~XOR(bag) etc. */
 This = arg(1) /* self of caller */
 r=This~class~new
 ab=MayEnBag (arg (2) )
 ss=This~supplier
 do while ss~available
   if \ab~hasindex(ss~index) then r[ss~index] =ss~item
   ss~next
   end
 cs=ab~supplier
 do while cs~available
   if \This~hasindex(cs~index) then r[cs~index] =cs~item
   cs-next
   end
 return r

::routine CommonIntersect
/* Returns a new collection of the same class as SELF that
contains the items from SELF that have indexes also in the
argument. */
/* Actually an index in SELF can only be 'matched' with one in the
argument once. Hence copy and removal. */
  This = arg(1) /* self of caller */
  w= .Bag~new
  sc=This~supplier
 do while sc~available
   w[sc~index] =sc~index
   sc-next
   end
 r=This~class~new
 cs=MayEnBag(arg(2))~supplier
 do while cs~available
   i=cs~index
   if w~hasindex(i) then do
     r[i]=This[i]
     w~remove(i)
     end
   cs~next
   end
 return r

::routine CommonUnion
/* Returns a new collection of the same class as SELF that
contains all the items from SELF and items from the
argument that have an index not in the first. */
/* Best to add them all. By adding non-receiver first we ensure that
receiver takes priority when same indexes. */
  This = arg(1) /* self of caller */
  r=This~class~new
  cs=MayEnBag(arg(2))~supplier
  do while cs~available
    r[cs~index] =cs~item
    cs~next
    end
  cs=This~supplier
  do while cs~available
    r[cs~index] =cs~item
    cs~next
    end
  return r

::routine CommonDifference
/* Returns a new collection containing only those index-item pairs from the
 SELF whose indexes the other collection does not contain. */
  This = arg(1) /* self of caller */
  r=This~class~new
  cs=This~supplier
  do while cs~available
    r[cs~index] =cs~item
    es-next
    end
  cs=MayEnBag(arg(2))~supplier
  do while cs~available
    r~remove(cs~index)
    cs~next
    end
  return r

::routine MayEnBag
/* For List and Queue the indexes are dropped. */
  r~arg(1)
  if r-clags == .List | r-class == .Queue then r=EnBag(r)
  return r

::routine EnBag
  r=.Bag~new
  s=arg(1)~supplier
  do while s~available
    if arg(1)~class == .List | arg(1)~class == .Queue then
      r[s~item] =s~item
    else
/* This case is when the receiver is a Bag. */
      r[s~index] =s~index
    s~next
  end
return r
```

### The collection class

```rexx
::class 'Collection'
```

#### INIT

```rexx
::method init
  expose a
/* A collection is modelled as using 3 slots in an array for each element.
The first slot holds the item, the second the index, and the third is
used by particular types of collection. This order of slots is arbitary,
chosen to match order of arguments for PUT and SUPPLIER~NEW. */
/* The first set of 3 slots is reserved for other purposes, to avoid
having separate variables which the subclassing would need to access. */
a=.array~new
a[1] /*ItemsCount*/=0
a[2]/*Unique*/=0
return self
```

#### EXPOSED

```rexx
::method exposed private
  expose a
/* This method allows subclasses to get at the implementation of Collection. */
  return a
```

#### FINDINDEX

```rexx
::method findindex private
  expose a
/* Returns array index if the collection contains any item associated with the
index specified or returns 0 otherwise. */
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    if alj+l]==arg(1) then return j
    end j
  return 0
```

#### AT

```rexx
::method at            /* rANY */
  expose a
/* Returns the item associated with the specified index. */
  j=self~findindex(arg(1))
  if j=0 then return .nil
  return a[j]
```

#### []

```rexx
::method '[]'
/* Synonym for the AT method. */
  forward message 'AT'
```

#### PUT

```rexx
::method put /* rANY rANy */
  expose a
  use arg item, index
/* Replaces any existing item associated with the specified index with the new
item. Otherwise adds the item-index pair. */
  j=self~findindex(index)
  if j>0 then do
    a[j]=item
    return
    end
  a[1]/*ItemsCount*/=a[1] /*ItemsCount*/+1
  j=1+3*a[1]/*ItemsCount*/
  a[j]=item
  a[j+1]=index
  a[j+2]=0
  return /* Error 91 in OOI if context requiring result. */
```

#### []=

```rexx
::method '[]='
/* Synonym for the PUT method. */
  forward message 'PUT'
```

#### HASINDEX

```rexx
::method hasindex      /* rANY */
/* Returns 1 (true) if the collection contains any item associated with the
index specified or returns 0 (false) otherwise. */
return self~findindex(arg(1))>0
```

#### ITEMS

```rexx
::method items
  expose a
/* Returns the number of items in the collection. */
  return a[1]/*ItemsCount*/
```

#### REMOVE

```rexx
::method remove       /* rANY */
  expose a
/* Returns and removes from a collection the member item with the specified
index. */
  j=self~findindex(arg(1))
  if j=0 then return .nil
  r=a[j]
  self~removeit(j)
  return r
```

#### REMOVEIT

```rexx
::method removeit private
  expose a
  use arg j
  /* Remove relevant slots from the array, with compaction. */
  do j=j+3 by 3 to 1+3*a[1]/*ItemsCount*/
    a[j-3]=a[j];a[j-2]=a[j+1];a[j]=a[j+2]
    end j
  a[1]/*ItemsCount*/=a[1]/*ItemsCount*/-1
  return
```

#### MAKEARRAY

```rexx
::method makearray
  expose a
/* Returns a single-index array containing the receiver list items. */
  r= .array~new        /* To build result in. */
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    r[r~dimension(1)+1]=a[j]
    end j
  return r
```

#### MAKEARRAYX

```rexx
::method makearrayx private
  expose a
/* Returns a single-index array containing the receiver index items. */
  r= .array~new        /* To build result in. */
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    r[r~dimension(1)+1]=a[j+1]
    end j
  return r
```

#### SUPPLIER

```rexx
::method supplier
  expose a
/* Returns a supplier object for the list. */
  return .supplier~new(self~makearray:.collection, self~makearrayx)
```

### Class list

```rexx
::class 'List' subclass Collection
```

#### PUT

```rexx
::method put          /* rANY rANY */
  use arg item, index
  a=self~exposed
/* PUT for a List must not be an insertion. */
  j=self~findindex (index)
  if j=0 then call Raise 'Syntax',93.918
  alj]=item
  return
```

#### OF

```rexx
::method of class     /* 1 or more oANY  Are they omittable? Not in IOO */
/* Returns a newly created list containing the specified value objects in the
order specified. */
   r= self ~ new
   do j = 1 to arg()
     r ~ insert (arg(j))
     end j
   return r
```

#### INSERT

```rexx
::method insert      /* rANY oANY */
  use arg item, index
  a=self~exposed
/* Returns a list-supplied index for a new item, of specified value, which is
added to the list. The new item follows the existing item with the specified
index in the list ordering. */
/* Establish the index of what preceeds the new element. */
/* If there was no index given, the new item becomes the last on list. */
/* .nil argument means first */
  if arg(2,'E') then p=arg(2)
                else p=self~last
/* Convert from list index to underlying array index. */
  if p==.nil then j=1
             else j=self~findindex(p)
  if j=0 then call Raise 'Syntax',93.918
  j=j+3 /* Where new entry will be. */
/* Move space to required place. */
  a[1]/*ItemsCount*/=a[1]/*ItemsCount*/+1
  do k=1+3*a[1]/*ItemsCount*/ by -3 to j+3
    a[k]=a[k-3];a[k+1]=a[k-2];a[k]=a[k-3]
    end
/* Insert new element. */
  a[j]=item
/* A new, unique, index is needed. */
/* The basic requirement is for something unique, so this would be correct:
   i=.object~new /* a unique object, used as a key (the index on the list) */
*/
/* However, a number can be used. (At risk of the user thinking it is
sensible to do arithmetic on it.) */
  a[j+1]=a[2]/*Unique*/;a[2]/*Unique*/=a[2]/*Unique*/+1
  a[j+2]=0
  return a[j+1]
```

#### FIRST

```rexx
::method first
  a=self~exposed
/* Returns the index of the first item in the list. */
  if a[1]/*ItemsCount*/=0 then return .nil
  return a[5]
```

#### LAST

```rexx
::method last
  a=self~exposed
/* Returns the index of the last item in the list. */
  if a[1]/*ItemsCount*/=0 then return .nil
  return a[3*a[1]/*ItemsCount*/+2]
```

#### FIRSTITEM

```rexx
::method firstitem
  a=self~exposed
/* Returns the first item in the list. */
  if a[1]/*ItemsCount*/=0 then return .nil
  return a[4]
```

#### LASTITEM

```rexx
::method lastitem
  a=self~exposed
/* Returns the last item in the list. */
  if a[1]/*ItemsCount*/=0 then return .nil
  return a[3*a[1]/*ItemsCount*/+1]
```

#### NEXT

```rexx
::method next         /* rANY */
  a=self~exposed
/* Returns the index of the item that follows the list item having the specified
index. */
  j=self~findindex(arg(1))
  if j=0 then call Raise 'Syntax',93.918
  j=j+3
  if j>3*a[1]/*ItemsCount*/ then return .nil /* Next of last was requested. */
  return a[j+1]
```

#### PREVIOUS

```rexx
::method previous     /* rANY */
  a=self~exposed
/* Returns the index of the item that precedes the list item having the
specified index. */
  j=self~findindex(arg(1))
  if j=0 then call Raise 'Syntax',93.918
  j=j-3
  if j<4 then return .nil /* Previous of first was requested. */
  return a[j+1]
```

#### SECTION

```rexx
::method section /* rANY oWHOLE>=0 */
  =self~exposed
/* Returns a new list containing selected items from the receiver list. The
first item in the new list is the item corresponding to the index specified,
in the receiver list. */
  j=self~findindex(arg(1))
  if j=0 then call Raise 'Syntax',93.918
  r= .list~new /* To build result in. */
  if arg(2,'E') then s = arg(2)
                     else s = self~items;
  do s
    r~insert (a[j])
    j=j+3
    if j>1+3*a[1]/*ItemsCount*/ then leave
    end
  return r
```
 
### Class queue

```rexx
::class 'Queue' subclass Collection

/* A queue is a sequenced collection with whole-number indexes. The
indexes specify the position of an item relative to the head (first item) of
the queue. Adding or removing an item changes the association of an index to
its queue item. */
```

#### PUSH

```rexx
::method push /* rvANY */
/* Adds the object value to the queue at its head. */
  a=self~exposed
  a[1]/*ItemCount*/=a[1]/*ItemCount*/+1
/* Slide along to make a space. */
  do j=1+3*a[1]/*ItemCount*/ by -3 to 7
    a[j]=a[j-3]
    a[j+l]=a[j-2]+1; /* Index changes */
    end j
  a[4]=arg(1)
  a[5]=1
  return
```

#### PULL

```rexx
::method pull
/* Returns and removes the item at the head of the queue. */
  a=self~exposed
  if a[1]/*ItemCount*/=0 then return .nil /* Stays empty */
  r=a[4]
  a[1]/*ItemCount*/=a[1]/*ItemCount*/-1
  do j=4 by 3 to 1+3*a[1]/*ItemCount*/
    a[j]=a[j+3]
    a[j+l]=a[j+4]-1; /* Index changes */
    end j
  return r
```

#### QUEUE

```rexx
::method queue       /* rANY */
/* Adds the object value to the queue at its tail. */
  a=self~exposed
  a[1]/*ItemCount*/=a[1]/*ItemCount*/+1
  a[1+3*a[1]/*ItemCount*/]=arg(1)
  a[2+3*a[1]/*ItemCount*/]=a[1]/*ItemCount*/
  return
```

#### PEEK

```rexx
::method peek
  a=self~exposed
/* Returns the item at the head of the queue. The collection remains unchanged.
*/
  return a[4]
```

#### REMOVE

```rexx
::method remove       /* rWHOLE>O */
/* Returns and removes from a collection the member item with the specified
index. */
  a=self~exposed
  if a[1]/*ItemCount*/<arg(1) then return .nil
  r=self~remove:super(arg(1))
  /* Reset the indexes. */
  k=0
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    k=k+1
    a[j+l]=k
    end j
  return r
```

### Class table

```rexx
::Class 'Table' subclass Collection
```

#### MAKEARRAY

```rexx
::method makearray
/* Returns a single-index array containing the index objects. */
/* This is different from Collection MAKEARRAY where items rather than indexes
are in the returned array. */
  forward message 'MAKEARRAYX'
```

#### UNION

```rexx
::method union        /* rCOLLECTION */
  return CommonUnion(self,arg(1))
```

#### INTERSECTION

```rexx
::method intersection         /* rCOLLECTION */
  return CommoniIntersect(self,arg(1))
```

#### XOR

```rexx
::method xor          /* rCOLLECTION */
  return CommonXor(self,arg(1))
```

#### DIFFERENCE

```rexx
::method difference   /* rCOLLECTION */
  return CommonDifference(self,arg(1))
```

#### SUBSET

```rexx
::method subset       /* rCOLLECTION */
return self~difference(arg(1))~items = 0
```

#### Class set

```rexx
::class 'Set' subclass table

/* A set is a collection that restricts the member items to have a value that is
 the same as the index. Any object can be placed in a set. There can be only
one occurrence of any object in a set. */
```

#### PUT

```rexx
/* Second arg same as first. Committee has dropped second? */
::method put          /* rANY oANY */
/* Makes the object value a member item of the collection and associates it with
specified index. */
  if arg(2,'E') then
    if arg(2)\==arg(1) then signal error  /* 949 */
  self~put:super(arg(1),arg(1))
```

#### OF

```rexx
::method of class     /* 1 or more rANY */
/* Returns a newly created set containing the specified value objects. */
  r=self~new
  do j=1 to arg()
    r~put(arg(j))
    end j
   return r
```

#### UNION

```rexx
::method union /* rCOLLECTION */
  return CommonUnion(self, EnBag(arg(1)))
```

#### INTERSECTION

```rexx
::method intersection          /* rCOLLECTION */
  return CommoniIntersect (self,EnBag(arg(1)))
```

#### XOR

```rexx
::method xor          /* rCOLLECTION */
  return CommonXor(self, EnBag(arg(1)))
```

#### DIFFERENCE

```rexx
::method difference   /* rCOLLECTION */
  return CommonDifference(self, EnBag(arg(1)))
```

### Class relation

```rexx
::class 'Relation' subclass Collection
```

#### PUT

```rexx
::method put          /* rANY rANY */
  use arg item, index
  a=self~exposed
/* Makes the object value a member item of the relation and associates it with
 the specified index. If the relation already contains any items with the
 specified index, this method adds a new member item value with the same index,
 without removing any existing members */
 a[1]/*ItemsCount*/=a[1]/*ItemsCount*/+1
  j=1+3*a[1]/*ItemsCount*/
  a[j]=item
  a[j+1]=index
  a[j+2]=0
  return /* Error 91 in OOI if context requiring result. */
```

#### ITEMS

```rexx
::method items       /* oANY */
  a=self~exposed
/* Returns the number of relation items with the specified index. If you specify
 no index, this method returns the total number of items associated with all
 indexes in the relation. */
  if \arg(1,'E') then return a[1]/*ItemsCount*/
  n=0
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    if arg(1)==a[j+1] then n=n+1
    end j
  return n
```

#### MAKEARRAY

```rexx
::method makearray
  forward message 'MAKEARRAYX'
```

#### SUPPLIER

```rexx
::method supplier     /* oANY */
  a=self~exposed
/* Returns a supplier object for the collection. If an index is specified, the
 supplier enumerates all of the items in the relation with the specified
 index. */
  m=.array~new     /* For the items */
  r=.array~new     /* For the indexes */
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    if arg(1,'E') then
      if arg(1)\==a[j+1] then iterate
    n=r~dimension(1)+1
    m[n] =a[j]
    r[n] =a[j+1]
    end j
  return .supplier~new(m,r)
```

#### UNION

```rexx
::method union        /* rCOLLECTION */
/* Union for a relation is just all of both. */
  r=self~class~new
  cs=self~supplier
  do while cs~available
    r[cs~index] =cs~item
    cs-next
    end
  cs=MayEnBag(arg(1))~supplier
  do while cs~available
    r[cs~index] =cs~item
    cs-next
    end
  return r
```

#### INTERSECTION

```rexx
::method intersection /* rCOLLECTION */
/* Intersection for a relation requires the items as well as the keys to
match. */
  r=self~class~new
  sc=self~class~new
  cs=self~supplier
  do while cs~available
    sc[cs~index] =cs~item
    cs~next
    end
  cs=MayEnBag(arg(1))~supplier
  do while cs~available
    if sc~hasitem(cs~item,cs~index) then
      r[ecs~index] =sc~removeitem(cs~item, cs~index)
    cs~next
    end
  return r
```

#### XOR

```rexx
::method xor          /* rCOLLECTION */
/* Returns a new relation that contains all items from self and
the argument except that all index-item pairs that appear in both collections
are removed. */
  r=self~class~new
  cs=self~supplier
  do while cs~available
    r[cs~index] =cs~item
    cs~next
    end
  cs=MayEnBag(arg(1))~supplier
  do while cs~available
    if self~hasitem(cs~item,cs~index) then
      r~removeitem(cs~item, cs~index)
    else
      r[cs~index] =cs~item
    cs~next
    end
  return r
```

#### DIFFERENCE

```rexx
::method difference   /* rCOLLECTION */
/* Returns a new relation containing only those index-item pairs from the
 SELF whose indexes the other collection does not contain. */
  r=self~class~new
  cs=self~supplier
  do while cs~available
    r[cs~index] =cs~item
    cs~next
    end
  cs=MayEnBag(arg(1))~supplier
  do while cs~available
    r~removeitem(cs~item, cs~index)
    cs~next
    end
  return r
```

#### SUBSET

```rexx
::method subset /* rCOLLECTION */
  return self~difference(arg(1))~items = 0
```

#### REMOVEITEM

```rexx
::method removeitem /* rANY rANY */
  a=self~exposed
/* Returns and removes from a relation the member item value (associated with
 the specified index). If value is not a member item associated with index
 index, this method returns the NIL object and removes no item. */
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    if a[j]==arg(1) & a[j+1]==arg(2) then do
      self~removeit(j)
      return arg(1)
      end
    end j
  return .nil
```

#### INDEX

```rexx
::method index        /* rANY */
  a=self~exposed
/* Returns the index for the specified item. If there is more than one index
 associated with the specified item, the one this method returns is not
 defined. */
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    if arg(1)==a[j] then return a[j+1]
    end j
  return .nil
```

#### ALLAT

```rexx
::method allat        /* rANY */
  a=self~exposed
/* Returns a single-index array containing all the items associated with the
 specified index. */
  r=.array~new
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    if arg(1)==a[j+1] then
      r[r~dimension(1)+1] = a[j]
    end j
  return r
```

#### HASITEM

```rexx
::method hasitem      /* rANY rANY */
  a=self~exposed
/* Returns 1 (true) if the relation contains the member item value (associated
 with specified index). Returns 0 (false) otherwise. */
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    if a[j]==arg(1) & a[j+l]==arg(2) then return 1
    end j
  return 0
```

#### ALLINDEX

```rexx
::method allindex    /* rANY */
  a=self~exposed
/* Returns a single-index array containing all indexes for the specified
 item. */
  r=.array~new
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    if a[j]==arg(1) then do
      r[r~dimension(1)+1] =a[j+1]
      end
    end j
  return r
```
### The bag class

```rexx
::class 'Bag' subclass relation

/* A bag is a collection that restricts the member items to having a value that
 is the same as the index. Any object can be placed in a bag, and the same
 object can be placed in a bag multiple times. */
```

#### OF

```rexx
::method of class     /* 1 or more rANY */
/* Returns a newly created bag containing the specified value objects. */
  r=self~new
  do j=1 to arg()
    r~put(arg(j))
    end j
  return r
```

#### PUT

```rexx
::method put          /* rANY oANY */
/* Committee does away with second argument? */
/* Makes the object value a member item of the collection and associates it with
 the specified index. If you specify index, it must be the same as value. */
  if arg(2,'E') then
    if arg(2)\==arg(1) then signal error
  self~put:super(arg(1),arg(1))
```

#### UNION

```rexx
::method union           /* rCOLLECTION */
  return CommonUnion(self, EnBag(arg(1)))
```

#### INTERSECTION

```rexx
::method intersection         /* rCOLLECTION */
  return CommoniIntersect(self,EnBag(arg(1)))
```

#### XOR

```rexx
::method xor          /* rCOLLECTION */
  return CommonXor(self, EnBag(arg(1)))
```

#### DIFFERENCE

```rexx
::method difference    /* rCOLLECTION */
  return CommonDifference(self, EnBag(arg(1)))
```

### The directory class

```rexx
::class 'Directory' subclass Collection
```

#### AT

```rexx
::method at           /* rANY */
  a=self~exposed
/* Returns the item associated with the specified index. */
  j=self~findindex(arg(1))
  if j=0 then return .nil
/* Run the method if there is one. */
  if a[j+2] then return self~run(a[j])
  return a[j]
```

#### PUT

```rexx
::method put          /* rANY rANY */
  a=self~exposed
/* Makes the object value a member item of the collection and associates it with
the specified index. */
  if \arg(2)~hasmethod('MAKESTRING') then call Raise 'Syntax', 93.938
  self~put:super(arg(1),arg(2)~makestring)
  return
```

#### MAKEARRAY

```rexx
::method makearray
  forward message 'MAKEARRAYX'
```

#### SUPPLIER

```rexx
::method supplier
  a=self~exposed
/* Returns a supplier object for the directory. */
/* Check out what happens to the SETENTRY fields. */
  r=.array~new    /* For items */
  do j=4 by 3 to 1+3*a[1]/*ItemsCount*/
    r[r~dimension(1)+1]=a[j]
    end j
  return .supplier~new(r,self~makearray)
```

#### UNION

```rexx
::method union         /* rCOLLECTION */
  return CommonUnion(self,arg(1))
```

#### INTERSECTION

```rexx
::method intersection         /* rCOLLECTION */
  return CommoniIntersect(self,arg(1))
```

#### XOR

```rexx
::method xor        /* rCOLLECTION */
return CommonXor(self,arg(1))
```

#### DIFFERENCE

```rexx
::method difference   /* rCOLLECTION */
  return CommonDifference(self,arg(1))
```

#### SUBSET

```rexx
::method subset     /* rCOLLECTION */
return self~difference(arg(1))~items = 0
```

#### SETENTRY

```rexx
::method setentry     /* rSTRING oANY */
  a=self~exposed
/* Sets the directory entry with the specified name (translated to uppercase) to
 the second argument, replacing any existing entry or method for the specified
 name. */
  n=translate(arg(1))
  j=self~findindex(n)
  if j=0 & \arg(2,'E') then return
  if \arg(2,'E') then do /* Removal */
    self~removeit (j)
    return
    end
  if j=0 then do /* It's new */
    a[1]/*ItemsCount*/=a[1]/*ItemsCount*/ +1
    j=1+3*al[1]/*ItemsCount*/
    a[j+l]=n
    end
  a[j]=arg(2)
  a[j+2]=0
  return
```

#### ENTRY

```rexx
::method entry        /* rSTRING */
  a=self~exposed
/* Returns the directory entry with the specified name (translated to
 uppercase). */
  n=translate(arg(1))
  j=self~findindex(n)
/*if j=0 then signal error according to online */
/* Online has something about running UNKNOWN. */
  if j=0 then return .nil
  /* If there is an entry decide whether to invoke it. */
  if a~hasindex(j) then do
    if \a[j+2] then return al[j]
    return self~run(al[jl])
    end
```

#### HASENTRY

```rexx
::method hasentry     /* rSTRING */
/* Returns 1 (true) if the directory has an entry or a method for the specified
name (translated to uppercase) or 0 (false) otherwise. */
  return self~findindex(translate(arg(1)))>0
```

#### SETMETHOD

```rexx
::method setmethod    /* rSTRING oMETHOD */
  a=self~exposed
/* Associates entry with the specified name (translated to uppercase) with
 method method. Thus, the language processor returns the result of running
 method when you access this entry. */
/* (Part of METHOD checking converts string or array to actual method.) */
  n=translate(arg(1))
  j=self~findindex(n)
  if j=0 & \arg(2,'E') then return
  if \arg(2,'E') then do
    self~removeit (j)
    return
    end
  if j=0 then do /* It's new */
    a[1]/*ItemsCount*/=a[1]/*ItemsCount*/ +1
    j=1+3*al[1]/*ItemsCount*/
    a[j+l]=n
    end
  a[j]=arg(2)
  a[j+2]=1
  return
```

#### UNKNOWN

```rexx
::method unknown      /* rSTRING rARRAY */
/* Runs either the ENTRY or SETENTRY method, depending on whether the message
 name supplied ends with an equal sign. If the message name does not end with an
 equal sign, this method runs the ENTRY method, passing the message name as its
 argument. */
  if right(arg(1),1)\=='=' then
    return self~entry(arg(1))
  /* ?? Not clear whether second argument is mandatory. */
  t=.nil
  if arg(2,'E') then t=arg(2)[1]
  self~setentry(left(arg(1),length(arg(1))-1),t)
```

### The stem class

_For some reason, the stem class doesn't have PUT and AT methods, which stops us having a general rule about [] synonyms AT, []= synonyms PUT._

_Anyway, committee doing without this class as such._

_Here is temporary stuff showing how to use algebra in the collection coding._

```rexx
/* This 1998 version uses Rony's rules for XOR and INTERSECTION based on
UNION and DIFFERENCE */

/* Test Set-Operator-Methods on different collection objects */

/* This top part has some rough parts - not meant for standard. */

/* The dumps put out results sorted, so that comparisons can be made
between implementations that keep collections in different orders. */

/* Invocation example:
  settest.cmd 1> tmp.res 2> tmp.err
*/

/* Jnitial verification that new definitions are in effect  */
J18list = .List~new
if \J18list~hasmethod("J18") then signal error

/* Input collections used for the tests */
coll.1 = .array~of(1, 2,, 4)
coll.2 = list~of(2, 3, 6)
coll.3 = .queue~new~~PUSH(2)~~PUSH(3)~~PUSH(7)
coll.4 = .directory~new~~setentry(1, "eins")~~setentry(3, "drei")
coll.5 = .bag~new~~put(2)~~put(3)~~put(5)~~put(2)
coll.6 = .relation~new~~"[J="("zwei", 2)~~"[]="(‘"drei", 3)~~"[J="(‘vier", 8)~~"J="C"drei",3)
coll.7 = .set~of(2, 3, 9)
coll.8 = .table~new~~"[]="("zwei", 2)~~"[J="("drei", 3)~~"[T]J="C"vier", 10)
coll.0 = 8

message. 1 = "UNION"
message.2 = "INTERSECTION"         /* index the same in both */
message.3 = "DIFFERENCE" /* if index only in Ist collection  */
message.4 = "XOR"     /* unique index among both collections */
message.5 = "SUBSET" /* target is subset of other collection */
message. = 5

target. = coll.

hstart = 4
istart = |
jstart = 1
output = 1
setOfTargets = .set~new

SAY "Test Results of Set Operations on Collection Classes -- dated" date('U')
SAY

DO h= hstart TO target.0        /* loop over target    */
  targetID = target.h~class~id
  IF \setOfTargets~hasindex(targetID) THEN
  DO
    SAY
    SAY CENTER(" Target:" targetID "", 70, "=")
    setOfTargets~put(targetID)
    output = 1
  END

  DO i= istart TO coll.0 /* loop over other collections    */
    if output then do
      output = 0
      argumentID = coll.i~class~id
      SAY
      SAY CENTER(" argument:" argumentID "", 65, "=")
      SAY
      SAY "INPUT:"
      SAY "contents of" pp(targetID) "target:"
      CALL dump_collection target.h
      SAY

      SAY "contents of" pp(argumentID) "argument:"
      CALL dump_collection colli
      SAY
      SAY CENTER(" start set operators ", 65, "-")
    end

    DO j =jstart TO message.0   /* loop over set operators */
      tmpString | = RIGHT("h" pp(h) "i" ppG) "j" ppG), 65)
      tmpString2 = pp(targetID "~" message.j || "(" argumentID ")")
      SAY OVERLAY( tmpString2, tmpString1 )
                 /* set resume parameter in case of error*/
      jstart = j+1
      IF jstart>message.0 THEN DO
        istart = i+]

        IF istart>coll.0 THEN DO
          hstart = h+1
          istart = 1
        END
        jstart = 1
        output = 1
      END
                      /* process method invocation */
      IF target.h~hasmethod(message.j) THEN DO
         tmp = .message~new(target.h, message.j, "I", coll.i)~send
         if "The String class"=tmp~class~defaultname then do
           if datatype(tmp,"B") then do
             if tmp then
               SAY" Result is TRUE"
             else
               SAY" Result is FALSE"
           end
         end
         else CALL dump_collection tmp
       END
       ELSE
         SAY pp(targetID) "does not have method ~" pp(message.j)

       SAY LEFT("", 40, "-")
     END
     jstart = 1
   END
   jstart = 1
   istart = 1
   output = 1
 END

 RETURN

dump_collection:procedure
  USE ARG collection
  k = .array~new
  i = .array~new
  tmpSupp = collection~supplier
  DO WHILE tmpSupp~AVAILABLE
    k[k~dimension(1)+1]=tmpSupp~INDEX
    i{i~dimension(1)+1]=tmpSupp~ITEM
    tmpSupp~NEXT
  END
  do until hope
    hope=1
    do j=1 to k~dimension(1)-1
      if k[j]~string>k[j+1]~string |,
        (k[j]~string=k[j+1]~string & i[j]~string<i[j+1]~string) then do
        t=k[j];k[j]=k[j+1];k[j+1]=t
        t=i[j];i[j]=i[j+1];i[j+1]=t
        hope=0
      end
    end
  end
  if O=collection~items then
    say" The result is empty!"
  else
    do j=1 to k~dimension(1)
      SAY " " "index" pp(k[j]) "item" ppd[j)
    end
  RETURN
            /* Auxiliary routines */
pp: RETURN "[" || ARG(1)~string || "]"
```

/*==================================================================================*/

/* X3J18 Rexx Language Standard proposal for the Set-like operations on the
Collection classes */

/* Tn the same way that the first standard uses BIFs which are defined using
other BIFs and ultimately the arithmetic and character operators, the second
standard can define classes using other classes and some fundamental basis.

This program gives the definition of some other classes, in a form which
(when thoroughly developed) might be part of the second standard. It also
has a testing mechanism, which will not be part of a standard.

This particular program is implementing collections on top of array.
*/

/* The class Collection is not one builtin, but is used to simplify the
definition. */

::class ‘Collection’

:imethod init
expose a
/* A collection is modelled as using 3 slots in an array for each element.
The first slot holds the item, the second the index, and the third is
used by particular types of collection. This order of slots is arbitary,
chosen to match order of arguments for PUT and SUPPLIER~NEW. */
/* The first set of 3 slots is reserved for other purposes, to avoid
having separate variables which the subclassing would need to access. */
a=.alray~new
a[1]/*ItemsCount*/=0
a[2]/*Unique*/=0

return self

::method exposed private
expose a

/* This method allows subclasses to get at the implementation of Collection. */
retum a

::method findindex private
expose a
/* Returns array index if the collection contains any item associated with the
index specified or returns 0 otherwise. */
do j=4 by 3 to 143*a[1]/*ItemsCount*/
if a[j+1]==arg(1) then return j
end j
return 0

::method at /* rANY */
expose a
/* Returns the item associated with the specified index. */
j=self~findindex(arg(1))
if j=0 then return .nil
return a[j]

::method '[]'
/* Synonym for the AT method. */
forward message 'AT’

::method put /* rANY rANY */
expose a
use arg item, index
/* Replaces any existing item associated with the specified index with the new
item. Otherwise adds the item-index pair. */
j=self~findindex(index)
if j>0 then do
a[j]=item
returm
end
a[1]/*ItemsCount*/=a[1 ]/*ItemsCount*/+1
j=lt3*a[1]/*ItemsCount*/
a[j]=item
a[j+1]=index
a[j+2]=0
return /* Error 91 in OOI if context requiring result. */

:method ‘[]='
/* Synonym for the PUT method. */

forward message 'PUT’

z:method hasindex /* rANY */
/* Returns | (true) if the collection contains any item associated with the
index specified or returns O (false) otherwise. */

return self~findindex(arg(1))>0

::method items
expose a

/* Returns the number of items in the collection. */
return a[1]/*ItemsCount*/

zimethod remove /* rANY */

expose a
/* Returns and removes from a collection the member item with the specified
index. */

j=self~findindex(arg(1))

if j=0 then return .nil

r=alj]

self~removeit(j)

returm r

::method removeit private

expose a

use arg j

/* Remove relevant slots from the array, with compaction. */

do j=j+3 by 3 to 14+3*a[1]/*ItemsCount*/
a[j-3]=alj];alj-2]=alj+1];a[j- 1 ]=alj+2]
end j

a[1]/*ItemsCount*/=a[ 1 ]/*ItemsCount*/-1

return

::method makearray
expose a
/* Returns a single-index array containing the receiver list items. */
r=.array~new = /* To build result in. */
do j=4 by 3 to 143*a[1]/*ItemsCount*/
r[r~dimension(1)+1]=a[j]
end j
returm r

::method makearrayx private
expose a

/* Returns a single-index array containing the receiver index items. */
r=.array~new = /* To build result in. */
do j=4 by 3 to 143*a[1]/*ItemsCount*/

r[r~dimension(1)+1]=a[j+1]
end j
return r

:imethod supplier
expose a
/* Returns a supplier object for the list. */
return .supplier~new(self~makearray:.collection,self~makearrayx)

::class ‘List’ subclass Collection

zimethod J18 = /* Here to demonstrate .LIST is replaced */
return

/* List and Queue are special because there is an order to their elements. */

::method put /* rANY rANY */
use arg item, index
a=self~exposed

/* PUT for a List must not be an insertion. */
j=self~findindex(index)
if j=0 then call Raise 'Syntax',93.918
a[j]=item
retum

zimethod of class /* 1 or more oANY Are they omittable? Not in IOO */
/* Returns a newly created list containing the specified value objects in the
order specified. */
r=self ~ new
do j = 1 to argQ)
r ~ insert(arg(j))
end j
return r

zimethod insert /* rANY oANY */

use arg item, index

a=self~exposed
/* Returns a list-supplied index for a new item, of specified value, which is
added to the list. The new item follows the existing item with the specified
index in the list ordering. */
/* Establish the index of what preceeds the new element. */
/* Tf there was no index given, the new item becomes the last on list. */
/* mil argument means first */

if arg(2,'E’) then p=arg(2)

else p=self~last

/* Convert from list index to underlying array index. */

if p==.nil then j=1
else j=self~findindex(p)

if j=0 then call Raise 'Syntax',93.918

j=J+3 /* Where new entry will be. */
/* Move space to required place. */

a[1]/*ItemsCount*/=a[1 ]/*ItemsCount*/+1

do k=1+3*a[1]/*ItemsCount*/ by -3 to j+3

a[k]=a[k-3];a[k+1 ]=a[k-2];a[k]=a[k-3]
end

/* Insert new element. */

a[j]=item
/* A new, unique, index is needed. */
/* The basic requirement is for something unique, so this would be correct:

i=.object~new /* a unique object, used as a key (the index on the list) */
*/
/* However, a number can be used. (At risk of the user thinking it is
sensible to do arithmetic on it.) */

a[j+1]=a[2]/*Unique*/;a[2]/*Unique*/=a[2 ]/*Unique*/+1

a[j+2]=0

return a[j+1]

:smethod first
a=self~exposed

/* Returns the index of the first item in the list. */
if a[1]/*ItemsCount*/=0 then return .nil
return a[5]

::method last
a=self~exposed

/* Returns the index of the last item in the list. */
if a[1]/*ItemsCount*/=0 then return .nil
return a[3*a[1]/*ItemsCount*/+2]|

::method firstitem
a=self~exposed

/* Returns the first item in the list. */
if a[1]/*ItemsCount*/=0 then return .nil
return a[4]

::method lastitem
a=self~exposed

/* Returns the last item in the list. */
if a[1]/*ItemsCount*/=0 then return .nil
return a[3*a[1]/*ItemsCount*/+1 |

::method next P* rANY */
a=self~exposed
/* Returns the index of the item that follows the list item having the specified
index. */

j=self~findindex(arg(1))

if j=0 then call Raise 'Syntax',93.918

jait3

if j>3*a[1]/*ItemsCount*/ then return .nil /* Next of last was requested. */

return a[j+1]

zimethod previous /* rANY */

a=self~exposed
/* Returns the index of the item that precedes the list item having the
specified index. */

j=self~findindex(arg(1))

if j=0 then call Raise 'Syntax',93.918

ja-3

if j<4 then return .nil /* Previous of first was requested. */

return a[j+1]

zimethod section /* rANY OoWHOLE>=0 */
a=self~exposed
/* Returns a new list containing selected items from the receiver list. The
first item in the new list is the item corresponding to the index specified,
in the receiver list. */
j=self~findindex(arg(1))
if j=0 then call Raise 'Syntax',93.918
r=.list~new /* To build result in. */
if arg(2,'E’) then s = arg(2)
else s = self~items;
do s
r~insert(a[j])
jait3
if j>1+3*a[1]/*ItemsCount*/ then leave
end
retum r

::class ‘Queue’ subclass Collection
/* A queue is a sequenced collection with whole-number indexes. The
indexes specify the position of an item relative to the head (first item) of

the queue. Adding or removing an item changes the association of an index to
its queue item. */

::method push /* rANY */

/* Adds the object value to the queue at its head. */
a=self~exposed
a[1]/*ItemCount*/=a[1 |/*ItemCount*/+1

/* Slide along to make a space. */
do j=1+3*a[1]/*ItemCount*/ by -3 to 7

aljl=alj-3]
a[j+1]=a[j-2]+1; /* Index changes */
end j
a[4]=arg(1)
a[5]=1
return
::method pull

/* Returns and removes the item at the head of the queue. */
a=self~exposed
if a[1]/*ItemCount*/=0 then return .nil /* Stays empty */
r=a[4]
a[1]/*ItemCount*/=a[1]/*ItemCount*/- 1
do j=4 by 3 to 14+3*a[1]/*ItemCount*/
alj}=alj+3]
a[j+1]=al[j+4]-1; /* Index changes */
end j
returm r

zimethod queue =/* rANY */

/* Adds the object value to the queue at its tail. */
a=self~exposed
a[1]/*ItemCount*/=a[1 |/*ItemCount*/+1
a[{1+3*a[1]/*ItemCount*/|=arg(1)
a[2+3*a[1]/*ItemCount*/|=al[ 1 ]/*ItemCount*/
return

:imethod peek

a=self~exposed
/* Returns the item at the head of the queue. The collection remains unchanged.
*/

return a[4]

zimethod remove /* rWHOLE>O */
/* Returns and removes from a collection the member item with the specified
index. */
a=self~exposed
if a[1]/*ItemCount*/<arg(1) then return .nil
r=self~remove:super(arg(1))
/* Reset the indexes. */
k=0
do j=4 by 3 to 143*a[1]/*ItemsCount*/
k=k+1
a{j+1J=k

end j
return r

::class "Table' subclass Collection

::method makearray
/* Returns a single-index array containing the index objects. */
/* This is different from Collection MAKEARRAY where items rather than indexes
are in the returned array. */
forward message 'MAKEARRAYX’

::method union /* rCOLLECTION */
return CommonUnion(self,arg(1))

::method intersection /* rCOLLECTION */
/* Returns a new collection of the same class as SELF that
contains the items from SELF that have indexes also in the
argument. */
/* Actually an index in SELF can only be ‘matched’ with one in the
argument once. */

return self~difference(self~difference(arg(1)))

::method xor /* rCOLLECTION */
/* Returns a new relation that contains all items from self and
the argument except that all index-item pairs that appear in both collections
are removed. */
return CommonXor(self,arg(1))

::method difference /* rCOLLECTION */
return CommonDifference(self,arg(1))

::method subset = /* rCOLLECTION */
return self~difference(arg(1))~items = 0

::class ‘Set’ subclass table

/* A set is a collection that restricts the member items to have a value that is
the same as the index. Any object can be placed in a set. There can be only
one occurrence of any object in a set. */

/* Second arg same as first. Committee has dropped second? */
:rmethod put /* rANY oANY */
/* Makes the object value a member item of the collection and associates it with
specified index. */
if arg(2,'E’) then
if arg(2)\==arg(1) then signal error /* 949 */
self~put:super(arg(1),arg(1))

zimethod of class /* 1 or more rANY */
/* Returns a newly created set containing the specified value objects. */
r=self~new
do j=1 to arg()
r~put(arg(j))
end j
retum r

::method union /* rCOLLECTION */
return CommonUnion(self,EnBag(arg(1)))

::method intersection /* rCOLLECTION */
return self~difference(self~difference(arg(1)))

::method xor /* rCOLLECTION */
return CommonXor(self,EnBag(arg(1)))

::method difference /* rCOLLECTION */
return CommonDifference(self,EnBag(arg(1)))

::class ‘Relation’ subclass Collection

::method put /* rANY rANY */

use arg item, index

a=self~exposed
/* Makes the object value a member item of the relation and associates it with
the specified index. If the relation already contains any items with the
specified index, this method adds a new member item value with the same index,
without removing any existing members */

a[1]/*ItemsCount*/=a[1 ]/*ItemsCount*/+1

j=lt3*a[1]/*ItemsCount*/

a[j]=item

a[j+1]=index

a[j+2]=0

return /* Error 91 in OOI if context requiring result. */

:imethod items /* oANY */
a=self~exposed
/* Returns the number of relation items with the specified index. If you specify

no index, this method returns the total number of items associated with all
indexes in the relation. */

if \arg(1,’E’) then return a[1]/*ItemsCount*/

n=0

do j=4 by 3 to 143*a[1]/*ItemsCount*/

if arg(1)==a[j+1] then n=n+1
end j
retum n

::method makearray
forward message 'MAKEARRAYX’

zimethod supplier /* oANY */
a=self~exposed
/* Returns a supplier object for the collection. If an index is specified, the
supplier enumerates all of the items in the relation with the specified
index. */
m=.array~new /* For the items */
r=.array~new  /* For the indexes */
do j=4 by 3 to 143*a[1]/*ItemsCount*/
if arg(1,'E’) then
if arg(1)\==a[j+1] then iterate
n=r~dimension(1)+1
m[n]=alj]
r[n]=a[j+1]
end j
return .supplier~new(m,r)

::method union /* rCOLLECTION */
/* Union for a relation is just all of both. */
r=self~class~new
cs=self~supplier
do while cs~available
r[cs~index]=cs~item
cs~next
end
cs=MayEnBag(arg(1))~supplier
do while cs~available
r[cs~index]=cs~item
cs~next
end
return r

::method intersection /* rCOLLECTION */
return self~difference(self~difference(arg(1)))

::method xor /* rCOLLECTION */
return CommonXor(self,arg(1))

zimethod difference /* rCOLLECTION */
/* Returns a new relation containing only those index-item pairs from the

163
SELF whose indexes the other collection does not contain. */
r=self~class~new
cs=self~supplier
do while cs~available
r[cs~index]=cs~item
cs~next
end
cs=MayEnBag(arg(1))~supplier
do while cs~available
r~removeitem(cs~item,cs~index)
cs~next
end
return r

::method subset = /* rCOLLECTION */
return self~difference(arg(1))~items = 0

zimethod removeitem /* rANY rANY */
a=self~exposed
/* Returns and removes from a relation the member item value (associated with
the specified index). If value is not a member item associated with index
index, this method returns the NIL object and removes no item. */
do j=4 by 3 to 143*a[1]/*ItemsCount*/
if a{jJ==arg(1) & a[j+1]==arg(2) then do
self~removeit(j)
return arg(1)
end
end j
return .nil

:rmethod index /* rANY */
a=self~exposed
/* Returns the index for the specified item. If there is more than one index
associated with the specified item, the one this method returns is not
defined. */
do j=4 by 3 to 143*a[1]/*ItemsCount*/
if arg(1)==a[j] then return a[j+1]
end j
return .nil

::method allat /* rANY */

a=self~exposed
/* Returns a single-index array containing all the items associated with the
specified index. */

r=.array~new

do j=4 by 3 to 143*a[1]/*ItemsCount*/

if arg(1)==a[j+1] then
r[r~dimension(1)+1] = a[j]
end j
return r

::method hasitem /* rANY rANY */
a=self~exposed
/* Returns 1 (true) if the relation contains the member item value (associated
with specified index). Returns 0 (false) otherwise. */
do j=4 by 3 to 143*a[1]/*ItemsCount*/
if a{jJ==arg(1) & a[j+1]==arg(2) then return |
end j
return 0

z:method allindex /* rANY */
a=self~exposed
/* Returns a single-index array containing all indexes for the specified
item. */
r=.array~new
do j=4 by 3 to 143*a[1]/*ItemsCount*/
if a[j]==arg(1) then do
r[r~dimension(1)+1]=a[j+1]
end
end j
returm r

::class ‘Bag’ subclass relation

/* A bag is a collection that restricts the member items to having a value that
is the same as the index. Any object can be placed in a bag, and the same
object can be placed in a bag multiple times. */

zimethod of class /* 1 or more rANY */
/* Returns a newly created bag containing the specified value objects. */
r=self~new
do j=1 to arg()
r~put(arg(j))
end j
retum r

:rmethod put /* rANY oANY */
/* Committee does away with second argument? */
/* Makes the object value a member item of the collection and associates it with
the specified index. If you specify index, it must be the same as value. */
if arg(2,'E’) then
if arg(2)\==arg(1) then signal error
self~put:super(arg(1),arg(1))

/* Bag may be a subclass of relation but many methods have different
semantics. */

::method union /* rCOLLECTION */
return CommonUnion(self,EnBag(arg(1)))

::method intersection /* rCOLLECTION */
return self~difference(self~difference(arg(1)))

::method xor /* rCOLLECTION */
return CommonXor(self,EnBag(arg(1)))

::method difference /* rCOLLECTION */
return CommonDifference(self,EnBag(arg(1)))

::class ‘Directory’ subclass Collection

/* Later we take three array elements for each element in the directory, one
for the item, one to contain the index, one to say if the item is a method

to be run or not. */

::method at /* rANY */
a=self~exposed
/* Returns the item associated with the specified index. */
j=self~findindex(arg(1))
if j=0 then return .nil
/* Run the method if there is one. */
if a[j+2] then return self~run(a[j])
return a[j]

::method put /* rANY rANY */
a=self~exposed
/* Makes the object value a member item of the collection and associates it with
the specified index. */
if \arg(2)~hasmethod(MAKESTRING'’) then call Raise 'Syntax', 93.938
self~put:super(arg(1),arg(2)~makestring)
return

::method makearray
forward message 'MAKEARRAYX’

:imethod supplier
a=self~exposed

/* Returns a supplier object for the directory. */

/* Check out what happens to the SETENTRY fields. */
r=.array~new /* For items */

do j=4 by 3 to 143*a[1]/*ItemsCount*/
r[r~dimension(1)+1]=a[j]
end j

return .supplier~new(r,self~makearray)

::method union /* rCOLLECTION */
return CommonUnion(self,arg(1))

::method intersection /* rCOLLECTION */
return self~difference(self~difference(arg(1)))

::method xor /* rCOLLECTION */
return CommonXor(self,arg(1))

::method difference /* rCOLLECTION */
return CommonDifference(self,arg(1))

::method subset = /* rCOLLECTION */
return self~difference(arg(1))~items = 0

z:method setentry /* rSTRING oANY */
a=self~exposed
/* Sets the directory entry with the specified name (translated to uppercase) to
the second argument, replacing any existing entry or method for the specified
name. */
n=translate(arg(1))
j=self~findindex(n)
if j=0 & \arg(2,'E') then return
if \arg(2,'E’) then do /* Removal */
self~removeit(j)
returm
end
if j=0 then do /* It's new */
a[1]/*ItemsCount*/=a[1]/*ItemsCount*/ +1
j=lt3*a[1]/*ItemsCount*/
a[j+1]J=n
end
a[j]=arg(2)
a[j+2]=0

returm

::method entry /* rSTRING */

a=self~exposed
/* Returns the directory entry with the specified name (translated to
uppercase). */

n=translate(arg(1))

j=self~findindex(n)
/*if j=0 then signal error according to online */
/* Online has something about running UNKNOWN. */
if j=0 then return .nil
/* Tf there is an entry decide whether to invoke it. */
if a~hasindex(j) then do
if \a[j+2] then return a[j]
return self~run(a[j])
end

z:method hasentry /* rSTRING */
/* Returns 1| (true) if the directory has an entry or a method for the specified
name (translated to uppercase) or O (false) otherwise. */

return self~findindex(translate(arg(1)))>0

z:method setmethod /* rSTRING oMETHOD */
a=self~exposed
/* Associates entry with the specified name (translated to uppercase) with
method method. Thus, the language processor returns the result of running
method when you access this entry. */
/* (Part of METHOD checking converts string or array to actual method.) */
n=translate(arg(1))
j=self~findindex(n)
if j=0 & \arg(2,'E') then return
if \arg(2,’E’) then do
self~removeit(j)
returm
end
if j=0 then do /* It's new */
a[1]/*ItemsCount*/=a[1]/*ItemsCount*/ +1
j=lt3*a[1]/*ItemsCount*/
a[j+1]J=n
end
a[j]=arg(2)
a{j+2]=1

returm

:imethod unknown =/* rSTRING rARRAY */

/* Runs either the ENTRY or SETENTRY method, depending on whether the message
name supplied ends with an equal sign. If the message name does not end with an
equal sign, this method runs the ENTRY method, passing the message name as its
argument. */
if right(arg(1),1)\=='="' then

return self~entry(arg(1))
/* 22 Not clear whether second argument is mandatory. */
t=.nil

if arg(2,'E’) then t=arg(2)[1]
self~setentry(left(arg(1),length(arg(1))-1),t)

routine CommonXor
/* Returns a new collection that contains all items from self and
the argument except that all indexes that appear in both collections
are removed. */
/* When the target is a bag, there may be an index in the bag that is
duplicated and the same value as an index in the argument. Should one
copy of the index survive in the bag? */
Ihs=arg(1)~difference(arg(2))
rhs=Cast(arg(1),MayEnBag(arg(2)))~difference(arg(1))
return lhs~union(rhs)

nroutine CommonUnion
/* Returns a new collection of the same class as SELF that
contains all the items from SELF and items from the
argument that have an index not in the first. */
/* Best to add them all. By adding non-receiver first we ensure that
receiver takes priority when same indexes. */
This = arg(1) /* self of caller */
r=This~class~new
cs=MayEnBag(arg(2))~supplier
do while cs~available
r[cs~index]=cs~item
cs~next
end
cs=This~supplier
do while cs~available
r[cs~index]=cs~item
cs~next
end
return r

nroutine CommonDifference
/* Returns a new collection containing only those index-item pairs from the
SELF whose indexes the other collection does not contain. */
This = arg(1) /* self of caller */
r=This~class~new
cs=This~supplier
do while cs~available
r[cs~index]=cs~item
cs~next
end
cs=MayEnBag(arg(2))~supplier

do while cs~available
r~remove(cs~index)
cs~next
end

return r

routine MayEnBag

/* For List and Queue the indexes are dropped. */
r=arg(1)
if r~class == .List | r~class == .Queue then r=EnBag(r)
retum r

routine EnBag
r=.Bag~new
s=arg(1)~supplier
do while s~available
if arg(1)~class == .List | arg(1)~class == .Queue then
1[s~item]=s~item
else
/* This case is when the receiver is a Bag. */
1[s~index]=s~index
s~next
end
return r

/* This Cast routine commented away, since replaced by Oct 98 Rony version.
routine Cast public
use arg Target, Other
TmpColl = Target~class~new /* Create an instance of type Target */
TmpSupp = Other~supplier /* Get supplier from Other */
signal on syntax
do while TmpSupp~available
TmpColl[TmpSupp~index] = TmpSupp~item
TmpSupp~next
end
return TmpColl

/* Tf syntax error 93.949, then target is an index-only collection like a set.*/
syntax:

if condition( "O" )~code = "93.949" then signal IndexOnly

raise propagate /* Unhandled syntax error, raise in caller */

IndexOnly: /* This for index-only collections. */
do while TmpSupp~available
TmpColl[TmpSupp~index] = TmpSupp~index
TmpSupp~next

end
return TmpColl
End commented away */

/* 98-09-24, ---ref;
CAST2.CMD
return a collection of type "target" which collected all
item/index pairs of the argument "other" */

2: ROUTINE cast PUBLIC
USE ARG target, other

SIGNAL ON SYNTAX
IF \ other ~ HASMETHOD( "SUPPLIER" ) THEN
RAISE SYNTAX 98.907 ARRAY ("COLLECTION (i.e. argument2='other'-object must
have a 'SUPPLIER'-method)" )

tmpColl = target ~ CLASS ~ NEW /* create a an instance of type target */
tmpSupp = other~ SUPPLIER /* get supplier from other */

/* is index of "other" usable ? */
bIndexUsable = other ~ HASMETHOD( "UNION" )

IF .Debug = .true THEN IF \ bIndexUsable THEN
SAY" /// index of ‘other’ not usable for setlike-operations”

/* possible syntax-error, if index and item must have the same value,
e.g. for sets/bags */
SIGNAL ON SYNTAX NAME INDEX ONLY
target ~ CLASS ~ NEW ~ PUT( 1,2) /* test, if target-type is index-only
*/

SIGNAL ON SYNTAX
DO WHILE tmpSupp ~ AVAILABLE
IF bIndexUsable THEN tmpColl[ tmpSupp ~ INDEX ] = tmpSupp ~ ITEM
ELSE tmpColl[ tmpSupp ~ ITEM ] = tmpSupp ~ ITEM
tmpSupp ~ NEXT
END
RETURN tmpColl

INDEX_ONLY : /* this is for index-only collections (e.g. sets, bags) */
SIGNAL ON SYNTAX
IF .Debug = .true THEN
SAY" \\'target’ is an index-only collection (index==item)"
DO WHILE tmpSupp ~ AVAILABLE

IF bIndexUsable THEN tmpColl[ tmpSupp ~ INDEX ] = tmpSupp ~ INDEX
ELSE tmpColl[ tmpSupp ~ ITEM ] = tmpSupp ~ ITEM
tmpSupp ~ NEXT
END
RETURN tmpColl

SYNTAX: RAISE PROPAGATE /* raise error in caller */

## The stream class

The stream class provides input/output on external streams.
::class stream

::method init /* rString */
Initializes a stream object for a stream named name, but does not open the stream.
::smethod query /* keywords */

There is also QUERY as command with method COMMAND.

Used with options, the QUERY method returns specific information about a stream.
::method charin

::smethod charout

::method chars

::method linein

::method lineout

::method lines

::method qualify

::method command /* rString */

Returns a string after performing the specified stream command.
::method open

There is also OPEN as command with method COMMAND.

Opens the stream to which you send the message and returns "READY:".

Committee dropping OPEN POSITION QUERY SEEK as methods in favour of command use.
::method state

Returns a string that indicates the current state of the specified stream.
::method say

::method uninit

::method position /* Ugh */
POSITION is a synonym for SEEK.
::method seek /* Ugh */

Sets the read or write position a specified number (offset) within a persistent stream.

::method flush

Returns "READY:". Forces any data currently buffered for writing to be written to the stream receiving the
message.

There is also FLUSH as command with method COMMAND.

Committee dropping FLUSH.

::method close

Closes the stream that receives the message.

There is also CLOSE as command with method COMMAND.

Semantics are 'seen by other thread’.
::method string

::method makearray /* rCHARLINE */
Returns a fixed array that contains the data from the stream in line or character format, starting from the

current read position.
::method supplier

Returns a supplier object for the stream.
::method description

::smethod arrayin /* rCHARLINE */

Mixed case value works on OOI.

Committee dropping Arrayin & Arrayout. Arrayin == MakeArray

Returns a fixed array that contains the data from the stream in line or character format, starting from the

current read position.
::smethod arrayout /* rARRAY rCHARLINE */

Returns a stream object that contains the data from array.

## The alarm class
::class alarm

::method init /* Time, Msg */
Sets up an alarm for a future time atime.
::method cancel

Cancels the pending alarm request represented by the receiver. This method takes no action if the
specified time has already been reached.

## The monitor class
The Monitor class forwards messages to a destination object.

-local ['OUTPUT'] = .monitor~new(.output)

::class monitor

### INIT
Initializes the newly created monitor object.

::method init /* oDESTINATION */
expose Destination
Destination = .queue~new
if arg(1,'E') then Destination~push (arg(1))
return

### CURRENT
Returns the current destination object.

::smethod current
expose Destination
return Destination [1]

### DESTINATION
Returns a new destination object.

::method destination /* oDESTINATION */
expose Destination
if arg(1,'E') then Destination~push (arg(1))
else Destination~pull
return Destination [1]

### UNKNOWN
Reissues or forwards to the current monitor destination all unknown messages sent to a monitor object

::method unknown
expose Destination

Extra parens needed here in original OREXX syntax

forward to destination[1] message arg(1) arguments arg(2)
return
