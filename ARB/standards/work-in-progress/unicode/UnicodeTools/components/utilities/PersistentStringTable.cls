/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- The PersistentStringTable class                                            --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Needed so that other classes can find it at activation time
.local~PersistentStringTable = .PersistentStringTable

::Class PersistentStringTable SubClass StringTable Public
::Method Save
  Use Strict arg target
  size = 4 -- To store the number of elements
  Do With Index index Item item over self
    If \item~isA(.String)  Then Raise Syntax 93.900 Additional("PersistentStringTable value cannot be saved because item at index '"index"' is not a string.")
    If Length(index) > 255 Then Raise Syntax 93.900 Additional("PersistentStringTable value cannot be saved because index '"index"' is longer that 255 characters.")
    size += 1 + Length(index) + 4 + 4 + Length(item)
  End
  If size > 2**32-1 Then Raise Syntax 93.900 Additional("Stringtable too big.")
  
  Call Stream target,"c","Open Write Replace"
  If result \== "READY:" Then Raise Syntax 98.920 Array(target,result)
  
  bin = .MutableBuffer~new(,size)
  
  -- Store the number of items as a 32-bit integer
  Call StoreInt32At 0, self~items
  
  offset  = 4  -- Current offset in bin
  offset. = 0  -- Offset of the different self~index values
  
  Do index Over self~allIndexes
    length = Length(index)
    Call StoreInt8At  offset, length
    offset += 1
    Call StoreStringAt offset, index
    offset += length
    offset.index = offset
    offset += 8
  End

  Do ix Over self~allIndexes
    length = Length(self[ix])
    Call StoreStringAt offset,     self[ix]
    Call StoreInt32At  offset.ix,   offset
    Call StoreInt32At  offset.ix+4, length
    offset += length
  End
  
  Call CharOut target, bin
  If result \== 0 Then 
    Raise Syntax 98.900 Additional("Not all bytes written to file '"target"';" result "bytes remaining.")
  
  Call Stream target, "c", "close"
  If result \== "READY:" Then 
    Raise Syntax 98.900 Additional("Error when closing file '"target"': '"result"'.")
  
Return

StoreInt8At:
  bin[Arg(1)+1] = X2C(D2X(Arg(2)))
Return 

StoreInt32At:
  bin[Arg(1)+1] = Right(X2C(D2X(Arg(2))),4,"00"X)  
Return 

StoreStringAt:
  bin[Arg(1)+1] = Arg(2)
Return
  
::Method Load
  Use Strict Arg source
  
  If Stream(source,"c","Query exists") = "" Then
    Raise Syntax 98.900 Additional("File '"source"' not found.")
    
  Call Stream source, "c", "Open read"
  If result \== "READY:" Then Raise Syntax 98.900 Additional("Can not open file '"source"' for reading, error was '"result"'.")
  
  size = Stream(source,"c","Query size")
  bin  = CharIn(source,1,size)
  
  Call Stream source, "c", "Close"  
  If result \== "READY:" Then 
    Raise Syntax 98.900 Additional("Error when closing file '"source"': '"result"'.")
    
  items = Int32At(0)
  offset = 4
  Do i = 1 To items
    length = Int8At(offset)
    name = StringAt(offset+1,length)
    valuePos = Int32At(1 + offset + length)
    valueLen = Int32At(1 + offset + length + 4)
    self[name] = StringAt(valuePos,valueLen)
    offset += 1 + length + 8
  End

Return

StringAt: Return bin[Arg(1)+1,Arg(2)]
Int8At:   Return bin[Arg(1)+1,1]~c2x~x2d
Int32At:  Return bin[Arg(1)+1,4]~c2x~x2d