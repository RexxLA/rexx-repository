# Internal representation

## ARB recommendations

(TBD)

## Draft Notes

Two families of Rexx regarding the interpretation of strings:

- those working with raw bytes like Regina and ooRexx. c2x returns these raw bytes.
- those working with Unicode strings (netrexx and crexx)

> (adrian)
> - For ooRexx we could just have a new class(s) (as discussed) and the bif members would follow the expected analog
> - NetRexx - presumably is done(?)
> - cRexx level b/g - done as it is not backward compatible anyway. Moreover the compiler will know if it is bytes or text and behave as expected
> - For Classic REXX the essential problem comes down to knowing if a variable contains UTF-8 / Unicode - or if it contains binary. If it (and the BIFs) can do this then they can fall back to binary 8-bit behaviour.
> So for the classic REXX standard - I guess all we have to say is that the language processor needs to track this (text/binary contents). Literals would clearly be text, and file opens could be text or binary mode etc. BIFs would have to read the status, behave and set status as appropriate. Plenty of rules to work through ...

> (rené)
> I think it would be wrong to assume a character encoding.

## Raw bytes versus Unicode

### Armin Ronacher about Python 3

(jlf)  
These blogs are old and biased, the situation could be better today for Python 3, but I still find them useful for the cases they describe.  
It's because of these blogs that I decided to apply the following rules with Executor:

- No automatic conversion to Unicode by the interpreter.
- The strings crossing the I/O barriers are kept unchanged.

(/jlf)

#### [More About Unicode in Python 2 and 3](https://lucumr.pocoo.org/2014/1/5/unicode-in-2-and-3/)  
January 5, 2014

(jlf)  
Looks similar to what could happen to Regina and ooRexx?  
(/jlf)


#### [Everything you did not want to know about Unicode in Python 3](https://lucumr.pocoo.org/2014/5/12/everything-about-unicode/)  
May 12, 2014

(jlf)  
The guy is not happy with the decision to force Unicode everywhere.
Illustration with the `cat` command.  
(/jlf)
