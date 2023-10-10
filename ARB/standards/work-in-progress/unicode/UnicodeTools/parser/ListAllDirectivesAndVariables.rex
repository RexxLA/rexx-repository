/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

-- ListAllDirectivesAndVariables.rex
-- =================================
--
-- A demo program for the Rexx tokenizer, following a suggestion by Rony Flatscher
--
-- This program scans a ooRexx files and lists all its directives.
-- It also collects all its variables and environment symbols, and
-- it lists them, ordered alphabetically and followed by the line
-- numbers in which they appear, after each directive (since a
-- directive opens a new section of code).
--
-- Limitation: the usefulness of this program is limited, because
-- we are using a tokenizer, not a full AST parser, and therefore
-- some sub-keywords, like "over", "value" or "with" may appear
-- wrongly listed as variables. The same is true of function
-- and method names.
-- 
-- Arguments: name -- The Rexx file to inspect
--
-- This program is a demo, and it includes no error handling.
--

Parse Arg fn                                      -- No error handling

source   = CharIn(fn,1,Chars(fn))~makeArray       -- Create an array (fast)
Call       Stream fn,"C","Close"                  -- Close the file
detailed = 0                                      -- We don't need a detailed tokenizing

tokenizer = .ooRexx.Tokenizer~new(source, detailed)

Do constant over tokenizer~tokenClasses           -- Create the constants
  c1 = constant[1]
  c2 = constant[2]
  Call Value c1, c2
  nameOf.c2 = c1                                  -- and a prettyprinting stem
End

-- We are interested in directives, variables symbols and (some) constant
-- symbols (i.e., environment symbols)

interested = DIRECTIVE || VAR_SYMBOL || CONST_SYMBOL

vars. = .nil                                        -- Will hold the variables of a code section

Loop

  If \MoreTokens() Then Leave                     -- If we don't leave, "token" is the next token
  If Pos(token[class], interested) == 0 Then Iterate -- We are not interested in this token
  If token[class] == CONST_SYMBOL, token[subClass] \== ENVIRONMENT_SYMBOL Then Iterate -- Ditto
  Parse Value token[location] With line .         -- Retrieve the line number
  
  -- Handle variables and environment symbols: collect them and their line numbers
  If token[class] \== DIRECTIVE Then Do           
    name = Upper( token[value] )
    If vars.name = .nil Then vars.name = .Set~new -- Use a set, we don't want duplicates
    vars.name~put(line)                           -- Store the line number
    Iterate                                       -- Go for the new token
  End
  
  -- That's a directive. If the "vars." stem has any tail, we have to list the variables
  
  tails = vars.~allIndexes~sort                   
  If tails~size > 0 Then Do
    Say "==============================================================================="
    Say 
    Say "  Variables and environment symbols        Lines"
    Say "  ---------------------------------        ------------------------------------"
    Do tail over tails
      If Length(tail) < 40 Then name = Left(tail,40)
      Else                      name = tail
      Nop
      lines = vars.tail~allIndexes~sort~makeString("Line"," ")
      Say "  "name lines
    End
    Say
    vars. = .nil                                  -- reset the "vars." stem
  End
  
  type = nameOf.[token[subclass]]                 -- And the directive type
  If \MoreTokens() Then Leave                     -- Next token is the name, if any
  
  -- No error handling: we assume that there is a symbol or a string after a directive
  -- that is not ::Annotate or ::Options (these two don't [always] have a name).
  Select
    When type == "ANNOTATE_DIRECTIVE" | type = "OPTIONS_DIRECTIVE" Then 
                                     name = ""
    When Token[class] == STRING Then name = '"'ChangeStr('"',Token[value],'""')'"'
    Otherwise                        name = Token[value]
  End
  
  Say "At line" line":" type name
  
End

Exit

----------------------------------------------------------------------------------------------------
-- MoreTokens (1) fills the "token" variable and (2) returns 0 at end of source or syntax error.  --
----------------------------------------------------------------------------------------------------

MoreTokens:
  token = tokenizer~getFullToken
Return Pos(token[class], SYNTAX_ERROR || END_OF_SOURCE ) == 0

::Options Prolog
::Annotate Package a b
::Constant K
::Class C
::Method M
::Attribute A
::Resource Res
A line
::END
::Routine R
::Requires "Rexx.Tokenizer.cls"