#!
/* The RexxAes routine encrypts and decrypts using AES               */
/* Author: Thierry Falissard Xephon MVS 176 May 2001 see CBTTAPE.org */
/* NOTA BENE the author's comments below                             */ 
	
/* Modified by Cyril Randles 2023 for unix IO                        */
/* Use four parameters/arguments                                     */
/* parameters : 	1) encryption key in hex format		     */
/* 		        2) processing option (encrypt, decrypt)      */
/* 			2) input file                                */
/* 			2) output file                               */
/* ***************************************************************** */
/* Change in RexxAes to AES logic BITXOR for short blocks            */
/* remove padding x'00' from bitxor routine call                     */
/* Add error routines and Unix IO                                    */
/* ***************************************************************** */
signal off any 
signal off notready
signal off failure
call checkparm					/* check parameters  */
trace ='N'
init_vector = '00'x
call init(128)				       /* we use AES-128 */
key = x2c(key)				 /* key must be in hex format*/
--say 'Key is :' c2x(key)
call 	Key_Expansion(key)		            /* Key expansion */
/* *******************************************************************/
/* Input for Encrypt is user data, output is  binary                 */
/* Input for Decrypt is binary, output is user data                  */
/* Encrypted data may contain control characters eg CR, LF           */
/* Encrypted data is written as variable length between 1 and 2**15-1*/
/* Length is stored as 1 or 2 bytes preceding the data               */

