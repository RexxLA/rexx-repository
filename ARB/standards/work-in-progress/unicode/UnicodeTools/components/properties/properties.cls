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

::Options Digits 16

::Class Unicode.Property Public

-- List of UCD files

::Constant UnicodeData               "UnicodeData-15.0.0.txt"  

::Constant CompositionExclusions     "CompositionExclusions-15.0.0.txt"
::Constant DerivedCoreProperties     "DerivedCoreProperties-15.0.0.txt"
::Constant DerivedNormalizationProps "DerivedNormalizationProps-15.0.0.txt"
::Constant Emoji_data                "emoji-data-15.0.0.txt"
::Constant GraphemeBreakProperty     "GraphemeBreakProperty-15.0.0.txt"
::Constant GraphemeBreakTest         "GraphemeBreakTest-15.0.0.txt"
::Constant NameAliases               "NameAliases-15.0.0.txt"
::Constant NormalizationTest         "NormalizationTest-15.0.0.txt"
::Constant PropList                  "PropList-15.0.0.txt"
::Constant SpecialCasing             "SpecialCasing-15.0.0.txt"

--
-- Registry methods
--

::Method RegisterProperties Class
  Expose propertyRegistry propertyHandler
  
  Use Strict Arg propertyList, handler
  propertyList    = Upper( propertyList    )
  Do i = 1 To Words(propertyList)
    property = Word(propertyList, i)
    If propertyRegistry~hasIndex(property) Then
      self~SyntaxError("Property name '"property"' already registered")
    propertyRegistry[ property ] = property
    propertyHandler[  property ] = handler
  End

::Method RegisterFunctions  Class
  Expose functionRegistry
  Use Strict Arg functionList, handler
  functionList = Upper( functionList )
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
  --Return myDir".."separator"bin"separator || fileName
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

::Method "[]" Class  
  Expose propertyHandler
  Use Strict Arg name, option = "SYNTAX"
  name   = Upper( name   )
  option = Upper( option )
  Select Case option
    When "SYNTAX" Then syntax = 1
    When "NULL"   Then syntax = 0
    When ""       Then syntax = 0
    Otherwise
      Raise Syntax 93.900 Additional("Invalid option '"Arg(2)"'")
  End  
  If \propertyHandler~hasIndex(name) Then
    If \syntax Then Return ""
    Else Raise Syntax 93.900 Additional("Property '"name"' not found.")
  Return propertyHandler[name]
  
-- This will hold the enumerated values of the property

::Method Variables Class Abstract

-- A stem that maps bytes (hex-coded enums) to their corresponding symbolic names

::Attribute NameOf Class

-- Name of the binary file

::Method BinaryFile Class Abstract

::Method SyntaxError Class
  Use Strict Arg message
  Raise Syntax 98.900 Additional(message)  
