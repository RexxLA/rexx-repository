--
-- This file is part of The Unicode Tools Of Rexx (TUTOR).
-- See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools
--
-- Copyright &copy; 2023, Josep Maria Blasco <josep.maria.blasco@epbcn.com>.
--
-- License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).
--
-- Please refer to docs/new-functions.md for documentation and additional details.
--
-- Notice:
--
-- Although this routine is part of TUTOR, The Unicode Tools Of Rexx,
-- it can also be used separately, as it has no dependencies on the rest
-- of components of TUTOR.
--

::Routine UTF8 Public

  -- string        -- The string to validate/convert
  -- format        -- Format of "string" (one of UTF-8, UTF-8Z, WTF-8, CESU-8, MUTF-8; default: UTF-8)
  -- target        -- We want "string" converted to the "target" encodings.
  --               --   Either not specified or "" (the default), don't do any conversion; 
  --               --   or (one of UTF-8, UTF-32, or both),
  --               --   or (one of WTF-8, WTF-32, or both).
  -- errorhandling -- What to do if we find ill-formed character sequences
  --               --   One of ("NULL" or "" [the default], return a null string; "REPLACE",
  --               --   replace the ill-formed sequence with the Unicode Replacement Character,
  --               --   or "SYNTAX", raise a Syntax error).
  --               -- It is an error to specify "errorHandling" when "target" was not specified.

  Use Strict Arg string, format = "UTF-8", target = "", errorHandling = ""

  -- One-time initialization. Fill the TRANSLATE tables
  If .Unicode.UTF8.Initialized \== 1 Then Call InitializeTranslateTables
  
  ------------------------------------------------------------------------------
  -- Check that the supplied arguments are OK,                                --
  -- and raise a Syntax condition if not                                      --
  ------------------------------------------------------------------------------
  
  -- Validate and normalize "format"
  
  format = Strip(Upper(format))
  Select Case format
    When "CESU-8", "CESU8"    Then format = "CESU-8"
    When "MUTF-8", "MUTF8"    Then format = "MUTF-8"
    When "UTF-8",  "UTF8", "" Then format = "UTF-8"
    When "UTF-8Z", "UTF8Z"    Then format = "UTF-8Z"
    When "WTF-8",  "WTF8"     Then format = "WTF-8"
    Otherwise Raise Syntax 93.900 Additional("Invalid format '"format"'")
  End

  -- Lone surrogates are ill-formed for UTF-8 and UTF-8Z  
  If format \== "UTF-8", format \== "UTF-8Z" Then loneSurr =  1
  -- Wait to see what are the formats
  Else                                            loneSurr = -1

  -- We are in validation mode only when no target format has been specified
  validate = target == ""
  
  -- Check that "target" is OK
  targets  =  0                       -- Number of targets (0, 1 or 2)
  return8  =  0                       -- Return UTF-8  or WTF-8
  return32 =  0                       -- Return UTF-32 or WTF-32
  target   =  Space(Upper(target))
  Do target Over target~makeArray(" ")
    targets += 1
    Select Case target
      When "UTF-8",  "UTF8",  "WTF-8",  "WTF8"  Then return8  = 1
      When "UTF-32", "UTF32", "WTF-32", "WTF32" Then return32 = 1
      Otherwise Raise Syntax 93.900 Additional("Invalid target '"target"'")
    End    
    Select Case target
      When "UTF-8", "UTF8", "UTF-32", "UTF32" Then 
        If loneSurr == -1 Then lonesurr = 0
        Else If loneSurr = 1 Then Raise Syntax 93.900 Additional("Conflicting target '"Space(Upper(Arg(3)))"' and format '"format"'")
      When "WTF-8", "WTF8", "WTF-32", "WTF32" Then 
        If loneSurr == -1 Then lonesurr = 1
        Else If loneSurr = 0 Then Raise Syntax 93.900 Additional("Conflicting target '"Space(Upper(Arg(3)))"' and format '"format"'")
    End    
  End
    
  -- It's an error to specify errorHandling when target was not specified
  If target == "", errorHandling \== "" Then 
    Raise Syntax 93.900 Additional("Invalid option '"errorHandling"'")
  
  -- Check that "errorHandling" is OK.  
  Select Case Strip(Upper(errorHandling))
    When "NULL", "" Then errorHandling = "NULL"
    When "SYNTAX"   Then errorHandling = "SYNTAX"
    When "REPLACE"  Then errorHandling = "REPLACE"
    Otherwise Raise Syntax 93.900 Additional("Invalid error handling '"errorHandling"'")
  End

  repl     = errorHandling == "REPLACE"
  syntax   = errorHandling == "SYNTAX"
  null     = errorHandling == "NULL"  
   
  ------------------------------------------------------------------------------
 
  -- Null strings decode to the null string.
  If string == "" Then Signal StringIsEmpty 
  
  string = string~makeString -- Demote to pure .String to avoid possible loops

  -- Build the "states" string. We will work in parallel with "string" and "states"
  states = Translate(string, .local["Unicode."format".tableo"], .local["Unicode."format".tablei"])
  
  If return8  Then buffer8  = .MutableBuffer~new
  If return32 Then buffer32 = .MutableBuffer~new
      
  i      = 0
  length = Length(string)
  
