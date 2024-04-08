# Instructions

This clause describes the execution of instructions, and how the sequence of execution can vary from the
normal execution in order of appearance in the program.

Execution of the program begins with its first clause.  
_If we left Routine initialization to here we can leave method initialization._

## Method initialization

There is a pool for local variables.
```rexx
call Config ObjectNew
#Pool = #Outcome
```
_Set self and super_

## Routine initialization

If the routine is invoked as a function, ``#IsFunction.#NewLevel`` shall be set to ``'1'``, otherwise to ``'0'``; this
affects the processing of a subsequent RETURN instruction.
```rexx
#AllowProcedure.#NewLevel = '1'
```
Many of the initial values for a new invocation are inherited from the caller's values.
```rexx
#Digits.#NewLevel = #Digits.#Level
#Form.#NewLevel = #Form.#Level
#Fuzz.#NewLevel = #Fuzz.#Level

#StartTime.#NewLevel = #StartTime.#Level

#Tracing.#NewLevel = #Tracing.#Level
#Interactive.#NewLevel = #Interactive.#Level

call EnvAssign ACTIVE, #NewLevel, ACTIVE, #Level
call EnvAssign ALTERNATE, #NewLevel, ALTERNATE, #Level

do t=1 to 7
  Condition = word('SYNTAX HALT ERROR FAILURE NOTREADY NOVALUE LOSTDIGITS',t)
  #Enabling.Condition.#NewLevel = #Enabling.Condition.#Level
  #Instruction.Condition.#NewLevel = #Instruction.Condition.#Level
  #TrapName.Condition.#NewLevel = #TrapName.Condition.#Level
  #EventLevel.Condition.#NewLevel = #EventLevel.Condition.#Level
  end t
```
If this invocation is not caused by a condition occurring, see nnn, the state variables for the CONDITION built-in function are copied.
```rexx
#Condition.#NewLevel = #Condition.#Level
#ConditionDescription.#NewLevel = #ConditionDescription.#Level
#ConditionExtra.#NewLevel = #ConditionExtra.#Level
#ConditionInstruction.#NewLevel = #ConditionInstruction.#Level
```
Execution of the initialized routine continues at the new level of invocation.
```rexx
#Level = #NewLevel
#NewLevel = #Level + 1
```

## Clause initialization

The clause is traced before execution:
```rexx
if pos(#Tracing.#Level, 'AIR') > 0 then call #TraceSource
```
The time of the first use of DATE or TIME will be retained throughout the clause.
```rexx
#ClauseTime.#Level = ''
```
The state variable ``#LineNumber`` is set to the line number of the clause, see nnn.  
A clause other than a null clause or label or procedure instruction sets:
```rexx
#AllowProcedure.#Level = '0' /* See message 17.1 */
```

## Clause termination

```rexx
if #InhibitTrace > 0 then #InhibitTrace = #InhibitTrace - 1
```
Polling for a HALT condition occurs:
```rexx
#Response = Config Halt Query ()
if #0utcome == 'Yes' then do
  call Config Halt Reset
  call #Raise 'HALT', substr(#Response,2) /* May return */
  end
```
At the end of each clause there is a check for conditions which occurred and were delayed. It is acted on
if this is the clause in which the condition arose.
```rexx
do t=1 to 4
  #Condition=WORD('HALT FAILURE ERROR NOTREADY',t)
  /* HALT can be established during HALT handling. */
  do while #PendingNow.#Condition.#Level
     #PendingNow.#Condition.#Level = '0'
     call #Raise
     end
  end
```
Interactive tracing may be turned on via the configuration. Only a change in the setting is significant.
```rexx
call Config Trace Query
if #AtPause = 0 & #Outcome == 'Yes' & #Trace QueryPrior == 'No' then do
  /* External request for Trace '?R!' */
  #Interactive.#Level = '1'
  #Tracing.#Level = 'R'
  end
#TraceQueryPrior = #Outcome
```
_Tracing just not the same with NetRexx._

When tracing interactively, pauses occur after the execution of each clause except for CALL, DO the
second or subsequent time through the loop, END, ELSE, EXIT, ITERATE, LEAVE, OTHERWISE,
RETURN, SIGNAL, THEN and null clauses.

If the character '=' is entered in response to a pause, the prior clause is re-executed.

Anything else entered will be treated as a string of one or more clauses and executed by the language
processor. The same rules apply to the contents of the string executed by interactive trace as do for
strings executed by the INTERPRET instruction. If the execution of the string generates a syntax error,
the standard message is displayed but no condition is raised. All condition traps are disabled during
execution of the string. During execution of the string, no tracing takes place other than error or failure
return codes from commands. The special variable RC is not set by commands executed within the
string, nor is .RC.

If a TRACE instruction is executed within the string, the language processor immediately alters the trace
setting according to the TRACE instruction encountered and leaves this pause point. If no TRACE
instruction is executed within the string, the language processor simply pauses again at the same point in
the program.

At a pause point:

```rexx
if #AtPause = 0 & #Interactive.#Level & #InhibitTrace = 0 then do
  if #InhibitPauses > 0 then #InhibitPauses = #InhibitPauses-1
  else do
  #TraceInstruction = '0'
  do forever
    call Config Trace Query
    if #Outcome == 'No' & #Trace QueryPrior == 'Yes' then do
      /* External request to stop tracing. */
      #Trace_QueryPrior=#Outcome
      #Interactive.#Level = '0'
      #Tracing.#Level = 'N'
      leave
      end
    if #Outcome == 'Yes' & #Trace QueryPrior == 'No' then do
      /* External request for Trace '?R!' */
      #Trace QueryPrior = #Outcome
      #Interactive.#Level = '1'
      #Tracing.#Level = 'R'
      leave
      end
    if \#Interactive.#Level | #TraceInstruction then leave

    /* Accept input for immediate execution. */
    call Config Trace Input
    if length(#0utcome) = 0  |  #0Outcome == '=' then leave
    #AtPause = #Level
    interpret #Outcome
    #AtPause = 0
    end /* forever loop */
  if #Outcome == '=' then call #Retry /* With no return */
  end
end
```

## Instruction

### ADDRESS

For a definition of the syntax of this instruction, see nnn.

An external environment to which commands can be submitted is identified by an environment name.
Environment names are specified in the ADDRESS instruction to identify the environment to which a
command should be sent.

I/O can be redirected when submitting commands to an external environment. The submitted command's
input stream can be taken from an existing stream or from a set of compound variables with a common
stem. In the latter case (that is, when a stem is specified as the source for the commands input stream)
whole number tails are used to order input for presentation to the submitted command. Stem.0 must
contain a whole number indicating the number of compound variables to be presented, and stem. 1
through stem.n (where n=stem.0) are the compound variables to be presented to the submitted
command.

Similarly, the submitted command's output stream can be directed to a stream, or to a set of compound
variables with a given stem. In the latter case (i.e., when a stem is specified as the destination)
compound variables will be created to hold the standard output, using whole number tails as described
above. Output redirection can specify a REPLACE or APPEND option, which controls positioning prior to
the command's execution. REPLACE is the default.

I/O redirection can be persistently associated with an environment name. The term "environment" is used
to refer to an environment name together with the I/O redirections.

At any given time, there will be two environments, the active environment and the alternate environment.
When an ADDRESS instruction specifies a command to the environment, any specified I/O redirection
applies to that command's execution only, providing a third environment for the duration of the instruction.
When an ADDRESS command does not contain a command, that ADDRESS command creates a new
active environment, which includes the specified I/O redirection.

