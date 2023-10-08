/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/


/**
 *
 *  The UNICODE.PROPERTY class
 *  ==========================
 *                                                                           
 *  <p>See /doc/properties.md for documentation
 *
 *  Version history                                                          
 *  ===============                                                          
 *                                                                           
 *  Vers. Aut Date     Comments                                              
 *  ----- --- -------- -----------------------------------------------------  
 *  00.1  JMB 20230716 Initial release                                       
 *  00.1c JMB 20230718 Move property classes to the "property" subdir        
 *                     Move binary files to the "bin" subdir                 
 *                     Fix some bugs, add consistency check for names        
 *  00.1e JMB 20230721 Add persistence classes and methods                   
 *  00.2  JMB 20230725 Rename classfile to 'properties.cls'                  
 *                     Start working on property register                    
 *                     Centralize list of UCD files                          
 *  00.4a JMB 20231002 Move docs to properties/readme.md                     
 *  00.4b JMB 20231005 Move docs to components/properties.md                     
 *                     Move individual property files to components/properties/
 *                     Rename to properties.cls
 *                                                                           
 */

.local~Unicode.Property = .Unicode.Property
.local~MultiStageTable  = .MultiStageTable

-- Extract our own directory, and do a directory listing of its "properties"
-- subdir. Call all the *.cls files in turn to give them the opportunity 
-- to register.

separator = .File~separator
Parse Source . . myself
myDir = Left(myself, LastPos(separator, myself))
Do file Over .File~new(myDir"properties")~listFiles
  fileName = file~absolutePath
  If filename~endsWith(".cls") Then Call (filename)
End

::Options Digits 16

::Class Unicode.Property Public

-- List of UCD files

::Constant UnicodeData               "UnicodeData-15.0.0.txt"  
::Constant DerivedCoreProperties     "DerivedCoreProperties-15.0.0.txt"
::Constant DerivedNormalizationProps "DerivedNormalizationProps-15.0.0.txt"
::Constant Emoji_data                "emoji-data-15.0.0.txt"
::Constant GraphemeBreakProperty     "GraphemeBreakProperty-15.0.0.txt"
::Constant GraphemeBreakTest         "GraphemeBreakTest-15.0.0.txt"
::Constant NameAliases               "NameAliases-15.0.0.txt"
::Constant PropList                  "PropList-15.0.0.txt"
::Constant SpecialCasing             "SpecialCasing-15.0.0.txt"

--
-- Registry methods
--

::Method RegisterProperties Class
  Expose propertyRegistry propertyHandler
  Use Strict Arg propertyList, propertyAliases, handler
  Do i = 1 To Words(propertyList)
    property = Word(propertyList, i)
    If propertyRegistry~hasIndex(property) Then
      self~SyntaxError("Property name '"property"' already registered")
    propertyRegistry[ property ] = property
    propertyHandler[  property ] = handler
  End
  Do i = 1 To Min( Words(propertyList), Words(propertyAliases) )
    property = Word(propertyList, i)
    alias    = Word(propertyAliases, i)
    If alias == "=" Then Iterate
    If propertyRegistry~hasIndex(alias) Then
      self~SyntaxError("Property name '"alias"' already registered")
    propertyRegistry[ alias ] = property
    propertyHandler[  alias ] = handler
  End

::Method RegisterFunctions  Class
  Expose functionRegistry
  Use Strict Arg functionList, handler
  Do function Over Upper(functionList)~makeArray(" ")
    If functionRegistry~hasIndex(function) Then
      self~SyntaxError("Function '"function"' already registered")
    functionRegistry[ function ] = handler
  End

--
-- Persistence methods
--

::Method getPersistent Class 
  Expose persistentStore
  Use Strict Arg key
  Return persistentStore[key]
  
::Method setPersistent Class   
  Expose persistentStore
  Use Strict Arg key, value
  persistentStore[key] = value

::Method loadPersistent Class 
  Expose persistentStore
  Use Strict Arg source
  persistentStore~load(source)  
  
::Method savePersistent Class 
  Expose persistentStore
  Use Strict Arg target
  persistentStore~save(target)  

--
-- UCD file location method
--

