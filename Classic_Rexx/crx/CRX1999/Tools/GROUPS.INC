; Lt and Gt separated by SubNum limit?
; Keep verbs (etc) below 64 so QueryKey answer in range at clause start.
; VALUE below 31. Also KWMiddle results.
; WITH is last of those used for direct tests. $nn of Group must be < 31
; Conditions together and ordered.
; ITERATE = LEAVE + 1 and in byte.
; Mul Div => Asterisk Slash
; EXIT to TRACE simple verbs.
; Parsing keywords together.
; NORMAL STREAM STEM together
; Specials low so that $Special+$xxx in a byte.  Includes STRING
; String to VAR_SYMBOL together.
; + - = close, also + - Not.
 GroupMember 0,Eos
 GroupMember 12,Semi
 GroupMember 11,UnAccept
 GroupMember 6,Lparen
 GroupMember 3,Percent
 GroupMember 3,Asterisk
 GroupMember 3,Slash
 GroupMember 3,Rem
 GroupMember 4,Xor
 GroupMember 4,Or
 GroupMember 5,And
 GroupMember 10,Comma
 GroupMember 24,Not
 GroupMember 9,Minus
 GroupMember 9,Plus
 GroupMember 14,Eq
 GroupMember 13,Ne
 GroupMember 13,Lt
 GroupMember 13,Le
 GroupMember 13,Ge
 GroupMember 13,Gt
 GroupMember 13,Seq
 GroupMember 13,Sne
 GroupMember 13,Slt
 GroupMember 13,Sle
 GroupMember 13,Sge
 GroupMember 13,Sgt
 GroupMember 7,Rparen
 GroupMember 27,STRING
 GroupMember 25,CONST_SYMBOL
 GroupMember 26,NUMBER
 GroupMember 28,VAR_SYMBOL
 GroupMember 1,Abut
 GroupMember 1,Cat
 GroupMember 8,Power
 GroupMember 2,Assign
 GroupMember 21,VALUE
 GroupMember 16,END
 GroupMember 18,THEN
 GroupMember 17,FOR
 GroupMember 19,TO
 GroupMember 15,BY
 GroupMember 20,UNTIL
 GroupMember 22,WHILE
 GroupMember 23,WITH
 GroupMember 48,LINEIN
 GroupMember 48,SOURCE
 GroupMember 48,VERSION
 GroupMember 60,PULL
 GroupMember 68,VAR
 GroupMember 31,ARG
 GroupMember 29,ADDRESS
 GroupMember 30,APPEND
 GroupMember 32,CALL
 GroupMember 34,DO
 GroupMember 36,ELSE
 GroupMember 51,NOP
 GroupMember 46,INTERPRET
 GroupMember 46,OPTIONS
 GroupMember 39,EXIT
 GroupMember 39,PUSH
 GroupMember 39,QUEUE
 GroupMember 39,RETURN
 GroupMember 39,SAY
 GroupMember 66,TRACE
 GroupMember 47,LEAVE
 GroupMember 47,ITERATE
 GroupMember 35,DROP
 GroupMember 40,EXPOSE
 GroupMember 63,SIGNAL
 GroupMember 49,SYNTAX
 GroupMember 49,LOSTDIGITS
 GroupMember 49,NOVALUE
 GroupMember 41,NOTREADY
 GroupMember 41,FAILURE
 GroupMember 41,HALT
 GroupMember 38,ERROR
 GroupMember 67,UPPER
 GroupMember 44,IF
 GroupMember 45,INPUT
 GroupMember 50,NAME
 GroupMember 53,NUMERIC
 GroupMember 33,DIGITS
 GroupMember 33,FUZZ
 GroupMember 43,FORM
 GroupMember 37,ENGINEERING
 GroupMember 37,SCIENTIFIC
 GroupMember 56,OTHERWISE
 GroupMember 57,OUTPUT
 GroupMember 58,PARSE
 GroupMember 59,PROCEDURE
 GroupMember 62,SELECT
 GroupMember 69,WHEN
 GroupMember 61,REPLACE
 GroupMember 64,STEM
 GroupMember 65,STREAM
 GroupMember 52,NORMAL
 GroupMember 42,FOREVER
 GroupMember 54,OFF
 GroupMember 55,ON
