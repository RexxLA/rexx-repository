/** 
   <h3>The <code>Encoding</code> class</h3>
    
  <p>
    This classfile is part of 
    <a href="https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools">the Unicode Tools for Rexx</a>. 
  </p>
    
  <p>See 
    <a href="https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/">
    https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/
    </a>
    for more information.
  </p>
    
  <p>
    License: Apache License 2.0 
    [<a href="https://www.apache.org/licenses/LICENSE-2.0">
    https://www.apache.org/licenses/LICENSE-2.0
    </a>]
  </p>
    
  <h4>Description</h4>
    
  <p>
    The <code>Encoding</code> class is the base class for all encodings, and all encoding classes should subclass <code>Encoding</code>. 
  </p>
  
  <p>   
    The <code>Encoding</code> class implements a series of common services (like the encoding registry),
    and defines a set of common interfaces (a contract) that all subclassing encodings have to follow.                            
  </p>
  
  <h4>The <code>Encoding</code> registry and contract</h4>
  
  <p>
    The <code>Encoding</code> class and its subclasses operate under the following contract. All subclasses must adhere to this contract to work properly.
  </p>
  
  <ul>
    <li>Subclasses of <code>Encoding</code> must reside each in a separate <code>.cls</code> file, 
        and these files must be located in the same directory where <code>Encoding.cls</code> is located.
    <li>At initialization time, the <code>Encoding</code> class will register in the <code>.local</code> directory by using <code>.local~encoding = .Encoding</code>. 
        This allows encoding subclasses to subclass <code>Encoding</code> without having to use the <code>::Requires</code> directive.
    <li><code>Encoding</code> will call all the <code>.cls</code> files that reside in its own directory, except itself. This will give all subclasses an opportunity 
        to register with the <code>Encoding</code> class.
    <li>Each subclass <code>myEncoding</code> must use its prolog to register with the <code>Encoding</code> class, by issuing the following method call: <code>.Encoding~register(.myEncoding)</code>.
    <li><code>Encoding</code> will then inspect the <code>name</code> and <code>aliases</code> constants of the <code>myEncoding</code> class, check that there are no duplicates, and, 
        if no errors are found, it will register these names appropriately.
    <li>From then on, the new <code>myEncoding</code> encoding will be accesible as the value of the <code>.Encoding[name]</code> method call (note the square brackets), 
        where <code>name</code> is the (case-insensitive) value of <code>myEncoding</code>'s <code>name</code>, or of any of its <code>aliases</code>.
  </ul>

  <h4>Version history</h4>
   
  <table class="table table-bordered">
    <tr><td><b>1.0</b><td><b>20230811</b><td>Initial release.
    <tr><td>          <td><b>20230816</b><td>Change the buffers from strings to mutablebuffer, as per Rony's suggestion
  </table>
 
  @author &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;  
  @version 1.0

 */

-- Make ourselves known so that encodings can subclass us without using
-- ::Requires (otherwise the prolog gets the risk of being run twice).

.local~encoding = .Encoding

-- Extract our own directory, and do a directory listing.
-- Then call all the *.cls files in turn (except ourselves) to give them
-- the opportunity to register.

separator = .File~separator
Parse Source . . myself
myDir = Left(myself, LastPos(separator, myself))
Do file Over .File~new(myDir)~listFiles
  fileName = file~absolutePath
  If fileName == myself         Then Iterate
  If \filename~endsWith(".cls") Then Iterate
  Call (filename)
End

::Class "Encoding" Public

/**
 *  <h4>The <code>name</code> constant</h4>
 *
 *  An encoding has an official <code>name</code>, a case-insensitive label 
 *  by which it may be uniquely identified.
 */

::Attribute name           Class Get Abstract

/**
 *  <h4>The <code>aliases</code> constant</h4>
 *
 *  <p>In addition to a <code>name</code>, an encoding may also have a set of case-insensitive <code>aliases</code>. 
 *  The encoding can be uniquely identified by its name, or by any of its aliases. The <code>Encoding</code> class keeps a registry
 *  of all the names and aliases of all encodings, takes care that there are no duplicates, and resolves
 *  names to their corresponding classes.
 *
 *  <p>Aliases can specified either as a one-dimensional array of strings,
 *  or as a blank separated string of words.
 */

::Attribute aliases        Class Get Abstract

/**
 *  <h4>The <code>endOfLine</code> constant</h4>
 *
 *  <p>Each encoding can define its own end-of-line sequence.
 *
 */

::Attribute endOfLine      Class Get Abstract

/**
 *  <h4>The <code>endOfLineAlignment</code> constant</h4>
 *
 *  <p>If <code>endOfLineAlignment</code> is &gt; 1, <code>endOfLine</code>
 *  and <code>alternateEndOfLine</code> sequences will only be recognized
 *  when they are aligned to <code>endOfLineAlignment</code> bytes.
 *
 */

