# Serialization and deserialization

## ARB recommendations

(TBD)

## Draft Notes

> (josep maria)
> Manipulating a stream that is BINARY RECLENGTH nnn is the first example that comes to my mind.
>  One knows the binary structure of the records, for example you know that the first four bytes
>  of each record represent an integer. You get the first four bytes, Left(record, 4), then C2X, then X2D

we should distinguish internal representation from serialization - this particular
example can go wrong in so many ways; network byte order versus little endian;
signed (1 complement, 2 complement) vs unsigned; (...)
