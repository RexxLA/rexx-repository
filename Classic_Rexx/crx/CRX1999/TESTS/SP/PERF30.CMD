/**/
 parse version ver;say "On" ver


/*[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[*/

  say "100 million countdown."
  call time('R')
  /* Personal Rexx stalled on original */
  do 10
   say '@@@'
   do 10000000 /* Ten million */
   end
  end
  say format(time('E'),,2) 'seconds'

/*]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]*/










/*[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[*/

  say "10 million string assignments."
  call time('R')
  do 10000000 /* Ten million */
   c="AbCdEfG"
   end
  say format(time('E'),,2) 'seconds'

/*]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]*/











/*[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[*/

  say "10 million small integer comparisons."
  def=7
  call time('R')
  do 10000000 /* Ten million */
   if def>9 then def=8
   end
  say format(time('E'),,2) 'seconds'

/*]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]*/









/*[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[*/

  say "A million concatenations. (Not 10 thousand) "
  call time('R')
  do 100
    str=''
    do 10000
      str=str'+-'
      end
    end
  say format(time('E'),,2) 'seconds'

/*]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]*/




