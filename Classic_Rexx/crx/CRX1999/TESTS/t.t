
  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 3 running "NonExist.rx": Failure during initialization
Error 3.1: Failure during initialization: Program was not found
================================================================

================================================================
/* 6.1 */
/*
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 6 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/601.RX", line 2: Unmatched "/*" or quote
Error 6.1: Unmatched comment delimiter ("/*")

================================================================
/* 6.2 */
 '
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 6 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/602.RX", line 2: Unmatched "/*" or quote
Error 6.2: Unmatched single quote (')

================================================================
/* 6.3 */
  "
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 6 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/603.RX", line 2: Unmatched "/*" or quote
Error 6.3: Unmatched double quote (")

================================================================
/*  7.1 */
  select
  end
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 7 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/701.RX", line 3: WHEN or OTHERWISE expected
Error 7.1: SELECT on line 0 requires WHEN; found "
"

================================================================
/*  7.2 */
  select
    when 7=8 then nop
    >
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 7 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/702.RX", line 4: WHEN or OTHERWISE expected
Error 7.2: SELECT on line 0 requires WHEN, OTHERWISE, or END; found ">"

================================================================
/*  8.1 */
  then
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 8 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/801.RX", line 2: Unexpected THEN or ELSE
Error 8.1: THEN has no corresponding IF or WHEN clause

================================================================
/*  8.2 */
  else
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 8 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/802.RX", line 2: Unexpected THEN or ELSE
Error 8.2: ELSE has no corresponding THEN clause

================================================================
/*  9.1 */
  when
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 9 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/901.RX", line 2: Unexpected WHEN or OTHERWISE
Error 9.1: WHEN has no corresponding SELECT

================================================================
/*  9.2 */
  otherwise
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 9 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/902.RX", line 2: Unexpected WHEN or OTHERWISE
Error 9.2: OTHERWISE has no corresponding SELECT

================================================================
/*  10.1 */
  end
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 10 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1001.RX", line 2: Unexpected or unmatched END
Error 10.1: END has no corresponding DO or SELECT

================================================================
/*  10.2 */
  do j=1 to 10
   nop
  end j
/* ClauseLine at following DO */
  do j=1 to 10
   nop
/* For this wrong END */
  end k
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 10 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1002.RX", line 9: Unexpected or unmatched END

================================================================
/*  10.3 */
  do
  end k
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 10 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1003.RX", line 3: Unexpected or unmatched END

================================================================
/* 10.4 */
  select
    when 7=8 then nop
  end j
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 10 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1004.RX", line 4: Unexpected or unmatched END

================================================================
/*  10.5 */
  if 7=7 then end
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 10 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1005.RX", line 2: Unexpected or unmatched END
Error 10.1: END has no corresponding DO or SELECT

================================================================
/*  10.6 */
  if 7=8 then nop;else end
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 10 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1006.RX", line 2: Unexpected or unmatched END
Error 10.1: END has no corresponding DO or SELECT

================================================================
/*  13.1 */
^
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 35 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1301.RX", line 2: Invalid expression
Error 35.1: Invalid expression detected at "\"

================================================================
/* 14.1 */
 nop
 do
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 14 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1401.RX", line 3: Incomplete DO/SELECT/IF

================================================================
/* 14.2 */
  nop
  select
    when 1 then nop
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 14 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1402.RX", line 4: Incomplete DO/SELECT/IF

================================================================
/* 14.3 */
  nop
  if 1 then
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 14 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1403.RX", line 4: Incomplete DO/SELECT/IF
Error 14.3: THEN requires a following instruction

================================================================
/* 14.4 */
  nop
  if 0 then nop
       else
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 14 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1404.RX", line 5: Incomplete DO/SELECT/IF
Error 14.4: ELSE requires a following instruction

================================================================
/* 15.1 */
 Wrong=' AA'X
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 15 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1501.RX", line 2: Invalid hexadecimal or binary string
Error 15.1: Invalid location of blank in position 1 in hexadecimal string

================================================================
/* 15.2 */
 Wrong='11 'B
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 15 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1502.RX", line 2: Invalid hexadecimal or binary string
Error 15.2: Invalid location of blank in position 3 in binary string

================================================================
/* 15.3 */
 Wrong='EFG'X
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 15 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1503.RX", line 2: Invalid hexadecimal or binary string
Error 15.3: Only 0-9, a-f, A-F, and blank are valid in a hexadecimal string; found "G"

================================================================
/* 15.4 */
 Wrong='012'B
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 15 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1504.RX", line 2: Invalid hexadecimal or binary string
Error 15.4: Only 0, 1, and blank are valid in a binary string; found "2"

