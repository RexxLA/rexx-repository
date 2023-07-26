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
/*  The RXU Unicode preprocessor                                             */
/*  ============================                                             */
/*                                                                           */
/*  Format:                                                                  */
/*                                                                           */
/*    [rexx] rxu [options] filename [arguments]                              */
/*                                                                           */
/*  Options:                                                                 */
/*                                                                           */
/*    /help, /h  : display help for the RXU command                          */
/*    /keep, /k  : do not delete the generated .rex file                     */
/*    /nokeep    : delete the generated .rex file (the default)              */
/*    /warnbif   : warn when using unsupported BIFs                          */
/*    /nowarnbif : don't warn when using unsupported BIFs (the default)      */
/*                                                                           */
/*  "RXU filename" converts a file named "filename" (default extension:      */
/*  ".rxu") into a ".rex" file, and then interprets the ".rex" file.         */
/*  A ".rxu" can use an extended ooRexx syntax with the following            */
/*  new constructs:                                                          */
/*                                                                           */
/*    "string"R, a Runes string (checked for UTF8 correctness at parse time) */
/*    "string"T, a Text string (checked for UTF8 correctness at parse time)  */
/*    "string"U, a Unicode codepoint string. Codepoints can be specified     */
/*               using hexadecimal notation (61, 0061, 0000), or as a name,  */
/*               alias or label enclosed in parenthesis ("(cr)","(CR) (LF)", */
/*               "(Woman) (zwj) (Man)").                                     */
/*                                                                           */
/*  Calls to a number of BIFs are substituted by equivalent calls to         */
/*  a function with a name formed by an exclamation mark ("!") concatenated  */
/*  to the BIF name. For example, "Length(var)" will be substituted by       */
/*  "|Length(var)". These !-functions have been defined in Unicode.cls       */
/*  and are re-routed to the corresponding BIMs for the Bytes (String),      */
/*  Runes and Text classes.                                                  */
/*                                                                           */
/*  The list of supported BIFs is listed in the "BIFs" variable at the       */
/*  start of the code.                                                       */
/*                                                                           */
/*  No check are done to see if there are internal routines with the same    */
/*  names as these BIFs, or to see if the BIFs are called with a CALL        */
/*  statement instead of a function call.                                    */
/*                                                                           */
/*  This preprocessor depends heavily on the Rexx.Tokenizer class.           */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1d JMB 20230719 Initial release                                       */
/*  00.1e JMB 20230721 Fix error when "0A"X, "0D"X or "1F"X in U string      */
/*                     Add LOWER(n, length)                                  */
/*  00.2  JMB 20230725 Add Upper                                             */
/*                     CHARACTER STRINGS are explicitly BYTES                */ 
/*                     Issue warnings for unsupported BIFs                   */
/*                     Add support for OPTIONS instruction (see below)       */
/*                     Add support for OPTIONS DEFAULTSTRING                 */
/*                                                                           */
/*****************************************************************************/

------------------------------------------------------------------------------
--
-- Please note that rxu.rex depends heavily on Rexx.Tokenizer, which is a 
-- simple tokenizer, not a full parser. This imposes some restrictions on
-- the source programs it can succesfully process.
--
-- In particular,
--
-- * Please ensure that directives start at the beginning of the line,
--   without intervening comments, and that they are not followed in the
--   same line by an instruction (i.e., ensure that any possible instruction
--   starts on one of the following lines).
--
-- * Please read the following section about the OPTIONS instruction.
--
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Implementation of the OPTIONS instruction
--
-- The OPTIONS instruction will only be recognized correctly by 
-- the RXU preprocessor when
--
-- (1) It appear by itself on a single line. 
-- (2) It starts the line, maybe after some optional blanks (i.e., no previous
--     comments).
-- (3) It does not expand for more than one line.
-- (4) It is composed exclusively of symbols taken as constants.
-- 
-- The OPTIONS instruction should not appear inside a conditional 
-- or repetitive instruction, or inside a procedure. if it does, results can
-- be unpredictable.
--
-- Recognized options
--
--   DEFAULTSTRING <stringType>
--     Determines the interpretation of an unpostfixed string, i.e., "string",
--     with no B, X, C, R, T or U postfix. Possible values for <stringType>
--     are BYTES, RUNES or TEXT. The preprocessor encloses unpostfixed
--     strings with a call to the corresponding conversion BIF, e.g., if
--     DEFAULTSTRING TEXT is in effect, then "string" will be equivalent to
--     TEXT("string").
--
--   CONVERSIONS NONE
--     Do not perform automatic conversions. Operations between differently
--     typed strings, like concatenating a BYTES and a TEXT string,
--     will raise a Syntax error. 
--   CONVERSIONS PROMOTE
--     If one of the operands is TEXT, return a TEXT string.
--     Else, if one of the operands is RUNES, return a RUNES string.
--     Otherwise, return a Bytes string.
--   CONVERSIONS DEMOTE
--     If one of the operands is BYTES, return a BYTES string.
--     Else, if one of the operands is RUNES, return a RUNES string.
--     Otherwise, return a TEXT string.
--   CONVERSIONS LEFT
--     An attempt is made to convert the result to the class of the left
--     operand.
--   CONVERSIONS RIGHT
--     An attempt is made to convert the result to the class of the right
--     operand.
--
------------------------------------------------------------------------------

