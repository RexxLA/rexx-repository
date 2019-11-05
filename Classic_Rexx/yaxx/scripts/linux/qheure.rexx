/* QHeure */

/*
   Displays time in French, also chimes.
   From QTIME, Mike Cowlishaw,  December 1979
   Xavier de Lamberterie, Janvier 1982
   Reviewed by Pierre Richard, July 2002
*/
qheure:
arg arg deb
if arg=?
   then call tell
if arg='STACK'
   then do
      stack=1
      parse var deb arg deb
      end
   else stack=0
if arg='TEST'
   then c8=deb
   else do
      if deb\='' then trace ?r
      c8=time()
      end
ot="Il est"

hr=substr(c8,1,2)+0
mn=substr(c8,4,2)
sc=substr(c8,7,2)

h.0 = 'minuit'
h.1 = 'une' ; h.2 = 'deux';    h.3 = 'trois';   h.4 = 'quatre'
h.5 = 'cinq'; h.6 = 'six' ;    h.7 = 'sept' ;   h.8 = 'huit'
h.9 = 'neuf'; h.10= 'dix' ;    h.11= 'onze' ;   h.12= 'midi'

if sc>29
   then mn=mn+1                                       /* round up mins */
if mn>32
   then do;                                          /* something to.. */
        hr=hr+1
        end;
if hr>=24
   then hr=hr-24                                     /* watch for 25 h */
if hr>12
   then hr=hr-12                           /* get rid of 24-hour clock */
if hr\=0 & hr\=12
   then do;
      if hr=1
      then do
         h.hr=h.hr 'heure'          /* ajoute heure sauf a midi/minuit */
         accord = 'e'              /* french accord of participe pass� */
         end
      else do
         h.hr=h.hr 'heures'         /* ajoute heure sauf a midi/minuit */
         accord = 'es'
         end
      end;
   else do
      accord = ''
      end

mod=mn//5

select
   when mod=0 then xt=''                                      /* exact */
   when mod=1 then xt=', légèrement passé' || accord
   when mod=2 then xt='passé' || accord
   when mod=3 then xt='bientôt'
   when mod=4 then xt='presque'
   end                                                       /* select */

mn=mn+2                                                    /* round up */
mn=mn-(mn//5)                                     /* to nearest 5 mins */

select
   when mn=0  then yt='pile'
   when mn=60 then do; mn=0; yt='pile'; end;
   when mn= 5 then yt='cinq'
   when mn=10 then yt='dix'
   when mn=15 then yt='et quart'
   when mn=20 then yt='vingt'
   when mn=25 then yt='vingt-cinq'
   when mn=30 then do
                     yt='et demi'
                     if (hr \= 0) then yt = yt || 'e'
                   end
   when mn=35 then yt='moins vingt-cinq'
   when mn=40 then yt='moins vingt'
   when mn=45 then yt='moins le quart'
   when mn=50 then yt='moins dix'
   when mn=55 then yt='moins cinq'
   end

if xt=''
   then ot=ot h.hr yt;
   else if mod<3
           then if mn=0 then ot=ot h.hr xt;
                        else ot=ot h.hr yt xt;
           else if mn=0 then ot=ot xt h.hr;
                        else ot=ot xt h.hr yt;
ot=ot'.'
if \stack
   then do
      say
      say ot
      if mod=0 & mn//15=0
         then call chime
      say
      end
   else push ot
return

chime:                                                  /* Give chimes */
if mn//60=0
   then do
      chime='Dong'
      num=hr
      if num=0 then num=12
      end
   else do                                                  /* quarter */
      chime='Ding-Dong'
      num=trunc(mn/15)
      end
ot='('chime
do num-1
   ot=ot||',' chime
   end
ot=ot||'!)'
say
say ot
return                                                        /* chime */

tell: say
parse source . . . . . en .
say en "donne l'heure en français."
say "Exécutez" en "sans paramètre pour avoir l'heure, ou avec"
say "l'option 'STACK' pour avoir le résultat dans le stack."
return
