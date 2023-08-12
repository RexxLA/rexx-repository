/**
 *
 * <h3>The <code>RXU</code> Rexx Preprocessor for Unicode</h3>
 *
 *<pre><code>   This file is part of <a href="https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools">the Unicode Tools Of Rexx</a> (TUTOR). 
 *   See <a href="https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/">https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/</a> for more information.
 *   Copyright &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;.
 *   License: Apache License 2.0 (<a href="https://www.apache.org/licenses/LICENSE-2.0">https://www.apache.org/licenses/LICENSE-2.0</a>).</code></pre>
 *   
 * <h4>Description</h4>
 *
 * <p>
 *   The <b><code>RXU</code> Rexx Preprocessor for Unicode</b> is implemented as a Rexx program, <code>rxu.rex</code>.
 *   RXU reads a <code>.rxu</code> program and attempts to translate it to 
 *   standard <code>.rex</code> code (assuming that the Unicode library,
 *   <code>Unicode.cls</code>, has been loaded). If no errors are found in 
 *   the translation pass, the resulting <code>.rex</code> program is then
 *   executed, after which the <code>.rex</code> program is deleted.
 *   <code>RXU</code> programs can be written using an extended Rexx
 *   syntax, implementing a set of Unicode and non-Unicode literals,
 *   several new BIFs and BIMs, and a system of polymorphic BIFs that
 *   allow the programmer to continue using the same concepts and BIFs that
 *   in Classic Rexx, and at the same time take advantage of the power
 *   and novelties of the Unicode world.
 * </p>
 *
 * <h4>The RXU command</h4>
 *
 * <p>
 *   <code>RXU filename</code> converts a file named <code>filename</code> 
 *   (default extension: <code>.rxu</code>) into a <code>.rex</code> file, 
 *   and then interprets this <code>.rex</code> file.
 * </p>
 * 
 * <code><pre> Format:                                                                  
 *                                                                           
 *    [rexx] rxu [options] filename [arguments]                              
 *                                                                           
 *  Options:                                                                 
 *                                                                           
 *    /help, /h  : display help for the RXU command                          
 *    /keep, /k  : do not delete the generated .rex file                     
 *    /nokeep    : delete the generated .rex file (the default)              
 *    /warnbif   : warn when using unsupported BIFs                          
 *    /nowarnbif : don't warn when using unsupported BIFs (the default)
 *  </pre></code>
 * 
 *
 * <h4>Language implemented by the RXU Preprocessor for Rexx</h4>
 *
 * <p>
 *   A <code>.rxu</code> can use an extended ooRexx syntax with the following            
 *   new syntactical constructs:                                                          
 *
 *  <code><pre>
 *    "string"Y, a Classic Rexx string, composed of bytes.                   
 *    "string"P, a Codepoints string (checked for UTF8 correctness at parse time)                                              
 *    "string"T, a Text string (checked for UTF8 correctness at parse time)  
 *    "string"U, a Unicode codepoint string. Codepoints can be specified using hexadecimal notation (like 61, 0061, or 0000), 
 *               Unicode standard U+ notation (like U+0061 or U+0000), or as a name, alias or label enclosed in parenthesis 
 *               (like "(cr)", "(CR) (LF)", "(Woman) (zwj) (Man)"). A "U" string is always CODEPOINTS string.
 * </pre></code>
 *
 * <p>
 *   Calls to a number of BIFs are substituted by equivalent calls to         
 *   a function with a name formed by an exclamation mark (<code>"!"</code>) concatenated  
 *   to the BIF name. For example, <code>Length(var)</code> will be substituted by       
 *   <code>|Length(var)</code>. These !-functions have been defined in <code>Unicode.cls</code>       
 *   and are re-routed to the corresponding BIMs for the <code>Bytes</code> (String),      
 *   <code>Codepoints</code> and <code>Text</code> classes.                                             
 * </p>
 *     
 * <p> 
 *   The list of supported BIFs changes ofter. It is listed in the <code>BIFs</code> 
 *   variable at the start of the present code.                                                       
 * </p>
 *     
 * <p> 
 *   No checks are done to see if there are internal routines with the same    
 *   names as these BIFs.                                    
 * </p>
 *
 * <p>A number of new BIMs, BIFs and classes are defined and available. Please refer
 *   to the documentation for the <code>Unicode.cls</code> class for details.
 *
 * <h4>Implementation of the <code>OPTIONS</code> instruction</h4>
 *
 * <p>
 *   The <code>OPTIONS</code> instruction will only be recognized correctly by 
 *   the RXU preprocessor when
 * </p>
 *
 * <ol>
 *   <li>It appears by itself on a single line. 
 *   <li>It starts the line, maybe after some optional blanks (i.e., no previous comments.
 *   <li>It does not expand for more than one line.
 *   <li>It is composed exclusively of symbols taken as constants (i.e., no expressions are allowed).
 * </ol>  
 *
 * <p>
 *   Furthermore, the <code>OPTIONS</code> instruction should not appear inside a conditional 
 *   or repetitive instruction, or inside a procedure. If it does, results can
 *   be unpredictable.
 * </p>
 *
 * <code><pre>
 *   Recognized OPTIONS:
 *
 *   DEFAULTSTRING &lt;stringType&gt;
 *       Determines the interpretation of an unsuffixed string, i.e., "string", when no "B", "X", "C", "P", "T" or "U" suffix
 *       is specified. Possible values for &lt;stringType&gt; are BYTES, CODEPOINTS or TEXT. The preprocessor encloses unsuffixed
 *       strings with a call to the corresponding conversion BIF, e.g., if DEFAULTSTRING TEXT is in effect, then "string" 
 *       will be equivalent to TEXT("string").
 * </pre></code>
 *
 * <h4>Note</h4>
 *
 * <p>
 *   Please note that <code>rxu.rex</code> depends heavily on <code>Rexx.Tokenizer</code>, which is a 
 *   simple tokenizer, not a full parser. This imposes some restrictions on
 *   the source programs it can succesfully process.
 * </p>
 *
 * <p>In particular,
 *
 * <ul>
 *   <li>Please ensure that directives start at the beginning of the line,
 *     without intervening comments, and that they are not followed in the
 *     same line by an instruction (i.e., ensure that any possible instruction
 *     starts on one of the following lines).
 *
 *   <li>
 *     Please read carefully the above section about the OPTIONS instruction.
 * </ul>
 *
 * <h4>Version history</h4>
 *
 * <table class="table table-borderless" style="font-size:smaller">
 *   <thead>
 *      <tr>
 *        <th class="col-xs-1">Vers.</th>
 *        <th class="col-xs-1">Aut.</th>
 *        <th class="col-xs-2">Date</th>
 *        <th class="col-xs-8">Description</th>
 *     </tr>
 *   </thead>
 *   <tr><td>00.1d <td>JMB <td>20230719 <td>Initial release                                       
 *   <tr><td>00.1e <td>JMB <td>20230721 <td>Fix error when "0A"X, "0D"X or "1F"X in U string      
 *   <tr><td>      <td>    <td>         <td>Add LOWER(n, length)                                  
 *   <tr><td>00.2  <td>JMB <td>20230725 <td>Add Upper                                             
 *   <tr><td>      <td>    <td>         <td>CHARACTER STRINGS are explicitly BYTES                 
 *   <tr><td>      <td>    <td>         <td>Issue warnings for unsupported BIFs                   
 *   <tr><td>      <td>    <td>         <td>Add support for OPTIONS instruction (see below)       
 *   <tr><td>      <td>    <td>         <td>Add support for OPTIONS DEFAULTSTRING                 
 *   <tr><td>00.2a <td>JMB <td>20230727 <td>U strings are Codepoints, not Text.     
 *   <tr><td>      <td>    <td>         <td>Bug when source contains X or B strings.              
 *   <tr><td>      <td>    <td>         <td>Change RUNES to CODEPOINTS                            
 *   <tr><td>00.3  <td>JMB <td>20230728 <td>Remove support for OPTIONS CONVERSIONS.               
 *   <tr><td>      <td>    <td>20230728 <td>Change "C" suffix to "Y", as per Rony's suggestion
 *   <tr><td>      <td>    <td>20230804 <td>"U" strings are now BYTES
 *   <tr><td>      <td>    <td>         <td>Implement ENCODING in the STREAM BIF
 *   <tr><td>      <td>    <td>         <td>Fix some bugs where abbutals were not translated properly.
 *   <tr><td>      <td>    <td>         <td>Implement LINEIN
 *   <tr><td>      <td>    <td>         <td>Implement DATATYPE(string, "C")
 *   <tr><td>      <td>    <td>         <td>Implement CHARIN, CHAROUT, CHARS, LINES
 *   <tr><td>00.3  <td>JMB <td>20230811 <td>0.3 release
 * </table>
 *
 * @author &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;  
 * @version 0.3
 */