The redirections specified on the ADDRESS instruction may not be possible. If the configuration is aware
that the command processor named does not perform I/O in a manner compatible with the request, the
value of #Env_Type. may be set to 'UNUSED' as an alternative to 'STEM' and 'STREAM' where those
values are assigned in the following code.

In the following code the particular use of ``#Contains(address, expression)`` refers to an expression
immediately contained in the address.
```rexx
Addrinstr:
 /* If ADDRESS keyword alone, environments are swapped. */
 if \#Contains (address, taken constant),
  & \#Contains (address,valueexp),
  & \#Contains (address, 'WITH') then do
    call EnvAssign TRANSIENT, #Level, ACTIVE, #Level
    call EnvAssign ACTIVE, #Level, ALTERNATE, #Level
    call EnvAssign ALTERNATE, #Level, TRANSIENT, #Level
    return
    end
 /* The environment name will be explicitly specified. */
 if #Contains(address,taken constant) then
   Name = #Instance(address, taken _ constant)
 else
   Name = #Evaluate(valueexp, expression)
 if length(Name) > #LimitEnvironmentName then
   call #Raise 'SYNTAX', 29.1, Name

 if #Contains(address,expression) then do
   /* The command is evaluated (but not issued) at this point. */
   Command = #Evaluate (address, expression)
   if #Tracing.#Level == 'C'  |  #Tracing.#Level == 'A' then do
      call #Trace '>>>!
      end
   end

 call AddressSetup /* Note what is specified on the ADDRESS instruction. */
 /* If there is no command, the persistent environment is being set. */
 if \#Contains(address,expression) then do
    call EnvAssign ACTIVE, #Level, TRANSIENT, #Level
    return
    end

 call CommandIssue Command /* See nnn */

 return /* From Addrinstr */

AddressSetup:
 /* Note what is specified on the ADDRESS instruction,
 into the TRANSIENT environment. */
 EnvTail = 'TRANSIENT. '#Level
 /* Initialize with defaults. */
 #Env_Name.EnvTail = ''
 #Env_ Type.I.EnvTail = 'NORMAL'
 #Env_ Type.O.EnvTail = 'NORMAL'
 #Env_ Type.E.EnvTail = 'NORMAL'
 #Env_Resource.I.EnvTail = ''
 #Env_Resource.O.EnvTail = '!
 #Env_Resource.E.EnvTail = ''
 /* APPEND / REPLACE does not apply to input. */
 #Env_Position.I.EnvTail = 'INPUT'
 #Env_Position.O.EnvTail = 'REPLACE'
 #Env_Position.E.EnvTail = 'REPLACE'

 /* If anything follows ADDRESS, it will include the command processor name.*/
 #Env_Name.EnvTail = Name

 /* Connections may be explicitly specified. */
 if #Contains (address, connection) then do
   if #Contains(connection,input) then do /* input redirection */
     if #Contains (resourcei, 'STREAM') then do
       #Env_Type.I.EnvTail = 'STREAM'
       #Env_Resource.1.EnvTail=#Evaluate(resourcei, VAR_SYMBOL)
       end
     if #Contains (resourcei, 'STEM') then do
       #Env_Type.I.EnvTail = 'STEM'
       Temp=#Instance (resourcei,VAR_SYMBOL)
       if \#Parses(Temp, stem /* See nnn */) then
         call #Raise 'SYNTAX', 53.3, Temp
       #Env_Resource.I.EnvTail=Temp
       end
     end /* Input */

   if #Contains(connection,output) then /* output redirection */
     call NoteTarget O

   if #Contains(connection,error) then /* error redirection */
     /* The prose on the description of #Contains specifies that the
     relevant resourceo is used in NoteTarget. */
     call NoteTarget E
   end /* Connection */

return /* from AddressSetup */

NoteTarget:
  /* Note the characteristics of an output resource. */
  arg Which /* O or E */
  if #Contains (resourceo, 'STREAM') then do
    #Env_Type.Which.EnvTail='STREAM'
    #Env_Resource.Which.EnvTail=#Evaluate(resourceo, VAR_SYMBOL)
    end
  if #Contains(resourceo,'STEM') then do
    #Env_Type.Which.EnvTail='STEM'
    Temp=#Instance (resourceo, VAR_SYMBOL)
    if \#Parses(Temp, stem /* See nnn */) then
      call #Raise 'SYNTAX', 53.3, Temp
    #Env_Resource.Which.EnvTail=Temp
    end
  if #Contains (resourceo,append) then
    #Env_Position.Which.EnvTail='APPEND'
return /* From NoteTarget */

EnvAssign:
/* Copy the values that name an environment and describe its
redirections. */
  arg Lhs, LhsLevel, Rhs, RhsLevel
  #Env_Name.Lhs.LhsLevel = #Env_Name.Rhs.RhsLevel
  #Env_ Type.I.Lhs.LhsLevel = #Env_Type.I.Rhs.RhsLevel
  #Env_ Resource.I.Lhs.LhsLevel = #Env_Resource.I.Rhs.RhsLevel
  #Env_Position.I.Lhs.LhsLevel = #Env_Position.I.Rhs.RhsLevel
  #Env_ Type.O.Lhs.LhsLevel = #Env_Type.O.Rhs.RhsLevel
  #Env_Resource.O.Lhs.LhsLevel = #Env_Resource.O.Rhs.RhsLevel
  #Env_Position.O.Lhs.LhsLevel = #Env_Position.O.Rhs.RhsLevel
  #Env_ Type.E.Lhs.LhsLevel = #Env_Type.E.Rhs.RhsLevel
  #Env_Resource.E.Lhs.LhsLevel #Env_Resource.E.Rhs.RhsLevel
  #Env_Position.E.Lhs.LhsLevel #Env_Position.E.Rhs.RhsLevel
  return
```

### ARG
For a definition of the syntax of this instruction, see nnn.

The ARG instruction is a shorter form of the equivalent instruction:  
`PARSE UPPER ARG`_`template list`_

### Assignment

Assignment can occur as the result of executing a clause containing an assignment (see nnn and nnn),
or as a result of executing the VALUE built-in function, or as part of the execution of a PARSE instruction.
Assignment involves an _expression_ and a _VAR_SYMBOL_. The value of the _expression_ is determined;
see nnn.

If the _VAR_SYMBOL_ does not contain a period, or contains only one period as its last character, the
value is associated with the _VAR_SYMBOL_:
```rexx
call Var Set #Pool,VAR SYMBOL, '0',Value
```
Otherwise, a name is derived, see nnn. The value is associated with the derived name:
```rexx
call Var Set #Pool,Derived Name,'1',Value
```

### CALL

For a definition of the syntax of this instruction, see nnn.

The CALL instruction is used to invoke a routine, or is used to control trapping of conditions.

lf a _vref_ is specified that value is the name of the routine to invoke:
```rexx
if #Contains (call, vref) then
  Name = #Evaluate(vref, var_symbol)
```

If a _taken\_constant_ is specified, that name is used.
```rexx
if #Contains (call, taken constant) then
Name = #Instance(call, taken constant)
```
The name is used to invoke a routine, see nnn. If that routine does not return a result the RESULT and
.RESULT variables become uninitialized:
```rexx
call Var Drop #Pool, 'RESULT', '0!
call Var Drop #ReservedPool, '.RESULT', '0'
```

If the routine does return a result that value is assigned to RESULT and .RESULT. See nnn for an
exception to assigning results.

