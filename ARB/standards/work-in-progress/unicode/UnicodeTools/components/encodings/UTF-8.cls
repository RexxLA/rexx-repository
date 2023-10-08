/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/


/** <h3>The <code>UTF-8</code> encoding class</h3>
 *   
 *  <p>
 *    The <code>UTF8</code> class implements encoding/decoding from/to the UTF-8
 *    format. This encoder/decoder is, in a sense, somewhat special: since UTF-8 is the
 *    designated interchange format for Unicode Rexx strings (i.e., how the string
 *    <em>presents itself</em>, although not necessarily how it is <em>internally represented</em>), 
 *    the <code>encode</code> method has little to do, apart from ensuring that the result is of the
 *    desired class.
 *  
 *  <p>This is a subclass of <a href="Encoding.cls.html">the Encoding class</a>. 
 *    Please refer to the documentation for <a href="Encoding.cls.html">that class</a>
 *    for additional details.
 *    
 *  <h4>Version history</h4>
 *  
 *  <h4>Version history</h4>
 *  
 *  <table>
 *    <tr><td><b>1.0</b><td><b>20230811</b><td>Initial release.
 *    <tr><td>          <td><b>20230816</b><td>Change the buffers from strings to mutablebuffer, as per Rony's suggestion
 *    <tr><td><b>1.1</b><td><b>20230926</b><td>JMB</td><td>Change name to UTF-8 as per IANA  
 *                                                         https://www.iana.org/assignments/character-sets/character-sets.xhtml 
 *  </table>
 * 
 */

.Encoding~register(.UTF8) -- Honor the contract with the .Encoding superclass

::Class UTF8 Subclass Encoding Public

::Constant name                  "UTF-8"
::Constant aliases               "UTF8"
::Constant isFixedLength         0
::Constant bytesPerChar          1
::Constant maxBytesPerChar       4
::Constant endOfLine             "0A"X
::Constant alternateEndOfLine    "0D 0A"X
::Constant useAlternateEndOfLine ( .endOfLine == "0D0A"X )
::Constant endOfLineAlignment    1

::Method bytesNeededForChar Class
  Use Strict Arg string
  length = Length(string)
  c = string[1]  
  Select
    When c <= "7F"X             Then Return Max(1 - length, 0)
    When c >= "C2"X, c <= "DF"X Then Return Max(2 - length, 0)
    When c >= "E0"X, c <= "EF"X Then Return Max(3 - length, 0)
    When c >= "F0"X, c <= "F4"X Then Return Max(4 - length, 0)
    Otherwise Return 0
  End

/**
 *
 *  <h4>The <code>.UTF8~encode</code> method</h4>
 *
 *  <p>The <code>encode</code> method of the UTF8 class is special, in the sense 
 *    that UTF8 is, precisely, the encoding we are using as an interchange format. 
 *    Because of that reason, if an encoding (to UTF-8) of a <code>Text</code> or <code>Codepoints</code> 
 *    string <code>string</code> is requested, the result is automatically the result of calling 
 *    the <code>makeString</code> method (<code>Text</code> and <code>Codepoints</code> are sanitized
 *    on construction, and therefore the string is well-formed by definition). 
 *
 *  <p>If the <code>string</code> argument is a simpler string (e.g., a <code>Bytes</code> string), then it will have to
 *    be <em>decoded</em> first (i.e., checked for UTF-8 well-formedness), and then we can
 *    return this very same string.
 *
 *  <p>Please note that the present implementation supports only UTF-8 as the encoding of source programs.
 *    If other encodings were to be supported, the preliminary decoding and sanitizing should, of course,
 *    use the corresponding decoder.
 *
 *  @param <code>string</code> The string we want to encode
 *  @param <code>option</code> What to do if we find an encoding error. <code>"Syntax"</code> raises a syntax condition, and <code>""</code> (the default) indicates
           the error by returning the null string.
 *  @condition <code>Syntax 93.900</code> Invalid option '<em>option</em>'.
 *  @condition <code>Syntax 23.900</code> Invalid UTF-8 sequence in position <em>n</em> of string: '<em>hex-value</em>'X.
 *  @see <a href="#decode"><em>decode</em></a>
 *
 */ 
::Method encode Class   
  Use Arg String

  Use Strict Arg string, option = ""

  -- Check that "option" is OK.  
  option = Strip(Upper(option))
  If option \== "", option \== "SYNTAX" Then
    Raise Syntax 93.900 Additional("Invalid option '"option"'")

  -- Null strings always encode to the null string.
  If string == "" Then Return ""

  -- TEXT and CODEPOINTS strings are well-formed for sure. Return the string value.
  If string~isA(.Text)       Then Signal MakeString
  If string~isA(.Codepoints) Then Signal MakeString
  
  -- Attempt to decode the string first. This will check for well-formedness.
  string = self~decode(string, "UTF-8", option)
  
  -- If we found an error and we got here, option = "". We should return a null string.
  If string == "" Then Return ""
  -- We don't need to makeString since this string is newly created by decode.
  Return string
  
  -- Make a pure string copy.
MakeString:  
  Return string~makeString
  
/**
 *  <h4>The <code>.UTF8~decode</code> method</h4>
 *
 *  <p><code>Decode</code> takes a UTF8 <code>string</code> as an argument, and returns a choice of Unicode conversions of the
 *  string (UTF8, UTF32, or both), according to the third, optional <code>format</code> parameter (by default, it
 *  returns the UTF8 version only).
 * 
 *  <p>The argument <code>string</code> is checked for UTF8 well-formedness. The behaviour of the <code>decode</code> method
 *  when <code>string</code> is not well-formed depends on the value of its second, optional, <code>option</code> argument.
 *
 *  <p>When <code>option</code> is <code>"Syntax"</code>", if <code>string</code> is ill-formed, a Syntax condition is raised.
 *
 *  <p>When <code>option</code> is the null string, if <code>string</code> is ill-formed, the null string is returned.
 *
 *  <p>Both <code>option</code> and <code>format</code> are case-insensitive.
 *
 *  @param <code>string</code> The string to decode.
 *  @param <code>option = ""</code> What to do if we find an encoding error. <code>"Syntax"</code> produces a syntax error, and <code>""</code> (the default) returns the null string.
 *  @param <code>format = "UTF8"</code> Format may be the null string, "UTF8" or "UTF-8", in which case a UTF-8 version of the argument string is returned; 
 *                                      it can be "UTF-32" or "UTF-32", in which case a UTF-32 version of the string is returned; or it can be any combination
 *                                      of blank-separated values (repetitions are allowed). If both UTF-8 and
 *                                      UTF-32 versions are requested, the returned value is a stem containing the UTF-8 and the
 *                                      UTF-32 versions of the argument string.
 *  @condition <code>Syntax 93.900</code> Invalid option '<em>option</em>'.
 *  @condition <code>Syntax 93.900</code> Invalid format '<em>format</em>'.
 *  @condition <code>Syntax 23.900</code> Invalid UTF-8 sequence in position <em>n</em> of string: '<em>hex-value</em>'X.
 *  @see <code>encode</code>
 *
 */
::Method decode Class 
  Use Strict Arg string, format = "", errorHandling = ""
  Return UTF8(string, "UTF-8", format, errorHandling)
  
::Requires "utf8.cls"  