-- Implemented BIFs
BIFs   = "C2X CHARIN CHAROUT CHARS CENTER CENTRE COPIES DATATYPE LEFT LENGTH "
BIFs ||= "LINEIN LINEOUT LINES LOWER POS REVERSE RIGHT STREAM SUBSTR UPPER "
-- The following list is taken from rexxref, ooRexx 5.0
Unsupported   = "ABBREV ABD ADDRESS ARG B2X BEEP BITAND BITOR BITXOR C2D "
Unsupported ||= "CHANGESTR COMPARE CONDITION "
Unsupported ||= "COUNTSTR D2C D2X DATE DELSTR DELWORD DIGITS "
Unsupported ||= "DIRECTORY ENDLOCAL ERRORTEXT FILESPEC FORM FORMAT FUZZ "
Unsupported ||= "INSERT LASTPOS MAX MIN OVERLAY QUALIFY "
Unsupported ||= "QUEUED RANDOM RXFUNCADD RXFUNCDROP RXFUNCQUERY RXQUEUE "
Unsupported ||= "SETLOCAL SIGN SOURCELINE SPACE STRIP SUBWORD SYMBOL "
Unsupported ||= "TIME TRACE TRANSLATE TRUNC USERID VALUE VAR VERIFY WORD "
Unsupported ||= "WORDINDEX WORDLENGTH WORDPOS WORDS X2B X2C X2D XRANGE"

