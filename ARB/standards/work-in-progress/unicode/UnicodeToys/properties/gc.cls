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
/*  The UNICODE.GENERAL_CATEGORY class                                       */
/*  ==================================                                       */
/*                                                                           */
/*  This class implements a primitive that maps a codepoint to its           */
/*  Unicode General_Category (gc) property. The property is returned in      */
/*  character form, i.e., for U+0061, "a", it returns the string "Ll",       */
/*  (Lowercase Letter), not a codified enumeration integer.                  */
/*                                                                           */
/*  The class includes also services to handle algorithically computable     */
/*  Unicode names, for example Hangul syllabes or CJK ideographs, and        */
/*  also labels for codes that do not have a name, like control characters,  */
/*  surrogates, reserved codepoints, etc.                                    */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1  JMB 20230716 Initial release                                       */
/*  00.1a JMB 20230717 Move UCD files to the UCD subdirectory                */
/*  00.1c JMB 20230718 Move property classes to the "property" subdir        */
/*                     Fix some bugs, add consistency check for names        */
/*  00.2  JMB 20230725 Rename classfile to 'gc.cls'                          */
/*                                                                           */
/*****************************************************************************/

--
-- Running this file (or ::requiring it) will generate the binary
-- file if not present.
--

--------------------------------------------------------------------------------
--                                                                            --
-- CLASS UNICODE.General_Category                                             --
--                                                                            --
-- Implements the General_Category property.                                  --
--                                                                            --
-- As a bonus, it includes a method that returns the Name property,           --
-- when that property is algorithmically computable.                          --
--                                                                            --
--------------------------------------------------------------------------------

::Class Unicode.General_Category Public SubClass Unicode.Property

::Constant Variables   "Lu Ll Lt Lm Lo Lo_CJK_Compatibility_Ideograph Lo_CJK_Unified_Ideograph Lo_Hangul_Syllabe Lo_Khitan_Small_Script Lo_Tangut_Component Lo_Tangut_Ideograph Mn Mc Me Nd Nl No Pc Pd Ps Pe Pi Pf Po Sm Sc Sk So Zs Zl Zp Cc Cf Cs Co Cn"
::Constant BinaryFile  "General_Category.bin"  

::Attribute Lo_CJK_Compatibility_Ideograph Class Get
::Attribute Lo_CJK_Unified_Ideograph       Class Get
::Attribute Lt                             Class Get
 
::Method hexValueOfPropertyAt Class
  Use Local -- Should be "Expose BinaryString (variables)", but it is slow
  
  Use Strict Arg code

  n = code~x2d
  
  -- Fast path: Planes 0 & 1
  If n <= 131071 Then
    Return self~TwoStageTable.getByteFromIntAt("UnicodeData.gc",n)
  
  Select Case Length(code)
    When 5 Then Do
      Select Case code[1]
        When "2" Then Do
          If              n <= 173791 Then Return Lo_CJK_Unified_Ideograph -- 20000 2A6DF
          If n >= 173824, n <= 177977 Then Return Lo_CJK_Unified_Ideograph -- 2A700 2B739
          If n >= 177984, n <= 178205 Then Return Lo_CJK_Unified_Ideograph -- 2B740 2B81D
          If n >= 178208, n <= 183969 Then Return Lo_CJK_Unified_Ideograph -- 2B820 2CEA1
          If n >= 183984, n <= 191456 Then Return Lo_CJK_Unified_Ideograph -- 2CEB0 2EBE0
          If n >= 194560, n <= 195101 Then Return Lo_CJK_Unified_Ideograph -- 2F800 2FA1D
        End
        When "3" Then Do
          If              n <= 201546 Then Return Lo_CJK_Unified_Ideograph -- 30000..3134A
          If n >= 201552, n <= 205743 Then Return Lo_CJK_Unified_Ideograph -- 31350..323AF
        End
        When "E" Then Do
          If n == 917505              Then Return Cf                       -- E0001
          If n >= 917536, n <= 917631 Then Return Cf                       -- E0020..E007F
          If n >= 917760, n <= 917999 Then Return Mn                       -- E0100..E01EF
        End
        When "F" Then
          If n <= 1048573             Then Return Co                       -- FFFFD
        Otherwise Return Cn
      End
    End
    When 6 Then
          If n <= 1114109             Then Return Co                       -- 10FFFD
    Otherwise Return Cn
  End
  Return Cn

