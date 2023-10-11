/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

/**
 *                                                                           
 *  <h2><code>Rexx.Tokenizer.cls</code></h2>
 *                        
 *  <p>
 *    Please refer to the accompanying file "readme.md" for documentation.
 * 
 *  <h4>Notice</h4>:
 *
 *  <p>Although this routine is part of TUTOR, The Unicode Tools Of Rexx,
 *    it can also be used separately, as it has no dependencies on the rest
 *    of components of TUTOR.
 *
 *  <h4>Version history</h4>
 *  
 *  <table class="table table-bordered">
 *    <tr><th>Ver.  <th>Aut.<th>Date    <th>Description
 *    <tr><td>00.1d <td>JMB <td>20230716<td>Initial public release
 *    <tr><td>00.1e <td>JMB <td>20230720<td>Support U+hhhh in U strings
 *    <tr><td>00.2  <td>JMB <td>20230725<td>Add support for "C" (Classic Rexx) strings
 *    <tr><td>00.2a <td>JMB <td>20230727<td>Change RUNES to CODEPOINTS
 *    <tr><td>00.2b <td>JMB <td>20230729<td>Fix subtle bug when / at start of multi-line comment
 *    <tr><td>00.3  <td>JMB <td>20230811<td>Change "C" suffix to "Y", as per Rony's suggestion
 *    <tr><td>      <td>JMB <td>20230818<td>All tokens return "line1 start line2 start" as .location
 *    <tr><td>00.4  <td>JMB <td>20230901<td>Implement full tokenizing
 *    <tr><td>00.4a <td>JMB <td>20230901<td>Move most of the external documentation to readme.md
 *  </table>
 *                                                                           
 */

::Class ooRexx.Tokenizer            Subclass Rexx.Tokenizer      Public
::Class ooRexx.Unicode.Tokenizer    Subclass ooRexx.Tokenizer    Public
::Class Regina.Tokenizer            Subclass Rexx.Tokenizer      Public
::Class Regina.Unicode.Tokenizer    Subclass Regina.Tokenizer    Public
::Class ANSI.Rexx.Tokenizer         Subclass Rexx.Tokenizer      Public
::Class ANSI.Rexx.Unicode.Tokenizer Subclass ANSI.Rexx.Tokenizer Public

::Class Rexx.Tokenizer                                           Public

::Method init
  Use local pkglocal
  Use Strict Arg source, detailed = 0
  line                   = 0
  pos                    = 0
  maxLines               = source~items
  moreLines              = line < maxLines
  UnicodeLoaded          = 0  
  
  pkgLocal               = .context~package~local
  
  pkgLocal~ooRexx        = self~isA(.ooRexx.Tokenizer)
  pkgLocal~Regina        = self~isA(.Regina.Tokenizer)
  pkgLocal~ANSI          = self~isA(.ANSI.Rexx.Tokenizer)
  pkgLocal~Unicode       = self~isA(.ooRexx.Unicode.Tokenizer) |,
                           self~isA(.Regina.Unicode.Tokenizer) |,
                           self~isA(.ANSI.Rexx.Unicode.Tokenizer)
                                    
  pkgLocal~line_comments = \ ( .ANSI )

  -- Ensure that the second element of each tokenClasses element
  -- is distinct
  tokenClasses = self~tokenClasses
  Do counter c pair Over tokenClasses 
    pair[2] = X2C(D2X(c - 1))
    If c >= 256 Then Say "PANIC! tolenClasses array has more than 256 elements!"
  End
    
  self~InitializeCharacterCategories
  self~InitializeClasses
  self~InitializeStringSuffixes -- After InitializeClasses
  self~InitializeKeywordInstructions
  self~InitializeDirectives
  self~InitializeActionPairs
  self~InitializeOperatorTable
  self~InitializeTokenizer
  self~InitializeSimpleTokenizer
    
-- This is a vector of two-element vectors. Each second element is an asterisk;
-- it will be substituted by a distinct char value in the init method.
::Constant tokenClasses (    -             
  ( SYNTAX_ERROR                   , "*" ), -  -- Special token returned when a Syntax error is found
  ( OPERATOR                       , "*" ), -
                                            -  -- +--- All subclasses of OPERATOR are full tokenizer only
    ( ADDITIVE_OPERATOR            , "*" ), -  -- | "+", "-" 
    ( COMPARISON_OPERATOR          , "*" ), -  -- | "=", "\=", ">", "<", "><", "<>", ">=", "\<", "<=", "\>" 
                                            -  -- | "==", "\==", ">>", "<<", ">>=", "\<<", "<<=", "\>>"
    ( CONCATENATION_OPERATOR       , "*" ), -  -- | "||" 
    ( LOGICAL_OPERATOR             , "*" ), -  -- | "&", "|", "&&" 
    ( MESSAGE_OPERATOR             , "*" ), -  -- | "~", "~~" 
    ( MULTIPLICATIVE_OPERATOR      , "*" ), -  -- | "*", "/", "//", "%" 
    ( POWER_OPERATOR               , "*" ), -  -- | "**" 
    ( EXTENDED_ASSIGNMENT          , "*" ), -  -- | "+=", "-=", "*=", "/=", "%=", "//=", "||=", "&=", "|=", "&&=", "**=" 
                                            -  -- +--- All subclasses of OPERATOR are full tokenizer only
  ( SPECIAL                        , "*" ), -
  ( COLON                          , "*" ), -
  ( DIRECTIVE_START                , "*" ), -  -- "::" (Full tokenizer only, absorbed by directive)
  ( LPAREN                         , "*" ), -
  ( RPAREN                         , "*" ), -
  ( LBRACKET                       , "*" ), -
  ( RBRACKET                       , "*" ), -
  ( BLANK                          , "*" ), -  -- May be ignorable, or not
  ( LINE_COMMENT                   , "*" ), -  -- Up to but not including the end of the line
  ( CLASSIC_COMMENT                , "*" ), -  -- Infinite nesting allowed
  ( RESOURCE                       , "*" ), -  -- The resource itself, i.e., the array of lines
  ( RESOURCE_DELIMITER             , "*" ), -  -- End delimiter, ends resource
  ( RESOURCE_IGNORED               , "*" ), -  -- After "::Resource name ;" or "::END delimiter"
  ( END_OF_SOURCE                  , "*" ), -
  ( END_OF_CLAUSE                  , "*" ), -
    ( BEGIN_OF_SOURCE              , "*" ), -  -- Dummy and inserted. Very convenient for simplification
    ( END_OF_LINE                  , "*" ), -  -- Implied semicolon
    ( SEMICOLON                    , "*" ), -  -- An explicit semicolon
    ( INSERTED_SEMICOLON           , "*" ), -  -- For example, after a label, THEN, ELSE, and OTHERWISE
                                            -
                                            -  -- CLAUSE SUPPORT (Full tokenizer only)
                                            -  -- ==============
  ( LABEL                          , "*" ), -  -- Includes and absorbs the COLON
                                            -  -- All DIRECTIVEs include and absorb the :: marker
  ( DIRECTIVE                      , "*" ), -  -- 
    ( ANNOTATE_DIRECTIVE           , "*" ), -  -- 
    ( ATTRIBUTE_DIRECTIVE          , "*" ), -  -- 
    ( CLASS_DIRECTIVE              , "*" ), -  -- 
    ( CONSTANT_DIRECTIVE           , "*" ), -  -- 
    ( METHOD_DIRECTIVE             , "*" ), -  -- 
    ( OPTIONS_DIRECTIVE            , "*" ), -  -- 
    ( REQUIRES_DIRECTIVE           , "*" ), -  -- 
    ( RESOURCE_DIRECTIVE           , "*" ), -  -- 
    ( ROUTINE_DIRECTIVE            , "*" ), -  -- 
                                            -  --
  ( KEYWORD_INSTRUCTION            , "*" ), -  -- All KEYWORD_INSTRUCTIONs include the first blank after the keyword, if present 
    (ADDRESS_INSTRUCTION           , "*" ), -  --     
    (ARG_INSTRUCTION               , "*" ), -  -- 
    (CALL_INSTRUCTION              , "*" ), -  -- 
    (CALL_ON_INSTRUCTION           , "*" ), -  -- Includes the ON  sub-keyword
    (CALL_OFF_INSTRUCTION          , "*" ), -  -- Includes the OFF sub-keyword
    (DO_INSTRUCTION                , "*" ), -  -- 
    (DROP_INSTRUCTION              , "*" ), -  -- 
    (ELSE_INSTRUCTION              , "*" ), -  -- Inserts a ";" after
    (END_INSTRUCTION               , "*" ), -  -- 
    (EXIT_INSTRUCTION              , "*" ), -  -- 
    (EXPOSE_INSTRUCTION            , "*" ), -  -- 
    (FORWARD_INSTRUCTION           , "*" ), -  -- 
    (GUARD_INSTRUCTION             , "*" ), -  -- 
    (IF_INSTRUCTION                , "*" ), -  -- 
    (INTERPRET_INSTRUCTION         , "*" ), -  -- 
    (ITERATE_INSTRUCTION           , "*" ), -  -- 
    (LEAVE_INSTRUCTION             , "*" ), -  -- 
    (LOOP_INSTRUCTION              , "*" ), -  -- 
    (NOP_INSTRUCTION               , "*" ), -  -- 
    (NUMERIC_INSTRUCTION           , "*" ), -  -- 
    (OPTIONS_INSTRUCTION           , "*" ), -  -- 
    (OTHERWISE_INSTRUCTION         , "*" ), -  -- Inserts a ";" after
    (PARSE_INSTRUCTION             , "*" ), -  -- Includes UPPER, LOWER and CASELESS (as attributes too)
    (PROCEDURE_INSTRUCTION         , "*" ), -  -- 
    (PUSH_INSTRUCTION              , "*" ), -  -- 
    (PULL_INSTRUCTION              , "*" ), -  -- 
    (QUEUE_INSTRUCTION             , "*" ), -  -- 
    (RAISE_INSTRUCTION             , "*" ), -  -- 
    (REPLY_INSTRUCTION             , "*" ), -  -- 
    (RETURN_INSTRUCTION            , "*" ), -  -- 
    (SAY_INSTRUCTION               , "*" ), -  -- 
    (SELECT_INSTRUCTION            , "*" ), -  -- 
    (SIGNAL_INSTRUCTION            , "*" ), -  -- 
    (SIGNAL_ON_INSTRUCTION         , "*" ), -  -- Includes SIGNAL ON
    (SIGNAL_OFF_INSTRUCTION        , "*" ), -  -- Includes SIGNAL OFF
    (THEN_INSTRUCTION              , "*" ), -  -- Inserts a ";" before and after
    (TRACE_INSTRUCTION             , "*" ), -  -- 
    (UPPER_INSTRUCTION             , "*" ), -  -- Regina only, no ANSI
    (USE_INSTRUCTION               , "*" ), -  -- 
    (WHEN_INSTRUCTION              , "*" ), -  -- 
  ( ASSIGNMENT_INSTRUCTION         , "*" ), -  -- Variable assignments, not message assignments             
  ( COMMAND_OR_MESSAGE_INSTRUCTION , "*" ), -  -- Cannot determine without arbitrarily large context        
                                            -  -- End of CLAUSE SUPPORT
                                            -  -- =====================
  ( VAR_SYMBOL                     , "*" ), -  
    ( SIMPLE_VAR                   , "*" ), -  
    ( STEM_VAR                     , "*" ), -
    ( COMPOUND_VAR                 , "*" ), -
  ( NUMBER                         , "*" ), -
    ( INTEGER                      , "*" ), -
    ( FRACTIONAL                   , "*" ), -
    ( EXPONENTIAL                  , "*" ), -
  ( CONST_SYMBOL                   , "*" ), -
    ( PERIOD_SYMBOL                , "*" ), -
    ( LITERAL_SYMBOL               , "*" ), -
    ( ENVIRONMENT_SYMBOL           , "*" ), -
  ( STRING                         , "*" ), -
    ( BINARY_STRING                , "*" ), -
    ( HEXADECIMAL_STRING           , "*" ), -
    ( CHARACTER_STRING             , "*" ), -  
    ( BYTES_STRING                 , "*" ), -  -- Unicode only. Y suffix
    ( CODEPOINTS_STRING            , "*" ), -  -- Unicode only. P suffix
    ( TEXT_STRING                  , "*" ), -  -- Unicode only. T suffix
    ( UNOTATION_STRING             , "*" )  -  -- Unicode only. U suffix
)