::Constant endOfLineAlignment       1

/**
 *  <h4>The <code>alternateEndOfLine</code> constant</h4>
 *
 *  <p>Some encodings and some implementations allow more than one
 *  form of end-of-line character. For example, ooRexx recognizes both
 *  Windows end of line (CR LF) and Linux end of line (LF) sequences.
 *  The null string means that no alternate end of line sequence exists
 *  for this encoding. If an alternate end of line sequence is specified,
 *  it has to verify that <code>alternateEndOfLine~endsWith(endOfLine) = 1</code>.
 *
 */

::Constant alternateEndOfLine        ""

/**
 *
 *  <h4>The <code>useAlternateEndOfLineOnOutput</code> constant</h4> 
 *
 *  <p>For encodings where <code>alternateEndOfLine \== ""</code>, determines
 *  whether <code>endOfLine</code> or <code>alternateEndOfLine</code> is used
 *  when writing a line to a stream.
 */

::Constant useAlternateEndOfLine     0

/**
 *
 *  <h4>The <code>isFixedLength</code> constant</h4> 
 *
 *  <p>An encoding can be fixed- or variable length. For example, cp850 is (1-byte)
 *  fixed length, as is UTF-32 (4-byte), but UTF-8 is variable-length (1 to 4 bytes).
 *
 *  <p>The fact that an encoding is variable-length can have notable influence
 *  on the behaviour and performance of certain stream BIFs. In particular, some of these behaviours
 *  can become extremely expensive, and others may be entirely disallowed by the implementation.
 */

::Attribute isFixedLength   Class Get Abstract

/**
 *
 *  <h4>The <code>bytesPerChar</code> constant</h4> 
 *
 *  <p>For fixed-length encodings, this is the length in bytes of one character. 
 *    For variable-length encodings, this is the minimum length in bytes of a character.
 */

::Attribute bytesPerChar    Class Get Abstract

/**
 *
 *  <h4>The <code>maxBytesPerChar</code> constant</h4> 
 *
 *  <p>For fixed-length encodings, this is the length in bytes of one character. For variable-length
 *  encodings, this is the maximum length in bytes of a character.
 */

::Attribute maxBytesPerChar Class Get Abstract

/**
 *  <h4>The <code>.Encoding~bytesNeededForChar</code> method</h4>
 *
 *  <p>^Returns 0 if the character is complete, or the number of remaining bytes needed
 *    to complete a character. For example, if the encoding is UTF-16 and the argument 
 *    string is a lone high surrogate, it will return 2.
 *
 *  <p>Please note that the fact that a character is complete does not imply that it is well-formed or valid.
 */

::Method bytesNeededForChar Class Abstract

/** 
 *  <h4>The <code>.Encoding~register</code> method</h4>
 * 
 *  <p><code>Register</code> is one of the two methods that define the interface to the encoding registry.
 *
 *  <p>The register itself is implemented and stored in a stem called <code>Names.</code>, which
 *  is <code>expose</code>d between the <code>register</code> and <code><a href="#%5B%5D-1">[]</a></code> methods.
 *
 *  
 *
 *
 *  @param <code>handler</code> The class to register.
 *
 */

::Method register          Class
  Expose Names. name aliases
  
  Use Strict Arg handler
      
  name    = handler~name
  aliases = handler~aliases
  
  --
  -- Names. stores both the official names and the aliases.
  -- This allows to detect duplicates.
  --
  
  If Names.~hasIndex(name) Then
    Raise Syntax 98.900 Additional("Duplicate encoding name '"name"'")
    
  Names.[Upper(name)] = handler
  
  -- "Aliases" can be specified as a blank-separated string, or as
  -- an array of names.
  If aliases~isA(.String) Then xAliases = aliases~makeArray(" ")
  Else                         xAliases = aliases
  
  Do alias Over xAliases
    If Names.~hasIndex(alias) Then 
      Raise Syntax 98.900 Additional("Duplicate encoding name or alias '"alias"'")
    Names.[Upper(alias)] = handler
  End
  
/**
 *  <h4>The <code>.Encoding~"[]"</code> method</h4>
 *
 *  <p>
 *    <code>Encoding[name]</code> returns the encoding class object uniquely identified by <code>name</code>.
 *
 *  @param <code>name</code>, the encoding name or alias to resolve.
 *  @param <code>option = "SYNTAX"</code> (optional), what to do when the encoding is not found 
 *    (<code>"SYNTAX"</code>: raise a Syntax condition, "" or "NULL": return <code>""</code>).
 *  @return <code>""</code>, when the name is not found, or the corresponding encoding class object otherwise.
 *  @see <a href="#register"><code>register</code></a>
 *  @condition <code>Syntax 93.900</code> Invalid option '<em>option</em>'. 
 *  @condition <code>Syntax 93.900</code> Encoding '<em>name</em>' not found. 
 */

