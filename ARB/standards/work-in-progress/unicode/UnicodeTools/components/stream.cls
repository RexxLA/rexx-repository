/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

-- stream.cls
--
-- A general description of the stream built-in functions can be found in doc/stream.md
--
-- Please refer to doc/built-in.md for a description of the built-in functions implemented here

.local~Unicode.Stream = .Stem~new    -- We will use this stem to store extended stream properties
.Unicode.Stream[]     = .Nil         -- Default value

/**
 * <p><code>NormalizeStreamName</code> is a private utility routine shared by all the helper routines in this classfile.
 *
 * <p>We assume that Windows is always case-insensitive (this is not always
 *  the case, but this is a prototype).
 */
::Routine NormalizedStreamName Private
  If .File~separator = "/" Then Return Arg(1)
  Return Upper(Arg(1))

::Routine !CharIn Public
  If Arg() > 3 Then Raise Syntax 40.4 Array("CHARIN",3)
  
  -- We don't handle encodings for stdin yet
  If Arg(1, "O") Then Do
    name = "stdin"
    Signal StandardCall
  End
  
  name   = Arg(1)
  start  = Arg(2)
  If Arg(3,"O") Then length = 1
  Else length = Arg(3)
  
  fileInfo = .Unicode.Stream[NormalizedStreamName(name)]
  
  -- No encoding info? That is standard behaviour
  If fileInfo == .Nil Then Signal StandardCall
  
  -- Reset last error
  fileInfo~lastError = ""
  
  encoding        = fileInfo~encoding        -- E.g., CP-850, or UTF-32.
  errorHandling   = fileInfo~errorHandling   -- REPLACE or SYNTAX
  target          = fileInfo~target          -- TEXT or CODEPOINTS
  
  text            = target        == "TEXT"
  
  replace         = errorHandling == "REPLACE"
  syntax          = errorHandling == "SYNTAX"
  
  isFixedLength   = encoding~isFixedLength
  bytesPerChar    = encoding~bytesPerChar
  maxBytesPerChar = encoding~maxBytesPerChar
           
  -- Handle the "start" argument. If it is not specified, we have nothing to do
  If Arg(2,"E") Then 
    If IsFixedLength, \ text Then Do -- We can handle seeks
      -- Seek in any case
      Call CharIn name, 1 + (arg(2)-1)* bytesPerChar, 0
      -- Pure seek? Return the result
      If Arg(3) == 0 Then Return result
      -- Something else to do
    End
    Else Do
      -- Positioning at the beginning of the stream always works
      If Arg(2) == 1 Then Do
        Call CharIn name, 1, 0
        -- Charin name, 1, 0 is a pure seek command
        If Arg(3) == 0 Then Return result
        -- Seek, then do something else
      End
      -- We don't do seeks when the encoding is not fixed-length or target = "TEXT"
      Else If Text Then
        Raise Syntax 93.900 Additional("Implementation restriction: cannot modify to a start position \= 1 when reading TEXT.")
      Else 
        Raise Syntax 93.900 Additional("Implementation restriction: cannot modify to a start position \= 1 with a non-fixed length encoding.")
    End

  -- We are now located in the proper place. Let's read "length" codepoints or grapheme clusters
  res = "" -- Will hold the result
  If text Then codes = ""

  Do i = 1 To length
    Call GetACodepoint
    decode = encoding~decode(result,"UTF8 UTF32",errorHandling)
    res ||= decode["UTF8"]
    If text Then codes ||= " "NiceCode(c2X(decode["UTF32"]))
  End
  If \text Then Return .Codepoints~new(res)
  
  -- We should discriminate the grapheme clusters as we read the decoded string.
  -- This is aprototype! It just works, but it is severely inefficient.
  
  -- Ensure that we have at least "length" grapheme clusters.
  Do While .Unicode.Grapheme_Cluster_Break~codepointsToGraphemes( Strip(codes), "UTF8" )~items < length
    Call GetACodepoint
  If result == "" Then Return .Text~new(res) -- EOF
    decode = encoding~decode(result,"UTF8 UTF32",errorHandling)
    res ||= decode["UTF8"]
    codes ||= " "NiceCode(c2X(decode["UTF32"]))
  End
  
  -- We need to look ahead and maybe backtrack

  -- Save our READ CHAR position in case we have to backtrack
