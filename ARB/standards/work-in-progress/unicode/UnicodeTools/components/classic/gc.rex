/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

/*
  Sample prototype classic rexx implementation of the (extended) general_category property.
  
  See https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/multi-stage-table.md
  for a description of the structure of the binary file,
  and also https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/components/properties/gc.cls
  for the code of the complete TUTOR ooRexx GC property.
  
  New in the 0.5 release of TUTOR. Proof-of-concept, with no error checking.
  
  See testgc.rex for an utilization example.
  
  The first call should have a single argument, called "INIT". It will return an opaque token.
  
  Subsequent calls should have three arguments:
    1: "Query" (case insensitive, 1 char is enough)
    2: code point (either hex, or 4 bytes binary UTF32)
    3: the token returned by the INIT call
  --> Returns the (extended) general_category property.
  Please refer to testgc.rex for details.
*/

/* Location of the binary file */
binFile = "../bin/gc.bin"

Arg verb

Select
  When verb == "INIT"         Then Call Init
  When Abbrev("QUERY",verb,1) Then Signal Query
End

Init:
  If Stream(binFile, "Command", "Query Exists") == "" Then Do
    Say "Missing binary file '"binfile"'."
    Exit 100
  End
  chunk = CharIn(binFile, 1, Chars(binFile) )
  Call Stream binFile, "Command", "Close"
Exit chunk

Query:
  Parse Arg , code, binary
  
  /* Code may be an hex number, or a UTF-32 (4 byte) code point */
  If Length(code) == 4 Then
    If Left(code,1) == "00"X Then
      code = C2X(code)
      
  If \DataType(code,"X") Then Do
    Say "Invalid code point '"code"'."
    Exit 100
  End

  Numeric Digits 15
  code = X2D(code)
      
  /* items  = X2D(C2X(SubStr(binary,     1   , 4)))                      */
  L1        = X2D(C2X(SubStr(binary,     5   , 1))) /* Length of id 1    */
  offset1   = X2D(C2X(SubStr(binary,  6+L1   , 4))) /* Offset and length */
  length1   = X2D(C2X(SubStr(binary, 10+L1   , 4))) /* of table 1        */
  L2        = X2D(C2X(SubStr(binary, 14+L1   , 1))) /* Length of id 2    */
  offset2   = X2D(C2X(SubStr(binary, 15+L1+L2, 4))) /* Offset and length */
  length2   = X2D(C2X(SubStr(binary, 19+L1+L2, 4))) /* of table 2        */
   
  offset     = SubStr(binary, offset1 + 1, length1) /* Offsets table     */
  chunks     = SubStr(binary, offset2 + 1, length2) /* Chunks table      */
   
  highIndex  = code  % 256
  highOffset = X2D(C2X(SubStr(offset,1 + highIndex,1)))
  lowOffset  = code // 256

  gc = SubStr(chunks, 1 + highOffset * 256 + lowOffset, 1)

Return gc
   
--Say code C2X(gc) highIndex highOffset lowoffset L1 L2 "*"SubStr(binary,6,L1)"*" "*"SubStr(binary,15+L1,L2)"*" offset1 length1 offset2 length2