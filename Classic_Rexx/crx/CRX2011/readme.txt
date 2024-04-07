
Folder CRX1999/ASM has the manually generated source code of Compact Rexx but merely uses the mechanically generated source (tables), without considering their origins. That folder's readme describes the physical and logical arrangement of the source.  In folder CRX1999/TOOLS the programs that create source tables are replicated.  However, those are in data-types-dubious "C" and a better understanding might come from this CRX2011 folder which has C++ approximate equivalents. 

ABOUT THE TOOLS

The programs are not in their original "C", they are in C++ acceptable to Microsoft's Visual Studio 2010. This is because there can be little interest in C language features that are nowadays deprecated. They originally used Wallets and Walks.  A wallet was an extendable collection of structures (extended by deallocating memory and allocating larger if necessary).  The items in the collection were not necessarily of equal length. If the items all started with the same header they could be walked - i.e there was lookup to find or add a new item.  C++ would object to all the arithmetic on pointers that this entailed. This is not a class that the C++ standard library has.  The nearest seems to be a vector of objects, each object containing a string. For any historical interest, the "C" versions are in subfolder Historical.

Recap for those unfamiliar with parsing tables:  A reference manual for a programming language will usually have "syntax diagrams" to show what can be validly written.  Together these form the "grammar" of the language.  For technical work on languages, the grammar is usually written in Backus Nuar Form (BNF).  See IS_BNF.TXT for the grammar of the Rexx Standard. A particular syntax can be described by BNF in more than one way.  By writing it suitably, the BNF can describe not only what user programs can be written but also the order of execution (operator precedence etc.)

Terminology: The statements of a grammar are called productions. What appears on the LHS of the ":=" is the production name.  What is referenced in the grammar but is not on any LHS is a terminal.

The action of parsing uses a stack and has the following primitives (with names that come from the theory).  A "shift" adds what is encountered to the stack. A "reduce" recognises the items that are on the top of the stack as comprising an instance of a piece of the BNF and replaces those items with the LHS of the piece of BNF. In traces of what is happening, a marker (here a caret ^) is used to denote progress through the BNF "production".  Thus "realaddition.10=addition additive_operator ^ multiplication" would correspond to the scan of the user's program having just encountered and shifted an additive_operator (a "+" or a "-").  When the "state" (i.e. context) corresponds to recognising the caret is at the end of a production, a reduction is performed.

In a pure interpreter the reduction is when the action is performed, e.g. the two numbers are added together.  However most Rexx interpreters record the order of operations in an internal form ("pseudo-code") and execute that after the whole source program is parsed.

The programs which process the BNF into parser tables are concerned with producing tables that allow the parsing described above to be done neatly. They include, for instance, recognising that two different states (that appear as different positions for the caret in the productions) can be rendered as one state because the actions to be taken (for whatever might appear next in the source being parsed) are the same.  

   

The machine authored sources are: CMP CODES KEYS SYN SYNEQU TOKDATA and the INCludes in BF\. (All with extension .INC)

The programs to produce the sources were written to process just one subject - bits of the content of the Rexx Standard.  They would probably work for a different language specified in the same style but there is no guarantee of that.

A more detailed account of rebuilding is in CRX1999/TOOLS 

BUILDING THESE TOOLS WITH a MODERN INTEGRATED DEVELOPMENT ENVIRONMENT

The tools are here all in one solution for Microsoft Visual Studio 2010 Express (which is free download). Some of the properties, e.g. command arguments, will need change for particular contexts. Other properties may need change because the original work was done on a 64 bit machine with that SDK in place.

Project Entable processes the BNF and thus corresponds to Simplify+States+Structs+Pack of the 1999 tools.  Project EntableBF corresponds to BF of the 1999 tools - it makes Bcode from the Rexx of the Standard. There is no project for compressing the messages - there are many different ways they could be compressed.

None of the projects are finalised since if ever used seriously they would be used on something more than the (solved) classic Rexx problem.  They could need adapting to the new problem.