If the routine returns a result and the trace setting is 'R' or 'I' then a trace with that result and a tag '>>>"
shall be produced, associated with the call instruction.

If a _callon\_spec_ is specified:
```rexx
If #Contains(call,callon spec) then do
  Condition = #Instance(callon_spec,callable condition)
  #Instruction.Condition.#Level = 'CALL'
  If #Contains(callon spec, 'OFF') then
    #Enabling.Condition.#Level = 'OFF'
  else
    #Enabling.Condition.#Level = 'ON'
  /* Note whether NAME supplied. */
  If Contains (callon spec,taken constant) then
    Name = #Instance (callable condition, taken_constant)
  else
    Name = Condition
  #TrapName.Condition.#Level = Name
  end
```
### Command to the configuration
For a definition of the syntax of a command, see nnn.

A command that is not part of an ADDRESS instruction is processed in the ACTIVE environment.

```rexx
Command = #Evaluate(command, expression)
if #Tracing.#Level == 'C' | #Tracing.#Level == 'A' then
   call #Trace '>>>!'
call EnvAssign TRANSIENT, #Level, ACTIVE, #Level
call CommandiIssue Command
```
`Commandlssue` is also used to describe the ADDRESS instruction:
```rexx
CommandIssue:
  parse arg Cmd
  /* Issues the command, requested environment is TRANSIENT */
  /* This description does not require the command processor to understand
  stems, so it uses an altered environment. */
  call EnvAssign PASSED, #Level, TRANSIENT, #Level
  EnvTail = 'TRANSIENT.'#Level

  /* Note the command input. */
  if #Env_Type.I.EnvTail = 'STEM' then do
      /* Check reasonableness of the stem. */
      Stem = #Env_Resource.I.EnvTail
      Lines = value(Stem'0')
      if \datatype(Lines,'W') then
        call #Raise 'SYNTAX',54.1,Stem'0', Lines
      if Lines<0 then
        call #Raise 'SYNTAX',54.1,Stem'0', Lines
      /* Use a stream for the stem */
      #Env_ Type.I.PASSED.#Level = 'STREAM'
      call Config Stream Unique
      InputStream = #Outcome
      #Env_Resource.1I.PASSED.#Level = InputStream
      call charout InputStream , ,l
      do j = 1 to Lines
        call lineout InputStream, value(Stem || j)
        end j
      call lineout InputStream
      end

  /* Note the command output. */
  if #Env_Type.O.EnvTail = 'STEM' then do
     Stem = #Env_Resource.O.EnvTail
     if #Env_Position.O.EnvTail == 'APPEND' then do
       /* Check that Stem.0 will accept incrementing. */
       Lines=value (Stem'0');
       if \datatype(Lines,'W') then
         call #Raise 'SYNTAX',54.1,Stem'0', Lines
       if Lines<0 then
         call #Raise 'SYNTAX',54.1,Stem'0', Lines
       end
     else call value Stem'0',O
     /* Use a stream for the stem */
     #Env_Type.O.PASSED.#Level = 'STREAM'
     call Config Stream Unique
     #Env_Resource.O.PASSED.#Level = #Outcome
     end

    /* Note the command error stream. */
    if #Env_Type.E.EnvTail = 'STEM' then do
       Stem = #Env_Resource.E.EnvTail
       if #Env_Position.E.EnvTail == 'APPEND' then do
         /* Check that Stem.0 will accept incrementing. */
         Lines=value (Stem'0');
         if \datatype(Lines,'W') then
           call #Raise 'SYNTAX',54.1,Stem'0', Lines
         if Lines<0 then
           call #Raise 'SYNTAX',54.1,Stem'0', Lines
       end
     else call value Stem'0',0O
     /* Use a stream for the stem */
     #Env_ Type.E.PASSED.#Level = 'STREAM'
     call Config Stream Unique
     #Env_Resource.E.PASSED.#Level = #Outcome
     end

 #API Enabled = '1'
  call Var_Reset #Pool
  /* Specifying PASSED here implies all the
     components of that environment. */
 #Response = Config Command (PASSED, Cmd)
 #Indicator = left (#Response,1)
 Description = substr (#Response, 2)
 #API Enabled = '0'
 /* Recognize success and failure. */
if #AtPause = 0 then do
  call value 'RC', #RC
  call var Set 0, '.RC', 0, #RC
  end
select
  when #Indicator=='N' then Temp=0
  when #Indicator=='F' then Temp=-1 /* Failure */
  when #Indicator=='E' then Temp=1 /* Error */
  end
call Var Set 0, '.RS', 0, Temp
/* Process the output */
if #Env_Type.O.EnvTail='STEM' then do   /* get output into stem. */
  Stem = #Env_Resource.0O.EnvTail
  OutputStream = #Env_Resource.0O.PASSED.#Level
  do while lines (OutputStream) > 0
    call value Stem'0O',value(Stem'0')4+1
    call value Stem| |value(Stem'0'),linein (OutputStream)
    end
  end /* Stemmed Output */
if #Env_Type.E.EnvTail='STEM' then do /* get error output into stem. */
  Stem = #Env_Resource.E.EnvTail
  OutputStream = #Env_Resource.E.PASSED.#Level
  do while lines (OutputStream) > 0
    call value Stem'0O',value(Stem'0')4+1
    call value Stem| |value(Stem'0'),linein (OutputStream)
    end
  end /* Stemmed Error output */
if #Indicator \== 'N' & pos(#Tracing.#Level, 'CAIR') > 0 then
   call #Trace '+++'
if (#Indicator \== 'N' & #Tracing.#Level=='E'),
 | (#Indicator=='F' & (#Tracing.#Level=='F' | #Tracing.#Level=='N')) then do
   call #Trace '>>>!'
   call #Trace '+++!'
   end
#Condition='FAILURE'
if #Indicator='F' & #Enabling.#Condition.#Level \== 'OFF' then call #Raise 'FAILURE', Cmd
else if #Indicator='E' | #Indicator='F' then call #Raise 'ERROR', Cmd
return /* From CommandIssue */
```

The configuration may choose to perform the test for message 54.1 before or after issuing the command.

### DO

For a definition of the syntax of this instruction, see nnn.

The DO instructions is used to group instructions together and optionally to execute them repeatedly.

Executing a _do_simple_ has the same effect as executing a _nop_, except in its trace output. Executing the
_do_ending_ associated with a _do_simple_ has the same effect as executing a _nop_, except in its trace
output.

A _do_instruction_ that does not contain a _do_simple_ is equivalent, except for trace output, to a sequence of
instructions in the following order.
```rexx
#Loop = #Loop+1
#Iterate.#Loop = #Clause (IterateLabel)
#Once.#Loop = #Clause (OnceLabel)
#Leave.#Loop = #Clause (LeaveLabel)
if #Contains (do specification,assignment) then
     #Identity.#Loop = #Instance(assignment, VAR SYMBOL)
if #Contains (do specification, repexpr) then
   if \datatype(repexpr,'W') then
       call #Raise 'SYNTAX', 26.2,repexpr
   else do
       #Repeat.#Loop = repexpr+0
       if #Repeat.#Loop<0 then
          call #Raise 'SYNTAX',26.2,#Repeat.#Loop
       end
if #Contains (do specification,assignment) then do
   #StartValue.#Loop = #Evaluate (assignment, expression)
   if datatype (#StartValue.#Loop) \== 'NUM' then
       call #Raise 'SYNTAX', 41.6, #StartValue.#Loop
   #StartValue.#Loop = #StartValue.#Loop + 0
   if \#Contains (do specification,byexpr) then
       #By.#Loop = 1
   end
```