/* Open input and output files                        		     */
N = 0				                     /* record count */
B = 0				                     /* byte count   */
max = 32768                                   /*------------------------------------------------------------------*/
   /* Decrypting a variable-length zone of data in CBC mode
    */
    /*------------------------------------------------------------------*/
    Zone_Decipher_CBC: procedure expose init_vector ,
    Nk nNb Nr  Rcon. w. trace 
    
    parse arg zone
    chain = left(init_vector,16,'00'x)		/* initialize CBC chaining */
    output_zone = ''								/* initialize output zone  */
    
    /* Main loop to process a 16-byte block - CBC decryption		   	*/
    do i = 1 to length(zone)%16
      block = substr(zone,1+16*(i-1),16) /* take a block in the zone */
      block = bitxor(AES_Inv_cipher(block),chain) 	/* CBC deciphering*/
      chain = substr(zone,1+16*(i-1),16)	  /* reinit chaining value */
      output_zone = output_zone || block	 /* concat resulting block */
    end
    
    /* Process last block with length < 16, if any  						*/
    /* The last block is deciphered using a CFB encryption mode,		*/
    /* in order to let the length of the output zone inchanged			*/
    /* isolate last block of data */
    lastblock_length = length(zone) - 16*(length(zone)%16)
    if lastblock_length = 0 then return output_zone
    
    lastblock = substr(zone,length(zone)-lastblock_length+1)
    /* bitxor changed cgr */
    --block = bitxor(AES_cipher(chain),lastblock. '00'x) /* CFB mode */
    block = bitxor(AES_cipher(chain),lastblock) /* CFB mode */
    return output_zone || left(block, lastblock_length)
    
    /*------------------------------------------------------------------*/
    /* In the AddRoundKey() transformation, a Round Key is added to	  */
    /* the State by a simple bitwise XOR operation. Each Round Key		  */
    /* consists of Nb words from the key schedule.							*/
    /*------------------------------------------------------------------*/
    AddRoundKey: procedure expose w.
    parse arg state,round			/* argument must be char, 16 bytes */
    if length(state) <> 16 then call Err 55
    j = round*4		; word = w.j
    j = j+1 ; word = word || w.j
    j = j+1 ; word = word || w.j
    j = j+1 ; word = word || w.j
    return bitxor(state,word)
    /*------------------------------------------------------------------*/
    /* The MixColumns() transformation operates on the State
     */
     /* column-by-colum, treating each column as a four-term polynomial */
     /*------------------------------------------------------------------*/
     MixColumns: procedure
     parse arg state					 /* argument must be char, 16 bytes */
     if length(state) <> 16 then call Err 8
     col.0 = substr(state,1,4)		;		col.1 = substr(state,5,4)
     col.2 = substr(state,9,4)		;		col.3 = substr(state,13,4)
     col.0 = Mixcol(col.0) ; col.1 = Mixcol(col.1)
     col.2 = Mixcol(col.2) ; col.3 = Mixcol(col.3)
     return col.0||col.1||col.2||col.3
     /*------------------------------------------------------------------*/
     /* InvMixColumns() is the inverse of the MixColumns() transformation*/
     /*------------------------------------------------------------------*/
     InvMixColumns: procedure
     parse arg state					/* argument must be char, 16 bytes */
     if length(state) <> 16 then call Err 8
     col.0 = substr(state,1,4)	;		col.1 = substr(state,5,4)
     col.2 = substr(state,9,4)	;		col.3 = substr(state,13,4)
     col.0 = InvMixcol(col.0) ; col.1 = InvMixcol(col.1)
     col.2 = InvMixcol(col.2) ; col.3 = InvMixcol(col.3)
     return col.0||col.1||col.2||col.3
     /*..................................................................*/
     /* Mixing a column according to the MixColumns function (encryption)*/
     /*..................................................................*/
     Mixcol: procedure
     parse arg col
     if length(col) <> 4 then call Err 19
     return Mix0(col) || Mix1(col) || Mix2(col) || Mix3(col)
     /*..................................................................*/
     /* Mixing a column according to InvMixColumns function (decryption) */
     /*..................................................................*/
     InvMixcol: procedure
     parse arg col
     if length(col) <> 4 then call Err 19
     return Mix4(col) || Mix5(col) || Mix6(col) || Mix7(col)
     /*..................................................................*/
     /* Mix a column ; used by MixColumns for encryption					  */
     /*..................................................................*/
     Mix0: procedure
     parse arg word
     if length(word) <> 4 then call Err 20
     s.0 = substr(word,1,1) ; s.1 = substr(word,2,1)
     s.2 = substr(word,3,1) ; s.3 = substr(word,4,1)
     r1 = d2c( xtime(c2d(s.0)) ) 				/* multiply by '02'x	*/
     r2 = bitxor(s.1,d2c( xtime( c2d(s.1) ) ) )  /* multiply by '03'x 	*/
     return bitxor(bitxor(bitxor(r1,r2),s.2),s.3)
     
     
     /*..................................................................*/
     /* Mix a column ; used by MixColumns for encryption
      */
      /*..................................................................*/
      Mix1: procedure
      parse arg word
      if length(word) <> 4 then call Err 21
      s.0 = substr(word,1,1) ; s.1 = substr(word,2,1)
      s.2 = substr(word,3,1) ; s.3 = substr(word,4,1)
      r1 = d2c( xtime(c2d(s.1)) )		/* multiply by '02'x  */
      r2 = bitxor(s.2,d2c( xtime( c2d(s.2) ) ) ) /* multiply by '03'x */
      
      return bitxor(bitxor(bitxor(r1,r2),s.0),s.3)
      /*..................................................................*/
      /* Mix a column ; used by MixColumns for encryption					  */
      /*..................................................................*/
      Mix2: procedure
      parse arg word
      if length(word) <> 4 then call Err 22
      s.0 = substr(word,1,1) ; s.1 = substr(word,2,1)
      s.2 = substr(word,3,1) ; s.3 = substr(word,4,1)
      r1 = d2c( xtime(c2d(s.2)) )					 /* multiply by '02'x   */
      r2 = bitxor(s.3,d2c( xtime( c2d(s.3) ) ) ) /* multiply by '03'x */
      
      return bitxor(bitxor(bitxor(r1,r2),s.0),s.1)
      /*..................................................................*/
      /* Mix a column ; used by MixColumns for encryption                 */
      /*..................................................................*/
      Mix3: procedure
      parse arg word
      if length(word) <> 4 then call Err 23
      s.0 = substr(word,1,1) ; s.1 = substr(word,2,1)
      s.2 = substr(word,3,1) ; s.3 = substr(word,4,1)
      r1 = d2c( xtime(c2d(s.3)) )					/* multiply by '02'x */
      r2 = bitxor(s.0,d2c( xtime( c2d(s.0) ) ) )  /* multiply by '03'x	*/
      return bitxor(bitxor(bitxor(r1,r2),s.1),s.2)
      
      
      /*..................................................................*/
      /* Mix a column ; used by InvMixColumns for decryption */
      /*..................................................................*/
      
      Mix4: procedure
      parse arg word
      if length(word) <> 4 then call Err 21
      s.0 = substr(word,1,1) ; s.1 = substr(word,2,1)
      s.2 = substr(word,3,1) ; s.3 = substr(word,4,1)
      
      
      r1 = mult(c2d(s.0),14)  		/* multiply by '0e'x */
      r2 = mult(c2d(s.1),11)			/* multiply by '0b'x */
      r3 = mult(c2d(s.2),13)			/* multiply by '0d'x */
      r4 = mult(c2d(s.3),09)			/* multiply by '09'x */
      
      
      return bitxor(bitxor(bitxor(r1,r2),r3),r4)
      /*..................................................................*/
      /* Mix a column ; used by InvMixColumns for decryption
       */
       /*..................................................................*/
       Mix5: procedure
       parse arg word
       if length(word) <> 4 then call Err 22
       s.0 = substr(word,1,1) ; s.1 = substr(word,2,1)
       s.2 = substr(word,3,1) ; s.3 = substr(word,4,1)
       r1 = mult(c2d(s.0),09)								/* multiply by '09'x	*/
       r2 = mult(c2d(s.1),14)								/* multiply by '0e'x	*/
       r3 = mult(c2d(s.2),11)								/* multiply by '0b'x	*/
       r4 = mult(c2d(s.3),13)								/* multiply by '0d'x	*/
       return bitxor(bitxor(bitxor(r1,r2),r3),r4)
       /*..................................................................*/
       /* Mix a column ; used by InvMixColumns for decryption
	*/
	/*..................................................................*/
	Mix6: procedure
	parse arg word
	if length(word) <> 4 then call Err 23
	s.0 = substr(word,1,1) ; s.1 = substr(word,2,1)
	s.2 = substr(word,3,1) ; s.3 = substr(word,4,1)
	r1 = mult(c2d(s.0),13)			/* multiply by '0d'x	*/
	r2 = mult(c2d(s.1),09)			/* multiply by '09'x	*/
	r3 = mult(c2d(s.2),14)			/* multiply by '0e'x	*/
	r4 = mult(c2d(s.3),11)			/* multiply by '0b'x	*/
	
	return bitxor(bitxor(bitxor(r1,r2),r3),r4)
	/*..................................................................*/
	/* Mix a column ; used by InvMixColumns for decryption
	 */
	 /*..................................................................*/
	 Mix7: procedure
	 parse arg word
	 if length(word) <> 4 then call Err 23
	 s.0 = substr(word,1,1) ; s.1 = substr(word,2,1)
	 s.2 = substr(word,3,1) ; s.3 = substr(word,4,1)
	 r1 = mult(c2d(s.0),11)				/* multiply by '0b'x	*/
	 r2 = mult(c2d(s.1),13)				/* multiply by '0d'x	*/
	 r3 = mult(c2d(s.2),09)				/* multiply by '09'x	*/
	 r4 = mult(c2d(s.3),14)				/* multiply by '0e'x	*/
	 return bitxor(bitxor(bitxor(r1,r2),r3),r4)
	 
	 