::Method InitializeClasses Private
  Use Local tc
  
  Do tc over self~tokenClasses
    Call Value tc[1], tc[2]
  End

  -- Useful compound values
  
  SYMBOL                        = VAR_SYMBOL || CONST_SYMBOL || NUMBER
  STRING_OR_SYMBOL              = STRING || SYMBOL
  IGNORE_NEXT_BLANK             = END_OF_CLAUSE || OPERATOR || SPECIAL || COLON || LPAREN || LBRACKET
  -- NULL clauses are ignored
  CLAUSE            = LABEL || DIRECTIVE || KEYWORD_INSTRUCTION || ASSIGNMENT_INSTRUCTION || COMMAND_OR_MESSAGE_INSTRUCTION

-- Transform string suffixes to subclasses
::Method InitializeStringSuffixes Private
  Use Local
  suffix2subClass.["B"] = BINARY_STRING
  suffix2subClass.["X"] = HEXADECIMAL_STRING
  suffix2subClass.["K"] = CHARACTER_STRING
  suffix2subClass.["Y"] = BYTES_STRING
  suffix2subClass.["P"] = CODEPOINTS_STRING
  suffix2subClass.["T"] = TEXT_STRING
  suffix2subClass.["U"] = UNOTATION_STRING

::Method InitializeKeywordInstructions Private
  Use Local
  
  NO_KEYWORD_INSTRUCTION = "00"X
  
  keywordInstruction.              = NO_KEYWORD_INSTRUCTION
  keywordInstruction.["ADDRESS"]   =    ADDRESS_INSTRUCTION
  keywordInstruction.["ARG"]       =        ARG_INSTRUCTION
  keywordInstruction.["CALL"]      =       CALL_INSTRUCTION
  keywordInstruction.["DO"]        =         DO_INSTRUCTION
  keywordInstruction.["DROP"]      =       DROP_INSTRUCTION
  keywordInstruction.["ELSE"]      =       ELSE_INSTRUCTION
  keywordInstruction.["END"]       =        END_INSTRUCTION
  keywordInstruction.["EXIT"]      =       EXIT_INSTRUCTION
If .ooRexx Then Do
  keywordInstruction.["EXPOSE"]    =     EXPOSE_INSTRUCTION
  keywordInstruction.["FORWARD"]   =    FORWARD_INSTRUCTION
  keywordInstruction.["GUARD"]     =      GUARD_INSTRUCTION
End  
  keywordInstruction.["IF"]        =         IF_INSTRUCTION
  keywordInstruction.["INTERPRET"] =  INTERPRET_INSTRUCTION
  keywordInstruction.["ITERATE"]   =    ITERATE_INSTRUCTION
  keywordInstruction.["LEAVE"]     =      LEAVE_INSTRUCTION
If .ooRexx Then Do  
  keywordInstruction.["LOOP"]      =       LOOP_INSTRUCTION
End
  keywordInstruction.["NOP"]       =        NOP_INSTRUCTION
  keywordInstruction.["NUMERIC"]   =    NUMERIC_INSTRUCTION
  keywordInstruction.["OPTIONS"]   =    OPTIONS_INSTRUCTION
  keywordInstruction.["OTHERWISE"] =  OTHERWISE_INSTRUCTION
  keywordInstruction.["PARSE"]     =      PARSE_INSTRUCTION
  keywordInstruction.["PROCEDURE"] =  PROCEDURE_INSTRUCTION
  keywordInstruction.["PULL"]      =       PULL_INSTRUCTION
  keywordInstruction.["PUSH"]      =       PUSH_INSTRUCTION
  keywordInstruction.["QUEUE"]     =      QUEUE_INSTRUCTION
If .ooRexx Then Do  
  keywordInstruction.["RAISE"]     =      RAISE_INSTRUCTION
  keywordInstruction.["REPLY"]     =      REPLY_INSTRUCTION
End  
  keywordInstruction.["RETURN"]    =     RETURN_INSTRUCTION
  keywordInstruction.["SAY"]       =        SAY_INSTRUCTION
  keywordInstruction.["SELECT"]    =     SELECT_INSTRUCTION
  keywordInstruction.["SIGNAL"]    =     SIGNAL_INSTRUCTION
  keywordInstruction.["THEN"]      =       THEN_INSTRUCTION
  keywordInstruction.["TRACE"]     =      TRACE_INSTRUCTION
If .Regina, \.ANSI Then Do  
  keywordInstruction.["UPPER"]     =      UPPER_INSTRUCTION
End
  keywordInstruction.["USE"]       =        USE_INSTRUCTION
  keywordInstruction.["WHEN"]      =       WHEN_INSTRUCTION

::Method InitializeDirectives
  Use Local
  
  -- SYNTAX_ERROR instead of NO_DIRECTIVE because directives are a closed set
  
  directive.              =        SYNTAX_ERROR
  directive.["ANNOTATE" ] =  ANNOTATE_DIRECTIVE
  directive.["ATTRIBUTE"] = ATTRIBUTE_DIRECTIVE
  directive.["CLASS"    ] =     CLASS_DIRECTIVE
  directive.["CONSTANT" ] =  CONSTANT_DIRECTIVE
  directive.["METHOD"   ] =    METHOD_DIRECTIVE
  directive.["OPTIONS"  ] =   OPTIONS_DIRECTIVE
  directive.["REQUIRES" ] =  REQUIRES_DIRECTIVE
  directive.["RESOURCE" ] =  RESOURCE_DIRECTIVE
  directive.["ROUTINE"  ] =   ROUTINE_DIRECTIVE

