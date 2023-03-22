/******************************************************************************
 *                                                                            *
 *  noextension.rex -- Compare the output of "Call program" and               *
 *                     "Call program.rex" in the results of sotes.rex.        *
 *                                                                            *
 *  Written in 2023 by Josep Maria Blasco <josep.maria.blasco@epbcn.com>      *
 *                                                                            *
 ******************************************************************************/

Parse Source . . myself
myDir = myself~left( myself~lastPos("\") - 1 )
myDir = .File~new(myDir)
files = myDir~listFiles
Do file Over files
  If \file~name~endsWith(".results.rex") Then Iterate
  If \file~isFile                        Then Iterate
  Call Check file
End
Exit

Check:
  Call (Arg(1))
  p. = result
  Do i = 1 To p.0 by 2
    If p.i \== p.[i+1] Then Do
	  Say "'"Arg(1)"' failed at test no." i ": '"p.i.test"'."
	  Return
	End
  End
  Say "'"Arg(1)"' passed."
Return
