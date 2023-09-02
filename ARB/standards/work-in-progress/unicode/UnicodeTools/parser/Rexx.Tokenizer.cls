/**
 *                                                                           
 *  <h2><code>Rexx.Tokenizer.cls</code></h2>
 *                        
 *<pre><code>   This file is part of <a href="https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools">the Unicode Tools Of Rexx</a> (TUTOR). 
 *   See <a href="https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/">https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/</a> for more information.
 *   Copyright &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;.
 *   License: Apache License 2.0 (<a href="https://www.apache.org/licenses/LICENSE-2.0">https://www.apache.org/licenses/LICENSE-2.0</a>).</code></pre>
 *                                                                           
 *  <p>
 *    This classfile includes a set of ooRexx classes. The main class is     
 *    <code>Rexx.Tokenizer</code>; it implements both a basic and a full Rexx tokenizer. The <code>getSimpleToken</code>
 *    method returns basic Rexx tokens and non-tokens, while the <code>getFullToken</code>
 *    method returns full tokens, after discarding null clauses, ignorable blanks and comments.
 *    When requesting full tokens, an optional mechanism allows access to the ignored simple tokens. 
 *    The tokenizer supports all the syntactical constructs of Open Object Rexx (ooRexx), Regina Rexx and
 *    ANSI Rexx. You can select the desired syntax subset at instance creation time by selecting the
 *    appropriate class (see below). The tokenizer supports classic comments (including nested comments), 
 *    line comments, strings and ::resources are handled. If a Unicode class is used (see below), 
 *    Y-, P-, T- and U-suffixed strings are implemented.
 *
 *  <p>
 *    The full tokenizer is not a full parser, but it returns useful semantical information, like the
 *    instruction or directive types.
 *                                                                           
 *  <p>
 *    The exact syntax accepted by the tokenizer depends on the subclass used to instantiate the
 *    tokenizer. Subclasses starting with <code>"Regina"</code> accept the Regina Rexx syntax;         
 *    subclasses starting with <code>"ANSI.Rexx"</code> accept only the ANSI Rexx syntax    
 *    (for example, comments starting with <code>"--"</code> are accepted by Regina but     
 *    not by ANSI); subclasses starting with <code>"ooRexx"</code> accept ooRexx syntax;    
 *    for example, <code>"["</code>, <code>"]"</code> and <code>"~"</code> are valid characters 
 *    for ooRexx subclasses but not for Regina or ANSI subclasses.                                   
 *                                                                           
 *  <p>
 *    Classes with "Unicode" in their name accept four new, experimental, types of string:                                                         
 *
 *<pre><code>
 *    <b>"string"Y</b>,  Bytes strings (i.e., Classic Rexx strings)                  
 *    <b>"string"P</b>,  Codepoints strings (checked for UTF8 correctness at parse time)                                                 
 *    <b>"string"T</b>,  Text strings (checked for UTF8 correctness at parse time)   
 *    <b>"string"U</b>,  Unicode codepoint strings. Codepoints can be specified using hexadecimal notation (61, 0061, 0000), or as a name,  
 *                alias or label enclosed in parenthesis ("(cr)","(CR) (LF)", "(Woman) (zwj) (Man)"). Codepoints, names, alias and labels 
 *                are checked for correctness at parse time.                  
 *</code></pre>
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
 *  </table>
 *                                                                           
 */

/**
 * <h3>The <code>ooRexx.Tokenizer</code> class</h3>
 *
 * <p>
 *   Instances of this class implement a ooRexx tokenizer.
 */

::Class ooRexx.Tokenizer            Subclass Rexx.Tokenizer      Public

/**
 * <h3>The <code>ooRexx.Unicode.Tokenizer</code> class</h3>
 *
 * <p>
 *   Instances of this class implement a ooRexx tokenizer with Unicode extensions.
 */
 
::Class ooRexx.Unicode.Tokenizer    Subclass ooRexx.Tokenizer    Public

/**
 * <h3>The <code>Regina.Tokenizer</code> class</h3>
 *
 * <p>
 *   Instances of this class implement a Regina Rexx tokenizer.
 */

::Class Regina.Tokenizer            Subclass Rexx.Tokenizer      Public

/**
 * <h3>The <code>Regina.Unicode.Tokenizer</code> class</h3>
 *
 * <p>
 *   Instances of this class implement a Regina Rexx tokenizer with Unicode
 *   extensions.
 */