Extend:  
  save = Stream(name,"Command", "Query Position Read Char")
  Call GetACodepoint
  If result == "" Then Return .Text~new(res) -- EOF
  -- Don't raise a Syntax error if something is wrong
  decode = encoding~decode(result,"UTF8 UTF32","REPLACE")
  -- REPLACEMENT CHARACTER breaks graphemes
  If decode["UTF32"] = "0000FFFD"X Then Signal BacktrackAndReturn
  codes2 = codes" "NiceCode(c2X(decode["UTF32"]))
  If .Unicode.Grapheme_Cluster_Break~codepointsToGraphemes( Strip(codes2), "UTF8" )~items > length Then
    Signal BacktrackAndReturn
  res ||= decode["UTF8"]
  codes ||= " "NiceCode(c2X(decode["UTF32"]))    
  Signal Extend

BacktrackAndReturn:
  Call Stream name, "Command", "SEEK =" save "READ CHAR" -- Backtrack
  Return .Text~new(res)

-- Temporary
NiceCode:
  tmp = Arg(1)
  Do While Length(tmp) > 4, tmp[1] = 0
    tmp = SubStr(tmp,2)
  End
Return tmp  

GetACodepoint:
  c = CharIn(name,,bytesPerChar)
  -- Either we get no bytes,..
  If c == "" Then Return ""
  -- ..or we expect to get all the bytes
  expected = bytesPerChar
  Do Forever
    -- Unexpected EOF?
    If Length(c) < expected Then 
      If replace Then Return "efbfbd"X -- Replacement character
      Else Signal SyntaxError
  If encoding~isFixedLength Then Leave      
    -- Do we need more bytes?
    more = encoding~bytesNeededForChar(c)
  If more == 0 Then Leave
    expected += more
    c ||= CharIn(name,,more)
  End
Return c  

StandardCall:
  If Arg(2,"O"), Arg(3,"O") Then Return CharIn(name)
  If Arg(3,"O") Then Return CharIn(name, start)
  If Arg(2,"O") Then Return CharIn(name, , length)
  Return CharIn(name, start , length)

SyntaxError:
  fileInfo~lastError = c
  Raise Syntax 23.001 Array(c,C2X(c))

::Routine !CharOut Public
  If Arg() > 3 Then Raise Syntax 40.4 Array("CHAROUT",3)
    
  -- We don't handle encodings for stdout yet
  If Arg(1, "O") Then Do
    name = "stdout"
    Signal StandardCall
  End
  
  name   = Arg(1)
  
  -- Handle CLOSE now
  If Arg(2,"O"), Arg(3,"O") Then Do
    Call !Stream name,"C", "Close"
    Return 0
  End
  
  fileInfo = .Unicode.Stream[NormalizedStreamName(name)]

  If fileInfo == .Nil Then Signal StandardCall
  
  -- Reset last error
  fileInfo~lastError = ""
    
  encoding        = fileInfo~encoding        -- E.g., CP-850, or UTF-32.
  errorHandling   = fileInfo~errorHandling   -- REPLACE or SYNTAX
  target          = fileInfo~target          -- TEXT or CODEPOINTS
  
  text            = target        == "TEXT"
  
  replace         = errorHandling == "REPLACE"
  syntax          = errorHandling == "SYNTAX"
  
  isFixedLength   = encoding~isFixedLength
  bytesPerChar    = encoding~bytesPerChar
  maxBytesPerChar = encoding~maxBytesPerChar  
    
  -- Handle character positioning now.
  If Arg(3,"E") Then Do
    start = Arg(3)
    -- Things we won't do
    If start \== 1 Then Do
      If \isFixedLength Then 
        Raise Syntax 93.900 Additional("Implementation restriction: cannot modify to a start position \= 1 with a non-fixed length encoding.")
      If text Then
        Raise Syntax 93.900 Additional("Implementation restriction: cannot modify to a start position \= 1 when reading TEXT.")
    End
    -- Ok, we can do that. Set the write position now
    Call CharOut name,,1 + (start-1) * bytesPerChar
    -- Nothing more to do? Return
    If Arg(2,"O") Then Return 0
  End
  
  -- Ok, we can write the string now
  
  string  = Arg(2)
  -- We are done positioning. Now write the line (if we got one)
  If string \== "" Then Call CharOut name, encoding~encode(string, errorHandling)
  
  Return result

