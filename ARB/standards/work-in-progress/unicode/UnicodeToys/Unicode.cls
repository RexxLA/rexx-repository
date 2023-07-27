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
/*    CODEPOINTS(string) -- Creates a new string composed of codepoints      */
/*    TEXT(string)  -- Creates a new string composed of grapheme clusters    */
/*    UNICODE(code,"Property",propertyName)                                  */
/*      Thw swiss-knife Unicode BIF. It allows to map codepoints to          */
/*      Unicode properties.                                                  */
/*    P2U(string)   -- Returns the set of codepoints that compose the        */
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
/*  00.2a JMB 20230727 Add format=("","U+","NAMES") for P2U.                 */
/*                     CODEPOINTS now checks for correct UTF-8.              */
/*                     Add init(encoding) to Codepoints (and hence Text),    */
/*                     add checking support for UTF16 (converted to UTF8).   */
/*                     Add STRINGTYPE(string,"ENCODING")                     */
/*                     Change RUNES to CODEPOINTS, and ALLRUNES to P2U       */
/*                                                                           */
/*****************************************************************************/

.environment~bytes      = .Bytes
.environment~codepoints = .Codepoints
.environment~text       = .Text
.environment~Unicode.Conversions  = "PROMOTE"

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
    When Abbrev("BYTES",      option,1) Then Return self~stringType == "BYTES"
    When Abbrev("CODEPOINTS", option,1) Then Return self~stringType == "CODEPOINTS"
    When Abbrev("TEXT",       option,1) Then Return self~stringType == "TEXT"
    When Abbrev("ENCODING",   option,1) Then Do
      If string~isA(.Text) | string~isA(.Codepoints) Then Return string~encoding
      Raise Syntax 40.900 Additional("Invalid option '"Arg(2)"'")
    End
    Otherwise 
      If option \== "" Then
        Raise Syntax 40.900 Additional("Invalid option '"Arg(2)"'")
  End
  Select
    When string~isA(.Text)       Then Return "TEXT"
    When string~isA(.Codepoints) Then Return "CODEPOINTS"
    When string~isA(.String)     Then Return "BYTES"
    Otherwise                         Return "NONE"
  End

::Routine Codepoints Public
  Use Strict Arg string, encoding = ""
  Return .Codepoints~new(string, encoding)

::Routine Text Public
  Use Strict Arg string, encoding = ""
  Return .Text~new(string, encoding)
  
::Routine Bytes Public
  Use Strict Arg string
  return .Bytes~new(string)
  
::Routine P2U Public  
  Use Strict Arg object, format=""
  Return object~P2U(format) 
  
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

--
-- OPTIONS CONVERSIONS ( NONE | LEFT | RIGHT | PROMOTE | DEMOTE )
--

::Routine Conversions.Left
  Use Strict Arg arg1, arg2, operation  
  
  If arg1~isA(.Text)       Then Return .Text
  If arg1~isA(.Codepoints) Then Return .Codepoints
  Return .Bytes

::Routine Conversions.Right
  Use Strict Arg arg1, arg2, operation  
  
  If arg2~isA(.Text)       Then Return .Text
  If arg2~isA(.Codepoints) Then Return .Codepoints
  Return .Bytes

::Routine Conversions.Demote
  Use Strict Arg arg1, arg2, operation  
  
  If arg1~isA(.Text)      , arg2~isA(.Text)       Then Return .Text
  If arg1~isA(.Text)      , arg2~isA(.Codepoints) Then Return .Codepoints
  If arg1~isA(.Codepoints), arg2~isA(.Text)       Then Return .Codepoints
  If arg1~isA(.Codepoints), arg2~isA(.Codepoints) Then Return .Codepoints
  Return .Bytes
  
::Routine Conversions.Promote
  Use Strict Arg arg1, arg2, operation  
  
  If arg1~isA(.Text)       Then Return .Text
  If arg2~isA(.Text)       Then Return .Text
  If arg1~isA(.Codepoints) Then Return .Codepoints
  If arg2~isA(.Codepoints) Then Return .Codepoints
  Return .Bytes
  
