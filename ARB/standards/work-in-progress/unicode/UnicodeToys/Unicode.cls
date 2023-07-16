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
/*  Unicode.cls: the main Unicode file                                       */
/*  ==================================                                       */
/*                                                                           */
/*  This class offers a set of public Unicode routines that implement        */
/*  the basic Unicode toy architecture. Some of these routines are:          */
/*                                                                           */
/*    BYTES(string) -- Creates a new string composed of bytes                */
/*    RUNES(string) -- Creates a new string composed of runes (codepoints)   */
/*    TEXT(string)  -- Creates a new string composed of grapheme clusters    */
/*    UNICODE(code,"Property",propertyName)                                  */
/*      Thw swiss-knife Unicode BIF. It allows to map codepoints to          */
/*      Unicode properties.                                                  */
/*    ALLRUNES(string) -- Returns the set of codepoints that compose the     */
/*                     string in a standard, blank-separated format          */
/*    R2N(code)     -- Rune To Name: returns the Unicode Name property       */
/*    N2R(name)     -- Name To Rune: transforms a Unicode name or alias      */
/*                                   into a normalized codepoint             */
/*                                                                           */
/*  official Unicode sources, since the standard is unclear on several       */
/*  points. Building on that property, another primitive is provided that    */
/*  transforms a set of codepoints (provided either as an array or as a      */
/*  blank-delimited string) into the corresponding string composed of        */
/*  grapheme clusters.                                                       */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Ver. Aut Date     Comments                                               */
/*  ---- --- -------- ------------------------------------------------------ */
/*  00.1 JMB 20230716 Initial release                                        */
/*                                                                           */
/*****************************************************************************/

::Routine Unicode Public
  Use Arg , option
  option = Upper( Strip( option ) )
  Select
    When "PROPERTY"~Abbrev(option,1) Then Signal Properties
    Otherwise Raise Syntax 88.900 Additional("Invalid option '"Arg(2)"'")
  End
    
Properties:
  Use Strict Arg code, optjon , property
  .Unicode.property~checkCode( code )
  code     = Upper( code )
  property = Space( Translate( Upper( property ),"  ","-_"), 0)
  
  Select Case property
    When "NA", "NAME" Then Do
      If .Unicode.Name == ".UNICODE.NAME" Then .Context~package~loadPackage("Unicode.Name.cls")
      Return .Unicode.Name[ code ]
    End
    When "GC", "GENERALCATEGORY" Then 
      Return .Unicode.General_Category[ code ]
    When "GCB", "GRAPHEMECLUSTERBREAK" Then 
      Return .Unicode.Grapheme_Cluster_Break[ code ]
    When "ALGORITHMICNAME" Then -- Until we have a true NAME implementation
      Return .Unicode.General_Category~Algorithmic_Name( code )
    Otherwise Raise Syntax 88.900 Additional("Invalid property '"Arg(3)"'")
  End

::Routine N2R Public
  Use Strict Arg name
  If .Unicode.Name == ".UNICODE.NAME" Then .Context~package~loadPackage("Unicode.Name.cls")  
  Return .Unicode.Name~n2r( name )

::Routine R2N Public
Use Strict Arg code
  If .Unicode.Name == ".UNICODE.NAME" Then .Context~package~loadPackage("Unicode.Name.cls")  
  Return .Unicode.Name[ code ]

::Routine stringType Public
  Use Strict Arg string, option = ""
  .Validate~classType( "option" , option , .String )
  option = Upper(option)
  Select
    When Abbrev("BYTES",option,1)  Then Return self~class == .String
    When Abbrev("RUNES", option,1) Then Return self~class == .Runes
    When Abbrev("TEXT",  option,1) Then Return self~class == .Text
    Otherwise Nop
  End
  Select
    When string~isA(.Text)   Then Return "TEXT"
    When string~isA(.Runes)  Then Return "RUNES"
    When string~isA(.String) Then Return "BYTES"
    Otherwise                     Return "NONE"
  End

::Routine Runes Public
  Use Strict Arg string
  Return .Runes~new(string)

::Routine Text Public
  Use Strict Arg string
  Return .Text~new(string)
  
::Routine Bytes Public
  Use Strict Arg object
  return object~makeString
  
::Routine AllRunes Public  
  Use Strict Arg object
  .Validate~classType( "object" , object , .Runes )
  Return object~allRunes
  
/*****************************************************************************
 *                                                                           *
 * Implementation of some classic Rexx BIFs                                  *
 * ----------------------------------------                                  * 
 *                                                                           * 
 * Names are preceded with "!", like in "!Length".                           *
 * An internal routine called "Length" will be needed that calls "!Length",  * 
 * or a preprocessor that substitutes calls to "Length" by calls to          *
 * "!Length", as there is no other way to override BIFs.                     * 
 *                                                                           * 
 *                                                                           * 
 *****************************************************************************/ 

::Routine !Length Public
  Use Strict Arg string
Return string~length
  
  
    
::Requires Unicode.Property.cls
::Requires Unicode.General_Category.cls
::Requires Unicode.Grapheme_Cluster_Break.cls

::Requires Runes.cls
::Requires Text.cls