::Class Regina.Unicode.Tokenizer    Subclass Regina.Tokenizer    Public

/**
 * <h3>The <code>ANSI.Rexx.Tokenizer</code> class</h3>
 *
 * <p>
 *   Instances of this class implement a ANSI Rexx tokenizer.
 */

::Class ANSI.Rexx.Tokenizer         Subclass Rexx.Tokenizer      Public

/**
 * <h3>The <code>ANSI.Rexx.Unicode.Tokenizer</code> class</h3>
 *
 * <p>
 *   Instances of this class implement a ANSI Rexx tokenizer with Unicode extenstions.
 */

::Class ANSI.Rexx.Unicode.Tokenizer Subclass ANSI.Rexx.Tokenizer Public

/**
 * <h3>The <code>Rexx.Tokenizer</code> class</h3>
 *
 * <p>
 *   This is the main Rexx Tokenizer class.
 */

::Class Rexx.Tokenizer                                           Public

/**
 * <h4>The <code>init</code> method</h4>
 *
 * @param <code>source</code> An array of strings containing the source of the program
 *   we want to tokenize.
 * @param <code>detailed = 1</code> An optional boolean. It has no effect for simple tokenizing.
 *   For full tokenizing, it determines whether full tokens will keep the collection of absorbed
 *   (ignored) simple tokens as an array as <code>token[absorbed]</code>.
 *
 */

::Method init
  Use local pkglocal
  Use Strict Arg source, detailed = 0
  line      = 0
  pos       = 0
  maxLines  = source~items
  moreLines = line < maxLines
  
  pkgLocal = .context~package~local
  pkgLocal~ooRexx  = 0
  pkgLocal~Regina  = 0
  pkgLocal~ANSI    = 0
  pkgLocal~Unicode = 0
  
  If self~isA(.ooRexx.Tokenizer)    Then pkgLocal~ooRexx  = 1
  If self~isA(.Regina.Tokenizer)    Then pkgLocal~Regina  = 1
  If self~isA(.ANSI.Rexx.Tokenizer) Then pkgLocal~ANSI    = 1
  If self~class~id~upper~contains(".UNICODE.") 
                                    Then pkgLocal~Unicode = 1
                                    
  pkgLocal~line_comments = \ ( .ANSI )
  
  self~InitializeCharacterCategories
  self~InitializeClasses
  self~InitializeKeywordInstructions
  self~InitializeDirectives
  self~InitializeActionPairs
  self~InitializeOperatorTable
  self~InitializeTokenizer
  self~InitializeSimpleTokenizer
  
  UnicodeLoaded = 0
    
/**
 *
 * <h4>The <code>tokenClasses</code> constant</h4>
 *
 * <p>
 *   The <code>tokenConstants</code> is indeed a vector of constants. The suggested way to use it is to
 *   use code similar to the following.
 *
 *<code><pre>
 *  Do tc over tokenizer~tokenClasses
 *   Call Value tc[1], tc[2]
 *  End
 *</pre></code>
 *
 */