continueScan:
  i += 1
  -- Did we scan the whole string without errors? The string is good.
  If i > length Then Signal StringIsGood
  
--  
-- VALID 1-BYTE SEQUENCES (i.e., ASCII, or ASCII - "00"U)
--
  
  save = i
  If OnlyASCIIsLeft() Then Do
    -- If the rest of the string is composed only of ASCII characters, then
    -- the string is good. Copy all ASCIIs left, and return.
    Do i = i to length
      If return8  Then buffer8 ~append(              string[i] )
      If return32 Then buffer32~append( "000000"x || string[i] )
    End
    Signal StringIsGood
  End
   
  -- Only some (>= 0) chars were ASCII. Copy them.
  Do j = save to i - 1
    If return8  Then buffer8 ~append(              string[j] )
    If return32 Then buffer32~append( "000000"x || string[j] )
  End 

--
-- HANDLE NON-ASCII CHARACTERS
--  

  state = states[i]
  Signal (state)     -- Fire the FSM

--
-- ILLEGAL CHARS
--  

-- An illegal character is an error, 
-- and a lone continuation character is also an error.
"I": "C": Signal 1Error
  
--
-- TWO-BYTE SEQUENCES
--  
"20"X:
  -- We want a two-byte sequence
  If states[i+1] \== "C" Then Signal 1Error
  If return32 Then Do
    y = Right(X2B(C2X(string[i  ])), 5)
    x = Right(X2B(C2X(string[i+1])), 6)
    buffer32~append( "0000"X || X2C(B2X("00000"||y||x)) )
  End
  If return8  Then buffer8~append(string[i,2])
  i += 1
  Signal continueScan

"0": -- UTF8-Z and MUTF-8: C080 --> "0000"U, ill-formed otherwise
  If string[i+1] \== "80"X Then Signal 1Error
  If return8  Then buffer8 ~append(        "00"X )
  If return32 Then buffer32~append( "0000 0000"X )
  i += 1
  Signal continueScan
  
--
-- THREE-BYTE SEQUENCES
--    
"3a"X: "3b"X: "3c"X: "3d"X: "3e"X:
  -- We need exactly a three-byte sequence
  If states[i+1] \== "C" Then Signal 1Error
  If state == "3a"X, string[i+1] < "A0"X  Then Signal 1Error
  If state == "3c"X, string[i+1] > "9F"X  Then Signal 1Error
  If state \== "3e"X, states[i+2] \== "C" Then Signal 2Error
  If state == "3d"X Then Do
    -- In WTF-8, surrogate pairs are ill-formed
    If states[i+3,3] == "3d"X"CC",                 -        
       string[i+1] >= "A0"X, string[i+1] <= "AF"X, -
       string[i+4] >= "B0"X, string[i+4] <= "BF"X  Then Signal 6Error
    -- Lone surrogates aren't well-formed in some encodings
    If string[i+1] >= "A0"X, \ loneSurr Then Signal 3Error
  End
  If state == "3e"X Then Signal CESU8
3OK:
  If return32 Then Do
    z = Right(X2B(C2X(string[i  ])), 4)
    y = Right(X2B(C2X(string[i+1])), 6)
    x = Right(X2B(C2X(string[i+2])), 6)
    If return32 Then buffer32~append( "0000"X || X2C(B2X(z||y||x)) )
  End
  If return8  Then buffer8~append(string[i,3])
  i = i + 2
Signal continueScan

