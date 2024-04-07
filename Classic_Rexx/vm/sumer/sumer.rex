/* Demonstration REX program.  Translated from BASIC by Mike Cowlishaw
*                              Updated to REX V3.0 by Al Vesper 6/28/82
*/
      /* ********************************************************* */
      /* ****  SUMER - GOVERNMENT EXERCISE (IMAGINARY KINGDOM)  ** */
      /* ********************************************************* */
      /* * PROGRAM DOCUMENTATION BLOCK:                            */
      /* A = INITIAL LAND OWNED - ACRES                            */
      /* A1 = DEFENSE BUDGET                                       */
      /* A$ = RULER PERFORMANCE EVALUATIONS                        */
      /* B = PRE-INTEGERIZED BUDGET FIGURE                         */
      /* B1 = CALCULATE SCORE FOR DECISION ON DEPTARMENT NAME      */
      /* C2 = Continuation flag (1=this is a continuation game)    */
      /* D = PEOPLE DEAD FROM STARVATION                           */
      /* D5 = PEOPLE DEAD FROM THE PLAGUE                          */
      /* D9 = CUMULATIVE DEATHS                                    */
      /* E1 = ELECTION CONTRIBUTION                                */
      /* E2 = ELECTION FLAG (0 = NO ELECT, 1 = WIN, 2 = LOSS)      */
      /* E5 = FIRST ELECTION FLAG 0 = NO ELECTION YET              */
      /* E8 = CUMULATIVE ERROR COUNT                               */
      /* E9 = ERRORS THIS YEAR                                     */
      /* F3 = RULER IS A FLOP FLAG (1= FLOP)                       */
      /* F6 = ACRES LEFT AFTER PROPOSED SALE OF LAND               */
      /* F7 = NUMBER OF ACRES CAPABLE OF CULTIVATION               */
      /* F9 = BRIBE TO PRIESTS                                     */
      /* G1 = HUNGER FLAG (0 = NOT HUNGRY)                         */
      /* G2 = CUMULATIVE HARVEST QUALITY * 100                     */
      /* H3 = GROSS HARVEST                                        */
      /* I = NET STOREHOUSE BUSHELS                                */
      /* I1 = NUMBER OF IMMIGRANTS                                 */
      /* I2 = INTEREST RATE                                        */
      /* I5 = AMOUNT OF BRIBE FOR Me                               */
      /* J = RANDOM NUMBER                                         */
      /* L = AMOUNT BORROWED FROM GONZOR                           */
      /* N1 = ACRES PLANTED                                        */
      /* N2 = HARVEST DENSITY IN BUSHELS/ACRE  * 100               */
      /* N3 = NET HARVEST                                          */
      /* N4 = KLINGON THEFT                                        */
      /* N5 = ACRES OWNED                                          */
      /* N6 = PRICE OF LAND                                        */
      /* N7 = NUMBER OF ACRES BOUGHT                               */
      /* N8 = NUMBER OF ACRES SOLD                                 */
      /* N9 = FOOD ALLOCATION                                      */
      /* P = POPULATION                                            */
      /* P0 = initial population                                   */
      /* P1 = PLAGUE FLAG (1 = PLAGUE)                             */
      /* Q = BUDGET QUANTITY INPUT                                 */
      /* R = CURRENT YEAR NUMBER (ZERO ORIGIN INDEXING)            */
      /* R9 = Morale counter (100=NO REVOLUTION)                   */
      /* S = SCORE                                                 */
      /* T = PERFORMANCE SCORE GRADE POINTS                        */
      /* W = BAD WEATHER FLAG (1 = STORMS)                         */
      /* X = LOOP INDEX                                            */
      /* Y = TOTAL NUMBER OF YEARS FOR THIS GAME                   */
      /* YT= TOTAL NUMBER OF YEARS For all games                   */
      /* Y$ = REMARK AT END OF REQUEST FOR ANOTHER GAME            */
      /* Z$ = DECISION TO PLAY ANOTHER GAME                        */
