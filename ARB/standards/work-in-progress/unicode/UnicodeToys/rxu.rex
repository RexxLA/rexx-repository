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
/*  "RXU filename" converts a file named "filename" (default extension:      */
/*  ".rxu") into a ".rex" file, and then interprets the ".rex" file.         */
/*  A ".rxu" can use an extended ooRexx syntax with the following            */
/*  new constructs:                                                */
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
/*                                                                           */
/*****************************************************************************/

BIFs = "LEFT LENGTH POS SUBSTR CENTER CENTRE REVERSE RIGHT"

Signal On User Syntax.Error -- Rexx.Tokekiner and subclasses raise Syntax.Error

Parse Arg arguments

-- Process options first

Do While Word(arguments,1)[1] == "/"
  Parse Var arguments "/"option arguments
  Select Case Upper(option)
    When "H", "HELP" Then Do
      Say .resources~help
      Exit
    End
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

Do Forever

  -- Did we pick the next token before? Then this is our token now
  If \nextToken~isNil Then Do
    token. = nextToken
    nextToken = .nil
  End
  -- No next token? Pick a new one then
  Else token. = tokenizer~getToken
  
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
      BIFPos = WordPos(Upper(token.value),BIFs)
      If BIFPos > 0, NextToken()["VALUE"] = "(" Then 
        Call CharOut outFile, "!"token.value
      Else 
        Call CharOut outFile, token.value
    End
    When STRING CODEPOINTS, STRING TEXT Then
      Call CharOut outFile, "Text('"ChangeStr("'",token.value,"''")"')"
    When STRING RUNES Then
      Call CharOut outFile, "Runes('"ChangeStr("'",token.value,"''")"')"
    When STRING CHARACTER Then
      Call CharOut outFile, "'"ChangeStr("'",token.value,"''")"'"
    Otherwise 
      Call CharOut outFile, token.value
  End
  
End

Call LineOut outFile, ""
Call LineOut outFile, "::Requires Unicode.cls" -- Duplicates don't do any harm

Call Stream inFile,  "C", "Close"
Call Stream outFile, "C", "Close"

-- Now run the .rex file!

Address COMMAND "rexx" outFile arguments

Exit rc

NextToken:
  If nextToken~isNil Then nextToken = tokenizer~getToken
Return nextToken  

Syntax.Error:
  additional = Condition("A")
  errNumber  = additional[1]
  lineNumber = additional[2]
  arguments  = additional[3]
  Parse Var errNumber errMajor"."
  errLines   = errorMessage(errNumber, arguments)
  Say "Error" errMajor "running" Qualify(inFile)" line" linenumber":"errLines[1]
  Say "Error" errNumber": " errLines[2]
  errLines   = errorMessage(errNumber, arguments)
Exit - errMajor

::Resource Help
rxu: A simple Unicode preprocessor for Rexx

Syntax:
  rxu [options]... [file]...

Default extension is ".rxu". A ".rex" file with the same name
will be created, replacing an existing one, if any.

Options (case insensitive):

  /h, /help: Displays this information-
::END

::Requires Rexx.Tokenizer.cls