/*------------------------------------------------------------------*/
/* In the ShiftRows() transformation, the bytes in the last three*/
/* rows of the State are cyclically shifted over different numbers */
/* of bytes (offsets). The first row, Row 0, is not shifted.  
 */
 /*------------------------------------------------------------------*/
 ShiftRows: procedure
 parse arg state
 /* argument must be char, 16 bytes */
 if length(state) <> 16 then call Err 8
 s2 = substr(row(state,2),2,3) || substr(row(state,2),1,1)
 s3 = substr(row(state,3),3,2) || substr(row(state,3),1,2)
 s4 = substr(row(state,4),4,1) || substr(row(state,4),1,3)
 result = row(state,1) || s2 || s3 || s4			/* new rows */
 return row(result,1)||row(result,2)||row(result,3)||row(result,4)
 /*------------------------------------------------------------------*/
 /* InvShiftRows() is the inverse of the ShiftRows() transformation. */
 /*------------------------------------------------------------------*/
 InvShiftRows: procedure
 parse arg state
 /* argument must be char, 16 bytes */
 if length(state) <> 16 then call Err 8
 s2 = substr(row(state,2),4,1) || substr(row(state,2),1,3)
 s3 = substr(row(state,3),3,2) || substr(row(state,3),1,2)
 s4 = substr(row(state,4),2,3) || substr(row(state,4),1,1)
 result = row(state,1) || s2 || s3 || s4		/* new rows */
 return row(result,1)||row(result,2)||row(result,3)||row(result,4)

 /*------------------------------------------------------------------*/
 /* Row : return a 4-byte row from a 16-byte state.
  */
  /* Not specific to AES, just convenient here.
   */
   /*------------------------------------------------------------------*/
   Row: procedure
   parse arg state,i
   /* argument must be char, 16 bytes */
   if length(state) <> 16 then call Err 8
   return substr(state,i,1)||substr(state,i+4,1)||,
   substr(state,i+8,1)||substr(state,i+12,1)
   /*-------------------------------------------------------------------*/
  /**/
  /* The function RotWord() (used for key expansion) takes a 				*/
  /* word "a0,a1,a2,a3" as input, performs a cyclic permutation, 		*/
  /* and returns the word "a1,a2,a3,a0". */
  /*-------------------------------------------------------------------*/
  RotWord: procedure
  Parse arg x 						  /* argument must be char. 4 bytes */
  if length(x) <> 4 then call Err 9  
  return right(x,3)||left(x,1)
  /*------------------------------------------------------------------*/
  /* Binary polynomial multiplication defined in the AES.
   */
   /* Used only for decryption (InvMixcolumns function)
    */
    /*------------------------------------------------------------------*/
    
    mult: procedure
    arg a,b
    /* arguments must be decimal, result is char */
    if a > 255 then say 'a=' a '(or' d2x(a) 'in hex) is in error'
    if b > 255 then say 'b=' b '(or' d2x(b) 'in hex) is in error'
    res = '00'x
    if bitand('01'x,d2c(b)) = '01'x then res = d2c(a)
    a = xtime(a)
    if bitand('02'x,d2c(b)) = '02'x then res = bitxor(d2c(a),res)
    a = xtime(a)
    if bitand('04'x,d2c(b)) = '04'x then res = bitxor(d2c(a),res)
    a = xtime(a)
    if bitand('08'x,d2c(b)) = '08'x then res = bitxor(d2c(a),res)
    a = xtime(a)
    if bitand('10'x,d2c(b)) = '10'x then res = bitxor(d2c(a),res)
    a = xtime(a)
    if bitand('20'x,d2c(b)) = '20'x then res = bitxor(d2c(a),res)
    a = xtime(a)
    if bitand('40'x,d2c(b)) = '40'x then res = bitxor(d2c(a),res)
    a = xtime(a)
    if bitand('80'x,d2c(b)) = '80'x then res = bitxor(d2c(a),res)
    return res
    
    /*------------------------------------------------------------------*/
    /* Function xtime
     */
     /* Multiplication by x (ie,'00000010' or '02') can be implemented  */
     /* at the byte level as a left shift and a subsequent conditional  */
     /* bitwise XOR with '1b'														 */
     /*																						 */
     /*------------------------------------------------------------------*/
     xtime: procedure
     arg d											  /* argument must be decimal */
     if d > 255 then do
       say 'Error, xtime called with argument=' d
       call Err 200
     end
     if d < 128 then return d+d									/* left shift */
     else return c2d(bitxor(d2c(d+d-256),'1b'x))
     /*------------------------------------------------------------------*/
     /* The SubBytes() transformation is a non-linear byte substitution */
     /* that operates independently on each byte of the state 			 */
     /* using a substitution table (S-box).									     */
     /*------------------------------------------------------------------*/
     SubBytes: procedure
     parse arg x							   /* argument must be character */
     
     Sbox =  '637c777bf26b6fc53001672bfed7ab76'x || ,
     'ca82c97dfa5947f0add4a2af9ca472c0'x || ,
     'b7fd9326363ff7cc34a5e5f171d83115'x || ,
     '04c723c31896059a071280e2eb27b275'x || ,
     '09832c1a1b6e5aa0523bd6b329e32f84'x || ,
     '53d100ed20fcb15b6acbbe394a4c58cf'x || ,
     'd0efaafb434d338545f9027f503c9fa8'x || ,
     '51a3408f929d38f5bcb6da2110fff3d2'x || ,
     'cd0c13ec5f974417c4a77e3d645d1973'x || ,
     '60814fdc222a908846eeb814de5e0bdb'x || ,
     'e0323a0a4906245cc2d3ac629195e479'x || ,
     'e7c8376d8dd54ea96c56f4ea657aae08'x || ,
     'ba78252e1ca6b4c6e8dd741f4bbd8b8a'x || ,
     '703eb5664803f60e613557b986c11d9e'x || ,
     'e1f8981169d98e949b1e87e9ce5528df'x || ,
     '8ca1890dbfe6426841992d0fb054bb16'x
     return translate(x,Sbox)
     
     /*------------------------------------------------------------------*/
     /* InvSubBytes() is the inverse of the byte substitution transform- */
     /* ation, in which the inverse S-box is applied to each byte
      */
      /* of the state.
       */
       /*------------------------------------------------------------------*/
       InvSubBytes: procedure
       parse arg x										/* argument must be character */
       Sbox_inv =	'52096ad53036a538bf40a39e81f3d7fb'x || ,
       '7ce339829b2fff87348e4344c4dee9cb'x || ,
       '547b9432a6c2233dee4c950b42fac34e'x || ,
       '082ea16628d924b2765ba2496d8bd125'x || ,
       '72f8f66486689816d4a45ccc5d65b692'x || ,
       '6c704850fdedb9da5e154657a78d9d84'x || ,
       '90d8ab008cbcd30af7e45805b8b34506'x || ,
       'd02c1e8fca3f0f02c1afbd0301138a6b'x || ,
       '3a9111414f67dcea97f2cfcef0b4e673'x || ,
       '96ac7422e7ad3585e2f937e81c75df6e'x || ,
       '47f11a711d29c5896fb7620eaa18be1b'x || ,
       'fc563e4bc6d279209adbc0fe78cd5af4'x || ,
       '1fdda8338807c731b11210592780ec5f'x || ,
       '60517fa919b54a0d2de57a9f93c99cef'x || ,
       'a0e03b4dae2af5b0c8ebbb3c83539961'x || ,
       '172b047eba77d626e169146355210c7d'x
       return translate(x,Sbox_inv)
       
 /*------------------------------------------------------------------*/
 /* Initial parameters ; we implement AES-128 here
  */
  /*------------------------------------------------------------------*/
  init: procedure expose Nk Nb Nr Rcon. trace
  arg type
  if type <> 128 & type <> 192 & type <> 256 then do
    say 'type=' type 'in error, must be 128, 192 or 256'
    call Err 8
  end
  /* Initialize values for AES-128 */
  Nk = 4 /* Number of 32-bit words comprising the Cipher Key. For this
     standard, Nk = 4, 6, or 8. (AES-128, AES-192, AES-256)		*/
  Nb = 4 /* Number of columns (32-bit words) comprising the State.
     For this standard, Nb = 4.												*/
  Nr = 10 /* Number of rounds, which is a function of Nk and Nb (which
     is fixed). For this standard, Nr = 10, 12, or 14.				*/
  
  if type = 192 then do
    Nk = 6 ; Nr = 12						/* AES-192 */
  end
  if type = 256 then do
    Nk = 8 ; Nr = 14							/* AES-256 */
  end
  /*
     The round constant word array, Rcon[i], contains the values given by
     [x**i-1 ,{00},{00},{00}], with x**i-1 being powers of x (x is denoted
     as {02}) in the field GF(2**8))
   */
  Rcon.1 = '01000000'x ; Rcon.2 = '02000000'x
  
  id = 2																	/* x = 02 */
  do i = 3 to Nr
    id = xtime(id)							/*compute all powers of x = 02 */
    Rcon.i = d2c(id) || '000000'x
  end
  if trace = 'Y' then say 'Initialized for' type'-bit keys'