/*
address command; 'PUSH CON';'CP SPOOL CONSOLE STOP';'CP CLOSE CON'
*/
arg exec_name debug
  /* trace debug */
/** SUBROUTINES **/
huh='say''Enter a positive integer, OK?''; e9=e9+1; pull q c;'
status='do;''VMFCLEAR'';interpret bush;interpret serf;interpret own;interpret cult;interpret price;interpret food;end;'
bush='say''You have'' i ''bushels of grain in the warehouse.'''
serf='say''There are'' p ''subjects in your kingdom.'''
own='say''You own'' a ''acres of land'''
cult='say''   '' n1 ''of which are under cultivation.'''
price='say''Should you buy or sell any land, the price is'' n6 ''bushels per acre.'''
food='say n9 ''bushels have been allocated to feed your subjects.'''
/* Old version of "input":
input='pull q c;do while datatype(q)=''CHAR''|q<0|q='' '';if q=quit;exit;say''Enter a positive integer, OK?'';e9=e9+1;pull q c;end;'
*/
input='pull q c;do while datatype(q)=''CHAR''|q<0|q='' '';if q=quit then exit;if q=''?'' then interpret status;else;interpret huh;'
input=input 'pull q c; end'
/* subroutine to crudely square root xx */
sqrt='ss=-1; do while xx>0; ss=ss+2; xx=xx-ss; end; xx=(ss+1)%2'

      n9=0
      a$.1='ghastly'
      a$.2='appalling'
      a$.3='sluggish at best'
      a$.4='so-so'
      a$.5='good'
      a$.6='very good'
      a$.7='excellent'
      a$.8='Super Fantastic'
      Y$=' '
      t.1=20;t.2=35;t.3=50;t.4=67;t.5=75;t.6=84;t.7=95;t.8=999
      vers='1.31'
      xx=random()
restart:
      'VMFCLEAR'
      Y=random(3,8)           /* years to rule */
      say 'SUMER/Rex Version' vers ' ('Y' years of rule will be simulated)'
      say
      say 'You may enter ''quit'' to quit or ''?'' to get a status report'
      say 'any time you are prompted to enter data.'
      STATE 'SUMER DATA A0'
      if rc=0 then /* continuation */ do
        stackio '2 DISKR SUMER DATA A1 (FINIS'
        PULL INV DAY MON YR A D D9 E2 E5 E8 E9 F3 G1 G2 H3 I I1 L xx
        PULL N1 N2 N3 N4 N5 P P1 R9 W YT xx
        if inv^=vers then do
          say 'Sorry, continuation data does not match this version'
          say 'File "SUMER DATA A" not used'
          c1=0
          end
         else do;c1=1; say
              say '(Game continued from' day mon yr')';end
        end
       else c1=0
      if c1=0 then /* new start */ do
        a=400; d=0
        e2=0; e5=0; e8=0; e9=0
        H3=750; I=675; I1=10;
        N1=300; N2=250; N3=750; N4=75; N5=400; N6=15
        P=40; R9=100; W=0
        d9=0; F3=0; L=0; G1=0; P1=0; G2=0
        yt=0
        end
       else do
        n6=random(13,19)  /* price of grain */
        end
      yt=yt+y  /* totalise years */
      r=0      /* year counter */
      e9=0     /* session errors */
      p0=p     /* init pop */
      say
      Say 'My Lord and Master,'
      Say 'Absolute ruler of Sumer,'
      Say 'I, your humble servant, the Mk7 Extronic Unit,'
      say '  beg to report on the state of your domain...'
      say


  change='growth'
  /* SUBSEQUENT YEARS LOOP BACK TO NEXT STATEMENT */
