/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

-- InspectTokens.rex - A sample program for the Rexx Tokenizer. It tokenizes a file, and prints its tokenization. 

Parse Arg inFile

detailed = 1
full     = 1
Do While inFile~Word(1)~Left(1) == "-"
  Parse var inFile option inFile
  Select Case Upper(option)
    When "-H", "-HELP" Then Do
      Say .resources[help]
      Exit 1
    End
    When "-D", "-DETAIL",   "-DETAILED"   Then detailed = 1
    When "-N", "-NODETAIL", "-NODETAILED" Then detailed = 0
    When "-F", "-FULL"                    Then full     = 1
    When "-S", "-SIMPLE"                  Then full     = 0
    Otherwise
      Say "Invalid option '"option"'."
      Exit 1
  End
End

If inFile = "" Then Do
  Say .resources[help]
  Exit 1
End

quote = infile[1]
If Pos(quote,"""'") > 0 Then Do Parse Arg (quote)inFile(quote)rest

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

-- Get a tokenizer instance for our source

tokenizer = .ooRexx.Unicode.Tokenizer~new(source, detailed)

-- The following code fragment allows symbolic manipulation of
-- the constants returned by the tokenizer.

Do constant over tokenizer~tokenClasses -- Create the constants...
  c1 = constant[1]
  c2 = constant[2]
  Call Value c1, c2
  nameOf.c2 = c1                        -- ...and a prettyprinting stem
End

Call Time "R"

Do tokenNo = 1 By 1

  If full Then token = tokenizer~getFullToken
  Else         token = tokenizer~getSimpleToken
  
-- Exit conditions  
If token[class] == END_OF_SOURCE Then Leave
If token[class] == SYNTAX_ERROR  Then Leave

  Say Right(tokenNo,5) "["token[location]"]" printClass(token)": '"token[value]"'"
  
  -- Detailed full tokenizing? Print the absorbed subtokens
  If token~hasIndex(absorbed) Then Do
    clonedIndex = token[cloneIndex]
    Say "        ---> Absorbed:"
    Do subTokenNo = 1 To token[absorbed]~items
      subToken = token[absorbed][subTokenNo]
      Say "        "subTokenNo"["subToken[location]"]" printClass(subToken)": '"||subToken[value]"'" Copies("<==", subTokenNo = clonedIndex)
    End
  End

End

-- When a token is a SYNTAX_ERROR, it contains additional fields to print
-- a meaningful error message.
If token[class] == SYNTAX_ERROR Then Do
  Say
  Parse Value token["NUMBER"] With major"."minor
  Say "Syntax error" major"."minor "on line" token[line]":" token[message]
  Say token[secondaryMessage]
  Exit -major
End

Say Time("E")
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
inspect.rex -- Tokenize and inspect a .rex source file
------------------------------------------------------

Format:

  [rexx] InspectTokens[.rex] [options] [filename]

Options:
  
  -h, -help                   Print this information
  -d, -detail, -detailed      Perform a detailed tokenization
  -n, -nodetail, -nodetailed  Perform an undetailed tokenization
  -f, -full                   Use the full tokenizer
  -s, -simple                 Use the simple tokenizer
   
::END    
::Requires Rexx.Tokenizer.cls
