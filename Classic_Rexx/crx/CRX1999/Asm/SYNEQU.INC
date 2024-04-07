$0 equ 0
$Eos equ 0*4
$12 equ 1
$Semi equ 1*4
$11 equ 2
$UnAccept equ 2*4
$6 equ 3
$Lparen equ 3*4
$3 equ 4
$Percent equ 4*4
$Asterisk equ 4*(5-1) + 1
$Slash equ 4*(5-1) + 2
$Rem equ 4*(5-1) + 3
$Xor equ 5*4
$Or equ 4*(6-1) + 1
$5 equ 6
$And equ 6*4
$10 equ 7
$Comma equ 7*4
$Not equ 8*4
$9 equ 9
$Minus equ 9*4
$Plus equ 4*(10-1) + 1
$Eq equ 10*4+3
$Ne equ 11*4
$Lt equ 4*(12-1) + 1
$Le equ 4*(12-1) + 2
$Ge equ 4*(12-1) + 3
$Gt equ 12*4
$Seq equ 4*(13-1) + 1
$Sne equ 4*(13-1) + 2
$Slt equ 4*(13-1) + 3
$Sle equ 13*4
$Sge equ 4*(14-1) + 1
$Sgt equ 4*(14-1) + 2
$7 equ 14
$Rparen equ 14*4
$STRING equ 15*4
$CONST_SYMBOL equ 16*4
$NUMBER equ 17*4
$28 equ 18
$VAR_SYMBOL equ 18*4
$1 equ 19
$Abut equ 19*4
$Cat equ 4*(20-1) + 1
$8 equ 20
$Power equ 20*4
$2 equ 21
$Assign equ 21*4
$21 equ 22
$VALUE equ 22*4
$16 equ 23
$END equ 23*4
$18 equ 24
$THEN equ 24*4
$17 equ 25
$FOR equ 25*4
$19 equ 26
$TO equ 26*4
$15 equ 27
$BY equ 27*4
$UNTIL equ 28*4
$WHILE equ 29*4
$23 equ 30
$WITH equ 30*4
$LINEIN equ 31*4
$SOURCE equ 4*(32-1) + 1
$VERSION equ 4*(32-1) + 2
$PULL equ 32*4
$VAR equ 33*4
$ARG equ 34*4
$ADDRESS equ 35*4
$APPEND equ 36*4
$CALL equ 37*4
$DO equ 38*4
$ELSE equ 39*4
$NOP equ 40*4
$INTERPRET equ 41*4
$OPTIONS equ 4*(42-1) + 1
$EXIT equ 42*4
$PUSH equ 4*(43-1) + 1
$QUEUE equ 4*(43-1) + 2
$RETURN equ 4*(43-1) + 3
$SAY equ 43*4
$TRACE equ 44*4
$LEAVE equ 45*4
$ITERATE equ 4*(46-1) + 1
$DROP equ 46*4
$EXPOSE equ 47*4
$SIGNAL equ 48*4
$SYNTAX equ 49*4
$LOSTDIGITS equ 4*(50-1) + 1
$NOVALUE equ 4*(50-1) + 2
$NOTREADY equ 50*4
$FAILURE equ 4*(51-1) + 1
$HALT equ 4*(51-1) + 2
$ERROR equ 51*4
$UPPER equ 52*4
$IF equ 53*4
$INPUT equ 54*4
$NAME equ 55*4
$NUMERIC equ 56*4
$DIGITS equ 57*4
$FUZZ equ 4*(58-1) + 1
$FORM equ 58*4
$ENGINEERING equ 59*4
$SCIENTIFIC equ 4*(60-1) + 1
$OTHERWISE equ 60*4
$OUTPUT equ 61*4
$PARSE equ 62*4
$PROCEDURE equ 63*4
$SELECT equ 64*4
$WHEN equ 65*4
$REPLACE equ 66*4
$STEM equ 67*4
$STREAM equ 68*4
$NORMAL equ 69*4
$FOREVER equ 70*4
$OFF equ 71*4
$ON equ 72*4
$sPercent equ 0
$sDrop equ 6
$sStem equ 9
$sWith equ 10
$sDropList equ 11
$sMinus equ 20
$sLength equ 23
$sEq equ 27
$sSeq equ 33
$sDigits equ 39
$sNop equ 42
$sForm equ 43
$sAddress equ 45
$sNegate equ 48
$sPositive equ 49
$sExit equ 50
$sReturns equ 53
$sNumber equ 55
$sRaise equ 57
$sLeave equ 62
$sIterate equ 63