::Constant tokenClasses (    -            -- <pre><code>
  ( SYNTAX_ERROR                   , "E" ), -
  ( OPERATOR                       , "o" ), -
                                            -  -- +--- All subclasses of OPERATOR are full tokenizer only
    ( ADDITIVE_OPERATOR            , "a" ), -  -- | "+", "-" 
    ( COMPARISON_OPERATOR          , "c" ), -  -- | "=", "\=", ">", "<", "><", "<>", ">=", "\<", "<=", "\>" 
                                            -  -- | "==", "\==", ">>", "<<", ">>=", "\<<", "<<=", "\>>"
    ( CONCATENATION_OPERATOR       , "k" ), -  -- | "||" 
    ( LOGICAL_OPERATOR             , "l" ), -  -- | "&", "|", "&&" 
    ( MESSAGE_OPERATOR             , "s" ), -  -- | "~", "~~" 
    ( MULTIPLICATIVE_OPERATOR      , "m" ), -  -- | "*", "/", "//", "%" 
    ( POWER_OPERATOR               , "p" ), -  -- | "**" 
    ( EXTENDED_ASSIGNMENT          , "x" ), -  -- | "+=", "-=", "*=", "/=", "%=", "//=", "||=", "&=", "|=", "&&=", "**=" 
                                            -  -- +--- All subclasses of OPERATOR are full tokenizer only
  ( SPECIAL                        , "s" ), -
  ( COLON                          , ":" ), -
  ( DIRECTIVE_START                , "*" ), -  -- "::" (Full tokenizer only, absorbed by directive)
  ( LPAREN                         , "(" ), -
  ( RPAREN                         , ")" ), -
  ( LBRACKET                       , "[" ), -
  ( RBRACKET                       , "]" ), -
  ( BLANK                          , "b" ), -  -- May be ignorable, or not
  ( LINE_COMMENT                   , "l" ), -  -- Up to but not including the end of line
  ( CLASSIC_COMMENT                , "c" ), -  -- Infinite nesting allowed
  ( RESOURCE                       , "R" ), -  -- The resource itself, i.e., the array of lines
  ( RESOURCE_DELIMITER             , "T" ), -  -- End delimiter, ends resource
  ( RESOURCE_IGNORED               , "G" ), -  -- After "::Resource name ;" or "::END delimiter"
  ( END_OF_SOURCE                  , "F" ), -
  ( END_OF_CLAUSE                  , ";" ), -
    ( BEGIN_OF_SOURCE              , "B" ), -  -- Dummy and inserted. Very convenient for simplification.
    ( END_OF_LINE                  , "L" ), -  -- Implied semicolon
    ( SEMICOLON                    , ";" ), -  -- An explicit semicolon
    ( INSERTED_SEMICOLON           , "I" ), -  -- For example, after a label, THEN, ELSE, and OTHERWISE.
                                            -
                                            -  -- CLAUSE SUPPORT (Full tokenizer only)
                                            -  -- ==============
  ( LABEL                          , "W" ), -  -- Includes the COLON
                                            -  -- All DIRECTIVEs include the :: marker
  ( DIRECTIVE                      , "w" ), -  -- 
    ( ANNOTATE_DIRECTIVE           , "1" ), -  -- 
    ( ATTRIBUTE_DIRECTIVE          , "2" ), -  -- 
    ( CLASS_DIRECTIVE              , "3" ), -  -- 
    ( CONSTANT_DIRECTIVE           , "4" ), -  -- 
    ( METHOD_DIRECTIVE             , "5" ), -  -- 
    ( OPTIONS_DIRECTIVE            , "6" ), -  -- 
    ( REQUIRES_DIRECTIVE           , "7" ), -  -- 
    ( RESOURCE_DIRECTIVE           , "8" ), -  -- 
    ( ROUTINE_DIRECTIVE            , "9" ), -  -- 
                                            -  --
  ( KEYWORD_INSTRUCTION            , "K" ), -  -- All KEYWORD_INSTRUCTIONs include the first blank after the keyword, if present 
    (ADDRESS_INSTRUCTION           , "a" ), -  --     
    (ARG_INSTRUCTION               , "b" ), -  -- 
    (CALL_INSTRUCTION              , "c" ), -  -- 
    (CALL_ON_INSTRUCTION           , "K" ), -  -- Includes CALL ON
    (CALL_OFF_INSTRUCTION          , "L" ), -  -- Includes CALL OFF
    (DO_INSTRUCTION                , "d" ), -  -- 
    (DROP_INSTRUCTION              , "e" ), -  -- 
    (ELSE_INSTRUCTION              , "f" ), -  -- Inserts a ";" after
    (END_INSTRUCTION               , "g" ), -  -- 
    (EXIT_INSTRUCTION              , "h" ), -  -- 
    (EXPOSE_INSTRUCTION            , "i" ), -  -- 
    (FORWARD_INSTRUCTION           , "j" ), -  -- 
    (GUARD_INSTRUCTION             , "k" ), -  -- 
    (IF_INSTRUCTION                , "l" ), -  -- 
    (INTERPRET_INSTRUCTION         , "m" ), -  -- 
    (ITERATE_INSTRUCTION           , "n" ), -  -- 
    (LEAVE_INSTRUCTION             , "o" ), -  -- 
    (LOOP_INSTRUCTION              , "p" ), -  -- 
    (NOP_INSTRUCTION               , "q" ), -  -- 
    (NUMERIC_INSTRUCTION           , "r" ), -  -- 
    (OPTIONS_INSTRUCTION           , "s" ), -  -- 
    (OTHERWISE_INSTRUCTION         , "t" ), -  -- Inserts a ";" after
    (PARSE_INSTRUCTION             , "u" ), -  -- Includes UPPER, LOWER and CASELESS (as attributes too)
    (PROCEDURE_INSTRUCTION         , "v" ), -  -- 
    (PUSH_INSTRUCTION              , "w" ), -  -- 
    (PULL_INSTRUCTION              , "x" ), -  -- 
    (QUEUE_INSTRUCTION             , "y" ), -  -- 
    (RAISE_INSTRUCTION             , "z" ), -  -- 
    (REPLY_INSTRUCTION             , "A" ), -  -- 
    (RETURN_INSTRUCTION            , "B" ), -  -- 
    (SAY_INSTRUCTION               , "C" ), -  -- 
    (SELECT_INSTRUCTION            , "D" ), -  -- 
    (SIGNAL_INSTRUCTION            , "E" ), -  -- 
    (SIGNAL_ON_INSTRUCTION         , "M" ), -  -- Includes SIGNAL ON
    (SIGNAL_OFF_INSTRUCTION        , "N" ), -  -- Includes SIGNAL OFF
    (THEN_INSTRUCTION              , "F" ), -  -- Inserts a ";" before and after
    (TRACE_INSTRUCTION             , "G" ), -  -- 
    (UPPER_INSTRUCTION             , "H" ), -  -- 
    (USE_INSTRUCTION               , "I" ), -  -- 
    (WHEN_INSTRUCTION              , "J" ), -  -- 
  ( ASSIGNMENT_INSTRUCTION         , "O" ), -  --         
  ( COMMAND_OR_MESSAGE_INSTRUCTION , "P" ), -  --     
                                            -  -- End of CLAUSE SUPPORT
                                            -  -- =====================
  ( VAR_SYMBOL                     , "V" ), -  
    ( SIMPLE                       , "1" ), -  
    ( STEM                         , "2" ), -
    ( COMPOUND                     , "3" ), -
  ( NUMBER                         , "N" ), -
    ( INTEGER                      , "4" ), -
    ( FRACTIONAL                   , "5" ), -
    ( EXPONENTIAL                  , "6" ), -
  ( CONST_SYMBOL                   , "C" ), -
    ( PERIOD                       , "7" ), -
    ( LITERAL                      , "8" ), -
    ( ENVIRONMENT                  , "9" ), -
  ( STRING                         , "S" ), -
    ( BINARY                       , "B" ), -
    ( HEXADECIMAL                  , "X" ), -
    ( CHARACTER                    , "C" ), -  
    ( BYTES                        , "Y" ), -  -- Unicode only. Y suffix
    ( CODEPOINTS                   , "P" ), -  -- Unicode only. P suffix
    ( TEXT                         , "T" ), -  -- Unicode only. T suffix
    ( UNOTATION                    , "U" )  -  -- Unicode only. U suffix</code></pre>
)

