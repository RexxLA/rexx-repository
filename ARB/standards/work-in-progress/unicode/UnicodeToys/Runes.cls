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
/*  Ver. Aut Date     Comments                                               */
/*  ---- --- -------- ------------------------------------------------------ */
/*  00.1 JMB 20230716 Initial release                                        */
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

::Class "Runes" SubClass String Public

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
  Do i = 1 To stringValue~length:super
    c = stringValue~"[]":super(i)
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
  x = stringValue~"[]":super(i)
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
  Return codes~makeString("L", " ")