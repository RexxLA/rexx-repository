/* REXX ****************************************************************
* Generated from SCBTRACE.SRC  for I22 by D:\conform\GENX.CMD
***********************************************************************/
/***********************************************************************
* Bif TRACE (syntax)
***********************************************************************/
/*********************************************************************
* Standard prolog for EXEC's generated from source "fn SRCE"
**********************************************************************/
Parse Version sys rexxlevel . ; newlang=(rexxlevel>'3.40')
host=("RIGHT"(sys,3)='370')   ; rxb=("RIGHT"(sys,4)='C370')
Signal On Syntax
Signal On Novalue
Signal On Halt
cnt.=0; vparm=''                    /* Initialize counters , etc.     */
g_.=''
  Parse Value 26 41 42 With xrc1 xrc2 xrc3
Parse Upper Arg . '(' opt
If pos('DEB',opt)>0 Then
  g_.0debug=1
id='** id not set **'
If "ARG"(1)='?' Then Do;
  Say 'This is a test case for REXX Function Test'; Exit 6; End;
Signal start

SYNTAX:
  If g_.0debug=1 Then Say 'SYNTAX id='id 'sigl='sigl
  tracestate=Trace()
  Trace Off
  synline=sigl
  Call protectrep
  back=back()
  If pos('S',id)=0 Then Do
    Say '    SYNTAX raised unexpectedly in line' synline
    Say '      rc='rc '('"ERRORTEXT"(rc)')'
    Say '   '"BRIGHT"('Testcase prematurely ended')
    Say ' Just in case: back='back
    Call err synline
    Say 'look around'
/***********************************************************************
* WAIT - include code to pause in case of problems
* 911107 PA enhanced for DEBUG mode
***********************************************************************/
  If g_.0debug=1 Then Do
    Say 'Look around, resume with TRACE O'
    Trace ?r
    Nop
    End
  Else Do
    Say 'WAIT.SRC lets you see the problem for ten seconds'
    Call time 'r'
    Do While time('e')<10
      End
    End
    Nop
    Signal exit
    End
  Else Do
    If rc<>xrc Then Do
      Parse Source s
      Call lineout 'rcsrc.err',s id '>'rc'>'xrc
      Call err synline
      Say '   subcase' id"BRIGHT"('rc='rc)'('"ERRORTEXT"(rc)') '||,
                                 'and'"BRIGHT"('not' xrc)'as expected.'
      End
    Else Call ok
    End
  id=''; xrc=0; sigl=''
  Signal On Syntax
  Trace Value tracestate
  Signal Value back

NOVALUE:
  If g_.0debug=1 Then Say 'NOVALUE id='id 'sigl='sigl
  tracestate=Trace()
  Trace Off
  novline=sigl
  Call protectrep
  If pos('N',id)=0 Then Do
    Say 'NOVALUE raised unexpectedly in line' novline
    If host=0 Then Do
      Say condition('d')
      Call ask
      End
    Call err
    Say 'Test case ended prematurely'
    Signal exit
    End
  If newlang Then
    Call ver "CONDITION"('D'),xnam
  xnam=''                           /* forget it                     */
  Call ok
  back=back(); id=''; sigl=''
  Signal On Novalue
  Trace Value tracestate
  Signal Value back

HALT: Say 'HALT condition, sigl='sigl; Trace ?I; Say 'look around'; Exit

OK: inc_ok: cnt.ok=inc(cnt.ok); Return
ERR: errline="ARG"(1); If errline='' Then errline=sigl
  errmsg="BRIGHT"('error')
  If "DATATYPE"(errline)='NUM' Then errmsg=errmsg 'in line' errline
  Else                              errmsg=errmsg errline
  Say errmsg
  cnt.err=inc(cnt.err);  Return
INC: Numeric Fuzz 0; Numeric Digits 9; Return "ARG"(1)+1
PROTECTREP:
  if cnt.id>cnt.0prot Then Do
    Call err 'Repeated problem with id='id'. Program terminates.'
    Signal Exit
    End
  cnt.id=inc(cnt.id); Return
BACK: Parse Var id back '-';
  back=strip(back,'B','N')
  back=strip(back,'B','S')
  Return 'R'back
inc_err: cnt.err=inc(cnt.err); Return
ver: Procedure Expose g_. id cnt. sigl
  Parse Arg r,e
  If r==e Then
    Call inc_ok
  Else Do
    ver_line=sigl
    Say 'problem with id='id
    Call 'VER' r,e
    Call inc_err;
    Say 'Look around, ver was called from line' ver_line
/***********************************************************************
* WAIT - include code to pause in case of problems
* 911107 PA enhanced for DEBUG mode
***********************************************************************/
  If g_.0debug=1 Then Do
    Say 'Look around, resume with TRACE O'
    Trace ?r
    Nop
    End
  Else Do
    Say 'WAIT.SRC lets you see the problem for ten seconds'
    Call time 'r'
    Do While time('e')<10
      End
    End
    Nop
    End
  Return
