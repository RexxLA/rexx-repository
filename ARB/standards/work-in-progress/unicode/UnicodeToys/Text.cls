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
/*  The TEXT class                                                           */
/*  ==============                                                           */
/*                                                                           */
/*  The TEXT class implements a new kind of string composed of Unicode       */
/*  grapheme clusters. Some of the usual BIFs (e.g., LENBTH, SUBSTR, [],     */
/*  POS, COPIES) are implemented at the grapheme cluster level. The          */
/*  ALLRUNES method from the RUNES class is also available, since TEXT is a  */
/*  subclass of ALLRUNES.                                                    */
/*                                                                           */
/*  When string is a TEXT string, string[i] returns an (extended) grapheme   */
/*  cluster which is itself a TEXT string. You can then use the ALLRUNES     */
/*  function on string[i], if so desired, to get the individual codepoints   */
/*  that compose the i-th grapheme cluster of "string".                      */
/*                                                                           */
/*  TEXT strings can be created by using the TEXT(string) function.          */
/*  (In the future, it will be possible to use the "string"T notation.)      */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.1  JMB 20230716 Initial release                                       */
/*  00.1c JMB 20230718 Move property classes to the "property" subdir        */
/*                                                                           */
/*****************************************************************************/

--
--
-- We redefine a number of BIMs (LENGTH, [], ...) so that we
-- can operate with Runes strings as easily as with Byte strings:
--
-- Done: 
--   []
--   Center/Centre (redefined in Runes.cls)
--   Copies        (redefined in Runes.cls)
--   Length
--   Pos           (redefined in Runes.cls)
--   SubStr        (redefined in Runes.cls)
-- 


::Class "Text" SubClass Runes Public
  
--------------------------------------------------------------------------------
-- Reimplementation of .String BIMs                                           --
--------------------------------------------------------------------------------  
  
::Method "[]"
  Expose graphemes
  Use Strict Arg n, length = 1
  .Validate~positiveWholeNumber( "n" , n )
  .Validate~nonNegativeWholeNumber( "length" , length )
  max = self~length
  If n > max Then Return self~class~new("")
  res = ""
  Do i = n for length While i <= max
    res ||= graphemes[i]
  End
  Return self~class~new(res)

::Method Length
  Expose graphemes
  Return graphemes~items

--------------------------------------------------------------------------------
-- End of reimplementation of .String BIMs                                    --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Currently, .Runes objects have to be initialized with a UTF8 .String       --
--------------------------------------------------------------------------------  
  
::Method init
  Expose graphemes
  self~init:super
  graphemes = .Unicode.Grapheme_Cluster_Break~codepointsToGraphemes( self~allRunes, "UTF8" )

::Requires Runes.cls
::Requires "properties/Unicode.Grapheme_Cluster_Break.cls"
