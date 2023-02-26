Source: https://learn.microsoft.com/en-us/previous-versions//cc723564(v=technet.10)#command-search-sequence

>The following section describes how Windows NT and the command shell use the PATH and PATHEXT variables.
>
># Command Search Sequence
>
>When a command is submitted for execution (either by typing or as part of a script), the shell performs the following actions:
>
>1. All parameter and environment variable references are resolved (see chapter 3).
>
>2. Compound commands are split into individual commands and each is then individually processed according to the following steps (see the section "Running Multiple Commands" for details of compound commands). Continuation lines are also processed at this step.
>
>3. The command is split into the command name and any arguments.
>
>4. If the command name does not specify a path, the shell attempts to match the command name against the list of internal shell commands. If a match is found, the internal command executes. Otherwise, the shell continues to step 5.
>
>5. If the command name specifies a path, the shell searches the specified path for an executable file matching the command name. If a match is found, the external command (the executable file) executes. If no match is found, the shell reports an error and command processing completes.
>
>6. If the command name does not specify a path, the shell searches the current directory for an executable file matching the command name. If a match is found, the external command (the executable file) executes. If no match is found, the shell continues to step 7.
>
>7. The shell now searches each directory specified by the PATH environment variable, in the order listed, for an executable file matching the command name. If a match is found, the external command (the executable file) executes. If no match is found, the shell reports an error and command processing completes.
>
>In outline, if the command name does not contain a path, the command shell first checks to see if the command is an internal command, then checks the current directory for a matching executable file, and then checks each directory in the search path. If the command name does contain a path, the shell only checks the specified directory for a matching executable file.
>
>If the command name includes a file extension, the shell searches each directory for the exact file name specified by the command name. If the command name does not include a file extension, the shell adds the extensions listed in the PATHEXT environment variable, one by one, and searches the directory for that file name. Note that the shell tries all possible file extensions in a specific directory before moving on to search the next directory (if there is one).
