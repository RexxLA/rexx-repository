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
/*  Unicode.cls: the main Unicode file                                       */
/*  ==================================                                       */
/*                                                                           */
/*  This class offers a set of public Unicode routines that implement        */
/*  the basic Unicode toy architecture. Some of these routines are:          */
/*                                                                           */
/*    BYTES(string) -- Creates a new string composed of bytes                */
/*    RUNES(string) -- Creates a new string composed of runes (codepoints)   */
/*    TEXT(string)  -- Creates a new string composed of grapheme clusters    */
/*    UNICODE(code,"Property",propertyName)                                  */
/*      Thw swiss-knife Unicode BIF. It allows to map codepoints to          */
/*      Unicode properties.                                                  */
/*    ALLRUNES(string) -- Returns the set of codepoints that compose the     */
/*                     string in a standard, blank-separated format          */
/*    R2N(code)     -- Rune To Name: returns the Unicode Name property       */
/*    N2R(name)     -- Name To Rune: transforms a Unicode name or alias      */
/*                                   into a normalized codepoint             */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Ver.  Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1  JMB 20230716 Initial release                                       */
/*  00.1c JMB 20230718 Move property classes to the "property" subdir        */
/*                     Fix some bugs, add consistency check for names        */
/*  00.1d JMB 20230719 Add support for many !-BIfs                           */
/*  00.1e JMB 20230721 Add support for LOWER, !LOWER                         */
/*  00.1f JMB          Add support for UPPER, !UPPER                         */
/*  00.2  JMB 20230725 Extensive refactoring. Move Bytes.cls, Runes.cls      */
/*                     and Text.cls to Unicode.cls.                          */
/*                     Implement OPTIONS CONVERSIONS for some ops and BIFs   */
/*                                                                           */
/*****************************************************************************/

.environment~bytes = .Bytes
.environment~runes = .Runes
.environment~text  = .Text
.environment~Unicode.Conversions  = "NONE"

::Routine Unicode Public
  Use Arg, option
  option = Upper( Strip( option ) )
  Select
    When "PROPERTY"~Abbrev(option,1) Then Signal Properties
    Otherwise Raise Syntax 88.900 Additional("Invalid option '"Arg(2)"'")
  End
    
Properties:
  Use Strict Arg code, optjon , property
  .Unicode.property~checkCode( code )
  code     = Upper( code )
  property = Space( Translate( Upper( property ),"  ","-_"), 0)
  
  Select Case property
    When "NA", "NAME" Then Do
      If .Unicode.Name == ".UNICODE.NAME" Then .Context~package~loadPackage("properties/name.cls")
      Return .Unicode.Name[ code ]
    End
    When "GC", "GENERALCATEGORY" Then 
      Return .Unicode.General_Category[ code ]
    When "GCB", "GRAPHEMECLUSTERBREAK" Then 
      Return .Unicode.Grapheme_Cluster_Break[ code ]
    When "ALGORITHMICNAME" Then -- Until we have a true NAME implementation
      Return .Unicode.General_Category~Algorithmic_Name( code )
    Otherwise Raise Syntax 88.900 Additional("Invalid property '"Arg(3)"'")
  End

::Routine N2R Public
  Use Strict Arg name
  If .Unicode.Name == ".UNICODE.NAME" Then .Context~package~loadPackage("properties/name.cls")  
  Return .Unicode.Name~n2r( name )

::Routine R2N Public
Use Strict Arg code
  If .Unicode.Name == ".UNICODE.NAME" Then .Context~package~loadPackage("properties/name.cls")  
  Return .Unicode.Name[ code ]

::Routine stringType Public
  Use Strict Arg string, option = ""
  .Validate~classType( "option" , option , .String )
  option = Upper(option)
  Select
    When Abbrev("BYTES", option,1) Then Return self~class == .String
    When Abbrev("RUNES", option,1) Then Return self~class == .Runes
    When Abbrev("TEXT",  option,1) Then Return self~class == .Text
    Otherwise Nop
  End
  Select
    When string~isA(.Text)   Then Return "TEXT"
    When string~isA(.Runes)  Then Return "RUNES"
    When string~isA(.String) Then Return "BYTES"
    Otherwise                     Return "NONE"
  End

