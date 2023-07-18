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
/*  The Unicode Demo                                                         */
/*  ================                                                         */
/*                                                                           */
/*  This is a low-level demo program. It tests the basic funcionality of     */
/*  several basic classes. In particular it (re-)generates the binary files  */
/*  that allow the functioning of these classes, it runs a series of         */
/*  self-tests, and then tests some of the basic functionality for these     */
/*  classes.                                                                 */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1  JMB 20230716 Initial release                                       */
/*  00.1a JMB 20230717 Move to "demo" subdir                                 */
/*  00.1c JMB 20230718 Move property classes to the "property" subdir        */
/*                     Fix some bugs, add consistency check for names        */
/*                                                                           */
/*****************************************************************************/

Say "Testing the base functionality for:"
Say
Say "  Class Unicode.General_Category"
Say "  Class Unicode.Name"
Say "  Class Unicode.Grapheme_Cluster_Break"
Say

Call NextTest "Regenerating the binary files..."

.Unicode.General_Category~generate
.Unicode.Grapheme_Cluster_Break~generate

Call NextTest "Performing self-tests (this will take some time)..."

.Unicode.General_Category~Consistency_Check
.Unicode.Name~Consistency_Check
.Unicode.Grapheme_Cluster_Break~Consistency_Check

Call NextTest "Testing the General_Category (gc) property for a number of codepoints..."

Do code over "0000 0010 001F 0020 0110 0210 1210 200F 8010 18010 1A010 1F010 10FFFD 10FFFE"~makeArray(" ")
  Say code Unicode(code ,"property","general category")
End

Call NextTest "Testing several algorithmically-generated names"

Do code over "8010 FA10 FA11 ACBA 18AFF"~makeArray(" ")
  Say code Unicode(code, "p", "algorithmic name")
End

Call NextTest "Testing the Grapheme_Cluster_Break property"

Do code over "0020 0000 000D 034F 0308 1F1E5 1100 000A AC00 D5E5 0600 1F1E6 1734 11A8 1160 200D"~makeArray(" ")
  Say Right(code,6) Unicode(code, "prop", "Grapheme cluster break")
End

Say

Exit

NextTest:
  Say
  Say "Press ENTER to continue"
  Parse pull
  Say Arg(1)
  Say
Return  

::Requires "../Unicode.cls"
::Requires "../properties/Unicode.Name.cls"