::Method "[]"              Class
  Expose Names.
  Use Strict Arg name, option = "Syntax"
  option = Upper(option)
  Select
    When option == "SYNTAX" Then syntax = 1
    When option == "NULL"   Then syntax = 0
    When option == ""       Then syntax = 0
    Otherwise
      Raise Syntax 93.900 Additional("Invalid option '"Arg(2)"'")
  End
  name = Upper(name)
  If Names.~hasIndex(name) Then Return names.[Upper(name)]
  If \syntax Then Return .Nil
  Raise Syntax 93.900 Additional("Encoding '"name"' not found.")

/**
 *  <h4>The <code>.Encoding~transcode</code> method </h4>
 *
 *  <p><b>Note:</b> This method should be considered <em>final</em>, in the Java sense.
 *  It is not intended to be overriden by subclasses.
 *
 *  <p>This method <em>transcodes</em> its first argument, <code>string</code>, from
 *  the encoding idenfitied by the second argument, <code>source</code>, to the
 *  encoding identified by the third argument, <code>target</code>.
 *
 *  <p>The <code>string</code> argument is supposed to be encoded using the <code>source</code>
 *  encoding. It will be decoded first, and then re-encoded with the <code>target</code> encoding.
 *
 *  <p>Both operations may fail. The behaviour of the method when an error is encountered
 *  is determined by the value of the fourth, optional, argument, <code>option</code>.
 *
 *  <p>When an error is encountered and <code>option</code> is not specified or is the null string
 *  (the default), a null string is returned.
 *
 *  <p>When an error is encountered and <code>option</code> has the value <code>"Syntax"</code>,
 *  a Syntax condition is raised.
 *
 *  <p>When no error is encountered, a new string is returned. It is guaranteed to be encoded
 *  using the <code>target</code> encoding.
 *
 *  @param <code>string</code> The string to be transcoded.
 *  @param <code>source</code> The source encoding, i.e., the encoding of <code>string</code>.
 *  @param <code>target</code> The target encoding, i.e., the desired encoding of the result.
 *  @param <code>option = ""</code> Determines the behaviour of the method when an error is encountered.
 *  @returns The value of the transcoded string.
 *  @condition <code>Syntax 93.900</code>: Invalid option '<em>option</em>'.
 *  @condition <code>Syntax 93.900</code>: Invalid source encoding '<em>source</em>'.
 *  @condition <code>Syntax 93.900</code>: Invalid target encoding '<em>target</em>'.
 *  @condition <code>Syntax 23.900</code>: Invalid <em>encoding-name</em> sequence in position <em>n</em> of string: '<em>hex-value</em>'X (only raised if <code>option = "Syntax"</code>).
 */
 
::Method transcode Class -- Final
  Use Strict arg string, source, target, option=""

  -- Check that "option" is OK.  
  option = Strip(Upper(option))
  If option \== "", option \== "SYNTAX" Then
    Raise Syntax 93.900 Additional("Invalid option '"option"'")
  raiseSyntax = option == "SYNTAX"
  
  sourceEncoding = .Encoding[source]
  If sourceEncoding~isNil Then
    Raise Syntax 93.900 Additional("Invalid source encoding '"source"'")

  targetEncoding = .Encoding[target]
  If targetEncoding~isNil Then
    Raise Syntax 93.900 Additional("Invalid target encoding '"target"'")
    
  If targetEncoding == sourceEncoding Then Return string
  
  If string == "" Then Return ""
  
  temp = sourceEncoding~decode(string, option)
  
  If \raiseSyntax, temp == "" Then Return ""
  
  new  = targetEncoding~encode(temp, option)
  
  -- Logically, this goes here, but it is not necessary
  -- If \raiseSyntax, new  == "" Then Return ""
  
  Return new

