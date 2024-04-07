The development of the ANSI standard occurred over years which corresponded to the peak then end of the Intel 16 bit hardware era. CRX served its purpose for the Standard.  If it had been a few years earlier, or if Rexx as part of SAA had the resources originally planned, CRX could have had general use. It is questionable whether any updating now, after more than a decade, has value.

Intel hardware has not obsoleted most machine instructions. (This is because in the modern architectures there is a separate part of the silicon devoted to cacheing and translating the machine instructions.  Provided this part can feed primitive instructions to the central mill fast enough, complication in the machine instruction architecture has little effect.)

Microsoft has made DOS obsolete, although emulators to run DOS 16-bit functions on 32-bit Windows will run many DOS programs.

Microsoft has made segment registers obsolete by using them only within the operating system, effectively unavailable to normal programming.  This does little harm because 16-bit real mode and segment registers were part of the same story - with only half a megabyte of memory addressible by the user program it made sense to get the most from that by moving data from real address to real address. As the CRX compaction/garbage-collection shows, segment registers allowed the main line programming to ignore these movements. (Software paging to a RAM disk could also be hidden, alleviating some 16-bit capacity problems)

Time has relegated the segment registers to uses-could-be-found status as opposed to essential status. Anyway, as programmers we have lost them.

Intel has given us extra general purpose registers in the 64 bit architecture.  It is chore to write Assembler that conditionally generates code according to the number of registers so there is a case for skipping 32-bit and coding only for the 64-bit. (This can still implement default numeric digits to give results identical to 32-bit. The 64-bitness would then only be exploited for the extra registers and the extra powers in addressibility - 32 bit relativity on 64 bit addresses.)

Ignoring the mechanics, there is a question of approach.  A table-driven interpreter is effective when implementation effort is shifted from the interpreter itself to the tools which construct the tables.  Are the semantics of object-oriented amenable to an analogous encoding?   

     

  