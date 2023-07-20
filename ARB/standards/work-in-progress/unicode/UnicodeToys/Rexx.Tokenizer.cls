/*****************************************************************************/
/*                                                                           */
/*  Rexx.Tokenizer.cls                                                       */
/*  ==================                                                       */
/*                                                                           */
/*  Copyright (c) 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>     */
/*                                                                           */
/*  See https://github.com/RexxLA, rexx-repository,                          */
/*      path ARB/standards/work-in-progress/unicode/UnicodeToys              */
/*                                                                           */
/*  License: Apache License 2.0 https://www.apache.org/licenses/LICENSE-2.0  */
/*                                                                           */
/*                                                                           */
/*  This .cls file implements a set of ooRexx classes. The main class is     */
/*  Rexx.Tokenizer. It implements a basic Rexx tokenizer. The getToken       */
/*  method returns basic Rexx tokens and non-tokens. [Nested] classic        */
/*  comments and strings are handled.                                        */
/*                                                                           */
/*  The exact syntax accepted by the tokenizer depends on the subclass.      */
/*  Subclasses starting with "Regina" accept the Regina Rexx syntax;         */
/*  subclasses starting with "ANSI.Rexx" accept only the ANSI Rexx syntax    */
/*  (for example, comments starting with "--" are accepted by Regina but     */
/*  not by ANSI; subclasses starting with "ooRexx" accept ooRexx syntax;     */
/*  for example, "[", "]" and "~" are valid characters for ooRexx subclasses */
/*  but not for Regina or ANSI subclasses.                                   */
/*                                                                           */
/*  Classes with "Unicode" in their name accept three new, experimental,     */
/*  types of string:                                                         */
/*                                                                           */
/*    "string"R, Runes strings (checked for UTF8 correctness at parse time)  */
/*    "string"T, Text strings (checked for UTF8 correctness at parse time)   */
/*    "string"U, Unicode codepoint strings. Codepoints can be specified      */
/*               using hexadecimal notation (61, 0061, 0000), or as a name,  */
/*               alias or label enclosed in parenthesis ("(cr)","(CR) (LF)", */
/*               "(Woman) (zwj) (Man)"). Codepoints, names, alias and labels */
/*               are checked for correctness at parse time.                  */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1d JMB 20230719 Initial public release                                */
/*  00.1e JMB 20230720 Support U+hhhh in U strings                           */
/*                                                                           */
/*****************************************************************************/

::Class ooRexx.Tokenizer            Subclass Rexx.Tokenizer   Public

::Class ooRexx.Unicode.Tokenizer    Subclass ooRexx.Tokenizer Public

::Class Regina.Tokenizer            Subclass Rexx.Tokenizer   Public

::Class Regina.Unicode.Tokenizer    Subclass Rexx.Tokenizer   Public

::Class ANSI.Rexx.Tokenizer         Subclass Rexx.Tokenizer   Public

::Class ANSI.Rexx.Unicode.Tokenizer Subclass Rexx.Tokenizer   Public

::Class Rexx.Tokenizer                                        Public

::Method init
  Use local pkglocal
  Use Strict Arg source
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
  self~InitializeTokenizer
  
  UnicodeLoaded = 0
  
::Attribute tokenCount get

::Method sourceLine
  Expose source
  Return source[Arg(1)]

::Method InitializeCharacterCategories Private
  Expose characters categories blank_character digit general_letter simple_symbol var_symbol_char
  characters = ""
  categories = ""

  -- The following values will be used as labels in the state machine below
  -- using a calculated Signal instruction.
  
  digit              = "d"
  general_letter     = "l"
  special            = "s"
  not                = "n"
  operator_only      = "o" -- Partial operator
  operator_or_other  = "/"
  blank_character    = " "
  illegal            = "x"
  
  simple_symbol      = general_letter||digit
  var_symbol_char    = simple_symbol||"."

  -- ANSI 6.2.2.1: digit := '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
  Call AssignCharacterCategory digit,              "0123456789"
 
  -- ANSI 6.2.2.2: special := ',' | ':' | ';' | ')' | '(' 
  Call AssignCharacterCategory special,            ",:;()[]"
 
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
    Call AssignCharacterCategory special,          "[]"
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