================================================================
/*  18.1 */
  if abc \
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 35 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1801.RX", line 2: Invalid expression
Error 35.1: Invalid expression detected at "\"

================================================================
/* 18.2 */
  select
    when 7 \
  end
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 35 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1802.RX", line 3: Invalid expression
Error 35.1: Invalid expression detected at "\"

================================================================
/*  19.1 */
  address >7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 19 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1901.RX", line 2: String or symbol expected
Error 19.1: String or symbol expected after ADDRESS keyword; found ">"

================================================================
/*  19.2 */
  call *7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 19 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1902.RX", line 2: String or symbol expected
Error 19.2: String or symbol expected after CALL keyword; found "*"

================================================================
/*  19.3 */
  call on notready name *
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 19 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1903.RX", line 2: String or symbol expected
Error 19.3: String or symbol expected after NAME keyword; found "*"

================================================================
/*  19.4 */
  signal >7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 19 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1904.RX", line 2: String or symbol expected
Error 19.4: String or symbol expected after SIGNAL keyword; found ">"

================================================================
/*  19.6 */
  trace >7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 35 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1906.RX", line 2: Invalid expression
Error 35.1: Invalid expression detected at ">"

================================================================
/*  19.7 */
  parse version ( +7 )
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 38 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/1907.RX", line 2: Invalid template or pattern
Error 38.1: Invalid parsing template detected at "+"

================================================================
/*  20.1 */
  drop 77
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 64 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2001.RX": [Syntax error while parsing]
Error 64.1: [Syntax error at line 2]

================================================================
/*  20.2 */
  leave >7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 20 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2002.RX", line 2: Name expected
Error 20.1: Name required; found ">"

================================================================
/*  21.1 */
  select 7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 21 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2101.RX", line 2: Invalid data on end of clause
Error 21.1: The clause ended at an unexpected token; found "7"

================================================================
/*  25.1 */
  call on ready
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2501.RX", line 2: Invalid sub-keyword found
Error 25.1: CALL ON must be followed by one of the keywords ERROR FAILURE HALT NOTREADY; found "ready"

================================================================
/*  25.2 */
  call off dogs
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2502.RX", line 2: Invalid sub-keyword found
Error 25.2: CALL OFF must be followed by one of the keywords ERROR FAILURE HALT NOTREADY; found "dogs"

================================================================
/*  25.3 */
  signal on duty
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2503.RX", line 2: Invalid sub-keyword found
Error 25.3: SIGNAL ON must be followed by one of the keywords ERROR FAILURE HALT NOTREADY NOVALUE SYNTAX LOSTDIGITS; found "duty"

================================================================
/*  25.4 */
  signal off duty
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2504.RX", line 2: Invalid sub-keyword found
Error 25.4: SIGNAL OFF must be followed by one of the keywords ERROR FAILURE HALT NOTREADY NOVALUE SYNTAX LOSTDIGITS; found "duty"

================================================================
/*  25.5 */
  address x y with z
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2505.RX", line 2: Invalid sub-keyword found
Error 25.5: ADDRESS WITH must be followed by one of the keywords INPUT, OUTPUT or ERROR; found "z"

================================================================
/*  25.6 */
  address x y with input stack
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2506.RX", line 2: Invalid sub-keyword found
Error 25.6: INPUT must be followed by one of the keywords STREAM, STEM, LIFO, FIFO or NORMAL; found "stack"

================================================================
/*  25.7 */
  address x y with output stack
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2507.RX", line 2: Invalid sub-keyword found
Error 25.7: OUTPUT must be followed by one of the keywords STREAM, STEM, LIFO, FIFO, APPEND, REPLACE or NORMAL; found "stack"

================================================================
/*  25.8 */
  address x y with output append
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2508.RX", line 2: Invalid sub-keyword found
Error 25.8: APPEND must be followed by one of the keywords STREAM, STEM, LIFO or FIFO; found "
"

================================================================
/*  25.9 */
  address x y with output replace
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2509.RX", line 2: Invalid sub-keyword found
Error 25.9: REPLACE must be followed by one of the keywords STREAM, STEM, LIFO or FIFO; found "
"

================================================================
/*  25.11 */
  numeric form > 7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2511.RX", line 2: Invalid sub-keyword found
Error 25.11: NUMERIC FORM must be followed by one of the keywords ENGINEERING SCIENTIFIC; found "> "

================================================================
/*  25.12 */
  parse 7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2512.RX", line 2: Invalid sub-keyword found
Error 25.12: PARSE must be followed by one of the keywords ARG CASELESS EXTERNAL LINEIN LOWER PULL SOURCE UPPER VAR VALUE VERSION; found "7"

