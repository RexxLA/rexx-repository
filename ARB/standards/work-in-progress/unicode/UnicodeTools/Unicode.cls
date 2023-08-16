/**
 * <h2>The UNICODE Tools Of Rexx (TUTOR)</h2>
 *
 *<pre><code>   This file is part of <a href="https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools">the Unicode Tools Of Rexx</a> (TUTOR). 
 *   See <a href="https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/">https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/</a> for more information.
 *   Copyright &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;.
 *   License: Apache License 2.0 (<a href="https://www.apache.org/licenses/LICENSE-2.0">https://www.apache.org/licenses/LICENSE-2.0</a>).</code></pre>
 *
 * <h3><code>Unicode.cls</code>: The main Unicode Tools Of Rexx file</h3>
 *
 * <p>This classfile offers a set of public Unicode routines that implement
 *   the basic Unicode Tools Of Rexx architecture. Some of these routines are:
 *
 * <pre><code>
 *   BYTES(string)         -- Creates a new string composed of bytes
 *   CODEPOINTS(string)    -- Creates a new string composed of Unicode codepoints
 *   TEXT(string)          -- Creates a new string composed of grapheme clusters
 *   UNICODE(code,"Property",propertyName)                                  
 *     The swiss-knife Unicode BIF. It allows to map codepoints to Unicode properties.
 *   C2U(string[,format]) -- Returns the set of codepoints that compose the string in a series of formats
 *   P2N(code)            -- codePoints To Name: returns the Unicode Name property
 *   N2P(name)            -- Name To codePoints: transforms a Unicode name or alias into a normalized codepoint
 * </code></pre>
 *
 * <p>
 *   Although the whole set of Unicode Tools can be used in a purely
 *   procedural way, the Tools are implemented by a set of classes, defined
 *   in this file. These are:
 *
 * <pre><code>
 *   .BYTES           -- Similar to .String, it implements a string composed of bytes
 *   .CODEPOINTS      -- Implements a string composed of Unicode codepoints
 *   .TEXT            -- Implements a string composed of extended grapheme clusters
 * </code></pre>
 *
 * <p>
 *   These classes implement the usual built-in methods (BIMs), but adapted
 *   to the elementary constituents of each class.
 *
 * <p>
 *   With some exceptions, which are detailed in the description of each !-BIF
 *   (see below), standard Rexx built-in functions (BIFs) continue to work 
 *   "in the same way" with <code>CODEPOINTS</code> or <code>TEXT</code> strings that they do with Classic 
 *   Rexx strings. "In the same way" means that they implement the same 
 *   logical operations, but applied, in each case, to their ultimate constituents. 
 *   For example, <code>SUBSTR</code>, when applied to a <code>CODEPOINTS</code> string, will operate 
 *   on codepoints; and <code>POS</code>, when applied to a <code>TEXT</code> string, will operate 
 *   at the extended grapheme cluster level.
 *
 * <p>
 *   The Rexx language does not allow any overriding of BIFs except by internal
 *   routines, that is, it is not possible to design a new set of BIFs that
 *   reside in an external file. To overcome this difficulty, Unicode.cls
 *   can be used with <em>the Rexx Preprocessor for Unicode</em>, <code>rxu.rex</code>.
 *   The preprocessor substitutes calls to the Rexx built-in functions by
 *   equivalent calls to functions with a new name, obtained by prefixing an
 *   exclamation mark character (<code>"!"</code>) to the standard BIF name.
 *   For example, the preprocessor replaces function calls like <code>Length(var)</code>
 *   with <code>!Lenght(var)</code>, and <code>CALL</code> instructions like
 * <pre><code>Call Stream filename, "Command", "Query exists"</code></pre>
 * <p>with
 * <pre><code>Call !Stream filename, "Command", "Query exists"</code></pre>
 * <p>
 *   <code>Unicode.cls</code> implements these substitution !-BIFs (as we
 *   could call them), adding new functionality when needed, and rerouting
 *   the calls to the corresponding BIM, depending on the class of the
 *   string. This means, for example, that, when using the new <code>rxu</code>
 *   command one can program in a purely procedural way, handle strings in the
 *   usual, Classic Rexx, way, and when one <em>promotes</em> a string, say,
 *   to <code>TEXT</code>, by using a <code>Text(string)</code> function call, she can
 *   expect the returned value to "magically" function as a normal string
 *   that operates on extended grapheme clusters instead of on characters.
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
 *  </table>
 *
 *  @author &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;  
 *  @version 1.0
 */

