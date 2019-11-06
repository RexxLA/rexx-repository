/* REXX    STRSORT   Sort a string of words into ascending or
                     descending sequence.
 
           Written by Frank Clarke, Tampa, 19951011
 
     Modification History
     20020903 fxc return compressed string
     20030521 fxc enable return via stack
 
*/
 
/*    The following code shows how STRSORT might be called:
string = "D M A B N"
string2 = STRSORT(string)
say string2
string2 = STRSORT(string,"D")
say string2
.  ----------------------------------------------------------------- */
   arg parms "((" opts
   parse var parms string "," dir      /* input string of words      */
 
   push ""
   pull answer
   parse value dir "A"   with dir .    /* default to 'ascending'     */
 
   if dir = "A" then,                  /* ascending                  */
   do while string ^= ""
      parse var string currwd string   /* get next word              */
      do ii = Words(answer) to 1 by -1,
              while(currwd < Word(answer,ii))
      end                              /* where does it go?          */
      front  = Subword(answer,1,ii)    /* split answer here          */
      back   = Subword(answer,ii+1)
      answer = front currwd back       /* insert between             */
   end
   /* this sorts in reverse order.... */
   else,
   do while string ^= ""
      parse var string currwd string   /* get next word              */
      do ii = 1 to Words(answer),
              until(currwd > Word(answer,ii))
      end
      front  = Subword(answer,1,ii-1)  /* split answer here          */
      back   = Subword(answer,ii)
      answer = front currwd back       /* insert between             */
   end
 
if Wordpos("QUEUE",opts) > 0 then queue Space(answer,1)
else,                                  /*                            */
return(Space(answer,1))                /*@ STRSORT                   */