StandardCall:
  If Arg(2,"O"), Arg(3,"O") Then Return CharOut(name)
  If Arg(2,"O") Then Return CharOut(name, , Arg(3))
  if Arg(3,"O") Then Return CharOut(name,Arg(2))
  Return CharOut(name, Arg(2), Arg(3))

::Routine !Chars Public
  If Arg() > 1 Then Raise Syntax 40.4 Array("CHARS",1)
  If Arg(1,"O") Then Do
    name = "stdin"
    Signal StandardCall
  End
  name = Arg(1)
  
  fileInfo = .Unicode.Stream[NormalizedStreamName(name)]

  If fileInfo == .Nil Then Signal StandardCall
  
  encoding        = fileInfo~encoding        -- E.g., CP-850, or UTF-32.
  errorHandling   = fileInfo~errorHandling   -- REPLACE or SYNTAX
  target          = fileInfo~target          -- TEXT or CODEPOINTS
  
  text            = target        == "TEXT"
  
  replace         = errorHandling == "REPLACE"
  syntax          = errorHandling == "SYNTAX"
  
  isFixedLength   = encoding~isFixedLength
  bytesPerChar    = encoding~bytesPerChar
  maxBytesPerChar = encoding~maxBytesPerChar  
  
  If isFixedLength, \text Then Do
    chars = Chars(name)
    If chars // bytesPerChar == 0 Then
      Return Chars(name)/bytesPerChar
    -- There are some chars, but not an exact multiple of bytesPerChar, or zero.
    Return 1
  End
  
  -- Can't get an accurate number of chars. Return 1 is there are any remaining, else 0
  Return Chars(name) > 0
  
StandardCall: Return CHARS(name)  

::Routine !Linein Public

  If Arg() > 3 Then
    Raise Syntax 40.4 Array("LINEIN",3)
    
  If Arg(1,"O") Then name  = stdin
  Else               name  = Arg(1)
  
  If Arg(2,"O") Then line  = .Nil
  Else               line  = Arg(2)
    
  If Arg(3,"O") Then count = .Nil
  Else               count = Arg(3)

  -- Don't return when we Signal StandardCall
  return = 0
    
  -- We don't support encoding for STDIN yet.
  If Arg(1,"O") Then Signal StandardCall
  
  fileInfo = .Unicode.Stream[NormalizedStreamName(name)]
  
  -- No encoding info? That is standard behaviour
  If fileInfo == .Nil Then Signal StandardCall
  
  -- Reset last error
  fileInfo~lastError = ""
  
  encoding           = fileInfo~encoding        -- E.g., CP-850, or UTF-32.
  errorHandling      = fileInfo~errorHandling   -- REPLACE or SYNTAX
  target             = fileInfo~target          -- TEXT or CODEPOINTS
  
  text               = target        == "TEXT"
  
  replace            = errorHandling == "REPLACE"
  syntax             = errorHandling == "SYNTAX"
  
  isFixedLength      = encoding~isFixedLength
  bytesPerChar       = encoding~bytesPerChar
  maxBytesPerChar    = encoding~maxBytesPerChar
  endOfLine          = encoding~endOfLine
  alternateEndOfLine = encoding~alternateEndOfLine
  endOfLineAlignment = encoding~endOfLineAlignment
  
  -- We have a handler. See that we are able to implement the operation.
  If \line~isNil, line == 1 Then Do
    Call LineIn name, 1, 0
    line = .Nil
  End
  -- Now "line" is either unspecified or \== 1
  If \line~isNil Then Do
    -- If endOfLine \== "0A"X, ooRexx will get confused about the line position
    -- Similarly, if the encoding has a bytesPerChar value > 1, there will be
    -- normal characters that contain a "0A"X.
    --
    -- For the moment, we won't implement line positioning in these cases.
    If \isFixedLength | (bytesPerChar > 1) | (endOfLine \== "0A"X) Then
      Raise Syntax 40.900 Additional("Line positioning not implemented for encoding '"encoding~name"'")
    -- We got a "line" argument, and we know how to positions ourselves there.
    Call LineIn name, line, 0
  End
  -- "Line" is handled. Take care of "count" now.
  If count == 0 Then
    If text Then Return .Text~new("")
    Else         Return .Codepoints~new("")
 
  -- Handle the cases where the end-of-line sequence does not end with "0A"X
  If \endOfLine~endsWith("0A"X) Then Signal NonStandardEOL
  
  -- Handle the cases where the end-of-line sequence ends with "0A"X, but
  -- its length is > 1
  If Length(endOfLine) > 1 Then Signal BigEOL
  
  -- Return to "GotALine:" when we Signal StandardCall
  return = 1
  Signal StandardCall
  
