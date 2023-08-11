/*****************************************************************************/
/*                                                                           */
/*  The UNICODE Tools for ooRexx                                             */
/*  ============================                                             */
/*                                                                           */
/*  Copyright (c) 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>     */
/*                                                                           */
/*  See https://github.com/RexxLA, rexx-repository,                          */
/*      path ARB/standards/work-in-progress/unicode/UnicodeTools             */
/*                                                                           */
/*  License: Apache License 2.0 https://www.apache.org/licenses/LICENSE-2.0  */
/*                                                                           */
/*                                                                           */
/*  gc.rex                                                                   */
/*  ======                                                                   */
/*                                                                           */
/*  Performs a consistency check on the properties implemented by            */
/*  properties/name.cls.                                                     */
/*                                                                           */
/*  See also build/name.rex.                                                 */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.2  JMB 20230725 Moved from properties/name.cls                        */
/*                                                                           */
/*****************************************************************************/


  self = .Unicode.Name

  Call Time "R"

  Say "Running consistency checks..."
  Say "" 
  Say "Checking the 'Name' ('na') property for 1114112 codepoints..."

  Do i = 0 To X2D(10FFFF)
    code = d2x(i)
    If i // 100000 = 0 Then Say i "codepoints checked..."
    If Length(code) < 4 Then code = Right(code,4,0)
    Else If code[1] == "0" Then code = Strip(code, "L",0)
    If code == N2P(P2N(code)) Then Iterate
    Say "Consistency check failed at:" code
    Parse pull
  End

  count = i - 1
  elapsed = Time("E")
  If elapsed = 0 Then elapsed = "0.001"
  
  Say count "codepoints checked in" elapsed "seconds."
  Say "This is" (count/elapsed) "codepoints/second."

::Requires "name.cls"