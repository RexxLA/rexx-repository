/* ALWAYS.H was included in all C compiles. Here C++ needs less. */

/* Type declarations that don't commit too much. */
/* Small integers means a byte is sufficient.  Use where space is crucial
or when working with (one-byte) characters. */
#define Uchar unsigned char
/* When 2 bytes sufficient we have Ushort. */
#define Ushort unsigned short
#define Offset unsigned short
/* Ulong means 31 bits wouldn't be enough. */
#define Ulong unsigned long
#define Dim(a) (sizeof(a)/sizeof(a[0]))
#define Max(a,b) ((a<b)?(b):(a))
#define Min(a,b) ((a>b)?(b):(a))
#define Clear(a) memset(&a,'\0',sizeof(a))
#define Assign(a,b) memcpy(&a,&b,sizeof(a))
#define Compare(a,b) memcmp(&a,&b,sizeof(a))
#define Offsetof(s,m)   (size_t)&(((s *)0)->m)
