This folder has the source code necessary to reassemble CRX.  Note however that the implementation uses tables that are not human-understandable.  Folder CRX2011 is about making those tables.

============================================================================================
READING THE ASSEMBLER

The assembly code, extension .AS, is multiple-statements-per-line. It can be read by any editor but for clarity it is best to have an editor (like Personal Editor) which uses a font in which 'FA'x, the statement separator, appears as dot-central-to-character. (If your editor treats 'FA'x as some obtrusive character then it is better to read the .LST files)


PHYSICAL ARRANGEMENT OF THE CODE

CRX.MK shows that CRX.EXE results from linking the .OBJ files of 10 assemblies. The root of each assembly has extension .AS  

The .AS sources (BCODE BIFS COMMAND EXECUTE MAIN MEMORY MSG PCODE SYNTAX TOKENS) have INCLUDEs with extension .INC. Some of these are not humanly authored, they are the product of utility programs which process parts of the text of the Standard.

Human authored: ATTRIBS BIFS CONFIG DEBUG DECLARES TRACE.  (There is also ALWAYS.INC that is included in all the assemblies)

Machine authored: CMP CODES KEYS SYN SYNEQU TOKDATA and the INCludes in BF\. 

LOGICAL ARRANGEMENT OF THE CODE

This can be guessed from the naming: MAIN has the overall control.  ATTRIBS, TOKENS, TOKDATA, KEYS, SYN, SYNEQU, CODES and SYNTAX combine to parse the source and, by calls from the parsing to actions in PCODE, generate the internal form ("pseudo-code") of the source.  Repositioning the values in play compactly, so as free address space for reuse ("garbage collection") is in MEMORY.  COMMAND allows for the user program issuing commands to the environment. EXECUTION executes the internal form of the user's program. MSG issues error msgs by expanding their compressed form CMP. when the messages are raised by SYNTAX or EXECUTE. BIFS and BCODE does the argument checking and execution for builtin functions.  The Standard defines many builtins using Rexx source code so these are implemented using an internal form derived from that Rexx source. (Similar but not the same as Pcode, this is called Bcode and can be more efficient than Pcode because it is known to be error free and has limited functionality.) The actual Bcode used is in folder BF\  

The file README.INC (not readme.txt) in Historical may have a few inaccuracies but it does some explaining of why the code is the way it is.  

NOTES ON NAMING AND MACROS

You will notice some verbs in the position where one would expect a hardware instruction.  These are expanded by the macros to be found in always.inc.  The common ones are z to xero a field (register or memory) and On Off Qry to set, reset, and test a bit.  There are other macros defined in declares.inc.  The common ones are 
Move which moves 8 bytes (usually the value of a variable in the subject Rexx program) and Up Down which alter the DI register by 8 (to address an adjacent variable).   

You will notice that the code uses names like Z.Tag and Y.Cseg, with a single letter start.  Macros defined in declares.inc expand these single letters into references to structures (Vshape for V., Zshape for Z. etc)  In this way Z. refers to a field in the Zone, an area globally available in CRX execution. D. refers to an element for a REXX DO loop on the soft stack. F. refers to data about a file.  A. refers to pieces of memory got from DOS.
 
You will notice operands of the instructions with names like SpecsBx and CursorSi where the right characters of the name match a reserved name for a register in the hardware.  The name is a synonym for the hardware register, used for readability.

README FOR \BF

The Rexx from the ANSI document, CRX.RX, is converted to a psuedocode (known as Bcode) for execution by the CRX implementation.  If there is a need to debug the Bcode, the members of \bf can be followed like this:

Bcode routines use only local variables and arguments, held on the stack; there are no more permanent variables.  The first byte of a Bcode routine holds count-of-locals * 8 + count-of-arguments.  In the remainder:

The names starting $p, like $pMultiply, are operators implemented in hard code within CRX.  What they do is meant to be clear from the choice of name.

The remainder of the references are name operands, using the same names as CRX.RX used for the same variables.  Operands are put on the stack as they are encountered.  Operands use and remove operands from the stack. 

(bf\time.inc also has some Bcode that is nothing to do with Time)