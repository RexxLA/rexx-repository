/*
Temporary implementations to have BIFs forwarding to RexxText.
*/

::requires "extension/extensions.cls"

::routine C2X;               return "C2X"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSCOMPARE;   return "CASELESSCOMPARE"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSCOMPARETO; return "CASELESSCOMPARETO"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSENDSWITH;  return "CASELESSENDSWITH"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSEQUALS;    return "CASELESSEQUALS"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSLASTPOS;   return "CASELESSLASTPOS"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSMATCH;     return "CASELESSMATCH"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSMATCHCHAR; return "CASELESSMATCHCHAR"~doWith(arg(1)~text, .context~args~section(2))
::routine CASELESSPOS;       return "CASELESSPOS"~doWith(arg(1)~text, .context~args~section(2))
::routine CENTER;            return "CENTER"~doWith(arg(1)~text, .context~args~section(2))
::routine CENTRE;            return "CENTRE"~doWith(arg(1)~text, .context~args~section(2))
::routine COMPARE;           return "COMPARE"~doWith(arg(1)~text, .context~args~section(2))
::routine COMPARETO;         return "COMPARETO"~doWith(arg(1)~text, .context~args~section(2))
::routine COPIES;            return "COPIES"~doWith(arg(1)~text, .context~args~section(2))
::routine EQUALS;            return "EQUALS"~doWith(arg(1)~text, .context~args~section(2))
::routine ENDSWITH;          return "ENDSWITH"~doWith(arg(1)~text, .context~args~section(2))
::routine LENGTH;            return "LENGTH"~doWith(arg(1)~text, .context~args~section(2))
::routine LEFT;              return "LEFT"~doWith(arg(1)~text, .context~args~section(2))
::routine LOWER;             return "LOWER"~doWith(arg(1)~text, .context~args~section(2))
::routine MATCH;             return "MATCH"~doWith(arg(1)~text, .context~args~section(2))
::routine MATCHCHAR;         return "MATCHCHAR"~doWith(arg(1)~text, .context~args~section(2))
::routine POS;               args = .context~args; args[2] = args[1]; return "POS"~doWith(arg(2)~text, args~section(2))
::routine REVERSE;           return "REVERSE"~doWith(arg(1)~text, .context~args~section(2))
::routine RIGHT;             return "RIGHT"~doWith(arg(1)~text, .context~args~section(2))
::routine SUBCHAR;           return "SUBCHAR"~doWith(arg(1)~text, .context~args~section(2))
::routine SUBSTR;            return "SUBSTR"~doWith(arg(1)~text, .context~args~section(2))
::routine UPPER;             return "UPPER"~doWith(arg(1)~text, .context~args~section(2))

/*
No added value, Executor directly forward to String

::routine C2D;               return "C2D"~doWith(arg(1)~text, .context~args~section(2))
::routine HASHCODE;          return "HASHCODE"~doWith(arg(1)~text, .context~args~section(2))
::routine X2B;               return "X2B"~doWith(arg(1)~text, .context~args~section(2))
::routine X2C;               return "X2C"~doWith(arg(1)~text, .context~args~section(2))
::routine X2D;               return "X2D"~doWith(arg(1)~text, .context~args~section(2))
*/


/*
Remember: the BIF where self is the 2nd arg, not the 1st.
changeStr
countStr
lastPos
pos
wordPos
*/