return

/*-----------------------------------------------------------------*/
/* Key Expansion                                                   */
/*                                                                 */
/* The AES algorithm takes the Cipher Key, and performs a Key      */
/* Expansion routine to generate a key schedule. The Key Expansion */
/* generates a total of Nb (Nr + 1) words: the algorithm requires  */
/* an initial set of Nb words, and each of the Nr rounds requires  */
/* Nb words of key data.                                           */
/*                                                                 */
/* Input = key  Output = "w." array (the key schedule)             */
/*-----------------------------------------------------------------*/
Key_Expansion: procedure expose Nk Nb Nr Rcon. w. trace
parse arg key
key = left(key,4*Nk,'00'x)  /* right padding to get max key length */
if trace = 'Y' then say 'Key =' c2x(key)
i = 0
/* create word array first entries */
do while i < Nk
  w.i = substr(key,4*i+1,4)
  i = i + 1
end
/* populate other word array entries */
i = Nk
do while i < Nb*(Nr+1)
  j = i - 1; temp = w.j 
  if  i // Nk = 0 then do 
    j = i%Nk
    temp = bitxor(SubBytes(RotWord(temp)),Rcon.j)
  end
else do      
  if Nk = 8 & i // Nk = 4 then ,
  temp = SubBytes(temp)