::Method UCDFile.Qualify Class
  Expose myself myDir separator
  Use Strict Arg fileName
  Return myDir"UCD"separator || fileName

--
-- Binary files location method
--

::Method BinFile.Qualify Class
  Expose myself myDir separator
  Use Strict Arg fileName
  --Return myDir".."separator"bin"separator || fileName
  Return myDir"bin"separator || fileName

-- Common activation. Subclasses that have an "activate" class
-- method should use a self~activate:super method call at the
-- beginning of the method code.

::Method Activate Class
  Expose myself myDir separator persistentStore propertyHandler propertyRegistry functionRegistry
  
  persistentStore  = .PersistentStringTable~new
  propertyHandler  = .Directory~new
  propertyRegistry = .Directory~new
  functionRegistry = .Directory~new
  
  self~activate:super

  separator = .File~separator
  Parse Source . . myself
  myDir = Left( myself,LastPos( separator, myself ) )

-- Main getter method

::Method "[]" Class
  Use Strict Arg code
  Return self~nameOf[ self~hexValueOfPropertyAt( code ) ]

-- This will hold the enumerated values of the property

::Method Variables Class Abstract

-- A stem that maps bytes (hex-coded enums) to their corresponding symbolic names

::Attribute NameOf Class

-- Name of the binary file

::Method BinaryFile Class Abstract

::Method SyntaxError Class
  Use Strict Arg message
  Raise Syntax 98.900 Additional(message)  

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- The MultiStageTable class                                                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


::Class MultiStageTable Public

::Method init 
  Expose offset chunks width bigvalues
  
  Use Strict Arg offset, chunks, width = 1, bigvalues = .Nil

::Method "[]"
  Expose offset chunks width bigvalues
  
  Use Strict Arg n
  
  .Validate~nonNegativeNumber("n",n)
  
  If n > 131071 Then Return Copies("00"X,width)
  
  
  highIndex  = n  % 256
  highOffset = offset[ 1 + highIndex ]~c2x~x2d
  lowOffset  = n // 256
  byte       = chunks[ 1 + highOffset*256 + lowOffset ]
  
  -- width == 1 is the two-stage case
  If width == 1 Then Return byte
  
  Return       bigvalues[ 1 + (byte~c2x~x2d - 1) * width, width]

::Method Compress Class
  Use Strict Arg buffer
  
  k       = -1       -- Offset of a chunk
  offset. = 0        -- Stores the offset of a chunk. 0 when the chunk was never seen.
  step    = 256      -- Size of the chunks
  offset  = ""       -- Will store the (512 = 128K/256) 1-byte offsets
  chunks  = ""       -- Will store the deduplicated chunks

  Do i = 0 + 1 To 1FFFF~x2d + 1 By step  -- U+0000..U+1FFFF
    chunk = buffer[i,step]               -- Pick a chunk of "step" bytes     
    If offset.chunk > 0 Then Do          -- Already seen? offset.chunk will store the offset
      offset ||= Right(D2X(offset.chunk),2,0)~x2c
      Iterate
    End
    k += 1                               -- Never seen: we need a new offset for that
    offset.chunk = k
    offset ||= Right( d2x(k) , 2, 0)~x2c 
    chunks ||= chunk                     -- Store the new chunk
  End
  If k > 255 Then Say "Warning!" k "chunks when compressing file!"
  Else Say "Compressing two-stage table into" k "256-byte fragments, total =" (Length(offset)+Length(chunks)) "bytes ."
  
Return offset, chunks

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- The PersistentStringTable class                                            --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

::Class PersistentStringTable SubClass StringTable Private
::Method Save
  Use Strict arg target
  size = 4 -- To store the number of elements
  Do With Index index Item item over self
    If \item~isA(.String)  Then Raise Syntax 93.900 Additional("PersistentStringTable value cannot be saved because item at index '"index"' is not a string.")
    If Length(index) > 255 Then Raise Syntax 93.900 Additional("PersistentStringTable value cannot be saved because index '"index"' is longer that 255 characters.")
    size += 1 + Length(index) + 4 + 4 + Length(item)
  End
  If size > 3**32-1 Then Raise Syntax 93.900 Additional("Stringtable too big.")
  
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