UnsupportedWarningIssued. = 0

keepOutputFile = 0

Signal On User Syntax.Error -- Rexx.Tokekiner and subclasses raise Syntax.Error

Parse Arg arguments

If arguments = "" Then Do
  Say .resources~help
  Exit 
End

-- Process options first

warnbif = 0

Do While Word(arguments,1)[1] == "/"
  Parse Var arguments "/"option arguments
  Select Case Upper(option)
    When "H", "HELP" Then Do
      Say .resources~help
      Exit 
    End
    When "K", "KEEP" Then keepOutputFile = 1
    When "NOKEEP"    Then keepOutputFile = 0
    When "WARNBIF"   Then warnbif = 1
    When "NOWARNBIF" Then warnbif = 0
    Otherwise
      Call LineOut .StdOut, "Invalid option '"option"'."
      Exit 1
  End
End

-- We don't handle filenames with blanks at the moment

Parse Var arguments filename arguments

If Pos(".",filename) == 0 Then Do
  inFile  = filename".rxu"
  outFile = filename".rex"
End
Else If filename~caselessEndsWith(".rxu") Then Do
  inFile  = filename
  outFile = Left(filename,Length(filename)-3)"rex"
End  
Else Do
  inFile  = filename
  outFile = filename".rex"
End

If Stream(inFile,"c","query exists") == "" Then Do
  Call LineOut .StdOut, "File '"inFile"' does not exist."
  Exit   
End

If .File~new(inFile)~isDirectory Then Do
  Call LineOut .StdOut, "'"inFile"' is a directory."
  Exit   
End

options = Upper(LineIn(infile))
Call Stream inFile,"C", "CLOSE"

--
-- Process options
--

defaultString = "Bytes"