end
j = i - Nk;  w.i = bitxor(temp,w.j)
i = i + 1
end

/* list the key schedule */
i = 0
do while i < Nb*(Nr+1)
  if trace = 'Y' then say 'w.'i '=' c2x(w.i)
  i = i + 1
end
return
/*------------------------------------------------------------------*/
/* AES-enciphering a block of 16 bytes			     					     */
/*------------------------------------------------------------------*/
AES_cipher: procedure expose Nk Nb Nr Rcon. w. trace
parse arg input
if length(input) <> 16 then call Err 'Error' 100
state = AddRoundKey(input,0)
do i = 1 to Nr-1
  state = SubBytes(state)
  if trace = 'Y' then say 'Round' i 'after subbytes' c2x(state)
  state = ShiftRows(state)
  if trace = 'Y' then say 'Round' i 'after shiftrows ' c2x(state)
  state = MixColumns(state)
  if trace = 'Y' then say 'Round' i 'after Mixcolumns ' c2x(state)
  state = AddRoundKey(state,i)
  if trace = 'Y' then say 'Round' i 'after AddRoundkey' c2x(state)
end
i = Nr
state = SubBytes(state)
if trace = 'Y' then say 'Round' i 'after subbytes' c2x(state)
state = ShiftRows(state)
if trace = 'Y' then say 'Round' i 'after shiftrows ' c2x(state)
state = AddRoundKey(state,i)
if trace = 'Y' then say 'Round' i 'after AddRoundkey' c2x(state)
return state
/*------------------------------------------------------------------*/
/* AES-deciphering a block of 16 bytes									     */
/*------------------------------------------------------------------*/
AES_Inv_cipher: procedure expose Nk Nb Nr Rcon. w. trace
parse arg input
if length(input) <> 16 then call Err 100 
state = AddRoundKey(input,Nr)
do i = Nr-1 to 1 by -1
  state = InvShiftRows(state)
  if trace = 'Y' then say 'Round' i 'after Invshiftrows ' c2x(state)
  state = InvSubBytes(state)
  if trace = 'Y' then say 'Round' i 'after Invsubbytes ' c2x(state)
  state = AddRoundKey(state,i)
  if trace = 'Y' then say 'Round' i 'after AddRoundkey ' c2x(state)
  state = InvMixColumns(state)
  if trace = 'Y' then say 'Round' i 'after InvMixcolumns' c2x(state)
