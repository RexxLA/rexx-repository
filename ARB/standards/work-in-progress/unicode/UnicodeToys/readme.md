# Some pure ooRexx Unicode toy implementations

### [Unicode.gc.cls](Unicode.gc.cls)

* A .cls file implementing the "General_Category" (gc) Unicode property.
  Needs the file [UnicodeData.15.0.0.txt](UnicodeData.15.0.0.txt) to work properly.
  On the first run, it will parse the .txt file and create a [gc.bin](gc.bin) file (included) that holds
  a two-stage table containing the encoded gc property for all Unicode points.
* As an added bonus, a public "Algorithmic_name_start" routine is defined. It returns the name start
  for a codepoint, when that name is algorithmically computable. For example, for "8010" it returns
  "CJK UNIFIED IDEOGRAPH-", and for "FA10" it returns "CJK COMPATIBILITY IDEOGRAPH-". Unsupported
  code points return a null string.
* See the comments in the source code for more details.