::Routine Conversions.None
  Use Strict Arg arg1, arg2, operation  
  
  -- Order and apparent redundancy is important, since a Text 
  -- is always a Codepoints and a Bytes, and a Codepoints is always a Bytes
  
  If arg1~isA(.Text)      , arg2~isA(.Text)       Then Return .Text
  If arg1~isA(.Text)      , arg2~isA(.Codepoints) Then Signal BadOperation
  If arg1~isA(.Text)      , arg2~isA(.Bytes)      Then Signal BadOperation
  If arg1~isA(.Codepoints), arg2~isA(.Text)       Then Signal BadOperation
  If arg1~isA(.Codepoints), arg2~isA(.Codepoints) Then Return .Codepoints
  If arg1~isA(.Codepoints), arg2~isA(.Bytes)      Then Signal BadOperation
  If arg1~isA(.Bytes)     , arg2~isA(.Text)       Then Signal BadOperation
  If arg1~isA(.Bytes)     , arg2~isA(.Codepoints) Then Signal BadOperation
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
/*****************************************************************************/

::Class "Bytes" SubClass String Public

--
-- Concatenation and equality operators, with OPTIONS CONVERSIONS
--

::Method "||" 
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "concatenation"
  Return result~new(self~makeString~"||":super(argument))

::Method " " 
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "concatenation"
  Return result~new(self~makeString~" ":super(argument))

::Method "" 
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "concatenation"
  Return result~new(self~makeString~"":super(argument))
  
::Method "="   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"=":super(argument))

::Method "\="   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"\=":super(argument))

::Method ">"   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~">":super(argument))

::Method "<"   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"<":super(argument))

::Method "><"   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"><":super(argument))

::Method "<>"   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"><":super(argument))

::Method ">="   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~">=":super(argument))

::Method "\<"   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"\<":super(argument))

::Method "<="   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"<=":super(argument))

::Method "\>"   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"\>":super(argument))

::Method "=="   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"==":super(argument))

::Method "\=="   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"\==":super(argument))

::Method ">>"   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~">>":super(argument))

::Method "<<"   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"<<":super(argument))

::Method ">>="   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~">>=":super(argument))

::Method "\<<"   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"\<<":super(argument))

::Method "<<="   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"<<=":super(argument))

::Method "\>>"   
  Use Strict Arg argument
  
  Call ("Conversions.".Unicode.Conversions) self, argument, "comparison"
  Return result~new(self~makeString~"\>>":super(argument))
  
--
-- Reimplementation of many basic BIFs. Code is common to BYTES, CODEPOINTS and 
-- TEXT, and will have different effects, depending on the most basic
-- implementations of LENGTH, SUBSTR and [].
--
    
::Method C2X
  Use Strict Arg
  Return self~makeString~c2x
  
::Method Center
  Use Strict Arg n, pad = " "
  .Validate~nonNegativeWholeNumber( "n" , n )
  If pad~class \== self~class Then pad = self~class~new(pad)
  If pad~length > 1 Then Raise Syntax 40.023 Array("CENTER",3,pad)
  If \self~isA(.Text), \self~isA(.Codepoints) Then Return Bytes(self~center:.String(n,pad))
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
  If \self~isA(.Text), \self~isA(.Codepoints) Then Return Bytes(self~copies:.String(n))
  Return self~class~new( Copies( self~makeString, n ) )    
  
::Method Left
  Use Strict Arg length, pad = " "
  .Validate~nonNegativeWholeNumber( "length" , length )
  If \self~isA(.Text), \self~isA(.Codepoints) Then Return Bytes(self~left:.String(length,pad))
  If pad~class \== self~class Then pad = self~class~new(pad)
  If pad~length \== 1 Then Raise Syntax 40.23 Array ("LEFT", 2, pad)
  If length > self~length Then 
    Return self~class~new(self||Copies(" ",length-self~length))
  Return self~subStr(1,length)
    