The following three assignments are made in the order in which 'TO'", 'BY' and 'FOR' appear in _docount_;
see nnn.
```rexx
if #Contains (do specification, toexpr) then do
   if datatype(toexpr) \== 'NUM' then
      call #Raise 'SYNTAX', 41.4, toexpr
   #To.#LOop = toexpr+0
if #Contains (do specification, byexpr) then do
   if datatype (byexpr) \=='NUM' then
      call #Raise 'SYNTAX', 41.5, byexpr
   #By.#Loop = byexpr+0
if #Contains (do specification, forexpr) then do
   if \datatype(forexpr, 'W') then
      call #Raise 'SYNTAX', 26.3, forexpr
   #For.#Loop = forexpr+0
   if #For.#Loop <0 then
      call #Raise 'SYNTAX', 26.3, #For.#Loop
   end
if #Contains (do specification,assignment) then do
   call value #Identity.#Loop, #StartValue.#Loop
   end
if #Contains (do specification, 'OVER') then do
   Value = #Evaluate(dorep, expression)
   #OverArray.#Loop = Value ~ makearray
   #Repeat.#Loop = #OverArray~items /* Count this downwards as if repexpr. */
   #Iidentity.#Loop = #Instance(dorep, VAR_SYMBOL)
   end
call #Goto #Once.#Loop /* to OnceLabel */
IterateLabel:
if #Contains (do specification, untilexpr) then do
  Value = #Evaluate(untilexp, expression)
  if Value == '1' then leave
  if Value \== '0' then call #Raise 'SYNTAX', 34.4, Value
  end
if #Contains (do specification, assignment) then do
   t = value (#Identity. #Loop)
   if #Indicator == 'D' then call #Raise 'NOVALUE', #Identity.#Loop
   call value #Identity.#Loop, t + #By.#Loop
   end

OnceLabel:
if #Contains (do specification, toexpr) then do
   if #By.#Loop>=0 then do
     if value(#Identity.#Loop) > #To.#Loop then leave
     end
   else do if value(#Identity.#Loop) < #To.#Loop then leave
     end
  end
if #Contains(dorep, repexpr)  |  #Contains(dorep, 'OVER') then do
   if #Repeat.#Loop = 0 then leave
   #Repeat.#Loop = #Repeat.#Loop-1
   if #Contains(dorep, 'OVER') then
      call value #Identity.#Loop, #OverArray[#OverArray~items - #Repeat.#Loop]
   end
if #Contains (do specification, forexpr) then do
   if #For.#Loop = 0 then leave
   #For.#Loop = #For.#Loop - 1
   end
if #Contains (do specification, whileexpr) then do
  Value = #Evaluate(whileexp, expression)
  if Value == '0' then leave
  if Value \== '1' then call #Raise 'SYNTAX', 34.3, Value
  end
  #Execute (do instruction, instruction list)
TraceOfEnd:
call #Goto #Iterate.#Loop /* to IterateLabel */
LeaveLabel:
#Loop = #Loop - 1
```

### DO loop tracing

When clauses are being traced by `#TraceSource`, due to `pos(#Tracing.#Level, 'AIR') > 0`, the DO
instruction shall be traced when it is encountered and again each time the `IterateLabel` (see nnn) is
encountered. The END instruction shall be traced when the `TraceOfEnd` label is encountered.

When expressions or intermediates are being traced they shall be traced in the order specified by nnn.
Hence, in the absence of conditions arising, those executed prior to the first execution of `OnceLabel` shall
be shown once per execution of the DO instruction; others shall be shown depending on the outcome of
the tests.

The code in the DO description:
```rexx
   t = value (#Identity. #Loop)
   if #Indicator == 'D' then call #Raise 'NOVALUE', #Identity.#Loop
   call value #Identity.#Loop, t + #By.#Loop
```
represents updating the control variable of the loop. That assignment is subject to tracing, and other
expressions involving state variables are not. When tracing intermediates, the BY value will have a tag of
`'>+>'`.

### DROP

For a definition of the syntax of this instruction, see nnn.

The DROP instruction restores variables to an uninitialized state.

The words of the _variable_list_ are processed from left to right.

A word which is a VAR_SYMBOL, not contained in parentheses, specifies a variable to be dropped. If
VAR_SYMBOL does not contain a period, or has only a single period as its last character, the variable
associated with VAR_SYMBOL by the variable pool is dropped:
```rexx
#Response = Var Drop (#Pool,VAR_ SYMBOL, '0')
```
If VAR_SYMBOL has a period other than as the last character, the variable associated with
VAR_SYMBOL by the variable pool is dropped by:
```rexx
#Response = Var Drop (#Pool,VAR SYMBOL, '1')
```
If the word of the _variable_list_ is a VAR_SYMBOL enclosed in parentheses then the value of the
VAR_SYMBOL is processed. The value is considered in uppercase:
```rexx
#Value = Config Upper (#Value)
```
Each word in that value found by the WORD built-in function, from left to right, is subjected to this
process:

If the word does not have the syntax of VAR_SYMBOL a condition is raised:
```rexx
call #Raise 'SYNTAX', 20.1, word
```
Otherwise the VAR_SYMBOL indicated by the word is dropped, as if that VAR_SYMBOL were a word of
the _variable_list_.

### EXIT

For a definition of the syntax of this instruction, see nnn.

The EXIT instruction is used to unconditionally complete execution of a program.

Any _expression_ is evaluated:
```rexx
if #Contains(exit, expression) then Value = #Evaluate(exit, expression)
#Level = 1
#Pool = #Pooll
```
The opportunity is provided for a final trap.
```rexx
#API Enabled = '1'
call Var_Reset #Pool
call Config Termination
#API Enabled = '0'
```
The processing of the program is complete. See nnn for what API Start returns as the result.

If the normal sequence of execution "falls through" the end of the program; that is, would execute a
further statement if one were appended to the program, then the program is terminated in the same
manner as an EXIT instruction with no argument.

### EXPOSE

The expose instruction identifies variables that are not local to the method.

_We need a check that this starts method; similarities with PROCEDURE._

For a definition of the syntax of this instruction, see nnn.

It is used at the start of a method, after method initialization, to make variables in the receiver's pool
accessible:
```rexx
if \#AllowExpose then call #Raise 'SYNTAX', 17.2
```
The words of the _variable_list_ are processed from left to right.

A word which is a VAR_SYMBOL, not contained in parentheses, specifies a variable to be made
accessible. If VAR_SYMBOL does not contain a period, or has only a single period as its last character,
the variable associated with VAR_SYMBOL by the variable pool (as a non-tailed name) is given the
attribute 'exposed'.
```rexx
call Var_ Expose #Pool, VAR SYMBOL, '0'
```
If VAR_SYMBOL has a period other than as last character, the variable associated with VAR_SYMBOL
in the variable pool ( by the name derived from VAR_SYMBOL, see nnn) is given the attribute ‘exposed’.
```rexx
call Var_ Expose #Pool, Derived Name, '1'
```
If the word from the _variable_list_ is a VAR_SYMBOL enclosed in parentheses then the VAR_SYMBOL is
exposed, as if that VAR_SYMBOL was a word in the variable_list. The value of the VAR_SYMBOL is
processed. The value is considered in uppercase:
```rexx
#Value = Config Upper (#Value)
```
Each word in that value found by the WORD built-in function, from left to right, is subjected to this
process:

