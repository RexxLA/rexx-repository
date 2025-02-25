/* Rexx */





/******************************************************************************/
/*                                                                            */
/*                        THIS FILE HAS BEEN GENERATED                        */
/*                                                                            */
/*                   DO NOT EDIT - ALL CHANGES WILL BE LOST                   */
/*                                                                            */
/******************************************************************************/


/*
Script displaying some expected results for Unicode strings.
*/





/*
Temporary declarations to have BIFs forwarding to RexxText.
*/

/* A global routine with the same name as a builtin function overrides this function. */
.globalRoutines["C2X"] = .routines~c2x
.globalRoutines["CASELESSCOMPARE"] = .routines~caselessCompare      -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSCOMPARETO"] = .routines~caselessCompareTo  -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSENDSWITH"] = .routines~caselessEndsWith    -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSEQUALS"] = .routines~caselessEquals        -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSLASTPOS"] = .routines~caselessLastPos      -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSMATCH"] = .routines~caselessMatch          -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSMATCHCHAR"] = .routines~caselessMatchChar  -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSPOS"] = .routines~caselessPos              -- ooRexx BIM only, no BIF
.globalRoutines["CENTER"] = .routines~center
.globalRoutines["CENTRE"] = .routines~centre
.globalRoutines["COMPARE"] = .routines~compare
.globalRoutines["COMPARETO"] = .routines~compareTo                  -- ooRexx BIM only, no BIF
.globalRoutines["COPIES"] = .routines~copies
.globalRoutines["EQUALS"] = .routines~equals                        -- ooRexx BIM only, no BIF
.globalRoutines["ENDSWITH"] = .routines~endsWith                    -- ooRexx BIM only, no BIF
.globalRoutines["LENGTH"] = .routines~length
.globalRoutines["LEFT"] = .routines~left
.globalRoutines["LOWER"] = .routines~lower
.globalRoutines["MATCH"] = .routines~match                          -- ooRexx BIM only, no BIF
.globalRoutines["MATCHCHAR"] = .routines~matchChar                  -- ooRexx BIM only, no BIF
.globalRoutines["POS"] = .routines~pos
.globalRoutines["REVERSE"] = .routines~reverse
.globalRoutines["RIGHT"] = .routines~right
.globalRoutines["SUBCHAR"] = .routines~subChar
.globalRoutines["SUBSTR"] = .routines~substr
.globalRoutines["UPPER"] = .routines~upper

/*
No added value, Executor directly forward to String

.globalRoutines["C2D"] = .routines~c2d
.globalRoutines["HASHCODE"] = .routines~hashCode
.globalRoutines["X2B"] = .routines~x2b
.globalRoutines["X2C"] = .routines~x2c
.globalRoutines["X2D"] = .routines~x2d
*/




ok = 0
ko = 0

/******************************************************************************/
/* strings */
/******************************************************************************/

/* BMP only (no surrogate when UTF-16), no grapheme made of several codepoints */
s1 = "café"

    /*
    Codepoints
     1 : ( "c"   U+0063 Ll 1 "LATIN SMALL LETTER C" )
     2 : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
     3 : ( "f"   U+0066 Ll 1 "LATIN SMALL LETTER F" )
     4 : ( "é"   U+00E9 Ll 1 "LATIN SMALL LETTER E WITH ACUTE" )

    Graphemes
     1 : "c"
     2 : "a"
     3 : "f"
     4 : "é"
    */


/* Supplementary planes (surrogate pairs when UTF-16) */
s2 = "𝖼𝖺𝖿é"

    /*
    Codepoints
     1 : ( "𝖼"   U+1D5BC Ll 1 "MATHEMATICAL SANS-SERIF SMALL C" )
     2 : ( "𝖺"   U+1D5BA Ll 1 "MATHEMATICAL SANS-SERIF SMALL A" )
     3 : ( "𝖿"   U+1D5BF Ll 1 "MATHEMATICAL SANS-SERIF SMALL F" )
     4 : ( "é"   U+00E9 Ll 1 "LATIN SMALL LETTER E WITH ACUTE" )

    Graphemes
     1 : "𝖼"
     2 : "𝖺"
     3 : "𝖿"
     4 : "é"
    */