/**
 *
 * <h4>The <code>InitializeClasses</code> private method</h4>
 *
 * <p>
 *   This method scans the <code>tokenClasses</code> vector and assigns the values
 *   of the corresponding constants. It also creates some useful compound values,
 *   like <code>STRING_OR_SYMBOL</code> or <code>CLAUSE</code>.
 *
 */

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

/**
 *
 * <h4>The <code>InitializeKeywordInstructions</code> private method</h4>
 *
 * <p>
 *   The <code>InitializeKeywordInstructions</code> method creates the
 *   <code>keywordInstruction.</code> stem, which allows us to determine whether a certain
 *   <code>SIMPLE VAR_SYMBOL</code> is a candidate to start a <code>KEYWORD_INSTRUCTION</code>
 *   or not. The stem is customized for the ooRexx, Regina and ANSI cases.
 *
 */

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

/**
 *
 * <h4>The <code>InitializeDirectives</code> private method</h4>
 *
 * <p>
 *   This method creates a stem that will be used to discriminate if a symbol is a valid
 *   directive name or not.
 *
 */

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

/**
 *
 * <h4>The <code>InitializeActionPairs</code> private method</h4>
 *
 * <p>
 *   <code>InitializeActionPairs</code> implements the <code>Action.</code> stem, which is 
 *   the core of the finite state automaton implementing the full tokenizing phase. Simple tokens
 *   are examined in a window of two consecutive tokens, and a series of actions is activated by
 *   examining the classes of these tokens. For example, a <code>BLANK</code> adjacent to a <code>COLON</code>
 *   can always be ignored ("absorbed"), and so on. 
 *
 */

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

