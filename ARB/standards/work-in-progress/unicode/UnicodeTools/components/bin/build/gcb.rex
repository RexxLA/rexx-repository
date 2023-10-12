/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

/*****************************************************************************/
/*                                                                           */
/*  The gcb.rex build program                                                */
/*  =========================                                                */
/*                                                                           */
/*  This program generates the binary data needed by properties/gcb.cls.     */
/*                                                                           */
/*  See also tests/gcb.rex.                                                  */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.2  JMB 20230725 Moved from properties/gcb.cls                         */
/*                                                                           */
/*****************************************************************************/

  -- Inform our classes that we are building the .bin files, so that they don't
  -- complain that they are not there.
  
  .local~Unicode.Buildtime = 1

  -- Call instead of ::Requires allows us to set the above variable first.

  Call "Unicode.cls"

  self = .Unicode.Grapheme_Cluster_Break
  
  super = self~superClass

  variables = self~variables
  
  Do counter c variable over variables~makeArray( " " )
    char = X2C( D2X( c ) )
    nameOf.char = variable
    Call Value variable, char -- Creates a new instance variable (because of use local)
  End
  
  Call Time "R"
  
  Say "Generating binary file..."

  buffer = .MutableBuffer~new( Copies( Other, X2D( 20000 ) ) )

  inFile = super~UCDFile.Qualify( self~GraphemeBreakProperty )

  Call Stream inFile, "c", "Query exist"

  If result == "" Then self~SyntaxError("File '"inFile"' does not exist")
  
  Call Stream inFile, "C", "Open Read"

  Do While Lines(infile)
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";"value "#"
    value = Strip(value)
    codes = Strip(codes)
    If Pos("..", codes) > 0 Then Do
      Parse Var codes min".."max
      -- We handle Ehhhh programmatically
      If Length(min) == 5, min[1] == "E" Then Iterate
    End
    Else Do
      If Length(codes) == 5, codes[1] == "E" Then Iterate
      min = codes
      max = codes
    End
    value = Value(value)
    Do i = X2D(min) To X2D(max)
      buffer[i+1] = value
    End
  End
  
  Call Stream inFile, "C", "Close"
  
  -- The "Extended_Pictographic" property is on another file
  
  inFile = super~UCDFile.Qualify( self~Emoji_data )

  Call Stream inFile, "c", "Query exist"

  If result == "" Then self~SyntaxError("File '"inFile"' does not exist")
  
  Call Stream inFile, "C", "Open Read"

  Do While Lines(infile)
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";"value "#"
    value = Strip(value)
    If value \== "Extended_Pictographic" Then Iterate
    codes = Strip(codes)
    If Pos("..", codes) > 0 Then
      Parse Var codes min".."max
    Else Do
      min = codes
      max = codes
    End
    value = Value(value)
    Do i = X2D(min) To X2D(max)
      If Buffer[i+1] \== Other Then self~syntaxError( "Error! Codepoint" d2x(i) "is not 'Other'. Cannot assign 'Extended_Pictographic'" )
      buffer[i+1] = Extended_Pictographic
    End
  End
  
  Call Stream inFile, "C", "Close"

  -- And, still, the ccc property is on another file
  
  inFile = super~UCDFile.Qualify( self~UnicodeData )
 
  Call Stream inFile, "c", "Query exist"

  If result == "" Then self~SyntaxError("File '"inFile"' does not exist")
  
  Call Stream inFile, "C", "Open Read"

  Do While Lines(infile)
    Parse Value LineIn(infile) With code";"name";" ";"ccc";"
    If ccc == 0 Then Iterate
    If name~endsWith("First>") Then Do
      Parse Value LineIn(infile) With code2";"
      Do i = X2D(code) To X2D(code2)
        If buffer[i+1] == Extend Then Do
          Extend2ExtCccZwj.[i] = 1
          buffer[i+1] = Extend_ExtCccZwj
        End
      End
    End
    Else If buffer[X2D(code)+1] == Extend Then Do
      Extend2ExtCccZwj.[X2D(code)] = 1
      buffer[X2D(code)+1] = Extend_ExtCccZwj 
    End
  End
  
  Call Stream inFile, "C", "Close"
  
  array = .MultiStageTable~compress(buffer)
  
  super~setPersistent("GraphemeBreakProperty.gcb.Table1", array[1])
  super~setPersistent("GraphemeBreakProperty.gcb.Table2", array[2])

  super~SavePersistent( super~BinFile.Qualify( self~binaryFile ) )
  
  elapsed = Time("E")
  Say "Done, took" elapsed "seconds."