/*****************************************************************************/
/*                                                                           */
/*  The UNICODE Tools for ooRexx                                             */
/*  ============================                                             */
/*                                                                           */
/*  Copyright (c) 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>     */
/*                                                                           */
/*  See https://github.com/RexxLA, rexx-repository,                          */
/*      path ARB/standards/work-in-progress/unicode/UnicodeTools             */
/*                                                                           */
/*  License: Apache License 2.0 https://www.apache.org/licenses/LICENSE-2.0  */
/*                                                                           */
/*                                                                           */
/*  The UNICODE.PROPERTY class                                               */
/*  ==========================                                               */
/*                                                                           */
/*  Classes implementing concrete Unicode properties may want to subclass    */
/*  this class. It offers a set of common services, including the            */
/*  generation and loading of compressed two-stage tables to store           */
/*  property values.                                                         */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1  JMB 20230716 Initial release                                       */
/*  00.1c JMB 20230718 Move property classes to the "property" subdir        */
/*                     Move binary files to the "bin" subdir                 */
/*                     Fix some bugs, add consistency check for names        */
/*  00.1e JMB 20230721 Add persistence classes and methods                   */
/*  00.2  JMB 20230725 Rename classfile to 'properties.cls'                  */
/*                     Start working on property register                    */
/*                     Centralize list of UCD files                          */
/*                                                                           */
/*****************************************************************************/

.local~Unicode.Property = .Unicode.Property
.local~MultiStageTable  = .MultiStageTable

-- Extract our own directory, and do a directory listing.
-- Then call all the *.cls files in turn (except ourselves) to give them
-- the opportunity to register.

separator = .File~separator
Parse Source . . myself
myDir = Left(myself, LastPos(separator, myself))
Do file Over .File~new(myDir)~listFiles
  fileName = file~absolutePath
  If fileName == myself         Then Iterate
  If \filename~endsWith(".cls") Then Iterate
  Call (filename)
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
  Return myDir".."separator"UCD"separator || fileName

--
-- Binary files location method
--

::Method BinFile.Qualify Class
  Expose myself myDir separator
  Use Strict Arg fileName
  Return myDir".."separator"bin"separator || fileName

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

--
-- A codepoint has to be:
--
-- * Either 4 hex digits, or
-- * 5 or 6 hex digits, but the first one can not be zero.
--

::Method CheckCode Class
  Use Strict Arg code
  
  bad = Verify(code,"0123456789ABCDEFabcdef")
  If bad > 0 Then 
    self~SyntaxError("Codepoints should be composed only of hexadecimal digits, found '"code[bad]"'")
    
  If Length(code) < 4 | Length(code) > 6 Then
    self~SyntaxError("Codepoint length should be 4, 5 or 6 hexadecimal digits, found '"code"'")
    
  If Length(code) \== 4, code[1] == "0" Then
    self~SyntaxError("Codepoints longer than four characters cannot start with zero, found '"code"'")
    
  If X2d( code ) > X2D( 10FFFF ) Then
    self~SyntaxError("Codepoints should not be bigger than 10FFFF, found '"code"'")

/**
 * <h4>The <code>MultiStageTable</code> class</h4>
 *
 * <p>
 *   This class specializes in producing <em>two-stage tables</em>, <em>three-stage tables</em>,
 *   or, in general <em>multi-stage tables</em>. 
 *
 * <p>
 *   Multi-stage tables are recommended in The Unicode Standard 15.0 
 *  (<a href="https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf">https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf</a>),
 *   section 5.1, <em>Data Structures for Character Conversion</em>, "Multistage Tables", pp. 196&ndash;7.
 *
 * <p>
 *   This is not a general implementation of multi-stage tables, but a custom, tailored one, specific
 *   to Unicode and the BMP and SMP planes.
 *
 * <p>
 *   The indexes for these tables run from 0 to 131071. Negative values will raise a Syntax error, and
 *   indexes greater than 131071 will return "00"X.
 *
 */

::Class MultiStageTable Public

/**
 *
 * <h4><code>Compress</code></h4>
 *
 * <code><pre>
 * <b>.MultiStageTable~new(</b> <em>offset</em> <b>,</b> <em>chunks</em> , >─┬───────────────────────┬─> <b>)</b>
 *                                           └─ <b>,</b> <em>width</em> <b>,</b> <em>bigvalues</em> ─┘  
 * </pre></code>

 * <p>
 *   Creates a new multi-stage table. The <em>offset</em> and <em>chunks</em> tables should have been
 *   created by the <code>Compress</code> class method. <em>Width</em> and <em>bigvalues</em> are optional.
 *   When specified, <em>width</em> should be a positive number greater than 1, and <em>bigvalues</em>
 *   should be a string of <em>width</em>-byte values. In that case, the 1-byte value obtained from <em>offset</em> and <em>chunks</em>
 *   is multiplied by <em>width</em> and used as an index into <em>bigvalues</em>.
 *
 */ 
