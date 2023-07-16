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
/*  The Unicode Jean-Louis Faucher demo                                      */
/*  ===================================                                      */
/*                                                                           */
/*  This demo file reproduces most of the tests included in the test set     */
/*  devised by Jean-Louis Faucher (see the URL below) and runs them using    */
/*  the Unicode Toys.                                                        */    
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Ver. Aut Date     Comments                                               */
/*  ---- --- -------- ------------------------------------------------------ */
/*  00.1 JMB 20230716 Initial release                                        */
/*                                                                           */
/*****************************************************************************/

noelemojiText = Text("noël👩‍👨‍👩‍👧🎅")

Say "Most of the tests found in"
Say "https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/code/expected_results"
Say
Say "There is only one test that fails. This is due to the fact that normalized" 
Say "comparisons are not yet implemented."
Say
Say 'center(Text("noël👩‍👨‍👩‍👧🎅"), 10) = "'center(Text("noël👩‍👨‍👩‍👧🎅"), 10)""" ("||(center(Text("noël👩‍👨‍👩‍👧🎅"), 10) == '  noël👩‍👨‍👩‍👧🎅  ')~?("OK", "KO")")"
Say 'center(Text("noël👩‍👨‍👩‍👧🎅"), 5) = "'center(Text("noël👩‍👨‍👩‍👧🎅"), 5)""" ("||(center(Text("noël👩‍👨‍👩‍👧🎅"), 5) == 'noël👩‍👨‍👩‍👧')~?("OK", "KO")")"
Say 'center(Text("noël👩‍👨‍👩‍👧🎅"), 3) = "'center(Text("noël👩‍👨‍👩‍👧🎅"), 3)""" ("||(center(Text("noël👩‍👨‍👩‍👧🎅"), 3) == 'oël')~?("OK", "KO")")"
Say 'center(Text("noël👩‍👨‍👩‍👧🎅"), 10, "═") = "'center(Text("noël👩‍👨‍👩‍👧🎅"), 10, "═")""" ("||(center(Text("noël👩‍👨‍👩‍👧🎅"), 10, "═") == '══noël👩‍👨‍👩‍👧🎅══')~?("OK", "KO")")"
Say 'copies(Text("́cafe"), 4) = "'copies(Text("́cafe"), 4)""" ("||(copies(Text("́cafe"), 4) == '́cafécafécafécafe')~?("OK", "KO")")"
Say 'Length(text("café")) = "'Length(text("café"))""" ("||(Length(text("café")) == 4)~?("OK", "KO")")"
Say 'Length(text("𝖼𝖺𝖿é")) = "'Length(text("𝖼𝖺𝖿é"))""" ("||(Length(text("𝖼𝖺𝖿é")) == 4)~?("OK", "KO")")"
Say 'Length(text("café")) = "'Length(text("café"))""" ("||(Length(text("café")) == 4)~?("OK", "KO")")"
Say 'Length(Text("noël👩‍👨‍👩‍👧🎅")) = "'Length(Text("noël👩‍👨‍👩‍👧🎅"))""" ("||(Length(Text("noël👩‍👨‍👩‍👧🎅")) == 6)~?("OK", "KO")")"
Say 'Length(Text("äöü äöü x̂ ϔ ﷺ baﬄe")) = "'Length(Text("äöü äöü x̂ ϔ ﷺ baﬄe"))""" ("||(Length(Text("äöü äöü x̂ ϔ ﷺ baﬄe")) == 18)~?("OK", "KO")")"
Say 'Pos(Text("café"), "é") = "'Pos(Text("café"), "é")""" ("||(Pos(Text("café"), "é") == 4)~?("OK", "KO")")"
Say 'Pos(Text("𝖼𝖺𝖿é"), "é") = "'Pos(Text("𝖼𝖺𝖿é"), "é")""" ("||(Pos(Text("𝖼𝖺𝖿é"), "é") == 4)~?("OK", "KO")")"
Say 'Pos(Text("café"), "é") = "'Pos(Text("café"), "é")""" ("||(Pos(Text("café"), "é") == 4)~?("OK", "KO")")"
Say 'substr(Text("noël👩‍👨‍👩‍👧🎅"), 3, 3) = "'substr(noelemojiText, 3, 3)""" ("||(substr(noelemojiText, 3, 3) == 'ël👩‍👨‍👩‍👧')~?("OK", "KO")")"
Say 'substr(Text("noël👩‍👨‍👩‍👧🎅"), 3, 6) = "'substr(noelemojiText, 3, 6)""" ("||(substr(noelemojiText, 3, 6) == 'ël👩‍👨‍👩‍👧🎅  ')~?("OK", "KO")")"
Say 'substr(Text("noël👩‍👨‍👩‍👧🎅"), 3, 6, "▷") = "'substr(noelemojiText, 3, 6, "▷")""" ("||(substr(noelemojiText, 3, 6, "▷") == 'ël👩‍👨‍👩‍👧🎅▷▷')~?("OK", "KO")")"

Exit

-- A series of internal routine to catch BIFs
Length: Procedure
  Use Strict Arg string
Return string~length

SubStr: Procedure
  .Validate~positiveWholeNumber( "n" , Arg(2) )
  Use Strict Arg string, n, length = (string~length - n + 1), pad = " "
  .Validate~classType( "pad" , pad , .String )
Return string~substr(n, length, pad)

Centre: Procedure
  Use Strict Arg string, n, pad = " "
  .Validate~nonNegativeWholeNumber( "n" , n )
Return string~centre(n, pad)

Center:
  Use Strict Arg string, n, pad = " "
  .Validate~nonNegativeWholeNumber( "n" , n )
Return string~center(n, pad)

Copies:
  Use Strict Arg string, n
  .Validate~nonNegativeWholeNumber( "n" , n )
Return string~copies(n)

Pos:
  Use Strict Arg string, needle, start = 1, length = (string~length - start + 1)
Return string~pos(needle, start, length)

::Requires Unicode.cls