/**
 *  <h4>The <code>.Encoding~encode</code> method </h4>
 *
 *  <p>This is an abstract method, that any subclass will have to implement.
 *
 *  <p>This method takes a string <code>string</code> as an argument. The string can be an Unicode
 *  string, in which case an encoding operation is immediately attempted, or it can be
 *  a non-unicode string (e.g., a BYTES string), in which case a normalization
 *  pass is attempted first. Normalizing consists of transforming the
 *  non-Unicode string into a Unicode string by promoting it to the CODEPOINTS class.
 *
 *  <p>Both operations may fail. The promotion, because <em>string</em> argument contains 
 *  ill-formed UTF-8, and the encoding, because the Unicode string cannot
 *  be encoded to this particular encoding.
 *
 *  <p>The behaviour of the <code>encode</code> method depends on the value of 
 *  <code>option</code>, a second, optional, argument. 
 *
 *  <p>When <code>option</code> is the null string (the default), <code>encode</code> 
 *  <p>When <code>option</code> is the null string (the default), <code>encode</code> 
 *  returns the null string when it encounters an error (note that there is no ambiguity 
 *  in this specification because the case where the <code>string</code> argument is itself 
 *  the null string can be handled separately).
 *
 *  <p>When <code>option</code> has a (case-insensitive) value of <code>"Syntax"</code>,
 *  a Syntax condition is raised. No other value for <code>option</code> is currently
 *  defined.
 *
 *  @param <code>string</code> The string to encode.
 *  @param <code>option = ""</code> [Optional]. Defines the behavior of the method when an error is encountered.
 *  @returns The encoded value of <code>string</code>, or the null string if an error was encountered and additionally <code>option = ""</code>.
 *  @condition <code>Syntax 93.900</code>: Invalid option '<em>option</em>'.
 *  @condition <code>Syntax 23.900</code>: Invalid <em>encoding-name</em> sequence in position <em>n</em> of string: '<em>hex-value</em>'X (only raised if <code>option = "Syntax"</code>).
 *
 */

::Method encode Class Abstract

/**
 *  <h4>The <code>.Encoding~prepareEncode</code> private utility method</h4>
 * 
 *  <p>This is a small private utility method that checks arguments passed
 *  to the <code>encode</code> method; <code>option</code> is checked
 *  for validity, and <code>string</code> is transformed into a UTF-32
 *  byte sequence. If the string is a CODEPOINTS or a TEXT, then the 
 *  C2U("UTF32") method of the string is used; in other cases, the
 *  <code>decode</code> method of the UTF8 encoding is used, with
 *  the UTF32 <code>format</code> option.
 *
 *  <p>The case of the null string is not handled here, since it is conceivable
 *  that an encoding could encode the null string to a non-null string
 *  (for example, by prepending a BOM or somesuch).
 *
 */

::Method prepareEncode Class Private
  Use Strict Arg string, option = ""
  
  -- Check that "option" is OK.  
  option = Strip(Upper(option))
  If option \== "", option \== "SYNTAX", option \== "REPLACE" Then
    Raise Syntax 93.900 Additional("Invalid option '"option"'")

  If \string~isA(.Text), \string~isA(.Codepoints) Then
    -- Attempt to decode the string first. This will check for well-formedness.
    Return .Encoding["utf8"]~decode(string, "UTF32", option)
    
  Return string~C2U("UTF32")
  

/**
 *  <h4>The <code>.Encoding~decode</code> method </h4>
 *
 *  <p>This is an abstract method, that any subclass will have to implement.
 *
 *  <p>This method takes a string <code>string</code> as an argument. 
 *  The string is assumed to be encoded using the encoding implemented by the current class.
 *  A decoding operation is attempted. If the decoding operation is successful,
 *  a choice of Unicode versions of the string is returned, as determined by the
 *  optional third argument, <code>format</code>. By default, a UTF-8 version of
 *  the argument string is returned.
 *
 *  <p>When <code>format</code> is the null string, <code>"UTF-8"</code>, <code>"UTF8"</code>
 *  or is not specified, a UTF-8 version of the argument string is returned.
 *
 *  <p>When <code>format</code> is "UTF-32" or "UTF32", a UTF-32 version of the argument
 *  string is returned.
 *
 *  <p>The <code>format</code> can also contain a blank-separated set of encodings. When both
 *  UTF-8 and UTF-32 are requested, they are returned in an array, containing the UTF-8
 *  version of the string in the first element, and the UTF-32 version of the string
 *  in the second element.
 *
 *  <p>For some encodings, the decoding operation may be unsuccessful; for example,
 *  an ill-formed UTF-8 string decoding can be attempted. The behaviour of the <code>method</code>
 *  is determined by the value of the second, optional, <code>option</code> argument.
 *
 *  <p>When <code>option = ""</code> (the default), a null string is returned whenever
 *  a decoding error is encountered. Please note that this specification does not introduce
 *  any ambiguity, since the fact that the decoding of a null string is always a null string
 *  is known in advance and may be checked separately (when an array is expected as the 
 *  return value, a separate check for the null string is needed).
 *
 *  <p>When <code>option</code> has the (case-insensitive) value of <code>"Syntax"</code>,
 *  a Syntax condition is raised.
 *
 *  <p>Please note that the <code>decode</code> method of the encoding class that corresponds 
 *  to the source file encoding will be automatically invoked by the <code>encode</code> method 
 *  when it receives a non-Unicode, non-null, string as its argument.
 *  This is done as a way to sanitize the BYTES string to ensure that the decoding operation makes sense 
 *  (currently, only UTF-8 source files are supported, so that the <a href="utf8.cls.html"><code>UTF8</code></a> 
 *  class will be used).
 *
 *  @param <code>string</code> The string to decode.
 *  @param <code>option = ""</code> [Optional]. Defines the behavior of the method when an error is encountered.
 *  @param <code>format = "UTF8"</code> Format may be the null string, "UTF8" or "UTF-8", in which case a UTF-8 version of the argument string is returned; 
 *                                      it can be "UTF-32" or "UTF-32", in which case a UTF-32 version of the string is returned; or it can be any combination
 *                                      of blank-separated values (repetitions are allowed). If both UTF-8 and
 *                                      UTF-32 versions are requested, the returned value is an array containing the UTF-8 and the
 *                                      UTF-32 versions of the argument string (in this order). 
 *  @returns The decoded value of <code>string</code>, or the null string if an error was encountered and additionally <code>option = ""</code>.
 *  @condition <code>Syntax 93.900</code>: Invalid option '<em>option</em>'.
 *  @condition <code>Syntax 93.900</code> Invalid format '<em>format</em>'. 
 *  @condition <code>Syntax 23.900</code>: Invalid <em>encoding-name</em> sequence in position <em>n</em> of string: '<em>hex-value</em>'X (only raised if <code>option = "Syntax"</code>).
 *
 */