::Method Lower
  Use Strict Arg n = 1, length = (Max(self~length - n + 1,0))
  .Validate~nonNegativeWholeNumber( "length" , length )
  .Validate~positiveWholeNumber(    "n" ,      n      )
  If \self~isA(.Text), \self~isA(.Codepoints) Then Return Bytes(self~lower:.String(n,length))
  If length == 0 Then Return self
  If n > self~length Then Return self
  left = self[1,n-1]
  center = .Unicode.case~toLowercase(self[n,length])
  right = self[n+length,self~length] -- ensure we get all the rest
  Return self~class~new(left || center || right)

::Method Pos
  Use Strict Arg needle, start = 1, length = (self~length - start + 1)
  If needle~class \== self~class Then needle = self~class~new(needle)
  .Validate~positiveWholeNumber(    "start" ,  start )
  .Validate~nonNegativeWholeNumber( "length" , length )
  If \self~isA(.Text), \self~isA(.Codepoints) Then Return Bytes(self~pos:.String(needle, start, length))
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
  If \self~isA(.Text), \self~isA(.Codepoints) Then Return Bytes(self~right:.String(length,pad))
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
  If \self~isA(.Text), \self~isA(.Codepoints) Then Return Bytes(self~subStr:.String(n,length,pad))
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
  If \self~isA(.Text), \self~isA(.Codepoints) Then Return Bytes(self~upper:.String(n,length))
  If length == 0 Then Return self
  If n > self~length Then Return self
  left = self[1,n-1]
  center = .Unicode.case~toUppercase(self[n,length])
  right = self[n+length,self~length] -- ensure we get all the rest
  Return self~class~new(left || center || right)
  
  
/*****************************************************************************/
/*                                                                           */
/*  The CODEPOINTS class                                                     */
/*  ===============                                                          */
/*                                                                           */
/*  The CODEPOINTS class implements a new kind of string composed of Unicode */
/*  codepoints. Some of the usual BIFs (e.g., LENBTH, SUBSTR, [], POS,       */
/*  COPIES) are implemented at the codepoint level. A new P2U method is      */
/*  provided: it returns a string composed of all the codepoints that        */
/*  compose the receiving object, in a blank separated string.               */
/*                                                                           */
/*  Codepoints strings can be created by using the CODEPOINTS(string)        */
/*  function, or using the "string"P notation (requires the rxu              */
/*  preprocessor).                                                           */
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
/*  00.1f JMB          Make RUNES a subclass of BYTES, move to Unicode.cls   */
/*                                                                           */
/*****************************************************************************/

/******************************************************************************
 *                                                                            *
 * Class "Codepoints"                                                         *
 *                                                                            *
 *   A .String-like class composed of Unicode codepoints                      *
 *                                                                            *
 *   This class builds over the built-in String class.                        *
 *   It can be initialized with a .String, with a .Bytes string, with a       *
 *   .Codepoints string, or with a .Text string. The "init" method constructs *
 *   an array of utf 8codepoints and another array of hexadecimal codepoints, *
 *   suitable for the U+ notation by prepending "U+" to them.                 *
 *                                                                            *
 *   A subset of the ooRexx BIMs have been implemented.                       *
 *   Individual codepoints can be accessed using "string[i]" or               *
 *   "substr(string,index,1)".                                                *
 *                                                                            *
 *   The "P2U" method returns a string of blank-separated codepoints.         *
 *   These codepoints are ready to use as arguments for the UNICODE BIF.      *
 *                                                                            *
 ******************************************************************************/
 
::Class "Codepoints" SubClass Bytes Public

--------------------------------------------------------------------------------
--                                                                            --
-- Reimplementation of .String BIMs                                           --
--                                                                            --
-- Only the most basic ones are needed, since the rest are based on those.    --
-- Most of the reimplemented BIMs are defined in the Bytes class, and they    --
-- are written in such a way that they will work with Bytes, Codepoints       --
-- and Text strings.                                                          --
--                                                                            --
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
  