If the word does not have the syntax of VAR_SYMBOL a condition is raised:
```rexx
call #Raise 'SYNTAX', 20.1, word
```
Otherwise the VAR_SYMBOL indicated by the word is exposed, as if that VAR_SYMBOL were a word of
the _variable_list_.

### FORWARD

For a definition of the syntax of this instruction, see nnn.

The FORWARD instruction is used to send a message based on the current message.
```rexx
if #Contains (forward, 'ARRAY') & #Contains(forward, 'ARGUMENTS') then
    call #Raise 'SYNTAX', nn.n
```

### GUARD

For a definition of the syntax of this instruction, see nnn.

The GUARD instruction is used to conditionally delay the execution of a method.

```rexx
do forever
   Value = #Evaluate( guard, expression)
   if Value == '1' then leave
   if Value \== '0' then call #Raise 'SYNTAX', 34.7, Value
```
_Drop exclusive access and wait for change_
```rexx
   end
```

### IF

For a definition of the syntax of this instruction, see nnn.

The IF instruction is used to conditionally execute an instruction, or to select between two alternatives.
The _expression_ is evaluated. If the value is neither '0' nor '1' error 34.1 occurs. If the value is '1', the
_instruction_ in the _then_ is executed. If the value is '0' and _else_ is specified, the instruction in the _else_ is
executed.

In the former case, if tracing clauses, the clause consisting of the THEN keyword shall be traced in
addition to the instructions.

In the latter case, if tracing clauses, the clause consisting of the ELSE keyword shall be traced in addition
to the instructions.

### INTERPRET

For a definition of the syntax of this instruction, see nnn.

The INTERPRET instruction is used to execute instructions that have been built dynamically by
evaluating an expression.

The _expression_ is evaluated.

The HALT condition is tested for, and may be raised, in the same way it is tested at clause termination,
see nnn.

The process of syntactic recognition described in clause 6 is applied, with `Config_SourceChar` obtaining
its results from the characters of the value, in left-to-right order, without producing any `EOL` or `EOS`
events. When the characters are exhausted, the event `EOL` occurs, followed by the event `EOS`.
If that recognition would produce any message then the _interpret_ raises the corresponding 'SYNTAX'
condition.

If the program recognized contains any LABELs then the _interpret_ raises a condition:
```rexx
call #Raise 'SYNTAX',47.1,Label
```
where `Label` is the first LABEL in the _program_.

Otherwise the _instruction_list_ in the _program_ is executed.

### ITERATE

For a definition of the syntax of this instruction, see nnn.

The ITERATE instruction is used to alter the flow of control within a repetitive DO.
For a definition of the nesting correction, see nnn.
```rexx
#Loop = #Loop - NestingCorrection
call #Goto #Iterate.#Loop
```

### Execution of labels

The execution of a label has no effect, other than clause termination activity and any tracing.
```rexx
if #Tracing.#Level=='L' then call #TraceSource
```

### LEAVE

For a definition of the syntax of this instruction, see nnn.

The LEAVE instruction is used to immediately exit one or more repetitive DOs.
For a definition of the nesting correction, see nnn.
```rexx
#Loop = #Loop - NestingCorrection
call #Goto #Leave.#Loop
```

### Message term
_We can do this by reference to method invokation, just as we do CALL by reference to invoking a function._

### LOOP

_Shares most of it's definition with repetitive DO._

### NOP
For a definition of the syntax of this instruction, see nnn.

The NOP instruction has no effect other than the effects associated with all instructions.

### NUMERIC

For a definition of the syntax of this instruction, see nnn.

The NUMERIC instruction is used to change the way in which arithmetic operations are carried out.

#### NUMERIC DIGITS

For a definition of the syntax of this instruction, see nnn.

NUMERIC DIGITS controls the precision under which arithmetic operations and arithmetic built-in
functions will be evaluated.

```rexx
if #Contains(numericdigits, expression) then
   Value = #Evaluate(numericdigits, expression)
else Value = 9
if \datatype(Value,'W') then
    call #Raise 'SYNTAX',26.5,Value
Value = Value + 0
if Value<=#Fuzz.#Level then
    call #Raise 'SYNTAX',33.1,Value
if Value>#Limit Digits then
    call #Raise 'SYNTAX',33.2,Value
#Digits.#Level = Value
```
#### NUMERIC FORM

For a definition of the syntax of this instruction, see nnn.

NUMERIC FORM controls which form of exponential notation is to be used for the results of operations
and arithmetic built-in functions.

The value of form is either taken directly from the SCIENTIFIC or ENGINEERING keywords, or by
evaluating _valueexp_.

```rexx
if \#Contains (numeric,numericsuffix) then
   Value = 'SCIENTIFIC'
else if #Contains (numericformsuffix, 'SCIENTIFIC') then
           Value = 'SCIENTIFIC'
        else
           if #Contains (numericformsuffix, 'ENGINEERING') then
             Value = 'ENGINEERING'
           else do
             Value = #Evaluate (numericformsuffix,valueexp)
             Value = translate (left (Value,1))
             select
                when Value == 'S' then Value = 'SCIENTIFIC'
                when Value == 'E' then Value = 'ENGINEERING'
                otherwise call #Raise 'SYNTAX',33.3,Value
                end
           end
#Form.#Level = Value
```
#### NUMERIC FUZZ
For a definition of the syntax of this instruction, see nnn.

NUMERIC FUZZ controls how many digits, at full precision, will be ignored during a numeric comparison.
```rexx
If #Contains (numericfuzz,expression) then
  Value = #Evaluate (numericfuzz,expression)
else
  Value = 0
If \datatype(Value,'W') then
  call #Raise 'SYNTAX',26.6,Value
  Value = Value+0
If Value < 0 then
  call #Raise 'SYNTAX',26.6,Value
If Value >= #Digits.#Level then
  call #Raise 'SYNTAX',33.1,#Digits.#Level,Value
#Fuzz.#Level = Value
```

#### OPTIONS

For a definition of the syntax of this instruction, see nnn.

The OPTIONS instruction is used to pass special requests to the language processor.

The _expression_ is evaluated and the value is passed to the language processor. The language processor
treats the value as a series of blank delimited words. Any words in the value that are not recognized by
the language processor are ignored without producing an error.
```rexx
call Config Options (Expression)
```

#### PARSE

For a definition of the syntax of this instruction, see nnn.

The PARSE instruction is used to assign data from various sources to variables.

The purpose of the PARSE instruction is to select substrings of the _parse_fype_ under control of the
_template_list_. If the _template_list_ is omitted, or a _template_ in the list is omitted, then a template which is
the null string is implied.

Processing for the PARSE instruction begins by constructing a value, the source to be parsed.

```rexx
ArgNum = 0
select
  when #Contains (parse type, 'ARG') then do
        ArgNum = 1
        ToParse = #Arg.#Level.ArgNum
        end
  when #Contains (parse type, 'LINEIN') then ToParse = linein('')
  when #Contains (parse type, 'PULL') then do
     /* Acquire from external queue or default input. */
     #Response = Config Pull()
     if left(#Response, 1) == 'F' then
       call Config Default Input
       ToParse = #Outcome
       end
  when #Contains (parse type, 'SOURCE') then
     ToParse = #Configuration #HowInvoked #Source
   when #Contains (parse type, 'VALUE') then
     if \#Contains(parse value, expression) then ToParse = ''
     else ToParse = #Evaluate(parse value, expression)
  when #Contains (parse type, 'VAR') then
    ToParse = #Evaluate (parse var, VAR_SYMBOL)
  when #Contains (parse type, 'VERSION') then ToParse = #Version
  end
Uppering = #Contains(parse, 'UPPER')
```