--
-- Activate is automatically called at the end of class initialization.
--
-- First, we generate a set of global variables (shared using an
-- empty "Use Local" instruction). 
--
-- We next check whether the binary file exists; 
-- if it does not exist, we call the "Generate" method
-- to build it. 
--
-- Finally, we load the two-stage table in memory (the "bin" string).
-- 
 
::Method Activate Class
  Use Local c char variable
  -- Should be "Expose (variables) etc.", but the variables are not constructed yet.
    
  self~activate:super
  
  variables = self~variables
   
  nameOf. = "Cn"
  Do counter c variable over variables~makeArray( " " )
    char                           = x2c( d2x( c ) )
    Var2Char.[ Upper( variable ) ] = char
    nameOf.char                    = Left( variable, 2 )
    Call Value variable, char
  End
  
  self~nameOf = nameOf.
  
  If .Unicode.Buildtime \== 1 Then 
    self~loadPersistent( self~BinFile.Qualify( self~binaryFile ) ) 
    
::Method Algorithmic_Name Class
  Use Local -- Should be "Expose (variables)", but it is too slow
  Use Strict Arg code
  code = Upper(code)
  Select Case self~hexValueOfPropertyAt(code)
    When Lo_CJK_Compatibility_Ideograph Then Return "CJK COMPATIBILITY IDEOGRAPH-"code
    When Lo_CJK_Unified_Ideograph       Then Return "CJK UNIFIED IDEOGRAPH-"code
    When Lo_Hangul_Syllabe              Then Return "HANGUL SYLLABE" Hangul_Syllabe_Name(code)
    When Lo_Khitan_Small_Script         Then Return "KHITAN SMALL SCRIPT CHARACTER-"code
    When Lo_Tangut_Component            Then Return "TANGUT COMPONENT-"Right(X2D(code) - X2D(18800)+1,3,0)
    When Lo_Tangut_Ideograph            Then Return "TANGUT IDEOGRAPH-"code
    When Cc                             Then Return "<control-"code">"
    When Co                             Then Return "<private-use-"code">"
    When Cn                             Then Do
      If WordPos( Right(code,4), "FFFE FFFF") > 0 Then
                                             Return "<noncharacter-"code">"
      n = X2D( code )
      If n >= 64976, n <= 65007         Then -- code in U+FDD0..U+FDEF 
                                             Return "<noncharacter-"code">"
      Return "<reserved-"code">"
    End
    When Cs                             Then Return "<surrogate-"code">"
    Otherwise                                Return ""
  End
  