::Method Length
  Expose codes
  Return codes~items  
    
--------------------------------------------------------------------------------
-- End of reimplementation of .String BIMs                                    --
--------------------------------------------------------------------------------

::Method encoding
  Expose encoding
  Return encoding

::Method bitsPerCode 
  Expose bits
  Return bits  -- 7, 8, 16 or 32
        
::Method init
  Expose codes utf8 bits encoding isNFC isNFD isNFKC isNFKD
  Use Strict Arg encoding = ""
  
  encoding = Upper( encoding )
  
  If encoding = "" | encoding = "UTF8" Then encoding = "UTF-8"
  If encoding = "UTF16" Then encoding = "UTF-16"
  
  string = self~makeString:.String
  codes  = .array~new()
  utf8   = .array~new()
  bits   = 7             -- ASCII
  isNFC  = -1            -- Maybe
  isNFD  = -1            -- Maybe
  isNFKC = -1            -- Maybe
  isNFKD = -1            -- Maybe
  Select case Upper(encoding)
    When "", "UTF-8", "UTF8" Then Signal UTF8
    When "UTF-16", "UTF16"   Then Signal UTF16
    Otherwise
      Raise Syntax 88.900 Additional("Invalid encoding '"encoding"'")
  End
  
UTF16: -- No BOM
  length = Length(string)
  If length // 2 = 1 Then
    Raise Syntax 23.900 Additional("An UTF-16 encoded string cannot have an odd number of bytes, found" length)
  Do i = 1 To length By 2
    c = string[i,2]
    n = X2D(C2X(c))
    If n > 55295 & n < 57344 Then Nop -- Not in U+0000..U+D7FF, U+E000..U+FFFF? Surrogate
      -- See https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, table 3.5, p. 124
      b =  X2B(C2X(c))
      If n > 56319 Then Do               -- Up to, U+DBFF, High Surrogate
        Signal InvalidUTF15              -- Low Surrogate without a previous High Surrogate
      If i + 1 = length Then           -- String ends here, missing Low Surrogate
        Signal InvalidUTF15
      -- 110110wwwwxxxxxx
      wwww   = SubStr(b,7,4)
      xxxxxx = SubStr(b,11)
      i = i + 2
      c = string[i,2]
      b =  X2B(C2X(c))
      If Left(b,6) \== "110111" Then   -- Not a Low Surrogate?
        Signal InvalidUTF15
      xxxxxxxxxx = SubStr(b,7,4)
      uuuuu = X2B(D2X( X2D(B2X(wwww)) + 1 ))
      n = X2D(B2X(uuuuu || xxxxxx || xxxxxxxxxx))
    End
    code = D2X(n)
    If Length(code) < 4 Then code = Right(code, 4, 0)
    codes~append( code )
    utf8 ~append( toUTF8() )    
  End
Return

toUTF8: 
  b = X2B(code)
  If b~length == 20 Then b = "0000"||b
  If b~length == 8, n >= 128 Then b = "0000"||b
  Select
    When n <= 127   Then Return X2C(code[3,2])
    When n <= 2047  Then Return X2C(B2X("110"SubStr(b,6,5)"10"Right(b,6)))
    When n <= 65535 Then Return X2C(B2X("1110"Left(b,4)"10"SubStr(b,5,6)"10"Right(b,6)))
    Otherwise            Return X2C(B2X("11110"SubStr(b,4,3) "10"SubStr(b,7,6) "10"SubStr(b,13,6) "10"Right(b,6)))
  End 

  
InvalidUTF16:  
  Raise Syntax 23.900 Array("Invalid UTF-16 sequence: '"C2X(c)"'X")
  