::Routine Runes Public
  Use Strict Arg string
  Return .Runes~new(string)

::Routine Text Public
  Use Strict Arg string
  Return .Text~new(string)
  
::Routine Bytes Public
  Use Strict Arg string
  return .Bytes~new(string)
  
::Routine AllRunes Public  
  Use Strict Arg object
  Return object~allRunes  
  
/*****************************************************************************
 *                                                                           *
 * Implementation of some classic Rexx BIFs                                  *
 * ----------------------------------------                                  * 
 *                                                                           * 
 * Names are preceded with "!", like in "!Length".                           *
 * An internal routine called "Length" will be needed that calls "!Length",  * 
 * or a preprocessor that substitutes calls to "Length" by calls to          *
 * "!Length", as there is no other way to override BIFs.                     * 
 *                                                                           * 
 *****************************************************************************/ 

::Routine !C2X Public
  Use Strict Arg string
Return string~c2x

::Routine !Center Public
  Use Strict Arg string, length, pad = " "
Return string~center(length, pad)  

::Routine !Centre Public
  Use Strict Arg string, length, pad = " "
Return string~centre(length, pad)  

::Routine !Copies Public
  Use Strict Arg string, n
Return string~copies(n)

::Routine !Left Public
  Use Strict Arg string, length, pad = " "
Return string~left(length, pad)

::Routine !Length Public
  Use Strict Arg string
Return string~length

::Routine !Lower Public
  Use Strict Arg string, n = 1, length = (Max(!Length(string) - n + 1,0))
Return string~lower(n, length)

::Routine !Pos Public
  Use Strict Arg needle, haystack, start = 1, length = ( Max(!Length(haystack)-start+1,0) )
Return haystack~Pos(needle, start, length)  

::Routine !Reverse Public
  Use Strict Arg string
Return string~reverse

::Routine !Right Public
  Use Strict Arg string, length, pad = " "
Return string~right(length, pad)

::Routine !Substr Public
  Use Strict Arg string, n, length = (Max(!Length(string)-n+1,0)), pad = " "
Return string~substr(n, length, pad)

::Routine !Upper Public
  Use Strict Arg string, n = 1, length = (Max(!Length(string) - n + 1,0))
Return string~upper(n, length)

::Routine Conversions.Left
  Use Strict Arg arg1, arg2, operation  
  
  If arg1~isA(.Text)   Then Return .Text
  If arg1~isA(.Runes)  Then Return .Runes
  Return .Bytes

::Routine Conversions.Right
  Use Strict Arg arg1, arg2, operation  
  
  If arg2~isA(.Text)   Then Return .Text
  If arg2~isA(.Runes)  Then Return .Runes
  Return .Bytes

::Routine Conversions.Demote
  Use Strict Arg arg1, arg2, operation  
  
  If arg1~isA(.Text)  , arg2~isA(.Text)   Then Return .Text
  If arg1~isA(.Text)  , arg2~isA(.Runes)  Then Return .Runes
  If arg1~isA(.Runes) , arg2~isA(.Text)   Then Return .Runes
  If arg1~isA(.Runes) , arg2~isA(.Runes)  Then Return .Runes
  Return .Bytes
  
::Routine Conversions.Promote
  Use Strict Arg arg1, arg2, operation  
  
  If arg1~isA(.Text)  Then Return .Text
  If arg2~isA(.Text)  Then Return .Text
  If arg1~isA(.Runes) Then Return .Runes
  If arg2~isA(.Runes) Then Return .Runes
  Return .Bytes
  
::Routine Conversions.None
  Use Strict Arg arg1, arg2, operation  
  
  -- Order and apparent redundancy is important, since a Text 
  -- is always a Runes and a Bytes, and a Runes is always a Bytes
  
  If arg1~isA(.Text),  arg2~isA(.Text)  Then Return .Text
  If arg1~isA(.Text),  arg2~isA(.Runes) Then Signal BadOperation
  If arg1~isA(.Text),  arg2~isA(.Bytes) Then Signal BadOperation
  If arg1~isA(.Runes), arg2~isA(.Text)  Then Signal BadOperation
  If arg1~isA(.Runes), arg2~isA(.Runes) Then Return .Runes
  If arg1~isA(.Runes), arg2~isA(.Bytes) Then Signal BadOperation
  If arg1~isA(.Bytes), arg2~isA(.Text)  Then Signal BadOperation
  If arg1~isA(.Bytes), arg2~isA(.Runes) Then Signal BadOperation
  Return .Bytes -- arg1~isA(.Bytes), arg2~isA(.Bytes)
  
