#ifndef RANDOM_H
#define RANDOM_H

#include <limits.h>

#ifdef __cplusplus
extern "C" {
#endif

#define RAND_MAX INT_MAX

unsigned int rand(void);
void srand(unsigned int);

unsigned int rand_range(unsigned int const, unsigned int const);

#ifdef __cplusplus
}
#endif
	
#endif
