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
 * <h3><code>Unicode.cls</code>: The main Unicode Tools Of Rexx file</h3>
 *
 * <p>This classfile offers a set of public routines and classes that implement
 *   the basic architecture of The Unicode Tools Of Rexx (TUTOR).
 *   Please refer to 
 *   <a href="https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/built-in.md">https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/built-in.md</a>
 *   and to 
 *   <a href="https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/new-functions.md">https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/new-functions.md</a>
 *   for documentation and examples.
 *
 *  <h4>Version history</h4>
 *  
 *  <table class="table">
 *    <tr><th>Ver. <th>Aut.<th>Date    <th>Description
 *    <tr><td>00.1 <td>JMB <td>20230716<td>Initial release                                       
 *    <tr><td>00.1c<td>JMB <td>20230718<td>Move property classes to the "property" subdir        
 *                     Fix some bugs, add consistency check for names       
 *    <tr><td>00.1d<td>JMB <td>20230719<td>Add support for many !-BIfs
 *    <tr><td>00.1e<td>JMB <td>20230721<td>Add support for LOWER, !LOWER
 *    <tr><td>00.1f<td>JMB <td>        <td>Add support for UPPER, !UPPER
 *    <tr><td>00.2 <td>JMB <td>20230725<td>Extensive refactoring. Move Bytes.cls, Runes.cls and Text.cls to Unicode.cls.
 *                                         <br>Implement OPTIONS CONVERSIONS for some ops and BIFs
 *    <tr><td>00.2a<td>JMB <td>20230727<td>Add format=("","U+","NAMES") for C2U.
 *                                         <br>CODEPOINTS now checks for correct UTF-8.
 *                                         <br>Change RUNES to CODEPOINTS, and ALLRUNES to C2U
 *    <tr><td>00.3 <td>JMB <td>20230811<td>Move utf-8 and -16 code to the "encodings" subdir, implement general interface to encodings.
 *                                         <br>Remove code for OPTIONS CONVERSIONS.
 *                                         <br>Add C2U("UTF32") option
 *                                         <br>Implement !STREAM and !LINEIN
 *                                         <br>Rename P2U to C2U.
 *                                         <br>ADD U2C to BYTES (and, by extension, to CODEPOINTS and TEXT)
 *                                         <br>DATATYPE BIM extended to accept "C" (for "uniCode") strings (the contents of a "U" string).
 *                                         <br>Implement !CHARIN
 *                                         <br>Move STREAM !BIFs to <a href="Stream.cls.html">Stream.cls</a>
 *    <tr><td>00.3a<td>JMB <td>20230815<td>New DECODE(string[, errorhandling]) BIF
 *    <tr><td>00.4 <td>JMB <td>20230901<td>General support for OPTIONS instruction via !Options routine
 *    <tr><td>     <td>JMB <td>20230912<td>Re-add OPTIONS COERCIONS support
 *    <tr><td>     <td>JMB <td>20230917<td>Migrate most of the docs to markdown format (see rxu.md and the /docs subdir)
 *    <tr><td>00.5 <td>JMB <td>20231001<td>Add GRAPHEMES class and BIF, isNFC, isNFD, toNFD, toNFD, CHANGESTR.
 *    <tr><td>     <td>JMB <td>20240128<td>!!DS -> !DS
 *    <tr><td>     <td>JMB <td>20240128<td>Defaultstring and promote can be set by caller
 *    <tr><td>     <td>JMB <td>20240128<td>Make TEXT the default string
 *  </table>
 */

.local~bytes                 = .Bytes       -- Make sure .Bytes is known everywhere
.local~codepoints            = .Codepoints  -- Make sure .Codepoints is known everywhere
.local~graphemes             = .Graphemes   -- Make sure .Graphemes is known everywhere
.local~text                  = .Text        -- Make sure .Text is known everywhere

--------------------------------------------------------------------------------
-- Support for OPTIONS DEFAULTSTRING                                          --
--------------------------------------------------------------------------------

-- When nothing is specified, default is "Text".
If .local~Unicode.DefaultString~isNil Then
  .local~Unicode.DefaultString = "Text"

--------------------------------------------------------------------------------
-- Support for OPTIONS COERCIONS                                              --
--------------------------------------------------------------------------------

-- When nothing is specified, default is "Promote".
If .local~Unicode.Coercions~isNil Then
  .local~Unicode.Coercions = "Promote"