/**
 *
 * <h4>The <code>InitializeOperatorTable</code> private method</h4>
 *
 * <p>
 *   The <code>InitializeOperatorTable</code> method creates the <code>operator_subclass.</code>
 *   stem. This stem allows us to discriminate which operator character combinations constitute
 *   valid Rexx operators, and which is the syntactic category (<code>ADDITIVE_OPERATOR</code>,
 *   <code>LOGICAL_OPERATOR</code>, etc., that should be assigned to those operators.
 *
 */

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

/**
 *
 * <h4>The <code>InitializeTokenizer</code> private method</h4>
 *
 * <p>
 *   The <code>InitializeTokenizer</code> method sets a number of variables to track the special context
 *   for THEN clauses, the special token supplied at begin-of-source, and the extra buffer used when
 *   we are forced, in the full tokenizer, to insert certain symbols, for example, a semicolon after
 *   a label, or a THEN, ELSE or OTHERWISE clause.
 *
 */

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

/**
 *
 * <h4>The <code>Syntax_Error</code> method</h4>
 *
 *<code><pre>
 * Syntax_Error(major"."minor, startLocation, endLocation, subst_1, ..., subst_n)
 *</pre></code>
 *
 * <p>
 *   The <code>Syntax_Error</code> method returns a special type of token that includes extra information
 *   to identify a syntax error. The arguments to <code>Syntax_Error</code> are:
 *
 * <ul>
 *   <li>The <code>errorNumber</code>, in the format <code>major.minor</code>.
 *   <li>The <code>startLocation</code> and the <code>endLocation</code>. Their format is
 *     <code>startLine startCol endLine endCol</code>. The location of the error token will be the
 *     start position of the start location followed by the end position of the end location.
 *   <li>The following arguments are the substitution instances for the secondary error message.
 * </ul>
 *
 * <p>
 *   The tokenizer uses the <code>Syntax_Error</code> method to return special tokens when a syntax
 *   error is encountered. Both the <code>class</code> and the <code>subclass</code> components
 *   of the returned stem are <code>SYNTAX_ERROR</code>. Other components of the returned stem 
 *   <code>token.</code> are:
 *
 * <ul>
 *   <li><code>value</code> is the main error message. Same as <code>message</code>
 *   <li><code>message</code> is the main error message. Same as <code>value</code>
 *   <li><code>number</code> is the error number, in the <code>major.minor</code> format, as
 *     specified in the first argument to <code>Syntax_Error</code>.
 *   <li><code>secondaryMessage</code> is the secondary error message, with all substitutions applied.
 *   <li><code>line</code> is the line number where the error occurred.
 * </ul>
 *
 */

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

