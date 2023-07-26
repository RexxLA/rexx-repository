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
/*  gc.rex                                                                   */
/*  ======                                                                   */
/*                                                                           */
/*  Performs a consistency check on the properties implemented by            */
/*  properties/gc.cls.                                                       */
/*                                                                           */
/*  See also build/gc.rex.                                                   */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.2  JMB 20230725 Moved from properties/gc.cls                          */
/*                                                                           */
/*****************************************************************************/

  self = .Unicode.General_Category
  
  variables = self~variables
   
  nameOf. = "Cn"
  Do counter c variable over variables~makeArray( " " )
    char                           = x2c( d2x( c ) )
    Var2Char.[ Upper( variable ) ] = char
    nameOf.char                    = Left( variable, 2 )
    Call Value variable, char
  End
  
  Call Time "R"
  
  Say "Running consistency checks..."
  Say ""
  Say "Checking the 'General_Category' (gc) property for 1114112 codepoints..."
  
  inFile = self~UCDFile.Qualify( self~UnicodeData )
  
  Call Stream inFile,"C","Close"      -- Recovers if previous run crashed
  
  Call Stream inFile,"C","Open Read"
  
  last = -1
  count = 0
  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code1";"name";"gc";"
    If X2D(code1) \== last + 1 Then Do
      Do i = last + 1 To X2D(code1) - 1
        iCode = D2X(i)
        count += 1
        If self[iCode] \== "Cn" Then
          Say "Consistency check failed at codepoint 'U+"iCode"', got '"self[iCode]"', expected 'Cn'."
      End
    End
    If name~endsWith("First>") Then Do
      Parse Value LineIn(inFile) With code2";"
      Do i = X2D(code1) To X2D(code2)
        iCode = D2X(i)
        count += 1
        If self[iCode] \== gc Then
          Say "Consistency check failed at codepoint 'U+"iCode"', got '"self[iCode]"', expected '"gc"'."
      End
      last = i - 1
    End
    Else Do
      count += 1
      If self[code1] \== gc Then
        Say "Consistency check failed at codepoint 'U+"code1"', got '"self[code1]"', expected '"gc"'."
      last = X2D(code1)
    End
  End
  If last < 1114111 Then Do
    Do i = last + 1 To 1114111
      iCode = D2X(i)
      count += 1
      If self[iCode] \== "Cn" Then
        Say "Consistency check failed at codepoint 'U+"iCode"', got '"self[iCode]"', expected 'Cn'."
    End
  End
  
  Call Stream inFile,"C","Close"
  
  elapsed = Time("E")
  If elapsed = 0 Then elapsed = "0.001"
  
  Say count "codepoints checked in" elapsed "seconds."
  Say "This is" (count/elapsed) "codepoints/second."
  
::Requires "gc.cls"