.local~Unicode = .routines~Unicode

Call "components/utilities/MultiStageTable.cls"
Call "components/utilities/PersistentStringTable.cls"
Call "components/properties/properties.cls"
Call "components/properties/case.cls"
Call "components/properties/gc.cls"
Call "components/properties/gcb.cls"
Call "components/properties/name.cls"
Call "components/properties/normalization.cls"


/**
 *
 *  <h4>Support for the OPTIONS instruction</h4>
 *
 *  <p>
 *    Routine <code>!Options</code> provides support for the <code>RXU</code>
 *    <code>OPTIONS</code> instructions extensions.
 */

::Routine !Options Public
  Arg string
  
  Do i = 1 To Words(string) - 1
    Select Case Space( SubWord(string,i,2) )
      When "DEFAULTSTRING BYTES"      Then .local~Unicode.DefaultString = "Bytes"
      When "DEFAULTSTRING CODEPOINTS" Then .local~Unicode.DefaultString = "Codepoints"
      When "DEFAULTSTRING TEXT"       Then .local~Unicode.DefaultString = "Text"
      When "DEFAULTSTRING GRAPHEMES"  Then .local~Unicode.DefaultString = "Graphemes"
      When "DEFAULTSTRING NONE"       Then .local~Unicode.DefaultString = ""
      When "COERCIONS NONE"           Then .local~Unicode.Coercions     = "None"
      When "COERCIONS LEFT"           Then .local~Unicode.Coercions     = "Left"
      When "COERCIONS RIGHT"          Then .local~Unicode.Coercions     = "Right"
      When "COERCIONS DEMOTE"         Then .local~Unicode.Coercions     = "Demote"
      When "COERCIONS PROMOTE"        Then .local~Unicode.Coercions     = "Promote"
      Otherwise Nop
    End
  End

/**
 *
 *  <h4>Support for unsuffixed strings</h4>
 *
 *  <p>
 *    An unsuffixed "string" will be translated to "(!DS(string))" by the preprocessor.
 */
 
::Routine !DS Public
  Use Strict Arg string
  Select Case Upper(.Unicode.DefaultString)
    When "BYTES"      Then Return Bytes(string)
    When "CODEPOINTS" Then Return Codepoints(string)
    When "GRAPHEMES"  Then Return Graphemes(string)
    When "TEXT"       Then Return Text(string)
    When "NONE",""    Then Return String
    Otherwise              Return String -- Should not happen
  End

-- This routine is a skeleton. It will grow considerably when we'll have
-- finished the properties infrastructure 

::Routine Unicode Public
  Use Arg , option
  option = Upper( option )
  Select
    When option == "PROPERTY"    Then Signal Properties
    When option == "ISNFD"       Then Do
      Use Strict Arg string, option
      If \string~isA(.Codepoints) Then string = Codepoints(string)
      Return string~isNFD    
    End
    When option == "ISNFC"       Then Do
      Use Strict Arg string, option
      If \string~isA(.Codepoints) Then string = Codepoints(string)
      Return string~isNFC    
    End
    Otherwise                         Signal Functions
  End
    
Functions:
  Use Strict Arg string, function
  function = Upper(function)
  handler  = .Unicode.Property~FunctionHandlerFor(function,"SYNTAX")
  Return handler~send(function, string)

Properties:
  Use Strict Arg code, option, property
    
  If code~startsWith("00"X) Then 
    If Length(code) \== 4 Then 
      Raise Syntax 40.900 Additional("Invalid code '"C2X(code)"'X")
    Else code = SubStr(C2X(code),3)
  Else Do
    code = Upper( code )
    If \DataType(code,"X") | Length(code) > 6 Then
      Raise Syntax 40.900 Additional("Invalid code '"code"'")
  End
  
  code = Strip(code,"L",0)
  If Length(code) < 4 Then code = Right(code,4,0)

  If X2D(code) > 1114111 Then 
    Raise Syntax 40.900 Additional("Invalid code '"code"'")
    
  property = Upper( property )
  
  array = .Unicode.Property[property, "SYNTAX"]
  
  Return array[1]~send(array[2], code)
  
::Routine N2P Public
  Use Strict Arg name
  Return .Unicode.Name~n2p( name )

::Routine P2N Public
  Use Strict Arg code
  Return Unicode(code, "Property", "Name")
  --Return .Unicode.Name~Name( code )

