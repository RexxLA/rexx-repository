/* ALWAYS.H included in all C compiles. */
/* LINT_ARGS causes extra type checking. */
#define LINT_ARGS
#define Yes 1
#define No  0
#define True 1
#define False 0
/* Type declarations that don't commit too much. */
/* Small integers means a byte is sufficient.  Use where space is crucial
or when working with (one-byte) characters. */
#define Uchar unsigned char
#define Bool unsigned char
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
/* Unused declarations only cost us a bit of compile time so we will make
some standard. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* #include <malloc.h> */
#include <setjmp.h>
#include <process.h>
#include <limits.h>
#include <ctype.h>
