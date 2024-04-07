/* FUZZ with operators. */
 if 123456789 = 123456788 then say "BAD01"
 numeric fuzz 1
 if 123456789 > 123456788 then say "BAD02"
 if 12345678 \> 12345677 then say "BAD03"
 numeric fuzz 2
 numeric fuzz 8
 if 12345678  > 12345677 then say "BAD04"
 if 12345678e99  > 12345677e99 then say "BAD05"
 say "Fuzz done"