/**
 *
 * <h3>The <code>getFullToken</code> method</h3> 
 *
 * <p>
 *   The <code>getFullToken</code> method selects the next "full" token in the input file and
 *   returns a stem containing the details that describe this token.
 *
 * <p>
 *   "Full" tokens build over "simple" tokens, by applying Rexx rules and ignoring certain
 *   elements:
 *
 * <ul>
 *   <li>Classic comments and line comments are ignored.
 *   <li>Blanks adjacent to special characters are ignored, except when they can be interpreted
 *     as a concatenation operator.
 *   <li>Two consecutive end of clause markers (i.e., an explicit semicolon, or an end of line)
 *     are reduced to a single end of clause marker (the second one would constitute an ignorable
 *     null clause).
 *   <li>Blanks at the beginning of a clause are ignored.
 * </ul>
 *
 * <p>
 *   The ignoring process is not a simple discarding. On the one hand, the location of each full
 *   token is adjusted, so that the original source can always be reconstructed by examining the locations
 *   of the returned tokens. On the other hand, if the <code>detailed</code> parameter is specified
 *   as <b>1</b> when creating the tokenizer instance, all the ignored tokens, including the original
 *   non-ignored token, can be accessed as an array which is the value of <code>token[absorbed]</code>.
 *
 * <p><b>Examples:</b> Assume a program consisting of a single line, <code>i = i + 1</code>. The
 *   simple tokenizer would return 11 tokens. The first one is a convenience begin-of-source token,
 *   and the rest are "i"; a blank; the assignment operator, "="; another blank; "i" again; a blank more; 
 *   the "+" operator; one blank more; the "1" numeric constant, and an implied semicolon created by
 *   the end-of-line condition (format is <code>token-number [location]: 'value' (class subclass)</code>).
 *
 *<pre><code>   1 [1 1 1 1]: '' (; B)
 *   2 [1 1 1 2]: 'i' (V 1)
 *   3 [1 2 1 3]: ' ' (b b)
 *   4 [1 3 1 4]: '=' (o o)
 *   5 [1 4 1 5]: ' ' (b b)
 *   6 [1 5 1 6]: 'i' (V 1)
 *   7 [1 6 1 7]: ' ' (b b)
 *   8 [1 7 1 8]: '+' (o o)
 *   9 [1 8 1 9]: ' ' (b b)
 *  10 [1 9 1 10]: '1' (N 4)
 *  11 [1 10 1 10]: '' (; L)
 *</code></pre>
 *
 * <p>
 *   The full tokenizer would return only 7 tokens. Inspection of the <code>location</code> information
 *   shows that the "=" operator has absorbed two blanks, and the same is true of the "+" operator.
 *   One can also appreciate that the class and subclass of the first "i" symbol has changed from "V 1",
 *   VAR_SYMBOL SIMPLE, to "O 1", ASSIGNMENT_INSTRUCTION (to a) SIMPLE variable.
 *
 *<pre><code>   1 [1 1 1 1]: '' (; B)
 *   2 [1 1 1 2]: 'i' (O 1)
 *   3 [1 2 1 5]: '=' (o o)
 *   4 [1 5 1 6]: 'i' (V 1)
 *   5 [1 6 1 9]: '+' (o o)
 *   6 [1 9 1 10]: '1' (N 4)
 *   7 [1 10 5 1]: '' (; L)
 *</code></pre>
 *
 * <p>
 *   A full, detailed, tokenizing allows us to appreciate the absortion process by which the
 *   simpler tokens are ignored, but not discarded:
 *
 *<pre><code>   1[1 1 1 1]: '' (; B)
 *   2[1 1 1 2]: 'i' (O 1)
 *   3[1 2 1 5]: '=' (o o)
 *       ---> Absorbed:
 *       1[1 2 1 3] (b b): ' '
 *       2[1 3 1 4] (o o): '=' <==
 *       3[1 4 1 5] (b b): ' '
 *   4[1 5 1 6]: 'i' (V 1)
 *   5[1 6 1 9]: '+' (o o)
 *       ---> Absorbed:
 *       1[1 6 1 7] (b b): ' '
 *       2[1 7 1 8] (o o): '+' <==
 *       3[1 8 1 9] (b b): ' '
 *   6[1 9 1 10]: '1' (N 4)
 *   7[1 10 5 1]: '' (; L)
 *</code></pre>
 *
 * <p>
 *   Sequences of special characters are collected to see if they form a multi-character operator,
 *   line "\==", an extended assignment token, like "+=", or a directive-start marker, like "::".
 *
 * <h4>Format of the returned values (undetailed full tokenizing)</h4>
 *
 * <p>
 *   When calling <code>getFullToken</code> in undetailed mode, each of the returned 
 *   tokens <code>t.</code> is a stem with the following components:
 *
 * <ul>
 *   <li><code>t.class</code>, selected between the <em>non-indented</em> elements of the <code>tokenClasses</code>
 *     constant.
 *   <li><code>t.subclass</code>, selected between the <em>indented</em> elements of the <code>tokenClasses</code>
 *     constant above (when there is no indented element, <code>t.class == t.subclass</code>). 
 *   <li><code>t.value</code>. In general, this is the character representation of the token itself,
 *     but in some cases it can differ. For example, in the case of strings, this is the string value,
 *     independently of whether its specification has used or not internal double quotes, or it is any of the
 *     "X"-, "B"- or "U"- suffixed strings. That is, in the ASCII encoding, <code>t.value</code> 
 *     is identical when the token was <code>"a"</code>, <code>"61"X</code> or <code>"0110 0001"B</code>.
 *     <code>T.value</code> can also be the compound operator, like "\==", an extended assignment symbol, like "+=", 
 *     or a directive delimiter, when appropriate. 
 *   <li><code>t.location</code>. This component has the form <code>line1 start line2 pos</code> and identifies the
 *     start position of the token, and the end position, plus one character. Please note that <code>t.location</code>
 *     includes the location of all the tokens that have been ignored, so that the returned stream has continuity.
 *     For example, tokenizing <code>"i = i + 1"</code> will return five tokens. 
 *     The first token will contain <code>"i"</code>; the second one will contain <code>" = "</code>, since
 *     <code>"="</code> is a special character and forces the blanks before and after to be ignored 
 *     (i.e., the full tokenizer will return one token where the simple tokenizer would have returned three,
 *     namely <code>" "</code>, <code>"="</code> and <code>" "</code>); and so on.
 * </ul>
 *
 * <h4>Format of the returned values (detailed full tokenizing)</h4>
 *
 * <p>
 *   If you at the moment of the tokenizer instance creation you have requested detailed tokens,
 *   <code>getFullToken</code> adds a series of additional component to the returned stem:
 *
 * <ul>
 *   <li><code>t.absorbed</code>is an array containing all the simple tokens that are represented by this
 *     fulk token, after the token ignoring pass. For example, <code>"a + b"</code> would consist of
 *     five tokens when inspected with a simple tokenizer, namely, <code>"a"</code> (a variable symbol), <code>" "</code> (a blank),
 *     <code>"+"</code> (an operator), <code>" "</code> and <code>"b"</code>. When using a full detailed
 *     tokenizer, only three tokens would be returned, since the operator, being a special character,
 *     determines that the blanks before and after are ignorable. The original tokens would be retrievable
 *     in the <code>t.absorbed</code> component, that is, <code>t.absorbed</code> would be an array
 *     containing the first blank, <code>" "</code>, the original operator itself, <code>"+"</code>, and
 *     the second blank.
 *   <li><code>t.cloneIndex</code> is an index into <code>t.absorbed</code> identifying the array element
 *     that contains original, untransformed, simple token. In the previous example, 
 *     <code>t.cloneIndex = 2</code>, the index of the original <code>"+"</code> simple token.
 * </ul>
 *
 * <h4>Error handling</h4>
 *
 * <p>
 *   When the tokenizer encounters a syntax error, it returns a special token describing the error.
 *   Please note that the full tokenizer detects a series of errors that are not detected by the
 *   simple tokenizer. For example, when a directive start sequence, "::", is followed by a symbol that
 *   is not the name of a directive, the full tokenizer emits an error and stops, but the simple tokenizer
 *   does not detect any error. A higher-level parser making use of the tokenizer may detect earlier
 *   errors than the one returned. See the documentation for the <code>Syntax_Error</code> method for details.
 *
 * <h4>Important note</h4>
 *  
 * <p>
 *   Using <code>getSimpleToken</code> and <code>getFullToken</code> with the same tokenizer
 *   instance can lead to impredictable results.
 */

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
        If lastToken[class] == VAR_SYMBOL, lastToken[subClass] = SIMPLE, WordPos(Upper( lastToken[value] ),"ON OFF") > 0 Then Do
          If Upper( lastToken[value] ) == "ON" Then nextToLastToken[subClass] = CALL_ON_INSTRUCTION
          Else                                      nextToLastToken[subClass] = CALL_OFF_INSTRUCTION
          Call AbsorbRight nextToLastToken,lastToken
          lastToken = token
          Signal Get_more_tokens
        End
      End
      When SIGNAL_INSTRUCTION Then Do
        If lastToken[class] == VAR_SYMBOL, lastToken[subClass] = SIMPLE, WordPos(Upper( lastToken[value] ),"ON OFF") > 0 Then Do
          If Upper( lastToken[value] ) == "ON" Then nextToLastToken[subClass] = SIGNAL_ON_INSTRUCTION
          Else                                      nextToLastToken[subClass] = SIGNAL_OFF_INSTRUCTION
          Call AbsorbRight nextToLastToken,lastToken
          lastToken = token
          Signal Get_more_tokens
        End
      End
      When PARSE_INSTRUCTION Then Do
        val = Upper( lastToken[value] )
        If lastToken[class] == VAR_SYMBOL, lastToken[subClass] = SIMPLE, WordPos(val,"UPPER LOWER CASELESS") > 0 Then Do
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
    
  If nextToLastToken[class] == VAR_SYMBOL, nextToLastToken[subClass] == SIMPLE Then 
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
        
        nextToLastToken[class]    = KEYWORD_INSTRUCTION
        nextToLastToken[subClass] = instruction        
        
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

