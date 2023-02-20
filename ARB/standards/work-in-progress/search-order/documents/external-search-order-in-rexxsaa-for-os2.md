# External search order for the REXXSAA interpreter for OS/2

\[Source: REXX.INF, REXXSAA interpreter setup, v. REXXSAA 4.00 3 Feb 1999, operating system is Arca Noae 5.0.7.\]

>REXX searches for external functions in the following order: 
>
>1. Functions that have been loaded into the macrospace for pre-order execution 
>2. Functions that are part of a function package. 
>3. REXX functions in the current directory, with the current extension 
>4. REXX functions along environment PATH, with the current extension 
>5. REXX functions in the current directory, with the default extension 
>6. REXX functions along environment PATH, with the default extension 
>7. Functions that have been loaded into the macrospace for post-order execution.

Please note that the "with the current extension" part of the algorithm does not seem to work \[Create `TEST.CMD`, from it call `TRY.IT` (by using `Call try.it`), and from this last routine try to call `INSISTON.IT`. `Call insiston.it` will work as expected, but `Call insiston` will not. On the other hand, `Call insiston` will work if there is a `INSISTON.CMD` file in the directory.\]