BadOperation:  
  Raise Syntax 88.900 Additional("Cannot combine a" StringType(arg1) "string and a" StringType(arg2) "string in a "operation" operation")
  
  
/*****************************************************************************/
/*                                                                           */
/*  The BYTES class                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  The BYTES class is fundamentally equivalent to the ooRexx built-in       */
/*  STRING class. "C" strings and unpostfixed strings (when OPTIONS          */
/*  DEFAULTSTRING BYTES is in effect) will be of this class. Having an       */
/*  explicit class (a subclass of STRING) allows us to define fine-grained   */
/*  rules about BIF or operation results for mixed-type classes.             */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*        JMB 20230716 Initial release                                       */
/*                                                                           */
/*****************************************************************************/

::Class "Bytes" SubClass String Public

::Method "||" 
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "concatenation"
  Return result~new(self~"||":super(argument))
  
NoConcat:  
  Raise Syntax 88.900 Additional("Cannot concatenate a" StringType(argument) "string and a" StringType(self) "string")

--
-- Reimplementation of many basic BIFs. Code is common to BYTES, RUNES and 
-- TEXT, and will have different effects, depending on the most basic
-- implementations of LENGTH, SUBSTR and [].
--
    
::Method C2X
  Use Strict Arg
  Return self~c2x:.String
    
::Method Lower
  Use Strict Arg n = 1, length = (Max(self~length - n + 1,0))
  .Validate~nonNegativeWholeNumber( "length" , length )
  .Validate~positiveWholeNumber(    "n" ,      n      )
  If length == 0 Then Return self
  If n > self~length Then Return self
  left = self[1,n-1]
  center = .Unicode.case~toLowercase(self[n,length])
  right = self[n+length,self~length] -- ensure we get all the rest
  Return self~class~new(left || center || right)
  
  
/*****************************************************************************/
/*                                                                           */
/*  The RUNES class                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  The RUNES class implements a new kind of string composed of Unicode      */
/*  codepoints. Some of the usual BIFs (e.g., LENBTH, SUBSTR, [], POS,       */
/*  COPIES) are implemented at the codepoint level. A new ALLRUNES           */
/*  method is provided: it returns a string composed of all the codepoints   */
/*  that compose the receiving object, in a blank separated string.          */
/*                                                                           */
/*  Runes strings can be created by using the RUNES(string) function.        */
/*  (In the future, it will be possible to use the "string"R notation.)      */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1  JMB 20230716 Initial release                                       */
/*  00.1c JMB 20230718 Move property classes to the "property" subdir        */
/*  00.1d JMB 20230719 Add support for LEFT, RIGHT and REVERSE               */
/*  00.1e JMB 20230721 Add support for LOWER(n,length)                       */
/*  00.1f JMB          Add support for UPPER(n,length)                       */
/*  00.1f JMB          Make RUNES a subclass of BYTES                        */
/*                                                                           */
/*****************************************************************************/

/******************************************************************************
 *                                                                            *
 * Class "Runes"                                                              *
 *                                                                            *
 *   A .String-like class composed of Unicode codepoints                      *
 *                                                                            *
 *   This class builds over the built-in String class.                        *
 *   It can be initialized with a .String, with a .Runes string, or with      *
 *   a .Text string. The "init" method constructs an array of utf 8codepoints *
 *   and another array of hexadecimal codepoints, suitable for the U+         *
 *   notation by prepending "U+" to them.                                     *
 *                                                                            *
 *   A subset of the ooRexx BIMs have been implemented.                       *
 *   Individual codepoints can be accessed using "string[i]" or               *
 *   "substr(string,index,1)".                                                *
 *                                                                            *
 *   You can find a list of the currently implemented BIMs below              *
 *                                                                            *
 *   Many of these BIMs are implemented in such a way that they will also     *
 *   work when applied to .Text objects.                                      *
 *                                                                            *
 *   The "allRunes" method returns a string of blank-separated codepoints.    *
 *   These codepoints are ready to use as arguments for the UNICODE BIF.      *
 *                                                                            *
 ******************************************************************************/
 
