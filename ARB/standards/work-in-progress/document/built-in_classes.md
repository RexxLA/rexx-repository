# Built-in classes

## Notation

The built-in classes are defined mainly through code. The code refers to state variables. This is solely a
notation used in this standard.

## Object, class and method

These objects provide the basis for class structure.

### The object class

::class object

::method new class
Returns a new instance of the receiver class.

call Config ObjectNew
return #Outcome

::method '=='
‘==’ with no argument gives a hash value in OOI.

call Config ObjectCompare #Receiver, #Arg.1

if #Outcome == 'equal' then return '1'

else return '0'

::method '<>!'

use arg a

return \self==a

::method '><'
forward message '<>'

::method '='
forward message '=='

::method '\=!
forward message '<>'

::method '\=='
forward message '<>'

::method copy
Returns a copy of the receiver object. The copied object has the same methods as the receiver object
and an equivalent set of object variables, with the same values.

call Config ObjectCopy #Receiver

return #Outcome

Since we have var_empty we could save a primitive by rendering ‘new’ as ‘copy’ plus ‘empty’.
::method defaultname

Returns a short human-readable string representation for the object.

call var_value #Receiver, '#Human', '0'

return #Outcome

This field would have been filled in at 'NEW' time.

::method 'OBJECTNAMES' /* rvSTRING */

Sets the receiver object's name to the specified string.

call var_set #Receiver, #ObjectName, '0', #Arg.1
return

Initialized to #Human? Or ObjectName does forwarding until assigned to?

::method objectname

Returns the receiver object's name (which the OBJECTNAME= method sets).
call var_value #Receiver, #ObjectName, '0'
return #Outcome

::method string

Returns a human-readable string representation for the object.
return #Receiver~ObjectName

::method class
Returns the class object that received the message that created the object.

call var value #Receiver, #IsA, '0'
return #Outcome

::method setmethod /* rSTRING oSTRING/METHOD/ARRAY */
Adds a method to the receiver object's collection of object methods.

Is ‘object methods’ what is intended; you add to a class without adding to its instance methods? Yes.
if #ArgExists.2 then m = Arg.2

else m = .NIL
call set_var #Receiver, 'METHODS.'#Arg.1, '1', m
return
::method hasmethod /* rSTRING */

Returns 1 (true) if the receiver object has a method with the specified name (translated to uppercase);
otherwise, returns 0 (false).

This presumably means inherited as well as SETMETHOD ones. What about ones set to .NIL?

Need to use the same search as for sending.

::method unsetmethod private

Removes a method from the receiver object's collection of object methods.
Use var_drop

Private means Receiver = Self check.

::method request /* rSTRING */
Returns an object of the specified class, or the NIL object if the request cannot be satisfied.
t = 'MAKE'#Arg.1

if \#Receiver~hasmethod(t) then return .NIL
forward message(t) array ()

::method run private /* rMETHOD Ugh keyoptions */
Runs the specified method. The method has access to the object variables of the receiver object, just as
if the receiver object had defined the method by using SETMETHOD.

::smethod startat Undocumented?

::method start /* rMESSAGE oArglist */

Returns a message object and sends it a START message to start concurrent processing.
::method init

Performs any required object initialization.

### The class class
::class class

Lots of these methods are both class and instance. | don't know whether to list them twice.
::method new class /* OARGLIST */

Returns a new instance of the receiver class, whose object methods are the instance methods of the
class. This method initializes a new instance by running its INIT methods.

::method subclass class

Returns a new subclass of the receiver class.

::method subclasses class

Returns the immediate subclasses of the receiver class in the form of a single-index array of the required
size.

::method define class /* rSTRING oMETHOD */

Incorporates the method object in the receiver class's collection of instance methods. The method name
is translated to upper case.

::method delete

Removes the receiver class's definition for the method name specified.

Builtin classes cannot be altered.

::method method class /* rSTRING */

Returns the method object for the receiver class's definition for the method name given.

Do we have to keep saying "method object" as opposed to "method" because "method name" exists?
::method querymixinclass

Returns 1 (true) if the class is a mixin class or 0 (false) otherwise.

::method mixinclass class /* 3 of em */

Returns a new mixin subclass of the receiver class.

::method inherit class /* rCLASS oCLASS */

Causes the receiver class to inherit the instance and class methods of the class object specified. The

optional class is a class object that specifies the position of the new superclass in the list of superclasses.
::method uninherit class /* rCLASSOBJ */

Nullifies the effect of any previous INHERIT message sent to the receiver for the class specified.
::smethod enhanced class /* rCOLLECTION oArgs */

Returns an enhanced new instance of the receiver class, with object methods that are the instance

methods of the class enhanced by the methods in the specified collection of methods.
::method baseclass class