.local~bytes          = .Bytes       -- Make sure .Bytes is known everywhere
.local~codepoints     = .Codepoints  -- Make sure .Codepoints is known everywhere
.local~text           = .Text        -- Make sure .Text is known everywhere

::Routine Unicode Public
  Use Arg, option
  option = Upper( Strip( option ) )
  Select
    When "PROPERTY"~Abbrev(option,1) Then Signal Properties
    Otherwise Raise Syntax 88.900 Additional("Invalid option '"Arg(2)"'")
  End
    
Properties:
  Use Strict Arg code, option , property
  
  code = Upper( code )
  If \DataType(code,"X") | Length(code) > 6 Then
    Raise Syntax 40.900 Additional("Invalid code '"code"'")
  n = X2D(code)
  If n > 1114111 Then 
    Raise Syntax 40.900 Additional("Invalid code '"code"'")
  If Length(code) < 4 Then code = Right(code,4,0)
  Else If Length(code) > 4 Then
    Do While code[1] == "0"
      code = SubStr(code,2)
      If Length(code) == 4 Then Leave
    End
    
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

/**
 *
 * <h4><code>N2P</code> (Name to codePoint)</h4>
 *
 * <code><pre>
 *
 * <b>N2P(</b> <em>name</em> <b>)</b>
 * </pre></code> 
 *
 * <p>
 *   Returns the hexadecimal Unicode codepoint corresponding to <em>name</em>, or the null string if <em>name</em>
 *   does not correspond to a Unicode codepoint. 
 *
 * <p>
 *   <code>N2P</code> accepts <em>names</em>, as defined in the second 
 *   column of <code>UnicodeData.txt</code> (that is, the Unicode "Name" ("Na") property), like 
 *   <code>"LATIN CAPITAL LETTER F"</code> or <code>"BELL"</code>; <em>aliases</em>, as defined in 
 *   <code>NameAliases.txt</code>, like <code>"LF"</code> or <code>"FORM FEED"</code>, and <em>labels</em> 
 *   identifying codepoints that have no names, like <code>"&lt;Control-0001&gt;"</code> or <code>"&lt;Private Use-E000&gt;"</code>.
 *
 * <p>
 *   When specifying a name, case is ignored, as are certain characters: spaces, medial dashes
 *   (except for the "HANGUL JUNGSEONG O-E" codepoint) and underscores that replace dashes. Hence, <code>"BELL"</code>,
 *   <code>"bell"</code> and <code>"Bell"</code> are all equivalent, as are <code>"LATIN CAPITAL LETTER F"</code>,
 *   <code>"Latin capital letter F"</code> and <code>"latin_capital_letter_f"</code>.
 *
 * <p>
 *   Returned codepoints will have a minimum length of four digits, and will never start with a zero if they have
 *   more than four digits.
 *
 * <p><b>Examples:</b>
 *
 * <code><pre>
 * N2P("LATIN CAPITAL LETTER F") =  "0046"       -- Padded to four digits
 * N2P("BELL")                   = "1F514"       -- Not "01F514"
 * N2P("Potato")                 = "1F954"       -- Unicode has "Potato" (a vegetable emoticon)..
 * N2P("Potatoes")               = ""            -- ..but no "Potatoes".</pre></code>
 *
 */

::Routine N2P Public
  Use Strict Arg name
  If .Unicode.Name == ".UNICODE.NAME" Then .Context~package~loadPackage("properties/name.cls")  
  Return .Unicode.Name~n2p( name )

/**
 *
 * <h4><code>P2N</code> (codePoint to Name)</h4>
 *
 * <code><pre>
 *
 * <b>N2P(</b> <em>codepoint</em> <b>)</b>
 * </pre></code> 
 *
 * <p>
 *   Returns the name or label corresponding to the hexadecimal Unicode <em>codepoint</em> argument, or the null string if the
 *   <em>codepoint</em> has no name or label.
 *
 * <p>
 *   The argument <em>codepoint</em> is first <em>verified</em> for validity. If it is not a valid hexadecimal number or it is
 *   out-of-range, a null string is returned. If the codepoint is found to be valid, it is then <em>normalized</em>: 
 *   if it has less than four digits, zeros are added to the left, until the codepoint has exactly four digits; 
 *   and if the codepoint has more than four digits, leading zeros are removed, until no more zeros are found or
 *   the codepoint has exactly four characters.
 *
 * <p>
 *   Once the codepoint has been validated and normalized, it is uppercased, and the Unicode Character Database 
 *   is then searched for the "Name" ("Na") property. If the codepoint has a name, that name is returned. 
 *   If the codepoint does not have a name but it has a label, like <code>"&lt;control-0010&gt;"</code>, the label is returned. 
 *   In all other cases, the null string is returned.
 *
 * <p>
 *   <b>Note.</b> Labels are always enclosed between "&lt;" and "&gt;" signs. This allows to quickly distinguish them from names.
 *
 * <p><b>Examples:</b>
 *
 * <code><pre>
 * P2N("46")      =  "LATIN CAPITAL LETTER F"    -- Normalized to "0046"
 * P2N("0046")    =  "LATIN CAPITAL LETTER F"    -- Normalized to "0046"
 * P2N("0000046") =  "LATIN CAPITAL LETTER F"    -- Normalized to "0046"
 * P2N("1F342")   =  "FALLEN LEAF"               -- An emoji
 * P2N("0012")    =  "&lt;control-0012&gt;"            -- A label, not a name
 * P2N("XXX")     =  ""                          -- Invalid codepoint
 * P2N("110000")  =  ""                          -- Out-of-range</pre></code>
 *   
 */