The first template is associated with this source. If there are further templates, they are matched against
null strings unless 'ARG' is specified, when they are matched against further arguments.

The parsing process is defined by the following routine, `ParseData`. The _template_list_ is accessed by
`ParseDat`a as a stemmed variable. This variable `Template.` has elements which are null strings except
for any elements with tails 1,2,3,... corresponding to the tokens of the _template_list_ from left to right.

```rexx
ParseData:
  /* Targets will be flagged as the template is examined. */
  Target.='0'
  /* Token is a cursor on the components of the template,
  moved by FindNextBreak. */
  Token = 1
  /* Tok ig a cursor on the components of the template
  moved through the target variables by routine WordParse. */
  Tok = 1
do forever /* Until commas dealt with. */
  /* BreakStart and BreakEnd indicate the position in the source
  string where there is a break that divides the source. When the break
  is a pattern they are the start of the pattern and the position just
  beyond it. */
  BreakStart =
  BreakEnd = 1
  SourceEnd = length(ToParse) + 1
  If Uppering then ToParse = translate (ToParse)

  do while Template.Tok \== '' & Template.Tok \== ','

    /* Isolate the data to be processed on this iteration. */
    call FindNextBreak /* Also marks targets. */

    /* Results have been set in DataStart which indicates the start
    of the isolated data and BreakStart and BreakEnd which are ready
    for the next iteration. Tok has not changed. */

    /* If a positional takes the break leftwards from the end of the
    previous selection, the source selected is the rest of the string, */

    if BreakEnd <= DataStart then
      DataEnd = SourceEnd
    else
      DataEnd = BreakStart

    /* Isolated data, to be assigned from: */
    Data=substr (ToParse,DataStart, DataEnd-DataStart)
    call WordParse /* Does the assignments. */
    end /* while */
  if Template.Tok \== ',' then leave
  /* Continue with next source. */
  Token=Token+1
  Tok=Token
  if ArgNum <> 0 then do
     ArgNum = ArgNum+1
     ToParse = #Arg.ArgNum
     end
  else ToParse=''
  end

return /* from ParseData */

FindNextBreak:
  do while Template.Token \== '' & Template.Token \== ','
    Type=left (Template.Token,1)
    /* The source data to be processed next will normally start at the end of
    the break that ended the previous piece. (However, the relative
    positionals alter this.) */
    DataStart = BreakEnd
    select

      when Type='"' | Type="'" | Type='(' then do
        if Type='(' then do
          /* A parenthesis introduces a pattern which is not a constant. */
          Token = Token+1
          Pattern = value(Template.Token)
          if #Indicator == 'D' then call #Raise 'NOVALUE', Template.Token
          Token = Token+1
          end
        else
          /* The following removes the outer quotes from the
          literal pattern */
          interpret "Pattern="Template.Token
        Token = Token+1
        /* Is that pattern in the remaining source? */
        PatternPos=pos (Pattern, ToParse,DataStart)
        if PatternPos>0 then do
          /* Selected source runs up to the pattern. */
          BreakStart=PatternPos
          BreakEnd=PatternPos+length (Pattern)
          return
          end
        leave /* The rest of the source is selected. */
        end

      when datatype(Template.Token,'W') | pos(Type,'+-=') > 0 then do
        /* A positional specifies where the relevant piece of the subject
        ends. */
        if pos (Type, '+-=') = 0 then do
          /* Whole number positional */
          BreakStart = Template.Token
          Token = Token+1
          end
        else do
          /* Other forms of positional. */
          Direction=Template.Token
          Token = Token + 1
          /* For a relative positional, the position is relative to the start
          of the previous trigger, and the source segment starts there. */
          if Direction \== '=' then
             DataStart = BreakStart
          /* The adjustment can be given as a number or a variable in
          parentheses. */
          if Template.Token ='(' then do
             Token=Token + 1
             BreakStart = value(Template. Token)
             if #Indicator == 'D' then call #Raise 'NOVALUE', Template.Token
             Token=Token + 1
             end
           else BreakStart = Template.Token
           if \datatype (BreakStart,'W')
                 then call #Raise 'SYNTAX', 26.4,BreakStart
           Token = Token+1
           If Direction='+'
             then BreakStart=DataStart+BreakStart
           else if Direction='-'
             then BreakStart=DataStart-BreakStart
           end
         /* Adjustment should remain within the ToParse */
         BreakStart = max(1, BreakStart)
         BreakStart = min(SourceEnd, BreakStart)
         BreakEnd = BreakStart /* No actual literal marks the boundary. */
         return
         end
       when Template.Token \== '.' & pos(Type, '0123456789.')>0 then
         /* A number that isn't a whole number. */
         call #Raise 'SYNTAX', 26.4, Template.Token
         /* Raise will not return */

       otherwise do /* It is a target, not a pattern */
         Target.Token='1'
         Token = Token+1
         end
       end /* select */
     end /* while */
     /* When no more explicit breaks, break is at the end of the source. */
     DataStart=BreakEnd
     BreakStart=SourceEnd
     BreakEnd=SourceEnd
     return

WordParse:
/* The names in the template are assigned blank-delimited values from the
source string. */

  do while Target.Tok /* Until no more targets for this data. */
    /* Last target gets all the residue of the Data.
    Next Tok = Tok + 1
    if \Target.NextTok then do
      call Assign (Data)
      leave
      end
    /* Not 1ast target; assign a word. */
    Data = strip(Data,'L')
    if Data == '' then call Assign('')
    else do
      Word = word(Data,1)
      call Assign Word
      Data = substr(Data,length(Word) + 1)
      /* The word terminator is not part of the residual data: */
      if Data \== '' then Data = substr (Data, 2)
      end
   Tok = Tok + 1
   end
   Tok=Token /* Next time start on new part of template. */
   return

Assign:
   if Template.Tok=='.' then Tag='>.>'
   else do
     Tag='>=>'
     call value Template.Tok,arg(1)
     end
   /* Arg(1) is an implied argument of the tracing.
   if #Tracing.#Level == 'R' | #Tracing.#Level == 'I' then call #Trace Tag
   return
```
### PROCEDURE

For a definition of the syntax of this instruction, see nnn.

The PROCEDURE instruction is used within an internal routine to protect all the existing variables by
making them unknown to following instructions. Selected variables may be exposed.

It is used at the start of a routine, after routine initialization:

```rexx
if \#AllowProcedure.#Level then call #Raise 'SYNTAX', 17.1
#AllowProcedure.#Level = 0
/* It introduces a new variable pool: */
call #Config ObjectNew
call var_set (#Outcome,'#UPPER', '0', #Pool) /* Previous #Pool is upper from the new
#Pool. */
#Pool=#OOutcome
IsProcedure.#Level='1'
call Var_Empty #Pool
```

If there is a _variable_list_, it provides access to a previous variable pool.

The words of the _variable_list_ are processed from left to right.

A word which is a VAR_SYMBOL, not contained in parentheses, specifies a variable to be made
accessible. If VAR_SYMBOL does not contain a period, or has only a single period as its last character,
the variable associated with VAR_SYMBOL by the variable pool (as a non-tailed name) is given the
attribute 'exposed'.

```rexx
call Var_ Expose #Pool, VAR SYMBOL, '0'
```

If VAR_SYMBOL has a period other than as last character, the variable associated with VAR_SYMBOL
in the variable pool (by the name derived from VAR_SYMBOL, see nnn) is given the attribute ‘exposed’.

