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
  
  outFile = super~BinFile.Qualify( self~PrimaryComposite )
  
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

  super~SavePersistent( super~BinFile.Qualify( self~binaryFile ) )
    
  Say "Generating arrays for the Canonical Composition Algorithm..."
  
  Call SysFileDelete outFile

  Call LineOut outFile, "-- This file is automatically generated by the build processes (/components/bin/build/normalization.rex)."
  Call LineOut outFile, "-- ALL CHANGES WILL BE LOST"
  Call LineOut outFile, ""
  Call LineOut outFile, "Use Strict Arg PrimaryCompositeLastSuffixes, PrimaryCompositeFirstPrefixes, PrimaryCompositeFirstSuffix"
  Call LineOut outFile, ""

  Lasts.  = 0

  Call Stream inFile, "c", "Open Read"

  -- https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf, p. 139.
  --
  -- "D114 Primary composite: A Canonical Decomposable Character (D69) which is not a Full
  -- Composition Exclusion."
  --
  -- "D115 Blocked: Let A and C be two characters in a coded character sequence <A, ... C>. C is
  --  blocked from A if and only if ccc(A) = 0 and there exists some character B between A
  --  and C in the coded character sequence, i.e., <A, ... B, ... C>, and either ccc(B) = 0 or
  --  ccc(B) >= ccc(C)."
  --
  -- "• Because the Canonical Composition Algorithm operates on a string which is
  --  already in canonical order, testing whether a character is blocked requires
  --  looking only at the immediately preceding character in the string."
  --
  -- Assume that ccc(C) == 0. The only possibility to combine is that L is the previous
  -- character and there exists a Primary Composite P which is canonically equivalent to <L,C>.
  --

  PrimaryComposite. = ""
  LastMin. = "FFFFF"
  LastMax. = "00000"
  Do While Lines(inFile) > 0
    Parse Value LineIn(inFile) With code";" ";" ";" ccc";" ";"decomp";"
    If code[1] == "<", ccc > 0 Then Pull
    If decomp     = "" Then Iterate
    If decomp[1] == "<" Then Iterate
    If Unicode(code,"Property","Full_Composition_Exclusion") Then Iterate
    Parse Var decomp first last .
    first = Right(first,6,0)
    last = Right(last,6,0)
  
    If Lasts.last   == 0 Then Do
      Lasts.last    += 1
      Lasts.0       += 1
    End
    
    If PrimaryComposite.last = "" Then
      PrimaryComposite.last = .StringTable~new
    PrimaryComposite.last[first] = Right(code,6,0)
    lastPrefix = Left(last,4)
    If last < LastMin.lastPrefix Then LastMin.lastPrefix = last
    If last > LastMax.lastPrefix Then LastMax.lastPrefix = last
  
  End

  Call Stream inFile, "c", "close"

  -- Max(Left(Right(last,5,0),3)) == "119"
  activeLastPrefix = .MutableBuffer~new(Copies("00"X, "11A"~X2d))

  MinMax = ""

  seen. = 0
  lastCount = 0
  accum = 1
  Do ix Over lasts.~allIndexes~sort
    If ix == "0" Then Iterate
    lastPrefix = Left(ix,4)
    If seen.lastPrefix Then Iterate
    seen.lastPrefix = 1
    lastCount += 1
    endings = ""
    Do n = LastMin.lastPrefix~x2d To LastMax.lastPrefix~x2d
      code = Right(n~d2x,6,0)
      If lasts.~hasIndex(code) Then endings ||= Right(code,2)
    End
    Call LineOut outFile, "PrimaryCompositeLastSuffixes["lastPrefix"~x2d] = '"D2X(lastCount,2)" "endings"'X"
    PrimaryCompositeFirstPrefixesArrayCreated = 0
    Do i = 0 To length(endings)/2-1
      code = lastPrefix||endings[2*i+1,2] 
      firstPrefixSeen. = 0
      firstSuffixSeen. = 0
      firstPrefixes = ""
      same = 1
      zeros = 1
      firstsuffixes = ""
      Do first over PrimaryComposite.code~allIndexes~sort
        firstPrefix     = Left(first,4)
        firstSuffixes ||= Right(first,2)
        If firstPrefixSeen.firstPrefix Then Iterate
        If firstPrefix \== "0000"      Then zeros = 0
        If lastPrefix \== firstPrefix  Then same  = 0
        firstPrefixSeen.firstPrefix = 1
        firstPrefixes ||= " "firstPrefix
      End
      If same Then Do
        -- 01: ccc
        -- 02: 01 (indicating first and last have the same prefix)
        -- 03: ss number of suffixes (hex)
        -- 04 to 04+ss-1: suffixes (1 byte each)
        -- 04+ss-1 to 04+ss-1 + 3*ss: composites (3 bytes each)
        If \PrimaryCompositeFirstPrefixesArrayCreated Then Do
          PrimaryCompositeFirstPrefixesArrayCreated = 1
          Call LineOut outFile, "PrimaryCompositeFirstPrefixes["Right(lastCount,2)"]      = .Array~new"
        End
        Call CharOut outFile,"PrimaryCompositeFirstPrefixes["Right(lastCount,2)"]["Right(i+1,2)"]  = '"Hex(Unicode(code,"property","ccc"))" 01"
        Do j = 1 To Length(firstSuffixes)-1 By 2
          xfirst = Left(code,4)firstSuffixes[j,2]
          Call CharOut outFile, " "firstSuffixes[j,2]
        End
        Do j = 1 To Length(firstSuffixes)-1 By 2
          xfirst = Left(code,4)firstSuffixes[j,2]
          Call CharOut outFile, " "PrimaryComposite.code[xfirst]
        End
        Call LineOut outFile, "'X"
      End
      Else If zeros Then Do
        -- 01: ccc
        -- 02: 02 (indicating that all first prefixes are 0000X)
        -- 03: ss number of suffixes (hex)
        -- 04 to 04+ss-1: suffixes (1 byte each)
        -- 04+ss-1 to 04+ss-1 + 3*ss: composites (3 bytes each)
        If \PrimaryCompositeFirstPrefixesArrayCreated Then Do
          PrimaryCompositeFirstPrefixesArrayCreated = 1
          Call LineOut outFile, "PrimaryCompositeFirstPrefixes["Right(lastCount,2)"]      = .Array~new"
        End      
        Call CharOut outFile,"PrimaryCompositeFirstPrefixes["Right(lastCount,2)"]["Right(i+1,2)"]  = '"Hex(Unicode(code,"property","ccc"))" 02"
        Do j = 1 To Length(firstSuffixes)-1 By 2
          xfirst = "0000"firstSuffixes[j,2]
          Call CharOut outFile, " "firstSuffixes[j,2]
        End
        Do j = 1 To Length(firstSuffixes)-1 By 2
          xfirst = "0000"firstSuffixes[j,2]
          Call CharOut outFile, " "PrimaryComposite.code[xfirst]
        End
        Call LineOut outFile, "'X"
      End
      Else Do
        -- 01: ccc
        -- 02: 00 (indicating there are several first prefixes)
        -- 03: ss number of first prefixes (hex)
        -- 04 to 04+ss-1: prefixes (1 byte each) <-- Heuristics indicate that they are all of the form 00ssxx
        If \PrimaryCompositeFirstPrefixesArrayCreated Then Do
          PrimaryCompositeFirstPrefixesArrayCreated = 1
          Call LineOut outFile, "PrimaryCompositeFirstPrefixes["Right(lastCount,2)"]      = .Array~new"
        End      
      
        Call CharOut outFile,"PrimaryCompositeFirstPrefixes["Right(lastCount,2)"]["Right(i+1,2)"]  = '"Hex(Unicode(code,"property","ccc"))" 00"
        Do j = 1 To Words(firstPrefixes)
          Call CharOut outFile, " "Right(Word(firstPrefixes,j),2)
        End
        Call LineOut outFile, "'X"
      
        count. = 0
        Do j = 1 To Words(firstPrefixes)
          prefix = "00"Right(Word(firstPrefixes,j),2)
          Do index Over PrimaryComposite.code~allIndexes~sort
            If index~startsWith(prefix) Then count.j += 1
          End
        End
        Do j = 1 To Words(firstPrefixes)
          prefix = "00"Right(Word(firstPrefixes,j),2)
          Call CharOut outFile, "PrimaryCompositeFirstSuffix["Right(lastCount,2)","Right(i+1,2)","Right(j,2)"]  = '"--Hex(count.j)
          Do index Over PrimaryComposite.code~allIndexes~sort
            If index~startsWith(prefix) Then Call CharOut outFile,Right(index,2)" "
          End
          blank = 0
          Do index Over PrimaryComposite.code~allIndexes~sort
            If \index~startsWith(prefix) Then Iterate
            If blank Then Do
              Call CharOut outFile," "
              blank = 0
            End
            Call CharOut outFile,PrimaryComposite.code[index]
            If \blank Then blank = 1
          End
          Call LineOut outFile, "'X"
        End
      End
    End
    accum += length(endings)/2
    --Say lastCount":" lastPrefix LastMin.lastPrefix LastMax.lastPrefix (LastMax.lastPrefix~x2d - LastMin.lastPrefix~x2d + 1) "["endings"]"
    MinMax ||= X2C(Right(LastMin.lastPrefix,2))X2C(Right(LastMax.lastPrefix,2))
    activeLastPrefix[ lastPrefix~X2D + 1 ] = lastCount~d2X~x2c
  End

  Call Stream outFile, "c", "Close"

  activeLastPrefix = activeLastPrefix~string

  elapsed = Time("E")
  Say "Done. Took" elapsed "seconds."

Exit

Hex: Return(Right(D2X(Arg(1)),2,0))

::Requires Unicode.cls