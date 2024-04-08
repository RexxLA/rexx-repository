```rexx
numeric Digits 4 
Parse Version v; Say v 
do i=0 To 6 
  x='0.'copies(0,i)'1234567' 
  Say right(x,16) left('>'format(x,6)'<',22) left((x+0),12) (x/1) 
  End
```
```
... 3.20 14 Jan 1983                                                  
      0.1234567 >     0.1235<          0.1235       0.1235            
     0.01234567 >     0.01235<         0.01235      0.01235           
    0.001234567 >     0.001235<        0.001235     0.001235          
   0.0001234567 >     0.0001235<       0.0001235    0.0001235         
  0.00001234567 >     0.00001235<      0.00001235   0.00001235        
 0.000001234567 >     1.235E-6<        1.235E-6     1.235E-6          
0.0000001234567 >     1.235E-7<        1.235E-7     1.235E-7          


REXX370 3.40 17 Jan 1984                                           
       0.1234567 >     0.1235<          0.1235       0.1235        
      0.01234567 >     0.01235<         0.01235      0.01235       
     0.001234567 >     0.001235<        0.001235     0.001235      
    0.0001234567 >     0.0001235<       0.0001235    0.0001235     
   0.00001234567 >     0.00001235<      0.00001235   0.00001235    
  0.000001234567 >     1.235E-6<        1.235E-6     1.235E-6      
 0.0000001234567 >     1.235E-7<        1.235E-7     1.235E-7      

REXX370 4.02 01 Dec 1998                                          
       0.1234567 >     0.1235<          0.1235       0.1235       
      0.01234567 >     0.01235<         0.01235      0.01235      
     0.001234567 >     0.001235<        0.001235     0.001235     
    0.0001234567 >     0.0001235<       0.0001235    0.0001235    
   0.00001234567 >     0.00001235<      0.00001235   0.00001235   
  0.000001234567 >     1.235E-6<        1.235E-6     1.235E-6     
 0.0000001234567 >     1.235E-7<        1.235E-7     1.235E-7     
                                    
CMS bREXX 1.0.1 Jul  5 2022                                                      
     6 *-*  SAY RIGHT(X,16) LEFT('>'FORMAT(X,6)'<',22) LEFT((X+0),12) (X/1)  END 
Error 41 running format2, line 6: Bad arithmetic conversion                      

 BREXX/370 V2R5M2 (Mar 02 2023)                                   
        0.1234567 >     0<               0.1235       0.1235      
       0.01234567 >   0.0<               0.01235      0.01235     
      0.001234567 >  0.00<               0.001235     0.001235    
     0.0001234567 > 0.000<               0.0001235    0.0001235   
    0.00001234567 >0.0000<               1.235e-05    1.235e-05   
   0.000001234567 >0.00000<              1.235e-06    1.235e-06   
  0.0000001234567 >0.000000<             1.235e-07    1.235e-07   

NetRexx 4.07 11 Mar 2024
      0.1234567 >     0.1234567<       0.1235       0.1235
     0.01234567 >     0.01234567<      0.01235      0.01235
    0.001234567 >     0.001234567<     0.001235     0.001235
   0.0001234567 >     0.0001234567<    0.0001235    0.0001235
  0.00001234567 >     0.00001234567<   0.00001235   0.00001235
 0.000001234567 >     0.000001234567<  0.000001235  0.000001235
0.0000001234567 >     0.0000001234567< 1.235E-7     1.235E-7

REXX-ooRexx_5.1.0(MT)_64-bit 6.05 9 Jan 2024
       0.1234567 >     0.1235<          0.1235       0.1235
      0.01234567 >     0.012355<        0.01235      0.01235
     0.001234567 >     0.00123556<      0.001235     0.001235
    0.0001234567 >     0.0001235567<    0.0001235    0.0001235
   0.00001234567 >     0.000012355670<  0.00001235   0.00001235
  0.000001234567 >     1.235E-6<        1.235E-6     1.235E-6
 0.0000001234567 >     1.235E-7<        1.235E-7     1.235E-7

brexx 2.1.10 Jul 19 2021
       0.1234567 >    0.<               0.1235       0.1235
      0.01234567 >    0.<               0.01235      0.01235
     0.001234567 >    0.<               0.001235     0.001235
    0.0001234567 >    0.<               0.0001235    0.0001235
   0.00001234567 >    0.<               1.235e-05    1.235e-05
  0.000001234567 >    0.<               1.235e-06    1.235e-06
 0.0000001234567 >    0.<               1.235e-07    1.235e-07

REXX 5.00 22 April 99
       0.1234567 >     0.1235<          0.1235       0.1235
      0.01234567 >     0.01235<         0.01235      0.01235
     0.001234567 >     0.001235<        0.001235     0.001235
    0.0001234567 >     0.0001235<       0.0001235    0.0001235
   0.00001234567 >     0.00001235<      0.00001235   0.00001235
  0.000001234567 >     0.000001235<     0.000001235  0.000001235
 0.0000001234567 >     1.235E-7<        1.235E-7     1.235E-7
```