UTF8:  
  length = Length(string)
  -- See https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf,
  -- table 3-7 on p. 125.
  Do i = 1 To length
    c = string[i]
    Select
      When c < "80"X Then 
        chars = 1
      When "C2"X <= c, c <= "DF"X Then Do
        Call Get1CharMore
        Call Check_2_80BF d
        chars = 2
      End
      When c == "E0"X Then Do
        Call Get2CharsMore
        Call Check_2_A0BF d -- A0BF
        Call Check_3_80BF e
        chars = 3
      End
      When "E1"X <= c, c <= "EC"X Then Do
        Call Get2CharsMore
        Call Check_2_80BF d
        Call Check_3_80BF e
        chars = 3
      End
      When c == "E0"X Then Do
        Call Get2CharsMore
        Call Check_2_809F d -- 809F
        Call Check_3_80BF e
        chars = 3
      End
      When "EE"X <= c, c <= "EF"X Then Do
        Call Get2CharsMore
        Call Check_2_80BF d
        Call Check_3_80BF e
        chars = 3
      End
      When c == "F0"X Then Do
        Call Get3CharsMore
        Call Check_2_90BF d -- 90BF
        Call Check_3_80BF e
        Call Check_4_80BF f
        chars = 4
      End
      When "F1"X <= c, c <= "F3"X Then Do
        Call Get3CharsMore
        Call Check_2_80BF d
        Call Check_3_80BF e
        Call Check_4_80BF f
        chars = 4
      End
      When c == "F4"X Then Do
        Call Get3CharsMore
        Call Check_2_808F d -- 80..8F
        Call Check_3_80BF e
        Call Check_4_80BF f
        chars = 4
      End
      Otherwise Call Syntax c2x(c)
    End
    Select case chars
      When 1 Then Do
        code = Right(c~c2x,4,0)
        codes~append( code )
        utf8 ~append( c )
      End
      When 2 Then Do
        code = Right((c~c2x~x2b~right(5) || d~c2x~x2b~right(6))~b2x,4,0)
        codes~append( code )
        utf8 ~append( c || d )
      End
      When 3 Then Do
        code = Right((c~c2x~x2b~right(4) || d~c2x~x2b~right(6) || e~c2x~x2b~right(6))~b2x,4,0)
        codes~append( code )
        utf8 ~append( c || d || e )
      End
      When 4 Then Do
        code = Right((c~c2x~x2b~right(3) || d~c2x~x2b~right(6) || e~c2x~x2b~right(6) || f~c2x~x2b~right(6))~b2x,6,0)~Strip("L",0)
        codes~append( code )
        utf8 ~append( c || d || e || f )
      End
    End
    n = X2D(code)
    Select
      When n < 128   Then Nop
      When n < 256   Then bits = Max(bits,8)
      When n < 65536 Then bits = Max(bits,16)
      Otherwise           bits = Max(bits,32)
    End
  End

  -- Note: Text exclusively containing ASCII characters (U+0000..U+007F) 
  -- is left unaffected by all of the Normalization Forms. This is particularly 
  -- important for programming languages. (See Unicode Standard Annex #31, 
  -- "Unicode Identifier and Pattern Syntax" [UAX31].) Text exclusively 
  -- containing Latin-1 characters (U+0000..U+00FF) is left unaffected by NFC. 
  -- This is effectively the same as saying that all Latin-1 text is already 
  -- normalized to NFC.
  --
  -- See https://unicode.org/reports/tr15/#Description_Norm, note.
  --

  Select case bits
    When 7 Then Do
      isNFC  = 1
      isNFD  = 1
      isNFKC = 1
      isNFKD = 1
    End
    When 8 Then Do
      isNFC  = 1
    End
    Otherwise Nop
  End

Return

Get1CharMore:
  If i   == length Then Call Syntax c2x(c)
  i += 1 
  d = string[i]
  Return
  
Get2CharsMore:
  Call Get1CharMore
  If i+1 > length Then Call Syntax c2x(c||d)
  i += 1
  e = string[i]
  Return