::Method decode Class Abstract

/**
 *  <h4>The <code>.Encoding~checkDecodeOptions</code> private utility method </h4>
 *
 *  <p>This is a small utility method to sanitize the values supplied as arguments
 *  for the <code>errorHandling</code> and <code>format</code> arguments to the <code>decode</code>
 *  method. If the supplied values are invalid, it raises a Syntax condition.
 *
 *  <p>When the values are valid, the method returns a string composed of three
 *  blank-separated values.
 *
 *  <p>The first value indicates the form of desired error handling. It will be one of "NULL",
 *    to indicate that a null string should be returned when a decoding error is encountered,
 *    "SYNTAX", when a Syntax condition should be raised, or "REPLACE", when ill-formed
 *    character sequences should be replaced by the Unicode Replacement Character <code>U+FFFD</code>.
 *
 *  <p>The second value is a boolean indicating that a UTF-8 version of the supplied string value
 *  is requested.
 *
 *  <p>The third value is a boolean indicating that a UTF-32 version of the supplied string value
 *  is requested.
 */

::Method checkDecodeOptions Private Class
  Use Strict Arg format, errorHandling

  -- Check that "format" is OK
  returnUTF8  = 0
  returnUTF32 = 0
  format = Space(Upper(format))
  Do format Over format~makeArray(" ")
    Select Case format
      When "UTF-8",  "UTF8"  Then returnUTF8  = 1
      When "UTF-32", "UTF32" Then returnUTF32 = 1
      Otherwise 
        Raise Syntax 93.900 Additional("Invalid format '"format"'")
    End    
  End
  
  If (Arg(1, "O") | Arg(1) == ""), errorHandling \== "" Then 
    Raise Syntax 93.900 Additional("Invalid option '"errorHandling"'")
  
  -- Check that "errorHandling" is OK.  
  errorHandling = Strip(Upper(errorHandling))
  Select
    When errorHandling == ""               Then errorHandling = "NULL"
    When Abbrev("NULL",errorHandling,1)    Then errorHandling = "NULL"
    When Abbrev("SYNTAX",errorHandling,1)  Then errorHandling = "SYNTAX"
    When Abbrev("REPLACE",errorHandling,1) Then errorHandling = "REPLACE"
    Otherwise Raise Syntax 93.900 Additional("Invalid error handling '"errorHandling"'")
  End
    
Return errorHandling returnUTF8 returnUTF32  


/**
 *  <h4>The <code>allowSurrogates</code> constant</h4>
 *
 *  <p>This is a boolean constant that determines if surrogates are allowed as Unicode values when decoding a string.
 *
 *  <p>The default is 0 (<code>.false</code>). A class may set this constant to 1 (<code>.true</code>) when it needs to manage ill-formed UTF-16 sequences, 
 *  containing isolated or out-of-sequence surrogates. Such ill-formed strings are encountered in certain contexts, for example as Windows file names.
 *
 *  <p>WTF-8 and WTF-16 are encodings that need to set <code>allowSurrogates</code> to true.
 *
 */

::Constant allowSurrogates 0

/**
 *  <h4>The <code>.Encoding~isCodeOK</code> utility method</h4>
 *
 *  <p>The <code>isCodeOk</code> checks that its hex argument, <code>code</code>,
 *  is in the Unicode scalar space. Surrogates are allowed only if <code>allowSurrogates</code> is 1
 *  for the current (sub-)class.
 *
 *  @param <code>code</code> The hexadecimal codepoint to check.
 *  @returns A boolean value, indicating the fact that <code>code</code> represents
 *           a valid Unicode codepoint (including surrogates if <code>allowSurrogates</code> is 1).
 *  @condition None.
 *
 */

