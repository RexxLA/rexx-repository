/*------------------------------------------------------------------------------
 show.h 920605
õ-----------------------------------------------------------------------------*/
/* The SHOW cluster puts output on a file which must first be set by
SetShowFile. ("stdout" or "" for standard out). */
#define  LINE_SZ    79  /* Change this for formatting at a different width. */
Storage char Line[LINE_SZ+1];           /* To construct line within. */
/* Newline-if-necessary is automatic. */
void SetShowFile(char *);
void NewLine(void);
void ShowC(char); /* Shows a single char. */
void ShowS(char *); /* Shows an ASCIIZ string. */
void ShowA(char *,Ushort); /* Shows a string, given length. */
void ShowD(short); /* Shows a number. */
void ShowL(long); /* Shows a long number. */
/* A left margin can be set. Numbering is from zero. */
void SetMargin(Ushort); /* Applies to subsequent Newlines. */
void SetColumn(Ushort); /* Positioning for next Show. */
Ushort QryColumn(void); /* Position expected for next Show. */