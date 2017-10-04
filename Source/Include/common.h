/* Common definitions and macros for C-language routines
 * Copyright 2014, Dakotah Lambert.
 * All Rights Reserved.
 */
#ifndef COMMON_H
#define COMMON_H

#ifdef __GNUC__
#define likely(x)    (__builtin_expect(!!(x), 1))
#define unlikely(x)  (__builtin_expect(!!(x), 0))
#else
#define likely(x)    (!!(x))
#define unlikely(x)  (!!(x))
#endif

#define BOOL(x) ((unsigned int)(!!(x)))

typedef unsigned char Byte;
typedef unsigned short Word;
typedef unsigned long DWord;

#endif
