rem Scratch remake from is_bnf.  See readme in \tools\
call bits.bat
call show.bat
call wal.bat
call simplify.bat
call simplifyl.bat
call states.bat
call statesl.bat
call structs.bat
call structsl.bat
call pack.bat
call packl.bat

simplify /:= is_bnf.txt simplify.out  > simplify.log       
states /s simplify.out states.out > states.log           
structs simplify.out states.out is.kwc > structs.log      
structs /a simplify.out states.out is.kwa > structs.log     
pack /u structs.log syn.inc > pack.log                 