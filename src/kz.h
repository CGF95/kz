#ifndef _KZ_H
#define _KZ_H

#include <stdint.h>
#include <vector/vector.h>

typedef struct  {
    _Bool ready;    
    struct vector watches;
} kz_ctxt_t;

#endif