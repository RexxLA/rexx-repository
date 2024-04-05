/* */
 do seed=0 by 1000000 to 10000000
   say "Seed" seed
   x = random(,100000,seed)
   do 9
     x = x random(,100000)
     end
   say x
 end