::Method InitializeActionPairs Private
  Use Local
  -- Create an action matrix for full the full tokenizer, indexed by category x category,
  -- to drive a Finite State Machine.
  --
  -- We will use it below, in a calculated Signal.

  -- Default action
  Action.                                = Return_a_token
    
  Action.DIRECTIVE.BLANK                 = Ignore_this_token
  Action.KEYWORD_INSTRUCTION.BLANK       = Ignore_this_token
    
  Action.END_OF_CLAUSE.END_OF_CLAUSE     = Ignore_last_token
  Action.BLANK.END_OF_CLAUSE             = Ignore_last_token
  Action.END_OF_CLAUSE.BLANK             = Ignore_this_token
  Action.END_OF_CLAUSE.CLASSIC_COMMENT   = Ignore_this_token
  Action.END_OF_CLAUSE.LINE_COMMENT      = Ignore_this_token
    
  Action.BLANK.BLANK                     = Ignore_last_token
    
  Action.BLANK.RPAREN                    = Ignore_last_token 
  Action.BLANK.RBRACKET                  = Ignore_last_token 
  Action.BLANK.SPECIAL                   = Ignore_last_token
  Action.BLANK.COLON                     = Ignore_last_token
  Action.BLANK.OPERATOR                  = Ignore_last_token

  Action.LPAREN.BLANK                    = Ignore_this_token 
  Action.LBRACKET.BLANK                  = Ignore_this_token 
  Action.SPECIAL.BLANK                   = Ignore_this_token
  Action.COLON.BLANK                     = Ignore_this_token
  
  Do v Over self~tokenClasses
    c = v[2]
    Action.c.VAR_SYMBOL                  = Check_for_then
  End

  Do v Over self~tokenClasses
    c = v[2]
    Action.DIRECTIVE_START.c             = 20.916 -- Symbol expected after ::.
  End
  Action.DIRECTIVE_START.BLANK           = Ignore_this_token
  Action.DIRECTIVE_START.VAR_SYMBOL      = Make_directive
  Action.DIRECTIVE_START.CONST_SYMBOL    = Make_directive
  Action.DIRECTIVE_START.NUMBER          = Make_directive

  -- Comments are ignorable in all classes
  Do v Over self~tokenClasses
    c = v[2]
    Action.LINE_COMMENT.c                = Ignore_last_token
    Action.CLASSIC_COMMENT.c             = Ignore_last_token
    Action.c.LINE_COMMENT                = Ignore_this_token
    Action.c.CLASSIC_COMMENT             = Ignore_this_token
  End

  -- "-" + END_OF_CLAUSE (ooRexx, and Regina, but not ANSI)
If \.ANSI Then Do  
  Action.SPECIAL.END_OF_CLAUSE           = Check_Continuation
End  
      
  -- There is a "window" operating over "lastToken" and "token" where most of the
  -- actions (transformations) are performed.
  -- In the case of certain actions, we may need a wider context.
  -- Part of this wider context is supplied by the "nextToLastToken" variable,
  -- and another part, when even "nextToLastToken" is not enough, is provided
  -- by marking a token as the "firstInClause" using an attribute of the token.
  -- This is done for tokens that immediately follow an END_OF_CLAUSE, and will
  -- allow us to classify and categorize instructions.
  --
  -- Some of the action mappings below should be understood with 
  -- these extensions in mind
  --  
  ------------------------------------------------------------------------------
  -- OPERATOR: In certain cases, an assignment                                --
  ------------------------------------------------------------------------------

  Do v Over self~tokenClasses
    c = v[2]
    Action.OPERATOR.C                    = Maybe_continuation_or_assignment
  End
  
  -- A compound operator (or a syntax error)
  Action.OPERATOR.OPERATOR               = Attempt_operator_merge
  -- Ignore ignorables
  Action.OPERATOR.BLANK                  = Ignore_this_token
  Action.OPERATOR.CLASSIC_COMMENT        = Ignore_this_token
  Action.OPERATOR.LINE_COMMENT           = Ignore_this_token

  ------------------------------------------------------------------------------
  -- COLON: Maybe a label                                                     --
  ------------------------------------------------------------------------------

  Do v Over self~tokenClasses
    c = v[2]
    Action.COLON.c                       = Maybe_a_label
  End
  
  -- Override: Ignore all ignorable stuff first
  
  Action.COLON.BLANK                     = Ignore_this_token
  Action.COLON.CLASSIC_COMMENT           = Ignore_this_token
  Action.COLON.LINE_COMMENT              = Ignore_this_token
 
  -- Override: "::" is a directive start (or an error) (ooRexx only)
If .ooRexx Then Do  
  Action.COLON.COLON                     = Detect_directive_start
End

::Method InitializeOperatorTable Private
  Use Local
  
  NO_OPERATOR = "00"X
  
  operator_subclass.       =             NO_OPERATOR
  operator_subclass.["||"] =  CONCATENATION_OPERATOR
  Do op over "+ -"~makeArray(" ")
    operator_subclass.op   =       ADDITIVE_OPERATOR
  End
  Do op over "* / // %"~makeArray(" ")
    operator_subclass.op   = MULTIPLICATIVE_OPERATOR
  End
  operator_subclass.["**"] =          POWER_OPERATOR
  Do op over "= \= > < >< <> >= \< <= \>"~makeArray(" ")
    operator_subclass.op   =     COMPARISON_OPERATOR
  End
  -- Strict comparisons
  Do op over "== \== >> << >>= \<< <<= \>>"~makeArray(" ")
    operator_subclass.op   =     COMPARISON_OPERATOR
  End
  Do op over "& | && \"~makeArray(" ")  
    operator_subclass.op   =        LOGICAL_OPERATOR
  End
  Do op over "~ ~~"~makeArray(" ")
    operator_subclass.op   =        MESSAGE_OPERATOR
  End
If \.ANSI Then Do
  Do op over "+=  -=  *= /=  %=  //=  ||=  &=  |=  &&= **="~makeArray(" ")
    operator_subclass.op   =        EXTENDED_ASSIGNMENT
  End
End

::Method InitializeTokenizer Private
  Use Local
  moreLines       = 1
  line            = 0
  pos             = 0
    
  lastToken          = .nil
  nextToLastToken    = .nil
   
  -- "THEN" is a keyword only when both openParens and openBrackets are == 0
  openParens         = 0
  openBrackets       = 0
  if_or_when_context = 0
  
  begin_of_source?   = 1
  buffer             = .Array~new  
  buffering          = 0

::Method Syntax_Error
  Expose SYNTAX_ERROR
  token. = .Stem~new
  Use   Arg errorNumber 
  Parse Arg       , startLine startPos . , . . endLine endPos .
  
  token.class            = SYNTAX_ERROR
  token.subClass         = SYNTAX_ERROR
  token.location         = startLine startPos endLine endPos
  errorMessages          = errorMessage(errorNumber, Arg(4,"A"))
  token.value            = errorMessages[1]
  token.number           = errorNumber
  token.message          = errorMessages[1]
  token.secondaryMessage = errorMessages[2]
  token.line             = startLine
Return token.  

::Method GetFullToken
  Use Local
  Use Strict Arg
       
-- We implement a lookahead with two variables, "token" and "lastToken".
--
-- In a few contexts, like when dealing with continuations, we may need a 3-token context 
-- (continuation character + EOL --> blank, but blank should be able to combine with the 
-- next-to-last token). We implement this with the "nextToLastToken" variable.
--
Get_more_tokens:

  If buffering Then Do
    token = buffer~delete(1)
    buffering = buffer~items \= 0
  End
  Else Do
    token = self~getSimpleToken
    If lastToken == .nil Then Do 
      lastToken = token
      token = self~getSimpleToken
    End
  End
 
Process_again: 
  lastValue = lastToken[value]

  -- Handle context for THEN  
  lClass    = lastToken[class] -- "lastClass" used by the simple tokenizer
  If lClass = END_OF_CLAUSE Then if_or_when_context = 0
  Else If if_or_when_context Then
    Select Case lastToken[class]
      When LBRACKET Then openBrackets += 1
      When LPAREN   Then openParens   += 1
      When RBRACKET Then openBrackets -= 1
      When RPAREN   Then openParens   -= 1
      Otherwise Nop
    End
  
--Say "Action.['"lastToken[class]" ("lastToken[location]")','"token[class]" ("token[location]")'] -->"  Action.[ lastToken[class], token[class] ]
  
  whatToDo  = Action.[ lastToken[class], token[class] ]
    
  Signal (whatToDo)  
     
Check_for_then:
  If \if_or_when_context              Then Signal Return_a_token
  If openBrackets \== 0               Then Signal Return_a_token
  If openParens   \== 0               Then Signal Return_a_token
  If Upper( token[value] ) \== "THEN" Then Signal Return_a_token
  token[class]    = KEYWORD_INSTRUCTION
  token[subClass] = THEN_INSTRUCTION
  -- ANSI 6.2.3, "Interaction between levels of syntax":
  --   When any of the keywords 'OTHERWISE', 'THEN', or 'ELSE' is recognized, a semicolon token is
  --   supplied as the following token. A semicolon token is supplied as the previous token when the
  --  'THEN' keyword is recognized.
  --
  buffer~insert(SemicolonAfter(token), .nil)
  buffering = 1
  -- The most usual case is that THEN follows a BLANK. Then the blank can be absorbed by the new semicolon
  insertBefore = SemicolonBefore(token)
  If lastToken[class] = BLANK Then Do
    Call AbsorbLeft lastToken, insertBefore
    lastToken = insertBefore
  End
  -- When THEN does NOT follow a BLANK, we have to insert the semicolon
  Else Do
    buffer~insert(token, .nil)
    token = insertBefore
  End
  Signal Return_a_token
     
