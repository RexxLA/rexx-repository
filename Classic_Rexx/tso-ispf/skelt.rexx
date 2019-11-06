)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW)  SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH) SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)  SKIP(ON)
)BODY EXPAND(บบ)
%บ-บ
     panel title
     +บ-บ
%Command ===>_ZCMD
                                                             %Scroll ===>_ZAMT+
+ column titles
)MODEL
_z!var1
)INIT
  .ZVARS = '(SEL)'
  .HELP = ISR00001
)REINIT
)PROC
  IF (.PFKEY = 'PF05')
      &PFKEY = 'F5'
      .RESP = END
)END