::Method isCodeOK          Class 
  Use Strict Arg code
  If code = ""             Then Return 0
  If \DataType(code,"X")   Then Return 0
  If Length(code) > 8      Then Return 0
  
  Numeric Digits 10
  
  n = X2D(code)
  
  If \self~allowSurrogates Then Do
    If n <    55296        Then Return 1       -- Surrogates start at U+D800..
    If n <=   57343        Then Return 0       -- ..and end at U+DFFF
  End
  
  If n <= 1114111          Then Return 1       -- Maximum is U+10FFFF
  Return 0
  
/**
 *
 *  <h4>The <code>.Encoding~checkCode</code> utility method</h4>
 *
 *  <p>The <code>checkCode</code> method checks to see if its its argument, <code>code</code>,
 *  is a valid hexadecimal Unicode codepoint, and raises a syntax condition of it is not. 
 *  Surrogate codepoints are only accepted when the <code>allowSurrogates</code> constant 
 *  is set to <code>.true</code> for this particular class.
 *
 *  @param <code>code</code> The hexadecimal codepoint to check.
 *  @returns Nothing. If <code>code</code> is not well-formed, and exception is raised.
 *  @condition <code>Syntax 23.900</code>: Invalid unicode codepoint '<em>code</em>'X.
 *
 */

::Method checkCode         Class Private
  Use Strict Arg code
  
  If self~isCodeOk(code) Then Return
  
  Raise Error 23.900 Additional("Invalid Unicode codepoint '"code"'X")  
  
::Method activate Class
  Expose tablei tableo ASCII       -- For TRANSLATE. Will be used by the "decode" method.
  
  ASCII  = "A"
  tablei = ""
  tableo = ""
  
  Call Assign "00","7F",ASCII      -- ASCII Chars
  Call Assign "80","BF","C"        -- Continuation character
  Call Assign "C0","C1","I"        -- Illegal character
  Call Assign "C2","DF","20"X      -- 2-byte sequences (1 continuation)
  Call Assign "E0","E0","3a"X      -- 3-byte sequences of subtype "a": 2nd byte in A0..BF. Manual check.
  Call Assign "E1","EC","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call Assign "ED","ED","3c"X      -- 3-byte sequences of subtype "c". 2nd byte in 80..9F. Manual check.
  Call Assign "EE","EF","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call Assign "F0","F0","4a"X      -- 4-byte sequences of subtype "a". 2nd byte in 90..BF. Manual check.
  Call Assign "F1","F3","4b"X      -- 4-byte sequences of subtype "b". 3 continuations.
  Call Assign "F4","F4","4c"X      -- 4-byte sequences of subtype "c". 2nd byte in 80..8F. Manual check.
  Call Assign "F5","FF","I"        -- Illegal character
Return  
  
  
Assign:
  use Arg from, to, value
  input = XRange(X2C(from), X2C(to))
  tablei ||= input
  tableo ||= Copies(value,Length(input))
Return    
  