newyear:
  L89:
   if d=1 then dead='one person'
    else if d=0 then dead='nobody'; else dead=d 'people'
   if i1=1 then imm='one miserable immigrant'
    else if i1=0 then imm='nobody'; else imm=i1 'immigrants'
   say 'Last year' dead 'died and' imm 'came into your domain'
   D9=D9+D
   IF I1=0 then do;
     say '(You''ve been receiving a bad press lately...)'
     end
    else If P1=1 & i1>1 then do
     say  'Most regrettably, they brought with them a mysterious plague'
     J=random(0,10)
     D5=I1*2%3+J*I1%P
     D9=D9+D5
     P=P-D5
     say 'and' d5 'people died in the ensuing epidemic.'
     end
   if g1=0 then subj='loyal subjects'
           else subj='hungry subjects'
   say 'Therefore, together with natural' change', the present population'
   say '  of Sumer is' p subj

   if p<=9 then do
     say 'We who remain have decided to leave for a healthier planet.'
     signal flop
     end
   Say
   g2=g2+n2
   say 'We planted' n1 'of your' n5 'acres last year'
   int=n2%100; dec=n2//100
   say '  and harvested' int'.'dec 'bushels per acre...'
   say 'The total harvest was therefore' h3 'bushels'
   junc='  and'
   IF W then do /* storms */
     w=0
     if n4=0 then junc='  - however'
     if h3^=0 then do
       say 'but, unfortunately, storms destroyed half your crop'
       G2=G2-N2%2
       end
     end
    else if n4^=0 then junc='  but sadly'
   if n4^=0 then say junc 'the Turks stole' n4 'bushels'
            else say junc 'the Turk raiders were successfully repelled'
   if l>0 then do
     L=((100+I2)*L)%100
     IF I>=L then do
       say '  and Gonzor collected the' l 'bushels owed him'
       I=I-L
       L=0; end
     end

   say 'Thus you now have' i 'bushels in your storehouse.'

   if i<l then do
     say 'However and alas! this is less than the' l 'bushels'
     say '  that you owe Gonzor.  He has therefore foreclosed'
     say '  on our happy kingdom.  You are deposed.'
     signal flop; end

   if e2 then do
     if e1<=0 then /* no contribution */
       if e1<0|e2^=1 then do
         say 'However, alas! a recent coup d''etat has deposed you from office.'
         signal flop
         end;
       else
       say 'Luckily, you managed to maintain your dictatorship during the year.'
      else /* contributed */
       if e2^=1 then do
         say 'Alas! you lost the election - it therefore seems that'
        flop:
         say 'frankly, Master, as a ruler you are a flop!'
         f3=1
         signal L469
         end
       else say 'luckily, the election gave you the required majority.'
     E2=0
     end /* election */
   Say
   /* TEST IF TERM OF OFFICE HAS EXPIRED */
   if r>=y then signal timeup

   if e9=1 | (r=(y%2)&e5=0) | r9<60 then do
     if e9=1 then e9=0 /* let him off if he survives the election! */
     IF E5=0 then adj='Now'
             else adj='Once again'
     E5=1
     E8=E8+E9
     E9=0
     E2=1
     say adj', a movement is afoot to oust you from office and'
     say '  your advisers urge you to obtain a mandate from the people.'
     say 'Should you decide to hold an election,'
     say '  your campaign workers may be paid in bushels of grain:'
     say 'Now, how many (if any) bushels do you wish to distribute thus?'
     interpret input
     E1=Q
     do while (E1=0 | E1>I) & I>0
       if e1=0 then do;
         say 'Oh, Master!! Theft from thy campaign workers'
         say '    is a punishable offence!'
         i5=i%10   /* 10% off! */
         say 'For a gift of but' i5 ' bushels, I guarantee that no-one shall'
         say 'expose your meanness before the populace.'
         Say; CP SL 3 SEC
         I=I-I5
         say  'Thank you, Sire.  Now, pray tell me again:'
         end
        else do /* too much */
         say 'Your generosity, Sire, is a source of continual embarrassment'
         say '  to your people...(at this juncture, you possess a mere' i ' bushels)'
         E9=E9+1
         say 'Please tell me again:'
         end
       interpret input
       E1=Q
       end
     say 'Thank you, Sire....'
     say 'An election will be held to stabilize confidence in your regime.'
     i=i-e1
     end /* oust from office */

   IF R<1 then do;
      say 'The gods decree that one bushel is required to plant one acre and'
      say '  the laws decree that one acre per person must be set aside for'
      say '  non-agricultural use'
      Say
      end
   if random(8)>6|random(i)>900 then do
     say 'Soothsayers are prophesying bad weather this summer, Master.'
     W=1 /* STORM */
     IF I<=2*P+N5+L+100 then do
       say 'That''s kind of a rough blow, Master.  If you wish, you may'
       say '  employ the priests in an effort to ward off the bad weather.'
       say 'Now, how many (if any) bushels do you wish to give the'
       say '  priests for this ceremony?'
       interpret input
       f9=q
       if f9>0 then do
         say 'Thank you, Eminence.  The priests will do their thing!!'
         /* CALC. CHANCES OF SUCCESSFUL RAIN DANCE */
         W=(1500-(F9*random()%P))%1000
         if w<0 then w=0
         end
       end
     end /* soothsayers */

   say 'This year we can buy or sell land for' n6 'bushels per acre.'
   IF 5*P>=N5 then do
     say 'However, I respectfully remind you that Sumer is becoming'
     say '    rather overcrowded, so'
     end
   do until n7=0|left>0
     say 'How many acres of land do you wish to buy this year?'
     If N6<=12 then Say '(The price is right!)'
     interpret input
     N7=Q
     left=i-n6*n7
     if left=0 then do
       say 'You will have no grain left in the storehouse for seed, stupid.'
       e9=e9+1
       end
      else if left<0 then do
       say 'Much though I would like to effect this transaction on your behalf,'
       say '  Master, it would cost' (n6*n7) ' bushels -- which is more'
       say '  than the' i 'bushels in your storehouse.'
       say '  therefore, please reconsider:'
       end
      else do
       n5=n5+n7
       i=i-n6*n7
       end
     end /* OK Buy input */
   if N7=0 then do until ok
     say  'How many acres do you wish to sell? (You own' n5')'
     IF N6>=20 then say '(The price is right!)'
     interpret input
     n8=q
     if n8=0 then ok=1
      else do /* try and sell */
       ok=0
       IF N5-N8=0 then do
         say 'Heavens, Master! you will have no land left!!'
         e9=e9+1
         end
        else if n5-n8>p then do
         n5=n5-n8
         i=i+n6*n8
         ok=1
         end
        else if n5>n8 then do
         F6=N5-N8
         say 'By gosh, Master! if' p 'people are crammed into' f6 'acres,'
         say '  there will be trouble at the palace tonight!'
         e9=e9+1
         end
        else do
         say 'Good Grief, Master.  You have only' n5 'acres.'
         e9=e9+1
         end
       end
     end /* sell ? */
   say 'As you know, Master, that means there are now' i 'bushels'
   say '  stashed in the storehouse.'
   do until ok
     say 'How many bushels of grain do you wish to distribute as food?'
     interpret input
     n9=q
     g1=0
     if n9<p then do
       g1=1
       r9=25+n9*75%p
       IF R9=25 then quan='All thy'
                else quan='Many'
       Say 'TYRANT!!' quan 'people will starve... I shall lead the revolution!!'
       e9=e9+1
       end

    IF I-N9=0 then do
      say 'You will have no grain left in the storehouse for seed'
      say 'Surely I misheard you, Master.  Pray tell me again,'
      e9=e9+1; ok=0; end
     else if i-n9<=0 then do
      say 'Think, Master. You have only' i 'bushels left in the'
      say '  storehouse'
      e9=e9+1; ok=0; end
     else do
      IF n9<2*P & n9>=p then
        say 'No point letting them get too fat, eh?, Master?'
      IF N9>=6*P then do
        say 'By Golly, Master, thy people will bloat up like Zeppelins!'
        E9=E9+1
        end
      i=i-n9
      ok=1
      end
    end /* until OK */
   say 'There are' n5-p 'acres available for cultivation, Sire'
   ok=0; do until ok
     say 'How many do you wish to plant with seed? (You have' i 'bushels)'
     interpret input
     n1=q
     f7=n5-p
     if N1<=F7%3 then do
       say 'Your distaste for agriculture is surprising, Sire'
       E9=E9+1
       end
     IF N1<=F7 & I>=n1 then ok=1
      else /* error */ do
       e9=e9+1
       if f7>i then do
         Say 'Think, master, you have only' i 'bushels left in the storehouse.'
         say '(Remember: one bushel per acre)'
         IF N1-I>=20 then do
           say 'However, your neighbor "Gonzor, the Toothless" has agreed'
           i2=random(41,99)
           l=n1-i
           say '  to lend you the necessary' l 'bushels at a modest'
           Say '  rate of' I2'% interest'
           I=I+L
           ok=1
           end
         end
        else do
         say 'Come now, Master...'
         say 'Sumer currently has only' f7 'acres capable of cultivation'
         if n1<=n5 then say '(Your people have to live somewhere)'
         end
       end /* error */
     end /* until OK */

   IF 20*P<=N1 then do
     say 'Your' p 'people are going to be hard-pressed to plant'
     say  n1 'acres this spring, Master. Watch out!'
     N9=N9+N1-30*P
     N1=30*P
     end
   i=i-n1
   if i<1 then do
     a1=0; i=0
     end
    else do
     say 'And how many of your' i 'bushels do you wish to spend'
     say '  on protecting your grain from the Turks?'
     interpret input
     A1=Q
     IF I>=A1 then do
       i=i-a1
       ok=1; end
      else do
       say 'Thou, Master, art truly afraid of the mighty Turks'
       if i=0 then do
         say 'But this year thy fears are unfounded,'
         say 'for thou hast left no grain in the storehouse for the thieves.'
         end
        else do
         say 'However thou hast a mere' i 'bushels reposing in a corner'
         say '  of your storehouse...'
         say 'I shall presume upon your desire to blow it all on the outer'
         say '  walls, rather than let it fall into the hands of the enemy.'
         end
       a1=i
       i=0
       end
     end /* anti-enemy */

   if e2^=0 then do
     J=random(50,99)
     /* CALC. CHANCE OF SURVIVING NEXT YR. WITH CONTRIB. OF E1 */
     if r9<45 | 5*J%2+E1*100%P+P*100%40 <= 300 then e2=2
     end /* e2^=0 */

   /* CALC. HARVEST */
   n2=random(150,500)
   n3=(n2*n1+50)%100
   h3=n3
   if w^=0 then N3=H3%2

   /* CALCULATE N4: KLINGON THEFT  */
   J=random(99)
   xx=(10-((N2+50)%100)-E9); if xx<1 then xx=1