```rexx
call Var_ Expose #Pool, Derived Name, '1'
```

If the word from the _variable_list_ is a VAR_SYMBOL enclosed in parentheses then the VAR_SYMBOL is
exposed, as if that VAR_SYMBOL was a word in the _variable_list_. Tne value of the VAR_SYMBOL is
processed. The value is considered in uppercase:

```rexx
#Value = Config Upper (#Value)
```

Each word in that value found by the WORD built-in function, from left to right, is subjected to this
process:

If the word does not have the syntax of VAR_SYMBOL a condition is raised:

```rexx
call #Raise 'SYNTAX', 20.1, word
```

Otherwise the VAR_SYMBOL indicated by the word is exposed, as if that VAR_SYMBOL were a word of
the _variable_list_.

### PULL

For a definition of the syntax of this instruction, see nnn.

A PULL instruction is a shorter form of the equivalent instruction:

```rexx
PARSE UPPER PULL template list
```

### PUSH

For a definition of the syntax of this instruction, see nnn.

The PUSH instruction is used to place a value on top of the stack.

```rexx
If #Contains(push,expression) then
  Value = #Evaluate (push, expression)
else
  Value = ''
call Config Push Value
```

### QUEUE

For a definition of the syntax of this instruction, see nnn.

The QUEUE instruction is used to place a value on the bottom of the stack.

```rexx
If #Contains (queue,expression) then
  Value = #Evaluate (queue, expression)
else
  Value = ''
call Config Queue Value
```

### RAISE

The RAISE instruction returns from the current method or routine and raises a condition.

### REPLY

The REPLY instruction is used to allow both the invoker of a method, and the replying method, to
continue executing.

Must set up for error of expression on subsequent RETURN.
### RETURN
For a definition of the syntax of this instruction, see nnn.
The RETURN instruction is used to return control and possibly a result from a program or internal routine
to the point of its invocation.
The RETURN keyword may be followed by an optional expression, which will be evaluated and returned
as a result to the caller of the routine.
Any expression is evaluated:
if #Contains(return,expression) then
#Outcome = #Evaluate(return, expression)

else if #IsFunction.#Level then
call #Raise 'SYNTAX', 45.1, #Name.#Level

At this point the clause termination occurs and then the following:

If the routine started with a PROCEDURE instruction then the associated pool is taken out of use:
if #IsProcedure.#Level then #Pool = #Upper
A RETURN instruction which is interactively entered at a pause point leaves the pause point.
if #Level = #AtPause then #AtPause = 0
The activity at this level is complete:
#Level = #Level-1
#NewLevel = #Level+1
If #Level is not zero, the processing of the RETURN instruction and the invocation is complete.
Otherwise processing of the program is completed:

The opportunity is provided for a final trap.
#API Enabled = '1'

call Var_Reset #Pool

call Config Termination

#API Enabled = '0'

The processing of the program is complete. See nnn for what API Start returns as the result.
### SAY

For a definition of the syntax of this instruction, see nnn.

The SAY instruction is used to write a line to the default output stream.

If #Contains(say,expression) then
Value = Evaluate (say, expression)
else
Value = ''
call Config Default Output Value

### SELECT

For a definition of the syntax of this instruction, see nnn.

The SELECT instruction is used to conditionally execute one of several alternative instructions.
When tracing, the clause containing the keyword SELECT is traced at this point.

The #Contains(select_body, when) test in the following description refers to the items of the optional
when repetition in order:

LineNum = #LineNumber
Ending = #Clause (EndLabel)
Value=#Evaluate (select body, expression) /* In the required WHEN */
if Value \== '1' & Value \== '0' then
call #Raise 'SYNTAX',34.2,Value
If Value=='1' then
call #Execute when, instruction
else do
do while #Contains (select body, when)
Value = #Evaluate (when, expression)
If Value=='1' then do
call #Execute when, instruction
call #Goto Ending
end
if Value \== '0' then
call #Raise 'SYNTAX', 34.2, Value
end /* Of each when */

If \#Contains(select body, 'OTHERWISE') then
call #Raise 'SYNTAX', 7.3, LineNum
If #Contains (select body, instruction list) then
call #Execute select body, instruction list
end
EndLabel:

When tracing, the clause containing the END keyword is traced at this point.

### SIGNAL

For a definition of the syntax of this instruction, see nnn.

The SIGNAL instruction is used to cause a change in the flow of control or is used with the ON and OFF
keywords to control the trapping of conditions.

If #Contains (signal,signal spec) then do
Condition = #Instance(signal spec,condition)

#Instruction.Condition.#Level = 'SIGNAL'
If #Contains (signal spec, 'OFF') then
#Enabling.Condition.#Level = 'OFF'
else
#Enabling.Condition.#Level = 'ON'

If Contains (signal spec,taken constant) then
Name = #Instance (condition, taken constant)

else

Name = Condition
#TrapName.Condition.#Level = Name
end

If there was a signal_spec this complete the processing of the signal instruction. Otherwise:
if #Contains (signal, valueexp)

then Name #Evaluate(valueexp, expression)

else Name #Instance(signal,taken constant)

The Name matches the first LABEL in the program which has that value. The comparison is made with
the '=="' operator.

If no label matches then a condition is raised:

call #Raise 'SYNTAX',16.1, Name

If the name is a trace-only label then a condition is raised:
call #Raise 'SYNTAX', 16.2, Name

If the name matches a label, execution continues at that label after these settings:
#Loop.#Level = 0

/* A SIGNAL interactively entered leaves the pause point. */

if #Level = #AtPause then #AtPause = 0

### TRACE

For a definition of the syntax of this instruction, see nnn.

The TRACE instruction is used to control the trace setting which in turn controls the tracing of execution
of the program.