Get3CharsMore:
  Call Get2CharsMore
  If i+1 > length Then Call Syntax c2x(c||d||e)
  i += 1
  f = string[i]
  Return
  
Check_2_A0BF:
  If "A0"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Call Syntax c2x(c||d)

Check_2_808F: 
  If "80"X <= Arg(1), Arg(1) <= "8F"X Then Return
  Call Syntax c2x(c||d)

Check_2_809F: 
  If "80"X <= Arg(1), Arg(1) <= "9F"X Then Return 1
  Call Syntax c2x(c||d)

Check_2_80BF: 
  If "80"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Call Syntax c2x(c||d)

Check_3_80BF: 
  If "80"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Call Syntax c2x(c||d||e)

Check_4_80BF: 
  If "80"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Call Syntax c2x(c||d||e||f)

Check_2_90BF: 
  If "90"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Call Syntax c2x(c||d)

Syntax: Raise Syntax 22.900 Additional("Invalid UTF-8 sequence '"Arg(1)"'X")

::Method makeString
  Expose utf8
  Return utf8~makeString("C")
  
  /*
::Method Request
  Use Strict Arg classId
  If Upper(classId) == "STRING" Then Return self~makeString
  self~request:super(classId)
  */

--------------------------------------------------------------------------------
-- New methods                                                                --
-- -----------                                                                --
--                                                                            --
-- P2U: returns all the codepoints in a blank-separated string.               --
--                                                                            --
--------------------------------------------------------------------------------
::Method P2U
  Expose codes
  Use Strict Arg format=""
  uFormat = Upper(format)
  Select
    When format = "" Then Return .Codepoints~new(codes~makeString("L", " "))  
    When Abbrev("U+",uFormat,1) Then Return "U+".Codepoints~new(codes~makeString("L", " U+"))
    When Abbrev("NAMES",uFormat,1) Then Nop
    Otherwise Raise Syntax 88.900 Additional("Invalid format '"format"'")
  End
  res = ""
  Do i = 1 To codes~items
    res ||= " ("R2N(codes[i])")"
  End
  Return Strip(res,"L")
  
/*****************************************************************************/
/*                                                                           */
/*  The TEXT class                                                           */
/*  ==============                                                           */
/*                                                                           */
/*  The TEXT class implements a new kind of string composed of Unicode       */
/*  grapheme clusters. Some of the usual BIFs (e.g., LENGTH, SUBSTR, [],     */
/*  POS, COPIES) are implemented at the grapheme cluster level (see the code */
/*  for the CODEPOINTS class for details. The P2U method from the CODEPOINTS */
/*  class is also available, since TEXT is a subclass of CODEPOINTS.         */
/*                                                                           */
/*  When string is a TEXT string, string[i] returns an (extended) grapheme   */
/*  cluster which is itself a TEXT string. You can then use the P2U function */
/*  on string[i], if so desired, to get the individual codepoints that       */
/*  compose the i-th grapheme cluster of "string".                           */
/*                                                                           */
/*  TEXT strings can be created by using the TEXT(string) function,          */
/*  or using the "string" T notation (requires the rxu preprocessor).        */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1  JMB 20230716 Initial release                                       */
/*  00.1c JMB 20230718 Move property classes to the "property" subdir        */
/*  00.2  JMB 20230726 Merge code with Unicode.cls.                          */
/*                                                                           */
/*****************************************************************************/

--
--
-- We redefine a number of BIMs (LENGTH, [], ...) so that we
-- can operate with Codepoints strings as easily as with Byte strings:
--

::Class "Text" SubClass Codepoints Public
  
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

::Method init
  Expose graphemes
  Use Strict Arg encoding = ""
  self~init:super(encoding)
  graphemes = .Unicode.Grapheme_Cluster_Break~codepointsToGraphemes( self~P2U, "UTF8" )
  
::Requires "properties/properties.cls"
::Requires "properties/gc.cls"
::Requires "properties/gcb.cls"
::Requires "properties/case.cls"