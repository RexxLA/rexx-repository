README FOR \BF

The Rexx from the ANSI document, CRX.RX, is converted to a pseudocode (known as Bcode) for execution by the CRX implementation.  If there is a need to debug the Bcode, the members of \bf can be followed like this:

Bcode routines use only local variables and arguments, held on the stack; there are no more permanent variables.  The first byte of a Bcode routine holds count-of-locals * 8 + count-of-arguments.  In the remainder:

The names starting $p, like $pMultiply, are operators implemented in hard code within CRX.  What they do is meant to be clear from the choice of name.

The remainder of the references are name operands, using the same names as CRX.RX used for the same variables.  Operands are put on the stack as they are encountered.  Operands use and remove operands from the stack. 

(bf\time.inc also has some Bcode that is nothing to do with Time)