::Routine STRINGTYPE Public
  Use Strict Arg string, option = ""
  .Validate~classType( "option" , option , .String )
  option = Upper(option)
  Select
    When Abbrev("BYTES",      option,1) Then Return self~stringType == "BYTES"
    When Abbrev("CODEPOINTS", option,1) Then Return self~stringType == "CODEPOINTS"
    When Abbrev("GRAPHEMES",  option,1) Then Return self~stringType == "GRAPHEMES"
    When Abbrev("TEXT",       option,1) Then Return self~stringType == "TEXT"
    Otherwise 
      If option \== "" Then
        Raise Syntax 40.900 Additional("Invalid option '"Arg(2)"'")
  End
  Select
    When string~isA(.Text)       Then Return "TEXT"
    When string~isA(.Graphemes)  Then Return "GRAPHEMES"
    When string~isA(.Codepoints) Then Return "CODEPOINTS"
    When string~isA(.String)     Then Return "BYTES"
    Otherwise                         Return "NONE"
  End

::Routine BYTES Public
  Use Strict Arg string
  return .Bytes~new(string)

::Routine CODEPOINTS Public
  Use Strict Arg string
  Return .Codepoints~new(string)

::Routine C2U Public  
  Use Strict Arg string, format=""
  Return string~C2U(format)   
         
::Routine DECODE Public  
  Use Strict Arg string, encoding, format="", errorHandling=""
  Return .Encoding[encoding]~decode(string, format, errorHandling)  
  
::Routine ENCODE Public  
  Use Strict Arg string, encoding, errorHandling=""
  Return .Encoding[encoding]~encode(string, errorHandling)  

::Routine GRAPHEMES Public
  Use Strict Arg string
  Return .Graphemes~new(string)
  
::Routine TEXT Public
  Use Strict Arg string
  Return .Text~new(string)
     
::Routine !C2X Public
  Use Strict Arg string
Return string~c2x

::Routine !CENTER Public
  Use Strict Arg string, length, pad = " "
Return string~center(length, pad)  

::Routine !CENTRE Public
  Use Strict Arg string, length, pad = " "
Return string~centre(length, pad)  

::Routine !CHANGESTR Public
  Use Strict Arg needle, haystack, newneedle, ...
  If Arg() > 4 Then Raise Syntax 40.4 Array("CHANGESTR",4)
  If Arg(4,"O") Then 
    Return haystack~changestr(needle, newneedle)  
  Else
    Return haystack~changestr(needle, newneedle, Arg(4))  

::Routine !COPIES Public
  Use Strict Arg string, n
Return string~copies(n)

::Routine !DATATYPE Public
  If Arg() > 2       Then Raise Syntax 40.4 Array("DATATYPE", 2)
  If Arg(1,"O") == 1 Then Raise Syntax 40.5 Array("DATATYPE", 1)
  If Arg(2,"O")      Then Return DataType(Arg(1))
  Use Arg string, type
  If Upper(type,1) \== "C" Then Return DataType(string, type)
  If \string~isA(.Bytes) Then string = .Bytes~new(string)
Return string~dataType("C")

::Routine !LEFT Public
  Use Strict Arg string, length, pad = " "
Return string~left(length, pad)

::Routine !LENGTH Public
  Use Strict Arg string
Return string~length

::Routine !LOWER Public
  Use Strict Arg string, n = 1, length = (Max(!Length(string) - n + 1,0))
Return string~lower(n, length)

::Routine !POS Public
  Use Strict Arg needle, haystack, start = 1, length = ( Max(!Length(haystack)-start+1,0) )
Return haystack~Pos(needle, start, length)  

::Routine !REVERSE Public
  Use Strict Arg string
Return string~reverse

::Routine !RIGHT Public
  Use Strict Arg string, length, pad = " "
Return string~right(length, pad)

::Routine !SUBSTR Public
  Use Strict Arg string, n, length = (Max(!Length(string)-n+1,0)), pad = " "
Return string~substr(n, length, pad)

::Routine !UPPER Public
  Use Strict Arg string, n = 1, length = (Max(!Length(string) - n + 1,0))
Return string~upper(n, length)

--------------------------------------------------------------------------------    
-- The BYTES class                                                            --
--------------------------------------------------------------------------------    

::Class "Bytes" SubClass String Public

-- Please refer to https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/classes.md
-- for documentation details