end
i = 0
state = InvShiftRows(state)
if trace = 'Y' then say 'Round' i 'after Invshiftrows ' c2x(state)
state = InvSubBytes(state)
if trace = 'Y' then say 'Round' i 'after Invsubbytes ' c2x(state)
state = AddRoundKey(state,i)
if trace = 'Y' then say 'Round' i 'after AddRoundkey ' c2x(state)
Return state

/* ****************************************************************** */
/* Error routines                                                     */
/* ****************************************************************** */
Err: 
parse arg message
from = .Context~stackFrames[2]~line
name = .Context~stackFrames[2]~name
say '@'sigl  'Error' message  N-1
Exit
Error: 
say '@'sigl  'record length error ' N
Exit
Errlen: 
call Err 'record length error' length(inrec)
Exit			    
/* ****************************************************************** */

Any:
Novalue:
/* Display condition directory                                     */
cd =  condition('O')			-- obtain condition directory	
ad =  condition('A')			-- and additional directory if any 
prog = .Context~stackFrames[1]~name
signal off any
say '@'.line 'Error routine entered' prog
cd =  condition('O')			-- obtain condition directory	
ad =  condition('A')			-- and additional directory if any 
stack = .context~stackframes
say '@'.line 'Condition Directory'
do z over cd;say z cd[z];
  if cd[z]~isa(.list) then do qq over cd[z];say qq;end;
end z
trace ?R
nop
Exit  