GotALine:  
  
  Signal On Syntax
  
  If res == "" Then Return ""
  If text Then 
    Return .Text~new(encoding~decode(res,"UTF8", errorHandling))
  Return .Codepoints~new(encoding~decode(res,"UTF8", errorHandling))
  
Syntax:
  fileInfo~lastError = res
  Raise Propagate  
    
StandardCall:
  If line == .Nil Then 
    If count == .Nil Then res = LineIn(name)
    Else                  res = LineIn(name,    ,count)
  Else
    If count == .Nil Then res = LineIn(name,line)
    Else                  res = LineIn(name,line,count)
  If return Then Signal GotALine
Return res  

-- We have got an encoding where Right(endOfLine,1) \== "0A".
-- The LINEIN BIF cannot read lines from such a stream.
-- We have to read bytes one by one and accumulate them
-- (taking the encoding's "endOfLineAlignment" constant into account too).
NonStandardEOL:
  res = ""
  
  Do While Chars(name) > 0
    res ||= CharIn(name,,1)
    If res~endsWith(endOfLine), Length(res) // endOfLineAlignment == 0 Then Do
      res = Left(res,Length(res)-Length(endOfLine))
      Signal GotALine
    End
    Else If alternateEndOfLine \== "", res~endsWith(alternateEndOfLine), Length(res) // endOfLineAlignment == 0 Then Do
      res = Left(res,Length(res)-Length(alternateEndOfLine))
      Signal GotALine
    End
  End
  -- End of file
  Signal GotALine

-- We have a "big" EOL, that is, an EOL that ends with "0A"X (and therefore
-- can be (partially) handled by the LINEIN BIF, but that it also has a length
-- greater than one. This needs some special handling.

BigEOL:
  res = ""
  -- We have to be very careful here:
  --
  -- * Maybe LINEIN has consumed a "OD0A"X instead of "0A"X. We must backtrack
  --   and take into account this eventuality.
  --
  -- * We need to check against Left(endOfLine,Length(endOfLine)-1) because the
  --   "0A"X character has already been consumed.
  --
  -- * If "0D"X was consumed, then we need to check against Left(endOfLine,Length(endOfLine)-1)
  --
  -- * The same applies to alternateEndOfLine
  --
  -- * We have to take endOfLineAlignment into account too.
  --
  
  endOfLine0A   = Left(endOfLine, Length(endOfLine) - 1)
  If alternateEndOfLine \== "" Then 
    alternateEndOfLine0A   = Left(alternateEndOfLine, Length(alternateEndOfLine) - 1)
   
  Do While Lines(name) > 0
    res ||= LineIn(name)
    
    -- Backtrack bytesPerChar chars, to see what comes before "0A"X
    Call Stream name, "c", "seek -2 read char"
    -- Get the next-to last end char...
    c  = CharIn(name,,1)
    -- ...and return
    Call CharIn name,,1
    
    If c == "0D"X Then Do -- "0D"X (...) "0A"X
      res2 = res"0D"x
      If res2~endsWith(endOfLine0A), (Length(res2)+1) // endOfLineAlignment == 0 Then Do
        res = Left(res2,Length(res2)-Length(endOfLine0A))
        Signal GotALine
      End
      Else If alternateEndOfLine \== "", res2~endsWith(alternateEndOfLine0A), (Length(res2)+1) // endOfLineAlignment == 0 Then Do
        res = Left(res2,Length(res2)-Length(alternateEndOfLine0A))
        Signal GotALine
      End
      -- Not a real EOL, it is a simple end-of-file condition.
      Else If Lines(name) == 0, Length(res) // endOfLineAlignment == 0 Then Nop
      -- Artifact. Restore the "0d0a"X
      Else res ||= "0D0A"X -- Not a real EOL. Iterate.
    End
    Else Do -- "0A"X
      If res~endsWith(endOfLine0A), (Length(res)+1) // endOfLineAlignment == 0 Then Do
        res = Left(res,Length(res)-Length(endOfLine0A))
        Signal GotALine
      End
      Else If alternateEndOfLine \== "", res~endsWith(alternateEndOfLine0A), (Length(res)+1) // endOfLineAlignment == 0 Then Do
        res = Left(res,Length(res)-Length(alternateEndOfLine0A))
        Signal GotALine
      End
      -- Not a real EOL, it is a simple end-of-file condition.
      Else If Lines(name) == 0, Length(res) // endOfLineAlignment == 0 Then Nop
      -- Artifact. Restore the "0a"X
      Else res ||= "0A"X -- Not a real EOL. Iterate.
    End
  End
  -- End of file
  Signal GotALine

::Routine !LineOut Public

  -- Handle CLOSE first
  If Arg(1,"E"), Arg(2,"O"), Arg(3, "O"), Stream(Arg(1),"c","Query StreamType") == "PERSISTENT" Then Do
    Call !Stream Arg(1),"C","CLOSE"
    Return result
  End

  If Arg(1,"O") Then name   = stdout
  Else               name   = Arg(1)  

  If Arg(2,"O") Then string = .Nil
  Else               string = Arg(2)  
  
  If Arg(3,"O") Then line   = .Nil
  Else               line   = Arg(3)  
      
  -- We don't support encoding for STDIN yet.
  If Arg(1,"O") Then Signal StandardCall
  
  fileInfo = .Unicode.Stream[NormalizedStreamName(name)]
  
  -- No encoding info? That is standard behaviour
  If fileInfo == .Nil Then Signal StandardCall
  
  -- Reset last error
  fileInfo~lastError    = ""
  
  encoding              = fileInfo~encoding        -- E.g., CP-850, or UTF-32.
  errorHandling         = fileInfo~errorHandling   -- REPLACE or SYNTAX
  target                = fileInfo~target          -- TEXT or CODEPOINTS
  
  text                  = target        == "TEXT"
  
  replace               = errorHandling == "REPLACE"
  syntax                = errorHandling == "SYNTAX"
  
  isFixedLength         = encoding~isFixedLength
  bytesPerChar          = encoding~bytesPerChar
  maxBytesPerChar       = encoding~maxBytesPerChar
  endOfLine             = encoding~endOfLine
  alternateEndOfLine    = encoding~alternateEndOfLine
  useAlternateEndOfLine = encoding~useAlternateEndOfLine
  endOfLineAlignment    = encoding~endOfLineAlignment
      
  -- We have a handler. See that we are able to implement the operation.
  If \line~isNil, line == 1 Then Call LineOut name, , 1
  -- Now "line" is either unspecified or \== 1
  If \line~isNil Then Do
    -- If endOfLine \== "0A"X, ooRexx will get confused about the line position
    -- Similarly, if the encoding has a bytesPerChar value > 1, there will be
    -- normal characters that contain a "0A"X.
    --
    -- For the moment, we won't implement line positioning.
    If \isFixedLength | (handler~bytesPerChar > 1) | (endOfLine \== "0A"X) Then
      Raise Syntax 40.900 Additional("Line positioning not implemented for encoding '"encodingName"'")
    -- We got a line, and we know how to positions ourselves there.
    Call LineOut name, , line
  End
  
  -- We are done positioning. Now write the line (if we got one)
  If string \== "" Then Call CharOut name, encoding~encode(string, errorHandling)
  
  -- If there was no error, write the end-of-line sequence
  If result == 0 Then Do
    If useAlternateEndOfLine Then Call CharOut name, alternateEndOfLine
    Else                          Call CharOut name, endOfLine
  End
  
  Return result

StandardCall:
  If line == .Nil Then 
    If string == .Nil Then Return LineOut(name)
    Else                   Return LineOut(name, string)
  Else 
    If string == .Nil Then Return LineOut(name, , line)
    Else                   Return LineOut(name, string, line)
  
::Routine !Lines Public
  Use Strict Arg name = "stdin", option = "Normal"

  -- We don't implement ENCODINGs for stdin yet  
  If Upper(name) == "STDIN" Then Signal StandardCall
      
  fileInfo = .Unicode.Stream[NormalizedStreamName(name)]

  If fileInfo == .Nil Then Signal StandardCall
  
  option = Upper(option)
  
  If option[1]  == "N" Then Return Lines(name) > 0
  
  If option[1] \== "C" Then
    Raise Syntax 40.904 Array("LINES",2,"CN",option[1])  
  
  -- Options is "Count". We don't do that unless ooRexx knows how to.
  
  encoding        = fileInfo~encoding        -- E.g., CP-850, or UTF-32.
  target          = fileInfo~target          -- TEXT or CODEPOINTS
  
  isFixedLength   = encoding~isFixedLength
  bytesPerChar    = encoding~bytesPerChar
  maxBytesPerChar = encoding~maxBytesPerChar  
  endOfLine       = encoding~endOfLine
  
  If isFixedLength, bytesPerChar == 1, endOfLine == "0A"X Then
    Return Lines(name,"Count")
  
  Raise Syntax 40.900 Additional("Line counting not implemented for encoding '"encodingName"'")
  
StandardCall: Return LINES(name, option)  
  
::Routine !Stream Public
  Use Arg , option="S"
    
  c = Left(option,1)
  uc = Upper(c)
  
  -- Pass STATE and DESCRIPTION to the standard BIF
  If uc == "S" | uc == "D" Then Do
    Use Strict Arg name, option
    Return Stream(name, option)
  End
  
  -- Not COMMAND is an error
  If uc \== "C" Then Raise Syntax 40.904 Array("STREAM",2,"SDC",c)
  
  Use Strict Arg name, option, command
  c = Upper(Left(command,1))
  
  -- We are only interested in OPEN, CLOSE, SEEK, POSITION and QUERY
  If Pos(c,"OCPQS") == 0 Then Return Stream(name, option, command)
  
  UCommand = Upper(Space(command))
  words    = Words(command)
  Signal (c)

"O": -- Open
  If \Abbrev("OPEN", Word(UCommand, 1), 1) Then 
    Raise Syntax 93.914 Array(1,"CLOSE FLUSH OPEN POSITION QUERY SEEK",Word(command, 1))
  foundBinary = 0
  newCommand = Word(command,1)
  -- Catch duplicates
  seenEncoding = 0
  Do i = 2 To Words
    If Abbrev("ENCODING", Word(UCommand, i), 3) Then Do
      If seenEncoding Then Raise Syntax 93.900 Additional("Duplicate option '"Word(command,i)"'")
      seenEncoding = 1
      If i == Words Then Raise Syntax 93.900 Additional("Missing encoding name after '"Word(Command,i)"'")
      i += 1
      -- Will raise a Syntax error if not found
      encoding = .Encoding[Word(command, i)]
      -- Set default values
      target        = "TEXT"
      errorHandling = "REPLACE"
      -- To prevent duplicates or contradictions
      seenTarget = 0
      seenError  = 0
      -- Eat any of TEXT CODEPOINTS REPLACE AND SYNTAX
      Do While i < Words 
        next = Word(UCommand,i+1)
        Select
          When next == "TEXT" Then 
            If seenTarget Then Raise Syntax 93.900 Additional("Multiple encoding targets specified")
            Else Do; target = "TEXT";           seenTarget = 1; End
          When next == "CODEPOINTS" Then 
            If seenTarget Then Raise Syntax 93.900 Additional("Multiple encoding targets specified")
            Else Do; target = "CODEPOINTS";     seenTarget = 1; End
          When next == "REPLACE" Then
            If seenError  Then Raise Syntax 93.900 Additional("Multiple encoding error handling options specified")
            Else Do; errorHandling = "REPLACE"; seenError = 1;  End
          When next == "SYNTAX" Then
            If seenError  Then Raise Syntax 93.900 Additional("Multiple encoding error handling options specified")
            Else Do; errorHandling = "SYNTAX";  seenError = 1;  End
          Otherwise Leave
        End
        i += 1
      End
      .Unicode.Stream[NormalizedStreamName(name)] = -
        .Directory~of(                      -
          ("NAME", encoding~name),          -
          ("ENCODING", encoding),           -
          ("TARGET", target),               -
          ("ERRORHANDLING", errorhandling), -
          ("LASTERROR", "")                 -
        )
    End
    Else Do
      If Abbrev("BINARY", Word(UCommand,i),2) Then foundBinary = 1
      newCommand = newCommand Word(command,i)
    End
  End
  If foundBinary, seenEncoding Then 
    Raise Syntax 93.900 Additional("Encoding cannot be specified for BINARY files")
  -- Pass the rest to the standard BIF
  Return Stream(name, option, newCommand)

"C": -- Close
  -- Check that verb is "Close"
  If \Abbrev("CLOSE", Word(UCommand, 1), 1) Then 
    Raise Syntax 93.914 Array(1,"CLOSE FLUSH OPEN POSITION QUERY SEEK",Word(command, 1))
  .Unicode.Stream[NormalizedStreamName(name)] = .Nil
  Return Stream(name, option, command)

"Q": -- Query
  -- Check that verb is "Query"
  If \Abbrev("QUERY", Word(UCommand, 1), 1) Then 
    Raise Syntax 93.914 Array(1,"CLOSE FLUSH OPEN POSITION QUERY SEEK",Word(command, 1))
  If Words(command) > 1, Abbrev("ENCODING", Word(UCommand, 2), 3) Then Do
    fileInfo = .Unicode.Stream[NormalizedStreamName(name)]
    If Words(command) > 3 Then
      Raise Syntax 93.900 Additional("Invalid command '"command"'")
    If Words(command) == 3 Then Do
      Select
        When Abbrev("ERROR",Word(UCommand,3),3) Then
          If fileInfo == .Nil Then Return ""
          Else Return fileInfo~errorHandling
        When Abbrev("TARGET",Word(UCommand,3),3) Then
          If fileInfo == .Nil Then Return ""
          Else Return fileInfo~target
        When Abbrev("NAME",Word(UCommand,3),3) Then
          If fileInfo == .Nil Then Return ""
          Else Return fileInfo~name
        When Abbrev("LASTERROR",Word(UCommand,3),3) Then
          If fileInfo == .Nil Then Return ""
          Else Return fileInfo~lastError
        Otherwise
          Raise Syntax 93.900 Additional("Invalid option '"Word(command,3)"'")
      End
    End
    Else 
      If fileInfo == .Nil Then Return ""
      Else Return fileInfo~name fileInfo~target fileInfo~errorHandling
  End
  Return Stream(name, option, command)
  
"S": "P": -- Seek, Position  
  If \Abbrev("SEEK", Word(UCommand, 1), 1), \Abbrev("POSITION", Word(UCommand, 1), 1) Then 
    Raise Syntax 93.914 Array(1,"CLOSE FLUSH OPEN POSITION QUERY SEEK",Word(command, 1))

  fileInfo = .Unicode.Stream[NormalizedStreamName(name)]
  If fileInfo == .Nil Then Return Stream(name,"Command",Command)
  
  encoding     = fileInfo~encoding
  bytesPerChar = encoding~bytesPerChar
  
  words = Words(UCommand)
  If words == 1 Then Raise Syntax 93.903 Additional("SEEK")
  
  offset = Word(Command, 2)
  If WordPos(offset,"= < + -") > 0 Then Do
    prefix = offset
    If words == 2 Then Raise Syntax 93.903 Additional("SEEK")
    offset = Word(Command, 3)
    rest = SubWord(command, 4)
  End
  Else Do
    prefix = "="
    rest = SubWord(command, 3)
  End
  
  If prefix == "=", offset = "1" Then Return Stream(name,"Command", Command)
  
  linePos = Abbrev("LINE",Word(UCommand, words),1)
  
  -- We don't support these
  If \encoding~isFixedLength | fileInfo~target == "TEXT" | (linePos & encoding~endOfLine \== "0A"X) Then
    Raise Syntax 93.900 Additional("SEEK and POSITION disabled for encoding '"encoding~name"'")
  
  -- Line positioning? ooRexx knows how to do that
  If linePos Then Return Stream(name,"Command", Command)
  
  -- Character positioning? We need to multiply by bytesPerChar
  If \DataType(offset,"W") Then Raise Syntax 93.0 -- That's what ooRexx does
  
  newCommand = "SEEK" prefix (offset * bytesPerChar) rest
  Return Stream(name,"Command", newCommand)
  