size = Stream(inFile,"c","query size")
array = CharIn(inFile,1,size)~makeArray
Call Stream outFile, "C", "Open Write Replace"

-- Create a new tokenizer. The "Unicode" portion in the classname
-- will activate Unicode support on the tokenizer.

tokenizer = .ooRexx.Unicode.Tokenizer~new(array)

-- This will create a convenient set of symbolic constants

Do tc over tokenizer~tokenClasses
  Call Value tc[1], tc[2]
End

-- nextToken allows us one token of lookahead

nextToken        = .nil
token.           = ""
noDefaultLine.   = 0
callContext      = 1


-- Number of significant token: we discount blanks and comments
tokenNo          = -1

Do Forever

  Call GetAToken
  
  tokenNo += 1
    
  --
  -- Special processing:
  --
  --   OPTIONS instructions
  --   CALL instructions 
  --   Directives
  --
  
  If token.Location~word(2) == "1" Then Do
    line = token.Location~word(1)
    upperFirst = Upper(Word(array[line],1))
    Select
      When upperFirst == "OPTIONS" Then Call Options
      When Space(array[line],0)[1,2] == "::" Then noDefaultLine.line = 1
      Otherwise Nop
    End
  End
    
If token.Class == END_OF_SOURCE Then Leave

  If token.class == END_OF_LINE Then Do
    Call LineOut outFile, ""
    tokenNo     = 0
    callContext = 0
    Iterate
    -- Reset tokenNo. Simplification: we don't handle continuation characters
  End
  
  -- Classic comments, line comments and blanks do not contribute to the token count.
  -- Subtract one, so that it compensates with the +1 at the start of the loop.
  If token.class == CLASSIC_COMMENT Then Do
    Parse var token.location start startPos end endPos
    tokenNo    -= 1
    callContext = 0
    If start == end Then Do
      Call CharOut outFile, SubStr(array[start],startPos,endPos-startPos)
      Iterate
    End
    Do i = start To End
      Select Case i
        When start Then Call LineOut outFile, SubStr(array[start],startPos)
        When end   Then Call CharOut outFile, Left(array[end],endPos-1)
        Otherwise       Call LineOut outFile, array[i]
      End
    End
    Iterate
  End
  
  If (token.class == LINE_COMMENT) | (token.class == BLANK) Then Do
    tokenNo    -= 1
    Call CharOut outFile, token.value
  End
  
  needExplicitConcat = 0
  If token.class == VAR_SYMBOL | token.class == NUMBER | token.class == CONST_SYMBOL Then Do
    -- Insert "||" when abuttal, because strings will be enclosed in conversion bifs.
    If NextToken()["CLASS"] == STRING Then -- Abbuttal, insert explicit "||"
      needExplicitConcat = 1
  End
  
  Select Case token.class token.subClass
    -- Only check for BIFs when simple symbols. Stems and compounds cannot be BIFs
    When VAR_SYMBOL SIMPLE Then Do
      UValue = Upper(token.value)
      If WordPos(UValue,"THEN ELSE") > 0 Then tokenNo = 0
      If tokenNo == 1 Then Do
        If UValue == "CALL" Then callContext = 1
        Else callContext = 0
      End
      If tokenNo == 2, callContext, WordPos(UValue,BIFs) > 0 Then Do
        Call CharOut outFile, "!"token.value
        If warnBIF, WordPos(UValue,Unsupported) > 0 Then Do
          If UnsupportedWarningIssued.[UValue] == 0 Then Do
            UnsupportedWarningIssued.[UValue] = 1
            Say "WARNING: Unsupported BIF '"token.value"' used in program '"filename"'."
          End
        End
      End
      Else Do
        If NextToken()["CLASS"] == STRING Then Do -- Abbuttal, will have "||" inserted below
          Call CharOut outFile, token.value
        End
        Else Do -- Check for built-ins
          BIFPos = WordPos(UValue,BIFs)
          If BIFPos > 0, NextToken()["VALUE"] = "(" Then 
            Call CharOut outFile, "!"token.value
          Else Do
            If warnBIF, WordPos(UValue,Unsupported) > 0, NextToken()["VALUE"] = "(" Then Do
              If UnsupportedWarningIssued.[UValue] == 0 Then Do
                UnsupportedWarningIssued.[UValue] = 1
                Say "WARNING: Unsupported BIF '"token.value"' used in program '"filename"'."
              End
            End
            -- Prepare for THEN CALL or ELSE CALL. Won't handle THEN THEN CALL & similar properly.
            Call CharOut outFile, token.value
          End
        End
      End
    End
    When STRING UNOTATION Then
      Call CharOut outFile, "Bytes('"C2X(token.value)"'X)"
    When STRING HEXADECIMAL Then
      Call CharOut outFile, defaultString"('"C2X(token.value)"'X)"
    When STRING BINARY Then
      Call CharOut outFile, defaultString"('"X2B(C2X(token.value))"'B)"
    When STRING TEXT Then
      Call CharOut outFile, "Text('"ChangeStr("'",token.value,"''")"')"
    When STRING CODEPOINTS Then
      Call CharOut outFile, "Codepoints('"ChangeStr("'",token.value,"''")"')"
    When STRING BYTES Then
      Call CharOut outFile, "Bytes('"ChangeStr("'",token.value,"''")"')"
    When STRING CHARACTER Then
      If noDefaultLine.[token.Location~word(1)] Then 
        Call CharOut outFile, "'"ChangeStr("'",token.value,"''")"'"
      Else 
        Call CharOut outFile, defaultString"('"ChangeStr("'",token.value,"''")"')"
    Otherwise 
      If token.class == SPECIAL, token.value == ";" Then
        tokenNo = -1
      Call CharOut outFile, token.value
  End
  If needExplicitConcat Then Call CharOut outFile, "||"
  