/* grapheme clusters */
s3 = "café"

    /*
    Codepoints
     1 : ( "c"   U+0063 Ll 1 "LATIN SMALL LETTER C" )
     2 : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
     3 : ( "f"   U+0066 Ll 1 "LATIN SMALL LETTER F" )
     4 : ( "e"   U+0065 Ll 1 "LATIN SMALL LETTER E" )
     5 : ( "́"    U+0301 Mn 0 "COMBINING ACUTE ACCENT" )

    Graphemes
     1 : T'c'
     2 : T'a'
     3 : T'f'
     4 : T'é'
    */


/* emoji */
s4 = "noël👩‍👨‍👩‍👧🎅"

    /*
    Codepoints
     1  : ( "n"   U+006E Ll 1 "LATIN SMALL LETTER N" )
     2  : ( "o"   U+006F Ll 1 "LATIN SMALL LETTER O" )
     3  : ( "ë"   U+00EB Ll 1 "LATIN SMALL LETTER E WITH DIAERESIS" )
     4  : ( "l"   U+006C Ll 1 "LATIN SMALL LETTER L" )
     5  : ( "👩"  U+1F469 So 2 "WOMAN" )
     6  : ( "‍"    U+200D Cf 0 "ZERO WIDTH JOINER", "ZWJ" )
     7  : ( "👨"  U+1F468 So 2 "MAN" )
     8  : ( "‍"    U+200D Cf 0 "ZERO WIDTH JOINER", "ZWJ" )
     9  : ( "👩"  U+1F469 So 2 "WOMAN" )
     10 : ( "‍"    U+200D Cf 0 "ZERO WIDTH JOINER", "ZWJ" )
     11 : ( "👧"  U+1F467 So 2 "GIRL" )
     12 : ( "🎅"  U+1F385 So 2 "FATHER CHRISTMAS" )

    Notice that 👩‍👨‍👩‍👧 constitute only 1 grapheme thanks to the ZERO WIDTH JOINER.
    Graphemes
     1 : "n"
     2 : "o"
     3 : "ë"
     4 : "l"
     5 : "👩‍👨‍👩‍👧"
     6 : "🎅"

    */


/* mix NFC NFD, ligature, expansion factor */
s5 = "äöü äöü x̂ ϔ ﷺ baﬄe"

    /*
    Codepoints
     1  : ( "ä"   U+00E4 Ll 1 "LATIN SMALL LETTER A WITH DIAERESIS" )
     2  : ( "ö"   U+00F6 Ll 1 "LATIN SMALL LETTER O WITH DIAERESIS" )
     3  : ( "ü"   U+00FC Ll 1 "LATIN SMALL LETTER U WITH DIAERESIS" )
     4  : ( " "   U+0020 Zs 1 "SPACE", "SP" )
     5  : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
     6  : ( "̈"    U+0308 Mn 0 "COMBINING DIAERESIS" )
     7  : ( "o"   U+006F Ll 1 "LATIN SMALL LETTER O" )
     8  : ( "̈"    U+0308 Mn 0 "COMBINING DIAERESIS" )
     9  : ( "u"   U+0075 Ll 1 "LATIN SMALL LETTER U" )
     10 : ( "̈"    U+0308 Mn 0 "COMBINING DIAERESIS" )
     11 : ( " "   U+0020 Zs 1 "SPACE", "SP" )
     12 : ( "x"   U+0078 Ll 1 "LATIN SMALL LETTER X" )
     13 : ( "̂"    U+0302 Mn 0 "COMBINING CIRCUMFLEX ACCENT" )
     14 : ( " "   U+0020 Zs 1 "SPACE", "SP" )
     15 : ( "ϔ"   U+03D4 Lu 1 "GREEK UPSILON WITH DIAERESIS AND HOOK SYMBOL" )
     16 : ( " "   U+0020 Zs 1 "SPACE", "SP" )
     17 : ( "ﷺ"   U+FDFA Lo 1 "ARABIC LIGATURE SALLALLAHOU ALAYHE WASALLAM" )
     18 : ( " "   U+0020 Zs 1 "SPACE", "SP" )
     19 : ( "b"   U+0062 Ll 1 "LATIN SMALL LETTER B" )
     20 : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
     21 : ( "ﬄ"   U+FB04 Ll 1 "LATIN SMALL LIGATURE FFL" )
     22 : ( "e"   U+0065 Ll 1 "LATIN SMALL LETTER E" )

    Graphemes
     1  : T'ä'
     2  : T'ö'
     3  : T'ü'
     4  : T' '
     5  : T'ä'
     6  : T'ö'
     7  : T'ü'
     8  : T' '
     9  : T'x̂'
     10 : T' '
     11 : T'ϔ'
     12 : T' '
     13 : T'ﷺ'
     14 : T' '
     15 : T'b'
     16 : T'a'
     17 : T'ﬄ'
     18 : T'e'

    Some remarks about this string:
    - the first "äöü" is NFC, the second "äöü" is NFD
    - "x̂" is two codepoints in any normalization.
    - "ϔ" normalization forms are all different.
    - "ﷺ" is one of the worst cases regarding the expansion factor in NFKS/NFKS: 18x
      "baﬄe": The ligature disappears in NFK[CD] but not in NF[CD]
    */