Returns the base class associated with the class. If the class is a mixin class, the base class is the first
superclass that is not also a mixin class. If the class is not a mixin class, then the base class is the class
receiving the BASECLASS message.

::method superclasses class
Returns the immediate superclasses of the receiver class in the form of a single-index array of the

required size.
::method id class

Returns a string that is the class identity (instance SUBCLASS and MIXINCLASS methods.)

::method metaclass class

Returns the receiver class's default metaclass.
::method methods class /* oCLASSOBJECT */

Returns a supplier object for all the instance methods of the receiver class and its superclasses, if no
argument is specified.
### The method class

::class method

::method new class /* rSTRING rSOURCE */
Returns a new instance of method class, which is an executable representation of the code contained in

the source.
::method setprivate

Specifies that a method is a private method.
::method setprotected

::method setsecuritymanager

::method setguarded
Reverses any previous SETUNGUARDED messages, restoring the receiver to the default guarded

status.
::method setunguarded

Lets an object run a method even when another method is active on the same object. If a method object

does not receive a SETUNGUARDED message, it requires exclusive use of its object variable pool.
::method source

Returns the method source code as a single index array of source lines.
::method interface

::method setinterface

11.3 The string class
The string class provides conventional strings and numbers.

Some differences from REXX class of NetRexx.
::class string

::method new class

::method '\'
We can do all the operators by appeal to classic section 7.
::method '-'
::method '-'

use arg a
return \a
General problem of making the error message come right.

:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method

:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method
:method

All

centre
center
changestr
compare
copies
counstr
datatype
delstr
delword
insert
lastpos
left
length
overlay
pos
reverse
right
space
strip
substr
subword
translate
verify
word
wordindex
wordlength
wordpos
words
abs
format
max

min

sign
trunc
B2x
bitand
bitor
bitxor
C2D

C2x

D2xX
::smethod D2C
::smethod X2B
::smethod X2C
::smethod X2D
::method string

::method makestring
### The array class

The main features of a single dimension array are provided by the configuration. This section defines
further methods and multi-dimensional arrays.

To be done. Dimensionality set at first use. Count commas, not classic arg().

::class array

::method new class /* 0 or more WHOLE>=0 */

Returns a new empty array.

::method of class /* 0 or more ANY */

Returns a newly created single-index array containing the specified value objects.
::method put /* rANY one or more WHOLE>0 */

Makes the object value a member item of the array and associates it with the specified index or indexes.
::method ' []=' /* 1 or more WHOLE>0O */

This method is the same as the PUT method.

::method at /* 1 or more WHOLE>0O */

Returns the item associated with the specified index or indexes.

::method '[]' /* 1 or more WHOLE>0O */

Returns the same value as the AT method.

::method remove /* 1 or more WHOLE>0O */

Returns and removes the member item with the specified index or indexes from the array.
::method hasindex /* 1 or more WHOLE>0O */

Returns 1 (true) if the array contains an item associated with the specified index or indexes. Returns 0
(false) otherwise.

::method items /* (None) */
Returns the number of items in the collection.
::method dimension /* OWHOLE>0O */

Returns the current size (upper bound) of dimension specified (a positive whole number). If you omit the
argument this method returns the dimensionality (number of dimensions) of the array.

::method size /* (None) */

Returns the number of items that can be placed in the array before it needs to be extended.

::method first /* (None) */

Returns the index of the first item in the array, or the NIL object if the array is empty.

::method last /* (None) */

Returns the index of the last item in the array, or the NIL object if the array is empty.

::method next /* rcWHOLE>O */

Returns the index of the item that follows the array item having the specified index or returns the NIL
object if the item having that index is last in the array.

::method previous /* rcWHOLE>O */

Returns the index of the item that precedes the array item having index index or the NIL object if the item
having that index is first in the array.

::method makearray /* (None) */

Returns a single-index array with the same number of items as the receiver object. Any index with no
associated item is omitted from the new array.

Returns a new array (of the same class as the receiver) containing selected items from the receiver array.
The first item in the new array is the item corresponding to index start (the first argument) in the receiver

array.
::method supplier /* (None) */
Returns a supplier object for the collection.
::method section /* rcWHOLE>0O oOWHOLE>=0 */

## The supplier class

A supplier object enumerates the items a collection contained at the time of the supplier's creation.
::class supplier

::method new class /* rANYARRAY rINDEXARRAY */
Returns a new supplier object.

::method index

Returns the index of the current item in the collection.
::method next

Moves to the next item in the collection.

::method item

Returns the current item in the collection.

::method available

Returns 1 (true) if an item is available from the supplier (that is, if the ITEM method would return a value).
Returns 0 (false) otherwise.

11.5 The message class
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