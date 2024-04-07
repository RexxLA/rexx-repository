/* rd.h 920616 Read in a grammar */
void ReadIn(const char* const f);/* Read grammar from file f */
Offset NewName(void); /* Create a new production name. */
void CountProd(Offset n); /* External because Simplify calls it again */
void CountTerm(Offset n); /* External because Simplify calls it again */
Storage Wshort * Text;  /* Result - Base for the Text stream */
Storage Ushort TermCount, ProdCount, BothCount; /* How many of each. */
Storage Offset *Num2Sym; /* From Num to symbol */
Storage Ushort CatNum; /* Remembers code for a || operator. */
Storage Ushort VarNum; /* Remembers code for 'VAR_SYMBOL'. */
/* Symbol extends WalkNode to cover the content of a looked up item.  */
/* Not all the fields are used by Readin - other things use this typedef. */
/* Fields can be overlaid by #define */
 typedef struct {
   WalkNode w;  /* cf wal.h */
   unsigned Temp:1;   /* Overlaid, eg Active */
   unsigned Prod:1;
   unsigned CanBeEmpty:1;  /* Overlaid, eg Subsumed. */
   unsigned IsMsg:1;    /* Spelled Msg... */
   unsigned IsAll:1;    /* Spelled All... */
   unsigned Routine:1;  /* Mixed case. */
   unsigned InSwitch:1;
   unsigned IsExit:1;  /* Has an underscore in it. */
   unsigned IsKey:1;  /* Keyword */
   unsigned Fix:7;  /* Cant get C600 to do bytes so make explicit. */
   Uchar Hatch;
   Ushort Num;
   Ushort ProdPos; /* Index value part of Text. */
   Ushort SymbolLength;
   char s[1]; /* Will actually be SymbolLength characters */
 } Symbol;
Storage Bool MsgFlag; /* Set if any terminal starts 'Msg...' */
#if Extern == 1
extern char * Specials;
#else
extern char * Specials = ":()<>[]|=;+" ; /* In step with codes. */
#endif
/* Codes for special tokens. cf case _SPECIAL. Used outside Readin as well. */
/* These and only these _SPECIAL in RDASCII.H */
#define Colon -1
#define LeftParen -2
#define RightParen -3
#define LeftAngle -4
#define RightAngle -5
#define LeftBracket -6
#define RightBracket -7
#define SpecialOr -8
#define Assignment -9
#define SemiColon -10
#define Plus -11
#define Break -12
/* The following are available after readin. */
Storage Symbol *Sym; /* Addresses Dict item. Set by SymLoc. */
Storage Offset Syo; /* of symbol */
Storage Offset SyoLo; /* First symbol */
Storage Offset SyoZi; /* Beyond Last */
#define SymLoc(x) ((Symbol*)(WalkBase+(x)))
/* Thru the symbols.  */
#define WhileSym Syo=SyoLo;while(Syo<SyoZi){Sym=SymLoc(Syo);
#define EndSym Syo=Syo+Offsetof(Symbol,s)+SymLoc(Syo)->SymbolLength;}
