/*****************************************************************************/
/*                                                                           */
/*  The UNICODE Toys for ooRexx                                              */
/*  ===========================                                              */
/*                                                                           */
/*  Copyright (c) 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>     */
/*                                                                           */
/*  See https://github.com/RexxLA, rexx-repository,                          */
/*      path ARB/standards/work-in-progress/unicode/UnicodeToys              */
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
/*  Ver. Aut Date     Comments                                               */
/*  ---- --- -------- ------------------------------------------------------ */
/*  00.1 JMB 20230716 Initial release                                        */
/*                                                                           */
/*****************************************************************************/

::Class Unicode.Property Public

-- Common activation. Subclasses that have an "activate" class
-- method should use a self~activate:super method call at the
-- beginning of the method code.

::Attribute myself 

::Method Activate Class
  Expose myself myDir
  
  self~activate:super

  Parse Source . . myself
  myDir = Left( myself,LastPos(.File~separator,myself) )

-- Main getter method

::Method "[]" Class
  Use Strict Arg code
  Return self~nameOf[ self~hexValueOfPropertyAt( code ) ]

-- This will hold the enumerated values of the property

::Method Variables Class Abstract

-- A stem that maps bytes (hex-coded enums) to their corresponding symbolic names

::Attribute NameOf Class

::Attribute binaryString Class Get

-- Name of the UCT .txt file (has to be present "myDir" directory)

::Method UCDFile Class Abstract

-- Name of the binary file (will be stored in the "myDir" directory)

::Method BinaryFile Class Abstract

::Method Log Class
  Say "["self~myself"]" Arg(1)

::Method SyntaxError Class
  Raise Syntax 98.900 Additional(Arg(1))  

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

-- Loads the binary file into a string and returns that string
    
::Method BinaryFileContents Class
  Expose myDir binaryString
    
  binaryFile = myDir || self~binaryFile
    
  -- If the binary file does not exist, call the "generate" method.
  Call           Stream  binaryFile, "C", "Query Exists"
  If result == "" Then self~generate
  
  -- If "generate" has not created the binary file, that's an error
  Call           Stream  binaryFile, "C", "Query Exists"
  If result == "" Then self~SyntaxError("File '"binaryFile"' not found. Aborting")
  
  -- Load the contents of the binary file into a string, and return that string.
  -- No I/O error handling is done.
  
  Call           Stream  binaryFile, "C", "Open Read"
  size         = Stream( binaryFile, "C", "Query Size" )
  binaryString = CharIn( binaryFile,1,size )
  Call           Stream  binaryFile, "C", "Close"
  
Return binaryString

::Method StoreBinaryFile Class
  Expose myDir
  Use Strict Arg buffer

  binaryFile = myDir || self~binaryFile
  
  k      = -1       -- Offset of a chunk
  seen.  = 0        -- Marks a chunk as seen
  step   = 256      -- Size of the chunks
  offset = ""       -- Will store the (512) 1-byte offsets
  chunks = ""       -- Will store the deduplicated chunks

  Do i = 1 To 1FFFF~x2d + 1 By step
    chunk = buffer[i,step]
    If seen.chunk > 0 Then Do
      offset ||= Right( d2x(seen.chunk), 2, 0 )~x2c
      Iterate
    End
    k += 1
    seen.chunk = k
    offset ||= Right( d2x(k) , 2, 0)~x2c
    chunks ||= chunk
  End
  
  -- No I/O error handling
  
  Call Stream  binaryFile, "C", "Close" -- Recover if previous run crashed
  
  Call Stream  binaryFile, "C", "Open Write Replace"
  Call CharOut binaryFile, offset || chunks, 1
  Call Stream  binaryFile, "C", "Close"

Return 

