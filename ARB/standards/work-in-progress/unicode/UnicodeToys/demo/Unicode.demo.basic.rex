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
/*  The Unicode Basic demo                                                   */
/*  ======================                                                   */
/*                                                                           */
/*  This demo file tests the basic working of the three string classes       */
/*  (i.e., Bytes [.String], Runes and Text), and the conversions             */
/*  between them.                                                            */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1  JMB 20230716 Initial release                                       */
/*  00.1a JMB 20230717 Move to "demo" subdir                                 */
/*                                                                           */
/*****************************************************************************/

Say "Testing basic operations and conversions"
Say "----------------------------------------"
Say
Say "Test number 1: a UTF8 Bytes string (.String)"
Say 
string = "noël👩‍👨‍👩‍👧🎅"  
Say "string = '"string"'"
Say "Length(string) =" Length(string)
Say "StringType(string) = '"StringType(string)"'"
Say "Elements of '"string"':"
Do i = 1 To Length(string) % 2
  Say Right(i,2)":" SubStr(string,i,1) "('"C2X(SubStr(string,i,1))"'X)" Right(i+17,2)":" SubStr(string,i+17,1) "('"C2X(SubStr(string,i+17,1))"'X)"
End

Say
Say "Press ENTER to continue"
Parse pull

Say "Test number 2: a Runes string (composed of codepoints)"
Say

string = Runes("noël👩‍👨‍👩‍👧🎅")
Say "string = Runes('"string"')"
Say "Length(string) =" Length(string)
Say "StringType(string) = '"StringType(string)"'"
Say "Elements of '"string"':"
Do i = 1 To Length(string)
  Say Right(i,2)":" SubStr(string,i,1) "('"C2X(SubStr(string,i,1))"'X)"
End
Say "AllRunes(string) = '"AllRunes(string)"'"

Say
Say "Press ENTER to continue"
Parse pull

Say "Test number 3: a Text string (composed of extended grapheme clusters)"
Say

string = Text("noël👩‍👨‍👩‍👧🎅")
Say "string = Text('"string"')"
Say "Length(string) =" Length(string)
Say "StringType(string) = '"StringType(string)"'"
Say "Elements of '"string"':"
Do i = 1 To Length(string)
  Say Right(i,2)":" SubStr(string,i,1) "('"C2X(SubStr(string,i,1))"'X)"
End
Say "AllRunes(string) = '"AllRunes(string)"'"

Say
Say "Press ENTER to continue"
Parse pull

Say "Test number 4: converting a Text to Runes"
Say

string = Runes(string)
Say "string = Runes('"string"')  -- Text to Runes"
Say "Length(string) =" Length(string)

Say
Say "Press ENTER to continue"
Parse pull

Say "Test number 5: converting a Runes to Bytes"
Say

string = Bytes(string)
Say "string = Bytes('"string"')  -- Runes to Bytes (String)"
Say "Length(string) =" Length(string)

Say
Say "Press ENTER to continue"
Parse pull

Say "Test number 6: converting Text to Bytes"
Say

string = Bytes(Text("noël👩‍👨‍👩‍👧🎅"))
Say "string = Bytes(Text('"||'noël👩‍👨‍👩‍👧🎅'"')  -- Text to Bytes (String)"
Say "Length(string) =" Length(string)

Exit
--------------------------------------------------------------------------------
-- A series of internal routine to catch BIFs                                 --
--------------------------------------------------------------------------------

Length: Procedure
  Use Strict Arg string
Return string~length

SubStr: Procedure
  .Validate~positiveWholeNumber( "n" , Arg(2) )
  Use Strict Arg string, n, length = (string~length - n + 1), pad = " "
  .Validate~classType( "pad" , pad , .String )
Return string~substr(n, length, pad)

::Requires "../Unicode.cls"
