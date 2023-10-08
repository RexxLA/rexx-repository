/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

/** <h3>The <code>UTF-32</code> encoding class</h3>
 *   
 *  <p>
 *    The <code>UTF32</code> class implements encoding/decoding from/to the UTF-32
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
 *    <tr><td><b>1.1</b><td><b>20230926</b><td>JMB</td><td>Change name to UTF-32 as per IANA 
 *                                                         https://www.iana.org/assignments/character-sets/character-sets.xhtml 
 *  </table>
 * 
 */

.Encoding~register(.UTF32) -- Honor the contract with the .Encoding superclass

::Class UTF32 Subclass Encoding Public

::Constant name                  "UTF-32"
::Constant aliases               "UTF32"
::Constant isFixedLength         1
::Constant bytesPerChar          4
::Constant maxBytesPerChar       4
::Constant endOfLine             "0000 000A"X
::Constant alternateEndOfLine    "0000 000D 0000 000A"X
::Constant useAlternateEndOfLine ( .endOfLine == "0D0A"X )
::Constant endOfLineAlignment    4

::Method encode Class
  Use Strict Arg string, option = ""

  If string == "" Then Return ""
  
  utf32 = self~prepareEncode(string, option) 
  
  -- We are done!
  Return utf32
  
::Method decode Class   
  Use Strict Arg string, format = "", errorHandling = ""
   
  -- Check that the supplied arguments are OK, and raise a Syntax condition if not
  Parse Value self~checkDecodeOptions(format,errorHandling) With errorHandling returnUTF8 returnUTF32  

  -- Null strings always to the null string.
  If string == "" Then Signal StringIsEmpty
  
  -- Will hold the utf8 value,  when needed
  utf8  = .MutableBuffer~new
  
  -- Will hold the utf32 value, when needed
  utf32 = .MutableBuffer~new
  
  repl   = errorHandling == "REPLACE"
  syntax = errorHandling == "SYNTAX"
  null   = errorHandling == "NULL"  
  validate = 0
  If \returnUTF8, \returnUTF32 Then validate = 1
  
  length = Length(string)
  
  Do i = 1 To length by 4
    code = C2X(string[i,4])
    -- Check that the supplied string contains well-formed UTF-32
    Select
      When i + 3 > length     Then Do
        If validate Then Return 0
        If null     Then Return ""
        If syntax   Then Signal Syntax
        Call ReplaceCharacter
      End
      When code >  "0010FFFF" Then Do
        If validate Then Return 0
        If null     Then Return ""
        If syntax   Then Signal Syntax
        Call ReplaceCharacter
      End
      When code >= "0000D800", -
           code <= "0000DFFF" Then Do
        If validate Then Return 0
        If null     Then Return ""
        If syntax   Then Signal Syntax
        Call ReplaceCharacter
      End
      Otherwise
        -- Transform to UTF-8, if so requested
        If returnUTF8 Then Do
          code = Strip(code,"L",0)
          If Length(code) < 4 Then code = Right(code,4,0)
          n = X2D(code)
          b = X2B(code)
          If b~length == 20 Then b = "0000"||b
          Select
            When n <= 127   Then utf8~append( X2C(code[3,2]) )
            When n <= 2047  Then utf8~append( X2C(B2X("110"SubStr(b,6,5)"10"Right(b,6))) )
            When n <= 65535 Then utf8~append( X2C(B2X("1110"Left(b,4)"10"SubStr(b,5,6)"10"Right(b,6))) )
            Otherwise            utf8~append( X2C(B2X("11110"SubStr(b,4,3) "10"SubStr(b,7,6) "10"SubStr(b,13,6) "10"Right(b,6))) )
          End 
        End
        If returnUTF32 Then utf32~append( string[i,4] )
    End
  End
  
  Signal StringIsGood
  
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
    s.["UTF8"]  = utf8  ~string
    s.["UTF32"] = utf32 ~string
    Return s.
  End
  If returnUTF8  Then Return utf8 ~string
  If returnUTF32 Then Return utf32~string
  -- Validation only
  Return 1
  
ReplaceCharacter:
  utf8 ~append(   "efbfbd"X )
  utf32~append( "0000FFFD"X )
Return    
  
Syntax:
  -- NULL is handled elsewhere
  If syntax Then
    Raise Syntax 23.900 Additional("Invalid UTF-32 sequence in position" i "of string: '"C2X(errorSequence)"'X")  
  If returnUTF8 , returnUTF32  Then Do
    -- Several targets. Return a stem.
    s. = .Stem~new()
    s.["UTF8"]  = utf8 ~string
    s.["UTF32"] = utf32~string
    Return s.
  End
  If returnUTF8 | returnUTF32  Then Return ""
  -- Validation only
  Return 0