::Routine P2N Public
Use Strict Arg code
  If .Unicode.Name == ".UNICODE.NAME" Then .Context~package~loadPackage("properties/name.cls")  
  Return .Unicode.Name[ code ]

/**
 *
 * <h4><code>STRINGTYPE</code></h4> 
 *
 * <code><pre>
 *
 * <b>STRINGTYPE(</b> <em>string</em>  >─┬────────┬─> <b>)</b>
 *                       └─ <em>type</em> ─┘</pre></code>
 *
 * <p>
 *   If you specify only <em>string</em>, it returns <b>TEXT</b> when <em>string</em> is a <code>TEXT</code> string,
 *   <b>CODEPOINTS</b> when <em>string</em> is a <code>CODEPOINTS</code> string, and <b>BYTES</b> when <em>string</em>
 *   is a <code>BYTES</code> string.
 *
 * <p>
 *   If you specify <em>type</em>, it returns <b>1</b> if the string matches the type. Otherwise, it returns <b>0</b>.
 *   The following are valid types. (Only the capitalized letter is needed; all
 *   characters following it are ignored.)
 *
 * <dl>
 *   <dt>Bytes<dd>Returns <b>1</b> if the string is a <code>BYTES</code> string.
 *   <dt>Codepoints<dd>Returns <b>1</b> if the string is a <code>CODEPOINTS</code> string.
 *   <dt>Text<dd>Returns <b>1</b> if the string is a <code>TEXT</code> string. 
 * </dl>
 *
 */

::Routine STRINGTYPE Public
  Use Strict Arg string, option = ""
  .Validate~classType( "option" , option , .String )
  option = Upper(option)
  Select
    When Abbrev("BYTES",      option,1) Then Return self~stringType == "BYTES"
    When Abbrev("CODEPOINTS", option,1) Then Return self~stringType == "CODEPOINTS"
    When Abbrev("TEXT",       option,1) Then Return self~stringType == "TEXT"
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

/**
 *
 * <h4><code>BYTES</code> (Convert a string to a <code>BYTES</code> string)</code></h4> 
 *
 * <code><pre>
 *
 * <b>BYTES(</b> <em>string</em> <b>)</b></pre></code>
 *
 * <p>
 *   Converts <em>string</em> to a <code>BYTES</code> string and returns it. <code>BYTES</code> strings are
 *   composed of 8-bit bytes, and every character in the string can be an arbitrary 8-bit value, including
 *   binary data. Rexx built-in-functions operate at the byte level, and no Unicode features are available
 *   (for example, <code>LOWER</code> operates only on the ranges "A".."Z" and "a".."z").
 *
 */


::Routine BYTES Public
  Use Strict Arg string
  return .Bytes~new(string)

/**
 *
 * <h4><code>CODEPOINTS</code> (Convert a string to a <code>CODEPOINTS</code> string)</code></h4> 
 *
 * <code><pre>
 *
 * <b>CODEPOINTS(</b> <em>string</em> <b>)</b></pre></code>
 *
 * <p>
 *   Converts <em>string</em> to a <code>CODEPOINTS</code> string and returns it. <code>CODEPOINTS</code> strings
 *   are composed of Unicode codepoints, and every character in the string can be an arbitrary Unicode codepoint.
 *   The argument <em>string</em> has to contain well-formed UTF-8, or a Syntax error is raised. Built-in functions
 *   operate at the codepoint level, and can produce much richer results than when operating on <code>BYTES</code>
 *   strings.
 * 
 * <p>
 *   Please note that <code>CODEPOINTS</code> and <code>TEXT</code> strings are guaranteed to contain 
 *   well-formed UTF-8 sequences. To test if a string contains well-formed UTF-8, you can use the 
 *   <code>DECODE(string,"UTF-8")</code> function call.
 *
 */

