# Built-in classes

## Notation

The built-in classes are defined mainly through code. The code refers to state variables. This is solely a
notation used in this standard.

## Object, class and method

These objects provide the basis for class structure.

### The object class

```rexx
::class object

::method new class
```

Returns a new instance of the receiver class.
```rexx
  call Config ObjectNew
  return #Outcome

::method '=='
```

_`'=='` with no argument gives a hash value in OOI._

```rexx
  call Config ObjectCompare #Receiver, #Arg.1
  if #Outcome == 'equal' then return '1
                         else return '0'
::method '<>'
  use arg a
  return \self==a

::method '><'
  forward message '<>'

::method '='
  forward message '=='

::method '\='
  forward message '<>'

::method '\=='
  forward message '<>'

::method copy
```

Returns a copy of the receiver object. The copied object has the same methods as the receiver object
and an equivalent set of object variables, with the same values.

```rexx
call Config ObjectCopy #Receiver
return #Outcome
```

_Since we have `var_empty` we could save a primitive by rendering 'new' as 'copy' plus 'empty'._

```rexx
::method defaultname
```

Returns a short human-readable string representation for the object.

```rexx
call var_value #Receiver, '#Human', '0'
return #Outcome
```

_This field would have been filled in at 'NEW' time._

```rexx
::method 'OBJECTNAMES'             /* rSTRING */
```

Sets the receiver object's name to the specified string.

```rexx
call var_set #Receiver, #ObjectName, '0', #Arg.1
return
```

_Initialized to #Human? Or ObjectName does forwarding until assigned to?_

```rexx
::method objectname
```

Returns the receiver object's name (which the `OBJECTNAME=` method sets).

```rexx
call var_value #Receiver, #ObjectName, '0'
return #Outcome

::method string
```

Returns a human-readable string representation for the object.

```rexx
return #Receiver~ObjectName

::method class
```

Returns the class object that received the message that created the object.

```rexx
call var value #Receiver, #IsA, '0'
return #Outcome

::method setmethod      /* rSTRING oSTRING/METHOD/ARRAY */
```

Adds a method to the receiver object's collection of object methods.

_Is 'object methods' what is intended; you add to a class without adding to its instance methods? Yes._

```rexx
  if #ArgExists.2 then m = Arg.2
                      else m = .NIL
  call set_var #Receiver, 'METHODS.'#Arg.1, '1', m
  return

::method hasmethod     /* rSTRING */
```

Returns 1 (true) if the receiver object has a method with the specified name (translated to uppercase);
otherwise, returns 0 (false).

_This presumably means inherited as well as `SETMETHOD` ones. What about ones set to `.NIL`?_

_Need to use the same search as for sending._

```rexx
::method unsetmethod private
```

Removes a method from the receiver object's collection of object methods.

_Use `var_drop`_

_Private means Receiver = Self check._

```rexx
::method request       /* rSTRING */
```

Returns an object of the specified class, or the `NIL` object if the request cannot be satisfied.

```rexx
t = 'MAKE'#Arg.1
if \#Receiver~hasmethod(t) then return .NIL
forward message(t) array ()

::method run private /* rMETHOD Ugh keyoptions */
```

Runs the specified method. The method has access to the object variables of the receiver object, just as
if the receiver object had defined the method by using `SETMETHOD`.

```rexx
::method startat      Undocumented?
::method start          /* rMESSAGE oArglist */
```

Returns a message object and sends it a `START` message to start concurrent processing.

```rexx
::method init
```

Performs any required object initialization.

### The class class

```rexx
::class class
```

_Lots of these methods are both class and instance. I don't know whether to list them twice._

```rexx
::method new class        /* oARGLIST */
```

Returns a new instance of the receiver class, whose object methods are the instance methods of the
class. This method initializes a new instance by running its `INIT` methods.

```rexx
::method subclass class
```

Returns a new subclass of the receiver class.

```rexx
::method subclasses class
```

