#include "compress.h"
#include <string.h>

#define LZ_WINDOW 4096
#define LZ_MAX_MATCH 18
#define LZ_MIN_MATCH 3
#define LZ_HASH_BITS 12
#define LZ_HASH_SIZE (1 << LZ_HASH_BITS)

size_t compress_bound(size_t input_size) {
  return input_size + input_size / 4 + COMPRESS_MAGIC_SZ;
}

static size_t lzss_compress(const uint8_t *in, size_t in_sz, uint8_t *out,
                            size_t out_sz) {
  size_t ip = 0, op = 0;
  int16_t hash[LZ_HASH_SIZE];
  int16_t prev[LZ_WINDOW];
  memset(hash, -1, sizeof(hash));
  memset(prev, -1, sizeof(prev));

  while (ip < in_sz) {
    size_t ctrl_pos = op;
    if (op >= out_sz) return 0;
    out[op++] = 0;

    for (int b = 0; b < 8; b++) {
      if (ip >= in_sz) break;

      int best_off = 0, best_len = 0;
      if (ip >= LZ_MIN_MATCH) {
        unsigned h = (in[ip] ^ ((unsigned)in[ip + 1] << 8)) % LZ_HASH_SIZE;
        int wstart = ip > LZ_WINDOW ? ip - LZ_WINDOW : 0;
        int m = hash[h];
        while (m >= wstart && m < (int)ip) {
          int max_len = in_sz - ip;
          if (max_len > LZ_MAX_MATCH) max_len = LZ_MAX_MATCH;
          int len = 0;
          while (len < max_len && in[m + len] == in[ip + len]) len++;
          if (len >= LZ_MIN_MATCH && len > best_len) {
            best_off = ip - m;
            best_len = len;
            if (len >= LZ_MAX_MATCH) break;
          }
          m = prev[m % LZ_WINDOW];
        }
        prev[ip % LZ_WINDOW] = hash[h];
        hash[h] = ip;
      }

      if (best_len >= LZ_MIN_MATCH) {
        out[ctrl_pos] |= (1 << (7 - b));
        unsigned ref = ((best_len - LZ_MIN_MATCH) << 12) | best_off;
        if (op + 2 > out_sz) return 0;
        out[op++] = (ref >> 8) & 0xFF;
        out[op++] = ref & 0xFF;
        ip += best_len;
      } else {
        if (op + 1 > out_sz) return 0;
        out[op++] = in[ip++];
      }
    }
  }
  return op;
}

static size_t lzss_decompress(const uint8_t *in, size_t in_sz, uint8_t *out,
                              size_t out_sz) {
  size_t ip = 0, op = 0;
  uint8_t win[LZ_WINDOW];
  size_t wp = 0;
  memset(win, 0, sizeof(win));

  while (ip < in_sz && op < out_sz) {
    uint8_t ctrl = in[ip++];
    for (int b = 0; b < 8; b++) {
      if (ip >= in_sz || op >= out_sz) break;
      if (ctrl & (1 << (7 - b))) {
        if (ip + 2 > in_sz) break;
        unsigned ref = ((unsigned)in[ip] << 8) | in[ip + 1];
        ip += 2;
        int len = (ref >> 12) + LZ_MIN_MATCH;
        int off = ref & 0xFFF;
        if (off == 0 || off > LZ_WINDOW) break;
        for (int i = 0; i < len && op < out_sz; i++) {
          uint8_t c = win[(wp - off + LZ_WINDOW) % LZ_WINDOW];
          out[op++] = c;
          win[wp] = c;
          wp = (wp + 1) % LZ_WINDOW;
        }
      } else {
        uint8_t c = in[ip++];
        out[op++] = c;
        win[wp] = c;
        wp = (wp + 1) % LZ_WINDOW;
      }
    }
  }
  return op;
}

char compress_magic[4] = {COMPRESS_MAGIC_B0, COMPRESS_MAGIC_B1,
                          COMPRESS_MAGIC_B2, COMPRESS_MAGIC_B3};

size_t compress(const void *input, size_t input_size, void *output,
                size_t output_size) {
  uint8_t *out = output;
  size_t out_pos = 0;

  if (output_size < COMPRESS_MAGIC_SZ) return 0;
  memcpy(out, compress_magic, 4);
  out_pos += 4;
  uint32_t usz = input_size;
  memcpy(out + out_pos, &usz, sizeof(usz));
  out_pos += 4;

  size_t comp = lzss_compress(input, input_size, out + out_pos,
                              output_size - out_pos);
  if (comp == 0) return 0;
  return out_pos + comp;
}

size_t decompress(const void *input, size_t input_size, void *output,
                  size_t output_size) {
  const uint8_t *in = input;
  if (input_size < COMPRESS_MAGIC_SZ) return 0;
  if (memcmp(in, compress_magic, 4) != 0) return 0;

  uint32_t usz;
  memcpy(&usz, in + 4, sizeof(usz));
  if (usz > output_size) return 0;

  size_t dec = lzss_decompress(in + COMPRESS_MAGIC_SZ,
                               input_size - COMPRESS_MAGIC_SZ, output, usz);
  return dec;
}
