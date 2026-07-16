#ifndef COMPRESS_H
#define COMPRESS_H

#include <stdint.h>
#include <stddef.h>

#define COMPRESS_MAGIC_SZ 8
#define COMPRESS_MAGIC_B0 0x4B
#define COMPRESS_MAGIC_B1 0x5A
#define COMPRESS_MAGIC_B2 0x43
#define COMPRESS_MAGIC_B3 0x00

size_t compress_bound(size_t input_size);
size_t compress(const void *input, size_t input_size, void *output, size_t output_size);
size_t decompress(const void *input, size_t input_size, void *output, size_t output_size);

#endif
