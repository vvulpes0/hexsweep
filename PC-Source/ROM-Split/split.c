#include <stdio.h>
#include <stdlib.h>

int
main(void)
{
	short i = 0;
	int c;

	while ((c = fgetc(stdin)) != EOF)
	{
		fputc(c,
		      i
		      ? stderr /* odd offsets */
		      : stdout /* even offsets */);
		i = 1 - i;
	}
	return EXIT_SUCCESS;
}
