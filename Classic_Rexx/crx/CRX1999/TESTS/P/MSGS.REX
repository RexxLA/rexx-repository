/*  13.1 */
^
~
/* 15.1 */
 Wrong=' AA'X
~
/* 15.1 */
 Wrong='A A AA'X
~
/* 15.3 */
 Wrong='EFG'X
~
/* 15.2 */
 Wrong=' 11'B
~
/* 15.2 */
 Wrong='1 1 1111'B
~
/* 15.4 */
 Wrong='012'B
~
/* 30.2 (Using small limit to test.) */
 TooLong="01234567890123456789+"
~
/* 30.1 (Using small limit to test.) */
 TooLong=V01234567890123456789
~
/* 22.1 can't be tested with ASCII source. */
/*  35.1 */
  > 7
~
/*  35.1 */
  ( > 7
~
/*  35.1 */
  +>7
~
/*  35.1 */
  ->
~
/*  35.1 */
  \>7
~
/*  19.1 */
  address >7
~
/*  38.1 */
  arg >7
~
/*  19.2 */
  call *7
~
/*  35.1 */
  do >7
~
/*  20.1 */
  drop 77
~
/*  8.2 */
  else
~
/*  10.1 */
  end
~
/*  35.1 */
  exit &7
~
/*  35.1 */
  if || 7
~
/*  35.1 */
  interpret >7
~
/*  20.1 */
  iterate >7
~
/*  20.1 */
  leave >7
~
/*  25.15 */
  numeric 7
~
/*  35.1 */
  options >7
~
/*  9.2 */
  otherwise
~
/*  25.12 */
  parse 7
~
/*  25.17 */
  trace ?r
  call ab
ab: procedure hide abc
  exit
~
/*  38.1 */
  pull *7
~
/*  35.1 */
  push >7
~
/*  35.1 */
  queue >7
~
/*  35.1 */
  return &7
~
/*  35.1 */
  say >7
~
/*  21.1 */
  select 7
~
/*  19.4 */
  signal >7
~
/*  8.1 */
  then
~
/*  19.6 */
  trace >7
~
/*  9.1 */
  when
~
/*  27.1 */
  do j=7 by 1 by 2
~
/*  35.1 */
  do j=7 \
~
/*  35.1 */
  nop
  &&
~
/*  35.1 */
  abc:;;;*
~
/*  21.1 */
  nop + 7
~
/*  36.1 */
  ( abc
~
/*  35.1 */
  address value *
~
/*  25.5 */
  address x y with z
~
/*  35.1 */
  address x >7
~
/*  19.7 */
  parse version ( +7 )
~
/*  38.2 */
  parse version +abc
~
/*  38.2 */
  parse version -abc
~
/*  38.2 */
  parse version =abc
~
/*  38.1 */
  parse version 7 ,*7
~
/*  38.1 */
  parse version 7 > 7
~
/*  25.2 */
  call off dogs
~
/*  25.1 */
  call on ready
~
/*  35.1 */
  call abc > 7
~
/*  25.16 */
  do forever by 1
  end
~
/*  35.1 */
  do j=7 until > 7
~
/*  35.1 */
  do 7 while > 7
~
/*  20.1 */
  drop (99)
~
/*  20.1 */
  drop abc (99)
~
/*  18.1 */
  if abc \
~
/*  35.1 */
  numeric digits > 7
~
/*  25.11 */
  numeric form > 7
~
/*  35.1 */
  numeric fuzz > 7
~
/*  25.13 */
  parse upper lower
~
/*  38.3 prefer 35.1 */
  parse value > 7
~
/*  20.1 */
  parse var > 7
~
/*  38.1 */
  parse var x > 7
~
/*  20.1 (17 really) */
  procedure expose 7
~
/*  7.1 */
  select
  end
~
/*  25.4 */
  signal off duty
~
/*  25.3 */
  signal on duty
~
/*  31.2 */
  7abc = 7
~
/*  31.3 */
  .7 = 7
~
/*  31.1 */
  7 = 7
~
/*  35.1 */
  x => 7
~
/*  35.1 */
  x = 7+>
~
/*  35.1 */
  x = 7&>
~
/*  35.1 */
  x = 7>&
~
/*  35.1 */
  x = 7 || )
~
/* 37.2 */
  x=7)
~
/*  35.1 */
  x = 7 | )
~
/*  35.1 */
  x = 7 * )
~
/*  10.1 */
  abc:end
~
/*  35.1 */
  x = 7 ** >
~
/*  35.1 */
  x = f(*)
~
/*  37.1 */
  x = (7,)
~
/*  25.6 */
  address x y with input stack
~
/*  25.7 */
  address x y with output stack
~
/*  46.1 */
  parse version (abc .
~
/*  20.1 (gave 19.7) */
  parse version =(+abc)
~
/*  38.1 */
  parse arg abc,
~
/*  35.1 */
  x = f(7,*)
~
/*  35.1 */
  do j=1 by *
~
/*  35.1 */
  do for *
~
/*  35.1 */
  do j=1 to *
~
/*  18.1 */
  if 7=8;;;abc
~
/*  38.1 */
  parse upper version > 7
~
/*  38.3 */
  parse value 7
~
/*  35.1 */
  select
    when > 7
  end
~
/* 18.2 */
  select
    when 7 \
  end
~
/*  7.2? Got 18 */
  select
    when 7
Fallguy:; /* OS2? */
~
/*  21.1 */
  do;end 7
~
/*  10.1 */
  nop
  end
~
/*  36.1 */
  x = f(7,1
~
/*  53.2 */
  address x y with output stem
~
/*  53.1 */
  address x y with output stream;
~
/*  25.8 */
  address x y with output append
~
/*  25.9 */
  address x y with output replace
~
/*  46.1 */
  parse version +(abc
~
/*  19.3 */
  call on notready name *
~
/*  35.1 */
  x=f(1,*)
~
/*  35.1 */
  if 7=7 then *
~
/*  18.2 */
  select
    when 7=8
  end
~
/* 35.1 */
  select
    when * then nop
  end
~
/*  7.2 */
  select
    when 7=8 then nop
    nop
  end
~
/*  7.2 */
  select
    when 7=8 then nop
    >
~
/* 21.1 */
  select
    when 7=8 then nop
  end 7
~
/* 10.4 */
  select
    when 7=8 then nop
  end j
~
/*  19.3 */
  signal on numeric name *
~
/*  21.1 */
  do j=7 to 9
  end j *
~
/*  20.1 */
  address x y with output stem (*)
~
/*  25.7 */
  address x y with input stream s output stack
~
/*  25.6 */
  address x y with output stream s input stack
~
/*  10.5 */
  if 7=7 then end
~
/* 18.2 */
  select
    when 7 *
  end
~
/* 18.2 */
  select
    when 7=7 then nop
    when 7=8 *
  end
~
/*  46.1 */
  address x y with output stem (z
~
/* 18.2 */
  select
    when 7=8 then nop
    otherwise &
  end
~
/*  10.6 */
  if 7=8 then nop;else end
~
/*  35.1 */
  if 7=8 then nop;else %
~
/* 35.1 */
  &&
~
/* 35.1 */
 DO FOREVER UNTIL &5
 END
~
/* 35.1 */
  say a | & b
~
/* 35.1 */
  say a * = b
~
/* 35.1 */
  say a **= b
~
/* 37.1 */
  say ( a+b, 3)
~
/* 35.1 */
  call abc 1, 2, *
~
