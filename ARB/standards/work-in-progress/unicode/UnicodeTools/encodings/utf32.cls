/** <h3>The <code>UTF-32</code> encoding class</h3>
 *   
 *  <p>
 *    This classfile is part of 
 *    <a href="https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools">the Unicode Tools for Rexx</a>. 
 *    
 *  <p>See 
 *    <a href="https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/">
 *    https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/
 *    </a>
 *    for more information.
 *    
 *  <p>
 *    License: Apache License 2.0 
 *    [<a href="https://www.apache.org/licenses/LICENSE-2.0">
 *    https://www.apache.org/licenses/LICENSE-2.0
 *    </a>]
 *    
 *  <h4>Description</h4>
 *  
 *  <p>
 *    The <code>UTF32</code> class implements encoding/decoding from/to the UTF32
 *    format. 
 *  
 *  <p>This is a subclass of <a href="Encoding.cls.html">the Encoding class</a>. 
 *    Please refer to the documentation for <a href="Encoding.cls.html">that class</a>
 *    for additional details.
 *    
 *  <h4>Version history</h4>
 *  
 *  <table>
 *    <tr><td><b>1.0 20230811</b><td>Initial release.
 *  </table>
 * 
 *  @author &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;  
 *  @version 1.0
 *  @see <a href="Encoding.cls.html">Encoding.cls</a>
 *   
 */

.Encoding~register(.UTF32) -- Honor the contract with the .Encoding superclass

::Class UTF32 Subclass Encoding Public

::Constant name                  "UTF32"
::Constant aliases               "UTF-32"
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
  If returnUTF8  Then Return ""
  If returnUTF32 Then Return ""
  Return 1
    
StringIsGood:
  If returnUTF8 Then
    If returnUTF32 Then Return utf8 ~string, utf32~string -- An array
    Else                Return utf8 ~string
  If returnUTF32   Then Return utf32~string  
  -- Validate only
  Return 1
  
ReplaceCharacter:
  utf8 ~append(   "efbfbd"X )
  utf32~append( "0000FFFD"X )
Return    
  
Syntax:
  -- NULL is handled elsewhere
  If syntax Then
    Raise Syntax 23.900 Additional("Invalid UTF-32 sequence in position" i "of string: '"code"'X")  
  If returnUTF8 Then
    If returnUTF32 Then Return utf8 ~string, utf32~string -- An array
    Else                Return utf8 ~string
  If returnUTF32   Then Return utf32~string  
  -- Validation only
  Return 0