::Method C2U
  Use Strict Arg format=""

  utf32 = UTF8(self,"UTF-8","UTF32","Syntax")
    
  uFormat = Upper(format)
  If uFormat == "UTF32" Then Return utf32
  
  LUtf32 = Length(utf32)
  
  codes = .Array~new( LUtf32 / 4 )
  
  Do i = 1 To LUtf32 By 4
    code = Strip(C2X(utf32[i,4]),"L",0)
    If Length(code) < 4 Then code = Right(code, 4, 0)
    codes~append(code)
  End
  
  Select
    When format = "" Then Return codes~makeString("L", " ")
    When uFormat == "U+" Then Return "U+"codes~makeString("L", " U+")
    When Abbrev("NAMES",uFormat,2) Then Signal Names
    Otherwise Raise Syntax 88.900 Additional("Invalid format '"format"'")
  End
  
Names:  
  res = ""
  Do i = 1 To codes~items
    res ||= " ("P2N(codes[i])")"
  End
  Return Strip(res,"L")
 
::Method U2C
  -- We want to operate on bytes
  contents = self~makeString
  res = ""
  Do While contents \= " "
    contents = Strip(contents)
    If contents[1] == "(" Then Do
      Parse var contents "("name")"extra
      If extra == "" Then If \contents~endsWith(")") Then Signal BadParenthesis
      contents = Strip(extra)
      word = N2P(name)
      If word = "" Then Signal BadName
    End
    Else Do
      Parse Var contents word contents
      If Upper(word) == "U+"         Then Signal BadCodepoint
      If Upper(Left(word,2)) == "U+" Then word = SubStr(word,3)
      If \DataType(word,"X")         Then Signal BadCodepoint
      If X2D(word) >  X2D(10FFFF)    Then Signal BadCodepoint
      If X2D(word) >= X2D(D800),,
         X2D(word) <= X2D(DFFF)      Then Signal BadCodepoint
    End
    res ||= UTF8(word)
  End
Return res

BadParenthesis:
  Raise Syntax 22.900 Additional("Unmatched parenthesis in Unicode name")
BadName:
  Raise Syntax 22.900 Additional("Invalid Unicode name '"name"'")
BadCodepoint:
  Raise Syntax 22.900 Additional("Invalid Unicode codepoint '"word"'")
  
UTF8: Procedure
  Use Arg code
  If code~length < 4 Then code = Right(code,4,0)
  Do While code~length > 4, code[1] == 0
    code = Substr(code,2)
  End
  n = X2D(code)
  b = X2B(code)
  If b~length == 20 Then b = "0000"||b
  If b~length == 8, n >= 128 Then b = "0000"||b
  Select
    When n <= 127   Then Return X2C(code[3,2])
    When n <= 2047  Then Return X2C(B2X("110"SubStr(b,6,5)"10"Right(b,6)))
    When n <= 65535 Then Return X2C(B2X("1110"Left(b,4)"10"SubStr(b,5,6)"10"Right(b,6)))
    Otherwise            Return X2C(B2X("11110"SubStr(b,4,3) "10"SubStr(b,7,6) "10"SubStr(b,13,6) "10"Right(b,6)))
  End 

--------------------------------------------------------------------------------
-- Implementation of automatic implicit coercions (OPTIONS COERCIONS)         --
--------------------------------------------------------------------------------

::Method coerceTo Private
  Use Strict Arg string, label
  lType = StringType(self  )
  rType = StringType(string)
  Select Case Upper(.Unicode.Coercions)
    When "LEFT"   Then resultType = lType
    When "RIGHT"  Then resultType = rType
    When "DEMOTE" Then
      If      (lType == "BYTES"      | rType == "BYTES")      Then resultType = "BYTES"
      Else If (lType == "CODEPOINTS" | rType == "CODEPOINTS") Then resultType = "CODEPOINTS"
      Else If (lType == "GRAPHEMES"  | rType == "GRAPHEMES")  Then resultType = "GRAPHEMES"
      Else                                                         resultType = "TEXT"
    When "PROMOTE" Then
      If      (lType == "TEXT"       | rType == "TEXT")       Then resultType = "TEXT"
      Else If (lType == "GRAPHEMES"  | rType == "GRAPHEMES")  Then resultType = "GRAPHEMES"
      Else If (lType == "CODEPOINTS" | rType == "CODEPOINTS") Then resultType = "CODEPOINTS"
      Else                                                         resultType = "BYTES"
    When "NONE" Then
      If lType \== rType Then 
         Raise Syntax 88.900 Additional("Cannot combine a" lType "string and a" rType "string in" label "operation")
      Else resultType = lType
  End
  Select
    When resultType == "TEXT"       Then Return .Text  
    When resultType == "GRAPHEMES"  Then Return .Graphemes
    When resultType == "BYTES"      Then Return .Bytes
    When resultType == "CODEPOINTS" Then Return .Codepoints
  End

