/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- The MultiStageTable class                                                  --
--                                                                            --
-- See /doc/multi-stage-table.md for documentation                            --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Needed so that other classes can find it at activation time
.local~MultiStageTable = .MultiStageTable  

::Class MultiStageTable Public

::Method Compress Class
  Use Strict Arg buffer, chunkSize = 256
  
  offset  = -1       -- Offset of a chunk
  offset. = 0        -- Stores the offset of a chunk. 0 when the chunk was never seen.
  offsets = ""       -- Will store the 1-byte offsets
  chunks  = ""       -- Will store the deduplicated chunks

  Do i = 1 To Length(buffer) By chunkSize     -- U+0000..Length(buffer)
  
    chunk = buffer[i,chunkSize]               -- Pick a chunk of "chunkSize" bytes     
    
    If offset.chunk > 0 Then Do               -- Already seen? offset.chunk will store the offset
      offsets ||= Right(D2X(offset.chunk),2,0)~x2c
      Iterate
    End
    
    offset      += 1                          -- Never seen: we need a new offset for that
    offset.chunk = offset
    offsets    ||= Right( d2x(offset) , 2, 0)~x2c 
    chunks     ||= chunk                      -- Store the new chunk
  End
  
  If offset > 255 Then Say "Warning!" offset "chunks when compressing file!"
  Else Do
    compressedSize = Length(offsets)+Length(chunks)
    Say "Compressing" Length(buffer) "bytes of two-stage table into",
      offset chunkSize"-byte fragments, total =" compressedSize,
      "bytes ("Format(100*compressedSize/Length(buffer),,2)"%)."
  End
  
Return offsets, chunks -- An array

::Method init 
  Expose offset chunks chunkSize width bigvalues
  
  Use Strict Arg offset, chunks, tableSize = (2**16 * 2), chunkSize = 256, width = 1, bigvalues = .Nil

::Method "[]"
  Expose offset chunks chunkSize width bigvalues
  
  Use Strict Arg n
  
  .Validate~nonNegativeNumber("n",n)
  
  If n >= tableSize Then Return Copies("00"X,width)           -- 0..(tableSize-1)
  
  twoStage   = bigValues~isNil
  
  highIndex  = n  % ( chunkSize / twoStage~?(width, 1) )
  highOffset = offset[ 1 + highIndex ]~c2x~x2d
  lowOffset  = n // ( chunkSize / twoStage~?(width, 1) )
    
  If twoStage Then Do
    Return     chunks[ 1 + highOffset*chunkSize + lowOffset * twoStage~?(width, 1), width ]
    End
  Else 
    byte     = chunks[ 1 + highOffset*chunkSize + lowOffset * twoStage~?(width, 1) ]
    
  Return       bigvalues[ 1 + (byte~c2x~x2d - 1) * width, width ]