-- We redefine a number of BIMs (LENGTH, [], ...) so that we
-- can operate with Runes strings as easily as with Byte strings:
--
-- Done: 
--   []
--   Center/Centre
--   Copies
--   Length
--   Pos
--   SubStr
-- 

::Class "Runes" SubClass Bytes Public

--------------------------------------------------------------------------------
-- Reimplementation of .String BIMs                                           --
--------------------------------------------------------------------------------

::Method "[]"
  Expose utf8
  Use Strict Arg n, length = 1
  .Validate~positiveWholeNumber( "n" , n )
  .Validate~nonNegativeWholeNumber( "length" , length )
  max = self~length
  If n > max Then Return self~class~new("")
  res = ""
  Do i = n for length While i <= max
    res ||= utf8[i]
  End
  Return self~class~new(res)
  
::Method Center
  Use Strict Arg n, pad = " "
  .Validate~nonNegativeWholeNumber( "n" , n )
  If pad~class \== self~class Then pad = self~class~new(pad)
  If pad~length > 1 Then Raise Syntax 40.023 Array("CENTER",3,pad)
  size = self~length
  If n == size Then Return self
  If n > size Then Do
    extra = n - size
    left  = (extra) % 2
    right = (extra) % 2 + (extra // 2 = 1)
    Return self~class~new(Copies(pad,left) || self~makeString || Copies(pad, right))
  End
  left = (size - n + 1) % 2
  Return self~subStr(left, n)

::Method Centre
  Forward Message (Center)

::Method Copies
  Use Strict Arg n
  .Validate~nonNegativeWholeNumber( "n" , n )
  Return self~class~new( Copies( self~makeString, n ) )  

::Method Left
  Use Strict Arg length, pad = " "
  .Validate~nonNegativeWholeNumber( "length" , length )
  If pad~class \== self~class Then pad = self~class~new(pad)
  If pad~length \== 1 Then Raise Syntax 40.23 Array ("LEFT", 2, pad)
  If length > self~length Then 
    Return self~class~new(self||Copies(" ",length-self~length))
  Return self~subStr(1,length)

::Method Length
  Expose codes
  Return codes~items  
  
::Method Pos
  Use Strict Arg needle, start = 1, length = (self~length - start + 1)
  If needle~class \== self~class Then needle = self~class~new(needle)
  .Validate~positiveWholeNumber(    "start" ,  start )
  .Validate~nonNegativeWholeNumber( "length" , length )
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
  max = self~length
  res = ""
  Do i = n For Length
    If i <= max Then res ||= self[i]
    Else             res ||= pad
  End
  Return self~class~new(res)

::Method Upper
  Use Strict Arg n = 1, length = (Max(self~length - n + 1,0))
  .Validate~nonNegativeWholeNumber( "length" , length )
  .Validate~positiveWholeNumber(    "n" ,      n      )
  If length == 0 Then Return self
  If n > self~length Then Return self
  left = self[1,n-1]
  center = .Unicode.case~toUppercase(self[n,length])
  right = self[n+length,self~length] -- ensure we get all the rest
  Return self~class~new(left || center || right)

--------------------------------------------------------------------------------
-- End of reimplementation of .String BIMs                                    --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Currently, .Runes objects have to be initialized with a UTF8 .String       --
--------------------------------------------------------------------------------
        
::Method init
  Expose codes utf8
  stringValue = self~makeString
  codes = .array~new()
  utf8  = .array~new()
  -- Beware! No protection against malformed utf8
  Do i = 1 To stringValue~length:.String
    c = stringValue~"[]":.String(i)
    Select
      When c <<= "7f"X       Then Do
        codes~append( Right(c~c2x,4,0) )
        utf8 ~append( c )
        End
      When c <<= "11011111"B Then Do
        c2 = nextChar(2)
        codes~append( Right((c~c2x~x2b~right(5) || c2~c2x~x2b~right(6))~b2x,4,0) )
        utf8 ~append( c || c2 )
      End
      When c <<= "11101111"B Then Do
        c2 = nextChar(2)
        c3 = nextChar(3)
        codes~append( Right((c~c2x~x2b~right(4) || c2~c2x~x2b~right(6) || c3~c2x~x2b~right(6))~b2x,4,0) )
        utf8 ~append( c || c2 || c3 )
      End
      When c <<= "11110111"B Then Do
        c2 = nextChar(2)
        c3 = nextChar(3)
        c4 = nextChar(4)
        codes~append( Right((c~c2x~x2b~right(3) || c2~c2x~x2b~right(6) || c3~c2x~x2b~right(6) || c4~c2x~x2b~right(6))~b2x,6,0)~Strip("L",0) )
        utf8 ~append( c || c2 || c3 || c4 )
      End
      Otherwise Signal Invalid1
    End
  End
Return  
  
NextChar:
  i = i + 1
  x = stringValue~"[]":.String(i)
  If x == ""           Then Signal ("INVALID" || (Arg(1)-1) )
  If x >>= "11011111"B Then Signal ("INVALID" ||  Arg(1)    )
Return x

Invalid1: Raise Syntax 22.900 Additional("Invalid UTF-8 sequence '"c ~c2x"'X")
Invalid2: Raise Syntax 22.900 Additional("Invalid UTF-8 sequence '"||(c||c2)~c2x"'X")
Invalid3: Raise Syntax 22.900 Additional("Invalid UTF-8 sequence '"||(c||c2||c3)~c2x"'X")
Invalid4: Raise Syntax 22.900 Additional("Invalid UTF-8 sequence '"||(c||c2||c3||c4)~c2x"'X")

--------------------------------------------------------------------------------
-- New methods                                                                --
-- -----------                                                                --
--                                                                            --
-- allRunes: returns all the runes in a blank-separated string.               --
--                                                                            --
--------------------------------------------------------------------------------
::Method allRunes
  Expose codes
  Return .Runes~new(codes~makeString("L", " "))  
  
/*****************************************************************************/
/*                                                                           */
/*  The TEXT class                                                           */
/*  ==============                                                           */
/*                                                                           */
/*  The TEXT class implements a new kind of string composed of Unicode       */
/*  grapheme clusters. Some of the usual BIFs (e.g., LENBTH, SUBSTR, [],     */
/*  POS, COPIES) are implemented at the grapheme cluster level. The          */
/*  ALLRUNES method from the RUNES class is also available, since TEXT is a  */
/*  subclass of ALLRUNES.                                                    */
/*                                                                           */
/*  When string is a TEXT string, string[i] returns an (extended) grapheme   */
/*  cluster which is itself a TEXT string. You can then use the ALLRUNES     */
/*  function on string[i], if so desired, to get the individual codepoints   */
/*  that compose the i-th grapheme cluster of "string".                      */
/*                                                                           */
/*  TEXT strings can be created by using the TEXT(string) function.          */
/*  (In the future, it will be possible to use the "string"T notation.)      */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1  JMB 20230716 Initial release                                       */
/*  00.1c JMB 20230718 Move property classes to the "property" subdir        */
/*                                                                           */
/*****************************************************************************/

--
--
-- We redefine a number of BIMs (LENGTH, [], ...) so that we
-- can operate with Runes strings as easily as with Byte strings:
--

::Class "Text" SubClass Runes Public
  
--------------------------------------------------------------------------------
-- Reimplementation of .String BIMs                                           --
--------------------------------------------------------------------------------  
  
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
-- End of reimplementation of .String BIMs                                    --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Currently, .Text objects have to be initialized with a UTF8 .String        --
--------------------------------------------------------------------------------  
  
::Method init
  Expose graphemes
  self~init:super
  graphemes = .Unicode.Grapheme_Cluster_Break~codepointsToGraphemes( self~allRunes, "UTF8" )
  
::Requires "properties/properties.cls"
::Requires "properties/gc.cls"
::Requires "properties/gcb.cls"
::Requires "properties/case.cls"