/**
 *
 * <h4>The <code>InitializeCharacterCategories</code> private method</h4>
 *
 * <p>
 *   Each character in the <b>"00"X.."FF"X</b> range is assigned a <em>character category</em>, 
 *   simbolized by a single character: digits ("0".."9") are assigned the category "digit" (<b>"d"</b>), 
 *   letters ("a".."z" and "A".."Z", plus "_", "?", "!" and some other implementation-dependent characters) 
 *   are assigned the "general_letter" (<b>"l"</b>) category, and so on.
 *
 * <p>
 *   When we are about to tokenize a line <b>L</b>, we will use the <code>TRANSLATE</code> BIF to obtain
 *   a new string containing the character categories of each individual character in <b>L</b>.
 *   This allows a very efficient determination of the token boundaries. For example, a run of <b>"d"</b> will
 *   identify a simple number, a run of <b>"d"</b> or <b>"l"</b> will identify a simple symbol, and so on.
 */ 

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
  
  simple_symbol      = general_letter||digit
  var_symbol_char    = simple_symbol||"."

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

/**
 *
 * <h4>The <code>InitializeSimpleTokenizer</code> private method</h4>
 *
 * <p>
 *   The <code>InitializeSimpleTokenizer</code> method initializes a series of variables
 *   that will hold the context when tokenizing a ::Resource directive.
 *
 */

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
    