/* to test simple vs full case mapping */
s6 = "Bundesstraße im Freiland"

    /*
    Codepoints
         1  : ( "B"   U+0042 Lu 1 "LATIN CAPITAL LETTER B" )
         2  : ( "u"   U+0075 Ll 1 "LATIN SMALL LETTER U" )
         3  : ( "n"   U+006E Ll 1 "LATIN SMALL LETTER N" )
         4  : ( "d"   U+0064 Ll 1 "LATIN SMALL LETTER D" )
         5  : ( "e"   U+0065 Ll 1 "LATIN SMALL LETTER E" )
         6  : ( "s"   U+0073 Ll 1 "LATIN SMALL LETTER S" )
         7  : ( "s"   U+0073 Ll 1 "LATIN SMALL LETTER S" )
         8  : ( "t"   U+0074 Ll 1 "LATIN SMALL LETTER T" )
         9  : ( "r"   U+0072 Ll 1 "LATIN SMALL LETTER R" )
         10 : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
         11 : ( "ß"   U+00DF Ll 1 "LATIN SMALL LETTER SHARP S" )
         12 : ( "e"   U+0065 Ll 1 "LATIN SMALL LETTER E" )
         13 : ( " "   U+0020 Zs 1 "SPACE", "SP" )
         14 : ( "i"   U+0069 Ll 1 "LATIN SMALL LETTER I" )
         15 : ( "m"   U+006D Ll 1 "LATIN SMALL LETTER M" )
         16 : ( " "   U+0020 Zs 1 "SPACE", "SP" )
         17 : ( "F"   U+0046 Lu 1 "LATIN CAPITAL LETTER F" )
         18 : ( "r"   U+0072 Ll 1 "LATIN SMALL LETTER R" )
         19 : ( "e"   U+0065 Ll 1 "LATIN SMALL LETTER E" )
         20 : ( "i"   U+0069 Ll 1 "LATIN SMALL LETTER I" )
         21 : ( "l"   U+006C Ll 1 "LATIN SMALL LETTER L" )
         22 : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
         23 : ( "n"   U+006E Ll 1 "LATIN SMALL LETTER N" )
         24 : ( "d"   U+0064 Ll 1 "LATIN SMALL LETTER D" )

    Graphemes
         1  : T'B'
         2  : T'u'
         3  : T'n'
         4  : T'd'
         5  : T'e'
         6  : T's'
         7  : T's'
         8  : T't'
         9  : T'r'
         10 : T'a'
         11 : T'ß'
         12 : T'e'
         13 : T' '
         14 : T'i'
         15 : T'm'
         16 : T' '
         17 : T'F'
         18 : T'r'
         19 : T'e'
         20 : T'i'
         21 : T'l'
         22 : T'a'
         23 : T'n'
         24 : T'd'

    Unicode standard section 5.18 Case Mappings:
        Default casing                                         Tailored casing
        (small sharp) ß <--- ẞ (capital sharp)                 (small sharp) ß <--> ẞ (capital sharp)
        (small sharp) ß ---> SS
                     ss <--> SS                                             ss <--> SS
    When using the default Unicode casing operations, capital sharp s will lowercase
    to small sharp s, but not vice versa: small sharp s uppercases to “SS”.
    A tailored casing operation is needed in circumstances requiring small sharp s
    to uppercase to capital sharp s.
    */