The TRACE instruction is ignored if it occurs within the program (as opposed to source obtained by

Config_Trace_Input) and interactive trace is requested (#Interactive.#Level = '1'). Otherwise:
#TraceInstruction = '1'
value = ''
if #Contains(trace, valueexp) then Value = #Evaluate(valueexp, expression)
if #Contains (trace, taken constant) then Value = #Instance (trace, taken constant)
if datatype(Value) == 'NUM' & \datatype(Value,'W') then
call #Raise 'SYNTAX', 26.7, Value
if datatype(Value,'W') then do
/* Numbers are used for skipping. */
if Value>=0 then #InhibitPauses = Value
else #InhibitTrace = -Value
end
else do
if length(Value) = 0 then do
#Interactive.#Level = '0'
Value = 'N'
end
/* Each question mark toggles the interacting. */
do while left(Value,1)=='?'
#Interactive.#Level = \#Interactive.#Level
Value = substr(Value,2)
end
if length(Value) \= 0 then do
Value = translate( left(Value,1) )
if verify(Value, 'ACEFILNOR') > 0 then
call #Raise 'SYNTAX', 24.1, Value
if Value=='0O' then #Interactive.#Level='0'
end
#Tracing.#Level = Value
end

### Trace output

If #NoSource is '1' there is no trace output.

The routines #TraceSource and #Trace specify the output that results from the trace settings. That
output is presented to the configuration by Config_Trace_Output as lines. Each line has a clause
identifier at the left, followed by a blank, followed by a three character tag, followed by a blank, followed
by the trace data.

The width of the clause identifier shall be large enough to hold the line number of the last line in the
program, and no larger. The clause identifier is the source program line number, or all blank if the line
number is the same as the previous line number indicated and no execution with trace Off has occurred
since. The line number is right-aligned with leading zeros replaced by blank characters.

When input at a pause is being executed (#AtPause \= 0 ), #Trace does nothing when the tag is not '+++'.

When input at a pause is being executed, #TraceSource does nothing.
If #InhibitTrace is greater than zero, #TraceSource does nothing except decrement #InhibitTrace.
Otherwise, unless the current clause is a null clause, #TraceSource outputs all lines of the source
program which contain any part of the current clause, with any characters in those lines which are not
part of the current clause and not other_blank_characters replaced by blank characters. The possible
replacement of other_blank_characters is defined by the configuration. The tag is '*-*", or if the line is not
the first line of the clause. ™,*’.
#Trace output also has a clause identifier and has a tag which is the argument to the #Trace invocation.
The data is truncated, if necessary, to #Limit_TraceData characters. The data is enclosed by quotation
marks and the quoted data preceded by two blanks. If the data is truncated, the trailing quote has the
three characters '...' appended.
_ when #Tracing.#Level is 'C' or 'E' or 'F' or 'N' or ‘A’ and the tag is '>>>' then the data is the value of
the command passed to the environment;
_ when the tag is '+++' then the data is the four characters 'RC
concatenated with the character "";
_ when #Tracing.#Level is 'l' or 'R' the data is the most recently evaluated value.
Trace output can also appear as the result of a'SYNTAX' condition occurring, irrespective of the trace
setting. If a'SYNTAX' condition occurs and it is not trapped by SIGNAL ON SYNTAX, then the clause in
error shall be traced, along with a traceback. A traceback is a display of each active CALL and
INTERPRET instruction, and function invocation, displayed in reverse order of execution, each with a tag
of '+4+'.
### USE
For a definition of the syntax of this instruction, see nnn.
The USE instruction assigns the values of arguments to variables.
Better not say copies since COPY method has different semantics.
The optional VAR_SYMBOL positions, positions 1, 2, ..., of the instruction are considered from left to
right. If the position has a VAR_SYMBOL then its value is assigned to:

if #ArgExists.Position then
call Value VAR_SYMBOL, #Arg.Position
else

Messy because VALUE bif won't DROP and var_drop needs to know if compound.

## Conditions and Messages

When an error occurs during execution of a program, an error number and message are associated with
it. The error number has two parts, the error code and the error subcode. These are the integer and
decimal parts of the error number. Subcodes beginning or ending in zero are not used.

Error codes in the range 1 to 90 and error subcodes up to .9 are reserved for errors described here and
for future extensions of this standard.

concatenated with #RC

Error number 3 is available to report error conditions occuring during the initialization phase; error
number 2 is available to report error conditions during the termination phase. These are error conditions
recognized by the language processor, but the circumstances of their detection is outside of the scope of
this standard.

The ERRORTEXT built-in function returns the text as initialized in nnn when called with the ‘Standard’
option. When the 'Standard' option is omitted, implementation-dependent text may be returned.

When messages are issued any message inserts are replaced by actual values.

The notation for detection of a condition is:

call #Raise Condition, Arg2, Arg3, Arg4, Arg5, Arg6é

Some of the arguments may be omitted. In the case of condition 'SYNTAX' the arguments are the
message number and the inserts for the message. In other cases the argument is a further description of
the condition.

The action of the program as a result of a condition is dependent on any signa/_spec and callon_spec in
the program.

### Raising of conditions

The routine #Raise corresponds to raising a condition. In the following definition, the instructions
containing SIGNAL VALUE and INTERPRET denote transfers of control in the program being
processed. The instruction EXIT denotes termination. If not at an interactive pause, this will be
termination of the program, see nnn, and there will be output by Config_Trace_Output of the message
(with prefix _ see nnn) and tracing (see nnn). If at an interactive pause (#AtPause \= 0), this will be
termination of the interpretation of the interactive input; there will be output by Config_Trace_Output of
the message (without traceback) before continuing. The description of the continuation is in nnn after
the "interpret #Outcome” instruction.

The instruction “interpret 'CALL' #TrapName.#Condition.#Level" below does not set the variables
RESULT and .RESULT; any result returned is discarded.

#Raise:
/* If there is no argument, this is an action which has been delayed from the time the
condition occurred until an appropriate clause boundary. */
if \arg(1,'E') then do
Description = #PendingDescription. #Condition. #Level
Extra = #PendingExtra.#Condition. #Level

end
else do
#Condition = arg(1)
if #Condition \== 'SYNTAX' then do

Description = arg(2)
Extra = arg(3)
end
else do
Description = #Message(arg(2),arg(3),arg(4),arg(5))
call Var Set #ReservedPool, '.MN', 0, arg(2)
Extra = '!
end
end

/* The events for disabled conditions are ignored or cause termination. */

if #Enabling.#Condition.#Level == 'OFF' | #AtPause \= 0 then do
if #Condition \== 'SYNTAX' & #Condition \== 'HALT' then
return /* To after use of #Raise. */
if #Condition == 'HALT' then Description = #Message(4.1, Description)
exit /* Terminate with Description as the message. */
end

/* SIGNAL actions occur as soon as the condition is raised. */

if #Instruction.#Condition.#Level == '"SIGNAL' then do
#ConditionDescription.#Level = Description
#ConditionExtra.#Level = Extra
#ConditionInstruction.#Level = 'SIGNAL'
#Enabling.#Condition.#Level = 'OFF'
signal value #TrapName.#Condition.#Level
end

/* All CALL actions are initially delayed until a clause boundary. */

if arg(1,'E') then do
/* Events within the handler are not stacked up, except for one
extra HALT while a first is being handled. */
EventLevel = #Level
if #Enabling.#Condition.#Level == 'DELAYED' then do
if #Condition \== 'HALT' then return
EventLevel = #EventLevel.#Condition. #Level
if #PendingNow.#Condition.EventLevel then return
/* Setup a HALT to come after the one being handled. */
end
/* Record a delayed event. */
#PendingNow.#Condition.EventLevel = '1'
#PendingDescription.#Condition.EventLevel = Description
#PendingExtra.#Condition.EventLevel = Extra
#Enabling.#Condition.EventLevel = 'DELAYED'
return
end
/* Here for CALL action after delay. */
/* Values for the CONDITION built-in function. */
#Condition.#NewLevel = #Condition
#ConditionDescription.#NewLevel = #PendingDescription. #Condition. #Level
#ConditionExtra.#NewLevel = #PendingExtra.#Condition. #Level
#ConditionInstruction.#NewLevel = 'CALL'
interpret 'CALL' #TrapName.#Condition.#Level
#Enabling.#Condition.#Level = 'ON'
return /* To clause termination */

### Messages during execution

The state function #Message corresponds to constructing a message.

This definition is for the message text in nnn. Translations in which the message inserts are in a different
order are permitted.

In addition to the result defined below, the values of MsgNumber and #LineNumber shall be shown when
a message is output. Also there shall be an indication of whether the error occurred in code executed at
an interactive pause, see nnn.

Messages are shown by writing them to the default error stream.

#Message:
MsgNumber = arg(1)
if #NoSource then MsgNumber = MsgNumber % 1 /* And hence no inserts */
Text = #ErrorText.MsgNumber
Expanded = ''

do Index = 2
parse var Text Begin '<' Insert '>' +1 Text

if Insert = '' then leave
Insert = arg(Index)
if length(Insert) > #Limit MessageInsert then
Insert = left(Insert,#Limit MessageInsert)'...'

Expanded = Expanded || Begin || Insert

end

Expanded = Expanded || Begin

say Expanded
return