Returns the immediate subclasses of the receiver class in the form of a single-index array of the required
size.

```rexx
::method define class /* rSTRING oMETHOD */
```

Incorporates the method object in the receiver class's collection of instance methods. The method name
is translated to upper case.

```rexx
::method delete
```

Removes the receiver class's definition for the method name specified.

_Builtin classes cannot be altered._

```rexx
::method method class /* rSTRING */
```

Returns the method object for the receiver class's definition for the method name given.

_Do we have to keep saying "method object" as opposed to "method" because "method name" exists?_

```rexx
::method querymixinclass
```

Returns 1 (true) if the class is a mixin class or 0 (false) otherwise.

```rexx
::method mixinclass class /* 3 of em */
```

Returns a new mixin subclass of the receiver class.

```rexx
::method inherit class /* rCLASS oCLASS */
```

Causes the receiver class to inherit the instance and class methods of the class object specified. The
optional class is a class object that specifies the position of the new superclass in the list of superclasses.

```rexx
::method uninherit class /* rCLASSOBJ */
```

Nullifies the effect of any previous `INHERIT` message sent to the receiver for the class specified.

```rexx
::method enhanced class /* rCOLLECTION oArgs */
```

Returns an enhanced new instance of the receiver class, with object methods that are the instance
methods of the class enhanced by the methods in the specified collection of methods.

```rexx
::method baseclass class
```

Returns the base class associated with the class. If the class is a mixin class, the base class is the first
superclass that is not also a mixin class. If the class is not a mixin class, then the base class is the class
receiving the `BASECLASS` message.

```rexx
::method superclasses class
```

Returns the immediate superclasses of the receiver class in the form of a single-index array of the
required size.

```rexx
::method id class
```

Returns a string that is the class identity (instance `SUBCLASS` and `MIXINCLASS` methods.)

```rexx
::method metaclass class
```

Returns the receiver class's default metaclass.

```rexx
::method methods class /* oCLASSOBJECT */
```

Returns a supplier object for all the instance methods of the receiver class and its superclasses, if no
argument is specified.

### The method class

```rexx
::class method

::method new class     /* rSTRING rSOURCE */
```

Returns a new instance of method class, which is an executable representation of the code contained in
the source.

```rexx
::method setprivate
```

Specifies that a method is a private method.

```rexx
::method setprotected

::method setsecuritymanager

::method setguarded
```

Reverses any previous `SETUNGUARDED` messages, restoring the receiver to the default guarded
status.

```rexx
::method setunguarded
```

Lets an object run a method even when another method is active on the same object. If a method object
does not receive a `SETUNGUARDED` message, it requires exclusive use of its object variable pool.

```rexx
::method source
```

Returns the method source code as a single index array of source lines.

```rexx
::method interface

::method setinterface
```

### The string class
The string class provides conventional strings and numbers.

_Some differences from REXX class of NetRexx._

```rexx
::class string

::method new class

::method '\'
```

_We can do all the operators by appeal to classic section 7._

```rexx
::method '-'
::method '-'
  use arg a
  return \a
```

_General problem of making the error message come right._

```rexx
:method '+'
:method '**'
:method '*'
:method '%'
:method '/'
:method '//'
:method ' '
:method '||'
:method '<>'
:method '><'
:method '='
:method '\='
:method '\=='
:method '=='
:method '<'
:method '>'
:method '>='
:method '/<'
:method '<='
:method '/>'
:method '<<'
:method '>>'
:method '>>='
:method '/>>'
:method '<<='
:method '\<<'
:method '&&'
:method '&'
:method abbrev

:method centre
:method center
:method changestr
:method compare
:method cppies
:method counstr
:method datatype
:method delstr
:method delword
:method insert
:method lastpos
:method left
:method length
:method overlay
:method pos
:method reverse
:method right
:method space
:method strip
:method substr
:method subword
:method translate
:method verify
:method word
:method wordindex
:method wordlength
:method wordpos
:method words
:method abs
:method format
:method max
:method min
:method sign
:method trunc
:method B2X
:method bitand
:method bitor
:method bitxor
:method C2D
:method C2X
:method D2X
::method string

::method makestring
```