verend:
  Numeric Fuzz 0
  Numeric Digits 9
  Say 'cnt.ok='cnt.ok
  Say 'cnt.err='cnt.err
  Parse Source s '.'
  sb=lastpos('\',s)
  tc=substr(s,sb+1,8)
  log=tc date('S') time()
  If cnt.err=0 Then  log=log 'ok,    cnt.ok='cnt.ok
               Else  log=log 'ERROR, cnt.ok='cnt.ok 'cnt.err='cnt.err
  Call lineout 'test.log',log
  Call stream  'test.log','c','close'
  Return 12*(cnt.err<>0)

EXIT:
Exit verend(vparm)

ask: Say 'look around';
/***********************************************************************
* WAIT - include code to pause in case of problems
* 911107 PA enhanced for DEBUG mode
***********************************************************************/
  If g_.0debug=1 Then Do
    Say 'Look around, resume with TRACE O'
    Trace ?r
    Nop
    End
  Else Do
    Say 'WAIT.SRC lets you see the problem for ten seconds'
    Call time 'r'
    Do While time('e')<10
      End
    End
Nop; Exit


START:

validopts='?acefilnorACEFILNOR'
/***********************************************************************
* Test all one-character arguments
* Note Call trace '?' turns on interactive trace
*  which is cancelled by Call trace '?' immediately after that
***********************************************************************/
x=0
loop1:  a=d2c(x)
        If verify(a,validopts)=1 Then Do
          id=1'S-'||x; xrc=24
          goodopt=0
          End
        Else Do
          id=1'-'||x
          goodopt=1
          End
        tp=trace()                  /* trace setting before          */
        Select
          When a='?' Then Do
            z=trace(a)              /* the invocation under test     */
            ta=trace('?')           /* trace setting after           */
                                    /*   resetting the interactive tr*/
            Call trace 'o'          /* turn off trace anyway         */
            te='?'tp                /* expected result               */
            End
          Otherwise Do
            z=trace(a)
            ta=trace()
            Call trace 'o'
            te=translate(left(a,1))
            End
          End
        Call ver ta,te
        Call ver goodopt,1
        Signal loop1e
R1:     Call ok
loop1e: x=x+1
        if x<256 then signal loop1

/***********************************************************************
* Test ?||all characters
* Note Call trace '?x' turns on interactive trace
*  which is cancelled by Call trace '?' immediately after that
* Call trace ?x raises syntax and no interactive tracing is started
* Another observation
*  Call trace '?O'
*  Say trace('?')  -> 'O'
***********************************************************************/
x=0
loop2:  a='?'d2c(x)
        if verify(right(a,1),validopts)=1 then Do
          id=2'S-'||x; xrc=24
          goodopt=0
          End
        Else Do
          id=2'-'||x
          goodopt=1
          End
        If a='??' Then Do
          z=trace(a)                /* the invocation under test     */
          ta=trace('?')             /* trace setting after           */
                                    /*   resetting the interactive tr*/
          Call trace 'o'            /* turn off trace anyway         */
          te='O'                    /* expected result               */
          End
        Else Do
          z=trace(a)
          ta=trace('?')
          Call trace 'o'
          te=left(translate(a),2)
          If te='?O' Then
            te='O'
          If te='?!' Then
            te='?!N'
          End
        Call ver ta,te
        Call ver goodopt,1
        Signal loop2e
R2:     Call ok
loop2e: x=x+1
        if x<265 then signal loop2

/***********************************************************************
* test if a very long argument works
***********************************************************************/
id=3; z=trace(copies('A',100000)); res=trace('o')
      Call VER res,'A'

/***********************************************************************
* Test that '?' after some valid char option is ignored
* trace('A?') == trace('A')
***********************************************************************/
opts='acefilnorACEFILNOR'
Do i=1 To Length(opts)
  id=4'-'i
  a=Substr(opts,i,1)||'?'
  z=trace(a)
  ta=trace()
  Call trace 'o'
  Call ver ta,translate(left(a,1))
  End

/***********************************************************************
* Test that only the first char is significant
* trace('Agarbage') == trace('A')
***********************************************************************/
append='@!bBdDgGhHjJ'
Do i=1 To Length(opts)
  id=5'-'i
  a=Substr(opts,i,1)||Substr(append,i,i)
  z=trace(a)
  ta=trace()
  Call trace 'o'
  Call ver ta,translate(left(a,1))
  End

/***********************************************************************
* Test that only the first char after the '?' is significant
* trace('?Agarbage') == trace('?A')
***********************************************************************/
append='@!bBdDgGhHjJ'
Do i=1 To Length(opts)
  id=6'-'i
  a='?'||Substr(opts,i,1)||Substr(append,i,i)
  z=trace(a)
  ta=trace('?')
  Call trace 'o'
  te=translate(left(a,2))
  If te='?O' Then
    te='O'
  Call ver ta,te
  End

id=7N; xnam='NOVAL'; xre=trace(noval);    Call Err; R7:
id=8N; xnam='NOVAL'; xre=trace('?'noval); Call Err; R8:

Signal Off Novalue
z=trace('O')
id=9;   xre=trace(noval);     Call Ver trace(),'N'
z=trace('?O')
id=10;  xre=trace('?'noval);           Call Ver trace('?'),'?N'
id=11S; xrc=24; xre=trace(xnoval);     Call Err; R11:
id=12S; xrc=24; xre=trace('?'xnoval);  Call Err; R12:
a=1                                 /* should *not* be traced        */
Signal EXIT
