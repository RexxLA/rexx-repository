# Unicode Draft Notes

## Internal representation

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