Maybe_continuation_or_assignment:
  -- "-" + END_OF_CLAUSE? This is a continuation
  If lastToken[value] == "-", token[class] = END_OF_CLAUSE, token[subclass] = END_OF_LINE Then
    Signal Continuation
    
  -- Assignment only if "=" or EXTENDED_ASSIGNMENT
  If lastToken[value] \== "=", lastToken[subclass] \== EXTENDED_ASSIGNMENT Then
    Signal Return_a_token
  
  If nextToLastToken == .nil Then Signal Return_a_token  
  
  -- Assignment only operator after first (non-ignorable) token in clause
  If nextToLastToken[firstInClause] \== "1" Then Signal Return_a_token
  
  -- Assignment only if operator after a SYMBOL
  If \ThisTokenIsA(nextToLastToken, SYMBOL) Then Signal Return_a_token
  
  Select Case nextToLastToken[class]
    -- NUMBER = and CONST_SYMBOL = --> Syntax error
    When NUMBER, CONST_SYMBOL Then Do
      val = nextToLastToken[value]
      If val[1] == "." Then
        nextToLastToken = self~Syntax_Error(31.3, TrueLocation(nextToLastToken), lastToken[location],val)
      Else
        nextToLastToken = self~Syntax_Error(31.2, TrueLocation(nextToLastToken), lastToken[location],val)
    End
    -- Assignment!
    Otherwise nextToLastToken[class] = ASSIGNMENT_INSTRUCTION
  End
Signal Return_a_token  

Check_Continuation:
  -- Sequence must be "," or "-" + END_OF_LINE
  If token[subClass] \== END_OF_LINE      Then Signal Return_a_token
  If lastValue \== ",", lastValue \== "-" Then Signal Return_a_token
Continuation:  
  -- "," + EOL or "-" + EOL. This will be transformed into a blank,
  -- but then this blank might need to be combined with the nextToLastToken.
  --
  -- We implement that by popping one token up, since the continuation char
  -- + the EOL are reduced to a single blank
  Call AbsorbRight lastToken, token
  lastToken[value]    = " "
  lastToken[class]    = BLANK
  token           = lastToken
  lastToken       = nextToLastToken
  nextToLastToken = .nil
  Signal Process_again
    
Maybe_a_label:    
  -- A label has to start at the beginning of a clause
  If nextToLastToken[firstInClause] \== "1" Then Signal Return_a_token 
  -- TODO: Regina is not so lenient regarding label formats 

  -- Absorb the colon and insert a semicolon
  Call AbsorbRight nextToLastToken, lastToken
  nextToLastToken[class]  =  LABEL
  -- No need to insert a semicolon?
  If token[class] == END_OF_CLAUSE Then Do
    lastToken = token
    Signal Get_more_tokens
  End
  lastToken = SemicolonAfter(lastToken)
Signal Return_a_token 
    
-- "::" is ooRexx-only
Detect_directive_start:
  -- A "::" has to start at the beginning of a clause
  If nextToLastToken[class] == END_OF_CLAUSE Then Do
    Call AbsorbRight lastToken, token
    lastToken[class] = DIRECTIVE_START
    lastToken[value] = "::"
    Signal Get_more_tokens
  End
  -- A "::" that does not start at the beginning of a clause (maybe after some ignorables) is an error
  lastToken = self~Syntax_Error(35.1, TrueLocation(lastToken), token[location],"::")
Signal Return_a_token 

Make_directive:
  thisDirective = directive.[Upper(token[value])]
  -- Unrecognized directive instruction
  If thisDirective == SYNTAX_ERROR Then Do
    token = self~Syntax_Error(99.916, TrueLocation(lastToken), token[location])
    Signal Return_a_token 
  End
  token[class]    = DIRECTIVE
  token[subclass] = thisDirective
  Call AbsorbLeft lastToken,token
  lastToken = token  
Signal Get_more_tokens
    
SemicolonBefore: Procedure Expose END_OF_CLAUSE INSERTED_SEMICOLON
  Use Arg token.
  Parse Value token.location With line col .
  t. = .Stem~new
  t.class    = END_OF_CLAUSE
  t.subClass = INSERTED_SEMICOLON
  t.value = ""
  t.location = line col line col
Return t.   

SemicolonAfter: Procedure Expose END_OF_CLAUSE INSERTED_SEMICOLON
  Use Arg token.
  Parse Value token.location With . . line col .
  t. = .Stem~new
  t.class    = END_OF_CLAUSE
  t.subClass = INSERTED_SEMICOLON
  t.value = ""
  t.location = line col line col
Return t.    
 
Return_a_token:

  -- Need to fill the buffer?
  If nextToLastToken == .nil Then Do
    nextToLastToken = lastToken
    lastToken       = token
    Signal Get_more_tokens
  End
    
  -- Mark symbols and strings that are at start of clause
  If nextToLastToken[class] == END_OF_CLAUSE, ThisTokenIsA(lastToken,STRING_OR_SYMBOL) Then
    lastToken[firstInClause] = 1
    
  If nextToLastToken[class] == KEYWORD_INSTRUCTION Then Do
    Select Case nextToLastToken[subClass]
      When CALL_INSTRUCTION Then Do
        If lastToken[class] == VAR_SYMBOL, lastToken[subClass] = SIMPLE_VAR  UnicodeLoaded = 0, WordPos(Upper( lastToken[value] ),"ON OFF") > 0 Then Do
          If Upper( lastToken[value] ) == "ON" Then nextToLastToken[subClass] = CALL_ON_INSTRUCTION
          Else                                      nextToLastToken[subClass] = CALL_OFF_INSTRUCTION
          Call AbsorbRight nextToLastToken,lastToken
          lastToken = token
          Signal Get_more_tokens
        End
      End
      When SIGNAL_INSTRUCTION Then Do
        If lastToken[class] == VAR_SYMBOL, lastToken[subClass] = SIMPLE_VAR, WordPos(Upper( lastToken[value] ),"ON OFF") > 0 Then Do
          If Upper( lastToken[value] ) == "ON" Then nextToLastToken[subClass] = SIGNAL_ON_INSTRUCTION
          Else                                      nextToLastToken[subClass] = SIGNAL_OFF_INSTRUCTION
          Call AbsorbRight nextToLastToken,lastToken
          lastToken = token
          Signal Get_more_tokens
        End
      End
      When PARSE_INSTRUCTION Then Do
        val = Upper( lastToken[value] )
        If lastToken[class] == VAR_SYMBOL, lastToken[subClass] = SIMPLE_VAR, WordPos(val,"UPPER LOWER CASELESS") > 0 Then Do
          If val == "CASELESS" Then Do
            If nextToLastToken~hasIndex(caseless) Then
              Return self~Syntax_error( 25.12, nextToLastToken[location], lastToken[location], val )
            Else nextToLastToken[caseless] = 1
          End
          Else Do
            If nextToLastToken~hasIndex(upper) | nextToLastToken~hasIndex(lower) Then
              Return self~Syntax_error( 25.12, nextToLastToken[location], lastToken[location], val )
            Else nextToLastToken[val] = 1
          End
          Call AbsorbRight nextToLastToken,lastToken
          lastToken = token
          Signal Get_more_tokens
        End
      End
      Otherwise Nop
    End
    
    If lastToken[class] == BLANK Then Do
      Call AbsorbRight nextToLastToken, lastToken
      lastToken = token
      Signal Get_more_tokens
    End
    
  End
    
  If nextToLastToken[class] == VAR_SYMBOL, nextToLastToken[subClass] == SIMPLE_VAR Then 
    possibleKeyword = 1
  Else
    possibleKeyword = 0
    
  If nextToLastToken[class] == OPERATOR Then
    nextToLastToken[subClass] = operator_subclass.[nextToLastToken[value]]
    
  If nextToLastToken[firstInClause] == "1" Then Do
    If possibleKeyword Then Do
      instruction = keywordInstruction.[ Upper( nextToLastToken[value] ) ]
      -- Handle keyword instructions
      If instruction \== NO_KEYWORD_INSTRUCTION Then Do
      
        nextToLastToken[class]    = KEYWORD_INSTRUCTION
        nextToLastToken[subClass] = instruction            
             
        Select Case instruction
          When IF_INSTRUCTION, WHEN_INSTRUCTION Then Do
            if_or_when_context = 1
            openParens         = 0
            openBrackets       = 0
          End
          -- ANSI, 6.2.3, "Interaction between levels of syntax":
          --
          --   When any of the keywords 'OTHERWISE', 'THEN', or 'ELSE' is recognized, a semicolon token is
          --   supplied as the following token. 
          --
          When ELSE_INSTRUCTION, OTHERWISE_INSTRUCTION Then Do
            insertAfter = SemicolonAfter(nextToLastToken)
            If lastToken[class] == BLANK Then Do
              Call AbsorbRight insertAfter, lastToken
              lastToken = insertAfter
            End
            Else Do
              buffer~insert(token)
              buffering = 1
              token     = lastToken
              lastToken = insertAfter 
            End
          End
          Otherwise Nop
        End
                
        If lastToken[class] == BLANK Then Do
           Call AbsorbRight nextToLastToken, lastToken
           lastToken = token
           Signal Get_more_tokens
        End
        
