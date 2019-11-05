/* Arabic <=> Roman */
/* RomanNumeral
   ArabicToRoman and RomanToArabic (rev 1.2)
*/
RomanNumeral:
if arg(1) =='' then do
  Say "Enter a Roman or Arabic number"
  arg = linein();
end; else do
  arg = arg(1)
end
if datatype(arg, 'W') then do
  res = ArabicToRoman(arg)
  if res < 0 then do
     Say 'Number too big'
     return
     end
end; else do
  res = RomanToArabic(arg)
  if (translate(ArabicToRoman(res)) \= translate(arg)) then do
     Say "Not a Roman number!"
     return
     end
end
Say arg " => " res
return

/* ArabicToRoman
Convert a number from arabic to roman
*/
ArabicToRoman: procedure
parse arg number
  if datatype(number, 'W') == 0 then return -1  /* Invalid Number */
  else if (number > 9999) then return -2        /* Number too big */
  else do
    lead.1 = 0;  cnt.1 = 0;
    lead.2 = 0;  cnt.2 = 1;  trail.2 = 0;
    lead.3 = 0;  cnt.3 = 2;  trail.3 = 0;
    lead.4 = 0;  cnt.4 = 1;  trail.4 = 4;
    lead.5 = 4;  cnt.5 = 0;
    lead.6 = 4;  cnt.6 = 1;  trail.6 = 0;
    lead.7 = 4;  cnt.7 = 2;  trail.7 = 0;
    lead.8 = 4;  cnt.8 = 3;  trail.8 = 0;
    lead.9 = 0;  cnt.9 = 1;  trail.9 = 8;
    symbols = "ixcmvldFxcmT"
    iNb = 1
    res=''
    do iSy = length(number) to 0 by -1
      n = substr(number,iNb,1)
      iNb = iNb+1
      if (n > 0) then do
        res = res || substr(symbols, lead.n+iSy, 1)
        do (cnt.n)
           res = res || substr(symbols, trail.n+iSy, 1)
           end
        end
      end
    return res
    end

/* RomanToArabic
Convert a number from arabic to roman
*/
RomanToArabic: procedure
  t.1 = 'XLCV'
  t.2 = 'XDMV'
  t.3 = 'XFTV'
  res = ''
  bef = arg(1) || '?'
  do i=1
    parse upper var bef bef 'I' aft
    val = translate(left(aft,1), '49', 'VX')
    if datatype(val, 'W') == 0 then val = verify(aft, 'I')
    if verify(bef, 'V', 'M') > 0 then val = val + 5
    res = val || res
    if i==4 then return strip(res ,'L','0')
    bef = translate(bef, "IVX?", t.i) || '?'
    end