::Routine CODEPOINTS Public
  Use Strict Arg string
  Return .Codepoints~new(string)

/**
 *
 * <h4><code>TEXT</code> (Convert a string to a <code>TEXT</code> string)</code></h4> 
 *
 * <code><pre>
 *
 * <b>TEXT(</b> <em>string</em> <b>)</b></pre></code>
 *
 * <p>
 *   Converts <em>string</em> to a <code>TEXT</code> string and returns it. <code>TEXT</code> strings are composed
 *   of extended grapheme clusters, and every character in the string can be an arbitrary extended grapheme cluster.
 *   The argument <em>string</em> has to contain well-formed UTF-8, or a Syntax error is raised. Built-in functions
 *   operate at the extended grapheme cluster level, and can produce much richer results than when operating in
 *   <code>BYTES</code> or <code>CODEPOINTS</code> strings.
 *
 * <p>
 *   Please note that <code>CODEPOINTS</code> and <code>TEXT</code> strings are guaranteed to contain well-formed UTF-8 sequences.
 *   To test if a string contains well-formed UTF-8, you can use the <code>DECODE(string,"UTF-8")</code> function call.
 *
 */

::Routine TEXT Public
  Use Strict Arg string
  Return .Text~new(string)
    
/**
 *
 * <h4><code>C2U</code> (Character to Unicode codepoint)</h4>
 * <code><pre>
 *
 * <b>C2U(</b> <em>string</em> ┬────────────┬─> <b>)</b>
 *             └─ <b>,</b> <em>format</em> ─┘</pre></code>
 *
 * <p>
 *   Returns a string, in character format, that represents <em>string</em> converted to Unicode codepoints.
 *   By default, <code>C2U</code> returns a list of blank-separated hexadecimal representations of the
 *   codepoints. The <em>format</em> argument allows to select different formats for the returned string.
 *
 * <ul>
 *  <li>When <em>format</em> is the null string or <code>"Codes"</code> (the default), <code>C2U</code>
 *    returns a list of blank-separated hexadecimal codepoints. Codepoints larger than "FFFF"X will have their
 *    leading zeros removed, if any. Codepoints smaller than "10000"X will always have four digits (by adding
 *    zeros to the left if necessary).
 *  <li>When <em>format</em> is <code>"U+"</code>, a list of hexadecimal codepoints is returned. Each codepoint is
 *    prefixed with the characters <code>"U+"</code>.
 *  <li>When <em>format</em> is <code>"Names"</code>, each codepoint is substituted by its corresponding
 *    name or label, between parenthesis. For example, C2U("S") == "(LATIN CAPITAL LETTER S)", and
 *    C2U("0A"X) = "(&lt;control-000A&gt;)".
 *  <li>When <em>format</em> is <code>"UTF-32"</code>, a UTF-32 representation of the string is returned.
 * </ul>
 *
 * <p><b>Examples</b> (assuming an ambient encoding of UTF-8):
 *
 * <code><pre>
 * C2U("Sí")       = "0053 00ED"       -- And "0053 00ED"U == "53 C3AD"X == "Sí".
 * C2U("Sí","U+")  = "U+0053 U+00ED"   -- Again, "U+0053 U+00ED"U == "53 C3AD"X == "Sí".
 * C2U("Sí","Na")  = "(LATIN CAPITAL LETTER S) (LATIN SMALL LETTER I WITH ACUTE)"
 *                                     -- And "(LATIN CAPITAL LETTER S) (LATIN SMALL LETTER I WITH ACUTE)"U == "Sí"
 * C2U("Sí","UTF-32") = "0000 0053 0000 00ED"X
 * </pre></code>
 */   
    
::Routine C2U Public  
  Use Strict Arg string, format=""
  Return string~C2U(format) 
  