--      nextToLastToken[class]    = KEYWORD_INSTRUCTION
--      nextToLastToken[subClass] = instruction        
        
      End
      -- Return a non-spacing COMMAND_OR_MESSAGE_INSTRUCTION marker 
      Else Signal Mark_COMMAND_OR_MESSAGE_INSTRUCTION
    End
    -- Return a non-spacing COMMAND_OR_MESSAGE_INSTRUCTION marker 
    Else If \ThisTokenIsA(nextToLastToken, CLAUSE) Then
      Signal Mark_COMMAND_OR_MESSAGE_INSTRUCTION
  End

  returned        = nextToLastToken
  nextToLastToken = lastToken
  lastToken       = token
  Return returned

Mark_COMMAND_OR_MESSAGE_INSTRUCTION:
  nextToLastToken~remove(firstInClause)
  buffer~insert(token)
  buffering = 1
  token = lastToken
  lastToken = nextToLastToken
  nextToLastToken = COMMAND_OR_MESSAGE_INSTRUCTION_before(nextToLastToken)
Signal Return_a_token

COMMAND_OR_MESSAGE_INSTRUCTION_before: Procedure Expose COMMAND_OR_MESSAGE_INSTRUCTION
  Use Arg token.
  t. = .Stem~new
  t.class    = COMMAND_OR_MESSAGE_INSTRUCTION
  t.subClass = COMMAND_OR_MESSAGE_INSTRUCTION
  t.value    = ""
  t.location = SubWord(token.location,1,2) SubWord(token.location,1,2)
Return t.  

Ignore_this_token:
  Call AbsorbRight lastToken, token
  Signal Get_more_tokens

Ignore_last_token:
  Call AbsorbLeft lastToken, token
  lastToken = token  
  Signal Get_more_tokens

Attempt_operator_merge:
  newOp = lastToken[value] || token[value]
  If operator_subclass.newOp == NO_OPERATOR Then Signal Return_a_token
  Call AbsorbRight lastToken, token
  lastToken[value]    = newOp
  lastToken[subclass] = operator_subclass.newOp
  Signal Get_more_tokens

AbsorbLeft: Procedure Expose detailed
  Use Arg inserted, target
  If detailed, \target~hasIndex(absorbed) Then Do
    target[absorbed]   = .Array~of(CloneStem(target))
    target[cloneIndex] = 1
  End
  target[location] = SubWord(inserted[location],1,2) SubWord(target[location],3,2)
  If \detailed Then Return
  If inserted~hasIndex(absorbed) Then Do
    Do i = inserted[absorbed]~items To 1 By -1
      target[absorbed]~insert(inserted[absorbed][i],.nil)
      target[cloneIndex] += 1
    End
  End
  Else Do
    target[absorbed]~insert(inserted,.nil)
    target[cloneIndex] += 1
  End
Return

AbsorbRight: Procedure Expose detailed
  Use Arg target, inserted
  If detailed, \target~hasIndex(absorbed) Then Do
    target[absorbed]   = .Array~of(CloneStem(target))
    target[cloneIndex] = 1
  End
  target[location] = SubWord(target[location],1,2) SubWord(inserted[location],3,2)
  If \detailed Then Return
  If inserted~hasIndex(absorbed) Then Do
    Do i = 1 to inserted[absorbed]~items
      target[absorbed]~insert(inserted[absorbed][i])
    End
  End
  Else Do
    target[absorbed]~insert(inserted)
  End
Return

CloneStem: Procedure
  Use Strict Arg stem
  clone = .Stem~new
  Do ix over stem~allIndexes
    clone[ix] = stem[ix]
  End
  Return clone


-- Symbol expected after ::.
20.916: 
  lastToken = self~Syntax_Error(20.916, TrueLocation(lastToken), token[location])
Signal Return_a_token

::Method InitializeCharacterCategories Private
  Expose characters categories blank_character digit general_letter simple_symbol var_symbol_char
  
  characters         = ""
  categories         = ""

  -- The following values will be used as labels in the state machine below
  -- using a calculated Signal instruction.
  
  digit              = "d"
  general_letter     = "l"
  special            = "s"
  not                = "n"
  operator_only      = "o" -- Partial operator
  operator_or_other  = "/"
  blank_character    = " "
  semicolon          = ";"
  colon              = ":"
  lparen             = "("
  rparen             = ")"
  lbracket           = "["
  rbracket           = "]"
  illegal            = "x"
  
  simple_symbol      = general_letter || digit
  var_symbol_char    = simple_symbol  || "."

  -- ANSI 6.2.2.1: digit := '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
  Call AssignCharacterCategory digit,              "0123456789"
 
  -- ANSI 6.2.2.2: special := ',' | ':' | ';' | ')' | '(' 
  Call AssignCharacterCategory special,            ","
  -- Separate handling 
  Call AssignCharacterCategory semicolon,          ";"
  Call AssignCharacterCategory colon,              ":"
  Call AssignCharacterCategory lparen,             "("
  Call AssignCharacterCategory rparen,             ")"
  
  -- ANSI 6.2.2.3: not := '\' | other_negator
  Call AssignCharacterCategory not,                "\"

  -- ANSI 6.2.2.4 operator_only := '+' | '-' | '%' | '|' | '&' | '=' | not | '>' | '<'
  Call AssignCharacterCategory operator_only,      "+-%|&=><" -- "not" is handled separately

  -- ANSI 6.2.2.5: operator_or_other := '/' | '*'
  Call AssignCharacterCategory operator_or_other,  "/" -- Comment start, or 
  Call AssignCharacterCategory operator_only,      "*" -- pass it as an operatos, it works as such outside comments

  -- ANSI 6.2.2.6: operator_char := operator_only | operator_or_other

  -- ANSI 6.2.2.7: general_letter := '_' | '!' | '?' | extra_letter | 'A' | 'B' | 'C' ...
  Call AssignCharacterCategory general_letter,     "_!?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  -- ANSI 6.2.2.8: blank := ' ' | other_blank_character
  Call AssignCharacterCategory blank_character,    " "

  -- ANSI 6.2.2.9: bo := [blank+]

  -- Pass those as-is
  Call AssignCharacterCategory ".",                "."
  Call AssignCharacterCategory "'",                "'" -- String delimiter
  Call AssignCharacterCategory '"',                '"' -- String delimiter
  
  If .ooRexx Then Do
    Call AssignCharacterCategory lbracket,         "["
    Call AssignCharacterCategory rbracket,         "]"
    Call AssignCharacterCategory not,              "aaac"x -- other_negator. Two forms of the logical not character
    Call AssignCharacterCategory operator_only,    "~"     
    Call AssignCharacterCategory blank_character,  "09"x   -- Horizontal tab ("09"x) as other_blank_character
  End
  
  If .Regina Then Do
    -- Other_blank_character:
    -- Horizontal tab ("09"x), Newline ("0B"x), Vertical tabulator ("0B"x), 
    -- Form Feed ("0C"X), carriage Return
    Call AssignCharacterCategory blank_character,  "090A0B0C0D"x
    -- Extra_letter
    Call AssignCharacterCategory general_letter,   "$@#"
  End
  
  -- All other characters are illegal, except inside strings 
  Call AssignCharacterCategory illegal,            xRange()

Return
    
AssignCharacterCategory:
  characters ||= Arg(2)
  categories ||= Copies(Arg(1),Length(Arg(2)))
Return

::Method InitializeSimpleTokenizer Private
  Use Local

  lastClass          = "00"X
  
  
  -- Infrastructure to detect ::Resources in the simple tokenizer
  
  -- Possible values of "resourceContext":
  --
  -- -1: no resource context
  --  0: start of possible resource context (END_OF_CLAUSE found)
  --  1: ":" found after END_OF_CLAUSE
  --  2: ":" found after first ":"
  --  3: Resource found after "::"
  --  4: name found after Resource  
  --  5: End found after name
  --  6: delimiter found after End
  --  7: end-of-clause found after delimiter
  --  8: delimiter at end of resource
  --  9: extra stuff after delimiter
  resourceContext             = -1
  resourceDirectiveStart      = ""
  resourceContinuation?       =  0
  nextLineStartsAResource     =  0
  lastLineOfResourceDirective =  0
  
  Return
      
-- Keeping track of the last token's class allows us to determine that leading blanks
-- in a clause are indeed leading blanks, and thus ignorable (because they come after the
-- previous END_OF_CLAUSE, which is either a semicolon or functionally equivalent to a
-- semicolon, and blanks after special characters are ignored). This apparently minor
-- optimization will help to greatly simplify the code in higher levels of syntax.
--
-- This optimization is the reason why, initially, we return a dummy END_OF_CLAUSE,
-- subclass BEGIN_OF_SOURCE.
--
  