CESU8:
-- See https://en.wikipedia.org/wiki/CESU-8:
--
-- "Though not specified in the technical report, unpaired surrogates are also encoded as 3 bytes each, 
--  and CESU-8 is exactly the same as applying an older UCS-2 to UTF-8 converter to UTF-16 data."
--
  -- We know that string[i] == "ED"X and that states[i+1] == "C"
  If states[i+2] \== "C"       Then Signal 2Error
  Select
    When string[i+1] <= "9F"X  Then Signal 3OK         -- Standard UTF-8 three-byte sequence
    When string[i+1] >= "B0"X  Then Signal 3OK         -- Lone trail surrogate
    Otherwise -- A0..AF: lead surrogate
      If states[i+2] \== "C"   Then Signal 2Error
      If string[i+3] \== "ED"X Then Signal 3OK         -- Lone lead surrogate
      If states[i+4] \== "C"   Then Signal 3OK
      If states[i+5] \== "C"   Then Signal 3OK
      If string[i+4] < "B0"X   Then Signal 3OK         -- Not a trail surrogate
      If string[i+4] > "BF"X   Then Signal 3OK         -- Not a trail surrogate
      -- From https://en.wikipedia.org/wiki/CESU-8
      -- The encoding of Unicode non-BMP characters works out to 
      -- 11101101 1010yyyy 10xxxxxx 11101101 1011xxxx 10xxxxxx (yyyy represents the top five bits of the character minus one). 
      a = Right(X2B(C2X(string[i+1])), 4)
      b = Right(X2B(C2X(string[i+2])), 6)
      c = Right(X2B(C2X(string[i+4])), 4)
      d = Right(X2B(C2X(string[i+5])), 6)
      a = X2B(D2X( X2D(B2X(a)) + 1 ))
      b = Right(a || b || c || d, 21, 0)
      scalar = Right(X2C(B2X(b)),4,"00"X)
  End

  If return32 Then buffer32~append( scalar )
  If return8  Then Do
    -- Unicode Standard, table 3-6.
    -- 000uuuuu zzzzyyyy yyxxxxxx --> 11110uuu 10uuzzzz 10yyyyyy 10xxxxxx
    Parse var b uuu 4 uuzzzz 10 yyyyyy 16 xxxxxx
    buffer8~append( X2C( B2X("11110"uuu"10"uuzzzz"10"yyyyyy"10"xxxxxx) ) )
  End
  i = i + 5
Signal continueScan


--
-- FOUR-BYTE SEQUENCES
--      
"4a"X: "4b"X: "4c"X:     
  -- We need a four-byte sequence. No continuation, or only one or two
  -- continuations are errors.
  If states[i+1] \== "C" Then Signal 1Error
  Select Case state
    When "4b"X Then Nop
    When "4a"X Then If string[i+1] < "90"X Then Signal 1Error
    When "4c"X Then If string[i+1] > "8F"X Then Signal 1Error        
  End
  If states[i+2] \== "C" Then Signal 2Error
  If states[i+3] \== "C" Then Signal 3Error
  If return32 Then Do
    u = Right(X2B(C2X(string[i  ])), 3)
    z = Right(X2B(C2X(string[i+1])), 6)
    y = Right(X2B(C2X(string[i+2])), 6)
    x = Right(X2B(C2X(string[i+3])), 6)
    buffer32~append( "00"X || X2C(B2X(Right(u||z||y||x,24,0))) )
  End
  If return8  Then buffer8~append(string[i,4])
  i = i + 3  
Signal continueScan
    
-- 1 character is in error  
1Error:  
  If validate Then Return 0
  If null     Then Return ""
  errorSequence = string[i]
  If syntax Then Signal Syntax
  Call ReplaceCharacter
Signal continueScan  

-- 2 characters are in error  
2Error:  
  If validate Then Return 0
  If null     Then Return ""
  errorSequence = string[i,2]
  If syntax Then Signal Syntax
  Call ReplaceCharacter
  i += 1
Signal continueScan  

-- 3 characters are in error  
3Error:  
  If validate Then Return 0
  If null     Then Return ""
  errorSequence = string[i,3]
  If syntax   Then Signal Syntax
  Call ReplaceCharacter
  i += 2
Signal continueScan  

-- 6 characters are in error (WTF-8 surrogate pair sequence)
6Error:  
  If validate Then Return 0
  If null     Then Return ""
  errorSequence = string[i,6]
  If syntax Then Signal Syntax
  Call ReplaceCharacter
  Call ReplaceCharacter -- Two replacement characters: it was a pair
  i += 5
Signal continueScan      
    
ReplaceCharacter:
  If return8  Then buffer8 ~append(   "efbfbd"X )
  If return32 Then buffer32~append( "0000FFFD"X )
Return    
  
OnlyASCIIsLeft:
  pos = Verify(states, "A", "N", i)
  If pos == 0 Then Return 1          -- Only ASCII characters left, string is good.
  i   = pos                          -- Set the new i
Return 0
  