/**
 *
 * <h4><code>DECODE</code> (new BIF)</h4>
 *
 * <code><pre>
 *
 * <b>DECODE(</b> <em>string</em> , <em>encoding</em> , >─┬──────────┬──┬───────────────────┬─> <b>)</b>
 *                               └─ <em>format</em> ─┘  └─ , <em>errorHandling</em> ─┘
 * </pre></code>
 * <p><code>DECODE</code> tests whether a <code>string</code> is encoded according to a certain <code>encoding</code>, 
 *   and optionally decodes it to a certain <code>format</code>.
 *
 * <p><code>DECODE</code> works as an <code>encoding</code> <em>validator</em> when <code>format</code> is omitted, and
 *   as a <em>decoder</em> when <code>format</code> is specified. It is an error to omit <code>format</code> and to specify
 *   a value for <code>errorHandling</code> at the same time (that is, if <code>format</code> was omitted, then
 *   <code>errorHandling</code> should be omitted too).
 *
 * <p>When <code>DECODE</code> is used as <em>validator</em>, it returns a boolean value, indicating
 *   if the <code>string</code> is well-formed according to the specified <code>encoding</code>.
 *   For example, <code>DECODE(string,"UTF-8")</code> returns <code>1</code> when string contains well-formed
 *   UTF-8, and 0 if it contains ill-formed UTF-8.
 *
 * <p>To use <code>DECODE</code> as a <em>decoder</em>, you have to specify a <code>format</code>. This argument accepts a blank-separated
 *   set of tokens. Each token can have one of the following values: <code>"UTF8"</code>, <code>"UTF-8"</code>, <code>"UTF32"</code>, or
 *   <code>"UTF-32"</code> (duplicates are allowed and ignored). When <code>"UTF8"</code> or <code>"UTF-8"</code> have been specified,
 *   a UTF-8 representation of the decoded string is returned. When <code>"UTF32"</code> or <code>"UTF-32"</code> have been specified,
 *   UTF-32 representation of the decoded string is returned. When both have been specified, an two-items array is returned. The first item
 *   of the array is the UTF-8 representation of the decoded string, and the second item of the array contains the UTF-32 representation
 *   of the decoded string.
 *
 * <p>The optional <code>errorHandling</code> argument determines the behaviour of the function when the <code>format</code> argument
 *   has been specified. If if has the value <code>""</code> (the default) or <code>"NULL"</code>, a null string is returned when there
 *   a decoding error is encountered. If it has the value <code>"REPLACE"</code>, any ill-formed character will be replaced by the
 *   Unicode Replacement Character (U+FFFD). If it has the value <code>"SYNTAX"</code>, a Syntax condition will be raised when
 *   a decoding error is encountered.
 *
 * <p><b>Examples:</b>
 *
 * <code><pre> 
 * DECODE(string, "UTF-16")                           -- Returns 1 if <em>string</em> contains proper UTF-8, and 0 otherwise
 * var = DECODE(string, "UTF-16", "UTF-8")            -- Decodes <em>string</em> to the UTF-8 format. A null string is returned if <em>string</em> contains ill-formed UTF-16.
 * DECODE(string, "UTF-16",,"SYNTAX")                 -- The fourth argument is checked for validity and then ignored.
 * DECODE(string, "UTF-16",,"POTATO")                 -- Syntax error (Invalid option 'POTATO').
 * var = DECODE(string, "UTF-16", "UTF-8", "REPLACE") -- Decodes <em>string</em> to the UTF-8 format. Ill-formed character sequences are replaced by U+FFFD.
 * var = DECODE(string, "UTF-16", "UTF-8", "SYNTAX")  -- Decodes <em>string</em> to the UTF-8 format. Any ill-formed character sequence will raise a Syntax error.
 * </pre></code>
 */ 
  
::Routine DECODE Public  
  Use Strict Arg string, encoding, format="", errorHandling=""
  Return .Encoding[encoding]~decode(string, format, errorHandling)  
  
/**
 *
 * <h4><code>ENCODE</code> (new BIF)</h4>
 *
 * <code><pre>
 *
 * <b>ENCODE(</b> <em>string</em> , <em>encoding</em> , >─┬───────────────────┬─> <b>)</b>
 *                               └─ , <em>errorHandling</em> ─┘
 * </pre></code>
 * <p><code>ENCODE</code> first attempts to normalize the <em>string</em>, if necessary.
 *   Once the string is normalized, an encoding is attempted using the specified <em>encoding</em>. 
 *   <code>ENCODE</code> returns the encoded string, or a null string if any of normalization or encoding failed. 
 *   You can influence the behaviour of the function when an error is encountered by specifying the optional 
 *   <em>errorHandling</em> argument.
 *
 * <ul>
 *   <li>When <em>errorHandling</em> is not specified, is <code>""</code> or is <code>"NULL"</code> (the default),
 *     a null string is returned if an error is encountered.
 *   <li>When <em>errorHandling</em> has the value <code>"SYNTAX"</code>, a Syntax error is raised if an error
 *      is encountered.
 * </ul>
 *
 * <p><b>Examples:</b>
 *
 * <code><pre> 
 * ENCODE(string, "IBM1047")                          -- The encoded string, or "" if <em>string</em> can not be encoded to IBM1047.
 * ENCODE(string, "IBM1047","SYNTAX")                 -- The encoded string. If the encoding fails, a Syntax error is raised.
 * </pre></code>
 */ 