/* Check that the right interpreter is used */


parse version v
if pos("REXX-ooRexx_4.3.0", v) == 0 then do
    error = "You are not using the Executor interpreter"
    call lineout "stdout", error
    call lineout "stdout", v
    call lineout "stderr", error
    call lineout "stderr", v
    exit 1
end




/******************************************************************************/
/* c2x */
/******************************************************************************/

say 'c2x("'s1'")'

actual = c2x(s1)

expected = "<TBD>"
say my_compare(actual, expected)
say

say 'c2x("'s2'")'

actual = c2x(s2)

expected = "<TBD>"
say my_compare(actual, expected)
say

say 'c2x("'s3'")'

actual = c2x(s3)

expected = "<TBD>"
say my_compare(actual, expected)
say

say 'c2x("'s4'")'

actual = c2x(s4)

expected = "<TBD>"
say my_compare(actual, expected)
say

say 'c2x("'s5'")'

actual = c2x(s5)

expected = "<TBD>"
say my_compare(actual, expected)
say


/******************************************************************************/
/* c2d */
/******************************************************************************/

say 'c2d("ë")'

actual = c2d("ë")

expected = "<TBD>"
say my_compare(actual, expected)
say


/* Error 93.936:  C2D result is not a valid whole number with NUMERIC DIGITS 9. */
numeric digits 10


say 'c2d("🎅")'

actual = c2d("🎅")

expected = "<TBD>"
say my_compare(actual, expected)
say


numeric digits



/******************************************************************************/
/* center */
/******************************************************************************/

say 'center("'s4'", 10)'
actual = center(s4, 10)
expected = "  noël👩‍👨‍👩‍👧🎅  "
say my_compare(actual, expected)
say

say 'center("'s4'", 5)'
actual = center(s4, 5)
expected = "noël👩‍👨‍👩‍👧"
say my_compare(actual, expected)
say

say 'center("'s4'", 3)'
actual = center(s4, 3)
expected = "oël"
say my_compare(actual, expected)
say


/******************************************************************************/
/* center with pad being 1 grapheme made of several bytes */
/******************************************************************************/

/*
Pad character "═"
'UTF-8 not-ASCII (3 bytes)'

Codepoints
 1 : ( "═"   U+2550 So 1 "BOX DRAWINGS DOUBLE HORIZONTAL" )

Graphemes
 1 : T'═'
*/

say 'center("'s4'", 10, "═")'

actual = center(s4, 10, "═")

expected = "══noël👩‍👨‍👩‍👧🎅══"
say my_compare(actual, expected)
say


/******************************************************************************/
/* copies */
/******************************************************************************/

s = "́cafe"

    /*
     1 : ( "́"    U+0301 Mn 0 "COMBINING ACUTE ACCENT" )
     2 : ( "c"   U+0063 Ll 1 "LATIN SMALL LETTER C" )
     3 : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
     4 : ( "f"   U+0066 Ll 1 "LATIN SMALL LETTER F" )
     5 : ( "e"   U+0065 Ll 1 "LATIN SMALL LETTER E" )
    */

