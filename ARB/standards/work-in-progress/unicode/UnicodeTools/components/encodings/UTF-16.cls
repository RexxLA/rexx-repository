/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

/** <h3>The <code>UTF-16</code> encoding class</h3>
 *   
 *  <p>
 *    The <code>UTF16</code> class implements encoding/decoding from/to the UTF16
 *    format. 
 *  
 *  <p>This is a subclass of <a href="Encoding.cls.html">the Encoding class</a>. 
 *    Please refer to the documentation for <a href="Encoding.cls.html">that class</a>
 *    for additional details.
 *    
 *  <h4>Version history</h4>
 *  
 *  <table>
 *    <tr><td><b>1.0</b><td><b>20230811</b><td>Initial release.
 *    <tr><td>          <td><b>20230816</b><td>Change the buffers from strings to mutablebuffer, as per Rony's suggestion
 *    <tr><td><b>1.1</b><td><b>20230926</b><td>JMB</td><td>Change name to UTF-16 as per IANA  
 *                                                         https://www.iana.org/assignments/character-sets/character-sets.xhtml  
 *  </table>
 *   
 */

.Encoding~register(.UTF16) -- Honor the contract with the .Encoding superclass

::Class UTF16 Subclass Encoding Public

::Constant name                  "UTF-16"
::Constant aliases               "UTF16"
::Constant isFixedLength         0 
::Constant bytesPerChar          2
::Constant maxBytesPerChar       4
::Constant endOfLine             "000A"X
::Constant alternateEndOfLine    "000D 000A"X
::Constant useAlternateEndOfLine ( .endOfLine == "0D0A"X )
::Constant endOfLineAlignment    2

::Method bytesNeededForChar Class
  Use Strict Arg string
  -- A high surrogate alone? We need two bytes more
  If string~length == 2, string >= "D800"X, string <= "DBFF"X Then Return 2
  Return 0

::Method encode Class
  Use Strict Arg string, option = ""

  utf32 = self~prepareEncode(string, option) 

  If string == "" Then Return ""
  
  res = .MutableBuffer~new -- Will hold the result
  Do i = 1 To Length(utf32) by 4
    code = Strip(C2X(utf32[i,4]),"L",0)
    If Length(code) < 4 Then code = Right(code,4,0)
    cLength = Length(code)
    If cLength < 5 Then res~append( X2C(code) )
    Else Do
      If cLength == 5 Then code = "0"code
      bCode = X2B(code)
      u = SubStr(bcode,4,5)
      x = Right(bcode,16)
      w = X2B(D2X( X2D(B2X(u)) - 1 ))
      res~append( X2C( B2X( "110110"||w||Left(x,6)"110111"Right(x,10) ) ) )
    End
  End

  Return res~string
  
-- See https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, table 3.5, p. 124
-- See https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt
::Method decode Class

  Use Strict Arg string, format = "", errorHandling = ""
  
  -- Check that the supplied arguments are OK, and raise a Syntax condition if not
  Parse Value self~checkDecodeOptions(format, errorHandling) With errorHandling returnUTF8 returnUTF32  

  -- Null strings decode to the null string.
  If string == "" Then Signal StringIsEmpty
  
  -- Will hold the utf8 value, if needed
  utf8     = .MutableBuffer~new
  
  -- Will hold the utf32 value, if needed
  utf32    = .MutableBuffer~new
  
  repl     = errorHandling == "REPLACE"
  syntax   = errorHandling == "SYNTAX"
  null     = errorHandling == "NULL"
  validate = 0
  If \returnUTF8, \returnUTF32 Then validate = 1
  
  length = Length(string)
    
  Do i = 1 By 2 To length
  
    c = string[i]
    -- Bytes should come in pairs
    If i = length Then Do
      If validate Then Return 0
      If null     Then Return ""
      errorSequence = c
      If syntax Then Signal Syntax
      Call ReplaceCharacter
      Leave
    End
    
    Select
      When c < "D8"X Then Call Decode2
      When c > "DF"X Then Call Decode2
      Otherwise 
        If c >= "DC"X            Then Do -- Low surrogate alone?
          If validate Then Return 0
          If null Then Return ""
          errorSequence = string[i,2]
          If syntax Then Signal Syntax
          Call ReplaceCharacter
          Iterate
        End
        If i + 3 > length        Then Do -- We need 4 bytes, no less
          If validate Then Return 0
          If null Then Return ""
          errorSequence = string[i,4]
          If syntax Then Signal Syntax
          Call ReplaceCharacter
          Iterate
        End
        d = string[i+2]
        If d < "DC"X | d > "DF"X Then Do -- Not a low surrogate
          If validate Then Return 0
          If null Then Return ""      
          errorSequence = string[i+2,2]
          If syntax Then Signal Syntax          
          Call ReplaceCharacter
          Iterate
        End
        Call Decode4
    End
  End
  
  Signal StringIsGood
  
ReplaceCharacter:
  utf8 ~append(   "efbfbd"X )
  utf32~append( "0000FFFD"X )
Return  
  
-- See <a href="https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf">The Unicode® Standard.
-- Version 15.0 – Core Specification</a>, table 3-5, p. 124, and table 3-6,  p. 125.
  
Decode2:
  If \returnUTF8, \returnUTF32 Then Return
  cc = string[i,2]
  If returnUTF32 Then utf32~append( "0000"x || cc )
  If returnUTF8  Then Do
    code = C2X(cc)
    n = X2D(code)
    b = X2B(code)
    Select
      When n <= 127   Then utf8~append( X2C(code[3,2]) )
      When n <= 2047  Then utf8~append( X2C(B2X("110"SubStr(b,6,5)"10"Right(b,6))) )
      Otherwise            utf8~append( X2C(B2X("1110"Left(b,4)"10"SubStr(b,5,6)"10"Right(b,6))) )
    End
  End
Return  

Decode4:
  If \returnUTF8, \returnUTF32 Then Do
    i += 2
    Return
  End
  code = X2B(C2X(string[i,4]))
  w    = SubStr(code,  7, 4)
  x1   = SubStr(code, 11, 6)
  x2   = SubStr(code, 23   )
  u    = X2B(D2X( X2D(B2X(w)) + 1))
  code = u || x1 || x2
  If Length(code) == 20 Then code = "0000"code
  If returnUTF32 Then 
    utf32~append( "00"X || X2C(B2X(code)) )
  If returnUTF8  Then
    utf8~append( X2C(B2X("11110"SubStr(code,4,3) "10"SubStr(code,7,6) "10"SubStr(code,13,6) "10"Right(code,6))) )
  i += 2
Return  
  
StringIsEmpty:  
  If returnUTF8 , returnUTF32  Then Do
    -- Several targets. Return a stem.
    s. = .Stem~new()
    s.["UTF8"]  = ""
    s.["UTF32"] = ""
    Return s.
  End
  If returnUTF8 | returnUTF32  Then Return ""
  -- Validation only
  Return 1
      
StringIsGood:
  If returnUTF8 , returnUTF32  Then Do
    -- Several targets. Return a stem.
    s. = .Stem~new()
    s.["UTF8"]  = utf8 ~string
    s.["UTF32"] = utf32~string
    Return s.
  End
  If returnUTF8  Then Return utf8 ~string
  If returnUTF32 Then Return utf32~string
  -- Validation only
  Return 1
  
Syntax:
  Raise Syntax 23.900 Additional("Invalid UTF-16 sequence in position" i "of string: '"C2X(errorSequence)"'X")