::Routine ENCODE Public  
  Use Strict Arg string, encoding, errorHandling=""
  Return .Encoding[encoding]~encode(string, errorHandling)  
  
/**
 *                                                                           
 * <h4>Implementation of some classic Rexx BIFs</h4>
 *                                                                            
 * <p>
 *   Names are preceded with <code>"!"</code>, like in <code>"!Length"</code>.
 *   An internal routine called <code>Length</code> will be needed that calls <code>!Length</code>,   
 *   or a preprocessor like <code>rxu</code>, the Rexx Preprocessor for Unicode,
 *   that substitutes calls to <code>Length</code> by calls to          
 *   <code>!Length</code>, as there is no other way to override BIFs.
 *                                                                            
 */ 

::Routine !C2X Public
  Use Strict Arg string
Return string~c2x

::Routine !CENTER Public
  Use Strict Arg string, length, pad = " "
Return string~center(length, pad)  

::Routine !CENTRE Public
  Use Strict Arg string, length, pad = " "
Return string~centre(length, pad)  

::Routine !COPIES Public
  Use Strict Arg string, n
Return string~copies(n)

/**
 *  <h4>Helper routine for the <code>DATATYPE</code> BIF</h4>
 *
 *  <p>The <code>DATATYPE</code> BIF is enhanced by supporting a new <code>"C"</code> option (for "uniCode").
 *
 *  <p>Please refer to the documentation for the <code>DATATYPE</code> method of the <code>BYTES</code> class.
 */

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
    
/**
 *                                                                          
 *  <h3>The <code>BYTES</code> class</h3>
 *
 *  <p> 
 *    The <code>BYTES</code> class is fundamentally equivalent to the ooRexx built-in      
 *    <code>STRING</code> class. <code>"Y"</code> strings and unpostfixed strings (when 
 *    <code>OPTIONS DEFAULTSTRING BYTES</code> is in effect) will be of this class. 
 *    Having an explicit class (a subclass of <code>STRING</code>) allows us to define fine-grained  
 *    rules about BIF or operation results for mixed-type classes.            
 *   
 *                                                                          
 */

::Class "Bytes" SubClass String Public

/**
 * <h4>C2U: character to Unicode codepoints</h4>
 *
 * <p>This method assumes that the target string contains well-formed UTF-8. If this
 *   is not the case, it will raise a Syntax condition.
 *
 * <p>Please note that <code>CODEPOINTS</code> and <code>BYTES</code> strings are always well-formed.
 *
 * <p><code>C2U</code> returns a <code>BYTES</code> string such that if a <code>U</code> were appended to it
 *   and it was inserted as a literal in a Rexx source program it would have
 *   the same string value as the target string.
 *
 * <ul>
 *   <li>
 *     <code>string~c2u</code> or <code>string~c2u("Codes")</code> (the default) will return a sequence of blank-separated codepoints,
 *     (without the <code>"U+"</code> prefix). Codepoints smaller than U+1000 will be
 *     padded on the left with zeros (<code>"0"</code>) until they are four bytes
 *     long. Codepoints larger that U+FFFF will have any leading zeroes removed.
 *     So, for example <code>"Sí"~C2U = "0053 00ED"</code>, and <code>"0053 00ED"U =
 *     "53 C3AD"X = "Sí"</code>, since UTF-8 for <code>"í"</code> is precisely
 *     <code>"C3AD"X</code>.
 *   <li><code>string~c2u("U+")</code> returns
 *      a list of blank-separated codepoints, with the <code>"U+"</code> prefix.
 *      For example, <code>"Sí"~C2U("U+") = "U+0053 U+00ED"</code>.
 *   <li><code>string~c2u("NAMES")</code> (abbreviable to "NA") returns a blank-separated
 *      list of the Unicode "Name" ("Na") property for each character in the target string.
 *      For example, <code>"Sí"~C2U("Na") = "(LATIN CAPITAL LETTER S) (LATIN SMALL LETTER I WITH ACUTE)"</code>.
 *   <li><code>string~c2u("UTF32")</code> returns a UTF-32 representation of the target string, 
 *      for example <code>"Sí"~C2U("UTF32") = "00000053 000000ED"X</code>.
 * </ul>
 */
::Method C2U
  Use Strict Arg format=""

  utf32 = .Encoding~UTF8(self,"UTF32","Syntax")
    
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