End

Call LineOut outFile, ""
Call LineOut outFile, "::Requires 'Unicode.cls'" -- Duplicates don't do any harm

Call Stream inFile,  "C", "Close"
Call Stream outFile, "C", "Close"

-- Now run the .rex file!

Address COMMAND "rexx" outFile arguments

saveRC = rc

If \keepOutputFile Then .File~new(outFile)~delete

Exit saveRC

GetAToken:
  -- Did we pick the next token before? Then this is our token now
  If \nextToken~isNil Then Do
    token. = nextToken
    nextToken = .nil
  End
  -- No next token? Pick a new one then
  Else token. = tokenizer~getToken
Return

-- Implements lookahead
NextToken:
  If nextToken~isNil Then nextToken = tokenizer~getToken
Return nextToken  

Options:
  options = Upper(array[line])
  Do i = 2 To Words(options)
    option  = Word(options, i)
    option2 = Word(options, i + 1)
    Select
      When (option option2) == "DEFAULTSTRING BYTES"      Then Do; i += 1; defaultString = "Bytes";      End
      When (option option2) == "DEFAULTSTRING CODEPOINTS" Then Do; i += 1; defaultString = "Codepoints"; End
      When (option option2) == "DEFAULTSTRING TEXT"       Then Do; i += 1; defaultString = "Text";       End
      Otherwise Nop
    End
  End
Return  

Syntax.Error:
  additional = Condition("A")
  errNumber  = additional[1]
  lineNumber = additional[2]
  arguments  = additional[3]
  Parse Var errNumber errMajor"."
  errLines   = errorMessage(errNumber, arguments)
  Say "Error" errMajor "running" Qualify(inFile)" line" linenumber": " errLines[1]
  Say "Error" errNumber": " errLines[2]
  errLines   = errorMessage(errNumber, arguments)
Exit - errMajor

::Resource Help
rxu: A simple Unicode preprocessor for Rexx

Syntax:
  rxu [options] filename [arguments]

Default extension is ".rxu". A ".rex" file with the same name
will be created, replacing an existing one, if any.

Options (case insensitive):

  /h, /help: Displays this information.
  /keep, /k: do not delete the generated .rex file                       
  /nokeep  : delete the generated .rex file (the default)
  
::END

::Requires "Rexx.Tokenizer.cls"