StringIsEmpty:  
  If validate     Then Return 1
  
  -- Only one target? Return a string
  Return ""
  
  -- Several targets. Return a stem.
  s. = .Stem~new()
  If loneSurr Then Do
    s.wtf8  = ""
    s.wtf32 = ""
  End
  Else Do
    s.utf8  = ""
    s.utf32 = ""
  End
  Return s.
    
StringIsGood:
  If validate     Then Return 1
  
  -- Only one target? Return a string
  If targets == 1 Then 
    If return8 Then Return buffer8 ~string
    Else            Return buffer32~string
    
  -- Several targets. Return a stem.
  s. = .Stem~new()
  If loneSurr Then Do
    s.wtf8  = buffer8  ~string
    s.wtf32 = buffer32 ~string
  End
  Else Do
    s.utf8  = buffer8  ~string
    s.utf32 = buffer32 ~string
  End
  Return s.
  
Syntax:
  Raise Syntax 23.900 Additional("Invalid" format "sequence in position" i "of string: '"C2X(errorSequence)"'X") 

--------------------------------------------------------------------------------
-- One time only: build the TRANSLATE tables for each supported encoding      --
--------------------------------------------------------------------------------

::Routine InitializeTranslateTables

  .local~Unicode.UTF8.Initialized = 1

  ASCII  = "A"
  
  --
  -- UTF8
  --
  -- The Unicode® Standard. Version 15.0 – Core Specification
  -- https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf,
  -- table 3-7, p. 135.
  
  tablei = ""
  tableo = ""
  
  Call AssignCharacters "00","7F",ASCII      -- ASCII Chars
  Call AssignCharacters "80","BF","C"        -- Continuation character
  Call AssignCharacters "C0","C1","I"        -- Illegal character
  Call AssignCharacters "C2","DF","20"X      -- 2-byte sequences (1 continuation)
  Call AssignCharacters "E0","E0","3a"X      -- 3-byte sequences of subtype "a": 2nd byte in A0..BF. Manual check.
  Call AssignCharacters "E1","EC","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call AssignCharacters "ED","ED","3c"X      -- 3-byte sequences of subtype "c". 2nd byte in 80..9F. Manual check.
  Call AssignCharacters "EE","EF","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call AssignCharacters "F0","F0","4a"X      -- 4-byte sequences of subtype "a". 2nd byte in 90..BF. Manual check.
  Call AssignCharacters "F1","F3","4b"X      -- 4-byte sequences of subtype "b". 3 continuations.
  Call AssignCharacters "F4","F4","4c"X      -- 4-byte sequences of subtype "c". 2nd byte in 80..8F. Manual check.
  Call AssignCharacters "F5","FF","I"        -- Illegal character
   
  .local["Unicode.UTF-8.tablei"] = tablei
  .local["Unicode.UTF-8.tableo"] = tableo
  
  -- UTF8Z
  --
  -- UTF-8Z is identical to UTF-8, except for the way in which the null character ("00"U) is encoded.
  --
  -- UTF-8Z encodes "00"U using the overlong encoding "C080"X. 
  -- "00"X never appears in a UTF-8Z encoded string,
  -- and "C0"X continues to be invalid, unless immediately followed by "00"X.

  tablei = ""
  tableo = ""
  
  Call AssignCharacters "00","00","I"        -- "00"X is illegal in UTF8Z
  Call AssignCharacters "01","7F",ASCII      -- ASCII Chars
  Call AssignCharacters "80","BF","C"        -- Continuation character
  Call AssignCharacters "C0","C0","0"        -- C080 --> "0000"U; C0xx --> illegal
  Call AssignCharacters "C1","C1","I"        -- Illegal character
  Call AssignCharacters "C2","DF","20"X      -- 2-byte sequences (1 continuation)
  Call AssignCharacters "E0","E0","3a"X      -- 3-byte sequences of subtype "a": 2nd byte in A0..BF. Manual check.
  Call AssignCharacters "E1","EC","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call AssignCharacters "ED","ED","3c"X      -- 3-byte sequences of subtype "c". 2nd byte in 80..9F. Manual check.
  Call AssignCharacters "EE","EF","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call AssignCharacters "F0","F0","4a"X      -- 4-byte sequences of subtype "a". 2nd byte in 90..BF. Manual check.
  Call AssignCharacters "F1","F3","4b"X      -- 4-byte sequences of subtype "b". 3 continuations.
  Call AssignCharacters "F4","F4","4c"X      -- 4-byte sequences of subtype "c". 2nd byte in 80..8F. Manual check.
  Call AssignCharacters "F5","FF","I"        -- Illegal character
   
  .local["Unicode.UTF-8Z.tablei"] = tablei
  .local["Unicode.UTF-8Z.tableo"] = tableo

  -- WTF8
  --
  -- See The WTF-8 Encoding, https://simonsapin.github.io/wtf-8/,
  -- table 3, which is a variant of UTF-8 table 3-7.
  
  tablei = ""
  tableo = ""
  
  Call AssignCharacters "00","7F",ASCII      -- ASCII Chars
  Call AssignCharacters "80","BF","C"        -- Continuation character
  Call AssignCharacters "C0","C1","I"        -- Illegal character
  Call AssignCharacters "C2","DF","20"X      -- 2-byte sequences (1 continuation)
  Call AssignCharacters "E0","E0","3a"X      -- 3-byte sequences of subtype "a": 2nd byte in A0..BF. Manual check.
  Call AssignCharacters "E1","EC","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call AssignCharacters "ED","ED","3d"X      -- 3-byte sequences of subtype "d". 2nd byte in 80..9F, normal char; in A0..AF, lead surrogate; in B0..BF, trail surrogate
  Call AssignCharacters "EE","EF","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call AssignCharacters "F0","F0","4a"X      -- 4-byte sequences of subtype "a". 2nd byte in 90..BF. Manual check.
  Call AssignCharacters "F1","F3","4b"X      -- 4-byte sequences of subtype "b". 3 continuations.
  Call AssignCharacters "F4","F4","4c"X      -- 4-byte sequences of subtype "c". 2nd byte in 80..8F. Manual check.
  Call AssignCharacters "F5","FF","I"        -- Illegal character
   
  .local["Unicode.WTF-8.tablei"] = tablei
  .local["Unicode.WTF-8.tableo"] = tableo

  -- CESU-8
  --
  -- See Unicode Technical Report #26. COMPATIBILITY ENCODING SCHEME FOR UTF-16: 8-BIT (CESU-8)
  -- https://www.unicode.org/reports/tr26/tr26-4.html

  tablei = ""
  tableo = ""
  
  Call AssignCharacters "00","7F",ASCII      -- ASCII Chars
  Call AssignCharacters "80","BF","C"        -- Continuation character
  Call AssignCharacters "C0","C1","I"        -- Illegal character
  Call AssignCharacters "C2","DF","20"X      -- 2-byte sequences (1 continuation)
  Call AssignCharacters "E0","E0","3a"X      -- 3-byte sequences of subtype "a": 2nd byte in A0..BF. Manual check.
  Call AssignCharacters "E1","EC","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call AssignCharacters "ED","ED","3e"X      -- 3-byte sequences of subtype "e". 2nd byte in 80..9F, normal char; 
                                              -- in A0..AF, lead surrogate of a possible pair; in B0..BF, trail surrogate (ill-formed)
  Call AssignCharacters "EE","EF","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call AssignCharacters "F0","FF","I"        -- Illegal character

  .local["Unicode.CESU-8.tablei"] = tablei
  .local["Unicode.CESU-8.tableo"] = tableo

  -- MUTF-8
  --
  -- See https://en.wikipedia.org/wiki/UTF-8#Modified_UTF-8
  -- See https://docs.oracle.com/javase/specs/jvms/se16/html/jvms-4.html#jvms-4.4.7

  tablei = ""
  tableo = ""

  Call AssignCharacters "00","00","I"        -- "00"X is illegal in UTF8Z  
  Call AssignCharacters "01","7F",ASCII      -- ASCII Chars
  Call AssignCharacters "80","BF","C"        -- Continuation character
  Call AssignCharacters "C0","C0","0"        -- C080 --> "0000"U; C0xx --> illegal
  Call AssignCharacters "C1","C1","I"        -- Illegal character
  Call AssignCharacters "C2","DF","20"X      -- 2-byte sequences (1 continuation)
  Call AssignCharacters "E0","E0","3a"X      -- 3-byte sequences of subtype "a": 2nd byte in A0..BF. Manual check.
  Call AssignCharacters "E1","EC","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call AssignCharacters "ED","ED","3e"X      -- 3-byte sequences of subtype "e". 2nd byte in 80..9F, normal char; 
                                              -- in A0..AF, lead surrogate of a possible pair; in B0..BF, trail surrogate (ill-formed)
  Call AssignCharacters "EE","EF","3b"X      -- 3-byte sequences of subtype "b". 2 continuations.
  Call AssignCharacters "F0","FF","I"        -- Illegal character

  .local["Unicode.MUTF-8.tablei"] = tablei
  .local["Unicode.MUTF-8.tableo"] = tableo

Return  
  
AssignCharacters:
  use Arg from, to, value
  input = XRange(X2C(from), X2C(to))
  tablei ||= input
  tableo ||= Copies(value,Length(input))
Return      
