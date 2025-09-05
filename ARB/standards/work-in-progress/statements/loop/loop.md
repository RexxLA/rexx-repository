= The LOOP statement

NetRexx and ooRexx have added a `loop` statement to lighten the load off of the `do` statement.

Differences: 'loop for' x (NetRexx) and `loop` x (ooRexx)

[JMB: to enhance the compatibility between ooRexx and NetRexx, ooRexx could optionally support the "loop for x" (and "do for x") syntax. The possibility of breakage is really remote: one would need a situation in which "for x" is an expression that evaluates to an integer: this can be done, by defining "for" as an object of a class which reacts to " "-concatenation by producing a positive whole number, but the chances of such a combination naturally occurring are practically zero].