say 'copies("'s'", 4)'
actual = copies(s, 4)
expected = "́cafécafécafécafe"
say my_compare(actual, expected)
say

    /*
     1  : ( "́"    U+0301 Mn 0 "COMBINING ACUTE ACCENT" )
     2  : ( "c"   U+0063 Ll 1 "LATIN SMALL LETTER C" )
     3  : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
     4  : ( "f"   U+0066 Ll 1 "LATIN SMALL LETTER F" )
     5  : ( "e"   U+0065 Ll 1 "LATIN SMALL LETTER E" )
     6  : ( "́"    U+0301 Mn 0 "COMBINING ACUTE ACCENT" )
     7  : ( "c"   U+0063 Ll 1 "LATIN SMALL LETTER C" )
     8  : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
     9  : ( "f"   U+0066 Ll 1 "LATIN SMALL LETTER F" )
     10 : ( "e"   U+0065 Ll 1 "LATIN SMALL LETTER E" )
     11 : ( "́"    U+0301 Mn 0 "COMBINING ACUTE ACCENT" )
     12 : ( "c"   U+0063 Ll 1 "LATIN SMALL LETTER C" )
     13 : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
     14 : ( "f"   U+0066 Ll 1 "LATIN SMALL LETTER F" )
     15 : ( "e"   U+0065 Ll 1 "LATIN SMALL LETTER E" )
     16 : ( "́"    U+0301 Mn 0 "COMBINING ACUTE ACCENT" )
     17 : ( "c"   U+0063 Ll 1 "LATIN SMALL LETTER C" )
     18 : ( "a"   U+0061 Ll 1 "LATIN SMALL LETTER A" )
     19 : ( "f"   U+0066 Ll 1 "LATIN SMALL LETTER F" )
     20 : ( "e"   U+0065 Ll 1 "LATIN SMALL LETTER E" )
    */


/******************************************************************************/
/* length */
/******************************************************************************/

say 'length("'s1'")'
actual = length(s1)
expected = 4
say my_compare(actual, expected)
say

say 'length("'s2'")'
actual = length(s2)
expected = 4
say my_compare(actual, expected)
say

say 'length("'s3'")'
actual = length(s3)
expected = 4
say my_compare(actual, expected)
say

say 'length("'s4'")'
actual = length(s4)
expected = 6
say my_compare(actual, expected)
say

say 'length("'s5'")'
actual = length(s5)
expected = 18
say my_compare(actual, expected)
say


/******************************************************************************/
/* pos */
/******************************************************************************/

say 'pos("é","'s1'")'
actual = pos("é", s1)
expected = 4
say my_compare(actual, expected)
say

say 'pos("é","'s2'")'
actual = pos("é",s2)
expected = 4
say my_compare(actual, expected)
say

say 'pos("é","'s3'")'
actual = pos("é",s3)
expected = 4               /* implies normalization when comparing */
say my_compare(actual, expected)
say


/******************************************************************************/
/* substr */
/******************************************************************************/

say 'substr("'s4'", 3, 3)'
actual = substr(s4, 3, 3)
expected = "ël👩‍👨‍👩‍👧"
say my_compare(actual, expected)
say

say 'substr("'s4'", 3, 6)'
actual = substr(s4, 3, 6)
expected = "ël👩‍👨‍👩‍👧🎅  "
say my_compare(actual, expected)
say


/******************************************************************************/
/* substr with pad being 1 grapheme made of several bytes */
/******************************************************************************/

/*
Pad character "▷"
'UTF-8 not-ASCII (3 bytes)'

Codepoints
 1 : ( "▷"   U+25B7 Sm 1 "WHITE RIGHT-POINTING TRIANGLE" )

Graphemes
 1 : T'▷'
*/

say 'substr("'s4'", 3, 6, "▷")'

actual = substr(s4, 3, 6, "▷")

expected = "ël👩‍👨‍👩‍👧🎅▷▷"
say my_compare(actual, expected)
say


/******************************************************************************/
/* x2c */
/******************************************************************************/






/* interpreter using byte encoding internally */
/* bytes for UTF-8 encoding */
say 'x2c("F09F8E85")'
actual = x2c("F09F8E85")
expected = "🎅"
say my_compare(actual, expected)
say