::Method "||"
  Use Strict Arg string
  class = self~coerceTo(string,"a concatenation")
  value = self~"||":.String(string)
  Return class~new(value)

::Method ""
  Use Strict Arg string
  class = self~coerceTo(string,"a concatenation")
  value = self~"":.String(string)
  Return class~new(value)
  
::Method " "
  Use Strict Arg string
  class = self~coerceTo(string,"a concatenation")
  value = self~" ":.String(string)
  Return class~new(value)

::Method "*"
  Use Strict Arg string
  class = self~coerceTo(string,"a multiplication")
  Return class~new(self~"*":.String(string))

::Method "/"
  Use Strict Arg string
  class = self~coerceTo(string,"a division")
  Return class~new(self~"/":.String(string))

::Method "%"
  Use Strict Arg string
  class = self~coerceTo(string,"a division")
  Return class~new(self~"%":.String(string))

::Method "//"
  Use Strict Arg string
  class = self~coerceTo(string,"a remainder")
  Return class~new(self~"//":.String(string))

::Method "**"
  Use Strict Arg string
  class = self~coerceTo(string,"a power")
  Return class~new(self~"**":.String(string))

::Method "+"
  If Arg() == 0 Then Return self
  Use Strict Arg string
  class = self~coerceTo(string,"an addition")
  Return class~new(self~"+":.String(string))
  
::Method "-"
  If Arg() == 0 Then Return self~class~new(0) - self
  Use Strict Arg string
  class = self~coerceTo(string,"a subtraction")
  Return class~new(self~"-":.String(string))

::Method "&"
  Use Strict Arg string
  class = self~coerceTo(string,"a logical AND")
  Return class~new(self~"&":.String(string))

::Method "|"
  Use Strict Arg string
  class = self~coerceTo(string,"an inclusive OR")
  Return class~new(self~"|":.String(string))

::Method "&&"
  Use Strict Arg string
  class = self~coerceTo(string,"an exclusive OR")
  Return class~new(self~"&&":.String(string))

::Method "\"
  Use Strict Arg
  Return self~class~new( (self~makeString == "1")~?("0","1") )

--
-- Reimplementation of many basic BIFs. Code is common to BYTES, CODEPOINTS and 
-- TEXT, and will have different effects, depending on the most basic
-- implementations of LENGTH, SUBSTR and [].
--

::Method C2X
  Use Strict Arg
  Return .Bytes~new(self~makeString~c2x)
  
