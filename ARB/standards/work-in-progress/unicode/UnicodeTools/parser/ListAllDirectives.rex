-- This file is part of The Unicode Tools Of Rexx (TUTOR)
-- See https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/ for more information
-- Copyright © 2023, Josep Maria Blasco <josep.maria.blasco@epbcn.com>
-- License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).

-- ListAllDirectives.rex
-- =====================
--
-- A demo program for the Rexx tokenizer, following a suggestion by Rony Flatscher
--
-- This program scans a ooRexx files and lists all its directives.
-- 
-- Items listed are (1) the line number, (2) the directive type and 
-- (3) the directive name, when applicable (::Annotate and ::Options do
-- not have a clear notion of name).
--
-- Arguments: name -- The Rexx file to inspect
--
-- This program is a demo, and it includes no error handling.
--

Parse Arg fn                                      -- No error handling

size     = Stream(fn,"C","Q Size")                -- Retrieve the size and...
source   = CharIn(fn,1,size)~makeArray            -- ...create an array (fast)
Call       Stream fn,"C","Close"                  -- Close the file
detailed = 0                                      -- We don't need a detailed tokenizing

tokenizer = .ooRexx.Tokenizer~new(source, detailed)

Do constant over tokenizer~tokenClasses           -- Create the constants
  c1 = constant[1]
  c2 = constant[2]
  Call Value c1, c2
  pretty.c2 = c1                                  -- and a prettyprinting stem
End

Loop

  If \MoreTokens() Then Leave                     -- If we don't leave, "token" is the next token
  If token[class] \== DIRECTIVE Then Iterate      -- We are interested only in directives
  Parse Value token[location] With line .         -- Retrieve the line number
  type = pretty.[token[subclass]]                 -- And the directive type
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
-- TODO: Bug: this line is necessary, otherwise the ::Routine is not seen
::Routine R
::Requires "Rexx.Tokenizer.cls"