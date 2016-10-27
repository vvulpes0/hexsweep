#ifndef RANDOM_H
#define RANDOM_H

#ifdef __cplusplus
extern "C" {
#endif

#define RAND_MAX (2147483647U)

unsigned int rand(void);
void srand(unsigned int);

unsigned int rand_range(unsigned int const, unsigned int const);

#ifdef __cplusplus
}
#endif
	
#endif