BIFs   = "C2X CENTER CENTRE COPIES LEFT LENGTH LOWER POS REVERSE RIGHT "
BIFs ||= "SUBSTR UPPER "
-- The following list is taken from rexxref, ooRexx 5.0
Unsupported   = "ABBREV ABD ADDRESS ARG B2X BEEP BITAND BITOR BITXOR C2D "
Unsupported ||= "CHANGESTR CHARIN CHAROUT CHARS COMPARE CONDITION "
Unsupported ||= "COUNTSTR D2C D2X DATATYPE DATE DELSTR DELWORD DIGITS "
Unsupported ||= "DIRECTORY ENDLOCAL ERRORTEXT FILESPEC FORM FORMAT FUZZ "
Unsupported ||= "INSERT LASTPOS LINEIN LINEOUT LINES MAX MIN OVERLAY QUALIFY "
Unsupported ||= "QUEUED RANDOM RXFUNCADD RXFUNCDROP RXFUNCQUERY RXQUEUE "
Unsupported ||= "SETLOCAL SIGN SOURCELINE SPACE STREAM STRIP SUBWORD SYMBOL "
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

-- nextToken allows us one token of look ahead

nextToken = .nil
token. = ""

noDefaultLine. = 0
Do Forever

  -- Did we pick the next token before? Then this is our token now
  If \nextToken~isNil Then Do
    token. = nextToken
    nextToken = .nil
  End
  -- No next token? Pick a new one then
  Else token. = tokenizer~getToken
    
  -- See if this is an OPTIONS instruction
  
  If token.Location~word(2) == "1" Then Do
    line = token.Location~word(1)
    If Upper(Word(array[line],1)) == "OPTIONS" Then Call Options
    Else If Space(array[line],0)[1,2] == "::" Then noDefaultLine.line = 1
  End
    
If token.Class == END_OF_SOURCE Then Leave

  If token.class == END_OF_LINE Then Do
    Call LineOut outFile, ""
    Iterate
  End
  
  If token.class == CLASSIC_COMMENT Then Do
    Parse var token.location start startPos end endPos
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
  
  Select Case token.class token.subClass
    -- Only check for BIFs when simple symbols. Stems and compounds cannot be BIFs
    When VAR_SYMBOL SIMPLE Then Do
      If NextToken()["CLASS"] == STRING Then Do -- Abbuttal, insert explicit "||"
        Call CharOut outFile, token.value"||"
      End
      Else Do -- Check for built-ins
        BIFPos = WordPos(Upper(token.value),BIFs)
        If BIFPos > 0, NextToken()["VALUE"] = "(" Then 
          Call CharOut outFile, "!"token.value
        Else Do
          If warnBIF, WordPos(Upper(token.value),Unsupported) > 0, NextToken()["VALUE"] = "(" Then Do
            If UnsupportedWarningIssued.[Upper(token.value)] == 0 Then Do
              UnsupportedWarningIssued.[Upper(token.value)] = 1
              Say "WARNING: Unsupported BIF '"token.value"' used in program '"filename"'."
            End
          End
          Call CharOut outFile, token.value
        End
      End
    End
    When STRING CODEPOINTS Then
      Call CharOut outFile, "Text('"C2X(token.value)"'X)"
    When STRING TEXT Then
      Call CharOut outFile, "Text('"ChangeStr("'",token.value,"''")"')"
    When STRING RUNES Then
      Call CharOut outFile, "Runes('"ChangeStr("'",token.value,"''")"')"
    When STRING BYTES Then
      Call CharOut outFile, "Bytes('"ChangeStr("'",token.value,"''")"')"
    When STRING CHARACTER Then
      If noDefaultLine.[token.Location~word(1)] Then 
        Call CharOut outFile, "'"ChangeStr("'",token.value,"''")"'"
      Else 
        Call CharOut outFile, defaultString"('"ChangeStr("'",token.value,"''")"')"
    Otherwise 
      Call CharOut outFile, token.value
  End
  
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

NextToken:
  If nextToken~isNil Then nextToken = tokenizer~getToken
Return nextToken  

Options:
  options = Upper(array[line])
  Do i = 2 To Words(options)
    option  = Word(options, i)
    option2 = Word(options, i + 1)
    Select
      When (option option2) == "DEFAULTSTRING BYTES" Then Do; i += 1; defaultString = "Bytes"; End
      When (option option2) == "DEFAULTSTRING RUNES" Then Do; i += 1; defaultString = "Runes"; End
      When (option option2) == "DEFAULTSTRING TEXT"  Then Do; i += 1; defaultString = "Text";  End
      When (option option2) == "CONVERSIONS NONE"    Then Do; i += 1; Call CharOut outFile, '.environment~Unicode.Conversions = "NONE"; '    ; End
      When (option option2) == "CONVERSIONS PROMOTE" Then Do; i += 1; Call CharOut outFile, '.environment~Unicode.Conversions = "PROMOTE"; ' ; End
      When (option option2) == "CONVERSIONS DEMOTE"  Then Do; i += 1; Call CharOut outFile, '.environment~Unicode.Conversions = "DEMOTE"; '  ; End
      When (option option2) == "CONVERSIONS LEFT"    Then Do; i += 1; Call CharOut outFile, '.environment~Unicode.Conversions = "LEFT"; '    ; End
      When (option option2) == "CONVERSIONS RIGHT"   Then Do; i += 1; Call CharOut outFile, '.environment~Unicode.Conversions = "RIGHT"; '   ; End
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
