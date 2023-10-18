/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

/** 
   <h3>The <code>Encoding</code> class</h3>
    
  <p>
    See doc/encodings.md for documentation
  
  <h4>Version history</h4>
   
  <table class="table table-bordered">
    <tr><td><b>1.0</b><td><b>20230811</b><td>Initial release.
    <tr><td>          <td><b>20230816</b><td>Change the buffers from strings to mutablebuffer, as per Rony's suggestion
    <tr><td><b>1.1</b><td><b>20230926</b><td>Delete UTF8 class method (now handled by the UTF8 BIF).
    <tr><td><b>   </b><td><b>20230930</b><td>Return a stem when both UTF-8 and UTF-32 are requested instead of an array.
    <tr><td><b>   </b><td><b>20230930</b><td>Move docs to readmd.md
  </table>
 
 */

-- Make ourselves known so that encodings can subclass us without using
-- ::Requires (otherwise the prolog gets the risk of being run twice).

.local~encoding = .Encoding

-- Extract our own directory, and do a directory listing of its "encodings"
-- subdir. Call all the *.cls files in turn to give them the opportunity 
-- to register.

separator = .File~separator
Parse Source . . myself
myDir = Left(myself, LastPos(separator, myself))
Do file Over .File~new(myDir"encodings")~listFiles
  fileName = file~absolutePath
  If filename~endsWith(".cls") Then Call (filename)
End

::Class "Encoding" Public

--------------------------------------------------------------------------------
-- CONSTANTS                                                                  --
--------------------------------------------------------------------------------

::Attribute name                 Class Get Abstract
::Attribute aliases              Class Get Abstract
::Constant  allowSurrogates      0
::Attribute endOfLine            Class Get Abstract
::Constant endOfLineAlignment    1
::Constant alternateEndOfLine    ""
::Constant useAlternateEndOfLine 0
::Attribute isFixedLength        Class Get Abstract
::Attribute bytesPerChar         Class Get Abstract
::Attribute maxBytesPerChar      Class Get Abstract
::Method bytesNeededForChar      Class Abstract

::Method register           Class
  Expose Names. name aliases
  
  Use Strict Arg handler
      
  name    = handler~name
  aliases = handler~aliases
  
  --
  -- Names. stores both the official names and the aliases.
  -- This allows to detect duplicates.
  --
  
  If Names.~hasIndex(name) Then
    Raise Syntax 98.900 Additional("Duplicate encoding name '"name"'")
    
  Names.[Upper(name)] = handler
  
  -- "Aliases" can be specified as a blank-separated string, or as
  -- an array of names.
  If aliases~isA(.String) Then xAliases = aliases~makeArray(" ")
  Else                         xAliases = aliases
  
  Do alias Over xAliases
    If Names.~hasIndex(alias) Then 
      Raise Syntax 98.900 Additional("Duplicate encoding name or alias '"alias"'")
    Names.[Upper(alias)] = handler
  End
  
::Method "[]"              Class
  Expose Names.
  Use Strict Arg name, option = "Syntax"
  option = Upper(option)
  Select Case option
    When "SYNTAX" Then syntax = 1
    When "NULL"   Then syntax = 0
    When ""       Then syntax = 0
    Otherwise
      Raise Syntax 93.900 Additional("Invalid option '"Arg(2)"'")
  End
  name = Upper(name)
  If Names.~hasIndex(name) Then Return names.[name]
  If \syntax Then Return ""
  Raise Syntax 93.900 Additional("Encoding '"name"' not found.")
 
::Method transcode Class -- Final
  Use Strict arg string, source, target, option=""

  -- Check that "option" is OK.  
  option = Strip(Upper(option))
  If option \== "", option \== "SYNTAX" Then
    Raise Syntax 93.900 Additional("Invalid option '"option"'")
  raiseSyntax = option == "SYNTAX"
  
  sourceEncoding = .Encoding[source]
  If sourceEncoding~isNil Then
    Raise Syntax 93.900 Additional("Invalid source encoding '"source"'")

  targetEncoding = .Encoding[target]
  If targetEncoding~isNil Then
    Raise Syntax 93.900 Additional("Invalid target encoding '"target"'")
    
  If targetEncoding == sourceEncoding Then Return string
  
  If string == "" Then Return ""
  
  temp = sourceEncoding~decode(string, option)
  
  If \raiseSyntax, temp == "" Then Return ""
  
  new  = targetEncoding~encode(temp, option)
  
  -- Logically, this goes here, but it is not necessary
  -- If \raiseSyntax, new  == "" Then Return ""
  
  Return new

::Method encode Class Abstract

::Method prepareEncode Class Private
  Use Strict Arg string, option = ""
  
  -- Check that "option" is OK.  
  option = Strip(Upper(option))
  If option \== "", option \== "SYNTAX", option \== "REPLACE" Then
    Raise Syntax 93.900 Additional("Invalid option '"option"'")

  If \string~isA(.Text), \string~isA(.Codepoints) Then
    -- Attempt to decode the string first. This will check for well-formedness.
    Return .Encoding["utf8"]~decode(string, "UTF32", option)
    
  Return string~C2U("UTF32")
  
::Method decode Class Abstract

::Method checkDecodeOptions Private Class
  Use Strict Arg format, errorHandling

  -- Check that "format" is OK
  returnUTF8  = 0
  returnUTF32 = 0
  format = Space(Upper(format))
  Do format Over format~makeArray(" ")
    Select Case format
      When "UTF-8",  "UTF8"  Then returnUTF8  = 1
      When "UTF-32", "UTF32" Then returnUTF32 = 1
      Otherwise 
        Raise Syntax 93.900 Additional("Invalid format '"format"'")
    End    
  End
  
  If (Arg(1, "O") | Arg(1) == ""), errorHandling \== "" Then 
    Raise Syntax 93.900 Additional("Invalid option '"errorHandling"'")
  
  -- Check that "errorHandling" is OK.  
  errorHandling = Strip(Upper(errorHandling))
  Select
    When errorHandling == ""               Then errorHandling = "NULL"
    When Abbrev("NULL",errorHandling,1)    Then errorHandling = "NULL"
    When Abbrev("SYNTAX",errorHandling,1)  Then errorHandling = "SYNTAX"
    When Abbrev("REPLACE",errorHandling,1) Then errorHandling = "REPLACE"
    Otherwise Raise Syntax 93.900 Additional("Invalid error handling '"errorHandling"'")
  End
    
Return errorHandling returnUTF8 returnUTF32  

::Method isCodeOK          Class 
  Use Strict Arg code
  If code = ""             Then Return 0
  If \DataType(code,"X")   Then Return 0
  If Length(code) > 8      Then Return 0
  
  Numeric Digits 10
  
  n = X2D(code)
  
  If \self~allowSurrogates Then Do
    If n <    55296        Then Return 1       -- Surrogates start at U+D800..
    If n <=   57343        Then Return 0       -- ..and end at U+DFFF
  End
  
  If n <= 1114111          Then Return 1       -- Maximum is U+10FFFF
  Return 0
  
::Method checkCode         Class Private
  Use Strict Arg code
  
  If self~isCodeOk(code) Then Return
  
  Raise Error 23.900 Additional("Invalid Unicode codepoint '"code"'X")