### The array class

The main features of a single dimension array are provided by the configuration. This section defines
further methods and multi-dimensional arrays.

_To be done. Dimensionality set at first use. Count commas, not classic `arg()`._

```rexx
::class array

::method new class       /* 0 or more WHOLE>=0 */
```

Returns a new empty array.

```rexx
::method of class        /* 0 or more ANY */
```

Returns a newly created single-index array containing the specified value objects.

```rexx
::method put             /* rANY one or more WHOLE>0 */
```

Makes the object value a member item of the array and associates it with the specified index or indexes.

```rexx
::method ' []='          /* 1 or more WHOLE>0 */
```

This method is the same as the `PUT` method.

```rexx
::method at              /* 1 or more WHOLE>0 */
```

Returns the item associated with the specified index or indexes.

```rexx
::method '[]'            /* 1 or more WHOLE>0 */
```

Returns the same value as the AT method.

```rexx
::method remove          /* 1 or more WHOLE>0 */
```

Returns and removes the member item with the specified index or indexes from the array.

```rexx
::method hasindex        /* 1 or more WHOLE>0 */
```

Returns 1 (true) if the array contains an item associated with the specified index or indexes. Returns 0
(false) otherwise.

```rexx
::method items           /* (None) */
```

Returns the number of items in the collection.

```rexx
::method dimension       /* oWHOLE>0 */
```

Returns the current size (upper bound) of dimension specified (a positive whole number). If you omit the
argument this method returns the dimensionality (number of dimensions) of the array.

```rexx
::method size            /* (None) */
```

Returns the number of items that can be placed in the array before it needs to be extended.

```rexx
::method first           /* (None) */
```

Returns the index of the first item in the array, or the `NIL` object if the array is empty.

```rexx
::method last            /* (None) */
```

Returns the index of the last item in the array, or the `NIL` object if the array is empty.

```rexx
::method next            /* rWHOLE>O */
```

Returns the index of the item that follows the array item having the specified index or returns the `NIL`
object if the item having that index is last in the array.

```rexx
::method previous        /* rWHOLE>O */
```

Returns the index of the item that precedes the array item having index index or the `NIL` object if the item
having that index is first in the array.

```rexx
::method makearray       /* (None) */
```

Returns a single-index array with the same number of items as the receiver object. Any index with no
associated item is omitted from the new array.

Returns a new array (of the same class as the receiver) containing selected items from the receiver array.
The first item in the new array is the item corresponding to index start (the first argument) in the receiver
array.

```rexx
::method supplier        /* (None) */
```

Returns a supplier object for the collection.

```rexx
::method section        /* rWHOLE>0O oWHOLE>=0 */
```

### The supplier class

A supplier object enumerates the items a collection contained at the time of the supplier's creation.

```rexx
::class supplier

::method new class      /* rANYARRAY rINDEXARRAY */
```

Returns a new supplier object.

```rexx
::method index
```

Returns the index of the current item in the collection.

```rexx
::method next
```

Moves to the next item in the collection.

```rexx
::method item
```

Returns the current item in the collection.

```rexx
::method available
```

Returns 1 (true) if an item is available from the supplier (that is, if the `ITEM` method would return a value).
Returns 0 (false) otherwise.

### The message class
::class message

::method init class /* Ugh */

Initializes the message object for sending......

::method completed

Returns 1 if the message object has completed its message; returns 0 otherwise.
::method notify /* rMESSAGE */

Requests notification about the completion of processing for the message SEND or START sends.
::method start /* oANY */

Sends the message for processing concurrently with continued processing of the sender.
::method send /* oANY */

Returns the result (if any) of sending the message.

::method result

Returns the result of the message SEND or START sends.