::Method getSimpleToken
  Use Local
  Use Strict Arg 
  
  token = getAToken()
  newClass = token[class]
    
  If .ooRexx Then Do
    -- Resource context starts with a new clause
    If resourceContext  == -1, lastClass = END_OF_CLAUSE Then resourceContext =  0
    -- We have a mini-automaton to detect resources
    If resourceContext \== -1 Then Call Check_for_resource
  End
  
  lastClass = newClass
  
Return token                   
   
getLine:
  If line  >= maxLines Then Return 0
  line      = line + 1
  pos       = 1
  thisLine  = source[line]
  moreLines = line < maxLines
  maxPos    = Length(thisLine)+1
  charCat   = Translate(thisLine, categories, characters)
    
Return 1       

nextChar:          pos += 1; Return

thisChar:          Return thisLine[pos]

thisCharIsA:       Return Pos(charCat[pos], Arg(1))  > 0

thisCharIsNotA:    Return Pos(charCat[pos], Arg(1)) == 0

skipCharsUntilNot:
  pos = Verify( charCat, Arg(1), , pos)
  If pos == 0 Then pos = maxPos
Return

getAToken:

  If begin_of_source? Then Do
    begin_of_source? = 0
    Return Token( END_OF_CLAUSE, BEGIN_OF_SOURCE, "", "1 1 1 1" )
  End

  -- Take care of ::Resources first
  If resourceContext >= 7 Then
    Return Take_care_of_final_part_of_Resource_context()

  --
  -- If we are asked for more tokens than we have, return repeatedly END_OF_SOURCE
  -- (this can be practical in certain buffering contexts)
  --
  If pos == 0, \getLine() Then Return Token( END_OF_SOURCE, , "")
  
  -- Return END_OF_LINE as END_OF_CLAUSE, this is useful to create context 
  If pos >= maxPos Then Do
    pos = 0 -- Forces line feed on next
    Return Token( END_OF_CLAUSE, END_OF_LINE, "", line maxPos line maxPos)
  End

  c = thisLine[pos]
  k = charCat[pos]
  
  start = pos
  Call nextChar
    
  Signal (k)
    
--------------------------------------------------------------------------------
-- BLANK                                                                      --
--                                                                            --
-- Skip all characters in the blank category, then return a (probably         --
-- ignorable) BLANK token                                                     --
--------------------------------------------------------------------------------

" ": Call skipCharsUntilNot blank_character
     Return Token( BLANK )

--------------------------------------------------------------------------------
-- VAR_SYMBOL                                                                 --
--                                                                            --
-- Got a letter. This has to be a var_symbol (or maybe a keyword)             --
--------------------------------------------------------------------------------

"l": Call skipCharsUntilNot simple_symbol -- Skip all letters and digits

     -- Neither a letter, a digit or a period? This is a simple symbol
     If thisCharIsNotA( "." )             Then Return Token( VAR_SYMBOL, SIMPLE_VAR )
     
     -- That was a period. Skip it
     Call nextChar
     
     -- End of symbol? This is a stem
     If thisCharIsNotA( var_symbol_char ) Then Return Token( VAR_SYMBOL, STEM_VAR )
     
     -- If there is any stuff after the period, that's a compound symbol
     Call skipCharsUntilNot var_symbol_char
     
     Return Token( VAR_SYMBOL, COMPOUND_VAR )

--------------------------------------------------------------------------------
-- NUMBER (or maybe CONST_SYMBOL)                                             --
--                                                                            --
-- Got a digit. This may be the start of a number (123, 123.45, 123.45E-6) or --
-- the start of a constant symbol.                                            --
--                                                                            --
-- Subclasses are INTEGER (nnnn), FRACTIONAL (nnnn.nnnn) and                  --
-- EXPONENTIAL (nnnn.nnnnE[+|-]nnnn).                                         --
--------------------------------------------------------------------------------     

"d": Call skipCharsUntilNot digit -- Skip all digits (dddd)

     -- Neither a digit, nor a letter, nor a period? This is an integer (dddd)
     If thisCharIsNotA( var_symbol_char ) Then Return Token( NUMBER, INTEGER )
     
     -- Check for an exponent ( ddddE[+|-]ddd )
     If validExponent()                   Then Return Token( NUMBER, EXPONENTIAL )

     -- dddd + letters -> literal constant symbol
     If thisCharIsA( general_letter ) Then Signal LiteralSymbol
       
     -- No letters? This is a period (dddd.)
     Call nextChar
     
     -- Get more possible digits after the period ( dddd.[dddd] )
     Call skipCharsUntilNot digit

     -- Check again for a possible exponent ( dddd.[dddd]E[+|-]ddd )
     If validExponent()                   Then Return Token( NUMBER, EXPONENTIAL )
       
     -- No letter, digit or period? This is a fractional number ( dddd.[dddd] )
     If thisCharIsNotA( var_symbol_char ) Then Return Token( NUMBER, FRACTIONAL ) 
       
     -- Letter, digit or period? A literal constant symbol
LiteralSymbol:     
     Call skipCharsUntilNot var_symbol_char
     Return Token( CONST_SYMBOL, LITERAL_SYMBOL )

--------------------------------------------------------------------------------     
-- If ("e"|"E")["+"|"-"]dddd then advance pointer and return true             --
-- Else this not an exponent, don't move and return false                     --
--------------------------------------------------------------------------------     
validExponent: 
    If Upper( thisChar() ) \== "E" Then Return 0
    saved = pos -- For backtrack
    Call nextChar
    If Pos( thisChar(), "+-") > 0 Then Call nextChar
    If thisCharIsNotA( digit ) Then Signal noValidExponent
    Call skipCharsUntilNot digit
    If thisCharIsNotA( var_symbol_char ) Then Return 1
NoValidExponent:     
    pos = saved
    Return 0    

--------------------------------------------------------------------------------
-- A symbol starting with a dot                                               --
-- May be a fractional number (.nnn), an exponential number (.nnnE[+|-]nnn)   --
-- a simple period, or an environment symbol.                                 --
--------------------------------------------------------------------------------

".": Select Case charCat[pos]
       When general_letter, "." Then Signal environmentSymbol
       When digit Then Do
         Call skipCharsUntilNot digit
         If validExponent() Then Return Token( NUMBER, EXPONENTIAL )
         If thisCharIsA( var_symbol_char ) Then Signal environmentSymbol
         Return Token( NUMBER, FRACTIONAL )
       End
       Otherwise Return Token( CONST_SYMBOL, PERIOD_SYMBOL )
     End
environmentSymbol:     
     Call skipCharsUntilNot var_symbol_char
     Return Token( CONST_SYMBOL, ENVIRONMENT_SYMBOL )

