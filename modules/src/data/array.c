#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "array.h"

static void extend(struct array* array)
{
	if (array->count == array->max)
	{
		int newmax = (array->max == 0) ? 8 : (array->max * 2);
		void** newarray = realloc(array->item, newmax * sizeof(void*));

		array->max = newmax;
		array->item = newarray;
	}
}

void array_append(void* arrayp, void* value)
{
    struct array* array = arrayp;

    extend(array);
    array->item[array->count] = value;
    array->count++;
}

bool array_contains(void* arrayp, void* value)
{
    struct array* array = arrayp;
	int i;

	for (i=0; i<array->count; i++)
		if (array->item[i] == value)
			return true;

	return false;
}

bool array_appendu(void* arrayp, void* value)
{
	if (array_contains(arrayp, value))
        return true;

    array_append(arrayp, value);
    return false;
}

void array_insert(void* arrayp, void* value, int before)
{
    struct array* array = arrayp;

    extend(array);
    memmove(&array->item[before+1], &array->item[before],
        (array->count-before) * sizeof(*array));
    array->item[before] = value;
    array->count++;
}

void array_remove(void* arrayp, void* value)
{
    struct array* array = arrayp;
    int i;

    for (i=0; i<array->count; i++)
    {
        if (array->item[i] == value)
        {
            while (i < (array->count-1))
            {
                array->item[i] = array->item[i+1];
                i++;
            }
            array->count--;
            return;
        }
    }
}

/* vim: set sw=4 ts=4 expandtab : */