::Method Center
  Use Strict Arg n, pad = " "
  .Validate~nonNegativeWholeNumber( "n" , n )
  class = self~class
  If pad~class \== class Then pad = class~new(pad)
  If pad~length > 1 Then Raise Syntax 40.023 Array("CENTER",3,pad)
  If \self~isA(.Text), \self~isA(.Graphemes), \self~isA(.Graphemes), \self~isA(.Codepoints) Then Return Bytes(self~center:.String(n,pad))
  size = self~length
  If n == size Then Return self
  If n > size Then Do
    extra = n - size
    left  = (extra) % 2
    right = (extra) % 2 + (extra // 2 = 1)
    value = Copies(pad,left) || self~makeString || Copies(pad, right)
    Return class~new( value )
  End
  left = (size - n + 1) % 2
  -- Normalization is stable under substringing
  Return self~subStr(left, n)

::Method Centre
  Forward Message (Center)
  
::Method ChangeStr
  Use Strict Arg needle, newneedle, ...
  class = self~class
  If needle~class \== class Then needle = class~new(needle)
  If Arg() > 3 Then Raise Syntax 93.902 Additional(3)
  If Arg(3, "O") Then count = self~length
  Else                Use Arg , , count
  .Validate~nonNegativeWholeNumber( "count" , count )
  If count = 0 Then Return self
  myCount = 0
  searchPos = 1
  res = .MutableBuffer~new -- Will hold the result
  Do Forever
    pos = self~pos(needle,searchPos)
    If pos == 0 Then
      If searchPos == 1 Then Return self
      Else signal Done
    res~append( self[searchPos, pos-searchPos], newNeedle )
    searchPos = pos + needle~length
    myCount += 1
    If myCount == count Then Signal Done
  End
    
Done:
  res~append( self~subStr(searchPos) )
  Return class~new( res~string)
  
::Method Copies
  Use Strict Arg n
  .Validate~nonNegativeWholeNumber( "n" , n )
  If \self~isA(.Text), \self~isA(.Graphemes), \self~isA(.Graphemes), \self~isA(.Codepoints) Then 
    Return Bytes(self~copies:.String(n))
  Return self~class~new( Copies( self~makeString, n ) )    

::Method Datatype
  If Arg() > 1 Then Raise Syntax 93.902 Array(1)
  
  If Arg() == 0 Then Return !DS(self~datatype:.String)
  
  If Arg(1) \== "C" Then Return !DS(self~datatype:.String(Arg(1)))

  no = !DS(0)
  contents = self~makeString
  Do While contents \= " "
    contents = Strip(contents)
    If contents[1] == "(" Then Do
      Parse var contents "("name")"extra
      If extra == "" Then If \contents~endsWith(")") Then Return no
      contents = Strip(extra)
      code = N2P(name)
      If code = "" Then Return no
    End
    Else Do
      Parse Var contents word contents
      If Upper(word) == "U+"         Then Return no
      If Upper(Left(word,2)) == "U+" Then word = SubStr(word,3)
      If \DataType(word,"X")         Then Return no
      If X2D(word) > X2D(10FFFF)     Then Return no
      If X2D(word) >= X2D(D800),,
         X2D(word) <= X2D(DFFF)      Then Return no
    End
  End
Return !DS(1)
  
::Method Left
  Use Strict Arg length, pad = " "
  .Validate~nonNegativeWholeNumber( "length" , length )
  If \self~isA(.Text), \self~isA(.Graphemes), \self~isA(.Codepoints) Then Return Bytes(self~left:.String(length,pad))
  class = self~class
  If \pad~isA(class) Then pad = class~new(pad)
  If pad~length \== 1 Then Raise Syntax 40.23 Array ("LEFT", 2, pad)
  If length > self~length Then 
    Return self~class~new(self||Copies(" ",length-self~length))
  -- Normalization is stable under substringing
  -- Substr will take care of class
  Return self~subStr(1,length)
    
::Method Lower
  Use Strict Arg n = 1, length = (Max(self~length - n + 1,0))
  .Validate~nonNegativeWholeNumber( "length" , length )
  .Validate~positiveWholeNumber(    "n" ,      n      )
  If \self~isA(.Text), \self~isA(.Graphemes), \self~isA(.Codepoints) Then Return Bytes(self~lower:.String(n,length))
  If length == 0     Then Return self
  If n > self~length Then Return self
  If n > 1 Then left = self[1,n-1]
  Else          left = ""
  If n = 1, length == self~length Then 
    center = .Unicode.case~toLowercase(self)
  Else
    center = .Unicode.case~toLowercase(self[n,length])
  If n+length <= self~length Then 
    right = self[n+length,self~length] -- ensure we get all the rest
  Else right = ""
  class = self~class
  If left == "" Then
    If right == "" Then 
      If self~identityHash == center~identityHash Then 
                        Return self
      Else              Return center
    Else                Return class~new( center || right )
  Else
    If right == "" Then Return class~new( left || center )
    Else                Return class~new( left || center || right )

::Method Pos
  Use Strict Arg needle, start = 1, length = (self~length - start + 1)
  If needle~class \== self~class Then needle = self~class~new(needle)
  .Validate~positiveWholeNumber(    "start" ,  start )
  .Validate~nonNegativeWholeNumber( "length" , length )
  If \self~isA(.Text), \self~isA(.Graphemes), \self~isA(.Codepoints) Then Return Bytes(self~pos:.String(needle, start, length))
  If self~length == 0    Then Return 0
  If start > self~length Then Return 0
  Do Label outer i = start By 1 While i + needle~length <= start + length
    If self[i] == needle[1] Then Do
      Do j = 2 To needle~length
        If self[i+j-1] \== needle[j] Then Iterate outer
      End
      Return i
    End
  End
  Return 0    

::Method Reverse
  ret = ""
  Do i = self~length To 1 By -1
    ret ||= self[i]
  End
  Return self~class~new(ret)

::Method Right
  Use Strict Arg length, pad = " "
  .Validate~nonNegativeWholeNumber( "length" , length )
  If \self~isA(.Text), \self~isA(.Graphemes), \self~isA(.Codepoints) Then Return Bytes(self~right:.String(length,pad))
  If pad~class \== self~class Then pad = self~class~new(pad)
  If pad~length \== 1 Then Raise Syntax 40.23 Array ("LEFT", 2, pad)
  res = ""
  If length > self~length Then 
    Return self~class~new(Copies(" ",length-self~length)||self)
  Return self~subStr(self~length - length + 1)

::Method SubStr
  .Validate~positiveWholeNumber( "n" , Arg(1) )
  Use Strict Arg n, length = (self~length - n + 1), pad = " "
  .Validate~classType( "pad" , pad , .String )
  If pad~class \== self~class Then pad = self~class~new(pad)
  If pad~length > 1 Then Raise Syntax 40.023 Array("SUBSTR",3,pad)
  If \self~isA(.Text), \self~isA(.Graphemes), \self~isA(.Codepoints) Then Return Bytes(self~subStr:.String(n,length,pad))
  max = self~length
  res = ""
  Do i = n For length
    If i <= max Then res ||= self[i]
    Else             res ||= pad
  End
  Return self~class~new(res)

::Method Upper
  Use Strict Arg n = 1, length = (Max(self~length - n + 1,0))
  .Validate~nonNegativeWholeNumber( "length" , length )
  .Validate~positiveWholeNumber(    "n" ,      n      )
  If \self~isA(.Text), \self~isA(.Graphemes), \self~isA(.Codepoints) Then Return Bytes(self~upper:.String(n,length))
  If length == 0 Then Return self
  If n > self~length Then Return self
  left = self[1,n-1]
  center = .Unicode.case~toUppercase(self[n,length])
  right = self[n+length,self~length] -- ensure we get all the rest
  Return self~class~new(left || center || right)

--------------------------------------------------------------------------------
-- The CODEPOINTS class                                                       --
--------------------------------------------------------------------------------
 
::Class "Codepoints" SubClass Bytes Public

::Method init
  Expose utf32 isNFC isNFD isNFKC isNFKD bits
    
  isNFC  = -1 -- Don't know    
  isNFD  = -1 -- Don't know    
  isNFKC = -1 -- Don't know    
  isNFKD = -1 -- Don't know    
    
  -- UTF8 will do both the validation and the conversion.
  utf32 = UTF8(self, "UTF-8", "UTF32", "Syntax")
  
  -- See Unicode Standard Annex #15, Unicode Normalization Forms. https://unicode.org/reports/tr15/ 

  -- Calculate the maximum width of a character  
  max = "0000 0000"X
  Do i = 1 To Length(utf32) By 4
    n = utf32[i,4]
    If n >> max Then max = n
    If n >> "0000FFFF"X Then Leave
  End
    
  Select
    -- "Note: Text exclusively containing ASCII characters (U+0000..U+007F) is left unaffected by all of the Normalization Forms."
    When max << "0000 0080"X Then Do
      isNFC  = 1 
      isNFD  = 1 
      isNFKC = 1 
      isNFKD = 1
      bits   = 7
    End
    -- "Text exclusively containing Latin-1 characters (U+0000..U+00FF) is left unaffected by NFC. 
    --  This is effectively the same as saying that all Latin-1 text is already normalized to NFC."
    When max << "0000 0100"X Then Do
      isNFC  = 1 
      bits   = 8
    End
    When max << "0001 0000"X Then Do
      bits   = 16
    End
    Otherwise
      bits   = 24
  End
    
::Method "[]"
  Expose utf32
  Use Strict Arg n, length = 1
  .Validate~positiveWholeNumber( "n" , n )
  .Validate~nonNegativeWholeNumber( "length" , length )
  max = self~length
  If n > max     Then Return self~class~new("")
  If length == 0 Then Return self~class~new("")
  
  If n + length - 1 > max Then length = max - n + 1
    
  Return self~class~new(.Encoding["UTF32"]~decode(SubStr(utf32, 1 + (n-1)* 4, length * 4),"UTF8","Syntax"))
  
::Method Length
  Expose utf32
  Return Length(utf32) / 4
    
::Method isNFC
  Expose isNFC utf32
    
  If isNFC \== -1 Then Return isNFC
  
  -- Try a quick check. See https://unicode.org/reports/tr15/
  
  -- TODO: Should get that value via the Unicode.properties class!
  -- TODO: Save the offending character, if any, to optimize toNFC later
  
  quick_check   = .Unicode.Case 
  normalization = .Unicode.normalization
  
  lastCCC = 0
  Do i = 1 To Length(utf32) By 4
    A = utf32[i,4]
    QC = quick_check~NFC_Quick_Check(A)
    If QC == "N" Then Signal No
    CCC = normalization~Canonical_Combining_Class(A)
    If lastCCC > CCC, CCC \== 0 Then Signal No
    If QC == "M" Then Signal Deepertest
    lastCCC = CCC
  End
Yes:  
  isNFC = 1
  Return 1
  
No:  
  isNFC = 0
  Return  0
  
DeeperTest:
  isNFC = self~"==":.String( Unicode(self, "toNFC") )
  Return isNFC
    
::Method isNFD
  Expose isNFD utf32
  If isNFD \== -1 Then Return isNFD
  
  -- Try a quick check
  -- See https://unicode.org/reports/tr15/:
  -- "There are no MAYBE values for NFD and NFKD: 
  -- the quickCheck function will always produce a definite result for these Normalization Forms".
  
  -- TODO: Should get that value via the Unicode.properties class!
  -- TODO: Save the offending character, if any, to optimize toNFD later
  
  handler = .Unicode.Case 
  Do i = 1 To Length(utf32) By 4
    n = c2x(utf32[i,4])
    QC = handler~NFD_Quick_Check(n)
    Select Case QC
      When "N" Then Do
        isNFD = 0
        Return 0
      End
      When "Y" Then Iterate
    End
  End
  handler = .Unicode.normalization
  Do i = 5 To Length(utf32) By 4
    B = utf32[i,4]
    cccB = handler~Canonical_Combining_Class(B) 
    If cccB == 0 Then Iterate
    A = utf32[i-4,4]
    cccA = handler~Canonical_Combining_Class(A) 
    If cccA > cccB Then Do
      isNFD = 0
      Return 0
    End
  End
  isNFD = 1
  Return 1  

::Method "="
  Expose isNFC
  Use Strict Arg string
  class = self~coerceTo(string,"non-strict equality")
  -- If the return should be a BYTES string, perform a normal compare
  If \class~isSubClassOf(.Codepoints) Then 
    Return class~new(self~"=":.String(string))
  -- We are returning CODEPOINTS, GRAPHEMES or TEXT. Promote string if needed
  If \string~isA(.Codepoints) Then string = class~new(string~makeString)
  
  -- Normalize the strings, if needed
  If isNFC == 1   Then left  = self
  Else                 left  = .Unicode.normalization~toNFC(self)
  If string~isNFC Then right = string
  Else                 right = .Unicode.normalization~toNFC(self)
  
  -- Now do a standard string comparison
Return class~new(left~"=":.String(right))

::Method "\="
  Use Strict Arg string
  Return \ self~"="(string)

--------------------------------------------------------------------------------
-- The GRAPHEMES class                                                        --
--------------------------------------------------------------------------------

::Class "Graphemes" SubClass Codepoints Public
  
::Method init
  Expose graphemes
  self~init:super
  graphemes = .Unicode.Grapheme_Cluster_Break~codepointsToGraphemes( self~C2U, "UTF8" )
  
::Method "[]"
  Expose graphemes
  Use Strict Arg n, length = 1
  .Validate~positiveWholeNumber( "n" , n )
  .Validate~nonNegativeWholeNumber( "length" , length )
  max = self~length
  If n > max Then Return self~class~new("")
  res = ""
  Do i = n for length While i <= max
    res ||= graphemes[i]
  End
  Return self~class~new(res)

::Method Length
  Expose graphemes
  Return graphemes~items

--------------------------------------------------------------------------------
-- The TEXT class                                                             --
--------------------------------------------------------------------------------

::Class "Text" SubClass Graphemes Public
-- Autonormalize to NFC
::Method new Class
  Use Strict Arg string
  string = Unicode(string, "toNFC")
  this = self~new:super(string)
  this~init
  Return this

--------------------------------------------------------------------------------

::Requires "utf8.cls"    
::Requires "components/stream.cls"  
::Requires "components/encoding.cls"