================================================================
/*  25.13 */
  parse upper lower
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2513.RX", line 2: Invalid sub-keyword found
Error 25.12: PARSE must be followed by one of the keywords ARG EXTERNAL LINEIN PULL SOURCE VAR VALUE VERSION; found "lower"

================================================================
/*  25.6 */
  address x y with error whatever
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2514.RX", line 2: Invalid sub-keyword found
Error 25.14: ERROR must be followed by one of the keywords STREAM, STEM, LIFO, FIFO, APPEND, REPLACE or NORMAL; found "whatever"

================================================================
/*  25.15 */
  numeric 7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2515.RX", line 2: Invalid sub-keyword found
Error 25.15: NUMERIC must be followed by one of the keywords DIGITS FORM FUZZ; found "7"

================================================================
/*  25.16 */
  do forever by 1
  end
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2516.RX", line 2: Invalid sub-keyword found
Error 25.16: FOREVER must be followed by one of the keywords WHILE UNTIL; found "by "

================================================================
/*  25.17 */
  call ab
ab: procedure hide abc
  exit
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 25 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2517.RX", line 3: Invalid sub-keyword found
Error 25.17: PROCEDURE must be followed by the keyword EXPOSE or nothing; found "hide"

================================================================
/*  27.1 */
  do j=7 by 1 by 2
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 27 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/2701.RX", line 2: Invalid DO syntax
Error 27.1: Invalid use of keyword "BY" in DO clause

================================================================
/* 30.1 */
 NotTooLong=,
V!_?345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
 TooLong=,
V01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.

================================================================
/* 30.2 */
 NotTooLong=,
"0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
 TooLong=,
"01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.

================================================================
/*  31.1 */
  7 = 7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 31 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/3101.RX", line 2: Name starts with number or "."
Error 31.2: Variable symbol must not start with a number; found ""

================================================================
/*  31.2 */
  7abc = 7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 31 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/3102.RX", line 2: Name starts with number or "."
Error 31.2: Variable symbol must not start with a number; found ""

================================================================
/*  31.3 */
  .rc = 7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 31 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/3103.RX", line 2: Name starts with number or "."
Error 31.3: Variable symbol must not start with a "."; found ".rc"

================================================================
/*  35.1 */
  > 7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 35 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/3501.RX", line 2: Invalid expression
Error 35.1: Invalid expression detected at ">"

================================================================
/*  36.0 */
  ( abc
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 36 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/3600.RX", line 2: Unmatched "(" in expression

================================================================
/*  37.1 */
  x = (7,)
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 37 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/3701.RX", line 2: Unexpected "," or ")"
Error 37.1: Unexpected ","

================================================================
/* 37.2 */
  x=7)
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 64 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/3702.RX": [Syntax error while parsing]
Error 64.1: [Syntax error at line 2]

================================================================
/*  38.1 */
  arg >7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 38 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/3801.RX", line 2: Invalid template or pattern
Error 38.1: Invalid parsing template detected at ">"

================================================================
/*  38.2 */
  parse version +abc
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 38 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/3802.RX", line 2: Invalid template or pattern
Error 38.1: Invalid parsing template detected at "abc"

================================================================
/*  38.3 */
  parse value 7
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 38 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/3803.RX", line 2: Invalid template or pattern
Error 38.3: PARSE VALUE instruction requires WITH keyword

================================================================
/*  46.1 */
  parse version (abc .
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 38 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/4601.RX", line 2: Invalid template or pattern
Error 38.1: Invalid parsing template detected at "."

================================================================
/* 50.1 */
.MN .RESULT .RC .RS .SIGL .OTHER
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
sh: .MN: not found
     2 *-* .MN .RESULT .RC .RS .SIGL .OTHER
       +++ RC=127 +++

================================================================
  fun()
  "fun."()
  fun.()
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
     1 +++    fun()
     1 +++ fun()
Error 43 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/5101.RX", line 1: Routine not found
Error 43.1: Could not find routine "FUN"

================================================================
/*  53.1 */
  address x y with output stream;
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 53 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/5301.RX", line 2: Invalid option
Error 53.1: String or symbol expected after STREAM keyword; found ";"

================================================================
/*  53.2 */
  address x y with output stem
----------------------------------------------------------------

  Electric Fence 2.1 Copyright (C) 1987-1998 Bruce Perens.
Error 53 running "/home/mark/projects/Regina/crx/CRX1999/TESTS/5302.RX", line 2: Invalid option
Error 53.2: Variable reference expected after STEM keyword; found "
"
