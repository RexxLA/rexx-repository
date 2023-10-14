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
/*  The normalization.rex build program                                      */
/*  ===================================                                      */
/*                                                                           */
/*  This program generates the binary data needed by                         */
/*    componentsproperties/normalization.cls.                                */      
/*                                                                           */
/*  See also tests/normalization.rex.                                        */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.4b JMB 20231014 Initial release. Implements toNFD                     */
/*                                                                           */
/*****************************************************************************/

  -- Inform our classes that we are building the .bin files, so that they don't
  -- complain that they are not there.
  
  .local~Unicode.Buildtime = 1

  -- Call instead of ::Requires allows us to set the above variable first.
  
  Call "Unicode.cls"
  
  self = .Unicode.Normalization
  
  super = self~superClass
  
  Say "Generating binary values for the Unicode.Normalization class..."

  Call Time "R"
  
  inFile = super~UCDFile.Qualify( self~UnicodeData )
  
  Call Stream inFile, "c", "query exists"
  
  If result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")

  canonicalCombiningClass = .MutableBuffer~new(Copies("00"X,2 * 2**16))  
  canonicalDoubleLast.    = 0
  canonicalDoubleFirst.   = 0
  canonicalDoubleFirsts   = .MutableBuffer~new
  canonicalDoubleLasts    = .MutableBuffer~new
  canonicalDouble         = .MutableBuffer~new(Copies("0000"X,2 * 2 * 2**16))
  CJK_2F800_2FA1D         = .MutableBuffer~new(Copies("000000"X, 2FA1D~X2D - 2F800~X2D + 1))
  CJK_F900_FAD9           = .MutableBuffer~new(Copies("000000"X, FAD9~X2D  - F900~X2D  + 1))

  -- ccc (the Canonical Combining Class) is always 0 for ranges such as Hangul Syllables
  -- The bigger codepoint such that ccc > 0 is 1E94A

  Do While Lines(inFile) > 0
    Parse Value LineIn(inFile) With code";" ";" ";"ccc ";" ";"decomp";"
    If ccc > 0 Then canonicalCombiningClass[X2D(code)+1] = X2C(D2X(ccc))
    If decomp = "" Then Iterate
    If Left(decomp,1) == "<" Then Iterate
    If Words(decomp) == 1 Then Do
      If Length(code) == 4, code[1] == "F", code >= F900, code <= FAD9 Then
        CJK_F900_FAD9[   3*(X2D(code) - X2D(F900 )) + 1, 3] = Right(X2C(decomp),3,"00"X)
      If Length(code) == 5, code[1,2] == "2F", code >>= 2F800, code <<= 2FA1D Then
        CJK_2F800_2FA1D[ 3*(X2D(code) - X2D(2F800)) + 1, 3] = Right(X2C(decomp),3,"00"X)
    End
    Else Do
      Parse Var decomp first last .
      If canonicalDoubleFirst.first == 0 Then Do
        canonicalDoubleFirst.0    += 1
        canonicalDoubleFirst.[canonicalDoubleFirst.0] = first
        canonicalDoubleFirst.first += canonicalDoubleFirst.0
        canonicalDoubleFirsts~append(Right(X2C(first),3,"00"X))
      End
      If canonicalDoubleLast.last == 0 Then Do
        canonicalDoubleLast.0    += 1
        canonicalDoubleLast.[canonicalDoubleLast.0] = last
        canonicalDoubleLast.last += canonicalDoubleLast.0
        canonicalDoubleLasts~append(Right(X2C(last),3,"00"X))
      End
      bin = canonicalDoubleLast.last * 512 + canonicalDoubleFirst.first
      canonicalDouble[2*X2D(code)+1,2] = Right(X2C(D2X(bin)),2,"00"X)
    End
  End
  
  Call Stream inFile, "c", "close"
  
  canonicalDouble       = canonicalDouble~string
  canonicalDoubleFirsts = canonicalDoubleFirsts~string
  canonicalDoubleLasts  = canonicalDoubleLasts ~string
  CJK_2F800_2FA1D       = CJK_2F800_2FA1D~string
  CJK_F900_FAD9         = CJK_F900_FAD9  ~string

  -- Chunk size should be coordinated with the property class of the same name in /components/properties

  v = .MultiStageTable~compress(canonicalDouble, 128)
  
  super~setPersistent("UnicodeData.normalization.canonicalDouble.Table1", v[1])
  super~setPersistent("UnicodeData.normalization.canonicalDouble.Table2", v[2])
  
  -- Chunk size should be coordinated with the property class of the same name in /components/properties
  
  v = .MultiStageTable~compress(canonicalCombiningClass, 64)

  super~setPersistent("UnicodeData.normalization.canonicalCombiningClass.Table1", v[1])
  super~setPersistent("UnicodeData.normalization.canonicalCombiningClass.Table2", v[2])
  
  super~setPersistent("UnicodeData.normalization.canonicalDoubleFirsts" , canonicalDoubleFirsts)
  super~setPersistent("UnicodeData.normalization.canonicalDoubleLasts"  , canonicalDoubleLasts)
  super~setPersistent("UnicodeData.normalization.CJK_2F800_2FA1D"       , CJK_2F800_2FA1D)
  super~setPersistent("UnicodeData.normalization.CJK_F900_FAD9"         , CJK_F900_FAD9)
  CJK_F900_FAD9

  super~SavePersistent( super~BinFile.Qualify( self~binaryFile ) )
  
  elapsed = Time("E")
  Say "Done, took" elapsed "seconds."