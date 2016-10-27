/*
 * Based on ``Random Number Generators: Good Ones are Hard to Find'',
 * Communications of the ACM, Oct 1988, Vol 31 No 10.
 */

#include "random.h"

static unsigned int       seed                =      1;
static unsigned int const multiplier          =  16087;
static unsigned int const max_over_multiplier = 127773;
static unsigned int const max_mod_multiplier  =   2836;

unsigned int
rand_range(unsigned int const min, unsigned int const max)
{
	return min + (rand() % (max - min + 1));
}

void
srand(unsigned int value)
{
	seed = value;
}

unsigned int
rand(void)
{
	unsigned int low, high;
	unsigned int s = seed;
	
	/* seed / max_over_multiplier is really seed * multiplier / RAND_MAX,
	 * but it ensures that we do not have integer overflow. Since this is
	 * integer arithmetic, we need the remainder of this division still,
	 * which is held in low.
	 */
	high   = (s / max_over_multiplier) * max_mod_multiplier;
	low    = (s % max_over_multiplier) * multiplier;
	if (high < low)
	{
		seed = low - high;
	}
	else
	{
		seed = RAND_MAX - high + low;
	}
	return seed;
}