/**
 * <h4><code>U2C</code> Unicode codepoints to Character</h4>
 * 
 * <p>
 *   This method inspects the target string for validity (see below). If valid,
 *   it translated the corresponding codepoints to UTF8, and returns the UTF8 string.
 *   If not valid, a Syntax condition is raised.
 *
 * <p>
 *   You can use the <code>DATATYPE(string, "C")</code> BIF (for "uniCode") or the
 *   <code>DATATYPE("C")</code> method to verify whether a string is a proper Unicode codepoints string.
 *
 */
 
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

/**
 *
 * <h4>DATATYPE</h4>
 *
 * <p>The standard <code>DATATYPE</code> BIM is extended to accept a new value, "C", from "uniCode".
 * <code>String~datatype("C")</code> returns <code>1</code> if and only if <code>string</code>
 * follows the Unicode format, namely, if it consists of a blank-separated series of:
 *
 * <ul>
 *   <li>Valid hexadecimal Unicode codepoints, like <code>61</code>, or <code>200D</code>, or <code>1F514</code>.
 *   <li>Valid hexadecimal Unicode codepoints prefixed with "U+" or "u+", like <code>u+61</code>, or <code>U+200D</code>, or <code>u+1F514</code>.
 *   <li>Names, alias or labels that designate a Unicode codepoint, enclosed between parentheses, like <code>(Latin small letter A)</code>,
 *      <code>(ZWJ)</code>, <code>(Bell)</code>, or <code>(&lt;Control-001d&gt;)</code>.
 * </ul>
 */
  
::Method Datatype
  If Arg() > 1 Then Raise Syntax 93.902 Array(1)
  
  If Arg() == 0 Then Return self~datatype:.String
  
  If Arg(1) \== "C" Then Return self~datatype:.String(Arg(1))

  contents = self~makeString
  Do While contents \= " "
    contents = Strip(contents)
    If contents[1] == "(" Then Do
      Parse var contents "("name")"extra
      If extra == "" Then If \contents~endsWith(")") Then Return 0
      contents = Strip(extra)
      code = N2P(name)
      If code = "" Then Return 0
    End
    Else Do
      Parse Var contents word contents
      If Upper(word) == "U+"         Then Return 0
      If Upper(Left(word,2)) == "U+" Then word = SubStr(word,3)
      If \DataType(word,"X")         Then Return 0
      If X2D(word) > X2D(10FFFF)     Then Return 0
      If X2D(word) >= X2D(D800),,
         X2D(word) <= X2D(DFFF)      Then Return 0
    End
  End
Return 1
  
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
  Do i = n For length
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

/**
 *      
 *  <h3>The <code>CODEPOINTS</code> class</h3> 
 *
 *  <p>A .String-like class composed of Unicode codepoints
 *                                                                           
 *  <p>
 *    The <code>CODEPOINTS</code> class implements a new kind of string composed of Unicode
 *    codepoints instead of bytes ("characters"). Individual codepoints can be accessed 
 *    using the ooRexx <code>string[i]</code> notation or the Classic Rexx 
 *    <code>SUBSTR(string,index,1)</code> notation.
 *
 *  <p>
 *    Instances of the class <em>present</em> themselves as UTF-8 strings, that is, they
 *    look as UTF-8 strings, can be compared to raw UTF-8 strings, and so on. We write
 *    <em>present</em> instead of <em>represent</em> because we are not compromising on
 *    an (internal) <em>representation</em> of the codepoints, but on a frontier
 *    interchange <em>presentation</em>: when convenient, the strings look as a "normal"
 *    UTF-8 string, and that's all you need to know.
 *
 *  <p>
 *    Instances of the class can be created by resorting to the class <code>init</code>
 *    method (<code>.Codepoints~new("string")</code>), by using the new built-in function
 *    <code>CODEPOINTS</code> (<code>var = CodePoints("string")</code>), or by using the
 *    new <code>"string"P</code> string notation (requires the use of the <code>rxu</code>
 *    Rexx Preprocessor for Unicode). The strings are checked for UTF-8 well-formedness,
 *    and a Syntax error is raised if they are found to be ill-formed.
 *
 *  <p>
 *    Some of the usual BIFs, in a growing number (e.g., <code>LENGTH</code>, <code>SUBSTR</code>, 
 *    <code>[]</code>, <code>POS</code>, <code>COPIES</code>), are implemented at the codepoint level. 
 *    A new <code>C2U</code> method is provided: it returns a string composed of all the codepoints that        
 *    compose the receiving object, in a blank separated string.               
 *                                                                           
 *  <p>
 *    Codepoints strings can be created by using the <code>CODEPOINTS(string)</code>
 *    built-in function, or using the <code>"string"P</code> notation (requires the use
 *    of the <code>rxu</code> Rexx Preprocessor for Unicode).
 *
 *  <h4>Reimplementation of .String BIMs</h4>
 *
 *  <p>
 *    Only the most basic string manipulation BIMs, like <code>LENGTH</code> and <code>[]</code>, 
 *    are needed, since most of the the rest can be based on those. The majority
 *    of the reimplemented BIMs are thus defined in the <code>Bytes</code> class,
 *    which this class subclasses. They will work equally well with <code>Bytes</code>, 
 *    <code>Codepoints</code> and <code>Text</code> strings.
 *                                                                           
 *  <h4>Version history</h4>
 *            
 *  <table class="table">
 *    <tr><th>Ver.  <th>Aut.<th>Date    <th>Description
 *    <tr><td>00.1  <td>JMB <td>20230716<td>Initial release
 *    <tr><td>00.1c <td>JMB <td>20230718<td>Move property classes to the "property" subdir
 *    <tr><td>00.1d <td>JMB <td>20230719<td>Add support for LEFT, RIGHT and REVERSE
 *    <tr><td>00.1e <td>JMB <td>20230721<td>Add support for LOWER(n,length)
 *    <tr><td>00.1f <td>JMB <td> <td>Add support for UPPER(n,length)
 *    <tr><td>00.1f <td>JMB <td> <td>Make CODEPOINTS a subclass of BYTES, move to Unicode.cls 
 *  </table>
 */
 