signal on syntax
   N4=I*I%(2*(I+A1+1))-A1*J%100+(N3-8*A1)%xx
   IF N4<=20 then n4=0
   I=I+N3-N4

   /* Reduce morale if ruler is getting too rich */
   r9=r9-i%507
   if r9<0 then r9=1

   /* CALCULATE I1: NUMBER OF IMMIGRANTS */
   /* I1=INT(R9*(N5*n5* SQR(A1+N9) % (A*P**1.5) -4*E9-2*E8)) */
   /* 1st calc sqrt((a1+n9)%p) */
   xx=(a1+n9)*100%p  /* note will end up mult by 10 */
   interpret sqrt; xx=xx+1
   i1=((r9*n5%10*n5%a*xx%p - r9*4*e9 -r9*2*e8)+50)%100
   IF I1<0 THEN I1=0

   /* plague? */
   IF random(9)=7 then p1=1
               else p1=0

   /* Adjust for natural births and deaths */
   /* BR=birthrate = morale/7 percent, deathrate=7% */
   br=100 + r9%7 -7
   p=p*br%100
   if br>=100 then change='growth'
              else change='wastage'

   /* CALCULATE D: NUMBER OF DEATHS FROM STARVATION AND MISC CAUSES */
   /* xx=p
   interpret sqrt */
   D=(P*p*110)%(2*N9*r9+1) + (E9*random(99)+5)%10 - (20*A1)%(I+21)
   if d<0 then d=0
   IF P<D then do
      D=(P-3)*(500+J+E9*100+50)%(100*(7+E9))  /* reprieve */
      say 'Under your rule, Master, your people are fast sickening'
      IF E8*4%yt>=2 then do
        say 'and the intelligentsia are committing suicide,'
        say 'rather than suffer the results of your mistakes'
        end
      end
   /* if the number of deaths are <5% of pop., then morale improves */
   if d*20<=p then r9=r9+4
   if r9<85&d*10<=p then r9=r9+3   /* extra boost if bad */
   /* if the number of deaths are >10%, and morale is fair then drop */
   if r9>85&d*10>p then r9=r9-3

   P=P-D+I1
   /* CALC. PRICE OF LAND, affected by pop. density */
   N6=random(11,21+p*10%n5)

   say
   IF I1>=15 then do
     say 'Press ENTER to continue...'
     'CP SLEEP'
     'VMFCLEAR'
     say 'A rumor of Sumer''s prosperity is spreading to'
     say '  neighboring countries.'
     end
   select
     when r9<59 then say 'Thy people plotteth against thee!'
     when r9<71 then say 'There is muttering in dark corners!'
     when r9<83 then say 'The people are disillusioned.'
     when r9>130 then do;
                     r9=121 /* limit */
                     say 'You are being worshipped almost as a God!'
                     end
     when r9>120 then say 'Rarely before has there been such a popular ruler.'
     when r9>110 then say 'The population applaud their ruler.'
     otherwise
   end
   if r9<100 then r9=r9+1 /* reward for frightening him */
   Say
   Say  '   (A year passeth.....)'
   Say
   R=R+1
   signal newyear /* Phew */
