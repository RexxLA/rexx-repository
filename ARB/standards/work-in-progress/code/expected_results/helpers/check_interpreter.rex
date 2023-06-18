/* Check that the right interpreter is used */

#if defined CREXX
/*
Not supported:
parse version v

Error Severity 1 in file crexx_expected_results
37:3 - Error at "address", invalid instruction mnemonic
45:3 - Error at "address", invalid instruction mnemonic
Errors in assembler can't generate output file: (null)
*/
#if 0
parse version v
if 1 /*pos("CREXX", v) == 0 */ then do
    say "You are not using the CREXX interpreter."
    say v
    exit 1
end
#endif

#elif defined NETREXX
parse version v
if pos("NetRexx", v) == 0 then do
    error = "You are not using the NetRexx interpreter"
    lineout("stdout", error)
    lineout("stdout", v)
    lineout("stderr", error)
    lineout("stderr", v)
    exit 1
end

#elif defined OOREXX
parse version v
if pos("REXX-ooRexx_5", v) == 0 then do
    error = "You are not using the ooRexx5 interpreter"
    call lineout "stdout", error
    call lineout "stdout", v
    call lineout "stderr", error
    call lineout "stderr", v
    exit 1
end

#elif defined REGINA
parse version v
if pos("REXX-Regina", v) == 0 then do
    error = "You are not using the Regina interpreter"
    call lineout "stdout", error
    call lineout "stdout", v
    call lineout "stderr", error
    call lineout "stderr", v
    exit 1
end

#elif defined EXECUTOR
parse version v
if pos("REXX-ooRexx_4.3.0", v) == 0 then do
    error = "You are not using the Executor interpreter"
    call lineout "stdout", error
    call lineout "stdout", v
    call lineout "stderr", error
    call lineout "stderr", v
    exit 1
end

#endif
