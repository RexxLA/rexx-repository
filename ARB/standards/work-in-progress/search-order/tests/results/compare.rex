/****************************************************************************
*                                                                           *
*  compare.rex -- Compare the results of two tests.                         *
*                                                                           *
*  Quick and dirty - compare the results of running sotest.rex or           *
*  any of its variations, and display the name of the first test            *
*  such that the result is different, or the word 'Identical'               *
*  in case the results are identical.                                       *
*                                                                           *
*  Written in 2023 by Josep Maria Blasco <josep.maria.blasco@epbcn.com>     *
*                                                                           *
*****************************************************************************/

Parse Arg a1 a2

Call (a1".results.rex")
p. = result

Call (a2".results.rex")
q. = result

Do i = 1 To Min(p.0,q.0)
  If p.i \== q.i Then Do
    Say "Tests are different at '"p.i.test"'."
    Exit
  End
End

Say "Identical"