::Method init 
  Expose offset chunks width bigvalues
  
  Use Strict Arg offset, chunks, width = 1, bigvalues = .Nil

/**
 *
 * <h4><code>[]</code></h4>
 *
 * <code><pre>
 * <b>[</b> <em>n</em> <b>]</b></pre></code> 
 *
 * <p>
 *   Returns the <em>n</em>-th element of the multi-stage table, when 0 &lt; <em>n</em> &lt;= 131071, 
 *   or a string containing <em>width</em> copies of <b>"00"X</b>, when <em>n</em> &gt; 131071. 
 *   Negative or non-numeric values of <em>n</em> will raise a Syntax error.
 *
 */ 

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

/**
 *
 * <h4><code>Compress</code> (Class method) </h4>
 *
 * <code><pre>
 * <b>Compress(</b> <em>buffer</em> <b>)</b></pre></code> 
 *
 * <p>
 *   The <code>Compress</code> method compresses a <em>buffer</em> and returns two smaller, 
 *   compressed, tables. 
 *
 * <p>
 *   <em>Buffer</em> is a 128K-byte string (131072 bytes) representing an array of 1-byte elements.
 *   Elements 1-65536 correspond to the Unicode Basic Multilingual Plane (BMP), and elements
 *   65537-131072 correspond to the Unicode Supplementary Multilingual Plane (SMP).
 *
 * <p>
 *   The compression technique works as follows: the source array-string is supposed
 *   to be compressible, i.e., is supposed to contain different segments which are identical.
 *   The array will be broken in a series of fixed-size sub-arrays, and, instead of storing
 *   the sub-array itself, we will store <em>a reference</em> to the sub-array. Thus, when
 *   two identical sub-arrays (segments) of the argument array are found, only the first copy is
 *   stored, and a repeated reference. But a reference is supposed to be much smaller than the
 *   subarray itself.
 *
 * <p>
 *   The current implementation uses several hardcoded constants. This can be changed in the future:
 *
 *   <ul>
 *     <li>The argument <em>buffer</em> is supposed have a length of exactly 2**17 bytes.
 *     <li>Sub-arrays will be of 256 bytes.
 *     <li>To allow for maximum compression, we are supposing that the quantity of different
 *       sub-arrays does not exceed 256. This allows to store the references to the sub-arrays
 *       in one byte.
 *   </ul>
 *
 */

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

/*******************************************************************************
 *                                                                             *
 * Class PersistentStringTable                                                 *
 * ===========================                                                 *
 *                                                                             *
 * A StringTable that can be quickly saved and restored to/from a binary file. *
 *                                                                             *
 * o  Keys must all be < 256 characters in length.                             *
 * o  Values must all be strings.                                              *
 * o  Total size of the file (i.e., keys + values + overhead) must not         *
 *    exceed 2**32.                                                            *
 *                                                                             *
 ******************************************************************************/

::Class PersistentStringTable SubClass StringTable Private
::Method Save
  Use Strict arg target
  size = 4 -- To store the number of elements
  Do With Index index Item item over self
    If \item~isA(.String)  Then Raise Syntax 93.900 Additional("PersistentStringTable value cannot be saved because item at index '"index"' is not a string.")
    If Length(index) > 255 Then Raise Syntax 93.900 Additional("PersistentStringTable value cannot be saved because index '"index"' is longer that 255 characters.")
    --
    --              +---------+---------+---------+---------+
    --   0          | number of items                       |   4
    --              +---------+---------+---------+---------+
    --   4          | len1    |  5   (Length of key1)
    --              +---------+---------+         +---------+
    --   5          | key1                  ///             |   5 + len1
    --              +---------+---------+---------+---------+
    --   5 + len1   | offset of value 1                     |   5 + len1 + 4  --------------+       
    --              +---------+---------+---------+---------+                               |
    --   9 + len1   | length of value 1                     |   5 + len1 + 4 +8             |
    --              +---------+---------+---------+---------+                               | This points here 
    --   13 + len1  (structure is repeated for key2..leyn)                                  |
    --              +---------+---------+         +---------+                               |
    --   offset1    | value1                ///             |   offset1 + lenval1  <--------+           
    --              +---------+---------+         +---------+
    --              (structure is repeated for value2..valuen)
    --
    --
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