::Constant tokenClasses (   -
  ( END_OF_SOURCE   , "F" ), -
  ( END_OF_LINE     , "L" ), -  
  ( CLASSIC_COMMENT , "c" ), -
  ( LINE_COMMENT    , "l" ), -
  ( BLANK           , "b" ), -
  ( SPECIAL         , "s" ), -
  ( OPERATOR        , "o" ), -
  ( VAR_SYMBOL      , "V" ), -
    ( SIMPLE        , "1" ), -
    ( STEM          , "2" ), -
    ( COMPOUND      , "3" ), -
  ( NUMBER          , "N" ), -
    ( INTEGER       , "4" ), -
    ( FRACTIONAL    , "5" ), -
    ( EXPONENTIAL   , "6" ), -
  ( CONST_SYMBOL    , "C" ), -
    ( PERIOD        , "7" ), -
    ( LITERAL       , "8" ), -
    ( ENVIRONMENT   , "9" ), -
  ( STRING          , "S" ), -
    ( BINARY        , "B" ), -
    ( HEXADECIMAL   , "X" ), -
    ( CHARACTER     , "C" ), -  
    ( RUNES         , "R" ), -  -- Unicode only
    ( TEXT          , "T" ), -  -- Unicode only
    ( CODEPOINTS    , "U" )  -  -- Unicode only
)

::Method InitializeTokenizer Private
  Use Local tc   -- Needed because of the "Call Value" instruction below
  moreLines      = 1
  line           = 0
  pos            = 0
  Do tc over self~tokenClasses
    Call Value tc[1], tc[2]
  End
  tokenCount     = 0
  lastToken      = .nil
Return  

::Method Prettify
  Use Local -- No local variables, really.
  Select Case Arg(1)
    When END_OF_SOURCE Then Return "End-of-source"
    When END_OF_LINE   Then Return "End-of-line"
    When BLANK         Then Return "Blank"
    When VAR_SYMBOL    Then Return "Variable"
    When NUMBER        Then Return "Number"
    When CONST_SYMBOL  Then Return "Const"
    When STRING        Then Return "String"
    When SPECIAL       Then Return "Special"
    When OPERATOR      Then Return "Operator"
    When SIMPLE        Then Return "Simple"
    When STEM          Then Return "Stem"
    When COMPOUND      Then Return "Compound"
    When INTEGER       Then Return "Integer"
    When FRACTIONAL    Then Return "Fractional"
    When EXPONENTIAL   Then Return "Exponential"
    When PERIOD        Then Return "Period"
    When LITERAL       Then Return "Literal"
    When ENVIRONMENT   Then Return "Environment"
    When BINARY        Then Return "Binary"
    When HEXADECIMAL   Then Return "HEXADECIMAL"
    When CHARACTER     Then Return "CHARACTER"
    Otherwise               Return Arg(1)
  End

::Attribute lastToken get
  
::Method getToken
  Use Local
  Signal On User Syntax.Error
  token = getAToken()
  lastToken = token
Return token                   

getLine:
  If line >= maxLines Then Return 0
  line      = line + 1
  pos       = 1
  thisLine  = source[line]
  moreLines = line < maxLines
  maxPos    = Length(thisLine)+1
  charCat   = Translate(thisLine, categories, characters)
Return 1       

nextChar: pos += 1; Return

thisChar: Return thisLine[pos]

thisCharIsA:    Return Pos(charCat[pos], Arg(1))  > 0

thisCharIsNotA: Return Pos(charCat[pos], Arg(1)) == 0

skipCharsUntilNot:
  pos = Verify( charCat, Arg(1), , pos)
  If pos == 0 Then pos = maxPos
Return