/**
 *
 *  <h4>The .Encoding~UTF8 method</h4>
 *  
 *  <p><b>Note:</b> These conversions should really reside in the UTF8 encoding class, but they are so frequently used 
 *  that they are better placed here.
 *
 *  <p>You can use the <code>UTF8</code> method as a format validator, as a conversion tool.
 *
 *  <p><code>UTF8(string)</code> returns 1 iff <code>string</code> is a well-formed UTF-8 string.
 *
 *  <p><code>UTF8(string, "Syntax")</code> returns 1 when <code>string</code> is a well-formed UTF-8 string,
 *  and raises a Syntax condition otherwise.
 *
 *  <p><code>UTF8(string,,"UTF32")</code> returns a UTF-32 version of the argument string, if that
 *  string was a well-formed UTF-8 string, and a null string otherwise.
 *
 *  <p><code>UTF8(string,"Syntax","UTF32")</code> returns a UTF-32 version of the argument string, if that
 *  string was a well-formed UTF-8 string, raises a Syntax condition otherwise.
 *
 *  <p>You can also use <p><code>UTF8(string,,"UTF8")</code> (it returns a makeString version of the argument string, if that
 *  string was a well-formed UTF-8 string, and a null string otherwise), and  <p><code>UTF8(string,,"UTF8 UTF32")</code> 
 *  (it returns an array containing a makeString version of the argument string and a UTF-32 version of the argument string, if that
 *  string was a well-formed UTF-8 string, and a null string otherwise), and the corresponding versions that
 *  raise a Syntax error.
 
 *  <p>[Start quote]
 *
 *  <p>See <a href="https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf">The Unicode® Standard.
 *  Version 15.0 – Core Specification</a>, p. 125.
 *
 *  <table class="table table-bordered"> 
 *  <caption><b>Table 3-7</b>. Well-Formed UTF-8 Byte Sequences</caption>
 *  <tr><th>Code Points       <th>First Byte<th>Second Byte<th>Third Byte<th>Fourth Byte
 *  <tr><td>U+0000..U+007F    <td>00..7F    <td>           <td>          <td>
 *  <tr><td>U+0080..U+07FF    <td>C2..DF    <td>80..BF     <td>          <td>
 *  <tr><td>U+0800..U+0FFF    <td>E0        <td><b><i>A0</i></b>..BF     <td>80..BF    <td>
 *  <tr><td>U+1000..U+CFFF    <td>E1..EC    <td>80..BF     <td>80..BF    <td>
 *  <tr><td>U+D000..U+D7FF    <td>ED        <td>80..<b><i>9F</i></b>    <td>80..BF    <td>
 *  <tr><td>U+E000..U+FFFF    <td>EE..EF    <td>80..BF     <td>80..BF    <td>
 *  <tr><td>U+10000..U+3FFFF  <td>F0        <td><b><i>90</i></b>..BF     <td>80..BF    <td>80..BF
 *  <tr><td>U+40000..U+FFFFF  <td>F1..F3    <td>80..BF     <td>80..BF    <td>80..BF
 *  <tr><td>U+100000..U+10FFFF<td>F4        <td>80..<b><i>8F</i></b>     <td>80..BF    <td>80..BF  
 *  </table> 
 * 
 *  <p>In Table 3-7, cases where a trailing byte range is not 80..BF are shown in bold italic to draw
 *    attention to them. These exceptions to the general pattern occur only in the second byte of
 *    a sequence.
 *
 *  <p>[End quote]
 *  <p>Based on this table, the <code>activate</code> method will build a Finite State Machine. States will be coded into two
 *  TRANSLATE tables, <code>tablei</code> and <code>tableo</code>.
 *
 *  @param <code>string</code> The string to validate/convert.
 *  @param <code>option = ""</code> What to do if we find an encoding error. <code>"Syntax"</code> produces a syntax error, and <code>""</code> (the default) returns the null string.
 *  @param <code>format = "UTF8"</code> Format may be the null string, "UTF8" or "UTF-8", in which case a UTF-8 version of the argument string is returned; 
 *                                      it can be "UTF-32" or "UTF-32", in which case a UTF-32 version of the string is returned; or it can be any combination
 *                                      of blank-separated values (repetitions are allowed). If both UTF-8 and
 *                                      UTF-32 versions are requested, the returned value is an array containing the UTF-8 and the
 *                                      UTF-32 versions of the argument string (in this order).
 *  @condition <code>Syntax 93.900</code> Invalid option '<em>option</em>'.
 *  @condition <code>Syntax 93.900</code> Invalid format '<em>format</em>'.
 *  @condition <code>Syntax 23.900</code> Invalid UTF-8 sequence in position <em>n</em> of string: '<em>hex-value</em>'X.
 *  @see <code>activate</code>
 *
 */
 
::Method UTF8 Class 
  Expose tablei tableo ASCII  -- Built by the "activate" method
   
  Use Strict Arg string, format = "", errorHandling = ""
  
  -- Check that the supplied arguments are OK, and raise a Syntax condition if not
  Parse Value self~checkDecodeOptions(format, errorHandling) With errorHandling returnUTF8 returnUTF32  
 
  -- Null UTF-8 strings decode to the null string.
  If string == "" Then Signal StringIsEmpty 
  
  string = string~makeString -- Demote to pure .String to avoid loops

  -- Build the states line. We will work in parallel with "string" and "states"
  states = Translate(string, tableo, tablei)
  
  -- Will hold the utf8 value, if needed
  utf8  = .MutableBuffer~new
    
  -- Will hold the utf32 value, if needed
  utf32 = .MutableBuffer~new

  repl     = errorHandling == "REPLACE"
  syntax   = errorHandling == "SYNTAX"
  null     = errorHandling == "NULL"  
  validate = 0
  If \returnUTF8, \returnUTF32 Then validate = 1
  
  i      = 0
  length = Length(string)
  
continueScan:
  i += 1
  -- Did we scan the whole string without errors? The string is good.
  If i > length Then Signal StringIsGood
  
  -- If the rest of the string is composed only of ASCII characters, then
  -- the string is good.
  save = i
  If OnlyASCIIsLeft() Then Do
    -- Copy all ASCIIs left
    Do i = i to length
      If returnUTF32 Then utf32~append( "000000"x || string[i] )
      If returnUTF8  Then utf8 ~append(              string[i] )
    End
    Signal StringIsGood
  End
   
  -- Copy all ASCIIs, up to i-1
  Do j = save to i - 1
    If returnUTF32 Then utf32~append( "000000"x || string[j] )
    If returnUTF8  Then utf8 ~append(              string[j] )
  End 
  
  -- Not an ASCII character.
  state = states[i]
  Signal (state)

  -- An illegal character is illegal, and a lone continuation character
  -- is also illegal.