/**
 *
 * <h4>The <code>getSimpleToken</code> method</h4> 
 *
 * <p>
 *   The <code>getSimpleToken</code> method selects the next token in the input file and
 *   returns a stem containing the details that describe this token.
 *
 * <p>
 *   The components of a returned stem <code>t.</code> are the following:
 *
 * <ul>
 *   <li><code>t.class</code>, selected between the <em>non-indented</em> elements of the <code>tokenClasses</code>
 *     constant above, excluding those marked as "Level 2".
 *   <li><code>t.subclass</code>, selected between the <em>indented</em> elements of the <code>tokenClasses</code>
 *     constant above (when there is no indented element, <code>t.class == t.subclass</code>). Subclasses
 *     identified as "Level 2" are not considered in a simple tokenizing.
 *   <li><code>t.value</code>. In general, this is the character representation of the token itself,
 *     but in some cases it can differ. For example, in the case of strings, this is the string value,
 *     independent of whether its specification has used or not internal double quotes, or it is any of the
 *     "X"-, "B"- or "U"- suffixed strings. That is, in the ASCII encoding, <code>t.value</code> 
 *     is identical when the token was <code>"a"</code>, <code>"61"X</code> or <code>"0110 0001"B</code>.
 *   <li><code>t.location</code>. This component has the form <code>line1 start line2 pos</code> and identifies the
 *     start position of the token, and the end position, plus one character. "Line1" and "line2" will always
 *     be identical, except in the case of multi-line comments.
 * </ul>
 *
 * <h4>Important note</h4>
 *  
 * <p>
 *   Using <code>getSimpleToken</code> and <code>getFullToken</code> with the same tokenizer
 *   instance can lead to impredictable results.
 *
 */ 
  
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
     If thisCharIsNotA( "." )             Then Return Token( VAR_SYMBOL, SIMPLE )
     
     -- That was a period. Skip it
     Call nextChar
     
     -- End of symbol? This is a stem
     If thisCharIsNotA( var_symbol_char ) Then Return Token( VAR_SYMBOL, STEM )
     
     -- If there is any stuff after the period, that's a compound symbol
     Call skipCharsUntilNot var_symbol_char
     
     Return Token( VAR_SYMBOL, COMPOUND )

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
     Return Token( CONST_SYMBOL, LITERAL )

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
       Otherwise Return Token( CONST_SYMBOL, PERIOD )
     End
environmentSymbol:     
     Call skipCharsUntilNot var_symbol_char
     Return Token( CONST_SYMBOL, ENVIRONMENT )

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
    r = CHARACTER
  End
StringCommon:  
  If r == "" Then r = CHARACTER
  Return Token( STRING, r, v, line start line pos)
 
BytesString: 
  v = thisLine[oldPos,pos-oldPos-1]~changeStr(q||q,q)
  r = BYTES
  Call nextChar -- Skip radix
  Return Token( STRING, r, v, line start line pos)  
 
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
    When 7, 8, 9 Then Nop -- Handled elsewhere
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
    pos = 0 -- Force line feed on next token
    resourceContext = -1
    Return Token( RESOURCE_IGNORED, , SubStr(thisLine, savePos), line savePos line maxPos )
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

/**
 * <h4>The <code>errorMessage</code> helper routine</h4>
 *
 * @param <code>code</code> The Rexx error Syntax code, in the <code><em>major</em>.<em>minor</em></code> format. 
 * @param <code>substArray</code> An array of substition instances.
 * @returns An array containing the major and the minor error messages for the specified <code>code</code>, with all the instances in <code>substArray</code>
 *   substituted in the message.
 */

::Routine errorMessage Public
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