getAToken:
  If pos == 0, \getLine() Then 
    Return Token( END_OF_SOURCE, , "")
  If pos >= maxPos Then Do
    pos = 0 -- Forces line feed on next
    Return Token( END_OF_LINE, , "")
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
-- skippable) BLANK token                                                     --
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
          
"s": Return Token( SPECIAL, ,  c   )
"n": Return Token( OPERATOR, , "\" )                 -- Always "\"
"o": If c == "-", .line_comments, thisChar() == "-" Then Do
       pos = maxPos                                  -- Forces END_OF_LINE on next
       Return Token( LINE_COMMENT, )
     End
     Return Token( OPERATOR, , c )
"x": If .ooRexx Then 
       Call Syntax 13.1, line, c, c2x(c)             -- illegal
     Else            
       Call Syntax 13.1, line, c2x(c)                -- illegal
"/": If thisChar() \== "*" Then Return Token( OPERATOR, , "/" )
     level = 1                                       -- standard_comment
     Call nextChar
     save = line
     saveLine = thisLine
     Loop
       p = Pos("/",charCat,pos)
       If p == 0 Then Do                             -- Multi-line comment
         If \getLine() Then Do
           thisLine = saveLine                       -- Restore for syntax error
           Call Syntax 6.1, save, save
         End
       End
       Else If thisLine[p-1] == "*" Then Do
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

-- Ensures that binary and hexadecimal strings are well-formed,
-- that no extraneous characters are found, and that the string
-- ends in the same line.
--
-- Returns the whole string, including the radix ("X" or "B"), 
-- if present, and possibly double delimiters.
--

"'": '"':                      
  q = k
  oldPos = pos
  Loop
    p = Pos(q,charCat,pos)
    If p == 0 Then
      If q = "'" Then Call Syntax 6.2, line
      Else            Call Syntax 6.3, line
    If charCat[p+1] == q Then pos = p+2
    Else Leave
  End
  pos = p + 1
  r = thisLine[pos]~upper
  If  .unicode, Pos(r,"XBRTU") == 0 Then r = ""
  If \.unicode, Pos(r,"XB")    == 0 Then r = ""
  If r \== "" , (pos+1 == maxPos | Verify(charCat[pos+1], var_symbol_char)) Then Do
    If Pos(r,"RTU") > 0 Then Signal UnicodeString
    inside = Translate(thisLine[start+1,pos-start-2]," ","09"x)  -- TODO See what does Regina consider whitespace inside such strings
    if inside[1] == " " Then Do
      If r == "X" Then Call Syntax 15.1, line, 1
      If r == "B" Then Call Syntax 15.2, line, 1
    End
    strip = Strip(inside,"T")
    If strip \== inside Then Do
      If r == "X" Then Call Syntax 15.1, line, Length(strip)+1
      If r == "B" Then Call Syntax 15.2, line, Length(strip)+1
    End
    Do i = 2 To Words(inside)
      If (Word(inside,i)~length // (2 + 2*(r == "B")) ) \== 0 Then Do
        If r == "X" Then Call Syntax 15.1, line, Length( Strip( SubWord(inside, 1, i),"T") ) + 1
        Else -- There is an incoherence in ooRexx here (15.1 vs 15.5)                     
          Call Syntax .regina~?(15.2,15.6), line, Length( Strip( SubWord(inside, 1, i),"T") ) + 1
      End
    End
    If r == "X", \inside~dataType("X") Then Call Syntax 15.3, line, Left( Strip( Translate(inside," ","01234567890ABCDEFabcdef") ), 1 )
    If r == "B", \inside~dataType("B") Then Call Syntax 15.4, line, Left( Strip( Translate(inside," ","01"                     ) ), 1 )
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
  Return Token( STRING, r, v )
 
UnicodeString:
  If r == "U" Then Signal UnicodeUString
UnicodeRandTStrings:  
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
        Call Check_2_808F d
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
      Otherwise Call Syntax 22.902, line, c2x(c)
    End
    Iterate
  End
  -- Do something
  Call nextChar -- Skip radix
Signal StringCommon  

Get1CharMore:
  If i   == length Then Call Syntax 22.902, line, c2x(c)
  i += 1 
  d = v[i]
  Return
  
Get2CharsMore:
  Call Get1CharMore
  If i+1 > length Then Call Syntax 22.902, line, c2x(c||d)
  i += 1
  e = v[i]
  Return

Get3CharsMore:
  Call Get2CharsMore
  If i+1 > length Then Call Syntax 22.902, line, c2x(c||d||e)
  i += 1
  f = v[i]
  Return
  
Check_2_A0BF:
  If "A0"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Call Syntax 22.902, line, c2x(c||d)

Check_2_808F: 
  If "80"X <= Arg(1), Arg(1) <= "8F"X Then Return
  Call Syntax 22.902, line, c2x(c||d)

Check_2_809F: 
  If "80"X <= Arg(1), Arg(1) <= "9F"X Then Return 1
  Call Syntax 22.902, line, c2x(c||d)

Check_2_80BF: 
  If "80"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Call Syntax 22.902, line, c2x(c||d)

Check_3_80BF: 
  If "80"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Call Syntax 22.902, line, c2x(c||d||e)

Check_4_80BF: 
  If "80"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Call Syntax 22.902, line, c2x(c||d||e||f)

Check_2_90BF: 
  If "90"X <= Arg(1), Arg(1) <= "BF"X Then Return 1
  Call Syntax 22.902, line, c2x(c||d)


UnicodeUString:
  -- Load Unicode on demand when really needed
  If \UnicodeLoaded Then Do
    Call "Unicode.cls"
    UnicodeLoaded = 1
  End
  -- 22: Invalid character string
  -- 22.903: Invalid Unicode codepoint "&1".
  contents = thisLine[oldPos,pos-oldPos-1]
  v = ""
  Do While contents \= " "
    contents = Strip(contents)
    If contents[1] == "(" Then Do
      Parse var contents "("name")"extra
      If extra == "" Then If \contents~endsWith(")") Then Call Syntax 22.903, line, contents
      contents = Strip(extra)
      code = N2R(name)
      If code = "" Then Call Syntax 22.904, line, name
      v ||= UTF8(code)
      Iterate
    End
    Parse Var contents word contents
    If Upper(word) == "U+" Then Call Syntax 22.903, line, word
    If Upper(Left(word,2)) == "U+" Then
       word = SubStr(word,3)
    If \DataType(word,"X") Then Call Syntax 22.903, line, word
    If X2D(word) > X2D(10FFFF) Then Call Syntax 22.903, line, word
    If X2D(word) >= X2D(DB00), X2D(word) <= X2D(DFFF) Then Call Syntax 22.903, line, word
    v ||= UTF8(word)
  End
  Call nextChar -- Skip radix
Signal StringCommon    
 
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
 
Token:
  tokenCount += 1
  t. = .Stem~new
  Use Arg ,
    t.class,, 
    t.subclass = ( t.class ),,
    t.value    = ( SubStr(thisLine,start,pos-start) ),,
    t.location = ( (t.value=="")~?("",line start pos) )
  Return t.

Syntax.Error: Raise propagate

::Routine Syntax Public
  Raise User Syntax.Error Array(Arg(1), Arg(2), Arg(3,"A"))

::Routine errorMessage Public
--
-- Arguments
--
--  error code: major"."minor
--  substArray: an array of substitution instances
--
-- List of error messages, with substitutions
--
-- When the messages for ooRexx and Regina are different, there is
-- an extra compound variable starting with "Regina.".
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
  errMsg.21      = "Invalid data on end of clause."
  errMsg.21.901  = "Data must not follow the NOP keyword; found ""&1""."
  errMsg.22      = "Invalid character string."
  Unicode.22.902 = "Invalid UTF-8 sequence ""&1""X."
  Unicode.22.903 = "Invalid Unicode codepoint ""&1""."
  Unicode.22.904 = "Invalid Unicode name ""&1""."
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
