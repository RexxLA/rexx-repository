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
 *   The <b><code>RXU</code> Rexx Preprocessor for Unicode</b> is implemented as a Rexx program, 
 *   <code>rxu.rex</code>. <code>RXU</code> reads a <code>.rxu</code> program and attempts 
 *   to translate it to standard <code>.rex</code> code (assuming that the Unicode library,
 *   <code>Unicode.cls</code>, is available and has been loaded). If no errors are found in 
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
 * <h4>What we do and what we don't do</h4>
 *
 * <p>
 *   <u><code>RXU</code> is a work-in-progress, not a finished product</u>. Some parts of Rexx have been made
 *   to appear as "Unicode-ready", and some others have not. This can produce all kind of unexpected results.
 *   Use at your own risk!
 *
 * <p>
 *   The major focus of the translator is to
 *   implement Unicode-aware Classic Rexx: in this sense, priority is given, for example, to the implementation
 *   of Built-in Functions (BIFs) over Built-in Methods (BIMs). For example, currently you will find
 *   a Unicode-aware implementation of several stream i/o BIFs, but no reimplementation of the
 *   Stream I/O classes.
 *
 * <p>
 *   Here is a list of what is currently implemented.
 *
 * <ul>
 *   <li><b>Four new types of string</b>:
 *     <ul>
 *       <li>"string"Y, a Classic Rexx string, composed of bytes.                   
 *       <li>"string"P, a Codepoints string (checked for UTF8 correctness at parse time)                                              
 *       <li>"string"T, a Text string (checked for UTF8 correctness at parse time)  
 *       <li>"string"U, a Unicode codepoint string. Codepoints can be specified using 
 *          hexadecimal notation (like 61, 0061, or 0000), Unicode standard U+ notation 
 *         (like U+0061 or U+0000), or as a name, alias or label enclosed in parenthesis 
 *         (like "(cr)", "(CR) (LF)", "(Woman) (zwj) (Man)"). A "U" string is always a BYTES string.
 *     </ul>
 *   <li><b>Built-in functions</b>: C2X, CHARIN, CHAROUT, CHARS, CENTER, CENTRE, COPIES, DATATYPE, LEFT,
 *     LENGTH, LINEIN, LINEOUT, LINES, LOWER, POS, REVERSE, RIGHT, STREAM, SUBSTR, UPPER. Please refer
 *     to the documentation for Unicode.cls and Stream.cls for a detailed description of these enhanced BIFs.
 *   <li><b>New OPTIONS</b>:
 *     <ul>
 *       <li>OPTIONS DEFAULTSTRING <em>default</em>, where default can be one of BYTES, CODEPOINTS, TEXT OR
 *         NONE. This affects the semantics of unsuffixed strings, i.e., "string", without an explicit
 *         B, X, Y, P; T or U suffix. If <em>default</em> is NONE, strings are left alone (i.e., they are
 *         handled as default Rexx strings. In other cases, strings are transformed to the corresponding
 *         type. For example, a T string, "string"T, will automatically be a TEXT string, composed of
 *         extended grapheme clusters. <b>Implementation restriction:</b> This is currently a global option.
 *         You can change it inside a procedure, and it will apply globally, not only to the procedure scope.
 *     </ul>
 * </ul>
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
 *    -help, -h  : display help for the RXU command                          
 *    -keep, -k  : do not delete the generated .rex file                     
 *    -nokeep    : delete the generated .rex file (the default)              
 *    -warnbif   : warn when using not-yet-migrated to Unicode BIFs
 *    -nowarnbif : don't warn when using not-yet-migrated to Unicode BIFs (the default)
 *  </pre></code>
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
 *   <tr><td>      <td>JMB <td>20230816 <td>Implement OPTIONS DEFAULTSTRING NONE
 *   <tr><td>00.4  <td>JMB <td>20230901 <td>Complete rewrite, use the full tokenizer
 *   <tr><td>      <td>    <td>         <td>Change /options to -options
 * </table>
 *
 * @author &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;  
 * @version 0.4
 */


Parse Arg arguments

If arguments = "" Then Do
  Say .resources~help
  Exit 
End

-- Process command options first

warnbif        = 0
keepOutputFile = 0

Do While Word(arguments,1)[1] == "-"
  Parse Var arguments "-"option arguments
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

-- Parse filename

arguments = Strip(arguments)

quote? = arguments[1] 
If Pos(quote?,"""'") > 0 Then
  Parse Value arguments With (quote?)filename(quote?)arguments
Else
  Parse Var arguments filename arguments
  
arguments = Strip(arguments)

-- Construct input and output file names

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

-- Check that the input file exists and is not a directory

If Stream(inFile,"c","query exists") == "" Then Do
  Call LineOut .StdOut, "File '"inFile"' does not exist."
  Exit   
End

If .File~new(inFile)~isDirectory Then Do
  Call LineOut .StdOut, "'"inFile"' is a directory."
  Exit   
End

Call Stream outFile,"c","close"
Call Stream outFile,"c","open write replace"

Call Transform inFile, outFile
saveRC = result

Call LineOut outFile, ""
Call LineOut outFile, "::Requires 'Unicode.cls'" -- Duplicates don't do any harm

Call Stream inFile,  "C", "Close"
Call Stream outFile, "C", "Close"

If saveRC \== 0 Then Exit saveRC

-- Now run the .rex file

Address COMMAND "rexx" outFile arguments

saveRC = rc

If \keepOutputFile Then .File~new(outFile)~delete

Exit saveRC

--------------------------------------------------------------------------------

Transform: Procedure Expose filename warnBIF
  Use Arg inFile, outFile
  
  -- Implemented BIFs
  BIFs   = "C2X CHARIN CHAROUT CHARS CENTER CENTRE COPIES DATATYPE LEFT LENGTH "
  BIFs ||= "LINEIN LINEOUT LINES LOWER POS REVERSE RIGHT STREAM SUBSTR UPPER "
  
  -- The following list is taken from rexxref, ooRexx 5.0
  Unsupported   = "ABBREV ABS ADDRESS ARG B2X BEEP BITAND BITOR BITXOR C2D "
  Unsupported ||= "CHANGESTR COMPARE CONDITION "
  Unsupported ||= "tokenNumberSTR D2C D2X DATE DELSTR DELWORD DIGITS "
  Unsupported ||= "DIRECTORY ENDLOCAL ERRORTEXT FILESPEC FORM FORMAT FUZZ "
  Unsupported ||= "INSERT LASTPOS MAX MIN OVERLAY QUALIFY "
  Unsupported ||= "QUEUED RANDOM RXFUNCADD RXFUNCDROP RXFUNCQUERY RXQUEUE "
  Unsupported ||= "SETLOCAL SIGN SOURCELINE SPACE STRIP SUBWORD SYMBOL "
  Unsupported ||= "TIME TRACE TRANSLATE TRUNC USERID VALUE VAR VERIFY WORD "
  Unsupported ||= "WORDINDEX WORDLENGTH WORDPOS WORDS X2B X2C X2D XRANGE"
  
  inFile = Qualify(infile)
  
  eol = .endOfLine

  size  = Stream(infile,"c","q size") -- This
  array = CharIn(inFile,,size)~makeArray

  t = .ooRexx.Unicode.Tokenizer~new(array,1)
  
  Do tc over t~tokenClasses
   Call Value tc[1], tc[2]
  End
  
  tokenNumber            = 0         -- (full) token no. in clause
  context          = "00"X     -- No context
  parseContext     = 0         -- Boolean: we are parsing a "parse" instruction
  parseWithPending = 0         -- Boolean: we are parsing a "parse value" instruction, didn't see "with" yet
  prevToken        = .Stem~new -- Look-back. Avoids tests for .Nil
  x                = .Stem~new -- Look-back. Avoids tests for .Nil
  nextToken        = .nil      -- Look-ahead

  lastLine         = 1         -- 
  
  optionsContext   = 0
  
  Do i = 1 By 1
  
    Call GetAToken -- GetAToken returns "x" as a (full) token

    xClass = x[class]
    
    Select Case xClass
    
  When END_OF_SOURCE, SYNTAX_ERROR Then Leave

      -- Keep track of context and token number at the start of each (non-null) clause
      When LABEL, DIRECTIVE, KEYWORD_INSTRUCTION, ASSIGNMENT_INSTRUCTION, COMMAND_OR_MESSAGE_INSTRUCTION Then Do
        context      = xClass
        parseContext = 0
        subContext   = x[subClass]
        tokenNumber  = 1
      End
      
      Otherwise tokenNumber += 1
    End
    
    Select Case xClass
      -- Keep also track of expression nesting, but only when parsing a "parse" instruction
      When LPAREN   Then If parseContext Then openParens   += 1
      When RPAREN   Then If parseContext Then openParens   -= 1
      When LBRACKET Then If parseContext Then openBrackets += 1
      When RBRACKET Then If parseContext Then openBrackets -= 1
      When END_OF_CLAUSE Then Do
        If optionsContext Then
          Call CharOut outFile, "; Call !Options !Options; Options !Options; End"
        optionsContext = 0
      End
      Otherwise Nop
    End

    -- "Parse" and similar instructions are special, in that some strings are part of patters,
    -- and some other strings are part of expressions.
    If (,
         ( subcontext == PARSE_INSTRUCTION ) |,
         ( subcontext == ARG_INSTRUCTION   ) |, 
         ( subcontext == PULL_INSTRUCTION  ),
       ), tokenNumber == 1 Then Do
      parseContext      = 1
      openParens        = 0
      openBrackets      = 0
      parseWithPending  = 0
    End

    -- Is this a "Parse Value" instruction? Then there is a pending "With" 
    If parseContext, subcontext == PARSE_INSTRUCTION, tokenNumber == 2, Upper( x[value] ) == "VALUE" Then 
      parseWithPending = 1
    
    -- Here is our "With". Resume normal "Parse" context
    If parseContext, parseWithPending, xClass = VAR_SYMBOL, Upper( x[VALUE] ) == "WITH" Then parseWithPending = 0

    -- Explore all the sub-tokens, if any
    If x~hasIndex(absorbed) Then y = x[absorbed]
    Else                         y = .array~of(x)
            
    Do counter count z over y      
    
      -- "Transformed" will be .nil if we leave the token as-is, or the new token otherwise
      transformed = .nil
      
      Parse Value z[location] With line1 col1 line2 col2
      
      -- Handling of strings
      If z[class] == STRING Then Do
        Select Case context
          -- Don't touch labels (other than eliminating new suffixes and translating U strings)
          When LABEL Then Call StringAsIs
          -- The only context where we have an expression inside a directive is a
          -- ::Constant. The constant name itself has to be left alone.
          When DIRECTIVE Then
            If (subContext \== CONSTANT_DIRECTIVE) | (tokenNumber == 2) Then Call StringAsIs
          When KEYWORD_INSTRUCTION Then
            Select Case subContext
              -- Don't touch strings in CALL ON or SIGNAL ON
              When CALL_ON_INSTRUCTION, SIGNAL_ON_INSTRUCTION Then Call StringAsIs
              -- The environment name, routine name or label name have to be left alone.
              -- Other strings have to be processed.
              When ADDRESS_INSTRUCTION, SIGNAL_INSTRUCTION, TRACE_INSTRUCTION Then
                If tokenNumber == 2 Then Call StringAsIs
              -- Parse and parse-like instructions and contexts
              -- Strings are only processed when they are part of an exprssion (i.e., when
              -- nesting is not zero).
              When ARG_INSTRUCTION, PARSE_INSTRUCTION, PULL_INSTRUCTION Then
                If \parseWithPending, openParens == 0, openBrackets == 0 Then Call StringAsIs
              -- In all other cases, process the strings
              Otherwise Nop
            End
          Otherwise Nop
        End
        -- No explicit transformation? Process the new, suffixed strings, and the
        -- default, unprefixed, strings.
        If transformed == .nil Then Call TypedString
      End
      -- Handling of identifiers
      Else If z[class] == VAR_SYMBOL, z[subClass] == SIMPLE Then Do
        -- We don't change symbols that are method names
        If prevToken[class] == OPERATOR, prevToken[value][1] == "~" Then Nop
        -- No method call, function or subroutine call context...
        Else If ( nextToken()[class] == LPAREN ) |,             -- Function
           (subcontext == CALL_INSTRUCTION & tokenNumber == 2), -- Subroutine
           Then Do
          val = Upper( z[value] )
          If WordPos(val, BIFs) > 1 Then transformed = '!'z[value]
          Else If WordPos(val, Unsupported) > 1 Then Do
            If warnBIF Then 
              Say "WARNING: Unsupported BIF '"val"' used in program '"filename"', line" Word(z[location],1)
          End
        End
      End
           
      If x[class] == KEYWORD_INSTRUCTION, x[subClass] == OPTIONS_INSTRUCTION, x[cloneIndex] == count Then Do
        transformed = "Do; !Options ="
        optionsContext = 1
      End
      
      Do i = lastLine To line1-1
        Call CharOut outFile, eol -- Sources are created in Windows
      End
      If line1 == line2 Then Do
        If transformed \== .Nil Then
          Call CharOut outFile, transformed
        Else
          Call CharOut outFile, array[line1][col1,col2-col1]
        lastLine = line1
      End
      Else Do line = line1 To line2
        Select Case line
          When line1 Then Call CharOut outFile, SubStr(array[line1],col1)eol
          When line2 Then Call CharOut outFile, Left(array[line2],col2-1)
          Otherwise       Call CharOut outFile, array[line]eol
        End
        lastLine = line2
      End
    End
  End
  -- Final EOL
  Call CharOut outFile, eol -- Sources are created in Windows
  
  --Call Stream outFile,"c","Close"
  Call Stream inFile ,"c","Close"
  
  If x[class] == SYNTAX_ERROR Then Do
    line = x[line]
    Parse Value x["NUMBER"] With major"."minor
    
    Say
    Say Right(line,6) "*-*" array[line]
    Say "Error" major "running" inFile "line" line":" x[message]
    Say "Error" major"."minor": " x[secondaryMessage]
    
    Return -major
    
  End
  
Return 0

StringAsIs:
  Select Case z[subClass]
    -- When "U"           Then transformed = '"'C2X(z[value])'"X'
    When "U"           Then transformed = '"'ChangeStr('"',z[value],'""')'"'
    When "P", "T", "Y" Then transformed = array[line1][col1,col2-col1-1]
    Otherwise               transformed = array[line1][col1,col2-col1]  -- Identity
  End
Return

TypedString:
  -- We don't change strings that are method names
  If prevToken[class] == OPERATOR, prevToken[value][1] == "~" Then Signal StringAsIs
  -- A function or subroutine call? Maybe it is a BIF...
  If (nextToken()[class] == LPAREN) |,                    -- Function
     (subcontext = CALL_INSTRUCTION & tokenNumber == 2),  -- Subroutine
    Then Do
    val = x[value]
    If WordPos(val, BIFs) > 1 Then transformed = '"!'val'"'
    Else If WordPos(val, Unsupported) > 1 Then Do
      If warnBIF Then 
        Say "WARNING: Unsupported BIF '"val"' used in program '"filename"', line" Word(x[location],1)
      transformed = '"'val'"'
    End
    Else Signal StringAsIs
    Return
  End
  If Pos(prevToken[class],VAR_SYMBOL||CONST_SYMBOL||NUMBER||STRING) > 0 Then concat = "||"
  Else                                                                       concat = ""
  Select Case z[subClass]
    When "U" Then transformed =      concat'(Bytes("'ChangeStr('"',z[value],'""')'"))'
    When "P" Then transformed = concat'(Codepoints('array[line1][col1,col2-col1-1]'))'
    When "T" Then transformed =       concat'(Text('array[line1][col1,col2-col1-1]'))'
    When "Y" Then transformed =      concat'(Bytes('array[line1][col1,col2-col1-1]'))'
    Otherwise     transformed =       concat'(!!DS('array[line1][col1,col2-col1  ]'))'
  End
Return

-- Implements one token of look-ahead (nextToken) and one token of look-back (prevYoken)
GetAToken:
  prevToken = x
  -- Did we pick the next token before? Then this is our token now
  If \nextToken~isNil Then Do
    x = nextToken
    nextToken = .nil
  End
  -- No next token? Pick a new one then
  Else x = t~getFullToken
Return

-- Implements lookahead
NextToken:
  If nextToken~isNil Then nextToken = t~getFullToken
Return nextToken  

::Resource Help
rxu: A Rexx Preprocessor for Unicode

Syntax:
  rxu [options] filename [arguments]

Default extension is ".rxu". A ".rex" file with the same name
will be created, replacing an existing one, if any.

Options (case insensitive):

  -help, -h  : display help for the RXU command                          
  -keep, -k  : do not delete the generated .rex file                     
  -nokeep    : delete the generated .rex file (the default)              
  -warnbif   : warn when using not-yet-migrated to Unicode BIFs
  -nowarnbif : don't warn when using not-yet-migrated to Unicode BIFs (the default)
  
::END

::Requires "parser/Rexx.Tokenizer.cls"