";": Return Token( END_OF_CLAUSE , SEMICOLON,  c  )          
"(": Return Token( LPAREN        , ,  c  )
")": Return Token( RPAREN        , ,  c  )
"[": Return Token( LBRACKET      , ,  c  )
"]": Return Token( RBRACKET      , ,  c  )
":": Return Token( COLON         , ,  c  )
"s": Return Token( SPECIAL       , ,  c  )
"n": Return Token( OPERATOR      , , "\" )           -- Always "\"
"o": If c == "-", .line_comments, thisChar() == "-" Then Do
       pos = maxPos                                  -- Forces END_OF_CLAUSE on next
       Return Token( LINE_COMMENT, )
     End
     Return Token( OPERATOR      , ,  c  )
"x": If .ooRexx Then                                 -- illegal
       Return self~Syntax_error( 13.1, line 1, ". ." line pos, c, c2x(c) )       
     Else                                            -- illegal
       Return self~Syntax_error( 13.1, line 1, ". ." line pos, c2x(c) )       
"/": If thisChar() \== "*" Then Return Token( OPERATOR, , "/" )
     level = 1                                       -- standard_comment
     Call nextChar
     save = line
     saveLine = thisLine
     Loop
       p = Pos("/",charCat,pos)
       If p == 0 Then Do                             -- Multi-line comment
         If \getLine() Then
           Return self~Syntax_error( 6.1, save 1, ". ." save 1, save)
       End
       Else If p > 1, thisLine[p-1] == "*" Then Do
         level -= 1
         pos = p+1
         If level == 0 Then Return Token( CLASSIC_COMMENT, , "/*...*/", save start line pos)
       End
       Else If thisLine[p+1] == "*" Then Do
         level += 1
         pos = p+2
       End
       Else pos = p+1
     End

--
-- Ensures that binary, hexadecimal and Unicode strings are well-formed,
-- that no extraneous characters are found, and that the string ends 
-- in the same line.
--

"'": '"':                      
  q = k
  oldPos = pos
  Loop
    p = Pos(q,charCat,pos)
    If p == 0 Then
      If q = "'" Then Return self~Syntax_error( 6.2, line start, ". ." line maxPos)      
      Else            Return self~Syntax_error( 6.3, line start, ". ." line maxPos)      
    If charCat[p+1] == q Then pos = p+2
    Else Leave
  End
  pos = p + 1
  r = thisLine[pos]~upper
  If  .unicode, Pos(r,"XBPTUY") == 0 Then r = ""
  If \.unicode, Pos(r,"XB")     == 0 Then r = ""
  If r \== "" , (pos+1 == maxPos | Verify(charCat[pos+1], var_symbol_char)) Then Do
    If Pos(r,"PTU") > 0 Then Signal UnicodeString
    If r == "Y" Then Signal BytesString
    inside = Translate(thisLine[start+1,pos-start-2]," ","09"x)  
    -- TODO See what does Regina consider whitespace inside such strings
    if inside[1] == " " Then Do
      If r == "X" Then Return self~Syntax_error( 15.1, line start, ". ." line pos, 1)      
      If r == "B" Then Return self~Syntax_error( 15.2, line start, ". ." line pos, 1)      
    End
    strip = Strip(inside,"T")
    If strip \== inside Then Do
      If r == "X" Then Return self~Syntax_error( 15.1, line start, ". ." line pos, Length(strip)+1 )
      If r == "B" Then Return self~Syntax_error( 15.2, line start, ". ." line pos, Length(strip)+1 )
    End
    Do i = 2 To Words(inside)
      If (Word(inside,i)~length // (2 + 2*(r == "B")) ) \== 0 Then Do
        If r == "X" Then 
          Return self~Syntax_error( .regina~?(15.1,15.5), line start, ". ." line pos, Length( Strip( SubWord(inside, 1, i),"T") ) + 1 )
        Else   
          Return self~Syntax_error( .regina~?(15.2,15.6), line start, ". ." line pos, Length( Strip( SubWord(inside, 1, i),"T") ) + 1 )
      End
    End
    If r == "X", \inside~dataType("X") Then 
      Return self~Syntax_error( 15.3, line start, ". ." line pos, Left( Strip( Translate(inside," ","01234567890ABCDEFabcdef") ), 1 ) )
    If r == "B", \inside~dataType("B") Then 
      Return self~Syntax_error( 15.4, line start, ". ." line pos, Left( Strip( Translate(inside," ","01"                     ) ), 1 ) )
    If r == "B" Then v = X2C(B2X(inside))
    If r == "X" Then v = X2C(inside)
    Call nextChar -- Skip radix
  End  
  Else Do
    v = thisLine[oldPos,pos-oldPos-1]~changeStr(q||q,q)
    r = CHARACTER_STRING
    Signal ReturnString
  End
StringCommon:  
  If r == "" Then r = CHARACTER_STRING
  Else r = suffix2subClass.r
ReturnString:  
  Return Token( STRING, r, v, line start line pos)
 
BytesString: 
  v = thisLine[oldPos,pos-oldPos-1]~changeStr(q||q,q)
  Call nextChar -- Skip radix
  Return Token( STRING, BYTES_STRING, v, line start line pos)  
 
UnicodeString:
  If r == "U" Then Signal UnicodeUString
UnicodePandTStrings:  
  v = thisLine[oldPos,pos-oldPos-1]~changeStr(q||q,q)
  length = Length(v)
  -- See https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf,
  -- table 3-7 on p. 125.
  Do i = 1 To length
    c = v[i]
    Select
      When c < "80"X Then Iterate
      When "C2"X <= c, c <= "DF"X Then Do
        Call Get1CharMore
        Call Check_2_80BF d
      End
      When c == "E0"X Then Do
        Call Get2CharsMore
        Call Check_2_A0BF d -- A0BF
        Call Check_3_80BF e
      End
      When "E1"X <= c, c <= "EC"X Then Do
        Call Get2CharsMore
        Call Check_2_80BF d
        Call Check_3_80BF e
      End
      When c == "E0"X Then Do
        Call Get2CharsMore
        Call Check_2_809F d -- 809F
        Call Check_3_80BF e
      End
      When "EE"X <= c, c <= "EF"X Then Do
        Call Get2CharsMore
        Call Check_2_80BF d
        Call Check_3_80BF e
      End
      When c == "F0"X Then Do
        Call Get3CharsMore
        Call Check_2_90BF d -- 90BF
        Call Check_3_80BF e
        Call Check_4_80BF f
      End
      When "F1"X <= c, c <= "F3"X Then Do
        Call Get3CharsMore
        Call Check_2_80BF d
        Call Check_3_80BF e
        Call Check_4_80BF f
      End
      When c == "F4"X Then Do
        Call Get3CharsMore
        Call Check_2_808F d -- 80..8F
        Call Check_3_80BF e
        Call Check_4_80BF f
      End
      Otherwise Return self~Syntax_error( 22.902, line start, ". ." line pos, c2x(c) )
    End
    Iterate
  End
  -- Do something
  Call nextChar -- Skip radix
Signal StringCommon  

Get1CharMore:
  If i   == length Then Return self~Syntax_error( 22.902, line start, ". ." line pos, c2x(c) )
  i += 1 
  d = v[i]
  Return
  
Get2CharsMore:
  Call Get1CharMore
  If i+1 > length Then Signal 22.902.c.d
  i += 1
  e = v[i]
  Return

Get3CharsMore:
  Call Get2CharsMore
  If i+1 > length Then Signal 22.902.c.d.e
  i += 1
  f = v[i]
  Return
  
Check_2_A0BF:
  If "A0"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
22.902.c.d:
  Return self~Syntax_error( 22.902, line start, ". ." line pos, c2x(c || d) )

Check_2_808F: 
  If "80"X <= Arg(1), Arg(1) <= "8F"X Then Return
  Signal 22.902.c.d

Check_2_809F: 
  If "80"X <= Arg(1), Arg(1) <= "9F"X Then Return 1
  Signal 22.902.c.d

Check_2_80BF: 
  If "80"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Signal 22.902.c.d

Check_3_80BF: 
  If "80"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
22.902.c.d.e:
  Return self~Syntax_error( 22.902, line start, ". ." line pos, c2x(c || d || e) )

Check_4_80BF: 
  If "80"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
22.902.c.d.e.f:  
  Return self~Syntax_error( 22.902, line start, ". ." line pos, c2x(c || d || e || f) )

Check_2_90BF: 
  If "90"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Signal 22.902.c.d

UnicodeUString:
  -- Load Unicode on demand when really needed
  If \UnicodeLoaded Then Do
    Call "Unicode.cls"
    UnicodeLoaded = 1
  End
  -- 22:     Invalid character string
  -- 22.903: Invalid Unicode codepoint "&1".
  contents = thisLine[oldPos,pos-oldPos-1]
  v = ""
  Do While contents \= " "
    contents = Strip(contents)
    If contents[1] == "(" Then Do
      Parse var contents "("name")"extra
      If extra == "" Then If \contents~endsWith(")") Then 
        Return self~Syntax_error( 22.903, line start, ". ." line pos, contents )
      contents = Strip(extra)
      code = N2P(name)
      If code = "" Then Return self~Syntax_error( 22.903, line start, ". ." line pos, name )
      v ||= UTF8(code)
      Iterate
    End
    Parse Var contents word contents
    If Upper(word) == "U+"                            Then Signal 22.903.word
    If Upper(Left(word,2)) == "U+" Then word = SubStr(word,3)
    If \DataType(word,"X")                            Then Signal 22.903.word
    If X2D(word) > X2D(10FFFF)                        Then Signal 22.903.word
    If X2D(word) >= X2D(D800), X2D(word) <= X2D(DFFF) Then Signal 22.903.word
    v ||= UTF8(word)
  End
  Call nextChar -- Skip radix
Signal StringCommon    

22.903.word: 
  Return self~Syntax_error( 22.903, line start, ". ." line pos, word )
 
UTF8: Procedure -- Internal, fast
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

--------------------------------------------------------------------------------
-- Handling of ::RESOURCE directives in simple tokenizing                     --
--------------------------------------------------------------------------------

Check_for_resource:
  If resourceContext < 1 Then resourceDelimiter = "::END"
  
  -- After a continuation char, we have ...
  If resourceContinuation? Then Do
    -- ...either an END_OF_CLAUSE, and then we ignore both, or...
    If newClass == END_OF_CLAUSE, token[subClass] == END_OF_LINE Then
      resourceContinuation? = 0
    -- ...something else, and then we are out of our ::Resource context
    Else resourceContext = -1
    Return
  End
  
  If Pos(newClass,BLANK||CLASSIC_COMMENT||LINE_COMMENT) > 0 Then Return
  
  -- Found a continuation char?
  If \resourceContinuation?,,
     Pos(newClass,OPERATOR||SPECIAL) > 0,,
     Pos(token[value],",-") > 0 Then Do
     -- Yes? Take note, and wait for an END_OF_LINE
     resourceContinuation? = 1
     Return
  End
  Select Case resourceContext
    When 0 Then
      If newClass == COLON Then Do
                                resourceContext =  1
                                resourceDirectiveStart = token[location]
      End
      Else                      resourceContext = -1
    When 1 Then
      If newClass == COLON Then resourceContext =  2
      Else                      resourceContext = -1
    When 2 Then
      If newClass == VAR_SYMBOL, Upper( token[value] ) == "RESOURCE" Then 
                                resourceContext =  3
      Else                      resourceContext = -1
    When 3 Then
      If ThisTokenIsA(token,STRING_OR_SYMBOL) Then Do
                                resourceContext =  4
                                resourceName    = token[value]
      End
      Else                      resourceContext = -1
    When 4 Then
      If newClass == END_OF_CLAUSE Then Do 
                                nextLineStartsAResource = 1
                                resourceDirectiveEnd = token[location]
                                lastLineOfResourceDirective = Word(token[location],1)
                                resourceContext =  7
      End
      Else If newClass = VAR_SYMBOL, Upper( token[value] ) == "END" Then 
                                resourceContext =  5
      Else                      resourceContext = -1
    When 5 Then          
      If ThisTokenIsA(token,STRING_OR_SYMBOL) Then Do
        resourceDelimiter = token[value]
        If newClass \== STRING Then 
          resourceDelimiter = Upper( resourceDelimiter )
                                resourceContext =  6
        End
      Else                      resourceContext = -1
    When 6 Then      
      If newClass == END_OF_CLAUSE Then Do
                                nextLineStartsAResource = 1
                                resourceDirectiveEnd = token[location]
                                lastLineOfResourceDirective = Word(token[location],1)
                                resourceContext =  7
      End
      Else Return self~Syntax_error( 21.914, resourceDirectiveStart, token[location], token[value] )     
    When 7, 8, 9, 10 Then Nop -- Handled elsewhere
  End
Return

Take_care_of_final_part_of_Resource_context:
  If resourceContext == 7 Then Do    
    If line == lastLineOfResourceDirective Then Do
      -- END_OF_LINE
      If pos == 0 Then Do
        If \getLine() Then Signal Missing_resource_end_marker
      End
      -- Not END_OF_LINE: return as ignorable
      Else Do
        savePos = pos
        pos = 0 -- Force line feed on next token
        Return Token( RESOURCE_IGNORED, , SubStr(thisLine,savePos), line savePos line maxPos )
      End
    End
    start = 1
    startLine = line
    Do While line <= maxLines
      If source[line]~startsWith(resourceDelimiter) Then Do
        resourceContext = 8
        Return Token( RESOURCE, , "[RESOURCE]", startLine 1 line 1 )        
      End
      If \getLine() Then Signal Missing_resource_end_marker
    End
    Signal Missing_resource_end_marker
  End
  If resourceContext == 8 Then Do
    pos = Length(resourceDelimiter) + 1
    resourceContext = 9
    Return Token( RESOURCE_DELIMITER, , resourceDelimiter, line 1 line pos)
  End
  If resourceContext == 9 Then Do
    savePos = pos
    --pos = 0 -- Force line feed on next token
    resourceContext = 10
    Return Token( RESOURCE_IGNORED, , SubStr(thisLine, savePos), line savePos line maxPos )
  End
  If resourceContext == 10 Then Do
    retPos = maxPos
    pos = 0 -- Force line feed on next token
    resourceContext = -1
    Return Token( END_OF_CLAUSE, INSERTED_SEMICOLON, "", line retPos line retPos )
  End

Missing_resource_end_marker:  
  Return self~Syntax_error( 99.943, resourceDirectiveStart, resourceDirectiveEnd, resourceDelimiter, resourceName )
 
Token: Procedure Expose thisLine line start pos
  t. = .Stem~new
  Use Arg ,
    t.class,, 
    t.subclass = ( t.class ),,
    t.value    = ( SubStr(thisLine,start,pos-start) ),,
    t.location = ( (t.value=="")~?(line start line start,line start line pos) )
  Return t.

-- Return the "true" location of a Token:
--
-- * If the token has absorbed others --> the location of its clone
-- * Else its own location
--

::Routine TrueLocation Private
  Use Strict Arg token.
  If token.~hasIndex(cloneIndex) Then Return token.[absorbed][token.[cloneIndex]][location]
  Else                                Return token.location
  
::Routine ThisTokenIsA Private
  Use Strict Arg token.,classes
  Return Pos(token.class,classes) > 0

::Routine errorMessage Private -- Public
-- List of error messages, with substitutions
--
-- When the messages for ooRexx and Regina are new or different, there is
-- an extra compound variable starting with "Regina.". The same is
-- true for the "Unicode" variants of the classes.
  Parse arg major"."minor
  
  errMsg.3       = "Failure during initialization."
  errMsg.3.1     = "Failure during initialization: Program was not found."
  errMsg.3.901   = "Failure during initialization: Program ""&1"" was not found."
  errMsg.6       = "Unmatched ""/*"" or quote."
  errMsg.6.1     = "Unmatched comment delimiter (""/*"") on line &1."
  Regina.6.1     = "Unmatched comment delimiter (""/*"")."
  errMsg.6.2     = "Unmatched single quote (')."
  errMsg.6.3     = "Unmatched double quote ("")."
  errMsg.13      = "Invalid character in program."
  errMsg.13.1    = "Incorrect character in program ""&1"" ('&2'X)."  
  Regina.13.1    = "Invalid character in program ""('&1'X)""."     
  errMsg.15      = "Invalid hexadecimal or binary string."
  Unicode.15     = "Invalid Unicode, hexadecimal or binary string."
  errMsg.15.1    = "Incorrect location of whitespace character in position &1 in hexadecimal string."
  Regina.15.1    = "Invalid location of blank in position &1 in hexadecimal string"
  errMsg.15.2    = "Incorrect location of whitespace character in position &1 in binary string."
  Regina.15.2    = "Invalid location of blank in position &1 in binary string."
  errMsg.15.3    = "Only 0-9, a-f, A-F, and whitespace characters are valid in a hexadecimal string; found ""&1""."
  Regina.15.3    = "Only 0-9, a-f, A-F, and blank are valid in a hexadecimal string; found ""&1""."
  errMsg.15.4    = "Only 0, 1, and whitespace characters are valid in a binary string; found ""&1""." 
  Regina.15.4    = "Only 0, 1, and blank are valid in a binary string; found ""&1""." 
  errMsg.15.5    = "Hexadecimal strings must be grouped in units that are multiples of two characters."
  errMsg.15.6    = "Binary strings must be grouped in units that are multiples of four characters."
  errMsg.19      = "String or symbol expected."
  errMsg.19.909  = "String or symbol expected after tilde (~)."
  errMsg.20      = "Symbol expected."
  errMsg.20.916  = "Symbol expected after ::."
  errMsg.21      = "Invalid data on end of clause."
  errMsg.21.901  = "Data must not follow the NOP keyword; found ""&1""."
  errMsg.21.914  = "Data must not follow the ::RESOURCE directive; found ""&1""."
  errMsg.22      = "Invalid character string."
  Unicode.22.902 = "Invalid UTF-8 sequence ""&1""X."
  Unicode.22.903 = "Invalid Unicode codepoint ""&1""."
  Unicode.22.904 = "Invalid Unicode name ""&1""."
  errMsg.25      = "Invalid subkeyword found."
  errMsg.25.12   = "PARSE must be followed by one of the keywords ARG, LINEIN, PULL, SOURCE, VALUE, VAR, or VERSION; found ""&1""."
  errMsg.31      = "Name starts with number or "".""."
  errMsg.31.2    = "Variable symbol must not start with a number; found ""&1""."
  errMsg.31.3    = "Variable symbol must not start with a "".""; found ""&1""."
  errMsg.35      = "Invalid expression."
  errMsg.35.1    = "Incorrect expression detected at ""&1""."
  errMsg.36      = "Unmatched ""("" or ""["" in expression."
  Regina.36      = "Unmatched ""("" in expression."
  errMsg.36.1    = "Unmatched ""("" in expression."
  errMsg.36.901  = "Left parenthesis ""("" in position &1 on line &2 requires a corresponding right parenthesis "")""."
  errMsg.36.902  = "Square bracket ""["" in position &1 on line &2 requires a corresponding right square bracket ""]""."
  errMsg.37      = "Unexpected "","", "")"", or ""]""."
  Regina.37      = "Unexpected "","" or "")""."
  errMsg.37.1    = "Unexpected "",""."
  errMsg.37.2    = "Unmatched "")"" in expression."
  errMsg.37.901  = "Unexpected ""]""."
  errMsg.99      = "Translation error."
  errMsg.99.916  = "Unrecognized directive instruction."
  errMsg.99.943  = "Missing ::RESOURCE end marker ""&1"" for resource ""&2""."
  
  If .regina,  Var("Regina.major.minor")  Then minorErrMsg = Regina.major.minor
                                          Else minorErrMsg = errMsg.major.minor
  If .Unicode, Var("Unicode.major.minor") Then minorErrMsg = Unicode.major.minor
                                          Else minorErrMsg = errMsg.major.minor
  If .regina,  Var("Regina.major")        Then majorErrMsg = Regina.major
                                          Else majorErrMsg = errMsg.major
  If .Unicode, Var("Unicode.major")       Then majorErrMsg = Unicode.major
                                          Else majorErrMsg = errMsg.major
  Do counter c arg over Arg(2)
    minorErrmsg = minorErrMsg~changeStr("&"c,arg)
  End
  If .Regina Then Do
    If minorErrMsg~endsWith(".") Then minorErrMsg = Left(minorErrMsg, Length(minorErrMsg) - 1)
    If majorErrMsg~endsWith(".") Then majorErrMsg = Left(majorErrMsg, Length(majorErrMsg) - 1)
  End
Return majorErrMsg, minorErrMsg
