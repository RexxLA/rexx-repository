
/* ZEDPFLAG   N  8         000000100000100000010000 */

snippet:
 a=zedpflag;
  If substr(a,1,1)=1  Then  caps  = 'ON';      Else caps  ='OFF'
  If substr(a,2,1)=1  Then  nonot = 'OFF';     Else nonot ='ON'
  If substr(a,3,1)=1  Then  hex   = 'ON';      Else hex   ='OFF'
  If substr(a,4,1)=1  Then  hexs  = 'VERT';    Else hexs  ='DATA';
  If substr(a,5,1)=1  Then  pack  = 'ON';      Else pack  ='OFF'
  If substr(a,6,1)=1  Then  nulls = 'ON';      Else nulls ='OFF'
  If substr(a,7,1)=1  Then  nulla = 'ALL';     Else nulla ='STD'
  If substr(a,8,1)=1  Then  numd  = 'ON';      Else numd  ='OFF'
  If substr(a,9,1)=1  Then  numb  = 'ON';      Else numb  ='OFF'
  If substr(a,10,1)=1 Then  numc  = 'COBOL'    Else numc  =''
  If substr(a,11,1)=1 Then  nums  = 'STD';     Else nums  =''
  If substr(a,12,1)=1 Then  num6  = 'STD6';    Else num6  =''
  If substr(a,13,1)=1 Then  tabs  = 'ON';      Else tabs  ='OFF'
  If substr(a,14,1)=1 Then  taba  = 'ALL';     Else taba  ='STD'
  If substr(a,15,1)=1 Then  tabi  = 'ON';      Else tabi  ='OFF'
  If substr(a,16,1)=1 Then  tabo  = 'ON';      Else tabo  ='OFF'
  If substr(a,17,1)=1 Then  auton = 'ON';      Else auton ='OFF'
  If substr(a,18,1)=1 Then  print = 'ON';      Else print ='OFF'
  If substr(a,19,1)=1 Then  stats = 'ON';      Else stats ='OFF'
  If substr(a,20,1)=1 Then  recvr = 'ON';      Else recvr ='OFF'
  If substr(a,21,1)=1 Then  lock  = 'LOCK'     Else lock  ='UNLOCK'
  If substr(a,22,1)=1 Then  autsa = 'ON';      Else autsa ='OFF'
  If substr(a,23,1)=1 Then  autsp = 'PROMPT';  Else autsp ='NOPROMPT'
  If substr(a,24,1)=1 Then  old   = 'ON';      Else old   ='OFF'
/*
And the results as shown on the panel:
                                                                       
CAPS    On/Off    ===> OFF       TABS     On/Off          ===> ON      
NOTE    On/Off    ===> ON                 Any/Std         ===> STD     
HEX     On/Off    ===> OFF                Input           ===> OFF     
        Vert/Data ===> DATA               Output          ===> OFF     
PACK    On/Off    ===> OFF       AUTONUM  On/Off          ===> OFF     
NULLS   On/Off    ===> OFF       PRINT    On/Off          ===> OFF     
        All/Std   ===> STD       STATS    On/Off          ===> OFF     
DISPLAY On/Off    ===> OFF       RECOVER  On/Off          ===> ON      
NUMBER  On/Off    ===> ON        LOCK     Lock/Unlock     ===>         
        Cobol     ===> 0         AUTOSAVE On/Off          ===> OFF     
        Std       ===>                    Prompt/Noprompt ===> NOPROMP 
        Std6      ===> STD6      OLD      Yes/No          ===> OFF     
*/