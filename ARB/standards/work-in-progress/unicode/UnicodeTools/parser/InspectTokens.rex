/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

-- InspectTokens.rex - A sample program for the Rexx Tokenizer. It tokenizes a file, and then prints its tokenization. 

Parse Arg inFile

detailed = 1
full     = 1
unicode  = 1
dialect  = "ooRexx"
Do While inFile~Word(1)~Left(1) == "-"
  Parse var inFile option inFile
  Select Case Upper(option)
    When "-H", "-HELP" Then Do
      Say .resources[help]
      Exit 1
    End
    When "-D",  "-DETAIL",   "-DETAILED"   Then detailed = 1
    When "-ND", "-NODETAIL", "-NODETAILED" Then detailed = 0
    When "-F",  "-FULL"                    Then full     = 1
    When "-S",  "-SIMPLE"                  Then full     = 0
	When "-U",  "-UNICODE"                 Then Unicode  = 1
	When "-NU", "-NOUNICODE"               Then Unicode  = 0
	When "-R",  "-REGINA"                  Then dialect  = "Regina"
	When "-O",  "-OOREXX"                  Then dialect  = "ooRexx"
	When "-A",  "-ANSI"                    Then dialect  = "ANSI"
    Otherwise
      Say "Invalid option '"option"'."
      Exit 1
  End
End

inFile = Strip(inFile)

If inFile = "" Then Do
  Say .resources[help]
  Exit 1
End

quote = infile[1]
If Pos(quote,"""'") > 0 Then Do 
  Parse Arg (quote)inFile(quote)rest
  If rest \= "" Then Do
    Say "Invalid file name" quote||inFile||quote||rest"."
    Exit 1
  End
End

If Stream(inFile,"C","Query exists") == "" Then Do
  Say "File '"inFile"' not found."
  Exit 1
End

source = CharIn(inFile,,Chars(inFile))~makeArray

-- Select the right tokenizer class

Select Case dialect
  When "ooRexx" Then
    If Unicode Then tokenizerClass = .ooRexx.Unicode.Tokenizer
	Else            tokenizerClass = .ooRexx.Tokenizer
  When "Regina" Then
    If Unicode Then tokenizerClass = .Regina.Unicode.Tokenizer
	Else            tokenizerClass = .Regina.Tokenizer
  When "ANSI"   Then
    If Unicode Then tokenizerClass = .ANSI.Rexx.Unicode.Tokenizer
	Else            tokenizerClass = .ANSI.Rexx.Tokenizer
End

-- Get a tokenizer instance for our source

tokenizer = tokenizerClass~new(source, detailed)

-- The following code fragment allows symbolic manipulation of
-- the constants returned by the tokenizer.

Do constant over tokenizer~tokenClasses -- Create the constants...
  c1 = constant[1]
  c2 = constant[2]
  Call Value c1, c2
  nameOf.c2 = c1                        -- ...and a prettyprinting stem
End

Call Time "R"

tokens = .Array~new

LocationPlaces. = 0



Do tokenNo = 1 By 1
  If full Then token = tokenizer~getFullToken
  Else         token = tokenizer~getSimpleToken

  lastToken = token
  
  -- Exit conditions  
  If token[class] == END_OF_SOURCE Then Leave
  If token[class] == SYNTAX_ERROR  Then Leave
  
  Parse Value token[location] With n.1 n.2 n.3 n.4
  Do i = 1 To 4
    LocationPlaces.i = Max(LocationPlaces.i, Length(n.i))
  End
  
  tokens~append(token)
End


Do tokenNo = 1 To tokens~items

  token = tokens[tokenNo]

  Parse Value token[location] With n.1 n.2 n.3 n.4

  Say Right(tokenNo,5),
    "["||,
    Right(n.1, LocationPlaces.1),
    Right(n.2, LocationPlaces.2),
    Right(n.3, LocationPlaces.3),
    Right(n.4, LocationPlaces.4) || ,
    "]" printClass(token)": '"token[value]"'"
  
  -- Detailed full tokenizing? Print the absorbed subtokens
  If token~hasIndex(absorbed) Then Do
    clonedIndex = token[cloneIndex]
    Say "        ---> Absorbed:"
    subTokenNoPlaces = Length(token[absorbed]~items)
    SubTokenLocationPlaces. = 0
    Do subTokenNo = 1 To token[absorbed]~items
      subToken = token[absorbed][subTokenNo]
      Parse Value subToken[location] With n.1 n.2 n.3 n.4
      SubTokenLocationPlaces.1 = Max(SubTokenLocationPlaces.1, Length(n.1))
      SubTokenLocationPlaces.2 = Max(SubTokenLocationPlaces.2, Length(n.2))
      SubTokenLocationPlaces.3 = Max(SubTokenLocationPlaces.3, Length(n.3))
      SubTokenLocationPlaces.4 = Max(SubTokenLocationPlaces.4, Length(n.4))
    End
    Do subTokenNo = 1 To token[absorbed]~items
      subToken = token[absorbed][subTokenNo]
      Parse Value subToken[location] With n.1 n.2 n.3 n.4
      Say "        "Right(subTokenNo,subTokenNoPlaces),
        "[" || , 
          Right(n.1, SubTokenLocationPlaces.1) ,
          Right(n.2, SubTokenLocationPlaces.2) ,
          Right(n.3, SubTokenLocationPlaces.3) ,
          Right(n.4, SubTokenLocationPlaces.4) ||,
        "]" printClass(subToken)": '"||subToken[value]"'" Copies("<==", subTokenNo = clonedIndex)
    End
  End

End

-- When a token is a SYNTAX_ERROR, it contains additional fields to print
-- a meaningful error message.
If lastToken[class] == SYNTAX_ERROR Then Do
  Say
  Parse Value lastToken["NUMBER"] With major"."minor
  Say "Syntax error" major"."minor "on line" lastToken[line]":" lastToken[message]
  Say lastToken[secondaryMessage]
  Exit -major
End

Say "Took" Time("E") "seconds."
Exit

PrintClass:
  theClass    = Arg(1)[class]
  theSubClass = Arg(1)[subClass]
  
  -- Class and subclass are the same in some cases. 
  -- Print only the class, since the subclass is redundant
  If theClass == theSubClass Then Return nameOf.[theClass]
  
  -- Print class and subclass
  Return nameOf.[theClass] "("nameOf.[theSubClass]")"
  
::Resource Help
InspectTokens.rex -- Tokenize and inspect a .rex source file
------------------------------------------------------------

Format:

  [rexx] InspectTokens[.rex] [options] [filename]

Options (starred descriptions are the default):
  
  -h,  -help                   Print this information
  -d,  -detail, -detailed      Perform a detailed tokenization (*)
  -nd, -nodetail, -nodetailed  Perform an undetailed tokenization
  -f,  -full                   Use the full tokenizer (*)
  -s,  -simple                 Use the simple tokenizer
  -u,  -unicode                Allow Unicode extensions (*)
  -nu, -nounicode              Do not allow Unicode extensions
  -o,  -oorexx                 Use the Open Object Rexx tokenizer (*)
  -r,  -regina                 Use the Regina Rexx tokenizer
  -a,  -ansi                   Use the ANSI Rexx tokenizer
::END    
::Requires Rexx.Tokenizer.cls