timeup:
   say 'Honoured Master, I and your' p 'loyal subjects,'
   if d9<12*yt then life='prospered'
               else life='suffered'
   say '  having' life 'for' yt 'years under your reign,'
   say '  humbly beg to remind you that your current term of office'
   say '  has expired...'

L469:
   Say
   /* score.. */
   s=(P*8+5)*4%P0+(I+20)%40+N5%20-E8*5%yt-G1*9-Y*4
   s=s-(G2%(120*(yt+1)))*3-F3*50-(D9%(yt+1))*3%2+11*7%100
   x=0
   do until x=8|s<t.x
     x=x+1
     end
   Say 'Your performance was' A$.x
   Say
   say 'Farewell'
   Say
   Say
   say 'Score breakdown'
   Say '---------------'
   Say
   Say 'POPULATION' (P*8+5)*4%P0
   Say 'MORALE    ' (R9+2)%5
   Say 'GRAIN     ' (I%4+5)%10
   Say 'LAND      ' (N5%2+5)%10
   Say 'MISTAKES  ' (E8*5+5)%yt
   Say 'HUNGER    ' (G1*90+5)%10
   Say 'YEARS     ' (Y*40+5)%10+12
   Say 'HARVEST   ' ((G2*3%(10*(yt+1)))+5)%10+7
   Say 'FLOP      ' (F3*500+5)%10
   Say 'DEATHS    ' (D9%(yt+1)*15+5)%10+10
   Say '---------- ---'
   Say 'Overall   ' S
   Say
   J=random(); j=random()

   say
   if f3=1 | x<3 then do
     say 'Your performance was so bad, this game will not be saved!'
     c1=0
     end
    else do
     a=n5 /* new init. land owned */
     ERASE 'SUMER DATA A0'
     queue vers date() a d d9 e2 e5 e8 e9 f3 g1 g2 h3 i i1 l
     queue n1 n2 n3 n4 n5 p p1 r9 w yt   '('A$.x')'
     stackio '2 DISKW SUMER DATA A1 (FINIS CASE M'
     say 'The game status has been saved on your "A" disk, Master'
     c1=1
     end
   say
   IF X<=4 then y$='(Snicker)'
   magn='and magnificent Master?' y$
   if c1=0 then
     say 'Do you wish another game, oh wise' magn
    else
     say 'Do you wish another term of office, oh wise' magn
   say '  (Reply yes or no)'
   pull Z$ xx
   if Z$='YES' then signal restart
/*
'POP CON'
*/
   exit
syntax: src=rc; rexdump; exit src