::Class "Codepoints" SubClass Bytes Public

::Method init
  Expose utf32
    
  -- .Encoding~UTF8 will do both the validation and the conversion.
  utf32 = .Encoding~UTF8(self, "UTF32", "Syntax")

::Method "[]"
  Expose utf32
  Use Strict Arg n, length = 1
  .Validate~positiveWholeNumber( "n" , n )
  .Validate~nonNegativeWholeNumber( "length" , length )
  max = self~length
  If n > max     Then Return self~class~new("")
  If length == 0 Then Return self~class~new("")
  
  If n + length - 1 > max Then length = max - n + 1
    
  Return .Encoding["UTF32"]~decode(SubStr(utf32, 1 + (n-1)* 4, length * 4),"UTF8","Syntax")
  
::Method Length
  Expose utf32
  Return Length(utf32) / 4
    
                
/**
 *                                                                           
 *  <h3>The <code>TEXT</code> class</h3>
 *                                                                           
 *  <p>
 *    The <code>TEXT</code> class implements a new kind of string composed of Unicode       
 *    grapheme clusters. Some of the usual BIFs, in a growing number, (e.g., <code>LENGTH</code>, 
 *    <code>SUBSTR</code>, <code>[]</code>, <code>POS</code>, <code>COPIES</code>) are implemented 
 *    at the grapheme cluster level. The <code>C2U</code> method of the <code>CODEPOINTS</code>
 *    class is also available, since <code>TEXT</code> is a subclass of <code>CODEPOINTS</code>.  
 *                                                                           
 *  <p>
 *    When a <code>string</code> is a <code>TEXT</code> string, <code>string[i]</code> returns an (extended) grapheme   
 *    cluster, which is itself a <code>TEXT</code> string. You can use the <code>C2U</code> function 
 *    on <code>string[i]</code>, if so desired, to get the individual codepoints that       
 *    compose the i-th grapheme cluster of <code>string</code>.  
 *                                                                           
 *  <p>
 *    <code>TEXT</code> strings can be created by initializing an instance of the <code>TEXT</code>
 *    class (<code>.Text~new("string")</code>), by using the <code>TEXT("string")</code> built-in function,          
 *    or by using the <code>"string"T</code> notation (requires the use of the <code>rxu</code> Rexx Preprocessor for Unicode).        
 *                                                                           
 *  <h4>Version history</h4>
 *                                                                           
 *  <table class="table">
 *    <tr><th>Ver.  <th>Aut.<th>Date    <th>Description
 *    <tr><td>00.1  <td>JMB <td>20230716<td>Initial release
 *    <tr><td>00.1c <td>JMB <td>20230718<td>Move property classes to the "property" subdir
 *    <tr><td>00.2  <td>JMB <td>20230726<td>Merge code with Unicode.cls
 *  </table>
 *                                                                           
 */

::Class "Text" SubClass Codepoints Public
  
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

  
::Requires "Stream.cls"  
::Requires "properties/Properties.cls"
::Requires "encodings/Encoding.cls"