/*
Temporary implementations to have BIFs forwarding to RexxText.
*/

::requires "extension/extensions.cls"

::routine C2X;      return "C2X"~doWith(arg(1)~text, .context~args~section(2))
::routine CENTER;   return "CENTER"~doWith(arg(1)~text, .context~args~section(2))
::routine CENTRE;   return "CENTRE"~doWith(arg(1)~text, .context~args~section(2))
::routine COPIES;   return "COPIES"~doWith(arg(1)~text, .context~args~section(2))
::routine LENGTH;   return "LENGTH"~doWith(arg(1)~text, .context~args~section(2))
::routine LEFT;     return "LEFT"~doWith(arg(1)~text, .context~args~section(2))
::routine LOWER;    return "LOWER"~doWith(arg(1)~text, .context~args~section(2))
::routine POS;      return "Not yet implemented"
::routine REVERSE;  return "REVERSE"~doWith(arg(1)~text, .context~args~section(2))
::routine RIGHT;    return "RIGHT"~doWith(arg(1)~text, .context~args~section(2))
::routine SUBSTR;   return "SUBSTR"~doWith(arg(1)~text, .context~args~section(2))
::routine UPPER;    return "UPPER"~doWith(arg(1)~text, .context~args~section(2))

/*
No added value, Executor directly forward to String

::routine C2D;      return "C2D"~doWith(arg(1)~text, .context~args~section(2))
::routine X2B;      return "X2B"~doWith(arg(1)~text, .context~args~section(2))
::routine X2C;      return "X2C"~doWith(arg(1)~text, .context~args~section(2))
::routine X2D;      return "X2D"~doWith(arg(1)~text, .context~args~section(2))
*/