say "Ok =" ok
say "Ko =" ko

return


/******************************************************************************/
/* helpers */
/******************************************************************************/

/* Can't be named "compare" because of crexx, hence the name "my_compare" */

my_compare: procedure expose ok ko
    use strict arg actual, expected

    /* Error 23.900:  UTF-8 not-ASCII 'actual ...' cannot be converted to a String instance. */
    /* Must explicitely convert to string */
    say 'actual  :' "'"actual~string"'"
    say 'expected:' "'"expected~string"'"

    if actual == expected then do

        result = "Ok"
        ok = ok + 1
    end
    else do
        result = "Ko *****"
        ko = ko + 1
    end
    return result



/*
Temporary implementations to have BIFs forwarding to RexxText.
*/

::requires "extension/extensions.cls"

::routine C2X;               return "C2X"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSCOMPARE;   return "CASELESSCOMPARE"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSCOMPARETO; return "CASELESSCOMPARETO"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSENDSWITH;  return "CASELESSENDSWITH"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSEQUALS;    return "CASELESSEQUALS"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSLASTPOS;   return "CASELESSLASTPOS"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSMATCH;     return "CASELESSMATCH"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSMATCHCHAR; return "CASELESSMATCHCHAR"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSPOS;       return "CASELESSPOS"~doWith(arg(1)~text, .context~args~section(2))
::routine CENTER;            return "CENTER"~doWith(arg(1)~text, .context~args~section(2))
::routine CENTRE;            return "CENTRE"~doWith(arg(1)~text, .context~args~section(2))
::routine COMPARE;           return "COMPARE"~doWith(arg(1)~text, .context~args~section(2))
::routine COMPARETO;         return "COMPARETO"~doWith(arg(1)~text, .context~args~section(2))
::routine COPIES;            return "COPIES"~doWith(arg(1)~text, .context~args~section(2))
::routine EQUALS;            return "EQUALS"~doWith(arg(1)~text, .context~args~section(2))
::routine ENDSWITH;          return "ENDSWITH"~doWith(arg(1)~text, .context~args~section(2))
::routine LENGTH;            return "LENGTH"~doWith(arg(1)~text, .context~args~section(2))
::routine LEFT;              return "LEFT"~doWith(arg(1)~text, .context~args~section(2))
::routine LOWER;             return "LOWER"~doWith(arg(1)~text, .context~args~section(2))
::routine MATCH;             return "MATCH"~doWith(arg(1)~text, .context~args~section(2))
::routine MATCHCHAR;         return "MATCHCHAR"~doWith(arg(1)~text, .context~args~section(2))
::routine POS;               args = .context~args; args[2] = args[1]; return "POS"~doWith(arg(2)~text, args~section(2))
::routine REVERSE;           return "REVERSE"~doWith(arg(1)~text, .context~args~section(2))
::routine RIGHT;             return "RIGHT"~doWith(arg(1)~text, .context~args~section(2))
::routine SUBCHAR;           return "SUBCHAR"~doWith(arg(1)~text, .context~args~section(2))
::routine SUBSTR;            return "SUBSTR"~doWith(arg(1)~text, .context~args~section(2))
::routine UPPER;             return "UPPER"~doWith(arg(1)~text, .context~args~section(2))

/*
No added value, Executor directly forward to String

::routine C2D;               return "C2D"~doWith(arg(1)~text, .context~args~section(2))
::routine HASHCODE;          return "HASHCODE"~doWith(arg(1)~text, .context~args~section(2))
::routine X2B;               return "X2B"~doWith(arg(1)~text, .context~args~section(2))
::routine X2C;               return "X2C"~doWith(arg(1)~text, .context~args~section(2))
::routine X2D;               return "X2D"~doWith(arg(1)~text, .context~args~section(2))
*/


/*
Remember: the BIF where self is the 2nd arg, not the 1st.
changeStr
countStr
lastPos
pos
wordPos
*/