Hangul_Syllabe_Code2LVT: Procedure
  Use Strict Arg code
  n = X2D(code)
  -- See http://gernot-katzers-spice-pages.com/var/korean_hangul_unicode.html
  tail  = (n - 44032) // 28 
  vowel = 1 + ( (n - 44032 - tail) // 588 ) / 28
  Parse Value (n - 44032 - tail) / 588 With t"."
  lead  = 1 + t
  Return lead vowel tail
  
Hangul_Syllabe_Name: Procedure
  Use Strict Arg code
  Parse Value Hangul_Syllabe_Code2LVT(code) With lead vowel tail
  lead  = ChangeStr("_",Word("G GG N D DD R M B BB S SS _ J JJ C K T P H",lead),"")        
  vowel = Word("A AE YA YAE EO E YEO YE O WA WAE OE YO U WEO WE WI YU EU YI I", vowel)        
  If tail == 0 Then tail = ""
  Else
    tail = Word("G GG GS N NJ NH D L LG LM LB LS LT LP LH M B BS S SS NG J C K T P H", tail)
  Return Space(lead vowel tail,0)
  
::Method Algorithmic_Code Class  
  Use Strict Arg name -- Name is supposed to be uppercased and compressed
    
  If name == "HANGULJUNGSEONGO-E" Then Return "1180" -- Special case
  If name[1] == "<" Then Signal Label                -- This is a label, not a name
  
  Do word Over "CJKCOMPATIBILITYIDEOGRAPH CJKUNIFIEDIDEOGRAPH KHITANSMALLSCRIPTCHARACTER TANGUTIDEOGRAPH"~makeArray(" ")
    If name~startsWith(word) Then Do
      code = SubStr(name,length(word)+1)
      Return CheckValid(code)
    End
  End
   
  start = "TANGUTCOMPONENT"
  If name~startsWith(start) Then Do
    number = SubStr(name,Length(start)+1)
    If \DataType(number, "W") Then Return ""
    If Length(number) \== 3   Then Return ""
    If number < 1             Then Return ""
    If number > 768           Then Return ""
    Return d2x(number + 6272 - 1)
  End

  start = "HANGULSYLLABE"
  If \name~startsWith(start) Then Return ""
  syllabeName = SubStr(name,Length(start)+1)
  
  Return Hangul_Syllabe_Code(syllabeName)
  
Label:
  Parse Var name "<"token">"extra
  If extra \== "" Then Return ""
  Do word Over "CONTROL PRIVATEUSE RESERVED SURROGATE NONCHARACTER"~makeArray(" ")
    If token~startsWith(word) Then Do
      code = SubStr(token,length(word)+1)
      Return CheckValid(code)
    End
  End
Return ""  

CheckValid:
  If \DataType(code,"X")              Then Return ""
  If Length(code) < 4                 Then Return ""
  If Length(code) > 6                 Then Return ""
  If Length(code) > 4, code[1] == "0" Then Return ""
  If X2D(code) > 1114111              Then Return ""
Return code  

Hangul_Syllabe_Code:
  -- See http://gernot-katzers-spice-pages.com/var/korean_hangul_unicode.html
  Use Strict Arg syllabe
  s1 = syllabe[1]
  s2 = syllabe[1,2]
  leadW = 2
  Select Case s2
    When "GG" Then lead =  2
    When "DD" Then lead =  5
    When "BB" Then lead =  9
    When "SS" Then lead = 11
    When "JJ" Then lead = 14
    Otherwise 
      leadW = 1
      Select Case s1
        When "G" Then lead =  1
        When "N" Then lead =  3
        When "D" Then lead =  4
        When "R" Then lead =  6
        When "M" Then lead =  7
        When "B" Then lead =  8
        When "S" Then lead =  10
        When "J" Then lead =  13
        When "C" Then lead =  15
        When "K" Then lead =  16
        When "T" Then lead =  17
        When "P" Then lead =  18
        When "H" Then lead =  19
        Otherwise
          lead  = 12
          leadW = 0
      End
  End
  s1 = syllabe[1+leadW]
  s2 = syllabe[1+leadW,2]
  s3 = syllabe[1+leadW,3]
  vowelW = 3
  Select Case s3
    When "YAE" Then vowel = 4
    When "YEO" Then vowel = 7
    When "WAE" Then vowel = 11
    When "WEO" Then vowel = 15
    Otherwise
      vowelW = 2
      Select Case s2
        When "AE" Then vowel =  2
        When "YA" Then vowel =  3
        When "EO" Then vowel =  5
        When "YE" Then vowel =  8
        When "WA" Then vowel = 10
        When "OE" Then vowel = 12
        When "YO" Then vowel = 13
        When "WE" Then vowel = 16
        When "WI" Then vowel = 17
        When "YU" Then vowel = 18
        When "EU" Then vowel = 19
        When "YI" Then vowel = 20
        Otherwise
          vowelW = 1
          Select Case s1
            When "A" Then vowel = 1
            When "E" Then vowel = 6
            When "O" Then vowel = 9
            When "U" Then vowel = 14
            When "I" Then vowel = 21
            Otherwise Return ""
          End
      End
  End
  rest = SubStr(syllabe,1+leadW+vowelW)
  Select Case rest
    When ""   Then tail =  0
    When "G"  Then tail =  1
    When "GG" Then tail =  2
    When "GS" Then tail =  3
    When "N"  Then tail =  4
    When "NJ" Then tail =  5
    When "NH" Then tail =  6
    When "D"  Then tail =  7
    When "L"  Then tail =  8
    When "LG" Then tail =  9
    When "LM" Then tail = 10
    When "LB" Then tail = 11
    When "LS" Then tail = 12
    When "LT" Then tail = 13
    When "LP" Then tail = 14
    When "LH" Then tail = 15
    When "M"  Then tail = 16
    When "B"  Then tail = 17
    When "BS" Then tail = 18
    When "S"  Then tail = 19
    When "SS" Then tail = 20
    When "NG" Then tail = 21
    When "J"  Then tail = 22
    When "C"  Then tail = 23
    When "K"  Then tail = 24
    When "T"  Then tail = 25
    When "P"  Then tail = 26
    When "H"  Then tail = 27
    Otherwise Return ""
  End
Return d2x( tail + (vowel-1)*28 + (lead-1)*588 + 44032 )  

::Requires "properties.cls"