"I": "C": 
  If validate Then Return 0
  If null     Then Return ""
  errorSequence = string[i]
  If syntax Then Signal Syntax
  Call ReplaceCharacter
  Signal continueScan
  
--
-- TWO-BYTE SEQUENCES
--  
"20"X:
  -- We need a two-byte sequence. 
  If states[i+1] \== "C" Then Do
    If validate Then Return 0
    If null     Then Return ""
    errorSequence = string[i,2]
    If syntax Then Signal Syntax
    Call ReplaceCharacter
  End
  Else Do
    If returnUTF32 Then Do
      y = Right(X2B(C2X(string[i  ])), 5)
      x = Right(X2B(C2X(string[i+1])), 6)
      utf32~append( "0000"X || X2C(B2X("00000"||y||x)) )
    End
    If returnUTF8  Then utf8~append(string[i,2])
  End
  i += 1
  Signal continueScan

--
-- THREE-BYTE SEQUENCES
--    
"3a"X: "3b"X: "3c"X:      
  -- We need exactly a three-byte sequence
  If states[i+1,2] \== "CC"    Then Do
    errorSequence = string[i,3]
    Signal 3Error
  End
  Select case state
    When "3b"X Then Signal 3OK
    When "3a"X Then 
      If string[i+1] < "A0"X Then Do
        errorSequence = string[i,3]
        Signal 3Error
      End
    When "3c"X Then 
      If string[i+1] > "9F"X Then Do
        errorSequence = string[i,3]
        Signal 3Error
      End
  End
3OK:
  If returnUTF32 Then Do
    z = Right(X2B(C2X(string[i  ])), 4)
    y = Right(X2B(C2X(string[i+1])), 6)
    x = Right(X2B(C2X(string[i+2])), 6)
    utf32~append( "0000"X || X2C(B2X(z||y||x)) )
  End
  If returnUTF8  Then utf8~append(string[i,3])
3End:  
  i = i + 2
  Signal continueScan
3Error:  
  If validate Then Return 0
  If null     Then Return ""
  If syntax Then Signal Syntax
  Call ReplaceCharacter
  Signal 3End

--
-- FOUR-BYTE SEQUENCES
--      
"4a"X: "4b"X: "4c"X:     
  -- We need a four-byte sequence. No continuation, or only one or two
  -- continuations are errors.
  If states[i+1,3] \== "CCC"   Then Do
    errorSequence = string[i,4]
    Signal 4Error
  End
  Select case state
    When "4b"X Then Signal 4OK
    When "4a"X Then 
      If string[i+1] < "90"X Then Do
        errorSequence = string[i,4]
        Signal 4Error
      End
    When "4c"X Then 
      If string[i+1] > "8F"X Then Do
        errorSequence = string[i,4]
        Signal 4Error        
      End
  End
4OK:
  If returnUTF32 Then Do
    u = Right(X2B(C2X(string[i  ])), 3)
    z = Right(X2B(C2X(string[i+1])), 6)
    y = Right(X2B(C2X(string[i+2])), 6)
    x = Right(X2B(C2X(string[i+3])), 6)
    utf32~append( "00"X || X2C(B2X(Right(u||z||y||x,24,0))) )
  End
  If returnUTF8  Then utf8~append(string[i,4])
4End:  
  i = i + 3  
  Signal continueScan
4Error:  
  If validate Then Return 0
  If null     Then Return ""
  If syntax Then Signal Syntax
  Call ReplaceCharacter
  Signal 4End
  
ReplaceCharacter:
  If returnUTF8  Then utf8 ~append(   "efbfbd"X )
  If returnUTF32 Then utf32~append( "0000FFFD"X )
Return    
  
OnlyASCIIsLeft:
  pos = Verify(states, ASCII, "N", i)
  If pos == 0 Then Return 1        -- Only ASCIIs left, string is good.
  i   = pos                        -- Set the new i
  Return 0
  
StringIsEmpty:  
  If returnUTF8  Then Return ""
  If returnUTF32 Then Return ""
  -- Validate. "" is valid UTF-8
  Return 1 
    
StringIsGood:
  If returnUTF8  Then
    If returnUTF32 Then Return utf8~string, utf32~string -- An array
    Else                Return utf8~string
  If returnUTF32 Then   Return utf32~string
  -- No target formats? Validate only
  Return 1 
  
Syntax:
  If syntax Then
    Raise Syntax 23.900 Additional("Invalid UTF-8 sequence in position" i "of string: '"C2X(errorSequence)"'X") 
  If returnUTF8 Then
    If returnUTF32 Then Return utf8~string, utf32~string -- An array
    Else                Return utf8~string
  If returnUTF32   Then Return utf32~string  
  -- Validation only
  Return 0