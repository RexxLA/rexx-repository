# Locale

## ARB recommendations

(TBD)

## Draft Notes

(Discussion starts with a comment about jlf's Executor)

(jmb)  
Having a RexxText class that is tied to the String class is a neat solution, but, in my opinion, it has a major drawback. It keeps String as the basic, universal class, and if one wants RexxText, one has to do additional work. 
For me, this is a perfectly workable solution. But what I've understood, from our conversations in the ARB list, is that many people consider it to be unacceptable. I.e., we would want that a "normal" programmer can use Unicode strings by default.  
(/jmb)

  (jlf)  
  Agreed. This is just a proto, and I'm not expecting anyone to want it in production.  
  Yes, currently String is the main class.  
  Since it's a circular dependency, it will also work if RexxText becomes the main class.  
  The big problem with RexxText being the main class is the performance regression.  
  I'm not focusing on perf, even if sometimes I can't resist and do some optimizations.  
  I bet that most of the rexxers will strongly complain about the perf (in general, not talking about Executor).  
  (/jlf)  
  
  (jmb)  
  Performance doesn't have to suffer at all for pure ASCII strings. The fact that a literal string is pure ASCII can be determined at parse time, and for run-time strings, such a determination is O(n), with a very fast character test. The fact that a string is pure ASCII can be stored as an attribute of the string instance, and some very simple rules followed (for example, if we concatenate two pure ASCII strings, we get a pure ASCII string). BIFs and BIMs should operate on pure ASCII strings at the same speed than current Rexx programs (if the internal representation is utf-8, of course).  
  On the other hand, if one wants diacritics, devanagari and all that, and still be able to use all the classic BIFs, one should be prepared for an unavoidable performance drop.  
  Finally, if you are really concerned about performance and additionally you know very well what you are doing, you can always resort to byte strings and manage the utf-8 details by yourself.  
  (/jmb)

  (jmb)  
  (Some additional thoughts about performance)  
  In many cases, and if we restrict ourselves to the BMP, NFC normalization can produce a string where every grapheme cluster is a single codepoint. This is also a good candidate for optimization. In this case, the ideal storage format is 16-bit words, since it allows for indexed, direct access. If we go beyond the BMP but we still have one grapheme cluster = one codepoint, then we can use 32-bit integers.  
  The only case where performance will forcefully degrade is when we are dealing with a string which cannot be confined to 8-bit, 16-bit or 32-bit clusters=codepoints.  
  Of course dealing with 16-bit or 32-bit codepoints should be a little more expensive, but the major performance benefit of these formats is that they allow direct access.  
  To summarize: if we want to maintain maximum performance, the minimum requirement would be to dual-path all BIFs and BIMs for "simple" cases (i.e., one grapheme cluster = one codepoint) and then implement at least 32-bit integer codepoints (but, most probably, also 16- and 8-bit, to conserve space).  
  (/jmb)  
